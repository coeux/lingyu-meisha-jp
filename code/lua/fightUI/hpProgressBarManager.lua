--hpProgressBarManager.lua
--==================================================================
--角色血条管理类

local BLOOD50 = 'fight.fight_blood3';
local BLOOD25 = 'fight.fight_blood2';
local BLOOD0 = 'fight.fight_blood1';
local BACKGROUND = 'fight.fight_jindutiao3';

HpProgressBarManager =
	{
		m_ProgressBarList = {};
		m_LeftProgressBarList = {};
		m_ProgressBarWidth = 100;
		m_TotalShowTime = 5;
		m_InterruptTime = 3;
		m_EffectMoveTimeRatio = Configuration.HpProgressSpeed;
	};

local headItemList;

--初始化
function HpProgressBarManager:Init(desktop)
	self.desktop = desktop;
	self.m_ProgressBarList = {};
	headItemList = {};
	--self:PreAddHpProgressBar();

	self.sceneCamera = FightManager.scene:GetCamera();
	self.uiCamera = self.desktop.Camera;

	local path = GlobalData.EffectPath .. 'interrupt_output/';
	AvatarManager:LoadFile(path)
end

--更新血条
function HpProgressBarManager:Update(elapse)
	for actorID, hpProbItem in pairs(self.m_ProgressBarList) do
		--更新显示时间
		hpProbItem.time = hpProbItem.time + elapse;
		--更新血条位置
		self:SetProgressBarPosition(hpProbItem.hpBar, hpProbItem.actor);
		--更新血条颜色
		self:UpdateColor(hpProbItem.hpBar);
		--判断血条显示时间是否已满
		if (hpProbItem.time > self.m_TotalShowTime) then
			self:RemoveHpProgressBar(actorID);
		end
	end

  if headItemList == nil then
    return;
  end
	for actorID, interruptItem in pairs(headItemList) do
		interruptItem.time = interruptItem.time + elapse;
		self:SetInterruptEffectPostion(interruptItem.panel, interruptItem.actor);
		if interruptItem.time > self.m_InterruptTime then
			headItemList[actorID].panel:RemoveAllChildren();
		end
	end
end

--销毁
function HpProgressBarManager:Destroy()
	for actorID, hpProbItem in pairs(self.m_ProgressBarList) do
		self.desktop:RemoveChild(hpProbItem.hpBar);
	end
	self.m_ProgressBarList = {};

	--[[
	for _, hpBar in ipairs(self.m_LeftProgressBarList) do
		self.desktop:RemoveChild(hpBar);
	end
	self.m_LeftProgressBarList = {};
	--]]
end

--创建血条
function HpProgressBarManager:createHpProgressBar()

	local node = Panel(uiSystem:CreateControl('Panel'));
	node.Size = Size(70, 8);
	node.ZOrder = PanelZOrder.hpProgress;
	node.Visibility = Visibility.Hidden;
	node.Background = uiSystem:FindResource('fight_jindutiao3', 'fight')

	local progressBar = EffectProgressBar(uiSystem:CreateControl('EffectProgressBar'));
	--progressBar.ForwardBrush = Converter.String2Brush(BLOOD50);
	progressBar.ForwardBrush = uiSystem:FindResource('fight_blood3', 'fight');
	--progressBar.EffectBrush = Converter.String2Brush(BLOOD50);
	progressBar.EffectBrush = uiSystem:FindResource('fight_blood3', 'fight');

	progressBar.Size = Size(70, 8);
	progressBar.ShowText = false;
	progressBar.ZOrder = 1;
	progressBar.Translate = Vector2(0, 0);

	node:AddChild(progressBar);
	node.bar = progressBar;

	self.desktop:AddChild(node);
--[[
	local hpValue = uiSystem:CreateControl('Label');
	hpValue.Visibility = Visibility.Visible;
	hpValue.Text = "";
	hpValue.Size = Size(100, 30);
	hpValue:SetFont('');
	hpValue:SetScale(0.7, 0.7);

	progressBar:AddChild(hpValue);
	progressBar.hpValue = hpValue;
--]]
	return node;
end

--隐藏该角色的血条
function HpProgressBarManager:HideProgressBar(actorID)
	local progressBar = self.m_ProgressBarList[actorID];
	if progressBar then
		progressBar.hpBar.Visibility = Visibility.Hidden;
	end
end

--显示该角色的血条
function HpProgressBarManager:ShowProgressBar(actorID)
	local progressBar = self.m_ProgressBarList[actorID];
	if progressBar then
		progressBar.hpBar.Visibility = Visibility.Visible;
	end
end

--调整血条参数
function HpProgressBarManager:SetProgressBarParam(progressBar, hpProbItem, damageValue)
	progressBar.Visibility = Visibility.Visible;
	progressBar.bar:Clear();
	progressBar.bar.MaxValue = hpProbItem.actor:GetMaxHP();
	progressBar.bar.CurValue = hpProbItem.actor:GetCurrentHP() + damageValue;

	--progressBar.hpValue.Text = tostring(progressBar.CurValue);

  --[[
	if hpProbItem.actor:IsEnemy() then
		progressBar.Scale = Vector2(-1, 1);
	else
		progressBar.Scale = Vector2(1, 1);
	end
  ]]


	self:SetProgressBarPosition(progressBar, hpProbItem.actor);
end

--根据角色位置设置血条位置
function HpProgressBarManager:SetProgressBarPosition(progressBar, actor)
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());

	progressBar.Translate = Vector2(uiPosition.x -35, uiPosition.y - actor:GetHeight() * GlobalData.ActorScaleChange);
	progressBar:ForceLayout();
end

--根据角色位置设置打断效果的位置
function HpProgressBarManager:SetInterruptEffectPostion(panel, actor)
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());

	panel.Translate = Vector2(uiPosition.x , uiPosition.y - actor:GetHeight() * GlobalData.ActorScaleChange );
	panel:ForceLayout();
end


--根据角色血量调整血条颜色
function HpProgressBarManager:UpdateColor(progressBar)
	if progressBar.bar.CurValue/progressBar.bar.MaxValue > 0.5 then
		progressBar.bar.ForwardBrush = uiSystem:FindResource('fight_blood3', 'fight');
		progressBar.bar.EffectBrush = uiSystem:FindResource('fight_blood3', 'fight');
	elseif progressBar.bar.CurValue/progressBar.bar.MaxValue > 0.25 then
		progressBar.bar.ForwardBrush = uiSystem:FindResource('fight_blood2', 'fight');
		progressBar.bar.EffectBrush = uiSystem:FindResource('fight_blood2', 'fight');
	else
		progressBar.bar.ForwardBrush = uiSystem:FindResource('fight_blood1', 'fight');
		progressBar.bar.EffectBrush = uiSystem:FindResource('fight_blood1', 'fight');
	end
end

--预添加血条
--[[
function HpProgressBarManager:PreAddHpProgressBar()
	for index = 1, 5 do
		table.insert(self.m_LeftProgressBarList, self:createHpProgressBar());
	end
end
--]]

--添加血条
function HpProgressBarManager:AddHpProgressBar(actorID, damageValue)
	local actor = ActorManager:GetActor(actorID);
	if actor == nil then
		return;
	elseif (actor:GetActorType() == ActorType.boss) or (actor:GetActorType() == ActorType.eliteMonster) then
		return;
	elseif actor:GetCurrentHP() == 0 then
		return;
	end

	if self.m_ProgressBarList[actorID] == nil then
		--该角色的血条没有显示
		local progressBar = self:createHpProgressBar();
--[[
		if (#self.m_LeftProgressBarList > 0) then
			progressBar = self.m_LeftProgressBarList[1];
			table.remove(self.m_LeftProgressBarList, 1);
		else
			progressBar = self:createHpProgressBar();
		end
--]]
		self.m_ProgressBarList[actorID] = {hpBar = progressBar; time = 0; actor = actor; dir = 1};

		--调整血条参数
		self:SetProgressBarParam(progressBar, self.m_ProgressBarList[actorID], damageValue);
		--设置血条特效速度
		local speed = CheckDiv(damageValue / (self.m_EffectMoveTimeRatio * self.m_TotalShowTime));

		progressBar.bar.EffectSpeed = speed < 150 and 150 or speed;
		--设置血条当前值
		progressBar.bar.CurValue = actor:GetCurrentHP();
	else
		--该角色的血条已经显示
		local hpProbItem = self.m_ProgressBarList[actorID];
		--设置血条速度
		local speed = CheckDiv((hpProbItem.hpBar.bar.EffectValue - actor:GetCurrentHP()) / (self.m_EffectMoveTimeRatio * self.m_TotalShowTime));
		hpProbItem.hpBar.bar.EffectSpeed = speed < 150 and 150 or speed;
		--设置血条当前值
		hpProbItem.hpBar.bar.CurValue = actor:GetCurrentHP();
--    hpProbItem.hpBar.hpValue.Text = tostring(actor:GetCurrentHP());
		if actor:GetCurrentHP() < 1 then
			hpProbItem.time = self.m_TotalShowTime;
		else
			--调整血条显示时间
			hpProbItem.time = 0;
		end
	end
end

--删除血条
function HpProgressBarManager:RemoveHpProgressBar(actorID)
	local hpProbItem = self.m_ProgressBarList[actorID];
	--隐藏显示的血条
	hpProbItem.hpBar.Visibility = Visibility.Hidden;
	--清除血条状态
	hpProbItem.hpBar.bar:Clear();
	--将血条添加到可用列表中
	--table.insert(self.m_LeftProgressBarList, hpProbItem.hpBar);
	--从血条更新列表中删除
	self.m_ProgressBarList[actorID] = nil;
end

--增加打断特效
function HpProgressBarManager:AddInterrupt(actorID)
	local actor = ActorManager:GetActor(actorID);
	if actor == nil then
		return;
	end
	if not headItemList[actorID] then
		headItemList[actorID] = {};
		headItemList[actorID].panel = uiSystem:CreateControl('Panel');
		headItemList[actorID].actor = actor;
		headItemList[actorID].time = 0;
		local arm = uiSystem:CreateControl('ArmatureUI');
		arm.Horizontal = ControlLayout.H_CENTER;
		arm.Vertical = ControlLayout.V_CENTER;
		arm:LoadArmature('interrupt');
		arm:SetAnimation('play');
		headItemList[actorID].panel:AddChild(arm);
		self.desktop:AddChild(headItemList[actorID].panel);
	else
		headItemList[actorID].time = 0;
		local arm = uiSystem:CreateControl('ArmatureUI');
		arm.Horizontal = ControlLayout.H_CENTER;
		arm.Vertical = ControlLayout.V_CENTER;
		arm:LoadArmature('interrupt');
		arm:SetAnimation('play');
		headItemList[actorID].panel:AddChild(arm);
	end
end
