--globalData.lua

--========================================================================
--========================================================================
--全局变量

GlobalData =
	{
		-- 策划不可调参数
    --
    EnterCity = true;
    RoleName = '';
    roleNameColor = Color.Red;
    MainScenePartCountX                 = 128;
    MainScenePartCountY                 = 128;

		TimeOut                              = 15;                                                -- 超时（单位秒）
		FPS                                  = 25;                                                -- 每秒帧数
		MinFPS                               = 30;

		WholeDaySecons                       = 86400;

		IsEncryption                         = true;                                              -- 消息是否加密

		sortActor                            = nil;                                               -- 用于排序过程中存储源角色
		isSortByRoot                         = false;

		-- [[美术制作按照480的比例制作场景，人物按照640比例制作 -- ]]
		ActorScale                           = 0.6;                                              -- 人物缩放（原始是0.75）
		ActorNPCScale                           = 1.0;                                              -- NPC人物缩放
		ActorFightScale                      = 0.9;                                              -- 人物战斗中缩放
		--MainSceneLogicWidth                  = 1448;                                              -- 主场景逻辑宽度
		--MainSceneLogicHeight                 = 480;                                               -- 主场景逻辑高度
		LeftTeleportPos                      = {x = -625, y = -100};                              -- 左侧传送点位置
		RightTeleportPos                     = {x = 554, y = -100};                               -- 右侧传送点位置
		MainSceneEnterFightRegion            = Rect( Vector2(554-50, -100-20), Size(100, 100) );  -- 主场景进入战斗区域
		MainSceneEnterWorldMapRegion         = Rect( Vector2(-625-50, -100-20), Size(100, 100) ); -- 主场景进入世界地图区域

		ArmatureScale                        = Vector2(1.3, 1.3);                                 -- 角色缩放比例
		ActorScaleChange                     = 0.9 / 0.75;                                       -- 角色缩放比例调整(ActorScale / 0.75)
		--宽度已废弃（普通副本，每个关卡scene宽度不同）
		FightSceneLogicWidth                 = 2559;                                              -- 战斗场景逻辑宽度
		FightSceneLogicHeight                = 480;                                               -- 战斗场景逻辑高度

		LogicSceneWidth                      = 2000;                                               -- 场景按照16:9的尺寸制作（高度固定为480）


    --[[这里是主城地图的信息，其他位置的信息作废]]--

    MainSceneLogicWidth              = 2500;                                              -- 主城场景逻辑宽度
    MainSceneLogicHeight             = 2500;                                               -- 主城场景逻辑高度
		MainSceneLogicHeightHalf             =2500/2;                                               -- 场景逻辑高度一半

    MainSceneMaxX                    = 2500/2;       -- 主城最大X
    MainSceneMaxY                    = 2500/2;        -- 主城最大Y

    MainSceneMinX                    = -2500/2;       -- 主城最小X
    MainSceneMinY                    = -2500/2;  


		BossSceneMaxX                        = -250;                                              -- 战斗场景最大X
		UnionSceneMaxX                       = 533;                                               -- 公会场景最大X
		UnionSceneMaxY                       = -100;                                              -- 公会场景最大Y

		AllyPlayerHpRatio                    = 1;                                                 -- 友方角色战斗初始血量百分比
		EnemyPlayerHpRatio                   = 1;                                                 -- 敌方角色战斗初始血量百分比

		MaxSceneRoleNum                      = 30;                                                -- 场景最大可见人数
		LimitMinFPS                          = 15;                                                -- 受限最低帧率（低于该帧率会做一些优化）

		MouseMoveDistance                    = 3;                                                 -- 拖拽时鼠标可移动移动距离
		MouseMoveTime                        = 0.2;

		UpdateTime                           = 0.002;                                             -- 录像模式下每次update的时间

		CommonBuffName                       = 'BUFF_01';                                         -- 通用buff名

		-- 常用路径
		ScenePath                            = 'resource/scene/';                                 -- 场景path
		AnimationPath                        = 'resource/animation/';                             -- 动作path
		EffectPath                           = 'resource/effect/';                                -- 特效path
		ParticlePath                         = 'resource/particle/';                              -- 粒子path
		UIPath                               = 'resource/ui/';                                    -- UI path
		OtherPath                            = 'resource/other/';                                 -- 其它

		AsyncLoadEnable                      = true;                                              -- 异步加载开关
		PlayBackEnable                       = false;                                             -- 记录回放
		PlayBackOpen                         = false;                                             -- 是否回放打开
		MaxNormalBarrier                     = 2000;                                              -- 普通关卡编号最大值
		MaxEliteBarrier                      = 3000;                                              -- 精英关卡编号最大值
		MaxZodiacBarrier                     = 4000;                                              -- 十二宫关卡编号最大值
		MaxUndoneCount                       = 20;                                                -- 普通未接任务显示数
		HeartBeatPeriod                      = 40;                                                -- 心跳周期40s
		HeartBeatWait                        = 30;                                                -- 心跳等待30s

		WorldBossSceneId                     = 1999;                                              -- 世界boss场景
		UnionSceneId                         = 2998;                                              -- 公会场景ID
		UnionBossSceneId                     = 2999;                                              -- 公会boss场景
		ScuffleSceneId                       = 2000;                                              -- 乱斗场场景ID
		NeedShowUnion                        = true;                                              -- 是否需要显示公会

		IsOpenTreasurePackage                = false;                                             -- 是否是打开宝箱界面

    FightAutoBattleFlag              		 = false;                                             -- 保存自动战斗标记

		-- 服务器需要的信息
		system                               = { Win32 = 1, Android = 2, iOS = 3 };
		jinfo                                = '';                                                -- 平台的参数
      
	instanceConsumePower                     = 6;            --副本战斗消耗的体力值
	};

function GlobalData:InitGlobalDir()
	if VersionUpdate.testmode == true then
		local prefixPath = '../langResource/' .. VersionUpdate.curLanguage .. '/';
		GlobalData.ScenePath		= prefixPath .. 'resource/scene/';		--场景path
		GlobalData.AnimationPath	= prefixPath .. 'resource/animation/';	--动作path
		GlobalData.EffectPath		= prefixPath .. 'resource/effect/';		--特效path
		GlobalData.ParticlePath		= prefixPath .. 'resource/particle/';		--粒子path
		GlobalData.UIPath			= prefixPath .. 'resource/ui/';			--UI path
		GlobalData.OtherPath		= prefixPath .. 'resource/other/';		--其它	
	end
end

function GlobalData:GetResDir()
	if VersionUpdate.testmode == true then
		return '../langResource/' .. VersionUpdate.curLanguage .. '/';
	else
		return ''
	end
end


--=============================================================================================
--tiledmap坐标转换
--=============================================================================================

function PointToTiled(px, py)
  local x = math.floor( (px + GlobalData.MainSceneLogicWidth / 2)  / GlobalData.MainSceneLogicWidth * GlobalData.MainScenePartCountX   ) + 1;
  local y = math.floor( (py + GlobalData.MainSceneLogicHeight / 2)  / GlobalData.MainSceneLogicHeight * GlobalData.MainScenePartCountY ) + 1;
  --微调边界值
  if x > GlobalData.MainScenePartCountX then
    x = GlobalData.MainScenePartCountX;
  end
  if y > GlobalData.MainScenePartCountY then
    y = GlobalData.MainScenePartCountY;
  end
  return {x = x, y = y};
end

function TiledToPoint(location)
  local x = location.x;
  local y = location.y;
  local px = (x - 1) * GlobalData.MainSceneLogicWidth / GlobalData.MainScenePartCountX - GlobalData.MainSceneLogicWidth/2;
  local py = (y - 1) * GlobalData.MainSceneLogicHeight / GlobalData.MainScenePartCountY - GlobalData.MainSceneLogicHeight/2;
  return {x = px, y = py};
end














