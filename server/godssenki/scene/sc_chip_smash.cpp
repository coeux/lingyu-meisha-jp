#include "sc_chip_smash.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_statics.h"

#include "code_def.h"
#include "repo_def.h"
#include "db_def.h"
#include "date_helper.h"
#include "random.h"
#include "stdlib.h"
#include "time.h"

#define LOG "SC_CHIP_SMASH"

#define SellPrice 1
#define BuyPrice 2

sc_smashitem_t::sc_smashitem_t(sc_user_t& user_):m_user(user_)
{
}

void sc_smashitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_chip_smash_t::sc_chip_smash_t(sc_user_t& user_):m_user(user_)
{
}

void sc_chip_smash_t::load_db()
{
    sql_result_t res;
    if (0 == db_ChipSmash_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_smashitem_t> sp_smashitem(new sc_smashitem_t(m_user));
            sp_smashitem->db.init(*res.get_row_at(i));
            if (sp_smashitem->db.buystamp > buystamp)
            {
                buystamp = sp_smashitem->db.buystamp;
            }
            m_chipsmash_hm.insert(make_pair(sp_smashitem->db.resid, sp_smashitem));
        }
    }
}

// chip_smash_hm_t m_chipsmash_hm;
int sc_chip_smash_t::unicast_smash_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for (auto i = repo_mgr.chip_smash.begin(); i != repo_mgr.chip_smash.end(); i++)
        {
            if(i->second.item_id == NULL)
                break;
            auto it = m_chipsmash_hm.find(i->second.item_id);
            if(it != m_chipsmash_hm.end())
            {
                db_ChipSmash_ext_t &db = it->second->db;
                db.count = 0;
                db.set_count(0);
                it->second->save_db();
            }
        }
    }

    sc_msg_def::ret_chip_smash_items_t ret;
    for (auto i = repo_mgr.chip_smash.begin(); i != repo_mgr.chip_smash.end(); i++)
    {
        auto rp_psmash_ = i->second;
        if (rp_psmash_.item_id == NULL)
            continue;
        int32_t resid_ = rp_psmash_.item_id % 30000;
        if(resid_ == m_user.db.resid)
        {    
            if(m_user.db.quality < 5)
                continue;
        }
        else
        { 
            if(!m_user.partner_mgr.has_hero(resid_))
                continue;
            else
            {   
                auto chippartner = m_user.partner_mgr.getbyresid(resid_);
                if(chippartner->db.quality < 5)
                    continue;
            }
        }
        sc_msg_def::chip_smash_item_t item;
        item.item_id = rp_psmash_.item_id;
        item.name = rp_psmash_.name;
        item.price = rp_psmash_.cost;
        item.value  = chip_value.get_chipvalue(rp_psmash_.item_id, item.trend, SellPrice);
        item.limited = rp_psmash_.islimit;
        int current;
        auto it = m_chipsmash_hm.find(rp_psmash_.item_id);
        if (it == m_chipsmash_hm.end())
            current = 0;
        else 
        {
            current = it->second->db.count;
        }
        item.buy_num = current;
        sp_partnerchip_t sp_chip = m_user.partner_mgr.get_chip(rp_psmash_.item_id);
        if(sp_chip == NULL)
        {
            continue;
        }
        else
        {
            item.chipnum = sp_chip->db.count;
        }
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_chip_smash_t::buy(int32_t id_, int32_t num_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::chip_smash_t* rp_pshop_ = repo_mgr.chip_smash.get(id_);
    if (rp_pshop_ == NULL)
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;

    int32_t resid_ = id_ % 30000;
    if(resid_ == m_user.db.resid)
    {    
        if(m_user.db.quality < 5)
            return ERROR_SC_EXCEPTION;
    }
    else
    { 
        if(!m_user.partner_mgr.has_hero(resid_))
            return ERROR_SC_EXCEPTION;
        else
        {   
            auto chippartner = m_user.partner_mgr.getbyresid(resid_);
            if(chippartner->db.quality < 5)
                return ERROR_SC_EXCEPTION;
        }
    }
    if (rp_pshop_->islimit > 0)
    {
        int32_t current;
        auto it = m_chipsmash_hm.find(rp_pshop_->item_id);
        if (it == m_chipsmash_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_pshop_->islimit)
            return ERROR_SHOP_LIMIT_OUT;
    }
    int32_t price = rp_pshop_->cost * num_;
    if (m_user.db.gold < price && price > 0)
        return ERROR_SC_NO_HONOR;
    sc_msg_def::nt_chip_change_t change;
    if( !m_user.partner_mgr.consume_chip(id_,num_,change) )
        return ERROR_SC_EXCEPTION;
    m_user.partner_mgr.on_chip_change(change);

    m_user.on_money_change(-price);
    m_user.save_db();
   
    sc_msg_def::nt_bag_change_t nt;
    int32_t trend;
    m_user.item_mgr.addnew(16005, chip_value.get_chipvalue(id_,trend, SellPrice) * num_  , nt);
    m_user.item_mgr.on_bag_change(nt);
   
    if (rp_pshop_->islimit > 0)
    {
        auto it = m_chipsmash_hm.find(rp_pshop_->item_id);
        if (it != m_chipsmash_hm.end())
        {
            db_ChipSmash_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_buystamp(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_smashitem_t> sp_smashitem(new sc_smashitem_t(m_user));
            db_ChipSmash_t& db = sp_smashitem->db;
            db.uid = m_user.db.uid;
            db.resid = rp_pshop_->item_id;
            db.count = num_;
            db.buystamp = date_helper.cur_sec();
            m_chipsmash_hm.insert(make_pair(sp_smashitem->db.resid, sp_smashitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_ChipSmash_t& db_){
                db_.insert();
            }, db);
        }
    }
    chip_value.update_chipvalue(id_, -num_);
    statics_ins.unicast_buylog(m_user,rp_pshop_->item_id,rp_pshop_->name,num_,-1,price,0,0,0);
    return SUCCESS;
}

sc_chipvalue_t::sc_chipvalue_t()
{
}

void sc_chipvalue_t::save_db()
{
    string sql = db.get_up_sql();
    if(sql.empty()) return;
    db_service.async_do((uint64_t)db.id, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_chipvalue_mgr_t::sc_chipvalue_mgr_t()
{
}

void sc_chipvalue_mgr_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load chipvalue begin ..."));

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    m_chipvalue_hm.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "select id,hostnum,resid,cur_value,trend from ChipValue where hostnum in (%s);", str_hosts.c_str());
    db_service.sync_select(sql, res);
    double powNum = double(repo_mgr.configure.find(24)->second.value)/10000;
    
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load chipvalue get_row_at is NULL!!, at:%lu", i));
            break;
        }
        sp_chipvalue_t sp_chipvalue(new sc_chipvalue_t);
        sql_result_row_t& row_ = *res.get_row_at(i);
        sp_chipvalue->db.id=(int)std::atoi(row_[0].c_str());
        sp_chipvalue->db.hostnum=(int)std::atoi(row_[1].c_str());
        sp_chipvalue->db.resid=(int)std::atoi(row_[2].c_str());
        sp_chipvalue->db.cur_value=(int)std::atoi(row_[3].c_str());
        sp_chipvalue->db.trend=(int)std::atoi(row_[4].c_str());
        auto rp_pshop_ = repo_mgr.chip_smash.find(sp_chipvalue->db.resid);
        if (rp_pshop_ == repo_mgr.chip_smash.end())
            continue;
        if (sp_chipvalue->db.trend < 0)
        {
            sp_chipvalue->db.price = rp_pshop_->second.base_value * (pow(1 - powNum,abs(sp_chipvalue->db.trend)));
            if(sp_chipvalue->db.price < rp_pshop_->second.min_value)
                sp_chipvalue->db.price = rp_pshop_->second.min_value;

        }
        else if(sp_chipvalue->db.trend > 0) 
        {
            sp_chipvalue->db.price = rp_pshop_->second.base_value * (pow(1 + powNum,abs(sp_chipvalue->db.trend)));
            if(sp_chipvalue->db.price > rp_pshop_->second.max_value)
                sp_chipvalue->db.price = rp_pshop_->second.max_value;
        }
        else
            sp_chipvalue->db.price = rp_pshop_->second.base_value;
        sp_chipvalue->save_db();
        db_ChipValue_t& chipdb = sp_chipvalue->db;
        db_service.async_do((uint64_t)chipdb.id, [](db_ChipValue_t& db_){
                db_.update();
            }, chipdb);

        m_chipvalue_hm.insert( make_pair(sp_chipvalue->db.resid,sp_chipvalue) );
    }

    int32_t id_ = 0;        
    sql_result_t res1;
    char buf[256];
    sprintf(buf,"select max(id) from ChipValue where 1;");
    db_service.sync_select(buf, res1);
    if(res1.affect_row_num() == 0){
        id_ = 1;
    }else{
        sql_result_row_t& row = *res1.get_row_at(0);
        if(row.empty())
            id_ = 1;
        else
            id_ = (int64_t)atoi(row[0].c_str());
    }

    for(auto rp_chipvalue = repo_mgr.chip_smash.begin(); rp_chipvalue != repo_mgr.chip_smash.end(); rp_chipvalue++)
    {
        auto it = m_chipvalue_hm.find(rp_chipvalue->second.item_id);
        if(it !=m_chipvalue_hm.end())
            continue;
        sp_chipvalue_t sp_chipvalue(new sc_chipvalue_t);
        db_ChipValue_t& chipdb = sp_chipvalue->db;
        chipdb.hostnum = sc_service.hostnum();
        chipdb.resid = rp_chipvalue->second.item_id;
        chipdb.price = rp_chipvalue->second.base_value;
        chipdb.cur_value = 0;
        chipdb.trend = 0;
        chipdb.id = id_ + 1;
        id_++;
        db_service.async_do((uint64_t)chipdb.id, [](db_ChipValue_t& db_){
                db_.insert();
            }, chipdb);
        m_chipvalue_hm.insert(make_pair(sp_chipvalue->db.resid,sp_chipvalue));
    }
    logwarn((LOG, "load chipvalue end..."));
}

void sc_chipvalue_mgr_t::update_chipvalue(int32_t chipid_, int32_t value_)
{
    repo_def::chip_smash_t* rp_pshop_ = repo_mgr.chip_smash.get(chipid_);
    if (rp_pshop_ == NULL)
        return;

    double powNum = double(repo_mgr.configure.find(24)->second.value)/10000;
    auto it = m_chipvalue_hm.find(chipid_);
    if(it ==m_chipvalue_hm.end())
        return;        
    if (value_ < 0)
    {
        //价格达到下限
        if(it->second->db.price <= rp_pshop_->min_value)
        {
            if(it->second->db.cur_value + value_ <= 0)
                it->second->db.cur_value = 0;
            else
                it->second->db.cur_value = it->second->db.cur_value + value_;
                
            it->second->db.price = rp_pshop_->min_value;
            it->second->save_db();
        }
        //满足降价条件
        else if(it->second->db.cur_value + value_ <= -repo_mgr.configure.find(23)->second.value)
        {
            it->second->db.trend = it->second->db.trend - 1;
            it->second->db.price = rp_pshop_->base_value * (pow(1-powNum,abs(it->second->db.trend)));
            if(it->second->db.price<= rp_pshop_->min_value)
                it->second->db.price = rp_pshop_->min_value;
            it->second->db.cur_value = 0;
            it->second->save_db();
            sc_msg_def::nt_chip_value_changed_t nt;
            nt.id = chipid_;
            nt.price = it->second->db.price;
            nt.buyprice = it->second->db.price * rp_pshop_->income_rate;
            nt.trend = it->second->db.trend;
            string message;
            nt >> message;
            logic.usermgr().broadcast(sc_msg_def::nt_chip_value_changed_t::cmd(),message);
        }
        else
        {
            it->second->db.cur_value = it->second->db.cur_value + value_;
            it->second->save_db();
        }
    }
    else
    {
        //价格达到上限
        if(it->second->db.price >= rp_pshop_->max_value)
        {
            if(it->second->db.cur_value + value_ >= 0)
                it->second->db.cur_value = 0;
            else
                it->second->db.cur_value = it->second->db.cur_value + value_;

            it->second->db.price = rp_pshop_->max_value;
            it->second->save_db();
        }
        else if(it->second->db.cur_value + value_ >= repo_mgr.configure.find(23)->second.value)
        {
            it->second->db.trend = it->second->db.trend + 1;
            it->second->db.price = rp_pshop_->base_value * (pow(1+powNum,abs(it->second->db.trend)));
            if(it->second->db.price >= rp_pshop_->max_value)
                it->second->db.cur_value = rp_pshop_->max_value;
            it->second->db.cur_value = 0;
            it->second->save_db();
            sc_msg_def::nt_chip_value_changed_t nt;
            nt.id = chipid_;
            nt.price = it->second->db.price;
            nt.buyprice = it->second->db.price * rp_pshop_->income_rate;
            nt.trend = it->second->db.trend;
            string message;
            nt >> message;
            logic.usermgr().broadcast(sc_msg_def::nt_chip_value_changed_t::cmd(),message);

        }
        else
        {
            it->second->db.cur_value = it->second->db.cur_value + value_;
            it->second->save_db();
        }
    }
    db_ChipValue_t& chipdb = it->second->db;
    db_service.async_do((uint64_t)chipdb.id, [](db_ChipValue_t& db_){
                db_.update();
            }, chipdb);

}

int sc_chipvalue_mgr_t::get_chipvalue(int32_t chipid_,int32_t& trend, int32_t type_)
{
    double rate;
    repo_def::chip_smash_t* rp_pshop_ = repo_mgr.chip_smash.get(chipid_);
    if(rp_pshop_ != NULL)
        rate = rp_pshop_->income_rate;
    else
        rate = 1.1;
    auto it = m_chipvalue_hm.find(chipid_);
    if(it !=m_chipvalue_hm.end())
        trend = it->second->db.trend;
        if(type_ == SellPrice)
            return it->second->db.price;
        else if(type_ == BuyPrice)
            return it->second->db.price * rate; 
    else
    {    
        trend = 0;
        if(type_ == SellPrice)
            return rp_pshop_->base_value;
        else if(type_ == BuyPrice)
            return rp_pshop_->base_value * rate;
    }
    return 999;
}
