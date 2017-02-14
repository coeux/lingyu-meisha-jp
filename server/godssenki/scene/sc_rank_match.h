#ifndef _sc_rank_match_h_
#define _sc_rank_match_h_

#include "singleton.h"
#include "repo_def.h"
#include "db_ext.h"
#include "code_def.h"
#include "msg_def.h"

#include <boost/shared_ptr.hpp>
using namespace std;

struct queue_member
{
    int32_t stamp;
    int32_t uid;
    int32_t req_times;
};


class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;
class sc_rank_match_t
{
    /* rank_match */
public:
    sc_rank_match_t();
    void load_db(vector<int32_t>& hostnums_);
    int32_t match(int32_t uid_, sc_msg_def::req_rank_season_match_t& jpk_, sp_user_t sp_user_);
    int32_t cancel_wait(int32_t uid_, sp_user_t sp_user_);
    //void save_queue_info();
    void update_db_user_info(queue_member& q_m, int r_t, sp_fight_view_user_t view_);
private:
    void update_host_queue_info();
    void online_push_back(int r_t, queue_member& q_m);
    void online_pop(int32_t uid_);
    void reserve_push_back(int r_t, queue_member& q_m, yarray_t<int32_t, 5>& team_);
    int get_rank(int r_t, int32_t delta_);
    int get_rank_grade(int r_t);
    void init_constant();
    void init_default_user();
    int32_t get_default_fight_user(int32_t uid_, int32_t rank_, int32_t* pids);
    sp_fight_view_user_t get_default_fight_view();
private:
    //reserve_queue 用于储存本服务器上该分段最近匹配过人的数据，key为uid
    unordered_map<int, unordered_map<int32_t, queue_member>> reserve_queue;
    //other_reserve_queue 用于储存其他服务器上的人员数据，key为uid
    unordered_map<int, unordered_map<int32_t, queue_member>> other_reserve_queue;
    //online_queue 用于保存当前正在等待匹配人的uid
    unordered_map<int, unordered_map<int32_t, queue_member>> online_queue;
    //
    unordered_map<int32_t, string> other_reserve_cache;
    unordered_map<int32_t, sp_fight_view_user_t> cur_view_cache;
    unordered_map<int32_t, queue_member> rank_map;

    unordered_map<int32_t, sc_msg_def::jpk_fight_view_role_data_t> default_user_view;
    vector<int32_t> default_user_pid;

    int host_num;
    bool default_get;
};
#define rank_match_s (singleton_t<sc_rank_match_t>::instance())
#endif
