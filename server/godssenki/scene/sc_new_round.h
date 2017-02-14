#ifndef _sc_new_round_h_
#define _sc_new_round_h_

#include <stdint.h>
#include "msg_def.h"
#include "db_def.h"
#include "db_ext.h"
#include "sc_arena.h"

#include <set>
#include <map>
#include <ext/hash_map>
using namespace __gnu_cxx;
using namespace std;
    
class sc_user_t;
class sc_new_round_t
{
public:
    sc_new_round_t(sc_user_t &user_);
public:
    void flush_round(int32_t gid_);
    //普通关卡
    void enter_round(int32_t resid_,int32_t uid_,int32_t pid_);
    void exit_round(sc_msg_def::req_round_exit_t &req_ );
    void pass_round(sc_msg_def::req_round_pass_t &req_);
    void pass_round_new(sc_msg_def::req_round_pass_new_t &req_ );
    void reset_elite(sc_msg_def::req_reset_elite_t &req_);
    int32_t get_left_secs();
	int32_t get_cave_left_secs();	//lewton
    void clear_pass_round_cd();
    //精英关卡
    void enter_elite(int32_t resid_);
    void exit_elite(sc_msg_def::req_elite_exit_t &req_);
    //十二宫
    void enter_zodiac(int32_t resid_,int32_t uid_,int32_t pid_);
    void exit_zodiac(sc_msg_def::req_zodiac_exit_t &req_);
    //英雄迷窟
    void enter_cave(int32_t resid_, int32_t uid_, int32_t pid_);
    void exit_cave( sc_msg_def::req_cave_exit_t &req_ );
    void pass_cave( sc_msg_def::req_cave_pass_t &req_ );
    void flush_cave( int32_t resid_ );
    void clear_pass_cave_cd();
    void refrsh_daily_data();
    int32_t get_round_total_stars();
    void update_round_stars_reward();
    void get_first_pass_elite_round_reward(int32_t resid_);
private:
    void clear_state();
    static int gen_rmb(int uid_);
    //区分是谁的掉落 第一位 普通副本掉率 第二位 普通副本掉落数量 第三位 精英副本掉落几率 第四位 精英副本掉落数量
    static void gen_drop_items(int rid_, vector<sc_msg_def::jpk_item_t>& drop_items_ ,int32_t flag = 0);
    void gen_drop_chips(int32_t resid_,vector<sc_msg_def::jpk_item_t> &drop_items_);
    void gen_drop_items_i(int32_t rid_,vector<sc_msg_def::jpk_item_t>& drop_items_  ,int32_t flag = 0);
    void gen_zodiac_drop_items_i(int32_t rid_,vector<sc_msg_def::jpk_item_t>& drop_items_); //增加标识符 0为未知副本 1 为普通 2 为精英
    static int32_t gen_array2_resid(vector<vector<int32_t>> &drop_);
    int32_t is_last_round(int32_t resid_);
private:
    sc_user_t&                          m_user;
    int32_t                             m_cur_rid;      //当前所在关卡
    int32_t                             m_cur_uid;      //助战英雄
    int32_t                             m_cur_pid;      //助战英雄
    sc_msg_def::ret_round_enter_t       m_ret;
    sc_msg_def::ret_cave_enter_t        m_cave_ret;
    string                              m_salt;         //校验码
    int                                 m_fight_time;   //校验时间
    uint32_t                            m_first_login_stamp;
    unordered_map<char, int>            c2i_map;
};

typedef boost::shared_ptr<sc_msg_def::sc_cave_t> sp_cave_t;

struct sc_zodiac_t
{
    //血量百分比
    float           hp_percent;
    //手滑能量
    int             fpower;
    //怒气值
    map<int, int>   angers;
};

class sc_user_t;
class sc_round_cache_t
{
    friend class sc_user_t;
    friend class sc_new_round_t;
    //[uid] [gid] [rounds]
    typedef hash_map<int32_t, map<int32_t, set<int32_t> > > round_hm_t;
    //typedef hash_map<int32_t, map<int32_t, int32_t> > zodiac_hm_t;
    typedef hash_map<int32_t, int32_t> rmb_hm_t;
    typedef hash_map<int32_t, uint32_t> flush_hm_t;
    //[uid] [resid] [cave_data]
    typedef hash_map<int32_t, hash_map<int32_t,sp_cave_t> > cave_hm_t;
    //[uid][zodica_id][info]
    typedef hash_map<int32_t,sc_zodiac_t> zodiac_hm_t;
private:
    //精英关卡已打关卡
    round_hm_t m_round_hm;
    //黄道十二宫每组打过的最大关卡
    zodiac_hm_t m_zodiac_hm;
    //玩家当日获得的免费水晶
    rmb_hm_t m_rmb_hm;
    //刷新时间
    flush_hm_t m_flush_hm;
    //最后一次挂机时间
    flush_hm_t m_pass_round_hm;
    //免费刷新十二宫
    rmb_hm_t m_free_zodiac_hm;
    //免费刷新精英
    rmb_hm_t m_free_elite_hm;
    //当天打过的英雄迷窟情况
    cave_hm_t m_cave_hm;
	//英雄迷窟的最后一次挂机时间
	flush_hm_t m_cave_pass_round_hm;	//<uid,time>,time->上一次刷新迷窟的时间
private:
    void reset(int32_t uid_);
public:
    void get_pass_round(int32_t uid_, vector<int32_t> &ret);
    int32_t get_cave_flush_count(int32_t uid_,int32_t resid_);
    void get_zodiac(int32_t uid_,map<int32_t,int32_t> &ret,map<int32_t,sc_msg_def::sc_cave_t> &cave_);
    void get_free_flush(sc_user_t &user_,int32_t uid_,int32_t &elite_,int32_t &zodiac);
};
#define round_cache (singleton_t<sc_round_cache_t>::instance())

class sc_expedition_t
{
    typedef db_Expedition_ext_t expedition_t;
    typedef boost::shared_ptr<expedition_t> sp_expedition_t;
    typedef unordered_map<int32_t, sp_expedition_t> sp_expedition_hm_t;
public:
    sc_expedition_t(sc_user_t& user_);
    void load_db();
    void save_db(sp_expedition_t& sp_expedition_);
    int32_t get_expedition_data(sc_msg_def::ret_expedition_t& ret);
    int32_t get_expedition_round(sc_msg_def::ret_expedition_round_t& ret);
    int32_t enter_expedition(int32_t resid_, sc_msg_def::ret_enter_expedition_round_t &ret);
    int32_t exit_expedition(const sc_msg_def::req_exit_expedition_round_t &jpk_);
    void pass_expedition();
    int32_t get_reward(int32_t resid_, sc_msg_def::ret_expedition_round_reward_t &ret, bool isDouble = false);
    int32_t reset(sc_msg_def::req_expedition_reset_t &jpk_, sc_msg_def::ret_expedition_reset_t &ret);
    int32_t get_cur_round();
    int32_t get_max_round();
    int32_t get_reset_num(); //远征重置次数
    void get_gang_name(int32_t uid, string &gangname);
private:
    //void get_equip_level(int32_t uid, int32_t pid, int32_t &equiplv); 
    void get_starnum(int32_t uid, int32_t pid, int32_t &rank);
    void check24();
    int32_t send_reward(int32_t resid_, int32_t type, sc_msg_def::ret_expedition_round_reward_t &ret , bool isDouble = false);
    void reset_round_data(int32_t refresh_times_);
    void update_expedition_round(int32_t resid_, int32_t *pid_, string view_, int32_t refresh_times_);
    void fill_round(int32_t index_, int32_t refresh_times_);
    void add_hp(sp_fight_view_user_t view);
    void set_last_max_round(int32_t round_);
private:
    sc_user_t& m_user;
    sp_expedition_hm_t m_expedition_hm;
    int32_t m_cur_round;
    int32_t m_cur_max_round;
    int32_t m_last_max_round;
    uint32_t m_utime;
    int32_t m_is_refresh_today;
    bool m_is_pass_all_round;
    bool m_set_last;
    bool m_can_sweep;
    string m_salt;
    int m_fight_time;
};

#endif
