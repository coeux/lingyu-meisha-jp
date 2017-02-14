#ifndef _sc_union_rank_h_
#define _sc_union_rank_h_

#include "singleton.h"
#include "msg_def.h"
#include "db_ext.h"
#include "db_def.h"

#include <boost/shared_ptr.hpp>
#include <map>
#include <unordered_map>

using namespace std;

typedef boost::shared_ptr<sc_msg_def::jpk_ganginfo_t> sp_ganginfo_t;
class sc_union_rank_t
{
public:
    sc_union_rank_t();
    void update();
    void unicast_union_rank(int32_t uid_);
    void update_rank_info();
    void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }
private: 
    db_Gang_t db; 
    db_GangUser_t userdb;
    bool    issend;
    string m_union_rank_list_str;
    list<sp_ganginfo_t> m_union_rank_list;
    uint32_t timeStamp;
    vector<int32_t>  m_hosts;
}; 
#define union_rank (singleton_t<sc_union_rank_t>::instance())
#endif
