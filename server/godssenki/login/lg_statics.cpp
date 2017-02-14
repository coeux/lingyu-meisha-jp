#include "lg_statics.h"

#include "date_helper.h"

#define LOG "LG_STATICS"

void lg_statics_t::unicast_newaccount(string &domain_,string &name_,int aid)
{
    db_NewAccount_t newaccount;
    newaccount.domain = domain_;
    newaccount.name = name_;
    newaccount.aid = aid;
    newaccount.ctime = date_helper.str_date_mysql(0);

    m_statics_db.async_do([](db_NewAccount_t& db_){
        string sql = db_.gen_insert_sql();
        lg_statics_ins.m_statics_db.async_execute(sql.c_str());
    }, newaccount);
}

