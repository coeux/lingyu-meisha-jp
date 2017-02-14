#include "sc_server.h"
#include "date_helper.h"
#include "db_service.h"
#include "config.h"
#include "log.h"
#include "random.h"
#include "config.h"

#include "sc_cache.h"
#include "sc_name.h"
#include "sc_arena_page_cache.h"
#include "sc_statics.h"

#define LOG "SC_SERVER"

void sc_server_t::load_db(int32_t serid_)
{
    sql_result_t res;
    if (0==db_Server_t::sync_select_server(serid_, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        db.serid = serid_;
        db.bosslv = 1;
        db.maxlv = 1;
        db.result_rank_stamp = 0;
        db.ctime = date_helper.cur_0_stmp(); 
        db_service.async_do((uint64_t)0, [](db_Server_t& db_){
            db_.insert();
        }, db.data());

        statics_ins.add_new_zone_hostnum(config.get_domain(), serid_);
    }
}
void sc_server_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)0, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}
