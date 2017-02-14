#include "sc_farm.h"
#include "sc_user.h"
#include "sc_logic.h"

#include "ys_tool.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "time.h"
#include "date_helper.h"
#include <sstream>

#define LOG "SC_FARM"

#define FARM_NUM    9
#define FARM_LV     3
#define FARM_LV     6
#define FARM_LV     9

sc_farmitem_t::sc_farmitem_t(sc_user_t& user_):m_user(user_)
{
}

void sc_farmitem_t::save_db()
{
    string sql = db.get_up_sql();
    if(sql.empty()) return;
    db_service.async_do((uint64_t)db.farmid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

sc_farm_mgr_t::sc_farm_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_farm_mgr_t::load_db()
{
    sql_result_t res;
    if(0==db_HomeFarm_t::sync_select_id(m_user.db.uid, res))
    {
        for(size_t i = 0; i < res.affect_row_num();i++)
        {
            boost::shared_ptr<sc_farmitem_t> sp_farm(new sc_farmitem_t(m_user));
            sp_farm->db.init(*res.get_row_at(i));
            m_farm_hm.insert(make_pair(sp_farm->db.farmid, sp_farm));
        }
    }
}

int sc_farm_mgr_t::unicast_farm_item()
{
    sc_msg_def::ret_farm_items_t ret;
    if(m_farm_hm.size() < FARM_NUM)
    {
        for(int i = 0; i < FARM_NUM; ++i)
        {
            auto it = m_farm_hm.find(i+1);
            if(it == m_farm_hm.end())
            {
                boost::shared_ptr<sc_farmitem_t> sp_farmitem(new sc_farmitem_t(m_user));
                db_HomeFarm_t& db = sp_farmitem->db;
                db.uid          = m_user.db.uid;
                db.farmid       = i;
                db.itemid       = 0;
                db.isend        = 0;
                db.getnum       = 0;
                db.getstamp     = 0;
                db.losetime     = 0;
                db.canrob       = 0;
                db.cstamp       = 0;
                m_farm_hm.insert(make_pair(sp_farmitem->db.farmid, sp_farmitem));
                db_service.async_do((uint64_t)i, [](db_HomeFarm_t& db_){
                    db_.insert();
                }, db);
            }
        }   
    }

    for(int i = 0; i < FARM_NUM; ++i)
    {
        auto it = m_farm_hm.find(i+1);
        if(it == m_farm_hm.end())
            continue;
    
        db_HomeFarm_t db = it->second->db;
        sc_msg_def::jpk_farm_item_t item;
        item.farmid = db.farmid;
        item.itemid = db.itemid;
        item.isend  = db.isend;
        item.getstamp = db.getstamp;
        item.losetime = db.losetime;
        item.canrob = db.canrob;
        item.cstamp = db.cstamp;

        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int32_t sc_farm_mgr_t::plant_farm_item(int32_t farmid_, int32_t resid_)
{
    if(farmid_ >FARM_NUM || farmid_ < 0)
        return ERROR_SC_EXCEPTION;
    auto farminfo = m_farm_hm.find(farmid_);
    if(farminfo == m_farm_hm.end())
        return ERROR_SC_EXCEPTION;
    db_HomeFarm_t db = farminfo->second->db;
    if(db.itemid != 0)
        return ERROR_SC_EXCEPTION;
    if(db.isend != 0)
        return ERROR_SC_EXCEPTION;
    auto it_farm = repo_mgr.residence_plant.find(resid_);
    if(it_farm == repo_mgr.residence_plant.end())
        return ERROR_SC_EXCEPTION;
    db.itemid = resid_;
    db.getnum = it_farm->second.harvest_count[1];
    db.cstamp = date_helper.cur_sec();
    db.getstamp = db.cstamp + it_farm->second.growth_stage;
    db.losetime = db.getstamp + it_farm->second.maturation_stage;
    db.canrob = it_farm->second.is_robbed;
    farminfo->second->save_db(); 

    sc_msg_def::ret_plant_item ret;
    ret.code = SUCCESS;
    ret.res.farmid = farmid_;
    ret.res.itemid = db.itemid;
    ret.res.isend = db.getnum;
    ret.res.isend   = 0;
    ret.res.getnum = db.getnum;
    ret.res.getstamp = db.cstamp;
    ret.res.losetime = db.losetime;
    ret.res.canrob = db.canrob;
    ret.res.cstamp = db.cstamp;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int32_t sc_farm_mgr_t::harvest_farm_item(int32_t farmid_)
{
    if(farmid_ >FARM_NUM || farmid_ < 0)
        return ERROR_SC_EXCEPTION;
    auto farminfo = m_farm_hm.find(farmid_);
    if(farminfo == m_farm_hm.end())
        return ERROR_SC_EXCEPTION;
    db_HomeFarm_t db = farminfo->second->db;
    if(db.itemid == 0)
        return ERROR_SC_EXCEPTION;
    if(db.isend != 0)
        return ERROR_SC_EXCEPTION;
    auto it_farm = repo_mgr.residence_plant.find(db.itemid);
    if(it_farm == repo_mgr.residence_plant.end())
        return ERROR_SC_EXCEPTION;
    if(db.cstamp + db.getstamp < date_helper.cur_sec())
        return ERROR_SC_EXCEPTION;
    if(db.cstamp + db.losetime >= date_helper.cur_sec())
        return ERROR_SC_EXCEPTION;
        
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(it_farm->second.harvest_id, db.getnum, nt);
    if (nt.items.empty())
    {
        logerror((LOG, "buy add items error!"));
        return ERROR_SC_EXCEPTION;
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);
    return SUCCESS;

}

