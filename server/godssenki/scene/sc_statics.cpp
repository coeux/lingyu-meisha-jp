#include "sc_statics.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_service.h"

#include "code_def.h"
#include "repo_def.h"
#include "date_helper.h"
#include "config.h"

#define LOG "SC_STATICS"

void sc_statics_t::unicast_buylog(sc_user_t &user_,int resid_,string &itemname_, int count_,int buytype_,int price_,int payyb_,int freeyb_,int fpoint_)
{
    //购买记录
    db_BuyLog_t buylog;
    buylog.uid = user_.db.uid;
    buylog.aid = user_.db.aid;
    buylog.domain = user_.plat_domain;
    buylog.hostnum = user_.db.hostnum;
    buylog.nickname = user_.db.nickname;
    buylog.vip = user_.db.viplevel;
    buylog.buytm = date_helper.str_date_mysql(0);
    buylog.resid = resid_;
    buylog.itemname = itemname_;
    buylog.count = count_;
    buylog.buytype = buytype_;
    buylog.price = price_;
    buylog.payyb = payyb_;
    buylog.freeyb = freeyb_;
    buylog.fpoint = fpoint_;

    m_statics_db.async_do((uint64_t)user_.db.uid, [](db_BuyLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, buylog);
}

void sc_statics_t::unicast_eventlog(sc_user_t &user_,int eid_,int rid_,int ct_,int cd_,int flag_,string extra_)
{
    //购买记录
    db_EventLog_t eventlog;
    eventlog.uid = user_.db.uid;
    eventlog.aid = user_.db.aid;
    eventlog.domain = user_.plat_domain;
    eventlog.hostnum = user_.db.hostnum;
    eventlog.nickname = user_.db.nickname;
    eventlog.eventid = eid_;
    eventlog.eventm = date_helper.str_date_mysql(0);
    eventlog.resid = rid_;
    eventlog.count = ct_<0?0:ct_;
    eventlog.code = cd_;
    eventlog.flag = flag_<0?0:flag_;
    eventlog.extra = extra_;

    m_statics_db.async_do((uint64_t)user_.db.uid, [](db_EventLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, eventlog);
}

void sc_statics_t::unicast_loginlog(sp_user_t sp_user_)
{
    //登录记录
    db_Online_t loginlog;
    loginlog.uid = sp_user_->db.uid;
    loginlog.aid = sp_user_->db.aid;
    loginlog.serid = config.serid;
    loginlog.name = sp_user_->plat_name;
    loginlog.domain = sp_user_->plat_domain;
    loginlog.sys = sp_user_->sys;
    loginlog.device = sp_user_->device;
    loginlog.os = sp_user_->os;
    loginlog.hostnum = sp_user_->db.hostnum;
    loginlog.nickname = sp_user_->db.nickname;
    loginlog.counttime = sp_user_->db.totaltime;
    loginlog.logintm = date_helper.str_date_mysql(sp_user_->login_time);
    loginlog.loginstamp = sp_user_->login_time;
    loginlog.mac = sp_user_->mac;
    loginlog.grade = sp_user_->db.grade;
    loginlog.exp = sp_user_->db.exp;
    loginlog.resid = sp_user_->db.resid;
    loginlog.vip = sp_user_->db.viplevel;
    loginlog.questid = sp_user_->db.questid;
    //loginlog.nextquestid = sp_user_->db.nextquestid;

    m_statics_db.async_do((uint64_t)sp_user_->db.uid, [](db_Online_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, loginlog);
}

void sc_statics_t::unicast_newrole(sp_user_t sp_user_, string &mac_,string &domain_)
{
    db_NewRole_t newrole;
    newrole.domain = domain_;
    newrole.hostnum = sp_user_->db.hostnum;
    newrole.aid = sp_user_->db.aid;
    newrole.uid = sp_user_->db.uid;
    newrole.mac = mac_;
    newrole.ctime = date_helper.str_date_mysql(0);
    
    m_statics_db.async_do((uint64_t)sp_user_->db.uid, [](db_NewRole_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, newrole);
}

void sc_statics_t::unicast_quitlog(sp_user_t sp_user_)
{
    //退出记录
    db_QuitLog_t quitlog;
    quitlog.uid = sp_user_->db.uid;
    quitlog.aid = sp_user_->db.aid;
    quitlog.name = sp_user_->plat_name;
    quitlog.domain = sp_user_->plat_domain;
    quitlog.sys = sp_user_->sys;
    quitlog.device = sp_user_->device;
    quitlog.os = sp_user_->os;
    quitlog.hostnum = sp_user_->db.hostnum;
    quitlog.nickname = sp_user_->db.nickname;
    quitlog.totaltime = sp_user_->db.totaltime;
    quitlog.counttime = sp_user_->counttime;
    quitlog.logintm = date_helper.str_date_mysql(sp_user_->login_time);
    quitlog.quittm = date_helper.str_date_mysql(sp_user_->db.lastquit);
    quitlog.mac = sp_user_->mac;
    quitlog.grade = sp_user_->db.grade;
    quitlog.exp = sp_user_->db.exp;
    quitlog.resid = sp_user_->db.resid;
    quitlog.vip = sp_user_->db.viplevel;
    quitlog.questid = sp_user_->db.questid;
    //quitlog.nextquestid = sp_user_->db.nextquestid;
    quitlog.step = sp_user_->current_step;

    m_statics_db.async_do((uint64_t)sp_user_->db.uid, [](db_QuitLog_t& db_,int32_t time_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
        
        char sql_[256];
        sprintf(sql_,"delete from Online where serid=%d and uid=%d",config.serid,db_.uid);
        statics_ins.m_statics_db.async_execute(sql_);
    }, quitlog,sp_user_->login_time);
}

void sc_statics_t::clear_loginlog()
{
    char sql[128];
    sprintf(sql,"delete from Online where serid=%d",config.serid);
    m_statics_db.sync_execute(sql);
}

void sc_statics_t::unicast_consumelog(sc_user_t &user_,int resid_,int consumetype_,int count_,int balance_)
{
    //购买记录
    db_ConsumeLog_t consumelog;
    consumelog.uid = user_.db.uid;
    consumelog.aid = user_.db.aid;
    consumelog.domain = user_.plat_domain;
    consumelog.hostnum = user_.db.hostnum;
    consumelog.nickname = user_.db.nickname;
    consumelog.consumetm = date_helper.str_date_mysql(0);
    consumelog.consumetype = consumetype_;
    consumelog.resid = resid_;
    consumelog.count = count_;
    consumelog.balance = balance_;

    repo_def::item_t* rp_item = repo_mgr.item.get(resid_);
    if (rp_item != NULL)
        consumelog.itemname = rp_item->name;

    m_statics_db.async_do((uint64_t)user_.db.uid, [](db_ConsumeLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, consumelog);
}

void sc_statics_t::unicast_yblog(sp_user_t user_,db_Pay_ext_t &order_)
{
    //购买记录
    db_YBLog_t yblog;
    yblog.uid = user_->db.uid;
    yblog.aid = user_->db.aid;
    yblog.hostnum = user_->db.hostnum;
    yblog.sid = order_.sid;
    yblog.nickname = user_->db.nickname;
    yblog.name = user_->plat_name;
    yblog.domain = user_->plat_domain;
    yblog.appid = order_.appid();
    yblog.serid = order_.serid;
    yblog.payyb = order_.cristal;
    yblog.freeyb = order_.reward_cristal;
    yblog.totalyb = user_->db.payyb+user_->db.freeyb+yblog.payyb+yblog.freeyb;
    yblog.resid = order_.goodsid;
    yblog.price = order_.repo_rmb;
    yblog.count = order_.goodnum;
    yblog.rmb = order_.pay_rmb;
    yblog.tradetm = order_.paytime();
    yblog.giventm = date_helper.str_date_mysql(0);

    m_statics_db.async_do((uint64_t)user_->db.uid, [](db_YBLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, yblog);
}

void sc_statics_t::unicast_freeyblog(sc_user_t &user_,int32_t freeyb_)
{
    //购买记录
    db_YBLog_t yblog;
    yblog.uid = user_.db.uid;
    yblog.aid = user_.db.aid;
    yblog.hostnum = user_.db.hostnum;
    yblog.sid = 0;
    yblog.nickname = user_.db.nickname;
    yblog.name = user_.plat_name;
    yblog.domain = user_.plat_domain;
    yblog.appid = "";
    yblog.serid = 0;
    yblog.payyb = 0;
    yblog.freeyb = freeyb_;
    yblog.totalyb = user_.db.payyb+user_.db.freeyb;
    yblog.resid = 0;
    yblog.price = 0;
    yblog.count = 0;
    yblog.rmb = 0;
    yblog.giventm = date_helper.str_date_mysql(0);
    yblog.tradetm = yblog.giventm;

    m_statics_db.async_do((uint64_t)user_.db.uid, [](db_YBLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, yblog);
}

void sc_statics_t::unicast_fpexception(sc_user_t &user_,int32_t resid_, int32_t resfp_)
{
    //购买记录
    db_FpException_t fpe;
    fpe.uid = user_.db.uid;
    fpe.aid = user_.db.aid;
    fpe.hostnum = user_.db.hostnum;
    fpe.nickname = user_.db.nickname;
    fpe.domain = user_.plat_domain;
    fpe.resid = resid_;
    fpe.rolefp = user_.db.fp;
    fpe.resfp = resfp_;

    m_statics_db.async_do((uint64_t)user_.db.uid, [](db_FpException_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, fpe);
}

void sc_statics_t::unicast_newaccount(string &domain_,string &name_,int aid)
{
    db_NewAccount_t newaccount;
    newaccount.domain = domain_;
    newaccount.name = name_;
    newaccount.aid = aid;
    newaccount.ctime = date_helper.str_date_mysql(0);

    m_statics_db.async_do([](db_NewAccount_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, newaccount);
}

void sc_statics_t::add_new_zone_hostnum(const string& zone_, int hostnum_)
{
    m_statics_db.async_do([](const string& zone_, int hostnum_){
        char sql[1024];
        sprintf(sql, "insert into stat_zone_hostnum (`zone`, `hostnum`) values ('%s', %d)", zone_.c_str(), hostnum_);
        statics_ins.m_statics_db.async_execute(sql);
    }, zone_, hostnum_);
}

void sc_statics_t::unicast_card_event_user_log(db_CardEventUser_ext_t& card_event_db, int season_id)
{
    db_CardEventUserLog_t log_db;
    log_db.uid = card_event_db.uid;
    log_db.hostnum = card_event_db.hostnum;
    log_db.score = card_event_db.score;
    log_db.coin = card_event_db.coin;
    log_db.goal_level = card_event_db.goal_level;
    log_db.round = card_event_db.round;
    log_db.round_status = card_event_db.round_status;
    log_db.round_max = card_event_db.round_max;
    log_db.reset_time = card_event_db.reset_time;
    log_db.pid1 = card_event_db.pid1;
    log_db.pid2 = card_event_db.pid2;
    log_db.pid3 = card_event_db.pid3;
    log_db.pid4 = card_event_db.pid4;
    log_db.pid5 = card_event_db.pid5;
    log_db.anger = card_event_db.anger;
    log_db.enemy_view_data = card_event_db.enemy_view_data;
    log_db.hp1 = card_event_db.hp1;
    log_db.hp2 = card_event_db.hp2;
    log_db.hp3 = card_event_db.hp3;
    log_db.hp4 = card_event_db.hp4;
    log_db.hp5 = card_event_db.hp5;
    log_db.difficult = card_event_db.difficult;
    log_db.season = card_event_db.season;

    m_statics_db.async_do([](db_CardEventUserLog_t& db_){
        string sql = db_.gen_insert_sql();
        statics_ins.m_statics_db.async_execute(sql.c_str());
    }, log_db);
    
}
