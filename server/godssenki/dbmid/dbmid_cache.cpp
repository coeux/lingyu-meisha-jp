#include "dbmid_cache.h"
#include "code_def.h"
#include "crypto.h"
#include "rpc.h"
#include "dbmid_def.h"

#define LOG "DBMID_CACHE"

typedef std::shared_ptr<dbmid_acc_t> sp_acc_t;
typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;

namespace std
{
    string to_string(const string& str_) {return str_; }
}

#define DBMID_BEGIN(key) { logwarn((LOG, "%s..., key:%s", __FUNCTION__, std::to_string(key).c_str())); }
#define DBMID_END(key) { logwarn((LOG, "%s...ok, key:%s", __FUNCTION__, std::to_string(key).c_str())); }
#define DBMID_SQL(fun, conn) if (fun) { logerror((LOG, "%s do sql error!", __FUNCTION__)); send_error(conn, SQL_ERROR); return; }

void send_error(sp_rpc_conn_t conn_, uint16_t code_)
{
    dbmid_error_t error; 
    error.code = code_;
    rpc_t::async_call(conn_, error); 
}

void dbmid_cache_t::insert_acc(db_Account_t& db_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(db_.aid)

    sp_acc_t sp_acc(new dbmid_acc_t);
    db_Account_t& acc = sp_acc->account;
    acc = db_;
    m_aid_acc_cache.put(acc.aid, sp_acc);

    //保存到数据库
    DBMID_SQL(db_.insert(), conn_);

    DBMID_END(db_.aid)
}

void dbmid_cache_t::insert_userid(db_UserID_t& db_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(db_.aid)

    sp_acc_t sp_acc;
    if (m_aid_acc_cache.get(db_.aid, sp_acc))
    {
        auto it = sp_acc->userids.insert(make_pair(db_.uid, db_)).first;
        auto it_host = sp_acc->hostindex.find(db_.hostnum);
        if (it_host == sp_acc->hostindex.end())
        {
            it_host = sp_acc->hostindex.insert(make_pair(db_.hostnum, list<dbmid_acc_t::it_userid_hm_t>())).first;
        }
        list<dbmid_acc_t::it_userid_hm_t>& uids = it_host->second;
        uids.push_back(it);
    }

    //保存到数据库
    DBMID_SQL(db_.insert(), conn_);

    DBMID_END(db_.aid)
}
void dbmid_cache_t::insert_user( db_UserInfo_t& db_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(db_.uid)

    sp_user_t sp_user = sp_user_t(new dbmid_user_t);
    sp_user->user = db_;
    m_user_cache.put(db_.uid, sp_user);

    //保存到数据库
    DBMID_SQL(db_.insert(), conn_);

    DBMID_END(db_.uid)
}
void dbmid_cache_t::insert_team( db_Team_t& db_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(db_.uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_.uid, sp_user))
    {
        sp_user->team = db_;
    }

    //保存到数据库
    DBMID_SQL(db_.insert(), conn_);

    DBMID_END(db_.uid)
}
void dbmid_cache_t::insert_items( vector<db_Item_t>& db_, sp_rpc_conn_t conn_)
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            sp_user->items.insert(make_pair((*it).itid, *it));
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).insert(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::insert_partners( vector<db_Partner_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            sp_user->partners.insert(make_pair((*it).pid, *it));
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).insert(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::insert_skils( vector<db_Skill_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            sp_user->skills.insert(make_pair((*it).skid, *it));
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).insert(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::insert_equip( vector<db_Equip_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            sp_user->equips.insert(make_pair((*it).eid, *it));
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).insert(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::update_acc( db_Account_t& db_, sp_rpc_conn_t conn_ )
{
    DBMID_BEGIN(db_.aid)

    sp_acc_t sp_acc;
    if (m_aid_acc_cache.get(db_.aid, sp_acc))
    {
        sp_acc->account = db_;
    }

    DBMID_SQL(db_.update(), conn_);

    DBMID_END(db_.aid)
}
void dbmid_cache_t::update_userid( db_UserID_t& db_, sp_rpc_conn_t conn_ )
{
    DBMID_BEGIN(db_.aid)

    sp_acc_t sp_acc;
    if (m_aid_acc_cache.get(db_.aid, sp_acc))
    {
        auto it = sp_acc->userids.find(db_.uid);
        if (it != sp_acc->userids.end())
        {
            it->second = db_;
        }
    }

    DBMID_SQL(db_.update(), conn_);

    DBMID_END(db_.aid)
}
void dbmid_cache_t::update_user( db_UserInfo_t& db_, sp_rpc_conn_t conn_ )
{
    DBMID_BEGIN(db_.aid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_.uid, sp_user))
    {
        sp_user->user = db_;
    }

    DBMID_SQL(db_.update(), conn_);

    DBMID_END(db_.aid)
}
void dbmid_cache_t::update_team( db_Team_t& db_, sp_rpc_conn_t conn_ )
{
    DBMID_BEGIN(db_.uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_.uid, sp_user))
    {
        sp_user->team = db_;
    }

    DBMID_SQL(db_.update(), conn_);

    DBMID_END(db_.uid)
}
void dbmid_cache_t::update_items( vector<db_Item_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            auto itt = sp_user->items.find((*it).itid);
            if (itt != sp_user->items.end())
            {
                itt->second = *it;
            }
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).update(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::update_partners( vector<db_Partner_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            auto itt = sp_user->partners.find((*it).pid);
            if (itt != sp_user->partners.end())
            {
                itt->second = *it;
                (*it).update();
            }
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).update(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::update_skils( vector<db_Skill_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            auto itt = sp_user->skills.find((*it).skid);
            if (itt != sp_user->skills.end())
            {
                itt->second = *it;
            }
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).update(), conn_);
    }

    DBMID_END(db_[0].uid)
}
void dbmid_cache_t::update_equip( vector<db_Equip_t>& db_, sp_rpc_conn_t conn_ )
{
    if (db_.empty())
        return;

    DBMID_BEGIN(db_[0].uid)

    sp_user_t sp_user;
    if (m_user_cache.get(db_[0].uid, sp_user))
    {
        for(auto it=db_.begin(); it!=db_.end(); it++)
        {
            auto itt = sp_user->equips.find((*it).eid);
            if (itt != sp_user->equips.end())
            {
                itt->second = *it;
                (*it).update();
            }
        }
    }

    for(auto it=db_.begin(); it!=db_.end(); it++)
    {
        DBMID_SQL((*it).update(), conn_);
    }

    DBMID_END(db_[0].uid)
}
sp_acc_t dbmid_cache_t::select_acc(string& mac_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(mac_)

    sp_acc_t sp_acc;
    if (!m_mac_acc_cache.get(mac_, sp_acc))
    {
        sql_result_t res;
        if (db_Account_t::select_mac(mac_, res))
        {
            send_error(conn_, ERROR_DB_NO_ACC);
            return sp_acc;
        }
        else
        {
            sp_acc = sp_acc_t(new dbmid_acc_t());
            sp_acc->account.init(*res.get_row_at(0));

            if (!db_UserID_t::select_all_uid_state(sp_acc->account.aid, 0, res))
            {
                for (size_t i=0; i<res.affect_row_num(); i++)
                {
                    db_UserID_t userid;
                    userid.init(*res.get_row_at(i));

                    auto it = sp_acc->userids.insert(make_pair(userid.uid, userid)).first;
                    auto it_host = sp_acc->hostindex.find(userid.hostnum);
                    if (it_host == sp_acc->hostindex.end())
                    {
                        it_host = sp_acc->hostindex.insert(make_pair(userid.hostnum, list<dbmid_acc_t::it_userid_hm_t>())).first;
                    }
                    list<dbmid_acc_t::it_userid_hm_t>& uids = it_host->second;
                    uids.push_back(it);
                }
            }
            m_mac_acc_cache.put(mac_, sp_acc);
        }
    }

    DBMID_END(mac_)

    rpc_t::async_call(conn_, *sp_acc);
    return sp_acc;
}
int dbmid_cache_t::select_user(int32_t uid_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(uid_)

    sp_user_t sp_user;
    if (!m_user_cache.get(uid_, sp_user))
    {
        sql_result_t res;
        if (db_UserInfo_t::select_user(uid_, res))
        {
            send_error(conn_, ERROR_DB_NO_USER);
            return ERROR_DB_NO_USER;
        }

        sp_user = sp_user_t(new dbmid_user_t);
        sp_user->user.init(*res.get_row_at(0));

        if (0==db_Team_t::select_team(uid_, res))
        {
            sp_user->team.init(*res.get_row_at(0));
        }

        if (0==db_Partner_t::select_partner(uid_, res))
        {
            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                db_Partner_t db;
                db.init(*res.get_row_at(i));
                sp_user->partners.insert(make_pair(db.pid, db));
            }
        }

        if (0==db_Equip_t::select_equip_exist(uid_, 0, res))
        {
            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                db_Equip_t db;
                db.init(*res.get_row_at(i));
                sp_user->equips.insert(make_pair(db.eid, db));
            }
        }

        if (0==db_Skill_t::select_skill(uid_, res))
        {
            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                db_Skill_t db;
                db.init(*res.get_row_at(i));
                sp_user->skills.insert(make_pair(db.skid, db));
            }
        }

        if (0==db_Item_t::select_item_exist(uid_, 0, res))
        {
            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                db_Item_t db;
                db.init(*res.get_row_at(i));
                sp_user->items.insert(make_pair(db.itid, db));
            }
        }

        m_user_cache.put(uid_, sp_user);
    }

    rpc_t::async_call(conn_, *sp_user);

    DBMID_END(uid_)

    return SUCCESS;
}
int dbmid_cache_t::insert(string& tablename_, string& data_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(tablename_)

    if (tablename_ == "Account")
    {
        db_Account_t db;
        db << data_;
        insert_acc(db, conn_);
        return 0;
    }
    if (tablename_ == "UserID")
    {
        db_UserID_t db;
        db << data_;
        insert_userid(db, conn_);
        return 0;
    }
    if (tablename_ == "Team")
    {
        db_Team_t db;
        db << data_;
        insert_team(db, conn_);
        return 0;
    }
    if (tablename_ == "User")
    {
        db_UserInfo_t db;
        db << data_;
        insert_user(db, conn_);
        return 0;
    }
    if (tablename_ == "Equip")
    {
        dbmid_array_t<db_Equip_t> array; 
        array << data_;
        insert_equip(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Item")
    {
        dbmid_array_t<db_Item_t> array; 
        array << data_;
        insert_items(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Partner")
    {
        dbmid_array_t<db_Partner_t> array; 
        array << data_;
        insert_partners(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Skill")
    {
        dbmid_array_t<db_Skill_t> array; 
        array << data_;
        insert_skils(array.elms, conn_);
        return 0;
    }

    DBMID_END(tablename_)

    return 0;
}
int dbmid_cache_t::update(string& tablename_, string& data_, sp_rpc_conn_t conn_)
{
    DBMID_BEGIN(tablename_)

    if (tablename_ == "Account")
    {
        db_Account_t db;
        db << data_;
        update_acc(db, conn_);
        return 0;
    }
    if (tablename_ == "UserID")
    {
        db_UserID_t db;
        db << data_;
        update_userid(db, conn_);
        return 0;
    }
    if (tablename_ == "Team")
    {
        db_Team_t db;
        db << data_;
        update_team(db, conn_);
        return 0;
    }
    if (tablename_ == "User")
    {
        db_UserInfo_t db;
        db << data_;
        update_user(db, conn_);
        return 0;
    }
    if (tablename_ == "Equip")
    {
        dbmid_array_t<db_Equip_t> array; 
        array << data_;
        update_equip(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Item")
    {
        dbmid_array_t<db_Item_t> array; 
        array << data_;
        update_items(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Partner")
    {
        dbmid_array_t<db_Partner_t> array; 
        array << data_;
        update_partners(array.elms, conn_);
        return 0;
    }
    if (tablename_ == "Skill")
    {
        dbmid_array_t<db_Skill_t> array; 
        array << data_;
        update_skils(array.elms, conn_);
        return 0;
    }

    DBMID_END(tablename_)
    return 0;
}
void dbmid_cache_t::insert_sp_acc(sp_acc_t sp_acc_)
{
    m_aid_acc_cache.put(sp_acc_->account.aid, sp_acc_);
}
//===========================================
void dbmid_cache_mgr_t::start(int thread_num_)
{
    m_caches.resize(thread_num_);
}
void dbmid_cache_mgr_t::conn_db(const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_)
{
    db_service.start(host_.c_str(), port_.c_str(), usr_.c_str(), pwd_.c_str(), database_.c_str(), m_caches.size());
}
dbmid_cache_t& dbmid_cache_mgr_t::get(const string& mac_)
{
    uint32_t hash = crypto_t::crc32(mac_.c_str(), mac_.size());
    return m_caches[hash % m_caches.size()];
}
dbmid_cache_t& dbmid_cache_mgr_t::get(int32_t uid_)
{
    return m_caches[uid_% m_caches.size()];
}
