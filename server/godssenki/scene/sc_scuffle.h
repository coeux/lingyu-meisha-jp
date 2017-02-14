#ifndef _sc_scuffle_h_
#define _sc_scuffle_h_

#include <boost/shared_ptr.hpp> 
#include <boost/noncopyable.hpp>

#include <unordered_map>
#include <map>
#include <vector>
#include <set>
#include <list>

#include "msg_def.h"

using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_scuffle_mgr_t;
class sc_scuffle_t;

class sc_scuffle_hero_t
{
    friend class sc_scuffle_t;
    friend class sc_scuffle_mgr_t;
public:
    sc_scuffle_hero_t(int32_t uid_,int32_t resid_,const string &nickname_,int32_t lv_, int32_t viplevel_, sc_scuffle_t &scuffle_);
    bool is_fullwatch();
    void watch_eachother(int32_t uid_);
    void unwatch_eachother(int32_t uid_);
    void leave(int32_t active_=1);
    void sync_pos(int32_t x_,int32_t y_);
    void rush_into(int32_t x_, int32_t y_);
    void unicast_state();

    int32_t uid;
    int32_t resid;
    string nickname;
    int32_t lv;
    int32_t old_scene;
    int32_t viplevel;

    int32_t last_in;
    uint32_t quit_stmp;
    int32_t in_scuffle;
    int32_t in_battle;
    int32_t n_victory;
    int32_t n_con_victory;
    int32_t n_fail;
    int32_t score;
    int32_t morale;
    uint32_t update_stamp;
    int32_t last_fight_time;
    int32_t last_beat_time;
    boost::shared_ptr<sc_scuffle_hero_t> last_fight_user;
    int32_t last_con_win;
    int32_t enter_times;
    
    int32_t x;
    int32_t y;
    uint32_t watch_max;
    float   hp_percent;
    unordered_map<int32_t, int32_t> watch;
    sc_scuffle_t    &scuffle;
};
typedef boost::shared_ptr<sc_scuffle_hero_t> sp_hero_t;

class sc_scuffle_t
{
    friend class sc_scuffle_mgr_t;
    friend class sc_scuffle_hero_t;
    typedef unordered_map<int32_t,sp_hero_t> m_hero_hm_t;
private:
    sc_scuffle_t(int32_t key_);
    void update(sp_hero_t hero_);
    sp_hero_t get_hero(int32_t uid_);
    void update_top(sp_hero_t hero_);
    void req_score_rank(int32_t uid_);
    void rank_reward();
    void rank_last(int32_t uid_);
    void rank_score();
    void unicast_top10();
    bool remain_one_fighter();
    void remain_one_end();
    void clear_rest();
    int32_t cal_battlexp(int32_t grade_,int32_t score_);
private:
    int32_t        key;
    m_hero_hm_t     m_hero_hm;
    list<int32_t>   users;
    vector<sc_msg_def::jpk_hero_info_t> top;
    int32_t        m_prepare_tm;
    int32_t        top_cut;
    int32_t        m_open;
};
typedef boost::shared_ptr<sc_scuffle_t> sp_scuffle_t;

class sc_scuffle_mgr_t
{
    typedef map<int32_t, sp_scuffle_t> m_scuffle_hm_t;
public:
    sc_scuffle_mgr_t();
    int prepare(sp_user_t user_);
    int32_t sign_up(sp_user_t user_);       // 乱斗场报名
    void arrange_region();
    void update();
    void update_fights(int32_t cur);
    void move(sc_msg_def::nt_move_t &jpk_,int32_t uid_);
    void exit_scuffle(sp_user_t user_);
    void enter_scuffle(sp_user_t user_, int32_t show_player_num_);
    //void login_enter_scuffle(sp_user_t user_, int32_t show_player_num_);
    //void on_loginoff(sp_user_t user_);
    void enter_battle(sp_user_t user_,int32_t uid_);
    void exit_battle(sp_user_t user_, sc_msg_def::req_scuffle_battle_end_t& jpk_);
    void get_rank(int32_t uid_);
    int32_t req_scuffle_state(sp_user_t user_, int32_t& state_, int32_t& user_state_, int32_t& remain_time_);
    void get_reward();
    int fuhuo(sp_user_t user_);
    int32_t is_close_stage();
    bool is_sign_up_time();
    bool is_fight_time();
    sp_hero_t get_hero(int uid_);
private:
    int32_t get_key(int32_t uid_);
    int32_t is_prepare_stage();
    int32_t is_enter_stage();
    int32_t is_balance_stage();
    void clear(sp_scuffle_t sp_scuf);
    int32_t cal_point(bool is_win_, int32_t con_win_, int32_t e_con_win_);
private:
    int32_t m_start;
    int32_t m_end;
    int32_t m_prepare;
    int32_t m_access;
    bool can_arrange;
    unordered_map<int32_t, int32_t> user_region_list;
    unordered_map<int32_t, sp_user_t> sign_up_list;
    unordered_map<int32_t, unordered_map<int32_t, float>> partner_hp_map;
    
    m_scuffle_hm_t        m_scuffle_hm;
};
#define scuffle_mgr (singleton_t<sc_scuffle_mgr_t>::instance())

#endif
