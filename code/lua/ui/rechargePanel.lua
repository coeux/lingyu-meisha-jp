--rechargePanel.lua
--==============================================================================================
--充值界面

RechargePanel =
	{
		baseID = 10100;
		rechargeBaseID = 10101;
		chargeCount = 6;
	};
	
--变量
local mCardLeftDays;		--领取月卡的剩余天数
local mCardLeftCount;		--今天还剩余多少次可以领取月卡
local rechargeList;
local rechargeid;
local vipStackPanel;

--控件
local mainDesktop;
local rechargePanel;
local rechargePanelList = {};  --任务列表
local mCardPanel;
local closeBtn;
local diamondValue;
local scrollPanel;

local getRi = 
{
	[1] = 0,
	[2] = 0,
	[3] = 120,
	[4] = 320,
	[5] = 700,
	[6] = 1500
}
--初始化
function RechargePanel:InitPanel(desktop)
	--变量初始化
	mCardLeftDays = 0;
	mCardLeftCount = 0;
	rechargeList = {};
	rechargeid = 0;

	--界面初始化
	mainDesktop = desktop;
	rechargePanel = Panel(desktop:GetLogicChild('rechargePanel'));
	rechargePanel:IncRefCount();
	
	closeBtn 		= rechargePanel:GetLogicChild('close');
	diamondValue 	= rechargePanel:GetLogicChild('diamondValue');
	scrollPanel		= rechargePanel:GetLogicChild('scrollPanel');
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent','RechargePanel:onClose');

	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', diamondValue, 'Text');					--绑定水晶

	self.chargeCount = 6;
	
	for index = 1, self.chargeCount do
		self:initCrystalPanel(index);
	end
	rechargePanel:GetLogicChild('btn_brush'):SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onGPlusClic');
end

function RechargePanel:onGPlusClic()
	if platformSDK.m_System == "iOS" then
		appFramework:OpenUrl('http://qmax.co.jp/page/tokushoho/');
	elseif platformSDK.m_System == "Android" then
		platformSDK:GetExtraInfo("url", "http://qmax.co.jp/page/tokushoho/");
	end
end

--销毁
function RechargePanel:Destroy()
	uiSystem:UnBind(ActorManager.user_data, 'rmb', diamondValue, 'Text');							--取消绑定水晶
	rechargePanel:DecRefCount();
	rechargePanel = nil;
end

--显示
function RechargePanel:Show()
	mainDesktop:DoModal(rechargePanel);

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(rechargePanel, StoryBoardType.ShowUI3);
	else
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(rechargePanel, StoryBoardType.ShowUI1);
	end
	 GodsSenki:LeaveMainScene()
end

--隐藏
function RechargePanel:Hide()
	mainDesktop:UndoModal();
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI消失时的效果
		StoryBoard:HideUIStoryBoard(rechargePanel, StoryBoardType.HideUI3, 'StoryBoard::OnPopUI');	
	else
		--增加UI消失时的效果
		StoryBoard:HideUIStoryBoard(rechargePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

--初始化水晶面板
function RechargePanel:initCrystalPanel(index)
	local tmpPanel = {};
	tmpPanel.panel = Panel(scrollPanel:GetLogicChild(tostring(index)));
	--tmpPanel.diamondCount 	= tmpPanel.panel:GetLogicChild('diamondCount');
	tmpPanel.rmb 			= tmpPanel.panel:GetLogicChild('money');
	tmpPanel.first 			= tmpPanel.panel:GetLogicChild('first');
	tmpPanel.noFirst		= tmpPanel.panel:GetLogicChild('noFirst');
	table.insert(rechargePanelList, tmpPanel);

	tmpPanel.panel.Tag = index;
	tmpPanel.panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RechargePanel:onRecharge');
end
--============================================================================================
--向服务器请求月卡信息
function RechargePanel:ApplyMCardInfo()
	Network:Send(NetworkCmdType.req_mcard_info, {}, true);
end

--接收月卡信息
function RechargePanel:ReceiveMCardInfo(msg)
	--[[
	mCardLeftDays = msg.mcardn;
	mCardLeftCount = msg.todayn;

	if rechargePanel.Visibility == Visibility.Visible then
		self:RefreshMCardPanel();
	end
	]]
	--if mCardLeftDays >= 30 then
	--	--显示月卡按钮
	--	--PromotionPanel:ShowMonthCardButton();
	--	mCardPanel.panel:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'RechargePanel:onRecharge');
	--	--mCardPanel.panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RechargePanel:ApplyMCardReward');
	--else
	--	--mCardPanel.panel:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'RechargePanel:ApplyMCardReward');
	--	mCardPanel.panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RechargePanel:onRecharge');
	--end
end

--向服务器申请月卡奖励
function RechargePanel:ApplyMCardReward()
	Network:Send(NetworkCmdType.req_mcard_reward, {});
end

--获取月卡奖励
function RechargePanel:onReceiveMCardReward(msg)
	mCardLeftCount = 0;
	PromotionPanel:HideMonthCardButton();		--隐藏月卡按钮
	local contents = {};
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_rechargePanel_9});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_rechargePanel_8; color = Configuration.BlueColor});
	MessageBox:ShowDialog(MessageBoxType.Ok, contents);
end

--获取月卡剩余天数
function RechargePanel:GetMCardLeftDays()
	return mCardLeftDays;
end	

--获取今天月卡可领取次数
function RechargePanel:GetMCardLeftCounts()
	return mCardLeftCount;
end

--刷新月卡面板
function RechargePanel:RefreshMCardPanel()
	if mCardLeftDays > 0 then
		mCardPanel.info1.Text = LANG_rechargePanel_2;
		mCardPanel.info2.Visibility = Visibility.Visible;
		mCardPanel.infoIcon.Visibility = Visibility.Visible;
		mCardPanel.info3.Visibility = Visibility.Visible;
		mCardPanel.info3.Text = LANG_rechargePanel_3 .. mCardLeftDays .. LANG_rechargePanel_4;
	else
		--当前没有买月卡
		mCardPanel.info1.Text = LANG_rechargePanel_5;
		mCardPanel.info2.Visibility = Visibility.Visible;
		mCardPanel.infoIcon.Visibility = Visibility.Visible;
		mCardPanel.info3.Visibility = Visibility.Hidden;
	end
end

--============================================================================================
--事件
--关闭
function RechargePanel:onClose()
	MainUI:Pop();
end

--请求充值界面信息
function RechargePanel:onShowRechargePanel()
	--MessageBox:ShowDialog(MessageBoxType.Ok, '未開放');

--	MainUI:onWorldClick();
	if MainUI:IsHaveMenu(RechargePanel) then
		--已经有充值窗口打开了
		local loop = true;
		while loop do
			local topMenu = MainUI:GetTopMenu();
			MainUI:Pop();
			
			if topMenu == RechargePanel then
				loop = false;
			end
		end
	end
	
	local msg = {};
	msg.domain = platformSDK.m_Platform;
	Network:Send(NetworkCmdType.req_yb_repo, msg);
	
end

--显示充值界面
function RechargePanel:onShow(msg)
	rechargeList = cjson.decode(msg.repo).contain;

	for index = 1, self.chargeCount do
		rechargePanelList[index].panel.Visibility = Visibility.Hidden;
		--mCardPanel.panel.Visibility = Visibility.Hidden;
	end


	for index,info in pairs(rechargeList) do
		if tonumber(index) <= self.baseID + self.chargeCount then

			local panelIndex = tonumber(index) - self.baseID;
			local pos = tonumber(index) -self.rechargeBaseID;
			if (panelIndex == 10) then
				panelIndex = 9;
			end

			--rechargePanelList[panelIndex].diamondCount.Text = tostring(info.cristal);
			rechargePanelList[panelIndex].rmb.Text = info.rmb..LANG_moneySign;
			--[[
			if '0' == info.bonus or nil == info.bonus then
				rechargePanelList[panelIndex].flag.Visibility = Visibility.Hidden;
				rechargePanelList[panelIndex].percent.Visibility = Visibility.Hidden;
			else
				rechargePanelList[panelIndex].flag.Visibility = Visibility.Visible;
				rechargePanelList[panelIndex].percent.Visibility = Visibility.Visible;
				rechargePanelList[panelIndex].percent.Text = '+' .. info.bonus;
			end	
			]]
			if self:isFirstPay(pos) then
				rechargePanelList[panelIndex].first.Visibility = Visibility.Visible;
				rechargePanelList[panelIndex].first:GetLogicChild('firstTitle').Text = string.format(LANG_first_recharge_tip,info.cristal,info.first_reward);
					local firstImg = rechargePanelList[panelIndex].first:GetLogicChild('firstImg');
					firstImg:RemoveAllChildren();
					pveArmature=PlayEffect('fuben2_output/',Rect(-20,2,0,0),'zhandouli',firstImg)
  					pveArmature:SetScale(2.8,1);
  				rechargePanelList[panelIndex].noFirst.Visibility = Visibility.Hidden;
			else
				rechargePanelList[panelIndex].noFirst:GetLogicChild('noFirstTitle').Text = string.format(LANG_noFirst_recharge_tip,info.cristal);
				rechargePanelList[panelIndex].noFirst:GetLogicChild('noFirstTitle1').Text = (getRi[panelIndex] ~= 0) and string.format(LANG_noFirst1_recharge_tip,tostring(getRi[panelIndex])) or '';
				print('index->'..tostring(panelIndex)..' getRi->'..tostring(getRi[panelIndex]));
				rechargePanelList[panelIndex].noFirst.Visibility = Visibility.Visible;
				rechargePanelList[panelIndex].first.Visibility = Visibility.Hidden;
			end
			
			rechargePanelList[panelIndex].panel.Visibility = Visibility.Visible;
			--[[
		elseif tonumber(index) == self.baseID + 9 then
			--月卡
			mCardPanel.panel.Visibility = Visibility.Visible;

			--bt版处理
			if platformSDK.m_Platform == 'moli' or platformSDK.m_Platform == 'dm' or platformSDK.m_Platform == 'vqs' then
				mCardPanel.shuijing:SetFont('huakang_20_miaobian_sp');
			end
			mCardPanel.shuijing.Text = tostring(info.cristal);
			mCardPanel.rmb.Text = LANG_moneySign .. info.rmb;
			]]
		end
		
	end	
	
	--刷新vip信息
	--VipPanel:RefreshNeedRmbToNextVipLevelPanel(vipStackPanel);
	
	--刷新月卡面板
	--self:RefreshMCardPanel();
	
	MainUI:Push(self);
	
end

--充值订单处理并请求充值
function RechargePanel:onStartRecharge(msg)
	--print(cjson.encode(msg));
	local rechargeInfo = rechargeList[tostring(rechargeid)];
	if nil ~= msg.serid and nil ~= rechargeInfo and nil ~= rechargeInfo.rmb and nil ~= rechargeInfo.cristal then
		--订单号,产品ID,产品名称,产品价格,产品数量,产品描述
		local payStr = '';
		local payCristal;
		if self:isFirstPay(tonumber(rechargeid - self.rechargeBaseID)) then
			payCristal = rechargeInfo.cristal + rechargeInfo.first_reward;
		else
			payCristal = rechargeInfo.cristal;
		end	
		
		local payInfo = {};
		payInfo.gameName = LANG_rechargePanel_7;						--游戏名
		payInfo.serid = msg.serid;							--订单号
		payInfo.productID = rechargeid;						--产品ID
		if platformSDK.m_Platform =='appstore_' then
			payInfo.productID = rechargeid + 10000;
		end
		payInfo.productName = rechargeInfo.name;			--产品名称
		payInfo.iosgoodsid = rechargeInfo.iosgoodsid;		--iOS appstore使用
		payInfo.productPrice = rechargeInfo.rmb;			--产品价格
		payInfo.productCount = 1;							--产品数量
		payInfo.productDescription = '';					--产品描述
		payInfo.userID = ActorManager.user_data.uid;		--用户ID
		payInfo.userName = ActorManager.user_data.name;		--角色名
		payInfo.curCristal = ActorManager.user_data.rmb;	--用户当前水晶数
		payInfo.vipLevel = ActorManager.user_data.viplevel;	--用户vip等级
		payInfo.userLevel = ActorManager.hero:GetLevel();	--用户等级
		payInfo.partyID = ActorManager.user_data.ggid;		--公会ID
		payInfo.hostnum = Login.hostnum;					--服务器ID
		--[[
		if VersionUpdate.curLanguage == 'tw' then
			payInfo.t_rmb = rechargeInfo.t_rmb;
		end
		]]
		platformSDK:OnRequestPaypage(cjson.encode(payInfo));
	end
end

--充值按钮响应
function RechargePanel:onRecharge(Args)
	local args = UIControlEventArgs(Args);
	if platformSDK.m_Platform == "master" or platformSDK.m_Platform == "appstore" then 
		Toast:MakeToast(Toast.TimeLength_Long, '功能暂未开放,敬请期待');
		return;
	end
	--if args.m_pControl.Tag == 9 and mCardLeftDays >= 30 then
		--Toast:MakeToast(Toast.TimeLength_Long, '剩余天数小于30才能充值月卡');
		--return;
	--end
	--if (1 == args.m_pControl.Tag) and self:isFirstPay() then
	--	--首次充值10元
	----	DoubleFirstChargePanel:ShowPanel(1);
	--elseif (2 == args.m_pControl.Tag) and self:isFirstPay() then
	--	--首次充值30元
	----	DoubleFirstChargePanel:ShowPanel(2);
	--else
	self:Recharge(args.m_pControl.Tag);
	--end	
end
function onUserInfoSuccess()
	Network:ShieldClickEvent();
end
function onUserInfoFailture()
	Network:CancelShieldClickEvent();
end
--充值
function RechargePanel:Recharge(level)
	local msg = {};
	msg.id = self.baseID + level;
	rechargeid = msg.id;
	
	--PrintLog("The user id is:"..platformSDK.m_PlatformUserID);
	
	msg.appid = platformSDK.m_Appid;
	msg.domain = platformSDK.m_Platform;
	msg.uin = platformSDK.m_UserName;
	
	Network:Send(NetworkCmdType.req_buy_yb, msg);
--	Network:Send(NetworkCmdType.req_pay, msg);
end

--是否首充
function RechargePanel:isFirstPay(pos)
	if platformSDK.m_Platform == 'moli' or platformSDK.m_Platform == 'dm' or platformSDK.m_Platform == 'vqs' then
		return false;
	end
	local i = self.chargeCount - 1;
	local data = ActorManager.user_data.first_pay;
	local state = false;
	while i >= pos
	do
		state = (data / math.pow(2,i)) < 1;
		data = data % math.pow(2,i);
		i = i -1
	end
	return state;
	--if 0 == ActorManager.user_data.first_pay then
	--	return true;
	--else
	--	return false;
	--end
end
