
--========================================================================
--========================================================================
--全局变量

GlobalData =
	{
		--策划不可调参数
		TimeOut					= 15;				--超时（单位秒）
		FPS						= 24;				--每秒帧数	
		MinFPS					= 30;	
		
		WholeDaySecons			= 86400;
		
		sortActor			= nil;					--用于排序过程中存储源角色
		isSortByRoot		= false;	 
		
		--[[美术制作按照480的比例制作场景，人物按照640比例制作--]]
		ActorScale				= 0.75;				--人物缩放
		MainSceneLogicWidth		= 1448;				--主场景逻辑宽度
		MainSceneLogicHeight	= 480;				--主场景逻辑高度
		MainSceneLogicHeightHalf= 240;				--场景逻辑高度一半
		LeftTeleportPos			= {x=-625, y=-100};	--左侧传送点位置
		RightTeleportPos		= {x=554, y=-100};		--右侧传送点位置
		
		FightSceneLogicWidth	= 1066;				--战斗场景逻辑宽度
		FightSceneLogicHeight	= 480;				--战斗场景逻辑高度
		
		LogicSceneWidth			= 852;				--场景按照16:9的尺寸制作（高度固定为480）
		
		MainSceneMaxY			= -50;				--主场景最大Y
		BossSceneMaxX			= -250;				--战斗场景最大X
		UnionSceneMaxX			= 533;				--公会场景最大X
		UnionSceneMaxY			= -100;				--公会场景最大Y

		AllyPlayerHpRatio		= 1;				--友方角色战斗初始血量百分比
		EnemyPlayerHpRatio		= 1;				--敌方角色战斗初始血量百分比
		
		MaxSceneRoleNum			= 20;				--场景最大可见人数
		LimitMinFPS				= 15;				--受限最低帧率（低于该帧率会做一些优化）

		MouseMoveDistance		= 3;				--拖拽时鼠标可移动移动距离
		MouseMoveTime			= 0.2;
		
		UpdateTime				= 0.002;			--录像模式下每次update的时间
		
		CommonBuffName			= 'BUFF_01';		--通用buff名

		--常用路径
		ScenePath		= 'resource/scene/';		--场景path
		AnimationPath	= 'resource/animation/';	--动作path
		EffectPath		= 'resource/effect/';		--特效path
		ParticlePath	= 'resource/particle/';		--粒子path
		UIPath			= 'resource/ui/';			--UI path
		OtherPath		= 'resource/other/';		--其它
		
		AsyncLoadEnable			= true;				--异步加载开关
		PlayBackEnable			= false;			--记录回放
		PlayBackOpen			= false;			--是否回放打开
		MaxNormalBarrier		= 2000;				--普通关卡编号最大值
		MaxEliteBarrier			= 3000;				--精英关卡编号最大值
		MaxZodiacBarrier		= 4000;				--十二宫关卡编号最大值
		MaxUndoneCount			= 20;				--普通未接任务显示数
		HeartBeatPeriod			= 40;				--心跳周期40s
		HeartBeatWait			= 30;				--心跳等待30s
		
		WorldBossSceneId		= 1999;				--世界boss场景
		UnionSceneId			= 2998;				--公会场景ID
		UnionBossSceneId		= 2999;				--公会boss场景	
		ScuffleSceneId			= 2000;				--乱斗场场景ID
		NeedShowUnion			= true;			--是否需要显示公会
		
		RightTotalDamage		= 0;

		--服务器需要的信息
		system					= { Win32 = 1, Android = 2, iOS = 3 };
		jinfo					= '';					--平台的参数
	};

asyncLoadManager = AsyncLoadManager.Instance();	--异步加载器
fightResultManager = FightResultManager.Instance();
resTableManager = fightResultManager;

local fileList = {};

--加载lua文件
function LoadLuaFile(fileName)
	if fileList[fileName] ~= nil then
		return;
	end
	fightResultManager:DoScriptFile(fileName);
	fileList[fileName] = true;
end