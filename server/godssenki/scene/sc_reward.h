#ifndef _sc_reward_h_
#define _sc_reward_h_

#include "invcode_msg_def.h"
#include "msg_def.h"
#include "db_ext.h" 


enum reward_t
{
    first_yb = 101,        //首次充值
    acc_yb1 = 201,         //累计充值
    acc_yb2,
    acc_yb3,
    acc_yb4,
    acc_yb5,
    acc_yb6,
    acc_yb7,
    con_lg1 = 301,      //连续登录
    con_lg2,
    con_lg3,
    con_lg4,
    con_lg5,
    acc_lg1 = 401,      //累计登录
    acc_lg2,
    acc_lg3,
    acc_lg4,
    acc_lg5,
    acc_lg6,
    acc_lg7,
    acc_lg8,
    acc_lg9,
    acc_lg10,
    acc_lg11,
    acc_lg12,
    acc_lg13,
    acc_lg14,
    acc_lg15,
    acc_lg16,
    acc_lg17,
    acc_lg18,
    acc_lg19,
    acc_lg20,
    acc_lg21,
    acc_lg22,
    acc_lg23,
    acc_lg24,
};

enum activity_t
{
    activity_free_flush_round = 1,   //副本福利
};

enum open_task_t
{
    open_task_equip_lv = 1,                     //装备强化至25级
    open_task_arena_num = 2,                    //竞技场次数
    open_task_cardevent_pass = 3,               //活动任意难度通过
    open_task_expedition_allnum = 4,         //远征通关最高关
    open_task_rank_winnumber = 5,           //排位赛获胜次数
    open_task_equip_advnum = 6,                 //装备进阶次数
    open_task_soul_num = 7,                     //熔炼次数
    open_task_limitround_num = 8,               //属性副本挑战次数
    open_task_talent_num = 9,                   //天赋刷新
    open_task_gem_count = 10,                    //装备魂器数量
    open_task_treasure_round = 11,               //探宝挑战关数
    
    open_task_expedition_num = 12,           //远征通关次数
    open_task_rank_grade = 13,               //排位赛达到段数
    open_task_rank_count = 14,               //排位赛战斗次数
    open_task_expedition_round = 15,        //远征通过总关数
    open_task_cardevent_num = 16,                //活动累计通过关数
    open_task_cardevent_grade =17,              //活动达到某难度
    open_task_equip_num = 18,                    //装备强化次数
};

class sc_user_t;
class sc_reward_t
{
public:
    db_Reward_ext_t db;
    db_RewardExtentionI_ext_t db_ext;
private:
    typedef boost::shared_ptr<db_RoundStarReward_ext_t> sp_sr_t;
    int get_month_delta();
public:
    bool is_activity_open(int32_t activity_type_);
    sc_reward_t(sc_user_t& user_);
    void init_db();
    void load_db();
    void async_load_db();
    void save_db();
    void save_db_ext();
    string update_sevenpayreward();
    string update_limit_sevenpay();
    void on_login();
    void change_expedition_state(int32_t newState);
    int get_expedition_state();
    bool isInDoubleActivity(int doubleActivityCode);
    uint32_t str2stamp(string str); 
    void clear_lmt_draw_data();
    void clear_lmt_wing_data();
    void clear_lmt_power_data();
    void clear_lmt_luckybag_data();
    void clear_lmt_recharge_data();
    void clear_lmt_melting_data();
    void clear_lmt_talent_data();
    void get_jpk(sc_msg_def::jpk_reward_data_t& data_);
    int32_t buy_growing_package(string &str);
    void refresh_growing_reward_status(string &str); 
    void get_login_jpk(sc_msg_def::ret_lg_rewardinfo_t& data_);
    void cast_login(int32_t flag_);
    void cast_yb(int slience_=0);
    int32_t get_reward(int32_t flag_, int32_t &dismess_);
    void put_reward(int32_t flag_);
    int unicast_rank_reward();
    void update_rank_reward(int rank_);
    int given_rank_reward();
    void get_invcode();
    void handle_get_invcode(invcode_msg::ret_code_t &ret_);
    void set_inviter(string &invcode_);
    void handle_set_inviter(int code_,int uid_);
    void invitee_upgrade(int32_t grade_);
    int get_inviter();
    void get_invcode_reward_info();
    void handle_get_invcode_reward_info(int r1_,int r2_,int r3_,int r4_);
    void get_invcode_reward(int32_t flag_);
    int given_power();
    int reward_power_cd();
    void on_vip_upgrade(int viplevel_,int slience_=0);
    int given_vip_reward(int viplevel_);
    int get_online_reward_cd();
    int get_online_reward(int& resid_);
    int get_online_reward_num(int& resid_);
    int given_login_yb(vector<sc_msg_def::jpk_item_t> &ret_);
    int isinvited();
    int given_starreward(int id_, int starnum_);
    int unicast_starreward_info(int id_);
    void get_lv_reward(int32_t lv_);
    void get_cdkey_reward(string cdkey_);
    void get_cumulogin_reward(int32_t lv_);
    int nt_mcard_info();
    int get_mcardn(int& contain_);
    int given_mcard_reward();
    void update_wingselected(int32_t pos_);
    int32_t update_wingactivityreward(int32_t index_);
    void get_fp_reward(int32_t pos_);
    void get_cumu_yb_reward(int32_t pos_);
    void update_daily_pay();
    void update_single_pay();
    void update_daily_consume_power();
    void update_daily_draw();
    void update_daily_melting();
    void update_daily_talent();
    void get_daily_pay_reward(int32_t pos_);
    void on_twoprecord_done(int op_);
    void given_vip_package(int viplevel_);
    bool isInOpenTime();
    void update_recharge_activity(int rmb_);
    void update_single_activity(int rmb_);
    void update_limit_pub_activity(int count_);
    void update_melting_activity(int num_);
    void update_talent_activity(int num_);
    void get_lmt_date(sc_msg_def::jpk_lmt_event_t &jpk_, int index_);
    void get_weekly_info(vector<sc_msg_def::jpk_weekly_reward_t> &reward_info_);
    void get_online_info(vector<sc_msg_def::jpk_online_reward_t> &reward_info_);
    int32_t get_pvelose_times(int32_t &times_);
    int32_t get_online_reward_pack(int32_t id, int32_t &online_, int32_t &cd_);
    int32_t get_weekly_reward(int32_t id, int32_t &reward_state);
    void get_activity_date(sc_msg_def::jpk_lmt_event_t &jpk_, int index_);
    void update_limit_activity_wing(int32_t pos_);
    void update_limit_activity_power(int32_t power_, int32_t &is_in_activity, string &str, int32_t &consume_power_);
    void consume_daily_power(int32_t power_);
    void daily_melting_num(int32_t num_);
    void daily_talent_num(int32_t num_);
    void daily_draw_num(int32_t num_);
    int get_limit_reward(int32_t pos_);
    void get_lucky_bag_date(sc_msg_def::jpk_lmt_event_t &jpk_);
    void get_luckybag_reward(int32_t pos_);
    void update_openybtotal(int32_t yb_);
    int get_openyb_reward(int32_t pos_);
    void update_openyb_info(); 
    //开服任务相关
    bool isinOpenTaskTime();
    void get_open_task_info();
    void update_opentask(int32_t index_);
    void get_opentask_reward();
    void update_sevenpay_info();
    void update_vip_exp();
    int32_t get_vip_days();
    int32_t get_vip_stamp();
private:
    int save_sr_db(sp_sr_t sp_sr_);
    int load_starreward();
    int async_load_starreward();
    void set_lg_rewards(int32_t days);
private:
    sc_user_t&                      m_user;
    int*                            m_vips[18];
    int*                            m_acclgs[24];
    uint32_t                        m_online_stamp;
    map<int, sp_sr_t>               m_sr_map;
    int                             m_is_first_login;
};

//[uid][stamp]
typedef unordered_map<int32_t, uint32_t> login_yb_hm_t;
#define login_yb_hm (singleton_t<login_yb_hm_t>::instance())


#endif
