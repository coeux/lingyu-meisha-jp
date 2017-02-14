#ifndef _sc_friend_h_
#define _sc_friend_h_

#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_def.h"
#include "msg_def.h"

class sc_user_t;

class sc_friend_t
{
public:
    db_Friend_t db;
    int32_t online;
public:
    sc_friend_t(sc_user_t &user_);
private:
    sc_user_t &m_user;
};
typedef boost::shared_ptr<sc_friend_t> sp_friend_t;
//======================================================
class sc_friend_mgr_t
{
    //[fuid] [sp_friend_t]
    typedef map<int32_t, sp_friend_t> friend_hm_t;
public:
    sc_friend_mgr_t(sc_user_t &user_);
    void load_db();
    void async_load_db();
    void load_info();
    int32_t is_frd(int32_t uid_);
    //寻找好友
    void search_friend(string &name_);
    void search_friend_by_uid(int32_t uid_);
    //添加好友
    void add_friend(int32_t uid_, int32_t fp_);
    //被加好友
    void add_req_return(int32_t suid_,int32_t reject_);
    //删除好友
    void del_friend(int32_t uid_);
    //请求好友列表
    void get_friends(int32_t page_);
    //通知好友，我上下线
    void on_online_change(int32_t online_);
    //通知好友，我更改助战英雄
    void on_helphero_change(int32_t resid_);
    //查看是否已经送过花
    bool check_send_flower(int32_t uid_);
    //标志该好友已被送过花
    void set_flower_sent(int32_t uid_);
    
    sp_friend_t get(int32_t fuid_);
    void put(sp_friend_t frd_);
    void del(int32_t uid_);
    void on_rename(int uid_, const string& name_);
    
    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_friend_vec.begin(); it!=m_friend_vec.end(); it++)
        {
            fun_(*it);
        }
    }
private:
    void get_friend_info(int32_t uid_, sc_msg_def::friend_info_t &ret_);
    void update_online(int32_t uid_,int32_t online_);
private:
    sc_user_t                           &m_user;
    friend_hm_t                         m_friend_hm;
    vector<sp_friend_t>                 m_friend_vec;
};
struct sc_friend_request_t
{
    int32_t uid;
    string name;
    int32_t lv;
    sc_friend_request_t(int32_t uid_,string &name_,int32_t lv_):uid(uid_),name(name_),lv(lv_)
    {
    }
};
class sc_frd_request_cache_t
{
    typedef unordered_map<int32_t, list<sc_msg_def::nt_request_info_t> > request_hm_t;
private:
    request_hm_t m_request_hm;
public:
    void get_frd_req_info(int32_t uid_,vector<sc_msg_def::nt_request_info_t> &ret_);
    void put(int32_t duid_,int32_t suid_,const string &name_,int32_t lv, int32_t resid, int32_t fp);
    void del(int32_t duid_,int32_t suid_);
    int32_t get_n_request(int32_t uid_);
};
#define frd_request_cache (singleton_t<sc_frd_request_cache_t>::instance())


class sc_frd_loadinfo_t
{
private:
    list<int32_t> m_uids;
public:
    void put(int32_t uid_);
    void load_frd_info();
};
#define frd_loadinfo (singleton_t<sc_frd_loadinfo_t>::instance())

struct sc_helphero_info_t
{
    int32_t m_fpoint;           //当日获得友情点总数，上限10000
    int32_t m_helpcount;        //当日被邀请次数，上限50
    set<int32_t> m_uids;        //当日邀请过的好友uid，每个好友只能被邀请一次
    sc_helphero_info_t():m_fpoint(0),m_helpcount(0){}
};
class sc_helphero_cache_t
{
    typedef unordered_map<int32_t,sc_helphero_info_t> helphero_hm_t;
private:
    helphero_hm_t m_helphero_hm;
    set<int32_t> m_graduated_set;
    uint32_t flush_sec;
private:
    void reset();
public:
    sc_helphero_cache_t();
    int32_t get_helpcount(int32_t uid_);
    int32_t get_fpoint(int32_t uid_);
    void add_helpcount(int32_t uid_);
    int32_t add_fpoint(int32_t uid_,int32_t delta_);
    int32_t is_helped(int32_t uid_,int32_t hhero_);
    void set_helper(int32_t uid_,int32_t hhero_);
    int32_t is_graduated(int32_t uid_);
};
#define helphero_cache (singleton_t<sc_helphero_cache_t>::instance())

#endif
