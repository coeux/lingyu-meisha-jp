
--========================================================================
--策划配置文件

Configuration = 
	{
		--策划可调参数
		GoodsStayTime			= 2;					--物品掉落后保持原地不动的时间
		PickUpXSpeed			= -700;					--物品飞到头像的x轴速度(负数)
		PickUpXAddSpeed			= 500;					--物品飞到头像的x轴加速度
		GoodsStayScale			= Vector2(0.8, 0.8);	--物品出现时的大小比例
		GoodsFinalScale			= 0.4;					--物品最终大小
		GoodsFinalYPosition 	= 150;					--物品掉落地点距离屏幕底端的距离(处于头像上方)
		FirstEnterFightStayTime = 0.4;					--入场时人物停留时间（攻击时间 - 该时间）
		AlertDistance			= 250;					--小怪站桩的警戒距离
		minMonsterWakeUpTime		= 0.2;				--小怪觉醒的最小时间间隔
		maxMonsterWakeUpTime		= 0.6;				--小怪觉醒的最大时间间隔
		
		YOrderList = {-100, -120, -140};				--战斗场景三条战线y轴坐标（中，上，下）
		XPositionIndentation = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};	--角色在战斗场景中X轴方向的位移差
		FirstPartnerEnterBattleTime = 1;				--第一个人物入场时间点
		PartnerEnterSpacingTime = 2;					--友方角色入场时间间隔
		
		StayRedTime = 0.25;								--被击变红的持续颜色
		
		EffectFlyYSpeed				= 300;				--特效飞行的Y轴初速度
		
		--数值系统	
		MaxAnger					= 1000;				--最大怒气值
		StormsHitMultiple			= 1.5;				--暴击倍数
		KnightDamagePercent			= 0.8;				--骑士实际收到伤害比例
		MinDamageDataPercent		= 0.95;				--最低伤害比例
		MaxDamageDataPercent		= 1.00;				--最高伤害比例
		
		FightTeleportLeftPos = {x=-473, y=-120};		--战斗界面左边传送点位置
		FightTeleportRightPos = {x=473, y=-120};		--战斗界面右边传送点位置
	};
