--userGuide.lua

--========================================================================
--新手引导类

--英灵殿的新手引导英雄
UserGuideHero = {
	{{resid=5010,hired=false,potential=1,rare=1,atk=0,mgc=155,def=72,res=115,hp=520,cri=300,acc=50,dodge=50,fp=650,old=0},
    {resid=5012,hired=false,potential=1,rare=1,atk=0,mgc=157,def=96,res=108,hp=520,cri=300,acc=50,dodge=50,fp=656,old=0},
    {resid=2044,hired=false,potential=1,rare=1,atk=144,mgc=0,def=73,res=87,hp=560,cri=150,acc=180,dodge=100,fp=674,old=0},
    {resid=5011,hired=false,potential=1,rare=1,atk=148,mgc=0,def=62,res=86,hp=560,cri=150,acc=180,dodge=100,fp=672,old=0}},	
	{{resid=5001,hired=false,potential=1,rare=1,atk=218,mgc=0,def=142,res=105,hp=960,cri=150,acc=150,dodge=150,fp=670,old=0},
	{resid=2104,hired=false,potential=1,rare=4,atk=240,mgc=0,def=480,res=480,hp=2400,cri=60,acc=350,dodge=360,fp=1529,old=0},
    {resid=5006,hired=false,potential=1,rare=1,atk=218,mgc=0,def=142,res=105,hp=960,cri=150,acc=150,dodge=150,fp=693,old=0},
    {resid=2064,hired=false,potential=1,rare=1,atk=218,mgc=0,def=142,res=105,hp=960,cri=150,acc=150,dodge=150,fp=665,old=0}}
}

FirstArenaFight = {target_data="{\"uid\":3034,\"name\":\"" .. LANG_userGuide_1 .. "\",\"roles\":{\"1\":{\"pid\":0,\"resid\":1005,\"skls\":[{\"skid\":1,\"resid\":411,\"level\":1},{\"skid\":2,\"resid\":522,\"level\":1}],\"equips\":{\"1\":{\"eid\":1,\"resid\":16011,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"2\":{\"eid\":2,\"resid\":16012,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"3\":{\"eid\":3,\"resid\":16013,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"4\":{\"eid\":4,\"resid\":16017,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"5\":{\"eid\":5,\"resid\":16018,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true}},\"pro\":{\"hp\":1232,\"atk\":0,\"def\":163,\"mgc\":296,\"res\":203,\"cri\":360,\"acc\":300,\"dodge\":50,\"fp\":1189,\"power\":200},\"lvl\":{\"level\":1,\"exp\":0},\"quality\":0,\"potential\":0},\"2\":{\"pid\":5,\"resid\":5009,\"skls\":[{\"skid\":12,\"resid\":521,\"level\":1},{\"skid\":11,\"resid\":411,\"level\":1}],\"equips\":{\"1\":{\"eid\":33,\"resid\":16011,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"2\":{\"eid\":34,\"resid\":16012,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"3\":{\"eid\":35,\"resid\":16013,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"4\":{\"eid\":36,\"resid\":16017,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"5\":{\"eid\":37,\"resid\":16018,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true}},\"pro\":{\"hp\":2561,\"atk\":4,\"def\":304,\"mgc\":414,\"res\":364,\"cri\":360,\"acc\":300,\"dodge\":50,\"fp\":1545,\"power\":200},\"lvl\":{\"level\":1,\"exp\":0},\"quality\":0,\"potential\":2},\"3\":{\"pid\":6,\"resid\":5014,\"skls\":[{\"skid\":14,\"resid\":531,\"level\":1},{\"skid\":13,\"resid\":411,\"level\":1}],\"equips\":{\"1\":{\"eid\":38,\"resid\":16011,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"2\":{\"eid\":39,\"resid\":16012,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"3\":{\"eid\":40,\"resid\":16013,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"4\":{\"eid\":41,\"resid\":16017,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true},\"5\":{\"eid\":42,\"resid\":16018,\"gresids\":[0,0,0],\"strenlevel\":0,\"isweared\":true}},\"pro\":{\"hp\":2561,\"atk\":4,\"def\":304,\"mgc\":414,\"res\":364,\"cri\":360,\"acc\":300,\"dodge\":50,\"fp\":1545,\"power\":200},\"lvl\":{\"level\":1,\"exp\":0},\"quality\":0,\"potential\":2}}}",rseed=13250,is_win=true,money=0,battlexp=50}
FirstArenaInfo = {targets={{uid=1055,resid=1003,rank=2001,name=LANG_userGuide_2,level=13,fp=1107},
				{uid=1062,resid=1006,rank=2002,name=LANG_userGuide_3,level=13,fp=1107},
				{uid=1063,resid=1005,rank=2003,name=LANG_userGuide_4,level=14,fp=1103},
				{uid=1064,resid=1002,rank=2004,name=LANG_userGuide_5,level=14,fp=1127},
				{uid=1065,resid=1005,rank=2005,name=LANG_userGuide_6,level=15,fp=1259}},
				records={},fight_count=10,rank=2006};


UserGuide =
	{
	};

--新手引导系统任务处理
function UserGuide:systemTask( taskid )
	if SystemTaskId.partner == taskid then	
		Network:Send(NetworkCmdType.req_guidence_partner, {});
	elseif SystemTaskId.changeName == taskid then
		UserGuideRenamePanel:onShow();
	else
	end
end

--请求宝石
function UserGuide:requestGem(taskid)
	local wait = false
	if SystemTaskId.getGem == taskid then
		Network:Send(NetworkCmdType.req_guidence_gemstone, {}, true);
		wait = true;
	end
	return wait;
end

--[[--请求精灵洗礼
function UserGuide:requestRefine(taskid)
	local wait = false
	if SystemTaskId.getRefine == taskid then
		Network:Send(NetworkCmdType.req_guidence_refine, {}, true);
		wait = true;
	end
	return wait;
end

--获取宝石，继续提交任务
function UserGuide:getGem(msg)
	TaskDialogPanel:requestCommitTask();
end

--获取精灵洗礼，继续提交任务
function UserGuide:getRefine(msg)
	TaskDialogPanel:requestCommitTask();
end
--]]

--新手引导送伙伴
function UserGuide:onOfferPartner( msg )
	ActorManager:AddRole(msg.partner);
	--赠送界面
	UserGuidePartnerPanel:onShowPartner(msg.partner.resid);	
	
	--向服务器发送统计数据
	NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 2);
end

--新手系统设置角色名
function UserGuide:onSetHeroName( msg )
	--重命名后处理
	UserGuideRenamePanel:AfterRename();

	--自动提交任务
	self:CommitSystemTask();
	
	--向服务器发送统计数据
	NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 2);
end

--随机生成一个名字
function UserGuide:onRandomName( msg )
	local name = '';
	if nil ~= msg or nil ~= msg.name then
		name = msg.name;
	end
	UserGuideRenamePanel:onRandomName(name);
end

--提交系统任务，系统任务不需要寻路到NPC，由新手引导操作完成提交
--并保持标示位，防止任务提交失败时可以重新提交
--在关闭时提交，可以避免NPC有别的任务时提前弹出
function UserGuide:CommitSystemTask()
	if not Task:isSystemTask() then
		return;
	end
	local taskid = Task:getMainTaskId();
	local msg = {};
	msg.resid = taskid;
	Network:Send(NetworkCmdType.req_commit_task, msg);
	--发送统计信息
	NetworkMsg_GodsSenki:SendStatisticsData(taskid, 2);
	if SystemTaskId.step1 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step1);
	elseif SystemTaskId.step2 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step2);
	elseif SystemTaskId.step3 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step3);
	elseif SystemTaskId.step4 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step4);
	elseif SystemTaskId.step5 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step5);
	elseif SystemTaskId.step6 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step6);
	elseif SystemTaskId.step7 == taskid then
		ActorManager:SetGuidStepDone(GuideStep.step7);
	end
end

--验证系统任务，如果操作完成，则提交任务
--如果操作未完成，继续执行操作
function UserGuide:ValidateSystemTask()
	UserGuidePanel:SetInGuiding(false);
	if not Task:isSystemTask() then
		return;
	end

	local task = Task.mainTask;	
	local taskid = task['id'];
	
	--未接，按正常流程走
	if Task.TaskUnreceive == task.step then	
		return;
	end
	print("afafafafaf", taskid);
	--已接，并已完成操作，直接提交
	if  (SystemTaskId.step1 == taskid and ActorManager:IsGuidStepDone(GuideStep.step1)) or 
		(SystemTaskId.step2 == taskid and ActorManager:IsGuidStepDone(GuideStep.step2)) or 
		(SystemTaskId.step3 == taskid and ActorManager:IsGuidStepDone(GuideStep.step3)) or
		(SystemTaskId.step4 == taskid and ActorManager:IsGuidStepDone(GuideStep.step4)) or
		(SystemTaskId.step5 == taskid and ActorManager:IsGuidStepDone(GuideStep.step5)) or 
		(SystemTaskId.step6 == taskid and ActorManager:IsGuidStepDone(GuideStep.step6)) or 
		(SystemTaskId.step7 == taskid and ActorManager:IsGuidStepDone(GuideStep.step7))  then

		local msg = {};
		msg.resid = taskid;
		Network:Send(NetworkCmdType.req_commit_task, msg);		
	else
		--已接，未完成，按钮恢复，重新做一遍
		MenuPanel:InitMenu();
		self:systemTask(taskid);
	end	
end
