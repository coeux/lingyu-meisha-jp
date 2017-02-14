#ifndef _sc_fp_rank_h_
#define _sc_fp_rank_h_

#include "singleton.h"
#include "msg_def.h"

#include <boost/shared_ptr.hpp> 
#include <list>
#include <unordered_map>

using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

typedef boost::shared_ptr<sc_msg_def::jpk_fp_node_t> sp_fp_node_t;

class sc_fp_rank_t
{
    typedef unordered_map<int32_t,sp_fp_node_t> uid_fp_hm_t;
public:
    sc_fp_rank_t();
    void load_db(vector<int32_t>& hostnums_);
    void update_fp();
    void unicast_fp_rank(int32_t uid_);
    void update_rank_info();
private:
    int32_t                     m_fp_uid;
    int32_t                     m_fp_cut;
    uint32_t                    m_fp_serize_tm;
    string                      m_fp_ranks_str;
    list<sp_fp_node_t>          m_fp_rank_list;
    uid_fp_hm_t                 m_uid_fp_hm;
    char                        db_sql[20];
};
#define fp_rank (singleton_t<sc_fp_rank_t>::instance())

#endif
