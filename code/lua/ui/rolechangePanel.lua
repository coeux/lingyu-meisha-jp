--rolechangePanel.lua
--=================================================================================
--转职界面
RolechangePanelPanel =
	{
	};
	
--变量
local changeroleindex = nil;

--控件
local mainDesktop;
local panel;
local closebtn;
local roleImg1;
local roleImg2;
local roleImg3;
local infoimg1;
local infoimg2;
local infoimg3;
local btnPanel;

local changebtn1;
local changebtn2;
local changebtn3;

local cost1;
local cost2;
local cost3;

local currole1;
local currole2;
local currole3;

local changeTipPanel;
local curHave;
local ok;
local cancel;

--初始化
function RolechangePanelPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('changeRolePanel');
	panel:IncRefCount();

	closebtn = panel:GetLogicChild('closebtn');
	roleImg1 = panel:GetLogicChild('roleImg1');
	roleImg2 = panel:GetLogicChild('roleImg2');
	roleImg3 = panel:GetLogicChild('roleImg3');
	infoimg1 = panel:GetLogicChild('infoimg1');
	infoimg2 = panel:GetLogicChild('infoimg2');
	infoimg3 = panel:GetLogicChild('infoimg3');
	btnPanel = panel:GetLogicChild('btnPanel');

	changebtn1 = btnPanel:GetLogicChild('changebtn1');
	changebtn2 = btnPanel:GetLogicChild('changebtn2');
	changebtn3 = btnPanel:GetLogicChild('changebtn3');

	cost1 = btnPanel:GetLogicChild('cost1');
	cost2 = btnPanel:GetLogicChild('cost2');
	cost3 = btnPanel:GetLogicChild('cost3');
	currole1 = btnPanel:GetLogicChild('currole1');
	currole2 = btnPanel:GetLogicChild('currole2');
	currole3 = btnPanel:GetLogicChild('currole3');


	changeTipPanel = panel:GetLogicChild('changeTipPanel');
	curHave		   = changeTipPanel:GetLogicChild('panel'):GetLogicChild('curHave');
	ok 			   = changeTipPanel:GetLogicChild('panel'):GetLogicChild('ok');
	cancel 		   = changeTipPanel:GetLogicChild('panel'):GetLogicChild('cancel');
	ok:SubscribeScriptedEvent('Button::ClickEvent','RolechangePanelPanel:reqChangeRole');
	cancel:SubscribeScriptedEvent('Button::ClickEvent','RolechangePanelPanel:changeTipPanelHide');
	changeTipPanel.Visibility = Visibility.Hidden;
end

--销毁
function RolechangePanelPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function RolechangePanelPanel:Show()
	HomePanel:destroyRoleSound()
	roleImg1.Image = GetPicture('navi/P101_navi_01.ccz');
	roleImg2.Image = GetPicture('navi/P102_navi_01.ccz');
	roleImg3.Image = GetPicture('navi/P103_navi_01.ccz');
	infoimg1.Image = GetPicture('login/login_icon_201.ccz');
	infoimg2.Image = GetPicture('login/login_icon_202.ccz');
	infoimg3.Image = GetPicture('login/login_icon_200.ccz');
	currole1.Image = GetPicture('home/home_curuser.ccz');
	currole2.Image = GetPicture('home/home_curuser.ccz');
	currole3.Image = GetPicture('home/home_curuser.ccz');
	closebtn:SubscribeScriptedEvent('Button::ClickEvent', 'RolechangePanelPanel:Hide');
	changebtn1:SubscribeScriptedEvent('Button::ClickEvent', 'RolechangePanelPanel:change_roletype');
	changebtn2:SubscribeScriptedEvent('Button::ClickEvent', 'RolechangePanelPanel:change_roletype');
	changebtn3:SubscribeScriptedEvent('Button::ClickEvent', 'RolechangePanelPanel:change_roletype');

	RolechangePanelPanel:updatePanel();
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI3);
	else
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	end
end

--隐藏
function RolechangePanelPanel:Hide()
	--增加UI消失时的效果
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then	
		StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI3, 'StoryBoard::OnPopUI');	
	else
		StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end
end

function RolechangePanelPanel:updatePanel()
	for index = 1, 3 do
		if index == ActorManager.user_data.role.resid%100 then
			btnPanel:GetLogicChild('changebtn' .. index).Visibility = Visibility.Hidden;
			btnPanel:GetLogicChild('cost' .. index).Visibility = Visibility.Hidden;
			btnPanel:GetLogicChild('currole' .. index).Visibility = Visibility.Visible;
		else
			if ActorManager.user_data.role.lvl.level < 50 then
				btnPanel:GetLogicChild('changebtn' .. index).Enable =false;
				btnPanel:GetLogicChild('cost' .. index).Text = LANG_first_pass_tip1;
			else
				btnPanel:GetLogicChild('changebtn' .. index).Enable =true;
				btnPanel:GetLogicChild('cost' .. index).Text = LANG_first_pass_tip1;
			end
			btnPanel:GetLogicChild('changebtn' .. index).Visibility = Visibility.Visible;
			btnPanel:GetLogicChild('cost' .. index).Visibility = Visibility.Visible;
			btnPanel:GetLogicChild('currole' .. index).Visibility = Visibility.Hidden;

		end
	end
end

--发送转职请求
function RolechangePanelPanel:reqChangeRole()
	local msg = {}
	if not changeroleindex then
		return 
	end
	msg.roletype = changeroleindex;
	Network:Send(NetworkCmdType.req_change_roletype_t, msg);
end


--换主角成功处理
function RolechangePanelPanel:change_roletype(Args)
	local args = UIControlEventArgs(Args);
	changeroleindex = args.m_pControl.Tag;
	local roletype = {
		[101]	= '风主',
		[102] 	= '火主',
		[103] 	= '无主',
	};
	curHave.Text = LANG_change_role_2..ActorManager.user_data.rmb..LANG_change_role_3;
	changeTipPanel.Visibility = Visibility.Visible;
	--[[
	local contents = {}
	local brushElement = uiSystem:CreateControl('BrushElement')
	brushElement.Background = CreateTextureBrush('recharge/GuildWelfare_gem.ccz', 'unionbattle')
	brushElement.Size = Size(37,34)
	table.insert(contents,{cType = MessageContentType.brush; brush = brushElement})
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_change_role_1})
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_change_role_2..ActorManager.user_data.rmb..LANG_change_role_3})
	--local tipText = LANG_ROLECHANGE_REQ_INFO .. roletype[changeroleindex];
	local okDelegate = Delegate.new(RolechangePanelPanel, RolechangePanelPanel.reqChangeRole, 0);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);
	]]
end

function  RolechangePanelPanel:changeTipPanelHide()
	changeTipPanel.Visibility = Visibility.Hidden;
end