#include "sc_task.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "log.h"
#include "repo_def.h"
#include "code_def.h"

#define LOG "SC_TASK"

#define MAX_TASK 30

sc_task_mgr_t::sc_task_mgr_t(sc_user_t& user_):m_user(user_)
{
}
void sc_task_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Task_t::sync_select_task(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_task_t sp_task(new task_t);
            sp_task->init(*res.get_row_at(i));
            //logwarn((LOG, "load task, uid:%d, resid:%d, state:%d", m_user.db.uid, sp_task->resid, sp_task->state));
            if (sp_task->state == 0)
                add_task(sp_task);
            else m_finished_bline.insert(sp_task->resid);
        }
    }
}
void sc_task_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Task_t::select_task(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_task_t sp_task(new task_t);
            sp_task->init(*res.get_row_at(i));
            //logwarn((LOG, "load task, uid:%d, resid:%d, state:%d", m_user.db.uid, sp_task->resid, sp_task->state));
            if (sp_task->state == 0)
                add_task(sp_task);
            else m_finished_bline.insert(sp_task->resid);
        }
    }
}

void sc_task_mgr_t::save_db(sp_task_t& sp_task_)
{
    string sql = sp_task_->get_up_sql();  
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

sc_task_mgr_t::sp_task_t sc_task_mgr_t::add_task(int resid_)
{
    sp_task_t sp_task(new task_t);
    sp_task->uid = m_user.db.uid;
    sp_task->resid = resid_;
    sp_task->step = 0;
    sp_task->state = 0;
    if (add_task(sp_task))
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Task_t& db_){
            db_.insert();
        }, sp_task->data());
        return sp_task;
    }
    else return sp_task_t();
}
bool sc_task_mgr_t::get_task(int resid_, sp_task_t& sp_task_)
{
    auto it = m_tasks.find(resid_);
    if (it != m_tasks.end())
    {
        sp_task_ = it->second;
        return true;
    }
    return false;
}
bool sc_task_mgr_t::add_task(sp_task_t sp_task_)
{
    m_tasks.insert(make_pair(sp_task_->resid, sp_task_));
    repo_def::quest_t* rp_quest = repo_mgr.quest.get(sp_task_->resid);
    if (rp_quest == NULL)
    {
        logerror((LOG, "repo no quest resid:%d", sp_task_->resid));
        return false;
    }
    switch(rp_quest->type)
    {
    //通关N次
    case 1:
        watch_task(m_pass_rounds, rp_quest, sp_task_);
        break;
    //杀怪N次
    case 2:
        watch_task(m_kill_monsters, rp_quest, sp_task_);
        break;
    //获得物品N个
    case 3:
        watch_task(m_coll_items, rp_quest, sp_task_);
        break;
    }
    return true;
}
void sc_task_mgr_t::watch_task(watch_task_t& wt_, repo_def::quest_t* quest_, sp_task_t sp_task_)
{
    if (quest_->value.size() < 3)
    {
        logerror((LOG, "repo quest resid:%d has error value size<3", sp_task_->resid));
        return;
    }

    int resid = quest_->value[1];

    auto it =wt_.find(resid);
    if (it == wt_.end())
    {
        it = wt_.insert(make_pair(resid, task_set_t())).first;
    }
    it->second.insert(sp_task_);
}
int sc_task_mgr_t::unicast_task_list()
{
    sc_msg_def::ret_task_list_t ret;
    for(auto it=m_tasks.begin(); it!=m_tasks.end(); it++)
    {
        sc_msg_def::jpk_task_t task;
        task.resid = it->second->resid;
        task.step = it->second->step;
        ret.tasks.push_back(std::move(task));
    }
    logic.unicast(m_user.db.uid, ret);
    return 0;
}
int sc_task_mgr_t::get_jpk(task_vec_t& vec_)
{
    vec_.resize(m_tasks.size());
    size_t i=0;
    for(auto it=m_tasks.begin(); it!=m_tasks.end(); it++)
    {
        sc_msg_def::jpk_task_t& task = vec_[i++];
        task.resid = it->second->resid;
        task.step = it->second->step;
    }
    return 0;
}
int sc_task_mgr_t::unicast_finished_bline()
{
    sc_msg_def::ret_finished_bline_t ret;
    ret.resids.resize(m_finished_bline.size());
    int i=0;
    for(auto it = m_finished_bline.begin(); it!=m_finished_bline.end(); it++)
    {
        ret.resids[i++]=(*it);
        //logwarn((LOG, "unicast finished task, uid:%d, resid:%d", m_user.db.uid, (*it)));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}
int sc_task_mgr_t::request(int resid_)
{
    if (MAX_TASK <= m_tasks.size())
        return ERROR_TASK_FULL;

    repo_def::quest_t* rp_quest = repo_mgr.quest.get(resid_);
    if (rp_quest == NULL)
        return ERROR_SC_EXCEPTION;

    auto it = m_tasks.find(resid_);
    if (it != m_tasks.end())
        return ERROR_TASK_HAS_EXISTED;

    if (m_finished_bline.find(resid_) != m_finished_bline.end())
        return ERROR_TASK_REQ_INVALID;

    if (rp_quest->level > m_user.db.grade)
        return ERROR_TASK_REQ_INVALID;

    /*
    if (rp_quest->pre_quest > 0)
    {
        if (rp_quest->mainline == 0 && rp_quest->pre_quest != m_user.db.questid)
            return ERROR_TASK_REQ_INVALID;
        if (rp_quest->mainline == 1 && rp_quest->pre_quest > m_user.db.questid)
            return ERROR_TASK_REQ_INVALID;
    }
    */

    add_task(resid_);

    return SUCCESS;
}
int sc_task_mgr_t::commit(int resid_, int next_id_)
{
    repo_def::quest_t* rp_quest = repo_mgr.quest.get(resid_);
    if (rp_quest == NULL)
        return ERROR_SC_EXCEPTION;

    sp_task_t sp_task;
    if (false == get_task(resid_, sp_task))
        return ERROR_TASK_NOT_EXISTED;

    bool finished = false;
    switch(rp_quest->type)
    {
    //通关N次
    case 1:
        finished = del_watch_task(m_pass_rounds, rp_quest, sp_task, true);
        break;
    //杀怪N次
    case 2:
        finished = del_watch_task(m_kill_monsters, rp_quest, sp_task, true);
        break;
    //获得物品N个
    case 3:
        finished = del_watch_task(m_coll_items, rp_quest, sp_task, true);
        break;
    default:
        finished = true;
    }
    if (!finished)
        return ERROR_TASK_NOT_FINISHED;

    m_tasks.erase(resid_);
    if (rp_quest->task_class == 0)
    {
        m_user.db.set_questid(resid_);
        m_user.db.set_nextquestid(next_id_);

        db_service.async_do((uint64_t)m_user.db.uid, [](sp_task_t& sp_task_){
            sp_task_->remove();
        }, sp_task);
    }
    else
    {
        m_finished_bline.insert(resid_);

        //完成的支线保存,修改状态为1
        sp_task->set_state(1);
        save_db(sp_task);

    }

    if (rp_quest->coin > 0)
        m_user.on_money_change(rp_quest->coin);

    if (rp_quest->exp > 0)
        m_user.on_exp_change(rp_quest->exp);
    if (rp_quest->diamond > 0)
        m_user.on_freeyb_change(rp_quest->diamond);

    auto item_size = rp_quest->item_id.size();
    for(auto i = 0; i < item_size; i++)
    {
        if( rp_quest->item_id[i][0] >= 30000 && rp_quest->item_id[i][0] < 40000 )
        {
            sc_msg_def::nt_chip_change_t change;
            m_user.partner_mgr.add_new_chip(rp_quest->item_id[i][0],rp_quest->item_id[i][1],change);
            m_user.partner_mgr.on_chip_change(change);
        }
        else
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.addnew(rp_quest->item_id[i][0], rp_quest->item_id[i][1], nt);
            m_user.item_mgr.on_bag_change(nt);
        }
    }

    m_user.save_db();

    return SUCCESS;
}
int sc_task_mgr_t::abort(int resid_)
{
    repo_def::quest_t* rp_quest = repo_mgr.quest.get(resid_);
    if (rp_quest == NULL)
        return ERROR_SC_EXCEPTION;

    sp_task_t sp_task;
    if (false == get_task(resid_, sp_task))
        return ERROR_TASK_NOT_EXISTED;

    switch(rp_quest->type)
    {
    //通关N次
    case 1:
        del_watch_task(m_pass_rounds, rp_quest, sp_task);
        break;
    //杀怪N次
    case 2:
        del_watch_task(m_kill_monsters, rp_quest, sp_task);
        break;
    //获得物品N个
    case 3:
        del_watch_task(m_coll_items, rp_quest, sp_task);
        break;
    }
    m_tasks.erase(resid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Task_t& db_){
            db_.remove();
    }, sp_task->data());

    return SUCCESS;
}
bool sc_task_mgr_t::del_watch_task(watch_task_t& wt_, repo_def::quest_t* quest_, sp_task_t sp_task_, bool finished_)
{
    if (quest_->value.size() < 3)
    {
        logerror((LOG, "repo quest resid:%d has error value size<3", sp_task_->resid));
        return false;
    }

    int resid = quest_->value[1];
    int num = quest_->value[2];
    if (finished_ && num > sp_task_->step)
        return false;

    auto it = wt_.find(resid);
    it->second.erase(sp_task_);
    return true;
}
void sc_task_mgr_t::on_round_pass(int resid_)
{
    watch_task_step(m_pass_rounds, resid_, 1);
}
void sc_task_mgr_t::on_got_items(int resid_, int num_)
{
    watch_task_step(m_coll_items, resid_, num_);
}
void sc_task_mgr_t::on_monsert_killed(int resid_, int num_)
{
    //logwarn((LOG, "on_monsert_killed, kill:%d, num:%d", resid_, num_));
    watch_task_step(m_kill_monsters, resid_, num_);
}
void sc_task_mgr_t::watch_task_step(watch_task_t& wt_, int resid_, int n_)
{
    auto it = wt_.find(resid_);
    if (it != wt_.end())
    {
        for(auto itt = it->second.begin(); itt != it->second.end(); itt++)
        {
            (*itt)->set_step((*itt)->step + n_);

            repo_def::quest_t* rp_quest = repo_mgr.quest.get((*itt)->resid);
            if (rp_quest == NULL)
                continue;

            /*
            logwarn((LOG, "uid:%d watch task %d step resid:%d, n:%d, now:%d, target:%d", 
                m_user.db.uid, (*itt)->resid, resid_, n_, (*itt)->step, rp_quest->value[2]));
            */

            if ((*itt)->step < rp_quest->value[2] || ((*itt)->step-n_) < rp_quest->value[2])
            {
                sc_msg_def::nt_task_change_t nt;
                nt.task.resid = (*itt)->resid;
                nt.task.step = (*itt)->step;
                logic.unicast(m_user.db.uid, nt);

                string sql = (*itt)->get_up_sql();  
                db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
                        db_service.async_execute(sql_);
                }, sql);
            }
        }
    }
}
