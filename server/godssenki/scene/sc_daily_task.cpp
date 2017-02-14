#include "sc_daily_task.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "log.h"
#include "repo_def.h"
#include "code_def.h"
#include "date_helper.h"
#include "random.h"
#include "sc_guidence.h"

#define MAX_DAILY_TASK 4
#define MAX_DAILY_DO 10

#define LOG "SC_DAILY_TASK"

sc_daily_task_t::sc_daily_task_t(sc_user_t& user_):
m_user(user_) 
{
}
/*
int sc_daily_task_t::gen_task()
{
    if (!daily_task_cache.get(m_user.db.uid, m_sp_cdtask))
    {
        m_sp_cdtask = sp_cdtask_t(new cdtask_t);
        m_sp_cdtask->gen_time = date_helper.cur_sec();
        m_sp_cdtask->tasks.resize(MAX_DAILY_TASK, {0, 0, 0, 0, 0});
        m_sp_cdtask->num = 0;
        m_sp_cdtask->buy_num = 0;
        m_sp_cdtask->do_num_hm.clear();
        daily_task_cache.add(m_user.db.uid, m_sp_cdtask);
    }

    if (date_helper.offday(m_sp_cdtask->gen_time) >= 1)
    {
        m_sp_cdtask->gen_time = date_helper.cur_sec();
        m_sp_cdtask->num = 0;
        m_sp_cdtask->buy_num = 0;
        m_sp_cdtask->do_num_hm.clear();
    }

    int size = repo_mgr.quest_daily_mm.size();
    if (size <= 0)
    {
        logerror((LOG, "gen_task daily task total<=0!"));
        return -1;
    }

    set<int> rtype_set;
    for(int i=0; i<MAX_DAILY_TASK; i++)
    {
        if (m_sp_cdtask->tasks[i].type != 0 && !m_sp_cdtask->tasks[i].finished)
        {
            rtype_set.insert(m_sp_cdtask->tasks[i].type);
        }
    }

    //新手第一个任务指定
    int i = 0;
    if( (m_user.db.isnew & (1<<evt_guidence_dailyquest))==0 )
    {
        dtask_t& t = m_sp_cdtask->tasks[0]; 
        if( t.resid == 0 )
        {
            t.resid = 21;
            t.type = 12;
            t.step = 0;
            t.finished = 0;
            t.max_step = 1;

            i = 1;
        }
        rtype_set.insert(12);
    }

    for(; i<MAX_DAILY_TASK; i++)
    {
        if (m_sp_cdtask->tasks[i].type != 0 && !m_sp_cdtask->tasks[i].finished)
        {
            continue;
        }

        int rtype = random_t::rand_integer(1,size);
        auto itt = repo_mgr.quest_daily_mm.begin();
        int num = 0; 
        int n = 0;
        int nn = 0;
        int nnn=0;
        do
        {
        begin_rtype_change:
            //如果所有的类型都被遍历到，但依然没有找到合适的任务，则跳出循环
            if (nnn >= size){
                logerror((LOG, "loop all type, no found! nnn:%d, size:%d", nnn, size));
                return -1;
            }
            nnn++;

            rtype = rtype % size + 1;
            itt = repo_mgr.quest_daily_mm.find(rtype);
            if (itt == repo_mgr.quest_daily_mm.end())
            {
                //logerror((LOG, "no rtype:%d", rtype));
                goto begin_rtype_change;
            }
            num = itt->second.size(); 
            n = random_t::rand_integer(0,num-1);
            nn = 0;
        begin_n_change:
            if (nn >= num)
                goto begin_rtype_change;
            n = (n+1) % num;
            nn++;

            if (itt->second[n].openlv > m_user.db.grade)
            {
                goto begin_n_change;
            }
            auto it_donum = m_sp_cdtask->do_num_hm.find(itt->second[n].id);
            if (it_donum != m_sp_cdtask->do_num_hm.end())
            {
                if (it_donum->second >= itt->second[n].count)
                {
                    goto begin_n_change;
                }
                else it_donum->second++;
            }
            else m_sp_cdtask->do_num_hm[itt->second[n].id] = 1;
        }
        while(rtype_set.find(rtype) != rtype_set.end());

        rtype_set.insert(rtype);

        dtask_t& t = m_sp_cdtask->tasks[i]; 
        t.resid = itt->second[n].id;
        t.type = itt->second[n].type;
        t.step = 0;
        t.finished = 0;
        t.max_step = itt->second[n].times;
    }

    return SUCCESS;
}
*/

int sc_daily_task_t::gen_task()
{
    int size = repo_mgr.quest_daily_t.size();
    if (size <= 0)
    {
        logerror((LOG, "gen_task daily task total <= 0!"));
        return -1;
    }

    if (!daily_task_cache.get(m_user.db.uid, m_sp_cdtask))
    {
        m_sp_cdtask = sp_cdtask_t(new cd_task_t);
        m_sp_cdtask->gen_time = date_helper.cur_sec();
        m_sp_cdtask->tasks.resize(size, {0, 0, 0, 0, 0});
        daily_task_cache.add(m_user.db.uid, m_sp_cdtask);
    }

    if (date_helper.offday(m_sp_cdtask->gen_time) >= 1)
    {
        m_sp_cdtask->gen_time = date_helper.cur_sec();
        m_sp_cdtask->tasks.clear();
    }
    else
        return SUCCESS;

    for (auto it = repo_mgr.quest_daily_t.begin(); it != repo_mgr.quest_daily_t.end(); ++it)
    {
        sp_dtask_t sp_dtask_;
        sp_dtask_->resid = it->resid;
        sp_dtask_->type = it->type;
        sp_dtask_->step = 0;
        sp_dtask_->max_step = it->times;
        sp_dtask_->finished = false;

        m_sp_cdtask->tasks.push_back(std::move(sp_dtask_));
    }
    return SUCCESS;
}

int sc_daily_task_t::on_event(int evt_)
{
    if (m_sp_cdtask == NULL)
        return -1;
    auto it = std::find_if(m_sp_cdtask->tasks.begin(), m_sp_cdtask->tasks.end(), [&](dtask_t& task_){
        return (task_.type == evt_);
    });
    if (it == m_sp_cdtask->tasks.end())
        return -1;
    (*it).step++;
    return SUCCESS;
}
int sc_daily_task_t::unicast_dtask_list()
{
    /*
    gen_task();

    sc_msg_def::ret_daily_task_list_t ret;
    ret.tasks.resize();
    for(int i=0; i<MAX_DAILY_TASK; i++)
    {
        ret.tasks[i].resid = m_sp_cdtask->tasks[i].resid;
        ret.tasks[i].step = m_sp_cdtask->tasks[i].step;
    }
    ret.num = m_sp_cdtask->num;
    ret.buy_num = m_sp_cdtask->buy_num;
    logic.unicast(m_user.db.uid, ret);
    */
    gen_task();

    sc_msg_def::ret_daily_task_list_t ret;
    int i = 0;
    for (auto it = m_sp_cdtask.tasks.begin(); it != m_sp_cdtask.tasks.end(); ++it)
    {
        ret.tasks[i].resid = it->resid;
        ret.tasks[i].step = it->step;
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}
int sc_daily_task_t::commit(int pos_)
{
    if (m_sp_cdtask->num >= MAX_DAILY_DO)
    {
        return ERROR_DTASK_MAX_DO ;
    }

    if (1 <= pos_ && pos_ <= 4)
    {
        dtask_t& t = m_sp_cdtask->tasks[pos_-1];
        if (!t.finished && t.step >= t.max_step)
        {
            repo_def::quest_daily_reward_t* rp_reward = repo_mgr.quest_daily_reward.get(m_user.db.grade);
            if (rp_reward == NULL)
            {
                logerror((LOG, "repo dailyquest_reward no level:%d", m_user.db.grade));
                return ERROR_SC_EXCEPTION;
            }

            t.finished = 1;

            m_sp_cdtask->num++;

            m_user.on_exp_change(rp_reward->exp);
            m_user.on_money_change(rp_reward->coin);
            m_user.save_db();

            if(( m_user.db.isnew & (1<<evt_guidence_dailyquest))==0 )
                guidence_ins.on_guidence_event(m_user,evt_guidence_dailyquest);

            return SUCCESS; 
        }
    }
    return ERROR_SC_EXCEPTION;
}
int sc_daily_task_t::buy_num()
{
    int32_t code = m_user.vip.buy_vip(vop_reset_daily_task);
    if (code == SUCCESS)
    {
        //修改cache数据
        m_sp_cdtask->buy_num++;
        m_sp_cdtask->num = 0;
        m_sp_cdtask->do_num_hm.clear();
    }

    return SUCCESS;
}
void sc_daily_task_t::on_login()
{
    if( (m_user.db.isnew & (1<<evt_guidence_dailyquest)) > 0)
        gen_task();
}
//=================================================
void sc_daily_task_cache_t::add(int32_t uid_, sp_cdtask_t& sp_task_)
{
    m_dtasks[uid_] = sp_task_;
}
bool sc_daily_task_cache_t::get(int32_t uid_, sp_cdtask_t& sp_task_)
{
    auto it = m_dtasks.find(uid_);
    if (it == m_dtasks.end())
        return false;

    sp_task_ = it->second;
    return true;
}
int  sc_daily_task_cache_t::get_dtask_num(int32_t uid_)
{
    auto it = m_dtasks.find(uid_);
    if (it == m_dtasks.end())
        return 0;

    return it->second->num;
}
