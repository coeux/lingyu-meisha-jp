--runeInlayPanel.lua
--
--=====================================================
--符文镶嵌界面
--
RuneInlayPanel =
	{
	};

--控件
local mainDesktop;
local runeInlayPanel;
local bg;
local runeListPanel;
local runeInlayList = {};
local btnActive;
local more_info;
local detailPanel;
local attributeList;
local btnIllustrate;
local btnShop;
local illPanel;
local touchPanel;
local runePagePanel;
local detailBtn;
local attributeChooseList;
local runeTypeRadioBtn;
local runeInfoPanel;
local shader2;

-- 变量
local cur_pid;

local rune_type;
local cur_attribute;

-- 常量
local item_height = 65;
local height_ori = 345;

-- 初始化面板
function RuneInlayPanel:InitPanel(desktop)
	mainDesktop = desktop;
	runeInlayPanel = Panel(mainDesktop:GetLogicChild('runeInlayPanel'));
	runeInlayPanel:IncRefCount();
	runeInlayPanel.Visibility = Visibility.Hidden;
	runeInlayPanel.ZOrder = PanelZOrder.runeInlay;

	btnReturn = runeInlayPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:onClose');	
	bg = runeInlayPanel:GetLogicChild('bg');

	btnIllustrate = runeInlayPanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:showIllustrate');
	illPanel = runeInlayPanel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	illPanel:GetLogicChild('shader'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:hideIllustrate');
	local txt = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	txt.Text = LANG_RUNE_INLAY_ILL;
	
	btnShop = runeInlayPanel:GetLogicChild('btnShop');
	btnShop:SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:gotoShop');

	runeListPanel = runeInlayPanel:GetLogicChild('runeListPanel');
	runeTypeRadioBtn = {};
	for i=1, 3 do 
		runeTypeRadioBtn[i] = runeListPanel:GetLogicChild('type'..i);
		runeTypeRadioBtn[i].Tag = i;
		runeTypeRadioBtn[i].GroupID = RadionButtonGroup.runeInlayType;
		runeTypeRadioBtn[i]:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RuneInlayPanel:ChangeType');
	end
	touchPanel = runeListPanel:GetLogicChild('runeList'):GetLogicChild('touchPanel');
	runeInfoPanel = touchPanel:GetLogicChild('runePanel');
	shader2 = runeListPanel:GetLogicChild('shader2');
	shader2.Visibility = Visibility.Hidden;
	shader2:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:showRuneAttribute');

	attributeChooseList = {};
	for i=1, 3 do 
		attributeChooseList[i] = {};
		attributeChooseList[i].showInfo = runeListPanel:GetLogicChild('attribute_'..i);
		attributeChooseList[i].showInfo:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:showRuneAttribute');
		attributeChooseList[i].showInfo.Tag = i;
		attributeChooseList[i].setName = function(name)
			attributeChooseList[i].showInfo:GetLogicChild('name').Text = tostring(name);
		end
		attributeChooseList[i].listWatch = runeListPanel:GetLogicChild('attribute_info_'..i);
		attributeChooseList[i].initListInfo = function(cur_type)
			attributeChooseList[i].listWatch:RemoveAllChildren();
			attributeChooseList[i].wordList = Rune:GetAttributeInfo(cur_type, i);
			local count = 0;
			for id, word in ipairs(attributeChooseList[i].wordList) do
				count = count+1;
				local runeAttributeItem = customUserControl.new(attributeChooseList[i].listWatch, 'runeAttributeTemplate');
				runeAttributeItem.initWithInfo(i*100+id, word, 'inlay');
			end
			attributeChooseList[i].listWatch.Size = Size(100, 30*count);
		end
		attributeChooseList[i].listWatch.Visibility = Visibility.Hidden;
		attributeChooseList[i].choose = function(id)
			cur_attribute[i] = id;
			attributeChooseList[i].setName(attributeChooseList[i].wordList[id]);
			attributeChooseList[i].listWatch.Visibility = Visibility.Hidden;
			shader2.Visibility = Visibility.Hidden;
		end
	end

	runeInlayList[1] = {};
	runeInlayList[2] = {};
	runeInlayList[3] = {};
	for i=1,10 do
		runeInlayList[1][i] = runeInlayPanel:GetLogicChild('runePagePanel'):GetLogicChild('rune1_'..i);
	end
	for i=1,10 do
		runeInlayList[2][i] = runeInlayPanel:GetLogicChild('runePagePanel'):GetLogicChild('rune2_'..i);
	end
	for i=1,2 do
		runeInlayList[3][i] = runeInlayPanel:GetLogicChild('runePagePanel'):GetLogicChild('rune3_'..i);
	end

	runePagePanel = runeInlayPanel:GetLogicChild('runePagePanel');

	runeInlayPanel:GetLogicChild('btnCompose'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:EnterCompose');
	runeInlayPanel:GetLogicChild('btnHunt'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:EnterHunt');

	btnActive = runeInlayPanel:GetLogicChild('runePageInfo'):GetLogicChild('active');
	btnActive:SubscribeScriptedEvent('Button::ClickEvent', 'RuneInlayPanel:active');
	more_info = runeInlayPanel:GetLogicChild('runePageInfo'):GetLogicChild('partner_icon');
	runeInlayPanel:GetLogicChild('runePageInfo'):GetLogicChild('click_label'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:more_partner');

	detailBtn = runeInlayPanel:GetLogicChild('runePageInfo'):GetLogicChild('detail');
	detailBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:showDetail');

	detailPanel = runeInlayPanel:GetLogicChild('detailPanel');
	detailPanel.Visibility = Visibility.Hidden;
	detailPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneInlayPanel:hideDetail');
	attributeList = detailPanel:GetLogicChild('info'):GetLogicChild('touch'):GetLogicChild('v_list');
	-- 
	cur_pid = 0;
	rune_type = 1;
	cur_attribute = {};
	for i=1, 3 do 
		cur_attribute[i] = 0;
	end
end

function RuneInlayPanel:Destroy()
	runeInlayPanel = nil;
end

function RuneInlayPanel:onShow()
	self:Show();
end

function RuneInlayPanel:Show()
	bg.Background = CreateTextureBrush('background/wing_bg.jpg', 'background');
	runeInlayPanel.Visibility = Visibility.Visible;
	rune_type = 1;
	for i=1, 3 do
		cur_attribute[i] = 1;
		attributeChooseList[i].initListInfo(rune_type);
		attributeChooseList[i].choose(1);
	end
	runeTypeRadioBtn[1].Selected = true;
	self:InitCurPidIcon();
	self:LoadRunePage();
	HomePanel:hideRolePanel();
end

function RuneInlayPanel:onClose()
	HomePanel:turnPageChange();
	HomePanel:showRolePanel();
	self:Hide();
end

function RuneInlayPanel:Hide()
	DestroyBrushAndImage('background/wing_bg.jpg', 'background');
	runeInlayPanel.Visibility = Visibility.Hidden;
end

function RuneInlayPanel:isVisible()
	return runeInlayPanel.Visibility == Visibility.Visible;
end

function RuneInlayPanel:EnterCompose()
	self:onClose();
	RuneComposePanel:onShow();
end

function RuneInlayPanel:EnterHunt()
	self:onClose();
	RuneHuntPanel:onShow();
end

function RuneInlayPanel:ChangeType(Args)
	local args = UIControlEventArgs(Args);
	rune_type = args.m_pControl.Tag;

	for i=1, 3 do
		attributeChooseList[i].initListInfo(rune_type);
		attributeChooseList[i].choose(1);
	end
	self:refreshRuneList();
end

function RuneInlayPanel:chooseAttribute(Args)
	local args = UIControlEventArgs(Args);
	local aim_a = args.m_pControl.Tag;
	local id = aim_a % 100;
	local type_ = math.floor(aim_a/100);
	attributeChooseList[type_].choose(id);
	self:refreshRuneList();
end

function RuneInlayPanel:showRuneAttribute(Args)
	local args = UIControlEventArgs(Args);
	local type_ = args.m_pControl.Tag;
	if attributeChooseList[type_].listWatch.Visibility == Visibility.Visible then
		attributeChooseList[type_].listWatch.Visibility = Visibility.Hidden;
		shader2.Visibility = Visibility.Hidden;
	else
		attributeChooseList[type_].listWatch.Visibility = Visibility.Visible;
		shader2.Visibility = Visibility.Visible;
		shader2.Tag = type_;
	end
end

function RuneInlayPanel:refreshRuneList()
	local runeList = Rune:GetRuneInfoByTypeAndPid(rune_type, cur_pid, cur_attribute[1], cur_attribute[2], cur_attribute[3]);
	local is_stack;
	if cur_attribute[1] == 1 then
		is_stack = false;
	elseif cur_attribute[1] == 2 then
		is_stack = true;
	else
		is_stack = false;
	end
	runeInfoPanel:RemoveAllChildren();
	local count = 0;
	for _, runeItem in pairs(runeList) do
		count = count + 1;
		local runeInfoLabel = customUserControl.new(runeInfoPanel, 'runeInfoTemplate');
		runeInfoLabel.initWithInfo(runeItem, count, 'inlay', is_stack);
	end
	local height = count * item_height;
	height = height > height_ori and height or height_ori;
	runeInfoPanel.Size = Size(380, height);
	if touchPanel.VScrollPos > height then
		touchPanel.VScrollPos = height
	end
end

function RuneInlayPanel:LoadRunePage()
	for k, v in pairs(runeInlayList) do
		for k1, v1 in pairs(v) do
			v1:RemoveAllChildren();
		end
	end
	local runePageInfo = Rune:GetRunePageInfoByPid(cur_pid);
	if not runePageInfo or (not runePageInfo[0]) then
		--
		btnActive.Visibility = Visibility.Visible;
		detailBtn.Visibility = Visibility.Hidden;
		for i=1, 22 do
			local type_ = math.floor((i-1)/10) + 1;
			local pos = i - (type_-1)*10;
			local slotItem = customUserControl.new(runeInlayList[type_][pos], 'runeInlayTemplate');
			slotItem.initWithInfo(-1, i, 'lock');
		end
	else
		btnActive.Visibility = Visibility.Hidden;
		detailBtn.Visibility = Visibility.Visible;
		for _, slot in pairs(runePageInfo) do
			local type_ = math.floor((slot.slot-1)/10) + 1;
			local pos = slot.slot - (type_-1)*10;
			if slot.slot ~= 0 then
			local slotItem = customUserControl.new(runeInlayList[type_][pos], 'runeInlayTemplate');
			local lv_req = resTableManager:GetValue(ResTable.rune_unlock, tostring(type_*100+pos), 'lv');
			local lv_cur = ActorManager:GetRole(cur_pid).lvl.level;
			if lv_cur > lv_req-1 then
				slotItem.initWithInfo(slot.id, slot.slot, 'slot');
			elseif lv_cur == lv_req-1 then
				slotItem.initWithInfo(slot.id, slot.slot, 'lv_lmt', lv_req);
			else
				slotItem.initWithInfo(slot.id, slot.slot, 'lock');
			end
		end
		end
	end
end

function RuneInlayPanel:InitCurPidIcon()
	local partner_icon = customUserControl.new(more_info, 'cardHeadTemplate');
	partner_icon.initWithPid(cur_pid, 100);
	--partner_icon.setTip(ActorManager:GetRole(cur_pid));
	partner_icon.clickEvent('RuneInlayPanel:more_partner', cur_pid, cur_pid);
end

function RuneInlayPanel:showDetail()
	self:refreshDetail();
	detailPanel.Visibility = Visibility.Visible;
end

function RuneInlayPanel:hideDetail()
	detailPanel.Visibility = Visibility.Hidden;
end

function RuneInlayPanel:refreshDetail()
	attributeList:RemoveAllChildren();
--	local type_list = Rune:GetAllType();
	for type_=1, 5 do
		local value = Rune:GetPidAttribute(cur_pid, type_);
		if value > 0 then
			local a_label = customUserControl.new(attributeList, 'runeAttributeInfoTemplate');
			a_label.initWithInfo(type_, value);
		end
	end
	for type_=100, 104 do
		local value = Rune:GetPidAttribute(cur_pid, type_);
		if value > 0 then
			local a_label = customUserControl.new(attributeList, 'runeAttributeInfoTemplate');
			a_label.initWithInfo(type_, value);
		end
	end
	for type_=200, 204 do
		local value = Rune:GetPidAttribute(cur_pid, type_);
		if value > 0 then
			local a_label = customUserControl.new(attributeList, 'runeAttributeInfoTemplate');
			a_label.initWithInfo(type_, value);
		end
	end
end

function RuneInlayPanel:selectNewPartner(pid)
	if cur_pid == pid then
		return;
	end
	cur_pid = pid;
	self:refreshRuneList();
	self:InitCurPidIcon();
	self:LoadRunePage();
end

function RuneInlayPanel:more_partner()
	local default = 0;
	HomeAllRolePanel:onShow(default,'runeInlay');
end

function RuneInlayPanel:active()
	local okDelegate = Delegate.new(Rune, Rune.active, cur_pid);
	local money = resTableManager:GetValue(ResTable.config, tostring(42), 'value');
	money = money or 0;
	local words = string.format(LANG_RUNE_IL_3, money);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, words, okDelegate);
end

function RuneInlayPanel:activeCallBack(pid)
	if cur_pid == pid then
		self:LoadRunePage();
	end
end

local can_click = true;
function RuneInlayPanel:clickRune(Args)
	if not can_click then
		return;
	end
	local args = UIControlEventArgs(Args);
	local rune_id = args.m_pControl.Tag;
	local runeItem = Rune:GetRuneById(rune_id);
	local pos = Rune:GetBlankPos(cur_pid, runeItem);
	if pos == -1 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_7);
		return;
	elseif pos == -2 then
		return;
	end

	Rune:AddRuneToPage(rune_id, cur_pid, pos);
end

function RuneInlayPanel:clickPageRune(Args)
	local args = UIControlEventArgs(Args);
	local pos = args.m_pControl.Tag;
	Rune:RemoveRuneFromPage(cur_pid, pos);
end

function RuneInlayPanel:runeInlayCallBack(msg)
	-- page
	if cur_pid == msg.pid then
		local type_ = math.floor((msg.pos-1)/10)+1;
		local pos_ = (msg.pos-1)%10+1;
		runeInlayList[type_][pos_]:RemoveAllChildren();
		local slotItem = customUserControl.new(runeInlayList[type_][pos_], 'runeInlayTemplate');
		slotItem.initWithInfo(msg.id, msg.pos, 'slot');
	end

	-- rune info
	self:refreshRuneList();
end

function RuneInlayPanel:runeUnlayCallBack(msg)
	-- page
	if cur_rune_page == msg.page then
		local type_ = math.floor((msg.pos-1)/10)+1;
		local pos_ = (msg.pos-1)%10+1;
		runeInlayList[type_][pos_]:RemoveAllChildren();
		local slotItem = customUserControl.new(runeInlayList[type_][pos_], 'runeInlayTemplate');
		slotItem.initWithInfo(-1, msg.pos, 'slot');
	end

	-- rune info
	self:refreshRuneList();
end

--显示说明
function RuneInlayPanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function RuneInlayPanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end

function RuneInlayPanel:gotoShop()
	ShopSetPanel:show(ShopSetType.runeShop);
--	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_8);
end

local dragDropTimer = 0;
local mouseDownPosition;
local isMouseDown;
local select_item_id;
function RuneInlayPanel:mouseDown(Args)
	if dragDropTimer ~= 0 then
		return;
	end

	local args = UIMouseButtonEventArgs(Args);
	select_item_id = Args.m_pControl.Tag;

	dragDropTimer = timerManager:CreateTimer(GlobalData.MouseMoveTime, 'RuneInlayPanel:startMove', 0);

	mouseDownPosition = Vector2(mouseCursor.Translate.x, mouseCursor.Translate.y);
	isMouseDown = true;
end

function RuneInlayPanel:startMove()
	timerManager:DestroyTimer(dragDropTimer);
	dragDropTimer = 0;

	local img = ArmatureUI( uiSystem:CreateControl('ImageElement') );
	mouseCursor:AddChild(img);
	mouseCursor.Size = img.Size;
	img.Horizontal = ControlLayout.H_CENTER;
	img.Vertical = ControlLayout.V_CENTER;
	local runeItem = Rune:GetRuneById(select_item_id);
	local icon_path = resTableManager:GetValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv), 'icon');
	img.Image = GetPicture('icon/'..icon_path..'.ccz')
	mouseCursor.Visible = true;
	touchPanel.CanVScroll = false;

	can_click = false;
end

function RuneInlayPanel:moveItem()
	local absX = 0;
	local absY = 0;
	if isMouseDown then
		absX = Math.Abs(mouseCursor.Translate.x - mouseDownPosition.x);
		absY = Math.Abs(mouseCursor.Translate.y - mouseDownPosition.y);
	end

	if (dragDropTimer ~= 0) then
		if isMouseDown and ((absX <= GlobalData.MouseMoveDistance) and (absY <= GlobalData.MouseMoveDistance)) then
			return ;
		else
			timerManager:DestroyTimer(dragDropTimer);
			dragDropTimer = 0;
		end	
	end
end

function RuneInlayPanel:overMove()
	if dragDropTimer ~= 0 then
		timerManager:DestroyTimer(dragDropTimer);
		dragDropTimer = 0;
	end	
	isMouseDown = false;
	can_click = true;

	mouseCursor:RemoveAllChildren();
	mouseCursor.Image = nil;
	mouseCursor.Visible = false;
	touchPanel.CanVScroll = true;

	local lx = runePagePanel:GetAbsTranslate().x;
	local rx = runePagePanel:GetAbsTranslate().x + runePagePanel.RenderSize.Width;
	local ty = runePagePanel:GetAbsTranslate().y;
	local by = runePagePanel:GetAbsTranslate().y + runePagePanel.RenderSize.Height;

	local isMouseOver = false;
	if mouseCursor.Translate.x > lx and mouseCursor.Translate.x < rx and mouseCursor.Translate.y > ty and mouseCursor.Translate.y < by then
		isMouseOver = true;
	end

	if isMouseOver then
		local runeItem = Rune:GetRuneById(select_item_id);
		local pos = Rune:GetBlankPos(cur_pid, runeItem);
		if pos == -1 then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_7);
			return;
		elseif pos == -2 then
			return;
		end

		Rune:AddRuneToPage(select_item_id, cur_pid, pos);
	end
	select_item_id = nil;
end

