--wingPanel.lua
--========================================================================
--翅膀界面

WingPanel =
	{
		wingItemResid = 24001;
		enterType = 0;
	};

--控件
local mainDesktop;
local wingPanel;
local bg;
local role;
local newRole;
local qualityPanel;
local quality_img;
local quality_word;
local level_img;
local level_word;
local listPanel;
local listWingItems;
local listWings;
local pro;
local proPanel;
local btnReturn;
local btnIllustrate;
local composePanel;
local btnCompose;
local token;
local progress;
local wingName;
local highLvLabel;
local tokenItem;
local bottomBru;
local labelcur;
local labelneed;
local illPanel;
local decomposePanel;
local shader;
local matItemDecompose;
local panel_no_wing;

--变量
local equipWing;			--当前装备的翅膀
local selectWing;			--当前选中的翅膀
local curMaterialNum;
local needMaterialNum;
--常量
local max_wid = 10000;
local matId = 24001; 

--初始化面板
function WingPanel:InitPanel(desktop)
	--变量初始化
	equipWing = nil;
	selectWing = nil;
	curMaterialNum = 0;
	needMaterialNum = 0;
	self.enterType = 0;
	--控件初始化
	mainDesktop = desktop;
	wingPanel = Panel(desktop:GetLogicChild('WingPanel'));
	wingPanel.ZOrder = PanelZOrder.wing;
	wingPanel.Visibility = Visibility.Hidden;
	wingPanel:IncRefCount();
	
	bg = wingPanel:GetLogicChild('bg');
	--适配
	wingPanel:GetLogicChild('rolePanel').Horizontal = ControlLayout.H_CENTER;
	wingPanel:GetLogicChild('rolePanel').Margin = Rect(160,110,0,0);
	wingPanel:GetLogicChild('qualityPanel').Horizontal = ControlLayout.H_RIGHT;
	wingPanel:GetLogicChild('qualityPanel').Margin = Rect(0,100,math.floor((desktop.Size.Width/2-360+19)/2-50+360),0);

	local width = mainDesktop.Size.Width - 440;
	wingPanel:GetLogicChild('listPanel').Size = Size(width, 110);
	local innerWidth = width - 30;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing').Size = Size(innerWidth, 90);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('scrollPanel').Size = Size(innerWidth, 90);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').TransformPoint = Vector2(0, 0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Scale = Vector2(0.68, 0.68);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Horizontal = ControlLayout.H_CENTER;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Margin = Rect(-50,15,0,0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Visibility = Visibility.Hidden;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Size = Size(132,48);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Horizontal = ControlLayout.H_CENTER;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Margin = Rect(0,0,0,0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('buyWing').Visibility = Visibility.Hidden;
	--角色
	role = wingPanel:GetLogicChild('rolePanel'):GetLogicChild('roleArm');
	wingName = wingPanel:GetLogicChild('rolePanel'):GetLogicChild('wingName');
	bottomBru = wingPanel:GetLogicChild('rolePanel'):GetLogicChild('bottombru');
	--翅膀品质和阶数
	qualityPanel = wingPanel:GetLogicChild('qualityPanel');
	quality_img = qualityPanel:GetLogicChild('quality_img');
	quality_word = quality_img:GetLogicChild('quality_word');
	level_img = qualityPanel:GetLogicChild('levelPanel'):GetLogicChild('level_img');
	level_word = qualityPanel:GetLogicChild('levelPanel'):GetLogicChild('level_word');
	--翅膀列表
	listWingItems = {};
	listPanel = wingPanel:GetLogicChild('listPanel'):GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	panel_no_wing = wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing');
	panel_no_wing:GetLogicChild('label').Text = LANG_Wing_2;
	panel_no_wing:GetLogicChild('btn'):SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:gotoShop');
	--翅膀属性
	proPanel = wingPanel:GetLogicChild('proPanel');
	pro = {};
	pro.setPro = function(atk, mgc, def, res, hp)
		proPanel:GetLogicChild('atk').Text = tostring(atk);
		proPanel:GetLogicChild('mgc').Text = tostring(mgc);
		proPanel:GetLogicChild('def').Text = tostring(def);
		proPanel:GetLogicChild('res').Text = tostring(res);
		proPanel:GetLogicChild('hp').Text = tostring(hp);
	end
	composePanel = wingPanel:GetLogicChild('composePanel');
	btnCompose = composePanel:GetLogicChild('btnCompose');
	btnCompose:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:onCompose');
	token = composePanel:GetLogicChild('token');
	tokenItem = customUserControl.new(token, 'itemTemplate');
	progress = composePanel:GetLogicChild('progress');
	highLvLabel = composePanel:GetLogicChild('highLv');
	labelcur = composePanel:GetLogicChild('cur');
	labelneed = composePanel:GetLogicChild('need');
	composePanel.ZOrder = 0;
	--分解弹框
	decomposePanel = wingPanel:GetLogicChild('decomposePanel');
	decomposePanel.Visibility = Visibility.Hidden;
	matItemDecompose = customUserControl.new(decomposePanel:GetLogicChild('mat'), 'itemTemplate');
	shader = wingPanel:GetLogicChild('shader');
	shader.Visibility = Visibility.Hidden;
	decomposePanel:GetLogicChild('btnSure'):SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:sureForDecompose');
	decomposePanel:GetLogicChild('btnCancel'):SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:cancelDecompose');

	--功能控件
	btnDecompos = wingPanel:GetLogicChild('btnDecompos');
	btnDecompos:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:onDecompos');
	btnEquip = wingPanel:GetLogicChild('btnEquip');
	btnEquip:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:onEquip');
	btnDebus = wingPanel:GetLogicChild('btnDebus');
	btnDebus:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:onDebus');
	
	btnReturn = wingPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:onClose');
	btnIllustrate = wingPanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'WingPanel:showIllustrate');

	illPanel = wingPanel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	local txt = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	local shader = illPanel:GetLogicChild('shader');
	shader:SubscribeScriptedEvent('UIControl::MouseClickEvent',	'WingPanel:hideIllustrate');
	txt.Text = LANG_Wing_1;
end

--显示
function WingPanel:onShow(enterType)
	if enterType then
		self.enterType = enterType;
	end
	HomePanel:destroyRoleSound()
	self:refreshWing();
	self:refreshRole();
	self:refreshWingQuality();
	self:refreshWingPro();
	self:refreshMaterial();
	self:refreshBtns();
	self:Show();
end

--销毁
function WingPanel:Destroy()
	wingPanel:IncRefCount();
	wingPanel = nil;
end

--返回
function WingPanel:onClose()
	self:Hide();
	if self.enterType ~= WingPanelEnterType.openServerWingSelect then
		HomePanel:turnPageChange();
		HomePanel:showRolePanel();
	end
	self.enterType = WingPanelEnterType.normal;
end

--显示说明
function WingPanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function WingPanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end

--显示分解弹出框
function WingPanel:showDecompose()
	shader.Visibility = Visibility.Visible;
	decomposePanel.Visibility = Visibility.Visible;
	local str = resTableManager:GetValue(ResTable.item, tostring(24001), 'name');
	decomposePanel:GetLogicChild('name').Text = str;
	local numDecompose = resTableManager:GetValue(ResTable.wing, tostring(selectWing.resid), 'split');
	matItemDecompose.initWithInfo(matId, numDecompose, 100, true);
end

--隐藏分解弹出框
function WingPanel:hideDecompose()
	shader.Visibility = Visibility.Hidden;
	decomposePanel.Visibility = Visibility.Hidden;
end

--确认分解
function WingPanel:sureForDecompose()
	local msg = {};
	msg.wid = selectWing.wid;
	msg.flag = WingCompose.split;
	Network:Send(NetworkCmdType.req_compose_wing, msg);
	self:hideDecompose();
end

--取消分解
function WingPanel:cancelDecompose()
	self:hideDecompose();
end

--根据当前翅膀情况来刷新人物形象
function WingPanel:refreshRole()
	role.Visibility = Visibility.Visible;
	role:Destroy();
	role:LoadArmature(ActorManager.user_data.role.actorForm);
	role:SetAnimation(AnimationType.fly_idle);
	if selectWing then
		wingName.Text = tostring(resTableManager:GetValue(ResTable.wing, tostring(selectWing.resid), 'name'));
	else
		wingName.Text = "";
	end
	if selectWing ~= nil then
		AddWingsToUIActor(role, selectWing.resid);
	end	
end

--刷新当前持有的翅膀
function WingPanel:refreshWing()
	local sort_list = {};
	listWings = {};
	local minWid = max_wid;
	if ActorManager.user_data.role.wings and ActorManager.user_data.role.wings[1] then
		equipWing = ActorManager.user_data.role.wings[1];
		listWings[equipWing.wid] = equipWing;
		table.insert(sort_list,{wid = equipWing.wid});
		if equipWing.wid < minWid then
			minWid = equipWing.wid;
		end
	end
	if Package.wingList ~= {} then
		for _, wing in pairs(Package.wingList) do
			listWings[wing.wid] = wing;
			table.insert(sort_list,{wid = wing.wid});
			if wing.wid < minWid then
				minWid = wing.wid;
			end
		end
	end

	listPanel:RemoveAllChildren();
	listWingItems = {};
	if minWid == max_wid then
		panel_no_wing.Visibility = Visibility.Visible;
		return;
	else
		panel_no_wing.Visibility = Visibility.Hidden;
	end

	table.sort(sort_list, function(a,b)
		return listWings[a.wid].resid > listWings[b.wid].resid;
	end)
	if (selectWing == nil and minWid ~= max_wid) then
		if equipWing then
			selectWing = equipWing;
		else
			selectWing = listWings[sort_list[1].wid];
		end
	end
	local selectid = selectWing.wid;
	local equipid = equipWing and equipWing.wid or -1;
	for _, wingid in pairs(sort_list) do
		local wing = listWings[wingid.wid];
		local wingItem = customUserControl.new(listPanel, 'wingTemplate');
		listWingItems[wing.wid] = wingItem;
		wingItem.initWithWing(wing);
		wingItem.beSelected(wing.wid == selectid);
		wingItem.equip(wing.wid == equipid);
	end
end

--刷新当前翅膀的品质和阶数
function WingPanel:refreshWingQuality()
	if not selectWing then
		qualityPanel.Visibility = Visibility.Hidden;
		return;
	else
		qualityPanel.Visibility = Visibility.Visible;
	end
	local info = selectWing.resid % 100;
	local level = math.floor(info/10)+1;
	local quality = info % 10;
	quality_img.Image = GetPicture('wing/quality_' .. quality .. '.ccz');
	quality_word.Image = GetPicture('wing/word_' .. quality .. '.ccz');
	level_img.Image = GetPicture('wing/level_' .. level .. '.ccz');
	level_word.Text = tostring(level);
end

--刷新当前翅膀的数值
function WingPanel:refreshWingPro()
	if not selectWing then
		pro.setPro(0, 0, 0, 0, 0);
		return;
	else
		proPanel.Visibility = Visibility.Visible;
	end
	pro.setPro(selectWing.atk, selectWing.mgc, selectWing.def, selectWing.res, selectWing.hp);
end

--刷新当前翅膀的合成材料
function WingPanel:refreshMaterial()
	--[[ 第一版时的代码
	if not selectWing then
		composePanel.Visibility = Visibility.Hidden;
		return;
	else
		composePanel.Visibility = Visibility.Visible;
	end
	local wingData = resTableManager:GetRowValue(ResTable.wing_compose, tostring(selectWing.resid))
	local matResid = wingData['stuff_1'];
	local matRNum = wingData['stuff_1_num'];
	local composeWing = wingData['former_equip'];
	if composeWing == 0 then
		token.Visibility = Visibility.Hidden;
		progress.Visibility = Visibility.Hidden;
		highLvLabel.Visibility = Visibility.Visible;
		btnCompose.Visibility = Visibility.Hidden;
	else
		token.Visibility = Visibility.Visible;
		progress.Visibility = Visibility.Visible;
		highLvLabel.Visibility = Visibility.Hidden;
		btnCompose.Visibility = Visibility.Visible;

		tokenItem.initWithInfo(matResid, -1, 70, true);
		local matItem = Package:GetMaterial( matResid );
		local matNum = matItem and matItem.num or 0;
		progress.CurValue = matNum;
		progress.MaxValue = matRNum;
		btnCompose.Enable = (matNum >= matRNum);
	end
	--]]
	local matResid = self.wingItemResid;
	local matItem = Package:GetMaterial( matResid );
	local matNum = matItem and matItem.num or 0;
	labelcur.Text = tostring(matNum);
	curMaterialNum = matNum;
	tokenItem.initWithInfo(matResid, -1, 70, false);
	tokenItem.addExtraClickEvent(matResid, 'WingPanel:onMaterialClick');
	local matRNum;
	if selectWing then
		local wingData = resTableManager:GetRowValue(ResTable.wing_compose, tostring(selectWing.resid))
		matRNum = wingData['stuff_1_num'];
		local composeWing = wingData['former_equip'];
		if composeWing == 0 then
			highLvLabel.Visibility = Visibility.Visible;
			btnCompose.Visibility = Visibility.Hidden;
			matRNum = 0;
		else
			highLvLabel.Visibility = Visibility.Hidden;
			btnCompose.Visibility = Visibility.Visible;
			btnCompose.Enable = (matNum >= matRNum);
		end
	else
		matRNum = 0;
		highLvLabel.Visibility = Visibility.Hidden;
		btnCompose.Visibility = Visibility.Visible;
		btnCompose.Enable = false;
	end	
	
	labelneed.Text = tostring(matRNum);
	needMaterialNum = matRNum;
	local showNum
	if matNum >= matRNum then
		showNum = matRNum;
		labelcur.TextColor = QuadColor(Color.Green);
	else
		showNum = matNum;
		labelcur.TextColor = QuadColor(Color.Red);
	end
	local showNum = (matNum > matRNum) and matRNum or matNum;
	progress.MaxValue = 99999;
	progress.CurValue = showNum;
	progress.MaxValue = matRNum;
end
function WingPanel:onMaterialClick(Args)
	local args = UIControlEventArgs(Args);
	
	if args.m_pControl.Tag == 0 then
		return;
	end
	local item = {};
	item.resid = args.m_pControl.Tag;
	local itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	local height = 100
	local wight = mainDesktop.Size.Width/2
	TooltipPanel:setNeedAndHaveNum( needMaterialNum,curMaterialNum);
	TooltipPanel:ShowItem(wingPanel, item, TipMaterialShowButton.Obtain,Rect(wight,height,0,0));
end
function WingPanel:refreshBtns()
	btnEquip.Enable = true;
	btnDebus.Enable = true;
	btnDecompos.Enable = true;
	if selectWing then
		if equipWing and equipWing.wid == selectWing.wid then
			btnDebus.Visibility = Visibility.Visible;
			btnEquip.Visibility = Visibility.Hidden;
		else
			btnDebus.Visibility = Visibility.Hidden;
			btnEquip.Visibility = Visibility.Visible;
		end
	else
		btnDebus.Visibility = Visibility.Hidden;
		btnEquip.Visibility = Visibility.Visible;
		btnDecompos.Enable = false;
		btnEquip.Enable = false;
	end
end
--选中列表中的某一个翅膀
function WingPanel:onSelectWing(Args)
	local args = UIControlEventArgs(Args);
	local aimWid = args.m_pControl.Tag;
	if aimWid == selectWing.wid then
		return;
	end
	for wid, wing in pairs(listWingItems) do
		wing.beSelected(wid == aimWid);
	end
	selectWing = listWings[aimWid];
	self:refreshWingPro();
	self:refreshMaterial();
	self:refreshRole();
	self:refreshWingQuality();
	self:refreshBtns();
end

--装备翅膀
function WingPanel:onEquip()
	if not selectWing then
		return;
	end
	local aimWid = selectWing.wid;
	local msg = {};
	msg.wid = selectWing.wid;
	msg.resid = selectWing.resid;
	msg.flag = WingWear.on;
	Network:Send(NetworkCmdType.req_wear_wing, msg);
end

--卸下翅膀
function WingPanel:onDebus()
	if not equipWing then
		return;
	end
	local aimWid = equipWing.wid;
	local msg = {};
	msg.wid = equipWing.wid;
	msg.resid = equipWing.resid;
	msg.flag = WingWear.off;
	Network:Send(NetworkCmdType.req_wear_wing, msg);
end

--合成翅膀
function WingPanel:onCompose()
	if not selectWing then
		return;
	end
	local msg = {};
	msg.wid = selectWing.wid;
	msg.flag = WingCompose.compose;
	Network:Send(NetworkCmdType.req_compose_wing, msg);
end

--分解翅膀
function WingPanel:onDecompos()
	if not selectWing then
		return;
	end
	self:showDecompose();
end

--========================================================================
function WingPanel:Show()
	bg.Background = CreateTextureBrush('background/wing_bg.jpg', 'background')
	bottomBru.Background = CreateTextureBrush('wing/bottom_bru.ccz', 'wing');
	wingPanel.Visibility = Visibility.Visible;
end

function WingPanel:Hide()
	DestroyBrushAndImage('background/wing_bg.jpg', 'background');
	DestroyBrushAndImage('wing/bottom_bru.ccz', 'wing');
	wingPanel.Visibility = Visibility.Hidden;
end

function WingPanel:equipCallback(msg)
	if msg.flag == WingWear.off then
		local aimWid = msg.wid;
		for wid, wing in pairs(listWingItems) do
			wing.equip(false);
		end
		ActorManager.user_data.role.wings = {};
		equipWing = nil;
		ActorManager.hero:DettachWing();
		--调整vip特殊效果高度
		ActorManager.hero:UpdateVipHeight(VipAvatarHeight.normal)
	elseif msg.flag == WingWear.on then
		local aimWid = msg.wid;
		for wid, wing in pairs(listWingItems) do
			wing.equip(wid == aimWid);
		end
		equipWing = listWings[aimWid];
		ActorManager.user_data.role.wings = {};
		ActorManager.user_data.role.wings[1] = equipWing;
		ActorManager.hero:AttachWing(msg.resid);
		--调整vip特殊效果高度
		ActorManager.hero:UpdateVipHeight(VipAvatarHeight.wing)
	end
	self:refreshRole();
	self:refreshBtns();
	self:refreshWingQuality();
	ActorManager.hero:RetachPet();
end

function WingPanel:composeCallback(msg)
	selectWing.resid = msg.resid;
	selectWing.atk = msg.atk;
	selectWing.mgc = msg.mgc;
	selectWing.def = msg.def;
	selectWing.res = msg.res;
	selectWing.hp = msg.hp;
	if selectWing and msg.wid == selectWing.wid then
		self:refreshRole();
		self:refreshWingQuality();
	end
	if selectWing and equipWing and selectWing.wid == equipWing.wid then
		ActorManager.hero:AttachWing(msg.resid);
	end
	self:refreshWing();
	self:refreshWingPro();
	self:refreshMaterial();
	ActorManager.hero:RetachPet();
end

function WingPanel:decomposCallback(msg)
	if equipWing and msg.wid == equipWing.wid then
		ActorManager.hero:DettachWing();
		--调整vip特殊效果高度
		ActorManager.hero:UpdateVipHeight(VipAvatarHeight.normal)
		ActorManager.user_data.role.wings = {};
		equipWing = nil;
	end
	selectWing = nil;
	self:refreshWing();
	self:refreshRole();
	self:refreshWingQuality();
	self:refreshWingPro();
	self:refreshMaterial();
	self:refreshBtns();
	ActorManager.hero:RetachPet();
end

function WingPanel:gotoShop()
	self:onClose();
	HomePanel:onLeaveHomePanel();
	PropertyBonusesPanel:onClose();
	-- ShopPanel:OpenShop();
	ShopSetPanel:show(ShopSetType.gameShop)
end
function WingPanel:leaveWingPanel()
	TooltipPanel:materialPanelClose()
	WingPanel:onClose();
	HomePanel:onLeaveHomePanel();
end

function WingPanel:isVisible()
	return wingPanel.Visibility == Visibility.Visible;
end