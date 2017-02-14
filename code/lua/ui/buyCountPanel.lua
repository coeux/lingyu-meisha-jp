--buyCountPanel.lua
--=====================================================================================
--购买次数通用界面
BuyCountPanel =
	{
	};
	
--变量
local curType;						--类型
local leftTimes = 0;				--剩余次数
local curCostRmb = 0;				--当次需花费的水晶
local strTitle;						--设置的标题
local callBackFuncList = {};		--购买按钮的相应事件列表
local rmbNotEnoughTip = '';			--水晶不足的提示
local limitCountTip = '';			--购买次数上限

--控件
local mainDesktop;
local panel;

local vip;
local title;
local text11;
local text12;
local text13;
local text14;
local line1;
local line2;
local text21;
local text22;
local text23;
local text24;
local text31;
local text32;
local text33;
local text34;
local btnBuy;
local btnCancel;

--初始化
function BuyCountPanel:InitPanel(desktop)
	--变量初始化
	curType = 0;				--类型
	leftTimes = 0;				--剩余次数
	curCostRmb = 0;				--当次需花费的水晶
	strTitle = nil;
	callBackFuncList = {};		--购买按钮的相应事件列表
	rmbNotEnoughTip = '';	

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('buyCountPanel'));
	panel:IncRefCount();
	
	title = panel:GetLogicChild('title');
	line1 = panel:GetLogicChild('line1');
	text11 = line1:GetLogicChild('1');
	text12 = line1:GetLogicChild('2');
	text13 = line1:GetLogicChild('3');
	text14 = line1:GetLogicChild('4');
	line2 = panel:GetLogicChild('line2');
	text21 = line2:GetLogicChild('1');
	text22 = line2:GetLogicChild('2');
	text23 = line2:GetLogicChild('3');
	text24 = line2:GetLogicChild('4');
	line3 = panel:GetLogicChild('line3')
	line3.Visibility = Visibility.Hidden
	text31 = line3:GetLogicChild('1')
	text32 = line3:GetLogicChild('2')
	text33 = line3:GetLogicChild('3')
	text34 = line3:GetLogicChild('4')
	vip = panel:GetLogicChild('vip');
	btnBuy = panel:GetLogicChild('ok');
	btnCancel = panel:GetLogicChild('cancel');
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function BuyCountPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end	

--显示
function BuyCountPanel:Show()
	if VipBuyType.vop_buy_power == curType then					--购买体力
		title.Text = LANG_buyCountPanel_1;
		rmbNotEnoughTip = LANG_buyCountPanel_2;
		limitCountTip = '(最多5次)';
		text11.Text = '确认购买';
		text12.Text = LANG_buyCountPanel_3;
		text12.TextColor = Configuration.WhiteColor;
		text13.Text = tostring(curCostRmb);
		text14.Text = LANG_buyCountPanel_4;
		text14.TextColor = Configuration.WhiteColor;
		text21.Visibility = Visibility.Hidden;
		text22.Visibility = Visibility.Hidden;
		text13.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_8;
		
	elseif VipBuyType.vop_buy_trial_energy == curType then			--活力
		title.Text = LANG_buyCountPanel_9;
		rmbNotEnoughTip = LANG_buyCountPanel_10;
		limitCountTip = '(最多20次)';
		text12.Text = curCostRmb .. LANG_buyCountPanel_11;
		text13.Text = LANG_buyCountPanel_12;
		text14.Text = LANG_buyCountPanel_13;
		
		text21.Text = LANG_buyCountPanel_14;
		text22.Text = leftTimes .. LANG_buyCountPanel_15;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_16;
		
	elseif VipBuyType.vop_buy_fight_count == curType then			--竞技场次数
		title.Text = LANG_buyCountPanel_17;
		rmbNotEnoughTip = LANG_buyCountPanel_18;
		limitCountTip = '(最多10次)';
		text11.Text = LANG_buyCountPanel_19
		text12.Text = tostring(curCostRmb);
		text13.Text = LANG_buyCountPanel_20;
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_21;
		text22.Text = leftTimes .. LANG_buyCountPanel_22;
		text22.TextColor = Configuration.RedColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		line3.Visibility = Visibility.Visible
		text31.Text = LANG_own_diamond
		text32.Text = ActorManager.user_data.rmb .. LANG_diamond
		text33.Text = ''
		text34.Text = ''
		btnBuy.Text = LANG_buyCountPanel_23;
		text12.TextColor = Configuration.DarkBlue;
		text32.TextColor = Configuration.DarkBlue;
		
	elseif VipBuyType.vop_arena_clear_time == curType then--清除竞技场冷却时间
		title.Text = LANG_buyCountPanel_81;
		rmbNotEnoughTip = LANG_buyCountPanel_82;
		limitCountTip = '';
		text11.Text = '';
		text12.Text = curCostRmb .. LANG_buyCountPanel_84;
		text13.Text = '';
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_85;
		text22.Text = '';
		text23.Text = '';
		text24.Text = '';
		line2.Visibility = Visibility.Visible;

		line3.Visibility = Visibility.Visible;
		text31.Text = LANG_buyCountPanel_86
		text32.Text = ActorManager.user_data.rmb .. LANG_diamond
		text32.TextColor = Configuration.RedColor
		text33.Text = ''
		text34.Text = ''
		btnBuy.Text = LANG_buyCountPanel_23;

	elseif VipBuyType.vop_reste_adv_round == curType then			--重置精英副本
		title.Text = LANG_buyCountPanel_24;
		rmbNotEnoughTip = LANG_buyCountPanel_25;
		limitCountTip = '(最多5次)';
		text12.Text = curCostRmb .. LANG_buyCountPanel_26;
		text13.Text = LANG_buyCountPanel_27;
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_28;
		text22.Text = leftTimes .. LANG_buyCountPanel_29;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_30;
		
	elseif VipBuyType.vop_reset_zodiac == curType then				--重置十二宫进度
		title.Text = LANG_buyCountPanel_31;
		rmbNotEnoughTip = LANG_buyCountPanel_32;
		limitCountTip = '(最多5次)';
		text12.Text = curCostRmb .. LANG_buyCountPanel_33;
		text13.Text = LANG_buyCountPanel_34;
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_35;
		text22.Text = leftTimes .. LANG_buyCountPanel_36;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_37;
		
	elseif VipBuyType.vop_reset_daily_task == curType then			--日常任务
		title.Text = LANG_buyCountPanel_38;
		rmbNotEnoughTip = LANG_buyCountPanel_39;
		limitCountTip = '(最多5次)';
		text12.Text = curCostRmb .. LANG_buyCountPanel_40;
		text13.Text = LANG_buyCountPanel_41;
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_42;
		text22.Text = leftTimes .. LANG_buyCountPanel_43;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_44;

	elseif VipBuyType.vop_starmap == curType then					--星魂刷新
		title.Text = LANG_buyCountPanel_45;
		rmbNotEnoughTip = LANG_buyCountPanel_46;
		limitCountTip = '(最多20次)'
		text12.Text = curCostRmb .. LANG_buyCountPanel_47;
		text13.Text = LANG_buyCountPanel_48;
		text14.Text = '';
		
		text21.Text = LANG_buyCountPanel_49;
		text22.Text = leftTimes .. LANG_buyCountPanel_50;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		btnBuy.Text = LANG_buyCountPanel_51;


	elseif VipBuyType.vop_add_bag_max == curType then
		title.Text = LANG_buyCountPanel_52;
		text12.Text = curCostRmb .. LANG_buyCountPanel_53;
		text13.Text = LANG_buyCountPanel_54
		text14.Text = LANG_buyCountPanel_55;
		btnBuy.Text = LANG_buyCountPanel_56;

		if ActorManager.user_data.viplevel >= resTableManager:GetValue(ResTable.vip_open, '6', 'viplv') then
			--获得100个格子上限增加			
			text21.Text = LANG_buyCountPanel_57;
			text22.Text = 300 - ActorManager.user_data.bagn .. LANG_buyCountPanel_58;
			text22.TextColor = Configuration.GreenColor;
			text23.Text = LANG_buyCountPanel_59;
			text24.Visibility = Visibility.Visible;
			text24.Visibility = Visibility.Hidden;
		else
			text21.Text = LANG_buyCountPanel_60;
			text22.Text = 200 - ActorManager.user_data.bagn .. LANG_buyCountPanel_61;
			text22.TextColor = Configuration.GreenColor;
			text23.Text = LANG_buyCountPanel_62;
			text23.Visibility = Visibility.Visible;
			text24.Visibility = Visibility.Hidden;
		end
	elseif VipBuyType.vop_do_buy_money == curType then
		title.Text = LANG_buyCountPanel_63;
		rmbNotEnoughTip = LANG_buyCountPanel_64;
		limitCountTip = '(最多65次)'

		text21.Text = LANG_buyCountPanel_65;
		text22.Text = leftTimes .. LANG_buyCountPanel_66;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
		
	elseif VipBuyType.vop_flush_cave == curType then
		title.Text = LANG_buyCountPanel_67;
		rmbNotEnoughTip = LANG_buyCountPanel_68;
		limitCountTip = '(最多3次)'
		
		text12.Text = curCostRmb .. LANG_buyCountPanel_69;
		text13.Text = LANG_buyCountPanel_70;
		text14.Text = '';

		text21.Text = LANG_buyCountPanel_71;
		text22.Text = leftTimes .. LANG_buyCountPanel_72;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
	elseif VipBuyType.vop_buy_goldpackage == curType then
		title.Text = LANG_buyCountPanel_77;
		limitCountTip = LANG_buyCountPanel_78;

		text21.Text = LANG_buyCountPanel_79;
		text22.Text = leftTimes .. LANG_buyCountPanel_72;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
	elseif VipBuyType.vop_buy_silverpackage == curType then
		title.Text = LANG_buyCountPanel_80;
		limitCountTip = LANG_buyCountPanel_78;

		text21.Text = LANG_buyCountPanel_79;
		text22.Text = leftTimes .. LANG_buyCountPanel_72;
		text22.TextColor = Configuration.GreenColor;
		text23.Visibility = Visibility.Hidden;
		text24.Visibility = Visibility.Hidden;
	elseif VipBuyType.vop_buy_unionBattle_count == curType then
		leftTimes = 1 
	end
	
	if leftTimes == 0 then
		line1.Visibility = Visibility.Hidden;
		vip.Visibility = Visibility.Visible;		
		if VipBuyType.vop_add_bag_max == curType then
			vip.Text = LANG_buyCountPanel_73;
			btnBuy.Text = LANG_buyCountPanel_74;
			btnBuy.Enable = false;
		else
			vip.Text = LANG_buyCountPanel_75 .. limitCountTip;
			text22.TextColor = Configuration.RedColor;
			btnBuy.Text = LANG_buyCountPanel_76;
			btnBuy.Enable = true;
			-- panel.Size = Size(460, 247);
		end	
	else
		line1.Visibility = Visibility.Visible;
		vip.Visibility = Visibility.Hidden;	
		btnBuy.Enable = true;
		-- panel.Size = Size(440, 247);
	end
	
	--显示设置的title
	if strTitle ~= nil then
		title.Text = strTitle;
		strTitle = nil;
	end
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function BuyCountPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=====================================================================================
--初始化购买按钮的响应函数
function BuyCountPanel:InitBuyCallBack()
	callBackFuncList[VipBuyType.vop_buy_power]				= BuyCountPanel.onBuyPower;					--购买体力
	callBackFuncList[VipBuyType.vop_buy_trial_energy]		= BuyCountPanel.onBuyEnergy;				--购买活力
	callBackFuncList[VipBuyType.vop_buy_fight_count]		= BuyCountPanel.onBuyChallengeCount;		--购买竞技场挑战次数
	callBackFuncList[VipBuyType.vop_arena_clear_time]		= BuyCountPanel.onClearTime;
	callBackFuncList[VipBuyType.vop_reste_adv_round] 		= PveEliteBarrierPanel.onRealResetElite;	--重置精英副本
	callBackFuncList[VipBuyType.vop_reset_zodiac] 			= ZodiacSignPanel.realReset;				--重置12宫进度
	callBackFuncList[VipBuyType.vop_reset_daily_task]		= BuyCountPanel.onResetDailyRequest;		--重置日常任务
	callBackFuncList[VipBuyType.vop_add_bag_max]			= BuyCountPanel.buyPackageCell;				--购买背包格子
	callBackFuncList[VipBuyType.vop_starmap]				= StarMapPanel.RefreshStarWithCoin;			--用水晶刷星图
	callBackFuncList[VipBuyType.vop_flush_cave]				= RoleMiKuInfoPanel.onResetRequest;			--重置迷窟副本
	callBackFuncList[VipBuyType.vop_buy_unionBattle_count]  = BuyCountPanel.onBuyUnionBattleCount;		--购买社团挑战次数
end

--申请数据
function BuyCountPanel:ApplyData(bType, param)
	curType = bType;
	
	local msg = {};
	msg.flag = curType;

	if param ~= nil then
		msg.resid = param;
	else
		msg.resid = 0;
	end
	
	Network:Send(NetworkCmdType.req_buy_vip_info, msg);
end

--设置标题
function BuyCountPanel:SetTitle(str)
	strTitle = str;
end

--=====================================================================================
--响应函数

--购买体力
function BuyCountPanel:onBuyPower()
	Network:Send(NetworkCmdType.req_buy_power, {});
end

--购买背包格子
function BuyCountPanel:buyPackageCell()
	Network:Send(NetworkCmdType.req_buy_bag_cap, {});
end

--购买活力
function BuyCountPanel:onBuyEnergy()
	Network:Send(NetworkCmdType.req_buy_energy, {});
end

--购买竞技场挑战次数
function BuyCountPanel:onBuyChallengeCount()
	Network:Send(NetworkCmdType.req_buy_fight_count, {});
end

--清除竞技场冷却时间
function BuyCountPanel:onClearTime()
	Network:Send(NetworkCmdType.req_arena_clear_time, {});
end

--重置日常任务
function BuyCountPanel:onResetDailyRequest()
	--Network:Send(NetworkCmdType.req_buy_daily_task_num, {});
end

--购买黄金宝箱
function BuyCountPanel:onBugGoldenPackage()
	curType = VipBuyType.vop_buy_goldpackage;
	self:onShowBuyCountPanel(0, 0);
end

--购买白银宝箱
function BuyCountPanel:onBugSilverPackage()
	curType = VipBuyType.vop_buy_silverpackage;
	self:onShowBuyCountPanel(0, 0);
end
--购买社团挑战次数
function BuyCountPanel:onBuyUnionBattleCount()
	print('battleCount-->')
end
--=====================================================================================
--事件
--显示购买界面

function BuyCountPanel:onShowBuyCountPanel(rmb, counts)
	local oldtime = leftTimes;
	curCostRmb = rmb;
	leftTimes = counts;
	
	if VipBuyType.vop_do_buy_money == curType then
		if PromotionGoldPanel:IsVisible() then
			if oldtime == 0 then
				MainUI:Push(self);
			end
		else			
			PromotionGoldPanel:onShow();				
		end
		PromotionGoldPanel:onGoldNum(curCostRmb, leftTimes);
	elseif VipBuyType.vop_buy_power == curType then
		if BuyPowerPanel:IsVisible() then
			if oldtime == 0 then
				MainUI:Push(self);
			end
		else			
			BuyPowerPanel:onShow();				
		end
		BuyPowerPanel:onGoldNum(curCostRmb, leftTimes);
	else
		--星魂刷新不需要这个面板，自己处理
		if curType == VipBuyType.vop_starmap then
			StarMapAttrPanel:OnRefreshWithRmb(curCostRmb, leftTimes);
			return;
		else	
			MainUI:Push(self);
		end
	end
end

--购买
function BuyCountPanel:onBuy()
	MainUI:Pop();
	
	if leftTimes == 0 then	
		RechargePanel:onShowRechargePanel();
	elseif ActorManager.user_data.rmb < curCostRmb then				
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(rmbNotEnoughTip);
	else
		callBackFuncList[curType]();
	end
end

--取消
function BuyCountPanel:onClose()
	MainUI:Pop();
end
