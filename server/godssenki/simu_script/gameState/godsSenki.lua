
--========================================================================
--诸神战记类

GodsSenki =
{
};


--初始化
function GodsSenki:Init()

end

--销毁
function GodsSenki:Destroy()

end

--进入
function GodsSenki:onEnter()

end

--离开
function GodsSenki:onLeave()
end

--更新
function GodsSenki:Update( Elapse )

	FightManager:Update(Elapse);
    EffectManager:Update(Elapse);
    effectScriptManager:Update(Elapse)
end

--========================================================================
--功能函数
--========================================================================

--========================================================================
--界面响应
--========================================================================

--进入战斗
--barriersId 关卡id
function GodsSenki:onEnterFight(recordList)

	--填充战斗人员
	local leftFighterList = {};
	local rightFighterList = {};
	
	local actorOrder = resTableManager:GetValue(ResTable.actorOrder, '1', '入场顺序');	
	local actorList = cjson.decode(actorOrder);
	for _,actorId in ipairs(actorList) do
		local leftFighter = ActorManager:CreatePFighter( actorId );
		leftFighter:SetActorType(ActorType.partner);
		table.insert(leftFighterList, leftFighter);
	end	
	
--[[	leftFighter = ActorManager:CreatePFighter( 1003 );
	table.insert(leftFighterList, leftFighter);		
	leftFighter:SetActorType(ActorType.partner);--]]	
	
	local barriesId = 1005;
	rightFighterList = self:GetMonsterList(barriesId);
	
	if nil == recordList then
		--正常战斗，非录像
		--print('battle');
		FightManager:Initialize(barriesId, leftFighterList, rightFighterList);
	else
		--录像
		--print('record');
		FightManager:Initialize(barriesId, leftFighterList, rightFighterList, recordList, 1);
	end
	

end


--填充即将战斗的怪物列表
--barriersId 关卡ID
function GodsSenki:GetMonsterList(id)
	
	id = tostring(id);
	local configure = nil;				--每个小怪的配置
	local monsterList = {};			--怪物列表
	local idleMonsterList = {};		--提前入场怪物列表
	--怪物等级
	local monsterLevel = tonumber(resTableManager:GetValue(ResTable.barriers, id, '怪物等级'));
	
	--提前入场怪物配置
	local idleMonsterConfigure = resTableManager:GetValue(ResTable.barriers, id, '初始怪物配置');

	local tsss = resTableManager:GetRowValue(ResTable.barriers, id);
    --tools_t:print_r(tsss)

	local wakeUpTime = 0;
	if '[]' ~= idleMonsterConfigure then
		local monsterConfigureList = cjson.decode(idleMonsterConfigure);
		for _,monsterConfigureItem in ipairs(monsterConfigureList) do	
			local monsterId = tonumber(monsterConfigureItem[1]);
			local xPosition = tonumber(monsterConfigureItem[2]);
			local lineIndex = tonumber(monsterConfigureItem[3]);
			local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; actorType = ActorType.monster});		--创建怪物
			monster:SetIsIdleMonster(true);
			monster:SetWakeUpTime(wakeUpTime);
			wakeUpTime = wakeUpTime + math.random(Configuration.minMonsterWakeUpTime, Configuration.maxMonsterWakeUpTime);
			local idleMonsterItem = {monster = monster; xPos = xPosition; index = lineIndex};
			table.insert(idleMonsterList, idleMonsterItem);	
		end	
	end		
	
	--提前入场的boss配置
	local idleBossConfigure = resTableManager:GetValue(ResTable.barriers, id, '初始boss配置');
	if '[]' ~= idleBossConfigure then
		local monsterConfigureItem = cjson.decode(idleBossConfigure);		
		local monsterId = tonumber(monsterConfigureItem[1]);
		local xPosition = tonumber(monsterConfigureItem[2]);
		local lineIndex = tonumber(monsterConfigureItem[3]);
		local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; actorType = ActorType.boss});		--创建怪物
		monster:SetIsIdleMonster(true);
		monster:SetWakeUpTime(wakeUpTime);
		local idleMonsterItem = {monster = monster; xPos = xPosition; index = lineIndex};
		table.insert(idleMonsterList, idleMonsterItem);
	end
	
	--怪物配置
	local monsterConfigure = resTableManager:GetValue(ResTable.barriers, id, '怪物配置');
	if nil ~= monsterConfigure then
		local monsterConfigureList = cjson.decode(monsterConfigure);
		
		for _,monsterConfigureItem in ipairs(monsterConfigureList) do	
			local monsterId = tonumber(monsterConfigureItem[1]);
			local enterTime = tonumber(monsterConfigureItem[2]);
			local lineIndex = tonumber(monsterConfigureItem[3]);
			local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; actorType = ActorType.monster});		--创建怪物
			local monsterItem = {monster = monster; time = enterTime, index = lineIndex};
			table.insert(monsterList, monsterItem);
		end	
	end
	
	--boss配置
	local bossConfigure = resTableManager:GetValue(ResTable.barriers, id, 'Boss配置');
	if '[]' ~= bossConfigure then
		local monsterConfigureList = cjson.decode(bossConfigure);
		if nil ~= monsterConfigureList then	
			local enterTime = tonumber(monsterConfigureList[2]);
			local monsterId = tonumber(monsterConfigureList[1]);
			local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; actorType = ActorType.boss});		--创建怪物
			local monsterItem = {monster = monster; time = enterTime};
			table.insert(monsterList, monsterItem);
		end
		
	end

	return {monsterList,idleMonsterList};
end	


--分解怪物配置
function GodsSenki:separateConfig(monsterConfigure)
	local list = {};
	while true do
		local index = string.find(monsterConfigure, ",");
		if nil ~= index then
			local item = string.sub(monsterConfigure, 1, index - 1);
			monsterConfigure = string.sub(monsterConfigure, index + 1, -1);
			table.insert(list, item);
		else
			table.insert(list, monsterConfigure);
			break;
		end	
	end	
	return list;
end	
