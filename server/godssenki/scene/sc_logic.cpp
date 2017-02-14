#include "sc_logic.h"
#include "sc_service.h"
#include "sc_cache.h"
#include "sc_arena_page_cache.h"
#include "sc_test.h"
#include "sc_message.h"
#include "sc_shop.h"
#include "sc_battle_pvp.h"
#include "sc_battle_record.h"
#include "sc_statics.h"
#include "sc_guidence.h"
#include "sc_name.h"
#include "sc_pub.h"
#include "sc_trial.h"
#include "sc_boss.h"
#include "sc_practice.h"
//#include "sc_rune.h"
#include "sc_pay.h"
#include "sc_city_boss.h"
#include "sc_scuffle.h"
#include "sc_push_def.h"
#include "sc_fp_rank.h"
#include "sc_pub_rank.h"
#include "sc_lv_rank.h"
#include "sc_mailinfo.h"
#include "sc_activity.h"
#include "sc_gmail.h"
#include "sc_limit_round.h"
#include "sc_wing.h"
#include "sc_chronicle.h"
#include "sc_bullet.h"
#include "sc_friend_flower.h"
#include "sc_sign.h"
#include "sc_union_rank.h"
#include "sc_card_rank.h"
#include "sc_arena_rank.h"
#include "sc_reward_mcard.h"
#include "sc_card_event.h"
#include "sc_rank_season.h"
#include "sc_rank_match.h"
#include "sc_card_comment.h"
#include "sc_guild_battle.h"

#include "ys_tool.h"
#include "log.h"
#include "config.h"
#include "code_def.h"
#include "db_def.h"
#include "remote_info.h"
#include "db_service.h"
#include "date_helper.h"
#include "performance_service.h"
#include "random.h"
#include "dbgl_service.h"
#include "crypto.h"

#include "sc_gang.h"

#include "invcode_msg_def.h"
#include "pf_msg_def.h"

#include <boost/format.hpp>

#define LOG "SC_LOGIC"

#define CHANGE_NAME_CONSUME_DIAMOND -100
#define ROLE_RESID_BEGIN 101
#define ROLE_RESID_END 103

sc_logic_t::sc_logic_t():
    m_lua(new sc_lua_t),
    m_user_mgr(new sc_user_mgr_t),
    m_city_mgr(new sc_city_mgr_t),
    m_maquee_time(0)
{
    init_lua();

    //@login
    reg_call(&sc_logic_t::on_mac_login);
    reg_call(&sc_logic_t::on_req_rolelist);
    reg_call(&sc_logic_t::on_req_new_role);
    reg_call(&sc_logic_t::on_req_del_role);
    //@login reg end

    //@scene begin
    reg_call(&sc_logic_t::on_req_login);
    reg_call(&sc_logic_t::on_req_user_data);
    reg_call(&sc_logic_t::on_req_enter_city);
    reg_call(&sc_logic_t::on_nt_move);
    reg_call(&sc_logic_t::on_session_broken);
    reg_call(&sc_logic_t::on_team_change);
    reg_call(&sc_logic_t::on_change_default_team);
    reg_call(&sc_logic_t::on_change_team_name);
    //reg_call(&sc_logic_t::on_remove_team);
    reg_call(&sc_logic_t::on_begin_round);
    reg_call(&sc_logic_t::on_end_round);
    reg_call(&sc_logic_t::on_begin_halt);
    reg_call(&sc_logic_t::on_req_halt_result);
    reg_call(&sc_logic_t::on_end_halt);
    reg_call(&sc_logic_t::on_flush_round);
    reg_call(&sc_logic_t::on_req_upquality);
    reg_call(&sc_logic_t::on_req_wear_equip);
    reg_call(&sc_logic_t::on_req_equip_upgrade);
    reg_call(&sc_logic_t::on_req_open_gemstore_slot);
    reg_call(&sc_logic_t::on_req_gemstone_inlay);
    reg_call(&sc_logic_t::on_req_gemstone_compose);
    reg_call(&sc_logic_t::on_req_gemstone_inlay_all);
    reg_call(&sc_logic_t::on_req_gemstone_syn_all);
    reg_call(&sc_logic_t::on_req_gem_page_info);
    reg_call(&sc_logic_t::on_req_equip_compose);
    reg_call(&sc_logic_t::on_req_equip_compose_by_yb);
    reg_call(&sc_logic_t::on_req_pub_flush);
    reg_call(&sc_logic_t::on_req_pub_time);
    reg_call(&sc_logic_t::on_req_enter_pub);
    //reg_call(&sc_logic_t::on_req_gold_chip);
    reg_call(&sc_logic_t::on_req_hire_partner);
    reg_call(&sc_logic_t::on_req_gen_power);
    reg_call(&sc_logic_t::on_req_gen_energy);
    reg_call(&sc_logic_t::on_req_offline_exp);
    reg_call(&sc_logic_t::on_req_trial_info);
    reg_call(&sc_logic_t::on_req_trial_receive_task);
    reg_call(&sc_logic_t::on_req_trial_giveup_task);
    reg_call(&sc_logic_t::on_req_trial_flush_task);
    reg_call(&sc_logic_t::on_req_trial_start_battle);
    reg_call(&sc_logic_t::on_req_trial_end_battle);
    reg_call(&sc_logic_t::on_req_trial_flush_targets);
    reg_call(&sc_logic_t::on_req_skill_upgrade);
    reg_call(&sc_logic_t::on_req_skill_upnext);
    reg_call(&sc_logic_t::on_req_view_user_info);
    reg_call(&sc_logic_t::on_req_up_potential);
    reg_call(&sc_logic_t::on_req_fire_partner);
    reg_call(&sc_logic_t::on_req_chip_to_soul);
    reg_call(&sc_logic_t::on_req_login_info);
    reg_call(&sc_logic_t::on_begin_zodiac_halt);
    reg_call(&sc_logic_t::on_req_zodiac_halt_result);
    reg_call(&sc_logic_t::on_req_boss_enter_scene);
    reg_call(&sc_logic_t::on_req_boss_alive);
    reg_call(&sc_logic_t::on_req_open_union_boss);
    reg_call(&sc_logic_t::on_req_boss_enter_battle);
    reg_call(&sc_logic_t::on_req_boss_exit_battle);
    reg_call(&sc_logic_t::on_req_boss_dmg_ranking);
    reg_call(&sc_logic_t::on_req_boss_leave_scene);
    reg_call(&sc_logic_t::on_req_arena_info);
    reg_call(&sc_logic_t::on_req_begin_arena_fight);
    reg_call(&sc_logic_t::on_req_end_arena_fight);
    reg_call(&sc_logic_t::on_req_arena_buy_count);
    reg_call(&sc_logic_t::on_req_arena_clear_time);
    reg_call(&sc_logic_t::on_req_arena_rank_page);
    reg_call(&sc_logic_t::on_req_open_pack);
    reg_call(&sc_logic_t::on_req_use_pack);
    reg_call(&sc_logic_t::on_req_trial_rewards);
    reg_call(&sc_logic_t::on_req_chart);
    reg_call(&sc_logic_t::on_req_mail_info);
    reg_call(&sc_logic_t::on_req_arena_reward);
    reg_call(&sc_logic_t::on_req_arena_cool_down);
    reg_call(&sc_logic_t::on_current_step_change);

    reg_call(&sc_logic_t::on_req_friend_search);
    reg_call(&sc_logic_t::on_req_friend_search_by_uid);
    reg_call(&sc_logic_t::on_req_friend_add);
    reg_call(&sc_logic_t::on_req_friend_beenadd);
    reg_call(&sc_logic_t::on_req_friend_del);
    reg_call(&sc_logic_t::on_req_change_helphero);
    reg_call(&sc_logic_t::on_req_friend_list);
    reg_call(&sc_logic_t::on_req_friend_req_list);
    reg_call(&sc_logic_t::on_req_send_flower);
    reg_call(&sc_logic_t::on_req_stranger_list);
    reg_call(&sc_logic_t::on_req_friend_battle);
    reg_call(&sc_logic_t::on_req_flower_list);
    reg_call(&sc_logic_t::on_req_receive_flower);
    reg_call(&sc_logic_t::on_req_receive_all);
    reg_call(&sc_logic_t::on_req_role_pro);
    reg_call(&sc_logic_t::on_req_maquee_info);

    reg_call(&sc_logic_t::on_req_practice_info);
    reg_call(&sc_logic_t::on_req_practice_clear);
    reg_call(&sc_logic_t::on_req_practice_prac);

    reg_call(&sc_logic_t::on_req_task_list);
    reg_call(&sc_logic_t::on_req_get_task);
    reg_call(&sc_logic_t::on_req_commit_task);
    reg_call(&sc_logic_t::on_req_abort_task);
    reg_call(&sc_logic_t::on_req_finished_bline);

    //活动
    //reg_call(&sc_logic_t::on_req_daily_task_list);
    //reg_call(&sc_logic_t::on_commit_daily_task);
    //reg_call(&sc_logic_t::on_req_buy_daily_task);
    reg_call(&sc_logic_t::on_req_cumu_yb_rank);

    //公会
    reg_call(&sc_logic_t::on_req_create_gang);
    reg_call(&sc_logic_t::on_req_gang_info);
    reg_call(&sc_logic_t::on_req_gang_list);
    reg_call(&sc_logic_t::on_req_search_gang);
    reg_call(&sc_logic_t::on_req_set_notice);
    reg_call(&sc_logic_t::on_req_set_adm);
    reg_call(&sc_logic_t::on_nt_gang_msg);
    reg_call(&sc_logic_t::on_req_gang_pay);
    reg_call(&sc_logic_t::on_req_close_gang);
    reg_call(&sc_logic_t::on_req_gskl_list);
    reg_call(&sc_logic_t::on_req_learn_gskl);
    reg_call(&sc_logic_t::on_req_add_gang);
    reg_call(&sc_logic_t::on_req_gang_reqlist);
    reg_call(&sc_logic_t::on_req_gang_mem);
    reg_call(&sc_logic_t::on_req_deal_gang_req);
    reg_call(&sc_logic_t::on_req_kick_mem);
    reg_call(&sc_logic_t::on_req_leave_gang);
    reg_call(&sc_logic_t::on_req_gang_pray);
    reg_call(&sc_logic_t::on_req_change_charman);
    reg_call(&sc_logic_t::on_req_enter_pray);
    reg_call(&sc_logic_t::on_req_set_gboss_time);

/*
    reg_call(&sc_logic_t::on_req_rune_switch);
    reg_call(&sc_logic_t::on_req_rmonster_info);
    reg_call(&sc_logic_t::on_req_rune_eatall);
    reg_call(&sc_logic_t::on_req_rune_huntone);
    reg_call(&sc_logic_t::on_req_rune_callboss);
    reg_call(&sc_logic_t::on_req_rune_buy);
    reg_call(&sc_logic_t::on_nt_rune_close);
    */

    reg_call(&sc_logic_t::on_guidence_get_partner);
    reg_call(&sc_logic_t::on_guidence_rename);
    //    reg_call(&sc_logic_t::on_guidence_gemstone);
    //    reg_call(&sc_logic_t::on_guidence_potential);
    reg_call(&sc_logic_t::on_guidence_pub);
    reg_call(&sc_logic_t::on_req_random_name);
    reg_call(&sc_logic_t::on_nt_function);

    reg_call(&sc_logic_t::on_up_team_pro);

    reg_call(&sc_logic_t::on_req_shop_items);
    reg_call(&sc_logic_t::on_shop_buy);
    reg_call(&sc_logic_t::on_npc_shop_buy);
    reg_call(&sc_logic_t::on_req_buy_coin);
    reg_call(&sc_logic_t::on_item_buy);
    reg_call(&sc_logic_t::on_sell);
    reg_call(&sc_logic_t::on_req_npcshop_items);
    reg_call(&sc_logic_t::on_req_npc_shop_update);
    reg_call(&sc_logic_t::on_req_prestige_shop_items);
    reg_call(&sc_logic_t::on_req_prestige_shop_buy);
    reg_call(&sc_logic_t::on_req_chip_shop_items);
    reg_call(&sc_logic_t::on_req_chip_shop_buy);


    reg_call(&sc_logic_t::on_req_plant_shop_items);
    reg_call(&sc_logic_t::on_req_plant_shop_buy);


    reg_call(&sc_logic_t::on_req_inventory_shop_items);
    reg_call(&sc_logic_t::on_req_inventory_shop_buy);
    
    reg_call(&sc_logic_t::on_req_chip_smash_items);
    reg_call(&sc_logic_t::on_req_chip_smash_buy);

    reg_call(&sc_logic_t::on_req_reward);
    reg_call(&sc_logic_t::on_req_lv_reward);
    reg_call(&sc_logic_t::on_req_cdkey_reward);
    // reg_call(&sc_logic_t::on_req_rank_reward);
    // reg_call(&sc_logic_t::on_req_given_rank_reward);
    reg_call(&sc_logic_t::on_req_given_power_reward);
    reg_call(&sc_logic_t::on_req_given_vip_reward);
    reg_call(&sc_logic_t::on_req_power_reward_cd);

    reg_call(&sc_logic_t::on_req_buy_vip_info);
    reg_call(&sc_logic_t::on_req_buy_power);
    reg_call(&sc_logic_t::on_req_buy_energy);

    reg_call(&sc_logic_t::on_req_online_reward_cd);
    reg_call(&sc_logic_t::on_req_online_reward);
    reg_call(&sc_logic_t::on_req_online_reward_num);


    reg_call(&sc_logic_t::on_req_invcode);
    reg_call(&sc_logic_t::on_req_invcode_set);
    reg_call(&sc_logic_t::on_req_invcode_reward);

    reg_call(&sc_logic_t::on_req_quit_game);
    reg_call(&sc_logic_t::on_req_login_yb);

    //巨龙宝库
    reg_call(&sc_logic_t::on_req_treasure_enter);
    reg_call(&sc_logic_t::on_req_treasure_exit);
    reg_call(&sc_logic_t::on_req_treasure_pass);
    reg_call(&sc_logic_t::on_req_treasure_occupy);
    reg_call(&sc_logic_t::on_req_treasure_fight);
    reg_call(&sc_logic_t::on_req_treasure_fight_end);
    reg_call(&sc_logic_t::on_req_treasure_rob);
    reg_call(&sc_logic_t::on_req_treasure_rob_end);
    reg_call(&sc_logic_t::on_req_treasure_floor);
    reg_call(&sc_logic_t::on_req_treasure_giveup);
    reg_call(&sc_logic_t::on_req_treasure_getreward);
    reg_call(&sc_logic_t::on_req_secs_to_zero);
    reg_call(&sc_logic_t::on_req_treasure_records);
    reg_call(&sc_logic_t::on_req_treasure_revenge);
    reg_call(&sc_logic_t::on_req_treasure_help);
    reg_call(&sc_logic_t::on_req_treasure_reset);

    //星魂系统
    reg_call(&sc_logic_t::on_req_star_open);
    reg_call(&sc_logic_t::on_req_star_flush);
    reg_call(&sc_logic_t::on_req_star_set);
    reg_call(&sc_logic_t::on_req_star_get);

    //支付 
    reg_call(&sc_logic_t::on_req_pay_repo);
    reg_call(&sc_logic_t::on_req_buy_yb);

    //购买背包容量
    reg_call(&sc_logic_t::on_req_buy_bag_cap);

    //新关卡协议
    reg_call(&sc_logic_t::on_req_round_enter);
    reg_call(&sc_logic_t::on_req_round_exit);
    reg_call(&sc_logic_t::on_req_elite_enter);
    reg_call(&sc_logic_t::on_req_elite_exit);
    reg_call(&sc_logic_t::on_req_reset_elite);
    reg_call(&sc_logic_t::on_req_zodiac_enter);
    reg_call(&sc_logic_t::on_req_zodiac_exit);
    reg_call(&sc_logic_t::on_req_zodiac_pass);
    reg_call(&sc_logic_t::on_req_round_flush);
    reg_call(&sc_logic_t::on_req_round_pass);
    reg_call(&sc_logic_t::on_req_round_pass_new);
    reg_call(&sc_logic_t::on_req_clear_round_pass);
    reg_call(&sc_logic_t::on_req_clear_cave_pass);
    reg_call(&sc_logic_t::on_req_cave_enter);
    reg_call(&sc_logic_t::on_req_cave_exit);
    reg_call(&sc_logic_t::on_req_cave_pass);
    reg_call(&sc_logic_t::on_req_cave_flush);
    reg_call(&sc_logic_t::on_req_expedition);
    reg_call(&sc_logic_t::on_req_expedition_round);
    reg_call(&sc_logic_t::on_req_enter_expedition_round);
    reg_call(&sc_logic_t::on_req_exit_expedition_round);
    reg_call(&sc_logic_t::on_req_expedition_team);
    reg_call(&sc_logic_t::on_nt_expedition_team_change);
    reg_call(&sc_logic_t::on_req_expedition_round_reward);
    reg_call(&sc_logic_t::on_req_expedition_partners);
    reg_call(&sc_logic_t::on_req_expedition_reset);
    reg_call(&sc_logic_t::on_req_expedition_shop);
    reg_call(&sc_logic_t::on_req_expedition_shop_buy);
    reg_call(&sc_logic_t::on_req_gang_shop);
    reg_call(&sc_logic_t::on_req_gang_shop_buy);
    reg_call(&sc_logic_t::on_req_rune_shop);
    reg_call(&sc_logic_t::on_req_rune_shop_buy);
    reg_call(&sc_logic_t::on_req_cardevent_shop);
    reg_call(&sc_logic_t::on_req_cardevent_shop_buy);
    reg_call(&sc_logic_t::on_req_lmt_shop);
    reg_call(&sc_logic_t::on_req_lmt_shop_buy);
    reg_call(&sc_logic_t::on_req_expedition_pass_round);

    //乱斗场
    reg_call(&sc_logic_t::on_req_scuffle_prepare);
    reg_call(&sc_logic_t::on_req_scuffle_exit);
    reg_call(&sc_logic_t::on_req_scuffle_battle);
    reg_call(&sc_logic_t::on_req_scuffle_battle_end);
    reg_call(&sc_logic_t::on_req_scuffle_score);
    reg_call(&sc_logic_t::on_req_scuffle_state);
    //reg_call(&sc_logic_t::on_req_scuffle_reward);

    reg_call(&sc_logic_t::on_req_sign_reward);
    
    reg_call(&sc_logic_t::on_req_fp_rank);
    reg_call(&sc_logic_t::on_req_pub_rank);
    reg_call(&sc_logic_t::on_req_lv_rank);
    reg_call(&sc_logic_t::on_req_sync_fp);
    reg_call(&sc_logic_t::on_req_arena_rank);

    //请求主城boss信息
    reg_call(&sc_logic_t::on_req_city_boss_info);
    //请求挑战主城boss
    reg_call(&sc_logic_t::on_req_fight_city_boss);
    //请求开始挑战主城boss
    reg_call(&sc_logic_t::on_req_begin_fight_city_boss);
    //图纸合成
    reg_call(&sc_logic_t::on_req_compose_drawing);
    //请求关卡星级奖励
    reg_call(&sc_logic_t::on_req_starreward);
    //请求关卡星级奖励信息
    reg_call(&sc_logic_t::on_req_starreward_info);
    //打开宝箱
    reg_call(&sc_logic_t::on_req_use_item);

    //请求月卡信息和奖励
    reg_call(&sc_logic_t::on_req_mcard_info);
    reg_call(&sc_logic_t::on_req_mcard_reward);

    reg_call(&sc_logic_t::on_req_fp_reward);
    reg_call(&sc_logic_t::on_req_cumu_yb_reward);
    reg_call(&sc_logic_t::on_req_daily_pay_reward);

    reg_call(&sc_logic_t::on_req_mail_list);
    reg_call(&sc_logic_t::on_req_mail_reward);
    reg_call(&sc_logic_t::on_req_mail_delete);
    reg_call(&sc_logic_t::on_req_mail_allreward);
    reg_call(&sc_logic_t::on_nt_mail_reaeded);
    reg_call(&sc_logic_t::on_nt_mail_delete);

    reg_call(&sc_logic_t::on_req_act_task);
    reg_call(&sc_logic_t::on_req_act_reward);

    reg_call(&sc_logic_t::on_req_achievement_task);
    reg_call(&sc_logic_t::on_req_achievement_reward);
    
    reg_call(&sc_logic_t::on_nt_twrecordop);
    reg_call(&sc_logic_t::on_req_hongbao);
    reg_call(&sc_logic_t::on_req_guwu);
    reg_call(&sc_logic_t::on_req_fuhuo);

    reg_call(&sc_logic_t::on_req_limit_round);
    reg_call(&sc_logic_t::on_req_limit_result);
    reg_call(&sc_logic_t::on_req_limit_round_clear_cd);
    reg_call(&sc_logic_t::on_req_zodiacid);
    reg_call(&sc_logic_t::on_req_limit_round_data);
    reg_call(&sc_logic_t::on_req_reset_limit_round_times);

    //翅膀
    reg_call(&sc_logic_t::on_req_wear_wing);
    reg_call(&sc_logic_t::on_req_compose_wing);

    //翅膀活动
    reg_call(&sc_logic_t::on_req_gacha_wing);
    reg_call(&sc_logic_t::on_req_get_wing);
    reg_call(&sc_logic_t::on_req_wing_rank);
    reg_call(&sc_logic_t::on_req_sell_wing);

    //宠物
    reg_call(&sc_logic_t::on_req_compose_pet);

    //编年史
    reg_call(&sc_logic_t::on_req_chronicle);
    reg_call(&sc_logic_t::on_req_chronicle_sign);
    reg_call(&sc_logic_t::on_req_chronicle_sign_retrieve);
    reg_call(&sc_logic_t::on_req_chronicle_sign_all);

    //爱恋度
    reg_call(&sc_logic_t::on_req_love_task_list);
    reg_call(&sc_logic_t::on_req_commit_love_task);
    //@scene reg end

    //test
    reg_call(&sc_logic_t::on_req_test_arena);
    reg_call(&sc_logic_t::on_req_test_pay);
    reg_call(&sc_logic_t::on_req_test_fight);
    reg_call(&sc_logic_t::on_req_overdue);
    reg_call(&sc_logic_t::on_req_test_round_drop);

    //每日签到
    reg_call(&sc_logic_t::on_req_sign_info);
    reg_call(&sc_logic_t::on_req_sign_daily);
    reg_call(&sc_logic_t::on_req_sign_remedy);
    
    //请求弹幕列表
    reg_call(&sc_logic_t::on_bullet_list);
    //发送弹幕
    reg_call(&sc_logic_t::on_send_bullet);
    //请求公会排行榜信息
    reg_call(&sc_logic_t::on_req_union_rank);
    //请求卡牌排行榜信息
    reg_call(&sc_logic_t::on_req_card_rank);

    /* 卡牌活动 */
    reg_call(&sc_logic_t::on_req_card_event_open_round);
    reg_call(&sc_logic_t::on_req_card_event_fight);
    reg_call(&sc_logic_t::on_req_card_event_round_exit);
    reg_call(&sc_logic_t::on_req_card_event_reset);
    reg_call(&sc_logic_t::on_nt_card_event_change_team);
    reg_call(&sc_logic_t::on_req_card_event_round_enemy);
    reg_call(&sc_logic_t::on_req_card_event_revive);
    reg_call(&sc_logic_t::on_req_card_event_rank);
    reg_call(&sc_logic_t::on_req_card_event_sweep);
    reg_call(&sc_logic_t::on_req_card_event_next);
    reg_call(&sc_logic_t::on_req_card_event_first_enter);

    /* 赛季排位 */
    reg_call(&sc_logic_t::on_req_rank_season_match);
    reg_call(&sc_logic_t::on_req_rank_season_info);
    reg_call(&sc_logic_t::on_req_rank_seson_fight_end);
    reg_call(&sc_logic_t::on_req_cancel_rank_season_wait);
    reg_call(&sc_logic_t::on_req_begin_rank_match_fight);

    //更换主角
    reg_call(&sc_logic_t::req_change_roletype);
    //请求开启魂师
    reg_call(&sc_logic_t::req_soulnode_open);
    //请求魂师信息
    reg_call(&sc_logic_t::req_soulnode_pro);
    //navi点击事件
    reg_call(&sc_logic_t::on_req_naviClickNum_add);

    //请求记录新手引导状态
    
    reg_call(&sc_logic_t::on_req_chip_smash_items);
    reg_call(&sc_logic_t::on_req_chip_smash_buy);

    //请求记录新手引导状态
    reg_call(&sc_logic_t::on_req_write_guidence);
    
    //更改名字
    reg_call(&sc_logic_t::on_req_change_name);
    reg_call(&sc_logic_t::on_req_set_kanban_role);
    //开服活动
    reg_call(&sc_logic_t::on_req_get_open_service_reward);
    //成长计划
    reg_call(&sc_logic_t::on_req_buy_growing_package);
    reg_call(&sc_logic_t::on_req_chat_info);
    //探宝
    reg_call(&sc_logic_t::on_req_treasure_give_occupy);
    reg_call(&sc_logic_t::on_req_treasure_giveup_help);

    // 晶魂
    reg_call(&sc_logic_t::on_req_get_soul_info);
    reg_call(&sc_logic_t::on_req_hunt_soul);
    reg_call(&sc_logic_t::on_req_rankup_soul);
    reg_call(&sc_logic_t::on_req_get_soul_reward);

    // 公会战
    reg_call(&sc_logic_t::on_req_guild_battle_state);
    reg_call(&sc_logic_t::on_req_guild_battle_sign_up);
    reg_call(&sc_logic_t::on_req_guild_battle_defence_info);
    reg_call(&sc_logic_t::on_req_guild_battle_whole_defence_info);
    reg_call(&sc_logic_t::on_req_guild_battle_defence_pos_on);
    reg_call(&sc_logic_t::on_req_guild_battle_defence_pos_off);
    reg_call(&sc_logic_t::on_req_guild_battle_cancel_other_pos);
    reg_call(&sc_logic_t::on_req_guild_battle_building_level_up);
    reg_call(&sc_logic_t::on_req_guild_battle_whole_defence_info_fight);
    reg_call(&sc_logic_t::on_req_guild_battle_defence_info_fight);
    reg_call(&sc_logic_t::on_req_guild_battle_fight);
    reg_call(&sc_logic_t::on_req_guild_battle_fight_end);
    reg_call(&sc_logic_t::on_req_guild_battle_fight_record_info);
    reg_call(&sc_logic_t::on_req_guild_battle_fight_info);
    reg_call(&sc_logic_t::on_req_guild_battle_buy_fight_times);
    reg_call(&sc_logic_t::on_req_guild_battle_clear_fight_cd);
    reg_call(&sc_logic_t::on_req_guild_battle_spy);
    reg_call(&sc_logic_t::on_req_guild_battle_guild_info);

    //卡牌评价
    reg_call(&sc_logic_t::on_req_card_comment);
    reg_call(&sc_logic_t::on_req_newest_card_comment);
    reg_call(&sc_logic_t::on_get_index_role_info);
    reg_call(&sc_logic_t::on_req_praise);
    //福袋奖励
    reg_call(&sc_logic_t::on_req_luckybag_reward);
    //pve战斗失败次数
    reg_call(&sc_logic_t::on_req_pvelose_times);
    //请求获得周礼包奖励
    reg_call(&sc_logic_t::on_req_get_weekly_reward);
    //请求获得在线包奖励
    reg_call(&sc_logic_t::on_req_get_online_reward);


    reg_call(&sc_logic_t::on_req_opentask_info);
    reg_call(&sc_logic_t::on_req_opentask_reward);

    // combo pro
    reg_call(&sc_logic_t::on_req_combo_pro_open);
    reg_call(&sc_logic_t::on_req_combo_pro_levelup);
    
    reg_call(&sc_logic_t::on_req_report);

    // rune
    reg_call(&sc_logic_t::on_req_hunt_rune_t);
    reg_call(&sc_logic_t::on_req_enter_rune_hunt_t);
    reg_call(&sc_logic_t::on_req_leave_rune_hunt_t);
    reg_call(&sc_logic_t::on_req_new_rune_inlay_t);
    reg_call(&sc_logic_t::on_req_new_rune_unlay_t);
    reg_call(&sc_logic_t::on_req_new_rune_levelup_t);
    reg_call(&sc_logic_t::on_req_new_rune_compose_t);
    reg_call(&sc_logic_t::on_req_new_rune_active_t);
    reg_call(&sc_logic_t::on_req_announcement_t);

    // 继承码
    reg_call(&sc_logic_t::on_req_gen_inheritance_code_t);

    // 主城形象
    reg_call(&sc_logic_t::on_req_model_t);
    reg_call(&sc_logic_t::on_req_change_model_t);


    //领取vip经验
    reg_call(&sc_logic_t::on_req_vip_exp_t);
    //请求聊天内容
    reg_call(&sc_logic_t::on_req_private_chat_info_t);
}
sc_logic_t::~sc_logic_t()
{
    delete m_lua;
    delete m_user_mgr;
    delete m_city_mgr;
}
sc_user_mgr_t& sc_logic_t::usermgr() { return *m_user_mgr; }
sc_city_mgr_t& sc_logic_t::citymgr() { return *m_city_mgr; }
sc_lua_t& sc_logic_t::lua() { return *m_lua; }
void sc_logic_t::close()
{
    logwarn((LOG, "sc_logic_t::close ..."));
    usermgr().foreach([](sp_user_t user)
            {
            //保存符文系统到数据库
            //user->rune_mgr.save_db();

            //如果有未成功领取的礼包则立刻领取
            //user->item_mgr.given_pack_item();

            //保存奖励
            user->reward.save_db();

            //保存玩家退出时间
            int32_t cursec = date_helper.cur_sec();
            user->db.set_lastquit(cursec);
            user->counttime = user->db.totaltime;

            if( user->login_time == 0 )
            user->login_time = cursec;

            user->db.set_totaltime( user->db.totaltime + ( cursec - user->login_time ) );

            //生成玩家退出记录
            if( user->mac.find("robot") == std::string::npos )
                statics_ins.unicast_quitlog(user);

            //保存玩家战斗力
            user->db.set_fp(user->get_total_fp());
            user->save_db(); 

            //保存用户id表
            user->save_db_userid();

            });
    logwarn((LOG, "sc_logic_t::close ... ok!"));
}
void sc_logic_t::init_lua()
{
    m_lua->reload_script(config.res.lua_path);
}
void sc_logic_t::unicast(int32_t uid_, uint16_t cmd_, const string& msg_)
{
    uint64_t seskey; 
    if (!is_online(uid_))
        return;
    if ((seskey=session.get_seskey(uid_))!=0)
    {
        uint32_t gwsid = ((uint32_t)REMOTE_GW<<16 | seskey>>48);
        sp_sc_gw_client_t client;
        if (sc_service.get(gwsid, client))
        {
            msg_sender_t::unicast(seskey, client->get_conn(), cmd_, (string&)msg_);
            return;
        }
        logerror((LOG, "no gw client:%u", gwsid));
    }
    else
        logerror((LOG, "no user seskey,uid:%d", uid_));
}
int sc_logic_t::is_online(int32_t uid_)
{
    sp_user_t user;
    if( (usermgr().get(uid_,user))&&(user->login_time) )
        return 1;
    return 0;
}

bool sc_logic_t::has_host(int32_t host_)
{
    auto it = std::find(m_hosts.begin(), m_hosts.end(), host_);
    return it != m_hosts.end();
}
void sc_logic_t::compensate(sp_user_t user)
{
    db_Compensate_t db;
    sql_result_t res;
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t item;

    if (0==db_Compensate_t::sync_select_compensate(user->db.uid, 0, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db.init(*res.get_row_at(i));
            nt.items.clear();

            if( db.count > 0 )
            {
                //记录事件
                statics_ins.unicast_eventlog(*user,3999,db.resid,db.count);

                if( db.resid < 10000 )
                {
                    //补偿伙伴
                    if(user->partner_mgr.hire_from_reward(db.resid,1) != SUCCESS)
                        continue;
                }
                else if( db.resid == 10001 )
                {
                    //补偿金币
                    user->db.set_gold(user->db.gold+db.count);
                }
                else if( db.resid == 10002 )
                {
                    //补偿战历
                    user->db.set_battlexp(user->db.battlexp+db.count);
                }
                else if( db.resid == 10003 )
                {
                    //补偿水晶
                    user->db.set_freeyb(user->db.freeyb+db.count);
                }
                else if( db.resid == 10004 )
                {
                    //补偿友情点
                    user->db.set_fpoint(user->db.fpoint+db.count);
                }
                else if( db.resid == 10005 )
                {
                    //补偿体力
                    user->db.set_power(user->db.power+db.count);
                }
                else if( db.resid == 10006 )
                {
                    //补偿符文碎片
                    user->db.set_runechip(user->db.runechip+db.count);
                }
                else if( db.resid == 10007 )
                {
                    //补偿vip等级
                    if( user->db.viplevel < (int)db.count )
                        user->vip.compensate_vip(db.count);
                }
                else if( db.resid == 10008 )
                {
                    //补偿等级
                    user->compensate_grade(db.count);
                }
                else if( db.resid == 10009 )
                {
                    //补偿灵能
                    user->db.set_soul(user->db.soul+db.count);
                }
                else if( db.resid == 10010 )
                {
                    //补偿声望
                    user->db.set_honor(user->db.honor+db.count);
                }
                else
                {
                    //补偿道具
                    repo_def::item_t* rp_item = repo_mgr.item.get(db.resid);
                    if (rp_item == NULL)
                        continue;
                    if( (rp_item->type==2)||(rp_item->type==8) )
                        continue;

                    item.itid = 0;
                    item.resid = db.resid;
                    item.num = db.count;
                    nt.items.push_back(std::move(item));
                }
                user->item_mgr.put(nt);
                user->save_db();
                //设置为已补偿
                db_service.async_do((uint64_t)user->db.uid,[](uint32_t stamp_,int id_){
                        char buf[256];
                        sprintf(buf, "update Compensate set state=1,givenstamp=%d where id=%d",stamp_,id_);
                        db_service.async_execute(buf);
                        }, date_helper.cur_sec(), db.id);
            }
        }
    }
}
bool isValidMac(const string& s)
{
    for (int i = 0; i < s.size(); i++)
    {   
        if ( !isalnum(s[i]) && s[i] != '_' )
            return false;
    }   
    return true;
}

void sc_logic_t::on_mac_login(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_)
{
    if(!isValidMac(jpk_.mac.c_str()))
    {
        logwarn((LOG, "req_mac_login not good mac"));
        lg_msg_def::ret_login_t ret;
        ret.code = ERROR_LG_EXCEPTION;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;

    } 
    uint32_t hash = crypto_t::crc32(jpk_.mac.c_str(), jpk_.mac.size());
    dbgl_service.async_do((uint64_t)hash, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_){

            logwarn((LOG, "req_mac_login..., seskey:%lu", seskey_));

            sql_result_t res;

            db_Account_ext_t acc;
            if (db_Account_ext_t::select_name(jpk_.domain, jpk_.name, res))
            {
                if ((acc.aid = async_new_dbid("aid")) == 0)
                {
                    logerror((LOG, "on_mac_login, create new aid failed!"));
                    lg_msg_def::ret_login_t ret;
                    ret.code = ERROR_LG_EXCEPTION;
                    msg_sender_t::unicast(seskey_, conn_, ret);
                    return;
                }
    
                acc.domain = jpk_.domain;
                acc.name = jpk_.name;
                acc.flag= 0;
                acc.lasthostnum = 0;
                acc.lastuid = 0;
    
                if (acc.insert())
                {
                    logerror((LOG, "on_mac_login, create new account failed!"));
                    lg_msg_def::ret_login_t ret;
                    ret.code = ERROR_LG_EXCEPTION;
                    msg_sender_t::unicast(seskey_, conn_, ret);
                    return;
                }

                //统计数据
                if( jpk_.name.find("robot") == std::string::npos )
                    statics_ins.unicast_newaccount(jpk_.domain,jpk_.name,acc.aid);
            }
            else
            {
                acc.init(*res.get_row_at(0));
            }

            lg_msg_def::ret_login_t ret;
            ret.aid = acc.aid;
            ret.hostnum = acc.lasthostnum;
            ret.code = SUCCESS;
            msg_sender_t::unicast(seskey_, conn_, ret);
    }, seskey_, conn_, jpk_);
}
void sc_logic_t::on_req_rolelist(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_)
{
    if (!sc_service.has_host(jpk_.hostnum))
    {
        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_UNKNOWN_SERVER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    dbgl_service.async_do((uint64_t)jpk_.aid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_){
            lg_msg_def::ret_rolelist_t ret;
            sql_result_t res;

            //确认账户存在
            db_Account_ext_t acc;
            if (db_Account_ext_t::select_aid(jpk_.aid, res))
            {
            ret.code = ERROR_LG_NO_AID;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }
            else
            {
            acc.init(*res.get_row_at(0));
            }

            ret.hostnum = jpk_.hostnum;
            //设置上一次选择的服务器角色
            ret.lastuid = acc.lastuid;
            //查找角色
            db_service.async_do((uint64_t)jpk_.aid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_, lg_msg_def::ret_rolelist_t& ret_){
                    sql_result_t res;
                    if (db_UserID_ext_t::select_user_condition(jpk_.aid, jpk_.hostnum, "state>=0", res))
                    {
                    ret_.code = SUCCESS;
                    msg_sender_t::unicast(seskey_, conn_, ret_);
                    }
                    else
                    {
                    int i=0;
                    sql_result_row_t* row = NULL;
                    while((row=res.get_row_at(i++))!=NULL)
                    {
                    db_UserID_ext_t userid;
                    userid.init(*row);

                    lg_msg_def::jpk_role_t jpk;
                    jpk.uid = userid.uid;
                    jpk.resid = userid.resid;
                    jpk.nickname = userid.nickname();
                    jpk.level = userid.grade;
                    jpk.viplevel = 0;
                    jpk.weaponid = 0;
                    jpk.wingid = userid.wingid;

                    ret_.rolelist.push_back(std::move(jpk));
                    }

            ret_.code = SUCCESS;
            msg_sender_t::unicast(seskey_, conn_, ret_);
                    }
            }, seskey_, conn_, jpk_, ret);
    }, seskey_, conn_, jpk_);
}
//请求创建角色
void sc_logic_t::on_req_new_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_)
{
    if (ROLE_RESID_BEGIN > jpk_.resid || jpk_.resid > ROLE_RESID_END)
    {
        logerror((LOG, "on_req_new_role, error role resid:%d,%d,%d!", ROLE_RESID_BEGIN, jpk_.resid, ROLE_RESID_END));
        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_LG_ROLE_RESID;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    if (!sc_service.has_host(jpk_.hostnum))
    {
        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_UNKNOWN_SERVER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    string name(jpk_.name);
    ys_tool_t::filter_str(name);
    //判断逻辑提出来改同步，不在异步中进行
    if (name.empty())
    {
        logerror((LOG, "on_req_new_role, create random_name empty!"));

        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_LG_EXCEPTION;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sql_result_t name_res;
    char sql[256]; 
    sprintf(sql, "select uid from UserID where nickname='%s'",name.c_str());
    db_service.sync_select(sql, name_res);
    if (name_res.affect_row_num() > 0) 
    {
        logerror((LOG, "on_req_new_role, failed! %s", sql));

        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_LG_ROLE_EXIST;
        msg_sender_t::unicast(seskey_, conn_, ret);
        logerror((LOG, "on_req_new_role, return"));
        return;
    }

    db_service.async_do((uint64_t)jpk_.aid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_){

            lg_msg_def::ret_new_role_t ret;
            ret.code = SUCCESS;

            sql_result_t res;
            //检查角色数是否溢出
            db_UserID_ext_t::select_user_condition(jpk_.aid, jpk_.hostnum, "state>=0", res);
            if (res.affect_row_num() >= 3)
            {
            ret.uid = 0;
            ret.code = ERROR_LG_ROLE_MAX_NUM;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }

            //插入角色ID
            db_UserID_ext_t userid;
            if ((userid.uid = dbid_assign.new_dbid("uid"))==0)
            {
                logerror((LOG, "on_req_new_role, create new uid failed!"));
                ret.uid = 0;
                ret.code = ERROR_LG_EXCEPTION;
                msg_sender_t::unicast(seskey_, conn_, ret);
                return;
            }
            userid.aid = jpk_.aid; 
            userid.resid = jpk_.resid;

            string name(jpk_.name);
            ys_tool_t::filter_str(name);
            userid.nickname = name;
            //验证名字是否合法，去重
            /*
            do
            {
                string name = gen_name.random_name();
                ys_tool_t::filter_str(name);
                userid.nickname = name;
                if (userid.nickname.empty())
                {
                    logerror((LOG, "on_req_new_role, create random_name failed!"));

                    ret.code = ERROR_LG_EXCEPTION;
                    msg_sender_t::unicast(seskey_, conn_, ret);
                    return;
                }

                //! 异步执行步执行sql操作 只能用在async_do中
                char sql[256]; 
                sprintf(sql, "select uid from UserID where nickname='%s'",userid.nickname.c_str());
                db_service.async_select(sql, res);
            }while(res.affect_row_num() > 0);
            */

            userid.grade = 1;
            userid.viplevel = 0;
            userid.wingid = 0;
            userid.state = 0;
            userid.hostnum = jpk_.hostnum;
            userid.isoverdue = 0;
            if (userid.insert())
            {
                logerror((LOG, "on_req_new_role, create new role failed!"));
                ret.uid = 0;
                ret.code = ERROR_LG_EXCEPTION;
                msg_sender_t::unicast(seskey_, conn_, ret);
                logerror((LOG, "on_req_new_role, create new role failed return!"));
            }
            else{
                ret.uid = userid.uid;
                ret.role.uid = userid.uid;
                ret.role.nickname = userid.nickname();
                ret.role.resid = userid.resid;
                ret.role.level = userid.grade;
                ret.role.viplevel = userid.viplevel;
                ret.role.weaponid = 0;
                ret.code = SUCCESS;
                msg_sender_t::unicast(seskey_, conn_, ret);
            }

    }, seskey_, conn_, jpk_);
}

void sc_logic_t::on_req_treasure_give_occupy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_give_occupy_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_treasure_give_occupy, no uid : %d", jpk_.uid));
        sc_msg_def::ret_treasure_give_occupy_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sc_msg_def::ret_treasure_give_occupy_t ret;
    ret.code = user->treasure.give_slot_to_occupy(jpk_.uid, jpk_.pos);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(),0, 0, ret.code);
}

void sc_logic_t::on_req_treasure_giveup_help(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_giveup_help_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_treasure_giveup_help, no uid : %d", jpk_.uid));
        sc_msg_def::ret_treasure_giveup_help_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sc_msg_def::ret_treasure_giveup_help_t ret;
    ret.code = user->treasure.giveup_help(jpk_.uid);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(),0, 0, ret.code);
}

void sc_logic_t::on_req_card_comment(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_comment_card_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_card_comment, no uid : %d", jpk_.uid));
        sc_msg_def::ret_comment_card_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sc_msg_def::ret_comment_card_t ret;
    ret.code = card_comment_ins.req_add_comment(user, jpk_.uid, jpk_.resid, jpk_.isshow, jpk_.comment, ret.infos, ret.max_comment);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(),0, 0, ret.code);
}

void sc_logic_t::on_req_newest_card_comment(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_newest_card_comment_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_newest_card_comment, no uid : %d", jpk_.uid));
        sc_msg_def::ret_newest_card_comment_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    sc_msg_def::ret_newest_card_comment_t ret;
    if (jpk_.type == 1)
        ret.code = card_comment_ins.req_newest_comment(user, jpk_.resid, ret.infos, ret.max_comment);  
    else if (jpk_.type == 2)
        ret.code = card_comment_ins.req_hotest_comment(user, jpk_.resid, ret.infos);
    
    ret.type = jpk_.type;
    ret.stamp = date_helper.cur_sec();
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_get_index_role_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_index_role_info_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        user.reset(new sc_user_t);
        if (!user->load_db(jpk_.uid))
        {
            logerror((LOG, "on_get_index_role_info, load_db error no uid :%d", jpk_.uid));
            sc_msg_def::ret_index_role_info_t ret;
            ret.code = ERROR_SC_NO_USER;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
    }

    sc_msg_def::ret_index_role_info_t ret;
    
    ret.name = user->db.nickname();
    ret.resid = user->db.resid;
    if (jpk_.resid > 100)
    {
        //主角 
       user->get_index_role_info(ret.data);
       ret.isfind = 1;
       ret.code = SUCCESS;
       msg_sender_t::unicast(seskey_, conn_, ret);
    }else
    {
        sql_result_t res;
        char sql[256];
        sprintf(sql, "select pid from Partner where uid = %d and resid = %d;", jpk_.uid, jpk_.resid);
        db_service.sync_select(sql, res);
        if (0 == res.affect_row_num())
        {
            ret.code = SUCCESS;
            ret.isfind = 0;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }

        sql_result_row_t& row = *res.get_row_at(0);
        int32_t pid = (int)std::atoi(row[0].c_str());
        sp_partner_t partner = user->partner_mgr.get(pid);
        if (SUCCESS == partner->get_partner_jpk(ret.data))
            ret.code = SUCCESS;
        else
            ret.code = ERROR_SC_ILLEGLE_REQ;
        ret.isfind = 1;
        msg_sender_t::unicast(seskey_, conn_, ret);
    }
}

//点赞
void sc_logic_t::on_req_praise(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_praise_comment_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.praiseuid, user))
    {
        logerror((LOG, "on_req_praise, no uid : %d", jpk_.praiseuid));
        sc_msg_def::ret_praise_comment_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    

    sc_msg_def::ret_praise_comment_t ret;
    ret.id = jpk_.commentid;
    ret.code = card_comment_ins.add_parise_num(user, jpk_.commentid, jpk_.commentuid, jpk_.praiseuid);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//领取福袋奖励
void sc_logic_t::on_req_luckybag_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_luckybag_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_luckybag_reward, no uid with seskey:%lu", seskey_)); 
        sc_msg_def::ret_luckybag_reward_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_luckybag_reward, no uid:%d", uid));
        sc_msg_def::ret_luckybag_reward_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    user->reward.get_luckybag_reward(jpk_.id);
}

void sc_logic_t::on_req_pvelose_times(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pvelose_times_t &jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_pvelose_times, no uid : %d", jpk_.uid));
        sc_msg_def::ret_pvelose_times_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    sc_msg_def::ret_pvelose_times_t ret;
    ret.code = user->reward.get_pvelose_times(ret.times);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_get_weekly_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_weekly_reward_t &jpk_)
{
    int32_t uid;
    sc_msg_def::ret_get_weekly_reward_t ret;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_get_weekly_reward, no uid with seskey:%lu", seskey_));
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_get_weekly_reward, no uid:%d", uid));
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    ret.code = user->reward.get_weekly_reward(jpk_.id, ret.week_reward);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_get_online_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_online_reward_t &jpk_)
{
    int32_t uid;
    sc_msg_def::ret_get_online_reward_t ret;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_get_online_reward, no uid with seskey:%lu", seskey_));
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_get_online_reward, no uid:%d", uid));
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    ret.code = user->reward.get_online_reward_pack(jpk_.id, ret.online, ret.cd);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//改名功能
void sc_logic_t::on_req_change_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_name_t &jpk_)
{
    
   /* string msg = pushinfo.get_push(push_worldboss_killed,"ddd", 20, 100211,3,"haha",10,100323,1,0);
   // string msg = "竞技场前三";
    //msg = pushinfo.get_push(push_arena_rank_1, "霸主", 50, 10001, 10,"哈哈", 50, 10002, 10, 1);
    pushinfo.push(msg);
    return ;
    */
    if (!sc_service.has_host(jpk_.hostnum))
    {
        sc_msg_def::ret_change_name_t ret;
        ret.code = ERROR_UNKNOWN_SERVER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_user_t user_t;
    if (!usermgr().get(jpk_.uid, user_t))
    {
        logerror((LOG, "on_req_change_name, no uid : %d", jpk_.uid));
        sc_msg_def::ret_change_name_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    int leftPayyb = ((user_t->db.payyb + CHANGE_NAME_CONSUME_DIAMOND)>0)?(user_t->db.payyb + CHANGE_NAME_CONSUME_DIAMOND):0;
    //cout<<"GGG = "<<user_t->db.payyb<<"   YYY = "<<leftPayyb<<endl;
    int leftFreeyb = ((user_t->db.payyb + CHANGE_NAME_CONSUME_DIAMOND)>0)?user_t->db.freeyb:(user_t->db.payyb + CHANGE_NAME_CONSUME_DIAMOND + user_t->db.freeyb);
    //cout<<"AAA = "<<user_t->db.freeyb<<"   NNN = "<<leftFreeyb<<endl;
    if (leftFreeyb >= 0)
    {
        sql_result_t res;
        char sql[256];
        //验证名字是否合法，去重
        sprintf(sql, "select uid from UserID where nickname = '%s'", jpk_.name.c_str());
        db_service.sync_select(sql, res);
        if (res.affect_row_num() > 0)
        {
            logerror((LOG, "on_change_name, naem is already exist!"));
            sc_msg_def::ret_change_name_t ret;
            ret.code = ERROR_SC_NAME_EXISTENCE;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
        
        //名字不能为空
        bool isnamenil = false;
        if ( not jpk_.name.empty())
        {
            const char *name = jpk_.name.c_str();
            isnamenil = true;
            for (int i = 0; name[i] != '\0'; ++i)
            {
                int tp = name[i];
                if (name[i] != 32)
                {
                    isnamenil = false;
                    break;
                }
            }
        }

        if (jpk_.name.empty() || isnamenil)
        {
            logerror((LOG, "on_change_name, naem is already exist!"));
            sc_msg_def::ret_change_name_t ret;
            ret.code = ERROR_SC_NAME_NULL;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
         
        user_t->db.set_freeyb(leftFreeyb);
        user_t->db.set_payyb(leftPayyb);
        
        sc_msg_def::nt_yb_change_t nt;
        nt.now = leftPayyb + leftFreeyb;
        logic.unicast(user_t->db.uid, nt);
    
        db_service.async_do((uint64_t)jpk_.uid, [&](uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_name_t& jpk_)
        {
            
            sc_msg_def::ret_change_name_t ret;
            ret.code = SUCCESS;

            //更新数据库
            char buf2[512];
            sprintf(buf2, "update UserID set nickname = '%s' where uid = '%d'", jpk_.name.c_str(),jpk_.uid);
            char buf3[512];
            sprintf(buf3,"update UserInfo set nickname = '%s' where uid = '%d'", jpk_.name.c_str(),jpk_.uid);
            db_service.async_execute(buf2);
            db_service.async_execute(buf3);
            sp_gang_t sp_gang;
            sp_ganguser_t sp_guser;
            if (gang_mgr.get_gang_by_uid(jpk_.uid, sp_gang, sp_guser))
            {
                sp_guser->on_rename(jpk_.name);
            }
            ret.code = SUCCESS;
            ret.nickname = jpk_.name.c_str();
            msg_sender_t::unicast(seskey_, conn_, ret);
        }, seskey_, conn_, jpk_);
    }else
    {
        logerror((LOG, "on_req_change_name, diamond is not enough!"));
        sc_msg_def::ret_change_name_t ret;
        ret.code = ERROR_SC_NO_YB;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

}

void sc_logic_t::on_req_set_kanban_role(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_kanban_role_t& jpk_)
{
    sp_user_t user;
    if (!usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_set_kanban_role, no uid : %d", jpk_.uid));
        sc_msg_def::ret_set_kanban_role_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    sc_msg_def::ret_set_kanban_role_t ret;
    user->set_kanban_role(jpk_.uid, jpk_.resid, jpk_.type);
    ret.resid = jpk_.resid;
    ret.type = jpk_.type;
    ret.code = 0;
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_get_open_service_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_open_service_reward_t& jpk_)
{
    sp_user_t user;
    if (!usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_get_open_service_reward, no uid : %d", jpk_.uid));
        sc_msg_def::ret_get_open_service_reward_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    sc_msg_def::ret_get_open_service_reward_t ret;
    ret.code = user->get_open_service_reward(jpk_.index);
    ret.index = jpk_.index;
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_buy_growing_package(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_growing_package_t& jpk_)
{
    sp_user_t user;
    if (!usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_buy_growing_package, no uid : %d", jpk_.uid));
        sc_msg_def::ret_buy_growing_package_t ret;
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    
    sc_msg_def::ret_buy_growing_package_t ret;
    ret.code = user->reward.buy_growing_package(ret.growing_reward);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_del_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_)
{
    db_service.async_do((uint64_t)jpk_.uid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_){

            logwarn((LOG, "req_del_role，uid:%d", jpk_.uid)); 

            lg_msg_def::ret_del_role_t ret;
            ret.uid = jpk_.uid;
            ret.code = SUCCESS;

            sql_result_t res;
            if (db_UserID_ext_t::select_uid_condition(jpk_.uid, "state>=0", res))
            {
            logerror((LOG, "req_del_role，no uid:%d", jpk_.uid)); 
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }

            db_UserID_ext_t userid;
            userid.init(*res.get_row_at(0));
            userid.set_state(-1);
            db_service.async_execute(userid.get_up_sql());

            sc_service.async_do([](uint32_t uid_){
                    logic.on_role_deleted(uid_);
                    }, jpk_.uid);

            msg_sender_t::unicast(seskey_, conn_, ret);
    }, seskey_, conn_, jpk_);
}
//@login end
//@scene begin
void sc_logic_t::on_req_login(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_login_t& jpk_)
{
    logwarn((LOG, "user login ...! uid:%d", jpk_.uid));

    sc_msg_def::ret_login_t ret;
    ret.code = SUCCESS;

    db_UserID_ext_t userid;

    //PERFORMANCE_GUARD("load userid from db");
    sql_result_t res;
    //确认角色存在
    if (db_UserID_t::sync_select_uid_condition(jpk_.uid, "state>=0", res))
    {
        logerror((LOG, "user login failed! no uid:%d", jpk_.uid));
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    userid.init(*res.get_row_at(0));

    //检查当前用户是否属于当前服务器
    if (!has_host(userid.hostnum))
    {
        logerror((LOG, "user login failed error host! uid:%d, host:%d", jpk_.uid, userid.hostnum));
        ret.code = ERROR_UNKNOWN_SERVER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    //检查当前用户是否被封停
    if (userid.state == 2)
    {
        ret.code = ERROR_USER_EXCPEL; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    //建立用户数据
    sp_user_t user;
    bool incache=true, online=true;
    if (!(incache = cache.get(jpk_.uid, user)) && !(online=usermgr().get(jpk_.uid, user))) //在cache中不存在
    {

        {
            //PERFORMANCE_GUARD("load userinfo from db");
            user.reset(new sc_user_t);
            if (!user->load_db(userid.uid))
            {
                user->init_new_user(userid);

                //生成新角色记录
                if( user->mac.find("robot") == std::string::npos )
                    statics_ins.unicast_newrole(user,jpk_.mac,jpk_.domain);

                //为新用户创建view的cache
                sp_view_user_t sp_view = user->get_view();
                view_cache.put(jpk_.uid, sp_view);
            }
            usermgr().insert(user->db.uid, user);
        }

        //发送竞技场第一上线事件
        if( user->db.rank == 1 )
            pushinfo.new_push(push_arena_first,user->db.nickname(),user->db.grade,user->db.uid,user->db.viplevel);

        session.add(seskey_, jpk_.uid);
    }
    else
    {
        if (incache)
        {
            //如果用户数据过期，重新加载
            if (userid.isoverdue)
            {
                user.reset(new sc_user_t);
                if (!user->load_db(userid.uid))
                {
                    user->init_new_user(userid);

                    //生成新角色记录
                    if( user->mac.find("robot") == std::string::npos )
                        statics_ins.unicast_newrole(user,jpk_.mac,jpk_.domain);

                    //为新用户创建view的cache
                    sp_view_user_t sp_view = user->get_view();
                    view_cache.put(jpk_.uid, sp_view);
                }
                //重置过期
                userid.set_isoverdue(0);
                string sql = userid.get_up_sql();
                if (!sql.empty())
                {
                    db_service.async_do((uint64_t)userid.uid, [](string& sql_){
                            db_service.async_execute(sql_);
                            }, sql);
                }
            }
            usermgr().insert(jpk_.uid, user);
        }

        //如果已经在线，且不同的seskey则将之前的用户会话断开
        uint64_t existed_seskey = session.get_seskey(jpk_.uid);
        if (existed_seskey!=0&&existed_seskey != seskey_)
        {
            inner_msg_def::nt_session_broken_t jpk;
            jpk.seskey = existed_seskey;
            on_session_broken(seskey_,conn_,jpk);
            session.broken_seskey(existed_seskey, conn_);
        }

        //发送竞技场第一上线事件
        if( user->db.rank == 1 )
            pushinfo.new_push(push_arena_first,user->db.nickname(),user->db.grade,user->db.uid,user->db.viplevel);

        session.add(seskey_, jpk_.uid);
    }

    {
        //PERFORMANCE_GUARD("load user system");
        //道具补偿
        compensate(user);

        //用户被禁言
        if (userid.state == 4)
        {
            user->notalk=true;
        }

        //触发玩家首次登录，连续登录等奖励
        user->reward.cast_login(1);

        
        //新建账号默认有鱼肠 
        if(!user->partner_mgr.has_hero(16))
        {
            user->partner_mgr.hire_from_reward(16, 1);
        }

        user->login_time = 0;
        //记录用户登录信息
        user->mac = jpk_.mac;
        user->plat_name = jpk_.name;
        user->plat_domain = jpk_.domain;
        user->sys = jpk_.sys;
        user->device = jpk_.device;
        user->os = jpk_.os;
        user->current_step = 0;
        user->counttime = user->db.totaltime;

        //领取试炼场奖励
        //scuffle_mgr.get_reward();

        //放进试炼场玩家库
        grade_user_cache.put_user(user);

        //建立角色名索引
        name_cache.put(user->db.nickname(),user->db.uid);

        //处理用户登录事件
        user->on_login();

        //添加用户到竞技场排名页缓存
        arena_page_cache.add_user(user);

        //设置公会用户上线
        sp_gang_t sp_gang; 
        sp_ganguser_t sp_guser; 
        if (gang_mgr.get_gang_by_uid(user->db.uid, sp_gang, sp_guser))
        {
            sp_gang->on_login(jpk_.uid);
        }

        //处理用户可能的支付结算
        pay_ins.on_login(user);

        //更新每日签到
        user->update_sign_info();
    }

    //更新账户表上上一次登陆的角色id和服务器id
    dbgl_service.async_do((uint64_t)jpk_.uid,[](int32_t uid_,int32_t hostnum_,int32_t aid_){
            char sql[256];
            sprintf(sql, "UPDATE Account SET lastuid=%d,lasthostnum=%d WHERE aid=%d",uid_,hostnum_,aid_);
            dbgl_service.async_execute(sql);
            },user->db.uid,user->db.hostnum,user->db.aid);

    ret.step = user->db.isnew;
    msg_sender_t::unicast(seskey_, conn_, ret);

    logwarn((LOG, "user login ok! uid:%d", jpk_.uid));

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
void sc_logic_t::on_req_user_data(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_user_data_t& jpk_)
{
    int32_t uid = jpk_.uid;
    /*
       if ((uid = session.get_uid(seskey_))==0)
       {
       logerror((LOG, "on_req_role_data, no uid with seskey:%lu", seskey_));
       session.dump();

       sc_msg_def::ret_role_data_fail_t ret;
       ret.code = ERROR_SC_EXCEPTION;
       msg_sender_t::unicast(seskey_, conn_, ret);
       return;
       }
       */

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_user_data, no uid:%d", uid));
        
        sc_msg_def::ret_user_data_failed_t ret;
        ret.uid = uid;
        ret.code = ERROR_SC_EXCEPTION;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sc_msg_def::ret_user_data_t ret;
    user->get_user_jpk(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求进入主城
void sc_logic_t::on_req_enter_city(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_city_t& jpk_)
{
    sc_msg_def::ret_enter_city_t ret;

    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_enter_city, no uid with seskey:%lu", seskey_));
        ret.code = ERROR_SC_EXCEPTION;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_enter_city, no uid:%d", uid));
        return;
    }
    //设置玩家在线
    if( !user->login_time )
    {
        user->login_time = date_helper.cur_sec();
        //生成登录记录
        if( user->mac.find("robot") == std::string::npos )
            statics_ins.unicast_loginlog(user);

        // 不能直接进入乱斗场
        if( jpk_.resid == 2000 )
        {
            jpk_.resid = 1001;
        }
        /*
            scuffle_mgr.login_enter_scuffle(user,jpk_.show_player_num);
            return;
        }
        */
    }

    if( jpk_.resid == 2000 )
    {
        scuffle_mgr.enter_scuffle(user,jpk_.show_player_num);
        return;
    }

    citymgr().enter_city(uid, jpk_);
}
//开始挂机
void sc_logic_t::on_begin_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_auto_round_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_halt, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_begin_halt, no uid:%d", uid));
        return;
    }

    user->round.start_halt(jpk_.resid, jpk_.repeat_num);
}
//获取挂机结果
void sc_logic_t::on_req_halt_result(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_auto_round_resu_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->round.get_halt_result(jpk_.resid, jpk_.flag);
}
//零点时，请求登录奖励
void sc_logic_t::on_req_login_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lg_rewardinfo_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->reward.cast_login(2);

    sc_msg_def::ret_lg_rewardinfo_t ret;
    user->reward.get_login_jpk(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//新手引导奖励伙伴
void sc_logic_t::on_guidence_get_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_partner_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_set_guidence, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_set_guidence, no uid:%d", uid));
        return;
    }

    if ( (user->db.isnew & (1<< evt_guidence_partner)) > 0 )
    {
        sc_msg_def::ret_guidence_partner_fail_t fail;
        fail.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, fail);
        return;
    }

    //获取伙伴的resid
    repo_def::role_t *role = repo_mgr.role.get(user->db.resid);
    if (role == NULL)
    {
        logerror((LOG,"on_guidence_gemstone, repo no resid!"));
        return;
    } 
    int32_t par_resid = 0;
    switch( role->job )
    {
        case 2:
            par_resid = 2016;
            break;
        case 3:
            par_resid = 2021;
            break;
        case 4:
            par_resid = 2021;
            break;
        default:
            return;
    }

    sc_msg_def::ret_guidence_partner_t ret;
    if( user->partner_mgr.get_specific_partner(par_resid,ret.partner)==0 )
    {
        msg_sender_t::unicast(seskey_, conn_, ret);

        //写新手引导步骤
        guidence_ins.on_guidence_event(*user,evt_guidence_partner);
        return;
    }

    sc_msg_def::ret_guidence_partner_fail_t fail;
    fail.code = ERROR_SC_EXCEPTION;
    msg_sender_t::unicast(seskey_, conn_, fail);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),5001,1);
}
//新手引导请求随机名字
void sc_logic_t::on_req_random_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_random_name_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_set_guidence, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_set_guidence, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_random_name_t ret;
    ret.name = gen_name.random_name();
    ys_tool_t::filter_str(ret.name);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//记录新手引导相关功能点
void sc_logic_t::on_nt_function(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_function_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_set_guidence, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_set_guidence, no uid:%d", uid));
        return;
    }

    user->db.set_func(jpk_.func);
    user->save_db();
}
//新手引导修改角色名
void sc_logic_t::on_guidence_rename(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_rename_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_set_guidence, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_set_guidence, no uid:%d", uid));
        return;
    }

    if ( (user->db.isnew & ( 1<< evt_guidence_name )) > 0 )
    {
        sc_msg_def::ret_guidence_rename_t fail;
        fail.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, fail);
        return;
    }

    sc_msg_def::ret_guidence_rename_t ret;
    if (user->db.nickname() == jpk_.name)
    {
        ret.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, ret);

        //写新手引导步骤
        guidence_ins.on_guidence_event(*user,evt_guidence_name);

        return;
    }

    ys_tool_t::filter_str(jpk_.name);
    if (jpk_.name.empty())
    {
        sc_msg_def::ret_guidence_rename_t fail;
        fail.code = ERROR_SC_ILLEGLE_REQ;
        msg_sender_t::unicast(seskey_, conn_, fail);
        return;
    }

    db_service.async_do((uint64_t)uid, [](uint64_t seskey_, sp_rpc_conn_t conn_, uint32_t uid_, const string& name_){

            char sql[512];
            sprintf(sql, "select uid from UserInfo where nickname = '%s'", name_.c_str());

            sql_result_t res;
            db_service.async_select(sql, res);
            if( res.affect_row_num() >= 1)
            {
            sc_msg_def::ret_guidence_rename_t ret;
            ret.code = ERROR_SC_NAME_EXISTENCE;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }

            db_service.async_execute("begin");
            sprintf(sql,"update UserInfo set nickname='%s' where uid=%d", name_.c_str(),uid_);
            if ( db_service.async_execute(sql)!=SUCCESS )
            {
            db_service.async_execute("rollback");

            sc_msg_def::ret_guidence_rename_t ret;
            ret.code = ERROR_SC_NAME_EXISTENCE;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }
            sprintf(sql, "update UserID set nickname = '%s' where uid=%d", name_.c_str(), uid_);
            if ( db_service.async_execute(sql)!=SUCCESS )
            {
                db_service.async_execute("rollback");

                sc_msg_def::ret_guidence_rename_t ret;
                ret.code = ERROR_SC_NAME_EXISTENCE;
                msg_sender_t::unicast(seskey_, conn_, ret);
                return;
            }
            db_service.async_execute("commit");

            sc_service.async_do([](uint64_t seskey_, sp_rpc_conn_t conn_, uint32_t uid_, const string& name_){
                    sp_user_t user;
                    if (logic.usermgr().get(uid_, user))
                    {
                    user->db.nickname = name_;        
                    activity.on_rename(user->db.uid, name_);
                    sc_msg_def::ret_guidence_rename_t ret;
                    ret.code = SUCCESS;
                    msg_sender_t::unicast(seskey_, conn_, ret);

                    //写新手引导步骤
                    guidence_ins.on_guidence_event(*user,evt_guidence_name);
                    }
                    }, seskey_, conn_, uid_, name_); 
    }, seskey_, conn_, uid, jpk_.name);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//记录新手当前步骤
void sc_logic_t::on_current_step_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_quit_step_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "1-on_guidence_gemstone, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_guidence_gemstone, no uid:%d", uid));
        return;
    }
    user->current_step = jpk_.step;
}

/*
//新手引导奖励宝石
void sc_logic_t::on_guidence_gemstone(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_gemstone_t &jpk_)
{
int32_t uid;
if ((uid = session.get_uid(seskey_))==0)
{
logerror((LOG, "on_guidence_gemstone, no uid with seskey:%lu", seskey_));
return;
}
sp_user_t user;
if (!usermgr().get(uid, user))
{
logerror((LOG, "on_guidence_gemstone, no uid:%d", uid));
return;
}

if ( user->db.isnew >= evt_guidence_gemstone )
{
sc_msg_def::ret_guidence_gemstone_fail_t ret;
ret.code = SUCCESS;
msg_sender_t::unicast(seskey_, conn_, ret);
return;
}

//获取该玩家的职业
int32_t gem_resid, gem_count=1;
repo_def::role_t *role = repo_mgr.role.get(user->db.resid);
if (role == NULL)
{
logerror((LOG,"on_guidence_gemstone, repo no resid!"));
return;
} 
switch( role->job )
{
case 2:
case 3:
gem_resid = 17101;
break;
case 4:
gem_resid = 17201;
break;
default:
return;
}

//写新手引导步骤
guidence_ins.on_guidence_event(*user,evt_guidence_gemstone);

//增加宝石
sc_msg_def::nt_bag_change_t nt;
user->item_mgr.addnew(gem_resid,gem_count,nt);
user->item_mgr.on_bag_change(nt);

sc_msg_def::ret_guidence_gemstone_t ret;
ret.resid = gem_resid;
ret.count = gem_count;
msg_sender_t::unicast(seskey_, conn_, ret);

//记录事件
statics_ins.unicast_eventlog(*user,jpk_.cmd(),gem_resid,gem_count);
}
*/

/*
//新手引导奖励精灵洗礼
void sc_logic_t::on_guidence_potential(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_potential_t &jpk_)
{
int32_t uid;
if ((uid = session.get_uid(seskey_))==0)
{
logerror((LOG, "on_guidence_gemstone, no uid with seskey:%lu", seskey_));
return;
}
sp_user_t user;
if (!usermgr().get(uid, user))
{
logerror((LOG, "on_guidence_gemstone, no uid:%d", uid));
return;
}

sc_msg_def::ret_guidence_potential_t ret;
if ( user->db.isnew >= evt_guidence_genine )
{
ret.code = SUCCESS;
msg_sender_t::unicast(seskey_, conn_, ret);
return;
}

//写新手引导步骤
guidence_ins.on_guidence_event(*user,evt_guidence_genine);

//增加
sc_msg_def::nt_bag_change_t nt;
user->item_mgr.addnew(15001,1,nt);
user->item_mgr.on_bag_change(nt);

ret.code = SUCCESS;
msg_sender_t::unicast(seskey_, conn_, ret);

//记录事件
statics_ins.unicast_eventlog(*user,jpk_.cmd(),15001,1);
}
*/

void sc_logic_t::on_guidence_pub(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_pub_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "2-on_guidence_gemstone, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_guidence_gemstone, no uid:%d", uid));
        return;
    }
    if( (user->db.isnew & (1<< evt_guidence_pub)) > 0 )
    {
        sc_msg_def::ret_guidence_pub_fail_t ret;
        ret.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }


    int32_t par_resid = 2104;

    if( user->partner_mgr.has_hero(par_resid) )
        return;
    //获取伙伴
    sp_partner_t sp_par = user->partner_mgr.hire( par_resid,1 );
    if( sp_par == NULL )
    {
        logerror((LOG, "on_guidence_pub, repo no resid:%d", par_resid));
        return;
    }

    sc_msg_def::ret_guidence_pub_t ret;
    ret.yb_left = 3600;
    ret.kg_left = 7200;
    sp_par->get_partner_jpk(ret.partner);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //写新手引导步骤
    guidence_ins.on_guidence_event(*user,evt_guidence_pub);

    pub_ctl.set_flushtm(user);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),par_resid,1);
}

//开始十二宫挂机
void sc_logic_t::on_begin_zodiac_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_auto_zodiac_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_halt, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_begin_halt, no uid:%d", uid));
        return;
    }

    user->round.start_zodiac_halt(jpk_.gid);
}
//获取十二宫挂机结果
void sc_logic_t::on_req_zodiac_halt_result(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_auto_zodiac_resu_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->round.get_zodiac_halt_result(jpk_.gid, jpk_.flag);
}
//请求开启星座图系统
void sc_logic_t::on_req_star_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_open_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->star_mgr.open_attr(jpk_);
}
//请求刷新星座图系统
void sc_logic_t::on_req_star_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_flush_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->star_mgr.flush_attr(jpk_);
}
//请求获得星座图属性
void sc_logic_t::on_req_star_get(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_get_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->star_mgr.get_attr(jpk_);
}
//请求设置星座图系统
void sc_logic_t::on_req_star_set(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_set_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_halt_result, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_halt_result, no uid:%d", uid));
        return;
    }

    user->star_mgr.set_attr();
}
//结束挂机
void sc_logic_t::on_end_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_stop_auto_round_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_end_halt, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_halt, no uid:%d", uid));
        return;
    }

    user->round.stop_halt();
}
//刷新关卡
void sc_logic_t::on_flush_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_flush_round_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_flush_round, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_flush_round, no uid:%d", uid));
        return;
    }

    user->round.flush_round(jpk_.gid);
}
//请求刷新酒馆
void sc_logic_t::on_req_pub_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_flush_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_pub_flush, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_pub_flush, no uid:%d", uid));
        return;
    }

    /*
       if( (jpk_.flag<0) || (jpk_.flag>3) )
       {
       logerror((LOG, "on req_pub_flush,no flag:%d",jpk_.flag));
       sc_msg_def::ret_pub_flush_failed_t ret;
       ret.code = ERROR_SC_ILLEGLE_REQ;
       msg_sender_t::unicast(seskey_, conn_, ret);
       return;
       }

       sc_msg_def::ret_pub_flush_t ret;
       int32_t res = pub_ctl.get_pub_info(user,uid,jpk_.flag,ret);
       */

    int32_t res = pub_ctl.flush_pub(user,uid,jpk_.flag,jpk_.cmd());
    if( res )
    {
        sc_msg_def::ret_pub_flush_failed_t fail;
        fail.code = res;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
}
//请求返回刷新时间
void sc_logic_t::on_req_pub_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_time_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_pub_flush, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_pub_flush, no uid:%d", uid));
        return;
    }

    pub_ctl.get_free_time(user,uid);
}
// 请求进入招募
void sc_logic_t::on_req_enter_pub(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_pub_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_pub_flush, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_pub_flush, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_enter_pub_t ret;
    ret.code = pub_ctl.req_enter_modular(user, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(), ret.code);
}
/*
//获取当天的限时金色英雄碎片
void sc_logic_t::on_req_gold_chip(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gold_chip_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_pub_flush, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_pub_flush, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_gold_chip_t ret;
    ret.gold_chip = pub_ctl.get_gold_chip();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
*/

//英雄系统
//请求雇佣伙伴
void sc_logic_t::on_req_hire_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hire_partner_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_fire_partner, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_fire_partner, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_hire_partner_t ret;
    int res = user->partner_mgr.hire_from_chip(jpk_.resid, ret.partner);

    if( SUCCESS == res )
        msg_sender_t::unicast(seskey_, conn_, ret);
    else
    {
        sc_msg_def::ret_hire_partner_failed_t fail;
        fail.code = res;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
}

//请求解雇伙伴
void sc_logic_t::on_req_fire_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fire_partner_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_fire_partner, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_fire_partner, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_fire_partner_t ret;
    ret.pid = jpk_.pid;
    int32_t resid = 0;
    ret.code = user->partner_mgr.fire( jpk_.pid ,resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),resid,1,ret.code);
}

//请求兑换灵能
void sc_logic_t::on_req_chip_to_soul(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_to_soul_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_fire_partner, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_fire_partner, no uid:%d", uid));
        return;
    }

    user->partner_mgr.chip_to_soul(jpk_.chips);
}

//通知移动
void sc_logic_t::on_nt_move(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_move_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_nt_move, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_nt_move, no uid:%d", uid));
        return;
    }

    if( jpk_.sceneid == 2000 )
    {
        scuffle_mgr.move(jpk_,user->db.uid);
        return;
    }

    citymgr().move(jpk_);
}
void sc_logic_t::on_session_broken(uint64_t seskey_, sp_rpc_conn_t conn_, inner_msg_def::nt_session_broken_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(jpk_.seskey))==0)
    {
        //logerror((LOG, "on_session_broken, no uid with seskey:%lu", seskey_));
        return;
    }

    session.on_broken(jpk_.seskey);

    sp_user_t user;
    if (usermgr().get(uid, user))
    {
        //记录事件
        statics_ins.unicast_eventlog(*user,jpk_.cmd());

        //清除关卡状态
        user->round.clear_state();
        user->treasure.clear_state();

        //清除主城boss状态
        if( user->city_boss_id )
            cityboss.fight(user,user->city_boss_id,false);

        //处理乱斗场事件
        //scuffle_mgr.on_loginoff(user);

        //通知该玩家的好友，我下线了
        user->friend_mgr.on_online_change(0);

        //保存符文系统到数据库
//        user->rune_mgr.save_db();

        //如果有未成功领取的礼包则立刻领取
        //user->item_mgr.given_pack_item();

        //保存奖励
        user->reward.save_db();

        //从城市中移除
        citymgr().del_uid(uid, user->db.sceneid);

        int32_t cursec = date_helper.cur_sec();
        if( user->login_time == 0 )
            user->login_time = cursec;
        //保存玩家退出时间
        user->db.set_lastquit(cursec);
        user->counttime = user->db.totaltime;
        user->db.set_totaltime( user->db.totaltime + ( cursec - user->login_time ) );

        //生成玩家退出记录
        if( user->mac.find("robot") == std::string::npos )
            statics_ins.unicast_quitlog(user);

        //设置玩家下线状态
        user->login_time = 0;

        //保存玩家战斗力
        user->db.set_fp(user->get_total_fp());
        user->save_db(); 

        //保存玩家id表
        user->save_db_userid();

        //设置公会玩家下线
        sp_gang_t sp_gang; 
        sp_ganguser_t sp_guser; 
        if (gang_mgr.get_gang_by_uid(user->db.uid, sp_gang, sp_guser))
        {
            sp_gang->on_session_broken(uid);
        }
        //清除聊天信息
        notify_cache.on_session_broken(user->db.uid);

        //保存玩家数据
        sp_view_user_t sp_view = user->get_view();
        view_cache.put(uid, sp_view);

        //这种情况是网关通知链接断开
        if (seskey_ == jpk_.seskey)
        {
            //从在线列表中移除
            usermgr().erase(uid);
            //放入到cache中
            cache.put(uid, user);
        }
        logwarn((LOG, "on_session_broken, seskey:%lu, uid:%d, ref_user:%d, ref_view:%d", seskey_, uid, user.use_count(), sp_view.use_count()));
    }
}
//开始关卡
void sc_logic_t::on_begin_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->round.enter_round(jpk_.resid, jpk_.flag,jpk_.uid,jpk_.pid);
}
//结束关卡
void sc_logic_t::on_end_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_end_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_end_round, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->round.exit_round(jpk_.resid, jpk_.win, jpk_.stars, jpk_.killed);
}
//请求离线经验
void sc_logic_t::on_req_offline_exp(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_offline_exp_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_offline_exp, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_offline_exp, no uid:%d", uid));
        return;
    }

    user->cal_offline_exp();
}

//请求体力增长
void sc_logic_t::on_req_gen_power(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_power_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_gen_power, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_gen_power, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_gen_power_t ret;
    user->gen_power(ret.left_gen_seconds, ret.power);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求活力增长
void sc_logic_t::on_req_gen_energy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_energy_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_gen_energy, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_gen_energy, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_gen_energy_t ret;
    user->gen_energy(ret.left_gen_seconds, ret.energy);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求试炼场信息
void sc_logic_t::on_req_trial_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_trial_info_t ret;
    trial_ctl.get_trial_info(user,uid,ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求试炼场接任务
void sc_logic_t::on_req_trial_receive_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_receive_task_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_receive_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_receive_task, no uid:%d", uid));
        return;
    }

    trial_ctl.receive_task(uid,user->db.grade,jpk_.pos);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}

//放弃试炼场任务
void sc_logic_t::on_req_trial_giveup_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_giveup_task_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_giveup_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_giveup_task, no uid:%d", uid));
        return;
    }

    trial_ctl.giveup_task(uid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//刷新试炼场任务
void sc_logic_t::on_req_trial_flush_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_flush_task_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    trial_ctl.flush_task(user,uid,1);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//试炼场开始战斗
void sc_logic_t::on_req_trial_start_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_start_batt_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    trial_ctl.start_battle(user,uid,user->db.grade,jpk_.pos);
}
//试炼场结束战斗
void sc_logic_t::on_req_trial_end_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_end_batt_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    trial_ctl.end_battle(user,uid,jpk_.battle_win);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.battle_win);
}
//试炼场领取奖励
void sc_logic_t::on_req_trial_rewards(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_rewards_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_rewards, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_rewards, no uid:%d", uid));
        return;
    }

    trial_ctl.get_rewards(user,uid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//刷新试炼场对手
void sc_logic_t::on_req_trial_flush_targets(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_flush_targets_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    trial_ctl.flush_targets(user,uid,user->db.grade);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
//伙伴或者主角升阶
void sc_logic_t::on_req_upquality(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_quality_up_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_partner_upquality, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_partner_upquality, no uid:%d", uid));
        return;
    }

    if( 0 == jpk_.pid )
    {
        //主角升阶
        user->on_quality_change();
    }
    else
    {
        //伙伴升阶
        sp_partner_t partner = user->partner_mgr.get(jpk_.pid);
        if( !partner )
        {
            logerror((LOG, "on_req_partner_upquality, no pid:%d", jpk_.pid));
            return;
        }
        partner->on_quality_change();
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pid);

}
//阵型改变
void sc_logic_t::on_team_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_team_change_t &jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_team_change, no uid, seskey:%lu", seskey_));
        return;
    }
    sp_user->team_mgr.change_team(jpk_.team, jpk_.tid);
    //sp_user->on_team_pro_changed(); 

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
//移除队伍
/*
void sc_logic_t::on_remove_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_remove_team_t &jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user ==NULL)
    {
        logerror((LOG, "on_team_change, no uid, seskey:%lu", seskey_));
        return;
    }
    sp_user->team_mgr.remove_team(jpk_.tid);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
*/
//改变默认队伍
void sc_logic_t::on_change_default_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_default_team_t &jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user ==NULL)
    {
        logerror((LOG, "on_team_change, no uid, seskey:%lu", seskey_));
        return;
    }
    sp_user->team_mgr.change_default_team(jpk_.tid);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

//改变队伍名称
void sc_logic_t::on_change_team_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_change_team_name &jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user ==NULL)
    {
        logerror((LOG, "on_team_change, no uid, seskey:%lu", seskey_));
        return;
    }
    sp_user->team_mgr.change_team_name(jpk_.tid, jpk_.name);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
    
//穿/脱装备
void sc_logic_t::on_req_wear_equip(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_wear_equip_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_wear_equip, no seskey:%d", seskey_));
        return;
    }

    sc_msg_def::ret_wear_equip_t ret;
    ret.pid = jpk_.pid;
    ret.eid = jpk_.eid;
    ret.flag = jpk_.flag;
    ret.slot_pos = jpk_.slot_pos;

    switch(jpk_.flag)
    {
        case 0:
            ret.code = sp_user->equip_mgr.takeoff_equip(jpk_.pid, jpk_.eid, jpk_.slot_pos);
            break;
        case 1:
            ret.code = sp_user->equip_mgr.wear_equip(jpk_.pid, jpk_.eid, jpk_.slot_pos);
            break;
    }

    if (ret.code == SUCCESS)
    {
        sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
        sp_equip->get_equip_jpk(ret.weared_equip);
    }

    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.pid,jpk_.eid,ret.code,ret.flag);
}
//装备升级
void sc_logic_t::on_req_equip_upgrade(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upgrade_equip_t& jpk_)
{
    sc_msg_def::ret_upgrade_equip_failed_t failed;
    failed.eid = jpk_.eid;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
    if (sp_equip == NULL)
    {
        failed.code = ERROR_EQ_NO_EQ;
        logerror((LOG, "on_req_equip_upgrade, no equip:%d", jpk_.eid));
        return;
    }

    failed.code = sp_equip->upgrade(jpk_.num);
    if (failed.code != SUCCESS)
    {
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.eid,jpk_.num,failed.code);

}
//请求装备合成
void sc_logic_t::on_req_equip_compose(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_equip_t& jpk_)
{
    sc_msg_def::ret_compose_equip_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
    if (sp_equip == NULL)
    {
        failed.code = ERROR_EQ_NO_EQ;
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    failed.code = sp_equip->compose(jpk_.dst_resid);
    if (failed.code != SUCCESS)
    {
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.dst_resid,jpk_.eid,failed.code);

}
//请求装备合成
void sc_logic_t::on_req_equip_compose_by_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_equip_yb_t& jpk_)
{
    sc_msg_def::ret_compose_equip_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
    if (sp_equip == NULL)
    {
        failed.code = ERROR_EQ_NO_EQ;
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    failed.code = sp_equip->compose_by_yb(jpk_.dst_resid);
    if (failed.code != SUCCESS)
    {
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.dst_resid,jpk_.eid,failed.code);

}
//请求开启镶嵌槽
void sc_logic_t::on_req_open_gemstore_slot(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_slot_open_t& jpk_)
{
    sc_msg_def::ret_gemstone_slot_open_t ret;
    ret.code = SUCCESS; 
    ret.eid = jpk_.eid;
    ret.slotid = jpk_.slotid;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
    ret.code = sp_equip->open_slot(jpk_.slotid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.eid,jpk_.slotid,ret.code);

}
//请求宝石镶嵌
void sc_logic_t::on_req_gemstone_inlay(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_inlay_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_gem_page_info, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_gem_page_info, no uid:%d", uid));
        return;
    }

    // 新代码
    sc_msg_def::ret_gemstone_inlay_t ret;
    sp_gem_t sp_gem;
    ret.code = sp_user->gem_page_mgr.get(jpk_.pageid, jpk_.slotid, sp_gem);
    if (ret.code == SUCCESS)
    {
        if (jpk_.flag == 1)
        {
            ret.code = sp_gem->inlay(jpk_.resid, ret);
        }
        else
        {
            ret.code = sp_gem->unlay(ret);
        }
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, jpk_.pageid, jpk_.slotid, jpk_.flag);
    /*
    sc_msg_def::ret_gemstone_inlay_failed_t failed;
    failed.resid = jpk_.resid;
    failed.eid = jpk_.eid;
    failed.slotid = jpk_.slotid;
    failed.flag = jpk_.flag;
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sp_equip_t sp_equip = sp_user->equip_mgr.get(jpk_.eid);
    if (jpk_.flag == 1)
    {
        failed.code = sp_equip->inlay(jpk_.resid, jpk_.slotid);
    }
    else{
        failed.code = sp_equip->unlay(jpk_.flag, jpk_.slotid);
    }

    if ( failed.code != SUCCESS )
    {
        msg_sender_t::unicast(seskey_, conn_, failed);
    }
    else
    {
        sc_msg_def::ret_gemstone_inlay_t ret;
        ret.resid = jpk_.resid;
        ret.eid = jpk_.eid;
        ret.slotid = jpk_.slotid;
        ret.flag = jpk_.flag;
        sp_equip->get_equip_jpk(ret.equip);
        msg_sender_t::unicast(seskey_, conn_, ret);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,jpk_.eid,failed.code,jpk_.flag);
    */
}
//请求宝石合成
void sc_logic_t::on_req_gemstone_compose(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_compose_t& jpk_)
{
    sc_msg_def::ret_gemstone_compose_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    failed.code = sp_user->item_mgr.gemstone_compose(jpk_.src_resid, jpk_.compose_num, jpk_.safe);
    if (failed.code != SUCCESS)
    {
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.src_resid,jpk_.compose_num,failed.code,jpk_.safe);

}
//请求宝石一键镶嵌/卸下
void sc_logic_t::on_req_gemstone_inlay_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_inlay_all_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_gemstone_inlay, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_gemstone_inlay_all, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_gemstone_inlay_all_t ret;
    ret.eg.resize(5);
    for(int i=0;i<5;i++)
    {
        ret.eg[i].resize(5);
        for(int j=0;j<5;j++)
        {
            ret.eg[i][j] = 0;
        }
    }
    for(int i=0;i<5;i++)
    {
        int32_t pageid = jpk_.eg[i][5];
        int32_t gemtype = 17100+i*100;
        for(int j=0;j<5;j++)
        {
            int slotid = j+1;
            sp_gem_t sp_gem;
            ret.code = sp_user->gem_page_mgr.get(pageid,gemtype*10+slotid,sp_gem);
            if (ret.code != SUCCESS)
                break;
            sc_msg_def::ret_gemstone_inlay_t ret2;
            if (jpk_.flag == 1)
            {
                if (jpk_.eg[i][j] != 0)
                {
                    ret2.code = sp_gem->inlay(jpk_.eg[i][j], ret2);
                    if (ret2.code == SUCCESS)
                        ret.eg[i][j] = jpk_.eg[i][j];
                    else
                        ret.eg[i][j] = 0;
                }
            }
            else
            {
                if (jpk_.eg[i][j] != 0)
                {
                    ret2.code = sp_gem->unlay(ret2);
                    ret.eg[i][j] = jpk_.eg[i][j];
                }
            }
        }
    }
    ret.flag = jpk_.flag;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}
//请求一键合成宝石
void sc_logic_t::on_req_gemstone_syn_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_syn_all_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        return;
    }
    sp_user->item_mgr.gemstone_compose_all(jpk_.type_gem);
    sc_msg_def::ret_gemstone_syn_all_t ret;
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求宝石页信息
void sc_logic_t::on_req_gem_page_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gem_page_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_gem_page_info, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_gem_page_info, no uid:%d", uid));
        return;
    }

    // 旧代码处理 勿删
    //sp_user->equip_mgr.unlay_all();

    // 新代码
    sc_msg_def::ret_gem_page_info_t ret;
    ret.code = sp_user->gem_page_mgr.get_gem_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}
//得到用户
sp_user_t sc_logic_t::getuid(uint64_t seskey_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)

    {
        logerror((LOG, "getuid, no uid with seskey:%lu", seskey_));
        return sp_user_t();
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "getuid, no uid:%d", uid));
        return sp_user_t();
    }

    return user;
}
//技能升级
void sc_logic_t::on_req_skill_upgrade(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upgrade_skill_t &jpk_)
{
    sc_msg_def::ret_upgrade_skill_t ret;
    ret.skid = jpk_.skid;
    ret.pid = jpk_.pid;
    ret.num = jpk_.num;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    sp_skill_t sp_skill = sp_user->skill_mgr.get(jpk_.skid);
    if (sp_skill == NULL)
    {
        ret.code = ERROR_SC_NO_SKILL;
        logerror((LOG, "on_req_skill_upgrade, no skill:%d", jpk_.skid));
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    ret.code = sp_skill->upgrade(jpk_.num);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.pid,jpk_.skid,ret.code);

}
//技能升阶
void sc_logic_t::on_req_skill_upnext(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upnext_skill_t &jpk_)
{
    sc_msg_def::ret_upnext_skill_failed_t failed;
    failed.skid = jpk_.skid;
    failed.pid = jpk_.pid;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sp_skill_t sp_skill = sp_user->skill_mgr.get(jpk_.skid);
    if (sp_skill == NULL)
    {
        failed.code = ERROR_SC_NO_SKILL;
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    sc_msg_def::ret_upnext_skill_t ret;
    ret.pid = jpk_.pid;
    failed.code = sp_skill->upnext(ret);

    if( failed.code )
        msg_sender_t::unicast(seskey_, conn_, failed);
    else
        msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.pid,jpk_.skid,failed.code);

}
//请求查看其他用户信息
void sc_logic_t::on_req_view_user_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_view_user_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sp_view_user_other_t view = view_cache_other.get_view_others(jpk_.uid, true);
    if (view != NULL)
    {
        sc_msg_def::ret_view_user_info_t ret;
        (*view) >> ret.info;
        msg_sender_t::unicast(seskey_, conn_, ret);
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.uid);
}
//好友挑战
void sc_logic_t::on_req_friend_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_battle_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sp_view_user_t view = view_cache.get_view(jpk_.uid, true);
    if (view != NULL)
    {
        sc_msg_def::ret_friend_battle_t ret;
        (*view) >> ret.info;
        msg_sender_t::unicast(seskey_, conn_, ret);
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.uid);
}
//请求走马灯信息
void sc_logic_t::on_req_maquee_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_maquee_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_maquee_info_t ret;

    auto it = repo_mgr.maquee.begin();
    while( it!=repo_mgr.maquee.end() )
    {
        ret.infos.push_back(it->second.tip);
        ++it;
    }

    msg_sender_t::unicast(seskey_, conn_, ret);
}
//巨龙宝库进入战斗
void sc_logic_t::on_req_treasure_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_enter_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    user->treasure.enter_round(jpk_.resid);
}
//巨龙宝库放弃坑位
void sc_logic_t::on_req_treasure_giveup(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_giveup_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_giveup_t ret;
    ret.code = user->treasure.giveup_slot(ret.left_secs);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,ret.left_secs,ret.code);

}

//巨龙宝库重置
void sc_logic_t::on_req_treasure_reset(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_reset_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG,"on_req_treasure_reset,no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_treasure_reset, no uid:%lu", uid));
        return;
    } 

    sc_msg_def::ret_treasure_reset_t ret;
    int t =  user->treasure.is_settle_today(ret.remain_times, ret.n_rob);
    if (t == 0)
        ret.code = 0;
    else if (t == 1)
        ret.code = ERROR_TREASURE_USE_OUT_RESET_TIMES;
    else if (t == 2)
        ret.code = ERROR_TREASURE_NO_RESET_TIMES;
    else
        ret.code = t;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(),0, 0, ret.code);
}

//巨龙宝库收割坑位
void sc_logic_t::on_req_treasure_getreward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_slot_rewd_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }
    
    sp_user_t user;
    if (!usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", jpk_.uid));
        return;
    }

    sc_msg_def::ret_treasure_slot_rewd_t ret;
    ret.code = user->treasure.get_reward(ret.m_or_t);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);

}
//巨龙宝库离开战斗
void sc_logic_t::on_req_treasure_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_exit_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    user->treasure.exit_round(jpk_.resid,jpk_.win, jpk_.salt);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,1,0,jpk_.win);

}
//巨龙宝库一键登塔
void sc_logic_t::on_req_treasure_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_pass_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    int32_t end = user->treasure.pass_round();

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,end);

}
//巨龙宝库占领空位
void sc_logic_t::on_req_treasure_occupy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_occupy_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_occupy_t ret;
    ret.pos = jpk_.pos;
    ret.code = user->treasure.occupy_blank(jpk_.pos);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code,ret.pos);
}
void sc_logic_t::on_req_treasure_help(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_help_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_treasure_help, no uid with seskey:%lu", seskey_));
        return ;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_treasure_help, no uid:%d", uid));
        return ;
    }
    sc_msg_def::ret_treasure_help_t ret;
    ret.pos = jpk_.pos;
    ret.code = user->treasure.help(jpk_.pos);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user, jpk_.cmd(), 0, 0, ret.code, ret.pos);
}
//巨龙宝库抢占坑位
void sc_logic_t::on_req_treasure_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_fight_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_fight_t ret;
    int32_t res=user->treasure.occupy_fight(jpk_.pos,jpk_.uid,ret);

    if( res != 0 )
    {
        sc_msg_def::ret_treasure_fight_failed_t fail;
        fail.code = res;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
    else
        msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pos,jpk_.uid,res);
}
void sc_logic_t::on_req_treasure_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_fight_end_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0) {
        logerror((LOG, "on_req_treasure_fight_end, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user)) {
        logerror((LOG, "on_req_treasure_fight_end, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_fight_end_t ret;
    ret.code = user->treasure.occupy_fight_end(jpk_, ret);

    if(ret.code != SUCCESS) {
        sc_msg_def::ret_treasure_fight_failed_t fail;
        fail.code = ret.code;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
    else msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    //statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.is_win,jpk_.uid,res);
}
//巨龙宝库抢占坑位
void sc_logic_t::on_req_treasure_rob(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rob_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_rob_t ret;
    int32_t res=user->treasure.rob(jpk_.pos,jpk_.uid,ret);
    if( res != 0 )
    {
        sc_msg_def::ret_treasure_rob_failed_t fail;
        fail.code = res;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
    else
        msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pos,jpk_.uid,res);

}
void sc_logic_t::on_req_treasure_rob_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rob_end_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0) {
        logerror((LOG, "on_req_treasure_rob_end, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user)) {
        logerror((LOG, "on_req_treasure_rob_end, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_rob_end_t ret;
    ret.code = user->treasure.rob_end(jpk_, ret);
    if(ret.code != SUCCESS) {
        sc_msg_def::ret_treasure_rob_failed_t fail;
        fail.code = ret.code;
        msg_sender_t::unicast(seskey_, conn_, fail);
    }
    else msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    // statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pos,jpk_.uid,res);
}
//到达零点的秒数
void sc_logic_t::on_req_secs_to_zero(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_secs_to_zero_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_secs_to_zero_t ret;
    ret.secs = date_helper.sec_2_tomorrow(0);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//巨龙宝库请求某一层的信息
void sc_logic_t::on_req_treasure_floor(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_floor_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_treasure_floor_t ret;
    ret.floor = jpk_.floor;
    //ret.code=user->treasure.get_jpk(jpk_.floor,ret.slots,ret.helper);
    ret.code=user->treasure.get_jpk(jpk_.floor,ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//获取巨龙宝库战报
void sc_logic_t::on_req_treasure_records(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rcds_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    user->treasure.unicast_records_info();
}
//获取巨龙宝库复仇记录
void sc_logic_t::on_req_treasure_revenge(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_revenge_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_maquee_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_maquee_info, no uid:%d", uid));
        return;
    }

    user->treasure.unicast_revenge_info();
}
//请求角色属性
void sc_logic_t::on_req_role_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_role_pro_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_role_pro, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_role_pro, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_role_pro_t ret;
    ret.pid = jpk_.pid;

    if( 0 == jpk_.pid )
    {
        //主角属性
        user->pro.cal_pro(0);
        user->pro.copy(ret.pro);
    }
    else
    {
        //伙伴属性
        sp_partner_t partner = user->partner_mgr.get(jpk_.pid);
        if( !partner )
        {
            logerror((LOG, "on_req_role_pro, no pid:%d", jpk_.pid));
            return;
        }
        partner->pro.cal_pro(jpk_.pid);
        partner->pro.copy(ret.pro);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求升级潜能
void sc_logic_t::on_req_up_potential(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_potential_up_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_up_potential, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_up_potential, no uid:%d", uid));
        return;
    }

    int32_t delta,current,res;
    if( 0 == jpk_.pid )
    {
        //主角潜能
        res = user->up_potential(jpk_.flag,delta,current, jpk_.attribute);
    }
    else
    {
        //伙伴潜能
        sp_partner_t partner = user->partner_mgr.get(jpk_.pid);
        if( !partner )
        {
            logerror((LOG, "on_req_up_potential, no pid:%d", jpk_.pid));
            return;
        }
        res = partner->up_potential(jpk_.flag,delta,current, jpk_.attribute);
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pid,delta,res,current);

}

void sc_logic_t::on_req_arena_cool_down(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_cool_down_t& jpk_)
{
    sc_msg_def::ret_arena_cool_down_t ret;
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    ret.code = SUCCESS; 
    sp_user->arena.get_cool_down(ret);
    
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求竞技场信息
void sc_logic_t::on_req_arena_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_info_t& jpk_)
{
    sc_msg_def::ret_arena_info_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    int code = sp_user->arena.unicast_arena_info(jpk_.flag);
    if (code != SUCCESS)
    {
        failed.code = code; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }
}

//请求挑战
void sc_logic_t::on_req_begin_arena_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_arena_fight_t& jpk_)
{
    sc_msg_def::ret_begin_arena_fight_t ret;
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL) {
        ret.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    ret.code = sp_user->arena.fight(ret, jpk_.pos);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.pos,0,ret.code);

    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_end_arena_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_end_arena_fight_t& jpk_)
{
    sc_msg_def::ret_end_arena_fight_t ret;
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        ret.code = ERROR_SC_NO_USER;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    ret.code = sp_user->arena.fight_end(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求购买竞技场次数
void sc_logic_t::on_req_arena_buy_count(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_fight_count_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_arena_buy_count, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_arena_buy_count, no uid:%d", uid));
        return;
    }

    user->arena.buy_fight_count();

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());

}

//请求清除竞技场冷却时间
void sc_logic_t::on_req_arena_clear_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_clear_time_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_arena_clear_time, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_arena_clear_time, no uid:%d", uid));
        return;
    }

    user->arena.clear_time();

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());

}

//请求boss生死状态
void sc_logic_t::on_req_boss_alive(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_alive_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_boss_alive, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_boss_alive, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_boss_alive_t ret;
    ret.flag = jpk_.flag;
    ret.st = -1;
    ret.bosscount = 0;
    if( 1 == jpk_.flag )
    {
        //世界boss
        ret.st = world_boss.is_boss_available();
    }
    else if (2 == jpk_.flag)
    {
        //公会boss
        ret.st = gang_boss_mgr.is_boss_available(user,ret.bosscount);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_open_union_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_open_union_boss_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_open_union_boss, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_open_union_boss, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_open_union_boss_t ret;
    gang_boss_mgr.open_boss(user,ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求进入boss场景
void sc_logic_t::on_req_boss_enter_scene(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_state_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_enter_scene, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_enter_scene, no uid:%d", uid));
        return;
    }

    switch(jpk_.flag)
    {
        case 1:
            {
                //世界boss
                world_boss.get_boss_state(uid,user->db.sceneid,user->db.grade,user->db.nickname());
            }
            break;
        case 2:
            {
                //公会boss
                sp_gang_boss_t sp_boss = gang_boss_mgr.get_boss(user);
                if (sp_boss != NULL)
                {
                    sp_boss->get_boss_state(uid,user->db.sceneid,user->db.grade,user->db.nickname());

                }
            }
            break;
        default:
            {
                sc_msg_def::ret_boss_state_t ret;
                ret.flag= jpk_.flag;
                ret.state = -1;
                msg_sender_t::unicast(seskey_, conn_, ret);
            }
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.flag);

}
//请求boss战斗
void sc_logic_t::on_req_boss_enter_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_start_batt_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_boss_enter_battle, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_boss_enter_battle, no uid:%d", uid));
        return;
    }

    switch(jpk_.flag)
    {
        case 1:
            //世界boss
            world_boss.enter_battle(user,uid,jpk_.charge);
            break;
        case 2:
            {
                //公会boss
                sp_gang_boss_t sp_boss = gang_boss_mgr.get_boss(user);
                if (sp_boss != NULL)
                {
                    sp_boss->enter_battle(user,uid,jpk_.charge);
                }
            }
            break;
        default:
            {
                sc_msg_def::ret_boss_state_t ret;
                ret.flag= jpk_.flag;
                ret.state = -1;
                msg_sender_t::unicast(seskey_, conn_, ret);
            }
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,jpk_.charge,0,jpk_.flag);
}

void sc_logic_t::on_req_boss_exit_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_end_batt_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_boss_exit_battle, no uid with seskey:%lu", seskey_));
        return ;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_boss_exit_battle, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_boss_end_batt_t ret;
    switch(jpk_.flag)
    {
        case 1: // world boss
            ret.code = world_boss.exit_battle(user, jpk_, ret);
            break;
        case 2: // union boss
            {
                //公会boss
                sp_gang_boss_t sp_boss = gang_boss_mgr.get_boss(user);
                if (sp_boss != NULL)
                {
                    ret.code = sp_boss->exit_battle(user,jpk_, ret);
                }
            }
            break;
        default:
            ret.code = FAILED;
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求伤害排名
void sc_logic_t::on_req_boss_dmg_ranking(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_dmg_ranking_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    switch(jpk_.flag)
    {
        case 1:
            //世界boss
            world_boss.req_damage_rank(uid);
            break;
        case 2:
            {
                //公会boss
                sp_gang_boss_t sp_boss = gang_boss_mgr.get_boss(user);
                if (sp_boss != NULL)
                {
                    sp_boss->req_damage_rank(uid);
                }
            }
            break;
        default:
            {
                sc_msg_def::ret_boss_state_t ret;
                ret.flag= jpk_.flag;
                ret.state = -1;
                msg_sender_t::unicast(seskey_, conn_, ret);
            }
    }
}
//请求离开boss场景
void sc_logic_t::on_req_boss_leave_scene(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_leave_scene &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }


    switch(jpk_.flag)
    {
        case 1:
            //世界boss
            world_boss.do_user_leave(uid);
            break;
        case 2:
            {
                //公会boss
                sp_gang_boss_t sp_boss = gang_boss_mgr.get_boss(user);
                if (sp_boss != NULL)
                {
                    sp_boss->do_user_leave(uid);
                }
            }
            break;
        default:
            {
                sc_msg_def::ret_boss_state_t ret;
                ret.flag= jpk_.flag;
                ret.state = -1;
                msg_sender_t::unicast(seskey_, conn_, ret);
            }
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.flag);

}
void sc_logic_t::on_req_arena_rank_page(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_rank_page_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_arena_rank_page, no uid with seskey:%lu", seskey_));
        return;
    }

    arena_page_cache.unicast_arena_page(uid);

}

//请求竞技场奖励
void sc_logic_t::on_req_arena_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_reward_countdown_t& jpk_)
{
    sc_msg_def::ret_arena_reward_countdown_t ret;
    ret.countdown = arena_cache.reward_countdown();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求打开礼包
void sc_logic_t::on_req_open_pack(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_open_pack_t& jpk_)
{
    sc_msg_def::ret_open_pack_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    int code = sp_user->item_mgr.use_item(jpk_.resid, 1, "");
    if (code != SUCCESS)
    {
        failed.code = code; 
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid);

}
//请求领取礼包
void sc_logic_t::on_req_use_pack(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_use_pack_t& jpk_)
{
    /*
       sc_msg_def::ret_use_pack_t ret;

       sp_user_t sp_user = getuid(seskey_);
       if (sp_user == NULL)
       {
       ret.code = ERROR_SC_NO_USER; 
       msg_sender_t::unicast(seskey_, conn_, ret);
       return;
       }

       ret.code = sp_user->item_mgr.given_pack_item();
       msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
    */
}
//请求聊天
void sc_logic_t::on_req_chart(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_chart_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    if (user->notalk)
        return;

    if(user->report_mgr.get_info() == 1)
        return;

    switch( jpk_.type )
    {
        case 1:
            {
                if(jpk_.id == 1)//反馈
                {
                    sc_msg_def::nt_feedback_t nt;
                    sql_result_t res;
                    if (0 == db_FeedbackFlag_t::sync_select(uid,res)){
                            nt.code = SUCCESS; 
                    }else{
                        db_FeedbackFlag_t db;
                        db.uid = uid;
                        db_service.async_do((uint64_t)uid , [](db_FeedbackFlag_t& db_){
                                db_.insert();
                                },db);

                        sc_msg_def::nt_bag_change_t nt_bag;
                        sc_msg_def::jpk_item_t item;
                        item.itid = 0;
                        item.resid = 10003;
                        item.num = 300;
                        nt_bag.items.push_back(std::move(item));

                        string msg;
                        msg = mailinfo.new_mail(mail_feedback);
                        auto rp_gmail = mailinfo.get_repo(mail_feedback);//阶段奖励
                        if (rp_gmail != NULL)
                            user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt_bag.items);
                        nt.code = SUCCESS;
                    }
                    chat_ins.addNew(1,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),1,jpk_.msg, user->db.hostnum);
                    logic.unicast(uid, nt);
                }
                else
                {
                    //世界聊天
                    notify_ctl.push_to_all(uid,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),1,jpk_.msg);

                    chat_ins.addNew(uid,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),1,jpk_.msg, user->db.hostnum);
                }
            }
            break;
        case 2:
            {
                //公会聊天
                notify_ctl.push_to_gang(uid,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),2,jpk_.id,jpk_.msg);
            }
            break;
        case 3:
            {
                //私人聊天
                //notify_ctl.push_to_uid(uid,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),3,jpk_.id,jpk_.msg);
                //chat_ins.addToUid(uid,jpk_.id,user->db.resid,user->db.quality,user->db.grade,user->db.viplevel,user->db.nickname(),3,jpk_.msg, user->db.hostnum);
                notify_cache.addToUid(user,jpk_.id,3,jpk_.msg);
            }
    }

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,0,0,jpk_.type,jpk_.msg);

}
//玩家上线获取离线期间产生的信封
void sc_logic_t::on_req_mail_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mail_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    notify_cache.unicast_cache_msg(uid);
}
//寻找好友
void sc_logic_t::on_req_friend_search(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_search_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->friend_mgr.search_friend(jpk_.name);
}
//寻找好友
void sc_logic_t::on_req_friend_search_by_uid(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_search_uid_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->friend_mgr.search_friend_by_uid(jpk_.uid);
}
//添加好友
void sc_logic_t::on_req_friend_add(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_add_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->friend_mgr.add_friend(jpk_.uid, jpk_.fp);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.uid);
}
//被加好友
void sc_logic_t::on_req_friend_beenadd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_add_res_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->friend_mgr.add_req_return(jpk_.uid,jpk_.reject);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.uid,0,0,jpk_.reject);

}
//删除好友
void sc_logic_t::on_req_friend_del(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_del_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }
    user->friend_mgr.del_friend(jpk_.uid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.uid);

}
//更换助战英雄
void sc_logic_t::on_req_change_helphero(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_helpbattle_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->on_change_help_hero(jpk_.pid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pid);

}
//请求好友列表
void sc_logic_t::on_req_friend_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_list_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->friend_mgr.get_friends(jpk_.page);
}
//请求鲜花列表
void sc_logic_t::on_req_flower_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_flower_list_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_flower_list, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_flower_list, no uid:%d", uid));
        return;
    }

    user->friend_flower_mgr.get_flowers();
}
//请求接受鲜花
void sc_logic_t::on_req_receive_flower(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_receive_flower_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_receive_flower, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_receive_flower, no uid:%d", uid));
        return;
    }

    user->friend_flower_mgr.receive_flower(jpk_.id);
}
//请求接受所有鲜花
void sc_logic_t::on_req_receive_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_receive_all_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_receive_all, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_receive_all, no uid:%d", uid));
        return;
    }

    if(jpk_.uid == 1)
        user->friend_flower_mgr.receive_userguide();
    else
        user->friend_flower_mgr.receive_all();
}
//请求陌生人列表
void sc_logic_t::on_req_stranger_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_helphero_stranger_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_helphero_stranger_t ret;
    grade_user_cache.get_strangers(user,uid,user->db.grade,jpk_.count,ret.strs);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求好友申请列表
void sc_logic_t::on_req_friend_req_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_addlist_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_friend_addlist_t ret;
    frd_request_cache.get_frd_req_info(uid,ret.list);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//送花
void sc_logic_t::on_req_send_flower(uint64_t seskey_, sp_rpc_conn_t, sc_msg_def::req_send_flower_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_send_flower, no uid with seskey_:%u", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_send_flower_t ret;
    //默认为24小时
    ret.code = user->friend_flower_mgr.addNew(jpk_.uid, jpk_.name, 86400);
    logic.unicast(user->db.uid, ret);
}
//请求训练场信息
void sc_logic_t::on_req_practice_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_practice_info_t ret;
    practice_cache.get_info(user,ret.infos);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求清除cd
void sc_logic_t::on_req_practice_clear(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_clear_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->practice.clear_cd(jpk_.pos);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pos);

}
//请求训练伙伴
void sc_logic_t::on_req_practice_prac(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_partner_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_trial_flush_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_trial_flush_task, no uid:%d", uid));
        return;
    }

    user->practice.practice_partner(jpk_.pos,jpk_.pid,jpk_.type);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.pid,jpk_.pos,0,jpk_.type);

}
//请求任务列表
void sc_logic_t::on_req_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_task_list_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_task_list, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user->task.unicast_task_list();
}
//请求接取任务
void sc_logic_t::on_req_get_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_task_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_get_task, no uid with seskey:%lu", seskey_));
        return;
    }

    logwarn((LOG, "on_req_get_task, uid:%lu, target:%d", sp_user->db.uid, jpk_.resid));

    sc_msg_def::ret_get_task_t ret;
    ret.resid = jpk_.resid;
    ret.code = sp_user->task.request(jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,0,ret.code);

}
//请求提交任务
void sc_logic_t::on_req_commit_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_task_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_commit_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_commit_task_t ret;
    ret.resid = jpk_.resid;
    ret.next_id = jpk_.next_id;
    ret.code = sp_user->task.commit(jpk_.resid, jpk_.next_id);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,0,ret.code);

}
//请求放弃任务
void sc_logic_t::on_req_abort_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_abort_task_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_abort_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_abort_task_t ret;
    ret.resid = jpk_.resid;
    ret.code = sp_user->task.abort(jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,0,ret.code);

}
//请求完成的支线任务列表
void sc_logic_t::on_req_finished_bline(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_finished_bline_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_abort_task, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user->task.unicast_finished_bline();
}
/*
void sc_logic_t::on_req_daily_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_daily_task_list_t & jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_daily_task_list, no uid with seskey:%lu", seskey_));
        return;
    }
    //sp_user->daily_task.unicast_dtask_list();
}
*/
/*
void sc_logic_t::on_commit_daily_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_daily_task_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_commit_daily_task, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_commit_daily_task_t ret;
    //ret.pos = jpk_.pos;
    //ret.code = sp_user->daily_task.commit(jpk_.pos);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.pos,0,ret.code);

}
*/
/*
void sc_logic_t::on_req_buy_daily_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_daily_task_num_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_buy_daily_task, no uid with seskey:%lu", seskey_));
        return;
    }

    //sc_msg_def::ret_buy_daily_task_num_t ret;
    //ret.code = sp_user->daily_task.buy_num();
    //msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());

}
*/

//请求创建公会
void sc_logic_t::on_req_create_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_create_gang_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_create_gang, no uid with seskey:%lu", seskey_));
        return;
    }

    int code = gang_mgr.create_gang(sp_user, jpk_.name);
    sc_msg_def::ret_create_gang_t ret;
    ret.ggid = gang_mgr.get_ggid_by_uid(sp_user->db.uid);
    ret.code = code;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,ret.code,ret.ggid,jpk_.name);

}

//请求公会公会信息
void sc_logic_t::on_req_gang_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_info_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_info, no uid with seskey:%lu", seskey_));
        return;
    }

    int code = gang_mgr.unicast_ganginfo(sp_user->db.uid, jpk_.ggid);
    if (code != SUCCESS)
    {
        sc_msg_def::ret_gang_info_failed_t ret;
        ret.code = code;
        msg_sender_t::unicast(seskey_, conn_, ret);
    }
}
void sc_logic_t::on_req_gang_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_list_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_list, no uid with seskey:%lu", seskey_));
        return;
    }

    gang_mgr.unicast_ganglist(sp_user->db.uid, jpk_.page);
}
void sc_logic_t::on_req_search_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_search_gang_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_search_gang, no uid with seskey:%lu", seskey_));
        return;
    }

    gang_mgr.search_gang(sp_user->db.uid, jpk_.name);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,0,0,jpk_.name);

}
//设置公会公告
void sc_logic_t::on_req_set_notice(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_notice_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_set_notice, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_set_notice_t ret;
    ret.code = gang_mgr.set_notice(sp_user->db.uid, jpk_.notice); 
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,0,0,jpk_.notice);

}
//设置公会留言
void sc_logic_t::on_nt_gang_msg(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_gang_msg_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_nt_gang_msg, no uid with seskey:%lu", seskey_));
        return;
    }

    gang_mgr.add_msg(sp_user->db.uid, jpk_.type, jpk_.msg);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,0,0,jpk_.msg);

}
//设置公告官员
void sc_logic_t::on_req_set_adm(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_adm_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_set_adm, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_set_adm_t ret;
    ret.uid = jpk_.uid;
    ret.isadm = jpk_.isadm;
    ret.code = gang_mgr.set_adm(sp_user->db.uid,jpk_.uid, jpk_.isadm);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.uid,0,0,jpk_.isadm);

}
//设置公会捐献
void sc_logic_t::on_req_gang_pay(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_pay_t& jpk_) 
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_pay, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_gang_pay_t ret;
    ret.code = gang_mgr.pay(sp_user, jpk_.money, jpk_.rmb, ret.dpm); 
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.money,jpk_.rmb);

}
//解散公会
void sc_logic_t::on_req_close_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_close_gang_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_close_gang, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_close_gang_t ret;
    ret.code = gang_mgr.close_gang(sp_user);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,ret.code);

}
void sc_logic_t::on_req_learn_gskl(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_learn_gskl_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_learn_gskl, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_learn_gskl_t ret;
    ret.code = gang_mgr.learn_gskl(sp_user, jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,0,ret.code);

}
void sc_logic_t::on_req_gskl_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gskl_list_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gskl_list, no uid with seskey:%lu", seskey_));
        return;
    }
    gang_mgr.unicast_gskl_list(sp_user);
}
//请求加入公会
void sc_logic_t::on_req_add_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_add_gang_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_add_gang, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_add_gang_t ret;
    ret.code = gang_mgr.add_req(sp_user, jpk_.ggid);
    ret.ggid = jpk_.ggid;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.ggid,0,ret.code);

}
//请求公会申请列表
void sc_logic_t::on_req_gang_reqlist(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_reqlist_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_reqlist, no uid with seskey:%lu", seskey_));
        return;
    }
    gang_mgr.unicast_reqlist(sp_user);
}

//请求公会排行榜信息
void sc_logic_t::on_req_union_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_union_rank_t& jpk_)
{
     int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_union_rank, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_union_rank, no uid:%d", uid));
        return;
    }
    union_rank.unicast_union_rank(uid);
}

//请求卡牌排行榜信息
void sc_logic_t::on_req_card_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_card_rank_t& jpk_)
{
     int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_card_rank, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_card_rank, no uid:%d", uid));
        return;
    }
    card_rank.unicast_card_rank(uid);
}

//请求公会成员列表
void sc_logic_t::on_req_gang_mem(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_mem_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_mem, no uid with seskey:%lu", seskey_));
        return;
    }
    gang_mgr.unicast_mem(sp_user, jpk_.page);
}
//处理公会申请
void sc_logic_t::on_req_deal_gang_req(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_deal_gang_req_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_deal_gang_req, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_deal_gang_req_t ret;
    ret.flag = jpk_.flag;
    ret.code = gang_mgr.deal_gang_req(sp_user, jpk_.uid, jpk_.flag);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.uid,0,ret.code,jpk_.flag);

}
//请求踢人
void sc_logic_t::on_req_kick_mem(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_kick_mem_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_kick_mem, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_kick_mem_t ret;
    ret.code = gang_mgr.kick_mem(sp_user, jpk_.uid);
    ret.uid = jpk_.uid;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.uid,0,ret.code);

}
//请求离开公会
void sc_logic_t::on_req_leave_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_leave_gang_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_leave_gang, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_leave_gang_t ret;
    ret.code = gang_mgr.leave_gang(sp_user);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());

}
void sc_logic_t::on_req_gang_pray(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_pray_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_gang_pray, no uid with seskey:%lu", seskey_));
        return;
    }
    gang_mgr.pray(sp_user);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());

}
void sc_logic_t::on_req_enter_pray(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_pray_t &jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_enter_pray, no uid with seskey:%lu", seskey_));
        return;
    }
    gang_mgr.enter_pray(sp_user);
}
void sc_logic_t::on_req_change_charman(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_charman_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_change_charman, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_change_charman_t ret;
    ret.code = gang_mgr.change_charman(sp_user, jpk_.uid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.uid,0,ret.code);

}
void sc_logic_t::on_req_set_gboss_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_gang_boss_time_t&jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_set_gboss_time, no uid with seskey:%lu", seskey_));
        return;
    }
    sc_msg_def::ret_set_gang_boss_time_t ret;
    ret.code = gang_mgr.set_boss_time(sp_user, jpk_.day);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),0,0,ret.code,jpk_.day);

}
/*
//吞噬符文
void sc_logic_t::on_req_rune_switch(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_switchpos_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

//    user->rune_mgr.switch_pos(jpk_.src_pos,jpk_.dst_pos,jpk_.pid);
}
//打开符文系统
void sc_logic_t::on_req_rmonster_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rmonster_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rmonster_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_rune_info_t ret;
    rune_cache.get_rmonsters(user->db.uid,user->db.grade,ret.mons);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//一键吞噬
void sc_logic_t::on_req_rune_eatall(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_eatall_t &jpk_)
{
    sc_msg_def::ret_rune_eatall_t ret;

    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

//    ret.code = user->rune_mgr.eat_all();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//猎魔
void sc_logic_t::on_req_rune_huntone(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_huntsome_t &jpk_)
{
    sc_msg_def::ret_rune_huntsome_t ret;

    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }
    int32_t res = user->rune_mgr.hunt_some(jpk_.flag,jpk_.lines,ret.monsters);
    if(res==ERROR_SC_EXCEPTION||res==ERROR_SC_ILLEGLE_REQ)
    {
        sc_msg_def::ret_rune_huntsome_fail_t fail;
        fail.code = res;
        msg_sender_t::unicast(seskey_, conn_, fail);
        return;
    }
    ret.flag = res;
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//召唤魔王
void sc_logic_t::on_req_rune_callboss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_callboss_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

}
//购买符文
void sc_logic_t::on_req_rune_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_buy_t &jpk_)
{
    sc_msg_def::ret_rune_buy_t ret;
    ret.resid = jpk_.resid;

    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

//    ret.code = user->rune_mgr.buy_rune(jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//关闭符文界面
void sc_logic_t::on_nt_rune_close(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_close_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

//    user->rune_mgr.save_db();

    sc_msg_def::ret_rune_close_t ret;
    ret.code = SUCCESS;
    msg_sender_t::unicast(seskey_, conn_, ret);
}
*/
//领取奖励，首次充值，累计充值，连续登录，累计登录
void sc_logic_t::on_req_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_reward_t retreward;
    retreward.flag = jpk_.flag;
    retreward.code = user->reward.get_reward(jpk_.flag,retreward.dismess);
    logic.unicast(user->db.uid, retreward);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,retreward.code,jpk_.flag);

}
//获取等级礼包
void sc_logic_t::on_req_lv_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lv_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

    user->reward.get_lv_reward(jpk_.lv);
}
//获取cdkey奖励
void sc_logic_t::on_req_cdkey_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cdkey_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

    user->reward.get_cdkey_reward(jpk_.cdkey);
}

//获取邀请码
void sc_logic_t::on_req_invcode(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_invcode, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_invcode, no uid:%d", uid));
        return;
    }
    user->reward.get_invcode();
}
//设置邀请人
void sc_logic_t::on_req_invcode_set(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_set_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_invcode_set, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_invcode_set, no uid:%d", uid));
        return;
    }
    user->reward.set_inviter(jpk_.invcode);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,0,jpk_.invcode);

}
//领取好友邀请奖励
void sc_logic_t::on_req_invcode_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_invcode_set, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_invcode_set, no uid:%d", uid));
        return;
    }
    user->reward.get_invcode_reward(jpk_.flag);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.flag);

}
void sc_logic_t::on_up_team_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::up_team_pro_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rune_switch, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rune_switch, no uid:%d", uid));
        return;
    }

    user->on_team_pro_changed();
}
void sc_logic_t::on_req_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_shop_items, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_shop_items, no uid:%d", uid));
        return;
    }

    user->shop.unicast_shop_items(jpk_.tab, jpk_.page, jpk_.sheet);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.tab,jpk_.page);
}
void sc_logic_t::on_req_npcshop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npcshop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_npcshop_items, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_npcshop_items, no uid:%d", uid));
        return;
    }
    user->shop.update();
    user->shop.unicast_npc_shop_items(jpk_.typenum);

    //记录事件
   // statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
void sc_logic_t::on_req_npc_shop_update(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npc_shop_update_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_npc_req_shop_update, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_npc_req_shop_update, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_npc_shop_update_t ret;
    ret.code = user->shop.npc_shop_update(jpk_.typenum);
    ret.typenum = jpk_.typenum;
    msg_sender_t::unicast(seskey_, conn_, ret);
    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),ret.code,jpk_.typenum);
}

void sc_logic_t::on_npc_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npc_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_npc_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_npc_shop_buy, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_npc_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->shop.npc_buy(jpk_.id, ret.dbid, jpk_.placeNum, jpk_.typenum);
    ret.placeNum = jpk_.placeNum;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,ret.code);

}
void sc_logic_t::on_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_shop_buy, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->shop.buy(jpk_.id, jpk_.num, ret.dbid);
    ret.num = jpk_.num;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);

}
void sc_logic_t::on_req_buy_coin(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_coin_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_coin, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_coin, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_buy_coin_t ret;
    user->shop.buy_coin(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);

}
void sc_logic_t::on_sell(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sell_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_sell, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_sell, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_sell_t ret;
    ret.code = user->shop.sell(jpk_.eid, jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,1,ret.code,jpk_.eid);

}
/*
//请求排名奖励
void sc_logic_t::on_req_rank_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rank_reward_t&jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_rank_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_rank_reward, no uid:%d", uid));
        return;
    }

    //    sc_msg_def::ret_rank_reward_t ret;
    user->reward.unicast_rank_reward();
    //    msg_sender_t::unicast(seskey_, conn_, ret);
}
*/
/*
//请求领取排名奖励
void sc_logic_t::on_req_given_rank_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_rank_reward_t&jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_given_rank_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_given_rank_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_given_rank_reward_t ret;
    ret.code = user->reward.given_rank_reward();
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);

}
*/
//请求领取体力奖励
void sc_logic_t::on_req_given_power_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_power_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_given_rank_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_given_power_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_given_power_reward_t ret;
    ret.code = user->reward.given_power();
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);

}
void sc_logic_t::on_req_power_reward_cd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reward_power_cd_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_given_rank_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_given_power_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_reward_power_cd_t ret;
    ret.cd = user->reward.reward_power_cd();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_given_vip_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_vip_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_given_vip_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_given_vip_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_given_vip_reward_t ret;
    ret.code = user->reward.given_vip_reward(jpk_.viplevel);
    ret.viplevel = jpk_.viplevel;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.viplevel,1,ret.code);
}
//请求vip购买信息
void sc_logic_t::on_req_buy_vip_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_vip_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_vip_info, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_vip_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_buy_vip_info_t ret;
    if( jpk_.flag == 6 )
    {
        //扩展背包
        ret.yb = user->vip.need_yb(jpk_.flag, user->db.bagn+1 );
        ret.count = 20 - user->db.bagn;
    }
    else if( jpk_.flag == 26 )
    {
        //英雄迷窟重置
        int32_t cur = round_cache.get_cave_flush_count(uid,jpk_.resid);
        ret.yb = user->vip.need_yb(jpk_.flag,cur+1);
        ret.count = user->vip.get_num(jpk_.flag) - cur;
    }
    else if (jpk_.flag == 31) { /* 竞技场冷却时间清除 cgmars #5394, 钻石数量固定，也没提和VIP相关 */
        ret.yb = user->arena.need_yb();
        ret.count = -1; // 这个字段没用
    }
    else
    {
        ret.yb = user->vip.need_yb(jpk_.flag, 0);
        ret.count = user->vip.get_num_count(jpk_.flag);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),ret.yb,ret.count,0,jpk_.flag);

}
//请求购买体力
void sc_logic_t::on_req_buy_power(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_power_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_power, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_power, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_buy_power_t ret;
    ret.code = user->shop.buy_power();
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);
}
//请求购买活力
void sc_logic_t::on_req_buy_energy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_energy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_energy, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_energy, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_buy_energy_t ret;
    ret.code = user->shop.buy_energy();
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);
}
//请求在线奖励cd
void sc_logic_t::on_req_online_reward_cd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_cd_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_online_reward_cd, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_online_reward_cd, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_online_reward_cd_t ret;
    ret.cd = user->reward.get_online_reward_cd();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求在线奖励
void sc_logic_t::on_req_online_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_online_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_online_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_online_reward_t ret;
    ret.code = user->reward.get_online_reward(ret.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),ret.resid,1,ret.code);

}
//请求在线奖励id
void sc_logic_t::on_req_online_reward_num(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_num_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_online_reward, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_online_reward, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_online_reward_num_t ret;
    ret.code = user->reward.get_online_reward_num(ret.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),ret.resid,1,ret.code);

}
void sc_logic_t::on_req_quit_game(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_quit_game_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_quit_game, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_quit_game, no uid:%d", uid));
        return;
    }

    inner_msg_def::nt_session_broken_t jpk;
    jpk.seskey = seskey_;
    on_session_broken(seskey_,conn_,jpk);

    sc_msg_def::ret_quit_game_t ret;
    ret.code = SUCCESS;
    msg_sender_t::unicast(seskey_, conn_, ret);


    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,ret.code);

}
void sc_logic_t::on_req_login_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_login_yb_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_login_yb, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_login_yb, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_login_yb_t ret;
    ret.code = user->reward.given_login_yb(ret.items);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_role_deleted(int32_t uid_)
{
    gang_mgr.on_role_deleted(uid_);
}
void sc_logic_t::handle_time(int sec_)
{
    int32_t cur_sec = date_helper.cur_sec();
    int32_t cur_0_stmp = date_helper.cur_0_stmp();

    arena_cache.update_reward_time(sec_);
    cityboss.update();
    activity.update();
    //arena_rank.update_rank_info();
    lv_rank.update_lv();
    union_rank.update();
    card_rank.update();
    fp_rank.update_fp();
    arena_rank.send_reward();
    lv_rank.send_reward();
    shop_ins.update();
    reward_mcard.update_reward();
    gang_boss_mgr.update_reward();
    sc_limit_round_mgr.update();
    card_event_s.update();
    card_event_rank.update();
    guild_battle_s.update();
    scuffle_mgr.update();
    pub_rank.send_reward();
    //更新跑马灯时间
    update_maqee();
    
    //每当0点时检测
    if( cur_sec == cur_0_stmp)
    {
        gang_mgr.refresh_chairman();
    }

    // 每天凌晨3点执行
    if( cur_sec == cur_0_stmp + 3600*3)
    {
        usermgr().foreach([](sp_user_t user)
            {
                sc_msg_def::nt_bag_change_t nt;
                user->item_mgr.consume_all(16004, nt);
                user->item_mgr.on_bag_change(nt);
            });
        sc_soul_t::clear_scroll();
    }
}

void sc_logic_t::handle_invcode_msg(uint16_t cmd_, const string& msg_)
{
    switch( cmd_ )
    {
        case 10001:
            {
                //请求邀请码
                invcode_msg::ret_code_t ret;
                ret << msg_;

                sp_user_t user;
                if (!usermgr().get(ret.uid, user))
                {
                    logerror((LOG, "handle_invcode_msg 10001: no uid:%d", ret.uid));
                    return;
                }
                user->reward.handle_get_invcode(ret);
            }
            break;
        case 10003:
            {
                //请求邀请码对应的uid
                invcode_msg::ret_uid_t ret;
                ret << msg_;

                sp_user_t user;
                if (!usermgr().get(ret.suid, user))
                {
                    logerror((LOG, "handle_invcode_msg 10003: no uid:%d", ret.suid));
                    return;
                }
                user->reward.handle_set_inviter(ret.code,ret.duid);
            }
            break;

        default:
            break;
    }
}
void sc_logic_t::on_req_test_arena(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_test_arena_t& req_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_test_arena, no uid with seskey:%lu", seskey_));
        return;
    }

    unit_test.test_arena(uid, req_);
}
void sc_logic_t::on_req_test_pay(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_pay_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_test_pay, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_test_pay, no uid:%d", uid));
        return;
    }

    test_msg_def::ret_pay_t ret;
    repo_def::pay_t* rp_pay = repo_mgr.pay.get(jpk_.id);
    if (rp_pay == NULL)
    {
        logerror((LOG, "on_req_test_pay, no repo id:%d", jpk_.id));
        ret.code = -1;
    }
    else
    {
        user->on_payed(rp_pay->rmb);

        if (rp_pay->id == 10109)
        {
            user->reward.db.set_mcardtm(0);
            user->reward.db.set_mcardbuytm(date_helper.cur_sec());
            user->reward.db.set_mcardn(user->reward.db.mcardn+30);
            user->reward.save_db();
            user->reward.nt_mcard_info();
        }

        user->on_payyb_change(rp_pay->cristal);
        //user->vip.on_exp_change(rp_pay->cristal);
        user->reward.cast_yb(rp_pay->rmb);

        string mail;
        if (rp_pay->id == 10109)
            mail=mailinfo.new_mail(mail_mcard_nt, user->db.viplevel); 
        else
            mail=mailinfo.new_mail(mail_pay_ok, rp_pay->cristal); 
        if (!mail.empty())
            notify_ctl.push_mail(user->db.uid, mail);

        ret.code = SUCCESS;
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//走马灯广播
void sc_logic_t::maquee_broadcast()
{
    sc_msg_def::ret_maquee_info_t ret;

    auto it = repo_mgr.maquee.begin();
    while( it!=repo_mgr.maquee.end() )
    {
        ret.infos.push_back(it->second.tip);
        ++it;
    }

    string message;
    ret >> message;

    usermgr().broadcast( sc_msg_def::ret_maquee_info_t::cmd(),message );
}
void sc_logic_t::broadcast_message(uint16_t cmd_, const string& msg_)
{
    usermgr().broadcast(cmd_, msg_);
}
void sc_logic_t::on_req_test_fight(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_fight_test_t& jpk_)
{
    test_msg_def::ret_fight_test_t ret;

    ret.code = 0;
    ret.win_num = 0;
    ret.lose_num = 0;
    ret.left_dmg = 0;
    ret.right_dmg = 0;

    //获取施法者数据
    sp_view_user_t sp_cast_data = view_cache.get_view(jpk_.cast_uid, true);
    if (sp_cast_data == NULL)
    {
        ret.code = ERROR_SC_EXCEPTION;
    }
    sp_view_user_t sp_target_data = view_cache.get_view(jpk_.target_uid, true);
    if (sp_target_data == NULL)
    {
        ret.code = ERROR_SC_EXCEPTION;
    }
    if (ret.code != 0)
    {
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    for(int i=0; i<jpk_.fight_num; i++)
    {
        //产生随机种子
        uint32_t rseed = random_t::rand_integer(10000, 100000);
        //开始pvp
        sc_battlefield_t field(rseed, sp_cast_data, sp_target_data);

        if (i<jpk_.fight_num-1)
            battle_record.open_record = false;
        else
            battle_record.open_record = true;

        int n = field.run();
        logwarn(("FIGHT_TEST", "battle total frames:%d", n));
        //保存胜负
        if (field.is_win())
            ret.win_num++;
        else
            ret.lose_num++;

        ret.left_dmg += field.left_dmg();
        ret.right_dmg += field.right_dmg();

        ret.logname = battle_record.logname;
    }

    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_overdue(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_overdue_t& jpk_)
{
    sp_user_t user;
    if (!cache.get(jpk_.uid, user)) //在cache中不存在
    {
        if (!usermgr().get(jpk_.uid, user))
        {
            logerror((LOG, "on_req_overdue, no uid:%d", jpk_.uid));
            return;
        }
    }

    user->is_overdue = true;
}
void sc_logic_t::on_req_test_round_drop(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_round_drop_t& jpk_)
{
    test_msg_def::ret_round_drop_t ret;
    map<uint32_t,uint32_t>& out = ret.drops;
    for (int i=0; i<jpk_.fight_num; i++)
    {
        vector<sc_msg_def::jpk_item_t> drop_items;
        sc_round_t::gen_drop_items(jpk_.resid, -1, drop_items);
        for(size_t n=0; n<drop_items.size(); n++)
        {
            auto it = out.find(drop_items[n].resid);
            if (it == out.end())
                out[drop_items[n].resid] = 0;
            out[drop_items[n].resid] += drop_items[n].num;
        }
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求购买yb
void sc_logic_t::on_req_buy_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_yb_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_yb, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_yb, no uid:%d", uid));
        return;
    }

    int32_t serid = pay_ins.req_pay(user, jpk_.id, jpk_.uin, jpk_.domain, jpk_.appid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,1,0,serid);

}

//请求支付表
void sc_logic_t::on_req_pay_repo(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pay_repo_t& jpk_)
{
    sc_msg_def::ret_pay_repo_t ret;
    ret.repo = repo_mgr.pay.str_json;
    if(jpk_.domain == "appstore_" || jpk_.domain == "jituo1" || jpk_.domain == "jituo2" || jpk_.domain == "xuegao1" || jpk_.domain == "xuegao2" || jpk_.domain == "soga" || jpk_.domain == "zhanji")
        ret.repo = repo_mgr.apppay.str_json;
    msg_sender_t::unicast(seskey_, conn_, ret);

}

//支付成功通知
void sc_logic_t::on_payed(uint32_t uid_, uint32_t serid_)
{
    sp_user_t user;
    if (!usermgr().get(uid_, user))
    {
        logwarn((LOG, "on_payed, uid:%d offline", uid_));
        return;
    }
    pay_ins.on_payed(user, serid_);

    //记录事件
    statics_ins.unicast_eventlog(*user,4990,0,0,1,serid_);

}
void sc_logic_t::on_req_buy_bag_cap(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_bag_cap_t& jpk_){
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_buy_bag_cap, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_buy_bag_cap, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_buy_bag_cap_t ret;
    ret.code = user->shop.buy_bag_cap();
    ret.cap = user->bag.get_size();
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,ret.cap,ret.code);

}
////新关卡协议////////////////////
//开始普通关卡
void sc_logic_t::on_req_round_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_enter_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.enter_round(jpk_.resid,jpk_.uid,jpk_.pid);
}
//结束普通关卡
void sc_logic_t::on_req_round_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_exit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.exit_round(jpk_);

    //记录事件
    //statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,jpk_.stars,0,jpk_.win);

}
//开始精英关卡
void sc_logic_t::on_req_elite_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_elite_enter_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.enter_elite(jpk_.resid);
}
//结束普通关卡
void sc_logic_t::on_req_elite_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_elite_exit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.exit_elite(jpk_);

    //记录事件
    //statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,jpk_.stars,0,jpk_.win);
}
void sc_logic_t::on_req_reset_elite(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reset_elite_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.reset_elite(jpk_);
}
//开始黄道十二宫
void sc_logic_t::on_req_zodiac_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_enter_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.enter_zodiac(jpk_.resid,jpk_.uid,jpk_.pid);
}
//结束黄道十二宫
void sc_logic_t::on_req_zodiac_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_exit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.exit_zodiac(jpk_);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,jpk_.stars,0,jpk_.win);

}
//自动黄道十二宫
void sc_logic_t::on_req_zodiac_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_pass_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    //user->new_round.pass_zodiac(jpk_.gid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.gid);

}
//刷新关卡
void sc_logic_t::on_req_round_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_flush_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.flush_round(jpk_.gid);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0,0,0,jpk_.gid);

}
//普通关卡挂机
void sc_logic_t::on_req_round_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.pass_round(jpk_);
}
//普通关卡挂机
void sc_logic_t::on_req_round_pass_new(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_new_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }
    user->new_round.pass_round_new(jpk_);
}
//清除普通关卡挂机cd
void sc_logic_t::on_req_clear_round_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_clear_cd_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.clear_pass_round_cd();
}
//清除英雄迷窟挂机cd
void sc_logic_t::on_req_clear_cave_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_pass_clear_cd_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.clear_pass_cave_cd();
}
//开始英雄迷窟
void sc_logic_t::on_req_cave_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_enter_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.enter_cave(jpk_.resid,jpk_.uid,jpk_.pid);
}
//结束英雄迷窟
void sc_logic_t::on_req_cave_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_exit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.exit_cave(jpk_);

}
//英雄迷窟挂机
void sc_logic_t::on_req_cave_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_pass_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.pass_cave(jpk_);
}
//刷新关卡
void sc_logic_t::on_req_cave_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_flush_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->new_round.flush_cave(jpk_.resid);

}
//////////////////////////
void sc_logic_t::on_req_city_boss_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_city_boss_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_city_boss_info, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_city_boss_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_city_boss_info_t ret;
    ret.cd = 0;
    ret.killcount = 0;
    ret.code = cityboss.unicast(user->db.uid, jpk_.sceneid);
    if (ret.code != SUCCESS)
        msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_fight_city_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fight_city_boss_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_fight_city_boss, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_fight_city_boss, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_fight_city_boss_t ret;
    ret.code = cityboss.fight(user, jpk_.bossid, jpk_.win);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_begin_fight_city_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_fight_city_boss_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_begin_fight_city_boss, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_begin_fight_city_boss, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_begin_fight_city_boss_t ret;
    ret.bossid = jpk_.bossid;
    ret.code = cityboss.begin_fight(user, jpk_.bossid);
    if (ret.code != SUCCESS)
        msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_compose_drawing(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_drawing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_compose_drawing, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_compose_drawing, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_compose_drawing_t ret;
    ret.code = user->item_mgr.drawing_compose(jpk_.resid, jpk_.source);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_starreward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_starreward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_starreward, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_starreward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_starreward_t ret;
    ret.code = user->reward.given_starreward(jpk_.id, jpk_.starnum);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_starreward_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_starreward_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_starreward_info, no uid with seskey:%lu", seskey_)); return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_starreward_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_starreward_info_t ret;
    ret.id = jpk_.id;
    ret.code = user->reward.unicast_starreward_info(jpk_.id);
    if (ret.code != SUCCESS)
        msg_sender_t::unicast(seskey_, conn_, ret);
}
//乱斗场报名
void sc_logic_t::on_req_scuffle_prepare(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_regist_t & jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_scuffle_regist_t ret;
    ret.code = scuffle_mgr.sign_up(user);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(), ret.code);
}
//请求离开乱斗场
void sc_logic_t::on_req_scuffle_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_leave_scene & jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    scuffle_mgr.exit_scuffle(user);
}
//乱斗场进入战斗
void sc_logic_t::on_req_scuffle_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_battle_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    scuffle_mgr.enter_battle(user,jpk_.uid);
}
//乱斗场离开战斗
void sc_logic_t::on_req_scuffle_battle_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_battle_end_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    scuffle_mgr.exit_battle(user, jpk_);
}
//乱斗场请求积分排名
void sc_logic_t::on_req_scuffle_score(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_ranking_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    scuffle_mgr.get_rank(user->db.uid);
}
//乱斗场请求是否开放
void sc_logic_t::on_req_scuffle_state(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_state_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_scuffle_state_t ret;
    ret.code = scuffle_mgr.req_scuffle_state(user, ret.state, ret.self_state, ret.remain_time);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user, jpk_.cmd(), ret.code);
}
//乱斗场请求领奖
/*
void sc_logic_t::on_req_scuffle_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_scuffle_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_scuffle_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_scuffle_reward_t ret;
    ret.code = SUCCESS;
    logic.unicast(uid, ret);

    scuffle_mgr.get_reward();
}
*/
//请求领取累计登录30天奖励
void sc_logic_t::on_req_sign_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cumulogin_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->reward.get_cumulogin_reward(jpk_.lv);
}
//请求战斗力排名
void sc_logic_t::on_req_fp_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fp_rank_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    fp_rank.unicast_fp_rank(uid);
}
//请求等级排名
void sc_logic_t::on_req_lv_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lv_rank_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    lv_rank.unicast_lv_rank(uid);
}
//请求同步战力
void sc_logic_t::on_req_sync_fp(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sync_fp_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_sync_fp_t ret;
    ret.fp = user->get_total_fp();
    logic.unicast(uid, ret);

}

//请求同步战力
void sc_logic_t::on_req_arena_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_rank_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_arena_rank_t ret;
    ret.rank = user->db.rank;
    logic.unicast(uid, ret);
}

void sc_logic_t::on_expel(sp_rpc_conn_t conn_, inner_msg_def::nt_expel_t& jpk_)
{
    uint64_t existed_seskey = session.get_seskey(jpk_.uid);
    if (existed_seskey!=0)
    {
        inner_msg_def::nt_session_broken_t jpk;
        jpk.seskey = existed_seskey;
        on_session_broken(existed_seskey,conn_,jpk);
        session.broken_seskey(existed_seskey, conn_);
    }
}
void sc_logic_t::on_notalk(inner_msg_def::nt_notalk_t& jpk_)
{
    sp_user_t user;
    if (usermgr().get(jpk_.uid, user))
    {
        user->notalk=jpk_.enable;
    }

}
void sc_logic_t::on_gm_mail(inner_msg_def::nt_gm_mail_t& jpk_)
{
    sp_user_t user;
    if (usermgr().get(jpk_.uid, user))
    {
        sql_result_t res;
        if (db_Mail_t::sync_select(jpk_.uid, res) == 0){

            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                sql_result_row_t& row = *res.get_row_at(i);
                db_Mail_t db;
                db.init(row);
                notify_ctl.push_mail(jpk_.uid, db.info.c_str());

                db_service.async_do((uint64_t)jpk_.uid, [](uint32_t uid_){
                        char sql[128];
                        sprintf(sql, "delete from Mail where uid=%d", uid_);
                        db_service.async_execute(sql);
                        }, jpk_.uid);
            }
        }
    }
}

void sc_logic_t::on_compensate(inner_msg_def::nt_compensate_t& jpk_)
{
    sp_user_t user;
    if (!usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "on_compensate, no uid:%d", jpk_.uid));
        return;
    }

    db_Compensate_t db;
    sql_result_t res;

    if (0==db_Compensate_t::sync_select_compensate(user->db.uid, 0, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db.init(*res.get_row_at(i));

            if( db.resid == 10003 )
            {
                //补偿水晶
                user->on_freeyb_change(db.count);
                user->save_db();
            }
            else if( db.resid == 10007 )
            {
                //补偿vip等级
                if( user->db.viplevel < (int)db.count )
                {
                    user->reward.on_vip_upgrade((int)db.count,0);

                    user->db.set_viplevel((int)db.count);
                    auto rp_vcg = repo_mgr.vip.get(user->db.viplevel);
                    if (rp_vcg != NULL)
                        user->db.set_vipexp(rp_vcg->pay);
                    user->save_db();

                    {
                        sc_msg_def::nt_vip_exp_changed_t nt;
                        nt.now = user->db.vipexp;
                        logic.unicast(user->db.uid, nt);
                    }

                    {
                        sc_msg_def::nt_vip_levelup_t nt;
                        nt.now= user->db.viplevel;
                        logic.unicast(user->db.uid, nt);
                    }

                }

            }
            //设置为已补偿
            db_service.async_do((uint64_t)user->db.uid,[](uint32_t stamp_,int id_){
                    char buf[256];
                    sprintf(buf, "update Compensate set state=1,givenstamp=%d where id=%d",stamp_,id_);
                    db_service.async_execute(buf);
                    }, date_helper.cur_sec(), db.id);
        }
    }
}

void sc_logic_t::update_maqee()
{
    m_maquee_time++;
    if (m_maquee_time > 3000){
        m_maquee_time = 0;
    }
} 
//请求使用道具
void sc_logic_t::on_req_use_item(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_use_item_t& jpk_)
{
    sc_msg_def::ret_use_item_failed_t failed;

    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        failed.code = ERROR_SC_NO_USER; 
        msg_sender_t::unicast(seskey_, conn_, failed);
        return;
    }

    int code = sp_user->item_mgr.use_item(jpk_.resid, jpk_.num, jpk_.param);
    if (code != SUCCESS)
    {
        failed.code = code; 
        msg_sender_t::unicast(seskey_, conn_, failed);
    }

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid);
}
//请求月卡奖励信息
void sc_logic_t::on_req_mcard_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mcard_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mcard_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mcard_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_mcard_info_t ret;
    ret.mcardn = ret.todayn = 0;
    ret.todayn= user->reward.get_mcardn(ret.mcardn);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//领取月卡奖励
void sc_logic_t::on_req_mcard_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mcard_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mcard_info, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mcard_info, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_mcard_reward_t ret;
    ret.code = user->reward.given_mcard_reward();
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//领取战斗力冲刺奖励
void sc_logic_t::on_req_fp_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fp_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->reward.get_fp_reward(jpk_.pos);
}
//领取累计消费奖励
void sc_logic_t::on_req_cumu_yb_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_cumu_yb_reward_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->reward.get_cumu_yb_reward(jpk_.pos);
}

void sc_logic_t::on_item_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_item_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_item_buy, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_item_buy, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_item_buy_t ret;
    ret.code = user->shop.buy_item(jpk_.resid, jpk_.num);
    ret.resid = jpk_.resid;
    ret.num = jpk_.num;
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid,jpk_.num,ret.code);
}
//领取每日充值奖励
void sc_logic_t::on_req_daily_pay_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_daily_pay_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_daily_pay_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_daily_pay_reward, no uid:%d", uid));
        return;
    }
    if (jpk_.pos > 200 && jpk_.pos < 2000)
        user->reward.get_limit_reward(jpk_.pos);
    else
        user->reward.get_daily_pay_reward(jpk_.pos);
}
//累计消费排行榜
void sc_logic_t::on_req_cumu_yb_rank(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_cumu_yb_rank_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_cumu_yb_rank, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_cumu_yb_rank, no uid:%d", uid));
        return;
    }

    activity.unicast(e_act_cumu_yb_rank, uid);
}
void sc_logic_t::on_req_mail_list(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_list_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mail_list, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mail_list, no uid:%d", uid));
        return;
    }

    user->gmail.unicast();
}
void sc_logic_t::on_req_mail_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mail_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mail_reward, no uid:%d", uid));
        return;
    }

    user->gmail.reward(jpk_.id);
}
void sc_logic_t::on_nt_mail_reaeded(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_gmail_readed_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mail_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mail_reward, no uid:%d", uid));
        return;
    }

    user->gmail.open(jpk_.id);
}
void sc_logic_t::on_req_mail_delete(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_delete_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mail_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mail_reward, no uid:%d", uid));
        return;
    }

    user->gmail.deletemail(jpk_.id);
}
void sc_logic_t::on_req_mail_allreward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_getallreward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_mail_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_mail_reward, no uid:%d", uid));
        return;
    }

    user->gmail.getallreward();
}

void sc_logic_t::on_nt_mail_delete(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_delete_gmail_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_nt_mail_delete, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_nt_mail_delete, no uid:%d", uid));
        return;
    }

    user->gmail.clear(jpk_.flag);
}
void sc_logic_t::on_gm_gmail(const vector<int>& uids_, const string& msg_)
{
    sc_msg_def::jpk_gmail_t jpk;
    try
    {
        jpk << msg_;
    }
    catch(std::exception& ex_)
    {
        logerror((LOG, "on_gm_gmail, jstr<%s>,exception<%s>", msg_.c_str(), ex_.what()));
        return;
    }

    for(size_t i=0; i< uids_.size(); i++)
    {
        int uid_ = uids_[i];
        sp_user_t user;
        if (!usermgr().get(uid_, user))
        {
            if (!cache.get(uid_, user))
            {
                user.reset(new sc_user_t);
                if (!user->load_db(uid_))
                {
                    logerror((LOG, "on_user_gmail, no uid:%d", uid_));
                    continue;
                }
            }
        }
        if (user != NULL)
            user->gmail.send(jpk);
    }

    if (uids_.empty()) 
    {
        /*
        usermgr().foreach([&](sp_user_t user_){
                user_->gmail.send(jpk);     
                });
        */

        sc_gmail_mgr_t::add_hostmail(jpk);
    }
}
void sc_logic_t::on_req_act_task(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_act_task_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_act_task, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_act_task, no uid:%d", uid));
        return;
    }

    user->daily_task.unicast();
}
void sc_logic_t::on_req_act_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_act_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_act_task, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_act_task, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_act_reward_t ret;
    ret.resid = jpk_.resid;
    bool doubleReward = user->reward.isInDoubleActivity(7);
    ret.code = user->daily_task.given_reward(jpk_.resid,doubleReward);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

void sc_logic_t::on_req_achievement_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_achievement_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_achievement_reward, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_achievement_reward, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_achievement_reward_t ret;
    ret.resid = jpk_.resid;
    ret.systype = jpk_.systype;
    ret.code = user->achievement.given_reward(jpk_.resid);
    msg_sender_t::unicast(seskey_, conn_, ret);
}


void sc_logic_t::on_req_achievement_task(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_achievement_task_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_achievement_task, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_achievement_task, no uid:%d", uid));
        return;
    }

    user->achievement.unicast();
}

void sc_logic_t::on_nt_twrecordop(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_twoprecrod_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_nt_twrecordop, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_nt_twrecordop, no uid:%d", uid));
        return;
    }

    user->reward.on_twoprecord_done(jpk_.op_done);
}
//请求领红包
void sc_logic_t::on_req_hongbao(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hongbao_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_hongbao, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_hongbao, no uid:%d", uid));
        return;
    }

    //设置公会用户上线
    sp_gang_t sp_gang; 
    sp_ganguser_t sp_guser; 
    if (gang_mgr.get_gang_by_uid(uid, sp_gang, sp_guser))
    {
        sc_msg_def::ret_hongbao_t ret;
        ret.code = sp_gang->given_hongbao(user, jpk_.id);
        if (ret.code != SUCCESS)
            msg_sender_t::unicast(seskey_, conn_, ret);
    }
}
//请求鼓舞
void sc_logic_t::on_req_guwu(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guwu_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_guwu, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_guwu, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guwu_t ret;
    ret.code = user->on_guwu(jpk_.flag, jpk_.yb, jpk_.coin); 
    ret.flag = jpk_.flag;
    auto guwu = user->get_guwu(jpk_.flag);
    if (guwu != NULL)
    {
        ret.v = guwu->v; 
        ret.stamp_yb = guwu->stamp_yb;
        ret.stamp_coin = guwu->stamp_coin;
        ret.progress = guwu->progress;
    }
    else
    {
        ret.v = 0; 
        ret.stamp_yb = 0;
        ret.stamp_coin = 0;
        ret.progress = 0;
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求复活
void sc_logic_t::on_req_fuhuo(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fuhuo_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_fuhuo, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_hongbao, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_fuhuo_t ret;
    ret.code = scuffle_mgr.fuhuo(user);
    ret.v = 1; 
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_limit_round(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_limit_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_limit_round, no uid:%d", uid));
        return;
    }

    sc_limit_round_mgr.user_round_battle(uid, jpk_.roundid,jpk_.partners, user);
}


void sc_logic_t::on_req_limit_result(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_quit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_limit_quit_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_limit_quit_round, no uid:%d", uid));
        return;
    }

    sc_limit_round_mgr.user_round_battle_res(uid, jpk_.result, jpk_.roundid, user, jpk_.salt);
}

//请求清除属性本CD
void
sc_logic_t::on_req_limit_round_clear_cd(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_clear_lmt_cd& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_limit_quit_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_limit_quit_round, no uid:%d", uid));
        return;
    }

    sc_limit_round_mgr.clear_fight_cd(uid, user);
    statics_ins.unicast_eventlog(*user, jpk_.cmd());
}

//请求十二宫当前id
void sc_logic_t::on_req_zodiacid(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_zodiacid_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_limit_quit_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_limit_quit_round, no uid:%d", uid));
        return;
    }

    if (date_helper.offday(user->db.zodiacstamp)>=1)
    {
        user->db.set_zodiacstamp(date_helper.cur_sec());
        user->db.set_zodiacid(0);
        user->save_db();
    }
    sc_msg_def::ret_zodiacid_t ret;
    ret.id = user->db.zodiacid;
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求限时副本数据
void sc_logic_t::on_req_limit_round_data(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_round_data &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_limit_round_data, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_limit_round_data, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_limit_round_data ret;
    user->get_limit_round_data(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//充值属性试炼次数
void sc_logic_t::on_req_reset_limit_round_times(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_reset_limit_round_times &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_reset_limit_round_times, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_reset_limit_round_times, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_reset_limit_round_times ret;
    ret.code = user->reset_limit_round_times(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求装备翅膀
void sc_logic_t::on_req_wear_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_wear_wing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_wear_wing, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_wear_wing, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_wear_wing_t ret;
    ret.wid = jpk_.wid;
    ret.resid = jpk_.resid;
    ret.flag = jpk_.flag;
    switch(ret.flag)
    {
    case 1:
    ret.code = user->wing.wear(jpk_.wid);
    break;
    case 0:
    ret.code = user->wing.takeoff(jpk_.wid);
    break;
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
//请求合成翅膀
void sc_logic_t::on_req_compose_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_compose_wing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_compose_wing, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_compose_wing, no uid:%d", uid));
        return;
    }

    switch(jpk_.flag)
    {
    case 0:
    user->wing.compose(jpk_.wid);
    break;
    case 1:
    sc_msg_def::ret_compose_wing_t ret;
    ret.wid = jpk_.wid;
    ret.flag = jpk_.flag;
    ret.code = user->wing.split(jpk_.wid);
    msg_sender_t::unicast(seskey_, conn_, ret);
    break;
    }
}
//请求翅膀抽签
void sc_logic_t::on_req_gacha_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gacha_wing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;

    act_wing_t* p = (act_wing_t*)activity.get_act(e_act_wing);
    if (p != NULL)
    {
        sc_msg_def::ret_gacha_wing_t ret;
        ret.code = p->on_gacha(user->db.uid, jpk_.num);
        if (ret.code != SUCCESS)
            msg_sender_t::unicast(seskey_, conn_, ret);
    }
}
//请求领取积分翅膀
void sc_logic_t::on_req_get_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_get_wing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;

    act_wing_t* p = (act_wing_t*)activity.get_act(e_act_wing);
    if (p != NULL)
    {
        sc_msg_def::ret_get_wing_t ret;
        ret.code = p->given_score_wing(user->db.uid);
        msg_sender_t::unicast(seskey_, conn_, ret);
    }
}
//请求翅膀排名
void sc_logic_t::on_req_wing_rank(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_wing_rank_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;

    act_wing_t* p = (act_wing_t*)activity.get_act(e_act_wing);
    if (p != NULL)
        p->unicast(user->db.uid);
}
//请求出售翅膀
void sc_logic_t::on_req_sell_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_sell_wing_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;

    sc_msg_def::ret_sell_wing_t ret; 
    ret.code = user->wing.sell(jpk_.wid);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求升级宠物
void sc_logic_t::on_req_compose_pet(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_compose_pet_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_compose_pet, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_compose_pet, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_compose_pet_t ret;
    ret.code = sp_user->pet_mgr.compose(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

//请求编年史信息
void sc_logic_t::on_req_chronicle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_chronicle, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user->chronicle.unicast_chronicle_list(jpk_.chronicle_id);
}

//请求完成当日编年史任务
void sc_logic_t::on_req_chronicle_sign(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_chronicle_sign, no uid with seskey:%lu", seskey_));
        return ;
    }
    sc_msg_def::ret_chronicle_sign_t ret;
    sp_user->chronicle.sign(ret, jpk_.year_month_day);
    msg_sender_t::unicast(seskey_, conn_, ret);
    //statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,0,ret.code);
}

//编年史记录找回
void sc_logic_t::on_req_chronicle_sign_retrieve(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_retrieve_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_chronicle_sign_retrieve, no uid with seskey:%lu", seskey_));
        return ;
    }
    sc_msg_def::ret_chronicle_sign_retrieve_t ret;
    sp_user->chronicle.record_retrieve(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求编年史所有签到记录
void sc_logic_t::on_req_chronicle_sign_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_all_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_chronicle_sign_all, no uid with seskey:%lu", seskey_));
        return ;
    }
    sc_msg_def::ret_chronicle_sign_all_t ret;
    sp_user->chronicle.progress(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求所有卡牌爱恋度任务
void sc_logic_t::on_req_love_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_love_task_list_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_love_task_list, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user->love_task.unicast_love_task_list();
}

//请求完成卡牌爱恋度任务
void sc_logic_t::on_req_commit_love_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_love_task_t& jpk_)
{
    sp_user_t sp_user = getuid(seskey_);
    if (sp_user == NULL)
    {
        logerror((LOG, "on_req_love_task_list, no uid with seskey:%lu", seskey_));
        return;
    }

    sc_msg_def::ret_commit_love_task_t ret;
    ret.resid = jpk_.resid;
    ret.code = sp_user->love_task.commit(jpk_.resid, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);

    //记录事件
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd(),jpk_.resid,1,ret.code);
}

//请求每日签到奖励
void sc_logic_t::on_req_sign_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_reward_t& jpk_)
{
    int32_t uid;
    if((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_sign_info, no uid with seskey:%u", seskey_));
        return;
    }

    sp_user_t user;
    if(!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_sign_info, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_sign_reward_t ret;
    ret.id = jpk_.id;
    ret.code = user->sign_daily.get_sign_reward(jpk_.id);
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求每日签到相关信息
void sc_logic_t::on_req_sign_daily(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_daily_t& jpk_)
{ 
    int32_t uid;
    if((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_sign_daily, no uid with seskey:%u", seskey_));
        return;
    }

    sp_user_t user;
    if(!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_sign_daily, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_sign_daily_t ret;
    ret.sign_daily  = user->db.sign_daily;
    ret.cost        = user->db.sign_cost;
    ret.cur_day     = date_helper.cur_dayofmonth();
    ret.cur_month   = date_helper.cur_month();
    msg_sender_t::unicast(seskey_, conn_, ret);
    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd());

}

//请求补签奖励
void sc_logic_t::on_req_sign_remedy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_remedy_t& jpk_)
{
    int32_t uid;
    if((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_sign_remedy, no uid with seskey:%u", seskey_));
        return;
    }

    sp_user_t user;
    if(!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_sign_remedy, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_sign_remedy_t ret;
    ret.id = jpk_.signid;
    ret.code = user->sign_daily.get_sign_remedy(jpk_.signid);
    ret.cost = user->db.sign_cost;
    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求弹幕列表
void sc_logic_t::on_bullet_list(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_bullet_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;
    sc_msg_def::ret_bullet_t ret;

    sc_bullet_t sc_bullet(user);

    sc_bullet.getList(jpk_.round, ret);

    msg_sender_t::unicast(seskey_, conn_, ret);
}

//请求发送弹幕
void sc_logic_t::on_send_bullet(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_send_bullet_t& jpk)
{
    logerror((LOG, "send_bullet:"));
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
        return;

    sp_user_t user;
    if (!usermgr().get(uid, user))
        return;
    sc_bullet_t sc_bullet(user);
    //arg1 = 消息
    //arg2 = 时间
    //arg3 = 位置
    //arg4 = round
    bool res = sc_bullet.addnew(jpk.msg, date_helper.cur_sec(), jpk.pos, jpk.round);
    sc_msg_def::ret_send_bullet_t ret;
    ret.ok = true;
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_prestige_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_prestige_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_prestige_shop_items, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_prestige_shop_items, no uid:%d", uid));
        return;
    }
    user->prestigeshop.unicast_shop_items(jpk_.index);

    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.index,0);
}
void sc_logic_t::on_req_prestige_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_prestige_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_prestige_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_prestige_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_prestige_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->prestigeshop.buy(jpk_.id, jpk_.num, ret.item_id, ret.num, jpk_.shopindex);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);
}

void sc_logic_t::on_req_chip_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_chip_shop_items, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_chip_shop_items, no uid:%d", uid));
        return;
    }
    user->chipshop.unicast_shop_items();

    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.page,0);
}
void sc_logic_t::on_req_chip_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_chip_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_chip_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_chip_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->chipshop.buy(jpk_.id, jpk_.num, ret.item_id, ret.num);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);
}

void sc_logic_t::on_req_chip_smash_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_smash_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_chip_smash_items, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_chip_smash_items, no uid:%d", uid));
        return;
    }
    user->chipsmash.unicast_smash_items();

    statics_ins.unicast_eventlog(*user,jpk_.cmd(),0);
}

void sc_logic_t::on_req_chip_smash_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_smash_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_chip_smash_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_chip_smash_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_chip_smash_buy_t ret;
    ret.id = jpk_.id;
    ret.num = jpk_.num;
    ret.code = user->chipsmash.buy(jpk_.id, jpk_.num);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);
}

void sc_logic_t::on_req_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_expedition_round, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_expedition_round, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_round_t ret;
    ret.code = user->expedition.get_expedition_round(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_expedition(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_expedition, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user)) {
        logerror((LOG, "on_req_expedition, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_t ret;
    ret.code = user->expedition.get_expedition_data(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_enter_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_expedition_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_enter_expedition_round, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_enter_expedition_round, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_enter_expedition_round_t ret;
    ret.resid = jpk_.resid;
    ret.code = user->expedition.enter_expedition(jpk_.resid, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
}
void sc_logic_t::on_req_exit_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_exit_expedition_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_exit_expedition_round, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_exit_expedition_round, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_exit_expedition_round_t ret;
    ret.code = user->expedition.exit_expedition(jpk_);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}
void sc_logic_t::on_req_expedition_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_team_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_exit_expedition_round, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user))
    {
        logerror((LOG, "on_req_exit_expedition_round, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_expedition_team_t ret;
    ret.code = sp_user->team_mgr.get_expedition_team(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);

    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_nt_expedition_team_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_expedition_team_change_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_nt_expedition_team_change, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user))
    {
        logerror((LOG, "on_nt_expedition_team_change, no uid:%d", uid));
        return;
    }
    sp_user->team_mgr.change_expedition_team(jpk_);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_expedition_round_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_round_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_expedition_round_reward, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user))
    {
        logerror((LOG, "on_req_expedition_round_reward, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_round_reward_t ret;
    ret.code = sp_user->expedition.get_reward(jpk_.resid, ret ,sp_user->reward.get_expedition_state() ? true : false);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_expedition_partners(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_partners_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_expedition_round_reward, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user))
    {
        logerror((LOG, "on_req_expedition_round_reward, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_partners_t ret;
    ret.code = sp_user->team_mgr.get_expedition_partners(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_expedition_reset(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_reset_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_expedition_reset, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_expedition_reset, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_reset_t ret;
    ret.code = sp_user->expedition.reset(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}
void sc_logic_t::on_req_expedition_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_expedition_shop, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_expedition_shop, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_shop_items_t ret;
    ret.code = sp_user->expeditionshop_mgr.unicast_shop_items();
   // msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_expedition_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_expedition_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_expedition_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_expedition_shop_buy_t ret;
    ret.code = sp_user->expeditionshop_mgr.buy(jpk_.index, 1);
    ret.index = jpk_.index;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

void sc_logic_t::on_req_gang_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_gang_shop, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_gang_shop, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_gang_shop_items_t ret;
    ret.code = sp_user->gangshop_mgr.unicast_shop_items();
    //msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_gang_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_gang_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_gang_shop_buy, no uid:%d", uid));
        return;
    }
    //sc_msg_def::ret_gang_shop_buy_t ret;
    sp_user->gangshop_mgr.buy(jpk_.index, 1);
    //ret.index = jpk_.index;
    //msg_sender_t::unicast(seskey_, conn_, ret);
    //statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

void sc_logic_t::on_req_rune_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_rune_shop, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_rune_shop, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_rune_shop_items_t ret;
    ret.code = sp_user->runeshop_mgr.unicast_shop_items();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_rune_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_rune_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_rune_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_rune_shop_buy_t ret;
    ret.code = sp_user->runeshop_mgr.buy(jpk_.index, 1);
    ret.index = jpk_.index;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}


void sc_logic_t::on_req_cardevent_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cardevent_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_cardevent_shop, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_cardevent_shop, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_cardevent_shop_items_t ret;
    sp_user->cardeventshop_mgr.unicast_shop_items();
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_cardevent_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cardevent_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_cardevent_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_cardevent_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_cardevent_shop_buy_t ret;
    ret.code = sp_user->cardeventshop_mgr.buy(jpk_.index, 1);
    ret.index = jpk_.index;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

void sc_logic_t::on_req_lmt_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lmt_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_lmt_shop, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_lmt_shop, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_lmt_shop_items_t ret;
    sp_user->lmtshop_mgr.unicast_shop_items();
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_lmt_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lmt_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_lmt_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_lmt_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_lmt_shop_buy_t ret;
    ret.code = sp_user->lmtshop_mgr.buy(jpk_.index, 1);
    ret.index = jpk_.index;
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

void sc_logic_t::on_req_expedition_pass_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sweep_expedition_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_expedition_sweep, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_expedition_sweep, no uid:%d", uid));
        return;
    }
    sp_user->expedition.pass_expedition();
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

//navi点击事件
void sc_logic_t::on_req_naviClickNum_add(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_naviClickNum_add_t& jpk_)
{
     int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_req_naviClickNum_add, no uid with seskey:%lu", seskey_));
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_naviClickNum_add, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_naviClickNum_add_t ret;
    ret.resid = jpk_.naviId / 100;
    ret.index = jpk_.naviId % 100;
    if (ret.resid == user->db.resid)
    {
       user->db.set_naviClickNum1(user->db.naviClickNum1 + 1); 
    }    
    else
    {
        user->partner_mgr.naviClick(jpk_.naviId, ret.resid, ret.index);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd());
}

void sc_logic_t::on_req_write_guidence(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_write_guidence_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_write_guidence, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_write_guidence, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_write_guidence_t ret;
    if(jpk_.index == 0)
    {
        logerror((LOG, "on_req_write_guidence, error:%d", uid));
    }
    else if (jpk_.guideindex == 1)
    {
        sp_user->db.set_isnew(jpk_.index); 
    }
    else if (jpk_.guideindex == 2)
    {
        sp_user->db.set_isnewlv(jpk_.index);
    }
    sp_user->save_db();
    ret.index = jpk_.index;
    ret.guideindex = jpk_.guideindex;

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

void sc_logic_t::on_req_chat_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chat_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_chatinfo, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_chatinfo, no uid:%d", uid));
        return;
    }
    chat_ins.getChatMessage(uid, sp_user->db.hostnum);
}

/* 卡牌活动 */
void
sc_logic_t::on_req_card_event_open_round(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_open_round_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_open_round, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_open_round, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_open_round_t ret;
    if (jpk_.is_reset == 1)
    {
        int code = sp_user->card_event.reset();
        if (code != SUCCESS)
        {
            ret.code = code;
            msg_sender_t::unicast(seskey_, conn_, ret);
            statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), code);
            return;
        }
    }
    ret.code = sp_user->card_event.open(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_fight_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_fight, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_fight, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_fight_t ret;
    ret.code = sp_user->card_event.fight(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_round_exit(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_round_exit_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_round_exit, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_round_exit, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_round_exit_t ret;
    ret.code = sp_user->card_event.fight_end(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_reset(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_reset_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_reset, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_reset, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_reset_t ret;
    ret.code = sp_user->card_event.reset();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_nt_card_event_change_team(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::nt_card_event_change_team_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_nt_card_event_change_team, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_nt_card_event_change_team, no uid:%d", uid));
        return;
    }
    sp_user->team_mgr.card_event_change_team(jpk_);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_round_enemy(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_round_enemy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_round_enemy, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_round_enemy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_round_enemy_t ret;
    ret.code = sp_user->card_event.get_enemy_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_revive(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_revive_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_revive, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_revive, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_card_event_revive_t ret;
    ret.code = sp_user->card_event.revive(jpk_, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

void
sc_logic_t::on_req_card_event_rank(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_rank_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }
    card_event_rank.unicast_card_event_rank(uid);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}
void sc_logic_t::on_req_card_event_sweep(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_card_event_sweep_t& jpk_){
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_sweep, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_sweep, no uid:%d", uid));
        return;
    }
    sp_user->card_event.card_event_sweep();
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_card_event_next(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_next_card_event_t& jpk_){
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_next, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_next, no uid:%d", uid));
        return;
    }  
    sc_msg_def::ret_next_card_event_t ret;
    ret.code = sp_user->card_event.next_round_end(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}
void sc_logic_t::on_req_card_event_first_enter(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_card_event_first_enter_t& jpk_){
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_first_enter, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_first_enter, no uid:%d", uid));
        return;
    }  
    sc_msg_def::ret_card_event_first_enter ret;
    ret.code = sp_user->card_event.set_first_enter();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user,jpk_.cmd());
}

// 获取晶魂信息
void sc_logic_t::on_req_get_soul_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_soul_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_get_soul_info_t ret;
    ret.code = sp_user->soul.get_info(ret);

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

// 精炼晶魂
void sc_logic_t::on_req_hunt_soul(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hunt_soul_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_hunt_soul_t ret;
    ret.code = sp_user->soul.hunt(ret);

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

// 加持晶魂
void sc_logic_t::on_req_rankup_soul(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rankup_soul_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_rankup_soul_t ret;
    ret.code = sp_user->soul.rankup(ret);

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

// 获得当前奖励
void sc_logic_t::on_req_get_soul_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_soul_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_get_soul_reward_t ret;
    ret.code = sp_user->soul.get_reward(ret , sp_user->reward.isInDoubleActivity(3));

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

// 请求匹配
void 
sc_logic_t::on_req_rank_season_match(uint64_t seskey_, sp_rpc_conn_t conn_,
    sc_msg_def::req_rank_season_match_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    rank_match_s.match(uid, jpk_, sp_user);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

// 请求赛季排位信息
void
sc_logic_t::on_req_rank_season_info(uint64_t seskey_, sp_rpc_conn_t conn_,
    sc_msg_def::req_rank_season_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_rank_season_info_t ret;
    user_info_set user_info_;
    ret.code = rank_season_s.find_user(uid, user_info_,sp_user, ret.month, ret.day, ret.hour);
    ret.rank = user_info_.rank;
    ret.score = user_info_.score;
    ret.season = user_info_.season;
    ret.lose_count = user_info_.successive_defeat;

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(),user_info_.rank, user_info_.score,0,0);
}

// 请求赛季排位战斗结束
void 
sc_logic_t::on_req_rank_seson_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_,
    sc_msg_def::req_rank_seson_fight_end_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_rank_season_fight_end_t ret;
    user_info_set user_info_;
    if (jpk_.is_win)
    {
        ret.code = rank_season_s.win_rank_match(uid, sp_user, user_info_);
        //ret.code = rank_season_s.win_match(uid, user_info_, sp_user);
    }
    else
    {
        //ret.code = rank_season_s.lose_match(uid, user_info_, sp_user);
        ret.code = rank_season_s.lose_rank_match(uid, sp_user, user_info_);
    }

    sp_user->reward.update_opentask(open_task_rank_count); 
    ret.rank = user_info_.rank;
    ret.score = user_info_.score;
    ret.lose_count = user_info_.successive_defeat;

    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(),user_info_.rank, user_info_.score,0,0);
}

// 请求取消赛季排位赛匹配
void
sc_logic_t::on_req_cancel_rank_season_wait(uint64_t seskey_, sp_rpc_conn_t conn_,
    sc_msg_def::req_cancel_rank_season_wait_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_card_event_rank, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_card_event_rank, no uid:%d", uid));
        return;
    }

    rank_match_s.cancel_wait(uid, sp_user);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

//开始排位赛战斗
void sc_logic_t::on_req_begin_rank_match_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_rank_match_fight_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_begin_rank_match_fight, no uid with seskey:%lu",seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_begin_rank_match_fight, no uid:%d", uid));
        return;
    }
    
    sc_msg_def::ret_begin_rank_match_fight_t ret;
    ret.code = 0;
    msg_sender_t::unicast(seskey_, conn_, ret);
    rank_season_s.cal_match_result(uid);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}

//请求更换主角
void sc_logic_t::req_change_roletype(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_roletype_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "req_change_roletype, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "req_change_roletype, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_change_roletype_t ret;
    ret.code = sp_user->change_roletype(jpk_.roletype);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(),jpk_.roletype, sp_user->db.resid);
}

//请求开启魂师
void sc_logic_t::req_soulnode_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_soulnode_open_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "req_soulnode_open, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "req_soulnode_open, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_soulnode_open_t ret;
    ret.code = sp_user->soulrank_mgr.req_open_soulnode(jpk_.soulid);
    msg_sender_t::unicast(seskey_, conn_, ret);
    if(ret.code == SUCCESS)
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(),jpk_.soulid, sp_user->db.resid);
}

//请求魂师信息
void sc_logic_t::req_soulnode_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_soulnode_pro_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "req_soulnode_pro, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "req_soulnode_pro, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_soulnode_pro_t ret;
    sp_user->soulrank_mgr.unicast_soul_node_info(ret.node_info, jpk_.soulid);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(),jpk_.soulid, sp_user->db.resid);
}

void
sc_logic_t::on_req_guild_battle_state(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_state& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_state ret;
    ret.code = sp_user->guild_battle_mgr.cur_state(ret.guild_state, ret.gbattle_state);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.guild_state, ret.gbattle_state);
}

// 公会战报名
void
sc_logic_t::on_req_guild_battle_sign_up(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_sign_up& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_sign_up ret;
    ret.code = sp_user->guild_battle_mgr.sign_up();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 公会战布阵信息获取
void
sc_logic_t::on_req_guild_battle_defence_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_defence_info& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_defence_info ret;
    ret.code = sp_user->guild_battle_mgr.get_defence_info(jpk_.building_id, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

//公会布阵整体情况
void
sc_logic_t::on_req_guild_battle_whole_defence_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_whole_defence_info& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_whole_defence_info ret;
    ret.code = sp_user->guild_battle_mgr.get_whole_defence_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 上阵
void
sc_logic_t::on_req_guild_battle_defence_pos_on(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_defence_pos_on& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_defence_pos_on ret;
    ret.code = sp_user->guild_battle_mgr.defence_pos_on(jpk_);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 下阵
void
sc_logic_t::on_req_guild_battle_defence_pos_off(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_defence_pos_off& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_defence_pos_off ret;
    ret.code = sp_user->guild_battle_mgr.defence_pos_off(jpk_);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 取消他人位置
void
sc_logic_t::on_req_guild_battle_cancel_other_pos(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_cancel_other_pos& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_cancel_other_pos ret;
    ret.code = sp_user->guild_battle_mgr.cancel_others_pos(jpk_);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 建筑物升级
void
sc_logic_t::on_req_guild_battle_building_level_up(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_building_level_up& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_building_level_up ret;
    ret.code = sp_user->guild_battle_mgr.building_level_up(jpk_.building_id, jpk_.old_level, ret.new_level);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 战斗日 全局状态查看
void
sc_logic_t::on_req_guild_battle_whole_defence_info_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_whole_defence_info_fight& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_whole_defence_info_fight ret;
    ret.code = sp_user->guild_battle_mgr.get_whole_defence_info_fight(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 战斗日 守方阵型获取
void
sc_logic_t::on_req_guild_battle_defence_info_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_defence_info_fight& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_defence_info_fight ret;
    ret.code = sp_user->guild_battle_mgr.get_defence_info_fight(jpk_.building_id, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 公会战 请求战斗
void
sc_logic_t::on_req_guild_battle_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_fight& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_fight ret;
    ret.code = sp_user->guild_battle_mgr.fight(jpk_.building_id, jpk_.building_pos, jpk_.partners, ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 公会战 战斗结束
void
sc_logic_t::on_req_guild_battle_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_fight_end& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_fight_end ret;
    ret.code = sp_user->guild_battle_mgr.fight_end(jpk_.is_win, jpk_.anger, jpk_.anger_enemy, jpk_.partners, ret.cool_down, jpk_);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 进公会战 获取公会战报
void
sc_logic_t::on_req_guild_battle_fight_record_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_fight_record_info& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_fight_record_info ret;
    ret.code = sp_user->guild_battle_mgr.get_guild_fight_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 公会战 全体战绩
void
sc_logic_t::on_req_guild_battle_fight_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_fight_info& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_fight_info ret;
    ret.code = sp_user->guild_battle_mgr.get_guild_battle_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 购买挑战次数
void
sc_logic_t::on_req_guild_battle_buy_fight_times(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_buy_fight_times& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_buy_fight_times ret;
    ret.code = sp_user->guild_battle_mgr.buy_fight_times();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 清除挑战时间
void
sc_logic_t::on_req_guild_battle_clear_fight_cd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_clear_fight_cd& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_clear_fight_cd ret;
    ret.code = sp_user->guild_battle_mgr.clear_fight_cd();
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 侦查
void
sc_logic_t::on_req_guild_battle_spy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_spy& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_spy ret;
    ret.code = sp_user->guild_battle_mgr.spy(jpk_.building_id, jpk_.building_pos);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 该赛季公会信息查看
void
sc_logic_t::on_req_guild_battle_guild_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guild_battle_guild_info& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_guild_battle_sign_up, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_guild_battle_guild_info ret;
    ret.code = sp_user->guild_battle_mgr.get_guild_info(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

void sc_logic_t::on_req_plant_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_plant_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_plant_shop_items, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_chip_shop_items, no uid:%d", uid));
        return;
    }
    user->plantshop.unicast_shop_items();

    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.page,0);
}
void sc_logic_t::on_req_plant_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_plant_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_plant_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_plant_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_plant_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->plantshop.buy(jpk_.id, jpk_.num, ret.item_id, ret.num);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);
}

void sc_logic_t::on_req_inventory_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_inventory_shop_items_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_inventory_shop_items, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_inventory_shop_items, no uid:%d", uid));
        return;
    }
    user->inventoryshop.unicast_shop_items();

    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.page,0);
}
void sc_logic_t::on_req_inventory_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_inventory_shop_buy_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_inventory_shop_buy, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_inventory_shop_buy, no uid:%d", uid));
        return;
    }
    sc_msg_def::ret_inventory_shop_buy_t ret;
    ret.id = jpk_.id;
    ret.code = user->inventoryshop.buy(jpk_.id, jpk_.num, ret.item_id, ret.num);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.id,jpk_.num,ret.code);
}

//请求召唤排行
void sc_logic_t::on_req_pub_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_rank_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    pub_rank.unicast_pub_rank(uid);
}

void sc_logic_t::on_req_opentask_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_opentask_info_t &jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0)
    {
        logerror((LOG, "on_req_opentask_info, no uid with seskey:%lu", seskey_));
        return;
    }
    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_req_opentask_info, no uid:%d", uid));
        return;
    }
    user->reward.get_open_task_info(); 

}

void sc_logic_t::on_req_opentask_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_opentask_reward_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_))==0)
    {
        logerror((LOG, "on_begin_round, no uid with seskey:%lu", seskey_)); 
        return;
    }

    sp_user_t user;
    if (!usermgr().get(uid, user))
    {
        logerror((LOG, "on_end_round, no uid:%d", uid));
        return;
    }

    user->reward.get_opentask_reward(); 
}

// 请求开启珍宝
void sc_logic_t::on_req_combo_pro_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_combo_pro_open_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_combo_pro_open, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_combo_pro_open, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_combo_pro_open_t ret;
    ret.code = sp_user->combo_pro_mgr.open(jpk_.type_id);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), jpk_.type_id, ret.code);
}

// 请求升级珍宝
void sc_logic_t::on_req_combo_pro_levelup(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_combo_pro_levelup_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_combo_pro_levelup, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_combo_pro_levelup, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_combo_pro_levelup_t ret;
    ret.code = sp_user->combo_pro_mgr.add_exp(jpk_.type_id);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), jpk_.type_id, ret.code);
}

// 请求举报
void sc_logic_t::on_req_report(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_report_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_report, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_report, no uid:%d", uid));
        return;
    }

    sp_user->report_mgr.reportuser(jpk_.uid);
}

// 请求进入符文猎取界面
void sc_logic_t::on_req_enter_rune_hunt_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_rune_hunt_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_enter_rune_hunt, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_enter_rune_hunt_t, no uid:%d", uid));
        return;
    }

    sp_user->new_rune_mgr.enter_hunt(jpk_);
}

// 请求猎取符文
void sc_logic_t::on_req_hunt_rune_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hunt_rune_t& jpk_)
{ 
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_hunt_rune, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_hunt_rune, no uid:%d", uid));
        return;
    }

    sp_user->new_rune_mgr.hunt(jpk_.use_item);
}

// 请求离开符文猎取界面
void sc_logic_t::on_req_leave_rune_hunt_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_leave_rune_hunt_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_leave_rune_hunt, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_leave_rune_hunt_t, no uid:%d", uid));
        return;
    }

    sp_user->new_rune_mgr.inform_leave();
}

// 请求镶嵌符文
void sc_logic_t::on_req_new_rune_inlay_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_inlay_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_inlay, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_inlay, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_new_rune_inlay_t ret;
    ret.code = sp_user->new_rune_mgr.inlay_rune(jpk_.id, jpk_.pid, jpk_.pos, ret);
    if (ret.code == SUCCESS)
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.id, ret.pid, ret.pos);
    }
    else
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

// 请求卸下符文
void sc_logic_t::on_req_new_rune_unlay_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_unlay_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_inlay, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_inlay, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_new_rune_unlay_t ret;
    ret.code = sp_user->new_rune_mgr.unlay_rune(jpk_.pid, jpk_.pos, ret);
    if (ret.code == SUCCESS)
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.pid, ret.pos);
    }
    else
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

// 请求升级符文
void sc_logic_t::on_req_new_rune_levelup_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_levelup_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_levelup_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_levelup_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_new_rune_levelup_t ret;
    ret.code = sp_user->new_rune_mgr.levelup(jpk_.rune, jpk_.mat_list, ret);
    if (ret.code == SUCCESS)
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.id, ret.exp);
    }
    else
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

// 请求突破符文
void sc_logic_t::on_req_new_rune_compose_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_compose_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_compose_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_compose_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_new_rune_compose_t ret;
    ret.code = sp_user->new_rune_mgr.compose(jpk_.id, jpk_.mat_list, ret);
    if (ret.code == SUCCESS)
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.id, ret.lv);
    }
    else
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

// 请求激活伙伴符文
void sc_logic_t::on_req_new_rune_active_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_active_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_active_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_active_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_new_rune_active_t ret;
    ret.code = sp_user->new_rune_mgr.active_new_partner(jpk_.pid, ret);
    if (ret.code == SUCCESS)
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.pid);
    }
    else
    {
        statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}

// 请求公告信息
void sc_logic_t::on_req_announcement_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_announcement_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_announcement_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_announcement_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_announcement_t ret;
    
    auto item_info = repo_mgr.announcement_update.begin();
    while(item_info != repo_mgr.announcement_update.end())
    {
        sc_msg_def::jpk_announcement_info info;
        info.id = item_info->second.id;
        info.title = item_info->second.title;
        info.time = item_info->second.time;
        info.content = item_info->second.content;
        info.timestamp = sp_user->reward.str2stamp(item_info->second.time);
        ret.info_update.push_back(std::move(info));
        item_info++;
    }

    auto event_info = repo_mgr.announcement_event.begin();
    while(event_info != repo_mgr.announcement_event.end())
    {
        sc_msg_def::jpk_announcement_event info_event;
        info_event.id = event_info->second.id;
        info_event.title = event_info->second.title;
        info_event.start_time = event_info->second.start_time;
        info_event.end_time = event_info->second.end_time;
        info_event.timestamp = sp_user->reward.str2stamp(event_info->second.start_time);
        info_event.content = event_info->second.content;
        ret.info_event.push_back(std::move(info_event));
        event_info++;
    }
    msg_sender_t::unicast(seskey_, conn_, ret);
}
// 请求生成继承码
void sc_logic_t::on_req_gen_inheritance_code_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_inheritance_code_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_active_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_active_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_gen_inheritance_code_t ret;
    ret.code = sp_user->gen_inheritance_code(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, std::atoi(ret.inheritance_code.substr(0,8).c_str()), std::atoi(ret.inheritance_code.substr(8,8).c_str()));
}

// 请求主城形象
void sc_logic_t::on_req_model_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_model_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_active_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_active_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_model_t ret;
    ret.code = sp_user->get_model(ret);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code);
}

// 请求更换主城形象
void sc_logic_t::on_req_change_model_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_model_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_new_rune_active_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_new_rune_active_t, no uid:%d", uid));
        return;
    }

    sc_msg_def::ret_change_model_t ret;
    ret.code = sp_user->change_model(ret, jpk_.new_model);
    msg_sender_t::unicast(seskey_, conn_, ret);
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd(), ret.code, ret.model);
}


// 领取vip经验
void sc_logic_t::on_req_vip_exp_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_vip_exp_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_vip_exp_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_vip_exp_t, no uid:%d", uid));
        return;
    }

    //vip经验处理
    sp_user->reward.update_vip_exp(); 
}
void sc_logic_t::on_req_private_chat_info_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_private_chat_info_t& jpk_)
{
    int32_t uid;
    if ((uid = session.get_uid(seskey_)) == 0) {
        logerror((LOG, "on_req_private_chat_info_t, no uid with seskey:%lu",
                  seskey_));
        return;
    }
    sp_user_t sp_user;
    if (!usermgr().get(uid, sp_user)) {
        logerror((LOG, "on_req_private_chat_info_t, no uid:%d", uid));
        return;
    }

    notify_cache.getPrivateChatMessage(sp_user,jpk_.player_uid); 
    statics_ins.unicast_eventlog(*sp_user, jpk_.cmd());
}
