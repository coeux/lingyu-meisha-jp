#ifndef SC_LIMIT_ROUND
#define SC_LIMIT_ROUND

#include <map>
#include "sc_user.h"
#include "msg_def.h"


class sc_limit_user_data
{
public:
    int m_user_last_reset_time;
    int m_user_whole_time_stamp;
    int m_fight_start_time_stamp;
    int coin;
    int exp;
    int power;
    int lovevalue;
    vector<sc_msg_def::jpk_item_t> drop_items;
    vector<int>  partners;
};


class sc_limit_round_mgr_t
{
private:
    std::map<int, sc_limit_user_data*>    m_user_data;
    std::map<int, int>                    m_user_last_reward;
    uint32_t                              gen_time;
    vector<int32_t>                       m_limit_open_round;
    string                                m_salt;
private:
    void gen_limit_round();
public:
    sc_limit_round_mgr_t();
    ~sc_limit_round_mgr_t();

    //初始化数据
    void init_round_mgr_data();

    //玩家登录时初始化数据
    void req_user_login_data(int uid_, sc_user_t &user_, sc_msg_def::ret_user_data_t &user_data_);
    //获得数据
    void get_user_round_data(int uid_,sc_user_t &user_, sc_msg_def::jpk_round_data_t &round_data);
    //请求数据
    void req_user_round_data(int uid_,sc_user_t &user_, sc_msg_def::ret_limit_round_data &limit_user_data);

    //重置属性试炼次数
    int32_t req_reset_limit_round_times(int uid_,sc_user_t &user_,sc_msg_def::ret_reset_limit_round_times &ret_);

    //玩家请求打某个关卡
    void user_round_battle(int uid_, int roundid, vector<int>& partners, sp_user_t &user);

    //玩家请求清除战斗CD
    void clear_fight_cd(int32_t uid_, sp_user_t user_);

    //玩家打完关卡请求结果
    void user_round_battle_res(int uid_, int res, int roundid, sp_user_t &user, string salt_);

    //vip升级调整重置次数
    void update_reset_times(int32_t uid_, int32_t viplevel_);
    //
    void update();
};


#define sc_limit_round_mgr (singleton_t<sc_limit_round_mgr_t>::instance())

#endif
