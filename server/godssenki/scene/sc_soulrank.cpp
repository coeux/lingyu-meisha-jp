#include "sc_item.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_message.h"
#include "sc_cache.h"
#include "sc_soulrank.h"
#include "time.h"
#include "date_helper.h"

#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include <sstream>

#define LOG "SC_SOULRANK"

#define PRO_TYPE  20

sc_soulrank_t::sc_soulrank_t()
{
}

void sc_soulrank_t::init_soulrank()
{
    auto f = [&](vector<int32_t> propertytype,int propertyindex, int promote){

    };
    for(size_t i = 0; i< repo_mgr.soulnode.size();i++)
    {
        repo_def::soulnode_t* rp_soulnode = repo_mgr.soulnode.get(1);
        if (rp_soulnode == NULL)
        {
            logerror((LOG, "repo soulnode no index:%d", i));
            break;
        }
        int32_t id = rp_soulnode->id; 


    }
} 



sc_soulrank_mgr_t::sc_soulrank_mgr_t(sc_user_t& user_):
    m_user(user_)
{

}
void sc_soulrank_mgr_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

void sc_soulrank_mgr_t::init_new_user()
{
    db.uid = m_user.db.uid;
    db.hostnum = m_user.db.hostnum;
    db.soulmoney    = 0;
    db.soullevel    = 1;
    db.soulid       = 0;
    db.ctime        = date_helper.str_date_mysql(0);
    db_service.async_do((uint64_t)m_user.db.uid, [](db_SoulUser_t& db_) {
        db_.insert();
    }, db.data());
}


void sc_soulrank_mgr_t::load_db()
{
    sql_result_t res;
    if(0 ==db_SoulUser_t::sync_select_id(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
        sc_soulrank_mgr_t::init_new_user();
}

void sc_soulrank_mgr_t::unicast_soul_node_info(map<int, sc_msg_def::jpk_soulnode_t>& soul_node_info, int soulid)
{
    if (soulid != 0)
    {
        auto itt_soulnode = repo_mgr.soulnode_info.find(soulid);
        if(itt_soulnode != repo_mgr.soulnode_info.end())
        {
            for(auto infos = itt_soulnode->second.begin();infos != itt_soulnode->second.end(); infos++)
            {
                sc_msg_def::jpk_soulnode_t infos_node;
                for(auto info = infos->second.begin();info != infos->second.end(); info++)
                {
                    infos_node.soul_node_point[info->first] = info->second;
                }
                soul_node_info[infos->first] = infos_node;
            }
        }
    }
}

void sc_soulrank_mgr_t::nt_soul_node_info()
{
    sc_msg_def::nt_soulnode_info_t  ret;
    if (db.soulid != 0)
    {
        auto itt_soulnode = repo_mgr.soulnode_info.find(db.soulid);
        for(auto infos = itt_soulnode->second.begin();infos != itt_soulnode->second.end(); infos++)
        {
            sc_msg_def::jpk_soulnode_t infos_node;
            for(auto info = infos->second.begin();info != infos->second.end(); info++)
            {
                infos_node.soul_node_point[info->first] = info->second;
            }
            ret.soul_node_info[infos->first] = infos_node;
        }
    }
    ret.soulranknum = db.soullevel;
    ret.soulid = db.soulid;
    logic.unicast(m_user.db.uid, ret);
}


int sc_soulrank_mgr_t::on_coin_change(int32_t coin_)
{
    logerror((LOG, "soulrank on_coin_change:uid =%d,coin = %d", m_user.db.uid, coin_));
    if (coin_ == 0) {
        return db.soulmoney;
    }
    db.set_soulmoney(db.soulmoney + coin_);
    if (db.soulmoney < 0) {
        db.set_soulmoney(0);
    }
    sc_msg_def::nt_soulnode_coin_t nt;
    nt.now = db.soulmoney;
    save_db();
    logic.unicast(m_user.db.uid, nt);
    return db.soulmoney;
}



int sc_soulrank_mgr_t::req_open_soulnode(int32_t soulid_)
{
    logerror((LOG, "req open soulnode:uid =%d,soulid = %d", m_user.db.uid, soulid_));
    auto soulinfo = repo_mgr.soulnode.get(soulid_);
    if(NULL == soulinfo)
       return ERROR_SOULNODE_INFO;
    if(db.soulmoney < soulinfo->cost)
        return ERROR_SOULNODE_MONEY;
    if(db.soulid != soulinfo->isfinal)
        return ERROR_SOULNODE_INFO;
    on_coin_change(-soulinfo->cost);
    db.set_soulid(soulid_);
    db.set_soullevel(soulinfo->rank);
    sc_soulrank_mgr_t::nt_soul_node_info();

    //更新伙伴属性
    m_user.on_team_pro_changed();
    save_db();
    return SUCCESS; 
}


map<int,int> sc_soulrank_mgr_t::get_pro_gen(int32_t soulid_, int32_t pro_type_)
{
    map<int,int> pro_gen;
    for(int index = 1;index <=5; index++)
    {
        pro_gen[index] = 0;
    }
    if(soulid_ != 0)
    {
        auto itt_soulnode = repo_mgr.soulnode_info.find(db.soulid);
        for(auto infos = itt_soulnode->second.begin();infos != itt_soulnode->second.end(); infos++)
        {
            if(infos->first == pro_type_)
            {
                for(auto info = infos->second.begin();info != infos->second.end(); info++)
                {
                    pro_gen[info->first] = info->second;
                }
            }
        }
    }
    return pro_gen;
}
