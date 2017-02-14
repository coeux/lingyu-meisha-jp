#include "sc_union_rank.h"
#include "sc_mailinfo.h"
#include "sc_server.h"
#include "sc_logic.h"
#include "date_helper.h"
#include "db_def.h"
#include "sc_rank.h"

#define LOG "SC_UNION_CARD_RANK"
sc_union_rank_t::sc_union_rank_t():timeStamp(0),issend(false)
{
}
bool union_compare(sp_ganginfo_t a, sp_ganginfo_t b)
{
    if (a->allgm > b->allgm)
        return true;
    else if(a->allgm == b->allgm)
    {
        if(a->grade < b->grade)
            return true;
        else if( a->grade == b->grade)
            return a->ggid < b->ggid;
        else
            return false;
    }
    else
        return false;
}
void sc_union_rank_t::update()
{
    //if(date_helper.cur_sec() >= server.db.ctime + 6 * 3600 * 24 + 21 * 3600 && date_helper.cur_sec() <= server.db.ctime + 6 * 3600 * 24 + 21 * 3600 + 10 && !issend)
    if(((date_helper.secoffday() >= 21*3600) && (timeStamp < date_helper.cur_0_stmp() + 21*3600)) || (timeStamp == 0))
    {

        logwarn((LOG, "update union rank begin..."));
        m_union_rank_list.clear();
        db_GangUser_t dbGanguser;
        db_Gang_t   dbGang;

        string str_hosts;
        for (int32_t host : m_hosts)
        {
            str_hosts.append(std::to_string(host)+",");
        }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);

        sql_result_t userRes;
        char buf1[4096];
        sprintf(buf1, "SELECT `todaycount` , `flag` , `bossrewardcount` , `hostnum` , `totalgm` , `skl8` , `skl6` , `lastenter` , `nickname` , `lastquit` , `skl7` , `skl5` , `skl1` , `ggid` , `grade` , `skl2` , `lastboss` , `uid` , `skl4` , `skl3` , `bossrewardtime` ,`gm` , `state` , `rank` FROM `GangUser` WHERE  `hostnum` in (%s)", str_hosts.c_str());
        db_service.sync_select(buf1, userRes);
        //dbGanguser.sync_select_ganguser(sc_service.hostnum(), userRes);
        
        sql_result_t res;
        char buf2[4096];
        sprintf(buf2, "SELECT `todaycount`, `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `hostnum` in (%s) order by exp desc", str_hosts.c_str());
        db_service.sync_select(buf2, res);
        //dbGang.sync_select_host_gang(sc_service.hostnum(), res);
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            if(res.get_row_at(i) == NULL)
                break;
            db.init(*res.get_row_at(i));
            sp_ganginfo_t t(new sc_msg_def::jpk_ganginfo_t);
            t->ggid = db.ggid;
            t->name = db.name();
            t->grade = db.level;
            t->allgm = db.exp;
            for(size_t j=0; j<userRes.affect_row_num(); j++)
            {
                if(userRes.get_row_at(j) == NULL)
                    break;
                userdb.init(*userRes.get_row_at(j));
                if(userdb.ggid == db.ggid && userdb.flag == 2)
                {
                    t->leadername = userdb.nickname();
                    //jp
                    /*
                    if(date_helper.cur_sec() >= server.db.ctime + 6 * 3600 * 24 + 21 * 3600 && date_helper.cur_sec() <= server.db.ctime + 6 * 3600 * 24 + 21 * 3600 + 10 && !issend)
                    {
                        issend = true;
                        sc_gmail_mgr_t::begin_offmail();
                        repo_def::newly_reward_t* publimit_pub_info = repo_mgr.newly_reward.get(700 + 1);
                        if(publimit_pub_info != NULL)
                        {
                            sc_msg_def::nt_bag_change_t nt;
                            sc_msg_def::jpk_item_t item_;
                            item_.itid = 0;
                            item_.resid = publimit_pub_info->reward[1][0];
                            item_.num = publimit_pub_info->reward[1][1];
                            nt.items.push_back(item_);
                                
                            auto rp_gmail = mailinfo.get_repo(mail_gang_rank);

                            if (rp_gmail != NULL)
                            {
                                 string msg = mailinfo.new_mail(mail_gang_rank);
                                 sc_gmail_mgr_t::add_offmail(userdb.uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);

                                 string msginfo = mailinfo.new_mail(mail_gang_info);
                                 sc_msg_def::nt_bag_change_t nt1;
                                 sc_gmail_mgr_t::add_offmail(userdb.uid, rp_gmail->title, rp_gmail->sender, msginfo, rp_gmail->validtime, nt1.items, 0);
                            }
                        }
                        sc_gmail_mgr_t::do_offmail();
                    }
                    */
                }       
            }
            logwarn((LOG, "union rank update: ggid = %d, name = %s, ranknum = %lu", t->ggid, t->name.c_str(), i));
            m_union_rank_list.push_back( t );
        }
        timeStamp = date_helper.cur_sec();
    
        if( !m_union_rank_list.empty())
        {
            m_union_rank_list.sort(union_compare);
            update_rank_info();
        }

        logwarn((LOG, "update union rank end..."));
    }
}

void sc_union_rank_t::unicast_union_rank(int32_t uid_)
{
    sc_msg_def::ret_union_rank_t ret;
    auto it_list = m_union_rank_list.begin();
    int n = 0;
    for (n = 0; it_list != m_union_rank_list.end() && n<10;n++)
    {
        ret.users.push_back(*(*it_list));
        ++it_list;
    }
    m_union_rank_list_str.clear();
    ret >> m_union_rank_list_str;
    logic.unicast( uid_, sc_msg_def::ret_union_rank_t::cmd(), m_union_rank_list_str );
}

void sc_union_rank_t::update_rank_info()
{       
    auto it_list = m_union_rank_list.begin();
    int n = 0;
    while( ( it_list != m_union_rank_list.end() ) && ( n != 5 ) )
    {
        char sql[256];
        sql_result_t res;
        string str_hosts;
        for (int32_t host : m_hosts)
        {
            str_hosts.append(std::to_string(host)+",");
        }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);
        sprintf(sql, "select uid,ggid,flag  from GangUser where hostnum in (%s);",str_hosts.c_str());
        db_service.sync_select(sql, res);
        int uid = 0;
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            if(res.get_row_at(i) == NULL)
                break;
            sql_result_row_t& row_ = *res.get_row_at(i);
            if ((*it_list)->ggid == (int)std::atoi(row_[1].c_str()) && (int)std::atoi(row_[2].c_str()) == 2)
            {
                uid = (int)std::atoi(row_[0].c_str());
                break;
            }
        }

        if ( n == 0 )
        {
            rank_ins.update_rank_infos(uid, gang_top, n + 1);
        }
        ++it_list;
        ++n;
    }
}
