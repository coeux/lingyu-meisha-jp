--network.lua

--========================================================================
--网络类

NetworkCmdType =
	{
		req_rout				= 6000;				--请求网关请求
		ret_rout				= 6001;				--请求网关回复

		req_gw					= 3001;				--网关登陆请求
		ret_gw					= 3002;				--网关登陆回复

		req_new_seskey			= 3004;				--请求新seskey
		ret_new_seskey			= 3005;				--请求新seskey回复

		req_heartbeat			= 3009;				--请求心跳连接
		ret_heartbeat			= 3010;				--返回心跳连接

		req_mac_login			= 2000;				--请求mac登陆
		ret_mac_login			= 2001;				--请求mac登陆回复

		req_gslist				= 3006;				--请求服务器列表
		ret_gslist				= 3007;				--请求服务器列表回复

		req_rolelist			= 2002;				--请求角色列表
		ret_rolelist			= 2003;				--返回角色列表

		req_new_role			= 2004;				--请求创建角色
		ret_new_role			= 2005;				--返回创建角色

		req_del_role			= 2006;				--请求删除角色
		ret_del_role			= 2007;				--返回删除角色

		req_enter_game			= 4000;				--请求进入游戏
		ret_enter_game			= 4001;				--返回进入游戏

		req_user_data			= 4002;				--请求用户数据
		ret_user_data			= 4003;				--返回用户数据

		nt_bag_change			= 4006;				--通知客户端背包改变, 改变的道具和装备

		req_enter_city			= 4007;				--请求进入主城
		ret_enter_city			= 4008;				--返回进入主城

		nt_move					= 4009;				--通知用户移动
		nt_transport			= 4010;				--拉扯用户位置
		nt_user_in				= 4011;				--通知用户进入
		nt_user_out				= 4012;				--通知用户消失

		--老协议
--[[		req_begin_round			= 4013;				--请求进入关卡
		ret_begin_round			= 4014;				--返回请求进入关卡
		nt_end_round			= 4015;				--通知关卡战斗结果--]]

		nt_power_change 		= 4016;				--通知体力改变
		nt_team_change			= 4017;				--通知阵型改变
		nt_levelup				= 4018;				--通知升级
		nt_money_change			= 4019;				--通知金币改变
		nt_rmb_change			= 4020;				--通知水晶改变
		nt_role_pro_change		= 4021;				--通知角色属性改变
		nt_role_pros_change		= 7862;				-- 复数角色属性改变
		nt_exp_change			= 4022;				--通知经验改变

		--老协议
--[[		req_begin_auto_round	= 4023;				--请求挂机
		ret_begin_auto_round	= 4024;				--返回关卡挂机请求

		req_auto_round_resu		= 4025;				--请求一次挂机结果
		ret_auto_round_resu		= 4026;				--返回一次挂机结果
		req_stop_auto_round		= 4027;				--请求结束挂机

		req_flush_round			= 4028;				--请求重置精英关卡
		ret_flush_round			= 4029;				--返回重置精英关卡--]]

		req_wear_equip			= 4030;				--请求穿脱装备
		ret_wear_equip			= 4031;				--返回穿脱装备

		req_upgrade_equip		= 4032;				--请求装备强化
		ret_upgrade_equip		= 4033;				--返回装备强化

		req_compose_equip		= 4034;				--请求装备升阶
		ret_compose_equip		= 4035;				--返回装备升阶
		req_compose_equip_yb	= 4036;				--compose equip

		req_gemstone_compose	= 4037;				--请求合成宝石
		ret_gemstone_compose	= 4038;				--返回合成宝石

		req_gemstone_inlay		= 4039;				--请求镶嵌宝石
		ret_gemstone_inlay		= 4040;				--返回镶嵌宝石

		req_gemstone_inlay_all	= 5400;				--一键镶嵌/卸下
		ret_gemstone_inlay_all  = 5401;

		req_gemstone_syn_all	= 5422;				--一键合成
		ret_gemstone_syn_all	= 5423;

		req_quality_up			= 4043;				--请求伙伴升阶
		ret_quality_up			= 4044;				--返回伙伴升阶
		nt_skill_open			= 4045;				--升阶开放技能

		req_pub_flush_t			= 4046;				--请求刷新酒馆
		ret_pub_flush_t			= 4047;				--返回酒馆信息
		req_enter_pub_t			= 6900;				--请求进入招募
		ret_enter_pub_t			= 6901;				--返回进入招募
		req_pub_time_t			= 5048;				--请求获取免费倒计时
		ret_pub_time_t			= 5049;				--返回获取免费倒计时

		req_gen_power			= 4050;				--请求恢复体力
		ret_gen_power			= 4051;				--返回体力恢复

		--老协议
--[[		req_offline_exp			= 4052;				--请求离线经验--]]

		req_trial_info			= 4053;				--请求试炼场信息
		ret_trial_info			= 4054;				--返回试炼场信息
		req_trial_receive_task	= 4055;				--请求试炼场接任务
		ret_trial_receive_task	= 4056;				--返回试炼场接任务
		req_trial_giveup_task	= 4057;				--请求试炼场放弃任务
		ret_trial_giveup_task	= 4058;				--返回试炼场放弃任务
		req_trial_flush_task	= 4059;				--请求试炼场刷新任务
		ret_trial_flush_task	= 4060;				--返回试炼场刷新任务
		req_trial_start_batt	= 4061;				--请求试炼场开始战斗
		ret_trial_start_batt	= 4062;				--返回试炼场开始战斗
		req_trial_end_batt		= 4063;				--请求试炼场结束战斗
		ret_trial_end_batt		= 4064;				--返回试炼场结束战斗
		req_trial_flush_targets	= 4065;				--请求试炼场刷新对手
		ret_trial_flush_targets	= 4066;				--返回试炼场刷新对手
		nt_energy_change		= 4067;				--通知活力改变
		nt_battlexp_change		= 4068;				--通知战历改变
		req_gen_energy			= 4069;				--请求每小时活力增长
		ret_gen_energy			= 4070;				--返回每小时活力增长

		req_upgrade_skill		= 4071;				--请求升级技能
		ret_upgrade_skill		= 4072;				--返回升级技能

		req_upnext_skill		= 4073;				--请求技能升阶
		ret_upnext_skill		= 4074;				--返回技能升阶

		req_trial_rewards		= 4075;				--请求试炼场领取奖励
		ret_trial_rewards		= 4076;				--返回试炼场领取奖励

		nt_chip_change			= 4077;				--通知客户端英雄碎片改变

		req_arena_info			= 4080;				--请求竞技场信息
		ret_arena_info			= 4081;				--返回竞技场信息
		req_begin_arena_fight	= 4082;				--请求挑战
		ret_begin_arena_fight	= 4083;				--返回挑战信息
		req_arena_rank_page		= 4084;				--请求竞技场页面
		ret_arena_rank_page		= 4085;				--返回请求竞技场页面
		req_end_arena_fight		= 4088;				--请求竞技场战斗结果
		ret_end_arena_fight		= 4089;				--返回竞技场战斗结果
		-- req_arena_reward_countdown		= 4086;		--请求竞技场奖励的剩余时间
		-- ret_arena_reward_countdown		= 4087;		--返回竞技场奖励的剩余时间
  	req_buy_fight_count		= 4090;				--购买竞技场挑战次数
		ret_buy_fight_count		= 4091;				--返回竞技场购买结果
		req_arena_clear_time = 5389; -- 请求清除竞技场冷却时间
		ret_arena_clear_time = 5390;

		req_view_user_info		= 4100;				--查看其他用户信息
		ret_view_user_info		= 4101;				--返回查看其他用户信息

		req_potential_up		= 4112;				--请求升级潜能
		ret_potential_up		= 4113;				--返回升级潜能

		nt_fpoint_change		= 4114;				--通知友情点改变

		nt_msg_push				= 4115;				--消息推送

		req_fire_partner		= 4116;				--请求解雇伙伴
		ret_fire_partner		= 4117;				--返回解雇伙伴

		--老协议
--[[		req_begin_auto_zodiac	= 4118;				--请求十二宫挂机
		ret_begin_auto_zodiac	= 4119;				--返回十二宫挂机

		req_auto_zodiac_resu	= 4220;				--请求一次十二宫挂机结果
		ret_auto_zodiac_resu	= 4221;				--返回一次挂机结果--]]

		req_boss_state           = 4222;				--请求Boss状态
		ret_boss_state           = 4223;				--返回Boss状态
		req_boss_start_batt      = 4224;				--请求Boss战斗
		ret_boss_start_batt      = 4225;				--返回Boss战斗
		ret_boss_start_batt_fail = 4225;				--返回boss战斗失败
		req_boss_end_batt        = 5373;
		ret_boss_end_batt        = 5374;
		nt_boss_go               = 4226;				--boss消失

		req_dmg_ranking			= 4227;				--请求伤害排名
		ret_dmg_ranking			= 4228;				--返回伤害排名

		req_boss_leave_scene	= 4229;				--请求离开场景
		ret_boss_leave_scene	= 4230;				--

		nt_chart				= 4231;				--聊天
		nt_event_general 		= 4232;				--事件公告系统
		nt_event_arena 			= 4232;
		nt_event_gemstone 		= 4232;
		req_mail_info 			= 4233;				--玩家上线获取离线期间产生的信封
		ret_mail_info 			= 4234;

		nt_pushinfo				= 4235;				--消息推送

		req_chat_info			= 4236;				--离线聊天信息
		ret_chat_info			= 4237;
		
		nt_union_boss_open      = 4238;

		req_open_pack			= 4300;				--打开礼包
		ret_open_pack			= 4301;				--返回打开礼包

		nt_dmg_ranking			= 4304;				--全服通告伤害排名

		req_friend_search_uid	= 4338;				--根据UID寻找好友
		req_friend_search		= 4340;				--寻找好友
		ret_friend_search		= 4341;				--返回寻找好友
		req_friend_add			= 4342;				--添加好友
		ret_friend_add			= 4343;				--服务器返回添加好友请求结果
		nt_friend_beenadd		= 4344;				--新的好友请求
		req_friend_add_res		= 4345;				--同意或拒绝好友请求
		ret_friend_add_res		= 4339;				--返回同意或拒绝好友
		req_friend_del			= 4346;				--请求删除好友
		ret_friend_del			= 4347;				--返回删除好友
		req_friend_helpbattle	= 4350;				--请求更换助战英雄
		ret_friend_helpbattle   = 4351;				--返回更换助战英雄
		req_friend_list			= 4352;				--请求好友列表
		ret_friend_list			= 4353;				--返回好友列表
		nt_friend_olchange		= 4354;				--好友在线变化
		nt_friend_hbchange		= 4355;				--好友助战英雄变化
		nt_friend_addone		= 4356;				--好友增加
		nt_friend_delone		= 4357;				--好友删除
		req_friend_addlist		= 4358;				--请求好友申请列表
		ret_friend_addlist		= 4359;				--返回好友申请列表
		req_send_flower			= 5402;				--送花
		ret_send_flower			= 5403;				--送花返回
		req_receive_flower		= 5404;				--收花
		req_receive_all			= 5405;				--收所有花
		ret_receive_flower		= 5406;				--接受鲜花返回
		req_flower_list			= 5407;				--请求鲜花列表
		ret_flower_list			= 5408;				--接受鲜花列表
		nt_receieve_flower		= 5409;				--接受鲜花通知
		req_change_default_team = 5450;				--通知改变默认队伍
		req_remove_team			= 5451;				--通知移除队伍
		nt_change_team_name		= 5452;				--通知改变队伍名称


		nt_reward				= 4360;				--活动通知
		req_reward				= 4361; 			--申请活动奖励
		ret_reward				= 4362;				--返回申请活动奖励
		nt_reward_partner		= 4363;				--活动系统奖励一个伙伴

		req_helphero_stranger	= 4364;				--好友助战系统，申请陌生人信息
		ret_helphero_stranger	= 4365;				--返回好友助战系统，申请陌生人信息

		req_lg_rewardinfo		= 4366;				--请求累积登录奖励
		ret_lg_rewardinfo		= 4367;				--返回累积登录奖励
		req_friend_battle		= 4368;				--请求好友挑战
		ret_friend_battle		= 4369;				--返回好友挑战

		req_role_pro			= 4370;				--请求伙伴属性信息
		ret_role_pro			= 4371;				--返回伙伴属性信息

		nt_quit_step			= 4374;				--通知服务器退出阶段

		--巨龙宝库
		req_treasure_floor     = 4375; -- 巨龙宝库获取某一层的信息
		ret_treasure_floor     = 4376; -- 服务器返回巨龙宝库获取某一层的信息
		req_treasure_enter     = 4377; -- 巨龙宝库进入战斗
		ret_treasure_enter     = 4378; -- 服务器返回巨龙宝库进入战斗
		req_treasure_exit      = 4379; -- 巨龙宝库结束战斗
		ret_treasure_exit      = 4380;
		req_treasure_pass      = 4381; -- 巨龙宝库一键登塔
		ret_treasure_pass      = 4382;
		req_treasure_occupy    = 4383; -- 巨龙宝库占领空位
		ret_treasure_occupy    = 4384;
		req_treasure_fight     = 4385; -- 巨龙宝库抢占蹲位
		ret_treasure_fight     = 4386;
		req_treasure_rob       = 4387; -- 巨龙宝库打劫
		ret_treasure_rob       = 4388;
		req_treasure_rob_end   = 5375;
		ret_treasure_rob_end   = 5376;
		req_treasure_fight_end = 5269;   --  巨龙宝库抢占
		ret_treasure_fight_end = 5270;
		nt_treasure_profit     = 5388;
		req_treasure_giveup    = 4389; -- 巨龙宝库放弃坑位
		ret_treasure_giveup    = 4390;
		nt_treasure_kick_out   = 4391; -- 巨龙宝库被踢出坑位
		req_treasure_slot_rewd = 4392; -- 巨龙宝库领取坑位奖励
		ret_treasure_slot_rewd = 4393;
		req_secs_to_zero       = 4394;
		ret_secs_to_zero       = 4395;
		req_treasure_rcds      = 4396; -- 请求巨龙宝库战斗记录
		ret_treasure_rcds      = 4397;
		req_treasure_revenge   = 4398; -- 请求复仇列表
		ret_treasure_revenge   = 4399; -- 服务器返回复仇列表

		req_treasure_reset     = 5500; --  探宝重置
		ret_treasure_reset     = 5501;
		req_change_name        = 5502; --  改名功能
		ret_change_name        = 5503;
		req_arena_cool_down    = 5504;
		ret_arena_cool_down    = 5505;
		req_treasure_give_occupy = 5506;
		ret_treasure_give_occupy = 5507;
		req_treasure_giveup_help = 5508;
		ret_treasure_giveup_help = 5509;
		req_set_kanban_role		= 5510;
		ret_set_kanban_role		= 5511;
		req_open_service_reward = 5512;
		ret_open_service_reward = 5513;
		req_buy_growing_package = 5514;
		ret_buy_growing_package = 5515;
		req_comment_card		= 5516;
		ret_comment_card		= 5517;
		req_newest_card_comment	= 5518;
		ret_newest_card_comment	= 5519;
		req_index_role_info		= 5520;				--请求玩家的某个角色的属性
		ret_index_role_info		= 5521;
		req_praise_comment 		= 5522; 			--给评论点赞
		ret_praise_comment 		= 5523; 			
		req_get_luckybag_reward	= 5524;				--领取福袋奖励
		ret_get_luckybag_reward	= 5525;
		req_pvelose_times		= 5526;				--pve战斗失败次数
		ret_pvelose_times		= 5527;
		nt_recharge_activity	= 5528;				--累计充值
		nt_daily_draw_activity	= 5529;				--每日抽卡
		nt_daily_power_activity	= 5530;				--每日体力
		nt_melting_activity		= 5531;				--熔炼活动
		nt_talent_activity		= 5532;				--天赋活动
		req_get_weekly_reward	= 5533;				--请求获得周礼包奖励
		ret_get_weekly_reward	= 5534;
		req_get_online_reward	= 5535;				--请求获得在线礼包奖励
		ret_get_online_reward 	= 5536;
		nt_single_activity		= 5537;
		req_get_midaut_reward   = 5538;				--请求中秋活动奖励
		ret_get_midaut_reward   = 5539;				--中秋活动奖励回调
		--任务
		req_task_list          = 4400; -- 请求任务列表(包含主线和支线)
		ret_task_list          = 4401; -- 返回任务列表
		req_get_task           = 4402; -- 请求获得任务
		ret_get_task           = 4403; -- 获得任务成功与否
		req_commit_task        = 4404; -- 请求提交任务
		ret_commit_task        = 4405; -- 提交任务成功与否

		--老协议
--[[		req_abort_task			= 4406;				--请求放弃任务
		ret_abort_task			= 4407;				--放弃任务成功与否--]]

		req_finished_bline		= 4408;				--请求已经完成的支线任务
		ret_finished_bline		= 4409;				--返回已经完成的支线任务
--[[ 老协议
		req_daily_task_list    = 4410;				--请求日常任务列表
		ret_daily_task_list    = 4411;				--返回日常任务列表
		req_commit_daily_task  = 4412;				--请求提交日常任务
		ret_commit_daily_task  = 4413;				--提交日常任务成功与否
		req_buy_daily_task_num = 4414;				--请求购买刷新日常任务数
		ret_buy_daily_task_num = 4415;				--购买刷新日常任务数成功与否
--]]
		nt_task_change			= 4420;				--通知主支线任务状态变化

		req_practice_info		= 4500;				--请求训练场信息
		ret_practice_info		= 4501;				--返回训练场信息
		req_practice_partner	= 4502;				--请求训练伙伴
		ret_practice_partner	= 4503;				--返回训练伙伴
		req_practice_clear		= 4504;				--清除训练场冷却cd
		ret_practice_clear		= 4505;				--返回清除训练场cd

		req_rune_info			= 4508;				--请求符文怪物信息
		ret_rune_info			= 4509;				--返回符文怪物信息
		req_rune_switchpos		= 4510;				--请求吞噬符文或者移动符文
		ret_rune_switchpos		= 4511;				--返回吞噬符文或者移动符文
		req_rune_eatall			= 4512;				--请求吞噬背包内所有符文
		ret_rune_eatall			= 4513;				--返回吞噬背包内所有符文
		req_rune_huntsome		= 4514;				--请求猎一个魔
		ret_rune_huntsome		= 4515;				--返回猎一个魔
		nt_rune_change			= 4521;				--通知符文增删
		req_rune_callboss		= 4522;				--请求召唤魔王
		ret_rune_callboss		= 4523;				--返回召唤魔王
		nt_runechip_change		= 4524;				--通知符文碎片改变
		req_rune_buy			= 4525;				--请求购买符文
		ret_rune_buy			= 4526;				--返回购买符文
		req_rune_close			= 4527;				--请求关闭符文界面
		ret_rune_close			= 4528;				--返回关闭符文界面

		req_guidence_partner	= 4551;				--请求新手系统奖励伙伴
		ret_guidence_partner	= 4552;				--返回新手系统奖励伙伴
		req_guidence_rename		= 4553;				--请求新手系统设置角色名
		ret_guidence_rename		= 4554;				--返回新手系统设置角色名
--[[		req_guidence_gemstone	= 4555;			 	--请求新手系统奖励宝石
		ret_guidence_gemstone	= 4556;			 	--返回新手系统奖励宝石--]]
		req_guidence_pub		= 4559;				--请求新手系统酒馆
		ret_guidence_pub		= 4560;				--返回新手系统酒馆
--[[		req_guidence_refine		= 4561;				--请求新手系统精灵洗礼
		ret_guidence_refine		= 4562;				--返回新手系统精灵洗礼--]]
		req_invcode				= 4570;				--请求获得邀请码及邀请好友情况
		ret_invcode				= 4571;				--返回获得邀请码及邀请好友情况
		req_invcode_set			= 4572;				--请求输入邀请码
		ret_invcode_set			= 4576;				--返回输入邀请码结果
		req_invcode_reward		= 4574;				--请求领取邀请码奖励
		ret_invcode_reward		= 4575;				--返回领取邀请码奖励
		req_write_guidence		= 4577;				--请求记录完成新手引导状态
		ret_write_guidence		= 4578; 			--返回记录完成新手引导状态

		req_boss_alive 			= 4579;				--获取boss死活
		ret_boss_alive			= 4580;
		req_open_union_boss		= 4581;
		ret_open_union_boss		= 4582;


		req_create_gang			= 4600;				--请求创建公会
		ret_create_gang			= 4601;				--返回创建请求
		req_add_gang			= 4602;				--申请加入公会
		ret_add_gang			= 4603;				--返回申请结果
		req_gang_reqlist		= 4604;				--请求工会申请列表
		ret_gang_reqlist		= 4605;				--返回申请列表
		nt_add_gang_res			= 4606;				--同志加入公会
		req_gang_mem			= 4607;				--请求公会会员列表
		ret_gang_mem			= 4608;				--返回公会会员请求
		req_deal_gang_req		= 4609;				--处理公会申请
		ret_deal_gang_req		= 4610;				--返回处理结果
		req_kick_mem			= 4611;				--请求踢人
		ret_kick_mem			= 4612;				--返回踢人结果
		req_set_adm				= 4613;				--请求设置官员
		ret_set_adm				= 4614;				--返回设置官员结果
		req_set_notice			= 4615;				--请求设置公告
		ret_set_notice			= 4616;				--返回设置公告请求
		req_close_gang			= 4617;				--请求解散工会
		ret_close_gang			= 4618;				--返回解散公会结果
		nt_gang_msg				= 4619;				--公会留言
		req_set_gang_boss_time	= 4620;				--设置公会boss时间
		ret_set_gang_boss_time	= 4621;				--返回公会时间
		nt_gang_boss_time		= 4622;				--通知公会boss时间改变
		req_gang_info			= 4650;				--请求公会信息
		ret_gang_info			= 4651;				--服务器返回公会信息
		req_gang_list			= 4652;				--请求公会列表
		ret_gang_list			= 4653;				--返回请求公会列表
		req_learn_gskl			= 4654;				--学习公会技能
		ret_learn_gskl			= 4655;				--返回学习结果
		req_gang_pay			= 4656;				--公会捐献
		ret_gang_pay			= 4657;				--返回捐献结果
		req_gang_pray			= 4658;				--公会祭祀
		ret_gang_pray			= 4659;				--返回公会祭祀
		req_search_gang			= 4660;				--查找工会
		ret_search_gang			= 4661;				--返回查找结果
		nt_gang_level_change	= 4662;				--通知公会等级改变
		nt_gang_pay_change		= 4663;				--通知个人贡献改变
		nt_gang_exp_change		= 4664;				--通知公会经验改变
		req_gskl_list			= 4665;				--请求公会技能列表
		ret_gskl_list			= 4666;				--返回请求的公会技能列表
		nt_gskl_lv_change		= 4667;				--通知公会技能等级改变
		req_leave_gang			= 4668;				--请求离开公会
		ret_leave_gang			= 4669;				--返回退出公会结果
		req_change_charman		= 4670;				--改变会长
		ret_change_charman		= 4671;				--返回改变会长结果
		req_enter_pray			= 4672;				--请求进入祭坛
		ret_enter_pray			= 4673;				--返回请求进入祭坛的结果
		nt_gang_req				= 4674;				--推送公会申请通知

		--战斗新协议，原来协议作废
		req_round_enter 		= 4680;				--请求进入关卡
		req_elite_enter 		= 4681;				--请求进入精英关卡
		req_elite_reset			= 5453;				--请求重置精英关卡
		ret_elite_reset			= 5454;				--返回重置精英关卡
		req_zodiac_enter 		= 4682;				--请求进入十二宫关卡
		ret_round_enter 		= 4683;				--进入关卡返回，包括普通关卡，精英关卡，十二宫关卡
		req_round_exit  		= 4684;				--结束普通关卡
		req_elite_exit 			= 4685;				--结束精英关卡
		req_zodiac_exit 		= 4686;				--结束黄道十二宫
		ret_round_exit 			= 4687;				--服务器返回结束关卡
		req_zodiac_pass 		= 4688;				--请求十二宫挂机
		ret_zodiac_pass 		= 4689;				--
		req_round_flush 		= 4690;				--请求刷新精英关卡和黄道十二宫关卡
		ret_round_flush 		= 4691;

		req_round_pass 			= 4692;				--请求普通关卡挂机
		ret_round_pass 			= 4693;				--返回普通关卡挂机
		req_round_pass_new		= 4696;				--请求普通关卡挂机(新)
		req_round_pass_clear_cd = 4694;				--请求清除普通关卡挂机cd
		ret_round_pass_clear_cd = 4695;				--返回清除普通关卡挂机cd

		up_team_pro				= 4700;				--请求更新队伍属性数据
		nt_kick_gang			= 4701;				--收到被踢出公会的通知

		req_shop_buy			= 4801;				--购买商品
		ret_shop_buy			= 4802;				--返回购买结果

		req_shop_items			= 4803;				--申请商城数据
		ret_shop_items			= 4804;				--返回商城数据

		req_npc_shop_items		= 4860;				--申请npc商城数据
		ret_npc_shop_items		= 4861;				--返回npc商城数据

		req_npcshop_buy			= 4862;				--购买npc商店商品
		ret_npcshop_buy			= 4863;				--返回购买npc商品结果

		req_npcshop_refresh 	= 4864;				--npc商店刷新
		ret_npcshop_refresh		= 4865;				--返回npc商店刷新结果

		req_buy_coin			= 4810;				--请求炼金
		ret_buy_coin			= 4811;				--返回炼金

		nt_vip_levelup			= 4820;				--vip等级改变
		nt_vip_exp_changed		= 4821;				--vip经验改变

		req_sell				= 4830;				--出售
		ret_sell				= 4831;				--返回出售结果

		--[[
		req_rank_reward			= 4840;				--请求排名奖励信息
		ret_rank_reward			= 4841;				--返回排名奖励信息
		req_given_rank_reward	= 4842;				--请求领取竞技场奖励
		ret_given_rank_reward	= 4843;				--返回领取竞技场奖励
		--]]

		req_given_power_reward	= 4844;				--请求领取体力奖励
		ret_given_power_reward	= 4845;				--返回领取体力奖励

		req_given_vip_reward_t	= 4846;				--请求vip升级奖励
		ret_given_vip_reward_t	= 4847;				--返回vip升级奖励

		req_fp_reward			= 4848;				--请求领取战斗力冲刺活动奖励
		ret_fp_reward			= 4849;				--返回领取战斗力冲刺活动奖励

		req_reward_power_cd		= 4854;				--请求领取体力奖励剩余时间
		ret_reward_power_cd		= 4855;				--返回领取体力奖励剩余时间


		req_buy_vip_info		= 4900;				--请求vip购买信息
		ret_buy_vip_info		= 4901;				--返回vip购买信息

		req_buy_power			= 4902;				--请求购买体力
		ret_buy_power			= 4903;				--返回购买体力

		req_buy_energy			= 4904;				--请求购买活力
		ret_buy_energy			= 4905;				--返回活力购买结果

		req_random_name			= 4906;				--请求一个随机名字
		ret_random_name			= 4907;				--返回一个随机名字

		req_online_reward_cd	= 4910;				--请求在线奖励cd
		ret_online_reward_cd	= 4911;				--返回在线奖励cd
		req_online_reward		= 4912;				--请求在线奖励
		ret_online_reward		= 4913;				--返回在线奖励
		req_online_reward_num	= 4914;				--请求在线奖励次数
		ret_online_reward_num	= 4915;				--返回在线奖励次数

		req_quit_game_t			= 4920;				--请求离开游戏
		ret_quit_game_t			= 4921;				--返回离开游戏

		req_login_yb              = 4922; -- 请求领取登陆奖励
		ret_login_yb              = 4923; -- 返回领取登陆奖励

		req_buy_yb                = 4990; -- 请求购买元宝
		ret_buy_yb                = 4991; -- 返回购买元宝
		req_yb_repo               = 4993; -- 请求购买元宝表
		ret_yb_repo               = 4994; -- 返回购买元宝表

		req_buy_bag_cap           = 5000; -- 购买背包格子
		ret_buy_bag_cap           = 5001; -- 返回背包格子购买结果

		req_city_boss_info_t      = 5010; -- boss信息
		ret_city_boss_info_t      = 5011; -- 返回boss信息
		req_fight_city_boss       = 5012; -- 向服务器发送杀星战斗结果
		ret_fight_city_boss       = 5013; -- 服务器返回杀星战斗的奖励
		req_begin_fight_city_boss = 5014; -- 请求杀星战斗开始
		ret_begin_fight_city_boss = 5015; -- 服务器返回杀星战斗
		nt_city_boss_state_t      = 5016; -- 杀星boss状态

		req_star_open_t           = 5020; -- 开星槽
		ret_star_open_t           = 5021; -- 开星槽返回结果
		req_star_flush_t          = 5022; -- 刷星槽
		ret_star_flush_t          = 5023; -- 刷星槽返回结果

		req_lv_reward             = 5024; -- 请求等级奖励
		ret_lv_reward             = 5025; -- 返回等级奖励
		req_star_set_t            = 5026; -- 请求刷星
		ret_star_set_t            = 5027; -- 返回刷星
		req_star_get_t            = 5028; -- 请求设置刷星
		ret_star_get_t            = 5029; -- 返回设置刷星

		req_compose_drawing_t     = 5030; -- 图纸合成
		ret_compose_drawing_t     = 5031; -- 图纸合成结果

		req_starreward            = 5040; -- 请求领取关卡星级奖励
		ret_starreward            = 5041; -- 返回领取关卡星级奖励
		req_starreward_info       = 5042; -- 请求关卡星级信息
		ret_starreward_info       = 5043; -- 返回关卡星级信息

		nt_function_t			= 5044;				--功能开启

		req_cdkey_reward		= 5055;				--领取序列号奖励
		ret_cdkey_reward		= 5056;				--
		
		req_scuffle_regist		= 5060;				--乱斗场报名
		ret_scuffle_regist		= 5061;
		req_scuffle_leave_scene	= 5062;				--请求离开乱斗场
		ret_scuffle_leave_scene	= 5063;				--返回离开乱斗场
		req_scuffle_battle		= 5064;				--请求乱斗场进入战斗
		ret_scuffle_battle		= 5065;				--返回乱斗场进入战斗
		req_scuffle_battle_end	= 5067;				--请求乱斗场战斗结束
		ret_scuffle_battle_end	= 5068;				--返回乱斗场战斗结束
		nt_scuffle_hero_in		= 5069;				--通知乱斗场角色出现
		nt_scuffle_hero_change	= 5070;				--通知乱斗场角色状态改变
		req_scuffle_ranking		= 5071;				--请求乱斗场积分排名
		ret_scuffle_ranking		= 5072;				--返回乱斗场积分排名
		nt_scuffle_end			= 5073;				--通知乱斗场结束
		req_scuffle_state		= 5074;				--请求获取乱斗场状态
		ret_scuffle_state		= 5075;				--返回乱斗场状态
		req_cumulogin_reward_t	= 5078;				--请求累计登录奖励
		ret_cumulogin_reward_t	= 5079;				--返回累计登录奖励

		nt_payyb_change			= 5080;				--玩家成功充值多少水晶
		nt_conlogin_hero_t		= 5081;				--领取金色英雄

		req_fp_rank_t			= 5082;				--请求战斗力排行榜
		ret_fp_rank_t			= 5083;				--返回战斗力排行榜
		req_lv_rank_t			= 5084;				--请求等级排行榜
		ret_lv_rank_t			= 5085;				--返回等级排行榜
		req_arena_rank 			= 5088;				--请求竞技场排名
		ret_arena_rank			= 5089;				--返回竞技场排名
		nt_score_ranking		= 5090;				--全服通告乱斗场积分排名
		req_use_item_t			= 5100;				--请求使用道具
		ret_use_item_t			= 5101;				--请求使用道具的结果
		req_union_rank			= 5091;				--请求公会排行榜
		ret_union_rank			= 5092;				--返回公会排行榜
		req_card_rank			= 5093;				--请求卡牌排行榜
		ret_card_rank			= 5094;				--返回卡牌排行榜

		req_mcard_info			= 5110;				--请求月卡信息
		ret_mcard_info			= 5111;				--返回月卡信息
		req_mcard_reward		= 5112;				--请求领取月卡奖励
		ret_mcard_reward		= 5113;				--返回月卡奖励
		nt_mcard_info			= 5114;				--通知月卡信息改变

		req_hire_partner		= 5200;				--请求雇佣伙伴
		ret_hire_partner		= 5201;				--返回雇佣伙伴
		req_chip_to_soul		= 5202;				--请求碎片兑换灵能
		ret_chip_to_soul		= 5203;				--返回碎片兑换灵能

		req_cave_enter			= 5220;				--请求进入迷窟
		ret_cave_enter			= 5221;				--返回进入迷窟
		req_cave_exit			= 5222;				--请求退出迷窟
		ret_cave_exit			= 5223;				--返回退出迷窟
		nt_soul_change			= 5224;				--通知灵能改变
		req_cave_pass			= 5225;				--请求迷窟挂机
		ret_cave_pass			= 5226;				--返回迷窟挂机
		req_cave_flush			= 5227;				--请求重置迷窟挂机
		ret_cave_flush			= 5228;				--返回重置迷窟挂机
		req_cave_pass_clear_cd	= 5229;				--请求清除迷窟关卡挂机cd
		ret_cave_pass_clear_cd	= 5230;				--返回清除迷窟关卡挂机cd
		nt_honor_change_t		= 5231;				--通知荣誉点的变化
		nt_unhonor_change_t		= 5209;				--通知跨服荣誉点的变化
		nt_first_pay			= 5232;				--通知首冲状态
		req_cumu_yb_reward_t	= 5235;				--请求累计消费奖励
		ret_cumu_yb_reward_t	= 5236;				--返回累计消费奖励
		req_daily_pay_reward_t	= 5237;				--请求每日充值奖励
		ret_daily_pay_reward_t	= 5238;				--返回每日充值奖励
		nt_daily_pay_t			= 5239;				--通知充值状态

		req_cumu_yb_rank = 5247; -- 请求累计消费排行榜
		ret_cumu_yb_rank = 5248; -- 返回累计消费排行榜
		nt_mcard_event_t = 5249; -- 通知年卡

		req_gmail_list   = 5241; -- 请求邮件列表
		ret_gmail_list   = 5242; -- 返回邮件列表
		req_gmail_reward = 5243; -- 请求领取邮件奖励
		ret_gmail_reward = 5244; -- 返回领取邮件奖励
		nt_gmail_readed  = 5245; -- 客户端通知邮件已读
		nt_new_gmail     = 5246; -- 通知新邮件到达
		req_gmail_delete = 5271; -- 请求删除邮件
		ret_gmail_delete = 5272; -- 返回删除邮件
		req_getallreward = 5273; -- 请求领取所有奖励
		ret_getallreward = 5274; -- 返回所有奖励结果
		nt_delete_gmail  = 5250; -- 删除所有邮件

		-----------------------------------------------------------------
		--新协议
		--
		--编年史
		req_chronicle               = 5252; -- 请求编年史信息（月）
		ret_chronicle               = 5253; -- 返回编年史信息（月）
		req_chronicle_sign          = 5254; -- 请求编年史签到
		ret_chronicle_sign          = 5255; -- 返回编年史签到结果
		nt_chronicle_sum_change     = 5256; -- 通知签到的编年史总天数变化
		req_chronicle_sign_retrieve = 5257; -- 编年史记录找回
		ret_chronicle_sign_retrieve = 5258; -- 返回记录
		req_chronicle_sign_all      = 5259; -- 请求所有编年史签到记录
		ret_chronicle_sign_all      = 5260; -- 返回所有编年史签到记录
		--
		--爱恋度
		req_love_task_list          = 5261; -- 请求所有卡牌爱恋度任务
		ret_love_task_list          = 5262; -- 返回爱恋度进度信息
		req_commit_love_task        = 5263; -- 请求完成爱恋度任务
		ret_commit_love_task        = 5264; -- 返回完成任务
		nt_love_task_change         = 5265; -- 通知爱恋度任务进度变化
		nt_change_lovelevel         = 5266; -- 通知爱恋度等级提升
		--
		--秘境（巨龙宝库额外新请求）
		req_treasure_help           = 5267; -- 向服务器发送协守事件
		ret_treasure_help           = 5268;
		--
		--每日任务
		req_act_task 			= 5300;				--请求请求活跃度任务
		ret_act_task 			= 5301;
		req_act_reward 			= 5302;				--请求活跃度奖励
		ret_act_reward 			= 5303;
		nt_act_changed 			= 5305;				--通知活跃度改变

		--成就任务
		req_achievement_task 	= 5410;				--请求成就任务信息
		ret_achievement_task 	= 5411;
		req_achievement_reward	= 5412;				--请求成就任务奖励
		ret_achievement_reward 	= 5413;
		nt_achievement_changed 	= 5414;				--通知成就任务改变
		-----------------------------------------------------------------

		--每日签到
		req_sign_reward			= 5310;				--请求获取签到奖励
		ret_sign_reward			= 5311;
		req_sign_daily			= 5312;				--请求每日签到相关信息
		ret_sign_daily			= 5313;
		req_sign_remedy         = 5314;				--每日签到请求补签
		ret_sign_remedy			= 5315;
 		-----------------------------------------------------------------

		nt_twoprecrod_t   = 5304;  -- 繁体版通知分享

		req_hongbao       = 5306;  -- 请求领红包
		ret_hongbao       = 5307;  -- 返回红包
		nt_hongbao        = 5308;  -- 通知发红包
		req_limit_round_t = 5320;  -- 请求打限时副本
		ret_limit_round_t = 5321;  -- 返回打限时副本消息
		req_limit_quit_t  = 5322;  -- 请求退出限时副本
		ret_limit_quit_t  = 5323;  -- 返回退出限时副本结果
		req_limit_round_data  = 5324;  -- 请求属性试练数据
		ret_limit_round_data  = 5325;  -- 返回属性试练数据
		req_reset_limit_round = 5326;  -- 请求重置属性试炼
		ret_reset_limit_round = 5327;  -- 返回重置属性试炼
		
		req_guwu          = 5330;  -- 鼓舞
		ret_guwu          = 5331;  -- 返回鼓舞

		req_fuhuo         = 5332;  -- 请求回血
		ret_fuhuo         = 5333;  -- 返回回血

		req_zodiacid      = 5334;  -- 请求通关的十二宫关卡id
		ret_zodiacid      = 5335;

		req_wear_wing     = 5340;  -- 请求装备/卸下翅膀
		ret_wear_wing     = 5341;  -- 返回装备/卸下翅膀
		req_compose_wing  = 5342;  -- 请求合成/分解翅膀
		ret_compose_wing  = 5343;  -- 返回合成/分解翅膀

		req_gacha_wing    = 5344;  -- 请求翅膀抽奖
		ret_gacha_wing    = 5345;  -- 返回翅膀抽奖结果
		req_get_wing      = 5346;  -- 请求领取翅膀
		ret_get_wing      = 5347;  -- 返回领取翅膀结果
		req_wing_rank     = 5348;  -- 请求翅膀排名
		ret_wing_rank     = 5349;  -- 返回翅膀排名结果
		req_sell_wing     = 5350;  -- 请求出售翅膀
		ret_sell_wing     = 5351;  -- 返回出售翅膀

		nt_treasure_help_end         = 5352; -- 巨龙宝库协守结束通知
		nt_meritorious_t             = 5353;
		nt_titleup_t                 = 5354;

		req_prestige_shop_items      = 5355;
		ret_prestige_shop_items      = 5356;
		req_prestige_shop_buy        = 5357;
		ret_prestige_shop_buy        = 5358;

		req_expedition_t              = 5359;
		ret_expedition_t              = 5360;
		req_enter_expedition_round_t  = 5361;
		ret_enter_expedition_round_t  = 5362;
		req_exit_expedition_round_t   = 5363;
		ret_exit_expedition_round_t   = 5364;
		req_expedition_team_t         = 5365;
		ret_expedition_team_t         = 5366;
		nt_expedition_team_change_t   = 5367;
		nt_expeditioncoin_t           = 5368;
		req_expedition_round_reward_t = 5369;
		ret_expedition_round_reward_t = 5370;
		req_expedition_partners_t     = 5371;
		ret_expedition_partners_t     = 5372;
		req_expedition_round_t        = 5377; -- 5375; 不要用这个号
		ret_expedition_round_t        = 5378; -- 5356; 不要用这个号
		req_expedition_reset_t        = 5379;
		ret_expedition_reset_t        = 5380;
		req_expedition_shop_items			= 5381;				--申请远征商城数据
		ret_expedition_shop_items			= 5382;				--返回远征商城数据
		req_expedition_shop_buy				= 5383;				--购买远征商店商品
		ret_expedition_shop_buy				= 5384;				--返回购买远征商品结果
		nt_expedition_shop_reset_t 		= 5385; -- 通知客户端远征商店已重置

		req_naviclicknum_add			= 5386;				--请求增加navi拆分点击次数
		ret_naviclicknum_add			= 5387;				--返回增加navi拆分点击次数结果

		-- 卡牌活动
    nt_card_event_t              = 5455;
    req_card_event_open_round_t  = 5456;
    ret_card_event_open_round_t  = 5457;
    req_card_event_fight_t       = 5458;
    ret_card_event_fight_t       = 5459;
    req_card_event_round_exit_t  = 5460;
    ret_card_event_round_exit_t  = 5461;
    req_card_event_reset_t       = 5462;
    ret_card_event_reset_t       = 5463;
    nt_card_event_coin_t         = 5464;
    nt_card_event_change_team_t  = 5465;
    req_card_event_round_enemy_t = 5466;
    ret_card_event_round_enemy_t = 5467;
    req_card_event_revive_t      = 5468;
    ret_card_event_revive_t      = 5469;
    req_card_event_rank_t        = 5470;
    ret_card_event_rank_t        = 5471;
    nt_card_event_score_t        = 5472;
    nt_card_event_drop_item_t    = 5473;
	req_card_event_sweep_t		 = 5480;
	ret_card_event_sweep_t		 = 5481;
	req_next_card_event_t 		 = 5482;
	ret_next_card_event_t 		 = 5483;
	req_card_event_first_enter	 = 5484;
	ret_card_event_first_enter	 = 5485;
	nt_card_event_change_state	 = 5486;
	nt_card_event_get_reward 	 = 5487;
	nt_card_event_get_level 	 = 5488;
	nt_card_event_open_t		 = 7902;

	nt_wingactivity_change_t 	= 6600;
    nt_sevenpay_change_t = 6610;
	--请求主角转职
	req_change_roletype_t 		= 6601;
	ret_change_roletype_t    	= 6602;

	nt_seven_pay_change 		= 6611;

	--魂师资源改变
	nt_soulvalue_change_t 		= 6603;
	--魂师信息改变
	nt_soulinfo_change_t		= 6604;
	--请求开启魂师位置
	req_open_soulid				= 6605;
	--请求开启魂师位置回调
	ret_open_soulid				= 6606;

	--请求魂师某阶属性加成
	req_soulnode_pro			= 6607;
	ret_soulnode_pro			= 6608;

	
	req_rank_season_match_t		= 6650;
	nt_rank_match_fight_t		= 6651;
	req_rank_season_info_t		= 6652;
	ret_rank_season_info_t		= 6653;
	req_rank_season_fight_end_t = 6654;
	ret_rank_season_fight_end_t = 6655;
	req_cancel_rank_season_wait = 6656;
	req_begin_rank_match_fight	= 6657;
	ret_begin_rank_match_fight	= 6658;

	req_get_soul_info			= 6700;
	ret_get_soul_info			= 6701;
	req_hunt_soul				= 6702;
	ret_hunt_soul				= 6703;
	req_rankup_soul				= 6704;
	ret_rankup_soul				= 6705;
	req_get_soul_reward			= 6706;
	ret_get_soul_reward			= 6707;
	
	--社团战请求报名
	req_union_battle_sign_up   				= 6750;
	ret_union_battle_sign_up   				= 6751;
	--我方某建筑布阵信息
	req_union_battle_defence_info			= 6752;
	ret_union_battle_defence_info			= 6753;
	--我方请求上阵                     
	req_union_battle_defence_pos_on			= 6754;
	ret_union_battle_defence_pos_on			= 6755;
	--我方请求取消上阵      
	req_union_battle_defence_pos_off		= 6756;
	ret_union_battle_defence_pos_off		= 6757;
	--社长,干部取消别人上阵
	req_union_battle_cancel_other_pos		= 6758;
	ret_union_battle_cancel_other_pos		= 6759;
	--敌方某建筑布阵信息                                       
	req_union_battle_defence_info_fight		= 6760;
	ret_union_battle_defence_info_fight		= 6761;
	--请求战斗
	req_union_battle_fight					= 6762;
	ret_union_battle_fight					= 6763;
	--战斗结束请求
	req_union_battle_fight_end				= 6764;
	ret_union_battle_fight_end				= 6765;
	--
	nt_union_boardcast_fight_state_switch	= 6766;
	--战报推送
	nt_union_boardcast_fight_info			= 6767;
	--全部战报
	req_union_battle_fight_record_info		= 6768;
	ret_union_battle_fight_record_info		= 6769;
	--实时战绩
	req_union_battle_fight_info				= 6770;
	ret_union_battle_fight_info				= 6771;
	--请求社团战报名状态
	req_union_battle_state   				= 6772;
	ret_union_battle_state     				= 6773;
	--布阵期间全局状态查看
	req_guild_battle_whole_defence_info		= 6774;
	ret_guild_battle_whole_defence_info		= 6775;
	--战斗期间查看敌方全局状态
	req_union_battle_whole_defence_info_fight = 6776;
	ret_union_battle_whole_defence_info_fight = 6777;
	--建筑升级
	req_union_battle_building_level_up		= 6778;
	ret_union_battle_building_level_up		= 6779;
	--购买挑战次数
	req_union_battle_buy_challenge_times	= 6780;
	ret_union_battle_buy_challenge_times	= 6781;
	--取消社团战CD
	req_union_battle_clear_fight_cd			= 6782;
	ret_union_battle_clear_fight_cd			= 6783;
	--侦察
	req_union_battle_spy					= 6784;
	ret_union_battle_spy					= 6785;
	--社团战排名
	req_union_battle_guild_info				= 6786;
	ret_union_battle_guild_info				= 6787;
	--献祭
	req_guild_battle_sacrifice_begin_t		= 6788;
	ret_guild_battle_sacrifice_begin_t		= 6789;
	req_guild_battle_sacrifice_confirm_t	= 6790;
	ret_guild_battle_sacrifice_confirm_t	= 6791;
	req_guild_battle_sacrifice_cancel_t		= 6792;
	ret_guild_battle_sacrifice_cancel_t		= 6793;
	req_guild_battle_sacrifice_assist_t		= 6794;
	ret_guild_battle_sacrifice_assist_t		= 6795;
	req_guild_battle_sacrifice_change_t		= 6796;
	ret_guild_battle_sacrifice_change_t		= 6797;
	req_guild_battle_sacrifice_new_pos_apply_t = 6798;
	ret_guild_battle_sacrifice_new_pos_apply_t = 6799;
	req_guild_battle_sacrifice_pos_off_t	= 6852;
	ret_guild_battle_sacrifice_pos_off_t	= 6853;
	req_guild_battle_sacrifice_info_t		= 6854;
	ret_guild_battle_sacrifice_info_t		= 6855;
		
	--请求碎片商店物品
	req_chip_shop_items      = 6801;
	ret_chip_shop_items      = 6802;
	--购买碎片商店物品
	req_chip_shop_buy        = 6803;
	ret_chip_shop_buy        = 6804;

	--请求碎片兑换物品
	req_chip_smash_items	 = 6806;
	ret_chip_smash_items 	 = 6805;
	req_chip_smash_buy 		 = 6807;
	ret_chip_smash_buy 		 = 6808;	
	nt_chip_value_change	 = 6809;

	--魂器页请求
	req_gem_page_t							= 6850;
	ret_gem_page_t							= 6851;
	
	req_plant_shop_items			= 7810;				--申请远征商城数据
	ret_plant_shop_items			= 7811;				--返回远征商城数据
	req_plant_shop_buy				= 7812;				--购买远征商店商品
	ret_plant_shop_buy				= 7813;				--返回购买远征商品结果

	req_inventory_shop_items			= 7814;				--申请远征商城数据
	ret_inventory_shop_items			= 7815;				--返回远征商城数据
	req_inventory_shop_buy				= 7816;				--购买远征商店商品
	ret_inventory_shop_buy				= 7817;				--返回购买远征商品结果
	req_grow_up				= 7818;				--请求开服成长活动任务消息
	ret_grow_up				= 7819;				--返回开服成长活动任务消息
	nt_opentask_t			= 7820;				-- 请求领取信息
	req_grow_up_get			= 7821;				-- 请求领取信息
	ret_grow_up_get			= 7822;				-- 返回领取信息

	req_guild_shop_items	= 7823;				-- 申请公会商店数据
	ret_guild_shop_items	= 7824;				-- 申请公会商店数据
	req_guild_shop_buy_items	= 7825;				-- 购买公会商品
	ret_guild_shop_buy_items	= 7826;				-- 返回购买公会商品结果

	req_rune_shop_items		= 7830;				-- 申请符文商店数据
	ret_rune_shop_items		= 7831;				-- 申请符文商店数据
	req_rune_shop_buy_items	= 7832;				-- 购买符文商品
	ret_rune_shop_buy_items	= 7833;				-- 返回购买符文商品结果

	req_cardevent_shop_items  	= 7835;			--申请活动商店数据
	ret_cardevent_shop_item  	= 7836;			--申请活动商店数据回调
	req_cardevent_shop_buy_items	= 7837;				-- 购买活动商品
	ret_cardevent_shop_buy_items	= 7838;				-- 返回购买活动商品结果

	req_lmt_shop_items  	= 7839;			--申请限时商店数据
	ret_lmt_shop_item  	= 7840;			--申请限时商店数据回调
	req_lmt_shop_buy_items	= 7841;				-- 购买限时商品
	ret_lmt_shop_buy_items	= 7842;				-- 返回限时商品结果


	nt_comment_change 		= 7828;

	req_clear_lmt_cd					= 7850;				--清除属性副本CD
	ret_clear_lmt_cd					= 7851;			--返回
	
	req_sweep_expedition				= 7852;				--请求远征扫荡
	ret_sweep_expedition				= 7853;				--请求远征扫荡

	nt_luckybag_change 					= 7854;				--福袋同步

	nt_report 							= 7860;				--举报通知
	req_report 							= 7861;				--举报请求

	req_compose_pet						= 7900;				--请求升级宠物
	ret_compose_pet						= 7901;				--返回升级宠物

	req_combo_pro_open_t				= 7903;
	ret_combo_pro_open_t 				= 7904;
	req_combo_pro_levelup_t				= 7905;
	ret_combo_pro_levelup_t				= 7906;
	nt_combo_pro_attribute_change		= 7907;
	nt_combo_pro_exp_change				= 7908;

	req_hunt_rune_t						= 7950;
	ret_hunt_rune_t						= 7951;
	req_enter_rune_hunt_t				= 7952;
	ret_enter_rune_hunt_t				= 7953;
	nt_new_rune_be_hunted_t				= 7954;
	nt_leave_rune_hunt_t				= 7955;
	nt_add_new_rune_t					= 7956;
	req_new_rune_inlay_t				= 7957;
	ret_new_rune_inlay_t				= 7958;
	req_new_rune_unlay_t				= 7959;
	ret_new_rune_unlay_t				= 7960;
	req_new_rune_levelup_t				= 7961;
	ret_new_rune_levelup_t				= 7962;
	nt_del_rune_t						= 7963;
	req_new_rune_compose_t				= 7964;
	ret_new_rune_compose_t				= 7965;
	req_new_rune_active_t				= 7966;
	ret_new_rune_active_t				= 7967;
	req_gen_in_code_t					= 8000;
	ret_gen_in_code_t					= 8001;
	req_model_t							= 8002;
	ret_model_t							= 8003;
	req_change_model_t					= 8004;
	ret_change_model_t					= 8005;
	req_wear_sweapon_t					= 8006;
	ret_wear_sweapon_t					= 8007;
	req_sweapon_gen_pro_t 				= 8008;
	ret_sweapon_gen_pro_t 				= 8009;
	req_sweapon_save_pro_t 				= 8010;
	ret_sweapon_save_pro_t 				= 8011;
	req_takeoff_sweapon_t				= 8012;
	ret_takeoff_sweapon_t				= 8013;

	req_announcement_t					= 8050;
	ret_announcement_t					= 8051;

	req_private_chat_info_t				= 8070;
	ret_private_chat_info_t				= 8071;

	req_vip_exp_t					= 8080;
	ret_vip_exp_t					= 8081;

	nt_feedback_t					=8082;  --反馈返回

	req_get_thirtydays_notlogin_reward_t = 8072;
	ret_get_thirtydays_notlogin_reward_t = 8073;

		req_test_arena    = 9000;  -- 请求测试
		ret_test_arena    = 9001;  -- 返回结果

		req_pay           = 9002;  -- 充值
		ret_pay           = 9003;  -- 返回充值结果

		req_pub_rank_t			= 9010;				--召唤排行
		ret_pub_rank_t			= 9011;				--召唤排行
		nt_pub_rank_t 			= 9012; 			--召唤排行改变

		nt_openyb_t 			= 9013; 			--钻石消费改变

    req_bullets       = 11001; -- 请求弹幕
    ret_bullets       = 11002; -- 返回弹幕结果

    req_send_bullet   = 11003; -- 发送弹幕
    ret_send_bullet   = 11004; -- 返回发送弹幕
	
	};

Network =
	{
		isInner          = true;              -- 是否使用内网
		---[[
		routeInnerIP     = '52.198.167.57'; -- Win32内网使用
		routeIP          = '52.198.167.57'; -- 真机使用
		--]]
		--[[
		routeInnerIP     = '182.254.147.153'; -- Win32内网使用
		routeIP          = '182.254.147.153'; -- 真机使用
		--]]
		routePort        = account_config.server_port;             -- 路由端口

		netError         = false;             -- 网络错误
		serverData       = nil;               -- 服务器数据
		reqList          = {};                -- 请求列表
		receiveID        = 0;                 -- 回复ID
		handlerList      = {};                -- 事件列表
		errorHandlerList = {};                -- 错误处理列表

		showWaiting      = true;              -- 显示等待界面
	};


local waitingPanel;		--网络等待窗口
local loadingBKG;			--等待动画背景
local loading;				--等待动画
local msgLabel;				--等待消息id

local loadingTimer = 0;	--等待计时器
local heartBeatTimer = 0;	--心跳等待计时器

--初始化
function Network:Init()

	self.netError			= false;
	self.serverData			= nil;					--服务器数据
	self.reqList			= {};					--请求列表
	self.receiveID			= 0;					--回复ID
	self.handlerList		= {};					--事件列表
	self.errorHandlerList	= {};					--错误处理列表
	self.faultToleranceList = {};					--避免部分请求重复发送容错堆栈
	self.faultList = 
	{
		[NetworkCmdType.req_hire_partner] = 1;
	};												--需要避免重复发送的请求
	self.errorHandlerSpecialList = 
	{
		[NetworkCmdType.ret_pub_flush_t] = ZhaomuResultPanel.ShowCostPanel;
	};												--特殊异常处理



	networkManager:SetErrorHandler('Network:onHandleError');
	networkManager:SetMsgHandler('Network:onHandleMsg');

	--登陆相关消息
	self:RegisterEvent(NetworkCmdType.ret_rout, NetworkMsg_Login, NetworkMsg_Login.onLoginRoute);
	self:RegisterEvent(NetworkCmdType.ret_gw, NetworkMsg_Login, NetworkMsg_Login.onLoginGateWay);
	self:RegisterEvent(NetworkCmdType.ret_mac_login, NetworkMsg_Login, NetworkMsg_Login.onMacLoginSuccess);
	self:RegisterEvent(NetworkCmdType.ret_gslist, NetworkMsg_Login, NetworkMsg_Login.onServerListSuccess);
	self:RegisterEvent(NetworkCmdType.ret_rolelist, NetworkMsg_Login, NetworkMsg_Login.onRoleListSuccess);
	self:RegisterEvent(NetworkCmdType.ret_new_role, NetworkMsg_Login, NetworkMsg_Login.onCreateRoleSuccess);
	self:RegisterEvent(NetworkCmdType.ret_del_role, NetworkMsg_Login, NetworkMsg_Login.onDeleteRoleSuccess);

	--场景、移动
	self:RegisterEvent(NetworkCmdType.ret_enter_game, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onEnterGame);
	self:RegisterEvent(NetworkCmdType.ret_user_data, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onReqUserData);
	self:RegisterEvent(NetworkCmdType.ret_enter_city, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onEnterCity, NetworkCmdType.req_enter_city);
	self:RegisterErrorEvent(NetworkCmdType.ret_enter_city);
	self:RegisterEvent(NetworkCmdType.nt_user_in, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onOtherPlayerEnter);
	self:RegisterEvent(NetworkCmdType.nt_user_out, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onOtherPlayerOut);
	self:RegisterEvent(NetworkCmdType.nt_transport, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onTranspot);
	self:RegisterEvent(NetworkCmdType.nt_move, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onMove);

	--关卡
	self:RegisterEvent(NetworkCmdType.ret_round_enter, NetworkMsg_Fight, NetworkMsg_Fight.onEnterBattle);
	--self:RegisterEvent(NetworkCmdType.ret_begin_auto_round, NetworkMsg_Fight, NetworkMsg_Fight.onEnterAutoBattleInfoPanel);
	--self:RegisterEvent(NetworkCmdType.ret_auto_round_resu, AutoBattleInfoPanel, AutoBattleInfoPanel.onAddAutoBattleInfo);
	self:RegisterEvent(NetworkCmdType.ret_elite_reset, NetworkMsg_Fight, NetworkMsg_Fight.onReturnResetElite);
	self:RegisterEvent(NetworkCmdType.ret_round_flush, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onRefreshEliteOrZodia, NetworkCmdType.req_round_flush);
	self:RegisterEvent(NetworkCmdType.ret_helphero_stranger, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onStrangerList);
	self:RegisterEvent(NetworkCmdType.ret_starreward, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onGetPveReward, NetworkCmdType.req_starreward);
	self:RegisterEvent(NetworkCmdType.ret_starreward_info, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onGetPveStarInfo);
	self:RegisterEvent(NetworkCmdType.ret_round_pass, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onHangUpInfo, NetworkCmdType.req_round_pass_new);
	self:RegisterEvent(NetworkCmdType.ret_round_pass_clear_cd, NetworkMsg_PveBarrier, NetworkMsg_PveBarrier.onHangUpClearCd, NetworkCmdType.req_round_pass_clear_cd);

	--数值通知
	self:RegisterEvent(NetworkCmdType.nt_power_change, NetworkMsg_Data, NetworkMsg_Data.onChangePower);
	self:RegisterEvent(NetworkCmdType.nt_money_change, NetworkMsg_Data, NetworkMsg_Data.onChangeMoney);
	self:RegisterEvent(NetworkCmdType.nt_rmb_change, NetworkMsg_Data, NetworkMsg_Data.onChangeRmb);
	self:RegisterEvent(NetworkCmdType.nt_exp_change, NetworkMsg_Data, NetworkMsg_Data.onChangeExp);
	self:RegisterEvent(NetworkCmdType.nt_role_pro_change, NetworkMsg_Data, NetworkMsg_Data.onChangePro);
	self:RegisterEvent(NetworkCmdType.nt_role_pros_change, NetworkMsg_Data, NetworkMsg_Data.onChangePros);
	self:RegisterEvent(NetworkCmdType.ret_role_pro, NetworkMsg_Data, NetworkMsg_Data.onChangePro, NetworkCmdType.req_role_pro);
	self:RegisterEvent(NetworkCmdType.nt_fpoint_change, NetworkMsg_Data, NetworkMsg_Data.onChangeYouQing);
	self:RegisterEvent(NetworkCmdType.ret_gen_power, LuaTimerManager, LuaTimerManager.onRecoverPower);
	self:RegisterEvent(NetworkCmdType.ret_buy_power, NetworkMsg_Data, NetworkMsg_Data.onRetBuyPower, NetworkCmdType.req_buy_power);
	self:RegisterEvent(NetworkCmdType.ret_guwu, NetworkMsg_Data, NetworkMsg_Data.onChangeInspire, NetworkCmdType.req_guwu);
	self:RegisterEvent(NetworkCmdType.nt_chronicle_sum_change, NetworkMsg_Data, NetworkMsg_Data.onChangeChronicleSum);
	self:RegisterEvent(NetworkCmdType.nt_pub_rank_t, OpenServiceRewardPanel, OpenServiceRewardPanel.LimitPubChange);


	self:RegisterEvent(NetworkCmdType.nt_soul_change, NetworkMsg_Data, NetworkMsg_Data.onChangeSoul);
	self:RegisterEvent(NetworkCmdType.nt_chip_change, NetworkMsg_Data, NetworkMsg_Data.onChangeChip);
	--碎片兑换灵能
	self:RegisterEvent(NetworkCmdType.ret_chip_to_soul, NetworkMsg_Data, NetworkMsg_Data.onChipToSoul, NetworkCmdType.req_chip_to_soul);
	--碎片合成英雄
	self:RegisterEvent(NetworkCmdType.ret_hire_partner, NetworkMsg_Pub, NetworkMsg_Pub.onHirePartner, NetworkCmdType.req_hire_partner);
	--伙伴升星、升潜力
	self:RegisterEvent(NetworkCmdType.ret_quality_up, NetworkMsg_Data, NetworkMsg_Data.onPartnerQualityUp, NetworkCmdType.req_quality_up);
	self:RegisterEvent(NetworkCmdType.ret_potential_up, NetworkMsg_Data, NetworkMsg_Data.onChangePotential);
	self:RegisterEvent(NetworkCmdType.nt_skill_open, NetworkMsg_Data, NetworkMsg_Data.onSkillOpen);

	--酒馆
	self:RegisterEvent(NetworkCmdType.ret_pub_flush_t, NetworkMsg_Pub, NetworkMsg_Pub.onRefreshPub, NetworkCmdType.req_pub_flush);
	self:RegisterEvent(NetworkCmdType.ret_pub_time_t, NetworkMsg_Pub, NetworkMsg_Pub.onRefreshTime, NetworkCmdType.req_pub_time_t);
	self:RegisterEvent(NetworkCmdType.ret_fire_partner, NetworkMsg_Pub, NetworkMsg_Pub.onFirePartner, NetworkCmdType.req_fire_partner);

	self:RegisterEvent(NetworkCmdType.ret_enter_pub_t, NetworkMsg_Pub, NetworkMsg_Pub.onEnter, NetworkCmdType.req_enter_pub_t);


	--十二宫
	self:RegisterEvent(NetworkCmdType.ret_zodiacid, ZodiacSignPanel, ZodiacSignPanel.ReceiveZodiacID, NetworkCmdType.req_zodiacid);

	--竞技场
	self:RegisterEvent(NetworkCmdType.ret_arena_info, NetworkMsg_Arena, NetworkMsg_Arena.onArenaInfo, NetworkCmdType.req_arena_info);
--	self:RegisterEvent(NetworkCmdType.ret_view_user_info, PlayerInfoPanel, PlayerInfoPanel.onShowPlayerInfoPanel, NetworkCmdType.req_view_user_info);
		self:RegisterEvent(NetworkCmdType.ret_view_user_info, PersonInfoPanel, PersonInfoPanel.ShowOtherInfo, NetworkCmdType.req_view_user_info);
	self:RegisterEvent(NetworkCmdType.ret_arena_rank_page, RankPanel, RankPanel.GotArenaRankMsg, NetworkCmdType.req_arena_rank_page);

	self:RegisterEvent(NetworkCmdType.ret_begin_arena_fight, NetworkMsg_Arena, NetworkMsg_Arena.onEnterArenaPvP, NetworkCmdType.req_begin_arena_fight);
	self:RegisterEvent(NetworkCmdType.ret_end_arena_fight, NetworkMsg_Arena, NetworkMsg_Arena.onEndArenaPvP, NetworkCmdType.req_end_arena_fight);

	self:RegisterEvent(NetworkCmdType.ret_test_arena, NetworkMsg_Fight, NetworkMsg_Fight.onTestPvP, NetworkCmdType.req_test_arena);
	-- self:RegisterEvent(NetworkCmdType.ret_arena_reward_countdown, ArenaPanel, ArenaPanel.onShowRewardTime, NetworkCmdType.req_arena_reward_countdown);
	self:RegisterEvent(NetworkCmdType.ret_buy_fight_count, ArenaPanel, ArenaPanel.onRetBuyChallengeCount, NetworkCmdType.req_buy_fight_count);
	self:RegisterEvent(NetworkCmdType.ret_arena_clear_time, ArenaPanel, ArenaPanel.onRetClearTime, NetworkCmdType.req_arena_clear_time);
	self:RegisterEvent(NetworkCmdType.ret_arena_rank, NetworkMsg_Arena, NetworkMsg_Arena.onGetArenaRank);

	--升级
	self:RegisterEvent(NetworkCmdType.nt_levelup, NetworkMsg_Data, NetworkMsg_Data.onChangeLevel);

	--宝石合成、镶嵌
	self:RegisterEvent(NetworkCmdType.ret_gemstone_compose, GemPanel, GemPanel.synCallback, NetworkCmdType.req_gemstone_compose);
	self:RegisterEvent(NetworkCmdType.ret_gemstone_inlay, GemPanel, GemPanel.mosCallback, NetworkCmdType.req_gemstone_inlay);
	self:RegisterEvent(NetworkCmdType.ret_gemstone_inlay_all, GemPanel, GemPanel.mosAllCallback, NetworkCmdType.req_gemstone_inlay_all);
	self:RegisterEvent(NetworkCmdType.ret_gemstone_syn_all, GemPanel, GemPanel.synAllCallBack, NetworkCmdType.req_gemstone_syn_all);

	--战历
	self:RegisterEvent(NetworkCmdType.nt_battlexp_change, NetworkMsg_Data, NetworkMsg_Data.onChangeBattleExp);

	--聊天
	self:RegisterEvent(NetworkCmdType.nt_msg_push, NetworkMsg_Chat, NetworkMsg_Chat.onReceiveMessage);
	self:RegisterEvent(NetworkCmdType.nt_event_general, NetworkMsg_Chat, NetworkMsg_Chat.onReceiveEventMessage);
	self:RegisterEvent(NetworkCmdType.ret_mail_info, NetworkMsg_Chat, NetworkMsg_Chat.onReceiveOffLineMessage, NetworkCmdType.req_mail_info);
	self:RegisterEvent(NetworkCmdType.nt_pushinfo, NetworkMsg_Chat, NetworkMsg_Chat.onParseEventMessage);
	self:RegisterEvent(NetworkCmdType.ret_private_chat_info_t,NetworkMsg_Chat, NetworkMsg_Chat.onGetPlayerMessage ,NetworkCmdType.req_private_chat_info_t);
	--Boss
	self:RegisterEvent(NetworkCmdType.ret_boss_state, WOUBossPanel, WOUBossPanel.onReceiveBossFlag, NetworkCmdType.req_boss_state);
	self:RegisterEvent(NetworkCmdType.ret_dmg_ranking, WOUBossPanel, WOUBossPanel.onShowRankPanel);
	self:RegisterEvent(NetworkCmdType.ret_boss_start_batt, NetworkMsg_Boss, NetworkMsg_Boss.onEnterBossFight, NetworkCmdType.req_boss_start_batt);
	self:RegisterEvent(NetworkCmdType.ret_boss_end_batt, NetworkMsg_Boss, NetworkMsg_Boss.onExitBossFight, NetworkCmdType.req_boss_end_batt);
	self:RegisterEvent(NetworkCmdType.ret_boss_leave_scene, WOUBossPanel, WOUBossPanel.OnRequestEnterCity, NetworkCmdType.req_boss_leave_scene);
	self:RegisterEvent(NetworkCmdType.nt_boss_go, WOUBossPanel, WOUBossPanel.ReceiveBossDisappear);
	self:RegisterEvent(NetworkCmdType.ret_boss_alive, WOUBossPanel, WOUBossPanel.ShowBossButton);
	self:RegisterEvent(NetworkCmdType.ret_open_union_boss, WOUBossPanel, WOUBossPanel.onOpenUnionBoss);
	self:RegisterEvent(NetworkCmdType.nt_dmg_ranking, NetworkMsg_Boss, NetworkMsg_Boss.AddTenBossDamage);

	--物品
	self:RegisterEvent(NetworkCmdType.ret_wear_equip, NetworkMsg_Item, NetworkMsg_Item.onWearEquip, NetworkCmdType.req_wear_equip);
	self:RegisterEvent(NetworkCmdType.nt_bag_change, NetworkMsg_Item, NetworkMsg_Item.onChangeBag);
	self:RegisterEvent(NetworkCmdType.ret_upgrade_equip, NetworkMsg_Item, NetworkMsg_Item.onEquipStrength);
	self:RegisterEvent(NetworkCmdType.ret_compose_equip, NetworkMsg_Item, NetworkMsg_Item.onEquipAdvance);
	self:RegisterErrorEvent(NetworkCmdType.ret_compose_equip);
	self:RegisterEvent(NetworkCmdType.ret_sell, PackagePanel, PackagePanel.onSellResult);
	self:RegisterEvent(NetworkCmdType.ret_open_pack, NetworkMsg_Item, NetworkMsg_Item.onOpenPacks, NetworkCmdType.req_open_pack);
	self:RegisterEvent(NetworkCmdType.ret_use_item_t, NetworkMsg_Item, NetworkMsg_Item.onUseItemCallBack, NetworkCmdType.req_use_item_t);

	--阵型
	self:RegisterEvent(NetworkCmdType.nt_team_change, NetworkMsg_Team, NetworkMsg_Team.onChangeTeamOrder);

	--技能
	self:RegisterEvent(NetworkCmdType.ret_upgrade_skill, NetworkMsg_Skill, NetworkMsg_Skill.onUpLevel);
	self:RegisterEvent(NetworkCmdType.ret_upnext_skill, NetworkMsg_Skill, NetworkMsg_Skill.onAdvanceLevel, NetworkCmdType.req_upnext_skill);
	self:RegisterErrorEvent(NetworkCmdType.ret_upgrade_skill);
	self:RegisterErrorEvent(NetworkCmdType.ret_upnext_skill);
	--训练
	self:RegisterEvent(NetworkCmdType.ret_practice_info, NetworkMsg_Train, NetworkMsg_Train.onTrainInfo, NetworkCmdType.req_practice_info);
	self:RegisterEvent(NetworkCmdType.ret_practice_partner, NetworkMsg_Train, NetworkMsg_Train.onTrainEnd, NetworkCmdType.req_practice_partner);
	self:RegisterEvent(NetworkCmdType.ret_practice_clear, NetworkMsg_Train, NetworkMsg_Train.onClearTrainCD, NetworkCmdType.req_practice_clear);

	--公会
	self:RegisterEvent(NetworkCmdType.ret_gang_list, NetworkMsg_Union, NetworkMsg_Union.onShowUnionList);
	self:RegisterEvent(NetworkCmdType.ret_gang_info, NetworkMsg_Union, NetworkMsg_Union.GetUnionInfo, NetworkCmdType.req_gang_info);
	self:RegisterEvent(NetworkCmdType.ret_create_gang, NetworkMsg_Union, NetworkMsg_Union.onCreateUnionSuccess, NetworkCmdType.req_create_gang);
	self:RegisterEvent(NetworkCmdType.ret_set_notice, UnionPanel, UnionPanel.SetNotice);
	self:RegisterEvent(NetworkCmdType.nt_gang_msg, UnionPanel, UnionPanel.onReceiveMessage);
	self:RegisterEvent(NetworkCmdType.ret_gang_pay, NetworkMsg_Union, NetworkMsg_Union.onUnionDonate, NetworkCmdType.req_gang_pay);
	self:RegisterEvent(NetworkCmdType.nt_gang_pay_change, NetworkMsg_Union, NetworkMsg_Union.onDonateChange);
	self:RegisterEvent(NetworkCmdType.nt_gang_exp_change, NetworkMsg_Union, NetworkMsg_Union.onUnionExpChange);
	self:RegisterEvent(NetworkCmdType.nt_gang_level_change, NetworkMsg_Union, NetworkMsg_Union.onUnionLevelChange);
	self:RegisterEvent(NetworkCmdType.ret_search_gang, UnionListPanel, UnionListPanel.onShowSearchResult, NetworkCmdType.req_search_gang);
	self:RegisterEvent(NetworkCmdType.ret_close_gang, NetworkMsg_Union, NetworkMsg_Union.onCloseUnion, NetworkCmdType.req_close_gang);
	self:RegisterEvent(NetworkCmdType.ret_gskl_list, UnionSkillPanel, UnionSkillPanel.onShowUnionSkillPanel, NetworkCmdType.req_gskl_list);
	self:RegisterEvent(NetworkCmdType.ret_learn_gskl, UnionSkillPanel, UnionSkillPanel.onAdvanceSkillSuccess);
	self:RegisterEvent(NetworkCmdType.nt_gskl_lv_change, UnionSkillPanel, UnionSkillPanel.onSkillAdvanced);
	self:RegisterEvent(NetworkCmdType.ret_add_gang, NetworkMsg_Union, NetworkMsg_Union.onReceiveApplyRes);
	self:RegisterEvent(NetworkCmdType.ret_gang_reqlist, UnionApplyPanel, UnionApplyPanel.onShowApplyList, NetworkCmdType.req_gang_reqlist);
	self:RegisterEvent(NetworkCmdType.ret_gang_mem, UnionMemberPanel, UnionMemberPanel.onShowMemberPanel);
	self:RegisterEvent(NetworkCmdType.ret_deal_gang_req, NetworkMsg_Union, NetworkMsg_Union.onAcceptNewPlayer);
	self:RegisterEvent(NetworkCmdType.nt_add_gang_res, NetworkMsg_Union, NetworkMsg_Union.onNoticeJoinInUnion);
	self:RegisterEvent(NetworkCmdType.ret_leave_gang, NetworkMsg_Union, NetworkMsg_Union.onLeaveUnion, NetworkCmdType.req_leave_gang);
	self:RegisterEvent(NetworkCmdType.ret_enter_pray, UnionAlterPanel, UnionAlterPanel.onShowAlterPanel, NetworkCmdType.req_enter_pray);
	self:RegisterEvent(NetworkCmdType.ret_set_adm, NetworkMsg_Union, NetworkMsg_Union.onOptPositionResult, NetworkCmdType.req_set_adm);
	self:RegisterEvent(NetworkCmdType.ret_kick_mem, NetworkMsg_Union, NetworkMsg_Union.onKickResult, NetworkCmdType.req_kick_mem);
	self:RegisterEvent(NetworkCmdType.ret_gang_pray, UnionAlterPanel, UnionAlterPanel.onReceivePrayResult, NetworkCmdType.req_gang_pray);
	self:RegisterEvent(NetworkCmdType.ret_change_charman, NetworkMsg_Union, NetworkMsg_Union.onChangeMaster, NetworkCmdType.req_change_charman);
	self:RegisterEvent(NetworkCmdType.nt_kick_gang, NetworkMsg_Union, NetworkMsg_Union.onKickOutofUnion);
	self:RegisterEvent(NetworkCmdType.nt_gang_req, UnionApplyPanel, UnionApplyPanel.onNewApply);
	self:RegisterEvent(NetworkCmdType.ret_set_gang_boss_time, UnionSetBossTimePanel, UnionSetBossTimePanel.ChangeBossTimeSuccess, NetworkCmdType.req_set_gang_boss_time);
	self:RegisterEvent(NetworkCmdType.nt_gang_boss_time, NetworkMsg_Union, NetworkMsg_Union.onUnionBossTimeChange);
	self:RegisterEvent(NetworkCmdType.ret_hongbao, NetworkMsg_Union, NetworkMsg_Union.onHongBao, NetworkCmdType.req_hongbao);
	self:RegisterEvent(NetworkCmdType.nt_hongbao, NetworkMsg_Union, NetworkMsg_Union.onNT_HongBao);

	--试炼
	self:RegisterEvent(NetworkCmdType.ret_trial_info, NetworkMsg_Trial, NetworkMsg_Trial.onTrialInfo, NetworkCmdType.req_trial_info);
	self:RegisterEvent(NetworkCmdType.ret_trial_receive_task, NetworkMsg_Trial, NetworkMsg_Trial.onTrialTaskInfo, NetworkCmdType.req_trial_receive_task);
	self:RegisterEvent(NetworkCmdType.ret_trial_flush_task, NetworkMsg_Trial, NetworkMsg_Trial.onTrialRefreshTasks, NetworkCmdType.req_trial_flush_task);
	self:RegisterEvent(NetworkCmdType.ret_trial_flush_targets, NetworkMsg_Trial, NetworkMsg_Trial.onTrialRefreshTargets, NetworkCmdType.req_trial_flush_targets);
	self:RegisterEvent(NetworkCmdType.ret_gen_energy, NetworkMsg_Trial, NetworkMsg_Trial.onGenEnergy);
	self:RegisterEvent(NetworkCmdType.ret_trial_giveup_task, NetworkMsg_Trial, NetworkMsg_Trial.onGiveupTrial, NetworkCmdType.req_trial_giveup_task);
	self:RegisterEvent(NetworkCmdType.ret_trial_start_batt, NetworkMsg_Trial, NetworkMsg_Trial.onTrialTargetFight, NetworkCmdType.req_trial_start_batt);
	self:RegisterEvent(NetworkCmdType.ret_trial_rewards, NetworkMsg_Trial, NetworkMsg_Trial.onGetReward, NetworkCmdType.req_trial_rewards);
	self:RegisterEvent(NetworkCmdType.ret_trial_end_batt, NetworkMsg_Trial, NetworkMsg_Trial.onTrialEndFight, NetworkCmdType.req_trial_end_batt);
	self:RegisterEvent(NetworkCmdType.nt_energy_change, NetworkMsg_Trial, NetworkMsg_Trial.onEnergyChange);
	self:RegisterEvent(NetworkCmdType.ret_buy_energy, NetworkMsg_Trial, NetworkMsg_Trial.onRetBuyEnergy, NetworkCmdType.req_buy_energy);

	--好友
	self:RegisterEvent(NetworkCmdType.ret_friend_search, FriendAddPanel, FriendAddPanel.onSearchResult, NetworkCmdType.req_friend_search);
	self:RegisterEvent(NetworkCmdType.nt_friend_beenadd, Friend, Friend.NewFriendRequest);
	self:RegisterEvent(NetworkCmdType.ret_friend_list, Friend, Friend.FetchFriendList);
	self:RegisterEvent(NetworkCmdType.nt_friend_olchange, Friend, Friend.ChangeFriendOnline);
	self:RegisterEvent(NetworkCmdType.nt_friend_hbchange, Friend, Friend.ChangeFriendAssist);
	self:RegisterEvent(NetworkCmdType.nt_friend_addone, Friend, Friend.FriendAdd);
	self:RegisterEvent(NetworkCmdType.nt_friend_delone, Friend, Friend.FriendDelete);
	self:RegisterEvent(NetworkCmdType.ret_friend_addlist, Friend, Friend.FetchFriendRequestList, NetworkCmdType.req_friend_addlist);
	self:RegisterEvent(NetworkCmdType.ret_friend_helpbattle, Friend, Friend.ChangeAssist, NetworkCmdType.req_friend_helpbattle);
	self:RegisterEvent(NetworkCmdType.ret_friend_add_res, Friend, Friend.onAcceptOrReject, NetworkCmdType.req_friend_add_res);
	self:RegisterEvent(NetworkCmdType.ret_friend_add, NetworkMsg_Friend, NetworkMsg_Friend.onApplyAddFriend);
	self:RegisterEvent(NetworkCmdType.ret_friend_battle, NetworkMsg_Friend, NetworkMsg_Friend.onFriendFight, NetworkCmdType.req_friend_battle);
	self:RegisterEvent(NetworkCmdType.ret_flower_list, NetworkMsg_Friend, NetworkMsg_Friend.onFriendFlower);
	self:RegisterEvent(NetworkCmdType.ret_receive_flower, NetworkMsg_Friend, NetworkMsg_Friend.onReceiveFlower);
	self:RegisterEvent(NetworkCmdType.nt_receieve_flower, NetworkMsg_Friend, NetworkMsg_Friend.onFriendFlowerReceieve);
	self:RegisterEvent(NetworkCmdType.ret_send_flower, Friend, Friend.onRetSendFlower);

	--巨龙宝库
	self:RegisterEvent(NetworkCmdType.ret_treasure_floor, TreasurePanel, TreasurePanel.onReceiveRoundInfomation, NetworkCmdType.req_treasure_floor);

	self:RegisterEvent(NetworkCmdType.ret_treasure_enter, NetworkMsg_DragonTreasure, NetworkMsg_DragonTreasure.onTreasureFight, NetworkCmdType.req_treasure_enter);

	self:RegisterEvent(NetworkCmdType.ret_treasure_exit, TreasurePanel, TreasurePanel.onTreasureFightEnd, NetworkCmdType.req_treasure_exit);
	self:RegisterEvent(NetworkCmdType.ret_treasure_occupy, TreasurePanel, TreasurePanel.onCaptureEmptySlot, NetworkCmdType.req_treasure_occupy);

	self:RegisterEvent(NetworkCmdType.ret_treasure_giveup, TreasurePanel, TreasurePanel.onGiveUpTreasureResult, NetworkCmdType.req_treasure_giveup);
	self:RegisterEvent(NetworkCmdType.ret_treasure_fight, NetworkMsg_DragonTreasure, NetworkMsg_DragonTreasure.onDragonTreasureGrabSlotPvp, NetworkCmdType.req_treasure_fight);

	self:RegisterEvent(NetworkCmdType.nt_treasure_kick_out, TreasurePanel, TreasurePanel.onKickOutofSlot);
	self:RegisterEvent(NetworkCmdType.nt_treasure_help_end, TreasurePanel, TreasurePanel.onHelpEnd);
	self:RegisterEvent(NetworkCmdType.nt_treasure_profit, NetworkMsg_Data, NetworkMsg_Data.onChangeProfit);

	self:RegisterEvent(NetworkCmdType.ret_treasure_rob, NetworkMsg_DragonTreasure, NetworkMsg_DragonTreasure.onDragonTreasureRobPvp, NetworkCmdType.req_treasure_rob);
	self:RegisterEvent(NetworkCmdType.ret_treasure_rob_end, NetworkMsg_DragonTreasure, NetworkMsg_DragonTreasure.onDragonTreasureRobPvpEnd, NetworkCmdType.req_treasure_rob_end);
	self:RegisterEvent(NetworkCmdType.ret_treasure_fight_end, NetworkMsg_DragonTreasure, NetworkMsg_DragonTreasure.onDragonTreasureFightPvpEnd, NetworkCmdType.req_treasure_fight_end)

	self:RegisterEvent(NetworkCmdType.ret_treasure_slot_rewd, TreasurePanel, TreasurePanel.onReceiveTreasureReward, NetworkCmdType.req_treasure_slot_rewd);
	self:RegisterEvent(NetworkCmdType.ret_treasure_pass, TreasurePanel, TreasurePanel.onFastSweepCallBack, NetworkCmdType.req_treasure_pass);

	self:RegisterEvent(NetworkCmdType.ret_secs_to_zero, LuaTimerManager, LuaTimerManager.adjust24Time, NetworkCmdType.req_secs_to_zero);
	self:RegisterEvent(NetworkCmdType.ret_treasure_rcds, TreasurePanel, TreasurePanel.ShowTreasureRecords, NetworkCmdType.req_treasure_rcds);
	self:RegisterEvent(NetworkCmdType.ret_treasure_revenge, TreasurePanel, TreasurePanel.ShowTreasureRevenge, NetworkCmdType.req_treasure_revenge);
	self:RegisterEvent(NetworkCmdType.ret_treasure_help, TreasurePanel, TreasurePanel.onTreasureHelp, NetworkCmdType.req_treasure_help);
	self:RegisterEvent(NetworkCmdType.ret_chat_info, ChatPanel, ChatPanel.onchatinfo, NetworkCmdType.req_chat_info);
	self:RegisterEvent(NetworkCmdType.nt_union_boss_open, WOUBossPanel, WOUBossPanel.onUnionBossOpen);

	--任务
	self:RegisterEvent(NetworkCmdType.ret_task_list, Task, Task.HandleTaskList);
	self:RegisterEvent(NetworkCmdType.ret_finished_bline, Task, Task.HandleFinishBline);
	self:RegisterEvent(NetworkCmdType.ret_get_task, Task, Task.GetTask, NetworkCmdType.req_get_task);
	self:RegisterEvent(NetworkCmdType.ret_commit_task, Task, Task.CommitTask, NetworkCmdType.req_commit_task);
	self:RegisterEvent(NetworkCmdType.nt_task_change, Task, Task.NotifyTaskChange);
	self:RegisterEvent(NetworkCmdType.ret_act_task, NetworkMsg_Task, NetworkMsg_Task.ReceiveActivityDegreeItemList, NetworkCmdType.req_act_task);
	self:RegisterEvent(NetworkCmdType.ret_act_reward, NetworkMsg_Task, NetworkMsg_Task.ReceiveActivityDegreeRewards, NetworkCmdType.req_act_reward);
	self:RegisterEvent(NetworkCmdType.nt_act_changed, NetworkMsg_Task, NetworkMsg_Task.ReceiveActivityDegreeChange);
	self:RegisterEvent(NetworkCmdType.ret_achievement_task, NetworkMsg_Task, NetworkMsg_Task.ReceiveAchievementList, NetworkCmdType.req_achievement_task);
	self:RegisterEvent(NetworkCmdType.ret_achievement_reward, NetworkMsg_Task, NetworkMsg_Task.ReceiveAchievementRewards, NetworkCmdType.req_achievement_reward);
	self:RegisterEvent(NetworkCmdType.nt_achievement_changed, NetworkMsg_Task, NetworkMsg_Task.ReceiveAchievementChange);

	--新手引导
	self:RegisterEvent(NetworkCmdType.ret_guidence_partner, UserGuide, UserGuide.onOfferPartner, NetworkCmdType.req_guidence_partner);
	self:RegisterEvent(NetworkCmdType.ret_guidence_rename, UserGuide, UserGuide.onSetHeroName, NetworkCmdType.req_guidence_rename);
--[[	self:RegisterEvent(NetworkCmdType.ret_guidence_gemstone, UserGuide, UserGuide.getGem, NetworkCmdType.req_guidence_gemstone);
	self:RegisterEvent(NetworkCmdType.ret_guidence_refine, UserGuide, UserGuide.getRefine, NetworkCmdType.req_guidence_refine);--]]
	self:RegisterEvent(NetworkCmdType.ret_guidence_pub, NetworkMsg_Pub, NetworkMsg_Pub.onGuidenceHireHero, NetworkCmdType.req_guidence_pub);
	self:RegisterEvent(NetworkCmdType.ret_random_name, UserGuide, UserGuide.onRandomName, NetworkCmdType.req_random_name);

	--商城
	self:RegisterEvent(NetworkCmdType.ret_shop_items, ShopSetPanel, ShopSetPanel.onReceiveGameShopItem, NetworkCmdType.req_shop_items);
	-- self:RegisterEvent(NetworkCmdType.ret_shop_items, ShopPanel, ShopPanel.onReceiveShopItems, NetworkCmdType.req_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_shop_buy, BuyUniversalPanel, BuyUniversalPanel.onBuyEnd, NetworkCmdType.req_shop_buy);
	self:RegisterEvent(NetworkCmdType.ret_buy_vip_info, NetworkMsg_GodsSenki, NetworkMsg_GodsSenki.onRetBuyVipInfo, NetworkCmdType.req_buy_vip_info);
	self:RegisterEvent(NetworkCmdType.ret_buy_bag_cap, PackagePanel, PackagePanel.BuyPackageResult, NetworkCmdType.req_buy_bag_cap);
	self:RegisterEvent(NetworkCmdType.nt_honor_change_t, PrestigeShopPanel, PrestigeShopPanel.onChangeShengwang);
	self:RegisterEvent(NetworkCmdType.nt_unhonor_change_t, PrestigeShopPanel, PrestigeShopPanel.onUnChangeShengwang);
	self:RegisterEvent(NetworkCmdType.nt_meritorious_t, PrestigeShopPanel, PrestigeShopPanel.onChangeMeritorious);
	self:RegisterEvent(NetworkCmdType.nt_titleup_t, PrestigeShopPanel, PrestigeShopPanel.onChangeTitleLevel);

	--npc商店
	self:RegisterEvent(NetworkCmdType.ret_npc_shop_items, ShopSetPanel, ShopSetPanel.onReceiveMysteryShopItem, NetworkCmdType.req_npc_shop_items);
	-- self:RegisterEvent(NetworkCmdType.ret_npc_shop_items, NpcShopPanel, NpcShopPanel.onReceiveShopItems, NetworkCmdType.req_npc_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_npcshop_buy, ShopSetPanel, ShopSetPanel.onBuyEnd, NetworkCmdType.req_npcshop_buy);
	-- self:RegisterEvent(NetworkCmdType.ret_npcshop_buy, NpcShopPanel, NpcShopPanel.onBuyEnd, NetworkCmdType.req_npcshop_buy);
	self:RegisterEvent(NetworkCmdType.ret_npcshop_refresh, ShopSetPanel, ShopSetPanel.onRefresh, NetworkCmdType.req_npcshop_refresh);
	-- self:RegisterEvent(NetworkCmdType.ret_npcshop_refresh, NpcShopPanel, NpcShopPanel.onRefresh, NetworkCmdType.req_npcshop_refresh);

	--充值
	self:RegisterEvent(NetworkCmdType.ret_pay, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onPayResult, NetworkCmdType.req_pay);
	self:RegisterEvent(NetworkCmdType.nt_vip_levelup, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onVipLevelUp);
	self:RegisterEvent(NetworkCmdType.nt_vip_exp_changed, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onVipExpChanged);
	self:RegisterEvent(NetworkCmdType.ret_mcard_info, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onReceiveMCardInfo);
	self:RegisterEvent(NetworkCmdType.nt_mcard_info, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onReceiveMCardInfo);
	self:RegisterEvent(NetworkCmdType.ret_mcard_reward, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onReceiveMCardReward, NetworkCmdType.req_mcard_reward);
	self:RegisterEvent(NetworkCmdType.nt_first_pay, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onFristPay);
	self:RegisterEvent(NetworkCmdType.nt_daily_pay_t, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onDailyPay);


	--迷窟
	self:RegisterEvent(NetworkCmdType.ret_cave_enter, NetworkMsg_Miku, NetworkMsg_Miku.onEnterBattle);
	self:RegisterEvent(NetworkCmdType.ret_cave_exit, FightOverUIManager, FightOverUIManager.OnReceiveFightOverMessage);
	self:RegisterEvent(NetworkCmdType.ret_cave_flush, NetworkMsg_Miku, NetworkMsg_Miku.onResetCave, NetworkCmdType.req_cave_flush);
	self:RegisterEvent(NetworkCmdType.ret_cave_pass, NetworkMsg_Miku, NetworkMsg_Miku.onHangUpInfo, NetworkCmdType.req_cave_pass);
	self:RegisterEvent(NetworkCmdType.ret_cave_pass_clear_cd, NetworkMsg_Miku, NetworkMsg_Miku.onHangUpClearCd, NetworkCmdType.req_cave_pass_clear_cd);

	--========================================================================

	--活动
	self:RegisterEvent(NetworkCmdType.ret_reward, NetworkMsg_Promotion, NetworkMsg_Promotion.onReturnReward, NetworkCmdType.req_reward);
	self:RegisterEvent(NetworkCmdType.nt_reward, NetworkMsg_Promotion, NetworkMsg_Promotion.onRefreshActivityFlag);
	self:RegisterEvent(NetworkCmdType.nt_reward_partner, NetworkMsg_Promotion, NetworkMsg_Promotion.onReceiveActivityPartner);
	self:RegisterEvent(NetworkCmdType.ret_cumulogin_reward_t, ActivityAllPanel, ActivityAllPanel.RetLoginReward);
	self:RegisterEvent(NetworkCmdType.ret_cumu_yb_reward_t, ActivityAllPanel, ActivityAllPanel.GotSumConsumeRes);
	self:RegisterEvent(NetworkCmdType.ret_daily_pay_reward_t, ActivityAllPanel, ActivityRechargePanel.GotDailyConsumeRes, NetworkCmdType.req_daily_pay_reward_t);
	self:RegisterEvent(NetworkCmdType.ret_cumu_yb_rank, NetworkMsg_Promotion, NetworkMsg_Promotion.onGetTotalConsumptionRank);
	self:RegisterEvent(NetworkCmdType.nt_mcard_event_t, ActivityRechargePanel, ActivityRechargePanel.onGetMcardEventOk);
	self:RegisterEvent(NetworkCmdType.ret_gacha_wing, WingActivityPanel, WingActivityPanel.GotGachaWing);
	self:RegisterEvent(NetworkCmdType.ret_get_wing, WingActivityPanel, WingActivityPanel.GotWingReward);
	self:RegisterEvent(NetworkCmdType.ret_wing_rank, WingActivityPanel, WingActivityPanel.GotWingRank);

	--炼金
	self:RegisterEvent(NetworkCmdType.ret_buy_coin, NetworkMsg_Promotion, NetworkMsg_Promotion.onReturnBuyCoin);

	--吃披萨
	self:RegisterEvent(NetworkCmdType.ret_given_power_reward, NetworkMsg_Promotion, NetworkMsg_Promotion.onGivenPowerReward, NetworkCmdType.req_given_power_reward);
	self:RegisterEvent(NetworkCmdType.ret_reward_power_cd, NetworkMsg_Promotion, NetworkMsg_Promotion.onRewardPowerCd, NetworkCmdType.req_reward_power_cd);

	--在线奖励
	self:RegisterEvent(NetworkCmdType.ret_online_reward_cd, NetworkMsg_Promotion, NetworkMsg_Promotion.onOnlineRewardCd, NetworkCmdType.req_online_reward_cd);
	self:RegisterEvent(NetworkCmdType.ret_online_reward, NetworkMsg_Promotion, NetworkMsg_Promotion.onGetOnlineReward, NetworkCmdType.req_online_reward);
	self:RegisterEvent(NetworkCmdType.ret_online_reward_num, NetworkMsg_Promotion, NetworkMsg_Promotion.onOnlineRewardNum, NetworkCmdType.req_online_reward_num);
	--========================================================================

	--领取序列号
	self:RegisterEvent(NetworkCmdType.ret_cdkey_reward, NetworkMsg_Item, NetworkMsg_Item.onShowExchangeGift, NetworkCmdType.req_cdkey_reward);

	--竞技场
	 -- self:RegisterEvent(NetworkCmdType.ret_rank_reward, NetworkMsg_Arena, NetworkMsg_Arena.onRankRewardInfo, NetworkCmdType.req_rank_reward);
	 -- self:RegisterEvent(NetworkCmdType.ret_given_rank_reward, NetworkMsg_Arena, NetworkMsg_Arena.onGetRankReward, NetworkCmdType.req_given_rank_reward);

	--12点累积登录奖励刷新
	self:RegisterEvent(NetworkCmdType.ret_lg_rewardinfo, NetworkMsg_Promotion, NetworkMsg_Promotion.onRefreshAccuReward, NetworkCmdType.req_lg_rewardinfo);

	--领取vip奖励
	self:RegisterEvent(NetworkCmdType.ret_given_vip_reward_t, VipPanel, VipPanel.HandleGivenVip, NetworkCmdType.req_given_vip_reward_t);

	--支付
	self:RegisterEvent(NetworkCmdType.ret_buy_yb, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onRechargeOrder, NetworkCmdType.req_buy_yb);
	self:RegisterEvent(NetworkCmdType.ret_yb_repo, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onRechargeInfo, NetworkCmdType.req_yb_repo);
	self:RegisterEvent(NetworkCmdType.nt_payyb_change, NetworkMsg_PayAndVip, NetworkMsg_PayAndVip.onRechargSuccess);

	--符文
	self:RegisterEvent(NetworkCmdType.ret_rune_info, NetworkMsg_Rune, NetworkMsg_Rune.onGetMonsters, NetworkCmdType.req_rune_info);
	self:RegisterEvent(NetworkCmdType.ret_rune_switchpos, NetworkMsg_Rune, NetworkMsg_Rune.onSwitchPosition, NetworkCmdType.req_rune_switchpos);
	self:RegisterEvent(NetworkCmdType.ret_rune_eatall, NetworkMsg_Rune, NetworkMsg_Rune.onEatAll, NetworkCmdType.req_rune_eatall);
	self:RegisterEvent(NetworkCmdType.ret_rune_huntsome, NetworkMsg_Rune, NetworkMsg_Rune.onHuntSome);
	self:RegisterEvent(NetworkCmdType.nt_rune_change, NetworkMsg_Rune, NetworkMsg_Rune.onRuneChange);
	self:RegisterEvent(NetworkCmdType.ret_rune_callboss, NetworkMsg_Rune, NetworkMsg_Rune.onCallBoss, NetworkCmdType.req_rune_callboss);
	self:RegisterEvent(NetworkCmdType.nt_runechip_change, NetworkMsg_Rune, NetworkMsg_Rune.onChipChange);
	self:RegisterEvent(NetworkCmdType.ret_rune_buy, NetworkMsg_Rune, NetworkMsg_Rune.onRuneBuy, NetworkCmdType.req_rune_buy);
	self:RegisterEvent(NetworkCmdType.ret_rune_close, NetworkMsg_Rune, RunePanel.onRuneChangeClose, NetworkCmdType.req_rune_close);

	--好友邀请
	self:RegisterEvent(NetworkCmdType.ret_invcode, NetworkMsg_Friend, NetworkMsg_Friend.onFriendInviteStatus, NetworkCmdType.req_invcode);
	self:RegisterEvent(NetworkCmdType.ret_invcode_reward, NetworkMsg_Friend, NetworkMsg_Friend.onFriendInviteReward, NetworkCmdType.req_invcode_reward);
	self:RegisterEvent(NetworkCmdType.ret_invcode_set, NetworkMsg_Friend, NetworkMsg_Friend.onVerifyInviteCode, NetworkCmdType.req_invcode_set);

	--星魂
	self:RegisterEvent(NetworkCmdType.ret_star_open_t, XinghunPanel, XinghunPanel.onOpenReturn);
	self:RegisterEvent(NetworkCmdType.ret_star_flush_t, StarMapPanel, StarMapPanel.GotRefreshHeroStar);
	self:RegisterEvent(NetworkCmdType.ret_star_set_t, XinghunPanel, XinghunPanel.onSetReturn);
	self:RegisterEvent(NetworkCmdType.ret_star_get_t, XinghunPanel, XinghunPanel.onGetReturn);

	--排行榜
	self:RegisterEvent(NetworkCmdType.ret_fp_rank_t, RankPanel, RankPanel.GotFpRankMsg);
	self:RegisterEvent(NetworkCmdType.ret_lv_rank_t, RankPanel, RankPanel.GotLvRankMsg);

	--抽卡排行
	self:RegisterEvent(NetworkCmdType.ret_pub_rank_t, OpenServiceRewardPanel, OpenServiceRewardPanel.limitpubReward);

	--杀星
	self:RegisterEvent(NetworkCmdType.ret_city_boss_info_t, StarKillBossMgr, StarKillBossMgr.GotRequestBossDataRes, NetworkCmdType.req_city_boss_info_t);
	self:RegisterEvent(NetworkCmdType.ret_fight_city_boss, NetworkMsg_KillBoss, NetworkMsg_KillBoss.InvasionFightOver, NetworkCmdType.req_fight_city_boss);
	self:RegisterEvent(NetworkCmdType.ret_begin_fight_city_boss, NetworkMsg_KillBoss, NetworkMsg_KillBoss.onInvasionFight, NetworkCmdType.req_begin_fight_city_boss);
	self:RegisterEvent(NetworkCmdType.nt_city_boss_state_t, StarKillBossMgr, StarKillBossMgr.onUpdateBossStatus);


	--等级奖励
	self:RegisterEvent(NetworkCmdType.ret_lv_reward, NetworkMsg_GodsSenki, NetworkMsg_GodsSenki.onGetLevelReward, NetworkCmdType.req_lv_reward);

	--图纸合成
	self:RegisterEvent(NetworkCmdType.ret_compose_drawing_t, DrawingSynthesisPanel, DrawingSynthesisPanel.OnGotGeneratePaperRes, NetworkCmdType.req_compose_drawing_t);

	--领取金色英雄
	self:RegisterEvent(NetworkCmdType.nt_conlogin_hero_t, ActivityAllPanel, ActivityAllPanel.OnGetGoldHero);

	self:RegisterEvent(NetworkCmdType.ret_prestige_shop_items, ShopSetPanel, ShopSetPanel.onReceivePvpShopItem, NetworkCmdType.req_prestige_shop_items);
	-- self:RegisterEvent(NetworkCmdType.ret_prestige_shop_items, PrestigeShopPanel, PrestigeShopPanel.shopItems, NetworkCmdType.req_prestige_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_prestige_shop_buy, ShopSetPanel, ShopSetPanel.buyResult, NetworkCmdType.req_prestige_shop_buy);
	-- self:RegisterEvent(NetworkCmdType.ret_prestige_shop_buy, PrestigeShopPanel, PrestigeShopPanel.buyResult, NetworkCmdType.req_prestige_shop_buy);

	--碎片商店
	self:RegisterEvent(NetworkCmdType.ret_chip_shop_items, ShopSetPanel, ShopSetPanel.onReceiveDebrisSplitShopItem, NetworkCmdType.req_chip_shop_items);
	-- self:RegisterEvent(NetworkCmdType.ret_chip_shop_items, ChipShopPanel, ChipShopPanel.shopItems, NetworkCmdType.req_chip_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_chip_shop_buy, ShopSetPanel, ShopSetPanel.buyResultChip, NetworkCmdType.req_chip_shop_buy);
	-- self:RegisterEvent(NetworkCmdType.ret_chip_shop_buy, ChipShopPanel, ChipShopPanel.buyResult, NetworkCmdType.req_chip_shop_buy);
	self:RegisterErrorEvent(NetworkCmdType.ret_chip_shop_buy, ShopSetPanel, ShopSetPanel.buyResultErrorChip);
	-- self:RegisterErrorEvent(NetworkCmdType.ret_chip_shop_buy, ChipShopPanel, ChipShopPanel.buyResultError);

	--碎片兑换
	self:RegisterEvent(NetworkCmdType.ret_chip_smash_items, ChipShopPanel, ChipSmashPanel.Show, NetworkCmdType.req_chip_smash_items);
	self:RegisterEvent(NetworkCmdType.ret_chip_smash_buy, ChipShopPanel, ChipSmashPanel.buyResult, NetworkCmdType.req_chip_smash_buy);
	self:RegisterEvent(NetworkCmdType.nt_chip_value_change, NetworkMsg_Data, NetworkMsg_Data.ChipValueUpdate);
	self:RegisterErrorEvent(NetworkCmdType.ret_chip_smash_buy, ChipShopPanel, ChipSmashPanel.buyResultError);

	--远征
	self:RegisterEvent(NetworkCmdType.ret_expedition_t, ExpeditionPanel, ExpeditionPanel.onHandleExpedition, NetworkCmdType.req_expedition_t);
	self:RegisterEvent(NetworkCmdType.ret_expedition_round_t, SelectActorPanel, SelectActorPanel.ExpeditionEnemys, NetworkCmdType.req_expedition_round_t);
	self:RegisterEvent(NetworkCmdType.ret_expedition_team_t, NetworkMsg_Expedition, NetworkMsg_Expedition.onHandleExpeditionTeam, NetworkCmdType.req_expedition_team_t);
	self:RegisterEvent(NetworkCmdType.nt_expedition_team_change_t, NetworkMsg_Team, NetworkMsg_Team.onExpeditionChangeTeam);
	self:RegisterEvent(NetworkCmdType.ret_expedition_round_reward_t, ExpeditionPanel, ExpeditionPanel.onHandleReward, NetworkCmdType.req_expedition_round_reward_t);
	self:RegisterEvent(NetworkCmdType.ret_enter_expedition_round_t, NetworkMsg_Expedition, NetworkMsg_Expedition.onHandleEnter, NetworkCmdType.req_enter_expedition_round_t);
	self:RegisterEvent(NetworkCmdType.ret_expedition_partners_t, Expedition, Expedition.onHandlePartners, NetworkCmdType.req_expedition_partners_t);
	self:RegisterEvent(NetworkCmdType.ret_exit_expedition_round_t, FightOverUIManager, FightOverUIManager.OnReceiveFightOverMessage, NetworkCmdType.req_exit_expedition_round_t);
	self:RegisterEvent(NetworkCmdType.ret_round_exit, FightOverUIManager, FightOverUIManager.OnReceiveFightOverMessage);
	self:RegisterEvent(NetworkCmdType.ret_expedition_reset_t, ExpeditionPanel, ExpeditionPanel.onHandleReset, NetworkCmdType.req_expedition_reset_t);
	self:RegisterEvent(NetworkCmdType.nt_expeditioncoin_t, NetworkMsg_Data, NetworkMsg_Data.onChangeExpeditionCoin);
	self:RegisterEvent(NetworkCmdType.ret_sweep_expedition, ExpeditionPanel, ExpeditionPanel.sweepRoundCallBack);
	self:RegisterErrorEvent(NetworkCmdType.ret_sweep_expedition);

	--远征商店
	self:RegisterEvent(NetworkCmdType.ret_expedition_shop_items, ShopSetPanel, ShopSetPanel.onReceiveExpeditionShopItem, NetworkCmdType.req_expedition_shop_items);
	-- self:RegisterEvent(NetworkCmdType.ret_expedition_shop_items, ExpeditionShopPanel, ExpeditionShopPanel.onReceiveShopItems, NetworkCmdType.req_expedition_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_expedition_shop_buy, ShopSetPanel, ShopSetPanel.onBuyEndYuanZheng, NetworkCmdType.req_expedition_shop_buy);
	-- self:RegisterEvent(NetworkCmdType.ret_expedition_shop_buy, ExpeditionShopPanel, ExpeditionShopPanel.onBuyEnd, NetworkCmdType.req_expedition_shop_buy);
	self:RegisterEvent(NetworkCmdType.nt_expedition_shop_reset_t, ExpeditionShopPanel, ExpeditionShopPanel.onExpeditionShopReset);
	self:RegisterErrorEvent(NetworkCmdType.ret_expedition_shop_buy, ShopSetPanel, ShopSetPanel.onBuyError);
	-- self:RegisterErrorEvent(NetworkCmdType.ret_expedition_shop_buy, ExpeditionShopPanel, ExpeditionShopPanel.onBuyError);

	-- 公会商店
	self:RegisterEvent(NetworkCmdType.ret_guild_shop_items, ShopSetPanel, ShopSetPanel.onReceiveGuildShopItem, NetworkCmdType.req_guild_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_guild_shop_buy_items, ShopSetPanel, ShopSetPanel.onGuildBuyEnd, NetworkCmdType.req_guild_shop_buy_items);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_shop_buy_items, ShopSetPanel, ShopSetPanel.onBuyError);

	-- 符文商店
	self:RegisterEvent(NetworkCmdType.ret_rune_shop_items, ShopSetPanel, ShopSetPanel.onReceiveRuneShopItem, NetworkCmdType.req_rune_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_rune_shop_buy_items, ShopSetPanel, ShopSetPanel.onRuneBuyEnd, NetworkCmdType.req_rune_shop_buy_items);
	self:RegisterErrorEvent(NetworkCmdType.ret_rune_shop_buy_items, ShopSetPanel, ShopSetPanel.onBuyError);

	-- 活动商店
	self:RegisterEvent(NetworkCmdType.ret_cardevent_shop_item, ShopSetPanel, ShopSetPanel.onReceiveCardEventShopItem, NetworkCmdType.req_cardevent_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_cardevent_shop_buy_items, ShopSetPanel, ShopSetPanel.onCardEventBuyEnd, NetworkCmdType.req_cardevent_shop_buy_items);
	self:RegisterErrorEvent(NetworkCmdType.ret_cardevent_shop_item, ShopSetPanel, ShopSetPanel.onCardEventBuyError);
	self:RegisterErrorEvent(NetworkCmdType.ret_cardevent_shop_buy_items, ShopSetPanel, ShopSetPanel.onBuyError);

	-- 活动商店
	self:RegisterEvent(NetworkCmdType.ret_lmt_shop_item, ShopSetPanel, ShopSetPanel.onReceiveLmtItem, NetworkCmdType.req_lmt_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_lmt_shop_buy_items, ShopSetPanel, ShopSetPanel.onLmtBuyEnd, NetworkCmdType.req_lmt_shop_buy_items);
	self:RegisterErrorEvent(NetworkCmdType.ret_lmt_shop_buy_items, ShopSetPanel, ShopSetPanel.onBuyError);


	self:RegisterEvent(NetworkCmdType.ret_naviclicknum_add, NetworkMsg_Data, NetworkMsg_Data.onnaviClickNumAdd, NetworkCmdType.req_naviclicknum_add);

	-- 卡牌活动
  self:RegisterEvent(NetworkCmdType.nt_card_event_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.notice)
  self:RegisterEvent(NetworkCmdType.nt_card_event_coin_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.coin)
  self:RegisterEvent(NetworkCmdType.nt_card_event_score_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.score)
  self:RegisterEvent(NetworkCmdType.nt_card_event_open_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.open)
  self:RegisterEvent(NetworkCmdType.nt_card_event_drop_item_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.drop)
  self:RegisterEvent(NetworkCmdType.nt_card_event_change_team_t,
                     NetworkMsg_Team,
                     NetworkMsg_Team.onCardEventChangeTeam);
  self:RegisterEvent(NetworkCmdType.ret_card_event_open_round_t,
                     CardEventPanel,
                     CardEventPanel.retOpen,
                     NetworkCmdType.req_card_event_open_round_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_open_round_t)
  self:RegisterEvent(NetworkCmdType.ret_card_event_fight_t,
                     NetworkMsg_CardEvent,
                     NetworkMsg_CardEvent.fight,
                     NetworkCmdType.req_card_event_fight_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_fight_t)
	self:RegisterEvent(NetworkCmdType.ret_card_event_round_exit_t,
                     FightOverUIManager,
                     FightOverUIManager.OnReceiveFightOverMessage,
                     NetworkCmdType.req_card_event_round_exit_t);
  self:RegisterEvent(NetworkCmdType.ret_card_event_reset_t,
                     CardEventPanel,
                     CardEventPanel.retReset,
                     NetworkCmdType.req_card_event_reset_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_reset_t)
  self:RegisterEvent(NetworkCmdType.ret_card_event_round_enemy_t,
                     SelectActorPanel,
                     SelectActorPanel.CardEventEnemys,
                     NetworkCmdType.req_card_event_round_enemy_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_round_enemy_t)
  self:RegisterEvent(NetworkCmdType.ret_card_event_revive_t,
                     CardEvent,
                     CardEvent.Revive,
                     NetworkCmdType.req_card_event_revive_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_revive_t)
  self:RegisterEvent(NetworkCmdType.ret_card_event_rank_t,
                     RankPanel,
                     RankPanel.GotCardEventRankMsg,
                     NetworkCmdType.req_card_event_rank_t)
  self:RegisterErrorEvent(NetworkCmdType.ret_card_event_rank_t)
  self:RegisterEvent(NetworkCmdType.ret_card_event_sweep_t,CardEvent,CardEvent.retSweep,NetworkCmdType.req_card_event_sweep_t);
  self:RegisterEvent(NetworkCmdType.ret_next_card_event_t,CardEvent,CardEvent.retNextRound,NetworkCmdType.req_next_card_event_t);
  self:RegisterEvent(NetworkCmdType.ret_card_event_first_enter,CardEvent,CardEvent.retFirstEnter,NetworkCmdType.req_card_event_first_enter);
  self:RegisterEvent(NetworkCmdType.nt_card_event_change_state,CardEvent,CardEvent.change_state);
  self:RegisterEvent(NetworkCmdType.nt_card_event_get_reward,CardEventPanel,CardEventPanel.setRewardNT);
  self:RegisterEvent(NetworkCmdType.nt_card_event_get_level,CardEventPanel,CardEventPanel.setRewardLevel);
  --


	self:RegisterEvent(NetworkCmdType.ret_change_roletype_t,NetworkMsg_Data,NetworkMsg_Data.change_roletype,NetworkCmdType.req_change_roletype_t)


	self:RegisterEvent(NetworkCmdType.nt_soulvalue_change_t,NetworkMsg_Data,NetworkMsg_Data.nt_soulvalue_change);
	self:RegisterEvent(NetworkCmdType.nt_soulinfo_change_t,NetworkMsg_Data,NetworkMsg_Data.nt_soulinfo_change);
	self:RegisterEvent(NetworkCmdType.ret_open_soulid,NetworkMsg_Data,NetworkMsg_Data.ret_soulid_open,NetworkCmdType.req_open_soulid);
	self:RegisterErrorEvent(NetworkCmdType.ret_open_soulid, NetworkMsg_Data, NetworkMsg_Data.retsoulidopenError);
	self:RegisterEvent(NetworkCmdType.ret_soulnode_pro,NetworkMsg_Data,NetworkMsg_Data.ret_soulnode_pro,NetworkCmdType.req_soulnode_pro);


	self:RegisterEvent(NetworkCmdType.nt_wingactivity_change_t,OpenServiceRewardPanel,OpenServiceRewardPanel.wingactivityChanged)

    self:RegisterEvent(NetworkCmdType.nt_sevenpay_change_t,OpenServiceRewardPanel,OpenServiceRewardPanel.sevenpayChanged)

	self:RegisterEvent(NetworkCmdType.nt_seven_pay_change,ActivityRechargePanel,ActivityRechargePanel.sevenpayChanged)

	self:RegisterErrorEvent(NetworkCmdType.ret_fuhuo, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onRevive);

	self:RegisterErrorEvent(NetworkCmdType.ret_send_flower, Friend, Friend.onRetSendFlowerError);

	self:RegisterErrorEvent(NetworkCmdType.ret_receive_flower, Friend, Friend.onRetReceiveFlower);
	--==========================================================================================================================
	--==========================================================================================================================
	--错误消息处理函数
  -- 说明！！: 此处仅处理通用错误消息处理，若处理完默认消息后仍然有其他内容
  -- 需要处理，则使用原有方案处理 例:WOUBossPanel:EnterBossBattleFailed(msg)
  -- NetworkMsg_KillBoss:onInvasionFightError(msg)
	--Login 重名判断
	self:RegisterErrorEvent(NetworkCmdType.ret_new_role);
	--巨龙宝库
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_occupy);
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_fight);
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_help);
	self:RegisterErrorEvent(NetworkCmdType.ret_change_roletype_t, NetworkMsg_Data, NetworkMsg_Data.onRolechangeError);
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_rob);
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_slot_rewd);
	--装备强化
	self:RegisterErrorEvent(NetworkCmdType.ret_upgrade_equip);
	--星魂
	self:RegisterErrorEvent(NetworkCmdType.ret_star_open_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_star_flush_t);
	--酒馆
	self:RegisterErrorEvent(NetworkCmdType.ret_pub_flush_t);
	--邀请码
	self:RegisterErrorEvent(NetworkCmdType.ret_invcode_set);
	--鼓舞
	self:RegisterErrorEvent(NetworkCmdType.ret_guwu);
	--远征
	self:RegisterErrorEvent(NetworkCmdType.ret_expedition_team_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_expedition_round_reward_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_expedition_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_expedition_reset_t);
	--任务
	self:RegisterErrorEvent(NetworkCmdType.ret_act_reward);
  --限时副本
	self:RegisterErrorEvent(NetworkCmdType.ret_limit_round_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_limit_quit_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_clear_lmt_cd);
  --声望商店
	self:RegisterErrorEvent(NetworkCmdType.ret_prestige_shop_buy);
	--战斗
	self:RegisterErrorEvent(NetworkCmdType.ret_round_enter, Loading, Loading.LoadingQuit);
	--self:RegisterErrorEvent(NetworkCmdType.ret_begin_arena_fight, Loading, Loading.LoadingQuit);
	self:RegisterErrorEvent(NetworkCmdType.ret_trial_start_batt, Loading, Loading.LoadingQuit);
	--boss战斗出错
	self:RegisterErrorEvent(NetworkCmdType.ret_boss_start_batt, WOUBossPanel, WOUBossPanel.EnterBossBattleFailed);
	--公会
	self:RegisterErrorEvent(NetworkCmdType.ret_add_gang, NetworkMsg_Union, NetworkMsg_Union.ononApplyFailed);
	-- self:RegisterErrorEvent(NetworkCmdType.ret_rank_reward, RewardArenaPanel, RewardArenaPanel.ArenaRewardNoExist);
	--杀星
	self:RegisterErrorEvent(NetworkCmdType.ret_begin_fight_city_boss, NetworkMsg_KillBoss, NetworkMsg_KillBoss.onInvasionFightError);
  --升星
  self:RegisterErrorEvent(NetworkCmdType.ret_quality_up, CardRankupPanel, CardRankupPanel.upCardRankUpCallBack);
	--乱斗场
	self:RegisterErrorEvent(NetworkCmdType.ret_fuhuo, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onRevive);

	--潜力升级
	self:RegisterErrorEvent(NetworkCmdType.ret_potential_up, NetworkMsg_Data, NetworkMsg_Data.onChangePotentialError);


	--竞技场打的人正在打别人
	self:RegisterErrorEvent(NetworkCmdType.ret_begin_arena_fight, NetworkMsg_Arena, NetworkMsg_Arena.in_fight);
	--探宝重置
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_reset);
	self:RegisterErrorEvent(NetworkCmdType.ret_change_name);
	self:RegisterErrorEvent(NetworkCmdType.ret_round_pass);
	self:RegisterErrorEvent(NetworkCmdType.ret_treasure_giveup_help);
	self:RegisterErrorEvent(NetworkCmdType.ret_open_service_reward);
	self:RegisterErrorEvent(NetworkCmdType.ret_buy_growing_package);
	self:RegisterErrorEvent(NetworkCmdType.ret_deal_gang_req);
	self:RegisterErrorEvent(NetworkCmdType.ret_praise_comment);
	self:RegisterErrorEvent(NetworkCmdType.ret_get_luckybag_reward);

	--补签
	self:RegisterErrorEvent(NetworkCmdType.ret_sign_remedy);
	--==========================================================================================================================
	--==========================================================================================================================

	--乱斗场
	self:RegisterEvent(NetworkCmdType.ret_scuffle_regist, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onScuffleRegist, NetworkCmdType.req_scuffle_regist);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_regist);
	self:RegisterEvent(NetworkCmdType.ret_scuffle_leave_scene, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onLeaveScene, NetworkCmdType.req_scuffle_leave_scene);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_leave_scene);
	--self:RegisterEvent(NetworkCmdType.ret_scuffle_battle, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onScuffleBattle, NetworkCmdType.req_scuffle_battle);
	self:RegisterEvent(NetworkCmdType.ret_scuffle_battle, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onHandleEnter, NetworkCmdType.req_scuffle_battle);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_battle);
	self:RegisterEvent(NetworkCmdType.ret_scuffle_battle_end, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onScuffleBattleEnd, NetworkCmdType.req_scuffle_battle_end);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_battle_end);
	self:RegisterEvent(NetworkCmdType.nt_scuffle_hero_in, NetworkMsg_EnterGame, NetworkMsg_EnterGame.onOtherPlayerEnterScuffle);
	self:RegisterEvent(NetworkCmdType.nt_scuffle_hero_change, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onPlayerStatusChange);
	self:RegisterEvent(NetworkCmdType.ret_scuffle_ranking, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onGetRanking, NetworkCmdType.req_scuffle_ranking);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_ranking);
	self:RegisterEvent(NetworkCmdType.nt_scuffle_end, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onScuffleEnd);
	self:RegisterEvent(NetworkCmdType.ret_scuffle_state, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onGetEndStatus, NetworkCmdType.req_scuffle_state);
	self:RegisterErrorEvent(NetworkCmdType.ret_scuffle_state);
	self:RegisterEvent(NetworkCmdType.nt_score_ranking, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onScoreRank);
	self:RegisterEvent(NetworkCmdType.ret_fuhuo, NetworkMsg_Scuffle, NetworkMsg_Scuffle.onRevive, NetworkCmdType.req_fuhuo);
	self:RegisterErrorEvent(NetworkCmdType.ret_fuhuo);
	--领取战斗力冲刺活动奖励
	self:RegisterEvent(NetworkCmdType.ret_fp_reward, NetworkMsg_Promotion, NetworkMsg_Promotion.onGetFightReward, NetworkCmdType.req_fp_reward);

	--开宝箱
	self:RegisterEvent(NetworkCmdType.ret_use_item_t, NetworkMsg_Item, NetworkMsg_Item.onUseItemCallBack, NetworkCmdType.req_use_item_t);

	--邮箱
	self:RegisterEvent(NetworkCmdType.ret_gmail_list, NetworkMsg_Email, NetworkMsg_Email.onGetEmailList, NetworkCmdType.req_gmail_list);
	self:RegisterEvent(NetworkCmdType.ret_gmail_reward, NetworkMsg_Email, NetworkMsg_Email.onGetEmailRewards, NetworkCmdType.req_gmail_reward);
	self:RegisterEvent(NetworkCmdType.nt_new_gmail, NetworkMsg_Email, NetworkMsg_Email.onNewEmail);
	self:RegisterEvent(NetworkCmdType.ret_gmail_delete, NetworkMsg_Email, NetworkMsg_Email.ondeleteEmail, NetworkCmdType.req_gmail_delete);
	self:RegisterEvent(NetworkCmdType.ret_getallreward, NetworkMsg_Email, NetworkMsg_Email.onAllReward, NetworkCmdType.ret_getallreward);

	--限时副本
	self:RegisterEvent(NetworkCmdType.ret_limit_round_t, NetworkMsg_LimitRound, NetworkMsg_LimitRound.onEnterBattle);
	self:RegisterEvent(NetworkCmdType.ret_limit_quit_t, FightOverUIManager, FightOverUIManager.OnReceiveFightOverMessage);
	self:RegisterEvent(NetworkCmdType.ret_clear_lmt_cd, NetworkMsg_LimitRound, NetworkMsg_LimitRound.clearCD);
	self:RegisterEvent(NetworkCmdType.ret_limit_round_data, NetworkMsg_LimitRound, NetworkMsg_LimitRound.retLimitRoundData);
	self:RegisterEvent(NetworkCmdType.ret_reset_limit_round, NetworkMsg_LimitRound, NetworkMsg_LimitRound.retResetLimitRoundData);
	self:RegisterErrorEvent(NetworkCmdType.ret_reset_limit_round);
	--翅膀
	self:RegisterEvent(NetworkCmdType.ret_wear_wing, NetworkMsg_Wing, NetworkMsg_Wing.onWearWing, NetworkCmdType.req_wear_wing);
	self:RegisterEvent(NetworkCmdType.ret_compose_wing, NetworkMsg_Wing, NetworkMsg_Wing.onComposeWing, NetworkCmdType.req_compose_wing);
	self:RegisterEvent(NetworkCmdType.ret_sell_wing, PackagePanel, PackagePanel.onSellWing, NetworkCmdType.req_sell_wing);

	-- 宠物
	self:RegisterEvent(NetworkCmdType.ret_compose_pet, PetModule, PetModule.onComposeCallback, NetworkCmdType.req_compose_pet);
	self:RegisterErrorEvent(NetworkCmdType.ret_compose_pet);
	---------------------------------------------------------------------------------------
	--新协议
	--编年史
	self:RegisterEvent(NetworkCmdType.ret_chronicle, NetworkMsg_Chronicle, NetworkMsg_Chronicle.retChronicle, NetworkCmdType.req_chronicle);
	self:RegisterEvent(NetworkCmdType.ret_chronicle_sign, NetworkMsg_Chronicle, NetworkMsg_Chronicle.retChronicleSign, NetworkCmdType.req_chronicle_sign);
	self:RegisterEvent(NetworkCmdType.ret_chronicle_sign_retrieve, NetworkMsg_Chronicle, NetworkMsg_Chronicle.retChronicleSignRetrieve, NetworkCmdType.req_chronicle_sign_retrieve);
	self:RegisterEvent(NetworkCmdType.ret_chronicle_sign_all, NetworkMsg_Chronicle, NetworkMsg_Chronicle.retChronicleSignAll, NetworkCmdType.req_chronicle_sign_all);

	--爱恋度
	self:RegisterEvent(NetworkCmdType.ret_love_task_list, NetworkMsg_LoveTask, NetworkMsg_LoveTask.retLoveTask, NetworkCmdType.req_love_task_list);
	self:RegisterEvent(NetworkCmdType.ret_commit_love_task, NetworkMsg_LoveTask, NetworkMsg_LoveTask.retCommitLoveTask, NetworkCmdType.req_commit_love_task);
	self:RegisterErrorEvent(NetworkCmdType.ret_commit_love_task);
	self:RegisterEvent(NetworkCmdType.nt_love_task_change, NetworkMsg_LoveTask, NetworkMsg_LoveTask.onLoveTaskChange);
	self:RegisterEvent(NetworkCmdType.nt_change_lovelevel, NetworkMsg_Data, NetworkMsg_Data.onChangeLoveLevel);
	---------------------------------------------------------------------------------------
	--每日签到
	self:RegisterEvent(NetworkCmdType.ret_sign_reward, DailySignPanel, DailySignPanel.SignSucess, NetworkMsg_Task.req_sign_reward);
	self:RegisterEvent(NetworkCmdType.ret_sign_daily, DailySignPanel, DailySignPanel.getSignInfo, NetworkMsg_Task.req_sign_daily);
	self:RegisterEvent(NetworkCmdType.ret_sign_remedy, DailySignPanel, DailySignPanel.RemedySucess, NetworkMsg_Task.req_sign_remedy);
	--公会排行榜
	self:RegisterEvent(NetworkCmdType.ret_union_rank, RankPanel, RankPanel.GotUnionRankMsg, NetworkMsg_Task.req_union_rank);
	--卡牌排行榜
	self:RegisterEvent(NetworkCmdType.ret_card_rank, RankPanel, RankPanel.GotCardRankMsg, NetworkMsg_Task.req_card_rank);

	--请求弹幕
	self:RegisterEvent(NetworkCmdType.ret_bullets, NetworkMsg_Bullet, NetworkMsg_Bullet.retBullets, NetworkCmdType.req_bullets);
	--发送弹幕
	self:RegisterEvent(NetworkCmdType.ret_send_bullet, NetworkMsg_Bullet, NetworkMsg_Bullet.retSendBullet, NetworkCmdType.req_send_bullet);


	--请求记录完成新手引导状态
	self:RegisterEvent(NetworkCmdType.ret_write_guidence, UserGuidePanel, UserGuidePanel.retWriteGuidence, NetworkCmdType.req_write_guidence);

	--  探宝重置
	self:RegisterEvent(NetworkCmdType.ret_treasure_reset, TreasurePanel, TreasurePanel.onReceiveReset, NetworkCmdType.req_treasure_reset);

	--  改名功能
	self:RegisterEvent(NetworkCmdType.ret_change_name, PersonInfoPanel, PersonInfoPanel.onReceiveChangeName, NetworkCmdType.req_change_name);
	--探宝放弃协守去占领
	self:RegisterEvent(NetworkCmdType.ret_treasure_give_occupy, TreasurePanel, TreasurePanel.onReturnGiveupToOccupuy, NetworkCmdType.req_treasure_give_occupy);
	--请求竞技场冷却时间
	self:RegisterEvent(NetworkCmdType.ret_arena_cool_down, PersonInfoPanel, NetworkMsg_Arena.onGetCoolDown, NetworkCmdType.req_arena_cool_down);
	--探宝放弃协守
	self:RegisterEvent(NetworkCmdType.ret_treasure_giveup_help, TreasurePanel, TreasurePanel.receiveGiveupHelp, NetworkCmdType.req_treasure_giveup_help);
	--看板娘
	self:RegisterEvent(NetworkCmdType.ret_set_kanban_role, CardDetailPanel, CardDetailPanel.onRetKanbanInfo, NetworkCmdType.req_set_kanban_role);
	--开服活动
	self:RegisterEvent(NetworkCmdType.ret_open_service_reward, OpenServiceRewardPanel, OpenServiceRewardPanel.onGetRewardRet, NetworkCmdType.req_open_service_reward);
	--成长计划
	self:RegisterEvent(NetworkCmdType.ret_buy_growing_package, ActivityAllPanel, ActivityAllPanel.onRetBuyGrowingReward, NetworkCmdType.req_buy_growing_package);
	--评论卡牌
	self:RegisterEvent(NetworkCmdType.ret_comment_card, CardCommentPanel, CardCommentPanel.onRetComment, NetworkCmdType.req_comment_card);
	--请求最新卡牌评论信息
	self:RegisterEvent(NetworkCmdType.ret_newest_card_comment, CardCommentPanel, CardCommentPanel.onReceiveComment, NetworkCmdType.req_newest_card_comment);
	--请求玩家某个角色的属性
	self:RegisterEvent(NetworkCmdType.ret_index_role_info, CardCommentPanel, CardCommentPanel.onRetIndexRoleInfo, NetworkCmdType.req_index_role_info);
	--点赞
	self:RegisterEvent(NetworkCmdType.ret_praise_comment, CardCommentPanel, CardCommentPanel.onRetPraise, NetworkCmdType.req_praise_comment);
	--领取福袋奖励
	self:RegisterEvent(NetworkCmdType.ret_get_luckybag_reward, ActivityRechargePanel, ActivityRechargePanel.onRetLuckybagReward, NetworkCmdType.req_get_luckybag_reward);
	--领取中秋奖励
	self:RegisterEvent(NetworkCmdType.ret_get_midaut_reward, ActivityRechargePanel, ActivityRechargePanel.onRetMidAutReward, NetworkCmdType.req_get_midaut_reward);
	--pve战斗失败次数
	self:RegisterEvent(NetworkCmdType.ret_pvelose_times, PveLosePanel, PveLosePanel.onRetPveloseTimes, NetworkCmdType.req_pvelose_times);
	--累计充值
	self:RegisterEvent(NetworkCmdType.nt_recharge_activity, ActivityRechargePanel, ActivityRechargePanel.onRechargeChange);
	--每日体力
	self:RegisterEvent(NetworkCmdType.nt_daily_power_activity, ActivityRechargePanel, ActivityRechargePanel.onDailyPowerChange);
	--熔炼活动
	self:RegisterEvent(NetworkCmdType.nt_melting_activity, ActivityRechargePanel, ActivityRechargePanel.onMeltingChange);
	--天赋活动
	self:RegisterEvent(NetworkCmdType.nt_talent_activity, ActivityRechargePanel, ActivityRechargePanel.onTalentChange);
	--每日抽卡
	self:RegisterEvent(NetworkCmdType.nt_daily_draw_activity, ActivityRechargePanel, ActivityRechargePanel.onDailyDrawChange);
	--钻石消费
	self:RegisterEvent(NetworkCmdType.nt_openyb_t, ActivityRechargePanel, ActivityRechargePanel.onOpenybYbChange);
	--请求获得周礼包奖励
	self:RegisterEvent(NetworkCmdType.ret_get_weekly_reward, WeekRewardPanel, WeekRewardPanel.onRetGetReward, NetworkCmdType.req_get_weekly_reward);
	self:RegisterErrorEvent(NetworkCmdType.ret_get_weekly_reward);
	--获得在线礼包奖励
	self:RegisterEvent(NetworkCmdType.ret_get_online_reward, OnlineRewardPanel, OnlineRewardPanel.onRetGetReward, NetworkCmdType.req_get_online_reward);
	self:RegisterErrorEvent(NetworkCmdType.ret_get_online_reward);
	--单日充值
	self:RegisterEvent(NetworkCmdType.nt_single_activity, ActivityRechargePanel, ActivityRechargePanel.onOnceRechargeChange);
	--赛季排位
	self:RegisterEvent(NetworkCmdType.nt_rank_match_fight_t,NetworkMsg_Rank,NetworkMsg_Rank.onHandleEnter);
	self:RegisterEvent(NetworkCmdType.ret_rank_season_info_t,NetworkMsg_Rank,NetworkMsg_Rank.RankInfo,NetworkCmdType.req_rank_season_info_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_rank_season_info_t)
	self:RegisterEvent(NetworkCmdType.ret_rank_season_fight_end_t,FightOverUIManager,FightOverUIManager.OnReceiveFightOverMessage,NetworkCmdType.req_rank_season_fight_end_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_rank_season_fight_end_t)
	self:RegisterEvent(NetworkCmdType.ret_begin_rank_match_fight, NetworkMsg_Rank,NetworkMsg_Rank.onRetBeginFight, NetworkCmdType.req_begin_rank_match_fight);

	--晶魂
	self:RegisterEvent(NetworkCmdType.ret_get_soul_info, SoulPanel, SoulPanel.Show, NetworkCmdType.req_get_soul_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_get_soul_info);
	self:RegisterEvent(NetworkCmdType.ret_hunt_soul, SoulPanel, SoulPanel.Show, NetworkCmdType.req_hunt_soul);
	self:RegisterErrorEvent(NetworkCmdType.ret_hunt_soul);
	self:RegisterEvent(NetworkCmdType.ret_rankup_soul, SoulPanel, SoulPanel.Show, NetworkCmdType.req_rankup_soul);
	self:RegisterErrorEvent(NetworkCmdType.ret_rankup_soul);
	self:RegisterEvent(NetworkCmdType.ret_get_soul_reward, SoulPanel, SoulPanel.Show, NetworkCmdType.req_get_soul_reward);
	self:RegisterErrorEvent(NetworkCmdType.ret_get_soul_reward);

	
	--社团战
	self:RegisterEvent(NetworkCmdType.ret_union_battle_sign_up,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retEnlist,NetworkCmdType.req_union_battle_sign_up);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_sign_up);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_defence_pos_on,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retUpTeam,NetworkCmdType.req_union_battle_defence_pos_on);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_defence_pos_on);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_defence_pos_off,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retDownteam,NetworkCmdType.req_union_battle_defence_pos_off);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_defence_pos_off);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_cancel_other_pos,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retOtherDownTeam,NetworkCmdType.req_union_battle_cancel_other_pos);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_cancel_other_pos);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_defence_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.battleBuildingInfo,NetworkCmdType.req_union_battle_defence_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_defence_info);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_defence_info_fight,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.battleBuildingInfoFight,NetworkCmdType.req_union_battle_defence_info_fight);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_defence_info_fight);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_state,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.unionState,NetworkCmdType.req_union_battle_state);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_state);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_whole_defence_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.wholeDefenceInfo,NetworkCmdType.req_guild_battle_whole_defence_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_whole_defence_info);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_fight,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.onHandleEnter,NetworkCmdType.req_union_battle_fight);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_fight);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_fight_end,FightOverUIManager,FightOverUIManager.OnReceiveFightOverMessage,NetworkCmdType.req_union_battle_fight_end);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_fight_end);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_whole_defence_info_fight,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.wholeDefenceInfoFight,NetworkCmdType.req_union_battle_whole_defence_info_fight);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_whole_defence_info_fight);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_building_level_up,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.buildingLevelUp,NetworkCmdType.req_union_battle_building_level_up);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_building_level_up);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_fight_record_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.fightRecordInfo,NetworkCmdType.req_union_battle_fight_record_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_fight_record_info);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_fight_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.battleFightInfo,NetworkCmdType.req_union_battle_fight_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_fight_info);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_buy_challenge_times,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.buyChallengeTimes,NetworkCmdType.req_union_battle_buy_challenge_times);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_buy_challenge_times);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_clear_fight_cd,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.clearFightCd,NetworkCmdType.req_union_battle_clear_fight_cd);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_clear_fight_cd);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_spy,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retSleuthing,NetworkCmdType.req_union_battle_spy);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_spy);
	self:RegisterEvent(NetworkCmdType.ret_union_battle_guild_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.unionRank,NetworkCmdType.req_union_battle_guild_info);
	self:RegisterErrorEvent(NetworkCmdType.ret_union_battle_guild_info);

	--献祭
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_begin_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retBeginSacrifice,NetworkCmdType.req_guild_battle_sacrifice_begin_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_begin_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_confirm_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retConfirmSacrifice,NetworkCmdType.req_guild_battle_sacrifice_confirm_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_confirm_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_cancel_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retCancelSacrifice,NetworkCmdType.req_guild_battle_sacrifice_cancel_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_cancel_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_assist_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retAssistSacrifice,NetworkCmdType.req_guild_battle_sacrifice_assist_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_assist_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_change_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retChangeSacrifice,NetworkCmdType.req_guild_battle_sacrifice_change_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_change_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_new_pos_apply_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retNPSacrifice,NetworkCmdType.req_guild_battle_sacrifice_new_pos_apply_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_new_pos_apply_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_pos_off_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retOffSacrifice,NetworkCmdType.req_guild_battle_sacrifice_pos_off_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_pos_off_t);
	self:RegisterEvent(NetworkCmdType.ret_guild_battle_sacrifice_info_t,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.retSacrificeInfo,NetworkCmdType.req_guild_battle_sacrifice_info_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_guild_battle_sacrifice_info_t);
	
	self:RegisterEvent(NetworkCmdType.nt_union_boardcast_fight_state_switch,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.fightStateSwitch);
	self:RegisterEvent(NetworkCmdType.nt_union_boardcast_fight_info,NetworkMsg_UnionBattle,NetworkMsg_UnionBattle.realTimeFightInfo);

	self:RegisterEvent(NetworkCmdType.ret_plant_shop_items, PlantShopPanel, PlantShopPanel.onReceiveShopItems, NetworkCmdType.req_plant_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_plant_shop_buy, PlantShopPanel, PlantShopPanel.onBuyEnd, NetworkCmdType.req_plant_shop_buy);

	self:RegisterEvent(NetworkCmdType.ret_inventory_shop_items,InventoryShopPanel, InventoryShopPanel.onReceiveShopItems, NetworkCmdType.req_inventory_shop_items);
	self:RegisterEvent(NetworkCmdType.ret_inventory_shop_buy, InventoryShopPanel, InventoryShopPanel.onBuyEnd, NetworkCmdType.req_inventory_shop_buy);

	-- 开服成长任务
	self:RegisterEvent(NetworkCmdType.ret_grow_up, OpenServiceRewardPanel, OpenServiceRewardPanel.growUpRewardInitReq, NetworkCmdType.req_grow_up);
	-- 开服成长任务领取消息
	self:RegisterEvent(NetworkCmdType.ret_grow_up_get, OpenServiceRewardPanel, OpenServiceRewardPanel.growUpRewardReq, NetworkCmdType.req_grow_up_get);
	self:RegisterErrorEvent(NetworkCmdType.ret_grow_up_get, OpenServiceRewardPanel, OpenServiceRewardPanel.getErrorReq);
	-- 开服成长任务实时消息
	self:RegisterEvent(NetworkCmdType.nt_opentask_t, OpenServiceRewardPanel, OpenServiceRewardPanel.growUpRewardRealTimeReq);

	self:RegisterEvent(NetworkCmdType.nt_luckybag_change , ActivityRechargePanel, ActivityRechargePanel.luckbagchange);
	
	--魂器页
	self:RegisterEvent(NetworkCmdType.ret_gem_page_t,GemPanel,GemPanel.retGemPage,NetworkCmdType.req_gem_page_t);
	
	--珍宝
	
	self:RegisterEvent(NetworkCmdType.ret_combo_pro_open_t,CuriosityPanel,CuriosityPanel.activateCallBack,NetworkCmdType.req_combo_pro_open_t);
	self:RegisterEvent(NetworkCmdType.ret_combo_pro_levelup_t,CuriosityPanel,CuriosityPanel.upLevelCallBack,NetworkCmdType.req_combo_pro_levelup_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_combo_pro_open_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_combo_pro_levelup_t);
	self:RegisterEvent(NetworkCmdType.nt_combo_pro_attribute_change, NetworkMsg_ComboPro, NetworkMsg_ComboPro.attributeChange);
	self:RegisterEvent(NetworkCmdType.nt_combo_pro_exp_change, NetworkMsg_ComboPro, NetworkMsg_ComboPro.expChange);

	self:RegisterEvent(NetworkCmdType.nt_comment_change, CardCommentPanel, CardCommentPanel.update_commment);

	self:RegisterEvent(NetworkCmdType.nt_report, PersonInfoPanel, PersonInfoPanel.reportinfo);
	self:RegisterErrorEvent(NetworkCmdType.nt_report, PersonInfoPanel, PersonInfoPanel.reportinfo_error);

	-- 符文
	self:RegisterEvent(NetworkCmdType.ret_hunt_rune_t, RuneHuntPanel, RuneHuntPanel.huntCallBack);
	self:RegisterErrorEvent(NetworkCmdType.ret_hunt_rune_t);

	self:RegisterEvent(NetworkCmdType.ret_enter_rune_hunt_t, RuneHuntPanel, RuneHuntPanel.Show);
	self:RegisterErrorEvent(NetworkCmdType.ret_enter_rune_hunt_t);

	self:RegisterEvent(NetworkCmdType.nt_new_rune_be_hunted_t, RuneHuntPanel, RuneHuntPanel.receiveNews);

	self:RegisterEvent(NetworkCmdType.nt_add_new_rune_t, NetworkMsg_Rune, NetworkMsg_Rune.addNewRune);
	self:RegisterEvent(NetworkCmdType.ret_new_rune_inlay_t, NetworkMsg_Rune, NetworkMsg_Rune.inlayRune, NetworkCmdType.req_new_rune_inlay_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_new_rune_inlay_t);
	self:RegisterEvent(NetworkCmdType.ret_new_rune_unlay_t, NetworkMsg_Rune, NetworkMsg_Rune.unlayRune, NetworkCmdType.req_new_rune_unlay_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_new_rune_unlay_t);
	self:RegisterEvent(NetworkCmdType.ret_new_rune_levelup_t, NetworkMsg_Rune, NetworkMsg_Rune.levelupRune, NetworkCmdType.req_new_rune_levelup_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_new_rune_levelup_t);
	self:RegisterEvent(NetworkCmdType.nt_del_rune_t, NetworkMsg_Rune, NetworkMsg_Rune.delRune);
	self:RegisterEvent(NetworkCmdType.ret_new_rune_compose_t, NetworkMsg_Rune, NetworkMsg_Rune.composeRune, NetworkCmdType.req_new_rune_compose_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_new_rune_compose_t);
	self:RegisterEvent(NetworkCmdType.ret_new_rune_active_t, NetworkMsg_Rune, NetworkMsg_Rune.avtiveCallBack, NetworkCmdType.req_new_rune_active_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_new_rune_active_t);

	--继承码
	self:RegisterEvent(NetworkCmdType.ret_gen_in_code_t, NetworkMsg_Data, NetworkMsg_Data.GenInCode, NetworkCmdType.req_gen_in_code_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_gen_in_code_t);

	self:RegisterEvent(NetworkCmdType.ret_announcement_t, AnnouncementPanel, AnnouncementPanel.GetShowInfo, NetworkCmdType.req_announcement_t);

	--人物形象
	self:RegisterEvent(NetworkCmdType.ret_model_t, NetworkMsg_Data, NetworkMsg_Data.GetModel, NetworkCmdType.req_model_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_model_t);
	self:RegisterEvent(NetworkCmdType.ret_change_model_t, NetworkMsg_Data, NetworkMsg_Data.ChangeModel, NetworkCmdType.req_change_model_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_change_model_t);
	self:RegisterEvent(NetworkCmdType.ret_wear_sweapon_t, SWeaponPanel, SWeaponPanel.wear_call_back, NetworkCmdType.req_wear_sweapon_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_wear_sweapon_t);
	self:RegisterEvent(NetworkCmdType.ret_takeoff_sweapon_t, SWeaponPanel, SWeaponPanel.takeoff_call_back, NetworkCmdType.req_takeoff_sweapon_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_takeoff_sweapon_t);
	self:RegisterEvent(NetworkCmdType.ret_sweapon_gen_pro_t, SWeaponPanel, SWeaponPanel.genpro_call_back, NetworkCmdType.req_sweapon_gen_pro_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_sweapon_gen_pro_t);
	self:RegisterEvent(NetworkCmdType.ret_sweapon_save_pro_t, SWeaponPanel, SWeaponPanel.savegenpro_call_back, NetworkCmdType.req_sweapon_save_pro_t);
	self:RegisterErrorEvent(NetworkCmdType.ret_sweapon_save_pro_t);

	self:RegisterEvent(NetworkCmdType.ret_vip_exp_t, VipPanel, VipPanel.reqVipExpEnd, NetworkCmdType.req_vip_exp_t);
	self:RegisterEvent(NetworkCmdType.nt_feedback_t,NetworkMsg_Chat,NetworkMsg_Chat.onFeedback);
	self:RegisterErrorEvent(NetworkCmdType.nt_feedback_t);
	self:RegisterEvent(NetworkCmdType.ret_get_thirtydays_notlogin_reward_t, ThirtyDaysNotLoginRewardPanel, ThirtyDaysNotLoginRewardPanel.getRewardReturn, NetworkCmdType.req_get_thirtydays_notlogin_reward_t);
end 

--初始化等待界面
function Network:InitPanel()
	waitingPanel = uiSystem:FindControl('waitingPanel');
	waitingPanel:IncRefCount();
	loadingBKG = UIControl( waitingPanel:GetLogicChild('background') );
	loading = UIControl( waitingPanel:GetLogicChild('loading') );
	msgLabel = UIControl( waitingPanel:GetLogicChild('msgid') );
	loading.Storyboard = 'storyboard.loading';

	waitingPanel.Visibility = Visibility.Hidden;
	waitingPanel.ZOrder = 5000;

	topDesktop:AddChild(waitingPanel);
end

--销毁界面
function Network:DestroyPanel()
	waitingPanel:DecRefCount();
	waitingPanel = nil
end

--========================================================================
--网络连接

--连接
function Network:Connect()

	local success = networkManager:Connect( self.serverData.ip, tonumber(self.serverData.port) );
	if not success then
		PrintLog('connect server fail!');
		return;
	end

end

--处理错误消息
function Network:onHandleError( errorCode )

	self.netError = true;
	self:hideLoading();

	--print('net error:' .. errorCode);
	
	local contents = {};
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_network_5});
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_network_6});
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_network_7});
	local delegate = Delegate.new(Network, Network.onNetError, errorCode);
	MessageBox:ShowDialog(MessageBoxType.Ok, contents, delegate);

end

--处理网络消息
function Network:onHandleMsg( id, msg )

	--PrintLog('	receive id:' .. id .. "\t" .. msg);
	--Debug.print('	receive id:' .. id .. "\t" .. msg);
	--PrintLog('	receive id:' .. id .. "\t" .. msg);

	--处理心跳消息
	if NetworkCmdType.ret_heartbeat == id then
		if heartBeatTimer ~= 0 then
			timerManager:DestroyTimer(heartBeatTimer);
			heartBeatTimer = 0;
		end
		return;
	end

	--是等待的消息
	if self.receiveID ~= 0 then
		if self.receiveID == id then
			self:hideLoading();
			self.receiveID = 0;
		end
	else
		self:hideLoading();
	end
	local data = cjson.decode(msg);
	if data.code ~= nil and data.code ~= 0 then
		print(data.code)
		--特殊异常处理
		if self.errorHandlerSpecialList[id] then
			self.errorHandlerSpecialList[id]();
		end
		--异常处理
		local errorDelegete = self.errorHandlerList[id];
	    if errorDelegete ~= nil then
		  errorDelegete:Callback(data);
		else
		  self:onDefaultErrorHandler(data.code);
		end
	    return;
	end

	local delegete = self.handlerList[id];
	if delegete == nil then
		print('Unhandled message id:' .. id);
	else
			delegete:Callback(data);
	end

end

--========================================================================
--事件注册

--注册事件
function Network:RegisterEvent( id, obj, func, reqID )
	self.handlerList[id] = Delegate.new(obj, func);

	if reqID ~= nil then
		self.reqList[reqID] = id;
	end
end

--取消注册
function Network:UnregisterEvent( id )
	self.handlerList[id] = nil;
end

--注册错误事件
function Network:RegisterErrorEvent( id, obj, func )
  if obj == nil and func == nil then
	  self.errorHandlerList[id] = Delegate.new(NetworkMsg_Error, NetworkMsg_Error.HandleErrorCode);
  else
	  self.errorHandlerList[id] = Delegate.new(obj, func);
  end
end

--默认错误消息处理
function Network:onDefaultErrorHandler( errorCode )
	local msg = resTableManager:GetValue(ResTable.errors, tostring(errorCode), 'info');
	if msg == nil then
		msg = LANG_network_2 .. errorCode;
	end

	MessageBox:ShowDialog(MessageBoxType.Ok, msg);
end

--发送消息
function Network:Send( id, msg, noWait )
    if id == 3009 then
        local count = _G['Game#UpdateCounter'];
        _G['Game#UpdateCounter'] = 0;
        if  count < 10 then
            return; -- android resume
        else
            -- cheating, send it and wait for being kicked
        end
    end




	--PrintLog('send id:' .. id .. "\t" .. cjson.encode(msg));

	if self.netError then
		return;
	end

	--心跳请求监听处理
	if NetworkCmdType.req_heartbeat == id then
		if heartBeatTimer == 0 then
			heartBeatTimer = timerManager:CreateTimer(GlobalData.HeartBeatWait, 'Network:onHeartBeatError', 0);
		end
	end
	if self.faultList[id] then
		local timeD = appFramework:GetOSTime();
		if not self.faultToleranceList[id] then
			self.faultToleranceList[id] = timeD;
		else
			if timeD - self.faultToleranceList[id] < 3000000 then
				return;
			end
			self.faultToleranceList[id] = timeD;
		end
	end

	networkManager:SendMsg(id, cjson.encode(msg), GlobalData.IsEncryption);

	if (noWait == nil) or (not noWait) then
		--记录要收到的消息id
		local recID = self.reqList[id];
		if recID ~= nil then
			--可能会有receiveID不为0，认为是记录最后一个需要回调的函数
			self.receiveID = recID;
		end

		self:displayLoading(tostring(id));
	end
	--print('sendId->'..id)
end

--屏蔽点击事件
function Network:ShieldClickEvent()
	waitingPanel.Visibility = Visibility.Visible;
	loadingBKG.Visibility = Visibility.Hidden;
	loading.Visibility = Visibility.Hidden;
end

--取消屏蔽事件
function Network:CancelShieldClickEvent()
	waitingPanel.Visibility = Visibility.Hidden;
	loadingBKG.Visibility = Visibility.Hidden;
	loading.Visibility = Visibility.Hidden;
end

--显示loading
function Network:displayLoading(msgid)
  if not msgid then
    msgid = "";
  end
	waitingPanel.Visibility = Visibility.Visible;
	loadingBKG.Visibility = Visibility.Hidden;
	loading.Visibility = Visibility.Hidden;
	msgLabel.Text = "";
	if loadingTimer == 0 then
		loadingTimer = timerManager:CreateTimer(2, 'Network:onLoadingTimer', 0);
	end
end

--心跳错误处理
function Network:onHeartBeatError()
	--心跳没返回，弹出错误提示
	local msg = LANG_network_3;
	local delegate = Delegate.new(Network, Network.onNetError, 0);
	MessageBox:ShowDialog(MessageBoxType.Ok, msg, delegate);
end

--隐藏loading
function Network:hideLoading()
	waitingPanel.Visibility = Visibility.Hidden;
	loadingBKG.Visibility = Visibility.Hidden;
	loading.Visibility = Visibility.Hidden;
	if loadingTimer ~= 0 then
		timerManager:DestroyTimer(loadingTimer);
		loadingTimer = 0;
	end
end

--loading计时器（到时显示loading动画）
function Network:onLoadingTimer()
	if self.showWaiting then
		loadingBKG.Visibility = Visibility.Visible;
		loading.Visibility = Visibility.Visible;
	end

	timerManager:DestroyTimer(loadingTimer);
	loadingTimer = 0;
end

--========================================================================
--界面响应

--网络出错
function Network:onNetError( errorCode )
	--关闭计时器
	if heartBeatTimer ~= 0 then
		timerManager:DestroyTimer(heartBeatTimer);
		heartBeatTimer = 0;
	end

	--销毁游戏
	Game:Destroy();
	appFramework:Reset();
end
