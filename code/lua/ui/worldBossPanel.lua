--worldBossPanel.lua
--=================================================================================
--世界或者工会boss面板
WOUBossPanel =
	{
		bossResid = 0;
		bossCD = 0;
		bossType = 1;
		bossMaxHP = 0;
		sceneID = 0;						--战斗场景id
		x = 0;
		y = 0;
		damageRadio = 0;					--本次战斗对boss的伤害数值显示比例
		isFree = true;						--是否免费战斗
		isAuto = false;						--是否自动挑战
		isQuit = false;						--boss战斗结束的返回主城标志
		isInBossScene = false;				--是否处于boss场景
		unionBossOpenFlag = false;			--是否开启公会boss
		revieve_times = 0;
		isFirstIn = false;
		bosscount = 0;
		unionBossCount = 8;					--需要人数进入场景才可开启社团boss
		isUnionBossAva = false;
	};

--变量
local fightStartTimer = -1;				--战斗开始定时器
local updateRankTimer = -1;				--排名数据刷新计时器
local updateReviveTimer = -1;				--刷新复活时间计时器
local curLeftReviveTime = 0;				--当前剩余复活时间
local bossData = {};						--boss属性
local preHpIndex = 7;						--上一次更新时boss的血条
local effectList = {};						--复活倒计时特效列表
local bossLeaveTime; -- 距boss离开剩余时间
local leaveTimer = -1;

--控件
local mainDesktop;
local bossPanel;
local labelCountDown;						--倒计时时间
local effectCountDown;						--倒计时特效
local bossHeadUIPanel;						--boss面板
local btnFightNow;							--是否立即挑战
local checkAutoFight;						--自动战斗复选框
local pRankPanel;
local rankPanel;
local rankList = {};
local reviveNumEffectList = {};				--复活数字特效列表
local reviveNumID = 0;						--复活数字id
local curPlayerCountBrush;					--当前场景中的人数背景
local curPlayerCountLabel;					--当前场景中的人数
local labelInspireCoin;
local labelInspireCoinIcon;
local lblBossLeaveTime;
local btnShow;
local btnHide;
local timePanel;
local lblReviveTime;
local rmbReviveValue;
local inspireValue;
local addValue;
-- local labelInspireValue;					--鼓舞值标签
local inspireTimer = -1;					--金币鼓舞定时器
local inspireBar;
local btnReturn;

local fightNowBtn
local bg      --  遮灰
local fightNowPanel
local closeBtn
local sureBtn
local diamondNum
local isFightNow = false

--初始化
function WOUBossPanel:InitPanel( desktop )
	--变量初始化
	fightStartTimer = -1;
	updateRankTimer = -1;
	updateReviveTimer = -1;
	curLeftReviveTime = 0;
	preHpIndex = 7;
	self.bossResid = 0;
	self.bossCD = 0;
	self.bossType = 1;
	self.bossMaxHP = 0;
	self.damageRadio = 0;
	self.sceneID = 0;
	self.x = 0;
	self.y = 0;
	self.isFree = true;
	rankList = {};
	bossData = {};
	bossHeadUIPanel = {};
	self.isQuit = false;
	self.unionBossOpenFlag = false;
	self.isInBossScene = false;
	reviveNumEffectList = {};
	reviveNumID = 0;
	inspireTimer = -1;
	leaveTimer = -1;

	--控件初始化
	mainDesktop = desktop;
	bossPanel = desktop:GetLogicChild('BossPanel');
	btnFightNow = bossPanel:GetLogicChild('fightNow');
	rmbReviveValue = btnFightNow:GetLogicChild("gemValue");
	checkAutoFight = bossPanel:GetLogicChild('autoFightPanel'):GetLogicChild('autoFight');
	checkAutoFight.Checked = false;
	self.isAuto = checkAutoFight.Checked;
	effectCountDown = nil;
	pRankPanel = bossPanel:GetLogicChild('userRank'):GetLogicChild('rankPanel');
	rankPanel = bossPanel:GetLogicChild('userRank'):GetLogicChild('rankPanel'):GetLogicChild('damageRankPanel');
	btnShow = bossPanel:GetLogicChild('userRank'):GetLogicChild('DownButton');
	btnHide = bossPanel:GetLogicChild('userRank'):GetLogicChild('UpButton');
	btnShow.Visibility, btnHide.Visibility = Visibility.Hidden, Visibility.Visible;
	btnShow:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:RankShow');
	btnHide:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:RankHide');
	timePanel = bossPanel:GetLogicChild('timePanel');
	timePanel.Visibility = Visibility.Hidden;
	lblReviveTime = timePanel:GetLogicChild('hour');
	lblReviveTime.Text = "00:00";

	btnReturn = bossPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:LeaveBossScene');
	curPlayerCountBrush = bossPanel:GetLogicChild('huodongPanel');
	curPlayerCountLabel = curPlayerCountBrush:GetLogicChild('person');
	lblBossLeaveTime = curPlayerCountBrush:GetLogicChild('time');
	local btnCoinInspire = bossPanel:GetLogicChild('inspire_coin');
	inspireBar = bossPanel:GetLogicChild('GuWuProgress');
	inspireValue = bossPanel:GetLogicChild('EncouragementPanel');
	addValue = inspireValue:GetLogicChild('Encouragement');

	fightNowBtn = bossPanel:GetLogicChild('fightNow')
	fightNowBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:fightRightNow')
	bg = bossPanel:GetLogicChild('bg')
	bg.Visibility = Visibility.Hidden
	fightNowPanel = bossPanel:GetLogicChild('fightNowPanel')
	fightNowPanel.Visibility = Visibility.Hidden
	closeBtn = fightNowPanel:GetLogicChild('closeBtn')
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:onCloseClick')
	sureBtn = fightNowPanel:GetLogicChild('ok')
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WOUBossPanel:FightNow')
	diamondNum = fightNowPanel:GetLogicChild('diamondLabel')

	for i = 1, 11 do
		local row = rankPanel:GetLogicChild(tostring(i));
		local labelRank = row:GetLogicChild('rank');
		local labelName = row:GetLogicChild('name');
		local labelDamage = row:GetLogicChild('damage');
		local labelPercent = row:GetLogicChild('percent');
		labelRank.Text = i .. ' ';
		labelName.Text = '';
		labelDamage.Text = '';
		labelPercent.Text = '';
		row.Visibility = Visibility.Hidden;
		table.insert(rankList, {row = row, rank = labelRank, name = labelName, damage = labelDamage, per = labelPercent});
	end

	--初始化boss头像面板
	bossHeadUIPanel.curHpIndex = 0;
	bossHeadUIPanel.panel = Panel(bossPanel:GetLogicChild('bossHeadUIPanel'));
	bossHeadUIPanel.backHpProb = EffectProgressBar(bossHeadUIPanel.panel:GetLogicChild('hpProb1'));
	bossHeadUIPanel.forwardHpProb = EffectProgressBar(bossHeadUIPanel.panel:GetLogicChild('hpProb2'));
	bossHeadUIPanel.hpProbCount = Label(bossHeadUIPanel.panel:GetLogicChild('hpProbCount'));
	bossHeadUIPanel.headPic = ImageElement(bossHeadUIPanel.panel:GetLogicChild('headPic'));
	bossHeadUIPanel.name = Label(bossHeadUIPanel.panel:GetLogicChild('name'));
	bossHeadUIPanel.lv = Label(bossHeadUIPanel.panel:GetLogicChild('Lv'));
	bossHeadUIPanel.panel.Visibility = Visibility.Hidden;
	bossHeadUIPanel.hpProbCount.Visibility = Visibility.Visible;
	bossHeadUIPanel.panel.Enable = true;

	bossPanel.Pick = false;
	btnFightNow.Visibility = Visibility.Hidden;
	rankPanel.Visibility = Visibility.Hidden;
	bossPanel.Visibility = Visibility.Hidden;

	--请求公会boss信息
	if ActorManager.user_data.ggid > 0 then
		self:RequestBossAlive(2);
	end
end

--销毁
function WOUBossPanel:Destroy()
	rankPanel = nil;
end

--=================================================================================
--请求boss是否存活
function WOUBossPanel:RequestBossAlive(bossType)
	local msg = {};
	msg.flag = bossType;
	Network:Send(NetworkCmdType.req_boss_alive, msg, true);
end

--=================================================================================
--UI操作
--显示bossUI界面
function WOUBossPanel:ShowBossPanel()
	bossPanel.Visibility = Visibility.Visible;
	rankPanel.Visibility = Visibility.Hidden;
end

--关闭boss界面
function WOUBossPanel:CloseBossPanel()
	bossPanel.Visibility = Visibility.Hidden;
	rankPanel.Visibility = Visibility.Hidden;
end

function WOUBossPanel:updateFightNowRmbNum()
	rmbReviveValue.Text = tostring(calReviveComsume(self.revieve_times));
end

--  立即重新开始战斗
function WOUBossPanel:fightRightNow(  )
	diamondNum.Text = tostring(calReviveComsume(self.revieve_times));
 	fightNowPanel.Visibility = Visibility.Visible
 	bg.Visibility = Visibility.Visible
end

function WOUBossPanel:onCloseClick(  )
 	fightNowPanel.Visibility = Visibility.Hidden
 	bg.Visibility = Visibility.Hidden
end

function WOUBossPanel:onSureClick(  )
 	self:EnterBossBattle()
 	isFightNow = true
 	fightNowPanel.Visibility = Visibility.Hidden
 	bg.Visibility = Visibility.Hidden
end

--显示伤害排名数据
function WOUBossPanel:showRankData(rankData, bossMaxHp, totalDamage)
	for i = 1, 11 do
		if (rankData[i] == nil) then
			--空,隐藏行
			rankList[i].row.Visibility = Visibility.Hidden;
		
		elseif (i == #rankData) then
			--自己的数据
			--[[
			rankList[i].row.Visibility = Visibility.Visible;
			rankList[i].rank.Visibility = Visibility.Hidden;
			rankList[i].name.Text = LANG_worldBossPanel_1;
			rankList[i].damage.Text = tostring(rankData[i].damage);
			if (rankData[i].damage == bossMaxHp) then
				rankList[i].per.Text = '(100%)';
			else
                           local percent = CheckDiv(rankData[i].damage / bossMaxHp) * 100;
				if (percent >= 99.99) then
					percent = 99.99;
				end
				rankList[i].per.Text = '(' .. string.format('%.1f', percent) .. '%)';
			end
		--]]
		else
			--伤害排名靠前的玩家的数据
			rankList[i].row.Visibility = Visibility.Visible;
			rankList[i].rank.Visibility = Visibility.Visible;
			if utf8.len(rankData[i].nickname) > 4 then
				rankList[i].name.Text = utf8.sub(rankData[i].nickname, 1, 4) .. "...";
			else
				rankList[i].name.Text = rankData[i].nickname;
			end
			rankList[i].name.TextColor = QualityColor[Configuration:getRare(rankData[i].lv)]
			rankList[i].damage.Text = tostring(rankData[i].damage);
			if (rankData[i].damage == bossMaxHp) then
				rankList[i].per.Text = '(100%)';
			else
                           local percent = CheckDiv(rankData[i].damage / bossMaxHp) * 100;
				if (percent >= 99.9) then
					percent = 99.9;
				end
				rankList[i].per.Text = '(' .. string.format('%.1f', percent) .. '%)';
			end
		end
	end
	rankPanel.Size = Size(310, (#rankData-1) * 25+25);

	self:UpdateBossUI(totalDamage);			--更新bossUI
end

--显示当前在线人数
function WOUBossPanel:showCurPlayerCount(count)
	curPlayerCountLabel.Text = tostring(count);
end

--向服务器申请刷新伤害排名
function WOUBossPanel:ApplyRefreshRankData()
	local rankMsg = {};
	rankMsg.flag = self.bossType;
	Network:Send(NetworkCmdType.req_dmg_ranking, rankMsg, true);
end
--开始战斗
function WOUBossPanel:startBossFight()
	self.bossCD = self.bossCD - 1;
	if self.bossCD < 0 then
		if (fightStartTimer ~= -1) then					--删除定时器
			timerManager:DestroyTimer(fightStartTimer);
			timePanel.Visibility = Visibility.Hidden;
			fightStartTimer = -1;
		end

		if effectCountDown ~= nil then
			topDesktop:RemoveChild(effectCountDown);
			effectCountDown = nil;
		end
		ActorManager.hero.scene:CancelObstacle();			--取消障碍
		self:ApplyRefreshRankData();						--申请刷新排名
		self:CreateRankUpdateTimer();						--创建刷新计时器
		if curLeftReviveTime > 0 then
			btnFightNow.Visibility = Visibility.Visible;		--显示立即再战按钮
		else
			btnFightNow.Visibility = Visibility.Hidden;		--显示立即再战按钮
		end
		--checkAutoFight.Visibility = Visibility.Visible;		--显示自动挑战复选框
		checkAutoFight:GetLogicParent().Visibility = Visibility.Visible;
	end
	lblReviveTime.Text = Time2MinSecStr(self.bossCD);
end

--设置本次战斗队boss 的伤害数值
function WOUBossPanel:SetCurDamageRadioToBoss(radio)
	self.damageRadio = radio;
end

--获取本次战斗队boss 的伤害数值
function WOUBossPanel:GetCurDamageRadioToBoss()
	return self.damageRadio;
end

--复活计时器数字特效的回调函数
function WOUBossPanel:reviveEffectAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	uiSystem:AddAutoReleaseControl(armature);				--销毁特效
	reviveNumEffectList[id] = nil;
end

--删除全部复活计时器特效
function WOUBossPanel:DestroyAllNumEffect()
	for key, armature in pairs(reviveNumEffectList) do
		bossPanel:RemoveChild(armature);
		reviveNumEffectList[key] = nil;
	end
end

--角色回到复活地点
function WOUBossPanel:BackToRevivePosition()
	local msg = {};
	msg.uid = ActorManager.user_data.uid;
	msg.sceneid = self.sceneID;
	msg.x = self.x;
	msg.y = self.y;
	Network:Send(NetworkCmdType.nt_move, msg, true);

	ActorManager.hero:SetPosition(Vector3(self.x, self.y, self.y));

	local camera = ActorManager.hero.scene:GetCamera();
	local cameraPos = camera.Translate;
	local width = camera.ViewFrustum.Right;		--屏宽度的一半
	local sceneWidth = ActorManager.hero.scene.width * 0.5;
	if self.x > 0 then
		if self.x + width > sceneWidth  then
			ActorManager.hero.scene:MoveScene(Vector2(sceneWidth - width, self.y));
		else
			ActorManager.hero.scene:MoveScene(Vector2(self.x, self.y));
		end
	else
		if self.x - width < -sceneWidth then
			ActorManager.hero.scene:MoveScene(Vector2(width - sceneWidth, self.y));
		else
			ActorManager.hero.scene:MoveScene(Vector2(self.x, self.y));
		end
	end

	--自动移动到boss区域
	self:BeginAutoMove();
end

--初始化boss属性
function WOUBossPanel:InitBossData(curHp, maxHp, level, resid)
	bossData.curHp = curHp;
	bossData.maxHp = maxHp;
	bossData.resid = resid;
	bossData.level = level;
	local bossItem = resTableManager:GetRowValue(ResTable.monster, tostring(resid));
	bossData.head = GetPicture('navi/' .. bossItem['icon'] .. '.ccz');
	bossData.name = bossItem['name'];
	bossData.hpProbCount = 7;
	preHpIndex = 7;
end

--显示bossUI头像
function WOUBossPanel:ShowBossUI()
	bossHeadUIPanel.curHpIndex = bossData.hpProbCount;
	bossHeadUIPanel.hpProbCount.Text = '× ' .. bossHeadUIPanel.curHpIndex;

	bossHeadUIPanel.name.Text = bossData.name;											--设置boss名字
	bossHeadUIPanel.lv.Text = tostring(bossData.level);
	bossHeadUIPanel.headPic.Image = bossData.head;
	bossHeadUIPanel.hp = CheckDiv(bossData.maxHp / bossHeadUIPanel.curHpIndex);					--每一个血条的血量

	--设置血条最大值
	bossHeadUIPanel.forwardHpProb.MaxValue = bossHeadUIPanel.hp;
	bossHeadUIPanel.forwardHpProb.CurValue = bossHeadUIPanel.forwardHpProb.MaxValue;
	bossHeadUIPanel.backHpProb.MaxValue = bossHeadUIPanel.hp;
	bossHeadUIPanel.backHpProb.CurValue = bossHeadUIPanel.backHpProb.MaxValue;

	self:SetBossHpProbForwardBrush();												--设置boss血条,必须放在maxValue初始化之后
	bossHeadUIPanel.panel.Visibility = Visibility.Visible;								--显示
  bossHeadUIPanel.panel.Enable = true;
end

--设置bossUI血条的前景色
function WOUBossPanel:SetBossHpProbForwardBrush()
	if 1 == bossHeadUIPanel.curHpIndex then
		self.forwardBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwarBrush1', 'godsSenki'));
		self.effectBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwarBrush1', 'godsSenki'));
		self.backBrush = nil;
	else
		self.forwardBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwarBrush' .. bossHeadUIPanel.curHpIndex, 'godsSenki'));
		self.effectBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwarBrush' .. bossHeadUIPanel.curHpIndex, 'godsSenki'));
		local index = bossHeadUIPanel.curHpIndex - 1;
		self.backBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwarBrush' .. index, 'godsSenki'));
	end
	if 0 == bossHeadUIPanel.curHpIndex then
		bossHeadUIPanel.hpProbCount.Visibility = Visibility.Hidden;
	else
		bossHeadUIPanel.hpProbCount.Text = 'x' .. bossHeadUIPanel.curHpIndex;
	end

	bossHeadUIPanel.forwardHpProb.ForwardBrush = self.forwardBrush;
	bossHeadUIPanel.backHpProb.ForwardBrush = self.backBrush;
end

--更新bossUI
function WOUBossPanel:UpdateBossUI(damage)
	if damage == 0 then
		return;
	end

	bossData.curHp = bossData.maxHp - damage;
	if bossData.curHp <= 0 then
		bossHeadUIPanel.panel.Enable = false;				--boss死亡
	end

	bossHeadUIPanel.curHpIndex = math.min(math.ceil(CheckDiv(bossData.curHp/bossHeadUIPanel.hp)), 7);
	bossHeadUIPanel.forwardHpProb.CurValue = bossData.curHp - (bossHeadUIPanel.curHpIndex - 1) * bossHeadUIPanel.hp;
	if preHpIndex ~= bossHeadUIPanel.curHpIndex then
		self:SetBossHpProbForwardBrush();
		preHpIndex = bossHeadUIPanel.curHpIndex;
	end
end

--=================================================================================
--事件

--请求进入世界boss准备场景
function WOUBossPanel:RequestBossFlag(bossType)
	local msg = {};
	msg.flag = bossType;
	Network:Send(NetworkCmdType.req_boss_state, msg);
end

--进入世界boss准备场景
function WOUBossPanel:onReceiveBossFlag(msg)
	if (msg.state == 0) then
		if msg.flag == 1 then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_4);
		elseif msg.flag == 2 then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_5);
		end

	elseif (msg.state == 3) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_6);

	elseif (msg.state == 4) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_7);

	elseif (msg.state == 5) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_8);
	elseif (msg.state == 6) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_11);
	elseif (msg.state == 7) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_unionBoss_10);
	elseif (msg.state == -1) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_worldBossPanel_9);

	else
		MenuPanel:onLeaveChatPanel();
		TaskTipPanel:Hide();
		WorldMapPanel:onClose();

		self.isFirstIn = true;
		bossLeaveTime = msg.boss_leave_time;
		self.revieve_times = msg.revieve_times + 1;
		rmbReviveValue.Text = tostring(calReviveComsume(self.revieve_times));
		self.isQuit = false;
		ActorManager.hero:StopMove();				--暂停英雄跑动

		if (LuaTimerManager:GetCurrentTime() > ActorManager.user_data.wb_start) and (1 == msg.flag) then
			self.bossCD = 0;
			curLeftReviveTime = msg.cd;
		elseif 2 == msg.flag then
			self.bossCD = msg.cd;
			curLeftReviveTime = 0;
		else
			self.bossCD = msg.cd;
			curLeftReviveTime = 0;
		end
		self.sceneID = msg.sceneid;
		self.bossResid = msg.resid;
		self.bossType = msg.flag;					--boss类型1代表世界，2代表公会
		self.bossMaxHP = msg.hp;
		self.x = msg.x;
		self.y = msg.y;

		self:InitBossData(msg.hp, msg.hp, msg.bosslv, msg.resid);
		self:ShowBossUI();

		if (self.bossCD <= 0) then
			btnFightNow.Visibility = Visibility.Visible;		--显示立即再战按钮
			checkAutoFight:GetLogicParent().Visibility = Visibility.Visible;	--显示自动战斗复选框
		else
			--创建定时器，定时开始战斗
			if 2 == msg.flag then
				Toast:MakeToast(Toast.TimeLength_Long,'参加人数が'..self.unionBossCount..'人以上で、ギルドボスに挑戦できます。');
			end
			self:CreateStartFightTimer();
			checkAutoFight:GetLogicParent().Visibility = Visibility.Hidden;	--隐藏自动战斗复选框
		end
		if curLeftReviveTime <= 0 then
			btnFightNow.Visibility = Visibility.Hidden;			--隐藏立即再战按钮
		else
			btnFightNow.Visibility = Visibility.Visible;			--隐藏立即再战按钮
		end


		--boss战斗已经开始，显示伤害排行榜
		self:ApplyRefreshRankData();							--申请刷新排名(包括在线人数)
		self:CreateRankUpdateTimer();							--创建刷新计时器
		self:CreateBossLeaveTimer();

		self:onEnterBossScene();								--切换boss场景
		self:RefreshInspire();									--刷新鼓舞显示
	end
end

--进入boss场景
function WOUBossPanel:onEnterBossScene(x, y)
	--保留hero
	if GodsSenki.mainScene ~= nil then
		GodsSenki.mainScene:RemoveSceneNodeNoDestroy(ActorManager.hero);
	end

	MainUI:SaveHeroTempPosition(ActorManager.hero:GetPosition());

	local scene = GodsSenki:LoadBossScene(self.sceneID);
	scene.isBoss = true;
	SceneManager:SetActiveScene(scene);
	ActorManager.hero.scene = scene;
	ActorManager.hero:InitHead();
	ActorManager.hero:SetStartPosition( Convert2Vector3( Vector2(self.x, self.y) ) );
	scene:AddSceneNode(ActorManager.hero);
	scene:InitNPCHead();

	if self.bossType == 1 then
		MainUI:SetSceneType(SceneType.WorldBoss);						--进入世界boss场景
	else
		MainUI:SetSceneType(SceneType.UnionBoss);						--进入公会boss
	end
	MainUI:ShowWorldBossUI();											--隐藏界面
	ActorManager.hero.scene:AddBoss(self.bossResid);					--添加boss
	ActorManager.hero.scene:SetObstacleState(self.bossCD, false);		--设置障碍状态
	self.isInBossScene = true;

	if (LuaTimerManager:GetCurrentTime() > ActorManager.user_data.wb_start) and (1 == self.bossType) then
		if (curLeftReviveTime > 0) then
			lblReviveTime.Text = Time2MinSecStr(curLeftReviveTime);
			self:CreateReviveUpdateTimer(curLeftReviveTime);
		else
			timePanel.Visibility = Visibility.Hidden;
		end
		self:BeginAutoMove();

	elseif 2 == self.bossType then
		if (curLeftReviveTime > 0) then
			lblReviveTime.Text = Time2MinSecStr(curLeftReviveTime);
			self:CreateReviveUpdateTimer(curLeftReviveTime);
		else
			timePanel.Visibility = Visibility.Hidden;
		end
		self:BeginAutoMove();
	end
end

--接收到服务器的伤害排名
function WOUBossPanel:onShowRankPanel(msg)
	if (1 >= #msg.rank) then
		--暂时没有伤害数据
		rankPanel.Visibility = Visibility.Hidden;
	else
		self:showRankData(msg.rank, self.bossMaxHP, msg.damage);
		rankPanel.Visibility = Visibility.Visible;
	end

	--显示当前人数
	self:showCurPlayerCount(msg.join_count);
end
function WOUBossPanel:BossBattleRoleSound()
	local team = MutipleTeam:getTeam(MutipleTeam:getDefault())
	--  战斗时从队伍中随机选一个英雄播放音效
	local len = 5
	for i=5,1, -1 do
		if team[i] == -1 then
			len = 5 - i
			break
		end
	end
	if len == 0 then
	else
		local random = math.random(1,len)
		local pid = team[6 - random]
		local role = ActorManager:GetRole(pid)   --  获取英雄信息
		local naviInfo
		if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
		else
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
		end
		--  获取声音
		if naviInfo then
			local path = random % (#naviInfo['soundlist']) + 1
			local soundPath = naviInfo['soundlist'][path]
			SoundManager:PlayVoice( tostring(soundPath) )
		end
	end
end
--开始boss战斗
function WOUBossPanel:EnterBossBattle()
	self:BossBattleRoleSound()
	--切到loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	if self.bossType == 1 then
		Loading:SetLoadType(LoadType.worldBoss);
	else
		Loading:SetLoadType(LoadType.unionBoss);
	end

	self:DestroyRankUpdateTimer();
	self:CreateReviveUpdateTimer(Configuration.ReviveTime);

	local msg = {};
	msg.flag = self.bossType;
	if self.isFree then
		msg.charge = 0;
	else
		msg.charge = 1;
	end
	Network:Send(NetworkCmdType.req_boss_start_batt, msg);
end

--立即再战
function WOUBossPanel:FightNow()
		if ActorManager.user_data.rmb >= calReviveComsume(self.revieve_times) then
			ActorManager.hero:StopMove();				--暂停英雄跑动

			self.revieve_times = self.revieve_times + 1;
			rmbReviveValue.Text = tostring(calReviveComsume(self.revieve_times));

			self.isFree = false;
			self:EnterBossBattle();
			self.isFree = true;
		else
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_worldBossPanel_13);
		end
	fightNowPanel.Visibility = Visibility.Hidden
 	bg.Visibility = Visibility.Hidden
end

--挑战boss时出错，boss已经死亡，或者boss逃跑，或者cd时间不到
function WOUBossPanel:EnterBossBattleFailed(msg)
	if 1 == msg.flag then
		--世界Boss
		if (Configuration.BossKilledCode == msg.code) then
			--boss已经被击杀
			self:LeaveBossScene();					--退出boss场景
			Game:SwitchState(GameState.runningState);
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_worldBossPanel_11);

		elseif (Configuration.BossFightCDCode == msg.code) then
			if isFightNow then        --  是否花钻石立即挑战

			else
				--boss挑战cd时间未到
			Loading:LoadingQuit();						--结束loading状态
			self:CreateReviveUpdateTimer(msg.cd);		--创建复活计时器
			end

		else
			--其他,退出loading状态
			Loading:LoadingQuit();
		end
	else
		--公会boss
		if (Configuration.BossKilledCode == msg.code) then
			--boss已经被击杀
			self:LeaveBossScene();					--退出boss场景
			Game:SwitchState(GameState.runningState);
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_worldBossPanel_12);

		elseif (Configuration.BossFightCDCode == msg.code) then
			--boss挑战cd时间未到
			Loading:LoadingQuit();						--结束loading状态
			self:CreateReviveUpdateTimer(msg.cd);		--创建复活计时器

		else
			--其他,退出loading状态
			Loading:LoadingQuit();
		end
	end
end

--离开boss场景
function WOUBossPanel:LeaveBossScene()
	if self.isInBossScene then							--防止连续执行两次LeaveBossScene函数
		local msg = {};
		msg.flag = self.bossType;
		Network:Send(NetworkCmdType.req_boss_leave_scene, msg)
	end
end

--请求进入主城
function WOUBossPanel:OnRequestEnterCity(msg)
	self:DestroyRankUpdateTimer();				--删除伤害排名更新计时器
	self:DestroyStartFightTimer();				--删除开始战斗计时器
	self:DestroyReviveUpdateTimer();			--删除复活计时器
	self:DestroyBossLeaveTimer();
	self.isInBossScene = false;
	checkAutoFight.Checked = false;
	self.isAuto = false;
	MenuPanel:onRecover();
	TaskTipPanel:onShow();
	NetworkMsg_EnterGame:onEnterCity(msg);
end

--收到服务器发送的boss消失或者死亡消息
function WOUBossPanel:ReceiveBossDisappear(msg)
	LimitTaskPanel:updateTask(LimitNews.worldBoss);
	if (msg.flag == 1) then
		PromotionPanel:HideWorldBossButton();		--隐藏世界boss图标
                ActorManager.user_data.counts.n_guwu[InspireType.worldBoss] = {progress = 0, v = 0, stamp_yb = 0, stamp_coin = 0};
	else
		UnionSceneUIPanel:HideUnionButtonAndEffect();
                ActorManager.user_data.counts.n_guwu[InspireType.unionBoss] = {progress = 0, v = 0, stamp_yb = 0, stamp_coin = 0};
		self.unionBossOpenFlag = false;
	end

	if (Game.curState == GameState.loadingState) and ((Loading.loadType == LoadType.worldBoss) or (Loading.loadType == LoadType.unionBoss)) then 					--如果处于战斗状态
		self.isQuit = true;

	elseif (FightManager.state ~= FightState.none) and ((FightManager.mFightType == FightType.worldBoss) or (FightManager.mFightType == FightType.unionBoss)) then
		self.isQuit = true;

	elseif (msg.flag == 1) then
		self:LeaveBossScene();

	elseif (msg.flag == 2) then
		self:LeaveBossScene();

	end
end

--显示世界boss按钮
function WOUBossPanel:ShowBossButton(msg)
	if msg.flag == 1 then
		--世界Boss
		if 1 == msg.st then			--该服未开放
			WorldMapPanel:ShowTimer(0)
			return;
		elseif 2 == msg.st then
			WorldMapPanel:ShowTimer(1)
			--已经开打
			PromotionPanel:ShowWorldBossEffect();
			if (LuaTimerManager:GetCurrentTime() < ActorManager.user_data.wb_start) then
				local msg = {};
				msg.type = SystemEventType.startWorldBoss;
				msg.time = ActorManager.user_data.wb_start;
				msg.flag = 1;
				ChatPanel:AddEventMessage(msg);
			end
		elseif 3 == msg.st then		--boss死亡
			WorldMapPanel:ShowTimer(0)
			return;
		else
			WorldMapPanel:ShowTimer(0)
			return;
		end
	else
		--公会boss
		self.bosscount = msg.bosscount;
		if 1 == msg.st then			--未开放公会boss
			self.isUnionBossAva = false;
			return;
		elseif 2 == msg.st then
			--公会boss正在进行
			self.isUnionBossAva = true;
			UnionSceneUIPanel:ShowUnionButtonAndEffect();
			--if (LuaTimerManager:GetCurrentTime() < Configuration.UnionBossStartTime) then
				local msg = {};
				msg.type = SystemEventType.startWorldBoss;
				msg.time = Configuration.UnionBossStartTime
				msg.flag = 2;
				ChatPanel:AddEventMessage(msg);
			--end
		elseif 3 == msg.st then		--公会boss死亡
			self.isUnionBossAva = false;
			return;
		else
			return;
		end

	end
end

function WOUBossPanel:onOpenUnionBoss(msg)
	if msg.st == 1 then
		Network:Send(NetworkCmdType.req_boss_alive, {
			flag = 2;
		});
	elseif msg.st == 2 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionBoss_2);
	elseif msg.st == 3 or msg.st == 4 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionBoss_3);
	elseif msg.st == 5 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionBoss_5);
	elseif msg.st == 6 or msg.st == 7 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionBoss_6);
	elseif msg.st == 8 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionBoss_8);
	end
end

--自动战斗复选框选中事件
function WOUBossPanel:onCheckAuto()
	self.isAuto = checkAutoFight.Checked;

	--自动移动到boss区域
	self:BeginAutoMove();
end

--开始自动移动
function WOUBossPanel:BeginAutoMove()
	if (self.isAuto) and (curLeftReviveTime <= 0) then
		ActorManager.hero:MoveTo(ActorManager.hero.scene:GetBossPosition(), false);
		--发送移动消息
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.sceneid = self.sceneID;
		msg.x = math.floor(ActorManager.hero.scene:GetBossPosition().x);
		msg.y = math.floor(ActorManager.hero.scene:GetBossPosition().y);
		Network:Send(NetworkCmdType.nt_move, msg, true);
	end
end
--===============================================================================================
function WOUBossPanel:RankShow()
	pRankPanel.Storyboard = 'storyboard.moveOut_3';
	btnShow.Visibility, btnHide.Visibility = Visibility.Hidden, Visibility.Visible;
end
function WOUBossPanel:RankHide()
	pRankPanel.Storyboard = 'storyboard.moveIn_3';
	btnShow.Visibility, btnHide.Visibility = Visibility.Visible, Visibility.Hidden;
end
--===============================================================================================
--刷新鼓舞显示
function WOUBossPanel:RefreshInspire()
	local guwu = ActorManager.user_data.counts.n_guwu;
	if self.bossType == 1 then
		inspireValue.Text = string.format(LANG_worldBossPanel_15, guwu[InspireType.worldBoss].progress);
		inspireBar.CurValue = guwu[InspireType.worldBoss].progress;
		if tonumber(guwu[InspireType.worldBoss].v) > 1 then
			addValue.Text = string.format(LANG_worldBossPanel_15, (guwu[InspireType.worldBoss].v - 1) * 100);
		end
	else
		inspireValue.Text = string.format(LANG_worldBossPanel_15, guwu[InspireType.unionBoss].progress);
		inspireBar.CurValue = guwu[InspireType.unionBoss].progress;
		if tonumber(guwu[InspireType.unionBoss].v) > 1 then
			addValue.Text = string.format(LANG_worldBossPanel_15, (guwu[InspireType.unionBoss].v - 1) * 100);
		end
	end
end

--鼓舞
function WOUBossPanel:Inspire(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.flag = self.bossType;

	if ActorManager.user_data.counts.n_guwu[tostring(msg.flag)].progress >= 100 then
		ToastMove:CreateToast(LANG__61);
		return ;
	end

	if (args.m_pControl.Tag == 1) then
		--金币鼓舞
		msg.yb = 0;
		msg.coin = Configuration.CoinInspireValue;
	else
		--水晶鼓舞
		msg.yb = Configuration.CrystalInspireValue;
		msg.coin = 0;
	end

	Network:Send(NetworkCmdType.req_guwu, msg);
end

--===============================================================================================
-- timer: boss leave timer
function WOUBossPanel:CreateBossLeaveTimer()
	if leaveTimer == -1 then
		leaveTimer = timerManager:CreateTimer(1, 'WOUBossPanel:RefreshBossLeaveTimer', 0);
	end
end
function WOUBossPanel:RefreshBossLeaveTimer()
	if bossLeaveTime <= 0 then
		if leaveTimer ~= -1 then
			timerManager:DestroyTimer(leaveTimer);
			leaveTimer = -1;
		end
	else
		lblBossLeaveTime.Text = Time2HMSStr(bossLeaveTime);
		bossLeaveTime = bossLeaveTime - 1;
		if leaveTimer == -1 then
			leaveTimer = timerManager:CreateTimer(1, 'WOUBossPanel:RefreshBossLeaveTimer', 0);
		end
	end
end
function WOUBossPanel:DestroyBossLeaveTimer()
	if leaveTimer ~= -1 then
		timerManager:DestroyTimer(leaveTimer);
		leaveTimer = -1;
	end
end

-- timer: start fight timer
function WOUBossPanel:CreateStartFightTimer()
	if fightStartTimer == -1 then
		fightStartTimer = timerManager:CreateTimer(1, 'WOUBossPanel:startBossFight', 0);
		timePanel.Visibility = Visibility.Visible;
	end
end
function WOUBossPanel:DestroyStartFightTimer()
	if fightStartTimer ~= -1 then
		timerManager:DestroyTimer(fightStartTimer);
		timePanel.Visibility = Visibility.Hidden;
		fightStartTimer = -1;
	end
end

-- tiemr: rank update timer
function WOUBossPanel:CreateRankUpdateTimer()
	if (updateRankTimer == -1) then
		updateRankTimer = timerManager:CreateTimer(Configuration.UpdateDamageRankSpaceTime, 'WOUBossPanel:ApplyRefreshRankData', 0);
	end
end
function WOUBossPanel:DestroyRankUpdateTimer()
	if (updateRankTimer ~= -1) then
		timerManager:DestroyTimer(updateRankTimer);
		updateRankTimer = -1;
	end
end

-- timer: revive update timer
function WOUBossPanel:CreateReviveUpdateTimer(leftTime)

	curLeftReviveTime = leftTime;
	if ActorManager.user_data.viplevel >= 4 then
		curLeftReviveTime = 0
	end
	ActorManager.hero.scene:SetObstacleState(leftTime, true);		--设置障碍状态

	if (-1 == updateReviveTimer) then
		updateReviveTimer = timerManager:CreateTimer(1, 'WOUBossPanel:updateReviveTime', 0);
	end
end
function WOUBossPanel:updateReviveTime()
	curLeftReviveTime = curLeftReviveTime - 1;
	if (curLeftReviveTime < 0) then
		timePanel.Visibility = Visibility.Hidden;
		btnFightNow.Visibility = Visibility.Hidden;
		--复活时间已过，可以继续战斗
		self:DestroyReviveUpdateTimer();

		--自动移动到boss区域
		if (FightManager.state == FightState.none) and (Game:GetCurState() ~= GameState.loadingState) then
			self:BeginAutoMove();
		end
	else
		timePanel.Visibility = Visibility.Visible;
		btnFightNow.Visibility = Visibility.Visible;
		if (MainUI:GetSceneType() == SceneType.UnionBoss) or (MainUI:GetSceneType() == SceneType.WorldBoss) then
			if (Game.curState == GameState.runningState) and (FightState.none == FightManager.state) then
				lblReviveTime.Text = Time2MinSecStr(curLeftReviveTime);
			end
		end
	end
end
function WOUBossPanel:DestroyReviveUpdateTimer()
	if (updateReviveTimer ~= -1) then
		timerManager:DestroyTimer(updateReviveTimer);
		updateReviveTimer = -1;
		ActorManager.hero.scene:CancelObstacle();
	end
end
function WOUBossPanel:OnBossFightOverCallBack(is_win, damage)
	local msg = {};
	msg.flag = 1;
	msg.damage = math.floor(damage);
	msg.is_win = is_win;
	msg.salt = "WorldBossSalt";
  Network:Send(NetworkCmdType.req_boss_end_batt, msg);
end
function WOUBossPanel:OnUBossFightOverCallBack(is_win, damage)
	local msg = {};
	msg.flag = 2;
	msg.damage = math.floor(damage);
	msg.is_win = is_win;
	msg.salt = "UnionBossSalt";
	Network:Send(NetworkCmdType.req_boss_end_batt, msg);
end

function WOUBossPanel:req_boss_alive()
	local msg = {};
	msg.flag = 1;		--世界boss
	Network:Send(NetworkCmdType.req_boss_alive, msg, true);
end
--===============================================================================================
-- revive math formula
function calReviveComsume(count)
	return count * 2;
end

function WOUBossPanel:onUnionBossOpen(msg)
	self.bossCD = 0;
end
