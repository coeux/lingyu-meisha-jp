--petPanel.lua
--========================================================================
--宠物界面

PetPanel =
	{
	};

--控件
local mainDesktop;
local petPanel;
local bg;

local pet;
local petName;
local bottomBru;
local qualityPanel;
local level_img;
local bg_img;
local proPanel;
local pro;
local previewPanel;
local petPreview;
local petPreviewBru;
local petPreviewBg;
local proPreviewPanel;
local proPreview;
local petArmPanel;
local bottomPanel;
local bottomMidPanel;

--变量
local materialItem;
local pet_data = {};
--常量
local max_pet_level;

--初始化面板
function PetPanel:InitPanel(desktop)
	--变量初始化
	--控件初始化
	mainDesktop = desktop;
	petPanel = Panel(desktop:GetLogicChild('PetPanel'));
	petPanel.ZOrder = PanelZOrder.pet;
	petPanel.Visibility = Visibility.Hidden;
	petPanel:IncRefCount();
	
	bg = petPanel:GetLogicChild('bg');

	--宠物形象
	petArmPanel = petPanel:GetLogicChild('petPanel');
	pet = petPanel:GetLogicChild('petPanel'):GetLogicChild('petArm');
	pet.ZOrder = 50;
	petName = petPanel:GetLogicChild('petPanel'):GetLogicChild('petName');
	bottomBru = petPanel:GetLogicChild('petPanel'):GetLogicChild('bottombru');

	--宠物品质和阶数
	qualityPanel = petPanel:GetLogicChild('qualityPanel');
	level_img = qualityPanel:GetLogicChild('levelPanel'):GetLogicChild('level_img');
	bg_img = qualityPanel:GetLogicChild('levelPanel'):GetLogicChild('bg_img');

	--宠物属性
	proPanel = petPanel:GetLogicChild('proPanel'):GetLogicChild('proPanel');
	pro = {};
	pro.setPro = function(atk, mgc, def, res, hp)
		proPanel:GetLogicChild('atk').Text = tostring(atk);
		proPanel:GetLogicChild('mgc').Text = tostring(mgc);
		proPanel:GetLogicChild('def').Text = tostring(def);
		proPanel:GetLogicChild('res').Text = tostring(res);
		proPanel:GetLogicChild('hp').Text = tostring(hp);
		proPanel:GetLogicChild('fp').Text = tostring(math.floor(atk * 1.1 + mgc * 1 + def * 1.2 + res * 1 + hp * 0.3));
	end

	--宠物下一级 预览
	previewPanel = petPanel:GetLogicChild('previewPanel');
	previewPanel.Visibility = Visibility.Hidden;
	petPreview = previewPanel:GetLogicChild('petPanel'):GetLogicChild('petArm');
	petPreviewBru = previewPanel:GetLogicChild('petPanel'):GetLogicChild('bottombru');
	petPreviewBg = previewPanel:GetLogicChild('petPanel'):GetLogicChild('pet_bg');

	--宠物下一级属性预览
	proPreviewPanel = previewPanel:GetLogicChild('proPanel'):GetLogicChild('proPanel');
	proPreview = {};
	proPreview.setPro = function(atk,mgc,def,res,hp)
		proPreviewPanel:GetLogicChild('atk').Text = tostring(atk);
		proPreviewPanel:GetLogicChild('mgc').Text = tostring(mgc);
		proPreviewPanel:GetLogicChild('def').Text = tostring(def);
		proPreviewPanel:GetLogicChild('res').Text = tostring(res);
		proPreviewPanel:GetLogicChild('hp').Text = tostring(hp);
	end

	--功能控件
	btnNextPreview = petPanel:GetLogicChild('btnNextPreview');
	btnNextPreview:SubscribeScriptedEvent('Button::ClickEvent', 'PetPanel:showPreview');
	bottomPanel = petPanel:GetLogicChild('bottomPanel');
	bottomMidPanel = bottomPanel:GetLogicChild('midPanel');
	btnCompose = bottomMidPanel:GetLogicChild('btnCompose');
	btnCompose:SubscribeScriptedEvent('Button::ClickEvent', 'PetPanel:onCompose');
	btnAdd = bottomMidPanel:GetLogicChild('addbutton');
	btnAdd:SubscribeScriptedEvent('Button::ClickEvent', 'PetPanel:gotoShop');

	btnReturn = petPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'PetPanel:onClose');
	btnIllustrate = petPanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'PetPanel:showIllustrate');

	illPanel = petPanel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	illPanel:GetLogicChild('shader'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PetPanel:hideIllustrate');
	local txt = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	txt.Text = LANG_PET_1;

	shader = petPanel:GetLogicChild('shader');
	shader:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PetPanel:hidePreview');
	shader.Visibility = Visibility.Hidden;

	--材料相关内容
	materialItem = customUserControl.new(bottomMidPanel:GetLogicChild('item'), 'itemTemplate');
	materialNumLabel = bottomMidPanel:GetLogicChild('itemNum');

	--适配
	local width = mainDesktop.Size.Width;

	petArmPanel.Horizontal = ControlLayout.H_CENTER;
	petArmPanel.Margin = Rect(160,110,0,0);

	qualityPanel.Horizontal = ControlLayout.H_RIGHT;
	qualityPanel.Margin = Rect(0,100,math.floor((width/2-360+19)/2-50+360),0);

	bottomPanel.Size = Size(width-400, 100);
	bottomMidPanel.Horizontal = ControlLayout.H_CENTER;

	--[[
	local width = mainDesktop.Size.Width - 440;
	wingPanel:GetLogicChild('listPanel').Size = Size(width, 110);
	local innerWidth = width - 30;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing').Size = Size(innerWidth, 90);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('scrollPanel').Size = Size(innerWidth, 90);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').TransformPoint = Vector2(0, 0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Scale = Vector2(0.68, 0.68);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Horizontal = ControlLayout.H_CENTER;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('label').Margin = Rect(-50,15,0,0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Size = Size(132,48);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Horizontal = ControlLayout.H_CENTER;
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('panel_no_wing'):GetLogicChild('btn').Margin = Rect(0,-15,0,0);
	wingPanel:GetLogicChild('listPanel'):GetLogicChild('buyWing').Visibility = Visibility.Hidden;
	--]]
end

--显示
function PetPanel:onShow()
	if not PetModule.have_pet then
		return;
	end
	if ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	end
	HomePanel:destroyRoleSound()
	self:refreshPetData();
	self:refreshPet();
	self:refreshPetQuality();
	self:refreshPetPro();
	self:refreshMaterial();
	self:refreshBtns();
	self:Show();
end

--销毁
function PetPanel:Destroy()
	petPanel:IncRefCount();
	petPanel = nil;
end

--返回
function PetPanel:onClose()
	self:Hide();
	HomePanel:turnPageChange();
	HomePanel:showRolePanel();
end

--显示说明
function PetPanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function PetPanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end

function PetPanel:refreshPetData()
	pet_data = resTableManager:GetRowValue(ResTable.pet, tostring(PetModule.resid));
	pet_compose_data = resTableManager:GetRowValue(ResTable.pet_compose, tostring(PetModule.resid));
end

--根据当前宠物情况来刷新宠物形象和名称
function PetPanel:refreshPet()
	pet.Visibility = Visibility.Visible;
	pet:Destroy();

	--TODO
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_1_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_2_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_3_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_4_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_5_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_6_output/');

	pet:LoadArmature(pet_data['animation']);
	pet:SetAnimation('play');

	petName.Text = tostring(pet_data['name']);
end

--刷新当前宠物的品质和阶数
function PetPanel:refreshPetQuality()
	local level = PetModule.resid % 100;
	level_img.Image = GetPicture('pet/level_' .. level .. '.ccz');
	bg_img.Image = GetPicture('wing/quality_5.ccz');
end

--刷新当前宠物的数值
function PetPanel:refreshPetPro()
	pro.setPro(PetModule:getAttribute());
end

--刷新当前宠物的合成材料
function PetPanel:refreshMaterial()
	local stuff_id = pet_compose_data['stuff_1'];
	local stuff_num = pet_compose_data['stuff_1_num'];

	materialItem.initWithInfo(stuff_id, -1, 80, true);
	local have_mat_num = Package:GetItemCount(stuff_id);

	materialNumLabel.Text = tostring(have_mat_num .. ' / ' .. stuff_num);

end

--[[
function WingPanel:onMaterialClick(Args)
	local args = UIControlEventArgs(Args);
	
	if args.m_pControl.Tag == 0 then
		return;
	end
	local item = {};
	item.resid = args.m_pControl.Tag;
	local itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	local height = 100
	local wight = appFramework.ScreenWidth / 2
	TooltipPanel:setNeedAndHaveNum( needMaterialNum,curMaterialNum);
	TooltipPanel:ShowItem(wingPanel, item, TipMaterialShowButton.Obtain,Rect(wight,height,0,0));
end
--]]

--刷新各按钮的可点击状态
function PetPanel:refreshBtns()
	--进化按钮	
	local stuff_id = pet_compose_data['stuff_1'];
	local stuff_num = pet_compose_data['stuff_1_num'];

	local have_mat_num = Package:GetItemCount(stuff_id);
	btnCompose.Enable = (stuff_num <= have_mat_num and pet_compose_data['next_resid'] ~= 0);

	--下一级预览按钮
	btnNextPreview.Enable = (pet_compose_data['next_resid'] ~= 0);
end

--进化宠物
function PetPanel:onCompose()
	local msg = {};
	Network:Send(NetworkCmdType.req_compose_pet, msg);
end

--进化宠物返回
function PetPanel:onComposeCallback(msg)

end

--========================================================================
function PetPanel:Show()
	bg.Background = CreateTextureBrush('background/wing_bg.jpg', 'background')
	bottomBru.Background = CreateTextureBrush('wing/bottom_bru.ccz', 'wing');
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		btnNextPreview:SetScale(0.85, 0.85);
		bottomMidPanel:SetScale(0.8, 0.8);
		previewPanel:GetLogicChild('proPanel'):SetScale(0.85, 0.85);
	end
	petPanel.Visibility = Visibility.Visible;
end

function PetPanel:showPreview()
	previewPanel.Visibility = Visibility.Visible;
	shader.Visibility = Visibility.Visible;

	petPreview:Destroy();
	if pet_compose_data['next_resid'] == 0 then
		return;
	end
	local pet_data_next = resTableManager:GetRowValue(ResTable.pet, tostring(pet_compose_data['next_resid']));
	petPreview:LoadArmature(pet_data_next['animation']);
	petPreview:SetAnimation('play');
	petPreviewBru.Background = CreateTextureBrush('wing/bottom_bru.ccz', 'wing');
	petPreviewBg.Background = CreateTextureBrush('pet/pet_bg.ccz', 'pet');
	local pro = {};
	pro.atk = (pet_data_next['atk'][1] + pet_data_next['atk'][2])/2;
	pro.mgc = (pet_data_next['mgc'][1] + pet_data_next['mgc'][2])/2;
	pro.def = (pet_data_next['def'][1] + pet_data_next['def'][2])/2;
	pro.res = (pet_data_next['res'][1] + pet_data_next['res'][2])/2;
	pro.hp = (pet_data_next['hp'][1] + pet_data_next['hp'][2])/2;
	proPreview.setPro(pro.atk, pro.mgc, pro.def, pro.res, pro.hp);
end

function PetPanel:hidePreview()
	previewPanel.Visibility = Visibility.Hidden;
	shader.Visibility = Visibility.Hidden;
end

function PetPanel:Hide()
	DestroyBrushAndImage('background/wing_bg.jpg', 'background');
	DestroyBrushAndImage('wing/bottom_bru.ccz', 'wing');
	petPanel.Visibility = Visibility.Hidden;
end

function PetPanel:composeCallback()
	self:refreshPetData();
	self:refreshPet();
	self:refreshPetQuality();
	self:refreshPetPro();
	self:refreshMaterial();
	self:refreshBtns();
end

function PetPanel:gotoShop()
	self:onClose();
	
	HomePanel:onLeaveHomePanel();
	PropertyBonusesPanel:onClose();
	-- ShopPanel:OpenShop();
	ShopSetPanel:show(ShopSetType.gameShop)
end

--[[
function WingPanel:leaveWingPanel()
	TooltipPanel:materialPanelClose()
	WingPanel:onClose();
	HomePanel:onLeaveHomePanel();
end
--]]
