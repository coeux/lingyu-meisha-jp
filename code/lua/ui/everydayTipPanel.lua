--everydayTipPanel.lua

--========================================================================
--everydayTipPanel

EverydayTipPanel =
{
	tipType = 0, -- 1.十连抽 2.限时商店 3.指定
	bgImaName = nil,
	conditions = {},
	changeClothesBegin = 1484838000,
	changeClothesEnd = 1485010800,
};
local bgImg = 
{
	'chouka/lmt_zhaomu_tip_bg',
	'shop/lmt_shop_tip_bg_1',
	'shop/lmt_shop_tip_bg_2',
	'shop/lmt_card_event_tip_bg',
	'shop/lmt_shop_tip_bg_3'
};
local goBtnText = 
{
	'さっそくガチャる',
	'購入する',
};

--初始化
function EverydayTipPanel:InitPanel( desktop )
	self.bgImaName = nil;

	self.mainDesktop 	= desktop;
	self.everydayTipPanel = Panel( desktop:GetLogicChild('everydayTipPanel') );
	self.everydayTipPanel:IncRefCount();
	self.everydayTipPanel.ZOrder = PanelZOrder.everydayTipPanel;
	self.bgPanel = self.everydayTipPanel:GetLogicChild('bgPanel');
	self.goBtn   = self.bgPanel:GetLogicChild('goBtn');
	self.closeBtn = self.bgPanel:GetLogicChild('closeBtn');
	self.goBtn:SubscribeScriptedEvent('Button::ClickEvent','EverydayTipPanel:goBtnClick');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent','EverydayTipPanel:Hide');
	self.everydayTipPanel.Visibility = Visibility.Hidden;
	self:initDate();
end
function EverydayTipPanel:initDate()
	local showTime12 = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(15005), 'time');
	local showTime13 = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(15006), 'time');
	local cardEvent = ActorManager.user_data.functions.card_event;
	local condition1 = ActorManager.user_data.extra_data.is_pub_4;
	local condition2 = showTime12 and (LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime12)*86400));
	local condition3 = showTime13 and (LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime13)*86400));
	local condition4 = LuaTimerManager:GetCurrentTimeStamp() >= cardEvent.begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= cardEvent.end_stamp;
	local condition5 = LuaTimerManager:GetCurrentTimeStamp() >=  self.changeClothesBegin and LuaTimerManager:GetCurrentTimeStamp() <= self.changeClothesEnd;
	self.conditions = {condition1,condition2,condition3,condition4,condition5};
end
function EverydayTipPanel:goBtnClick()
	if self.tipType == 1 then
		ZhaomuPanel:ZhaomuTipShow();
	elseif self.tipType == 2 then
		ShopSetPanel:show(ShopSetType.gameShop);
	elseif self.tipType == 3 then
		ShopSetPanel:show(ShopSetType.gameShop);
	elseif self.tipType == 4 then
		CardEventPanel:enterCardEvent();
	end
	self:Hide();
end
function EverydayTipPanel:UpdateBgPanel()
	self.bgImaName = bgImg[self.tipType];
	self.bgPanel.Background = CreateTextureBrush(self.bgImaName..'.ccz', 'background');
end
function EverydayTipPanel:UpdateGoBtnText()
	
	if self.tipType == 2 or self.tipType == 3 then
		self.goBtn.CoverBrush = CreateTextureBrush('shop/lmt_shop_tip_btn.ccz','godsSenki');
		self.goBtn.NormalBrush = CreateTextureBrush('shop/lmt_shop_tip_btn.ccz','godsSenki');
		self.goBtn.PressBrush = CreateTextureBrush('shop/lmt_shop_tip_btn.ccz','godsSenki');
		self.goBtn.Margin = Rect(614, 469, 0, 0);
		self.closeBtn.Margin = Rect(809, 3, 0, 0);
		self.bgPanel.Size = Size(896,640);
	elseif self.tipType == 4 then
		self.goBtn.CoverBrush = CreateTextureBrush('shop/lmt_card_event_tip_btn.ccz','godsSenki');
		self.goBtn.NormalBrush = CreateTextureBrush('shop/lmt_card_event_tip_btn.ccz','godsSenki');
		self.goBtn.PressBrush = CreateTextureBrush('shop/lmt_card_event_tip_btn.ccz','godsSenki');
		self.goBtn.Margin = Rect(654, 494, 0, 0);
		self.closeBtn.Margin = Rect(809, 3, 0, 0);
		self.bgPanel.Size = Size(896,640);
	elseif self.tipType == 5 then
		self.goBtn.Visibility = Visibility.Hidden;
		self.closeBtn.Margin = Rect(809, 3, 0, 0);
		self.bgPanel.Size = Size(896,640);
	elseif self.tipType == 1 then
		self.goBtn.CoverBrush = CreateTextureBrush('chouka/lmt_zhaomu_tip_btn.ccz','godsSenki');
		self.goBtn.NormalBrush = CreateTextureBrush('chouka/lmt_zhaomu_tip_btn.ccz','godsSenki');
		self.goBtn.PressBrush = CreateTextureBrush('chouka/lmt_zhaomu_tip_btn.ccz','godsSenki');
		self.goBtn.Margin = Rect(605,427,0,0);
		self.closeBtn.Margin = Rect(775, 2, 0, 0);
		self.bgPanel.Size = Size(896,572);
	end
end
--销毁
function EverydayTipPanel:Destroy()
	self.everydayTipPanel:DecRefCount();
	self.everydayTipPanel = nil;
end
function EverydayTipPanel:onShow()
	for tipType,condition in pairs(self.conditions) do
		if condition then
			self:Show(tipType);
			self.conditions[tipType] = false;
			break;
		end
	end
end
--显示
function EverydayTipPanel:Show(tipType)
	if tipType == nil then
		return;
	end
	self.tipType = tipType;
	self:UpdateBgPanel();
	self:UpdateGoBtnText();
	self.everydayTipPanel.Visibility = Visibility.Visible;
end

--隐藏
function EverydayTipPanel:Hide()
	if self.bgImaName then
		DestroyBrushAndImage(self.bgImaName..'.ccz', 'background');
		self.bgImaName = nil;
	end
	self.everydayTipPanel.Visibility = Visibility.Hidden;
	self:onShow();
end

