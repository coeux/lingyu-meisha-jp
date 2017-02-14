#ifndef _sc_guild_battle_h_
#define _sc_guild_battle_h_

#include "singleton.h"
#include "repo_def.h"
#include "db_ext.h"
#include "code_def.h"
#include "msg_def.h"

using namespace std;

struct guild_info
{
    int32_t guild_id;
    int32_t host;
    int32_t score;
    int32_t opponent;
    int32_t sign_time;
    bool in_cur_host;
};

struct building_info
{
    int32_t guild_id;
    int32_t building_id;
    int32_t level;
    int32_t state;          // 0: 未击溃  1: 击溃
};

struct fight_guild_info
{
    int32_t guild_id;
    string name;
    int32_t state;
    int32_t host;
    int32_t score;
    int32_t opponent;
    int32_t win;
    int32_t lose;
    int32_t total_score;
    int32_t is_win;
    int32_t add_score;
    int32_t sign_time;
};

struct fight_info
{
    int32_t stamp;
    string attack_name;
    string defence_name;
    int32_t win_count;
    int32_t state;
    int32_t attacker_uid;
    int32_t defencer_uid;
    int32_t ggid;
    int32_t building_id;
    int32_t position_id;
};

struct fight_state
{
    int32_t defence_uid;
    int32_t state;                      // 0: 隐藏 ; 1:可见 ; 2: 战斗中; 3: 击溃
    sc_msg_def::jpk_gbattle_target_t jpk_target;
    string view_data;
    int32_t anger_enemy;
    int32_t pid1;
    int32_t pid2;
    int32_t pid3;
    int32_t pid4;
    int32_t pid5;
    float hp1;
    float hp2;
    float hp3;
    float hp4;
    float hp5;
};

struct arrange_defence_info
{
    int32_t defence_uid;
    int32_t guild_id;
    int32_t building_id;
    int32_t position_id;
    int32_t pid[5];
    sc_msg_def::jpk_gbattle_target_t jpk_target;
    string view_data;
};

struct fight_defence_info
{
    int32_t defence_uid;
    int32_t guild_id;
    int32_t building_id;
    int32_t position_id;
    sc_msg_def::jpk_gbattle_target_t jpk_target;
    string view_data;
    int32_t state;
    int32_t anger_enemy;
};

struct fight_user_info
{
    int32_t uid;
    int32_t guild_id;
    int32_t score;
    int32_t add_score;
    int32_t last_fight_time;
    int32_t rest_times;
    int32_t have_buy_times;
    int32_t anger;
    int32_t win_count;
    int32_t defence_win;
    int32_t defence_lose;
    int32_t attack_win;
    int32_t attack_lose;
};

struct fight_user_abb_info
{
    int32_t pid;
    int32_t resid;
    int32_t level;
    int32_t starnum;
    int32_t equiplv;
    int32_t lovelevel;
    int32_t fp;
    int32_t viplevel;
};

struct fight_battle_log
{
    int32_t guild_id;
    int32_t building_id;
    int32_t position_id;
    string attack_name;
    string defence_name;
    int32_t attacker_uid;
    int32_t defencer_uid;
    int32_t stamp;
    int32_t win_count;
    int32_t win_side;
};

struct user_fight_info
{
    int32_t uid;
    int32_t score;
    int32_t last_fight_time;
    int32_t rest_times;
    int32_t have_buy_times;
    int32_t anger;
    int32_t win_count;
    int32_t ggid;
    int32_t attack_win;
    int32_t attack_lose;
    int32_t defence_win;
    int32_t defence_lose;
};

class sc_guild_battle_t
{
    /* guild battle */
public:
    sc_guild_battle_t();
    void load_db(vector<int32_t>& hostnums_);
    int32_t cur_season;
    int32_t cur_turn;
public:
    void update();
    void update_cur_season();
    void update_fights(int32_t cur_sec_);
    bool sign_up_time();
    int32_t get_state();
    void get_guild_fight_state_list(int32_t ggid_, map<int32_t, int32_t>& state_list_);
    int32_t get_pos_state(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t& state_);
    bool set_pos_state(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t state_);
    int32_t get_gbattle_cache(int32_t ggid_, int32_t building_id_, int32_t building_pos_, sc_msg_def::jpk_gbattle_target_t& gbattle_);
    int32_t get_guild_building_fight_info(int32_t ggid_, int32_t building_id_, map<int32_t, int32_t>& defence_state_, map<int32_t, sc_msg_def::jpk_gbattle_target_t>& defence_info_);
    void boardcast_fight_info(int32_t ggid_, sc_msg_def::nt_guild_boardcast_fight_info& nt_); // 广播
    void add_fighter(int32_t ggid_, int32_t uid_);
    int32_t get_guild_building_level_list(int32_t ggid_, map<int32_t, int32_t>& level_list_);
    void get_guild_building_level(int32_t ggid_, int32_t building_id_, int32_t& level_);
    void add_fight(int32_t ggid_, int32_t building_id_, int32_t building_pos_);
    void del_fight(int32_t ggid_, int32_t building_id_, int32_t building_pos_);
    void boardcast_fight_state(int32_t ggid_, sc_msg_def::nt_guild_boardcast_fight_state_switch& nt_);
    int32_t get_fight_view(int32_t ggid_, int32_t building_id_, int32_t building_pos_, string& view_data_, int32_t& anger_enemy_, int32_t& opponent_uid_);
    void set_enemy_anger(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t anger_);
    void set_enemy_hp(int32_t guild_id_, int32_t building_id_, int32_t position_id, float hp1_, float hp2_, float hp3_, float hp4_, float hp5_);
    void get_enemy_hp(int32_t guild_id_, int32_t building_id_, int32_t position_id, map<int32_t, sc_msg_def::jpk_card_event_partner_t>& team_);
    void set_building_state(int32_t ggid_, int32_t building_id_, int32_t state_);
    void add_fight_info(int32_t uid_, int32_t opponent_uid_, int32_t ggid_, int32_t state_, int32_t win_count_, int32_t building_id_, int32_t building_pos_);
    int32_t get_user_fight_info(int32_t uid_, fight_user_info& info_);
    int32_t user_fight(int32_t uid_);
    void add_fight_times(int32_t uid_);
    void save_user_anger(int32_t uid_, int32_t anger_);
    void clear_fight_cd(int32_t uid_);
    int32_t get_AllBattleLog(int32_t ggid_, sc_msg_def::ret_guild_battle_fight_record_info& ret_);
    int32_t get_battle_log_names(int32_t ggid_, string& mvp_, string& attacker_, string& defencer_);
    int32_t get_user_battle_log(int32_t ggid_, int32_t uid_, vector<sc_msg_def::fight_info_self>& info_);
    int32_t get_abb_info(int32_t uid_, sc_msg_def::jpk_arena_team_info_t& info_, int32_t& fp_, int32_t& viplevel_);
    int32_t get_opponent_guild_name(int32_t ggid_, string& opponent_name_);
    int32_t get_whole_guild_info(map<int32_t, sc_msg_def::guild_info>& info_list_);
    void add_guild_score(int32_t guild_id_, int32_t score_);
    void add_guild_score_e(int32_t guild_id_, int32_t score_);
    void add_user_score(int32_t uid_, int32_t score_);
    int32_t get_gfight_info_e(int32_t guild_id_, map<int32_t, sc_msg_def::gfight_info_t>& info_);
    int32_t get_gfight_info(int32_t guild_id_, map<int32_t, sc_msg_def::gfight_info_t>& info_);
    int32_t get_guild_name(int32_t guild_id_, string& name_);
    void get_guild_score(int32_t guild_id_, int32_t& score_);
    void get_opponent_guild_score(int32_t guild_id_, int32_t& score_);
    void save_user_info(int32_t uid_, string update_str);
    void user_attack_end(int32_t uid_, bool is_win_);
    void user_defence_end(int32_t uid_, bool is_win_);
    int32_t get_arrange_building_level(int32_t guild_id_, int32_t building_id_);
    void set_arrange_building_level(int32_t guild_id_, int32_t building_id_, int32_t level_);
    void save_guild_info(int32_t guild_id_);
    void save_guild_score(int32_t guild_id_);
    void get_arrange_uid(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t& uid_);
    void load_arrange_defence_info();        // 布阵期间获取当前布阵情况
    void load_arrange_building_info();      // 布阵期间获取当前建筑情况
    void save_arrange_defence_info(int32_t guild_id_, int32_t building_id, int32_t position_id_);
    void save_arrange_building_info(int32_t guild_id_, int32_t building_id_);
    int32_t get_arrange_building_defence_info(int32_t guild_id_, int32_t building_id_, map<int, sc_msg_def::jpk_gbattle_target_t>& defence_info_);
    int32_t get_arrange_defence_info(int32_t guild_id_, int32_t uid_, map<int32_t, int32_t>& building_state_, map<int32_t, sc_msg_def::jpk_team_t>& self_team_);
    bool is_user_more_than_3(int32_t guild_id_, int32_t uid_);
    bool is_partner_on(int32_t guild_id_, int32_t uid_, vector<int32_t>& team_info_);
    bool is_occupy(int32_t guild_id_, int32_t building_id_, int32_t position_id_);
    void occupy_pos(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t uid_, vector<int32_t>& team_info_, int32_t fp_);
    void arrange_add_user(int32_t guild_id_, int32_t uid_);
    bool is_this_user(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t uid_);
    void off_pos(int32_t guild_id_, int32_t building_id_, int32_t position_id_);
    void add_battle_log(int32_t ggid_, fight_info& info_);
    void update_fight_partner(int32_t uid_, map<int32_t, float>& partners_); // 更新战斗 partner成员
    int32_t get_fight_partner(int32_t uid_, map<int32_t, float>& partners_);    // 获取战斗 partner成员
    void update_guild_opponent_score(int32_t guild_id_);
    void update_guild_opponent_user_info(int32_t guild_id_);
private:
    void guild_match();                     // 公会匹配
    void position_adjust();                  // 上阵位置调整
    void building_level_adjust();           // 插入建筑等级空档
    void user_join_qualifications();        // 更新用户状态为1
    void load_fight_building_info();        // 获取战时建筑信息
    void fight_state_broadcast();           // 当前防守建筑中守方状态转换广播
    void reset_guild_info();                // 公会战结束后重置flag
    void init_fight_state();                // 公会战当天 初始化战斗状态
    void check_fight_states();              // 检测是否有建筑立面没有守卫，没有则填补
    void add_robot_fight(unordered_map<int32_t, unordered_map<int32_t, fight_state>>& guild_, int32_t building_id_, int32_t guild_id_);
    void add_robot();                       // 建筑中空闲的位置插入守卫
    void load_fight_user();                 // 战斗当天 获取用户状态
    void load_g_opponent();                 // 载入对手
    void send_reward();                     // 发放奖励
    void summary_turn();                    // 结算公会胜利
    void send_season_reward();              // 发放赛季奖励 
    void push_back_fight_info(int32_t ggid_, fight_info& info_);
    string get_name(int32_t uid_);
    void load_arrange_partner();            // 读取布阵 partner成员
    void save_arrange_partner(int32_t uid_, int32_t pid_[], bool is_save_);            // 操作布阵 partner成员
    void load_fight_partner();              // 读取战斗 partner成员
private:
    //void load_db_user();
    void load_guild_name();
    void load_guild_info();
    void get_cur_host_guilds(unordered_map<int32_t, int32_t>& guild_list_);
    void load_battle_log();
    void begin_battle();
    void pre_arrange();
    void in_arrange();
    void pre_fight();
    void in_fight();
    void after_fight();
private:
    /* state说明
     * 0 未响应时间段 包括活动前 活动间隙
     * 1 报名时间
     * 2 布阵时间
     * 3 战斗时间
     */
    int state_gb;

    bool battle_over;
    bool has_sign_up;
    bool during_arrange;
    bool has_arrange;
    bool during_fight;
    bool during_summary;
    // 报名需要
    // 布阵需要
    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t, arrange_defence_info>>> arrange_defence_info_list;
    unordered_map<int32_t, unordered_map<int32_t, building_info>> arrange_building_info_list;        // 布阵建筑信息
    unordered_map<int32_t, int32_t> arrange_user_list;
    unordered_map<int32_t, unordered_map<int32_t, int32_t>> arrange_partner_list;
    unordered_map<int32_t, unordered_map<int32_t, float>> fight_partner_list;
    // 战斗需要
    unordered_map<int32_t, unordered_map<int32_t, int32_t>> fight_guild_user_list;
    unordered_map<int32_t, unordered_map<int32_t, building_info>> fight_building_info_list;        // 战斗建筑信息
    unordered_map<int32_t, unordered_map<int32_t, int32_t>> guild_fighters;                         // 公会中战斗过的用户
    unordered_map<int32_t, fight_user_info> fight_user_info_list;

    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t, fight_state>>> fight_state_list;
    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t, fight_state>>> defence_state_list;
    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t, int32_t>>> fighting_list;
    unordered_map<int32_t, fight_user_abb_info> abb_user_info;
    vector<int32_t> hosts;
    unordered_map<int32_t, int32_t> g_opponent_list;
    unordered_map<int32_t, vector<fight_info>> fight_info_map;
    unordered_map<int32_t, string> name_map;
    unordered_map<int32_t, string> guild_name_list;
    unordered_map<int32_t, sc_msg_def::guild_info> guild_info_list;
    unordered_map<int32_t, fight_guild_info> fight_guild_info_list;
};

class sc_user_t;
class sc_guild_battle_user_t
{
    /* battle user */
public:
    sc_guild_battle_user_t(sc_user_t& user_);
public:
    void load_user_info();
    int32_t sign_up();
    int32_t get_defence_info(int32_t building_id_, sc_msg_def::ret_guild_battle_defence_info& ret_);
    int32_t get_whole_defence_info(sc_msg_def::ret_guild_battle_whole_defence_info& ret_);
    int32_t defence_pos_on(sc_msg_def::req_guild_battle_defence_pos_on& jpk_);
    int32_t defence_pos_off(sc_msg_def::req_guild_battle_defence_pos_off& jpk_);
    int32_t cancel_others_pos(sc_msg_def::req_guild_battle_cancel_other_pos& jpk_);
    int32_t building_level_up(int32_t building_id_, int32_t old_level_, int32_t& new_level_);
    int32_t get_whole_defence_info_fight(sc_msg_def::ret_guild_battle_whole_defence_info_fight& ret_);
    int32_t get_defence_info_fight(int32_t building_id_, sc_msg_def::ret_guild_battle_defence_info_fight& ret_);
    int32_t fight(int32_t building_id_, int32_t building_pos_, vector<int32_t>& partners_, sc_msg_def::ret_guild_battle_fight& ret_);
    int32_t fight_end(bool is_win_, int32_t anger_, int32_t anger_enemy_, vector<sc_msg_def::jpk_guild_battle_partner_t>& partners_, int32_t& cool_down_, sc_msg_def::req_guild_battle_fight_end& jpk_);
    int32_t cur_state(int32_t& g_state_, int32_t& gb_state_);
    int32_t buy_fight_times();
    int32_t clear_fight_cd();
    int32_t spy(int32_t building_id_, int32_t building_pos_);
    int32_t get_guild_fight_info(sc_msg_def::ret_guild_battle_fight_record_info& ret_);
    int32_t get_guild_battle_info(sc_msg_def::ret_guild_battle_fight_info& ret_);
    int32_t get_guild_info(sc_msg_def::ret_guild_battle_guild_info& ret_);
private:
    sc_user_t& m_user;
    int32_t cur_fight_building_id;
    int32_t cur_fight_building_pos;
    int32_t cur_fight_opponent;
    int32_t win_count;
};
#define guild_battle_s (singleton_t<sc_guild_battle_t>::instance())
#endif
