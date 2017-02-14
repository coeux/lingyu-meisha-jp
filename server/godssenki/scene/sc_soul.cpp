#include "sc_soul.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_SOUL"

sc_soul_t::sc_soul_t(sc_user_t& user_)
:m_user(user_)
{
}

    void
sc_soul_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

    void
sc_soul_t::load_db()
{
    sql_result_t res;
    if (0 == db_Soul_t::sync_select_uid(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        init_new_user();
    }
}

    void
sc_soul_t::init_new_user()
{
    db.uid = m_user.db.uid;
    db.soul_id = 0;
    db.level = 0;
    db.rare = 0;
    db.state = 0;
    db.gem_need = 0;
    db.time = 0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Soul_t& db_) {
        db_.insert();
    }, db.data());
}

/*
 * 晶魂状态 
 * state
 * 0 未熔炼
 * 1 成功
 * 2 失败
 * 3 最高
 */
    int32_t
sc_soul_t::get_info(sc_msg_def::ret_get_soul_info_t& ret_)
{
    ret_.soul_id = db.soul_id;
    ret_.level = db.level;
    ret_.rare = db.rare;
    ret_.state = db.state;
    ret_.gem_need = db.gem_need;
    ret_.time  = db.time;
    return SUCCESS;
}

    int32_t
sc_soul_t::hunt(sc_msg_def::ret_hunt_soul_t &ret_)
{
    if (m_user.item_mgr.get_items_count(16004) < 1)
        return ERROR_NO_16004;
    
    if (db.soul_id != 0)
        return ERROR_HAVE_HAD_SOUL;

    unordered_map<int, int> weight_list;
    int32_t total=0;
    for(auto rp=repo_mgr.soul.begin(); rp!=repo_mgr.soul.end(); ++rp)
    {
        if (1 == rp->second.level)
        {
            total+=rp->second.suc_rara;
            weight_list.insert(make_pair(rp->second.id, rp->second.suc_rara));
        }
    }
    if (total < 1)
        return ERROR_SOUL_REPO_NULL;
    int32_t r = random_t::rand_integer(1,total);
    int32_t aim_id;
    for(auto it=weight_list.begin(); it!=weight_list.end(); ++it)
    {
        if (r <= it->second)
        {
            aim_id = it->first;
            break;
        }
        r -= it->second;
    }
    if (m_user.consume_gold(30000) == -1)
        return ERROR_NOT_ENOUGH_MONEY;

    auto rp_soul=repo_mgr.soul.get(aim_id);
    db.soul_id = aim_id;
    db.level = rp_soul->level;
    db.rare = rp_soul->rare;
    db.state = 1;
    db.gem_need = 30;
    db.time = 0;

    db.set_soul_id(aim_id);
    db.set_level(rp_soul->level);
    db.set_rare(rp_soul->rare);
    db.set_state(1);
    db.set_gem_need(30);
    db.set_time(0);
    save_db();

    ret_.soul_id = aim_id;
    ret_.level = db.level;
    ret_.rare = db.rare;
    ret_.state = db.state;
    ret_.gem_need = db.gem_need;
    ret_.time = db.time;

    sc_msg_def::nt_bag_change_t nt_;
    m_user.item_mgr.consume(16004,1,nt_);
    m_user.item_mgr.on_bag_change(nt_);
    
    m_user.reward.update_melting_activity(1);
    m_user.reward.daily_melting_num(1);
    m_user.reward.update_opentask(open_task_soul_num);

    return SUCCESS;
}

bool sc_soul_t::get_cost_item_count(int32_t soullv_)
{
    switch(soullv_)
    {
        case 1: return m_user.item_mgr.has_items(16014, 1); break;
        case 2: return m_user.item_mgr.has_items(16015, 1); break;
        case 3: return m_user.item_mgr.has_items(16016, 1); break;
        case 4: return m_user.item_mgr.has_items(16017, 1); break;
    } 
    return false;
}
int32_t sc_soul_t::use_soul_item(int32_t soullv_)
{
    int32_t is_suc = FAILED;
    switch(soullv_)
    {
        case 1: 
        {       
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(16014, 1, nt);
            m_user.item_mgr.on_bag_change(nt);
            is_suc = SUCCESS; break;
        }
        case 2: 
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(16015, 1, nt);
            m_user.item_mgr.on_bag_change(nt);
            is_suc = SUCCESS; break;
        }
        case 3: 
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(16016, 1, nt);
            m_user.item_mgr.on_bag_change(nt);
            is_suc = SUCCESS; break;
        }
        case 4: 
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(16017, 1, nt);
            m_user.item_mgr.on_bag_change(nt);
            is_suc = SUCCESS; break;
        }
    }
    return is_suc;
}
    int32_t
sc_soul_t::rankup(sc_msg_def::ret_rankup_soul_t &ret_)
{
    if (0 == db.soul_id)
        return ERROR_HAVE_NO_SOUL;
    auto rp=repo_mgr.soul.get(db.soul_id);
    if (rp == NULL)
    {
        logwarn((LOG, "no such soul: %d", db.soul_id));
        return ERROR_SOUL_REPO_NULL;
    }

    if (!get_cost_item_count(rp->level) &&(m_user.rmb() < db.gem_need))
         return ERROR_NOT_ENOUGH_RMB;

    int32_t r=random_t::rand_integer(1,100);
    bool is_suc = false;
    int gem_ori = db.gem_need;
    if (r <= 100*rp->fail_rara)
    {
        ret_.state = 2;
        db.set_state(2);
        db.state = 2;

        ret_.gem_need = 0;
        db.gem_need = 0;
        db.set_gem_need(0);
        db.time = 0;
        db.set_time(0);
    }
    else
    {
        ret_.state = 1;
        r -= 100*rp->fail_rara;
        if (r > 100*rp->invalid_rara)
            is_suc = true;

        db.gem_need = db.gem_need*2;
        db.time = db.time + 1;
        if (db.gem_need > 600)
            db.gem_need = 600;
        db.set_gem_need(db.gem_need);
        db.set_time(db.time);
        ret_.gem_need = db.gem_need;
    }

    int32_t aim_id = db.soul_id;
    if (is_suc)
    {
        unordered_map<int, int> weight_list;
        int32_t total=0;
        for(auto rp=repo_mgr.soul.begin(); rp!=repo_mgr.soul.end(); ++rp)
        {
            if ((rp->second.level == db.level+1) && (rp->second.rare >= db.rare))
            {
                total+=rp->second.suc_rara;
                weight_list.insert(make_pair(rp->second.id, rp->second.suc_rara));
            }
        }
        if (total < 1)
            return ERROR_SOUL_REPO_NULL;
        int32_t r = random_t::rand_integer(1,total);
        for(auto it=weight_list.begin(); it!=weight_list.end(); ++it)
        {
            if (r <= it->second)
            {
                aim_id = it->first;
                break;
            }
            r -= it->second;
        }

    }

    auto rp_soul=repo_mgr.soul.get(aim_id);
    db.soul_id = aim_id;
    db.level = rp_soul->level;
    db.rare = rp_soul->rare;

    db.set_soul_id(aim_id);
    db.set_level(rp_soul->level);
    db.set_rare(rp_soul->rare);
    save_db();

    ret_.soul_id = aim_id;
    ret_.level = db.level;
    ret_.rare = db.rare;
    ret_.state = db.state;
    ret_.time = db.time;
    
    if(get_cost_item_count(rp->level))
        use_soul_item(rp->level);
    else
        m_user.consume_yb(gem_ori);

    m_user.reward.update_melting_activity(1);
    m_user.reward.daily_melting_num(1);
    m_user.reward.update_opentask(open_task_soul_num);

    return SUCCESS;
}

    int32_t
sc_soul_t::get_reward(sc_msg_def::ret_get_soul_reward_t& ret_ , bool isDouble)
{
    sc_msg_def::nt_bag_change_t nt;
    auto rp=repo_mgr.soul.get(db.soul_id);
    if (rp == NULL)
        return ERROR_SOUL_REPO_NULL;
    int first,second;
    if (1 == db.state)
    {
        first = rp->suc_reward[1];
        second = rp->suc_reward[2];
    }
    else if (2 == db.state)
    {
        first = rp->fail_reward[1];
        second = rp->fail_reward[2];
    }

    if(isDouble){
        m_user.item_mgr.addnew(15001,(int32_t)second*1.5,nt);
        m_user.item_mgr.addnew(16003,(int32_t)first*1.5,nt);
        m_user.item_mgr.on_bag_change(nt);
    }else{
        m_user.item_mgr.addnew(15001,second,nt);
        m_user.item_mgr.addnew(16003,first,nt);
        m_user.item_mgr.on_bag_change(nt);
    }
    ret_.soul_id = 0;
    ret_.level = 0;
    ret_.rare = 0;
    ret_.state = 0;
    ret_.gem_need = 0;
    ret_.time = 0;

    db.soul_id = 0;
    db.level = 0;
    db.rare = 0;
    db.state = 0;
    db.gem_need = 0;
    db.time = 0;

    db.set_soul_id(0);
    db.set_level(0);
    db.set_rare(0);
    db.set_state(0);
    db.set_gem_need(0);
    db.set_time(0);
    save_db();

    return SUCCESS;
}

    void
sc_soul_t::clear_scroll()
{
    char buf[4096];
    sprintf(buf, "UPDATE `Item` SET `count` = 0 WHERE  `resid` = 16004");
    db_service.sync_execute(buf);
}
