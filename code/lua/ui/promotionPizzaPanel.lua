--promotionPizzaPanel.lua

--========================================================================
--吃披萨界面

PromotionPizzaPanel =
	{
	};	

--变量
local isVisible;			 	    --是否已经显示
local refreshTimer = 0;				--定时器
local effectTimer = 0;				--桌面显示特效定时器
local cdDefault = -1;				--初始剩余时间为-1
local cdEat = 0;					--0表示可以吃披萨
local cd = cdDefault;
local effectFlag = false;			--特效状态请求

--控件
local mainDesktop;
local promotionPizzaPanel;
local btnEatPizza;
local yadianna;						--雅典娜全身像
local labelNextTime;				--下次吃披萨
local labelPreNextTime;


--初始化面板
function PromotionPizzaPanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;			 	    --是否已经显示
	refreshTimer = 0;				--定时器
	effectTimer = 0;				--桌面显示特效定时器
	cdDefault = -1;				--初始剩余时间为-1
	cdEat = 0;					--0表示可以吃披萨
	cd = cdDefault;
	effectFlag = false;			--特效状态请求

	--界面初始化
	mainDesktop = desktop;
	promotionPizzaPanel = Panel(desktop:GetLogicChild('promotionPizzaPanel'));
	promotionPizzaPanel:IncRefCount();
	promotionPizzaPanel.Visibility = Visibility.Hidden;
	btnEatPizza = Button(promotionPizzaPanel:GetLogicChild('eat'));
	labelNextTime = Label(promotionPizzaPanel:GetLogicChild('nextTime'));
	labelPreNextTime = Label(promotionPizzaPanel:GetLogicChild('preNextTime'));
	yadianna = promotionPizzaPanel:GetLogicChild('yadianna');
end

--销毁
function PromotionPizzaPanel:Destroy()
	promotionPizzaPanel:DecRefCount();
	promotionPizzaPanel = nil;
end

--显示
function PromotionPizzaPanel:Show()
	isVisible = true;
	--设置模式对话框
	mainDesktop:DoModal(promotionPizzaPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(promotionPizzaPanel, StoryBoardType.ShowUI1);

	yadianna.Background = CreateTextureBrush('dynamicPic/huodong_yadianna.ccz', 'godsSenki', Rect(0,0,252,341));	
end

--隐藏
function PromotionPizzaPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(promotionPizzaPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	isVisible = false;	
	--删除计时器
	if 0 ~= refreshTimer then
		timerManager:DestroyTimer(refreshTimer);
		refreshTimer = 0;
	end
end	

--刷新下次领取剩余时间
function PromotionPizzaPanel:RefreshNextTime()
	if cd < 0 then
		labelNextTime.Visibility = Visibility.Hidden;
		labelPreNextTime.Visibility = Visibility.Hidden;
		btnEatPizza.Enable = false;
	elseif cd == 0 then
		labelNextTime.Visibility = Visibility.Hidden;
		labelPreNextTime.Visibility = Visibility.Hidden;
		btnEatPizza.Enable = true;
	else
		labelNextTime.Visibility = Visibility.Visible;
		labelPreNextTime.Visibility = Visibility.Visible;
		btnEatPizza.Enable = false;
		local hour, min, sec = Time2HourMinSec(cd);
		if 0 == hour then
			labelNextTime.Text = '' .. min .. LANG_promotionPizzaPanel_1 .. sec .. LANG_promotionPizzaPanel_2;
		else
			labelNextTime.Text = '' .. hour .. LANG_promotionPizzaPanel_3 .. min .. LANG_promotionPizzaPanel_4 .. sec .. LANG_promotionPizzaPanel_5;
		end	
	end	
end

--刷新剩余时间
function PromotionPizzaPanel:onRefreshTime()
	cd = cd - 1;
	if cd <= 0 then
		--删除计时器
		if 0 ~= refreshTimer then
			timerManager:DestroyTimer(refreshTimer);
			refreshTimer = 0;
		end
	end
	self:RefreshNextTime();
end

--========================================================================
--点击事件

--显示吃披萨活动界面
function PromotionPizzaPanel:onShow()
	if cdEat == cd and not isVisible then
		MainUI:Push(self);
	else
		Network:Send(NetworkCmdType.req_reward_power_cd, {});
	end
end

--点击吃Pisa
function PromotionPizzaPanel:onEatClick()
	Network:Send(NetworkCmdType.req_given_power_reward, {});
end

--吃完Pisa
function PromotionPizzaPanel:onEatPisa()
	btnEatPizza.Enable = false;
	PromotionPanel:HidePisaEffect();
	Network:Send(NetworkCmdType.req_reward_power_cd, {});	
end

--请求是否可以吃披萨，显示特效用
function PromotionPizzaPanel:RequestPisaStatus()
	Network:Send(NetworkCmdType.req_reward_power_cd, {});
	--标示该请求为了获取是否可以吃披萨
	effectFlag = true;
end

--下次吃Pisa的剩余时间
function PromotionPizzaPanel:onNextEatCd(msg)
	if nil ~= msg then
		local effectcd = msg.cd;
		--是否显示可以吃披萨特效
		if effectFlag then
			if effectcd == 0 then
				PromotionPanel:ShowPisaEffect();
			elseif effectcd > 0 then
				if effectTimer == 0 then
					effectTimer = timerManager:CreateTimer(effectcd, 'PromotionPanel:ShowPisaEffect', 0);
				end
			end
			effectFlag = false;
			return;
		end
		cd = msg.cd;
		self:RefreshNextTime();
		if not isVisible then
			MainUI:Push(self);
		end
		if cd > 0 then
			if refreshTimer == 0 then
				refreshTimer = timerManager:CreateTimer(1, 'PromotionPizzaPanel:onRefreshTime', 0);
			end
		end	
	end
end

--关闭
function PromotionPizzaPanel:onClose()
	MainUI:Pop();
end
