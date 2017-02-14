#include "sc_sign.h"
#include "sc_user.h"
#include "db_def.h"
#include "sc_logic.h"
#include "sc_shop.h"
#include "code_def.h"
#include "repo_def.h"
#include "date_helper.h"


#define LOG "SC_SIGN"

sc_sign_t::sc_sign_t(sc_user_t& user_): m_user(user_)
{
}

//请求每日签到奖励
int sc_sign_t::get_sign_reward(int id_)
{
    if (id_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::daily_sign_t* rp_sign = repo_mgr.daily_sign.get(id_);
    if (rp_sign->data != date_helper.cur_month())
       return ERROR_SC_EXCEPTION;
    if (rp_sign->day  != date_helper.cur_dayofmonth())
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* sign_item = repo_mgr.item.get(rp_sign->reward[1]);
    if (sign_item == NULL)
    {   
        logerror((LOG, "sign repo no have item! sign id = %d", id_));
        return ERROR_SC_EXCEPTION;
    }
    if ((m_user.db.sign_daily >> date_helper.cur_dayofmonth() & 1 ) == 1 )
    { 
        logerror((LOG, "havle areadly sign!"));
        return ERROR_SC_EXCEPTION;
    }
    if ( 2 == sign_item->type)
    {
        //装备不能叠加
        if( (m_user.bag.get_size() - m_user.bag.get_current_size()) < rp_sign->reward[2])
            return ERROR_BAG_FULL;
    }
    else
    {
        if(m_user.bag.is_full())
            return ERROR_BAG_FULL;
    }   
    sc_msg_def::nt_bag_change_t nt;  
    int num = rp_sign->reward[2];
    if (m_user.db.viplevel >= rp_sign->vip_level && rp_sign->vip_level != 0)
        num = num * rp_sign->times;
    m_user.item_mgr.addnew(rp_sign->reward[1],num, nt); 
    m_user.item_mgr.on_bag_change(nt);
    m_user.db.set_sign_daily( m_user.db.sign_daily + (1 << date_helper.cur_dayofmonth()));
    m_user.save_db();
    return SUCCESS;
}

//补签
int sc_sign_t::get_sign_remedy(int id_)
{
    if (id_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::daily_sign_t* rp_sign = repo_mgr.daily_sign.get(id_);
    if (rp_sign->data != date_helper.cur_month())
       return ERROR_SC_EXCEPTION;
    repo_def::item_t* sign_item = repo_mgr.item.get(rp_sign->reward[1]);
    if (sign_item == NULL)
    {   
        logerror((LOG, "sign repo have no item! sign id = %d", id_));
        return ERROR_SC_EXCEPTION;
    }
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT unix_timestamp(ctime) FROM UserInfo where uid = %d and hostnum = %d ;", m_user.db.uid,m_user.db.hostnum);
    if (0 == db_service.sync_select(sql, res))
    {
        sql_result_row_t& row_ = *res.get_row_at(0);
        //创建角色时间戳
        uint32_t ctime = (uint32_t)std::atoi(row_[0].c_str());
        time_t tp;
        time(&tp);
        struct tm* p = localtime(&tp);
        //签到当天时间戳
        uint32_t signstamp = date_helper.trans_unixstamp(( p->tm_year + 1900) * 10000 + id_);
        if(signstamp < ctime && ((ctime - signstamp > 86400)))
        {
            logerror((LOG,"sign from create time before"));
            return ERROR_DAILY_TIME_TOO_EARLY;
        }
    }
    if ((m_user.db.sign_daily >> rp_sign->day & 1 ) == 1 || rp_sign->day >= date_helper.cur_dayofmonth())
    { 
        logerror((LOG, "sign  add equips error2!"));
        return ERROR_SC_EXCEPTION;
    }
    if ( 2 == sign_item->type)
    {
        //装备不能叠加
        if( (m_user.bag.get_size() - m_user.bag.get_current_size()) < rp_sign->reward[2])
            return ERROR_BAG_FULL;
    }
    else
    {
        if(m_user.bag.is_full())
            return ERROR_BAG_FULL;
    }   
    if (m_user.rmb() >= m_user.db.sign_cost)
    {
        m_user.consume_yb(m_user.db.sign_cost);
        m_user.db.set_sign_cost( m_user.db.sign_cost + 20);
        m_user.save_db();
    }else return ERROR_SC_NO_YB;
 
    sc_msg_def::nt_bag_change_t nt;  
    int num = rp_sign->reward[2];
    if (m_user.db.viplevel >= rp_sign->vip_level && rp_sign->vip_level != 0)
        num = num * rp_sign->times;
    m_user.item_mgr.addnew(rp_sign->reward[1], num, nt);
    m_user.item_mgr.on_bag_change(nt);
    m_user.db.set_sign_daily( m_user.db.sign_daily + (1 << rp_sign->day));
    m_user.save_db();
    return SUCCESS;
}
