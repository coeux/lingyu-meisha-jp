--LoginRewardPanel.lua
--=============================================================================================
--捐献界面

LoginRewardPanel =
{
	gotReward = {};
	rewardIndex = 0;
	loginCount = {};
};

--初始化
function LoginRewardPanel:InitPanel(desktop)
	self.gotReward = {};
	self.rewardIndex = 0;
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('loginRewardPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.titlePic = self.panel:GetLogicChild('rewardPanel'):GetLogicChild('titlePic');
	self.closeBtn = self.panel:GetLogicChild('close');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LoginRewardPanel:onClose');
	self.scroll = self.panel:GetLogicChild('rewardPanel'):GetLogicChild('scroll');
	self.stack = self.scroll:GetLogicChild('stack');
	self.tip = self.panel:GetLogicChild('rewardPanel'):GetLogicChild('tip');
	self.tip.Text = LANG_login_reward_tip;

	self.panel.Visibility = Visibility.Hidden;
end

--销毁
function LoginRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

function LoginRewardPanel:onReqGetReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	if tag < 0 then
		return;
	end

	local flag = 600 + tag;
	self.rewardIndex = tag;
	Network:Send(NetworkCmdType.req_reward, {flag = flag});
end

function LoginRewardPanel:onShow()
	self.panel.Background = CreateTextureBrush('Welfare/welfare_diban.jpg','Welfare');
	self.titlePic.Image = GetPicture('Welfare/welfare_conlogin_title.ccz');
	local bgTop = self.panel:GetLogicChild(0);
	bgTop.Background = CreateTextureBrush('Welfare/welfare_top.ccz','Welfare');
	-- 0：不可领取	1：可以领取 2：已领取  
	self.stack:RemoveAllChildren();

	local rowNum = resTableManager:GetRowNum(ResTable.login_count);
	for i = 1, rowNum do
		local welfareItem = customUserControl.new(self.stack, 'WelfareTemplate');
		local tag = self.loginCount[i].login_count;
		local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(tag));

		local loginStatus = 0;
		local str = ActorManager.user_data.reward.loginrewards;
		if str then
			local index = tonumber(string.sub(str, tag, tag));
			if index == 0 then
				loginStatus = 0;
			elseif index == 1 then
				loginStatus = 1;
			elseif index == 2 then
				loginStatus = -1;
			end
		end

		local showWeapon = false;
		if (rowData['count2'] ~= 0) then
			showWeapon = true;
		end

		welfareItem.initWithId(tag, showWeapon);
		--initBtn的loginStatus的值： 0不可领取，1可领取，-1已经领取
		welfareItem.initBtn(loginStatus, self.gotReward, tag, 'LoginRewardPanel:onReqGetReward');
	end

	if TomorrowRewardPanel.isGetReward then
		if TomorrowRewardPanel.isShowMore then
			MainUI:Push(self);
			TomorrowRewardPanel.isShowMore = false;
		end
	else
		MainUI:Push(self);
	end
end

--显示
function LoginRewardPanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
end

--隐藏
function LoginRewardPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function LoginRewardPanel:onClose()
	TomorrowRewardPanel.isShowMore = false;
	MainUI:Pop();
end

function LoginRewardPanel:onRetGetReward(flag, dismess)
	table.insert(self.gotReward, self.rewardIndex);
	self:onShow();

	print("LoginRewardPanel : self.rewardIndex = ", self.rewardIndex);
	local itemData = resTableManager:GetRowValue(ResTable.login_count, tostring(self.rewardIndex));
	if (itemData['heroid'] ~= 0) then
		if dismess == 1 then
			--如果获得英雄，显示是否已分解为碎片
			local pieceid, piecenum = ActorManager:ShowTipOfHeroToPiece(actorID);
			ToastMove:AddGoodsGetTip(pieceid, piecenum);
		else
			local msg = {};
			msg.resid = actorID;
			ActivityAllPanel:OnGetGoldHero(msg);
		end
	elseif (itemData['count2'] ~= 0) then
		ToastMove:AddGoodsGetTip(itemData['item2'], itemData['count2']);
	else
		ToastMove:AddGoodsGetTip(itemData['item1'], itemData['count1']);
	end

end
