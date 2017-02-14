#ifndef _SC_TREASURE_H_
#define _SC_TREASURE_H_

#include "msg_def.h"
#include "code_def.h"
#include "repo_def.h"
#include "singleton.h"
#include "db_ext.h"
#include "db_def.h"
#include "config.h"

#include <vector>
#include <map>
#include <set>
#include <stdint.h>

using namespace std;

class sc_user_t;
class sc_treasure_t
{
    typedef db_Treasure_ext_t treasure_t;
    typedef boost::shared_ptr<treasure_t> sp_treasure_t;
    typedef unordered_map<int32_t, sp_treasure_t> sp_treasure_hm_t; 
public:
    sc_treasure_t(sc_user_t &user_);
    void load_db();
    void save_db(sp_treasure_t& sp_treasure_);
    void update_treasure_reset_num(int32_t reset_times);
    int32_t get_reset_num();
    int32_t enter_round(int32_t resid_);
    int32_t exit_round(int resid_, int win_, string salt_);
    int32_t pass_round();
    int32_t occupy_blank(int32_t pos_);
    int32_t occupy_fight(int32_t pos_,int32_t uid_,sc_msg_def::ret_treasure_fight_t &ret);
    int32_t occupy_fight_end(sc_msg_def::req_treasure_fight_end_t &jpk_, sc_msg_def::ret_treasure_fight_end_t &ret);
    int32_t help(int32_t pos_);
    int32_t rob(int32_t pos_,int32_t uid_,sc_msg_def::ret_treasure_rob_t &ret);
    int32_t rob_end(sc_msg_def::req_treasure_rob_end_t &jpk_, sc_msg_def::ret_treasure_rob_end_t &ret);
    //int32_t get_jpk(int32_t floor_,vector<sc_msg_def::treasure_cli_slot_t> &ret);
    int32_t get_jpk(int32_t floor_, sc_msg_def::ret_treasure_floor_t &ret);
    void get_cur_floor(sc_msg_def::jpk_round_data_t &treasure_);
    void clear_state(){m_cur_rid=0;}
    int32_t giveup_slot(int32_t &left_secs_);
    int32_t get_reward(int32_t &m_or_t_);
    void unicast_records_info();
    void unicast_revenge_info();
    int is_settle_today(int32_t &time, int32_t &rob_time);
    void get_team_fp(int32_t uid, int32_t &fp);
    //void get_equip_level(int32_t uid, int32_t pid, int32_t &equiplv);
    void get_level_info(int32_t uid, int32_t pid, int32_t &level, int32_t &lovelevel, int32_t &rank, int32_t &resid);
    void get_gang_name(int32_t uid, string &gangname);
    int32_t give_slot_to_occupy(int32_t uid_, int32_t pos_);
    int32_t giveup_help(int32_t uid_);
    void get_first_pass_treasure_reward(int32_t resid_);
private:
    void reset(int32_t &time, int32_t &rob_time);
    int32_t cal_money(int32_t pos_,uint32_t start_,uint32_t end_,int32_t ht_sec_, int32_t uid_);
    int32_t cal_help_money(int32_t pos_,uint32_t start_,uint32_t end_,int32_t rob_money);
    void settle();
    void put_reward(int32_t uid_,int32_t money_,int32_t now_profit_);
    void gen_drop(int resid_,map<int,int>&);
    int32_t is_open();
    int32_t settle_owner(uint32_t sec_now_, int32_t &left_secs_, int32_t &pos_, int32_t &rob_money_);
    int32_t settle_owner(int32_t pos_, int32_t &rob_money_);
    int32_t settle_owner(int32_t pos_, uint32_t end_, int32_t &rob_money_);
    int32_t settle_owner_and_occupy(int32_t pos_, uint32_t end_, uint32_t &ds_, int32_t &money_all, int32_t &rob_money_);
    int32_t settle_helper(int32_t pos_, uint32_t end_, int32_t rob_money_, string name, bool isused);
    void check24();

private:
    sc_user_t   &m_user;
    int32_t     m_cur_rid;
    int32_t     m_cur_drop;
    int32_t     m_cur_count;
    int32_t     m_pos;
    int32_t     m_today_refresh_times;    //  宝库今日刷新次数
    sp_treasure_hm_t m_treasure_hm;
    uint32_t m_utime;
    string      m_salt;
    int         m_fight_time;
};
///////////////////////////////////////////////////////////
//占领者信息
struct conqueror_info_t
{
    int32_t slot_pos;
    int32_t last_round;
    int32_t debian_secs;   //今日已经结算的时间
    int32_t last_stamp;    //本次占坑的开始时间
    int32_t n_rob;
    int32_t profit; // 占领、掠夺收益
    conqueror_info_t(int slot_pos_=-1,int last_round_=0,int debian_secs_=0,int32_t last_stamp_=0,int n_rob_=0,int32_t profit_=0):slot_pos(slot_pos_),last_round(last_round_),debian_secs(debian_secs_),last_stamp(last_stamp_),n_rob(n_rob_),profit(profit_)
    {
    }
};
///////////////////////////////////////////////////////////
//协守者信息
struct coopertive_info_t
{
    int32_t slot_pos;
    int32_t last_round;
    int32_t debian_secs;
    int32_t last_stamp;
    int32_t n_help; // 协守次数
    int32_t profit; // 协守收益
    coopertive_info_t(int slot_pos_ = -1, int last_round_ = 0, int debian_secs_ = 0, int32_t last_stamp_ = 0, int n_help_ = 0, int32_t profit_ = 0):slot_pos(slot_pos_), last_round(last_round_), debian_secs(debian_secs_), last_stamp(last_stamp_), n_help(n_help_), profit(profit_)
    {
    }
};
//////////////
//巨龙宝藏的蹲位
struct treasure_srv_slot_t
{
    int32_t uid;
    int32_t resid;
    string nickname;
    int32_t fp;
    int32_t grade;
    uint32_t stamp;         //占领时间
    int32_t n_rob;          //被打劫次数
    int32_t rob_money;      //被打劫金钱
    vector<int32_t> robers; //打劫者
    int32_t lovelevel;      //爱恋度等级
    bool is_pvp_fighting;
    uint32_t begin_pvp_fight_time;
    JSON11(treasure_srv_slot_t,uid,resid,nickname,fp,grade,stamp,n_rob,rob_money,robers,is_pvp_fighting,begin_pvp_fight_time);
};

typedef boost::shared_ptr<sc_msg_def::jpk_treasure_record_t> sp_jpk_treasure_record_t;
struct sc_treasure_record_t
{
    //第一次的记录时间
    uint32_t record_time;
    //挑战记录
    deque<sp_jpk_treasure_record_t> records;
    sc_treasure_record_t():record_time(0) {}
};
typedef boost::shared_ptr<sc_treasure_record_t> sp_treasure_record_t;

struct sc_revenge_record_t
{
    int32_t uid;
    int32_t lv;
    int32_t lovelevel;
    int32_t resid;
    string nickname;
};

class sc_treasure_cache_t
{
    friend class sc_treasure_t;
    typedef std::unordered_map<int32_t,conqueror_info_t> conqueror_info_hm_t;
    typedef std::unordered_map<int32_t,coopertive_info_t> coopertive_info_hm_t;
    typedef std::unordered_map<int32_t,sp_treasure_record_t> record_hm_t;
    typedef std::unordered_map<int32_t,deque<sc_revenge_record_t>> revenge_hm_t;
private:
    uint32_t flush_time;
    vector<treasure_srv_slot_t> slots;
    vector<treasure_srv_slot_t> helps;
    conqueror_info_hm_t conqueror_info_hm;
    coopertive_info_hm_t coopertive_info_hm;
    record_hm_t   m_record_hm;
    revenge_hm_t  m_revenge_hm;
public:
    sc_treasure_cache_t();
    char db_sql[30];
    void add_record(int32_t uid_, sp_jpk_treasure_record_t record_);
    void add_revenge(int32_t uid_, sc_revenge_record_t &record_);
    bool get_record(int32_t uid_, sp_treasure_record_t &sp_record_);
    void insert_conqueror_db(int32_t uid_,conqueror_info_t& con_info_,int32_t hostnum_);
    void update_conqueror_db(int32_t uid_,conqueror_info_t& con_info_,int32_t hostnum_);
    void insert_coopertive_db(int32_t uid_,coopertive_info_t& coo_info_,int32_t hostnum_);
    void update_coopertive_db(int32_t uid_,coopertive_info_t& coo_info_,int32_t hostnum_);
    void splits_robers(vector<int32_t>& v_robers_,string& s_robers_);
    void merge_robers(vector<int32_t>& v_robers_,string& s_robers_);
    void treasure_slot_db(treasure_srv_slot_t &t,int32_t slot_type,int32_t slot_pos,int32_t hostnum_);
    int32_t get_hostnum_by_uid(int32_t uid_);
    void load_db(vector<int32_t>& hostnums_);
};
#define treasure_cache (singleton_t<sc_treasure_cache_t>::instance())

#endif
