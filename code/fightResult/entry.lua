function GenerateFightResult(fType, fightData)
	GlobalData.RightTotalDamage = 0;
	
	local str = '';
	fightData = cjson.decode(fightData);

	--根据鼓舞值调整角色属性
	AdjustPropertyByInspire(fightData.allyData, fightData.inspire);
    AdjustPropertyByInspire(fightData.enemyData, fightData.enemyInspire);
	--记录当前双方的血量系数
	GlobalData.AllyPlayerHpRatio = fightData.allyHpRatio;
	GlobalData.EnemyPlayerHpRatio = fightData.enemyHpRatio;

	if fType == BackstageType.pvp then
		if fightData.is_win then
			str = procPVP(fightData.allyData, fightData.enemyData, 1);
		else
			str = procPVP(fightData.allyData, fightData.enemyData, 2);
		end
		
	elseif fType == BackstageType.boss then
		str = procBossFight(fightData.allyData, fightData.bossData, fightData.is_win);	
		
	end
	
	return str;
end

function procPVP(la, ra, result)
	local index = 1;
	local tempResult = Victory.none;
	local hpList = {};
	print('server result = ' .. result)

	while ((tempResult ~= result) and (index < 30)) do
		
		local leftFighterList = {};
		local rightFighterList = {};

		for k,role in ipairs(la) do
			
			if result == Victory.left then
				if (index > 1) and (index <= 20) then
					role.pro.cri = role.pro.cri + role.pro.cri * 0.1;
					role.pro.dodge = role.pro.dodge + role.pro.dodge * 0.1;
                    role.pro.atk = role.pro.atk + role.pro.atk * 0.025;
                    role.pro.def = role.pro.def + role.pro.def * 0.04;
                    role.pro.mgc = role.pro.mgc + role.pro.mgc * 0.025;
                    role.pro.res = role.pro.res + role.pro.res * 0.04;
                    role.pro.hp = role.pro.hp + role.pro.hp * 0.04;
                end
            else
                if (index > 1) and (index <= 20) then
                    role.pro.def = role.pro.def - role.pro.def * 0.07;
                    role.pro.res = role.pro.res - role.pro.res * 0.07;
                    role.pro.cri = role.pro.cri - role.pro.cri * 0.04;
                    role.pro.dodge = role.pro.dodge - role.pro.dodge * 0.04;
                end
			end
			
			local leftFighter;
			if  0 == role.pid then	
				leftFighter = ActorManager:CreatePFighter(role.resid);
				leftFighter:InitFightData(role);
				leftFighter:SetActorType(ActorType.hero);
				table.insert(leftFighterList, leftFighter);
			elseif role.pid > 0 then
				leftFighter = ActorManager:CreatePFighter(role.resid);
				leftFighter:InitFightData(role);
				leftFighter:SetActorType(ActorType.partner);
				table.insert(leftFighterList, leftFighter);
			end
		end

		for k,role in ipairs(ra) do
			if type(role) == 'table' then
				if result == Victory.right then
					if (index > 1) and (index <= 20) then
						role.pro.cri = role.pro.cri + role.pro.cri * 0.1;
						role.pro.dodge = role.pro.dodge + role.pro.dodge * 0.1;
                        role.pro.atk = role.pro.atk + role.pro.atk * 0.025;
                        role.pro.def = role.pro.def + role.pro.def * 0.04;
                        role.pro.mgc = role.pro.mgc + role.pro.mgc * 0.025;
                        role.pro.res = role.pro.res + role.pro.res * 0.04;
                        role.pro.hp = role.pro.hp + role.pro.hp * 0.04;
                    end
                else
                    if (index > 1) and (index <= 20) then
                        role.pro.def = role.pro.def - role.pro.def * 0.07;
                        role.pro.res = role.pro.res - role.pro.res * 0.07;
                        role.pro.cri = role.pro.cri - role.pro.cri * 0.04;
                        role.pro.dodge = role.pro.dodge - role.pro.dodge * 0.04;
                    end
				end
				
				local rightFighter;
                rightFighter = ActorManager:CreatePFighter(role.resid);
                rightFighter:SetIsEnemy(true);							--设置角色为敌方
                rightFighter:InitFightData(role);
                table.insert(rightFighterList, rightFighter);
				if 0 == role.pid then
					rightFighter:SetActorType(ActorType.hero);
				elseif role.pid > 0 then
					rightFighter:SetActorType(ActorType.partner);
				end
			end	
		end	
		
		--保存血量
		hpList = {};
		hpList.allyHpList = {};
		for _,role in ipairs(la) do
			table.insert(hpList.allyHpList, {maxHp = role.pro.hp, curHp = role.pro.currentHp});
		end
		
		hpList.enemyHpList = {};
		for k,role in ipairs(ra) do
			if type(role) == 'table' then
				table.insert(hpList.enemyHpList, {maxHp = role.pro.hp, curHp = role.pro.currentHp});
			end
		end
		
		FightManager:Initialize( FightType.arena, leftFighterList, rightFighterList, false)
		while(not FightManager.isOver) do
			GodsSenki:Update( 0.03 );
		end	
		GodsSenki:Update( 0.03 );					--再更新一次，避免角色最后的待机事件未被保存到录像列表
		ActorManager:DestroyAllActor();				--删除所有角色,防止下次update时会有垃圾数据
		effectScriptManager:Destroy();				--防止有垃圾脚本未清空
		EffectManager:Destroy();
		
		index = index + 1;
		tempResult = FightManager.result;			--战斗结果	
		print('client result = ' .. tempResult)
	end

	local resultData = {};
	if index >= 30 then
		--没有计算出结果，强制结束
		resultData.unNormalFinish = true;
	else
		resultData.unNormalFinish = false;
		resultData.hpList = hpList;
		resultData.AllyPlayerHpRatio = FightManager:GetAllyLeftHpRatio();
	end
	fightResultManager:SetFightResultData(cjson.encode(resultData));

	return FightRecordManager:EncodeRecordEventList();
end

--后台计算boss战斗
function procBossFight(la, ra, result)
	local index = 0;
	local tempResult = Victory.none;
    local hpList = {};
	print('server result = ' .. result)
	
	while tempResult ~= result do	
		local leftFighterList = {};
		local rightFighterList = {};
		
		for k,role in ipairs(la) do
			local leftFighter;
			if 0 == role.pid then	
				leftFighter = ActorManager:CreatePFighter(role.resid);
				leftFighter:InitFightData(role);
				leftFighter:SetActorType(ActorType.hero);
				table.insert(leftFighterList, leftFighter);
			elseif role.pid > 0 then
				leftFighter = ActorManager:CreatePFighter(role.resid);
				leftFighter:InitFightData(role);
				leftFighter:SetActorType(ActorType.partner);
				table.insert(leftFighterList, leftFighter);
			end
		end

		if (result == Victory.left) and (index >= 1) then
			--我方胜利时，减少boss血量
			ra.pro.hp = ra.pro.hp * 0.8;			

		elseif (result == Victory.right) and (index >= 1) then
			--敌方胜利是，增加boss血量
			ra.pro.hp = ra.pro.hp * 1.2;
			
		end

		--世界boss
		local monsterId = ra.resid;
		local xPosition = Configuration.BossInitXPosition;
		local lineIndex = 2;
		local monster = ActorManager:CreateBFigher(monsterId, {level = ra.lvl.level; roundType = MonsterRoundType.worldBoss});
		monster:InitFightData(ra);
		monster:SetKeepIdle();
		local idleMonsterItem = {monster = monster; xPos = xPosition; index = lineIndex};
		table.insert(rightFighterList, idleMonsterItem);
		
		FightManager:Initialize( FightType.worldBoss, leftFighterList, rightFighterList, false)
		while(not FightManager.isOver) do		
			GodsSenki:Update( 0.03 );
		end	
		GodsSenki:Update( 0.03 );					--再更新一次，避免角色最后的待机事件未被保存到录像列表
		ActorManager:DestroyAllActor();				--删除所有角色,防止下次update时会有垃圾数据
		effectScriptManager:Destroy();				--防止有垃圾脚本未清空
		EffectManager:Destroy();

        --保存血量
        hpList = {};
        hpList.allyHpList = {};
        for _,role in ipairs(la) do
            table.insert(hpList.allyHpList, {maxHp = role.pro.hp, curHp = role.pro.currentHp});
        end

		index = index + 1;
		tempResult = FightManager.result;			--战斗结果	
		print('client result = ' .. tempResult)
		
	end
	
	local resultData = {};
	resultData.RightTotalDamage = GlobalData.RightTotalDamage;
	resultData.AllyPlayerHpRatio = FightManager:GetAllyLeftHpRatio();
    resultData.hpList = hpList;
	fightResultManager:SetFightResultData(cjson.encode(resultData));
	
	return FightRecordManager:EncodeRecordEventList();
end	

function procPVE(leftUser, sceneID)
	local roles = cjson.decode(leftUser)

	local leftFighterList = {};
	local rightFighterList = {};

	for k,v in ipairs(roles) do
		local role = v;
		if  0 == role.pid then
			leftFighter = ActorManager:CreatePFighter(role.resid);
			leftFighter:InitData(role);
			leftFighter:SetActorType(ActorType.hero);
			table.insert(leftFighterList, leftFighter);
		elseif role.pid > 0 then
			local role = ActorManager:GetRole(role.pid);
			leftFighter = ActorManager:CreatePFighter(role.resid);
			leftFighter:InitData(role);
			leftFighter:SetActorType(ActorType.partner);
			table.insert(leftFighterList, leftFighter);
		end
	end

	local recordList = {}

	local n = 0
	FightManager:Initialize( sceneID, leftFighterList, nil, false, recordList)
	while(not FightManager.isOver) do
		n = n +1 
		GodsSenki:Update( 0.1 )
	end	

	local result = {};
	result.fightResult = FightManager.result;
	return cjson.encode(recordList)
end

--根据鼓舞值调整角色属性
function AdjustPropertyByInspire(roleDataList, inspireValue)
	if roleDataList == nil then
		return;
	end
	
	for _, role in ipairs(roleDataList) do
		if (type(role) == 'table') then
			role.pro.cri = math.floor(role.pro.cri * inspireValue);
			role.pro.dodge = math.floor(role.pro.dodge * inspireValue);
			role.pro.acc = math.floor(role.pro.acc * inspireValue);
			role.pro.atk = math.floor(role.pro.atk * inspireValue);
			role.pro.def = math.floor(role.pro.def * inspireValue);
			role.pro.mgc = math.floor(role.pro.mgc * inspireValue);
			role.pro.res = math.floor(role.pro.res * inspireValue);
			role.pro.hp = math.floor(role.pro.hp * inspireValue);
		end
	end
end