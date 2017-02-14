--questPanel.lua

--========================================================================
--问题反馈界面

QuestPanel =
	{
	};

--控件
local mainDesktop;
local questPanel;
local info;


--初始化面板
function QuestPanel:InitPanel(desktop)

	mainDesktop = desktop;
	questPanel = Panel(desktop:GetLogicChild('questPanel'));
	questPanel:IncRefCount();
	questPanel.Visibility = Visibility.Hidden;

	info = questPanel:GetLogicChild('info');

end

--销毁
function QuestPanel:Destroy()
	questPanel:DecRefCount();
	questPanel = nil;
end

--显示
function QuestPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(questPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(questPanel, StoryBoardType.ShowUI1);
	
end

--隐藏
function QuestPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(questPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--关闭
function QuestPanel:onClose()
	MainUI:Pop();
end

--发送
function QuestPanel:onSend()

	local msg = {};
	msg.game = 'zs';
	msg.platform = platformSDK.m_Platform .. '_' .. platformSDK.m_System;
	msg.node = 1;
	msg.role_name = ActorManager.hero.name;
	msg.uin = platformSDK.m_Platform .. '_' .. platformSDK.m_System;
	msg.event_reason = 1;
	msg.username = ActorManager.hero.name;
	msg.phone = '';
	msg.email = '';
	msg.qq = '';
	msg.address = '';
	msg.event_detail = info.Text;
	msg.attachment = '';
	local params = cjson.encode(msg);
	
	curlManager:SendHttpScriptRequest('http://kf.123u.com/api/addevent.php', '', '', params, 0);

	MainUI:Pop();
	
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_questPanel_1);
	
end
