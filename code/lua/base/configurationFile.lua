--configurationFile.lua

--========================================================================
--策划配置文件

Configuration =
	{
		--策划可调参数

    --totalAngerForMaxHP                = 1;                     --所有人满血一共多少怒气(用来按百分比计算每次击打获得的怒气)
      fightShade = false;                   -- 战斗中是否蒙灰
    roleTotalPower                    = 80;                     -- 英雄默认能提供多少怒气
    maxHandSkillResetCount            = 5;                       -- 抽卡多少轮后卡包重置
    maxTotalAnger                     = 100;                     -- 最大怒气值（达到会获得一张卡）
    combo4EachSkill					  = 10;						--每个技能的最大combo数量
    distributeCardTime       = 7;					--七秒钟自动发一张卡牌
    distributeCardTimeInRankFight       = 6;					--6秒钟自动发一张卡牌(排位战)
    maxCardCountOnce         = 8;                                       --获得一次怒气，最多能兑换的卡牌数
		GoodsFallMaxCount                 = 2;                       -- 每个怪物掉落物品的最大值
		GoodsStayTime                     = 1;                       -- 物品掉落后保持原地不动的时间
		PickUpXSpeed                      = -700;                    -- 物品飞到头像的x轴速度(负数)
		PickUpXAddSpeed                   = 500;                     -- 物品飞到头像的x轴加速度
		GoodsStayScale                    = Vector2(0.5, 0.5);       -- 物品出现时的大小比例
		GoodsFinalScale                   = 0.4;                     -- 物品最终大小
		GoodsFinalYPosition               = 150;                     -- 物品掉落地点距离屏幕底端的距离(处于头像上方)
		SkillFinalYPosition               = 150;                     -- 技能图标滚动的最低Y轴
		ActorMaxSkillCount                = 3;                       -- 角色最大技能icon数
		FirstEnterFightStayTime           = 0.3;                     -- 入场时人物停留时间（攻击时间 - 该时间）
		AlertDistance                     = 250;                     -- 小怪站桩的警戒距离
		minMonsterWakeUpTime              = 0.2;                     -- 小怪觉醒的最小时间间隔
		maxMonsterWakeUpTime              = 0.6;                     -- 小怪觉醒的最大时间间隔
		TwoLevelAddSpeedVipOpenLevel      = 3;                       -- 二等加速开放等级
		OneLevelAddSpeedOpenLevel         = 40;                      -- 一等加速开放等级
		FightTimeScaleList                = {1, 1.5};              -- 战斗加速倍数
		CameraMoveSpeed                   = 150;                     -- 相机的初始移动速度

		--YOrderList                        = {-60, -89, -118};      -- 战斗场景三条战线y轴坐标（上，中，下）
		-- battle scence split (base = 20)
		-- 7:10:7 = 140 : 200 : 140  = {(240)->(140) : (140)->(-140) : (-140)->(-240)}
		-- 战斗区 = 人物(80) + 站立区(120) = 200
		-- 																					屏幕
		--        ==========================================================================================
		--        (+240)
		--
		--        (   0)
		--        ( -20)
		--        ------------------------------------------------------------------------------------------
		--        (....)
		--    [1] ( -20)
		-- 站 [2] ( -45) in
		-- 立 [3] ( -70)
		-- 区 [4] (-95) in
		--    [5] (-120)
		--        ------------------------------------------------------------------------------------------
		--        (....)
		-- 卡     (-168)
		-- 片     (-192)
		-- 区     (-216)
		--        (-240)
		--        ==========================================================================================
    --        临时修改调整为如下宽度，fightScale = 0.9时适用
		BattleEnterLine     = {2, 4};
		--XInterval         = 50;
		--YInterval         = 0;
		YOrderList          = {-5, -45, -85, -125, -165}; --出场线 // monster捣乱
		BattleYPositionLine = {2, 4, 3, 5, 1};
		YOrderAllPosition   = {-45, -125, -85, -165, -5}; -- Y方向的5个站立区域
		--    +-----------+
		-- 站 |  D  |  A  |
		-- 立 ------+-----+
		-- 范 |  C  |  B  |
		-- 围 +-----------+
		-- 默认站在[A]位置
		StandAreaCount      = 4; 											 -- 站立区数量
		StandAreaAdjust     = { {{0, 0}, {0, -10}, {-10, 0}, {-10, -10}}, {{0, 0}, {0, -10}, {10, 0}, {10, 10}}};-- 站立区调整{left, right}
		StandAreaInterval   = 10;  -- 站立区最小间隔
		MaxIntervalArea     = 20; --目标选取的前后间隔的最大范围 最大值可为前排攻击范围
		OffsetAngle 	    = 85; -- (-90,90) 双开区间（角度）正负数偏移方向, 尽量选择大角度
		-- 补偿长度最大不可超过近战攻击距离，否则会发生跑动现象
		-- 测试时请使用5个前排敌人，和我方任意多个前排测试。
		-- 若要查看效果可使用5个后排敌人，调相应角度查看参考效果，实际效果请以5个前排的效果为准。
		--        /|
		--       / |
		--      /  |
		--     /   |
		--    /a   |
		--   -------
		--   | 补偿|
		--   !!!!!!!!! 注意
		--   这个是配置文件中的说明；这个<补偿>距离不可超过现在前排攻击距离，也就是说"15单位"，
		--   以此推算，tan(a) = (最上排y-最下排y) / 补偿 = (-5 - (-165)) / 15  = 32/3 约 10.67,
		--   tan(rad(85)) = 11.43, tan(rad(84)) = 9.51
		--   即 按照目前普攻攻击范围可填写角度为(-90, -85] U [85, 90) 超过本范围会照成跑动或者其他奇怪现象。
		--   !!!!!!!!!!
		EffectZorder        = -101; -- 特效层级zorder

		FirstPartnerEnterBattleTime       = 0.2;                     -- 第一个人物入场时间点

		-- 战斗相关
		SuppressLevel = 3; 		-- 最低等级差, 大于该数值出现等级压制
		ChaosAndAttackAllyProbability = 1; -- 混乱条件下攻击友军的概率

		PartnerEnterSpacingTime           = 0.2;                     -- 友方角色入场时间间隔
		-- [1]指第一个人入场后，第二个人进入场景的时间间隔,以此类推
		SuperFightPartnerEnterSpacingTime = {4,360,1,1,0};           -- 友方角色入场时间间隔

		StayRedTime                       = 0.25;                    -- 被击变红的持续颜色
		HitColor                          = Color(175, 55, 55, 255); -- 被击变红颜色

		QTEMinPercent                     = 0.1;                     -- QTE触发的最小血量百分比
		QTEMaxPercent                     = 0.35;                    -- QTE触发的最大血量百分比
		QTETeachRoundID                   = 1005;                    -- QTE教学关卡
		MaxGesturePower                   = 12;                      -- 手势技能最大能量数
		GestureSkillDisappearTime         = 0.5;                     -- 手势技能消失时间
		GestureSkillDisappearSpeed        = 300;                     -- 手势技能消失速度

		GestureSkillInitPower             = 0;                       -- 手势技能初始化能量点
		GesturePowerTipLastTime           = 1.2;                     -- 手势能量提示持续时间
		GesturePowerRecoverSpaceTime      = 2.5;                     -- 手势能量恢复时间间隔
		GestureSkillGouGuidRound          = 1004;                    -- 打钩技能的最大引导关卡

		HpProgressSpeed					  = 0.01;						 -- 血条下降上升速度

		ShadowSize                        = { Rect(0, 0, 78 ,25), Rect(0, 0, 120, 24), Rect(0, 0, 298, 48) };		--阴影图片大小

		GuidePointDelay					 = 30;				--延迟触发事件的延迟帧数


		--==========================================================================================
		--远征
		EXPEDITION_MAX_ROUND		= 15;					--远征最大关数

		--==========================================================================================
		--战斗相关参数
		FIGHT_BASE_CRI				= 0.15;					--基础爆击率
		FIGHT_BASE_DEFCRI			= 0.15;					--基础防爆率
		FIGHT_BASE_ACC				= 0.92;					--基础命中率
		FIGHT_BASE_DOD				= 0.05;					--基础闪避率

		--==========================================================================================
		--vip
		MaxVipLevel					= 18;					--最大vip等级
		MaxTaskLevel				= 70;					--最大任务等级

		--==========================================================================================
		--任务
		MaxTaskID					= 1427;					--最大任务

		--==========================================================================================
		--背包
		MaxPackageCount				= 200;				--背包最大的个数
		MaxVipPackageCount			= 300;				--vip1以上背包最大的个数
		WarningPackageCount			= 3;				--背包满提醒数量

		--数值系统
		MaxAnger					= 1000;				--最大怒气值
		InitAnger					= 200;				--初始怒气
		StormsHitMultiple			= 2;				--暴击倍数
		ExtraAttackPercent = 0.25; 			--追击系数
		KnightDamagePercent			= 0.8;				--骑士实际收到伤害比例
		MinDamageDataPercent		= 95;				--最低伤害比例(百分比)
		MaxDamageDataPercent		= 105;				--最高伤害比例(百分比)

		AutoBattleTime				= 300;				--一次战斗的挂机时间(秒)
		AutoBattlePrice				= 50;				--自动战斗每小时单价数

		RecoverPowerTime			= 5;				--体力恢复时间间隔(分钟)
		MaxPower					= 120;				--最大体力值
		NormalRequestPower			= 6;				--普通关卡消耗的体力
		EliteRequestPower			= 10;				--精英关卡消耗的体力

		TaskMaxLevel				= 999;				--配置等级为该值的任务为最后一个任务，不显示

		-- 已废弃
		-- [[
		FightTeleportPveLeftPos = {x=100, y=-85};	--pve战斗界面左边传送点位置
		FightTeleportPvpLeftPos = {x=-473, y=-85};	--pvp战斗界面左边传送点位置
		FightTeleportRightPos = {x=200, y=-100};		--战斗界面右边传送点位置
		--]]
		FightTeleportPveLeftOffset = { x =  100, y = -85}; -- pve战斗界面左侧传送点偏移
		FightTeleportPvpLeftOffset = { x =  100, y = -85};  -- pvp战斗界面左侧传送点偏移
		FightTeleportRightOffset   = { x = -100, y = -85};  -- 战斗界面右侧传送点偏移

		--=============================================================================
		ShowSkillActorIdleTime		= 0.4;				--技能展示时角色待机时间长度
		ShowSkillSpaceTime			= 4.8;				--技能展示的间隔时间
		ShowSkillShaderTime			= 1;				--技能展示时遮罩时间长度

		--=============================================================================
		--走马灯
		PerInfomationUpdateTime		= 1;				--每条走马灯信息的更新时间
		PerRoundUpdateTime			= 5;				--每轮走马灯更新的时间

		--=============================================================================
		--好友助战

		ShowAssistFriendCount		= 3;				--显示助战好友个数
		FriendGetFriendShip			= 100;				--好友获得的友情点
		StrangerGetFriendShip		= 50;				--陌生人获得友情点

		--=============================================================================

		normalRefineID				= 15001;			--精灵的洗礼
		superRefineID				= 15002;			--女神的洗礼
		normalRefineBuyID			= 1113;				--精灵的洗礼购买id
		superRefineBuyID			= 1121;				--女神的洗礼购买id

		siverPackageID				= 20001;			--白银宝箱
		goldPackageID				= 20002;			--黄金宝箱

		goldPackageBuyID			= 1111;				--黄金宝箱购买ID
		siverPackageBuyID			= 1112;				--白银宝箱购买ID

		ChangeNameCardID			= 22001;			--改名卡

		--=============================================================================
		--宝石
		LevelFiveGemRmb				= 10;				--五级宝石价格
		ShelterSeal					= 15004;			--庇护之印
		ShelterSealBuyID			= 1122;				--庇护之印购买id
		DismantleStoneID			= 15003;			--拆卸钳ID

		--=============================================================================

		RoleMaxStarNum				= 5;				--角色最大星级数
		MaxEnergy				    = 20;				--最大活力值
		EquipAdvanceMaxLevel		= 110;				--装备升阶最大等级

		--============================================================================
		--聊天
		WorldChatLevel				= 1;				--世界聊天开启等级
		MaxTalker					= 5;				--同时聊天的最大人数；
		CharToChineseRatio			= 1.5;				--汉字对英文字符的转换比例
		ChatStrCount				= 45;				--聊天输入最大字符个数
		MainCityChatStrCount		= 35;				--主城界面最大显示个数
		WorldTalkColdTime			= 5;				--世界消息的冷却时间
		SystemUID					= -1;				--系统的uid
		MaxExpressionCount			= 21;				--最大表情个数

		--============================================================================
		--十二宫
		BaseZodiaSignID				= 300;				--十二宫基础id
		ZodiaBossNeedPower			= 5;				--十二宫boss关需要的体力
		MaxOpenZodiacID 			= 308;				--十二宫最大开启宫殿id

		--============================================================================
		--乱斗场
		ScuffleDisplayTime			= 1200;				--乱斗场开始后20分钟内显示图标
		ScuffleWaitTime				= 60;				--乱斗场开始后等待1分钟
		ScuffleBroadcastTime		= 300;				--乱斗场开始后5分钟内可以进入
		ScuffleSecondTime			= 3600 * 20;		--乱斗场第二次开始时间

		--============================================================================
		--巨龙宝库
		TreasureMaxFloorCount     = 100;   -- 巨龙宝库最大层数
		TreasureCaptureMaxTime    = 14400; -- 巨龙宝库每天最大占领时间
		TreasureRobMaxCount       = 5;    -- 巨龙宝库每天最大的抢劫次数
		TreasureRobedMaxCount     = 2;     -- 巨龙宝库玩家在同一个位置上最大被打劫次数
		TreasureRobSaveLevel      = 10;    -- 巨龙宝库的等级保护
		TreasureBeginTime    = 32400;     -- 巨龙宝库的起始时间
		TreasureEndTime      = 64800; -- 巨龙宝库的结束时间

		--============================================================================
		--新手战斗

		GuideFireLevel				= 3;				--怒气满提示箭头

		--============================================================================
		--世界boss
		BossInitXPosition          = 200;   -- 世界boss初始X轴位置
		UpdateDamageRankSpaceTime  = 5;     -- 刷新伤害排名的间隔时间
		UpdateScuffleRankSpaceTime = 5;     -- 刷新乱斗场排名的间隔时间
		ReviveTime                 = 43;    -- 复活时间
		BossKilledCode             = 1400;  -- boss已经被击杀的错误码
		BossFightCDCode            = 515;   -- boss战斗cd时间未到的错误码
		FightNowCostRmb            = 10;    -- boss立即再战的水晶
		BossFightNoticeAdvanceTime = 290;   -- boss战斗提醒的提前时间
		MakeFrenzyCount            = 9;     -- boss进入狂暴状态的攻击次数
		BossFrencyTipLastTime      = 3;     -- boss狂暴提示的持续时间
		CrystalInspireValue        = 50;    -- 水晶鼓舞的水晶
		CoinInspireValue           = 30000; -- 金币鼓舞的事件
    CoinInspireSpaceTime       = 120;   -- 金币鼓舞cd时间
		WorldBossResID 						 = 99999; -- 世界BOSSID
		UnionBossResID						 = 99998; -- 公会BossID
		--============================================================================
		--公会boss
		UnionBossStartTime			= 75600;			--公会boss开始的时间
		BossFightNowVipLevel		= 3;				--公会和世界boss的立即再战功能的开启等级
		UnionBossOpenLevel			= 3;				--公会boss开启的公会等级
        UnionBossRefreshWeekDay     = 6;                --公会boss刷新星期

		--============================================================================
		--训练
		TrainColdTime				= 28800;			--训练的冷却时间
		TrainPosOpenLevel			= {20,40,3}; 		--训练位置开启等级
		--============================================================================
		--公会
		CreateDiamond					= 500;			--创建公会需要的钻石
		CreateUnionLevel			= 1;				--创建公会的最低等级
		AlertDonate					= 100;				--祭祀消耗的贡献值
		StartUpdateTime				= 0.005;			--祭祀旋转开始的时间间隔
		EndUpdateTime				= 0.3;				--祭祀旋转结束的时间间隔
		UnionMaxLevel				= 10;				--公会最大等级
		StatueNPCID					= 904;				--公会雕像npcID

		NoticeStrCount				= 100;				--公会公告最大字符个数
		UnionNameStrCount			= 5;				--公会名称最大字符个数
		HeroNameStrCount			= 5;				--主角名字最大字符个数
		EmailContentStrCount		= 480;				--邮箱反馈最大字符个数
		InviteCodeCount				= 9;				--邀请码最大字符个数

		RedEnvelopesResID			= 905;				--红包资源ID

		--========================================================================
		--英雄迷窟

		MikuChangeMaxCount			= 5;				--迷窟可以挑战的最大次数

		--========================================================================
		--训练
		KingTrainRmb				= 2000;				--王者训练花费的水晶
		PerClearCDRmb				= 5;				--清除训练cd的水晶

		--========================================================================
		--抽翅膀需要的水晶数
		ExtractWingRmb				= 120;				--抽一次翅膀积分需要的水晶

		--========================================================================
		--商城
		MaxNumberOfOnePurchase		= 99;				--一次购买的最大数量

		--========================================================================
		--战斗结算
		TimeForExpEffect			= 1.2;				--经验条动画持续时间 单位秒,为0.1的倍数

		--========================================================================
		--卡牌活动
		CardEventMinOpenLv			= 1;				--card event 中默认开启的难度
		CardEventLvNum				= 5;				--卡牌活动总难度个数
		CardEventStageNum			= 3;				--卡牌活动关卡个数

		--========================================================================

		--========================================================================
		--卡牌评价
		--字数要求12~100
		commentMinWords				= 18;				--评论的最少字符数
		commentMaxWords				= 150;				--评论的最多字符数
		commentNewestCacheLen		= 50;				--最新评论数据最大缓存
		commentHotestCacheLen		= 10;				--最热评论数据最大缓存
		reqNewestCommentInterval 	= 300; 				--最新评论更新时间间隔
		reqHotestCommentInterval 	= 300;				--最热评论更新时间间隔

		--========================================================================

		--游戏逻辑配置

		SaleRate					= 0.8;				--物品卖出折扣

		--颜色
		VipColor    = QuadColor(Color(253, 255, 76, 255), Color(255, 177, 0, 255), Color(253, 255, 76, 255), Color(255, 177, 0, 255));
		RedColor    = QuadColor(Color.Red);						--红色
		GreenColor  = QuadColor(Color(146, 227, 0, 255));		--绿色
		WhiteColor  = QuadColor(Color.White);					--白色
		BlackColor  = QuadColor(Color(38, 19, 0, 255));
		DarkSalmon  = QuadColor(Color(233, 150, 122, 255));
		GrayColor   = QuadColor(Color(128, 128, 128, 255));	--灰色
		YellowColor = QuadColor(Color(254, 231, 0, 255));		--黄色
		BlueColor   = QuadColor(Color(87, 213, 255, 255));		--蓝色
		PurpleColor = QuadColor(Color(223, 107, 255, 255));	--紫色
		DarkBlue = QuadColor(Color(10, 45, 99, 255));	--深蓝色
		MainColor   = QuadColor(Color(255,153,0,255), Color(255,255,255,255), Color(255,153,0,255), Color(255,255,255,255)); --主线
		BLineColor  = QuadColor(Color(255,255,255,255), Color(128,128,128,255), Color(192,192,192,255), Color(128,128,128,255));
		PinkColor 	= QuadColor(Color(248, 116, 116, 255));	--紫色

		--========================================================================
		--战斗场景文件位置
		arenaScene			= 'resource/scene/shatan/st_1_1.sce';			--竞技场场景
		scuffleScene		= 'resource/scene/shatan/st_1_1.sce';			--乱斗场场景
		trialScene			= 'resource/scene/xuexiao/xx_zl_1.sce';			--试炼场景
		treasureScene		= 'resource/scene/xueshan/xs_bd_1.sce';			--探宝场景
		worldBossScene		= 'resource/scene/xueshan/xs_sd_1.sce';			--世界boss场景
		unionBossScene		= 'resource/scene/shatan/st_2_1.sce';			--公会boss场景
		grabScene			= 'resource/scene/xueshan/xs_bd_1.sce'; 		--探宝抢劫场景

		--========================================================================
		--配置

		sanren_chouka_vip_level = 9;							--三刃抽卡需要的vip等级
		equip_max_level         = 14;                     --装备的最高等级

		-- 施法疲劳
		cast_max_time			= 3;
		cast_coefficient		= 0.7;

	};


--是否可以镶嵌
function Configuration:canEmbed( roleLevel, pos )

	if pos == 1 then
		return roleLevel >= 1;
	elseif pos == 2 then
		return roleLevel >= 20;
	elseif pos == 3 then
		return roleLevel >= 30;
	end

	return false;

end

--主角等级变稀有度
function Configuration:getRare( level )
	local rare = 1;
	if level >= 60 then
		rare = 5;
	elseif level >= 40 then
		rare = 4;
	elseif level >= 20 then
		rare = 3;
	elseif level >= 10 then
		rare = 2;
	end

	return rare;
end

--根据装备等级获得名字颜色
function Configuration:getNameColorByEquip(quality)
	local index = 1;
	if quality then
		if quality == 1 then
			index = 1;
		elseif quality >1 and quality <=3 then
			index = 2;
		elseif quality >= 4 and quality <= 6 then
			index = 3;
		elseif quality >= 7 and quality <= 9 then
			index = 4;
		elseif quality >= 10 and quality <= 13 then
			index = 5;
		elseif quality >= 14 and quality <= 17 then
			index = 6;
		end
	end
	return index;
end
