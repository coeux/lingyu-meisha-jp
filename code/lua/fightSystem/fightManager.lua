--fightManager.lua

--========================================================================
--战斗管理者类

FightManager =
{
	isPanelInit        = false;                     -- 战斗UI是否经过初始化
	isAuto             = false;                     -- 是否自动战斗
	isOver             = true;                      -- 战斗结束标志
	isPvP              = false;                     -- 是否为PVP模式
	hasBoss            = false;                     -- 关卡是否有boss
	state              = FightState.none;           -- 是否为战斗模式
	mFightType         = FightType.normal;          -- 战斗类型
	isRecord           = false;                     -- 记录是否录像
	cameraMoveSpeed    = 50;                        -- 相机移动速度
	-- pveLeftPos         = Vector3(0,0,0);         -- pve左边出生点lo
	-- pvpLeftPos         = Vector3(-473,0,0);         -- pvp左边出生点
	leftPos            = nil;                       -- 左边出生地点
	-- rightPos           = Vector3(2000,0,0);          -- 右边出生点
	frontPositionList  = {};                        -- 敌我双方最前方的角色位置
	yOrderList         = Configuration.YOrderList;
	zOrderList         = {-100, -50, 0, 50, 100};   -- 图层优先级

	-- 人物行间距
	interval = {
		[Configuration.YOrderList[1]] = 0;
		[Configuration.YOrderList[2]] = math.abs(Configuration.YOrderList[2] - Configuration.YOrderList[1]);
		[Configuration.YOrderList[3]] = math.abs(Configuration.YOrderList[3] - Configuration.YOrderList[1]);
		[Configuration.YOrderList[4]] = math.abs(Configuration.YOrderList[4] - Configuration.YOrderList[1]);
		[Configuration.YOrderList[5]] = math.abs(Configuration.YOrderList[5] - Configuration.YOrderList[1]);
	};

	time               = 0;                         -- 战斗系统时间
	recordPauseTime    = 0;                         -- 录像暂停时间
	actorList          = {};                        -- 所有角色列表
	needleftActorList  = {};                        -- 左侧准备入场的ActorList
	needrightActorList = {};                        -- 右侧准备入场的ActorList
	idleMonsterList    = {};                        -- 右侧提前入场，在战场待机的怪物
	leftActorList      = {};                        -- 左侧的ActorList
	rightActorList     = {};                        -- 右侧的ActorList
	constLeftActorList = {};                        -- 战斗中永远保存友方角色的列表

	leftTotalAnger      = 0;                         -- 左侧总怒气值
	leftAngerMaxTimes   = 0; 												 -- 左侧怒气满次数（包含怒气满但无卡牌情况）
	rightTotalAnger     = 0;                         -- 左侧总怒气值
	tagFighter          = nil;                       -- 手动选择的目标

	--关卡产出
	goodsKindList        = {};                 -- 掉落物品列表
	rmb                  = nil;                -- 掉落水晶个数
	coin                 = nil;                -- 掉落金币数量
	soul                 = nil;                -- 掉落灵能数量
	jifen                = nil;                -- 乱斗场积分
	exp                  = nil;                -- 关卡经验
	lovevalue			   = nil;				 -- 关卡爱恋度数值
	zhanli               = nil;                -- pvp战斗奖励的战历
	level                = nil;                -- 如果主角升级，存储升级后的等级
	stars                = nil;                -- 该关卡获得的星星数

	slowMotionTimer      = -1;                 -- 慢镜头计时器
	slowMotionLastTime   = 3;                  -- 慢镜头持续时间
	slowLineArmature     = nil;                -- 添加慢镜头放射线
	fightOverTimer       = 0;                  -- 战斗结束计时器
	cameraState          = CameraState.normal; -- 相机状态
	frustumWidth         = 0;                  -- 视锥宽度
	frustumHeight        = 0;                  -- 视锥高度
	cameraPos            = nil;                -- 相机位置
	deltaCameraPos       = nil;                -- 相机移动偏移
	cameraPosY           = 0;                  -- 相机Y轴振动起点

	frustumScale         = 0.4;                -- 视锥缩放
	zoomInTime           = 0.2;                -- 拉近时间
	zoomStopTime         = 3;                  -- 慢动作时间
	zoomOutTime          = 0.7;                -- 拉出时间
	shakeNum             = 3;                  -- 抖动次数
	shakeUpTime          = 0.05;               -- 相机拉上
	shakeDownTime        = 0.05;               -- 相机拉回
	shakeMovePosY        = -10;                -- 相机移动位置
	cameraElapse         = 0;                  -- 相机时间消耗
	tmpShakeNum          = 0;                  -- 记录抖动次数

	ellipseX             = 6;                  -- 抖动椭圆X半径
	ellipseY             = 3;                  -- 抖动椭圆Y半径
	ellipseAngle         = 0;                  -- 当前抖动角度
	ellipseAngleSpeed    = 1000;               -- 抖动角度速度
	cameraStartTranslate = nil;                -- 相机的初始位移

	timeScaleLevel       = 1;                  -- 快进等级
	rightTotalDamage                 = 0;
	--  旷世大战时选择人的时候不能点击卡牌
	canClickCard = false;
	--  用于选敌人时缩小特效
	isSelectEnemy = false;
	isFiredReadyRunSkill = true;
	roleBaseHP = 280000;          --  主角初始血量值
	mainRole   = nil;
	isRoleCurHpTrigger = false;
	isFirstTimeTrigger = false;
	isangerMaxTrigger = false;
	isNoviceBattleOver = false;
	checkStuck = -1;
	isTriggerSelect = false;
	rolePos = 0;
	leftActorFlag = false;			--是否是左侧人物初始化数据
};

local isCameraZoomIn = false;
local lastMonsterEnterTime;									--记录上一个怪物的入场时间
local monsterEnterAdvancedTime;								--怪物入场提前的时间
local boss;													--关卡boss
local hasAssistHero = false;								--是否拥有助战英雄
local fightEndEffectSound;									--战斗结束音效
local needUpdateRecordAgain = false;						--判断是否需要再次更新录像

local selectArmature
local isNoviceBattle = false
local isCanTagEnemy = false

local isFirstGuide       = true;
local isFirstAnger 		 = true;

--初始化
function FightManager:Initialize( sceneID, enemyRoleList, isRecord)
	--========================================================================================

	Logger:clear();            --初始化日志模块

	self.isLevelUp				= false;						--战斗结束后主角是否升级
	needUpdateRecordAgain           = false;
	self.tagFighter          = nil;
	--========================================================================================
	self.barrierId				= sceneID;						--关卡ID
	self.killedList				= {};							--杀死的怪物的table
	self:fightType();											--计算战斗类型和是否pvp战斗
	self.leftActorId = {}


	self.enablePause = true; --是否可以按下暂停按钮
	if FightType.rank == self.mFightType then
		self.lastDistributeCardTime = Configuration.distributeCardTimeInRankFight; --上次分发卡牌时间(排位战)
	else
		self.lastDistributeCardTime = Configuration.distributeCardTime; --上次分发卡牌时间
	end

	--========================================================================================
	--战斗UI
	if FightState.none == self.state then
		self.lastScene = GodsSenki.mainScene;					--主界面场景
	end
	self.state = FightState.loadState;							--初始化过程设置成loading状态

	--画屏拖尾效果等级开启
	--[[
	if ActorManager.hero:GetLevel() >= FunctionOpenLevel.TouchTailEnbale then
		BottomRenderStep:SetTouchEnable(true);
	else
		BottomRenderStep:SetTouchEnable(false);
	end
	--]]
	--更改成手动选取目标且无拖尾效果
	BottomRenderStep:SetTouchEnable(false);

	--=======================================================================================
	self.scene = SceneManager:LoadFightScene(sceneID);			--战斗场景
	self.camera = self.scene:GetCamera();						--场景
	self.cameraState = CameraState.normal;
	self.camera.Translate = Vector3(0,0,0);

	--=======================================================================================
	--根据场景宽度计算左侧出生点坐标

	if self.isPvP or (self.mFightType == FightType.worldBoss) or (self.mFightType == FightType.unionBoss) then
		self.leftPos = Vector3( -1 * self.scene.width / 2 + Configuration.FightTeleportPvpLeftOffset.x, 0, 0);
	else
		self.leftPos = Vector3( -1 * self.scene.width / 2 + Configuration.FightTeleportPveLeftOffset.x, 0, 0);
	end

	--根据场景宽度计算右侧出生点坐标
	self.rightPos = Vector3( self.scene.width / 2 + Configuration.FightTeleportRightOffset.x, 0, 0);

	--=======================================================================================

	--=======================================================================================
	self.meleeFighterCount	= 0;								--pve时本方近战英雄数量
	self.remoteFighterCount	= 0;								--pve时本方远程英雄数量
	--========================================================================================
	-- 属性相关
	self.isOver	= false;										--战斗结束标志

	if isRecord == true then
		self.isRecord = true;									--战斗模式
	else
		self.isRecord = false;									--录像模式
	end
	self.leftActorFlag = false;  
	if self.isPvP then
		self.hasBoss = false;
		boss = nil;
		self.needrightActorList = self:GetEnemyRoleList(enemyRoleList);
	else
		self.isPvP = false;
		local monsterList = {};
		if FightType.worldBoss == self.mFightType or FightType.unionBoss == self.mFightType then
			--世界和公会boss战
			self.idleMonsterList	= self:GetBossData(enemyRoleList);		--战场中提前入场的怪物
			self.needrightActorList = {};
		elseif FightType.invasion == self.mFightType then
			--杀星
			local level = enemyRoleList;									--当战斗为杀星时，该参数为怪物等级
			monsterList = self:GetMonsterList(self.barrierId, level);
			self.needrightActorList	= monsterList[1];						--右侧准备入场的ActorList
			self.idleMonsterList	= monsterList[2];						--战场中提前入场的怪物

		elseif FightType.expedition == self.mFightType then
			monsterList = self:GetExpeditionMonsterList(enemyRoleList);
			self.needrightActorList	= monsterList[1];
			self.idleMonsterList	= monsterList[2];

		elseif FightType.cardEvent == self.mFightType then
			monsterList = self:GetCardEventMonsterList(enemyRoleList)
			self.needrightActorList = monsterList[1]
			self.idleMonsterList = monsterList[2]
		elseif FightType.rank == self.mFightType then
			monsterList = self:GetRankMonsterList(enemyRoleList)
			self.needrightActorList = monsterList[1]
			self.idleMonsterList = monsterList[2]
		elseif FightType.unionBattle == self.mFightType then
			monsterList = self:GetUnionBattleMonsterList(enemyRoleList)
			self.needrightActorList = monsterList[1]
			self.idleMonsterList = monsterList[2]
			-- elseif FightType.scuffle == self.mFightType then
			--	monsterList = self:GetRankMonsterList(enemyRoleList) --用排位测试
			--   self.needrightActorList = monsterList[1]
			--  self.idleMonsterList = monsterList[2]
		else
			--普通关卡
			monsterList = self:GetMonsterList(self.barrierId);
			self.needrightActorList	= monsterList[1];						--右侧准备入场的ActorList
			self.idleMonsterList	= monsterList[2];						--战场中提前入场的怪物
		end
		lastMonsterEnterTime    = 0;										--初始化上一个怪物的入场时间
		monsterEnterAdvancedTime = 0;
	end
	self.leftActorFlag = true;
	if FightType.expedition == self.mFightType then
		self.needleftActorList = self:GetExpeditionAllyRoleList();
	elseif FightType.cardEvent == self.mFightType then
		self.needleftActorList = self:GetCardEventAllyRoleList()
	elseif FightType.treasureGrabBattle == self.mFightType or FightType.treasureRobBattle == self.mFightType then
		self.needleftActorList = self:GetTreasureAllyRoleList();
	elseif FightType.rank == self.mFightType then
		self.needleftActorList = self:GetRankAllyRoleList()
	elseif FightType.unionBattle == self.mFightType then
		self.needleftActorList = self:GetUnionBattleAllyRoleList()
	else
		self.needleftActorList = self:GetAllyRoleList();						--左侧准备入场的ActorList
	end
	for k,v in pairs( self.needleftActorList) do
		table.insert(self.leftActorId,v:GetResID())
	end

	self.isTriggerSelect = false;
	self.leftActorList              = {};											--左侧的ActorList
	self.rightActorList             = {};											--右侧的ActorList
	self.deathActorList             = {};											--死亡的ActorList
	self.actorList                  = {};											--所有角色列表
	self.constLeftActorList         = {};
	self.cameraReferenceX           = 0;											--相机参考位置
	self.cameraReferenceActor       = nil;										--相机参考坐标角色

	self.count                      = 0;											--进场的英雄及伙伴个数
	self.enemyCount                 = 0;											--进场的地方角色个数
	self.time                       = 0;											--战斗系统时间
	self.enterSpacingTime           = Configuration.FirstPartnerEnterBattleTime;	--设置第一个友方角色入场时间
	self.lastPlayerEnterTime        = 0;											--英雄或者伙伴上次进入时间
	self.lastMonsterEnterTime       = 0;											--怪物上一波入场时间
	self.firstIdleMonsterWakeUpTime = nil;											--上一个待机怪物觉醒时间
	isCameraZoomIn                  = false;
	self.rightTotalDamage                = 0;
	self.deadActorTime			   = {};										--记录角色死亡时间的表

	isFirstGuide       	= true;
	isFirstAnger 		 = true;

	FightShowSkillManager:Initialize();
	FightHandSkillManager:Initialize(self.needleftActorList, self.needrightActorList, self.idleMonsterList);

	--场景特效
	FightEffectManager:Initialize();

	--======================================================================================================
	self:InitAutoButton();								--手动按钮初始化
	self:InitPanel();									--ui界面初始化
	self:InitFightConfigButton();						--游戏设置按钮初始化
	FightComboQueue:Init(self.desktop);					--游戏连击初始化
	--======================================================================================================
	--
	self.allyTotalHP= 0;
	self.enemyTotalHP= 0;

	for index, fighter in ipairs(self.needleftActorList) do
		self.allyTotalHP = self.allyTotalHP + fighter.m_propertyData.m_maxHP;
	end

	for index, monsterItem in ipairs(self.needrightActorList) do
		local monster = monsterItem.monster;
		if monster then --是怪物
			self.enemyTotalHP = self.enemyTotalHP + monster.m_propertyData.m_maxHP;
		else --对方是人
			self.enemyTotalHP = self.enemyTotalHP + monsterItem.m_propertyData.m_maxHP;
		end
	end

	for index, monsterItem in ipairs(self.idleMonsterList) do
		local monster = monsterItem.monster;
		self.enemyTotalHP = self.enemyTotalHP + monster.m_propertyData.m_maxHP;
	end

	if self.mFightType == FightType.noviceBattle then   --  不显示
		LimitTaskPanel:Show()
	end
	--设置声音
	SoundManager:PauseBackgroundSound();

	-- 初始化技能连续释放疲劳系统
	self.skillCastCheck = {};
	self.skillCastCheck.attackerTable = {};
	self.skillCastCheck.attackerTable.lastAttacker = -1;
	self.skillCastCheck.attackerTable.num = 0;
	self.skillCastCheck.attackerTable.lastSkillID = -1;
	self.skillCastCheck.getSkillCoefficient = function(attackerID, skillID)
		local coefficient, addbuff, phase;
		if self.skillCastCheck.attackerTable.lastAttacker == attackerID then
			if self.skillCastCheck.attackerTable.lastSkillID ~= skillID then
				self.skillCastCheck.attackerTable.num = self.skillCastCheck.attackerTable.num + 1;
				self.skillCastCheck.attackerTable.lastSkillID = skillID;
			end
			if self.skillCastCheck.attackerTable.num <= Configuration.cast_max_time then
				coefficient = 1;
				addbuff = true;
			else
				coefficient = Configuration.cast_coefficient;
				addbuff = false;
			end
			if self.skillCastCheck.attackerTable.num == 1 then
				phase = 1;
			elseif self.skillCastCheck.attackerTable.num >= Configuration.cast_max_time then
				phase = 3;
			else
				phase = 2;
			end
		else
			self.skillCastCheck.attackerTable.lastAttacker = attackerID;
			self.skillCastCheck.attackerTable.num = 1;
			self.skillCastCheck.attackerTable.lastSkillID = skillID;
			coefficient = 1;
			addbuff = true;
			phase = 1;
		end
		return coefficient, addbuff, phase;
	end
	self.skillCastCheck.getCurSkillCoefficient = function(attackerID, skillID)
		local coefficient, addbuff;
		if self.skillCastCheck.attackerTable.lastAttacker == attackerID then
			if self.skillCastCheck.attackerTable.num <= Configuration.cast_max_time or self.skillCastCheck.attackerTable.lastSkillID ~= skillID then
				coefficient = 1;
				addbuff = true;
			else
				coefficient = Configuration.cast_coefficient;
				addbuff = false;
			end
		else
			coefficient = 1;
			addbuff = true;
		end
		return coefficient, addbuff;
	end
end

--初始化战斗角色的形象数据
function FightManager:InitAllFightersAvatar()
	for _, fighter in ipairs(self.needleftActorList) do
		fighter:InitAvatar();
	end

	if (self.isPvP) then
		for _, fighter in ipairs(self.needrightActorList) do
			fighter:InitAvatar();
		end
	elseif ((FightType.worldBoss ~= self.mFightType) and (FightType.unionBoss ~= self.mFightType)) then
		for _, fighter in ipairs(self.needrightActorList) do
			fighter.monster:InitAvatar();
		end
	end

	--加载提前入场的怪物
	if not self.isPvP then
		for _, item in ipairs(self.idleMonsterList) do
			item.monster:InitAvatar();
			item.monster:SetKeepIdle();
		end

		self:loadIdleMonster();
	end
end

function FightManager:InitSchemeXML()
	uiSystem:LoadSchemeXML('fight.lay');
	uiSystem:LoadResource('fight');
	self.desktop = uiSystem:GetDesktop('fight');
	SetDesktopSize(self.desktop);

	BottomRenderStep:CreateTouchTail(self.desktop)
end

--初始化panel
function FightManager:InitPanel()

	DamageLabelManager:Initialize(self.desktop);			--初始化伤害显示缓存
	FightUIManager:Initialize(self.desktop);				--战斗UI界面初始化
	GoodsFalldownManager:Initialize(self.desktop);			--物品掉落初始化
	HpProgressBarManager:Init(self.desktop);				--血条UI初始化

	if not self.isPanelInit then
		PveWinPanel:Initialize(self.desktop);				--战斗胜利界面初始化
		PveLosePanel:Initialize(self.desktop);				--战斗失败界面初始化
		PvpWinPanel:Initialize(self.desktop);				--pvp战斗胜利界面初始化
		PvpLosePanel:Initialize(self.desktop);				--pvp战斗失败界面初始化
		FightBigPicPanel:InitPanel(self.desktop);				--技能立绘界面初始化
		FightConfigPanel:InitPanel(self.desktop);			--游戏设置界面初始化
		TreasureCaptureWinPanel:Initialize(self.desktop);
		TreasureFightWinPanel:Initialize(self.desktop);
		FightOverUIManager:Init();
		FightImageGuidePanel:InitPanel(self.desktop)       --前三关引导面板
		LoveMaxPanel:InitPanel(self.desktop);

		self.isPanelInit = true;							--设置战斗ui已经初始化
	end
end

function FightManager:GetFightDeskTop()
	return self.desktop;
end
--初始化加速按钮
function FightManager:InitSpeedButton()
	--二倍速处理
	--[[
	if FightManager.mFightType == FightType.normal or FightManager.mFightType == FightType.elite 
	or FightManager.mFightType == FightType.rank 
	or FightManager.mFightType == FightType.cardEvent then --]]
	if true then
		appFramework.TimeScale = Configuration.FightTimeScaleList[self.timeScaleLevel];
		if self.timeScaleLevel == 2 then
			FightUIManager:isAddSpeed(true);
		else
			FightUIManager:isAddSpeed(false);
		end
	else
		appFramework.TimeScale = Configuration.FightTimeScaleList[1];
		FightUIManager:isAddSpeed(false);
	end
	if self.mFightType == FightType.noviceBattle then
		appFramework.TimeScale = Configuration.FightTimeScaleList[1];
		self.addSpeedButton.Visibility = Visibility.Hidden;
	end
end
--[[
--初始化加速按钮
function FightManager:InitSpeedButton()
	self.addSpeedButton = Button(self.desktop:GetLogicChild('speed'));
	self.Speed1Brush = TextureBrush(uiSystem:FindResource('pve_kuaijin1_1', 'fight'));
	self.Speed1PressBrush = TextureBrush(uiSystem:FindResource('pve_kuaijin1_2', 'fight'));
	self.Speed2Brush = TextureBrush(uiSystem:FindResource('pve_kuaijin2_1', 'fight'));
	self.Speed2PressBrush = TextureBrush(uiSystem:FindResource('pve_kuaijin2_2', 'fight'));
	self.Speed3Brush = TextureBrush(uiSystem:FindResource('pve_kuaijin3_1', 'fight'));
	self.Speed3PressBrush = TextureBrush(uiSystem:FindResource('pve_kuaijin3_2', 'fight'));

	appFramework.TimeScale = Configuration.FightTimeScaleList[self.timeScaleLevel];
	self.addSpeedButton.Visibility = Visibility.Visible;
	if (self.timeScaleLevel == 1) then			--当前正常速度
		self.addSpeedButton.NormalBrush = self.Speed1Brush;
		self.addSpeedButton.CoverBrush = self.Speed1Brush;
		self.addSpeedButton.PressBrush = self.Speed1PressBrush;

	elseif (self.timeScaleLevel == 2) then		--当前二等加速
		self.addSpeedButton.NormalBrush = self.Speed2Brush;
		self.addSpeedButton.CoverBrush = self.Speed2Brush;
		self.addSpeedButton.PressBrush = self.Speed2PressBrush;

	end

	if self.mFightType == FightType.noviceBattle then
		self.addSpeedButton.Visibility = Visibility.Hidden;
	end
end
]]
--初始化自动按钮
function FightManager:InitAutoButton()
	self.autoButton = ScaleButton(self.desktop:GetLogicChild('btnAuto'));
	self.cancelAutoButton = ScaleButton(self.desktop:GetLogicChild('btnCancelAuto'));
	if (self.isRecord) then
		--录像状态下隐藏，同时将所有头像设置成不可点击
		self.autoButton.Visibility = Visibility.Hidden;
		self.cancelAutoButton.Visibility = Visibility.Hidden;
	elseif (self.mFightType == FightType.zodiac) then
		self.autoButton.Visibility = Visibility.Hidden;
		GlobalData.FightAutoBattleFlag = self.isAuto;           --保存自动战斗标记
		self.isAuto = false;
	else
		if (FightType.trial == self.mFightType) or (FightType.FriendBattle == self.mFightType) then
			self.autoButton.Visibility = Visibility.Hidden;
			self.isAuto = true;
		elseif FightType.noviceBattle == self.mFightType then
			self.autoButton.Visibility = Visibility.Hidden;
			self.isAuto = false;
		elseif Hero:GetLevel() < FunctionOpenLevel.autoFight then
			self.autoButton.Visibility = Visibility.Hidden;
			self.isAuto = false;
		else
			--[[
			if self.isAuto then
				self.autoButton.Text = LANG_fightManager_1;
			else
				self.autoButton.Text = LANG_fightManager_2;
			end
			--]]
			self.autoButton.Visibility = self.isAuto and Visibility.Hidden or Visibility.Visible;
			self.cancelAutoButton.Visibility = self.isAuto and Visibility.Visible or Visibility.Hidden;
		end
	end
end

--初始化游戏设置按钮
function FightManager:InitFightConfigButton()
	self.fightConfigButton = ScaleButton(self.desktop:GetLogicChild('btnFightConfig'));
end

--全部销毁
function FightManager:FullDestroy()
	--停止两倍速
	appFramework.TimeScale = Configuration.FightTimeScaleList[1];
	if self.state ~= FightState.none then
		self:Destroy();
	end

	FightQTEManager:Destroy();
	FightAttackManager:Clear();

	--销毁只初始化一次的界面
	if self.isPanelInit then
		PveWinPanel:Destroy();
		PveLosePanel:Destroy();
		PvpWinPanel:Destroy();
		PvpLosePanel:Destroy();
		FightBigPicPanel:Destroy();
		FightConfigPanel:Destroy();
		TreasureCaptureWinPanel:Destroy();
		FightImageGuidePanel:Destroy();
		LoveMaxPanel:Destroy();
	end

end

--销毁
function FightManager:Destroy()

	--触发销毁战斗事件
	EventManager:FireEvent(EventType.DestroyFight, self.barrierId);

	--还原自动战斗标记
	if (self.mFightType == FightType.zodiac) then
		self.isAuto = GlobalData.FightAutoBattleFlag;
	end

	for _,fighter in ipairs(self.actorList) do
		fighter:DestroyDebugInfo();
		ActorManager:DestroyActor(fighter:GetID());		--销毁Fighter
	end

	self.leftTotalAnger = 0;
	self.rightTotalAnger = 0;
	self.actorList = {};
	self.deathActorList = {};
	self.killedList = {};
	self.needleftActorList	= {};						--左侧准备入场的ActorList
	self.needrightActorList	= {};						--右侧准备入场的ActorList
	self.idleMonsterList = {};							--右侧提前入场，在战场待机的怪物
	self.leftActorList = {};							--左侧的ActorList
	self.rightActorList = {};							--右侧的ActorList
	self.constLeftActorList = {};

	self:DestroyUI();									--销毁UI资源

	SceneManager:SetActiveScene(self.lastScene);		--恢复战斗前场景
	SceneManager:RemoveScene(self.scene);
	self.scene = nil;

	MainUI:Active();
	MainUI:GetDesktop():AddChild(PlotPanel:getPlotPanel());
	bottomDesktop.Visibility = Visibility.Visible;

	self.isOver = true;									--将游戏是否结束标志复原
	self.state = FightState.none;						--游戏退出战斗（战斗和录像）界面
	GlobalData.AllyPlayerHpRatio = 1;					--重置角色初始血量百分比
	hasAssistHero = false;

	if nil ~= fightEndEffectSound then
		soundManager:DestroySource(fightEndEffectSound);
		fightEndEffectSound = nil;
	end

	FightComboQueue:Destroy();

	SoundManager:PlayBackgroundSound();     --  播放主城背景音乐
end

--销毁UI资源
function FightManager:DestroyUI()
	FightUIManager:Destroy();						--战斗角色技能头像UI
	DamageLabelManager:Destroy();					--伤害显示标签
	GoodsFalldownManager:Destroy();					--掉落物品UI
	HpProgressBarManager:Destroy();					--角色血条
end

--更新FightConfigPanel
function FightManager:Update( elapse )
	if FightState.none ~= self.state then
		if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
			--print('trigger->'..tostring(self.isTriggerSelect)..' isEnemyInScreen->'..tostring(self:isEnemyInScreen(3009))..' secondCard->'..tostring(FightHandSkillManager.isSecondCard));
			if not self.isTriggerSelect and self:isEnemyInScreen(3009)  and FightHandSkillManager.isSecondCard then
				local handSkill = FightSkillCardManager:getHandSkillList();
				for i=1,#handSkill do
					if handSkill[i].skill_resid == 302 then
						FightManager:Pause();
						self:playSelectArmature(3009, LANG_GUIDE_CONTENT_4);
						FightImageGuidePanel.isShowNextPic = true;
						break;
					end
				end
				FightSkillCardManager.guideCardClick = true;
			end
		end
		if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
			if not self.isTriggerSelect and self:isEnemyInScreen(3007)  and FightHandSkillManager.isFirstCard then
				local handSkill = FightSkillCardManager:getHandSkillList();
				for i=1,#handSkill do
					if handSkill[i].skill_resid == 202 then
						FightManager:Pause();
						self:playSelectArmature(3007, LANG_GUIDE_CONTENT_4);
						FightImageGuidePanel.isShowNextPic = true;
						break;
					end
				end
				FightSkillCardManager.guideCardClick = true;
				FightUIManager:setInfoGuidePanel(false)
			end
		end

		if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 then
			if isFirstGuide then
				FightUIManager:setFightGuidePanel(true)
				FightUIManager:setAngerGuidePanel(false)
				isFirstGuide = false;
			end

			if FightManager.barrierId == 1001 and FightManager:getTotalAnger() >= 1 and isFirstAnger then
				isFirstAnger = false;
				FightUIManager:setFightGuidePanel(false)
				FightUIManager:setAngerGuidePanel(true)
			end

			if not self.isTriggerSelect and self:isEnemyInScreen(3055) and FightHandSkillManager.isSecondCard then
				FightManager:FightPauseGame()

				FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_1);
				--FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_9);
				FightSkillCardManager.guideCardClick = true;
			end
		end

		if self.checkStuck ~= -1 and self.isOver == false then
			self.checkStuck = self.checkStuck + elapse;
		end

		if self.checkStuck > 4.8 and self.checkStuck <= 4.8 + elapse then
			--TopRenderStep:onReport();
			Debug.print("stuck now");
			self.checkStuck = 0;
		end

		FightEffectManager:loadEnvEffect(); -- 进入关卡，加载场景特效
		if FightState.fightState == self.state then
			--战斗模式
			self:fightBattles(elapse);
		elseif FightState.recordState == self.state then
			--录像模式
			self:updateRecordNoPause(elapse);

			if needUpdateRecordAgain then
				self:updateRecordOnPause(0);
				needUpdateRecordAgain = false;
			end
		elseif FightState.recordPauseState == self.state then
			--录像暂停模式（播放录像过程中的技能展示）
			self:updateRecordOnPause(elapse);
		end

		self:updateCamera(elapse);				--更新相机
		FightShowSkillManager:Update(elapse);	--Show Skill更新
		DamageLabelManager:Update(elapse);		--伤害数字的更新
		GoodsFalldownManager:Update(elapse);	--物品掉落更新
		HpProgressBarManager:Update(elapse);	--血条更新
		FightComboQueue:Update(elapse);				--更新连击队列
		--FightSkillCardManager:Update(elapse);
		FightBigPicPanel:Update(elapse);
	end
end

--游戏是否处于running状态
function FightManager:IsRunning()
	if (self.state == FightState.fightState) or (self.state == FightState.recordState) then
		if self.isOver then
			return false;
		else
			return true;
		end
	else
		return false;
	end
end

function FightManager:IsPause()
	if (self.state == FightState.pauseState) then
		return true;
	else
		return false;
	end
end

--结束加载状态
function FightManager:FinishLoadState()
	--向服务器发送统计数据
	if (Task.mainTask ~= nil) then
		local taskID = Task.mainTask['id'];
		if self.mFightType == FightType.noviceBattle then
			NetworkMsg_GodsSenki:SendStatisticsData(0, 3);
		elseif (taskID <= MenuOpenLevel.statistics) and (taskID > 0) then
			local taskItem = resTableManager:GetValue(ResTable.task, tostring(taskID), {'type','value'});
			if (nil ~= taskItem) and (1 == taskItem['type']) and (self.barrierId == taskItem['value'][1]) then
				NetworkMsg_GodsSenki:SendStatisticsData(taskID, 6);
			end
		end
	end

	--修改状态
	if self.isRecord then
		self.state = FightState.recordState;
	else
		self.state = FightState.fightState;
	end

	--切换桌面
	bottomDesktop.Visibility = Visibility.Hidden;
	uiSystem:SwitchToDesktop(self.desktop);
	self.desktop:AddChild(PlotPanel:getPlotPanel());

	--初始化加速按钮
	self:InitSpeedButton();

	--切换场景
	SceneManager:SetActiveScene(self.scene);

	local cameraPos = self.camera.Translate;

	local camera = sceneManager.ActiveScene.Camera;
	local frustumWidth = camera.ViewFrustum.Right;
	local cameraInitialOffset = frustumWidth;

	self.camera.Translate = Vector3(-1 * self.scene.width / 2 + cameraInitialOffset, cameraPos.y, cameraPos.z);

	--PVP或Boss播放boss战斗声音
	if self.isPvP or self.hasBoss then
		SoundManager:PlayFightSound( true );
	else
		SoundManager:PlayFightSound( false );
	end
	for k,leftActor in pairs(self.needleftActorList) do
		print('role-'..k..'att------------->')
		local leftActorAtt =leftActor.m_propertyData:GetCurrentPropertyData()
		print('phyAtt->'..leftActorAtt.phy)
		print('magAtt->'..leftActorAtt.mag)
		print('phyDef->'..leftActorAtt.phyDef)
		print('magDef->'..leftActorAtt.magDef)
		print('hp->'..leftActorAtt.hp)
	end
	--触发战斗开始
	EventManager:FireEvent(EventType.EnterFight, self.barrierId);
end

--继续战斗
function FightManager:Continue()
	if FightComboQueue:onComboQueue() then
		Debug.print("FightManager:Continue onCombo return");
		return;
	end

	FightUIManager:resumeTime();

	if FightState.pauseState == self.state then
		self:ResumeAction();
		self:ResumeEffectScript();
	end

	if self.isRecord then
		self.state = FightState.recordState;
	else
		self.state = FightState.fightState;
	end

	--触发战斗恢复的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.fightResume, self:GetTime());
end

--恢复角色动作
function FightManager:ResumeAction()
	for _,actor in ipairs(self.leftActorList) do
		actor:ContinueAction();
	end

	for _,actor in ipairs(self.rightActorList) do
		actor:ContinueAction();
	end
end

--恢复技能脚本及追踪特效
function FightManager:ResumeEffectScript()
	--恢复全部技能脚本更新
	effectScriptManager:ResumeAllEffectScript();

	--恢复全部lua有引用保存的特效
	EffectManager:ResumeAllEffect();
end

--暂停战斗
function FightManager:Pause( holdAnimation )
	self.state = FightState.pauseState;
	if FightComboQueue:onComboQueue() then
		Debug.print("FightManager:Continue onCombo return");
		return;
	end

	if holdAnimation then
	else
		self:PauseAction();
		self:PauseEffectScript();
	end
	FightUIManager:pauseTime();

	--触发战斗暂停的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.fightPause, self:GetTime());
end

--暂停角色动作及角色身上的挂点特效
function FightManager:PauseAction()
	for _,actor in ipairs(self.leftActorList) do
		actor:PauseAction();
	end

	for _,actor in ipairs(self.rightActorList) do
		actor:PauseAction();
	end
end

--暂停技能脚本及追踪特效
function FightManager:PauseEffectScript()
	--暂停全部技能脚本更新
	effectScriptManager:PauseAllEffectScript();

	--暂停全部lua有引用保存的特效
	EffectManager:PauseAllEffect();
end

--添加遮罩
function FightManager:AddShader()
	self.scene:AddShader();
end

--删除遮罩
function FightManager:RemoveShader()
	self.scene:RemoveShader();
end

--弹出战斗结算界面
function FightManager:DisplayResult()
	local taskid = Task:getMainTaskId();
	if 0 == taskid then
		self.fightOverTimer = timerManager:CreateTimer(0.1, 'FightManager:OnFirstFightOver', 0);
	else
		self.fightOverTimer = timerManager:CreateTimer(0.1, 'FightManager:OnFightOver', 0);
	end
end

--=======================================================================================
--预加载
--QTE预加载
function FightManager:PreLoadQTEResource()
	--加载美术资源
	PreLoadAvatar("Heart_Shield_1");
	PreLoadAvatar("Heart_Shield");
	PreLoadAvatar("Heart_Iron_1");
	PreLoadAvatar("Heart_Iron");
	PreLoadAvatar("Heart_1");
	PreLoadAvatar("Heart");
	--加载声音资源
	PreLoadSound('breakarmor');
	PreLoadSound('breakshield');
	PreLoadSound('combo1');
	PreLoadSound('combo2');
	PreLoadSound('combo3');
	PreLoadSound('combo4');
	PreLoadSound('combo5');
	PreLoadSound('breakheart');
end

--预加载声音资源
function FightManager:PreLoadSoundResource()
	asyncLoadManager:PreLoadSound(SoundManager.WinSound, false);
	asyncLoadManager:PreLoadSound(SoundManager.LostSound, false);
	PreLoadSound('combo1');             --划破技能的音效

	--PVP或Boss播放boss战斗声音
	if self.isPvP or self.hasBoss then
		asyncLoadManager:PreLoadSound(SoundManager.BossSound, true);
		if self.hasBoss then
			self:PreLoadQTEResource();
		end
	else
		asyncLoadManager:PreLoadSound(SoundManager.FightSound, true);
	end
end

--预加载死亡动画
function FightManager:PreLoadDieResource()
	--加载角色死亡动画资源
	asyncLoadManager:PreLoadArmatureTextureFile('die_1');
	asyncLoadManager:PreLoadArmatureTextureFile('die_2');
	asyncLoadManager:PreLoadArmatureTextureFile('die_3');
end

--预加载全局技能
function FightManager:PreLoadGestureSkillResource(bID)
	local rowNum = resTableManager:GetRowNum(ResTable.gestureskillNoKey);
	for index = 1, rowNum do
		local rowData = resTableManager:GetValue(ResTable.gestureskillNoKey, index-1, {'open', 'effect_main', 'effect'});
		if (ActorManager.user_data.round.roundid >= rowData['open']) or (ActorManager.user_data.round.roundid + 1 == bID) then
			if (string.len(rowData['effect_main']) ~= 0) then
				LoadLuaFile('skillScript/' .. rowData['effect_main'] .. '.lua');			--加载手势技能脚本
				local skillScript = _G[rowData['effect_main']];
				skillScript:preLoad();
			end

			if (string.len(rowData['effect']) ~= 0) then
				LoadLuaFile('skillScript/' .. rowData['effect'] .. '.lua');			--加载手势技能脚本
				local skillScript = _G[rowData['effect']];
				skillScript:preLoad();
			end
		end
	end
end

--pve战斗预加载
function FightManager:PvePreLoad(bID)
	--预加载全局技能资源
	self:PreLoadGestureSkillResource(bID);
	--预加载声音资源
	self:PreLoadSoundResource();
	self:PreLoadDieResource();
end

--预加载新手战斗资源
function FightManager:PreLoadNoviceBattleResource()
	self:PreLoadSoundResource();
	self:PreLoadDieResource();
end

--=========================================================================================
--相机相关
--=========================================================================================
--进入拉近镜头
function FightManager:onEnterCameraZoomIn( targeter )

	local tmpTargetPos = targeter:GetPosition();
	local targetPos = Vector3(tmpTargetPos.x, tmpTargetPos.y + targeter:GetHeight() * 0.5, 0);
	local camera = sceneManager.ActiveScene.Camera;
	self.cameraState = CameraState.zoomIn;
	local tmpCameraPos = camera.Translate;
	self.cameraPos = Vector3(tmpCameraPos.x, tmpCameraPos.y, tmpCameraPos.z);

	--处于相机抖动
	if self.cameraState ~= CameraState.normal then
		self.cameraPos.y = self.cameraPosY;
	end

	self.deltaCameraPos = targetPos - self.cameraPos;
	self.deltaCameraPos.z = 0;

	self.frustumWidth = camera.ViewFrustum.Right;
	self.frustumHeight = camera.ViewFrustum.Top;
	self.cameraElapse = 0;

	--appFramework.TimeScale = 0.0001;

end

--进入相机抖动
function FightManager:onEnterCameraShake(shakeType)

	--重复shake或者拉近镜头
	if (self.cameraState ~= CameraState.normal) and (self.cameraState ~= CameraState.shake) then
		return;
	end

	if shakeType == nil and self.cameraState ~= CameraState.shake then
		self.cameraState = CameraState.shakeUp;
		self.cameraPosY = sceneManager.ActiveScene.Camera.Translate.y;
	else
		self.cameraState = CameraState.shake;
		if self.tmpShakeNum == 0 then
			self.cameraStartTranslate = Vector2(self.camera.Translate.x, 0);
		end
	end

	self.cameraElapse = 0;
	self.tmpShakeNum = self.shakeNum;
end

--更新camera
function FightManager:updateCamera( elapse )
	if self.cameraState == CameraState.normal then
		return;
	end

	if self.cameraState == CameraState.zoomIn then
		--拉近
		self.cameraElapse = self.cameraElapse + elapse / appFramework.TimeScale;
		if self.cameraElapse >= self.zoomInTime then
			--拉近结束
			appFramework.TimeScale = 0.2;	--慢动作
			self.cameraState = CameraState.zoomStop;
			self.cameraElapse = 0;
			local scene = SceneManager:GetActiveScene();
			local camera = scene:GetCamera();
			local width = self.frustumWidth * (1 - self.frustumScale);
			local height = self.frustumHeight * (1 - self.frustumScale);
			local sceneWidth = scene.width * 0.5;
			local pos = self.cameraPos + self.deltaCameraPos;
			if pos.x < width - sceneWidth then
				pos.x = width - sceneWidth;
			elseif pos.x > sceneWidth - width then
				pos.x = sceneWidth - width;
			end
			camera.Translate = pos;
			camera.ViewFrustum = Frustum(-width, width, -height, height, 1, 100, true);
			return;
		end

		local scale = CheckDiv(self.cameraElapse / self.zoomInTime);
		local scene = SceneManager:GetActiveScene();
		local camera = scene:GetCamera();
		local deltaPos = self.deltaCameraPos * scale;
		local width = self.frustumWidth * (1 - self.frustumScale * scale);
		local height = self.frustumHeight * (1 - self.frustumScale * scale);
		local sceneWidth = scene.width * 0.5;
		local pos = self.cameraPos + deltaPos;
		if pos.x < width - sceneWidth then
			pos.x = width - sceneWidth;
		elseif pos.x > sceneWidth - width then
			pos.x = sceneWidth - width;
		end

		camera.Translate = pos;
		camera.ViewFrustum = Frustum(-width, width, -height, height, 1, 100, true);

	elseif self.cameraState == CameraState.zoomStop then
		--保持近景
		self.cameraElapse = self.cameraElapse + elapse / appFramework.TimeScale;
		if self.cameraElapse >= self.zoomStopTime then
			--保持近景结束
			appFramework.TimeScale = 1;		--恢复正常动作
			self.cameraState = CameraState.zoomOut;
			self.cameraElapse = 0;
			return;
		end

	elseif self.cameraState == CameraState.zoomOut then
		--拉远
		self.cameraElapse = self.cameraElapse + elapse / appFramework.TimeScale;
		if self.cameraElapse >= self.zoomOutTime then
			--拉远结束
			appFramework.TimeScale = 1;		--恢复正常动作
			self.cameraState = CameraState.normal;
			local camera = sceneManager.ActiveScene.Camera;
			camera.Translate = self.cameraPos;
			local width = self.frustumWidth;
			local height = self.frustumHeight;
			camera.ViewFrustum = Frustum(-width, width, -height, height, 1, 100, true);

			if self.result == Victory.left then
				--触发战斗胜利剧情
				EventManager:FireEvent(EventType.FightWin, self.barrierId);
			else

			end
			if not PlotManager:isPlayPlot() then
				--弹出战斗结算界面
				self.fightOverTimer = timerManager:CreateTimer(1, 'FightManager:OnFightOver', 0);
			end
			return;
		end

		local scale = 1 - CheckDiv(self.cameraElapse / self.zoomOutTime);
		local scene = SceneManager:GetActiveScene();
		local camera = scene:GetCamera();
		local deltaPos = self.deltaCameraPos * scale;
		local width = self.frustumWidth * (1 - self.frustumScale * scale);
		local height = self.frustumHeight * (1 - self.frustumScale * scale);
		local sceneWidth = scene.width * 0.5;

		local pos = self.cameraPos + deltaPos;
		if pos.x < width - sceneWidth then
			pos.x = width - sceneWidth;
		elseif pos.x > sceneWidth - width then
			pos.x = sceneWidth - width;
		end

		camera.Translate = pos;
		camera.ViewFrustum = Frustum(-width, width, -height, height, 1, 100, true);

	elseif self.cameraState == CameraState.shakeUp then
		--抖动上
		self.cameraElapse = self.cameraElapse + elapse;
		local radio = CheckDiv(self.tmpShakeNum / self.shakeNum);
		if self.cameraElapse >= self.shakeUpTime * radio then
			--抖动上结束
			self.cameraElapse = 0;
			self.cameraState = CameraState.shakeDown;
			local camera = sceneManager.ActiveScene.Camera;
			local y = self.cameraPosY + self.shakeMovePosY * radio;
			camera.Translate = Vector3(camera.Translate.x, y, camera.Translate.z);
			return;
		end

		local scale = CheckDiv(self.cameraElapse / (self.shakeUpTime * radio));
		local camera = SceneManager:GetActiveScene():GetCamera();
		local y = self.cameraPosY + self.shakeMovePosY * scale * radio;
		local cameraPos = Vector3(camera.Translate.x, y, camera.Translate.z);
		camera.Translate = cameraPos;

	elseif self.cameraState == CameraState.shakeDown then
		--抖动下
		self.cameraElapse = self.cameraElapse + elapse;
		local radio = CheckDiv(self.tmpShakeNum / self.shakeNum);
		if self.cameraElapse >= self.shakeDownTime * radio then
			--抖动下结束
			self.tmpShakeNum = self.tmpShakeNum - 1;
			self.cameraElapse = 0;
			local camera = sceneManager.ActiveScene.Camera;
			camera.Translate = Vector3(camera.Translate.x, self.cameraPosY, camera.Translate.z);
			if self.tmpShakeNum > 0 then
				self.cameraState = CameraState.shakeUp;
			else
				self.cameraState = CameraState.normal;
			end
			return;
		end

		local scale = 1 - CheckDiv(self.cameraElapse / (self.shakeDownTime * radio));
		local camera = SceneManager:GetActiveScene():GetCamera();
		local y = self.cameraPosY + self.shakeMovePosY * scale * radio;
		local cameraPos = Vector3(camera.Translate.x, y, camera.Translate.z);
		camera.Translate = cameraPos;

	elseif self.cameraState == CameraState.shake then
		self.cameraElapse = self.cameraElapse + elapse;
		self.ellipseAngle = self.cameraElapse * self.ellipseAngleSpeed;

		if self.ellipseAngle >= 360 then
			self.cameraElapse = 0;
			self.tmpShakeNum = self.tmpShakeNum - 1;
			if self.tmpShakeNum == 0 then
				self.cameraState = CameraState.normal;
				self.camera.Translate = Vector3(self.cameraStartTranslate.x, self.cameraStartTranslate.y, self.camera.Translate.z);
				return;
			end
		end

		local a = CheckDiv(self.ellipseX * self.tmpShakeNum / self.shakeNum);
		local b = CheckDiv(self.ellipseY * self.tmpShakeNum / self.shakeNum);
		local k = math.tan(math.rad(self.ellipseAngle));
		local x = CheckDiv((a * b) / math.sqrt(a * a * k * k + b * b));
		local y = k * x;

		self.camera.Translate = Vector3(self.cameraStartTranslate.x + x, self.cameraStartTranslate.y + y, self.camera.Translate.z);

	end

end

--相机移动
function FightManager:moveCamera(elapse)
	local cameraX = self.camera.Translate.x;
	if cameraX == self.cameraReferenceX then
		--相机不移动
	elseif self.cameraReferenceX > cameraX then
		--相机向右移动

		if (cameraX + (self.cameraMoveSpeed * elapse)) >= self.cameraReferenceX then
			local newPosition = Vector3(self.cameraReferenceX, self.camera.Translate.y, self.camera.Translate.z);
			self.scene:MoveScene(newPosition, self.cameraReferenceX - cameraX);
		else
			local newPosition = Vector3(cameraX + (self.cameraMoveSpeed * elapse), self.camera.Translate.y, self.camera.Translate.z);
			self.scene:MoveScene(newPosition, (self.cameraMoveSpeed * elapse));
		end

		EventManager:FireEvent(EventType.CameraMove);
	else
		--相机向左移动
		if (cameraX - (self.cameraMoveSpeed * elapse)) <= self.cameraReferenceX then
			local newPosition = Vector3(self.cameraReferenceX, self.camera.Translate.y, self.camera.Translate.z);
			self.scene:MoveScene(newPosition, self.cameraReferenceX - cameraX);
		else
			local newPosition = Vector3(cameraX - (self.cameraMoveSpeed * elapse), self.camera.Translate.y, self.camera.Translate.z);
			self.scene:MoveScene(newPosition, -(self.cameraMoveSpeed * elapse));
		end

		EventManager:FireEvent(EventType.CameraMove);
	end
end

--开始慢镜头
function FightManager:StartSlowMotion()
	self.slowMotionTimer = timerManager:CreateTimer(self.slowMotionLastTime, 'FightManager:EndSlowMotion', 0);
	appFramework.TimeScale = 0.2;    --恢复正常动作
	self:AddSlowLine();

	--非旷世大战
	if (FightType.noviceBattle ~= self.mFightType) then
		if (self.result == Victory.right) then
			--战斗失败
			FightOverUIManager:CreateShowTimer();
			self:OnFightOver();
		else
			--战斗胜利
			if not PlotManager:WillPlayPlot(EventType.FightWin, Task:getMainTaskId(), self.barrierId) then
				--不播放剧情
				FightOverUIManager:CreateShowTimer();
				self:OnFightOver();
			end
		end
	end
end

--结束慢镜头
function FightManager:EndSlowMotion()
	timerManager:DestroyTimer(self.slowMotionTimer);
	self.slowMotionTimer = -1;
	appFramework.TimeScale = 1;			--恢复正常动作

	if (self.result == Victory.left) then
		EventManager:FireEvent(EventType.FightWin, self.barrierId);		--触发战斗胜利剧情
	end
	for _,actor in pairs(self.leftActorList) do
		actor:SetAnimation('win');
	end
end

--播放战斗结束慢镜头放射线
function FightManager:AddSlowLine()
	AvatarManager:LoadFile(GlobalData.EffectPath .. 'die_xiaoguoxian_output/');

	slowLineArmature = uiSystem:CreateControl('ArmatureUI');
	slowLineArmature:LoadArmature('die_xiaoguoxian');
	slowLineArmature:SetAnimation('play', 0.4);
	if self.mFightType == FightType.noviceBattle then
		slowLineArmature:SetScriptAnimationCallback('FightManager:showDialog', 0)
	end

	slowLineArmature.Horizontal = ControlLayout.H_CENTER;
	slowLineArmature.Vertical = ControlLayout.V_CENTER;

	slowLineArmature.ZOrder = 0;
	self.desktop:AddChild(slowLineArmature);

	if self.result == Victory.right then
		--战斗失败，放射线变灰
		slowLineArmature.ShaderType = IRenderer.Scene_GrayShader;
	end

	-- --  旷世大战结束
	-- if self.mFightType == FightType.noviceBattle then
	--    slowLineArmature:SetScriptAnimationCallback('FightManager:backMainCity', 1)
	-- end
end

function FightManager:showDialog( armature )
	if armature:GetAnimation() == 'play' then
		--   触发boss死亡剧情
		EventManager:FireEvent( EventType.NoviceBossDie )
	end
end

function FightManager:backMainCity( armature, id )
	if armature:GetAnimation() == 'play' then
		FightOverUIManager:OnBackToCity()
	end
end

--=====================================================================================
--角色入场
--=====================================================================================

--插入左侧角色
function FightManager:InsertLeftActor( pos, id, enterLine )
	local actor = ActorManager:CreateNPFighter(id);
	actor:SetActorType(ActorType.partner);
	if enterLine == nil then
		if (self.mFightType == FightType.noviceBattle) and (actor:GetJob() == JobType.warrior) then
			enterLine = 1;
		else
			enterLine = 2;
		end
	end
	actor:SetAbsoluteEnterLine(enterLine);
	actor:InitAvatar();
	table.insert(self.needleftActorList, pos, actor);
end

--插入右侧角色
function FightManager:InsertRightActor( enterTime, id, lineIndex )
	local actor = ActorManager:CreateMFighter(id, {level = 1; roundType = MonsterRoundType.noviceBattle});
	actor:InitAvatar();
	local newMonster = {monster = actor; absoluteTime = enterTime; index = lineIndex};
	local finded = false;
	for k,monster in ipairs(self.needrightActorList) do
		if monster.absoluteTime > enterTime then
			if k == 1 then
				newMonster.relativeTime = 0;
				monster.relativeTime = monster.absoluteTime - enterTime;
				table.insert(self.needrightActorList, 1, newMonster);
			else
				newMonster.relativeTime = enterTime - self.needrightActorList[k-1].absoluteTime;
				table.insert(self.needrightActorList, k, newMonster);
				finded = true;
			end
			break;
		end
	end

	if not finded then
		newMonster.relativeTime = enterTime - self.needrightActorList[#self.needrightActorList].absoluteTime;
		table.insert(self.needrightActorList, newMonster);
	end
end

--根据职业排列出场顺序
function FightManager:SortEnterLineByJob(fighterList, isEnemy)
	-- table.sort(fighterList, function (role1, role2) return role1:GetAttackRange() < role2:GetAttackRange(); end);
	-- 原有方案已移除 现有逻辑已攻击范围排序
end

--填充本方战斗角色
function FightManager:GetAllyRoleList()
	local leftFighterList = {};

	if FightType.noviceBattle == self.mFightType then
		local array = resTableManager:GetValue(ResTable.tutorial_actorOrder, '1', 'order');  --  获取己方出场的英雄
		self.roleBaseHP = resTableManager:GetValue(ResTable.tutorial_role, tostring(ActorManager.user_data.role.resid), 'base_hp')
		for _,id in ipairs(array) do
			if id == 0 then id = ActorManager.user_data.role.resid end;
			local leftFighter = ActorManager:CreateNPFighter(id);
			leftFighter:InitFightData(id);
			table.insert(leftFighterList, leftFighter);
			leftFighter:SetActorType(ActorType.partner);
			if id == ActorManager.user_data.role.resid then
				self.mainRole = leftFighter
			end
		end

	elseif FightType.limitround == self.mFightType then
		for _, pid in ipairs(MutipleTeam.teamList[SpecialTeam.PropertyTeam]) do
			if pid >= 0 then
				local role = ActorManager:GetRole(pid);
				local leftFighter = ActorManager:CreatePFighter(role.resid);
				leftFighter:InitFightData(role);
				table.insert(leftFighterList, leftFighter);
				if 0 == pid then
					leftFighter:SetActorType(ActorType.hero);
				else
					leftFighter:SetActorType(ActorType.partner);
				end
			end
		end

	else
		for index = 5, 1, -1 do
			while true do
				local pid = MutipleTeam:getCurrentTeam()[index];
				local hpp = nil;
				if pid >= 0 then
					if FightType.scuffle == self.mFightType then
						hpp = Scuffle:GetAllyHP(pid);
						if hpp == 0 then
							break;
						end
					end	 
					local role = ActorManager:GetRole(pid);
					local leftFighter = ActorManager:CreatePFighter(role.resid);
					leftFighter:InitFightData(role);
					leftFighter.pid = pid;
					if hpp then
						leftFighter.m_propertyData:SetPercent(hpp);
					end
					table.insert(leftFighterList, leftFighter);
					if 0 == pid then
						leftFighter:SetActorType(ActorType.hero);
					elseif pid > 0 then
						leftFighter:SetActorType(ActorType.partner);
					end

					if (FightType.zodiac == self.mFightType) then
						local anger = ZodiacSignPanel.fighterAngerList[leftFighter:GetResID()];
						if (anger ~= nil) and (anger >= 0) then                                 --如果是十二宫，则重新初始化角色怒气
							leftFighter:SetAnger(anger);
						end
					end
				end
				break;
			end
		end
	end

	-- table.sort(fighterList, function (role1, role2) return role1:GetAttackRange() < role2:GetAttackRange(); end);
	return leftFighterList;
end

--填充pvp敌方战斗角色
function FightManager:GetEnemyRoleList(enemyRolesList)
	local rightFighterList = {};
	for index = 1, 5 do
		while true do
			local role = enemyRolesList[index];
			local hpp = nil;
			if role ~= nil then
				if FightType.scuffle == self.mFightType then
					hpp = Scuffle:GetEnemyHP(role.pid);
					if hpp == 0 then
						break;
					end
				end
				local rightFighter = ActorManager:CreatePFighter(role.resid, false);
				rightFighter:InitFightData(role);
				if hpp then
					rightFighter.m_propertyData:SetPercent(hpp);
				end
				if 0 == role.pid then
					rightFighter:SetActorType(ActorType.hero);
				else
					rightFighter:SetActorType(ActorType.partner);
				end
				table.insert(rightFighterList, rightFighter);
			end
			break;
		end
	end

	-- 地方人物出场顺序按照攻击范围排列
	table.sort(rightFighterList, function (role1, role2) return role1:GetAttackRange() < role2:GetAttackRange(); end);

	return rightFighterList;
end

--初始化世界boss数据
function FightManager:GetBossData(role)
	local idleMonsterList = {};		--提前入场怪物列表
	local roundType = 0;
	if FightType.worldBoss == self.mFightType then
		roundType = MonsterRoundType.worldBoss;
	elseif FightType.unionBoss == self.mFightType then
		roundType = MonsterRoundType.unionBoss;
	end
	local monsterId = role.resid;
	local xPosition = Configuration.BossInitXPosition;
	local lineIndex = 2;
	local monster = ActorManager:CreateBFigher(monsterId, {level = role.lvl.level; roundType = roundType});--创建怪物
	boss = monster;
	self.hasBoss = true;
	monster:InitFightData(role)
	monster:SetMaxHp(WOUBossPanel.bossMaxHP);
	monster:SetWakeUpTime(0);
	local idleMonsterItem = {monster = monster; xPos = xPosition; index = lineIndex};
	table.insert(idleMonsterList, idleMonsterItem);

	return idleMonsterList;
end

--填充即将战斗的怪物列表
--barriersId 关卡ID
function FightManager:GetMonsterList(id, level)
	local bossFlag = false;
	local roundType = false;		--是否新手战斗
	boss = nil;

	id = tostring(id);
	local configure = nil;				--每个小怪的配置
	local monsterList = {};			--怪物列表
	local idleMonsterList = {};		--提前入场怪物列表
	local rowData = {};
	local monsterLevel = 0;				--怪物等级
	if FightType.noviceBattle == self.mFightType then
		rowData = resTableManager:GetRowValue(ResTable.tutorial_round, id);
		monsterLevel = rowData['monster_level'];
		roundType = MonsterRoundType.noviceBattle;

	elseif FightType.treasureBattle == self.mFightType then
		rowData = resTableManager:GetRowValue(ResTable.treasure, id);
		monsterLevel = rowData['monster_level'];
		roundType = MonsterRoundType.treasure;

	elseif FightType.invasion == self.mFightType then
		rowData = resTableManager:GetRowValue(ResTable.invasion, id);
		monsterLevel = level;
		roundType = MonsterRoundType.invasion;

	elseif FightType.miku == self.mFightType then
		rowData = resTableManager:GetRowValue(ResTable.miku, id);
		monsterLevel = rowData['monster_level'];
		roundType = MonsterRoundType.miku;

	elseif FightType.zodiac == self.mFightType then                         --十二宫
		rowData = resTableManager:GetRowValue(ResTable.barriers, id);
		monsterLevel = resTableManager:GetValue(ResTable.zodiac_level, tostring(ActorManager.hero:GetLevel()), 'lv' .. math.mod(id, 100));
		roundType = MonsterRoundType.zodiac;

	elseif FightType.limitround == self.mFightType then             -- 限时副本
		rowData = resTableManager:GetRowValue(ResTable.limit_round, id);
		monsterLevel = rowData['monster_level']
		roundType = MonsterRoundType.limitround;

	else
		rowData = resTableManager:GetRowValue(ResTable.barriers, id);
		monsterLevel = rowData['monster_level'];
		roundType = MonsterRoundType.normal;
	end

	--提前入场怪物配置
	local idleMonsterConfigure = rowData['initial_monster'];
	local wakeUpTime = 0;
	if nil ~= idleMonsterConfigure then
		local monsterConfigureList = idleMonsterConfigure;
		for _,monsterConfigureItem in ipairs(monsterConfigureList) do
			local monsterId = monsterConfigureItem[1];
			local xPosition = monsterConfigureItem[2];
			local lineIndex = monsterConfigureItem[3];
			local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
			monster:SetWakeUpTime(wakeUpTime);
			wakeUpTime = wakeUpTime + Math.RangeRandom(Configuration.minMonsterWakeUpTime, Configuration.maxMonsterWakeUpTime);
			local idleMonsterItem = {monster = monster; xPos = xPosition; index = lineIndex};
			table.insert(idleMonsterList, idleMonsterItem);

			if configure == idleMonsterConfigure then
				break;
			end
		end
	end

	--提前入场的boss配置
	local idleBossConfigure = rowData['initial_boss'];
	if nil ~= idleBossConfigure then
		local monsterConfigureItem = idleBossConfigure;
		local monsterId = monsterConfigureItem[1];
		local xPosition = monsterConfigureItem[2];
		local lineIndex = monsterConfigureItem[3];
		if (FightType.zodiac == self.mFightType) then           --如果是十二宫
			boss = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
			boss:SetActorType(ActorType.eliteMonster);
		else
			boss = ActorManager:CreateBFigher(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
		end

		boss:SetWakeUpTime(wakeUpTime);
		local idleMonsterItem = {monster = boss; xPos = xPosition; index = lineIndex};
		table.insert(idleMonsterList, idleMonsterItem);

		bossFlag = true;
	end

	--怪物配置
	local monsterConfigure = rowData['monster'];
	local preMonsterEnterTime = 0;
	if nil ~= monsterConfigure then
		local monsterConfigureList = monsterConfigure;
		for _,monsterConfigureItem in ipairs(monsterConfigureList) do
			local monsterId = monsterConfigureItem[1];
			local enterTime = monsterConfigureItem[2];
			local lineIndex = monsterConfigureItem[3];
			local monster = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
			local monsterItem = {monster = monster; relativeTime = enterTime - preMonsterEnterTime; absoluteTime = enterTime; index = lineIndex};					--time是相对时间
			table.insert(monsterList, monsterItem);
			preMonsterEnterTime = enterTime;

			if configure == monsterConfigure then
				break;
			end
		end
	end

	--boss配置
	local bossConfigure = rowData['boss'];
	if nil ~= bossConfigure then
		local monsterConfigureList = bossConfigure;
		if nil ~= monsterConfigureList and 0 ~= monsterConfigureList[1] then
			local monsterId = monsterConfigureList[1];
			local enterTime = monsterConfigureList[2];
			if (FightType.zodiac == self.mFightType) then           --如果是十二宫
				boss = ActorManager:CreateMFighter(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
				boss:SetActorType(ActorType.eliteMonster);
			else
				boss = ActorManager:CreateBFigher(monsterId, {level = monsterLevel; roundType = roundType});		--创建怪物
			end

			local monsterItem = {monster = boss; relativeTime = enterTime - preMonsterEnterTime; absoluteTime = enterTime; time = enterTime};
			table.insert(monsterList, monsterItem);

			bossFlag = true;
		end
	end

	if bossFlag then
		self.hasBoss = true;
		FightQTEManager.hasAppear = false;				--设置QTE未出现
	else
		self.hasBoss = false;
	end

	return {monsterList,idleMonsterList};
end

function FightManager:GetRankAllyRoleList()
	local leftFighterList = {};
	local allRoleList = Rank.self_data.roles;
	for _, actor in pairs(allRoleList) do
		local leftFighter = ActorManager:CreatePFighter(actor.resid);
		leftFighter:InitFightData(actor);
		table.insert(leftFighterList, leftFighter);
		if 0 == actor.pid then
			leftFighter:SetActorType(ActorType.hero);
		elseif actor.pid > 0 then
			leftFighter:SetActorType(ActorType.partner);
		end
	end
	self:SortEnterLineByJob(leftFighterList, false);
	return leftFighterList;
end

function FightManager:GetRankMonsterList(enemyRolesList)
	local monsterList = {};
	local idleMonsterList = {};
	for _, role in pairs(enemyRolesList) do
		local monster = ActorManager:CreatePFighter(role.resid, true);
		monster:InitFightData(role);
		local monsterItem = {monster = monster; relativeTime = 0, absoluteTime = 0; index = 1};
		table.insert(monsterList, monsterItem);
	end
	return {monsterList, idleMonsterList};
end
function FightManager:GetUnionBattleAllyRoleList()
	local leftFighterList = {};
	for _, actor in pairs(UnionBattle.allyTeamList) do
		local hpp = UnionBattle:AllyHP(actor.resid);
		if hpp ~= 0 then
			local role = ActorManager:GetRole(actor.pid);
			ActorManager:AdjustRole( role );
			local leftFighter = ActorManager:CreatePFighter(role.resid);
			leftFighter:InitFightData(role);
			leftFighter.m_propertyData:SetPercent(hpp);
			table.insert(leftFighterList, leftFighter);
			if 0 == actor.pid then
				leftFighter:SetActorType(ActorType.hero);
			elseif actor.pid > 0 then
				leftFighter:SetActorType(ActorType.partner);
			end
		end
	end
	--self.leftTotalAnger = UnionBattle.leaveAnger
	--leftFighter:SetAnger(UnionBattle.leaveAnger); --填充怒气
	self:SortEnterLineByJob(leftFighterList, false);
	return leftFighterList;
end
function FightManager:GetUnionBattleMonsterList(enemyRoleList)
	local monsterList = {};
	local idleMonsterList = {};
	local monsterAddAtt = UnionBattle:GetAtt();
	for _, role in pairs(enemyRoleList) do
		local hpp = UnionBattle:EnemyHP(role.resid)
		if hpp ~= 0 then
			local monster = ActorManager:CreatePFighter(role.resid, true);
			monster:InitFightData(role);
			local monsterAtt = monster.m_propertyData:GetCurrentPropertyData();
			local att = 0;
			if monsterAddAtt[1] then
				if monsterAddAtt[1] > 0 then
					att = monsterAtt.phy * monsterAddAtt[1] - monsterAtt.phy
					monster.m_propertyData:ChangePropertyData(FighterPropertyType.phy, att);
				end
			end
			if monsterAddAtt[2] then
				if monsterAddAtt[2] > 0 then
					att = monsterAtt.mag * monsterAddAtt[2] - monsterAtt.mag
					monster.m_propertyData:ChangePropertyData(FighterPropertyType.mag, att);
				end
			end
			if monsterAddAtt[3] then
				if monsterAddAtt[3] > 0 then
					att =  monsterAtt.phyDef * monsterAddAtt[3] - monsterAtt.phyDef
					monster.m_propertyData:ChangePropertyData(FighterPropertyType.phyDef,att);
				end
			end
			if monsterAddAtt[4] then
				if monsterAddAtt[4] > 0 then
					att = monsterAtt.magDef * monsterAddAtt[4] - monsterAtt.magDef
					monster.m_propertyData:ChangePropertyData(FighterPropertyType.magDef,att);
				end
			end
			if monsterAddAtt[5] then
				if monsterAddAtt[5] > 0 then
					att =  monsterAtt.hp * monsterAddAtt[5] - monsterAtt.hp
					monster.m_propertyData:ChangePropertyData(FighterPropertyType.hp,att);
					monster.m_propertyData:SetPercent(hpp);
				end
			end
			local monsterItem = {monster = monster; relativeTime = 0, absoluteTime = 0; index = 1};
			table.insert(monsterList, monsterItem);
		end
	end
	--self.rightTotalAnger = UnionBattle.anger_enemy

	return {monsterList, idleMonsterList};
end
function FightManager:GetExpeditionMonsterList(enemyRolesList)
	local monsterList = {};
	local idleMonsterList = {};
	for _, role in pairs(enemyRolesList) do
		local hpp = Expedition:EnemyHP(role.resid);
		if hpp ~= 0 then
			local monster = ActorManager:CreatePFighter(role.resid, true);
			monster:InitFightData(role);
			monster.m_propertyData:SetPercent(hpp);
			local monsterItem = {monster = monster; relativeTime = 0, absoluteTime = 0; index = 1};
			table.insert(monsterList, monsterItem);
		end
	end
	return {monsterList, idleMonsterList};
end

function FightManager:GetExpeditionAllyRoleList()
	local leftFighterList = {};
	for _, actor in pairs(Expedition.allyTeamList) do
		local hpp = Expedition:AllyHP(actor.resid);
		if hpp ~= 0 then
			local role = ActorManager:GetRole(actor.pid);
			ActorManager:AdjustRole( role );
			local leftFighter = ActorManager:CreatePFighter(role.resid);
			leftFighter:InitFightData(role);
			--leftFighter.m_propertyData:SetCurrentHP(math.floor(role.pro.hp * hpp * 1.5));
			--leftFighter.m_propertyData:SetMaxHP(math.floor(role.pro.hp * 1.5));
			leftFighter.m_propertyData:SetPercent(hpp);
			table.insert(leftFighterList, leftFighter);
			if 0 == actor.pid then
				leftFighter:SetActorType(ActorType.hero);
			elseif actor.pid > 0 then
				leftFighter:SetActorType(ActorType.partner);
			end
		end
	end
	-- leftFighter:SetAnger(anger); 填充怒气
	self:SortEnterLineByJob(leftFighterList, false);
	return leftFighterList;
end

function FightManager:GetCardEventMonsterList(enemyRolesList)
	local monsterList = {}
	local idleMonsterList = {}
	for _, role in pairs(enemyRolesList) do
		local hpp = CardEvent:EnemyHP(role.resid)
		if hpp ~= 0 then
			local monster = ActorManager:CreatePFighter(role.resid, true)
			monster:InitFightData(role)
			monster.m_propertyData:SetPercent(hpp);
			local monsterItem = {
				monster = monster,
				relativeTime = 0,
				absoluteTime = 0,
				index = 1
			}
			monsterList[#monsterList + 1] = monsterItem
		end
	end
	return {monsterList, idleMonsterList}
end

function FightManager:GetCardEventAllyRoleList()
	local leftFighterList = {}
	for _, actor in pairs(CardEvent.allyTeamList) do
		local hpp = CardEvent:AllyHP(actor.resid)
		if hpp ~= 0 then
			local role = ActorManager:GetRole(actor.pid)
			ActorManager:AdjustRole(role)
			local leftFighter = ActorManager:CreatePFighter(role.resid)
			leftFighter:InitFightData(role)
			leftFighter.m_propertyData:SetPercent(hpp);
			--leftFighter.m_propertyData:SetCurrentHP(math.floor(role.pro.hp * hpp))
			--leftFighter.m_propertyData:SetMaxHP(math.floor(role.pro.hp))
			table.insert(leftFighterList, leftFighter)
			if 0 == actor.pid then
				leftFighter:SetActorType(ActorType.hero)
			elseif actor.pid > 0 then
				leftFighter:SetActorType(ActorType.partner)
			end
		end
	end
	self:SortEnterLineByJob(leftFighterList, false)
	return leftFighterList;
end

function FightManager:GetTreasureAllyRoleList()
	local leftFighterList = {};
	for index = 5, 1, -1 do
		local pid = MutipleTeam:getCurrentTeam()[index];
		if pid >= 0 then
			local role = ActorManager:GetRole(pid);
			local leftFighter = ActorManager:CreatePFighter(role.resid);
			leftFighter:InitFightData(role);
			--更新血量值
			-- if next(Treasure.leaveHp) then Treasure:setHp(leftFighter, role); end
			table.insert(leftFighterList, leftFighter);
			if 0 == pid then
				leftFighter:SetActorType(ActorType.hero);
			elseif pid > 0 then
				leftFighter:SetActorType(ActorType.partner);
			end
		end
	end
	self:SortEnterLineByJob(leftFighterList, false);
	return leftFighterList;
end

--进入场景
function FightManager:enterScene( actor, isEnemy, monsterIndex )
	local index = 0;

	if not isEnemy then
		--己方
		index = Configuration.BattleYPositionLine[self:countLeftRowActor(actor)];
		actor:SetPosition(Vector3(self.leftPos.x + actor:GetDistCompensation(), self.yOrderList[actor:GetEnterLine()], 0));
		actor:SetDirection(DirectionType.faceright);
	else
		index = Configuration.BattleYPositionLine[self:countRightRowActor(actor)];
		actor:SetDirection(DirectionType.faceleft);
		if self.mFightType == FightType.worldBoss or self.mFightType == FightType.unionBoss then
			actor:SetPosition(Vector3(Configuration.BossInitXPosition + actor:GetDistCompensation(), self.yOrderList[index], 0));
		else
			actor:SetPosition(Vector3(self.rightPos.x + actor:GetDistCompensation(), self.yOrderList[index], 0));
		end
	end

	actor:SetEnterFight();										--设置角色已经入场的状态
	--   actor:SetZOrder(self.zOrderList[index]);					--设置角色zOrder，即设置图层
	self.scene:AddSceneNode(actor);								--添加到场景中,之后角色更新跟随场景更新

	table.insert(self.actorList, actor);

	--触发左侧个体进入战斗场景事件
	if not isEnemy then
		EventManager:FireEvent(EventType.LeftPersonEnterFightScene, Task:getMainTaskId(), self.count);
	end

	self:SortZOrder();

	--增加相关联的debug项
	FightUIManager:addDebugItem(actor, isEnemy);
end

--加载提前入场的怪物
function FightManager:enterSceneBeforBattle(actor, xPosition, index)
	local pos = Vector3(xPosition + actor:GetDistCompensation(), self.yOrderList[index], 0);
	local dir = DirectionType.faceleft;

	actor:SetEnterFight();										--设置角色已经入场的状态
	actor:SetDirection(dir);
	actor:SetPosition(pos);
	--actor:SetZOrder(self.zOrderList[math.mod(index - 1, #self.zOrderList) + 1]);					--设置角色zOrder，即设置图层
	self.scene:AddSceneNode(actor);								--添加到场景中,之后角色更新跟随场景更新

	table.insert(self.actorList, actor);

	self:SortZOrder();

	--增加相关联的debug项
	FightUIManager:addDebugItem(actor, true);
end

--排序场景中角色和特效的ZOrder
function FightManager:SortZOrder()
	if not self.scene then return end;
	self.scene:GetRootCppObject():SortChildren();	--zorder排序
end

--添加boss来袭动画
function FightManager:TriggerBossComing()
	if self.mFightType == FightType.noviceBattle then --旷世大战
		EventManager:FireEvent(EventType.BossEnterFightScene);
	end
	AvatarManager:LoadFile(GlobalData.EffectPath .. 'BOSScoming_output/');
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature('BOSScoming');
	armatureUI:SetAnimation('play');
	armatureUI:SetScale(2, 2);
	armatureUI.Horizontal = ControlLayout.H_CENTER;
	armatureUI.Vertical = ControlLayout.V_CENTER;
	armatureUI.Pick = false;
	self.desktop:AddChild(armatureUI);
end

--加载入场角色和怪物
function FightManager:loadFighter(elapse)
	--间隔n秒进入一个人物
	if self.time - self.lastPlayerEnterTime > self.enterSpacingTime then
		self.lastPlayerEnterTime = self.time;
		self:loadAllyPlayer();			--加载友方角色

		if self.isPvP then
			self:loadEnemyPlayer();		--加载pvp敌方角色
		end
		if self.mFightType == FightType.noviceBattle then
			self.enterSpacingTime = Configuration.SuperFightPartnerEnterSpacingTime[#self.leftActorList];
		end
	end

	if self.isPvP == false then
		self:loadMonster(elapse);					--怪物入场
	end
end

function FightManager:NoviceEnterScene()
	self.enterSpacingTime = 0;
end

--加载本方角色
function FightManager:loadAllyPlayer()
	if #(self.needleftActorList) ~= 0 then
		local enterFighter = self.needleftActorList[1];
		self.count = self.count + 1;								--记录本方已入场人数
		enterFighter:SetStation(self.count, self:countLeftRowActor(enterFighter));
		enterFighter:SetIsEnemy(false);							--设置角色不为敌方
		enterFighter:SetKeepIdle();
		FightManager:enterScene( enterFighter, false );	--人物进入场景
		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, enterFighter, self.count);

		--重置人物入场时间间隔
		if self.mFightType == FightType.noviceBattle then		--旷世大战
			-- 这个不这么用
			-- self.enterSpacingTime = Configuration.SuperFightPartnerEnterSpacingTime[self.count];
		else													--其他战斗
			if 1 == self.count then
				self.enterSpacingTime = Configuration.PartnerEnterSpacingTime;
			end
		end

		table.insert(self.leftActorList, enterFighter);
		table.insert(self.constLeftActorList, enterFighter);
		table.remove(self.needleftActorList, 1);


		--这里分两种情况，pvp需要两侧人员全部登场再释放halo
		if not self.isPvP and FightType.unionBattle ~= self.mFightType then
			if #(self.needleftActorList) == 0 then --所有人都上场以后,开始上光环
				self:CastHaloFromList(self.leftActorList);
			end
		else
			self:CheckHaloCastAndAngerInPvP();
		end

	end

end

--两边所有人都进场，才可以上光环
function FightManager:CheckHaloCastAndAngerInPvP()
	if #(self.needrightActorList) == 0 and #(self.needleftActorList) == 0 then --所有人都上场以后,开始上光环
		self:CastHaloFromList(self.rightActorList);
		self:CastHaloFromList(self.leftActorList);
		if FightType.unionBattle == self.mFightType then
			if UnionBattle.leaveAnger and UnionBattle.leaveAnger > 0 then
				self:AddTotalAnger(UnionBattle.leaveAnger)
				print('CheckHaloAnger------->'..tostring(UnionBattle.leaveAnger))
			end
			if UnionBattle.anger_enemy and UnionBattle.anger_enemy > 0 then
				self:AddTotalEnemyAnger(UnionBattle.anger_enemy)
				print('CheckHaloEnemyAnger------->'..tostring(UnionBattle.anger_enemy))
			end
		end
	end
end

--加载pvp敌方角色
function FightManager:loadEnemyPlayer()
	if #(self.needrightActorList) ~= 0 then
		local enterFighter = self.needrightActorList[1];
		self.enemyCount = self.enemyCount + 1;									--记录敌方已入场人数
		enterFighter:SetStation(self.enemyCount, self:countRightRowActor(enterFighter));
		enterFighter:SetIsEnemy(true);							--设置角色为敌方
		enterFighter:SetKeepIdle();
		FightManager:enterScene( enterFighter, true );			--人物进入场景;

		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, enterFighter, self.enemyCount);

		--触发角色入场的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.enterScene, self.time, enterFighter);

		table.insert(self.rightActorList, enterFighter);
		table.remove(self.needrightActorList, 1);

		self:CheckHaloCastAndAngerInPvP();
	end

end

function FightManager:AnyEnemyInScreen()

	for _, actor in pairs(self.rightActorList) do
		if actor:isInScreenCamera() then
			return true;
		end
	end

	return false;
end

-- 计算当前出场角色中的某一排的人数(按照攻击范围区分某排)
function FightManager:countLeftRowActor(enterFighter)
	if self.leftActorList == nil or #self.leftActorList == 0 then
		return 1;
	end
	local count = 0;
	for _, actor in ipairs(self.leftActorList) do
		if actor.m_attackRange == enterFighter.m_attackRange then
			count = count + 1;
		end
	end
	count = (count + 1) % 5;
	return count == 0 and 5 or count;
end

-- 计算当前出场角色中的某一排的人数(按照攻击范围区分某排)
function FightManager:countRightRowActor(enterFighter)
	if self.rightActorList == nil or #self.rightActorList == 0 then
		return 1;
	end
	local count = 0;
	for _, actor in ipairs(self.rightActorList) do
		if actor.m_attackRange == enterFighter.m_attackRange then
			count = count + 1;
		end
	end
	count = (count + 1) % 5;
	return count == 0 and 5 or count;
end


--加载提前入场的怪物
function FightManager:loadIdleMonster()
	if 0 == #(self.idleMonsterList) then
		return;
	end

	--加载提前入场的怪物
	for _,monsterItem in ipairs(self.idleMonsterList) do
		self.enemyCount = self.enemyCount + 1;						--记录敌方已入场人数
		monsterItem.monster:SetStation(self.enemyCount, self:countRightRowActor(monsterItem.monster));
		FightManager:enterSceneBeforBattle( monsterItem.monster, monsterItem.xPos, monsterItem.index );

		--角色入场事件
		EventManager:FireEvent(EventType.FighterEnterFight, monsterItem.monster, self.enemyCount, false);

		--触发角色入场的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.enterScene, self.time, self.needrightActorList[1]);

		table.insert(self.rightActorList, monsterItem.monster);												--插入怪物列表
	end

	--所有怪都上场以后,开始上光环
	self:CastHaloFromList(self.rightActorList);

	--初始化怪物combo技能
	FightComboQueue:InitRightSkill(self.rightActorList);

	--战斗场景中待机怪唔触发觉醒的警戒线
	local pos = self.idleMonsterList[1].monster:GetPosition();
	if self.mFightType == FightType.worldBoss then
		self.idleMonsterList[1].monster:SetPosition(Vector3(pos.x + self.idleMonsterList[1].monster:GetDistCompensation(), Configuration.YOrderList[3], 0));
	end
	self.alertLineXposition = pos.x - Configuration.AlertDistance;
	self.idleMonsterList = {};
end

--怪物入场
function FightManager:loadMonster(elapse)
	while true do
		if 0 ~= #(self.needrightActorList) then
			local length = #(self.needrightActorList);												--剩余未进场怪物个数
			local flagIsBoss = ((ActorType.boss == self.needrightActorList[length].monster:GetActorType()) or (ActorType.eliteMonster == self.needrightActorList[length].monster:GetActorType()));
			local flag = flagIsBoss and (self.time >= (self.needrightActorList[length].time - monsterEnterAdvancedTime) or (1 == length and 0 == #self.rightActorList));

			if flag then
				local monster = self.needrightActorList[length].monster;
				self.enemyCount = self.enemyCount + 1;							--记录敌方已入场人数
				-- monster:SetStation(self.enemyCount, self:countRightRowActor(monster));
				monster:SetStation(self.enemyCount, 2);
				FightManager:enterScene( monster, true, 2 );					--角色进入场景

				self.CastHaloFromList({monster}); -- 让这个怪单独发动一次光环

				--角色入场事 Boss入场
				EventManager:FireEvent(EventType.FighterEnterFight, monster, self.enemyCount, true)

				table.insert(self.rightActorList, monster);					--插入怪物列表
				table.remove(self.needrightActorList, length);					--将第一波怪从怪物总表中删除
			end

			--怪物入场时间
			if nil ~= self.needrightActorList[1] then
				local flag = ((self.time - lastMonsterEnterTime) >= self.needrightActorList[1].relativeTime) or (0 == #self.rightActorList);

				if flag then	--相对入场时间
					lastMonsterEnterTime = self.time;													--记录上一个怪物的入场时间
					monsterEnterAdvancedTime = self.needrightActorList[1].absoluteTime - self.time;		--记录怪物入场提前的时间
					local monster = self.needrightActorList[1].monster;
					self.enemyCount = self.enemyCount + 1;												--记录敌方已入场人数
					monster:SetStation(self.enemyCount, self:countRightRowActor(monster));

					FightManager:enterScene( monster, true, self.needrightActorList[1].index );		--小怪入场
					table.insert(self.rightActorList, monster);										--插入怪物列表
					table.remove(self.needrightActorList, 1);											--将第一波怪从怪物总表中删除
				else
					break;
				end
			end
		else
			break;
		end
	end
end

--从角色列表中删除某个角色
function FightManager:DeleteFighter(fighter)


	table.insert(self.deathActorList, fighter);
	local actorList = {};
	if fighter:IsEnemy() then
		actorList = self.rightActorList;
		self:AddKillMonster(fighter:GetResID());
	else
		actorList = self.leftActorList;
	end

	local index = nil;
	for i,role in pairs(actorList) do
		if fighter:GetID() == role:GetID() then
			index = i;
			break;
		end
	end
	if index then table.remove(actorList, index); end

	--在人员变动时，同步连击系统的技能列表
	if fighter:IsEnemy() then
		FightComboQueue:InitRightSkill(self.rightActorList);
		FightComboQueue:DelDiePursuitSkill(1, fighter);
	else
		FightComboQueue:InitLeftSkill(self.leftActorList);
		FightComboQueue:DelDiePursuitSkill(0, fighter);
	end

	--判断战斗是否结束
	self:UpdateBattleIsOver();
end

--获得最前面的本方角色
function FightManager:getCameraReferenceX()
	if #self.leftActorList == 0 then
		self.cameraMoveSpeed = Configuration.CameraMoveSpeed;
		return -10000;
	else
		self.cameraMoveSpeed = self.leftActorList[1]:GetPropertyData(FighterPropertyType.movSpe);
		return self.leftActorList[1]:GetPosition().x + self.leftActorList[1]:GetNormalAttackRange()/2 + self.leftActorList[1]:GetWidth()/2;
	end
end

function FightManager:distributeCard(elapse)
  if self.time > self.lastDistributeCardTime then
    self.lastDistributeCardTime = self.time
    if FightType.rank == self.mFightType then
      self.lastDistributeCardTime = self.lastDistributeCardTime + Configuration.distributeCardTimeInRankFight;
    else
      self.lastDistributeCardTime = self.lastDistributeCardTime + Configuration.distributeCardTime;
    end

    if appFramework:IsInBackground() then return; end;
    self:AddTotalAnger(100);
    self:AddTotalEnemyAnger(100);
  end
end

--进行战斗
function FightManager:fightBattles(elapse)
	self.time = self.time + elapse;				--累计时间

	FightUIManager:Update(elapse);				--战斗UI更新

	__.each ( self.rightActorList, function( actor )
		actor:updateDebug();
	end)
	__.each ( self.leftActorList, function( actor )
		actor:updateDebug();
	end)

	--用于判断是否加载了角色
	local numLeft = #(self.needleftActorList);
	local numRight = #(self.needrightActorList);

	--加载战斗角色
	if (0 ~= #(self.needleftActorList) or 0 ~= #(self.needrightActorList)) and (not self.isOver) then
		self:loadFighter(elapse);
		if numLeft > #(self.needleftActorList) then
			FightComboQueue:InitLeftSkill(self.leftActorList);
		end
		if numRight > #(self.needrightActorList) then
			FightComboQueue:InitRightSkill(self.rightActorList);
		end
	end

	self:SortActorList();
	self:SortZOrder();

	--判断战斗是否结束
	if self:IsOver() then
		return;
	end
	if not (self.mFightType == FightType.noviceBattle) then
		self:distributeCard(elapse);              --每到10秒分发一次卡牌
	end

	self.cameraReferenceX = self:getCameraReferenceX();		--移动相机
	self:moveCamera(elapse);
end

--更新战斗是否结束
function FightManager:UpdateBattleIsOver()
	if self.isOver then
		return;
	end

	--战斗结束判断
	if #(self.actorList) ~= 0 then
		if (#self.needleftActorList == 0) and (#self.leftActorList == 0) then
			self.isOver = true;
			self.result = Victory.right;
		elseif (#self.needrightActorList == 0) and (#self.rightActorList == 0) and (#self.idleMonsterList == 0) then
			self.isOver = true;
			self.result = Victory.left;
		end
	end

	if self.isOver then
		if platformSDK.m_System ~= "Win32" then
			os.remove(appFramework:GetCachePath() .. "debug.txt");
		end
	end

	-- if self.isOver and FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == 8 and FightImageGuidePanel.isShowNextPic then
	--    FightImageGuidePanel:showTipsPic();
	--    return;
	-- end

	--战斗结束
	if self.isOver then
		--最后一个人物死亡
		self:StartSlowMotion();
		self.enablePause = false; -- 禁止按下暂停按钮
		--删除技能图标特效
		FightUIManager:DestroyAllSkillEffect();
		if FightType.expedition == self.mFightType then
			Expedition:FightOver();
			Expedition.leaveAnger = 0;

		elseif FightType.cardEvent == self.mFightType then
			CardEvent:FightOver()
			CardEvent.leaveAnger = 0
		elseif FightType.unionBattle == self.mFightType then
			UnionBattle:FightOver()
		end

		local updateExpeditionHp = function(team, actor)
			if FightType.expedition == self.mFightType then
				__.each(team, function(a)
					if tonumber(a.resid) == tonumber(actor.resID) then
						a.hp = CheckDiv(actor:GetCurrentHP() / actor:GetMaxHP());
					end
				end)
			end
		end

		local updateCardEventHp = function(team, actor)
			if FightType.cardEvent == self.mFightType then
				__.each(team, function(a)
					if tonumber(a.resid) == tonumber(actor.resID) then
						a.hp = CheckDiv(actor:GetCurrentHP() / actor:GetMaxHP())
					end
				end)
			end
		end
		local updateUnionBattleHp = function(team, actor)
			if FightType.unionBattle == self.mFightType then
				__.each(team, function(a)
					if tonumber(a.resid) == tonumber(actor.resID) then
						a.hp = CheckDiv(actor:GetCurrentHP() / actor:GetMaxHP())
					end
				end)
			end
		end
		--将角色设置成待机动作
		Treasure:updateTreasureHp();
		for _, actor in ipairs(self.leftActorList) do
			actor:SetStateAfterBattle();
			updateExpeditionHp(Expedition.allyTeamList, actor);
			updateCardEventHp(CardEvent.allyTeamList, actor);
			updateUnionBattleHp(UnionBattle.allyTeamList,actor)
		end
		for _, actor in ipairs(self.rightActorList) do
			actor:SetStateAfterBattle();
			updateExpeditionHp(Expedition.enemyTeamList, actor);
			updateCardEventHp(CardEvent.enemyTeamList, actor);
			updateUnionBattleHp(UnionBattle.enemyTeamList,actor)
		end
		if FightType.expedition == self.mFightType then
			Expedition:reqExitExpedition(self.result == Victory.left);
		elseif FightType.cardEvent == self.mFightType then
			CardEvent:reqExitCardEvent(self.result == Victory.left)
		elseif FightType.unionBattle == self.mFightType then
			--UnionBattle:reqExitUnionBattle(self.result == Victory.left)
		elseif FightType.scuffle == self.mFightType then
			Scuffle:updateAllyHp(self.leftActorList);
		end
	end
end

--判断战斗是否结束
function FightManager:IsOver()
	if (self.isOver) then
		return true;
	end

	return false;
end

--根据位置排序角色列表
function FightManager:SortActorList()
	table.sort(self.leftActorList, function (tar1, tar2)
		return tar1:GetPosition().x > tar2:GetPosition().x;
	end);

	if #self.leftActorList > 0 then
		self.frontPositionList[DirectionType.faceleft] = self.leftActorList[1]:GetPosition().x + self.leftActorList[1]:GetWidth() / 2;
	else
		self.frontPositionList[DirectionType.faceleft] = self.leftPos.x;
	end

	table.sort(self.rightActorList, function (tar1, tar2)
		return tar1:GetPosition().x < tar2:GetPosition().x;
	end);

	if #self.rightActorList > 0 then
		self.frontPositionList[DirectionType.faceright] = self.rightActorList[1]:GetPosition().x - self.rightActorList[1]:GetWidth() / 2;
	else
		self.frontPositionList[DirectionType.faceright] = self.rightPos.x;
	end
end

--获取排序后的角色列表
function FightManager:GetOrderedTargeterList(isEnemy)
	if isEnemy then
		return self.rightActorList;
	else
		return self.leftActorList;
	end
end

--获取角色当前可以移动到的最前的位置
function FightManager:GetForwardPosition(fighter)
	if fighter:GetDirection() == DirectionType.faceright then
		if fighter:GetPosition().x + fighter:GetWidth() / 2 > self.frontPositionList[DirectionType.faceright] then
			return false, self.frontPositionList[DirectionType.faceright];
		else
			return true;
		end
	else
		if fighter:GetPosition().x - fighter:GetWidth() / 2 < self.frontPositionList[DirectionType.faceleft] then
			return false, self.frontPositionList[DirectionType.faceleft];
		else
			return true;
		end
	end
end

--获取出生点坐标
function FightManager:GetBornPosition(directionType)
	if directionType == DirectionType.faceright then
		return self.rightPos.x;
	else
		return self.leftPos.x;
	end
end

--=====================================================================================
--数值计算
--=====================================================================================
function FightManager:GetAchievement()
	return self.currentAchievement and self.currentAchievement:getCompleteRes() or nil;
end

--=======================================================================================
--新手战斗
function FightManager:NoviceBattle()
	--进入关卡
	while true do
		if threadPool:IsThreadFuncFinished() then
			self:InitAllFightersAvatar();
			break;
		end
	end
end

--=======================================================================================
--录像相关
--=======================================================================================
--录像恢复
function FightManager:RecordContinue()
	self.state = FightState.recordState;
	self.recordPauseTime = 0;
	self:ResumeEffectScript();
end

--录像暂停
function FightManager:RecordPause()
	self.state = FightState.recordPauseState;

	self:PauseEffectScript();
end

--是否录像模式
function FightManager:IsRecord()
	if (FightState.recordState == self.state) or (FightState.recordPauseState == self.state) then
		return true;
	else
		return false;
	end
end

--获取录像中的角色
function FightManager:GetFighter(teamIndex, isEnemy)
	if nil == teamIndex then
		return nil;
	end

	if (isEnemy) then
		return self.needrightActorList[teamIndex];
	else
		return self.needleftActorList[teamIndex];
	end
end

--设置战斗结束
function FightManager:SetOver(result)
	self.isOver = true;
	self.result = result;
	if platformSDK.m_System ~= "Win32" then
		os.remove(appFramework:GetCachePath() .. "debug.txt");
	end
end

--更新录像
function FightManager:updateRecord(elapse, time)
	--更新UI
	FightUIManager:Update(elapse);				--战斗UI更新

	--更新录像事件
	FightRecordManager:UpdateRecordEvent(time);

	--排序角色
	self:SortActorList();

	if self.isOver then
		return;				--战斗结束
	end

	--移动相机
	self.cameraReferenceX = self:getCameraReferenceX();
	self:moveCamera(elapse);
end

--更新非暂停录像
function FightManager:updateRecordNoPause(elapse)
	self.time = self.time + elapse;				--累计时间
	self:updateRecord(elapse, self.time);
end

--录像暂停时的更新
function FightManager:updateRecordOnPause(elapse)
	self.recordPauseTime = self.recordPauseTime + elapse;
	self:updateRecord(elapse, self.recordPauseTime);
end

--调整角色血量
function FightManager:adjustFighterHP(hpList)
	if hpList.allyHpList ~= nil then
		for index, fighter in ipairs(self.needleftActorList) do
			fighter:AdjustHP(hpList.allyHpList[index]);
		end
	end

	if hpList.enemyHpList ~= nil then
		for index, fighter in ipairs(self.needrightActorList) do
			fighter:AdjustHP(hpList.enemyHpList[index]);
		end
	end
end

--获取己方的hp总量
function FightManager:getAllyTotalHP()
	return self.allyTotalHP;
end

--获取敌方的hp总量
function FightManager:getEnemyTotalHP()
	return self.enemyTotalHP;
end

function FightManager:getFinalHpPercent()
	local totalHp = 0;
	for _, fighter in pairs(self.leftActorList) do
		totalHp = totalHp + fighter.m_propertyData:GetCurrentHP();
	end

	return CheckDiv(totalHp / self.allyTotalHP);
end

function FightManager:setAllLeftRoleDie()
	if self.isOver then
		return;
	end
		local actor_id = {};

	for id,fighter in pairs(self.leftActorList) do
		table.insert(actor_id,id);
	end
	table.sort(actor_id);
	for i=#actor_id,1,-1 do
		self.leftActorList[i]:SetDie();
	end
end

function FightManager:getFightUseTime()
	return 0;
end
--=======================================================================================
--属性设置和获取
--=======================================================================================

--获取战斗持续时间
function FightManager:GetTime()
	return self.time;
end

--获取战斗状态
function FightManager:GetState()
	return self.state;
end

--获取战斗方式是否为自动战斗
function FightManager:IsAuto()
	return self.isAuto;
end

--临时关闭自动战斗
function FightManager:CloseAutoTemporarily()
	self.tempAutoState = self.isAuto;
	self.isAuto = false;

	if self.isAuto then
		self.autoButton.Text = LANG_fightManager_3;
	else
		self.autoButton.Text = LANG_fightManager_4;
	end
end

--恢复临时关闭的自动战斗
function FightManager:RecoverAutoTemporarily()
	self.isAuto = self.tempAutoState;

	if self.isAuto then
		self.autoButton.Text = LANG_fightManager_5;
	else
		self.autoButton.Text = LANG_fightManager_6;
	end
end


--计算当前的战斗状态
function FightManager:fightType()
	if ((self.barrierId >= RoundIDSection.NormalBegin) and (self.barrierId <= RoundIDSection.NormalEnd)) or ((self.barrierId >= RoundIDSection.NormalEliteBeign) and (self.barrierId <= RoundIDSection.NormalEliteEnd)) then
		self.mFightType = FightType.normal;			--普通关卡
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.EliteBegin) and (self.barrierId <= RoundIDSection.EliteEnd) then
		self.mFightType = FightType.elite;			--精英关卡
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.SoulBegin) and (self.barrierId <= RoundIDSection.SoulEnd) then
		self.mFightType = FightType.normal;			--魂师关卡
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.ZodiacBegin) and (self.barrierId <= RoundIDSection.ZodiacEnd) then
		self.mFightType = FightType.zodiac;			--十二宫
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.InvasionBegin) and (self.barrierId <= RoundIDSection.InvasionEnd) then
		self.mFightType = FightType.invasion;		--杀星
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.TreasureBegin) and (self.barrierId <= RoundIDSection.TreasureEnd) then
		self.mFightType = FightType.treasureBattle;	--巨龙宝库
		self.isPvP = false;
	elseif (self.barrierId >= RoundIDSection.MiKuBegin) and (self.barrierId <= RoundIDSection.MiKuEnd) then
		self.mFightType = FightType.miku;			--迷窟
		self.isPvP = false;
	elseif self.barrierId == RoundIDSection.NoviceBattleID then
		self.mFightType = FightType.noviceBattle;	--新手战斗
		self.isPvP = false;
	elseif self.barrierId == FightType.worldBoss then
		self.mFightType = FightType.worldBoss;		--世界boss战
		self.isPvP = false;
	elseif self.barrierId == FightType.unionBoss then
		self.mFightType = FightType.unionBoss;		--公会boss
		self.isPvP = false;
	elseif self.barrierId == FightType.FriendBattle then
		self.mFightType = FightType.FriendBattle;	--好友挑战
		self.isPvP = true;
	elseif self.barrierId >= RoundIDSection.LimitRoundBegin and self.barrierId <= RoundIDSection.LimitRoundEnd then
		self.mFightType = FightType.limitround;		--限时副本
		self.isPvP = false;
	elseif self.barrierId >= RoundIDSection.ExpeditionBegin and self.barrierId <= RoundIDSection.ExpeditionEnd then
		self.mFightType = FightType.expedition;
		self.isPvP = false;
	elseif self.barrierId >= RoundIDSection.CardEventBegin and self.barrierId <= RoundIDSection.CardEventEnd then
		self.mFightType = FightType.cardEvent
		self.isPvP = false
	elseif self.barrierId == FightType.rank then
		self.mFightType = FightType.rank;	--排位赛
		self.isPvP = false;
	elseif self.barrierId == FightType.unionBattle then
		self.mFightType = FightType.unionBattle;	--社团战
		self.isPvP = false;
		--elseif self.barrierId == FightType.scuffle then
		--  self.mFightType =  FightType.scuffle;	
		--   self.isPvP = false;
	else
		self.isPvP = true;
		self.isAuto = true;
		self.mFightType = self.barrierId;
	end
end

function FightManager:isGCDPVP()
	if self.isPvP or self.mFightType == FightType.cardEvent then
		return true;
	end
	return false;
end

--获取战斗类型
function FightManager:GetFightType()
	return self.mFightType;
end

--警戒线X轴
function FightManager:GetAlertLineXposition()
	return self.alertLineXposition;
end

--设置入场角色个数
function FightManager:SetFighterCount(fighter, count, isEnemy)
	if isEnemy then
		self.enemyCount = count;
	else
		self.count = count;
	end
end

--计算死亡人数
function FightManager:getDeadNum()
	local deadNum = self.count - #(self.leftActorList);
	return deadNum;
end

--设置待机怪物中第一个觉醒怪觉醒的时间
function FightManager:SetFirstIdleMonsterWakeUpTime(isTouchTheAlertLine)
	if self.isRecord then
		return;
	end

	if not self.isPvP then
		if nil == self.firstIdleMonsterWakeUpTime then
			self.firstIdleMonsterWakeUpTime = self.time;
			if isTouchTheAlertLine then
				Debug.assert(self.rightActorList[1], "aaaaaaaaaaaa");
				self.rightActorList[1]:SetIdle();
			end
		end
	end
end

--获取待机怪物中第一个觉醒怪觉醒的时间
function FightManager:GetFirstIdleMonsterWakeUpTime()
	return self.firstIdleMonsterWakeUpTime;
end

--重置战斗结果数据
function FightManager:ResetResultData()
	self.goodsKindList      = {};				--掉落物品列表
	self.rmb			= nil;				--掉落水晶个数
	self.coin			= nil;				--掉落金币数量
	self.soul			= nil;				--掉落灵能数量
	self.exp			= nil;				--关卡经验
	self.lovevalue 		= nil;
	self.zhanli			= nil;				--pvp战斗奖励的战历
	self.isLevelUp		= false;			--战斗结束后主角是否升级
	self.level			= nil;		--如果主角升级，存储升级后的等级
	self.stars			= nil;				--该关卡获得的星星数
	self.jifen			= nil;				--乱斗场积分
	self.shengwang		= nil;				--竞技场声望
end

--设置是否需要再次更新录像
function FightManager:SetNeedUpdateRecordAgain(flag)
	needUpdateRecordAgain = flag;
end

--设置主角是否升级
function FightManager:SetHeroLevelUp(level)
	self.isLevelUp = true;
	self.level = level;
end

--设置助战英雄
function FightManager:SetAssistHero(hero)
	if true then return end;
	hasAssistHero = true;
	local leftFighter = ActorManager:CreatePFighter(hero.resid, false);
	leftFighter:SetActorType(ActorType.partner);
	leftFighter.isAssist = true;
	leftFighter:InitFightData(hero);
	if leftFighter:IsMeleeFighter() then
		leftFighter:SetEnterLine(self.meleeFighterCount);
		self.meleeFighterCount = self.meleeFighterCount + 1;
	else
		leftFighter:SetEnterLine(self.remoteFighterCount + self.meleeFighterCount);
		self.remoteFighterCount = self.remoteFighterCount + 1;
	end
	leftFighter:InitAvatar();
	table.insert(self.needleftActorList, leftFighter);
end

--设置掉落物品
function FightManager:SetFallingGoods( goods )

	self.goodsKindList = goods;

	if (FightType.normal == self.mFightType) and (boss ~= nil) then
		boss:AddFallGoods(goods);

	elseif FightType.elite == self.mFightType or FightType.miku == self.mFightType then
		boss:AddFallGoods(goods);			--精英关卡，掉落物品集中在boss身上

	elseif (FightType.treasureBattle == self.mFightType) and (boss ~= nil) then
		boss:AddFallGoods(goods);		--巨龙宝库关卡战斗，掉落物品集中在boss身上

	elseif FightType.limitround == self.mFightType then
		for _, good in pairs(goods) do
			boss:AddFallGoodsNoLimit(good.resid);
		end

	elseif FightType.zodiac == self.mFightType then
		--十二宫不显示掉落

	else
		--其他关卡，掉落平摊到每个小怪身上
		local actorList = {};
		for _,v in ipairs(self.rightActorList) do
			table.insert(actorList, v);
		end
		for _,v in ipairs(self.needrightActorList) do
			table.insert(actorList, v.monster);
		end

		for _,goodsItem in ipairs(goods) do
			for index = 1, goodsItem.num do
				while true do
					if (#actorList == 0) then
						return;
					end

					local count = Math.IRangeRandom(1, #actorList);
					local actor = actorList[count];
					--判断角色掉落物品是否达到最大数
					if Configuration.GoodsFallMaxCount > #(actor:GetFallGoodsIDList()) then
						--添加掉落物品
						actor:AddFallGoods(goodsItem.resid);
						break;
					else
						table.remove(actorList, count);
					end
				end
			end
		end
	end
end

--设置掉落金币
function FightManager:SetFallingCoin( coin )
	self.coin = coin;
end

--设置掉落灵能
function FightManager:SetFallingSoul( soul )
	self.soul = soul;
end

--设置关卡经验
function FightManager:SetExp( exp )
	self.exp = exp;
end

--设置关卡爱恋度
function FightManager:SetLoveValue(lovevalue)
	self.lovevalue = lovevalue;
end

--设置pvp战历奖励
function FightManager:SetZhanli(zhanli)
	self.zhanli = zhanli;
end

--设置乱斗场积分
function FightManager:SetJifen(jifen)
	self.jifen = jifen;
end

--设置声望
function FightManager:SetShengWang(shengwang)
	self.shengwang = shengwang;
end

--设置掉落水晶
function FightManager:SetFallingRmb( rmb )
	self.rmb = rmb;
end

--获取关卡boss
function FightManager:GetBoss()
	if self.hasBoss then
		return boss;
	else
		return nil;
	end
end

--boss死亡后，设置所有monster角色死亡
function FightManager:SetAllMonsterDie()
	if not self.isRecord then
		self.needrightActorList = {};						--清空未进场怪物
		while #(self.rightActorList) > 0 do				--设置战场中为死亡角色死亡
			local fightActor = self.rightActorList[1];
			fightActor:SetDie();
		end

		self:UpdateBattleIsOver();
	end
end

--=======================================================================================
--事件
--=======================================================================================
--获取战斗结果数据
function FightManager:GetFightResultData()
	--触发战斗结束事件
	local resultData = {};
	resultData.zhanli = self.zhanli;
	resultData.coin = self.coin;
	resultData.soul = self.soul;
	resultData.shengwang = self.shengwang;
	resultData.starsCount = 0; --计算星数
	resultData.stars = self:GetAchievement() or "0"; --获取成就
	resultData.isLevelUp = self.isLevelUp;
	resultData.isShowTryAgain = false;
	resultData.level = self.level;
	resultData.exp = self.exp;
	resultData.rmb = self.rmb;
	resultData.lovevalue = self.lovevalue;
	resultData.jifen = self.jifen;
	resultData.goodsList = self.goodsKindList;
	resultData.id = self.barrierId;
	resultData.fightType = self.mFightType;
	resultData.result = self.result;
	resultData.damage = self.rightTotalDamage;
	if (self.mFightType == FightType.zodiac)then
		resultData.fighterAngerList = {};
		resultData.gesturePower = FightUIManager:GetGesturePower();							--剩余手势能量
		local curTotalHp = 0;																--当前角色总血量
		local originalTotalHp = 0;															--最初的角色总血量
		for _, fighter in ipairs(self.constLeftActorList) do
			resultData.fighterAngerList[fighter:GetResID()] = fighter:GetCurrentAnger();	--保存角色的怒气
			curTotalHp = curTotalHp + fighter:GetCurrentHP();
			originalTotalHp = originalTotalHp + fighter:GetMaxHP();
		end
		resultData.hp_percent = CheckDiv(curTotalHp / originalTotalHp);
	end
	--[[
	if (self.mFightType == FightType.zodiac) or (self.mFightType == FightType.scuffle) then
		resultData.fighterAngerList = {};
		resultData.gesturePower = FightUIManager:GetGesturePower();							--剩余手势能量
		local curTotalHp = 0;																--当前角色总血量
		local originalTotalHp = 0;															--最初的角色总血量
		for _, fighter in ipairs(self.constLeftActorList) do
			resultData.fighterAngerList[fighter:GetResID()] = fighter:GetCurrentAnger();	--保存角色的怒气
			curTotalHp = curTotalHp + fighter:GetCurrentHP();
			originalTotalHp = originalTotalHp + fighter:GetMaxHP();
		end
		resultData.hp_percent = CheckDiv(curTotalHp / originalTotalHp);
	end
	]]	
	return resultData;
end

--获取任务击杀怪物列表
function FightManager:GetKillMonsterList()
	local list = {{resid = 0, num = 0}};
	for resid,num in pairs(self.killedList) do
		table.insert(list, {resid = tonumber(resid), num = num});
	end

	return list;
end

--添加死亡怪物
function FightManager:AddKillMonster(resid)
	--[[
	if tonumber(resid) == 3002 and FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightSkillCardManager.isStop then
		FightComboQueue:setIsStop(true);
	end--]]
	if self.killedList[resid] == nil then
		self.killedList[resid] = 1;
		--增加第一个怪物的死亡事件
		self.deadActorTime[resid] = FightUIManager:getTimeGone();
	else
		self.killedList[resid] = self.killedList[resid] + 1;
	end
end

--查找怪物死亡时间
function FightManager:findDeadTime(monsterID)
	local time = 3600;
	for id, timecost in pairs(self.deadActorTime) do
		if tonumber(id) == tonumber(monsterID) then
			time = timecost;
		end
	end
	return time;
end
function FightManager:isMaxLove()
	local team = MutipleTeam:getCurrentTeam()
	local heroNum = 0
	for i=5,1,-1 do
		if team[i] >= 0 then
			heroNum = heroNum + 1
		end
	end
	if heroNum == 1 then
		local member = ActorManager:GetRole(0)      --  一个人可能是主角,属性试炼时一个人也不一定是主角
		if self.mFightType and self.mFightType == FightType.limitround then         --  如果是属性试炼
			team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
		end
		if self.mFightType and self.mFightType == FightType.invasion then
			local teamId = MutipleTeam:getDefault()
			team = MutipleTeam:getTeam(teamId)
		end

		for i=5,1,-1 do
			if team[i] >= 0 then
				member = ActorManager:GetRole(team[i])
			end
		end
		local rand = 0;
		if member.lvl.lovelevel == 4 then
			rand = 16;
		else
			local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(member.resid * 100 + member.lvl.lovelevel + 1), 'love_max');
			local beforeLoveValue = member.lovevalue;
			local curLovevalue = (self.lovevalue + member.lovevalue) >= totalLovevalue and totalLovevalue or (self.lovevalue + member.lovevalue);
			rand = math.floor(curLovevalue / totalLovevalue * 16);

			if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and member.lvl.lovelevel < 4 then
				--爱恋满
				return true
			end
		end
	else
		if self.mFightType and self.mFightType == FightType.limitround then         --  如果是属性试炼
			team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
		end
		if self.mFightType and self.mFightType == FightType.invasion then
			local teamId = MutipleTeam:getDefault()
			team = MutipleTeam:getTeam(teamId)
		end

		for i=5, 1,-1 do
			if team[i] >= 0 then
				local partner = ActorManager:GetRole(team[i])
				if partner.lvl.lovelevel == 4 then
				else
					local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(partner.resid * 100 + partner.lvl.lovelevel + 1), 'love_max');
					local beforeLoveValue = partner.lovevalue;
					local curLovevalue = (self.lovevalue + partner.lovevalue) >= totalLovevalue and totalLovevalue or (self.lovevalue + partner.lovevalue);
					if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and partner.lvl.lovelevel < 4 then
						--爱恋满
						return true
					end
				end
			end
		end
	end
	return false
end
--战斗结束
function FightManager:OnFightOver()

	timerManager:DestroyTimer(self.fightOverTimer);						--清除计时器
	self.fightOverTimer = 0;

	--播放音效
	SoundManager:StopFightSound();						--停止战斗时的音效
	if Victory.left == self.result then
		--if self.lovevalue and self:isMaxLove() then
		--SoundManager:PlayEffect( 'v1100' )
		--else
		fightEndEffectSound = SoundManager:PlayEffect('win');
		--end

	else
		if self.mFightType ~= FightType.worldBoss then
			fightEndEffectSound = SoundManager:PlayEffect('lose');
		end
	end

	EventManager:FireEvent(EventType.FightOver, self:GetFightResultData());
	Rune:ClearEnemyAttribute();
end

--自动按钮点击事件响应函数
function FightManager:OnAutoClick()
	if (FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0) or (FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_11);
		return;
	end
	if ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 and FightManager.barrierId == 1003 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_11);
		return;
	end
	if ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 and FightManager.barrierId == 1004 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_11);
		return;
	end 
	if Hero:GetLevel() < FunctionOpenLevel.autoFight then
		Toast:MakeToast(Toast.TimeLength_Long, FunctionOpenLevel.autoFight .. LANG_fightManager_10);
		return;
	end

	if self.isAuto then
		self.isAuto = false;
		self.autoButton.Visibility = Visibility.Visible;
		self.cancelAutoButton.Visibility = Visibility.Hidden;
		--self.autoButton.Text = LANG_fightManager_7;

		for index = 1, 6 do
			FightUIManager:UpdateHeadUI(index, false);
		end
	else
		self.isAuto = true;
		self.autoButton.Visibility = Visibility.Hidden;
		self.cancelAutoButton.Visibility = Visibility.Visible;
		--self.autoButton.Text = LANG_fightManager_8;

		FightUIManager:DestroyAllSkillEffect();
	end

	--触发自动战斗改变事件
	EventManager:FireEvent(EventType.AutoFightChange);
end

--游戏设置点击时间相应函数
function FightManager:OnFightConfigClick()
	--引导点击暂停按钮无效
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		return;
	end 
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		return;
	end
	if FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		return;
	end
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 then
		return;
	end
	if FightType.noviceBattle == self.mFightType or not self.enablePause then
		--  如果是旷世大战则点击暂停按钮不执行任何操作
	else
		SceneRenderStep:Pause();
		self:PauseAction();
		self:PauseEffectScript();
		FightUIManager:pauseTime();
		FightConfigPanel:Show()
	end
end

--游戏战斗内暂停
function FightManager:FightPauseGame()
	SceneRenderStep:Pause();
	FightManager:PauseAction();
	FightManager:PauseEffectScript();
	FightUIManager:pauseTime();
end

--游戏战斗内取消暂停
function FightManager:FightContinueGame()
	SceneRenderStep:Continue();
	FightManager:ResumeAction();
	FightManager:ResumeEffectScript();
	FightUIManager:resumeTime();
end
--加速按钮响应事件
function FightManager:OnAddSpeed()
	--[[
	if ActorManager.user_data.role.lvl.level < 25 then 
		Toast:MakeToast(Toast.TimeLength_Long, LANG_FightManager_new_1);
		return
	end
	]]
	if self.timeScaleLevel == 2 then
		self.timeScaleLevel = 1;
		FightUIManager:isAddSpeed(false)
	else
		self.timeScaleLevel = 2;
		FightUIManager:isAddSpeed(true)
	end

	appFramework.TimeScale = Configuration.FightTimeScaleList[self.timeScaleLevel];
end
--[[
--加速按钮响应事件
function FightManager:OnAddSpeed()
	if ActorManager.user_data.role.lvl.level < Configuration.OneLevelAddSpeedOpenLevel and ActorManager.user_data.viplevel < Configuration.TwoLevelAddSpeedVipOpenLevel then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_fightManager_9);
		return;
	end

	if self.timeScaleLevel == 2 then
		self.timeScaleLevel = 1;
	else
		self.timeScaleLevel = 2;
	end

	appFramework.TimeScale = Configuration.FightTimeScaleList[self.timeScaleLevel];
	if (self.timeScaleLevel == 1) then				--当前正常速度
		self.addSpeedButton.NormalBrush = self.Speed1Brush;
		self.addSpeedButton.CoverBrush = self.Speed1Brush;
		self.addSpeedButton.PressBrush = self.Speed1PressBrush;

	elseif (self.timeScaleLevel == 2) then		--当前二等加速
		self.addSpeedButton.NormalBrush = self.Speed2Brush;
		self.addSpeedButton.CoverBrush = self.Speed2Brush;
		self.addSpeedButton.PressBrush = self.Speed2PressBrush;

	end
end
]]
--第一场战斗结束
function FightManager:OnFirstFightOver()
	self.isAuto = false;									--重置自动战斗状态
	self:ResetResultData();
	self:Destroy();
	timerManager:DestroyTimer(self.fightOverTimer);			--清除计时器
	self.fightOverTimer = 0;
	SoundManager:StopFightSound();
end

function FightManager:OnStartInput()
	self:Pause(true)
end


--获取游戏战斗进度
function FightManager:getFightProgress()
	--获取怪物死亡数
	local sumKilled = 0;
	for _,v in pairs(self.killedList) do
		sumKilled = sumKilled + v;
	end

	--获取怪物总数
	local monsterList = self:GetMonsterList(self.barrierId);
	local sum = #monsterList[1] + #monsterList[2]

	return sumKilled , sum;
end


--获得左侧所有英雄的总怒气值
function FightManager:getTotalAnger()
	return self.leftTotalAnger;
end

--获得右侧侧所有英雄的总怒气值
function FightManager:getTotalEnemyAnger()
	return self.rightTotalAnger;
end

--获得左侧怒气满的次数
function FightManager:getAngerMaxTimes()
	return self.leftAngerMaxTimes;
end

--增加左侧怒气
function FightManager:AddTotalAnger(value)
	self.leftTotalAnger = self.leftTotalAnger + value;
	if self.leftTotalAnger < 0 then
		self.leftTotalAnger = 0;
	end
	-- if self.mFightType == FightType.noviceBattle and not self.isangerMaxTrigger and FightUIManager.isTraggerLastSkill then --  旷世大战加满怒气后则把之前的怒气清0
	--    self.leftTotalAnger = 100
	--    self.isangerMaxTrigger = true
	-- end

	if self.leftTotalAnger >= Configuration.maxTotalAnger then
		self.leftAngerMaxTimes = self.leftAngerMaxTimes + 1;
		EventManager:FireEvent(EventType.AngerMax);
	end

	local count = Configuration.maxCardCountOnce;
	while self.leftTotalAnger >= Configuration.maxTotalAnger and count > 0 do
		count = count - 1;    --获得一次怒气，最多能兑换maxCardCountOnce张卡牌，避免在这里循环次数过多造成卡顿

		--播放声效
		SoundManager:PlayEffect('angerFull');
		--播放动画

		AvatarManager:LoadFile(GlobalData.EffectPath .. 'angerball_output/');
		local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
		FightUIManager.angerBar:AddChild(armatureUI);
		armatureUI:LoadArmature('angerball');
		armatureUI:SetAnimation('play');
		armatureUI:SetScale(2, 2);
		armatureUI.Translate = Vector2(FightUIManager.angerBar.Size.width/2+ 10, FightUIManager.angerBar.Size.height/2-13);
		armatureUI.Pick = false;

		self.leftTotalAnger = self.leftTotalAnger - Configuration.maxTotalAnger;

		--false：己方抽卡
		local skillInfo = FightHandSkillManager:GetRandomSkill();
		if skillInfo then
			print("ok: card" .. skillInfo.actor.id);
			--抽卡
			FightSkillCardManager:AddCard(skillInfo);
		end
	end
end

--增加右侧怒气
function FightManager:AddTotalEnemyAnger(value)
	self.rightTotalAnger = self.rightTotalAnger + value;
	if self.rightTotalAnger < 0 then
		self.rightTotalAnger = 0;
	end
	while self.rightTotalAnger >= Configuration.maxTotalAnger do
		self.rightTotalAnger = self.rightTotalAnger - Configuration.maxTotalAnger;

		--true：isEnemy敌方抽卡
		local skillInfo = FightHandSkillManager:GetRandomEnemySkill();
		if skillInfo then
			--敌方抽卡
			FightSkillCardManager:AddEnemyCard(skillInfo);
		end
	end
end

function FightManager:GetTagFighter()
	return self.tagFighter;
end

--手动增加标记
function FightManager:AddTag(x, y)
	if (self.tagFighter ~= nil and self.tagFighter:GetFighterState() ~= FighterState.death) then
		self.tagFighter:DetachEffect(self.tag);
	end
	local clickPos = Vector2(math.floor(x), math.floor(y));

	if FightType.noviceBattle == self.mFightType then     --  是否是旷世大战
		--  是否选中的后排敌人
		local len = #self.rightActorList   --  敌人长度
		local fighter = self.rightActorList[len]
		for i,v in pairs(self.rightActorList) do
			if v:GetResID() == 8004 and v:GetFighterState() ~= FighterState.death then
				fighter = v
			end
		end
		if fighter then
			if (self.tagFighter == nil or self.tagFighter:GetFighterState() ~= FighterState.death) and fighter:Hit(clickPos) then
				self.tagFighter = fighter;
			end
		end
		if (self.tagFighter ~= nil and self.tagFighter:GetFighterState() ~= FighterState.death) and isCanTagEnemy then
			local tag = sceneManager:CreateSceneNode('Armature');
			tag:LoadArmature('xuanzhong');
			tag.Scale = Vector3(0.4,0.4,1)
			tag:SetAnimation('play');
			self.tagFighter:AttachEffect('root', tag);
			self.tag = tag;
			--  旷世大战中，选中敌人后将特效和提示移除
			FightSkillCardManager:destroyGuideArmature()
			isNoviceBattle = false
			fighter:RecoverZOrder()
			self.isSelectEnemy = false
			PlotPanel:changeContentPos(100,0)
			PlotPanel:changeContentText( LANG_GUIDE_CONTENT_1 )
			local handSkill = FightSkillCardManager:getHandSkillList()
			if handSkill[1] then
				-- handSkill[1].main.Opacity = 0
				--  播放引导特效
				--  这里用常数640，而用appFramework.ScreenHeight不正确，是因为这个特性是添加在topDesktop上 ，而topdesktop的大小是调用了SetDesktopSize(topDesktop)方法
				FightSkillCardManager:displayGuideEffect( handSkill[1].Translate.x + 70, handSkill[1].Translate.y + 640 - 120, false)
				self.canClickCard = true    --  技能卡能点击
				FightSkillCardManager:setCardEnabled(  )   --  卡牌可点击
			end
			isCanTagEnemy = false
		end
	else
		--普通副本第二关战斗
		if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
			self:selectOneEnemy( 3007, clickPos )
			return;
		end
		if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
			self:selectOneEnemy( 3009, clickPos )
			return;
		end
		function checkFighter(fighter)
			if fighter:Hit(clickPos) then
				if (self.tagFighter == nil or self.tagFighter:GetFighterState() ~= FighterState.death) then
					self.tagFighter = fighter;
				else
					if self.tagFighter and self.tagFighter:GetFighterState() ~= FighterState.death and self.tagFighter.picDis and self.tagFighter.pickDis > fighter.pickDis then
						self.tagFighter = fighter;
					end
				end
			end
		end

		for _, fighter in pairs(self.leftActorList) do
			checkFighter(fighter)
		end

		for _, fighter in pairs(self.rightActorList) do
			checkFighter(fighter)
		end

		if (self.tagFighter ~= nil and self.tagFighter:GetFighterState() ~= FighterState.death) then
			local tag = sceneManager:CreateSceneNode('Armature');
			tag:LoadArmature('xuanzhong');
			tag.Scale = Vector3(0.4,0.4,1)
			tag:SetAnimation('play');
			self.tagFighter:AttachEffect('root', tag);
			self.tag = tag;
		end
	end
end

function FightManager:selectOneEnemy( enemyID, clickPos )
	--  是否选中的后排敌人
	local len = #self.rightActorList   --  敌人长度
	local fighter = self.rightActorList[len]
	for i,v in pairs(self.rightActorList) do
		if v:GetResID() == enemyID and v:GetFighterState() ~= FighterState.death then
			fighter = v
		end
	end
	if fighter then
		if (self.tagFighter == nil or self.tagFighter:GetFighterState() ~= FighterState.death) and fighter:Hit(clickPos) then
			self.tagFighter = fighter;
		end
	end
	if (self.tagFighter ~= nil and self.tagFighter:GetFighterState() ~= FighterState.death) and isCanTagEnemy then
		local tag = sceneManager:CreateSceneNode('Armature');
		tag:LoadArmature('xuanzhong');
		tag.Scale = Vector3(0.4,0.4,1)
		tag:SetAnimation('play');
		self.tagFighter:AttachEffect('root', tag);
		self.tag = tag;
		--  旷世大战中，选中敌人后将特效和提示移除
		FightSkillCardManager:destroyGuideArmature()
		fighter:RecoverZOrder()
		if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
			if FightHandSkillManager.isSecondCard then
				local handSkill = FightSkillCardManager:getHandSkillList();
				local count = 1;
				for i=1,#handSkill do
					if handSkill[i].skill_resid == 302 then
						count = i;
					end
				end
				FightSkillCardManager:setIndexCardEnabled(count);
				FightSkillCardManager:guideCradClick(count, LANG_GUIDE_CONTENT_5);
				FightSkillCardManager.guideCardClick = true;
			end
		elseif FightHandSkillManager.isFirstCard then
			local handSkill = FightSkillCardManager:getHandSkillList();
			local count = 1;
			for i=1,#handSkill do
				if handSkill[i].skill_resid == 232 then
					count = i;
				end
			end
			FightSkillCardManager:setIndexCardEnabled(count);
			FightSkillCardManager:guideCradClick(count, LANG_GUIDE_CONTENT_5);
			FightSkillCardManager.guideCardClick = true;
		end
	end
end
function FightManager:isEnemyInScreen(enemyID)
	local len = #self.rightActorList             --  敌人长度
	local fighter = nil    --  将最后一个敌人放到屏蔽层前面

	for i,v in pairs(self.rightActorList) do
		if tonumber(v:GetResID()) == enemyID and v:GetFighterState() ~= FighterState.death then
			fighter = v;
			break;
		end
	end

	--怪距离屏幕边缘偏移量
	local distance;
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		distance = 180;
	elseif FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		distance = 80;
	elseif FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 then
		distance = 180;
	else
		distance = 80;
	end
	if fighter and fighter:isInScreenWithMargin(distance) then
		return true;
	else
		return false;
	end
end

function FightManager:playSelectArmature(enemyID, content)
	isNoviceBattle = true

	self.isTriggerSelect = true;
	FightManager:Pause();
	FightShowSkillManager:AddShader();

	local len = #self.rightActorList             --  敌人长度
	local fighter = self.rightActorList[len]    --  将最后一个敌人放到屏蔽层前面

	for i,v in pairs(self.rightActorList) do
		if v:GetResID() == enemyID and v:GetFighterState() ~= FighterState.death then
			fighter = v
		end
	end
	fighter:BringToFront()
	self.canClickCard = false    --  技能卡不能点击
	--  坐标转换
	local pos = SceneToUiPT(self.camera, FightManager.desktop.Camera, fighter:GetPosition())
	PlotPanel:changeContentPos(0, -30)--( pos.x - 500, pos.y - 700 )    --  content的坐标是74,349,宽350,搞110
	PlotPanel:showContent();
	PlotPanel:changeContentText(content);
	--  播放引导特效
	self.isSelectEnemy = true
	FightSkillCardManager:displayGuideEffect( pos.x + 25 , pos.y - 110, true)
	isCanTagEnemy = true
end

--死亡删除标记
function FightManager:DeleteTag(fighter)
	if fighter == self.tagFighter then
		self.tagFighter:DetachEffect(self.tag);
		self.tagFighter = nil;
	end
end

--获取友方角色列表
function FightManager:getFriendList()
	return self.leftActorList;
end

--获取敌方角色列表
function FightManager:getEnemyList()
	return self.rightActorList;
end

--检测敌方角色列表是否为空
function FightManager:isEnemyListEmpty()
	return self.rightActorList == {};
end

--让list中的所有人开始施放光环.
function FightManager:CastHaloFromList(list)
	if not list then
		return;
	end

	__.each(list, function(actor)
		actor:castHalo();
	end)
end
