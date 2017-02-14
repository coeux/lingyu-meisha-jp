--runeComposePanel.lua
--
--=====================================================
--符文熔炼界面
--
RuneComposePanel =
{
};

--控件
local mainDesktop;
local runeComposePanel;
local bg;
local runeListPanel;
local runeInfo;
local runeCompose;
local runeLevelup;
local runeMaxLv;
local touchPanel;
local levelBar;
local levelBarPlus;
local rune_bar_cur;
local rune_bar_max;
local rune_bar_mark;
local labelCompose;
local composeImg;
local btnIllustrate;
local btnShop;
local illPanel;
local attributeChooseList;
local runeTypeRadioBtn;
local runeInfoPanel;
local shader2;

-- 变量
--local rune_list;
--local rune_num;
local main_pos;
local mat_pos;
local mat_rune_list;
local req_Num;
local can_add_mat;
local rune_type;
local cur_attribute;


-- 常量
local item_height = 65;
local height_ori = 345;
local bar_length = 204;

-- 初始化面板
function RuneComposePanel:InitPanel(desktop)
	mainDesktop = desktop;
	runeComposePanel = Panel(mainDesktop:GetLogicChild('runeComposePanel'));
	runeComposePanel:IncRefCount();
	runeComposePanel.Visibility = Visibility.Hidden;
	runeComposePanel.ZOrder = PanelZOrder.runeCompose;

	btnReturn = runeComposePanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:onClose');	
	bg = runeComposePanel:GetLogicChild('bg');

	btnIllustrate = runeComposePanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:showIllustrate');
	illPanel = runeComposePanel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	illPanel:GetLogicChild('shader'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:hideIllustrate');
	local txt = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	txt.Text = LANG_RUNE_LEVEL_ILL;

	btnShop = runeComposePanel:GetLogicChild('btnShop');
	btnShop:SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:gotoShop');

	runeListPanel = runeComposePanel:GetLogicChild('runeListPanel');
	runeTypeRadioBtn = {};
	for i=1, 3 do 
		runeTypeRadioBtn[i] = runeListPanel:GetLogicChild('type'..i);
		runeTypeRadioBtn[i].Tag = i;
		runeTypeRadioBtn[i].GroupID = RadionButtonGroup.runeComposeType;
		runeTypeRadioBtn[i]:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RuneComposePanel:ChangeType');
	end
	touchPanel = runeListPanel:GetLogicChild('runeList'):GetLogicChild('touchPanel');
	runeInfoPanel = touchPanel:GetLogicChild('runePanel');
	shader2 = runeListPanel:GetLogicChild('shader2');
	shader2.Visibility = Visibility.Hidden;
	shader2:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:showRuneAttribute');

	attributeChooseList = {};
	for i=1, 3 do 
		attributeChooseList[i] = {};
		attributeChooseList[i].showInfo = runeListPanel:GetLogicChild('attribute_'..i);
		attributeChooseList[i].showInfo:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:showRuneAttribute');
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
				runeAttributeItem.initWithInfo(i*100+id, word, 'compose');
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

	runeInfo = runeComposePanel:GetLogicChild('runeInfo');
	runeInfo:GetLogicChild('bg').Background = CreateTextureBrush('item/ball.ccz', 'item');
	levelLabel = runeInfo:GetLogicChild('level');
	levelBar = runeInfo:GetLogicChild('rune_bar');
	levelBarPlus = runeInfo:GetLogicChild('rune_bar_plus');
	rune_bar_cur = runeInfo:GetLogicChild('rune_bar_label'):GetLogicChild('cur');
	rune_bar_max = runeInfo:GetLogicChild('rune_bar_label'):GetLogicChild('max');
	rune_bar_mark = runeInfo:GetLogicChild('rune_bar_label'):GetLogicChild('mark');
	infoImg = runeInfo:GetLogicChild('runeImage');
	infoImg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:clearInfo');

	runeCompose = runeComposePanel:GetLogicChild('runeCompose');
	labelCompose = runeCompose:GetLogicChild('num');
	runeCompose:GetLogicChild('mat'):GetLogicChild('brush').Background = CreateTextureBrush('item/ball.ccz', 'item');
	composeImg = runeCompose:GetLogicChild('mat'):GetLogicChild('icon');
	runeCompose:GetLogicChild('levelup'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:composeRune');
	runeCompose.Visibility = Visibility.Hidden;

	runeLevelup = runeComposePanel:GetLogicChild('runeLevelup');
	runeLevelupMat = {};
	mat_pos = {};
	for i=1, 5 do
		runeLevelup:GetLogicChild('pos'..i):GetLogicChild('brush').Background = CreateTextureBrush('item/ball.ccz', 'item');
		runeLevelupMat[i] = runeLevelup:GetLogicChild('pos'..i):GetLogicChild('icon');
		mat_pos[i] = -1;
		runeLevelupMat[i]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneComposePanel:clearMatInfo');
		runeLevelupMat[i].Tag = i;
	end
	runeLevelup:GetLogicChild('levelup'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:addExp');
	runeLevelup:GetLogicChild('oneAdd'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:oneAdd');
	runeLevelup.Visibility = Visibility.Hidden;

	runeMaxLv = runeComposePanel:GetLogicChild('runeMaxLv');
	runeMaxLv.Visibility = Visibility.Hidden;

	runeComposePanel:GetLogicChild('btnHunt'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:EnterHunt');
	runeComposePanel:GetLogicChild('btnInlay'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneComposePanel:EnterInlay');
	--
	--rune_list = {};
	mat_rune_list = {};
	req_Num = 0;
	can_add_mat = true;
	self:clearInfo();
	rune_type = 1;
	cur_attribute = {};
	for i=1, 3 do 
		cur_attribute[i] = 0;
	end
end

function RuneComposePanel:Destroy()
	runeComposePanel = nil;
end

function RuneComposePanel:onShow()
	self:Show();
end

function RuneComposePanel:Show()
	bg.Background = CreateTextureBrush('background/wing_bg.jpg', 'background');
	runeComposePanel.Visibility = Visibility.Visible;
	rune_type = 1;
	for i=1, 3 do
		cur_attribute[i] = 1;
		attributeChooseList[i].initListInfo(rune_type);
		attributeChooseList[i].choose(1);
	end
	runeTypeRadioBtn[1].Selected = true;
	HomePanel:hideRolePanel();
	self:clearInfo();
end

function RuneComposePanel:onClose()
	HomePanel:turnPageChange();
	HomePanel:showRolePanel();
	self:Hide();
end

function RuneComposePanel:Hide()
	DestroyBrushAndImage('background/wing_bg.jpg', 'background');
	runeComposePanel.Visibility = Visibility.Hidden;
end

function RuneComposePanel:isVisible()
	return runeComposePanel.Visibility == Visibility.Visible;
end

function RuneComposePanel:EnterHunt()
	self:onClose();
	RuneHuntPanel:onShow();
end

function RuneComposePanel:EnterInlay()
	self:onClose();
	RuneInlayPanel:onShow();
end

function RuneComposePanel:ChangeType(Args)
	local args = UIControlEventArgs(Args);
	rune_type = args.m_pControl.Tag;

	for i=1, 3 do
		attributeChooseList[i].initListInfo(rune_type);
		attributeChooseList[i].choose(1);
	end
	self:refreshRuneList();
end

function RuneComposePanel:chooseAttribute(Args)
	local args = UIControlEventArgs(Args);
	local aim_a = args.m_pControl.Tag;
	local id = aim_a % 100;
	local type_ = math.floor(aim_a/100);
	attributeChooseList[type_].choose(id);
	self:refreshRuneList();
end

function RuneComposePanel:showRuneAttribute(Args)
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

function RuneComposePanel:refreshRuneList()
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
		runeInfoLabel.initWithInfo(runeItem, count, 'compose', is_stack);
	end
	local height = count * item_height;
	height = height > height_ori and height or height_ori;
	runeInfoPanel.Size = Size(380, height);
	if touchPanel.VScrollPos > height then
		touchPanel.VScrollPos = height
	end
end

function RuneComposePanel:clearInfo()
	levelLabel.Text = string.format(LANG_RUNE_LV, 0);
	levelBar.Width = 0;
	levelBarPlus.Width = 0;
	rune_bar_cur.Text = '0';
	rune_bar_cur.TextColor = QuadColor(Color.White);
	rune_bar_max.Text = '1';
	infoImg.Image = nil;
	main_pos = -1;
	for i=1, 5 do
		mat_pos[i] = -1;
	end

	runeLevelup.Visibility = Visibility.Hidden;
	runeCompose.Visibility = Visibility.Hidden;
	runeMaxLv.Visibility = Visibility.Hidden;
end

function RuneComposePanel:newRuneInfo(rune_id, check)
	if check and (not self:check_rune(rune_id)) then
		return -1;
	end
	local runeItem = Rune:GetRuneById(rune_id);
	levelLabel.Text = string.format(LANG_RUNE_LV, runeItem.lv);
	local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

	infoImg.Image = GetPicture('icon/'..runeData['icon']..'.ccz');
	main_pos = rune_id;

	local runePData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv-1));
	local runePExp = runePData and runePData['exp'] or 0;

	rune_bar_cur.Text = (runeData['exp'] == 0) and tostring(runeItem.exp) or tostring(runeItem.exp-runePExp);
	rune_bar_cur.TextColor = QuadColor(Color.White);
	rune_bar_max.Text = tostring(runeData['exp']-runePExp);
	local percent = (runeData['exp'] == 0) and 0 or (runeItem.exp-runePExp)/(runeData['exp']-runePExp);
	if percent > 1 then percent = 1; end
	levelBar.Width = math.floor(percent*bar_length);
	levelBarPlus.Width = 0;

	runeLevelup.Visibility = Visibility.Hidden;
	runeCompose.Visibility = Visibility.Hidden;
	runeMaxLv.Visibility = Visibility.Hidden;

	if Rune:checkMaxLv(runeItem) then
		self:maxLv();
		rune_bar_max.Text = tostring(0);
	elseif runeItem.exp >= runeData['exp'] then
		self:preCompose();
	else
		self:preLevelup();
	end
end

function RuneComposePanel:newMatInfo(rune_id, pos)
	if not self:check_rune(rune_id) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_6);
		return -1;
	end
	if not can_add_mat then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_1);
		return;
	end
	
	local runeItem = Rune:GetRuneById(rune_id);
	local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

	runeLevelupMat[pos].Image = GetPicture('icon/'..runeData['icon']..'.ccz');
	mat_pos[pos] = rune_id;
	
	self:genExpEffect();
end

function RuneComposePanel:genExpEffect()
	local main_rune = Rune:GetRuneById(main_pos);
	local sum_mat_exp = 0;
	for _, mat in pairs(mat_pos) do
		if mat ~= -1 then
			local mat_rune = Rune:GetRuneById(mat);
			local rune_base_exp = resTableManager:GetValue(ResTable.rune, tostring(mat_rune.resid*100+mat_rune.lv), 'base_exp');
			sum_mat_exp = sum_mat_exp + rune_base_exp + mat_rune.exp;
		end
	end
	local runePData = resTableManager:GetRowValue(ResTable.rune, tostring(main_rune.resid*100+main_rune.lv-1));
	local runePExp = runePData and runePData['exp'] or 0;
	if sum_mat_exp == 0 then
		rune_bar_cur.Text = tostring(main_rune.exp - runePExp);
		rune_bar_cur.TextColor = QuadColor(Color.White);
		levelBarPlus.Width = 0;
	else
		rune_bar_cur.Text = tostring(main_rune.exp + sum_mat_exp - runePExp);
		rune_bar_cur.TextColor = QuadColor(Color.Green);
		rune_bar_cur.TextColor = QuadColor(QualityColor[2]);

		local runeItem = Rune:GetRuneById(main_pos);
		local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

		local percent = (runeData['exp'] == 0) and 0 or (main_rune.exp + sum_mat_exp - runePExp)/(runeData['exp'] - runePExp);
		if percent >= 1 then 
			percent = 1;
			can_add_mat = false;
		else
			can_add_mat = true;
		end
		levelBarPlus.Width = math.floor(percent*bar_length);
	end
end

function RuneComposePanel:maxLv()
	runeMaxLv.Visibility = Visibility.Visible;
end

function RuneComposePanel:clearMatInfo(Args)
	local args = UIControlEventArgs(Args);
	local pos = args.m_pControl.Tag;
	runeLevelupMat[pos].Image = nil;
	runeLevelupMat[pos].Visibility = Visibility.Visible;
	mat_pos[pos] = -1;

	self:genExpEffect();
end


function RuneComposePanel:preCompose()
	runeCompose.Visibility = Visibility.Visible;

	local runeItem = Rune:GetRuneById(main_pos);
	local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

	mat_rune_list = Rune:GetSameRune(main_pos);
	local curNum = table.getn(mat_rune_list);
	req_Num = runeData['stuff'];
	composeImg.Image = GetPicture('icon/'..runeData['icon']..'.ccz');
	labelCompose.Text = curNum .. '/' .. req_Num;
end

function RuneComposePanel:preLevelup()
	runeLevelup.Visibility = Visibility.Visible;

	for i=1, 5 do
		runeLevelupMat[i].Image = nil;
		mat_pos[i] = -1;
	end
	can_add_mat = true;
end

function RuneComposePanel:addExp()
	if main_pos == -1 then
		return;
	end
	local can_levelup = false;
	local warning = false;
	local mat_list = {};
	for i=1, 5 do
		if mat_pos[i] ~= -1 then
			local runeItem = Rune:GetRuneById(mat_pos[i]);
			local quality = resTableManager:GetValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv), 'quality');
			if runeItem.lv > 1 or quality > 3 then
				warning = true;				
			end
			can_levelup = true;
			table.insert(mat_list, mat_pos[i]);
		end
	end
	if not can_levelup then
		return;
	end

	if warning then
		local okDelegate = Delegate.new(Rune, Rune.runeLevelup, main_pos, mat_list);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_RUNE_WARNING_2, okDelegate);
	else
		Rune:runeLevelup(main_pos, mat_list);
	end
end

function RuneComposePanel:oneAdd()
	-- exp require
	local main_rune = Rune:GetRuneById(main_pos);
	local mainData = resTableManager:GetRowValue(ResTable.rune, tostring(main_rune.resid*100+main_rune.lv));
	local exp_require = mainData['exp'] - main_rune.exp;
	if exp_require <= 0 then
		return;
	end

	Rune:getMatofLack(mat_pos, main_pos, exp_require);
	for pos, id in pairs (mat_pos) do
		if id ~= -1 then
			local runeItem = Rune:GetRuneById(id);
			local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

			runeLevelupMat[pos].Image = GetPicture('icon/'..runeData['icon']..'.ccz');
		end
	end
	self:genExpEffect();
end

function RuneComposePanel:levelupCallBack(msg)
	--[[
	local rune_id = msg.id;
	local runeItem = Rune:GetRuneById(rune_id);
	local runeData = resTableManager:GetRowValue(ResTable.rune, tostring(runeItem.resid*100+runeItem.lv));

	rune_bar_cur.Text = tostring(runeItem.exp);
	local percent = runeItem.exp/runeData['exp'];
	if percent > 1 then percent = 1; end
	levelBar.Width = math.floor(percent*bar_length);
	if runeItem.exp >= runeData['exp'] then
		self:preCompose();
	else
		self:preLevelup();
	end
	--]]
	self:newRuneInfo(msg.id, false);
end

function RuneComposePanel:composeRune()
	local curNum = table.getn(mat_rune_list);
	if curNum < req_Num then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_4);
	else
		table.sort(mat_rune_list, function(rune_a, rune_b)
			return rune_a.lv < rune_b.lv;
		end)
		local warning = false;
		local req_list = {};
		for i=1, req_Num do
			if mat_rune_list[i].lv > 1 then
				warning = true;
			end
			table.insert(req_list, mat_rune_list[i].id);
		end
		if warning then
			local okDelegate = Delegate.new(Rune, Rune.composeRune, main_pos, req_list);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_RUNE_WARNING_3, okDelegate);
		else
			Rune:composeRune(main_pos, req_list);
		end
	end
end

function RuneComposePanel:composeCallBack(msg)
	self:newRuneInfo(msg.id, false);
end

function RuneComposePanel:check_rune(id_)
	local can_inlay = true;
	if id_ == main_pos then
		can_inlay = false;
	end
	for i=1, 5 do
		if id_ == mat_pos[i] then
			can_inlay = false;
		end
	end
	return can_inlay;
end

--显示说明
function RuneComposePanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function RuneComposePanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end

function RuneComposePanel:gotoShop()
	ShopSetPanel:show(ShopSetType.runeShop);
--	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_8);
end

local dragDropTimer = 0;
local mouseDownPosition;
local isMouseDown;
local select_item_id;
local can_click = true;
function RuneComposePanel:mouseClick(Args)
	if not can_click then
		return;
	end
	local args = UIMouseButtonEventArgs(Args);
	local rune_id = Args.m_pControl.Tag;
	if Args.m_pControl.TagExt == 1 then
		rune_id = Rune:getSameResidRune(rune_id, main_pos, mat_pos);
	end
	if main_pos == -1 then
		self:newRuneInfo(rune_id, true);
	else
		if runeLevelup.Visibility == Visibility.Hidden then
			return;
		end
		local blank = -1;
		for i=1, 5 do
			if mat_pos[i] == -1 then
				blank = i;
				break;
			end
		end
		if blank ~= -1 then
			local can_mat, pid = Rune:CanMat(rune_id);
			if can_mat then
				self:newMatInfo(rune_id, blank);
			else
				local roleName = '';
				if pid >= 0 then
					local role = ActorManager:GetRole(pid);
					roleName = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'name');
				end
				local str = string.format(LANG_RUNE_WARNING_5, roleName);
				MessageBox:ShowDialog(MessageBoxType.Ok, str);
			end
		end
	end
end

function RuneComposePanel:mouseDown(Args)
	if dragDropTimer ~= 0 then
		return;
	end

	local args = UIMouseButtonEventArgs(Args);
	select_item_id = Args.m_pControl.Tag;
	if Args.m_pControl.TagExt == 1 then
		select_item_id = Rune:getSameResidRune(select_item_id, main_pos, mat_pos);
	end

	dragDropTimer = timerManager:CreateTimer(GlobalData.MouseMoveTime, 'RuneComposePanel:startMove', 0);

	mouseDownPosition = Vector2(mouseCursor.Translate.x, mouseCursor.Translate.y);
	isMouseDown = true;
end

function RuneComposePanel:startMove()
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

function RuneComposePanel:moveItem()
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

function RuneComposePanel:overMove()
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

	if infoImg:IsMouseOver() then
		if select_item_id then
			self:newRuneInfo(select_item_id, true);
		end
	elseif runeLevelup.Visibility == Visibility.Visible then
		for i=1, 5 do
			if runeLevelupMat[i]:IsMouseOver() then
				local can_mat, pid = Rune:CanMat(select_item_id);
				if can_mat then
					self:newMatInfo(select_item_id, blank);
				else
					local roleName = '';
					if pid >= 0 then
						local role = ActorManager:GetRole(pid);
						roleName = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'name');
					end
					local str = string.format(LANG_RUNE_WARNING_5, roleName);
					MessageBox:ShowDialog(MessageBoxType.Ok, str);
				end
				break;
			end
		end
	end
	select_item_id = nil;
end
