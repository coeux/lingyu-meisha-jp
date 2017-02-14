--roleLevelUpPanel.lua

--========================================================================
--角色升级面板

RoleLevelUpPanel =
	{
		speed	= 40;
		isRoleLevelUpOpen = false;
	};

--变量
local tiliTimer = 0;		--体力动画timer
local curTili = 0;			--当前体力值
local targetTili = 0;		--目标体力值
local startTime = 0;		--体力特效开始时间

--ui
local mainDesktop;
local panel;

local effect;
local level1;
local level2;
local hp1;
local hp2;
local attackName;
local attack1;
local attack2;
local phDef1;
local phDef2;
local magDef1;
local magDef2;
local potential1;
local potential2;
local tili;
local tiliValue;


local roleLevelUpPanel
local levelNum
local levelUpBg
local sureBtn
local blackBG

local preFP
local preLife
local prePhysicAtt
local prePhysicDef
local preMagicAtt
local preMagicDef
local postFP
local postLife
local postPhysicalAtt
local postPhysicalDef
local postMagicAtt
local postMagicDef

local armature     --  特效
local armature1
local effectArmature

local lableList = {}
local index = 1

--初始化面板
function RoleLevelUpPanel:InitPanel( desktop )
		
	--变量初始化
	tiliTimer = 0;		--体力动画timer
	curTili = 0;
	targetTili = 0;
	startTime = 0;

	--界面初始化
	mainDesktop = desktop;
	roleLevelUpPanel = desktop:GetLogicChild('roleLevelUpPanel')
	roleLevelUpPanel:IncRefCount()
	roleLevelUpPanel.ZOrder = 10000
	roleLevelUpPanel.Visibility = Visibility.Hidden
	levelNum = roleLevelUpPanel:GetLogicChild('wingImg'):GetLogicChild('levelNum')
	levelUpBg = roleLevelUpPanel:GetLogicChild('bg')
	levelUpBg.Visibility = Visibility.Hidden;
	sureBtn = roleLevelUpPanel:GetLogicChild('sureBtn')
	sureBtn.Visibility = Visibility.Hidden
	--roleLevelUpPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','RoleLevelUpPanel:onClose')
	self.info = roleLevelUpPanel:GetLogicChild('info');
	self.info.Text = InfoGuidePanel_Lang_3;
	self.info.Visibility = Visibility.Hidden;

	blackBG = roleLevelUpPanel:GetLogicChild('blackBG')
	preFP = blackBG:GetLogicChild('preFP')
	preLife = blackBG:GetLogicChild('preLife')
	prePhysicAtt = blackBG:GetLogicChild('prePhysicAtt')
	prePhysicDef = blackBG:GetLogicChild('prePhysicDef')
	preMagicAtt = blackBG:GetLogicChild('preMagicAtt')
	preMagicDef = blackBG:GetLogicChild('preMagicDef')

	postFP = blackBG:GetLogicChild('postFP')
	postLife = blackBG:GetLogicChild('postLife')
	postPhysicalAtt = blackBG:GetLogicChild('postPhysicalAtt')
	postPhysicalDef = blackBG:GetLogicChild('postPhysicalDef')
	postMagicAtt = blackBG:GetLogicChild('postMaigcAtt')
	postMagicDef = blackBG:GetLogicChild('postMaigcDef')

	roleLevelUpPanel:GetLogicChild('wingImg').Visibility = Visibility.Hidden

	lableList[1] = postFP
	lableList[2] = postLife
	lableList[3] = postPhysicalAtt
	lableList[4] = postPhysicalDef
	lableList[5] = postMagicAtt
	lableList[6] = postMagicDef
end

--销毁
function RoleLevelUpPanel:Destroy()
	-- panel:DecRefCount();
	-- panel = nil;
	roleLevelUpPanel:DecRefCount()
	roleLevelUpPanel = nil
end
--显示
function RoleLevelUpPanel:Show()
	
	--新手引导特殊处理
	if Task:getMainTaskId() == 100002 then
		Task.currentNpc = 116;
		TaskDialogPanel:onShowDialog()
		UserGuidePanel:SetIsLvUp(false)
		return
	end

	if Task:getMainTaskId() == 100003 then
		TaskDialogPanel:Hide();
		UserGuidePanel:SelectAndEnterGuidence();
		UserGuidePanel:SetIsLvUp(false);
		--UserGuidePanel:ShowGuideShade(LimitTaskPanel:getUserGuidePartnerGoBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		return
	end

	roleLevelUpPanel:GetLogicChild('wingImg').Image = GetPicture('common/hunshi_levelup.ccz');
	roleLevelUpPanel:GetLogicChild('wingImg'):GetLogicChild('titlePic1').Image = GetPicture('common/levelup_title_1.ccz');
	roleLevelUpPanel:GetLogicChild('wingImg'):GetLogicChild('titlePic2').Image = GetPicture('common/levelup_title_2.ccz');

	local oldHeroPro = NetworkMsg_Data.heroPro
	local newHeroPro = ActorManager.user_data.role.pro

	if armature then
		armature:Destroy()
	end
	self.isRoleLevelUpOpen = true
	--显示特效
	-- local path = GlobalData.EffectPath .. 'zhandoushengli_output/'
	-- AvatarManager:LoadFile(path)             --   载入动画
	--armature = PlayEffect('zhandoushengli_output/', Rect(0,100, 0, 90), 'guang',roleLevelUpPanel)
	--armature.ZOrder = -10
	--armature.Translate = Vector2(0, -200)
	--显示数值
	local oldLevel = GodsSenki:getOldHeroLevel() or 0;
	levelNum.Text = oldLevel..'→'..tostring(ActorManager.user_data.role.lvl.level)

	preFP.Text = tostring(oldHeroPro.fp)
	postFP.Text = tostring(newHeroPro.fp)
	preLife.Text = tostring(oldHeroPro.hp)
	postLife.Text = tostring(newHeroPro.hp)

	prePhysicAtt.Text = tostring(oldHeroPro.attack)
	postPhysicalAtt.Text = tostring(newHeroPro.attack) 
	prePhysicDef.Text =  tostring(oldHeroPro.def)
	postPhysicalDef.Text = tostring(newHeroPro.def)

	preMagicAtt.Text = tostring(oldHeroPro.mgc)
	postMagicAtt.Text = tostring(newHeroPro.mgc)
	preMagicDef.Text = tostring(oldHeroPro.res)
	postMagicDef.Text = tostring(newHeroPro.res)

	blackBG.Visibility = Visibility.Hidden;
	levelUpBg.Visibility = Visibility.Visible;
	roleLevelUpPanel.Visibility = Visibility.Visible
	mainDesktop:DoModal(roleLevelUpPanel)
	StoryBoard:ShowUIStoryBoard(roleLevelUpPanel,StoryBoardType.ShowUI1)
	self:displayPropertyEffect()

	--  播放升级音效
	-- SoundManager:PlayEffect('user_level_up')
end

function RoleLevelUpPanel:displayPropertyEffect(  )

	--  播放属性变化特效
	local path = GlobalData.EffectPath .. 'rolelevelup_output/'
	AvatarManager:LoadFile(path)

	effectArmature = ArmatureUI(uiSystem:CreateControl('ArmatureUI'))
	effectArmature.pick = false
	effectArmature.Horizontal = ControlLayout.H_CENTER
	effectArmature.Vertical = ControlLayout.V_CENTER
	--effectArmature.Margin = Rect(-100,0,0,0)
	effectArmature:LoadArmature('yanchu')
	effectArmature:SetAnimation('play')
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) <= (960/640) then
	    effectArmature:SetScale(2,2);
	else
	    effectArmature:SetScale(2.1,2);
	end
	--effectArmature:SetScriptAnimationCallback('RoleLevelUpPanel:nextEffect', 0)
	effectArmature:SetScriptAnimationCallback('RoleLevelUpPanel:onClose', 0)
	levelUpBg:AddChild(effectArmature)
end

-- function RoleLevelUpPanel:nextEffect( armature )
-- 	print("Index = ", index)
-- 	if armature:GetAnimation() == 'play' and index < 6 then
-- 		index = index + 1
-- 		self:displayPropertyEffect( index )
-- 	else
-- 	end
-- end

--打开动画结束
function RoleLevelUpPanel:onUserGuid()
	if tili.CurValue < tili.MaxValue then
		curTili = tili.CurValue;
		startTime = appFramework:GetAllRunningTime();
		tiliTimer = timerManager:CreateTimer(0.01, 'RoleLevelUpPanel:updateTiliEffect', 0);
	end
end

--更新体力效果
function RoleLevelUpPanel:updateTiliEffect()
	local cur = curTili + (appFramework:GetAllRunningTime() - startTime) * self.speed;
	tili.CurValue = cur;

	if cur >= targetTili then
		tili.CurValue = targetTili;
		timerManager:DestroyTimer(tiliTimer);
		tiliTimer = 0;
	end
end

--隐藏
function RoleLevelUpPanel:Hide()
	
	-- effect:Destroy();
	--取消模式对话框
	--topDesktop:UndoModal();

	--增加UI消失时的效果
	-- StoryBoard:HideTopUIStoryBoard(panel, StoryBoardType.HideUI2, 'StoryBoard::OnPopTopUI');
	self.isRoleLevelUpOpen = false

	if armature then
		armature:Destroy()
	end
	
	levelUpBg.Visibility = Visibility.Hidden
	roleLevelUpPanel.Visibility = Visibility.Hidden
	mainDesktop:UndoModal()
	StoryBoard:HideTopUIStoryBoard(roleLevelUpPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopTopUI')
end

--========================================================================
--界面响应
--========================================================================

--返回
function RoleLevelUpPanel:onClose()
	self:Hide()	
	UserGuidePanel:SelectAndEnterGuidence();
	local index = ActorManager.user_data.reward.lg_days;
	if index and ActorManager.user_data.role.lvl.level == 17 and Task:getMainTaskId() >= 100017 and Task:getMainTaskId() <= 100018 then
		if ActorManager.user_data.extra_data.is_get_notlogin_reward == 1 then
			ThirtyDaysNotLoginRewardPanel:firstShow();
		else
			TomorrowRewardPanel:showTomorrowReward();
			--弹出次日奖励
			--[[
			local index = ActorManager.user_data.reward.lg_days;
			if index and ActorManager.user_data.role.lvl.level == 17 and Task:getMainTaskId() >= 100017 and Task:getMainTaskId() <= 100018 then
				TomorrowRewardPanel.fromRoleLevelUpPanel = true;
				if #TomorrowRewardPanel.receiveDay > 0 then
					local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));
		
					if rowData1 then
						TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
					else
						local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
						TomorrowRewardPanel:onShowRewardInfo(count, false);
					end
				else
					--获得下一次可怜领取奖励的时间
					local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
					TomorrowRewardPanel:onShowRewardInfo(count, false);
				end
				RolePortraitPanel:UpdateMainTaskHandle();
			end
			]]
		end
		RolePortraitPanel:UpdateMainTaskHandle();
	end
	if ActorManager.user_data.role.lvl.level == FunctionOpenLevel.chipsmash then
		UserGuidePanel:GetNewSystem(UserGuideIndex.chipsmash)
	end
	--触发新手引导箭头
	--UserGuidePanel:TriggerAutoTaskGuide();
	UserGuidePanel:SetIsLvUp(false);
end
