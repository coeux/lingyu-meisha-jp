--NetworkMsg_UnionBattle.lua

--======================================================================
--社团战

NetworkMsg_UnionBattle= 
	{
		
	};
--报名返回
function NetworkMsg_UnionBattle:retEnlist(msg)
	UnionBattlePanel:retEnlist(msg)
end

--上阵返回
function NetworkMsg_UnionBattle:retUpTeam(msg)
	UnionBuZhenPanel:retUpTeam(msg)
end

--自己取消上阵返回
function NetworkMsg_UnionBattle:retDownteam(msg)
	UnionBuZhenPanel:retDownteam(msg)
end

--社长取消社员上阵返回
function NetworkMsg_UnionBattle:retOtherDownTeam(msg)
	UnionBuZhenPanel:retDownTeamByProp(msg)
end
--
function NetworkMsg_UnionBattle:fightStateSwitch(msg)
	UnionBuZhenPanel:fightStateSwitch(msg)
end
--实时战报推送
function NetworkMsg_UnionBattle:realTimeFightInfo(msg)
	UnionBattlePanel:realTimeFightInfo(msg)
end
--全部战报
function NetworkMsg_UnionBattle:fightRecordInfo(msg)
	UnionBattlePanel:fightRecordInfo(msg)
end
--战绩信息
function NetworkMsg_UnionBattle:battleFightInfo(msg)
	UnionBattlePanel:battleFightInfo(msg)
end
--我方某建筑信息
function NetworkMsg_UnionBattle:battleBuildingInfo(msg)
	UnionBuZhenPanel:battleBuildingInfo(msg)
end
--敌方某建筑信息
function NetworkMsg_UnionBattle:battleBuildingInfoFight(msg)
	UnionBuZhenPanel:battleBuildingInfoFight(msg)
end
--请求社团战报名状态
function NetworkMsg_UnionBattle:unionState(msg)
	UnionBattlePanel.union_state = msg.guild_state;  
	UnionBattlePanel.union_battle_state = msg.gbattle_state;
	if SceneType.Union == MainUI:GetSceneType() then
		UnionDialogPanel:onShow();
	end
	MenuPanel:UnionTip(UnionBattlePanel:isUnionBattleTip());

end
--布阵期间全局状态查看
function NetworkMsg_UnionBattle:wholeDefenceInfo(msg)
	UnionBattlePanel:wholeDefenceInfo(msg)
end
function NetworkMsg_UnionBattle:wholeDefenceInfoFight(msg)
	UnionBattlePanel:wholeDefenceInfoFight(msg)
end
--建筑升级返回
function NetworkMsg_UnionBattle:buildingLevelUp(msg)
	UnionBuZhenPanel:buildingLevelUp(msg)
end
--购买挑战次数返回
function NetworkMsg_UnionBattle:buyChallengeTimes(msg)
	UnionBattlePanel:buyChallengeTimes(msg)
end
--清除CD
function NetworkMsg_UnionBattle:clearFightCd(msg)
	UnionBattlePanel:clearFightCd(msg)
end
--侦察返回
function NetworkMsg_UnionBattle:retSleuthing(msg)
	UnionBuZhenPanel:retSleuthing(msg)
end
--社团排名
function NetworkMsg_UnionBattle:unionRank(msg)
	UnionBattlePanel:unionBattleRank(msg)
end

--发起献祭
function NetworkMsg_UnionBattle:retBeginSacrifice(msg)
	UnionBuZhenPanel:retSacrificeTeam();
end

function NetworkMsg_UnionBattle:retConfirmSacrifice(msg)
end

function NetworkMsg_UnionBattle:retCancelSacrifice(msg)
end

function NetworkMsg_UnionBattle:retAssistSacrifice(msg)
end

function NetworkMsg_UnionBattle:retChangeSacrifice(msg)
end

function NetworkMsg_UnionBattle:retNPSacrifice(msg)
end

function NetworkMsg_UnionBattle:retOffSacrifice(msg)
end

function NetworkMsg_UnionBattle:retSacrificeInfo(msg)
	UnionBuZhenPanel:sacrificeInfo(msg);
end

--敌方队伍数据
function NetworkMsg_UnionBattle:onHandleEnter(msg)
	Loading.waitMsgNum = 1;
	UnionBattleSelectActorPanel:onClose()
	Game:SwitchState(GameState.loadingState);
	UnionBattlePanel.resetTimes = UnionBattlePanel.resetTimes - 1
	local dc = cjson.decode(msg.view_data);
	UnionBattle.leaveAnger = msg.anger
	UnionBattle.anger_enemy = msg.anger_enemy
	local fill_pro = function(pro, arr)
		pro.atk 	= arr[1];
		pro.mgc 	= arr[2];
		pro.def		= arr[3];
		pro.res 	= arr[4];
		pro.hp  	= arr[5];
		pro.cri		= arr[6];
		pro.acc 	= arr[7]; 
		pro.dodge	= arr[8]; 
		pro.fp		= arr[9];
		pro.power	= arr[10]; 
		pro.ten 	= arr[11]; 
		pro.imm_dam_pro = arr[12];
		pro.move_speed = arr[13]; 
		pro.factor = {};
		table.insert(pro.factor, arr[14]);
		table.insert(pro.factor, arr[15]);
		table.insert(pro.factor, arr[16]);
		table.insert(pro.factor, arr[17]);
		table.insert(pro.factor, arr[18]);
		pro.atk_power = arr[19]; 
		pro.hit_power = arr[19]; 
		pro.kill_power = arr[19];
		pro.pd = {};
		pro.pa = {};
		for i=1, 5 do
			pro.pd[i] = arr[19+i] or 0;
			pro.pa[i] = arr[24+i] or 0;
		end
	end
	local fill_skls = function(skls, arr)
		for _, a in pairs(arr) do
			local skl = {};
			skl.skid = a[1];
			skl.resid = a[2];
			skl.level = a[3];
			table.insert(skls, skl);
		end
	end
	local fill_lvl = function(lvl, arr)
		lvl.level = arr[1];
		lvl.lovelevel = arr[2];
	end

	local tmp = {};
	for _, role in pairs(dc.roles) do
		role.equips = nil;
		tmp[role.pid] = role.resid;
		local pro = role.pro; role.pro = {};
		fill_pro(role.pro, pro);
		local skls = role.skls; role.skls = {};
		fill_skls(role.skls, skls);
		local lvl = role.lvl; role.lvl = {};
		fill_lvl(role.lvl, lvl);
	end
	UnionBattle.enemyTeamList = {};
	UnionBattle.enemyTeamMap = {};
	UnionBattle.enemyTeamMap = msg.enemy_team
	for _, actor in pairs(msg.enemy_team) do
		if actor.pid ~= -1 then
		table.insert(UnionBattle.enemyTeamList, {
			pid = actor.pid, resid = tmp[actor.pid], hp = actor.hp
		})
		end
	end
	tmp = nil;
	ComboPro:InitEnemyData(dc.combo_pro);
	Rune:InitEnemyAttribute(dc.roles);
	--[[
	UnionBattle.enemyTeamList = {};
	table.insert(UnionBattle.enemyTeamList,msg.hp1)
	table.insert(UnionBattle.enemyTeamList,msg.hp2)
	table.insert(UnionBattle.enemyTeamList,msg.hp3)
	table.insert(UnionBattle.enemyTeamList,msg.hp4)
	table.insert(UnionBattle.enemyTeamList,msg.hp5)
	print('ret-enemHP1->'..tostring(msg.hp1)..' -enemHP2->'..tostring(msg.hp2)..' -enemHP3->'..tostring(msg.hp3)..' -enemHP4->'..tostring(msg.hp4)..' -enemHP5->'..tostring(msg.hp5))
	for i = 1 , 5 do
		print('enemyHP-'..i..'->'..tostring(UnionBattle.enemyTeamList[i]))
	end
	]]
	NetworkMsg_Fight:onEnterFight(dc,FightType.unionBattle)
end



