--promotionGoldPanel.lua

--========================================================================
--炼金界面

PromotionGoldPanel =
	{
	};	

--变量
local num = 0;			 	    --炼金次数
local goldNum = 0;				--炼金一次获得金币数
local goldVipFlag = 15;
local curNeedRmb = 0;			--该次炼金需要的水晶数

--控件
local mainDesktop;
local promotionGoldPanel;
local labelGoldNum;
local labelRmbNum;
local labelRemainTime;
local floatMoneyEffectList = {};		--金钱增加浮动特效
local btnGold;
local returnBtn;

--初始化面板
function PromotionGoldPanel:InitPanel(desktop)
	--变量初始化
	num = 0;			 	    --炼金次数
	goldNum = 0;				--炼金一次获得金币数
	goldVipFlag = 15;
	curNeedRmb = 0;

	--界面初始化
	mainDesktop = desktop;
	promotionGoldPanel = Panel(desktop:GetLogicChild('promotionGoldPanel2'));
	promotionGoldPanel:IncRefCount();
	promotionGoldPanel.Visibility = Visibility.Hidden;
	labelGoldNum = Label(promotionGoldPanel:GetLogicChild('goldNum'));
	labelRmbNum = Label(promotionGoldPanel:GetLogicChild('rmbNum'));
	labelRemainTime = Label(promotionGoldPanel:GetLogicChild('remainTime'));
	btnGold = Button(promotionGoldPanel:GetLogicChild('getGold'));
	btnGold:SubscribeScriptedEvent('UIControl::MouseClickEvent','PromotionGoldPanel:onGoldClick');
	returnBtn = promotionGoldPanel:GetLogicChild('close');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','PromotionGoldPanel:onClose');
end

--销毁
function PromotionGoldPanel:Destroy()
	promotionGoldPanel:DecRefCount();
	promotionGoldPanel = nil;
end

--显示
function PromotionGoldPanel:Show()
	promotionGoldPanel:GetLogicChild(2).Background = CreateTextureBrush('main/buy_diban.ccz', 'main');
	--设置模式对话框
	mainDesktop:DoModal(promotionGoldPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(promotionGoldPanel, StoryBoardType.ShowUI1);
		
	local level = ActorManager.user_data.role.lvl.level;
	goldNum = resTableManager:GetValue(ResTable.levelup, tostring(level), 'alchemy_money');
	labelGoldNum.Text = tostring(goldNum);
	GodsSenki:LeaveMainScene();
end

--隐藏
function PromotionGoldPanel:Hide()
	for _,effect in ipairs(floatMoneyEffectList) do
		topDesktop:RemoveChild(effect);
	end
	floatMoneyEffectList = {};
	
	--取消模式对话框
	--mainDesktop:UndoModal();	
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(promotionGoldPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	promotionGoldPanel:GetLogicChild(2).Background = nil;
	DestroyBrushAndImage('main/buy_diban.ccz', 'main');
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

--是否显示
function PromotionGoldPanel:IsVisible()
	return promotionGoldPanel.Visibility == Visibility.Visible;
end

--========================================================================
--点击事件

--申请炼金信息
function PromotionGoldPanel:onApplyGoldInfo()
	BuyCountPanel:ApplyData(VipBuyType.vop_do_buy_money);
end

--显示炼金界面
function PromotionGoldPanel:onShow()
	MainUI:Push(self);
end

--点击炼金
function PromotionGoldPanel:onGoldClick()
	if num <= 0 then
		BuyCountPanel:onShowBuyCountPanel(curNeedRmb, 0);
	elseif curNeedRmb > ActorManager.user_data.rmb then
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_promotionGoldPanel_1);
	else
		local okDelegate = Delegate.new(PromotionGoldPanel, PromotionGoldPanel.sendMessage, 0);
		local str = LANG_Vip_tip_5;
		MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
	end
end

function PromotionGoldPanel:sendMessage()
	Network:Send(NetworkCmdType.req_buy_coin, {}, true);
end

--炼金后处理
function PromotionGoldPanel:onGold(msg)
	local floatMoneyEffect = CreateGoldMoneyEffect(goldNum*msg.times, 0, 80);
	if msg.times >= 2 then
		PromotionGoldPanel:baojiShow(msg.times)
	end
	--PlayEffectLT('lianjinjiangli_output/', Rect(btnGold:GetAbsTranslate().x  + btnGold.Width * 0.39, btnGold:GetAbsTranslate().y - btnGold.Height * 1.35, 0, 0), 'lianjinjiangli');
	topDesktop:AddChild(floatMoneyEffect);
	table.insert(floatMoneyEffectList, floatMoneyEffect);	
	
	BuyCountPanel:ApplyData(VipBuyType.vop_do_buy_money);
	--PlayEffectLT('jinbi_output/', Rect(110 ,70, 0, 0), 'jinbi');
end

--暴击动画效果
function PromotionGoldPanel:baojiShow(num)
	local MoneyEffect =  uiSystem:CreateControl('BaojiTemplate');
	local numImg1 = MoneyEffect:GetLogicChild(0):GetLogicChild('1');
	local numImg2 = MoneyEffect:GetLogicChild(0):GetLogicChild('2');
	if num >= 1 and num <= 9 then
		numImg1.Image = GetPicture('common/buy_' .. num .. '.ccz');
		numImg2.Visibility = Visibility.Hidden;
		MoneyEffect.Margin = Rect(btnGold:GetAbsTranslate().x  - btnGold.Width * 0.63, btnGold:GetAbsTranslate().y - btnGold.Height * 3.2, 0, 0);
	else
		numImg1.Image = GetPicture('common/buy_' .. num/10 .. '.ccz');
		numImg2.Image = GetPicture('common/buy_' .. num%10 .. '.ccz');
		numImg2.Visibility = Visibility.Visible;
		MoneyEffect.Margin = Rect(btnGold:GetAbsTranslate().x  - btnGold.Width * 0.75, btnGold:GetAbsTranslate().y - btnGold.Height * 3.2, 0, 0);
	end
	
	MoneyEffect.Pick = false;		
	MoneyEffect.Visibility = Visibility.Visible;
	MoneyEffect.Storyboard = '';
	MoneyEffect.Storyboard = 'storyboard.goodsDisappear';
	topDesktop:AddChild(MoneyEffect);
	table.insert(floatMoneyEffectList, MoneyEffect);
end

--获取炼金次数
function PromotionGoldPanel:onGoldNum(yb, count)
	curNeedRmb = yb;
	labelRmbNum.Text = tostring(yb);
	if curNeedRmb == 0 then
		labelRmbNum.Text = LANG_promotionGoldPanel_2;
	end
	
	num = count;
	local viplevel = ActorManager.user_data.viplevel;
	local totalNum = resTableManager:GetValue(ResTable.vip, tostring(viplevel), 'buy_coin');
	labelRemainTime.Text = tostring(99999 - count);
--	labelRemainTime.Text = count .. '/' .. totalNum;
--	if count <= 0 then
--		labelRemainTime.TextColor = Configuration.RedColor;	
--	else
--		labelRemainTime.TextColor = Configuration.GreenColor;
--	end
end

--关闭
function PromotionGoldPanel:onClose()
	MainUI:Pop();
end
