--task.lua
--========================================================================
--任务类

Task =
  {
    allTasks           = {};   -- 所有任务列表，包含需要遍历操作的一些列
    allBarriers        = {};   -- 所有关卡列表，根据物品和怪物查找最大开启关卡，用于寻路
    mainTask           = nil;  -- 主线任务

                               -- step
    TaskUnreceive      = -1;   -- 任务未接状态
    TaskReceived       = 0;    -- 任务已接状态
    TaskSystemComplete = 1;    -- 系统任务完成

    undoneBline        = {};   -- 可接支线任务(不包括系统支线)
    doneBline          = {};   -- 已接支线任务
    currentNpc;                -- 当前对话NPC，自动寻路或点击NPC时指定
    currentBarrier    = nil;   -- 自动寻路关卡
    newDoneTask       = nil;   -- 刚完成的任务(目前通关后完成任务)
    dailyTask         = {};    -- 记录一下每日任务
	achievement		  = {};		--记录成就任务
  };

local lastMainId = nil;              --最后完成的主线任务Id
local residsMap = {};                 --已完成和已接支线任务ID表
local itemBarrierMap = {};          --掉落物品与最大关卡映射，关卡需开启的
local monsterBarrierMap = {};        --怪物与最大关卡映射，关卡需开启的
local handleRoundId = nil;            --已经处理过映射的最大关卡ID，新开启的关卡需另外处理
local OpenOlympusTaskId = 1407;      --开启第二个奥林匹斯山场景的任务ID
local FirstTaskId = 201;        --第一个关卡ID

local getDailyTaskNum = 0;
local allDailyTaskNum = 0;
local leftDailyTaskNum = 0;
local leftDailyTaskExp = 0;

--任务数据初始化
function Task:Init()
  lastMainId = ActorManager.user_data.main_task.questid;
  --初始化掉落物品和怪物与关卡的映射
  Task:InitBarrierMap();
  
  --从user_data里面获取主线任务
  local msg = {};
  msg.tasks = ActorManager.user_data.tasks;
  ActorManager.user_data.tasks = nil;
  Task:HandleTaskList(msg);

  getDailyTaskNum = 0;
  allDailyTaskNum = 0;
  leftDailyTaskNum = 0;
  leftDailyTaskExp = 0;
end

--处理任务列表返回结果
function Task:HandleTaskList(msg)
  for _,task in ipairs(msg.tasks) do  
    local data = resTableManager:GetRowValue(ResTable.task, tostring(task.resid));
    if TaskClass.main == data['task_class'] then
      self.mainTask = data;
      self.mainTask.step = task.step;
      if TaskType.barrier == self.mainTask['type'] then
        ActorManager.user_data.round.openRoundId = self.mainTask['value'][1];
      end
    else
      data.step = task.step;
      self.doneBline[data['id']] = data;
      residsMap[data['id']] = data['id'];
    end
  end

  --没有已接的主线任务，
  if nil == self.mainTask then
    self:fetchNextMainTask();
  end

  local msg = {};
  --暂时不用
  msg.sceneid = 0;
  --请求已经完成的支线任务，用于查找可接的支线任务
  Network:Send(NetworkCmdType.req_finished_bline, msg, true);
  RolePortraitPanel:UpdateMainTaskHandle();
end

--处理已完成的支线任务
function Task:HandleFinishBline(msg)
  self:resetResidsMap(msg.resids);
  self:refreshUndoneBline();
  self:UpdateMainSceneUI();

  local t = self:getAllPlotTasks()[1];
  if self:isComplete(t) or t.step == self.TaskUnreceive then
--    TaskTipPanel:onClick();
	  TaskTipPanel:Refresh()
  end
  EventManager:FireEvent(EventType.TaskInitFinished);
end  

--主界面自动任务
function Task:GuideInMainUI()
  local task = self:getNextHandleTask();
  
  if nil == task then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_task_1);
    return;
  end
  --隐藏自动任务提示
  UserGuidePanel:HideAutoTaskGuide(); 
  --验证系统任务是否有完成未提交的
  UserGuide:ValidateSystemTask();
  self:GuideByTask(task);
end  

--任务列表自动寻路
function Task:GuideInTaskList(taskid)
  local task = Task:getTaskById(taskid);
  self:GuideByTask(task);
end

--更新主城任务相关的信息
function Task:UpdateMainSceneUI()
  if nil ~= GodsSenki.mainScene and nil ~= GodsSenki.mainScene.npcList then
	if MainUI:GetSceneType() ~= SceneType.Union then
		--更新NPC头顶任务状态
		GodsSenki.mainScene:UpdateNPCHeadStatus();
	end
  end
  
  local task = self:getNextHandleTask();
  if nil == task then
    return;
  end
  
  local npcid = nil;
  --系统任务
  if TaskType.system == task['type'] then
    npcid = task['quest_get'];

  --任务未接，显示任务发布人
  elseif task.step == self.TaskUnreceive then
    npcid = task['quest_get'];
    
  --任务未完成，显示关卡名和关卡图片
  elseif false == self:isComplete(task) then

  --任务完成，显示任务交付人
  elseif self:isComplete(task) then  
    npcid = task['quest_finish'];

  end

	PlotTaskPanel:hideTips();
  local tips = false;
  local alltask = self:getAllPlotTasks();
  for _, task in pairs(alltask) do
    if self:isComplete(task) then
	  if ActorManager.user_data.userguide.isnew >= UserGuideIndex.dailytask then
		 MenuPanel:TaskTipsShow();
	  end
      PlotTaskPanel:showTips(2);
      tips = true;
      break;
    end
  end
  allDailyTaskNum = 0;
  getDailyTaskNum = 0;
  leftDailyTaskNum = 0;
  leftDailyTaskExp = 0;

--  if not tips then
  local i=1;
  while true do
      local dailytask_sort = resTableManager:GetValue(ResTable.daily_task,tostring(i),'sort');
	  if dailytask_sort == nil then
		  break;
	  end
	  i = i + 1;
	  if tonumber(dailytask_sort) >= 0 then
		  allDailyTaskNum = allDailyTaskNum + 1;
		  getDailyTaskNum = getDailyTaskNum + 1;
	  end
	  
  end

    for _, task in pairs(self.dailyTask) do
      local taskInfo = resTableManager:GetValue(ResTable.daily_task, tostring(task.resid), {'times','exp','sort'});
      if task.collect ~= 1 and task.step == taskInfo['times'] and taskInfo['sort'] >= 0 then
		leftDailyTaskNum = leftDailyTaskNum + 1;
		leftDailyTaskExp = leftDailyTaskExp + taskInfo['exp'];
        MenuPanel:TaskTipsShow();
				PlotTaskPanel:showTips(1);
        tips = true;
--        break;
	  elseif task.collect ~= 1 and taskInfo['sort'] >= 0 then
		  getDailyTaskNum = getDailyTaskNum - 1;
		  leftDailyTaskNum = leftDailyTaskNum + 1;
		  leftDailyTaskExp = leftDailyTaskExp + taskInfo['exp'];
      end
    end

	local achievementtip1 = true;
	local achievementtip2 = true;
  local count1 = 0;
  local count2 = 0;
	for _, task in pairs(self.achievement) do
      local taskInfo = resTableManager:GetValue(ResTable.achievement_task, tostring(task.resid), {'times','exp','sort','typeindex','openlv'});
      if task.collect ~= 1 and task.step >= taskInfo['times'] and taskInfo['sort'] >= 0 and taskInfo['openlv'] <= ActorManager.user_data.role.lvl.level then
					if taskInfo['typeindex'] == 1 and achievementtip1 then
							LimitTaskPanel:GetNewNews(LimitNews.achievement1);
              count1 = count1 + 1;
						  achievementtip1 = false;
					elseif taskInfo['typeindex'] == 2 and achievementtip2 then
							LimitTaskPanel:GetNewNews(LimitNews.achievement2);
              count2 = count2 + 1;
							achievementtip2 = false;
					end
					MenuPanel:TaskTipsShow();
					tips = true;
			end
	end
  --判断是否有可以领取的任务
  if count1 == 0 then
    LimitTaskPanel:updateTask(LimitNews.achievement1);
  end
  if count2 == 0 then
    LimitTaskPanel:updateTask(LimitNews.achievement2);
  end

	if not tips then MenuPanel:TaskTipsHide() end;
	TaskTipPanel:Refresh();
end

--获取下一个处理的任务
function Task:getNextHandleTask()
  local level = ActorManager.user_data.role.lvl.level;
  --优先处理主线
  local task = self.mainTask;
  --主线下一个任务主角等级不够，则自动寻路处理支线
  if nil ~= self.mainTask and self.mainTask['level'] > level and self.mainTask.step == self.TaskUnreceive then
    task = self:getMaxBline();
  end
  --都没有可接主线和支线，显示下一个主线
  if nil == task then
    task = self.mainTask;
  end
  return task;
end

--根据任务自动寻路
function Task:GuideByTask(task)
  if nil == task then
    return
  end
  --任务未接，找任务发布人
  if task.step == self.TaskUnreceive then
    self:findNpc(task['quest_get']);

  --任务未完成，如果不是找人任务则寻路到相应的关卡
  elseif false == self:isComplete(task) then
    self:findBarrier(self:getBarrierIdByTask(task));

  --任务完成，则寻路去找任务交付人
  elseif self:isComplete(task) then
    self:findNpc(task['quest_finish']);
  end
end

--寻路到指定NPC
function Task:findNpc(npcid, noFindPathPanel)
  if nil ~= npcid then    
    --寻找NPC和当前NPC是同一个人，不需要寻路
    self.currentNpc = npcid
    if self:isHeroStandInNpc(npcid) then
      TaskDialogPanel:onPopUpNpcDialog();
      return;
    end
    
    --主城界面走动时将打开的UI缩回去
    MenuPanel:onMenuOut();

    -- self.currentNpc = npcid;
    --标示自动寻路，弹出NPC对话框或向关卡出发时重新置为no
    ActorManager.hero:SetFindPathType(FindPathType.npc);
    
    local data = resTableManager:GetRowValue(ResTable.npc, tostring(npcid));
    local sceneid = data['city_id'];
    --同一个主城
    if ActorManager.user_data.sceneid == sceneid then
      --显示自动寻路面板
      if true ~= noFindPathPanel then
        TaskFindPathPanel:Show();  
      end
      
      local x,y = VerifyScenePos(MainUI:GetSceneType(), data['coord'][1], data['coord'][2]);
      
      --直接寻路到传送点
      local pos = Vector2(x, y);
      
      --通知服务器移动到指定位置
      local msg = {};
      msg.uid = ActorManager.user_data.uid;
      msg.sceneid = ActorManager.user_data.sceneid;
      msg.x = math.floor(pos.x);
      msg.y = math.floor(pos.y);
      Network:Send(NetworkCmdType.nt_move, msg, true);
      
      ActorManager.hero:MoveTo(pos);
    --不同主城
    else
      --弹出世界地图
      WorldPanel:onFindPathScene(sceneid);
    end
  end
end

--寻路到指定关卡
function Task:findBarrier(barrierid)
  if nil ~= barrierid then
    --主城界面走动时将打开的UI缩回去
    MenuPanel:onMenuOut();
    self.currentBarrier = barrierid;
    
    --关闭其他打开的窗口，打开关卡
    -- MainUI:PopAll();
    if nil == self.currentBarrier then
      PveBarrierPanel:OpenBarrierMapOfMainCity(ActorManager.user_data.sceneid)
    else
      PveBarrierPanel:OpenToPage(self.currentBarrier, true);
    end
  end
end

--初始化掉落物品，怪物与最大关卡映射
function Task:InitBarrierMap()
  handleRoundId = ActorManager.user_data.round.openRoundId;  
  for _,barrier in ipairs(self.allBarriers) do  
    self:iterateBarrier(barrier);
  end
end

--根据任务查找对应的关卡
function Task:getBarrierIdByTask(task)
  if task == nil then
    return nil;
  end
  local barrierid = nil;
  if TaskType.barrier == task['type'] then
    barrierid = task['value'][1];
  elseif TaskType.monster == task['type'] then
    barrierid = self:getBarrierIdByMonsterId(task['value'][1]);
  elseif TaskType.reward == task['type'] then
    barrierid = self:getBarrierIdByItemId(task['value'][1]);
  end
  return barrierid;
end


--根据掉落物品id查找最大的包含怪物的关卡
function Task:getBarrierIdByMonsterId(monsterid)
  self:refreshBarrierMap();
  return monsterBarrierMap[monsterid];
end

--根据掉落物品id查找最大的包含掉落物品的关卡
function Task:getBarrierIdByItemId(itemid)
  self:refreshBarrierMap(); 
  return itemBarrierMap[itemid];
end

--新开启的副本需要添加到映射表中
function Task:refreshBarrierMap()
  local roundId = tonumber(ActorManager.user_data.round.openRoundId);
  local barrierid;
  local rowData;
  if 0 == handleRoundId then
    --调整为1000，可以统一加1处理
    handleRoundId = 1000;
  end

  if roundId > handleRoundId then
    for i = 1, roundId - handleRoundId do
      barrierid = handleRoundId + i;
      rowData = resTableManager:GetRowValue(ResTable.barriers, tostring(barrierid));
      if nil ~= rowData['item_drop'] then
        for _,item in ipairs(rowData['item_drop']) do
          --相同物品后面的关卡覆盖前面的关卡
          itemBarrierMap[item[1]] = barrierid;
        end
      end
      self:iterateMonsters(rowData['initial_monster'], barrierid);  
      self:iterateMonsters(rowData['monster'], barrierid);
      self:iterateBoss(rowData['initial_boss'], barrierid);
      self:iterateBoss(rowData['boss'], barrierid);
    end
    handleRoundId = roundId;
  end
end

--遍历一个关卡里映射关系
function Task:iterateBarrier(barrier)
  if nil ~= barrier.dropItems then
    for _,item in ipairs(barrier.dropItems) do  
      if barrier.id <= ActorManager.user_data.round.openRoundId then  
        itemBarrierMap[item[1]] = barrier.id;
      end
    end
  end
  self:iterateMonsters(barrier.idleMonster, barrier.id);
  self:iterateMonsters(barrier.monster, barrier.id);
  self:iterateBoss(barrier.idleBoss, barrier.id);
  self:iterateBoss(barrier.boss, barrier.id);
end

--遍历一个怪物列表里映射关系
function Task:iterateMonsters(monsters, barrierid)
  if nil ~= monsters then
    for _,monster in ipairs(monsters) do
      if barrierid <= ActorManager.user_data.round.openRoundId then
        monsterBarrierMap[monster[1]] = barrierid;
      end        
    end
  end
end  

--遍历一个怪物列表里映射关系
function Task:iterateBoss(boss, barrierid)
  if nil ~= boss and nil ~= boss[1] then
    if barrierid <= ActorManager.user_data.round.openRoundId then
      monsterBarrierMap[boss[1]] = barrierid;  
    end  
  end
end

--获得任务，从发布人获得
function Task:GetTask(msg)
  if nil == msg then
    return;
  end
  local taskid = msg.resid;
  if nil ~= self.mainTask  and taskid == self.mainTask['id'] and self.mainTask.step == self.TaskUnreceive then
    self.mainTask.step = 0;
    
    --接主线任务时更新已开启的关卡
    local barrierid = Task:getBarrierIdByTask(self.mainTask);  
    if barrierid ~= nil then
      ActorManager.user_data.round.openRoundId = barrierid;
    end
    
    --触发接主线任务事件
    EventManager:FireEvent(EventType.GetMainTask, taskid);
  else
    local data = self.undoneBline[taskid];
    data.step = 0; -- self.TaskReceived;
    --添加任务已接任务表
    self.doneBline[taskid] = data;
    --任务从可接任务表删除
    self.undoneBline[taskid] = nil;
    
    --已经任务加到映射里
    residsMap[taskid] = taskid;
    
    TaskDialogPanel:AfterGetTask();
  end

  local t = self:getAllPlotTasks()[1];
  if self:isComplete(t) or t.step == self.TaskUnreceive then
--    TaskTipPanel:onClick();
	  TaskTipPanel:Refresh();
  end
end

--提交任务，向交付人提交
function Task:CommitTask(msg)
  if nil == msg then
    return;
  end
  local taskid = msg.resid;
  if nil ~= self.mainTask  and taskid == self.mainTask['id'] then
    --主线任务提交，最后完成的主线任务
    lastMainId = self.mainTask['id'];
    ActorManager.user_data.main_task.questid = lastMainId;
    ActorManager.user_data.main_task.nextquestid = msg.next_id;
    --更新支线
    self:refreshUndoneBline();
    --获取下一个主线
    self:fetchNextMainTask();

    --触发提交主线任务事件
    EventManager:FireEvent(EventType.CommitMainTask, taskid);
  else
    --添加到已完成支线任务Id列表
    residsMap[taskid] = taskid;
    --已接支线任务列表删除该任务
    self.doneBline[taskid] = nil;

    TaskDialogPanel:AfterCommitTask();
  end  
  
  --更新主城NPC状态
  Task:UpdateMainSceneUI();

  -- --经验和金币奖励浮动效果
  -- local taskReward = resTableManager:GetValue(ResTable.task, tostring(taskid), {'exp', 'coin'});
  -- MainUI:ShowEffectTask(taskReward['exp'], taskReward['coin']);
end

--通知任务状态变化
function Task:NotifyTaskChange(msg)
  if nil == msg and nil == msg.task then
    return;
  end

  if nil ~= self.mainTask  and msg.task.resid == self.mainTask['id']then
    self.mainTask.step = msg.task.step;
  else
    self.doneBline[msg.task.resid].step = msg.task.step;
    self.newDoneTask = self.doneBline[msg.task.resid];
  end  
  local t = self:getAllPlotTasks()[1];
  if self:isComplete(t) or t.step == self.TaskUnreceive then
 --   TaskTipPanel:onClick();
	  TaskTipPanel:Refresh();
  end
end  

--获取下一个主线任务
function Task:fetchNextMainTask()
  --更新主线
  local data = resTableManager:GetRowValue(ResTable.task, tostring(ActorManager.user_data.main_task.nextquestid));
  --等级不足还是让他获取，只是在可接任务列表给予提示，自动任务不做处理
  if nil ~= data then
    self.mainTask = data;
    self.mainTask.step = self.TaskUnreceive;
  end
end

--刷新未接任务
function Task:refreshUndoneBline()
  local level = ActorManager.user_data.role.lvl.level;
  for _, task in ipairs(self.allTasks) do
    --任务条件：支线任务，非系统操作类型，未完成和等级达到
    if task.class ~= TaskClass.main and task.type ~= TaskType.system and task.preid <= lastMainId and nil == residsMap[task.id] and task.level <= level then
      local data = resTableManager:GetRowValue(ResTable.task, tostring(task.id));
      if nil ~= data then
        data.step = self.TaskUnreceive;
        self.undoneBline[data['id']] = data;
      end
    end
  end

end

--根据NPC获取该发布人或交付人的任务列表
function Task:GetTasksByNpc(npcid)
  --该NPC可接或已接的任务, 任务进度由step标示
  ---[[
  local tasks = {};  
  if self.mainTask ~= nil and self.mainTask['level'] < Configuration.TaskMaxLevel and self:isNpcTask(self.mainTask, npcid) then  
    table.insert(tasks, self.mainTask);
  end
  for _,bline in pairs(self.undoneBline) do
    if self:isNpcTask(bline, npcid) then
      table.insert(tasks, bline);
    end
  end
  for _,bline in pairs(self.doneBline) do
    if self:isNpcTask(bline, npcid) then
      table.insert(tasks, bline);
    end
  end
  table.sort(tasks, CompareDescendingTask);
  return tasks;
  --]]
end

--获取该NPC的任务状态，已完成>未接>已接未完成
--完成>可领取>已领取>不可领取(可以用)
function Task:GetNpcTaskStatus(npcid)
  local status = NpcStatus.no;
  
  local taskList = Task:GetTasksByNpc(npcid);
  local task;
  local taskStatus;
  --for index = 1,3 do
  --只显示第一个任务
  task = taskList[1];    
  if nil ~= task then
    if self:isComplete(task) then
      taskStatus = NpcStatus.complete;
    elseif self.TaskUnreceive == task.step then
      local level = ActorManager.user_data.role.lvl.level;
      if task['level'] > level then
        taskStatus = NpcStatus.noLevel;
      else
        taskStatus = NpcStatus.undone;
      end
    else
      taskStatus = NpcStatus.receive;
    end
    if taskStatus > status then
      status = taskStatus;
    end
  end
  return status;
end

--是否是该NPC的任务
function Task:isNpcTask(task, npcid)
  --npc是任务发布人，对应的任务未接或未完成
  if npcid == task['quest_get'] and (self.TaskUnreceive == task.step or false == self:isComplete(task))then
    return true;
  end
  --npc是任务交接人，对应的任务已完成
  if npcid == task['quest_finish'] and self:isComplete(task) then
    return true;
  end
  return false;
end

--获取所有显示的支线
function Task:getAllPlots()
  local allBline = {};
  for _, bline in pairs(Task.doneBline) do
    table.insert(allBline, bline);
  end
  for _, bline in pairs(Task.undoneBline) do
    table.insert(allBline, bline);
  end
  
  if nil ~= Task.mainTask and Task.mainTask['level'] < Configuration.TaskMaxLevel then
    table.insert(allBline, Task.mainTask);
  end
  table.sort(allBline, CompareBlineTask);
  return allBline;
end

--====================================================================================
--获取所有任务（任务面板）
function Task:getAllPlotTasks()
  local tasks = {};
  for _, task in pairs(Task.doneBline) do
    table.insert(tasks, task);
  end
  for _, task in pairs(Task.undoneBline) do
    table.insert(tasks, task);
  end
  if nil ~= Task.mainTask and Task.mainTask['level'] < Configuration.TaskMaxLevel then
    table.insert(tasks, Task.mainTask);
  end
  table.sort(tasks, ComparePlotsTask);
  return tasks;
end

--按照主线支线优先级排序
function ComparePlotsTask(task1, task2)
  local p1 = Task:getTaskPriority(task1);
  local p2 = Task:getTaskPriority(task2);
  if p1 ~= p2 then
    return p1 > p2;
  else
    return task1['id'] > task2['id'];
  end
end

--获取任务表的显示优先级
function Task:getTaskPriority(task)
  local priority = 0;
  if Task:isComplete(task) then
    priority = priority + 10;
  end
  local flag = task['type'] == TaskType.barrier or task['type'] == TaskType.monster or task['type'] == TaskType.reward;
  if flag and task.step ~= self.TaskUnreceive and task.step ~= task['value'][2] then
    priority = priority + 4;
  end
  if task.step == self.TaskUnreceive then
    priority = priority + 7;
  end
  if task['task_class'] == TaskClass.main then
    priority = priority + 3;
  end
  return priority;
end
--====================================================================================

--按任务编号从大到小排序
function CompareBlineTask(task1, task2)
  local p1 = Task:getPlotPriority(task1);
  local p2 = Task:getPlotPriority(task2);
  if p1 ~= p2 then
    return p1 > p2;
  else
    return task1['id'] > task2['id'];
  end
end

--任务排序，主线，已完成，已接，未接
function CompareDescendingTask(task1, task2)
  return Task:getPriority(task1) > Task:getPriority(task2);
end


--获取排序优先级
function Task:getPlotPriority(task)
  local priority = 0;  
  if Task:isComplete(task) then
    --任务完成权重为2
    priority = priority + 2;
  end
  if TaskMain.yes == task['mainline'] then
    --主线任务权重为8
    priority = priority + 1;
  end
  return priority;
end

--获取排序优先级
function Task:getPriority(task)
  --[[
  local priority = 0;  
  if TaskMain.yes == task['mainline'] then
    --主线任务权重为8
    priority = priority + 8;
  end
  if task.step == self.TaskUnreceive then
    --任务未接权重为4
    priority = priority + 4;
  end
  if Task:isComplete(task) then
    --任务完成权重为2
    priority = priority + 2;
  end
  
  return priority;
  --]]
  ---[[
  local priority = 0;
  if Task:isComplete(task) then
    priority = priority + 4;
  end
  if task.step == self.TaskUnreceive then
    priority = priority + 3;
  end
  if task.step == self.TaskReceived then
    priority = priority + 2;
  end
  if TaskClass.main == task['class'] then
    priority = priority + 1;
  end
  return priority;
  --]]
end

--判断任务是否完成
function Task:isComplete(task)

  if TaskType.dialog == task['type'] then
    return task.step ~= self.TaskUnreceive;
  end
  if TaskType.system == task['type'] then
    return task.step ~= self.TaskUnreceive;
  end
  return task.step >= task['value'][2];
end

--转换成映射，提高查找效率
function Task:resetResidsMap(resids)
  if nil ~= resids then
    for _,resid in ipairs(resids) do
      residsMap[resid] = resid;
    end  
  end
end

--寻找最大支线，包括已接和未接
function Task:getMaxBline()
  local maxBline = nil;
  for _,task in pairs(self.undoneBline) do
    if nil == maxBline or task['id'] > maxBline['id'] then
      maxBline = task;
    end
  end
  for _,task in pairs(self.doneBline) do
    if nil == maxBline or task['id'] > maxBline['id'] then
      maxBline = task;
    end
  end
  return maxBline;
end

--根据任务ID查找对应的已接或未接任务
function Task:getTaskById(taskid)
  if taskid == self.mainTask['id'] then
    return self.mainTask;
  end    
  local task = nil;
  task = self.undoneBline[taskid];
  if nil ~= task then
    return task;
  else
    return self.doneBline[taskid];
  end
end

--主角是否站在该NPC面前
function Task:isHeroStandInNpc(npcid)
  local pos = ActorManager.hero:GetPosition();
  local cor = resTableManager:GetValue(ResTable.npc, tostring(npcid), 'coord');
  if cor[2] > GlobalData.MainSceneMaxY then
    cor[2] = GlobalData.MainSceneMaxY;
  end
	local a2b2 = math.abs((pos.x - cor[1]) * (pos.x - cor[1])) + math.abs((pos.y - cor[2]) * (pos.y - cor[2]));
	local c2 = 2500;
	-- 将原有的点 变更为某一范围，防止NPC在死角用户无法站到指定点 by fanbin
  -- if pos.x == cor[1] and pos.y == cor[2] then
	if a2b2 <= c2 then
    return true;
  else  
    return false;
  end
end

--根据主线任务判断新的奥林匹斯山场景是否打开
function Task:isNewOlympusOpen()
  if self.mainTask['id'] > OpenOlympusTaskId or (self.mainTask['id'] == OpenOlympusTaskId and self.mainTask.step ~= self.TaskUnreceive) then
    return true;
  end
  return false;
end

--切换主城时寻路到NPC或关卡
function Task:FindPathToPos()
  if ActorManager.hero.findPathType ~= FindPathType.barrier and ActorManager.hero.findPathType ~= FindPathType.npc then
    return;
  end
  
  local x,y;
  if ActorManager.hero.findPathType == FindPathType.barrier then  
    x,y = VerifyScenePos(MainUI:GetSceneType(), GlobalData.RightTeleportPos.x, GlobalData.RightTeleportPos.y);
    --关卡先标示，人物等对话框弹出再标示
    ActorManager.hero.findPathType = FindPathType.no;
  elseif ActorManager.hero.findPathType == FindPathType.npc then    
    local cor = resTableManager:GetValue(ResTable.npc, tostring(Task.currentNpc), 'coord');  
    x,y = VerifyScenePos(MainUI:GetSceneType(), cor[1], cor[2]);
  end  

  --直接寻路到传送点
  local pos = Vector2(x, y);

  TaskFindPathPanel:Show();
  
  --通知服务器移动到指定位置
  local msg = {};
  msg.uid = ActorManager.user_data.uid;
  msg.sceneid = ActorManager.user_data.sceneid;
  msg.x = math.floor(pos.x);
  msg.y = math.floor(pos.y);
  Network:Send(NetworkCmdType.nt_move, msg, true);

  ActorManager.hero:MoveTo(pos);
end

--获取当前主线任务ID
function Task:getMainTaskId()
  local mainTaskId = 0;
  local task = self.mainTask;  
  if nil ~= task then
    mainTaskId = task['id'];
    --第一个任务未接之前设置为0
    if FirstTaskId == mainTaskId and task.step == self.TaskUnreceive then
      return 0;
    end
  end
  return mainTaskId;
end

--获取已接当前主线任务ID
function Task:getReceiveMainTaskId()
  local mainTaskId = 0;
  local task = self.mainTask;  
  if nil ~= task then
    mainTaskId = task['id'];
    --第一个任务未接之前设置为0
    if FirstTaskId == mainTaskId and task.step == self.TaskUnreceive then
      return 0;
    end
    --当前任务未接，则返回前一个主线任务ID
    if task.step == self.TaskUnreceive then
      mainTaskId = mainTaskId - 1;
    end
  end
  return mainTaskId;
end

--主线任务是否为系统任务
function Task:isSystemTask()
  local task = self.mainTask;  
  if TaskType.system == task['type'] then
    return true;
  else
    return false;
  end
end

--任务是否已接
function Task:isTaskReceived(taskid)
  local mainTaskId = 0;
  local task = self.mainTask;  
  if nil ~= task then
    mainTaskId = task['id'];
    
    --第一个任务未接之前设置为0
    if mainTaskId > taskid or (mainTaskId == taskid and task.step ~= self.TaskUnreceive) then
      return true;
    end
  end
  return false;
end

function Task:getTaskNum()
	return getDailyTaskNum, allDailyTaskNum;
end

--获取剩余任务数及可获得经验
function Task:getLeftTaskInfo()
	return tostring(leftDailyTaskNum), tostring(leftDailyTaskExp);
end


--更改任务状态
function Task:updateDailytask()
  for _, dt in pairs(Task.dailyTask) do
	  local data = resTableManager:GetValue(ResTable.daily_task, tostring(dt.resid), {'openlv', 'times', 'sort'});
		if dt.step >= data['times'] then
		  dt.weight = 3;
		elseif ActorManager.user_data.role.lvl.level >= data['openlv'] then
		  dt.weight = 2;
		else
		  dt.weight = 1;
		end
	  Task:UpdateMainSceneUI();
  end
end
