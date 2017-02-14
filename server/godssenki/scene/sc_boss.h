#ifndef _SC_BOSS_H_
#define _SC_BOSS_H_

#include <stdint.h>
#include "msg_def.h"
#include "code_def.h"
#include "sc_user.h"
#include "sc_gang.h"

#include <vector>
#include <list>
#include <string>
#include <map>

using namespace std;

struct damage_info_t
{
    int32_t in_scene;
    int32_t damage;
    uint32_t last_batt_time;
    int32_t old_scene;
    string nickname;
    int32_t lv;
    damage_info_t(const string &nickname_):
        in_scene(0),
        damage(0),
        last_batt_time(0),
        old_scene(0),
        nickname(nickname_),
        lv(0){}
};

class sc_boss_t
{
    //[uid] [damage_info_t]
    typedef map<int32_t,damage_info_t> m_damage_hm_t;
public:
    sc_boss_t();
    int32_t get_last_batt_time(int32_t uid_);
    int32_t set_last_batt_time(int32_t uid_,uint32_t bt_);
    int32_t update_damage(int32_t uid_,int32_t damage_);
    //flag_:boss类型,1,世界boss,2,公会boss
    //世界boss:3101,3102,3103,3104
    //公会boss:3100
    //lv_:boss等级
    int32_t boss_spawn(int32_t lv_, int tag);
    //uid_:0,boss逃匿,<>0,该玩家杀死boss
    int32_t boss_gone(int32_t uid_);
    void boss_grow_up(int32_t uid_, uint32_t cur_sec_);
    void do_user_enter(int32_t uid_,int32_t scene_,const string &nickname_,int32_t sceneid_, int lv_);
    void get_rank(int32_t count_, vector<sc_msg_def::jpk_dmg_info_t> &rank_);
public:
    void req_damage_rank(int32_t uid_);
    void do_user_leave(int32_t uid_);
    void save_damage_db(int32_t uid_,int32_t ggid_,damage_info_t& d_info);
    void save_db(int32_t ggid_){cout<<"sc_boss_save_db->"<<endl;};
public:
    m_damage_hm_t m_damage_hm;
    int32_t m_spawned;
    uint32_t m_spawne_time;
    uint32_t m_spawne_time2;
    int32_t m_resid;
    int32_t m_grade;
    int64_t m_hp;
    int64_t m_max_hp;
    int32_t is_event;
    int32_t m_damage;
    int32_t m_flag;
    int32_t top_cut;
    int32_t m_cur_count;
    int32_t m_join_count; //公会boss参与人数
    bool is_join_reward = false;
    bool reward60;
    bool reward30;
    bool reward10;
    bool reward0;

    //伤害前十名的玩家
    vector<sc_msg_def::jpk_dmg_info_t> top;
};

class sc_world_boss_t: public sc_boss_t
{
public:
    sc_world_boss_t();
public:
    void get_boss_state(int32_t uid_,int32_t scene_,int32_t grade_, const string &nickname_);
    void enter_battle(sp_user_t user_,int32_t uid_, int32_t fee_);
    int32_t exit_battle(sp_user_t user_, sc_msg_def::req_boss_end_batt_t &jpk_, sc_msg_def::ret_boss_end_batt_t &ret);
    void get_startime(int32_t &start_);
    int32_t is_boss_available();
    void update_boss_time();
    void set_boss_available();
    void join_reward();
private:
    void rank_reward();
    void unicast_top10();
    int32_t send_satge_reward(int32_t uid_, int32_t gold_, int32_t reward_id_);
    int32_t send_gang_boss_reward(int32_t uid_,int32_t percent_);
    int32_t is_battle_stage(sp_user_t user_);
protected:
    uint32_t m_start;
    uint32_t m_end;
    uint32_t m_prepare;
};
#define world_boss (singleton_t<sc_world_boss_t>::instance())

class gang_boss_mgr_t;
class sc_gang_boss_t : public sc_world_boss_t 
{
    friend class sc_gang_boss_mgr_t;
public:
    sc_gang_boss_t();
    void load_db(int32_t ggid_);
    void save_db(int32_t ggid_);
    void get_boss_state(int32_t uid_,int32_t scene_,int32_t grade_, const string &nickname_);
    bool is_spawned() { return m_spawned; }
    void update_boss(const sp_gang_t& sp_gang_, const sp_ganguser_t& sp_guser_, int32_t& bosscount);
    int update_time(const sp_gang_t& sp_gang_, const sp_ganguser_t& sp_guser_);
};
typedef boost::shared_ptr<sc_gang_boss_t> sp_gang_boss_t;

class sc_gang_boss_mgr_t
{
    typedef unordered_map<int32_t, sp_gang_boss_t> boss_mgr_t;
public:
    sp_gang_boss_t get_boss(sp_user_t sp_user_);
    int32_t is_boss_available(sp_user_t sp_user_, int32_t& bosscount);
    void open_boss(sp_user_t sp_user_, sc_msg_def::ret_open_union_boss_t& ret);
    void update_reward();
    boss_mgr_t m_mgr;
};

#define gang_boss_mgr (singleton_t<sc_gang_boss_mgr_t>::instance())

#endif
