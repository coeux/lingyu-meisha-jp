--daily_sign.lua
--=====================================
--每日签到面板
DailySignPanel =
{
	firstEnterFlag = false;
	SignSucessRet = false;
};

--每月天数
local Days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
--闰年判断
local year = os.date("*t").year
if (year%4==0 and year%100 ~= 0) or (year%400==0) then
    Days[2] = 29;
end


local Vpos = { 0, 140, 278, 413, 550, 590, 590}
local Times = {LANG_SIGN_1, LANG_SIGN_2, LANG_SIGN_3, LANG_SIGN_4, LANG_SIGN_5, LANG_SIGN_6, LANG_SIGN_7, LANG_SIGN_8, LANG_SIGN_9};
--变量
local signBit;
local cost;
local cur_day;

--控件
local mainDesktop;
local dailysignPanel;
local closeBtn;
local weekBtn;


--签到面板
local signPanel;
local tspPanel;
local monthLable;

--补签面板
local remedyPanel;
local costLblae;
local cancelBtn;
local sureBtn;
local bg;
local rolebg;	
local titlebg;	
local titleImg;
local huabg1;  
local huabg2;  
--签到说明
local noticePanel;

function DailySignPanel:InitPanel(desktop)

	self.firstEnterFlag = false;
	self.SignSucessRet = false;
	--界面初始化
	mainDesktop = desktop;
	dailysignPanel = desktop:GetLogicChild('qiandaoPanel');
	dailysignPanel:IncRefCount();
	dailysignPanel.Visibility = Visibility.Hidden;


	--签到面板初始化
	signPanel 	= dailysignPanel:GetLogicChild('signInPanel');
	tspPanel 	= signPanel:GetLogicChild('tsp');
	monthLable	= signPanel:GetLogicChild('descLabel'):GetLogicChild('month');
	local noticeBtn = signPanel:GetLogicChild('notice');
	noticeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:onNotice');
	closeBtn = signPanel:GetLogicChild('close');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:onClose');

	--补签面板初始化
	remedyPanel = dailysignPanel:GetLogicChild('buQianPanel');
	remedyPanel.Visibility = Visibility.Hidden;
	cancelBtn	= remedyPanel:GetLogicChild('cancel');
	cancelBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:cancelRemedy');
	sureBtn		= remedyPanel:GetLogicChild('sure');
	sureBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:reqRemedyReward');

	--签到说明面板
	noticePanel = dailysignPanel:GetLogicChild('noticePanel');
	noticePanel.Visibility = Visibility.Hidden;
	local noticeSureBtn = noticePanel:GetLogicChild('sure');
	noticeSureBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:onNoticeClose');

	weekBtn = signPanel:GetLogicChild('weekBtn');
	weekBtn:SubscribeScriptedEvent('Button::ClickEvent', 'DailySignPanel:onShowWeeklyReward');
	bg = dailysignPanel:GetLogicChild('bg');
	bg.Visibility = Visibility.Hidden;

	rolebg		= signPanel:GetLogicChild('rolebg');
	titlebg		= signPanel:GetLogicChild('titlebg');
	titleImg	= signPanel:GetLogicChild('titleImg');
	huabg1  	= signPanel:GetLogicChild('huabg1');
	huabg2  	= signPanel:GetLogicChild('huabg2');
end

--销毁
function DailySignPanel:Destroy()
	dailysignPanel:DecRefCount();
	dailysignPanel = nil;
end


function DailySignPanel:onShowWeeklyReward()
	bg.Visibility = Visibility.Visible;
	WeekRewardPanel:onShow();
end

function DailySignPanel:onHideBG()
	if bg.Visibility == Visibility.Visible then
		bg.Visibility = Visibility.Hidden;
	end
end

--显示
function DailySignPanel:Show()

	signPanel.Background = CreateTextureBrush('qiandao/qiandao_bg_0.ccz','godsSenki');
	--rolebg.Image = GetPicture('qiandao/qiandao_bg_2.ccz');	
	--titlebg.Image = GetPicture('qiandao/qiandao_bg_1.ccz');	
	--titleImg.Image = GetPicture('qiandao/qiandao_title.ccz');
	--huabg1.Image = GetPicture('qiandao/qiandao_hua_1.ccz');  
	--huabg2.Image = GetPicture('qiandao/qiandao_hua_2.ccz');  
	local tc = os.date("*t", ActorManager.user_data.reward.cur_sec);
	local year, month, day = tc.year, tc.month, tc.day;
	local week = KimLarssonYearMonthDay(year, month, day);
	
	if not (week == 0 or week == 6) then	
        weekBtn.Visibility = Visibility.Hidden;
    else
    	weekBtn.Visibility = Visibility.Hidden;
    end
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		signPanel:SetScale(0.9, 0.9);
	end
	dailysignPanel.Visibility = Visibility.Visible;
	mainDesktop:DoModal(dailysignPanel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(dailysignPanel, StoryBoardType.ShowUI1);
end

--隐藏
function DailySignPanel:Hide()
	DestroyBrushAndImage('qiandao/qiandao_bg_0.ccz','godsSenki');
	mainDesktop:UndoModal();
	tspPanel:RemoveAllChildren();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(dailysignPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end


function DailySignPanel:onNotice()
	noticePanel.Visibility = Visibility.Visible;
end

function DailySignPanel:onNoticeClose()
	noticePanel.Visibility = Visibility.Hidden;
end

--关闭面板
function DailySignPanel:onClose()
	noticePanel.Visibility = Visibility.Hidden;
	MainUI:Pop();
	GodsSenki:BackToMainScene(SceneType.HomeUI)
	if self.firstEnterFlag then
		VipPanel:firstEnter();
	end
	self.firstEnterFlag = false;
end

--打开面板
function DailySignPanel:onShow()
	MainUI:Push(self);
	GodsSenki:LeaveMainScene()
end
function DailySignPanel:firstEnter()
	if UserGuidePanel:GetInGuilding() then
		return false;
	end
	self.firstEnterFlag = true;
	return true;
end
function DailySignPanel:firstEnterFromTomm()
	if self:firstEnter() then
		self:reqSignInfo();
	end
end
function DailySignPanel:reqSignInfo()

	monthLable.Text = tostring(cur_month);

	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initIconGrid(iconGrid);

	local logicnum = 1;
	for i = 1, Days[cur_month] do
		local logicnum = logicnum * 2;
		local index;
		local control;
		if i <= 9 then
			index = cur_month .. 0 .. i;
		else
			index = cur_month .. i;
		end
		if i < cur_day then
			local isSign = bit.band(signBit, bit.lshift(1,i));
			if isSign ~= 0 then
				control = DailySignPanel:createSignInfo(index, 1);
			else
				control = DailySignPanel:createSignInfo(index, 2);
			end
		elseif i == cur_day then
			local isSign = bit.band(signBit, bit.lshift(1,i))
			if isSign ~= 0 then
				control = DailySignPanel:createSignInfo(index, 1);
			else
				control = DailySignPanel:createSignInfo(index, 3);
				AvatarManager:LoadFile(GlobalData.EffectPath .. 'qiandao_output/');
				local armture = control:GetLogicChild(0):GetLogicChild('armature');
				local armture1 = control:GetLogicChild(0):GetLogicChild('armature1');
				armture:LoadArmature('front');
				armture:SetAnimation('front');
				armture1:LoadArmature('back');
				armture1:SetAnimation('back');
			end
		else
			control = DailySignPanel:createSignInfo(index, 4);
		end
		iconGrid:AddChild(control);
	end
	tspPanel:AddChild(iconGrid);
	DailySignPanel:onShow();
	if self.SignSucessRet then
		self:onClose();
		self.SignSucessRet = false;
	end
	tspPanel.VScrollPos =  Vpos[math.ceil(cur_day / 5)];
end

--获取每日签到信息
function DailySignPanel:sendSignDaily()
	Network:Send(NetworkCmdType.req_sign_daily, {});
end

--获取并解析签到信息
function DailySignPanel:getSignInfo(msg)
	signBit 	= msg.sign_daily;
	cost		= msg.cost;
	cur_day		= msg.cur_day;
	cur_month	= msg.cur_month;

	if bit.band(signBit, bit.lshift(1,cur_day)) == 0 then
		MenuPanel:UpdateSignTip(true)
	else
		MenuPanel:UpdateSignTip(false)
	end
	if self.firstEnterFlag then
		self:reqSignInfo();
	end
end

function DailySignPanel:updateForRedPoint()
    if bit.band(signBit, bit.lshift(1,cur_day)) == 0 then
		MenuPanel:UpdateSignTip(true)
	else
		MenuPanel:UpdateSignTip(false)
	end
end 
function DailySignPanel:isSign( )
	if bit.band(signBit, bit.lshift(1,cur_day)) == 0 then
		return true;
	end
	return false;
end
--创建签到每日信息
function DailySignPanel:createSignInfo(date, type)
	local control = uiSystem:CreateControl('qiandaoTemplate1');
	control.Tag = tonumber(date);
	control.Visibility = Visibility.Visible;
	local data = resTableManager:GetRowValue(ResTable.daily_sign, tostring(date));
	local bgPanel = control:GetLogicChild(0):GetLogicChild('select');
	local itemid = data['reward'][1];
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(itemid))
	local DayLable = control:GetLogicChild(0):GetLogicChild('num');
	DayLable.Text =  tostring(data['day']);
	local itemContrl = customUserControl.new(control:GetLogicChild(0):GetLogicChild('item'), 'itemTemplate');
	itemContrl.initWithInfo(itemid,  data['reward'][2], 80, false);
	local vipPanel = control:GetLogicChild(0):GetLogicChild('multiple');
	local vipLable = vipPanel:GetLogicChild('v');
	local timesLable = vipPanel:GetLogicChild('beishu');
	if data['vip_level'] > 0 and data['times'] > 1 then
		vipLable.Text = tostring( 'V' .. data['vip_level']);
		timesLable.Text = Times[data['times']];
		vipPanel.Visibility = Visibility.Visible;
	else
		vipPanel.Visibility = Visibility.Hidden;
	end

	local hookPanel = control:GetLogicChild(0):GetLogicChild('hook');
	hookPanel.Visibility = Visibility.Hidden;
	local shaderLbale = control:GetLogicChild(0):GetLogicChild('shader');
	local guoqiLabel = control:GetLogicChild(0):GetLogicChild('guoqi');
	guoqiLabel.Visibility = Visibility.Hidden;
	if type ~= 1 then
		if type == 2 then
			shaderLbale.Visibility = Visibility.Visible;
			guoqiLabel.Visibility = Visibility.Visible;
			if ActorManager.user_data.viplevel >= 5 then
				guoqiLabel.Font = uiSystem:FindFont('huakang_24_noboard_sp1');
				guoqiLabel.Text = LANG_SIGN_11;
				control:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:meredyClick');
			else
				guoqiLabel.Font = uiSystem:FindFont('huakang_24_noboard_sp');
				guoqiLabel.Text = LANG_SIGN_12;
			end
		elseif type == 3 then
			control:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:getSignReward');
			shaderLbale.Visibility = Visibility.Hidden;
			local bgPanel = control:GetLogicChild(0):GetLogicChild('select');
			bgPanel.Visibility = Visibility.Visible;
		end
	else
		shaderLbale.Visibility = Visibility.Visible;
		hookPanel.Visibility = Visibility.Visible;
		bgPanel.Visibility = Visibility.Visible;
	end
	return control;
end

--初始化icongrid
function DailySignPanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 140;
	iconGrid.CellWidth = 155;
	iconGrid.CellHSpace = -4
	iconGrid.CellVSpace = -3;
	iconGrid.StartPos = Vector2(0,0);
	iconGrid.Margin = Rect(1,1,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	if Days[cur_month] == 31 then
		iconGrid.Size = Size(760, 965);
	else
		iconGrid.Size = Size(760, 825);
	end
end

--补签点击
function DailySignPanel:meredyClick(Args)
	local args = UIControlEventArgs(Args);
	sureBtn.Tag = args.m_pControl.Tag;
	remedyPanel.Visibility = Visibility.Visible;
	local moneyLable = remedyPanel:GetLogicChild('money');
	moneyLable.Text = tostring(cost);
end

--取消补签
function DailySignPanel:cancelRemedy()
	remedyPanel.Visibility = Visibility.Hidden;
end

--请求补签
function DailySignPanel:reqRemedyReward(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.signid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_sign_remedy, msg);
end

--补签成功
function DailySignPanel:RemedySucess(msg)
	local moneyLable = remedyPanel:GetLogicChild('money');
	cost = msg.cost;
	remedyPanel.Visibility = Visibility.Hidden;
	local day = msg.id%100 - 1;
	local control = tspPanel:GetLogicChild(0):GetLogicChild(day);
	local guoqiLabel = control:GetLogicChild(0):GetLogicChild('guoqi');
	guoqiLabel.Visibility = Visibility.Hidden;
	local hookPanel = control:GetLogicChild(0):GetLogicChild('hook');
	hookPanel.Visibility = Visibility.Visible;
	local data = resTableManager:GetRowValue(ResTable.daily_sign, tostring(msg.id));
	local numReward = data['reward'][2];
	if data['vip_level'] >= ActorManager.user_data.viplevel and data['times'] ~= 0 then
		numReward = numReward * data['times'];
	end
	ToastMove:AddGoodsGetTip(data['reward'][1], numReward);
	control:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:meredyClick');
	DailySignPanel:sendSignDaily();
end

--领取每日签到奖励
function DailySignPanel:getSignReward(Args)
	SoundManager:PlayEffect("getsignreward");
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.id = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_sign_reward, msg);
end

--签到领取奖励成功
function DailySignPanel:SignSucess(msg)
	local day = msg.id%100 - 1;
	local control = tspPanel:GetLogicChild(0):GetLogicChild(day);
	local armture = control:GetLogicChild(0):GetLogicChild('armature');
	local armture1 = control:GetLogicChild(0):GetLogicChild('armature1');
	armture:Destroy();
	armture1:Destroy();
	MenuPanel:UpdateSignTip(false)
	local bgPanel = control:GetLogicChild(0):GetLogicChild('select');
	bgPanel.Visibility = Visibility.Hidden;
	local getLabel = control:GetLogicChild(0):GetLogicChild('hook');
	getLabel.Visibility = Visibility.Visible;
	local shaderLbale = control:GetLogicChild(0):GetLogicChild('shader');
	shaderLbale.Visibility = Visibility.Visible;
	control:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'DailySignPanel:getSignReward');
	local data = resTableManager:GetRowValue(ResTable.daily_sign, tostring(msg.id));
	local numReward = data['reward'][2];
	if data['vip_level'] <= ActorManager.user_data.viplevel and data['times'] ~= 0 then
		numReward = numReward * data['times'];
	end
	self.SignSucessRet = true;
	ToastMove:AddGoodsGetTip(data['reward'][1], numReward);
	DailySignPanel:sendSignDaily()
end
