
--========================================================================
--策划配置文件

Configuration =
	{
		--策划可调参数
		FirstEnterFightStayTime		= 0.3;					--入场时人物停留时间（攻击时间 - 该时间）
		AlertDistance				= 250;					--小怪站桩的警戒距离
		minMonsterWakeUpTime		= 0.2;					--小怪觉醒的最小时间间隔
		maxMonsterWakeUpTime		= 0.6;					--小怪觉醒的最大时间间隔

		YOrderList = {-60, -89, -118};					--战斗场景三条战线y轴坐标（中，上，下）
		FirstPartnerEnterBattleTime = 1;					--第一个人物入场时间点
	
		PartnerEnterSpacingTime 	= 1.3;					--友方角色入场时间间隔
		SuperFightPartnerEnterSpacingTime 	= {7,7,1.5,1.5, 0};	--友方角色入场时间间隔

		--战斗站位
		BattleEnterLine 												= {2, 4};
		YOrderList                        = {-44, -68, -92, -116, -130}; --出场线 // monster捣乱
		BattleYPositionLine 							= {2, 4, 3, 5, 1};
		YOrderAllPosition 								= {-68, -116, -92, -150, -44}; -- Y方向的5个站立区域
		StandAreaCount 										= 4; 											 -- 站立区数量
		StandAreaAdjust  = {{{0, 0}, {0, -10}, {-10, 0}, {-10, -10}}, {{0, 0}, {0, -10}, {10, 0}, {10, 10}}};-- 站立区调整{left, right}


		--数值系统
		NormalRoundBeginID 			= 1000;      		 --普通关卡起始ID
		NormalRoundEndID   			= 2000;      		 --普通关卡结束ID
		ZodiacRoundBeginID 			= 3000;       		--十二宫关卡起始ID
		MaxAnger					= 1000;				--最大怒气值
		StormsHitMultiple			= 1.5;				--暴击倍数
		KnightDamagePercent			= 0.8;				--骑士实际收到伤害比例
		MinDamageDataPercent		= 95;				--最低伤害比例(百分比)
		MaxDamageDataPercent		= 105;				--最高伤害比例(百分比)		

		FightTeleportPveLeftPos = {x=-400, y=-120};		--pve战斗界面左边传送点位置
		FightTeleportPvpLeftPos = {x=-473, y=-120};		--pvp战斗界面左边传送点位置
		FightTeleportRightPos = {x=473, y=-120};		--战斗界面右边传送点位置		
		
		--============================================================================
		--十二宫
		BaseZodiaSignID				= 300;				--十二宫基础id
		ZodiaBossNeedPower			= 5;				--十二宫boss关需要的体力
		MaxOpenZodiacID 			= 308;				--十二宫最大开启宫殿id
		
		--============================================================================
		--杀星
		InvasionStartID				= 201;				--杀星起始关卡id
		InvasionEndID				= 208;				--杀星结束关卡id
		
		--============================================================================
		--巨龙宝库
		TreasureBaseRoundID			= 4000;				--巨龙宝库的基础id
		
		BossInitXPosition			= 100;				--世界boss初始X轴位置
		MakeFrenzyCount				= 9;				--boss进入狂暴状态的攻击次数
		--=============================================================================
		ShowSkillActorIdleTime		= 0.4;				--技能展示时角色待机时间长度
		ShowSkillSpaceTime			= 0.5;				--技能展示的间隔时间
		ShowSkillShaderTime			= 1;				--技能展示时遮罩时间长度
	};

