#ifndef _sc_card_rank_h_
#define _sc_card_rank_h_

#include "singleton.h"
#include "msg_def.h"
#include "db_ext.h"
#include "db_def.h"

using namespace std;
typedef boost::shared_ptr<sc_msg_def::jpk_card_rank_t> sp_card_node_t;

class sc_card_rank_t
{
public:
    sc_card_rank_t();
    void update();
    void unicast_card_rank(int32_t uid_);
    void update_rank_info(); 
    void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }
private:
    db_Partner_t dbPartner;
    string m_card_rank_list_str;
    list<sp_card_node_t> m_card_rank_list;
    uint32_t timeStamp;
    vector<int32_t>  m_hosts;
};
#define card_rank (singleton_t<sc_card_rank_t>::instance())
#endif
