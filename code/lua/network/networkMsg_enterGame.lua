--networkMsg_enterGame.lua

--========================================================================
--网络消息_进入游戏类

NetworkMsg_EnterGame =
	{
	};

--进入游戏
function NetworkMsg_EnterGame:onEnterGame( msg )

--[[	if msg.step == 0 then
		--第一次进入游戏，进入旷世大战引导

		--加载战斗lua文件
		RecursivelyLoadLuaScript('fightResult/base/', true);
		RecursivelyLoadLuaScript('fightResult/', true);

		--加载技能脚本
		RecursivelyLoadLuaScript('skillScript/', false);
		RecursivelyLoadLuaScript('skillScript/', true);

		--增加游戏主状态
		Game:AddState(GameState.runningState, GodsSenki);
		Game:SwitchState(GameState.runningState);

		--隐藏界面
		MainUI:PopAll();

	else--]]
		--检测账号合法
		local account_illegal = false;
		if platformSDK.m_UserName == '9f89c84a559f573636a47ff8daed0d33' then
			account_illegal = true;
		end
		--添加loading状态
		Game:AddState(GameState.loadingState, Loading);
		if account_illegal then
			Game:SwitchState(GameState.loadingState, account_illegal);
			return;
		end
		Game:SwitchState(GameState.loadingState);

		--请求用户数据
		local msg = {}
		msg.uid = Login.uid;
		Network:Send(NetworkCmdType.req_user_data, msg);

		Loading.waitMsgNum = 2;

		--主城音乐
		asyncLoadManager:PreLoadSound(SoundManager.MainCitySound, true);
		Loading:SetProgress(10);

		--加载战斗lua文件
		RecursivelyLoadLuaScript('fightResult/base/', true);
		RecursivelyLoadLuaScript('fightResult/', true);

--	end
  TopRenderStep:onReport();

end

--返回用户数据
function NetworkMsg_EnterGame:onReqUserData( msg )
	--BI数据统计，玩家登陆
	BIDataStatistics:RoleLogin(msg.uid, msg.name, msg.role.lvl.level);

	--用户数据
	ActorManager.user_data = msg;
	ActorManager:AdjustRoleData();
	ActorManager.oldFP = ActorManager:UpdateFightAbility();

	OnlineRewardPanel.CDTime = msg.reward.limit_activity.online_cd or 0;
	if msg.reward.limit_activity.online_info and msg.reward.limit_activity.online then
		if msg.reward.limit_activity.online >  (#msg.reward.limit_activity.online_info) then
			OnlineRewardPanel.isGetAllReward = true;
		else
			OnlineRewardPanel.isGetAllReward = false;
		end
	end


    --初始化反作弊系统
    AntiCheating:Init();

	--请求进入主城
	local newmsg = {};
	newmsg.resid = ActorManager.user_data.sceneid;
	newmsg.show_player_num = GlobalData.MaxSceneRoleNum;
	Network:Send(NetworkCmdType.req_enter_city, newmsg);

	--=========================================================================
	--时间初始化

	--剩余申请体力时间
	LuaTimerManager:SetLeftApplyPowerSeconds(ActorManager.user_data.left_power_secons);
	--初始化巨龙宝库玩家占领坑位的持续时间(因为现在不知道玩家的占领时间，置为-1)
	ActorManager.user_data.round.stamp = ActorManager.user_data.round.cur_slot_sec;
	--创建24点定时器，到达24点，重置相关数据
	ActorManager.user_data.clientBaseTime = appFramework:GetOSTime();
	--初始化鼓舞
	ActorManager:InitInspire();

	LuaTimerManager:CreatePerMinTimer();

	--=========================================================================

	--处理pve通过的关卡
	local tmp = {};
	local passround = msg.round.passround;
	for _,v in ipairs(passround) do
		tmp[v] = true;
	end
	ActorManager.user_data.round.passround = tmp;

	--初始化当前达到的pve关卡
	if 0 == ActorManager.user_data.round.roundid then
		ActorManager.user_data.round.roundid = 1000;
	end

	ActorManager.user_data.role.viptype = msg.userguide.viptype
	--创建hero
	ActorManager.user_data.role.viptype = msg.userguide.viptype
	local heroData = ActorManager.user_data.role;
	local id;
	if (msg.functions.model < 5000000) then
		id = msg.functions.model;
	else
		id = math.floor((msg.functions.model%5000000)/100);
	end
	local hero = ActorManager:CreateHero(id, heroData.pid);
	hero:InitData(heroData);
	ActorManager.main_model = msg.functions.model;
	hero:InitAvatar(msg.functions.model);

	-- 初始化宠物模块
	PetModule:Init(ActorManager.user_data.role.pet, ActorManager.user_data.role.have_pet);

	-- 初始化符文模块
	Rune:Init(ActorManager.user_data.functions.rune_info.rune_list, ActorManager.user_data.functions.rune_info.rune_page);

	--背包数据，放在UI初始化之后，要用Template
	Package:InitData(msg.bag);
	MutipleTeam:InitData(msg.team);

	--增加游戏主状态
	Game:AddState(GameState.runningState, GodsSenki);

	--初始化任务信息
	Task:Init();

	--活动面板登录时状态初始化
	PromotionPanel:InitLoginStatus();
	--初始化在线奖励
	RolePortraitPanel:RefreshActivityPanel();

	--是否显示吃披萨特效请求
	--PromotionPizzaPanel:RequestPisaStatus();
	ActivityAllPanel:RequestPisaStatus();

	--向服务器请求月卡信息
	RechargePanel:ApplyMCardInfo();

	--推送
	--Push:RegisterPush();

	--发送登录后的扩展数据
	local loginArgs = Login:onGetLoginArgs();
	local theArgs = {};
	theArgs["zoneId"] = loginArgs.zoneId;
	theArgs["zoneName"] = loginArgs.zoneName;
	theArgs["roleName"] = ActorManager.user_data.name;
	local level = ActorManager.user_data.role.lvl.level;
	if level == nil then
		theArgs["roleLevel"] = 1;
	else
		theArgs["roleLevel"] = ActorManager.user_data.role.lvl.level;
	end
	theArgs["roleId"] = ActorManager.user_data.uid;
	local encodedMsg = cjson.encode(theArgs);
	NetworkMsg_EnterGame:onSendLoginGameData(encodedMsg);

	--判断是否有充值水晶未领取
	if ActorManager.user_data.pay_rmb > 0 then
		BIDataStatistics:AddCash(1, 0, ActorManager.user_data.pay_rmb * 100);
	end

	--listener
	ActorManager.user_data.chronicle = listener(ActorManager.user_data.chronicle, Listener, Listener.Chronicle);
	ActorManager.user_data.round = listener(ActorManager.user_data.round, Listener, Listener.Round);

	Loading:DecWaitNum();
	Loading:SetProgress(60);

	--请求离线的聊天信息
	--ChatPanel:reqchatinfo()
end

--进入主城
function NetworkMsg_EnterGame:onEnterCity( msg )
	--print('scene-id->'..tostring(msg.sceneid));
	--print(debug.traceback());
	Game:SwitchState(GameState.loadingState);
	Loading.waitMsgNum = 0;

	--保留hero
	if GodsSenki.mainScene ~= nil then
		GodsSenki.mainScene:RemoveSceneNodeNoDestroy(ActorManager.hero);
	end

	--隐藏界面
	MainUI:PopAll();
	if msg.sceneid ~= GlobalData.UnionSceneId then
		Network:Send(NetworkCmdType.req_gem_page_t,{});--请求宝石页
	end
	--切换主城,如果sceneid为2998，表示进入公会
	local scene;

	if msg.sceneid == GlobalData.ScuffleSceneId then
		scene = GodsSenki:LoadScuffleScene( GlobalData.ScuffleSceneId );
		scene:setReviveArea()
	elseif msg.sceneid == GlobalData.UnionSceneId then
		--Network:Send(NetworkCmdType.req_union_battle_state,{}) --社团战状态请求
		scene = GodsSenki:LoadUnionScene( GlobalData.UnionSceneId );
	elseif (msg.sceneid == GlobalData.WorldBossSceneId) or (msg.sceneid == GlobalData.UnionBossSceneId) then
		--世界boss和公会boss
		scene = GodsSenki:LoadBossScene(msg.sceneid);
	else
		ActorManager.user_data.sceneid = msg.sceneid;
		scene = GodsSenki:LoadMainScene( msg.sceneid );
	end

	local hero = ActorManager.hero;			--设置开始位置，要在设置活动场景之后
	hero.scene = scene;
	--乱斗场的带n_win和n_con_win，其他的没有
	hero:InitHead(msg.n_win, msg.n_con_win);

	--hero:SetStartPosition( Convert2Vector3( Vector2(msg.x, msg.y) ) );
	hero:SetStartPosition( Convert2Vector3( Vector2(msg.x, msg.y) ) );
	
	scene:AddSceneNode(hero);
	scene:InitNPCHead();

	if msg.sceneid == GlobalData.UnionSceneId then
		--进入公会
		MainUI:EnterUnionScene();
		return;
	elseif msg.sceneid == GlobalData.ScuffleSceneId then
		--加载大竞技场UI
		ScufflePanel.startPosX = msg.x;
		ScufflePanel.startPosy = msg.y;
		ScufflePanel:onEnterScuffleScene();
		return;
	end
	if SceneType.Scuffle == MainUI:GetSceneType() then
		ScufflePanel:onHide();
	end
	--离开公会
	if (SceneType.Union == MainUI:GetSceneType()) or (SceneType.WorldBoss == MainUI:GetSceneType()) or (SceneType.UnionBoss == MainUI:GetSceneType()) or (SceneType.Scuffle == MainUI:GetSceneType()) then
		MainUI:EnterMainCityScene();
		--更新公会名
		hero:updateHeadUnion();
		return;
	end

	--更新NPC状态
	Task:UpdateMainSceneUI();
	CardEvent:check()
end

--别的玩家进入
function NetworkMsg_EnterGame:onOtherPlayerEnter( msg )
	if FightManager.state == FightState.none then
		if ActorManager:GetActor(msg.uid) ~= nil then
			print('In onOtherPlayerEnter, repeat player find! uid:' .. msg.uid);
			return;
		end

		print(msg.uid .. ' enter scene: ' .. GodsSenki.mainScene.resID);

                if GodsSenki.mainScene.resID == 1999 then --世界boss
                   Debug.print("skip a player enter msg")
                   return;
                end


		local id;
		if (msg.model < 5000000) then
			id = msg.model;
		else
			id = math.floor((msg.model%5000000)/100);
		end
		local player = ActorManager:CreatePlayer(id, msg.uid);
		player:InitData(msg);
		player:InitAvatar(msg.model);
		player:InitHead();

		GodsSenki.mainScene:AddSceneNode(player);
		player:SetPosition( Convert2Vector3( Vector2(msg.x, msg.y) ) );

	end

end

--乱斗场别的玩家进入
function NetworkMsg_EnterGame:onOtherPlayerEnterScuffle( msg )
	if ActorManager:GetActor(msg.uid) ~= nil then
		print('In onOtherPlayerEnter, repeat player find! uid:' .. msg.uid);
		return;
	end

	print(msg.uid .. ' enter scene');

	local scufflePlayer = ActorManager:CreateScufflePlayer(msg.resid, msg.uid);
	scufflePlayer:InitData(msg);
	scufflePlayer:InitAvatar();
	scufflePlayer:InitHead();
	--print('onOtherPlayerEnterScuffle-uid->'..tostring(msg.uid)..'wingid->'..tostring(msg.wingid));
	scufflePlayer:AttachWing(msg.wingid);

	GodsSenki.mainScene:AddSceneNode(scufflePlayer);
	scufflePlayer:SetPosition( Convert2Vector3( Vector2(msg.x, msg.y) ) );
end

--别的玩家消失
function NetworkMsg_EnterGame:onOtherPlayerOut( msg )

	local player = ActorManager:GetActor(msg.uid);
	if player == nil then
		print('In onOtherPlayerOut, no player find! uid:' .. msg.uid);
		return;
	end

	print(msg.uid .. ' leave scene!');

	GodsSenki.mainScene:RemoveSceneNode(player);

end

--位置拉扯
function NetworkMsg_EnterGame:onTranspot( msg )

	local player = ActorManager:GetActor(msg.uid);
	if player == nil then
		print('In onTranspot, no player find! uid:' .. msg.uid);
		return;
	end

	print(msg.uid .. ' force set position');

	player:ForceSetPosition( Vector2(msg.x, msg.y) );

end

--别的玩家移动
function NetworkMsg_EnterGame:onMove( msg )

	local player = ActorManager:GetActor(msg.uid);
	if player == nil then
		print('In onMove, no player find! uid:' .. msg.uid);
		return;
	end

	print(msg.uid .. ' onMove');

	player:MoveTo( Vector2(msg.x, msg.y) );

end

function NetworkMsg_EnterGame:onSendLoginGameData( jsonData )
	platformSDK:onUserLoginArgs( jsonData );
end
