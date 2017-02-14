#include "sc_partner.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_pub.h"
#include "sc_statics.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "sc_fp_rank.h"
#include "sc_push_def.h"
#include "math.h"

#define LOG "SC_PARTNER"

#define RESID_POTENTIAL_DRAG 15001
#define RESID_SUPER_POTENTIAL_DRAG 15002

sc_partner_t::sc_partner_t(sc_user_t& user_):
    pro(user_),
    m_user(user_)
{
}

int sc_partner_t::on_quality_change()
{
    //获取伙伴升阶需要的材料
    int32_t id = db.resid*10 + db.quality + 1 + 1;
    auto it_hm = repo_mgr.qualityup_staff.find(id);
    if( it_hm == repo_mgr.qualityup_staff.end() )
    {
        logerror((LOG, "on_quality_change,repo no qualityup staff, pid:%d", db.pid));
        sc_msg_def::ret_quality_up_t ret;
        ret.pid = db.pid;
        ret.code = ERROR_UPGRADE_MAX_LV;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_UPGRADE_MAX_LV;
    }

    //判断材料是否足够
    if( (m_user.partner_mgr.get_now_piece_count(db.resid)<it_hm->second.var1) || (m_user.db.soul<it_hm->second.var2) || (m_user.db.gold < it_hm->second.var3) )
     {
        logerror((LOG, "on_quality_change,bag not enough material, pid:%d", db.pid));
        sc_msg_def::ret_quality_up_t ret;
        ret.pid = db.pid;
        ret.code = ERROR_SC_NOT_ENOUGH_MATERIAL;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_NOT_ENOUGH_MATERIAL;
    }       

    //扣去背包中的材料，通知客户端背包改变
    sc_msg_def::nt_chip_change_t change;
    int32_t chip_resid = pub_ctl.get_chip_resid(db.resid);
    if( !m_user.partner_mgr.consume_chip(chip_resid,it_hm->second.var1,change) )
        return ERROR_SC_EXCEPTION;
    m_user.partner_mgr.on_chip_change(change);
    m_user.on_soul_change( -(it_hm->second.var2) );
    m_user.on_money_change( -(it_hm->second.var3) );
    m_user.save_db();

    //伙伴升阶
    db.set_quality(db.quality + 1);
    save_db();
    m_user.skill_mgr.update_skill_level(db.pid,db.quality,db.resid);
    
    //通知客户端伙伴属性改变
    on_pro_changed();
    
    //成就任务更改
    m_user.achievement.on_event(evt_rankup_lv, 1);
    sc_msg_def::ret_quality_up_t ret;
    ret.pid = db.pid;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    
    //记录事件
    statics_ins.unicast_eventlog(m_user,ret.cmd(),db.pid);

    return SUCCESS;
}

void sc_partner_t::on_lovevalue_change(int32_t lovevalue)
{
    auto love_info = repo_mgr.love_task.get(db.resid * 100 + db.lovelevel + 1);
    if (love_info != NULL)
    {
        if( (db.lovevalue + lovevalue) >= love_info->love_max)
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
}
int sc_partner_t::on_exp_change(int32_t exp_)
{
    int32_t is_exp_change=0, is_grade_change=0;
    int32_t old = db.grade;
    if( (db.exp+exp_)>=m_user.db.exp )
    {
        if( db.exp!=m_user.db.exp )
        {
            is_exp_change = 1;
            db.set_exp(m_user.db.exp);
        }
        if( db.grade!=m_user.db.grade )
        {
            is_grade_change = 1;
            db.set_grade(m_user.db.grade);
        }
    }
    else
    {
        int grade = db.grade;
        repo_def::levelup_t* rp_lvup = NULL;
        while((rp_lvup = repo_mgr.levelup.get(grade))!=NULL)
        {
            if ((db.exp+exp_) < rp_lvup->exp)
                break;

            grade++;
        }

        if( grade != db.grade )
        {
            is_grade_change = 1;
            db.set_grade(grade);
        }
        is_exp_change = 1;
        db.set_exp(db.exp+exp_);
    }

    //通知经验改变
    if( is_exp_change )
    {
        sc_msg_def::nt_exp_change_t nt;
        nt.pid = db.pid;
        nt.now = db.exp;
        logic.unicast(m_user.db.uid, nt);
    }

    //升级!!!
    if( is_grade_change )
    {
        //通知角色属性改变
        on_pro_changed();
        sc_msg_def::nt_levelup_t nt_lv;
        nt_lv.pid = db.pid;
        nt_lv.level = db.grade;
        logic.unicast(m_user.db.uid, nt_lv);
        //记录事件
        statics_ins.unicast_eventlog(m_user,nt_lv.cmd(),db.pid,old,0,nt_lv.level);
    }
    return db.grade;
}
int sc_partner_t::get_partner_jpk(sc_msg_def::jpk_role_data_t& jpk_)
{
    jpk_.pid = db.pid;
    jpk_.resid = db.resid;

    pro.cal_pro(db.pid);
    pro.copy(jpk_.pro);

    jpk_.lvl.level = db.grade;
    jpk_.lvl.exp = db.exp;
    jpk_.lvl.lovelevel = db.lovelevel;

    jpk_.quality = db.quality;
    jpk_.lovevalue = db.lovevalue;
    jpk_.potential_1 = db.potential_1;
    jpk_.potential_2 = db.potential_2;
    jpk_.potential_3 = db.potential_3;
    jpk_.potential_4 = db.potential_4;
    jpk_.potential_5 = db.potential_5;
    jpk_.naviClickNum1 = db.naviClickNum1;
    jpk_.naviClickNum2 = db.naviClickNum2;

    int slot = 1;
    m_user.equip_mgr.foreach([&](sp_equip_t eqp_){

        repo_def::equip_t* reqp = repo_mgr.equip.get(eqp_->db.resid);
        if (reqp == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", eqp_->db.resid));
            return;
        }

        if (jpk_.pid == eqp_->db.pid && eqp_->db.isweared)
        {
            sc_msg_def::jpk_equip_t eqp;
            eqp_->get_equip_jpk(eqp);
            jpk_.equips.insert(std::move(make_pair(slot, std::move(eqp))));
            slot++;
        }
    });

    m_user.skill_mgr.foreach([&](sp_skill_t skl_){
        if (jpk_.pid == skl_->db.pid)
        {
            sc_msg_def::jpk_skill_t skl;
            skl_->get_skill_jpk(skl);
            jpk_.skls.push_back(std::move(skl));
        }
    });
    
    m_user.star_mgr.foreach([&](sp_star_t star_){
        sc_msg_def::jpk_star_t star;
        star_->get_star_jpk(star);
        jpk_.stars.push_back(std::move(star));
    }, jpk_.pid);

    //m_user.rune_mgr.get_runes(db.pid,jpk_.runes);

    return SUCCESS;
}
int sc_partner_t::get_jpk_view_data(sc_msg_def::jpk_view_role_data_t& jpk_)
{
    jpk_.uid = db.uid;
    jpk_.pid = db.pid;
    jpk_.resid = db.resid;

    pro.cal_pro(db.pid);
    pro.copy(jpk_.pro);

    jpk_.lvl.level = db.grade;
    jpk_.lvl.exp = db.exp;
    jpk_.lvl.lovelevel = db.lovelevel;

    jpk_.quality = db.quality;
    jpk_.potential_1 = db.potential_1;
    jpk_.potential_2 = db.potential_2;
    jpk_.potential_3 = db.potential_3;
    jpk_.potential_4 = db.potential_4;
    jpk_.potential_5 = db.potential_5;

    int slot=1;
    m_user.equip_mgr.foreach([&](sp_equip_t eqp_){
        if((eqp_->db.isweared==1)&&(eqp_->db.pid==jpk_.pid))
        {
            repo_def::equip_t* reqp = repo_mgr.equip.get(eqp_->db.resid);
            if (reqp == NULL)
            {
                logerror((LOG, "repo no equip resid:%d", eqp_->db.resid));
                return;
            }

            sc_msg_def::jpk_equip_t jpk;
            eqp_->get_equip_jpk(jpk);
            jpk_.equips.insert(std::move(make_pair(slot, std::move(jpk))));
            slot++;
        }
    });

    m_user.skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == jpk_.pid)
        {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            jpk_.skls.push_back(std::move(jpk));
        }
    });
    return SUCCESS;
}
int sc_partner_t::get_jpk_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t& jpk_)
{
    jpk_.uid = db.uid;
    jpk_.pid = db.pid;
    jpk_.resid = db.resid;
    pro.cal_pro(db.pid);
    pro.copy(jpk_.pro);
    jpk_.lvl.push_back(db.grade);
    jpk_.lvl.push_back(db.lovelevel);
    jpk_.wid = -1;

    m_user.skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == jpk_.pid) {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            if (jpk.level > 0) {
                vector<int32_t> tmp;
                tmp.push_back(jpk.skid);
                tmp.push_back(jpk.resid);
                tmp.push_back(jpk.level);
                jpk_.skls.push_back(std::move(tmp));
            }
        }
    });
    return SUCCESS;
}
void sc_partner_t::get_jpk_gbattle_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_, int32_t pos_)
{
    view_.uid = db.uid;
    view_.pid = db.pid;
    view_.resid = db.resid;
    sc_pro_t g_battle_pro(m_user);
    g_battle_pro.cal_pro(db.pid, pos_, 1);
    g_battle_pro.copy(view_.pro);
    view_.lvl.push_back(db.grade);
    view_.lvl.push_back(db.lovelevel);

    m_user.skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == view_.pid) {
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
int sc_partner_t::get_jpk_rank_view_data(sc_msg_def::jpk_fight_view_role_data_t& jpk_, float num, int32_t pos_)
{
    jpk_.uid = db.uid;
    jpk_.pid = db.pid;
    jpk_.resid = db.resid;
    sc_pro_t pro_rank(m_user);
    pro_rank.cal_pro(db.pid, pos_, num);
    pro_rank.copy(jpk_.pro);
    jpk_.lvl.push_back(db.grade);
    jpk_.lvl.push_back(db.lovelevel);
    jpk_.wid = -1;

    m_user.skill_mgr.foreach([&](sp_skill_t skl_){
        if (skl_->db.pid == jpk_.pid) {
            sc_msg_def::jpk_skill_t jpk;
            skl_->get_skill_jpk(jpk);
            if (jpk.level > 0) {
                vector<int32_t> tmp;
                tmp.push_back(jpk.skid);
                tmp.push_back(jpk.resid);
                tmp.push_back(jpk.level);
                jpk_.skls.push_back(std::move(tmp));
            }
        }
    });
    return SUCCESS;
}

int sc_partner_t::get_pro_jpk(sc_msg_def::jpk_role_pro_t& jpk_)
{
    repo_def::role_t* role = repo_mgr.role.get(db.resid);
    if (role == NULL)
    {
        logerror((LOG, "repo no role id:%d", db.resid));
        return ERROR_SC_EXCEPTION; 
    }

    pro.cal_pro(db.pid);
    pro.copy(jpk_);

    return SUCCESS;
}
void sc_partner_t::save_db()
{
    /*
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
    */
    
    db_service.async_do((uint64_t)db.uid, [](db_Partner_t& db_){
        db_.update();
    }, db.data());
}
int32_t sc_partner_t::up_potential(int32_t flag_,int32_t &delata_,int32_t &current_, int32_t &attribute)
{
    sc_msg_def::ret_potential_up_t ret;    
    ret.pid = db.pid;
    delata_ = current_ = 0;

    /*
    if(m_user.db.grade < 17 )
    {
        logerror((LOG, "on_partner_up_potential, user grade not enough :%d", m_user.db.grade));
        ret.code = ERROR_SC_NOT_ENOUGH_GRADE;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_NOT_ENOUGH_GRADE;
    }
    */

    //当前潜能是否已经达到上限
    auto it = repo_mgr.potential_caps.find(db.grade);
    if( it == repo_mgr.potential_caps.end() )
    {
        logerror((LOG, "on_partner_up_potential, repo no quality:%d", db.grade));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(m_user.db.uid, ret);
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
        }
    }
    if( cap <= *potential )
    {
        logerror((LOG, "on_partner_up_potential, potential max:%d", *potential));
        ret.code = ERROR_SC_POTENTIAL_CAP;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_POTENTIAL_CAP;
    }

    //材料是否足够
    if( flag_!=1 && flag_!=2 )
    {
        logerror((LOG, "on_partner_up_potential, illegal flag:%d", flag_));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    auto rp_partner = repo_mgr.role.get(db.resid);
    auto rp_potential = repo_mgr.potential.get(rp_partner->job * 100 + attribute);

    int32_t resid_drag = rp_potential->consume;
    /*
    if( 1==flag_ )
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

    if( !m_user.item_mgr.has_items(resid_drag,num) )
    {
        logerror((LOG, "on_partner_up_potential,bag no material,mat id:%d", resid_drag));
        ret.code = ERROR_SC_NOT_ENOUGH_MATERIAL;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_NOT_ENOUGH_MATERIAL;
    }

    //扣去材料
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(resid_drag, num,  nt);
    m_user.item_mgr.on_bag_change(nt);

    //产生随机潜力变化
    /*
    auto it_hm = repo_mgr.potential_upgrade.find(db.potential+1);
    if( it_hm == repo_mgr.potential_upgrade.end() )
    {
        logerror((LOG, "on_partner_up_potential,repo no potential,:%d", db.potential+1));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    vector<int32_t> probab ;
    if( 1==flag_ )
        probab = it_hm->second.normal_success_rate;
    else
        probab = it_hm->second.super_success_rate;

    if( 3!=probab.size() )
    {
        logerror((LOG, "on_partner_up_potential,repo exception,potential_upgrade"));
        ret.code = ERROR_SC_EXCEPTION;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    int32_t r = random_t::rand_integer(1, 10000);
    int32_t delta = 0;
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

    if( (db.potential + delta ) > cap )
        delta = cap - db.potential;
    */

    *potential += 1;
    //计算属性变化
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
    save_db();

    get_pro_jpk(ret.pro);

    ret.code = SUCCESS;
    int delta = 1;
    ret.delta = delta;
    logic.unicast(m_user.db.uid, ret);
    
    delata_ = delta;
    current_ = *potential;

    //更新洗礼的日常任务
    m_user.daily_task.on_event(evt_up_potential);
    
    return SUCCESS;
}
void sc_partner_t::on_pro_changed()
{
    sc_msg_def::nt_role_pro_change_t nt;
    nt.pid = db.pid;
    get_pro_jpk(nt.pro);
    logic.unicast(db.uid, nt);
}
void sc_partner_t::gen_pro(sc_msg_def::nt_role_pro_change_t& nt_)
{
    nt_.pid = db.pid;
    get_pro_jpk(nt_.pro);
}
//======================================================
sc_partner_mgr_t::sc_partner_mgr_t(sc_user_t& user_):m_user(user_)
{
}
void sc_partner_mgr_t::init_new_user()
{
    auto it_role = repo_mgr.role.find(m_user.db.resid);
    if (it_role == repo_mgr.role.end())
    {
        logerror((LOG, "repo no role, resid:%d", m_user.db.resid));
        return;
    }
    repo_def::role_t& role = it_role->second;
    for (size_t i=1; i<role.partner.size(); i++)
    {
        auto it_partner = repo_mgr.role.find(role.partner[i]);
        if (it_partner == repo_mgr.role.end())
        {
            logerror((LOG, "repo no role, resid:%d", role.partner[i]));
            continue;
        }

        sp_partner_t sp_partner(new sc_partner_t(m_user));
        db_Partner_t& padb = sp_partner->db;

        repo_def::role_t& partner = it_partner->second;
        padb.pid = m_maxid.newid();
        padb.uid = m_user.db.uid;
        padb.resid = partner.id;
        padb.exp  =0;
        padb.lovevalue = 0;
        padb.potential_1  =0;
        padb.potential_2  =0;
        padb.potential_3  =0;
        padb.potential_4  =0;
        padb.potential_5  =0;
        padb.naviClickNum1 = 0;
        padb.naviClickNum2 = 0;
        padb.grade = 1;
        padb.quality = 1;
        m_partner_hm.insert(make_pair(sp_partner->db.pid, sp_partner));
        m_resid_hm.insert(make_pair(sp_partner->db.resid,1));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Partner_t& db_){
            db_.insert();
        }, padb);
    }
}
void sc_partner_mgr_t::load_db()
{
    //加载伙伴数据
    sql_result_t res;
    if (0==db_Partner_t::sync_select_partner(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_partner_t sp_partner(new sc_partner_t(m_user));
            sp_partner->db.init(*res.get_row_at(i));
            m_partner_hm.insert(make_pair(sp_partner->db.pid, sp_partner));
            m_resid_hm.insert(make_pair(sp_partner->db.resid,1));
            m_maxid.update(sp_partner->db.pid);
            logwarn((LOG, "load partner from db, uid:%d, pid:%d, resid:%d", 
                sp_partner->db.uid, sp_partner->db.pid, sp_partner->db.resid));
        }
    }
    //加载碎片数据
    if (0==db_PartnerChip_t::sync_select_partnerchip(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_partnerchip_t sp_partnerchip(new sc_partnerchip_t);
            sp_partnerchip->db.init(*res.get_row_at(i));
            m_chip_hm.insert(make_pair(sp_partnerchip->db.resid, sp_partnerchip));
            logwarn((LOG, "load partner from db, uid:%d, count:%d, resid:%d", 
             sp_partnerchip->db.uid, sp_partnerchip->db.count, sp_partnerchip->db.resid));
        }
        logwarn((LOG, "load finish."));
    }
}

void sc_partner_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Partner_t::select_partner(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_partner_t sp_partner(new sc_partner_t(m_user));
            sp_partner->db.init(*res.get_row_at(i));
            m_partner_hm.insert(make_pair(sp_partner->db.pid, sp_partner));
            m_maxid.update(sp_partner->db.pid);
            logwarn((LOG, "load partner from db, uid:%d, pid:%d, resid:%d", 
                sp_partner->db.uid, sp_partner->db.pid, sp_partner->db.resid));
        }
    }
}

sp_partner_t sc_partner_mgr_t::get(int32_t pid_)
{
    auto it = m_partner_hm.find(pid_);
    if (it != m_partner_hm.end())
        return it->second;
    return sp_partner_t();
}

sp_partner_t sc_partner_mgr_t::getbyresid(int32_t resid_)
{
    for(auto it = m_partner_hm.begin(); it != m_partner_hm.end(); it++)
    {
        if(it->second->db.resid == resid_)
            return it->second;
    }
    return sp_partner_t();
}


int32_t sc_partner_mgr_t::hire_from_reward(int32_t resid_,int32_t silence_)
{
    //判断玩家是否已有该英雄
    if( has_hero(resid_) )
    {
        //分解碎片
        sc_msg_def::nt_chip_change_t change;
        sc_msg_def::jpk_pub_chip_t chip;
        chip.resid = pub_ctl.get_chip_resid(resid_);
        if( chip.resid <= 0 )
            return ERROR_SC_EXCEPTION;
        chip.count = get_need_piece_count(resid_);
        chip.reduced = 1;

        //将碎片塞入背包
        add_new_chip(chip.resid,chip.count,change);
        if( 0==silence_ )
            on_chip_change(change);

        return 1;
    }
    else
    {
        //奖励英雄
        sc_msg_def::nt_reward_partner_t ret;
        //sp_partner_t sp_par = m_user.partner_mgr.hire(resid_,1);
        sp_partner_t sp_par = hire(resid_,1);
        if( sp_par != NULL )
        {
            sp_par->get_partner_jpk(ret.partner);
            if( 0==silence_ )
                logic.unicast(m_user.db.uid, ret);
        }

        return 0;
    }
}

int32_t sc_partner_mgr_t::hire_from_chip(int32_t resid_,sc_msg_def::jpk_role_data_t &ret_)
{
    //判断碎片是否足够
    int32_t need = get_need_piece_count(resid_);
    int32_t now = get_now_piece_count(resid_);
    if( now < need )
    {
        logwarn((LOG, "hire from chip,not enough chip,resid:%d",resid_)); 
        return ERROR_HERO_NOT_ENOUGH_CHIP;
    }

    //判断玩家是否已有该英雄
    if( has_hero(resid_) )
    {
        logwarn((LOG, "hire from chip,hero existed,resid:%d",resid_)); 
        return ERROR_HERO_EXISTED;
    }

    //消耗碎片
    sc_msg_def::nt_chip_change_t change;
    int32_t chip_resid = pub_ctl.get_chip_resid(resid_);
    if( !consume_chip(chip_resid,need,change) )
        return ERROR_SC_EXCEPTION;
    on_chip_change(change);

    //雇佣英雄
    sp_partner_t sp_partner = hire(resid_,1);
    if( sp_partner != NULL )
        sp_partner->get_partner_jpk(ret_);
    else
        return ERROR_SC_EXCEPTION;

    return SUCCESS;
}
sp_partner_t sc_partner_mgr_t::hire(int32_t resid_, int32_t potential_)
{
    auto it_partner = repo_mgr.role.find(resid_);
    if (it_partner == repo_mgr.role.end())
    {
        logerror((LOG, "repo no role, resid:%d", resid_));
        return sp_partner_t();
    }
    
    if( it_partner->second.rare == 5 )
        pushinfo.new_push(push_partner,m_user.db.nickname(),m_user.db.grade,m_user.db.uid,m_user.db.viplevel,resid_);

    sp_partner_t sp_partner(new sc_partner_t(m_user));
    db_Partner_t& padb = sp_partner->db;

    repo_def::role_t& partner = it_partner->second;
    padb.pid = m_maxid.newid();
    padb.uid = m_user.db.uid;
    padb.resid = partner.id;
    padb.exp  =0;
    padb.potential_1  =0;
    padb.potential_2  =0;
    padb.potential_3  =0;
    padb.potential_4  =0;
    padb.potential_5  =0;
    padb.grade = potential_;
    padb.lovelevel = 0;
    //召唤鱼肠默认爱恋等级调整
    if(padb.resid == 16)
        padb.lovelevel = 2;
    padb.lovevalue = 0;
    padb.naviClickNum1 = 0;
    padb.naviClickNum2 = 0;
    auto qua_count = repo_mgr.item.find(resid_ + 30000);
    if (qua_count == repo_mgr.item.end())
        padb.quality = 1;
    else
        padb.quality = qua_count->second.quality;
    m_partner_hm.insert(make_pair(sp_partner->db.pid, sp_partner));
    m_resid_hm.insert(make_pair(sp_partner->db.resid,1));

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Partner_t& db_){
        db_.insert();
    }, padb);

    m_user.equip_mgr.init_new_partner(padb.pid, padb.resid);
    m_user.skill_mgr.init_new_partner(padb.pid, padb.resid, padb.quality);

    //成就任务记录
    //m_user.achievement.on_event(evt_rankup_lv, padb.quality);
    m_user.achievement.on_event(evt_own_partners, 1);
    return sp_partner;
}

int32_t sc_partner_mgr_t::has_hero(int32_t resid_)
{
    auto it = m_resid_hm.find(resid_);
    if( it == m_resid_hm.end() )
        return 0;
    return 1;
}

int32_t sc_partner_mgr_t::get_need_piece_count(int32_t resid_)
{
    auto it = repo_mgr.role.find( resid_ );
    if( it == repo_mgr.role.end() )
        return 0;
    return it->second.hero_piece;
}

int32_t sc_partner_mgr_t::get_now_piece_count(int32_t resid_)
{
    int32_t chip_resid = pub_ctl.get_chip_resid(resid_);
    auto it = m_chip_hm.find( chip_resid );
    if( it == m_chip_hm.end() )
        return 0;
    return it->second->db.count;
}

void sc_partner_mgr_t::chip_to_soul(vector<sc_msg_def::jpk_chip_t> &chips_)
{
    sc_msg_def::ret_chip_to_soul_t ret;
    ret.soul = 0;
    sc_msg_def::nt_chip_change_t change;
    int32_t soul = 0;

    for( auto it=chips_.begin(); it!=chips_.end(); ++it)
    {
        auto it_chip = repo_mgr.chip.find( (*it).resid );
        if( it_chip == repo_mgr.chip.end() )
        {
            logerror((LOG, "chip_to_soul,repo no chip, resid:%d", (*it).resid ));
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return;
        }

        if( !consume_chip((*it).resid,(*it).count,change) )
        {
            logerror((LOG, "chip_to_soul,not enough, resid:%d", (*it).resid ));
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return;
        }

        soul += (((*it).count)*(it_chip->second.soul));
    }

    m_user.on_soul_change( soul );
    m_user.save_db();
    m_user.partner_mgr.on_chip_change(change);

    ret.soul = soul;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return;
}

int32_t sc_partner_mgr_t::fire(int32_t pid_,int32_t &resid_)
{
    //确定该伙伴是否存在
    auto it = m_partner_hm.find( pid_ );
    if( it == m_partner_hm.end() )
    {
        return ERROR_SC_NO_PARTNER;
    }
    resid_ = it->second->db.resid;
    
    //脱下该伙伴的符文
    //int32_t res = m_user.rune_mgr.takeoff_rune(pid_);
    //if( res != SUCCESS )
    //    return res;

    //脱下该伙伴的装备
    sc_msg_def::nt_bag_change_t ret;
    m_user.equip_mgr.fire_all_equip(pid_,ret);
    //通知客户端背包改变
    if( !ret.add_equips.empty() )
        logic.unicast(m_user.db.uid, ret);
    
    //判断是否是助战英雄
    if( m_user.db.helphero == pid_ )
    {
        m_user.db.set_helphero(0);
        m_user.save_db(); 

        m_user.friend_mgr.on_helphero_change(m_user.db.resid);
    }

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Partner_t& db_){
        db_.remove();
    }, it->second->db.data());

    //从队伍中移除伙伴
    //m_user.team.on_partner_fired(pid_);

    int32_t id = resid_*10 + it->second->db.quality ;
    int32_t n_chip = 0,n_gold=0,n_soul=0;
    auto it_hm = repo_mgr.qualityup_staff.find(id);
    while( it_hm != repo_mgr.qualityup_staff.end() )
    {
        n_chip += it_hm->second.var1;
        n_soul += it_hm->second.var2;
        n_gold += it_hm->second.var3;
        --id;
        it_hm = repo_mgr.qualityup_staff.find(id);
    }

    //增加碎片
    sc_msg_def::nt_chip_change_t change;
    int32_t chip_resid = pub_ctl.get_chip_resid(resid_);
    int32_t need = get_need_piece_count(resid_);
    //分解时碎片数量为总数的90%，分解损耗
    add_new_chip(chip_resid,((need+n_chip)* 0.9f),change);
    on_chip_change(change);
    //增加灵能
    m_user.on_soul_change(n_soul * 0.7);
    //增加金币
    m_user.on_money_change(n_gold * 0.7);
    //增加战历
    //m_user.on_battlexp_change( m_user.skill_mgr.get_total_battlexp(pid_) * 0.7 );

    //删除该伙伴
    m_partner_hm.erase( it );
    m_resid_hm.erase(resid_);
    
    return SUCCESS;
}

void sc_partnerchip_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

//奖励伙伴
int32_t sc_partner_mgr_t::get_specific_partner(int32_t resid_, sc_msg_def::jpk_role_data_t &ret_)
{
    if( resid_ != 0 )
    {
        sp_partner_t sp_par = m_user.partner_mgr.hire(resid_,1);
        if( sp_par != NULL )
        {
            sp_par->get_partner_jpk(ret_);
            return 0;
        }
        return -1;
    }
    return -1;
}

sp_partnerchip_t sc_partner_mgr_t::get_chip(int32_t resid_)
{
    auto it = m_chip_hm.find(resid_);
    if (it != m_chip_hm.end())
        return it->second;
    return sp_partnerchip_t();
}
void sc_partner_mgr_t::on_chip_change(sc_msg_def::nt_chip_change_t& change_)
{
    if(!change_.chips.empty())
        logic.unicast(m_user.db.uid, change_);
}

bool sc_partner_mgr_t::consume_chip(int32_t resid_, int32_t num_, sc_msg_def::nt_chip_change_t& change_)
{
    if( num_<=0 )
        return true;

    auto it = m_chip_hm.find(resid_);
    if (it != m_chip_hm.end() && it->second->db.count >= num_)
    {
        db_PartnerChip_ext_t &db = it->second->db;

        db.set_count(db.count - num_);

        if (db.count<=0)
        {
            m_chip_hm.erase(db.resid);
            db_service.async_do((uint64_t)m_user.db.uid, [](db_PartnerChip_t &db_){
                db_.remove();
            }, db.data());
        }
        else
        {
            it->second->save_db();
        }

        //生成消耗记录
        statics_ins.unicast_consumelog(m_user,resid_,1,num_,it->second->db.count);

        sc_msg_def::jpk_chip_t item;
        item.resid = db.resid;
        item.count = db.count;
        change_.chips.push_back(std::move(item));

        return true;

    }
    return false;
}
bool sc_partner_mgr_t::add_new_chip(int32_t resid_,int32_t num_,vector<sc_msg_def::jpk_chip_t> &change_)
{
    if (num_ <= 0)
        return false;

    if (resid_ == 39999)
    {
        resid_ = m_user.db.resid + 30000;
    }
    sp_partnerchip_t sp_chip = get_chip(resid_);
    if (sp_chip != NULL)
    {
        db_PartnerChip_ext_t &db = sp_chip->db;
        db.set_count(db.count + num_);
        sp_chip->save_db();


        sc_msg_def::jpk_chip_t chip;
        chip.resid = resid_;
        chip.count = db.count;
        change_.push_back(std::move(chip));
    }
    else
    {
        boost::shared_ptr<sc_partnerchip_t> sp_chip(new sc_partnerchip_t);
        db_PartnerChip_t& db = sp_chip->db;
        db.uid = m_user.db.uid;
        db.resid = resid_;
        db.count = num_;

        m_chip_hm.insert( make_pair(resid_, sp_chip) );

        db_service.async_do((uint64_t)m_user.db.uid, [](db_PartnerChip_t& db_){
                db_.insert();
                }, db);

        sc_msg_def::jpk_chip_t item;
        item.resid = db.resid;
        item.count = db.count;
        change_.push_back(std::move(item));
    }

    return true;
}

bool sc_partner_mgr_t::add_new_chip(int32_t resid_, int32_t num_, sc_msg_def::nt_chip_change_t& change_)
{
    return add_new_chip(resid_, num_, change_.chips);
}

void sc_partner_mgr_t::naviClick(int32_t naviId, int32_t& resid, int32_t& index)
{
    for( auto it = m_partner_hm.begin(); it != m_partner_hm.end();it++)
    {
        if (it->second->db.resid == resid)
        {
            it->second->db.naviClickNum1++;
          //  else
          //      it->second->db.naviClickNum2++;    
            it->second->save_db();
            break;
        }
    } 
}
