--taskPanel.lua
--==========================================================================================
--剧情面板(任务)

PlotTaskPanel = 
{
};

local mainDesktop;
local list;
local tasksView;
local list2;
local tasksView2;
local imgBackground;
local list3;
local tasksView3;
local list4;
local tasksView4;

local selectFont;
local unselectFont;
local curindex = 0;

local returnbtn;

--初始化面板
function PlotTaskPanel:InitPanel(destop)
	mainDesktop = destop;
	plotTaskPanel = Panel(destop:GetLogicChild('TaskPanel1'));
	plotTaskPanel :IncRefCount();
	plotTaskPanel.ZOrder = PanelZOrder.task;

    list = TouchScrollPanel(plotTaskPanel:GetLogicChild('taskListClip'));
	tasksView = StackPanel(list:GetLogicChild('taskList'));
    list2 = TouchScrollPanel(plotTaskPanel:GetLogicChild('taskListClip2'));
	tasksView2 = StackPanel(list2:GetLogicChild('taskList'));
	list3 = TouchScrollPanel(plotTaskPanel:GetLogicChild('taskListClip3'));
	tasksView3 = StackPanel(list3:GetLogicChild('taskList'));
	list4 = TouchScrollPanel(plotTaskPanel:GetLogicChild('taskListClip4'));
	tasksView4 = StackPanel(list4:GetLogicChild('taskList'));
	returnbtn = plotTaskPanel:GetLogicChild('returnBtn');

	--字体
	selectFont = uiSystem:FindFont('FZ_24_miaobian_R193G155B23');
	unselectFont = uiSystem:FindFont('FZ_24_miaobian_R7G46B75');	

	self:ApplyData();
	self:ApplyAchievementData();
end

--显示
function PlotTaskPanel:Show()
	MainUI:IncCount();
	plotTaskPanel:GetLogicChild('bg').Background = CreateTextureBrush('background/default_bg.jpg', 'background');
	self:TipCheck();
	self:RefreshDailyTask();
	plotTaskPanel.Visibility = Visibility.Visible

	StoryBoard:ShowUIStoryBoard(plotTaskPanel, StoryBoardType.ShowUI1);
	returnbtn:SubscribeScriptedEvent('Button::ClickEvent', 'PlotTaskPanel:onClose');
	brush_top = plotTaskPanel:GetLogicChild('brush_top');
  	brush_top.Background = CreateTextureBrush('chouka/brush_top.ccz', 'chouka');

	plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('1_btn').Selected = true;
end

function PlotTaskPanel:onEnterPlotTaskPanel()
  if FriendListPanel:IsVisible() then FriendListPanel:onClose() end
  if ChatPanel:IsShow() then ChatPanel:Hide() end
  self:Show()
  GodsSenki:LeaveMainScene()
end

function PlotTaskPanel:onLeavePlotTaskPanel()
  self:Hide()
  GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function PlotTaskPanel:onShow()
	self:onEnterPlotTaskPanel()
	self:Show();	
	if UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) then
		plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('3_btn').Selected = true;
	end
end

--当不选中时的事件
function PlotTaskPanel:UnselectPub(Args)
	local args = UIControlEventArgs(Args);
	--字体
	args.m_pControl:GetLogicChild('label').Font = unselectFont;
end


function PlotTaskPanel:Hide()
	MainUI:DecCount();
	plotTaskPanel.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(plotTaskPanel, StoryBoardType.HideUI1, 'PlotTaskPanel:onDestroy')
end

function PlotTaskPanel:onClose()
	MainUI:DecCount();
	self:Hide();
	return GodsSenki:BackToMainScene(SceneType.HomeUI);
end

function PlotTaskPanel:onDestroy()
	plotTaskPanel:GetLogicChild('bg').Background = nil;
	DestroyBrushAndImage('background/default_bg.jpg', 'background');
end

function PlotTaskPanel:Destroy()
	plotTaskPanel:DecRefCount();
	plotTaskPanel = nil;
end

--申请每日任务信息
function PlotTaskPanel:ApplyData()
	Network:Send(NetworkCmdType.req_act_task, {});
end

--申请成就任务信息
function PlotTaskPanel:ApplyAchievementData()
	Network:Send(NetworkCmdType.req_achievement_task, {});
end

function PlotTaskPanel:RefreshDailyTask()
	curindex = TaskIndex.daily;
	plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('1_btn'):GetLogicChild('label').Font = selectFont;
	if ActorManager.user_data.role.lvl.level < FunctionFirstClickOpen.dailyTask then
		MessageBox:ShowDialog(MessageBoxType.Ok, string.format(LANG_plotTaskPanel_10, FunctionFirstClickOpen.dailyTask));
		return ;
	end
	list.Visibility = Visibility.Hidden;
	list2.Visibility = Visibility.Visible;
	list3.Visibility = Visibility.Hidden;
	list4.Visibility = Visibility.Hidden;
	tasksView2:RemoveAllChildren();
	table.sort(Task.dailyTask, function(a_, b_)
		if a_.weight > b_.weight then
			return true;
		elseif a_.weight < b_.weight then
			return false;
		else
			if a_.weight > 1 and b_.weight > 1 then
				return a_.sort < b_.sort;
			else
				return a_.openlv < b_.openlv;
			end

		end
	end);
	for _, task in pairs(Task.dailyTask) do
		if task.collect ~= 1 and task.sort ~= -1 then
			local item = customUserControl.new(tasksView2, 'TaskTemplate');
			item.initDailyTask(task.resid, task.step);
		end
	end
	list2.VScrollPos = 0;
end

function PlotTaskPanel:RefreshAchievementTask(index)
	
	list.Visibility = Visibility.Hidden;
	list2.Visibility = Visibility.Hidden;
	if index == 1 then
		curindex = TaskIndex.grow;
		list3.Visibility = Visibility.Visible;
		list4.Visibility = Visibility.Hidden;
		tasksView3:RemoveAllChildren();
		tasksView3.VScrollPos = 0;
		plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('3_btn'):GetLogicChild('label').Font = selectFont;
	else
		curindex = TaskIndex.peiyang;
		list4.Visibility = Visibility.Visible;
		list3.Visibility = Visibility.Hidden;
		tasksView4:RemoveAllChildren();
		tasksView4.VScrollPos = 0;
		plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('4_btn'):GetLogicChild('label').Font = selectFont;
	end
	table.sort(Task.achievement, function(a_, b_)
		if a_.weight > b_.weight then
			return true;
		elseif a_.weight < b_.weight then
			return false;
		else
			return a_.taskindex < b_.taskindex;
		end
	end);
	for _, task in pairs(Task.achievement) do
		if 1 == task.systype then
			if task.collect ~= 1 and task.sort ~= -1 then
				local item = customUserControl.new(tasksView3, 'TaskTemplate');
				item.initAchievementTask(task.resid, task.step);
			end
		elseif 2 == task.systype then
			if task.collect ~= 1 and task.sort ~= -1 then
				local item = customUserControl.new(tasksView4, 'TaskTemplate');
				item.initAchievementTask(task.resid, task.step);
			end
		end
	end	
end

function PlotTaskPanel:showchengzhangtask()
	 PlotTaskPanel:RefreshAchievementTask(1);
end


function PlotTaskPanel:showpeiyangtask()
	 PlotTaskPanel:RefreshAchievementTask(2);
end

function PlotTaskPanel:showTips(which)
--[[	if which == 1 then
		btnDailyTask:GetLogicChild('cricle').Visibility = Visibility.Visible;
	elseif which == 2 then
		btnPlotTask:GetLogicChild('cricle').Visibility = Visibility.Visible;
	else
		btnDailyTask:GetLogicChild('cricle').Visibility = Visibility.Visible;
		btnPlotTask:GetLogicChild('cricle').Visibility = Visibility.Visible;
	end]]
end

function PlotTaskPanel:hideTips(which)
	--[[if which == 1 then
		btnDailyTask:GetLogicChild('cricle').Visibility = Visibility.Hidden;
	elseif which == 2 then
		btnPlotTask:GetLogicChild('cricle').Visibility = Visibility.Hidden;
	else
		btnDailyTask:GetLogicChild('cricle').Visibility = Visibility.Hidden;
		btnPlotTask:GetLogicChild('cricle').Visibility = Visibility.Hidden;
	end]]
end

function PlotTaskPanel:RefreshPlotTask()
	curindex = TaskIndex.main;
	plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild('2_btn'):GetLogicChild('label').Font = selectFont;
	local tasks = Task.getAllPlotTasks()
	list.Visibility = Visibility.Visible;
	list2.Visibility = Visibility.Hidden;
	list3.Visibility = Visibility.Hidden;
	list4.Visibility = Visibility.Hidden;
	tasksView:RemoveAllChildren();
	for _, task in pairs(tasks) do
		if task['level'] <= Configuration.MaxTaskLevel then
			local item = customUserControl.new(tasksView, 'TaskTemplate');
			item.initPlotTask(task);
		end
	end
	list.VScrollPos = 0;
end

function PlotTaskPanel:onGoToClick(Args)
	self:onClose();
	local args = UIControlEventArgs(Args);		
	local taskid = args.m_pControl.Tag;
	Task:GuideInTaskList(taskid);
end

function PlotTaskPanel:onGetToClick(Args)
	self:onClose();
	local args = UIControlEventArgs(Args);		
	local taskid = args.m_pControl.Tag;
	Task:GuideInTaskList(taskid);
end

function PlotTaskPanel:onGoToDailyClick(Args)
	local level = ActorManager.hero:GetLevel();
	local args = UIControlEventArgs(Args);		
	local tag = args.m_pControl.Tag;
	if self:onClose() then
		return;
	end

	if tag == ActivityDegreeType.barrier then				--任意关卡 (DONE)
		PveBarrierPanel:onEnterPveBarrier();
		FightOverUIManager:setFightOverPopupUI(FightOverPopup.task);
	elseif tag == ActivityDegreeType.strength then			--强化装备
		EquipStrengthPanel:onShow(1)
	elseif tag == ActivityDegreeType.advance then			--装备升阶(技能升级)
		SkillStrPanel:Show();
	elseif tag == ActivityDegreeType.arena then				--竞技场挑(DONE)
		ArenaPanel.flag = 0;
		ArenaPanel:ReqArenaInfo(ArenaPanel.flag);
	elseif tag == ActivityDegreeType.gold then				--炼金(DONE)
		PromotionGoldPanel:onApplyGoldInfo();
	elseif tag == ActivityDegreeType.pub then				--刷新酒馆(DONE)
		ZhaomuPanel:TaskShow()
	elseif tag == ActivityDegreeType.refine then			--洗礼
		HomePanel:onEnterHomePanel(true)
		HomePanel:ListClick()		
		CardListPanel:Show(0, true);   
		CardListPanel:onChangePanel(3)  
	elseif tag == ActivityDegreeType.capTreasure then		--占领宝库(DONE)
		TreasurePanel:onShowTreasure();
	elseif tag == ActivityDegreeType.train then				--使用训练场(吃包子)
		HomePanel:onEnterHomePanel(true)
		--显示列表排序的第二个
		--  这里先对主角的伙伴进行排序，排序规则必须和家界面一样
		local defalutPatner = {};
		local actRoles = {};
		for _, partner in pairs (ActorManager.user_data.partners) do
			if MutipleTeam:isInDefaultTeam(partner.pid) then
				table.insert(defalutPatner, partner)
			else
				table.insert(actRoles, partner)
			end
		end

		local sortFunc = function(a, b)
			if b.pro.fp ~= a.pro.fp then
				return b.pro.fp < a.pro.fp
			else
				return b.pid < a.pid
			end
		end

		table.sort(defalutPatner, sortFunc);
		table.sort(actRoles, sortFunc);
		--  根据homePanel中的ShowRoleInfo函数的参数类型构建参数
		local args = {}
		args.m_pControl = {}
		args.m_pControl.Tag = defalutPatner[1] ~= nil and defalutPatner[1].pid or actRoles[1].pid
		args.m_pControl.TagExt = defalutPatner[1] ~= nil and defalutPatner[1].resid or actRoles[1].resid;
		HomePanel:ShowRoleInfo(args)
		HomePanel:ListClick();
		CardListPanel:Show(args.m_pControl.Tag, true);
	elseif tag == ActivityDegreeType.unionAlter then				--公会祭祀
		MainUI:RequestUnionScene();
	elseif tag == ActivityDegreeType.starSoul then			--刷新星魂
		HomePanel:onEnterHomePanel(true)
		HomePanel:ListClick();		
		CardListPanel:Show(0, true); 
		CardListPanel:onChangePanel(4)      
	elseif tag == ActivityDegreeType.zodiac then			--黄道十二宫(远征)
			ExpeditionPanel:onShow();
	elseif tag == ActivityDegreeType.hunt then				--猎魔（符文系统）
		RunePanel:onShow();
	elseif tag == ActivityDegreeType.miku then				--迷窟(英雄副本)
		PveBarrierPanel:OpenToPage(5001, true);
	elseif tag == ActivityDegreeType.limitRound then		--限时副本(DONE)
		PropertyRoundPanel:onShow();
	elseif tag == ActivityDegreeType.worldBoss then -- world boss(DONE)
		MainUI:onWorldClick();
	elseif tag == ActivityDegreeType.rankfight then		--占领宝库(DONE)
		RankSelectActorPanel:reqEnterRankPanel();
	end
end

function PlotTaskPanel:onGoToAchievementClick(Args)
	local level = ActorManager.hero:GetLevel();
	local args = UIControlEventArgs(Args);		
	local index = args.m_pControl.Tag;
	local taskindex = resTableManager:GetValue(ResTable.achievement_task, tostring(index), 'taskindex');
	if self:onClose() then
		return;
	end
	if taskindex == AchievementDegreeType.parnter then				--拥有伙伴
		MainUI:onYingLingDian();
	elseif taskindex == AchievementDegreeType.strength then			--强化装备
		EquipStrengthPanel:onShow(1)
	elseif taskindex == AchievementDegreeType.lovelv or taskindex == AchievementDegreeType.lovemarried then			--爱恋数量或爱恋等级
		local info = ActorManager.user_data.role;
		for _,roleinfo in ipairs(ActorManager.user_data.partners) do
			if info.lvl.lovelevel == 4 then
				info = roleinfo;
			end
			if roleinfo.lvl.lovelevel > info.lvl.lovelevel and roleinfo.lvl.lovelevel ~= 4 then
				if roleinfo.lovevalue > info.lovevalue then
					info = roleinfo;
				end
			end
		end
		HomePanel:onEnterHomePanel();
		--设置人物详情及背景
		HomePanel:setPartnerInfo(info)
		HomePanel:setNaviInfo(info)
		HomePanel:HideRight();
		LovePanel:onShow(info.pid, function() HomePanel:ShowRight(); end);
	elseif taskindex == AchievementDegreeType.rankup then				--星级数量
		local info = ActorManager.user_data.role;
		local chipNum = 0;
		for _,roleinfo in ipairs(ActorManager.user_data.partners) do
			--判断碎片数量
			local chipId = 30000 + roleinfo.resid;
			local chipItem = Package:GetChip(tonumber(chipId));	
			if chipItem ~= nil and chipItem.count > chipNum then
				info = roleinfo;
				chipNum = chipItem.count;
			end
		end
		--进入家界面
		HomePanel:onEnterHomePanel();
		--进入培养
		HomePanel:ListClick();
		--切换到特定人物
		CardListPanel:Show(info.pid,true);	
		--切换到升星界面
		CardListPanel:onChangePanel(2);
		--切换背景
		HomePanel:setNaviInfo(info);
	end
end

--每日任务点击
function PlotTaskPanel:onGetToDailyClick(Args)
	local args = UIControlEventArgs(Args);		
	local msg = {};
	msg.resid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_act_reward, msg);
end

--成就任务点击
function PlotTaskPanel:onGetToAchievementClick(Args)
	local args = UIControlEventArgs(Args);		
	local msg = {};
	msg.resid = args.m_pControl.Tag;
	msg.systype = args.m_pControl.TagExt;
	Network:Send(NetworkCmdType.req_achievement_reward, msg);
end

--重置日常任务
function PlotTaskPanel:RefreshTaskAt24()
	for _, task in pairs(Task.dailyTask) do
		task.step = 0;
	end
end

--获取奖励返回
function PlotTaskPanel:getReward(data)
	if data['power'] and data['power'] ~= 0 then
		ToastMove:AddGoodsGetTip(10005, data['power']);
	end
	if data['coin'] and data['coin'] ~= 0 then
		ToastMove:AddGoodsGetTip(10001, data['coin']);
	end
	if data['diamond'] and data['diamond'] ~= 0 then
		ToastMove:AddGoodsGetTip(10003, data['diamond']);
	end
	if data['exp'] and data['exp'] ~= 0 then
		ToastMove:AddGoodsGetTip(10011, data['exp']);
	end
	if data['reward'] and next(data['reward']) then
		for _, r in ipairs(data['reward']) do
			if not ActivityRechargePanel:isInMidAutumnActivity() and r[1] == 16018 then
			else
				ToastMove:AddGoodsGetTip(r[1], r[2]);
			end
		end
	end
	if data['item_id'] and next(data['item_id']) then
		for _, r in ipairs(data['item_id']) do
			if not ActivityRechargePanel:isInMidAutumnActivity() and r[1] == 16018 then
			else
				ToastMove:AddGoodsGetTip(r[1], r[2]);
			end
		end
	end
	PlotTaskPanel:ApplyData();
	PlotTaskPanel:ApplyAchievementData();
	if UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) then
		UserGuidePanel:ShowGuideShade( returnbtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.dailytask);
		UserGuidePanel:SetInGuiding(false)
	end

	--领取奖励动画
	local path = GlobalData.EffectPath .. 'renwuwancheng_2_output/'
	AvatarManager:LoadFile(path)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI.Pick = false
	armatureUI.Margin = Rect(0,100,0,0)
	armatureUI.Horizontal = ControlLayout.H_CENTER
	armatureUI.Vertical = ControlLayout.V_TOP
	armatureUI:LoadArmature('renwuwancheng_2')
	armatureUI:SetAnimation('play')
	armatureUI.ZOrder = 100000
	topDesktop:AddChild(armatureUI)
end

function PlotTaskPanel:checktaskindex(index)
	plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild( index .. '_btn').Selected = true;
end

function PlotTaskPanel:getcurindex()
	return curindex;
end
function PlotTaskPanel:TipCheck()
	local dailytaskFlag = false;
	local achievementOneFlag = false;
	local achievementTwoFlag = false;
	local plotTaskFlag = false;

	local getTipFlag = function(tabelId,taskList,task)
		local tipFlag = false;
		if task.collect ~= 1 and task.sort ~= -1 then
			local data = resTableManager:GetRowValue(tabelId, tostring(task.resid));
			local collected = false;
			for _, dt in pairs(taskList) do
				if dt.resid == task.resid and dt.collect == 1 then
					collected = true;
				end
			end
			if not (ActorManager.user_data.role.lvl.level < data['openlv'] or task.step < data['times'] or collected) then
				tipFlag = true;
			end
		end
		return tipFlag;
	end

	--每日任务 btn1
	for _, task in pairs(Task.dailyTask) do
		if getTipFlag(ResTable.daily_task,Task.dailyTask,task) then
			dailytaskFlag = true;
			break;
		end
	end
	self:updataTip(1,dailytaskFlag);

	--主线任务
	for _,task in pairs(Task.getAllPlotTasks()) do
		if Task:isComplete(task) then
			plotTaskFlag = true;
			break;
		end
	end
	self:updataTip(2,plotTaskFlag);

	--收集任务
	for _, task in pairs(Task.achievement) do
		if 1 == task.systype then
			if getTipFlag(ResTable.achievement_task,Task.achievement,task) then
				achievementOneFlag = true;
				break;
			end 
		end
	end
	self:updataTip(3,achievementOneFlag); 

	--成长任务
	for _, task in pairs(Task.achievement) do
		if 2 == task.systype then
			if getTipFlag(ResTable.achievement_task,Task.achievement,task) then
				achievementTwoFlag = true;
				break;
			end 
		end
	end	
	self:updataTip(4,achievementTwoFlag); 
end
function  PlotTaskPanel:updataTip(index,cricleIsShow)
	plotTaskPanel:GetLogicChild('topBtnPanel'):GetLogicChild(index..'_btn'):GetLogicChild('cricle').Visibility = 
	cricleIsShow and Visibility.Visible or Visibility.Hidden;
end
