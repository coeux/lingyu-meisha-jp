--networkMsg_LoveTask.lua

--======================================================================
--爱恋度
NetworkMsg_LoveTask =
{
};

--请求所有卡牌爱恋度任务
function NetworkMsg_LoveTask:reqLoveTask()
	Network:Send(NetworkCmdType.req_love_task_list, {});
end

--返回爱恋度进度信息
function NetworkMsg_LoveTask:retLoveTask(msg)
	LoveTask:HandleLoveTaskList(msg);
end

--请求完成爱恋度任务
function NetworkMsg_LoveTask:reqCommitLoveTask(loveTaskId)
	local t = {};
	t.resid = loveTaskId;
	Network:Send(NetworkCmdType.req_commit_love_task, t, true);
end

--返回完成任务
function NetworkMsg_LoveTask:retCommitLoveTask(msg)
	LoveTask:HandleLoveTaskComplete(msg);
end

--获得爱恋度进度变化通知
function NetworkMsg_LoveTask:onLoveTaskChange(msg)
	LoveTask:HandleLoveTaskChange(msg);
end
