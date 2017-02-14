#ifndef _sc_activity_h_
#define _sc_activity_h_

#include "singleton.h"
#include "msg_def.h"
#include "db_ext.h"

#include <boost/shared_ptr.hpp> 
#include <list>
#include <map>
using namespace std;

class sc_user_t;

struct sc_auser_t : public db_Activity_ext_t
{
    int wingnum;
    sc_auser_t():wingnum(0){}
};
typedef boost::shared_ptr<sc_auser_t> sp_auser_t;

enum act_e
{
    e_act_cumu_yb_rank = 1,
    e_act_wing = 2,
};

class act_t
{
public:
    act_t() {}
    virtual ~act_t() {}
    virtual bool isopen() { return false; }
    virtual void load_db(vector<int32_t>& hostnums_) {}
    virtual void on_reload_repo() {};
    virtual void on_login(int uid_){}
    virtual void on_cumu_yb(int uid_, int yb_) {}
    virtual void update(){}
    virtual void unicast(int uid_){}
};

//========================================

class act_cumu_yb_rank_t : public act_t
{
    typedef boost::shared_ptr<sc_msg_def::jpk_cumu_yb_rank_t> sp_ri_t;
    typedef list<sp_ri_t> rank_list_t;
    typedef map<int, rank_list_t::iterator> rank_map_t;
    typedef map<int, sp_auser_t> cumu_user_map_t;
public:
    act_cumu_yb_rank_t();
    bool isopen() { return m_opened; }
    void load_db(vector<int32_t>& hostnums_);
    void on_reload_repo();
    void on_login(int uid_);
    void on_cumu_yb(int uid_, int yb_);
    void update();
    void unicast(int uid_);
private:
    void check_time();
    int reward_rank(int uid_, int rank);
    int reward_cumu(int uid_, int cumu_);
private:
    bool                m_opened;
    uint32_t            m_btime;
    uint32_t            m_etime;
    uint32_t            m_savetime;
    rank_map_t          m_map;
    rank_list_t         m_rank_list;
    cumu_user_map_t     m_cumu_user_map;
};
//========================================
class act_wing_t : public act_t
{
    typedef boost::shared_ptr<sc_msg_def::jpk_wing_rank_t> sp_ri_t;
    typedef list<sp_ri_t> rank_list_t;
    typedef map<int, rank_list_t::iterator> rank_map_t;
public:
    act_wing_t();
    bool isopen() { return m_opened; }
    void load_db(vector<int32_t>& hostnums_);
    void on_reload_repo();
    void on_reward(sp_auser_t sp_auser);
    int on_gacha(int uid_, int num_);
    int given_score_wing(int uid_);
    void update();
    void unicast(int uid_);
private:
    void check_time();
private:
    bool                m_opened;
    uint32_t            m_btime;
    uint32_t            m_etime;
    uint32_t            m_savetime;
    rank_map_t          m_map;
    rank_list_t         m_rank_list;
};
//========================================
class sc_activity_t
{
    friend class act_cumu_yb_rank_t;
    friend class act_wing_t;
    typedef unordered_map<int, sp_auser_t> auser_map_t;
    typedef map<int, act_t*> act_map_t;
public:
    sc_activity_t();
    ~sc_activity_t();
    void load_db(vector<int32_t>& hostnums_);
    void init_new_user(sc_user_t& user_);
    void load_user(sc_user_t& user_);
    void on_reload_repo();
    void on_login(int uid_);
    void on_upgrade(int uid_,  int lv_);
    void on_rename(int uid_, const string& name_);
    void on_cumu_yb(int uid_, int yb_);
    void update();
    void unicast(int actid_, int uid_);
    sp_auser_t get_user(int uid_);
    act_t* get_act(int type_);
private:
    int get_repo(int actid_, uint32_t& btime_, uint32_t& etime_);
    void save_user(sp_auser_t sp_auser_);
private:
    auser_map_t          m_auser_map;
    act_map_t           m_act_map;
};

#define activity (singleton_t<sc_activity_t>::instance())

#endif
