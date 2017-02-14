#ifndef _sc_star_h_
#define _sc_star_h_

#include <map>
#include <vector>

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

using namespace std;

class sc_user_t;
class sc_star_t
{
public:
    db_Star_t db;
public:
    sc_star_t(sc_user_t &user_);
    void get_star_jpk(sc_msg_def::jpk_star_t &jpk_);
private:
    sc_user_t &m_user;
};

typedef boost::shared_ptr<sc_star_t> sp_star_t;

class sc_star_mgr_t
{
    //[pid] [vector]
    typedef map<int32_t, vector<sp_star_t> > star_hm_t;
public:
    sc_star_mgr_t(sc_user_t &user_);
    void load_db();
    void async_load_db();
    void open_attr(sc_msg_def::req_star_open_t &req_);
    void flush_attr(sc_msg_def::req_star_flush_t &req_);
    void get_attr(sc_msg_def::req_star_get_t &req_);
    void set_attr();
    
    template<class F>
    void foreach(F fun_, int32_t pid_)
    {
        auto it_hm = m_stars.find(pid_);
        if( it_hm == m_stars.end() )
            return;

        for(auto it=it_hm->second.begin(); it!=it_hm->second.end(); it++)
        {
            fun_(*it);
        }
    }
private:
    int32_t is_open(int32_t rare_,int32_t lv_,int32_t pos_);
    void random_attr(int32_t job_,int32_t lv_,int32_t &att_,int32_t &value_);
private:
    sc_user_t       &m_user;
    star_hm_t       m_stars;
    //最近一次刷新的属性
    int32_t         m_last_attr;
    int32_t         m_last_value;
    int32_t         m_last_pid;
    sp_star_t       m_last_sp_star;
};

#endif
