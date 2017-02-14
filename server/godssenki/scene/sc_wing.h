#ifndef _sc_wing_h_
#define _sc_wing_h_

#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;
class sc_wing_t
{
public:
    db_Wing_ext_t db;
public:
    sc_wing_t(sc_user_t& user_);
    void get_wing_jpk(sc_msg_def::jpk_wing_t& jpk_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_wing_t> sp_wing_t;

class sc_wing_mgr_t
{
    typedef unordered_map<int32_t, sp_wing_t> wing_hm_t;
public:
    sc_wing_mgr_t(sc_user_t& user_);
    void load_db();
    sp_wing_t& get_weared() { return m_weared; }
    sp_wing_t get(int32_t wid_);

    bool addnew(int32_t resid_,int32_t num_,sc_msg_def::nt_bag_change_t& change_);
    bool addnew(int32_t source_type_, int32_t target_type_, int32_t num_,sc_msg_def::nt_bag_change_t& change_);
    void genpro(sp_wing_t sp_wing_); 
    void remove(int wid_);

    int wear(int32_t wid_);
    int takeoff(int32_t wid_);

    void compose(int32_t wid_);
    int32_t split(int32_t wid_);
    int32_t sell(int32_t wid_);
    int32_t bag_size();

    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_wing_hm.begin(); it!=m_wing_hm.end(); it++)
        {
            fun_(it->second);
        }
    }

    void save_db_userid();
private:
    sc_user_t&          m_user;
    wing_hm_t           m_wing_hm;
    sc_maxid_t          m_maxid;
    sp_wing_t           m_weared;
};

#endif
