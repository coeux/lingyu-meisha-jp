--zodiacSignPanel.lua
--========================================================================
--十二宫面板

ZodiacSignPanel = 
	{
		inGuiding	= false;
		fighterAngerList = {};
		gesturePower = 0;
	};
	
--变量
local roundID;						--选择攻打的该宫殿的关卡ID
local lightBg;
local darkBg;
local resetNeedRmb = {200,400,600,800,1000};

--控件
local mainDesktop;
local panel;
local center;
local btnReturn;
local btnReset;
local btnActivityReset;
local labelResetInfo;
local signTitleList = {};
local leftHpProgress;

--初始化
function ZodiacSignPanel:InitPanel(desktop)
	--变量初始化
	roundID = 0;						--选择攻打的该宫殿的关卡ID	
	resetNeedRmb = {200,400,600,800,1000};
	signTitleList = {};
	self.fighterAngerList = {};
	self.gesturePower = 0;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('zodiacSignPanel'));
	panel:IncRefCount();
	
	center = panel:GetLogicChild('center');	
	btnReturn = Button(center:GetLogicChild('back'));
	btnReset = Button(center:GetLogicChild('reset'));
	btnActivityReset = Button(center:GetLogicChild('activityreset'));
	labelResetInfo = Label(center:GetLogicChild('resetInfo'));
	leftHpProgress = center:GetLogicChild('leftHpPercent');
	
	for index = 1, 17 do
		local ctrl = center:GetLogicChild(tostring(index));
		local brushBg = ctrl:GetLogicChild('title');
		local labelTitle = brushBg:GetLogicChild(0);
		local icon = ctrl:GetLogicChild('crossIcon');
		table.insert(signTitleList, {ctrl = ctrl, background = brushBg, title = labelTitle, crossIcon = icon});
		ctrl.Tag = index;
		ctrl.TagExt = RoundIDSection.ZodiacBegin + index;
	end
	
	lightBg = uiSystem:FindResource('12gong_juanzhou_1', 'godsSenki');
	darkBg = uiSystem:FindResource('12gong_juanzhou_2', 'godsSenki');	
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function ZodiacSignPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function ZodiacSignPanel:Show()
	self:Refresh();
	self:RefreshResetButton();
	self:UpdateHpProgressBar();
	center.Background = CreateTextureBrush('background/12gong_beijingtu.ccz', 'godsSenki', Rect(0,0,700,467));
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'ZodiacSignPanel:onUserGuid');	
	
	--离开主城
	GodsSenki:LeaveMainScene();
	
	--刷新十二宫活动按钮
	self:onRefreshResetBtn();
end	

--打开时的新手引导
function ZodiacSignPanel:onUserGuid()
	if UserGuidePanel:GetInGuilding() then
		if (ActorManager.user_data.round.zodiacid == 0) or (ActorManager.user_data.round.zodiacid == RoundIDSection.ZodiacBegin) then
			--判断首个关卡是否可以打
			self.inGuiding = true;
			UserGuidePanel:ShowGuideShade(signTitleList[1].ctrl, GuideEffectType.hand, GuideTipPos.bottom, LANG_zodiacSignPanel_1, nil, 0.5);
		else
			UserGuidePanel:SetInGuiding(false);
		end
	end
end

--隐藏
function ZodiacSignPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	--销毁背景
	center.Background = nil;
	DestroyBrushAndImage('background/12gong_beijingtu.ccz', 'godsSenki');

	--返回主城
	GodsSenki:BackToMainScene(SceneType.ZodiacSignUI);

	--处于新手引导中
	if self.inGuiding then
		self.inGuiding = false;
	end
end

--=============================================================================================
--功能函数

--刷新某一宫的按钮param signState 1代表通过，2代表可以进入，3代表未开启
function ZodiacSignPanel:RefreshSignButton(index, signState)
	local signTitle = signTitleList[index];
	if (signTitle ~= nil) then
		if signState == 1 then
			--通过
			signTitle.background.Background = lightBg;
			signTitle.title.Text = resTableManager:GetValue(ResTable.barriers, tostring(RoundIDSection.ZodiacBegin + index), 'name');
			signTitle.title.TextColor = Configuration.WhiteColor;
			signTitle.ctrl.Pick = false;
			signTitle.crossIcon.Visibility = Visibility.Visible;
		elseif signState == 2 then
			--可以进入
			signTitle.background.Background = lightBg;
			signTitle.title.Text = resTableManager:GetValue(ResTable.barriers, tostring(RoundIDSection.ZodiacBegin + index), 'name');
			signTitle.title.TextColor = Configuration.WhiteColor;
			signTitle.ctrl.Pick = true;
			signTitle.crossIcon.Visibility = Visibility.Hidden;
		else
			--未开启
			signTitle.background.Background = darkBg;
			signTitle.title.Text = LANG_zodiacSignPanel_3;
			signTitle.title.TextColor = QuadColor(Color(200, 33, 33, 255));
			signTitle.ctrl.Pick = false;
			signTitle.crossIcon.Visibility = Visibility.Hidden;
		end
	end
end

--刷新十二宫界面
function ZodiacSignPanel:Refresh()
	local count = 0;
	if ActorManager.user_data.round.zodiacid > RoundIDSection.ZodiacBegin then
		count = ActorManager.user_data.round.zodiacid - RoundIDSection.ZodiacBegin;
	end

	for index = 1, 17 do
		if index <= count then
			self:RefreshSignButton(index, 1);
		elseif index == count + 1 then
			self:RefreshSignButton(index, 2);
		else
			self:RefreshSignButton(index, 3);
		end
	end		
end

--刷新重置按钮
function ZodiacSignPanel:RefreshResetButton()
	local times = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_zodiac');
	if nil == ActorManager.user_data.round.zodiac_flush then
		ActorManager.user_data.round.zodiac_flush = 0;
	end
	
	labelResetInfo.Visibility = Visibility.Visible;
	btnReset.Visibility = Visibility.Visible;

	if (times > 0) and (times <= ActorManager.user_data.round.zodiac_flush) then
		--重置次数已经用完
		btnReset.Enable = false;
	else
		btnReset.Enable = true;
	end
end

--是否显示
function ZodiacSignPanel:IsVisible()
	return Visibility.Visible == panel.Visibility;
end

--设置战斗结束的时候角色怒气
function ZodiacSignPanel:SetFighterAnger(fighterAngerList)
	self.fighterAngerList = fighterAngerList;
end

--设置战斗结束的时候手势技能的能量
function ZodiacSignPanel:SetGesturePower(power)
	self.gesturePower = power;
end

--更新血量进度条显示
function ZodiacSignPanel:UpdateHpProgressBar()
	if (ActorManager.user_data.counts.zodiac_hp_percent == nil) then
		ActorManager.user_data.counts.zodiac_hp_percent = 1;
	end
	leftHpProgress.CurValue = math.floor(ActorManager.user_data.counts.zodiac_hp_percent * 100);
end

--请求通关的十二宫id
function ZodiacSignPanel:ApplyCrossedZodiacID()
	-- Network:Send(NetworkCmdType.req_zodiacid, {});
end
--=============================================================================================
--事件
function ZodiacSignPanel:onReturn()
	MainUI:Pop();
end

--某个宫的点击事件
function ZodiacSignPanel:onEnterSign(Args)
	if (ActorManager.user_data.counts.zodiac_hp_percent == 0) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG__68);
		return;
	end

	local args = UIControlEventArgs(Args);
	PveBarrierInfoPanel:onEnterPveBarrierInfo(args.m_pControl.TagExt);
end	

--重置按钮点击事件
function ZodiacSignPanel:onReset()
	local openVipLv = resTableManager:GetValue(ResTable.vip_open, '12', 'viplv');
	local times = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_zodiac');

	if (times <= 0) then
		--vip等级不足，没有重置次数
		local vipOpenLv = resTableManager:GetValue(ResTable.vip_open, '12', 'viplv');
		MessageBox:ShowDialog(MessageBoxType.Ok, 'Vip'.. vipOpenLv .. LANG__69);
	elseif (ActorManager.user_data.round.zodiac_flush < times) then
		local okDelegate = Delegate.new(ZodiacSignPanel, ZodiacSignPanel.realReset);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG__70, okDelegate);
	end
end

function ZodiacSignPanel:onActivityReset()
	ZodiacSignPanel:realReset();
end

function ZodiacSignPanel:onRefreshResetBtn()
	if ActorManager.user_data.round.free_flush_zodiac == 0 then
		btnReset.Visibility = Visibility.Hidden;
		btnActivityReset.Visibility = Visibility.Visible;
	else
		btnReset.Visibility = Visibility.Visible;
		btnActivityReset.Visibility = Visibility.Hidden;
	end
end

--确认重置
function ZodiacSignPanel:realReset()
	local msg = {};
	msg.gid = Configuration.BaseZodiaSignID;
	Network:Send(NetworkCmdType.req_round_flush, msg);
end

--重置十二宫关卡
function ZodiacSignPanel:ResetSignRound(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_zodiacSignPanel_5);

	--刷新免费刷新标志位
	if ActorManager.user_data.round.free_flush_zodiac == 0 then
		ActorManager.user_data.round.free_flush_zodiac = ActorManager.user_data.round.free_flush_zodiac + 1;
	else
		ActorManager.user_data.round.zodiac_flush = ActorManager.user_data.round.zodiac_flush + 1;
	end
	
	ActorManager.user_data.round.zodiacid = 0;              --关卡id重置
	ActorManager.user_data.counts.zodiac_hp_percent = 1;    --血量重置
	
	self:Refresh();
	self:RefreshResetButton();
	self:onRefreshResetBtn();
    self:UpdateHpProgressBar();
end

--显示说明
function ZodiacSignPanel:onShuoMing()
	HelpPanel:SetDisplayAndMove(12);
	MainUI:Push(HelpPanel);
end

--十二宫战斗结束回调函数
function ZodiacSignPanel:OnZodiacFightCallBack(resultData)
	--保存剩余血量
	ActorManager.user_data.counts.zodiac_hp_percent = resultData.hp_percent;
	self:UpdateHpProgressBar();

	local msg = {};
	msg.resid = resultData.id;
	msg.killed = FightManager:GetKillMonsterList();
	msg.hp_percent = resultData.hp_percent;
	msg.fpower = resultData.gesturePower;
	msg.angers = resultData.fighterAngerList;
	if resultData.result == Victory.left then
		msg.stars = 0;
		msg.win = true;	
	else
		msg.stars = 0;
		msg.win = false;
	end
	Network:Send(NetworkCmdType.req_zodiac_exit, msg);			--通知服务器十二宫战斗结束	
end

--十二宫战斗结束收到服务器消息的回调函数
function ZodiacSignPanel:OnZodiacFightAfterSerMsgCallBack(isWin, barrierID)
	if not isWin then
		return;
	end
	
	ActorManager.user_data.round.zodiacid = barrierID;
	local crossIndex = ActorManager.user_data.round.zodiacid - RoundIDSection.ZodiacBegin;
	self:RefreshSignButton(crossIndex, 1);			--刷新该按钮显示已经通关
	self:RefreshSignButton(crossIndex + 1, 2);		--刷新该按钮显示可以进入
end

--24点重置功能
function ZodiacSignPanel:ResetAt24()
	ActorManager.user_data.round.zodiac_flush = 0;
	ActorManager.user_data.round.zodiacid = RoundIDSection.ZodiacBegin;
	ActorManager.user_data.counts.zodiac_hp_percent = 1;

	self:Refresh();
	self:RefreshResetButton();
	self:onRefreshResetBtn();

	if PveBarrierInfoPanel:IsVisible() and PveBarrierInfoPanel:isZodia() then
		MainUI:Pop();								--关闭当前界面
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_timer_4);
	end
end

--收到zodiacID
function ZodiacSignPanel:ReceiveZodiacID(msg)
	ActorManager.user_data.round.zodiacid = msg.id;
end
