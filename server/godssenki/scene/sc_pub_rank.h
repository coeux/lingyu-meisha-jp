#ifndef _sc_pub_rank_h_
#define _sc_pub_rank_h_

#include "singleton.h"
#include "msg_def.h"

#include <boost/shared_ptr.hpp> 
#include <list>
#include <unordered_map>

using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

typedef boost::shared_ptr<sc_msg_def::jpk_pub_node_t> sp_pub_node_t;

class sc_pub_rank_t
{
    typedef unordered_map<int32_t,sp_pub_node_t> uid_pub_hm_t;
public:
    sc_pub_rank_t();
    void load_db(vector<int32_t>& hostnums_);
    void update_pub(int32_t pubcount_);
    void unicast_pub_rank(int32_t uid_);
    void update_rank_info();
    void send_reward();
private:
    int32_t                     m_pub_uid;
    bool                        issend;
    int32_t                     m_pub_cut;
    uint32_t                    m_pub_serize_tm;
    string                      m_pub_ranks_str;
    list<sp_pub_node_t>          m_pub_rank_list;
    uid_pub_hm_t                 m_uid_pub_hm;
    char                        db_sql[20];
};
#define pub_rank (singleton_t<sc_pub_rank_t>::instance())

#endif
