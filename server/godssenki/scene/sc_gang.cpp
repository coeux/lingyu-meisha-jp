#include "sc_gang.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "msg_def.h"
#include "log.h"
#include "random.h"
#include "date_helper.h"
#include "sc_cache.h"
#include "code_def.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_push_def.h"
#include "ys_tool.h"

#include <math.h>
#include <boost/format.hpp>

#define LOG "SC_GANG"

#define MAX_GSKL 8 
//公会最大官员数量
//官员数量=ROUNDDOWN(公会人数/5,0)
#define MAX_ADM_NUM(n) ((int)ceilf(n*0.2f))

#define MAX_PAY_MONEY   10000
#define MAX_PAY_RMB     20
#define MAX_PAY_SUPER   120
#define MAX_PAY_HONGBAO 400 
#define MAX_HONGBAO     10
#define PAY_PRAY        100

sc_ganguser_t::sc_ganguser_t():
isonline(false),
m_daily_pay(0),
m_last_pay_time(0),
m_last_pray_time(0),
m_max_pray_num(0)
{
    m_dbgsklv.resize(MAX_GSKL);
    m_dbgsklv[0] = &(db.skl1);
    m_dbgsklv[1] = &(db.skl2);
    m_dbgsklv[2] = &(db.skl3);
    m_dbgsklv[3] = &(db.skl4);
    m_dbgsklv[4] = &(db.skl5);
    m_dbgsklv[5] = &(db.skl6);
    m_dbgsklv[6] = &(db.skl7);
    m_dbgsklv[7] = &(db.skl8);

}
sc_ganguser_t::~sc_ganguser_t()
{
}
int sc_ganguser_t::on_daily_pay(int pay_)
{
    //每日捐献上限为=用户等级*(1+ROUNDUP(用户等级/10,0)/10)*1000+3900
    //int max_pay = db.grade * (1.0f+ceilf(db.grade*0.1f)*0.1f)*1000+3900;
    //int max_pay = ((int)((1.0f+ceilf(db.grade*0.1f)*0.1f)*1000))*db.grade +3900;

    if (m_last_pay_time == 0)
    {
        m_daily_pay = 0;
        m_daily_pay += pay_;
        m_last_pay_time = date_helper.cur_sec();
        return SUCCESS;
    }
    else if (m_last_pay_time  > 0 && date_helper.offday(m_last_pay_time) >= 1)
    {
        m_daily_pay = 0;
        m_daily_pay += pay_;
        m_last_pay_time = date_helper.cur_sec();
        return SUCCESS;
    }
    return ERROR_SC_ILLEGLE_REQ;
    /*

    if (m_daily_pay+pay_ >= max_pay)
    {
        pay_ = (max_pay-m_daily_pay);
        m_daily_pay = max_pay;
        return pay_;
    }else
    {
        m_daily_pay += pay_;
        return pay_;
    }
    */
}
void sc_ganguser_t::get_mem_jpk(sc_msg_def::jpk_gangmem_t& jpk_, int uid_)
{
    jpk_.uid = db.uid;
    jpk_.name = db.nickname();
    //获取装备等级
    jpk_.quality = sc_user_t::get_equip_level(uid_, 0);

    jpk_.grade = db.grade;
    jpk_.flag = db.flag;
    jpk_.gm = db.gm;
    jpk_.totalgm = db.totalgm;
    jpk_.rank = db.rank;
    jpk_.online = isonline;
    if (!jpk_.online)
        jpk_.offtime = date_helper.cur_sec()-db.lastquit; 
}
/*int sc_ganguser_t::get_equip_level(int uid,int pid)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select resid from Equip where uid=%d and pid=%d;", uid, pid);
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
}*/

void sc_ganguser_t::get_gskl_jpk(vector<sc_msg_def::jpk_gskl_t>& jpk_)
{
    for(size_t i=0; i<MAX_GSKL; i++)
    {
        sc_msg_def::jpk_gskl_t jpk;

        jpk.resid = i+101;
        jpk.level = *m_dbgsklv[i];

        jpk_.push_back(std::move(jpk));
    }
}
void sc_ganguser_t::upgrade_gskl(int resid_)
{
    switch(resid_-101)
    {
    case 0: db.set_skl1(db.skl1+1); break;
    case 1: db.set_skl2(db.skl2+1); break;
    case 2: db.set_skl3(db.skl3+1); break;
    case 3: db.set_skl4(db.skl4+1); break;
    case 4: db.set_skl5(db.skl5+1); break;
    case 5: db.set_skl6(db.skl6+1); break;
    case 6: db.set_skl7(db.skl7+1); break;
    case 7: db.set_skl8(db.skl8+1); break;
    }

    sc_msg_def::nt_gskl_lv_change_t nt;
    nt.resid = resid_;
    nt.level = (*m_dbgsklv[resid_-101]);
    logic.unicast(db.uid, nt);
}
void sc_ganguser_t::on_change_gm(int gm_)
{
    if (gm_ > 0)
        db.set_totalgm(db.totalgm + gm_);

    db.set_gm(db.gm + gm_);
    if (db.gm < 0) db.set_gm(0);

    sc_msg_def::nt_gang_pay_change_t nt;
    nt.gm = db.gm;
    nt.totalgm = db.totalgm;
    logic.unicast(db.uid, nt);
}
void sc_ganguser_t::on_rename(const string& name_)
{
    db.set_nickname(name_);
    save_db();
}
void sc_ganguser_t::set_leave_gang()
{
    //重置祭祀
    m_pray_num = 0;
    m_last_pray_time = 0;
    m_max_pray_num = 0;

    db.set_flag(0);
    db.set_gm(0);
    db.set_totalgm(0);
    db.set_state(0);

    sp_user_t sp_user;
    if (logic.usermgr().get(db.uid, sp_user))
    {
        sp_user->on_team_pro_changed();
    }
}
int  sc_ganguser_t::get_gskl_pro(int type_)
{
    int resid = type_+101;
    int level = get_gskl_lv(resid);
    repo_def::guildskill_t* gskl = repo_mgr.guildskill.get(resid*1000+level); 
    if (gskl == NULL)
        return 0;
    return gskl->value;
}
int  sc_ganguser_t::get_gskl_lv(int resid_)
{
    return (*m_dbgsklv[resid_-101]);
}
void sc_ganguser_t::enter_pray(sp_user_t sp_user_)
{
    update_praynum();
    m_last_pray_time = date_helper.cur_sec();

    sc_msg_def::ret_enter_pray_t ret;
    ret.code = SUCCESS;
    ret.prn = m_pray_num;
    ret.gm = db.gm;
    ret.lv = get_gang()->db.level;
    logic.unicast(db.uid, ret);
}
void sc_ganguser_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
int sc_ganguser_t::get_daily_pay() 
{ 
    if (m_last_pay_time > 0 && date_helper.offday(m_last_pay_time) >= 1)
    {
        m_daily_pay = 0;
    }
    return m_daily_pay; 
}
void sc_ganguser_t::pray(sp_user_t sp_user_)
{
    sc_msg_def::ret_gang_pray_t ret;
    if (sp_user_->bag.is_full())
    {
        ret.code = ERROR_BAG_FULL;
        logic.unicast(db.uid, ret);
        return;
    }

    if (get_gang()->db.level < 2) 
    {
        ret.code = ERROR_GANG_LEVEL;
        logic.unicast(db.uid, ret);
        return;
    }

    update_praynum();
    m_last_pray_time = date_helper.cur_sec();

    if (m_pray_num <= 0)
    {
        ret.code = ERROR_GANG_LESS_PRAY_NUM;
        logic.unicast(db.uid, ret);
        return;
    }

    if (db.gm < PAY_PRAY)
    {
        ret.code = ERROR_GANG_LESS_GM;
        logic.unicast(db.uid, ret);
        return;
    }

    //修改贡献值
    db.set_gm(db.gm - PAY_PRAY);
    save_db();

    //通知用户贡献值改变
    {
        sc_msg_def::nt_gang_pay_change_t nt;
        nt.gm = db.gm;
        nt.totalgm = db.totalgm;
        logic.unicast(db.uid, nt);
    }
    sp_user_->daily_task.on_event(evt_gang_act);
    m_pray_num--;

    uint32_t need_r = 0; 
    repo_def::altar_t* rp_altar = NULL; 
    uint32_t r = random_t::rand_integer(1, 10000);
    for(auto it=repo_mgr.altar_hm.begin(); it!=repo_mgr.altar_hm.end(); it++)
    {
        need_r += it->first * it->second.size();
        if (r <= need_r )
        {
            uint32_t rr = random_t::rand_integer(0, it->second.size()-1);
            rp_altar = &(it->second[rr]);
            break;
        }
    }
    if (rp_altar == NULL)
    {
        logerror((LOG, "pray failed!, r:%d, need_r:%d", r, need_r));
        ret.code = ERROR_GANG_LESS_PRAY_NUM; 
        logic.unicast(db.uid, ret);
        return;
    }

    switch(rp_altar->item)
    {
    case 10000:
    {
        sp_user_->on_money_change(rp_altar->quantity);
        sp_user_->save_db();
    }
    break;
    case 10003:
    {
        sp_user_->on_freeyb_change(rp_altar->quantity);
        sp_user_->save_db();
    }
    break;
    default:
        {
            sc_msg_def::nt_bag_change_t nt;
            sp_user_->item_mgr.addnew(rp_altar->item, rp_altar->quantity, nt);
            sp_user_->item_mgr.on_bag_change(nt);
        }
    }

    ret.code = SUCCESS;
    ret.num = rp_altar->quantity;
    ret.resid = rp_altar->item;
    ret.loc = rp_altar->location;
    logic.unicast(db.uid, ret);
}
void sc_ganguser_t::update_praynum()
{
    if (m_last_pray_time == 0 || date_helper.offday(m_last_pray_time)>=1)
    {
        m_pray_num = get_gang()->db.level/2 + 1;
        m_pray_num = m_pray_num > 5 ? 5 : m_pray_num;
        m_max_pray_num  = m_pray_num;
    }
    else 
    {
        int pn = get_gang()->db.level/2 + 1;
        if (pn > 5) pn = 5;
        if (m_max_pray_num < pn)
        {
            m_pray_num += pn - m_max_pray_num;
            m_max_pray_num = pn;
        }
    }
}
sp_gang_t sc_ganguser_t::get_gang()
{
    sp_gang_t sp_gang;
    gang_mgr.get(db.ggid, sp_gang);
    return sp_gang;
}
//=============================================
sc_gang_t::sc_gang_t():m_hongbao_stamp(0)
{
}

sc_gang_t::~sc_gang_t()
{
}

void sc_gang_t::broadcast(int32_t cmd_, string &msg_)
{
    for(auto it=m_online_role.begin();it!=m_online_role.end();++it)
    {
        logic.unicast(*it, cmd_, msg_);
    }
}

void sc_gang_t::on_login(int uid_)
{
    sp_ganguser_t sp_guser;
    if (get_user(uid_, sp_guser))
    {
        logwarn((LOG, "load gangusers ggid:%d,uid:%d", db.ggid, uid_));

        sp_guser->isonline = true;
        sp_guser->update_praynum();
        m_online_role.insert(uid_);
        nt_add_res(uid_);
    }
}

void sc_gang_t::on_session_broken(int32_t uid_)
{
    sp_ganguser_t sp_guser;
    if (get_user(uid_, sp_guser))
    {
        sp_guser->isonline = false;
        sp_guser->db.set_lastquit(date_helper.cur_sec());
        sp_guser->save_db();
        m_online_role.erase(uid_);
    }
}

void sc_gang_t::on_upgrade(int32_t uid_, int32_t grade_)
{
    sp_ganguser_t sp_guser;
    if (get_user(uid_, sp_guser))
    {
        sp_guser->db.set_grade(grade_);
        sp_guser->save_db();
    }
}

void sc_gang_t::on_rank_changed(int32_t uid_, int32_t rank_)
{
    sp_ganguser_t sp_guser;
    if (get_user(uid_, sp_guser))
    {
        sp_guser->db.set_rank(rank_);
        sp_guser->save_db();
    }
}

void sc_gang_t::add_user(sp_ganguser_t sp_guser_)
{
    m_ganguser_hm.insert(make_pair(sp_guser_->db.uid, sp_guser_));
    if (sp_guser_->db.flag == gang_chairman)
        m_sp_chairman = sp_guser_;
    else if (sp_guser_->db.flag == gang_adm)
        m_adm_uid.insert(sp_guser_->db.uid);
}
void sc_gang_t::new_user(sp_user_t sp_user_, int flag_)
{
    sp_ganguser_t sp_guser;

    sp_ganguser_t sp_del_guser;
    if (gang_mgr.get_del_guser(sp_user_->db.uid, sp_del_guser))
    {
        gang_mgr.remove_del_guser(sp_user_->db.uid);

        sp_guser = sp_del_guser;
        sp_guser->db.set_ggid(db.ggid);
        sp_guser->db.set_lastquit(date_helper.cur_sec());
        sp_guser->db.set_lastenter(date_helper.cur_sec());
        sp_guser->db.set_grade(sp_user_->db.grade);
        sp_guser->db.set_nickname(sp_user_->db.nickname());
        sp_guser->db.set_rank(sp_user_->db.rank);
        sp_guser->db.set_flag(flag_);
        sp_guser->db.set_state(1);
        sp_guser->db.set_lastboss(0);
        sp_guser->save_db();
    }
    else
    {
        sp_guser.reset(new sc_ganguser_t());
        //创建公会成员
        sp_guser->db.ggid = db.ggid;
        sp_guser->db.hostnum = sp_user_->db.hostnum;
        sp_guser->db.uid = sp_user_->db.uid;
        sp_guser->db.grade = sp_user_->db.grade;
        sp_guser->db.nickname = sp_user_->db.nickname();
        sp_guser->db.rank = sp_user_->db.rank;
        sp_guser->db.flag = flag_;
        sp_guser->db.gm = 0;
        sp_guser->db.totalgm = 0;
        sp_guser->db.lastboss = 0;
        sp_guser->db.lastquit= date_helper.cur_sec();
        sp_guser->db.lastenter = date_helper.cur_sec();
        sp_guser->db.state = 1;
        sp_guser->db.skl1 = 0;
        sp_guser->db.skl2 = 0;
        sp_guser->db.skl3 = 0;
        sp_guser->db.skl4 = 0;
        sp_guser->db.skl5 = 0;
        sp_guser->db.skl6 = 0;
        sp_guser->db.skl7 = 0;
        sp_guser->db.skl8 = 0;

        db_service.async_do((uint64_t)sp_user_->db.uid, [](db_GangUser_t& db_){
            db_.insert();
        }, sp_guser->db.data());
    }

    if (sp_guser->db.flag == gang_adm)
        m_adm_uid.insert(sp_guser->db.uid);

    m_ganguser_hm.insert(make_pair(sp_user_->db.uid, sp_guser));

    if (flag_ == gang_chairman)
        m_sp_chairman = sp_guser;

    m_online_role.insert(sp_user_->db.uid);
}
void sc_gang_t::new_user(gang_add_req_t& req_, int flag_)
{
    sp_ganguser_t sp_guser;
    sp_ganguser_t sp_del_guser;
    if (gang_mgr.get_del_guser(req_.uid, sp_del_guser))
    {
        gang_mgr.remove_del_guser(req_.uid);

        sp_guser = sp_del_guser;
        sp_guser->db.set_ggid(db.ggid);
        sp_guser->db.set_lastquit(date_helper.cur_sec());
        sp_guser->db.set_lastenter(date_helper.cur_sec());
        sp_guser->db.set_grade(req_.grade);
        sp_guser->db.set_nickname(req_.nickname);
        sp_guser->db.set_rank(req_.rank);
        sp_guser->db.set_flag(flag_);
        sp_guser->db.set_state(1);
        sp_guser->save_db();
    }
    else
    {
        sp_guser.reset(new sc_ganguser_t());
        //创建公会成员
        sp_guser->db.ggid = db.ggid;
        sp_guser->db.hostnum = req_.hostnum;
        sp_guser->db.uid = req_.uid;
        sp_guser->db.grade = req_.grade;
        sp_guser->db.nickname = req_.nickname;
        sp_guser->db.rank = req_.rank;
        sp_guser->db.flag = flag_;
        sp_guser->db.gm = 0;
        sp_guser->db.totalgm = 0;
        sp_guser->db.lastquit= date_helper.cur_sec();
        sp_guser->db.lastenter = date_helper.cur_sec();
        sp_guser->db.lastboss= 0;
        sp_guser->db.set_todaycount(0);
        sp_guser->db.bossrewardcount = 0;
        sp_guser->db.bossrewardtime = 0;
        sp_guser->db.state = 1;
        sp_guser->db.skl1 = 0;
        sp_guser->db.skl2 = 0;
        sp_guser->db.skl3 = 0;
        sp_guser->db.skl4 = 0;
        sp_guser->db.skl5 = 0;
        sp_guser->db.skl6 = 0;
        sp_guser->db.skl7 = 0;
        sp_guser->db.skl8 = 0;

        db_service.async_do((uint64_t)req_.uid, [](db_GangUser_t& db_){
            db_.insert();
        }, sp_guser->db.data());
    }

    if (sp_guser->db.flag == gang_adm)
        m_adm_uid.insert(sp_guser->db.uid);

    m_ganguser_hm.insert(make_pair(req_.uid, sp_guser));

    if (logic.usermgr().has(sp_guser->db.uid))
        m_online_role.insert(sp_guser->db.uid);
}
bool sc_gang_t::get_user(int32_t uid_, sp_ganguser_t& sp_guser_)
{
    auto it = m_ganguser_hm.find(uid_);
    if (it == m_ganguser_hm.end())
        return false;
    sp_guser_ = it->second;
    return true;
}

void sc_gang_t::add_msg(sp_ganguser_t sp_guser_, int type_, string& msg_)
{
    //logwarn((LOG, "add_msg..."));

    sc_gang_msg_t gmsg;
    gmsg.type = type_;
    gmsg.stamp = date_helper.cur_sec(); 
    gmsg.nickname = sp_guser_->db.nickname();
    gmsg.grade = sp_guser_->db.grade;
    gmsg.msg = msg_;

    sc_msg_def::jpk_gang_msg_t jpk;
    jpk.type = type_;
    jpk.offtime = 0; 
    jpk.nickname = sp_guser_->db.nickname(); 
    jpk.grade = sp_guser_->db.grade;
    //获取装备等级
    jpk.quality = sc_user_t::get_equip_level(sp_guser_->db.uid, 0);
    jpk.msg = msg_;

    string serialized;
    jpk >> serialized;

    broadcast(sc_msg_def::nt_gang_msg_t::cmd(), serialized);
    
    m_gang_msg.push_back(std::move(gmsg));
    while (m_gang_msg.size() > 50)
    {
        m_gang_msg.pop_front();
    }

    //logwarn((LOG, "add_msg...ok"));
}
void sc_gang_t::get_msg(vector<string>& msgs_)
{
    sc_msg_def::jpk_gang_msg_t jpk;

    for(size_t i=0; i<m_gang_msg.size(); i++)
    {
        sc_gang_msg_t& gmsg = m_gang_msg[i];

        jpk.type = gmsg.type;
        jpk.offtime = date_helper.cur_sec() - gmsg.stamp; 
        jpk.nickname = gmsg.nickname;
        jpk.grade = gmsg.grade;
        //获取准备等级
        sql_result_t res;
        char sql[256];
        sprintf(sql, "select uid from UserInfo where nickname='%s';", gmsg.nickname.c_str());
        db_service.sync_select(sql,res);
        int uid = 0;
        if (res.affect_row_num() > 0)
        {
            sql_result_row_t& row = *res.get_row_at(0);
            uid = (int)std::atoi(row[0].c_str());
        }
        jpk.quality = 1;
        sp_ganguser_t sp_guser;
        if (uid > 0 && get_user(uid, sp_guser))
        {
            jpk.quality = sc_user_t::get_equip_level(uid, 0);
        }
        jpk.msg = gmsg.msg;
        
        string serialized;
        jpk >> serialized;

        msgs_.push_back(std::move(serialized));
    }
}
int  sc_gang_t::set_adm(int32_t cuid_,int32_t uid_, bool isadm_)
{
    sp_ganguser_t sp_c_guser;
    if (!get_user(cuid_, sp_c_guser))
        return ERROR_GANG_NO_USER;

    sp_ganguser_t sp_guser;
    if (!get_user(uid_, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_c_guser->db.flag != gang_chairman)
        return ERROR_GANG_FLAG;

    if (isadm_)
    {
        if (has_adm(uid_))
            return ERROR_GANG_HAS_ADM;
        if (m_adm_uid.size() >= (size_t)MAX_ADM_NUM(m_ganguser_hm.size()))
            return ERROR_GANG_MAX_ADM;

        m_adm_uid.insert(uid_);

        sp_guser->db.set_flag(gang_adm);
        sp_guser->save_db();


        //推送信封
        string mail = mailinfo.new_mail(mail_gang_appoint, date_helper.str_date(), sp_c_guser->db.nickname()); 
        if (!mail.empty())
        {
            notify_ctl.push_mail(uid_, mail);
        }
    }
    else
    {
        if (!has_adm(uid_))
            return ERROR_GANG_FLAG;

        m_adm_uid.erase(uid_);

        sp_guser->db.set_flag(gang_member);
        sp_guser->save_db();

        //推送信封
        string mail = mailinfo.new_mail(mail_gang_fire, date_helper.str_date(), sp_c_guser->db.nickname()); 
        if (!mail.empty())
        {
            notify_ctl.push_mail(uid_, mail);
        }
    }
    
    return SUCCESS;
}
void sc_gang_t::get_pro_jpk(int uid_, sc_msg_def::jpk_gang_pro_t& jpk_)
{
    jpk_.ggid = db.ggid;
    jpk_.level = db.level;
    jpk_.exp = db.exp;
    jpk_.name = db.name();
    if (m_sp_chairman != NULL)
    {
        jpk_.cname = m_sp_chairman->db.nickname();
        //获取装备等级 
        jpk_.quality = sc_user_t::get_equip_level(m_sp_chairman->db.uid, 0);
        jpk_.cgrade = m_sp_chairman->db.grade;
    }
    jpk_.online = online_num();
    jpk_.total = total_num();
    jpk_.reqed = (m_add_req_hm.find(uid_)!=m_add_req_hm.end()); 
    jpk_.grank = gang_mgr.get_grank(db.ggid);
}
int sc_gang_t::add_req(sp_user_t sp_user_)
{
    repo_def::guild_t* rp_guild = repo_mgr.guild.get(db.level);
    if (rp_guild == NULL)
        return ERROR_SC_EXCEPTION;
    if (rp_guild->member <= total_num())
        return ERROR_GANG_HAS_FULL;

    if( m_add_req_hm.count(sp_user_->db.uid) == 0 )
    {
        gang_add_req_t req;
        req.uid = sp_user_->db.uid;
        req.nickname = sp_user_->db.nickname();
        req.grade = sp_user_->db.grade;
        req.rank = sp_user_->db.rank;
        req.hostnum = sp_user_->db.hostnum;
        m_add_req_hm.insert(make_pair(sp_user_->db.uid,std::move(req)));

        //给官员发送推送信息
        sp_ganguser_t sp_guser;
        sc_msg_def::nt_gang_req_t nt;
        nt.code = SUCCESS;

        auto it = m_adm_uid.begin();
        while( it!= m_adm_uid.end() )
        {
            if( !get_user(*it,sp_guser) )
            {
                ++it;
                break;
            }

            if( sp_guser->isonline )
                logic.unicast(*it, nt);
            ++it;
        }

        if(m_sp_chairman != NULL && m_sp_chairman->isonline )
            logic.unicast(m_sp_chairman->db.uid, nt);
    }

    return SUCCESS;
}
int sc_gang_t::get_req_count()
{
    return m_add_req_hm.size();
}
void sc_gang_t::del_req(int uid_)
{
    if (m_add_req_hm.empty())
        return;
    m_add_req_hm.erase(uid_);
}
void sc_gang_t::get_req(vector<sc_msg_def::jpk_gang_requser_t>& reqs_)
{
    reqs_.resize(m_add_req_hm.size());
    int i=0;
    for(auto it=m_add_req_hm.begin(); it!=m_add_req_hm.end(); it++)
    {
        sc_msg_def::jpk_gang_requser_t& jpk = reqs_[i++];
        jpk.uid = it->second.uid;
        jpk.nickname = it->second.nickname;
        jpk.grade = it->second.grade;
        jpk.rank = it->second.rank;
    }
}
void sc_gang_t::save_add_res(int uid_, int code_, string& msg_)
{
    if (logic.usermgr().has(uid_))
    {
        logic.unicast(uid_, 
                sc_msg_def::nt_add_gang_res_t::cmd(), msg_);
    }
    else
    {
        m_cache_deal_req[uid_] = code_;
    }

    //推送信封
    if (code_ == SUCCESS)
    {
        string mail = mailinfo.new_mail(mail_gang_add, date_helper.str_date(), db.name()); 
        if (!mail.empty())
        {
            notify_ctl.push_mail(uid_, mail);
        }
    }
}
void sc_gang_t::nt_add_res(int uid_)
{
    auto it = m_cache_deal_req.find(uid_);
    if (it == m_cache_deal_req.end())
        return;

    sc_msg_def::nt_add_gang_res_t nt;
    nt.ggid = db.ggid;
    nt.name = db.name();
    nt.code = it->second; 
    logic.unicast(uid_, nt);
    
    m_cache_deal_req.erase(it);
}
int sc_gang_t::deal_req(int uid_, int flag_)
{
    sc_msg_def::nt_add_gang_res_t nt;
    nt.ggid = db.ggid;
    nt.name = db.name();
    nt.code = SUCCESS; 
    string ser_nt_ok, ser_nt_failed; 
    nt >> ser_nt_ok;

    nt.code = ERROR_GANG_REFUSE_ADDREQ;
    nt >> ser_nt_failed;

    if (flag_ == 0)
    {
        if (uid_ == 0)
        {
            for(auto it=m_add_req_hm.begin();it!=m_add_req_hm.end();it++)
            {
                save_add_res(it->second.uid, -1, ser_nt_failed);
            }
            m_add_req_hm.clear();
        }
        else
        {
            if (m_add_req_hm.find(uid_) == m_add_req_hm.end())
                return ERROR_GANG_NO_ADDREQ;

            save_add_res(uid_, -1, ser_nt_failed);

            m_add_req_hm.erase(uid_);
        }

        return SUCCESS;
    }

    repo_def::guild_t* rp_guild = repo_mgr.guild.get(db.level);
    if (rp_guild == NULL)
    {
        logerror((LOG, "repo guild no level:%d", db.level));
        return ERROR_SC_EXCEPTION;
    }

    if (uid_ == 0)
    {
        for(auto it=m_add_req_hm.begin(); it!=m_add_req_hm.end(); it++)
        {
            if (rp_guild->member <= total_num())
            {
                save_add_res(it->second.uid, -1, ser_nt_failed);
                continue;
            }

            new_user(it->second, gang_member);
            save_add_res(it->second.uid, SUCCESS, ser_nt_ok);
        }
    }
    else
    {
        auto it = m_add_req_hm.find(uid_);
        if (it == m_add_req_hm.end())
            return ERROR_GANG_NO_ADDREQ;

        if (rp_guild->member <= total_num())
        {
            save_add_res(it->second.uid, -1, ser_nt_failed);
            return ERROR_GANG_HAS_FULL;
        }

        new_user(it->second, gang_member);
        save_add_res(uid_, SUCCESS, ser_nt_ok);
    }

    return SUCCESS;
}
void sc_gang_t::sort_mem()
{
    m_sort_mem.clear();
    for(auto it=m_ganguser_hm.begin();it!=m_ganguser_hm.end();it++)
    {
        sp_ganguser_t sp_guser = it->second;
        m_sort_mem.push_back(sp_guser);
    }

    std::stable_sort(m_sort_mem.begin(), m_sort_mem.end(), [](const sp_ganguser_t& a_, const sp_ganguser_t& b_){
        return (a_->db.grade > b_->db.grade);
    });

    std::stable_sort(m_sort_mem.begin(), m_sort_mem.end(), [](const sp_ganguser_t& a_, const sp_ganguser_t& b_){
        return (a_->db.totalgm > b_->db.totalgm);
    });

    std::stable_sort(m_sort_mem.begin(), m_sort_mem.end(), [](const sp_ganguser_t& a_, const sp_ganguser_t& b_){
        return(a_->db.flag > b_->db.flag);
    });
}
void sc_gang_t::get_memjpk_list(vector<sc_msg_def::jpk_gangmem_t>& list_, int page_)
{
    if (page_ < 1)
    {
        logerror((LOG, "get_memjpk_list, page<1!"));
        return;
    }

    sort_mem();

    for(size_t i=(page_-1)*15, n=0; i<m_sort_mem.size()&&n<15; i++, n++)
    {
        sp_ganguser_t sp_guser = m_sort_mem[i];
        sc_msg_def::jpk_gangmem_t jpk;
        sp_guser->get_mem_jpk(jpk,sp_guser->db.uid);
        list_.push_back(std::move(jpk));
    }
}
int sc_gang_t::kick_mem(int uid_, sp_ganguser_t sp_guser_)
{
    //不能自己踢自己
    if (sp_guser_->db.uid == uid_)
        return ERROR_GANG_OP_TARGET;

    sp_ganguser_t sp_target;
    if (!get_user(uid_, sp_target))
        return ERROR_GANG_NO_USER;

    int kickby_ = sp_guser_->db.flag;
    if (kickby_ < gang_adm)
        return ERROR_GANG_UNABLE_OP;
    if (sp_target->db.flag == gang_chairman)
        return ERROR_GANG_UNABLE_OP;
    if (sp_target->db.flag == gang_adm && kickby_ == gang_adm)
        return ERROR_GANG_UNABLE_OP;

    leave_gang(sp_target);

    sc_msg_def::nt_kick_gang_t nt;
    nt.ggid = db.ggid;
    logic.unicast(uid_, nt);

    //推送信封
    string mail = mailinfo.new_mail(mail_gang_kick, date_helper.str_date(), sp_guser_->db.nickname()); 
    if (!mail.empty())
    {
        notify_ctl.push_mail(uid_, mail);
    }

    return SUCCESS;
}
int sc_gang_t::leave_gang(sp_ganguser_t sp_guser_)
{
    if (sp_guser_->db.flag == gang_chairman)
        return ERROR_GANG_FLAG;

    int uid_ = sp_guser_->db.uid;
    m_online_role.erase(uid_);
    m_adm_uid.erase(uid_);
    m_ganguser_hm.erase(uid_);

    //修改公会成员为删除状态
    sp_guser_->set_leave_gang();
    gang_mgr.add_del_guser(sp_guser_);
    sp_guser_->save_db();
    
    //将社团boss伤害记录删除
    char sql[1024];
    sql_result_t res;
    sprintf(sql,"select uid from GangBossDamage where uid = %d",uid_);
    db_service.sync_select(sql,res);
    if (0 <= res.affect_row_num()){
        sprintf(sql,"delete from GangBossDamage where uid = %d",uid_);
        db_service.sync_execute(sql);
    }

    return SUCCESS;
}
int sc_gang_t::change_charman(sp_ganguser_t a_, sp_ganguser_t b_)
{
    if (a_ == NULL || b_ == NULL)
        return ERROR_SC_EXCEPTION;
    if (a_->db.flag != gang_chairman)
        return ERROR_GANG_FLAG;
    a_->db.set_flag(gang_member);
    a_->save_db();

    b_->db.set_flag(gang_chairman);
    b_->save_db();

    logwarn((LOG, "change_chairman: a %d, b %d", a_->db.uid, b_->db.uid));
    m_sp_chairman = b_;

    //推送信封
    string mail = mailinfo.new_mail(mail_gang_chairman, date_helper.str_date(), db.name()); 
    if (!mail.empty())
    {
        notify_ctl.push_mail(m_sp_chairman->db.uid, mail);
    }

    return SUCCESS;
}
int sc_gang_t::on_role_deleted(int uid_)
{
    //当角色删除的时候，如果是会长，则要处理相关会长转让，或者解散公会的操作
    sp_ganguser_t sp_deleted;
    if (!get_user(uid_, sp_deleted))
        return ERROR_GANG_NO_USER;

    //解散公会
    if (m_ganguser_hm.size() == 1)
    {
        //删除公会
        gang_mgr.del_gang(db.ggid);
        db_service.async_do((uint64_t)db.ggid, [](db_Gang_t& db_){
                db_.remove();
        }, db.data());
        goto tag_leave_gang;
    }

    //转让会长
    if (sp_deleted->db.flag == gang_chairman)
    {
        sp_ganguser_t sp_target;
        //转让给贡献值高的官员
        if (!m_adm_uid.empty())
        {
            for(auto it=m_adm_uid.begin();it!=m_adm_uid.end();it++)
            {
                if (*it == uid_)
                    continue;

                sp_ganguser_t sp_guser;
                if (get_user(*it, sp_guser))
                {
                    if (sp_target == NULL)
                        sp_target = sp_guser;
                    else if (sp_target->db.totalgm < sp_guser->db.totalgm)
                        sp_target = sp_guser;
                }
            }
        }
        else //没有官员则转让给贡献值高的会员
        {
            for(auto it = m_ganguser_hm.begin(); it!=m_ganguser_hm.end(); it++)
            {
                if (it->first == uid_)
                    continue;

                sp_ganguser_t sp_guser = it->second;
                if (sp_target == NULL)
                    sp_target = sp_guser;
                else if (sp_target->db.totalgm < sp_guser->db.totalgm)
                    sp_target = sp_guser;
            }
        }
        if (sp_target != NULL)
        {
            //change_charman(sp_deleted, sp_target);
        }
    }

    //离开公会
tag_leave_gang:
    //修改公会成员为删除状态
    leave_gang(sp_deleted);
    
    return SUCCESS;
}
void sc_gang_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.ggid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
int sc_gang_t::set_boss_time(sp_ganguser_t sp_guser_, int day_)
{
    if (db.level < 4)
        return ERROR_GANG_LEVEL;
    if (sp_guser_->db.flag != gang_chairman)
        return ERROR_GANG_FLAG;

    //下一周时间+1右移8位
    db.set_bossday((day_+1)<<8|(uint8_t)db.bossday); 
    db.set_lastboss(date_helper.cur_local_sec());
    save_db();

    //推送信封
    int offtime = db.ggid%10 * 5;
    string opentime = "21:";
    if (offtime < 10)
        opentime += "0"+std::to_string(offtime);
    else
        opentime += std::to_string(offtime);
    string mail = mailinfo.new_mail(mail_gang_boss_time, date_helper.str_dayofweek(day_), opentime); 

    sc_msg_def::nt_gang_boss_time_t nt;
    nt.day = day_; 
    string msg; nt >> msg;

    if (!mail.empty())
    {
        for(auto it=m_ganguser_hm.begin();it!=m_ganguser_hm.end(); it++)
        {
            notify_ctl.push_mail(it->first, mail);
            if (it->second->isonline)
                logic.unicast(it->first, nt.cmd(), msg);
        }
    }

    return SUCCESS;
}
void sc_gang_t::update_guser_paynum()
{
    for(auto it=m_ganguser_hm.begin(); it!=m_ganguser_hm.end(); it++)
    {
        it->second->update_praynum();
    }
}
void sc_gang_t::on_boss_killed(sp_ganguser_t sp_guser_)
{
    //推送信封
    string mail = mailinfo.new_mail(mail_gang_boss_killed, date_helper.str_date(), sp_guser_->db.nickname()); 
    if (!mail.empty())
    {
        for(auto it=m_ganguser_hm.begin();it!=m_ganguser_hm.end(); it++)
        {
            notify_ctl.push_mail(it->first, mail);
        }
    }
}
int sc_gang_t::given_hongbao(sp_user_t sp_user_, uint64_t id_)
{
    sc_msg_def::ret_hongbao_t ret;
    ret.code = SUCCESS;
    ret.id = id_;
    ret.uid = 0;
    ret.count = 0;

    auto it = m_hongbao_map.find(id_);
    if (it == m_hongbao_map.end())
        return -1;

    sp_ganguser_t sp_guser;
    if (!get_user(sp_user_->db.uid, sp_guser))
        return -1;

    auto itgh = sp_guser->m_gotted_hongbao.find(sp_user_->db.uid);
    if (itgh != sp_guser->m_gotted_hongbao.end())
    {
        if (date_helper.offday(itgh->second)>=1)
            sp_guser->m_gotted_hongbao.erase(itgh);
        else
            return -1;
    }

    for(auto it=sp_guser->m_gotted_hongbao.begin(); it!=sp_guser->m_gotted_hongbao.end();)
    {
        if (date_helper.offday(itgh->second)>=1)
            it = sp_guser->m_gotted_hongbao.erase(it);
        else it++;
    }

    if (sp_guser->m_gotted_hongbao.size() > MAX_PAY_HONGBAO)
        return -1;

    sp_guser->m_gotted_hongbao.insert(make_pair(sp_user_->db.uid, date_helper.cur_sec()));

    sc_hongbao_t& h = it->second;
    sp_user_->on_freeyb_change(h.yb);
    sp_user_->save_db();
    h.count--;
    ret.uid = sp_user_->db.uid;
    ret.count = h.count;
    ret.yb = h.yb;
    h.yb = random_t::rand_integer(1,20);
    ret.nickname = sp_user_->db.nickname();
    if (h.count <= 0)
        m_hongbao_map.erase(id_);
    string msg;
    ret >> msg;
    broadcast(sc_msg_def::ret_hongbao_t::cmd(), msg);

    return SUCCESS;
}
//=============================================
sc_gang_mgr_t::sc_gang_mgr_t():
m_max_ggid(0)
{
}

void sc_gang_mgr_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load gang ..."));

    map<uint32_t, sp_gang_t> tmp;
    for(size_t i=0; i<hostnums_.size(); i++)
    {
        sql_result_t res; 
        db_Gang_ext_t::sync_select_host_gang(hostnums_[i], res);
        for(size_t r=0; r<res.affect_row_num(); r++)
        {
            sp_gang_t sp_gang(new sc_gang_t);
            sp_gang->db.init(*res.get_row_at(r));
            tmp[sp_gang->db.ggid]=std::move(sp_gang);
        }
    }
    for(size_t i=0; i<hostnums_.size(); i++)
    {
        sql_result_t res_guser; 
        db_GangUser_ext_t::sync_select_ganguser(hostnums_[i], res_guser);

        for(size_t n=0; n<res_guser.affect_row_num(); n++)
        {
            sp_ganguser_t sp_guser(new sc_ganguser_t());
            sp_guser->db.init(*res_guser.get_row_at(n));

            auto it = tmp.find(sp_guser->db.ggid);
            if (it != tmp.end() && sp_guser->db.state == 1)
            {
                it->second->add_user(sp_guser);
            }
            else add_del_guser(sp_guser);
        }
    }

    for(auto it : tmp)
    {
        auto sp_gang = it.second;
        if (sp_gang->total_num() > 0 && sp_gang->get_chairman() != NULL)
        {
            add_gang(sp_gang);
        }
        else logerror((LOG, "gang is empty! ggid:%d", sp_gang->db.ggid));
    }

    sort_gang();

    logwarn((LOG, "load gang ...ok"));
}

bool sc_gang_mgr_t::get(int32_t ggid_, sp_gang_t &sp_gang_)
{
    auto it = m_gang_hm.find(ggid_);
    if (it != m_gang_hm.end())
    {
        sp_gang_ = it->second;
        return true;
    }
    return false;
}

int sc_gang_mgr_t::create_gang(sp_user_t sp_user_, string& name_)
{
    ys_tool_t::filter_str(name_);

    if (name_.empty())
        return ERROR_SC_ILLEGLE_REQ;

    for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
    {
        if (it->second->db.name() == name_)
            return ERROR_GANG_NAME_EXIST;
    }

    if (has_gang_by_uid(sp_user_->db.uid))
        return ERROR_GANG_NAME_EXIST;
    if (sp_user_->db.grade < 1)
        return ERROR_GANG_CREATE_LESS_LEVEL;
    int32_t remainyb = sp_user_->db.payyb + sp_user_->db.freeyb;
    if (remainyb < 500)
        return ERROR_GANG_CREATE_LESS_GOLD;
    
    logwarn((LOG, "before create gang, total yb = %d, uid = %d", (sp_user_->db.payyb + sp_user_->db.freeyb), sp_user_->db.uid));
    sp_user_->consume_yb(500);
    logwarn((LOG, "after create gang, total yb = %d, uid = %d", (sp_user_->db.payyb + sp_user_->db.freeyb), sp_user_->db.uid));
    /*if (sp_user_->db.payyb >= 500)
        sp_user_->on_payyb_change(-500);
    else if (sp_user_->db.payyb > 0)
    {
        sp_user_->on_payyb_change(-sp_user_->db.payyb);
        sp_user_->on_freeyb_change(sp_user_->db.payyb - 500);
    }else
        sp_user_->on_freeyb_change(-500);
    */

    //创建公会
    sp_gang_t sp_gang(new sc_gang_t);
    sp_gang->db.ggid = dbid_assign.new_dbid("ggid");
    sp_gang->db.hostnum = sp_user_->db.hostnum;
    sp_gang->db.exp = 0;
    sp_gang->db.level = 1;
    sp_gang->db.name = name_;
    sp_gang->db.notice = "";
    sp_gang->db.bosslv = 1;
    sp_gang->db.bossday = 6;
    sp_gang->db.bosscount = 0;
    sp_gang->db.todaycount = 0;
    sp_gang->db.lastboss = 0;
    add_gang(sp_gang);

    db_service.async_do((uint64_t)sp_gang->db.ggid, [](db_Gang_t& db_){
        db_.insert();
    }, sp_gang->db.data());

    sp_gang->new_user(sp_user_, gang_chairman);
    sp_gang->on_login(sp_user_->db.uid);

    return SUCCESS;
}
int sc_gang_mgr_t::unicast_ganginfo(int uid_, int ggid_)
{
    sp_gang_t sp_gang;
    if (!get(ggid_, sp_gang))
        return ERROR_GANG_NO_USER;

    sp_ganguser_t sp_guser;
    if (!sp_gang->get_user(uid_, sp_guser))
        return ERROR_GANG_NO_USER;

    sc_msg_def::ret_gang_info_t ret;
    
    sp_guser->get_mem_jpk(ret.mem,uid_);
    sp_gang->get_pro_jpk(uid_, ret.pro);
    ret.notice = sp_gang->db.notice();
    sp_gang->get_msg(ret.msgs);
    ret.dpm = sp_guser->get_daily_pay();
    int nextday = sp_gang->db.bossday>>8;
    ret.bossday = nextday>0 ? nextday-1 : (uint8_t)(sp_gang->db.bossday);
    ret.bosslv = sp_gang->db.bosslv;

    if (date_helper.offday(sp_gang->m_hongbao_stamp) >= 1)
    {
        sp_gang->m_hongbao_map.clear();
    }
    for(auto it=sp_gang->m_hongbao_map.begin(); it!=sp_gang->m_hongbao_map.end(); it++)
    {
        auto itgh = sp_guser->m_gotted_hongbao.find(it->second.uid);
        if (itgh != sp_guser->m_gotted_hongbao.end())
        {
            if (date_helper.offday(itgh->second)>=1)
                sp_guser->m_gotted_hongbao.erase(itgh);
            else continue;
        }

        ret.hongbao.push_back(it->second);
    }
    logic.unicast(uid_, ret);

    return SUCCESS;
}
int sc_gang_mgr_t::unicast_ganglist(int32_t uid_, int page_)
{
    sc_msg_def::ret_gang_list_t ret;

    for(size_t i=(page_-1)*10, n=0; i<m_gang_sort.size()&&n<10; i++, n++)
    {
        sp_gang_t sp_gang = m_gang_sort[i]->second;
        sc_msg_def::jpk_gang_pro_t jpk;
        sp_gang->get_pro_jpk(uid_, jpk);
        ret.gangs.push_back(std::move(jpk));
    }

    logic.unicast(uid_, ret);

    return SUCCESS;
}
int sc_gang_mgr_t::search_gang(int uid_, string& name_)
{
    sc_msg_def::ret_search_gang_t ret;

    if (name_ != "")
    {
        for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
        {
            if (it->second->db.name().find(name_) == string::npos)
                continue;

            sp_gang_t sp_gang = it->second;

            sc_msg_def::jpk_gang_pro_t jpk;
            sp_gang->get_pro_jpk(uid_, jpk);
            ret.gangs.push_back(std::move(jpk));
        }
    }

    logic.unicast(uid_, ret);

    return SUCCESS;
}
int sc_gang_mgr_t::set_notice(int uid_, string& notice_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_guser->db.flag < 1)
        return ERROR_GANG_FLAG;

    sp_gang->db.set_notice(notice_);
    sp_gang->save_db();

    return SUCCESS;
}
int sc_gang_mgr_t::add_msg(int uid_, int type_, string& msg_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    sp_gang->add_msg(sp_guser, type_, msg_);

    return SUCCESS;
}
int sc_gang_mgr_t::set_adm(int cuid_,int uid_, bool isadm_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(cuid_, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    return sp_gang->set_adm(cuid_,uid_, isadm_);
}

int sc_gang_mgr_t::pay(sp_user_t sp_user_, int money_, int rmb_, int& dpm_)
{
    dpm_ = 0;

    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    int cur_pay = 0;

    if (money_ == MAX_PAY_MONEY)
    {
        if (sp_user_->db.gold < money_ )
            return ERROR_SC_NO_GOLD;

        cur_pay = money_ * 1E-3 * 1E1;
        if (SUCCESS != sp_guser->on_daily_pay(cur_pay))
            return ERROR_SC_ILLEGLE_REQ;

        if (-1 == sp_user_->consume_gold(money_))
            return ERROR_SC_ILLEGLE_REQ;
    }
    else if (rmb_ == MAX_PAY_RMB || rmb_ == MAX_PAY_SUPER || rmb_ == MAX_PAY_HONGBAO)
    {
        if (rmb_ == MAX_PAY_HONGBAO && sp_user_->db.viplevel < 7)
            return -1;

        if (sp_user_->rmb() < rmb_)
            return ERROR_SC_NO_YB;

        cur_pay = rmb_ * 1E1;
        if (SUCCESS != sp_guser->on_daily_pay(cur_pay))
            return ERROR_SC_ILLEGLE_REQ;

        if (-1 == sp_user_->consume_yb(rmb_))
            return ERROR_SC_ILLEGLE_REQ;
    }
    else return ERROR_SC_ILLEGLE_REQ;

    dpm_ = sp_guser->get_daily_pay();


    //保存用户信息
    sp_user_->save_db();

    //修改公会贡献值
    sp_guser->db.set_gm(sp_guser->db.gm + cur_pay);
    sp_guser->db.set_totalgm(sp_guser->db.totalgm + cur_pay);
    sp_guser->save_db();

    //通知用户贡献值改变
    {
        sc_msg_def::nt_gang_pay_change_t nt;
        nt.gm = sp_guser->db.gm;
        nt.totalgm = sp_guser->db.totalgm;
        logic.unicast(sp_user_->db.uid, nt);
    }

    //保存公会信息
    int now_exp = sp_gang->db.exp + cur_pay;
    bool islevelup = false;
    repo_def::guild_t* rp_guild = repo_mgr.guild.get(sp_gang->db.level+1);
    while(rp_guild != NULL && rp_guild->exp <= now_exp)
    {
        islevelup = true;
        sp_gang->db.set_level(sp_gang->db.level+1);
        rp_guild = repo_mgr.guild.get(sp_gang->db.level+1);
    }
    sp_gang->db.set_exp(sp_gang->db.exp + cur_pay);
    sp_gang->save_db();

    if (islevelup)
    {
        sc_msg_def::nt_gang_level_change_t nt;
        nt.level = sp_gang->db.level;
        nt.exp = sp_gang->db.exp;
        logic.unicast(sp_user_->db.uid, nt);

        sp_gang->update_guser_paynum();
        sort_gang();
    }
    else
    {
        sc_msg_def::nt_gang_exp_change_t nt;
        nt.exp = sp_gang->db.exp;
        logic.unicast(sp_user_->db.uid, nt);
    }

    //产生红包
    if (rmb_ == MAX_PAY_HONGBAO)
    {
        sp_gang->m_hongbao_stamp = date_helper.cur_sec();
        uint32_t r = random_t::rand_integer(5, 15);
        sc_msg_def::nt_hongbao_t nt;

        sc_hongbao_t h;
        h.uid = sp_guser->db.uid;
        //发红包的人的装备等级
        h.quality = sc_user_t::get_equip_level(sp_guser->db.uid, 0);
        h.nickname  = sp_guser->db.nickname();
        h.id=(((uint64_t)(sp_guser->db.uid)<<32))|(1);
        h.yb= random_t::rand_integer(1, 20);
        h.count = r;
        nt.hongbao.push_back(h);
        sp_gang->m_hongbao_map[h.id] = h;

        sp_gang->m_hongbao_stamp = date_helper.cur_sec();

        string msg;
        nt >> msg;
        sp_gang->broadcast(sc_msg_def::nt_hongbao_t::cmd(), msg);

        string push_msg = pushinfo.get_push(push_hongbao,sp_user_->db.nickname(), sp_user_->db.grade, sp_user_->db.uid, sp_user_->db.viplevel);
        pushinfo.push_gang(sp_gang, push_msg);
    }

    return SUCCESS;
}
int sc_gang_mgr_t::close_gang(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_guser->db.flag != gang_chairman)
        return ERROR_GANG_FLAG;
    
    if (sp_gang->total_num() > 1)
        return ERROR_GANG_CLOSE;

    //删除公会
    del_gang(sp_gang->db.ggid);
    db_service.async_do((uint64_t)sp_gang->db.ggid, [](db_Gang_t& db_){
        db_.remove();
    }, sp_gang->db.data());

    //修改公会成员为删除状态
    sp_guser->set_leave_gang();
    gang_mgr.add_del_guser(sp_guser);
    sp_guser->save_db();

    return SUCCESS;
}
int sc_gang_mgr_t::learn_gskl(sp_user_t sp_user_, int resid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_user_->db.grade <= sp_guser->get_gskl_lv(resid_))
        return ERROR_GANG_LEARN_GSKL_LESS_LEVEL;

    int skill_lvl = sp_guser->get_gskl_lv(resid_);
    int keyid = resid_*1000 + skill_lvl;

    repo_def::guildskill_t* rp_gskl = repo_mgr.guildskill.get(keyid);
    if (rp_gskl == NULL)
        return ERROR_SC_EXCEPTION;

    repo_def::guildskill_t* rp_gsklNext = repo_mgr.guildskill.get(keyid+1);
    if (rp_gsklNext == NULL)
        return ERROR_SC_EXCEPTION;
    
    if (sp_gang->db.level < rp_gsklNext->unlock_guildlv)
        return ERROR_GANG_UNLOCK_SKL_LESS_LEVEL;
    
    int cost = rp_gsklNext->cost;

    if (cost == 0)
        return ERROR_SC_EXCEPTION;

    if (sp_guser->db.gm < cost) 
        return ERROR_GANG_LESS_GM;

    sp_guser->on_change_gm(-cost);
    sp_guser->upgrade_gskl(resid_);
    sp_guser->save_db();

    return SUCCESS;
}
int sc_gang_mgr_t::unicast_gskl_list(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    sc_msg_def::ret_gskl_list_t ret;
    ret.gm = sp_guser->db.gm;
    ret.lv = sp_gang->db.level;
    sp_guser->get_gskl_jpk(ret.gskls);
    logic.unicast(sp_user_->db.uid, ret);

    return SUCCESS;
}
int sc_gang_mgr_t::add_req(sp_user_t sp_user_, int32_t ggid_)
{
    //用户已经在公会中，则失败
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (!get(ggid_, sp_gang))
        return ERROR_GANG_NO_GANG;

    return sp_gang->add_req(sp_user_);
}
int sc_gang_mgr_t::unicast_reqlist(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_guser->db.flag < gang_adm)
        return ERROR_GANG_FLAG;

    sc_msg_def::ret_gang_reqlist_t ret;
    sp_gang->get_req(ret.reqs);
    logic.unicast(sp_user_->db.uid, ret);

    return SUCCESS;
}
int sc_gang_mgr_t::deal_gang_req(sp_user_t sp_user_, int uid_, int flag_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    if (sp_guser->db.flag < gang_adm)
        return ERROR_GANG_FLAG;

    if (has_gang_by_uid(uid_))
    {
        remove_req(uid_);
        return ERROR_GANG_ALREADY_IN_GANG;
    }

    int ret = sp_gang->deal_req(uid_, flag_);
    if (flag_ == 1 && ret == SUCCESS)
    {
        remove_req(uid_);
    }
    return ret;
}
void sc_gang_mgr_t::remove_req(int uid_)
{
    for(auto it=m_gang_hm.begin();it!=m_gang_hm.end();it++)
    {
        it->second->del_req(uid_);
    }
}
int sc_gang_mgr_t::unicast_mem(sp_user_t sp_user_, int page_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    sc_msg_def::ret_gang_mem_t ret;
    sp_gang->get_memjpk_list(ret.members, page_);
    logic.unicast(sp_user_->db.uid, ret);
    return SUCCESS;
}
int sc_gang_mgr_t::kick_mem(sp_user_t sp_user_, int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;
    return sp_gang->kick_mem(uid_, sp_guser);
}
int sc_gang_mgr_t::enter_pray(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;
    sp_guser->enter_pray(sp_user_);
    return SUCCESS;
}
int sc_gang_mgr_t::pray(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    sc_msg_def::ret_gang_pray_t ret;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
    {
        ret.code = ERROR_GANG_NO_USER;
        logic.unicast(sp_user_->db.uid, ret);
    }
    sp_guser->pray(sp_user_);
    return SUCCESS;
}
int sc_gang_mgr_t::change_charman(sp_user_t sp_user_, int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    sp_ganguser_t sp_new_chairman;
    if (!sp_gang->get_user(uid_, sp_new_chairman))
        return ERROR_GANG_NO_USER;
    
    return sp_gang->change_charman(sp_guser, sp_new_chairman);
}
int sc_gang_mgr_t::on_role_deleted(int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    sp_gang->on_role_deleted(uid_);
    return SUCCESS;
}
bool sc_gang_mgr_t::get_gang_by_uid(int uid_, sp_gang_t& sp_gang_, sp_ganguser_t& sp_guser_)
{
    for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
    {
        if (it->second->get_user(uid_, sp_guser_))
        {
            sp_gang_ = it->second;
            return true;
        }
    }
    return false;
}
bool sc_gang_mgr_t::has_gang_by_uid(int uid_)
{
    sp_ganguser_t sp_guser_;
    for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
    {
        if (it->second->get_user(uid_, sp_guser_))
        {
            return true;
        }
    }
    return false;
}
int sc_gang_mgr_t::leave_gang(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    return sp_gang->leave_gang(sp_guser);
}
int sc_gang_mgr_t::get_ggid_by_uid(int uid_)
{
    sp_ganguser_t sp_guser_;
    for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
    {
        if (it->second->get_user(uid_, sp_guser_))
        {
            return it->second->db.ggid;
        }
    }
    return 0;
}
void sc_gang_mgr_t::get_ggname_by_uid(int uid_, sc_msg_def::jpk_role_data_t& roleinfo)
{
    sp_ganguser_t sp_guser_;
    for(auto it=m_gang_hm.begin(); it!=m_gang_hm.end(); it++)
    {
        if(it->second->get_user(uid_, sp_guser_))
        {
            roleinfo.ggname = it->second->db.name();
       }
    }
}
void sc_gang_mgr_t::add_del_guser(sp_ganguser_t guser_)
{
    m_del_user_hm[guser_->db.uid] = guser_;
} 
void sc_gang_mgr_t::remove_del_guser(int uid_)
{
    m_del_user_hm.erase(uid_);
}
bool sc_gang_mgr_t::get_del_guser(int uid_, sp_ganguser_t& guser_)
{
    auto it = m_del_user_hm.find(uid_);
    if (it != m_del_user_hm.end())
    {
        guser_ = it->second;
        return true;
    }
    return false;
}
int sc_gang_mgr_t::set_boss_time(sp_user_t sp_user_, int day_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
        return ERROR_GANG_NO_USER;

    return sp_gang->set_boss_time(sp_guser, day_);
}
void sc_gang_mgr_t::sort_gang()
{
    std::sort(m_gang_sort.begin(), m_gang_sort.end(), [](const it_gang_t& a_, const it_gang_t& b_){
            return (a_->second->db.level > b_->second->db.level);
    });
}
void sc_gang_mgr_t::add_gang(sp_gang_t sp_gang_)
{
    auto it = m_gang_hm.insert(make_pair(sp_gang_->db.ggid, sp_gang_)).first;
    m_gang_sort.push_back(it);
}
void sc_gang_mgr_t::del_gang(int ggid_)
{
    auto it = std::find_if(m_gang_sort.begin(), m_gang_sort.end(), [&](const it_gang_t& a_){
        return (a_->second->db.ggid == ggid_);
    });
    if (it != m_gang_sort.end())
        m_gang_sort.erase(it);

    m_gang_hm.erase(ggid_);
}
int sc_gang_mgr_t::get_grank(int ggid_)
{
    auto it = std::find_if(m_gang_sort.begin(), m_gang_sort.end(), [&](const it_gang_t& a_){
        return (a_->second->db.ggid == ggid_);
    });
    if (it == m_gang_sort.end())
        return 0;
    else
        return (it-m_gang_sort.begin())+1;
}
int sc_gang_mgr_t::get_guser_pray_num(int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return 0;
    return sp_guser->get_pray_num();
}
int sc_gang_mgr_t::get_gang_add_req(int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return 0;
    if( 0 == sp_guser->db.flag )
        return 0;
    return sp_gang->get_req_count();
}
void sc_gang_mgr_t::on_level_up(int uid_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!get_gang_by_uid(uid_, sp_gang, sp_guser))
        return;

    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        sp_guser->db.set_grade(sp_user->db.grade);
        sp_guser->save_db();
    }
}
void sc_gang_mgr_t::refresh_chairman()
{
    for(auto it = m_gang_hm.begin();it != m_gang_hm.end(); ++it)
    {
        sql_result_t res;
        char sql[256];
        sprintf(sql, "select uid, lastquit from GangUser where flag = 2 and ggid = %d", it->second->db.ggid);
        db_service.sync_select(sql, res);
        if (0 == res.affect_row_num())    //没有找到
        {    
            continue;
        }
        sql_result_row_t& row = *res.get_row_at(0);
        int uid_gang = (int)std::atoi(row[0].c_str());
        int lastquit_chairman = (int)std::atoi(row[1].c_str());
        //当前的会长            
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (!get_gang_by_uid(uid_gang, sp_gang, sp_guser))
            continue;

        repo_def::guild_t* rp_guild = repo_mgr.guild.get(sp_gang->db.level);
        int offday_date;
        if (rp_guild == NULL)
            offday_date = 14;
        else
            offday_date = rp_guild->data;

        if( date_helper.offday(lastquit_chairman) >= offday_date )
        {
            //找到将要给会长的人
            sql_result_t res1;
            char sql1[256];
            int64_t stamp_lmt = date_helper.cur_sec() - 3600*24*7;
            sprintf(sql1, "select uid from GangUser where flag = 1 and ggid = %d and lastquit >= %ld order by totalgm DESC", it->second->db.ggid, stamp_lmt);
            db_service.sync_select(sql1, res1);
            if (0 == res1.affect_row_num())    //没有找到
            {    
                continue;
            }
            sql_result_row_t& row1 = *res1.get_row_at(0);
            int uid_new = (int)std::atoi(row1[0].c_str());

            sp_ganguser_t sp_new_chairman;
            if (!sp_gang->get_user(uid_new, sp_new_chairman))
                continue;

            //传授会长 
            sp_gang->change_charman(sp_guser, sp_new_chairman);
        }
    }
}
