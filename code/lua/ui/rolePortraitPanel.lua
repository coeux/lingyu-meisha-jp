--rolePortraitPanel.lua
   
--========================================================================
--角色头像面板

RolePortraitPanel =
	{
	};

--变量
local powerTimer = 0;

--ui
local curDesktop;
local rolePortraitPanel;


local onlineShowFlag = false;
local nextRefreshTime = 0;                --下次刷新剩余时间
local refreshTimer;


local labelName;
local labelVip;
local labelLevel;
local labelFP;
local probExp;
local expPercent;
local probPower;
local labelPower;
local labelMaxPower;
local labelCoin;
local labelRmb;
local imgHeadPic;
local vipRewardEffect;
local moneyBtn;
local vipBtn;
local firstBtn;
local giftBtn;

--在线奖励
local activityOnline;						--在线领奖按钮
local activityOnlineTime;					--在线奖励领取剩余时间

--每日签到按钮
local signBtn;

--充返活动
local rechargeBtn;

--体力
local powerPanel;
local powerNext;
local powerRecover;
local powerBtn;
local recharmature;
local fpeffect;

local armature1
local armature2
local bottomFPPanel
local bottomArmature
local bottomFP
local jinbiImage;
local zuanshiImage;
local propertyPanel;
local goldCoinPanel;
local diamondPanel;
local apPanel;
local diamondButton;
local infoPanel;

local loginRewardBtn;
local nextDayRewardPanel;
--初始化面板
function RolePortraitPanel:InitPanel( desktop )
	
	--变量初始化
	powerTimer = 0;
	onlineShowFlag = false;
	--ui
	rolePortraitPanel = desktop:GetLogicChild('renwutouxiangPanel1');
	rolePortraitPanel.Visibility = Visibility.Visible;

	propertyPanel = rolePortraitPanel:GetLogicChild('propertyPanel');
	goldCoinPanel = propertyPanel:GetLogicChild('goldCoinPanel');
	diamondPanel  = propertyPanel:GetLogicChild('diamondPanel');
	apPanel		  = propertyPanel:GetLogicChild('apPanel');
	infoPanel = rolePortraitPanel:GetLogicChild('infoPanel');
	
	--签到
	signinPanel = rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('signinPanel');
	signinBtn	= signinPanel:GetLogicChild('signinButton');
	signinCricle = signinPanel:GetLogicChild('cricle');
	signinBtn:SubscribeScriptedEvent('Button::ClickEvent','DailySignPanel:reqSignInfo');
	signinCricle.Visibility = Visibility.Hidden;

	jinbiImage = goldCoinPanel:GetLogicChild('jinbiImage');
	zuanshiImage = rolePortraitPanel:GetLogicChild('zuanshiImage');
	labelName = Label(infoPanel:GetLogicChild('name') );
	labelVip = Label(infoPanel:GetLogicChild('vip') );
	local vipBg = infoPanel:GetLogicChild('vipBg')
	vipBg:SubscribeScriptedEvent('UIControl::MouseClickEvent','RolePortraitPanel:GoVipPanel')
	

	labelLevel = Label( infoPanel:GetLogicChild('level') );
	probExp = ProgressBar( infoPanel:GetLogicChild('jingyan') );
	labelPower = apPanel:GetLogicChild('apStackPanel'):GetLogicChild('tiliValue');
	labelMaxPower = apPanel:GetLogicChild('apStackPanel'):GetLogicChild('tiliMaxValue');
	labelFP = Label( infoPanel:GetLogicChild('zhanliValue') );
	labelCoin = Label( goldCoinPanel:GetLogicChild('jinbi') );
	labelRmb = Label( diamondPanel:GetLogicChild('diamondLabel'));
	
	apPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyPower');

	moneyBtn = Label( goldCoinPanel:GetLogicChild('moneyButton') );
	goldCoinPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold');

	diamondButton = diamondPanel:GetLogicChild('diamondButton');
	
	diamondPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onShowRechargePanel');

	firstBtn = Label( rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('firstrechargeBtn') );
	firstBtn.Visibility = Visibility.Hidden;
	--充值动画特效
	--recharmature = vipBtn:GetLogicChild('armature');
	--recharmature:LoadArmature('chongzhi');
	--recharmature:SetAnimation('play');

	--战斗力动画特效
	--fpeffect = infoPanel:GetLogicChild('zhandouli'):GetLogicChild('armature');
	--fpeffect:LoadArmature('zhandouli');
	--fpeffect:SetAnimation('play');


--	probExp:SubscribeScriptedEvent('ProgressBar::ValueChangedEvent', 'RolePortraitPanel:onExpChange');

	activityOnline = Button(rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('giftPanel'):GetLogicChild('giftButton'));
--	activityOnline:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onOnlieReward');
--	activityOnlineTime = Label(rolePortraitPanel:GetLogicChild('giftPanel'):GetLogicChild('time'));

	activityOnline:SubscribeScriptedEvent('UIControl::MouseClickEvent','ActivityAllPanel:OnShow');

	nextDayRewardPanel = rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('nextDayRewardPanel');
	loginRewardBtn = Button(rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('nextDayRewardPanel'):GetLogicChild('loginButton'));
	loginRewardBtn:SubscribeScriptedEvent('Button::ClickEvent','RolePortraitPanel:onShowTomorrowRewardPanel');
	self:tomorrowRewardTip()
	
	
	self:setLoginRewardButtonHidden();
	rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel').Visibility = Visibility.Hidden
	
    if ActivityRechargePanel:isHaveDoubleActivity() then 
    
    end 
    
	if ActivityRechargePanel:isHaveActivity() then  --ActivityRechargePanel:isInRechargeActivity()
		rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel').Visibility = Visibility.Visible
		rechargeBtn = Button(rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel'):GetLogicChild('rechargeButton'));
		rechargeBtn:SubscribeScriptedEvent('Button::ClickEvent','ActivityRechargePanel:OnShow')
		rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel'):GetLogicChild('cricle').Visibility = Visibility.Hidden
	end
	-- imgHeadPic = ImageElement( rolePortraitPanel:GetLogicChild('touxiang') );
	imgHeadPic = Button( infoPanel:GetLogicChild('touxiang') )           --将ImageElement控件强转成Button控件
	imgHeadPic:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:selfInfo')
	
	
	--vip奖励特效
	vipRewardEffect = uiSystem:CreateControl('ArmatureUI');
	vipRewardEffect:LoadArmature('VIP_texiao');
	vipRewardEffect.Pick = false;
	vipRewardEffect.Margin = Rect(5, 13, 0, 0);
	labelVip:AddChild(vipRewardEffect);
	
	--显示头像
	imgHeadPic.Image = GetPicture('navi/' .. ActorManager.user_data.role.headImage .. '.ccz');

	--体力
	powerPanel = desktop:GetLogicChild('powerPanel');
	powerNext = powerPanel:GetLogicChild('powerNext');
	powerRecover = powerPanel:GetLogicChild('powerRecover');
	powerTimer = 0;
	
	--labelMaxPower.Text = '/' .. Configuration.MaxPower;		--体力上限
	
	powerPanel.Visibility = Visibility.Hidden;

	bottomFPPanel = rolePortraitPanel:GetLogicChild('bottomFP')
	bottomFP = bottomFPPanel:GetLogicChild('zhanliValue')
	bottomArmature = bottomFPPanel:GetLogicChild('zhandouli'):GetLogicChild('armature')
	bottomFPPanel.Visibility = Visibility.Hidden

	self.activityButton = rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('activityPanel'):GetLogicChild('activityButton');
	self.activityCircle = rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('activityPanel'):GetLogicChild('cricle');
	self.activityButton:SubscribeScriptedEvent('Button::ClickEvent', 'OpenServiceRewardPanel:onShow');

	-- allPanel:GetLogicChild('packPanel').Visibility = Visibility.Hidden;
	self.onlinePanel = rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('onlinePanel');
	self.onlineBtn = self.onlinePanel:GetLogicChild('onlineBtn');
	self.onlineCircle = self.onlinePanel:GetLogicChild('circle');
	self.onlineTime = self.onlinePanel:GetLogicChild('time');
	self.onlineTime.Visibility = Visibility.Hidden;
	self.onlineBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OnlineRewardPanel:onShow');

	self.weekPanel = rolePortraitPanel:GetLogicChild('packPanel'):GetLogicChild('weekPanel');
	self.weekBtn = self.weekPanel:GetLogicChild('weekBtn');
	self.weekCircle = self.weekPanel:GetLogicChild('circle');
	self.weekBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WeekRewardPanel:onShow');
	
	self:bind();
	uiSystem:UpdateDataBind();
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		local packPanel = rolePortraitPanel:GetLogicChild('packPanel')
		local btnPanel = rolePortraitPanel:GetLogicChild('btnPanel')
		infoPanel:SetScale(factor,factor);
		infoPanel.Translate = Vector2(350*(factor-1)/2, 100*(factor-1)/2);
		propertyPanel:SetScale(factor,factor);
		propertyPanel.Translate = Vector2(153*(1-factor)/2, 124*(factor-1)/2);
		packPanel:SetScale(factor,factor);
		packPanel.Translate = Vector2(369*(1-factor)/2, 74*(factor-1)/2);
		btnPanel:SetScale(factor,factor);
		btnPanel.Translate = Vector2(369*(1-factor)/2, 74*(factor-1)/2);
	end
	--刷新
	self:Refresh();
	self:RefreshVipReward();
	self:RefreshPowerColor();
	self:updateFirstRechargeBtn()
	self:UpdateActivityBtn()
	self:updateWeekBtn();
	rolePortraitPanel:GetLogicChild('brush_1').Visibility = Visibility.Hidden;
	rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel').Visibility = Visibility.Hidden
end

function RolePortraitPanel:UpdateMainTaskHandle()
	if Task:getMainTaskId() < 100017 then
		rolePortraitPanel:GetLogicChild('brush_1').Visibility = Visibility.Visible;
		rolePortraitPanel:GetLogicChild('brush_1').Background = CreateTextureBrush('main/brush_1.ccz', 'main');
	else
		rolePortraitPanel:GetLogicChild('brush_1').Visibility = Visibility.Hidden;
	end
end


--签到提示更新  追加周礼包领取提示
function RolePortraitPanel:UpdateSignTip(flag)
    if  flag or WeekRewardPanel:isCanGetReward()  then
        signinCricle.Visibility =Visibility.Visible;
    else
        signinCricle.Visibility = Visibility.Hidden 
    end 
end
function RolePortraitPanel:GoVipPanel()
	VipPanel:onShowVipPanel()
	VipPanel:setActivePageIndex( ActorManager.user_data.viplevel )
end
function RolePortraitPanel:UpdateActivityBtn()
	if ActorManager.user_data.reward.servercreatestamp then
		if LuaTimerManager:GetCurrentTimeStamp() <= ActorManager.user_data.reward.servercreatestamp  + ActivityTime.OpenActivity then
			rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('activityPanel').Visibility = Visibility.Visible;
		else
			rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('activityPanel').Visibility = Visibility.Hidden;
		end
	else
		rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('activityPanel').Visibility = Visibility.Hidden;
	end
end


function RolePortraitPanel:setLoginRewardButtonHidden()
	--[[
	if TomorrowRewardPanel:isGetAllReward() then
		nextDayRewardPanel.Visibility = Visibility.Hidden;
	else
		nextDayRewardPanel.Visibility = Visibility.Visible;
	end
	]]
	nextDayRewardPanel.Visibility = Visibility.Hidden;
end

function RolePortraitPanel:updateFirstRechargeBtn()
	if ActorManager.user_data.reward.first_yb == -1 or 
	(ActorManager.user_data.reward.first_yb == 1 and ActorManager.user_data.reward.recharge_back.can_get_first == 0) then
		firstBtn.Visibility = Visibility.Hidden;
	else
		firstBtn.Visibility = Visibility.Visible;
	end
end
function RolePortraitPanel:isFirstRecharge()
	if ActorManager.user_data.reward.first_yb == -1 or 
	(ActorManager.user_data.reward.first_yb == 1 and ActorManager.user_data.reward.recharge_back.can_get_first == 0) then
		return true;
	else
		return false;
	end
end

function RolePortraitPanel:updateWeekBtn()
	local tc = os.date("*t", ActorManager.user_data.reward.cur_sec);
	local year, month, day = tc.year, tc.month, tc.day;
	local week = KimLarssonYearMonthDay(year, month, day);
	-- print("ChroniclePanel.year = ", year);
	-- print("ChroniclePanel.month = ", month);
	-- print("ChroniclePanel.day = ", day);
	-- print("week = ", week);
	--if week == 0 or week == 6 then
		self.weekPanel.Visibility = Visibility.Hidden;
	--	RolePortraitPanel:updateWeekRewardTip()
	--else
		--self.weekPanel.Visibility = Visibility.Hidden;
	--end
end

function RolePortraitPanel:updateOnlineRewardTip()
	if OnlineRewardPanel:isCanGetReward() and not OnlineRewardPanel.isGetAllReward then
		self.onlineCircle.Visibility = Visibility.Visible;
	else
		self.onlineCircle.Visibility = Visibility.Hidden;
	end
end

function RolePortraitPanel:updateOnlineRewardCD()
	if OnlineRewardPanel.isGetAllReward then
		self.onlineTime.Visibility = Visibility.Hidden;
	else
		self.onlineTime.Visibility = Visibility.Visible;
		if OnlineRewardPanel.CDTime > 0 then
			self.onlineTime.Text = tostring(Time2HMSStr(OnlineRewardPanel.CDTime));
		else
			self.onlineTime.Text = LANG_online_reward_tip;
		end
	end
end

function RolePortraitPanel:updateWeekRewardTip()
	if WeekRewardPanel:isCanGetReward() then
		self.weekCircle.Visibility = Visibility.Visible;
	else
		self.weekCircle.Visibility = Visibility.Hidden;
	end
end

function RolePortraitPanel:setLoginRewardButtonVisible()
	loginRewardBtn.Visibility = Visibility.Visible;
end

function RolePortraitPanel:onShowTomorrowRewardPanel()
	local index = ActorManager.user_data.reward.lg_days;

	if index then
		if #TomorrowRewardPanel.receiveDay > 0 then
			local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));

			if rowData1 then
				TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
			else
				local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
				TomorrowRewardPanel:onShowRewardInfo(count, false);
			end
		else
			local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
			TomorrowRewardPanel:onShowRewardInfo(count, false);
		end
	end
end

function RolePortraitPanel:effectPlay(kind)
	if true then return end--something wrong
	if  MainUI:RefCount() == 0  then
		if kind == "jinbi" then
			if jinbiImage == nil then return end;
			local effect = PlayEffectLT("jinbi_zuanshi_output/", Rect(jinbiImage:GetAbsTranslate().x + jinbiImage.Width * 0.5, jinbiImage:GetAbsTranslate().y - 9 + jinbiImage.Height * 0.5, 0, 0), "jinbi", jinbiImage);
			effect:SetScale(0.8, 0.8);
		elseif kind == "zuanshi" then
			if zuanshiImage == nil then return end;
			local effect = PlayEffectLT("jinbi_zuanshi_output/", Rect(zuanshiImage:GetAbsTranslate().x + zuanshiImage.Width * 0.5, zuanshiImage:GetAbsTranslate().y - 9+ zuanshiImage.Height * 0.5, 0, 0), "zuanshi", zuanshiImage);
			effect:SetScale(0.8, 0.8);
		end
	end
end

function RolePortraitPanel:displayBottomEffect(  )
	bottomFPPanel.Visibility = Visibility.Visible
	bottomFP.Visibility = Visibility.Hidden
	-- bottomFPPanel:GetLogicChild('zhandouli').Visibility = Visibility.Hidden
	FightPoint:ShowFP(ActorManager.user_data.fp, ControlLayout.H_CENTER,ControlLayout.V_BOTTOM,Rect(0,0,0,150))--, bottomFPPanel)
	if armature1 then
		armature1:Destroy()
	end
	local path = GlobalData.EffectPath .. 'fp_value_output/'
	AvatarManager:LoadFile(path) 
	--   载入动画
	armature1 = ArmatureUI( uiSystem:CreateControl('ArmatureUI') )
	armature1.Pick = false
	armature1.Horizontal = ControlLayout.H_CENTER
	armature1.Vertical = ControlLayout.V_CENTER
	armature1:LoadArmature('zhandouli')
	bottomFPPanel:AddChild(armature1)
	armature1:SetAnimation('play')
	armature1:SetScriptAnimationCallback('RolePortraitPanel:playNextEffect', 0)
	armature1.ZOrder = 1000000
end

function RolePortraitPanel:playNextEffect( armature, id )
	if armature:GetAnimation() == 'play' then
		self:HideBottomPanel()
		self:displayFPUpEffect()
	end
end

function RolePortraitPanel:HideBottomPanel(  )
	bottomFPPanel.Visibility = Visibility.Hidden
end

function RolePortraitPanel:displayFPUpEffect( )
	if armature1 then
		armature1:Destroy()
	end
	FightPoint:onClose()
	-- FightPoint:ShowFP(ActorManager.user_data.fp, rolePortraitPanel)
	armature2 = ArmatureUI( uiSystem:CreateControl('ArmatureUI') )
	armature2.Pick = false
	armature2.Horizontal = ControlLayout.H_CENTER
	armature2.Vertical = ControlLayout.V_CENTER
	armature2:LoadArmature('zhandouli')
	infoPanel:GetLogicChild('zhandouli'):AddChild(armature2)
	armature2:SetAnimation('play')
	-- armature2:SetScriptAnimationCallback('RolePortraitPanel:onCloseFightPoint', 0)
	armature2.ZOrder = 1000000
	armature2.Translate = Vector2(100, -10)
end

function RolePortraitPanel:onCloseFightPoint( armature )
	if armature:GetAnimation() == 'play' then
		FightPoint:onClose()
	end
end

--销毁
function RolePortraitPanel:Destroy()
	self:unbind();
	rolePortraitPanel = nil;
end

--显示
function RolePortraitPanel:Show()
	rolePortraitPanel.Visibility = Visibility.Visible;
end

--隐藏
function RolePortraitPanel:Hide()
	rolePortraitPanel.Visibility = Visibility.Hidden;
end

--刷新
function RolePortraitPanel:Refresh()
	--名字颜色
--	labelName.TextColor = QualityColor[ActorManager.user_data.role.rare];
end

--刷新体力颜色
function RolePortraitPanel:RefreshPowerColor()
	if labelPower == nil then
		return;
	end
	
	if ActorManager.user_data.power > Configuration.MaxPower then
		labelPower.TextColor = Configuration.WhiteColor;--QuadColor( Color(0,246,255, 255) );
	else
		labelPower.TextColor = Configuration.WhiteColor;
	end
end

--刷新vip奖励
function RolePortraitPanel:RefreshVipReward()
	--有vip奖励可以领取
	if VipPanel:IsHaveVipReward() then
		vipRewardEffect.Visibility = Visibility.Visible;
		vipRewardEffect:SetAnimation('play');
	else
		vipRewardEffect.Visibility = Visibility.Hidden;
		vipRewardEffect:Stop();
	end
end

--========================================================================

--绑定数据
function RolePortraitPanel:bind()
	
	uiSystem:Bind(DDXTYPE.DDX_STRING, ActorManager.user_data, 'name', labelName, 'Text');				--绑定姓名
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'viplevel', labelVip, 'Text');				--绑定vip
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.role.lvl, 'level', labelLevel, 'Text');		--绑定等级
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.role.lvl, 'levelUpExp', probExp, 'MaxValue');	--取消绑定等级的最大经验
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.role.lvl, 'curLevelExp', probExp, 'CurValue');--绑定当前等级的经验
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', labelCoin, 'Text');					--绑定金币
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', labelRmb, 'Text');					--绑定水晶
	--uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'powerProgress', probPower, 'CurValue');		--绑定体力
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'power', labelPower, 'Text');				--绑定体力显示值
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'fp', labelFP, 'Text');						--绑定战力
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'fp', bottomFP, 'Text');
end

--取消绑定数据
function RolePortraitPanel:unbind()
	
	uiSystem:UnBind(ActorManager.user_data, 'name', labelName, 'Text');							--取消绑定姓名
	uiSystem:UnBind(ActorManager.user_data, 'viplevel', labelVip, 'Text');						--取消绑定vip
	uiSystem:UnBind(ActorManager.user_data.role.lvl, 'level', labelLevel, 'Text');				--取消绑定等级
	uiSystem:UnBind(ActorManager.user_data.role.lvl, 'levelUpExp', probExp, 'MaxValue');		--取消绑定当前等级的经验
	uiSystem:UnBind(ActorManager.user_data.role.lvl, 'curLevelExp', probExp, 'CurValue');		--取消绑定等级的最大经验
	uiSystem:UnBind(ActorManager.user_data, 'money', labelCoin, 'Text');						--取消绑定金币
	uiSystem:UnBind(ActorManager.user_data, 'rmb', labelRmb, 'Text');							--取消绑定水晶
	--uiSystem:UnBind(ActorManager.user_data, 'powerProgress', probPower, 'CurValue');			--取消绑定体力
	uiSystem:UnBind(ActorManager.user_data, 'power', labelPower, 'Text');						--取消绑定体力显示值
	uiSystem:UnBind(ActorManager.user_data, 'fp', labelFP, 'Text');								--取消绑定战力
	uiSystem:UnBind(ActorManager.user_data, 'fp', bottomFP, 'Text')
end

--经验改变
function RolePortraitPanel:onExpChange()
	local v = ActorManager.user_data.role.lvl.curLevelExp / ActorManager.user_data.role.lvl.levelUpExp;
	--expPercent.Text = math.floor(v * 100) .. '%';
end

--点击体力显示
function RolePortraitPanel:onShowPower()
	powerPanel.Visibility = Visibility.Visible;
	powerTimer = timerManager:CreateTimer(0.3, 'RolePortraitPanel:refreshPower', 0);
end

--关闭体力显示
function RolePortraitPanel:onHidePower()
	powerPanel.Visibility = Visibility.Hidden;
	
	timerManager:DestroyTimer(powerTimer);
	powerTimer = 0;
end

--刷新体力显示
function RolePortraitPanel:refreshPower()
	--还有多久恢复满
	local totalTime;
	if ActorManager.user_data.power >= Configuration.MaxPower then
		totalTime = 0;
	else
		totalTime = (Configuration.MaxPower - ActorManager.user_data.power - 1) * Configuration.RecoverPowerTime * 60 + LuaTimerManager.leftApplyPowerSeconds;
	end

	local hour, min, sec = Time2HourMinSec(totalTime);
	powerRecover.Text = string.format(LANG_rolePortraitPanel_1, hour, min, sec);
	
	--当前这一点还有多久
	if totalTime == 0 then
		hour, min, sec = 0, 0, 0;
	else
		hour, min, sec = Time2HourMinSec(LuaTimerManager.leftApplyPowerSeconds);
	end

	powerNext.Text = string.format(LANG_rolePortraitPanel_2, min, sec);
end

------------------------
--更新在线奖励领取时间
function RolePortraitPanel:UpdateActivityOnlineTime(time)
--	activityOnlineTime.Text = time;
end

--初始化活动面板
function RolePortraitPanel:RefreshActivityPanel()
	--在线奖励开始计时
--	RewardOnlinePanel:RequestOnlineRewardTimer();
end

--显示在线奖励
function RolePortraitPanel:ShowActivityOnline()
	onlineShowFlag = true;
	activityOnline.Visibility = Visibility.Visible;	
--	activityOnlineTime.Visibility = Visibility.Visible;	
end

--隐藏在线奖励
function RolePortraitPanel:HideActivityOnline()
	onlineShowFlag = false;
	activityOnline.Visibility = Visibility.Hidden;
--	activityOnlineTime.Visibility = Visibility.Hidden;
end

--刷新活动按钮显示
function RolePortraitPanel:RefreshActivityButton()
	if onlineShowFlag then
		activityOnline.Visibility = Visibility.Hidden;
		activityOnline.Visibility = Visibility.Visible;
--		activityOnlineTime.Visibility = Visibility.Hidden;
--		activityOnlineTime.Visibility = Visibility.Visible;	
	else
		activityOnline.Visibility = Visibility.Hidden;
--		activityOnlineTime.Visibility = Visibility.Hidden;
	end	
end

function RolePortraitPanel:updateBind()
	-- print("TTTTTTTTTTTTT = ", tonumber(labelFP.Text))
	uiSystem:UpdateDataBind()
	-- print("HHHHHHHHHHHHHHH = ", tonumber(labelFP.Text))
end

function RolePortraitPanel:getSignBtn()
	return signBtn;
end


function RolePortraitPanel:getActivityBtn()
	return activityOnline;
end
--限时活动提示
function RolePortraitPanel:activityLimitTip(flag)
    if not flag then 
        flag = ActivityRechargePanel:isInDoubleReward()
    end  
	rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('rechargePanel'):GetLogicChild('cricle').Visibility = flag and Visibility.Visible or Visibility.Hidden
end
--次日奖励提示
function RolePortraitPanel:tomorrowRewardTip()
	--rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('nextDayRewardPanel'):GetLogicChild('cricle').Visibility = 
	--TomorrowRewardPanel:isCanGetReward() and Visibility.Visible or Visibility.Hidden
	rolePortraitPanel:GetLogicChild('btnPanel'):GetLogicChild('nextDayRewardPanel'):GetLogicChild('cricle').Visibility = Visibility.Hidden;
end

--开服活动提示
function RolePortraitPanel:setStatusOfOpenServerRedPoint(flag)
    if flag then 
         self.activityCircle.Visibility = Visibility.Visible;
    else 
        self.activityCircle.Visibility = Visibility.Hidden;
    end 
end 
