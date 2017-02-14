--loveTask.lua

--========================================================================
--爱恋度任务
--
--策划说：卡牌不可被销毁 2015-01-29
--         服务器任务记录使用伙伴id
LoveTask = 
{
  allTasks = {};
  complete = {}; -- 任务完成true（完成未交），任务未完成false
};

--任务数据初始化
function LoveTask:Init()
end

--处理爱恋度任务列表返回的结果
function LoveTask:HandleLoveTaskList(msg)
  local value;
  for _, v in pairs(msg.love_task) do
    self.allTasks[v.pid] = {};
    self.allTasks[v.pid].step = v.step;
    self.allTasks[v.pid].ltid = v.ltid;
    value = resTableManager:GetValue(ResTable.love_task, tostring(v.ltid), 'value1');
    self.complete[v.ltid] = v.state;
  end
end

--处理爱恋度进度变化
function LoveTask:HandleLoveTaskChange(msg)
  if not self.allTasks[msg.love_task.pid] then
    self.allTasks[msg.love_task.pid] = {};
  end

  self.allTasks[msg.love_task.pid].step = msg.love_task.step;
  value = resTableManager:GetValue(ResTable.love_task, tostring(msg.love_task.ltid), 'value1');
  self.complete[msg.love_task.ltid] = msg.love_task.step >= value[2] and true or nil;
end

--处理爱恋度任务完成
function LoveTask:HandleLoveTaskComplete(msg)
  local role = ActorManager:GetRoleFromResid(math.floor(msg.resid/100));
  if role then
	role.lovevalue = 0;
  end
  if msg.code == 0 then
    self.complete[msg.resid] = nil;
    for _, v in pairs(self.allTasks) do
      if v.ltid == msg.resid then
        if v.ltid % 10 ~= LovePanel.MAX_LOVE_TASK_LEVEL then
          self.allTasks[_].step = 0;
          self.allTasks[_].ltid = v.ltid + 1;
        end
        v = nil;
        break;
      end
    end
  end
  LovePanel:Refresh();
  LovePanel:ShowStroyPanel(msg.resid)
  --  更新战斗力
  uiSystem:UpdateDataBind()
end

--判断任务是否完成（完成未交）
function LoveTask:isComplete(ltid)
  return self.complete[ltid];
end
