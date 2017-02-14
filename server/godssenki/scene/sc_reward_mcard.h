#ifndef _sc_reward_mcard_h_
#define _sc_reward_mcard_h_

#include "msg_def.h"
#include "db_ext.h" 
#include "db_def.h"

#include <vector>

class sc_user_t;
class sc_reward_mcard_t
{
    public:
        sc_reward_mcard_t();
        sql_result_t load_db();
        void update_reward();
        void db_save();
        void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }
    private:
        db_Reward_ext_t db;   
        bool m_is_send;
        vector<int32_t>  m_hosts;
};

#define reward_mcard (singleton_t<sc_reward_mcard_t>::instance()) 

#endif
