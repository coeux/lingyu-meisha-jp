#include "sc_act_daily_task.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "date_helper.h"

#define LOG "SC_ACT_DAILY_TASK"

sc_act_daily_task_t::sc_act_daily_task_t(sc_user_t& user_):
m_user(user_)
{
}
void sc_act_daily_task_t::load_db()
{
    sql_result_t res;
    if (0==db_ActDailyTask_ext_t::sync_select_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_adt_t sp_adt(new db_ActDailyTask_ext_t);
            sp_adt->init(*res.get_row_at(i));
            m_adt_map.insert(make_pair(sp_adt->resid, sp_adt));

            auto rp_adt = repo_mgr.quest_daily.get(sp_adt->resid);
            if (rp_adt != NULL)
            {
                //每天12点重置
                if (date_helper.offday(sp_adt->stamp)>=1)
                {
                    sp_adt->step = 0;
                    sp_adt->collect = 0;
                    save_db(sp_adt);
                }
            }
        }
    }
}

void sc_act_daily_task_t::init_new_user()
{
    if (repo_mgr.quest_daily.size() <= 0)
    {
        logerror((LOG, "sc_act_daily_task_t, init_new_user faild, repo_mgr.quest_daily.size <= 0, uid:%d", m_user.db.uid));
        return ;
    }
    for (auto it = repo_mgr.quest_daily.begin(); it != repo_mgr.quest_daily.end(); ++it)
    {
        sp_adt_t sp_adt(new db_ActDailyTask_ext_t);
        sp_adt->uid = m_user.db.uid;
        sp_adt->resid = it->first;
        sp_adt->step = 0;
        sp_adt->collect = 0;
        sp_adt->stamp = date_helper.cur_sec();

        db_service.async_do((uint64_t)m_user.db.uid, [](sp_adt_t& sp_adt_){
            sp_adt_->insert();
        }, sp_adt);

        m_adt_map.insert(make_pair(sp_adt->resid, sp_adt));
    }
}

void sc_act_daily_task_t::unicast()
{
    /*
    if (date_helper.offday(m_user.reward.db.adt_stamp) >= 1)
    {
        m_user.reward.db.set_adt_stamp(date_helper.cur_sec());
        m_user.reward.save_db();
        m_user.reward.db.set_adt_reward(0);
        m_user.reward.save_db();
    }
    */

    sc_msg_def::ret_act_task_t ret;
    for(auto it=m_adt_map.begin(); it != m_adt_map.end(); it++)
    {
        sc_msg_def::jpk_daily_task_t jpk;
        //每天12点重置
        if (date_helper.offday(it->second->stamp)>=1)
        {
            it->second->step = 0;
            it->second->collect = 0;
            save_db(it->second);
        }
        if (it->second->collect == 1)
            continue;
        jpk.resid = it->second->resid;
        jpk.step = it->second->step;
        jpk.collect = it->second->collect;
        ret.tasks.push_back(std::move(jpk));
    }

    //ret.rewarded_ids = m_user.reward.db.adt_reward;
    logic.unicast(m_user.db.uid, ret);
}
void sc_act_daily_task_t::save_db(sp_adt_t sp_adt_)
{
    db_service.async_do((uint64_t)m_user.db.uid, [](sp_adt_t sp_adt_){
        sp_adt_->update();
    }, sp_adt_);
}
int sc_act_daily_task_t::on_event(int evt_)
{
    auto rp_adt = repo_mgr.quest_daily.get(evt_);
    if (rp_adt == NULL)
        return -1;

    if (rp_adt->openlv > m_user.db.grade)
        return -1;

    /*
    if (date_helper.offday(m_user.reward.db.adt_stamp) >= 1)
    {
        m_user.reward.db.set_adt_stamp(date_helper.cur_sec());
        m_user.reward.save_db();
        m_user.reward.db.set_adt_reward(0);
        m_user.reward.save_db();
    }
    */

    sp_adt_t sp_adt;
    auto it = m_adt_map.find(evt_);
    if (it != m_adt_map.end())
    {
        sp_adt = it->second;
        //每天12点重置
        if (date_helper.offday(it->second->stamp)>=1)
            it->second->step = 0;
        //达到最大次数则返回
        if (it->second->step >= rp_adt->times)
            return -1;
        //printf("%d,%d,%d, %d\n", evt_, it->second->step, rp_adt->id, rp_adt->times);
        it->second->step++;
        sp_adt->stamp = date_helper.cur_sec();
        save_db(it->second);
    }
    else
    {
        sp_adt.reset(new db_ActDailyTask_ext_t);
        sp_adt->uid = m_user.db.uid;
        sp_adt->resid = evt_;
        sp_adt->step = 1;
        sp_adt->collect = 0;
        sp_adt->stamp = date_helper.cur_sec();
        m_adt_map.insert(make_pair(sp_adt->resid, sp_adt));

        db_service.async_do((uint64_t)m_user.db.uid, [](sp_adt_t sp_adt_){
            sp_adt_->insert();
        }, sp_adt);
    }

    sc_msg_def::nt_act_changed_t nt;
    nt.resid = sp_adt->resid;
    nt.step = sp_adt->step;
    logic.unicast(m_user.db.uid, nt);

    return 0;
}
int sc_act_daily_task_t::given_reward(int id_ ,bool isDouble)
{
    /*
    auto rp_qdr = repo_mgr.quest_daily_reward.get(id_);
    if (rp_qdr == NULL)
        return -1;

    if (rp_qdr->active > m_adtv)
        return -1;

    if ((m_user.reward.db.adt_reward & (1 << id_)) > 0)
        return -1;

    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(rp_qdr->reward1,rp_qdr->reward1_count,nt);
    m_user.item_mgr.addnew(rp_qdr->reward2,rp_qdr->reward2_count,nt);
    m_user.item_mgr.addnew(rp_qdr->reward3,rp_qdr->reward3_count,nt);
    m_user.item_mgr.on_bag_change(nt);
    
    m_user.reward.db.set_adt_reward(m_user.reward.db.adt_reward | (1 << id_));
    m_user.reward.save_db();
    */

    auto rp_qdr = repo_mgr.quest_daily.get(id_);
    if (rp_qdr == NULL)
    {
        logerror((LOG, "give_reward failed, table quest_daily is null, uid:%d", m_user.db.uid));
        return ERROR_DTASK_NO_TASK;
    }
    auto it = m_adt_map.find(id_);
    if (it == m_adt_map.end())
    {
        logerror((LOG, "give_reward failed, daily task[%d] not exists, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_SERVER_NO_TASK;
    }
    if (it->second->collect == 1)
    {
        logerror((LOG, "give_reward failed, daily task[%d] has been collected, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_FINISHED;
    }
    if (it->second->step < rp_qdr->times)
    {
        logerror((LOG, "give_reward failed, daily task[%d] unfinished, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_NOT_FINISHED;
    }

    it->second->collect = 1;
    save_db(it->second);

    if (rp_qdr->power >= 0)
        m_user.on_power_change(rp_qdr->power);
    if (rp_qdr->exp >= 0 && isDouble){
        m_user.on_exp_change((uint32_t)rp_qdr->exp * 1.2);
    }else if(rp_qdr->exp >= 0 && (!isDouble))
    {
        m_user.on_exp_change(rp_qdr->exp);
    }
    if (rp_qdr->diamond >= 0)
        m_user.on_freeyb_change(rp_qdr->diamond);
    if (rp_qdr->coin >= 0)
        m_user.on_money_change(rp_qdr->coin);
    uint32_t size = rp_qdr->reward.size();
    sc_msg_def::nt_bag_change_t nt;
    for (uint32_t i = 1; i < size; ++i)
    {
        m_user.item_mgr.addnew(rp_qdr->reward[i][0], rp_qdr->reward[i][1], nt);
    }
    m_user.item_mgr.on_bag_change(nt);
    return 0;
}
