--unionCreatePanel.lua
--============================================================================================
--创建公会

UnionCreatePanel =
	{
	};
	
--变量

--控件
local mainDesktop;
local panel;
local tbInput;
local name;

--初始化
function UnionCreatePanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionCreatePanel'));
	panel:IncRefCount();
	
	tbInput = panel:GetLogicChild('input');
	tbInput:SubscribeScriptedEvent('Label::TextChangedEvent', 'UnionCreatePanel:onTextChange');
	
	name = '';
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionCreatePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionCreatePanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	
end

--隐藏
function UnionCreatePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--获取公会名称
function UnionCreatePanel:GetUnionName()
	return name;
end
--=============================================================================================
--事件
--关闭
function UnionCreatePanel:onClose()
	MainUI:Pop();
end

--创建公会
function UnionCreatePanel:onCreate()
	if ActorManager.user_data.rmb < Configuration.CreateDiamond then
		--钻石不足
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionCreatePanel_1 .. Configuration.CreateDiamond .. LANG_unionCreatePanel_2);
	elseif string.len(name) == 0 then
		--公会名称不能为空
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionCreatePanel_3);
	elseif LimitedWord:isLimited(name) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionCreatePanel_4);
	else
		local msg = {};
		msg.name = name;
		Network:Send(NetworkCmdType.req_create_gang, msg);
	end
end

--字符内容改变事件
function UnionCreatePanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	if utf8.len(args.m_pControl.Text) > Configuration.UnionNameStrCount then
		--超过最大字符限制
		args.m_pControl.Text = name;
	else
		--没有超过最大字符限制
		name = args.m_pControl.Text;
	end
end
