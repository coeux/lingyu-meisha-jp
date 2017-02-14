#ifndef _sc_soul_h_
#define _sc_soul_h_

#include "db_ext.h"
#include "msg_def.h"

using namespace std;

class sc_user_t;
class sc_soul_t
{
public:
    db_Soul_ext_t db;
    /* soul */
public:
    sc_soul_t(sc_user_t& user_);
    void save_db();
    void load_db();
    void init_new_user();
    // 获得晶魂信息
    int32_t get_info(sc_msg_def::ret_get_soul_info_t& ret_);
    // 开始猎魂
    int32_t hunt(sc_msg_def::ret_hunt_soul_t& ret_);
    //是否有对应材料
    bool get_cost_item_count(int32_t soullv_);
    //消耗猎魂材料
    int32_t use_soul_item(int32_t soullv_);
    // 加持器魂
    int32_t rankup(sc_msg_def::ret_rankup_soul_t& ret_);
    // 获得奖励
    int32_t get_reward(sc_msg_def::ret_get_soul_reward_t& ret_ , bool isDouble = false); 
public:
    static void clear_scroll();
private:
    sc_user_t& m_user;
};

#endif
