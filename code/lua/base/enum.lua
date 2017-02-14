--enum.lua

--========================================================================
--========================================================================
--枚举定义

--  背包分类
BagKind = 
	{
		material    = 101;
		piece       = 102;
		love        = 103;
		comsumables = 104;
	}

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
		normal       = 1;				--普通
		noviceBattle = 2;				--新手战斗
		treasure     = 3;				--巨龙宝库
		worldBoss    = 4;				--世界boss
		unionBoss    = 5;				--公会boss
		invasion     = 6;				--杀星
		miku         = 7;				--迷窟
		zodiac       = 8;				--十二宫
		limitround   = 9;				--限时副本
		expedition   = 10; --  远征
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
		normal             = 0;		--普通
		elite              = 1;		--精英
		zodiac             = 2;		--十二宫关卡
		arena              = 3;		--竞技场
		trial              = 4;		--试炼
		worldBoss          = 5;		--世界boss
		unionBoss          = 11;		--公会Boss
		noviceBattle       = 6;		--新手战斗
		FriendBattle       = 7;		--好友挑战
		treasureBattle     = 8;		--巨龙宝库
		treasureGrabBattle = 9;		--巨龙宝库占领穴位战斗
		treasureRobBattle  = 10;		--巨龙宝库抢劫战斗
		invasion           = 12;		--杀星
		scuffle            = 13;		--乱斗场
		miku               = 14;		--迷窟
		limitround         = 15;		--限时副本
		expedition         = 16;
		cardEvent          = 17;
		rank			   = 18;	--排位
		unionBattle        = 19;	--社团战
	};
	
-- 等级压制率
LevelToSuppress =
{
	accuracyRate = 1;--0.89; -- 命中
	damageRate = 1;--0.97;   -- 攻击
}
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
		Unknown			= 0;				--未知
		MainCity		= 1;				--主城
		WorldBoss		= 2;				--世界boss
		Union			= 3;				--公会
		Plot			= 4;				--剧情
		UnionBoss		= 5;				--公会Boss
		Scuffle			= 6;				--大竞技场
		
		FightScene		= 7;				--从战斗场景直接返回
		WorldMapUI		= 8;				--世界地图UI
		PubUI			= 9;				--英灵殿UI
		PveBarrierUI	= 10;				--关卡地图UI
		ZodiacSignUI	= 11;				--十二宫地图UI
		RuneUI			= 12;				--符文UI
		DragonUI		= 13;				--巨龙宝库UI
		
		HomeUI			= 14;				--家UI
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
	
--品质类型
QualityType =
	{
		'common.colour_white',				--白
		'common.colour_green',				--绿
		'common.colour_blue',				--蓝
		'common.colour_purple',				--紫
		'common.colour_yellow',				--金
		'common.colour_anjin'				--暗金
	};
QualityType[0] = 'common.colour_wuse';

--人物品质类型
RoleQualityType =
	{
		'godsSenki.colour_white_1',			--白
		'godsSenki.colour_green_1',			--绿
		'godsSenki.colour_blue_1',			--蓝
		'godsSenki.colour_purple_1',		--紫
		'godsSenki.colour_yellow_1',		--金
		''			--暗金
	};
RoleQualityType[0] = 'godsSenki.colour_wuse';
	
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

QualityColor =
	{
		QuadColor(Color.White),					--白
		QuadColor(Color(61, 217, 14, 255)),		--绿
		QuadColor(Color(15, 187, 255,255)),		--蓝
		QuadColor(Color(206, 16, 190, 255)),	--紫
		QuadColor(Color(254, 102, 0, 255)),		--金
		QuadColor(Color(255, 0, 0, 255)),		--红
		QuadColor(Color(232, 37, 74, 255)),		--红
		QuadColor(Color(9, 45, 147, 255)),
		QuadColor(Color(38, 19, 0, 255)),
		QuadColor(Color(5, 225, 251, 255)),
	};

--宝石属性类型
ActorPropertyTypeName =
	{
		LANG_enum_1,
		LANG_enum_2,
		LANG_enum_3,
		LANG_enum_4,
		LANG_enum_5,
		LANG_enum_6,
		LANG_enum_7,
		LANG_enum_8
	};
	
--限时消息提醒
LimitNews = 
	{
		addpower 	= 1, 				--吃披萨
		npcshop		= 2,				--npc商店
		arena       = 3,
		achievement1 = 4,
		achievement2 = 5,
		fightreward  = 6,
		levelreward  = 7,
		getpartner   = 8,
		worldBoss    = 9,
		scuffle		 = 10,
	};

--任务索引
TaskIndex = 
	{
		daily 	= 1;
		main  	= 2;
		grow	= 3;
		peiyang	= 4;
	}

--战斗图层
FightZOrderList =
	{
		bottom			= -10000;			--最底层
		skillEffect		= 10001;			--技能图层ZOrder，最前端显示
		obstacle		= 1000;				--boss准备场景障碍Zorder
		teleport		= -1000;			--出生点特效
		shader			= 9000;				--技能遮罩
		imageGuide      = 20000;
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
		fly_idle		= 'fly_idle';		--飞行待机
		fly_run			= 'fly_run';		--飞行
		run				= 'run';			--跑动
		f_idle			= 'f_idle';			--战斗待机
		f_run			= 'f_run';			--战斗移动
		attack			= 'attack';			--攻击
		skill			= 'skill';			--技能攻击
		hit				= 'hit';			--受击
		death			= 'die';			--死亡
		win				= 'win';			--胜利
		await			= 'await';			--待机小动作
		auto1 			= 'auto1';			--自动技能
		chant			= 'chant';			--蓄力
		skill2			= 'skill2';			--技能2
		repel			= 'repel';			--击退
		down			= 'down';			--倒地		
	};

--技能类型
SkillType =
	{
		activeSkill		= 0;				--主动技能（普通的主动技能）
		passiveSkill	= 1;				--被动技能
		normalAttack	= 2;				--普通攻击
		
	};

--释放阶段
ReleasePeriod =
{
	none = -1; -- 此数据策划不可填写
	instantaneous = 0; -- 瞬时
	delay = 1; -- 搓一下子
};

--技能的目标选择方式
SkillSelectTargeterType = 
{
	Point          = 1; -- 点
	HorizontalLine = 2; -- 水平线
	VerticalLine   = 3; -- 垂直线
	ObliqueLine    = 4; -- 斜线(无用)
	Cycle          = 5; -- 圆
	Cross 				 = 6; -- 十字
	All 					 = 7; -- all
};

VerticalLineTargeter = 
{
	Front  = 1; -- 前排
	Middle = 2; -- 中排（不可用）（又可用了）
	Rear   = 3; -- 后排
}

--普攻攻击距离
NormalAttackRange = 
{
	Front = 15; 		-- 前排攻击距离
	Middle = 130; 	-- 中排攻击距离
	Rear = 260; 		-- 后排攻击距离
}

--选择类型(暂未使用)
LineXorDirection =
{
	HTTorUTD = 1; 		-- head to tail or up to down
	TTHorDTU = 2; 		-- tail to head or down to up
	Line1 = 201; 			-- 第1条横线or纵线
	Line2 = 202;
	Line3 = 203;
	Line4 = 204;
	Line5 = 205;
	LeftObliqueLine = 400; -- 左斜线\
	RightObliqueLine = 401; -- 右斜线\
};

--技能分类
SkillClass = 
	{
		ordinarySkill	= 0;				--普通的主动技能
		startSkill		= 1;				--起手技能
		counterSkill	= 2;				--反击技能
		comboSkill		= 3;				--连击技能
		pursuitSkill	= 4;				--追击技能
		triggerSkill	= 5;				--常驻触发技能
	}

--技能状态
FighterComboState = 
	{
		Default		= 7;			--默认
		Fall		= 1;			--倒地
		Repel		= 2;			--击退
		Vertigo		= 3;			--击晕
		Injured		= 5;			--重伤
		Combo		= 6;			--高连
		AllTrigger	= 8;			--所有都触发
	}

--常驻触发技能条件
SkillCause =
	{
		SkillDamage			= 11;			--造成技能伤害
		AttackDamamge		= 12;			--造成普攻伤害
		HPDamage			= 13;			--受到攻击伤害
		HPHeal				= 14;			--受到技能治疗
		KillUnit			= 15;			--杀死单位
		HPTrigger			= 16;			--血量低于某百分比时触发
		HPResident			= 17;			--血量低于某百分比时常驻		
	}

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
	
--成就类型 =
AchievementType = 
	{
		HpPercent				= 1;				--我方完成关卡最少总体血量要求
		CardDoentUse			= 2;				--必须不能用某张卡
		CardUse					= 3;				--必须用某张卡
		TimeLimit				= 4;				--通关时间限制
		TimeMonster				= 5;				--打死某个特别的怪需要的时间
		ComboNeed				= 6;				--需要combo数量
		Nodeath					= 7;				--无人死亡
	}
	
	
-- 技能单位系数
SkillTargeterFactor =
{
	Point = 1;  	-- 单体目标
	Line = 1; 	-- 单排/3目标以下
	Cycle = 1; 	-- 群体目标
}
--Buff影响的属性类型
FighterPropertyType =
{
	-- 基本属性
	none      = 0;  -- nothing
	phy       = 1;  -- 普通攻击
	mag       = 2;  -- 绝技攻击
	phyDef    = 3;  -- 普通防御
	magDef    = 4;  -- 绝技防御
	hp        = 5;  -- 生命值
	cri       = 6;  -- 暴击
	acc       = 7;  -- 命中
	dod       = 8;  -- 闪避
--fp 9 战力
	ang       = 10;  -- 怒气值(power)
	ten       = 11; -- 韧性
	immDamPro = 12; -- 免伤比
	movSpe    = 13; -- 移动速度
	-- 不可变属性
	phyAttFac = 14; -- 普通攻击因子
	magAttFac = 15; -- 绝技攻击因子
	phyDefFac = 16; -- 普通防御因子
	magDefFac = 17; -- 绝技防御因子
	chaFac    = 18; -- 追击因子
	-- 不要使用19，20枚举值，已被天赋使用
	--atk_power = 19; --
	--hit_power = 20; --

	-- 中间属性
	phyDam = 101; -- 普通伤害
	magDam = 102; -- 技能伤害
	purDam = 103; -- 追击伤害
};
	
--战斗中角色的特殊状态类性
FightSpecialStateType =
{
	--状态 
	None          = 0;  -- 无状态
	Freeze        = 1;  -- 冰冻
	Dizziness     = 2;  -- 眩晕
	Invincible    = 3;  -- 无敌
	Thorns        = 4;  -- 反伤
	Immune        = 5;  -- 免疫
	Blind         = 6;  -- 目盲
	Chaos         = 7;  -- 混乱
	Silence       = 8;  -- 沉默
	Deny          = 9;  -- 法术否定
	Bloodthirsty  = 10; -- 吸血

	--光环
	NoAnger       = 11; -- 不得怒气(光环)
	MoreAnger     = 12; -- 更多的怒气(光环)

	Cleanse       = 13; -- 净化
	Relieve       = 14; -- 解除
	DodgeAddAnger = 15; -- 闪避增加怒气值

	--光环
	HaloRecoverEffect= 16; -- 回复效果提升/降低(光环)
	HaloThorns       = 17; -- 反伤(光环)
	HaloImmuneDamage = 18; -- 免伤(光环)
	HaloDamage       = 19; -- 伤害提升/降低(光环)
	HaloComboDamage  = 20; -- combo伤害提升/降低(光环)

	--标记  抗性加成
	MarkSkillProperty0 = 100; -- 无属性标记
	MarkSkillProperty1 = 101; -- 风
	MarkSkillProperty2 = 102; -- 火
	MarkSkillProperty3 = 103; -- 水
	MarkSkillProperty4 = 104; -- 土

	--属性(技能属性) (光环)  伤害加成
	SkillProperty0 		= 200; -- 无属性(可能是combo所用)
	SkillProperty1 		= 201; -- 风（乱起的）
	SkillProperty2 		= 202; -- 火（乱起的）
	SkillProperty3 		= 203; -- 水（乱起的）
	SkillProperty4 		= 204; -- 雷（乱起的）
};

--同上对应, 角色属性
RoleProperty =
{
	None = 200;
	Wind = 201;
	Fire = 202;
	Water = 203,
	Light = 204;
};

--buff标记类型
BuffSymbolType =
{
	BeneficialBuff = 1; -- 有益buff
	HarmfulBuff 	 = 2; -- 有害buff
}

PropertyRound =
{
	Light = 1;
	Wind = 2;
	Fire = 3;
	Water = 4;
	None = 5;
}
	
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
		right_up_wing	= 'right_up_wing';	--右上翅膀
		right_down_wing	= 'right_down_wing';--右下翅膀
		left_up_wing	= 'left_up_wing';	--左上翅膀
		left_down_wing	= 'left_down_wing';	--左下翅膀
		pet_wing		= 'pet_wing';		--有翅膀时候的宠物节点
		pet_no_wing		= 'pet_no_wing';	--无翅膀时候的宠物节点
		head_wing		= 'head_wing';      --头部翅膀节点
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
		skillAttack		= 3;				--技能攻击状态
		singing			= 4;				--吟唱状态
		death			= 5;				--死亡状态
		keepIdle		= 6;				--待机保持状态
		pauseAction		= 7;				--定身状态
	};

--战斗状态
FightState = 
	{
		none				= 0;			--未进入战斗界面
		fightState			= 1;			--进入战斗模式
		recordState			= 2;			--进入录像模式
		loadState			= 3;			--战斗加载状态
		pauseState			= 4;			--暂停状态
		recordPauseState	= 5;			--录像暂停状态
	};

--摄像机状态
CameraState =
	{
		normal			= 0;				--正常状态
		zoomIn			= 1;				--放大
		zoomOut			= 2;				--缩小
		zoomStop		= 3;				--放大停止
		shake 			= 4;				--抖动
		shakeUp 		= 5;
		shakeDown 		= 6;
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
		selectSearchFriend		= 20;		--查找好友单选按钮组
		selectActivityButton	= 21;		--查找好友单选按钮组
		selectCardFun			= 22;		--卡牌列表按钮
		selectCardList			= 23;		--卡牌选择
		selectGemInfo			= 24;		--宝石合成界面 7个级别的宝石
		zhaomubtn				= 25;		--招募界面中的3种抽卡方式
		selectBagList           = 26;       --背包界面
		cardEventReward         = 27;      
		cardEventSelectLv		= 28;
		settingPanelSound       = 29;       --设置面板声音和音效
		openServiceReward		= 30;		--开服大礼
		cardComment				= 31;		--卡牌评论
		homePanelRadioBtn 		= 32;		--家界面
		weekReward				= 33;		--周礼包
		runeInlayPage			= 34;		--符文镶嵌 分页按钮
		runeInlayType			= 35;		--符文镶嵌 类别单选按钮
		runeComposeType			= 36;		--符文吞噬 类别单选按钮
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
		joinInFellow		= 8;			--小伙伴
	};

--特殊队伍tid枚举值
SpecialTeam = 
{
		PropertyTeam = 100; -- 属性副本队伍
		--TreasureTeam = 101; -- 探宝队队伍
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
		
		treasureBox		= 11;				--宝箱
		power			= 12;				--体力药剂
		heroChip		= 14;				--英雄碎片

		wing 			= 15;				--翅膀
		wingMaterial 	= 16;				--翅膀材料
		
		--=======纯客户端使用类别，上面是跟策划表格相关======--
		rune 			= 100;				--符文
		RuneExchange    = 101;				--符文兑换
		chipMerge    	= 102;				--碎片合成
	};

UseItemType =
	{
		SingleItem		= 0;
		Package			= 1;
		PowerBottle		= 2;
		ChangeNameCard	= 3;
	};


ItemPackageType = 
	{
		toolType		= 1;				--背包道具类型
		equipType		= 2;				--装备类型
		gemType			= 3;				--宝石类型
		materialType	= 4;				--材料类型
		noPackageType	= 5;				--非包裹类型，如金币
		chipType		= 6;				--英雄碎片
	};

ItemPackageTipType = 
	{
		getAndSellTip		= 1;			--买和卖的tip
		onlySellTip			= 2;			--仅卖出tip
		noButtonTip			= 3;			--无按钮tip
		openAndOpenAllTip	= 4;			--打开和全部打开
		equipSellTip		= 5;			--卖出装备tip
		gemsNotButtonTip	= 6;			--宝石无按钮tip
	};

--关卡ID段
RoundIDSection =
	{
		NoviceBattleID  = 101;  -- 新手战斗关卡
		InvasionBegin   = 201;  -- 杀星起始关卡id
		InvasionEnd     = 300;  -- 杀星结束关卡id
		SoulBegin		= 500;	-- 魂师关卡
		SoulEnd 		= 599;	-- 魂师关卡
		NormalBegin     = 1000; -- 普通关卡起始ID
		NormalEnd       = 1999; -- 普通关卡结束ID
		EliteBegin      = 2000; -- 精英关卡起始ID
		EliteEnd        = 2999; -- 精英关卡结束ID
		ZodiacBegin     = 3000; -- 十二宫关卡起始ID
		ZodiacEnd       = 3017; -- 十二宫关卡结束ID
		TreasureBegin   = 4000; -- 巨龙宝库的起始id
		TreasureEnd     = 4999; -- 巨龙宝库的结束id
		MiKuBegin       = 5000; -- 迷窟起始关卡id
		MiKuEnd         = 5999; -- 迷窟结束关卡id
		LimitRoundBegin = 7000; -- 限时副本开始id
		LimitRoundEnd   = 7999; -- 限时副本结束ID
		ExpeditionBegin = 8001;
		ExpeditionEnd   = 8015;
		NormalEliteBeign= 5001;
		NormalEliteEnd  = 5999;
	    CardEventBegin  = 6001;
		CardEventEnd    = 6999;
		CardEventEver	= 3;
		CardEventMaxLv  = 5;
	};

--物品的ID分段
ItemIDSection =
	{
		RuneItemBegin			= 1000;				--符文ID段开始
		RuneItemEnd				= 5999;				--符文ID段结束
		BarrierItemBegin		= 11000;			--普通关卡材料ID段开始
		BarrierItemEnd			= 11999;			--普通关卡材料ID段结束
		EliteItemBegin			= 12021;			--精英图纸ID段开始
		EliteItemEnd			= 12999;			--精英图纸ID段结束
		ZodiacItemBegin			= 13001;			--十二宫ID段开始
		ZodiacItemEnd			= 13999;			--十二宫ID段结束
		skillDrawingBegin		= 14000;			--技能升阶图纸ID段开始
		skillDrawingEnd			= 14999;			--技能升阶图纸ID段结束
		killBossBegin			= 19001;			--杀星物品ID段开始
		killBossEnd				= 19999;			--杀星物品ID段结束
		RoleChipBegin			= 30000;			--英雄碎片ID段开始
		RoleChipEnd				= 39999;			--英雄碎片ID段结束
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
		PacksInfo				= 1;			--宝石信息
		PacksNothing			= 0;			--宝石拆卸
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
		171, 172, 173, 174, 175
		--171, 172, 173, 174, 175, 176, 177, 178
	};
--宝石文字
GemWord = 
	{
		LANG_GEM_NA,
		LANG_GEM_SA,
		LANG_GEM_ND,
		LANG_GEM_SD,
		LANG_GEM_HP,
	};

--将数字转换成等级
NumToLevel = 
	{
		LANG_enum_9, LANG_enum_10, LANG_enum_11, LANG_enum_12, LANG_enum_13, LANG_enum_14, LANG_enum_15, LANG_enum_16, LANG_enum_17 , LANG_enum_18
	};	
	
--将数字转化成星期
NumToWeek =
	{
		LANG_enum_19, LANG_enum_20, LANG_enum_21, LANG_enum_22, LANG_enum_23, LANG_enum_24, LANG_enum_25
	};
	
--任务主线与否(这个应该删掉，慢慢来)
TaskMain =
	{
		yes			= 0;					--主线
		no			= 1;					--支线
	};

--任务类别
TaskClass = 
{
	main = 0;
	Bline = 1;
}

--任务类型
TaskType =
	{
		dialog		= 0;					--找人
		barrier		= 1;					--通关X关卡Y次
		monster		= 2;					--杀X怪Y次
		reward		= 3;					--获得X物品Y个
		system		= 4;					--完成某个系统一次操作。
	};

--
TaskWhoSpeak =
{
	Left = 0;
	Right = 1;
};

TaskSpecialContentTriggerType = 
{
	Dialog = 1;
};

--爱恋度任务类型
LoveTaskType =
{
	barrier = 1;
	monster = 2;
	reward = 3;
};

--日常任务类型
ActivityDegreeType =
	{
		barrier     = 1;  -- 任意关卡
		strength    = 2;  -- 强化装备
		advance     = 3;  -- (装备升阶) 改成技能升级
		arena       = 4;  -- 竞技场挑
		gold        = 5;  -- 炼金
		pub         = 6;  -- 刷新酒馆
		refine      = 7;  -- 洗礼
		limitRound  = 8;  -- 限时副本
		capTreasure = 9;  -- 占领宝库
		miku        = 10; -- (迷窟)改成英雄副本
		train       = 11; -- (使用训练场)改成吃包子
		starSoul    = 12; -- 刷新星魂
		zodiac      = 13; -- (黄道十二宫)改成远征
		hunt        = 14; -- 猎魔（符文系统）
		worldBoss   = 15; -- 世界boss
		unionAlter  = 16; -- 公会祭祀
		rankfight	= 17;
	};
	
--成就任务类型
AchievementDegreeType =
	{
		parnter     = 1;  -- 任意关卡
		strength    = 2;  -- 强化装备
		rankup		= 3;  -- 星级
		lovemarried = 4;  -- 结婚数量
		lovelv		= 5;  -- 爱恋提升等级
	};

--寻路类型
FindPathType =
	{
		no			= 0;					--没在寻路
		barrier		= 1;					--寻找关卡
		npc			= 2;					--寻找npc
		Union		= 3;					--寻找公会npc
		npcshop  	= 4;
		worboss     = 5;
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
		portraitIn	 = 11;					--对话半身像进入
		portraitOut	 = 12;					--对话半身像移出
		shadeIn		 = 13;					--对话遮罩显示
		shadeOut	 = 14;					--对话遮罩隐藏
		npcTalkTw	 = 15;					--台湾版说话
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
		pos3		= 5,		--5级
		pos4		= 20,		--20级
		pos5		= 30,		--30级
	};
	
--小伙伴开启等级
FellowOpenType	=
	{
		pos1		= 30,		--30级
		pos2		= 40,		--40级
		pos3		= 50,		--50级
		pos4		= 60,		--60级
		pos5		= 70,		--70级
		pos6		= 80,		--80级
	};		

GuidePartner = 
	{
		hire1 			= 9,		--新手引导召唤伙伴1
		hire 			= 7,		--新手引导召唤伙伴2
		cardrolelvup 	= 15,		--新手引导升级伙伴
		love			= 16,		--新手引导爱恋伙伴
	};
--[[
GuideIndexExt.befigth2
GuideIndexExt.bfcardrolelvup
GuideIndexExt.befigth3
GuideIndexExt.belove2
]]
GuideIndexExt = 
{
	befigth2 = 4;
	bfcardrolelvup = 6;
	befigth3 = 8;
	belove2 = 9;
};

--新手引导索引
UserGuideIndex = 
	{
		hire1					= 1;			--召唤伙伴1
		fight1 					= 2;			--战斗1
		love					= 3;			--爱恋
		hire		 			= 4;			--召唤伙伴2
		fight2					= 5;			--战斗2
		card					= 6;			--抽卡
		cardrolelvup			= 7;			--人物升级
		dailytask				= 8;			--任务
		fight3					= 9;			--战斗3
		love2					= 10;
		equip					= 11;			--装备引导
		equipadv				= 12;			--装备升阶
		task10					= 13;			--探宝开启
		task11					= 14;			--宝石镶嵌
		union					= 15;
		task16					= 16;			--精英副本
		task17					= 17;			--排位赛开启
		task18					= 18;			--宝藏占领
		arenaTask				= 19;			--22级任务  竞技场
		worldBossTask			= 20;			--23级任务  世界boss
		propertyTask			= 21;			--24级任务  属性副本
		cardEvent               = 22;			
		npcshop					= 23;			--32级任务
		expeditonTask			= 24;			--27级任务  远征
		strength				= 25;
		soulAndCrystalsoul		= 26;			--魂师进价和晶魂熔炼
		upstar					= 27;
		talent					= 28;
		skillup					= 29;
		curiosity				= 30;			--珍宝引导

		chipsmash 				= 99;			--碎片拆分
	};

Prestige_shoptype = 
{
	normal 		= 1;
	union  		= 2;
}

--新手引导对应的任务ID/引导ID/等级
SystemTaskId =  
	{
		[1]			= 3,
		[2]			= -1,
		[3]			= 4,  
		[4] 		= 100004,
		[5]			= -1, 
		[6]			= 100005,
		[7]			= 100005,
		[8]			= 100005,
		[9]			= -1,
		[10]       	= 100007,
		[11]		= 100011,
		[12]		= 100014,
		[13]		= 100015,
		[14]		= 10,
		[15]        = 16,
		[16]        = 100022,
		[17]        = 20,
		[18]		= 100024,
		[19]        = 100026,					--22,
		[20]        = 23,					--23,
		[21]        = 26,					--25,  属性试炼
		[22]        = 100031,
		[23]        = 100036,
		[24]        = 27,					--27,
		[25]		= 100041,
		[26]		= 29;					--魂师进价和晶魂熔炼 
		[27]		= 100045,
		[28]		= 100052,
		[29]		= 35,						--level
		[30]		= 40,
	};


--===========================================================================
--===========================================================================
--功能开启依赖

--实际功能开启等级
FunctionOpenLevel =
{
	invasion        = 20;  -- 杀星
	friend          = 99;  -- 好友（聊天中好友按钮开启）
	friendlist		= 18;
	updateInfo      = 9;   -- 更新公告
	assist          = 10;  -- 好友助战
	promotion       = 99;  -- 活动
	strengthTen     = 99;  -- 强化十次
	autoFight       = 9;  -- 自动战斗
	HangUpOpenLevel = 15;  -- 扫荡开放
	TouchTailEnbale = 99;  -- 画屏效果开启

	arena           = 21; -- 竞技场 !!同时需更改服务器开启等级
	skill           = 99;  -- 技能
	refine          = 25; -- 潜力开启
	trial           = 99;  -- 试炼
	limitround      = 26; -- 限时副本
	dragon          = 150; -- 巨龙宝库
	miku            = 99;  -- 迷窟
	roleadvance     = 99;  -- 人物升星
	union           = 15; -- 公会
	train           = 200; -- 训练场
	starMap         = 240; -- 星魂
	zodiac          = 250; -- 十二宫
	wing            = 400; -- 翅膀
	rune            = 50; -- 符文
	gem             = 199; -- 宝石
	expedition      = 27; -- 远征 ！！更改的同时需要更改服务器等级限制
	talent			= 32; -- 天赋
	treasure  		= 12;  --探宝
	hunShi			= 29;	--魂师
	crystalSoul 	= 29;	--晶魂
	cardComment		= 30;	--30级才可以发表评论 
	rankMatch		= 20;	--排位赛
	chipsmash		= 50;
	scuffle			= 30;
	curiosity		= 40;
	runeOpend		= 50;
};

FunctionOpenTask = 
{
	team 			= 100009; --编队开始任务
};

VipAvatarHeight = 
{
	normal 			= 80; --编队开始任务
	wing 			= 100;
};


--功能第一次点击开放
FunctionFirstClickOpen =
	{
		arena		= 1;		--竞技场 !!同时需更改服务器开启等级
		trial		= 2;		--试炼
		skill		= 4;		--技能
		
		zodiac		= 8;		--十二宫
		train		= 16;		--训练场
		union		= 32;		--公会
		dragon		= 64;		--巨龙宝库
		
		starMap		= 128;		--星魂
		rune		= 256;		--符文
		gem			= 512;		--宝石
		roleadvance	= 1024;		--升星
		refine		= 2048;		--潜力
		miku		= 4096;		--迷窟
		limitround	= 8192;		--限时副本
		wing		= 16384;	--翅膀
		dailyTask = 1; -- 每日任务
	};

--===========================================================================
--===========================================================================

--界面开启点对应的任务或等级
MenuOpenLevel =
	{
		openBarrier	= 203;		--打开关卡任务
		guidEnd		= 225;		--引导结束（用于判定新功能开放，会有多个功能按钮同时开放）
		statistics	= 100012;		--统计结束点
		normalTask  = 1020;		--关闭箭头提示任务id
		openWorldMap= 1027;		--开放世界地图
		openMerge	= 5000--1115;		--开放合并图标（任务）
	};

--新手引导特殊步骤完成情况   --要更改的 BY Dongenlai
--[[GuideStep =
	{
		step1		= 1;		--送完伙伴
		step2	    = 2;		--修改完名字
		step3		= 3;		--设置完队伍
		step4	    = 4;		--强化成功
		step5		= 5;		--招募完伙伴
		step6		= 6;		--队伍2
		step7		= 7;		--精英
		step8		= 8;		--升阶
		step1	    = 9;		--每日任务
	};--]]

	GuideStep =
	{
		partner		= 1;		--送完伙伴
		changeName	= 2;		--修改完名字
		team		= 3;		--设置完队伍
		strength	= 4;		--强化成功
		pub			= 5;		--招募完伙伴
		team2		= 6;		--队伍2
		elite		= 7;		--精英
		advance		= 8;		--升阶
		dailyTask	= 9;		--每日任务
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
		vop_buy_unionBattle_count   = 23;			--社团战斗次数
		
		--===================
		--服务器使用
--[[		vop_flush_targets			= 23,			--试炼场刷新对手
		vop_clear_pass_round		= 24,			--普通关卡清除cd
		vop_equip_compose_buy		= 25,			--升阶材料购买--]]
		--===================
		
		vop_flush_cave				= 26;			--刷新英雄迷窟
		
		--客户端用 begin
		vop_buy_goldpackage			= 27;			--买金宝箱	
		vop_buy_siverpackage		= 28;			--买银宝箱
		--客户端用 end
		vop_cancel_cd				= 29;			--取消挂机CD时间
		vop_union_zhizun			= 30;			--公会新增至尊贡献
		vop_arena_clear_time = 31; --清除竞技场等待时间
	};
	
--场景特效位置类型
SceneEffectPositionType = 
	{
		TopMiddleScene					= 1;			--场景上方中央
		FirstEnemy						= 2;			--第一个敌方位置
		FirstAlly						= 3;			--第一个友方位置
		MiddleScene 					= 4;			--屏幕中心
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
		miku					= 4;			--迷窟
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
		YES	= 'godsSenki.fuwen_xue1';		--有血
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

TreasureButtonPanelType =
{
	panel1 = 1; -- 扫荡 挑战
	panel2 = 2; -- 抢劫 协助 占领
	panel3 = 3; -- 占领
	panel4 = 4; -- 放弃
	panel5 = 5; --放弃协守
};

TreasureMessageBoxType = 
{
	empty     = 1; -- 空矿占领
	occupy    = 2; -- 有人 挑战成功后占领
	rob       = 3; -- 挑战 抢钱
	help      = 4; -- 协守
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
		no				= 0;		
	};	
	
--命运属性类型
FatePropertyTypeName =
	{
		LANG_enum_26,	
		LANG_enum_27,
		LANG_enum_28,
		LANG_enum_29,
		LANG_enum_30,
		LANG_enum_31,
		LANG_enum_32,
		LANG_enum_33
	};
	
--碎片类型
ChipItemType = 
	{
		pkg			= 1;
		soul		= 2;	
	};	
	
--邮件已读状态
EmailReadStatus = 
	{
		readed		= 1;		--已读邮件
		unread		= 0;		--未读邮件
	};

--邮件类型
EmailType = 
	{
		reward		= 1;		--奖励邮件
		system		= 2;		--客服邮件
	};		

--分享类型
ShareType =
	{
		gplus		= 1;		--google+
		gplay		= 2;		--google play
		facebook	= 3;		--facebook
	};

--公会留言类型
UnionInputType =
	{
		input		= 1;		--留言
		hongbao		= 2;		--红包
	};

--鼓舞类型
InspireType =
	{
		worldBoss 	= '1';		--世界boss
		unionBoss 	= '2';		--公会boss
		scuffle 	= '3';		--乱斗场static
	};

--战斗结束弹出界面
FightOverPopup =
	{
		none	 	= 0;		--没界面
		strength 	= 1;		--强化界面
		task 		= 2;		--任务界面
	};
	
--活动类型
ActivityType = 
	{
		static 		= 1; 		--静态活动
		openServer 	= 2;		--开服活动
		dateGiven	= 3;		--特定日期
	};
	

--翅膀类型
WingType =
	{
		w1_101		= 23000;
		w1_201		= 23010;
		w1_301		= 23020;
		w1_401		= 23030;
		w1_501		= 23040;
		w1_601		= 23050;
		one 		= 23000;	--等级1
		two 		= 23010;	--等级1
		three 		= 23020;	--等级1
		four 		= 23030;	--等级1
		five 		= 23040;	--等级1
		six 		= 23050;	--等级1
	};
	
--翅膀品质
WingQualityType =
	{
		'C',
		'B',
		'A',
		'S',	
		'S+',	
	};	
	
--翅膀穿脱
WingWear =
	{
		off	 	= 0;			--脱下
		on 		= 1;			--穿上
	};

--翅膀合成/分解
WingCompose =
	{
		compose	 	= 0;		--合成
		split 		= 1;		--分解
	};		

--星魂界面属性
XinghunAtt =
	{
		LANG_enum_1,
		LANG_enum_2,
		LANG_enum_3,
		LANG_enum_4,
		LANG_enum_5,
	};

--界面ZOrder
PanelZOrder = 
	{
		home			= 300,
		cardlist		= 400,
		bagList         = 1000,
		xinghun			= 500,
		cardinfo		= 500,
		equip			= 500,
		skill			= 500,
		teamOrganization= 2000,
		memberSelect    = 700,
		teamSelct		= 500,
		teamComprise	= 600,
		propertyBounses = 1500,
		gem				= 2000,
		wing			= 2000,
		pet				= 2000,
		curiosity		= 2000,
		runeHunt		= 2000,
		runeInlay		= 2000,
		runeCompose		= 2000,
		soul			= 3000,
		sweapon			= 1000,

		qianli			= 500,		--潜力界面
        chatPanelZOrder = 400,      --私聊的界面
		friendList		= 300,		--好友界面
		friendFLower    = 400,
		friendApply		= 400,
		task			= 400,		--任务界面
		accept			= 400,

		chipsmash		= 500,


		fightConfig		= 12000,
		win_pve			= 13000,
		lose_pve		= 13000,
		win_pvp			= 13000,
		lose_pvp		= 13000,
		loveMax         = 20000,
		select_actor	= 2000,

		userGuide		= 20000,

		sweep			= 15000,
		
		Zhaomu			= 100,		--招募界面
		ZhaomuResult	= 200,		--招募结果界面

		activity		= 200,		--活动页面
		shop			= 400,		--商店

		FBInstr			= 1600,		--战前准备界面
		treasure		= 1300,		--探宝界面
		property		= 1300,		--属性试炼
		FB				= 1300,
		expedition		= 1300,		--远征
		worldmap		= 1000,
		saodang			= 1700,

		BigPic			= 2000,     --战斗立绘
		hpProgress		= 400,		--血条

                comboPanel              = 500, -- combo面板

		tips			= 20000,    --tips
		feedbackPanel	= 50;		
		homeGetRolePanel = 2500;
		everydayTipPanel = 60;
		thirtyDaysNotLoginRewardPanel = 50;

	}

--排行榜类型
RankType = 	
	{
		Fight 		= 1;
		Level 		= 2;
		Card		= 3;
		Union		= 4;
		Arena 		= 5;
		CardEvent 	= 6;
	}


--战斗界面的背景
FightConfigBrush = 
	{
		On = 'fight.cf_danxuankuangG';
		Off = 'fight.cf_danxuankuang';
	}

HomeTemplateType =
{
	Skillup = 1;
	Skilladv = 2;
	Equipup = 3;
	Equipadv = 4;
}

--  章节数
ChapterName =
{
	'一',
	'二',
	'三',
	'四',
	'五',
	'六',
	'七',
	'八',
	'九',
	'十',
	'十一',
	'十二',
	'十三',
	'十四',
	'十五',
}

PropertyKinds = 
{
	[2] = '風',
	[3] = '火',
	[4] = '水',
	[5] = '無',
}

SkillTypeEnum = 
{
	[1] = '転倒';
	[2] = '吹飛';
	[3] = '気絶';
	[4] = '追击';
	[5] = '重傷';
	[6] = '高连';
	[100] = '';
}

CardSide =
   {
      Left = 1;
      Right = 2;
   }

ShopType = 
	{
		Normal 	= 1;
		Chip 	= 2;
	}

ShopSetType = {
	gameShop 			= 1;		-- 游戏商城
	lmtShop 			= 2;		-- 礼包商店
	cardeventShop 		= 3;		--活动商店
	mysteryShop 		= 4;		-- 村正小铺
	specialShop 		= 5;		-- 藏宝阁
	pvpShop 			= 6;		-- 竞技场声望商店
	pvpBigShop 			= 7;		-- 竞技场荣誉商店
	expeditionShop 		= 8;		-- 远征商店
	debrisSplitShop 	= 9;		-- 堕天使之屋（碎片商店）
	guildShop 			= 10;		-- 堕天使之屋（碎片商店）
	runeShop			= 11;
	
}

ShopMaxType = 11; -- 对应ShopSetType

--活动时间
ActivityTime = 
{
	OpenActivity = 7 * 86400; --开服活动按钮时间
}

WingPanelEnterType = 
{
	normal 				 = 0,
	openServerWingSelect = 1,
}
