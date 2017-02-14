--resTable.lua

--========================================================================
--资源表格

ResTable =
  {
    errors                 = 0;   -- 错误表
    scene                  = 1;   -- 场景表
    actor                  = 2;   -- 角色表
    monster                = 3;   -- 怪物表
    buff                   = 4;   -- buff
    skill                  = 5;   -- 技能表
    barriers               = 6;   -- 关卡表
    npc                    = 7;   -- npc表
    monster_property       = 8;   -- 怪物属性
    boss_property          = 9;   -- boss表
    skill_damage           = 10;  -- 技能伤害系数
    avatar                 = 11;  -- 角色形象表
    pveElite               = 12;  -- pve精英关卡
    vip                    = 13;  -- vip表
    equip                  = 14;  -- 装备表
    item                   = 15;  -- 物品表
    levelup                = 16;  -- 角色升级经验
    gemstone               = 17;  -- 宝石表
    equip_upgrade          = 18;  -- 强化数据表
    equip_upgrade_pay      = 19;  -- 强化描述表
    qualityup_stuff        = 20;  -- 伙伴升阶消耗表
    qualityup_attribute    = 21;  -- 伙伴升阶属性表
    equip_compose          = 22;  -- 装备升阶表
    gemstone_part          = 23;  -- 宝石镶嵌
    zodiac                 = 24;  -- 十二宫
    skill_upgrade          = 25;  -- 技能升级表
    actorNoKey             = 26;  -- 角色表（无key）
    arena_reward           = 27;  -- 竞技场奖励
    trial                  = 28;  -- 试炼任务概率
    trial_reward           = 29;  -- 试炼奖励
    task                   = 30;  -- 任务
    task_nokey             = 31;  -- 任务(无key)
    daily_task             = 32;  -- 日常任务
    barriers_nokey         = 34;  -- 关卡表(无key)

    train                  = 35;  -- 训练经验
    unionLevel             = 36;  -- 公会等级经验表
    unionSkill             = 37;  -- 工会技能属性表
    unionSkillCon          = 38;  -- 升级公会技能消耗的贡献值
    unionAltar             = 39;  -- 公会祭祀奖品
    pveGroup_nokey         = 40;  -- 精英关卡和十二宫关卡组表（无key）
    zodiac_drop            = 41;  -- 十二宫关卡掉落表
    potential_caps         = 42;  -- 潜力上限表
    tip                    = 43;  -- tip表

    tutorial_actorOrder    = 44;  -- 新手战斗本方角色入场顺序
    tutorial_round         = 45;  -- 新手战斗关卡配置
    tutorial_role          = 46;  -- 新手角色配置

    money_shop_buyID       = 47;  -- 商城物品
    money_shop_itemID      = 48;  -- 商城物品

    recharge_accumulative  = 49;  -- 累计充值
    recharge_fristtime     = 50;  -- 首次充值奖励

    gestureskill           = 51;  -- 手势技能
    gestureskillNoKey      = 52;  -- 手势技能（nokey）
    online_reward          = 53;  -- 在线奖励
    login_accumulative     = 54;  -- 累计登录奖励

    vip_open               = 55;  -- vip开启等级
    login_count            = 56;  -- 连续登录奖励
    talkword               = 57;  -- 日常任务世界喊话
    limitedword            = 58;  -- 屏蔽字

    gathering              = 59;  -- 统计表
    gemstone_compose       = 60;  -- 宝石合成概率
    friend_reward          = 61;  -- 好友邀请奖励

    treasure               = 62;  -- 巨龙宝库
    treasure_boss          = 63;  -- 巨龙宝库的boss配置
    rune_coordinate        = 64;  -- 符文怪物坐标
    rune_prob              = 65;  -- 符文怪物表
    rune                   = 66;  -- 符文表
    rune_exchange          = 67;  -- 符文兑换表
    rune_unlock            = 68;  -- 符文解锁表
    star_map               = 69;  -- 星魂数据表

                                  -- 杀星
    invasion               = 70;  -- 杀星主表
    invasion_boss          = 71;  -- 杀星boss
    invasion_city          = 72;  -- 杀星城市
    invasion_coordinate    = 73;  -- 杀星boss坐标
    invasion_drop          = 74;  -- 杀星掉落
    invasion_prefix        = 75;  -- 杀星boss前缀

    level_reward           = 77;  -- 等级奖励
    starreward             = 78;  -- 关卡奖励
    kof_rank_reward        = 79;  -- 乱斗场军衔图标
    kof_1st_reward         = 80;  -- 乱斗场冠军奖励
    sigh_reward            = 81;  -- 累计登录奖励

    passiveSkill           = 83;  -- 被动技能
    passiveSkillupgrade    = 84;  -- 被动技能升级表
    powerpush              = 85;  -- 推送表
    fp_reward              = 86;  -- 战斗力冲刺表

    unionAltarByPos        = 87;  -- 公会祭坛配置（key是位置）
    activity_time          = 88;  -- 副本福利时间

    miku                   = 89;  -- 英雄迷窟
    miku_nokey             = 90;  -- 英雄迷窟nokey
    miku_boss              = 91;  -- 英雄迷窟boss数据

    destiny                = 92;  -- 命运表
    hero_piece             = 93;  -- 英雄碎片表

    buff_relation          = 94;  -- buff之间关系表
    activity_consume       = 95;  -- 累计消费活动
    daily_pay              = 96;  -- 每日充值活动

    guild_bonus_coordinate = 97;  -- 公会红包位置显示表

    zodiac_level           = 98;  -- 十二宫怪物等级表

    zodiac_monster         = 99;  -- 十二宫boss属性
    limit_round            = 100; -- 限时副本
    limit_boss             = 101; -- 限时副本boss

    wing                   = 103; -- 翅膀配置
    wing_compose           = 104; -- 翅膀合成
    wing_compose_nokey     = 105; -- 翅膀合成(nokey)
    wing_activity          = 106; -- 翅膀活动
    activity_cfg           = 107; -- 活动配置

    achievement            = 108; -- 成就
    achievement_name       = 109; -- 成就名称
    skillNoKey             = 110; -- 技能表(nokey)
    plot                   = 113;
    love_task              = 115; -- 爱恋度任务
    love_reward            = 116; -- 爱恋度奖励
    chapter                = 117; -- 章节名称

    navi_effect            = 118; -- navi中每个图片的位置 内容
    navi_event             = 119; -- navi中每个事件的点击区域 对应声音文件 冲突事件列表
    navi_action            = 120; -- navi中每个事件中对应图片出现和消失的时间
    navi_main              = 121; -- navi主表

    barrier_effect         = 122; -- 关卡特效
    barrier_effect_switch  = 123; -- 关卡特效切换表

    levelup_attribute      = 124; -- 升级属性
    skill_compose          = 125; -- 技能升阶
    star                   = 126; -- 星魂的星星
    npc_shop_buyID         = 127; -- 商城物品
    npc_shop_itemID        = 128; -- 商城物
    potential              = 129; -- 潜力表
    title_up               = 130; -- 爵位升级
    daily_sign             = 131; -- 每日签到
    title_up_no_key        = 132;
    expedition             = 133; -- 远征
    create_role            = 134; -- 角色选择表
    random_name            = 135; -- 随机姓名
    sp_shop_buyID          = 136; -- 特殊商店
    actor_nokey            = 137;
    item_path              = 138;
    expedition_shop        = 139;
    tutorial_monster       = 140;  -- 新手角色配置
    init_equip             = 141;  --初始装备
    item_no_key            = 142; --无序item表
    star_prob              = 143;  --判定星魂颜色品质的
    drug                   = 144;
    config                 = 145;
    cdkey_reward           = 146; --礼包奖励
    event                  = 147;
    event_point            = 148;
    event_ranking          = 149;
    event_role             = 150;
    event_round            = 151;
	event_difficulty	   = 152;
    login_count_no_key    = 153;
    achievement_task	   = 154;
	event_reward		   = 155;
	newly_reward		   = 156;
  growup_reward      = 157;
  lmt_reward         = 158;
  rank_season_no_key	   = 159;
  rank_season			   = 160;
  soul					   = 161;
  soul_node				   = 162;
  levelup_nokey          = 163;
  unionboss_open          = 164;
	guild_battle_no_key	   = 165;
	guild_battle_building  = 166;
	guild_battle		   = 167;
	plant_shop		  		 = 168;
	inventory_shop	   		 = 169;
	kof_reward				= 170;
	unarena_reward				= 171;
	pet							= 172;
	pet_compose					= 173;
	event_open					= 174;
  open_task           = 175;    --开服成长表
	artifact					= 176;
	artifact_levelup			= 177;
	guild_shop			= 178;
	rune_shop 			= 179;
	model_change		= 180;
	model_change_nokey		= 181;
	pub_show			= 182;
	cardeventshop		= 183;
	skin 				= 184;
	pub_info			= 185;
	pub_special			= 186;
	sweapon				= 187;
	goodsToRound = {}
  }; 

local tableDir = '';
function ResTable:Init()
  if VersionUpdate.testmode == true then
    tableDir = '../langResource/' .. VersionUpdate.curLanguage .. '/';
  end

  resTableManager:LoadTable(ResTable.errors, tableDir .. 'table/errors.txt', 'errorid');                --错误表
  resTableManager:LoadTable(ResTable.scene, tableDir .. 'table/scene.txt', 'id');                  --场景表
  resTableManager:LoadTable(ResTable.actor, tableDir .. 'table/role.txt', 'id');                    --职业表
  resTableManager:LoadTable(ResTable.monster, tableDir .. 'table/monster.txt', 'id');                --怪物表
  resTableManager:LoadTable(ResTable.buff, tableDir .. 'table/buff.txt', 'id_level');                --对话表
  resTableManager:LoadTable(ResTable.skill, tableDir .. 'table/skill.txt', 'id');                  --技能表
  resTableManager:LoadTable(ResTable.barriers, tableDir .. 'table/round.txt', 'id');                  --关卡表
  resTableManager:LoadTable(ResTable.npc, tableDir .. 'table/npc.txt', 'id');                    --npc表
  resTableManager:LoadTable(ResTable.monster_property, tableDir .. 'table/monster_property.txt', 'level');      --怪物属性表
  resTableManager:LoadTable(ResTable.boss_property, tableDir .. 'table/boss_property.txt', 'id_level');        --boss属性表
  resTableManager:LoadTable(ResTable.skill_damage, tableDir .. 'table/skill_effect.txt', 'skillid');            --技能伤害系数表
  resTableManager:LoadTable(ResTable.avatar, tableDir .. 'table/avatar.txt', 'id_gender');              --角色形象表
  resTableManager:LoadTable(ResTable.pveElite, tableDir .. 'table/scene_reset.txt', 'id');              --pve精英关卡表

  --bt版处理
  if platformSDK.m_Platform == 'moli' or platformSDK.m_Platform == 'dm' or platformSDK.m_Platform == 'vqs' then	
	  resTableManager:LoadTable(ResTable.vip, tableDir .. 'table/vip_config_moli.txt', 'vip_level');              --vip表
  else
	  resTableManager:LoadTable(ResTable.vip, tableDir .. 'table/vip_config.txt', 'vip_level');              --vip表
  end

  resTableManager:LoadTable(ResTable.equip, tableDir .. 'table/equip.txt', 'id');  
  resTableManager:LoadTable(ResTable.item, tableDir .. 'table/item.txt', 'id');
  resTableManager:LoadTable(ResTable.item_no_key, tableDir .. 'table/item.txt', '');
  resTableManager:LoadTable(ResTable.star_prob, tableDir .. 'table/star_prob.txt', 'id');   --星魂颜色品质表
  resTableManager:LoadTable(ResTable.levelup, tableDir .. 'table/levelup.txt', 'level');
  resTableManager:LoadTable(ResTable.gemstone, tableDir .. 'table/gemstone.txt', 'id');
  resTableManager:LoadTable(ResTable.equip_upgrade, tableDir .. 'table/equip_upgrade.txt', 'type');
  resTableManager:LoadTable(ResTable.equip_upgrade_pay, tableDir .. 'table/equip_upgrade_pay.txt', 'strength_lv');
  resTableManager:LoadTable(ResTable.qualityup_stuff, tableDir .. 'table/qualityup_stuff.txt', 'id');          --强化升阶消耗表
  resTableManager:LoadTable(ResTable.qualityup_attribute, tableDir .. 'table/qualityup_attribute.txt', 'id');      --强化升阶属性表
  resTableManager:LoadTable(ResTable.equip_compose, tableDir .. 'table/equip_compose.txt', 'id');          --装备升阶表
  resTableManager:LoadTable(ResTable.gemstone_part, tableDir .. 'table/gemstone_part.txt', 'position');          --宝石镶嵌
  resTableManager:LoadTable(ResTable.zodiac, tableDir .. 'table/zodiac.txt', 'id');                  --十二宫
  resTableManager:LoadTable(ResTable.skill_upgrade, tableDir .. 'table/skill_upgrade.txt', 'lv');  
  --技能升级
  resTableManager:LoadTable(ResTable.skill_compose, tableDir .. 'table/skill_compose.txt', 'skillid');
  --技能升阶
  resTableManager:LoadTable(ResTable.arena_reward, tableDir .. 'table/arena_rank.txt', 'rank');
  resTableManager:LoadTable(ResTable.unarena_reward, tableDir .. 'table/unarena_rank.txt', 'rank');

  resTableManager:LoadTable(ResTable.trial, tableDir .. 'table/trial.txt', 'id');                           --试炼任务概率
  resTableManager:LoadTable(ResTable.trial_reward, tableDir .. 'table/trial_reward.txt', 'id');            --试炼奖励
  resTableManager:LoadTable(ResTable.task, tableDir .. 'table/quest.txt', 'id');                    --任务
  resTableManager:LoadTable(ResTable.daily_task, tableDir .. 'table/dailyquest.txt', 'id');              --日常任务
  --new task
  --resTableManager:LoadTable(ResTable.new_task, tableDir .. 'table/task.txt', 'id');                    --任务
  resTableManager:LoadTable(ResTable.plot, tableDir .. 'table/plot.txt', 'id');                    --任务
  
  resTableManager:LoadTable(ResTable.train, tableDir .. 'table/practice.txt', 'lv');                     --训练经验
  resTableManager:LoadTable(ResTable.unionLevel, tableDir .. 'table/guild.txt', 'guildlv');              --公会等级
  resTableManager:LoadTable(ResTable.unionboss_open, tableDir .. 'table/guildboss_open.txt', 'id');
  resTableManager:LoadTable(ResTable.unionSkill, tableDir .. 'table/guildskill.txt', 'keyid');              --工会技能
  resTableManager:LoadTable(ResTable.unionSkillCon, tableDir .. 'table/guildskill_cost.txt', 'skilllv');  
  resTableManager:LoadTable(ResTable.unionAltar, tableDir .. 'table/altar.txt', 'item');
  resTableManager:LoadTable(ResTable.unionAltarByPos, tableDir .. 'table/altar.txt', 'location');
  resTableManager:LoadTable(ResTable.zodiac_drop, tableDir .. 'table/zodiac_drop.txt', 'lv');            --十二宫关卡掉落表
  resTableManager:LoadTable(ResTable.potential_caps, tableDir .. 'table/potential_caps.txt', 'level');        --潜力值表

  resTableManager:LoadTable(ResTable.potential, tableDir .. 'table/potential.txt', 'id');        --潜力值表
  resTableManager:LoadTable(ResTable.tip, tableDir .. 'table/tip.txt', 'id');                    --tip表
  
  resTableManager:LoadTable(ResTable.tutorial_actorOrder, tableDir .. 'table/tutorial_actorOrder.txt', 'id');
  resTableManager:LoadTable(ResTable.tutorial_round, tableDir .. 'table/tutorial_round.txt', 'id');
  resTableManager:LoadTable(ResTable.tutorial_role, tableDir .. 'table/tutorial_role.txt', 'id');
  resTableManager:LoadTable(ResTable.tutorial_monster, tableDir .. 'table/tutorial_monster.txt', 'id');
  
  resTableManager:LoadTable(ResTable.money_shop_buyID, tableDir .. 'table/money_shop.txt', 'id');
  resTableManager:LoadTable(ResTable.money_shop_itemID, tableDir .. 'table/money_shop.txt', 'item_id');
  
  resTableManager:LoadTable(ResTable.recharge_accumulative, tableDir .. 'table/recharge_accumulative.txt', 'id');    --累计充值
  resTableManager:LoadTable(ResTable.recharge_fristtime, tableDir .. 'table/recharge_fristtime.txt', '');
  resTableManager:LoadTable(ResTable.gestureskill, tableDir .. 'table/shoushi.txt', 'id');
  resTableManager:LoadTable(ResTable.gestureskillNoKey, tableDir .. 'table/shoushi.txt', '');
  resTableManager:LoadTable(ResTable.online_reward, tableDir .. 'table/online.txt', 'id');
  resTableManager:LoadTable(ResTable.login_accumulative, tableDir .. 'table/login_accumulative.txt', 'id');
  resTableManager:LoadTable(ResTable.login_count, tableDir .. 'table/login_count.txt', 'login_count');
  resTableManager:LoadTable(ResTable.vip_open, tableDir .. 'table/vip_open.txt', 'id');
  resTableManager:LoadTable(ResTable.talkword, tableDir .. 'table/talkword.txt', 'id');
  
  resTableManager:LoadTable(ResTable.gathering, tableDir .. 'table/gathering.txt', 'id');
  resTableManager:LoadTable(ResTable.gemstone_compose, tableDir .. 'table/gemstone_compose.txt', 'level');
  resTableManager:LoadTable(ResTable.friend_reward, tableDir .. 'table/friend_reward.txt', 'id');

  resTableManager:LoadTable(ResTable.treasure, tableDir .. 'table/treasure.txt', 'id');
  resTableManager:LoadTable(ResTable.treasure_boss, tableDir .. 'table/treasure_boss.txt', 'id_level');
  resTableManager:LoadTable(ResTable.rune_coordinate, tableDir .. 'table/rune_coordinate.txt', 'id');
  resTableManager:LoadTable(ResTable.rune_prob, tableDir .. 'table/rune_prob.txt', 'id');
  resTableManager:LoadTable(ResTable.rune, tableDir .. 'table/rune.txt', 'id');
  --resTableManager:LoadTable(ResTable.rune_exchange, tableDir .. 'table/rune_exchange.txt', 'location');
  resTableManager:LoadTable(ResTable.rune_unlock, tableDir .. 'table/rune_unlock.txt', 'pos');
  resTableManager:LoadTable(ResTable.star_map, tableDir .. 'table/star_map.txt', 'quality');
  resTableManager:LoadTable(ResTable.star, tableDir .. 'table/star.txt', 'id');
  resTableManager:LoadTable(ResTable.invasion, tableDir .. 'table/invasion.txt', 'id');
  resTableManager:LoadTable(ResTable.invasion_boss, tableDir .. 'table/invasion_boss.txt', 'id_level');
  resTableManager:LoadTable(ResTable.invasion_city, tableDir .. 'table/invasion_city.txt', 'id');
  resTableManager:LoadTable(ResTable.invasion_coordinate, tableDir .. 'table/invasion_coordinate.txt', 'id');
  resTableManager:LoadTable(ResTable.invasion_drop, tableDir .. 'table/invasion_drop.txt', 'drop_level');
  resTableManager:LoadTable(ResTable.invasion_prefix, tableDir .. 'table/invasion_prefix.txt', 'id');
  resTableManager:LoadTable(ResTable.level_reward, tableDir .. 'table/level_reward.txt', 'level');
  resTableManager:LoadTable(ResTable.starreward, tableDir .. 'table/starreward.txt', 'id');  
  resTableManager:LoadTable(ResTable.sigh_reward, tableDir .. 'table/sigh_reward.txt', 'id');  
  resTableManager:LoadTable(ResTable.kof_rank_reward, tableDir .. 'table/kof_rank_reward.txt', 'id');
  resTableManager:LoadTable(ResTable.kof_1st_reward, tableDir .. 'table/kof_1st_reward.txt', 'id');
  
  resTableManager:LoadTable(ResTable.passiveSkill, tableDir .. 'table/passiveskill.txt', 'id');
  resTableManager:LoadTable(ResTable.passiveSkillupgrade, tableDir .. 'table/passiveskill_upgrade.txt', 'id');
  resTableManager:LoadTable(ResTable.powerpush, tableDir .. 'table/powerpush.txt', 'pushid');
  resTableManager:LoadTable(ResTable.fp_reward, tableDir .. 'table/fp_reward.txt', 'id');

  resTableManager:LoadTable(ResTable.activity_time, tableDir .. 'table/activity_time.txt', 'id');
  
  resTableManager:LoadTable(ResTable.miku, tableDir .. 'table/miku.txt', 'id');
  resTableManager:LoadTable(ResTable.miku_boss, tableDir .. 'table/miku_boss.txt', 'id_level');
  
  resTableManager:LoadTable(ResTable.destiny, tableDir .. 'table/destiny.txt', 'id');
  resTableManager:LoadTable(ResTable.hero_piece, tableDir .. 'table/hero_piece.txt', 'id');

  resTableManager:LoadTable(ResTable.buff_relation, tableDir .. 'table/buff_relation.txt', 'buff_type');
  resTableManager:LoadTable(ResTable.activity_consume, tableDir .. 'table/activity_consumption.txt', 'id');
  resTableManager:LoadTable(ResTable.daily_pay, tableDir .. 'table/daily_pay.txt', 'id');

  resTableManager:LoadTable(ResTable.zodiac_level, tableDir .. 'table/zodiac_level.txt', 'player_lv');

  resTableManager:LoadTable(ResTable.zodiac_monster, tableDir .. 'table/zodiac_monster.txt', 'level');
  
  resTableManager:LoadTable(ResTable.limit_round, tableDir .. 'table/lmt_battle_round.txt', 'id');
  resTableManager:LoadTable(ResTable.limit_boss, tableDir .. 'table/lmt_battle_boss.txt', 'id_level');
  
  resTableManager:LoadTable(ResTable.guild_bonus_coordinate, tableDir .. 'table/guild_bonus_coordinate.txt', 'id');

  resTableManager:LoadTable(ResTable.wing, tableDir .. 'table/wing.txt', 'id');
  resTableManager:LoadTable(ResTable.wing_compose, tableDir .. 'table/wing_compose.txt', 'id');
  resTableManager:LoadTable(ResTable.wing_activity, tableDir .. 'table/time_wing.txt', 'location');
  resTableManager:LoadTable(ResTable.activity_cfg, tableDir .. 'table/activity_cfg.txt', 'hostnum');
  resTableManager:LoadTable(ResTable.pet, tableDir .. 'table/pet.txt', 'id');
  resTableManager:LoadTable(ResTable.pet_compose, tableDir .. 'table/pet_compose.txt', 'id');
  
  resTableManager:LoadTable(ResTable.achievement, tableDir .. 'table/achievement.txt', 'id');
  resTableManager:LoadTable(ResTable.achievement_name, tableDir .. 'table/achievement_name.txt', 'id');

  resTableManager:LoadTable(ResTable.love_task, tableDir .. 'table/love_task.txt', 'id');
  resTableManager:LoadTable(ResTable.love_reward, tableDir .. 'table/love_reward.txt', 'id');
  resTableManager:LoadTable(ResTable.chapter, tableDir .. 'table/chapter.txt', 'id');
  
  resTableManager:LoadTable(ResTable.navi_effect, tableDir .. 'table/navi_effect.txt', 'id');
  resTableManager:LoadTable(ResTable.navi_event, tableDir .. 'table/navi_event.txt', 'id');
  resTableManager:LoadTable(ResTable.navi_action, tableDir .. 'table/navi_action.txt', 'id');
  resTableManager:LoadTable(ResTable.navi_main, tableDir .. 'table/navi_main.txt', 'roleid');
    resTableManager:LoadTable(ResTable.create_role, tableDir .. 'table/create_role.txt', 'id');
    resTableManager:LoadTable(ResTable.random_name, tableDir .. 'table/random_name.txt', 'id');
  --关卡特效
  resTableManager:LoadTable(ResTable.barrier_effect, tableDir .. 'table/round_effect.txt', 'id');
  resTableManager:LoadTable(ResTable.barrier_effect_switch, tableDir .. 'table/round_effect_switch.txt', 'id');
  
  --卡牌升级表
  resTableManager:LoadTable(ResTable.levelup_attribute, tableDir .. 'table/levelup_attribute.txt', 'id');


  resTableManager:LoadTable(ResTable.npc_shop_buyID, tableDir .. 'table/npc_shop.txt', 'id');
  resTableManager:LoadTable(ResTable.npc_shop_itemID, tableDir .. 'table/npc_shop.txt', 'item_id');
  
  resTableManager:LoadTable(ResTable.sp_shop_buyID, tableDir .. 'table/special_shop.txt', 'id');

  resTableManager:LoadTable(ResTable.title_up, tableDir .. 'table/meritorious.txt', 'id');

  resTableManager:LoadTable(ResTable.daily_sign, tableDir .. 'table/daily_sign.txt', 'id');
  resTableManager:LoadTable(ResTable.expedition, tableDir .. 'table/expedition.txt', 'id');

  resTableManager:LoadTable(ResTable.actor_nokey, tableDir .. 'table/role.txt', '');

  resTableManager:LoadTable(ResTable.item_path, tableDir .. 'table/item_path.txt', 'id');
  resTableManager:LoadTable(ResTable.expedition_shop, tableDir .. 'table/expedition_shop.txt', 'id');
  resTableManager:LoadTable(ResTable.init_equip, tableDir .. 'table/init_equip.txt', 'role_id');
  resTableManager:LoadTable(ResTable.drug, tableDir .. 'table/drug.txt', 'id');

  --bt版处理
  if platformSDK.m_Platform == 'moli' or platformSDK.m_Platform == 'dm' or platformSDK.m_Platform == 'vqs' then	
		resTableManager:LoadTable(ResTable.config, tableDir .. 'table/config_moli.txt', 'id');
  else
		resTableManager:LoadTable(ResTable.config, tableDir .. 'table/config.txt', 'id');
  end

  resTableManager:LoadTable(ResTable.cdkey_reward, tableDir .. 'table/cdkey_reward.txt', 'id');
  resTableManager:LoadTable(ResTable.event, tableDir .. 'table/event.txt', 'id');
  resTableManager:LoadTable(ResTable.event_point, 
                            tableDir .. 'table/event_point.txt', 'id');
  resTableManager:LoadTable(ResTable.event_ranking, 
                            tableDir .. 'table/event_ranking.txt', 'id');
  resTableManager:LoadTable(ResTable.event_role, 
                            tableDir .. 'table/event_role.txt', 'id');
  resTableManager:LoadTable(ResTable.event_round, 
                            tableDir .. 'table/event_round.txt', 'id');
  resTableManager:LoadTable(ResTable.event_difficulty, 
                            tableDir .. 'table/event_difficulty.txt', 'id');
  resTableManager:LoadTable(ResTable.event_reward, 
                            tableDir .. 'table/event_reward.txt', 'id');
  resTableManager:LoadTable(ResTable.event_open, 
                            tableDir .. 'table/event_open.txt', 'id');
  resTableManager:LoadTable(ResTable.soul, 
                            tableDir .. 'table/soul_pursue.txt', 'id');


    resTableManager:LoadTable(ResTable.achievement_task, tableDir .. 'table/achievement_task.txt', 'id');
  resTableManager:LoadTable(ResTable.newly_reward, tableDir .. 'table/newly_reward.txt', 'id');                --开服活动
   resTableManager:LoadTable(ResTable.growup_reward, tableDir .. 'table/growup_reward.txt', 'id');
   resTableManager:LoadTable(ResTable.lmt_reward, tableDir .. 'table/lmt_reward.txt', 'id');
   resTableManager:LoadTable(ResTable.rank_season, tableDir .. 'table/rank_season.txt','id');
    resTableManager:LoadTable(ResTable.rank_season_no_key, tableDir .. 'table/rank_season.txt','');
	resTableManager:LoadTable(ResTable.soul_node, tableDir .. 'table/soul_node.txt','id');
	resTableManager:LoadTable(ResTable.guild_battle_no_key, tableDir .. 'table/guild_battle.txt','');
	resTableManager:LoadTable(ResTable.guild_battle, tableDir .. 'table/guild_battle.txt','id');
	resTableManager:LoadTable(ResTable.guild_battle_building, tableDir .. 'table/guild_battle_building.txt','id');
  --========================================================================
  resTableManager:LoadTable(ResTable.plant_shop, tableDir .. 'table/residence_plantshop.txt','id');
    resTableManager:LoadTable(ResTable.inventory_shop, tableDir .. 'table/inventoryshop.txt','id');
  
	resTableManager:LoadTable(ResTable.kof_reward, tableDir .. 'table/kof_reward.txt','');
  resTableManager:LoadTable(ResTable.open_task, tableDir .. 'table/open_task.txt', 'id');                --开服成长表
  resTableManager:LoadTable(ResTable.artifact, tableDir .. 'table/artifact.txt', 'id');
  resTableManager:LoadTable(ResTable.artifact_levelup, tableDir .. 'table/artifact_levelup.txt', 'id');
    resTableManager:LoadTable(ResTable.guild_shop, tableDir .. 'table/guild_shop.txt', 'id');
  resTableManager:LoadTable(ResTable.rune_shop, tableDir .. 'table/rune_exchange.txt', 'id');
  resTableManager:LoadTable(ResTable.model_change, tableDir .. 'table/model_change.txt', 'role_id');
  resTableManager:LoadTable(ResTable.model_change_nokey, tableDir .. 'table/model_change.txt', '');
  resTableManager:LoadTable(ResTable.pub_show, tableDir .. 'table/pub_show.txt', '');
  resTableManager:LoadTable(ResTable.cardeventshop, tableDir .. 'table/PT_shop.txt', 'id');
  resTableManager:LoadTable(ResTable.skin, tableDir .. 'table/skin.txt', 'id');
  resTableManager:LoadTable(ResTable.pub_info, tableDir .. 'table/pub_info.txt', 'id');
  resTableManager:LoadTable(ResTable.pub_special, tableDir .. 'table/pub_special.txt', 'id');
  resTableManager:LoadTable(ResTable.sweapon, tableDir .. 'table/orderweapon.txt', 'id');


  self:loadRoleNoKey();
  --self:loadTaskNoKey();
  self:loadTaskNoKey__new();
  self:loadBarrierNoKey();
  self:loadPveGroupNoKey();
  self:loadLimitedWordNoKey();
  self:loadMikuNoKey();
  --self:loadWingNoKey();
  self:loadComboCauseAndResultNoKey();
  self:loadTitleUpNoKey();
  self:loadLoginCountNoKey();
  self:loadLevelUpNoKey();
end


--创建未拥有卡牌模板
local properInfo;
function ResTable:createRoleNoHave(resid)
  local role = {};
  properInfo = resTableManager:GetRowValue(ResTable.actor, tostring(resid));  --生命 物攻 技攻 物防 技防   ;
  role.resid = resid;
  role.pid = resid;
  role.lvl = {};
  role.lvl.level = 1;
  role.lvl.lovelevel = 0;
  role.lvl.exp = 0;
  role.lovevalue = 0;
  role.pro = {};
  role.pro.fp   = 100;
  role.skls = {};
  role.stars ={};
  table.insert( role.skls, {resid = properInfo['skill_id'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_id2'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_id3'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_passive'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_passive2'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_auto'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_auto2'] or 0});
  table.insert( role.skls, {resid = properInfo['skill_auto3'] or 0});
  --调整角色
  role.pro.hp  = properInfo['base_hp'];
  role.pro.atk = properInfo['base_atk'];
  role.pro.mgc = properInfo['base_mgc'];
  role.pro.def = properInfo['base_def'];
  role.pro.res = properInfo['base_res'];

 
  role.equips = {}
  local equipsInfo = resTableManager:GetValue(ResTable.init_equip, tostring(resid), 'init_equip');
  for index = 1,5 do
    role.equips[tostring(index)] ={}
    role.equips[tostring(index)].resid = equipsInfo[index];
  end

  --print("--------", role.pro.atk);
  ActorManager:AdjustRole(role);
  --调整角色技能
  ActorManager:AdjustRoleSkill(role);
  --调整经验
  ActorManager:AdjustRoleLevel(role, role.lvl);
  return role;
end

--伙伴升序函数（按职业）
local function CompareAscendingRole( role1, role2 )
  return role1.job < role2.job;
end

--所有的英雄列表
function ResTable:loadRoleNoKey()
  --酒馆英雄排行，避免策划再多配一个表，使用已有的角色表来处理酒馆中英雄的显示
  resTableManager:LoadTable(ResTable.actorNoKey, tableDir .. 'table/role.txt', '');              --角色表无key
  
  local rowNum = resTableManager:GetRowNum(ResTable.actorNoKey);
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  table.insert(AllRolePanel.roleList, {});
  
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.actorNoKey, i-1, {'id', 'name', 'job', 'path', 'img', 'rare', 'handbook'});
    local handbook = rowData['handbook']
    
    if rowData['rare'] > 1 and handbook == 1 then
      --绿蓝紫金
      local role = {};
      role.resid = rowData['id'];
      role.name = rowData['name'];
      role.rare = rowData['rare'];
      role.job = rowData['job'];
      role.path = rowData['path'];
      role.avatarName = rowData['img'];

      table.insert( AllRolePanel.roleList[role.rare - 1], role );
    end
  end
 
  table.sort( AllRolePanel.roleList[1], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[2], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[3], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[4], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[5], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[6], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[7], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[8], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[9], CompareAscendingRole );
  table.sort( AllRolePanel.roleList[10], CompareAscendingRole );
  
  resTableManager:RemoveTable(ResTable.actorNoKey);
end

function ResTable:loadTaskNoKey__new()
  resTableManager:LoadTable(ResTable.task_nokey, tableDir .. 'table/quest.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.task_nokey);
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.task_nokey, i-1, {'id', 'task_class', 'level', 'pre_quest', 'quest_get', 'plot_id', 'type', 'quest_finish', 'finish_plot_id'});
    local task = {};
    task.id = rowData['id'];
    task.class = rowData['task_class'];
    task.level = rowData['level'];
    task.preid = rowData['pre_quest'];
    task.qid = rowData['quest_get'];
    task.plotId = rowData['plot_id'];
    task.type = rowData['type'];
    task.finid = rowData['quest_finish'];
    task.finPlotId = rowData['finish_plot_id'];
    table.insert(Task.allTasks, task);
  end
  resTableManager:RemoveTable(ResTable.task_nokey);
end

--所有关卡列表，根据物品和怪物查找最大开启关卡，用于任务寻路
function ResTable:loadBarrierNoKey()
  resTableManager:LoadTable(ResTable.barriers_nokey, tableDir .. 'table/round.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.barriers_nokey);
  --  扫描关卡，然后获取每关的掉落物品，然后生成掉落物品对应的关卡id的一个map
  for i=1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.barriers_nokey, i-1, {'id', 'item_drop'})
    local roundId = rowData['id']
    local dropItems = rowData['item_drop']
    for index=1,#dropItems do     --  掉落物品表
      local resid = tostring(dropItems[index][1])
      if not self.goodsToRound[resid] then  --  如果当前物品id不在self.goodsToRound的map里，则把其加入,
        self.goodsToRound[resid] = {}
        self.goodsToRound[resid][1] = roundId
      else        --  如果物品之前已经添加则把加入到表末尾
        local len = #self.goodsToRound[resid] + 1
        self.goodsToRound[resid][len] = roundId
      end
    end
  end
    
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.barriers_nokey, i-1, {'id', 'level', 'elite', 'item_drop', 'darwing_drop', 'zodiac_drop', 'initial_monster', 'initial_boss', 'monster', 'boss'});
    local barrier = {};
    barrier.id = rowData['id'];
    barrier.flag = rowData['elite'];       --0为普通，1为精英
    barrier.openLevel = rowData['level'];

    --分为普通关卡，精英关卡和十二宫
    if barrier.id < GlobalData.MaxNormalBarrier then
      barrier.dropItems = rowData['item_drop'];
    elseif  barrier.id < GlobalData.MaxEliteBarrier then
      barrier.dropItems = rowData['darwing_drop'];
    elseif barrier.id < GlobalData.MaxZodiacBarrier then
      barrier.dropItems = resTableManager:GetValue(ResTable.zodiac_drop, tostring(rowData['zodiac_drop']), LANG_resTable_1);
    end
    
    barrier.idleMonster = rowData['initial_monster'];
    barrier.idleBoss = rowData['initial_boss'];
    barrier.monster = rowData['monster'];
    barrier.boss = rowData['boss'];  
    
    --分为普通关卡，精英关卡和十二宫
    if barrier.id < GlobalData.MaxNormalBarrier then
      table.insert(Task.allBarriers, barrier);
    elseif  barrier.id < GlobalData.MaxEliteBarrier then
      table.insert(Material.eliteBarriers, barrier);
    elseif barrier.id < GlobalData.MaxZodiacBarrier then
      table.insert(Material.zodiacBarriers, barrier);
    end
  end  
  resTableManager:RemoveTable(ResTable.barriers_nokey);
end

--初始化合成时原始翅膀和翅膀id关联
function ResTable:loadWingNoKey()
  resTableManager:LoadTable(ResTable.wing_compose_nokey, tableDir .. 'table/wing_compose.txt', '');
  local num = resTableManager:GetRowNum(ResTable.wing_compose_nokey);
    
  for i = 1, num do
    local rowData = resTableManager:GetValue(ResTable.wing_compose_nokey, i-1, {'id', 'former_equip'});
    if WingPanel.baseWingIdMap[rowData['former_equip']] == nil then
      WingPanel.baseWingIdMap[rowData['former_equip']] = rowData['id'];
    end
  end
  
  resTableManager:RemoveTable(ResTable.wing_compose_nokey);
end

--初始化迷窟掉落和碎片关联
function ResTable:loadMikuNoKey()
  resTableManager:LoadTable(ResTable.miku_nokey, tableDir .. 'table/miku.txt', '');
  local num = resTableManager:GetRowNum(ResTable.miku_nokey);
  RoleMiKuPanel.totalRoundPageNum = math.ceil(num / 10) - 1;
  
  for i = 1, num do
    local rowData = resTableManager:GetValue(ResTable.miku_nokey, i-1, {'id', 'piece_name'});
    
    for k, v in pairs( rowData['piece_name'] ) do
      v = tonumber(v);
      
      if v >= ItemIDSection.RoleChipBegin and v <= ItemIDSection.RoleChipEnd then
        local tab;
        if RoleMiKuPanel.item2round[v] == nil then
          tab = {};
          RoleMiKuPanel.item2round[v] = tab;
        else
          tab = RoleMiKuPanel.item2round[v];
        end
        
        table.insert(tab, rowData['id']);
      end
    end
  end
  
  resTableManager:RemoveTable(ResTable.miku_nokey);
end

--初始化精英和十二宫关卡和组的关系
function ResTable:loadPveGroupNoKey()
  resTableManager:LoadTable(ResTable.pveGroup_nokey, tableDir .. 'table/scene_reset.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.pveGroup_nokey);
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.pveGroup_nokey, i-1, {'id', 'scene_id'});
    for _,item in ipairs(rowData['scene_id']) do
      Material.barrierGroupMap[item] = rowData['id'];
    end
  end
  resTableManager:RemoveTable(ResTable.pveGroup_nokey);  
end

--初始化屏蔽字
function ResTable:loadLimitedWordNoKey()
  resTableManager:LoadTable(ResTable.limitedword, tableDir .. 'table/font.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.limitedword);
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.limitedword, i-1, {'name'});
    LimitedWord.words[rowData['name']] = true;
  end
  resTableManager:RemoveTable(ResTable.limitedword);  
end

--初始化combo技的cause result
function ResTable:loadComboCauseAndResultNoKey()
  resTableManager:LoadTable(ResTable.skillNoKey, tableDir .. 'table/skill.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.skillNoKey);
  for i = 1, rowNum do
    local rowData = resTableManager:GetValue(ResTable.skillNoKey, i-1, {'id', 'skill_class', 'combo_cause', 'combo_result'});
    MutipleTeam.skillList[rowData['id']] = rowData;
  end
  resTableManager:RemoveTable(ResTable.skillNoKey);
end

function ResTable:loadTitleUpNoKey()
  resTableManager:LoadTable(ResTable.title_up_no_key, tableDir .. 'table/meritorious.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.title_up_no_key);
  for i = 1, rowNum do
    local data = resTableManager:GetValue(ResTable.title_up_no_key, i-1, {'id', 'meritorious', 'name', 'reward'});
    table.insert(ArenaDialogPanel.titleupdata, data);
  end
  table.sort(ArenaDialogPanel.titleupdata, function(d1, d2) return d1['id'] > d2['id'] end)
  resTableManager:RemoveTable(ResTable.title_up_no_key);
end
--次日奖励表
function ResTable:loadLoginCountNoKey()
  resTableManager:LoadTable(ResTable.login_count_no_key, tableDir .. 'table/login_count.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.login_count_no_key);
  for i = 1, rowNum do
    local data = resTableManager:GetValue(ResTable.login_count_no_key, i-1, {'login_count'});
    table.insert(LoginRewardPanel.loginCount, data);
    table.insert(ActivityAllPanel.loginCount, data);
  end
  table.sort(LoginRewardPanel.loginCount, function(d1, d2) return d1['login_count'] < d2['login_count'] end);
  table.sort(ActivityAllPanel.loginCount, function(d1, d2) return d1['login_count'] < d2['login_count'] end);
  resTableManager:RemoveTable(ResTable.login_count_no_key);
end

function ResTable:loadLevelUpNoKey()
  resTableManager:LoadTable(ResTable.levelup_nokey, tableDir .. 'table/levelup.txt', '');
  local rowNum = resTableManager:GetRowNum(ResTable.levelup_nokey);
  for i = 1, rowNum do
    local data = resTableManager:GetValue(ResTable.levelup_nokey, i-1, {'level'});
    table.insert(PveWinPanel.levelUpData, data);
  end
  table.sort(PveWinPanel.levelUpData, function(d1, d2) return d1['level'] > d2['level'] end);
  resTableManager:RemoveTable(ResTable.levelup_nokey);
end
