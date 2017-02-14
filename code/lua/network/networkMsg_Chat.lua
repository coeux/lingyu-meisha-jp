--networkMsg_Chat.lua

--======================================================================
--聊天

NetworkMsg_Chat =
	{
	};


--收到消息
function NetworkMsg_Chat:onReceiveMessage(msg)
	if not MainUI.IsInitSuccess then
		return;
	end
	
	if msg.type <= 2 then		--聊天信息
		ChatPanel:ReceiveMessage(msg);
	elseif msg.type == 3 then
		 NewChatPanel:getPushMessage(msg);
	elseif msg.type == 4 then  --推送消息
		MainUI:AddLetter(msg);
	end
end

--收到服务器发送的事件推送消息
function NetworkMsg_Chat:onParseEventMessage(msg)
--	ChatPanel:ParseEventXML(msg.info);
end

--收到离线消息
function NetworkMsg_Chat:onReceiveOffLineMessage(msg)
	for _,v in ipairs(msg.mails) do
		self:onReceiveMessage(v);
	end	
end

--事件公告
function NetworkMsg_Chat:onReceiveEventMessage(msg)
	ChatPanel:AddEventMessage(msg);
end
function NetworkMsg_Chat:onFeedback(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_feedback_8);
--	FeedbackPanel:onFeedback(msg);
end
function NetworkMsg_Chat:onGetPlayerMessage(msg)
	NewChatPanel:onGetPlayerMessage(msg)
end
