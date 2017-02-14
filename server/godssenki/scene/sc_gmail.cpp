#include "sc_gmail.h"
#include "sc_logic.h"
#include "sc_mailinfo.h"
#include "log.h"
#include "date_helper.h"

#define MAX_MAIL 100

vector<sp_gmail_t>  sc_gmail_mgr_t::g_hostmail;
string              sc_gmail_mgr_t::m_sql;
int64_t             sc_gmail_mgr_t::max_mid;
string              sc_gmail_mgr_t::compare_sql;

#define MAIL_LOG "SC_MAIL"

void db2jpk(sp_gmail_t& sp_gmail_, sc_msg_def::jpk_gmail_t& jpk_)
{
    jpk_.id = sp_gmail_->mid;
    jpk_.flag = sp_gmail_->flag;
    jpk_.resid = 0;
    jpk_.title = sp_gmail_->title.c_str();
    jpk_.sender = sp_gmail_->sender.c_str();
    string content = sp_gmail_->info.c_str();
    
    //jjc邮件特殊处理
    if (content.length() >= 6)
    {
        string info = content.substr(0, 5);
        string rank = content.substr(5, content.length()-5);  
        jpk_.content = sp_gmail_->info.c_str();

        if (info == "json:")
            jpk_.content = mailinfo.new_mail(mail_arena_reward, rank);
    }

    jpk_.readed = sp_gmail_->opened;
    jpk_.rewarded = sp_gmail_->rewarded;
    jpk_.stamp = sp_gmail_->stamp;
    jpk_.validtime = sp_gmail_->validtime;
    jpk_.date = date_helper.str_date(jpk_.stamp);
    auto f=[&](int resid_, int num_){
        if (resid_ > 0 && num_ > 0)
        {
            sc_msg_def::jpk_item_t ji;
            ji.itid = 0;
            ji.resid = resid_;
            ji.num = num_;
            jpk_.reward_items.push_back(std::move(ji));
        }
    };

    f(sp_gmail_->item1, sp_gmail_->count1);
    f(sp_gmail_->item2, sp_gmail_->count2);
    f(sp_gmail_->item3, sp_gmail_->count3);
    f(sp_gmail_->item4, sp_gmail_->count4);
    f(sp_gmail_->item5, sp_gmail_->count5);
}
void jpk2db(sc_msg_def::jpk_gmail_t& jpk_, sp_gmail_t& sp_gmail_)
{
    sp_gmail_->mid = jpk_.id;
    sp_gmail_->flag = jpk_.flag;
    sp_gmail_->resid = 0;
    sp_gmail_->title = jpk_.title;
    sp_gmail_->sender = jpk_.sender;
    sp_gmail_->info = jpk_.content;
    sp_gmail_->opened = jpk_.readed ;
    sp_gmail_->rewarded = jpk_.rewarded;
    sp_gmail_->stamp = jpk_.stamp;
    sp_gmail_->validtime = jpk_.validtime;
    auto f=[&](size_t i_, int& resid_, int& num_){
        resid_ = 0;
        num_ = 0;
        if (i_ <= jpk_.reward_items.size())
        {
            resid_ = jpk_.reward_items[i_-1].resid;
            num_ = jpk_.reward_items[i_-1].num;
        }
    };

    f(1, sp_gmail_->item1, sp_gmail_->count1);
    f(2, sp_gmail_->item2, sp_gmail_->count2);
    f(3, sp_gmail_->item3, sp_gmail_->count3);
    f(4, sp_gmail_->item4, sp_gmail_->count4);
    f(5, sp_gmail_->item5, sp_gmail_->count5);
}

sc_gmail_mgr_t::sc_gmail_mgr_t(sc_user_t& user_):
    m_user(user_)
{
}
void sc_gmail_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_GMail_t::sync_select_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_gmail_t sp_gmail(new db_GMail_ext_t);
            sp_gmail->init(*res.get_row_at(i));
            m_gmail_list.insert(m_gmail_list.begin(), sp_gmail); 
            m_gmail_map.insert(make_pair(sp_gmail->mid, m_gmail_list.begin()));
            m_maxid.update(sp_gmail->mid);
        }
    }

    compare_sql = "INSERT IGNORE INTO `GMail` ( `count1`  ,  `mid`  ,  `flag`  ,  `validtime`  ,  `opened`  ,  `info`  ,  `count5`  ,  `stamp`  ,  `resid`  ,  `sender`  ,  `item5`  ,  `count3`  ,  `count2`  ,  `rewarded`  ,  `uid`  ,  `title`  ,  `count4`  ,  `item4`  ,  `item3`  ,  `item2`  ,  `item1` ) VALUES"; 

    //读取邮件最大mid
    sql_result_t res1;
    db_service.sync_select("select max(mid) from GMail", res1);


    if(res1.affect_row_num() == 0){
        max_mid = 1;
    }else{
        sql_result_row_t& row = *res1.get_row_at(0);
        if(row.empty())
            max_mid = 1;
        else
        {
            max_mid = (int64_t)atoi(row[0].c_str());
            if(max_mid%2==0)
                max_mid++;
        }
    }

}
//登入获取邮件信息
void sc_gmail_mgr_t::on_login()
{
    if (g_hostmail.empty())
        return;
    int maxid = g_hostmail[0]->mid;
    int recvn = 0;
    for(size_t i=0; i<g_hostmail.size(); i++)
    {
        if (g_hostmail[i]->mid > m_user.db.hm_maxid)
        {
            recvn++;

            sp_gmail_t sp_gmail(new db_GMail_ext_t);
            db_GMail_t* dst = (db_GMail_t*)sp_gmail.get();
            db_GMail_t* src = (db_GMail_t*)g_hostmail[i].get();
            memcpy(dst, src, sizeof(db_GMail_t));

            sp_gmail->mid = m_maxid.newid();
            sp_gmail->uid = m_user.db.uid;
            m_gmail_list.insert(m_gmail_list.begin(), sp_gmail); 
            m_gmail_map.insert(make_pair(sp_gmail->mid, m_gmail_list.begin()));

            db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
                sp_gmail_->insert();
            }, sp_gmail);
        }
    }
    if (recvn > 0)
    {
        m_user.db.set_hm_maxid(maxid);
        m_user.save_db();
    }
}
void sc_gmail_mgr_t::load_hostmail(vector<int32_t>& hostnums_)
{
    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char sql[1024];
    sprintf(sql, "SELECT `mid`, `jstr` FROM `HostGMail`  WHERE  `hostnum` in (%s) order by mid DESC", str_hosts.c_str());

    sql_result_t res;
    db_service.sync_select(sql, res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
            break;
        sc_msg_def::jpk_gmail_t jpk;
        int mid = std::atoi((*res.get_row_at(i))[0].c_str());
        jpk << (*res.get_row_at(i))[1];
        jpk.id = mid;
        sp_gmail_t sp_gmail(new db_GMail_ext_t);
        jpk2db(jpk, sp_gmail);
        if (date_helper.offday(sp_gmail->stamp) <= 30)
            g_hostmail.push_back(std::move(sp_gmail));
    }
}
void sc_gmail_mgr_t::add_hostmail(sc_msg_def::jpk_gmail_t& jpk_)
{
    sp_gmail_t sp_gmail(new db_GMail_ext_t);
    jpk2db(jpk_, sp_gmail);
    g_hostmail.push_back(sp_gmail);
    std::sort(g_hostmail.begin(), g_hostmail.end(), [](const sp_gmail_t& a_, const sp_gmail_t& b_){
        return (a_->mid > b_->mid);
    });
}

void sc_gmail_mgr_t::begin_offmail()
{
    m_sql = "INSERT IGNORE INTO `GMail` ( `count1`  ,  `mid`  ,  `flag`  ,  `validtime`  ,  `opened`  ,  `info`  ,  `count5`  ,  `stamp`  ,  `resid`  ,  `sender`  ,  `item5`  ,  `count3`  ,  `count2`  ,  `rewarded`  ,  `uid`  ,  `title`  ,  `count4`  ,  `item4`  ,  `item3`  ,  `item2`  ,  `item1` ) VALUES"; 
}

void sc_gmail_mgr_t::do_offmail()
{
    if(compare_sql != m_sql)
    {
        m_sql = m_sql.substr(0, m_sql.length()-1);
        db_service.sync_execute(m_sql);
    }
}

void sc_gmail_mgr_t::add_offmail(int32_t uid, const string& title_, const string& sender_, const string& msg_, int validtime_, vector<sc_msg_def::jpk_item_t>& items_, int flag_)

{
    max_mid = max_mid + 2;
    char tmp_sql[256];
    int32_t i_size = items_.size();
    sprintf(tmp_sql, "( %d , %d , %d , %d , %d , '%s' , %d , %u , %d, '%s' , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d )," , (i_size>=1 ? items_[0].num : 0), max_mid, flag_, validtime_, 0, msg_.c_str(), (i_size>=5 ? items_[4].num : 0), date_helper.cur_sec(), 0, sender_.c_str(), (i_size>=5 ? items_[4].resid : 0), (i_size>=3 ? items_[2].num : 0), (i_size>=2 ? items_[1].num : 0), 0, uid, title_.c_str(), (i_size>=4 ? items_[3].num : 0), (i_size>=4 ? items_[3].resid : 0), (i_size >= 3 ? items_[2].resid : 0), (i_size >= 2 ? items_[1].resid :0), (i_size >= 1 ? items_[0].resid : 0));
    m_sql += string(tmp_sql);
}
//获取邮件相关信息
void sc_gmail_mgr_t::unicast()
{
    int flagn[] = {0,0,0};
    sc_msg_def::ret_gmail_list_t ret;
    for(auto it=m_gmail_list.begin(); it!=m_gmail_list.end();)
    {
        sp_gmail_t sp_gmail = *it;
        if (flagn[sp_gmail->flag] >= MAX_MAIL)
        {
            m_gmail_map.erase(sp_gmail->mid);
            it=m_gmail_list.erase(it);
            db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
                sp_gmail_->remove();
            }, sp_gmail);
        }
        else 
        {
            sc_msg_def::jpk_gmail_t jpk;
            db2jpk(sp_gmail, jpk); 
            if (jpk.validtime != -1 and ((jpk.stamp + jpk.validtime * 86400) <= date_helper.cur_sec()))
            {
                m_gmail_map.erase(sp_gmail->mid);
                it=m_gmail_list.erase(it);
                db_service.async_do((uint64_t)m_user.db.uid,[](sp_gmail_t sp_gmail_){
                    sp_gmail_->remove();

                },sp_gmail);
            } 
            else
            {
                ret.mails.push_back(std::move(jpk));
                flagn[jpk.flag]++;
                it++;
            }
        }
    }
    logic.unicast(m_user.db.uid, ret);
}
//打开邮件变为已读状态
void sc_gmail_mgr_t::open(int id_)
{
    auto it = m_gmail_map.find(id_);
    if (it != m_gmail_map.end())
    {
        auto sp_gmail = *(it->second);
        sp_gmail->set_opened(1);
        save_db(sp_gmail);
    }
}
//领取邮件奖励
void sc_gmail_mgr_t::reward(int id_)
{
    auto f=[&](int resid_, int num_, sc_msg_def::nt_bag_change_t& nt_){
        if (resid_ > 0 && num_ > 0)
        {
            m_user.item_mgr.addnew(resid_, num_, nt_);
            logerror((MAIL_LOG,"email reward uid = %d, resid_ = %d, num_ = %d", m_user.db.uid, resid_, num_));
        }
    };

    sc_msg_def::ret_gmail_reward_t ret;
    ret.id = id_;
    ret.code = SUCCESS;

    auto it = m_gmail_map.find(id_);
    if (it != m_gmail_map.end())
    {
        auto sp_gmail = *(it->second);
        sc_msg_def::nt_bag_change_t nt;
        f(sp_gmail->item1,sp_gmail->count1,nt);
        f(sp_gmail->item2,sp_gmail->count2,nt);
        f(sp_gmail->item3,sp_gmail->count3,nt);
        f(sp_gmail->item4,sp_gmail->count4,nt);
        f(sp_gmail->item5,sp_gmail->count5,nt);
        m_user.item_mgr.on_bag_change(nt);
        m_gmail_list.erase(it->second);
        m_gmail_map.erase(it);
        db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
                sp_gmail_->remove();
             }, sp_gmail);
    }
    else ret.code = ERROR_SC_ILLEGLE_REQ;

    logic.unicast(m_user.db.uid, ret);
}
//删除邮件
void sc_gmail_mgr_t::deletemail(int id_)
{
    sc_msg_def::ret_gmail_delete_t ret;
    ret.id = id_;
    ret.code = SUCCESS;

    auto it = m_gmail_map.find(id_);
    if (it != m_gmail_map.end())
    {
        auto sp_gmail = *(it->second);
        m_gmail_list.erase(it->second);
        m_gmail_map.erase(it);
        db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
            sp_gmail_->remove();
        }, sp_gmail);
        save_db(sp_gmail);
    }
    else ret.code = ERROR_SC_ILLEGLE_REQ;

    logic.unicast(m_user.db.uid, ret);
}
//领取所有奖励并删除邮件
void sc_gmail_mgr_t::getallreward()
{
    auto f=[&](int resid_, int num_, sc_msg_def::nt_bag_change_t& nt_){
        logerror((MAIL_LOG,"email allreward uid = %d, resid_ = %d, num_ = %d", m_user.db.uid, resid_, num_));
        if (resid_ > 0 && num_ > 0)
            m_user.item_mgr.addnew(resid_, num_, nt_);
    };
    sc_msg_def::ret_gmail_getallreward_t ret;
    ret.code = SUCCESS;

    for(auto it=m_gmail_list.begin(); it!=m_gmail_list.end();)
    {
        sp_gmail_t sp_gmail = *it;
        sc_msg_def::jpk_gmail_t jpk;
        db2jpk(sp_gmail, jpk);
        if(sp_gmail->flag == 1)
        {
            sc_msg_def::nt_bag_change_t nt;
            f(sp_gmail->item1,sp_gmail->count1,nt);
            f(sp_gmail->item2,sp_gmail->count2,nt);
            f(sp_gmail->item3,sp_gmail->count3,nt);
            f(sp_gmail->item4,sp_gmail->count4,nt);
            f(sp_gmail->item5,sp_gmail->count5,nt);
            m_user.item_mgr.on_bag_change(nt);
            m_gmail_map.erase(sp_gmail->mid);
            it=m_gmail_list.erase(it);
            db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
                sp_gmail_->remove();
             }, sp_gmail);
            ret.id.push_back(sp_gmail->mid);
        }
        else
            it++;
    }
    logic.unicast(m_user.db.uid, ret);
}

void sc_gmail_mgr_t::send(sc_msg_def::jpk_gmail_t& jpk_)
{
    sp_gmail_t sp_gmail(new db_GMail_ext_t);
    jpk2db(jpk_, sp_gmail);

    max_mid = max_mid + 2;
    sp_gmail->mid = max_mid;
    //sp_gmail->mid = m_maxid.newid();
    sp_gmail->uid = m_user.db.uid;

    m_gmail_list.insert(m_gmail_list.begin(), sp_gmail); 
    m_gmail_map.insert(make_pair(sp_gmail->mid, m_gmail_list.begin()));

    db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
        sp_gmail_->insert();
    }, sp_gmail);

    sc_msg_def::nt_new_gmail_t nt;
    nt.mail = jpk_;
    logic.unicast(m_user.db.uid, nt);
}
//发送消息文件
void sc_gmail_mgr_t::send(const string& title_, const string& sender_, const string& msg_, int validtime_, int flag_)
{
    sp_gmail_t sp_gmail(new db_GMail_ext_t);
    max_mid = max_mid + 2;
    sp_gmail->mid = max_mid;
    //sp_gmail->mid = m_maxid.newid();
    sp_gmail->uid = m_user.db.uid;
    sp_gmail->resid = 0;
    sp_gmail->flag = flag_;
    sp_gmail->title=title_;
    sp_gmail->sender=sender_;
    sp_gmail->info = msg_;
    sp_gmail->opened = 0;
    sp_gmail->rewarded = 0;
    sp_gmail->stamp=date_helper.cur_sec();
    sp_gmail->validtime = validtime_;
    sp_gmail->item1=0;
    sp_gmail->count1=0;
    sp_gmail->item2=0;
    sp_gmail->count2=0;
    sp_gmail->item3=0;
    sp_gmail->count3=0;
    sp_gmail->item4=0;
    sp_gmail->count4=0;
    sp_gmail->item5=0;
    sp_gmail->count5=0;

    m_gmail_list.insert(m_gmail_list.begin(), sp_gmail); 
    m_gmail_map.insert(make_pair(sp_gmail->mid, m_gmail_list.begin()));

    db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
        sp_gmail_->insert();
    }, sp_gmail);

    sc_msg_def::nt_new_gmail_t nt;
    db2jpk(sp_gmail, nt.mail);
    logic.unicast(m_user.db.uid, nt);
}
//发送奖励邮件
void sc_gmail_mgr_t::send(const string& title_, const string& sender_, const string& msg_, int validtime_, vector<sc_msg_def::jpk_item_t>& items_, int flag_)
{
    sp_gmail_t sp_gmail(new db_GMail_ext_t);
    max_mid = max_mid + 2;
    sp_gmail->mid = max_mid;
    //sp_gmail->mid = m_maxid.newid();
    sp_gmail->uid = m_user.db.uid;
    sp_gmail->resid = 0;
    sp_gmail->flag = flag_;
    sp_gmail->title=title_;
    sp_gmail->sender=sender_;
    sp_gmail->info = msg_;
    sp_gmail->opened = 0;
    sp_gmail->rewarded = 0;
    sp_gmail->stamp=date_helper.cur_sec();
    sp_gmail->validtime = validtime_;
    sp_gmail->item1=0;
    sp_gmail->count1=0;
    sp_gmail->item2=0;
    sp_gmail->count2=0;
    sp_gmail->item3=0;
    sp_gmail->count3=0;
    sp_gmail->item4=0;
    sp_gmail->count4=0;
    sp_gmail->item5=0;
    sp_gmail->count5=0;

    uint32_t i=0;
    if (i<items_.size())
    {
        sp_gmail->item1=items_[i].resid;
        sp_gmail->count1=items_[i].num;
    }
    i++;
    if (i<items_.size())
    {
        sp_gmail->item2=items_[i].resid;
        sp_gmail->count2=items_[i].num;
    }
    i++;
    if (i<items_.size())
    {
        sp_gmail->item3=items_[i].resid;
        sp_gmail->count3=items_[i].num;
    }
    i++;
    if (i<items_.size())
    {
        sp_gmail->item4=items_[i].resid;
        sp_gmail->count4=items_[i].num;
    }
    i++;
    if (i<items_.size())
    {
        sp_gmail->item5=items_[i].resid;
        sp_gmail->count5=items_[i].num;
    }

    m_gmail_list.insert(m_gmail_list.begin(), sp_gmail); 
    m_gmail_map.insert(make_pair(sp_gmail->mid, m_gmail_list.begin()));

    db_service.async_do((uint64_t)m_user.db.uid, [](sp_gmail_t sp_gmail_){
        sp_gmail_->insert();
    }, sp_gmail);

    sc_msg_def::nt_new_gmail_t nt;
    db2jpk(sp_gmail, nt.mail);
    logic.unicast(m_user.db.uid, nt);
}



//删除所有邮件
void sc_gmail_mgr_t::clear(int flag_)
{
    /*
    for(auto it=m_gmail_list.begin(); it!=m_gmail_list.end();)
    {
        auto sp_gmail = *(it);
        if (sp_gmail->flag == flag_)
        {
            m_gmail_map.erase(sp_gmail->mid);
            it = m_gmail_list.erase(it);
        }
        else it++;
    }
    */
    m_gmail_map.clear();
    m_gmail_list.clear();

    db_service.async_do((uint64_t)m_user.db.uid, [](int uid_){
            char sql[1024];
            sprintf(sql,"delete from GMail where uid=%d", uid_);
            db_service.async_execute(sql);
    }, m_user.db.uid);
}
void sc_gmail_mgr_t::save_db(sp_gmail_t sp_gmail_)
{
    auto sql = sp_gmail_->get_up_sql();
    if (!sql.empty())
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
            db_service.async_execute(sql_);
        }, sql);
    }
}

//获取未读邮件数量
int sc_gmail_mgr_t::get_unopened_num()
{
    int n=0;
    for(auto it=m_gmail_list.begin(); it!=m_gmail_list.end(); it++)
    {
        auto sp_gmail = *it;
        if (sp_gmail->opened == 0)
            n++;
    }
    return n;
}

//获取是否有未领取邮件
int sc_gmail_mgr_t::ishaverewardEmail()
{
    for(auto it=m_gmail_list.begin(); it!=m_gmail_list.end(); it++)
    {
        auto sp_gmail = *it;
        if (sp_gmail->flag == 1)
            return 1;
    }
    return 0;
}
