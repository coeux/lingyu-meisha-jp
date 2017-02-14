#include "sc_pay.h"
#include "sc_logic.h"
#include "sc_server.h"
#include "date_helper.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_statics.h"
#include "db_helper.h"

#define BOOST_MUTEX
#define BASEID 10101
#define MOONCARDID 10109
#define MCARD_EVENT_N 6
#define MCARD_EVENT_REWARD_N 6

#include "id_assign.h"

#define LOG "SC_PAY"

bool is_first_pay(int data, int pos)
{
    int i = 6;
    bool ret = true;
    while(i>=pos)
    {
        ret = (data/pow(2,i)) < 1;
        data = data % (int)pow(2,i);
        i = i - 1;
    }
    return ret;
}

uint32_t str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

int sc_pay_t::req_pay(sp_user_t sp_user_, int id_, const string& uin_, const string& domain_, const string& appid_)
{
    int cristal;
    int first_reward;
    int rmb;

    if(domain_ != "appstore_" && domain_ != "jituo1" && domain_ != "jituo2" && domain_ != "xuegao1" && domain_ != "xuegao2" && domain_ != "soga" && domain_ != "zhanji"){
        repo_def::pay_t* rp_pay = repo_mgr.pay.get(id_);
        cristal = rp_pay->cristal;
        first_reward = rp_pay->first_reward;
        rmb = rp_pay->rmb;
        if (rp_pay == NULL)
        {
            logerror((LOG, "req_pay, no repo id:%d", id_));
            return 0;
        }
    }else{
        repo_def::apppay_t* rp_pay = repo_mgr.apppay.get(id_);
        cristal = rp_pay->cristal;
        first_reward = rp_pay->first_reward;
        rmb = rp_pay->rmb;
        if (rp_pay == NULL)
        {
            logerror((LOG, "req_pay, no repo id:%d", id_));
            return 0;
        }
    }


    db_Pay_t db;

    db.serid = dbid_assign.new_dbid("orderid");
    if (db.serid == 0)
    {
        logerror((LOG, "new orderid failed!"));
        return 0;
    }

    db.sid = server.db.serid;
    db.uid = sp_user_->db.uid;
    db.appid = appid_;
    db.domain = domain_;
    db.uin = uin_;
    db.state = 1;
    db.goodsid = id_;
    db.goodnum = 1;
    db.cristal = cristal;
    db.reward_cristal = 0;
    int pos = id_ - BASEID;
    if (id_ != MOONCARDID && is_first_pay(sp_user_->db.firstpay, pos))
    {
        //非月卡有首冲奖励
        db.reward_cristal += first_reward;
    }
    db.repo_rmb = rmb;
    db.pay_rmb = 0;

    dbgl_service.async_do((uint64_t)db.uid, [](db_Pay_t& db_){
        int code = SUCCESS;
        if (db_.insert())
        {
            code = ERROR_SC_EXCEPTION; 
        }

        sc_service.async_do([](int code, uint32_t uid_, uint32_t serid_){
            sc_msg_def::ret_buy_yb_t ret;
            ret.code = code;
            ret.serid = serid_; 
            logic.unicast(uid_, ret);
        }, code, db_.uid, db_.serid);
    }, db);

    return db.serid;
}
int sc_pay_t::on_payed(sp_user_t sp_user_, uint32_t serid_)
{
    dbgl_service.async_do((uint64_t)sp_user_->db.uid, [](sp_user_t sp_user_,uint32_t serid_){
        sql_result_t res;
        if (db_Pay_ext_t::select_serid(serid_, res))
        {
            logerror((LOG, "on_payed but no serid:%u", serid_));
            return;
        }
        boost::shared_ptr<db_Pay_ext_t> sp_db(new db_Pay_ext_t);
        sp_db->init(*res.get_row_at(0));
        //已经支付完成，则给予水晶
        if (sp_db->state == 2)
        {
            //福袋奖励相关，判断获得道具个数
            sc_msg_def::jpk_lmt_event_t jpk;
            sp_user_->reward.get_lucky_bag_date(jpk);
            if(date_helper.cur_sec() >= jpk.lmt_event_begin && date_helper.cur_sec() <= jpk.lmt_event_end)
            {
                //在福袋活动期内则更具充值的钱数发放道具
                repo_def::configure_t * rp_config = NULL;
                int money = 100;
                if ((rp_config = repo_mgr.configure.get(22)) != NULL)
                    money = rp_config->value;
                if (money > 0)
                {
                    //计算道具个数
                    int num = 0;
                    if(sp_user_->reward.db_ext.luckbagstamp >= jpk.lmt_event_begin && sp_user_->reward.db_ext.luckbagstamp <= jpk.lmt_event_end )
                    {

                        num = (sp_db->pay_rmb + sp_user_->reward.db_ext.luckbagvalue)/money;
                        sp_user_->reward.db_ext.luckbagvalue = (sp_db->pay_rmb + sp_user_->reward.db_ext.luckbagvalue)%money;
                        sp_user_->reward.db_ext.luckbagstamp = date_helper.cur_sec();
                        sp_user_->reward.db_ext.set_luckbagvalue(sp_user_->reward.db_ext.luckbagvalue);
                        sp_user_->reward.db_ext.set_luckbagstamp(date_helper.cur_sec());
                        sp_user_->reward.save_db_ext();
                        sc_msg_def::nt_luckybag_change nt;
                        nt.luckybagvalue = sp_user_->reward.db_ext.luckbagvalue;
                        logic.unicast(sp_user_->db.uid, nt); 
                    }
                    else
                    {
                        num = sp_db->pay_rmb/money;
                        sp_user_->reward.db_ext.luckbagvalue = sp_db->pay_rmb%money;
                        sp_user_->reward.db_ext.luckbagstamp = date_helper.cur_sec();
                        sp_user_->reward.db_ext.set_luckbagvalue(sp_user_->reward.db_ext.luckbagvalue);
                        sp_user_->reward.db_ext.set_luckbagstamp(date_helper.cur_sec());
                        sp_user_->reward.save_db_ext();
                        sc_msg_def::nt_luckybag_change nt;
                        nt.luckybagvalue = sp_user_->reward.db_ext.luckbagvalue;
                        logic.unicast(sp_user_->db.uid, nt); 
                    
                    }

                    sc_msg_def::nt_bag_change_t nt;
                    sp_user_->item_mgr.addnew(16002, num, nt);
                    sp_user_->item_mgr.on_bag_change(nt);
                }
            }
            //判断充值金额是否大于等于100
            sc_msg_def::jpk_lmt_event_t lmt_growing;
            sp_user_->reward.get_lmt_date(lmt_growing, 10);
            if(date_helper.cur_sec() >= lmt_growing.lmt_event_begin && date_helper.cur_sec() <= lmt_growing.lmt_event_end)
            {
                if (sp_db->pay_rmb >= 100)
                {
                    if (sp_user_->reward.db.is_consume_hundred == 0)
                    {
                        logwarn((LOG, "on_payed consume hundred one time!!!! uid : %d", sp_user_->db.uid));    
                        sp_user_->reward.db.set_is_consume_hundred(1);
                    }
                }
            }
            //发送客户端BI
            sc_msg_def::nt_payyb_change_t nt_change;
            nt_change.delta = sp_db->pay_rmb;
            logic.unicast(sp_db->uid, nt_change);
            
            sp_db->set_state(3);
            sp_db->set_giventime(date_helper.str_date());
            string sql = sp_db->get_up_sql();
            if (SUCCESS == dbgl_service.async_execute(sql))
            {
                sc_service.async_do([](sp_user_t& sp_user_, boost::shared_ptr<db_Pay_ext_t>& sp_db_){
                    //对于充值金额大于表格金额的处理
                    string domain = sp_db_->domain.c_str();
                    if(domain == "appstore_" || domain == "jituo1" || domain == "jituo2" || domain == "xuegao1" || domain == "xuegao2" || domain == "soga" || domain == "zhanji"){
                        repo_def::apppay_t* rp_pay = repo_mgr.apppay.get(sp_db_->goodsid);
                        if (rp_pay != NULL && sp_db_->pay_rmb > rp_pay->rmb)
                        {
                        float off = sp_db_->pay_rmb - rp_pay->rmb;
                        off *= rp_pay->ratio;
                        sp_db_->reward_cristal += (int)(off + 0.5f);
                        }
                    }else{
                        repo_def::pay_t* rp_pay = repo_mgr.pay.get(sp_db_->goodsid);
                        if (rp_pay != NULL && sp_db_->pay_rmb > rp_pay->rmb)
                        {
                        float off = sp_db_->pay_rmb - rp_pay->rmb;
                        off *= rp_pay->ratio;
                        sp_db_->reward_cristal += (int)(off + 0.5f);
                        }
                    }

                    sp_user_->on_payed(sp_db_->pay_rmb);
                    int pos = sp_db_->goodsid - BASEID;

                    if (sp_db_->goodsid == MOONCARDID)
                    {
                        repo_def::lmt_event_t* rp_reward = repo_mgr.lmt_event.get(6);
                        if (NULL == rp_reward) {
                            logwarn((LOG, "load_repo, lmt_event mcard not exists"));
                        } 
                        else 
                        {
                            if(date_helper.cur_sec() < str2stamp(rp_reward->start_time) || date_helper.cur_sec() > str2stamp(rp_reward->end_time)) 
                            {
                            }
                            else if(sp_user_->reward.db.mcardbuytm < str2stamp(rp_reward->start_time))
                            {
                                sp_user_->reward.db.set_mcard_event_buy_count(1);
                                sp_user_->reward.db.set_mcard_event_state(0);
                            }
                            else
                            {
                                sp_user_->reward.db.set_mcard_event_buy_count(sp_user_->reward.db.mcard_event_buy_count + 1);
                                if(sp_user_->reward.db.mcard_event_state == 0){
                                    if(sp_user_->reward.db.mcard_event_buy_count >= MCARD_EVENT_N){
                                        sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn + MCARD_EVENT_REWARD_N * 30);
                                        sp_user_->reward.db.set_mcard_event_state(1);
                                        sc_msg_def::nt_mcard_event_t nt_event;
                                        nt_event.state = 1;
                                        nt_event.count = sp_user_->reward.db.mcard_event_buy_count;
                                        logic.unicast(sp_user_->db.uid,nt_event);
                                    }
                                }
                            }
                        }

                        //sp_user_->reward.db.set_mcardtm(0);
                        sp_user_->reward.db.set_mcardbuytm(date_helper.cur_sec());
                        sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn+30);
                        sp_user_->reward.save_db();
                        auto rp_gmail = mailinfo.get_repo(mail_mcard_daily);
                        if (rp_gmail != NULL && (sp_user_->reward.db.mcardtm == 0 || !(sp_user_->reward.db.mcardtm - date_helper.cur_0_stmp() >= 0)))
                        {
                            sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn-1);
                            sp_user_->reward.db.set_mcardtm(date_helper.cur_sec());
                            sc_msg_def::nt_bag_change_t nt;
                            sc_msg_def::jpk_item_t item;
                            item.itid = 0;
                            item.resid = 10003;
                            item.num = 120;//月卡每天领取120钻
                            nt.items.push_back(item);
                            string msg = mailinfo.new_mail(mail_mcard_daily, "120");
                            sp_user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                        }
                        sp_user_->reward.save_db();
                        sp_user_->reward.nt_mcard_info();
                    }
                    else if (is_first_pay(sp_user_->db.firstpay, pos))
                    {
                        sp_user_->db.set_firstpay(sp_user_->db.firstpay + (int32_t)pow(2,pos));
                        sc_msg_def::nt_first_pay_t nt;
                        nt.state = 1;
                        nt.firstpay = sp_user_->db.firstpay;
                        logic.unicast(sp_user_->db.uid,nt);
                    }

                    if (sp_db_->reward_cristal > 0)
                        sp_user_->on_allyb_change(sp_db_->cristal,sp_db_->reward_cristal);
                    else
                        sp_user_->on_payyb_change(sp_db_->cristal);
                    sp_user_->reward.cast_yb(sp_db_->pay_rmb);

                    //推送信封
                    string mail;
                    if (sp_db_->goodsid == MOONCARDID)
                        mail=mailinfo.new_mail(mail_mcard_nt, sp_user_->db.viplevel); 
                    else
                        mail=mailinfo.new_mail(mail_pay_ok, sp_db_->cristal+sp_db_->reward_cristal); 
                    if (!mail.empty())
                        notify_ctl.push_mail(sp_user_->db.uid, mail);

                    //统计信息
                    statics_ins.unicast_yblog(sp_user_,*sp_db_);
                }, sp_user_, sp_db);
            }
            else
            {
                logerror((LOG, "on_payed but set state 3 failed, serid:%u", serid_));
                return;
            }
        }
    }, sp_user_, serid_);
    return 0;
}

int sc_pay_t::on_login(sp_user_t sp_user_)
{
    dbgl_service.async_do((uint64_t)sp_user_->db.uid, [](sp_user_t sp_user_){
        sql_result_t res;
        if (db_Pay_ext_t::select_uid_state(sp_user_->db.uid,2,res))
            return;
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<db_Pay_ext_t> sp_db(new db_Pay_ext_t);
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "get_row_at is NULL!!, at:%d", i));
                break;
            }
            sp_db->init(*res.get_row_at(i));
            //福袋奖励相关，判断获得道具个数
            sc_msg_def::jpk_lmt_event_t jpk;
            sp_user_->reward.get_lucky_bag_date(jpk);
            if(date_helper.cur_sec() >= jpk.lmt_event_begin && date_helper.cur_sec() <= jpk.lmt_event_end)
            {
                //在福袋活动期内则更具充值的钱数发放道具
                repo_def::configure_t * rp_config = NULL;
                int money = 100;
                if ((rp_config = repo_mgr.configure.get(22)) != NULL)
                    money = rp_config->value;
                if (money > 0)
                {
                    //计算道具个数
                    int num = 0;
                    if(sp_user_->reward.db_ext.luckbagstamp >= jpk.lmt_event_begin && sp_user_->reward.db_ext.luckbagstamp <= jpk.lmt_event_end )
                    {

                        num = (sp_db->pay_rmb + sp_user_->reward.db_ext.luckbagvalue)/money;
                        sp_user_->reward.db_ext.luckbagvalue = (sp_db->pay_rmb + sp_user_->reward.db_ext.luckbagvalue)%money;
                        sp_user_->reward.db_ext.luckbagstamp = date_helper.cur_sec();
                        sp_user_->reward.db_ext.set_luckbagvalue(sp_user_->reward.db_ext.luckbagvalue);
                        sp_user_->reward.db_ext.set_luckbagstamp(date_helper.cur_sec());
                        sp_user_->reward.save_db_ext();
                        sc_msg_def::nt_luckybag_change nt;
                        nt.luckybagvalue = sp_user_->reward.db_ext.luckbagvalue;
                        logic.unicast(sp_user_->db.uid, nt); 
                    }
                    else
                    {
                        num = sp_db->pay_rmb/money;
                        sp_user_->reward.db_ext.luckbagvalue = sp_db->pay_rmb%money;
                        sp_user_->reward.db_ext.luckbagstamp = date_helper.cur_sec();
                        sp_user_->reward.db_ext.set_luckbagvalue(sp_user_->reward.db_ext.luckbagvalue);
                        sp_user_->reward.db_ext.set_luckbagstamp(date_helper.cur_sec());
                        sp_user_->reward.save_db_ext();
                        sc_msg_def::nt_luckybag_change nt;
                        nt.luckybagvalue = sp_user_->reward.db_ext.luckbagvalue;
                        logic.unicast(sp_user_->db.uid, nt); 
                    }

                    sc_msg_def::nt_bag_change_t nt;
                    sp_user_->item_mgr.addnew(16002, num, nt);
                    sp_user_->item_mgr.on_bag_change(nt);
                }
            }
             
            //判断充值金额是否大于等于100
            sc_msg_def::jpk_lmt_event_t lmt_growing;
            sp_user_->reward.get_lmt_date(lmt_growing, 10);
            if(date_helper.cur_sec() >= lmt_growing.lmt_event_begin && date_helper.cur_sec() <= lmt_growing.lmt_event_end)
            {
                if (sp_db->pay_rmb >= 100)
                {
                    if (sp_user_->reward.db.is_consume_hundred == 0)
                    {
                        logwarn((LOG, "on_payed consume hundred one time!!!! uid : %d", sp_user_->db.uid));    
                        sp_user_->reward.db.set_is_consume_hundred(1);
                    }
                }
            }
             
            //客户端BI
            sp_user_->pay_rmb = sp_db->pay_rmb;

            sp_db->set_state(3);
            sp_db->set_giventime(date_helper.str_date());
            string sql = sp_db->get_up_sql();
            if (SUCCESS == dbgl_service.async_execute(sql))
            {
                sc_service.async_do([](sp_user_t& sp_user_, boost::shared_ptr<db_Pay_ext_t>& sp_db_){
                    //对于充值金额大于表格金额的处理
                    string domain = sp_db_->domain.c_str();
                    if(domain == "appstore_" || domain == "jituo1" || domain == "jituo2" || domain == "xuegao1" || domain == "xuegao2" || domain == "soga" || domain == "zhanji"){
                        repo_def::apppay_t* rp_pay = repo_mgr.apppay.get(sp_db_->goodsid);
                        if (rp_pay != NULL && sp_db_->pay_rmb > rp_pay->rmb)
                        {
                        float off = sp_db_->pay_rmb - rp_pay->rmb;
                        off *= rp_pay->ratio;
                        sp_db_->reward_cristal += (int)(off + 0.5f);
                        }
                    }else{
                        repo_def::pay_t* rp_pay = repo_mgr.pay.get(sp_db_->goodsid);
                        if (rp_pay != NULL && sp_db_->pay_rmb > rp_pay->rmb)
                        {
                        float off = sp_db_->pay_rmb - rp_pay->rmb;
                        off *= rp_pay->ratio;
                        sp_db_->reward_cristal += (int)(off + 0.5f);
                        }
                    }

                    sp_user_->on_payed(sp_db_->pay_rmb);
                    int pos = sp_db_->goodsid - BASEID;

                    if (sp_db_->goodsid == MOONCARDID)
                    {
                        repo_def::lmt_event_t* rp_reward = repo_mgr.lmt_event.get(6);
                        if (NULL == rp_reward) {
                            logwarn((LOG, "load_repo, lmt_event mcard not exists"));
                        } 
                        else 
                        {
                            if(date_helper.cur_sec() < str2stamp(rp_reward->start_time) || date_helper.cur_sec() > str2stamp(rp_reward->end_time)) 
                            {
                            }
                            else if(sp_user_->reward.db.mcardbuytm < str2stamp(rp_reward->start_time))
                            {
                                sp_user_->reward.db.set_mcard_event_buy_count(1);
                                sp_user_->reward.db.set_mcard_event_state(0);
                            }
                            else
                            {
                                sp_user_->reward.db.set_mcard_event_buy_count(sp_user_->reward.db.mcard_event_buy_count + 1);
                                if(sp_user_->reward.db.mcard_event_state == 0){
                                    if(sp_user_->reward.db.mcard_event_buy_count >= MCARD_EVENT_N){
                                        sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn + MCARD_EVENT_REWARD_N * 30);
                                        sp_user_->reward.db.set_mcard_event_state(1);
                                        sc_msg_def::nt_mcard_event_t nt_event;
                                        nt_event.state = 1;
                                        nt_event.count = sp_user_->reward.db.mcard_event_buy_count;
                                        logic.unicast(sp_user_->db.uid,nt_event);
                                    }
                                }
                            }
                        }

                        //sp_user_->reward.db.set_mcardtm(0);
                        sp_user_->reward.db.set_mcardbuytm(date_helper.cur_sec());
                        sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn+30);
                        sp_user_->reward.save_db();
                        auto rp_gmail = mailinfo.get_repo(mail_mcard_daily);
                        if (rp_gmail != NULL && (sp_user_->reward.db.mcardtm == 0 || !(sp_user_->reward.db.mcardtm - date_helper.cur_0_stmp() >= 0)))
                        {
                            sp_user_->reward.db.set_mcardn(sp_user_->reward.db.mcardn-1);
                            sp_user_->reward.db.set_mcardtm(date_helper.cur_sec());
                            sc_msg_def::nt_bag_change_t nt;
                            sc_msg_def::jpk_item_t item;
                            item.itid = 0;
                            item.resid = 10003;
                            item.num = 120;//月卡每天领取120钻
                            nt.items.push_back(item);
                            string msg = mailinfo.new_mail(mail_mcard_daily, "120");
                            sp_user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                        }
                        sp_user_->reward.save_db();
                        sp_user_->reward.nt_mcard_info();
                    }
                    else if (is_first_pay(sp_user_->db.firstpay, pos))
                    {
                        sp_user_->db.set_firstpay(sp_user_->db.firstpay + (int32_t)pow(2,pos));
                        sc_msg_def::nt_first_pay_t nt;
                        nt.state = 1;
                        nt.firstpay = sp_user_->db.firstpay;
                        logic.unicast(sp_user_->db.uid,nt);
                    }

                    if (sp_db_->reward_cristal > 0)
                        sp_user_->on_allyb_change(sp_db_->cristal,sp_db_->reward_cristal);
                    else
                        sp_user_->on_payyb_change(sp_db_->cristal);
                    sp_user_->reward.cast_yb(sp_db_->pay_rmb);

                    //推送信封
                    string mail;
                    if (sp_db_->goodsid == MOONCARDID)
                        mail=mailinfo.new_mail(mail_mcard_nt, sp_user_->db.viplevel); 
                    else
                        mail=mailinfo.new_mail(mail_pay_ok, sp_db_->cristal+sp_db_->reward_cristal); 
                    if (!mail.empty())
                        notify_ctl.push_mail(sp_user_->db.uid, mail);

                    //统计信息
                    statics_ins.unicast_yblog(sp_user_,*sp_db_);
                }, sp_user_, sp_db);
            }
            else
            {
                logerror((LOG, "on_login but set state 3 failed, serid:%u", sp_db->serid));
                return;
            }
        }
    }, sp_user_);
    return SUCCESS;
}
