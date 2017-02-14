--networkMsg_Trial.lua

--======================================================================
--试练

NetworkMsg_Trial = 
	{
	};


--显示试炼场或试炼任务
function NetworkMsg_Trial:onTrialInfo(msg)
	if nil ~= msg and nil ~= msg.trial and nil ~= msg.trial.current_stage then
		if TrialStatus.notask == msg.trial.current_stage then
			TrialFieldPanel.current_stage = TrialStatus.notask;
			TrialFieldPanel:onShowTrialField(msg);
		elseif TrialStatus.task == msg.trial.current_stage then
			TrialFieldPanel.current_stage = TrialStatus.task;
			TrialFieldPanel.taskList = msg.trial.tasks;
			TrialTaskPanel:onShowTrialTask(msg);
		elseif TrialStatus.failFight == msg.trial.current_stage then
			local failmsg = {};
			failmsg.battle_win = 0;  --上次没完成，表示失败
			Network:Send(NetworkCmdType.req_trial_end_batt, failmsg);  --通知上次战斗失败
			--返回试炼场时显示信息
			TrialFieldPanel.taskList = msg.trial.tasks;
			TrialTaskPanel:onShowTrialTask(msg);
		end
	end
end

--试炼场刷新任务
function NetworkMsg_Trial:onTrialRefreshTasks(msg)
	TrialFieldPanel:onRefreshTasks(msg);
end

--返回试炼场接任务
function NetworkMsg_Trial:onTrialTaskInfo(msg)
	TrialTaskPanel:onLauchTrialTask(msg);
end

--试炼任务刷新对手
function NetworkMsg_Trial:onTrialRefreshTargets(msg)
	TrialTaskPanel:onRefreshTargerts(msg);
end

--放弃试炼任务
function NetworkMsg_Trial:onGiveupTrial()
	TrialTaskPanel:onGiveupTrialTask();
end

--试炼领取奖励
function NetworkMsg_Trial:onGetReward(msg)
	TrialTaskPanel:onGetReward(msg);
end

--试炼结束挑战
function NetworkMsg_Trial:onTrialEndFight()
	TrialTaskPanel:onTrialEndFight();
end

--通知活力改变
function NetworkMsg_Trial:onEnergyChange(msg)
	TrialFieldPanel:onEnergyChange(msg);
end

--每小时活力增长
function NetworkMsg_Trial:onGenEnergy(msg)
	TrialFieldPanel:onGenEnergy(msg);
end

--试炼挑战
local trialTimer = -1;
function NetworkMsg_Trial:onTrialTargetFight( msg )
	if nil ~= msg and nil ~= msg.target_data then	
		local enemy = cjson.decode(msg.target_data);
		local tmp = {}
	    for strIndex,role in pairs(enemy.roles) do
		    tmp[tonumber(strIndex)] = {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl};
	    end	

		FightManager:Initialize(FightType.trial, tmp);
		FightManager:SetZhanli(msg.battlexp);
		
		--预加载声音资源
		FightManager:PreLoadSoundResource();
		
		trialTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Trial:onRealTrialFight', 0);
		Loading:SetProgress(60);
	end
end

function NetworkMsg_Trial:onRealTrialFight()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end	

	timerManager:DestroyTimer(trialTimer);
	trialTimer = -1;
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
end

--购买活力成功
function NetworkMsg_Trial:onRetBuyEnergy()
	
end
