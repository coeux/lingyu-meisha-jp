
--========================================================================
--战斗管理者类

FightManager = 
{
    isPanelInit			= false;						--战斗UI是否经过初始化
    isAuto				= true;							--是否自动战斗
    fightSpeed			= 1;
    isOver				= true;							--战斗结束标志
    isPvP				= false;						--是否为PVP模式	
    state				= FightState.none;				--是否为战斗模式
    actorList			= {};							--所有角色列表
    leftPos				= Vector3(-473,0,0);			--左边出生点
    rightPos			= Vector3(473,0,0);				--右边出生点
    yOrderList			= Configuration.YOrderList;
    zOrderList			= {-100, 0, 100};
    time				= 0;							--战斗系统时间
    needleftActorList	= {};							--左侧准备入场的ActorList
    needrightActorList	= {};							--右侧准备入场的ActorList
    idleMonsterList		= {};							--右侧提前入场，在战场待机的怪物
    leftActorList		= {};							--左侧的ActorList
    rightActorList		= {};							--右侧的ActorList	
    fightOverTimer		= nil;							--战斗结束计时器
};

--初始化
function FightManager:Initialize( sceneID, leftActorList, rightActorList, recordList, fightResult)
	
	--========================================================================
	--属性相关
	self.isOver				= false;				--战斗结束标志	
	
	if nil == fightResult then
		self.result = Victory.none;					--战斗结果(1表示左边赢，2表示右边赢)
		self.state = FightState.fightState;			--战斗模式
	else
		self.result = fightResult;					--存储战斗录像结果
		self.state = FightState.recordState;		--录像模式
	end	

	self.recordList = recordList;					--战斗录像事件列表
	
	self.needleftActorList	= leftActorList;		--左侧准备入场的ActorList
	self.needrightActorList	= rightActorList[1];	--右侧准备入场的ActorList	
	self.idleMonsterList	= rightActorList[2];	--战场中提前入场的怪物
	self.leftActorList		= {};					--左侧的ActorList
	self.rightActorList		= {};					--右侧的ActorList
	self.deathActorList		= {};					--死亡的ActorList
	self.actorList			= {};					--所有角色列表	
	self.cameraReferenceActor = nil;				--相机参考坐标角色
	self.isCameraMoveToActor = true;				--相机是否向角色移动
	self.lastCameraActorSign = -1;					--前一帧相机X位置和参考角色X位置差方向
	self.curCameraActorSign = -1;					--下一帧相机X位置和参考角色X位置差方向
	self.xPositionIndentation = self:getXpositionIndentation();	--角色在战斗场景中X轴方向的位移差

	self.count = 0;									--进场的英雄及伙伴个数
	self.enemyCount = 0;							--进场的地方角色个数
	self.time				= 0;					--战斗系统时间
	self.enterSpacingTime 	= Configuration.FirstPartnerEnterBattleTime;	--设置第一个友方角色入场时间
	self.lastPlayerEnterTime = 0;					--英雄或者伙伴上次进入时间
	self.lastMonsterEnterTime = 0;					--怪物上一波入场时间
	self.firstIdleMonsterWakeUpTime = nil;			--上一个待机怪物觉醒时间

	
	--录像列表初始化
	if 0 == #self.recordList then
		self.recordList.leftActorRecordList = {};
        self.recordList.rightActorRecordList = {};
	end

	--加载提前入场的怪物
	self:loadIdleMonster();
end

--获取战斗时三条战线在x轴方向的位移差
function FightManager:getXpositionIndentation()
	local index = math.random(1, 10);
	local xArray = {};
	for i = 1, 6 do
		xArray[i] = Configuration.XPositionIndentation[math.mod(index, 10) + 1];
		index = index + 1;
	end
	return xArray;
end

--
function FightManager:GetAlertLineXposition()
	return self.alertLineXposition;
end

--销毁
function FightManager:Destroy()
	
	--销毁Fighter
	for _,fighter in ipairs(self.actorList) do
		ActorManager:DestroyActor( fighter:GetID() )
	end
	
	--将游戏是否结束标志复原
	self.isOver = true;
	
	self.state = FightState.none;
end	

--是否录像模式
function FightManager:IsRecord()
	if (FightState.recordState == self.state) then
		return true;
	else
		return false;
	end
end

--获取战斗持续时间
function FightManager:GetFightTime()
	return self.time;
end		

--获取战斗方式是否为自动战斗
function FightManager:IsAuto()
	return self.isAuto;
end

--更新
function FightManager:Update( elapse )

	if FightState.fightState == self.state then
		--战斗模式
		self:fightBattles(elapse);
		--更新角色
		for _,actor in ipairs(self.leftActorList) do
			
			actor:Update(elapse);
		end
		for _,actor in ipairs(self.rightActorList) do	
			actor:Update(elapse)
		end
	elseif FightState.recordState == self.state then
		--录像模式
		self:playRecord(elapse);
	end
	
end	

--进行战斗
function FightManager:fightBattles(elapse)
	--!!!如果帧率丢失太严重，临时写的!!!
	if elapse > 0.5 then
		elapse = 0.000001;
	end	
	
    --累计时间
	self.time = self.time + elapse;	

	--加载战斗角色
	if 0 ~= #(self.needleftActorList) or 0 ~= #(self.needrightActorList) then	
    	self:loadFighter(elapse);
	end	
	
	--更新（增加左右特效列表是解决最后一击同时死亡的问题）
	local effectScriptList = {};
	FightManager:updateActor(self.leftActorList, self.rightActorList, elapse, effectScriptList);
	FightManager:updateActor(self.rightActorList, self.leftActorList, elapse, effectScriptList);
	
	if self.isOver then
		--战斗结束
		return;
	end

	--战斗结束判断
	if #(self.actorList) ~= 0 then

		if (#self.needleftActorList == 0) and (#self.leftActorList == 0) then
			self.isOver = true;
			self.result = Victory.right;
		elseif (#self.needrightActorList == 0) and (#self.rightActorList == 0) and (#self.idleMonsterList == 0) then	
			self.isOver = true;
			self.result = Victory.left;	
			--tools_t:print_r(self.recordList)
		end
		
	end

	--执行特效脚本
	for _,effectScript in ipairs(effectScriptList) do
		effectScript:TakeOff();
	end	
	
	--战斗结束
	if self.isOver then	
		self:InsertRecordEvent(self.deathActorList[#self.deathActorList], nil, nil, self.result);
	end
	
end

--将录像事件插入录像列表中
--recordList为self.recordList.leftActorRecordList或者self.recordList.rightActorRecordList
--actor为动作执行人，actionType为动作类型，otherDataItem为table，可能包含目标列表1，目标列表2和伤害列表
function FightManager:InsertRecordEvent(actor, fighterState, otherDataItem, victory)
	if 0 == fighterState then
		--print()
	end
	local oneSideRecordList = {};
	if Victory.right == victory then
		oneSideRecordList = self.recordList.leftActorRecordList;
	elseif Victory.left == victory then
		oneSideRecordList = self.recordList.rightActorRecordList;
	else
		if DirectionType.faceright == actor:GetDirection() then
			oneSideRecordList = self.recordList.leftActorRecordList;
		else
			oneSideRecordList = self.recordList.rightActorRecordList;
		end
	end
	
	self:InsertLeftOrRightRecordEvent(oneSideRecordList, actor, fighterState, otherDataItem, victory);
end

--将录像事件插入录像列表中
--recordList为self.recordList.leftActorRecordList或者self.recordList.rightActorRecordList
--actor为动作执行人，actionType为动作类型，otherDataItem为table，可能包含目标列表1，目标列表2和伤害列表
function FightManager:InsertLeftOrRightRecordEvent(oneSideRecordList, actor, fighterState, otherDataItem, victory)
	local recordItem = {};
	--动作发生时间
	recordItem.time = self.time;
	--动作执行人在本方阵型中的出场顺序
	recordItem.teamIndex = actor:GetTeamIndex();
	
	if nil ~= victory then
		recordItem.victory = victory;
		table.insert(oneSideRecordList, recordItem);
		return;
	end
	
	--动作发生地点
	recordItem.xPosition = actor:GetPosition().x;
	recordItem.yPosition = actor:GetPosition().y;
	--动作类型
	recordItem.fighterState = fighterState;
	--解析otherDataItem
	if (FighterState.normalAttack == fighterState) then
		--插入被攻击目标在其队伍中的入场顺序	
		recordItem.attackTargeterTeamIndexList = otherDataItem.targeterTeamIndexList1;
		--插入被攻击目标受到的伤害值（减免前）
		recordItem.attackDataList = otherDataItem.attackDataList;
	elseif (FighterState.skillAttack == fighterState) then
		if nil ~= otherDataItem.targeterTeamIndexList1 then
			--技能伤害部分
			--插入被攻击目标在其队伍中的入场顺序	
			recordItem.attackTargeterTeamIndexList = otherDataItem.targeterTeamIndexList1;
			--插入被攻击目标受到的伤害值（减免前）
			recordItem.attackDataList = otherDataItem.attackDataList;
		else
			--技能buff部分
			--被加buff目标在其队伍中的入场顺序
			recordItem.buffTargeterTeamIndexList = otherDataItem.targeterTeamIndexList2;
		end	
	end	
	
    ----print(debug.traceback())	
	table.insert(oneSideRecordList, recordItem);
end

--========================================================================

--进入场景
function FightManager:enterScene( actor, index ,isLeft )
	local pos;
	local dir;
	if isLeft then
		pos = Vector3(self.leftPos.x, self.yOrderList[index], 0);
		dir = DirectionType.faceright;
	else
		pos = Vector3(self.rightPos.x, self.yOrderList[index], 0);
		dir = DirectionType.faceleft;
	end		
	actor:SetDirection(dir);	
	actor:SetPosition(pos);	

	--调整角色的宽度，使其在X轴方向错落排列
	actor:AddWidth(self.xPositionIndentation[2*index - 1]);	
	table.insert(self.actorList, actor);
end

--加载提前入场的怪物
function FightManager:enterSceneBeforBattle(actor, xPosition, index)
	local pos = Vector3(xPosition, self.yOrderList[index], 0);
	local dir = DirectionType.faceleft;
	actor:SetDirection(dir);	
	actor:SetPosition(pos);		
	--调整角色的宽度，使其在X轴方向错落排列
	actor:AddWidth(self.xPositionIndentation[2*index - 1]);	
	table.insert(self.actorList, actor);
end

--加载入场角色和怪物
function FightManager:loadFighter(elapse)
	--间隔n秒进入一个人物
	if self.time - self.lastPlayerEnterTime > self.enterSpacingTime then
		self.lastPlayerEnterTime = self.time;		
		--人物进入场景	
		if #(self.needleftActorList) ~= 0 then
			--记录本方已入场人数
			self.count = self.count + 1;
			--设置角色在本方阵列的出场顺序
			self.needleftActorList[1]:SetTeamIndex(self.count);
			--设置角色不为敌方
			self.needleftActorList[1]:SetIsEnemy(false);

			--计算角色入场时在上中下三条线的位置
			local index = math.mod(self.count, 3) + 1;				
			--人物进入场景
			FightManager:enterScene( self.needleftActorList[1], index, true );

			table.insert(self.leftActorList, self.needleftActorList[1]);
			table.remove(self.needleftActorList, 1);			
		end	
		
		if self.isPvP then
			--人物进入场景
			if #(self.needrightActorList) ~= 0 then
				--记录敌方已入场人数
				self.enemyCount = self.enemyCount + 1;
				--设置角色在本方阵列的出场顺序
				self.needrightActorList[1]:SetTeamIndex(self.enemyCount);
				--设置角色为敌方
				self.needrightActorList[1]:SetIsEnemy(true);	
				--计算角色入场时在上中下三条线的位置
				local index = math.mod(#(self.rightActorList), 3) + 1;
				--人物进入场景
				FightManager:enterScene( self.needrightActorList[1], index, false );				
				table.insert(self.rightActorList, self.needrightActorList[1]);
				table.remove(self.needrightActorList, 1);
			end	
		end
		
	end
	
	if self.isPvP == false then
		--怪物入场
		self:loadMonster(elapse);
	end
	
	--随机X轴位移
	if math.mod((#(self.leftActorList) + #(self.rightActorList)),6) == 0 then
		self.xPositionIndentation = self:getXpositionIndentation();	--角色在战斗场景中X轴方向的位移差
	end
	
	
end	

--加载提前入场的怪物
function FightManager:loadIdleMonster()	
	if 0 == #(self.idleMonsterList) then	
		return;
	end
	
	--加载提前入场的怪物
	for _,monsterItem in ipairs(self.idleMonsterList) do
		--记录敌方已入场人数
		self.enemyCount = self.enemyCount + 1;
		--设置角色在本方阵列的出场顺序
		monsterItem.monster:SetTeamIndex(self.enemyCount);

		FightManager:enterSceneBeforBattle( monsterItem.monster, monsterItem.xPos, monsterItem.index );		
		--插入怪物列表
		table.insert(self.rightActorList, monsterItem.monster);	
	end
	
	--战斗场景中待机怪唔触发觉醒的警戒线
	local pos = self.idleMonsterList[1].monster:GetPosition();
	self.alertLineXposition = pos.x - Configuration.AlertDistance;

end

--怪物入场
function FightManager:loadMonster(elapse)
	while true do	
		if 0 ~= #(self.needrightActorList) then
			
			local length = #(self.needrightActorList);												--剩余未进场怪物个数
			if (ActorType.boss == self.needrightActorList[length].monster:GetActorType()) and (self.time > self.needrightActorList[length].time) then
				local monster = self.needrightActorList[length].monster;	
				self.enemyCount = self.enemyCount + 1;												--记录敌方已入场人数
				monster:SetTeamIndex(self.enemyCount);												--设置角色在本方阵列的出场顺序	
				FightManager:enterScene( monster, 2, false );									--角色进入场景
				table.insert(self.rightActorList, monster);										--插入怪物列表				
				table.remove(self.needrightActorList, length);									--将第一波怪从怪物总表中删除
			end
			
			--怪物入场时间
			if nil ~= self.needrightActorList[1] then
				if self.time > self.needrightActorList[1].time then
					local monster = self.needrightActorList[1].monster;	
					self.enemyCount = self.enemyCount + 1;												--记录敌方已入场人数
					monster:SetTeamIndex(self.enemyCount);												--设置角色在本方阵列的出场顺序				
					FightManager:enterScene( monster, self.needrightActorList[1].index, false );	--小怪入场	
					table.insert(self.rightActorList, monster);										--插入怪物列表				
					table.remove(self.needrightActorList, 1);											--将第一波怪从怪物总表中删除	
				else
					break;
				end
			end
			
			
		else
			break;
		end
	end
	
end

--更新战斗者
function FightManager:updateActor( srcActorList, targetActorList, elapse, effectScriptList )


	local i = 1;
	while true do	
		local fightActor = srcActorList[i];
		if fightActor == nil then
			break;
		end			
		
		if fightActor:GetFightstate() == FighterState.death then
			
			--插入录像列表
			if (FightState.recordState ~= self.state) then
				FightManager:InsertRecordEvent(fightActor, FighterState.death, nil, nil);
			end

			--死亡
			table.insert(self.deathActorList, fightActor);
			table.remove(srcActorList, i);

		else
			
			if (fightActor:GetFightstate() == FighterState.idle) or (fightActor:GetFightstate() == FighterState.moving) or (fightActor:GetSkillClickedFlag()) then
				--待机或者移动状态（暂时只写攻击最近距离的人）
				self:attackNearestFighter(fightActor, srcActorList, targetActorList, elapse, effectScriptList);
			end

			i = i + 1;
		end
	end
end

--攻击最近距离的角色
function FightManager:attackNearestFighter( attacker, srcActorList, targetActorList, elapse, effectScriptList )
	
	if self.isOver then
		--非录像模式
		if (FightState.recordState ~= self.state) then
			self:InsertRecordEvent(attacker, FighterState.idle, nil, nil);
		end	
		return;
	end
	
	local flag = attacker:GetSkillClickedFlag();		--是否手动释放技能

	if (attacker:GetFightstate() ~= FighterState.normalAttack) and (attacker:GetFightstate() ~= FighterState.skillAttack) and (not flag) then
		--正常进入该函数，不是按了技能按钮之后进入的
		if (attacker:IsOwnSkill()) and (self.isAuto or (attacker:IsEnemy())) and attacker:GetAnger() >= Configuration.MaxAnger then
			
			if attacker:isSkillType2() then	
				--技能效果2（buff技能），如果存在buff技能，则以buff为主，伤害为辅
				if 4 ~= attacker:GetSkillTargeter2() then
					local targeterList = self:findSkillBuffTargeter(attacker, srcActorList);
					if 0 ~= #(targeterList) then
						--给友方加buff
						attacker:ReleaseSkillBuff(targeterList, FighterState.skillAttack);	
						
						--如果buff技能附带伤害
						if attacker:isSkillType1() then
							local targeterList = self:findSkillAttackTargeter(attacker, targetActorList);
							if 0 ~= #(targeterList) then
								--进行技能攻击
								attacker:AttackBegin(targeterList, FighterState.skillAttack, effectScriptList);	
							end
						end
						
					else
						--怒气值已满，但是buff技能没有释放目标，则其执行动作待定						
					end	
				end	

			else	
				--技能效果1	
				local targeterList = self:findSkillAttackTargeter(attacker, targetActorList);
				if 0 ~= #(targeterList) then
					--进行技能攻击
					attacker:AttackBegin(targeterList, FighterState.skillAttack, effectScriptList);	
				else
					--向目标移动
					self:moveToTargeter(attacker, elapse);
				end
			end
			
		else
			--寻找在普通攻击范围内距离攻击者最近的敌方目标
			local targeterList = self:findNearestTargeterByNormalAttack(attacker, targetActorList);
			if nil ~= targeterList then
				--进行普通攻击
				attacker:AttackBegin(targeterList, FighterState.normalAttack, effectScriptList);
			else
				if attacker:IsIdleMonster() then
					--怪物待机,如果没有目标，则呆在原地不动
					return;
				else
					--向目标移动
					self:moveToTargeter(attacker, elapse);
				end
			end
		end	
		
	else
		--按技能按钮之后进入该函数
		if (false == self.isAuto) and (attacker:IsOwnSkill()) and (attacker:GetAnger() >= Configuration.MaxAnger) then
			--手动进行技能攻击	
			if attacker:isSkillType2() then	
				--技能效果2（buff技能），如果存在buff技能，则以buff为主，伤害为辅
				if 4 ~= attacker:GetSkillTargeter2() then
					local targeterList = self:findSkillBuffTargeter(attacker, srcActorList);
					if 0 ~= #(targeterList) then
						--给友方加buff
						attacker:ReleaseSkillBuff(targeterList, FighterState.skillAttack);	
						--将手动技能释放标志位重置为false
						attacker:SetSkillClickedFlag(false);
						
						--如果buff技能附带伤害
						if attacker:isSkillType1() then
							local targeterList = self:findSkillAttackTargeter(attacker, targetActorList);
							if 0 ~= #(targeterList) then
								--进行技能攻击
								attacker:AttackBegin(targeterList, FighterState.skillAttack, effectScriptList);	
							end
						end
						
					else
						--怒气值已满，但是buff技能没有释放目标，则其执行动作待定						
					end	
				end	

			else	
				--技能效果1		
				local targeterList = self:findSkillAttackTargeter(attacker, targetActorList);
				if 0 ~= #(targeterList) then
					--进行技能攻击
					attacker:AttackBegin(targeterList, FighterState.skillAttack, effectScriptList);	
					--将手动技能释放标志位重置为false
					attacker:SetSkillClickedFlag(false);
				else
					--向目标移动
					self:moveToTargeter(attacker, elapse);
				end
			end
			
		else
			--将手动技能释放标志位重置为false
			attacker:SetSkillClickedFlag(false);
		end
	end	

end

--向目标移动
function FightManager:moveToTargeter(attacker, elapse)
	if self:isArriveTerminal(attacker) == false then
		--战斗未结束，如果角色未到达地方出生地点，则继续向前移动
		attacker:MoveToTarget(elapse);
	end	
end


--寻找技能攻击目标
function FightManager:findSkillAttackTargeter(attacker, targetActorList)
	local targeter = nil;
	if 1 == attacker:GetSkillTargeterType1() then
		--最近的目标,findNearestTargeter返回的是包含targeter的table
		targeter = self:findNearestTargeter(attacker, targetActorList, attacker:GetSkillAttackRange(), false, 1);
		targeter = targeter[1];
	elseif 2 == attacker:GetSkillTargeterType1() then
		--随机目标，findRandomTargeter返回的是包含targeter的table
		targeter = self:findRandomTargeter(attacker, targetActorList, attacker:GetSkillAttackRange(), false, 1);
		targeter = targeter[1];
	else
		--最远目标
		targeter = self:findFarthestTargeter(attacker, targetActorList, attacker:GetSkillAttackRange(), false, 1);
		targeter = targeter[1];
	end
	
	if nil == targeter then
		--如果目标为空
		return {};
	elseif attacker:GetSkillSpreadArea1() == 0 then
		--扩散范围=0，单体伤害
		return {targeter};
	else
		local targeterList = {};
		--扩散范围>0，AOE伤害
		if attacker:GetSkillSpreadType1() == 1 then
			--向最近目标扩散
			targeterList = self:findNearestTargeter(targeter, targetActorList, attacker:GetSkillSpreadArea1(), true, attacker:GetSkillSpreadCount1());
		elseif attacker:GetSkillSpreadType1() == 2 then
			--向随机目标扩散
			targeterList = self:findRandomTargeter(targeter, targetActorList, attacker:GetSkillSpreadArea1(), true, attacker:GetSkillSpreadCount1());
		else
			--向全体目标扩散
			targeterList = self:findNearestTargeter(targeter, targetActorList, attacker:GetSkillSpreadArea1(), true, 0);
		end	
		--实际命中目标为总目标列表的最后一个
		table.insert(targeterList, targeter);
		
		return targeterList;
	end	
end

--寻找技能buff的目标
function FightManager:findSkillBuffTargeter(actor, srcActorList)
	local targeterList = {};
	if 0 == actor:GetSkillSpreadType2() then
		--自己
		targeterList = {actor};	
	elseif 1 == actor:GetSkillSpreadType2() then
		--最近的目标
		targeterList = self:findNearestTargeter(actor, targetActorList, actor:GetSkillSpreadArea2(), true, attacker:GetSkillSpreadCount2());	
	elseif 2 == actor:GetSkillSpreadType2() then
		--随机目标
		targeterList = self:findRandomTargeter(actor, targetActorList, actor:GetSkillSpreadArea2(), true, attacker:GetSkillSpreadCount2());
	elseif 3 == actor:GetSkillSpreadType2() then
		--全体的目标
		targeterList = srcActorList;
	else
		targeterList = {};
	end
	
	return targeterList;
end


--寻找攻击距离内距离最近的敌方目标(普通攻击)
function FightManager:findNearestTargeterByNormalAttack(attacker, targetActorList)
	local targeterList = self:getAliveTargeterArroundActor(attacker, targetActorList, attacker:GetNormalAttackRange(), false);
	if 0 ~= #targeterList then
		return {targeterList[1]};
	else
		return nil;
	end	
end


--寻找攻击距离内距离最近的敌方目标
function FightManager:findNearestTargeter(actor, targetActorList, distance, sortByRoot, count)
	local targeterList = self:getAliveTargeterArroundActor(actor, targetActorList, distance, sortByRoot);
	local actorList = {};
	if 0 ~= #targeterList then
		if (count >= #targeterList) or (0 == count) then
			--技能攻击的最大敌人数大于等于可被攻击角色数 或者 count=0为全体目标时
			return targeterList;
		else
			--技能攻击的最大敌人数小于可被攻击角色数
			local i = 1;
			while (i <= count) do	
				table.insert(actorList, targeterList[i]);
				i = i + 1;	
			end
			return actorList;
		end	
	else
		--返回空链表
		return actorList;
	end	
end


--寻找攻击距离内距离最远的敌方目标
function FightManager:findFarthestTargeter(actor, targetActorList, distance, sortByRoot, count)
	local targeterList = self:getAliveTargeterArroundActor(actor, targetActorList, distance, sortByRoot);
	local actorList = {};
	if 0 ~= #targeterList then
		if (count >= #targeterList) or (0 == count) then
			--技能攻击的最大敌人数大于等于可被攻击角色数 或者 count=0为全体目标时
			return targeterList;
		else
			--技能攻击的最大敌人数小于可被攻击角色数
			local i = 0;
			while (i < count) do	
				table.insert(actorList, targeterList[#targeterList - i]);
				i = i + 1;	
			end
			return actorList;
		end	
	else
		--返回空链表
		return actorList;
	end	
end	


--寻找攻击距离内随机的敌方单位
function FightManager:findRandomTargeter(actor, targetActorList, distance, sortByRoot, count)
	local targeterList = self:getAliveTargeterArroundActor(actor, targetActorList, distance, sortByRoot);
	local actorList = {};
	if 0 ~= #targeterList then
		if (count >= #targeterList) or (0 == count) then
			--技能攻击的最大敌人数大于等于可被攻击角色数 或者 count=0为全体目标时
			return targeterList;
		else
			--技能攻击的最大敌人数小于可被攻击角色数
			local i = 0;
			while (i < count) do
				local index = math.floor(math.random(1, #targeterList - i));
				table.insert(actorList, targeterList[index]);
				table.remove(targeterList, index);
				i = i + 1;
			end
			return actorList;
		end	
	else
		--返回空链表
		return actorList;
	end	
	
end


--获取距离某个角色一定距离内的全部未死亡的目标,并按距离远近排序
--sortByRoot为是否根据角色的root点来判断范围（在计算范围伤害时为true，在寻找攻击目标时为false）
function FightManager:getAliveTargeterArroundActor(actor, targetActorList, distance, sortByRoot)
	local targeterList = {};	
	local i = 1;
	--寻找一定距离内的全部未死亡的目标
	while true do
		local targetActor = targetActorList[i];
		if targetActor == nil then
			break;
		end

		if targetActor:GetFightstate() ~= FighterState.death then
			--选择最远的人
			local curPos = actor:GetPosition().x;
			local targetPos = targetActor:GetPosition().x;
			local disLength = targetPos - curPos;
			
			if sortByRoot then
				disLength = math.abs(disLength)
			else
				disLength = math.abs(disLength) - targetActor:GetWidth() / 2 - actor:GetWidth() / 2;
			end
			--距离满足条件而且不是同一个角色
			if (disLength < distance) and (actor ~= targetActor) then
				table.insert(targeterList, targetActor);
			end
		end
		--不管目标是否死亡，i都要加1，防止死循环出现
		i = i + 1;
	end	
	--排序
	if 0 ~= #targeterList then
		GlobalData.sortActor = actor;
		GlobalData.isSortByRoot = sortByRoot;
		table.sort(targeterList, sortByMinDistance);
	end
	
	return targeterList;
end

--排序
function sortByMinDistance(tar1, tar2)
	local curPos = GlobalData.sortActor:GetPosition().x;
	local tarPos1 = tar1:GetPosition().x;
	local tarPos2 = tar2:GetPosition().x;
	local disLength1 = nil;
	local disLength2 = nil;
	if GlobalData.isSortByRoot then
		disLength1 = math.abs(tarPos1 - curPos);
		disLength2 = math.abs(tarPos2 - curPos);
	else
		--敌我双方的攻击距离
		disLength1 = math.abs(tarPos1 - curPos) - tar1:GetWidth() / 2 - GlobalData.sortActor:GetWidth() / 2;
		disLength2 = math.abs(tarPos2 - curPos) - tar2:GetWidth() / 2 - GlobalData.sortActor:GetWidth() / 2;
	end
	
	return (disLength1 < disLength2);
end

--设置待机怪物中第一个觉醒怪觉醒的时间
function FightManager:SetFirstIdleMonsterWakeUpTime(isTouchTheAlertLine)
	if nil == self.firstIdleMonsterWakeUpTime then
		self.firstIdleMonsterWakeUpTime = self.time;
		if isTouchTheAlertLine then
			self.idleMonsterList[1].monster:SetIsIdleMonster(false);
		end
		self.idleMonsterList = {};
	end
end

--获取待机怪物中第一个觉醒怪觉醒的时间
function FightManager:GetFirstIdleMonsterWakeUpTime()
	return self.firstIdleMonsterWakeUpTime;
end

--判断角色攻击范围是否到达地方出生点
function FightManager:isArriveTerminal(actor)
	--普通攻击距离和技能攻击距离较短的一个
	if not actor:IsArriveTerminal() then
		local minDis = actor:GetMinAttackRange() + actor:GetWidth()/2;	
		if actor:GetDirection() == DirectionType.faceright then
			if actor:GetPosition().x >= self.rightPos.x - minDis then
				--非录像模式
				if (FightState.recordState ~= self.state) then
					self:InsertRecordEvent(actor, FighterState.idle, nil, nil);
				end	
				return true;
			else
				return false;
			end
		else
			if actor:GetPosition().x <= self.leftPos.x + minDis then
				--非录像模式
				if (FightState.recordState ~= self.state) then
					self:InsertRecordEvent(actor, FighterState.idle, nil, nil);
				end	
				return true;
			else
				return false;
			end
		end
	else
		return true;
	end
	
end

--boss死亡后，设置所有monster角色死亡
function FightManager:SetAllMonsterDie()
	--清空未进场怪物
	self.needrightActorList = {};
	--判断boss标志
	local index = 1;
	--设置战场中为死亡角色死亡	
	while 1 < #(self.rightActorList) do
		if self.rightActorList[index]:GetActorType() ~= ActorType.boss then
			--插入录像列表
			if (FightState.recordState ~= self.state) then
				FightManager:InsertRecordEvent(self.rightActorList[index], FighterState.death, nil, nil);
			end
			
			self.rightActorList[index]:SetDie();
			table.insert(self.deathActorList, self.rightActorList[index]);
			table.remove(self.rightActorList, index);
		else
			index = 2;
		end		
	end
end	

--非骑士类的伤害公式
--攻击值，防御值，被攻击者等级
function FightManager:DamageFormula(attackData, defenceData, level)
	local damageData = attackData * (1 - defenceData/(defenceData + level*150 + 2000)) - defenceData/(15 + RoundUp(level/10));
	return RoundUp(damageData);
end

--计算暴击率(攻击方暴击值，防御方闪避值， 攻击方命中值)
function FightManager:CaculateStormsHitPercent(stormsHitData, missData, hitData)
	local percent = stormsHitData/(stormsHitData + missData - (hitData - 300)*0.88 + 2333);
	if percent < 0 then
		percent = 0;
	end
	return percent;
end

--计算闪避率(攻击方暴击值，防御方闪避值， 攻击方命中值)
function FightManager:CaculateMissPercent(stormsHitData, missData, hitData)
	local percent = (missData - (hitData - 300)*0.88)/(missData - (hitData - 300)*0.88 + stormsHitData + 2333);
	if percent < 0 then
		percent = 0;
	end
	return percent;
end

function RoundUp( number, unitsOrder )
	if number < 1 then
		number = 1;
	end	
	
	if number/1 ~= math.floor(number) then
		return math.floor(number) + 1;
	else
		return number;
	end
end
