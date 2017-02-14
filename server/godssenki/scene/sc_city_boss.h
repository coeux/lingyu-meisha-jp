#ifndef _sc_city_boss_h_
#define _sc_city_boss_h_

#include <boost/shared_ptr.hpp>
#include <unordered_map>
#include <vector>
#include <map>
#include "msg_def.h"
#include "sc_user.h"
#include "singleton.h"

namespace sc_city_boss{

typedef vector<sc_msg_def::jpk_item_t> jpk_item_vec_t;
struct boss_t;
typedef boost::shared_ptr<boss_t> sp_boss_t;

struct user_t
{
    int             fightcount;
    uint32_t        fightstamp;
    jpk_item_vec_t  drop_items;
    sp_boss_t       sp_boss;
    int             gold;
};

struct boss_t
{
    int             id;
    uint32_t        resid;
    int             level;
    uint32_t        spawnstamp;
    int             killcount;
    int             x,y;
    int             fightingbyuid;
    int             fightstamp;

    boss_t(int id_):id(id_),fightingbyuid(0){};
};
typedef boost::shared_ptr<sc_city_boss::user_t> sp_cbuser_t;

typedef vector<sc_msg_def::jpk_city_boss_t> jpk_boss_vec_t;
class city_t
{
    typedef map<uint32_t, sp_boss_t> boss_map_t;
public:
    city_t(int sceneid_);
    int update();
    int spawn();
    int gone();
    int begin_fight(sp_user_t sp_user_, uint32_t bossid_);
    int fight_boss(sp_user_t sp_user_, uint32_t bossid_, bool win_);
    int get_boss_jpk(jpk_boss_vec_t& jpks_);
private:
    int             m_sceneid;
    int             m_spawn_num;
    boss_map_t      m_boss_map;
    bool            m_notify1;
    bool            m_notify2;
    bool            m_notify3;
    bool            m_spawned;
    bool            m_bossgone;
};
typedef boost::shared_ptr<city_t> sp_city_t;

class mgr_t
{
    friend class city_t;
    typedef unordered_map<uint32_t, sp_cbuser_t> user_map_t;
    //[sceneid][sp_city_boss_t]
    typedef map<int, sp_city_t> city_map_t;
public:
    int unicast(int uid_, int sceneid_);
    int begin_fight(sp_user_t sp_user_, int bossid_);
    int fight(sp_user_t sp_user_, int bossid_, bool win_);
    int update();
private:
    city_map_t  m_city_map;
    user_map_t  m_user_map;
};

}

#define cityboss (singleton_t<sc_city_boss::mgr_t>::instance())

#endif
