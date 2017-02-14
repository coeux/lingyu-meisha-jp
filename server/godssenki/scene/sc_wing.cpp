#include "sc_wing.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_WING"

sc_wing_t::sc_wing_t(sc_user_t& user_):m_user(user_)
{
}
void sc_wing_t::get_wing_jpk(sc_msg_def::jpk_wing_t& jpk_)
{
    jpk_.wid = db.wid;
    jpk_.resid = db.resid;
    jpk_.atk = db.atk;
    jpk_.mgc = db.mgc;
    jpk_.def = db.def;
    jpk_.res = db.res;
    jpk_.hp = db.hp;
    jpk_.crit = db.crit;
    jpk_.acc = db.acc;
    jpk_.dodge = db.dodge;
    jpk_.lucky = db.lucky;
}
void sc_wing_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
//====================================================================
sc_wing_mgr_t::sc_wing_mgr_t(sc_user_t& user_):m_user(user_)
{
}
void sc_wing_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Wing_t::sync_select_wing_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_wing_t> sp_wing(new sc_wing_t(m_user));
            sp_wing->db.init(*res.get_row_at(i));
            m_wing_hm.insert(make_pair(sp_wing->db.wid, sp_wing));
            m_maxid.update(sp_wing->db.wid);
            if (sp_wing->db.isweared)
                m_weared = sp_wing;
        }
    }
}
sp_wing_t sc_wing_mgr_t::get(int32_t wid_)
{
    auto it = m_wing_hm.find(wid_);
    if (it != m_wing_hm.end())
        return it->second;
    return sp_wing_t();
}
bool sc_wing_mgr_t::addnew(int32_t resid_,int32_t num_,sc_msg_def::nt_bag_change_t& change_)
{
    auto rp_wing = repo_mgr.wing.get(resid_);
    if (rp_wing == NULL)
    {
        logerror((LOG, "addnew error!,resid:%d, num:%d", resid_, num_));
        return false;
    }

    for ( int i =0;i<num_;++i)
    {
        boost::shared_ptr<sc_wing_t> sp_wing(new sc_wing_t(m_user));

        db_Wing_t& db = sp_wing->db.data();
        memset( &db, 0, sizeof(db) );

        db.uid = m_user.db.uid;
        db.wid = m_maxid.newid(); 
        db.resid = resid_;
        db.isweared = 0;
        genpro(sp_wing);
        
        m_wing_hm.insert(make_pair(sp_wing->db.wid, sp_wing));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Wing_t& db_){
                db_.insert();
        }, db);

        sc_msg_def::jpk_wing_t jpk;
        sp_wing->get_wing_jpk(jpk);
        change_.add_wings.push_back(std::move(jpk));
    }

    return true;
}
bool sc_wing_mgr_t::addnew(int32_t source_resid_, int32_t target_type_, int32_t num_,sc_msg_def::nt_bag_change_t& change_)
{
    for ( int n =0;n<num_;++n)
    {
        auto rp_wing = repo_mgr.wing.get(source_resid_);
        if (rp_wing == NULL)
            return false;
/*
        std::vector<int>* rare_pro = &(rp_wing->genpro);
        if (IS_REPO_ARRAY_EMPTY(rp_wing->genpro)){
            rare_pro = &(rp_wing->pro);
        }
        if (IS_REPO_ARRAY_EMPTY(*rare_pro))
            return false;

        int r = random_t::rand_integer(1, 10000);
        int p = 0;
        int rare = 0;
        for(size_t i=1; i<rare_pro->size();++i)
        {
            p += rare_pro->at(i);
            if (r<=p)
            {
                rare = i;
                break;
            }
        }
*/
        int target_resid = target_type_;
        auto rp_target = repo_mgr.wing.get(target_resid);
        if (rp_target == NULL)
            return false;

        boost::shared_ptr<sc_wing_t> sp_wing(new sc_wing_t(m_user));

        db_Wing_t& db = sp_wing->db;
        memset( &db, 0, sizeof(db) );

        db.uid = m_user.db.uid;
        db.wid = m_maxid.newid(); 
        db.resid = target_resid;
        db.isweared = 0;
        genpro(sp_wing);
        
        m_wing_hm.insert(make_pair(sp_wing->db.wid, sp_wing));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Wing_t& db_){
                db_.insert();
        }, db);

        sc_msg_def::jpk_wing_t jpk;
        sp_wing->get_wing_jpk(jpk);
        change_.add_wings.push_back(std::move(jpk));
    }
    return true;
}
void sc_wing_mgr_t::remove(int wid_)
{
    if (m_weared != NULL && m_weared->db.wid == wid_)
        return; 

    sp_wing_t sp_wing = get(wid_);
    if (sp_wing == NULL)
        return; 

    sc_msg_def::nt_bag_change_t nt;
    nt.del_wings.resize(1);
    sp_wing->get_wing_jpk(nt.del_wings[0]);
    logic.unicast(m_user.db.uid, nt);

    m_wing_hm.erase(wid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Wing_t& db_){
        db_.remove();
    }, sp_wing->db.data());
}
void sc_wing_mgr_t::genpro(sp_wing_t sp_wing_)
{
    db_Wing_t& db = sp_wing_->db;
    auto rp_wing = repo_mgr.wing.get(db.resid);
    if (rp_wing == NULL)
        return ;

    db.atk = random_t::rand_integer(rp_wing->atk[1], rp_wing->atk[2]);
    db.mgc = random_t::rand_integer(rp_wing->mgc[1], rp_wing->mgc[2]);
    db.def = random_t::rand_integer(rp_wing->def[1], rp_wing->def[2]);
    db.res = random_t::rand_integer(rp_wing->res[1], rp_wing->res[2]);
    db.hp = random_t::rand_integer(rp_wing->hp[1], rp_wing->hp[2]);
    db.crit = 0;
    db.acc = 0;
    db.dodge = 0;
}
int sc_wing_mgr_t::wear(int32_t wid_)
{
    if (m_weared != NULL)
    {
        takeoff(m_weared->db.wid);
    }

    sp_wing_t wearing = get(wid_);
    if (wearing == NULL)
        return ERROR_SC_ILLEGLE_REQ; 
    if (wearing->db.isweared == 1)
        return ERROR_SC_ILLEGLE_REQ; 

    m_weared = wearing;
    m_weared->db.set_isweared(1);
    m_weared->save_db();

    sc_msg_def::nt_bag_change_t bagchange;
    sc_msg_def::jpk_wing_t jpk;
    m_weared->get_wing_jpk(jpk);
    bagchange.del_wings.push_back(std::move(jpk));
    logic.unicast(m_user.db.uid, bagchange);

    m_user.on_team_pro_changed();

    save_db_userid();

    return SUCCESS;
}
int sc_wing_mgr_t::takeoff(int32_t wid_)
{
    if (m_weared == NULL)
        return ERROR_SC_ILLEGLE_REQ; 
    if (m_weared->db.wid != wid_)
        return ERROR_SC_ILLEGLE_REQ; 
    m_weared->db.set_isweared(0);
    m_weared->save_db();

    sc_msg_def::nt_bag_change_t bagchange;
    sc_msg_def::jpk_wing_t jpk;
    m_weared->get_wing_jpk(jpk);
    bagchange.add_wings.push_back(std::move(jpk));
    logic.unicast(m_user.db.uid, bagchange);

    m_weared.reset();

    m_user.on_team_pro_changed();

    save_db_userid();

    return SUCCESS;
}
void sc_wing_mgr_t::compose(int32_t wid_)
{
    sc_msg_def::ret_compose_wing_t ret_;
    sp_wing_t sp_wing = get(wid_);
    if (sp_wing == NULL)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    auto rp_wing = repo_mgr.wing.get(sp_wing->db.resid);
    if (rp_wing == NULL)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    auto rp_compose = repo_mgr.wing_compose.get(sp_wing->db.resid);
    if (rp_compose == NULL)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    if (rp_compose->stuff_1_num > 0 && m_user.item_mgr.get_items_count(rp_compose->stuff_1)<rp_compose->stuff_1_num)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    logerror((LOG, "compose :%d", wid_));
    
    ret_.wid = wid_;
    ret_.flag = 0;
    int newid = rp_compose->former_equip;
    if (newid == 0)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    int aim_resid;
    bool back_door = false;
    //jp
    /* 
    if (newid % 100 == 30 && m_user.db.viplevel >= 10)
    {
        int rare_new = sp_wing->db.resid % 10 + 1;
        aim_resid = newid + (rare_new <= 5 ? rare_new : 5);
        back_door = true;
    }
    if (newid % 100 == 40 && m_user.db.viplevel >= 12)
    {
        int rare_new = sp_wing->db.resid % 10 + 1;
        aim_resid = newid + (rare_new <= 5 ? rare_new : 5);
        back_door = true;
    }
    if (newid % 100 == 50 && m_user.db.viplevel >= 14)
    {
        int rare_new = sp_wing->db.resid % 10 + 1;
        aim_resid = newid + (rare_new <= 5 ? rare_new : 5);
        back_door = true;
    }
    */
    if (!back_door)
    {
        int r = random_t::rand_integer(1, 10000);
        int sum = 0;
        for(int i=1;i<=5;++i)
        {
            sum += rp_wing->pro[i];
            if (r <= sum)
            {
                aim_resid = newid+i;
                break;
            }
        }
    }
    ret_.resid = aim_resid;
    
    auto aim_rp_wing = repo_mgr.wing.get(aim_resid);
    if (aim_rp_wing == NULL)
    {
        ret_.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }

    sp_wing->db.set_resid(aim_resid);
    genpro(sp_wing);
    sp_wing->db.set_atk(sp_wing->db.atk);
    sp_wing->db.set_mgc(sp_wing->db.mgc);
    sp_wing->db.set_def(sp_wing->db.def);
    sp_wing->db.set_res(sp_wing->db.res);
    sp_wing->db.set_hp(sp_wing->db.hp);
    ret_.atk = sp_wing->db.atk;
    ret_.mgc = sp_wing->db.mgc;
    ret_.def = sp_wing->db.def;
    ret_.res = sp_wing->db.res;
    ret_.hp = sp_wing->db.hp;
    sp_wing->save_db();
    m_user.reward.update_wingselected((aim_resid / 10)%10);
    m_user.reward.update_limit_activity_wing((aim_resid / 10)%10);
    //扣道具
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(rp_compose->stuff_1, rp_compose->stuff_1_num, nt);
    m_user.item_mgr.on_bag_change(nt);
    ret_.code = SUCCESS;
    m_user.on_team_pro_changed();
    logic.unicast(m_user.db.uid, ret_);
}
int32_t sc_wing_mgr_t::split(int32_t wid_)
{
    if (m_weared != NULL && m_weared->db.wid == wid_)
    {
        takeoff(wid_);
    }

    sp_wing_t sp_wing = get(wid_);
    if (sp_wing == NULL)
        return ERROR_SC_ILLEGLE_REQ;
    auto rp_wing = repo_mgr.wing.get(sp_wing->db.resid);
    if (rp_wing == NULL)
        return ERROR_SC_EXCEPTION;
    auto rp_compose = repo_mgr.wing_compose.get(sp_wing->db.resid);
    if (rp_compose == NULL)
        return ERROR_SC_EXCEPTION;

    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(rp_compose->stuff_1, rp_wing->split, nt);
    m_user.item_mgr.on_bag_change(nt);

    remove(wid_);

    return SUCCESS;
}
int32_t sc_wing_mgr_t::sell(int32_t wid_)
{
    if (m_weared != NULL && m_weared->db.wid == wid_)
        return ERROR_SC_ILLEGLE_REQ; 

    sp_wing_t sp_wing = get(wid_);
    if (sp_wing == NULL)
        return ERROR_SC_ILLEGLE_REQ; 

    sc_msg_def::nt_bag_change_t nt;
    nt.del_wings.resize(1);
    nt.del_wings[0].wid = sp_wing->db.wid;
    logic.unicast(m_user.db.uid, nt);

    m_wing_hm.erase(wid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Wing_t& db_){
        db_.remove();
    }, sp_wing->db.data());

    return SUCCESS;
}
int32_t sc_wing_mgr_t::bag_size()
{
    if (m_weared != NULL)
        return m_wing_hm.size()-1;
    return m_wing_hm.size();
}
void sc_wing_mgr_t::save_db_userid()
{
    int wingid = 0;
    if (m_weared != NULL)
        wingid = m_weared->db.resid;
    db_service.async_do((uint64_t)m_user.db.uid, [](int32_t uid_, int wingid_){
        char buf[256];
        sprintf(buf, "update UserID set wingid=%d where uid=%d", wingid_, uid_);
        db_service.async_execute(buf);
    }, m_user.db.uid, wingid);
}
