#ifndef _sc_guidence_h_
#define _sc_guidence_h_

#include "singleton.h"
#include "repo_def.h"
#include "msg_def.h"

#include <vector>

using namespace std;

class sc_user_t;

enum evt_guidence_enum
{
    //伙伴加入
    evt_guidence_partner = 1,
    //起个名字
    evt_guidence_name = 2,
    //伙伴上场
    evt_guidence_team = 3,
    //强化装备
    evt_guidence_equip = 4,
    //第一次精英(替换为关卡掉落)
    evt_guidence_elite1 = 5,
    //升阶
    evt_guidence_uplevel = 6,
    //招募英雄
    evt_guidence_pub = 7,
    //第二次伙伴上场
    evt_guidence_team2 = 8,
    //每日任务
    evt_guidence_dailyquest = 9,
    //试炼
    evt_guidence_trial = 10,
    //洗礼
    evt_guidence_potential = 11,
    //第二次精英
    evt_guidence_elite2 = 12

};

class sc_guidence_t
{
public:
    //设置新手引导步骤
    void on_guidence_event(sc_user_t &user_, int evt_);
    //产生精英关卡掉落
    void gen_elite_drop(sc_user_t &user_,vector<sc_msg_def::jpk_item_t>& drop_items);
};

#define guidence_ins (singleton_t<sc_guidence_t>::instance()) 

#endif
