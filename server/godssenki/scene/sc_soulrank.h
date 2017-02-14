#ifndef _soulrank_h_
#define _soulrank_h_

#include <unordered_map>
#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;

class sc_soulrank_t
{
public:
    sc_soulrank_t();
    void init_soulrank();
    void unicast_soulrank_rank(int32_t id);
private:
    vector<vector<int32_t>> soulrank;
    vector<int32_t> cursoulrank;
};
#define soulrank (singleton_t<sc_soulrank_t>::instance())
//======================================================
class sc_soulrank_mgr_t
{
public:
    sc_soulrank_mgr_t(sc_user_t& user_);
    db_SoulUser_ext_t db;

    void init_new_user(); 
    void save_db();

    void load_db();

    void unicast_soul_node_info(map<int, sc_msg_def::jpk_soulnode_t>& soul_node_info, int soulid_);
    int on_coin_change(int32_t coin_);
    int req_open_soulnode(int32_t soulid_);
    map<int,int> get_pro_gen(int32_t soulid_, int32_t pro_type_);
    void nt_soul_node_info();
private:
    sc_user_t&                      m_user;
    sc_maxid_t                      m_maxid;
};

#endif
