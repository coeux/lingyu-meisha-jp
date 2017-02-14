#include "sc_report.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "date_helper.h"

#define LOG "SC_REPORT"

sc_report_t::sc_report_t(sc_user_t& user_)
:m_user(user_)
{
}

void sc_report_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void sc_report_t::load_db()
{
    sql_result_t res;
    if (0 == db_ReportUser_t::sync_select(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        init_new_user();
    }
}

void sc_report_t::init_new_user()
{
    db.uid = m_user.db.uid;
    db.reportNum = 0;
    db.accusedNum = 0;
    db.reportTime = 0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_ReportUser_t& db_) {
        db_.insert();
    }, db.data());
}

int32_t sc_report_t::get_info()
{
    load_db();
    if(db.accusedNum >= 15)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int32_t sc_report_t::reportuser(int32_t uid_)
{
        if(db.reportTime <= date_helper.cur_0_stmp())
        {
            db.reportNum = 0;
            db.set_reportNum(db.reportNum);
            db.reportTime = date_helper.cur_sec();
            db.set_reportTime(db.reportTime);
        }
         
        sc_msg_def::nt_report_t nt;
        
        if (db.reportNum >= 5)
        {
            nt.code = ERROR_REPORT_HAVE_NOTIMES;
            logic.unicast(m_user.db.uid, nt);
            return FAILED;
        }
        sql_result_t res;
        char sql[1024];
        sprintf(sql, "select * from Report where uid = %d and reportuid = %d;", m_user.db.uid, uid_);
        db_service.sync_select(sql, res);
        if (0<res.affect_row_num())
        { 
            nt.code = ERROR_REPORT_HAVE_REPORTED;
            logic.unicast(m_user.db.uid, nt);
        }
        else
        {
            sql_result_t res2;
            char sql2[1024];
            sprintf(sql2, "update ReportUser set accusedNum = accusedNum + 1 where uid = %d;", uid_);
            db_service.sync_select(sql2, res2);
            sql_result_t res3;
            char sql3[1024];
            sprintf(sql3, "INSERT INTO `Report` ( `uid`, `reportuid`) VALUES ('%d', '%d');", m_user.db.uid, uid_);
            db_service.sync_select(sql3, res3);
            db.reportNum = db.reportNum + 1;    
            db.set_reportNum(db.reportNum);
            db.reportTime = date_helper.cur_sec();
            db.set_reportTime(db.reportTime);
            nt.code = SUCCESS;
            logic.unicast(m_user.db.uid, nt); 
        }
        save_db();
 
}

