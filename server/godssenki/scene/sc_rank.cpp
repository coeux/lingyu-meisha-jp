#include "sc_rank.h"
#include "config.h"
#include "date_helper.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "db_service.h"
#include "code_def.h"

#define LOG "SC_FRIEND_FLOWER"
#define ONE_HOUR 360

void sc_rank_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load rank ..."));

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    char sql[256];
    sql_result_t res;
    strcpy(db_sql, str_hosts.c_str());
    sprintf(sql, "select id,hostnum,rankindex,ranknum,uid from Rank where hostnum in (%s);", str_hosts.c_str());
    db_service.sync_select(sql, res);

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load rank get_row_at is NULL!!, at:%lu", i));
            break;
        }

        db_Rank_t db_info;
        sql_result_row_t& row_ = *res.get_row_at(i);
        db_info.id=(int)std::atoi(row_[0].c_str());
        m_maxid.update(db_info.id);
        db_info.hostnum = (int)std::atoi(row_[1].c_str());
        db_info.rankindex = (int)std::atoi(row_[2].c_str());
        db_info.ranknum=(int)std::atoi(row_[3].c_str());
        db_info.uid=(int)std::atoi(row_[4].c_str());

        db_rank.insert( make_pair(db_info.id,db_info));
    }
}

int sc_rank_t::unicast_rank_infos(int32_t uid, vector<sc_msg_def::jpk_rank_t>& rankinfo)
{
    for(auto it = db_rank.begin();it != db_rank.end();it++)
    {
        if(it->second.uid == uid)
        {   
            sc_msg_def::jpk_rank_t info;
            info.uid = it->second.uid;
            info.rankindex = it->second.rankindex;
            info.ranknum = it->second.ranknum;
            rankinfo.push_back(info);
        }

    }
}

int sc_rank_t::update_rank_infos(int32_t uid, int rankindex, int ranknum)
{
    for(auto it = db_rank.begin();it != db_rank.end();it++)
    {
        if(it->second.rankindex == rankindex && it->second.ranknum == ranknum)
        {
            it->second.uid = uid;
            db_Rank_t dbRank;
            dbRank.id = it->second.id;
            dbRank.rankindex = it->second.rankindex;
            dbRank.ranknum = it->second.ranknum;
            dbRank.hostnum = it->second.hostnum;
            dbRank.uid = uid;
            db_service.async_do((uint64_t)dbRank.id, [](db_Rank_t& db_){
                db_.update();
        }, dbRank);          
            return 1;
        }
    }
    db_Rank_t dbRank;
    dbRank.rankindex = rankindex;
    dbRank.ranknum = ranknum;
    dbRank.hostnum = (int)config.serid;
    dbRank.uid = uid;
    char buf[4096];
    sprintf(buf, "INSERT INTO `Rank` ( `uid`  ,  `hostnum`  ,  `rankindex`  ,  `ranknum` ) VALUES ( %d , %d , %d , %d )" , uid, (int)config.serid, rankindex, ranknum);
    db_service.sync_execute(buf);

    sql_result_t res;
    char sql[256];
    sprintf(sql,"select max(id) from Rank where uid = %d;", uid);
    db_service.sync_select(sql, res);

    if(res.affect_row_num() == 0){
        dbRank.id = 1;
    }else{
        sql_result_row_t& row = *res.get_row_at(0);
        if(row.empty())
            dbRank.id = 1;
        else
            dbRank.id = (int64_t)atoi(row[0].c_str());
    }

    db_rank.insert( make_pair(dbRank.id,dbRank));
    return 1;

}

