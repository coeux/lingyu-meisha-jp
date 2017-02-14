
--========================================================================
--战斗管理者类

FightManager = 
	{
		isAuto				= true;						--是否自动战斗
		isOver				= true;							--战斗结束标志
		isPvP				= false;						--是否为PVP模式	
		state				= FightState.none;				--是否为战斗模式
		mFightType			= FightType.normal;				--战斗类型

		pveLeftPos			= Vector3(-400,0,0);			--pve左边出生点lo
		pvpLeftPos			= Vector3(-473,0,0);			--pvp左边出生点
		leftPos				= nil;							--左边出生地点
		rightPos			= Vector3(473,0,0);				--右边出生点
		
		frontPositionList	= {};							--敌我双方最前方的角色位置
		
		yOrderList			= Configuration.YOrderList;
		zOrderList         = {-100, -50, 0, 50, 100}; -- 图层优先级
		
		time				= 0;							--战斗系统时间
		pauseTime			= 0;							--战斗暂停时间
		
		actorList			= {};							--所有角色列表
		needleftActorList	= {};							--左侧准备入场的ActorList
		needrightActorList	= {};							--右侧准备入场的ActorList
		idleMonsterList		= {};							--右侧提前入场，在战场待机的怪物
		leftActorList		= {};							--左侧的ActorList
		rightActorList		= {};							--右侧的ActorList
		
		fightOverTimer		= 0;							--战斗结束计时器
	};

--初始化
function FightManager:Initialize( sceneID, leftActorList, rightActorList, isRecord, fightResult)

	--===============================================================================
	self.barrierId				= sceneID;				--关卡ID
	self:fightType();									--计算战斗类型和是否pvp战斗
	
	if self.isPvP or (self.mFightType == FightType.worldBoss) or (self.mFightType == FightType.unionBoss) then
		self.leftPos = self.pvpLeftPos;
	else
		self.leftPos = self.pveLeftPos;
	end
	
	--================================================================================
	--初始化战斗状态
	self.state = FightState.fightState;					--初始化过程设置成loading状态
	
	--================================================================================
	--属性相关
	self.isOver	= false;										--战斗结束标志

	if isRecord == true then
		self.isRecord = true;									--战斗模式
	else
		self.isRecord = false;									--录像模式
	end	
	
	self.meleeFighterCount	= 0;							--pve时本方近战英雄数量
	self.remoteFighterCount	= 0;							--pve时本方远程英雄数量
	if self.isPvP then	
		self.needrightActorList = rightActorList;
		self:SortEnterLineByJob(self.needrightActorList, true);
	else
		self.idleMonsterList	= rightActorList;			--战场中提前入场的怪物
		self.needrightActorList = {};
	end	

	self.needleftActorList	= leftActorList;				--左侧准备入场的ActorList
	self:SortEnterLineByJob(self.needleftActorList, false);
	self.leftActorList		= {};							--左侧的ActorList
	self.rightActorList		= {};							--右侧的ActorList
	self.deathActorList		= {};							--死亡的ActorList
	self.actorList			= {};							--所有角色列表

	self.count = 0;											--进场的英雄及伙伴个数
	self.enemyCount = 0;									--进场的地方角色个数
	self.time = 0;											--战斗系统时间
	self.pauseTime = 0;										--战斗暂停时间
	self.enterSpacingTime = Configuration.FirstPartnerEnterBattleTime;	--设置第一个友方角色入场时间
	self.lastPlayerEnterTime = 0;							--英雄或者伙伴上次进入时间
	
	GlobalData.RightTotalDamage = 0;
		
	EventManager:Init();
	FightRecordManager:Init();
	FightShowSkillManager:Initialize();
	
	self:loadIdleMonster();
end

--初始化战斗角色的形象数据
function FightManager:InitAllFightersAvatar()
	for _, fighter in ipairs(self.needleftActorList) do
		fighter:InitAvatar();
	end
	
	for _, fighter in ipairs(self.needrightActorList) do
		fighter:InitAvatar();
	end	
end

--销毁
function FightManager:Destroy()
	
	--触发销毁战斗事件
	EventManager:FireEvent(EventType.DestroyFight, self.barrierId);
	
	for _,fighter in ipairs(self.actorList) do
		ActorManager:DestroyActor(fighter:GetID());		--销毁Fighter
	end
	
	self.actorList = {};
	self.deathActorList = {};
	self.needleftActorList	= {};						--左侧准备入场的ActorList
	self.needrightActorList	= {};						--右侧准备入场的ActorList
	self.leftActorList = {};							--左侧的ActorList
	self.rightActorList = {};							--右侧的ActorList

	self.isOver = true;									--将游戏是否结束标志复原
	self.state = FightState.none;						--游戏退出战斗（战斗和录像）界面	
end	

--更新
function FightManager:Update( elapse )
	if FightState.fightState == self.state then
		self:fightBattles(elapse);			--战斗模式
	elseif FightState.pauseState == self.state then
		self.pauseTime = self.pauseTime + elapse;
	end
	
end

--游戏是否处于running状态
function FightManager:IsRunning()
	if (self.state == FightState.fightState) or (self.state == FightState.recordState) then
		if self.isOver then
			return false;
		else
			return true;
		end	
	else
		return false;
	end
end


--获取角色剩余血量百分比
function FightManager:GetAllyLeftHpRatio()
	if (self.result == Victory.right) then
		--失败
		return 0;
	end

	local curTotalHp = 0;
	local originalTotalHp = 0;
	for _, fighter in ipairs(self.actorList) do
		if (not fighter:IsEnemy()) then
			curTotalHp = curTotalHp + fighter:GetCurrentHP();
			originalTotalHp = originalTotalHp + fighter:GetMaxHP();
		end
	end
	return curTotalHp / originalTotalHp;
end

--===================================================================================
--角色入场

--根据职业排列出场顺序
function FightManager:SortEnterLineByJob(fighterList, isEnemy)
	local meleeHeroList = {};
	local remoteHeroList = {};

	for _,v in ipairs(fighterList) do
		if v:IsMeleeFighter() then
			table.insert(meleeHeroList, v);
		else
			table.insert(remoteHeroList, v);
		end		
	end

	local index = 0;
	for _, role in ipairs(meleeHeroList) do
		index = index + 1;
		role:SetEnterLine(index);
	end
	if not isEnemy then
		self.meleeFighterCount = index;
	end

	for _, role in ipairs(remoteHeroList) do
		index = index + 1;
		role:SetEnterLine(index);
	end
	if not isEnemy then
		self.remoteFighterCount = index - self.meleeFighterCount;
	end
end

--进入场景
function FightManager:enterScene( actor, isEnemy )
	local index = 0;
	
	if not isEnemy then
		--己方
		index = Configuration.BattleYPositionLine[math.mod(self.count - 1, #self.zOrderList) + 1];
		actor:SetPosition(Vector3(self.leftPos.x, self.yOrderList[index], 0));
		actor:SetDirection(DirectionType.faceright);
	else
		index = actor:GetEnterLine();
		actor:SetPosition(Vector3(self.rightPos.x, self.yOrderList[index], 0));
		actor:SetDirection(DirectionType.faceleft);
	end	
	
	actor:SetEnterFight();										--设置角色已经入场的状态

	table.insert(self.actorList, actor);
end

--加载提前入场的怪物
function FightManager:enterSceneBeforBattle(actor, xPosition, index)
	local pos = Vector3(xPosition, self.yOrderList[index], 0);
	local dir = DirectionType.faceleft;
	
	actor:SetEnterFight();										--设置角色已经入场的状态
	actor:SetDirection(dir);	
	actor:SetPosition(pos);	
	actor:SetZOrder(self.zOrderList[math.mod(index - 1, #self.zOrderList) + 1]);					--设置角色zOrder，即设置图层
	
	table.insert(self.actorList, actor);
end

--加载入场角色和怪物
function FightManager:loadFighter(elapse)
	--间隔n秒进入一个人物
	if self.time - self.lastPlayerEnterTime > self.enterSpacingTime then	
		self.lastPlayerEnterTime = self.time;
		self:loadAllyPlayer();			--加载友方角色
		
		if self.isPvP then
			self:loadEnemyPlayer();		--加载pvp敌方角色
		end	
	end	
end	

--加载本方角色
function FightManager:loadAllyPlayer()
	if #(self.needleftActorList) ~= 0 then	
		local enterFighter = self.needleftActorList[1];
		self.count = self.count + 1;											--记录本方已入场人数
		enterFighter:SetTeamIndex(self.count);						--设置角色在本方阵列的出场顺序			
		enterFighter:SetStandArea(self.count); 			--设置角色站位
		enterFighter:SetYPosition(self.count); 			--设置站位
		enterFighter:SetIsEnemy(false);							--设置角色不为敌方
		enterFighter:SetKeepIdle();
		FightManager:enterScene( enterFighter, false );			--人物进入场景
		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, enterFighter, self.count);
		
		--触发角色入场的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.enterScene, self.time, enterFighter);

		--重置人物入场时间间隔
		if 1 == self.count then
			self.enterSpacingTime = Configuration.PartnerEnterSpacingTime;
		end
		
		table.insert(self.leftActorList, enterFighter);
		table.remove(self.needleftActorList, 1);			
	end	
end

--加载pvp敌方角色
function FightManager:loadEnemyPlayer()
	if #(self.needrightActorList) ~= 0 then	
		local enterFighter = self.needrightActorList[1];
		self.enemyCount = self.enemyCount + 1;									--记录敌方已入场人数
		enterFighter:SetTeamIndex(self.enemyCount);				--设置角色在本方阵列的出场顺序				
		enterFighter:SetStandArea(self.enemyCount); 			--设置角色站位
		enterFighter:SetYPosition(self.enemyCount); 			--设置站位
		enterFighter:SetIsEnemy(true);							--设置角色为敌方
		enterFighter:SetKeepIdle();	
		FightManager:enterScene( enterFighter, true );			--人物进入场景
		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, enterFighter, self.enemyCount);

		--触发角色入场的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.enterScene, self.time, enterFighter);

		table.insert(self.rightActorList, enterFighter);
		table.remove(self.needrightActorList, 1);
	end	
end	

--加载提前入场的怪物
function FightManager:loadIdleMonster()	
	if 0 == #(self.idleMonsterList) then	
		return;
	end
	
	--加载提前入场的怪物
	for _,monsterItem in ipairs(self.idleMonsterList) do
		self.enemyCount = self.enemyCount + 1;						--记录敌方已入场人数		
		monsterItem.monster:SetTeamIndex(self.enemyCount);			--设置角色在本方阵列的出场顺序
		FightManager:enterSceneBeforBattle( monsterItem.monster, monsterItem.xPos, monsterItem.index );
		
		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, monsterItem.monster, self.enemyCount);
		
		--触发角色入场的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.enterScene, self.time, monsterItem.monster);
	
		table.insert(self.rightActorList, monsterItem.monster);												--插入怪物列表
	end
	
	self.idleMonsterList = {};
end

--从角色列表中删除某个角色
function FightManager:DeleteFighter(fighter)
	table.insert(self.deathActorList, fighter);
	local actorList = {};
	if fighter:IsEnemy() then
		actorList = self.rightActorList;
	else
		actorList = self.leftActorList;
	end

	local index = 1;
	while true do
		if fighter:GetID() == actorList[index]:GetID() then
			table.remove(actorList, index);
			break;
		end

		index = index + 1;
	end
end

--继续战斗
function FightManager:Continue()
	--触发战斗恢复的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.fightResume, self:GetTime());
	
	if FightState.pauseState == self.state then
		self:ResumeAction();
		self:ResumeEffectScript();
	end

	if self.isRecord then
		self.state = FightState.recordState;
	else
		self.state = FightState.fightState;
	end		
end

--恢复角色动作
function FightManager:ResumeAction()
	for _,actor in ipairs(self.leftActorList) do
		actor:ContinueAction();
	end
	
	for _,actor in ipairs(self.rightActorList) do
		actor:ContinueAction();
	end
end

--恢复技能脚本及追踪特效
function FightManager:ResumeEffectScript()
	--恢复全部技能脚本更新
	effectScriptManager:ResumeAllEffectScript();
	
	--恢复全部lua有引用保存的特效
	EffectManager:ResumeAllEffect();
end

--暂停战斗
function FightManager:Pause( holdAnimation )
	self.state = FightState.pauseState;
	self.pauseTime = 0;
	
	if holdAnimation then
	else
		self:PauseAction();
		self:PauseEffectScript();
	end
	
	--触发战斗暂停的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.fightPause, self:GetTime());
end

--暂停角色动作及角色身上的挂点特效
function FightManager:PauseAction()
	for _,actor in ipairs(self.leftActorList) do
		actor:PauseAction();
	end
	
	for _,actor in ipairs(self.rightActorList) do
		actor:PauseAction();
	end
end

--暂停技能脚本及追踪特效
function FightManager:PauseEffectScript()
	--暂停全部技能脚本更新
	effectScriptManager:PauseAllEffectScript();
	
	--暂停全部lua有引用保存的特效
	EffectManager:PauseAllEffect();
end	

--进行战斗
function FightManager:fightBattles(elapse)
	self.time = self.time + elapse;				--累计时间

	--加载战斗角色
	if (0 ~= #(self.needleftActorList) or 0 ~= #(self.needrightActorList)) and (not self.isOver) then
		self:loadFighter(elapse);
	end	

	self:SortActorList();
	
	--判断战斗是否结束
	if self:IsOver() then
		return;
	end
end

--判断战斗是否结束
function FightManager:IsOver()
	if (self.isOver) then
		return true;
	end
	
	--战斗结束判断
	if #(self.actorList) ~= 0 then
		if (#self.needleftActorList == 0) and (#self.leftActorList == 0) then
			self.isOver = true;
			self.result = Victory.right;
		elseif (#self.needrightActorList == 0) and (#self.rightActorList == 0) and (#self.idleMonsterList == 0) then	
			self.isOver = true;
			self.result = Victory.left;
		end	
	end	
	
	if (self.time > 180) then
		--战斗时间过长，攻防失败
		self.isOver = true;
		self.result = Victory.right;
	end

	--战斗结束
	if self.isOver then	
		--触发镜头拉近动作
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.cameraZoomIn, self.time, self.result);
		
		--将角色设置成待机动作
		for _, actor in ipairs(self.leftActorList) do
			actor:SetStateAfterBattle();
		end
		for _, actor in ipairs(self.rightActorList) do
			actor:SetStateAfterBattle();
		end
		
		return true;
		
	else
		return false;
	end
end	

--根据位置排序角色列表
function FightManager:SortActorList()
	table.sort(self.leftActorList, function (tar1, tar2)
		return tar1:GetPosition().x > tar2:GetPosition().x;
	end);
	
	if #self.leftActorList > 0 then
		self.frontPositionList[DirectionType.faceleft] = self.leftActorList[1]:GetPosition().x + self.leftActorList[1]:GetWidth() / 2;
	else
		self.frontPositionList[DirectionType.faceleft] = self.leftPos.x;
	end
		
	table.sort(self.rightActorList, function (tar1, tar2)
		return tar1:GetPosition().x < tar2:GetPosition().x;
	end);
	
	if #self.rightActorList > 0 then
		self.frontPositionList[DirectionType.faceright] = self.rightActorList[1]:GetPosition().x - self.rightActorList[1]:GetWidth() / 2;
	else
		self.frontPositionList[DirectionType.faceright] = self.rightPos.x;
	end
end

--获取排序后的角色列表
function FightManager:GetOrderedTargeterList(isEnemy)
	if isEnemy then
		return self.rightActorList;
	else
		return self.leftActorList;
	end
end

--获取角色当前可以移动到的最前的位置
function FightManager:GetForwardPosition(fighter)
	if fighter:GetDirection() == DirectionType.faceright then
		if fighter:GetPosition().x + fighter:GetWidth() / 2 > self.frontPositionList[DirectionType.faceright] then
			return false, self.frontPositionList[DirectionType.faceright];
		else
			return true;
		end
	else
		if fighter:GetPosition().x - fighter:GetWidth() / 2 < self.frontPositionList[DirectionType.faceleft] then
			return false, self.frontPositionList[DirectionType.faceleft];
		else
			return true;
		end
	end
end

--获取出生点坐标
function FightManager:GetBornPosition(directionType)
	if directionType == DirectionType.faceright then
		return self.rightPos.x;
	else
		return self.leftPos.x;
	end
end	

--====================================================================================
--录像相关
--====================================================================================
--是否录像模式
function FightManager:IsRecord()
	if (FightState.recordState == self.state) or (FightState.recordPauseState == self.state) then
		return true;
	else
		return false;
	end
end	

--=======================================================================================
--属性设置和获取
--=======================================================================================
--添加暂停时间
function FightManager:AddPauseTime(elapse)
	self.pauseTime = self.pauseTime + elapse;
end

--获取战斗持续时间
function FightManager:GetTime()
	if self.state == FightState.fightState then
		return self.time;
	elseif self.state == FightState.pauseState then
		return self.pauseTime;
	end
end		

--获取战斗方式是否为自动战斗
function FightManager:IsAuto()
	return self.isAuto;
end

--计算当前的战斗状态
function FightManager:fightType()
	if (self.barrierId >= Configuration.NormalRoundBeginID) and (self.barrierId <= Configuration.NormalRoundEndID) then
		self.mFightType = FightType.normal;			--普通关卡
		self.isPvP = false;
	elseif (self.barrierId > Configuration.NormalRoundEndID) and (self.barrierId <= Configuration.ZodiacRoundBeginID) then
		self.mFightType = FightType.elite;			--精英关卡
		self.isPvP = false;
	elseif (self.barrierId > Configuration.ZodiacRoundBeginID) and (self.barrierId < Configuration.TreasureBaseRoundID) then
		self.mFightType = FightType.instance;		--十二宫
		self.isPvP = false;
	elseif (self.barrierId >= Configuration.InvasionStartID) and (self.barrierId <= Configuration.InvasionEndID) then
		self.mFightType = FightType.invasion;		--杀星
		self.isPvP = false;
	elseif (self.barrierId > Configuration.TreasureBaseRoundID) then
		self.mFightType = FightType.treasureBattle;	--巨龙宝库
		self.isPvP = false;
	elseif self.barrierId == Configuration.NoviceBattleID then
		self.mFightType = FightType.noviceBattle;	--新手战斗
		self.isPvP = false;
	elseif self.barrierId == FightType.worldBoss then
		self.mFightType = FightType.worldBoss;		--世界boss战
		self.isPvP = false;
	elseif self.barrierId == FightType.unionBoss then
		self.mFightType = FightType.unionBoss;		--公会boss
		self.isPvP = true;
	elseif self.barrierId == FightType.FriendBattle then
		self.mFightType = FightType.FriendBattle;	--好友挑战
		self.isPvP = true;
	else
		self.isPvP = true;
		self.mFightType = self.barrierId;
	end
end	

--设置入场角色个数
function FightManager:SetFighterCount(count, isEnemy)
	if isEnemy then
		self.enemyCount = count;
	else
		self.count = count;
	end
end	

--添加遮罩
function FightManager:AddShader()

end

--移除遮罩
function FightManager:RemoveShader()

end
