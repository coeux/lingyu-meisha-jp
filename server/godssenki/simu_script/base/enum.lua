
--========================================================================
--========================================================================
--枚举定义

--游戏状态类
GameState =
	{
		loginState		= 1;				--登陆状态
		runningState	= 2;				--运行状态
		loadingState	= 3;				--加载状态
	};

--骨骼动画步骤
SkeletonAnimationStep =
	{
		DurationTo		= 0,			--动画间过渡
		DurationDelay	= 1,			--动画延迟
		Duration		= 2,			--关键帧动画
	};

--性别
SexType =
	{
		boy			= 1;				--男
		girl		= 2;				--女
	};

--角色类型
ActorType = 
	{
		hero = 1;				--英雄
		partner = 2;			--伙伴
		monster = 3;			--小怪
		eliteMonster = 4;		--精英怪
		boss = 5;				--boss
	};

--职业
JobType =
	{
		knight		= 1;				--骑士
		warrior		= 2;				--战士
		hunter		= 3;				--猎人
		magician	= 4;				--法师
	};

--动作类型
AnimationType =
	{
		none		= 0;				--空
		idle		= 'idle';			--待机动作
		run			= 'run';			--跑动
		f_idle		= 'f_idle';			--战斗待机
		f_run		= 'f_run';			--战斗移动
		attack		= 'attack';			--攻击
		skill		= 'skill';			--技能攻击
		hit			= 'hit';			--受击
		death		= 'die';			--死亡
		win			= 'win';			--胜利
		await		= 'await';			--待机小动作
	};

--攻击状态
AttackType = 
	{
		normal		= 0;				--普通
		skill		= 1;				--技能
	};
	
--攻击状态
AttackState = 
	{
		normal = 0;			--普通	
		stormsHit = 1;		--暴击
		miss = 2;			--闪避
	};

--换装部位
AvatarPos =
	{
		root			= 'root';			--根节点
		head			= 'head';			--头
		body			= 'body';			--上身体
		right_arm		= 'right_arm';		--右手臂
		right_hand		= 'right_hand';		--右手掌
		right_up_leg	= 'right_up_leg';	--右大腿
		right_down_leg	= 'right_down_leg';	--右小腿
		right_foot		= 'right_foot';		--右脚
		left_arm		= 'left_arm';		--左手臂
		left_hand		= 'left_hand';		--左手掌
		left_up_leg		= 'left_up_leg';	--左大腿
		left_down_leg	= 'left_down_leg';	--左小腿
		left_foot		= 'left_foot';		--左脚
		right_weapon	= 'right_weapon';	--右武器
		left_weapon		= 'left_weapon';	--左武器
		right_wing		= 'right_wing';		--右翅膀
		left_wing		= 'left_wing';		--左翅膀
	};

--朝向类型
DirectionType =
	{
		faceleft	= 1;				--朝左
		faceright	= 2;				--朝右
	};

--伤害显示标签漂浮速度
DamageShowSpeed = 
	{
		X_SPEED		= 0.15;				--x方向速度
		Y_SPEED		= 0.3;				--y方向速度
	};


--玩家状态
PlayerState =
	{
		idle		= 1;				--待机状态
		moving		= 2;				--移动状态
	};

--战斗者状态
FighterState =
	{
		idle		= 0;				--空闲状态
		moving		= 1;				--移动状态
		normalAttack= 2;				--普通攻击状态
		skillAttack = 3;				--技能攻击状态
		singing		= 4;				--吟唱状态
		death		= 5;				--死亡状态
	};

--战斗状态
FightState = 
	{
		none = 0;						--未进入战斗界面
		fightState = 1;					--进入战斗模式
		recordState = 2;				--进入录像模式
	};

--摄像机状态
CameraState =
	{
		normal		= 0;				--正常状态
		zoomIn		= 1;				--放大
		zoomOut		= 2;				--缩小
		zoomStop	= 3;				--放大停止
		shakeUp		= 4;				--抖动上
		shakeDown	= 5;				--抖动下
	};

--胜利方
Victory =
	{
		none		= 0;
		left		= 1;
		right		= 2;
	};

