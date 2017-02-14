#ifndef _SC_TRIAL_H_
#define _SC_TRIAL_H_

#include <stdint.h>
#include "msg_def.h"
#include "code_def.h"
#include "sc_user.h"

#include <vector>
#include <ext/hash_map>
#include <list>

using namespace __gnu_cxx;
using namespace std;

#define N_TRIAL 4
#define N_TRIAL_TASK_REWARD 10
#define MAX_GRADE 200

struct sc_trial_info_t
{
    //0 未接任务
    //1 已接任务
    //2 正在战斗
    int32_t current_stage;
    //正在战斗的对手
    int32_t current_target;
    //已经打赢的对手数
    int32_t successed_target;
    //刷新任务时间
    uint32_t        flush_tm;
    //已经接的任务
    //sc_msg_def::jpk_trial_task_t current_task;
    int32_t task_pos;
    //试炼场任务
    vector<sc_msg_def::jpk_trial_task_t> tasks;
    //当前已接任务的对手
    vector<sc_msg_def::jpk_trial_target_info_t> targets;
    sc_trial_info_t():current_stage(0),current_target(0),successed_target(0),flush_tm(0),task_pos(-1)
    {
    }
};

class sc_trial_ctl_t
{
    typedef hash_map<int32_t, sc_trial_info_t > trial_hm_t;
private:
    uint32_t flush_time;
    trial_hm_t m_trial_hm;
    //试炼任务概率表
    int32_t prob_task[N_TRIAL];
    int32_t prob_task_id[N_TRIAL];
    //试炼任务掉落概率表
    int32_t prob_trial_reward[N_TRIAL][N_TRIAL_TASK_REWARD];
    int32_t prob_trial_reward_id[N_TRIAL][N_TRIAL_TASK_REWARD];
private:
    //刷新一个任务
    void flush_one_task(int32_t uid_, int32_t pos_);
    void clear_outed_data();
    void get_target_info(int32_t uid_, sc_msg_def::jpk_trial_target_info_t &info_);
    void flush_fp( vector<sc_msg_def::jpk_trial_target_info_t> &targets );

    //flush all targets
    void do_flush_targets(int32_t uid_, int32_t grade_);
public:
    sc_trial_ctl_t();
    //请求试炼场信息
    void get_trial_info(sp_user_t user_,int32_t uid_,sc_msg_def::ret_trial_info_t &ret_ );
    //接任务
    void receive_task(int32_t uid_, int32_t grade_, int32_t pos_);
    //放弃任务
    void giveup_task(int32_t uid_);
    //刷新任务
    void flush_task(sp_user_t user_, int32_t uid_, int32_t flag_);
    //刷新对手
    void flush_targets(sp_user_t user_, int32_t uid_,int32_t grade_);
    //开始战斗
    void start_battle(sp_user_t user_, int32_t uid_, int32_t grade_, int32_t pos_);
    //结束战斗
    void end_battle(sp_user_t user_, int32_t uid_, int32_t battle_win_);
    //领取奖励
    void get_rewards(sp_user_t user_, int32_t uid_);
};
#define trial_ctl (singleton_t<sc_trial_ctl_t>::instance())

#endif
