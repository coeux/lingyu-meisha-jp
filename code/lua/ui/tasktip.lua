--tasktip.lua
--=============================================
--任务提示面板
TaskTipPanel = 
{
}

local tippanel;
local btn;
local mainDesktop;
local out = true;
local name;
local task;
local panel;
local arm;
local arm1;
local biankuang;

local GetGoNone;

function TaskTipPanel:InitPanel(desktop)
	GetGoNone = 3;

	mainDesktop = desktop;
	tippanel = desktop:GetLogicChild('taskTipPanel');
	tippanel:IncRefCount();
	name = tippanel:GetLogicChild('namePanel'):GetLogicChild('name');
	task = tippanel:GetLogicChild('task');
	panel = tippanel:GetLogicChild('panel');
	btn = tippanel:GetLogicChild('btn');
	btn:SubscribeScriptedEvent('Button::ClickEvent', 'TaskTipPanel:onClick');
	panel:SubscribeScriptedEvent('Button::ClickEvent', 'TaskTipPanel:onAuto');
	tippanel.Storyboard = 'storyboard.taskTipIn';
	tippanel.Visibility = Visibility.Visible;
	self:RefreshArmature()
end

--显示
function TaskTipPanel:Show()
  mainDesktop:DoModal(tippanel);
end

function TaskTipPanel:onShow()
	tippanel.Visibility = Visibility.Visible;
	if FightType.noviceBattle  == FightManager:GetFightType() then
	end
end

function TaskTipPanel:Hide()
	tippanel.Visibility = Visibility.Hidden;
end

function TaskTipPanel:getUserGuideBtn()
	return panel;
end

function TaskTipPanel:Destroy()
  tippanel:DecRefCount();
  tippanel = nil;
end

function TaskTipPanel:Refresh()
	local t = Task:getAllPlotTasks()[1];
	if t['task_class'] == TaskClass.main then
		--name.Text = t['name'] .. LANG_taskTipPanel_1;
		name.Text = LANG_taskTipPanel_9;
	else
		--name.Text = t['name'] .. LANG_taskTipPanel_2;
		name.Text = LANG_taskTipPanel_9;
	end

	if t['level'] > Configuration.MaxTaskLevel then
		name.Text = LANG_taskTipPanel_10;
		task.Text = LANG_taskTipPanel_8;	
		GetGoNone = 3;
	elseif ActorManager.user_data.role.lvl.level < t['level'] then
		name.Text = string.format(LANG_taskTipPanel_4, t['level']);
		task.Text = LANG_taskTipPanel_8;
		GetGoNone = 3;
	elseif Task:isComplete(t) then
		task.Text = string.format(LANG_taskTipPanel_5, resTableManager:GetValue(ResTable.npc, tostring(t['quest_finish']), 'name'));
		GetGoNone = 1;
	elseif t.step == Task.TaskUnreceive then
		task.Text = string.format(LANG_taskTipPanel_5, resTableManager:GetValue(ResTable.npc, tostring(t['quest_get']), 'name'));
		GetGoNone = 1;
	elseif TaskType.dialog == t['type'] then
		task.Text = string.format(LANG_taskTipPanel_5, resTableManager:GetValue(ResTable.npc, tostring(t['quest_get']), 'name'));
		GetGoNone = 1;
	elseif TaskType.barrier == t['type'] then
		task.Text = string.format(LANG_taskTipPanel_6, resTableManager:GetValue(ResTable.barriers, tostring(t['value'][1]), 'name'), t.step, t['value'][2]);
		GetGoNone = 2;
	elseif TaskType.monster == t['type'] then
		task.Text = string.format(LANG_taskTipPanel_7, resTableManager:GetValue(ResTable.monster, tostring(t['value'][1]), 'name'), t.step, t['value'][2]);
		GetGoNone = 2;
	end
	panel.Tag = t['id'];
	--[[
	arm = tippanel:GetLogicChild('ar');
  local path = GlobalData.AnimationPath .. 'P101_output/';
  AvatarManager:LoadFile(path);
  arm:LoadArmature('P101');
  arm:SetAnimation(AnimationType.idle);
	--]]
	self:RefreshArmature()
end
function TaskTipPanel:RefreshArmature()
	if ActorManager.user_data.role.lvl.level <= 20 then
		arm = tippanel:GetLogicChild('panel'):GetLogicChild('armature');
		arm:LoadArmature('renwu_1');
		arm:SetAnimation('play');
	
	elseif ActorManager.user_data.role.lvl.level <= 20 then
		arm = tippanel:GetLogicChild('panel'):GetLogicChild('armature');
		arm:LoadArmature('renwu_2');
		arm:SetAnimation('play');
	--	arm1 = tippanel:GetLogicChild('panel'):GetLogicChild('armature2');
	--	arm1:LoadArmature('xinshoujiantou');
	--	arm1:SetAnimation('play');
	else
		if arm ~= nil then
			arm:Destroy();
		end
	end
end
function TaskTipPanel:onClick()	
	if out then
		out = false;
		local sb = tippanel:SetUIStoryBoard("storyboard.taskTipOut");
		sb:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', 'TaskTipPanel:Revert');
	else
		out = true;
		local sb = tippanel:SetUIStoryBoard("storyboard.taskTipIn");		
		sb:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', 'TaskTipPanel:Revert');
		self:Refresh();
	end
end
--  旷世大战结束
function TaskTipPanel:getPanel(  )
	return panel
end

function TaskTipPanel:onAuto(Args)
	local t = Task:getAllPlotTasks()[1];
	local args = UIControlEventArgs(Args);		
	local taskid = args.m_pControl.Tag;
	if GetGoNone == 1 or GetGoNone == 2 then
		Task:GuideInTaskList(taskid);
	elseif GetGoNone == 3 then
		PlotTaskPanel:onShow();
	elseif ActorManager.user_data.role.lvl.level < t['level'] then
		PlotTaskPanel:onShow();
	end
--	self:onClick();
end

function TaskTipPanel:Revert()
	if out then 
		btn:SetScale(1, 1);
		if ActorManager.user_data.role.lvl.level <= 20 then
			arm = tippanel:GetLogicChild('panel'):GetLogicChild('armature');
			arm:LoadArmature('renwulan');
			arm:SetAnimation('play');
		--	arm1 = tippanel:GetLogicChild('panel'):GetLogicChild('armature2');
		--	arm1:LoadArmature('xinshoujiantou');
		--	arm1:SetAnimation('play');

		end
	else 	
		btn:SetScale(-1, 1); 
		if arm then
			arm:Destroy();
		end
	end
end

function TaskTipPanel:settasktiparm(flag)
	if ActorManager.user_data.role.lvl.level <= 20 then
		if flag and arm then
			arm.Visibility = Visibility.Visible;
		elseif arm then
			arm.Visibility = Visibility.Hidden;
		end
	end
end

