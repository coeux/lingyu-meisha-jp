#ifndef _dbmid_cache_h_
#define _dbmid_cache_h_

#include "msg_def.h"
#include "lru_cache.h"
#include "dbmid_def.h"
#include "rpc_connecter.h"

class dbmid_cache_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
    typedef std::shared_ptr<dbmid_acc_t> sp_acc_t;
    typedef std::shared_ptr<dbmid_user_t> sp_user_t;
public:
    void insert_acc(db_Account_t& db_, sp_rpc_conn_t conn_);
    void insert_userid(db_UserID_t& db_, sp_rpc_conn_t conn_);
    void insert_user(db_UserInfo_t& db_, sp_rpc_conn_t conn_);
    void insert_team(db_Team_t& db_, sp_rpc_conn_t conn_);
    void insert_items(vector<db_Item_t>& db_, sp_rpc_conn_t conn_);
    void insert_partners(vector<db_Partner_t>& db_, sp_rpc_conn_t conn_);
    void insert_skils(vector<db_Skill_t>& db_, sp_rpc_conn_t conn_);
    void insert_equip(vector<db_Equip_t>& db_, sp_rpc_conn_t conn_);

    void update_acc(db_Account_t& db_, sp_rpc_conn_t conn_);
    void update_userid(db_UserID_t& db_, sp_rpc_conn_t conn_);
    void update_user(db_UserInfo_t& db_, sp_rpc_conn_t conn_);
    void update_team(db_Team_t& db_, sp_rpc_conn_t conn_);
    void update_items(vector<db_Item_t>& db_, sp_rpc_conn_t conn_);
    void update_partners(vector<db_Partner_t>& db_, sp_rpc_conn_t conn_);
    void update_skils(vector<db_Skill_t>& db_, sp_rpc_conn_t conn_);
    void update_equip(vector<db_Equip_t>& db_, sp_rpc_conn_t conn_);

    sp_acc_t select_acc(string& mac_, sp_rpc_conn_t conn_);
    int select_user(int32_t uid_, sp_rpc_conn_t conn_);

    int insert(string& tablename_, string& data_, sp_rpc_conn_t conn_);
    int update(string& tablename_, string& data_, sp_rpc_conn_t conn_);

    void insert_sp_acc(sp_acc_t sp_acc_);
private:
    lru_cache_t<string, sp_acc_t> m_mac_acc_cache;
    lru_cache_t<int32_t, sp_acc_t> m_aid_acc_cache;
    lru_cache_t<int32_t, sp_user_t> m_user_cache;
};

class dbmid_cache_mgr_t
{
public:
    void start(int thread_num_);
    void conn_db(const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_);
    dbmid_cache_t& get(const string& mac_);
    dbmid_cache_t& get(int32_t uid_);
private:
    vector<dbmid_cache_t>  m_caches;
};

#define cache_mgr (singleton_t<dbmid_cache_mgr_t>::instance())

#endif
