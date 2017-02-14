#ifndef _sc_statics_h_
#define _sc_statics_h_

#include <boost/shared_ptr.hpp>
#include <string>

#include "singleton.h"
#include "db_service.h"
#include "db_ext.h"

using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_statics_t
{
public:
    void unicast_buylog(sc_user_t &user_,int resid_,string &itemname_, int count_,int buytype_,int price_,int payyb_,int freeyb_,int fpoint_);
    void unicast_loginlog(sp_user_t sp_user_);
    void unicast_quitlog(sp_user_t sp_user_);
    void unicast_consumelog(sc_user_t &user_,int resid_,int consumetype_,int count_,int balance_);
    void unicast_yblog(sp_user_t user_,db_Pay_ext_t &order_);
    void unicast_freeyblog(sc_user_t &user_,int32_t freeyb_);
    //eid 事件id
    //rid 表格id
    //count 物品个数
    //code 返回码
    //flag 标志位
    void unicast_eventlog(sc_user_t &user_,int eventid_,int resid_=0,int count_=0,int code_=0,int flag_=0,string extra_="");
    void unicast_newrole(sp_user_t sp_user_, string &mac_,string &domain_);
    void unicast_card_event_user_log(db_CardEventUser_ext_t& card_event_db, int season_id);
    void clear_loginlog();
    void unicast_fpexception(sc_user_t &user_,int32_t resid_, int32_t resfp_);
    void unicast_newaccount(string &domain_,string &name_,int aid);
    void add_new_zone_hostnum(const string& zone_, int hostnum_);
public:
    db_service_t m_statics_db;
};

#define statics_ins (singleton_t<sc_statics_t>::instance())

#endif
