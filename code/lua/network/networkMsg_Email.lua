--networkMsg_Email.lua

--======================================================================
--邮箱

NetworkMsg_Email = 
	{
	};

--返回领取邮件奖励
function NetworkMsg_Email:onGetEmailRewards(msg)
	EmailPanel:onGetEmailRewards(msg);
end

--返回邮件列表
function NetworkMsg_Email:onGetEmailList(msg)
	EmailPanel:onGetEmailList(msg);
end

--通知新邮件到达
function NetworkMsg_Email:onNewEmail(msg)
	EmailPanel:onNewEmail(msg);
end

--删除邮件结果返回
function NetworkMsg_Email:ondeleteEmail(msg)
	 EmailPanel:deleteSuccess(msg);
end

--一键领取所有奖励返回
function NetworkMsg_Email:onAllReward(msg)
	EmailPanel:onAllReward(msg);
end
