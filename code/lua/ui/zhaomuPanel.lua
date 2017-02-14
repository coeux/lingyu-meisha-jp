--zhaomuPanel.lua
--招募界面
--================================================
ZhaomuPanel = 
	{
		pub_type;
		rest_free_times;
		show_special_flag;
		show_stepup_flag;
		cur_state;
		cur_stepup_state_4;
		cur_stepup_state_3;
		isTipShow;
		isTaskShow;
		stepupBrush1;
		stepupBrush2;
		stepupBrush3;
		stepup_circle;
		stepup_arrow;
		eventBrush1;
		eventBrush2;
		evebtBrush3;
		event_circle;
		event_arrow;
		detailPanel;
		will_show = -1;
	};

--常量
local jinbi_1;
local jinbi_10;
local zhizun_1;
local zhizun_10;
local shenmi_1;
local shenmi_10;

local selectFont;
local unselectFont;
local lockTimer;

local pub_show;
local armElapseTable = {
	[1] = 0.05,
	[2] = 0.05,
	[3] = 0.1,
	[4] = 0.1,
	[5] = 0.2,
	[6] = 0.2,
	[7] = 0.1,
	[8] = 0.1,
	[9] = 0.05,
	[10] = 0.05,
};


--控件
local mainDesktop;
local panel;
local btnReturn;
local rolePanel;
local changeRolePanel;
local stepupBtnPanel;
local role_name;
local role_arm;
local target_arm;
local role_navi;
local role_qu;
local role_des;
local prev_btn;
local next_btn;
local play_btn;

local detailBtn;
local currencyPanel;
local coin_scroll;
local gem_scroll;
local label_Money;
local label_Zuanshi;

local onePub;
local tenPub;
local choosePanel;
local bg;
local bg1;
local imgPanel;
local imgBg;
local img1;
local img2;
local img4;


local btnList;
local stepupbtnList;
local one_icon;
local one_consume_num;
local one_free_time;
local one_rest_times;

local one_normal;
local one_free;

--变量
local isVisible;
local refreshTimer;						--免费的计时器
local initTimer;
local bgRollingTimer;
local stepupArmTimer;

local bg_list = {};
local stepup_list = {};
local event_list = {};
local is_play;
local go_change;
local armElapse;
local armCount;
local is_lock;

--私有方法
local getDotStr = function(num)
	local str;
	if num > 999 then
		str = math.floor(num/1000) .. ',' .. string.sub(tostring(num),-3,-1);
	else
		str = tostring(num);
	end
	return str;
end

local get2digit = function(num)
	local str;
	if num < 10 then
		str = '0' .. num;
	else
		str = tostring(num);
	end
	return str;
end

local getTimeStr = function(n)
	local str;
	num = math.floor(n)
	if num < 60 then
		str = '00:00:' .. num;
	elseif num < 3600 then
		local minute = math.floor(num / 60);
		local second = num % 60;
		str = '00:' .. get2digit(minute) .. ':' .. get2digit(second);
	else
		local hour = math.floor(num / 3600);
		local minute = math.floor((num - hour*3600) / 60);
		local second = num % 60;
		str = get2digit(hour) .. ':' .. get2digit(minute) .. ':' .. get2digit(second);
	end
	return str;
end

--初始化
function ZhaomuPanel:InitPanel(desktop)
	--变量
	self.cur_state = 1;
	self.isTipShow = false;
	self.isTaskShow = false;
	self.rest_free_times = 0;
	initTimer = false;

	refreshTimer = 0;
	self.pub_type = 1;

	bgRollingTimer = 0;
	stepupArmTimer = 0;
	is_lock = false;
	lockTimer = 0;

	--控件
	mainDesktop = desktop;
	panel = mainDesktop:GetLogicChild('zhaomuPanel');
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.Zhaomu;

	btnReturn = panel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:onClose');

	currencyPanel = panel:GetLogicChild('currency');
	coin_scroll = currencyPanel:GetLogicChild('coinScroll'):GetLogicChild('num');
	gem_scroll = currencyPanel:GetLogicChild('gemScroll'):GetLogicChild('num');
	label_Money = currencyPanel:GetLogicChild('moneyPanel'):GetLogicChild('num');
	currencyPanel:GetLogicChild('moneyPanel'):SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold');
	label_Zuanshi = currencyPanel:GetLogicChild('gemPanel'):GetLogicChild('num');
	currencyPanel:GetLogicChild('gemPanel'):SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onShowRechargePanel');


	stepupBtnPanel = panel:GetLogicChild('stepupBtnPanel');

	rolePanel = panel:GetLogicChild('rolePanel');
	changeRolePanel = panel:GetLogicChild('changeRole');
	role_name = rolePanel:GetLogicChild('roleInfo'):GetLogicChild('name');
	role_arm = rolePanel:GetLogicChild('roleInfo'):GetLogicChild('role_arm');
	target_arm = rolePanel:GetLogicChild('roleInfo'):GetLogicChild('target_arm');
	role_navi = rolePanel:GetLogicChild('navi');
	role_qu = rolePanel:GetLogicChild('roleInfo'):GetLogicChild('qu_img');
	role_des = rolePanel:GetLogicChild('des');
	prev_btn = changeRolePanel:GetLogicChild('prev_btn');
	prev_btn:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:prev_role');
	next_btn = changeRolePanel:GetLogicChild('next_btn');
	next_btn:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:next_role');
	play_btn = rolePanel:GetLogicChild('roleInfo'):GetLogicChild('playBtn');
	play_btn:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:playAcotor');

	detailBtn = rolePanel:GetLogicChild('detailBtn');
	detailBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:detailRoleInfo');

	onePub = panel:GetLogicChild('onePub');
	onePub:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:on_one_pub');
	one_normal = onePub:GetLogicChild('normal');
	one_free = onePub:GetLogicChild('free');
	one_rest_times = one_free:GetLogicChild('free_times');
	one_icon = one_normal:GetLogicChild('img');
	one_consume_num = one_normal:GetLogicChild('num');
	one_free_time = one_normal:GetLogicChild('free_time');

	tenPub = panel:GetLogicChild('tenPub');
	tenPub:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:on_ten_pub');
	ten_icon = tenPub:GetLogicChild('img');
	ten_consume_num = tenPub:GetLogicChild('num');

	choosePanel = panel:GetLogicChild('choosePanel');

	imgPanel = panel:GetLogicChild('imgPanel');
	imgBg = imgPanel:GetLogicChild('imgBG');
	img1 = imgPanel:GetLogicChild('img1');
	img2 = imgPanel:GetLogicChild('img2');
	img4 = imgPanel:GetLogicChild('img4');
	imgBg.Image = GetPicture('chouka/chouka_img3.ccz');
	img1.Image = GetPicture('chouka/chouka_img1.ccz');
	img2.Image = GetPicture('chouka/chouka_img2.ccz');
	img4.Image = GetPicture('chouka/chouka_img4.ccz');
	imgPanel.Visibility = Visibility.Hidden;

	bg = panel:GetLogicChild('bg');
	bg1 = panel:GetLogicChild('bg1');
	self.stepupBrush1 = panel:GetLogicChild('stepupBrush1');
	self.stepupBrush2 = panel:GetLogicChild('stepupBrush2');
	self.stepupBrush3 = panel:GetLogicChild('stepupBrush3');
	self.stepup_circle = self.stepupBrush2:GetLogicChild('circle');
	self.stepup_arrow = self.stepupBrush3:GetLogicChild('arrow');
	self.eventBrush1 = panel:GetLogicChild('eventBrush1');
	self.eventBrush2 = panel:GetLogicChild('eventBrush2');
	self.eventBrush3 = panel:GetLogicChild('eventBrush3');
	self.event_circle = self.eventBrush2:GetLogicChild('circle');
	self.event_arrow = self.eventBrush3:GetLogicChild('arrow');
	for i=1, 4 do
		bg_list[i] = 0;
	end
	for i=1, 3 do
		stepup_list[i] = 0;
	end
	for i=1, 3 do
		event_list[i] = 0;
	end

	jinbi_1 = resTableManager:GetValue(ResTable.config, tostring(1), 'value');
	jinbi_10 = resTableManager:GetValue(ResTable.config, tostring(2), 'value');
	zhizun_1 = resTableManager:GetValue(ResTable.config, tostring(3), 'value');
	zhizun_10 = resTableManager:GetValue(ResTable.config, tostring(4), 'value');
	shenmi_1 = resTableManager:GetValue(ResTable.config, tostring(5), 'value');
	shenmi_10 = resTableManager:GetValue(ResTable.config, tostring(6), 'value');

	btnList = {};
	stepupbtnList = {};
	pub_show = 1;

	self.btnDetail = currencyPanel:GetLogicChild('btnDetail');
	self.btnDetail:SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:ShowDetail');
	self.detailPanelMain = panel:GetLogicChild('detailPanel');
	self.detailPanel = self.detailPanelMain:GetLogicChild('center');
	self.detailPanelMain.Visibility = Visibility.Hidden;
	self.detailPanelMain:GetLogicChild('closeBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'ZhaomuPanel:HideDetail');
end

function ZhaomuPanel:initPubShow()
	pub_show = {};
	local rowNum = resTableManager:GetRowNum(ResTable.pub_show);
	for index = 1, rowNum do
		local rowData = resTableManager:GetValue(ResTable.pub_show, index-1, {'id', 'role_id'});
		local pub_type = math.floor(rowData['id'] / 100);
		local pub_index = math.floor(rowData['id'] % 100);
		if not pub_show[pub_type] then
			pub_show[pub_type] = {};
			pub_show[pub_type].cur_index = 1;
		end
		local data = resTableManager:GetRowValue(ResTable.actor, tostring(rowData['role_id']));
		if data then
			pub_show[pub_type][pub_show[pub_type].cur_index] = rowData['role_id'];
			pub_show[pub_type].cur_index = pub_show[pub_type].cur_index + 1;
		end
	end
end

--销毁
function ZhaomuPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
function ZhaomuPanel:ZhaomuTipShow()
	self.isTipShow = true;
	self:onShow();
end

function ZhaomuPanel:TaskShow()
	self.isTaskShow = true;
	self:onShow();
end

function ZhaomuPanel:onShow(showFlag)
	self.will_show = showFlag or -1;
	local msg = {};
	Network:Send(NetworkCmdType.req_enter_pub_t, msg);
end

--显示
function ZhaomuPanel:Show(showFlag)
	is_lock = false;
	self.show_special_flag = showFlag.show_3 or false;
	self.show_stepup_flag = showFlag.show_4 or false;
	self.cur_stepup_state_4 = showFlag.state_4;
	self.cur_stepup_state_3 = showFlag.state_3;

	if WingPanel:isVisible() then
		panel.ZOrder = PanelZOrder.Zhaomu + PanelZOrder.wing;
	elseif HomePanel:returnVisble() then
		panel.ZOrder = PanelZOrder.Zhaomu + PanelZOrder.cardinfo;
		HomePanel:setRolePanelZOrder(false)
	else
		panel.ZOrder = PanelZOrder.Zhaomu;
	end
	is_play = false;
	go_change = false;

	if ActorManager.user_data.role.lvl.level < 6 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_ZHAOMU_TIP_5);
		return;
	end
	MainUI:IncCount();
	panel.Visibility = Visibility.Visible;
	self:bind();
	uiSystem:UpdateDataBind();
	self:refresh();
	self:updateBg();
	if pub_show == 1 then
		self:initPubBtn();
		self:initPubShow();
	end

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);

	--获取图标
	currencyPanel:GetLogicChild('coinScroll'):GetLogicChild('img').Image = GetPicture('icon/10012.ccz');
	currencyPanel:GetLogicChild('gemScroll'):GetLogicChild('img').Image = GetPicture('icon/10013.ccz');

	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		local ctrl = {};
		self:SelectPub(ctrl, 2);
		UserGuidePanel:ShowGuideShade(onePub,GuideEffectType.hand, GuideTipPos.right);
	else
		if self.isTipShow then
			local ctrl = {};
			self:SelectPub(ctrl, 2);
			self.isTipShow = false;
		elseif self.isTaskShow then
			local ctrl = {};
			self:SelectPub(ctrl, 1);
			self.isTaskShow = false;
		else
			local ctrl = {};
			local show_page = showFlag.show_4 and 4 or (showFlag.show_3 and 3 or 2);
			if self.will_show ~= -1 then
				if self.will_show == 3 and showFlag.show_3 then
					self:SelectPub(ctrl, 3);
				elseif self.will_show == 4 and showFlag.show_4 then
					self:SelectPub(ctrl, 4);
				else
					self:SelectPub(ctrl, show_page);
				end
				self.will_show = -1;
			else
				self:SelectPub(ctrl, show_page);				
			end
		end
	end
	GodsSenki:LeaveMainScene();
end

--隐藏
function ZhaomuPanel:Hide()
	MainUI:DecCount();
	self:unbind();
	panel.Visibility = Visibility.Hidden;
	if refreshTimer ~= 0 then
		timerManager:DestroyTimer(refreshTimer);
		refreshTimer = 0;
	end
	if bgRollingTimer ~= 0 then
		timerManager:DestroyTimer(bgRollingTimer);
		bgRollingTimer = 0;
	end
	initTimer = false;

	for i=1, 4 do
		if bg_list[i] > 0 then
			DestroyBrushAndImage('chouka/chouka_bg_' .. i .. '.jpg', 'chouka');
			bg_list[i] = 0;
		end
	end
	for i=1, 3 do
		if stepup_list[i] > 0 then
			DestroyBrushAndImage('chouka/stepup_brush' .. i .. '.ccz', 'chouka');
		stepup_list[i] = 0;
		end
	end
	for i=1, 3 do
		if event_list[i] > 0 then
			DestroyBrushAndImage('chouka/event_brush' .. i .. '.ccz', 'chouka');
		event_list[i] = 0;
		end
	end
	DestroyBrushAndImage('chouka/chouka_bg_2_1.jpg', 'chouka');
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function ZhaomuPanel:initPubBtn()
	btnList = {};
	choosePanel:RemoveAllChildren();
	if self.show_stepup_flag then
		local btn = customUserControl.new(choosePanel, 'pubBtnTemplate');
		btn.initWithInfo(4);
		btnList[4] = btn;
	end
	if self.show_special_flag then
		local btn = customUserControl.new(choosePanel, 'pubBtnTemplate');
		btn.initWithInfo(3);
		btnList[3] = btn;
	end
	for i=2, 1, -1 do
		local btn = customUserControl.new(choosePanel, 'pubBtnTemplate');
		btn.initWithInfo(i);
		btnList[i] = btn;
	end
end

function ZhaomuPanel:playAcotor()
	if is_play then
		return;
	end
	is_play = true;
	local r = math.random(1, 3);
	local actorInfo = 
	{
		AnimationType.attack,
		AnimationType.skill,
		AnimationType.skill2,
	}
	local data = resTableManager:GetRowValue(ResTable.actor, tostring(self.cur_role));
	local script;
	if r == 1 then
		script = data['atk_script'];
	elseif r == 2 then
		script = data['skill_script'];
	elseif r == 3 then
		script = data['skill_script2'];
	end

	AvatarPosEffect:SetPlayerEnemyArmature(role_arm, target_arm);
	LoadLuaFile('skillScript/' .. script .. '.lua');
	--加载脚本所需资源
	local script_lua = _G[script];
	script_lua:preLoad();
	local effectScript = effectScriptManager:CreateEffectScript(script);
	effectScript:SetArgs('Attacker', 100);
	--此参数代表此次攻击的ID，参数名称等测试完毕更改技能脚本
	effectScript:SetArgs('Targeter', -100);
	effectScript:TakeOff();

	role_arm:SetAnimation(tostring(actorInfo[r]));
	role_arm:SetScriptAnimationCallback('ZhaomuPanel:actorEnd', 0);	
end

function ZhaomuPanel:actorEnd()
	is_play = false;
	role_arm:SetAnimation(AnimationType.f_idle);
	if go_change then
		self:initRole();
		go_change = false;
	end
end


--刷新
function ZhaomuPanel:refresh()
	--刷新免费时间
	self:refreshFreeTime();
end

--绑定数据
function ZhaomuPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[10012], 'num', coin_scroll, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[10013], 'num', gem_scroll, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', label_Money, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', label_Zuanshi, 'Text');
end

--取消绑定数据
function ZhaomuPanel:unbind()
	uiSystem:UnBind(Package.goodsList[10012], 'num', coin_scroll, 'Text');
	uiSystem:UnBind(Package.goodsList[10013], 'num', gem_scroll, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'money', label_Money, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'rmb', label_Zuanshi, 'Text');
end

function ZhaomuPanel:refreshFreeTime()
	--初始化
	if initTimer == false then
		refreshTimer = timerManager:CreateTimer(1.0, 'ZhaomuPanel:refreshFreeTime', 0);
		initTimer = true;
	end
	self:updateTimeLabel();
end

function ZhaomuPanel:updateTimeLabel()
	if self.cur_state == 1 then
		if self.rest_free_times and self.rest_free_times > 0 then
			if putong_time <= 0 then
				one_normal.Visibility = Visibility.Hidden;
				one_free.Visibility = Visibility.Visible;
				one_rest_times.Text = string.format(LANG_pubNewPanel_24, tonumber(self.rest_free_times or 1));
			else
				one_normal.Visibility = Visibility.Visible;
				one_free.Visibility = Visibility.Hidden;
				one_free_time.Text = getTimeStr(putong_time);
				one_free_time.Visibility = Visibility.Visible;
			end
		else
			one_normal.Visibility = Visibility.Visible;
			one_free.Visibility = Visibility.Hidden;
			one_free_time.Visibility = Visibility.Hidden;
		end
	elseif self.cur_state == 2 then
		if zhizun_time <= 0 then
			one_normal.Visibility = Visibility.Hidden;
			one_free.Visibility = Visibility.Visible;
			one_rest_times.Text = string.format(LANG_pubNewPanel_24, 1);
		else
			one_normal.Visibility = Visibility.Visible;
			one_free.Visibility = Visibility.Hidden;
			one_free_time.Text = getTimeStr(zhizun_time);
			one_free_time.Visibility = Visibility.Visible;
		end
	elseif self.cur_state == 3 then
		one_normal.Visibility = Visibility.Visible;
		one_free.Visibility = Visibility.Hidden;
		one_free_time.Visibility = Visibility.Hidden;
	end
end

function ZhaomuPanel:UpdateZhizunTip(flag)
	ZhaomuPanel.zhizunTip = flag
	self:UpdateZhaomuTipFlag()
	if btnList[2] then
		btnList[2].setRedPoint(flag);
	end
end

function ZhaomuPanel:UpdatePutongTip(flag)
	ZhaomuPanel.putongTip = flag
	self:UpdateZhaomuTipFlag()
	if btnList[1] then
		btnList[1].setRedPoint(flag);
	end
end

function ZhaomuPanel:UpdateZhaomuTipFlag()
	if  self.zhizunTip or self.putongTip then
		MenuPanel:ZhaomuTip(true)
	else
		MenuPanel:ZhaomuTip(false)
	end
end

function ZhaomuPanel:refreshStatus()
	if self.cur_state == 1 then
		--普通
		local scroll_item = Package:GetItem(10012);
		local scroll_num = scroll_item and scroll_item.num or 0;
		if self.rest_free_times and self.rest_free_times > 0 and putong_time <= 0 then
		elseif scroll_num >= 1 then
			one_icon.Image = GetPicture('icon/10012.ccz');
			one_consume_num.Text = '1';
		else
			one_icon.Image = GetPicture('icon/10001.ccz');
			one_consume_num.Text = getDotStr(jinbi_1);
		end
		if scroll_num >= 10 then
			ten_icon.Image = GetPicture('icon/10012.ccz');
			ten_consume_num.Text = '10';
		else
			ten_icon.Image = GetPicture('icon/10001.ccz');
			ten_consume_num.Text = getDotStr(jinbi_10);
		end
	elseif self.cur_state == 2 then
		--至尊
		local scroll_item = Package:GetItem(10013);
		local scroll_num = scroll_item and scroll_item.num or 0;
		if zhizun_time <= 0 then
			
		elseif scroll_num >= 1 then
			one_icon.Image = GetPicture('icon/10013.ccz');
			one_consume_num.Text = '1';
		else
			one_icon.Image = GetPicture('icon/10003.ccz');
			one_consume_num.Text = getDotStr(zhizun_1);
		end
		if scroll_num >= 10 then
			ten_icon.Image = GetPicture('icon/10013.ccz');
			ten_consume_num.Text = '10';
		else
			ten_icon.Image = GetPicture('icon/10003.ccz');
			ten_consume_num.Text = getDotStr(zhizun_10);
		end
	elseif self.cur_state == 3 then
		--神秘
		local scroll_item = Package:GetItem(10013);
		local scroll_num = scroll_item and scroll_item.num or 0;
		if scroll_num >= 1 then
			one_icon.Image = GetPicture('icon/10013.ccz');
			one_consume_num.Text = '1';
		else
			one_icon.Image = GetPicture('icon/10003.ccz');
			one_consume_num.Text = getDotStr(shenmi_1);
		end
		if scroll_num >= 10 then
			ten_icon.Image = GetPicture('icon/10013.ccz');
			ten_consume_num.Text = '10';
		else
			ten_icon.Image = GetPicture('icon/10003.ccz');
			ten_consume_num.Text = getDotStr(shenmi_10);
		end
	end
end

--======================================================
--功能函数
--关闭
function ZhaomuPanel:onClose()
	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.card);
	end
	if HomePanel:returnVisble() and (not WingPanel:isVisible()) then
		HomePanel:setRolePanelZOrder(true)
		CardRankupPanel:refreshHaveCount()
	end
	self:Hide();
	GodsSenki:BackToMainScene(SceneType.HomeUI);
end

--选取不同的抽卡方式
function ZhaomuPanel:SelectPub(Args, manual)
	if manual then
		self.cur_state = manual;
	else
		local args = UIControlEventArgs(Args);
		self.cur_state = args.m_pControl.Tag;
	end

	for _, btn in pairs(btnList) do
		if btn.GetTag() == self.cur_state then
			btn.beSelected();
		else
			btn.beUnSelected();
		end
	end

	stepupBtnPanel.Visibility = Visibility.Hidden;
	onePub.Visibility = Visibility.Hidden;
	tenPub.Visibility = Visibility.Hidden;
	if self.cur_state == 4 then
		rolePanel.Visibility = Visibility.Visible;
		rolePanel:GetLogicChild('roleInfo').Visibility = Visibility.Hidden;
		rolePanel:GetLogicChild('des').Visibility = Visibility.Hidden;
		rolePanel:GetLogicChild('detailBtn').Visibility = Visibility.Hidden;
		self.cur_role_index = 1;
		self:initRole();
		changeRolePanel.Visibility = Visibility.Visible;
		stepupBtnPanel.Visibility = Visibility.Visible;
		self:initStepupBtnPanel();
	elseif self.cur_state == 3 then
		rolePanel.Visibility = Visibility.Visible;
		rolePanel:GetLogicChild('roleInfo').Visibility = Visibility.Hidden;
		rolePanel:GetLogicChild('des').Visibility = Visibility.Hidden;
		rolePanel:GetLogicChild('detailBtn').Visibility = Visibility.Hidden;
		self.cur_role_index = 1;
		self:initRole();
		changeRolePanel.Visibility = Visibility.Visible;
		stepupBtnPanel.Visibility = Visibility.Visible;
		self:initStepupBtnPanel();
	elseif self.cur_state == 2 then
		rolePanel.Visibility = Visibility.Visible;
		rolePanel:GetLogicChild('roleInfo').Visibility = Visibility.Visible;
		rolePanel:GetLogicChild('des').Visibility = Visibility.Visible;
		rolePanel:GetLogicChild('detailBtn').Visibility = Visibility.Visible;
		self.cur_role_index = 1;
		self:initRole();
		changeRolePanel.Visibility = Visibility.Visible;
		onePub.Visibility = Visibility.Visible;
		tenPub.Visibility = Visibility.Visible;
	elseif self.cur_state == 1 then
		rolePanel.Visibility = Visibility.Hidden;
		changeRolePanel.Visibility = Visibility.Hidden;
		onePub.Visibility = Visibility.Visible;
		tenPub.Visibility = Visibility.Visible;
	end

	self:updateTimeLabel();
	self:refreshStatus();
	self:updateBg();
end

function ZhaomuPanel:initStepupBtnPanel()
	local cur_stepup_state;
	if self.cur_state == 4 then
		cur_stepup_state = self.cur_stepup_state_4;
	elseif self.cur_state == 3 then
		cur_stepup_state = self.cur_stepup_state_3;
	else
		return;
	end

	if cur_stepup_state == 0 then
		return;
	end

	stepupBtnPanel:RemoveAllChildren();
	for i=1, 5 do
		local btn = customUserControl.new(stepupBtnPanel, 'stepupBtnGreyTemplate');
		btn.initWithInfo(i, cur_stepup_state, self.cur_state);
		stepupbtnList[i] = btn;
	end
	local btn = customUserControl.new(stepupBtnPanel, 'stepupBtnTemplate');
	btn.initWithInfo(cur_stepup_state, self.cur_state);
	stepupbtnList[6] = btn;
end

function ZhaomuPanel:clickStepupBtn()
	if is_lock then
		return;
	end
	local cur_stepup_state;
	local send_flag;
	if self.cur_state == 4 then
		cur_stepup_state = self.cur_stepup_state_4;
		send_flag = 7;
	elseif self.cur_state == 3 then
		cur_stepup_state = self.cur_stepup_state_3;
		send_flag = 5;
	else
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, send_flag);
	local str = LANG_ZHAOMU_TIP_7;
	if cur_stepup_state == 2 then
		str = string.format(LANG_ZHAOMU_TIP_8, 2);
	elseif cur_stepup_state == 3 then
		str = string.format(LANG_ZHAOMU_TIP_8, 6);
	elseif cur_stepup_state == 4 then
		str = string.format(LANG_ZHAOMU_TIP_8, 7);
	elseif cur_stepup_state == 5 then
		str = string.format(LANG_ZHAOMU_TIP_8, 14);
	end
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

function ZhaomuPanel:showStepupArm()
	--TODO 
	if self.cur_state == 4 then
		self.cur_stepup_state_4 = self.cur_stepup_state_4 + 1;
		if self.cur_stepup_state_4 > 5 then
			self.cur_stepup_state_4 = 1;
	end
	elseif self.cur_state == 3 then
		self.cur_stepup_state_3 = self.cur_stepup_state_3 + 1;
		if self.cur_stepup_state_3 > 5 then
			self.cur_stepup_state_3 = 1;
		end
	end
	stepupbtnList[6]:Hide();

	if stepupArmTimer ~= 0 then
		timerManager:DestroyTimer(stepupArmTimer);
		stepupArmTimer = 0;
	end
	armElapse = 0;
	armCount = 0;
	stepupArmTimer = timerManager:CreateTimer(0.05, 'ZhaomuPanel:playStepupArm', 0);
end

function ZhaomuPanel:playStepupArm()
	armCount = armCount + 1;
	armElapse = armElapse + armElapseTable[armCount] or 0;

	for i=1, 5 do
		stepupbtnList[i].updateToNextPos(armElapse);
	end
	if armCount >= 10 then
		timerManager:DestroyTimer(stepupArmTimer);
		stepupArmTimer = 0;
		for i=1, 5 do
			stepupbtnList[i].setNewPos();
		end
		if self.cur_state == 3 then
			stepupbtnList[6].changeID(self.cur_stepup_state_3);
		elseif self.cur_state == 4 then
			stepupbtnList[6].changeID(self.cur_stepup_state_4);
		end
		stepupbtnList[6]:Show();
	end
end

function ZhaomuPanel:prev_role()
	self.cur_role_index = self.cur_role_index - 1;
	if self.cur_role_index < 1 then
		self.cur_role_index = #pub_show[self.cur_state];
	end
	if is_play then
		go_change = true;
		return;
	end
	self:initRole();
end

function ZhaomuPanel:next_role()
	self.cur_role_index = self.cur_role_index + 1;
	if self.cur_role_index > #pub_show[self.cur_state] then
		self.cur_role_index = 1;
	end
	if is_play then
		go_change = true;
		return;
	end
	self:initRole();
end

function ZhaomuPanel:initRole()
	local aim_resid = pub_show[self.cur_state][self.cur_role_index];
	if self.cur_role == aim_resid then
		return;
	end
	self.cur_role = aim_resid;
	local data = resTableManager:GetRowValue(ResTable.actor, tostring(self.cur_role));
	local rare = resTableManager:GetValue(ResTable.item, tostring(self.cur_role+40000), 'quality');
	role_navi.Image = GetPicture('chouka/navi_'..self.cur_role..'.ccz');
	if rolePanel:GetLogicChild('roleInfo').Visibility == Visibility.Visible then
		role_name.Text = tostring(data['name']);
		role_qu.Image = GetPicture('chouka/qu_'..rare..'.ccz');
		role_des.Image = GetPicture('chouka/des_'..self.cur_role..'.ccz');
	role_arm:Destroy();
	local path = GlobalData.AnimationPath .. data['path'] .. '/';
	AvatarManager:LoadFile(path);
	role_arm:LoadArmature(data['img']);
	role_arm:SetAnimation(AnimationType.f_idle);
	role_arm:SetScale(1.3, 1.3);
	role_arm.Horizontal = ControlLayout.H_CENTER;
	role_arm.Vertical = ControlLayout.V_CENTER;
	end

end

--显示背景
function ZhaomuPanel:updateBg()
	bg.Translate = Vector2(0,0);
	bg1.Translate = Vector2(1134,0);
	if bgRollingTimer ~= 0 then
		timerManager:DestroyTimer(bgRollingTimer);
		bgRollingTimer = 0
	end

	imgPanel.Visibility = Visibility.Hidden;

	self.stepupBrush1.Visibility = Visibility.Hidden;
	self.stepupBrush2.Visibility = Visibility.Hidden;
	self.stepupBrush3.Visibility = Visibility.Hidden;
	self.eventBrush1.Visibility = Visibility.Hidden;
	self.eventBrush2.Visibility = Visibility.Hidden;
	self.eventBrush3.Visibility = Visibility.Hidden;
	self.btnDetail.Visibility = Visibility.Hidden;

	if self.cur_state == 2 then
		imgPanel.Visibility = Visibility.Visible;
		bgRollingTimer = timerManager:CreateTimer(0.1, 'ZhaomuPanel:bgRollingUpatd', 0);
		bg1.Background = CreateTextureBrush('chouka/chouka_bg_2_1.jpg', 'chouka');
	elseif self.cur_state == 3 then
		self.eventBrush1.Visibility = Visibility.Visible;
		self.eventBrush2.Visibility = Visibility.Visible;
		self.eventBrush3.Visibility = Visibility.Visible;
		self.event_circle.Background = CreateTextureBrush('chouka/stepup_circle.ccz', 'chouka');
		self.event_arrow.Background = CreateTextureBrush('chouka/stepup_select.ccz', 'chouka');
		for i=1, 3 do
			if event_list[i] == 0 then
				self.eventBrush1:GetLogicChild('event_brush'..i).Background = CreateTextureBrush('chouka/event_brush'..i..'.ccz', 'chouka');
				event_list[i] = event_list[i] + 1;
	end
		end
	elseif self.cur_state == 4 then
		self.stepupBrush1.Visibility = Visibility.Visible;
		self.stepupBrush2.Visibility = Visibility.Visible;
		self.stepupBrush3.Visibility = Visibility.Visible;
		self.stepup_circle.Background = CreateTextureBrush('chouka/stepup_circle.ccz', 'chouka');
		self.stepup_arrow.Background = CreateTextureBrush('chouka/stepup_select.ccz', 'chouka');
		for i=1, 3 do
			if stepup_list[i] == 0 then
				self.stepupBrush1:GetLogicChild('stepup_brush'..i).Background = CreateTextureBrush('chouka/stepup_brush'..i..'.ccz', 'chouka');
				stepup_list[i] = stepup_list[i] + 1;
			end
		end
		self.btnDetail.Visibility = Visibility.Visible;
	end

	if self.cur_state == 1 then
		bg.Background = CreateTextureBrush('chouka/chouka_bg_1.jpg', 'chouka');
	elseif self.cur_state == 2 then
		bg.Background = CreateTextureBrush('chouka/chouka_bg_2.jpg', 'chouka');
	elseif self.cur_state == 3 then
		bg.Background = CreateTextureBrush('chouka/chouka_bg_3.ccz', 'chouka')
	elseif self.cur_state == 4 then
		bg.Background = CreateTextureBrush('chouka/chouka_bg_4.ccz', 'chouka');
	end
	

	bg_list[self.cur_state] = bg_list[self.cur_state] + 1;
end
function ZhaomuPanel:bgRollingUpatd()
	if bg.Translate.x < -1134 then
		bg.Translate = Vector2(1134,0);
	end
	if bg1.Translate.x < -1134 then
		bg1.Translate = Vector2(1134,0);
	end
	bg.Translate = Vector2(bg.Translate.x-1,0);
	bg1.Translate = Vector2(bg1.Translate.x-1,0);
end
--点击1次事件
function ZhaomuPanel:on_one_pub()
	if self.cur_state == 1 then
		self:commonZhaomuOne();
	elseif self.cur_state == 2 then
		self:zhizunZhaomuOne();
	elseif self.cur_state == 3 then
		self:shenmiZhaomuOne();
	end
end

--点击10次事件
function ZhaomuPanel:on_ten_pub()
	if self.cur_state == 1 then
		self:commonZhaomuTen();
	elseif self.cur_state == 2 then
		self:zhizunZhaomuTen();
	elseif self.cur_state == 3 then
		self:shenmiZhaomuTen();
	end
end

--点击普通招募1次
function ZhaomuPanel:commonZhaomuOne()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 1);
	local str = LANG_ZHAOMU_TIP_7;
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

--点击普通招募10次
function ZhaomuPanel:commonZhaomuTen()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 2);
	local str = string.format(LANG_ZHAOMU_TIP_8, 10);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

--点击至尊招募1次
function ZhaomuPanel:zhizunZhaomuOne()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 3);
	local str = LANG_ZHAOMU_TIP_7;
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

--点击至尊招募10次
function ZhaomuPanel:zhizunZhaomuTen()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 4);
	local str = string.format(LANG_ZHAOMU_TIP_8, 10);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

--点击神秘招募1次
function ZhaomuPanel:shenmiZhaomuOne()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 5);
	local str = LANG_ZHAOMU_TIP_7;
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

--点击神秘招募10次
function ZhaomuPanel:shenmiZhaomuTen()
	if is_lock then
		return;
	end
	local okDelegate = Delegate.new(ZhaomuPanel, ZhaomuPanel.sendMessage, 6);
	local str = string.format(LANG_ZHAOMU_TIP_8, 10);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

function ZhaomuPanel:reqRefreshPubTime()
	local msg = {};
	Network:Send(NetworkCmdType.req_pub_time_t, msg);
end

function ZhaomuPanel:refreshTimeFromServer(msg)
	local pub = ActorManager.user_data.pub;

	pub.left_sec1 = msg.left_sec1;
	pub.left_sec2 = msg.left_sec2;
	pub.left_sec3 = msg.left_sec3;
	pub.flush3round = msg.flush3round;
	putong_time = pub.left_sec1 or 0; --putong_time在timer.lua
	zhizun_time = pub.left_sec2 or 0; --zhizun_time在timer.lua
	shenmi_time = pub.left_sec3 or 0; --shenmi_time在timer.lua
	self:updateTimeLabel();
	self:refreshStatus();
end

function ZhaomuPanel:refreshCallBackTime(time)
	local pub = ActorManager.user_data.pub;

	if self.pub_type == 1 then
		pub.left_sec1 = time;
		putong_time = time;
	elseif self.pub_type == 3 then
		pub.left_sec2 = time;
		zhizun_time = time;
	elseif self.pub_type == 5 then
		pub.left_sec3 = time;
		shenmi_time = time;
	end

	self:updateTimeLabel();
	self:refreshStatus();

end

function ZhaomuPanel:detailRoleInfo()
	local str = 30000+self.cur_role;
	TipsPanel:onShow(str);
end

--新手引导相关
function ZhaomuPanel:GetRetrunBtn()
	return btnReturn;
end	
function ZhaomuPanel:goToRechargeShow()
	mainDesktop:GetLogicChild('zhaomuTipPanel').Visibility = Visibility.Visible;
end
function ZhaomuPanel:tipcancelBtn()
	mainDesktop:GetLogicChild('zhaomuTipPanel').Visibility = Visibility.Hidden;
end
function ZhaomuPanel:tipokBtn()
	mainDesktop:GetLogicChild('zhaomuTipPanel').Visibility = Visibility.Hidden;
	RechargePanel:onShowRechargePanel();
end

function ZhaomuPanel:sendMessage(pub_type)
	is_lock = true;
	self.pub_type = pub_type;
	local msg = {};
	msg.flag = pub_type;
	Network:Send(NetworkCmdType.req_pub_flush_t, msg);
	ZhaomuResultPanel:HideCostPanel();
	if lockTimer ~= 0 then
		timerManager:DestroyTimer(lockTimer);
		lockTimer = 0;
	end
	lockTimer = timerManager:CreateTimer(2, 'ZhaomuPanel:unLock', 0);
end

function ZhaomuPanel:unLock()
	if lockTimer ~= 0 then
		timerManager:DestroyTimer(lockTimer);
		lockTimer = 0;
	end
	is_lock = false;
end

function ZhaomuPanel:ShowDetail()
	if self.cur_state == 4 then
		self.detailPanel.Background = CreateTextureBrush('chouka/chouka_detail_bg.ccz', 'chouka');
		for i=1, 4 do
			self.detailPanel:GetLogicChild('top'):GetLogicChild('brush'..i).Background = CreateTextureBrush('chouka/chouka_detail_top_brush'..i..'.ccz', 'chouka');
		end
		self.detailPanel:GetLogicChild('brush_word').Background = CreateTextureBrush('chouka/chouka_detail_brush_word.ccz', 'chouka');
		self.detailPanel:GetLogicChild('brush_word').Background = CreateTextureBrush('chouka/chouka_detail_brush_word.ccz', 'chouka');
		local role_panel = self.detailPanel:GetLogicChild('touchPanel'):GetLogicChild('panel');
		role_panel:RemoveAllChildren();
		local count = 0;
		for i=1, 999 do
			local role_id = resTableManager:GetValue(ResTable.pub_info, tostring(i+self.cur_state*100), 'role_id');
			if not role_id then
				break;
			end
			local detailRole = customUserControl.new(role_panel, 'pubDetailRoleTemplate');
			detailRole.initWithRoleId(role_id, self.cur_state);
			count = i;
		end
		role_panel.Size = Size(160*count+5*(count-1), 278);
	end
	self.detailPanelMain.Visibility = Visibility.Visible;
end

function ZhaomuPanel:HideDetail()
	if self.cur_state == 4 then
		self.detailPanel.Background = nil;
		DestroyBrushAndImage('chouka/chouka_detail_bg.ccz', 'chouka');
		for i=1, 4 do
			self.detailPanel:GetLogicChild('top'):GetLogicChild('brush'..i).Background = nil;
			DestroyBrushAndImage('chouka/detail_top_brush'..i..'.ccz', 'chouka');
		end
		self.detailPanel:GetLogicChild('brush_word').Background = nil;
		DestroyBrushAndImage('chouka/chouka_detail_brush_word.ccz', 'chouka');
	end
	self.detailPanelMain.Visibility = Visibility.Hidden;
end
