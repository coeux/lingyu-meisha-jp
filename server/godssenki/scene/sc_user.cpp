#include "sc_user.h"
#include "sc_service.h"
#include "sc_logic.h"
#include "sc_gang.h"
#include "sc_server.h"
#include "sc_arena_page_cache.h"
#include "sc_statics.h"
#include "sc_boss.h"
#include "sc_cache.h"
#include "sc_guidence.h"
#include "sc_arena_rank.h"
#include "sc_message.h"
#include "sc_fp_rank.h"
#include "sc_lv_rank.h"
#include "sc_mailinfo.h"
#include "sc_pub.h"
#include "sc_activity.h"
#include "sc_limit_round.h"
#include "sc_scuffle.h"
#include "sc_rank.h"
#include "sc_card_event.h"
#include "sc_rank_season.h"


#include "remote_info.h"
#include "log.h"
#include "repo_def.h"
#include "code_def.h"
#include "performance_service.h"
#include "random.h"
#include "date_helper.h"
#include "config.h"
#include <math.h>
#include <ctime>
#include <stdio.h>
#include <stdlib.h>

#define LOG "SC_USER"

#define SECONDS_PER_EXP 300

#define SECONDS_PER_POW 300
#define POWER_PER_GEN 1
#define POWER_UPLIMIT 120
#define CHRONICLE_SUM_UPLIMIT 9999
#define MAIN_HERO_SKIN 9999

#define ENERGY_PER_GEN 1
#define SECONDS_PER_ENERGY 1800
#define ENERGY_UPLIMIT 20

#define RESID_POTENTIAL_DRAG 15001
#define RESID_SUPER_POTENTIAL_DRAG 15002
#define MAX_GRADE 80

#define IVT_LV1 20
#define IVT_LV2 30
#define IVT_LV3 40
#define IVT_LV4 50
#define IVT_LV5 60
// sc_love_task.cpp 也有
#define MAX_LOVE_LEVEL 4

sc_user_t::sc_user_t():
    bag(*this),
    skill_mgr(*this),
    equip_mgr(*this),
    partner_mgr(*this),
    item_mgr(*this),
    friend_mgr(*this),
    friend_flower_mgr(*this),
    //rune_mgr(*this),
    new_rune_mgr(*this),
    round(*this),
    new_round(*this),
    expedition(*this),
    arena(*this),
    practice(*this),
    task(*this),
    daily_task(*this),
    achievement(*this),
    vip(*this),
    reward(*this),
    treasure(*this),
    star_mgr(*this),
    shop(*this),
    expeditionshop_mgr(*this),
    gangshop_mgr(*this),
    runeshop_mgr(*this),
    cardeventshop_mgr(*this),
    lmtshop_mgr(*this),
    prestigeshop(*this),
    chipshop(*this),
    plantshop(*this),
    inventoryshop(*this),
    chipsmash(*this),
    gmail(*this),
    wing(*this),
    chronicle(*this),
    love_task(*this),
    sign_daily(*this),
    card_event(*this),
    pro(*this),
    team_mgr(*this),
    soul(*this),
    soulrank_mgr(*this),
    guild_battle_mgr(*this),
    gem_page_mgr(*this),
    pet_mgr(*this),
    combo_pro_mgr(*this),
    report_mgr(*this),
    pub_mgr(*this),
    //homebuilding(*this),
    last_gen_energy(0),
    login_time(0),
    counttime(0),
    is_overdue(false),
    current_step(0),
    lastsceneid(0),
    city_boss_id(0),
    pay_rmb(0),
    notalk(false)
{
}
void sc_user_t::compensate_grade(int32_t grade_, int test_/*= 1*/)
{
    repo_def::levelup_t* rp_lvup = NULL;
    rp_lvup = repo_mgr.levelup.get(grade_+1);
    if( rp_lvup == NULL )
        return;

    //从cache中清除玩家
    grade_user_cache.remove_user(db.uid,db.grade);

    db.set_exp( rp_lvup->exp - 1 );
    db.set_grade(grade_);
    save_db();

    if (test_ == 1)
        return;

    //通知角色属性改变
    on_pro_changed(0);

    //通知主角等级改变
    sc_msg_def::nt_levelup_t nt;
    reward.refresh_growing_reward_status(nt.growing_reward);
    nt.pid = 0;
    nt.level = db.grade;
    logic.unicast(db.uid, nt);

    /*
    //记录事件
    statics_ins.unicast_eventlog(*user,nt.cmd(),nt.pid,old,0,nt.level);
    */

    //恢复体力
    //on_power_change(rp_lvup->energy);

    //再放进去
    //从cache中清除玩家
    grade_user_cache.remove_user(db.uid,db.grade);

    sp_user_t user;
    if( logic.usermgr().get(db.uid,user) )
    {
        grade_user_cache.put_user(user);
    }

    //更改Server表的最高玩家等级字段
    if( server.db.maxlv < db.grade )
    {
        //世界boss 两级开放
        if( (server.db.maxlv<2)&&(db.grade>=2) )
            server.db.set_wbcut( date_helper.cur_sec() );
        server.db.set_maxlv(db.grade);
        server.save_db();
    }

    activity.on_upgrade(db.uid, db.grade); 
    arena_page_cache.on_level_up(db.uid);
    gang_mgr.on_level_up(db.uid);
}

void sc_user_t::on_lovevalue_change(int32_t lovevalue)
{
    auto love_info = repo_mgr.love_task.get(db.resid * 100 + db.lovelevel + 1);
    if (love_info != NULL)
    {
        if( db.lovevalue + lovevalue >= love_info->love_max)
        {
            db.lovevalue = love_info->love_max;
            db.set_lovevalue(db.lovevalue);
        }
        else
        {
            db.lovevalue = db.lovevalue + lovevalue;
            db.set_lovevalue(db.lovevalue);
        }
    }
    for (int32_t i = 0; i < TEAM_BATTLE_SIZE; i++)
    {
        if(team_mgr[i] <= 0)
            continue;
        sp_partner_t partner = partner_mgr.get(team_mgr[i]);
        if (partner == NULL)
            continue;
        partner->on_lovevalue_change(lovevalue);
        partner->save_db();
    }
            
}

int sc_user_t::on_exp_change(int32_t exp_)
{
    /*
    //玩家在227任务完成之前，等级不能超过15级
    if( (db.questid<227) && ((db.exp+exp_)>=4170) )
        return 0;
    */

    int grade = db.grade;
    repo_def::levelup_t* rp_lvup = NULL;
    if ( grade < MAX_GRADE )
    {
        while((rp_lvup = repo_mgr.levelup.get(grade))!=NULL)
        {
            if ((db.exp+exp_) < rp_lvup->exp)
            {
                break;
            }

            grade++;

            //设置该玩家的邀请者的标志位
            if((reward.get_inviter()!=0)&&((grade==27)||(grade==33)||(grade==40)||(grade==50)))
                reward.invitee_upgrade(grade);
        }
    }

    db.set_exp(db.exp + exp_);
    if( rp_lvup == NULL )
    {
        rp_lvup = repo_mgr.levelup.get(grade);
    }

    sc_msg_def::nt_exp_change_t nt;
    nt.pid = 0;
    nt.now = db.exp;
    logic.unicast(db.uid, nt);
    
    if (db.grade >= grade)
    {
        //保存伙伴经验
        for(int32_t i=0; i<TEAM_BATTLE_SIZE; i++)
        {
            if (team_mgr[i] <= 0)
                continue;
            sp_partner_t partner = partner_mgr.get(team_mgr[i]);
            if (partner == NULL) 
                continue;
            partner->on_exp_change(exp_);
            partner->save_db();
        }
        return db.grade;
    }

    //升级!!!
    {
        //从cache中清除玩家
        grade_user_cache.remove_user(db.uid,db.grade);

        int32_t old = db.grade;
        db.set_grade(grade);

        //恢复体力
        on_power_change(rp_lvup->energy);

        //再放进去
        sp_user_t user;
        if( logic.usermgr().get(db.uid,user) )
        {
            grade_user_cache.put_user(user);
        }

        //更改Server表的最高玩家等级字段
        if( server.db.maxlv < db.grade )
        {
            //世界boss 两级开放
            if( (server.db.maxlv<2)&&(db.grade>=2) )
                server.db.set_wbcut( date_helper.cur_sec() );
            server.db.set_maxlv(db.grade);
            server.save_db();
        }

        //设置公会用户等级
        sp_gang_t sp_gang; 
        sp_ganguser_t sp_guser; 
        if (gang_mgr.get_gang_by_uid(db.uid, sp_gang, sp_guser))
        {
            sp_gang->on_upgrade(db.uid, db.grade);
        }

        activity.on_upgrade(db.uid, db.grade); 

        //记录事件
        statics_ins.unicast_eventlog(*this,nt.cmd(),nt.pid,old,0,db.grade);
    }

    //通知角色属性改变
    on_pro_changed(0);

    //通知主角等级改变
    {
        sc_msg_def::nt_levelup_t nt;
        reward.refresh_growing_reward_status(nt.growing_reward);
        nt.pid = 0;
        nt.level = db.grade;

        logic.unicast(db.uid, nt);
    }

    //保存伙伴经验
    for(int32_t i=0; i<TEAM_BATTLE_SIZE; i++)
    {
        if (team_mgr[i] <= 0)
            continue;
        sp_partner_t partner = partner_mgr.get(team_mgr[i]);
        if (partner == NULL) 
            continue;
        partner->on_exp_change(exp_);
        partner->save_db();
    }

    arena_page_cache.on_level_up(db.uid);
    gang_mgr.on_level_up(db.uid);

    
    if(db.grade == 17)
    {
        add_new_mail();
    }

    return db.grade;
}
int sc_user_t::on_money_change(int32_t money_)
{
    int32_t old = db.gold;
    if( money_ == 0 )
        return db.gold;

    db.set_gold(db.gold + money_);
    if (db.gold < 0)
        db.set_gold(0);

    sc_msg_def::nt_money_change_t  nt;
    nt.now = db.gold;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.gold;
}
int sc_user_t::on_expeditioncoin_change(int32_t expeditioncoin_)
{
    if (expeditioncoin_ == 0)
        return db.expeditioncoin;
    db.set_expeditioncoin(db.expeditioncoin + expeditioncoin_);
    if (db.expeditioncoin < 0)
        db.set_expeditioncoin(0);
    sc_msg_def::nt_expeditioncoin_t nt;
    nt.now = db.expeditioncoin;
    logic.unicast(db.uid, nt);
    return db.expeditioncoin;
}
int sc_user_t::on_runechip_change(int32_t runechip_)
{
    int32_t old = db.runechip;

    db.set_runechip(db.runechip + runechip_);
    sc_msg_def::nt_runechip_change_t  nt;
    nt.now = db.runechip ;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.runechip;
}
int sc_user_t::on_freeyb_change(int32_t yb_)
{
    if( 0 == yb_ )
        return db.freeyb;

    //int32_t old = db.payyb + db.freeyb;

    db.set_freeyb(db.freeyb + yb_);
    if (db.freeyb < 0)
        db.set_freeyb(0);

    sc_msg_def::nt_yb_change_t nt;
    nt.now = db.freeyb+db.payyb;
    logic.unicast(db.uid, nt);
    
    //记录事件
    //statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);
    statics_ins.unicast_freeyblog(*this,yb_);
    if( yb_ > 0 ){
    }else
    {
        reward.db.set_cumu_yb_exp( reward.db.cumu_yb_exp-yb_);
        activity.on_cumu_yb(db.uid, -yb_);
        reward.save_db();
    }

    return db.freeyb;
}
int sc_user_t::on_payyb_change(int32_t yb_)
{
    if( 0 == yb_ )
        return db.payyb;

    int32_t old = db.payyb + db.freeyb;

    db.set_payyb(db.payyb + yb_);
    if (db.payyb < 0)
        db.set_payyb(0);

    sc_msg_def::nt_yb_change_t nt;
    nt.now = db.payyb+db.freeyb;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    if( yb_<0 )
    {
        reward.db.set_cumu_yb_exp( reward.db.cumu_yb_exp-yb_);
        activity.on_cumu_yb(db.uid, -yb_);
        reward.save_db();
    }
    return db.payyb;
}
void sc_user_t::on_payed(int rmb_)
{
    //每日充值活动
    reward.update_sevenpayreward();
    reward.update_limit_sevenpay();
    if (date_helper.offday(reward.db.daily_pay_stamp)>=1)
    {
        reward.db.set_daily_pay(rmb_);
        reward.db.set_daily_pay_reward(0);
    }
    else
    {
        reward.db.set_daily_pay(reward.db.daily_pay+rmb_);
    }
    reward.db.set_daily_pay_stamp(date_helper.cur_sec());
    reward.save_db();
    
    reward.update_recharge_activity(rmb_);
    reward.update_single_activity(rmb_);

    sc_msg_def::nt_daily_pay_t nt;
    nt.rmb = rmb_;
    nt.total = reward.db.daily_pay;
    logic.unicast(db.uid, nt);
}
int sc_user_t::on_allyb_change(int32_t payyb_, int32_t freeyb_)
{
    if( 0 == (payyb_+freeyb_) )
        return db.payyb+db.freeyb;
        
    int32_t old = db.payyb + db.freeyb;

    db.set_payyb(db.payyb + payyb_);
    if (db.payyb < 0)
        db.set_payyb(0);

    db.set_freeyb(db.freeyb + freeyb_);
    if (db.freeyb < 0)
        db.set_freeyb(0);

    sc_msg_def::nt_yb_change_t nt;
    nt.now = db.payyb+db.freeyb;
    logic.unicast(db.uid, nt);
    
    if( (payyb_+freeyb_)<0 )
    {
        reward.db.set_cumu_yb_exp( reward.db.cumu_yb_exp-(payyb_+freeyb_) );
        activity.on_cumu_yb(db.uid, -(payyb_+freeyb_));
        reward.save_db();
    }
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.payyb+db.freeyb;
}

//主角升阶
int sc_user_t::on_quality_change()
{
    //获取伙伴升阶需要的材料, quality编号从1开始，切记
    int32_t id = db.resid*10 + db.quality + 1 + 1;
    auto it_hm = repo_mgr.qualityup_staff.find(id);
    if( it_hm == repo_mgr.qualityup_staff.end() )
    {
        logerror((LOG, "on_user_quality_change,repo no qualityup staff, pid:%d", db.uid));
        sc_msg_def::ret_quality_up_t ret;
        ret.pid = 0;
        ret.code = ERROR_UPGRADE_MAX_LV;
        logic.unicast(db.uid, ret);
        return ERROR_UPGRADE_MAX_LV;
    }

    //判断材料是否足够
    if( (db.soul<it_hm->second.var2) || (db.gold < it_hm->second.var3) )
     {
        logerror((LOG, "on_quality_change,bag not enough material, pid:%d", db.uid));
        sc_msg_def::ret_quality_up_t ret;
        ret.pid = 0;
        ret.code = ERROR_SC_NOT_ENOUGH_MATERIAL;
        logic.unicast(db.uid, ret);
        return ERROR_SC_NOT_ENOUGH_MATERIAL;
    }       

    //扣去背包中的材料，通知客户端背包改变
    //on_runechip_change( -(it_hm->second.var1));
    sc_msg_def::nt_chip_change_t change;
    int32_t chip_resid = pub_ctl.get_chip_resid(db.resid);
    if( !partner_mgr.consume_chip(chip_resid,it_hm->second.var1,change) )
        return ERROR_SC_EXCEPTION;
    partner_mgr.on_chip_change(change);
    on_soul_change( -(it_hm->second.var2) );
    on_money_change( -(it_hm->second.var3) );

    //伙伴升阶
    int32_t old = db.quality;
    db.set_quality(db.quality + 1);
    save_db();

    skill_mgr.update_skill_level(0, db.quality, db.resid);
    //通知客户端伙伴属性改变
    on_pro_changed();
    
    achievement.on_event(evt_rankup_lv, 1);
    //返回结果
    sc_msg_def::ret_quality_up_t ret;
    ret.pid = 0;
    ret.code = SUCCESS;
    logic.unicast(db.uid, ret);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,ret.cmd(),0,old,0,db.quality);

    return SUCCESS;
}

int sc_user_t::on_power_change(int32_t power_)
{
    int32_t old = db.power;
    db.set_power(db.power + power_); 
    
    if( (old>=POWER_UPLIMIT) && (db.power<POWER_UPLIMIT) )
    {
        db.last_power_stamp = date_helper.cur_sec();
        db.set_last_power_stamp(db.last_power_stamp);
        save_db();
    }
    sc_msg_def::nt_power_change_t nt;
   
    nt.is_in_limit_activity = 0; 
    //更新消耗体力数
    if (power_ < 0)
    {
        reward.update_limit_activity_power(-power_, nt.is_in_limit_activity, nt.limit_consume_power_reward, nt.limit_consume_power);
        reward.consume_daily_power(-power_);
        logwarn((LOG, "consume power: %d, user uid is : %d", power_, db.uid));
    }
    nt.now = db.power;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.power;
}

int sc_user_t::on_chronicle_sum_change(int32_t value_)
{
    db.set_chronicle_sum(db.chronicle_sum + value_);
    if (db.chronicle_sum < 0)
    {
        db.set_chronicle_sum(0);
    }

    sc_msg_def::nt_chronicle_sum_change_t nt;
    nt.now = db.chronicle_sum;
    logic.unicast(db.uid, nt);

    return db.chronicle_sum;
}

int sc_user_t::on_lovelevel_change(int32_t pid_)
{
    if (pid_ == 0) {
        if (db.lovelevel >= MAX_LOVE_LEVEL) // 爱恋度最大等级
            return -1;
        db.set_lovelevel(db.lovelevel + 1);
        if (db.lovelevel < 0)
        {
            db.set_lovelevel(0);
        }
        sc_msg_def::nt_lovelevelup_t nt;
        nt.pid = pid_;
        nt.lovelevel = db.lovelevel;
        logic.unicast(db.uid, nt);
        return db.lovelevel;
    } else {
        sp_partner_t par = partner_mgr.get(pid_);
        if (par->db.lovelevel >= MAX_LOVE_LEVEL) // 爱恋度最大等级
            return -1;
        par->db.set_lovelevel(par->db.lovelevel + 1);
        if (par->db.lovelevel < 0)
        {
            par->db.set_lovelevel(0);
        }
        par->save_db();
        sc_msg_def::nt_lovelevelup_t nt;
        nt.pid = pid_;
        nt.lovelevel = par->db.lovelevel;
        logic.unicast(par->db.uid, nt);
        return par->db.lovelevel;
    }
}

void sc_user_t::on_change_help_hero(int32_t pid_)
{
    int32_t newresid, oldresid = db.hhresid;
    
    sp_partner_t par = partner_mgr.get(pid_);
    if( par )
        newresid = par->db.resid;
    else
        newresid = db.resid;

    db.set_helphero(pid_);
    db.set_hhresid(newresid);
    save_db();

    if( oldresid != newresid )
    {
        friend_mgr.on_helphero_change( newresid );
        sp_helphero_t sp_helphero=get_helphero();
        hero_cache.put(db.uid,sp_helphero);
    }

    sc_msg_def::ret_friend_helpbattle_t ret;
    ret.code = SUCCESS;
    ret.uid = db.uid;
    logic.unicast(db.uid, ret);
}
int sc_user_t::on_energy_change(int32_t energy_)
{
    int32_t old = db.energy;
    db.set_energy(db.energy + energy_);

    if( (old>=ENERGY_UPLIMIT) && (db.energy<ENERGY_UPLIMIT) )
        last_gen_energy = date_helper.cur_sec();

    sc_msg_def::nt_energy_change_t nt;
    nt.now = db.energy;
    nt.left_secs = SECONDS_PER_ENERGY - date_helper.cur_sec()%SECONDS_PER_ENERGY;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.energy;
}
int sc_user_t::on_fpoint_change(int32_t fpoint_)
{
    //int32_t old = db.fpoint;

    db.set_fpoint(db.fpoint + fpoint_);
    if (db.fpoint < 0)
    {
        db.set_fpoint(0);
    }

    sc_msg_def::nt_fpoint_change_t nt;
    nt.now = db.fpoint;
    logic.unicast(db.uid, nt);
    
    /*
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);
    */

    return db.fpoint;
}
int sc_user_t::on_soul_change(int32_t soul_)
{
    if( soul_ == 0 )
        return db.soul;

    db.set_soul(db.soul + soul_);
    if (db.soul < 0)
    {
        db.set_soul(0);
    }

    sc_msg_def::nt_soul_change_t nt;
    nt.now = db.soul;
    logic.unicast(db.uid, nt);
    
    return db.soul;
}
int sc_user_t::on_honor_change(int32_t honor_)
{
    int old = db.honor;
    if( honor_ == 0 )
        return db.honor;

    db.set_honor(db.honor + honor_);
    if (db.honor < 0)
    {
        db.set_honor(0);
    }

    sc_msg_def::nt_honor_change_t nt;
    nt.now = db.honor;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);

    return db.honor;
}
int sc_user_t::on_unhonor_change(int32_t honor_)
{
    int32_t old = db.unhonor;
    if( honor_ == 0 )
        return db.unhonor;

    db.set_unhonor(db.unhonor + honor_);
    if (db.unhonor < 0)
    {
        db.set_unhonor(0);
    }

    sc_msg_def::nt_unhonor_change_t nt;
    nt.now = db.unhonor;
    logic.unicast(db.uid, nt);
    
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);
    
    return db.unhonor;
}

int sc_user_t::on_meritorious_change(int32_t meritorious_)
{
    if (meritorious_ == 0)
        return db.meritorious;

    int lv = db.titlelv;
    int lasttitlelv = db.titlelv;
    repo_def::titleup_t* rp_titleup = NULL;
    while((rp_titleup = repo_mgr.titleup.get(lv+1)) != NULL)
    {
        if ((db.meritorious + meritorious_) < rp_titleup->meritorious)
            break;
        ++lv;
    }
    if (rp_titleup == NULL)
    {
        rp_titleup = repo_mgr.titleup.get(lv);
        db.set_meritorious(rp_titleup->meritorious);
    }
    else db.set_meritorious(db.meritorious + meritorious_);
    
    sc_msg_def::nt_meritorious_t nt1;
    nt1.now = db.meritorious;
    logic.unicast(db.uid, nt1);
    if (db.titlelv >= lv)
        return db.titlelv;
    
    rp_titleup = repo_mgr.titleup.get(lv);
    int newlv = rp_titleup->id;
    logwarn((LOG,"on_meritorious_change old titlelv = %d", lasttitlelv));
    logwarn((LOG,"on_meritorious_change new titlelv = %d", newlv));
    sp_user_t user;
    if (logic.usermgr().get(db.uid, user))
    {
        //发送奖励邮件
        for (int i = lasttitlelv + 1; i<= newlv; i++ )
        {
            repo_def::titleup_t* temp = NULL;
            if ((temp = repo_mgr.titleup.get(i)) != NULL)
            {
                sc_msg_def::nt_bag_change_t nt;
                sc_msg_def::jpk_item_t itm;
                itm.itid = 0;
                itm.resid = temp->reward[1];
                itm.num = temp->reward[2];
                nt.items.push_back(itm);

                string msg = mailinfo.new_mail(mail_arena_rank_up, temp->name, temp->reward[2]);
                auto rp_gmail = mailinfo.get_repo(mail_arena_rank_up);
                if (rp_gmail != NULL)
                {
                    user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                }
            }
        }
    }
    sc_msg_def::nt_titleup_t nt2;
    nt2.now = newlv;
    logic.unicast(db.uid, nt2);
    db.set_titlelv(newlv);
    return db.titlelv;
}
/*
int sc_user_t::on_limit_round_change(int32_t index_, int32_t value_)
{
    // index_ : 0 个位  1 十位  2 百位
    if (value_ == 0)
        return db.limitround;

    if (index_ < 0 || index_ > 3)
        return db.limitround;

    int32_t num = (db.limitround >> (4*index_)) & (0x7);

    int32_t new_limitround = db.limitround - (num << (4*index_));
   
    num += value_;
   
    if (num < 0) num = 0;
    if (num > 5) num = 5;

    new_limitround += (num << (4*index_));
    new_limitround = (new_limitround & 0x777);
    db.set_limitround(new_limitround);
    return db.limitround;     
}
*/
int sc_user_t::on_battlexp_change(int32_t battlexp_)
{
    //int32_t old = db.battlexp;

    db.set_battlexp(db.battlexp + battlexp_);
    if (db.battlexp < 0)
    {
        db.set_battlexp(0);
    }

    sc_msg_def::nt_battlexp_change_t nt;
    nt.now = db.battlexp;
    logic.unicast(db.uid, nt);
    
    /*
    //记录事件
    statics_ins.unicast_eventlog(*this,nt.cmd(),old,nt.now);
    */

    return db.battlexp;
}

bool sc_user_t::load_db(int32_t uid_)
{
    sql_result_t res;
    if (0==db_UserInfo_t::sync_select_user(uid_, res))
    {
        db.init(*res.get_row_at(0));
        partner_mgr.load_db();
        equip_mgr.load_db();
        skill_mgr.load_db();
        item_mgr.load_db();
        soulrank_mgr.load_db();
        friend_mgr.load_db();
        friend_flower_mgr.load_db();
        //rune_mgr.load_db();
        new_rune_mgr.load_db();
        task.load_db();
        daily_task.load_db();
        achievement.load_db();
        reward.load_db();
        star_mgr.load_db();
        shop.load_db();
        expeditionshop_mgr.load_db();
        gangshop_mgr.load_db();
        runeshop_mgr.load_db();
        cardeventshop_mgr.load_db();
        lmtshop_mgr.load_db();
        prestigeshop.load_db();
        chipshop.load_db();
        plantshop.load_db();
        inventoryshop.load_db();
        chipsmash.load_db();
        vip.load_db();
        arena.load_db();
        expedition.load_db();
        treasure.load_db();
        activity.load_user(*this);
        gmail.load_db();
        wing.load_db();
        chronicle.load_db();
        love_task.load_db();
        team_mgr.load_db();
        card_event.load_db();
        soul.load_db();
        //homebuilding.load_db();
        gem_page_mgr.load_db();
        pet_mgr.load_db();
        combo_pro_mgr.load_db();
        report_mgr.load_db();
        pub_mgr.load_db();
        return true;
    }
    return false; 
}

void sc_user_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}
void sc_user_t::get_jpk_role_data(sc_msg_def::jpk_role_data_t &urole)
{
    urole.pid = 0;
    urole.resid = db.resid;

    pro.cal_pro(0, -1, 1);
    pro.copy(urole.pro);

    urole.lvl.level = db.grade;
    urole.lvl.exp = db.exp;
    urole.lvl.lovelevel = db.lovelevel;
    gang_mgr.get_ggname_by_uid( db.uid, urole);
    urole.quality = db.quality;
    urole.lovevalue = db.lovevalue;
    urole.naviClickNum1= db.naviClickNum1;
    urole.naviClickNum2= db.naviClickNum2;

    urole.potential_1 = db.potential_1;
    urole.potential_2 = db.potential_2;
    urole.potential_3 = db.potential_3;
    urole.potential_4 = db.potential_4;
    urole.potential_5 = db.potential_5;

    urole.draw_num = db.draw_num;
    urole.kanban = db.kanban;
    urole.kanban_type = db.kanban_type;
    urole.draw_ten_diamond = db.draw_ten_diamond;
    urole.draw_reward = db.draw_reward();
    urole.round_stars_reward = db.round_stars_reward();

    if (wing.get_weared() != NULL)
    {
        sc_msg_def::jpk_wing_t jpk_wing; 
        wing.get_weared()->get_wing_jpk(jpk_wing);
        urole.wings.push_back(std::move(jpk_wing));
    }
    pet_mgr.get_pet_jpk(urole.pet, urole.have_pet);

    skill_mgr.foreach([&](sp_skill_t skl_){
        sc_msg_def::jpk_skill_t skl;
        skl_->get_skill_jpk(skl);
        if (skl_->db.pid == 0)
        {
            urole.skls.push_back(std::move(skl));
        }
    });

    int slot=1;
    equip_mgr.foreach([&, this](sp_equip_t eqp_){

        repo_def::equip_t* reqp = repo_mgr.equip.get(eqp_->db.resid); 
        if (reqp == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", eqp_->db.resid));
            return; 
        }

        sc_msg_def::jpk_equip_t eqp;
        eqp_->get_equip_jpk(eqp);

        if((eqp_->db.isweared==1)&&(eqp_->db.pid==0))
        {
            urole.equips.insert(std::move(make_pair(slot, std::move(eqp))));
            slot++;
        }
    });
    
    star_mgr.foreach([&](sp_star_t star_){
        sc_msg_def::jpk_star_t star;
        star_->get_star_jpk(star);
        urole.stars.push_back(std::move(star));
    },0);

//    rune_mgr.get_runes(0,urole.runes);
}
void sc_user_t::get_jpk_view_data(sc_msg_def::jpk_view_role_data_t &view_)
{
    view_.uid = db.uid;
    view_.pid = 0;
    view_.resid = db.resid;

    pro.cal_pro(0, -1, 1);
    pro.copy(view_.pro);

    view_.lvl.level = db.grade;
    view_.lvl.exp = db.exp;
    view_.lvl.lovelevel = db.lovelevel;

    view_.quality = db.quality;
    view_.potential_1 = db.potential_1;
    view_.potential_2 = db.potential_2;
    view_.potential_3 = db.potential_3;
    view_.potential_4 = db.potential_4;
    view_.potential_5 = db.potential_5;

    if (wing.get_weared() != NULL)
    {
        sc_msg_def::jpk_wing_t jpk_wing; 
        wing.get_weared()->get_wing_jpk(jpk_wing);
        view_.wings.push_back(std::move(jpk_wing));
    }
    
    int slot=1;
    equip_mgr.foreach([&, this](sp_equip_t eqp_){
        if ((eqp_->db.isweared==1) && (eqp_->db.pid == 0))
        {
            repo_def::equip_t* reqp = repo_mgr.equip.get(eqp_->db.resid);
            if (reqp == NULL)
            {
                logerror((LOG, "repo no equip resid:%d", eqp_->db.resid));
                return;
            }
            sc_msg_def::jpk_equip_t jpk;
            eqp_->get_equip_jpk(jpk);
            view_.equips.insert(std::move(make_pair(slot, std::move(jpk))));
            slot++;
        }
    });

    skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == 0)
        {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            view_.skls.push_back(std::move(jpk));
        }
    });
}
void sc_user_t::get_jpk_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_)
{
    view_.uid = db.uid;
    view_.pid = 0;
    view_.resid = db.resid;
    pro.cal_pro(0, -1, 1);
    pro.copy(view_.pro);
    view_.lvl.push_back(db.grade);
    view_.lvl.push_back(db.lovelevel);
    if (wing.get_weared() != NULL) {
        sc_msg_def::jpk_wing_t jpk_wing; 
        wing.get_weared()->get_wing_jpk(jpk_wing);
        view_.wid = jpk_wing.resid;
    }

    skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == 0) {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            if (jpk.level > 0) {
                vector<int32_t> tmp;
                tmp.push_back(jpk.skid);
                tmp.push_back(jpk.resid);
                tmp.push_back(jpk.level);
                view_.skls.push_back(std::move(tmp));
            }
        }
    });
}
void sc_user_t::get_jpk_gbattle_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_, int32_t pos_)
{
    view_.uid = db.uid;
    view_.pid = 0;
    view_.resid = db.resid;
    sc_pro_t g_battle_pro(*this);
    g_battle_pro.cal_pro(0, pos_, 1);
    g_battle_pro.copy(view_.pro);
    view_.lvl.push_back(db.grade);
    view_.lvl.push_back(db.lovelevel);
    if (wing.get_weared() != NULL) {
        sc_msg_def::jpk_wing_t jpk_wing; 
        wing.get_weared()->get_wing_jpk(jpk_wing);
        view_.wid = jpk_wing.resid;
    }

    skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == 0) {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            if (jpk.level > 0) {
                vector<int32_t> tmp;
                tmp.push_back(jpk.skid);
                tmp.push_back(jpk.resid);
                tmp.push_back(jpk.level);
                view_.skls.push_back(std::move(tmp));
            }
        }
    });
}

int sc_user_t::get_equip_level(int32_t uid_, int32_t pid_)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select resid from Equip where uid=%d and pid=%d;", uid_, pid_);
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        return 1;
    }
    //一个英雄有五件装备
    int lowest_lv = 13;//用于保存装备的最低等级
    for (int i = 0; i < (int)res.affect_row_num(); ++i)
    {    
        sql_result_row_t& row = *res.get_row_at(i);
        int temp = (int)std::atoi(row[0].c_str());
        
        repo_def::equip_t* rp_equip = repo_mgr.equip.get(temp);
        int temp_level = 13;
        if (rp_equip == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", temp));
            temp_level = 13;
        }else
        {
            temp_level = rp_equip->rank;
        }
        if (temp_level < lowest_lv)
            lowest_lv = temp_level;
    }

    return lowest_lv;
}

void sc_user_t::get_jpk_rank_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_, float num, int32_t pos_)
{
    view_.uid = db.uid;
    view_.pid = 0;
    view_.resid = db.resid;
    sc_pro_t pro_rank(*this);
    pro_rank.cal_pro(0, pos_, num);
    pro_rank.copy(view_.pro);
    view_.lvl.push_back(db.grade);
    view_.lvl.push_back(db.lovelevel);
    if (wing.get_weared() != NULL) {
        sc_msg_def::jpk_wing_t jpk_wing; 
        wing.get_weared()->get_wing_jpk(jpk_wing);
        view_.wid = jpk_wing.resid;
    }

    skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == 0) {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            if (jpk.level > 0) {
                vector<int32_t> tmp;
                tmp.push_back(jpk.skid);
                tmp.push_back(jpk.resid);
                tmp.push_back(jpk.level);
                view_.skls.push_back(std::move(tmp));
            }
        }
    });
}
int sc_user_t::get_limit_round_data(sc_msg_def::ret_limit_round_data &ret_)
{
       ret_.code = SUCCESS;
       sc_limit_round_mgr.req_user_round_data(db.uid, *this, ret_); 
       return SUCCESS;
}
int sc_user_t::reset_limit_round_times(sc_msg_def::ret_reset_limit_round_times &ret_)
{
    return sc_limit_round_mgr.req_reset_limit_round_times(db.uid,*this,ret_);
}
void sc_user_t::get_index_role_info(sc_msg_def::jpk_role_data_t &urole)
{
    get_jpk_role_data(urole);
}

sp_view_user_t sc_user_t::get_view()
{
    sp_view_user_t sp_view(new sc_msg_def::jpk_view_user_data_t());

    sp_view->uid = db.uid;
    sp_view->name = db.nickname();
    sp_view->rank = db.rank;
    sp_view->lv = db.grade;
    sp_view->viplevel = db.viplevel;
    sp_view->fp = db.fp;
    sp_view->model = db.model;
    sp_view->ggid = gang_mgr.get_ggid_by_uid(db.uid);;
    sql_result_t res;
    db_Gang_t dbGang;
    dbGang.sync_select_gang(sp_view->ggid, db.hostnum, res);
    sp_view->hp_percent = 1;
    combo_pro_mgr.get_combo_pro(sp_view->combo_pro);
    if (res.get_row_at(0) != NULL)
    {
        dbGong.init(*res.get_row_at(0));
        sp_view->ggname = dbGong.name(); 
    }
    for(size_t i=0;i<5;++i)
    {
        if( 0 > team_mgr[i] )
            continue;

        if( 0==team_mgr[i] )
        {
            sc_msg_def::jpk_view_role_data_t view;
            get_jpk_view_data(view);
            sp_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
            continue;
        }

        sp_partner_t p=partner_mgr.get(team_mgr[i]);
        if( p != NULL )
        {
            sc_msg_def::jpk_view_role_data_t view;
            p->get_jpk_view_data(view);
            sp_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
        }
    }

    return sp_view;
}
sp_view_user_other_t sc_user_t::get_view_others()
{
    sp_view_user_other_t sp_view(new sc_msg_def::jpk_view_other_data_t());

    char sql[256];
    sql_result_t result;
    sprintf(sql,"select total_login_days from Reward where uid=%d;",db.uid);
    db_service.sync_select(sql, result);
    if( 0==result.affect_row_num() ) 
        sp_view->total_login_days = 1;
    else
    {
        sql_result_row_t& row = *result.get_row_at(0);
        sp_view->total_login_days = (int)std::atoi(row[0].c_str());
    }  
    
    char sel[1024];
    sql_result_t reu;
    sprintf(sel,"select resid, strenlevel from Equip where uid=%d and pid =0;",db.uid);
    db_service.sync_select(sel, reu);
    if( 0==reu.affect_row_num() ) 
    {
        sp_view->equip1_resid = 13027;
        sp_view->equip2_resid = 13036;
        sp_view->equip3_resid = 13045;
        sp_view->equip4_resid = 13054;
        sp_view->equip5_resid = 13063;
        sp_view->strenlevel = 0;
    }
    else
    {
        sp_view->strenlevel = 0;
        for (int i = 0; i < reu.affect_row_num(); ++i)
        {
            sql_result_row_t& row = *reu.get_row_at(i);
            if (i == 0)
                sp_view->equip1_resid = (int)std::atoi(row[0].c_str());
            else if (i == 1)
                sp_view->equip2_resid = (int)std::atoi(row[0].c_str());
            else if (i == 2)
                sp_view->equip3_resid = (int)std::atoi(row[0].c_str());
            else if (i == 3)
                sp_view->equip4_resid = (int)std::atoi(row[0].c_str());
            else if (i == 4)
                sp_view->equip5_resid = (int)std::atoi(row[0].c_str());
            sp_view->strenlevel += (int)std::atoi(row[1].c_str()); 
        }
    }

        
    sp_view->kanban = db.kanban;
    sp_view->kanban_type = db.kanban_type; 
    sp_view->uid = db.uid;
    sp_view->resid = db.resid;
    sp_view->name = db.nickname();
    sp_view->rank = db.rank;
    sp_view->lv = db.grade;
    sp_view->viplevel = db.viplevel;
    sp_view->draw_num = db.draw_num;
    sp_view->lovelevel = db.lovelevel;
    sp_view->quality = db.quality;
    pro.cal_pro(0, -1, 1);
    sp_view->fp = pro.get_fp();
    sp_view->ggid = gang_mgr.get_ggid_by_uid(db.uid);;
    sql_result_t res;
    sp_view->team.pid1= team_mgr[0];
    sp_view->team.pid2= team_mgr[1];
    sp_view->team.pid3= team_mgr[2];
    sp_view->team.pid4= team_mgr[3];
    sp_view->team.pid5= team_mgr[4];
    db_Gang_t dbGang;
    dbGang.sync_select_ganginfo(sp_view->ggid, res);
    sp_view->hp_percent = 1;
    if (res.get_row_at(0) != NULL)
    {
        dbGong.init(*res.get_row_at(0));
        sp_view->ggname = dbGong.name(); 
    }
    int32_t i = 0;
    partner_mgr.foreach([&](sp_partner_t partner_){
        sc_msg_def::jpk_role_data_t prole;
        if (SUCCESS == partner_->get_partner_jpk(prole))
        {
            sp_view->roles.insert(std::move(make_pair(i,std::move(prole))));
            i++;
        }
    });
    combo_pro_mgr.get_combo_pro(sp_view->combo_pro);

    return sp_view;
}

sp_view_user_t sc_user_t::get_view(int32_t tid_)
{
    sp_team_t sp_team_ = team_mgr.get(tid_);
    if (sp_team_ == NULL)
    {
        logerror((LOG, "get_view(tid_) error, tid:%d not exists!", tid_));
        return NULL;
    }

    sp_view_user_t sp_view(new sc_msg_def::jpk_view_user_data_t());
    sp_view->uid = db.uid;
    sp_view->name = db.nickname();
    sp_view->rank = db.rank;
    sp_view->lv = db.grade;
    sp_view->viplevel = db.viplevel;
    sp_view->hp_percent = 1;
    combo_pro_mgr.get_combo_pro(sp_view->combo_pro);

    sp_team_->foreach_get_view([&](int32_t pid_, int32_t index_){
        if (0 == pid_)
        {
            sc_msg_def::jpk_view_role_data_t view;
            get_jpk_view_data(view);
            sp_view->roles.insert(std::move(make_pair(index_, std::move(view))));
        }
        else if (pid_ > 0)
        {
            sp_partner_t p = partner_mgr.get(pid_);
            if (p != NULL)
            {
                sc_msg_def::jpk_view_role_data_t view;
                p->get_jpk_view_data(view);
                sp_view->roles.insert(std::move(make_pair(index_, std::move(view))));
            }
        }
    });

    return sp_view;
}
sp_view_user_t sc_user_t::get_view(int32_t* pid_)
{
    sp_view_user_t sp_view(new sc_msg_def::jpk_view_user_data_t());
    sp_view->uid = db.uid;
    sp_view->name = db.nickname();
    sp_view->rank = db.rank;
    sp_view->lv = db.grade;
    sp_view->viplevel = db.viplevel;
    sp_view->hp_percent = 1;
    combo_pro_mgr.get_combo_pro(sp_view->combo_pro);

    for (size_t i = 0; i < 5; ++i)
    {
        if (0 > pid_[i])
            continue;
        if (0 == pid_[i])
        {
            sc_msg_def::jpk_view_role_data_t view;
            get_jpk_view_data(view);
            sp_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
            continue;
        }
        sp_partner_t p = partner_mgr.get(pid_[i]);
        if (p != NULL)
        {
            sc_msg_def::jpk_view_role_data_t view;
            p->get_jpk_view_data(view);
            sp_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
        }
    }

    return sp_view;
}
sp_fight_view_user_t sc_user_t::get_fight_view(int32_t* pid_)
{
    sp_fight_view_user_t sp_fight_view(new sc_msg_def::jpk_fight_view_user_data_t());
    sp_fight_view->uid = db.uid;
    sp_fight_view->name = db.nickname();
    sp_fight_view->rank = db.rank;
    sp_fight_view->lv = db.grade;
    sp_fight_view->viplevel = db.viplevel;
    combo_pro_mgr.get_combo_pro(sp_fight_view->combo_pro);

    for (size_t i = 0; i < 5; ++i) {
        if (0 > pid_[i]) continue;
        if (0 == pid_[i]) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            get_jpk_fight_view_data(view);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
            continue;
        }
        sp_partner_t p = partner_mgr.get(pid_[i]);
        if (p != NULL) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            p->get_jpk_fight_view_data(view);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
        }
    }
    return sp_fight_view;
}
sp_fight_view_user_t sc_user_t::get_gbattle_fight_view(int32_t* pid_)
{
    sp_fight_view_user_t sp_fight_view(new sc_msg_def::jpk_fight_view_user_data_t());
    sp_fight_view->uid = db.uid;
    sp_fight_view->name = db.nickname();
    sp_fight_view->rank = db.rank;
    sp_fight_view->lv = db.grade;
    sp_fight_view->viplevel = db.viplevel;
    combo_pro_mgr.get_combo_pro(sp_fight_view->combo_pro);

    for (int32_t i = 0; i < 5; ++i) {
        if (0 > pid_[i]) continue;
        if (0 == pid_[i]) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            get_jpk_gbattle_fight_view_data(view, i);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
            continue;
        }
        sp_partner_t p = partner_mgr.get(pid_[i]);
        if (p != NULL) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            p->get_jpk_gbattle_fight_view_data(view, i);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
        }
    }
    return sp_fight_view;
}

sp_fight_view_user_t sc_user_t::get_rank_view(int32_t* pid_)
{
    sp_fight_view_user_t sp_fight_view(new sc_msg_def::jpk_fight_view_user_data_t());
    sp_fight_view->uid = db.uid;
    sp_fight_view->name = db.nickname();
    sp_fight_view->rank = db.rank;
    sp_fight_view->lv = db.grade;
    sp_fight_view->viplevel = db.viplevel;
    combo_pro_mgr.get_combo_pro(sp_fight_view->combo_pro);

    for (size_t i = 0; i < 5; ++i) {
        if (0 > pid_[i]) continue;
        if (0 == pid_[i]) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            get_jpk_rank_view_data(view, 0.05, i);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
            continue;
        }
        sp_partner_t p = partner_mgr.get(pid_[i]);
        if (p != NULL) {
            sc_msg_def::jpk_fight_view_role_data_t view;
            p->get_jpk_rank_view_data(view, 0.05, i);
            sp_fight_view->roles.insert(std::move(make_pair(i+1,std::move(view))));
        }
    }
    return sp_fight_view;
}
sp_helphero_t sc_user_t::get_helphero()
{
    sp_helphero_t sp_helphero(new sc_msg_def::jpk_view_role_data_t());

    if( db.helphero == 0 )
    {
        get_jpk_view_data(*sp_helphero);
        return sp_helphero;
    }
    sp_partner_t partner = partner_mgr.get(db.helphero);
    if( !partner )
    {
        logerror((LOG, "get_helphero, no pid:%d", db.helphero));
        return sp_helphero_t();
    }
    partner->get_jpk_view_data(*sp_helphero);
    return sp_helphero;
}

sp_baseinfo_t sc_user_t::get_frd_info()
{
    sp_baseinfo_t sp_frd(new sc_baseinfo_t());

    sp_frd->nickname = db.nickname();
    sp_frd->grade = db.grade;
    sp_frd->fp = db.fp;
    sp_frd->frdcount = db.frd;
    sp_frd->helphero = db.helphero;

    if( 0 == db.helphero )
        sp_frd->helpresid = db.resid;
    else
    {
        sp_partner_t p=partner_mgr.get(db.helphero);
        
        if( p != NULL )
        {
            sp_frd->helpresid = p->db.resid;
        }
    }

    return sp_frd;
}

int32_t sc_user_t::cal_offline_interval()
{
    struct timeval tm;
    gettimeofday(&tm, NULL);
    return tm.tv_sec - db.lastquit;
}
void sc_user_t::cal_offline_exp()
{
    //获得每五分钟离线经验
    repo_def::levelup_t* p_lvup = repo_mgr.levelup.get(db.grade);
    if (p_lvup == NULL)
    {
        logerror((LOG, "cal_offline_exp, illegal grade:%d", db.grade));
        return;
    }
    int32_t offline_exp = p_lvup->offline_exp_bonus;

    //计算离线期间获得经验次数
    int32_t exp;
    logerror((LOG, "cal_offline_exp, illegal db.lastdate:%d", db.lastquit));
    if( 0 == db.lastquit )
    {
        exp = 0;
    }
    else
    {
        struct timeval tm;
        gettimeofday(&tm, NULL);

        int32_t count_exp = (tm.tv_sec - db.lastquit )/SECONDS_PER_EXP;
        exp = count_exp * offline_exp;
    }

    //保存主角经验
    on_exp_change( exp );
    save_db();
}

void sc_user_t::gen_power(int32_t &seconds_left_, int32_t &power_)
{
    int32_t time_cur = date_helper.cur_sec();

    if (db.power >= POWER_UPLIMIT)
    {
        seconds_left_ = SECONDS_PER_POW - time_cur%SECONDS_PER_POW;
        power_ = db.power;
        db.last_power_stamp = time_cur;
        db.set_last_power_stamp(db.last_power_stamp);
        save_db();
        return;
    }

    int32_t count_gen = time_cur/SECONDS_PER_POW - db.last_power_stamp/SECONDS_PER_POW ;
    if (count_gen >= 1)
    {
        db.set_power(db.power + count_gen * POWER_PER_GEN);
        if( db.power>POWER_UPLIMIT )
            db.set_power(POWER_UPLIMIT);

        save_db();
    }

    seconds_left_ = SECONDS_PER_POW - time_cur%SECONDS_PER_POW;
    power_ = db.power;
    db.last_power_stamp = time_cur;
    db.set_last_power_stamp(db.last_power_stamp);
    save_db();
}

void sc_user_t::gen_energy(int32_t &seconds_left_, int32_t &energy_)
{
    if( 0 == last_gen_energy )
        last_gen_energy = db.lastquit;

    struct timeval tm;
    gettimeofday(&tm,NULL);

    if (db.energy >= ENERGY_UPLIMIT)
    {
        seconds_left_ = SECONDS_PER_ENERGY - tm.tv_sec%SECONDS_PER_ENERGY; 
        energy_ = db.energy;
        last_gen_energy = tm.tv_sec;
        return;
    }

    int32_t count_gen = tm.tv_sec/SECONDS_PER_ENERGY-last_gen_energy/SECONDS_PER_ENERGY ;
    if( count_gen >= 1)
    {
        db.set_energy(db.energy + count_gen * ENERGY_PER_GEN);
        if( db.energy>ENERGY_UPLIMIT )
            db.set_energy(ENERGY_UPLIMIT);

        save_db();
    }

    seconds_left_ = SECONDS_PER_ENERGY - tm.tv_sec%SECONDS_PER_ENERGY;
    energy_ = db.energy;
    last_gen_energy = tm.tv_sec;
}

void check_mail(int uid_)
{
    sql_result_t res;
    if (db_Mail_t::sync_select(uid_, res) == 0){

        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sql_result_row_t& row = *res.get_row_at(i);
            db_Mail_t db;
            db.init(row);
            notify_ctl.push_mail(uid_, db.info.c_str());

            db_service.async_do((uint64_t)uid_, [](uint32_t uid_){
                    char sql[128];
                    sprintf(sql, "delete from Mail where uid=%d", uid_);
                    db_service.async_execute(sql);
            }, uid_);
        }
    }
}

void sc_user_t::on_login()
{
    //round.load_halt_info();
    //通知该玩家的好友，我上线了
    arena.on_login();
    friend_mgr.on_online_change(1);
    reward.on_login();
    arena_rank.on_login(db.uid);
    vip.on_login();
    //登陆的时候检查是否有邮件
    //check_mail(db.uid);
    activity.on_login(db.uid);
    gmail.on_login();
    check_first_login();
}

void sc_user_t::check_first_login()
{
    //读取更新login的时间戳
    char sql[256];
    sql_result_t res;
    sprintf(sql, "select zodiacstamp from UserInfo where uid = %d ;", db.uid);
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {
        char error_info[64];
        sprintf(error_info,"File: [%s], Line: [%I64d]", __FILE__, __LINE__);
        logerror((LOG," no such user! %s", error_info));
        return;
    }

    sql_result_row_t& row = *res.get_row_at(0);
    int stamp = (int)std::atoi(row[0].c_str());
    if(date_helper.offday(stamp) >= 1)
    {
        new_round.refrsh_daily_data();      //更新精英副本等刷新次数
        
        stamp = date_helper.cur_sec();
        sprintf(sql, "update UserInfo set zodiacstamp = %d where uid = %d", stamp, db.uid);
        db_service.sync_execute(sql);
    }
}

void sc_user_t::init_new_user(const db_UserID_t& userid_)
{
    //PERFORMANCE_GUARD("init_new_user");
    //插入角色信息
    db.nickname = userid_.nickname;
    db.resid = userid_.resid;
    db.model = userid_.resid;
    db.uid = userid_.uid;
    db.exp = 0;
    db.grade = 1;
    db.hostnum = userid_.hostnum;
    db.chronicle_sum = 0;
    db.lovelevel = 0;
    db.payyb = 0;
    db.freeyb = 0;
    db.gold = 1000;
    db.battlexp = 1000;
    db.runechip = 0;
    db.fpoint = 0;
    db.viplevel = 0;
    db.vipexp = 0;
    db.isnew = 0;
    db.isnewlv = 0;
    db.draw_num = 0;
    db.draw_ten_diamond = 0;
    db.kanban = 0;
    db.kanban_type = 0;
    db.aid = userid_.aid;
    db.sceneid = 1001;          //初始所在主城id
    db.roundid = 0;             //当前关卡进度
    db.elite_roundid = 0;
    db.eliteid = 0; 
    db.zodiacid = 3000;
    db.questid = 100001; // 默认挂一个任务，做新手引导的时候再删
    db.nextquestid = 100001;
    db.treasure = 0;
    db.power = 120;
    db.energy = 10;
    db.lastquit = 0;
    db.quality = 1; // 默认N卡
    db.lovevalue = 0;
    db.naviClickNum1 = 0;
    db.naviClickNum2 = 0;
    db.potential_1 = 0;
    db.potential_2 = 0;
    db.potential_3 = 0;
    db.potential_4 = 0;
    db.potential_5 = 0;
    db.flush1times = date_helper.cur_sec() - 28080,
    db.flush1round = 5,
    db.flush2first = 0,
    db.flush2round = 0,
    db.flush2times = date_helper.cur_sec(),
    db.flush3round = 0,
    db.flush3times = date_helper.cur_sec(),
    db.helphero = 0;
    db.hhresid = db.resid;
    db.frd = 0;
    db.totaltime = 0;
    db.fp = 0;
    db.bagn = 0;
    db.func = 0;
    db.utype = userid_.state == 100 ? 1:0; //100产生的都是机器人
    db.boxe = 0;
    db.boxn = 0;
    db.firstpay=0;
    db.soul=600;
    db.caveid=0;
    db.honor=0;
    db.unhonor = 0;
    db.meritorious=0;
    db.expeditioncoin = 0;
    db.titlelv = 0;
    db.npcshop = 1;
    db.npcshoprefresh = 50;
    db.npcshopbuy = 0;
    db.npcshoptime1 = 0;
    db.npcshoptime2 = 0;
    db.npcshoptime3 = 0;
    db.specicalshop = 0;
    db.spshopbuy = 0;
    db.spshoptime = 0;
    db.sign_daily = 0;
    db.sign_cost = 0;
    db.hm_maxid=0;
    db.twoprecord=0;
    db.limitround=0x555;
    db.zodiacstamp=0;
    db.rank=2000;
    db.m_rank=0;
    db.numFlower = 10;
    db.useFlower = 0;
    db.resetFlowerStamp = 0;
    db.useFlowerStamp = 0;
    db.last_power_stamp = 0;
    db.sign_month = 0;
    db.createtime = date_helper.day_0_stmp(date_helper.cur_sec());
    //test
    //db.viplevel = 4;
    //db.vipexp = 2500;

    //开始一个事务
    db_service.async_begin_trans(db.uid);
    
    db_service.async_do((uint64_t)db.uid, [](db_UserInfo_t& db_){
        db_.insert();
    }, db.data());
    
    partner_mgr.init_new_user();
    equip_mgr.init_new_user();
    skill_mgr.init_new_user();
    item_mgr.init_new_user();
    soulrank_mgr.init_new_user();
    team_mgr.init_new_user();
    arena.init_new_user();
    love_task.init_new_user();
    reward.init_db();
    vip.init_db();
    activity.init_new_user(*this);
    daily_task.init_new_user();
    achievement.init_new_user();
    card_event.init_new_user();
    gem_page_mgr.init_new_user();
    pet_mgr.init_new_user();
    combo_pro_mgr.init_new_user();
    pub_mgr.init_new_user();

    //提交事务
    db_service.async_commit_trans(db.uid);

}

void sc_user_t::set_kanban_role(int32_t uid, int32_t resid, int32_t type)
{
   db.set_kanban(resid);
   db.set_kanban_type(type);
   save_db(); 
}

/*
 * date string to uint32_t time stamp
 * 2015-01-01 00:00:00 => 1420041600
 */
uint32_t sc_user_t::str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

int sc_user_t::get_open_service_reward(int32_t index)
{
    //判断是否在活动时间内
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t item;
    repo_def::newly_reward_t * rp_draw_reward = NULL;
    //获得奖励的类型
    int flag = index/100;
    int pos = index - flag*100; 
    if((rp_draw_reward = repo_mgr.newly_reward.get(index))!=NULL)
    {
        auto f = [&](int item_, int num_)
        {
            if (num_ <= 0)
                return ERROR_SC_ILLEGLE_REQ;
            sc_msg_def::nt_bag_change_t nt;
            if (item_ / 10000 == 3)
                partner_mgr.add_new_chip(item_, num_, nt.chips);
            else if (item_ == 10001)
            {
                on_money_change(num_);
                save_db();
            }
            else
            {
                item_mgr.addnew(item_, num_, nt);
                bool is_empty = true;
                if (!nt.items.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_wings.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_pet.empty())
                {
                    is_empty = false;
                }
                if (is_empty)
                {                                 
                    logerror((LOG, "con reward items error!"));
                    return ERROR_SC_ILLEGLE_REQ;;
                }
            }
            item_mgr.on_bag_change(nt);
        };
        
        //判断是否符合领取条件
        switch( flag  )
        {
            case 2:         //翅膀阶数
            {
                if(reward.update_wingactivityreward(index))
                    return FAILED;
            } 
            break;

            case 3:         //钻石十连抽
            {
                if (db.draw_reward[pos - 1] == '1')
                {
                    db.draw_reward[pos - 1] = '2'; 
                    db.set_draw_reward(db.draw_reward);
                }
                else
                    return FAILED;
            } 
            break;
            case 4:         //星级数
            {
                if (db.round_stars_reward[pos - 1] == '1')
                {
                    db.round_stars_reward[pos - 1] = '2'; 
                    db.set_round_stars_reward(db.round_stars_reward);
                }
                else
                    return FAILED;
            } 
            break;
            case 8:
            {
                if(reward.db_ext.sevenpay_stage[pos - 1] == '1')
                {
                   reward.db_ext.sevenpay_stage[pos - 1] = '2';
                   reward.db_ext.set_sevenpay_stage(reward.db_ext.sevenpay_stage);
                   reward.save_db_ext();
                }
            }
            break;
        } 
         
        int size = rp_draw_reward->reward.size();
        for (size_t i = 1; i < size; ++i)
        {
            f(rp_draw_reward->reward[i][0], rp_draw_reward->reward[i][1]);
        }
    }

    save_db();
    return SUCCESS;
}

int sc_user_t::change_roletype(int32_t roleindex)
{
    //主角技能id
    const int skill_id[10][3] = {
    {430, 440, 420}, {431, 441, 421}, {432, 442, 422}, {433, 443, 423},
    {436, 444, 424}, {437, 445, 425}, {434, 446, 426}, {435, 447, 427},
    {438, 448, 428}, {439, 449, 429}
    };
    //主角碎片id
    const int chip_id[3] = {30101,30102,30103};
    //职业id
    const int roletype_id[3] = {101, 102, 103};
    
    const int lovetask_id[4][3] = {
    {10101, 10201, 10301}, {10102, 10202, 10302}, {10103, 10203, 10303}, {10104, 10204, 10304}
    };

    
    int32_t yb_ = 500;
    int32_t lv_ = 50;
    if(db.resid == roleindex)
        return ERROR_SC_CHANGEROLE_SANME_ROLE;
    if(db.grade < lv_)
        return ERROR_SC_CHANGEROLE_LV_NOT_ENOUGH;
    if(rmb()< yb_)
        return ERROR_SC_NO_YB;
    consume_yb(yb_);

    int32_t oldindex = db.resid % 100 - 1;
    int32_t newindex = roleindex % 100 - 1;
    skill_mgr.foreach([&](sp_skill_t skl_){
        sc_msg_def::jpk_skill_t skl;
        skl_->get_skill_jpk(skl);
        if (skl_->db.pid == 0)
        {
            for(int skillindex = 0; skillindex <= 9; skillindex++)
            {
                if(skill_id[skillindex][oldindex] == skl_->db.resid)
                {
                   char buf[4096];
                   sprintf(buf,"UPDATE Skill set resid = %d where resid = %d and uid=%d", skill_id[skillindex][newindex],skill_id[skillindex][oldindex], db.uid);
                   db_service.sync_execute(buf);      
                   break;
                }
            } 
        }
    });
    char sqlresid[4096];
    sprintf(sqlresid,"UPDATE UserInfo set resid = %d where resid = %d and uid = %d", roletype_id[newindex],roletype_id[oldindex], db.uid);
    db_service.sync_execute(sqlresid);      
    
    char sqlchip[4096];
    sprintf(sqlchip,"UPDATE PartnerChip set resid = %d where resid = %d and uid = %d", chip_id[newindex],chip_id[oldindex], db.uid);
    db_service.sync_execute(sqlchip);      

    
    for(int32_t index = 0; index <= db.lovelevel && index != 4; index++)
    {
        char sqlloveid[4096];
        sprintf(sqlloveid,"UPDATE LoveTask set resid = %d where resid = %d and uid = %d", lovetask_id[index][newindex],lovetask_id[index][oldindex], db.uid);
        db_service.sync_execute(sqlloveid);      
    }
    team_mgr.update_team_pos(roleindex);
    db.set_kanban(roleindex);
    db.set_model(roleindex);
    save_db();
    return SUCCESS;
}

int sc_user_t::get_user_jpk(sc_msg_def::ret_user_data_t& ret_)
{
    //PERFORMANCE_GUARD("get_user_jpk");

    repo_def::role_t* role = repo_mgr.role.get(db.resid);
    if (role == NULL)
    {
        logerror((LOG, "repo no role id:%d", db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    ret_.uid = db.uid;
    ret_.userguide.isnew = db.isnew;
    ret_.userguide.viptype = reward.db.vip18;
    ret_.userguide.isnewlv = db.isnewlv;
    rank_ins.unicast_rank_infos(db.uid,ret_.userguide.rankinfo);
    ret_.viplevel = db.viplevel;
    ret_.vipexp = db.vipexp;
    ret_.rmb = db.payyb+db.freeyb;
    ret_.name = db.nickname();
    ret_.sceneid= db.sceneid;
    /* 功能及玩法相关数据 */
    /* 1.卡牌活动 */
    card_event.get_user_info(ret_.functions.card_event);
    team_mgr.card_event(ret_.functions.card_event);
    /* 2.combo pro */
    combo_pro_mgr.get_user_info(ret_.functions.combo_pro);
    /* 3.new rune */
    new_rune_mgr.get_rune_list(ret_.functions.rune_info.rune_list);
    new_rune_mgr.get_rune_page(ret_.functions.rune_info.rune_page);
    /* 4.change model */
    ret_.functions.model = db.model;

    ret_.round.roundid= db.roundid;
    ret_.round.elite_roundid = db.elite_roundid;
    ret_.round.caveid= db.caveid;
    ret_.round.eliteid= db.eliteid;
    ret_.round.zodiacid= db.zodiacid;
    ret_.round.stars= db.roundstars();
    ret_.round.elite_round_times= db.elite_round_times();
    ret_.round.elite_reset_times= db.elite_reset_times();
    ret_.round.limit_round_left = db.limitround;
    ret_.round.treasure_reset_num = treasure.get_reset_num();
    // ret_.battexp = db.battlexp;
    ret_.fpoint = db.fpoint;
    /* 竞技场数据 */
    ret_.arena.honor = db.honor;
    ret_.arena.unhonor = db.unhonor;
    ret_.arena.meritorious= db.meritorious;
    ret_.arena.title_lv = db.titlelv;
    /* 远征数据 */
    ret_.expedition.expeditioncoin = db.expeditioncoin;
    ret_.expedition.reset_num = expedition.get_reset_num();
    ret_.soul = db.soul;
    ret_.runechip = db.runechip;
    //ret_.helphero = db.helphero;
    ret_.main_task.questid = db.questid;
    ret_.main_task.nextquestid = db.nextquestid;
    ret_.ggid = gang_mgr.get_ggid_by_uid(db.uid);
    //ret_.first_pub = db.ybflushpub;
    ret_.extra_data.dayofweek = date_helper.cur_dayofweek();
    ret_.extra_data.vip_days = reward.get_vip_days();
    ret_.extra_data.vip_stamp = reward.get_vip_stamp();
    ret_.extra_data.cur_0_stamp = date_helper.cur_0_stmp();
    ret_.extra_data.isSend = feedbackIsSend();
    ret_.extra_data.is_pub_4 = pub_mgr.is_pub_4_first();
    get_last_chat_role_info(ret_.extra_data.last_chat_info);
    ret_.func = db.func;
    ret_.first_pay = db.firstpay;
    /* 编年史数据 */
    ret_.chronicle.chronicle_sum = db.chronicle_sum;
    ret_.chronicle.is_sign = chronicle.is_sign();

    pub_ctl.get_pub_data( *this, ret_.pub );

    ret_.pay_rmb = pay_rmb;
    pay_rmb = 0;

    world_boss.get_startime(ret_.wb_start);

    round_cache.get_pass_round(db.uid,ret_.round.passround);
    round_cache.get_free_flush(*this,db.uid,ret_.round.free_flush_elite,ret_.round.free_flush_zodiac);
    ret_.round.elite_flush = vip.get_num_used(vop_reste_adv_round);
    ret_.round.zodiac_flush = vip.get_num_used(vop_reset_zodiac);
    round_cache.get_zodiac(db.uid,ret_.round.zodiac,ret_.round.cave);
    round.get_halt_info(ret_.round.cur_rid, ret_.round.seconds_need, ret_.round.halt_times, ret_.round.halt_flag, ret_.round.halt_gid);
    ret_.round.cur_fp = helphero_cache.get_helpcount(db.uid);
    ret_.round.expedition_cur_round = expedition.get_cur_round(); 
    ret_.round.expedition_max_round = expedition.get_max_round(); 
    ret_.round.max_treasure = db.treasure;
    treasure.get_cur_floor(ret_.round);
    ret_.round.pass_round_left = new_round.get_left_secs();
	
	ret_.round.pass_cave_left = new_round.get_cave_left_secs();	//lewton
    
    sc_limit_round_mgr.req_user_login_data(db.uid, *this, ret_);

    ret_.money = db.gold;

    gen_power(ret_.left_power_secons, ret_.power);
    gen_energy(ret_.left_energy_secons, ret_.energy);

    ret_.counts.n_friend = frd_request_cache.get_n_request(db.uid);
    ret_.counts.n_pvp = arena.db.fight_count; 
    ret_.counts.n_pray = gang_mgr.get_guser_pray_num(db.uid); 
    ret_.counts.n_gang_req = gang_mgr.get_gang_add_req(db.uid);
    //ret_.counts.n_dtask = daily_task_cache.get_dtask_num(db.uid);
    ret_.counts.n_dtask = 0;
    ret_.counts.soulvalue = soulrank_mgr.db.soulmoney;
    ret_.counts.soulranknum = soulrank_mgr.db.soullevel;
    ret_.counts.soulid      = soulrank_mgr.db.soulid;
    soulrank_mgr.unicast_soul_node_info(ret_.counts.soul_node_infos, soulrank_mgr.db.soulid);
    ret_.counts.n_trial = db.energy;
    ret_.counts.n_gmail_unopend = gmail.get_unopened_num();
    ret_.counts.n_gmail_isrewardEmail = gmail.ishaverewardEmail();
    ret_.counts.n_golden_box = vip.get_num_used(vop_buy_golden_box);
    ret_.counts.n_silver_box = vip.get_num_used(vop_buy_silver_box);
    ret_.counts.n_twoprecord = db.twoprecord;

    // 有关乱斗场的 以前的需求 注掉
    /*
    auto hero = scuffle_mgr.get_hero(db.uid, db.grade); 
    if (hero != NULL)
        ret_.counts.scuffle_hp_percent = hero->hp_percent;
    else
        ret_.counts.scuffle_hp_percent = 1;
    */
    ret_.counts.scuffle_hp_percent = 1;

    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    if (itt != guwu_mgr.user_guwu_map.end())
    {
        sc_user_guwu_t& ug = itt->second;
        for(auto it_ug = ug.begin(); it_ug != ug.end(); it_ug++)
        {
            if (date_helper.offday(it_ug->second.stamp_v)>=1)
            {
                it_ug->second.v = 0;
                it_ug->second.stamp_v = 0;
                it_ug->second.stamp_coin = 0;
                it_ug->second.stamp_yb= 0;
                it_ug->second.progress = 0;
            }
        }
        ret_.counts.n_guwu = ug;
    }else{
        sc_user_guwu_t uug;
        if (0 == guwu_mgr.load_db(db.uid,2,uug,false)){
            //cout<<"user-get_guwu"<<endl;
            guwu_mgr.user_guwu_map.insert(make_pair(db.uid, uug));
            auto itt = guwu_mgr.user_guwu_map.find(db.uid);
            sc_user_guwu_t& ug = itt->second;
            for(auto it_ug = ug.begin(); it_ug != ug.end(); it_ug++)
            {
                if (date_helper.offday(it_ug->second.stamp_v)>=1)
                {
                    it_ug->second.v = 0;
                    it_ug->second.stamp_v = 0;
                    it_ug->second.stamp_coin = 0;
                    it_ug->second.stamp_yb= 0;
                    it_ug->second.progress = 0;
                    guwu_mgr.save_db(db.uid,2,ug);   
                }
            }
            ret_.counts.n_guwu = ug;
        }
    }

    if (date_helper.offday(db.zodiacstamp)>=1)
    {
        round_cache.m_zodiac_hm.erase(db.uid);
    }
    auto it_hpp = round_cache.m_zodiac_hm.find(db.uid);
    if (it_hpp == round_cache.m_zodiac_hm.end())
    {
        ret_.counts.zodiac_hp_percent = 1;
    }
    else
    {
        sc_zodiac_t& z = it_hpp->second;
        ret_.counts.zodiac_hp_percent = z.hp_percent;
    }

    ret_.isinvited = reward.isinvited();
    ret_.bagn = bag.get_size();

    get_jpk_role_data( ret_.role );
    //获取排位赛段位
    if (db.grade >= 20)
        rank_season_s.get_rank(db.uid, ret_.role.season_rank);
    else
        ret_.role.season_rank = 0;

    if (logic.citymgr().get_uid_pos(db.uid, ret_.sceneid, ret_.x, ret_.y))
    {
        ret_.x = -300;
        ret_.y = -100;
    }

    partner_mgr.foreach([&](sp_partner_t partner_){
        sc_msg_def::jpk_role_data_t prole;
        if (0 == partner_->get_partner_jpk(prole))
        {
            ret_.partners.push_back(std::move(prole));
        }
    });

    wing.foreach([&, this](sp_wing_t eqp_){
        sc_msg_def::jpk_wing_t eqp;
        eqp_->get_wing_jpk(eqp);

        if (eqp_->db.isweared == 0)
        {
            ret_.bag.wings.push_back(std::move(eqp));
        }
    });

    equip_mgr.foreach([&, this](sp_equip_t eqp_){

        repo_def::equip_t* reqp = repo_mgr.equip.get(eqp_->db.resid); 
        if (reqp == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", eqp_->db.resid));
            return; 
        }

        sc_msg_def::jpk_equip_t eqp;
        eqp_->get_equip_jpk(eqp);

        if (eqp_->db.isweared == 0)
        {
            ret_.bag.equips.push_back(std::move(eqp));
        }
    });
    
    //清除福袋道具
    reward.clear_lmt_luckybag_data();

    item_mgr.foreach([&, this](sp_item_t item_){
        repo_def::item_t* ritem = repo_mgr.item.get(item_->db.resid); 
        if (ritem == NULL)
        {
            logerror((LOG, "repo no item resid:%d", item_->db.resid));
            return; 
        }

        sc_msg_def::jpk_item_t item;
        item_->get_item_jpk(item);

        ret_.bag.items.push_back(item);
    });
    
    partner_mgr.foreachchip([&,this](sp_partnerchip_t chip_){
        sc_msg_def::jpk_chip_t chip;
        chip.resid = chip_->db.resid;
        chip.count = chip_->db.count;
        ret_.bag.chips.push_back(chip);
    });

    team_mgr.foreachteam([&,this](sp_team_t team_){
        sc_msg_def::jpk_team_t team;
        team_->get_team_jpk(team);
        ret_.team.push_back(std::move(team));
    });

//    rune_cache.get_rmonsters(db.uid,ret_.rmonsters);

    reward.get_jpk(ret_.reward);

    task.get_jpk(ret_.tasks);

    return SUCCESS;
}
void sc_user_t::get_last_chat_role_info(vector<sc_msg_def::last_chat_role_info>& last_chat_info_)
{
    sql_result_t res;
    if (0 == db_ChatUser_t::sync_select_all(db.uid,res)){
        //cout<<"get_last_row_num->"<<res.affect_row_num()<<endl;
        if (res.affect_row_num() > 0){

            char sql[256];
            string str_uid;
            unordered_map<int32_t,int32_t> user_chat;

            for(int32_t index = 0 ; index < res.affect_row_num();index++)                   
            {                                               
                sql_result_row_t& row1 = *res.get_row_at(index);
                db_ChatUser_t chat_db;
                chat_db.init(row1);
                user_chat.insert(make_pair(chat_db.player_uid,chat_db.stmp));
                str_uid.append(std::to_string(chat_db.player_uid)+",");
            }
            str_uid = str_uid.substr(0, str_uid.length()-1);
            //cout<<"get_last_uid->"<<str_uid<<endl;

            sprintf(sql, "select uid,lovelevel,resid,grade,nickname from UserInfo where uid in (%s);", str_uid.c_str());
            db_service.sync_select(sql, res);               
            if (res.affect_row_num() > 0)                   
            {                                               
                //cout<<"get_last_row_num-1->"<<res.affect_row_num()<<endl;
                for(int32_t index = 0 ; index < res.affect_row_num() ; index++){
                    //cout<<"get_last_last_for->"<<index<<endl;
                    sc_msg_def::last_chat_role_info info;
                    sql_result_row_t& row1 = *res.get_row_at(index);
                    info.uid = (int)std::atoi(row1[0].c_str());
                    info.lovelevel = (int)std::atoi(row1[1].c_str());
                    info.resid = (int)std::atoi(row1[2].c_str());
                    info.grade = (int)std::atoi(row1[3].c_str());
                    info.name = row1[4];
                    auto user_chat_it = user_chat.find(info.uid);
                    if(user_chat_it != user_chat.end()){
                        info.stmp = user_chat_it->second;
                    }
                    last_chat_info_.push_back(std::move(info));
                }
            }

        }
    }
}
int sc_user_t::feedbackIsSend()
{
    sql_result_t res;
    if (0 == db_FeedbackFlag_t::sync_select(db.uid,res))
                return 1;
    
    return 0;

}
int sc_user_t::get_pro_jpk(sc_msg_def::jpk_role_pro_t& jpk_)
{
    repo_def::role_t* role = repo_mgr.role.get(db.resid);
    if (role == NULL)
    {
        logerror((LOG, "repo no role id:%d", db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    pro.cal_pro(0, -1, 1);
    pro.copy(jpk_);

    return SUCCESS;
}
int sc_user_t::rmb()
{
    return (db.freeyb+db.payyb);
}

int32_t sc_user_t::up_potential(int32_t flag_,int32_t &delata_,int32_t &current_, int32_t &attribute)
{
    sc_msg_def::ret_potential_up_t ret;
    ret.pid = 0;
    delata_ = current_ = 0;

    if( flag_!=1 && flag_!=2 )
    {
        logerror((LOG, "on_user_up_potential, illegal flag:%d", flag_));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    //当前潜能是否已经达到上限
    auto it = repo_mgr.potential_caps.find(db.grade);
    if( it == repo_mgr.potential_caps.end() )
    {
        logerror((LOG, "on_user_up_potential, repo no quality:%d", db.grade));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    int32_t cap = it->second.caps;

    int* potential;
    switch(attribute)
    {
        case 1:
        {
            potential = &db.potential_1;
            break;
        }
        case 2:
        {
            potential = &db.potential_2;
            break;
        }
        case 3:
        {
            potential = &db.potential_3;
            break;
        }
        case 4:
        {
            potential = &db.potential_4;
            break;
        }
        case 5:
        {
            potential = &db.potential_5;
            break;
        }
        default:
        {
            potential = &db.potential_1;
            break;
        }
    }

    if( cap <= *potential )
    {
        logerror((LOG, "on_user_up_potential, potential max:%d", *potential));
        ret.code = ERROR_SC_POTENTIAL_CAP;
        logic.unicast(db.uid, ret);
        return ERROR_SC_POTENTIAL_CAP;
    }

    //材料是否足够
    auto rp_partner = repo_mgr.role.get(db.resid);

    int32_t idx_offset = rp_partner->job * 100;
    auto rp_potential = repo_mgr.potential.get(idx_offset + attribute);

    int32_t resid_drag = rp_potential->consume;
    /*if( 1==flag_ )
        resid_drag = RESID_POTENTIAL_DRAG ;
    else
        resid_drag = RESID_SUPER_POTENTIAL_DRAG ;
    */
    //消耗材料公式
    int num;
    if (*potential <= 20)
    {
        num = int(floor(10*pow(1.055,*potential+1) + pow((*potential+1),1.5)));
    }
    else
    {
        num = int(floor(10*pow(1.055,*potential+1) + pow((*potential+1),1.575)));
    }

    if( !item_mgr.has_items(resid_drag,num) )
    {
        logerror((LOG, "on_user_up_potential,bag no material,mat id:%d", resid_drag));
        ret.code = ERROR_SC_NOT_ENOUGH_MATERIAL;
        logic.unicast(db.uid, ret);
        return ERROR_SC_NOT_ENOUGH_MATERIAL;
    }

    //扣去材料
    sc_msg_def::nt_bag_change_t nt;
    item_mgr.consume(resid_drag, num,  nt);
    item_mgr.on_bag_change(nt);

    //产生随机潜力变化
    /*
    auto it_hm = repo_mgr.potential_upgrade.find(db.potential+1);
    if( it_hm == repo_mgr.potential_upgrade.end() )
    {
        logerror((LOG, "on_user_up_potential,repo no potential,:%d", db.potential+1));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    vector<int32_t> probab ;
    if( 1==flag_ )
        probab = it_hm->second.normal_success_rate;
    else
        probab = it_hm->second.super_success_rate;

    if( 3!=probab.size() )
    {
        logerror((LOG, "on_user_up_potential,repo exception,potential_upgrade"));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    int32_t delta = 0;
    if( ((db.isnew) & (1<<evt_guidence_potential))==0 )
    {
        delta = 1;
        guidence_ins.on_guidence_event(*this,evt_guidence_potential);
    }
    else
    {
        int32_t r = random_t::rand_integer(1, 10000);
        if( r<=probab[2] )
        {
            //暴击
            delta = 2;
        }
        else
        {
            if( r<=probab[1] )
            {
                //普通
                delta = 1;
            }
            else
            {
                //失败
                if( (1==flag_) && (db.potential>0) )
                    delta = -1;
            }
        }
    }

    if( (db.potential + delta ) > cap )
        delta = cap - db.potential;
    */

    *potential += 1;
    switch(attribute)
    {
        case 1:
        {
            db.set_potential_1(*potential);
            break;
        }
        case 2:
        {
            db.set_potential_2(*potential);
            break;
        }
        case 3:
        {
            db.set_potential_3(*potential);
            break;
        }
        case 4:
        {
            db.set_potential_4(*potential);
            break;
        }
        case 5:
        {
            db.set_potential_5(*potential);
            break;
        }
    }

    //计算属性变化
    save_db();
    
    get_pro_jpk(ret.pro);

    ret.code = SUCCESS;
    int delta = 1;
    ret.delta = delta;
    logic.unicast(db.uid, ret);

    delata_ = delta;
    current_ = *potential;

    //更新洗礼的日常任务
    daily_task.on_event(evt_up_potential);

    return SUCCESS;
}
void sc_user_t::on_pro_changed(int pid_)
{
    sc_msg_def::nt_role_pro_change_t nt;
    if (pid_ == 0)
    {
        nt.pid = 0;
        get_pro_jpk(nt.pro);
        logic.unicast(db.uid, nt);
    }
    else
    {
        sp_partner_t p=partner_mgr.get(pid_);
        if( p != NULL )
        {
            p->on_pro_changed();
        }
    }

}
void sc_user_t::on_pro_changed_multiple(vector<int32_t>& pid_list_)
{
    int32_t count = 0;
    sc_msg_def::nt_role_pros_change_t nt;
    for(auto partner=pid_list_.begin(); partner!=pid_list_.end(); ++partner)
    {
        count++;
        sc_msg_def::nt_role_pro_change_t nt_pro;
        if (*partner == 0)
        {
            nt_pro.pid = 0;
            get_pro_jpk(nt_pro.pro);
            nt.pro_list.push_back(nt_pro);
        }
        else
        {
            sp_partner_t p=partner_mgr.get(*partner);
            if( p != NULL )
            {
                p->gen_pro(nt_pro);
                nt.pro_list.push_back(nt_pro);
            }
        }
    }
    if (count > 0)
        logic.unicast(db.uid, nt);
}

int sc_user_t::cal_total_fp()
{
    sc_msg_def::nt_role_pro_change_t nt;
    int fp = 0;
    for(size_t i=0;i<5;++i)
    {
        if( 0 > team_mgr[i] )
            continue;

        if( 0==team_mgr[i] )
        {
            pro.cal_pro(0, -1, 1);
            fp += pro.get_fp();

            nt.pid = 0;
            get_pro_jpk(nt.pro);
            logic.unicast(db.uid, nt);
            continue;
        }

        sp_partner_t p=partner_mgr.get(team_mgr[i]);
        if( p != NULL )
        {
            p->pro.cal_pro(p->db.pid, -1, 1);
            fp += p->pro.get_fp();

            nt.pid = p->db.pid;
            p->get_pro_jpk(nt.pro);
            logic.unicast(db.uid, nt);
        }
    }

    db.fp = fp ;
    save_db();
    return fp;
}

int sc_user_t::get_total_fp()
{
    
    int fp = 0;
    for(size_t i=0;i<5;++i)
    {
        if( 0 > team_mgr[i] )
            continue;

        if( 0==team_mgr[i] )
        {
            if (pro.get_fp() == 0)
                pro.cal_pro(0, -1, 1);
            fp += pro.get_fp();
            continue;
        }

        sp_partner_t p=partner_mgr.get(team_mgr[i]);
        if( p != NULL )
        {
            if (p->pro.get_fp() == 0)
                p->pro.cal_pro(p->db.pid, -1, 1);
            fp += p->pro.get_fp();
        }
    }

    db.fp = fp ;
    save_db();
    return fp;
}

int sc_user_t::get_max_5_fp()
{
    vector<int> fp_list;
    if (pro.get_fp() == 0)
        pro.cal_pro(0, -1, 1);
    fp_list.push_back(pro.get_fp());
    partner_mgr.foreach([&fp_list](sp_partner_t partner_){
        if (partner_->pro.get_fp() == 0)
            partner_->pro.cal_pro(partner_->db.pid, -1, 1);
        fp_list.push_back(partner_->pro.get_fp());
    });

    int fp = 0;
    if ( fp_list.size() <= 5)
    {
        for(auto it=fp_list.begin(); it!=fp_list.end(); ++it)
        {
            fp += *it;
        }
    }
    else
    {
        // 找出战斗力最大的5个人
        std::sort(fp_list.begin(), fp_list.end(), greater<int>());
        for (int i=0;i<5;++i)
            fp += fp_list[i];
    }
    return fp;
}

void sc_user_t::on_team_pro_changed()
{
    vector<int32_t> pid_list;
    pid_list.push_back(0);
    partner_mgr.foreach([&](sp_partner_t partner_){
        pid_list.push_back(partner_->db.pid);
    });
    on_pro_changed_multiple(pid_list);
}
int sc_user_t::consume_gold(int gold_)
{
    if (-gold_ >= 0)
    {
        logerror((LOG, "consume_gold error! gold:%d", gold_));
        return -1;
    }

    return on_money_change(-gold_);
}
int sc_user_t::consume_yb(int yb_)
{
    if (-yb_ >= 0)
    {
        logerror((LOG, "consume_yb error! yb_:%d", yb_));
        return -1;
    }

    //开服消费钻石活动
    reward.update_openybtotal(yb_);
    //元宝足够，先扣收费元宝，再扣免费元宝
    if( db.payyb >= yb_)
    {
        on_payyb_change(-yb_);
        return yb_;
    }
    else
    {
        on_allyb_change(-db.payyb, db.payyb-yb_);
        return db.payyb;
    }
}
int sc_user_t::consume_expeditioncoin(int32_t expeditioncoin_)
{
    if (-expeditioncoin_ >= 0)
    {
        logerror((LOG, "consume_expeditioncoin error! expeditioncoin_:%d", expeditioncoin_));
        return -1;
    }
    return on_expeditioncoin_change(-expeditioncoin_);
}
int sc_user_t::fpoint()
{
    return db.fpoint;
}
int sc_user_t::honor()
{
    return db.honor;
}
int sc_user_t::unhonor()
{
    return db.unhonor;
}

int sc_user_t::meritorious()
{
    return db.meritorious;
}
int sc_user_t::consume_fpoint(int v_)
{
    if (-v_ >= 0)
    {
        logerror((LOG, "consume_fpoint error! v_:%d", v_));
        return -1;
    }
    return on_fpoint_change(-v_);
}

int sc_user_t::consume_honor(int v_)
{
    if (-v_ >= 0)
    {
        logerror((LOG, "consume_honor error! v_:%d", v_));
        return -1;
    }
    return on_honor_change(-v_);
}


int sc_user_t::consume_unhonor(int v_)
{
    if (-v_ >= 0)
    {
        logerror((LOG, "consume_unhonor error! v_:%d", v_));
        return -1;
    }
    return on_unhonor_change(-v_);
}

void sc_user_t::save_db_userid()
{
    db_service.async_do((uint64_t)db.uid, [](int32_t uid_, int grade_, int viplevel_){
        char buf[256];
        sprintf(buf, "update UserID set grade=%d, viplevel=%d where uid=%d", grade_, viplevel_, uid_);
        db_service.async_execute(buf);
    }, db.uid, db.grade, db.viplevel);
}
int sc_user_t::on_guwu(int flag_, int yb_, int coin_)
{
    if (flag_ < 1 || flag_ > 3)
        return -1;

    auto it = guwu_mgr.user_guwu_map.find(db.uid);
    if (it == guwu_mgr.user_guwu_map.end()){
        guwu_mgr.user_guwu_map.insert(make_pair(db.uid, sc_user_guwu_t()));
        if (flag_ == 2){
            auto itt = guwu_mgr.user_guwu_map.find(db.uid);
            guwu_mgr.load_db(db.uid,flag_,itt->second,true);
        }
    }

    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    sc_user_guwu_t& guwu_map = itt->second; 
    if (coin_ == 30000)
    {
        if (db.gold < coin_)
            return ERROR_SC_NO_GOLD;
        //if (date_helper.offsec(guwu_map[flag_].stamp_coin) <= 120)
        //    return -1;
        if (guwu_map[flag_].progress >= 100)
            return ERROR_GUWU_PROGRESS_HAS_FULL;
        repo_def::boss_up_t* rp_boss_up = repo_mgr.boss_up.get(guwu_map[flag_].progress+1);
        if (rp_boss_up == NULL)
            return -1;
        if (rp_boss_up->pro2 == 0 || random_t::rand_integer(1, 100) > rp_boss_up->pro2)
            return ERROR_GUWU_FAILED;

        guwu_map[flag_].progress += random_t::rand_integer(rp_boss_up->range2[1], rp_boss_up->range2[2]);
        if (guwu_map[flag_].progress >= 100)
            guwu_map[flag_].progress = 100;

        consume_gold(coin_);
        save_db();
        guwu_map[flag_].v = rp_boss_up->factor;
        guwu_map[flag_].stamp_v = date_helper.cur_sec();
        guwu_map[flag_].stamp_coin = date_helper.cur_sec();
        if (flag_ == 2){
            guwu_mgr.save_db(db.uid,flag_,guwu_map);
        }
    }
    else if (yb_ == 50)
    {
        if (rmb() < yb_)
            return ERROR_SC_NO_YB;
        //if (date_helper.offsec(guwu_map[flag_].stamp_yb <= 120))
        //   return -1;
        if (guwu_map[flag_].progress >= 100)
            return ERROR_GUWU_PROGRESS_HAS_FULL;
        repo_def::boss_up_t* rp_boss_up = repo_mgr.boss_up.get(guwu_map[flag_].progress+1);
        if (rp_boss_up == NULL)
            return -1;
        if (rp_boss_up->pro1 == 0 || random_t::rand_integer(1, 100) > rp_boss_up->pro1)
            return ERROR_GUWU_FAILED;

        guwu_map[flag_].progress += random_t::rand_integer(rp_boss_up->range1[1], rp_boss_up->range1[2]);
        if (guwu_map[flag_].progress >= 100)
            guwu_map[flag_].progress = 100;

        consume_yb(yb_);
        save_db();
        guwu_map[flag_].v = rp_boss_up->factor;
        guwu_map[flag_].stamp_v = date_helper.cur_sec();
        guwu_map[flag_].stamp_yb = date_helper.cur_sec();
        if (flag_ == 2){
            guwu_mgr.save_db(db.uid,flag_,guwu_map);
        }
    }

    return SUCCESS;
}
float sc_user_t::get_guwu_v(int flag_)
{
    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    if (itt != guwu_mgr.user_guwu_map.end())
    {
        if (itt->second.find(flag_) == itt->second.end())
            return 0;
        return itt->second[flag_].v;
    }
    return 0;
}
sc_guwu_t* sc_user_t::get_guwu(int flag_)
{
    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    if (itt != guwu_mgr.user_guwu_map.end())
    {
        if (itt->second.find(flag_) == itt->second.end())
            return NULL;
        return &(itt->second[flag_]);
    }
    return NULL;
}
int sc_user_t::update_guwu(int flag_, uint32_t b_, uint32_t e_)
{
    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    if (itt != guwu_mgr.user_guwu_map.end())
    {
        if (b_ <= itt->second[flag_].stamp_v && itt->second[flag_].stamp_v <= e_)
            return itt->second[flag_].v;
        else {
            itt->second.erase(flag_);
            if (flag_ == 2){
                guwu_mgr.delete_db(db.uid);
            }
        }
    }
    return 0;
}
void sc_user_t::remove_guwu(int flag_)
{
    auto itt = guwu_mgr.user_guwu_map.find(db.uid);
    if (itt != guwu_mgr.user_guwu_map.end())
    {
        itt->second.erase(flag_);
        if (2 == flag_){
            guwu_mgr.delete_db(db.uid);
        }
    }
}
void sc_user_t::update_sign_info()
{
    time_t tp;
    time(&tp);
    struct tm* p = localtime(&tp);
    if(p->tm_mon != db.sign_month)
    {
        db.sign_daily = 0;
        db.sign_cost = 0;
        db.sign_month = p->tm_mon;
        db.set_sign_month(db.sign_month);
        db.set_sign_cost(db.sign_cost);
        db.set_sign_daily(db.sign_daily);
    }
}
void sc_user_t::add_new_mail()
{
    
    string msg = mailinfo.new_mail(mail_open_reward1); 
    if (!msg.empty())
    {
        auto rp_gmail = mailinfo.get_repo(mail_open_reward1);
        if (rp_gmail != NULL)
        {
            sp_user_t user;
            if (logic.usermgr().get(db.uid, user))
            {
                sc_msg_def::nt_bag_change_t nt;
                sc_msg_def::jpk_item_t itm;
                itm.itid = 0;
                itm.resid = 10003;
                itm.num = 1800;
                nt.items.push_back(itm);
                itm.resid = 30017;
                itm.num = 80;
                nt.items.push_back(itm);
                user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
            }
        }
    }
    
    string msg1 = mailinfo.new_mail(mail_open_reward2); 
    if (!msg1.empty())
    {
        auto rp_gmail = mailinfo.get_repo(mail_open_reward2);
        if (rp_gmail != NULL)
        {
            sp_user_t user;
            if (logic.usermgr().get(db.uid, user))
            {
                sc_msg_def::nt_bag_change_t nt;
                sc_msg_def::jpk_item_t itm;
                itm.itid = 0;
                itm.resid = 10003;
                itm.num = 500;
                nt.items.push_back(itm);
                user->gmail.send(rp_gmail->title, rp_gmail->sender, msg1, rp_gmail->validtime, nt.items); 
            }
        }
    }


}

int32_t sc_user_t::gen_inheritance_code(sc_msg_def::ret_gen_inheritance_code_t& ret_)
{
    char str[10];
    sprintf(str, "%d", db.aid);
    string lastcode7 = str;
    string buff = "0000000"+lastcode7;
    lastcode7 = buff.substr(buff.length()-7);

    char arr[9];
    int32_t num;
    for (int32_t i=0; i<9; ++i)
    {
        num = rand()%10;                
        arr[i] = '0'+num;
    }

    string s;
    for (int32_t i=0; i<9; ++i)
    {
        s += arr[i];
    }
    ret_.inheritance_code = s+lastcode7;

    /*
    char sql[256];
    sprintf(sql, "UPDATE Account SET code=%s WHRRE aid=%d;", ret_.inheritance_code.c_str(), db.aid);
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
    */
    db_service.async_do((uint64_t)db.uid, [](string code_, int aid_){
        char sql[256];
        sprintf(sql, "UPDATE `niceshot_jp`.`Account` SET code='%s' WHERE aid=%d;", code_.c_str(), aid_);
        db_service.async_execute(sql);
    }, ret_.inheritance_code, db.aid);
    return SUCCESS;
}

int32_t sc_user_t::get_model(sc_msg_def::ret_model_t& ret_)
{
    ret_.model = db.model;
    return SUCCESS;
}

int32_t sc_user_t::change_model(sc_msg_def::ret_change_model_t& ret_, int32_t new_model_)
{
    if (new_model_ != db.resid)
    {
        repo_def::skin_t* rp_skin = repo_mgr.skin.get(new_model_);
        if (rp_skin == NULL)
            return ERROR_MODEL_NO_SUCH_MODEL;
        if (rp_skin->type == 2)
        {
            sp_partner_t p=partner_mgr.getbyresid(int((new_model_%100000)/100));
            if (p == NULL)
            {
                return ERROR_MODEL_NO_PARTNER;
            }
        }
        else if (rp_skin->type == 3)
        {
            int role_id = int((new_model_%100000)/100);
            int item_id = 0;
            if (role_id == 101 || role_id == 102 || role_id == 103)
                item_id = 5000000 + MAIN_HERO_SKIN*100 + new_model_%100;
            else
                item_id = new_model_;                
            
            if (!item_mgr.has_items(item_id, 1))
                return ERROR_MODEL_HAVE_NO_SUCH_MODEL;
        }

    }

    db.model = new_model_;
    db.set_model(new_model_);
    save_db();

    ret_.model = new_model_;
    return SUCCESS;
}
//=====================================================
sc_user_mgr_t::sc_user_mgr_t()
{
}
void sc_user_mgr_t::on_session_broken(int32_t uid_)
{
    this->erase(uid_);
}
bool sc_user_mgr_t::get(const int32_t& uid_, sp_user_t& sp_user_)
{
    auto it = m_user_hm.find(uid_);
    if (it != m_user_hm.end())
    {
        sp_user_ = it->second;
        return true;
    }
    return false;
}
void sc_user_mgr_t::broadcast(int32_t cmd_,const string &msg_)
{
    for(auto it=m_user_hm.begin();it!=m_user_hm.end();++it)
    {
        logic.unicast(it->first, cmd_, msg_);
    }
}
bool sc_user_mgr_t::has(const int32_t& uid_)
{
    return (m_user_hm.find(uid_) != m_user_hm.end());
}
