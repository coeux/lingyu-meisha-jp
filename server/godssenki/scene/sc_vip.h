#ifndef _sc_vip_h_
#define _sc_vip_h_

#include <stdint.h>
#include <singleton.h>
#include <unordered_map>
#include <vector>
#include <db_def.h>
using namespace std;

#include <boost/shared_ptr.hpp>

enum vip_do_e
{
    vop_buy_power = 1,      //购买体力
    vop_do_halt,            //开启挂机
    vop_buy_halt_time,      //购买挂机时间
    vop_acc_fight_speed,    //加速战斗
    vop_reste_adv_round,    //重置精英关卡
    vop_buy_bag_num,        //购买背包容量
    vop_do_trial_pos3,      //训练位置3
    vop_acc_trial,          //加速训练
    vop_buy_fight_count,    //购买竞技场次数
    vop_buy_trial_energy,   //购买活力

    vop_do_vp_trial = 11,   //王者训练
    vop_reset_zodiac,       //重置12宫
    vop_rune_cost,          //符文召唤高级小怪
    vop_given_power,        //每日体力赠送
    vop_do_buy_money,       //炼金
    vop_flash_pub,          //酒馆刷新
    vop_flash_vp_pub,       //酒馆至尊刷新
    vop_reset_daily_task,   //重置日常任务
    vop_pay_gm,             //公会捐献水晶
    vop_immedia_fight_wboss,//被世界boss击杀后，立刻复活

    vop_add_bag_max = 21,   //增加背包上限100
    vop_flush_star,         //水晶刷新星魂
    vop_flush_targets,      //试炼场刷新对手
    vop_clear_pass_round,   //普通关卡清除cd
    vop_equip_compose_buy,  //升阶材料购买
    vop_flush_cave,         //刷新英雄迷窟
    vop_buy_golden_box,     //购买黄金宝箱
    vop_buy_silver_box,     //购买白银宝箱

    vop_num,
};

class sc_user_t;

class sc_vip_t
{
public:
    sc_vip_t(sc_user_t& user_);
    ~sc_vip_t();

    void init_db();
    void load_db();
    void on_login();
    //flag:vip_do_e
    bool enable_do(int flag_);
    //flag:vip_donum_e
    int get_num(int flag_);
    //得到剩余的购买次数
    int get_num_count(int flag_);
    int get_num_used(int flag_);
    void compensate_vip(int viplevel_);
    int on_exp_change(int exp_,int slience_=0);
    //flag:vip_do_e
    int need_yb(int flag_, int cd_);
    int buy_vip(int flag_, int cd_=0);
    //更新vip操作记录数
    int update_vip_recordn(int flag_, int recordn_);
    void update_num(int flag_);
private:
    sc_user_t&      m_user;
    db_Vip_t        m_record[vop_num];
};

#endif
