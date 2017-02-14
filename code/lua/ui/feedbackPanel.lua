--feedbackPanel.lua
--==============================================================================================
--反馈界面

FeedbackPanel =
	{
		isSend = false;
	};

local mainPanel;
local title;	
local closeBtn;	
local sendBtn;	
local feedContent;	
local tip;


local content;
--初始化
function FeedbackPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('feedbackPanel'));
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.feedbackPanel;
	self:initControl();
end
function FeedbackPanel:initControl()
	mainPanel 	= panel:GetLogicChild('mainPanel');
	title		= mainPanel:GetLogicChild('title');	
	closeBtn	= mainPanel:GetLogicChild('closeBtn');	
	sendBtn		= mainPanel:GetLogicChild('sendBtn');	
	feedContent	= mainPanel:GetLogicChild('feedContent');
	feedContent:SubscribeScriptedEvent('Label::TextChangedEvent', 'FeedbackPanel:onTextChange');	
	feedContent:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FeedbackPanel:feedContentClick');	
	tip			= mainPanel:GetLogicChild('tip');
	tip.Text    = LANG_feedback_1;
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent','FeedbackPanel:closeBtnClick');
	sendBtn:SubscribeScriptedEvent('Button::ClickEvent','FeedbackPanel:sendBtn');
end
function FeedbackPanel:closeBtnClick()
	self:onClose();
end
function FeedbackPanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	content = args.m_pControl.Text;
end
function FeedbackPanel:feedContentClick()
	feedContent.Text = '';
end
function FeedbackPanel:sendBtn(Args)
	local args = UIControlEventArgs(Args);
  	local tag = args.m_pControl.Tag;
  	if tag == 1 then
  		args.m_pControl.Tag = 2;
  		title.Text = LANG_feedback_4;
		args.m_pControl.Text = LANG_feedback_5;
		feedContent.Text = LANG_feedback_6;
		tip.Visibility = Visibility.Hidden;
		feedContent.Visibility = Visibility.Visible;
  	elseif tag == 2 then
  		if self.isSend then
  			return;
  		end
  		local curContent = string.gsub(content, "^%s*(.-)%s*$", "%1")
  		if curContent == '' or curContent == LANG_feedback_6 then
  			MessageBox:ShowDialog(MessageBoxType.Ok,LANG_feedback_7);
  			return 
  		end
  		local msg = {};
  		msg.type = 1;
    	msg.id = 1;
    	msg.msg = curContent;
    	msg.name = ActorManager.user_data.name;
    	msg.vipLevel = ActorManager.user_data.viplevel;
    	Network:Send(NetworkCmdType.nt_chart, msg);
  	end
end
--销毁
function FeedbackPanel:Destroy()
	if not panel then
		return;
	end
	panel:DecRefCount();
	panel = nil;
end

--显示
function FeedbackPanel:Show()
	ActorManager.hero:StopMove();
	title.Text = LANG_feedback_2;
	sendBtn.Text = LANG_feedback_3;
	sendBtn.Tag = 1;
	tip.Visibility = Visibility.Visible;
	feedContent.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Visible;
end

--隐藏
function FeedbackPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end


--关闭
function FeedbackPanel:onClose()
	self:Hide();
end	
function FeedbackPanel:onFeedback(msg)
	self.isSend = true;
	ActorManager.user_data.extra_data.isSend = 1;
	MenuPanel:isShowFeedbackPanel()
	self:onClose();
end

