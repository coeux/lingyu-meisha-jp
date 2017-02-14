--fightUIManager.lua

--========================================================================
--战斗UI管理者类

FightUIManager =
{
	headUIList = {};
	enemyHeadUIList = {};
	bossUI = {};
	showHeadUITimer = -1;
	showEnemyHeadUITimer = -1;

	fightUIGroup = 'fight';

	techingSkillEffectPos = 1;		--教学技能特效位置

	isSkillCast= false;   --此次按下之后技能是否已经释放过了
	isTraggerLastSkill = false
};

local allyPanelList;
local enemyPanelList;
local skillIconList;				--技能图标列表
local uiCamera;						--UI相机
local sceneCamera;					--场景相机
local curGestureSkillID;			--当前的手势技能ID
local preBossHpIndex = 0;			--上一次更新时boss的血条

local settingPanel;
local timeLabel;					--计时控件
local BOSSHPCOLORPATH = 'godsSenki.bossHpForwarBrush';


--手势技能能量积累面板
local powerStepList = {};
powerStepList[GestureSkillID.V] = 4;
powerStepList[GestureSkillID.Lighting] = 6;
powerStepList[GestureSkillID.Circle] = 7;
powerStepList[GestureSkillID.Z] = 12;

local gesturePowerRecoverTime = 0;										--手势能量恢复时间
local gestureSkillLittleIcon = {};										--手势技能小图标
local gestureSkillOpenFlag = {};										--手势技能开启标志
local gesturePanel;														--手势技能能量面板
local powerEnoughTip;													--手势能量提示
local powerTipLastTime = 0;												--手势能量提示持续时间
local gesture_progressbar;												--手势技能能量进度条
local isGestureSkillAvailable = true;									--判断当前手势技能是否可用
local canReleaseGestureSkill = true;									--是否可以释放手势技能
local gestureArmature = nil;											--手势引导特效
local gestureSkillCenterArmature = nil;								--划手势在屏幕中心显示的手势动画
local restTime = 0;
local is_pause;

--战斗提示引导
local fightGuidePanel;
local angerGuidePanel;
local infoGuidePanel;


--初始化
function FightUIManager:Initialize(desktop)

	self.desktop = desktop;				--获取战斗UI界面
	sceneCamera = FightManager.scene:GetCamera();
	uiCamera = desktop.Camera;
	self.hpFullBrush = CenterStretchBrush(uiSystem:FindResource('fullHpForwardBrush', self.fightUIGroup));
	self.hpHalfBrush = CenterStretchBrush(uiSystem:FindResource('halfHpForwardBrush', self.fightUIGroup));
	self.hpEmptyBrush = CenterStretchBrush(uiSystem:FindResource('emptyHpForwardBrush', self.fightUIGroup));
	self.forwardBrush = nil;			--boss血条前景刷
	self.effectBrush = nil;				--boss血条特效刷
	self.backBrush = nil;				--boss血条背景刷
	self.angerBar = nil;         --总怒气进度条
	is_pause = 0;

	self.debugInfoPanel = self.desktop:GetLogicChild('DebugPanel');
	self.debugInfoPanel.Pick = false


	if debuginfomode then
		self.debugInfoPanel.Visibility = Visibility.Visible;
	else
		self.debugInfoPanel.Visibility = Visibility.Hidden;
	end

	self.leftList = self.debugInfoPanel:GetLogicChild('leftList')
	self.leftList.Pick = false
	self.rightList = self.debugInfoPanel:GetLogicChild('rightList')
	self.rightList.Pick = false

	self.leftList:RemoveAllChildren();
	self.rightList:RemoveAllChildren();
	self.debugItemList = {};

	self.tracePanel = self.desktop:GetLogicChild('TraceEffectPanel');
	self.tracePanel.Pick = false;

	self.traceList = self.tracePanel:GetLogicChild('leftList')
	self.traceList:RemoveAllChildren();

	if debugtracemode then
		self.tracePanel.Visibility = Visibility.Visible;
	else
		self.tracePanel.Visibility = Visibility.Hidden;
	end

	fightGuidePanel = self.desktop:GetLogicChild('FightGuidePanel');
	fightGuidePanel:GetLogicChild('info').Text = FightGuidePanel_Lang;
	angerGuidePanel = self.desktop:GetLogicChild('AngerGuidePanel');
	angerGuidePanel:GetLogicChild('info').Text = AngerGuidePanel_Lang;
	infoGuidePanel = self.desktop:GetLogicChild('InfoGuidePanel');
	infoGuidePanel:GetLogicChild('info').Text = InfoGuidePanel_Lang;

	allyPanelList = self.desktop:GetLogicChild('allyPanelList');
	enemyPanelList = self.desktop:GetLogicChild('enemyPanelList');

	--gesturePanel = self.desktop:GetLogicChild('gesturePowerPanel');
	--gesturePanel:ForceLayout();
	powerEnoughTip = self.desktop:GetLogicChild('energyTip');
	--gesture_progressbar = gesturePanel:GetLogicChild('powerProgressBar');
	self.angerBar = self.desktop:GetLogicChild('newAngerBar');
	self.angerBar.MaxValue = Configuration.maxTotalAnger;
	self.angerBar.CurValue = 0;
	self.enemyAngerBar = self.desktop:GetLogicChild('enemyAngerBar');
	self.enemyAngerBar.MaxValue = Configuration.maxTotalAnger;
	self.enemyAngerBar.CurValue = 0;
	--gestureSkillLittleIcon[GestureSkillID.V]			= gesturePanel:GetLogicChild('step1');
	--gestureSkillLittleIcon[GestureSkillID.Lighting] 	= gesturePanel:GetLogicChild('step2');
	--gestureSkillLittleIcon[GestureSkillID.Circle] 		= gesturePanel:GetLogicChild('step3');
	--gestureSkillLittleIcon[GestureSkillID.Z] 			= gesturePanel:GetLogicChild('step4');
	powerEnoughTip.Visibility = Visibility.Hidden;
	isGestureSkillAvailable = true;
	canReleaseGestureSkill = true;
	gesturePowerRecoverTime = 0;

	settingPanel = Panel(self.desktop:GetLogicChild('shezhidiPanel'));
	timeLabel = self.desktop:GetLogicChild('labelTimeRest');
	timeLabel.Text = tostring(0);
	self.timeControl = {};

	-- 测试模式时间长度增长
	if debugmode then
	   self.count_dount_time = 150000000;
		self.timeControl.req = 150000000;
	else
	   self.count_dount_time = 150
		self.timeControl.req = 150;
	end

	self.timeControl.start = os.clock();
	self.timeControl.pauseGone = 0;
	self.timeControl.pauseStart = 0;
	self.timeControl.pauseEnd = 0;
	self.timeControl.gone = os.clock() - self.timeControl.start - self.timeControl.pauseGone;
	self.timeControl.isGameOver = false;

	settingPanel.Visibility = Visibility.Visible;
	if FightManager.mFightType == FightType.worldBoss or
		FightManager.mFightType == FightType.unionBoss or
		FightManager.mFightType == FightType.arena or
		FightManager.mFightType == FightType.unionBattle or
		FightManager.mFightType == FightType.scuffle then
		settingPanel:GetLogicChild('btnFightConfig').Visibility = Visibility.Hidden;
	else
		settingPanel:GetLogicChild('btnFightConfig').Visibility = Visibility.Visible;
	end
	--手势技能开启关卡显示手势技能
	--self:InitGestureSkillOpenFlag(FightManager.barrierId);
	--初始化手势技能能量点
	if FightManager:GetFightType() == FightType.zodiac then
		self:AddInitGesturePower(ZodiacSignPanel.gesturePower);				--十二宫继承上一场的能量
	else
		self:AddInitGesturePower(Configuration.GestureSkillInitPower);
	end

	--设置面板
	--[[
	if FightManager:GetFightType() == FightType.invasion then
		settingPanel.Visibility = Visibility.Hidden; --杀星不显示设置
	end
	--]]

	--gesturePanel.Visibility = Visibility.Visible;
	if (not gestureSkillOpenFlag[GestureSkillID.V]) or (FightType.noviceBattle == FightManager.mFightType) or (FightManager.isRecord) or (FightManager.isPvP) then					--屏蔽手势技能
		self:ShieldGestureSkill();
	end

	self.bossUI = self:createBossUI();

	skillIconList = {};

	--初始化手牌系统
	FightSkillCardManager:Initialize(desktop);

	--初始化Combo Link
	FightComboLinkManager:Initialize(desktop);

        --初始化Card Panel
        FightCardPanel:Initialize(desktop);

	--初始化弹幕系统
	--BulletScreenManager:Initialize(desktop);

	--初始化测试模式技能列表
	if debugmode then
		self:initDebugSkillPanel(desktop);
	end
	self.infoBtn   = settingPanel:GetLogicChild('infoBtn');
	self.infoBtn:SubscribeScriptedEvent('Button::ClickEvent','FightUIManager:infoBtnClick');
	self.skillInfo = desktop:GetLogicChild('info');
	self.infoContent = self.skillInfo:GetLogicChild('infoPanel'):GetLogicChild('scrollPanel'):GetLogicChild('panel'):GetLogicChild('label');
	self.infoContent.Text = LANG_TEAM_EXPLAIN;
	self.skillInfo.ZOrder = 50000;
	self.skillInfo:SubscribeScriptedEvent('UIControl::MouseClickEvent','FightUIManager:closeSkillInfo');
	if FightManager.mFightType == FightType.arena then
		self.infoBtn.Visibility = Visibility.Hidden;
	else
		self.infoBtn.Visibility = Visibility.Visible;
	end

	--二倍速处理
	self.addBtn  = settingPanel:GetLogicChild('addBtn');
	self.addBtnCancel  = settingPanel:GetLogicChild('addBtnCancel');
	self.addBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','FightManager:OnAddSpeed');
	self.addBtnCancel:SubscribeScriptedEvent('UIControl::MouseClickEvent','FightManager:OnAddSpeed');
	if FightManager.mFightType == FightType.normal or FightManager.mFightType == FightType.elite or FightManager.mFightType == FightType.cardEvent
	or FightManager.mFightType == FightType.rank or FightManager.mFightType == FightType.arena or FightManager.mFightType == FightType.limitround
	or FightManager.mFightType == FightType.expedition then
		self.addBtn.Visibility = Visibility.Visible;
		self.addBtnCancel.Visibility = Visibility.Hidden;
	else
		self.addBtn.Visibility = Visibility.Hidden;
		self.addBtnCancel.Visibility = Visibility.Hidden;
	end

	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		FightUIManager:setInfoGuidePanel(true)
	else
		FightUIManager:setInfoGuidePanel(false)
	end
end
function FightUIManager:isAddSpeed(flag)
	if FightManager.mFightType == FightType.normal or FightManager.mFightType == FightType.elite or FightManager.mFightType == FightType.cardEvent 
	or FightManager.mFightType == FightType.rank or FightManager.mFightType == FightType.arena or FightManager.mFightType == FightType.limitround
	or FightManager.mFightType == FightType.expedition then
		if flag then
			self.addBtn.Visibility = Visibility.Hidden;
			self.addBtnCancel.Visibility = Visibility.Visible;
		else
			self.addBtn.Visibility = Visibility.Visible;
			self.addBtnCancel.Visibility = Visibility.Hidden;
		end
	else
		self.addBtn.Visibility = Visibility.Hidden;
		self.addBtnCancel.Visibility = Visibility.Hidden;
	end
end
function FightUIManager:infoBtnClick()
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_12);
		return;
	end
	if FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_12);
		return;
	end
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_12);
		return;
	end
	self:showSkillInfo()
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 and FightHandSkillManager.thirdRoundUpdata then
		FightSkillCardManager:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent()
	else
		FightManager:FightPauseGame()
	end

	--说明界面提示及动画
	self.skillInfo:GetLogicChild('infoPanel'):GetLogicChild('tipInfo').Text = InfoGuidePanel_Lang_2;
	self.skillInfo:GetLogicChild('infoPanel'):GetLogicChild('tipInfo'):SetUIStoryBoard("storyboard.infocricle");
	FightUIManager:setInfoGuidePanel(false)
end
function FightUIManager:showSkillInfo()
	self.skillInfo.Visibility = Visibility.Visible;
end
function FightUIManager:closeSkillInfo()
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 and FightHandSkillManager.thirdRoundUpdata then 
		FightHandSkillManager.thirdRoundCardCanClick = true;
		self.canClickCard = true;
		FightHandSkillManager.thirdRoundUpdata = false;
	else
		FightManager:FightContinueGame()
	end
	self.skillInfo.Visibility = Visibility.Hidden;
end
function FightUIManager:debugClearCardCallback()
	FightSkillCardManager:Clear();
end

function FightUIManager:getSetbtn()
	return settingPanel:GetLogicChild('btnFightConfig')
end

function FightUIManager:initDebugSkillPanel(desktop)

	local function getActorName(id)
		local name = resTableManager:GetValue(ResTable.actor, tostring(id), 'name');
		return name;
	end

	local function getSkillName(id)
		local name = resTableManager:GetValue(ResTable.skill, tostring(id), 'name');
		return name
	end
	self.debugSkillPanel = uiSystem:CreateControl('StackPanel');
	self.debugSkillPanel.Pick = false;
        self.debugSkillPanel.ZOrder = 50000;
	--self.debugSkillPanel.Alignment = Alignment.Center;
	self.debugSkillPanel.Horizontal = ControlLayout.H_LEFT;
	self.debugSkillPanel.Vertical = ControlLayout.V_TOP;
	self.debugSkillPanel.Margin = Rect(0, 90, 0, 0);

	--清除按钮
	local btn = uiSystem:CreateControl('Button');
	btn.Horizontal = ControlLayout.H_LEFT;
	btn.Vertical = ControlLayout.V_CENTER;
	btn.Size = Size(400, 30);
	btn.Margin = Rect(0, 0, 0, 0);
	btn.TextColor = QuadColor(Color.White);
	btn.Text = "clear"
	btn:SubscribeScriptedEvent('Button::ClickEvent', 'FightUIManager:debugClearCardCallback');
	self.debugSkillPanel:AddChild(btn)

	for i, v in ipairs(FightHandSkillManager:DebugModeSkillList()) do
		local btn = uiSystem:CreateControl('Button');
		btn.Horizontal = ControlLayout.H_LEFT;
		btn.Vertical = ControlLayout.V_CENTER;
		btn.Size = Size(400, 30);
		btn.Margin = Rect(0, 0, 0, 0);
		btn.TextColor = QuadColor(Color.White);
		btn.Text = getActorName(v.actor.resID) .. ':' .. getSkillName(v.skill.m_resid) .. tostring(v.skill.m_resid) ;
		btn.Tag = i;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'FightUIManager:debugSkillCardCallback');
		self.debugSkillPanel:AddChild(btn)
	end
	desktop:AddChild(self.debugSkillPanel);

end

function FightUIManager:debugSkillCardCallback(Args)

	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	local skillInfo = FightHandSkillManager:DebugModeSkillList()[tag];
	if skillInfo then
		--抽卡
		FightSkillCardManager:AddCard(skillInfo, true); -- 强制插卡
	end
end

--销毁
function FightUIManager:Destroy()
	self.bossUI.forwardHpProb:Clear();			--重置特效进度值


	--删除定时器
	if self.showEnemyHeadUITimer ~= -1 then
		timerManager:DestroyTimer(self.showEnemyHeadUITimer);
		self.showEnemyHeadUITimer = -1;
	end

	if self.showHeadUITimer ~= -1 then
		timerManager:DestroyTimer(self.showHeadUITimer);
		self.showHeadUITimer = -1;
	end

	self.headUIList = {};
	self.enemyHeadUIList = {};
	allyPanelList:RemoveAllChildren();
	enemyPanelList:RemoveAllChildren();

	if self.debugSkillPanel then
		self.debugSkillPanel:RemoveAllChildren();
		self.debugSkillPanel = nil;
	end

	self.debugItemList = nil;

	--[[
	--删除手势技能的持续特效
	for _,icon in pairs(gestureSkillLittleIcon) do
		if icon.fireEffect ~= nil then
			gesturePanel:RemoveChild(icon.fireEffect);
			icon.fireEffect = nil;
		end
	end

	--删除手势技能引导教学
	if nil ~= gestureArmature then
		self.desktop:RemoveChild(gestureArmature);
		gestureArmature = nil;
	end
	--]]
	--销毁手牌系统
	FightSkillCardManager:Destroy();

end

--更新
function FightUIManager:Update(elapse)
	--FightSkillCardManager:Update(elapse);
	--更新能量不足提示
	if powerTipLastTime > 0 then
		if powerTipLastTime - elapse <= 0 then			--隐藏提示
			powerEnoughTip.Visibility = Visibility.Hidden;
		end

		powerEnoughTip.Opacity = powerTipLastTime / Configuration.GesturePowerTipLastTime;
		powerTipLastTime = powerTipLastTime - elapse;
	end

	--能量恢复
	if not FightManager:IsOver() then
		gesturePowerRecoverTime = gesturePowerRecoverTime + elapse;
		if gesturePowerRecoverTime >= Configuration.GesturePowerRecoverSpaceTime then
			self:AddGesturePower();
			gesturePowerRecoverTime = 0;
		end
	end
	--BulletScreenManager:Update(elapse);

	--更新UI界面上面的控件
	self.timeControl.gone = os.clock() - self.timeControl.start - self.timeControl.pauseGone;
	self.count_dount_time = self.count_dount_time - elapse
	restTime = math.floor(self.count_dount_time)
	--restTime = self.timeControl.req - math.floor(self.timeControl.gone);
	--
	if restTime < 0 then restTime = 0 end;
	if (0 == restTime) then
		FightManager:setAllLeftRoleDie();
	end
	local second = restTime % 60;
	local minute = ((restTime - second) / 60) % 60;
	local hour = (restTime - second - minute*60) / 60;
	local extraM = (minute >= 10) and '' or '0';
	local extraS = (second >= 10) and '' or '0';
	local extraH = (hour >= 10) and '' or '0';
	if not self.timeControl.isGameOver then
		--timeLabel.Text = extraH .. tostring(hour) .. ':' .. extraM .. tostring(minute) .. ':' .. extraS .. tostring(second);
		timeLabel.Text = extraM .. tostring(minute) .. ':' .. extraS .. tostring(second);
	end

	--更新怒气条
	local anger = FightManager:getTotalAnger();
	self.angerBar.CurValue = anger;
end

function FightUIManager:getTimeSec()
	return restTime;
end

function FightUIManager:getTimeGone()
	return self.timeControl.gone;
end

--创建人物头像ui链表
function FightUIManager:createHeadUI()
	local headUI = {};
	local uctrl = uiSystem:CreateControl('playerPanelTemplate');
	local panel = uctrl:GetLogicChild(0);

	headUI.uctrl = uctrl;
	headUI.assist = panel:GetLogicChild('assist');
	headUI.jobIcon = panel:GetLogicChild('jobIcon');
	headUI.headPic = ImageElement(panel:GetLogicChild('headPic'));
	headUI.angerProb = ProgressBar(panel:GetLogicChild('angerProb'));
	headUI.angerProb.ShowText = false;
	headUI.hpProb = ProgressBar(panel:GetLogicChild('hpProb'));
	headUI.hpProb.ShowText = false;
	headUI.starsList = panel:GetLogicChild('starsList');
	headUI.enable = true;
	headUI.scale = 0.05;
	headUI.isChangeSize = true;                                         --是否还在变大
	headUI.uctrl:SetScale(-headUI.scale, headUI.scale);					--设置缩放

	uctrl.Pick = false;
	panel.Pick = false;
	headUI.headPic.Pick = false;
	headUI.angerProb.Pick = false;
	headUI.hpProb.Pick = false;

	--初始化进度和颜色
	headUI.hpProb.CurValue = 100;
	headUI.hpProb.ForwardBrush = self.hpFullBrush;
	headUI.angerProb.MaxValue = Configuration.MaxAnger;					--设置技能进度条的最大值
	headUI.uctrl.Visibility = Visibility.Visible;
	headUI.assist.Visibility = Visibility.Hidden;

	return headUI;
end

--显示人物头像和头像出现的特效
function FightUIManager:ShowHeadEffect(actor, index, isEnemy)
end

--显示人物头像UI
function FightUIManager:showHeadUI(index)
	self.headUIList[index].scale = self.headUIList[index].scale + 0.1;

	if self.headUIList[index].scale > 1 then
		self.headUIList[index].scale = 1;
		self.headUIList[index].isChangeSize = false;
		timerManager:DestroyTimer(self.showHeadUITimer);				--清除计时器
		self.showHeadUITimer = -1;										--重置定时器
	end

	self.headUIList[index].uctrl:SetScale(-self.headUIList[index].scale, self.headUIList[index].scale);

	self:UpdateHeadUI(index, false);
end

--显示pvp敌方角色头像
function FightUIManager:showEnemyHeadUI(index)
	self.enemyHeadUIList[index].scale = self.enemyHeadUIList[index].scale + 0.1;
	if self.enemyHeadUIList[index].scale > 1 then
		self.enemyHeadUIList[index].isChangeSize = false;
		self.enemyHeadUIList[index].scale = 1;
		timerManager:DestroyTimer(self.showEnemyHeadUITimer);			--清除计时器
		self.showEnemyHeadUITimer = -1;									--重置定时器
	end
	self.enemyHeadUIList[index].uctrl:SetScale(self.enemyHeadUIList[index].scale, self.enemyHeadUIList[index].scale);
end

--更新人物头像
function FightUIManager:UpdateHeadUI(index, isEnemy)
	return;
	--[[
	--更新总怒气进度条
	--TODO:有for1-6更新6次的地方需要改进
	FightUIManager:UpdateTotalAngerBar();
	FightUIManager:UpdateTotalEnemyAngerBar();
	local headUI;
	if isEnemy then
		headUI = self.enemyHeadUIList[index];
	else
		headUI = self.headUIList[index];
	end

	if (nil ~= headUI) and (nil ~= headUI.actor) then
		--更改血条进度
		self:updateHpProb(headUI);


		if (headUI.actor:GetFighterState() == FighterState.death) then
			--判断是否将头像UI置灰
			headUI.uctrl.Enable = false;
		end

	end
	--]]
end

--更新角色头像的血条进度
function FightUIManager:updateHpProb(headUI)
   local hpPercentage = CheckDiv(headUI.actor:GetCurrentHP() / headUI.actor:GetMaxHP());
	headUI.hpProb.CurValue = hpPercentage * 100;

	--更改血条颜色
	if hpPercentage >= 0.65 then
		headUI.hpProb.ForwardBrush = self.hpFullBrush;
	elseif hpPercentage >= 0.3 then
		headUI.hpProb.ForwardBrush = self.hpHalfBrush;
	else
		headUI.hpProb.ForwardBrush = self.hpEmptyBrush;
	end
end

--创建技能图标
--[[
function FightUIManager:createSkillIcon(index)
	--创建armature
	local skillEffect = Armature( sceneManager:CreateSceneNode('Armature') );

	print('S' .. self.headUIList[index].actor:GetSkill(SkillType.activeSkill):GetSkillID() .. '_tubiao');
	skillEffect:LoadArmature('S' .. self.headUIList[index].actor:GetSkill(SkillType.activeSkill):GetSkillID() .. '_tubiao');
	skillEffect:SetAnimation('appear');
	skillEffect:SetScale(GlobalData.ActorScale, GlobalData.ActorScale, 1);
	skillEffect.ZOrder = FightZOrderList.skillEffect;
	skillEffect:SetScriptAnimationCallback('skillEffectAnimationEnd', index);

	--挂在场景中
	local scene = SceneManager:GetActiveScene();
	scene:GetRootCppObject():AddChild(skillEffect);
	scene:GetRootCppObject():SortChildren();
	return skillEffect;
end
]]

--技能动画动作结束回调函数
function skillEffectAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	if 'appear' == armature:GetAnimation() then
		--出现
		armature:SetAnimation('keep');

	elseif 'disappear' == armature:GetAnimation() then
		--消失
		sceneManager:AddAutoReleaseNode(armature);
	else
		--其他
	end
end

--=====================================================================
--特殊教学技能特效创建
--=====================================================================

--创建教学技能特效
function FightUIManager:CreateTeachingSkillEffect()
	local headUI = FightUIManager.headUIList[FightUIManager.techingSkillEffectPos];
	headUI.skillGuid = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	headUI.skillGuid.Pick = false;
	if ActorManager.user_data.round.roundid == 1000 then
		headUI.skillGuid:LoadArmature('skill_yindao_1');
	else
		headUI.skillGuid:LoadArmature('skill_yindao');
	end
	headUI.skillGuid:SetAnimation('play');
	headUI.skillGuid.ZOrder = 5;
	headUI.skillGuid.Translate = Vector2(-35, 20);
	headUI.uctrl:AddChild(headUI.skillGuid, true);
end

--销毁教学技能特效
function FightUIManager:DestroyTeachingSkillEffect()
	local headUI = FightUIManager.headUIList[FightUIManager.techingSkillEffectPos];

	if headUI.skillGuid ~= nil then
		headUI.uctrl:RemoveChild(headUI.skillGuid);
		headUI.skillGuid = nil;
	end
end

--=====================================================================
--=====================================================================

--播放技能图标特效
--[[
function FightUIManager:playSkillEffect(index)
	local headUI = self.headUIList[index];
	if headUI.skillEffect == nil then
		headUI.skillEffect = self:createSkillIcon(index);
		--计算场景坐标
		local x = headUI.uctrl:GetAbsTranslate().x + headUI.uctrl.RenderSize.Width / 2;
		local y = headUI.uctrl:GetAbsTranslate().y;
		local scenePosition = UIToScenePT(uiCamera, sceneCamera, Vector2(x, y));
		headUI.skillEffect.Translate = Vector3(scenePosition.x, scenePosition.y, 0);

		if nil == headUI.lightEffect then
			headUI.lightEffect = uiSystem:CreateControl('ArmatureUI');
			headUI.lightEffect.Pick = false;
			headUI.lightEffect:LoadArmature('nvhuo');
			headUI.lightEffect:SetAnimation('play');
			headUI.lightEffect:SetScriptAnimationCallback('PveLosePanel:onAnimationCallback', 0);
			headUI.lightEffect:Stop();

			local renderSize = headUI.uctrl.RenderSize;
			headUI.lightEffect.Translate = Vector2(renderSize.Width*0.45, renderSize.Height*0.5);

			headUI.uctrl:AddChild(headUI.lightEffect, true);
		end
		headUI.lightEffect:Replay();
	end
end
]]

--更新技能图标位置
--[[
function FightUIManager:UpdateSkillEffect()
	for _,headUI in ipairs(self.headUIList) do
		if nil ~= headUI.skillEffect then
			--计算场景坐标
			local x = headUI.uctrl:GetAbsTranslate().x + headUI.uctrl.RenderSize.Width / 2;
			local y = headUI.uctrl:GetAbsTranslate().y;
			local scenePosition = UIToScenePT(uiCamera, sceneCamera, Vector2(x, y));
			headUI.skillEffect.Translate = Vector3(scenePosition.x, scenePosition.y, 0);
		end
	end

end
]]


--将技能图标设置成不可用状态
function FightUIManager:SetAllSkillEffectEnable(flag)
	for _,headUI in ipairs(self.headUIList) do
		headUI.enable = flag;
		if (nil ~= headUI.skillEffect) then
			if flag then
				headUI.skillEffect.ShaderType = IRenderer.Scene_NormalShader;
			else
				headUI.skillEffect.ShaderType = IRenderer.Scene_GrayShader;
			end
		end
	end
end

--删除技能图标特效
function FightUIManager:DestroySkillEffect(index)
	local headUI = self.headUIList[index];
	if (headUI ~= nil) then
		if (headUI.skillEffect ~= nil) then					--删除技能图标特效
			local scene = SceneManager:GetActiveScene();
			scene:DetachEffect(headUI.skillEffect);
			headUI.skillEffect = nil;
		end

		if (headUI.lightEffect ~= nil) then					--删除技能出现光效
			headUI.uctrl:RemoveChild(headUI.lightEffect);
			headUI.lightEffect = nil;
		end
	end
end

--删除所有技能图标特效
function FightUIManager:DestroyAllSkillEffect()
	for _,headUI in ipairs(self.headUIList) do
		if (headUI.skillEffect ~= nil) then					--删除技能图标特效
			local scene = SceneManager:GetActiveScene();
			scene:DetachEffect(headUI.skillEffect);
			headUI.skillEffect = nil;
		end

		if (headUI.lightEffect ~= nil) then					--删除技能出现光效
			headUI.uctrl:RemoveChild(headUI.lightEffect);
			headUI.lightEffect = nil;
		end
	end
end

--技能释放时图标爆破
function FightUIManager:DisappearSkillEffect(index)
	local headUI = self.headUIList[index];
	if (headUI ~= nil) then
		if headUI.skillEffect ~= nil then
			headUI.skillEffect:SetAnimation('disappear');	--技能图标爆破
		end
	end
end


--显示手势图片
function FightUIManager:ShowGestureImage(gestureSkillID)
	if nil ~= gestureSkillCenterArmature then
		self.desktop:RemoveChild(gestureSkillCenterArmature);
		FightGestureSkill:RunGestureSkill(curGestureSkillID);						--释放技能
		gestureSkillCenterArmature = nil;
	end

	gestureSkillCenterArmature = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	gestureSkillCenterArmature.Pick = false;
	gestureSkillCenterArmature:LoadArmature('donghua_' .. tostring(gestureSkillID));
	gestureSkillCenterArmature:SetAnimation('play');
	gestureSkillCenterArmature.Horizontal = ControlLayout.H_CENTER;
	gestureSkillCenterArmature.Vertical = ControlLayout.V_CENTER;
	gestureSkillCenterArmature:SetScriptAnimationCallback('FightUIManager:gestureImageAnimationEnd', gestureSkillID);
	self.desktop:AddChild(gestureSkillCenterArmature);
end

--手势图片动画回调函数
function FightUIManager:gestureImageAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	uiSystem:AddAutoReleaseControl(armature);				--销毁特效
	FightGestureSkill:RunGestureSkill(id)					--释放技能
	gestureSkillCenterArmature = nil;
end

--初始化手势技能开启
function FightUIManager:InitGestureSkillOpenFlag(curRoundID)

	local id = resTableManager:GetValue(ResTable.gestureskill, tostring(GestureSkillID.V), 'open');
	if curRoundID == id then		--开启关卡
		gestureSkillOpenFlag[GestureSkillID.V] = (ActorManager.user_data.round.roundid + 1 >= id);
	else							--非开启关卡
		gestureSkillOpenFlag[GestureSkillID.V] = (ActorManager.user_data.round.roundid >= id);
	end
	if gestureSkillOpenFlag[GestureSkillID.V] then		--开放
		gestureSkillLittleIcon[GestureSkillID.V].Visibility = Visibility.Visible;
	else												--非开放
		gestureSkillLittleIcon[GestureSkillID.V].Visibility = Visibility.Hidden;
	end

	id = resTableManager:GetValue(ResTable.gestureskill, tostring(GestureSkillID.Circle), 'open');
	if curRoundID == id then		--开启关卡
		gestureSkillOpenFlag[GestureSkillID.Circle] = (ActorManager.user_data.round.roundid + 1 >= id);
	else							--非开启关卡
		gestureSkillOpenFlag[GestureSkillID.Circle] = (ActorManager.user_data.round.roundid >= id);
	end
	if gestureSkillOpenFlag[GestureSkillID.Circle] then
		gestureSkillLittleIcon[GestureSkillID.Circle].Visibility = Visibility.Visible;
	else
		gestureSkillLittleIcon[GestureSkillID.Circle].Visibility = Visibility.Hidden;
	end

	id = resTableManager:GetValue(ResTable.gestureskill, tostring(GestureSkillID.Lighting), 'open');
	if curRoundID == id then		--开启关卡
		gestureSkillOpenFlag[GestureSkillID.Lighting] = (ActorManager.user_data.round.roundid + 1 >= id);
	else							--非开启关卡
		gestureSkillOpenFlag[GestureSkillID.Lighting] = (ActorManager.user_data.round.roundid >= id);
	end
	if gestureSkillOpenFlag[GestureSkillID.Lighting] then
		gestureSkillLittleIcon[GestureSkillID.Lighting].Visibility = Visibility.Visible;
	else
		gestureSkillLittleIcon[GestureSkillID.Lighting].Visibility = Visibility.Hidden;
	end

	id = resTableManager:GetValue(ResTable.gestureskill, tostring(GestureSkillID.Z), 'open');
	if curRoundID == id then		--开启关卡
		gestureSkillOpenFlag[GestureSkillID.Z] = (ActorManager.user_data.round.roundid + 1 >= id);
	else							--非开启关卡
		gestureSkillOpenFlag[GestureSkillID.Z] = (ActorManager.user_data.round.roundid >= id);
	end
	if gestureSkillOpenFlag[GestureSkillID.Z] then
		gestureSkillLittleIcon[GestureSkillID.Z].Visibility = Visibility.Visible;
	else
		gestureSkillLittleIcon[GestureSkillID.Z].Visibility = Visibility.Hidden;
	end

end

--播放手势能量增加的特效
function FightUIManager:PlayGesturePowerRaiseEffect()
	local armatureUI = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	armatureUI.Pick = false;
	armatureUI:LoadArmature('hunpo_2');
	armatureUI:SetAnimation('play');

	local renderSize = gesturePanel.RenderSize;
	--armatureUI.Translate = Vector2(renderSize.Width * 0.5, renderSize.Height * (gesture_progressbar.MaxValue - gesture_progressbar.CurValue) / gesture_progressbar.MaxValue);
	gesturePanel:AddChild(armatureUI);
end

--播放手势特效的持续火焰特效
function FightUIManager:PlayGestureSkillKeepEffect(skillID)
	local armatureUI = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	armatureUI.Pick = false;
	armatureUI:LoadArmature('man');
	armatureUI:SetAnimation('play');

	local margin = gestureSkillLittleIcon[skillID].Margin;
	armatureUI.Translate = Vector2(margin.Left + 28 , margin.Top + 7);

	gesturePanel:AddChild(armatureUI);
	armatureUI:BringToBack();							--放到图层最下面
	return armatureUI;
end

--播放手势技能可用特效(flag代表是否播放开启特效)
function FightUIManager:PlayGestureSkillAvailableEffect()
	for skillID,power in pairs(powerStepList) do
		if (gesture_progressbar.CurValue == power) and (gestureSkillOpenFlag[skillID])then
			--播放能量槽发光特效
			--self:PlayEnergyTankLightEffect();
			--播放特效
			local armature = uiSystem:CreateControl('ArmatureUI');
			armature.Pick = false;
			armature:LoadArmature(tostring(skillID));	--skillID为手势技能编号，动画命名与此一致，方便查找
			armature:SetAnimation('play');
			armature.Horizontal = ControlLayout.H_CENTER;
			armature.Vertical = ControlLayout.V_CENTER;
			armature.Translate = Vector2(10, -5);

			armature:SetScriptAnimationCallback('FightUIManager:availableAnimationEnd', skillID);
			gestureSkillLittleIcon[skillID]:AddChild(armature);

			--触发可以释放手势技能事件
			EventManager:FireEvent(EventType.CanPlayGestureSkill, skillID);
			return;
		end
	end
end

--可用特效的回调函数
function FightUIManager:availableAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	--自动销毁
	uiSystem:AddAutoReleaseControl(armature);
	--播放持续特效,判断当前能量是否大于该技能所需的能量，防止特效出现之前能量已经被用到
	if (gesture_progressbar.CurValue >= powerStepList[id]) and (gestureSkillLittleIcon[id].fireEffect == nil) then
		gestureSkillLittleIcon[id].fireEffect = self:PlayGestureSkillKeepEffect(id);
	end
end

--更新手势能量的持续特效显示
function FightUIManager:UpdateGestureSkillKeepEffect()
	for skillID, step in pairs(powerStepList) do
		if gestureSkillOpenFlag[skillID] then					--判断该技能已经开启
			if (step > gesture_progressbar.CurValue) and (gestureSkillLittleIcon[skillID].fireEffect ~= nil) then
				gesturePanel:RemoveChild(gestureSkillLittleIcon[skillID].fireEffect);
				gestureSkillLittleIcon[skillID].fireEffect = nil;
			end
		end
	end
end

function FightManager:ShowUserGuideInfo()
	self.desktop:GetLogicChild('info').Visibility = Visibility.Visible;
end


--释放技能
--[[
function FightUIManager:RunSkill(headUI)
	--手动战斗
	if FightManager:IsAuto() == false and (not FightManager.isOver) and (headUI.enable) then
		headUI.actor:SetRunningState(true);					--强制更新
		headUI.skillEffect:SetAnimation('disappear');			--技能图标爆破
		if (headUI.skillGuid ~= nil) then						--删除技能引导特效
			headUI.uctrl:RemoveChild(headUI.skillGuid);
			headUI.skillGuid = nil;
		end

		--将技能释放标志位设置为true
		local activeSkill = headUI.actor:GetSkill(SkillType.activeSkill);
		if activeSkill ~= nil then
			headUI.actor:SetShowSkillFlag(true);
			activeSkill:SetReleaseFlag(true);
		end

		PlaySound('combo1');									--播放技能音效
	end
end
]]

--设置手势技能是否可以释放
function FightUIManager:SetCanReleaseGestureSkill(flag)
	canReleaseGestureSkill = flag;
end

--执行手势技能position为UI坐标
function FightUIManager:RunGestureSkill(gesture)
	if not isGestureSkillAvailable then
		return;
	end

	if not canReleaseGestureSkill then
		--如果手势技能释放标志位为false
		return;
	end

	--[[	if not FightManager:IsRunning() then
	--如果游戏处于暂停状态，则不触发手势技能
	return;
end--]]

local flag = false;		--是否释放手势技能

if GestureType.V == gesture then
	if gestureSkillOpenFlag[GestureSkillID.V] then
		if (gesture_progressbar.CurValue >= powerStepList[GestureSkillID.V]) then
			gesture_progressbar.CurValue = gesture_progressbar.CurValue - powerStepList[GestureSkillID.V];
			self:ShowGestureImage(GestureSkillID.V);
			self:DestroyTeachGestureSkillEffect();
			curGestureSkillID = GestureSkillID.V;
			flag = true;

			--触发释放手势技能事件
			EventManager:FireEvent(EventType.PlayGestureSkill, GestureSkillID.V);
		else
			self:EnergyNotEnoughTip();
		end
	end

elseif GestureType.Circle == gesture then
	if gestureSkillOpenFlag[GestureSkillID.Circle] then
		if (gesture_progressbar.CurValue >= powerStepList[GestureSkillID.Circle]) then
			gesture_progressbar.CurValue = gesture_progressbar.CurValue - powerStepList[GestureSkillID.Circle];
			self:ShowGestureImage(GestureSkillID.Circle);
			self:DestroyTeachGestureSkillEffect();
			curGestureSkillID = GestureSkillID.Circle;
			flag = true;

			--触发释放手势技能事件
			EventManager:FireEvent(EventType.PlayGestureSkill, GestureSkillID.Circle);
		else
			self:EnergyNotEnoughTip();
		end
	end

elseif GestureType.Lighting == gesture then
	if gestureSkillOpenFlag[GestureSkillID.Lighting] then
		if (gesture_progressbar.CurValue >= powerStepList[GestureSkillID.Lighting]) then
			gesture_progressbar.CurValue = gesture_progressbar.CurValue - powerStepList[GestureSkillID.Lighting];
			self:ShowGestureImage(GestureSkillID.Lighting);
			self:DestroyTeachGestureSkillEffect();
			curGestureSkillID = GestureSkillID.Lighting;
			flag = true;

			--触发释放手势技能事件
			EventManager:FireEvent(EventType.PlayGestureSkill, GestureSkillID.Lighting);
		else
			self:EnergyNotEnoughTip();
		end
	end

elseif GestureType.Z == gesture then
	if gestureSkillOpenFlag[GestureSkillID.Z] then
		if (gesture_progressbar.CurValue >= powerStepList[GestureSkillID.Z]) then
			gesture_progressbar.CurValue = gesture_progressbar.CurValue - powerStepList[GestureSkillID.Z];
			self:ShowGestureImage(GestureSkillID.Z);
			self:DestroyTeachGestureSkillEffect();
			curGestureSkillID = GestureSkillID.Z;
			flag = true;

			--触发释放手势技能事件
			EventManager:FireEvent(EventType.PlayGestureSkill, GestureSkillID.Z);
		else
			self:EnergyNotEnoughTip();
		end
	end

else			--其他

end

if flag then
	self:UpdateGestureSkillKeepEffect();					--更新手势能量的持续特效显示
	EventManager:FireEvent(EventType.ShowGestureSkill);		--触发展示手势技能事件
end
end

--播放手势技能教学特效
function FightUIManager:PlayTeachGestureSkillEffect(skillID)
	if nil ~= gestureArmature then
		return;
	end
	gestureArmature = uiSystem:CreateControl('ArmatureUI');
	gestureArmature.Pick = false;
	gestureArmature:LoadArmature('jiaoxue_' .. skillID);
	gestureArmature:SetAnimation('play');
	gestureArmature.Horizontal = ControlLayout.H_CENTER;
	gestureArmature.Vertical = ControlLayout.V_CENTER;
	gestureArmature.Translate = Vector2(0, 0);
	self.desktop:AddChild(gestureArmature);
end

--删除手势技能教学特效
function FightUIManager:DestroyTeachGestureSkillEffect()
	if nil ~= gestureArmature then
		self.desktop:RemoveChild(gestureArmature);
		gestureArmature = nil;
	end
end

--添加初始手势能量点
function FightUIManager:AddInitGesturePower(power)
	for index = 1, power do
		self:AddGesturePower();
	end
end

--增加手势能量点
function FightUIManager:AddGesturePower()
	if not isGestureSkillAvailable then
		return;
	end

	if gesture_progressbar.CurValue < gesture_progressbar.MaxValue then
		gesture_progressbar.CurValue = gesture_progressbar.CurValue + 1;
		--self:PlayGesturePowerRaiseEffect();									--播放能量上升特效
		--self:PlayGestureSkillAvailableEffect();								--播放手势技能可释放特效

		self:AutoReleaseGestureSkill();									--自动释放手势技能
	end
end

--获取手势能量点
function FightUIManager:GetGesturePower()
	return gesture_progressbar.CurValue;
end

--自动战斗时能量点增加触发自动释放手势技能
--如果闪电技能没有开启，则自动释放陨石技能，否则释放闪电技能
function FightUIManager:AutoReleaseGestureSkill()
	if not FightManager:IsAuto() then
		return;
	end

	if gestureSkillOpenFlag[GestureSkillID.Lighting] then
		if gesture_progressbar.CurValue >= powerStepList[GestureSkillID.Lighting] then
			--闪电技能开启
			self:RunGestureSkill(GestureType.Lighting);
		end

	elseif gestureSkillOpenFlag[GestureSkillID.V] and gesture_progressbar.CurValue >= powerStepList[GestureSkillID.V] then
		--陨石技能开启
		self:RunGestureSkill(GestureType.V);
	end
end

--屏蔽手势技能能量点
function FightUIManager:ShieldGestureSkill()
	--gesturePanel.Visibility = Visibility.Hidden;
	isGestureSkillAvailable = false;
end

--播放手势能量槽发光特效
function FightUIManager:PlayEnergyTankLightEffect()
	local energyTankLightEffect = ArmatureUI(uiSystem:CreateControl('ArmatureUI'));
	energyTankLightEffect.Pick = false;
	energyTankLightEffect:LoadArmature('nengliangcao_shan');
	energyTankLightEffect:SetAnimation('play');
	energyTankLightEffect.Horizontal = ControlLayout.H_CENTER;
	energyTankLightEffect.Vertical = ControlLayout.V_CENTER;
	energyTankLightEffect.Translate = Vector2(2, 0);
	energyTankLightEffect.ZOrder = -2;
	gesturePanel:AddChild(energyTankLightEffect);
end

--播放能量槽出现特效
function FightUIManager:PlayEnergyTankEffect()
	--gesturePanel.Visibility = Visibility.Hidden;

	local armature = uiSystem:CreateControl('ArmatureUI');
	armature.Pick = false;
	armature:LoadArmature('shenjichuxian_1');
	armature:SetAnimation('play');
	armature:SetScriptAnimationCallback('FightUIManager:EnergyTankAnimationEnd', 0);
	gesturePanel:ForceLayout();
	armature.Translate = Vector2(gesturePanel:GetAbsTranslate().x, gesturePanel:GetAbsTranslate().y - 10);

	self.desktop:AddChild(armature);
end

--能量槽播放特效的回调函数
function FightUIManager:EnergyTankAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	uiSystem:AddAutoReleaseControl(armature);				--销毁特效
	gesturePanel.Visibility = Visibility.Visible;			--显示能量槽面板
end

--能量不足提示
function FightUIManager:EnergyNotEnoughTip()
	powerEnoughTip.Text = LANG_fightUIManager_1;
	powerEnoughTip.Visibility = Visibility.Visible;
	powerTipLastTime = Configuration.GesturePowerTipLastTime;
end

--boss狂暴提示
function FightUIManager:AddBossFrencyTip(text)
	powerEnoughTip.Text = text;
	powerEnoughTip.Visibility = Visibility.Visible;
	powerTipLastTime = Configuration.BossFrencyTipLastTime;
end

--创建bossUI
function FightUIManager:createBossUI()
	local bossUI = {};
	bossUI.curHpIndex = 0;

	--获取boss UI控件
	bossUI.panel = Panel(self.desktop:GetLogicChild('bossPanel1'));
	bossUI.backHpProb = EffectProgressBar(bossUI.panel:GetLogicChild('hpProb2'));
	bossUI.backHpProb.MaxValue = 100;
	bossUI.backHpProb.CurValue = 100;
	bossUI.forwardHpProb = EffectProgressBar(bossUI.panel:GetLogicChild('hpProb1'));
	bossUI.hpProbCount = Label(bossUI.panel:GetLogicChild('hpProbCount'));
	bossUI.headPic = ImageElement(bossUI.panel:GetLogicChild('headPic'));
	bossUI.name = ImageElement(bossUI.panel:GetLogicChild('name'));
	bossUI.lv = bossUI.panel:GetLogicChild('lv');

	--设置控件属性
	bossUI.panel.Visibility = Visibility.Hidden;
	bossUI.hpProbCount.Visibility = Visibility.Visible;
	bossUI.panel.Enable = true;

	return bossUI;
end

--显示bossUI头像
function FightUIManager:ShowBossUI(boss)
	self.bossUI.boss = boss;
	--设置boss名字
	self.bossUI.name.Text = boss:GetActorName();
	--设置boss头像
	local imgPath = resTableManager:GetValue(ResTable.monster, tostring(boss:GetResID()), 'icon');

	local headPicPath = 'navi/' .. imgPath .. '.ccz';
	self.bossUI.headPic.Image = GetPicture(headPicPath);
	--每一个血条的血量
	self.bossUI.hp = CheckDiv(boss:GetMaxHP() / boss:GetHpProbCount());
	self.bossUI.curHpIndex = math.min(math.ceil(self.bossUI.boss:GetCurrentHP()/self.bossUI.hp), 7);
	preBossHpIndex = self.bossUI.curHpIndex;
	self.bossUI.hpProbCount.Text = '×' .. self.bossUI.curHpIndex;

	--设置血条进度
	self.bossUI.forwardHpProb.MaxValue = self.bossUI.hp;
	self.bossUI.forwardHpProb.CurValue = self.bossUI.boss:GetCurrentHP() - (self.bossUI.curHpIndex - 1) * self.bossUI.hp;
	self.bossUI.forwardHpProb.EffectSpeed = self.bossUI.hp / 2;

	--设置血条颜色
	self.bossUI.forwardHpProb.ForwardBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex);
	self.bossUI.forwardHpProb.EffectBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex);

	if preBossHpIndex == 1 then
		self.bossUI.backHpProb.Visibility = Visibility.Hidden;
	else
		self.bossUI.backHpProb.Visibility = Visibility.Visible;
		self.bossUI.backHpProb.ForwardBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex - 1);
	end

	self.bossUI.lv.Text = tostring(self.bossUI.boss.m_level);

	--设置boss血条,必须放在maxValue初始化之后
	--self:SetBossHpProbForwardBrush();
	--显示
	FightUIManager:setFightGuidePanel(false);
	self.bossUI.panel.Visibility = Visibility.Visible;
end

--更新bossUI
function FightUIManager:UpdateBossUI()
	self.bossUI.curHpIndex = math.min(math.ceil(self.bossUI.boss:GetCurrentHP()/self.bossUI.hp), 7);
	if FightType.noviceBattle == FightManager:GetFightType() and self.bossUI.boss:GetCurrentHP() <= (self.bossUI.boss:GetMaxHP()* 0.5) and not self.isTraggerLastSkill then
		FightManager:AddTotalAnger(100)
		self.isTraggerLastSkill = true
	end
	self.bossUI.forwardHpProb.CurValue = self.bossUI.boss:GetCurrentHP() - (self.bossUI.curHpIndex - 1) * self.bossUI.hp;
	if preBossHpIndex ~= self.bossUI.curHpIndex then
		--self:SetBossHpProbForwardBrush();
		preBossHpIndex = self.bossUI.curHpIndex;
		self.bossUI.hpProbCount.Text = '×' .. self.bossUI.curHpIndex;
		--设置血条颜色
		self.bossUI.forwardHpProb.ForwardBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex);
		self.bossUI.forwardHpProb.EffectBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex);
		if preBossHpIndex == 1 then
			self.bossUI.backHpProb.Visibility = Visibility.Hidden;
		else
			self.bossUI.backHpProb.Visibility = Visibility.Visible;
			self.bossUI.backHpProb.ForwardBrush = Converter.String2Brush(BOSSHPCOLORPATH .. preBossHpIndex - 1);
		end
	end
	--设置血条进度
	self.bossUI.forwardHpProb.MaxValue = self.bossUI.hp;
	self.bossUI.forwardHpProb.CurValue = self.bossUI.boss:GetCurrentHP() - (self.bossUI.curHpIndex - 1) * self.bossUI.hp;
	self.bossUI.forwardHpProb.EffectSpeed = self.bossUI.hp / 2;

	if self.bossUI.boss:GetFighterState() == FighterState.death then
		self.bossUI.panel.Enable = false;
	end
end

--设置bossUI血条的前景色
function FightUIManager:SetBossHpProbForwardBrush()
	if 0 == self.bossUI.curHpIndex then
		self.forwardBrush = nil;
		self.effectBrush = nil;
		self.backBrush = nil;

	elseif 1 == self.bossUI.curHpIndex then
		self.forwardBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwardBrush1', 'godsSenki'));
		self.effectBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwardBrush1', 'godsSenki'));
		--self.bossUI.backHpProb.Visibility = Visibility.Hidden;
		self.backBrush = nil;
	else
		self.forwardBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwardBrush' .. self.bossUI.curHpIndex, 'godsSenki'));
		self.effectBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwardBrush' .. self.bossUI.curHpIndex, 'godsSenki'));
		local index = self.bossUI.curHpIndex - 1;
		self.backBrush = CenterStretchBrush(uiSystem:FindResource('bossHpForwardBrush' .. index, 'godsSenki'));
	end
	if 0 == self.bossUI.curHpIndex then
		self.bossUI.hpProbCount.Visibility = Visibility.Hidden;
	else
		self.bossUI.hpProbCount.Text = '×' .. self.bossUI.curHpIndex;
	end

	self.bossUI.forwardHpProb.ForwardBrush = self.forwardBrush;
	self.bossUI.forwardHpProb.EffectBrush = self.effectBrush;
	self.bossUI.backHpProb.ForwardBrush = self.backBrush;

end

--更新总怒气进度条
function FightUIManager:UpdateTotalAngerBar()
	local anger = FightManager:getTotalAnger();
	self.angerBar.CurValue = anger;
end

--更新敌人总怒气进度条
function FightUIManager:UpdateTotalEnemyAngerBar()
	local anger = FightManager:getTotalEnemyAnger();
	self.enemyAngerBar.CurValue = anger;
end

function FightUIManager:resumeTime()
	is_pause = is_pause - 1;
	if is_pause <= 0 then
		is_pause = 0
	else
		return;
	end
	self.timeControl.pauseEnd = os.clock();
	self.timeControl.pauseGone = self.timeControl.pauseGone + (self.timeControl.pauseEnd - self.timeControl.pauseStart);
end

function FightUIManager:pauseTime()
	is_pause = is_pause + 1;
	if is_pause > 1 then
		return;
	end
	self.timeControl.pauseStart = os.clock();
end

function FightUIManager:endTime()
	self.timeControl.isGameOver = true;
end

function FightUIManager:Active()
	uiSystem:SwitchToDesktop(self.desktop);
end

function FightUIManager:UpdateDebugPanel(elapse)
	if not self.debugItemList then
		return
	end
	__.each(self.debugItemList, function(item)
		item:GetLogicChild(0):GetLogicChild('name').Text = item.actor:getName();
		item:GetLogicChild(0):GetLogicChild('curskill').Text = item.actor:getSkill();
		item:GetLogicChild(0):GetLogicChild('state').Text = item.actor:getState();
		item:GetLogicChild(0):GetLogicChild('buff').Text = item.actor:getBuff();
		item:GetLogicChild(0):GetLogicChild('action').Text = item.actor:getAction();
	end)
end

function FightUIManager:addDebugItem(actor, isEnemy)
	local list = nil;
	if isEnemy then
		list = self.rightList;
	else
		list = self.leftList;
	end

	local item =  uiSystem:CreateControl('DebugItemTemplate') ;
	item.Pick = false;
	item:GetLogicChild(0).Pick = false;
	--互相关联
	actor.debugItem = item;
	item.actor = actor;

	table.insert(self.debugItemList, item);
	list:AddChild(item);
end

function FightUIManager:addTraceItem(effect)
	if not debugtracemode then
		return;
	end
	local item =  uiSystem:CreateControl('TraceItemTemplate') ;
	item.Pick = false;
	item:GetLogicChild(0).Pick = false;
	--互相关联
	effect.item = item;
	item.effect = effect;


	self.traceList:AddChild(item)
end

function FightUIManager:destroyTraceItem(effect)
	self.traceList:RemoveChild(effect.item);
end

function FightUIManager:updateTraceItem(effect)
	local item = effect.item;
	if not item then return end;

	local id = effect.id
	local time = effect.lastTime;
	local _type = effect.flightPathType;
	local dir = effect.dir == 1 and ">>" or "<<";
	local translate = effect:GetCppObject().Translate
	local pos = math.floor(translate.x) .. "/" .. math.floor(translate.y);
	item:GetLogicChild(0):GetLogicChild('id').Text = tostring(id);
	item:GetLogicChild(0):GetLogicChild('time').Text = tostring(time);
	item:GetLogicChild(0):GetLogicChild('type').Text = tostring(_type) .. "," ..tostring(dir);
	item:GetLogicChild(0):GetLogicChild('pos').Text = tostring(pos);
	--item:GetLogicChild(0):GetLogicChild('id').Text = tostring(id);
end

--设置新手引导战斗描述提示
function FightUIManager:setFightGuidePanel(flag)
	
	if flag then
		fightGuidePanel.Visibility = Visibility.Visible;
	else
		fightGuidePanel.Visibility = Visibility.Hidden;
	end
end

--设置新手引导战斗怒气提示
function FightUIManager:setAngerGuidePanel(flag)
	if flag then
		angerGuidePanel.Visibility = Visibility.Visible;
	else
		angerGuidePanel.Visibility = Visibility.Hidden;
	end
end

--设置新手引导战斗信息提示
function FightUIManager:setInfoGuidePanel(flag)
	if flag then
		infoGuidePanel.Visibility = Visibility.Visible;
	else
		infoGuidePanel.Visibility = Visibility.Hidden;
	end
end
