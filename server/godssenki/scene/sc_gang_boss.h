#ifndef _sc_gang_boss_h_
#define _sc_gang_boss_h_

#include <boost/shared_ptr.hpp>
#include <vector>
#include <string>
using namespace std;

#include "sc_cache.h"

class sc_gang_t;

class sc_ganguser_t;
typedef boost::shared_ptr<sc_ganguser_t> sp_ganguser_t;

class sc_gang_boss_t
{
    enum state
    {
        state_closed,
        state_prepared,
        state_started
    };

    struct target_t
    {
        int uid;
        string nickname;
        int32_t dmg;
        uint32_t fight_stamp;

        target_t():dmg(0){}
    };
    typedef boost::shared_ptr<target_t> sp_target_t;
    typedef vector<sp_target_t> target_vec_t;
public:
    sc_gang_boss_t(sc_gang_t& gang_);

    int unicast_boss_info(sp_ganguser_t sp_guser_);
    int unicast_rank(sp_ganguser_t sp_guser_);

    int fight(sp_ganguser_t sp_guser_);

    bool has_state(int state_) { return (m_state==state_); }
    void set_state(int state_);
private:
    void on_prepare();
    void on_start();
    void on_close();
    //击杀者的uid
    void on_dead(int uid_); 
    void on_gone();

    void spawn_boss();
    void update_hp(int uid_, int damage_);
    void update_rank(int uid_, int damage_);

    bool get_target(int uid_, sp_target_t& sp_target_);
    bool is_time_over();
    void check_time();
    int countdown();
private:
    sc_gang_t&      m_gang;
    target_vec_t    m_targets;
    uint32_t        m_started_time;
    int*            m_ref_hp;
    int             m_hpmax;
    int             m_state;
    sp_view_user_t  m_boss;
};

#endif
