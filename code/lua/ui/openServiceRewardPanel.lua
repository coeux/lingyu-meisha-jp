--openServiceRewardPanel.lua
 
--========================================================================

OpenServiceRewardPanel = 
{

}
--冲级有礼
local levelPanel
local levelTitlePic;
local levelTipPic;
local levelDrawStack;
local levelAcDate;
--领袖之路
local leaderPanel;
local leaderTitlePic;
local leaderTipPic;
local leaderRewardPanel;
local leaderAcDate;

--竞技王者
local arenafightPanel;
local arenafightTitlePic;
local arenafightTipPic;
local arenafightRewardPanel;
local arenafightAcDate;

-- 开服7日成长
local getButtonArr

local activityBtnEvent = {
	'OpenServiceRewardPanel::shareReward', 					-- 分享
	'OpenServiceRewardPanel:wingSelectReward', 				-- 放飞梦想
	'OpenServiceRewardPanel::diamondDrwaReward',			-- 限时召唤
	'OpenServiceRewardPanel::roundStarsReward', 			-- 战斗达人
	'OpenServiceRewardPanel::ArenaFightPanel', 				-- 竞技王者
	'OpenServiceRewardPanel::levelDrawReward',				--冲级有礼
	'OpenServiceRewardPanel::leaderDrawReward',  			-- 邀请好友
    'OpenServiceRewardPanel:sevenpayReward',                --天天充值
	'OpenServiceRewardPanel:ReqlimitpubReward',             --召唤排行
	'OpenServiceRewardPanel:GrowUpReward',					-- 开服成长
}

function OpenServiceRewardPanel:InitPanel(desktop)
	self.activityTipList ={};			--运营活动按钮提示
	self.mainDesktop =  desktop;

	self.panel = desktop:GetLogicChild('openServicePanel');
	self.panel:IncRefCount();	
	self.panel.ZOrder = PanelZOrder.activity;
	self.panel.Visibility = Visibility.Hidden;

	self.closeBtn = self.panel:GetLogicChild('close');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:onClose');

	self.activityArea = self.panel:GetLogicChild('activityArea');
	self.btnArea = self.panel:GetLogicChild('btnArea');
	self.selectImg = self.btnArea:GetLogicChild('img');
	self.selectImg.Visibility = Visibility.Hidden;
	--放飞梦想
	self.wingSelectPanel = self.activityArea:GetLogicChild('2');
	self.wingSelectTipPic = self.wingSelectPanel:GetLogicChild('tipPic');
	self.wingSelectTitlePic =  self.wingSelectPanel:GetLogicChild('titlePic');
	self.wingSelectDesc = self.wingSelectPanel:GetLogicChild('desc');
	self.wingSelectInfo = self.wingSelectPanel:GetLogicChild('Info');
	self.wingSelectDate = self.wingSelectPanel:GetLogicChild('date');
	self.wingSelectStackPanel = self.wingSelectPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.wingSelectgoBtn	= self.wingSelectPanel:GetLogicChild('goBtn');
	self.wingSelectgoBtn:SubscribeScriptedEvent('Button::ClickEvent','OpenServiceRewardPanel:wingSelectgoBtnClick');
	--限时召唤
	self.drawRewardPanel = self.activityArea:GetLogicChild('3');
	self.drawRewardTipPic = self.drawRewardPanel:GetLogicChild('tipPic');
	self.drawRewardTitlePic =  self.drawRewardPanel:GetLogicChild('titlePic');
	self.drawRewardDesc = self.drawRewardPanel:GetLogicChild('desc');
	self.drawRewardInfo = self.drawRewardPanel:GetLogicChild('Info');
	self.drawRewardDate = self.drawRewardPanel:GetLogicChild('date');
	self.drawRewardStackPanel = self.drawRewardPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.drawRewardHeroPic = self.drawRewardPanel:GetLogicChild('heroPic');
	self.drawRewardCount = self.drawRewardPanel:GetLogicChild('countLabel'):GetLogicChild('count')

	--战斗达人
	self.roundStarRewardPanel = self.activityArea:GetLogicChild('4');
	self.roundStarRewardTipPic = self.roundStarRewardPanel:GetLogicChild('tipPic');
	self.roundStarRewardTitlePic =  self.roundStarRewardPanel:GetLogicChild('titlePic');
	self.roundStarRewardDesc = self.roundStarRewardPanel:GetLogicChild('desc');
	self.roundStarRewardInfo = self.roundStarRewardPanel:GetLogicChild('Info');
	self.roundStarRewardDate = self.roundStarRewardPanel:GetLogicChild('date');
	self.roundStarRewardStackPanel = self.roundStarRewardPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	
	--冲级有礼
	levelPanel     = self.activityArea:GetLogicChild('6')
	levelTitlePic  = levelPanel:GetLogicChild('titlePic')
	levelTipPic	   = levelPanel:GetLogicChild('tipPic')
	levelDesc	   = levelPanel:GetLogicChild('desc')
	levelDrawStack = levelPanel:GetLogicChild('levelDrawScroll'):GetLogicChild('levelDrawStack')
	levelAcDate    = levelPanel:GetLogicChild('activityDate'):GetLogicChild('acDate')
	levelEndTip  = levelPanel:GetLogicChild('activityDate'):GetLogicChild('date')
	self:levelDrawRewardInit()
	--领袖之路
	leaderPanel       = self.activityArea:GetLogicChild('7')
	leaderTitlePic    = leaderPanel:GetLogicChild('titlePic')
	leaderTipPic      = leaderPanel:GetLogicChild('tipPic')
	leaderDesc		  = leaderPanel:GetLogicChild('desc')
	leaderRewardPanel = leaderPanel:GetLogicChild('leaderDrawScroll'):GetLogicChild('leaderDrawStack')
	leaderAcDate      = leaderPanel:GetLogicChild('activityDate'):GetLogicChild('acDate')
	leaderEndTip      = leaderPanel:GetLogicChild('activityDate'):GetLogicChild('date')
	OpenServiceRewardPanel:leaderDrawRewardInit()

	--竞技王者
	arenafightPanel       = self.activityArea:GetLogicChild('5')
	arenafightTitlePic    = arenafightPanel:GetLogicChild('titlePic')
	arenafightTipPic      = arenafightPanel:GetLogicChild('tipPic')
	arenafightDesc     = arenafightPanel:GetLogicChild('desc')
	arenafightRewardPanel = arenafightPanel:GetLogicChild('arenafightRewardPanel'):GetLogicChild('arenafightStack');
	arenafightAcDate      = arenafightPanel:GetLogicChild('activityDate'):GetLogicChild('acDate')
	arenafightEndTip      = arenafightPanel:GetLogicChild('activityDate'):GetLogicChild('date')
	self:arenafightDrawRewardInit()


	self.wingendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('wingendtip');
	self.zhaomuendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('zhaomuendtip');
	self.fightendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('fightendtip');
	self.arenaendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('arenaendtip');
	self.levelrankendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('levelrankendtip');
	self.levelrankendtip2 = self.panel:GetLogicChild('btnArea'):GetLogicChild('levelrankendtip2');
	self.leadendtip = self.panel:GetLogicChild('btnArea'):GetLogicChild('leadendtip');
	self.leadendtip2 = self.panel:GetLogicChild('btnArea'):GetLogicChild('leadendtip2');
    
    --天天充值
	self.sevenpayPanel = self.activityArea:GetLogicChild('8');
	self.sevenpayTipPic = self.sevenpayPanel:GetLogicChild('tipPic');
	self.sevenpayTitlePic =  self.sevenpayPanel:GetLogicChild('titlePic');
	self.sevenpayDesc = self.sevenpayPanel:GetLogicChild('desc');
	self.sevenpayInfo = self.sevenpayPanel:GetLogicChild('Info');
	self.sevenpayDate = self.sevenpayPanel:GetLogicChild('date');
	self.sevenpayStackPanel = self.sevenpayPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
    self.dailypaytip = self.panel:GetLogicChild('btnArea'):GetLogicChild('dailypaytip');
	self.seveninfo1 = self.sevenpayPanel:GetLogicChild('info1');
	self.seveninfo2 = self.sevenpayPanel:GetLogicChild('info2');
	self.seveninfo3 = self.sevenpayPanel:GetLogicChild('info3');
	self.seveninfo4 = self.sevenpayPanel:GetLogicChild('info4');
	self.seveninfo5 = self.sevenpayPanel:GetLogicChild('info5');
	self.sevenimage = self.sevenpayPanel:GetLogicChild('image');
	self.sevenheropic  = self.sevenpayPanel:GetLogicChild('heroPic');

	--召唤排行
	self.limitpubPanel     	= self.activityArea:GetLogicChild('9')
	self.limitpubTipPic	   	= self.limitpubPanel:GetLogicChild('titlePic')
	self.limitpubDesc	   	= self.limitpubPanel:GetLogicChild('desc')
	self.limitpubInfo 		= self.limitpubPanel:GetLogicChild('Info');
	self.limitpubTopPanel	= self.limitpubPanel:GetLogicChild('topPanel');
	self.limitpubRankPanel  = self.limitpubPanel:GetLogicChild('rankPanel');
	self.limitpubDrawStack 	= self.limitpubPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel')
	self.limitpubtip 		= self.panel:GetLogicChild('btnArea'):GetLogicChild('pubranktip');
	self.reqlimitpubtime 	= 0;
	self:limitpubRewardInit()

	-- 开服成长
	self.growUpPanel = self.activityArea:GetLogicChild('10');
	self.growUpTitlePic =  self.growUpPanel:GetLogicChild('titlePic');
	self.growUpHeroPic =  self.growUpPanel:GetLogicChild('heroPic');
	self.growUpDesc = self.growUpPanel:GetLogicChild('desc');
	self.growUpInfo = self.growUpPanel:GetLogicChild('Info');
	self.growUpDate = self.growUpPanel:GetLogicChild('date');
	self.growUpStackPanel = self.growUpPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
    self.growUptip = self.panel:GetLogicChild('btnArea'):GetLogicChild('growUptip');

    self.timePanel = self.panel:GetLogicChild('btnArea'):GetLogicChild('timePanel');
    self.timePanel.Background = CreateTextureBrush('dynamicPic/openserver_time_bg.ccz','Welfare');
    self.startTime = self.timePanel:GetLogicChild('startTime');
    self.endTime = self.timePanel:GetLogicChild('endTime');
end
function OpenServiceRewardPanel:wingSelectgoBtnClick()
	WingPanel:onShow(WingPanelEnterType.openServerWingSelect);
end
function OpenServiceRewardPanel:updateBtnTip()
	--jp
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + ActivityTime.OpenActivity then
		--self.wingendtip.Visibility = Visibility.Hidden;
		self.zhaomuendtip.Visibility = Visibility.Hidden;
		self.fightendtip.Visibility = Visibility.Hidden;
	--	self.leadendtip.Visibility = Visibility.Visible;
	--	self.leadendtip2.Visibility = Visibility.Hidden;	
	--	self.dailypaytip.Visibility = Visibility.Hidden;
	else
		self.zhaomuendtip.Visibility = Visibility.Visible;
		--self.wingendtip.Visibility = Visibility.Visible;
		self.fightendtip.Visibility = Visibility.Visible;
	--	self.leadendtip2.Visibility = Visibility.Visible;
	--	self.leadendtip.Visibility = Visibility.Hidden;
	--	self.dailypaytip.Visibility = Visibility.Visible;
	end

	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 10 * 86400 then
		--self.growUptip.Visibility = Visibility.Hidden;
	else
		--self.growUptip.Visibility = Visibility.Visible;
	end


	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 5 * 86400 then
		self.levelrankendtip.Visibility = Visibility.Visible;
		self.levelrankendtip.Visibility = Visibility.Hidden;
		
	else
		self.levelrankendtip.Visibility = Visibility.Hidden;
		self.levelrankendtip2.Visibility = Visibility.Visible;
	end


	if LuaTimerManager:GetCurrentTimeStamp() >= ActorManager.user_data.reward.servercreatestamp + 9 * 86400 - 3 * 3600 then
		self.arenaendtip.Visibility = Visibility.Visible;
	else
		self.arenaendtip.Visibility = Visibility.Hidden;
	end

	--jp
	self.levelrankendtip2.Visibility = Visibility.Hidden;
	self.levelrankendtip.Visibility = Visibility.Hidden;
	self.arenaendtip.Visibility = Visibility.Hidden;
	self.dailypaytip.Visibility = Visibility.Hidden;
	self.leadendtip.Visibility = Visibility.Hidden;
	self.leadendtip2.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

function OpenServiceRewardPanel:onClose()
	self:Hide();
end

function OpenServiceRewardPanel:Hide()
	self.panel.Visibility = Visibility.Hidden;

	self:DestroyBrushAndImage()
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function OpenServiceRewardPanel:DestroyBrushAndImage()
	self.btnArea.Background = nil;
	self.activityArea.Background = nil;
	local bgTop = self.activityArea:GetLogicChild(0);
	bgTop.Background = nil;
	DestroyBrushAndImage('Welfare/recharge_back_list.ccz','Welfare');
	DestroyBrushAndImage('Welfare/recharge_back_bg.ccz','Welfare');
	DestroyBrushAndImage('Welfare/recharge_back_title.ccz','Welfare');
end

function OpenServiceRewardPanel:onShow()
	self.btnArea.Background = CreateTextureBrush('Welfare/Welfare_bg_1.ccz','Welfare');
	self.activityArea.Background = CreateTextureBrush('Welfare/Welfare_bg_2.ccz','Welfare');
	--local bgTop = self.activityArea:GetLogicChild(0);
	--bgTop.Background = CreateTextureBrush('Welfare/recharge_back_title.ccz','Welfare');

	--设置模式对话框
	self.panel.Visibility = Visibility.Visible;

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		self.activityArea:SetScale(0.85, 0.85);
		self.activityArea.Margin = Rect(-120, 70, 0, 0);
		self.panel:GetLogicChild('btnArea'):SetScale(0.85, 0.85);
		self.panel:GetLogicChild('btnArea').Margin = Rect(280, 67, 0, 0);
		self.closeBtn.Margin = Rect(-380, 85, 11, 0);
	end
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);

	self:InitBtnArea();
	OpenServiceRewardPanel:updateBtnTip()
end

function OpenServiceRewardPanel:InitBtnArea()
	for i=1, #activityBtnEvent do	
		local activityBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild(i-1);
		activityBtn.GroupID = RadionButtonGroup.openServiceReward;
		local activityItemLabel = activityBtn:GetLogicChild(0);
		if i == 2 or i == 3 or i == 4 or i == 10 then
			activityBtn.SelectedBrush = CreateTextureBrush('dynamicPic/openserver_time_'..(i*10+1)..'.ccz', 'Welfare');
			activityBtn.UnSelectedBrush = CreateTextureBrush('dynamicPic/openserver_time_'..(i*10)..'.ccz', 'Welfare');
		end
		activityBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', activityBtnEvent[i]);	

		local activityNumLabel = activityBtn:GetLogicChild(2);

		if i==2 then
			activityBtn.Selected = true;
			--self:shareReward();
		else
			activityBtn.Selected = false;
		end
		OpenServiceRewardPanel:wingSelectReward();
		--jp
		if i >= 5 and i <= 9 then
			self.btnArea:GetLogicChild('stack'):GetLogicChild(i-1).Visibility = Visibility.Hidden;
			self.btnArea:GetLogicChild(1):GetLogicChild(i-1).Visibility = Visibility.Hidden;
		end
	end	
end

function OpenServiceRewardPanel:HideAllActivityPanel()
	local btnNum = #activityBtnEvent;
	for i= 1, btnNum do
		local thePanel =  self.activityArea:GetLogicChild(tostring(i));
		if thePanel then
			local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild(i-1):GetLogicChild('nameLabel');
			textBtn.Visibility = Visibility.Hidden;
			thePanel.Visibility = Visibility.Hidden;
		end
	end
end

function OpenServiceRewardPanel:shareReward()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('1'):GetLogicChild('nameLabel');
	self.selectImg.Margin = Rect(-68,14,0,0);
	textBtn.Visibility = Visibility.Visible;
end

function OpenServiceRewardPanel:diamondDrwaReward()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('3'):GetLogicChild('nameLabel');
	-- activityTipList[3]:Destroy();
	--self.selectImg.Margin = Rect(-68,68,0,0);
	--textBtn.Visibility = Visibility.Visible;

	self.drawRewardTitlePic.Image = GetPicture('dynamicPic/openserver_title_2.ccz');
	self.drawRewardTipPic.Image  = GetPicture('dynamicPic/diamond_draw_tip.ccz');
	self.drawRewardHeroPic.Image = GetPicture('navi/H027_navi_01.ccz');
	self.drawRewardCount.Text = tostring(ActorManager.user_data.role.draw_ten_diamond);
	local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
	local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 7 * 86400); 
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 7 * 86400 then
		self.drawRewardDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		--self.drawRewardDate.Visibility = Visibility.Visible;
	else
		self.drawRewardDesc.Text = '(活动已结束) ';
		--self.drawRewardDate.Visibility = Visibility.Hidden;
	end
	self.startTime.Text = tostring(begintc.year..'/'..begintc.month..'/'..begintc.day..'/'..begintc.hour..'時');
	self.endTime.Text = tostring(endtc.year..'/'..endtc.month..'/'..endtc.day..'/'..endtc.hour..'時');
	self.drawRewardInfo.Text = ''--LANG_OPENSERVER_Info_2;
	self.drawRewardPanel.Visibility = Visibility.Visible;
	self:initDrawRewardPanel();
end

function OpenServiceRewardPanel:sevenpayReward()
--天天充值绑定方法
    self:HideAllActivityPanel();
    local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('8'):GetLogicChild('nameLabel');
    self.selectImg.Margin = Rect(-68,328,0,0);
	textBtn.Visibility = Visibility.Visible;

	self.seveninfo1.Text = Lang_open_seven_1;
	self.seveninfo2.Text = Lang_open_seven_2;
	self.seveninfo4.Text = Lang_open_seven_3;
	self.seveninfo5.Text = Lang_open_seven_4;
	self.sevenheropic.Image = GetPicture('navi/H043_navi_01.ccz');


	self.sevenpayTitlePic.Image = GetPicture('dynamicPic/sevenpay_title.ccz');
	self.sevenpayTipPic.Image  = GetPicture('dynamicPic/sevenpay_info.ccz');
	self.sevenpayPanel.Visibility = Visibility.Visible;
	local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
	local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 7 * 86400); 
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 7 * 86400 then
		self.sevenpayDesc.Text =   string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		self.sevenpayDate.Visibility = Visibility.Visible;
	else
	    self.sevenpayDesc.Text = LANG_activityAllPanel_72;
	    self.sevenpayDate.Visibility = Visibility.Hidden;
	end
	    self.sevenpayInfo.Text = LANG_OPENSERVER_Info_8;
	    self:initSevenpayRewardPanel();
end


function OpenServiceRewardPanel:isInOpenTime()

    local curstamp = LuaTimerManager:GetCurrentTimeStamp()
    local servercreate_stamp = ActorManager.user_data.reward.servercreatestamp;

    if curstamp > servercreate_stamp and curstamp < (servercreate_stamp + ActivityTime.OpenActivity) then 
        return true;
    else
	return false;
    end 

end 


--天天充值活动状态改变
function OpenServiceRewardPanel:sevenpayChanged(msg)
    ActorManager.user_data.reward.limit_activity.limit_double_activity.sevenpay_stage = msg.stage;
    self:initSevenpayRewardPanel();
    RolePortraitPanel:activityLimitTip(YN)
end

function OpenServiceRewardPanel:wingSelectReward()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('2'):GetLogicChild('nameLabel');
	--self.selectImg.Margin = Rect(-68,14,0,0);
	--textBtn.Visibility = Visibility.Visible;

	self.wingSelectTitlePic.Image = GetPicture('dynamicPic/openserver_title_1.ccz');
	self.wingSelectTipPic.Image  = GetPicture('dynamicPic/wingselect_info.ccz');
	self.wingSelectPanel.Visibility = Visibility.Visible;
	local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
	local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + ActivityTime.OpenActivity); 
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 7 * 86400 then
		self.wingSelectDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		--self.wingSelectDate.Visibility = Visibility.Visible;
	else
		self.wingSelectDesc.Text = LANG_activityAllPanel_72;
		--self.wingSelectDate.Visibility = Visibility.Hidden;
	end
	self.startTime.Text = tostring(begintc.year..'/'..begintc.month..'/'..begintc.day..'/'..begintc.hour..'時');
	self.endTime.Text = tostring(endtc.year..'/'..endtc.month..'/'..endtc.day..'/'..endtc.hour..'時');
	self.wingSelectInfo.Text = ''--LANG_OPENSERVER_Info_1;

	self:initWingSelectRewardPanel();
end

--放飞梦想活动状态改变
function OpenServiceRewardPanel:wingactivityChanged(msg)
	if msg.is_in_limit_activity == 1 then
		if msg.limit_wing_reward then
			ActorManager.user_data.reward.limit_activity.limit_wing_reward = msg.limit_wing_reward;
		end
		local YN = ActivityRechargePanel:IsCanGetReward();
		RolePortraitPanel:activityLimitTip(YN);
	else
		ActorManager.user_data.reward.wingactivity = msg.wingactivity;
		self:initWingSelectRewardPanel();
	end
end


function OpenServiceRewardPanel:roundStarsReward()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('4'):GetLogicChild('nameLabel');
	-- activityTipList[4]:Destroy();
	--self.selectImg.Margin = Rect(-68,118,0,0);
	--textBtn.Visibility = Visibility.Visible;

	self.roundStarRewardTitlePic.Image = GetPicture('dynamicPic/openserver_title_3.ccz');
	self.roundStarRewardTipPic.Image  = GetPicture('dynamicPic/round_star_tip.ccz');
	local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
	local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + ActivityTime.OpenActivity); 
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 7 * 86400 then
		self.roundStarRewardDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		--self.roundStarRewardDate.Visibility = Visibility.Visible;
	else
		self.roundStarRewardDesc.Text = LANG_activityAllPanel_72;
		--self.roundStarRewardDate.Visibility = Visibility.Hidden;
	end
	self.startTime.Text = tostring(begintc.year..'/'..begintc.month..'/'..begintc.day..'/'..begintc.hour..'時');
	self.endTime.Text = tostring(endtc.year..'/'..endtc.month..'/'..endtc.day..'/'..endtc.hour..'時');
	self.roundStarRewardInfo.Text = ''--LANG_OPENSERVER_Info_3;
	self.roundStarRewardPanel.Visibility = Visibility.Visible;
	self:initRoundStarRewardPanel();
end

function OpenServiceRewardPanel:levelDrawReward()
	self:HideAllActivityPanel();
	levelPanel.Visibility = Visibility.Visible;
	levelTitlePic.Image = GetPicture('dynamicPic/level_draw_title.ccz');
	levelTipPic.Image = GetPicture('dynamicPic/level_draw_tip.ccz');
	local textBtn = self.panel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('6'):GetLogicChild('nameLabel');
	self.selectImg.Margin = Rect(-68,220,0,0);    --274
	textBtn.Visibility = Visibility.Visible;
	if ActorManager.user_data.reward.servercreatestamp then
		local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
		local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 5 * 86400 - 3 * 3600);
		if	self:isInLevelActivity(5) then	
			levelAcDate.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
			levelEndTip.Visibility = Visibility.Visible;
		else
			levelAcDate.Text =  LANG_activityAllPanel_72;
			levelEndTip.Visibility = Visibility.Hidden;
		end
	end
	self:levelDrawRewardInit()

	--jp
	leaderEndTip.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:leaderDrawReward()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('7'):GetLogicChild('nameLabel');
	leaderPanel.Visibility = Visibility.Visible
	leaderTitlePic.Image = GetPicture('dynamicPic/leader_draw_title.ccz');
	leaderTipPic.Image = GetPicture('dynamicPic/leader_draw_tip.ccz');
	self.selectImg.Margin = Rect(-68,274,0,0);
	textBtn.Visibility = Visibility.Visible;
	if ActorManager.user_data.reward.servercreatestamp then
		local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
		local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 7 * 86400 - 3 * 3600); 
		if self:isInLevelActivity(7) then	
			leaderAcDate.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
			leaderEndTip.Visibility = Visibility.Visible;
		else
			leaderAcDate.Text =  LANG_activityAllPanel_72;
			leaderEndTip.Visibility = Visibility.Hidden;
		end
	end

	self:leaderDrawRewardInit()

	--jp
	leaderEndTip.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:ArenaFightPanel()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('5'):GetLogicChild('nameLabel');
	arenafightPanel.Visibility = Visibility.Visible
	arenafightTitlePic.Image = GetPicture('dynamicPic/arenareward_title.ccz');
	arenafightTipPic.Image = GetPicture('dynamicPic/arenareward_info.ccz');
	self.selectImg.Margin = Rect(-68,170,0,0);
	textBtn.Visibility = Visibility.Visible;
	local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
	local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 9 * 86400 - 3 * 3600); 
	if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 3 * 86400 - 3 * 3600 then
		endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 3 * 86400 - 3 * 3600); 
		arenafightAcDate.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
	elseif LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 6 * 86400 - 3 * 3600 then
		endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 6 * 86400 - 3 * 3600); 
		arenafightAcDate.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
	elseif LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 9 * 86400 - 3 * 3600 then
		endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 9 * 86400 - 3 * 3600); 
		arenafightAcDate.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		arenafightEndTip.Visibility = Visibility.Visible;
	else
		arenafightEndTip.Visibility = Visibility.Hidden;
		arenafightAcDate.Text = LANG_activityAllPanel_72;
	end

	--jp
	arenafightEndTip.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:StayTunded()
	self:HideAllActivityPanel();
	local textBtn = self.btnArea:GetLogicChild('stack'):GetLogicChild('8'):GetLogicChild('nameLabel');
	-- activityTipList[8]:Destroy();
	self.selectImg.Margin = Rect(-68,326,0,0);
	textBtn.Visibility = Visibility.Visible;
end

function OpenServiceRewardPanel:initDrawRewardTemplate(template, rewardType, rowData, status)
	local ctrl = template:GetLogicChild(0);
	local getBtn = ctrl:GetLogicChild('button');
	local finish = ctrl:GetLogicChild('get');
	local item = ctrl:GetLogicChild('item');
	local reward = ctrl:GetLogicChild('reward');
	local reward2 = ctrl:GetLogicChild('reward2');
	ctrl.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');

	getBtn.Tag = tonumber(rowData['id']);
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:onGetReward');
	
	if rowData then
		if #rowData['reward'] > 0 then
			local rewardTab = rowData['reward']
			local resid = rewardTab[1][1]
			local num = rewardTab[1][2]
			local contrl = customUserControl.new(item, 'itemTemplate');
			contrl.initWithInfo(resid, -1, 60, true);
			reward.Text = '10連ガチャ'..rowData['description']..'報酬';
			local name = resTableManager:GetValue(ResTable.item, tostring(resid),'name');
			reward2.Text = tostring(name)..'x'..num;
		end
	end

	--活动内可领取
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end
function OpenServiceRewardPanel:newInitRewardTemplate(template, rewardType, rowData, status, index)
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local getBtn = ctrl:GetLogicChild('getBtn');
	local finish = ctrl:GetLogicChild('finish');
	local lvImg	 = ctrl:GetLogicChild('lvImg');
	ctrl.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');

	getBtn.Tag = tonumber(rowData['id']);
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:onGetReward');
	
	if rowData then
		if #rowData['reward'] > 0 then
			local rewardTab = rowData['reward']
			for i=1,#rowData['reward'] do
				local resid = rewardTab[i][1]
				local num = rewardTab[i][2]
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end
	if rewardType == 2 then
		lvImg.Background = CreateTextureBrush('dynamicPic/openserver_wing_item_'..index..'.ccz','Welfare');
	elseif rewardType == 4 then
		lvImg.Background = CreateTextureBrush('dynamicPic/openserver_star_item_'..index..'.ccz','Welfare');
	end
	--活动内可领取
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end
function OpenServiceRewardPanel:initRewardTemplate(template, rewardType, rowData, status, isShowStar)
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local textLabel = ctrl:GetLogicChild('textLabel');
	local getBtn = ctrl:GetLogicChild('getBtn');
	local finish = ctrl:GetLogicChild('finish');
	local starPic = ctrl:GetLogicChild('starPic');
	local settlementLabel = ctrl:GetLogicChild('settlementLabel');
	local noSettlement = ctrl:GetLogicChild('noSettlement');
	
	getBtn.Tag = tonumber(rowData['id']);
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:onGetReward');
	
	if rowData then
		if rewardType == 3 then
			textLabel.Text = '        '..rowData['description'];
		else
			textLabel.Text = rowData['description'];
		end
		if #rowData['reward'] > 0 then
			local rewardTab = rowData['reward']
			for i=1,#rowData['reward'] do
				local resid = rewardTab[i][1]
				local num = rewardTab[i][2]
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end

	if rewardType == 3 or rewardType == 4 then
		settlementLabel.Visibility = Visibility.Hidden;
		noSettlement.Visibility = Visibility.Hidden;
	end

	if isShowStar then
		starPic.Visibility = Visibility.Visible;
	else
		starPic.Visibility = Visibility.Hidden;
	end

	--活动内可领取
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end

function OpenServiceRewardPanel:initDrawRewardPanel()
	self.drawRewardStackPanel:RemoveAllChildren();

	local index = 301;
	local drawCount = ActorManager.user_data.role.draw_ten_diamond;
	local str = ActorManager.user_data.role.draw_reward;
	local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	while rowData do
		--[[
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index - 300, index - 300);
			self:initRewardTemplate(rewardTemplate, 3, rowData, temp_str, false);
		end
		]]
		local rewardTemplate = uiSystem:CreateControl('WelfareTemplate');
		if str then
			local temp_str = string.sub(str, index - 300, index - 300);
			self:initDrawRewardTemplate(rewardTemplate, 3, rowData, temp_str);
		end
		self.drawRewardStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	end
end
 
function OpenServiceRewardPanel:initWingSelectRewardPanel()
	self.wingSelectStackPanel:RemoveAllChildren();
	local index = 201;
	local wingactivity = ActorManager.user_data.reward.wingactivity;
	local wingactivityreward = ActorManager.user_data.reward.wingactivityreward ;
	local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	local num = 1;
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('LevelDrawTemplate');
		local temp_str = 1;
		local isCanGot = bit.band(wingactivity, math.pow(2, rowData['value'] ));
		local isGot = bit.band(wingactivityreward, math.pow(2, rowData['value'] ));
		if isCanGot == 0 then
			temp_str = 3;
		else
			if isGot == 0 then
				temp_str = 1;
			else
				temp_str = 2;
			end
		end
	
		self:newInitRewardTemplate(rewardTemplate, 2, rowData, tostring(temp_str), num);

		self.wingSelectStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		num = num + 1;
		rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	end
end


function OpenServiceRewardPanel:initSevenpayRewardPanel()
    self.sevenpayStackPanel:RemoveAllChildren();
    local index = 801;
	local getType = true;
	local needindex = 801;
    local sevenpayStage = ActorManager.user_data.reward.limit_activity.limit_double_activity.sevenpay_stage;
    
    local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	local str = sevenpayStage;
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('LevelDrawTemplate1');
		if str then
			local temp_str = string.sub(str, index - 800, index - 800);
			self:initRewardTemplate(rewardTemplate, 8, rowData, temp_str, false);
			if temp_str ~= '2' and temp_str ~= '1' and getType then
				needindex = index;
				getType = false;
			end
		end

		self.sevenpayStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	end
	self.seveninfo3.Text = tostring(index - needindex);
end

function OpenServiceRewardPanel:initRoundStarRewardPanel()
	self.roundStarRewardStackPanel:RemoveAllChildren();

	local index = 401;
	local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	local str = ActorManager.user_data.role.round_stars_reward;
	local num = 1;
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('LevelDrawTemplate');
		if str then
			local temp_str = string.sub(str, index - 400, index - 400);
			self:newInitRewardTemplate(rewardTemplate, 4, rowData, temp_str, num);
		end

		self.roundStarRewardStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		num = num + 1;
		rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(index));
	end
end

function OpenServiceRewardPanel:levelAndLeaderInit(drawTemplate,rewardData)
	local tPanel = drawTemplate:GetLogicChild(0)
	local textLabel = tPanel:GetLogicChild('textLabel')
	local getBtn = tPanel:GetLogicChild('getBtn')
	getBtn.Visibility = Visibility.Hidden
	local finishLabel = tPanel:GetLogicChild('finish')
	finishLabel.Visibility = Visibility.Hidden
	local starPic = tPanel:GetLogicChild('starPic')
	starPic.Visibility = Visibility.Hidden
	textLabel.Size = Size(220,50)

	local tStackPanel = tPanel:GetLogicChild('stackPanel')
	tStackPanel.Margin = Rect(300,1,0,0)

	if rewardData then
		textLabel.Text = rewardData['description']
		for j = 1 , 3 do
			if rewardData['reward'][j] then
				local rewardid = rewardData['reward'][j][1]
				local rewardNumber = rewardData['reward'][j][2]
				local ts = customUserControl.new(tStackPanel:GetLogicChild(''..j), 'itemTemplate');
				ts.initWithInfo(rewardid, rewardNumber, 60, true);
			end
		end
	end
end

function OpenServiceRewardPanel:levelDrawRewardInit()
	if levelDrawStack then
		levelDrawStack:RemoveAllChildren();
	end
	local i = 1
	while true do
		local rewardData = resTableManager:GetValue(ResTable.newly_reward, tostring('60'..i), {'description','reward'})
		if rewardData == nil then
			break
		end
		local tControl = uiSystem:CreateControl('LevelDrawTemplate1')
		self:levelAndLeaderInit(tControl,rewardData)
		if levelDrawStack then
			levelDrawStack:AddChild(tControl)
		end
		i = i + 1
	end
	levelDesc.Text = LANG_OPENSERVER_Info_5;
end

function OpenServiceRewardPanel:arenafightDrawRewardInit()
	if arenafightRewardPanel then
		arenafightRewardPanel:RemoveAllChildren();
	end
	local i = 1
	while true do
		local rewardData = resTableManager:GetValue(ResTable.newly_reward, tostring('50'..i), {'reward','description'})
		if rewardData == nil then
			break
		end
		local tControl = uiSystem:CreateControl('LevelDrawTemplate1')
		local tRechargeBack = tControl:GetLogicChild(0)
		local tStackPanel = tRechargeBack:GetLogicChild('stackPanel')
		tRechargeBack:GetLogicChild('textLabel').Text =  rewardData['description'];
		tRechargeBack:GetLogicChild('starPic').Visibility = Visibility.Hidden;
		for j = 1 , 3 do
			if rewardData['reward'][j] then
			local rewardid = rewardData['reward'][j][1]
			local rewardNumber = rewardData['reward'][j][2]
			local ts = customUserControl.new(tStackPanel:GetLogicChild(''..j), 'itemTemplate');
			ts.initWithInfo(rewardid, rewardNumber, 60, true);
			end
		end
		
		if arenafightRewardPanel then
			arenafightRewardPanel:AddChild(tControl)
		end
		i = i + 1
	end
	arenafightDesc.Text = LANG_OPENSERVER_Info_4;
end

function OpenServiceRewardPanel:leaderDrawRewardInit()

	if leaderRewardPanel then
		leaderRewardPanel:RemoveAllChildren();
	end
	local i = 1
	while true do
		local rewardData = resTableManager:GetValue(ResTable.newly_reward, tostring('70'..i), {'description','reward'})
		if rewardData == nil then
			break
		end
		local tControl = uiSystem:CreateControl('LevelDrawTemplate1')
		self:levelAndLeaderInit(tControl,rewardData)
		if leaderRewardPanel then
			leaderRewardPanel:AddChild(tControl)
		end
		i = i + 1
	end
	leaderDesc.Text = LANG_OPENSERVER_Info_6;
end

function OpenServiceRewardPanel:onGetReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	local msg = {};
	msg.uid = ActorManager.user_data.uid;
	msg.index = tag;
	Network:Send(NetworkCmdType.req_open_service_reward, msg);
end

function OpenServiceRewardPanel:onGetRewardRet(msg)
	local flag = math.floor(msg.index/100);
	if flag == 2 then
		local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(msg.index));
		if rowData then
			ActorManager.user_data.reward.wingactivityreward = bit.bor(ActorManager.user_data.reward.wingactivityreward, math.pow(2, rowData['value'] ));
		end
		self:initWingSelectRewardPanel();
	elseif flag == 3 then

		local str = ActorManager.user_data.role.draw_reward;
		ActorManager.user_data.role.draw_reward = string.sub(str, 1, msg.index - 301) .. 2 .. string.sub(str, msg.index - 299, -1);
		self:initDrawRewardPanel();
	elseif flag == 4 then
		local str = ActorManager.user_data.role.round_stars_reward;
		ActorManager.user_data.role.round_stars_reward = string.sub(str, 1, msg.index - 401) .. 2 .. string.sub(str, msg.index - 399, -1);
		self:initRoundStarRewardPanel();
    elseif flag == 8 then 
            local str = ActorManager.user_data.reward.limit_activity.limit_double_activity.sevenpay_stage;
	    	ActorManager.user_data.reward.limit_activity.limit_double_activity.sevenpay_stage = string.sub(str, 1, msg.index - 801) .. 2 .. string.sub(str, msg.index - 799, -1);
    		self:initSevenpayRewardPanel();
	end

	local rowData = resTableManager:GetRowValue(ResTable.newly_reward, tostring(msg.index));
	for i = 1, #rowData['reward'] do
		local rewardTab = rowData['reward']	
		local resid = rewardTab[i][1];
		local num = rewardTab[i][2];
		ToastMove:AddGoodsGetTip(resid, num);
	end	
end

function OpenServiceRewardPanel:GetLeftCount(index)
--[[	local resNum = 0;
	if index == 1 then
		resNum = ActivityAllPanel:GetConLoginNum();
	elseif index == 2 then
		resNum = ActorManager.user_data.reward.first_yb;
	elseif index == 3 then
		resNum = ActivityAllPanel:GetLevelRewardNum();
	elseif index == 4 then
		if ActivityAllPanel:hasFightReward() then
			resNum = 1;
		end
	elseif index == 5 then
		if ActivityAllPanel:CanEatPizza() then
			resNum = 1;
		end	
	elseif index == 6 then
	--	resNum = ActivityAllPanel:GetRechargeNum();
	elseif index == 7 then
	elseif index == 8 then
		--	resNum = ActivityAllPanel:GetConsumeActivityNum();
	elseif index == 9 then
	else
	end

	return resNum;--]]
end

function OpenServiceRewardPanel:isInLevelActivity(tDay)
	local nowDate = LuaTimerManager:GetCurrentTimeStamp()
	if ActorManager.user_data.reward.servercreatestamp then
		local tc = ActorManager.user_data.reward.servercreatestamp
		if nowDate >= tc and nowDate <= tc + tonumber(tDay) * 86400 - 3 * 3600 then
			return true
		end
	end
	return false
end

--召唤排行
function OpenServiceRewardPanel:limitpubRewardInit()
	self.limitpubTipPic.Image = GetPicture('dynamicPic/pubrank.ccz');
	self.limitpubInfo.Text = LimitPub_Reward_1;
	self.panel:GetLogicChild('btnArea'):GetLogicChild('StackPanel'):GetLogicChild('9').Text = LimitPub_Reward_2;
	for i = 1 ,3  do
		self.limitpubTopPanel:GetLogicChild('img' .. i).Image = GetPicture('dynamicPic/limitpub_' .. i .. '.ccz');
		self.limitpubTopPanel:GetLogicChild('tip' .. i).Text = LimitPub_Reward_3;
	end
	self.limitpubTopPanel:GetLogicChild('rankBtn').Text = LimitPub_Reward_4;
	self.limitpubTopPanel:GetLogicChild('mytip').Text = LimitPub_Reward_5;
	self.limitpubRankPanel:GetLogicChild('title'):GetLogicChild('titlePanel').Text = LimitPub_Reward_6;
	self.limitpubRankPanel:GetLogicChild('rankLabel').Text = LimitPub_Reward_7;
	self.limitpubRankPanel:GetLogicChild('nameLabel').Text = LimitPub_Reward_8;
	self.limitpubRankPanel:GetLogicChild('countLabel').Text = LimitPub_Reward_9;

	self.limitpubTopPanel:GetLogicChild('rankBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:ShowPubRankPanel')
	self.limitpubRankPanel:GetLogicChild('exitBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:ClosePubRankPanel')
	self.limitpubtip.Visibility = Visibility.Hidden;

	local i = 1
	while true do
		local rewardData = resTableManager:GetValue(ResTable.newly_reward, tostring('90' .. i), {'reward','description'})
		if rewardData == nil then
			break
		end
		local tControl = uiSystem:CreateControl('LevelDrawTemplate1')
		local tRechargeBack = tControl:GetLogicChild(0)
		local tStackPanel = tRechargeBack:GetLogicChild('stackPanel')
		tRechargeBack:GetLogicChild('textLabel').Text =  rewardData['description'];
		tRechargeBack:GetLogicChild('starPic').Visibility = Visibility.Hidden;
		for j = 1 , 3 do
			if rewardData['reward'][j] then
			local rewardid = rewardData['reward'][j][1]
			local rewardNumber = rewardData['reward'][j][2]
			local ts = customUserControl.new(tStackPanel:GetLogicChild(''..j), 'itemTemplate');
			ts.initWithInfo(rewardid, rewardNumber, 60, true);
			end
		end
		
		if self.limitpubDrawStack then
			self.limitpubDrawStack:AddChild(tControl)
		end
		i = i + 1
	end
end

function OpenServiceRewardPanel:ReqlimitpubReward()
	self:ClosePubRankPanel();
	self:HideAllActivityPanel();
	self.limitpubPanel.Visibility = Visibility.Visible;	
	self.limitpubTopPanel:GetLogicChild('mycount').Text = tostring(ActorManager.user_data.reward.limit_activity_ext.limit_pub);
	local textBtn = self.panel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('9'):GetLogicChild('nameLabel');
	self.selectImg.Margin = Rect(-68,380,0,0);    --274
	textBtn.Text = LimitPub_Reward_2;
	textBtn.Visibility = Visibility.Visible;
	if ActorManager.user_data.reward.servercreatestamp then
		local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
		local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 3 * 86400);
		if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 3 * 86400 then
			self.limitpubDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
			self.limitpubtip.Visibility = Visibility.Hidden;
		else
			self.limitpubDesc.Text =  LANG_activityAllPanel_72;
			self.limitpubtip.Visibility = Visibility.Visible;
		end
	end


	if LuaTimerManager:GetCurrentTime() - self.reqlimitpubtime > 3000 then
		Network:Send(NetworkCmdType.req_pub_rank_t, {});
		self.reqlimitpubtime = LuaTimerManager:GetCurrentTime();
	end

	--jp
	self.limitpubtip.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:limitpubReward(msg)
	for index = 1,10 do
		local userinfo = msg.users[index];
		if index <= 3 then
			if userinfo and userinfo.count >= 60 then
				self.limitpubTopPanel:GetLogicChild('name' .. index).Text = userinfo.nickname;
				self.limitpubTopPanel:GetLogicChild('number' .. index).Text = tostring(userinfo.count);
			else
				self.limitpubTopPanel:GetLogicChild('name' .. index).Text = '';
				self.limitpubTopPanel:GetLogicChild('number' .. index).Text = '';
			end
		end

		if userinfo and userinfo.count >= 60 then
			self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('name').Text  = userinfo.nickname;
			self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('count').Text  = tostring(userinfo.count);
			if userinfo.vip and userinfo.vip > 0 then
				local vipLabel = vipToImage(userinfo.vip);
				vipLabel.Margin = Rect(0,0,0,0);
				vipLabel.Horizontal = ControlLayout.H_CENTER;
				vipLabel.Vertical   = ControlLayout.V_CENTER;
				vipLabel:SetScale(0.8, 0.8);
				self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('vipPanel'):AddChild(vipLabel);
				self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('vipPanel').Visibility = Visibility.Visible;
			else
				self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('vipPanel').Visibility = Visibility.Hidden;
			end
		else
			self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('name').Text  = '';
			self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('count').Text  = '';
			self.limitpubRankPanel:GetLogicChild('rank' .. index):GetLogicChild('vipPanel').Visibility = Visibility.Hidden;
		end
	end
end

function OpenServiceRewardPanel:GrowUpReward()
	self:HideAllActivityPanel();
	self.growUpPanel.Visibility = Visibility.Visible;
	local textBtn = self.panel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('10'):GetLogicChild('nameLabel');
	--self.selectImg.Margin = Rect(-68,170,0,0);
	--textBtn.Visibility = Visibility.Visible;
	self.growUpTitlePic.Image = GetPicture('dynamicPic/openserver_title_4.ccz');		-- title图片
	self.growUpHeroPic.Image = GetPicture('navi/H023_navi_01.ccz')		-- 英雄图片

	if ActorManager.user_data.reward.servercreatestamp then
		local begintc = os.date("*t", ActorManager.user_data.reward.servercreatestamp);
		local endtc = os.date("*t", ActorManager.user_data.reward.servercreatestamp + 7 * 86400);
		if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp + 7 * 86400 then
			self.growUpDesc.Text = string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour); -- 时间
			--self.growUpDate.Visibility = Visibility.Visible;
		else
			self.growUpDesc.Text = LANG_activityAllPanel_72;
			--self.growUpDate.Visibility = Visibility.Hidden;
		end
		self.startTime.Text = tostring(begintc.year..'/'..begintc.month..'/'..begintc.day..'/'..begintc.hour..'時');
		self.endTime.Text = tostring(endtc.year..'/'..endtc.month..'/'..endtc.day..'/'..endtc.hour..'時');
	end
	Network:Send(NetworkCmdType.req_grow_up);
end

function OpenServiceRewardPanel:GrowUpRewardInit(msg)
	if msg.id == 0 then 
		msg.id = 1101
	end
	if self.growUpStackPanel then 
		self.growUpStackPanel:RemoveAllChildren();
	end
	getButtonArr = {}
	for i = 1, 7 do

		local loadPanel = function(data, val, index)
			local panel = uiSystem:CreateControl('Panel');
			panel.Size = Size(370, 23);
			for k=1,2 do
				--local str = LANG_openTask_1..index..'  '..data
				local str = '·  '..data
				if k == 2 then
					local doNum = 0
					if (1100+i) < msg.id then
						doNum = val
					elseif (1100+i) == msg.id then 
						doNum = msg['task'..index]
					end
					str = '('..doNum..'/'..val..')'
					if tonumber(doNum) >= tonumber(val) then
						local img = uiSystem:CreateControl('ImageElement');
						img.Size = Size(15, 15)
						img.AutoSize = false;
						img.Vertical = ControlLayout.V_CENTER
						img.Horizontal = ControlLayout.H_RIGHT;
						img.Pick = false
						img.Image = GetPicture('qiandao/duihao.ccz')
						panel:AddChild(img)
					end
				end
				panel:AddChild(self:addInfoSingle(str,k))
			end
			return panel
		end

		local rewardData = resTableManager:GetRowValue(ResTable.open_task, tostring(1100+i))
		local rewardArr = rewardData['reward']
		local tControl = uiSystem:CreateControl('GrowUpTemplate')
		local temp = tControl:GetLogicChild(0)
		local title = temp:GetLogicChild('daysLabel')
		local getBtn = temp:GetLogicChild('getBtn')		-- 领完
		temp:GetLogicChild('titleImg').Image = GetPicture('dynamicPic/openserver_up_item_'..i..'.ccz');
		temp:GetLogicChild('bg').Image = GetPicture('Welfare/Welfare_item_bg.ccz');
		temp:GetLogicChild('panel').Background = CreateTextureBrush('dynamicPic/openserver_up_item_bg.ccz','Welfare');
		getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:getGrowUpReward');
		if (1100+i) == msg.id then
			getBtn.Tag = msg.id
		end
		local finish = temp:GetLogicChild('finish')		-- 领完
		local taskListPanel = temp:GetLogicChild('taskListPanel')
		local iconPanel = temp:GetLogicChild('iconPanel')
		title.Text = rewardData['name']
		for j=1,3 do
			taskListPanel:AddChild(loadPanel(rewardData['description'..j],rewardData['value'..j],j))
			if #rewardData['reward'] > 0 then 
				local contrl = customUserControl.new(iconPanel:GetLogicChild(''..j), 'itemTemplate');
				contrl.initWithInfo(rewardArr[j][1], rewardArr[j][2], 70, true);
			end
		end
		-- 是否领取
		if (1100+i) < msg.id then
			getBtn.Visibility = Visibility.Hidden
			finish.Visibility = Visibility.Visible
		elseif (1100+i) == msg.id then 
			if msg.value == 0 then 
				getBtn.Visibility = Visibility.Visible
				getBtn.Enable = false
				finish.Visibility = Visibility.Hidden
			elseif msg.value == 1 then 
				getBtn.Visibility = Visibility.Visible
				getBtn.Enable = true
				finish.Visibility = Visibility.Hidden
			else
				getBtn.Visibility = Visibility.Hidden
				finish.Visibility = Visibility.Visible
			end
		else
			getBtn.Visibility = Visibility.Hidden
			finish.Visibility = Visibility.Hidden
		end
		table.insert(getButtonArr, temp)
		self.growUpStackPanel:AddChild(temp)
	end
end

-- 领取奖励请求
function OpenServiceRewardPanel:getGrowUpReward(args)
	local sender = UIControlEventArgs(args)
	local msg = {}
	msg.opentaskid = sender.m_pControl.Tag
	Network:Send(NetworkCmdType.req_grow_up_get, msg);
end

-- 领取奖励返回
function OpenServiceRewardPanel:growUpRewardReq(msg)
	local id = msg.opentaskid - 1101
	getButtonArr[id]:GetLogicChild('getBtn').Visibility = Visibility.Hidden
	getButtonArr[id]:GetLogicChild('finish').Visibility = Visibility.Visible

	local rowData = resTableManager:GetRowValue(ResTable.open_task, tostring(msg.opentaskid-1));
	for i = 1, #rowData['reward'] do
		local rewardTab = rowData['reward']	
		local resid = rewardTab[i][1];
		local num = rewardTab[i][2];
		ToastMove:AddGoodsGetTip(resid, num);
	end	
	getButtonArr[id+1]:GetLogicChild('getBtn').Visibility = Visibility.Visible
	getButtonArr[id+1]:GetLogicChild('getBtn').Enable = false
	getButtonArr[id+1]:GetLogicChild('finish').Visibility = Visibility.Hidden

end

-- 初始init
function OpenServiceRewardPanel:growUpRewardInitReq(msg)
	local taskInitInfo = {}
	taskInitInfo.id = msg['opentasklv']
	taskInitInfo.task1 = msg['opentask_step1']
	taskInitInfo.task2 = msg['opentask_step2']
	taskInitInfo.task3 = msg['opentask_step3']
	taskInitInfo.value = msg['opentask_reward']
	self:GrowUpRewardInit(taskInitInfo)
end

-- 实时返回
function OpenServiceRewardPanel:growUpRewardRealTimeReq(msg)
	local taskInitInfo = {}
	taskInitInfo.id = msg['opentask_level']
	taskInitInfo.task1 = msg['opentask_stage_one']
	taskInitInfo.task2 = msg['opentask_stage_two']
	taskInitInfo.task3 = msg['opentask_stage_three']
	taskInitInfo.value = msg['opentask_reward']
	for k,v in pairs(taskInitInfo) do
		print(k,v)
	end
	self:GrowUpRewardInit(taskInitInfo)
end

function OpenServiceRewardPanel:getErrorReq( msg )
	if msg.code == 3500 then 
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_growUp_error_1);
	elseif msg.code == 3501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_growUp_error_2);
	elseif msg.code == 3502 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_growUp_error_3);
	end
end

function OpenServiceRewardPanel:addInfoSingle(info, ver)
	local label = uiSystem:CreateControl('Label')
	label.Vertical = ControlLayout.V_CENTER
	label.Margin = Rect(0, 0, 0, 0)
	label.Size = Size(340, 25)
	if ver == 1 then
		label.TextAlignStyle = TextFormat.MiddleLeft
	else
		label.TextAlignStyle = TextFormat.MiddleRight
	end
	label.Horizontal = ControlLayout.H_LEFT
	label.Text = info
	label.Font = uiSystem:FindFont('huakang_17_noborder')
	label.TextColor = QuadColor(Color(0, 14, 60, 255))
	return label
end

function OpenServiceRewardPanel:ShowPubRankPanel()
	self.limitpubRankPanel.Visibility = Visibility.Visible;
end

function OpenServiceRewardPanel:ClosePubRankPanel()
	self.limitpubRankPanel.Visibility = Visibility.Hidden;
end

function OpenServiceRewardPanel:LimitPubChange(msg)
	ActorManager.user_data.reward.limit_activity_ext.limit_pub = msg.now;
	self.reqlimitpubtime = self.reqlimitpubtime - 3000;
end
