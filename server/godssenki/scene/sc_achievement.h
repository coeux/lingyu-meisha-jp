#ifndef _sc_achievement_h_
#define _sc_achievement_h_

#include "msg_def.h"
#include "db_ext.h"
#include <boost/shared_ptr.hpp> 

enum evt_achievement_e
{
    evt_unknow = 0,
    evt_own_partners,
    evt_equip_lv,
    evt_rankup_lv,
    evt_love_marriged,
    evt_love_lv,
};

class sc_user_t;
typedef boost::shared_ptr<db_Achievement_t> sp_achievement_t;
class sc_achievement_t
{
    typedef map<int, sp_achievement_t> achievement_map_t;
public:
    void init_new_user();

    sc_achievement_t(sc_user_t& user_);
    void load_db();
    void unicast();
    void save_db(sp_achievement_t sp_achievement_t_);
    int on_event(int evt_, int times);
    int given_reward(int id_);
private:
    sc_user_t&  m_user;
    achievement_map_t   m_achievement_map;
};

#endif
