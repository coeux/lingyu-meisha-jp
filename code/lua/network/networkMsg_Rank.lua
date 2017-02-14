--NetworkMsg_Rank.lua
--======================================================================
NetworkMsg_Rank = 
{
};

function NetworkMsg_Rank:RankInfo(msg)
	
	RankSelectActorPanel:onShow(msg)
end

function NetworkMsg_Rank:onHandleEnter(msg)
	if not RankSelectActorPanel.reqState then
		return
	end
	RankSelectActorPanel:pipeiCancelHide()
	Loading.waitMsgNum = 1
	Game:SwitchState(GameState.loadingState);
	local dc = cjson.decode(msg.view_data);
	local dc_self = cjson.decode(msg.view_data_self);
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
	tmp = {};
	for _, role in pairs(dc_self.roles) do
		role.equips = nil;
		tmp[role.pid] = role.resid;
		local pro = role.pro; role.pro = {};
		fill_pro(role.pro, pro);
		local skls = role.skls; role.skls = {};
		fill_skls(role.skls, skls);
		local lvl = role.lvl; role.lvl = {};
		fill_lvl(role.lvl, lvl);
	end
	Rank:setSelfData(dc_self);
	tmp = nil;
	ComboPro:InitEnemyData(dc.combo_pro);
	Rune:InitEnemyAttribute(dc.roles);
	NetworkMsg_Fight:onEnterFight(dc,FightType.rank)
	--告诉服务器开始排位赛战斗
	Network:Send(NetworkCmdType.req_begin_rank_match_fight, {});
end

function NetworkMsg_Rank:onRetBeginFight(msg)
end
--======================================================================
