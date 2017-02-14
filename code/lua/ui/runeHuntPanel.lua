--runeHuntPanel.lua
--
--=====================================================
--获取符文界面
--
RuneHuntPanel =
{
};

--控件
local mainDesktop;
local runeHuntPanel;
local newsPanel;
local autoCheck;
local autoItem1;
local autoItem2;
local bg;
local generator_name;
local nameArmPanel;
local items = {};
local armPanel;
local btnIllustrate;
local btnShop;
local illPanel;
local effectPanel;

-- 变量
local news_num;
local curLevel;
local news_num;
local auto_timer;
local effect_timer;
local effectNum;

-- 初始化面板
function RuneHuntPanel:InitPanel(desktop)
	mainDesktop = desktop;
	runeHuntPanel = Panel(mainDesktop:GetLogicChild('runeHuntPanel'));
	runeHuntPanel:IncRefCount();
	runeHuntPanel.Visibility = Visibility.Hidden;
	runeHuntPanel.ZOrder = PanelZOrder.runeHunt;

	btnReturn = runeHuntPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:onClose');	

	newsPanel = runeHuntPanel:GetLogicChild('newsInfoPanel'):GetLogicChild('touchPanel'):GetLogicChild('news');
	self:InitWordsAndImg();
	bg = runeHuntPanel:GetLogicChild('bg');

	btnIllustrate = runeHuntPanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:showIllustrate');
	illPanel = runeHuntPanel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	illPanel:GetLogicChild('shader'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneHuntPanel:hideIllustrate');
	local txt = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	txt.Text = LANG_RUNE_HUNT_ILL;	

	btnShop = runeHuntPanel:GetLogicChild('btnShop');
	btnShop:SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:gotoShop');

	local itemPanel = runeHuntPanel:GetLogicChild('leftPanel'):GetLogicChild('itemPanel');
	items[10001] = {};
	items[10001].turn = 1;
	items[18001] = {};
	items[18001].turn = 2;
	items[18002] = {};
	items[18002].turn = 3;
	items[18003] = {};
	items[18003].turn = 4;

	for _, item in pairs(items) do
		item.control = itemPanel:GetLogicChild('item'..item.turn);
		item.labelNum = item.control:GetLogicChild('num');
		item.icon = item.control:GetLogicChild('icon');
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(_));
		item.icon.Image = GetPicture('icon/' .. itemData['icon'] .. '.ccz');
	end

	local checkedPanel = runeHuntPanel:GetLogicChild('leftPanel'):GetLogicChild('checkPanel');

	autoCheck = checkedPanel:GetLogicChild('autoSearch'):GetLogicChild('checkBox');
	autoCheck:SubscribeScriptedEvent('CheckBox::CheckChangedEvent','RuneHuntPanel:onAutoSearch');
	autoItem1 = checkedPanel:GetLogicChild('autoItem1'):GetLogicChild('checkBox');
	autoItem1:SubscribeScriptedEvent('CheckBox::CheckChangedEvent','RuneHuntPanel:onAutoItem1');
	autoItem2 = checkedPanel:GetLogicChild('autoItem2'):GetLogicChild('checkBox');
	autoItem2:SubscribeScriptedEvent('CheckBox::CheckChangedEvent','RuneHuntPanel:onAutoItem2');

	armPanel = runeHuntPanel:GetLogicChild('armPanel');
	armPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneHuntPanel:clickHunt');
	effectPanel = runeHuntPanel:GetLogicChild('effect');
	effectPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneHuntPanel:clickHunt');

	-- level
	generator_name = runeHuntPanel:GetLogicChild('bottomPanel'):GetLogicChild('namePanel'):GetLogicChild('name');
	nameArmPanel = runeHuntPanel:GetLogicChild('bottomPanel'):GetLogicChild('armPanel');

	-- news
	touchPanel = runeHuntPanel:GetLogicChild('newsInfoPanel'):GetLogicChild('touchPanel');
	newsPanel = touchPanel:GetLogicChild('news');

	runeHuntPanel:GetLogicChild('btnCompose'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:EnterCompose');
	runeHuntPanel:GetLogicChild('btnInlay'):SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:EnterInlay');
	-- 
	newsNum = 0;
	curLevel = 1;
	newsNum = 0;
	auto_timer = 0;
	effect_timer = 0;
	effectNum = 0;
end

function RuneHuntPanel:InitWordsAndImg()
	runeHuntPanel:GetLogicChild('bottomPanel'):GetLogicChild('il1').Text = LANG_RUNE_IL_1;
	runeHuntPanel:GetLogicChild('bottomPanel'):GetLogicChild('il2').Text = LANG_RUNE_IL_2;		
	runeHuntPanel:GetLogicChild('leftPanel'):GetLogicChild('checkPanel'):GetLogicChild('autoItem1'):GetLogicChild('label').Text = LANG_RUNE_AUTO_1;
	runeHuntPanel:GetLogicChild('leftPanel'):GetLogicChild('checkPanel'):GetLogicChild('autoItem2'):GetLogicChild('label').Text = LANG_RUNE_AUTO_2;
end

function RuneHuntPanel:updataArm()
	armPanel:RemoveAllChildren();
	local arm_hunt = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	arm_hunt.Horizontal = ControlLayout.H_CENTER;
	arm_hunt.Vertical = ControlLayout.V_CENTER;
	armPanel:AddChild(arm_hunt);
	armatureManager:LoadFile('resource/animation/rune_hunt_output/');
	arm_hunt:LoadArmature('rune_hunt_'..curLevel);
	arm_hunt:SetAnimation('play');
	arm_hunt:SetScale(2,2);
	arm_hunt.Visibility = Visibility.Visible;
end

function RuneHuntPanel:nameArm()
	nameArmPanel:RemoveAllChildren();
	local arm_hunt = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	arm_hunt.Horizontal = ControlLayout.H_CENTER;
	arm_hunt.Vertical = ControlLayout.V_CENTER;
	nameArmPanel:AddChild(arm_hunt);
	armatureManager:LoadFile('resource/animation/rune_name_output/');
	arm_hunt:LoadArmature('rune_name');
	arm_hunt:SetAnimation('play');
	arm_hunt:SetScale(1.5,1.5);
	arm_hunt.Visibility = Visibility.Visible;
end

function RuneHuntPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[18001], 'num', items[18001].labelNum, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[18002], 'num', items[18002].labelNum, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[18003], 'num', items[18003].labelNum, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', items[10001].labelNum, 'Text');
end

function RuneHuntPanel:unBind()
	uiSystem:UnBind(Package.goodsList[18001], 'num', items[18001].labelNum, 'Text');
	uiSystem:UnBind(Package.goodsList[18002], 'num', items[18002].labelNum, 'Text');
	uiSystem:UnBind(Package.goodsList[18003], 'num', items[18003].labelNum, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'money', items[10001].labelNum, 'Text');
end

-- 
function RuneHuntPanel:Destroy()
	runeHuntPanel = nil;
end

function RuneHuntPanel:Update()
end

function RuneHuntPanel:onShow()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.runeOpend then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_RUNE_IL_4);
		return;
	end
	newsNum = 0;
	-- 请求当前信息
	-- msg: 
	-- news
	-- curLevel
	local msg = {};
	Network:Send(NetworkCmdType.req_enter_rune_hunt_t,msg);
end

function RuneHuntPanel:Show(msg_)
	bg.Background = CreateTextureBrush('background/wing_bg.jpg', 'background');
	runeHuntPanel.Visibility = Visibility.Visible;
	self:InitHuntLevel(msg_.curLevel);
	curLevel = msg_.curLevel;

	self:InitNewsPanel(msg_.news);
	self:clearCheckBox();
	HomePanel:hideRolePanel();
	self:bind();
	uiSystem:UpdateDataBind();
	self:updataArm();
end


function RuneHuntPanel:onClose()
	if auto_timer ~= 0 then
		timerManager:DestroyTimer(auto_timer);
		auto_timer = 0;
	end
	local msg = {};
	Network:Send(NetworkCmdType.nt_leave_rune_hunt_t,msg,true);
	self:clearCheckBox();
	HomePanel:turnPageChange();
	HomePanel:showRolePanel();
	self:Hide();
end

function RuneHuntPanel:Hide()
	DestroyBrushAndImage('background/wing_bg.jpg', 'background');
	runeHuntPanel.Visibility = Visibility.Hidden;
	self:unBind();
end

function RuneHuntPanel:EnterCompose()
	self:onClose();
	RuneComposePanel:onShow();
end

function RuneHuntPanel:EnterInlay()
	self:onClose();
	RuneInlayPanel:onShow();
end

function RuneHuntPanel:clearCheckBox()
	autoCheck.Checked = false;
	autoItem1.Checked = false;
	autoItem2.Checked = false;
end

function RuneHuntPanel:InitHuntLevel(level_)
	local probData = resTableManager:GetRowValue(ResTable.rune_prob, tostring(level_));
	if probData then
		generator_name.Text = tostring(probData['name']);
	end
end

function RuneHuntPanel:clickHunt()
	if autoCheck.Checked == true then
		return;
	end
	self:Hunt();
end

function RuneHuntPanel:Hunt()
	if auto_timer ~= 0 then
		timerManager:DestroyTimer(auto_timer);
		auto_timer = 0;
	end
	local cost = resTableManager:GetValue(ResTable.rune_prob, tostring(curLevel), 'cost');
	if ActorManager.user_data.money < cost then
		autoCheck.Checked = false;
		return;
	end
	local msg = {};
	if autoItem2.Checked == true then
		msg.use_item = 18003;
	elseif autoItem1.Checked == true then
		msg.use_item = 18002;
	else
		msg.use_item = -1;
	end
	Network:Send(NetworkCmdType.req_hunt_rune_t,msg);
end

function RuneHuntPanel:huntCallBack(msg_)
	self:InitHuntLevel(msg_.new_level);
	self:playEffect(msg_.new_resid);
	if autoCheck.Checked then
		auto_timer = timerManager:CreateTimer(2, 'RuneHuntPanel:Hunt', 0);
	end
	if msg_.new_level ~= curLevel then
		curLevel = msg_.new_level;
		self:updataArm();
	end
	self:nameArm();
end

function RuneHuntPanel:playEffect(resid)
	local img = uiSystem:CreateControl('ImageElement');
	effectPanel:RemoveAllChildren();
	img.Horizontal = ControlLayout.H_CENTER;
	img.Vertical = ControlLayout.V_CENTER;
	img:SetScale(1.6, 1.6);
	img.Opacity = 1;
	local icon_path = resTableManager:GetValue(ResTable.rune, tostring(resid*100+1), 'icon');
	img.Image = GetPicture('icon/'..icon_path..'.ccz');
	img.Name = 'effect';
	effectNum = 0;
	effectPanel:AddChild(img);
	if effect_timer ~= 0 then
		timerManager:DestroyTimer(effect_timer);
		effect_timer = 0;
	end
	effect_timer = timerManager:CreateTimer(0.01, 'RuneHuntPanel:effectUpdate', 0);
end

function RuneHuntPanel:effectUpdate()
	if effectNum >= 80 then
		timerManager:DestroyTimer(effect_timer);
		effect_timer = 0;
		effectPanel:RemoveAllChildren();
		return;
	end
	local ima_effect = effectPanel:GetLogicChild('effect');
	effectNum = effectNum + 1;
	local scale_c;
	local opacity_c;
	if effectNum <= 25 then
		scale_c = 0.05*effectNum;
		opacity_c = 0.025*effectNum;
	else
		scale_c = 0.8;
		opacity_c = 1;
	end
	ima_effect:SetScale(scale_c, scale_c);
--	ima_effect.Opacity = opacity_c;
end

function RuneHuntPanel:InitNewsPanel(news)
	newsPanel:RemoveAllChildren();
	if not news then
		return;
	end
	for _, newsItem in pairs(news) do
		self:AddNews(newsItem);
	end
end

function RuneHuntPanel:receiveNews(msg_)
	if runeHuntPanel.Visibility == Visibility.Hidden then
		return;
	end
	self:AddNews(msg_.news);
end

function RuneHuntPanel:AddNews(newsItem)
	newsNum = newsNum + 1;

	local newsLabel = customUserControl.new(newsPanel, 'runeHuntNewsTemplate');
	newsLabel.initWithInfo(newsItem.name, newsItem.resid);

	local height = newsNum*80;
	height = height>320 and height or 320;
	newsPanel.Size = Size(380, height);
	runeHuntPanel:GetLogicChild('newsInfoPanel'):GetLogicChild('touchPanel').VScrollPos = height;
end

function RuneHuntPanel:onAutoSearch()
	if autoCheck.Checked == true then
		self:Hunt();
	end
end

function RuneHuntPanel:onAutoItem1()
end

function RuneHuntPanel:onAutoItem2()
end

--显示说明
function RuneHuntPanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function RuneHuntPanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end

function RuneHuntPanel:gotoShop()
	ShopSetPanel:show(ShopSetType.runeShop);
	--MessageBox:ShowDialog(MessageBoxType.Ok, LANG_RUNE_WARNING_8);
end
