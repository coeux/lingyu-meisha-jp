#include "sc_pub_mgr.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_PUB_MGR"

sc_pub_mgr_t::sc_pub_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_pub_mgr_t::init_new_user()
{
    db.uid = m_user.db.uid;
    db.pub_3_first = 0;
	db.pub_4_first = 0;
	db.pub_sum = 0;
	db.stepup_state = 1;
    db.event_state = 1;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_PubMgr_t& db_) {
        db_.insert();
    }, db.data());
}

void sc_pub_mgr_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

void sc_pub_mgr_t::load_db()
{
	sql_result_t res;
    if (0 == db_PubMgr_t::sync_select(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        init_new_user();
    }
}

bool sc_pub_mgr_t::is_pub_3_first()
{
	return (db.pub_3_first == 0);
}

void sc_pub_mgr_t::set_pub_3_first()
{
	db.set_pub_3_first(1);
	db.pub_3_first = 1;
	save_db();
}

bool sc_pub_mgr_t::is_pub_4_first()
{
	return (db.pub_4_first == 0);
}

void sc_pub_mgr_t::set_pub_4_first()
{
	db.set_pub_4_first(1);
	db.pub_4_first = 1;
	save_db();
}

void sc_pub_mgr_t::add_pub_sum(int32_t num_)
{
	db.pub_sum = db.pub_sum + num_;
	db.set_pub_sum(db.pub_sum);
	save_db();
}

int32_t sc_pub_mgr_t::get_stepup_state()
{
	return db.stepup_state;
}

void sc_pub_mgr_t::add_stepup_state()
{
	db.stepup_state++;
	if (db.stepup_state > 5)
		db.stepup_state = 1;
	db.set_stepup_state(db.stepup_state);
    save_db();
}

int32_t sc_pub_mgr_t::get_event_state()
{
	return db.event_state;
}

void sc_pub_mgr_t::add_event_state()
{
	db.event_state++;
	if (db.event_state > 5)
		db.event_state = 1;
	db.set_event_state(db.event_state);
    save_db();
}
