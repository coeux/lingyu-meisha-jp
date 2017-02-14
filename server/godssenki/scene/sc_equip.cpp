#include "sc_equip.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_guidence.h"
#include "sc_statics.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_EQUIP"

sc_equip_t::sc_equip_t(sc_user_t& user_):m_user(user_)
{
}
void sc_equip_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
int32_t sc_equip_t::level()
{
    repo_def::equip_t* rp_equip = repo_mgr.equip.get(db.resid);
    if (rp_equip == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", db.resid));
        return ERROR_SC_EXCEPTION;
    }
    //return rp_equip->level; 
    return 1;
}
int32_t sc_equip_t::upgrade(int num_)
{
    int role_lv = 0;
    if (db.pid == 0)
    {
        role_lv = m_user.db.grade;
    }
    else
    {
        auto partner = m_user.partner_mgr.get(db.pid);
        if (partner == NULL)
        {
            logerror((LOG, "equip upgrade no partner, uid:%d, pid:%d", m_user.db.uid, db.pid));
            return ERROR_SC_EXCEPTION;
        }
        role_lv = partner->db.grade;
    }

    if (num_ <= 0)
    {
        return ERROR_SC_ILLEGLE_REQ;
    }

    repo_def::equip_t* rp_equip = repo_mgr.equip.get(db.resid);
    if (rp_equip == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", db.resid));
        return ERROR_SC_EXCEPTION;
    }

    int n=1;
    int sum = 0;
    repo_def::equip_upgrade_pay_t* rp_pay =NULL;
    for(; n<=num_; n++)
    {
        if (db.strenlevel+n > rp_equip->upgrade_lv || db.strenlevel >= role_lv)
            break;

        rp_pay = repo_mgr.equip_up_pay.get(db.strenlevel+n); 
        if (rp_pay== NULL)
            break;

        sum += rp_pay->money;
    }

    float discount_ = m_user.love_task.get_gold_discount(db.pid);
    if (sum <= 0)
        return ERROR_SC_EXCEPTION;

    if (m_user.db.gold < sum * discount_ )
        return ERROR_EQ_LESS_MONEY;

    n--;

    m_user.on_money_change(-sum * discount_);

    db.set_strenlevel(db.strenlevel+n);
    save_db();

    //通知装备升级后的角色属性改变
    m_user.on_pro_changed(db.pid);

    sc_msg_def::ret_upgrade_equip_t ret;
    ret.pid = db.pid;
    get_equip_jpk(ret.equip);
    logic.unicast(m_user.db.uid, ret);
    
    //开服任务
    if(db.strenlevel >= 25)
        m_user.reward.update_opentask(open_task_equip_lv);

    //设置新手引导步骤
    if( (m_user.db.isnew & (1<< evt_guidence_equip)) == 0 )
        guidence_ins.on_guidence_event(m_user,evt_guidence_equip);

    for(int i=0; i<n; i++)
        m_user.daily_task.on_event(evt_equip_upgrade);
    m_user.achievement.on_event(evt_equip_lv, n);
    return SUCCESS;
}

int32_t sc_equip_t::compose_by_yb(int32_t dst_resid_)
{
    repo_def::equip_compose_t* rp_compose = repo_mgr.equip_compose.get(dst_resid_);
    if (rp_compose == NULL)
    {
        return ERROR_SC_EXCEPTION;
    }
    /*
    if (rp_compose->former_equip != db.resid)
    {
        return ERROR_EQ_ILLEGLE_COMPOSE;
    }
*/
    //判断是否有图纸
    int32_t sum_yb=0;
    if ( !m_user.item_mgr.has_items(rp_compose->stuff_4, rp_compose->stuff_4_num) ) 
    {
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_compose->stuff_4);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;

        int price = rp_item->price_yb * rp_compose->stuff_4_num;
        if (price <= 0)
            return ERROR_SC_EXCEPTION;

        if (m_user.rmb() < price)
            return ERROR_SC_NO_YB;

        sum_yb += price;
    }

    //判断a材料是否满足
    int32_t count_a = m_user.item_mgr.get_items_count(rp_compose->stuff_1);
    if( count_a < rp_compose->stuff_1_num )
    {
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_compose->stuff_1);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;

        sum_yb += (rp_compose->stuff_1_num-count_a) * rp_item->price_yb;
    }
    else count_a = rp_compose->stuff_1_num ;

    //判断b材料是否满足
    int32_t count_b = m_user.item_mgr.get_items_count(rp_compose->stuff_2);
    if( count_b < rp_compose->stuff_2_num )
    {
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_compose->stuff_2);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;

        sum_yb += (rp_compose->stuff_2_num-count_b) * rp_item->price_yb;
    }
    else count_b = rp_compose->stuff_2_num ;

    //判断c材料是否满足
    int32_t count_c = m_user.item_mgr.get_items_count(rp_compose->stuff_3);
    if( count_c < rp_compose->stuff_3_num )
    {
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_compose->stuff_3);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;

        sum_yb += (rp_compose->stuff_3_num-count_c) * rp_item->price_yb;
    }
    else count_c = rp_compose->stuff_3_num ;

    //扣水晶
    if( sum_yb > 0 )
    {
        int32_t code = m_user.vip.buy_vip(vop_equip_compose_buy, sum_yb);
        if (code != SUCCESS)
            return code;
    }

    //扣道具
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(rp_compose->stuff_1, count_a, nt);
    m_user.item_mgr.consume(rp_compose->stuff_2, count_b, nt);
    m_user.item_mgr.consume(rp_compose->stuff_3, count_c, nt);
    m_user.item_mgr.consume(rp_compose->stuff_4, rp_compose->stuff_4_num, nt);
    //通知合成后的背包改变
    m_user.item_mgr.on_bag_change(nt);

    //保存装备信息
    db.set_resid(rp_compose->rankup_id);
    save_db();

    //记录事件
    statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),db.resid,1,0,-1);
    statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),rp_compose->rankup_id,1,0,1);

    //通知合成后的角色属性改变
    m_user.on_pro_changed(db.pid);

    //通知合成后的装备信息
    sc_msg_def::ret_compose_equip_t ret;
    ret.pid = db.pid;
    get_equip_jpk(ret.equip);
    logic.unicast(m_user.db.uid, ret);

    //设置新手引导步骤
    guidence_ins.on_guidence_event(m_user,evt_guidence_uplevel);

    return SUCCESS;
}
int32_t sc_equip_t::compose(int32_t dst_resid_)
{
    repo_def::equip_compose_t* rp_compose = repo_mgr.equip_compose.get(dst_resid_);
    if (rp_compose == NULL)
    {
        return ERROR_SC_EXCEPTION;
    }

    if (rp_compose->id != db.resid)
    {
        return ERROR_EQ_ILLEGLE_COMPOSE;
    }

    /*
    if (db.isweared && m_user.db.grade < level())
    {
        return ERROR_EQ_LESS_GRADE;
    }
    */

    //判断材料是否满足
    if (m_user.item_mgr.has_items(rp_compose->stuff_1, rp_compose->stuff_1_num) && 
        m_user.item_mgr.has_items(rp_compose->stuff_2, rp_compose->stuff_2_num) &&
        m_user.item_mgr.has_items(rp_compose->stuff_3, rp_compose->stuff_3_num) &&
        m_user.item_mgr.has_items(rp_compose->stuff_4, rp_compose->stuff_4_num))
    {
        //保存装备信息
        db.set_resid(rp_compose->rankup_id);
        save_db();
        
        //记录事件
        statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),db.resid,1,0,-1);
        statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),rp_compose->rankup_id,1,0,1);


        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(rp_compose->stuff_1, rp_compose->stuff_1_num, nt);
            m_user.item_mgr.consume(rp_compose->stuff_2, rp_compose->stuff_2_num, nt);
            m_user.item_mgr.consume(rp_compose->stuff_3, rp_compose->stuff_3_num, nt);
            m_user.item_mgr.consume(rp_compose->stuff_4, rp_compose->stuff_4_num, nt);

            //通知合成后的背包改变
            m_user.item_mgr.on_bag_change(nt);
        }

        //通知合成后的角色属性改变
        m_user.on_pro_changed(db.pid);

        //通知合成后的装备信息
        sc_msg_def::ret_compose_equip_t ret;
        ret.pid = db.pid;
        get_equip_jpk(ret.equip);
        logic.unicast(m_user.db.uid, ret);

        //设置新手引导步骤
        guidence_ins.on_guidence_event(m_user,evt_guidence_uplevel);

        m_user.reward.update_opentask(open_task_equip_advnum);
        return SUCCESS;
    }
    else return ERROR_EQ_LESS_MATERIAL;
}
int32_t sc_equip_t::open_slot(int32_t slotid_)
{
    /*
    repo_def::equip_slot_t* rp_slot = repo_mgr.equip_slot.get(slotid_);
    if (rp_slot == NULL)
    {
        logerror((LOG, "repo no equip_slot:%d", slotid_));
        return ERROR_SC_EXCEPTION;
    } 

    if (!m_user.item_mgr.has_items(rp_slot->stoneid, 1))
    {
        return ERROR_EQ_LESS_SLOTSTONE;
    }

    int32_t* pslot = NULL;
    switch(slotid_)
    {
    case 1:
        pslot = &db.gresid1;
    break;
    case 2:
        pslot = &db.gresid2;
    break;
    case 3:
        pslot = &db.gresid3;
    break;
    case 4:
        pslot = &db.gresid4;
    break;
    case 5:
        pslot = &db.gresid5;
    break;
    }

    if (pslot == NULL)
        return ERROR_EQ_ILLEGLE_GEM_SLOT;

    if (*pslot >= 0)
        return ERROR_EQ_USED_GEM_SLOT;

    int32_t n = random_t::rand_integer(1, 10000);
    if (n <= rp_slot->prob)
        *pslot = 0;
    else return FAILED;

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
        db_.update();
    }, db);

    //消耗开启石
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(rp_slot->stoneid, 1, nt);
    if (!nt.items.empty())
        logic.unicast(m_user.db.uid, nt);
    */

    return SUCCESS;
}

int32_t sc_equip_t::inlay(int32_t resid_, int32_t slotid_)
{
    /*
    repo_def::equip_slot_t* rp_slot = repo_mgr.equip_slot.get(slotid_);
    if (rp_slot == NULL)
    {
        logerror((LOG, "repo no equip_slot:%d", slotid_));
        return ERROR_EQ_ILLEGLE_GEM_SLOT;
    } 
    */
    /*
    if (rp_slot->openlv > db.strenlevel)
    {
        return ERROR_EQ_LOW_LV;
    }
    */
    sp_item_t sp_gem = m_user.item_mgr.get(resid_);
    if (sp_gem == NULL)
    {
        return ERROR_EQ_NO_GEM;
    }

    repo_def::gemstone_t *rp_gem = repo_mgr.gemstone.get(resid_);
    if (rp_gem == NULL)
    {
        logerror((LOG, "repo no gemstone resid:%d", resid_));
        return ERROR_GEM_NO_REPO; 
    }

    //获取装备的部位
    auto it_equip = repo_mgr.equip.find( db.resid );
    if( it_equip == repo_mgr.equip.end() )
    {
        return ERROR_SC_EXCEPTION;
    } 

    /*
    repo_def::gemstone_part_t *rp_gem_part = repo_mgr.gemstone_part.get(it_equip->second.type);
    if (rp_gem_part == NULL)
    {
        logerror((LOG, "repo no gemstone type, type:%d", it_equip->second.type));
        return ERROR_GEM_NO_REPO; 
    }

    auto it = std::find(rp_gem_part->attribute.begin(), rp_gem_part->attribute.end(), rp_gem->attribute);
    if (it == rp_gem_part->attribute.end())
    {
        logerror((LOG, "error_eq_illegle_gem_attr: gem attr:%d, eq type:%d", rp_gem->attribute, it_equip->second.type));
        return ERROR_EQ_ILLEGLE_GEM_ATTR;
    }
    */
    int32_t* pslot = NULL;
    switch(slotid_)
    {
    case 1:
        pslot = &db.gresid1;
    break;
    case 2:
        pslot = &db.gresid2;
    break;
    case 3:
        pslot = &db.gresid3;
    break;
    case 4:
        pslot = &db.gresid4;
    break;
    case 5:
        pslot = &db.gresid5;
    break;
    }

    if (pslot == NULL)
        return ERROR_EQ_ILLEGLE_GEM_SLOT;

    if (*pslot > 0)
    {
        logerror((LOG, "the pslot is %d", *pslot));
        return ERROR_EQ_ILLEGLE_GEM_SLOT;
    }

    repo_def::gemstone_t *rp_inlay = repo_mgr.gemstone.get(*pslot);
    if (*pslot > 0 && rp_inlay == NULL)
    {
        logerror((LOG, "repo no gemstone resid:%d", resid_));
        return ERROR_SC_EXCEPTION; 
    }

    //设置当前槽位置上的宝石
    switch(slotid_)
    {
    case 1:
        db.set_gresid1(resid_);
    break;
    case 2:
        db.set_gresid2(resid_);
    break;
    case 3:
        db.set_gresid3(resid_);
    break;
    case 4:
        db.set_gresid4(resid_);
    break;
    case 5:
        db.set_gresid5(resid_);
    break;
    }

    save_db();

    //通知合成后的角色属性改变
    m_user.on_pro_changed(db.pid);
    //通知背包改变
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(resid_, 1, nt);
    m_user.item_mgr.on_bag_change(nt);
    
    //设置新手引导步骤
    //guidence_ins.on_guidence_event(m_user,evt_guidence_inlay);

    return SUCCESS;
}
//拆下宝石
int32_t sc_equip_t::unlay(int32_t flag_, int32_t slotid_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    int32_t* pslot = NULL;
    switch(slotid_)
    {
    case 1:
        pslot = &db.gresid1;
    break;
    case 2:
        pslot = &db.gresid2;
    break;
    case 3:
        pslot = &db.gresid3;
    break;
    case 4:
        pslot = &db.gresid4;
    break;
    case 5:
        pslot = &db.gresid5;
    break;
    }

    if (pslot == NULL)
        return ERROR_EQ_ILLEGLE_GEM_SLOT;

    //设置当前槽位置上的宝石
    int resid = *pslot;
    if (resid != 0)
        cout <<" resid: " << resid << endl;

    switch(slotid_)
    {
    case 1:
        db.set_gresid1(0);
    break;
    case 2:
        db.set_gresid2(0);
    break;
    case 3:
        db.set_gresid3(0);
    break;
    case 4:
        db.set_gresid4(0);
    break;
    case 5:
        db.set_gresid5(0);
    break;
    }
    save_db();

    sc_msg_def::nt_bag_change_t nt_bag;
    //把宝石放回背包
    m_user.item_mgr.addnew(resid, 1, nt_bag);

    //通知角色属性改变
    m_user.on_pro_changed(db.pid);

    //背包改变
    m_user.item_mgr.on_bag_change(nt_bag);

    return SUCCESS;
}
void sc_equip_t::get_equip_jpk(sc_msg_def::jpk_equip_t& equip_)
{
    sc_msg_def::jpk_equip_t& eqp = equip_;
    eqp.eid = db.eid;
    eqp.resid = db.resid;
    eqp.gresids[0] = (db.gresid1);
    eqp.gresids[1] = (db.gresid2);
    eqp.gresids[2] = (db.gresid3);
    eqp.gresids[3] = (db.gresid4);
    eqp.gresids[4] = (db.gresid5);
    eqp.strenlevel = db.strenlevel;
    eqp.isweared = db.isweared == 1;
}
//======================================================
sc_equip_mgr_t::sc_equip_mgr_t(sc_user_t& user_):
    m_user(user_)
{
}
void sc_equip_mgr_t::init_new_user()
{
    repo_def::role_t* role = repo_mgr.role.get(m_user.db.resid);
    if (role == NULL)
    {
        logerror((LOG, "repo no role id:%d", m_user.db.resid));
        return ; 
    }

    auto  it_equip = repo_mgr.init_equip.find(role->id);
    if (it_equip == repo_mgr.init_equip.end())
    {
        logerror((LOG, "repo init_equip no job:%d", role->id));
        return;
    }

    repo_def::init_equip_t& eq = it_equip->second;
    for (size_t i=1; i<eq.init_equip.size(); i++)
    {
        boost::shared_ptr<sc_equip_t> sp_equip(new sc_equip_t(m_user));

        db_Equip_t& eqdb = sp_equip->db;
        eqdb.eid = m_maxid.newid();
        eqdb.uid = m_user.db.uid;
        eqdb.pid = 0; 
        eqdb.resid = eq.init_equip[i];
        eqdb.gresid1 = 0;
        eqdb.gresid2 = 0;
        eqdb.gresid3 = 0;
        eqdb.gresid4 = 0;
        eqdb.gresid5 = 0;
        eqdb.strenlevel = 0;
        eqdb.isweared = 1;

        m_equip_hm.insert(make_pair(sp_equip->db.eid, sp_equip));
        add_part(sp_equip, int32_t(i));    

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
            db_.insert();
        }, eqdb);
    }

    m_user.partner_mgr.foreach([this](sp_partner_t partner){
        this->init_new_partner(partner->db.pid, partner->db.resid);
    });
}
void sc_equip_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Equip_t::sync_select_equip_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_equip_t> sp_equip(new sc_equip_t(m_user));
            sp_equip->db.init(*res.get_row_at(i));
            m_equip_hm.insert(make_pair(sp_equip->db.eid, sp_equip));
            m_maxid.update(sp_equip->db.eid);
            //logwarn((LOG, "load equip from db, uid:%d, eid:%d, resid:%d, pid:%d", sp_equip->db.uid, sp_equip->db.eid, sp_equip->db.resid, sp_equip->db.pid));
            add_part(sp_equip, int32_t( i % 5 + 1));    
        }
    }
}
void sc_equip_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Equip_t::select_equip_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_equip_t> sp_equip(new sc_equip_t(m_user));
            sp_equip->db.init(*res.get_row_at(i));
            m_equip_hm.insert(make_pair(sp_equip->db.eid, sp_equip));
            m_maxid.update(sp_equip->db.eid);
            add_part(sp_equip, int32_t( i % 5 + 1));
        }
    }
}
sp_equip_t sc_equip_mgr_t::get(int32_t eid_)
{
    auto it = m_equip_hm.find(eid_);
    if (it != m_equip_hm.end())
        return it->second;
    return sp_equip_t();
}

void
sc_equip_mgr_t::unlay_all()
{
    for(auto it=m_equip_hm.begin();it!=m_equip_hm.end();++it)
    {
        for(int32_t i=1;i<=5;++i)
            it->second->unlay(0,i);
    }
}

int sc_equip_mgr_t::get_quality_by_equip(int32_t uid)
{
    db_equip.clear();
    sql_result_t res;
    char buf[4096];
    sprintf(buf, "SELECT `strenlevel` , `pid` , `resid` , `gresid2`, `eid`, `gresid4`, `isweared` , `gresid5` , `gresid3`,`gresid1`,`uid` FROM `Equip` WHERE  `uid` = %d", uid);
    if (0==db_service.sync_select(buf, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db_Equip_t db;
            size_t j = 0;
            sql_result_row_t& row_= *res.get_row_at(i);
            db.strenlevel = (int)std::atoi(row_[j++].c_str());
            db.pid = (int)std::atoi(row_[j++].c_str());
            db.resid = (int)std::atoi(row_[j++].c_str());
            db.gresid2 = (int)std::atoi(row_[j++].c_str());
            db.eid = (int)std::atoi(row_[j++].c_str());
            db.gresid4 = (int)std::atoi(row_[j++].c_str());
            db.isweared = (int)std::atoi(row_[j++].c_str());
            db.gresid5 = (int)std::atoi(row_[j++].c_str());
            db.gresid3 = (int)std::atoi(row_[j++].c_str());
            db.gresid1 = (int)std::atoi(row_[j++].c_str());
            db.uid = (int)std::atoi(row_[j++].c_str());
            db_equip.insert(make_pair(db.eid,db));
        }
        logwarn((LOG, "load friend flower finish"));
    }

    int32_t quality = 14;
    for (auto it = db_equip.begin();it != db_equip.end(); it++)
    {
        if (it->second.pid == 0)
        {
            auto repoInfo = repo_mgr.equip.find(it->second.resid);
            if ( repoInfo != repo_mgr.equip.end())
            {
                if(repoInfo->second.rank < quality)
                    quality = repoInfo->second.rank;
            }
        }
    }
    return quality;
}
int sc_equip_mgr_t::add_part(sp_equip_t equip_, int32_t part)
{
    repo_def::equip_t* reqp = repo_mgr.equip.get(equip_->db.resid);
    if (reqp == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", equip_->db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    if (!equip_->db.isweared)
    {
        //logwarn((LOG, "add_part, equip is unweared:%d", equip_->db.eid));
        return ERROR_SC_ILLEGLE_REQ; 
    }

    if (equip_->db.pid == 0)
    {
        m_user_equip_slot.insert(make_pair(part, equip_));
    }
    else
    {
        auto it = m_partner_equip_slot.find(equip_->db.pid);
        if (it == m_partner_equip_slot.end())
        {
            it = m_partner_equip_slot.insert(make_pair(equip_->db.pid, equip_slot_t())).first;
        }

        it->second.insert(make_pair(part, equip_));
    }
    //logwarn((LOG, "add_part, equip is uid:%d, pid:%d, eid:%d",equip_->db.uid, equip_->db.pid, equip_->db.eid));

    return SUCCESS;
}
int32_t sc_equip_mgr_t::del_part(sp_equip_t equip_)
{
    /*
    repo_def::equip_t* reqp = repo_mgr.equip.get(equip_->db.resid); 
    if (reqp == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", equip_->db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    if (!equip_->db.isweared)
    {
        logerror((LOG, "takeoff_equip, equip is weared:%d", equip_->db.eid));
        return ERROR_SC_ILLEGLE_REQ; 
    }

    if (equip_->db.pid == 0)
    {
        m_user_equip_slot.erase(reqp->part);
    }
    else
    {
        auto it = m_partner_equip_slot.find(equip_->db.pid);
        if (it != m_partner_equip_slot.end())
        {
            it->second.erase(reqp->part);
        }
    }
    */
    return SUCCESS;
}
sp_equip_t sc_equip_mgr_t::get_part(int32_t pid_, int32_t part_)
{
    if (pid_ == 0)
    {
        auto it = m_user_equip_slot.find(part_);
        if (it != m_user_equip_slot.end())
            return it->second;
        return sp_equip_t();
    }
    else
    {
        auto it = m_partner_equip_slot.find(pid_);
        if (it != m_partner_equip_slot.end())
        {
            auto ite = it->second.find(part_);
            if (ite != it->second.end())
                return ite->second;
        }
        return sp_equip_t();
    }
}
int sc_equip_mgr_t::wear_equip(int32_t pid_, int32_t eid_, int slot_pos_)
{
    /*
    logwarn((LOG, "wear_equip, pid:%d, eid:%d, slot_pos_:%d...", pid_, eid_, slot_pos_));

    sp_equip_t sp_equip = get(eid_);
    if (sp_equip == NULL)
    {
        logerror((LOG, "wear_equip, no equip:%d", eid_));
        return ERROR_EQ_NO_EQ;
    }

    if (sp_equip->db.isweared == 1)
    {
        logerror((LOG, "wear_equip, equip:%d has equiped!", eid_));
        return ERROR_EQ_WEAR_EQUIPED;
    }

    repo_def::equip_t* rp_eq = repo_mgr.equip.get(sp_equip->db.resid); 
    if (rp_eq == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", sp_equip->db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    int role_lv = 0;
    int job = 0;
    equip_slot_t* slot = NULL;
    if (pid_ == 0)
    {
        role_lv = m_user.db.grade;
        slot = &m_user_equip_slot;

        auto rp_role = repo_mgr.role.get(m_user.db.resid);
        if (rp_role == NULL)
        {
            logerror((LOG, "repo no role info, uid:%d, pid:%d", m_user.db.uid, pid_));
            return ERROR_SC_EXCEPTION;
        }

        job = rp_role->job;
    }
    else
    {
        sp_partner_t sp_partner = m_user.partner_mgr.get(pid_);
        if (sp_partner == NULL)
        {
            logerror((LOG, "user no partner, uid:%d, pid:%d", m_user.db.uid, pid_));
            return ERROR_SC_NO_PARTNER;
        }

        role_lv = sp_partner->db.grade;

        auto it = m_partner_equip_slot.find(pid_);
        if (it == m_partner_equip_slot.end())
        {
            it = m_partner_equip_slot.insert(make_pair(pid_, equip_slot_t())).first;
        }
        slot = &it->second;

        auto rp_role = repo_mgr.role.get(sp_partner->db.resid);
        if (rp_role == NULL)
        {
            logerror((LOG, "repo no role info, uid:%d, pid:%d", m_user.db.uid, pid_));
            return ERROR_SC_EXCEPTION;
        }

        job = rp_role->job;
    }

//      if (role_lv < sp_equip->db.strenlevel || role_lv < rp_eq->level)
    if ( role_lv < rp_eq->level)
    {
        return ERROR_EQ_LOW_LV;
    }

    if (slot_pos_ != rp_eq->part)
    {
        return ERROR_EQ_ILLEGLE_PART;
    }

    if (std::find(rp_eq->jobsort.begin(), rp_eq->jobsort.end(), job) == rp_eq->jobsort.end())
    {
        logerror((LOG, "error equip job, uid:%d, pid:%d, job:%d", m_user.db.uid, pid_, job));
        return ERROR_EQ_ILLEGLE_JOB;
    }

    sp_equip_t weared_equip;
    auto it_eq =(*slot).find(rp_eq->part);
    if (it_eq != (*slot).end())
    {
        weared_equip = it_eq->second;
    }
    (*slot)[rp_eq->part] = sp_equip;

    sp_equip->db.set_isweared(1);
    sp_equip->db.set_pid(pid_);
    sp_equip->save_db();

    if (weared_equip != NULL)
    {
        weared_equip->db.set_pid(0);
        weared_equip->db.set_isweared(0);
        weared_equip->save_db();
    }

    //通知角色属性改变
    m_user.on_pro_changed(pid_);

    sc_msg_def::nt_bag_change_t bagchange;
    sc_msg_def::jpk_equip_t jpk;
    sp_equip->get_equip_jpk(jpk);
    bagchange.del_equips.push_back(std::move(jpk));

    if (weared_equip != NULL)
    {
        weared_equip->get_equip_jpk(jpk);
        bagchange.add_equips.push_back(std::move(jpk));
    }

    logic.unicast(m_user.db.uid, bagchange);

    logwarn((LOG, "wear_equip, pid:%d, eid:%d, slot_pos_:%d...ok", pid_, eid_, slot_pos_));
*/
    return SUCCESS;
}
int sc_equip_mgr_t::takeoff_equip(int32_t pid_, int32_t eid_, int slot_pos_)
{
    logwarn((LOG, "takeoff_equip, pid:%d, eid:%d, slot_pos_:%d...", pid_, eid_, slot_pos_));
/*
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    sp_equip_t sp_equip = get(eid_);
    if (sp_equip == NULL)
    {
        logerror((LOG, "wear_equip, no equip:%d", eid_));
        return ERROR_EQ_NO_EQ;
    }

    repo_def::equip_t* reqp = repo_mgr.equip.get(sp_equip->db.resid); 
    if (reqp == NULL)
    {
        logerror((LOG, "repo no equip resid:%d", sp_equip->db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    equip_slot_t* slot;
    if (pid_ == 0)
    {
        slot = &m_user_equip_slot;
    }
    else
    {
        auto it = m_partner_equip_slot.find(pid_);
        if (it == m_partner_equip_slot.end())
        {
            it = m_partner_equip_slot.insert(make_pair(pid_, equip_slot_t())).first;
        }
        slot = &it->second;
    }

    auto it_eq =(*slot).find(reqp->part);
    if (it_eq == (*slot).end())
    {
        logerror((LOG, "takeoff unweared equip! eid:%d, resid:%d, part:%d", 
            sp_equip->db.eid, sp_equip->db.resid, reqp->part));
        return ERROR_EQ_TAKEOFF_UNWEARED;
    }

    (*slot).erase(it_eq);

    sp_equip->db.set_pid(0);
    sp_equip->db.set_isweared(0);
    sp_equip->save_db();

    m_user.on_pro_changed(pid_);

    sc_msg_def::nt_bag_change_t bagchange;
    sc_msg_def::jpk_equip_t jpk;
    sp_equip->get_equip_jpk(jpk);
    bagchange.add_equips.push_back(std::move(jpk));
    logic.unicast(m_user.db.uid, bagchange);

    logwarn((LOG, "takeoff_equip, pid:%d, eid:%d, slot_pos_:%d...ok", pid_, eid_, slot_pos_));
*/
    return SUCCESS;
}

bool sc_equip_mgr_t::is_white_equip(sp_equip_t equip_)
{
    if( equip_->db.resid / 10 != 1601 )
        return false;
    if( equip_->db.strenlevel != 0 )
        return false;
    return true;
}

void sc_equip_mgr_t::fire_all_equip(int32_t pid_, sc_msg_def::nt_bag_change_t& ret_)
{
    if (pid_ > 0)
    {
        for(auto it=m_equip_hm.begin(); it!=m_equip_hm.end(); )
        {
            if (it->second->db.pid == pid_)
            {
                if( is_white_equip(it->second) )
                {
                    //白装，直接删除
                    db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
                        db_.remove();
                    }, it->second->db.data());

                    it = m_equip_hm.erase(it);
                }
                else
                {
                    //脱装备
                    it->second->db.set_isweared(0);
                    it->second->save_db();

                    sc_msg_def::jpk_equip_t jpk;
                    it->second->get_equip_jpk(jpk);
                    ret_.add_equips.push_back(std::move(jpk));

                    it++;
                }
            }
            else
                it++;

        }
    }
}

void sc_equip_mgr_t::takeoff_all_equip(int32_t pid_, sc_msg_def::nt_bag_change_t& ret_)
{
    if (pid_ > 0)
    {
        for(auto it=m_equip_hm.begin(); it!=m_equip_hm.end(); it++)
        {
            if (it->second->db.pid == pid_)
            {
                //脱装备
                it->second->db.set_isweared(0);
                it->second->save_db();

                sc_msg_def::jpk_equip_t jpk;
                it->second->get_equip_jpk(jpk);
                ret_.add_equips.push_back(std::move(jpk));
            }
        }
    }
}
void sc_equip_mgr_t::init_new_partner(int32_t pid_, int32_t resid_)
{
    repo_def::role_t* role = repo_mgr.role.get(resid_);
    if (role == NULL)
    {
        logerror((LOG, "repo no role id:%d", resid_));
        return ; 
    }

    auto it_equip = repo_mgr.init_equip.find(role->id);
    if (it_equip == repo_mgr.init_equip.end())
    {
        logerror((LOG, "repo init_equip no job:%d", role->id));
        return;
    }
    repo_def::init_equip_t& eq = it_equip->second;
    for(size_t i=1; i<eq.init_equip.size(); i++)
    {
        boost::shared_ptr<sc_equip_t> sp_equip(new sc_equip_t(m_user));

        db_Equip_t& eqdb = sp_equip->db;
        eqdb.eid = m_maxid.newid(); 
        eqdb.uid = m_user.db.uid;
        eqdb.pid = pid_; 
        eqdb.resid = eq.init_equip[i];
        eqdb.gresid1 = 0;
        eqdb.gresid2 = 0;
        eqdb.gresid3 = 0;
        eqdb.gresid4 = 0;
        eqdb.gresid5 = 0;
        eqdb.strenlevel = 0;
        eqdb.isweared = 1;

        m_equip_hm.insert(make_pair(sp_equip->db.eid, sp_equip));
        add_part(sp_equip, int32_t(i));    

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
            db_.insert();
        }, eqdb);
    }
}
//从商城买装备
void sc_equip_mgr_t::addnew(int32_t resid_,int32_t num_,sc_msg_def::nt_bag_change_t& change_)
{
    for ( int i =0;i<num_;++i)
    {
        boost::shared_ptr<sc_equip_t> sp_equip(new sc_equip_t(m_user));

        sc_msg_def::jpk_equip_t jpk;
        db_Equip_t& eqdb = sp_equip->db;
        jpk.eid = eqdb.eid = m_maxid.newid(); 
        eqdb.uid = m_user.db.uid;
        eqdb.pid = 0;
        jpk.resid = eqdb.resid = resid_;
        jpk.gresids[0] = eqdb.gresid1 = 0;
        jpk.gresids[1] = eqdb.gresid2 = 0;
        jpk.gresids[2] = eqdb.gresid3 = 0;
        jpk.gresids[3] = eqdb.gresid4 = 0;
        jpk.gresids[4] = eqdb.gresid5 = 0;
        jpk.strenlevel = eqdb.strenlevel = 0;
        eqdb.isweared = 0;
        jpk.isweared = (eqdb.isweared != 0);

        m_equip_hm.insert(make_pair(sp_equip->db.eid, sp_equip));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
                db_.insert();
                }, eqdb);

        change_.add_equips.push_back(std::move(jpk));
    }
}

int32_t sc_equip_mgr_t::bag_size()
{
    int n=0;
    for(auto it=m_equip_hm.begin(); it!=m_equip_hm.end(); it++)
    {
        if (it->second->db.isweared == 0)
            n++;
    }
    return n;
}
void sc_equip_mgr_t::sell_equip(int32_t eid_)
{
    sp_equip_t sp_eq = get(eid_);
    if (sp_eq == NULL)
        return;

    sc_msg_def::nt_bag_change_t nt;
    nt.del_equips.resize(1);
    nt.del_equips[0].eid = sp_eq->db.eid;
    logic.unicast(m_user.db.uid, nt);

    m_equip_hm.erase(eid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Equip_t& db_){
        db_.remove();
    }, sp_eq->db.data());
}
