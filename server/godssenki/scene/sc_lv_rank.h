#ifndef _sc_lv_rank_h_
#define _sc_lv_rank_h_

#include "singleton.h"
#include "msg_def.h"

#include <boost/shared_ptr.hpp> 
#include <list>
#include <unordered_map>

using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

typedef boost::shared_ptr<sc_msg_def::jpk_lv_node_t> sp_lv_node_t;

class sc_lv_rank_t
{
    typedef unordered_map<int32_t,sp_lv_node_t> uid_lv_hm_t;
public:
    sc_lv_rank_t();
    void load_db(vector<int32_t>& hostnums_);
    void update_lv();
    void unicast_lv_rank(int32_t uid_);
    void update_rank_info();
    void send_reward();
private:
    int32_t                     m_lv_cut;
    uint32_t                    m_lv_serize_tm;
    int32_t                     issend;
    string                      m_lv_ranks_str;
    list<sp_lv_node_t>          m_lv_rank_list;
    uid_lv_hm_t                 m_uid_lv_hm;
    char                      dbspl_strhost[32];
};
#define lv_rank (singleton_t<sc_lv_rank_t>::instance())

#endif
