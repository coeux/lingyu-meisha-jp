--zhaomuResultPanel.lua
--结算界面
--=======================================================
ZhaomuResultPanel = 
	{
		show_num = 1,
	};

--常量
local jinbi_1;
local jinbi_10;
local zhizun_1;
local zhizun_10;
local shenmi_1;
local shenmi_10;
local original_pos_one;
local aim_pos_one;
local original_pos_ten;
local aim_pos_ten;
local configList;

--控件
local panel;
local maindesktop;
local bg;
local btnSure;
local btnTen;
local btnOne;
local tenPanel;
local onePanel;
local costPanel;
local labelTip;
local rolePanel;
local roleImg;
local roleArmFront;
local roleArmBack;
local item10Center;
local item14Sp;
local timerList;
local touchPanel;
local infoLabel;

--变量
local itemList;
local itemSp;
local item;
local tenIndex;
local spIndex;
local tenArmList;
local spArmList;
local oneArm;
local timer = 0;
local timer_stage_1 = 0;
local timer_stage_2 = 0;
local timer_stage_3 = 0;
local callback;
local armStage;
local disappearArmIndex;
local skipTimer;
local isSkip;
local reducedList;
local itemResid;
local itemSound;
local itemRoleSound;
local spPanel;
local flag_show_one;
local flag_show_ten;

--初始化
function ZhaomuResultPanel:InitPanel(desktop)
	--变量
	itemSound = nil
	itemRoleSound = nil
	--控件
	maindesktop = desktop;
	panel = desktop:GetLogicChild('choukaResultPanel');
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.ZhaomuResult;

	bg = panel:GetLogicChild('bg');

	labelTip = panel:GetLogicChild('tip');
	btnSure = panel:GetLogicChild('sureButton');
	btnSure:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuResultPanel:onSure');
	btnOne = panel:GetLogicChild('againOnceButton');
	btnOne:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuResultPanel:onOne');
	btnTen = panel:GetLogicChild('againTenButton');
	btnTen:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuResultPanel:onTen');

	touchPanel = panel:GetLogicChild('touchPanel');
	touchPanel.Visibility = Visibility.Hidden;
	touchPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ZhaomuResultPanel:gotoSkip');

	rolePanel = panel:GetLogicChild('rolePanel');
	rolePanel:GetLogicChild('sure'):SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuResultPanel:onback');
	roleImg = rolePanel:GetLogicChild('roleImg');
	local path = GlobalData.EffectPath .. 'role_chouka_output/';
	AvatarManager:LoadFile(path);
	roleArmFront = rolePanel:GetLogicChild('armFront');
	roleArmBack = rolePanel:GetLogicChild('armBack');

	--消耗的东西
	costPanel = {};
	costPanel.hideAll = function()
		panel:GetLogicChild('costPanel'):GetLogicChild('gem').Visibility = Visibility.Hidden;
		panel:GetLogicChild('costPanel'):GetLogicChild('gold').Visibility = Visibility.Hidden;
		panel:GetLogicChild('costPanel'):GetLogicChild('coin_scroll').Visibility = Visibility.Hidden;
		panel:GetLogicChild('costPanel'):GetLogicChild('gem_scroll').Visibility = Visibility.Hidden;
	end
	costPanel.setMoney = function(num)
		costPanel.hideAll();
		panel:GetLogicChild('costPanel'):GetLogicChild('gold').Visibility = Visibility.Visible;
		panel:GetLogicChild('costPanel'):GetLogicChild('cost').Text = tostring(num);
	end
	costPanel.setZS = function(num)
		costPanel.hideAll();
		panel:GetLogicChild('costPanel'):GetLogicChild('gem').Visibility = Visibility.Visible;
		panel:GetLogicChild('costPanel'):GetLogicChild('cost').Text = tostring(num);
	end
	costPanel.setRedScroll = function(num)
		costPanel.hideAll();
		panel:GetLogicChild('costPanel'):GetLogicChild('coin_scroll').Visibility = Visibility.Visible;
		panel:GetLogicChild('costPanel'):GetLogicChild('cost').Text = tostring(num);
	end
	costPanel.setGreenScroll = function(num)
		costPanel.hideAll();
		panel:GetLogicChild('costPanel'):GetLogicChild('gem_scroll').Visibility = Visibility.Visible;
		panel:GetLogicChild('costPanel'):GetLogicChild('cost').Text = tostring(num);
	end
	costPanel.Hide = function()
		panel:GetLogicChild('costPanel').Visibility = Visibility.Hidden;
	end
	costPanel.Show = function()
		panel:GetLogicChild('costPanel').Visibility = Visibility.Visible;
	end


	itemList = {};
	itemSp = {};
	item = {};
	onePanel = panel:GetLogicChild('onePanel');
	item.setVisibility = function(flag)
		onePanel.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
	item.setIconVisibility = function(flag)
		onePanel:GetLogicChild('item').Visibility = flag and Visibility.Visible or Visibility.Hidden;
		onePanel:GetLogicChild('name').Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
	item.item = customUserControl.new(onePanel:GetLogicChild('item'), 'itemTemplate');
	item.setName = function(name)
		onePanel:GetLogicChild('name').Text = tostring(name);
	end

	tenPanel = panel:GetLogicChild('tenPanel');
	itemList.setVisibility = function(flag)
		tenPanel.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
	for i=1, 10 do
		itemList[i] = {};
		itemList[i].setVisibility = function(flag)
			tenPanel:GetLogicChild(tostring(i)):GetLogicChild('item').Visibility = flag and Visibility.Visible or Visibility.Hidden;
			tenPanel:GetLogicChild(tostring(i)):GetLogicChild('name').Visibility = flag and Visibility.Visible or Visibility.Hidden;
		end
		itemList[i].item = customUserControl.new(tenPanel:GetLogicChild(tostring(i)):GetLogicChild('item'), 'itemTemplate');
		itemList[i].setName = function(name)
			tenPanel:GetLogicChild(tostring(i)):GetLogicChild('name').Text = tostring(name);
		end
	end
	itemList.hideAll = function()
		for i=1, 10 do
			itemList[i].setVisibility(false);
		end
	end

	spPanel = panel:GetLogicChild('spPanel'); 
	itemSp.setVisibility = function(flag)
		spPanel.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	end
	for i=1, 14 do
		itemSp[i] = {};
		itemSp[i].setVisibility = function(flag)
			spPanel:GetLogicChild(tostring(i)):GetLogicChild('item').Visibility = flag and Visibility.Visible or Visibility.Hidden;
			spPanel:GetLogicChild(tostring(i)):GetLogicChild('name').Visibility = flag and Visibility.Visible or Visibility.Hidden;
		end
		itemSp[i].item = customUserControl.new(spPanel:GetLogicChild(tostring(i)):GetLogicChild('item'), 'itemTemplate');
		itemSp[i].setName = function(name)
			spPanel:GetLogicChild(tostring(i)):GetLogicChild('name').Text = tostring(name);
		end
	end
	itemSp.hideAll = function()
		for i=1, 14 do
			itemSp[i].setVisibility(false);
		end
	end


	jinbi_1 = resTableManager:GetValue(ResTable.config, tostring(1), 'value');
	jinbi_10 = resTableManager:GetValue(ResTable.config, tostring(2), 'value');
	zhizun_1 = resTableManager:GetValue(ResTable.config, tostring(3), 'value');
	zhizun_10 = resTableManager:GetValue(ResTable.config, tostring(4), 'value');
	shenmi_1 = resTableManager:GetValue(ResTable.config, tostring(5), 'value');
	shenmi_10 = resTableManager:GetValue(ResTable.config, tostring(6), 'value');

	--动画位置
	original_pos_one = Rect(60, 160, 0, 0);
	original_pos_ten = Rect(370, 155, 0, 0);
	aim_pos_one = Rect(60+2, 60-11, 0, 0);
	aim_pos_ten = {};
	for i=1, 10 do
		local x = (i <= 5) and ((i-1)*155+60) or ((i-6)*155+60);
		local y = (i <= 5) and 60 or 220;
		aim_pos_ten[i] = Rect(x+2, y-11, 0, 0);
	end
	--动画内容
	tenArmList = {};
	path = GlobalData.EffectPath .. 'item_chouka_output/';
	AvatarManager:LoadFile(path);
	path = GlobalData.EffectPath .. 'item10_chouka_output/';
	AvatarManager:LoadFile(path);
	spArmList = {};

	--碎片对应关系
	configList = {};
	configList[1] = 7;
	configList[2] = 8;
	configList[3] = 9;
	configList[4] = 10;
	configList[5] = 11;

	--是否由整卡拆成碎片
	reducedList = {};
	infoLabel =	rolePanel:GetLogicChild('info');
	infoLabel.Visibility = Visibility.Hidden;
end

--销毁
function ZhaomuResultPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function ZhaomuResultPanel:Show()
	if WingPanel:isVisible() then
		panel.ZOrder = PanelZOrder.ZhaomuResult + PanelZOrder.wing;
	elseif HomePanel:returnVisble() then
		panel.ZOrder = PanelZOrder.ZhaomuResult + PanelZOrder.cardinfo;
	else
		panel.ZOrder = PanelZOrder.ZhaomuResult;
	end
	ZhaomuPanel:unLock();

	panel:GetLogicChild('costPanel'):GetLogicChild('coin_scroll').Image = GetPicture('icon/10012.ccz');
	panel:GetLogicChild('costPanel'):GetLogicChild('gem_scroll').Image = GetPicture('icon/10013.ccz');
	panel.Visibility = Visibility.Visible;
	armStage = 0;
	touchPanel.Visibility = Visibility.Visible;
	if ZhaomuPanel.pub_type == 1 or ZhaomuPanel.pub_type == 3 then
		self:showOneArm();
		costPanel.Hide();
	elseif ZhaomuPanel.pub_type == 2 or ZhaomuPanel.pub_type == 4 then
		tenIndex = 1;
		disappearArmIndex = 0;
		self:showTenArm();
		costPanel.Hide();
	elseif ZhaomuPanel.pub_type == 7 or ZhaomuPanel.pub_type == 5 then
		spIndex = 1;
		disappearArmIndex = 0;
		self:showSpArm();
		costPanel.Hide();
	end

	bg.Background = CreateTextureBrush('background/default_bg.jpg', 'background');
--[[
	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		UserGuidePanel:ShowGuideShade(rolePanel:GetLogicChild('sure'),GuideEffectType.hand, GuideTipPos.right);
	end
--]]
end

--隐藏
function ZhaomuResultPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

function ZhaomuResultPanel:HideCostPanel()
	costPanel.Hide();
	if btnOne.Visibility == Visibility.Visible then
		flag_show_one = true;
		btnOne.Visibility = Visibility.Hidden;
	else
		flag_show_one = false;
	end

	if btnTen.Visibility == Visibility.Visible then
		flag_show_ten = true;
		btnTen.Visibility = Visibility.Hidden;
	else
		flag_show_ten = false;
	end
	btnSure.Visibility = Visibility.Hidden;
end

function ZhaomuResultPanel:ShowCostPanel()
	costPanel.Show();
	if flag_show_one then
		btnOne.Visibility = Visibility.Visible;
	end
	if flag_show_ten then
		btnTen.Visibility = Visibility.Visible;
	end
	btnSure.Visibility = Visibility.Visible;
end

--刷新
function ZhaomuResultPanel:refresh(msg)
	itemResid = -1
	reducedList = {};
	btnSure.Visibility = Visibility.Hidden;
	if ZhaomuPanel.pub_type == 1 or ZhaomuPanel.pub_type == 3 then
		item.setVisibility(false);
		item.setIconVisibility(false);
		itemList.setVisibility(false);
		itemList.hideAll();
		labelTip.Text = LANG_ZHAOMU_TIP_1;
		btnOne.Visibility = Visibility.Hidden;
		btnTen.Visibility = Visibility.Hidden;
		itemSp.hideAll();

		--物品
		if #(msg.items) > 0 then
			for _, it in pairs(msg.items) do
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				item.item.initWithInfo(it.resid, it.num, 120, true);	
				item.setName(it_name);
				itemResid = it.resid
			end
		end
		--碎片
		if #(msg.chips) > 0 then
			for _, it in pairs(msg.chips) do
				local count = it.count;
				if it.resid < 10000 then
					it.resid = it.resid+40000;
					count = -1;
				end
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				item.item.initWithInfo(it.resid, count, 120, true);	
				if it.resid == 30101 or it.resid == 30102 or it.resid == 30103 then
					item.setName(LANG_ZHAOMU_TIP_6);
				else
					item.setName(it_name);
				end
				itemResid = it.resid
				if it.reduced == 1 then
					reducedList[1] = true;
					--item.setName(LANG_ZHAOMU_TIP_4);
				end
			end
		end
		--人物
		if #(msg.partners) > 0 then
			for _, role in pairs(msg.partners) do
				ActorManager:AddRole(role);
			end
		end
	elseif ZhaomuPanel.pub_type == 2 or ZhaomuPanel.pub_type == 4 then
		item.setVisibility(false);
		item.setIconVisibility(false);
		itemList.setVisibility(false);
		itemList.hideAll();
		labelTip.Text = LANG_ZHAOMU_TIP_2;
		btnOne.Visibility = Visibility.Hidden;
		btnTen.Visibility = Visibility.Hidden;
		itemSp.hideAll();

		local cid = 1;
		--物品
		if #(msg.items) > 0 then
			for _, it in pairs(msg.items) do
				local it_icon = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'icon');
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				
				itemList[cid].item.initWithInfo(it.resid, it.num, 120, true);
				itemList[cid].setName(it_name);
				cid = cid + 1;
			end
		end
		--碎片
		if #(msg.chips) > 0 then
			for _, it in pairs(msg.chips) do
				local count = it.count;
				if it.resid < 10000 then
					it.resid = it.resid+40000;
					count = -1;
				end
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				itemList[cid].item.initWithInfo(it.resid, count, 120, true);
				if it.resid == 30101 or it.resid == 30102 or it.resid == 30103 then
					itemList[cid].setName(LANG_ZHAOMU_TIP_6);
				else
					itemList[cid].setName(it_name);
				end
				if it.reduced == 1 then
					--itemList[cid].setName(LANG_ZHAOMU_TIP_4);
					reducedList[cid] = true;
				end
				cid = cid + 1;
			end
		end
		--人物
		if #(msg.partners) > 0 then
			for _, role in pairs(msg.partners) do
				ActorManager:AddRole(role);
			end
		end
	elseif ZhaomuPanel.pub_type == 7 or ZhaomuPanel.pub_type == 5 then
		item.setVisibility(false);
		item.setIconVisibility(false);
		itemList.setVisibility(false);
		itemList.hideAll();
		labelTip.Text = LANG_ZHAOMU_TIP_2;
		btnOne.Visibility = Visibility.Hidden;
		btnTen.Visibility = Visibility.Hidden;
		btnSure.Visibility = Visibility.Visible;
		itemSp.hideAll();
		self.show_num = msg.draw_num;

		local cid = 1;
		--物品
		if #(msg.items) > 0 then
			for _, it in pairs(msg.items) do
				local it_icon = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'icon');
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				
				itemSp[cid].item.initWithInfo(it.resid, it.num, 120, true);
				itemSp[cid].setName(it_name);
				cid = cid + 1;
			end
		end
		--碎片
		if #(msg.chips) > 0 then
			for _, it in pairs(msg.chips) do
				local count = it.count;
				if it.resid < 10000 then
					it.resid = it.resid+40000;
					count = -1;
				end
				local it_name = resTableManager:GetValue(ResTable.item, tostring(it.resid), 'name');
				itemSp[cid].item.initWithInfo(it.resid, count, 120, true);
				if it.resid == 30101 or it.resid == 30102 or it.resid == 30103 then
					itemSp[cid].setName(LANG_ZHAOMU_TIP_6);
				else
					itemSp[cid].setName(it_name);
				end
				if it.reduced == 1 then
					--itemSp[cid].setName(LANG_ZHAOMU_TIP_4);
					reducedList[cid] = true;
				end
				cid = cid + 1;
			end
		end
		--人物
		if #(msg.partners) > 0 then
			for _, role in pairs(msg.partners) do
				ActorManager:AddRole(role);
			end
		end
	end

	--刷新再次刷新的材料
	if ZhaomuPanel.pub_type == 1 then
		if Package:GetItem(10012).num >= 1 then
			costPanel.setRedScroll(1);
		else
			costPanel.setMoney(jinbi_1);
		end
	elseif ZhaomuPanel.pub_type == 2 then
		if Package:GetItem(10012).num >= 10 then
			costPanel.setRedScroll(10);
		else
			costPanel.setMoney(jinbi_10);
		end
	elseif ZhaomuPanel.pub_type == 3 then
		if Package:GetItem(10013).num >= 1 then
			costPanel.setGreenScroll(1);
		else
			costPanel.setZS(zhizun_1);
		end
	elseif ZhaomuPanel.pub_type == 4 then
		if Package:GetItem(10013).num >= 10 then
			costPanel.setGreenScroll(10);
		else
			costPanel.setZS(zhizun_10);
		end
	end
	if #(msg.partners) > 0 then
		for _, role in pairs(msg.partners) do
			MutipleTeam:addPartnerToDefaultTeam(role.pid);
		end
	end
end

--========================================================
--功能函数

--继续招募
function ZhaomuResultPanel:onOne()
	self:destroyItemSound()
	if ZhaomuPanel.pub_type == 1 then
		ZhaomuPanel:commonZhaomuOne();
	elseif ZhaomuPanel.pub_type == 3 then
		ZhaomuPanel:zhizunZhaomuOne();
	elseif ZhaomuPanel.pub_type == 5 then
		ZhaomuPanel:shenmiZhaomuOne();
	end
end

function ZhaomuResultPanel:onTen()
	self:destroyItemSound()
	if ZhaomuPanel.pub_type == 2 then
		ZhaomuPanel:commonZhaomuTen();
	elseif ZhaomuPanel.pub_type == 4 then
		ZhaomuPanel:zhizunZhaomuTen();
	end
end

--确认并关闭
function ZhaomuResultPanel:onSure()
	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		UserGuidePanel:ShowGuideShade(ZhaomuPanel:GetRetrunBtn(),GuideEffectType.hand, GuideTipPos.right);
	end
	self:Hide();
	self:destroyItemSound()
	if ZhaomuPanel.pub_type == 7 or ZhaomuPanel.pub_type == 5 then
		ZhaomuPanel:showStepupArm();
	end
	--ZhaomuPanel:setCenterVisible(true);
end

function ZhaomuResultPanel:showTenArm()
	armStage = 1;
	itemList.setVisibility(true);
	item10Center = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	item10Center.Horizontal = ControlLayout.H_CENTER;
	item10Center.Vertical = ControlLayout.V_CENTER;
	item10Center.Visibility = Visibility.Visible;
	item10Center.Margin = Rect(0,0,0,0);
	item10Center:LoadArmature('center10_chouka');
	item10Center:SetAnimation('play');
	tenPanel:AddChild(item10Center);
	item10Center:SetScriptAnimationCallback('ZhaomuResultPanel:playTenArm', 0);

	for i=1, 10 do
		tenArmList[i] = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
		tenArmList[i].Horizontal = ControlLayout.H_CENTER;
		tenArmList[i].Vertical = ControlLayout.V_CENTER;
		tenArmList[i].Visibility = Visibility.Visible;
		tenArmList[i].Margin = Rect(0, 0, 0, 0);
		tenArmList[i]:LoadArmature('item10_chouka');
		tenArmList[i]:SetAnimation('play1'); 
		tenPanel:GetLogicChild(tostring(i)):GetLogicChild('arm'):RemoveAllChildren();
		tenPanel:GetLogicChild(tostring(i)):GetLogicChild('arm'):AddChild(tenArmList[i]);
	end
end

function ZhaomuResultPanel:showSpArm()
	armStage = 1;
	itemSp.setVisibility(true);
	item14Sp = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	item14Sp.Horizontal = ControlLayout.H_CENTER;
	item14Sp.Vertical = ControlLayout.V_CENTER;
	item14Sp.Visibility = Visibility.Visible;
	item14Sp.Margin = Rect(0,0,0,0);
	item14Sp:LoadArmature('center10_chouka');
	item14Sp:SetAnimation('play');
	spPanel:AddChild(item14Sp);
	item14Sp:SetScriptAnimationCallback('ZhaomuResultPanel:playSpArm', 0);

	for i=1, self.show_num do
		spArmList[i] = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
		spArmList[i].Horizontal = ControlLayout.H_CENTER;
		spArmList[i].Vertical = ControlLayout.V_CENTER;
		spArmList[i].Visibility = Visibility.Visible;
		spArmList[i].Margin = Rect(0, 0, 0, 0);
		spArmList[i]:LoadArmature('item10_chouka');
		spArmList[i]:SetAnimation('play1'); 
		spPanel:GetLogicChild(tostring(i)):GetLogicChild('arm'):RemoveAllChildren();
		spPanel:GetLogicChild(tostring(i)):GetLogicChild('arm'):AddChild(spArmList[i]);
	end
end

function ZhaomuResultPanel:destroyItemRoleSound()
	if itemRoleSound then
		soundManager:DestroySource(itemRoleSound);
		itemRoleSound = nil
	end
end
function ZhaomuResultPanel:destroyItemSound()
	if itemSound then
		soundManager:DestroySource(itemSound);
		itemSound = nil
	end
end
function ZhaomuResultPanel:playItemSound(itResid)
	if itResid > 40000 then
		local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(itResid-40000));
		if naviInfo['soundlist'] then
			local voiceNum = math.random(1,#naviInfo['soundlist'])
			itemRoleSound = SoundManager:PlayVoice(naviInfo['soundlist'][voiceNum]);
		end
	else
		self:destroyItemSound()
		itemSound = SoundManager:PlayEffect( 'v1100' );
	end
end
function ZhaomuResultPanel:showOneArm()
	armStage = 1;
	oneArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	oneArm.Horizontal = ControlLayout.H_LEFT;
	oneArm.Vertical = ControlLayout.V_TOP;
	onePanel:AddChild(oneArm);
	item.setVisibility(true);
	oneArm.Margin = original_pos_one;
	oneArm:LoadArmature('item_chouka');
	oneArm:SetAnimation('play1');
	oneArm:SetScale(0.9,0.9);
	oneArm.Visibility = Visibility.Visible;

	arm_one_play_elapse = 0;
	timer = timerManager:CreateTimer(0.02, 'ZhaomuResultPanel:playOneArm', 0);
end

function ZhaomuResultPanel:playTenArm()
	armStage = 2;
	for i=1, 10 do
		tenArmList[i]:SetAnimation('keep');
	end
	if timer_stage_2 ~= 0 then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
	end
	timer_stage_2 = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showTenOnebyOne', 0);
end

function ZhaomuResultPanel:playSpArm()
	armStage = 2;
	for i=1, self.show_num do
		spArmList[i]:SetAnimation('keep');
	end
	if timer_stage_2 ~= 0 then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
	end
	timer_stage_2 = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showSpOnebyOne', 0);
end

function ZhaomuResultPanel:playOneArm()
	armStage = 2;
	if arm_one_play_elapse*0.02 >= 0.5 then
		arm_one_play_elapse = 0;
		timerManager:DestroyTimer(timer);
		oneArm:SetAnimation('play2');
		timer = 0;
    oneArm:SetScriptAnimationCallback('ZhaomuResultPanel:showOne', 0);
		--timer = timerManager:CreateTimer(0.5, 'ZhaomuResultPanel:showOne', 0);
		return;
	end
	local x = original_pos_one.Left + (aim_pos_one.Left - original_pos_one.Left)/25*arm_one_play_elapse;
	local y = original_pos_one.Top + (aim_pos_one.Top - original_pos_one.Top)/25*arm_one_play_elapse;
	oneArm.Margin = Rect(x, y, 0, 0);
	arm_one_play_elapse = arm_one_play_elapse + 1;
end

function ZhaomuResultPanel:showTenOnebyOne()
	armStage = 3;
	if tenIndex > 10 then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
		touchPanel.Visibility = Visibility.Hidden;
		btnTen.Visibility = Visibility.Visible;
		btnSure.Visibility = Visibility.Visible;
		costPanel.Show();
		return;
	end
	tenArmList[tenIndex]:SetAnimation('play2');
	tenArmList[tenIndex]:SetScriptAnimationCallback('ZhaomuResultPanel:showTenImg', tenIndex);
	self:checkIsRole('ZhaomuResultPanel:showTenOnebyOne', tenIndex, itemList);
	tenIndex = tenIndex + 1;
end

function ZhaomuResultPanel:showSpOnebyOne()
	armStage = 3;
	if spIndex > self.show_num then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
		touchPanel.Visibility = Visibility.Hidden;
		btnSure.Visibility = Visibility.Visible;
		return;
	end
	spArmList[spIndex]:SetAnimation('play2');
	spArmList[spIndex]:SetScriptAnimationCallback('ZhaomuResultPanel:showSpImg', spIndex);
	self:checkIsRole('ZhaomuResultPanel:showSpOnebyOne', spIndex, itemSp);
	spIndex = spIndex + 1;
end

function ZhaomuResultPanel:checkIsRole(call_back, index, list)
	if list[index].item.isRole() then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
		self:onShowRoleImg(list[index].item.getRoleResid(),
		function()
			timer_stage_2 = timerManager:CreateTimer(0.2, call_back, 0);
		end);
	elseif reducedList[index] then
		timerManager:DestroyTimer(timer_stage_2);
		timer_stage_2 = 0;
		self:onShowRoleImg(list[index].item.getChipResid(),
		function()
			timer_stage_2 = timerManager:CreateTimer(0.2, call_back, 0);
		end, true);
	end
end

function ZhaomuResultPanel:showTenImg(coming, index)
	disappearArmIndex = index;
	itemList[index].setVisibility(true);
	if not itemList[index].item.isRole() and not reducedList[index] then
		self:playItemSound(itemList[index].item.getResid())
	end
end

function ZhaomuResultPanel:showSpImg(coming, index)
	disappearArmIndex = index;
	itemSp[index].setVisibility(true);
	if not itemSp[index].item.isRole() and not reducedList[index] then
		self:playItemSound(itemSp[index].item.getResid())
	end
end

function ZhaomuResultPanel:showOne()
	armStage = 3;
	oneArm.Visibility = Visibility.Hidden;
	item.setIconVisibility(true);
	local itemFlag = true
	if item.item.isRole() then
		self:onShowRoleImg(item.item.getRoleResid());
		itemFlag = false
	end
	if reducedList[1] then
		self:onShowRoleImg(item.item.getChipResid(),nil,true);
		itemFlag = false
	end
	if itemFlag then
		self:playItemSound(itemResid)
	end
	touchPanel.Visibility = Visibility.Hidden;
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		btnOne.Visibility = Visibility.Hidden;
	else
		btnOne.Visibility = Visibility.Visible;
	end
	btnSure.Visibility = Visibility.Visible;
	costPanel.Show();
	timerManager:DestroyTimer(timer);
	timer = 0;
end

function ZhaomuResultPanel:gotoSkip()
	if isSkip then
		return;
	end
	isSkip = true;
	skipTimer = timerManager:CreateTimer(0.5, 'ZhaomuResultPanel:skipArm', 0);
end

function ZhaomuResultPanel:skipArm()
	timerManager:DestroyTimer(skipTimer);
	skipTimer = 0;
	isSkip = false;
	if timer_stage_2 == 0 then
		return;
	end
	timerManager:DestroyTimer(timer_stage_2);
	timer_stage_2 = 0;
	if ZhaomuPanel.pub_type == 1 or ZhaomuPanel.pub_type == 3 then
		oneArm.Visibility = Visibility.Hidden;
		item.setIconVisibility(true);
		if item.item.isRole() then
			self:onShowRoleImg(item.item.getRoleResid());
		end
		if reducedList[1] then
			self:onShowRoleImg(item.item.getChipResid(),nil,true);
		end
		touchPanel.Visibility = Visibility.Hidden;
		if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
			btnOne.Visibility = Visibility.Hidden;
		else
			btnOne.Visibility = Visibility.Visible;
		end
		btnSure.Visibility = Visibility.Visible;
		costPanel.Show();
	elseif ZhaomuPanel.pub_type == 2 or ZhaomuPanel.pub_type == 4 then
		local findRoleIndex,flag = self:findNextRoleIndex(itemList, tenIndex, 10);
		if findRoleIndex > 10 then
			for i=disappearArmIndex+1, 10 do
				tenArmList[i].Visibility = Visibility.Hidden;
			end
			for i=1, 10 do
				itemList[i].setVisibility(true);
			end
			touchPanel.Visibility = Visibility.Hidden;
			btnTen.Visibility = Visibility.Visible;
			btnSure.Visibility = Visibility.Visible;
			costPanel.Show();
			return;
		end
		local startShow;
		if armStage == 1 then
			item10Center.Visibility = Visibility.Hidden;
			startShow = 1;
		elseif armStage == 2 then
			startShow = 1;
		elseif armStage == 3 then
			startShow = tenIndex;
		end

		for i=disappearArmIndex+1, findRoleIndex do
			tenArmList[i].Visibility = Visibility.Hidden;
		end
		for i=1, findRoleIndex do
			itemList[i].setVisibility(true);
		end
		tenIndex = findRoleIndex + 1;
		if flag == 1 then
			self:onShowRoleImg(itemList[findRoleIndex].item.getRoleResid(),
			function()
				timer = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showTenOnebyOne', 0);
			end);
		elseif flag == 2 then
			self:onShowRoleImg(itemList[findRoleIndex].item.getChipResid(), function()
				timer = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showTenOnebyOne', 0);
			end,true);
		end
	elseif ZhaomuPanel.pub_type == 7 or ZhaomuPanel.pub_type == 5 then
		local findRoleIndex,flag = self:findNextRoleIndex(itemSp, spIndex, self.show_num);
		if findRoleIndex > self.show_num then
			for i=disappearArmIndex+1, self.show_num do
				spArmList[i].Visibility = Visibility.Hidden;
			end
			for i=1, self.show_num do
				itemSp[i].setVisibility(true);
			end
			touchPanel.Visibility = Visibility.Hidden;
			btnSure.Visibility = Visibility.Visible;
			return;
		end

		for i=disappearArmIndex+1, findRoleIndex do
			spArmList[i].Visibility = Visibility.Hidden;
		end
		for i=1, findRoleIndex do
			itemSp[i].setVisibility(true);
		end
		spIndex = findRoleIndex + 1;
		if flag == 1 then
			self:onShowRoleImg(itemSp[findRoleIndex].item.getRoleResid(),
			function()
				timer_stage_2 = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showSpOnebyOne', 0);
			end);
		elseif flag == 2 then
			self:onShowRoleImg(itemSp[findRoleIndex].item.getChipResid(), function()
				timer_stage_2 = timerManager:CreateTimer(0.3, 'ZhaomuResultPanel:showSpOnebyOne', 0);
			end,true);
		end
	end
end

function ZhaomuResultPanel:findNextRoleIndex(list, index_in, top)
	local isFind=false;
	local flag = 0;
	local index = index_in;
	while((not isFind) and (index<=top)) do
		if list[index].item.isRole() then
			isFind=true;
			flag = 1;
			break;
		end
		if reducedList[index] then
			isFind=true;
			flag = 2;
			break;
		end
		index = index + 1; 
	end
	return index,flag;
end

function ZhaomuResultPanel:onShowRoleImg(resid, fun, isChip)
	callback = fun or nil;
	isChip = isChip or false;

	--背景
	rolePanel.Background = CreateTextureBrush('background/default_bg.jpg', 'background');

	rolePanel.Visibility = Visibility.Visible;

	--人物
	local path = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'role_path');
	roleImg.Image = GetPicture('navi/' .. path .. '.ccz');
	self:playItemSound(resid+40000)
	--显示是否为整卡拆分碎片
	if isChip then
		--infoLabel.Visibility = Visibility.Visible;
		local quality = resTableManager:GetValue(ResTable.item, tostring(resid+30000), 'quality');
		infoLabel.Text = string.format(LANG_ZHAOMU_TIP_3,resTableManager:GetValue(ResTable.item, tostring(resid+40000), 'name'), resTableManager:GetValue(ResTable.item, tostring(resid+30000), 'name'), resTableManager:GetValue(ResTable.config, tostring(configList[quality]), 'value'));
	else
		--infoLabel.Visibility = Visibility.Hidden;
	end

	--动画
	local frontArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	frontArm:LoadArmature('role_chouka_front');
	frontArm:SetAnimation('play');
	roleArmFront:AddChild(frontArm);
	local backArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	backArm:LoadArmature('role_chouka_back');
	backArm:SetAnimation('play');
	roleArmBack:AddChild(backArm);
end

function ZhaomuResultPanel:onback()
	self:destroyItemRoleSound()		
	rolePanel.Visibility = Visibility.Hidden;
	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		UserGuidePanel:ShowGuideShade(btnSure,GuideEffectType.hand, GuideTipPos.right);
	end

	roleArmFront:RemoveAllChildren();
	roleArmBack:RemoveAllChildren();

	--背景
	DestroyBrushAndImage('background/default_bg.jpg', 'background');

	if callback then
		callback();
	end
end
