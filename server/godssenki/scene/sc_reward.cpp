#include "sc_reward.h"
#include "sc_server.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_arena_rank.h"
#include "sc_equip.h"
#include "log.h"
#include "code_def.h"
#include "invcode_msg_def.h"
#include "db_def.h"
#include "db_service.h"
#include "sc_statics.h"
#include "dbgl_service.h"
#include "config.h"
#include "date_helper.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_pub_rank.h"
#include "sc_push_def.h"
#include "random.h"
#include "time.h"
#include "sc_limit_round.h"

#define LOG "SC_REWARD"
#define ACC_LG_LEVEL 24

#define INV_LV1 27
#define INV_LV2 33
#define INV_LV3 40
#define INV_LV4 50

int char_to_integer(char key)
{
    if('0' <= key && key <= '9')
        return key - '0';
    else if('a' <= key && key <= 'z')
        return key - 'a' + 10;
    else
        return -1;
}

char integer_to_char(int value)
{
    char char_map[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    if(0 <= value && value <= 35)
        return char_map[value];
    else
        return '@';
}

bool sc_reward_t::is_activity_open(int32_t activity_type_)
{
    //读取表格
    repo_def::activity_time_t *p_at = NULL;
    p_at = repo_mgr.activity_time.get(activity_type_);
    if( NULL == p_at )
        return false;

    switch( p_at->sort )
    {
        case 1:
            {
                string date = date_helper.str_date_only();
                if( p_at->start<=date && date<=p_at->end )
                    return true;
            }
            break;
    }

    return false;
}

sc_reward_t::sc_reward_t(sc_user_t& user_):m_user(user_)
{
    m_is_first_login = 1;   
    m_vips[0] = &(db.vip1);
    m_vips[1] = &(db.vip2);
    m_vips[2] = &(db.vip3);
    m_vips[3] = &(db.vip4);
    m_vips[4] = &(db.vip5);
    m_vips[5] = &(db.vip6);
    m_vips[6] = &(db.vip7);
    m_vips[7] = &(db.vip8);
    m_vips[8] = &(db.vip9);
    m_vips[9] = &(db.vip10);
    m_vips[10] = &(db.vip11);
    m_vips[11] = &(db.vip12);
    m_vips[12] = &(db.vip13);
    m_vips[13] = &(db.vip14);
    m_vips[14] = &(db.vip15);
    m_vips[15] = &(db.vip16);
    m_vips[16] = &(db.vip17);
    m_vips[17] = &(db.vip18);

    m_acclgs[0] = &(db.acc_lg1);
    m_acclgs[1] = &(db.acc_lg2);
    m_acclgs[2] = &(db.acc_lg3);
    m_acclgs[3] = &(db.acc_lg4);
    m_acclgs[4] = &(db.acc_lg5);
    m_acclgs[5] = &(db.acc_lg6);
    m_acclgs[6] = &(db.acc_lg7);
    m_acclgs[7] = &(db.acc_lg8);
    m_acclgs[8] = &(db.acc_lg9);
    m_acclgs[9] = &(db.acc_lg10);
    m_acclgs[10] = &(db.acc_lg11);
    m_acclgs[11] = &(db.acc_lg12);
    m_acclgs[12] = &(db.acc_lg13);
    m_acclgs[13] = &(db.acc_lg14);
    m_acclgs[14] = &(db.acc_lg15);
    m_acclgs[15] = &(db.acc_lg16);
    m_acclgs[16] = &(db.acc_lg17);
    m_acclgs[17] = &(db.acc_lg18);
    m_acclgs[18] = &(db.acc_lg19);
    m_acclgs[19] = &(db.acc_lg20);
    m_acclgs[20] = &(db.acc_lg21);
    m_acclgs[21] = &(db.acc_lg22);
    m_acclgs[22] = &(db.acc_lg23);
    m_acclgs[23] = &(db.acc_lg24);
}
void sc_reward_t::init_db()
{
    db_Reward_t& sdb = (db_Reward_t&)db;
    memset( &sdb, 0, sizeof(sdb) );
    db.uid = m_user.db.uid;

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Reward_t& db_){
        db_.insert();
    }, db.data());
    
    db_RewardExtentionI_t& extdb = (db_RewardExtentionI_t&)db_ext;
    memset( &extdb, 0, sizeof(extdb) );
    db_ext.uid = m_user.db.uid;

    db_service.async_do((uint64_t)m_user.db.uid, [](db_RewardExtentionI_t& db2_){
        db2_.insert();
    }, db_ext.data());
}
void sc_reward_t::load_db()
{
    sql_result_t res;
    if (0==db_Reward_t::sync_select_reward(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    if (0==db_RewardExtentionI_t::sync_select_reward(m_user.db.uid, res))
    {
        db_ext.init(*res.get_row_at(0));
    }else{
        db_ext.uid = m_user.db.uid;
        db_ext.sevenpay_stage = "0";
        db_ext.lastpay_timestamp = 0;
        db_ext.sevenpay_count = 0;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_RewardExtentionI_t& db2_){
        db2_.insert();
    }, db_ext.data());

    }

    load_starreward();
    update_daily_pay();
    update_single_pay();
    update_openyb_info();
    update_daily_consume_power();
    update_daily_draw();
    update_daily_melting();
    update_daily_talent();
    update_sevenpay_info();
}
void sc_reward_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Reward_t::select_reward(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    sql_result_t res_ext;
    if (0==db_RewardExtentionI_t::select_reward(m_user.db.uid, res_ext))
    {
        db_ext.init(*res_ext.get_row_at(0));
    }
    async_load_starreward();
    update_daily_pay();
    update_single_pay();
    update_daily_consume_power();
    update_daily_draw();
    update_daily_melting();
    update_daily_talent();
}
void sc_reward_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

void sc_reward_t::save_db_ext()
{
    string sql = db_ext.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db_ext.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);

}
void sc_reward_t::get_login_jpk(sc_msg_def::ret_lg_rewardinfo_t& data_)
{
    data_.con_lg[0] = db.con_lg1;
    data_.con_lg[1] = db.con_lg2;
    data_.con_lg[2] = db.con_lg3;
    data_.con_lg[3] = db.con_lg4;
    data_.con_lg[4] = db.con_lg5;
    
    for(int i=0; i<ACC_LG_LEVEL; i++)
    {
        data_.acc_lg[i] = *m_acclgs[i];
    }

    data_.acclgexp = db.acclgexp;
    data_.month = get_month_delta()+1;

    data_.sec_2_tom = date_helper.sec_2_tomorrow(0);
}

/*
 * date string to uint32_t time stamp
 * 2015-01-01 00:00:00 => 1420041600
 */
uint32_t sc_reward_t::str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

int32_t sc_reward_t::buy_growing_package(string &str)
{
    if (db.growing_package_status == 1)
        return ERROR_SC_ILLEGLE_REQ;
    if (db.is_consume_hundred != 1)
        return ERROR_SC_ILLEGLE_REQ;
    repo_def::configure_t * rp_config = NULL;
    int consume_yb = 888;
    if ((rp_config = repo_mgr.configure.get(16)) != NULL)
        consume_yb = rp_config->value;
    //这里需要读表，表还没有配好，暂时写死
    if ((m_user.db.payyb + m_user.db.freeyb) < consume_yb)
        return ERROR_SC_NO_YB;
    
    //扣除钻石
    logwarn((LOG, "before buy growing package, total yb = %d, uid = %d", (m_user.db.payyb + m_user.db.freeyb), m_user.db.uid));
    m_user.consume_yb(consume_yb);
    logwarn((LOG, "after buy growing package, total yb = %d, uid = %d", (m_user.db.payyb + m_user.db.freeyb), m_user.db.uid));

    db.set_growing_package_status(1);
    save_db();
    
    //更新奖励状态
    repo_def::growup_reward_t * rp_growup_reward = NULL;
    int index = 1;
    for (; (rp_growup_reward = repo_mgr.growup_reward.get(index)) != NULL; ++index)
    {
        if (rp_growup_reward->level > m_user.db.grade)
            break;
        if (index >  (int)db.growing_reward.length())
            db.growing_reward.append(index - db.growing_reward.length(), '1');
        
        db.growing_reward[index - 1] = '1';
        db.set_growing_reward(db.growing_reward);
        save_db();
    }
    str = db.growing_reward();
    return SUCCESS;  
}

void sc_reward_t::refresh_growing_reward_status(string &str)
{
    if (db.growing_package_status != 1)
        return;
    //int index = db.growing_reward.length();
    repo_def::growup_reward_t * rp_growup_reward = NULL;
    for (int i = 1; (rp_growup_reward = repo_mgr.growup_reward.get(i)) != NULL; ++i)
    {
        if (m_user.db.grade >= rp_growup_reward->level)
        {
            if (db.growing_reward.length() == 1 && db.growing_reward[0] == '0')
            {
                if (m_user.db.grade >= rp_growup_reward->level)
                {   
                    db.growing_reward[0] = '1'; 
                    db.set_growing_reward(db.growing_reward);
                    save_db();
                }
            }else
            {
                if (i > (int)db.growing_reward.length())
                {
                    db.growing_reward.append(1,'1');
                    db.set_growing_reward(db.growing_reward);
                    save_db();
                }
            }
        }
        /*if (db.growing_reward.length() == 1 && db.growing_reward[0] == '0')
        {
            if ((rp_growup_reward = repo_mgr.growup_reward.get(1)) != NULL)
            {
                if (m_user.db.grade >= rp_growup_reward->level)
                {   
                    db.growing_reward[0] = '1'; 
                    db.set_growing_reward(db.growing_reward);
                    save_db();
                }
            }
        }else
        {
            index = db.growing_reward.length() + 1; 
            if ((rp_growup_reward = repo_mgr.growup_reward.get(index)) != NULL)
            {
                if (m_user.db.grade >= rp_growup_reward->level)
                {   db.growing_reward.append(1,'1');
                    db.set_growing_reward(db.growing_reward);
                    save_db();
                }
            }
        }*/
    }

    str = db.growing_reward();
}

void sc_reward_t::clear_lmt_draw_data()
{
    //限时活动钻石十连
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(2);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end)
        {
            db.set_limit_draw_ten(0);
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.limit_draw_ten_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                db.set_limit_draw_ten_reward(state);
                save_db();
            }else if(db.limit_draw_ten_reward[0] != '0')
            {
                db.limit_draw_ten_reward[0] = '0';
                db.set_limit_draw_ten_reward(db.limit_draw_ten_reward);
                save_db();
            }
        }
    }
}


string sc_reward_t::update_sevenpayreward()
{
    uint32_t ctime_stamp = server.db.ctime;
    uint32_t activity_end_time_stamp = ctime_stamp + 7*86400;
    uint32_t cur_timestamp = date_helper.cur_sec();
    int32_t sevenpay_count = db_ext.sevenpay_count;

     
    if ( cur_timestamp <= activity_end_time_stamp )
    {   
        //判断上次支付是否已经超过了一天，如果没有的话不会执行更新相关的操作。
        if (db_ext.lastpay_timestamp > 0  && date_helper.offday(db_ext.lastpay_timestamp) < 1){
             
             return db_ext.sevenpay_stage();
             
        }
         repo_def::newly_reward_t * rp_draw_reward = NULL;
         db_ext.sevenpay_count = db_ext.sevenpay_count + 1;
         db_ext.set_sevenpay_count(db_ext.sevenpay_count);
         //获取当前表的数据
         int32_t i = 801;
         if(db_ext.sevenpay_stage.length()==1 && db_ext.sevenpay_stage[0] == '0'){
             i = 801;
         }else
             i = 800 + db_ext.sevenpay_stage.length() + 1;
        
         for(;repo_mgr.newly_reward.get(i) != NULL ;i++)
         {
             rp_draw_reward = repo_mgr.newly_reward.get(i);
             if (db_ext.sevenpay_count >= rp_draw_reward->value)
             {
                 if((i-db_ext.sevenpay_stage.length()) > 800 && db_ext.sevenpay_stage[i-801] != '2')
                 {
                      db_ext.sevenpay_stage.append(i-800-db_ext.sevenpay_stage.length(),'1');
                 }
                 if(db_ext.sevenpay_stage[i-801] != '2')
                    db_ext.sevenpay_stage[i-801] = '1';
                 db_ext.set_sevenpay_stage(db_ext.sevenpay_stage);
                 db_ext.set_lastpay_timestamp(cur_timestamp);
                 sc_msg_def::nt_sevenpay_changed_t nt;
                 nt.stage = db_ext.sevenpay_stage();
                 logic.unicast(m_user.db.uid, nt);
             }else{
                 db_ext.set_lastpay_timestamp(cur_timestamp);
             }
         }

    }
    save_db_ext();
    return db_ext.sevenpay_stage();
}

void sc_reward_t::clear_lmt_wing_data()
{
    //限时活动合成翅膀
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(3);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end)
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备 
            if (db.limit_wing_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                db.set_limit_wing_reward(state);
                save_db();
            }else if(db.limit_wing_reward[0] != '0')
            {
                db.limit_wing_reward[0] = '0';
                db.set_limit_wing_reward(db.limit_wing_reward);
                save_db();
            }
        }
    }
}

void sc_reward_t::clear_lmt_power_data()
{
    //限时活动消耗体力
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(4);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        int32_t lmt_event_begin = str2stamp(rp->start_time);
        int32_t lmt_event_end = str2stamp(rp->end_time);
        if(db.limit_consume_power_stamp < lmt_event_begin || db.limit_consume_power_stamp > lmt_event_end)
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            db.set_limit_consume_power(0);
            db.set_limit_consume_power_stamp(date_helper.cur_sec());
            if (db.limit_consume_power_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                db.set_limit_consume_power_reward(state);
                save_db();
            }else if(db.limit_consume_power_reward[0] != '0')
            {
                db.limit_consume_power_reward[0] = '0';
                db.set_limit_consume_power_reward(db.limit_wing_reward);
                save_db();
            }
        }
    }
}

void sc_reward_t::clear_lmt_luckybag_data()
{
    //限时活动福袋
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(5);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end)
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.luckybag_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                db.set_luckybag_reward(state);
                save_db();
            }else if(db.luckybag_reward[0] != '0')
            {
                db.luckybag_reward[0] = '0';
                db.set_luckybag_reward(db.luckybag_reward);
                save_db();
            }
            //福袋道具清除 
            int32_t count = m_user.item_mgr.get_items_count(16002);
            if (count > 0)
            {
                sc_msg_def::nt_bag_change_t nt;
                m_user.item_mgr.consume(16002, count, nt);
                m_user.item_mgr.on_bag_change(nt);  
            }   
        }
    }
}

void sc_reward_t::clear_lmt_recharge_data()
{
    //累计充值
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(7);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        //if((date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end) && !isInOpenTime())
        if((date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end))
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.limit_recharge_reward.length() > 1)
            {
                ystring_t<10> state;
                state.append(1,'0');
                db.set_limit_recharge_reward(state);
            }else if(db.limit_recharge_reward[0] != '0')
            {
                db.limit_recharge_reward[0] = '0';
                db.set_limit_recharge_reward(db.limit_recharge_reward);
            }
            db.set_limit_recharge_money(0);
            save_db();
        }
    }
}

void sc_reward_t::clear_lmt_melting_data()
{
    //累计熔炼
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(12);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end)
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.limit_melting_reward.length() > 1)
            {
                ystring_t<10> state;
                state.append(1,'0');
                db.set_limit_melting_reward(state);
            }else if(db.limit_melting_reward[0] != '0')
            {
                db.limit_melting_reward[0] = '0';
                db.set_limit_melting_reward(db.limit_melting_reward);
            }
            db.set_limit_melting(0);
            save_db();
        }
    }
}

void sc_reward_t::clear_lmt_talent_data()
{
    //累计天赋
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(14);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() < lmt_event_begin || date_helper.cur_sec() > lmt_event_end)
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.limit_talent_reward.length() > 1)
            {
                ystring_t<10> state;
                state.append(1,'0');
                db.set_limit_talent_reward(state);
            }else if(db.limit_talent_reward[0] != '0')
            {
                db.limit_talent_reward[0] = '0';
                db.set_limit_talent_reward(db.limit_talent_reward);
            }
            db.set_limit_talent(0);
            save_db();
        }
    }
}

void sc_reward_t::get_jpk(sc_msg_def::jpk_reward_data_t& data_)
{
    //memset(&data_, 0, sizeof(data_));
    //不在活动内则将线上召唤和翅膀升阶清0
    clear_lmt_draw_data(); 
    clear_lmt_wing_data();
    clear_lmt_power_data();
    clear_lmt_luckybag_data();
    clear_lmt_recharge_data();
    clear_lmt_melting_data();
    clear_lmt_talent_data(); 

    if (m_is_first_login == 0)
        data_.isshowtoday = 0;
    else
        data_.isshowtoday = 1;

    if (db.given_rank_stamp != 0)
        data_.rank = arena_rank.get_reward_rank(m_user.db.uid);

    data_.first_yb = db.first_yb;
    data_.lg_days = db.login_days;
    data_.loginrewards = db.login_rewards();
    data_.total_login_days = db.total_login_days;
    data_.growing_package_status = db.growing_package_status;
    data_.growing_reward = db.growing_reward();
    data_.is_consume_hundred = db.is_consume_hundred;
    data_.pvelose_times = db.pvelose_times;

    data_.acc_yb[0] = db.acc_yb1;
    data_.acc_yb[1] = db.acc_yb2;
    data_.acc_yb[2] = db.acc_yb3;
    data_.acc_yb[3] = db.acc_yb4;
    data_.acc_yb[4] = db.acc_yb5;
    data_.acc_yb[5] = db.acc_yb6;
    data_.acc_yb[6] = db.acc_yb7;

    data_.con_lg[0] = db.con_lg1;
    data_.con_lg[1] = db.con_lg2;
    data_.con_lg[2] = db.con_lg3;
    data_.con_lg[3] = db.con_lg4;
    data_.con_lg[4] = db.con_lg5;
    data_.con_lg[5] = db.con_lg6;
    data_.con_lg[6] = db.con_lg7;
    data_.con_hero = db.conhero;
    data_.con_equip = db.conequip;

    data_.lv_reward[0] = db.lv_20;
    data_.lv_reward[1] = db.lv_25;
    data_.lv_reward[2] = db.lv_30;
    data_.lv_reward[3] = db.lv_35;
    data_.lv_reward[4] = db.lv_40;
    data_.lv_reward[5] = db.lv_45;
    data_.lv_reward[6] = db.lv_50;
    data_.lv_reward[7] = db.lv_55;
    data_.lv_reward[8] = db.lv_60;
    data_.lv_reward[9] = db.lv_65;
    data_.lv_reward[10] = db.lv_70;

    for(int i=0; i<ACC_LG_LEVEL; i++)
    {
        data_.acc_lg[i] = *m_acclgs[i];
    }

    data_.acclgexp = db.acclgexp;
    data_.month = get_month_delta()+1;

    data_.first_lg = date_helper.offday( db.last_login );

    data_.sec_2_tom = date_helper.sec_2_tomorrow(0);

    for(int i=0; i<18; i++)
    {
        data_.vip_reward[i] = *m_vips[i];
    }

    data_.cumulevel = db.cumulevel;
    data_.cumureward = db.cumureward;
    data_.fpreward = db.fpreward;
    data_.server_ctime = server.db.ctime;
    data_.cur_sec = date_helper.cur_sec();
    
    data_.cumu_yb_exp = db.cumu_yb_exp;
    data_.cumu_yb_reward = db.cumu_yb_reward;

    data_.daily_pay = db.daily_pay;
    data_.daily_pay_reward = db.daily_pay_reward;
    data_.mcard_event_buy_count = db.mcard_event_buy_count;
    data_.mcard_event_state = db.mcard_event_state;

    //限时双倍活动时间设置返回
    for(int i = 1;i<8;i++){
        repo_def::lmt_double_t* rp = repo_mgr.lmt_double.get(i);
        switch (i){
           case 1 :
               data_.limit_activity.limit_double_activity.lmt_double_rate_stage_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_rate_stage_end = str2stamp(rp->end_time);
               break;
           case 2 :
               data_.limit_activity.limit_double_activity.lmt_double_stage_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_stage_end = str2stamp(rp->end_time);
               break;
           case 3 :
               data_.limit_activity.limit_double_activity.lmt_double_soul_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_soul_end = str2stamp(rp->end_time);
               break;
           case 4 :
               data_.limit_activity.limit_double_activity.lmt_double_expedition_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_expedition_end = str2stamp(rp->end_time);
               //远征需要一个标识位。 因为他的活动效益是延时的。
               data_.limit_activity.limit_double_activity.lmt_double_expedition_state = db.double_expedition;
               break;
           case 5 :
               data_.limit_activity.limit_double_activity.lmt_double_rate_high_stage_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_rate_high_stage_end = str2stamp(rp->end_time);
               break;
           case 6 :
               data_.limit_activity.limit_double_activity.lmt_double_high_stage_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_high_stage_end = str2stamp(rp->end_time);
               break;
           case 7 :
               data_.limit_activity.limit_double_activity.lmt_double_dailytask_begin = str2stamp(rp->start_time);
               data_.limit_activity.limit_double_activity.lmt_double_dailytask_end = str2stamp(rp->end_time);
               break;
           dafault:
              break;
        }
    }

    /* 从表中获取活动 */
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(1);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        data_.recharge_back.lmt_event_begin_year = rp->start_time.substr(0,4);
        data_.recharge_back.lmt_event_begin_month = rp->start_time.substr(5,2);
        data_.recharge_back.lmt_event_begin_day = rp->start_time.substr(8,2);
        data_.recharge_back.lmt_event_end_year = rp->end_time.substr(0,4);
        data_.recharge_back.lmt_event_end_month = rp->end_time.substr(5,2);
        data_.recharge_back.lmt_event_end_day = rp->end_time.substr(8,2);
        data_.recharge_back.lmt_event_begin = str2stamp(rp->start_time);
        data_.recharge_back.lmt_event_end = str2stamp(rp->end_time);
        vector<sc_msg_def::jpk_recharge_info_t> recharge_infos;
        auto item_info = repo_mgr.daily_pay.begin();
        while(item_info != repo_mgr.daily_pay.end())
        {
            sc_msg_def::jpk_recharge_info_t recharge_info;
            recharge_info.id = item_info->second.id;
            recharge_info.rmb = item_info->second.rmb;
            for(size_t i = 1;i<item_info->second.item.size(); i++)
            {
                vector<int32_t> lmt_item;
                lmt_item.push_back(std::move(item_info->second.item[i][0])); 
                lmt_item.push_back(std::move(item_info->second.item[i][1])); 
                recharge_info.item.push_back(std::move(lmt_item));
            }
            recharge_infos.push_back(std::move(recharge_info));
            item_info++;
        }
        data_.recharge_back.recharge_info = recharge_infos;
    }
    data_.recharge_back.can_get_first = db.can_get_first;
    int32_t repo_first_rmb = repo_mgr.configure.find(48)->second.value;
    data_.recharge_back.first_rmb = repo_first_rmb;
    repo_def::lmt_event_t* rp_mcard = repo_mgr.lmt_event.get(6);
    if (NULL == rp_mcard) {
       logwarn((LOG, "load_repo, lmt_event mcard not exists"));
    }
    else
    {
        data_.mcard_event_time.lmt_event_begin = str2stamp(rp_mcard->start_time);
        data_.mcard_event_time.lmt_event_end = str2stamp(rp_mcard->end_time);

    }
    data_.wingactivity = db.wingactivity;
    data_.wingactivityreward = db.wingactivityreward;
    data_.servercreatestamp = m_user.db.createtime;
    data_.limit_activity.limit_double_activity.sevenpay_stage = db_ext.sevenpay_stage();
    //限时双倍活动

    get_activity_date(data_.limit_activity.limit_draw_activity, 2);
    get_activity_date(data_.limit_activity.limit_wing_activity, 3); 
    data_.limit_activity.limit_draw_ten = db.limit_draw_ten;
    data_.limit_activity.limit_draw_ten_reward = db.limit_draw_ten_reward();
    data_.limit_activity.limit_wing_reward = db.limit_wing_reward();
    //限时体力
    get_activity_date(data_.limit_activity.limit_power_activity, 4);
    data_.limit_activity.limit_consume_power_reward = db.limit_consume_power_reward();
    data_.limit_activity.limit_consume_power = db.limit_consume_power;
    //福袋
    get_lucky_bag_date(data_.limit_activity.limit_lucky_bag_activity);
    data_.limit_activity.luckybag_reward = db.luckybag_reward();
    data_.limit_activity_ext.luckybagvalue = db_ext.luckbagvalue;
    get_lmt_date(data_.limit_activity.limit_growing_activity, 10);
    //累计充值
    data_.limit_activity.limit_recharge_money = db.limit_recharge_money;
    data_.limit_activity.limit_recharge_reward = db.limit_recharge_reward();
    get_activity_date(data_.limit_activity.limit_recharge_activity, 7);
    //每日抽卡
    data_.limit_activity.daily_draw_num = db.daily_draw;
    data_.limit_activity.daily_draw_reward = db.daily_draw_reward();
    get_activity_date(data_.limit_activity.daily_draw_activity, 8);
    //每日体力
    data_.limit_activity.daily_consume_ap = db.daily_consume_ap;
    data_.limit_activity.daily_consume_ap_reward = db.daily_consume_ap_reward();
    get_activity_date(data_.limit_activity.daily_consume_activity, 9);
    //每日熔炼
    data_.limit_activity.daily_melting_num = db.daily_melting;
    data_.limit_activity.daily_melting_reward = db.daily_melting_reward();
    get_activity_date(data_.limit_activity.daily_melting_activity, 11);
    //累计熔炼
    data_.limit_activity.limit_melting_num = db.limit_melting;
    data_.limit_activity.limit_melting_reward = db.limit_melting_reward();
    get_activity_date(data_.limit_activity.limit_melting_activity, 12);
    //每日天赋
    data_.limit_activity.daily_talent_num = db.daily_talent;
    data_.limit_activity.daily_talent_reward = db.daily_talent_reward();
    get_activity_date(data_.limit_activity.daily_talent_activity, 13);
    //累计天赋
    data_.limit_activity.limit_talent_num = db.limit_talent;
    data_.limit_activity.limit_talent_reward = db.limit_talent_reward();
    get_activity_date(data_.limit_activity.limit_talent_activity, 14);
    
    //限时7日充值
    data_.limit_activity_ext.limit_seven_stage = db_ext.limit_seven_stage();
    get_activity_date(data_.limit_activity_ext.limit_seven_activity, 15);

    //单笔充值
    data_.limit_activity_ext.limit_single_recharge = db.limit_single_recharge;
    data_.limit_activity_ext.limit_single_reward = db.limit_single_reward();
    get_activity_date(data_.limit_activity_ext.limit_single_activity, 17);

    //抽卡活动
    data_.limit_activity_ext.limit_pub = db_ext.limit_pub;

    //钻石消费
    data_.limit_activity_ext.openybtotal = db_ext.openybtotal;
    data_.limit_activity_ext.openybreward = db_ext.openybreward();
    get_activity_date(data_.limit_activity_ext.openybactivity, 19);
     
    
    //在线礼包
    data_.limit_activity.online_cd = get_online_reward_cd();
    data_.limit_activity.online = db.online + 1;
    get_online_info(data_.limit_activity.online_info); 
    //周礼包
    data_.limit_activity.week_reward = db.week_reward;
    get_weekly_info(data_.limit_activity.weekly_info); 
}

void sc_reward_t::get_online_info(vector<sc_msg_def::jpk_online_reward_t> &reward_info_)
{
    vector<sc_msg_def::jpk_online_reward_t> recharge_infos;
    auto item_info = repo_mgr.online.begin();
    while(item_info != repo_mgr.online.end())
    {
        sc_msg_def::jpk_online_reward_t recharge_info;
        recharge_info.id = item_info->second.id;
        recharge_info.time = item_info->second.time;
        for(size_t i = 1;i<item_info->second.reward.size(); i++)
        {
            vector<int32_t> lmt_item;
            lmt_item.push_back(std::move(item_info->second.reward[i][0])); 
            lmt_item.push_back(std::move(item_info->second.reward[i][1])); 
            recharge_info.reward.push_back(std::move(lmt_item));
        }
        recharge_infos.push_back(std::move(recharge_info));

        item_info++;
    }
    reward_info_ = recharge_infos;
}

void sc_reward_t::get_weekly_info(vector<sc_msg_def::jpk_weekly_reward_t> &reward_info_)
{
    if (date_helper.cur_dayofweek() == 6 || date_helper.cur_dayofweek() == 0 || true )
    //if (date_helper.cur_dayofweek() == 6 || date_helper.cur_dayofweek() == 0 )
    {
        //将周礼包奖励返回
        vector<sc_msg_def::jpk_weekly_reward_t> recharge_infos;
        auto item_info = repo_mgr.weekly.begin();
        while(item_info != repo_mgr.weekly.end())
        {
            sc_msg_def::jpk_weekly_reward_t recharge_info;
            recharge_info.id = item_info->second.id;
            recharge_info.description = item_info->second.description;
            recharge_info.name = item_info->second.name;
            recharge_info.vip.push_back(std::move(item_info->second.VIP[1])); 
            recharge_info.vip.push_back(std::move(item_info->second.VIP[2])); 
            for(size_t i = 1;i<item_info->second.reward.size(); i++)
            {
                vector<int32_t> lmt_item;
                lmt_item.push_back(std::move(item_info->second.reward[i][0])); 
                lmt_item.push_back(std::move(item_info->second.reward[i][1])); 
                recharge_info.reward.push_back(std::move(lmt_item));
            }
            recharge_infos.push_back(std::move(recharge_info));
            
            item_info++;
        }
        reward_info_ = recharge_infos;
    }
}

int32_t sc_reward_t::get_pvelose_times(int32_t &times_)
{
    times_ = db.pvelose_times + 1;
    db.set_pvelose_times(db.pvelose_times + 1);
    save_db(); 
    return SUCCESS; 
}

int32_t sc_reward_t::get_online_reward_pack(int32_t id, int32_t &online_, int32_t &cd_)
{
    repo_def::online_t* rp = repo_mgr.online.get(id);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
       return FAILED;
    }
    else
    {
        if( id == (db.online + 1))
        {
            //冷却时间未到
            if(db.next_online > date_helper.cur_sec())
                return ERROR_SC_ILLEGLE_REQ;
            
            if(db.online >= id)
                return ERROR_SC_ILLEGLE_REQ;

            auto f = [&](int item_, int num_)
            {
                if (num_ <= 0)
                    return ERROR_SC_ILLEGLE_REQ;
                sc_msg_def::nt_bag_change_t nt;
                if (item_ / 10000 == 3)
                    m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                else if (item_ == 10001)
                {
                    m_user.on_money_change(num_);
                    m_user.save_db();
                }
                else
                {
                    m_user.item_mgr.addnew(item_, num_, nt);
                    bool is_empty = true;
                    if (!nt.items.empty())
                    {
                        is_empty = false;
                    }
                    else if(!nt.add_wings.empty())
                    {
                        is_empty = false;
                    }
                    else if(!nt.add_pet.empty())
                    {
                        is_empty = false;
                    }
                    if (is_empty)
                    {                                 
                        logerror((LOG, "con reward items error!"));
                        return ERROR_SC_ILLEGLE_REQ;;
                    }
                }
                m_user.item_mgr.on_bag_change(nt);

                return SUCCESS;
            };
            
            uint32_t size = rp->reward.size();
            for (size_t i = 1; i < size; ++i)
            {
                f(rp->reward[i][0], rp->reward[i][1]);
            }
           
            db.set_online(db.online + 1); 
            repo_def::online_t* rp_next = repo_mgr.online.get(id + 1);
            if(rp_next != NULL)
                db.set_next_online(date_helper.cur_sec() + rp_next->time);
            save_db();
            
            online_ = db.online + 1;
            cd_ = get_online_reward_cd();
        } 
        else
            return ERROR_SC_ILLEGLE_REQ;
    }
    return SUCCESS;
}

int32_t sc_reward_t::get_weekly_reward(int32_t id, int32_t &reward_state)
{
    repo_def::weekly_t* rp = repo_mgr.weekly.get(id);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
       return FAILED;
    }
    else
    {
        if(m_user.db.viplevel >= rp->VIP[1] && m_user.db.viplevel <= rp->VIP[2])
        {
            auto f = [&](int item_, int num_)
            {
                if (num_ <= 0)
                    return ERROR_SC_ILLEGLE_REQ;
                sc_msg_def::nt_bag_change_t nt;
                if (item_ / 10000 == 3)
                    m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                else if (item_ == 10001)
                {
                    m_user.on_money_change(num_);
                    m_user.save_db();
                }
                else
                {
                    m_user.item_mgr.addnew(item_, num_, nt);
                    bool is_empty = true;
                    if (!nt.items.empty())
                    {
                        is_empty = false;
                    }
                    else if(!nt.add_wings.empty())
                    {
                        is_empty = false;
                    }
                    else if (!nt.add_pet.empty())
                    {
                        is_empty = false;
                    }
                    if (is_empty)
                    {                                 
                        logerror((LOG, "con reward items error!"));
                        return ERROR_SC_ILLEGLE_REQ;;
                    }
                }
                m_user.item_mgr.on_bag_change(nt);
                return SUCCESS;
            };
            
            if(date_helper.cur_dayofweek() != 6 && date_helper.cur_dayofweek() != 0)
                return ERROR_QUEST_OVERDUED;

            if(db.week_reward != 1)
                return ERROR_SC_ILLEGLE_REQ;

            uint32_t size = rp->reward.size();
            for (size_t i = 1; i < size; ++i)
            {
                f(rp->reward[i][0], rp->reward[i][1]);
            }
            
            db.set_week_reward(2);
            save_db();
            reward_state = db.week_reward;
        } 
        else
            return ERROR_SC_ILLEGLE_REQ;
    }
    return SUCCESS;
}

void sc_reward_t::change_expedition_state(int32_t newState)
{
    db.set_double_expedition(newState);
}

int sc_reward_t::get_expedition_state()
{
    return (int)db.double_expedition;
}

bool sc_reward_t::isInDoubleActivity(int doubleActivityCode)
{
    //不同的code代表不同的活动。以此来判断是否在相应的活动时间内
    //1.双倍副本掉率
    //2.双倍副本物品
    //3.魂晶熔炼收益双倍活动
    //4.远征重置后得双倍活动
    //5.双倍精英副本掉率
    //6.双倍精英副本物品掉落
    //7.双倍每日任务经验
    bool isRet = false;
    uint32_t cur_stamp = date_helper.cur_sec();
    repo_def::lmt_double_t* rp = repo_mgr.lmt_double.get(doubleActivityCode);
    if((str2stamp(rp->start_time) < cur_stamp) && (str2stamp(rp->end_time) > cur_stamp))
        isRet = true;    
    return isRet;
}
    

void sc_reward_t::update_recharge_activity(int rmb_)
{
    sc_msg_def::jpk_lmt_event_t lmt_recharge;
    get_lmt_date(lmt_recharge, 7);

    //if (date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end && !isInOpenTime())
    if (date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end)
    {
        int total_money = db.limit_recharge_money + rmb_;
        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 701;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_money < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 700) > (int)db.limit_recharge_reward.length())
            {
                db.limit_recharge_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_recharge_reward[index - 701] == '0')
                {
                    db.limit_recharge_reward[index - 701] = '1';     
                }
            }
            db.set_limit_recharge_reward(db.limit_recharge_reward);
            save_db();
        }

        db.set_limit_recharge_money(db.limit_recharge_money + rmb_); 
        save_db();
    
        sc_msg_def::nt_recharge_activity_t nt;
        nt.totalmoney = total_money;
        nt.recharge_reward = db.limit_recharge_reward();
        logic.unicast(m_user.db.uid, nt); 
    }
    /* 
    else if(date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end && isInOpenTime())
    {

        int total_money = db.limit_recharge_money + rmb_;
        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 1601;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_money < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 1600) > (int)db.limit_recharge_reward.length())
            {
                db.limit_recharge_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_recharge_reward[index - 1601] == '0')
                {
                    db.limit_recharge_reward[index - 1601] = '1';     
                }
            }
            db.set_limit_recharge_reward(db.limit_recharge_reward);
            save_db();
        }

        db.set_limit_recharge_money(db.limit_recharge_money + rmb_); 
        save_db();
    
        sc_msg_def::nt_recharge_activity_t nt;
        nt.totalmoney = total_money;
        nt.recharge_reward = db.limit_recharge_reward();
        logic.unicast(m_user.db.uid, nt); 
    }
    */
}

//更新单笔充值
void sc_reward_t::update_single_activity(int rmb_)
{
    sc_msg_def::jpk_lmt_event_t lmt_recharge;
    get_lmt_date(lmt_recharge, 17);

    if(db.limit_single_stamp < date_helper.cur_0_stmp())
    {
        if (db.limit_single_reward.length() > 1)
        {
                ystring_t<10> state;
                state.append(1,'0');
                db.set_limit_single_reward(state);
        }else if(db.limit_single_reward[0] != '0')
        {
            db.limit_single_reward[0] = '0';
            db.set_limit_single_reward(db.limit_single_reward);
        }
    }
    //jp
    //if (date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end && !isInOpenTime())
    if (date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end)
    {
        int32_t total_money = db.limit_single_recharge + rmb_;
        if(db.limit_single_stamp < date_helper.cur_0_stmp())
            total_money = rmb_;

        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 1701;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_money < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 1700) > (int)db.limit_single_reward.length())
            {
                db.limit_single_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_single_reward[index - 1701] == '0')
                {
                    db.limit_single_reward[index - 1701] = '1';     
                }
            }
            db.set_limit_single_reward(db.limit_single_reward);
            save_db();
        }

        if(db.limit_single_stamp < date_helper.cur_0_stmp())
        {
            db.limit_single_recharge = rmb_;
            db.set_limit_single_recharge(rmb_); 
        }
        else
        {
            db.limit_single_recharge = db.limit_single_recharge + rmb_;
            db.set_limit_single_recharge(db.limit_single_recharge);
        }

        db.limit_single_stamp = date_helper.cur_sec();
        db.set_limit_single_stamp(date_helper.cur_sec());
        save_db();
    
        sc_msg_def::nt_single_activity_t nt;
        nt.totalmoney = total_money;
        nt.recharge_reward = db.limit_single_recharge;
        logic.unicast(m_user.db.uid, nt); 
    }
    /*
    else if(date_helper.cur_sec() >= lmt_recharge.lmt_event_begin && date_helper.cur_sec() <= lmt_recharge.lmt_event_end && isInOpenTime())
    {

        int32_t total_money = db.limit_single_recharge + rmb_;
        if(db.limit_single_stamp < date_helper.cur_0_stmp())
            total_money = rmb_;

        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 1801;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_money < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 1800) > (int)db.limit_single_reward.length())
            {
                db.limit_single_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_single_reward[index - 1801] == '0')
                {
                    db.limit_single_reward[index - 1801] = '1';     
                }
            }
            db.set_limit_single_reward(db.limit_single_reward);
            save_db();
        }
        
        if(db.limit_single_stamp < date_helper.cur_0_stmp())
        {
            db.limit_single_recharge = rmb_;
            db.set_limit_single_recharge(rmb_); 
        }
        else
        {
            db.limit_single_recharge = db.limit_single_recharge + rmb_;
            db.set_limit_single_recharge(db.limit_single_recharge);
        }

        db.limit_single_stamp = date_helper.cur_sec();
        db.set_limit_single_stamp(date_helper.cur_sec());
        save_db();
    
        sc_msg_def::nt_single_activity_t nt;
        nt.totalmoney = total_money;
        nt.recharge_reward = db.limit_single_reward();
        logic.unicast(m_user.db.uid, nt); 
    }
    */
}

//更新抽卡排行
void sc_reward_t::update_limit_pub_activity(int count_)
{
    if(date_helper.cur_sec() <= server.db.ctime + 3 * 86400)
    {
        db_ext.limit_pub = db_ext.limit_pub + count_;
        db_ext.set_limit_pub(db_ext.limit_pub);
        char sql[256];
        sql_result_t res;
        sprintf(sql, "update RewardExtentionI set limit_pub = (%d) where uid = (%d);",db_ext.limit_pub ,m_user.db.uid);
        db_service.sync_select(sql, res);
        
        //通知客户端抽卡排行改变
        sc_msg_def::nt_limit_pub_t nt;
        nt.now = db_ext.limit_pub;
        logic.unicast(m_user.db.uid, nt); 

        //更新排行榜数据
        pub_rank.update_pub(db_ext.limit_pub);
    }

}


//累计熔炼
void sc_reward_t::update_melting_activity(int num_)
{
    sc_msg_def::jpk_lmt_event_t lmt_melting;
    get_lmt_date(lmt_melting, 12);
    if (date_helper.cur_sec() >= lmt_melting.lmt_event_begin && date_helper.cur_sec() <= lmt_melting.lmt_event_end)
    {
        int total_melting = db.limit_melting + num_;
        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 1201;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_melting < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 1200) > (int)db.limit_melting_reward.length())
            {
                db.limit_melting_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_melting_reward[index - 1201] == '0')
                {
                    db.limit_melting_reward[index - 1201] = '1';     
                }
            }
            db.set_limit_melting_reward(db.limit_melting_reward);
            save_db();
        }

        db.set_limit_melting(db.limit_melting + num_); 
        save_db();
    
        sc_msg_def::nt_melting_t nt;
        nt.totalmelting = total_melting;
        nt.melting_reward = db.limit_melting_reward();
        nt.type = 2;
        logic.unicast(m_user.db.uid, nt); 
    }
}
//累计天赋
void sc_reward_t::update_talent_activity(int num_)
{
    sc_msg_def::jpk_lmt_event_t lmt_talent;
    get_lmt_date(lmt_talent, 14);
    if (date_helper.cur_sec() >= lmt_talent.lmt_event_begin && date_helper.cur_sec() <= lmt_talent.lmt_event_end)
    {
        int total_talent = db.limit_talent + num_;
        repo_def::lmt_reward_t * rp_lmt_reward = NULL;
        int index = 1401;
        for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_talent < rp_lmt_reward->value)
                break;
            //置位
            if ((index - 1400) > (int)db.limit_talent_reward.length())
            {
                db.limit_talent_reward.append(1, '1'); 
            }
            else
            {
                if (db.limit_talent_reward[index - 1401] == '0')
                {
                    db.limit_talent_reward[index - 1401] = '1';     
                }
            }
            db.set_limit_talent_reward(db.limit_talent_reward);
            save_db();
        }

        db.set_limit_talent(db.limit_talent + num_); 
        save_db();
    
        sc_msg_def::nt_talent_t nt;
        nt.totaltalent = total_talent;
        nt.talent_reward = db.limit_talent_reward();
        nt.type = 2;
        logic.unicast(m_user.db.uid, nt); 
    }
}
bool sc_reward_t::isInOpenTime()
{
    auto open_time = m_user.db.createtime;
    auto cur_time = date_helper.cur_sec();
    bool ret = false;

    if((cur_time - open_time) < (86400 * 7))
        ret = true;
    else 
        ret = false;

    return ret;    
}
void sc_reward_t::get_lmt_date(sc_msg_def::jpk_lmt_event_t &jpk_, int32_t index_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(index_);
    auto server_start_time = m_user.db.createtime;
    auto server_end_time = m_user.db.createtime + 86400 * 7;
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    /*
    else if((index_ == 7 || index_ == 17) && isInOpenTime())
    {
        char now[64];
        time_t t_start;
        struct tm *ttime; 
        t_start = server_start_time;
        ttime = localtime(&t_start);
        strftime(now,64,"%Y-%m-%d %H:%M:%S",ttime); 
        string st(now);
        
        
        jpk_.lmt_event_begin_year = st.substr(0,4);
        jpk_.lmt_event_begin_month = st.substr(5,2);
        jpk_.lmt_event_begin_day = st.substr(8,2);
        jpk_.lmt_event_begin = server_start_time;
        
        
        
        char end[64];
        time_t t_end;
        struct tm *tetime;
        t_end = server_end_time;
        tetime = localtime(&t_end);
        strftime(end,64,"%Y-%m-%d %H:%M:%S",tetime); 
        string se(end);

        jpk_.lmt_event_end_year = se.substr(0,4);
        jpk_.lmt_event_end_month = se.substr(5,2);
        jpk_.lmt_event_end_day = se.substr(8,2);
        jpk_.lmt_event_end = server_end_time;
    }
    */
    else
    {
        jpk_.lmt_event_begin_year = rp->start_time.substr(0,4);
        jpk_.lmt_event_begin_month = rp->start_time.substr(5,2);
        jpk_.lmt_event_begin_day = rp->start_time.substr(8,2);
        jpk_.lmt_event_end_year = rp->end_time.substr(0,4);
        jpk_.lmt_event_end_month = rp->end_time.substr(5,2);
        jpk_.lmt_event_end_day = rp->end_time.substr(8,2);
        jpk_.lmt_event_begin = str2stamp(rp->start_time);
        jpk_.lmt_event_end = str2stamp(rp->end_time);
    }
}

void sc_reward_t::get_activity_date(sc_msg_def::jpk_lmt_event_t &jpk_, int index_)
{
    get_lmt_date(jpk_, index_);
    
    /*
    if(index_ == 7 && isInOpenTime())
        index_ = 16;

    if(index_ == 17 && isInOpenTime())
        index_ = 18;
    */
    //从服务器获取奖励数据，客户端奖励表不用
    vector<sc_msg_def::jpk_recharge_info_t> recharge_infos;
    auto item_info = repo_mgr.lmt_reward.begin();
    while(item_info != repo_mgr.lmt_reward.end())
    {
        if (item_info->second.id /100 == index_)
        {
            sc_msg_def::jpk_recharge_info_t recharge_info;
            recharge_info.id = item_info->second.id;
            recharge_info.rmb = 0;
            recharge_info.description = item_info->second.description;
            recharge_info.name = item_info->second.name;
            recharge_info.value = item_info->second.value;
            for(size_t i = 1;i<item_info->second.reward.size(); i++)
            {
                vector<int32_t> lmt_item;
                lmt_item.push_back(std::move(item_info->second.reward[i][0])); 
                lmt_item.push_back(std::move(item_info->second.reward[i][1])); 
                recharge_info.item.push_back(std::move(lmt_item));
            }
            recharge_infos.push_back(std::move(recharge_info));
        }
        item_info++;
    }
    jpk_.recharge_info = recharge_infos;
}

void sc_reward_t::get_lucky_bag_date(sc_msg_def::jpk_lmt_event_t &jpk_)
{
    //福袋
    get_lmt_date(jpk_, 5);
    
    vector<sc_msg_def::jpk_recharge_info_t> recharge_infos;
    auto item_info = repo_mgr.lmt_gift.begin();
    while(item_info != repo_mgr.lmt_gift.end())
    {
        sc_msg_def::jpk_recharge_info_t recharge_info;
        recharge_info.id = item_info->second.id;
        recharge_info.rmb = 0;
        recharge_info.description = item_info->second.description;
        recharge_info.name = item_info->second.name;
        recharge_info.value = item_info->second.value;
        recharge_info.value2 = item_info->second.value2;
        recharge_info.times = item_info->second.times;
        for(size_t i = 1;i<item_info->second.reward.size(); i++)
        {
            vector<int32_t> lmt_item;
            lmt_item.push_back(std::move(item_info->second.reward[i][0])); 
            lmt_item.push_back(std::move(item_info->second.reward[i][1])); 
            recharge_info.item.push_back(std::move(lmt_item));
        }
        recharge_infos.push_back(std::move(recharge_info));
        
        item_info++;
    }
    jpk_.recharge_info = recharge_infos;
}

void sc_reward_t::get_luckybag_reward(int32_t pos_)
{
    //判断是否在活动时间内
    sc_msg_def::jpk_lmt_event_t jpk;
    sc_msg_def::ret_luckybag_reward_t ret;
    repo_def::lmt_gift_t * rp_lmt_reward = NULL;
    //获得奖励的类型
    int flag = pos_/100;
    int index = pos_ - flag*100; 
    get_lucky_bag_date(jpk);

    if(date_helper.cur_sec() < jpk.lmt_event_begin || date_helper.cur_sec() > jpk.lmt_event_end)
    {
        ret.code = ERROR_QUEST_OVERDUED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    if((rp_lmt_reward = repo_mgr.lmt_gift.get(pos_))!=NULL)
    {
        auto f = [&](int item_, int num_)
        {
            if (num_ <= 0)
                return ERROR_SC_ILLEGLE_REQ;
            sc_msg_def::nt_bag_change_t nt;
            if (item_ / 10000 == 3)
                m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
            else if (item_ == 10001)
            {
                m_user.on_money_change(num_);
                m_user.save_db();
            }
            else
            {
                m_user.item_mgr.addnew(item_, num_, nt);
                bool is_empty = true;
                if (!nt.items.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_wings.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_pet.empty())
                {
                    is_empty = false;
                }
                if (is_empty)
                {                                 
                    logerror((LOG, "con reward items error!"));
                    return ERROR_SC_ILLEGLE_REQ;;
                }
            }
            m_user.item_mgr.on_bag_change(nt);
            return SUCCESS;
        };
        
        //判断是否符合领取条件
        if (m_user.item_mgr.get_items_count(16002) >= rp_lmt_reward->value2 && m_user.rmb() >= rp_lmt_reward->value)
        {
            int off = pos_ - 500 - db.luckybag_reward.length();
            if (off > 0)
            {
                db.luckybag_reward.append(off, '0');
                db.set_luckybag_reward(db.luckybag_reward);
                save_db();
            }
            //判断兑换次数是否已经用完
            char time_temp = db.luckybag_reward[pos_ - 501];
            int times;
            times = char_to_integer(time_temp);
            if (-1 == times)
            {
                ret.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, ret);
                return;
            }
            if (times >= rp_lmt_reward->times)
            {
                ret.code = ERROR_SC_LUCKYBAG_NO_TIMES;
                logic.unicast(m_user.db.uid, ret);
                return;
            }
            //增加领奖次数
            char after_time = integer_to_char(times + 1);
            if ('@' == after_time)
            {
                ret.code = ERROR_SC_LUCKYBAG_ADD_TIME;
                logerror((LOG, "get luckybag_reward add times error, lmt_gift id :%d", pos_));
                logic.unicast(m_user.db.uid, ret);
                return;
            }
            logwarn((LOG,"on exchange luckybag reward, consume rmb:%d, uid:%d", rp_lmt_reward->value, m_user.db.uid));
            m_user.consume_yb(rp_lmt_reward->value);
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(16002, rp_lmt_reward->value2, nt);
            m_user.item_mgr.on_bag_change(nt);
            db.luckybag_reward[pos_ - 501] = after_time;
            db.set_luckybag_reward(db.luckybag_reward);
            save_db();
        }
        else
        {
            ret.code = ERROR_SC_LUCKYBAG_NO_ITEM;
            logic.unicast(m_user.db.uid, ret);
        }
         
        uint32_t size = rp_lmt_reward->reward.size();
        for (size_t i = 1; i < size; ++i)
        {
            f(rp_lmt_reward->reward[i][0], rp_lmt_reward->reward[i][1]);
        }
        ret.code = SUCCESS;
        ret.id = pos_;
        ret.luckybag_reward = db.luckybag_reward();
        logic.unicast(m_user.db.uid, ret);
    }

    save_db();
}

int sc_reward_t::get_month_delta()
{
    int32_t om = date_helper.offmonth(server.db.ctime);
    if( om > 3 )
        om = 3;
    return om;
}

void sc_reward_t::get_cumulogin_reward(int32_t lv_)
{
    sc_msg_def::ret_cumulogin_reward_t ret;

    if( (db.cumureward & (1<<lv_)) == 0 )
    {
        logerror((LOG, "get_cumu, not prepared: %d,%d",db.cumureward,lv_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    repo_def::sign_reward_t *rp_sign_reward= NULL;
    rp_sign_reward = repo_mgr.sign_reward.get(lv_) ;
    if( rp_sign_reward == NULL )
    {
        logerror((LOG, "get_cumu, no repo: %d",lv_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    //加金币
    m_user.on_money_change(rp_sign_reward->count1);
    //加道具
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t itm;
    itm.itid=0;
    itm.resid=rp_sign_reward->item2;
    itm.num=rp_sign_reward->count2;
    nt.items.push_back(std::move(itm));
    //加水晶或者加星魂
    if( rp_sign_reward->item3 == 10003 )
        m_user.on_freeyb_change( rp_sign_reward->count3 );
    else if( rp_sign_reward->item3 ==  10006 )
        m_user.on_runechip_change( rp_sign_reward->count3 );
    else
    {
        sc_msg_def::jpk_item_t itm;
        itm.itid=0;
        itm.resid = rp_sign_reward->item3;
        itm.num = rp_sign_reward->count3;
        nt.items.push_back(std::move(itm));
    }
    m_user.item_mgr.put(nt);
    m_user.item_mgr.on_bag_change(nt);
    m_user.save_db();

    //置位
    db.set_cumureward( (~(1<<lv_)) & db.cumureward );
    save_db();
    
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_reward_t::set_lg_rewards(int32_t days)
{
    if (days > (int)db.login_rewards.length())
    {
        db.login_rewards.append(days - db.login_rewards.length(),'1');
    } 
    db.login_rewards[days - 1] = '1';  
    db.set_login_rewards(db.login_rewards);
    save_db();
}

// flag_
// 1 玩家登录时候触发
// 2 零点时触发
void sc_reward_t::cast_login(int32_t flag_)
{
    //是否是今天第一次登录
    //cout<<"cur_dayofweek = "<<date_helper.cur_dayofweek()<<endl;
    if( db.next_online == 0 )
    {
        db.set_online(0);
        repo_def::online_t* rp_online = repo_mgr.online.get(1);
        if(rp_online != NULL)
            db.set_next_online(date_helper.cur_sec() + rp_online->time);
        save_db();
    }
    int od = date_helper.offday( db.last_login ) ;
    if( 0==od )
    {
        m_is_first_login = 0;
        return;
    }else
        m_is_first_login = 1;

    //判断当前是第几个月
    int32_t om = get_month_delta();
    if( -1 == om )
        return;
    int weekday = date_helper.cur_dayofweek();
    //if( weekday == 6 || weekday == 0 || true )
    if( weekday == 6 || weekday == 0 )
        db.set_week_reward(1);
    else
        db.set_week_reward(0);
    
    //清除在线礼包领取奖励
    db.set_online(0);
    repo_def::online_t* rp_online = repo_mgr.online.get(1);
    if(rp_online != NULL)
        db.set_next_online(date_helper.cur_sec() + rp_online->time);

    int32_t is_put = 0;

    //处理连续30天登录的活动
    if( db.cumulevel < 30 )
    {
        db.set_cumulevel(db.cumulevel+1);
        db.set_cumureward( ( 1<<db.cumulevel ) | db.cumureward );
        save_db();
    }
    //该玩家首次登录游戏
    if( 0==db.last_login )
    {
        db.set_first_login(date_helper.cur_sec());
        db.set_last_login(date_helper.cur_sec());
       
        //连续登录
        db.set_conlglevel(1);
        db.set_con_lg1(1);
        
        //设置登录天数
        db.set_login_days(1);
        //设置第一天的奖励状态
        if (db.login_days > (int)db.login_rewards.length())
        {
            db.login_rewards.append(db.login_days - db.login_rewards.length(),'1');
        } 
        db.login_rewards[0] = '1';
        db.set_login_rewards(db.login_rewards);

        db.set_total_login_days(1);

        save_db();
        return;
    }
    //非首次登录,处理连续登录
    if( (7==db.conlglevel)||(od!=1) )
    {
    }
    else
    {
        db.set_conlglevel(db.conlglevel + 1);
        switch( db.conlglevel )
        {
            case 1: db.set_con_lg1(1); break;
            case 2: db.set_con_lg2(1); break;
            case 3: db.set_con_lg3(1); break;
            case 4: db.set_con_lg4(1); break;
            case 5: db.set_con_lg5(1); break;
            case 6: db.set_con_lg6(1); break;
            case 7: db.set_con_lg7(1); break;
        }
    }
    
    if (db.login_days < 14)
    {
        db.set_login_days(db.login_days + 1);    //连续登录天数加1
        switch( db.login_days )
        {
            case 1: set_lg_rewards(1); break;
            case 2: set_lg_rewards(2); break;
            case 3: set_lg_rewards(3); break;
            case 4: set_lg_rewards(4); break;
            case 5: set_lg_rewards(5); break;
            case 6: set_lg_rewards(6); break;
            case 7: set_lg_rewards(7); break;
            case 8: set_lg_rewards(8); break;
            case 9: set_lg_rewards(9); break;
            case 10: set_lg_rewards(10); break;
            case 11: set_lg_rewards(11); break;
            case 12: set_lg_rewards(12); break;
            case 13: set_lg_rewards(13); break;
            case 14: set_lg_rewards(14); break;
        }
    }
    //更新连续登录天数
    if (od > 2)
    {
        //登录天数清除
        db.set_total_login_days(1);
    }else
    {
        if (db.total_login_days < 7)
            if (od == 1)
                db.set_total_login_days(db.total_login_days + 1);
            else
                db.set_total_login_days(1);
        else
            db.set_total_login_days(db.total_login_days + 1); 
    }

    db.set_last_login(date_helper.cur_sec());
    save_db();
}
void sc_reward_t::cast_yb(int slience_)
{
   // if (!slience_)
    {
        sc_msg_def::nt_reward_t ret;

        //首次充值
        if( db.first_yb==0 )
        {
            if (slience_ == 9800){
                db.set_first_yb(1);
                //判断是否可领
                int32_t base_rmb = repo_mgr.configure.find(48)->second.value; 
                if (slience_ >= base_rmb){
                    db.set_can_get_first(1);
                    ret.can_get_first = 1;
                }else{
                    ret.can_get_first = 0;
                }
                ret.flag = first_yb;
                //if( !slience_ )
                logic.unicast(m_user.db.uid, ret);
            }
        }
        //累计充值
        if( db.yblevel!=-1 )
        {
            repo_def::acc_yb_t* rp_acc_yb = NULL;
            while((rp_acc_yb = repo_mgr.acc_yb.get(db.yblevel+1))!=NULL)
            {
                if ( m_user.db.vipexp < (rp_acc_yb->recharge) )
                    break;

                db.set_yblevel(db.yblevel+1);

                switch( db.yblevel )
                {
                    case 1: { ret.flag = acc_yb1; db.set_acc_yb1(1); } break;
                    case 2: { ret.flag = acc_yb2; db.set_acc_yb2(1); } break;
                    case 3: { ret.flag = acc_yb3; db.set_acc_yb3(1); } break;
                    case 4: { ret.flag = acc_yb4; db.set_acc_yb4(1); } break;
                    case 5: { ret.flag = acc_yb5; db.set_acc_yb5(1); } break;
                    case 6: { ret.flag = acc_yb6; db.set_acc_yb6(1); } break;
                    case 7: { ret.flag = acc_yb7; db.set_acc_yb7(1); } break;
                }
                //if( !slience_ )
                    logic.unicast(m_user.db.uid, ret);
            }
            if( 7==db.yblevel )
                db.set_yblevel(-1);
        }
        save_db();
    }
}
void sc_reward_t::put_reward(int32_t flag_)
{
    int32_t coin=0,resid=0,fpoint=0,freeyb=0;
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t item;

    switch(flag_/100)
    {
        case 1:
            {
            }
            break;
        case 2:
            {
                repo_def::acc_yb_t* rp_acc_yb = NULL;
                if((rp_acc_yb = repo_mgr.acc_yb.get(flag_%100))!=NULL)
                {
                    coin = rp_acc_yb->count1;

                    item.itid=0;
                    item.resid = rp_acc_yb->item2;
                    item.num = rp_acc_yb->count2;
                    if( item.resid != 0 )
                        nt.items.push_back(item);

                    item.itid=0;
                    item.resid = rp_acc_yb->item3;
                    item.num = rp_acc_yb->count3;
                    if( item.resid != 0 )
                        nt.items.push_back(item);

                    resid = rp_acc_yb->heroid;
                }
            }
            break;
        case 3:
            {
                repo_def::con_login_t* rp_con_lg = NULL;
                if((rp_con_lg = repo_mgr.con_login.get(flag_%100))!=NULL)
                {
                    auto f = [&](int item_, int num_)
                    {
                        if (num_ <= 0)
                            return ERROR_SC_ILLEGLE_REQ;
                        sc_msg_def::nt_bag_change_t nt;
                        if (item_ / 10000 == 3)
                            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                        else if (item_ == 10001)
                        {
                            m_user.on_money_change(num_);
                            m_user.save_db();
                        }
                        else
                        {
                            m_user.item_mgr.addnew(item_, num_, nt);
                            if (nt.items.empty())
                            {
                                logerror((LOG, "con reward items error!"));
                                return ERROR_SC_ILLEGLE_REQ;;
                            }
                        }
                        m_user.item_mgr.on_bag_change(nt);
                        return SUCCESS;
                    };

                    f(rp_con_lg->item1, rp_con_lg->count1);

                }
            }
            break;
        case 4:
            {
                int32_t om = get_month_delta();
                if( -1 == om )
                    break;
                repo_def::acc_login_t* rp_acc_lg = NULL;
                if((rp_acc_lg = repo_mgr.acc_login.get(flag_%100+ACC_LG_LEVEL*om))!=NULL)
                {
                    if( (rp_acc_lg->item)!=0 )
                    {
                        item.itid=0;
                        item.resid = rp_acc_lg->item;
                        item.num = rp_acc_lg->count;
                        nt.items.push_back(item);
                    }
                    resid = rp_acc_lg->heroid;
                }
            }
            break;
    }

    //奖励金币
    if( coin != 0 )
        m_user.db.set_gold(m_user.db.gold+coin);

    //奖励友情点
    if( fpoint!=0 )
        m_user.db.set_fpoint(m_user.db.fpoint+fpoint);

    //奖励免费水晶
    if( freeyb != 0 )
        m_user.db.set_freeyb(m_user.db.freeyb+freeyb);

    m_user.save_db();

    //奖励道具
    m_user.item_mgr.put(nt);

    //奖励伙伴
    if( resid != 0 )
    {
        //sp_partner_t sp_par = m_user.partner_mgr.hire(resid,1);
        m_user.partner_mgr.hire_from_reward(resid,1);
    }
}
int32_t sc_reward_t::get_reward(int32_t flag_, int32_t &dismess_)
{
    int32_t coin=0,resid=0,fpoint=0,freeyb=0;
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t item;
    int32_t equip = 0;

    dismess_ = 0;
    
    switch(flag_/100)
    {
        case 1:
            {
                if( db.first_yb != 1 || db.can_get_first != 1)
                    return ERROR_SC_ILLEGLE_REQ;
                repo_def::recharge_frist_t* fr_t = repo_mgr.recharge_fristtime.get(1);
                if (NULL == fr_t)
                    return ERROR_SC_ILLEGLE_REQ;
                auto f = [&](int item_, int num_)
                {
                    if (num_ <= 0)
                        return ERROR_SC_ILLEGLE_REQ;
                    sc_msg_def::nt_bag_change_t nt;
                    if (item_ / 10000 == 3)
                    {
                        m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                        statics_ins.unicast_eventlog(m_user,item_,num_,30000,1);
                    }
                    else if (item_ == 10001)
                    {
                        m_user.on_money_change(num_);
                        m_user.save_db();
                    }
                    else
                    {
                        m_user.item_mgr.addnew(item_, num_, nt);
                        if (nt.items.empty())
                        {
                            logerror((LOG, "buy add items error!"));
                            return ERROR_SC_ILLEGLE_REQ;;
                        }
                    }
                    m_user.item_mgr.on_bag_change(nt);
                    return SUCCESS;
                };
                f(fr_t->item1,fr_t->count1);             
                f(fr_t->item2,fr_t->count2);
                f(fr_t->item3,fr_t->count3);
                f(fr_t->item4,fr_t->count4);
                
                //置位
                db.set_first_yb(-1);
            }
            break;
        case 2:
            {
                //发送事件
                if( 207 == flag_ )
                    pushinfo.new_push(push_yadiana,m_user.db.nickname(),m_user.db.grade,m_user.db.uid,m_user.db.viplevel);

                switch( flag_%100 )
                {
                    case 1: { if(db.acc_yb1!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 2: { if(db.acc_yb2!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 3: { if(db.acc_yb3!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 4: { if(db.acc_yb4!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 5: { if(db.acc_yb5!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 6: { if(db.acc_yb6!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 7: { if(db.acc_yb7!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                }
                repo_def::acc_yb_t* rp_acc_yb = NULL;
                if((rp_acc_yb = repo_mgr.acc_yb.get(flag_%100))!=NULL)
                {
                    coin = rp_acc_yb->count1;

                    item.itid=0;
                    item.resid = rp_acc_yb->item2;
                    item.num = rp_acc_yb->count2;
                    if( item.resid != 0 )
                    {
                        nt.items.push_back(item);
                    }

                    /*
                    item.itid=0;
                    item.resid = rp_acc_yb->item3;
                    item.num = rp_acc_yb->count3;
                    if( item.resid != 0 )
                        nt.items.push_back(item);
                    */

                    if (!m_user.bag.can_change(nt))
                        return ERROR_BAG_FULL;

                    resid = rp_acc_yb->heroid;
                    
                    //置位
                    switch( flag_%100 )
                    {
                        case 1: db.set_acc_yb1(-1);break;
                        case 2: db.set_acc_yb2(-1);break;
                        case 3: db.set_acc_yb3(-1);break;
                        case 4: db.set_acc_yb4(-1);break;
                        case 5: db.set_acc_yb5(-1);break;
                        case 6: db.set_acc_yb6(-1);break;
                        case 7: db.set_acc_yb7(-1);break;
                    }
                }
            }
            break;
        case 3:
            {
                switch( flag_%100 )
                {
                    case 1: { if(db.con_lg1!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 2: { if(db.con_lg2!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 3: { if(db.con_lg3!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 4: { if(db.con_lg4!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 5: { if(db.con_lg5!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 6: { if(db.con_lg6!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                    case 7: { if(db.con_lg7!= 1)return ERROR_SC_ILLEGLE_REQ; }break;
                }

                repo_def::con_login_t* rp_con_lg = NULL;
                if((rp_con_lg = repo_mgr.con_login.get(flag_%100))!=NULL)
                {
                    auto f = [&](int item_, int num_)
                    {
                        if (num_ <= 0)
                            return ERROR_SC_ILLEGLE_REQ;
                        sc_msg_def::nt_bag_change_t nt;
                        if (item_ / 10000 == 3)
                            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                        else if (item_ == 10001)
                        {
                            m_user.on_money_change(num_);
                            m_user.save_db();
                        }
                        else
                        {
                            m_user.item_mgr.addnew(item_, num_, nt);
                            bool is_empty = true;
                            if (!nt.items.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_wings.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_pet.empty())
                            {
                                is_empty = false;
                            }
                            if (is_empty)
                            {                                 
                                return ERROR_SC_ILLEGLE_REQ;;
                            }
                        }
                        m_user.item_mgr.on_bag_change(nt);

                        return SUCCESS;
                    };

                    f(rp_con_lg->item1, rp_con_lg->count1);

                    //置位
                    switch( flag_%100 )
                    {
                        case 1: db.set_con_lg1(-1);break;
                        case 2: db.set_con_lg2(-1);break;
                        case 3: db.set_con_lg3(-1);break;
                        case 4: db.set_con_lg4(-1);break;
                        case 5: db.set_con_lg5(-1);break;
                        case 6: db.set_con_lg6(-1);break;
                        case 7: db.set_con_lg7(-1);break;
                    }
                }
            }
            break;
        case 4:
            {
                int32_t lv=flag_%100;
                if( lv<1 || lv>ACC_LG_LEVEL )
                    return ERROR_SC_ILLEGLE_REQ;
                if( *m_acclgs[lv-1] != 1 )
                    return ERROR_SC_ILLEGLE_REQ;

                int32_t om = get_month_delta();
                if( -1 == om )
                    break;
                repo_def::acc_login_t* rp_acc_lg = NULL;
                if((rp_acc_lg = repo_mgr.acc_login.get(flag_%100+ACC_LG_LEVEL*om))!=NULL)
                {
                    if( (rp_acc_lg->item)!=0 )
                    {
                        item.itid=0;
                        item.resid = rp_acc_lg->item;
                        item.num = rp_acc_lg->count;
                        nt.items.push_back(item);

                        if (!m_user.bag.can_change(nt))
                            return ERROR_BAG_FULL;
                    }
                    resid = rp_acc_lg->heroid;
                    
                    //置位
                    switch( flag_%100 )
                    {
                        case 1: db.set_acc_lg1(-1);break;
                        case 2: db.set_acc_lg2(-1);break;
                        case 3: db.set_acc_lg3(-1);break;
                        case 4: db.set_acc_lg4(-1);break;
                        case 5: db.set_acc_lg5(-1);break;
                        case 6: db.set_acc_lg6(-1);break;
                        case 7: db.set_acc_lg7(-1);break;
                        case 8: db.set_acc_lg8(-1);break;
                        case 9: db.set_acc_lg9(-1);break;
                        case 10: db.set_acc_lg10(-1);break;
                        case 11: db.set_acc_lg11(-1);break;
                        case 12: db.set_acc_lg12(-1);break;
                        case 13: db.set_acc_lg13(-1);break;
                        case 14: db.set_acc_lg14(-1);break;
                        case 15: db.set_acc_lg15(-1);break;
                        case 16: db.set_acc_lg16(-1);break;
                        case 17: db.set_acc_lg17(-1);break;
                        case 18: db.set_acc_lg18(-1);break;
                        case 19: db.set_acc_lg19(-1);break;
                        case 20: db.set_acc_lg20(-1);break;
                        case 21: db.set_acc_lg21(-1);break;
                        case 22: db.set_acc_lg22(-1);break;
                        case 23: db.set_acc_lg23(-1);break;
                        case 24: db.set_acc_lg24(-1);break;
                    }
                }
            }
            break;
        case 6:
            {
                switch( flag_%100 )
                {
                    case 1: { if(db.login_rewards[0] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 2: { if(db.login_rewards[1] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 3: { if(db.login_rewards[2] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 4: { if(db.login_rewards[3] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 5: { if(db.login_rewards[4] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 6: { if(db.login_rewards[5] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 7: { if(db.login_rewards[6] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 8: { if(db.login_rewards[7] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 9: { if(db.login_rewards[8] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 10: { if(db.login_rewards[9] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 11: { if(db.login_rewards[10] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 12: { if(db.login_rewards[11] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 13: { if(db.login_rewards[12] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                    case 14: { if(db.login_rewards[13] != '1')return ERROR_SC_ILLEGLE_REQ; }break;
                }

                repo_def::con_login_t* rp_con_lg = NULL;
                if((rp_con_lg = repo_mgr.con_login.get(flag_%100))!=NULL)
                {
                    auto f = [&](int item_, int num_)
                    {
                        if (num_ <= 0)
                            return ERROR_SC_ILLEGLE_REQ;
                        sc_msg_def::nt_bag_change_t nt;
                        if (item_ / 10000 == 3)
                            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                        else if (item_ == 10001)
                        {
                            m_user.on_money_change(num_);
                            m_user.save_db();
                        }
                        else
                        {
                            m_user.item_mgr.addnew(item_, num_, nt);
                            bool is_empty = true;
                            if (!nt.items.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_wings.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_pet.empty())
                            {
                                is_empty = false;
                            }
                            if (is_empty)
                            {                                 
                                logerror((LOG, "con reward items error!"));
                                return ERROR_SC_ILLEGLE_REQ;;
                            }
                        }
                        m_user.item_mgr.on_bag_change(nt);

                        return SUCCESS;
                    };

                    f(rp_con_lg->item1, rp_con_lg->count1);

                    //置位
                    switch( flag_%100 )
                    {
                        case 1:{db.login_rewards[0] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 2:{db.login_rewards[1] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 3:{db.login_rewards[2] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 4:{db.login_rewards[3] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 5:{db.login_rewards[4] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 6:{db.login_rewards[5] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 7:{db.login_rewards[6] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 8:{db.login_rewards[7] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 9:{db.login_rewards[8] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 10:{db.login_rewards[9] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 11:{db.login_rewards[10] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 12:{db.login_rewards[11]= '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 13:{db.login_rewards[12] = '2'; db.set_login_rewards(db.login_rewards);} break;
                        case 14:{db.login_rewards[13] = '2'; db.set_login_rewards(db.login_rewards);} break;
                    }
                }
            }
            break;
            case 7:
            {
                if (db.growing_package_status != 1)
                    return ERROR_SC_ILLEGLE_REQ;
                int index = flag_%100;
                if(db.growing_reward[index - 1] != '1')
                    return ERROR_SC_ILLEGLE_REQ;

                repo_def::growup_reward_t* rp_growup_reward = NULL;
                if((rp_growup_reward = repo_mgr.growup_reward.get(flag_%100))!=NULL)
                {
                    auto f = [&](int item_, int num_)
                    {
                        if (num_ <= 0)
                            return ERROR_SC_ILLEGLE_REQ;
                        sc_msg_def::nt_bag_change_t nt;
                        if (item_ / 10000 == 3)
                            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                        else if (item_ == 10001)
                        {
                            m_user.on_money_change(num_);
                            m_user.save_db();
                        }
                        else
                        {
                            m_user.item_mgr.addnew(item_, num_, nt);
                            bool is_empty = true;
                            if (!nt.items.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_wings.empty())
                            {
                                is_empty = false;
                            }
                            else if(!nt.add_pet.empty())
                            {
                                is_empty = false;
                            }
                            if (is_empty)
                            {                                 
                                logerror((LOG, "con reward items error!"));
                                return ERROR_SC_ILLEGLE_REQ;;
                            }
                        }
                        m_user.item_mgr.on_bag_change(nt);
                        return SUCCESS;
                    };

                    uint32_t size = rp_growup_reward->reward.size();
                    for (size_t i = 1; i < size; ++i)
                    {
                        f(rp_growup_reward->reward[i][0], rp_growup_reward->reward[i][1]);
                    }

                    //置位 
                    db.growing_reward[index - 1] = '2'; 
                    db.set_growing_reward(db.growing_reward);
                    save_db();
                }
            }
            break;
    }

    //奖励金币
    if( coin != 0 )
        m_user.on_money_change(coin);

    //奖励友情点
    if( fpoint!=0 )
        m_user.on_fpoint_change(fpoint);

    //奖励免费水晶
    if( freeyb != 0 )
        m_user.on_freeyb_change(freeyb);
    
    //奖励道具
    if( nt.items.size() != 0 )
        m_user.item_mgr.put(nt);

    //奖励装备
    if( equip != 0 )
        m_user.equip_mgr.addnew(equip,1,nt);

    m_user.item_mgr.on_bag_change(nt);

    m_user.save_db();

    //奖励伙伴
    if( resid != 0 )
        dismess_ = m_user.partner_mgr.hire_from_reward(resid);

    save_db();

    return SUCCESS;
}
void sc_reward_t::get_invcode()
{
    invcode_msg::req_code_t req;
    req.uid = m_user.db.uid;
    req.domain = m_user.plat_domain;
    logic.send_invcode_msg(req);
}
void sc_reward_t::handle_get_invcode(invcode_msg::ret_code_t &ret_)
{
    sc_msg_def::ret_invcode_t ret;
    if( ret_.code != SUCCESS )
    {
        ret.code = ret_.code;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    ret.invcode = ret_.invcode;
    ret.n1=ret_.n1;
    ret.n2=ret_.n2;
    ret.n3=ret_.n3;
    ret.n4=ret_.n4;
    if (db.inviter/100 != 0)
    {
        char sql[256];
        sql_result_t res;
        sprintf(sql, "select nickname from UserInfo where uid = %d;", db.inviter/100);
        db_service.sync_select(sql, res);
        if (res.get_row_at(0) == NULL)
        {
            logerror((LOG, "load fp rank get_row_at is NULL!!, at:%lu", db.inviter/100));
            ret.inviter = "";
        }
        else
        {
            sql_result_row_t& row_ = *res.get_row_at(0);
            ret.inviter = row_[0];
        }
    }
    else
    {
        ret.inviter = "";
    }

    if( (db.inv_reward1==0)&&(ret.n1>=1) )
        db.set_inv_reward1(1);
    if( (db.inv_reward2==0)&&(ret.n2>=2) )
        db.set_inv_reward2(1);
    if( (db.inv_reward3==0)&&(ret.n3>=4) )
        db.set_inv_reward3(1);
    if( (db.inv_reward4==0)&&(ret.n4>=6) )
        db.set_inv_reward4(1);
    save_db();

    ret.r1=db.inv_reward1;
    ret.r2=db.inv_reward2;
    ret.r3=db.inv_reward3;
    ret.r4=db.inv_reward4;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}
void sc_reward_t::set_inviter(string &invcode_)
{
    //是否设置过邀请者
    if( db.inviter )
    {
        sc_msg_def::ret_invcode_set_t ret;
        ret.code = ERROR_SC_NO_INV_FRIEND;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //获取该邀请码对应的uid
    invcode_msg::req_uid_t req;
    req.suid = m_user.db.uid;
    req.invcode = invcode_;
    req.domain = m_user.plat_domain;
    logic.send_invcode_msg(req);
}
int sc_reward_t::isinvited()
{
    if( db.inviter )
        return 1;
    else
        return 0;

}
void sc_reward_t::handle_set_inviter(int code_,int uid_)
{
    sc_msg_def::ret_invcode_set_t ret;

    if( SUCCESS == code_ )
    {
        db.set_inviter(uid_);
        save_db();

        //发送五个女神洗礼
      //  sc_msg_def::nt_bag_change_t nt;
      //  m_user.item_mgr.addnew(15002,5,nt);
      //  m_user.item_mgr.on_bag_change(nt);

        //判断玩家等级
        if( m_user.db.grade>=INV_LV4 )
        {
            invitee_upgrade(INV_LV1);
            invitee_upgrade(INV_LV2);
            invitee_upgrade(INV_LV3);
            invitee_upgrade(INV_LV4);
        }
        else if( m_user.db.grade>=INV_LV3 )
        {
            invitee_upgrade(INV_LV1);
            invitee_upgrade(INV_LV2);
            invitee_upgrade(INV_LV3);
        }
        else if( m_user.db.grade>=INV_LV2 )
        {
            invitee_upgrade(INV_LV1);
            invitee_upgrade(INV_LV2);
        }
        else if( m_user.db.grade>=INV_LV1 )
        {
            invitee_upgrade(INV_LV1);
        }

        ret.code = SUCCESS;
    }
    else
        ret.code = code_;

    logic.unicast(m_user.db.uid, ret);
}
void sc_reward_t::invitee_upgrade(int32_t grade_)
{
    invcode_msg::nt_upgrade_t nt;
    nt.inviter = db.inviter;
    nt.grade = grade_;
    logic.send_invcode_msg(nt);
}
/*
void sc_reward_t::get_invcode_reward_info()
{
    invcode_msg::req_reward_t req;
    req.uid = m_user.db.uid;
    logic.send_invcode_msg(req);
}
void sc_reward_t::handle_get_invcode_reward_info(int r1_,int r2_,int r3_,int r4_)
{
    sc_msg_def::nt_invcode_rewinfo_t nt;

    if( (db.inv_reward1!=-1)&&r1_ )
        nt.r1=1;
    else
        nt.r1=0;
    
    if( (db.inv_reward2!=-1)&&r2_ )
        nt.r2=1;
    else
        nt.r2=0;
    
    if( (db.inv_reward3!=-1)&&r3_ )
        nt.r3=1;
    else
        nt.r3=0;
    
    if( (db.inv_reward4!=-1)&&r4_ )
        nt.r4=1;
    else
        nt.r4=0;

    logic.unicast(m_user.db.uid, nt);

}
*/
void sc_reward_t::get_invcode_reward(int32_t flag_)
{
    sc_msg_def::ret_invcode_reward_t ret;
    ret.flag = flag_;
    ret.dismess = 0;

    if( flag_<1 || flag_>4 )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    if (m_user.bag.is_full())
    {
        ret.code =  ERROR_BAG_FULL;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    if( (flag_==4) && (db.inv_reward4==1) )
    {
        db.set_inv_reward4(-1);
        m_user.vip.on_exp_change(100, 1);
        save_db();
    }
    else if( (flag_==1) && (db.inv_reward1==1) )
    {
        db.set_inv_reward1(-1);
        save_db();
    }
    else if( (flag_==2) && (db.inv_reward2==1) )
    {
        db.set_inv_reward2(-1);
        m_user.vip.on_exp_change(10, 1);
        save_db();
    }
    else if( (flag_==3) && (db.inv_reward3==1) )
    {
        db.set_inv_reward3(-1);
        save_db();
    }
    else
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    repo_def::friend_reward_t *rp_fr = repo_mgr.friend_reward.get(flag_);
    if (rp_fr == NULL)
    {
        logerror((LOG, "repo invite friend reward no id:%d", flag_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    sc_msg_def::nt_bag_change_t nt;
    auto f = [&](int item_, int num_)
    {
        if (num_ <= 0)
            return ERROR_SC_ILLEGLE_REQ;
        sc_msg_def::nt_bag_change_t nt;
        if (item_ / 10000 == 3)
            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
        else if (item_ == 10001)
        {
            m_user.on_money_change(num_);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(item_, num_, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_ILLEGLE_REQ;;
            }
        }
        m_user.item_mgr.on_bag_change(nt);
        return SUCCESS;
    };

    f(rp_fr->reward, rp_fr->count);

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}
int sc_reward_t::get_inviter()
{
    return db.inviter;
}
/*
int sc_reward_t::unicast_rank_reward()
{
    sc_msg_def::ret_rank_reward_t ret;

    if ( (server.db.result_rank_stamp>db.given_rank_stamp) && (server.db.result_rank_stamp>db.first_login) )
    {
        //奖励奖励排名
        ret.code = SUCCESS;
        ret.rank = arena_rank.get_reward_rank(m_user.db.uid);
    }
    else
    {
        ret.code = ERROR_ARENA_NO_REWARD;
        ret.rank = 0;
    }
    logic.unicast(m_user.db.uid, ret);

    return 0;
      //奖励之前的排名时间戳应该在奖励排名3天之内
//    int offday = date_helper.offday(db.given_rank_stamp, server.db.result_rank_stamp);
//    if (offday >= -3 && offday <= 0)

    //else if (db.given_rank_stamp != 0)
    //{
    //    db.set_given_rank_stamp(0);
    //    save_db();
    //}
}
*/
void sc_reward_t::update_rank_reward(int rank_)
{
    uint32_t cur_stamp = date_helper.cur_sec();
    if (cur_stamp <= server.db.result_rank_stamp)
    {
        //当前时间戳比排名奖励时间点小，则更新奖励时间戳
        db.set_given_rank_stamp(cur_stamp);
        save_db();
    }
}
/*
int sc_reward_t::given_rank_reward()
{
    //如果存在奖励时间戳，则表示有奖励可以领取
    if ( (server.db.result_rank_stamp>db.given_rank_stamp) && (server.db.result_rank_stamp>db.first_login) )
//    if (db.given_rank_stamp != 0)
    {
        db.set_given_rank_stamp( date_helper.cur_sec() );
        save_db();

        //领取奖励
        int rank = arena_rank.get_reward_rank(m_user.db.uid);
        if (51  <= rank && rank <= 100)
            rank = 51;
        else if (101 <= rank && rank <= 300)
            rank = 101;
        else if (301 <= rank && rank <= 500)
            rank = 301;
        else if (501 <= rank && rank <= 1000)
            rank = 501;
        else if (1001 <= rank)
            rank = 1001;

        //通知奖励
        //m_user.on_battlexp_change(rp_reward->btp);
        // m_user.save_db();
        

        auto rp_gmail = mailinfo.get_repo(mail_arena_reward);
        if (rp_gmail != NULL)
        {
            repo_def::arena_reward_t* rp_reward = repo_mgr.arena_reward.get(rank); 
            vector<sc_msg_def::jpk_item_t> items;

            if (rp_reward != NULL && rp_reward->btp>0)
            {
                sc_msg_def::jpk_item_t itm;
                itm.itid=0;
                itm.resid=10002;

                float p = 0;
                if (m_user.db.viplevel == 8)
                    p=0.3f;
                else if (m_user.db.viplevel == 10)
                    p=0.5f;

                itm.num=rp_reward->btp * (1+p);
                items.push_back(std::move(itm));
            }

            if (rp_reward != NULL && rp_reward->item != 0 && rp_reward->number > 0)
            {
                sc_msg_def::jpk_item_t itm;
                itm.itid=0;
                itm.resid=rp_reward->item;
                itm.num=rp_reward->number;
                items.push_back(std::move(itm));
            }
            string msg = mailinfo.new_mail(mail_arena_reward, m_user.db.rank);
            m_user.gmail.send(rp_gmail->title, rp_gmail->sender, msg,rp_gmail->validtime, items); 
        }

        return SUCCESS;
    }
    return ERROR_ARENA_NO_REWARD;
}
*/
int sc_reward_t::given_power()
{
    if (!m_user.vip.enable_do(vop_given_power))
        return ERROR_SC_NOT_ENOUGH_VIP;
    if ( reward_power_cd() <= 0)
    {
        repo_def::vip_t* vip_info = repo_mgr.vip.get(m_user.db.viplevel);
        if (m_user.db.power >= vip_info->power_limit)
            return ERROR_POWER_MAX;
        else
        {
            //给予体力 
            if(m_user.db.power + 60 > vip_info->power_limit)
                m_user.on_power_change(vip_info->power_limit - m_user.db.power);
            else
                m_user.on_power_change(60);
            m_user.save_db();
            db.given_power_stamp = date_helper.cur_sec();
            db.set_given_power_stamp(date_helper.cur_sec());
            save_db();
            return SUCCESS;
        }
    }
    return ERROR_SC_NOT_ENOUGH_TIME;
}
int sc_reward_t::reward_power_cd()
{
    uint32_t cur_0_stmp = date_helper.cur_0_stmp();
    uint32_t stampbegin1 = cur_0_stmp + 12*3600;
    uint32_t stampend1 = cur_0_stmp + 14*3600;
    uint32_t stampbegin2 = cur_0_stmp + 17*3600;
    uint32_t stampend2 = cur_0_stmp + 19*3600;
    uint32_t stampbegin3 = cur_0_stmp + 21*3600;
    uint32_t stampend3 = cur_0_stmp + 23*3600;
    uint32_t timebegin1 = 12*3600;
    uint32_t timebegin2 = 17*3600;
    uint32_t timebegin3 = 21*3600;
    uint32_t time_24 = 24*3600;

    uint32_t sec = date_helper.secoffday();
    uint32_t now_stmp = date_helper.cur_sec();
    //在12点左边
    if ( now_stmp < stampbegin1)
    {
        return timebegin1-sec;
    }
    //在12点的右边，在18点的左边
    else if (stampbegin1 <= now_stmp && now_stmp < stampbegin2)
    {
        if (db.given_power_stamp <= stampbegin1 && now_stmp <= stampend1)
        {
            return 0;
        }
        else
        {
            return timebegin2-sec;
        }
    }
    else if (stampbegin2 <= now_stmp && now_stmp < stampbegin3)
    {
        if (db.given_power_stamp <= stampbegin2 && now_stmp <= stampend2)
        {
            return 0;
        }
        else
        {
            return timebegin3-sec;
        }
    //在18点的右边
    }
    else 
    {
        if (db.given_power_stamp <= stampbegin3 && now_stmp <= stampend3)
        {
            return 0;
        }
        else
        {
            return time_24 - sec + timebegin1;
        }
    }
}
void sc_reward_t::on_vip_upgrade(int viplevel_,int slience_)
{
    if (viplevel_ > 18 || viplevel_ <= m_user.db.viplevel)
        return;

    sc_limit_round_mgr.update_reset_times(m_user.db.uid, viplevel_);
    for(int v=1; v<=viplevel_; v++)
    {
        //可以领取的设置1
        if ((*m_vips[v-1]) == 0)
        {
            //已经领取奖励
            switch(v)
            {
                case 1: db.set_vip1(1);break;
                case 2: db.set_vip2(1);break;
                case 3: db.set_vip3(1);break;
                case 4: db.set_vip4(1);break;
                case 5: db.set_vip5(1);break;
                case 6: db.set_vip6(1);break;
                case 7: db.set_vip7(1);break;
                case 8: db.set_vip8(1);break;
                case 9: db.set_vip9(1);break;
                case 10: db.set_vip10(1);break;
                case 11: db.set_vip11(1);break;
                case 12: db.set_vip12(1);break;
                case 13: db.set_vip13(1);break;
                case 14: db.set_vip14(1);break;
                case 15: db.set_vip15(1);break;
                case 16: db.set_vip16(1);break;
                case 17: db.set_vip17(1);break;
                case 18: db.set_vip18(1);break;
            }

            if( !slience_ )
            {
                sc_msg_def::nt_reward_t nt;
                nt.flag = 500+v;
                logic.unicast(m_user.db.uid, nt);
            }
        }
    }

    save_db();
    
    given_vip_package(viplevel_);
}
int sc_reward_t::given_vip_reward(int viplevel_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    if (viplevel_ > 18 || viplevel_ < 0)
        return -1;

    int &v = (*m_vips[viplevel_-1]);
    if (v <= 0)
        return ERROR_SC_NOT_ENOUGH_VIP;

    repo_def::vip_t* rp_vcg = repo_mgr.vip.get(viplevel_);
    if (rp_vcg == NULL)
    {
        logerror((LOG, "repo vip no level:%d", m_user.db.viplevel));
        return ERROR_SC_EXCEPTION;
    }

    //奖励金币
    m_user.on_money_change(rp_vcg->pro1);
    m_user.save_db();

    //奖励礼包 
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(rp_vcg->item2, rp_vcg->pro2, nt);
    //m_user.equip_mgr.addnew(rp_vcg->item2, rp_vcg->pro2, nt);
    m_user.item_mgr.on_bag_change(nt);

    //已经领取奖励
    switch(viplevel_)
    {
    case 1: db.set_vip1(-1);break;
    case 2: db.set_vip2(-1);break;
    case 3: db.set_vip3(-1);break;
    case 4: db.set_vip4(-1);break;
    case 5: db.set_vip5(-1);break;
    case 6: db.set_vip6(-1);break;
    case 7: db.set_vip7(-1);break;
    case 8: db.set_vip8(-1);break;
    case 9: db.set_vip9(-1);break;
    case 10: db.set_vip10(-1);break;
    case 11: db.set_vip11(-1);break;
    case 12: db.set_vip12(-1);break;
    case 13: db.set_vip13(-1);break;
    case 14: db.set_vip14(-1);break;
    case 15: db.set_vip15(-1);break;
    case 16: db.set_vip16(-1);break;
    case 17: db.set_vip17(-1);break;
    case 18: db.set_vip18(-1);break;
    }

    save_db();

    return SUCCESS;
}
int sc_reward_t::get_online_reward_cd()
{
    if( -1 == db.online )
        return -1;

    repo_def::online_t* rp_online = repo_mgr.online.get(db.online+1);
    if (rp_online == NULL)
    {
        logerror((LOG, "rp_online prepare no resid:%d", db.online+1));
        return 0;
    }
    
    int cd = db.next_online - date_helper.cur_sec();
    if (cd < 0) cd=0;
    return cd;
}

int sc_reward_t::get_online_reward(int& resid_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    resid_ = 0;
    int cd = get_online_reward_cd(); 
    if (cd < 0) 
    {
        cout << "wrong1"<<endl;
        logerror((LOG, "rp_online cd < 0"));
        return ERROR_SC_EXCEPTION;
    }
    else if (cd == 0)
    {
        db.set_online(db.online + 1);
        resid_ = db.online;

        repo_def::online_t* rp_online = repo_mgr.online.get(db.online);
        if (rp_online == NULL)
        {
            cout << "wrong2"<<endl;
            logerror((LOG, "rp_online no resid:%d", db.online));
            return ERROR_SC_EXCEPTION;
        }

        sc_msg_def::nt_bag_change_t nt;
        uint32_t size = rp_online->reward.size();
        for (size_t i = 1; i < size; ++i)
        {
            m_user.item_mgr.addnew(rp_online->reward[i][0], rp_online->reward[i][1], nt);
            //f(rp_lmt_reward->reward[i][0], rp_lmt_reward->reward[i][1]);
        }

        /*m_user.item_mgr.addnew(rp_online->item1, rp_online->count1, nt);
        m_user.item_mgr.addnew(rp_online->item2, rp_online->count2, nt);
        m_user.item_mgr.addnew(rp_online->item3, rp_online->count3, nt);
        m_user.item_mgr.addnew(rp_online->item4, rp_online->count4, nt);
        */
        //如果有发生过用户数据改变（钱等）,更新用户数据
        if (nt.items.size() != 4)
        {
            m_user.save_db();
        }
        //刷新数据
        m_user.item_mgr.on_bag_change(nt);
        m_online_stamp = date_helper.cur_sec();
        rp_online = repo_mgr.online.get(db.online+1);
        if (rp_online == NULL)
            db.set_online(-1);
        save_db();

        return SUCCESS;
    }
    else
    {
        logerror((LOG, "rp_online cd > 0"));
        return ERROR_SC_ILLEGLE_REQ;
    }
}
int sc_reward_t::get_online_reward_num(int& resid_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    resid_ = 0;
    int cd = get_online_reward_cd(); 
    if (cd < 0) 
    {
        logerror((LOG, "rp_online cd < 0"));
        return ERROR_SC_EXCEPTION;
    }
    else
    {
        resid_ = db.online + 1;
        return SUCCESS;
    }
    
    /*resid_ = 0;
    int cd = get_online_reward_cd(); 
    if (cd < 0) 
    {
        logerror((LOG, "rp_online cd < 0"));
        return ERROR_SC_EXCEPTION;
    }
    else if (cd == 0)
    {
        resid_ = db.online + 1;
        return SUCCESS;
    }
    else
    {
        logerror((LOG, "rp_online cd > 0"));
        return ERROR_SC_ILLEGLE_REQ;
    }*/
}
int sc_reward_t::given_login_yb(vector<sc_msg_def::jpk_item_t> &ret_)
{
    /*
    auto it = login_yb_hm.find(m_user.db.uid);
    if (it == login_yb_hm.end() || date_helper.offday(it->second) >= 1)
    {
        login_yb_hm[m_user.db.uid] = date_helper.cur_sec();

        m_user.on_freeyb_change(500);
        m_user.save_db();
        return SUCCESS;
    }

    return FAILED;
    */
    auto it = login_yb_hm.find(m_user.db.uid);
    if (it == login_yb_hm.end() || date_helper.offday(it->second) >= 1)
    {
        login_yb_hm[m_user.db.uid] = date_helper.cur_sec();

        sc_msg_def::jpk_item_t item;
        item.itid = 0;
        item.resid = 0;
        item.num = 0;

        auto it_lgrw = repo_mgr.first_lgrw.begin();
        while( it_lgrw != repo_mgr.first_lgrw.end() )
        {
            if( 10001 == it_lgrw->first )
            {
                m_user.on_money_change(it_lgrw->second.count1);

                item.resid = 10001;
                item.num = it_lgrw->second.count1;
            }
            else if( 10003 == it_lgrw->first )
            {
                m_user.on_freeyb_change(it_lgrw->second.count1);

                item.resid = 10003;
                item.num = it_lgrw->second.count1;
            }
            if (item.resid != 0)
                ret_.push_back( std::move(item) );

            it_lgrw++;
        }
        m_user.save_db();

        //推送信封
        /*
        string mail = mailinfo.new_mail(mail_login_reward_info); 
        if (!mail.empty())
        {
            notify_ctl.push_mail(m_user.db.uid, mail);
        }
        */

        return SUCCESS;
    }
    return FAILED;
}
void sc_reward_t::on_login()
{
    m_online_stamp = date_helper.cur_sec();
    given_vip_package(m_user.db.viplevel);
}
int sc_reward_t::given_starreward(int id_, int starnum_)
{
    repo_def::starreward_t* rp_sr = repo_mgr.starreward.get(id_);
    if (rp_sr == NULL)
    {
        logerror((LOG, "repo starreward no id:%d", id_));
        return ERROR_SC_EXCEPTION;
    }

    if (id_ < 0)
        return ERROR_SC_ILLEGLE_REQ;

    auto it = m_sr_map.find(id_);
    if (it == m_sr_map.end())
        return ERROR_SC_ILLEGLE_REQ;
    
    int rid = (id_-1) * 10;
    int total_star = 0;
    int rlen = (int)m_user.db.roundstars.size();
    for(int i=0;(rid+i)<rlen&&i<10;i++)
    {
        //计算该关有多少颗星星
        int n = 0;
        switch (m_user.db.roundstars[rid+i])
        {
            case '0':
                n = 0;
                break;
            case '1':
                n = 1;
                break;
            case '2':
                n = 1;
                break;
            case '3':
                n = 2;
                break;
            case '4':
                n = 1;
                break;
            case '5':
                n = 2;
                break;
            case '6':
                n = 2;
                break;
            case '7':
                n = 3;
                break;
            case '8':
                n = 1;
                break;
            case '9':
                n = 2;
                break;
            case 'a':
                n = 2;
                break;
            case 'b':
                n = 3;
                break;
            case 'c':
                n = 2;
                break;
            case 'd':
                n = 3;
                break;
            case 'e':
                n = 3;
                break;
            case 'f':
                n = 4;
                break;
            default:
                n = 0;
        }
        //int n = m_user.db.roundstars[rid+i] - '0';
        total_star += n;
    }

    if (total_star<10 || total_star < starnum_)
        return ERROR_STARREWARD_NOENOUGH ;

    sp_sr_t& sp_sr = it->second;

    vector<vector<int>>* countNum = NULL; rp_sr->count1;
    if (10 == starnum_)
    {
        if (sp_sr->r1 != 0)
            return ERROR_SC_ILLEGLE_REQ;
        sp_sr->set_r1(1);

        countNum = &(rp_sr->count1);
    }
    else if (20 == starnum_)
    {
        if (sp_sr->r2 != 0)
            return ERROR_SC_ILLEGLE_REQ;
        sp_sr->set_r2(1);

        countNum = &(rp_sr->count2);
    }
    else if (30 == starnum_)
    {
        if (sp_sr->r3 != 0)
            return ERROR_SC_ILLEGLE_REQ;
        sp_sr->set_r3(1);

        countNum = &(rp_sr->count3);
    }
    else if (40 == starnum_)
    {
        if (sp_sr->r4 !=0)
            return ERROR_SC_ILLEGLE_REQ;
        sp_sr->set_r4(1);

        countNum = &(rp_sr->count4);
    }
    else
    {
        return ERROR_SC_ILLEGLE_REQ;
    }

    for(int i=1;i<countNum->size();i++)
    {
        vector<int>& reward = (*countNum)[i];
        if ( 10003 == reward[0])
        {
            m_user.on_freeyb_change(reward[1]);
        }
        else if ( 10005 == reward[0])
        {
            m_user.on_power_change(reward[1]);
        }
        else if ( 10001 == reward[0])
        {
            m_user.on_money_change(reward[1]);
        }
        else if ( 30000 < reward[0] && reward[0] < 40000)
        {
            sc_msg_def::nt_chip_change_t change;
            sc_msg_def::jpk_pub_chip_t chip;
            chip.resid = reward[0];
            chip.count = reward[1];
            chip.reduced = 0;
            m_user.partner_mgr.add_new_chip(chip.resid,chip.count,change);
            m_user.partner_mgr.on_chip_change(change);
        }
        else
        {
            //道具
/*            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item;
            nt.items.clear();

            repo_def::item_t* rp_item = repo_mgr.item.get(reward[0]);
            if (rp_item == NULL)
                continue;
            if( (rp_item->type==2)||(rp_item->type==8) )
                continue;
            item.itid = 0;
            item.resid = reward[0];
            item.num = reward[1];
            nt.items.push_back(std::move(item));
            m_user.item_mgr.put(nt);
*/
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.addnew(reward[0], reward[1], nt);
            m_user.item_mgr.on_bag_change(nt);
        }
    }

    save_sr_db(sp_sr);
    m_user.save_db();
    return SUCCESS;
}
int sc_reward_t::save_sr_db(sp_sr_t sp_sr_)
{
    string sql = sp_sr_->get_up_sql();
    if (sql.empty()) return -1;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
    return 0;
}
int sc_reward_t::unicast_starreward_info(int id_)
{
    sp_sr_t sp_db;
    auto it = m_sr_map.find(id_);
    if (it == m_sr_map.end())
    {
        sp_db.reset(new db_RoundStarReward_ext_t);
        sp_db->uid = m_user.db.uid;
        sp_db->rpid = id_;
        sp_db->r4 = sp_db->r1 = sp_db->r2 = sp_db->r3 = 0;

        db_service.async_do((uint64_t)m_user.db.uid, [](sp_sr_t& sp_db_){
            sp_db_->insert();
        }, sp_db);

        m_sr_map[id_] = sp_db;
    }
    else sp_db = it->second;

    sc_msg_def::ret_starreward_info_t ret;
    ret.code = SUCCESS;
    ret.id = id_;
    ret.given[0] = sp_db->r1;
    ret.given[1] = sp_db->r2;
    ret.given[2] = sp_db->r3;
    ret.given[3] = sp_db->r4;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}
int sc_reward_t::load_starreward()
{
    sql_result_t res;
    if (0 == db_RoundStarReward_ext_t::sync_select(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++){
            sp_sr_t sp_db(new db_RoundStarReward_ext_t);
            sp_db->init(*res.get_row_at(i));
            m_sr_map[sp_db->rpid] = std::move(sp_db);
        }
    }
    return SUCCESS;
}
int sc_reward_t::async_load_starreward()
{
    sql_result_t res;
    if (0 == db_RoundStarReward_ext_t::select(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++){
            sp_sr_t sp_db(new db_RoundStarReward_ext_t);
            sp_db->init(*res.get_row_at(i));
            m_sr_map[sp_db->rpid] = std::move(sp_db);
        }
    }
    return SUCCESS;
}
void sc_reward_t::get_cdkey_reward(string cdkey_)
{
    sc_msg_def::ret_cdkey_reward_t ret;
    ret.resid = 0;

    //判断cdkey是否有效
    sql_result_t res;
    db_Cdkey_t::sync_select_sn(cdkey_, res);
    if( 0==res.affect_row_num() )
    {
        ret.code = ERROR_CDKEY_NOT_EXISTED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    db_Cdkey_ext_t db;
    db.init(*res.get_row_at(0));
    //判断cdkey是否已经被用过
    if( db.uid != 0 )
    {
        ret.code = ERROR_CDKEY_USED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    //判断该玩家是否领取过相同类型的奖励
    char s[256];
    sprintf(s,"select uid from Cdkey where flag=%d and uid=%d;",db.flag,m_user.db.uid);
    dbgl_service.sync_select(s, res);
    if( res.affect_row_num()!=0 )
    {
        ret.code = ERROR_CDKEY_INPUTED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //判断该玩家是否领取正确平台的奖励
    char sq[256];
    conf_def::global_sqldb_t &gldb = config.global_sqldb;
    sprintf(sq,"select * from %s.Account where lastuid=%d and domain='%s';",gldb.name.c_str(), m_user.db.uid, db.domain.c_str());
    db_service.sync_select(sq, res);
    if(res.affect_row_num() < 1 )
    {
        if (strcmp(db.domain.c_str(), "alldomain") != 0)
        {
            ret.code = ERROR_CDKEY_NOT_EXISTED;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }

    //发放奖励
    repo_def::cdkey_reward_t *rp_cdkey = repo_mgr.cdkey_reward.get(db.flag);
    if ((rp_cdkey==NULL))
    {
        logerror((LOG, "repo cdkey reward no id:%d", db.flag));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    auto item_size = rp_cdkey->item.size();
    for(auto i = 0; i < item_size; i++)
    {
        if( rp_cdkey->item[i][0] >= 30000 && rp_cdkey->item[i][0] < 40000 )
        {
            sc_msg_def::nt_chip_change_t change;
            m_user.partner_mgr.add_new_chip(rp_cdkey->item[i][0],rp_cdkey->item[i][1],change);
            m_user.partner_mgr.on_chip_change(change);
            vector<int32_t> cdkey_item;
            cdkey_item.push_back(std::move(rp_cdkey->item[i][0])); 
            cdkey_item.push_back(std::move(rp_cdkey->item[i][1])); 
            ret.items.push_back(std::move(cdkey_item));
        }
        else
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.addnew(rp_cdkey->item[i][0], rp_cdkey->item[i][1], nt);
            m_user.item_mgr.on_bag_change(nt);
            vector<int32_t> cdkey_item;
            cdkey_item.push_back(std::move(rp_cdkey->item[i][0])); 
            cdkey_item.push_back(std::move(rp_cdkey->item[i][1])); 
            ret.items.push_back(std::move(cdkey_item));
        }
    }

    m_user.save_db();
    ret.resid = db.flag;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);

    //置位
    db.set_uid(m_user.db.uid);
    db.set_nickname(m_user.db.nickname());
    db.set_giventm(date_helper.str_date_mysql(0));
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    dbgl_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
            dbgl_service.async_execute(sql_);
    }, sql);
}
void sc_reward_t::get_lv_reward(int32_t lv_)
{
    sc_msg_def::ret_lv_reward_t ret;
    ret.lv = lv_;

    //判断玩家是否有资格领取
    if( m_user.db.grade < lv_ )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
     
    //判断玩家是否已经领取过
    int32_t is_exist = 1;
    switch(lv_)
    {
        case 10:is_exist=db.lv_20;break;
        case 20:is_exist=db.lv_25;break;
        case 30:is_exist=db.lv_30;break;
        case 40:is_exist=db.lv_35;break;
        case 50:is_exist=db.lv_40;break;
        case 60:is_exist=db.lv_45;break;
        case 70:is_exist=db.lv_50;break;
        case 80:is_exist=db.lv_55;break;
   /*     case 55:is_exist=db.lv_55;break;
        case 60:is_exist=db.lv_60;break;
        case 65:is_exist=db.lv_65;break;
        case 70:is_exist=db.lv_70;break;
  */    default:is_exist=-1;
    }
    if( -1 == is_exist )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    repo_def::level_reward_t *rp_lv = repo_mgr.level_reward.get(lv_);
    if (rp_lv == NULL)
    {
        logerror((LOG, "repo level reward no id:%d", lv_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    auto f = [&](int item_, int num_)
    {
        if (num_ <= 0)
            return ERROR_SC_ILLEGLE_REQ;
        sc_msg_def::nt_bag_change_t nt;
        if (item_ / 10000 == 3)
            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
        else if (item_ == 10001)
        {
            m_user.on_money_change(num_);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(item_, num_, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_ILLEGLE_REQ;;
            }
        }
        m_user.item_mgr.on_bag_change(nt);
        return SUCCESS;
    };

    f(rp_lv->item1, rp_lv->count1);
    f(rp_lv->item2, rp_lv->count2);
    f(rp_lv->item3, rp_lv->count3);
    f(rp_lv->item4, rp_lv->count4);
/*
    //判断是否有符文奖励
    int32_t rune_id = 0;
    if( rp_lv->item5  )
    {
        rune_id = m_user.rune_mgr.get_blank();
        if( -1 == rune_id )
        {
            ret.code = ERROR_RUNE_BAG_FULL;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }
    //奖励水晶
    m_user.on_freeyb_change(rp_lv->count1);
    //奖励金币
    m_user.on_money_change(rp_lv->count2);
    //奖励战历
    m_user.on_battlexp_change(rp_lv->count4);
    m_user.save_db();
    //奖励道具
    sc_msg_def::jpk_item_t item;
    sc_msg_def::nt_bag_change_t nt;

    if( rp_lv->item3 != 0 )
    {
        item.itid = 0;
        item.resid = rp_lv->item3;
        item.num = rp_lv->count3;
        nt.items.push_back( item );
    }

    m_user.item_mgr.put(nt);
    m_user.item_mgr.on_bag_change(nt);
    //奖励符文
    if( rp_lv ->item5 )
        m_user.rune_mgr.add_rune(rp_lv->item5);
*/
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);

    //置位
    switch(lv_)
    {
        case 10:db.set_lv_20(-1);break;
        case 20:db.set_lv_25(-1);break;
        case 30:db.set_lv_30(-1);break;
        case 40:db.set_lv_35(-1);break;
        case 50:db.set_lv_40(-1);break;
        case 60:db.set_lv_45(-1);break;
        case 70:db.set_lv_50(-1);break;
        case 80:db.set_lv_55(-1);break;
     /*   case 60:db.set_lv_60(-1);break;
        case 65:db.set_lv_65(-1);break;
        case 70:db.set_lv_70(-1);break;
    */
    }
    save_db();
}
int sc_reward_t::nt_mcard_info()
{
    sc_msg_def::nt_mcard_info_t nt;
    nt.todayn = get_mcardn(nt.mcardn);
    logic.unicast(m_user.db.uid, nt);
    return 0;
}
int sc_reward_t::get_mcardn(int& contain_)
{
    contain_ = 0;
    if (db.mcardtm < 0)
        return 0;

    if (db.mcardtm == 0)
    {
        contain_ = db.mcardn;
        if (date_helper.offday(db.mcardbuytm)==0)
            return 1;
        else return 0;
    }

    //上一次月卡领取时间
    int day = date_helper.offday(db.mcardtm);
    if (day > 0)
    {
        int off = db.mcardn - day;
        if (off < 0)
        {
            db.set_mcardn(0);
            db.set_mcardtm(0);
            contain_ = 0;
            return 0;
        }
        else
        {
            contain_ = off;
            return 1;
        }
    }
    else
    {
        contain_ = db.mcardn;
        return 0;
    }
}
int sc_reward_t::given_mcard_reward()
{
    if (db.mcardtm < 0)
        return ERROR_SC_ILLEGLE_REQ;

    int day = date_helper.offday(db.mcardtm);
    if (date_helper.offday(db.mcardbuytm)==0)
        day = 1;
    if (day <= 0 or db.mcardtm > date_helper.cur_0_stmp())
        return ERROR_SC_ILLEGLE_REQ;

    int off = db.mcardn - day;
    if (off < 0)
    {
        db.set_mcardn(0);
        db.set_mcardtm(0);
        save_db();
        return ERROR_SC_ILLEGLE_REQ;
    }
    else
    {
        m_user.on_freeyb_change(120);
        db.set_mcardn(off);
        db.set_mcardtm(date_helper.cur_sec());
        save_db();
        return SUCCESS;
    }
}
void sc_reward_t::get_cumu_yb_reward(int32_t pos_)
{
    repo_def::cumu_consume_t *p_r = repo_mgr.cumu_consume.get(pos_);
    if( NULL == p_r )
        return;

    sc_msg_def::ret_cumu_yb_reward_t ret;
    ret.pos = pos_;

    //判断活动是否过期
    int32_t ts_after_day = server.db.ctime + p_r->day * 86400;
    uint32_t deadline = ts_after_day - (ts_after_day+28800)%86400;
    if( date_helper.cur_sec() > (deadline+86400))
    {
        ret.code = ERROR_QUEST_OVERDUED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    //是否已经领过
    if( (db.cumu_yb_reward & (1<<pos_)) == 1 )
    {
        logerror((LOG, "get_cumu_yb, not prepared: %d,%d",db.cumu_yb_reward,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    //是否满足领取条件
    if( db.cumu_yb_exp < p_r->consumption )
    {
        logerror((LOG, "get_fp, not enough fp: %d,%d",db.cumu_yb_exp,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    sc_msg_def::nt_bag_change_t nt;
    //发放战历 或者 道具
    if( !( m_user.item_mgr.addnew( p_r->item3,p_r->count3,nt) ) )
    {
        ret.code = ERROR_BAG_FULL;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    //发放灵能
    m_user.item_mgr.addnew( p_r->item2,p_r->count2,nt);
    //发放碎片
    m_user.partner_mgr.add_new_chip(p_r->item1,p_r->count1,nt.chips);
    m_user.item_mgr.on_bag_change(nt);
    
    //置位
    db.set_cumu_yb_reward( (1<<pos_) | db.cumu_yb_reward);
    save_db();

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_reward_t::update_wingselected(int32_t pos_)
{
    pos_ = pos_ + 1;
    if(date_helper.cur_sec() >= m_user.db.createtime + 7 * 86400)
        return ;
    auto it_wingselected = repo_mgr.newly_reward.begin();
    while(it_wingselected != repo_mgr.newly_reward.end())
    {
        if (it_wingselected->second.value == pos_ && it_wingselected->second.id /100 == 2)
        {
            //置位
            db.set_wingactivity( (1<<(pos_)) | db.wingactivity );
            logerror((LOG, "wingactivity update: %d,pos_ =%d",m_user.db.uid,pos_));
            save_db();
            sc_msg_def::nt_wingactivity_changed_t nt;
            nt.wingactivity = db.wingactivity;
            logic.unicast(m_user.db.uid, nt);
        }
        it_wingselected++;
    }
}

void sc_reward_t::update_limit_activity_wing(int32_t pos_)
{
    pos_ = pos_ + 1;
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(3);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            auto it_wingselected = repo_mgr.lmt_reward.begin();
            while(it_wingselected != repo_mgr.lmt_reward.end())
            {
                //置位
                if ((it_wingselected->second.id - 300) > (int)db.limit_wing_reward.length())
                {
                    db.limit_wing_reward.append(1,'0');
                }

                if (it_wingselected->second.value == pos_ && it_wingselected->second.id /100 == 3)
                {
                    if ( db.limit_wing_reward[it_wingselected->second.id - 300 - 1] == '0')
                    {
                        db.limit_wing_reward[it_wingselected->second.id - 300 - 1] = '1';
                        db.set_limit_wing_reward(db.limit_wing_reward);
                    } 
                    logerror((LOG, "limit wing activity update: %d,pos_ =%d",m_user.db.uid,pos_));
                    save_db();
                    sc_msg_def::nt_wingactivity_changed_t nt;
                    nt.is_in_limit_activity = 1;
                    nt.limit_wing_reward = db.limit_wing_reward();
                    logic.unicast(m_user.db.uid, nt);
                    break;
                }
                it_wingselected++;
            } 
        }else
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            if (db.limit_wing_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                db.set_limit_wing_reward(state);
                save_db();
            }else if(db.limit_wing_reward[0] != '0')
            {
                db.limit_wing_reward[0] = '0';
                db.set_limit_wing_reward(db.limit_wing_reward);
                save_db();
            }
        }
    } 
}

void sc_reward_t::update_limit_activity_power(int32_t power_, int32_t &is_in_activity, string &str, int32_t &consume_power_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(4);
    is_in_activity = 0;
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            if(db.limit_consume_power_stamp <= lmt_event_begin || db.limit_consume_power_stamp >= lmt_event_end)
            {
                //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
                db.set_limit_consume_power(0);
                db.set_limit_consume_power_stamp(date_helper.cur_sec());
                if (db.limit_consume_power_reward.length() > 1)
                {
                    ystring_t<30> state;
                    state.append(1,'0');
                    db.set_limit_consume_power_reward(state);
                }else if(db.limit_consume_power_reward[0] != '0')
                {
                    db.limit_consume_power_reward[0] = '0';
                    db.set_limit_consume_power_reward(db.limit_consume_power_reward);
                }
                save_db();
            }

            is_in_activity = 1;
            db.set_limit_consume_power(db.limit_consume_power + power_);
            db.set_limit_consume_power_stamp(date_helper.cur_sec());
            consume_power_ = db.limit_consume_power;
            save_db();
            auto it_draw_reward = repo_mgr.lmt_reward.begin();
            while(it_draw_reward != repo_mgr.lmt_reward.end())
            {
                if (db.limit_consume_power >= it_draw_reward->second.value && it_draw_reward->second.id /100 == 4)
                {
                    //置位
                    if ((it_draw_reward->second.id - 400) > (int)db.limit_consume_power_reward.length())
                    {
                        db.limit_consume_power_reward.append(1,'0');
                    }
                    if ( db.limit_consume_power_reward[it_draw_reward->second.id - 400 - 1] == '0')
                    {
                        db.limit_consume_power_reward[it_draw_reward->second.id - 400 - 1] = '1';
                        db.set_limit_consume_power_reward(db.limit_consume_power_reward);
                    } 
                    logwarn((LOG, "limit consume power activity update: %d",m_user.db.uid));
                    save_db();
                }
                it_draw_reward++;
            } 
        }
        str = db.limit_consume_power_reward();
    }
}

void sc_reward_t::daily_draw_num(int32_t num_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(8);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            if (num_ <= 0)
                return;
            int total_draw = num_;
            if (date_helper.offday(db.daily_draw_stamp) >= 1)
            {
                db.set_daily_draw(num_);
                ystring_t<10> state;
                state.append(1,'0');
                db.set_daily_draw_reward(state);
            }
            else
            {   
                total_draw = db.daily_draw + num_; 
                db.set_daily_draw(db.daily_draw + num_);
                save_db();

                repo_def::lmt_reward_t * rp_lmt_reward = NULL;
                int index = 801;
                for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
                {
                    if (total_draw < rp_lmt_reward->value)
                        break;
                    //置位
                    if ((index - 800) > (int)db.daily_draw_reward.length())
                    {
                        db.daily_draw_reward.append(1, '1'); 
                    }
                    else
                    {
                        if (db.daily_draw_reward[index - 801] == '0')
                        {
                            db.daily_draw_reward[index - 801] = '1';     
                        }
                    }
                    db.set_daily_draw_reward(db.daily_draw_reward);
                    save_db();
                }
            }
            db.set_daily_draw_stamp(date_helper.cur_sec());

            sc_msg_def::nt_daily_draw_t nt;
            nt.totaldraw = total_draw;
            nt.daily_draw_reward = db.daily_draw_reward();
            logic.unicast(m_user.db.uid, nt);
        }
    }
}

void sc_reward_t::consume_daily_power(int32_t power_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(9);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            int total_power = power_;
            if (date_helper.offday(db.daily_consume_ap_stamp) >= 1)
            {
                db.set_daily_consume_ap(power_);
                ystring_t<10> state;
                state.append(1,'0');
                db.set_daily_consume_ap_reward(state);
                save_db();
            }
            else
            {   
                total_power = db.daily_consume_ap + power_; 
                db.set_daily_consume_ap(db.daily_consume_ap + power_);
                save_db();

                repo_def::lmt_reward_t * rp_lmt_reward = NULL;
                uint index = 901;
                for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
                {
                    if (total_power < rp_lmt_reward->value)
                        break;
                    //置位
                    if ((index - 900) > db.daily_consume_ap_reward.length())
                    {
                        db.daily_consume_ap_reward.append(1, '1'); 
                    }
                    else
                    {
                        if (db.daily_consume_ap_reward[index - 901] == '0')
                        {
                            db.daily_consume_ap_reward[index - 901] = '1';     
                        }
                    }
                    db.set_daily_consume_ap_reward(db.daily_consume_ap_reward);
                    save_db();
                }
            }
            db.set_daily_consume_ap_stamp(date_helper.cur_sec()); 
            
            sc_msg_def::nt_daily_consume_t nt;
            nt.totalpower = total_power;
            nt.daily_consume_ap_reward = db.daily_consume_ap_reward();
            logic.unicast(m_user.db.uid, nt);
        }
    }
}

void sc_reward_t::daily_melting_num(int32_t num_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(11);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            int total_melting = num_;
            if (date_helper.offday(db.daily_melting_stamp) >= 1)
            {
                db.set_daily_melting(num_);
                ystring_t<10> state;
                state.append(1,'0');
                db.set_daily_melting_reward(state);
                save_db();
            }
            else
            {   
                total_melting = db.daily_melting + num_; 
                db.set_daily_melting(db.daily_melting + num_);
                save_db();

                repo_def::lmt_reward_t * rp_lmt_reward = NULL;
                uint index = 1101;
                for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
                {
                    if (total_melting < rp_lmt_reward->value)
                        break;
                    //置位
                    if ((index - 1100) > db.daily_melting_reward.length())
                    {
                        db.daily_melting_reward.append(1, '1'); 
                    }
                    else
                    {
                        if (db.daily_melting_reward[index - 1101] == '0')
                        {
                            db.daily_melting_reward[index - 1101] = '1';     
                        }
                    }
                    db.set_daily_melting_reward(db.daily_melting_reward);
                    save_db();
                }
            }
            db.set_daily_melting_stamp(date_helper.cur_sec()); 
            
            sc_msg_def::nt_melting_t nt;
            nt.type = 1;
            nt.totalmelting = total_melting;
            nt.melting_reward = db.daily_melting_reward();
            logic.unicast(m_user.db.uid, nt);
        }
    }
}

void sc_reward_t::daily_talent_num(int32_t num_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(13);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            int total_talent = num_;
            if (date_helper.offday(db.daily_talent_stamp) >= 1)
            {
                db.set_daily_talent(num_);
                ystring_t<10> state;
                state.append(1,'0');
                db.set_daily_talent_reward(state);
                save_db();
            }
            else
            {   
                total_talent = db.daily_talent + num_; 
                db.set_daily_talent(db.daily_talent + num_);
                save_db();

                repo_def::lmt_reward_t * rp_lmt_reward = NULL;
                uint32_t index = 1301;
                for (; (rp_lmt_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
                {
                    if (total_talent < rp_lmt_reward->value)
                        break;
                    //置位
                    if ((index - 1300) > db.daily_talent_reward.length())
                    {
                        db.daily_talent_reward.append(1, '1'); 
                    }
                    else
                    {
                        if (db.daily_talent_reward[index - 1301] == '0')
                        {
                            db.daily_talent_reward[index - 1301] = '1';     
                        }
                    }
                    db.set_daily_talent_reward(db.daily_talent_reward);
                    save_db();
                }
            }
            db.set_daily_talent_stamp(date_helper.cur_sec()); 
            
            sc_msg_def::nt_talent_t nt;
            nt.totaltalent = total_talent;
            nt.talent_reward = db.daily_talent_reward();
            nt.type = 1;
            logic.unicast(m_user.db.uid, nt);
        }
    }
}

int32_t sc_reward_t::update_wingactivityreward(int32_t index_)
{
    auto wingactivity_reward = repo_mgr.newly_reward.get(index_);
    if(wingactivity_reward != NULL)
    {
        if((db.wingactivityreward>>(wingactivity_reward->value) & 1) == 0)
        {
            db.set_wingactivityreward((1<<(wingactivity_reward->value)) | db.wingactivityreward);
            save_db();
            return SUCCESS;
        }
    }
    return FAILED;
}

void sc_reward_t::get_fp_reward(int32_t pos_)
{
    repo_def::fp_reward_t *p_r = repo_mgr.fp_reward.get(pos_);
    if( NULL == p_r )
        return;
    sc_msg_def::ret_fp_reward_t ret;
    ret.pos = pos_;
    auto f = [&](int item_, int num_){
        if (num_ <= 0)
            return ERROR_SC_ILLEGLE_REQ;
        sc_msg_def::nt_bag_change_t nt;
        if (item_ / 10000 == 3)
            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
        else if (item_ == 10001)
        {
            m_user.on_money_change(num_);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(item_, num_, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_EXCEPTION;
            }
        }
        m_user.item_mgr.on_bag_change(nt);
        return SUCCESS;
    };

    if( ((db.fpreward>>pos_) & 1) == 1 )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    m_user.get_total_fp();

    if( m_user.db.fp < p_r->fp )
    {
        logerror((LOG, "get_fp, not enough fp: %d,%d",m_user.db.fp,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    f(p_r->item1, p_r->count1);
    f(p_r->item2, p_r->count2);
    f(p_r->item3, p_r->count3);
    f(p_r->item4, p_r->count4);
    //置位
    db.set_fpreward( (1<<pos_) | db.fpreward );
    save_db();

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_reward_t::update_daily_pay()
{
    if(db.daily_pay_stamp < date_helper.cur_0_stmp())
    {
        db.set_daily_pay_reward(0);
        db.set_daily_pay(0);
        db.set_daily_pay_stamp(date_helper.cur_sec());
    }
}

void sc_reward_t::update_daily_consume_power()
{
    if(db.daily_consume_ap_stamp < date_helper.cur_0_stmp())
    {
        ystring_t<10> state;
        state.append(1,'0');
        db.set_daily_consume_ap_reward(state);
        db.set_daily_consume_ap(0);
        db.set_daily_consume_ap_stamp(date_helper.cur_sec());
    }
}

void sc_reward_t::update_daily_draw()
{
    if(db.daily_draw_stamp < date_helper.cur_0_stmp())
    {
        ystring_t<10> state;
        state.append(1,'0');
        db.set_daily_draw_reward(state);
        db.set_daily_draw(0);
        db.set_daily_draw_stamp(date_helper.cur_sec());
    }
}

void sc_reward_t::update_daily_melting()
{
    if(db.daily_melting_stamp < date_helper.cur_0_stmp())
    {
        ystring_t<10> state;
        state.append(1,'0');
        db.set_daily_melting_reward(state);
        db.set_daily_melting(0);
        db.set_daily_melting_stamp(date_helper.cur_sec());
    }
}

void sc_reward_t::update_daily_talent()
{
    if(db.daily_talent_stamp < date_helper.cur_0_stmp())
    {
        ystring_t<10> state;
        state.append(1,'0');
        db.set_daily_talent_reward(state);
        db.set_daily_talent(0);
        db.set_daily_talent_stamp(date_helper.cur_sec());
    }
}

int sc_reward_t::get_limit_reward(int32_t pos_)
{
    logwarn((LOG, "get lmt_limit_reward pos: %d", pos_));
    //判断是否在活动时间内
    sc_msg_def::jpk_lmt_event_t jpk;
    sc_msg_def::ret_daily_pay_reward_t ret;
    ret.pos = pos_;
    repo_def::lmt_reward_t * rp_lmt_reward = NULL;
    //获得奖励的类型
    int flag = pos_/100;
    int index = pos_ - flag*100; 
    get_activity_date(jpk, flag);

    if(date_helper.cur_sec() < jpk.lmt_event_begin || date_helper.cur_sec() > jpk.lmt_event_end)
    {

        if((flag == 16 || flag == 18) && isInOpenTime())
        {

        }else{

        ret.code = ERROR_QUEST_OVERDUED;
        logic.unicast(m_user.db.uid, ret);
        return FAILED;
        }
    }
    if((rp_lmt_reward = repo_mgr.lmt_reward.get(pos_))!=NULL)
    {
        auto f = [&](int item_, int num_)
        {

            logerror((LOG, "limit reward log, get reward, itemnum: %d, num = %d",item_,num_));
            if (num_ <= 0)
                return ERROR_SC_ILLEGLE_REQ;
            sc_msg_def::nt_bag_change_t nt;
            if (item_ / 10000 == 3)
                m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
            else if (item_ == 10001)
            {
                m_user.on_money_change(num_);
                m_user.save_db();
            }
            else
            {
                cout << "item_: " << item_ << " num: " << num_ << endl;
                m_user.item_mgr.addnew(item_, num_, nt);
                bool is_empty = true;
                if (!nt.items.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_wings.empty())
                {
                    is_empty = false;
                }
                else if(!nt.add_pet.empty())
                {
                    is_empty = false;
                }
                if (is_empty)
                {                                 
                    logerror((LOG, "con reward items error!"));
                    return ERROR_SC_ILLEGLE_REQ;;
                }
            }
            m_user.item_mgr.on_bag_change(nt);
            return SUCCESS;
        };
        
        //判断是否符合领取条件
        switch( flag  )
        {
            case 2:         //钻石十连抽
            {
                if (db.limit_draw_ten_reward[index - 1] == '1')
                {
                    db.limit_draw_ten_reward[index - 1] = '2'; 
                    db.set_limit_draw_ten_reward(db.limit_draw_ten_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 3:         //限时翅膀
            {
                if (db.limit_wing_reward[index - 1] == '1')
                {
                    db.limit_wing_reward[index - 1] = '2'; 
                    db.set_limit_wing_reward(db.limit_wing_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 4:         //消耗体力
            {
                if (db.limit_consume_power_reward[index - 1] == '1')
                {
                    db.limit_consume_power_reward[index - 1] = '2'; 
                    db.set_limit_consume_power_reward(db.limit_consume_power_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 7:         //累计充值
            {
                if (db.limit_recharge_reward[index - 1] == '1')
                {
                    db.limit_recharge_reward[index - 1] = '2'; 
                    db.set_limit_recharge_reward(db.limit_recharge_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 8:         //每日抽卡
            {
                if (db.daily_draw_reward[index - 1] == '1')
                {
                    db.daily_draw_reward[index - 1] = '2'; 
                    db.set_daily_draw_reward(db.daily_draw_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 9:         //每日体力
            {
                if (db.daily_consume_ap_reward[index - 1] == '1')
                {
                    db.daily_consume_ap_reward[index - 1] = '2'; 
                    db.set_daily_consume_ap_reward(db.daily_consume_ap_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 11:         //每日熔炼
            {
                if (db.daily_melting_reward[index - 1] == '1')
                {
                    db.daily_melting_reward[index - 1] = '2'; 
                    db.set_daily_melting_reward(db.daily_melting_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 12:         //累计熔炼
            {
                if (db.limit_melting_reward[index - 1] == '1')
                {
                    db.limit_melting_reward[index - 1] = '2'; 
                    db.set_limit_melting_reward(db.limit_melting_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 13:         //每日天赋
            {
                if (db.daily_talent_reward[index - 1] == '1')
                {
                    db.daily_talent_reward[index - 1] = '2'; 
                    db.set_daily_talent_reward(db.daily_talent_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 14:         //累计天赋
            {
                if (db.limit_talent_reward[index - 1] == '1')
                {
                    db.limit_talent_reward[index - 1] = '2'; 
                    db.set_limit_talent_reward(db.limit_talent_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 15:         //天天充值
            {
                if (db_ext.limit_seven_stage[index - 1] == '1')
                {
                    db_ext.limit_seven_stage[index - 1] = '2'; 
                    db_ext.set_limit_seven_stage(db_ext.limit_seven_stage);
                    save_db_ext();
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 16:         //累计充值
            {
                if (db.limit_recharge_reward[index - 1] == '1')
                {
                    db.limit_recharge_reward[index - 1] = '2'; 
                    db.set_limit_recharge_reward(db.limit_recharge_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 17:         //单日充值(普通)
            {
                if (db.limit_single_reward[index - 1] == '1')
                {
                    db.limit_single_reward[index - 1] = '2'; 
                    db.set_limit_single_reward(db.limit_single_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 18:         //单日充值(开服)
            {
                if (db.limit_single_reward[index - 1] == '1')
                {
                    db.limit_single_reward[index - 1] = '2'; 
                    db.set_limit_single_reward(db.limit_single_reward);
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            } 
            break;
            case 19:    //钻石消费
            {
                if(db_ext.openybreward[index - 1] == '1')
                {
                    db_ext.openybreward[index - 1] = '2';
                    db_ext.set_openybreward(db_ext.openybreward);
                    save_db_ext();
                }
                else
                {
                    ret.code = ERROR_SC_ILLEGLE_REQ;
                    logic.unicast(m_user.db.uid, ret);
                    return FAILED;
                }
            }
            break;
            default: return FAILED;
        } 
         
        uint size = rp_lmt_reward->reward.size();
        for (size_t i = 1; i < size; ++i)
        {

            f(rp_lmt_reward->reward[i][0], rp_lmt_reward->reward[i][1]);
        }
        ret.code = SUCCESS;
        logic.unicast(m_user.db.uid, ret);
    }
    save_db();
    return SUCCESS;
}

void sc_reward_t::get_daily_pay_reward(int32_t pos_)
{
    auto p_r = repo_mgr.daily_pay.get(pos_);
    if( NULL == p_r )
        return;

    sc_msg_def::ret_daily_pay_reward_t ret;
    ret.pos = pos_;

    uint32_t ts_begin_day = 0;
    uint32_t ts_after_day = 0;
    //判断活动是否过期
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(1);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        ts_begin_day = str2stamp(rp->start_time); 
        ts_after_day = str2stamp(rp->end_time);
    }
    
    if(date_helper.cur_sec() < ts_begin_day || date_helper.cur_sec() > ts_after_day)
    {
        ret.code = ERROR_QUEST_OVERDUED;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    if(db.daily_pay_stamp < date_helper.cur_0_stmp())
    {  
        logerror((LOG, "daily_pay_stamp, not correct: %d,%d",db.cumu_yb_reward,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
   
    //是否已经领过
    if( (db.daily_pay_reward & (1<<pos_)) == 1 )
    {
        logerror((LOG, "get_daily_pay_reward, not prepared: %d,%d",db.cumu_yb_reward,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    
    //是否满足领取条件
    if( db.daily_pay < p_r->rmb)
    {
        logerror((LOG, "get_daily_pay_reward, not enough rmb: %d,%d",db.daily_pay_reward,pos_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    sc_msg_def::nt_bag_change_t nt;
    for(size_t i=1; i<p_r->item.size(); i++)
    {
        if( !( m_user.item_mgr.addnew(p_r->item[i][0],p_r->item[i][1],nt) ) )
        {
            logerror((LOG, "get_daily_pay_reward_faile: %d,%d",db.daily_pay_reward,pos_));
            ret.code = ERROR_BAG_FULL;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
        logerror((LOG, "get_daily_pay_reward: %d,%d",db.daily_pay_reward,pos_));
    }
    m_user.item_mgr.on_bag_change(nt);
    
    //置位
    db.set_daily_pay_reward( (1<<pos_) | db.daily_pay_reward);
    save_db();

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_reward_t::update_single_pay()
{
    if(db.limit_single_stamp < date_helper.cur_0_stmp())
    {
        db.set_limit_single_recharge(0);
        db.set_limit_single_stamp(date_helper.cur_sec());
        if (db.limit_single_reward.length() > 1)
        {
                ystring_t<10> state;
                state.append(1,'0');
                db.set_limit_single_reward(state);
        }else if(db.limit_single_reward[0] != '0')
        {
            db.limit_single_reward[0] = '0';
            db.set_limit_single_reward(db.limit_single_reward);
        }
        save_db();

    }
}

void sc_reward_t::on_twoprecord_done(int op_)
{
    if ((m_user.db.twoprecord & (1<<op_)) == 0 )
    {
        m_user.db.set_twoprecord(m_user.db.twoprecord | (1<<op_));
        switch(op_)
        {
        case 1:
        case 2:
        case 3:
            m_user.on_freeyb_change(100);
        break;
        }
        m_user.save_db();
    }
}
void sc_reward_t::given_vip_package(int viplevel_)
{
    //屏蔽
    return;
    //printf("%d,%d,%d,%d\n", viplevel_, m_user.db.viplevel, db.vip_package_stamp,date_helper.offday(db.vip_package_stamp));
    if (viplevel_ <= m_user.db.viplevel && date_helper.offday(db.vip_package_stamp)<1)
        return;

    db.set_vip_package_stamp(date_helper.cur_sec());

    auto rp_vip_package = repo_mgr.vip_package.get(viplevel_);
    if (rp_vip_package == NULL)
        return;

    sc_msg_def::nt_bag_change_t nt;
    auto f = [&](int item_, int num_){
        if (num_ <= 0)
            return;
        sc_msg_def::jpk_item_t itm;
        itm.itid=0;
        itm.resid=item_;
        itm.num=num_;
        nt.items.push_back(itm);
    };

    f(rp_vip_package->item1, rp_vip_package->count1);
    f(rp_vip_package->item2, rp_vip_package->count2);
    f(rp_vip_package->item3, rp_vip_package->count3);
    f(rp_vip_package->item4, rp_vip_package->count4);

    string msg = mailinfo.new_mail(mail_vip_package,viplevel_); 
    if (!msg.empty())
    {
        auto rp_gmail = mailinfo.get_repo(mail_vip_package);
        if (rp_gmail != NULL)
            m_user.gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
    }

    save_db();
}

void sc_reward_t::update_openyb_info()
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(19);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    
    uint32_t lmt_event_begin = str2stamp(rp->start_time);
    uint32_t lmt_event_end = str2stamp(rp->end_time);

    if(db_ext.openybstamp <= lmt_event_begin || db_ext.openybstamp >= lmt_event_end)
    {    
        logwarn((LOG, "uid = %d, openybstamp = %d, lmt_event_time = %d, lmt_event_end = %d", m_user.db.uid, db_ext.openybstamp, lmt_event_begin, lmt_event_end));
        db_ext.set_openybtotal(0);
        db_ext.set_openybstamp(date_helper.cur_sec());
        if (db_ext.openybreward.length() > 1)
        {
            ystring_t<30> state;
            state.append(1,'0');
            db_ext.set_openybreward(state);
        }else if(db_ext.openybreward[0] != '0')
        {
            db_ext.openybreward[0] = '0';
            db_ext.set_openybreward(db_ext.openybreward);
        }
        save_db_ext();

    }
}



void sc_reward_t::update_openybtotal(int32_t yb_)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(19);
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    
    uint32_t lmt_event_begin = str2stamp(rp->start_time);
    uint32_t lmt_event_end = str2stamp(rp->end_time);

    if(db_ext.openybstamp <= lmt_event_begin || db_ext.openybstamp >= lmt_event_end)
    {    
        db_ext.openybstamp = 0;
        db_ext.set_openybstamp(0);
        save_db_ext();
    }
        
    if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
    {
        int total_yb = db_ext.openybtotal + yb_;
        repo_def::lmt_reward_t * rp_openyb_reward = NULL;
        int index = 1901;
        for (; (rp_openyb_reward = repo_mgr.lmt_reward.get(index)) != NULL; index++)
        {
            if (total_yb < rp_openyb_reward->value)
                break;
            //置位
            if ((index - 1900) > (int)db_ext.openybreward.length())
            {
                db_ext.openybreward.append(1, '1'); 
            }
            else
            {
                if (db_ext.openybreward[index - 1901] == '0')
                {
                    db_ext.openybreward[index - 1901] = '1';     
                }
            }
            db_ext.set_openybreward(db_ext.openybreward());
            save_db_ext();
        }

        db_ext.openybtotal = db_ext.openybtotal + yb_;
        db_ext.openybstamp = date_helper.cur_sec();
        db_ext.set_openybtotal(db_ext.openybtotal); 
        db_ext.set_openybstamp(date_helper.cur_sec());
        save_db_ext();
    
        sc_msg_def::nt_openyb_change_t nt;
        nt.totalyb = total_yb;
        nt.openybreward = db_ext.openybreward();
        logic.unicast(m_user.db.uid, nt); 
    }
}


int sc_reward_t::get_openyb_reward(int32_t pos_)
{
    logwarn((LOG, "get lmt_openyb_reward pos: %d", pos_));
    //判断是否在活动时间内
    if(isInOpenTime())
    {
        sc_msg_def::ret_openyb_reward_t ret;
        ret.pos = pos_;
        repo_def::newly_reward_t * rp_newly_reward = NULL;
        //获得奖励的类型
        int index = pos_%100; 

        if((rp_newly_reward = repo_mgr.newly_reward.get(pos_))!=NULL)
        {
            auto f = [&](int item_, int num_)
            {

                logerror((LOG, "openyb reward log, get reward, itemnum: %d, num = %d",item_,num_));
                if (num_ <= 0)
                    return ERROR_SC_ILLEGLE_REQ;
                sc_msg_def::nt_bag_change_t nt;
                if (item_ / 10000 == 3)
                    m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
                else if (item_ == 10001)
                {
                    m_user.on_money_change(num_);
                    m_user.save_db();
                }
                else
                {
                    m_user.item_mgr.addnew(item_, num_, nt);
                    bool is_empty = true;
                    if (!nt.items.empty())
                    {
                        is_empty = false;
                    }
                    else if(!nt.add_wings.empty())
                    {
                        is_empty = false;
                    }
                    if (is_empty)
                    {                                 
                        logerror((LOG, "openyb con reward items error!"));
                        return ERROR_SC_ILLEGLE_REQ;;
                    }
                }
                m_user.item_mgr.on_bag_change(nt);
                return SUCCESS;
            };
        
            //判断是否符合领取条件
            if (db_ext.openybreward[index - 1] == '1')
            {
                    db_ext.openybreward[index - 1] = '2'; 
                    db_ext.set_openybreward(db_ext.openybreward);
            }
            else
            {
                ret.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, ret);
                return FAILED;
            }
            
            uint size = rp_newly_reward->reward.size();
            for (size_t i = 1; i < size; ++i)
            {

                f(rp_newly_reward->reward[i][0], rp_newly_reward->reward[i][1]);
            }
            ret.code = SUCCESS;
            logic.unicast(m_user.db.uid, ret);
        }
        save_db();
        return SUCCESS;
    }
    return FAILED;
}


bool sc_reward_t::isinOpenTaskTime()
{
    auto open_time = m_user.db.createtime;
    auto cur_time = date_helper.cur_sec();
    bool ret = false;

    if((cur_time - open_time) < (86400 * 7))
        ret = true;
    else 
        ret = false;
    return ret;    
}

void sc_reward_t::get_open_task_info()
{
    if(isinOpenTaskTime())
    {
        if(db_ext.opentask_level == 0)
            db_ext.opentask_level = 1101;
        db_ext.set_opentask_level(db_ext.opentask_level); 
        sc_msg_def::ret_opentask_info_t ret;
        ret.opentasklv = db_ext.opentask_level;
        ret.opentask_step1 = db_ext.opentask_stage_one;
        ret.opentask_step2 = db_ext.opentask_stage_two;
        ret.opentask_step3 = db_ext.opentask_stage_three;
        ret.opentask_reward = db_ext.opentask_reward;
        logic.unicast(m_user.db.uid, ret);
    }
    else
    {
        sc_msg_def::ret_opentask_info_t ret;
        ret.opentasklv = -1;
        ret.opentask_step1 = 0;
        ret.opentask_step2 = 0;
        ret.opentask_step3 = 0;
        ret.opentask_reward = 0;
        logic.unicast(m_user.db.uid, ret);

    }
}

void sc_reward_t::update_opentask(int32_t index_)
{
    bool ispass = true;
    //不在活动期间内
    if(!isinOpenTaskTime())
        return;

    auto rp = repo_mgr.open_task.get(db_ext.opentask_level);
    if(rp == NULL)
        return ;
    if(index_ == rp->type1)
    {
        if(db_ext.opentask_stage_one < rp->value1)
        {
            db_ext.opentask_stage_one = db_ext.opentask_stage_one + 1;
            db_ext.set_opentask_stage_one(db_ext.opentask_stage_one);
            save_db_ext();    
        }
    }

    if(index_ == rp->type2)
    {
        if(db_ext.opentask_stage_two < rp->value2)
        {
            db_ext.opentask_stage_two = db_ext.opentask_stage_two + 1;
            db_ext.set_opentask_stage_two(db_ext.opentask_stage_two);
            save_db_ext();
        }
    }

    if(index_ == rp->type3)
    {
        if(db_ext.opentask_stage_three < rp->value3)
        {
            db_ext.opentask_stage_three = db_ext.opentask_stage_three + 1;
            db_ext.set_opentask_stage_three(db_ext.opentask_stage_three);
            save_db_ext();
        }
    }
    if(db_ext.opentask_stage_one < rp->value1 || db_ext.opentask_stage_two < rp->value2 || db_ext.opentask_stage_three < rp->value3)
        ispass = false;
    if(ispass && db_ext.opentask_reward == 0)
    {
        db_ext.opentask_reward = 1;
        db_ext.set_opentask_reward(1);
    }
    

    sc_msg_def::nt_opentask_t nt;
    nt.opentask_stage_one = db_ext.opentask_stage_one;
    nt.opentask_stage_two = db_ext.opentask_stage_two;
    nt.opentask_stage_three = db_ext.opentask_stage_three;
    nt.opentask_reward = db_ext.opentask_reward;
    nt.opentask_level = db_ext.opentask_level;
    logic.unicast(m_user.db.uid, nt);
}

void sc_reward_t::get_opentask_reward()
{
    sc_msg_def::ret_opentask_reward_t ret;
    bool is_canget = true;
    //不在活动期间内
    if(!isinOpenTaskTime())
    {
        ret.code  = ERROR_OPENTASK_TIME; 
        is_canget = false;
    }
    //判断任务id
    auto rp = repo_mgr.open_task.get(db_ext.opentask_level);
    if(rp == NULL)
    {
        is_canget = false;
        ret.code = ERROR_OPENTASK_INFO;
    }
    //判断领取条件
    if(db_ext.opentask_stage_one < rp->value1 || db_ext.opentask_stage_two < rp->value2 || db_ext.opentask_stage_three < rp->value3)
    {
        is_canget = false;
        ret.code = ERROR_OPENTASK_LIMIT;
    }
    auto f = [&](int item_, int num_){
        if (num_ <= 0)
            return ERROR_SC_ILLEGLE_REQ;
        sc_msg_def::nt_bag_change_t nt;
        if (item_ / 10000 == 3)
            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
        else if (item_ == 10001)
        {
            m_user.on_money_change(num_);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(item_, num_, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_EXCEPTION;
            }
        }
        m_user.item_mgr.on_bag_change(nt);
        return SUCCESS;
    };
    
    if(is_canget)
    { 
        for(size_t i = 1;i<rp->reward.size(); i++)
            f(rp->reward[i][0],rp->reward[i][1]);

        //设置任务状态
        db_ext.opentask_level = db_ext.opentask_level + 1;
        db_ext.set_opentask_level(db_ext.opentask_level);

        db_ext.opentask_stage_one = 0;
        db_ext.opentask_stage_two = 0;
        db_ext.opentask_stage_three = 0;
        db_ext.opentask_reward = 0;
        db_ext.set_opentask_stage_one(0);
        db_ext.set_opentask_stage_two(0);
        db_ext.set_opentask_stage_three(0);
        db_ext.set_opentask_reward(0);
        save_db_ext();

        ret.code = SUCCESS;
    }
    ret.opentaskid = db_ext.opentask_level;
    logic.unicast(m_user.db.uid, ret);

}



//限时7日充值

string sc_reward_t::update_limit_sevenpay()
{
    sc_msg_def::jpk_lmt_event_t lmt_seven_pay;
    get_lmt_date(lmt_seven_pay, 15);

    uint32_t ctime_stamp = server.db.ctime;
    uint32_t cur_timestamp = date_helper.cur_sec();
    int32_t seven_count = db_ext.limit_seven_count;

    if (date_helper.cur_sec() >= lmt_seven_pay.lmt_event_begin && date_helper.cur_sec() <= lmt_seven_pay.lmt_event_end && (lmt_seven_pay.lmt_event_begin - ctime_stamp > 7 * 86400))
    {   
        //判断上次支付是否已经超过了一天，如果没有的话不会执行更新相关的操作。
        if (db_ext.limit_seven_stamp > 0  && date_helper.offday(db_ext.limit_seven_stamp) < 1){
             
             return db_ext.limit_seven_stage();
             
        }
         repo_def::lmt_reward_t * rp_seven_reward = NULL;
         db_ext.limit_seven_count = db_ext.limit_seven_count + 1;
         db_ext.set_limit_seven_count(db_ext.limit_seven_count);
         //获取当前表的数据
         int32_t i = 1501;
         if(db_ext.limit_seven_stage.length()==1 && db_ext.limit_seven_stage[0] == '0'){
             i = 1501;
         }else
             i = 1500 + db_ext.limit_seven_stage.length() + 1;
        
         for(;repo_mgr.lmt_reward.get(i) != NULL ;i++)
         {
             rp_seven_reward = repo_mgr.lmt_reward.get(i);
             if (db_ext.limit_seven_count >= rp_seven_reward->value)
             {
                 if((i-db_ext.limit_seven_stage.length()) > 1500 && db_ext.limit_seven_stage[i-1501] != '2')
                 {
                      db_ext.limit_seven_stage.append(i-1500-db_ext.limit_seven_stage.length(),'1');
                 }
                 if(db_ext.limit_seven_stage[i-1501] != '2')
                    db_ext.limit_seven_stage[i-1501] = '1';
                 db_ext.set_limit_seven_stage(db_ext.limit_seven_stage);
                 db_ext.set_limit_seven_stamp(cur_timestamp);
                 sc_msg_def::nt_limit_sevenpay_changed_t nt;
                 nt.stage = db_ext.limit_seven_stage();
                 logic.unicast(m_user.db.uid, nt);
             }else{
                 db_ext.set_limit_seven_stamp(cur_timestamp);
             }
         }

    }
    else
    {
        ystring_t<30> state;
        state.append(1,'0');
        db_ext.set_limit_seven_stage(state);
        db_ext.set_limit_seven_count(0);
        db_ext.set_limit_seven_stamp(0);
    }
    save_db_ext();
    return db_ext.limit_seven_stage();
}

void sc_reward_t::update_sevenpay_info()
{
    sc_msg_def::jpk_lmt_event_t lmt_seven_pay;
    get_lmt_date(lmt_seven_pay, 15);

    uint32_t ctime_stamp = server.db.ctime;
    uint32_t cur_timestamp = date_helper.cur_sec();
    if (db_ext.limit_seven_stamp < lmt_seven_pay.lmt_event_begin || db_ext.limit_seven_stamp > lmt_seven_pay.lmt_event_end || (lmt_seven_pay.lmt_event_begin - ctime_stamp < 7 * 86400))
    {
        ystring_t<30> state;
        state.append(1,'0');
        db_ext.set_limit_seven_stage(state);
        db_ext.set_limit_seven_count(0);
        db_ext.set_limit_seven_stamp(0);
        save_db_ext();
    } 
}

void sc_reward_t::update_vip_exp()
{
    int32_t day = date_helper.offday(0, date_helper.cur_sec())-date_helper.offday(0, db_ext.vip_stamp);
    if(day >= 2)
    {
        db_ext.vip_days = 1;
        db_ext.set_vip_days(1);
        db_ext.vip_stamp = date_helper.cur_sec();
        db_ext.set_vip_stamp(date_helper.cur_sec());
        m_user.vip.on_exp_change(10);
        save_db_ext();
    }
    else if (day == 1)
    {
        if(db_ext.vip_days == 1)
            m_user.vip.on_exp_change(20);
        else if(db_ext.vip_days == 2)
            m_user.vip.on_exp_change(40);
        else if(db_ext.vip_days == 3)
            m_user.vip.on_exp_change(60);
        else if(db_ext.vip_days >= 4)
            m_user.vip.on_exp_change(100);
        db_ext.vip_days = db_ext.vip_days + 1;
        db_ext.set_vip_days(db_ext.vip_days);
        db_ext.vip_stamp = date_helper.cur_sec();
        db_ext.set_vip_stamp(date_helper.cur_sec());
        save_db_ext();
    }
    sc_msg_def::ret_vip_exp_t ret;
    ret.vip_days = db_ext.vip_days;
    ret.vip_stamp = db_ext.vip_stamp;
    
    logic.unicast(m_user.db.uid, ret);
}

int32_t sc_reward_t::get_vip_days()
{
    return db_ext.vip_days;
}

int32_t sc_reward_t::get_vip_stamp()
{
    return db_ext.vip_stamp;
}
