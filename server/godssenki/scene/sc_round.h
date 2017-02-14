#ifndef _sc_round_h_
#define _sc_round_h_

#include <stdint.h>
#include "msg_def.h"

#include <set>
#include <map>
#include <ext/hash_map>
using namespace __gnu_cxx;
using namespace std;
    
class sc_user_t;
class sc_round_t
{
public:
    sc_round_t(sc_user_t &user_);
public:
    int32_t enter_round(int32_t resid_, int32_t flag_,int32_t uid_,int32_t pid_);
    int32_t exit_round(int32_t resid_, bool batt_win_, int32_t stars_, vector<sc_msg_def::jpk_round_monster_t>& killed_);
    bool is_user_in() { return m_cur_rid != 0; }
    int32_t flush_round(int32_t gid_);
    int32_t start_halt(int32_t resid_, int32_t times_);
    int32_t get_halt_result(int32_t resid_, int32_t flag_);
    int32_t start_zodiac_halt(int32_t gid_);
    int32_t get_zodiac_halt_result(int32_t gid_, int32_t flag_);
    int32_t stop_halt();
    void load_halt_info();
    void get_halt_info(int32_t &rid_, int32_t &stamp_, int32_t &times_, int32_t &flag_, int32_t &gid_);
    void clear_state();
    static void gen_drop_items(int rid_, int rflag_, vector<sc_msg_def::jpk_item_t>& drop_items_);
private:
    void gen_drop_items_i(vector<sc_msg_def::jpk_item_t>& drop_items_);
    void store_halt_info();
    int gen_rmb();
    static int32_t gen_array2_resid(vector<vector<int32_t>> &drop_);
private:
    sc_user_t&                          m_user;
    int32_t                             m_cur_rid;      //当前所在关卡
    int32_t                             m_cur_flag;     //当前所在关卡类型
    int32_t                             m_cur_uid;      //助战英雄
    int32_t                             m_cur_pid;      //助战英雄
    uint32_t                            m_in_stamp;     //挂机开始时间
    int32_t                             m_halt_times;   //普通关卡挂机剩余次数
    int32_t                             m_halt_sent;    //普通关卡挂机已发送次数
    int32_t                             m_halt_flag;    //挂机关卡类型
    int32_t                             m_halt_gid;     //黄道十二宫挂机组
    int32_t                             m_limit_round;  //限时副本次数
    int32_t                             m_limit_cooldown;//限时副本冷却时间
    sc_msg_def::ret_begin_round_t       m_ret;
};

struct sc_halt_t
{
    int32_t r_cur_rid; 
    int32_t r_cur_flag;
    int32_t r_in_stamp;
    int32_t r_halt_times;
    int32_t r_halt_sent;
    int32_t r_halt_flag;
    int32_t r_halt_gid;
    sc_halt_t(int32_t cur_rid_=0,int32_t cur_flag_=0,int32_t in_stamp_=0,int32_t halt_times_=0,int32_t halt_sent_=0,int32_t halt_flag_=0,int32_t halt_gid_=0):
        r_cur_rid(cur_rid_),
        r_cur_flag(cur_flag_),
        r_in_stamp(in_stamp_),
        r_halt_times(halt_times_),
        r_halt_sent(halt_sent_),
        r_halt_flag(halt_flag_),
        r_halt_gid(halt_gid_)
    {
    }
};

class sc_round_ctl_t
{
    friend class sc_round_t;
    //[uid] [gid] [rounds]
    typedef hash_map<int32_t, map<int32_t, set<int32_t> > > round_hm_t;
    typedef hash_map<int32_t, sc_halt_t> halt_hm_t;
    typedef hash_map<int32_t, map<int32_t, int32_t> > zodiac_hm_t;
    typedef hash_map<int32_t, int32_t> rmb_hm_t;
    typedef hash_map<int32_t, uint32_t> flush_hm_t;
private:
    //精英关卡,黄道十二宫已打关卡
    round_hm_t m_round_hm;
    //挂机信息
    halt_hm_t m_halt_hm;
    //黄道十二宫每组打过的最大关卡
    zodiac_hm_t m_zodiac_hm;
    rmb_hm_t m_rmb_hm;
    //刷新时间
    flush_hm_t m_flush_hm;
    uint32_t flush_sec;
private:
    void reset(int32_t uid_);
public:
    void get_pass_round(int32_t uid_, vector<int32_t> &ret);
    void get_zodiac(int32_t uid_, map<int32_t,int32_t> &ret);
    //获取该十二宫组未打过的关卡
    int32_t get_raw_zodiac(int32_t uid_, int32_t gid_, vector<int32_t> &rounds);
};
#define round_ctl (singleton_t<sc_round_ctl_t>::instance())

#endif
