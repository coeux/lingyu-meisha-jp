#include "sc_achievement.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "date_helper.h"

#define LOG "SC_ACHIVEVMENT"

sc_achievement_t::sc_achievement_t(sc_user_t& user_):
m_user(user_)
{
}
void sc_achievement_t::load_db()
{
    sql_result_t res;
    if (0==db_Achievement_t::sync_select_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_achievement_t sp_achievement(new db_Achievement_t); 
            sp_achievement->init(*res.get_row_at(i));
            if (sp_achievement->collect != 1)
                m_achievement_map.insert(make_pair(sp_achievement->resid, sp_achievement));
        }
    }
}

void sc_achievement_t::init_new_user()
{
    if (repo_mgr.achievement.size() <= 0)
    {
        logerror((LOG, "sc_achievement_t, init_new_user faild, repo_mgr.achievement.size <= 0, uid:%d", m_user.db.uid));
        return ;
    }
    for (auto it = repo_mgr.achievement.begin(); it != repo_mgr.achievement.end(); ++it)
    {
        if(it->second.sort == 1)
        {
            sp_achievement_t sp_achievement(new db_Achievement_t);
            sp_achievement->uid = m_user.db.uid;
            sp_achievement->resid = it->second.taskindex * 10000 + it->second.sort;
            sp_achievement->step = 0;
            sp_achievement->tasktype = it->second.taskindex;
            sp_achievement->systype = it->second.typeindex;
            sp_achievement->collect = 0;
            sp_achievement->stamp = date_helper.cur_sec();

            db_service.async_do((uint64_t)m_user.db.uid, [](sp_achievement_t& sp_achievement_t_){
                sp_achievement_t_->insert();
            }, sp_achievement);

            m_achievement_map.insert(make_pair(sp_achievement->resid, sp_achievement));
        }
    }
}

void sc_achievement_t::unicast()
{
    sc_msg_def::ret_achievement_t ret;
    for(auto it=m_achievement_map.begin(); it != m_achievement_map.end(); it++)
    {
        sc_msg_def::jpk_achievement_t jpk;
        if (it->second->collect == 1)
            continue;
        jpk.resid = it->second->resid;
        jpk.step = it->second->step;
        jpk.tasktype = it->second->tasktype;
        jpk.systype = it->second->systype;
        jpk.collect = it->second->collect;
        ret.tasks.push_back(std::move(jpk));
    }

    logic.unicast(m_user.db.uid, ret);
}
void sc_achievement_t::save_db(sp_achievement_t sp_achievement_)
{
    db_service.async_do((uint64_t)m_user.db.uid, [](sp_achievement_t sp_achievement_){
        sp_achievement_->update();
    }, sp_achievement_);
}
int sc_achievement_t::on_event(int evt_, int times)
{
    for (auto it = m_achievement_map.begin();it != m_achievement_map.end();it++)
    {
        sp_achievement_t sp_achievement;
        sp_achievement = it->second;
        if(it->second->tasktype == evt_ && it->second->collect != 1)
        {
            it->second->step = it->second->step + times;
            sp_achievement->stamp = date_helper.cur_sec();
            save_db(it->second);
        }
        sc_msg_def::nt_achievement_t nt;
        nt.resid = sp_achievement->resid;
        nt.step = sp_achievement->step;
        logic.unicast(m_user.db.uid, nt);

    }
    return 0;
}
int sc_achievement_t::given_reward(int id_)
{
    auto rp_qdr = repo_mgr.achievement.get(id_);
    if (rp_qdr == NULL)
    {
        logerror((LOG, "give_reward failed, table achievement is null, uid:%d", m_user.db.uid));
        return ERROR_DTASK_NO_TASK;
    }
    auto it = m_achievement_map.find(id_);
    if (it == m_achievement_map.end())
    {
        logerror((LOG, "give_reward failed, achievement[%d] not exists, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_SERVER_NO_TASK;
    }
    if (it->second->collect == 1)
    {
        logerror((LOG, "give_reward failed, achievement[%d] has been collected, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_FINISHED;
    }
    if (it->second->step < rp_qdr->times)
    {
        logerror((LOG, "give_reward failed, daily task[%d] unfinished, uid:%d", id_, m_user.db.uid));
        return ERROR_DTASK_NOT_FINISHED;
    }

    it->second->collect = 1;
    save_db(it->second);

    auto rp_nexttask = repo_mgr.achievement.get(id_ + 1);
    if (rp_nexttask != NULL)
    {
        sp_achievement_t sp_achievement(new db_Achievement_t);
        sp_achievement->uid = m_user.db.uid;
        sp_achievement->resid = rp_nexttask->taskindex * 10000 + rp_nexttask->sort;
        sp_achievement->step = it->second->step;
        sp_achievement->tasktype = rp_nexttask->taskindex;
        sp_achievement->systype = rp_nexttask->typeindex;
        sp_achievement->collect = 0;
        sp_achievement->stamp = date_helper.cur_sec();
        db_service.async_do((uint64_t)m_user.db.uid, [](sp_achievement_t& sp_achievement_t_){
            sp_achievement_t_->insert();    
        }, sp_achievement);
        m_achievement_map.insert(make_pair(sp_achievement->resid,sp_achievement));
    }
    
    if (rp_qdr->power >= 0)
        m_user.on_power_change(rp_qdr->power);
    if (rp_qdr->exp >= 0)
        m_user.on_exp_change(rp_qdr->exp);
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
