--taskAcceptAndRewardPanel.lua

--========================================================================
--ÈÎÎñ½ÓÊÜºÍ½±ÀøÀà
--
TaskAcceptAndRewardPanel =
{
	task = nil;
	isTaskAndRewardOpen = false;
};

--±äÁ¿
local needFlyItems;
--¿Ø¼þ
local mainDesktop;
local panel;
local lblFinish;
local lblAccept;
local btnOk;
local btnGo;
local lblName;
local lblContent;
local lblExp;
local lblCoin;
local rewardPanel;
local expPanel;
local coinPanel;


--³õÊ¼»¯
function TaskAcceptAndRewardPanel:InitPanel(desktop)
	--±äÁ¿³õÊ¼»¯
	--¿Ø¼þ³õÊ¼»¯
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('acceptPanel'));
	panel:IncRefCount();
	panel.ZOrder = PanelZOrder.accept;

	lblFinish = Label(panel:GetLogicChild('finish'));
	lblAccept = Label(panel:GetLogicChild('succeed'));
	btnOk = Button(panel:GetLogicChild('btnSure'));
	btnGo = Button(panel:GetLogicChild('btnAdvance'));
	lblName = Label(panel:GetLogicChild('taskName'));
	lblContent = Label(panel:GetLogicChild('taskInfoLabel'));
	rewardPanel = StackPanel(panel:GetLogicChild('rewardPanel'));
	expPanel = Panel(panel:GetLogicChild('reward'):GetLogicChild('expPanel'));
	lblExp = Label(expPanel:GetLogicChild('expNum'));
	coinPanel = Panel(panel:GetLogicChild('reward'):GetLogicChild('coinPanel'));
	lblCoin = Label(coinPanel:GetLogicChild('goldNum'));
	btnOk:SubscribeScriptedEvent('Button::ClickEvent', 'TaskAcceptAndRewardPanel:Disappear');
	btnGo:SubscribeScriptedEvent('Button::ClickEvent', 'TaskAcceptAndRewardPanel:onGo');

end

--ÏÔÊ¾ÁìÈ¡ÈÎÎñ
function TaskAcceptAndRewardPanel:AcceptTask(task)
	--新手引导特殊处理
	if Task:getMainTaskId() <= 100002 then
		Task.currentNpc = 116;
		TaskDialogPanel:onShowDialog()
		return
	end

	self:Show();
	--MainUI:Push(self);
	self.task = task;
	self:ShowReward(true);
end

--ÏÔÊ¾Íê³ÉÈÎÎñ
function TaskAcceptAndRewardPanel:FinishTask(task)
	self:Show();
	--MainUI:Push(self);
	self.task = task;
	self:ShowReward(false);
end

--ÏÔÊ¾½±Àø
function TaskAcceptAndRewardPanel:ShowReward(isAccept)
	local data = resTableManager:GetValue(ResTable.task, tostring(self.task['id']), {'name', 'description', 'exp', 'coin', 'diamond', 'item_id'});
	lblName.Text = data['name'];
	lblContent.Text = data['description'];
	local v, h = Visibility.Visible, Visibility.Hidden;

	if data['exp'] == 0 then
		expPanel.Visibility = h;
	else
		expPanel.Visibility = v;
		lblExp.Text = tostring(data['exp']);
	end
	if data['coin'] == 0 then
		coinPanel.Visibility = h;
	else 
		coinPanel.Visibility = v;
		lblCoin.Text = tostring(data['coin']);
	end
	needFlyItems = {};
	rewardPanel:RemoveAllChildren();
	local numSize = 0;
	if data['item_id'] then	
		for _, item in ipairs(data['item_id']) do
			local itemPanel = uiSystem:CreateControl('Panel');
			itemPanel.Size = Size(75,75);
			local itemT = customUserControl.new(itemPanel, 'itemTemplate');
			itemT.initWithInfo(item[1],item[2],75,true);
			rewardPanel:AddChild(itemPanel);
			table.insert(needFlyItems, self:CopyItem(item, _));
			numSize = numSize + 1;
		end
	end
	if numSize > 0 then
		rewardPanel.Size = Size(75*numSize+20*(numSize-1),75);
	end

	local effect = PlayEffectLT('renwuwancheng_output/', Rect(lblAccept:GetAbsTranslate().x  + lblAccept.Width * 0.5 - 10 , lblAccept:GetAbsTranslate().y - 30, 0, 0), 'renwuwancheng');
	effect:SetScale(2, 2);
	lblAccept.Visibility = isAccept and v or h;
	lblFinish.Visibility = isAccept and h or v;
	btnOk.Visibility = isAccept and h or v;
	btnGo.Visibility = isAccept and v or h;
end

--¿½±´¿Ø¼þ
function TaskAcceptAndRewardPanel:CopyItem(item, i)
	local itemPanel = uiSystem:CreateControl('Panel');
	itemPanel.Size = Size(90,90);
	local itemT = customUserControl.new(itemPanel, 'itemTemplate');
	itemT.initWithInfo(item[1],item[2],90,true);
	itemPanel.Visibility = Visibility.Hidden;
	mainDesktop:AddChild(itemPanel);
	return itemPanel;
end

--========================================================================================================
--·ÉÈë±³°üÐ§¹û
--
local bezierStart = Vector2(300, 600);
local bezierEndNormal = Vector2(600, 500);
local bezierEndAbandon = Vector2(700, 400);

local bezierCtrlPtNormal1 = Vector2(100, 100);
local bezierCtrlPtNormal2 = Vector2(150, 100);

local bezierCtrlPtAbandon1 = Vector2(100, 100);
local bezierCtrlPtAbandon2 = Vector2(100, 100);
local TotalStep = 100;
local ScaleSize = 0.01;
local Acount;
local At;
--ÒÆ¶¯itemÖÁ±³°ü
function TaskAcceptAndRewardPanel:MoveToPackage()
	if Acount == TotalStep then
		timerManager:DestroyTimer(At);
		for _, child in pairs(needFlyItems) do
			mainDesktop:RemoveChild(child);
		end
		return;
	end
	local t = Acount / TotalStep;
	for _, item in pairs(needFlyItems) do
		local x = Math.Bezier(t, item.Translate.x, bezierCtrlPtNormal1.x, bezierCtrlPtNormal2.x, appFramework.ScreenWidth);
		local y = Math.Bezier(t, item.Translate.y, bezierCtrlPtNormal1.y, bezierCtrlPtNormal2.y, appFramework.ScreenHeight);
		item.Translate = Vector2(x, y);
		item:SetScale(1 - Acount * ScaleSize, 1 - Acount * ScaleSize);
	end
	Acount = Acount + 1;
end

--ÏûÊ§
function TaskAcceptAndRewardPanel:Disappear()
	Acount = 0; --Í³¼Æ¼ÆÊýÇå0
	panel.Visibility = Visibility.Hidden; --Òþ²Øµ±Ç°panel
	self:onClose();

	--coin and Exp Effect
	local taskReward = resTableManager:GetValue(ResTable.task, tostring(self.task['id']), {'exp', 'coin'});
	--MainUI:ShowEffectTask(taskReward['exp'], taskReward['coin']);
	MainUI:NewShowEffectGeneral(taskReward['exp'], taskReward['coin']);
	for _, item in pairs(needFlyItems) do
		item.Visibility = Visibility.Hidden; --ÏÔÊ¾Item
	end
	--[[
	if #needFlyItems ~= 0 then
		MainUI:onHideShade(); --È¥³ýÕÚÕÖ
		At = timerManager:CreateTimer(0.01, 'TaskAcceptAndRewardPanel:MoveToPackage', 0);
	end
	--]]
	if not UserGuidePanel:GetInGuilding() and not UserGuidePanel:GetIsLvUp() then
		if self.task['task_class'] == TaskClass.main and
			Task.mainTask and Task.mainTask['quest_get'] == self.task['quest_finish'] then
			TaskDialogPanel:onPopUpNpcDialog();
		else
		--	UserGuidePanel:TriggerAutoTaskGuide();
		end	
	else
		UserGuidePanel:SetIsLvUp(false)
	end	
end
--========================================================================================================

--Ñ°Â·£¨Ñ°ÈË£¬Ñ°¹Ø¿¨¡£¡£¡£¡££©
function TaskAcceptAndRewardPanel:onGo()
	self:onClose();
	print('TaskAcceptAndRewardPanel:onGo')
	if  not UserGuidePanel:GetIsLvUp() then
		print('TaskAcceptAndRewardPanel:onGo step 1')
		-- Òýµ¼
		if TaskType.system == self.task['type'] then
			UserGuide:systemTask(self.task['id']);
		elseif self.task['type'] == TaskType.dialog and self.task['quest_finish'] == self.task['quest_get'] then
			Task:findNpc(self.task['quest_finish']);
		elseif Task:isComplete(self.task) then
			Task:findNpc(self.task['quest_finish']);
		elseif self.task['type'] == TaskType.barrier then
			local barrierid = Task:getBarrierIdByTask(self.task);
		--	if not UserGuidePanel.isUserGuide then
				Task:findBarrier(barrierid);
		--	end
		else
		--	UserGuidePanel:TriggerAutoTaskGuide();
		end
	else
		UserGuidePanel:SetIsLvUp(false)
	end
end

--ÏÔÊ¾
function TaskAcceptAndRewardPanel:Show()
	panel.Visibility = Visibility.Visible;
	--ÉèÖÃÄ£Ê½¶Ô»°¿ò
	--	mainDesktop:DoModal(panel);
	mainDesktop:GetLogicChild('bgPanel').Visibility = Visibility.Visible;
	mainDesktop:GetLogicChild('bgPanel').ZOrder = PanelZOrder.accept;
	--Ôö¼ÓUIµ¯³öÊ±ºòµÄÐ§¹û
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);

	self.isTaskAndRewardOpen = true
end

--Òþ²Ø
function TaskAcceptAndRewardPanel:Hide()
	panel.Visibility = Visibility.Hidden;
	mainDesktop:GetLogicChild('bgPanel').Visibility = Visibility.Hidden;

	--Ôö¼ÓUIÏûÊ§Ê±µÄÐ§¹û
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	self.isTaskAndRewardOpen = false
	if not UserGuidePanel:GetIsLvUp() then
		UserGuidePanel:SelectAndEnterGuidence();
		--触发新手引导箭头
	else
		UserGuidePanel:SetIsLvUp(false)
	end
end

--¹Ø±Õ
function TaskAcceptAndRewardPanel:onClose()
	self:Hide();
end

--Ïú»Ù
function TaskAcceptAndRewardPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

function TaskAcceptAndRewardPanel:IsShow()
	return panel.Visibility == Visibility.Visible;
end
