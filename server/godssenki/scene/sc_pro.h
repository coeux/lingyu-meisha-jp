#ifndef _sc_pro_h_
#define _sc_pro_h_

#include <stdint.h>
using namespace std;

#include "msg_def.h"

//#define N_BASE_PRO 10

class sc_user_t;

class sc_pro_t
{
private:
    // 0 物攻
    // 1 魔攻
    // 2 物防
    // 3 魔防
    // 4 生命
    // 5 暴击
    // 6 命中
    // 7 回避
    // 8 战力
    // 9 怒气
    // 10 韧性
    // 11 免伤比
    // 21 无抗
    // 22 风抗
    // 23 火抗
    // 24 水抗
    // 25 土炕
    // 26 无伤
    // 27 风伤
    // 28 火伤
    // 29 水伤
    // 30 雷伤
    enum 
    {
        atk         = 0,
        mgc         = 1,
        def         = 2,
        res         = 3,
        hp          = 4,
        cri         = 5,
        acc         = 6,
        dodge       = 7,
        fp          = 8,
        power       = 9,
        ten         = 10,
        imm_dam_pro = 11,
        move_speed  = 12,
        phy_att_fac = 13,
        mag_att_fac = 14,
        phy_def_fac = 15,
        mag_def_fac = 16,
        cha_fac     = 17,
        atk_power   = 18,
        hit_power   = 19,
        kill_power = 20,
        p0_d        = 21,
        p1_d        = 22,
        p2_d        = 23,
        p3_d        = 24,
        p4_d        = 25,
        p0_a        = 26,
        p1_a        = 27,
        p2_a        = 28,
        p3_a        = 29,
        p4_a        = 30,

        BASE_PRO_COUNT,
    };
public:
    sc_pro_t(sc_user_t &user_);
    int cal_pro(int32_t pid_ = 0, int32_t pos_ = -1, float num = 1);
    void copy(sc_msg_def::jpk_role_pro_t& jpk_);
    void copy(vector<float> &pro);
    //战力
    int32_t cal_fight_point(int32_t pid_, int32_t rolelv_);
    int get_fp() { return m_base_pro[fp]; }
private:
    float m_base_pro[BASE_PRO_COUNT];
    sc_user_t &m_user;
};

#endif
