#ifndef _sc_act_daily_task_h_
#define _sc_act_daily_task_h_

#include "msg_def.h"
#include "db_ext.h"
#include <boost/shared_ptr.hpp> 

enum evt_act_daily_task_e
{
    evt_unknown = 0,
    evt_round_pass,
    evt_equip_upgrade,
    //evt_equip_compose, // 更改为技能升级
    evt_skill_upgrade,
    evt_arena_fight_win,
    evt_buy_money,
    evt_pub_flash,
    evt_up_potential,
    evt_limitround_pass, 
    evt_treasure_occupy, // 宝藏
                            //evt_miku_pass, // 秘境
    evt_elite_pass, // 精英副本
    evt_practice, // 吃包子
    evt_starsoul_flash,
    evt_pass_zodiac,
    evt_got_fuwen,
    evt_world_boss, // 新添
    evt_gang_act,
    evt_rank_fight,
};

class sc_user_t;
typedef boost::shared_ptr<db_ActDailyTask_ext_t> sp_adt_t;
class sc_act_daily_task_t
{
    typedef map<int, sp_adt_t> adt_map_t;
public:
    void init_new_user();

    sc_act_daily_task_t(sc_user_t& user_);
    void load_db();
    void unicast();
    void save_db(sp_adt_t sp_adt_);
    int on_event(int evt_);
    int given_reward(int id_,bool isDouble = false);
private:
    sc_user_t&  m_user;
    adt_map_t   m_adt_map;
};

#endif
