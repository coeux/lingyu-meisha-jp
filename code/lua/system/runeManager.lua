--runeManager.lua

--========================================================================
--符文怪物和操作管理类

RuneManager =
	{
		monsterList		= {};				--怪物列表	
		coordsMonsterMap = {};				--怪物坐标映射
		huntFlag = RuneHuntFlag.none;		
		
		RuneEquipNum = 8;					--装备符文最大数
		RunePackageNum = 9;					--背包符文最大数
		RuneHuntMoney = 3000;				--符文猎魔的金币数	
		InvalidPos = -1;					--人物装备或背包中没有空位置	
	}
--变量
local globalActorID	= 900;				--全局怪物ID
local CoordsCount	= 10;				--怪物坐标个数	
local CoordsOffsetX = 100;				--坐标中心点x轴偏移
local CoordsOffsetY = 50;				--坐标中心点y轴偏移
local lineMonsterMap = {};				--怪物线与怪物映射，用于猎魔网络处理先到还是怪物死亡动作先播完
local lineStatusMap	={};				--怪物线与状态映射，用于猎魔网络处理先到还是怪物死亡动作先播完


--控件		
local parentPanel = nil;

--设置怪物挂载节点
function RuneManager:setParentPanel( panel )
	parentPanel = panel;
	CoordsCount = resTableManager:GetRowNum(ResTable.rune_coordinate);
end

--更新
function RuneManager:Update( Elapse )

	--更新动画
	for k, v in pairs(self.monsterList) do
		v:Update(Elapse);
	end
	
	RuneFalldownManager:Update( Elapse );
end

--记录划动开始节点
function RuneManager:SetTouchBeganPoint( point )
	for k, v in pairs(self.monsterList) do
		v:SetTouchBeganPoint(point);
	end
end

--划动过程处理
function RuneManager:TouchMove( point )
	for k, v in pairs(self.monsterList) do
		v:TouchMove(point);
	end
end

--自动猎魔处理
function RuneManager:AutoHunt( )
	local lines = {};
	for _, monster in pairs(self.monsterList) do
		--自动猎魔操作，减血，播特效
		monster:AutoHunt();
		
		--上一步自动猎魔完，血量为0的发服务器一块结算
		if 0 == monster:GetCurLife() then
			table.insert(lines, monster:GetLine());
		end			
	end	
	if #lines > 0 then
		local msg = {};
		msg.lines = lines;
		msg.flag = RuneHuntPanel:getAutoMerge();
		Network:Send(NetworkCmdType.req_rune_huntsome, msg, true);
	end

end

--========================================================================

--分配id
function RuneManager:allocActorID()
	globalActorID = globalActorID + 1;
	if globalActorID >= 1000 then
		globalActorID = 900;
	end

	return globalActorID;
end

--创建符文猎魔中的怪物
function RuneManager:CreateMonster(monsterTypeId, line, drop, resID, hasEffect)
	local coordsId = self:GetRandomCoords();
	self.coordsMonsterMap[coordsId] = monsterTypeId;
	local monster = RuneMonster.new( self:allocActorID(), monsterTypeId, coordsId, line, drop, resID );
	self.monsterList[monster:GetID()] = monster;
	
	parentPanel:AddChild(monster.monsterPanel);
	if hasEffect then
		if 5 == monsterTypeId then
		RuneHuntPanel:createEffect(monster.monsterPanel, RuneEffectType.appearBig);
		else
			RuneHuntPanel:createEffect(monster.monsterPanel, RuneEffectType.appearSmall);
		end
	end

	return monster;
	
end

--销毁怪物
--isHunt表示是否是被猎取，是猎取要播放特效等处理
function RuneManager:DestroyMonster( id , isHunt)
	parentPanel:RemoveChild(self.monsterList[id]:GetRootPanel());
	
	--坐标释放出来
	self.coordsMonsterMap[self.monsterList[id]:GetCoordId()] = nil;
	
	if isHunt then
		RuneHuntPanel:createEffect(parentPanel, RuneEffectType.disappear, Vector2(self.monsterList[id]:GetRootPanel().Translate.x, self.monsterList[id]:GetRootPanel().Translate.y));
		local line = self.monsterList[id]:GetLine();		
		--该条线的怪物已经死亡，如果有该条线需要创建的怪则创建
		if lineStatusMap[line] == RuneDeadStatus.net then
			
			local obj = lineMonsterMap[line];			
			RuneManager:CreateMonster(obj.resid, obj.line, obj.drop, obj.coat, true);
			lineStatusMap[line] = RuneDeadStatus.initial;
		else
			lineStatusMap[line] = RuneDeadStatus.animation;
		end
	end
	
	self.monsterList[id]:Destroy();
	self.monsterList[id] = nil;
	
end

--销毁所有怪物
function RuneManager:DestroyAllMonster( )
	for k, v in pairs(self.monsterList) do
		self:DestroyMonster( k , false );
	end
	
	--映射数据清空
	lineMonsterMap = {};
	lineStatusMap = {};
end

--查找怪物
function RuneManager:GetMonster( id )
	return self.monsterList[id];
end	

--随机生成一个未被占用的坐标ID
function RuneManager:GetRandomCoords( )
	--未被分配的坐标ID
	local unLocatedCoords = {};
	for i = 1, CoordsCount do
		if self.coordsMonsterMap[i] == nil then
			table.insert(unLocatedCoords, i);
		end
	end	
	return unLocatedCoords[Math.IRangeRandom(1, #unLocatedCoords)];
end	

--获取怪物随机偏离值
function RuneManager:GetRandomOffset( )
	return Vector2(math.random(CoordsOffsetX * -1, CoordsOffsetX), math.random(CoordsOffsetY * -1, CoordsOffsetY))
end

--播放滑动轨迹特效
function RuneManager:PlayScratchTraceEffect(startPoint, endPoint)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature('Gesture_3');
	armatureUI:SetAnimation('play');
	armatureUI.Translate = Vector2((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y)/2);	
	armatureUI.ZOrder = 11;					--在sharder前面
	parentPanel:AddChild(armatureUI);
	
	local angle = Math.ATan((endPoint.y - startPoint.y) / (endPoint.x - startPoint.x));
	if endPoint.x < startPoint.x then
		angle = angle + 3.141592653;
	end
	armatureUI:SetRotation(angle);		--旋转
end

--背包9个表示符文已满
function RuneManager:IsPackageFull()
	local runesMap = ActorManager.user_data.role.runesMap;
	local num = 0;
	--8~16表示符文背包
	for index = 8, 16 do
		if runesMap[index] ~= nil then
			num = num + 1;
		end
	end
	if self.RunePackageNum == num then
		return true;
	else
		return false;
	end
end

--背包中是否有高级符文
function RuneManager:hasHighRune()
	local runesMap = ActorManager.user_data.role.runesMap;
	local rune;
	--8~16表示符文背包
	for index = 8, 16 do
		rune = runesMap[index];
		if nil ~= rune then
			local color = resTableManager:GetValue(ResTable.rune, tostring(rune.resid), 'quality');
			--紫色和金色显示特效
			if 4 == color or 5 == color then
				return true;
			end
		end
	end
	return false;
end

--==============================================================
--符文网络请求

function RuneManager:onRequestHuntOne(line)
	
	local msg = {};
	local lines = {};
	table.insert(lines, line);
	msg.lines = lines;
	msg.flag = RuneHuntPanel:getAutoMerge();
	Network:Send(NetworkCmdType.req_rune_huntsome, msg, true);
	
end

--==============================================================
--网络消息处理

--游戏启动时保存一份符文映射数据，便于后面操作
function RuneManager:AdjustRuneData()
	
	local count = 1 + #ActorManager.user_data.partners;
	for index = 1, count do
		local role = {};
		if 1 == index then
			role = ActorManager.user_data.role;
		else
			role = ActorManager.user_data.partners[index - 1];
		end

		self:AdjustRoleRuneData( role );
	end
	
	--if RunePanel:Visible() then
	--	RunePanel:refreshRuneInfo();
	--end
end

function RuneManager:AdjustRoleRuneData( role )
	--装备上Pos值0~7，背包上Pos值8~16
	local runesMap = {};
	if nil ~= role.runes then
		for k, rune in ipairs (role.runes) do
			if nil ~= rune then
				runesMap[rune.pos] = rune;
			end
		end
	end
	role.runesMap = runesMap;
end

--猎一个魔
function RuneManager:onHuntSome(msg)
	--界面关闭时，不处理
	if not RuneHuntPanel:Visible() then
		return;
	end
	for _,monster in ipairs(msg.monsters) do
		RuneFalldownManager:lineSuccess( monster.line );
		if 0 ~= monster.resid then
			--该条线的怪物已经死亡，直接创建新的怪
			if lineStatusMap[monster.line] == RuneDeadStatus.animation then		
				RuneManager:CreateMonster(monster.resid, monster.line, monster.drop, monster.coat, true);
				lineStatusMap[monster.line] = RuneDeadStatus.initial;
			else
				--该条线的怪没有死亡，先保存数据，等死亡时创建
				local obj = {};
				obj.resid = monster.resid;
				obj.line = monster.line;
				obj.drop = monster.drop;
				obj.coat = monster.coat;
				lineMonsterMap[monster.line] = obj;
				lineStatusMap[monster.line] = RuneDeadStatus.net;
			end
		end	
	end
	
	if msg.flag ~= 0 then
		RuneHuntPanel:SetErrorFlag(msg.flag);
	end
	
end

--符文增删，包括背包和人物
function RuneManager:onRuneChange(msg)
	if nil ~= msg.pid then
		
		--背包角色，就是主角
		local pkgRole = ActorManager.user_data.role;

		local role = ActorManager:GetRole(msg.pid);
		if nil ~= msg.dels then
			for i, id in ipairs (msg.dels) do
				--id小于8是人物装备符文，8以上是背包符文
				if id < self.RuneEquipNum then
					role.runesMap[id] = nil;
				else
					pkgRole.runesMap[id] = nil;
				end
			end
		end
		if nil ~= msg.adds then
			for _, rune in ipairs (msg.adds) do
				if rune.pos < self.RuneEquipNum then
					role.runesMap[rune.pos] = rune;
				else
					pkgRole.runesMap[rune.pos] = rune;
				end
			end
		end
		RunePanel:refreshRuneInfo();
	end
	
end

--召唤魔王
function RuneManager:onCallBoss( monster )
	if nil ~= monster and  0 ~= monster.resid then
		--该条线的怪物已经死亡，或该条线没有怪，则直接创建新的怪
		if lineStatusMap[monster.line] == RuneDeadStatus.animation or lineStatusMap[monster.line] == nil then
			RuneManager:CreateMonster(monster.resid, monster.line, monster.drop, monster.coat, true);			
			lineStatusMap[monster.line] = RuneDeadStatus.initial;
		else
			--该条线的怪没有死亡，先保存数据，等死亡时创建
			local obj = {};
			obj.resid = monster.resid;
			obj.line = monster.line;
			obj.drop = monster.drop;
			obj.coat = monster.coat;
			lineMonsterMap[monster.line] = obj;
			lineStatusMap[monster.line] = RuneDeadStatus.net;
		end
	end
end

