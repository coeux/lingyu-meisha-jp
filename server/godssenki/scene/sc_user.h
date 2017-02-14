#ifndef _sc_user_h_
#define _sc_user_h_

#include <boost/shared_ptr.hpp>

#include <unordered_map>
#include <string>
using namespace std;

#include "db_ext.h"
#include "repo_def.h"
#include "msg_def.h"

#include "sc_bag.h"
#include "sc_equip.h"
#include "sc_partner.h"
#include "sc_skill.h"
#include "sc_pro.h"
#include "sc_item.h"
#include "sc_team.h"
#include "sc_round.h"
#include "sc_new_round.h"
#include "sc_arena.h"
#include "sc_friend.h"
#include "sc_friend_flower.h"
#include "sc_practice.h"
#include "sc_task.h"
#include "sc_act_daily_task.h"
//#include "sc_rune.h"
#include "sc_new_rune.h"
#include "sc_cache_data.h"
#include "sc_vip.h"
#include "sc_reward.h"
#include "sc_treasure.h"
#include "sc_star.h"
#include "sc_shop.h"
#include "sc_gmail.h"
#include "sc_guwu.h"
#include "sc_wing.h"
#include "sc_chronicle.h"
#include "sc_love_task.h"
#include "sc_sign.h"
#include "sc_card_event.h"
#include "sc_soul.h"
#include "sc_achievement.h"
#include "sc_soulrank.h"
#include "sc_chip_smash.h"
#include "sc_farm.h"
#include "sc_guild_battle.h"
#include "sc_gem_page.h"
#include "sc_pet.h"
#include "sc_combo_pro.h"
#include "sc_report.h"
#include "sc_pub_mgr.h"

class sc_user_t
{
public:
    db_UserInfo_ext_t           db;
    db_Gang_t                dbGong;
    sc_bag_t                bag;
    sc_skill_mgr_t          skill_mgr;
    sc_equip_mgr_t          equip_mgr;     
    sc_partner_mgr_t        partner_mgr;
    sc_item_mgr_t           item_mgr;
    sc_friend_mgr_t         friend_mgr;
    sc_friend_flower_t      friend_flower_mgr;
    //sc_rune_mgr_t           rune_mgr;
    sc_rune_page_t          new_rune_mgr;
    sc_round_t              round;
    sc_new_round_t          new_round;
    sc_expedition_t         expedition;
    sc_arena_t              arena;
    sc_practice_t           practice;
    sc_task_mgr_t           task;
    sc_act_daily_task_t     daily_task;
    sc_vip_t                vip;
    sc_reward_t             reward;
    sc_treasure_t           treasure;
    sc_star_mgr_t           star_mgr;               
    sc_shop_t               shop;
    sc_expeditionshop_mgr_t expeditionshop_mgr;
    sc_gang_shop_mgr_t      gangshop_mgr;
    sc_rune_shop_mgr_t      runeshop_mgr;
    sc_cardevent_shop_mgr_t cardeventshop_mgr;
    sc_lmt_shop_mgr_t lmtshop_mgr;
    sc_prestige_shop_t      prestigeshop;
    sc_chip_shop_t          chipshop;
    sc_plant_shop_t         plantshop;
    sc_inventoryshop_t     inventoryshop;
    //sc_homebuilding_mgr_t   homebuilding;
    sc_chip_smash_t          chipsmash;
    sc_gmail_mgr_t          gmail;
    sc_wing_mgr_t           wing;
    sc_chronicle_mgr_t      chronicle;
    sc_love_task_mgr_t      love_task;
    sc_team_mgr_t           team_mgr;
    sc_sign_t               sign_daily;
    sc_card_event_user_t    card_event;
    sc_soul_t               soul;
    sc_achievement_t        achievement;
    sc_soulrank_mgr_t       soulrank_mgr;
    sc_guild_battle_user_t  guild_battle_mgr;
    sc_gem_page_t           gem_page_mgr;
    sc_pet_mgr_t            pet_mgr;
    sc_combo_pro_t          combo_pro_mgr;
    sc_report_t             report_mgr;
    sc_pub_mgr_t            pub_mgr;
    
    map<int32_t, int32_t>   equip_solt;
    sc_pro_t                pro;

    uint32_t                last_gen_energy;
    uint32_t                login_time;
    uint32_t                counttime;
    string                  mac;
    string                  plat_name;
    string                  plat_domain;
    int                     sys;
    string                  device;
    string                  os;
    bool                    is_overdue;
    int                     current_step;
    uint32_t                lastsceneid;
    uint32_t                city_boss_id;
    int32_t                 pay_rmb;
    bool                    notalk;
    int                     m_fight_boss_time;
private:
    void get_jpk_role_data(sc_msg_def::jpk_role_data_t &urole);
    void get_jpk_view_data(sc_msg_def::jpk_view_role_data_t &urole);
    void get_jpk_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &urole);
    void get_jpk_gbattle_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_, int32_t pos_);
public:
    sc_user_t();
public:
    static int get_equip_level(int32_t uid_, int32_t pid_);
    void get_index_role_info(sc_msg_def::jpk_role_data_t &urole);
    sp_helphero_t get_helphero();
    sp_view_user_t get_view();
    sp_view_user_other_t get_view_others();
    sp_view_user_t get_view(int32_t tid_);
    sp_view_user_t get_view(int32_t* pid_);
    sp_fight_view_user_t get_fight_view(int32_t* pid_);
    sp_fight_view_user_t get_rank_view(int32_t* pid_);
    sp_fight_view_user_t get_gbattle_fight_view(int32_t* pid_);
    sp_baseinfo_t get_frd_info();
    bool load_db(int32_t uid_);
    void save_db();
    void init_new_user(const db_UserID_t& userid_); 
    int get_user_jpk(sc_msg_def::ret_user_data_t& ret_);    
    int feedbackIsSend();
    void get_last_chat_role_info(vector<sc_msg_def::last_chat_role_info>& last_chat_info_);
    int get_pro_jpk(sc_msg_def::jpk_role_pro_t& jpk_);
    int rmb();
    int on_exp_change(int32_t exp_);
    void on_lovevalue_change(int32_t lovevalue);
    void compensate_grade(int32_t grade_, int test_ = 1);
    int on_money_change(int32_t money_);
    int on_runechip_change(int32_t runechip_);
    int on_freeyb_change(int32_t yb_);
    int on_allyb_change(int32_t payyb_, int32_t freeyb_);
    int on_payyb_change(int32_t yb_);
    void on_payed(int rmb_);
    int on_power_change(int32_t power_);
    int on_energy_change(int32_t energy_);
    int on_quality_change();
    int on_battlexp_change(int32_t battlexp_);
    int on_fpoint_change(int32_t fpoint_);
    int on_soul_change(int32_t soul_);
    int on_honor_change(int32_t honor_);
    int on_unhonor_change(int32_t honor_);
    int on_meritorious_change(int32_t meritorious_);
    int on_expeditioncoin_change(int32_t expeditioncoin_);
    int on_chronicle_sum_change(int32_t value_);
    int on_lovelevel_change(int32_t pid_);
    void on_change_help_hero(int32_t pid_);
    int cal_offline_interval();
    void cal_offline_exp();
    void gen_power(int32_t &seconds_left_, int32_t &power_);
    void gen_energy(int32_t &seconds_left_, int32_t &energy_);
    void on_login();
    void check_first_login();
    int32_t up_potential(int32_t flag_,int32_t &delata_,int32_t &current_, int32_t &attribute);
    void on_pro_changed(int pid_ = 0);
    void on_pro_changed_multiple(vector<int32_t>& pid_list_);
    int get_total_fp();
    int cal_total_fp();
    int get_max_5_fp();
    void on_team_pro_changed();
    int consume_gold(int gold_);
    int consume_yb(int yb_);
    int consume_expeditioncoin(int32_t expeditioncoin_);
    int fpoint();
    int honor();
    int unhonor();
    int meritorious();
    int consume_fpoint(int v_);
    int consume_honor(int v_);
    int consume_unhonor(int v_);
    bool db_has_changed();
    void save_db_userid();
    int on_guwu(int flag_, int yb_, int coin_);
    float get_guwu_v(int flag_);
    sc_guwu_t* get_guwu(int flag_);
    int update_guwu(int flag_, uint32_t b_, uint32_t e_);
    void remove_guwu(int flag_);
    void set_kanban_role(int32_t uid, int32_t resid, int32_t type);
    int get_open_service_reward(int32_t index);
    int change_roletype(int32_t roleindex);
    uint32_t str2stamp(string str);
    void get_jpk_rank_view_data(sc_msg_def::jpk_fight_view_role_data_t &urole, float num, int32_t pos_);
    int get_limit_round_data(sc_msg_def::ret_limit_round_data &ret_);
    int reset_limit_round_times(sc_msg_def::ret_reset_limit_round_times &ret_);
    void update_sign_info();
    void add_new_mail();
    int32_t gen_inheritance_code(sc_msg_def::ret_gen_inheritance_code_t& ret_);
    int32_t get_model(sc_msg_def::ret_model_t& ret_);
    int32_t change_model(sc_msg_def::ret_change_model_t& ret_, int32_t new_model_);
};

typedef boost::shared_ptr<sc_user_t> sp_user_t;

//[uid][sc_user_t]
class sc_user_mgr_t 
{
    typedef unordered_map<int32_t, sp_user_t> user_hm_t;
public:
    sc_user_mgr_t();
    void on_session_broken(int32_t uid_);

    bool has(const int32_t& uid_);
    bool get(const int32_t& uid_, sp_user_t& sp_user_);
    void insert(const int32_t& uid_, const sp_user_t& sp_user_) { m_user_hm.insert(make_pair(uid_, sp_user_)); }
    void erase(const int32_t& uid_) { m_user_hm.erase(uid_); }
    size_t size() const { return m_user_hm.size(); }
    void broadcast(int32_t cmd_,const string &msg_);
    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_user_hm.begin();it!=m_user_hm.end();++it)
        {
            fun_(it->second);
        }
    }
private:
    user_hm_t m_user_hm;
};

#endif
