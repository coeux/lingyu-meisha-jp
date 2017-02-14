--buypower.lua

--========================================================================
--购买体力界面

BuyPowerPanel =
	{
		powerItemId = 21001;
	};	

--变量
local num = 0;			 	    --购买体力次数
local powerNum = 0;				--获得体力值
local curNeedRmb = 0;			--该次购买体力消耗

--控件
local mainDesktop;
local buypowerPanel;
local labelPowerNum;
local labelRmbNum;
local labelRemainTime;
local floatPowerEffectList = {};		--体力增加浮动特效
local btnGold;
local returnBtn;

--初始化面板
function BuyPowerPanel:InitPanel(desktop)
	--变量初始化
	num = 0;			 	    --购买体力次数
	powerNum = 0;				--购买一次获得体力数
	curNeedRmb = 0;

	--界面初始化
	mainDesktop = desktop;
	buypowerPanel = Panel(desktop:GetLogicChild('buyPowerPanel'));
	buypowerPanel:IncRefCount();
	buypowerPanel.Visibility = Visibility.Hidden;
	labelPowerNum = Label(buypowerPanel:GetLogicChild('rmbGoldNum'));
	labelRmbNum = Label(buypowerPanel:GetLogicChild('rmbNum'));
	labelRemainTime = Label(buypowerPanel:GetLogicChild('remainTime'));
	btnPower = Button(buypowerPanel:GetLogicChild('ok'));
	btnPower:SubscribeScriptedEvent('UIControl::MouseClickEvent','BuyPowerPanel:onGoldClick');
	returnBtn = buypowerPanel:GetLogicChild('close');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','BuyPowerPanel:onClose');
	self.useBtn = buypowerPanel:GetLogicChild('useBtn');
	self.itemNmu = buypowerPanel:GetLogicChild('itemNum');
	self.useGoldNum = buypowerPanel:GetLogicChild('useGoldNum');
	self.useItemCell = buypowerPanel:GetLogicChild('useItemCell');
	self.useItemCell.IconMargin = Rect(0,0,0,0);
	self.useBtn:SubscribeScriptedEvent('Button::ClickEvent','BuyPowerPanel:useBtnClick');
end

--销毁
function BuyPowerPanel:Destroy()
	buypowerPanel:DecRefCount();
	buypowerPanel = nil;
end

--显示
function BuyPowerPanel:Show()
	buypowerPanel:GetLogicChild('brush1').Background = CreateTextureBrush('main/buy_diban.ccz', 'main');
	buypowerPanel:GetLogicChild('brush2').Background = CreateTextureBrush('main/buy_diban.ccz', 'main');
	--设置模式对话框
	mainDesktop:DoModal(buypowerPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(buypowerPanel, StoryBoardType.ShowUI1);
		
	powerNum = 60;
	labelPowerNum.Text = tostring(powerNum);
	GodsSenki:LeaveMainScene()
	self:updateItemUse();
end

--隐藏
function BuyPowerPanel:Hide()
	isClickBtn = false;
	for _,effect in ipairs(floatPowerEffectList) do
		topDesktop:RemoveChild(effect);
	end
	floatPowerEffectList = {};
	--取消模式对话框
	--mainDesktop:UndoModal();	
--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(buypowerPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	buypowerPanel:GetLogicChild('brush1').Background = nil;
	buypowerPanel:GetLogicChild('brush2').Background = nil;
	DestroyBrushAndImage('main/buy_diban.ccz', 'main');
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

--是否显示
function BuyPowerPanel:IsVisible()
	return buypowerPanel.Visibility == Visibility.Visible;
end

--========================================================================
--点击事件

--申请购买体力信息
function BuyPowerPanel:onApplyGoldInfo()
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
end

--显示购买体力界面?
function BuyPowerPanel:onShow()
	 MainUI:Push(self);
end

--点击购买体力
function BuyPowerPanel:onGoldClick()
	if num <= 0 then
		BuyCountPanel:onShowBuyCountPanel(curNeedRmb, 0);
	elseif curNeedRmb > ActorManager.user_data.rmb then
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_promotionGoldPanel_1);
	else
		local okDelegate = Delegate.new(BuyPowerPanel, BuyPowerPanel.sendMessage, 0);
		local str = LANG_Vip_tip_6;
		MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
	end
end

function BuyPowerPanel:sendMessage()
	Network:Send(NetworkCmdType.req_buy_power, {}, true);
end

--购买体力后处理
function BuyPowerPanel:onGold(msg)
--	local floatMoneyEffect = CreateGoldMoneyEffect(goldNum*msg.times, 0, 80);
--	PlayEffectLT('lianjinjiangli_output/', Rect(btnGold:GetAbsTranslate().x  + btnGold.Width * 0.42, btnGold:GetAbsTranslate().y - btnGold.Height * 2.8, 0, 0), 'lianjinjiangli');
--	topDesktop:AddChild(floatMoneyEffect);
--	table.insert(floatMoneyEffectList, floatMoneyEffect);	
	local powerEffect = CreateaddPowerEffect(1);
	topDesktop:AddChild(powerEffect);
	table.insert(floatPowerEffectList, powerEffect);	
	PlayEffectLT('tili_output/', Rect(428 ,20, 0, 0), 'tili');
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
end

--获取购买体力次数
function BuyPowerPanel:onGoldNum(yb, count)
	curNeedRmb = yb;
	labelRmbNum.Text = tostring(yb);
	
	num = count;
	local viplevel = ActorManager.user_data.viplevel;
	local totalNum = resTableManager:GetValue(ResTable.vip, tostring(viplevel), 'buy_power');
	labelRemainTime.Text = tostring(99999 - count);
--	if count <= 0 then
--		labelRemainTime.TextColor = Configuration.RedColor;	
--	else
--		labelRemainTime.TextColor = Configuration.GreenColor;
--	end
end
function BuyPowerPanel:updateItemUse()
	local powerItemCount = 0;
	local curPowerItemId = self.powerItemId;
	local powerItem = Package:GetItem(curPowerItemId);
	local apNum = resTableManager:GetValue(ResTable.drug,tostring(curPowerItemId),'num');
	while(apNum and (not powerItem or powerItem.num <= 0)) do
		curPowerItemId = curPowerItemId + 1;
		powerItem = Package:GetItem(curPowerItemId);
		apNum = resTableManager:GetValue(ResTable.drug,tostring(curPowerItemId),'num');
	end
	if powerItem and powerItem.num > 0 then
		powerItemCount = powerItem.num;
	else
		powerItemCount = 0;
		curPowerItemId = self.powerItemId;
		apNum = resTableManager:GetValue(ResTable.drug,tostring(curPowerItemId),'num');
	end
	local iconId = resTableManager:GetValue(ResTable.item,tostring(curPowerItemId),'icon');
	if iconId then
		self.useItemCell.Image = GetPicture('icon/'..iconId..'.ccz');
	end
	self.itemNmu.Text = tostring(powerItemCount);
	self.useGoldNum.Text = tostring(tonumber(apNum) or 0);
	if powerItemCount == 0 then
		self.useBtn.Enable = false;
	else
		self.useBtn.Enable = true;
		self.useBtn.Tag = curPowerItemId;
	end
end
--道具使用
function BuyPowerPanel:useBtnClick(Args)
	local args = UIControlEventArgs(Args);
   	local resid = args.m_pControl.Tag;
   	local powerItem = Package:GetItem(resid);
   	if not powerItem or powerItem.num <= 0 then
   		return;
   	end
   	local msg = {};
	msg.resid = resid;
	msg.num = 1;
	msg.param = '';
	Network:Send(NetworkCmdType.req_use_item_t, msg);
end
--关闭
function BuyPowerPanel:onClose()
	MainUI:Pop();
end
