--eventTask.lua

--========================================================================
--任务
--========================================================================

--任务数据初始化完成后
function Event:OnTaskInitFinished()
	MenuPanel:InitMenu();
end

--接主线任务
function Event:OnGetMainTask( taskid )
	
	if false == PlotManager:TriggerPlot(EventType.GetMainTask, taskid) then
		TaskDialogPanel:AfterGetTask();
	end

end	

--交主线任务后
function Event:OnCommitMainTask( taskid )
	
	if false == PlotManager:TriggerPlot(EventType.CommitMainTask, taskid) then
		
		--新手引导结束，触发新功能开启
		local trig = true;
		if taskid == MenuOpenLevel.guidEnd then
		else
			--增加触发功能开启检测
			local hero = ActorManager.hero;
		end
	end

	if not UserGuidePanel:GetIsLvUp() then
		TaskDialogPanel:AfterCommitTask(taskid);
	else
		UserGuidePanel:SetIsLvUp(false)
	end	
end
