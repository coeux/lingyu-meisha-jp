--TomorrowRewardPanel.lua
--=============================================================================================
--捐献界面

TomorrowRewardPanel =
{
	isGetReward = false;
	isShowMore = false;
	receiveDay = {};
	firstEnter = false;
	fromRoleLevelUpPanel = false;
};

--初始化
function TomorrowRewardPanel:InitPanel(desktop)
	--控件初始化
	self.isGetReward = false;
	self.firstEnter = false;
	self.fromRoleLevelUpPanel = false;
	self.receiveDay = {}
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('tomorrowRewardPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.getBtn = self.panel:GetLogicChild('getBtn');
	self.getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TomorrowRewardPanel:onGetReward');
	self.getTomorrowBtn = self.panel:GetLogicChild('getTomorrowBtn');
	self.getTomorrowBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TomorrowRewardPanel:onClose');
	self.closeBtn = self.panel:GetLogicChild('closeBtn');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TomorrowRewardPanel:onClose');
	self.moreBtn = self.panel:GetLogicChild('moreBtn');
	self.moreBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TomorrowRewardPanel:onShowLoginRewardPanel');
	self.titlePic = self.panel:GetLogicChild('titlePic');
	self.wingPic = self.panel:GetLogicChild('wingPic');
	self.personPic = self.panel:GetLogicChild('personPic');
	self.tomorrowLabel = self.panel:GetLogicChild('tomorrowLabel');
	self.describeLabel = self.panel:GetLogicChild('describeLabel');
	self.item = self.panel:GetLogicChild('item');
	self.secondDayPic = self.panel:GetLogicChild('secondDay');
	self.secondDaylbl = self.panel:GetLogicChild('secondDayLabel');
	self.secondDayPic.Visibility = Visibility.Hidden;
	self.secondDaylbl.Visibility = Visibility.Hidden;
	self.dayLabel = self.panel:GetLogicChild('dayLabel');

	self.panel.Background = CreateTextureBrush('dynamicPic/login_reward_panel.ccz','dynamicPic');
	self.titlePic.Image = GetPicture('dynamicPic/login_reward_today.ccz');
	self.wingPic.Image = nil --GetPicture('dynamicPic/login_reward_wing.ccz');
	self.personPic.Image = GetPicture('navi/H022_navi_02.ccz');

	self.tomorrowLabel.Visibility = Visibility.Hidden;
	self.getTomorrowBtn.Visibility = Visibility.Hidden;
	-- self.getBtn.Visibility = Visibility.Hidden;
	self.panel.Visibility = Visibility.Hidden;

	self:getReceiveDay();
end

function TomorrowRewardPanel:onShowLoginRewardPanel()
	self.isShowMore = true;
	ActivityAllPanel:OnShow();
	self:onClose();
end

--销毁
function TomorrowRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end
--点击领取礼物
function TomorrowRewardPanel:onGetReward()
	local login_days = ActorManager.user_data.reward.lg_days;
	if login_days then
		local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(self.receiveDay[1]));
		if rowData then
			if self.receiveDay[1] < 0 then
				return;
			end

			ActivityAllPanel.rewardIndex = self.receiveDay[1];
			self.isGetReward = true;
			local flag = 600 + self.receiveDay[1];
			Network:Send(NetworkCmdType.req_reward, {flag = flag});
		end
	end
end

function TomorrowRewardPanel:getRewardStatus(days)
	local count = 1;
	local str = ActorManager.user_data.reward.loginrewards;
	local temp = string.sub(str, days, days);
	if temp and 2 == tonumber(temp) then
		count = 2;
	elseif temp and 1 == tonumber(temp) then
		count = 1;
	end

	return count;
end

function TomorrowRewardPanel:onShowRewardInfo(index, isToday)
	if UserGuidePanel:GetInGuilding() then
		self.firstEnter = false;
		return                   
    end        
	--改变图片
	if ActorManager.user_data.reward.loginrewards then
		if index > 7 then
			self.wingPic.Image = GetPicture('dynamicPic/login_reward_rings.ccz');
		elseif index == 7 then
			self.personPic.Image = GetPicture('navi/H013_navi_01.ccz');
			if self:getRewardStatus(7) == 2 then
				self.wingPic.Image = GetPicture('dynamicPic/login_reward_rings.ccz');
			else
				self.wingPic.Image = GetPicture('dynamicPic/login_reward_role.ccz');
				self.personPic.Image = GetPicture('navi/H013_navi_01.ccz');
			end
		elseif index > 5 then
			self.wingPic.Image = GetPicture('dynamicPic/login_reward_role.ccz');
			self.personPic.Image = GetPicture('navi/H013_navi_01.ccz');
		elseif index == 5 then
			if self:getRewardStatus(5) == 2 then
				self.wingPic.Image = GetPicture('dynamicPic/login_reward_role.ccz');
				self.personPic.Image = GetPicture('navi/H013_navi_01.ccz');
			else
				self.wingPic.Image = GetPicture('dynamicPic/login_reward_ring.ccz');
			end
		elseif index > 2 then
			self.wingPic.Image = GetPicture('dynamicPic/login_reward_ring.ccz');
		elseif index == 2 then
			if self:getRewardStatus(2) == 2 then
				self.wingPic.Image = GetPicture('dynamicPic/login_reward_ring.ccz');
			else
				self.wingPic.Image = nil --GetPicture('dynamicPic/login_reward_wing.ccz');
			end
		end
	end

	if ActorManager.user_data.reward.lg_days and ActorManager.user_data.reward.lg_days == 14  and index == 14 then
		local str = ActorManager.user_data.reward.loginrewards;
		if str then
			local temp = string.sub(str, 14, 14);
			if tonumber(temp) == 2 then
				self.getBtn.Enable = false;
				self.getTomorrowBtn.Enable = false;
			end
		end
	end

	if isToday then
		self.dayLabel.Text = LANG_tomorrow_reward_4;
		self.getBtn.Visibility = Visibility.Visible;
		self.getTomorrowBtn.Visibility = Visibility.Hidden;
		self.titlePic.Image = GetPicture('dynamicPic/login_reward_today.ccz');
	else
		self.dayLabel.Text = LANG_tomorrow_reward_5;
		self.getBtn.Visibility = Visibility.Hidden;
		self.getTomorrowBtn.Visibility = Visibility.Visible;
		self.titlePic.Image = GetPicture('dynamicPic/login_reward_tomorrow.ccz');
	end

	if index == 2 then
		self.secondDayPic.Visibility = Visibility.Visible;
		--self.secondDayPic.Image = GetPicture('dynamicPic/tomorrow_bg.ccz');
		--self.secondDaylbl.Visibility = Visibility.Visible;
		self.secondDaylbl.Text = LANG_tomorrow_reward_3;
	else
		self.secondDayPic.Visibility = Visibility.Hidden;
		--self.secondDaylbl.Visibility = Visibility.Hidden;
	end

	--显示奖励物品
	local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(index));
	if not rowData then
		return;
	end
	local name = resTableManager:GetValue(ResTable.item, tostring(rowData['item1']), 'name');
	if rowData then
		local item = customUserControl.new(self.item, 'itemTemplate');
		item.initWithInfo(tonumber(rowData['item1']),tonumber(rowData['count1']),65,true);
	end
	if isToday then
		self.describeLabel.Text = index .. LANG_tomorrow_reward_2 ..name..'x'..rowData['count1'];
	else
		self.describeLabel.Text = LANG_tomorrow_reward_6 ..name..'x'..rowData['count1']..LANG_tomorrow_reward_7;
	end

	MainUI:Push(self);
end
--index表示当前领取奖励的时间
function TomorrowRewardPanel:nextCanDrawRewardDay(index)
	local count = 14;
	for i= index + 1,14 do
		local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(i));
		if rowData then
			count = i;
			break;
		end
	end
	
	return count	
end

--显示
function TomorrowRewardPanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene()
end

--隐藏
function TomorrowRewardPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)
	--print('tomorr--->'..tostring(self.fromRoleLevelUpPanel));
	--print('first--->'..tostring(self.firstEnter));
	if self.firstEnter or self.fromRoleLevelUpPanel then
		DailySignPanel:firstEnterFromTomm();
		self.fromRoleLevelUpPanel = false;
	end
	self.firstEnter = false;
	--[[
	if ActorManager.user_data.extra_data.vip_stamp < ActorManager.user_data.extra_data.cur_0_stamp then
		VipPanel:onShowVipPanel();
	end
	]]
end

function TomorrowRewardPanel:onClose()
	MainUI:Pop();
end

function TomorrowRewardPanel:isGetAllReward()
	local str = ActorManager.user_data.reward.loginrewards;
	local count = 0;
	local YN = false;
	if str then
		for i=1,14 do
			local temp = string.sub(str, i, i);
			if temp and 2 == tonumber(temp) then
				count = count + 1;
			else
				break;
			end
		end
		if count == 14 then
			YN = true;
		end
	end
	return YN;
end

function TomorrowRewardPanel:isCanGetReward()
	local str = ActorManager.user_data.reward.loginrewards;
	local count = 0;
	local YN = false;
	if str then
		for i=1,#str do
			local temp = string.sub(str, i, i);
			if temp and 1 == tonumber(temp) then
				count = count + 1;
			end
		end
		if count > 0 then
			YN = true;
		end
	end
	return YN;
end

function TomorrowRewardPanel:getReceiveDay()
	self.receiveDay = {};

	local str = ActorManager.user_data.reward.loginrewards;
	if str then
		for i=1,#str do
			local temp = string.sub(str, i, i);
			if temp and 1 == tonumber(temp) then
				table.insert(self.receiveDay, i);
			end
		end
	end
end
function TomorrowRewardPanel:firstShow()
	if not ActivityAllPanel:IsShow() then
		--判断今日是否有登录奖励，奖励是否已经领取
		local index = ActorManager.user_data.reward.lg_days;
		-- 0表示今天不是第一次登录,1表示今天第一次登录
		local isShowToday = 1;
		if ActorManager.user_data.reward.isshowtoday then
			isShowToday = ActorManager.user_data.reward.isshowtoday;
		end
		if index then
			self.firstEnter = true;
			if #TomorrowRewardPanel.receiveDay > 0 then
				local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));

				if rowData1 and  isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 then
					TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
				elseif isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 then  --明天有登录奖励
					local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
					TomorrowRewardPanel:onShowRewardInfo(count, false);
				end
			elseif isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 and not TomorrowRewardPanel:isGetAllReward() then 
				local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
				TomorrowRewardPanel:onShowRewardInfo(count, false);
			end
			ActorManager.user_data.reward.isshowtoday = 0;
		end
	end
end
function TomorrowRewardPanel:showTomorrowReward()
	--弹出次日奖励
	local index = ActorManager.user_data.reward.lg_days;
	if index then
		TomorrowRewardPanel.fromRoleLevelUpPanel = true;
		if #TomorrowRewardPanel.receiveDay > 0 then
			local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));
			if rowData1 then
				TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
			else
				local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
				TomorrowRewardPanel:onShowRewardInfo(count, false);
			end
		else
			--获得下一次可怜领取奖励的时间
			local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
			TomorrowRewardPanel:onShowRewardInfo(count, false);
		end
	end
end