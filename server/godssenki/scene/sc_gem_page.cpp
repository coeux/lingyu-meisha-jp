#include "sc_gem_page.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"

#define LOG "SC_GEMPAGE"

sc_gem_t::sc_gem_t(sc_user_t& user_)
:m_user(user_)
{
}

void
sc_gem_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

int32_t
sc_gem_t::inlay(int32_t resid_, sc_msg_def::ret_gemstone_inlay_t& ret_)
{
    repo_def::gemstone_t *rp_gem = repo_mgr.gemstone.get(resid_);
    if (rp_gem == NULL)
    {
        logerror((LOG, "repo no gemstone resid:%d", resid_));
        return ERROR_GEM_NO_REPO;
    }

    db.set_resid(resid_);
    save_db();

    //通知背包改变
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(resid_, 1, nt);
    m_user.item_mgr.on_bag_change(nt);

    // 通知角色属性变化
    m_user.on_team_pro_changed();

    ret_.resid = resid_;
    ret_.pageid = db.pageid;
    ret_.slotid = db.gemtype*10+db.slotid;
    ret_.flag = 1;

    m_user.reward.update_opentask(open_task_gem_count);
    return SUCCESS;
}

int32_t
sc_gem_t::unlay(sc_msg_def::ret_gemstone_inlay_t& ret_)
{
    int32_t resid_ = db.resid;
    db.set_resid(0);
    save_db();

    //通知背包改变
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(resid_, 1, nt);
    m_user.item_mgr.on_bag_change(nt);

    // 通知角色属性变化
    m_user.on_team_pro_changed();

    ret_.resid = resid_;
    ret_.pageid = db.pageid;
    ret_.slotid = db.gemtype*10+db.slotid;
    ret_.flag = 2;

    return SUCCESS;
}

//==========================================================================================
sc_gem_page_t::sc_gem_page_t(sc_user_t& user_)
:m_user(user_)
{
}

void
sc_gem_page_t::load_db()
{
    for(int32_t pageid=1;pageid<=5;++pageid)
    {
        unordered_map<int32_t, unordered_map<int32_t, sp_gem_t>> gemtype_map;
        for(int32_t gemtype=17100;gemtype<=17500;gemtype+=100)
        {
            unordered_map<int32_t, sp_gem_t> slot_map;
            for(int32_t slotid=1;slotid<=5;++slotid)
            {
                boost::shared_ptr<sc_gem_t> sp_gem(new sc_gem_t(m_user));
                sp_gem->db.uid = m_user.db.uid;
                sp_gem->db.pageid = pageid;
                sp_gem->db.gemtype = gemtype;
                sp_gem->db.slotid = slotid;
                sp_gem->db.resid = 0;
                slot_map.insert(make_pair(slotid, sp_gem));
            }
            gemtype_map.insert(make_pair(gemtype, slot_map));
        }
        gem_map.insert(make_pair(pageid, gemtype_map));
    }
    sql_result_t res;
    if (0==db_GemPage_t::sync_select_uid(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db_GemPage_ext_t db;
            db.init(*res.get_row_at(i));
            gem_map[db.pageid][db.gemtype][db.slotid]->db.init(*res.get_row_at(i));
        }
    }
    else
    {
        init_new_user();
    }
}

void
sc_gem_page_t::init_new_user()
{
    for(int32_t pageid=1;pageid<=5;++pageid)
    {
        unordered_map<int32_t, unordered_map<int32_t, sp_gem_t>> gemtype_map;
        for(int32_t gemtype=17100;gemtype<=17500;gemtype+=100)
        {
            unordered_map<int32_t, sp_gem_t> slot_map;
            for(int32_t slotid=1;slotid<=5;++slotid)
            {
                boost::shared_ptr<sc_gem_t> sp_gem(new sc_gem_t(m_user));
                sp_gem->db.uid = m_user.db.uid;
                sp_gem->db.pageid = pageid;
                sp_gem->db.gemtype = gemtype;
                sp_gem->db.slotid = slotid;
                sp_gem->db.resid = 0;
                slot_map.insert(make_pair(slotid, sp_gem));
            }
            gemtype_map.insert(make_pair(gemtype, slot_map));
        }
        gem_map.insert(make_pair(pageid, gemtype_map));
    }
    for(int32_t pageid=1;pageid<=5;++pageid)
    {
        auto gemtype_map = gem_map[pageid];
        for(int32_t gemtype=17100;gemtype<=17500;gemtype+=100)
        {
            auto slot_map = gemtype_map[gemtype];
            for(int32_t slotid=1;slotid<=5;++slotid)
            {
                db_GemPage_t& gpdb = slot_map[slotid]->db;
                db_GemPage_t db;
                db.uid = gpdb.uid;
                db.pageid = gpdb.pageid;
                db.gemtype = gpdb.gemtype;
                db.slotid = gpdb.slotid;
                db.resid = gpdb.resid;
                db_service.async_do((uint64_t)m_user.db.uid, [](db_GemPage_t& db_){
                    db_.insert();
                }, db);
            }
        }
    }
}

int32_t
sc_gem_page_t::get(int32_t pageid_, int32_t slotid_, sp_gem_t& sp_gem)
{
    auto it_page=gem_map.find(pageid_);
    if (it_page==gem_map.end())
    {
        return ERROR_NO_SUCH_PAGE;
    }

    int32_t type = slotid_/10;
    int32_t slot = slotid_%10;

    auto it_type=it_page->second.find(type);
    if (it_type==it_page->second.end())
    {
        return ERROR_NO_SUCH_TYPE;
    }

    auto it_slot=it_type->second.find(slot);
    if (it_slot==it_type->second.end())
    {
        return ERROR_NO_SUCH_POS;
    }

    sp_gem = it_slot->second;
    return SUCCESS;
}


int32_t
sc_gem_page_t::get_gem_info(sc_msg_def::ret_gem_page_info_t& ret_)
{
    for(auto it_page=gem_map.begin();it_page!=gem_map.end();++it_page)
    {
        sc_msg_def::gem_page page_;
        for(auto it_type=it_page->second.begin();it_type!=it_page->second.end();++it_type)
        {
            for(auto it_slot=it_type->second.begin();it_slot!=it_type->second.end();++it_slot)
            {
                page_.slot_map.insert(make_pair(it_type->first*10+it_slot->first, it_slot->second->db.resid));
            }
        }
        ret_.gem_page_map.insert(make_pair(it_page->first, page_));
    }
    return SUCCESS;
}

int32_t
sc_gem_page_t::get_attribute(int32_t pageid_, int32_t gem_type_)
{
    auto it_page = gem_map.find(pageid_);
    if (it_page == gem_map.end())
        return 0;
    auto it_type = it_page->second.find(gem_type_);
    if (it_type == it_page->second.end())
        return 0;
    
    int32_t sum=0;
    for (auto it_slot=it_type->second.begin(); it_slot!=it_type->second.end(); ++it_slot)
    {
        auto rp_gem = repo_mgr.gemstone.get(it_slot->second->db.resid);
        if (rp_gem != NULL)
        {
            sum += rp_gem->value;
        }
    }
    return sum;
}
