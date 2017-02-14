#ifndef _sc_love_task_h_
#define _sc_love_task_h_

#include "msg_def.h"
#include "db_ext.h"
#include "repo_def.h"

#include <boost/shared_ptr.hpp>

#include <unordered_map>
#include <vector>
using namespace std;

class sc_user_t;

class sc_love_task_mgr_t
{
    typedef db_LoveTask_ext_t love_task_t;
    typedef boost::shared_ptr<love_task_t> sp_love_task_t;
    typedef unordered_map<int32_t, sp_love_task_t> love_task_hm_t;
    typedef set<sp_love_task_t> love_task_set_t;
    typedef unordered_map<int32_t, love_task_set_t> watch_love_task_t;
    typedef map<int32_t, int32_t> pid_ltid_t; //已完成任务的映射关系 partner id->love task id
public:
    sc_love_task_mgr_t(sc_user_t& user_);
    void load_db();
    void async_load_db();
    void save_db(sp_love_task_t& sp_love_task_);

    int unicast_love_task_list();
    int request(int resid_);
    int commit(int resid_, sc_msg_def::ret_commit_love_task_t& ret);

    void on_round_pass(int resid_);
    void on_got_items(int resid_, int num_);
    void on_monster_killed(int resid_, int num_);

    sp_love_task_t add_love_task(int resid_, int32_t pid_);
    bool get_love_task(int resid_, sp_love_task_t& sp_love_task_);

    void init_new_user();
    int32_t cal_love_reward_pro(int32_t pid_, float* m_base_pro_);
    int32_t get_love_coefficient(int32_t pid_, double& atk_, double& mgc_, double& def_, double& res_, double& hp_);
    float get_gold_discount(int32_t pid_);
private:
    bool add_love_task(sp_love_task_t sp_love_task_);
    void refresh_coll_items_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_);
    void watch_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_, sp_love_task_t sp_love_task_);
    bool del_watch_love_task(watch_love_task_t& wlt_, repo_def::love_task_t* love_task_, sp_love_task_t sp_love_task_, bool finished_ = false);
    void watch_love_task_step(watch_love_task_t& wlt_, int resid_, int n_);
private:
    sc_user_t& m_user;
    love_task_hm_t m_love_tasks;
    watch_love_task_t m_pass_rounds;
    watch_love_task_t m_coll_items;
    watch_love_task_t m_kill_monsters;
    pid_ltid_t m_pid_ltid;
};

#endif
