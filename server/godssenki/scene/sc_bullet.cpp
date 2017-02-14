#include "sc_bullet.h"
#include "date_helper.h"

bool sc_bullet_t::addnew(string msg_, int time_, int pos_, int round_)
{
    db.msg = msg_;
    db.uid = m_user->db.uid;
    db.pos = pos_;
    db.stamp = date_helper.cur_sec();
    db.round = round_;
    db_service.async_do((uint64_t)db.uid, [](db_Bullet_t& db_){
            db_.insert();
            }, db);
    return true;
}

void sc_bullet_t::getList(int round_, sc_msg_def::ret_bullet_t& ret)
{
    sql_result_t res;
    db_Bullet_t dbBullet;
    dbBullet.sync_select_round(round_, res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {   
        if (res.get_row_at(i) == NULL)
            break;

        db.init(*res.get_row_at(i));

        sc_msg_def::bullet_t t;
        t.pos = db.pos;
        t.stamp = db.stamp;
        t.msg = db.msg();

        ret.bullets.push_back(t);
    }
}
