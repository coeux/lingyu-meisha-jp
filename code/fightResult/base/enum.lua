
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

--性别
SexType =
	{
		girl			= 1;				--女
		boy				= 2;				--男
	};

--角色类型
ActorType = 
	{
		hero			= 1;				--英雄
		partner			= 2;				--伙伴
		monster			= 3;				--小怪
		eliteMonster	= 4;				--精英怪
		boss			= 5;				--boss
	};
	
--boss类型
MonsterRoundType =
	{
		normal			= 1;				--普通
		noviceBattle	= 2;				--新手战斗
		treasure		= 3;				--巨龙宝库
		worldBoss 		= 4;				--世界boss
		unionBoss		= 5;				--公会boss
		invasion		= 6;				--杀星
	};

--关卡类型
BarrierType = 
	{
		normal			= 0;				--普通
		elite			= 1;				--精英
		instance		= 2;				--十二宫关卡
	};
	
--load类型
LoadType =
	{
		none			= 0;
		worldBoss		= 1;				--世界boss
		unionBoss		= 2;				--公会Boss
	};

--战斗类型
FightType = 
	{
		normal					= 0;		--普通
		elite					= 1;		--精英
		instance				= 2;		--十二宫关卡
		arena					= 3;		--竞技场
		trial					= 4;		--试炼
		worldBoss				= 5;		--世界boss
		unionBoss				= 11;		--公会Boss
		noviceBattle			= 6;		--新手战斗
		FriendBattle			= 7;		--好友挑战
		treasureBattle			= 8;		--巨龙宝库
		treasureGrabBattle		= 9;		--巨龙宝库占领穴位战斗
		treasureRobBattle		= 10;		--巨龙宝库抢劫战斗
		invasion				= 12;		--杀星
		scuffle					= 13;		--乱斗场
	};
	
--后占计算战斗类型
BackstageType =
	{
		pvp = 1;
		boss = 2;
	};
	
--追踪特效的飞行轨迹
FlightPathType =
	{
		Parabola				= 1;		--抛物线
		StraightLine			= 2;		--直线
		HorizontalTrajectory 	= 3;		--水平直线
	};

--职业
JobType =
	{
		knight			= 1;				--骑士
		warrior			= 2;				--战士
		hunter			= 3;				--猎人
		magician		= 4;				--法师
	};

--场景类型
SceneType =
	{
		MainCity		= 1;				--主城
		WorldBoss		= 2;				--世界boss
		Union			= 3;				--公会
		Plot			= 4;				--剧情
		UnionBoss		= 5;				--公会Boss
		Scuffle			= 6;				--大竞技场
	};
	
--手势类型
GestureType =
	{
		Circle 			= 'Circle';			--圆
		Lighting 		= 'Lighting';		--闪电
		V				= 'V';				--V
		Z				= 'Z';				--Z
		Unknown			= 'Unknown';		--未匹配到手势
	};
	
--手势对应技能ID
GestureSkillID =
	{
		V				= 101;				--勾
		Circle			= 201;				--圆
		Lighting		= 301;				--闪电
		Z				= 401;				--Z
	};

--装备部位
EquipmentPos =
	{
		head			= 1;				--头
		body			= 2;				--身体
		foot			= 3;				--足		
		weapon			= 4;				--武器
		jewelry			= 5;				--饰品
	};
	
--按钮状态
ButtonStatus =
	{
		button1Normal = 'common.anniu_1';			--按钮1正常状态
		button1Press  = 'common.anniu_2';			--按钮1按下状态
		button2Normal = 'common.anniu02_1';			--按钮2正常状态
		button2Press  = 'common.anniu02_2';			--按钮2按下状态
	};


--试炼状态
TrialStatus =
	{
		init			= -1;				--初始化
		notask			= 0;				--未接任务
		task			= 1;				--已结任务
		failFight		= 2;		        --上次战斗结束请求没发送
	};

--试炼类型
TrialType =
	{
		'godsSenki.shilian_1',				--简单
		'godsSenki.shilian_2',				--普通
		'godsSenki.shilian_3',				--困难
		'godsSenki.shilian_4'				--地狱	
	};	
	
--战斗技能图标移动状态
SkillIconMoveState = 
	{
		parabola 	= 1;			--抛物线
		level		= 2;			--水平
	};

--动作类型
AnimationType =
	{
		none			= 0;				--空
		idle			= 'idle';			--待机动作
		run				= 'run';			--跑动
		f_idle			= 'f_idle';			--战斗待机
		f_run			= 'f_run';			--战斗移动
		attack			= 'attack';			--攻击
		skill			= 'skill';			--技能攻击
		hit				= 'hit';			--受击
		death			= 'die';			--死亡
		win				= 'win';			--胜利
		await			= 'await';			--待机小动作
	};

--技能类型
SkillType =
	{
		activeSkill		= 0;				--主动技能
		passiveSkill	= 1;				--被动技能
		normalAttack	= 2;				--普通攻击
	};
	
--攻击状态
AttackType = 
	{
		normal			= 0;				--普通
		skill			= 1;				--技能
		gesture			= 2;				--手势技能
	};
	
--攻击状态
AttackState = 
	{
		normal			= 0;				--普通	
		critical		= 1;				--暴击
		miss			= 2;				--闪避
		RecoverHP		= 3;				--加血
	};
	
--Buff影响的属性类型
FighterPropertyType =
	{
		attack		 		= 1;			--攻击	
		physicalDef			= 2;			--物理防御
		magicDef			= 3;			--魔法防御
		hp					= 4;			--生命值
		cri					= 5;			--暴击值
		acc					= 6;			--命中值
		dodge				= 7;			--闪避值
		moveSpeed			= 8;			--移动状态
	};	
	
--战斗中角色的特殊状态类性
FightSpecialStateType =
	{
		PauseAction			= 1;			--定身
		Invincible			= 2;			--无敌
		TripleDamage		= 3;			--三倍伤害
	};	
	
--录像事件类型
RecordEventType =
	{
		enterScene		= 0;				--角色进入场景
		idle			= 1;				--角色进入待机状态
		keepIdle		= 2;				--角色进入保持待机状态
		move			= 3;				--角色进入移动状态
		normalAttack	= 4;				--角色进入普通攻击状态
		skillAttack		= 5;				--角色进入技能攻击状态
		damage 			= 6;				--角色受到伤害
		buff			= 7;				--角色添加buff
		cameraZoomIn	= 8;				--战斗结束的镜头拉近事件
		
		fightPause 		= 9;				--游戏暂停事件
		fightResume		= 10;				--游戏恢复事件
		startShowSkill	= 11;				--开始技能展示事件
		endShowSkill	= 12;				--结束技能展示事件
		actionPause		= 13;				--动作暂停事件
		actionResume	= 14;				--动作恢复事件
		bringToFront	= 15;				--ZOrder提前事件
		recoverZorder	= 16;				--恢复ZOrder事件
		
		removeBuff		= 17;				--删除buff
		buffDamage		= 18;				--buff伤害
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
		faceleft		= 1;				--朝左
		faceright		= 2;				--朝右
	};

--伤害显示标签漂浮速度
DamageShowSpeed = 
	{
		X_SPEED			= 0.15;				--x方向速度
		Y_SPEED			= 0.3;				--y方向速度
	};

--加速按钮状态
SpeedButtonType =
	{
		available		= 1;				--可用
		unavailable		= 2;				--不可用
		hidden			= 3;				--隐藏
	}

--玩家状态
PlayerState =
	{
		idle			= 1;				--待机状态
		moving			= 2;				--移动状态
	};

--战斗者状态
FighterState =
	{
		idle			= 0;				--空闲状态
		moving			= 1;				--移动状态
		normalAttack	= 2;				--普通攻击状态
		skillAttack		= 3;				--技能攻击状态
		singing			= 4;				--吟唱状态
		death			= 5;				--死亡状态
		keepIdle		= 6;				--待机保持状态
	};

--战斗状态
FightState = 
	{
		none			= 0;				--未进入战斗界面
		fightState		= 1;				--进入战斗模式
		recordState		= 2;				--进入录像模式
		loadState		= 3;				--战斗加载状态
		pauseState		= 4;				--暂停状态
	};

--摄像机状态
CameraState =
	{
		normal			= 0;				--正常状态
		zoomIn			= 1;				--放大
		zoomOut			= 2;				--缩小
		zoomStop		= 3;				--放大停止
		shakeUp			= 4;				--抖动上
		shakeDown		= 5;				--抖动下
	};	

--胜利方
Victory =
	{
		none		= 0;
		left		= 1;
		right		= 2;
	};
	
--RadionButton组
RadionButtonGroup =
	{
		selectRole				= 1;		--选择角色进入游戏
		selectJiYou				= 2;		--选择基友参加战斗
		selectRoleInfoHuoBan	= 3;		--角色信息选择伙伴
		selectRoleAdvanceHuoBan	= 4;		--伙伴进阶选择伙伴
		selectRefineHuoBan		= 5;		--洗炼选择伙伴信息
		selectTeamHuoBan		= 6;		--阵型选择伙伴
		selectPveGuanQia		= 7;		--选择关卡类型（普通或精英）
		selectRoleEquipStrength	= 8;		--装备强化界面选择伙伴
		selectEquipEquipStrength= 9;		--装备强化界面选择装备
		selectGemSynthetise		= 10;		--宝石合成界面选择宝石
		selectGemMosRole		= 11;		--宝石镶嵌界面选择角色
		selectEquipMos			= 12;		--宝石镶嵌界面选择装备
		selectGemChoose			= 13;		--宝石选择界面选择宝石
		selectGemItemCell		= 14;		--宝石选择界面选择宝石格子
		selectRoleSkill			= 15;		--技能面板选择伙伴		
		selectOtherPlayerInfo	= 16;		--查看其他玩家信息时选择角色
		selectDragonFloor		= 17;		--巨龙宝库选择层数
		selectUnionBossTime		= 18;		--公会boss时间
		selectStarmapHuoBan		= 19;		--星魂选择组
	};

--拖拽分组
DragDropGroup =
	{
		bodyEquipPackage	= 1;			--身上穿的装备背包
		equipPackage		= 2;			--装备背包
		
		joinInTeam			= 3;			--上阵
		leaveTeam			= 4;			--离阵
		leaveTeamPanel		= 5;			--离阵区域，人物以外的区域
		runeInPackage		= 6;			--包裹中的符文
		runeEquip			= 7;			--已装备的符文
	};

--穿脱装备（协议）
EquipTakeOnOff =
	{
		off				= 0;				--脱下
		on				= 1;				--穿上
	};

--物品类型
ItemType =
	{
		item			= 1;				--道具
		equip			= 2;				--装备
		material		= 3;				--材料
		gemStone		= 4;				--宝石
		drawing			= 5;				--图纸
		packs			= 6;				--礼包
		trash			= 7;				--垃圾
		consumable		= 8;				--金币，水晶，战力等消耗品
		
		--=======纯客户端使用类别，上面是跟策划表格相关======--
		rune 			= 100;				--符文
		RuneExchange    = 101;				--符文兑换
	};

--物品的ID分段
ItemIDSection =
	{
		BarrierItemBegin	= 11000;		--普通关卡材料ID段开始
		BarrierItemEnd		= 11999;		--普通关卡材料ID段结束
		EliteItemBegin		= 12021;		--精英图纸ID段开始
		EliteItemEnd		= 12999;		--精英图纸ID段结束
		ZodiacItemBegin		= 13001;		--十二宫ID段开始
		ZodiacItemEnd		= 13999;		--十二宫ID段结束
		skillDrawingBegin	= 14000;		--技能升阶图纸ID段开始
		skillDrawingEnd		= 14999;		--技能升阶图纸ID段结束
		killBossBegin		= 19001;		--杀星物品ID段开始
		killBossEnd			= 19999;		--杀星物品ID段结束
	};

--装备tip显示按钮
TipEquipShowButton =
	{
		EquipSell				= 0;			--装备、卖出按钮
		Nothing					= 1;			--按钮不显示
		Sell					= 2;			--卖出按钮
		UnEquip					= 3;			--卸下按钮
		Shop					= 4;			--商店显示
	};

--礼包tip显示按钮
TipPacksShowButton =
	{
		PacksInfo				= 0;			--宝石信息
		PacksNothing			= 1;			--宝石拆卸
	};

--宝石tip显示按钮
TipGemShowButton =
	{
		GemInfo				= 0;			--宝石信息
		GemDismantle		= 1;			--宝石拆卸
		GemShop				= 2;			--商城宝石
	};

--材料tip显示按钮
TipMaterialShowButton =
	{
		SellSynthesisObtain	= 0;			--都显示
		Obtain				= 1;			--获取按钮
		SellObtain			= 2;			--卖出、获取按钮
		SynthesisObtain		= 3;			--合成、获取按钮
		Sell				= 4;			--卖出按钮
	};

	
--次数购买类型
BuyCountType =
	{
		power			= 1;				--购买体力
		energy			= 2;				--活力
		arena			= 3;				--竞技场次数
		elite			= 4;				--重置精英副本
		zodiac			= 5;				--重置十二宫进度
		daily			= 6;				--重置日常任务
	};

--宝石种类前缀
--1物理攻击 2魔法攻击 3物理防御 4魔法防御 5生命值 6暴击值 7命中值 8闪避值
GemPrefix = 
	{
		171, 172, 173, 174, 175, 176, 177, 178
	};
	
--任务主线与否
TaskMain =
	{
		yes			= 0;					--主线
		no			= 1;					--支线
	};

--任务类型
TaskType =
	{
		dialog		= 0;					--找人
		barrier		= 1;					--通关X关卡Y次
		monster		= 2;					--杀X怪Y次
		reward		= 3;					--获得X物品Y个
		system		= 4;					--完成某个系统一次操作。
	};

--日常任务类型
DailyTaskType =
	{
		barrier		= 1;					--普通关卡胜利（不含挂机）
		strength	= 2;					--强化装备
		compose		= 3;					--宝石合成
		arena		= 4;					--竞技场挑
		trial		= 5;					--完成试炼任务
		train		= 6;					--使用训练场
		gold		= 7;					--炼金
		zodiac		= 8;					--黄道十二宫
		pub			= 9;					--刷新酒馆		
		union		= 10;					--公会祭祀
		hunt		= 11;					--猎魔（符文系统）
		talk		= 12;					--世界聊天
		advance		= 13;					--装备升阶
		refine		= 14;					--洗礼
		capTreasure	= 15;					--占领宝库
		robTreasure	= 16;					--抢夺宝库
	};
	
--寻路类型
FindPathType =
	{
		no			= 0;					--没在寻路
		barrier		= 1;					--寻找关卡
		npc			= 2;					--寻找npc
		Union		= 3;					--寻找公会npc
	};
	
--NPC状态
NpcStatus =
	{
		no			= 0;					--没有任务
		noLevel		= 1;					--主线任务没达到等级
		receive		= 2;					--已接未完成的任务
		undone		= 3;					--未接任务
		complete	= 4;					--完成的任务
	};

--NPC特殊状态
NpcSpecial =
	{
		default		= 0;					--默认状态，有任务	
		bless		= 1;					--没有任务，显示愿诸神祝福你
		recruit		= 2;					--没有任务，显示前往英灵殿
	};

--NPC状态对应的图标
NpcStatusImage =
	{
		noLevel		= 'task_5';				--没达到等级主线任务
		receive		= 'task_2';				--已接未完成的任务
		undone		= 'task_3';				--未接任务
		complete	= 'task_1';				--完成的任务
	};

--持续性剧情接口类型
PlotStepType =
	{
		none		= 0;					--无
		npcMove		= 1;					--NPC移动
		blackIn		= 2;					--屏幕黑屏淡入
		blackOut	= 3;					--屏幕黑屏淡出
		blackInText	= 5;					--黑屏字幕淡入
		blackOutText= 6;					--黑屏字幕淡出
		npcTalk		= 7;					--说话
		wait		= 8;					--等待
		blackInImage = 9;					--图片淡入
		blackOutImage= 10;					--图片淡出
	};	

--提示框相对手势或箭头位置
GuideTipPos =
	{
		no			= 0;					--没有
		left		= 1;					--左边
		right		= 2;					--右边
		bottom		= 3;					--下面	
	};

--新手引导手势或箭头类型
GuideEffectType =
	{
		arrow		= 1;					--箭头
		hand		= 2;					--手势
		handMove	= 3;					--手势移动（第一个英雄上阵）
		handMove2	= 4;					--手势移动2（第二个英雄上阵）
	};
	
--队伍开启等级
TeamOpenType	=
	{
		pos2		= 1,		--1级
		pos3		= 8,		--8级
		pos4		= 25,		--25级
		pos5		= 40,		--40级
	};		

--开启新功能对应的任务ID
SystemTaskId =
	{
		strength	= 204;		--强化开启，强化装备教学
		partner		= 206;		--送伙伴
		changeName	= 207;		--起名字
		team		= 208;		--队伍开启，设置伙伴上场
		getGem		= 211;		--送宝石
		gem			= 212;		--宝石镶嵌开启
		pub			= 216;		--英灵殿开启
		team2		= 217;		--第二个英雄上阵
		getRefine	= 218;		--送宝石
		refine		= 220;		--潜力开启
		elite		= 224;		--精英副本开启
		advance		= 225;		--装备升阶学习
		elite2		= 226;		--精英副本2
		normalTask  = 1016;		--关闭箭头提示任务id
	};


--===========================================================================
--===========================================================================
--功能开启依赖

--功能点
FunctionPoint =
	{
		arena		= 1;		--竞技场
		trial		= 2;		--试炼
		skill		= 3;		--技能
		
		zodiac		= 4;		--十二宫
		train		= 5;		--训练场
		union		= 6;		--公会
		dragon		= 7;		--巨龙宝库
		
		starMap		= 8;		--星魂
		rune		= 9;		--符文
	};

--实际功能开启等级
FunctionOpenLevel =
	{
		promotion	= 13;		--活动
		friend		= 13;		--好友
		assist		= 15;		--好友助战
		arena		= 15;		--竞技场
		trial		= 16;		--试炼
		skill		= 16;		--技能
		
		zodiac		= 17;		--十二宫
		train		= 18;		--训练场
		union		= 19;		--公会
		dragon		= 21;		--巨龙宝库
		
		starMap		= 24;		--星魂
		rune		= 30;		--符文
		
		task		= 19;		--日常任务
		autoFight	= 8;		--自动战斗
	};

--功能第一次点击开放
FunctionFirstClickOpen =
	{
		arena		= 1;		--竞技场
		trial		= 2;		--试炼
		skill		= 4;		--技能
		
		zodiac		= 8;		--十二宫
		train		= 16;		--训练场
		union		= 32;		--公会
		dragon		= 64;		--巨龙宝库
		
		starMap		= 128;		--星魂
		rune		= 256;		--符文
	};

--===========================================================================
--===========================================================================

--界面开启点对应的任务或等级
MenuOpenLevel =
	{
		openBarrier	= 203;		--打开关卡任务
		guidEnd		= 226;		--引导结束（用于判定新功能开放，会有多个功能按钮同时开放）
		open1		= 17;		--第一步开放
		open2		= 21;		--第二步开放
		statistics	= 100012;		--统计结束点
		openWorldMap= 1027;		--开放世界地图
		openMerge	= 30;		--开放合并图标
	};

--新手引导新开启按钮
NewOpenMenu =
	{
		strength	= 'godsSenki.zhucheng_qianghua_1';		--强化开启，强化装备教学
		team		= 'godsSenki.zhucheng_duiwu_1';			--队伍开启，设置伙伴上场
		gem			= 'godsSenki.zhucheng_baoshi_1';		--宝石镶嵌开启
		elite		= 'godsSenki.zhucheng_jingying_1';		--精英副本开启
		pub			= 'godsSenki.zhucheng_yinglingdian_1';	--英灵殿开启
		refine		= 'godsSenki.zhucheng_qianli_1';		--潜力开启
		merge		= 'godsSenki.zhucheng_chengzhang_1';	--功能按钮合并
	}; 

--新手引导特殊步骤完成情况
GuideStep =
	{
		strength	= 1;		--强化成功
		partner		= 2;		--送完伙伴
		changeName	= 3;		--修改完名字
		team		= 4;		--设置完队伍
		gem			= 6;		--镶嵌完宝石
		pub			= 7;		--招募完伙伴
		refine		= 9;		--潜力
		elite		= 10;		--精英
		advance		= 11;		--升阶
		elite2		= 12;		--第二次精英（客户端没有用）
	};
	
	
ParticlePosType	=
	{
		World		= 0,		--世界坐标
		Relative	= 1,		--相对坐标
		Free		= 2,		--
	};		

--vip购买flag			
VipBuyType = 
	{
		vop_buy_power 				= 1;      		--购买体力
		vop_do_halt 				= 2;           	--开启挂机
		vop_buy_halt_time			= 3;      		--购买挂机时间
		vop_acc_fight_speed			= 4;    		--加速战斗
		vop_reste_adv_round			= 5;    		--重置精英关卡
		vop_add_bag_max				= 6;        	--增加背包上限
		vop_do_trial_pos3			= 7;      		--训练位置3
		vop_acc_trial				= 8;          	--加速训练
		vop_buy_fight_count			= 9;    		--购买竞技场次数
		vop_buy_trial_energy		= 10;   		--购买活力
		vop_do_vp_trial				= 11;        	--王者训练
		vop_reset_zodiac			= 12;       	--重置12宫
		vop_rune_cost				= 13;          	--符文召唤高级小怪
		vop_given_power				= 14;        	--每日体力赠送
		vop_do_buy_money			= 15;       	--炼金
		vop_flash_pub				= 16;          	--酒馆刷新
		vop_flash_vp_pub			= 17;       	--酒馆至尊刷新
		vop_reset_daily_task		= 18;   		--重置日常任务
		vop_pay_gm					= 19;           --公会捐献水晶
		vop_immedia_fight_wboss		= 20;			--被世界boss击杀后，立刻复活
		vop_num						= 21;			--永久增加背包上限
		vop_starmap					= 22;			--刷新星魂
	};
	
--场景特效位置类型
SceneEffectPositionType = 
	{
		TopMiddleScene					= 1;			--场景上方中央
		FirstEnemy						= 2;			--第一个敌方位置
		FirstAlly						= 3;			--第一个友方位置
	};

--竞技场排名区域
ArenaRankType	=
	{
		rank51		= 51,		--排名51位
		rank101		= 101,		--排名101位
		rank301		= 301,		--排名301位
		rank501		= 501,		--排名501位
		rank1001	= 1001,		--排名1001位
	};
	
InviteRewardStatus = 
	{
		Got						= -1;			--领过
		No						= 0;			--未达成
		Yes						= 1;			--已达成
	};		

--自动挂机类型
AutoBattleType = 
	{
		normal 					= 1;			--普通关卡
		zodiac 					= 2;			--十二宫
		treasure 				= 3;			--巨龙宝库
	};
	
--划中方向
SlideDirection = 
	{
		none 				= 0;			--没划中
		left 				= 1;			--向左划
		right 				= 2;			--向右划
	};
--符文怪物血
RuneMonsterLife =
	{
		YES	= 'godsSenki.fuwen_xue1';			--有血
		NO	= 'godsSenki.fuwen_xue2';		--没血		
	};	

--符文怪物状态
RuneMonsterState =
	{
		idle		= 0;				--空闲状态
		moving		= 1;				--移动状态
		death		= 2;				--死亡状态
	};
	
--猎取一个怪物时合成标示
RuneHuntFlag =
	{
		none		= 0;				--不合成
		yellow		= 5;				--合成金色以下符文
		purple		= 4;				--合成紫色以下符文
		blue		= 3;				--合成蓝色以下符文
	};
	
RuneDeadStatus =
	{
		initial		= 0;				--初始状态
		animation	= 1;				--死亡动作先播放完成
		net			= 2;				--网络先到
	};	
	
RuneType =	
	{
		physicalAttack 		= 1;		--物理攻击
		magicAttack			= 2;		--魔法攻击
		physicalDef			= 3;		--物理防御
		magicDef			= 4;		--魔法防御
		hp					= 5;		--生命值
		cri					= 6;		--暴击值
		acc					= 7;		--命中值
		dodge				= 8;		--闪避值
		anger				= 9;		--怒气
	};
	
--事件类型
SystemEventType =
	{
		startWorldBoss		= 0;		--世界boss开始
		gemSynthetise 		= 1;		--宝石合成
		zodiacSign 			= 2;		--通关黄道十二宫
		elite				= 3;		--通关精英关卡
		recruit				= 4;		--招募
		rmb 				= 5;		--获得水晶
		worldBossKilled		= 6;		--世界boss被击杀
		firstOne			= 7;		--成为竞技场第一
		worldBossEscape		= 8;		--世界boss逃跑
		firstOneOnLine		= 9;		--竞技场第一上线
		worldBoss10Hp		= 10;		--世界boss10%血量
	};
	
--需要单一显示的对话框类型
SingleMessageBoxType =
	{
		noMoneyEquipStrength 		= 1;		--强化装备缺钱
	};
	
--符文猎魔特效类型
RuneEffectType =
	{
		appearBig		= 0;				--大怪物出现
		appearSmall		= 1;				--小怪物出现
		disappear		= 2;				--怪物消失
		drop			= 3;				--掉落金色和紫色
	};

--符文提示按钮类型
RuneTipType =
	{
		equip		= 1;				--装备
		takeoff		= 2;				--卸载
	};		
	
DragonSurfaceType = 
	{
		bossSurface				= 1;
		floorSurface			= 2;
		incomeSurface			= 3;
		revengerSurface			= 4;
	};

--关卡奖励通关星类型
PveStar = 
	{
		star10			= 1;
		star20			= 2;
		star30			= 3;		
	};

--乱斗场战斗状态
ScuffleFightStatus = 
	{
		yes				= 1;
		No				= 0;		
	};

