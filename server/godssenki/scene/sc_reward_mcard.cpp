#include "sc_reward_mcard.h"
#include "sc_reward.h"
#include "sc_mailinfo.h"
#include "sc_logic.h"
#include "config.h"
#include "date_helper.h"
#include "sc_logic.h"
#include "sc_cache.h"
#include "msg_def.h"
#include "db_ext.h"
#include "config.h"

#include <atomic>
#include <unistd.h>

#define LOG "SC_REWARD_MCARD"
#define DAY_TIME 24 * 3600

sc_reward_mcard_t::sc_reward_mcard_t():m_is_send(true)
{

}

sql_result_t sc_reward_mcard_t::load_db()
{
    logwarn((LOG, "load users month card ..."));

    char sql[256];
    sql_result_t mcards;

    string str_hosts;
    for (int32_t host : m_hosts)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    sprintf(sql, "select Reward.uid, mcardtm, mcardn, mcardbuytm from Reward inner join UserInfo on Reward.uid = UserInfo.uid  where hostnum in (%s) and mcardn > 0 and mcardbuytm > 0", str_hosts.c_str());
    db_service.sync_select(sql, mcards);
    return mcards;
}

void sc_reward_mcard_t::update_reward()
{
    if(date_helper.cur_sec() <= date_helper.cur_0_stmp() + 60)
    {
        m_is_send = false;
        return;
    }
    if(m_is_send)
        return;
    m_is_send = true;
    int uid = 0;
    int mcardtm = 0;//月卡领取时间戳
    int mcardn = 0;//月卡剩余领取次数
    int mcardbuytm = 0;//月卡购买时间戳

    sql_result_t res = load_db();
    sc_gmail_mgr_t::begin_offmail();
    
    char sql_prefix[256];
    sprintf(sql_prefix, "update Reward set mcardn = mcardn - 1, mcardtm = %d where uid in (", date_helper.cur_sec());
    string update_sql = string(sql_prefix);
    stringstream ss;
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            continue;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int)std::atoi(row_[0].c_str());
        mcardtm=(int)std::atoi(row_[1].c_str());
        mcardn=(int)std::atoi(row_[2].c_str());
        mcardbuytm=(int)std::atoi(row_[3].c_str());

        if((mcardtm - date_helper.cur_0_stmp() >= 0) && (mcardtm - date_helper.cur_0_stmp() <= DAY_TIME))//今日已发过奖励 
            continue;

       // if((int)config.serid == (int)sp_user->db.hostnum)
        {
    /*        sql_result_t res1;
            if(0==db_Reward_t::sync_select_reward(uid, res1))
            {
              db.init(*res1.get_row_at(0));
            }*/
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item;
            item.itid = 0;
            item.resid = 10003;
            item.num = 120;//月卡每天领取120钻
            nt.items.push_back(item);

            auto rp_gmail = mailinfo.get_repo(mail_mcard_daily);
            if (rp_gmail != NULL)
            {
    //            db.set_mcardn(mcardn-1);
    //            db.set_mcardtm(date_helper.cur_sec());
                db_save();
                string msg = mailinfo.new_mail(mail_mcard_daily, "120");
                sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
            }
        }
        ss << uid;
        ss << ",";
    }
    update_sql +=  ss.str();
    update_sql.replace(update_sql.size()-1,1,")");
    logwarn((LOG, update_sql.c_str()));
    db_service.sync_execute(update_sql);
    sc_gmail_mgr_t::do_offmail();
}

void sc_reward_mcard_t::db_save()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

