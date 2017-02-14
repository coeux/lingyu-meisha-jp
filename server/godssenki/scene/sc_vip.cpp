#include "sc_vip.h"
#include "repo_def.h"
#include "date_helper.h"
#include "sc_logic.h"
#include "sc_push_def.h"
#include "sc_statics.h"
#include "code_def.h"

#define LOG "SC_VIP"

string vip_shop_name[]={
    "体力",
    "开启关卡挂机",
    "挂机时间",
    "加速战斗",
    "重置精英关卡",
    "增加背包上限",
    "训练场位置3开放",
    "加速训练",
    "竞技场次数",
    "活力",
    "王者训练",
    "重置十二宫",
    "符文召唤",
    "体力赠送",
    "炼金",
    "酒馆刷新",
    "酒馆至尊刷新",
    "重置日常任务",
    "公会捐献",
    "世界boss再战",
    "永久增加100背包上限",
    "刷新星魂",
    "试炼刷新对手",
    "普通挂机清除CD",
    "升阶材料购买",
    "重置英雄迷窟",
};

sc_vip_t::sc_vip_t(sc_user_t& user_):m_user(user_)
{
    memset(&m_record, 0, sizeof(m_record));
}
sc_vip_t::~sc_vip_t()
{
}
void sc_vip_t::init_db()
{
}
void sc_vip_t::load_db()
{
    sql_result_t res;
    db_Vip_t::sync_select(m_user.db.uid, res);
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
            continue;
        db_Vip_t db;
        db.init(*res.get_row_at(i));
        memcpy(&m_record[db.vop], &db, sizeof(db));
    }
}
void sc_vip_t::on_login()
{
    for(int i=0; i<vop_num; i++)
    {
        db_Vip_t& record = m_record[i];
        if (record.uid > 0 && date_helper.offday(record.stamp) >= 1)
        {
            record.stamp = date_helper.cur_sec();
            record.num = 0;
        }
    }
}
bool sc_vip_t::enable_do(int flag_)
{
    repo_def::vip_open_t* rp_vo = repo_mgr.vip_open.get(flag_);
    if( rp_vo == NULL )
        return false;
    return (m_user.db.viplevel >= rp_vo->viplv);
}
int sc_vip_t::get_num(int flag_)
{
    repo_def::vip_t* rp_vcg = repo_mgr.vip.get(m_user.db.viplevel);
    if (rp_vcg == NULL)
    {
        logerror((LOG, "repo vip no level:%d", m_user.db.viplevel));
        return -1;
    }
    switch(flag_)
    {
        case vop_buy_power:                 //购买体力
            return 99999;
            break;
        case vop_reste_adv_round:           //重置精英关卡
            return rp_vcg->reset_elite;
            break;
        case vop_buy_fight_count:           //天梯挑战次数
            return rp_vcg->buy_ladder;
            break;
        case vop_buy_trial_energy:          //试炼活力购买次数
            return rp_vcg->buy_train;
            break;
        case vop_reset_zodiac:              //十二宫重置进度次数
            return rp_vcg->reset_zodiac;
            break;
        case vop_rune_cost:                 //符文召唤怪物次数
            return rp_vcg->summon_rune;
            break;
        case vop_do_buy_money:              //炼金次数
            return 99999;
            break;
        case vop_reset_daily_task:          //重置日常任务次数
            return rp_vcg->reset_mission;
            break;
        case vop_flush_star:                //水晶刷新星魂
            return rp_vcg->refresh_star;
            break;
        case vop_flush_cave:                //英雄迷窟
            return rp_vcg->reset_miku;
            break;
        case vop_buy_golden_box:          //黄金宝箱
            return rp_vcg->reset_golden_box;
            break;
        case vop_buy_silver_box:          //白银宝箱
            return rp_vcg->reset_silver_box;
            break;
        default:
            logwarn((LOG, "repo vip no flag:%d", flag_));
    }
    return -1;
}
void sc_vip_t::compensate_vip(int viplevel_)
{
    repo_def::vip_t* rp_vcg = NULL;
    if((rp_vcg = repo_mgr.vip.get(viplevel_))==NULL)
        return;
    m_user.db.set_vipexp(rp_vcg->pay);
    m_user.reward.on_vip_upgrade(viplevel_,1);
    m_user.db.set_viplevel(viplevel_);
}
int sc_vip_t::on_exp_change(int exp_,int slience_)
{
    int viplevel = m_user.db.viplevel;
    repo_def::vip_t* rp_vcg = NULL;
    while((rp_vcg = repo_mgr.vip.get(viplevel+1))!=NULL)
    {
        if ((m_user.db.vipexp+exp_) < rp_vcg->pay)
            break;

        viplevel++;
    }

    //处理经验改变
    {
        m_user.db.set_vipexp(m_user.db.vipexp + exp_);
        if( !slience_ )
        {
            sc_msg_def::nt_vip_exp_changed_t nt;
            nt.now = m_user.db.vipexp;
            logic.unicast(m_user.db.uid, nt);
        }
    }

    //处理升级
    if (m_user.db.viplevel < viplevel)
    {   
        int oldviplevel = m_user.db.viplevel;
        //判断周礼包是否领取另一档
        int id1 = 0, id2 = 0;
        auto item_info1 = repo_mgr.weekly.begin();
        while(item_info1 != repo_mgr.weekly.end())
        {
           if (oldviplevel >= item_info1->second.VIP[1] && oldviplevel <= item_info1->second.VIP[2])
           {
               id1 = item_info1->second.id;
               break;
           }
           ++item_info1;
        }
        auto item_info2 = repo_mgr.weekly.begin();
        while(item_info2 != repo_mgr.weekly.end())
        {
           if (viplevel >= item_info2->second.VIP[1] && viplevel <= item_info2->second.VIP[2])
           {
               id2 = item_info2->second.id;
               break;
           } 
           ++item_info2;
        }
        if(id2 > id1)
            m_user.reward.db.set_week_reward(1);
        //处理升级奖励
        m_user.reward.on_vip_upgrade(viplevel,slience_);

        m_user.db.set_viplevel(viplevel);

        if( viplevel >= 6 )
            pushinfo.new_push(push_vip,m_user.db.nickname(),m_user.db.grade,m_user.db.uid,m_user.db.viplevel,viplevel);

        sc_msg_def::nt_vip_levelup_t nt;
        nt.now= m_user.db.viplevel;
        nt.week_reward = m_user.reward.db.week_reward;
        logic.unicast(m_user.db.uid, nt);
    }

    m_user.save_db();

    //触发首次充值和累计充值
    //m_user.reward.cast_yb(slience_);

    return m_user.db.viplevel;
}
int sc_vip_t::need_yb(int flag_, int cd_)
{
    db_Vip_t& record = m_record[flag_];
    if (record.stamp == 0)
    {
        record.stamp = date_helper.cur_sec();
    }
    else if (date_helper.offday(record.stamp) >= 1)
    {
        record.stamp = date_helper.cur_sec();
        record.num = 0;
    }

    try 
    {
        if (cd_ == 0)
            return logic.lua().prt()->call<int>("vip_need_yb", flag_, record.num+1);
        else
            return logic.lua().prt()->call<int>("vip_need_yb", flag_, cd_);
    }
    catch(exception& e_) 
    {   
        logerror((LOG, "do_script exe failed<%s>\n", e_.what()));
    }

    return -1;
}
int sc_vip_t::buy_vip(int flag_, int cd_)
{
    if (!enable_do(flag_))
    {
        logerror((LOG, "viplevel not enough:%d",flag_));
        return ERROR_SC_NOT_ENOUGH_VIP;
    }

    db_Vip_t& record = m_record[flag_];
    int maxnum = get_num(flag_);
    int curnum = 0;
    if( cd_ != 0 )
        //英雄魔窟重置时，次数由外面传入，比实际次数多一
        curnum = cd_-1;
    else
        curnum = record.num;

    if (maxnum > 0 && maxnum <= curnum)
    {
        logerror((LOG, "no left count:%d,%d",maxnum,record.num));
        return ERROR_SC_NOT_ENOUGH_VIP;
    }

    int yb = need_yb(flag_, cd_);
    if (yb < 0)
        return ERROR_SC_EXCEPTION;

    int32_t payyb;
    if (m_user.rmb() >= yb)
    {
        payyb = m_user.consume_yb(yb);
        m_user.save_db();
    }
    else
        return ERROR_SC_NO_YB;

    //生成购买记录
    statics_ins.unicast_buylog(m_user,flag_,vip_shop_name[flag_-1],1,1,yb,payyb,yb-payyb,0);

    record.num++;

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Vip_t& db_){
            db_.update();
    }, record);

    return SUCCESS; 
}
int sc_vip_t::update_vip_recordn(int flag_, int recordn_)
{
    db_Vip_t& record = m_record[flag_];

    record.num += recordn_;

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Vip_t& db_){
            db_.update();
    }, record);

    return SUCCESS; 
}
int sc_vip_t::get_num_count(int flag_)
{
    update_num(flag_);
    db_Vip_t& record = m_record[flag_];
    int maxnum = get_num(flag_);
    if (maxnum > 0 )
    {
        maxnum -= record.num;
        if (maxnum < 0)
            maxnum = 0;
        return maxnum;
    }
    if (flag_ == vop_immedia_fight_wboss)
        return record.num;
    return 0;
}
int sc_vip_t::get_num_used(int flag_)
{
    update_num(flag_);
    return m_record[flag_].num;
}
void sc_vip_t::update_num(int flag_)
{
    db_Vip_t& record = m_record[flag_];

    bool changed = false;
    if (record.stamp == 0)
    {
        record.stamp = date_helper.cur_sec();
        changed = true;
    }
    else if (date_helper.offday(record.stamp) >= 1)
    {
        record.stamp = date_helper.cur_sec();
        record.num = 0;
        changed = true;
    }

    if (record.uid==0)
    {
        record.uid = m_user.db.uid;
        record.vop = flag_;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Vip_t& db_){
            db_.insert();
        }, record);
    }
    else if (changed)
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Vip_t& db_){
            db_.update();
        }, record);
    }
}
