#include "conf_db_def.h"
#include "db_service.h"

int db_Host_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;compo=(int)std::atoi(row_[i++].c_str());
    mid=(int)std::atoi(row_[i++].c_str());
    sername = row_[i++];
    id=(int)std::atoi(row_[i++].c_str());
    recom=(int)std::atoi(row_[i++].c_str());
    did=(int)std::atoi(row_[i++].c_str());
    hostid=(int)std::atoi(row_[i++].c_str());
    sertype=(int)std::atoi(row_[i++].c_str());
    return 0;
}
int db_Host_t::select(db_service_t& db_, int32_t did_, int32_t sertype_, int32_t hostid_, sql_result_t &res_){
    char buf[4096];
    sprintf(buf, "SELECT `compo` , `mid` , `sername` , `id` , `recom` , `did`, `hostid` , `sertype`  FROM `Host` WHERE  `did` = %d and `hostid`=%d and `sertype`=%d", did_, hostid_, sertype_);
    db_.sync_select(buf, res_);
    sql_result_row_t* row = res_.get_row_at(0); 
    if (row != NULL)
    {
        return 0;
    }
    return -1;
}
int db_Host_t::select_hosts(db_service_t& db_, int32_t did_,  int32_t sertype_, sql_result_t &res_)
{
    char buf[4096];
    sprintf(buf, "SELECT `compo` , `mid` , `sername` , `id` , `recom` , `did` , `hostid` , `sertype` FROM `Host` WHERE  `did` = %d and `sertype`=%d", did_, sertype_);
    db_.sync_select(buf, res_);
    sql_result_row_t* row = res_.get_row_at(0); 
    if (row != NULL)
    {
        return 0;
    }
    return -1;
}

int db_Machine_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
    type = (int)std::atoi(row_[i++].c_str());
    pubip = row_[i++];
    priip = row_[i++];
    return 0;
}
int db_Machine_t::select(db_service_t& db_, int32_t id_, sql_result_t &res_){
    char buf[4096];
    sprintf(buf, "SELECT `id` , `type`, `pubip` , `priip` FROM `Machine` WHERE  `id` = %d", id_);
    db_.sync_select(buf, res_);
    sql_result_row_t* row = res_.get_row_at(0); 
    if (row != NULL)
    {
        return 0;
    }
    return -1;
}
int db_Domain_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
    name = row_[i++];
    rid = (int)std::atoi(row_[i++].c_str());
    invid = (int)std::atoi(row_[i++].c_str());
    invdbid = (int)std::atoi(row_[i++].c_str());
    invdbport = (int)std::atoi(row_[i++].c_str());
    invdbname = row_[i++];
    dbid = (int)std::atoi(row_[i++].c_str());
    dbport = (int)std::atoi(row_[i++].c_str());
    dbname = row_[i++];
    return 0;
}
int db_Domain_t::select(db_service_t& db_, int32_t id_, sql_result_t &res_){
    char buf[4096];
    sprintf(buf, "SELECT `id` , `name`, `rid`, `invid`, `invdbid`, `invdbport`, `invdbname`, `dbid`, `dbport`, `dbname` FROM `Domain` WHERE  `id` = %d", id_);
    db_.sync_select(buf, res_);
    sql_result_row_t* row = res_.get_row_at(0); 
    if (row != NULL)
    {
        return 0;
    }
    return -1;
}
int db_Domain_t::select(db_service_t& db_, const string& domain_, sql_result_t &res_){
    char buf[4096];
    sprintf(buf, "SELECT `id` , `name`, `rid`, `invid`, `invdbid`, `invdbport`, `invdbname`, `dbid`, `dbport`, `dbname` FROM `Domain` WHERE  `name` = \"%s\"", domain_.c_str());
    db_.sync_select(buf, res_);
    sql_result_row_t* row = res_.get_row_at(0); 
    if (row != NULL)
    {
        return 0;
    }
    return -1;
}
