#include "sc_love_task.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "log.h"
#include "repo_def.h"
#include "code_def.h"
#include <map>

#define LOG "SC_LOVE_TASK"
//sc_user_t.cpp 也有
#define MAX_LOVE_LEVEL 4

//-
sc_love_task_mgr_t::sc_love_task_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_love_task_mgr_t::load_db()
{
    sql_result_t res;
    map<uint32_t, bool> has_task;
    if (0 == db_LoveTask_t::sync_select_love_task_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            sp_love_task_t sp_love_task(new love_task_t);
            sp_love_task->init(*res.get_row_at(i));
            //logwarn((LOG, "load love task, uid:%d, resid:%d, state:%d", m_user.db.uid, sp_love_task->resid, sp_love_task->state));
            if (sp_love_task->state == 0)
                add_love_task(sp_love_task);
            else if (sp_love_task->state == 1){
                auto it = m_pid_ltid.find(sp_love_task->pid);
                if (it == m_pid_ltid.end())
                    m_pid_ltid.insert(make_pair(sp_love_task->pid, sp_love_task->resid));
                else {
                    m_pid_ltid.erase(it);
                    m_pid_ltid.insert(make_pair(sp_love_task->pid, sp_love_task->resid));
                }
            }
            if (has_task.find(sp_love_task->pid) == has_task.end()){
                has_task.insert(make_pair(sp_love_task->pid, true));
            }
        }
    }
    if (has_task.find(0) == has_task.end()) { // 0 ==> self
        //role_id + love_level
        add_love_task(m_user.db.resid * 100 + 1, 0); // pid == 0 self
    } else {
        has_task.erase(m_user.db.resid);
    }
    m_user.partner_mgr.foreach([&](sp_partner_t partner) {
        if (has_task.find(partner->db.pid) == has_task.end()) {
            //role_id + love_level
            if( partner->db.pid == 1)
                add_love_task(partner->db.resid * 100 + 3, partner->db.pid);
            else
                add_love_task(partner->db.resid * 100 + 1, partner->db.pid);
        } else {
            has_task.erase(partner->db.pid);
        }
    });
}

void sc_love_task_mgr_t::async_load_db()
{
    sql_result_t res;
    map<uint32_t, bool> has_task;
    if (0 == db_LoveTask_t::select_love_task_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            sp_love_task_t sp_love_task(new love_task_t);
            sp_love_task->init(*res.get_row_at(i));
            if (sp_love_task->state == 0)
                add_love_task(sp_love_task);
            else if (sp_love_task->state == 1){
                auto it = m_pid_ltid.find(sp_love_task->pid);
                if (it == m_pid_ltid.end())
                    m_pid_ltid.insert(make_pair(sp_love_task->pid, sp_love_task->resid));
                else {
                    m_pid_ltid.erase(it);
                    m_pid_ltid.insert(make_pair(sp_love_task->pid, sp_love_task->resid));
                }
            }
            if (has_task.find(sp_love_task->pid) == has_task.end())
                has_task.insert(make_pair(sp_love_task->pid, true));
        }
    }
    if (has_task.find(0) == has_task.end()) { // 0 ==> self
        //role_id + love_level
        add_love_task(m_user.db.resid * 100 + 1, 0); // pid == 0 self
    } else {
        has_task.erase(m_user.db.resid);
    }
    m_user.partner_mgr.foreach([&](sp_partner_t partner) {
        if (has_task.find(partner->db.pid) == has_task.end()) {
            if( partner->db.pid == 1)
                add_love_task(partner->db.resid * 100 + 4, partner->db.pid);
            else
                add_love_task(partner->db.resid * 100 + 1, partner->db.pid);
        } else {
            has_task.erase(partner->db.pid);
        }
    });
}

void sc_love_task_mgr_t::init_new_user()
{
    add_love_task(m_user.db.resid * 100 + 1, 0);
}

void sc_love_task_mgr_t::save_db(sp_love_task_t& sp_love_task_)
{
    string sql = sp_love_task_->get_up_sql();
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}

//-
int sc_love_task_mgr_t::unicast_love_task_list()
{
    sc_love_task_mgr_t::load_db();
    sc_msg_def::ret_love_task_list_t ret;

    for(auto it = m_love_tasks.begin(); it != m_love_tasks.end(); ++it)
    {
        logwarn((LOG, "pid = %d", it->second->pid));
        sc_msg_def::jpk_love_task_t love_task;
        love_task.pid = it->second->pid;
        love_task.ltid = it->second->resid;
        love_task.step = it->second->step;
        love_task.state = it->second->state;
        ret.love_task.push_back(std::move(love_task));
    }
    logic.unicast(m_user.db.uid, ret);
    return 0;
}

int sc_love_task_mgr_t::request(int resid_)
{
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(resid_);
    if (rp_love_task == NULL)
        return ERROR_SC_EXCEPTION;

    auto it = m_love_tasks.find(resid_);
    if (it != m_love_tasks.end())
        return ERROR_TASK_HAS_EXISTED;

    add_love_task(resid_, resid_/100);
    return SUCCESS;
}

int sc_love_task_mgr_t::commit(int resid_, sc_msg_def::ret_commit_love_task_t& ret)
{
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(resid_);
    if (rp_love_task == NULL)
        return ERROR_SC_EXCEPTION;

    sp_love_task_t sp_love_task;
    if (false == get_love_task(resid_, sp_love_task))
        return ERROR_TASK_NOT_EXISTED;

    bool finished = true; 
    auto f = [&](int type_, int info_, int count_)
    {
        switch(type_)
        {
            case -1:
                break;
            case 3:
                if (!m_user.item_mgr.has_items(info_, count_))
                {
                    finished = false;
                    logerror((LOG, "uid = %d, love type = 3 and info = %d, count = %d",m_user.db.uid, info_, count_));
                }
                break;
            case 4:
                if (sp_love_task->pid == 0)
                {    
                    if (m_user.db.lovevalue < rp_love_task->love_max)
                    {
                        //finished = true;
                        logerror((LOG, "uid = %d, love type = 4 and lovevalue = %d, lovemax = %d",m_user.db.uid, m_user.db.lovevalue, rp_love_task->love_max));
                    }
                }
                else 
                {    
                    if ( m_user.partner_mgr.get( sp_love_task->pid )->db.lovevalue < rp_love_task->love_max)
                    {
                        //finished = true;
                        logerror((LOG, "uid = %d, love type = 4 and lovevalue = %d, lovemax = %d",m_user.db.uid,m_user.partner_mgr.get( sp_love_task->pid )->db.lovevalue, rp_love_task->love_max));
                    }
                }
                break;
            case 5:
                if (sp_love_task->pid == 0)
                {
                    if (m_user.db.naviClickNum1 < count_)
                    {
                        logerror((LOG, "uid = %d, love type = 5 and neednum = %d, havenum = %d",m_user.db.uid,m_user.db.naviClickNum1,count_));
                        finished = false;
                    }
                }
                else
                {    
                    if ( m_user.partner_mgr.get( sp_love_task->pid )->db.naviClickNum1 < count_)
                    {
                        finished = false;
                        logerror((LOG, "uid = %d, love type = 5 and neednum = %d, havenum = %d",m_user.partner_mgr.get( sp_love_task->pid )->db.naviClickNum1,count_));
                    }
                }
                break;
            default:
                break;
        }
    };
    f(rp_love_task->love_type3, rp_love_task->value3[1], rp_love_task->value3[2]);
    f(rp_love_task->love_type1, rp_love_task->value1[1], rp_love_task->value1[2]);
    f(rp_love_task->love_type2, rp_love_task->value2[1], rp_love_task->value2[2]);
    if (!finished)
        return ERROR_TASK_NOT_FINISHED;

    m_love_tasks.erase(resid_);

    sp_love_task->set_state(1);
    if ( sp_love_task->pid == 0)
    {
        m_user.db.set_lovevalue(0);
    }
    else
    {
        m_user.partner_mgr.get( sp_love_task->pid )->db.lovevalue = 0;
        m_user.partner_mgr.get( sp_love_task->pid )->save_db();
    }
    save_db(sp_love_task);
    //加入已完成映射中
    auto it = m_pid_ltid.find(sp_love_task->pid);
    if (it != m_pid_ltid.end())
        m_pid_ltid.erase(it);
    m_pid_ltid.insert(make_pair(sp_love_task->pid, sp_love_task->resid));
    //通知心级发生变化
    m_user.on_lovelevel_change(sp_love_task->pid);
    //通知属性发生变化
    m_user.on_pro_changed(sp_love_task->pid);
    m_user.save_db();
    //强化消费减少。。。
    
    
    //消耗所需物品
    auto useitem = [&](int type_, int info_, int count_)
    {
        if(type_ == 3)
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(info_, count_, nt);
            m_user.item_mgr.on_bag_change(nt);
        }
    };
    useitem(rp_love_task->love_type3, rp_love_task->value3[1], rp_love_task->value3[2]);
    useitem(rp_love_task->love_type1, rp_love_task->value1[1], rp_love_task->value1[2]);
    useitem(rp_love_task->love_type2, rp_love_task->value2[1], rp_love_task->value2[2]);

    //自动激活下一个任务
    if (resid_ % 100 != MAX_LOVE_LEVEL) {
        add_love_task(sp_love_task->resid + 1, sp_love_task->pid);
        ret.love_task.pid = sp_love_task->pid;
        ret.love_task.ltid = sp_love_task->resid + 1;
        ret.love_task.step = 0;
    }
    else
    {
        m_user.achievement.on_event(evt_love_marriged, 1);
    }
    m_user.achievement.on_event(evt_love_lv, 1);
    return SUCCESS;
}

void sc_love_task_mgr_t::refresh_coll_items_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_)
{
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(love_task_->value1[1], love_task_->value1[2],  nt);
    m_user.item_mgr.on_bag_change(nt);

    int32_t count = m_user.item_mgr.get_items_count(love_task_->value1[1]);
    auto iterator = wlt_.find(love_task_->value1[1]);
    if (iterator != wlt_.end())
    {
        for (auto it = iterator->second.begin(); it != iterator->second.end(); ++it)
        {
            if ((*it)->step > count)
            {
                (*it)->set_step(count);
                sc_msg_def::nt_love_task_change_t nt_change;
                nt_change.love_task.pid = (*it)->pid;
                nt_change.love_task.ltid = (*it)->resid;
                nt_change.love_task.step = (*it)->step;
                logic.unicast(m_user.db.uid, nt_change);

                string sql = (*it)->get_up_sql();
                db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_) {
                    db_service.async_execute(sql_);
                }, sql);
            }
        }
    }
}
bool sc_love_task_mgr_t::get_love_task(int resid_, sp_love_task_t& sp_love_task_)
{
    auto it = m_love_tasks.find(resid_);
    if (it != m_love_tasks.end())
    {
        sp_love_task_ = it->second;
        return true;
    }
    return false;
}

//-
void sc_love_task_mgr_t::on_round_pass(int resid_)
{
    watch_love_task_step(m_pass_rounds, resid_, 1);
}

void sc_love_task_mgr_t::on_got_items(int resid_, int num_)
{
    watch_love_task_step(m_coll_items, resid_, num_);
}

void sc_love_task_mgr_t::on_monster_killed(int resid_, int num_)
{
    watch_love_task_step(m_kill_monsters, resid_, num_);
}

//-
sc_love_task_mgr_t::sp_love_task_t sc_love_task_mgr_t::add_love_task(int resid_, int32_t pid_)
{
    sp_love_task_t sp_love_task(new love_task_t);
    sp_love_task->uid = m_user.db.uid;
    sp_love_task->pid = pid_;
    sp_love_task->resid = resid_;
    sp_love_task->step = 0;
    sp_love_task->state = 0;
    if (add_love_task(sp_love_task))
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](db_LoveTask_t& db_) {
            db_.insert();
        }, sp_love_task->data());
        return sp_love_task;
    } else return sp_love_task_t();
}

//-
bool sc_love_task_mgr_t::add_love_task(sp_love_task_t sp_love_task_)
{
    m_love_tasks.insert(make_pair(sp_love_task_->resid, sp_love_task_));
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(sp_love_task_->resid);
    if (rp_love_task == NULL)
    {
        logerror((LOG, "repo no love task resid:%d", sp_love_task_->resid));
        return false;
    }
    switch(rp_love_task->love_type1)
    {
    //通关N次
    case 1:
        watch_love_task(m_pass_rounds, rp_love_task, sp_love_task_);
        break;
    //杀怪N次
    case 2:
        watch_love_task(m_kill_monsters, rp_love_task, sp_love_task_);
        break;
    //获得物品N个
    case 3:
        watch_love_task(m_coll_items, rp_love_task, sp_love_task_);
        break;
    }
    return true;
}

void sc_love_task_mgr_t::watch_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_, sp_love_task_t sp_love_task_)
{
    if (love_task_->value1.size() < 3)
    {
        logerror((LOG, "repo love_task resid:%d has error value1 size<3", sp_love_task_->resid));
        return;
    }
    int resid = love_task_->value1[1];

    auto it = wlt_.find(resid);
    if (it == wlt_.end())
    {
        it = wlt_.insert(make_pair(resid, love_task_set_t())).first;
    }
    it->second.insert(sp_love_task_);
}

bool sc_love_task_mgr_t::del_watch_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_, sp_love_task_t sp_love_task_, bool finished_)
{
    if (love_task_->value1.size() < 3)
    {
        logerror((LOG, "repo love task resid:%d has error value1 size<3", sp_love_task_->resid));
        return false;
    }
    int resid = love_task_->value1[1];
    int num = love_task_->value1[2];
    if (finished_ && num > sp_love_task_->step)
        return false;

    auto it = wlt_.find(resid);
    it->second.erase(sp_love_task_);
    return true;
}

void sc_love_task_mgr_t::watch_love_task_step(watch_love_task_t& wlt_, int resid_, int n_)
{
    auto it = wlt_.find(resid_);
    if (it != wlt_.end())
    {
        for (auto itt = it->second.begin(); itt != it->second.end(); ++itt)
        {
            (*itt)->set_step((*itt)->step + n_);

            repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get((*itt)->resid);
            if (rp_love_task == NULL)
                continue;

        //    if ((*itt)->step < rp_love_task->value1[2] || ((*itt)->step - n_) < rp_love_task->value1[2])
        //    {
                sc_msg_def::nt_love_task_change_t nt;
                nt.love_task.pid = (*itt)->pid;
                nt.love_task.ltid = (*itt)->resid;
                nt.love_task.step = (*itt)->step;
                logic.unicast(m_user.db.uid, nt);

                string sql = (*itt)->get_up_sql();
                db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_) {
                    db_service.async_execute(sql_);
                }, sql);
         //   }
        }
    }
}

int32_t sc_love_task_mgr_t::cal_love_reward_pro(int32_t pid_, float* m_base_pro_)
{
    auto it = m_pid_ltid.find(pid_);
    if (it == m_pid_ltid.end())
        return 1;
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(it->second);
    if (rp_love_task == NULL)
        return -1;
    repo_def::love_reward_t* rp_love_reward = repo_mgr.love_reward.get(rp_love_task->love_reward_id);
    if (rp_love_reward == NULL)
        return -1;
    m_base_pro_[0] *= (1 + rp_love_reward->atk);
    m_base_pro_[1] *= (1 + rp_love_reward->mgc);
    m_base_pro_[2] *= (1 + rp_love_reward->def);
    m_base_pro_[3] *= (1 + rp_love_reward->res);
    m_base_pro_[4] *= (1 + rp_love_reward->hp);
    return 0;
}

int32_t
sc_love_task_mgr_t::get_love_coefficient(int32_t pid_, double& atk_, double& mgc_, double& def_, double& res_, double& hp_)
{
    auto it = m_pid_ltid.find(pid_);
    if (it == m_pid_ltid.end())
        return 1;
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(it->second);
    if (rp_love_task == NULL)
        return -1;
    repo_def::love_reward_t* rp_love_reward = repo_mgr.love_reward.get(rp_love_task->love_reward_id);
    if (rp_love_reward == NULL)
        return -1;

    atk_ = 1 + rp_love_reward->atk;
    mgc_ = 1 + rp_love_reward->mgc;
    def_ = 1 + rp_love_reward->def;
    res_ = 1 + rp_love_reward->res;
    hp_ = 1 + rp_love_reward->hp;
    return 0;
}

float sc_love_task_mgr_t::get_gold_discount(int32_t pid_)
{
    auto it = m_pid_ltid.find(pid_);
    if (it == m_pid_ltid.end())
        return 1.0f;
    repo_def::love_task_t* rp_love_task = repo_mgr.love_task.get(it->second);
    if (rp_love_task == NULL)
        return 1.0f;
    repo_def::love_reward_t* rp_love_reward = repo_mgr.love_reward.get(rp_love_task->love_reward_id);
    if (rp_love_reward == NULL)
        return 1.0f;
    return rp_love_reward->gold_cost_decreased;
}
