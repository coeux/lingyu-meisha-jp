#include "sc_pub_rank.h"
#include "sc_mailinfo.h"
#include "sc_server.h"
#include "sc_logic.h"
#include "sc_user.h"
#include "date_helper.h"
#include "sc_rank.h"

#define LOG "SC_PUB_RANK"

#define N_PUB_RANK 20

sc_pub_rank_t::sc_pub_rank_t():m_pub_uid(0), m_pub_cut(0),m_pub_serize_tm(0),issend(false)
{
}

bool pub_compare(sp_pub_node_t a, sp_pub_node_t b)
{
    if( a->count > b->count )
        return true;
    else if( a->count == b->count )
    {
        if( a->lv > b->lv )
            return true;
        else if ( a->lv == b->lv )
            return a->uid < b->uid;
        else
            return false;
    }
    else
        return false;
}

void sc_pub_rank_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load pub rank ..."));

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char sql[256];
    sql_result_t res;
    strcpy(db_sql, str_hosts.c_str());
    sprintf(sql, "select a.uid,a.nickname,a.grade,a.fp,a.viplevel,b.limit_pub from UserInfo as a inner join RewardExtentionI b on a.uid = b.uid and a.hostnum in (%s) order by b.limit_pub desc limit 20", str_hosts.c_str());
    db_service.sync_select(sql, res);
    //没有数据
    if (0 == res.affect_row_num())    //没有找到
        return;
     
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load pub rank get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sp_pub_node_t sp_pub_node(new sc_msg_def::jpk_pub_node_t);

        sql_result_row_t& row_ = *res.get_row_at(i);
        sp_pub_node->uid=(int)std::atoi(row_[0].c_str());
        sp_pub_node->nickname=row_[1];
        sp_pub_node->lv=(int)std::atoi(row_[2].c_str());
        sp_pub_node->fp=(int)std::atoi(row_[3].c_str());
        sp_pub_node->vip = (int)std::atoi(row_[4].c_str());
        sp_pub_node->count = (int)std::atoi(row_[5].c_str());

        m_pub_rank_list.push_back( sp_pub_node );
        m_uid_pub_hm.insert( make_pair(sp_pub_node->uid,sp_pub_node) );
    }

    if (!m_pub_rank_list.empty())
    {
        m_pub_rank_list.sort(pub_compare);
        m_pub_cut = (*(m_pub_rank_list.rbegin()))->count;
        m_pub_uid = (*(m_pub_rank_list.rbegin()))->uid;
    }
    else m_pub_cut = 0;
}

void sc_pub_rank_t::update_pub(int32_t pubcount_)
{
    if(m_pub_cut <= pubcount_) 
    {
        logwarn((LOG, "update pub rank ..."));
        m_uid_pub_hm.clear();
        m_pub_rank_list.clear();
        char sql[256];
        sql_result_t res;

        sprintf(sql, "select a.uid,a.nickname,a.grade,a.fp,a.viplevel,b.limit_pub from UserInfo as a inner join RewardExtentionI b on a.uid = b.uid and a.hostnum in (%s) order by b.limit_pub desc limit 20",db_sql);
        db_service.sync_select(sql, res);

        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "load pub rank get_row_at is NULL!!, at:%lu", i));
                break;
            }

            sp_pub_node_t sp_pub_node(new sc_msg_def::jpk_pub_node_t);

            sql_result_row_t& row_ = *res.get_row_at(i);
            sp_pub_node->uid=(int)std::atoi(row_[0].c_str());
            sp_pub_node->nickname=row_[1];
            sp_pub_node->lv=(int)std::atoi(row_[2].c_str());
            sp_pub_node->fp=(int)std::atoi(row_[3].c_str());
            sp_pub_node->vip = (int)std::atoi(row_[4].c_str());
            sp_pub_node->count = (int)std::atoi(row_[5].c_str());
            m_pub_rank_list.push_back( sp_pub_node );
            m_uid_pub_hm.insert( make_pair(sp_pub_node->uid,sp_pub_node) );
            logerror((LOG, "pub rand update : randnum = %lu, uid = %d", i, sp_pub_node->count)); 
        }

        if (!m_pub_rank_list.empty())
        {
            m_pub_rank_list.sort(pub_compare);
            m_pub_cut = (*(m_pub_rank_list.rbegin()))->count;
            m_pub_uid = (*(m_pub_rank_list.rbegin()))->uid;
        }
        else m_pub_cut = 0;
        m_pub_serize_tm = date_helper.cur_sec(); 
        logwarn((LOG, "update pub rank end..."));
    }
}

void sc_pub_rank_t::unicast_pub_rank(int32_t uid_)
{
    sc_msg_def::ret_pub_rank_t ret;
    auto it_list = m_pub_rank_list.begin();
    int n = 0;
    while( ( it_list != m_pub_rank_list.end() ) && ( n != N_PUB_RANK ) )
    {
        ret.users.push_back( *(*it_list) );
        ++it_list;
        ++n;
    }

    m_pub_ranks_str.clear();
    ret >> m_pub_ranks_str;
    logic.unicast( uid_, sc_msg_def::ret_pub_rank_t::cmd(), m_pub_ranks_str );
}

void sc_pub_rank_t::send_reward()
{
    //jp
    return ;
    if(date_helper.cur_sec() >= server.db.ctime + 3 * 3600 * 24 && date_helper.cur_sec() <= server.db.ctime + 3 * 3600 * 24 + 10 && !issend)
    {
        issend = true;
        
        char sql_user[256];
        sql_result_t res_user;

        sprintf(sql_user, "select a.uid,b.limit_pub from UserInfo as a inner join RewardExtentionI b on a.uid = b.uid and a.hostnum in (%s) order by b.limit_pub desc limit 20",db_sql);
        db_service.sync_select(sql_user, res_user);
        for(size_t i = 0; i < res_user.affect_row_num(); ++i)
        {
            if(res_user.get_row_at(i) == NULL)
            {
                logerror((LOG, "get row is NULL!, pub limit reward at:%lu",i));
                break;
            }
            if(i > 9)
                break;

            sql_result_row_t& row_ = *res_user.get_row_at(i);
            int32_t uid = (int32_t)std::atoi(row_[0].c_str());
            int32_t pubcount = (int32_t)std::atoi(row_[1].c_str());
            if(pubcount < 60)
                continue;
            sc_gmail_mgr_t::begin_offmail();
            for(int32_t index = 1; index <= 10; index++)
            {
                repo_def::newly_reward_t* publimit_pub_info = repo_mgr.newly_reward.get(900 + index);
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
                        auto rp_gmail = mailinfo.get_repo(mail_pub_rank);

                        if (rp_gmail != NULL)
                        {
                             string msg = mailinfo.new_mail(mail_pub_rank, i + 1);
                             sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                             break;
                        }
                    }
                }
            }
            sc_gmail_mgr_t::do_offmail();
        }
    }
}
