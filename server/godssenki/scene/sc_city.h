#ifndef _city_mgr_h_
#define _city_mgr_h_

#include <list>
#include <set>
#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>
#include "msg_def.h"

struct sc_city_t;
struct sc_city_user_t
{
    sc_city_user_t(int32_t uid_, sc_city_t& city_);

    void sync_pos(int32_t x_, int32_t y_);
    void watch(int32_t uid_, int32_t x_, int32_t y_);
    void watched(int32_t uid_, int32_t x_, int32_t y_);
    bool has_watch(int32_t uid_) { return watch_other.find(uid_) != watch_other.end(); }
    
    bool is_fullwatch(); 
    bool is_fullwatched(); 

    int32_t         uid;
    sc_city_t&      city;
    int32_t         x;
    int32_t         y;
    set<int32_t>    watch_other;
    set<int32_t>    watch_me;
    uint32_t        max_watch;
};
typedef boost::shared_ptr<sc_city_user_t> sp_city_user_t;

//[uid][city_user]
struct sc_city_t
{
    typedef unordered_map<int32_t, sp_city_user_t> user_hm_t;

    sc_city_t(int32_t resid_);
    sp_city_user_t get_user(int32_t uid_);
    sp_city_user_t add_user(int32_t uid_, int32_t watch_max_);
    void del_user(int32_t uid_);
    void update(sp_city_user_t cuser);

    int32_t             resid;
    user_hm_t           user_hm;
    list<int32_t>       users;
};
typedef boost::shared_ptr<sc_city_t> sp_city_t;

//[sceneid][city]
class sc_city_mgr_t  
{
    typedef unordered_map<int32_t, sp_city_t> city_hm_t;
public:
    int enter_city(uint32_t uid_,sc_msg_def::req_enter_city_t& jpk_,int32_t slience_=0);
    int move(sc_msg_def::nt_move_t& jpk_);
    int get_uid_pos(int32_t uid_, int32_t sceneid, int32_t& x_, int32_t&y_);
    int del_uid(int32_t uid_, int32_t sceneid_);
    bool get(int32_t sceneid_, sp_city_t& city_);
    void insert(int32_t sceneid_, sp_city_t city_);
    template<class T>
    void broadcast(int sceneid_, T& nt_)
    {
        typedef unordered_map<int32_t, sp_city_user_t> user_hm_t;
        string msg; nt_ >> msg;

        auto it_city = m_city_hm.find(sceneid_);
        if (it_city == m_city_hm.end()) return;

        user_hm_t& users = it_city->second->user_hm;
        for(auto it = users.begin(); it!=users.end(); it++)
        {
            unicast(it->first, T::cmd(), msg);
        }
    }
private:
    void unicast(int uid_, uint16_t cmd_, const string& msg_);
private:
    city_hm_t m_city_hm;
};

#endif
