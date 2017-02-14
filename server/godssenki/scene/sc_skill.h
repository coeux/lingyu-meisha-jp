#ifndef _sc_skill_h_
#define _sc_skill_h_

#include <unordered_map>
#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;

class sc_skill_t 
{
public:
    db_Skill_ext_t db;
public:
    sc_skill_t(sc_user_t& user_);
    void get_skill_jpk(sc_msg_def::jpk_skill_t& jpk_);
    //技能升级
    int32_t upgrade(int num_);
    //技能升阶
    int32_t upnext(sc_msg_def::ret_upnext_skill_t &ret);
    void save_db();

    bool istskill(int skid_);
    bool isaskill(int skid_);
    bool ispskill(int skid_);
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_skill_t> sp_skill_t;
//======================================================
class sc_skill_mgr_t 
{
    typedef unordered_map<int32_t, sp_skill_t> skill_hm_t;
public:
    sc_skill_mgr_t(sc_user_t& user_);

    void init_new_user(); 

    void load_db();
    void async_load_db();

    sp_skill_t get(int32_t skid_);
    void init_new_partner(int32_t pid_, int32_t resid_, int32_t quality_);

    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_skill_hm.begin(); it!=m_skill_hm.end(); it++)
        {
            fun_(it->second);
        }
    }

    void update_skill_level(int32_t pid_, int32_t quality, int32_t resid);
    bool is_skill_cangrade(int32_t quality, int32_t resid_, int32_t skill_id_);
    int32_t get_total_battlexp(int32_t pid_);
private:
    sc_user_t&      m_user;
    skill_hm_t      m_skill_hm;
    sc_maxid_t      m_maxid;
};

#endif
