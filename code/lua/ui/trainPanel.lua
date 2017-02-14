--trainPanel.lua
--==============================================================================================
--训练场

TrainPanel =
	{
	};
	
--变量
local stateList = {1,1,3};			--1空闲、2训练完成、3未开放、4休整、5开始训练
local timerList = {};				--定时器table
local leftTimeList = {0,0,0};		--定时器剩余时间
local partnerList = {};				--伙伴列表
local pos;							--选择的位置
local trainType = {};				--训练类型
local isTouched = false;			--开始训练状态时按钮是否已经点击过
local menuPos = {{40,127}, {290,127}, {540,127}};


--控件
local mainDesktop;
local panel;
local controlList = {};
local menu;
local floatLevelEffectLabel;				--浮动等级特效标签
local floatExpEffectLabel;					--浮动经验特效标签

--初始化
function TrainPanel:InitPanel(desktop)
	--变量初始化
	stateList = {1,1,3};					--1空闲、2训练完成、3未开放、4休整、5开始训练
	timerList = {};							--定时器table
	leftTimeList = {0,0,0};					--定时器剩余时间
	partnerList = {};						--伙伴列表
	pos = Vector2(0,0);						--选择的位置
	trainType = {};							--训练类型
	isTouched = false;						--开始训练状态时按钮是否已经点击过
	menuPos = {{40,127}, {290,127}, {540,127}};
	controlList = {};
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('trainPanel'));
	panel:IncRefCount();
	
	menu = panel:GetLogicChild('menu');
	menu.typeKingItem = menu:GetLogicChild('typeShowKing');
	
	local item;
	for index = 1, 3 do
		item = panel:GetLogicChild(tostring(index));
		controlList[index] = {};
		controlList[index].labelState = item:GetLogicChild('state');
		controlList[index].labelTime = item:GetLogicChild('time');
		controlList[index].labelExp = item:GetLogicChild('exp');
		controlList[index].iconExp = item:GetLogicChild('iconExp');
		controlList[index].labelLevel = item:GetLogicChild('level');		
		
		local btn = item:GetLogicChild('button');
		controlList[index].btnTrain	 = btn;
		controlList[index].btnTrain.shuijing	 = btn:GetLogicChild(0):GetLogicChild('shuijing');
		controlList[index].btnTrain.text		 = btn:GetLogicChild(0):GetLogicChild('text');
		controlList[index].avatureRole = ArmatureUI(item:GetLogicChild('form'));

		controlList[index].typeButton = item:GetLogicChild('typeButton');
		controlList[index].typeShow = item:GetLogicChild('typeShow');
		controlList[index].typeKingItem = controlList[index].typeShow:GetLogicChild('typeShowKing');
		controlList[index].typeNormalItem = controlList[index].typeShow:GetLogicChild('typeShowNormal');
		
		if 1 ~= index then
			controlList[index].fences = item:GetLogicChild('fences');
		end
	end
	
	menu.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function TrainPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TrainPanel:Show()
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'TrainPanel:onUserGuid');		
end

--打开时的新手引导
function TrainPanel:onUserGuid()
	if UserGuidePanel:GetInGuilding() then
		if stateList[1] == 1 then
			UserGuidePanel:ShowGuideShade(controlList[1].labelState, GuideEffectType.hand, GuideTipPos.no);
		end
		UserGuidePanel:SetInGuiding(false);
	end
end

--隐藏
function TrainPanel:Hide()
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--刷新队伍战斗力（训练场挪到队伍界面内部）
	TeamOrderPanel:refreshTotalFightPoint();
	
	--销毁定时器
	for index = 1, 3 do
		if nil ~= timerList[index] then
			timerManager:DestroyTimer(timerList[index]);			--清除定时器
			timerList[index] = nil;
		end
	end
	
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--功能函数
--空闲状态
function TrainPanel:SetFreeState(index)
	stateList[index] = 1;
	controlList[index].labelState.Text = LANG_trainPanel_1;
	controlList[index].labelState.TextColor = QualityColor[2];			--绿色
	controlList[index].labelState.Visibility = Visibility.Visible;
	controlList[index].labelTime.Visibility = Visibility.Hidden;
	controlList[index].labelExp.Visibility = Visibility.Hidden;
	controlList[index].iconExp.Visibility = Visibility.Hidden;
	controlList[index].labelLevel.Visibility = Visibility.Hidden;	
	controlList[index].btnTrain.Visibility = Visibility.Hidden;
	controlList[index].avatureRole.Visibility = Visibility.Hidden;
	
	controlList[index].typeButton.Visibility = Visibility.Hidden;
	controlList[index].typeShow.Visibility = Visibility.Hidden;
	controlList[index].typeKingItem.Visibility = Visibility.Hidden;
	controlList[index].typeNormalItem.Visibility = Visibility.Hidden;
	
	if 1 ~= index then
		controlList[index].fences.Visibility = Visibility.Hidden;
	end
end

--训练完成状态
function TrainPanel:SetFinishState(index, isKingTrain)
	stateList[index] = 2;
	controlList[index].labelState.Text = LANG_trainPanel_2;
	controlList[index].labelState.TextColor = QualityColor[5];			--黄色
	controlList[index].btnTrain.shuijing.Visibility = Visibility.Hidden;
	controlList[index].btnTrain.text.Text = LANG_trainPanel_3;
	
	if isKingTrain then													--王者训练
		controlList[index].labelLevel.Text = LANG_trainPanel_4 .. ActorManager.user_data.role.lvl.level .. LANG_trainPanel_5;
		controlList[index].labelExp.Visibility = Visibility.Hidden;
		controlList[index].iconExp.Visibility = Visibility.Hidden;
		controlList[index].labelLevel.Visibility = Visibility.Visible;
	else																--普通训练
		controlList[index].labelExp.Text = tostring(self:GetTrainExp(ActorManager.user_data.role.lvl.level));
		controlList[index].labelExp.Visibility = Visibility.Visible;
		controlList[index].iconExp.Visibility = Visibility.Visible;
		controlList[index].labelLevel.Visibility = Visibility.Hidden;
	end
	
	controlList[index].labelState.Visibility = Visibility.Visible;
	controlList[index].labelTime.Visibility = Visibility.Hidden;		
	controlList[index].btnTrain.Visibility = Visibility.Visible;
	controlList[index].avatureRole.Visibility = Visibility.Visible;

	controlList[index].typeButton.Visibility = Visibility.Hidden;
	controlList[index].typeShow.Visibility = Visibility.Hidden;
	controlList[index].typeKingItem.Visibility = Visibility.Hidden;
	controlList[index].typeNormalItem.Visibility = Visibility.Hidden;
	
	if 1 ~= index then
		controlList[index].fences.Visibility = Visibility.Hidden;
	end
end

--未开放状态
function TrainPanel:SetUnopenState(index)
	stateList[index] = 3;
	controlList[index].labelState.TextColor = QuadColor(Color.Red);			--红色
	controlList[index].labelState.Visibility = Visibility.Visible;
	controlList[index].labelTime.Visibility = Visibility.Hidden;
	controlList[index].labelExp.Visibility = Visibility.Hidden;
	controlList[index].iconExp.Visibility = Visibility.Hidden;
	controlList[index].labelLevel.Visibility = Visibility.Hidden;	
	controlList[index].btnTrain.Visibility = Visibility.Hidden;
	controlList[index].avatureRole.Visibility = Visibility.Hidden;

	controlList[index].typeButton.Visibility = Visibility.Hidden;
	controlList[index].typeShow.Visibility = Visibility.Hidden;
	controlList[index].typeKingItem.Visibility = Visibility.Hidden;
	controlList[index].typeNormalItem.Visibility = Visibility.Hidden;
	
	if 2 == index then
		controlList[index].labelState.Text = LANG_trainPanel_6;
		controlList[index].fences.Visibility = Visibility.Visible;
	elseif 3 == index then
		controlList[index].labelState.Text = LANG_trainPanel_7;
		controlList[index].fences.Visibility = Visibility.Visible;
	end
end

--休整状态
function TrainPanel:SetRestState(index, leftTime)
	stateList[index] = 4;	
	
	controlList[index].labelTime.Text = self:ShowRemainderTime(leftTime);
	controlList[index].labelState.Text = LANG_trainPanel_8;
	controlList[index].labelState.TextColor = QuadColor(Color.Red);			--红色
	
	controlList[index].labelState.Visibility = Visibility.Visible;
	controlList[index].labelTime.Visibility = Visibility.Visible;
	controlList[index].labelExp.Visibility = Visibility.Hidden;
	controlList[index].iconExp.Visibility = Visibility.Hidden;
	controlList[index].labelLevel.Visibility = Visibility.Hidden;	
	controlList[index].btnTrain.Visibility = Visibility.Visible;
	controlList[index].avatureRole.Visibility = Visibility.Hidden;

	controlList[index].typeButton.Visibility = Visibility.Hidden;
	controlList[index].typeShow.Visibility = Visibility.Hidden;
	controlList[index].typeKingItem.Visibility = Visibility.Hidden;
	controlList[index].typeNormalItem.Visibility = Visibility.Hidden;
	
	controlList[index].btnTrain.text.Text = LANG_trainPanel_9;
	controlList[index].btnTrain.shuijing.Visibility = Visibility.Visible;
	
	if timerList[index] == nil then
		timerList[index] = timerManager:CreateTimer(1, 'TrainPanel:onUpdateRestTime', index);
		leftTimeList[index] = leftTime;
	end
	
	if 1 ~= index then
		controlList[index].fences.Visibility = Visibility.Hidden;
	end
end

--开始训练状态
function TrainPanel:SetStartState(index)
	stateList[index] = 5;
	controlList[index].btnTrain.text.Text = LANG_trainPanel_10;
	controlList[index].btnTrain.shuijing.Visibility = Visibility.Hidden;
	controlList[index].labelState.Visibility = Visibility.Hidden;
	controlList[index].labelTime.Visibility = Visibility.Hidden;
	controlList[index].labelExp.Visibility = Visibility.Visible;
	controlList[index].iconExp.Visibility = Visibility.Visible;
	controlList[index].labelLevel.Visibility = Visibility.Hidden;	
	controlList[index].btnTrain.Visibility = Visibility.Visible;
	controlList[index].avatureRole.Visibility = Visibility.Visible;

	controlList[index].typeButton.Visibility = Visibility.Visible;
	controlList[index].typeShow.Visibility = Visibility.Visible;
	controlList[index].typeKingItem.Visibility = Visibility.Hidden;
	controlList[index].typeNormalItem.Visibility = Visibility.Visible;
	
	controlList[index].labelExp.Text = tostring(self:GetTrainExp(ActorManager.user_data.role.lvl.level));
	trainType[index] = 1;				--训练类型
	
	if 1 ~= index then
		controlList[index].fences.Visibility = Visibility.Hidden;
	end
end

--设置选择的角色
function TrainPanel:SetParnter(actor)
	partnerList[pos] = actor;
	--显示角色形象
	local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(actor.resid), 'path') .. '/';
	AvatarManager:LoadFile(path);
	controlList[pos].avatureRole:Destroy();
	controlList[pos].avatureRole:LoadArmature(actor.actorForm);
	controlList[pos].avatureRole:SetAnimation(AnimationType.f_idle);
	
	self:SetStartState(pos);
end

--获得训练经验
function TrainPanel:GetTrainExp(level)
	level = math.floor(level / 10) * 10;
	local exp = resTableManager:GetValue(ResTable.train, tostring(level), 'exp');
	return exp;
end

--清除训练场cd
function TrainPanel:clearTrainColdTime(pos)
	local msg = {};
	msg.pos = pos;
	Network:Send(NetworkCmdType.req_practice_clear, msg);
end

--播放浮动等级特效
function TrainPanel:ShowFloatLevelEffect(curLevel)
	if nil == floatLevelEffectLabel then
		floatLevelEffectLabel = uiSystem:CreateControl('Label');
		floatLevelEffectLabel.Margin = Rect(0, 0, 0, 80);
		floatLevelEffectLabel.Size = Size(500, 40);
		floatLevelEffectLabel.TextAlignStyle = TextFormat.MiddleCenter;
		floatLevelEffectLabel.Horizontal = ControlLayout.H_CENTER;
		floatLevelEffectLabel.Vertical = ControlLayout.V_CENTER;
		floatLevelEffectLabel.Font = uiSystem:FindFont('huakang_20');
		floatLevelEffectLabel.Pick = false;
		topDesktop:AddChild(floatLevelEffectLabel);
			
		
		floatLevelEffectLabel.Translate = Vector2(0,0);
		floatLevelEffectLabel.TextColor = Configuration.GreenColor;
	end
	
	floatLevelEffectLabel.Visibility = Visibility.Visible;
	floatLevelEffectLabel.Margin = Rect(0, 0, 240*(pos - 1), 80);
	floatLevelEffectLabel.Text = 'Lv' .. curLevel .. ' ↑';
	floatLevelEffectLabel.Storyboard = '';
	floatLevelEffectLabel.Storyboard = 'storyboard.floatTrainUp';	
end

--播放浮动经验特效
function TrainPanel:ShowFloatExpEffect(exp)
	if nil == floatExpEffectLabel then
		floatExpEffectLabel = uiSystem:CreateControl('Label');
		floatExpEffectLabel.Margin = Rect(0, 0, 0, 60);
		floatExpEffectLabel.Size = Size(500, 40);
		floatExpEffectLabel.TextAlignStyle = TextFormat.MiddleCenter;
		floatExpEffectLabel.Horizontal = ControlLayout.H_CENTER;
		floatExpEffectLabel.Vertical = ControlLayout.V_CENTER;
		floatExpEffectLabel.Font = uiSystem:FindFont('huakang_20');
		floatExpEffectLabel.Pick = false;
		topDesktop:AddChild(floatExpEffectLabel);		
	end
	
	floatExpEffectLabel.Visibility = Visibility.Visible;
	floatExpEffectLabel.Margin = Rect(0, 0, 240*(pos - 1), 60);
	floatExpEffectLabel.Text = LANG_trainPanel_11 .. exp;	
	floatExpEffectLabel.Storyboard = '';
	floatExpEffectLabel.Storyboard = 'storyboard.floatTrainUp';	
end

--是否显示
function TrainPanel:IsVisible()
	if panel.Visibility == Visibility.Hidden then
		return false;
	else
		return true;
	end
end

--更改显示时间
function TrainPanel:ShowRemainderTime(totalTime)
	local hour = Math.Floor(totalTime/3600);
	local min = Math.Floor(math.mod(totalTime,3600)/60);
	local sec = math.mod(math.mod(totalTime,3600), 60);
	return string.format(LANG_trainPanel_12, hour, min, sec);
end
--=============================================================================================
--事件

--关闭
function TrainPanel:onClose()
	MainUI:Pop();
end		

--打开训练场
function TrainPanel:onShowTrainPanel(infos)
	for index = 1, 3 do
		if -1 == infos[index].state then			--场地未开放
			if index < 3 then
				if ActorManager.user_data.role.lvl.level >= Configuration.TrainPosOpenLevel[index] then
					self:SetFreeState(index);
				else
					self:SetUnopenState(index);
				end
			else
				if ActorManager.user_data.viplevel >= Configuration.TrainPosOpenLevel[index] then
					self:SetFreeState(index);
				else
					self:SetUnopenState(index);
				end
			end
			
		elseif 0 == infos[index].state then		--空闲
			self:SetFreeState(index);
		elseif 1 == infos[index].state then		--冷却
			self:SetRestState(index, infos[index].remains);
		end
	end
	
	isTouched = false;
	MainUI:Push(self);
end

--选择训练伙伴
function TrainPanel:onChooseParnter(Args)
	if isTouched then
		return;
	end
	
	local arg = UIControlEventArgs(Args);
	pos = arg.m_pControl.Tag;		
	
	if (1 == stateList[pos]) or (5 == stateList[pos]) then
		local flag = true;
		for _,partner in ipairs(ActorManager.user_data.partners) do
			if partner.lvl.level < ActorManager.user_data.role.lvl.level then
				flag = false;
			end	
		end
		
		if flag then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_trainPanel_13);
		else
			FriendAssistPanel:onShowPartner();	
		end	
	end
end

--定时器响应函数
function TrainPanel:onUpdateRestTime(index)
	leftTimeList[index] = leftTimeList[index] - 1;
	if leftTimeList[index] < 0 then
		timerManager:DestroyTimer(timerList[index]);			--清除定时器
		timerList[index] = nil;
		leftTimeList[index] = 0;
		self:SetFreeState(index);								--设置为空闲状态
	else
		controlList[index].labelTime.Text = self:ShowRemainderTime(leftTimeList[index]);
	end
end

--选择训练类型
function TrainPanel:onClickChooseType(Args)
	local args = UIControlEventArgs(Args);
	menu.Visibility = Visibility.Visible;
	menu.Translate = Vector2(menuPos[args.m_pControl.Tag][1], menuPos[args.m_pControl.Tag][2]);
	menu.Tag = args.m_pControl.Tag;
	mainDesktop.FocusControl = menu;
	
	local superTrainOpenLevel = resTableManager:GetValue(ResTable.vip_open, '11', 'viplv');
	if superTrainOpenLevel > ActorManager.user_data.viplevel then
		menu.typeKingItem.Visibility = Visibility.Hidden;
	else
		menu.typeKingItem.Visibility = Visibility.Visible;
	end
	
	args.m_bHandled = true;
end

function TrainPanel:onChooseType(Args)
	local args = UIControlEventArgs(Args);
	trainType[menu.Tag] = args.m_pControl.Tag;
	if 1 == args.m_pControl.Tag then			--普通训练
		controlList[menu.Tag].labelExp.Visibility = Visibility.Visible;
		controlList[menu.Tag].iconExp.Visibility = Visibility.Visible;
		controlList[menu.Tag].labelLevel.Visibility = Visibility.Hidden;
		controlList[menu.Tag].typeKingItem.Visibility = Visibility.Hidden;
		controlList[menu.Tag].typeNormalItem.Visibility = Visibility.Visible;
	elseif 2 == args.m_pControl.Tag then		--王者训练
		controlList[menu.Tag].labelExp.Visibility = Visibility.Hidden;
		controlList[menu.Tag].iconExp.Visibility = Visibility.Hidden;
		controlList[menu.Tag].labelLevel.Visibility = Visibility.Visible;
		controlList[menu.Tag].typeKingItem.Visibility = Visibility.Visible;
		controlList[menu.Tag].typeNormalItem.Visibility = Visibility.Hidden;
		controlList[menu.Tag].labelLevel.Text = LANG_trainPanel_14 .. ActorManager.user_data.role.lvl.level .. LANG_trainPanel_15;
	end
	
	menu.Visibility = Visibility.Hidden;
	args.m_bHandled = true;
end

--菜单失去焦点事件
function TrainPanel:onMenuLoseFocuse()
	menu.Visibility = Visibility.Hidden;
end

--开始训练
function TrainPanel:onStartToTrain(Args)
	local args = UIControlEventArgs(Args);	
	args.m_bHandled = true;
	
	if isTouched then
		return;
	end
	
	if 5 == stateList[args.m_pControl.Tag] then
		if (2 == trainType[args.m_pControl.Tag]) and (ActorManager.user_data.rmb < Configuration.KingTrainRmb) then
            --[[local okDelegate = Delegate.new(RechargePanel, RechargePanel.onShowRechargePanel, 0);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_trainPanel_16 .. Configuration.KingTrainRmb .. LANG_trainPanel_17, okDelegate);--]]
			RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_trainPanel_18);
		else
			isTouched = true;			--防止按钮重复点击
			
			local msg = {};
			pos = args.m_pControl.Tag - 1
			msg.pos = pos;
			msg.pid = partnerList[args.m_pControl.Tag].pid;
			msg.type = trainType[args.m_pControl.Tag];
			
			Network:Send(NetworkCmdType.req_practice_partner, msg);
		end
	elseif 4 == stateList[args.m_pControl.Tag] then
		if ActorManager.user_data.rmb < (Configuration.PerClearCDRmb * math.ceil(leftTimeList[args.m_pControl.Tag] / 3600)) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_trainPanel_19 .. (Configuration.PerClearCDRmb * math.ceil(leftTimeList[args.m_pControl.Tag] / 3600)));
		else
			--显示MessageBox
			local contents = {};
			table.insert(contents, {cType = MessageContentType.Text; text = LANG_trainPanel_20});

			table.insert(contents, {cType = MessageContentType.Text; text = (Configuration.PerClearCDRmb * math.ceil(leftTimeList[args.m_pControl.Tag] / 3600)) .. LANG_trainPanel_21, color = Configuration.BlueColor});

			table.insert(contents, {cType = MessageContentType.Text; text = LANG_trainPanel_22});
			
			local okDelegate = Delegate.new(TrainPanel, TrainPanel.clearTrainColdTime, args.m_pControl.Tag - 1);

			MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);
		end
	elseif 2 == stateList[args.m_pControl.Tag] then
		self:SetRestState(args.m_pControl.Tag, leftTimeList[args.m_pControl.Tag]);
	end	
end

--显示训练结束
function TrainPanel:onShowTrainEnd(pos)
	isTouched = false;
	
	if 1 == trainType[pos] then
		self:SetFinishState(pos, false);
	elseif 2 == trainType[pos] then
		self:SetFinishState(pos, true);
	end
	
	leftTimeList[pos] = Configuration.TrainColdTime;
	timerList[pos] = timerManager:CreateTimer(1, 'TrainPanel:onUpdateRestTime', pos);	
end

--响应服务器清除训练cd的消息
function TrainPanel:onClearTrainCD(pos)
	if timerList[pos] ~= nil then
		timerManager:DestroyTimer(timerList[pos]);			--清除定时器
		timerList[pos] = nil;
		leftTimeList[pos] = 0;		
	end
	self:SetFreeState(pos);								--设置为空闲状态
end
