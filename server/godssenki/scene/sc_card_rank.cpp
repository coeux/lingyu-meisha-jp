#include "sc_card_rank.h"
#include "sc_logic.h"
#include "date_helper.h"
#include "db_def.h"
#include "sc_rank.h"

#define LOG "SC_CARD_RANK"

sc_card_rank_t::sc_card_rank_t():timeStamp(0)
{
}

bool card_compare(sp_card_node_t a, sp_card_node_t b)
{
    if (a->starnum > b->starnum)
       return true;
    else if(a->starnum == b->starnum)
    {
        if(a->uid > b->uid)
            return true;
        else
            return false;
    }
    else
        return false; 
}

void sc_card_rank_t::update()
{
    if(((date_helper.secoffday() >= 21*3600) && (timeStamp < date_helper.cur_0_stmp())) || (timeStamp == 0))
    {
            
        logwarn((LOG, "update card rank begin..."));
        m_card_rank_list.clear();
        sql_result_t res;
        char buf[4096];
        
        string str_hosts;
        for (int32_t host : m_hosts)
        {
            str_hosts.append(std::to_string(host)+",");
        }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);

        sprintf(buf, "select UserInfo.uid,nickname,UserInfo.grade,fp, sum(Partner.quality) as starnum,viplevel from UserInfo inner join Partner on UserInfo.uid = Partner.uid and UserInfo.grade >= 10 and hostnum in (%s) group by UserInfo.uid order by starnum desc limit 105", str_hosts.c_str());  
        db_service.sync_select(buf, res); 
        for(size_t i=0; i<res.affect_row_num();i++)
        {
            if(res.get_row_at(i) == NULL)
            {
                logerror((LOG, "loda card rank get_row_at is NULL!!, at:%lu",i));   
                break;
            }
            sp_card_node_t sp_card_node(new sc_msg_def::jpk_card_rank_t);
            sql_result_row_t& row_ = *res.get_row_at(i);
            sp_card_node->uid = (int)std::atoi(row_[0].c_str());
            sp_card_node->nickname = row_[1];
            sp_card_node->level =(int)std::atoi(row_[2].c_str());
            sp_card_node->fp = (int)std::atoi(row_[3].c_str());
            sp_card_node->starnum = (int)std::atoi(row_[4].c_str());
            sp_card_node->vip = (int)std::atoi(row_[5].c_str());
            /*db_Partner_t db;
            sql_result_t cardres;
            db.sync_select_partner(sp_card_node->uid, cardres);
            for(size_t j=0;j<cardres.affect_row_num();j++)
            {
                if(cardres.get_row_at(j) == NULL)
                    break;
                dbPartner.init(*cardres.get_row_at(j));
                sp_card_node->starnum = dbPartner.quality + sp_card_node->starnum + 1;    
            } */
            m_card_rank_list.push_back(sp_card_node);
        }
        timeStamp = date_helper.cur_sec();
        if( !m_card_rank_list.empty())
        {
            //m_card_rank_list.sort(card_compare);
            update_rank_info();
        }
        logwarn((LOG, "update card rank end..."));
   }    
}

void sc_card_rank_t::unicast_card_rank(int32_t uid_)
{
    sc_msg_def::ret_card_rank_t ret;
    auto it_list = m_card_rank_list.begin();
    int n = 0;
    for (n= 0; it_list != m_card_rank_list.end() && n< 100;n++)
    {
        ret.users.push_back(*(*it_list));
        ++it_list;
    }
    m_card_rank_list_str.clear();
    ret >> m_card_rank_list_str;
    logic.unicast( uid_, sc_msg_def::ret_card_rank_t::cmd(), m_card_rank_list_str);
}
void sc_card_rank_t::update_rank_info()
{       
    auto it_list = m_card_rank_list.begin();
    int n = 0;
    while( ( it_list != m_card_rank_list.end() ) && ( n != 5 ) )
    {
        if ( n == 0 )
        {
            rank_ins.update_rank_infos((*it_list)->uid, card_top, n + 1);
        }
        else
        {
            rank_ins.update_rank_infos((*it_list)->uid, card_five, n + 1);
        } 
        ++it_list;
        ++n;
    }
}
