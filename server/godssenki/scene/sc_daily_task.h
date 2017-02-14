#ifndef _sc_daily_task_h_
#define _sc_daily_task_h_

#include <stdint.h>
#include <unordered_map>
#include <map>
#include <vector>
using namespace std;
#include <boost/shared_ptr.hpp> 
#include "singleton.h" 

class sc_user_t;

enum evt_daily_task_e
{
    evt_unknown = 0,
    evt_round_pass,
    evt_equip_upgrade,
    evt_gemstone_compose,
    evt_arena_fight_win,
    evt_trial_task, 
    evt_practice,
    evt_buy_money,
    evt_pass_zodiac,
    evt_pub_flash,
    evt_sacrifice,
    evt_got_fuwen,
    evt_world_msg,
    evt_equip_compose,
    evt_up_potential,
    evt_treasure_occupy,
    evt_treasure_rob,
};

struct dtask_t
{
    int resid;
    int type;
    int step;
    int max_step;
    bool finished;
};
typedef boost::shared_ptr<dtask_t> sp_dtask_t;

struct cdtask_t
{
    uint32_t            gen_time; 
    vector<sp_dtask_t>  tasks;
    //int                 num;
    //int                 buy_num;
    //[taskid][donum]
    //map<int,int>        do_num_hm;
};
typedef boost::shared_ptr<cdtask_t> sp_cdtask_t;

class sc_daily_task_t
{
public:
    sc_daily_task_t(sc_user_t& user_);
    int gen_task();
    int unicast_dtask_list();
    int commit(int pos_);
    int buy_num();
    int on_event(int evt_);
public:
    void on_login();
private:
    sc_user_t&      m_user;
    sp_cdtask_t     m_sp_cdtask;
};

class sc_daily_task_cache_t
{
    typedef unordered_map<int32_t, sp_cdtask_t> user_dtask_hm_t;
public:
    void add(int32_t uid_, sp_cdtask_t& sp_task_);
    bool get(int32_t uid_, sp_cdtask_t& sp_task_);
    int  get_dtask_num(int32_t uid_);
private:
    user_dtask_hm_t m_dtasks;
};

#define daily_task_cache (singleton_t<sc_daily_task_cache_t>::instance()) 

#endif
