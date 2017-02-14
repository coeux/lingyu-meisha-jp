#ifndef _sc_logic_h_
#define _sc_logic_h_

#include "singleton.h"
#include "msg_dispatcher.h"
#include "msg_def.h"
#include "test_msg_def.h"
#include "rpc_client.h"
#include "sc_session.h"
#include "remote_info.h"
#include "sc_service.h"

#include "sc_user.h"
#include "sc_city.h"
#include "sc_lua.h"

class sc_logic_t : public msg_dispatcher_t<sc_logic_t>
{
public:
    sc_logic_t();
    ~sc_logic_t();

    void close();

    sc_user_mgr_t& usermgr(); 
    sc_city_mgr_t& citymgr();
    sc_lua_t& lua();
    
    void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }

    int is_online(int32_t uid_);

    bool has_host(int32_t host_);

    void unicast(int32_t uid_, uint16_t cmd_, const string& msg_);

    //走马灯广播
    void maquee_broadcast();
    //全服广播
    void broadcast_message(uint16_t cmd_, const string& msg_);

    template<class TMsg>
    void unicast(int32_t uid_, TMsg& msg_)
    {
        //判断玩家是否在线
        uint64_t seskey; 
        if ( (is_online(uid_)) && ((seskey=session.get_seskey(uid_))!=0))
        {
            uint32_t gwsid = ((uint32_t)REMOTE_GW<<16 | seskey>>48);
            sp_sc_gw_client_t client;
            if (sc_service.get(gwsid, client))
            {
                msg_sender_t::unicast(seskey, client->get_conn(), msg_);
            }
        }
    }
private:
    void init_lua();
private:
    //@login begin
    //客户端请求登陆
    void on_mac_login(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_);
    //请求角色列表
    void on_req_rolelist(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_);
    //请求创建角色
    void on_req_new_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_);
    //请求删除角色
    void on_req_del_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_);
    //@login end 

    //@scene begin
    //角色登陆
    void on_req_login(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_login_t& jpk_);
    //会话断开
    void on_session_broken(uint64_t seskey_, sp_rpc_conn_t conn_, inner_msg_def::nt_session_broken_t& jpk_);
    //请求角色数据
    void on_req_user_data(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_user_data_t& jpk_);
    //请求进入主城
    void on_req_enter_city(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_city_t& jpk_);
    //通知移动
    void on_nt_move(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_move_t& jpk_);
    //开始关卡
    void on_begin_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_round_t& jpk_);
    //结束关卡
    void on_end_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_end_round_t& jpk_);
    //开始挂机
    void on_begin_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_auto_round_t &jpk_);
    //获取挂机结果
    void on_req_halt_result(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_auto_round_resu_t &jpk_);
    //结束挂机
    void on_end_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_stop_auto_round_t &jpk_);
    //刷新关卡
    void on_flush_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_flush_round_t &jpk_);
    //通知阵型改变
    void on_team_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_team_change_t &jpk_);
    //通知移除队伍
    //void on_remove_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_remove_team_t &jpk_);
    //通知更换默认队伍
    void on_change_default_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_default_team_t &jpk_);
    //通知改变队伍名称
    void on_change_team_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_change_team_name &jpk_);
    //请求穿/脱装备
    void on_req_wear_equip(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_wear_equip_t& jpk_);
    //请求强化装备
    void on_req_equip_upgrade(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upgrade_equip_t& jpk_);
    //请求开启镶嵌槽
    void on_req_open_gemstore_slot(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_slot_open_t& jpk_);
    //请求宝石镶嵌
    void on_req_gemstone_inlay(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_inlay_t& jpk_);
    //请求宝石合成
    void on_req_gemstone_compose(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_compose_t& jpk_);
    //请求宝石一键镶嵌
    void on_req_gemstone_inlay_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_inlay_all_t& jpk_);
    //请求宝石一键合成
    void on_req_gemstone_syn_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gemstone_syn_all_t& jpk_);
    //请求装备合成
    void on_req_equip_compose(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_equip_t& jpk_);
    //请求装备合成
    void on_req_equip_compose_by_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_equip_yb_t& jpk_);
    //请求宝石页信息
    void on_req_gem_page_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gem_page_info_t& jpk_);

    //请求伙伴或者角色升阶
    void on_req_upquality(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_quality_up_t& jpk_);
    //请求刷新酒馆
    void on_req_pub_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_flush_t& jpk_);
    //请求获取免费时间
    void on_req_pub_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_time_t& jpk_);
    // 请求招募信息
    void on_req_enter_pub(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_pub_t& jpk_);
    //获取当天的限时金色英雄碎片
    //void on_req_gold_chip(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gold_chip_t &jpk_);

    //请求雇佣伙伴
    void on_req_hire_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hire_partner_t& jpk_);
    //请求体力增长
    void on_req_gen_power(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_power_t &jpk_);
    //请求活力增长
    void on_req_gen_energy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_energy_t &jpk_);
    //记录新手当前步骤
    void on_current_step_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_quit_step_t &jpk_);
    //请求离线经验
    void on_req_offline_exp(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_offline_exp_t &jpk_);
    //请求试炼场信息
    void on_req_trial_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_info_t &jpk_);
    //零点时，请求登录信息
    void on_req_login_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lg_rewardinfo_t &jpk_);
    //好友挑战
    void on_req_friend_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_battle_t &jpk_);
    //请求角色属性
    void on_req_role_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_role_pro_t &jpk_);
    //请求走马灯信息
    void on_req_maquee_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_maquee_info_t &jpk_);
    //接试炼场任务
    void on_req_trial_receive_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_receive_task_t &jpk_);
    //放弃试炼场任务
    void on_req_trial_giveup_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_giveup_task_t &jpk_);
    //刷新试炼场任务
    void on_req_trial_flush_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_flush_task_t &jpk_);
    //试炼场开始战斗
    void on_req_trial_start_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_start_batt_t &jpk_);
    //试炼场结束战斗
    void on_req_trial_end_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_end_batt_t &jpk_);
    //试炼场领取奖励
    void on_req_trial_rewards(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_rewards_t &jpk_);
    //刷新试炼场对手
    void on_req_trial_flush_targets(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_trial_flush_targets_t &jpk_);
    //技能升级
    void on_req_skill_upgrade(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upgrade_skill_t &jpk_);
    //技能升阶
    void on_req_skill_upnext(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_upnext_skill_t &jpk_);
    //请求其他用户信息
    void on_req_view_user_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_view_user_info_t &jpk_);
    //请求升级潜能
    void on_req_up_potential(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_potential_up_t &jpk_);
    //请求解雇伙伴
    void on_req_fire_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fire_partner_t &jpk_);
    //请求兑换灵能
    void on_req_chip_to_soul(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_to_soul_t &jpk_);

    //开始十二宫挂机
    void on_begin_zodiac_halt(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_auto_zodiac_t &jpk_);
    //获取十二宫挂机结果
    void on_req_zodiac_halt_result(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_auto_zodiac_resu_t &jpk_);
    //请求boss生死状态
    void on_req_boss_alive(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_alive_t &jpk_);
    void on_req_open_union_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_open_union_boss_t &jpk_);
    //请求进入boss场景
    void on_req_boss_enter_scene(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_state_t &jpk_);
    //请求boss战斗
    void on_req_boss_enter_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_start_batt_t &jpk_);
    void on_req_boss_exit_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_end_batt_t &jpk_);
    //请求伤害排名
    void on_req_boss_dmg_ranking(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_dmg_ranking_t &jpk_);
    //请求离开boss场景
    void on_req_boss_leave_scene(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_boss_leave_scene &jpk_);
    //请求竞技场信息
    void on_req_arena_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_info_t& jpk_);
    //请求开启星座图系统
    void on_req_star_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_open_t &jpk_);
    //请求刷新星座图系统
    void on_req_star_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_flush_t &jpk_);
    //请求设置星座图系统
    void on_req_star_set(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_set_t &jpk_);
    //请求获得星座图属性
    void on_req_star_get(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_star_get_t &jpk_);


    //请求挑战
    void on_req_begin_arena_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_arena_fight_t& jpk_);

    void on_req_end_arena_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_end_arena_fight_t& jpk_);

    //请求购买竞技场次数
    void on_req_arena_buy_count(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_fight_count_t &jpk_);
    
    //请求清除竞技场冷却时间
    void on_req_arena_clear_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_clear_time_t &jpk_);

    //请求竞技场页面
    void on_req_arena_rank_page(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_rank_page_t& jpk_); 

    //请求竞技场奖励
    void on_req_arena_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_reward_countdown_t& jpk_); 

    //请求测试
    void on_req_test_arena(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_test_arena_t& req_);

    //请求打开礼包
    void on_req_open_pack(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_open_pack_t& jpk_);

    //请求领取礼包
    void on_req_use_pack(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_use_pack_t& jpk_);

    //请求聊天
    void on_req_chart(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_chart_t &jpk_);
    //玩家上线获取离线期间产生的信封
    void on_req_mail_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mail_info_t &jpk_);
    //寻找好友
    void on_req_friend_search(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_search_t &jpk_);
    //寻找好友
    void on_req_friend_search_by_uid(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_search_uid_t &jpk_);
    //添加好友
    void on_req_friend_add(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_add_t &jpk_);
    //被加好友
    void on_req_friend_beenadd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_add_res_t &jpk_);
    //删除好友
    void on_req_friend_del(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_del_t &jpk_);
    //更换助战英雄
    void on_req_change_helphero(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_helpbattle_t &jpk_);
    //请求好友列表
    void on_req_friend_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_list_t &jpk_);
    //请求好友申请列表
    void on_req_friend_req_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_friend_addlist_t &jpk_);
    //送花
    void on_req_send_flower(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_send_flower_t &jpk_);
    //请求鲜花信息
    void on_req_flower_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_flower_list_t &jpk_);
    //请求接受鲜花
    void on_req_receive_flower(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_receive_flower_t &jpk_);
    //请求接受所有鲜花
    void on_req_receive_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_receive_all_t &jpk_);
    //请求训练场信息
    void on_req_practice_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_info_t &jpk_);
    //请求清除cd
    void on_req_practice_clear(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_clear_t &jpk_);
    //请求训练伙伴
    void on_req_practice_prac(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_practice_partner_t &jpk_);

    //请求任务列表
    void on_req_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_task_list_t& jpk_);
    //请求接取任务
    void on_req_get_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_task_t& jpk_);
    //请求提交任务
    void on_req_commit_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_task_t& jpk_);
    //请求放弃任务
    void on_req_abort_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_abort_task_t& jpk_);
    //请求完成的支线任务列表
    void on_req_finished_bline(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_finished_bline_t& jpk_);

    //请求日常任务列表
    //void on_req_daily_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_daily_task_list_t & jpk_);
    //请求提交日常任务
    //void on_commit_daily_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_daily_task_t& jpk_);
    //请求刷新日常任务
    //void on_req_buy_daily_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_daily_task_num_t& jpk_);

    //请求创建公会
    void on_req_create_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_create_gang_t& jpk_);
    //请求公会公会信息
    void on_req_gang_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_info_t& jpk_);
    //请求公会公会列表
    void on_req_gang_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_list_t& jpk_);
    //查找公会
    void on_req_search_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_search_gang_t& jpk_);
    //设置公会公告
    void on_req_set_notice(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_notice_t& jpk_);
    //设置公会留言
    void on_nt_gang_msg(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_gang_msg_t& jpk_);
    //设置公告官员
    void on_req_set_adm(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_adm_t& jpk_);
    //公会捐献
    void on_req_gang_pay(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_pay_t& jpk_); 
    //解散公会
    void on_req_close_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_close_gang_t& jpk_);
    //学习公会技能
    void on_req_learn_gskl(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_learn_gskl_t& jpk_);
    //获取公会技能列表
    void on_req_gskl_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gskl_list_t& jpk_);
    //请求加入公会
    void on_req_add_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_add_gang_t& jpk_);
    //请求公会申请列表
    void on_req_gang_reqlist(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_reqlist_t& jpk_);
    //请求公会成员列表
    void on_req_gang_mem(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_mem_t& jpk_);
    //处理公会申请
    void on_req_deal_gang_req(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_deal_gang_req_t& jpk_);
    //请求踢人
    void on_req_kick_mem(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_kick_mem_t& jpk_);
    //请求离开公会
    void on_req_leave_gang(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_leave_gang_t& jpk_);
    //请求公会献祭
    void on_req_gang_pray(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_pray_t& jpk_);
    //请求改变公会会长
    void on_req_change_charman(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_charman_t& jpk_);
    //请求进入祭祀 
    void on_req_enter_pray(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_pray_t &jpk_);
    //设置公会boss时间
    void on_req_set_gboss_time(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_gang_boss_time_t&jpk_);
    /*
    //请求公会boss信息
    void on_req_gang_boss_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gboss_info_t&jpk_);
    //请求公会boss排名
    void on_req_gang_boss_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gboss_rank_t&jpk_);
    //请求挑战公会boss
    void on_req_fight_gboss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gboss_fight_t&jpk_);
    */
    //吞噬符文
    //移动符文
    /*
    void on_req_rune_switch(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_switchpos_t &jpk_);
    //打开符文系统
    void on_req_rmonster_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_info_t &jpk_);
    //一键吞噬
    void on_req_rune_eatall(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_eatall_t &jpk_);
    //猎魔
    void on_req_rune_huntone(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_huntsome_t &jpk_);
    //召唤魔王
    void on_req_rune_callboss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_callboss_t &jpk_);
    //购买符文
    void on_req_rune_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_buy_t &jpk_);
    //关闭符文界面
    void on_nt_rune_close(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_close_t &jpk_);
    */

    //更新队伍属性数据
    void on_up_team_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::up_team_pro_t& jpk_);

    //商城
    void on_req_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_shop_items_t& jpk_);

    void on_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_shop_buy_t& jpk_);
    //购买金币
    void on_req_buy_coin(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_coin_t& jpk_);
    //出售
    void on_sell(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sell_t& jpk_);
    //道具购买
    void on_item_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_item_buy_t& jpk_);

    //npc商店
    void on_req_npcshop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npcshop_items_t& jpk_);
    //刷新商店
    void on_req_npc_shop_update(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npc_shop_update_t& jpk_);
    
    //npc商城
    //购买Npc商店商品
    void on_req_npc_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npc_shop_buy_t& jpk_);
    //npc商城购买物品
    void on_npc_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_npc_shop_buy_t& jpk_);
    void on_req_prestige_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_prestige_shop_items_t& jpk_);
    void on_req_prestige_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_prestige_shop_buy_t& jpk_);
    //请求碎片商店信息
    void on_req_chip_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_shop_items_t& jpk_);
    //请求购买碎片商店物品
    void on_req_chip_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_shop_buy_t& jpk_);
    //请求碎片拆分信息
    void on_req_chip_smash_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_smash_items_t& jpk_);
    void on_req_chip_smash_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chip_smash_buy_t& jpk_);
public:
    //角色被删除
    void on_role_deleted(int32_t uid_);
    
    //领取奖励，首次充值，累计充值，连续登录，累计登录
    void on_req_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reward_t &jpk_);
    //获取等级礼包
    void on_req_lv_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lv_reward_t &jpk_);
    //获取cdkey奖励
    void on_req_cdkey_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cdkey_reward_t &jpk_);


    //获取邀请码
    void on_req_invcode(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_t &jpk_);
    //设置邀请人
    void on_req_invcode_set(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_set_t &jpk_);
    //领取好友邀请奖励
    void on_req_invcode_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_invcode_reward_t &jpk_);
    
    //巨龙宝库进入战斗
    void on_req_treasure_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_enter_t &jpk_);
    //巨龙宝库离开战斗
    void on_req_treasure_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_exit_t &jpk_);
    //巨龙宝库一键登塔
    void on_req_treasure_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_pass_t &jpk_);
    //巨龙宝库占领空位
    void on_req_treasure_occupy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_occupy_t &jpk_);
    //巨龙宝库抢占坑位
    void on_req_treasure_fight(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_fight_t &jpk_);
    void on_req_treasure_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_fight_end_t &jpk_);
    //巨龙宝库抢占坑位
    void on_req_treasure_rob(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rob_t &jpk_);
    void on_req_treasure_rob_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rob_end_t &jpk_);
    //巨龙宝库请求某一层的信息
    void on_req_treasure_floor(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_floor_t &jpk_);
    //巨龙宝库放弃坑位
    void on_req_treasure_giveup(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_giveup_t &jpk_);
    //巨龙宝库收割坑位
    void on_req_treasure_getreward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_slot_rewd_t &jpk_);
    //到达零点的秒数
    void on_req_secs_to_zero(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_secs_to_zero_t &jpk_);
    //获取巨龙宝库战报
    void on_req_treasure_records(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_rcds_t &jpk_);
    //获取巨龙宝库复仇记录
    void on_req_treasure_revenge(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_revenge_t &jpk_);
    //巨龙宝库协守
    void on_req_treasure_help(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_help_t &jpk);

    //新手引导奖励伙伴
    void on_guidence_get_partner(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_partner_t &jpk_);
    //新手引导修改角色名
    void on_guidence_rename(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_rename_t &jpk_);
    //新手引导奖励宝石
    //void on_guidence_gemstone(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_gemstone_t &jpk_);
    //新手引导奖励精灵洗礼
    //void on_guidence_potential(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_potential_t &jpk_);

    //新手引导酒馆
    void on_guidence_pub(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guidence_pub_t &jpk_);
    //请求随机名字
    void on_req_random_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_random_name_t &jpk_);
    //记录新手引导相关功能点
    void on_nt_function(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_function_t &jpk_);


    //请求陌生人列表
    void on_req_stranger_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_helphero_stranger_t &jpk_);

    //请求排名奖励
    // void on_req_rank_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rank_reward_t&jpk_);
    //请求领取排名奖励
    // void on_req_given_rank_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_rank_reward_t&jpk_);
    //请求领取体力奖励
    void on_req_given_power_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_power_reward_t& jpk_);
    //请求领取体力倒计时
    void on_req_power_reward_cd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reward_power_cd_t& jpk_);
    //请求领取vip奖励
    void on_req_given_vip_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_given_vip_reward_t& jpk_);
    //请求vip购买信息
    void on_req_buy_vip_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_vip_info_t& jpk_);
    //请求购买体力
    void on_req_buy_power(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_power_t& jpk_);
    //请求购买活力
    void on_req_buy_energy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_energy_t& jpk_);
    //请求在线奖励cd
    void on_req_online_reward_cd(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_cd_t& jpk_);
    //请求在线奖励
    void on_req_online_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_t& jpk_);
    //请求在线奖励Id
    void on_req_online_reward_num(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_online_reward_num_t& jpk_);
    //请求离开游戏
    void on_req_quit_game(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_quit_game_t& jpk_);
    //请求登陆元宝奖励
    void on_req_login_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_login_yb_t& jpk_);

    //请求购买yb
    void on_req_buy_yb(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_yb_t& jpk_);
    //请求支付表
    void on_req_pay_repo(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pay_repo_t& jpk_);
    //通知支付完成
    void on_payed(uint32_t uid_, uint32_t serid_);

    //请求购买背包
    void on_req_buy_bag_cap(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_bag_cap_t& jpk_);

    //开始普通关卡
    void on_req_round_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_enter_t& jpk_);
    //结束普通关卡
    void on_req_round_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_exit_t& jpk_);
    //开始精英关卡
    void on_req_elite_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_elite_enter_t& jpk_);
    //结束精英关卡
    void on_req_elite_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_elite_exit_t& jpk_);
    //请求重置精英关卡次数
    void on_req_reset_elite(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_reset_elite_t& jpk_);
    //开始黄道十二宫
    void on_req_zodiac_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_enter_t& jpk_);
    //结束黄道十二宫
    void on_req_zodiac_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_exit_t& jpk_);
    //自动黄道十二宫
    void on_req_zodiac_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_zodiac_pass_t& jpk_);
    //刷新关卡
    void on_req_round_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_flush_t& jpk_);
    //普通关卡挂机
    void on_req_round_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_t& jpk_);
    //普通关卡挂机
    void on_req_round_pass_new(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_new_t& jpk_);
    //清除普通关卡挂机cd
    void on_req_clear_round_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_round_pass_clear_cd_t& jpk_);
    //清除英雄迷窟挂机cd
    void on_req_clear_cave_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_pass_clear_cd_t& jpk_);

    //开始英雄迷窟
    void on_req_cave_enter(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_enter_t& jpk_);
    //结束英雄迷窟
    void on_req_cave_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_exit_t& jpk_);
    //英雄迷窟挂机
    void on_req_cave_pass(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_pass_t& jpk_);
    //刷新关卡
    void on_req_cave_flush(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cave_flush_t& jpk_);

    //杀星城市boss
    void on_req_city_boss_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_city_boss_info_t& jpk_);
    void on_req_fight_city_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fight_city_boss_t& jpk_);
    void on_req_begin_fight_city_boss(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_begin_fight_city_boss_t& jpk_);

    //请求图纸合成
    void on_req_compose_drawing(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_compose_drawing_t& jpk_);
    
    //乱斗场报名
    void on_req_scuffle_prepare(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_regist_t & jpk_);
    //请求离开乱斗场
    void on_req_scuffle_exit(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_leave_scene & jpk_);
    //乱斗场进入战斗
    void on_req_scuffle_battle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_battle_t &jpk_);
    //乱斗场离开战斗
    void on_req_scuffle_battle_end(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_battle_end_t &jpk_);
    //乱斗场请求积分排名
    void on_req_scuffle_score(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_ranking_t &jpk_);
    //乱斗场请求是否开放
    void on_req_scuffle_state(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_state_t &jpk_);
    //乱斗场请求领奖
    //void on_req_scuffle_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_scuffle_reward_t &jpk_);
    
    //请求领取累计登录30天奖励
    void on_req_sign_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cumulogin_reward_t &jpk_);
    //请求战斗力排名
    void on_req_fp_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fp_rank_t &jpk_);
    void on_req_pub_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pub_rank_t &jpk_);
    //请求等级排名
    void on_req_lv_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lv_rank_t &jpk_);
    //请求同步战力
    void on_req_sync_fp(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sync_fp_t &jpk_);
    //请求同步战力
    void on_req_arena_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_rank_t &jpk_);

    //请求关卡星级奖励
    void on_req_starreward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_starreward_t& jpk_);
    void on_req_starreward_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_starreward_info_t& jpk_);

    //test游戏内购
    void on_req_test_pay(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_pay_t& jpk_);
    //测试两个角色pk结果
    void on_req_test_fight(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_fight_test_t& jpk_);
    //测试将一个用户数据过期
    void on_req_overdue(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_overdue_t& jpk_);
    //测试关卡的掉落概率
    void on_req_test_round_drop(uint64_t seskey_, sp_rpc_conn_t conn_, test_msg_def::req_round_drop_t& jpk_);

    //测试
    void on_req_login_async(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_login_t& jpk_);
    void on_logined(sp_user_t user);

    //gm工具接口
    void on_expel(sp_rpc_conn_t conn_, inner_msg_def::nt_expel_t& jpk_);
    void on_notalk(inner_msg_def::nt_notalk_t& jpk_);
    void on_gm_mail(inner_msg_def::nt_gm_mail_t& jpk_);
    void on_compensate(inner_msg_def::nt_compensate_t& jpk_);
    //@scene end

    //宝箱操作
    //请求打开宝箱
    void on_req_use_item(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_use_item_t& jpk_);

    //请求月卡奖励信息
    void on_req_mcard_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mcard_info_t& jpk_);
    //领取月卡奖励
    void on_req_mcard_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_mcard_reward_t& jpk_);
    //领取战斗力冲刺奖励
    void on_req_fp_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fp_reward_t &jpk_);
    //领取累计消费奖励
    void on_req_cumu_yb_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_cumu_yb_reward_t &jpk_);
    //领取每日充值奖励
    void on_req_daily_pay_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_daily_pay_reward_t& jpk_);
    //累计消费排行榜
    void on_req_cumu_yb_rank(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_cumu_yb_rank_t& jpk_);


    //邮箱
    void on_req_mail_list(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_list_t& jpk_);  
    void on_req_mail_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_reward_t& jpk_);  
    void on_nt_mail_reaeded(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_gmail_readed_t& jpk_);
    void on_nt_mail_delete(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_delete_gmail_t& jpk_);
    void on_gm_gmail(const vector<int>& uids_, const string& msg_);
    void on_req_mail_delete(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_delete_t& jpk_);   
    void on_req_mail_allreward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gmail_getallreward_t& jpk_);  
    //新日常任务
    void on_req_act_task(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_act_task_t& jpk_);
    void on_req_act_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_act_reward_t& jpk_);
    //成就任务
    void on_req_achievement_task(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_achievement_task_t& jpk_);
    void on_req_achievement_reward(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_achievement_reward_t& jpk_);


    //通知twoprecord
    void on_nt_twrecordop(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::nt_twoprecrod_t& jpk_);

    //请求领红包
    void on_req_hongbao(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hongbao_t& jpk_);
    //请求鼓舞
    void on_req_guwu(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_guwu_t& jpk_);
    //请求复活
    void on_req_fuhuo(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_fuhuo_t& jpk_);

    //请求打开限时副本
    void on_req_limit_round(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_round_t& jpk_);
    //限时副本结果
    void on_req_limit_result(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_quit_t& jpk_);
    //属性副本清除CD
    void on_req_limit_round_clear_cd(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_clear_lmt_cd& jpk_);
    //请求十二宫当前id
    void on_req_zodiacid(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_zodiacid_t& jpk_);
    //请求限时副本数据
    void on_req_limit_round_data(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_limit_round_data &jpk_);
    //重置挑战次数
    void on_req_reset_limit_round_times(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_reset_limit_round_times &jpk_);

    //请求装备翅膀
    void on_req_wear_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_wear_wing_t& jpk_);
    //请求合成翅膀
    void on_req_compose_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_compose_wing_t& jpk_);

    //请求翅膀抽签
    void on_req_gacha_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_gacha_wing_t& jpk_);
    //请求领取积分翅膀
    void on_req_get_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_get_wing_t& jpk_);
    //请求翅膀排名
    void on_req_wing_rank(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_wing_rank_t& jpk_);
    //请求出售翅膀
    void on_req_sell_wing(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_sell_wing_t& jpk_);

    //请求升级宠物
    void on_req_compose_pet(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_compose_pet_t& jpk_);

    //请求编年史信息
    void on_req_chronicle(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_t& jpk_);
    //请求完成当日编年史任务
    void on_req_chronicle_sign(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_t& jpk_);
    //编年史记录找回
    void on_req_chronicle_sign_retrieve(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_retrieve_t& jpk_);
    //请求所有编年史签到记录
    void on_req_chronicle_sign_all(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chronicle_sign_all_t &jpk_);

    //请求所有卡牌爱恋度任务
    void on_req_love_task_list(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_love_task_list_t& jpk_);
    //请求完成卡牌爱恋度任务
    void on_req_commit_love_task(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_commit_love_task_t& jpk_);
    
    //请求领取每日签到奖励
    void on_req_sign_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_reward_t& jpk_);
    //请求每日签到相关信息
    void on_req_sign_daily(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_daily_t& jpk_);
    //请求补签签到
    void on_req_sign_remedy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sign_remedy_t& jpk_);

    void on_req_expedition(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_t& jpk_);
    void on_req_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_round_t& jpk_);
    void on_req_enter_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_expedition_round_t& jpk_);
    void on_req_exit_expedition_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_exit_expedition_round_t& jpk_);
    void on_req_expedition_team(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_team_t& jpk_);
    void on_nt_expedition_team_change(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_expedition_team_change_t& jpk_);
    void on_req_expedition_round_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_round_reward_t& jpk_);
    void on_req_expedition_partners(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_partners_t& jpk_);
    void on_req_expedition_reset(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_reset_t& jpk_);
    void on_req_expedition_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_shop_items_t& jpk_);
    void on_req_expedition_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_expedition_shop_buy_t& jpk_);
    void on_req_gang_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_shop_items_t& jpk_);
    void on_req_gang_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gang_shop_buy_t& jpk_);
    void on_req_rune_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_shop_items_t& jpk_);
    void on_req_rune_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_rune_shop_buy_t& jpk_);
    void on_req_cardevent_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cardevent_shop_items_t& jpk_);
    void on_req_cardevent_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_cardevent_shop_buy_t& jpk_);
    void on_req_lmt_shop(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lmt_shop_items_t& jpk_);
    void on_req_lmt_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_lmt_shop_buy_t& jpk_);

    void on_req_expedition_pass_round(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_sweep_expedition_t& jpk_);


    //请求弹幕
    void on_bullet_list(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_bullet_t& jpk_);
    //请求发送弹幕
    void on_send_bullet(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_send_bullet_t& jpk_);
    //请求公会排行榜信息
    void on_req_union_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_union_rank_t& jpk_);
    //请求卡牌排行榜信息
    void on_req_card_rank(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_card_rank_t& jpk_);

    //请求卡牌排行榜信息
    void on_req_naviClickNum_add(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_naviClickNum_add_t& jpk_);

    //请求记录新手引导状态
    void on_req_write_guidence(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_write_guidence_t& jpk_);
    //宝库重置
    void on_req_treasure_reset(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_reset_t& jpk_);
    //改名功能
    void on_req_change_name(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_name_t& jpk_);
    void on_req_card_comment(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_comment_card_t& jpk_);
    void on_req_newest_card_comment(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_newest_card_comment_t& jpk_);
    //请求某个角色属性信息
    void on_get_index_role_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_index_role_info_t &jpk_);
    //点赞
    void on_req_praise(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_praise_comment_t &jpk_);
    //福袋
    void on_req_luckybag_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_luckybag_reward_t &jpk_);
    //pve战斗失败次数
    void on_req_pvelose_times(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_pvelose_times_t &jpk_);
    //请求获得周礼包奖励
    void on_req_get_weekly_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_weekly_reward_t &jpk_);
    void on_req_get_online_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_online_reward_t &jpk_);
    void on_req_set_kanban_role(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_set_kanban_role_t& jpk_);
    //钻石十连奖励
    void on_req_get_open_service_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_get_open_service_reward_t& jpk_);
    void on_req_buy_growing_package(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_buy_growing_package_t& jpk_);
    //探宝放弃协守去占领
    void on_req_treasure_give_occupy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_give_occupy_t &jpk_);
    //探宝放弃协守
    void on_req_treasure_giveup_help(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_treasure_giveup_help_t &jpk_);
    //请求竞技场冷却时间
    void on_req_arena_cool_down(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_arena_cool_down_t& jpk_);
    //请求离线聊天消息
    void on_req_chat_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_chat_info_t& jpk_);

    /* 卡牌活动 */
    void on_req_card_event_open_round(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_open_round_t& jpk_);
    void on_req_card_event_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_fight_t& jpk_);
    void on_req_card_event_round_exit(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_round_exit_t& jpk_);
    void on_req_card_event_reset(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_reset_t& jpk_);
    void on_nt_card_event_change_team(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::nt_card_event_change_team_t& jpk_);
    void on_req_card_event_round_enemy(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_round_enemy_t& jpk_);
    void on_req_card_event_revive(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_revive_t& jpk_);
    void on_req_card_event_rank(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_card_event_rank_t& jpk_);
    void on_req_card_event_sweep(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_card_event_sweep_t& jpk_);
    void on_req_card_event_next(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_next_card_event_t& jpk_);
    void on_req_card_event_first_enter(uint64_t seskey_, sp_rpc_conn_t conn_,sc_msg_def::req_card_event_first_enter_t& jpk_);
    
    /* 晶魂 */
    void on_req_get_soul_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_get_soul_info_t& jpk_);
    void on_req_hunt_soul(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_hunt_soul_t& jpk_);
    void on_req_rankup_soul(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_rankup_soul_t& jpk_);
    void on_req_get_soul_reward(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_get_soul_reward_t& jpk_);

    /* 赛季排位 */
    void on_req_rank_season_match(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_rank_season_match_t& jpk_);
    void on_req_rank_season_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_rank_season_info_t& jpk_);
    void on_req_rank_seson_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_rank_seson_fight_end_t& jpk_);
    void on_req_cancel_rank_season_wait(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_cancel_rank_season_wait_t& jpk_); 
    void on_req_begin_rank_match_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_begin_rank_match_fight_t& jpk_);

    /* 公会战 */
    void on_req_guild_battle_state(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_state& jpk_);
    // 报名
    void on_req_guild_battle_sign_up(uint64_t seskey_, sp_rpc_conn_t conn_, 
        sc_msg_def::req_guild_battle_sign_up& jpk_);
    // 布阵
    void on_req_guild_battle_defence_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_defence_info& jpk_);
    void on_req_guild_battle_whole_defence_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_whole_defence_info& jpk_);
    void on_req_guild_battle_defence_pos_on(uint64_t seskey_, sp_rpc_conn_t conn_, 
        sc_msg_def::req_guild_battle_defence_pos_on& jpk_);
    void on_req_guild_battle_defence_pos_off(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_defence_pos_off& jpk_);
    void on_req_guild_battle_cancel_other_pos(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_cancel_other_pos& jpk_);
    void on_req_guild_battle_building_level_up(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_building_level_up& jpk_);
    // 战斗
    void on_req_guild_battle_whole_defence_info_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_whole_defence_info_fight& jpk_);
    void on_req_guild_battle_defence_info_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_defence_info_fight& jpk_);
    void on_req_guild_battle_fight(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_fight& jpk_);
    void on_req_guild_battle_fight_end(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_fight_end& jpk_);
    void on_req_guild_battle_fight_record_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_fight_record_info& jpk_);
    void on_req_guild_battle_fight_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_fight_info& jpk_);
    void on_req_guild_battle_buy_fight_times(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_buy_fight_times& jpk_);
    void on_req_guild_battle_clear_fight_cd(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_clear_fight_cd& jpk_);
    void on_req_guild_battle_spy(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_spy& jpk_);
    // 全局
    void on_req_guild_battle_guild_info(uint64_t seskey_, sp_rpc_conn_t conn_,
        sc_msg_def::req_guild_battle_guild_info& jpk_);
    
    //请求更换主角
    void req_change_roletype(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_roletype_t& jpk_);
    //请求开启魂师
    void req_soulnode_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_soulnode_open_t& jpk_);
    //请求魂师加长
    void req_soulnode_pro(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_soulnode_pro_t& jpk_);

    //请求种子商店信息
    void on_req_plant_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_plant_shop_items_t& jpk_);
    //请求购买种子商店物品
    void on_req_plant_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_plant_shop_buy_t& jpk_);


    //请求库存商店信息
    void on_req_inventory_shop_items(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_inventory_shop_items_t& jpk_);
    //请求购买库存商店物品
    void on_req_inventory_shop_buy(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_inventory_shop_buy_t& jpk_);
    
    void on_req_opentask_info(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_opentask_info_t& jpk_);
    void on_req_opentask_reward(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_opentask_reward_t& jpk_);

    // 请求开启珍宝
    void on_req_combo_pro_open(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_combo_pro_open_t& jpk_);
    // 请求升级珍宝
    void on_req_combo_pro_levelup(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_combo_pro_levelup_t& jpk_);

    // 请求举报
    void on_req_report(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_report_t& jpk_);

    // 请求进入符文猎取界面
    void on_req_enter_rune_hunt_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_enter_rune_hunt_t& jpk_);
    // 请求猎取符文
    void on_req_hunt_rune_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_hunt_rune_t& jpk_);
    // 通知离开符文猎取界面
    void on_req_leave_rune_hunt_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::nt_leave_rune_hunt_t& jpk_);
    // 请求镶嵌符文
    void on_req_new_rune_inlay_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_inlay_t& jpk_);
    // 请求卸下符文
    void on_req_new_rune_unlay_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_unlay_t& jpk_);
    // 请求升级符文
    void on_req_new_rune_levelup_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_levelup_t& jpk_);
    // 请求突破符文
    void on_req_new_rune_compose_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_compose_t& jpk_);
    // 请求激活伙伴符文
    void on_req_new_rune_active_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_new_rune_active_t& jpk_);

    // 请求获取公告
    void on_req_announcement_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_announcement_t& jpk_);
    
    // 请求生成继承码
    void on_req_gen_inheritance_code_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_gen_inheritance_code_t& jp_);

    // 请求主城形象
    void on_req_model_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_model_t& jp_);
    // 更改主城形象
    void on_req_change_model_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_change_model_t& jp_);
    
    // 领取vip经验
    void on_req_vip_exp_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_vip_exp_t& jpk_);
    //请求聊天内容
    void on_req_private_chat_info_t(uint64_t seskey_, sp_rpc_conn_t conn_, sc_msg_def::req_private_chat_info_t& jpk_);
public:
    void handle_time(int sec_);
    void updateshop();
public:
    void handle_invcode_msg(uint16_t cmd_, const string& msg_);

    template<class T>
    void send_invcode_msg(T& msg_)
    {
        string out;
        msg_ >> out;
        sc_service.send_invcode_msg(T::cmd(), out);
    }
public:
    sc_session_t     session;
private:
    sp_user_t getuid(uint64_t seskey_);
    void compensate(sp_user_t user);
    void update_maqee();
private:
    sc_lua_t*        m_lua;
    sc_user_mgr_t*   m_user_mgr;
    sc_city_mgr_t*   m_city_mgr;
    vector<int32_t>  m_hosts;
    int              m_maquee_time;
};

#define logic (singleton_t<sc_logic_t>::instance())

#endif
