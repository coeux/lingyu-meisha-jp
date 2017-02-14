#ifndef _sc_arena_h_
#define _sc_arena_h_

#include "singleton.h"
#include "repo_def.h"
#include "msg_def.h"
#include "db_def.h"
#include "db_ext.h"

#include <unordered_map>
#include <vector>
#include <deque>
using namespace std;

class sc_user_t;
struct sc_arena_data_t;
struct sc_arena_record_t;

typedef boost::shared_ptr<sc_arena_data_t>                sp_arena_data_t;
typedef boost::shared_ptr<sc_msg_def::jpk_arena_record_t> sp_jpk_arena_record_t;
typedef boost::shared_ptr<sc_arena_record_t>              sp_arena_record_t;

class sc_arena_t
{
public:
    db_Arena_t db;
public:
    sc_arena_t(sc_user_t& user_);

    void init_new_user();
    void load_db();
    void on_login(); 
    int  unicast_arena_info(int32_t flag);
    void buy_fight_count();
    int need_yb(); // 清除冷却时间所需要钻石
    void clear_time();
    void get_cool_down(sc_msg_def::ret_arena_cool_down_t& ret_);
    int  fight(sc_msg_def::ret_begin_arena_fight_t &ret_, int pos_);
    int  fight_end(sc_msg_def::req_end_arena_fight_t &jpk_, sc_msg_def::ret_end_arena_fight_t &ret);
    bool is_in_fight();
    bool is_last_fight_end();
private:
    //void get_equip_level(int32_t uid, int32_t pid, int32_t &equiplv);
    void get_level_info(int32_t uid, int32_t pid, int32_t &level, int32_t &lovelevel, int32_t &starnum, int32_t &resid);
    bool is_in_rank(int b_, int e_);
    int  find_rank_targets();
    int  get_targets(int off_);
    int  db_get_rank(uint32_t uid_);
    int  db_get_host_rank(int& hostnum, uint32_t uid_);
    bool get_jpk_arena_target(uint32_t uid_, int rank_, sc_msg_def::jpk_arena_target_t& jpk_);
    void win(int lrank_, int32_t ruid_, int rrank_, sc_msg_def::ret_end_arena_fight_t &ret);
    void lose(sc_msg_def::ret_end_arena_fight_t &ret);
    void clear(sc_msg_def::ret_end_arena_fight_t &ret);
    void record(bool win_, int32_t lfp_, int32_t rfp_, int32_t ruid_, string rname_, int rlv_, int rrank_);
    void record_a(bool win_, int32_t lfp_, int32_t rfp_, sp_view_user_t sp_tar, int lrank_, int rrank_, int hostnum);
private:
    sc_user_t&          m_user;
    //[uid]
    uint32_t            m_targets[5];
    //[rank]
    uint32_t            m_ranks[5];
    string              m_salt;
    int                 m_fight_time;
    int32_t             m_target_uid; // 受击方 uid
    bool                m_in_fight;
    int32_t             m_flag; //0本服竞技场 1跨服竞技场
};

struct sc_arena_record_t
{
    //第一次的记录时间
    uint32_t record_time;
    //挑战记录
    deque<sp_jpk_arena_record_t> records;

    sc_arena_record_t():record_time(0) {}
};

class sc_arena_info_cache_t
{
    typedef db_ArenaInfo_ext_t arena_info_t;
    typedef boost::shared_ptr<arena_info_t> sp_arena_info_t;
    typedef unordered_map<int32_t, sp_arena_info_t> sp_arena_info_hm_t;
    typedef unordered_map<int32_t, list<int32_t>> hostnum_level_uid;
public:
    sc_arena_info_cache_t();
    void load_db(vector<int32_t>& hostnums_);
    void update(int32_t hostnum_, int32_t uid_, int32_t total_fp_, int32_t level_, int32_t* p_);
    bool get_arena_pid(int32_t hostnum_, int32_t uid, int32_t level_, int32_t& uid_, int32_t* p_);
    bool get_arena_pid(int32_t from_, int32_t to_, int32_t& uid_, int32_t* pid_);
    sp_fight_view_user_t get_arena_view(int32_t rank_, int32_t& uid_, bool& succ_);
private:
    sp_arena_info_hm_t m_arena_info;
    hostnum_level_uid m_hlu;
};

class sc_arena_cache_t
{
    friend class sc_arena_t;
    //[uid][sp_arena_record_t]
    typedef std::unordered_map<int32_t, sp_arena_record_t> record_hm_t;
public:
    sc_arena_cache_t();

    void update();
    void add_record(int32_t uid_, sp_jpk_arena_record_t record_, int32_t flag);
    bool get_record(int32_t uid_, sp_arena_record_t& sp_record_, int32_t flag);
    void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }

    //奖励倒计时
    uint32_t reward_countdown();
    //更新奖励时间
    void update_reward_time(int sec_);
private:
    record_hm_t     m_record_hm;
    record_hm_t     m_record_g_hm;
    uint32_t        m_flush_time;
    uint32_t        m_reward_time;
    vector<int32_t>  m_hosts;
};

#define arena_cache (singleton_t<sc_arena_cache_t>::instance())
#define arena_info_cache (singleton_t<sc_arena_info_cache_t>::instance())

#endif
