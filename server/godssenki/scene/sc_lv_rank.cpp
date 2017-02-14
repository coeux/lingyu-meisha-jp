#include "sc_lv_rank.h"
#include "sc_logic.h"
#include "sc_mailinfo.h"
#include "sc_server.h"
#include "sc_user.h"
#include "date_helper.h"
#include "sc_rank.h"

#define LOG "SC_LV_RANK"

#define N_LV_RANK 100
#define LV_SERIZE_INTERVAL 300

sc_lv_rank_t::sc_lv_rank_t():m_lv_cut(0),m_lv_serize_tm(0),issend(false)
{
}

bool lv_compare(sp_lv_node_t a, sp_lv_node_t b)
{
    if( a->lv > b->lv )
        return true;
    else if( a->lv == b->lv )
    {
        return a->exp > b->exp;
    }
    else
        return false;
}

void sc_lv_rank_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load lv rank ..."));

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char sql[256];
    sql_result_t res;
    strcpy(dbspl_strhost,str_hosts.c_str());
    sprintf(sql, "select uid,nickname,grade,exp,viplevel from UserInfo where hostnum in (%s) and utype=0 order by grade desc limit 100;", str_hosts.c_str());
    db_service.sync_select(sql, res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load lv rank get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sp_lv_node_t sp_lv_node(new sc_msg_def::jpk_lv_node_t);

        sql_result_row_t& row_ = *res.get_row_at(i);
        sp_lv_node->uid=(int)std::atoi(row_[0].c_str());
        sp_lv_node->nickname=row_[1];
        sp_lv_node->lv=(int)std::atoi(row_[2].c_str());
        sp_lv_node->exp=(int)std::atoi(row_[3].c_str());
        sp_lv_node->vip=(int)std::atoi(row_[4].c_str());

        m_lv_rank_list.push_back( sp_lv_node );
        m_uid_lv_hm.insert( make_pair(sp_lv_node->uid,sp_lv_node) );
    }

    if (!m_lv_rank_list.empty())
    {
        m_lv_rank_list.sort(lv_compare);
        update_rank_info();
        m_lv_cut = (*(m_lv_rank_list.rbegin()))->lv;
    }
    else m_lv_cut = 0;
}

void sc_lv_rank_t::update_lv()
{
    if ((date_helper.secoffday() >= 21* 3600) && (m_lv_serize_tm < date_helper.cur_0_stmp()))
    { 
        logwarn((LOG, "update lv rank begin..."));
        m_uid_lv_hm.clear();
        m_lv_rank_list.clear();
        char sql[256];
        sql_result_t res;
        sprintf(sql, "select uid,nickname,grade,exp,viplevel from UserInfo where hostnum in (%s) and utype=0 order by grade desc limit 100;", dbspl_strhost);
        db_service.sync_select(sql, res);

        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "load lv rank get_row_at is NULL!!, at:%lu", i));
                break;
            }

            sp_lv_node_t sp_lv_node(new sc_msg_def::jpk_lv_node_t);
    
            sql_result_row_t& row_ = *res.get_row_at(i);
            sp_lv_node->uid=(int)std::atoi(row_[0].c_str());
            sp_lv_node->nickname=row_[1];
            sp_lv_node->lv=(int)std::atoi(row_[2].c_str());
            sp_lv_node->exp=(int)std::atoi(row_[3].c_str());
            sp_lv_node->vip=(int)std::atoi(row_[4].c_str());
            logerror((LOG, "lv rand update : randnum = %lu, uid = %d", i, sp_lv_node->uid)); 

            m_lv_rank_list.push_back( sp_lv_node );
            m_uid_lv_hm.insert( make_pair(sp_lv_node->uid,sp_lv_node) );
        }

        if (!m_lv_rank_list.empty())
        {
            m_lv_rank_list.sort(lv_compare);
            update_rank_info();
            m_lv_cut = (*(m_lv_rank_list.rbegin()))->lv;
        }
        else m_lv_cut = 0;
        m_lv_serize_tm = date_helper.cur_sec();
        logwarn((LOG, "update lv rank end..."));
    }
}

void sc_lv_rank_t::unicast_lv_rank(int32_t uid_)
{
    sc_msg_def::ret_lv_rank_t ret;
    auto it_list = m_lv_rank_list.begin();
    while( it_list != m_lv_rank_list.end() )
    {
        ret.users.push_back( *(*it_list) );
        ++it_list;
    }

    m_lv_ranks_str.clear();
    ret >> m_lv_ranks_str;

    logic.unicast( uid_, sc_msg_def::ret_lv_rank_t::cmd(), m_lv_ranks_str );
}

void sc_lv_rank_t::update_rank_info()
{       
    auto it_list = m_lv_rank_list.begin();
    int n = 0;
    while( ( it_list != m_lv_rank_list.end() ) && ( n != 5 ) )
    {
        if ( n == 0 )
        {
            rank_ins.update_rank_infos((*it_list)->uid, level_top, n + 1);
        }
        else
        {
            rank_ins.update_rank_infos((*it_list)->uid, level_five, n + 1);
        } 
        ++it_list;
        ++n;
    }
}

void sc_lv_rank_t::send_reward()
{
    //jp
    return ;
    if(date_helper.cur_sec() >= server.db.ctime + 4 * 3600 * 24 + 21 * 3600 && date_helper.cur_sec() <= server.db.ctime + 4 * 3600 * 24 + 21 * 3600 + 10 && !issend)
    {
        issend = true;
        
        char sql_user[256];
        sql_result_t res_user;

        sprintf(sql_user, "select uid,nickname,grade,exp,viplevel from UserInfo where hostnum in (%s) and utype=0 order by grade desc limit 100;", dbspl_strhost);
        db_service.sync_select(sql_user, res_user);

        sc_gmail_mgr_t::begin_offmail();
        for(size_t i = 0; i < res_user.affect_row_num(); ++i)
        {
            if(res_user.get_row_at(i) == NULL)
            {
                logerror((LOG, "get row is NULL!, pub limit reward at:%lu",i));
                break;
            }
            if(i > 10)
                break;

            sql_result_row_t& row_ = *res_user.get_row_at(i);
            int32_t uid = (int32_t)std::atoi(row_[0].c_str());
            
            for(int32_t index = 1; index <= 10; index++)
            {
                repo_def::newly_reward_t* publimit_pub_info = repo_mgr.newly_reward.get(600 + index);
                if(publimit_pub_info != NULL)
                {
                    if(i + 1 <= publimit_pub_info->value)
                    {
                        sc_msg_def::nt_bag_change_t nt;
                        for(size_t itemindex = 1;itemindex < publimit_pub_info->reward.size();itemindex++)
                        {
                            sc_msg_def::jpk_item_t item_;
                            item_.itid = 0;
                            item_.resid = publimit_pub_info->reward[itemindex][0];
                            item_.num = publimit_pub_info->reward[itemindex][1];
                            nt.items.push_back(item_);
                        }
                        auto rp_gmail = mailinfo.get_repo(mail_lv_rank);

                        if (rp_gmail != NULL)
                        {
                             string msg = mailinfo.new_mail(mail_lv_rank, i + 1);
                             sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                             break;
                        }
                    }
                }
            }
        }
        sc_gmail_mgr_t::do_offmail();
    }
}
