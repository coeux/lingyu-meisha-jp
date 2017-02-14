#ifndef _CODE_DEF_H_
#define _CODE_DEF_H_

enum code_type_e
{
    SUCCESS = 0,
    FAILED = 1,
    
    ERROR_NAME_EXIST = 5,

    ERROR_USER_EXCPEL = 10,

    //服务器内部错误码
    ERROR_ILLEGLE_SERVER = 100,
    ERROR_SERVER_HAS_REGISTED,
    ERROR_UNKNOWN_SERVER,            

    //会话码异常
    ERROR_SESKEY_EXCEPTION = 200,
    //当前会话已经失效
    ERROR_SESKEY_TIMEOVER,
    //重复登陆网关
    ERROR_SESKEY_EXISTED,

    //服务器异常
    ERROR_GW_EXCEPTION = 300,
    //更新会话码失败
    ERROR_GW_RESET_SESKEY_FAILED,
    //找不到游戏服务器
    ERROR_GW_NO_SCENE_SERVER,

    //服务器异常
    ERROR_LG_EXCEPTION = 400,
    //非法的mac地址
    ERROR_LG_MAC_ILLEGLE,
    //创建新角色，已经达到最大角色数
    ERROR_LG_ROLE_MAX_NUM,
    //非法的角色表格id
    ERROR_LG_ROLE_RESID,
    //账户不存在
    ERROR_LG_NO_AID,
    //平台验证失败
    ERROR_LG_VERIFY,
    //创建新角色，角色已经存在
    ERROR_LG_ROLE_EXIST,

    //角色不存在
    ERROR_SC_NO_USER        = 500,
    //游戏服务器异常
    ERROR_SC_EXCEPTION,
    //找不到主城
    ERROR_SC_NO_CITY,
    //主城主城中没有当前用户
    ERROR_SC_NO_CITY_USER,
    //没有体力
    ERROR_SC_NO_POWER,
    //无效的请求
    ERROR_SC_ILLEGLE_REQ,
    //元宝不足
    ERROR_SC_NO_YB,
    //友情点不足
    ERROR_SC_NO_FPOINT,
    //金币不足
    ERROR_SC_NO_GOLD,
    //刷新次数不足
    ERROR_SC_NO_FLUSH,
    //没有当前伙伴
    ERROR_SC_NO_PARTNER  = 510,
    //材料不足
    ERROR_SC_NOT_ENOUGH_MATERIAL,
    //活力不足
    ERROR_SC_NO_ENERGY,
    //战历不足
    ERROR_SC_NO_BATTLEXP,
    //技能不存在
    ERROR_SC_NO_SKILL,
    //时间未到
    ERROR_SC_NOT_ENOUGH_TIME,
    //做某个操作的时候，vip等级不足
    ERROR_SC_NOT_ENOUGH_VIP,
    //伙伴数已达上线
    ERROR_PARTNER_MAX_COUNT,
    //英雄进阶已达最高等级
    ERROR_UPGRADE_MAX_LV,
    //体力达到上限
    ERROR_POWER_MAX,
    //声望不足
    ERROR_SC_NO_HONOR = 520,
    //商城限量商品，个数不足
    ERROR_SHOP_LIMIT_OUT,
    //活动已过期
    ERROR_QUEST_OVERDUED,
    //探宝无重置次数
    ERROR_TREASURE_NO_RESET_TIMES,
    //探宝重置次数用完
    ERROR_TREASURE_USE_OUT_RESET_TIMES,
    //英雄系统
    //雇佣英雄时碎片不够
    ERROR_HERO_NOT_ENOUGH_CHIP = 550,
    //雇佣英雄时，该英雄已存在
    ERROR_HERO_EXISTED,
    //物品不存在
    ERROR_NO_ITEM,
    //商店未开放
    ERROR_NO_OPEN_SHOP,
    //限时商店错误
    ERROR_LIMIT_SHOP_ERROR = 560,
    ERROR_NO_LIMIT_ITME,
    ERROR_NO_LIMIT_OPEN,
    ERROR_NO_LIMIT_REWARD,
    ERROR_NOT_ENOUGH_TIMES,
    ERROR_NO_LIMIT_COST,
    ERROR_CARDEVENT_SHOP,


    //好友系统
    //添加好友，自己好友已达上限
    ERROR_SC_FRIEND_MAX_SOURCE = 600,
    //添加好友，对方好友已达上限
    ERROR_SC_FRIEND_MAX_TARGET,
    //不能添加自己为好友
    ERROR_SC_FRIEND_NO_SELF,
    //该玩家已经是你的好友
    ERROR_SC_FRIEND_REDU_ADD,
    //好友助战，已经助战过
    ERROR_SC_ROUND_HELPED,
    //好友助战，达到最大助战次数
    ERROR_SC_ROUND_MAX_HELP,
    //好友邀请，无效的邀请码
    ERROR_SC_ERROR_INVCODE,
    //好友邀请，不能邀请自己
    ERROR_SC_NO_INV_SELF,
    //已经送过花，不能再送
    ERROR_SC_HAD_SENT_FLOWER,
    //兑换花达到上限
    ERROR_SC_FLOWER_USE_LIMIT,
    //已经使用过该鲜花
    ERROR_SC_FLOWER_USED,
    //已填写过邀请码，无法再次填写
    ERROR_SC_NO_INV_FRIEND,

    //新手系统
    //修改名字，名字已存在
    ERROR_SC_NAME_EXISTENCE = 620,
    ERROR_SC_NAME_NULL = 630,
    //精英关剩余次数小于请求的扫荡次数
    ERROR_ELITE_ROUND_SWIPE_TIMES = 640,
    ERROR_ROUND_SWIPE_SERVERAL_VIP_NOT_ENOUGH,
    //卡牌评论
    //已经点过赞了
    ERROR_SC_HAS_PRAISE = 650,
    //没有找到对应的评论
    ERROR_SC_NO_COMMENT,
    //点赞失败
    ERROR_SC_PRAISE_FAILED,
    //发表评论失败
    ERROR_SC_COMMENT_FAILED,
    //福袋奖励
    ERROR_SC_LUCKYBAG_NO_TIMES = 660,
    ERROR_SC_LUCKYBAG_ADD_TIME,
    ERROR_SC_LUCKYBAG_NO_ITEM,

    //训练系统
    //训练场位置未开放
    ERROR_SC_PRACTICE_LOCKED = 700,
    //训练场位置不需要清除cd
    ERROR_SC_PRACTICE_NO_CLEAR,
    //伙伴于主角等级相同，不能训练
    ERROR_SC_PRACTICE_LV_EQUAL,
    //训练场cd
    ERROR_SC_PRACTICE_CD,

    //符文系统
    //无效的符文
    ERROR_RUNE_NO_RESID     = 800,
    //当前符文已经最大等级
    ERROR_RUNE_MAX_LV,
    //符文背包空
    ERROR_RUNE_BAG_EMPTY,
    //符文背包满
    ERROR_RUNE_BAG_FULL,
    //符文碎片不足
    ERROR_RUNE_NO_CHIP,
    //符文位置未解锁
    ERROR_RUNE_POS_LOCK,
    //当前角色等级不足
    ERROR_RUNE_LESS_GRADE,
    //玩家身上已有相同属性的符文
    ERROR_RUNE_DOUBLE_ATTR,
    //已招募五个怪
    ERROR_RUNE_FIVE_BOSS,
    //解雇英雄时，符文背包已满
    ERROR_FIRE_RUNE_BAG_FULL,

    //背包满
    ERROR_BAG_FULL          = 900,
    //没有当前道具
    ERROR_BAG_NO_ITEM,
    //Drug表里没有对应道具
    ERROR_NO_SUCH_DRUG,

    //没有当前装备
    ERROR_EQ_NO_EQ          = 1000,
    //背包中不存在
    ERROR_EQ_IN_BAG, 
    //等级不足
    ERROR_EQ_LOW_LV,
    //无效的部位
    ERROR_EQ_ILLEGLE_PART,
    //无效的职业
    ERROR_EQ_ILLEGLE_JOB,
    //装备升级，金币不足
    ERROR_EQ_LESS_MONEY,
    //无效的装备合成
    ERROR_EQ_ILLEGLE_COMPOSE,
    //缺少材料
    ERROR_EQ_LESS_MATERIAL,
    //等级不足
    ERROR_EQ_LESS_GRADE,
    //已经使用的宝石槽
    ERROR_EQ_USED_GEM_SLOT,
    //无效的宝石槽
    ERROR_EQ_ILLEGLE_GEM_SLOT,
    //无效的宝石属性
    ERROR_EQ_ILLEGLE_GEM_ATTR,
    //没有宝石
    ERROR_EQ_NO_GEM,
    //镶嵌失败
    ERROR_EQ_ILLEGLE_INLAY,
    //卸下宝石水晶不足
    ERROR_UNLAY_LESS_RMB,
    //卸下宝石道具不足
    ERROR_UNLAY_LESS_ITEM,
    //脱下未穿上的装备
    ERROR_EQ_TAKEOFF_UNWEARED,
    //已经装备
    ERROR_EQ_WEAR_EQUIPED,
    //宝石页 没有这一页
    ERROR_NO_SUCH_PAGE,
    //没有这一种类
    ERROR_NO_SUCH_TYPE,
    //没有这个位置
    ERROR_NO_SUCH_POS,

    //关卡
    //进关卡条件不足
    ERROR_ROUND_NO_PERMIT   = 1100,
    //挂机异常
    ERROR_ROUND_NO_HALT, 
    //校验失败
    ERROR_SALT_FAILED,

    //技能
    //升级技能时，技能已达最大等级
    ERROR_SKILL_MAX_LEVEL   = 1200,
    //升阶技能时，技能未达最大等级
    ERROR_SKILL_NO_MAX_LEVEL,
    //技能升阶材料不足
    ERROR_SKILL_NOT_ENOUGH_DRAWING,

    //潜力
    //升级潜能时，潜能已达当前星级的上限
    ERROR_SC_POTENTIAL_CAP  = 1300,
    //升级潜能时，等级未达25级
    ERROR_SC_NOT_ENOUGH_GRADE,

    //BOSS
    //世界boss时，请求进入战斗，但是boss已死
    ERROR_SC_BOSS_DEAD      = 1400,

    ERROR_REPORT_HAVE_NOTIMES = 1410,
    ERROR_REPORT_HAVE_REPORTED = 1411,

    //宝石
    //没有宝石表
    ERROR_GEM_NO_REPO       = 1500,
    //当前宝石不存在
    ERROR_GEM_NO_ITEM,
    //材料不足
    ERROR_GEM_LESS_MATERIAL,
    //保护石不足
    ERROR_GEM_LESS_SAFESTONE,
    //元宝不足
    ERROR_GEM_LESS_RMB,

    //魂师表错误
    ERROR_SOULNODE_INFO     = 1510,
    //魂师资源不足
    ERROR_SOULNODE_MONEY,

    //竞技场
    //购买超出挑战上限
    ERROR_ARENA_BUY_MAX_FIGHTCOUNT = 1600,
    //挑战次数不足
    ERROR_ARENA_NO_FIGHT_COUNT,
    //无效的挑战目标
    ERROR_ARENA_ILLEGLE_TARGET,
    //竞技场奖励不存在
    ERROR_ARENA_NO_REWARD,
    /* 在挑战时间间隔内(冷却中) */
    ERROR_ARENA_IN_COOLING,
    // 该玩家已经正在战斗中,
    ERROR_ARENA_IN_FIGHTING,

    //属性试炼
    ERROR_NOT_ENOUGH_RESET_TIMES = 1650,

    //任务
    //任务已经存在
    ERROR_TASK_HAS_EXISTED = 1700,
    //任务达到上限
    ERROR_TASK_FULL,
    //任务无效接取
    ERROR_TASK_REQ_INVALID,
    //任务不存在
    ERROR_TASK_NOT_EXISTED,
    //任务已经完成
    ERROR_TASK_NOT_FINISHED,

    //日常任务
    //日常任务已经达到当天最大次数
    ERROR_DTASK_MAX_DO = 1750,
    // 数据表中无此任务
    ERROR_DTASK_NO_TASK,
    // 服务器中无此任务
    ERROR_DTASK_SERVER_NO_TASK,
    // 已经完成此任务
    ERROR_DTASK_FINISHED,
    // 每日任务未完成
    ERROR_DTASK_NOT_FINISHED,

    //公会
    ERROR_GANG_HAS_FULL = 1800,
    //会员不存在
    ERROR_GANG_NO_USER,
    //错误的职位
    ERROR_GANG_FLAG,
    //已经是官员
    ERROR_GANG_HAS_ADM,
    //超出官员上限
    ERROR_GANG_MAX_ADM,
    //用户申请不存在
    ERROR_GANG_NO_ADDREQ,
    //错误的操作目标
    ERROR_GANG_OP_TARGET,
    //操作权限不足
    ERROR_GANG_UNABLE_OP,
    //公会等级不足
    ERROR_GANG_LEVEL,
    //公会名已经存在
    ERROR_GANG_NAME_EXIST,
    //用户创建公会等级不足
    ERROR_GANG_CREATE_LESS_LEVEL,
    //用户创建公会金币不足
    ERROR_GANG_CREATE_LESS_GOLD,
    //捐献金币不足
    ERROR_GANG_PAY_LESS_GOLD,
    //无效的捐献
    ERROR_GANG_PAY,
    //关闭公会失败
    ERROR_GANG_CLOSE,
    //公会解锁技能等级不足
    ERROR_GANG_UNLOCK_SKL_LESS_LEVEL,
    //公会贡献值不足
    ERROR_GANG_LESS_GM,
    //用户学习公会技能等级不足
    ERROR_GANG_LEARN_GSKL_LESS_LEVEL,
    //公会不存在
    ERROR_GANG_NO_GANG,
    //献祭次数不足
    ERROR_GANG_LESS_PRAY_NUM,
    //申请公会被拒绝
    ERROR_GANG_REFUSE_ADDREQ,
    //同时申请加入多个公会， 其中一个公会已经同意
    ERROR_GANG_ALREADY_IN_GANG,

    //商城
    //商城的货物id不存在
    ERROR_NO_SHOPID = 1900,
    //出售不存在的装备
    ERROR_SELL_NO_EQUIP,
    //不能出售已经装备的装备
    ERROR_SELL_EQUIPED,
    //出售不存在的道具
    ERROR_SELL_NO_ITEM,

    //DBMID
    ERROR_DB_NO_ACC = 2000,
    ERROR_DB_NO_USER,

    //巨龙宝库
    ERROR_TREASURE_EMPTY_SLOT = 2100,  //该蹲位为空
    ERROR_TREASURE_ROB_ALL,            //该蹲位的打劫次数已满
    ERROR_TREASURE_SLOT_ROBED,         //你已经打劫过该蹲位
    ERROR_TREASURE_HAS_SLOT,           //你已经有蹲位
    ERROR_TREASURE_FULL_SLOT,          //该蹲位不为空
    ERROR_TREASURE_NO_SECONDS,         //你今天的蹲位时间已满
    ERROR_TREASURE_SLOT_CHANGED,       //该蹲位上的人已变化
    ERROR_TREASURE_NO_ROB,             //你今天的打劫次数已满
    ERROR_TREASURE_SLOT_GROWING,       //收割坑位时，尚未成熟
    ERROR_TREASURE_NOT_OPEN,           //不在活动时间段
    ERROR_TREASURE_HELP_SLOT,          //不可占领自己协守的坑位
    ERROR_TREASURE_PVP_FIGHTING,    //其他人正在与矿主战斗
    ERROR_TREASURE_OCCUPY_HELP,       //占领和协守不能同时
    ERROR_TREASURE_OCCUPY_OWN_SLOT,         //不可抢占自己的坑位
    ERROR_TREASURE_ROB_OWN_SLOT,            //不可掠夺自己的坑位

    //序列号
    ERROR_CDKEY_NOT_EXISTED = 2130,
    ERROR_CDKEY_USED,
    ERROR_CDKEY_INPUTED,

    //乱斗场
    ERROR_SCUFFLE_NOT_OPEN = 2140,      // 不在报名时间段
    ERROR_SCUFFLE_NO_REGISTED,          // 没有报名,无权进入
    ERROR_SCUFFLE_TARGET_BATTLE,        // 乱斗场挑战时，对方正在战斗中
    ERROR_SCUFFLE_FULL,                 // 报名人数已满
    ERROR_SCUFFLE_FAIL10,               // 士气为0 不能进乱斗场
    ERROR_USER_HAS_SIGNUP,              // 已报名 不可重复报名
    ERROR_SCUFFLE_LV,                   // 报名等级不足
    ERROR_NO_SUCH_SCUFFLE,              // 该等级乱斗场未开放
    ERROR_SCUFFLE_CLOSE,                // 乱斗场已提前结束
    ERROR_NOT_IN_BATTLE,                // 之前未进行战斗 不能正常结算
    ERROR_SCUFFLE_NOT_FIGHT,            // 不在战斗时间段
    ERROR_NOT_IN_SCUFFLE,               // 不在乱斗场内 不能战斗
    ERROR_LESS_PLAYER,                  // 玩家数量过少 关闭乱斗场
    ERROR_MORE_THAN_MAX_TIMES,          // 超过可进入的最大次数
    ERROR_IDLE_TOO_MUCH,                // 目标太长时间没有活动 自动退出乱斗场
    ERROR_FUHUO,                        // 目标正在复活中 请稍后求战
    ERROR_NO_VIEW_DATA,                 // 没有战斗数据

    //杀星
    ERROR_CITYBOSS_KILLED = 2200,
    ERROR_CITYBOSS_FIGHTMAX = 2201,
    ERROR_CITYBOSS_FIGHTING = 2202,
    ERROR_CITYBOSS_NONE = 2204,

    //关卡星级,星级不足
    ERROR_STARREWARD_NOENOUGH = 2300,

    //鼓舞
    ERROR_GUWU_FAILED = 2400, // 鼓舞失败
    ERROR_GUWU_PROGRESS_HAS_FULL, // 鼓舞进度已满

    //队伍
    ERROR_NO_EXPEDITION_TEAM = 2500,
    ERROR_NO_EXPEDITION_PARTNER,

    /* 远征 */
    ERROR_SC_NO_EXPEDITION_ROUND = 2600,
    ERROR_SC_NO_PASS_EXPEDITION_ROUND,
    ERROR_SC_HAS_BEEN_OPEND,
    ERROR_SC_EXPEDITION_LESS_LEVEL, //远征开启等级不足
    ERROR_SC_NO_EXPEDITION_COIN, // 远征币不足
    ERROR_SC_NOT_ENOUGH_EXPEDITION_SHOP, // 远征商店购买次数不足
    ERROR_CANT_SWEEP, //无法扫荡

    /* 卡牌活动 */
    ERROR_SC_CARD_EVENT_CLOSED = 2700,
    ERROR_SC_CARD_EVENT_ROUND,
    ERROR_SC_CARD_EVENT_ROUND_OPEN,
    ERROR_SC_CARD_EVENT_COIN_NOT_ENOUGH,
    ERROR_SC_CONSUME,
    ERROR_SC_CARD_EVENT_ROUND_UNOPEN,
    ERROR_SC_CARD_EVENT_ROUND_NO_ENEMY,
    ERROR_CARD_EVENT_CANT_SWEEP,
    ERROR_SC_CARD_EVENT_NEXT_NO_MONEY,
    

    /* 每日签到*/
    ERROR_DAILY_TIME_TOO_EARLY = 2800,//补签创建角色前的每日签到
    //DB
    ERROR_DB_EXCEPTION = 3000,



    /*角色切换*/
    ERROR_SC_CHANGEROLE_LV_NOT_ENOUGH = 3100,   //切换角色等级不够
    ERROR_SC_CHANGEROLE_SANME_ROLE,             //角色相同无法切换

    /* 排位赛 */
    ERROR_NO_RANK_SEASON_USER = 3150, //没有这个赛季用户
    ERROR_NO_SUCH_RANK        = 3151, // 没有这个段位

    /* 魂石 */
    ERROR_HAVE_HAD_SOUL = 3200, // 已经有魂石，不能精铸
    ERROR_SOUL_REPO_NULL = 3201, // 表中没有该魂石
    ERROR_HAVE_NO_SOUL = 3202, // 没有魂石 不能追加
    ERROR_NOT_ENOUGH_MONEY = 3203, // 没有足够的金币
    ERROR_NO_16004 = 3204, //没有足够的熔炼券
    ERROR_NOT_ENOUGH_RMB = 3205, //钻石不足

    /* 公会战 */
    ERROR_PERMISSION_DENIED = 3250, // 权限不足，需要会长或干部
    ERROR_NO_SUCH_GANG_USER = 3251, // 公会用户不存在
    ERROR_NOT_IN_SIGH_UP_TIME =  3252, // 不在报名时间段
    ERROR_GBATTLE_GANG_LEVEL = 3253, // 公会等级不足
    ERROR_POS_OCCUPY = 3254, // 上阵时位置已被占据
    ERROR_NOT_THE_OWNER = 3255, // 下阵时并非下属于自己的队伍
    ERROR_POS_MORE_THEN_3 = 3256, // 上阵队伍已经大于等于3个
    ERROR_PID_REPEAT = 3257, // 上阵人员重复
    ERROR_LEVEL_NOT_MATCH = 3258, // 升级等级不匹配
    ERROR_NO_SUCH_GB_REPO = 3259, // 表错误
    ERROR_NO_SUCH_GBB_REPO = 3260, // 表错误
    ERROR_LEVEL_UP_MONEY = 3261, // 升级金钱不足
    ERROR_NO_BUILDING_STATE = 3262,
    ERROR_NO_SUCH_USER = 3263,
    ERROR_FIGHT_STATE = 3264,
    ERROR_DEFENCE_INFO = 3265,
    ERROR_IN_FIGHT_OR_END = 3266,
    ERROR_USER_INFO = 3267,
    ERROR_NO_PARTNER_INFO = 3268,
    ERROR_BUILDING_INFO = 3269,
    ERROR_NO_OPPONENT = 3270,
    ERROR_FIGHT_IN_COOLING = 3271,
    ERROR_FIGHT_NO_TIMES = 3272,
    ERROR_CANT_SPY = 3273,
    ERROR_NO_SUCH_GANG = 3274,
    ERROR_0_SIZE = 3275,
    ERROR_DID_JOIN_FIGHT = 3276,
    ERROR_NOT_IN_ARRANGE = 3277,
    ERROR_NOT_IN_FIGHT = 3278,
    ERROR_CUR_G_B_ISNT_AVAILABLE = 3279,

    /* 宠物 */
    ERROR_HAVE_NO_PET = 3300,
    ERROR_PET_MAT = 3301,
    ERROR_NOT_ENOUGH_PET_MAT = 3302,
    ERROR_LEVEL_MAX = 3303,

    /* combo pro */
    ERROR_COMBOPRO_NO_SUCH_TYPE = 3350,
    ERROR_COMBOPRO_MAX_LEVEL = 3351,
    ERROR_COMBOPRO_NOT_ENOUGH_MAT = 3352,

    /* 招募问题 */
    ERROR_CHIP_ERROR = 3400,
    ERROR_NO_PARTNER = 3401,
    ERROR_PUB_NO_YB = 3402,

    /*开服任务*/
    ERROR_OPENTASK_TIME = 3500, //不在活动时间内
    ERROR_OPENTASK_INFO = 3501,  //该任务不存在
    ERROR_OPENTASK_LIMIT= 3502,  //未满足获取奖励条件

    /*公会商店*/
    ERROR_SC_GANGSHOP_INFO = 3510, //数据异常
    ERROR_SC_GANG_ITEM = 3511,  //没有商品信息
    ERROR_SC_NOT_ENOUGH_GANG_SHOP = 3512, //没有购买次数
    ERROR_GANG_SHOP_LIMIT_OUT = 3513, //公会币不足
    /*符文商店*/
    ERROR_SC_RUNESHOP_INFO = 3514, //数据异常
    ERROR_SC_RUNE_ITEM = 3515,  //没有商品信息
    ERROR_SC_NOT_ENOUGH_RUNE_SHOP = 3516, //没有购买次数
    ERROR_RUNE_SHOP_LIMIT_OUT = 3517, //公会币不足


    /*符文*/
    ERROR_RUNE_REPO = 3600,
    ERROR_RUNE_NOT_ENOUGH_MONEY = 3601,
    ERROR_RUNE_MAP = 3602,
    ERROR_RUNE_PAGE_NUM = 3603,
    ERROR_RUNE_POS = 3604,
    ERROR_RUNE_NO_PAGE = 3605,
    ERROR_RUNE_NO_POS = 3606,
    ERROR_RUNE_HAS_OCCUPY = 3607,
    ERROR_RUNE_HAS_INLAY = 3608,
    ERROR_NOT_ENOUGH_EXP = 3609,
    ERROR_NOT_ACTIVE = 3610,
    ERROR_HAVE_ACTIVE_PARTNER = 3611,
    ERROR_RUNE_MAX_LEVEL = 3612,
    ERROR_RUNE_NO_YB = 3613,

    /*主城形象*/
    ERROR_MODEL_NO_SUCH_MODEL = 3650,
    ERROR_MODEL_NO_PARTNER = 3651,
    ERROR_MODEL_HAVE_NO_SUCH_MODEL = 3652,

    /*反馈返回*/
    ERROR_FEEDBACK_HAD_FEEDBACK = 3700,
    ERROR_SC_FLOWER_UNOPEN = 3701,
};

#endif
