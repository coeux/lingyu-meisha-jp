--soulPanel.lua
--========================================================================
--晶魂界面
--

SoulPanel = 
	{
	};

--控件
local mainDesktop;
local soulPanel;
local centerPanel;
local bg;
local num_gold;
local num_gem;
local num_scroll;
local img_soul;
local bru_ball;
local bru_qianli;
local bru_jinghun;
local num_jinghun;
local num_qianli;
local label_name;
local state_panel_list;
local panel_hunli;
local panel_qianli;
local btn_info;
local panel_info;
local infoBg;

local hunshiBtn;
local countPanel;
local countLabel;
local smelt_card_list;
local itemContrl;
local infoLeftImg; 
local infoRightImg;
local smelt_card_icon_list = {
	[1] = tostring(16014),
	[2] = tostring(16015),
	[3] = tostring(16016),
	[4] = tostring(16017),
}


--变量
local cur_state;		--0 未熔炼 1 成功 2失败 3最高
local req_type;			--0 从外面界面进入 1 hunt 2 rankup 3 get_reward
local former_soul;
local is_init_words;
local RareColor = 
{
	[1] = QuadColor(Color(255, 255, 255, 255)),
	[2] = QuadColor(Color(146, 227, 0, 255)),
	[3] = QuadColor(Color(15, 187, 255, 255)),
	[4] = QuadColor(Color(223, 107, 255, 255)),
	[5] = QuadColor(Color(253, 198, 49, 255)),
}
local LevelFont = 
{
	[1] = 'FZ_20_miaobian_R38G19B0',
	[2] = 'FZ_22_miaobian_R38G19B0',
	[3] = 'FZ_24_miaobian_R38G19B0',
	[4] = 'FZ_26_miaobian_R38G19B0',
	[5] = 'FZ_28_miaobian_R38G19B0',
}

--初始化面板
function SoulPanel:InitPanel(desktop)
	--变量初始化
	cur_state = 0;
	is_init_words = false;

	--控件初始化
	mainDesktop = desktop;
	soulPanel = desktop:GetLogicChild('soulPanel');
	soulPanel.ZOrder = PanelZOrder.soul;
	bg = soulPanel:GetLogicChild('bg');
	centerPanel = soulPanel:GetLogicChild('centerPanel');
	soulPanel.Visibility = Visibility.Hidden;
	soulPanel:IncRefCount();

	num_gold = centerPanel:GetLogicChild('currency'):GetLogicChild('moneyPanel'):GetLogicChild('num');
	num_gem = centerPanel:GetLogicChild('currency'):GetLogicChild('gemPanel'):GetLogicChild('num');
	num_scroll = centerPanel:GetLogicChild('currency'):GetLogicChild('scrollPanel'):GetLogicChild('num');
	countPanel = centerPanel:GetLogicChild('bottom'):GetLogicChild('smeltCountPanel');
	countLabel = countPanel:GetLogicChild('countLabel');

	smelt_card_list = {};
	smelt_card_list[1] = centerPanel:GetLogicChild('currency'):GetLogicChild('lowPanel'):GetLogicChild('num');			-- 低级卡 1级晶魂
	smelt_card_list[2] = centerPanel:GetLogicChild('currency'):GetLogicChild('middlePanel'):GetLogicChild('num');		-- 中级卡 2级晶魂
	smelt_card_list[3] = centerPanel:GetLogicChild('currency'):GetLogicChild('highPanel'):GetLogicChild('num');			-- 高级卡 3级晶魂
	smelt_card_list[4] = centerPanel:GetLogicChild('currency'):GetLogicChild('ultimatePanel'):GetLogicChild('num');		-- 终级卡 4级晶魂

	-- centerPanel:GetLogicChild('currency'):GetLogicChild('lowPanel'):GetLogicChild('low').Image = GetPicture('icon/' .. smelt_card_icon_list[1] .. '.ccz')
	-- centerPanel:GetLogicChild('currency'):GetLogicChild('middlePanel'):GetLogicChild('middle').Image = GetPicture('icon/' .. smelt_card_icon_list[2] .. '.ccz')
	-- centerPanel:GetLogicChild('currency'):GetLogicChild('highPanel'):GetLogicChild('high').Image = GetPicture('icon/' .. smelt_card_icon_list[3] .. '.ccz')
	-- centerPanel:GetLogicChild('currency'):GetLogicChild('ultimatePanel'):GetLogicChild('ultimate').Image = GetPicture('icon/' .. smelt_card_icon_list[4] .. '.ccz')

	itemContrl = {}
	itemContrl[1] = customUserControl.new(centerPanel:GetLogicChild('currency'):GetLogicChild('lowPanel'):GetLogicChild('low'), 'itemTemplate');
	itemContrl[1].initWithInfo(tostring(16014), -1, 40, true);
	itemContrl[2] = customUserControl.new(centerPanel:GetLogicChild('currency'):GetLogicChild('middlePanel'):GetLogicChild('middle'), 'itemTemplate');
	itemContrl[2].initWithInfo(tostring(16015), -1, 40, true);
	itemContrl[3] = customUserControl.new(centerPanel:GetLogicChild('currency'):GetLogicChild('highPanel'):GetLogicChild('high'), 'itemTemplate');
	itemContrl[3].initWithInfo(tostring(16016), -1, 40, true);
	itemContrl[4] = customUserControl.new(centerPanel:GetLogicChild('currency'):GetLogicChild('ultimatePanel'):GetLogicChild('ultimate'), 'itemTemplate');
	itemContrl[4].initWithInfo(tostring(16017), -1, 40, true);
	-- for i=1,4 do
	-- 	itemContrl[i].initWithInfo((16013 + i), -1, 40, true);
	-- 	print("yyz	~~~~~~")
	-- end

	panel_hunli = centerPanel:GetLogicChild('panel_hunli');
	panel_qianli = centerPanel:GetLogicChild('panel_qianli');
	img_soul = centerPanel:GetLogicChild('soul');
	bru_ball = centerPanel:GetLogicChild('ball');
	bru_qianli = panel_qianli:GetLogicChild('img_qianli');
	bru_jinghun = panel_hunli:GetLogicChild('img_jinghun');
	label_name = centerPanel:GetLogicChild('soul_name');
	num_jinghun = panel_hunli:GetLogicChild('num_jinghun');
	num_qianli = panel_qianli:GetLogicChild('num_qianli');

	state_panel_list = {};
	state_panel_list[0] = centerPanel:GetLogicChild('bottom'):GetLogicChild('state_panel_0');
	state_panel_list[1] = centerPanel:GetLogicChild('bottom'):GetLogicChild('state_panel_1');
	state_panel_list[2] = centerPanel:GetLogicChild('bottom'):GetLogicChild('state_panel_2');
	state_panel_list[3] = centerPanel:GetLogicChild('bottom'):GetLogicChild('state_panel_3');
	state_panel_list.hide_all = function()
		for i=0,3 do
			state_panel_list[i].Visibility = Visibility.Hidden;
		end
	end

	state_panel_list[0]:GetLogicChild('btn_hunt'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:hunt');
	state_panel_list[1]:GetLogicChild('btn_reward'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:get_reward');
	state_panel_list[1]:GetLogicChild('btn_rankup'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:rankup');
	state_panel_list[2]:GetLogicChild('btn_reward'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:get_reward');
	state_panel_list[3]:GetLogicChild('btn_reward'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:get_reward');

	centerPanel:GetLogicChild('returnBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:onClose');

	btn_info = centerPanel:GetLogicChild('btnInfo');
	btn_info:SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:showInfo')
	panel_info = centerPanel:GetLogicChild('info');
	panel_info:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SoulPanel:hideInfo');
	panel_info.Visibility = Visibility.Hidden;
	infoBg = centerPanel:GetLogicChild('explainBG')
	infoBg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SoulPanel:hideInfo');
	infoBg.Visibility = Visibility.Hidden
	hunshiBtn = centerPanel:GetLogicChild('hunshiBtn')
	hunshiBtn:SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:hunshiOnShow');
end

--销毁
function SoulPanel:Destroy()
	soulPanel:IncRefCount();
	soulPanel = nil;
end

--请求显示
function SoulPanel:onShow()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.crystalSoul then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_crystal_soul);
		return;
	end
	self:bind();
	req_type = 0;
	--发出请求
	local msg = {};
	Network:Send(NetworkCmdType.req_get_soul_info, msg);

	--屏蔽编年史干扰
	if ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	end
end

--显示
function SoulPanel:Show(msg)
	self:init_words();
	uiSystem:UpdateDataBind();
	bg.Background = CreateTextureBrush('background/soul_bg.jpg', 'background');
	bru_ball.Background = CreateTextureBrush('item/ball.ccz', 'item');
	local soulData;
	if msg.state ~= 0 then
		soulData = resTableManager:GetRowValue(ResTable.soul, tostring(msg.soul_id));
	end

	if req_type == 0 then
	elseif req_type == 1 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_SOUL_4);
	elseif req_type == 2 then
		if msg.state == 1 then
			if former_soul == msg.soul_id then
				Toast:MakeToast(Toast.TimeLength_Long, LANG_SOUL_3);
			else
				Toast:MakeToast(Toast.TimeLength_Long, LANG_SOUL_4);
			end
		elseif msg.state == 2 then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_SOUL_5);
		end
	end
	former_soul = msg.soul_id;

	state_panel_list.hide_all();
    local doubleRate = 1;
        if  ActivityRechargePanel:QuiryDoubleReward("Soul") then
            doubleRate = 1.5;
        end
	if msg.state == 0 then		-- 不在熔炼状态中
		img_soul.Visibility = Visibility.Hidden;
		panel_hunli.Visibility = Visibility.Hidden;
		panel_qianli.Visibility = Visibility.Hidden;
		label_name.Visibility = Visibility.Hidden;
		countPanel.Visibility = Visibility.Hidden;		-- 熔炼次数label
		state_panel_list[0].Visibility = Visibility.Visible;
	elseif msg.state == 1 then	-- 熔炼状态
		img_soul.Image = GetPicture('item/soul_' .. msg.level ..msg.rare.. '.ccz');
		img_soul.Visibility = Visibility.Visible;
		panel_hunli.Visibility = Visibility.Visible;
		panel_qianli.Visibility = Visibility.Visible;
		countPanel.Visibility = Visibility.Visible;		-- 熔炼次数label
          
		num_jinghun.Text = tostring(math.floor(soulData['suc_reward'][1] *doubleRate));
		num_qianli.Text = tostring(math.floor(soulData['suc_reward'][2] *doubleRate));
           
		label_name.Visibility = Visibility.Visible;
		label_name.Text = tostring(soulData['name']);
		if msg.level == 5 then
			state_panel_list[3].Visibility = Visibility.Visible;
		else
			state_panel_list[1].Visibility = Visibility.Visible;
			self:updateConsume(msg.gem_need, msg.level, msg.time + 1);
		end
	elseif msg.state == 2 then	-- 熔炼失败
		img_soul.Image = GetPicture('item/soul_' .. msg.level..msg.rare.. '.ccz');
		img_soul.Visibility = Visibility.Visible;
		panel_hunli.Visibility = Visibility.Visible;
		panel_qianli.Visibility = Visibility.Visible;
		num_jinghun.Text = tostring(math.floor(soulData['fail_reward'][1] *doubleRate));
		num_qianli.Text = tostring(math.floor(soulData['fail_reward'][2] *doubleRate));
		label_name.Visibility = Visibility.Visible;
		label_name.Text = tostring(soulData['name']);
		state_panel_list[2].Visibility = Visibility.Visible;
	end

	if msg.rare and RareColor[msg.rare] then
		label_name.TextColor = RareColor[msg.rare];
	end
	if msg.level and LevelFont[msg.level] then
		label_name:SetFont(LevelFont[msg.level]);
	end

	soulPanel.Visibility = Visibility.Visible;
end

function SoulPanel:onClose()
	self:unBind();
	self:Hide();
end

function SoulPanel:Hide()
	DestroyBrushAndImage('background/soul_bg.jpg', 'background');
	DestroyBrushAndImage('item/ball.ccz', 'item');
	soulPanel.Visibility = Visibility.Hidden;
end

--数据绑定
function SoulPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', num_gem, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', num_gold, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[16004], 'num', num_scroll, 'Text');

	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[16014], 'num', smelt_card_list[1], 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[16015], 'num', smelt_card_list[2], 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[16016], 'num', smelt_card_list[3], 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, Package.goodsList[16017], 'num', smelt_card_list[4], 'Text');
end

--解除绑定
function SoulPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'rmb', num_gem, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'money', num_gold, 'Text');
	uiSystem:UnBind(Package.goodsList[16004], 'num', num_scroll, 'Text');

	uiSystem:UnBind(Package.goodsList[16014], 'num', smelt_card_list[1], 'Text');
	uiSystem:UnBind(Package.goodsList[16015], 'num', smelt_card_list[2], 'Text');
	uiSystem:UnBind(Package.goodsList[16016], 'num', smelt_card_list[3], 'Text');
	uiSystem:UnBind(Package.goodsList[16017], 'num', smelt_card_list[4], 'Text');
end

--熔炼
function SoulPanel:hunt()
	if Package.goodsList[16004].num < 1 or ActorManager.user_data.money < 30000 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_SOUL_1);
		return;
	end
	req_type = 1;
	local msg = {};
	Network:Send(NetworkCmdType.req_hunt_soul, msg);
end

--继续熔炼
function SoulPanel:rankup()
	req_type = 2;
	local msg = {};
	Network:Send(NetworkCmdType.req_rankup_soul, msg);
end

--获取奖励
function SoulPanel:get_reward()
	req_type = 3;
	local msg = {};
	Network:Send(NetworkCmdType.req_get_soul_reward, msg);
end

function SoulPanel:init_words()
	if is_init_words then
		return;
	end
	is_init_words = true;
	
	state_panel_list[1]:GetLogicChild('btn_reward').Text = LANG_SOUL_6;
	state_panel_list[2]:GetLogicChild('btn_reward').Text = LANG_SOUL_8;
	state_panel_list[1]:GetLogicChild('rankup_words').Text = LANG_SOUL_7;
	panel_info:GetLogicChild('touchPanel'):GetLogicChild('panel'):GetLogicChild('label').Text = LANG_SOUL_10;
	infoLeftImg  = panel_info:GetLogicChild('touchPanel'):GetLogicChild('infoLeftImg');
	infoRightImg = panel_info:GetLogicChild('touchPanel'):GetLogicChild('infoRightImg');
	infoLeftImg.Image = GetPicture('explain/explain_soul_1.ccz');
	infoRightImg.Image = GetPicture('explain/explain_soul_0.ccz');
end

function SoulPanel:updateConsume(gem_num, jh_Level, times)
	countLabel.Text = tostring(times);
	if tonumber(smelt_card_list[jh_Level].Text) < 1 then 
		state_panel_list[1]:GetLogicChild('gem_consume').Text = string.format(LANG_SOUL_9, gem_num or 50);
		state_panel_list[1]:GetLogicChild('gem').Image = GetPicture('recharge/GuildWelfare_gem.ccz');
	else
		state_panel_list[1]:GetLogicChild('gem_consume').Text = string.format(LANG_SOUL_9, 1);
		local name = tostring(resTableManager:GetValue(ResTable.item, smelt_card_icon_list[jh_Level], 'icon'))
		state_panel_list[1]:GetLogicChild('gem').Image = GetPicture('icon/' .. name .. '.ccz');
	end
end

function SoulPanel:showInfo()
	panel_info.Visibility = Visibility.Visible;
	infoBg.Visibility = Visibility.Visible
end

function SoulPanel:hideInfo()
	panel_info.Visibility = Visibility.Hidden;
	infoBg.Visibility = Visibility.Hidden
end

function SoulPanel:isShow()
	return soulPanel.Visibility == Visibility.Visible;
end

function SoulPanel:hunshiOnShow()
	HunShiPanel:onShow();
end