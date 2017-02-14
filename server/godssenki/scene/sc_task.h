#ifndef _sc_task_h_
#define _sc_task_h_

#include "msg_def.h"
#include "db_ext.h"
#include "repo_def.h"

#include <boost/shared_ptr.hpp>

#include <unordered_map>
#include <vector>
using namespace std;

class sc_user_t;

typedef vector<sc_msg_def::jpk_task_t> task_vec_t;

class sc_task_mgr_t
{
    typedef db_Task_ext_t task_t;
    typedef boost::shared_ptr<task_t> sp_task_t;
    typedef unordered_map<int32_t, sp_task_t> task_hm_t;
    typedef set<sp_task_t> task_set_t;
    typedef unordered_map<int32_t, task_set_t> watch_task_t;
    typedef set<int32_t> resid_set_t;
public:
    sc_task_mgr_t(sc_user_t& user_);
    void load_db();
    void async_load_db();
    void save_db(sp_task_t& sp_task_);

    int unicast_task_list();
    int get_jpk(task_vec_t& vec_);
    int unicast_finished_bline();
    int request(int resid_);
    int commit(int resid_, int next_id_);
    int abort(int resid_);

    void on_round_pass(int resid_);
    void on_got_items(int resid_, int num_);
    void on_monsert_killed(int resid_, int num_);

    sp_task_t add_task(int resid_);
    bool get_task(int resid_, sp_task_t& sp_task_);
private:
    bool add_task(sp_task_t sp_task_);
    void watch_task(watch_task_t& wt_, repo_def::quest_t* quest_, sp_task_t sp_task_);
    bool del_watch_task(watch_task_t& wt_, repo_def::quest_t* quest_, sp_task_t sp_task_, bool finished_ = false);
    void watch_task_step(watch_task_t& wt_, int resid_, int n_);
private:
    sc_user_t&      m_user;
    task_hm_t       m_tasks;
    resid_set_t     m_finished_bline; //完成的支线任务
    watch_task_t    m_pass_rounds;
    watch_task_t    m_coll_items;
    watch_task_t    m_kill_monsters;
};

#endif
