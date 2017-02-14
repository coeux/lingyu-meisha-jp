--sweaponPanel.lua
--============================================================
--专属武器界面

SWeaponPanel =
	{
		cur_weapon = -1;
		choose_weapon = -1;
		own_weapon = {};
		is_genpro = false;
	};

--控件
local mainDesktop;
local panel;
local centerPanel;
local brushs = {};
local main_brush;
local btn_save;
local btn_wear;
local btn_takeoff;
local btn_gen;
local brush_blank;
local brush_point;
local image_main;
local namePanel;
local weaponListPanel;
local brush_list_bg;
local brush_left;
local brush_right;
local listPanel;
local label_gem;
local attPanelLeft = {};
local attPanelRight = {};
local bg;
local costPanel;
local warnPanel;
local shader2;
local illPanel;
local ill_bg;
local ill_word;

--变量
--常量
local fontColor = Color(0, 15, 78, 255);
local fontColorUp = Color(184, 53, 53, 255);
local fontColorDown = Color(64, 106, 242, 255);

--初始化界面
function SWeaponPanel:InitPanel( desktop )
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('SWeaponPanel'));
	panel.ZOrder = PanelZOrder.sweapon;
	panel.Visibility = Visibility.Hidden;
	centerPanel = panel:GetLogicChild('centerPanel');
	for i=1, 5 do
		brushs[i] = centerPanel:GetLogicChild('brush'..i);
	end
	main_brush = centerPanel:GetLogicChild('main_brush');
	main_brush:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:enterChooseMode');
	btn_save = centerPanel:GetLogicChild('btn_save');
	btn_save:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:saveGenPro');
	btn_wear = centerPanel:GetLogicChild('btn_wear');
	btn_wear:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:wear');
	btn_takeoff = centerPanel:GetLogicChild('btn_takeoff');
	btn_takeoff:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:takeoff');
	btn_gen = centerPanel:GetLogicChild('btn_gen');
	btn_gen:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:reqGenPro');
	brush_blank = main_brush:GetLogicChild('brush_blank');
	brush_point = centerPanel:GetLogicChild('brush_point');
	image_main = main_brush:GetLogicChild('img');
	namePanel = centerPanel:GetLogicChild('namePanel');
	centerPanel:GetLogicChild('closeBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'SWeaponPanel:onBack');

	costPanel = centerPanel:GetLogicChild('costPanel');
	label_gem = centerPanel:GetLogicChild('gemPanel'):GetLogicChild('num');

	weaponListPanel = centerPanel:GetLogicChild('weaponListPanel');
	brush_list_bg = weaponListPanel:GetLogicChild('brush_list_bg');
	brush_left = weaponListPanel:GetLogicChild('brush_left');
	brush_right = weaponListPanel:GetLogicChild('brush_right');
	listPanel = weaponListPanel:GetLogicChild('touchPanel'):GetLogicChild('listPanel');

	warnPanel = panel:GetLogicChild('infoPanel');
	warnPanel.Visibility = Visibility.Hidden;
	shader2 = panel:GetLogicChild('shader2');
	shader2.Visibility = Visibility.Hidden;
	warnPanel:GetLogicChild('cancel'):SubscribeScriptedEvent('Button::ClickEvent', 'SWeaponPanel:cancelWarnPanel');
	warnPanel:GetLogicChild('sure'):SubscribeScriptedEvent('Button::ClickEvent', 'SWeaponPanel:sureWarnPanel');

	illPanel = panel:GetLogicChild('illPanel');
	illPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SWeaponPanel:hideIll');
	centerPanel:GetLogicChild('btn_ill'):SubscribeScriptedEvent('Button::ClickEvent', 'SWeaponPanel:showIll');
	ill_bg = illPanel:GetLogicChild('brush_ill_bg');
	ill_word = illPanel:GetLogicChild('brush_ill_word');
	for i=1, 5 do
		attPanelLeft[i] = {};
		attPanelLeft[i].panel = brushs[3]:GetLogicChild('panel'..i);
		attPanelLeft[i].mark = attPanelLeft[i].panel:GetLogicChild('mark');
		attPanelLeft[i].label = attPanelLeft[i].panel:GetLogicChild('label');
		attPanelLeft[i].value = attPanelLeft[i].panel:GetLogicChild('value');
		attPanelRight[i] = {};
		attPanelRight[i].panel = brushs[4]:GetLogicChild('panel'..i);
		attPanelRight[i].mark = attPanelRight[i].panel:GetLogicChild('mark');
		attPanelRight[i].label = attPanelRight[i].panel:GetLogicChild('label');
		attPanelRight[i].value = attPanelRight[i].panel:GetLogicChild('value');
	end

	bg = centerPanel:GetLogicChild('bg');
end

function SWeaponPanel:Destroy()
	panel = nil;
end

function SWeaponPanel:onShow(pid)
	self.pid = pid;
	self:Show();
end

function SWeaponPanel:Show()
	brushs[1].Background = CreateTextureBrush('home/sweapon_brush1.ccz', 'home');
	brushs[2].Background = CreateTextureBrush('home/sweapon_brush2.ccz', 'home');
	brushs[3].Background = CreateTextureBrush('home/sweapon_brush3.ccz', 'home');
	brushs[4].Background = CreateTextureBrush('home/sweapon_brush3.ccz', 'home');
	brushs[5].Background = CreateTextureBrush('home/sweapon_brush4.ccz', 'home');
	main_brush.Background = CreateTextureBrush('home/sweapon_icon.ccz', 'home');
	btn_save.Background = CreateTextureBrush('home/sweapon_btn_save.ccz', 'home');
	btn_wear.Background = CreateTextureBrush('home/sweapon_btn_wear.ccz', 'home');
	btn_takeoff.Background = CreateTextureBrush('home/sweapon_btn_takeoff.ccz', 'home');
	btn_gen.Background = CreateTextureBrush('home/sweapon_btn_strengthen.ccz', 'home');
	brush_blank.Background = CreateTextureBrush('home/sweapon_blank.ccz', 'home');
	brush_point.Background = CreateTextureBrush('home/sweapon_brush5.ccz', 'home');
	brush_list_bg.Background = CreateTextureBrush('home/sweapon_list_bg.ccz', 'home');
	brush_left.Background = CreateTextureBrush('home/sweapon_list_side_left.ccz', 'home');
	brush_right.Background = CreateTextureBrush('home/sweapon_list_side_right.ccz', 'home');
	ill_bg.Background = CreateTextureBrush('home/sweapon_ill_bg.ccz', 'home');
	ill_word.Background = CreateTextureBrush('home/sweapon_ill_word.ccz', 'home');
	bg.Background = CreateTextureBrush('home/sweapon_bg.ccz', 'home');
	panel.Visibility = Visibility.Visible;
	btn_save.Visibility = Visibility.Hidden;

	self:initSWeaponList();
	self:enterAttributeMode();
	self:bind();
	uiSystem:UpdateDataBind();
end

function SWeaponPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', label_gem, 'Text');
end

function SWeaponPanel:onBack()
	if self.is_genpro then
		self:showWarnPanel();
		return;
	end
	self:Hide();
end

function SWeaponPanel:Hide()
	panel.Visibility = Visibility.Hidden;

	for i=1, 4 do
		DestroyBrushAndImage('home/sweapon_brush'..i..'.ccz', 'home');
	end
	for i=1, 5 do
		brushs[i].Background = nil;
	end
	DestroyBrushAndImage('home/sweapon_bg.ccz', 'home');
	bg.Background = nil;
	DestroyBrushAndImage('home/sweapon_icon.ccz', 'home');
	main_brush.Background = nil;
	DestroyBrushAndImage('home/sweapon_btn_save.ccz', 'home');
	btn_save.Background = nil;
	DestroyBrushAndImage('home/sweapon_btn_wear.ccz', 'home');
	btn_wear.Background = nil;
	DestroyBrushAndImage('home/sweapon_btn_takeoff.ccz', 'home');
	btn_takeoff.Background = nil;
	DestroyBrushAndImage('home/sweapon_btn_strengthen.ccz', 'home');
	btn_gen.Background = nil;
	DestroyBrushAndImage('home/sweapon_blank.ccz', 'home');
	brush_blank.Background = nil;
	DestroyBrushAndImage('home/sweapon_list_bg.ccz', 'home');
	brush_list_bg.Background = nil;
	DestroyBrushAndImage('home/sweapon_list_side_left.ccz', 'home');
	brush_left.Background = nil;
	DestroyBrushAndImage('home/sweapon_list_side_right.ccz', 'home');
	brush_right.Background = nil;
	DestroyBrushAndImage('home/sweapon_brush5.ccz', 'home');
	brush_point.Background = nil;
	DestroyBrushAndImage('home/sweapon_ill_bg.ccz', 'home');
	ill_bg.Background = nil;
	DestroyBrushAndImage('home/sweapon_ill_word.ccz', 'home');
	ill_word.Background = nil
	self:unbind();
end

function SWeaponPanel:unbind()
	uiSystem:UnBind(ActorManager.user_data, 'rmb', label_gem, 'Text');
end

function SWeaponPanel:initSWeaponList()
	self.cur_weapon = -1;
	self.own_weapon = {};

	self.weapon_sum = 0
	for id, weapon in pairs(ActorManager.user_data.functions.sweapon) do
		if weapon.pid == self.pid then
			self.cur_weapon = tonumber(id);
		end
		if weapon.owner == ActorManager:GetRole(self.pid).resid then
			self.weapon_sum = self.weapon_sum + 1;
			self.own_weapon[tonumber(id)] = weapon;
		end
	end
end

function SWeaponPanel:showMainWeaponInfoStrengthen(weapon_id)
	local weapon = self.own_weapon[weapon_id];
	if not weapon then
		self:hideWeaponInfo();
		return;
	end
	local itemWeaponData = resTableManager:GetRowValue(ResTable.item, tostring(weapon.resid));
	-- Main Icon init
	image_main.Visibility = Visibility.Visible;
	image_main.Image = GetPicture('icon/'..itemWeaponData['icon']..'.ccz');	
	-- attribute init
	self:showWeaponInfo();
	-- name init
	namePanel.Visibility = Visibility.Visible;
	namePanel:GetLogicChild('name').Text = tostring(itemWeaponData['name']);
	-- cost init 
	costPanel.Visibility = Visibility.Visible;
	local SWeaponData = resTableManager:GetRowValue(ResTable.sweapon, tostring(weapon.resid));
	costPanel:GetLogicChild('cost').Text = tostring(SWeaponData['cost']);
end

function SWeaponPanel:enterAttributeMode()
	brush_blank.Visibility = Visibility.Hidden;
	image_main.Visibility = Visibility.Hidden;
	namePanel.Visibility = Visibility.Hidden;
	btn_wear.Visibility = Visibility.Hidden;
	btn_takeoff.Visibility = Visibility.Hidden;
	if self.cur_weapon == -1 then
		brush_blank.Visibility = Visibility.Visible;		
	end
	self:showMainWeaponInfoStrengthen(self.cur_weapon);		

	weaponListPanel.Visibility = Visibility.Hidden;
	brushs[3].Visibility = Visibility.Visible;
	brushs[4].Visibility = Visibility.Visible;
end

function SWeaponPanel:enterChooseMode()
	if self.is_genpro then
		self:showWarnPanel();
		return;
	end
	brush_blank.Visibility = Visibility.Hidden;
	image_main.Visibility = Visibility.Hidden;
	namePanel.Visibility = Visibility.Hidden;
	costPanel.Visibility = Visibility.Hidden;
	self:showMainWeaponInfoChoose(self.cur_weapon);

	weaponListPanel.Visibility = Visibility.Visible;
	brushs[3].Visibility = Visibility.Hidden;
	brushs[4].Visibility = Visibility.Hidden;
	self:initWeaponListPanel();

	btn_wear.Visibility = Visibility.Visible;
	btn_gen.Visibility = Visibility.Hidden;
	if self.cur_weapon ~= -1 then
		btn_takeoff.Visibility = Visibility.Visible;
	end
end

function SWeaponPanel:showWeaponInfo()
	btn_gen.Visibility = Visibility.Visible;
	brush_point.Visibility = Visibility.Hidden;
	local weapon = self.own_weapon[self.cur_weapon]
	if not weapon then
		btn_gen.Visibility = Visibility.Hidden;
		return;
	end

	local index = 1;
	local att = {};
	att[1] = weapon.atk_ori + weapon.atk;
	att[2] = weapon.mgc_ori + weapon.mgc;
	att[3] = weapon.def_ori + weapon.def;
	att[4] = weapon.res_ori + weapon.res;
	att[5] = weapon.hp_ori + weapon.hp;
	for i=1, 5 do
		if att[i] > 0 then
			attPanelLeft[index].panel.Visibility = Visibility.Visible;
			attPanelLeft[index].mark.Visibility = Visibility.Hidden;
			attPanelLeft[index].label.Text = LANG_SWEAPON_ATT[i];
			attPanelLeft[index].label.TextColor = QuadColor(fontColor);
			attPanelLeft[index].value.Text = tostring(att[i]);
			attPanelLeft[index].value.TextColor = QuadColor(fontColor);
			index = index + 1;
		end
	end
	for i=index, 5 do
		attPanelLeft[i].panel.Visibility = Visibility.Hidden;
	end
	for i=1, 5 do
		attPanelRight[i].panel.Visibility = Visibility.Hidden;
	end	
end

function SWeaponPanel:hideWeaponInfo()
	for i=1, 5 do
		attPanelLeft[i].panel.Visibility = Visibility.Hidden;
		attPanelRight[i].panel.Visibility = Visibility.Hidden;
	end
	brush_point.Visibility = Visibility.Hidden;
	costPanel.Visibility = Visibility.Hidden;
	btn_gen.Visibility = Visibility.Hidden;
end

function SWeaponPanel:showMainWeaponInfoChoose(weapon_id)
	local weapon = self.own_weapon[weapon_id];
	if not weapon then
		return;
	end
	local itemWeaponData = resTableManager:GetRowValue(ResTable.item, tostring(weapon.resid));
	-- image
	image_main.Visibility = Visibility.Visible;
	image_main.Image = GetPicture('icon/'..itemWeaponData['icon']..'.ccz');	
	
	-- name
	namePanel.Visibility = Visibility.Visible;
	namePanel:GetLogicChild('name').Text = tostring(itemWeaponData['name']);
end

function SWeaponPanel:chooseWeapon(Args)
	local arg = UIControlEventArgs(Args);	
	local id = arg.m_pControl.Tag;
	self.choose_weapon = id;
	self:showMainWeaponInfoChoose(self.choose_weapon);
	self:updateWeaponListPanel();
end

function SWeaponPanel:initWeaponListPanel()
	listPanel:RemoveAllChildren();
	self.weaponList = {};
	local count = 1;
	for id, weapon in pairs(self.own_weapon) do
		local weaponItem = customUserControl.new(listPanel, 'sweaponTemplate');
		weaponItem.initWithInfo(weapon, self.own_weapon[self.cur_weapon]);
		self.weaponList[id] = weaponItem;
		if count < self.weapon_sum then
			local brush = BrushElement(uiSystem:CreateControl('BrushElement'));
			brush.Vertical = ControlLayout.V_CENTER;
			brush.Size = Size(18, 167);
			brush.Background = CreateTextureBrush('home/sweapon_list_brush.ccz', 'home');
			listPanel:AddChild(brush);
		end
		count = count + 1;
	end
	listPanel.Size = Size(180*count+18*(count-1), 250);
	weaponListPanel:GetLogicChild('touchPanel'):VScrollBegin();
end

function SWeaponPanel:updateWeaponListPanel()
	for id, weaponItem in pairs(self.weaponList) do
		weaponItem.update(self.own_weapon[self.choose_weapon]);
	end		
end

function SWeaponPanel:wear()
	if self.weapon_sum == 0 then
		self:enterAttributeMode();
		return;
	end
	if self.choose_weapon == -1 then
		return;
	end
	if self.cur_weapon == self.choose_weapon then
		self:enterAttributeMode();
		return;
	end
	local msg = {};
	msg.wear_id = self.choose_weapon;
	msg.pid = self.pid;
	Network:Send(NetworkCmdType.req_wear_sweapon_t, msg);
end

function SWeaponPanel:wear_call_back(msg)
	self.cur_weapon = msg.weapon_id;
	for _, weapon in pairs(self.own_weapon) do
		if weapon.pid == self.pid then
			weapon.pid = -1;
		end
	end
	for _, weapon in pairs(self.own_weapon) do
		if weapon.id == msg.weapon_id then
			weapon.pid = self.pid;
			break;
		end
	end
	self:enterAttributeMode();
	CardDetailPanel:UpdateSWeapon();
end

function SWeaponPanel:takeoff(w)
	if self.cur_weapon == -1 then
		return;
	end
	local msg = {};
	msg.takeoff_id = self.cur_weapon;
	msg.pid = self.pid;
	Network:Send(NetworkCmdType.req_takeoff_sweapon_t, msg);
end

function SWeaponPanel:takeoff_call_back(msg)
	for _, weapon in pairs(self.own_weapon) do
		if weapon.pid == self.pid then
			weapon.pid = -1;
		end
	end
	self.cur_weapon = -1;
	self:enterAttributeMode();
	CardDetailPanel:UpdateSWeapon();
end

function SWeaponPanel:reqGenPro()
	local msg = {};
	msg.weapon_id = self.cur_weapon;
	Network:Send(NetworkCmdType.req_sweapon_gen_pro_t, msg);
end

function SWeaponPanel:genpro_call_back(msg)
	self.is_genpro = true;
	brush_point.Visibility = Visibility.Visible;
	btn_save.Visibility = Visibility.Visible;
	local weapon = self.own_weapon[self.cur_weapon];
	if not weapon then
		return;
	end

	local index = 1;
	self.gen_att = {};
	self.gen_att[1] = msg.atk;
	self.gen_att[2] = msg.mgc;
	self.gen_att[3] = msg.def;
	self.gen_att[4] = msg.res;
	self.gen_att[5] = msg.hp;
	local cur_att = {};
	cur_att[1] = weapon.atk;
	cur_att[2] = weapon.mgc;
	cur_att[3] = weapon.def;
	cur_att[4] = weapon.res;
	cur_att[5] = weapon.hp;
	local ori_att = {};
	ori_att[1] = weapon.atk_ori;
	ori_att[2] = weapon.mgc_ori;
	ori_att[3] = weapon.def_ori;
	ori_att[4] = weapon.res_ori;
	ori_att[5] = weapon.hp_ori;
	for i=1, 5 do
		if self.gen_att[i] > 0 then
			attPanelRight[index].panel.Visibility = Visibility.Visible;
			if self.gen_att[i] > cur_att[i] then
				attPanelRight[index].mark.Visibility = Visibility.Visible;
				attPanelRight[index].mark.Background = CreateTextureBrush('home/sweapon_arrow_up.ccz', 'home');
				attPanelRight[index].label.Text = LANG_SWEAPON_ATT[i];
				attPanelRight[index].label.TextColor = QuadColor(fontColor);
				attPanelRight[index].value.Text = tostring(self.gen_att[i]+ori_att[i]);
				attPanelRight[index].value.TextColor = QuadColor(fontColorUp);
			elseif self.gen_att[i] < cur_att[i] then
				attPanelRight[index].mark.Visibility = Visibility.Visible;
				attPanelRight[index].mark.Background = CreateTextureBrush('home/sweapon_arrow_down.ccz', 'home');
				attPanelRight[index].label.Text = LANG_SWEAPON_ATT[i];
				attPanelRight[index].label.TextColor = QuadColor(fontColor);
				attPanelRight[index].value.Text = tostring(self.gen_att[i]+ori_att[i]);
				attPanelRight[index].value.TextColor = QuadColor(fontColorDown);
			else
				attPanelRight[index].mark.Visibility = Visibility.Hidden;
				attPanelRight[index].label.Text = LANG_SWEAPON_ATT[i];
				attPanelRight[index].label.TextColor = QuadColor(fontColor);
				attPanelRight[index].value.Text = tostring(self.gen_att[i]+ori_att[i]);
				attPanelRight[index].value.TextColor = QuadColor(fontColorUp);
			end

			index = index + 1;
		end
	end
	for i=index, 5 do
		attPanelRight[i].panel.Visibility = Visibility.Hidden;
	end
end

function SWeaponPanel:saveGenPro()
	local msg = {};
	msg.weapon_id = self.cur_weapon;
	Network:Send(NetworkCmdType.req_sweapon_save_pro_t, msg);
end

function SWeaponPanel:savegenpro_call_back(msg)
	self.is_genpro = false;
	btn_save.Visibility = Visibility.Hidden;
	local weapon = self.own_weapon[self.cur_weapon];
	if not weapon then
		return;
	end
	weapon.atk = self.gen_att[1];
	weapon.mgc = self.gen_att[2];
	weapon.def = self.gen_att[3];
	weapon.res = self.gen_att[4];
	weapon.hp = self.gen_att[5];
	self:showWeaponInfo();
end

function SWeaponPanel:showWarnPanel()
	warnPanel.Visibility = Visibility.Visible;
	shader2.Visibility = Visibility.Visible;

	local weapon = self.own_weapon[self.cur_weapon];
	if not weapon then
		return;
	end
	warnPanel:GetLogicChild('title').Text = LANG_SWEAPON_WARN;
	warnPanel:GetLogicChild('cur_atk').Text = tostring(weapon.atk_ori+weapon.atk);
	warnPanel:GetLogicChild('cur_mgc').Text = tostring(weapon.mgc_ori + weapon.mgc);
	warnPanel:GetLogicChild('cur_def').Text = tostring(weapon.def_ori + weapon.def);
	warnPanel:GetLogicChild('cur_res').Text = tostring(weapon.res_ori + weapon.res);
	warnPanel:GetLogicChild('cur_hp').Text = tostring(weapon.hp_ori + weapon.hp);
	warnPanel:GetLogicChild('aim_atk').Text = tostring(self.gen_att[1]);
	warnPanel:GetLogicChild('aim_mgc').Text = tostring(self.gen_att[2]);
	warnPanel:GetLogicChild('aim_def').Text = tostring(self.gen_att[3]);
	warnPanel:GetLogicChild('aim_res').Text = tostring(self.gen_att[4]);
	warnPanel:GetLogicChild('aim_hp').Text = tostring(self.gen_att[5]);
end

function SWeaponPanel:cancelWarnPanel()
	warnPanel.Visibility = Visibility.Hidden;
	shader2.Visibility = Visibility.Hidden;
	self.is_genpro = false;
	btn_save.Visibility = Visibility.Hidden;
	self:showWeaponInfo();
end

function SWeaponPanel:sureWarnPanel()
	warnPanel.Visibility = Visibility.Hidden;
	shader2.Visibility = Visibility.Hidden;
	self:saveGenPro();
end

function SWeaponPanel:showIll()
	illPanel.Visibility = Visibility.Visible;
end

function SWeaponPanel:hideIll()
	illPanel.Visibility = Visibility.Hidden;
end

