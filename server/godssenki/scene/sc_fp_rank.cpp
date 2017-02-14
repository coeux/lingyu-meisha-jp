#include "sc_fp_rank.h"
#include "sc_logic.h"
#include "sc_user.h"
#include "date_helper.h"
#include "sc_rank.h"

#define LOG "SC_RANK"

#define N_FP_RANK 100
#define SERIZE_INTERVAL 60

sc_fp_rank_t::sc_fp_rank_t():m_fp_uid(0), m_fp_cut(0),m_fp_serize_tm(0)
{
}

bool fp_compare(sp_fp_node_t a, sp_fp_node_t b)
{
    if( a->fp > b->fp )
        return true;
    else if( a->fp == b->fp )
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

void sc_fp_rank_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load fp rank ..."));

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char sql[256];
    sql_result_t res;
    strcpy(db_sql, str_hosts.c_str());
    sprintf(sql, "select uid,nickname,grade,fp,viplevel from UserInfo where hostnum in (%s) and utype=0 order by fp desc limit 200;", str_hosts.c_str());
    db_service.sync_select(sql, res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load fp rank get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sp_fp_node_t sp_fp_node(new sc_msg_def::jpk_fp_node_t);

        sql_result_row_t& row_ = *res.get_row_at(i);
        sp_fp_node->uid=(int)std::atoi(row_[0].c_str());
        sp_fp_node->nickname=row_[1];
        sp_fp_node->lv=(int)std::atoi(row_[2].c_str());
        sp_fp_node->fp=(int)std::atoi(row_[3].c_str());
        sp_fp_node->vip = (int)std::atoi(row_[4].c_str());

        m_fp_rank_list.push_back( sp_fp_node );
        m_uid_fp_hm.insert( make_pair(sp_fp_node->uid,sp_fp_node) );
    }

    if (!m_fp_rank_list.empty())
    {
        m_fp_rank_list.sort(fp_compare);
        m_fp_cut = (*(m_fp_rank_list.rbegin()))->fp;
        m_fp_uid = (*(m_fp_rank_list.rbegin()))->uid;
        update_rank_info();
    }
    else m_fp_cut = 0;
}

void sc_fp_rank_t::update_fp()
{
    if((date_helper.secoffday() >= 21 * 3600) && (m_fp_serize_tm < date_helper.cur_0_stmp())) 
    {

        logwarn((LOG, "update fp rank ..."));
        m_uid_fp_hm.clear();
        m_fp_rank_list.clear();
        char sql[256];
        sql_result_t res;
        sprintf(sql, "select uid,nickname,grade,fp,viplevel from UserInfo where hostnum in (%s) and utype=0 order by fp desc limit 200;", db_sql);
        db_service.sync_select(sql, res);

        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "load fp rank get_row_at is NULL!!, at:%lu", i));
                break;
            }

            sp_fp_node_t sp_fp_node(new sc_msg_def::jpk_fp_node_t);

            sql_result_row_t& row_ = *res.get_row_at(i);
            sp_fp_node->uid=(int)std::atoi(row_[0].c_str());
            sp_fp_node->nickname=row_[1];
            sp_fp_node->lv=(int)std::atoi(row_[2].c_str());
            sp_fp_node->fp=(int)std::atoi(row_[3].c_str());
            sp_fp_node->vip = (int)std::atoi(row_[4].c_str());
            m_fp_rank_list.push_back( sp_fp_node );
            m_uid_fp_hm.insert( make_pair(sp_fp_node->uid,sp_fp_node) );
            logerror((LOG, "fp rand update : randnum = %lu, uid = %d", i, sp_fp_node->uid)); 
        }

        if (!m_fp_rank_list.empty())
        {
            m_fp_rank_list.sort(fp_compare);
            m_fp_cut = (*(m_fp_rank_list.rbegin()))->fp;
            m_fp_uid = (*(m_fp_rank_list.rbegin()))->uid;
            update_rank_info();
        }
        else m_fp_cut = 0;
        m_fp_serize_tm = date_helper.cur_sec(); 
        logwarn((LOG, "update fp rank end..."));
    }
}
void sc_fp_rank_t::unicast_fp_rank(int32_t uid_)
{
    sc_msg_def::ret_fp_rank_t ret;
    auto it_list = m_fp_rank_list.begin();
    int n = 0;
    while( ( it_list != m_fp_rank_list.end() ) && ( n != N_FP_RANK ) )
    {
        ret.users.push_back( *(*it_list) );
        ++it_list;
        ++n;
    }

    m_fp_ranks_str.clear();
    ret >> m_fp_ranks_str;
    logic.unicast( uid_, sc_msg_def::ret_fp_rank_t::cmd(), m_fp_ranks_str );
}

void sc_fp_rank_t::update_rank_info()
{       
    auto it_list = m_fp_rank_list.begin();
    int n = 0;
    while( ( it_list != m_fp_rank_list.end() ) && ( n != 5 ) )
    {
        if ( n == 0 )
        {
            rank_ins.update_rank_infos((*it_list)->uid, fight_top, n + 1);
        }
        else
        {
            rank_ins.update_rank_infos((*it_list)->uid, fight_five, n + 1);
        } 
        ++it_list;
        ++n;
    }
}
