#ifndef _sc_rank_season_h_
#define _sc_rank_season_h_

#include "singleton.h"
#include "repo_def.h"
#include "db_ext.h"
#include "code_def.h"
#include "msg_def.h"

using namespace std;

/*
 * @ rank type
typedef enum rank_type
{
    challenger1 = 10,
    diamond1 = 21,
    diamond2 = 22,
    diamond3 = 23,
    platinum1 = 31,
    platinum2 = 32,
    platinum3 = 33,
    gold1 = 41,
    gold2 = 42,
    gold3 = 43,
    silver1 = 51,
    silver2 = 52,
    silver3 = 53,
    bronze1 = 61,
    bronze2 = 62,
    bronze3 = 63,
};

typedef enum rank_grade
{
    challenger = 1,
    diamond = 2,
    platinum = 3,
    gold = 4,
    silver = 5,
    bronze = 6,
}
*/

struct user_info_set
{
    int32_t uid;                        // 用户id
    int32_t rank;                       // 用户段位
    int32_t score;                      // 用户积分
    int32_t season;                     // 用户所处赛季
    int32_t successive_defeat;          // 用户连败场次
    int32_t max_rank;                   // 用户到达的当前赛季最大rank
    int32_t last_fight_stamp;           // 用户最近一次的战斗时间
};

struct temporary_match_result
{
    user_info_set win_result;
    user_info_set lose_result;
};

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;
class sc_rank_season_t
{
    /* rank_season */
public:
    sc_rank_season_t();
    void load_user(int32_t uid_, sp_user_t sp_user_);
    void get_rank(int32_t uid_, int32_t& rank_);
    int32_t find_user(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_, int32_t& month, int32_t& day, int32_t& hour);
    int32_t win_match(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_);
    int32_t lose_match(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_);
    void rank_reward(int32_t uid_, int32_t r_t, sp_user_t sp_user);
    void season_reward(int32_t uid_, int32_t r_t, sp_user_t sp_user);
    int32_t win_rank_match(int32_t uid_, sp_user_t sp_user_, user_info_set &user_info_);
    int32_t lose_rank_match(int32_t uid_, sp_user_t sp_user_, user_info_set &user_info_);
    int32_t cal_match_result(int32_t uid_);
private:
    void reset_user(user_info_set& user_, int new_season);
    void save_user(user_info_set& user_);
    int32_t get_cur_season();
    void get_cur_season_end_time(int32_t& month, int32_t& day, int32_t& hour);
    void check_active(user_info_set& user_);
    int32_t cal_win_result(int32_t uid_, user_info_set &win_result_);
    int32_t cal_lose_result(int32_t uid_, user_info_set &lose_result_);
private:
    unordered_map<int32_t, user_info_set> user_info_map;
    unordered_map<int32_t, temporary_match_result> match_result_map;
};
#define rank_season_s (singleton_t<sc_rank_season_t>::instance())
#endif
