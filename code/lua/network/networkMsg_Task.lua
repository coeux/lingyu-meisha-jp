--networkMsg_Task.lua
NetworkMsg_Task =
    {
    };
--收到活跃度事项列表
function NetworkMsg_Task:ReceiveActivityDegreeItemList(msg)
  Task.dailyTask = {};
  for _, dt in pairs(msg.tasks) do
    local data = resTableManager:GetValue(ResTable.daily_task, tostring(dt.resid), {'openlv', 'times', 'sort'});
    dt.sort = data['sort'];
	dt.openlv = data['openlv'];
    if dt.step >= data['times'] then
      dt.weight = 3;
    elseif ActorManager.user_data.role.lvl.level >= data['openlv'] then
      dt.weight = 2;
    else
      dt.weight = 1;
    end
    table.insert(Task.dailyTask, dt);
  end
  Task:UpdateMainSceneUI();
  PlotTaskPanel:TipCheck();
end

--收到活跃度奖励
function NetworkMsg_Task:ReceiveActivityDegreeRewards(msg)
  if msg.code == 0 then
    for _, dt in pairs(Task.dailyTask) do
      if dt.resid == msg.resid then
        dt.collect = 1;
      end
    end
    PlotTaskPanel:RefreshDailyTask();
    local data = resTableManager:GetRowValue(ResTable.daily_task, tostring(msg.resid));
    if ActivityRechargePanel:QuiryDoubleReward("DailyTask") then 
        data.exp = data.exp * 1.2
    end 
    PlotTaskPanel:getReward(data);
  end
  Task:UpdateMainSceneUI();
  PlotTaskPanel:TipCheck();
end

--收到服务器通知进度改变
function NetworkMsg_Task:ReceiveActivityDegreeChange(msg)
  for _, dt in pairs(Task.dailyTask) do
    if dt.resid == msg.resid then
      dt.step = msg.step;
    end
    local data = resTableManager:GetValue(ResTable.daily_task, tostring(dt.resid), {'openlv', 'times', 'sort'});
    dt.sort = data['sort'];
    if dt.step >= data['times'] then
      dt.weight = 3;
    elseif ActorManager.user_data.role.lvl.level >= data['openlv'] then
      dt.weight = 2;
    else
      dt.weight = 1;
    end
  end
  Task:UpdateMainSceneUI();
  PlotTaskPanel:TipCheck();
end

--收到成就任务列表
function NetworkMsg_Task:ReceiveAchievementList(msg)
  Task.achievement = {};
  for _, dt in pairs(msg.tasks) do
    local data = resTableManager:GetValue(ResTable.achievement_task, tostring(dt.resid), {'openlv', 'times', 'sort','taskindex'});
    dt.sort = data['sort'];
	dt.taskindex = data['taskindex'];
    if dt.step >= data['times'] then
      dt.weight = 3;
    elseif ActorManager.user_data.role.lvl.level >= data['openlv'] then
      dt.weight = 2;
    else
      dt.weight = 1;
    end
    table.insert(Task.achievement, dt);
  end
  Task:UpdateMainSceneUI();
  if PlotTaskPanel:getcurindex() == TaskIndex.grow then
	  PlotTaskPanel:RefreshAchievementTask(1)
  elseif PlotTaskPanel:getcurindex() == TaskIndex.peiyang then
	  PlotTaskPanel:RefreshAchievementTask(2);
  end
  PlotTaskPanel:TipCheck();
end

--收到成就任务奖励
function NetworkMsg_Task:ReceiveAchievementRewards(msg)
  if msg.code == 0 then
	for _, dt in pairs(Task.achievement) do
	  if dt.resid == msg.resid then
		dt.collect = 1;
	  end
	end
	 PlotTaskPanel:RefreshAchievementTask(msg.systype);
	local data = resTableManager:GetRowValue(ResTable.achievement_task, tostring(msg.resid));
	PlotTaskPanel:getReward(data);
  end
  Task:UpdateMainSceneUI();
  PlotTaskPanel:TipCheck();
end

--收到服务器通知进度改变
function NetworkMsg_Task:ReceiveAchievementChange(msg)
  for _, dt in pairs(Task.achievement) do
	if dt.resid == msg.resid then
	  dt.step = msg.step;
	end
	local data = resTableManager:GetValue(ResTable.achievement_task, tostring(dt.resid), {'openlv', 'times', 'sort'});
	dt.sort = data['sort'];
	if dt.step >= data['times'] then
	  dt.weight = 3;
	elseif ActorManager.user_data.role.lvl.level >= data['openlv'] then
	  dt.weight = 2;
	else
	  dt.weight = 1;
	end
  end
  Task:UpdateMainSceneUI();
  PlotTaskPanel:TipCheck();
end

