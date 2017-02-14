#include "sc_trial.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_statics.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "msg_def.h"
#include <sys/time.h>
#include <atomic>
#include "sc_cache.h"
#include "date_helper.h"
#include "sc_guidence.h"

#define LOG "SC_TRIAL"
#define N_TRAIL_TASK 5
#define N_TRAIL_TARGET 3
#define FLUSH_INTERVAL_SEC 7200

sc_trial_ctl_t::sc_trial_ctl_t()
{
    flush_time = date_helper.cur_sec();

    //生成试炼任务概率
    int32_t i=0;
    auto it_hm = repo_mgr.trial.begin();
    while( it_hm != repo_mgr.trial.end() )
    {
        if( 0==i )
            prob_task[0]=it_hm->second.probab;
        else
            prob_task[i]=prob_task[i-1]+it_hm->second.probab;

        prob_task_id[i]=it_hm->second.id;
        ++i;
        ++it_hm;
    }

    //生成试炼任务奖励概率
    auto it_reward=repo_mgr.trial_reward.begin();
    while( it_reward != repo_mgr.trial_reward.end() )
    {
        switch( it_reward->second.id )
        {
            case 1:
                {
                    for(size_t j=1;j<it_reward->second.item_pro.size();++j)
                    {
                        vector<int32_t> &reward=it_reward->second.item_pro[j];
                        if( reward.size() != 2)
                        {
                            logerror((LOG, "生成试炼任务奖励概率失败"));
                            return;
                        }
                        if(1==j)
                            prob_trial_reward[0][0]=reward[1];
                        else
                            prob_trial_reward[0][j-1]=prob_trial_reward[0][j-2]+reward[1];
                        prob_trial_reward_id[0][j-1]=reward[0];
                    }
                }
                break;
            case 2:
                {
                    for(size_t j=1;j<it_reward->second.item_pro.size();++j)
                    {
                        vector<int32_t> &reward=it_reward->second.item_pro[j];
                        if( reward.size() != 2)
                        {
                            logerror((LOG, "生成试炼任务奖励概率失败"));
                            return;
                        }
                        if(1==j)
                            prob_trial_reward[1][0]=reward[1];
                        else
                            prob_trial_reward[1][j-1]=prob_trial_reward[1][j-2]+reward[1];
                        prob_trial_reward_id[1][j-1]=reward[0];
                    }
                }
                break;
            case 3:
                {
                    for(size_t j=1;j<it_reward->second.item_pro.size();++j)
                    {
                        vector<int32_t> &reward=it_reward->second.item_pro[j];
                        if( reward.size() != 2)
                        {
                            logerror((LOG, "生成试炼任务奖励概率失败"));
                            return;
                        }
                        if(1==j)
                            prob_trial_reward[2][0]=reward[1];
                        else
                            prob_trial_reward[2][j-1]=prob_trial_reward[2][j-2]+reward[1];
                        prob_trial_reward_id[2][j-1]=reward[0];
                    }
                }
                break;
            case 4:
                {
                    for(size_t j=1;j<it_reward->second.item_pro.size();++j)
                    {
                        vector<int32_t> &reward=it_reward->second.item_pro[j];
                        if( reward.size() != 2)
                        {
                            logerror((LOG, "生成试炼任务奖励概率失败"));
                            return;
                        }
                        if(1==j)
                            prob_trial_reward[3][0]=reward[1];
                        else
                            prob_trial_reward[3][j-1]=prob_trial_reward[3][j-2]+reward[1];
                        prob_trial_reward_id[3][j-1]=reward[0];
                    }
                }
                break;
        }
        ++it_reward;
    }
}

/*
   sc_msg_def::jpk_role_data_t jpk;
   string str;
   jpk >> str;

   sc_msg_def::ret_trial_t
   {
   string target_jdata;
   };

   cjson.decode(target_jdata)
*/

void sc_trial_ctl_t::clear_outed_data()
{
    if (date_helper.offday(flush_time) >= 1)
    {
        //数据过期，清理
        m_trial_hm.clear();
        flush_time = date_helper.cur_sec();
    }
}

void sc_trial_ctl_t::get_trial_info(sp_user_t user_, int32_t uid_, sc_msg_def::ret_trial_info_t &ret_ )
{
//    clear_outed_data();

    int32_t new_flush = 0;
    auto it_hm = m_trial_hm.find(uid_);
    //没有该用户的试炼场数据，初始之
    if( it_hm == m_trial_hm.end() )
    {
        flush_task(user_, uid_, 0);
        new_flush = 1;
    }
    
    it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
    {
        logerror((LOG, "get_trial_info,serious error"));
        return;
    }

    ret_.trial.current_stage = it_hm->second.current_stage;
    ret_.trial.successed_target = it_hm->second.successed_target;
    ret_.trial.current_task = it_hm->second.task_pos;
    ret_.trial.tasks = it_hm->second.tasks;
    ret_.trial.targets = it_hm->second.targets;

    if( 1 == new_flush )
    {
        ret_.trial.left_secs = 0;
        it_hm->second.flush_tm = 0;
    }
    else
    {
        int32_t delta = date_helper.cur_sec() - it_hm->second.flush_tm;
        if( delta >= FLUSH_INTERVAL_SEC )
            ret_.trial.left_secs = 0;
        else
            ret_.trial.left_secs = FLUSH_INTERVAL_SEC - delta ;
    }
    
    flush_fp(ret_.trial.targets);
}
void sc_trial_ctl_t::flush_fp( vector<sc_msg_def::jpk_trial_target_info_t> &targets_ )
{
    for( auto it=targets_.begin();it!=targets_.end();++it)
    {
        sp_view_user_t view = view_cache.get_view(it->uid,true);
        if( view != NULL )
            it->fp = view_cache.get_fp_total(view);
    }
}

void sc_trial_ctl_t::flush_task(sp_user_t user_, int32_t uid_, int32_t flag_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
    {
        it_hm=m_trial_hm.insert(make_pair(uid_,sc_trial_info_t())).first;
    }
    uint32_t cur_sec = date_helper.cur_sec();
    if( cur_sec - it_hm->second.flush_tm < FLUSH_INTERVAL_SEC )
    {
        sc_msg_def::ret_trial_flush_task_failed_t fail;
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(uid_, fail);
        return;
    }
    it_hm->second.tasks.clear();

    sc_msg_def::jpk_trial_task_t task;
    //新手系统产生五个定制试炼任务
    if( (user_->db.isnew & (1<<evt_guidence_trial))==0 )
    {
        task.taskid = 1;
        task.rewardid = 15001;
        it_hm->second.tasks.push_back(task);
        task.taskid = 4;
        task.rewardid = 20002;
        it_hm->second.tasks.push_back(task);
        task.taskid = 2;
        task.rewardid = 15002;
        it_hm->second.tasks.push_back(task);
        task.taskid = 1;
        task.rewardid = 15001;
        it_hm->second.tasks.push_back(task);
        task.taskid = 3;
        task.rewardid = 20001;
        it_hm->second.tasks.push_back(task);

        guidence_ins.on_guidence_event(*user_,evt_guidence_trial);
        return;
    }

    it_hm->second.flush_tm = cur_sec;
    
    //随机产生5个试炼任务
    int32_t r;
    size_t j,k;
    for(int i=0;i<N_TRAIL_TASK;++i)
    {
        //随机产生试炼任务
        r = random_t::rand_integer(1, 10000);
        for(j=0;j<repo_mgr.trial.size();++j)
        {
            if(r<=prob_task[j])
                break;
        }
        task.taskid=prob_task_id[j];

        /*
        //测试bug，老是出现id为1250的任务
        if( j >= 4 )
        {
            logerror((LOG, "%d,%d,%d,%d\n",prob_task[0],prob_task[1],prob_task[2],prob_task[3]));
            logerror((LOG, "r=%d\n",r));
            logerror((LOG, "taskid=%d\n",task.taskid));
            assert(0);
        }
        */

        //随机产生试炼任务的奖励
        r=random_t::rand_integer(1, 10000);
        for(k=0;k<N_TRIAL_TASK_REWARD;++k)
        {
            if(r<=prob_trial_reward[task.taskid-1][k])
                break;
        }
        task.rewardid=prob_trial_reward_id[task.taskid-1][k];

        it_hm->second.tasks.push_back(task);
    }

    if( flag_ )
    {
        sc_msg_def::ret_trial_flush_task_t ret;
        ret.left_secs = FLUSH_INTERVAL_SEC;
        ret.tasks = it_hm->second.tasks;
        logic.unicast(uid_, ret);
    }
}

void sc_trial_ctl_t::flush_one_task(int32_t uid_, int32_t pos_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;

    int32_t r;
    size_t j,k;
    //随机产生试炼任务
    r = random_t::rand_integer(1, 10000);
    for(j=0;j<repo_mgr.trial.size();++j)
    {
        if(r<=prob_task[j])
            break;
    }
    it_hm->second.tasks[pos_].taskid=prob_task_id[j];

    //随机产生试炼任务的奖励
    r=random_t::rand_integer(1, 10000);
    for(k=0;k<N_TRIAL_TASK_REWARD;++k)
    {
        if( r<=prob_trial_reward[ prob_task_id[j]-1 ][k] )
            break;
    }
    it_hm->second.tasks[pos_].rewardid=prob_trial_reward_id[ prob_task_id[j]-1 ][k];
}

//flush all targets
void sc_trial_ctl_t::do_flush_targets(int32_t uid_, int32_t grade_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;

    //刷新对手
    it_hm->second.targets.clear();

    int tg=0,r;
    if( it_hm->second.task_pos<0 || it_hm->second.task_pos>=N_TRAIL_TASK )
        return;
    int32_t taskid = it_hm->second.tasks[ it_hm->second.task_pos ].taskid;

    switch( taskid )
    {
        case 1:
            {
                r = random_t::rand_integer(1, 5);
                tg = grade_-r;
                if( tg < 1 )
                    tg =1;
            }
            break;
        case 2:
            {
                r = random_t::rand_integer(0, 2);
                tg = grade_-r;
                if( tg <1)
                    tg =1;
            }
            break;
        case 3:
            {
                r = random_t::rand_integer(1, 2);
                tg = grade_+r;
                if( tg > MAX_GRADE )
                    tg = MAX_GRADE;
            }
            break;
        case 4:
            {
                r = random_t::rand_integer(1, 5);
                tg = grade_+r;
                if( tg > MAX_GRADE )
                    tg = MAX_GRADE;
            }
            break;
        default:
            return;
    }

//    sc_msg_def::jpk_trial_target_info_t info;
    vector<sc_msg_def::jpk_trial_target_info_t> ret;
    grade_user_cache.get_users(uid_,tg,ret);
    it_hm->second.targets = std::move(ret);
}
void sc_trial_ctl_t::get_target_info(int32_t uid_, sc_msg_def::jpk_trial_target_info_t &info_)
{
    //建立用户数据
    sp_user_t user;
    bool incache=true, online=true;
    if(!(incache=cache.get(uid_, user)) && !(online=logic.usermgr().get(uid_, user)))
    {
        user.reset(new sc_user_t);
        user->load_db(uid_);
        cache.put(user->db.uid, user);
    }

    info_.uid = uid_;
    info_.resid = user->db.resid;
    info_.name = user->db.nickname();
    info_.lv = user->db.grade;
    info_.fp = user->pro.get_fp();
}

void sc_trial_ctl_t::receive_task(int32_t uid_, int32_t grade_, int32_t pos_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;
    if( pos_<0 || pos_>=N_TRAIL_TASK )
        return;

    it_hm->second.current_stage=1;
    it_hm->second.successed_target=0;
    it_hm->second.task_pos = pos_;

    //刷新对手
    do_flush_targets(uid_,grade_);


    sc_msg_def::ret_trial_receive_task_t ret;
    ret.targets = it_hm->second.targets;
    flush_fp(ret.targets);
    logic.unicast(uid_, ret);
}

void sc_trial_ctl_t::giveup_task(int32_t uid_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;

    it_hm->second.current_stage=0;
    it_hm->second.successed_target=0;
    it_hm->second.task_pos = -1;

    sc_msg_def::ret_trial_giveup_task_t ret;
    ret.code = 0;
    logic.unicast(uid_, ret);
}

void sc_trial_ctl_t::flush_targets(sp_user_t user_, int32_t uid_,int32_t grade_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;

    //扣除水晶
    int32_t code = user_->vip.buy_vip(vop_flush_targets);
    if (code != SUCCESS)
    {
        sc_msg_def::ret_trial_flush_targets_failed_t ret;
        ret.code = code;
        logic.unicast(uid_, ret);
        return;
    }

    //刷新对手
    do_flush_targets(uid_,grade_);

    sc_msg_def::ret_trial_flush_targets ret;
    ret.targets = it_hm->second.targets;
    flush_fp(ret.targets);
    logic.unicast(uid_, ret);
}

void sc_trial_ctl_t::start_battle(sp_user_t user_, int32_t uid_, int32_t grade_, int32_t pos_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK)
        return;
    if( it_hm->second.current_stage!=1 || it_hm->second.successed_target>=3 )
    {
        sc_msg_def::ret_trial_start_batt_fail_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    if( pos_<0 || pos_ >2 )
        return;

    //判断活力是否足够
    if( user_->db.energy<1)
    {
        logerror((LOG, "start_battle, no energy, uid:%d", user_->db.uid));
        sc_msg_def::ret_trial_start_batt_fail_t ret;
        ret.code = ERROR_SC_NO_ENERGY;
        logic.unicast(user_->db.uid, ret);
        return ;
    }

    it_hm->second.current_stage=2;
    it_hm->second.current_target=pos_;

    sc_msg_def::ret_trial_start_batt_t ret;

    //获取目标数据
    sp_view_user_t sp_target_data=view_cache.get_view(it_hm->second.targets[pos_].uid, true);
    if (sp_target_data == NULL)
    {
        return ;
    }
    (*sp_target_data) >> ret.target_data;
    
    ret.battlexp = 10;

    logic.unicast(uid_, ret);
}

void sc_trial_ctl_t::get_rewards(sp_user_t user_, int32_t uid_)
{
    sc_msg_def::ret_trial_rewards_t ret;

    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;
    if( it_hm->second.current_stage!=1 || it_hm->second.successed_target<3 )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(uid_, ret);
    }
    
    //保存道具到数据库
    sc_msg_def::nt_bag_change_t nt;
    user_->item_mgr.addnew(it_hm->second.tasks[it_hm->second.task_pos].rewardid, 1, nt);
    user_->item_mgr.on_bag_change(nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*user_,4075,it_hm->second.tasks[it_hm->second.task_pos].rewardid,1,0);

    //增加战历
    auto it_reward=repo_mgr.trial_reward.find( it_hm->second.tasks[it_hm->second.task_pos].taskid );
    if( it_reward==repo_mgr.trial_reward.end() )
    {
        logerror(( LOG, "end_battle, repo no taskid, taskid:%d",it_hm->second.tasks[it_hm->second.task_pos].taskid));
        return;
    }

    user_->on_battlexp_change(it_reward->second.bpt);
    user_->save_db();

    ret.rewards = it_hm->second.tasks[it_hm->second.task_pos].rewardid;

    //刷新任务
    int32_t pos = it_hm->second.task_pos;
    if( pos<0 || pos>=N_TRAIL_TASK )
        return;
    flush_one_task(uid_, pos);
    ret.new_task = it_hm->second.tasks[pos];

    it_hm->second.current_stage=0;
    it_hm->second.successed_target=0;
    it_hm->second.task_pos=-1;

    ret.code = 0;
    logic.unicast(uid_, ret);

    //user_->daily_task.on_event(evt_trial_task);
}

void sc_trial_ctl_t::end_battle(sp_user_t user_, int32_t uid_, int32_t battle_win_)
{
    auto it_hm = m_trial_hm.find(uid_);
    if( it_hm == m_trial_hm.end() )
        return;
    if( it_hm->second.tasks.size() != N_TRAIL_TASK )
        return;

    if( 2!= it_hm->second.current_stage )
    {
        logerror(( LOG, "end_battle, not in battle"));
        return;
    }

    if( battle_win_ )
    {
        //扣去活力
        user_->on_energy_change(-1);
        //增加战历
        user_->on_battlexp_change(10);
        user_->save_db();

        (it_hm->second.successed_target)=(it_hm->second.successed_target)+1;
        it_hm->second.targets[it_hm->second.current_target].win = 1;
    }

    it_hm->second.current_stage=1;

    sc_msg_def::ret_trial_end_batt_t ret;
    ret.code = 0;
    logic.unicast(user_->db.uid, ret);
}
