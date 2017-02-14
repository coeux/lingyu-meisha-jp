#include "sc_activity.h"
#include "sc_logic.h"
#include "sc_user.h"
#include "sc_item.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "random.h"

#include "log.h"
#include "repo_def.h"
#include "config.h"
#include "date_helper.h"

#define LOG "SC_ACT"
#define SAVE_TIME 300

string get_sql(vector<int32_t>& hostnums_, const string& opt_)
{
    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char buf[1024];
    sprintf(buf, "SELECT `nickname` , `cumu_yb_rank_exp` , `grade` , `con_wing_given` , `uid` , `con_wing_stamp` , `hostnum` , `cumu_yb_rank_stamp` , `con_wing_rank` , `con_wing_score` , `cumu_yb_rank`  FROM `Activity` WHERE  hostnum in (%s) %s",
         str_hosts.c_str(), opt_.c_str());
    return string(buf);
}

//========================================

act_cumu_yb_rank_t::act_cumu_yb_rank_t()
{
    m_opened = false;
    m_savetime = SAVE_TIME;
}
void act_cumu_yb_rank_t::load_db(vector<int32_t>& hostnums_)
{
    if (activity.get_repo(e_act_cumu_yb_rank, m_btime, m_etime))
        return;

    m_btime = date_helper.trans_unixstamp(m_btime);
    m_etime = date_helper.trans_unixstamp(m_etime);
    uint32_t now = date_helper.cur_sec();
    m_opened = (m_btime <= now && now <= m_etime);

    if (!isopen())
        return; 
        
    sql_result_t res;
    string sql = get_sql(hostnums_, "and cumu_yb_rank_exp > 0 order by cumu_yb_rank_exp desc limit 20;");
    db_service.sync_select(sql.c_str(), res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
            break;

        sp_auser_t sp_auser(new sc_auser_t);
        sp_auser->init(*res.get_row_at(i));
        if (activity.m_auser_map.find(sp_auser->uid) == activity.m_auser_map.end())
            activity.m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));

        sp_ri_t sp_ri(new sc_msg_def::jpk_cumu_yb_rank_t);
        sp_ri->uid=sp_auser->uid;
        sp_ri->nickname=sp_auser->nickname.c_str();
        sp_ri->grade=sp_auser->grade;
        sp_ri->yb=sp_auser->cumu_yb_rank_exp;
        m_rank_list.push_back(sp_ri);
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);
        m_map.insert(make_pair(sp_ri->uid, vi));
    }

    if (m_rank_list.size()>1)
    {
        m_rank_list.sort([](const sp_ri_t& a_, const sp_ri_t& b_)->bool{
            return (a_->yb > b_->yb);
        });
    }
}
void act_cumu_yb_rank_t::on_reload_repo()
{
    if (activity.get_repo(e_act_cumu_yb_rank, m_btime, m_etime))
        return;

    m_btime = date_helper.trans_unixstamp(m_btime);
    m_etime = date_helper.trans_unixstamp(m_etime);
    uint32_t now = date_helper.cur_sec();
    m_opened = (m_btime <= now && now <= m_etime);
}
void act_cumu_yb_rank_t::on_cumu_yb(int uid_, int yb_)
{
    if (!isopen())
        return;

    sp_auser_t sp_auser = activity.get_user(uid_);
    if (sp_auser == NULL)
    {
        logerror((LOG, "on_cumu_yb no user:%u", uid_));
        return;
    }

    //判断当前活动是否需要被重置
    if (sp_auser->cumu_yb_rank_stamp < m_btime)
        sp_auser->set_cumu_yb_rank_exp(yb_);
    else
        sp_auser->set_cumu_yb_rank_exp(sp_auser->cumu_yb_rank_exp + yb_);
    sp_auser->set_cumu_yb_rank_stamp(date_helper.cur_sec());
    activity.save_user(sp_auser);

    if (m_cumu_user_map.find(sp_auser->uid) == m_cumu_user_map.end())
        m_cumu_user_map[sp_auser->uid] = sp_auser;

    //如果当前用户的消费额比20名小则不进入排名榜
    if (m_rank_list.size() >= 20 && sp_auser->cumu_yb_rank_exp < (*m_rank_list.rbegin())->yb)
        return;

    auto it_found = m_map.find(uid_);
    if (it_found == m_map.end())
    {
        sp_ri_t sp_ri(new sc_msg_def::jpk_cumu_yb_rank_t);
        sp_ri->uid=(int)sp_auser->uid;
        sp_ri->nickname=sp_auser->nickname.c_str();
        sp_ri->grade=sp_auser->grade;
        sp_ri->yb=sp_auser->cumu_yb_rank_exp;
        m_rank_list.push_back(sp_ri);
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);
        m_map.insert(make_pair(sp_ri->uid, vi));
    }
    else
    {
        (*(it_found->second))->yb = sp_auser->cumu_yb_rank_exp;
    }

    m_rank_list.sort([](const sp_ri_t& a_, const sp_ri_t& b_)->bool{
        return (a_->yb > b_->yb);
    });

    //如果超出20名，则移除最后一名, 并将其rank置为0
    if (m_rank_list.size()>20)
    {
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);

        auto sp_auser = activity.get_user((*vi)->uid);

        m_map.erase((*vi)->uid);
        m_rank_list.erase(vi);

        sp_auser->set_cumu_yb_rank(0);
        activity.save_user(sp_auser);
    }

}
void act_cumu_yb_rank_t::unicast(int uid_)
{
    //通知消费排行榜
    sc_msg_def::ret_cumu_yb_rank_t ret;
    for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
    {
        sp_auser_t sp_auser = activity.get_user((*it)->uid);
        if (sp_auser != NULL)
        {
            (*it)->nickname = sp_auser->nickname.c_str();
            (*it)->grade = sp_auser->grade;
        }
        ret.ranks.push_back(*(*it));
    }
    logic.unicast(uid_, ret);
}
void fmail1(int uid_, const string& name1_, int num1_){
    string mail = mailinfo.new_mail(mail_cumu_yb_rank1, name1_, num1_); 
    if (!mail.empty())
        notify_ctl.push_mail(uid_, mail);
}
void fmail2(int uid_, int rank_, const string& name1_, int num1_, const string& name2_, int num2_){
    string mail = mailinfo.new_mail(mail_cumu_yb_rank2, rank_,name1_, num1_, name2_, num2_); 
    if (!mail.empty())
        notify_ctl.push_mail(uid_, mail);
}
void act_cumu_yb_rank_t::check_time()
{
    if (isopen())
        return;
    if (activity.get_repo(e_act_cumu_yb_rank, m_btime, m_etime))
        return;
    m_btime = date_helper.trans_unixstamp(m_btime);
    m_etime = date_helper.trans_unixstamp(m_etime);
    uint32_t now = date_helper.cur_sec();
    if (m_btime <= now && now <= m_etime)
        m_opened  = true;
}
void act_cumu_yb_rank_t::update()
{
    check_time();
    if (!isopen())
        return; 

    //定时保存排名
    if (isopen())
    {
        m_savetime--;
        if (m_savetime <= 0)
        {
            m_savetime = SAVE_TIME;
            int rank=0; 
            for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
            {
                int uid = (*it)->uid;
                sp_auser_t sp_auser = activity.get_user(uid);
                if (sp_auser == NULL)
                    continue;
                rank++;
                sp_auser->set_cumu_yb_rank(rank);
                activity.save_user(sp_auser);
            }
        }
    }

    //在活动开启但当前时间超过结束时间,则进行奖励发放
    if (isopen() && (date_helper.cur_sec() > m_etime))
    {
        m_opened = false;

        //排名奖励
        int rank=0; 
        for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
        {
            int uid = (*it)->uid;
            sp_auser_t sp_auser = activity.get_user(uid);
            if (sp_auser == NULL)
                continue;
            rank++;
            reward_rank(uid, rank);
        }
        //宝箱奖励
        for(auto it=m_cumu_user_map.begin(); it!=m_cumu_user_map.end(); it++)
        {
            if (-1 != reward_cumu(it->second->uid, it->second->cumu_yb_rank_exp))
            {
                it->second->set_cumu_yb_rank_exp(0);
                activity.save_user(it->second);
            }
        }

        //清除数据
        m_cumu_user_map.clear();
        m_map.clear();
        m_rank_list.clear();
    }
}
int act_cumu_yb_rank_t::reward_cumu(int uid_, int cumu_)
{
    sp_user_t user;
    if (!logic.usermgr().get(uid_, user))
        return -1;

    //黄金宝箱20002*5
    if (cumu_ < 1000)
        return -2;

    sc_msg_def::nt_bag_change_t nt;
    user->item_mgr.addnew(20002,5,nt);
    user->item_mgr.on_bag_change(nt);
    auto rp_item = repo_mgr.item.get(20002);
    fmail1(uid_, rp_item->name, 5);
    return 0;
}
int act_cumu_yb_rank_t::reward_rank(int uid_, int rank)
{
    sp_user_t user;
    if (!logic.usermgr().get(uid_, user))
        return -1;

    sc_msg_def::nt_bag_change_t nt;
    if (rank == 1)
    {
        //2003 宙斯*1
        //2075 赫拉*1
        user->partner_mgr.hire_from_reward(2003,0);
        user->partner_mgr.hire_from_reward(2075,0);

        auto rp_role1 = repo_mgr.role.get(2003);
        auto rp_role2 = repo_mgr.role.get(2075);
        fmail2(uid_, rank, rp_role1->name, 1, rp_role2->name, 1);
    }
    else if (2 <= rank && rank <= 3)
    {
        //2003 宙斯
        //32075 赫拉碎片*30
        user->partner_mgr.hire_from_reward(2003,0);
        user->partner_mgr.add_new_chip(32075,30,nt.chips);

        auto rp_role = repo_mgr.role.get(2003);
        auto rp_item = repo_mgr.item.get(32075);
        fmail2(uid_, rank, rp_role->name, 1, rp_item->name, 30);
    }
    else if (4 <= rank && rank <= 10)
    {
        //32003 宙斯碎片*35
        //32075 赫拉碎片*25
        user->partner_mgr.add_new_chip(32003,35,nt.chips);
        user->partner_mgr.add_new_chip(32075,25,nt.chips);

        auto rp_item1 = repo_mgr.item.get(32003);
        auto rp_item2 = repo_mgr.item.get(32075);
        fmail2(uid_, rank, rp_item1->name, 35, rp_item2->name, 25);
    }
    else if (11 <= rank && rank <= 20)
    {
        //32003 宙斯碎片*20
        //32075 赫拉碎片*20
        user->partner_mgr.add_new_chip(32003,20,nt.chips);
        user->partner_mgr.add_new_chip(32075,20,nt.chips);

        auto rp_item1 = repo_mgr.item.get(32003);
        auto rp_item2 = repo_mgr.item.get(32075);
        fmail2(uid_, rank, rp_item1->name, 20, rp_item2->name, 20);
    }
    else return 0;
    user->item_mgr.on_bag_change(nt);
    return 0;
}
void act_cumu_yb_rank_t::on_login(int uid_)
{
    sp_auser_t sp_auser = activity.get_user(uid_);
    if (sp_auser == NULL)
        return;
    if (!isopen() && sp_auser->cumu_yb_rank_exp > 0 && m_btime <= sp_auser->cumu_yb_rank_stamp && sp_auser->cumu_yb_rank_stamp <= m_etime)
    {
        reward_rank(sp_auser->uid, sp_auser->cumu_yb_rank);
        reward_cumu(sp_auser->uid, sp_auser->cumu_yb_rank_exp);
        sp_auser->set_cumu_yb_rank_exp(0);
        activity.save_user(sp_auser);
    }
}
//========================================

act_wing_t::act_wing_t()
{
    m_opened = false;
    m_savetime = SAVE_TIME;
}
void act_wing_t::load_db(vector<int32_t>& hostnums_)
{
    if (!isopen())
        return; 
        
    sql_result_t res;
    string sql = get_sql(hostnums_, "and con_wing_score > 0 order by con_wing_score desc limit 10;");
    db_service.sync_select(sql.c_str(), res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
            break;

        sp_auser_t sp_auser(new sc_auser_t);
        sp_auser->init(*res.get_row_at(i));
        if (activity.m_auser_map.find(sp_auser->uid) == activity.m_auser_map.end())
            activity.m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));

        sp_ri_t sp_ri(new sc_msg_def::jpk_wing_rank_t);
        sp_ri->uid=sp_auser->uid;
        sp_ri->nickname=sp_auser->nickname.c_str();
        sp_ri->grade=sp_auser->grade;
        sp_ri->score=sp_auser->con_wing_score;
        m_rank_list.push_back(sp_ri);
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);
        m_map.insert(make_pair(sp_ri->uid, vi));
    }

    if (m_rank_list.size()>1)
    {
        m_rank_list.sort([](const sp_ri_t& a_, const sp_ri_t& b_)->bool{
            return (a_->score > b_->score);
        });
    }
}
void act_wing_t::on_reload_repo()
{
    if (activity.get_repo(e_act_wing, m_btime, m_etime))
        return;

    m_btime = date_helper.trans_unixstamp(m_btime);
    m_etime = date_helper.trans_unixstamp(m_etime);
    uint32_t now = date_helper.cur_sec();
    m_opened = (m_btime <= now && now <= m_etime);
}
int act_wing_t::on_gacha(int uid_, int num_)
{
    if (!isopen())
        return ERROR_SC_ILLEGLE_REQ;

    if (num_ <= 0)
        return ERROR_SC_ILLEGLE_REQ;

    sp_auser_t sp_auser = activity.get_user(uid_);
    if (sp_auser == NULL)
    {
        logerror((LOG, "on_gacha no user:%u", uid_));
        return ERROR_SC_EXCEPTION;
    }

    sp_user_t user;
    if (!logic.usermgr().get(uid_, user))
        return ERROR_SC_EXCEPTION;

    int needyb = num_*120;
    if (user->rmb() < needyb)
        return ERROR_SC_NO_YB;

    user->consume_yb(needyb);
    user->save_db();

    auto f = []()->int{
        typedef std::pair<int, int> reco_t;
        std::vector<reco_t> reco;
        for(auto it=repo_mgr.wing_act.begin(); it!=repo_mgr.wing_act.end(); it++)
        {
            reco.push_back(std::make_pair(it->second.location, it->second.prob));
        }
        std::sort(reco.begin(), reco.end(), [](const reco_t& a_, const reco_t b_){ 
            return a_.second < b_.second;
        });
        int r = random_t::rand_integer(1, 10000);
        int p = 0;
        for(size_t i=0; i<reco.size();++i)
        {
            p += reco[i].second;
            if (r<=p)
                return reco[i].first;
        }
        return 0;
    };

    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::ret_gacha_wing_t ret;
    ret.code = SUCCESS;
    for(int i=0; i<num_; i++)
    {
        int location = f();
        auto rp_wing_act = repo_mgr.wing_act.get(location);
        if (rp_wing_act == NULL)
            continue;

        sc_msg_def::jpk_gacha_res_t jpk;
        jpk.pos = location;
        jpk.res_id = rp_wing_act->item;
        jpk.res_num = rp_wing_act->quantity; 
        if (!IS_REPO_ARRAY_EMPTY(rp_wing_act->genpro)){
            if (sp_auser->wingnum <= 0)
            {
                sp_auser->wingnum = 10;
                int p=0;
                int r = random_t::rand_integer(1, 10000);
                for(size_t i=1; i<rp_wing_act->genpro.size();++i)
                {
                    p += rp_wing_act->genpro[i];
                    if (r<=p)
                    {
                        jpk.res_id += i;
                        break;
                    }
                }
            }
            else
            {
                location++;
                rp_wing_act = repo_mgr.wing_act.get(location);
                if (rp_wing_act == NULL)
                    continue;
                jpk.pos = location;
                jpk.res_id = rp_wing_act->item;
                jpk.res_num = rp_wing_act->quantity; 
            }
        }
        sp_auser->wingnum--;
        ret.gacha_res.push_back(std::move(jpk));
        user->item_mgr.addnew(jpk.res_id,jpk.res_num,nt);
    }
    user->item_mgr.on_bag_change(nt);
    logic.unicast(uid_, ret);

    //判断当前活动是否需要被重置
    if (sp_auser->con_wing_stamp < m_btime)
        sp_auser->set_con_wing_score(num_ * 10);
    else
        sp_auser->set_con_wing_score(sp_auser->con_wing_score + num_ * 10);
    sp_auser->set_con_wing_stamp(date_helper.cur_sec());
    activity.save_user(sp_auser);

    //如果当前用户的积分额比10名小则不进入排名榜
    if (m_rank_list.size() >= 10 && sp_auser->con_wing_score < (*m_rank_list.rbegin())->score)
        return SUCCESS;

    auto it_found = m_map.find(uid_);
    if (it_found == m_map.end())
    {
        sp_ri_t sp_ri(new sc_msg_def::jpk_wing_rank_t);
        sp_ri->uid=(int)sp_auser->uid;
        sp_ri->nickname=sp_auser->nickname.c_str();
        sp_ri->grade=sp_auser->grade;
        sp_ri->score=sp_auser->con_wing_score;
        m_rank_list.push_back(sp_ri);
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);
        m_map.insert(make_pair(sp_ri->uid, vi));
    }
    else
    {
        (*(it_found->second))->score = sp_auser->con_wing_score;
    }

    m_rank_list.sort([](const sp_ri_t& a_, const sp_ri_t& b_)->bool{
        return (a_->score > b_->score);
    });

    //如果超出10名，则移除最后一名, 并将其rank置为0
    if (m_rank_list.size()>10)
    {
        auto vi = m_rank_list.begin();
        std::advance(vi, m_rank_list.size()-1);

        auto sp_auser = activity.get_user((*vi)->uid);

        m_map.erase((*vi)->uid);
        m_rank_list.erase(vi);

        sp_auser->set_con_wing_rank(0);
        activity.save_user(sp_auser);
    }
    return SUCCESS;
}
void act_wing_t::unicast(int uid_)
{
    sp_auser_t sp_auser = activity.get_user(uid_);
    //通知消费排行榜
    sc_msg_def::ret_wing_rank_t  ret;
    ret.con_wing = (sp_auser->con_wing_given & 1);
    ret.con_wing_score = sp_auser->con_wing_score;

    for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
    {
        sp_auser = activity.get_user((*it)->uid);
        if (sp_auser != NULL)
        {
            (*it)->nickname = sp_auser->nickname.c_str();
            (*it)->grade = sp_auser->grade;
        }
        ret.wing_rank.push_back(*(*it));
    }
    logic.unicast(uid_, ret);
}
void act_wing_t::check_time()
{
    if (isopen())
        return;
    if (activity.get_repo(e_act_wing, m_btime, m_etime))
        return;
    m_btime = date_helper.trans_unixstamp(m_btime);
    m_etime = date_helper.trans_unixstamp(m_etime);
    uint32_t now = date_helper.cur_sec();
    if (m_btime <= now && now <= m_etime)
        m_opened  = true;
}
void act_wing_t::update()
{
    check_time();
    if (!isopen())
        return; 

    //定时保存排名
    if (isopen())
    {
        m_savetime--;
        if (m_savetime <= 0)
        {
            m_savetime = SAVE_TIME;
            int rank=0; 
            for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
            {
                int uid = (*it)->uid;
                sp_auser_t sp_auser = activity.get_user(uid);
                if (sp_auser == NULL)
                    continue;
                rank++;
                sp_auser->set_con_wing_rank(rank);
                activity.save_user(sp_auser);
            }
        }
    }

    //在活动开启但当前时间超过结束时间,则进行奖励发放
    if (isopen() && (date_helper.cur_sec() > m_etime))
    {
        m_opened = false;

        //排名奖励
        int rank=0; 
        for(auto it=m_rank_list.begin(); it!=m_rank_list.end(); it++)
        {
            int uid = (*it)->uid;
            sp_auser_t sp_auser = activity.get_user(uid);
            if (sp_auser == NULL)
                continue;
            rank++;
            sp_auser->set_con_wing_rank(rank);
            on_reward(sp_auser);
        }
        //清除数据
        m_map.clear();
        m_rank_list.clear();
    }
}
void act_wing_t::on_reward(sp_auser_t sp_auser)
{
    sp_user_t user;
    if (!logic.usermgr().get(sp_auser->uid, user))
        return;

    if (!isopen() && sp_auser->con_wing_score > 0 && 
        m_btime <= sp_auser->con_wing_stamp && sp_auser->con_wing_stamp <= m_etime)
    {
        sc_msg_def::nt_bag_change_t nt;
        if ((sp_auser->con_wing_rank > 0) && (sp_auser->con_wing_given & (1<<1)) == 0)
        {
            int resid = 23053;
            if (sp_auser->con_wing_rank == 1)
            {
                sc_msg_def::jpk_item_t itm;
                itm.itid=0;
                itm.resid=resid;
                itm.num=1;
                nt.items.push_back(std::move(itm));
            }
            else 
            {
                resid = 23043;
                sc_msg_def::jpk_item_t itm;
                itm.itid=0;
                itm.resid=resid;
                itm.num=1;
                nt.items.push_back(std::move(itm));
            }

            auto rp_wing = repo_mgr.wing.get(resid);
            if (rp_wing != NULL)
            {
                string mail = mailinfo.new_mail(mail_act_wing_score, rp_wing->name, sp_auser->con_wing_rank); 
                auto rp_gmail = mailinfo.get_repo(mail_worldboss_rank);
                if (rp_gmail != NULL)
                    user->gmail.send(rp_gmail->title, rp_gmail->sender, mail, rp_gmail->validtime, nt.items); 
            }

            sp_auser->set_con_wing_given((1<<1)|sp_auser->con_wing_given);
        }
        if (sp_auser->con_wing_score >= 100 && (sp_auser->con_wing_given & 1) == 0)
        {
            user->item_mgr.addnew(23003,1,nt);
            auto rp_wing = repo_mgr.wing.get(23003);
            if (rp_wing != NULL)
            {
                string mail = mailinfo.new_mail(mail_act_wing_score, rp_wing->name); 
                if (!mail.empty())
                    notify_ctl.push_mail(sp_auser->uid, mail);
            }

            sp_auser->set_con_wing_given((1)|sp_auser->con_wing_given);
        }
        user->item_mgr.on_bag_change(nt);
        activity.save_user(sp_auser);
    }
}
int act_wing_t::given_score_wing(int uid_)
{
    sp_user_t user;
    if (!logic.usermgr().get(uid_, user))
        return ERROR_SC_EXCEPTION;

    sp_auser_t sp_auser = activity.get_user(uid_);
    if (sp_auser == NULL)
        return ERROR_SC_EXCEPTION;

    if (isopen() &&  
        m_btime <= sp_auser->con_wing_stamp && sp_auser->con_wing_stamp <= m_etime &&
        sp_auser->con_wing_score >= 100 &&
        (sp_auser->con_wing_given & 1) == 0)
    {
        sc_msg_def::nt_bag_change_t nt;
        user->item_mgr.addnew(23003,1,nt);
        user->item_mgr.on_bag_change(nt);
        sp_auser->set_con_wing_given((1)|sp_auser->con_wing_given);
        activity.save_user(sp_auser);
        return SUCCESS;
    }
    else return ERROR_SC_ILLEGLE_REQ;
}
//========================================

sc_activity_t::sc_activity_t()
{
    m_act_map[e_act_cumu_yb_rank] = new act_cumu_yb_rank_t;
    m_act_map[e_act_wing] = new act_wing_t;
}
sc_activity_t::~sc_activity_t()
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        if (it->second)
            delete it->second;
    }
    m_act_map.clear();
}
void sc_activity_t::load_db(vector<int32_t>& hostnums_)
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        it->second->load_db(hostnums_);
    }
}
void sc_activity_t::init_new_user(sc_user_t& user_)
{
    if (user_.db.utype > 0)
        return;
    sp_auser_t sp_auser(new sc_auser_t);
    memset(&(sp_auser->data()), 0, sizeof(db_Activity_t));
    sp_auser->uid = user_.db.uid;
    sp_auser->hostnum = sc_service.hostnum();
    sp_auser->grade = user_.db.grade;
    sp_auser->nickname = user_.db.nickname.c_str();
    m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));

    db_service.async_do((uint64_t)sp_auser->uid, [](sp_auser_t& sp_auser_){
        sp_auser_->insert();
    }, sp_auser);
}
void sc_activity_t::load_user(sc_user_t& user_)
{
    if (user_.db.utype > 0)
        return;
    sp_auser_t sp_auser(new sc_auser_t);
    sql_result_t res;
    if (0==db_Activity_ext_t::sync_select(user_.db.uid, res))
    {
        sp_auser->init(*res.get_row_at(0));
        m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));
    }
    else
    {
        sp_auser->uid = user_.db.uid;
        sp_auser->hostnum = sc_service.hostnum();
        sp_auser->grade = user_.db.grade;
        sp_auser->nickname = user_.db.nickname.c_str();
        sp_auser->cumu_yb_rank_exp = 0;
        sp_auser->cumu_yb_rank= 0;
        sp_auser->cumu_yb_rank_stamp= 0;
        m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));

        db_service.async_do((uint64_t)sp_auser->uid, [](sp_auser_t& sp_auser_){
                sp_auser_->insert();
        }, sp_auser);
        m_auser_map.insert(make_pair(sp_auser->uid, sp_auser));
    }
}
void sc_activity_t::save_user(sp_auser_t sp_auser_)
{
    string sql = sp_auser_->get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)sp_auser_->uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}
void sc_activity_t::on_reload_repo()
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        it->second->on_reload_repo();
    }
}
void sc_activity_t::on_login(int uid_)
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        it->second->on_login(uid_);
    }
}
void sc_activity_t::on_cumu_yb(int uid_, int yb_)
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        it->second->on_cumu_yb(uid_, yb_);
    }
}
void sc_activity_t::on_upgrade(int uid_, int lv_)
{
    auto it = m_auser_map.find(uid_);
    if (it != m_auser_map.end())
    {
        it->second->set_grade(lv_);
        save_user(it->second);
    }
}
void sc_activity_t::on_rename(int uid_, const string& name_)
{
    auto it = m_auser_map.find(uid_);
    if (it != m_auser_map.end())
    {
        it->second->set_nickname(name_);
        save_user(it->second);
    }
}
void sc_activity_t::unicast(int actid_, int uid_)
{
    auto it = m_act_map.find(actid_);
    if (it != m_act_map.end())
    {
        it->second->unicast(uid_);
    }
}
int sc_activity_t::get_repo(int actid_, uint32_t& btime_, uint32_t& etime_)
{
    int sid = sc_service.hostnum();
    if (config.get_domain() == "ios")
        sid += 10000;
    else if (config.get_domain() == "android")
        sid += 20000;
    else if (config.get_domain() == "appstore")
        sid += 30000;

    auto rp_act = repo_mgr.activity_cfg.get(sid);
    if (rp_act == NULL)
        return -1;
    for(size_t i=1; i<rp_act->actives.size(); i++)
    {
        if (rp_act->actives[i][0] == actid_)
        {
            btime_ = rp_act->actives[i][1];
            etime_ = rp_act->actives[i][2];
            return 0;
        }
    }
    return -1;
}
void sc_activity_t::update()
{
    for(auto it = m_act_map.begin(); it!=m_act_map.end(); it++)
    {
        it->second->update();
    }
}
sp_auser_t sc_activity_t::get_user(int uid_)
{
    auto it = m_auser_map.find(uid_);
    if (it != m_auser_map.end())
    {
        return it->second;
    }
    return sp_auser_t();
}
act_t* sc_activity_t::get_act(int type_)
{
    auto it = m_act_map.find(type_);
    if (it != m_act_map.end())
        return it->second;
    return NULL;
}
