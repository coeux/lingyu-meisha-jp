--vipPanel.lua
--==============================================================================================
--vip特权面板

VipPanel =
	{
		firstEnterFlag = false;
	};
	
VipExpInfos = 
{
	['1'] = 10,
	['2'] = 20,
	['3'] = 40,
	['4'] = 60,
	['5'] = 100,
}
--变量
local font;
local fontVip;
local color;
local currentListTag = 0;    --当前ListView的位置

--控件
local mainDesktop;
local panel;


local labelVipLevel;
local rtbVipInfo;			--富文本
local vipExp;				--经验条
local listView;

local info_tip;

local explainPanel;
local explainLabel;

--初始化
function VipPanel:InitPanel(desktop)
	
	self.firstEnterFlag = false;

	--变量初始化
	font = uiSystem:FindFont('huakang_18_blue');
	fontVip = uiSystem:FindFont('vipFont');
	color = QuadColor(Color(255, 255, 255, 255));
	color1 = QuadColor(Color(255, 255, 255, 255));


	--界面初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('vipPanel'));
	panel:IncRefCount();
	
	labelVipLevel = panel:GetLogicChild('vipLevel');
	rtbVipInfo = panel:GetLogicChild('richTextBox');
	vipExp = panel:GetLogicChild('vipexp');
	listView = panel:GetLogicChild('listView');

	explainPanel = 	panel:GetLogicChild('illPanel');
	explainLabel = 	explainPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	explainBtn 	= 	panel:GetLogicChild('explainBtn');
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'VipPanel:ExplainShow');
	explainPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'VipPanel:ExplainHide');

	info_tip = panel:GetLogicChild('info_tip');

	self.tipPanel = panel:GetLogicChild('tipPanel');
	self.tipBrush = self.tipPanel:GetLogicChild('tipBrush');
	self.tipBrush.Background = CreateTextureBrush('vip/vip_tip_bg.ccz','godsSenki');
	self.tipBrush:SubscribeScriptedEvent('UIControl::MouseClickEvent','VipPanel:tipBrushClick');
	self.titleLabel = panel:GetLogicChild('titleLabel');
	self.titleLabel.Background = CreateTextureBrush('vip/vip_title_bg.ccz','godsSenki');
	self.tipPanel.Visibility = Visibility.Hidden;

	self:ShowVipListView();
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function VipPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
function VipPanel:tipBrushClick()
	local expNum = ((ActorManager.user_data.extra_data.vip_days + 1 >= 5) and  5) or (ActorManager.user_data.extra_data.vip_days + 1);
	--local msg = LANG_Vip_tip_1 ..  (ActorManager.user_data.extra_data.vip_days + 1) ..  LANG_Vip_tip_2 .. VipExpInfos[tostring(expNum)] .. LANG_Vip_tip_3;
	local contents = {};
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_Vip_tip_1..(ActorManager.user_data.extra_data.vip_days + 1) .. LANG_Vip_tip_2});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_Vip_tip_3 .. VipExpInfos[tostring(expNum)] .. LANG_Vip_tip_4});
	local okDelegate = Delegate.new(VipPanel, VipPanel.reqVipExp);
	MessageBox:ShowDialog(MessageBoxType.Ok, contents, okDelegate);
	self.tipPanel.Visibility = Visibility.Hidden;
	self.titleLabel.Visibility = Visibility.Visible;
end
--显示
function VipPanel:Show()
	if ActorManager.user_data.extra_data.vip_stamp < ActorManager.user_data.extra_data.cur_0_stamp then
		self.tipPanel.Visibility = Visibility.Visible;
		self.titleLabel.Visibility = Visibility.Hidden
	else
		self.titleLabel.Visibility = Visibility.Visible;
		self.tipPanel.Visibility = Visibility.Hidden;
	end
	explainLabel.Text = LANG_VipExplain_ILL;
	self:RefreshVipExp();
	self:RefreshVipRewardButton();
	self:updatePanel(currentListTag);
	mainDesktop:DoModal(panel);

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI3);
	else
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	end
end

--隐藏
function VipPanel:Hide()
	mainDesktop:UndoModal();
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI消失时的效果
		StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI3, 'StoryBoard::OnPopUI');	
	else
		--增加UI消失时的效果
		StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end
end


--显示说明
function VipPanel:ExplainShow()
	explainPanel.Visibility = Visibility.Visible;
end

--隐藏说明
function VipPanel:ExplainHide()
	explainPanel.Visibility = Visibility.Hidden;
end

--============================================================================================
--显示vip特权

function VipPanel:ShowVipListView()

	for index = 1, Configuration.MaxVipLevel do
--		local t = uiSystem:CreateControl('vipItemTemplate');
		local t = uiSystem:CreateControl('vipItem');
		local vipItem = t:GetLogicChild('vipItem');
		local vipLevel = vipItem:GetLogicChild('viplevel');
		local rtbInfo = vipItem:GetLogicChild('info');
		local itemCell1 = vipItem:GetLogicChild('itemCell1');
		local name1 = vipItem:GetLogicChild('name1');
		local itemCell2 = vipItem:GetLogicChild('itemCell2');
		local name2 = vipItem:GetLogicChild('name2');
		local title2 = vipItem:GetLogicChild('title2');
		local get = vipItem:GetLogicChild('get');
		local panel1 = vipItem:GetLogicChild('panel1');
		local panel2 = vipItem:GetLogicChild('panel2');
		if index >= 13 then
			panel1.Background = Converter.String2Brush("godsSenki.vip_info3"); 
			panel2.Background = Converter.String2Brush("godsSenki.vip_info3");
			vipItem:GetLogicChild('Label1').Background = Converter.String2Brush("godsSenki.vip_tip2"); 
			vipLevel:SetFont('vipws');
			panel1:GetLogicChild('title_tip').Image = GetPicture('vip/vip_tip4.ccz');
			panel2:GetLogicChild('title_tip').Image = GetPicture('vip/vip_tip4.ccz');
			panel1:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.vip_info2"); 
			panel2:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.vip_info2"); 
			color1 = QuadColor(Color(255, 255, 255, 255));
		elseif index >= 7 then
			panel1.Background = Converter.String2Brush("godsSenki.vip_info6"); 
			panel2.Background = Converter.String2Brush("godsSenki.vip_info6"); 
			vipItem:GetLogicChild('Label1').Background = Converter.String2Brush("godsSenki.vip_tip2"); 
			vipLevel:SetFont('vipws');
			panel1:GetLogicChild('title_tip').Image = GetPicture('vip/vip_tip8.ccz');
			panel2:GetLogicChild('title_tip').Image = GetPicture('vip/vip_tip8.ccz');
			panel1:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.vip_info7"); 
			panel2:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.vip_info7"); 
			color1 = QuadColor(Color(255, 255, 255, 255));
		else
			panel1.Background = Converter.String2Brush("godsSenki.skillup_diban1"); 
			panel2.Background = Converter.String2Brush("godsSenki.skillup_diban1"); 
			vipItem:GetLogicChild('Label1').Background = Converter.String2Brush("godsSenki.vip_tip1"); 
			vipLevel:SetFont('vipJP');
			panel1:GetLogicChild('title_tip').Image = GetPicture('getrole/getrole_title.png');
			panel2:GetLogicChild('title_tip').Image = GetPicture('getrole/getrole_title.png');
			panel1:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.email_banzi");
			panel2:GetLogicChild('contentBg').Background = Converter.String2Brush("godsSenki.email_banzi");  
			color1 = QuadColor(Color(9, 47, 145, 255));
		end
		
		get.Tag = index;
		get:SubscribeScriptedEvent('Button::ClickEvent', 'VipPanel:onOpenVip');
		
		vipLevel.Text = tostring(index);
		title2.TextColor = color1;
		--title2.Text = 'VIP' .. index .. LANG_vipPanel_1;
		local info = resTableManager:GetRowValue(ResTable.vip, tostring(index));
		
		local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(info['item1']));
		local item1 = customUserControl.new(itemCell1, 'itemTemplate');
		item1.initWithInfo(info['item1'],-1,66,true);
		name1.Text = info['pro1'] .. reward1['name'];
		name1.TextColor = color1;
		
		local reward2 = resTableManager:GetRowValue(ResTable.item, tostring(info['item2']));
		local item2 = customUserControl.new(itemCell2, 'itemTemplate');
		item2.initWithInfo(info['item2'],info['pro2'],66,true);
		name2.Text = reward2['name'];
		name2.TextColor = color1;

		local i = 1;
		while true do
			if (nil ~= info['privilege'..tostring(i)]) and (0 < string.len(info['privilege'..tostring(i)])) then
				local element = TextElement( uiSystem:CreateControl('BrushElement') );
				element.TextColor = Configuration.BlackColor;
				element.Size = Size(19, 19); 
				element.Background = Converter.String2Brush("godsSenki.recharge_point");
				element.Vertical = ControlLayout.V_CENTER;
				rtbInfo:AddUIControl(element);
				rtbInfo:AppendText(' ' .. info['privilege'..tostring(i)], color1, font);
				i = i + 1;
			else
				break;
			end
		end
		
		listView:AddChild(t);
	end

end

--测试是否有vip奖励可以领取
function VipPanel:IsHaveVipReward()
	for i = 1, Configuration.MaxVipLevel do
		if ActorManager.user_data.reward.vip_reward[i] == 1 then
			--可领取
			return true;
		end
	end
	
	return false;
end

--刷新领取按钮状态
function VipPanel:RefreshVipRewardButton()
	
	local firstPos = -1;		--第一个可以领取的位置
	local endPos = -1;		--最后一个已领取的位置
	for i = 1, Configuration.MaxVipLevel do
		local panel = listView:GetLogicChild(i-1):GetLogicChild(0);
		local get = panel:GetLogicChild('get');
		if ActorManager.user_data.reward.vip_reward[i] == 0 then
			--不能领
			get.Enable = false;
			get.Text = LANG_vipPanel_2;
		elseif ActorManager.user_data.reward.vip_reward[i] == -1 then
			--已领取
			get.Enable = false;
			get.Text = LANG_vipPanel_3;
			
			endPos = i;		--记录已领取位置
		elseif ActorManager.user_data.reward.vip_reward[i] == 1 then
			--可领取
			get.Enable = true;
			get.Text = LANG_vipPanel_4;
			
			if firstPos == -1 then
				firstPos = i;	--记录第一个可领取的位置
			end
		end
	end

	local pos = 0;
	if firstPos ~= -1 then
		pos = firstPos - 1;
	elseif endPos ~= -1 then
		pos = endPos;
	else
		pos = math.max(0, ActorManager.user_data.viplevel - 1);
	end
	currentListTag = ActorManager.user_data.viplevel - 1
	if currentListTag < 0 then
		currentListTag = 0;
	end
    --currentListTag = (ActorManager.user_data.viplevel  - 1)>0 and ActorManager.user_data.viplevel  - 1   or ActorManager.user_data.viplevel;
	listView:SetActivePageIndexImmediate(currentListTag);
end

function VipPanel:setActivePageIndex( index )
	index = index - 1;
	if index <= 0 then
		index = 0;
	end
	listView:SetActivePageIndexImmediate(index)
end

function VipPanel:refreshVipExpTurn()
    local curTag = currentListTag;                                                 --当前的panel所位于的地址
    local curVipLevel = ActorManager.user_data.viplevel;                                  --当前的Vip等级
    local x_chazhi
    x_chazhi = curTag - curVipLevel
    if x_chazhi < 1 then 
       self:RefreshVipExp(1);
    else
        self:RefreshVipExp(x_chazhi + 1);
    end  
end 

--请求vip经验
function VipPanel:reqVipExp()

	Network:Send(NetworkCmdType.req_vip_exp_t, msg);
end

--请求vip经验回调
function VipPanel:reqVipExpEnd(msg)
	ActorManager.user_data.extra_data.vip_stamp =  msg.vip_stamp;
	ActorManager.user_data.extra_data.vip_days =  msg.vip_days;
end


--刷新vip经验
function VipPanel:RefreshVipExp(d_level)
    d_level = d_level or 1
	local textfont = uiSystem:FindFont('huakang_18_noborder');
	if currentListTag >= 12 then
		color = QuadColor(Color(255, 255, 255, 255));
	elseif currentListTag >= 6 then
		color = QuadColor(Color(255, 255, 255, 255));
	else
		color = QuadColor(Color(9, 47, 145, 255));
	end
	
	labelVipLevel.TextColor = color;
	info_tip.TextColor = color;

	labelVipLevel.Text = tostring(ActorManager.user_data.viplevel);
	local curLevelExp = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'pay');
	local tiliValue = vipExp:GetLogicChild(0):GetLogicChild(0);
	local tiliMaxValue = vipExp:GetLogicChild(0):GetLogicChild(1);

	local nextLv = panel:GetLogicChild('nextLv');
	if (ActorManager.user_data.viplevel >= Configuration.MaxVipLevel) then
		rtbVipInfo:Clear();
		rtbVipInfo:AddText("您已达到最高vip级别" , color, textfont);
		vipExp.CurValue = vipExp.MaxValue;
		vipExp.ShowText = false;
		vipExp:GetLogicChild(0).Visibility = Visibility.Hidden;
		nextLv.Text = tostring(ActorManager.user_data.viplevel);
		return;
	end
	
	local nextLevelExp = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel + d_level), 'pay');	

	rtbVipInfo:Clear();
	rtbVipInfo:AddText(LANG_vipPanel_5 , color, textfont);
	rtbVipInfo:AppendText( tostring(nextLevelExp - ActorManager.user_data.vipexp), color, textfont);
	--rtbVipInfo:AppendText( LANG_vipPanel_7, color, textfont);
	
	local brush = uiSystem:CreateControl('BrushElement');
	brush.Size = Size(43, 22);
	brush.Background = uiSystem:FindResource('vip_tubiao2', 'godsSenki');
	rtbVipInfo:AppendUIControl(brush);
	rtbVipInfo:AppendText(tostring(ActorManager.user_data.viplevel + d_level), Configuration.WhiteColor, fontVip);
	
	vipExp.MaxValue = nextLevelExp - curLevelExp;
	vipExp.CurValue = ActorManager.user_data.vipexp - curLevelExp;

	tiliMaxValue.Text = tostring('/' .. (nextLevelExp - curLevelExp));
	tiliValue.Text = tostring(ActorManager.user_data.vipexp - curLevelExp);

	nextLv.Text = tostring(ActorManager.user_data.viplevel + d_level);
end	

 


--刷新累计充值标志
function VipPanel:RefreshVipFlag( index )
	ActorManager.user_data.reward.vip_reward[index] = 1;			--可领取
end

--刷新达到下一个vip等级需充值多少水晶的界面
function VipPanel:RefreshNeedRmbToNextVipLevelPanel(stackPanel)
	local curVipLevel = stackPanel:GetLogicChild('curVipLevel');
	local needRmb = stackPanel:GetLogicChild('rmb');
	local nextVipLevel = stackPanel:GetLogicChild('nextVipLevel');
	local nextLv = panel:GetLogicChild('nextLv');
	
	local text1 = stackPanel:GetLogicChild('text1');
	local text2 = stackPanel:GetLogicChild('text2');
	local icon1 = stackPanel:GetLogicChild('icon1');
	local maxVipInfo = stackPanel:GetLogicChild('maxVipInfo');
	
	curVipLevel.Text = 'VIP ' .. ActorManager.user_data.viplevel;
	local curLevelExp = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'pay');
	if (ActorManager.user_data.viplevel >= Configuration.MaxVipLevel) then
		maxVipInfo.Visibility = Visibility.Visible;
		text1.Visibility = Visibility.Hidden;
		text2.Visibility = Visibility.Hidden;
		icon1.Visibility = Visibility.Hidden;

		needRmb.Visibility = Visibility.Hidden;
		nextVipLevel.Visibility = Visibility.Hidden;
		nextLv.Text = tostring(ActorManager.user_data.viplevel);
	else
		local nextLevelExp = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel + 1), 'pay');
		needRmb.Text = tostring(nextLevelExp - ActorManager.user_data.vipexp);
		nextVipLevel.Text = 'VIP ' .. (ActorManager.user_data.viplevel + 1);
		nextLv.Text = tostring(ActorManager.user_data.viplevel + 1);
		
		maxVipInfo.Visibility = Visibility.Hidden;
		text1.Visibility = Visibility.Visible;
		text2.Visibility = Visibility.Visible;
		icon1.Visibility = Visibility.Visible;

		needRmb.Visibility = Visibility.Visible;
		nextVipLevel.Visibility = Visibility.Visible;
	end	
end

--==============================================================================================
--事件

--关闭
function VipPanel:onClose()
	MainUI:Pop();
	if self.firstEnterFlag then
		AnnouncementPanel:FirstEnter();
	end
	self.firstEnterFlag = false;
end
function VipPanel:firstEnter()
	self.firstEnterFlag = true;
	self:onShowVipPanel();
end
--打开vip特权界面
function VipPanel:onShowVipPanel()
	if MainUI:IsHaveMenu(VipPanel) then
		--已经有vip特权窗口打开了
		local loop = true;
		while loop do
			local topMenu = MainUI:GetTopMenu();
			MainUI:Pop();
			
			if topMenu == VipPanel then
				loop = false;
			end
		end
	end
	
	MainUI:Push(self);
end

--vip领取
function VipPanel:onOpenVip( Args )
	local msg = {};
	msg.viplevel = Args.m_pControl.Tag;

	Network:Send(NetworkCmdType.req_given_vip_reward_t, msg);
end

--vip领取响应
function VipPanel:HandleGivenVip( msg )
--[[
	--如果领取的v18奖励,显示特殊效果
	if msg.viplevel == 18 then
		ActorManager.hero:AttachVipToAvatar();
		ActorManager.hero:UpdateVipHeight(90)
	end
--]]
	ActorManager.user_data.reward.vip_reward[msg.viplevel] = -1;
	
	local panel = listView:GetLogicChild(msg.viplevel - 1):GetLogicChild(0);
	local get = panel:GetLogicChild('get');
	
	--已领取
	get.Enable = false;
	get.Text = LANG_vipPanel_8;
	
	self:onVipRewardDisplay(msg.viplevel);
	
	--刷新头像旁边vip领取特效
	RolePortraitPanel:RefreshVipReward();

end

--显示领取提示
function VipPanel:onVipRewardDisplay(index)
	if (index <= Configuration.MaxVipLevel) then
		local info = resTableManager:GetRowValue(ResTable.vip, tostring(index));
		ToastMove:AddGoodsGetTip(info['item1'], info['pro1']);
		ToastMove:AddGoodsGetTip(info['item2'], info['pro2']);
	end
end

--左翻
function VipPanel:TurnLeft()
	listView:TurnPageForward();
end

--右翻
function VipPanel:TurnRight()
	listView:TurnPageBack();
end

function VipPanel:ChangeShowPanel()
    currentListTag = listView.ActivePageIndex

	VipPanel:updatePanel(currentListTag)
    self:refreshVipExpTurn()
end 

function VipPanel:updatePanel(index_)

	if index_ >= 12 then
		panel:GetLogicChild('bg').Background = CreateTextureBrush('vip/vip_background1.ccz', 'vip');
		panel:GetLogicChild('tip'):GetLogicChild('tip1').Background = Converter.String2Brush("godsSenki.vip_tip6"); 
		panel:GetLogicChild('tip'):GetLogicChild('tip2').Background = Converter.String2Brush("godsSenki.vip_tip6"); 
	elseif index_ >= 6 then
		panel:GetLogicChild('bg').Background = CreateTextureBrush('vip/vip_background3.ccz', 'vip');
		panel:GetLogicChild('tip'):GetLogicChild('tip1').Background = Converter.String2Brush("godsSenki.vip_tip9"); 
		panel:GetLogicChild('tip'):GetLogicChild('tip2').Background = Converter.String2Brush("godsSenki.vip_tip9"); 
	else
		panel:GetLogicChild('bg').Background = Converter.String2Brush("godsSenki.jineng_diban2"); 
		panel:GetLogicChild('tip'):GetLogicChild('tip1').Background = Converter.String2Brush("godsSenki.vip_tip7"); 
		panel:GetLogicChild('tip'):GetLogicChild('tip2').Background = Converter.String2Brush("godsSenki.vip_tip7"); 
	end

	local picindex = 6;
	if math.floor((index_ + 1)/2) < picindex then
		picindex = math.floor((index_ + 1)/2)
	end

	panel:GetLogicChild('tip'):GetLogicChild('pic_tip').Background = CreateTextureBrush('vip/level_tip' .. (picindex + 1) .. '.ccz', 'vip');
end
function VipPanel:ShowVipLevelUp()
	effect = PlayEffect('viplevelup_output/',Rect(0,0,0,0),'viplevelup');
	effect:SetScale(2,2);
end