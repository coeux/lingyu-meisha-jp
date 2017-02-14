#include "db_def.h"
#include "db_service.h"
int db_ActDailyTask_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
collect=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ActDailyTask_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `resid` , `step` , `collect` FROM `ActDailyTask` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ActDailyTask_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `resid` , `step` , `collect` FROM `ActDailyTask` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ActDailyTask_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ActDailyTask` SET  `stamp` = %u ,  `step` = %d ,  `collect` = %d WHERE  `uid` = %d AND  `resid` = %d", stamp, step, collect, uid, resid);
return db_service.async_execute(buf);
}
int db_ActDailyTask_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ActDailyTask` SET  `stamp` = %u ,  `step` = %d ,  `collect` = %d WHERE  `uid` = %d AND  `resid` = %d", stamp, step, collect, uid, resid);
return db_service.sync_execute(buf);
}
int db_ActDailyTask_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `ActDailyTask` WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return db_service.async_execute(buf);
}
string db_ActDailyTask_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ActDailyTask` ( `uid`  ,  `stamp`  ,  `resid`  ,  `step`  ,  `collect` ) VALUES ( %d , %u , %d , %d , %d )" , uid, stamp, resid, step, collect);
return string(buf);
}
int db_ActDailyTask_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ActDailyTask` ( `uid`  ,  `stamp`  ,  `resid`  ,  `step`  ,  `collect` ) VALUES ( %d , %u , %d , %d , %d )" , uid, stamp, resid, step, collect);
return db_service.async_execute(buf);
}
int db_ActDailyTask_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ActDailyTask` ( `uid`  ,  `stamp`  ,  `resid`  ,  `step`  ,  `collect` ) VALUES ( %d , %u , %d , %d , %d )" , uid, stamp, resid, step, collect);
return db_service.sync_execute(buf);
}
int db_CardEventUserLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;score=(int)std::atoi(row_[i++].c_str());
goal_level=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
season=(int)std::atoi(row_[i++].c_str());
round=(int)std::atoi(row_[i++].c_str());
hp5=(float)std::atof(row_[i++].c_str());
hp4=(float)std::atof(row_[i++].c_str());
anger=(int)std::atoi(row_[i++].c_str());
hp3=(float)std::atof(row_[i++].c_str());
coin=(int)std::atoi(row_[i++].c_str());
round_status=(int)std::atoi(row_[i++].c_str());
hp2=(float)std::atof(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
enemy_view_data = row_[i++];
pid5=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
round_max=(int)std::atoi(row_[i++].c_str());
difficult=(int)std::atoi(row_[i++].c_str());
reset_time=(int)std::atoi(row_[i++].c_str());
hp1=(float)std::atof(row_[i++].c_str());
return 0;
}
string db_CardEventUserLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserLog` ( `score`  ,  `goal_level`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `round_status`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, hostnum, season, round, hp5, hp4, anger, hp3, coin, round_status, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return string(buf);
}
int db_CardEventUserLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserLog` ( `score`  ,  `goal_level`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `round_status`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, hostnum, season, round, hp5, hp4, anger, hp3, coin, round_status, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return db_service.async_execute(buf);
}
int db_CardEventUserLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserLog` ( `score`  ,  `goal_level`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `round_status`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, hostnum, season, round, hp5, hp4, anger, hp3, coin, round_status, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return db_service.sync_execute(buf);
}
int db_Treasure_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
utime=(int)std::atoi(row_[i++].c_str());
reset_num=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Treasure_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `utime` , `reset_num` FROM `Treasure` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Treasure_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `utime` , `reset_num` FROM `Treasure` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Treasure_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Treasure` SET  `utime` = %d ,  `reset_num` = %d WHERE  `uid` = %d", utime, reset_num, uid);
return db_service.async_execute(buf);
}
int db_Treasure_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Treasure` SET  `utime` = %d ,  `reset_num` = %d WHERE  `uid` = %d", utime, reset_num, uid);
return db_service.sync_execute(buf);
}
string db_Treasure_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Treasure` ( `uid`  ,  `utime`  ,  `reset_num` ) VALUES ( %d , %d , %d )" , uid, utime, reset_num);
return string(buf);
}
int db_Treasure_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Treasure` ( `uid`  ,  `utime`  ,  `reset_num` ) VALUES ( %d , %d , %d )" , uid, utime, reset_num);
return db_service.async_execute(buf);
}
int db_Treasure_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Treasure` ( `uid`  ,  `utime`  ,  `reset_num` ) VALUES ( %d , %d , %d )" , uid, utime, reset_num);
return db_service.sync_execute(buf);
}
int db_CardEventUserPartner_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
hp=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_CardEventUserPartner_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `CardEventUserPartner` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventUserPartner_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `CardEventUserPartner` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventUserPartner_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventUserPartner` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.async_execute(buf);
}
int db_CardEventUserPartner_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventUserPartner` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.sync_execute(buf);
}
string db_CardEventUserPartner_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserPartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return string(buf);
}
int db_CardEventUserPartner_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserPartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.async_execute(buf);
}
int db_CardEventUserPartner_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUserPartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.sync_execute(buf);
}
int db_Star_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
value=(int)std::atoi(row_[i++].c_str());
lv=(int)std::atoi(row_[i++].c_str());
att=(int)std::atoi(row_[i++].c_str());
pos=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Star_t::select_star(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `value` , `lv` , `att` , `pos` FROM `Star` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Star_t::sync_select_star(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `value` , `lv` , `att` , `pos` FROM `Star` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Star_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Star` SET  `value` = %d ,  `att` = %d WHERE  `uid` = %d AND  `pid` = %d AND  `lv` = %d AND  `pos` = %d", value, att, uid, pid, lv, pos);
return db_service.async_execute(buf);
}
int db_Star_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Star` SET  `value` = %d ,  `att` = %d WHERE  `uid` = %d AND  `pid` = %d AND  `lv` = %d AND  `pos` = %d", value, att, uid, pid, lv, pos);
return db_service.sync_execute(buf);
}
string db_Star_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Star` ( `uid`  ,  `pid`  ,  `value`  ,  `lv`  ,  `att`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, value, lv, att, pos);
return string(buf);
}
int db_Star_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Star` ( `uid`  ,  `pid`  ,  `value`  ,  `lv`  ,  `att`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, value, lv, att, pos);
return db_service.async_execute(buf);
}
int db_Star_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Star` ( `uid`  ,  `pid`  ,  `value`  ,  `lv`  ,  `att`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, value, lv, att, pos);
return db_service.sync_execute(buf);
}
int db_ChipShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;buystamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ChipShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `ChipShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `ChipShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.async_execute(buf);
}
int db_ChipShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.sync_execute(buf);
}
string db_ChipShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return string(buf);
}
int db_ChipShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.async_execute(buf);
}
int db_ChipShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.sync_execute(buf);
}
int db_Vip_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;stamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
vop=(int)std::atoi(row_[i++].c_str());
num=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Vip_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `stamp` , `uid` , `vop` , `num` FROM `Vip` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Vip_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `stamp` , `uid` , `vop` , `num` FROM `Vip` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Vip_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Vip` SET  `stamp` = %u ,  `num` = %d WHERE  `uid` = %d AND  `vop` = %d", stamp, num, uid, vop);
return db_service.async_execute(buf);
}
int db_Vip_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Vip` SET  `stamp` = %u ,  `num` = %d WHERE  `uid` = %d AND  `vop` = %d", stamp, num, uid, vop);
return db_service.sync_execute(buf);
}
string db_Vip_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Vip` ( `stamp`  ,  `uid`  ,  `vop`  ,  `num` ) VALUES ( %u , %d , %d , %d )" , stamp, uid, vop, num);
return string(buf);
}
int db_Vip_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Vip` ( `stamp`  ,  `uid`  ,  `vop`  ,  `num` ) VALUES ( %u , %d , %d , %d )" , stamp, uid, vop, num);
return db_service.async_execute(buf);
}
int db_Vip_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Vip` ( `stamp`  ,  `uid`  ,  `vop`  ,  `num` ) VALUES ( %u , %d , %d , %d )" , stamp, uid, vop, num);
return db_service.sync_execute(buf);
}
int db_NewRole_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;mac = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
ctime = row_[i++];
aid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
return 0;
}
string db_NewRole_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewRole` ( `mac`  ,  `uid`  ,  `hostnum`  ,  `ctime`  ,  `aid`  ,  `domain` ) VALUES ( '%s' , %d , %d , '%s' , %d , '%s' )" , mac.c_str(), uid, hostnum, ctime.c_str(), aid, domain.c_str());
return string(buf);
}
int db_NewRole_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewRole` ( `mac`  ,  `uid`  ,  `hostnum`  ,  `ctime`  ,  `aid`  ,  `domain` ) VALUES ( '%s' , %d , %d , '%s' , %d , '%s' )" , mac.c_str(), uid, hostnum, ctime.c_str(), aid, domain.c_str());
return db_service.async_execute(buf);
}
int db_NewRole_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewRole` ( `mac`  ,  `uid`  ,  `hostnum`  ,  `ctime`  ,  `aid`  ,  `domain` ) VALUES ( '%s' , %d , %d , '%s' , %d , '%s' )" , mac.c_str(), uid, hostnum, ctime.c_str(), aid, domain.c_str());
return db_service.sync_execute(buf);
}
int db_PlantShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;buystamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
plantid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_PlantShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `plantid` , `count` FROM `PlantShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PlantShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `plantid` , `count` FROM `PlantShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PlantShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `PlantShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `plantid` = %d", buystamp, count, uid, plantid);
return db_service.async_execute(buf);
}
int db_PlantShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `PlantShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `plantid` = %d", buystamp, count, uid, plantid);
return db_service.sync_execute(buf);
}
string db_PlantShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `PlantShop` ( `buystamp`  ,  `uid`  ,  `plantid`  ,  `count` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, plantid, count);
return string(buf);
}
int db_PlantShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PlantShop` ( `buystamp`  ,  `uid`  ,  `plantid`  ,  `count` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, plantid, count);
return db_service.async_execute(buf);
}
int db_PlantShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PlantShop` ( `buystamp`  ,  `uid`  ,  `plantid`  ,  `count` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, plantid, count);
return db_service.sync_execute(buf);
}
int db_RankSeason_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
score=(int)std::atoi(row_[i++].c_str());
last_fight_stamp=(int)std::atoi(row_[i++].c_str());
max_rank=(int)std::atoi(row_[i++].c_str());
successive_defeat=(int)std::atoi(row_[i++].c_str());
season=(int)std::atoi(row_[i++].c_str());
rank=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RankSeason_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `score` , `last_fight_stamp` , `max_rank` , `successive_defeat` , `season` , `rank` FROM `RankSeason` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RankSeason_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `score` , `last_fight_stamp` , `max_rank` , `successive_defeat` , `season` , `rank` FROM `RankSeason` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RankSeason_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RankSeason` SET  `score` = %d ,  `last_fight_stamp` = %d ,  `max_rank` = %d ,  `successive_defeat` = %d ,  `season` = %d ,  `rank` = %d WHERE  `uid` = %d", score, last_fight_stamp, max_rank, successive_defeat, season, rank, uid);
return db_service.async_execute(buf);
}
int db_RankSeason_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RankSeason` SET  `score` = %d ,  `last_fight_stamp` = %d ,  `max_rank` = %d ,  `successive_defeat` = %d ,  `season` = %d ,  `rank` = %d WHERE  `uid` = %d", score, last_fight_stamp, max_rank, successive_defeat, season, rank, uid);
return db_service.sync_execute(buf);
}
string db_RankSeason_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankSeason` ( `uid`  ,  `score`  ,  `last_fight_stamp`  ,  `max_rank`  ,  `successive_defeat`  ,  `season`  ,  `rank` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , uid, score, last_fight_stamp, max_rank, successive_defeat, season, rank);
return string(buf);
}
int db_RankSeason_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankSeason` ( `uid`  ,  `score`  ,  `last_fight_stamp`  ,  `max_rank`  ,  `successive_defeat`  ,  `season`  ,  `rank` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , uid, score, last_fight_stamp, max_rank, successive_defeat, season, rank);
return db_service.async_execute(buf);
}
int db_RankSeason_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankSeason` ( `uid`  ,  `score`  ,  `last_fight_stamp`  ,  `max_rank`  ,  `successive_defeat`  ,  `season`  ,  `rank` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , uid, score, last_fight_stamp, max_rank, successive_defeat, season, rank);
return db_service.sync_execute(buf);
}
int db_TreasureSlot_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
slot_type=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
begin_pvp_fight_time=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
is_pvp_fighting=(int)std::atoi(row_[i++].c_str());
robers = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
lovelevel=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
rob_money=(int)std::atoi(row_[i++].c_str());
slot_pos=(int)std::atoi(row_[i++].c_str());
fp=(int)std::atoi(row_[i++].c_str());
n_rob=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_TreasureSlot_t::select(const int32_t& hostnum_, const int32_t& slot_type_, const int32_t& slot_pos_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `slot_type` , `stamp` , `resid` , `id` , `begin_pvp_fight_time` , `grade` , `is_pvp_fighting` , `robers` , `uid` , `lovelevel` , `hostnum` , `rob_money` , `slot_pos` , `fp` , `n_rob` FROM `TreasureSlot` WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", hostnum_, slot_type_, slot_pos_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureSlot_t::sync_select(const int32_t& hostnum_, const int32_t& slot_type_, const int32_t& slot_pos_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `slot_type` , `stamp` , `resid` , `id` , `begin_pvp_fight_time` , `grade` , `is_pvp_fighting` , `robers` , `uid` , `lovelevel` , `hostnum` , `rob_money` , `slot_pos` , `fp` , `n_rob` FROM `TreasureSlot` WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", hostnum_, slot_type_, slot_pos_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureSlot_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureSlot` SET  `nickname` = '%s' ,  `slot_type` = %d ,  `stamp` = %d ,  `resid` = %d ,  `id` = %d ,  `begin_pvp_fight_time` = %d ,  `grade` = %d ,  `is_pvp_fighting` = %d ,  `robers` = '%s' ,  `uid` = %d ,  `lovelevel` = %d ,  `hostnum` = %d ,  `rob_money` = %d ,  `slot_pos` = %d ,  `fp` = %d ,  `n_rob` = %d WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", nickname.c_str(), slot_type, stamp, resid, id, begin_pvp_fight_time, grade, is_pvp_fighting, robers.c_str(), uid, lovelevel, hostnum, rob_money, slot_pos, fp, n_rob, hostnum, slot_type, slot_pos);
return db_service.async_execute(buf);
}
int db_TreasureSlot_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureSlot` SET  `nickname` = '%s' ,  `slot_type` = %d ,  `stamp` = %d ,  `resid` = %d ,  `id` = %d ,  `begin_pvp_fight_time` = %d ,  `grade` = %d ,  `is_pvp_fighting` = %d ,  `robers` = '%s' ,  `uid` = %d ,  `lovelevel` = %d ,  `hostnum` = %d ,  `rob_money` = %d ,  `slot_pos` = %d ,  `fp` = %d ,  `n_rob` = %d WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", nickname.c_str(), slot_type, stamp, resid, id, begin_pvp_fight_time, grade, is_pvp_fighting, robers.c_str(), uid, lovelevel, hostnum, rob_money, slot_pos, fp, n_rob, hostnum, slot_type, slot_pos);
return db_service.sync_execute(buf);
}
string db_TreasureSlot_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureSlot` ( `nickname`  ,  `slot_type`  ,  `stamp`  ,  `resid`  ,  `begin_pvp_fight_time`  ,  `grade`  ,  `is_pvp_fighting`  ,  `robers`  ,  `uid`  ,  `lovelevel`  ,  `hostnum`  ,  `rob_money`  ,  `slot_pos`  ,  `fp`  ,  `n_rob` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), slot_type, stamp, resid, begin_pvp_fight_time, grade, is_pvp_fighting, robers.c_str(), uid, lovelevel, hostnum, rob_money, slot_pos, fp, n_rob);
return string(buf);
}
int db_TreasureSlot_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureSlot` ( `nickname`  ,  `slot_type`  ,  `stamp`  ,  `resid`  ,  `begin_pvp_fight_time`  ,  `grade`  ,  `is_pvp_fighting`  ,  `robers`  ,  `uid`  ,  `lovelevel`  ,  `hostnum`  ,  `rob_money`  ,  `slot_pos`  ,  `fp`  ,  `n_rob` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), slot_type, stamp, resid, begin_pvp_fight_time, grade, is_pvp_fighting, robers.c_str(), uid, lovelevel, hostnum, rob_money, slot_pos, fp, n_rob);
return db_service.async_execute(buf);
}
int db_TreasureSlot_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureSlot` ( `nickname`  ,  `slot_type`  ,  `stamp`  ,  `resid`  ,  `begin_pvp_fight_time`  ,  `grade`  ,  `is_pvp_fighting`  ,  `robers`  ,  `uid`  ,  `lovelevel`  ,  `hostnum`  ,  `rob_money`  ,  `slot_pos`  ,  `fp`  ,  `n_rob` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), slot_type, stamp, resid, begin_pvp_fight_time, grade, is_pvp_fighting, robers.c_str(), uid, lovelevel, hostnum, rob_money, slot_pos, fp, n_rob);
return db_service.sync_execute(buf);
}
int db_Achievement_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
tasktype=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
systype=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
collect=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Achievement_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `tasktype` , `resid` , `systype` , `stamp` , `step` , `collect` FROM `Achievement` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Achievement_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `tasktype` , `resid` , `systype` , `stamp` , `step` , `collect` FROM `Achievement` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Achievement_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Achievement` SET  `tasktype` = %d ,  `systype` = %d ,  `stamp` = %u ,  `step` = %d ,  `collect` = %d WHERE  `uid` = %d AND  `resid` = %d", tasktype, systype, stamp, step, collect, uid, resid);
return db_service.async_execute(buf);
}
int db_Achievement_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Achievement` SET  `tasktype` = %d ,  `systype` = %d ,  `stamp` = %u ,  `step` = %d ,  `collect` = %d WHERE  `uid` = %d AND  `resid` = %d", tasktype, systype, stamp, step, collect, uid, resid);
return db_service.sync_execute(buf);
}
int db_Achievement_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Achievement` WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return db_service.async_execute(buf);
}
string db_Achievement_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Achievement` ( `uid`  ,  `tasktype`  ,  `resid`  ,  `systype`  ,  `stamp`  ,  `step`  ,  `collect` ) VALUES ( %d , %d , %d , %d , %u , %d , %d )" , uid, tasktype, resid, systype, stamp, step, collect);
return string(buf);
}
int db_Achievement_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Achievement` ( `uid`  ,  `tasktype`  ,  `resid`  ,  `systype`  ,  `stamp`  ,  `step`  ,  `collect` ) VALUES ( %d , %d , %d , %d , %u , %d , %d )" , uid, tasktype, resid, systype, stamp, step, collect);
return db_service.async_execute(buf);
}
int db_Achievement_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Achievement` ( `uid`  ,  `tasktype`  ,  `resid`  ,  `systype`  ,  `stamp`  ,  `step`  ,  `collect` ) VALUES ( %d , %d , %d , %d , %u , %d , %d )" , uid, tasktype, resid, systype, stamp, step, collect);
return db_service.sync_execute(buf);
}
int db_Online_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;loginstamp=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
serid=(int)std::atoi(row_[i++].c_str());
os = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
sys=(int)std::atoi(row_[i++].c_str());
nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
device = row_[i++];
questid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
vip=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
mac = row_[i++];
logintm = row_[i++];
counttime=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_Online_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Online` ( `loginstamp`  ,  `exp`  ,  `serid`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `sys`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `questid`  ,  `domain`  ,  `uid`  ,  `name`  ,  `vip`  ,  `grade`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %u , %d , %d , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , '%s' , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , loginstamp, exp, serid, os.c_str(), hostnum, aid, sys, nickname.c_str(), resid, device.c_str(), questid, domain.c_str(), uid, name.c_str(), vip, grade, mac.c_str(), logintm.c_str(), counttime);
return string(buf);
}
int db_Online_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Online` ( `loginstamp`  ,  `exp`  ,  `serid`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `sys`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `questid`  ,  `domain`  ,  `uid`  ,  `name`  ,  `vip`  ,  `grade`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %u , %d , %d , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , '%s' , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , loginstamp, exp, serid, os.c_str(), hostnum, aid, sys, nickname.c_str(), resid, device.c_str(), questid, domain.c_str(), uid, name.c_str(), vip, grade, mac.c_str(), logintm.c_str(), counttime);
return db_service.async_execute(buf);
}
int db_Online_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Online` ( `loginstamp`  ,  `exp`  ,  `serid`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `sys`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `questid`  ,  `domain`  ,  `uid`  ,  `name`  ,  `vip`  ,  `grade`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %u , %d , %d , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , '%s' , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , loginstamp, exp, serid, os.c_str(), hostnum, aid, sys, nickname.c_str(), resid, device.c_str(), questid, domain.c_str(), uid, name.c_str(), vip, grade, mac.c_str(), logintm.c_str(), counttime);
return db_service.sync_execute(buf);
}
int db_Expedition_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;open_box=(int)std::atoi(row_[i++].c_str());
hp4=(float)std::atof(row_[i++].c_str());
is_refresh_today=(int)std::atoi(row_[i++].c_str());
hp3=(float)std::atof(row_[i++].c_str());
refresh_type=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
hp2=(float)std::atof(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
utime=(int)std::atoi(row_[i++].c_str());
view_data = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
hp5=(float)std::atof(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
hp1=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_Expedition_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `open_box` , `hp4` , `is_refresh_today` , `hp3` , `refresh_type` , `resid` , `hp2` , `pid3` , `utime` , `view_data` , `uid` , `pid4` , `pid2` , `pid1` , `hp5` , `pid5` , `hp1` FROM `Expedition` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Expedition_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `open_box` , `hp4` , `is_refresh_today` , `hp3` , `refresh_type` , `resid` , `hp2` , `pid3` , `utime` , `view_data` , `uid` , `pid4` , `pid2` , `pid1` , `hp5` , `pid5` , `hp1` FROM `Expedition` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Expedition_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Expedition` SET  `open_box` = %d ,  `hp4` = %f ,  `is_refresh_today` = %d ,  `hp3` = %f ,  `refresh_type` = %d ,  `hp2` = %f ,  `pid3` = %d ,  `utime` = %d ,  `view_data` = '%s' ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `hp5` = %f ,  `pid5` = %d ,  `hp1` = %f WHERE  `uid` = %d AND  `resid` = %d", open_box, hp4, is_refresh_today, hp3, refresh_type, hp2, pid3, utime, view_data.c_str(), pid4, pid2, pid1, hp5, pid5, hp1, uid, resid);
return db_service.async_execute(buf);
}
int db_Expedition_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Expedition` SET  `open_box` = %d ,  `hp4` = %f ,  `is_refresh_today` = %d ,  `hp3` = %f ,  `refresh_type` = %d ,  `hp2` = %f ,  `pid3` = %d ,  `utime` = %d ,  `view_data` = '%s' ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `hp5` = %f ,  `pid5` = %d ,  `hp1` = %f WHERE  `uid` = %d AND  `resid` = %d", open_box, hp4, is_refresh_today, hp3, refresh_type, hp2, pid3, utime, view_data.c_str(), pid4, pid2, pid1, hp5, pid5, hp1, uid, resid);
return db_service.sync_execute(buf);
}
string db_Expedition_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Expedition` ( `open_box`  ,  `hp4`  ,  `is_refresh_today`  ,  `hp3`  ,  `refresh_type`  ,  `resid`  ,  `hp2`  ,  `pid3`  ,  `utime`  ,  `view_data`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `hp5`  ,  `pid5`  ,  `hp1` ) VALUES ( %d , %f , %d , %f , %d , %d , %f , %d , %d , '%s' , %d , %d , %d , %d , %f , %d , %f )" , open_box, hp4, is_refresh_today, hp3, refresh_type, resid, hp2, pid3, utime, view_data.c_str(), uid, pid4, pid2, pid1, hp5, pid5, hp1);
return string(buf);
}
int db_Expedition_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Expedition` ( `open_box`  ,  `hp4`  ,  `is_refresh_today`  ,  `hp3`  ,  `refresh_type`  ,  `resid`  ,  `hp2`  ,  `pid3`  ,  `utime`  ,  `view_data`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `hp5`  ,  `pid5`  ,  `hp1` ) VALUES ( %d , %f , %d , %f , %d , %d , %f , %d , %d , '%s' , %d , %d , %d , %d , %f , %d , %f )" , open_box, hp4, is_refresh_today, hp3, refresh_type, resid, hp2, pid3, utime, view_data.c_str(), uid, pid4, pid2, pid1, hp5, pid5, hp1);
return db_service.async_execute(buf);
}
int db_Expedition_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Expedition` ( `open_box`  ,  `hp4`  ,  `is_refresh_today`  ,  `hp3`  ,  `refresh_type`  ,  `resid`  ,  `hp2`  ,  `pid3`  ,  `utime`  ,  `view_data`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `hp5`  ,  `pid5`  ,  `hp1` ) VALUES ( %d , %f , %d , %f , %d , %d , %f , %d , %d , '%s' , %d , %d , %d , %d , %f , %d , %f )" , open_box, hp4, is_refresh_today, hp3, refresh_type, resid, hp2, pid3, utime, view_data.c_str(), uid, pid4, pid2, pid1, hp5, pid5, hp1);
return db_service.sync_execute(buf);
}
int db_Mail_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;info = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Mail_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `info` , `uid` FROM `Mail` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Mail_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `info` , `uid` FROM `Mail` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
string db_Mail_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Mail` ( `info`  ,  `uid` ) VALUES ( '%s' , %d )" , info.c_str(), uid);
return string(buf);
}
int db_Mail_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Mail` ( `info`  ,  `uid` ) VALUES ( '%s' , %d )" , info.c_str(), uid);
return db_service.async_execute(buf);
}
int db_Mail_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Mail` ( `info`  ,  `uid` ) VALUES ( '%s' , %d )" , info.c_str(), uid);
return db_service.sync_execute(buf);
}
int db_GangUser_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;todaycount=(int)std::atoi(row_[i++].c_str());
flag=(int)std::atoi(row_[i++].c_str());
bossrewardcount=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
totalgm=(int)std::atoi(row_[i++].c_str());
skl8=(int)std::atoi(row_[i++].c_str());
skl6=(int)std::atoi(row_[i++].c_str());
lastenter=(int)std::atoi(row_[i++].c_str());
nickname = row_[i++];
lastquit=(int)std::atoi(row_[i++].c_str());
skl7=(int)std::atoi(row_[i++].c_str());
skl5=(int)std::atoi(row_[i++].c_str());
skl1=(int)std::atoi(row_[i++].c_str());
ggid=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
skl2=(int)std::atoi(row_[i++].c_str());
lastboss=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
skl4=(int)std::atoi(row_[i++].c_str());
skl3=(int)std::atoi(row_[i++].c_str());
bossrewardtime=(int)std::atoi(row_[i++].c_str());
gm=(int)std::atoi(row_[i++].c_str());
state=(int)std::atoi(row_[i++].c_str());
rank=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GangUser_t::select_ganguser(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `flag` , `bossrewardcount` , `hostnum` , `totalgm` , `skl8` , `skl6` , `lastenter` , `nickname` , `lastquit` , `skl7` , `skl5` , `skl1` , `ggid` , `grade` , `skl2` , `lastboss` , `uid` , `skl4` , `skl3` , `bossrewardtime` , `gm` , `state` , `rank` FROM `GangUser` WHERE  `hostnum` = %d", hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangUser_t::sync_select_ganguser(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `flag` , `bossrewardcount` , `hostnum` , `totalgm` , `skl8` , `skl6` , `lastenter` , `nickname` , `lastquit` , `skl7` , `skl5` , `skl1` , `ggid` , `grade` , `skl2` , `lastboss` , `uid` , `skl4` , `skl3` , `bossrewardtime` , `gm` , `state` , `rank` FROM `GangUser` WHERE  `hostnum` = %d", hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangUser_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GangUser` SET  `todaycount` = %u ,  `flag` = %d ,  `bossrewardcount` = %u ,  `hostnum` = %d ,  `totalgm` = %d ,  `skl8` = %d ,  `skl6` = %d ,  `lastenter` = %u ,  `nickname` = '%s' ,  `lastquit` = %u ,  `skl7` = %d ,  `skl5` = %d ,  `skl1` = %d ,  `ggid` = %d ,  `grade` = %d ,  `skl2` = %d ,  `lastboss` = %u ,  `skl4` = %d ,  `skl3` = %d ,  `bossrewardtime` = %u ,  `gm` = %d ,  `state` = %d ,  `rank` = %d WHERE  `uid` = %d", todaycount, flag, bossrewardcount, hostnum, totalgm, skl8, skl6, lastenter, nickname.c_str(), lastquit, skl7, skl5, skl1, ggid, grade, skl2, lastboss, skl4, skl3, bossrewardtime, gm, state, rank, uid);
return db_service.async_execute(buf);
}
int db_GangUser_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GangUser` SET  `todaycount` = %u ,  `flag` = %d ,  `bossrewardcount` = %u ,  `hostnum` = %d ,  `totalgm` = %d ,  `skl8` = %d ,  `skl6` = %d ,  `lastenter` = %u ,  `nickname` = '%s' ,  `lastquit` = %u ,  `skl7` = %d ,  `skl5` = %d ,  `skl1` = %d ,  `ggid` = %d ,  `grade` = %d ,  `skl2` = %d ,  `lastboss` = %u ,  `skl4` = %d ,  `skl3` = %d ,  `bossrewardtime` = %u ,  `gm` = %d ,  `state` = %d ,  `rank` = %d WHERE  `uid` = %d", todaycount, flag, bossrewardcount, hostnum, totalgm, skl8, skl6, lastenter, nickname.c_str(), lastquit, skl7, skl5, skl1, ggid, grade, skl2, lastboss, skl4, skl3, bossrewardtime, gm, state, rank, uid);
return db_service.sync_execute(buf);
}
int db_GangUser_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `GangUser` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_GangUser_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangUser` ( `todaycount`  ,  `flag`  ,  `bossrewardcount`  ,  `hostnum`  ,  `totalgm`  ,  `skl8`  ,  `skl6`  ,  `lastenter`  ,  `nickname`  ,  `lastquit`  ,  `skl7`  ,  `skl5`  ,  `skl1`  ,  `ggid`  ,  `grade`  ,  `skl2`  ,  `lastboss`  ,  `uid`  ,  `skl4`  ,  `skl3`  ,  `bossrewardtime`  ,  `gm`  ,  `state`  ,  `rank` ) VALUES ( %u , %d , %u , %d , %d , %d , %d , %u , '%s' , %u , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %u , %d , %d , %d )" , todaycount, flag, bossrewardcount, hostnum, totalgm, skl8, skl6, lastenter, nickname.c_str(), lastquit, skl7, skl5, skl1, ggid, grade, skl2, lastboss, uid, skl4, skl3, bossrewardtime, gm, state, rank);
return string(buf);
}
int db_GangUser_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangUser` ( `todaycount`  ,  `flag`  ,  `bossrewardcount`  ,  `hostnum`  ,  `totalgm`  ,  `skl8`  ,  `skl6`  ,  `lastenter`  ,  `nickname`  ,  `lastquit`  ,  `skl7`  ,  `skl5`  ,  `skl1`  ,  `ggid`  ,  `grade`  ,  `skl2`  ,  `lastboss`  ,  `uid`  ,  `skl4`  ,  `skl3`  ,  `bossrewardtime`  ,  `gm`  ,  `state`  ,  `rank` ) VALUES ( %u , %d , %u , %d , %d , %d , %d , %u , '%s' , %u , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %u , %d , %d , %d )" , todaycount, flag, bossrewardcount, hostnum, totalgm, skl8, skl6, lastenter, nickname.c_str(), lastquit, skl7, skl5, skl1, ggid, grade, skl2, lastboss, uid, skl4, skl3, bossrewardtime, gm, state, rank);
return db_service.async_execute(buf);
}
int db_GangUser_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangUser` ( `todaycount`  ,  `flag`  ,  `bossrewardcount`  ,  `hostnum`  ,  `totalgm`  ,  `skl8`  ,  `skl6`  ,  `lastenter`  ,  `nickname`  ,  `lastquit`  ,  `skl7`  ,  `skl5`  ,  `skl1`  ,  `ggid`  ,  `grade`  ,  `skl2`  ,  `lastboss`  ,  `uid`  ,  `skl4`  ,  `skl3`  ,  `bossrewardtime`  ,  `gm`  ,  `state`  ,  `rank` ) VALUES ( %u , %d , %u , %d , %d , %d , %d , %u , '%s' , %u , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %u , %d , %d , %d )" , todaycount, flag, bossrewardcount, hostnum, totalgm, skl8, skl6, lastenter, nickname.c_str(), lastquit, skl7, skl5, skl1, ggid, grade, skl2, lastboss, uid, skl4, skl3, bossrewardtime, gm, state, rank);
return db_service.sync_execute(buf);
}
int db_ChatUser_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
player_uid=(int)std::atoi(row_[i++].c_str());
stmp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ChatUser_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `player_uid` , `stmp` FROM `ChatUser` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChatUser_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `player_uid` , `stmp` FROM `ChatUser` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChatUser_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ChatUser` SET  `id` = %d ,  `uid` = %d ,  `player_uid` = %d ,  `stmp` = %d WHERE  `uid` = %d", id, uid, player_uid, stmp, uid);
return db_service.async_execute(buf);
}
int db_ChatUser_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ChatUser` SET  `id` = %d ,  `uid` = %d ,  `player_uid` = %d ,  `stmp` = %d WHERE  `uid` = %d", id, uid, player_uid, stmp, uid);
return db_service.sync_execute(buf);
}
string db_ChatUser_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChatUser` ( `uid`  ,  `player_uid`  ,  `stmp` ) VALUES ( %d , %d , %d )" , uid, player_uid, stmp);
return string(buf);
}
int db_ChatUser_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChatUser` ( `uid`  ,  `player_uid`  ,  `stmp` ) VALUES ( %d , %d , %d )" , uid, player_uid, stmp);
return db_service.async_execute(buf);
}
int db_ChatUser_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChatUser` ( `uid`  ,  `player_uid`  ,  `stmp` ) VALUES ( %d , %d , %d )" , uid, player_uid, stmp);
return db_service.sync_execute(buf);
}
int db_GangBossGuwu_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
stamp_yb=(int)std::atoi(row_[i++].c_str());
progress=(int)std::atoi(row_[i++].c_str());
stamp_coin=(int)std::atoi(row_[i++].c_str());
stamp_v=(int)std::atoi(row_[i++].c_str());
v=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_GangBossGuwu_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp_yb` , `progress` , `stamp_coin` , `stamp_v` , `v` FROM `GangBossGuwu` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBossGuwu_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp_yb` , `progress` , `stamp_coin` , `stamp_v` , `v` FROM `GangBossGuwu` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBossGuwu_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBossGuwu` SET  `stamp_yb` = %d ,  `progress` = %d ,  `stamp_coin` = %d ,  `stamp_v` = %d ,  `v` = %f WHERE  `uid` = %d", stamp_yb, progress, stamp_coin, stamp_v, v, uid);
return db_service.async_execute(buf);
}
int db_GangBossGuwu_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBossGuwu` SET  `stamp_yb` = %d ,  `progress` = %d ,  `stamp_coin` = %d ,  `stamp_v` = %d ,  `v` = %f WHERE  `uid` = %d", stamp_yb, progress, stamp_coin, stamp_v, v, uid);
return db_service.sync_execute(buf);
}
string db_GangBossGuwu_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossGuwu` ( `uid`  ,  `stamp_yb`  ,  `progress`  ,  `stamp_coin`  ,  `stamp_v`  ,  `v` ) VALUES ( %d , %d , %d , %d , %d , %f )" , uid, stamp_yb, progress, stamp_coin, stamp_v, v);
return string(buf);
}
int db_GangBossGuwu_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossGuwu` ( `uid`  ,  `stamp_yb`  ,  `progress`  ,  `stamp_coin`  ,  `stamp_v`  ,  `v` ) VALUES ( %d , %d , %d , %d , %d , %f )" , uid, stamp_yb, progress, stamp_coin, stamp_v, v);
return db_service.async_execute(buf);
}
int db_GangBossGuwu_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossGuwu` ( `uid`  ,  `stamp_yb`  ,  `progress`  ,  `stamp_coin`  ,  `stamp_v`  ,  `v` ) VALUES ( %d , %d , %d , %d , %d , %f )" , uid, stamp_yb, progress, stamp_coin, stamp_v, v);
return db_service.sync_execute(buf);
}
int db_ChipValue_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;trend=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
price=(int)std::atoi(row_[i++].c_str());
cur_value=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ChipValue_t::select_all(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `trend` , `hostnum` , `id` , `resid` , `price` , `cur_value` FROM `ChipValue` WHERE  `hostnum` = %d", hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipValue_t::sync_select_all(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `trend` , `hostnum` , `id` , `resid` , `price` , `cur_value` FROM `ChipValue` WHERE  `hostnum` = %d", hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipValue_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipValue` SET  `trend` = %d ,  `resid` = %d ,  `price` = %d ,  `cur_value` = %d WHERE  `id` = %d", trend, resid, price, cur_value, id);
return db_service.async_execute(buf);
}
int db_ChipValue_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipValue` SET  `trend` = %d ,  `resid` = %d ,  `price` = %d ,  `cur_value` = %d WHERE  `id` = %d", trend, resid, price, cur_value, id);
return db_service.sync_execute(buf);
}
string db_ChipValue_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipValue` ( `trend`  ,  `hostnum`  ,  `id`  ,  `resid`  ,  `price`  ,  `cur_value` ) VALUES ( %d , %d , %d , %d , %d , %d )" , trend, hostnum, id, resid, price, cur_value);
return string(buf);
}
int db_ChipValue_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipValue` ( `trend`  ,  `hostnum`  ,  `id`  ,  `resid`  ,  `price`  ,  `cur_value` ) VALUES ( %d , %d , %d , %d , %d , %d )" , trend, hostnum, id, resid, price, cur_value);
return db_service.async_execute(buf);
}
int db_ChipValue_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipValue` ( `trend`  ,  `hostnum`  ,  `id`  ,  `resid`  ,  `price`  ,  `cur_value` ) VALUES ( %d , %d , %d , %d , %d , %d )" , trend, hostnum, id, resid, price, cur_value);
return db_service.sync_execute(buf);
}
int db_Skill_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
skid=(int)std::atoi(row_[i++].c_str());
level=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Skill_t::select_skill(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `resid` , `skid` , `level` FROM `Skill` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Skill_t::sync_select_skill(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `resid` , `skid` , `level` FROM `Skill` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Skill_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Skill` SET  `resid` = %d ,  `level` = %d WHERE  `uid` = %d AND  `skid` = %d", resid, level, uid, skid);
return db_service.async_execute(buf);
}
int db_Skill_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Skill` SET  `resid` = %d ,  `level` = %d WHERE  `uid` = %d AND  `skid` = %d", resid, level, uid, skid);
return db_service.sync_execute(buf);
}
int db_Skill_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Skill` WHERE  `uid` = %d AND  `skid` = %d", uid, skid);
return db_service.async_execute(buf);
}
string db_Skill_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Skill` ( `uid`  ,  `pid`  ,  `resid`  ,  `skid`  ,  `level` ) VALUES ( %d , %d , %d , %d , %d )" , uid, pid, resid, skid, level);
return string(buf);
}
int db_Skill_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Skill` ( `uid`  ,  `pid`  ,  `resid`  ,  `skid`  ,  `level` ) VALUES ( %d , %d , %d , %d , %d )" , uid, pid, resid, skid, level);
return db_service.async_execute(buf);
}
int db_Skill_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Skill` ( `uid`  ,  `pid`  ,  `resid`  ,  `skid`  ,  `level` ) VALUES ( %d , %d , %d , %d , %d )" , uid, pid, resid, skid, level);
return db_service.sync_execute(buf);
}
int db_Host_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
stoptm=(int)std::atoi(row_[i++].c_str());
jstr = row_[i++];
platname = row_[i++];
return 0;
}
int db_Host_t::select(const int& hostnum_, const string& platname_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `hostnum` , `id` , `stoptm` , `jstr` , `platname` FROM `Host` WHERE  `hostnum` = %d AND  `platname` = '%s'", hostnum_, platname_.c_str());
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Host_t::sync_select(const int& hostnum_, const string& platname_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `hostnum` , `id` , `stoptm` , `jstr` , `platname` FROM `Host` WHERE  `hostnum` = %d AND  `platname` = '%s'", hostnum_, platname_.c_str());
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
string db_Host_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Host` ( `state`  ,  `hostnum`  ,  `id`  ,  `stoptm`  ,  `jstr`  ,  `platname` ) VALUES ( %d , %d , %d , %u , '%s' , '%s' )" , state, hostnum, id, stoptm, jstr.c_str(), platname.c_str());
return string(buf);
}
int db_Host_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Host` ( `state`  ,  `hostnum`  ,  `id`  ,  `stoptm`  ,  `jstr`  ,  `platname` ) VALUES ( %d , %d , %d , %u , '%s' , '%s' )" , state, hostnum, id, stoptm, jstr.c_str(), platname.c_str());
return db_service.async_execute(buf);
}
int db_Host_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Host` ( `state`  ,  `hostnum`  ,  `id`  ,  `stoptm`  ,  `jstr`  ,  `platname` ) VALUES ( %d , %d , %d , %u , '%s' , '%s' )" , state, hostnum, id, stoptm, jstr.c_str(), platname.c_str());
return db_service.sync_execute(buf);
}
int db_Shop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Shop_t::select_shop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `resid` FROM `Shop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Shop_t::sync_select_shop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `resid` FROM `Shop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Shop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Shop` SET  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", count, uid, resid);
return db_service.async_execute(buf);
}
int db_Shop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Shop` SET  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", count, uid, resid);
return db_service.sync_execute(buf);
}
int db_Shop_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Shop` WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return db_service.async_execute(buf);
}
string db_Shop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Shop` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return string(buf);
}
int db_Shop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Shop` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return db_service.async_execute(buf);
}
int db_Shop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Shop` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return db_service.sync_execute(buf);
}
int db_SpShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;item11=(int)std::atoi(row_[i++].c_str());
item10=(int)std::atoi(row_[i++].c_str());
item8=(int)std::atoi(row_[i++].c_str());
item12=(int)std::atoi(row_[i++].c_str());
item4=(int)std::atoi(row_[i++].c_str());
item2=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
item6=(int)std::atoi(row_[i++].c_str());
item9=(int)std::atoi(row_[i++].c_str());
item7=(int)std::atoi(row_[i++].c_str());
item5=(int)std::atoi(row_[i++].c_str());
item3=(int)std::atoi(row_[i++].c_str());
item1=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_SpShop_t::select_spshop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `item11` , `item10` , `item8` , `item12` , `item4` , `item2` , `uid` , `item6` , `item9` , `item7` , `item5` , `item3` , `item1` FROM `SpShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_SpShop_t::sync_select_spshop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `item11` , `item10` , `item8` , `item12` , `item4` , `item2` , `uid` , `item6` , `item9` , `item7` , `item5` , `item3` , `item1` FROM `SpShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_SpShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `SpShop` SET  `item11` = %d ,  `item10` = %d ,  `item8` = %d ,  `item12` = %d ,  `item4` = %d ,  `item2` = %d ,  `item6` = %d ,  `item9` = %d ,  `item7` = %d ,  `item5` = %d ,  `item3` = %d ,  `item1` = %d WHERE  `uid` = %d", item11, item10, item8, item12, item4, item2, item6, item9, item7, item5, item3, item1, uid);
return db_service.async_execute(buf);
}
int db_SpShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `SpShop` SET  `item11` = %d ,  `item10` = %d ,  `item8` = %d ,  `item12` = %d ,  `item4` = %d ,  `item2` = %d ,  `item6` = %d ,  `item9` = %d ,  `item7` = %d ,  `item5` = %d ,  `item3` = %d ,  `item1` = %d WHERE  `uid` = %d", item11, item10, item8, item12, item4, item2, item6, item9, item7, item5, item3, item1, uid);
return db_service.sync_execute(buf);
}
string db_SpShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `SpShop` ( `item11`  ,  `item10`  ,  `item8`  ,  `item12`  ,  `item4`  ,  `item2`  ,  `uid`  ,  `item6`  ,  `item9`  ,  `item7`  ,  `item5`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , item11, item10, item8, item12, item4, item2, uid, item6, item9, item7, item5, item3, item1);
return string(buf);
}
int db_SpShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `SpShop` ( `item11`  ,  `item10`  ,  `item8`  ,  `item12`  ,  `item4`  ,  `item2`  ,  `uid`  ,  `item6`  ,  `item9`  ,  `item7`  ,  `item5`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , item11, item10, item8, item12, item4, item2, uid, item6, item9, item7, item5, item3, item1);
return db_service.async_execute(buf);
}
int db_SpShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `SpShop` ( `item11`  ,  `item10`  ,  `item8`  ,  `item12`  ,  `item4`  ,  `item2`  ,  `uid`  ,  `item6`  ,  `item9`  ,  `item7`  ,  `item5`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , item11, item10, item8, item12, item4, item2, uid, item6, item9, item7, item5, item3, item1);
return db_service.sync_execute(buf);
}
int db_RuneItem_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
level=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RuneItem_t::select_rune_item_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `resid` , `id` , `level` , `exp` FROM `RuneItem` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneItem_t::sync_select_rune_item_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `resid` , `id` , `level` , `exp` FROM `RuneItem` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneItem_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneItem` SET  `resid` = %d ,  `level` = %d ,  `exp` = %d WHERE  `uid` = %d AND  `id` = %d", resid, level, exp, uid, id);
return db_service.async_execute(buf);
}
int db_RuneItem_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneItem` SET  `resid` = %d ,  `level` = %d ,  `exp` = %d WHERE  `uid` = %d AND  `id` = %d", resid, level, exp, uid, id);
return db_service.sync_execute(buf);
}
int db_RuneItem_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `RuneItem` WHERE  `uid` = %d AND  `id` = %d", uid, id);
return db_service.async_execute(buf);
}
string db_RuneItem_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneItem` ( `uid`  ,  `resid`  ,  `id`  ,  `level`  ,  `exp` ) VALUES ( %d , %d , %d , %d , %d )" , uid, resid, id, level, exp);
return string(buf);
}
int db_RuneItem_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneItem` ( `uid`  ,  `resid`  ,  `id`  ,  `level`  ,  `exp` ) VALUES ( %d , %d , %d , %d , %d )" , uid, resid, id, level, exp);
return db_service.async_execute(buf);
}
int db_RuneItem_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneItem` ( `uid`  ,  `resid`  ,  `id`  ,  `level`  ,  `exp` ) VALUES ( %d , %d , %d , %d , %d )" , uid, resid, id, level, exp);
return db_service.sync_execute(buf);
}
int db_FriendFlower_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;fuid=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
getPower=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
lifetime=(int)std::atoi(row_[i++].c_str());
lv=(int)std::atoi(row_[i++].c_str());
headid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_FriendFlower_t::select_friend_flower(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `fuid` , `stamp` , `id` , `getPower` , `uid` , `name` , `lifetime` , `lv` , `headid` FROM `FriendFlower` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_FriendFlower_t::sync_select_friend_flower(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `fuid` , `stamp` , `id` , `getPower` , `uid` , `name` , `lifetime` , `lv` , `headid` FROM `FriendFlower` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_FriendFlower_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `FriendFlower` SET  `fuid` = %d ,  `stamp` = %u ,  `id` = %d ,  `getPower` = %d ,  `uid` = %d ,  `name` = '%s' ,  `lifetime` = %d ,  `lv` = %d ,  `headid` = %d WHERE  `id` = %d", fuid, stamp, id, getPower, uid, name.c_str(), lifetime, lv, headid, id);
return db_service.async_execute(buf);
}
int db_FriendFlower_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `FriendFlower` SET  `fuid` = %d ,  `stamp` = %u ,  `id` = %d ,  `getPower` = %d ,  `uid` = %d ,  `name` = '%s' ,  `lifetime` = %d ,  `lv` = %d ,  `headid` = %d WHERE  `id` = %d", fuid, stamp, id, getPower, uid, name.c_str(), lifetime, lv, headid, id);
return db_service.sync_execute(buf);
}
string db_FriendFlower_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `FriendFlower` ( `fuid`  ,  `stamp`  ,  `getPower`  ,  `uid`  ,  `name`  ,  `lifetime`  ,  `lv`  ,  `headid` ) VALUES ( %d , %u , %d , %d , '%s' , %d , %d , %d )" , fuid, stamp, getPower, uid, name.c_str(), lifetime, lv, headid);
return string(buf);
}
int db_FriendFlower_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FriendFlower` ( `fuid`  ,  `stamp`  ,  `getPower`  ,  `uid`  ,  `name`  ,  `lifetime`  ,  `lv`  ,  `headid` ) VALUES ( %d , %u , %d , %d , '%s' , %d , %d , %d )" , fuid, stamp, getPower, uid, name.c_str(), lifetime, lv, headid);
return db_service.async_execute(buf);
}
int db_FriendFlower_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FriendFlower` ( `fuid`  ,  `stamp`  ,  `getPower`  ,  `uid`  ,  `name`  ,  `lifetime`  ,  `lv`  ,  `headid` ) VALUES ( %d , %u , %d , %d , '%s' , %d , %d , %d )" , fuid, stamp, getPower, uid, name.c_str(), lifetime, lv, headid);
return db_service.sync_execute(buf);
}
int db_HomeFarm_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;getstamp=(int)std::atoi(row_[i++].c_str());
isend=(int)std::atoi(row_[i++].c_str());
losetime=(int)std::atoi(row_[i++].c_str());
getnum=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
canrob=(int)std::atoi(row_[i++].c_str());
cstamp=(int)std::atoi(row_[i++].c_str());
farmid=(int)std::atoi(row_[i++].c_str());
itemid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_HomeFarm_t::select_id(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `getstamp` , `isend` , `losetime` , `getnum` , `uid` , `canrob` , `cstamp` , `farmid` , `itemid` FROM `HomeFarm` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_HomeFarm_t::sync_select_id(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `getstamp` , `isend` , `losetime` , `getnum` , `uid` , `canrob` , `cstamp` , `farmid` , `itemid` FROM `HomeFarm` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_HomeFarm_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `HomeFarm` SET  `getstamp` = %d ,  `isend` = %d ,  `losetime` = %d ,  `getnum` = %d ,  `canrob` = %d ,  `cstamp` = %d ,  `farmid` = %d ,  `itemid` = %d WHERE  `uid` = %d", getstamp, isend, losetime, getnum, canrob, cstamp, farmid, itemid, uid);
return db_service.async_execute(buf);
}
int db_HomeFarm_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `HomeFarm` SET  `getstamp` = %d ,  `isend` = %d ,  `losetime` = %d ,  `getnum` = %d ,  `canrob` = %d ,  `cstamp` = %d ,  `farmid` = %d ,  `itemid` = %d WHERE  `uid` = %d", getstamp, isend, losetime, getnum, canrob, cstamp, farmid, itemid, uid);
return db_service.sync_execute(buf);
}
string db_HomeFarm_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `HomeFarm` ( `getstamp`  ,  `isend`  ,  `losetime`  ,  `getnum`  ,  `uid`  ,  `canrob`  ,  `cstamp`  ,  `farmid`  ,  `itemid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , getstamp, isend, losetime, getnum, uid, canrob, cstamp, farmid, itemid);
return string(buf);
}
int db_HomeFarm_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `HomeFarm` ( `getstamp`  ,  `isend`  ,  `losetime`  ,  `getnum`  ,  `uid`  ,  `canrob`  ,  `cstamp`  ,  `farmid`  ,  `itemid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , getstamp, isend, losetime, getnum, uid, canrob, cstamp, farmid, itemid);
return db_service.async_execute(buf);
}
int db_HomeFarm_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `HomeFarm` ( `getstamp`  ,  `isend`  ,  `losetime`  ,  `getnum`  ,  `uid`  ,  `canrob`  ,  `cstamp`  ,  `farmid`  ,  `itemid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , getstamp, isend, losetime, getnum, uid, canrob, cstamp, farmid, itemid);
return db_service.sync_execute(buf);
}
int db_Gang_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;todaycount=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
notice = row_[i++];
ggid=(int)std::atoi(row_[i++].c_str());
bosscount=(int)std::atoi(row_[i++].c_str());
bossday=(int)std::atoi(row_[i++].c_str());
lastboss=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
level=(int)std::atoi(row_[i++].c_str());
bosslv=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Gang_t::select_host_gang(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `hostnum` = %d", hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::select_ganginfo(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `ggid` = %d", ggid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::select_gang(const int32_t& ggid_, const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `ggid` = %d AND  `hostnum` = %d", ggid_, hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::sync_select_host_gang(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `hostnum` = %d", hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::sync_select_ganginfo(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `ggid` = %d", ggid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::sync_select_gang(const int32_t& ggid_, const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `todaycount` , `exp` , `notice` , `ggid` , `bosscount` , `bossday` , `lastboss` , `name` , `hostnum` , `level` , `bosslv` FROM `Gang` WHERE  `ggid` = %d AND  `hostnum` = %d", ggid_, hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Gang_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Gang` SET  `todaycount` = %d ,  `exp` = %d ,  `notice` = '%s' ,  `bosscount` = %d ,  `bossday` = %d ,  `lastboss` = %d ,  `name` = '%s' ,  `level` = %d ,  `bosslv` = %d WHERE  `ggid` = %d AND  `hostnum` = %d", todaycount, exp, notice.c_str(), bosscount, bossday, lastboss, name.c_str(), level, bosslv, ggid, hostnum);
return db_service.async_execute(buf);
}
int db_Gang_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Gang` SET  `todaycount` = %d ,  `exp` = %d ,  `notice` = '%s' ,  `bosscount` = %d ,  `bossday` = %d ,  `lastboss` = %d ,  `name` = '%s' ,  `level` = %d ,  `bosslv` = %d WHERE  `ggid` = %d AND  `hostnum` = %d", todaycount, exp, notice.c_str(), bosscount, bossday, lastboss, name.c_str(), level, bosslv, ggid, hostnum);
return db_service.sync_execute(buf);
}
int db_Gang_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Gang` WHERE  `ggid` = %d AND  `hostnum` = %d", ggid, hostnum);
return db_service.async_execute(buf);
}
string db_Gang_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Gang` ( `todaycount`  ,  `exp`  ,  `notice`  ,  `ggid`  ,  `bosscount`  ,  `bossday`  ,  `lastboss`  ,  `name`  ,  `hostnum`  ,  `level`  ,  `bosslv` ) VALUES ( %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %d , %d )" , todaycount, exp, notice.c_str(), ggid, bosscount, bossday, lastboss, name.c_str(), hostnum, level, bosslv);
return string(buf);
}
int db_Gang_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Gang` ( `todaycount`  ,  `exp`  ,  `notice`  ,  `ggid`  ,  `bosscount`  ,  `bossday`  ,  `lastboss`  ,  `name`  ,  `hostnum`  ,  `level`  ,  `bosslv` ) VALUES ( %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %d , %d )" , todaycount, exp, notice.c_str(), ggid, bosscount, bossday, lastboss, name.c_str(), hostnum, level, bosslv);
return db_service.async_execute(buf);
}
int db_Gang_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Gang` ( `todaycount`  ,  `exp`  ,  `notice`  ,  `ggid`  ,  `bosscount`  ,  `bossday`  ,  `lastboss`  ,  `name`  ,  `hostnum`  ,  `level`  ,  `bosslv` ) VALUES ( %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %d , %d )" , todaycount, exp, notice.c_str(), ggid, bosscount, bossday, lastboss, name.c_str(), hostnum, level, bosslv);
return db_service.sync_execute(buf);
}
int db_Soul_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
time=(int)std::atoi(row_[i++].c_str());
gem_need=(int)std::atoi(row_[i++].c_str());
level=(int)std::atoi(row_[i++].c_str());
rare=(int)std::atoi(row_[i++].c_str());
soul_id=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Soul_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `time` , `gem_need` , `level` , `rare` , `soul_id` FROM `Soul` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Soul_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `time` , `gem_need` , `level` , `rare` , `soul_id` FROM `Soul` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Soul_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Soul` SET  `state` = %d ,  `time` = %d ,  `gem_need` = %d ,  `level` = %d ,  `rare` = %d ,  `soul_id` = %d WHERE  `uid` = %d", state, time, gem_need, level, rare, soul_id, uid);
return db_service.async_execute(buf);
}
int db_Soul_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Soul` SET  `state` = %d ,  `time` = %d ,  `gem_need` = %d ,  `level` = %d ,  `rare` = %d ,  `soul_id` = %d WHERE  `uid` = %d", state, time, gem_need, level, rare, soul_id, uid);
return db_service.sync_execute(buf);
}
string db_Soul_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Soul` ( `state`  ,  `uid`  ,  `time`  ,  `gem_need`  ,  `level`  ,  `rare`  ,  `soul_id` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , state, uid, time, gem_need, level, rare, soul_id);
return string(buf);
}
int db_Soul_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Soul` ( `state`  ,  `uid`  ,  `time`  ,  `gem_need`  ,  `level`  ,  `rare`  ,  `soul_id` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , state, uid, time, gem_need, level, rare, soul_id);
return db_service.async_execute(buf);
}
int db_Soul_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Soul` ( `state`  ,  `uid`  ,  `time`  ,  `gem_need`  ,  `level`  ,  `rare`  ,  `soul_id` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , state, uid, time, gem_need, level, rare, soul_id);
return db_service.sync_execute(buf);
}
int db_LoveTask_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_LoveTask_t::select_love_task_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `pid` , `resid` , `step` FROM `LoveTask` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LoveTask_t::sync_select_love_task_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `pid` , `resid` , `step` FROM `LoveTask` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LoveTask_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `LoveTask` SET  `state` = %d ,  `pid` = %d ,  `step` = %d WHERE  `uid` = %d AND  `resid` = %d", state, pid, step, uid, resid);
return db_service.async_execute(buf);
}
int db_LoveTask_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `LoveTask` SET  `state` = %d ,  `pid` = %d ,  `step` = %d WHERE  `uid` = %d AND  `resid` = %d", state, pid, step, uid, resid);
return db_service.sync_execute(buf);
}
string db_LoveTask_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `LoveTask` ( `state`  ,  `uid`  ,  `pid`  ,  `resid`  ,  `step` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, pid, resid, step);
return string(buf);
}
int db_LoveTask_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LoveTask` ( `state`  ,  `uid`  ,  `pid`  ,  `resid`  ,  `step` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, pid, resid, step);
return db_service.async_execute(buf);
}
int db_LoveTask_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LoveTask` ( `state`  ,  `uid`  ,  `pid`  ,  `resid`  ,  `step` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, pid, resid, step);
return db_service.sync_execute(buf);
}
int db_ArenaInfo_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;total_fp=(int)std::atoi(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
level=(int)std::atoi(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ArenaInfo_t::select_hostnum(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `total_fp` , `pid3` , `uid` , `pid4` , `hostnum` , `pid1` , `level` , `pid5` , `pid2` FROM `ArenaInfo` WHERE  `hostnum` = %d", hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ArenaInfo_t::sync_select_hostnum(const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `total_fp` , `pid3` , `uid` , `pid4` , `hostnum` , `pid1` , `level` , `pid5` , `pid2` FROM `ArenaInfo` WHERE  `hostnum` = %d", hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ArenaInfo_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ArenaInfo` SET  `total_fp` = %d ,  `pid3` = %d ,  `pid4` = %d ,  `pid1` = %d ,  `level` = %d ,  `pid5` = %d ,  `pid2` = %d WHERE  `hostnum` = %d AND  `uid` = %d", total_fp, pid3, pid4, pid1, level, pid5, pid2, hostnum, uid);
return db_service.async_execute(buf);
}
int db_ArenaInfo_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ArenaInfo` SET  `total_fp` = %d ,  `pid3` = %d ,  `pid4` = %d ,  `pid1` = %d ,  `level` = %d ,  `pid5` = %d ,  `pid2` = %d WHERE  `hostnum` = %d AND  `uid` = %d", total_fp, pid3, pid4, pid1, level, pid5, pid2, hostnum, uid);
return db_service.sync_execute(buf);
}
string db_ArenaInfo_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ArenaInfo` ( `total_fp`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hostnum`  ,  `pid1`  ,  `level`  ,  `pid5`  ,  `pid2` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , total_fp, pid3, uid, pid4, hostnum, pid1, level, pid5, pid2);
return string(buf);
}
int db_ArenaInfo_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ArenaInfo` ( `total_fp`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hostnum`  ,  `pid1`  ,  `level`  ,  `pid5`  ,  `pid2` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , total_fp, pid3, uid, pid4, hostnum, pid1, level, pid5, pid2);
return db_service.async_execute(buf);
}
int db_ArenaInfo_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ArenaInfo` ( `total_fp`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hostnum`  ,  `pid1`  ,  `level`  ,  `pid5`  ,  `pid2` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d )" , total_fp, pid3, uid, pid4, hostnum, pid1, level, pid5, pid2);
return db_service.sync_execute(buf);
}
int db_QuitLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;exp=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
os = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
quittm = row_[i++];
nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
device = row_[i++];
totaltime=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
questid=(int)std::atoi(row_[i++].c_str());
vip=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
grade=(int)std::atoi(row_[i++].c_str());
sys=(int)std::atoi(row_[i++].c_str());
mac = row_[i++];
logintm = row_[i++];
counttime=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_QuitLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `QuitLog` ( `exp`  ,  `step`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `quittm`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `totaltime`  ,  `domain`  ,  `questid`  ,  `vip`  ,  `uid`  ,  `name`  ,  `grade`  ,  `sys`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , exp, step, os.c_str(), hostnum, aid, quittm.c_str(), nickname.c_str(), resid, device.c_str(), totaltime, domain.c_str(), questid, vip, uid, name.c_str(), grade, sys, mac.c_str(), logintm.c_str(), counttime);
return string(buf);
}
int db_QuitLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `QuitLog` ( `exp`  ,  `step`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `quittm`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `totaltime`  ,  `domain`  ,  `questid`  ,  `vip`  ,  `uid`  ,  `name`  ,  `grade`  ,  `sys`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , exp, step, os.c_str(), hostnum, aid, quittm.c_str(), nickname.c_str(), resid, device.c_str(), totaltime, domain.c_str(), questid, vip, uid, name.c_str(), grade, sys, mac.c_str(), logintm.c_str(), counttime);
return db_service.async_execute(buf);
}
int db_QuitLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `QuitLog` ( `exp`  ,  `step`  ,  `os`  ,  `hostnum`  ,  `aid`  ,  `quittm`  ,  `nickname`  ,  `resid`  ,  `device`  ,  `totaltime`  ,  `domain`  ,  `questid`  ,  `vip`  ,  `uid`  ,  `name`  ,  `grade`  ,  `sys`  ,  `mac`  ,  `logintm`  ,  `counttime` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d )" , exp, step, os.c_str(), hostnum, aid, quittm.c_str(), nickname.c_str(), resid, device.c_str(), totaltime, domain.c_str(), questid, vip, uid, name.c_str(), grade, sys, mac.c_str(), logintm.c_str(), counttime);
return db_service.sync_execute(buf);
}
int db_PrivateChat_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;acuid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
msg = row_[i++];
grade=(int)std::atoi(row_[i++].c_str());
suid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
typeindex=(int)std::atoi(row_[i++].c_str());
vip=(int)std::atoi(row_[i++].c_str());
quality=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_PrivateChat_t::select_all(const int32_t& suid_, const int32_t& acuid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `acuid` , `resid` , `id` , `msg` , `grade` , `suid` , `name` , `hostnum` , `typeindex` , `vip` , `quality` FROM `PrivateChat` WHERE  `suid` = %d AND  `acuid` = %d", suid_, acuid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PrivateChat_t::sync_select_all(const int32_t& suid_, const int32_t& acuid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `acuid` , `resid` , `id` , `msg` , `grade` , `suid` , `name` , `hostnum` , `typeindex` , `vip` , `quality` FROM `PrivateChat` WHERE  `suid` = %d AND  `acuid` = %d", suid_, acuid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PrivateChat_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `PrivateChat` WHERE  `suid` = %d AND  `acuid` = %d", suid, acuid);
return db_service.async_execute(buf);
}
string db_PrivateChat_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrivateChat` ( `acuid`  ,  `resid`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , acuid, resid, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return string(buf);
}
int db_PrivateChat_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrivateChat` ( `acuid`  ,  `resid`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , acuid, resid, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return db_service.async_execute(buf);
}
int db_PrivateChat_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrivateChat` ( `acuid`  ,  `resid`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , acuid, resid, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return db_service.sync_execute(buf);
}
int db_Wing_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;lucky=(int)std::atoi(row_[i++].c_str());
isweared=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
mgc=(int)std::atoi(row_[i++].c_str());
hp=(int)std::atoi(row_[i++].c_str());
dodge=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
acc=(int)std::atoi(row_[i++].c_str());
wid=(int)std::atoi(row_[i++].c_str());
def=(int)std::atoi(row_[i++].c_str());
res=(int)std::atoi(row_[i++].c_str());
crit=(int)std::atoi(row_[i++].c_str());
atk=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Wing_t::select_wing_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `lucky` , `isweared` , `resid` , `mgc` , `hp` , `dodge` , `uid` , `acc` , `wid` , `def` , `res` , `crit` , `atk` FROM `Wing` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Wing_t::sync_select_wing_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `lucky` , `isweared` , `resid` , `mgc` , `hp` , `dodge` , `uid` , `acc` , `wid` , `def` , `res` , `crit` , `atk` FROM `Wing` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Wing_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Wing` SET  `lucky` = %d ,  `isweared` = %d ,  `resid` = %d ,  `mgc` = %d ,  `hp` = %d ,  `dodge` = %d ,  `acc` = %d ,  `def` = %d ,  `res` = %d ,  `crit` = %d ,  `atk` = %d WHERE  `uid` = %d AND  `wid` = %d", lucky, isweared, resid, mgc, hp, dodge, acc, def, res, crit, atk, uid, wid);
return db_service.async_execute(buf);
}
int db_Wing_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Wing` SET  `lucky` = %d ,  `isweared` = %d ,  `resid` = %d ,  `mgc` = %d ,  `hp` = %d ,  `dodge` = %d ,  `acc` = %d ,  `def` = %d ,  `res` = %d ,  `crit` = %d ,  `atk` = %d WHERE  `uid` = %d AND  `wid` = %d", lucky, isweared, resid, mgc, hp, dodge, acc, def, res, crit, atk, uid, wid);
return db_service.sync_execute(buf);
}
int db_Wing_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Wing` WHERE  `uid` = %d AND  `wid` = %d", uid, wid);
return db_service.async_execute(buf);
}
string db_Wing_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Wing` ( `lucky`  ,  `isweared`  ,  `resid`  ,  `mgc`  ,  `hp`  ,  `dodge`  ,  `uid`  ,  `acc`  ,  `wid`  ,  `def`  ,  `res`  ,  `crit`  ,  `atk` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , lucky, isweared, resid, mgc, hp, dodge, uid, acc, wid, def, res, crit, atk);
return string(buf);
}
int db_Wing_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Wing` ( `lucky`  ,  `isweared`  ,  `resid`  ,  `mgc`  ,  `hp`  ,  `dodge`  ,  `uid`  ,  `acc`  ,  `wid`  ,  `def`  ,  `res`  ,  `crit`  ,  `atk` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , lucky, isweared, resid, mgc, hp, dodge, uid, acc, wid, def, res, crit, atk);
return db_service.async_execute(buf);
}
int db_Wing_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Wing` ( `lucky`  ,  `isweared`  ,  `resid`  ,  `mgc`  ,  `hp`  ,  `dodge`  ,  `uid`  ,  `acc`  ,  `wid`  ,  `def`  ,  `res`  ,  `crit`  ,  `atk` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , lucky, isweared, resid, mgc, hp, dodge, uid, acc, wid, def, res, crit, atk);
return db_service.sync_execute(buf);
}
int db_ExpeditionTeam_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;anger=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ExpeditionTeam_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `anger` , `uid` , `pid4` , `pid2` , `pid1` , `pid3` , `pid5` FROM `ExpeditionTeam` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionTeam_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `anger` , `uid` , `pid4` , `pid2` , `pid1` , `pid3` , `pid5` FROM `ExpeditionTeam` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionTeam_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionTeam` SET  `anger` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid3` = %d ,  `pid5` = %d WHERE  `uid` = %d", anger, pid4, pid2, pid1, pid3, pid5, uid);
return db_service.async_execute(buf);
}
int db_ExpeditionTeam_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionTeam` SET  `anger` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid3` = %d ,  `pid5` = %d WHERE  `uid` = %d", anger, pid4, pid2, pid1, pid3, pid5, uid);
return db_service.sync_execute(buf);
}
string db_ExpeditionTeam_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return string(buf);
}
int db_ExpeditionTeam_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return db_service.async_execute(buf);
}
int db_ExpeditionTeam_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return db_service.sync_execute(buf);
}
int db_RuneInfo_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
hunt_level=(int)std::atoi(row_[i++].c_str());
page_num=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RuneInfo_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hunt_level` , `page_num` FROM `RuneInfo` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneInfo_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hunt_level` , `page_num` FROM `RuneInfo` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneInfo_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneInfo` SET  `hunt_level` = %d ,  `page_num` = %d WHERE  `uid` = %d", hunt_level, page_num, uid);
return db_service.async_execute(buf);
}
int db_RuneInfo_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneInfo` SET  `hunt_level` = %d ,  `page_num` = %d WHERE  `uid` = %d", hunt_level, page_num, uid);
return db_service.sync_execute(buf);
}
int db_RuneInfo_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `RuneInfo` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_RuneInfo_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneInfo` ( `uid`  ,  `hunt_level`  ,  `page_num` ) VALUES ( %d , %d , %d )" , uid, hunt_level, page_num);
return string(buf);
}
int db_RuneInfo_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneInfo` ( `uid`  ,  `hunt_level`  ,  `page_num` ) VALUES ( %d , %d , %d )" , uid, hunt_level, page_num);
return db_service.async_execute(buf);
}
int db_RuneInfo_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneInfo` ( `uid`  ,  `hunt_level`  ,  `page_num` ) VALUES ( %d , %d , %d )" , uid, hunt_level, page_num);
return db_service.sync_execute(buf);
}
int db_YBLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;price=(int)std::atoi(row_[i++].c_str());
serid=(int)std::atoi(row_[i++].c_str());
giventm = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
tradetm = row_[i++];
domain = row_[i++];
rmb=(int)std::atoi(row_[i++].c_str());
totalyb=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
count=(int)std::atoi(row_[i++].c_str());
appid = row_[i++];
payyb=(int)std::atoi(row_[i++].c_str());
freeyb=(int)std::atoi(row_[i++].c_str());
sid=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_YBLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `YBLog` ( `price`  ,  `serid`  ,  `giventm`  ,  `hostnum`  ,  `aid`  ,  `nickname`  ,  `resid`  ,  `tradetm`  ,  `domain`  ,  `rmb`  ,  `totalyb`  ,  `uid`  ,  `name`  ,  `count`  ,  `appid`  ,  `payyb`  ,  `freeyb`  ,  `sid` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , %d , %d )" , price, serid, giventm.c_str(), hostnum, aid, nickname.c_str(), resid, tradetm.c_str(), domain.c_str(), rmb, totalyb, uid, name.c_str(), count, appid.c_str(), payyb, freeyb, sid);
return string(buf);
}
int db_YBLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `YBLog` ( `price`  ,  `serid`  ,  `giventm`  ,  `hostnum`  ,  `aid`  ,  `nickname`  ,  `resid`  ,  `tradetm`  ,  `domain`  ,  `rmb`  ,  `totalyb`  ,  `uid`  ,  `name`  ,  `count`  ,  `appid`  ,  `payyb`  ,  `freeyb`  ,  `sid` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , %d , %d )" , price, serid, giventm.c_str(), hostnum, aid, nickname.c_str(), resid, tradetm.c_str(), domain.c_str(), rmb, totalyb, uid, name.c_str(), count, appid.c_str(), payyb, freeyb, sid);
return db_service.async_execute(buf);
}
int db_YBLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `YBLog` ( `price`  ,  `serid`  ,  `giventm`  ,  `hostnum`  ,  `aid`  ,  `nickname`  ,  `resid`  ,  `tradetm`  ,  `domain`  ,  `rmb`  ,  `totalyb`  ,  `uid`  ,  `name`  ,  `count`  ,  `appid`  ,  `payyb`  ,  `freeyb`  ,  `sid` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , '%s' , %d , %d , %d )" , price, serid, giventm.c_str(), hostnum, aid, nickname.c_str(), resid, tradetm.c_str(), domain.c_str(), rmb, totalyb, uid, name.c_str(), count, appid.c_str(), payyb, freeyb, sid);
return db_service.sync_execute(buf);
}
int db_CardEventShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
shopindex=(int)std::atoi(row_[i++].c_str());
shopid=(int)std::atoi(row_[i++].c_str());
refresh_time=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_CardEventShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `shopindex` , `shopid` , `refresh_time` FROM `CardEventShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `shopindex` , `shopid` , `refresh_time` FROM `CardEventShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventShop` SET  `count` = %d ,  `shopindex` = %d ,  `refresh_time` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, shopindex, refresh_time, uid, shopid);
return db_service.async_execute(buf);
}
int db_CardEventShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventShop` SET  `count` = %d ,  `shopindex` = %d ,  `refresh_time` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, shopindex, refresh_time, uid, shopid);
return db_service.sync_execute(buf);
}
string db_CardEventShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return string(buf);
}
int db_CardEventShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return db_service.async_execute(buf);
}
int db_CardEventShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return db_service.sync_execute(buf);
}
int db_Compensate_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
givenstamp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Compensate_t::select_compensate(const uint32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `count` , `resid` , `id` , `givenstamp` FROM `Compensate` WHERE  `uid` = %u AND  `state` = %d", uid_, state_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Compensate_t::sync_select_compensate(const uint32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `count` , `resid` , `id` , `givenstamp` FROM `Compensate` WHERE  `uid` = %u AND  `state` = %d", uid_, state_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Compensate_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Compensate` SET  `state` = %d ,  `count` = %u ,  `resid` = %u ,  `id` = %u ,  `givenstamp` = %u WHERE  `id` = %u", state, count, resid, id, givenstamp, id);
return db_service.async_execute(buf);
}
int db_Compensate_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Compensate` SET  `state` = %d ,  `count` = %u ,  `resid` = %u ,  `id` = %u ,  `givenstamp` = %u WHERE  `id` = %u", state, count, resid, id, givenstamp, id);
return db_service.sync_execute(buf);
}
string db_Compensate_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Compensate` ( `state`  ,  `uid`  ,  `count`  ,  `resid`  ,  `id`  ,  `givenstamp` ) VALUES ( %d , %u , %u , %u , %u , %u )" , state, uid, count, resid, id, givenstamp);
return string(buf);
}
int db_Compensate_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Compensate` ( `state`  ,  `uid`  ,  `count`  ,  `resid`  ,  `id`  ,  `givenstamp` ) VALUES ( %d , %u , %u , %u , %u , %u )" , state, uid, count, resid, id, givenstamp);
return db_service.async_execute(buf);
}
int db_Compensate_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Compensate` ( `state`  ,  `uid`  ,  `count`  ,  `resid`  ,  `id`  ,  `givenstamp` ) VALUES ( %d , %u , %u , %u , %u , %u )" , state, uid, count, resid, id, givenstamp);
return db_service.sync_execute(buf);
}
int db_PubMgr_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;pub_sum=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pub_4_first=(int)std::atoi(row_[i++].c_str());
stepup_state=(int)std::atoi(row_[i++].c_str());
event_state=(int)std::atoi(row_[i++].c_str());
pub_3_first=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_PubMgr_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `pub_sum` , `uid` , `pub_4_first` , `stepup_state` , `event_state` , `pub_3_first` FROM `PubMgr` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PubMgr_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `pub_sum` , `uid` , `pub_4_first` , `stepup_state` , `event_state` , `pub_3_first` FROM `PubMgr` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PubMgr_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `PubMgr` SET  `pub_sum` = %d ,  `uid` = %d ,  `pub_4_first` = %d ,  `stepup_state` = %d ,  `event_state` = %d ,  `pub_3_first` = %d WHERE  `uid` = %d", pub_sum, uid, pub_4_first, stepup_state, event_state, pub_3_first, uid);
return db_service.async_execute(buf);
}
int db_PubMgr_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `PubMgr` SET  `pub_sum` = %d ,  `uid` = %d ,  `pub_4_first` = %d ,  `stepup_state` = %d ,  `event_state` = %d ,  `pub_3_first` = %d WHERE  `uid` = %d", pub_sum, uid, pub_4_first, stepup_state, event_state, pub_3_first, uid);
return db_service.sync_execute(buf);
}
string db_PubMgr_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `PubMgr` ( `pub_sum`  ,  `uid`  ,  `pub_4_first`  ,  `stepup_state`  ,  `event_state`  ,  `pub_3_first` ) VALUES ( %d , %d , %d , %d , %d , %d )" , pub_sum, uid, pub_4_first, stepup_state, event_state, pub_3_first);
return string(buf);
}
int db_PubMgr_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PubMgr` ( `pub_sum`  ,  `uid`  ,  `pub_4_first`  ,  `stepup_state`  ,  `event_state`  ,  `pub_3_first` ) VALUES ( %d , %d , %d , %d , %d , %d )" , pub_sum, uid, pub_4_first, stepup_state, event_state, pub_3_first);
return db_service.async_execute(buf);
}
int db_PubMgr_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PubMgr` ( `pub_sum`  ,  `uid`  ,  `pub_4_first`  ,  `stepup_state`  ,  `event_state`  ,  `pub_3_first` ) VALUES ( %d , %d , %d , %d , %d , %d )" , pub_sum, uid, pub_4_first, stepup_state, event_state, pub_3_first);
return db_service.sync_execute(buf);
}
int db_FeedbackFlag_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_FeedbackFlag_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` FROM `FeedbackFlag` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_FeedbackFlag_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` FROM `FeedbackFlag` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_FeedbackFlag_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `FeedbackFlag` SET  `id` = %d ,  `uid` = %d WHERE  `uid` = %d", id, uid, uid);
return db_service.async_execute(buf);
}
int db_FeedbackFlag_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `FeedbackFlag` SET  `id` = %d ,  `uid` = %d WHERE  `uid` = %d", id, uid, uid);
return db_service.sync_execute(buf);
}
string db_FeedbackFlag_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `FeedbackFlag` ( `uid` ) VALUES ( %d )" , uid);
return string(buf);
}
int db_FeedbackFlag_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FeedbackFlag` ( `uid` ) VALUES ( %d )" , uid);
return db_service.async_execute(buf);
}
int db_FeedbackFlag_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FeedbackFlag` ( `uid` ) VALUES ( %d )" , uid);
return db_service.sync_execute(buf);
}
int db_Reward_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;adt_reward=(int)std::atoi(row_[i++].c_str());
given_power_stamp=(int)std::atoi(row_[i++].c_str());
lv_40=(int)std::atoi(row_[i++].c_str());
inv_reward4=(int)std::atoi(row_[i++].c_str());
vip10=(int)std::atoi(row_[i++].c_str());
vip13=(int)std::atoi(row_[i++].c_str());
vip16=(int)std::atoi(row_[i++].c_str());
acc_lg16=(int)std::atoi(row_[i++].c_str());
con_lg6=(int)std::atoi(row_[i++].c_str());
acc_lg18=(int)std::atoi(row_[i++].c_str());
daily_draw_stamp=(int)std::atoi(row_[i++].c_str());
vip7=(int)std::atoi(row_[i++].c_str());
login_rewards = row_[i++];
acc_lg9=(int)std::atoi(row_[i++].c_str());
acc_lg23=(int)std::atoi(row_[i++].c_str());
conequip=(int)std::atoi(row_[i++].c_str());
vip8=(int)std::atoi(row_[i++].c_str());
acc_lg19=(int)std::atoi(row_[i++].c_str());
luckybag_reward = row_[i++];
mcard_event_state=(int)std::atoi(row_[i++].c_str());
vip15=(int)std::atoi(row_[i++].c_str());
wingactivityreward=(int)std::atoi(row_[i++].c_str());
limit_melting=(int)std::atoi(row_[i++].c_str());
vip12=(int)std::atoi(row_[i++].c_str());
vip11=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
acc_lg5=(int)std::atoi(row_[i++].c_str());
lv_70=(int)std::atoi(row_[i++].c_str());
acc_yb2=(int)std::atoi(row_[i++].c_str());
next_online=(int)std::atoi(row_[i++].c_str());
cumu_yb_exp=(int)std::atoi(row_[i++].c_str());
daily_pay_stamp=(int)std::atoi(row_[i++].c_str());
daily_consume_ap_stamp=(int)std::atoi(row_[i++].c_str());
acc_lg6=(int)std::atoi(row_[i++].c_str());
daily_talent=(int)std::atoi(row_[i++].c_str());
daily_consume_ap=(int)std::atoi(row_[i++].c_str());
daily_draw_reward = row_[i++];
acc_yb3=(int)std::atoi(row_[i++].c_str());
acc_yb6=(int)std::atoi(row_[i++].c_str());
acc_yb5=(int)std::atoi(row_[i++].c_str());
mcardtm=(int)std::atoi(row_[i++].c_str());
limit_wing_reward = row_[i++];
acc_lg17=(int)std::atoi(row_[i++].c_str());
double_expedition=(int)std::atoi(row_[i++].c_str());
daily_melting=(int)std::atoi(row_[i++].c_str());
lv_65=(int)std::atoi(row_[i++].c_str());
inv_reward1=(int)std::atoi(row_[i++].c_str());
acc_lg20=(int)std::atoi(row_[i++].c_str());
growing_package_status=(int)std::atoi(row_[i++].c_str());
acc_lg3=(int)std::atoi(row_[i++].c_str());
limit_draw_ten_reward = row_[i++];
first_login=(int)std::atoi(row_[i++].c_str());
vip4=(int)std::atoi(row_[i++].c_str());
online=(int)std::atoi(row_[i++].c_str());
mcardbuytm=(int)std::atoi(row_[i++].c_str());
limit_single_stamp=(int)std::atoi(row_[i++].c_str());
cumulevel=(int)std::atoi(row_[i++].c_str());
con_lg3=(int)std::atoi(row_[i++].c_str());
inv_reward3=(int)std::atoi(row_[i++].c_str());
con_lg4=(int)std::atoi(row_[i++].c_str());
acc_yb4=(int)std::atoi(row_[i++].c_str());
vip5=(int)std::atoi(row_[i++].c_str());
adt_stamp=(int)std::atoi(row_[i++].c_str());
con_lg5=(int)std::atoi(row_[i++].c_str());
can_get_first=(int)std::atoi(row_[i++].c_str());
vip3=(int)std::atoi(row_[i++].c_str());
lv_35=(int)std::atoi(row_[i++].c_str());
acc_lg1=(int)std::atoi(row_[i++].c_str());
lv_55=(int)std::atoi(row_[i++].c_str());
limit_melting_reward = row_[i++];
daily_draw=(int)std::atoi(row_[i++].c_str());
vip17=(int)std::atoi(row_[i++].c_str());
growing_reward = row_[i++];
login_days=(int)std::atoi(row_[i++].c_str());
cumureward=(int)std::atoi(row_[i++].c_str());
acc_lg22=(int)std::atoi(row_[i++].c_str());
vip1=(int)std::atoi(row_[i++].c_str());
vip6=(int)std::atoi(row_[i++].c_str());
acc_yb1=(int)std::atoi(row_[i++].c_str());
acc_lg7=(int)std::atoi(row_[i++].c_str());
acc_yb7=(int)std::atoi(row_[i++].c_str());
lv_60=(int)std::atoi(row_[i++].c_str());
vip18=(int)std::atoi(row_[i++].c_str());
acc_lg14=(int)std::atoi(row_[i++].c_str());
conhero=(int)std::atoi(row_[i++].c_str());
vip_package_stamp=(int)std::atoi(row_[i++].c_str());
wingactivity=(int)std::atoi(row_[i++].c_str());
daily_pay_reward=(int)std::atoi(row_[i++].c_str());
pvelose_times=(int)std::atoi(row_[i++].c_str());
lv_30=(int)std::atoi(row_[i++].c_str());
lv_20=(int)std::atoi(row_[i++].c_str());
limit_draw_ten=(int)std::atoi(row_[i++].c_str());
daily_consume_ap_reward = row_[i++];
cumu_yb_reward=(int)std::atoi(row_[i++].c_str());
acc_lg12=(int)std::atoi(row_[i++].c_str());
con_lg7=(int)std::atoi(row_[i++].c_str());
conlglevel=(int)std::atoi(row_[i++].c_str());
fpreward=(int)std::atoi(row_[i++].c_str());
mcard_event_buy_count=(int)std::atoi(row_[i++].c_str());
mcardn=(int)std::atoi(row_[i++].c_str());
lv_50=(int)std::atoi(row_[i++].c_str());
lv_45=(int)std::atoi(row_[i++].c_str());
limit_talent_reward = row_[i++];
limit_consume_power_stamp=(int)std::atoi(row_[i++].c_str());
limit_recharge_money=(int)std::atoi(row_[i++].c_str());
daily_pay=(int)std::atoi(row_[i++].c_str());
acc_lg4=(int)std::atoi(row_[i++].c_str());
inviter=(int)std::atoi(row_[i++].c_str());
inv_reward2=(int)std::atoi(row_[i++].c_str());
vip9=(int)std::atoi(row_[i++].c_str());
invcode=(int)std::atoi(row_[i++].c_str());
last_login=(int)std::atoi(row_[i++].c_str());
acc_lg15=(int)std::atoi(row_[i++].c_str());
acclgexp=(int)std::atoi(row_[i++].c_str());
week_reward=(int)std::atoi(row_[i++].c_str());
limit_talent=(int)std::atoi(row_[i++].c_str());
daily_talent_stamp=(int)std::atoi(row_[i++].c_str());
daily_talent_reward = row_[i++];
daily_melting_stamp=(int)std::atoi(row_[i++].c_str());
con_lg2=(int)std::atoi(row_[i++].c_str());
daily_melting_reward = row_[i++];
limit_single_reward = row_[i++];
limit_single_recharge=(int)std::atoi(row_[i++].c_str());
limit_recharge_reward = row_[i++];
lv_25=(int)std::atoi(row_[i++].c_str());
limit_consume_power_reward = row_[i++];
limit_consume_power=(int)std::atoi(row_[i++].c_str());
yblevel=(int)std::atoi(row_[i++].c_str());
is_consume_hundred=(int)std::atoi(row_[i++].c_str());
total_login_days=(int)std::atoi(row_[i++].c_str());
con_lg1=(int)std::atoi(row_[i++].c_str());
acc_lg24=(int)std::atoi(row_[i++].c_str());
acc_lg21=(int)std::atoi(row_[i++].c_str());
acc_lg13=(int)std::atoi(row_[i++].c_str());
acc_lg11=(int)std::atoi(row_[i++].c_str());
acc_lg10=(int)std::atoi(row_[i++].c_str());
first_yb=(int)std::atoi(row_[i++].c_str());
acc_lg8=(int)std::atoi(row_[i++].c_str());
vip2=(int)std::atoi(row_[i++].c_str());
acc_lg2=(int)std::atoi(row_[i++].c_str());
vip14=(int)std::atoi(row_[i++].c_str());
acclglevel=(int)std::atoi(row_[i++].c_str());
given_rank_stamp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Reward_t::select_reward(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `adt_reward` , `given_power_stamp` , `lv_40` , `inv_reward4` , `vip10` , `vip13` , `vip16` , `acc_lg16` , `con_lg6` , `acc_lg18` , `daily_draw_stamp` , `vip7` , `login_rewards` , `acc_lg9` , `acc_lg23` , `conequip` , `vip8` , `acc_lg19` , `luckybag_reward` , `mcard_event_state` , `vip15` , `wingactivityreward` , `limit_melting` , `vip12` , `vip11` , `uid` , `acc_lg5` , `lv_70` , `acc_yb2` , `next_online` , `cumu_yb_exp` , `daily_pay_stamp` , `daily_consume_ap_stamp` , `acc_lg6` , `daily_talent` , `daily_consume_ap` , `daily_draw_reward` , `acc_yb3` , `acc_yb6` , `acc_yb5` , `mcardtm` , `limit_wing_reward` , `acc_lg17` , `double_expedition` , `daily_melting` , `lv_65` , `inv_reward1` , `acc_lg20` , `growing_package_status` , `acc_lg3` , `limit_draw_ten_reward` , `first_login` , `vip4` , `online` , `mcardbuytm` , `limit_single_stamp` , `cumulevel` , `con_lg3` , `inv_reward3` , `con_lg4` , `acc_yb4` , `vip5` , `adt_stamp` , `con_lg5` , `can_get_first` , `vip3` , `lv_35` , `acc_lg1` , `lv_55` , `limit_melting_reward` , `daily_draw` , `vip17` , `growing_reward` , `login_days` , `cumureward` , `acc_lg22` , `vip1` , `vip6` , `acc_yb1` , `acc_lg7` , `acc_yb7` , `lv_60` , `vip18` , `acc_lg14` , `conhero` , `vip_package_stamp` , `wingactivity` , `daily_pay_reward` , `pvelose_times` , `lv_30` , `lv_20` , `limit_draw_ten` , `daily_consume_ap_reward` , `cumu_yb_reward` , `acc_lg12` , `con_lg7` , `conlglevel` , `fpreward` , `mcard_event_buy_count` , `mcardn` , `lv_50` , `lv_45` , `limit_talent_reward` , `limit_consume_power_stamp` , `limit_recharge_money` , `daily_pay` , `acc_lg4` , `inviter` , `inv_reward2` , `vip9` , `invcode` , `last_login` , `acc_lg15` , `acclgexp` , `week_reward` , `limit_talent` , `daily_talent_stamp` , `daily_talent_reward` , `daily_melting_stamp` , `con_lg2` , `daily_melting_reward` , `limit_single_reward` , `limit_single_recharge` , `limit_recharge_reward` , `lv_25` , `limit_consume_power_reward` , `limit_consume_power` , `yblevel` , `is_consume_hundred` , `total_login_days` , `con_lg1` , `acc_lg24` , `acc_lg21` , `acc_lg13` , `acc_lg11` , `acc_lg10` , `first_yb` , `acc_lg8` , `vip2` , `acc_lg2` , `vip14` , `acclglevel` , `given_rank_stamp` FROM `Reward` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Reward_t::sync_select_reward(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `adt_reward` , `given_power_stamp` , `lv_40` , `inv_reward4` , `vip10` , `vip13` , `vip16` , `acc_lg16` , `con_lg6` , `acc_lg18` , `daily_draw_stamp` , `vip7` , `login_rewards` , `acc_lg9` , `acc_lg23` , `conequip` , `vip8` , `acc_lg19` , `luckybag_reward` , `mcard_event_state` , `vip15` , `wingactivityreward` , `limit_melting` , `vip12` , `vip11` , `uid` , `acc_lg5` , `lv_70` , `acc_yb2` , `next_online` , `cumu_yb_exp` , `daily_pay_stamp` , `daily_consume_ap_stamp` , `acc_lg6` , `daily_talent` , `daily_consume_ap` , `daily_draw_reward` , `acc_yb3` , `acc_yb6` , `acc_yb5` , `mcardtm` , `limit_wing_reward` , `acc_lg17` , `double_expedition` , `daily_melting` , `lv_65` , `inv_reward1` , `acc_lg20` , `growing_package_status` , `acc_lg3` , `limit_draw_ten_reward` , `first_login` , `vip4` , `online` , `mcardbuytm` , `limit_single_stamp` , `cumulevel` , `con_lg3` , `inv_reward3` , `con_lg4` , `acc_yb4` , `vip5` , `adt_stamp` , `con_lg5` , `can_get_first` , `vip3` , `lv_35` , `acc_lg1` , `lv_55` , `limit_melting_reward` , `daily_draw` , `vip17` , `growing_reward` , `login_days` , `cumureward` , `acc_lg22` , `vip1` , `vip6` , `acc_yb1` , `acc_lg7` , `acc_yb7` , `lv_60` , `vip18` , `acc_lg14` , `conhero` , `vip_package_stamp` , `wingactivity` , `daily_pay_reward` , `pvelose_times` , `lv_30` , `lv_20` , `limit_draw_ten` , `daily_consume_ap_reward` , `cumu_yb_reward` , `acc_lg12` , `con_lg7` , `conlglevel` , `fpreward` , `mcard_event_buy_count` , `mcardn` , `lv_50` , `lv_45` , `limit_talent_reward` , `limit_consume_power_stamp` , `limit_recharge_money` , `daily_pay` , `acc_lg4` , `inviter` , `inv_reward2` , `vip9` , `invcode` , `last_login` , `acc_lg15` , `acclgexp` , `week_reward` , `limit_talent` , `daily_talent_stamp` , `daily_talent_reward` , `daily_melting_stamp` , `con_lg2` , `daily_melting_reward` , `limit_single_reward` , `limit_single_recharge` , `limit_recharge_reward` , `lv_25` , `limit_consume_power_reward` , `limit_consume_power` , `yblevel` , `is_consume_hundred` , `total_login_days` , `con_lg1` , `acc_lg24` , `acc_lg21` , `acc_lg13` , `acc_lg11` , `acc_lg10` , `first_yb` , `acc_lg8` , `vip2` , `acc_lg2` , `vip14` , `acclglevel` , `given_rank_stamp` FROM `Reward` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Reward_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Reward` SET  `adt_reward` = %d ,  `given_power_stamp` = %u ,  `lv_40` = %d ,  `inv_reward4` = %d ,  `vip10` = %d ,  `vip13` = %d ,  `vip16` = %d ,  `acc_lg16` = %d ,  `con_lg6` = %d ,  `acc_lg18` = %d ,  `daily_draw_stamp` = %d ,  `vip7` = %d ,  `login_rewards` = '%s' ,  `acc_lg9` = %d ,  `acc_lg23` = %d ,  `conequip` = %d ,  `vip8` = %d ,  `acc_lg19` = %d ,  `luckybag_reward` = '%s' ,  `mcard_event_state` = %u ,  `vip15` = %d ,  `wingactivityreward` = %d ,  `limit_melting` = %d ,  `vip12` = %d ,  `vip11` = %d ,  `acc_lg5` = %d ,  `lv_70` = %d ,  `acc_yb2` = %d ,  `next_online` = %d ,  `cumu_yb_exp` = %d ,  `daily_pay_stamp` = %d ,  `daily_consume_ap_stamp` = %d ,  `acc_lg6` = %d ,  `daily_talent` = %d ,  `daily_consume_ap` = %d ,  `daily_draw_reward` = '%s' ,  `acc_yb3` = %d ,  `acc_yb6` = %d ,  `acc_yb5` = %d ,  `mcardtm` = %u ,  `limit_wing_reward` = '%s' ,  `acc_lg17` = %d ,  `double_expedition` = %d ,  `daily_melting` = %d ,  `lv_65` = %d ,  `inv_reward1` = %d ,  `acc_lg20` = %d ,  `growing_package_status` = %d ,  `acc_lg3` = %d ,  `limit_draw_ten_reward` = '%s' ,  `first_login` = %u ,  `vip4` = %d ,  `online` = %d ,  `mcardbuytm` = %u ,  `limit_single_stamp` = %d ,  `cumulevel` = %d ,  `con_lg3` = %d ,  `inv_reward3` = %d ,  `con_lg4` = %d ,  `acc_yb4` = %d ,  `vip5` = %d ,  `adt_stamp` = %u ,  `con_lg5` = %d ,  `can_get_first` = %d ,  `vip3` = %d ,  `lv_35` = %d ,  `acc_lg1` = %d ,  `lv_55` = %d ,  `limit_melting_reward` = '%s' ,  `daily_draw` = %d ,  `vip17` = %d ,  `growing_reward` = '%s' ,  `login_days` = %d ,  `cumureward` = %d ,  `acc_lg22` = %d ,  `vip1` = %d ,  `vip6` = %d ,  `acc_yb1` = %d ,  `acc_lg7` = %d ,  `acc_yb7` = %d ,  `lv_60` = %d ,  `vip18` = %d ,  `acc_lg14` = %d ,  `conhero` = %d ,  `vip_package_stamp` = %u ,  `wingactivity` = %d ,  `daily_pay_reward` = %d ,  `pvelose_times` = %d ,  `lv_30` = %d ,  `lv_20` = %d ,  `limit_draw_ten` = %d ,  `daily_consume_ap_reward` = '%s' ,  `cumu_yb_reward` = %d ,  `acc_lg12` = %d ,  `con_lg7` = %d ,  `conlglevel` = %d ,  `fpreward` = %d ,  `mcard_event_buy_count` = %u ,  `mcardn` = %d ,  `lv_50` = %d ,  `lv_45` = %d ,  `limit_talent_reward` = '%s' ,  `limit_consume_power_stamp` = %d ,  `limit_recharge_money` = %d ,  `daily_pay` = %d ,  `acc_lg4` = %d ,  `inviter` = %d ,  `inv_reward2` = %d ,  `vip9` = %d ,  `invcode` = %d ,  `last_login` = %u ,  `acc_lg15` = %d ,  `acclgexp` = %d ,  `week_reward` = %d ,  `limit_talent` = %d ,  `daily_talent_stamp` = %d ,  `daily_talent_reward` = '%s' ,  `daily_melting_stamp` = %d ,  `con_lg2` = %d ,  `daily_melting_reward` = '%s' ,  `limit_single_reward` = '%s' ,  `limit_single_recharge` = %d ,  `limit_recharge_reward` = '%s' ,  `lv_25` = %d ,  `limit_consume_power_reward` = '%s' ,  `limit_consume_power` = %d ,  `yblevel` = %d ,  `is_consume_hundred` = %d ,  `total_login_days` = %d ,  `con_lg1` = %d ,  `acc_lg24` = %d ,  `acc_lg21` = %d ,  `acc_lg13` = %d ,  `acc_lg11` = %d ,  `acc_lg10` = %d ,  `first_yb` = %d ,  `acc_lg8` = %d ,  `vip2` = %d ,  `acc_lg2` = %d ,  `vip14` = %d ,  `acclglevel` = %d ,  `given_rank_stamp` = %u WHERE  `uid` = %d", adt_reward, given_power_stamp, lv_40, inv_reward4, vip10, vip13, vip16, acc_lg16, con_lg6, acc_lg18, daily_draw_stamp, vip7, login_rewards.c_str(), acc_lg9, acc_lg23, conequip, vip8, acc_lg19, luckybag_reward.c_str(), mcard_event_state, vip15, wingactivityreward, limit_melting, vip12, vip11, acc_lg5, lv_70, acc_yb2, next_online, cumu_yb_exp, daily_pay_stamp, daily_consume_ap_stamp, acc_lg6, daily_talent, daily_consume_ap, daily_draw_reward.c_str(), acc_yb3, acc_yb6, acc_yb5, mcardtm, limit_wing_reward.c_str(), acc_lg17, double_expedition, daily_melting, lv_65, inv_reward1, acc_lg20, growing_package_status, acc_lg3, limit_draw_ten_reward.c_str(), first_login, vip4, online, mcardbuytm, limit_single_stamp, cumulevel, con_lg3, inv_reward3, con_lg4, acc_yb4, vip5, adt_stamp, con_lg5, can_get_first, vip3, lv_35, acc_lg1, lv_55, limit_melting_reward.c_str(), daily_draw, vip17, growing_reward.c_str(), login_days, cumureward, acc_lg22, vip1, vip6, acc_yb1, acc_lg7, acc_yb7, lv_60, vip18, acc_lg14, conhero, vip_package_stamp, wingactivity, daily_pay_reward, pvelose_times, lv_30, lv_20, limit_draw_ten, daily_consume_ap_reward.c_str(), cumu_yb_reward, acc_lg12, con_lg7, conlglevel, fpreward, mcard_event_buy_count, mcardn, lv_50, lv_45, limit_talent_reward.c_str(), limit_consume_power_stamp, limit_recharge_money, daily_pay, acc_lg4, inviter, inv_reward2, vip9, invcode, last_login, acc_lg15, acclgexp, week_reward, limit_talent, daily_talent_stamp, daily_talent_reward.c_str(), daily_melting_stamp, con_lg2, daily_melting_reward.c_str(), limit_single_reward.c_str(), limit_single_recharge, limit_recharge_reward.c_str(), lv_25, limit_consume_power_reward.c_str(), limit_consume_power, yblevel, is_consume_hundred, total_login_days, con_lg1, acc_lg24, acc_lg21, acc_lg13, acc_lg11, acc_lg10, first_yb, acc_lg8, vip2, acc_lg2, vip14, acclglevel, given_rank_stamp, uid);
return db_service.async_execute(buf);
}
int db_Reward_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Reward` SET  `adt_reward` = %d ,  `given_power_stamp` = %u ,  `lv_40` = %d ,  `inv_reward4` = %d ,  `vip10` = %d ,  `vip13` = %d ,  `vip16` = %d ,  `acc_lg16` = %d ,  `con_lg6` = %d ,  `acc_lg18` = %d ,  `daily_draw_stamp` = %d ,  `vip7` = %d ,  `login_rewards` = '%s' ,  `acc_lg9` = %d ,  `acc_lg23` = %d ,  `conequip` = %d ,  `vip8` = %d ,  `acc_lg19` = %d ,  `luckybag_reward` = '%s' ,  `mcard_event_state` = %u ,  `vip15` = %d ,  `wingactivityreward` = %d ,  `limit_melting` = %d ,  `vip12` = %d ,  `vip11` = %d ,  `acc_lg5` = %d ,  `lv_70` = %d ,  `acc_yb2` = %d ,  `next_online` = %d ,  `cumu_yb_exp` = %d ,  `daily_pay_stamp` = %d ,  `daily_consume_ap_stamp` = %d ,  `acc_lg6` = %d ,  `daily_talent` = %d ,  `daily_consume_ap` = %d ,  `daily_draw_reward` = '%s' ,  `acc_yb3` = %d ,  `acc_yb6` = %d ,  `acc_yb5` = %d ,  `mcardtm` = %u ,  `limit_wing_reward` = '%s' ,  `acc_lg17` = %d ,  `double_expedition` = %d ,  `daily_melting` = %d ,  `lv_65` = %d ,  `inv_reward1` = %d ,  `acc_lg20` = %d ,  `growing_package_status` = %d ,  `acc_lg3` = %d ,  `limit_draw_ten_reward` = '%s' ,  `first_login` = %u ,  `vip4` = %d ,  `online` = %d ,  `mcardbuytm` = %u ,  `limit_single_stamp` = %d ,  `cumulevel` = %d ,  `con_lg3` = %d ,  `inv_reward3` = %d ,  `con_lg4` = %d ,  `acc_yb4` = %d ,  `vip5` = %d ,  `adt_stamp` = %u ,  `con_lg5` = %d ,  `can_get_first` = %d ,  `vip3` = %d ,  `lv_35` = %d ,  `acc_lg1` = %d ,  `lv_55` = %d ,  `limit_melting_reward` = '%s' ,  `daily_draw` = %d ,  `vip17` = %d ,  `growing_reward` = '%s' ,  `login_days` = %d ,  `cumureward` = %d ,  `acc_lg22` = %d ,  `vip1` = %d ,  `vip6` = %d ,  `acc_yb1` = %d ,  `acc_lg7` = %d ,  `acc_yb7` = %d ,  `lv_60` = %d ,  `vip18` = %d ,  `acc_lg14` = %d ,  `conhero` = %d ,  `vip_package_stamp` = %u ,  `wingactivity` = %d ,  `daily_pay_reward` = %d ,  `pvelose_times` = %d ,  `lv_30` = %d ,  `lv_20` = %d ,  `limit_draw_ten` = %d ,  `daily_consume_ap_reward` = '%s' ,  `cumu_yb_reward` = %d ,  `acc_lg12` = %d ,  `con_lg7` = %d ,  `conlglevel` = %d ,  `fpreward` = %d ,  `mcard_event_buy_count` = %u ,  `mcardn` = %d ,  `lv_50` = %d ,  `lv_45` = %d ,  `limit_talent_reward` = '%s' ,  `limit_consume_power_stamp` = %d ,  `limit_recharge_money` = %d ,  `daily_pay` = %d ,  `acc_lg4` = %d ,  `inviter` = %d ,  `inv_reward2` = %d ,  `vip9` = %d ,  `invcode` = %d ,  `last_login` = %u ,  `acc_lg15` = %d ,  `acclgexp` = %d ,  `week_reward` = %d ,  `limit_talent` = %d ,  `daily_talent_stamp` = %d ,  `daily_talent_reward` = '%s' ,  `daily_melting_stamp` = %d ,  `con_lg2` = %d ,  `daily_melting_reward` = '%s' ,  `limit_single_reward` = '%s' ,  `limit_single_recharge` = %d ,  `limit_recharge_reward` = '%s' ,  `lv_25` = %d ,  `limit_consume_power_reward` = '%s' ,  `limit_consume_power` = %d ,  `yblevel` = %d ,  `is_consume_hundred` = %d ,  `total_login_days` = %d ,  `con_lg1` = %d ,  `acc_lg24` = %d ,  `acc_lg21` = %d ,  `acc_lg13` = %d ,  `acc_lg11` = %d ,  `acc_lg10` = %d ,  `first_yb` = %d ,  `acc_lg8` = %d ,  `vip2` = %d ,  `acc_lg2` = %d ,  `vip14` = %d ,  `acclglevel` = %d ,  `given_rank_stamp` = %u WHERE  `uid` = %d", adt_reward, given_power_stamp, lv_40, inv_reward4, vip10, vip13, vip16, acc_lg16, con_lg6, acc_lg18, daily_draw_stamp, vip7, login_rewards.c_str(), acc_lg9, acc_lg23, conequip, vip8, acc_lg19, luckybag_reward.c_str(), mcard_event_state, vip15, wingactivityreward, limit_melting, vip12, vip11, acc_lg5, lv_70, acc_yb2, next_online, cumu_yb_exp, daily_pay_stamp, daily_consume_ap_stamp, acc_lg6, daily_talent, daily_consume_ap, daily_draw_reward.c_str(), acc_yb3, acc_yb6, acc_yb5, mcardtm, limit_wing_reward.c_str(), acc_lg17, double_expedition, daily_melting, lv_65, inv_reward1, acc_lg20, growing_package_status, acc_lg3, limit_draw_ten_reward.c_str(), first_login, vip4, online, mcardbuytm, limit_single_stamp, cumulevel, con_lg3, inv_reward3, con_lg4, acc_yb4, vip5, adt_stamp, con_lg5, can_get_first, vip3, lv_35, acc_lg1, lv_55, limit_melting_reward.c_str(), daily_draw, vip17, growing_reward.c_str(), login_days, cumureward, acc_lg22, vip1, vip6, acc_yb1, acc_lg7, acc_yb7, lv_60, vip18, acc_lg14, conhero, vip_package_stamp, wingactivity, daily_pay_reward, pvelose_times, lv_30, lv_20, limit_draw_ten, daily_consume_ap_reward.c_str(), cumu_yb_reward, acc_lg12, con_lg7, conlglevel, fpreward, mcard_event_buy_count, mcardn, lv_50, lv_45, limit_talent_reward.c_str(), limit_consume_power_stamp, limit_recharge_money, daily_pay, acc_lg4, inviter, inv_reward2, vip9, invcode, last_login, acc_lg15, acclgexp, week_reward, limit_talent, daily_talent_stamp, daily_talent_reward.c_str(), daily_melting_stamp, con_lg2, daily_melting_reward.c_str(), limit_single_reward.c_str(), limit_single_recharge, limit_recharge_reward.c_str(), lv_25, limit_consume_power_reward.c_str(), limit_consume_power, yblevel, is_consume_hundred, total_login_days, con_lg1, acc_lg24, acc_lg21, acc_lg13, acc_lg11, acc_lg10, first_yb, acc_lg8, vip2, acc_lg2, vip14, acclglevel, given_rank_stamp, uid);
return db_service.sync_execute(buf);
}
int db_Reward_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Reward` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_Reward_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Reward` ( `adt_reward`  ,  `given_power_stamp`  ,  `lv_40`  ,  `inv_reward4`  ,  `vip10`  ,  `vip13`  ,  `vip16`  ,  `acc_lg16`  ,  `con_lg6`  ,  `acc_lg18`  ,  `daily_draw_stamp`  ,  `vip7`  ,  `login_rewards`  ,  `acc_lg9`  ,  `acc_lg23`  ,  `conequip`  ,  `vip8`  ,  `acc_lg19`  ,  `luckybag_reward`  ,  `mcard_event_state`  ,  `vip15`  ,  `wingactivityreward`  ,  `limit_melting`  ,  `vip12`  ,  `vip11`  ,  `uid`  ,  `acc_lg5`  ,  `lv_70`  ,  `acc_yb2`  ,  `next_online`  ,  `cumu_yb_exp`  ,  `daily_pay_stamp`  ,  `daily_consume_ap_stamp`  ,  `acc_lg6`  ,  `daily_talent`  ,  `daily_consume_ap`  ,  `daily_draw_reward`  ,  `acc_yb3`  ,  `acc_yb6`  ,  `acc_yb5`  ,  `mcardtm`  ,  `limit_wing_reward`  ,  `acc_lg17`  ,  `double_expedition`  ,  `daily_melting`  ,  `lv_65`  ,  `inv_reward1`  ,  `acc_lg20`  ,  `growing_package_status`  ,  `acc_lg3`  ,  `limit_draw_ten_reward`  ,  `first_login`  ,  `vip4`  ,  `online`  ,  `mcardbuytm`  ,  `limit_single_stamp`  ,  `cumulevel`  ,  `con_lg3`  ,  `inv_reward3`  ,  `con_lg4`  ,  `acc_yb4`  ,  `vip5`  ,  `adt_stamp`  ,  `con_lg5`  ,  `can_get_first`  ,  `vip3`  ,  `lv_35`  ,  `acc_lg1`  ,  `lv_55`  ,  `limit_melting_reward`  ,  `daily_draw`  ,  `vip17`  ,  `growing_reward`  ,  `login_days`  ,  `cumureward`  ,  `acc_lg22`  ,  `vip1`  ,  `vip6`  ,  `acc_yb1`  ,  `acc_lg7`  ,  `acc_yb7`  ,  `lv_60`  ,  `vip18`  ,  `acc_lg14`  ,  `conhero`  ,  `vip_package_stamp`  ,  `wingactivity`  ,  `daily_pay_reward`  ,  `pvelose_times`  ,  `lv_30`  ,  `lv_20`  ,  `limit_draw_ten`  ,  `daily_consume_ap_reward`  ,  `cumu_yb_reward`  ,  `acc_lg12`  ,  `con_lg7`  ,  `conlglevel`  ,  `fpreward`  ,  `mcard_event_buy_count`  ,  `mcardn`  ,  `lv_50`  ,  `lv_45`  ,  `limit_talent_reward`  ,  `limit_consume_power_stamp`  ,  `limit_recharge_money`  ,  `daily_pay`  ,  `acc_lg4`  ,  `inviter`  ,  `inv_reward2`  ,  `vip9`  ,  `invcode`  ,  `last_login`  ,  `acc_lg15`  ,  `acclgexp`  ,  `week_reward`  ,  `limit_talent`  ,  `daily_talent_stamp`  ,  `daily_talent_reward`  ,  `daily_melting_stamp`  ,  `con_lg2`  ,  `daily_melting_reward`  ,  `limit_single_reward`  ,  `limit_single_recharge`  ,  `limit_recharge_reward`  ,  `lv_25`  ,  `limit_consume_power_reward`  ,  `limit_consume_power`  ,  `yblevel`  ,  `is_consume_hundred`  ,  `total_login_days`  ,  `con_lg1`  ,  `acc_lg24`  ,  `acc_lg21`  ,  `acc_lg13`  ,  `acc_lg11`  ,  `acc_lg10`  ,  `first_yb`  ,  `acc_lg8`  ,  `vip2`  ,  `acc_lg2`  ,  `vip14`  ,  `acclglevel`  ,  `given_rank_stamp` ) VALUES ( %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %u , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u )" , adt_reward, given_power_stamp, lv_40, inv_reward4, vip10, vip13, vip16, acc_lg16, con_lg6, acc_lg18, daily_draw_stamp, vip7, login_rewards.c_str(), acc_lg9, acc_lg23, conequip, vip8, acc_lg19, luckybag_reward.c_str(), mcard_event_state, vip15, wingactivityreward, limit_melting, vip12, vip11, uid, acc_lg5, lv_70, acc_yb2, next_online, cumu_yb_exp, daily_pay_stamp, daily_consume_ap_stamp, acc_lg6, daily_talent, daily_consume_ap, daily_draw_reward.c_str(), acc_yb3, acc_yb6, acc_yb5, mcardtm, limit_wing_reward.c_str(), acc_lg17, double_expedition, daily_melting, lv_65, inv_reward1, acc_lg20, growing_package_status, acc_lg3, limit_draw_ten_reward.c_str(), first_login, vip4, online, mcardbuytm, limit_single_stamp, cumulevel, con_lg3, inv_reward3, con_lg4, acc_yb4, vip5, adt_stamp, con_lg5, can_get_first, vip3, lv_35, acc_lg1, lv_55, limit_melting_reward.c_str(), daily_draw, vip17, growing_reward.c_str(), login_days, cumureward, acc_lg22, vip1, vip6, acc_yb1, acc_lg7, acc_yb7, lv_60, vip18, acc_lg14, conhero, vip_package_stamp, wingactivity, daily_pay_reward, pvelose_times, lv_30, lv_20, limit_draw_ten, daily_consume_ap_reward.c_str(), cumu_yb_reward, acc_lg12, con_lg7, conlglevel, fpreward, mcard_event_buy_count, mcardn, lv_50, lv_45, limit_talent_reward.c_str(), limit_consume_power_stamp, limit_recharge_money, daily_pay, acc_lg4, inviter, inv_reward2, vip9, invcode, last_login, acc_lg15, acclgexp, week_reward, limit_talent, daily_talent_stamp, daily_talent_reward.c_str(), daily_melting_stamp, con_lg2, daily_melting_reward.c_str(), limit_single_reward.c_str(), limit_single_recharge, limit_recharge_reward.c_str(), lv_25, limit_consume_power_reward.c_str(), limit_consume_power, yblevel, is_consume_hundred, total_login_days, con_lg1, acc_lg24, acc_lg21, acc_lg13, acc_lg11, acc_lg10, first_yb, acc_lg8, vip2, acc_lg2, vip14, acclglevel, given_rank_stamp);
return string(buf);
}
int db_Reward_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Reward` ( `adt_reward`  ,  `given_power_stamp`  ,  `lv_40`  ,  `inv_reward4`  ,  `vip10`  ,  `vip13`  ,  `vip16`  ,  `acc_lg16`  ,  `con_lg6`  ,  `acc_lg18`  ,  `daily_draw_stamp`  ,  `vip7`  ,  `login_rewards`  ,  `acc_lg9`  ,  `acc_lg23`  ,  `conequip`  ,  `vip8`  ,  `acc_lg19`  ,  `luckybag_reward`  ,  `mcard_event_state`  ,  `vip15`  ,  `wingactivityreward`  ,  `limit_melting`  ,  `vip12`  ,  `vip11`  ,  `uid`  ,  `acc_lg5`  ,  `lv_70`  ,  `acc_yb2`  ,  `next_online`  ,  `cumu_yb_exp`  ,  `daily_pay_stamp`  ,  `daily_consume_ap_stamp`  ,  `acc_lg6`  ,  `daily_talent`  ,  `daily_consume_ap`  ,  `daily_draw_reward`  ,  `acc_yb3`  ,  `acc_yb6`  ,  `acc_yb5`  ,  `mcardtm`  ,  `limit_wing_reward`  ,  `acc_lg17`  ,  `double_expedition`  ,  `daily_melting`  ,  `lv_65`  ,  `inv_reward1`  ,  `acc_lg20`  ,  `growing_package_status`  ,  `acc_lg3`  ,  `limit_draw_ten_reward`  ,  `first_login`  ,  `vip4`  ,  `online`  ,  `mcardbuytm`  ,  `limit_single_stamp`  ,  `cumulevel`  ,  `con_lg3`  ,  `inv_reward3`  ,  `con_lg4`  ,  `acc_yb4`  ,  `vip5`  ,  `adt_stamp`  ,  `con_lg5`  ,  `can_get_first`  ,  `vip3`  ,  `lv_35`  ,  `acc_lg1`  ,  `lv_55`  ,  `limit_melting_reward`  ,  `daily_draw`  ,  `vip17`  ,  `growing_reward`  ,  `login_days`  ,  `cumureward`  ,  `acc_lg22`  ,  `vip1`  ,  `vip6`  ,  `acc_yb1`  ,  `acc_lg7`  ,  `acc_yb7`  ,  `lv_60`  ,  `vip18`  ,  `acc_lg14`  ,  `conhero`  ,  `vip_package_stamp`  ,  `wingactivity`  ,  `daily_pay_reward`  ,  `pvelose_times`  ,  `lv_30`  ,  `lv_20`  ,  `limit_draw_ten`  ,  `daily_consume_ap_reward`  ,  `cumu_yb_reward`  ,  `acc_lg12`  ,  `con_lg7`  ,  `conlglevel`  ,  `fpreward`  ,  `mcard_event_buy_count`  ,  `mcardn`  ,  `lv_50`  ,  `lv_45`  ,  `limit_talent_reward`  ,  `limit_consume_power_stamp`  ,  `limit_recharge_money`  ,  `daily_pay`  ,  `acc_lg4`  ,  `inviter`  ,  `inv_reward2`  ,  `vip9`  ,  `invcode`  ,  `last_login`  ,  `acc_lg15`  ,  `acclgexp`  ,  `week_reward`  ,  `limit_talent`  ,  `daily_talent_stamp`  ,  `daily_talent_reward`  ,  `daily_melting_stamp`  ,  `con_lg2`  ,  `daily_melting_reward`  ,  `limit_single_reward`  ,  `limit_single_recharge`  ,  `limit_recharge_reward`  ,  `lv_25`  ,  `limit_consume_power_reward`  ,  `limit_consume_power`  ,  `yblevel`  ,  `is_consume_hundred`  ,  `total_login_days`  ,  `con_lg1`  ,  `acc_lg24`  ,  `acc_lg21`  ,  `acc_lg13`  ,  `acc_lg11`  ,  `acc_lg10`  ,  `first_yb`  ,  `acc_lg8`  ,  `vip2`  ,  `acc_lg2`  ,  `vip14`  ,  `acclglevel`  ,  `given_rank_stamp` ) VALUES ( %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %u , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u )" , adt_reward, given_power_stamp, lv_40, inv_reward4, vip10, vip13, vip16, acc_lg16, con_lg6, acc_lg18, daily_draw_stamp, vip7, login_rewards.c_str(), acc_lg9, acc_lg23, conequip, vip8, acc_lg19, luckybag_reward.c_str(), mcard_event_state, vip15, wingactivityreward, limit_melting, vip12, vip11, uid, acc_lg5, lv_70, acc_yb2, next_online, cumu_yb_exp, daily_pay_stamp, daily_consume_ap_stamp, acc_lg6, daily_talent, daily_consume_ap, daily_draw_reward.c_str(), acc_yb3, acc_yb6, acc_yb5, mcardtm, limit_wing_reward.c_str(), acc_lg17, double_expedition, daily_melting, lv_65, inv_reward1, acc_lg20, growing_package_status, acc_lg3, limit_draw_ten_reward.c_str(), first_login, vip4, online, mcardbuytm, limit_single_stamp, cumulevel, con_lg3, inv_reward3, con_lg4, acc_yb4, vip5, adt_stamp, con_lg5, can_get_first, vip3, lv_35, acc_lg1, lv_55, limit_melting_reward.c_str(), daily_draw, vip17, growing_reward.c_str(), login_days, cumureward, acc_lg22, vip1, vip6, acc_yb1, acc_lg7, acc_yb7, lv_60, vip18, acc_lg14, conhero, vip_package_stamp, wingactivity, daily_pay_reward, pvelose_times, lv_30, lv_20, limit_draw_ten, daily_consume_ap_reward.c_str(), cumu_yb_reward, acc_lg12, con_lg7, conlglevel, fpreward, mcard_event_buy_count, mcardn, lv_50, lv_45, limit_talent_reward.c_str(), limit_consume_power_stamp, limit_recharge_money, daily_pay, acc_lg4, inviter, inv_reward2, vip9, invcode, last_login, acc_lg15, acclgexp, week_reward, limit_talent, daily_talent_stamp, daily_talent_reward.c_str(), daily_melting_stamp, con_lg2, daily_melting_reward.c_str(), limit_single_reward.c_str(), limit_single_recharge, limit_recharge_reward.c_str(), lv_25, limit_consume_power_reward.c_str(), limit_consume_power, yblevel, is_consume_hundred, total_login_days, con_lg1, acc_lg24, acc_lg21, acc_lg13, acc_lg11, acc_lg10, first_yb, acc_lg8, vip2, acc_lg2, vip14, acclglevel, given_rank_stamp);
return db_service.async_execute(buf);
}
int db_Reward_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Reward` ( `adt_reward`  ,  `given_power_stamp`  ,  `lv_40`  ,  `inv_reward4`  ,  `vip10`  ,  `vip13`  ,  `vip16`  ,  `acc_lg16`  ,  `con_lg6`  ,  `acc_lg18`  ,  `daily_draw_stamp`  ,  `vip7`  ,  `login_rewards`  ,  `acc_lg9`  ,  `acc_lg23`  ,  `conequip`  ,  `vip8`  ,  `acc_lg19`  ,  `luckybag_reward`  ,  `mcard_event_state`  ,  `vip15`  ,  `wingactivityreward`  ,  `limit_melting`  ,  `vip12`  ,  `vip11`  ,  `uid`  ,  `acc_lg5`  ,  `lv_70`  ,  `acc_yb2`  ,  `next_online`  ,  `cumu_yb_exp`  ,  `daily_pay_stamp`  ,  `daily_consume_ap_stamp`  ,  `acc_lg6`  ,  `daily_talent`  ,  `daily_consume_ap`  ,  `daily_draw_reward`  ,  `acc_yb3`  ,  `acc_yb6`  ,  `acc_yb5`  ,  `mcardtm`  ,  `limit_wing_reward`  ,  `acc_lg17`  ,  `double_expedition`  ,  `daily_melting`  ,  `lv_65`  ,  `inv_reward1`  ,  `acc_lg20`  ,  `growing_package_status`  ,  `acc_lg3`  ,  `limit_draw_ten_reward`  ,  `first_login`  ,  `vip4`  ,  `online`  ,  `mcardbuytm`  ,  `limit_single_stamp`  ,  `cumulevel`  ,  `con_lg3`  ,  `inv_reward3`  ,  `con_lg4`  ,  `acc_yb4`  ,  `vip5`  ,  `adt_stamp`  ,  `con_lg5`  ,  `can_get_first`  ,  `vip3`  ,  `lv_35`  ,  `acc_lg1`  ,  `lv_55`  ,  `limit_melting_reward`  ,  `daily_draw`  ,  `vip17`  ,  `growing_reward`  ,  `login_days`  ,  `cumureward`  ,  `acc_lg22`  ,  `vip1`  ,  `vip6`  ,  `acc_yb1`  ,  `acc_lg7`  ,  `acc_yb7`  ,  `lv_60`  ,  `vip18`  ,  `acc_lg14`  ,  `conhero`  ,  `vip_package_stamp`  ,  `wingactivity`  ,  `daily_pay_reward`  ,  `pvelose_times`  ,  `lv_30`  ,  `lv_20`  ,  `limit_draw_ten`  ,  `daily_consume_ap_reward`  ,  `cumu_yb_reward`  ,  `acc_lg12`  ,  `con_lg7`  ,  `conlglevel`  ,  `fpreward`  ,  `mcard_event_buy_count`  ,  `mcardn`  ,  `lv_50`  ,  `lv_45`  ,  `limit_talent_reward`  ,  `limit_consume_power_stamp`  ,  `limit_recharge_money`  ,  `daily_pay`  ,  `acc_lg4`  ,  `inviter`  ,  `inv_reward2`  ,  `vip9`  ,  `invcode`  ,  `last_login`  ,  `acc_lg15`  ,  `acclgexp`  ,  `week_reward`  ,  `limit_talent`  ,  `daily_talent_stamp`  ,  `daily_talent_reward`  ,  `daily_melting_stamp`  ,  `con_lg2`  ,  `daily_melting_reward`  ,  `limit_single_reward`  ,  `limit_single_recharge`  ,  `limit_recharge_reward`  ,  `lv_25`  ,  `limit_consume_power_reward`  ,  `limit_consume_power`  ,  `yblevel`  ,  `is_consume_hundred`  ,  `total_login_days`  ,  `con_lg1`  ,  `acc_lg24`  ,  `acc_lg21`  ,  `acc_lg13`  ,  `acc_lg11`  ,  `acc_lg10`  ,  `first_yb`  ,  `acc_lg8`  ,  `vip2`  ,  `acc_lg2`  ,  `vip14`  ,  `acclglevel`  ,  `given_rank_stamp` ) VALUES ( %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %u , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %u , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , '%s' , %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u )" , adt_reward, given_power_stamp, lv_40, inv_reward4, vip10, vip13, vip16, acc_lg16, con_lg6, acc_lg18, daily_draw_stamp, vip7, login_rewards.c_str(), acc_lg9, acc_lg23, conequip, vip8, acc_lg19, luckybag_reward.c_str(), mcard_event_state, vip15, wingactivityreward, limit_melting, vip12, vip11, uid, acc_lg5, lv_70, acc_yb2, next_online, cumu_yb_exp, daily_pay_stamp, daily_consume_ap_stamp, acc_lg6, daily_talent, daily_consume_ap, daily_draw_reward.c_str(), acc_yb3, acc_yb6, acc_yb5, mcardtm, limit_wing_reward.c_str(), acc_lg17, double_expedition, daily_melting, lv_65, inv_reward1, acc_lg20, growing_package_status, acc_lg3, limit_draw_ten_reward.c_str(), first_login, vip4, online, mcardbuytm, limit_single_stamp, cumulevel, con_lg3, inv_reward3, con_lg4, acc_yb4, vip5, adt_stamp, con_lg5, can_get_first, vip3, lv_35, acc_lg1, lv_55, limit_melting_reward.c_str(), daily_draw, vip17, growing_reward.c_str(), login_days, cumureward, acc_lg22, vip1, vip6, acc_yb1, acc_lg7, acc_yb7, lv_60, vip18, acc_lg14, conhero, vip_package_stamp, wingactivity, daily_pay_reward, pvelose_times, lv_30, lv_20, limit_draw_ten, daily_consume_ap_reward.c_str(), cumu_yb_reward, acc_lg12, con_lg7, conlglevel, fpreward, mcard_event_buy_count, mcardn, lv_50, lv_45, limit_talent_reward.c_str(), limit_consume_power_stamp, limit_recharge_money, daily_pay, acc_lg4, inviter, inv_reward2, vip9, invcode, last_login, acc_lg15, acclgexp, week_reward, limit_talent, daily_talent_stamp, daily_talent_reward.c_str(), daily_melting_stamp, con_lg2, daily_melting_reward.c_str(), limit_single_reward.c_str(), limit_single_recharge, limit_recharge_reward.c_str(), lv_25, limit_consume_power_reward.c_str(), limit_consume_power, yblevel, is_consume_hundred, total_login_days, con_lg1, acc_lg24, acc_lg21, acc_lg13, acc_lg11, acc_lg10, first_yb, acc_lg8, vip2, acc_lg2, vip14, acclglevel, given_rank_stamp);
return db_service.sync_execute(buf);
}
int db_UserInfo_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;spshopbuy=(int)std::atoi(row_[i++].c_str());
useFlower=(int)std::atoi(row_[i++].c_str());
nextquestid=(int)std::atoi(row_[i++].c_str());
spshoprefresh=(int)std::atoi(row_[i++].c_str());
last_power_stamp=(int)std::atoi(row_[i++].c_str());
sceneid=(int)std::atoi(row_[i++].c_str());
eliteid=(int)std::atoi(row_[i++].c_str());
nickname = row_[i++];
lovelevel=(int)std::atoi(row_[i++].c_str());
draw_ten_diamond=(int)std::atoi(row_[i++].c_str());
totaltime=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
naviClickNum2=(int)std::atoi(row_[i++].c_str());
potential_5=(int)std::atoi(row_[i++].c_str());
draw_num=(int)std::atoi(row_[i++].c_str());
energy=(int)std::atoi(row_[i++].c_str());
headid=(int)std::atoi(row_[i++].c_str());
zodiacid=(int)std::atoi(row_[i++].c_str());
flush1times=(int)std::atoi(row_[i++].c_str());
flush2times=(int)std::atoi(row_[i++].c_str());
npcshoptime3=(int)std::atoi(row_[i++].c_str());
unhonor=(int)std::atoi(row_[i++].c_str());
flush2round=(int)std::atoi(row_[i++].c_str());
flush1round=(int)std::atoi(row_[i++].c_str());
kanban=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
hhresid=(int)std::atoi(row_[i++].c_str());
sign_cost=(int)std::atoi(row_[i++].c_str());
fpoint=(int)std::atoi(row_[i++].c_str());
chronicle_sum=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
battlexp=(int)std::atoi(row_[i++].c_str());
questid=(int)std::atoi(row_[i++].c_str());
utype=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
rank=(int)std::atoi(row_[i++].c_str());
createtime=(int)std::atoi(row_[i++].c_str());
hm_maxid=(int)std::atoi(row_[i++].c_str());
sign_daily=(int)std::atoi(row_[i++].c_str());
useFlowerStamp=(int)std::atoi(row_[i++].c_str());
resetFlowerStamp=(int)std::atoi(row_[i++].c_str());
draw_reward = row_[i++];
caveid=(int)std::atoi(row_[i++].c_str());
npcshopbuy=(int)std::atoi(row_[i++].c_str());
vipexp=(int)std::atoi(row_[i++].c_str());
payyb=(int)std::atoi(row_[i++].c_str());
limitround=(int)std::atoi(row_[i++].c_str());
boxe=(int)std::atoi(row_[i++].c_str());
spshoptime=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
sign_month=(int)std::atoi(row_[i++].c_str());
quality=(int)std::atoi(row_[i++].c_str());
isnew=(int)std::atoi(row_[i++].c_str());
twoprecord=(int)std::atoi(row_[i++].c_str());
naviClickNum1=(int)std::atoi(row_[i++].c_str());
helphero=(int)std::atoi(row_[i++].c_str());
soul=(int)std::atoi(row_[i++].c_str());
power=(int)std::atoi(row_[i++].c_str());
npcshoptime1=(int)std::atoi(row_[i++].c_str());
potential_2=(int)std::atoi(row_[i++].c_str());
round_stars_reward = row_[i++];
elite_roundid=(int)std::atoi(row_[i++].c_str());
npcshop=(int)std::atoi(row_[i++].c_str());
model=(int)std::atoi(row_[i++].c_str());
elite_round_times = row_[i++];
expeditioncoin=(int)std::atoi(row_[i++].c_str());
meritorious=(int)std::atoi(row_[i++].c_str());
bagn=(int)std::atoi(row_[i++].c_str());
fp=(int)std::atoi(row_[i++].c_str());
honor=(int)std::atoi(row_[i++].c_str());
zodiacstamp=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
flush2first=(int)std::atoi(row_[i++].c_str());
numFlower=(int)std::atoi(row_[i++].c_str());
func=(int)std::atoi(row_[i++].c_str());
firstpay=(int)std::atoi(row_[i++].c_str());
boxn=(int)std::atoi(row_[i++].c_str());
isnewlv=(int)std::atoi(row_[i++].c_str());
roundstars = row_[i++];
potential_3=(int)std::atoi(row_[i++].c_str());
frd=(int)std::atoi(row_[i++].c_str());
viplevel=(int)std::atoi(row_[i++].c_str());
m_rank=(int)std::atoi(row_[i++].c_str());
elite_reset_times = row_[i++];
titlelv=(int)std::atoi(row_[i++].c_str());
lastquit=(int)std::atoi(row_[i++].c_str());
treasure=(int)std::atoi(row_[i++].c_str());
kanban_type=(int)std::atoi(row_[i++].c_str());
roundid=(int)std::atoi(row_[i++].c_str());
runechip=(int)std::atoi(row_[i++].c_str());
specicalshop=(int)std::atoi(row_[i++].c_str());
potential_4=(int)std::atoi(row_[i++].c_str());
potential_1=(int)std::atoi(row_[i++].c_str());
npcshoptime2=(int)std::atoi(row_[i++].c_str());
flush3times=(int)std::atoi(row_[i++].c_str());
lovevalue=(int)std::atoi(row_[i++].c_str());
flush3round=(int)std::atoi(row_[i++].c_str());
npcshoprefresh=(int)std::atoi(row_[i++].c_str());
freeyb=(int)std::atoi(row_[i++].c_str());
gold=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_UserInfo_t::select_user(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `spshopbuy` , `useFlower` , `nextquestid` , `spshoprefresh` , `last_power_stamp` , `sceneid` , `eliteid` , `nickname` , `lovelevel` , `draw_ten_diamond` , `totaltime` , `grade` , `naviClickNum2` , `potential_5` , `draw_num` , `energy` , `headid` , `zodiacid` , `flush1times` , `flush2times` , `npcshoptime3` , `unhonor` , `flush2round` , `flush1round` , `kanban` , `hostnum` , `hhresid` , `sign_cost` , `fpoint` , `chronicle_sum` , `resid` , `battlexp` , `questid` , `utype` , `uid` , `rank` , `createtime` , `hm_maxid` , `sign_daily` , `useFlowerStamp` , `resetFlowerStamp` , `draw_reward` , `caveid` , `npcshopbuy` , `vipexp` , `payyb` , `limitround` , `boxe` , `spshoptime` , `aid` , `sign_month` , `quality` , `isnew` , `twoprecord` , `naviClickNum1` , `helphero` , `soul` , `power` , `npcshoptime1` , `potential_2` , `round_stars_reward` , `elite_roundid` , `npcshop` , `model` , `elite_round_times` , `expeditioncoin` , `meritorious` , `bagn` , `fp` , `honor` , `zodiacstamp` , `exp` , `flush2first` , `numFlower` , `func` , `firstpay` , `boxn` , `isnewlv` , `roundstars` , `potential_3` , `frd` , `viplevel` , `m_rank` , `elite_reset_times` , `titlelv` , `lastquit` , `treasure` , `kanban_type` , `roundid` , `runechip` , `specicalshop` , `potential_4` , `potential_1` , `npcshoptime2` , `flush3times` , `lovevalue` , `flush3round` , `npcshoprefresh` , `freeyb` , `gold` FROM `UserInfo` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserInfo_t::sync_select_user(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `spshopbuy` , `useFlower` , `nextquestid` , `spshoprefresh` , `last_power_stamp` , `sceneid` , `eliteid` , `nickname` , `lovelevel` , `draw_ten_diamond` , `totaltime` , `grade` , `naviClickNum2` , `potential_5` , `draw_num` , `energy` , `headid` , `zodiacid` , `flush1times` , `flush2times` , `npcshoptime3` , `unhonor` , `flush2round` , `flush1round` , `kanban` , `hostnum` , `hhresid` , `sign_cost` , `fpoint` , `chronicle_sum` , `resid` , `battlexp` , `questid` , `utype` , `uid` , `rank` , `createtime` , `hm_maxid` , `sign_daily` , `useFlowerStamp` , `resetFlowerStamp` , `draw_reward` , `caveid` , `npcshopbuy` , `vipexp` , `payyb` , `limitround` , `boxe` , `spshoptime` , `aid` , `sign_month` , `quality` , `isnew` , `twoprecord` , `naviClickNum1` , `helphero` , `soul` , `power` , `npcshoptime1` , `potential_2` , `round_stars_reward` , `elite_roundid` , `npcshop` , `model` , `elite_round_times` , `expeditioncoin` , `meritorious` , `bagn` , `fp` , `honor` , `zodiacstamp` , `exp` , `flush2first` , `numFlower` , `func` , `firstpay` , `boxn` , `isnewlv` , `roundstars` , `potential_3` , `frd` , `viplevel` , `m_rank` , `elite_reset_times` , `titlelv` , `lastquit` , `treasure` , `kanban_type` , `roundid` , `runechip` , `specicalshop` , `potential_4` , `potential_1` , `npcshoptime2` , `flush3times` , `lovevalue` , `flush3round` , `npcshoprefresh` , `freeyb` , `gold` FROM `UserInfo` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserInfo_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `UserInfo` SET  `spshopbuy` = %d ,  `useFlower` = %d ,  `nextquestid` = %d ,  `spshoprefresh` = %d ,  `last_power_stamp` = %d ,  `sceneid` = %d ,  `eliteid` = %d ,  `lovelevel` = %d ,  `draw_ten_diamond` = %d ,  `totaltime` = %u ,  `grade` = %d ,  `naviClickNum2` = %d ,  `potential_5` = %d ,  `draw_num` = %d ,  `energy` = %d ,  `headid` = %d ,  `zodiacid` = %d ,  `flush1times` = %d ,  `flush2times` = %d ,  `npcshoptime3` = %u ,  `unhonor` = %d ,  `flush2round` = %d ,  `flush1round` = %d ,  `kanban` = %d ,  `hostnum` = %d ,  `hhresid` = %d ,  `sign_cost` = %d ,  `fpoint` = %d ,  `chronicle_sum` = %u ,  `battlexp` = %d ,  `questid` = %d ,  `utype` = %d ,  `rank` = %d ,  `createtime` = %u ,  `hm_maxid` = %d ,  `sign_daily` = %u ,  `useFlowerStamp` = %u ,  `resetFlowerStamp` = %u ,  `draw_reward` = '%s' ,  `caveid` = %d ,  `npcshopbuy` = %d ,  `vipexp` = %d ,  `payyb` = %d ,  `limitround` = %d ,  `boxe` = %d ,  `spshoptime` = %u ,  `sign_month` = %d ,  `quality` = %d ,  `isnew` = %d ,  `twoprecord` = %d ,  `naviClickNum1` = %d ,  `helphero` = %d ,  `soul` = %d ,  `power` = %d ,  `npcshoptime1` = %u ,  `potential_2` = %d ,  `round_stars_reward` = '%s' ,  `elite_roundid` = %d ,  `npcshop` = %u ,  `model` = %d ,  `elite_round_times` = '%s' ,  `expeditioncoin` = %d ,  `meritorious` = %d ,  `bagn` = %d ,  `fp` = %d ,  `honor` = %d ,  `zodiacstamp` = %u ,  `exp` = %d ,  `flush2first` = %d ,  `numFlower` = %d ,  `func` = %lu ,  `firstpay` = %d ,  `boxn` = %d ,  `isnewlv` = %d ,  `roundstars` = '%s' ,  `potential_3` = %d ,  `frd` = %d ,  `viplevel` = %d ,  `m_rank` = %d ,  `elite_reset_times` = '%s' ,  `titlelv` = %d ,  `lastquit` = %u ,  `treasure` = %d ,  `kanban_type` = %d ,  `roundid` = %d ,  `runechip` = %d ,  `specicalshop` = %d ,  `potential_4` = %d ,  `potential_1` = %d ,  `npcshoptime2` = %u ,  `flush3times` = %d ,  `lovevalue` = %d ,  `flush3round` = %d ,  `npcshoprefresh` = %d ,  `freeyb` = %d ,  `gold` = %d WHERE  `uid` = %d", spshopbuy, useFlower, nextquestid, spshoprefresh, last_power_stamp, sceneid, eliteid, lovelevel, draw_ten_diamond, totaltime, grade, naviClickNum2, potential_5, draw_num, energy, headid, zodiacid, flush1times, flush2times, npcshoptime3, unhonor, flush2round, flush1round, kanban, hostnum, hhresid, sign_cost, fpoint, chronicle_sum, battlexp, questid, utype, rank, createtime, hm_maxid, sign_daily, useFlowerStamp, resetFlowerStamp, draw_reward.c_str(), caveid, npcshopbuy, vipexp, payyb, limitround, boxe, spshoptime, sign_month, quality, isnew, twoprecord, naviClickNum1, helphero, soul, power, npcshoptime1, potential_2, round_stars_reward.c_str(), elite_roundid, npcshop, model, elite_round_times.c_str(), expeditioncoin, meritorious, bagn, fp, honor, zodiacstamp, exp, flush2first, numFlower, func, firstpay, boxn, isnewlv, roundstars.c_str(), potential_3, frd, viplevel, m_rank, elite_reset_times.c_str(), titlelv, lastquit, treasure, kanban_type, roundid, runechip, specicalshop, potential_4, potential_1, npcshoptime2, flush3times, lovevalue, flush3round, npcshoprefresh, freeyb, gold, uid);
return db_service.async_execute(buf);
}
int db_UserInfo_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `UserInfo` SET  `spshopbuy` = %d ,  `useFlower` = %d ,  `nextquestid` = %d ,  `spshoprefresh` = %d ,  `last_power_stamp` = %d ,  `sceneid` = %d ,  `eliteid` = %d ,  `lovelevel` = %d ,  `draw_ten_diamond` = %d ,  `totaltime` = %u ,  `grade` = %d ,  `naviClickNum2` = %d ,  `potential_5` = %d ,  `draw_num` = %d ,  `energy` = %d ,  `headid` = %d ,  `zodiacid` = %d ,  `flush1times` = %d ,  `flush2times` = %d ,  `npcshoptime3` = %u ,  `unhonor` = %d ,  `flush2round` = %d ,  `flush1round` = %d ,  `kanban` = %d ,  `hostnum` = %d ,  `hhresid` = %d ,  `sign_cost` = %d ,  `fpoint` = %d ,  `chronicle_sum` = %u ,  `battlexp` = %d ,  `questid` = %d ,  `utype` = %d ,  `rank` = %d ,  `createtime` = %u ,  `hm_maxid` = %d ,  `sign_daily` = %u ,  `useFlowerStamp` = %u ,  `resetFlowerStamp` = %u ,  `draw_reward` = '%s' ,  `caveid` = %d ,  `npcshopbuy` = %d ,  `vipexp` = %d ,  `payyb` = %d ,  `limitround` = %d ,  `boxe` = %d ,  `spshoptime` = %u ,  `sign_month` = %d ,  `quality` = %d ,  `isnew` = %d ,  `twoprecord` = %d ,  `naviClickNum1` = %d ,  `helphero` = %d ,  `soul` = %d ,  `power` = %d ,  `npcshoptime1` = %u ,  `potential_2` = %d ,  `round_stars_reward` = '%s' ,  `elite_roundid` = %d ,  `npcshop` = %u ,  `model` = %d ,  `elite_round_times` = '%s' ,  `expeditioncoin` = %d ,  `meritorious` = %d ,  `bagn` = %d ,  `fp` = %d ,  `honor` = %d ,  `zodiacstamp` = %u ,  `exp` = %d ,  `flush2first` = %d ,  `numFlower` = %d ,  `func` = %lu ,  `firstpay` = %d ,  `boxn` = %d ,  `isnewlv` = %d ,  `roundstars` = '%s' ,  `potential_3` = %d ,  `frd` = %d ,  `viplevel` = %d ,  `m_rank` = %d ,  `elite_reset_times` = '%s' ,  `titlelv` = %d ,  `lastquit` = %u ,  `treasure` = %d ,  `kanban_type` = %d ,  `roundid` = %d ,  `runechip` = %d ,  `specicalshop` = %d ,  `potential_4` = %d ,  `potential_1` = %d ,  `npcshoptime2` = %u ,  `flush3times` = %d ,  `lovevalue` = %d ,  `flush3round` = %d ,  `npcshoprefresh` = %d ,  `freeyb` = %d ,  `gold` = %d WHERE  `uid` = %d", spshopbuy, useFlower, nextquestid, spshoprefresh, last_power_stamp, sceneid, eliteid, lovelevel, draw_ten_diamond, totaltime, grade, naviClickNum2, potential_5, draw_num, energy, headid, zodiacid, flush1times, flush2times, npcshoptime3, unhonor, flush2round, flush1round, kanban, hostnum, hhresid, sign_cost, fpoint, chronicle_sum, battlexp, questid, utype, rank, createtime, hm_maxid, sign_daily, useFlowerStamp, resetFlowerStamp, draw_reward.c_str(), caveid, npcshopbuy, vipexp, payyb, limitround, boxe, spshoptime, sign_month, quality, isnew, twoprecord, naviClickNum1, helphero, soul, power, npcshoptime1, potential_2, round_stars_reward.c_str(), elite_roundid, npcshop, model, elite_round_times.c_str(), expeditioncoin, meritorious, bagn, fp, honor, zodiacstamp, exp, flush2first, numFlower, func, firstpay, boxn, isnewlv, roundstars.c_str(), potential_3, frd, viplevel, m_rank, elite_reset_times.c_str(), titlelv, lastquit, treasure, kanban_type, roundid, runechip, specicalshop, potential_4, potential_1, npcshoptime2, flush3times, lovevalue, flush3round, npcshoprefresh, freeyb, gold, uid);
return db_service.sync_execute(buf);
}
int db_UserInfo_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `UserInfo` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_UserInfo_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserInfo` ( `spshopbuy`  ,  `useFlower`  ,  `nextquestid`  ,  `spshoprefresh`  ,  `last_power_stamp`  ,  `sceneid`  ,  `eliteid`  ,  `nickname`  ,  `lovelevel`  ,  `draw_ten_diamond`  ,  `totaltime`  ,  `grade`  ,  `naviClickNum2`  ,  `potential_5`  ,  `draw_num`  ,  `energy`  ,  `headid`  ,  `zodiacid`  ,  `flush1times`  ,  `flush2times`  ,  `npcshoptime3`  ,  `unhonor`  ,  `flush2round`  ,  `flush1round`  ,  `kanban`  ,  `hostnum`  ,  `hhresid`  ,  `sign_cost`  ,  `fpoint`  ,  `chronicle_sum`  ,  `resid`  ,  `battlexp`  ,  `questid`  ,  `utype`  ,  `uid`  ,  `rank`  ,  `createtime`  ,  `hm_maxid`  ,  `sign_daily`  ,  `useFlowerStamp`  ,  `resetFlowerStamp`  ,  `draw_reward`  ,  `caveid`  ,  `npcshopbuy`  ,  `vipexp`  ,  `payyb`  ,  `limitround`  ,  `boxe`  ,  `spshoptime`  ,  `aid`  ,  `sign_month`  ,  `quality`  ,  `isnew`  ,  `twoprecord`  ,  `naviClickNum1`  ,  `helphero`  ,  `soul`  ,  `power`  ,  `npcshoptime1`  ,  `potential_2`  ,  `round_stars_reward`  ,  `elite_roundid`  ,  `npcshop`  ,  `model`  ,  `elite_round_times`  ,  `expeditioncoin`  ,  `meritorious`  ,  `bagn`  ,  `fp`  ,  `honor`  ,  `zodiacstamp`  ,  `exp`  ,  `flush2first`  ,  `numFlower`  ,  `func`  ,  `firstpay`  ,  `boxn`  ,  `isnewlv`  ,  `roundstars`  ,  `potential_3`  ,  `frd`  ,  `viplevel`  ,  `m_rank`  ,  `elite_reset_times`  ,  `titlelv`  ,  `lastquit`  ,  `treasure`  ,  `kanban_type`  ,  `roundid`  ,  `runechip`  ,  `specicalshop`  ,  `potential_4`  ,  `potential_1`  ,  `npcshoptime2`  ,  `flush3times`  ,  `lovevalue`  ,  `flush3round`  ,  `npcshoprefresh`  ,  `freeyb`  ,  `gold` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %u , %d , %u , %u , %u , '%s' , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , %lu , %d , %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d )" , spshopbuy, useFlower, nextquestid, spshoprefresh, last_power_stamp, sceneid, eliteid, nickname.c_str(), lovelevel, draw_ten_diamond, totaltime, grade, naviClickNum2, potential_5, draw_num, energy, headid, zodiacid, flush1times, flush2times, npcshoptime3, unhonor, flush2round, flush1round, kanban, hostnum, hhresid, sign_cost, fpoint, chronicle_sum, resid, battlexp, questid, utype, uid, rank, createtime, hm_maxid, sign_daily, useFlowerStamp, resetFlowerStamp, draw_reward.c_str(), caveid, npcshopbuy, vipexp, payyb, limitround, boxe, spshoptime, aid, sign_month, quality, isnew, twoprecord, naviClickNum1, helphero, soul, power, npcshoptime1, potential_2, round_stars_reward.c_str(), elite_roundid, npcshop, model, elite_round_times.c_str(), expeditioncoin, meritorious, bagn, fp, honor, zodiacstamp, exp, flush2first, numFlower, func, firstpay, boxn, isnewlv, roundstars.c_str(), potential_3, frd, viplevel, m_rank, elite_reset_times.c_str(), titlelv, lastquit, treasure, kanban_type, roundid, runechip, specicalshop, potential_4, potential_1, npcshoptime2, flush3times, lovevalue, flush3round, npcshoprefresh, freeyb, gold);
return string(buf);
}
int db_UserInfo_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserInfo` ( `spshopbuy`  ,  `useFlower`  ,  `nextquestid`  ,  `spshoprefresh`  ,  `last_power_stamp`  ,  `sceneid`  ,  `eliteid`  ,  `nickname`  ,  `lovelevel`  ,  `draw_ten_diamond`  ,  `totaltime`  ,  `grade`  ,  `naviClickNum2`  ,  `potential_5`  ,  `draw_num`  ,  `energy`  ,  `headid`  ,  `zodiacid`  ,  `flush1times`  ,  `flush2times`  ,  `npcshoptime3`  ,  `unhonor`  ,  `flush2round`  ,  `flush1round`  ,  `kanban`  ,  `hostnum`  ,  `hhresid`  ,  `sign_cost`  ,  `fpoint`  ,  `chronicle_sum`  ,  `resid`  ,  `battlexp`  ,  `questid`  ,  `utype`  ,  `uid`  ,  `rank`  ,  `createtime`  ,  `hm_maxid`  ,  `sign_daily`  ,  `useFlowerStamp`  ,  `resetFlowerStamp`  ,  `draw_reward`  ,  `caveid`  ,  `npcshopbuy`  ,  `vipexp`  ,  `payyb`  ,  `limitround`  ,  `boxe`  ,  `spshoptime`  ,  `aid`  ,  `sign_month`  ,  `quality`  ,  `isnew`  ,  `twoprecord`  ,  `naviClickNum1`  ,  `helphero`  ,  `soul`  ,  `power`  ,  `npcshoptime1`  ,  `potential_2`  ,  `round_stars_reward`  ,  `elite_roundid`  ,  `npcshop`  ,  `model`  ,  `elite_round_times`  ,  `expeditioncoin`  ,  `meritorious`  ,  `bagn`  ,  `fp`  ,  `honor`  ,  `zodiacstamp`  ,  `exp`  ,  `flush2first`  ,  `numFlower`  ,  `func`  ,  `firstpay`  ,  `boxn`  ,  `isnewlv`  ,  `roundstars`  ,  `potential_3`  ,  `frd`  ,  `viplevel`  ,  `m_rank`  ,  `elite_reset_times`  ,  `titlelv`  ,  `lastquit`  ,  `treasure`  ,  `kanban_type`  ,  `roundid`  ,  `runechip`  ,  `specicalshop`  ,  `potential_4`  ,  `potential_1`  ,  `npcshoptime2`  ,  `flush3times`  ,  `lovevalue`  ,  `flush3round`  ,  `npcshoprefresh`  ,  `freeyb`  ,  `gold` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %u , %d , %u , %u , %u , '%s' , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , %lu , %d , %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d )" , spshopbuy, useFlower, nextquestid, spshoprefresh, last_power_stamp, sceneid, eliteid, nickname.c_str(), lovelevel, draw_ten_diamond, totaltime, grade, naviClickNum2, potential_5, draw_num, energy, headid, zodiacid, flush1times, flush2times, npcshoptime3, unhonor, flush2round, flush1round, kanban, hostnum, hhresid, sign_cost, fpoint, chronicle_sum, resid, battlexp, questid, utype, uid, rank, createtime, hm_maxid, sign_daily, useFlowerStamp, resetFlowerStamp, draw_reward.c_str(), caveid, npcshopbuy, vipexp, payyb, limitround, boxe, spshoptime, aid, sign_month, quality, isnew, twoprecord, naviClickNum1, helphero, soul, power, npcshoptime1, potential_2, round_stars_reward.c_str(), elite_roundid, npcshop, model, elite_round_times.c_str(), expeditioncoin, meritorious, bagn, fp, honor, zodiacstamp, exp, flush2first, numFlower, func, firstpay, boxn, isnewlv, roundstars.c_str(), potential_3, frd, viplevel, m_rank, elite_reset_times.c_str(), titlelv, lastquit, treasure, kanban_type, roundid, runechip, specicalshop, potential_4, potential_1, npcshoptime2, flush3times, lovevalue, flush3round, npcshoprefresh, freeyb, gold);
return db_service.async_execute(buf);
}
int db_UserInfo_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserInfo` ( `spshopbuy`  ,  `useFlower`  ,  `nextquestid`  ,  `spshoprefresh`  ,  `last_power_stamp`  ,  `sceneid`  ,  `eliteid`  ,  `nickname`  ,  `lovelevel`  ,  `draw_ten_diamond`  ,  `totaltime`  ,  `grade`  ,  `naviClickNum2`  ,  `potential_5`  ,  `draw_num`  ,  `energy`  ,  `headid`  ,  `zodiacid`  ,  `flush1times`  ,  `flush2times`  ,  `npcshoptime3`  ,  `unhonor`  ,  `flush2round`  ,  `flush1round`  ,  `kanban`  ,  `hostnum`  ,  `hhresid`  ,  `sign_cost`  ,  `fpoint`  ,  `chronicle_sum`  ,  `resid`  ,  `battlexp`  ,  `questid`  ,  `utype`  ,  `uid`  ,  `rank`  ,  `createtime`  ,  `hm_maxid`  ,  `sign_daily`  ,  `useFlowerStamp`  ,  `resetFlowerStamp`  ,  `draw_reward`  ,  `caveid`  ,  `npcshopbuy`  ,  `vipexp`  ,  `payyb`  ,  `limitround`  ,  `boxe`  ,  `spshoptime`  ,  `aid`  ,  `sign_month`  ,  `quality`  ,  `isnew`  ,  `twoprecord`  ,  `naviClickNum1`  ,  `helphero`  ,  `soul`  ,  `power`  ,  `npcshoptime1`  ,  `potential_2`  ,  `round_stars_reward`  ,  `elite_roundid`  ,  `npcshop`  ,  `model`  ,  `elite_round_times`  ,  `expeditioncoin`  ,  `meritorious`  ,  `bagn`  ,  `fp`  ,  `honor`  ,  `zodiacstamp`  ,  `exp`  ,  `flush2first`  ,  `numFlower`  ,  `func`  ,  `firstpay`  ,  `boxn`  ,  `isnewlv`  ,  `roundstars`  ,  `potential_3`  ,  `frd`  ,  `viplevel`  ,  `m_rank`  ,  `elite_reset_times`  ,  `titlelv`  ,  `lastquit`  ,  `treasure`  ,  `kanban_type`  ,  `roundid`  ,  `runechip`  ,  `specicalshop`  ,  `potential_4`  ,  `potential_1`  ,  `npcshoptime2`  ,  `flush3times`  ,  `lovevalue`  ,  `flush3round`  ,  `npcshoprefresh`  ,  `freeyb`  ,  `gold` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %u , %d , %u , %u , %u , '%s' , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d , %d , %d , %d , %u , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , %u , %d , %d , %d , %lu , %d , %d , %d , '%s' , %d , %d , %d , %d , '%s' , %d , %u , %d , %d , %d , %d , %d , %d , %d , %u , %d , %d , %d , %d , %d , %d )" , spshopbuy, useFlower, nextquestid, spshoprefresh, last_power_stamp, sceneid, eliteid, nickname.c_str(), lovelevel, draw_ten_diamond, totaltime, grade, naviClickNum2, potential_5, draw_num, energy, headid, zodiacid, flush1times, flush2times, npcshoptime3, unhonor, flush2round, flush1round, kanban, hostnum, hhresid, sign_cost, fpoint, chronicle_sum, resid, battlexp, questid, utype, uid, rank, createtime, hm_maxid, sign_daily, useFlowerStamp, resetFlowerStamp, draw_reward.c_str(), caveid, npcshopbuy, vipexp, payyb, limitround, boxe, spshoptime, aid, sign_month, quality, isnew, twoprecord, naviClickNum1, helphero, soul, power, npcshoptime1, potential_2, round_stars_reward.c_str(), elite_roundid, npcshop, model, elite_round_times.c_str(), expeditioncoin, meritorious, bagn, fp, honor, zodiacstamp, exp, flush2first, numFlower, func, firstpay, boxn, isnewlv, roundstars.c_str(), potential_3, frd, viplevel, m_rank, elite_reset_times.c_str(), titlelv, lastquit, treasure, kanban_type, roundid, runechip, specicalshop, potential_4, potential_1, npcshoptime2, flush3times, lovevalue, flush3round, npcshoprefresh, freeyb, gold);
return db_service.sync_execute(buf);
}
int db_Partner_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;potential_4=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
naviClickNum1=(int)std::atoi(row_[i++].c_str());
potential_5=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
potential_2=(int)std::atoi(row_[i++].c_str());
naviClickNum2=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
potential_3=(int)std::atoi(row_[i++].c_str());
lovevalue=(int)std::atoi(row_[i++].c_str());
potential_1=(int)std::atoi(row_[i++].c_str());
lovelevel=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
quality=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Partner_t::select_partner(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `potential_4` , `pid` , `resid` , `naviClickNum1` , `potential_5` , `grade` , `potential_2` , `naviClickNum2` , `uid` , `potential_3` , `lovevalue` , `potential_1` , `lovelevel` , `exp` , `quality` FROM `Partner` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Partner_t::sync_select_partner(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `potential_4` , `pid` , `resid` , `naviClickNum1` , `potential_5` , `grade` , `potential_2` , `naviClickNum2` , `uid` , `potential_3` , `lovevalue` , `potential_1` , `lovelevel` , `exp` , `quality` FROM `Partner` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Partner_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Partner` SET  `potential_4` = %d ,  `naviClickNum1` = %d ,  `potential_5` = %d ,  `grade` = %d ,  `potential_2` = %d ,  `naviClickNum2` = %d ,  `potential_3` = %d ,  `lovevalue` = %d ,  `potential_1` = %d ,  `lovelevel` = %d ,  `exp` = %d ,  `quality` = %d WHERE  `uid` = %d AND  `pid` = %d", potential_4, naviClickNum1, potential_5, grade, potential_2, naviClickNum2, potential_3, lovevalue, potential_1, lovelevel, exp, quality, uid, pid);
return db_service.async_execute(buf);
}
int db_Partner_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Partner` SET  `potential_4` = %d ,  `naviClickNum1` = %d ,  `potential_5` = %d ,  `grade` = %d ,  `potential_2` = %d ,  `naviClickNum2` = %d ,  `potential_3` = %d ,  `lovevalue` = %d ,  `potential_1` = %d ,  `lovelevel` = %d ,  `exp` = %d ,  `quality` = %d WHERE  `uid` = %d AND  `pid` = %d", potential_4, naviClickNum1, potential_5, grade, potential_2, naviClickNum2, potential_3, lovevalue, potential_1, lovelevel, exp, quality, uid, pid);
return db_service.sync_execute(buf);
}
int db_Partner_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Partner` WHERE  `uid` = %d AND  `pid` = %d", uid, pid);
return db_service.async_execute(buf);
}
string db_Partner_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Partner` ( `potential_4`  ,  `pid`  ,  `resid`  ,  `naviClickNum1`  ,  `potential_5`  ,  `grade`  ,  `potential_2`  ,  `naviClickNum2`  ,  `uid`  ,  `potential_3`  ,  `lovevalue`  ,  `potential_1`  ,  `lovelevel`  ,  `exp`  ,  `quality` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , potential_4, pid, resid, naviClickNum1, potential_5, grade, potential_2, naviClickNum2, uid, potential_3, lovevalue, potential_1, lovelevel, exp, quality);
return string(buf);
}
int db_Partner_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Partner` ( `potential_4`  ,  `pid`  ,  `resid`  ,  `naviClickNum1`  ,  `potential_5`  ,  `grade`  ,  `potential_2`  ,  `naviClickNum2`  ,  `uid`  ,  `potential_3`  ,  `lovevalue`  ,  `potential_1`  ,  `lovelevel`  ,  `exp`  ,  `quality` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , potential_4, pid, resid, naviClickNum1, potential_5, grade, potential_2, naviClickNum2, uid, potential_3, lovevalue, potential_1, lovelevel, exp, quality);
return db_service.async_execute(buf);
}
int db_Partner_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Partner` ( `potential_4`  ,  `pid`  ,  `resid`  ,  `naviClickNum1`  ,  `potential_5`  ,  `grade`  ,  `potential_2`  ,  `naviClickNum2`  ,  `uid`  ,  `potential_3`  ,  `lovevalue`  ,  `potential_1`  ,  `lovelevel`  ,  `exp`  ,  `quality` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , potential_4, pid, resid, naviClickNum1, potential_5, grade, potential_2, naviClickNum2, uid, potential_3, lovevalue, potential_1, lovelevel, exp, quality);
return db_service.sync_execute(buf);
}
int db_UnPrestigeShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;buystamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_UnPrestigeShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `UnPrestigeShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UnPrestigeShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `UnPrestigeShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UnPrestigeShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `UnPrestigeShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.async_execute(buf);
}
int db_UnPrestigeShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `UnPrestigeShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.sync_execute(buf);
}
string db_UnPrestigeShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `UnPrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return string(buf);
}
int db_UnPrestigeShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UnPrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.async_execute(buf);
}
int db_UnPrestigeShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UnPrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.sync_execute(buf);
}
int db_Report_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
reportuid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Report_t::select(const int32_t& uid_, const int32_t& reportuid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `reportuid` FROM `Report` WHERE  `uid` = %d AND  `reportuid` = %d", uid_, reportuid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Report_t::sync_select(const int32_t& uid_, const int32_t& reportuid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `reportuid` FROM `Report` WHERE  `uid` = %d AND  `reportuid` = %d", uid_, reportuid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Report_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Report` SET  `id` = %d ,  `uid` = %d ,  `reportuid` = %d WHERE  `uid` = %d AND  `reportuid` = %d", id, uid, reportuid, uid, reportuid);
return db_service.async_execute(buf);
}
int db_Report_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Report` SET  `id` = %d ,  `uid` = %d ,  `reportuid` = %d WHERE  `uid` = %d AND  `reportuid` = %d", id, uid, reportuid, uid, reportuid);
return db_service.sync_execute(buf);
}
string db_Report_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Report` ( `uid`  ,  `reportuid` ) VALUES ( %d , %d )" , uid, reportuid);
return string(buf);
}
int db_Report_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Report` ( `uid`  ,  `reportuid` ) VALUES ( %d , %d )" , uid, reportuid);
return db_service.async_execute(buf);
}
int db_Report_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Report` ( `uid`  ,  `reportuid` ) VALUES ( %d , %d )" , uid, reportuid);
return db_service.sync_execute(buf);
}
int db_GMail_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;count1=(int)std::atoi(row_[i++].c_str());
mid=(int)std::atoi(row_[i++].c_str());
flag=(int)std::atoi(row_[i++].c_str());
validtime=(int)std::atoi(row_[i++].c_str());
opened=(int)std::atoi(row_[i++].c_str());
info = row_[i++];
count5=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
sender = row_[i++];
item5=(int)std::atoi(row_[i++].c_str());
count3=(int)std::atoi(row_[i++].c_str());
count2=(int)std::atoi(row_[i++].c_str());
rewarded=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
title = row_[i++];
count4=(int)std::atoi(row_[i++].c_str());
item4=(int)std::atoi(row_[i++].c_str());
item3=(int)std::atoi(row_[i++].c_str());
item2=(int)std::atoi(row_[i++].c_str());
item1=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GMail_t::select_mid(const int32_t& mid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `count1` , `mid` , `flag` , `validtime` , `opened` , `info` , `count5` , `stamp` , `resid` , `sender` , `item5` , `count3` , `count2` , `rewarded` , `uid` , `title` , `count4` , `item4` , `item3` , `item2` , `item1` FROM `GMail` WHERE  `mid` = %d", mid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GMail_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `count1` , `mid` , `flag` , `validtime` , `opened` , `info` , `count5` , `stamp` , `resid` , `sender` , `item5` , `count3` , `count2` , `rewarded` , `uid` , `title` , `count4` , `item4` , `item3` , `item2` , `item1` FROM `GMail` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GMail_t::sync_select_mid(const int32_t& mid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `count1` , `mid` , `flag` , `validtime` , `opened` , `info` , `count5` , `stamp` , `resid` , `sender` , `item5` , `count3` , `count2` , `rewarded` , `uid` , `title` , `count4` , `item4` , `item3` , `item2` , `item1` FROM `GMail` WHERE  `mid` = %d", mid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GMail_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `count1` , `mid` , `flag` , `validtime` , `opened` , `info` , `count5` , `stamp` , `resid` , `sender` , `item5` , `count3` , `count2` , `rewarded` , `uid` , `title` , `count4` , `item4` , `item3` , `item2` , `item1` FROM `GMail` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GMail_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GMail` SET  `count1` = %d ,  `flag` = %d ,  `validtime` = %d ,  `opened` = %d ,  `info` = '%s' ,  `count5` = %d ,  `stamp` = %u ,  `resid` = %d ,  `sender` = '%s' ,  `item5` = %d ,  `count3` = %d ,  `count2` = %d ,  `rewarded` = %d ,  `title` = '%s' ,  `count4` = %d ,  `item4` = %d ,  `item3` = %d ,  `item2` = %d ,  `item1` = %d WHERE  `uid` = %d AND  `mid` = %d", count1, flag, validtime, opened, info.c_str(), count5, stamp, resid, sender.c_str(), item5, count3, count2, rewarded, title.c_str(), count4, item4, item3, item2, item1, uid, mid);
return db_service.async_execute(buf);
}
int db_GMail_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GMail` SET  `count1` = %d ,  `flag` = %d ,  `validtime` = %d ,  `opened` = %d ,  `info` = '%s' ,  `count5` = %d ,  `stamp` = %u ,  `resid` = %d ,  `sender` = '%s' ,  `item5` = %d ,  `count3` = %d ,  `count2` = %d ,  `rewarded` = %d ,  `title` = '%s' ,  `count4` = %d ,  `item4` = %d ,  `item3` = %d ,  `item2` = %d ,  `item1` = %d WHERE  `uid` = %d AND  `mid` = %d", count1, flag, validtime, opened, info.c_str(), count5, stamp, resid, sender.c_str(), item5, count3, count2, rewarded, title.c_str(), count4, item4, item3, item2, item1, uid, mid);
return db_service.sync_execute(buf);
}
int db_GMail_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `GMail` WHERE  `uid` = %d AND  `mid` = %d", uid, mid);
return db_service.async_execute(buf);
}
string db_GMail_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GMail` ( `count1`  ,  `mid`  ,  `flag`  ,  `validtime`  ,  `opened`  ,  `info`  ,  `count5`  ,  `stamp`  ,  `resid`  ,  `sender`  ,  `item5`  ,  `count3`  ,  `count2`  ,  `rewarded`  ,  `uid`  ,  `title`  ,  `count4`  ,  `item4`  ,  `item3`  ,  `item2`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , count1, mid, flag, validtime, opened, info.c_str(), count5, stamp, resid, sender.c_str(), item5, count3, count2, rewarded, uid, title.c_str(), count4, item4, item3, item2, item1);
return string(buf);
}
int db_GMail_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GMail` ( `count1`  ,  `mid`  ,  `flag`  ,  `validtime`  ,  `opened`  ,  `info`  ,  `count5`  ,  `stamp`  ,  `resid`  ,  `sender`  ,  `item5`  ,  `count3`  ,  `count2`  ,  `rewarded`  ,  `uid`  ,  `title`  ,  `count4`  ,  `item4`  ,  `item3`  ,  `item2`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , count1, mid, flag, validtime, opened, info.c_str(), count5, stamp, resid, sender.c_str(), item5, count3, count2, rewarded, uid, title.c_str(), count4, item4, item3, item2, item1);
return db_service.async_execute(buf);
}
int db_GMail_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GMail` ( `count1`  ,  `mid`  ,  `flag`  ,  `validtime`  ,  `opened`  ,  `info`  ,  `count5`  ,  `stamp`  ,  `resid`  ,  `sender`  ,  `item5`  ,  `count3`  ,  `count2`  ,  `rewarded`  ,  `uid`  ,  `title`  ,  `count4`  ,  `item4`  ,  `item3`  ,  `item2`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %u , %d , '%s' , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , count1, mid, flag, validtime, opened, info.c_str(), count5, stamp, resid, sender.c_str(), item5, count3, count2, rewarded, uid, title.c_str(), count4, item4, item3, item2, item1);
return db_service.sync_execute(buf);
}
int db_Item_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;itid=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Item_t::select_item_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `itid` , `uid` , `count` , `resid` FROM `Item` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Item_t::sync_select_item_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `itid` , `uid` , `count` , `resid` FROM `Item` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Item_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Item` SET  `count` = %d WHERE  `uid` = %d AND  `itid` = %d", count, uid, itid);
return db_service.async_execute(buf);
}
int db_Item_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Item` SET  `count` = %d WHERE  `uid` = %d AND  `itid` = %d", count, uid, itid);
return db_service.sync_execute(buf);
}
int db_Item_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Item` WHERE  `uid` = %d AND  `itid` = %d", uid, itid);
return db_service.async_execute(buf);
}
string db_Item_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Item` ( `itid`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , itid, uid, count, resid);
return string(buf);
}
int db_Item_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Item` ( `itid`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , itid, uid, count, resid);
return db_service.async_execute(buf);
}
int db_Item_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Item` ( `itid`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , itid, uid, count, resid);
return db_service.sync_execute(buf);
}
int db_GangBossDamage_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
lv=(int)std::atoi(row_[i++].c_str());
old_scene=(int)std::atoi(row_[i++].c_str());
last_batt_time=(int)std::atoi(row_[i++].c_str());
ggid=(int)std::atoi(row_[i++].c_str());
in_scene=(int)std::atoi(row_[i++].c_str());
damage=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GangBossDamage_t::select_ggid(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `uid` , `lv` , `old_scene` , `last_batt_time` , `ggid` , `in_scene` , `damage` FROM `GangBossDamage` WHERE  `ggid` = %d", ggid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBossDamage_t::sync_select_ggid(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `uid` , `lv` , `old_scene` , `last_batt_time` , `ggid` , `in_scene` , `damage` FROM `GangBossDamage` WHERE  `ggid` = %d", ggid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBossDamage_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBossDamage` SET  `nickname` = '%s' ,  `lv` = %d ,  `old_scene` = %d ,  `last_batt_time` = %d ,  `ggid` = %d ,  `in_scene` = %d ,  `damage` = %d WHERE  `uid` = %d", nickname.c_str(), lv, old_scene, last_batt_time, ggid, in_scene, damage, uid);
return db_service.async_execute(buf);
}
int db_GangBossDamage_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBossDamage` SET  `nickname` = '%s' ,  `lv` = %d ,  `old_scene` = %d ,  `last_batt_time` = %d ,  `ggid` = %d ,  `in_scene` = %d ,  `damage` = %d WHERE  `uid` = %d", nickname.c_str(), lv, old_scene, last_batt_time, ggid, in_scene, damage, uid);
return db_service.sync_execute(buf);
}
string db_GangBossDamage_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossDamage` ( `nickname`  ,  `uid`  ,  `lv`  ,  `old_scene`  ,  `last_batt_time`  ,  `ggid`  ,  `in_scene`  ,  `damage` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), uid, lv, old_scene, last_batt_time, ggid, in_scene, damage);
return string(buf);
}
int db_GangBossDamage_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossDamage` ( `nickname`  ,  `uid`  ,  `lv`  ,  `old_scene`  ,  `last_batt_time`  ,  `ggid`  ,  `in_scene`  ,  `damage` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), uid, lv, old_scene, last_batt_time, ggid, in_scene, damage);
return db_service.async_execute(buf);
}
int db_GangBossDamage_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBossDamage` ( `nickname`  ,  `uid`  ,  `lv`  ,  `old_scene`  ,  `last_batt_time`  ,  `ggid`  ,  `in_scene`  ,  `damage` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), uid, lv, old_scene, last_batt_time, ggid, in_scene, damage);
return db_service.sync_execute(buf);
}
int db_Equip_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;strenlevel=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
gresid2=(int)std::atoi(row_[i++].c_str());
eid=(int)std::atoi(row_[i++].c_str());
gresid4=(int)std::atoi(row_[i++].c_str());
isweared=(int)std::atoi(row_[i++].c_str());
gresid5=(int)std::atoi(row_[i++].c_str());
gresid3=(int)std::atoi(row_[i++].c_str());
gresid1=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Equip_t::select_equip_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `strenlevel` , `pid` , `resid` , `gresid2` , `eid` , `gresid4` , `isweared` , `gresid5` , `gresid3` , `gresid1` , `uid` FROM `Equip` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Equip_t::sync_select_equip_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `strenlevel` , `pid` , `resid` , `gresid2` , `eid` , `gresid4` , `isweared` , `gresid5` , `gresid3` , `gresid1` , `uid` FROM `Equip` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Equip_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Equip` SET  `strenlevel` = %d ,  `pid` = %d ,  `resid` = %d ,  `gresid2` = %d ,  `gresid4` = %d ,  `isweared` = %d ,  `gresid5` = %d ,  `gresid3` = %d ,  `gresid1` = %d WHERE  `uid` = %d AND  `eid` = %d", strenlevel, pid, resid, gresid2, gresid4, isweared, gresid5, gresid3, gresid1, uid, eid);
return db_service.async_execute(buf);
}
int db_Equip_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Equip` SET  `strenlevel` = %d ,  `pid` = %d ,  `resid` = %d ,  `gresid2` = %d ,  `gresid4` = %d ,  `isweared` = %d ,  `gresid5` = %d ,  `gresid3` = %d ,  `gresid1` = %d WHERE  `uid` = %d AND  `eid` = %d", strenlevel, pid, resid, gresid2, gresid4, isweared, gresid5, gresid3, gresid1, uid, eid);
return db_service.sync_execute(buf);
}
int db_Equip_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Equip` WHERE  `uid` = %d AND  `eid` = %d", uid, eid);
return db_service.async_execute(buf);
}
string db_Equip_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Equip` ( `strenlevel`  ,  `pid`  ,  `resid`  ,  `gresid2`  ,  `eid`  ,  `gresid4`  ,  `isweared`  ,  `gresid5`  ,  `gresid3`  ,  `gresid1`  ,  `uid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , strenlevel, pid, resid, gresid2, eid, gresid4, isweared, gresid5, gresid3, gresid1, uid);
return string(buf);
}
int db_Equip_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Equip` ( `strenlevel`  ,  `pid`  ,  `resid`  ,  `gresid2`  ,  `eid`  ,  `gresid4`  ,  `isweared`  ,  `gresid5`  ,  `gresid3`  ,  `gresid1`  ,  `uid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , strenlevel, pid, resid, gresid2, eid, gresid4, isweared, gresid5, gresid3, gresid1, uid);
return db_service.async_execute(buf);
}
int db_Equip_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Equip` ( `strenlevel`  ,  `pid`  ,  `resid`  ,  `gresid2`  ,  `eid`  ,  `gresid4`  ,  `isweared`  ,  `gresid5`  ,  `gresid3`  ,  `gresid1`  ,  `uid` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , strenlevel, pid, resid, gresid2, eid, gresid4, isweared, gresid5, gresid3, gresid1, uid);
return db_service.sync_execute(buf);
}
int db_GangBoss_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;m_join_count=(int)std::atoi(row_[i++].c_str());
m_prepare=(int)std::atoi(row_[i++].c_str());
is_event=(int)std::atoi(row_[i++].c_str());
m_resid=(int)std::atoi(row_[i++].c_str());
top_cut=(int)std::atoi(row_[i++].c_str());
m_hp=(int)std::atoi(row_[i++].c_str());
m_end=(int)std::atoi(row_[i++].c_str());
m_spawned=(int)std::atoi(row_[i++].c_str());
m_grade=(int)std::atoi(row_[i++].c_str());
ggid=(int)std::atoi(row_[i++].c_str());
top = row_[i++];
m_max_hp=(int)std::atoi(row_[i++].c_str());
m_spawne_time=(int)std::atoi(row_[i++].c_str());
m_start=(int)std::atoi(row_[i++].c_str());
reward_send=(int)std::atoi(row_[i++].c_str());
m_cur_count=(int)std::atoi(row_[i++].c_str());
is_join_reward=(int)std::atoi(row_[i++].c_str());
m_damage=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GangBoss_t::select_ggid(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `m_join_count` , `m_prepare` , `is_event` , `m_resid` , `top_cut` , `m_hp` , `m_end` , `m_spawned` , `m_grade` , `ggid` , `top` , `m_max_hp` , `m_spawne_time` , `m_start` , `reward_send` , `m_cur_count` , `is_join_reward` , `m_damage` FROM `GangBoss` WHERE  `ggid` = %d", ggid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBoss_t::sync_select_ggid(const int32_t& ggid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `m_join_count` , `m_prepare` , `is_event` , `m_resid` , `top_cut` , `m_hp` , `m_end` , `m_spawned` , `m_grade` , `ggid` , `top` , `m_max_hp` , `m_spawne_time` , `m_start` , `reward_send` , `m_cur_count` , `is_join_reward` , `m_damage` FROM `GangBoss` WHERE  `ggid` = %d", ggid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangBoss_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBoss` SET  `m_join_count` = %d ,  `m_prepare` = %d ,  `is_event` = %d ,  `m_resid` = %d ,  `top_cut` = %d ,  `m_hp` = %d ,  `m_end` = %d ,  `m_spawned` = %d ,  `m_grade` = %d ,  `top` = '%s' ,  `m_max_hp` = %d ,  `m_spawne_time` = %d ,  `m_start` = %d ,  `reward_send` = %d ,  `m_cur_count` = %d ,  `is_join_reward` = %d ,  `m_damage` = %d WHERE  `ggid` = %d", m_join_count, m_prepare, is_event, m_resid, top_cut, m_hp, m_end, m_spawned, m_grade, top.c_str(), m_max_hp, m_spawne_time, m_start, reward_send, m_cur_count, is_join_reward, m_damage, ggid);
return db_service.async_execute(buf);
}
int db_GangBoss_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GangBoss` SET  `m_join_count` = %d ,  `m_prepare` = %d ,  `is_event` = %d ,  `m_resid` = %d ,  `top_cut` = %d ,  `m_hp` = %d ,  `m_end` = %d ,  `m_spawned` = %d ,  `m_grade` = %d ,  `top` = '%s' ,  `m_max_hp` = %d ,  `m_spawne_time` = %d ,  `m_start` = %d ,  `reward_send` = %d ,  `m_cur_count` = %d ,  `is_join_reward` = %d ,  `m_damage` = %d WHERE  `ggid` = %d", m_join_count, m_prepare, is_event, m_resid, top_cut, m_hp, m_end, m_spawned, m_grade, top.c_str(), m_max_hp, m_spawne_time, m_start, reward_send, m_cur_count, is_join_reward, m_damage, ggid);
return db_service.sync_execute(buf);
}
string db_GangBoss_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBoss` ( `m_join_count`  ,  `m_prepare`  ,  `is_event`  ,  `m_resid`  ,  `top_cut`  ,  `m_hp`  ,  `m_end`  ,  `m_spawned`  ,  `m_grade`  ,  `ggid`  ,  `top`  ,  `m_max_hp`  ,  `m_spawne_time`  ,  `m_start`  ,  `reward_send`  ,  `m_cur_count`  ,  `is_join_reward`  ,  `m_damage` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , m_join_count, m_prepare, is_event, m_resid, top_cut, m_hp, m_end, m_spawned, m_grade, ggid, top.c_str(), m_max_hp, m_spawne_time, m_start, reward_send, m_cur_count, is_join_reward, m_damage);
return string(buf);
}
int db_GangBoss_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBoss` ( `m_join_count`  ,  `m_prepare`  ,  `is_event`  ,  `m_resid`  ,  `top_cut`  ,  `m_hp`  ,  `m_end`  ,  `m_spawned`  ,  `m_grade`  ,  `ggid`  ,  `top`  ,  `m_max_hp`  ,  `m_spawne_time`  ,  `m_start`  ,  `reward_send`  ,  `m_cur_count`  ,  `is_join_reward`  ,  `m_damage` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , m_join_count, m_prepare, is_event, m_resid, top_cut, m_hp, m_end, m_spawned, m_grade, ggid, top.c_str(), m_max_hp, m_spawne_time, m_start, reward_send, m_cur_count, is_join_reward, m_damage);
return db_service.async_execute(buf);
}
int db_GangBoss_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangBoss` ( `m_join_count`  ,  `m_prepare`  ,  `is_event`  ,  `m_resid`  ,  `top_cut`  ,  `m_hp`  ,  `m_end`  ,  `m_spawned`  ,  `m_grade`  ,  `ggid`  ,  `top`  ,  `m_max_hp`  ,  `m_spawne_time`  ,  `m_start`  ,  `reward_send`  ,  `m_cur_count`  ,  `is_join_reward`  ,  `m_damage` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' , %d , %d , %d , %d , %d , %d , %d )" , m_join_count, m_prepare, is_event, m_resid, top_cut, m_hp, m_end, m_spawned, m_grade, ggid, top.c_str(), m_max_hp, m_spawne_time, m_start, reward_send, m_cur_count, is_join_reward, m_damage);
return db_service.sync_execute(buf);
}
int db_PartnerChip_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_PartnerChip_t::select_partnerchip(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `resid` FROM `PartnerChip` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PartnerChip_t::sync_select_partnerchip(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `resid` FROM `PartnerChip` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PartnerChip_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `PartnerChip` SET  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", count, uid, resid);
return db_service.async_execute(buf);
}
int db_PartnerChip_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `PartnerChip` SET  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", count, uid, resid);
return db_service.sync_execute(buf);
}
int db_PartnerChip_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `PartnerChip` WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return db_service.async_execute(buf);
}
string db_PartnerChip_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `PartnerChip` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return string(buf);
}
int db_PartnerChip_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PartnerChip` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return db_service.async_execute(buf);
}
int db_PartnerChip_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PartnerChip` ( `uid`  ,  `count`  ,  `resid` ) VALUES ( %d , %d , %d )" , uid, count, resid);
return db_service.sync_execute(buf);
}
int db_TreasureCoopertive_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;profit=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
n_help=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
slot_pos=(int)std::atoi(row_[i++].c_str());
last_stamp=(int)std::atoi(row_[i++].c_str());
last_round=(int)std::atoi(row_[i++].c_str());
debian_secs=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_TreasureCoopertive_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `profit` , `uid` , `n_help` , `hostnum` , `slot_pos` , `last_stamp` , `last_round` , `debian_secs` FROM `TreasureCoopertive` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureCoopertive_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `profit` , `uid` , `n_help` , `hostnum` , `slot_pos` , `last_stamp` , `last_round` , `debian_secs` FROM `TreasureCoopertive` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureCoopertive_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureCoopertive` SET  `profit` = %d ,  `n_help` = %d ,  `hostnum` = %d ,  `slot_pos` = %d ,  `last_stamp` = %d ,  `last_round` = %d ,  `debian_secs` = %d WHERE  `uid` = %d", profit, n_help, hostnum, slot_pos, last_stamp, last_round, debian_secs, uid);
return db_service.async_execute(buf);
}
int db_TreasureCoopertive_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureCoopertive` SET  `profit` = %d ,  `n_help` = %d ,  `hostnum` = %d ,  `slot_pos` = %d ,  `last_stamp` = %d ,  `last_round` = %d ,  `debian_secs` = %d WHERE  `uid` = %d", profit, n_help, hostnum, slot_pos, last_stamp, last_round, debian_secs, uid);
return db_service.sync_execute(buf);
}
string db_TreasureCoopertive_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureCoopertive` ( `profit`  ,  `uid`  ,  `n_help`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `debian_secs` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, n_help, hostnum, slot_pos, last_stamp, last_round, debian_secs);
return string(buf);
}
int db_TreasureCoopertive_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureCoopertive` ( `profit`  ,  `uid`  ,  `n_help`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `debian_secs` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, n_help, hostnum, slot_pos, last_stamp, last_round, debian_secs);
return db_service.async_execute(buf);
}
int db_TreasureCoopertive_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureCoopertive` ( `profit`  ,  `uid`  ,  `n_help`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `debian_secs` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, n_help, hostnum, slot_pos, last_stamp, last_round, debian_secs);
return db_service.sync_execute(buf);
}
int db_ChipSmash_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;buystamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ChipSmash_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `ChipSmash` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipSmash_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `ChipSmash` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ChipSmash_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipSmash` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.async_execute(buf);
}
int db_ChipSmash_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ChipSmash` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.sync_execute(buf);
}
string db_ChipSmash_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipSmash` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return string(buf);
}
int db_ChipSmash_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipSmash` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.async_execute(buf);
}
int db_ChipSmash_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ChipSmash` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.sync_execute(buf);
}
int db_LimitRound_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
reset_times=(int)std::atoi(row_[i++].c_str());
lasttime=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_LimitRound_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `reset_times` , `lasttime` FROM `LimitRound` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LimitRound_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `reset_times` , `lasttime` FROM `LimitRound` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LimitRound_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `LimitRound` SET  `reset_times` = %d ,  `lasttime` = %d WHERE  `uid` = %d", reset_times, lasttime, uid);
return db_service.async_execute(buf);
}
int db_LimitRound_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `LimitRound` SET  `reset_times` = %d ,  `lasttime` = %d WHERE  `uid` = %d", reset_times, lasttime, uid);
return db_service.sync_execute(buf);
}
string db_LimitRound_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `LimitRound` ( `uid`  ,  `reset_times`  ,  `lasttime` ) VALUES ( %d , %d , %d )" , uid, reset_times, lasttime);
return string(buf);
}
int db_LimitRound_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LimitRound` ( `uid`  ,  `reset_times`  ,  `lasttime` ) VALUES ( %d , %d , %d )" , uid, reset_times, lasttime);
return db_service.async_execute(buf);
}
int db_LimitRound_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LimitRound` ( `uid`  ,  `reset_times`  ,  `lasttime` ) VALUES ( %d , %d , %d )" , uid, reset_times, lasttime);
return db_service.sync_execute(buf);
}
int db_PrestigeShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;buystamp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_PrestigeShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `PrestigeShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PrestigeShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `buystamp` , `uid` , `count` , `resid` FROM `PrestigeShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_PrestigeShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `PrestigeShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.async_execute(buf);
}
int db_PrestigeShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `PrestigeShop` SET  `buystamp` = %u ,  `count` = %d WHERE  `uid` = %d AND  `resid` = %d", buystamp, count, uid, resid);
return db_service.sync_execute(buf);
}
string db_PrestigeShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return string(buf);
}
int db_PrestigeShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.async_execute(buf);
}
int db_PrestigeShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `PrestigeShop` ( `buystamp`  ,  `uid`  ,  `count`  ,  `resid` ) VALUES ( %u , %d , %d , %d )" , buystamp, uid, count, resid);
return db_service.sync_execute(buf);
}
int db_InventoryShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;shopid=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
buystamp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_InventoryShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `shopid` , `uid` , `count` , `buystamp` FROM `InventoryShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_InventoryShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `shopid` , `uid` , `count` , `buystamp` FROM `InventoryShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_InventoryShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `InventoryShop` SET  `count` = %d ,  `buystamp` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, buystamp, uid, shopid);
return db_service.async_execute(buf);
}
int db_InventoryShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `InventoryShop` SET  `count` = %d ,  `buystamp` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, buystamp, uid, shopid);
return db_service.sync_execute(buf);
}
string db_InventoryShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `InventoryShop` ( `shopid`  ,  `uid`  ,  `count`  ,  `buystamp` ) VALUES ( %d , %d , %d , %u )" , shopid, uid, count, buystamp);
return string(buf);
}
int db_InventoryShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `InventoryShop` ( `shopid`  ,  `uid`  ,  `count`  ,  `buystamp` ) VALUES ( %d , %d , %d , %u )" , shopid, uid, count, buystamp);
return db_service.async_execute(buf);
}
int db_InventoryShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `InventoryShop` ( `shopid`  ,  `uid`  ,  `count`  ,  `buystamp` ) VALUES ( %d , %d , %d , %u )" , shopid, uid, count, buystamp);
return db_service.sync_execute(buf);
}
int db_GemPage_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
slotid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
pageid=(int)std::atoi(row_[i++].c_str());
gemtype=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GemPage_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `slotid` , `resid` , `pageid` , `gemtype` FROM `GemPage` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GemPage_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `slotid` , `resid` , `pageid` , `gemtype` FROM `GemPage` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GemPage_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GemPage` SET  `resid` = %d WHERE  `uid` = %d AND  `pageid` = %d AND  `gemtype` = %d AND  `slotid` = %d", resid, uid, pageid, gemtype, slotid);
return db_service.async_execute(buf);
}
int db_GemPage_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GemPage` SET  `resid` = %d WHERE  `uid` = %d AND  `pageid` = %d AND  `gemtype` = %d AND  `slotid` = %d", resid, uid, pageid, gemtype, slotid);
return db_service.sync_execute(buf);
}
string db_GemPage_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GemPage` ( `uid`  ,  `slotid`  ,  `resid`  ,  `pageid`  ,  `gemtype` ) VALUES ( %d , %d , %d , %d , %d )" , uid, slotid, resid, pageid, gemtype);
return string(buf);
}
int db_GemPage_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GemPage` ( `uid`  ,  `slotid`  ,  `resid`  ,  `pageid`  ,  `gemtype` ) VALUES ( %d , %d , %d , %d , %d )" , uid, slotid, resid, pageid, gemtype);
return db_service.async_execute(buf);
}
int db_GemPage_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GemPage` ( `uid`  ,  `slotid`  ,  `resid`  ,  `pageid`  ,  `gemtype` ) VALUES ( %d , %d , %d , %d , %d )" , uid, slotid, resid, pageid, gemtype);
return db_service.sync_execute(buf);
}
int db_Chronicle_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
chronicle_month=(int)std::atoi(row_[i++].c_str());
chronicle_day=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Chronicle_t::select_chronicle(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::select_chronicle_month(const int32_t& uid_, const int32_t& chronicle_month_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `chronicle_month` = %d", uid_, chronicle_month_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::select_chronicle_day(const int32_t& uid_, const int32_t& chronicle_day_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `chronicle_day` = %d", uid_, chronicle_day_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::select_chronicle_undone(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::sync_select_chronicle(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::sync_select_chronicle_month(const int32_t& uid_, const int32_t& chronicle_month_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `chronicle_month` = %d", uid_, chronicle_month_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::sync_select_chronicle_day(const int32_t& uid_, const int32_t& chronicle_day_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `chronicle_day` = %d", uid_, chronicle_day_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::sync_select_chronicle_undone(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `chronicle_month` , `chronicle_day` FROM `Chronicle` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chronicle_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Chronicle` SET  `state` = %d ,  `step` = %d ,  `chronicle_month` = %d WHERE  `uid` = %d AND  `chronicle_day` = %d", state, step, chronicle_month, uid, chronicle_day);
return db_service.async_execute(buf);
}
int db_Chronicle_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Chronicle` SET  `state` = %d ,  `step` = %d ,  `chronicle_month` = %d WHERE  `uid` = %d AND  `chronicle_day` = %d", state, step, chronicle_month, uid, chronicle_day);
return db_service.sync_execute(buf);
}
int db_Chronicle_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Chronicle` WHERE  `uid` = %d AND  `chronicle_day` = %d", uid, chronicle_day);
return db_service.async_execute(buf);
}
string db_Chronicle_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chronicle` ( `state`  ,  `uid`  ,  `step`  ,  `chronicle_month`  ,  `chronicle_day` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, step, chronicle_month, chronicle_day);
return string(buf);
}
int db_Chronicle_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chronicle` ( `state`  ,  `uid`  ,  `step`  ,  `chronicle_month`  ,  `chronicle_day` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, step, chronicle_month, chronicle_day);
return db_service.async_execute(buf);
}
int db_Chronicle_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chronicle` ( `state`  ,  `uid`  ,  `step`  ,  `chronicle_month`  ,  `chronicle_day` ) VALUES ( %d , %d , %d , %d , %d )" , state, uid, step, chronicle_month, chronicle_day);
return db_service.sync_execute(buf);
}
int db_GuildBattlePartner_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
hp=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_GuildBattlePartner_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `GuildBattlePartner` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GuildBattlePartner_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `GuildBattlePartner` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GuildBattlePartner_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GuildBattlePartner` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.async_execute(buf);
}
int db_GuildBattlePartner_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GuildBattlePartner` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.sync_execute(buf);
}
string db_GuildBattlePartner_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattlePartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return string(buf);
}
int db_GuildBattlePartner_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattlePartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.async_execute(buf);
}
int db_GuildBattlePartner_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattlePartner` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.sync_execute(buf);
}
int db_GuildBattleDefenceInfo_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;view_data = row_[i++];
building_pos=(int)std::atoi(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
hp2=(float)std::atof(row_[i++].c_str());
ggid=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
building_id=(int)std::atoi(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
hp5=(float)std::atof(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
hp3=(float)std::atof(row_[i++].c_str());
hp4=(float)std::atof(row_[i++].c_str());
hp1=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_GuildBattleDefenceInfo_t::select_info(const int32_t& ggid_, const int32_t& building_id_, const int32_t& building_pos_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `view_data` , `building_pos` , `pid5` , `hp2` , `ggid` , `pid2` , `building_id` , `pid3` , `uid` , `pid4` , `hp5` , `pid1` , `hp3` , `hp4` , `hp1` FROM `GuildBattleDefenceInfo` WHERE  `ggid` = %d AND  `building_id` = %d AND  `building_pos` = %d", ggid_, building_id_, building_pos_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GuildBattleDefenceInfo_t::sync_select_info(const int32_t& ggid_, const int32_t& building_id_, const int32_t& building_pos_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `view_data` , `building_pos` , `pid5` , `hp2` , `ggid` , `pid2` , `building_id` , `pid3` , `uid` , `pid4` , `hp5` , `pid1` , `hp3` , `hp4` , `hp1` FROM `GuildBattleDefenceInfo` WHERE  `ggid` = %d AND  `building_id` = %d AND  `building_pos` = %d", ggid_, building_id_, building_pos_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GuildBattleDefenceInfo_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GuildBattleDefenceInfo` SET  `view_data` = '%s' ,  `pid5` = %d ,  `hp2` = %f ,  `pid2` = %d ,  `pid3` = %d ,  `uid` = %d ,  `pid4` = %d ,  `hp5` = %f ,  `pid1` = %d ,  `hp3` = %f ,  `hp4` = %f ,  `hp1` = %f WHERE  `ggid` = %d AND  `building_id` = %d AND  `building_pos` = %d", view_data.c_str(), pid5, hp2, pid2, pid3, uid, pid4, hp5, pid1, hp3, hp4, hp1, ggid, building_id, building_pos);
return db_service.async_execute(buf);
}
int db_GuildBattleDefenceInfo_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GuildBattleDefenceInfo` SET  `view_data` = '%s' ,  `pid5` = %d ,  `hp2` = %f ,  `pid2` = %d ,  `pid3` = %d ,  `uid` = %d ,  `pid4` = %d ,  `hp5` = %f ,  `pid1` = %d ,  `hp3` = %f ,  `hp4` = %f ,  `hp1` = %f WHERE  `ggid` = %d AND  `building_id` = %d AND  `building_pos` = %d", view_data.c_str(), pid5, hp2, pid2, pid3, uid, pid4, hp5, pid1, hp3, hp4, hp1, ggid, building_id, building_pos);
return db_service.sync_execute(buf);
}
string db_GuildBattleDefenceInfo_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattleDefenceInfo` ( `view_data`  ,  `building_pos`  ,  `pid5`  ,  `hp2`  ,  `ggid`  ,  `pid2`  ,  `building_id`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hp5`  ,  `pid1`  ,  `hp3`  ,  `hp4`  ,  `hp1` ) VALUES ( '%s' , %d , %d , %f , %d , %d , %d , %d , %d , %d , %f , %d , %f , %f , %f )" , view_data.c_str(), building_pos, pid5, hp2, ggid, pid2, building_id, pid3, uid, pid4, hp5, pid1, hp3, hp4, hp1);
return string(buf);
}
int db_GuildBattleDefenceInfo_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattleDefenceInfo` ( `view_data`  ,  `building_pos`  ,  `pid5`  ,  `hp2`  ,  `ggid`  ,  `pid2`  ,  `building_id`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hp5`  ,  `pid1`  ,  `hp3`  ,  `hp4`  ,  `hp1` ) VALUES ( '%s' , %d , %d , %f , %d , %d , %d , %d , %d , %d , %f , %d , %f , %f , %f )" , view_data.c_str(), building_pos, pid5, hp2, ggid, pid2, building_id, pid3, uid, pid4, hp5, pid1, hp3, hp4, hp1);
return db_service.async_execute(buf);
}
int db_GuildBattleDefenceInfo_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GuildBattleDefenceInfo` ( `view_data`  ,  `building_pos`  ,  `pid5`  ,  `hp2`  ,  `ggid`  ,  `pid2`  ,  `building_id`  ,  `pid3`  ,  `uid`  ,  `pid4`  ,  `hp5`  ,  `pid1`  ,  `hp3`  ,  `hp4`  ,  `hp1` ) VALUES ( '%s' , %d , %d , %f , %d , %d , %d , %d , %d , %d , %f , %d , %f , %f , %f )" , view_data.c_str(), building_pos, pid5, hp2, ggid, pid2, building_id, pid3, uid, pid4, hp5, pid1, hp3, hp4, hp1);
return db_service.sync_execute(buf);
}
int db_SoulUser_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
ctime = row_[i++];
soullevel=(int)std::atoi(row_[i++].c_str());
soulid=(int)std::atoi(row_[i++].c_str());
soulmoney=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_SoulUser_t::select_id(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hostnum` , `ctime` , `soullevel` , `soulid` , `soulmoney` FROM `SoulUser` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_SoulUser_t::sync_select_id(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hostnum` , `ctime` , `soullevel` , `soulid` , `soulmoney` FROM `SoulUser` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_SoulUser_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `SoulUser` SET  `hostnum` = %d ,  `ctime` = '%s' ,  `soullevel` = %d ,  `soulid` = %d ,  `soulmoney` = %d WHERE  `uid` = %d", hostnum, ctime.c_str(), soullevel, soulid, soulmoney, uid);
return db_service.async_execute(buf);
}
int db_SoulUser_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `SoulUser` SET  `hostnum` = %d ,  `ctime` = '%s' ,  `soullevel` = %d ,  `soulid` = %d ,  `soulmoney` = %d WHERE  `uid` = %d", hostnum, ctime.c_str(), soullevel, soulid, soulmoney, uid);
return db_service.sync_execute(buf);
}
string db_SoulUser_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `SoulUser` ( `uid`  ,  `hostnum`  ,  `ctime`  ,  `soullevel`  ,  `soulid`  ,  `soulmoney` ) VALUES ( %d , %d , '%s' , %d , %d , %d )" , uid, hostnum, ctime.c_str(), soullevel, soulid, soulmoney);
return string(buf);
}
int db_SoulUser_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `SoulUser` ( `uid`  ,  `hostnum`  ,  `ctime`  ,  `soullevel`  ,  `soulid`  ,  `soulmoney` ) VALUES ( %d , %d , '%s' , %d , %d , %d )" , uid, hostnum, ctime.c_str(), soullevel, soulid, soulmoney);
return db_service.async_execute(buf);
}
int db_SoulUser_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `SoulUser` ( `uid`  ,  `hostnum`  ,  `ctime`  ,  `soullevel`  ,  `soulid`  ,  `soulmoney` ) VALUES ( %d , %d , '%s' , %d , %d , %d )" , uid, hostnum, ctime.c_str(), soullevel, soulid, soulmoney);
return db_service.sync_execute(buf);
}
int db_CardCommentPraise_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;praiseuid=(int)std::atoi(row_[i++].c_str());
commentid=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_CardCommentPraise_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardCommentPraise` ( `praiseuid`  ,  `commentid`  ,  `stamp` ) VALUES ( %d , %d , %d )" , praiseuid, commentid, stamp);
return string(buf);
}
int db_CardCommentPraise_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardCommentPraise` ( `praiseuid`  ,  `commentid`  ,  `stamp` ) VALUES ( %d , %d , %d )" , praiseuid, commentid, stamp);
return dbgl_service.async_execute(buf);
}
int db_CardCommentPraise_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardCommentPraise` ( `praiseuid`  ,  `commentid`  ,  `stamp` ) VALUES ( %d , %d , %d )" , praiseuid, commentid, stamp);
return dbgl_service.sync_execute(buf);
}
int db_CardComment_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;praisenum=(int)std::atoi(row_[i++].c_str());
equiprank=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
stamp=(int)std::atoi(row_[i++].c_str());
viplevel=(int)std::atoi(row_[i++].c_str());
comment = row_[i++];
isshow=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_CardComment_t::select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `praisenum` , `equiprank` , `resid` , `id` , `grade` , `uid` , `name` , `stamp` , `viplevel` , `comment` , `isshow` FROM `CardComment` WHERE  `id` = %d", id_);
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardComment_t::sync_select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `praisenum` , `equiprank` , `resid` , `id` , `grade` , `uid` , `name` , `stamp` , `viplevel` , `comment` , `isshow` FROM `CardComment` WHERE  `id` = %d", id_);
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardComment_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardComment` SET  `praisenum` = %d ,  `equiprank` = %d ,  `resid` = %d ,  `id` = %d ,  `grade` = %d ,  `uid` = %d ,  `name` = '%s' ,  `stamp` = %d ,  `viplevel` = %d ,  `comment` = '%s' ,  `isshow` = %d WHERE  `id` = %d", praisenum, equiprank, resid, id, grade, uid, name.c_str(), stamp, viplevel, comment.c_str(), isshow, id);
return dbgl_service.async_execute(buf);
}
int db_CardComment_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardComment` SET  `praisenum` = %d ,  `equiprank` = %d ,  `resid` = %d ,  `id` = %d ,  `grade` = %d ,  `uid` = %d ,  `name` = '%s' ,  `stamp` = %d ,  `viplevel` = %d ,  `comment` = '%s' ,  `isshow` = %d WHERE  `id` = %d", praisenum, equiprank, resid, id, grade, uid, name.c_str(), stamp, viplevel, comment.c_str(), isshow, id);
return dbgl_service.sync_execute(buf);
}
string db_CardComment_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardComment` ( `praisenum`  ,  `equiprank`  ,  `resid`  ,  `grade`  ,  `uid`  ,  `name`  ,  `stamp`  ,  `viplevel`  ,  `comment`  ,  `isshow` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d )" , praisenum, equiprank, resid, grade, uid, name.c_str(), stamp, viplevel, comment.c_str(), isshow);
return string(buf);
}
int db_CardComment_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardComment` ( `praisenum`  ,  `equiprank`  ,  `resid`  ,  `grade`  ,  `uid`  ,  `name`  ,  `stamp`  ,  `viplevel`  ,  `comment`  ,  `isshow` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d )" , praisenum, equiprank, resid, grade, uid, name.c_str(), stamp, viplevel, comment.c_str(), isshow);
return dbgl_service.async_execute(buf);
}
int db_CardComment_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardComment` ( `praisenum`  ,  `equiprank`  ,  `resid`  ,  `grade`  ,  `uid`  ,  `name`  ,  `stamp`  ,  `viplevel`  ,  `comment`  ,  `isshow` ) VALUES ( %d , %d , %d , %d , %d , '%s' , %d , %d , '%s' , %d )" , praisenum, equiprank, resid, grade, uid, name.c_str(), stamp, viplevel, comment.c_str(), isshow);
return dbgl_service.sync_execute(buf);
}
int db_RankMatch_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
req_times=(int)std::atoi(row_[i++].c_str());
view_data = row_[i++];
rank_type=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RankMatch_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `hostnum` , `req_times` , `view_data` , `rank_type` FROM `RankMatch` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RankMatch_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `hostnum` , `req_times` , `view_data` , `rank_type` FROM `RankMatch` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RankMatch_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RankMatch` SET  `stamp` = %d ,  `hostnum` = %d ,  `req_times` = %d ,  `view_data` = '%s' ,  `rank_type` = %d WHERE  `uid` = %d", stamp, hostnum, req_times, view_data.c_str(), rank_type, uid);
return db_service.async_execute(buf);
}
int db_RankMatch_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RankMatch` SET  `stamp` = %d ,  `hostnum` = %d ,  `req_times` = %d ,  `view_data` = '%s' ,  `rank_type` = %d WHERE  `uid` = %d", stamp, hostnum, req_times, view_data.c_str(), rank_type, uid);
return db_service.sync_execute(buf);
}
string db_RankMatch_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankMatch` ( `uid`  ,  `stamp`  ,  `hostnum`  ,  `req_times`  ,  `view_data`  ,  `rank_type` ) VALUES ( %d , %d , %d , %d , '%s' , %d )" , uid, stamp, hostnum, req_times, view_data.c_str(), rank_type);
return string(buf);
}
int db_RankMatch_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankMatch` ( `uid`  ,  `stamp`  ,  `hostnum`  ,  `req_times`  ,  `view_data`  ,  `rank_type` ) VALUES ( %d , %d , %d , %d , '%s' , %d )" , uid, stamp, hostnum, req_times, view_data.c_str(), rank_type);
return db_service.async_execute(buf);
}
int db_RankMatch_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RankMatch` ( `uid`  ,  `stamp`  ,  `hostnum`  ,  `req_times`  ,  `view_data`  ,  `rank_type` ) VALUES ( %d , %d , %d , %d , '%s' , %d )" , uid, stamp, hostnum, req_times, view_data.c_str(), rank_type);
return db_service.sync_execute(buf);
}
int db_Chat_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;resid=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
msg = row_[i++];
grade=(int)std::atoi(row_[i++].c_str());
suid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
hostnum=(int)std::atoi(row_[i++].c_str());
typeindex=(int)std::atoi(row_[i++].c_str());
vip=(int)std::atoi(row_[i++].c_str());
quality=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Chat_t::select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `resid` , `id` , `msg` , `grade` , `suid` , `name` , `hostnum` , `typeindex` , `vip` , `quality` FROM `Chat` WHERE  `id` = %d", id_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Chat_t::sync_select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `resid` , `id` , `msg` , `grade` , `suid` , `name` , `hostnum` , `typeindex` , `vip` , `quality` FROM `Chat` WHERE  `id` = %d", id_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
string db_Chat_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chat` ( `resid`  ,  `id`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , resid, id, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return string(buf);
}
int db_Chat_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chat` ( `resid`  ,  `id`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , resid, id, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return db_service.async_execute(buf);
}
int db_Chat_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Chat` ( `resid`  ,  `id`  ,  `msg`  ,  `grade`  ,  `suid`  ,  `name`  ,  `hostnum`  ,  `typeindex`  ,  `vip`  ,  `quality` ) VALUES ( %d , %d , '%s' , %d , %d , '%s' , %d , %d , %d , %d )" , resid, id, msg.c_str(), grade, suid, name.c_str(), hostnum, typeindex, vip, quality);
return db_service.sync_execute(buf);
}
int db_CardEventUser_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;score=(int)std::atoi(row_[i++].c_str());
goal_level=(int)std::atoi(row_[i++].c_str());
round_status=(int)std::atoi(row_[i++].c_str());
next_count=(int)std::atoi(row_[i++].c_str());
open_level=(int)std::atoi(row_[i++].c_str());
open_times=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
season=(int)std::atoi(row_[i++].c_str());
round=(int)std::atoi(row_[i++].c_str());
hp5=(float)std::atof(row_[i++].c_str());
hp4=(float)std::atof(row_[i++].c_str());
anger=(int)std::atoi(row_[i++].c_str());
hp3=(float)std::atof(row_[i++].c_str());
coin=(int)std::atoi(row_[i++].c_str());
first_enter_time=(int)std::atoi(row_[i++].c_str());
hp2=(float)std::atof(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
enemy_view_data = row_[i++];
pid5=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
round_max=(int)std::atoi(row_[i++].c_str());
difficult=(int)std::atoi(row_[i++].c_str());
reset_time=(int)std::atoi(row_[i++].c_str());
hp1=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_CardEventUser_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `score` , `goal_level` , `round_status` , `next_count` , `open_level` , `open_times` , `hostnum` , `season` , `round` , `hp5` , `hp4` , `anger` , `hp3` , `coin` , `first_enter_time` , `hp2` , `pid3` , `enemy_view_data` , `pid5` , `pid1` , `uid` , `pid4` , `pid2` , `round_max` , `difficult` , `reset_time` , `hp1` FROM `CardEventUser` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventUser_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `score` , `goal_level` , `round_status` , `next_count` , `open_level` , `open_times` , `hostnum` , `season` , `round` , `hp5` , `hp4` , `anger` , `hp3` , `coin` , `first_enter_time` , `hp2` , `pid3` , `enemy_view_data` , `pid5` , `pid1` , `uid` , `pid4` , `pid2` , `round_max` , `difficult` , `reset_time` , `hp1` FROM `CardEventUser` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventUser_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventUser` SET  `score` = %d ,  `goal_level` = %d ,  `round_status` = %d ,  `next_count` = %d ,  `open_level` = %d ,  `open_times` = %d ,  `hostnum` = %d ,  `season` = %d ,  `round` = %d ,  `hp5` = %f ,  `hp4` = %f ,  `anger` = %d ,  `hp3` = %f ,  `coin` = %d ,  `first_enter_time` = %d ,  `hp2` = %f ,  `pid3` = %d ,  `enemy_view_data` = '%s' ,  `pid5` = %d ,  `pid1` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `round_max` = %d ,  `difficult` = %d ,  `reset_time` = %d ,  `hp1` = %f WHERE  `uid` = %d", score, goal_level, round_status, next_count, open_level, open_times, hostnum, season, round, hp5, hp4, anger, hp3, coin, first_enter_time, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, pid4, pid2, round_max, difficult, reset_time, hp1, uid);
return db_service.async_execute(buf);
}
int db_CardEventUser_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventUser` SET  `score` = %d ,  `goal_level` = %d ,  `round_status` = %d ,  `next_count` = %d ,  `open_level` = %d ,  `open_times` = %d ,  `hostnum` = %d ,  `season` = %d ,  `round` = %d ,  `hp5` = %f ,  `hp4` = %f ,  `anger` = %d ,  `hp3` = %f ,  `coin` = %d ,  `first_enter_time` = %d ,  `hp2` = %f ,  `pid3` = %d ,  `enemy_view_data` = '%s' ,  `pid5` = %d ,  `pid1` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `round_max` = %d ,  `difficult` = %d ,  `reset_time` = %d ,  `hp1` = %f WHERE  `uid` = %d", score, goal_level, round_status, next_count, open_level, open_times, hostnum, season, round, hp5, hp4, anger, hp3, coin, first_enter_time, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, pid4, pid2, round_max, difficult, reset_time, hp1, uid);
return db_service.sync_execute(buf);
}
string db_CardEventUser_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUser` ( `score`  ,  `goal_level`  ,  `round_status`  ,  `next_count`  ,  `open_level`  ,  `open_times`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `first_enter_time`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, round_status, next_count, open_level, open_times, hostnum, season, round, hp5, hp4, anger, hp3, coin, first_enter_time, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return string(buf);
}
int db_CardEventUser_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUser` ( `score`  ,  `goal_level`  ,  `round_status`  ,  `next_count`  ,  `open_level`  ,  `open_times`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `first_enter_time`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, round_status, next_count, open_level, open_times, hostnum, season, round, hp5, hp4, anger, hp3, coin, first_enter_time, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return db_service.async_execute(buf);
}
int db_CardEventUser_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventUser` ( `score`  ,  `goal_level`  ,  `round_status`  ,  `next_count`  ,  `open_level`  ,  `open_times`  ,  `hostnum`  ,  `season`  ,  `round`  ,  `hp5`  ,  `hp4`  ,  `anger`  ,  `hp3`  ,  `coin`  ,  `first_enter_time`  ,  `hp2`  ,  `pid3`  ,  `enemy_view_data`  ,  `pid5`  ,  `pid1`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `round_max`  ,  `difficult`  ,  `reset_time`  ,  `hp1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %f , %f , %d , %f , %d , %d , %f , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %f )" , score, goal_level, round_status, next_count, open_level, open_times, hostnum, season, round, hp5, hp4, anger, hp3, coin, first_enter_time, hp2, pid3, enemy_view_data.c_str(), pid5, pid1, uid, pid4, pid2, round_max, difficult, reset_time, hp1);
return db_service.sync_execute(buf);
}
int db_CardEventTeam_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;anger=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_CardEventTeam_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `anger` , `uid` , `pid4` , `pid2` , `pid1` , `pid3` , `pid5` FROM `CardEventTeam` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventTeam_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `anger` , `uid` , `pid4` , `pid2` , `pid1` , `pid3` , `pid5` FROM `CardEventTeam` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventTeam_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventTeam` SET  `anger` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid3` = %d ,  `pid5` = %d WHERE  `uid` = %d", anger, pid4, pid2, pid1, pid3, pid5, uid);
return db_service.async_execute(buf);
}
int db_CardEventTeam_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventTeam` SET  `anger` = %d ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid3` = %d ,  `pid5` = %d WHERE  `uid` = %d", anger, pid4, pid2, pid1, pid3, pid5, uid);
return db_service.sync_execute(buf);
}
string db_CardEventTeam_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return string(buf);
}
int db_CardEventTeam_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return db_service.async_execute(buf);
}
int db_CardEventTeam_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventTeam` ( `anger`  ,  `uid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `pid3`  ,  `pid5` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , anger, uid, pid4, pid2, pid1, pid3, pid5);
return db_service.sync_execute(buf);
}
int db_Rank_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
id=(int)std::atoi(row_[i++].c_str());
rankindex=(int)std::atoi(row_[i++].c_str());
ranknum=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Rank_t::select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hostnum` , `id` , `rankindex` , `ranknum` FROM `Rank` WHERE  `id` = %d", id_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Rank_t::sync_select_id(const int32_t& id_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `hostnum` , `id` , `rankindex` , `ranknum` FROM `Rank` WHERE  `id` = %d", id_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Rank_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Rank` SET  `uid` = %d ,  `hostnum` = %d ,  `id` = %d ,  `rankindex` = %d ,  `ranknum` = %d WHERE  `id` = %d", uid, hostnum, id, rankindex, ranknum, id);
return db_service.async_execute(buf);
}
int db_Rank_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Rank` SET  `uid` = %d ,  `hostnum` = %d ,  `id` = %d ,  `rankindex` = %d ,  `ranknum` = %d WHERE  `id` = %d", uid, hostnum, id, rankindex, ranknum, id);
return db_service.sync_execute(buf);
}
string db_Rank_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rank` ( `uid`  ,  `hostnum`  ,  `rankindex`  ,  `ranknum` ) VALUES ( %d , %d , %d , %d )" , uid, hostnum, rankindex, ranknum);
return string(buf);
}
int db_Rank_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rank` ( `uid`  ,  `hostnum`  ,  `rankindex`  ,  `ranknum` ) VALUES ( %d , %d , %d , %d )" , uid, hostnum, rankindex, ranknum);
return db_service.async_execute(buf);
}
int db_Rank_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rank` ( `uid`  ,  `hostnum`  ,  `rankindex`  ,  `ranknum` ) VALUES ( %d , %d , %d , %d )" , uid, hostnum, rankindex, ranknum);
return db_service.sync_execute(buf);
}
int db_RoundStarReward_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;rpid=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
r4=(int)std::atoi(row_[i++].c_str());
r1=(int)std::atoi(row_[i++].c_str());
r2=(int)std::atoi(row_[i++].c_str());
r3=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RoundStarReward_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rpid` , `uid` , `r4` , `r1` , `r2` , `r3` FROM `RoundStarReward` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RoundStarReward_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rpid` , `uid` , `r4` , `r1` , `r2` , `r3` FROM `RoundStarReward` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RoundStarReward_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RoundStarReward` SET  `r4` = %d ,  `r1` = %d ,  `r2` = %d ,  `r3` = %d WHERE  `uid` = %d AND  `rpid` = %d", r4, r1, r2, r3, uid, rpid);
return db_service.async_execute(buf);
}
int db_RoundStarReward_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RoundStarReward` SET  `r4` = %d ,  `r1` = %d ,  `r2` = %d ,  `r3` = %d WHERE  `uid` = %d AND  `rpid` = %d", r4, r1, r2, r3, uid, rpid);
return db_service.sync_execute(buf);
}
string db_RoundStarReward_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RoundStarReward` ( `rpid`  ,  `uid`  ,  `r4`  ,  `r1`  ,  `r2`  ,  `r3` ) VALUES ( %d , %d , %d , %d , %d , %d )" , rpid, uid, r4, r1, r2, r3);
return string(buf);
}
int db_RoundStarReward_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RoundStarReward` ( `rpid`  ,  `uid`  ,  `r4`  ,  `r1`  ,  `r2`  ,  `r3` ) VALUES ( %d , %d , %d , %d , %d , %d )" , rpid, uid, r4, r1, r2, r3);
return db_service.async_execute(buf);
}
int db_RoundStarReward_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RoundStarReward` ( `rpid`  ,  `uid`  ,  `r4`  ,  `r1`  ,  `r2`  ,  `r3` ) VALUES ( %d , %d , %d , %d , %d , %d )" , rpid, uid, r4, r1, r2, r3);
return db_service.sync_execute(buf);
}
int db_CardEventRank_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;rank=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_CardEventRank_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rank` , `uid` FROM `CardEventRank` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventRank_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rank` , `uid` FROM `CardEventRank` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventRank_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventRank` SET  `rank` = %d WHERE  `uid` = %d", rank, uid);
return db_service.async_execute(buf);
}
int db_CardEventRank_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventRank` SET  `rank` = %d WHERE  `uid` = %d", rank, uid);
return db_service.sync_execute(buf);
}
string db_CardEventRank_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRank` ( `rank`  ,  `uid` ) VALUES ( %d , %d )" , rank, uid);
return string(buf);
}
int db_CardEventRank_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRank` ( `rank`  ,  `uid` ) VALUES ( %d , %d )" , rank, uid);
return db_service.async_execute(buf);
}
int db_CardEventRank_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRank` ( `rank`  ,  `uid` ) VALUES ( %d , %d )" , rank, uid);
return db_service.sync_execute(buf);
}
int db_Activity_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
cumu_yb_rank_exp=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
con_wing_given=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
con_wing_stamp=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
cumu_yb_rank_stamp=(int)std::atoi(row_[i++].c_str());
con_wing_rank=(int)std::atoi(row_[i++].c_str());
con_wing_score=(int)std::atoi(row_[i++].c_str());
cumu_yb_rank=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Activity_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `cumu_yb_rank_exp` , `grade` , `con_wing_given` , `uid` , `con_wing_stamp` , `hostnum` , `cumu_yb_rank_stamp` , `con_wing_rank` , `con_wing_score` , `cumu_yb_rank` FROM `Activity` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Activity_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `cumu_yb_rank_exp` , `grade` , `con_wing_given` , `uid` , `con_wing_stamp` , `hostnum` , `cumu_yb_rank_stamp` , `con_wing_rank` , `con_wing_score` , `cumu_yb_rank` FROM `Activity` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Activity_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Activity` SET  `nickname` = '%s' ,  `cumu_yb_rank_exp` = %d ,  `grade` = %d ,  `con_wing_given` = %d ,  `con_wing_stamp` = %u ,  `hostnum` = %d ,  `cumu_yb_rank_stamp` = %u ,  `con_wing_rank` = %d ,  `con_wing_score` = %d ,  `cumu_yb_rank` = %d WHERE  `uid` = %d", nickname.c_str(), cumu_yb_rank_exp, grade, con_wing_given, con_wing_stamp, hostnum, cumu_yb_rank_stamp, con_wing_rank, con_wing_score, cumu_yb_rank, uid);
return db_service.async_execute(buf);
}
int db_Activity_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Activity` SET  `nickname` = '%s' ,  `cumu_yb_rank_exp` = %d ,  `grade` = %d ,  `con_wing_given` = %d ,  `con_wing_stamp` = %u ,  `hostnum` = %d ,  `cumu_yb_rank_stamp` = %u ,  `con_wing_rank` = %d ,  `con_wing_score` = %d ,  `cumu_yb_rank` = %d WHERE  `uid` = %d", nickname.c_str(), cumu_yb_rank_exp, grade, con_wing_given, con_wing_stamp, hostnum, cumu_yb_rank_stamp, con_wing_rank, con_wing_score, cumu_yb_rank, uid);
return db_service.sync_execute(buf);
}
string db_Activity_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Activity` ( `nickname`  ,  `cumu_yb_rank_exp`  ,  `grade`  ,  `con_wing_given`  ,  `uid`  ,  `con_wing_stamp`  ,  `hostnum`  ,  `cumu_yb_rank_stamp`  ,  `con_wing_rank`  ,  `con_wing_score`  ,  `cumu_yb_rank` ) VALUES ( '%s' , %d , %d , %d , %d , %u , %d , %u , %d , %d , %d )" , nickname.c_str(), cumu_yb_rank_exp, grade, con_wing_given, uid, con_wing_stamp, hostnum, cumu_yb_rank_stamp, con_wing_rank, con_wing_score, cumu_yb_rank);
return string(buf);
}
int db_Activity_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Activity` ( `nickname`  ,  `cumu_yb_rank_exp`  ,  `grade`  ,  `con_wing_given`  ,  `uid`  ,  `con_wing_stamp`  ,  `hostnum`  ,  `cumu_yb_rank_stamp`  ,  `con_wing_rank`  ,  `con_wing_score`  ,  `cumu_yb_rank` ) VALUES ( '%s' , %d , %d , %d , %d , %u , %d , %u , %d , %d , %d )" , nickname.c_str(), cumu_yb_rank_exp, grade, con_wing_given, uid, con_wing_stamp, hostnum, cumu_yb_rank_stamp, con_wing_rank, con_wing_score, cumu_yb_rank);
return db_service.async_execute(buf);
}
int db_Activity_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Activity` ( `nickname`  ,  `cumu_yb_rank_exp`  ,  `grade`  ,  `con_wing_given`  ,  `uid`  ,  `con_wing_stamp`  ,  `hostnum`  ,  `cumu_yb_rank_stamp`  ,  `con_wing_rank`  ,  `con_wing_score`  ,  `cumu_yb_rank` ) VALUES ( '%s' , %d , %d , %d , %d , %u , %d , %u , %d , %d , %d )" , nickname.c_str(), cumu_yb_rank_exp, grade, con_wing_given, uid, con_wing_stamp, hostnum, cumu_yb_rank_stamp, con_wing_rank, con_wing_score, cumu_yb_rank);
return db_service.sync_execute(buf);
}
int db_BuyLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
fpoint=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
price=(int)std::atoi(row_[i++].c_str());
buytm = row_[i++];
domain = row_[i++];
itemname = row_[i++];
payyb=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
buytype=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
freeyb=(int)std::atoi(row_[i++].c_str());
vip=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_BuyLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `BuyLog` ( `nickname`  ,  `fpoint`  ,  `resid`  ,  `price`  ,  `buytm`  ,  `domain`  ,  `itemname`  ,  `payyb`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `buytype`  ,  `aid`  ,  `freeyb`  ,  `vip` ) VALUES ( '%s' , %d , %d , %d , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), fpoint, resid, price, buytm.c_str(), domain.c_str(), itemname.c_str(), payyb, uid, count, hostnum, buytype, aid, freeyb, vip);
return string(buf);
}
int db_BuyLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `BuyLog` ( `nickname`  ,  `fpoint`  ,  `resid`  ,  `price`  ,  `buytm`  ,  `domain`  ,  `itemname`  ,  `payyb`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `buytype`  ,  `aid`  ,  `freeyb`  ,  `vip` ) VALUES ( '%s' , %d , %d , %d , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), fpoint, resid, price, buytm.c_str(), domain.c_str(), itemname.c_str(), payyb, uid, count, hostnum, buytype, aid, freeyb, vip);
return db_service.async_execute(buf);
}
int db_BuyLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `BuyLog` ( `nickname`  ,  `fpoint`  ,  `resid`  ,  `price`  ,  `buytm`  ,  `domain`  ,  `itemname`  ,  `payyb`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `buytype`  ,  `aid`  ,  `freeyb`  ,  `vip` ) VALUES ( '%s' , %d , %d , %d , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), fpoint, resid, price, buytm.c_str(), domain.c_str(), itemname.c_str(), payyb, uid, count, hostnum, buytype, aid, freeyb, vip);
return db_service.sync_execute(buf);
}
int db_CardEventRound_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;view_data = row_[i++];
eid=(int)std::atoi(row_[i++].c_str());
pid4=(int)std::atoi(row_[i++].c_str());
pid2=(int)std::atoi(row_[i++].c_str());
pid1=(int)std::atoi(row_[i++].c_str());
round=(int)std::atoi(row_[i++].c_str());
pid5=(int)std::atoi(row_[i++].c_str());
pid3=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_CardEventRound_t::select_all(const int32_t& eid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `view_data` , `eid` , `pid4` , `pid2` , `pid1` , `round` , `pid5` , `pid3` FROM `CardEventRound` WHERE  `eid` = %d", eid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventRound_t::sync_select_all(const int32_t& eid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `view_data` , `eid` , `pid4` , `pid2` , `pid1` , `round` , `pid5` , `pid3` FROM `CardEventRound` WHERE  `eid` = %d", eid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_CardEventRound_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventRound` SET  `view_data` = '%s' ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid5` = %d ,  `pid3` = %d WHERE  `eid` = %d AND  `round` = %d", view_data.c_str(), pid4, pid2, pid1, pid5, pid3, eid, round);
return db_service.async_execute(buf);
}
int db_CardEventRound_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `CardEventRound` SET  `view_data` = '%s' ,  `pid4` = %d ,  `pid2` = %d ,  `pid1` = %d ,  `pid5` = %d ,  `pid3` = %d WHERE  `eid` = %d AND  `round` = %d", view_data.c_str(), pid4, pid2, pid1, pid5, pid3, eid, round);
return db_service.sync_execute(buf);
}
string db_CardEventRound_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRound` ( `view_data`  ,  `eid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `round`  ,  `pid5`  ,  `pid3` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , view_data.c_str(), eid, pid4, pid2, pid1, round, pid5, pid3);
return string(buf);
}
int db_CardEventRound_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRound` ( `view_data`  ,  `eid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `round`  ,  `pid5`  ,  `pid3` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , view_data.c_str(), eid, pid4, pid2, pid1, round, pid5, pid3);
return db_service.async_execute(buf);
}
int db_CardEventRound_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `CardEventRound` ( `view_data`  ,  `eid`  ,  `pid4`  ,  `pid2`  ,  `pid1`  ,  `round`  ,  `pid5`  ,  `pid3` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d )" , view_data.c_str(), eid, pid4, pid2, pid1, round, pid5, pid3);
return db_service.sync_execute(buf);
}
int db_UserID_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
grade=(int)std::atoi(row_[i++].c_str());
state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
wingid=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
isoverdue=(int)std::atoi(row_[i++].c_str());
viplevel=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_UserID_t::select_user(const int32_t& aid_, const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d", aid_, hostnum_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_uid_state(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_all_uid_state(const int32_t& aid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `state` = %d", aid_, state_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_uid_condition(const int32_t& uid_, const char* condition_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d AND %s", uid_, condition_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_user_state(const int32_t& aid_, const int32_t& hostnum_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d AND  `state` = %d", aid_, hostnum_, state_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_user_condition(const int32_t& aid_, const int32_t& hostnum_, const char* condition_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d AND %s", aid_, hostnum_, condition_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_user(const int32_t& aid_, const int32_t& hostnum_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d", aid_, hostnum_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_uid_state(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_all_uid_state(const int32_t& aid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `state` = %d", aid_, state_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_uid_condition(const int32_t& uid_, const char* condition_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d AND %s", uid_, condition_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_user_state(const int32_t& aid_, const int32_t& hostnum_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d AND  `state` = %d", aid_, hostnum_, state_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_user_condition(const int32_t& aid_, const int32_t& hostnum_, const char* condition_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `aid` = %d AND  `hostnum` = %d AND %s", aid_, hostnum_, condition_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `nickname` , `resid` , `grade` , `state` , `uid` , `wingid` , `hostnum` , `aid` , `isoverdue` , `viplevel` FROM `UserID` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_UserID_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `UserID` SET  `nickname` = '%s' ,  `grade` = %d ,  `state` = %d ,  `wingid` = %d ,  `hostnum` = %d ,  `isoverdue` = %d ,  `viplevel` = %d WHERE  `uid` = %d", nickname.c_str(), grade, state, wingid, hostnum, isoverdue, viplevel, uid);
return db_service.async_execute(buf);
}
int db_UserID_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `UserID` SET  `nickname` = '%s' ,  `grade` = %d ,  `state` = %d ,  `wingid` = %d ,  `hostnum` = %d ,  `isoverdue` = %d ,  `viplevel` = %d WHERE  `uid` = %d", nickname.c_str(), grade, state, wingid, hostnum, isoverdue, viplevel, uid);
return db_service.sync_execute(buf);
}
int db_UserID_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `UserID` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_UserID_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserID` ( `nickname`  ,  `resid`  ,  `grade`  ,  `state`  ,  `uid`  ,  `wingid`  ,  `hostnum`  ,  `aid`  ,  `isoverdue`  ,  `viplevel` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), resid, grade, state, uid, wingid, hostnum, aid, isoverdue, viplevel);
return string(buf);
}
int db_UserID_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserID` ( `nickname`  ,  `resid`  ,  `grade`  ,  `state`  ,  `uid`  ,  `wingid`  ,  `hostnum`  ,  `aid`  ,  `isoverdue`  ,  `viplevel` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), resid, grade, state, uid, wingid, hostnum, aid, isoverdue, viplevel);
return db_service.async_execute(buf);
}
int db_UserID_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `UserID` ( `nickname`  ,  `resid`  ,  `grade`  ,  `state`  ,  `uid`  ,  `wingid`  ,  `hostnum`  ,  `aid`  ,  `isoverdue`  ,  `viplevel` ) VALUES ( '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , nickname.c_str(), resid, grade, state, uid, wingid, hostnum, aid, isoverdue, viplevel);
return db_service.sync_execute(buf);
}
int db_Friend_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;fuid=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
hasSendFlower=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Friend_t::select_friend(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `fuid` , `uid` , `hasSendFlower` FROM `Friend` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Friend_t::sync_select_friend(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `fuid` , `uid` , `hasSendFlower` FROM `Friend` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Friend_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Friend` SET  `hasSendFlower` = %d WHERE  `uid` = %d AND  `fuid` = %d", hasSendFlower, uid, fuid);
return db_service.async_execute(buf);
}
int db_Friend_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Friend` SET  `hasSendFlower` = %d WHERE  `uid` = %d AND  `fuid` = %d", hasSendFlower, uid, fuid);
return db_service.sync_execute(buf);
}
int db_Friend_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Friend` WHERE  `uid` = %d AND  `fuid` = %d", uid, fuid);
return db_service.async_execute(buf);
}
string db_Friend_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Friend` ( `fuid`  ,  `uid`  ,  `hasSendFlower` ) VALUES ( %d , %d , %d )" , fuid, uid, hasSendFlower);
return string(buf);
}
int db_Friend_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Friend` ( `fuid`  ,  `uid`  ,  `hasSendFlower` ) VALUES ( %d , %d , %d )" , fuid, uid, hasSendFlower);
return db_service.async_execute(buf);
}
int db_Friend_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Friend` ( `fuid`  ,  `uid`  ,  `hasSendFlower` ) VALUES ( %d , %d , %d )" , fuid, uid, hasSendFlower);
return db_service.sync_execute(buf);
}
int db_ComboPro_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;exp5=(int)std::atoi(row_[i++].c_str());
exp1=(int)std::atoi(row_[i++].c_str());
o4=(int)std::atoi(row_[i++].c_str());
o1=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
o3=(int)std::atoi(row_[i++].c_str());
o2=(int)std::atoi(row_[i++].c_str());
exp4=(int)std::atoi(row_[i++].c_str());
exp2=(int)std::atoi(row_[i++].c_str());
o5=(int)std::atoi(row_[i++].c_str());
exp3=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ComboPro_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `exp5` , `exp1` , `o4` , `o1` , `uid` , `o3` , `o2` , `exp4` , `exp2` , `o5` , `exp3` FROM `ComboPro` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ComboPro_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `exp5` , `exp1` , `o4` , `o1` , `uid` , `o3` , `o2` , `exp4` , `exp2` , `o5` , `exp3` FROM `ComboPro` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ComboPro_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ComboPro` SET  `exp5` = %d ,  `exp1` = %d ,  `o4` = %d ,  `o1` = %d ,  `o3` = %d ,  `o2` = %d ,  `exp4` = %d ,  `exp2` = %d ,  `o5` = %d ,  `exp3` = %d WHERE  `uid` = %d", exp5, exp1, o4, o1, o3, o2, exp4, exp2, o5, exp3, uid);
return db_service.async_execute(buf);
}
int db_ComboPro_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ComboPro` SET  `exp5` = %d ,  `exp1` = %d ,  `o4` = %d ,  `o1` = %d ,  `o3` = %d ,  `o2` = %d ,  `exp4` = %d ,  `exp2` = %d ,  `o5` = %d ,  `exp3` = %d WHERE  `uid` = %d", exp5, exp1, o4, o1, o3, o2, exp4, exp2, o5, exp3, uid);
return db_service.sync_execute(buf);
}
int db_ComboPro_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `ComboPro` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_ComboPro_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ComboPro` ( `exp5`  ,  `exp1`  ,  `o4`  ,  `o1`  ,  `uid`  ,  `o3`  ,  `o2`  ,  `exp4`  ,  `exp2`  ,  `o5`  ,  `exp3` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , exp5, exp1, o4, o1, uid, o3, o2, exp4, exp2, o5, exp3);
return string(buf);
}
int db_ComboPro_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ComboPro` ( `exp5`  ,  `exp1`  ,  `o4`  ,  `o1`  ,  `uid`  ,  `o3`  ,  `o2`  ,  `exp4`  ,  `exp2`  ,  `o5`  ,  `exp3` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , exp5, exp1, o4, o1, uid, o3, o2, exp4, exp2, o5, exp3);
return db_service.async_execute(buf);
}
int db_ComboPro_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ComboPro` ( `exp5`  ,  `exp1`  ,  `o4`  ,  `o1`  ,  `uid`  ,  `o3`  ,  `o2`  ,  `exp4`  ,  `exp2`  ,  `o5`  ,  `exp3` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , exp5, exp1, o4, o1, uid, o3, o2, exp4, exp2, o5, exp3);
return db_service.sync_execute(buf);
}
int db_RunePage_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;id=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
slot=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RunePage_t::select_rune_page_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `pid` , `slot` FROM `RunePage` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RunePage_t::sync_select_rune_page_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `id` , `uid` , `pid` , `slot` FROM `RunePage` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RunePage_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RunePage` SET  `id` = %d WHERE  `uid` = %d AND  `pid` = %d AND  `slot` = %d", id, uid, pid, slot);
return db_service.async_execute(buf);
}
int db_RunePage_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RunePage` SET  `id` = %d WHERE  `uid` = %d AND  `pid` = %d AND  `slot` = %d", id, uid, pid, slot);
return db_service.sync_execute(buf);
}
int db_RunePage_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `RunePage` WHERE  `uid` = %d AND  `pid` = %d AND  `slot` = %d", uid, pid, slot);
return db_service.async_execute(buf);
}
string db_RunePage_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RunePage` ( `id`  ,  `uid`  ,  `pid`  ,  `slot` ) VALUES ( %d , %d , %d , %d )" , id, uid, pid, slot);
return string(buf);
}
int db_RunePage_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RunePage` ( `id`  ,  `uid`  ,  `pid`  ,  `slot` ) VALUES ( %d , %d , %d , %d )" , id, uid, pid, slot);
return db_service.async_execute(buf);
}
int db_RunePage_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RunePage` ( `id`  ,  `uid`  ,  `pid`  ,  `slot` ) VALUES ( %d , %d , %d , %d )" , id, uid, pid, slot);
return db_service.sync_execute(buf);
}
int db_Bullet_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
stamp=(int)std::atoi(row_[i++].c_str());
round=(int)std::atoi(row_[i++].c_str());
msg = row_[i++];
pos=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Bullet_t::select_round(const uint32_t& round_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `round` , `msg` , `pos` FROM `Bullet` WHERE  `round` = %u", round_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Bullet_t::sync_select_round(const uint32_t& round_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `stamp` , `round` , `msg` , `pos` FROM `Bullet` WHERE  `round` = %u", round_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Bullet_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Bullet` SET  `uid` = %d ,  `stamp` = %u ,  `round` = %u ,  `msg` = '%s' ,  `pos` = %d WHERE  `round` = %u", uid, stamp, round, msg.c_str(), pos, round);
return db_service.async_execute(buf);
}
int db_Bullet_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Bullet` SET  `uid` = %d ,  `stamp` = %u ,  `round` = %u ,  `msg` = '%s' ,  `pos` = %d WHERE  `round` = %u", uid, stamp, round, msg.c_str(), pos, round);
return db_service.sync_execute(buf);
}
string db_Bullet_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Bullet` ( `uid`  ,  `stamp`  ,  `round`  ,  `msg`  ,  `pos` ) VALUES ( %d , %u , %u , '%s' , %d )" , uid, stamp, round, msg.c_str(), pos);
return string(buf);
}
int db_Bullet_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Bullet` ( `uid`  ,  `stamp`  ,  `round`  ,  `msg`  ,  `pos` ) VALUES ( %d , %u , %u , '%s' , %d )" , uid, stamp, round, msg.c_str(), pos);
return db_service.async_execute(buf);
}
int db_Bullet_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Bullet` ( `uid`  ,  `stamp`  ,  `round`  ,  `msg`  ,  `pos` ) VALUES ( %d , %u , %u , '%s' , %d )" , uid, stamp, round, msg.c_str(), pos);
return db_service.sync_execute(buf);
}
int db_ExpeditionShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
eshopindex=(int)std::atoi(row_[i++].c_str());
eshopid=(int)std::atoi(row_[i++].c_str());
refresh_time=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ExpeditionShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `eshopindex` , `eshopid` , `refresh_time` FROM `ExpeditionShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `eshopindex` , `eshopid` , `refresh_time` FROM `ExpeditionShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionShop` SET  `count` = %d ,  `eshopid` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `eshopindex` = %d", count, eshopid, refresh_time, uid, eshopindex);
return db_service.async_execute(buf);
}
int db_ExpeditionShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionShop` SET  `count` = %d ,  `eshopid` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `eshopindex` = %d", count, eshopid, refresh_time, uid, eshopindex);
return db_service.sync_execute(buf);
}
string db_ExpeditionShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionShop` ( `uid`  ,  `count`  ,  `eshopindex`  ,  `eshopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, eshopindex, eshopid, refresh_time);
return string(buf);
}
int db_ExpeditionShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionShop` ( `uid`  ,  `count`  ,  `eshopindex`  ,  `eshopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, eshopindex, eshopid, refresh_time);
return db_service.async_execute(buf);
}
int db_ExpeditionShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionShop` ( `uid`  ,  `count`  ,  `eshopindex`  ,  `eshopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, eshopindex, eshopid, refresh_time);
return db_service.sync_execute(buf);
}
int db_ConsumeLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
balance=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
consumetype=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
itemname = row_[i++];
consumetm = row_[i++];
return 0;
}
string db_ConsumeLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ConsumeLog` ( `nickname`  ,  `resid`  ,  `domain`  ,  `balance`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `consumetype`  ,  `aid`  ,  `itemname`  ,  `consumetm` ) VALUES ( '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , '%s' , '%s' )" , nickname.c_str(), resid, domain.c_str(), balance, uid, count, hostnum, consumetype, aid, itemname.c_str(), consumetm.c_str());
return string(buf);
}
int db_ConsumeLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ConsumeLog` ( `nickname`  ,  `resid`  ,  `domain`  ,  `balance`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `consumetype`  ,  `aid`  ,  `itemname`  ,  `consumetm` ) VALUES ( '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , '%s' , '%s' )" , nickname.c_str(), resid, domain.c_str(), balance, uid, count, hostnum, consumetype, aid, itemname.c_str(), consumetm.c_str());
return db_service.async_execute(buf);
}
int db_ConsumeLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ConsumeLog` ( `nickname`  ,  `resid`  ,  `domain`  ,  `balance`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `consumetype`  ,  `aid`  ,  `itemname`  ,  `consumetm` ) VALUES ( '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , '%s' , '%s' )" , nickname.c_str(), resid, domain.c_str(), balance, uid, count, hostnum, consumetype, aid, itemname.c_str(), consumetm.c_str());
return db_service.sync_execute(buf);
}
int db_Team_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;is_default=(int)std::atoi(row_[i++].c_str());
p5=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
name = row_[i++];
p4=(int)std::atoi(row_[i++].c_str());
p2=(int)std::atoi(row_[i++].c_str());
p3=(int)std::atoi(row_[i++].c_str());
tid=(int)std::atoi(row_[i++].c_str());
p1=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Team_t::select_team_default(const int32_t& uid_, const int32_t& is_default_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `is_default` , `p5` , `uid` , `name` , `p4` , `p2` , `p3` , `tid` , `p1` FROM `Team` WHERE  `uid` = %d AND  `is_default` = %d", uid_, is_default_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Team_t::select_team_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `is_default` , `p5` , `uid` , `name` , `p4` , `p2` , `p3` , `tid` , `p1` FROM `Team` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Team_t::sync_select_team_default(const int32_t& uid_, const int32_t& is_default_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `is_default` , `p5` , `uid` , `name` , `p4` , `p2` , `p3` , `tid` , `p1` FROM `Team` WHERE  `uid` = %d AND  `is_default` = %d", uid_, is_default_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Team_t::sync_select_team_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `is_default` , `p5` , `uid` , `name` , `p4` , `p2` , `p3` , `tid` , `p1` FROM `Team` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Team_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Team` SET  `is_default` = %d ,  `p5` = %d ,  `name` = '%s' ,  `p4` = %d ,  `p2` = %d ,  `p3` = %d ,  `p1` = %d WHERE  `uid` = %d AND  `tid` = %d", is_default, p5, name.c_str(), p4, p2, p3, p1, uid, tid);
return db_service.async_execute(buf);
}
int db_Team_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Team` SET  `is_default` = %d ,  `p5` = %d ,  `name` = '%s' ,  `p4` = %d ,  `p2` = %d ,  `p3` = %d ,  `p1` = %d WHERE  `uid` = %d AND  `tid` = %d", is_default, p5, name.c_str(), p4, p2, p3, p1, uid, tid);
return db_service.sync_execute(buf);
}
int db_Team_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Team` WHERE  `uid` = %d AND  `tid` = %d", uid, tid);
return db_service.async_execute(buf);
}
string db_Team_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Team` ( `is_default`  ,  `p5`  ,  `uid`  ,  `name`  ,  `p4`  ,  `p2`  ,  `p3`  ,  `tid`  ,  `p1` ) VALUES ( %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , is_default, p5, uid, name.c_str(), p4, p2, p3, tid, p1);
return string(buf);
}
int db_Team_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Team` ( `is_default`  ,  `p5`  ,  `uid`  ,  `name`  ,  `p4`  ,  `p2`  ,  `p3`  ,  `tid`  ,  `p1` ) VALUES ( %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , is_default, p5, uid, name.c_str(), p4, p2, p3, tid, p1);
return db_service.async_execute(buf);
}
int db_Team_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Team` ( `is_default`  ,  `p5`  ,  `uid`  ,  `name`  ,  `p4`  ,  `p2`  ,  `p3`  ,  `tid`  ,  `p1` ) VALUES ( %d , %d , %d , '%s' , %d , %d , %d , %d , %d )" , is_default, p5, uid, name.c_str(), p4, p2, p3, tid, p1);
return db_service.sync_execute(buf);
}
int db_ExpeditionPartners_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
hp=(float)std::atof(row_[i++].c_str());
return 0;
}
int db_ExpeditionPartners_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `ExpeditionPartners` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionPartners_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `hp` FROM `ExpeditionPartners` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ExpeditionPartners_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionPartners` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.async_execute(buf);
}
int db_ExpeditionPartners_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ExpeditionPartners` SET  `hp` = %f WHERE  `uid` = %d AND  `pid` = %d", hp, uid, pid);
return db_service.sync_execute(buf);
}
string db_ExpeditionPartners_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionPartners` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return string(buf);
}
int db_ExpeditionPartners_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionPartners` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.async_execute(buf);
}
int db_ExpeditionPartners_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ExpeditionPartners` ( `uid`  ,  `pid`  ,  `hp` ) VALUES ( %d , %d , %f )" , uid, pid, hp);
return db_service.sync_execute(buf);
}
int db_Task_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;state=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
step=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Task_t::select_task(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `resid` FROM `Task` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Task_t::sync_select_task(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `state` , `uid` , `step` , `resid` FROM `Task` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Task_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Task` SET  `state` = %d ,  `step` = %d WHERE  `uid` = %d AND  `resid` = %d", state, step, uid, resid);
return db_service.async_execute(buf);
}
int db_Task_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Task` SET  `state` = %d ,  `step` = %d WHERE  `uid` = %d AND  `resid` = %d", state, step, uid, resid);
return db_service.sync_execute(buf);
}
int db_Task_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Task` WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return db_service.async_execute(buf);
}
string db_Task_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Task` ( `state`  ,  `uid`  ,  `step`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , state, uid, step, resid);
return string(buf);
}
int db_Task_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Task` ( `state`  ,  `uid`  ,  `step`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , state, uid, step, resid);
return db_service.async_execute(buf);
}
int db_Task_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Task` ( `state`  ,  `uid`  ,  `step`  ,  `resid` ) VALUES ( %d , %d , %d , %d )" , state, uid, step, resid);
return db_service.sync_execute(buf);
}
int db_Server_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;serid=(int)std::atoi(row_[i++].c_str());
wbcut=(int)std::atoi(row_[i++].c_str());
ctime=(int)std::atoi(row_[i++].c_str());
maxlv=(int)std::atoi(row_[i++].c_str());
bosslv=(int)std::atoi(row_[i++].c_str());
result_rank_stamp=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Server_t::select_server(const int32_t& serid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `serid` , `wbcut` , `ctime` , `maxlv` , `bosslv` , `result_rank_stamp` FROM `Server` WHERE  `serid` = %d", serid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Server_t::sync_select_server(const int32_t& serid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `serid` , `wbcut` , `ctime` , `maxlv` , `bosslv` , `result_rank_stamp` FROM `Server` WHERE  `serid` = %d", serid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Server_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Server` SET  `wbcut` = %u ,  `ctime` = %u ,  `maxlv` = %d ,  `bosslv` = %d ,  `result_rank_stamp` = %u WHERE  `serid` = %d", wbcut, ctime, maxlv, bosslv, result_rank_stamp, serid);
return db_service.async_execute(buf);
}
int db_Server_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Server` SET  `wbcut` = %u ,  `ctime` = %u ,  `maxlv` = %d ,  `bosslv` = %d ,  `result_rank_stamp` = %u WHERE  `serid` = %d", wbcut, ctime, maxlv, bosslv, result_rank_stamp, serid);
return db_service.sync_execute(buf);
}
int db_Server_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Server` WHERE  `serid` = %d", serid);
return db_service.async_execute(buf);
}
string db_Server_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Server` ( `serid`  ,  `wbcut`  ,  `ctime`  ,  `maxlv`  ,  `bosslv`  ,  `result_rank_stamp` ) VALUES ( %d , %u , %u , %d , %d , %u )" , serid, wbcut, ctime, maxlv, bosslv, result_rank_stamp);
return string(buf);
}
int db_Server_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Server` ( `serid`  ,  `wbcut`  ,  `ctime`  ,  `maxlv`  ,  `bosslv`  ,  `result_rank_stamp` ) VALUES ( %d , %u , %u , %d , %d , %u )" , serid, wbcut, ctime, maxlv, bosslv, result_rank_stamp);
return db_service.async_execute(buf);
}
int db_Server_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Server` ( `serid`  ,  `wbcut`  ,  `ctime`  ,  `maxlv`  ,  `bosslv`  ,  `result_rank_stamp` ) VALUES ( %d , %u , %u , %d , %d , %u )" , serid, wbcut, ctime, maxlv, bosslv, result_rank_stamp);
return db_service.sync_execute(buf);
}
int db_RewardExtentionI_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;sevenpay_count=(int)std::atoi(row_[i++].c_str());
limit_seven_stage = row_[i++];
opentask_stage_two=(int)std::atoi(row_[i++].c_str());
sevenpay_stage = row_[i++];
opentask_reward=(int)std::atoi(row_[i++].c_str());
vip_days=(int)std::atoi(row_[i++].c_str());
luckbagvalue=(int)std::atoi(row_[i++].c_str());
limit_seven_count=(int)std::atoi(row_[i++].c_str());
openybtotal=(int)std::atoi(row_[i++].c_str());
vip_stamp=(int)std::atoi(row_[i++].c_str());
limit_seven_stamp=(int)std::atoi(row_[i++].c_str());
limit_pub=(int)std::atoi(row_[i++].c_str());
opentask_stage_one=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
opentask_stage_three=(int)std::atoi(row_[i++].c_str());
opentask_level=(int)std::atoi(row_[i++].c_str());
openybstamp=(int)std::atoi(row_[i++].c_str());
luckbagstamp=(int)std::atoi(row_[i++].c_str());
lastpay_timestamp=(int)std::atoi(row_[i++].c_str());
openybreward = row_[i++];
return 0;
}
int db_RewardExtentionI_t::select_reward(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `sevenpay_count` , `limit_seven_stage` , `opentask_stage_two` , `sevenpay_stage` , `opentask_reward` , `vip_days` , `luckbagvalue` , `limit_seven_count` , `openybtotal` , `vip_stamp` , `limit_seven_stamp` , `limit_pub` , `opentask_stage_one` , `uid` , `opentask_stage_three` , `opentask_level` , `openybstamp` , `luckbagstamp` , `lastpay_timestamp` , `openybreward` FROM `RewardExtentionI` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RewardExtentionI_t::sync_select_reward(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `sevenpay_count` , `limit_seven_stage` , `opentask_stage_two` , `sevenpay_stage` , `opentask_reward` , `vip_days` , `luckbagvalue` , `limit_seven_count` , `openybtotal` , `vip_stamp` , `limit_seven_stamp` , `limit_pub` , `opentask_stage_one` , `uid` , `opentask_stage_three` , `opentask_level` , `openybstamp` , `luckbagstamp` , `lastpay_timestamp` , `openybreward` FROM `RewardExtentionI` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RewardExtentionI_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RewardExtentionI` SET  `sevenpay_count` = %d ,  `limit_seven_stage` = '%s' ,  `opentask_stage_two` = %d ,  `sevenpay_stage` = '%s' ,  `opentask_reward` = %d ,  `vip_days` = %d ,  `luckbagvalue` = %d ,  `limit_seven_count` = %d ,  `openybtotal` = %d ,  `vip_stamp` = %d ,  `limit_seven_stamp` = %d ,  `limit_pub` = %d ,  `opentask_stage_one` = %d ,  `opentask_stage_three` = %d ,  `opentask_level` = %d ,  `openybstamp` = %d ,  `luckbagstamp` = %d ,  `lastpay_timestamp` = %d ,  `openybreward` = '%s' WHERE  `uid` = %d", sevenpay_count, limit_seven_stage.c_str(), opentask_stage_two, sevenpay_stage.c_str(), opentask_reward, vip_days, luckbagvalue, limit_seven_count, openybtotal, vip_stamp, limit_seven_stamp, limit_pub, opentask_stage_one, opentask_stage_three, opentask_level, openybstamp, luckbagstamp, lastpay_timestamp, openybreward.c_str(), uid);
return db_service.async_execute(buf);
}
int db_RewardExtentionI_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RewardExtentionI` SET  `sevenpay_count` = %d ,  `limit_seven_stage` = '%s' ,  `opentask_stage_two` = %d ,  `sevenpay_stage` = '%s' ,  `opentask_reward` = %d ,  `vip_days` = %d ,  `luckbagvalue` = %d ,  `limit_seven_count` = %d ,  `openybtotal` = %d ,  `vip_stamp` = %d ,  `limit_seven_stamp` = %d ,  `limit_pub` = %d ,  `opentask_stage_one` = %d ,  `opentask_stage_three` = %d ,  `opentask_level` = %d ,  `openybstamp` = %d ,  `luckbagstamp` = %d ,  `lastpay_timestamp` = %d ,  `openybreward` = '%s' WHERE  `uid` = %d", sevenpay_count, limit_seven_stage.c_str(), opentask_stage_two, sevenpay_stage.c_str(), opentask_reward, vip_days, luckbagvalue, limit_seven_count, openybtotal, vip_stamp, limit_seven_stamp, limit_pub, opentask_stage_one, opentask_stage_three, opentask_level, openybstamp, luckbagstamp, lastpay_timestamp, openybreward.c_str(), uid);
return db_service.sync_execute(buf);
}
int db_RewardExtentionI_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `RewardExtentionI` WHERE  `uid` = %d", uid);
return db_service.async_execute(buf);
}
string db_RewardExtentionI_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RewardExtentionI` ( `sevenpay_count`  ,  `limit_seven_stage`  ,  `opentask_stage_two`  ,  `sevenpay_stage`  ,  `opentask_reward`  ,  `vip_days`  ,  `luckbagvalue`  ,  `limit_seven_count`  ,  `openybtotal`  ,  `vip_stamp`  ,  `limit_seven_stamp`  ,  `limit_pub`  ,  `opentask_stage_one`  ,  `uid`  ,  `opentask_stage_three`  ,  `opentask_level`  ,  `openybstamp`  ,  `luckbagstamp`  ,  `lastpay_timestamp`  ,  `openybreward` ) VALUES ( %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' )" , sevenpay_count, limit_seven_stage.c_str(), opentask_stage_two, sevenpay_stage.c_str(), opentask_reward, vip_days, luckbagvalue, limit_seven_count, openybtotal, vip_stamp, limit_seven_stamp, limit_pub, opentask_stage_one, uid, opentask_stage_three, opentask_level, openybstamp, luckbagstamp, lastpay_timestamp, openybreward.c_str());
return string(buf);
}
int db_RewardExtentionI_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RewardExtentionI` ( `sevenpay_count`  ,  `limit_seven_stage`  ,  `opentask_stage_two`  ,  `sevenpay_stage`  ,  `opentask_reward`  ,  `vip_days`  ,  `luckbagvalue`  ,  `limit_seven_count`  ,  `openybtotal`  ,  `vip_stamp`  ,  `limit_seven_stamp`  ,  `limit_pub`  ,  `opentask_stage_one`  ,  `uid`  ,  `opentask_stage_three`  ,  `opentask_level`  ,  `openybstamp`  ,  `luckbagstamp`  ,  `lastpay_timestamp`  ,  `openybreward` ) VALUES ( %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' )" , sevenpay_count, limit_seven_stage.c_str(), opentask_stage_two, sevenpay_stage.c_str(), opentask_reward, vip_days, luckbagvalue, limit_seven_count, openybtotal, vip_stamp, limit_seven_stamp, limit_pub, opentask_stage_one, uid, opentask_stage_three, opentask_level, openybstamp, luckbagstamp, lastpay_timestamp, openybreward.c_str());
return db_service.async_execute(buf);
}
int db_RewardExtentionI_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RewardExtentionI` ( `sevenpay_count`  ,  `limit_seven_stage`  ,  `opentask_stage_two`  ,  `sevenpay_stage`  ,  `opentask_reward`  ,  `vip_days`  ,  `luckbagvalue`  ,  `limit_seven_count`  ,  `openybtotal`  ,  `vip_stamp`  ,  `limit_seven_stamp`  ,  `limit_pub`  ,  `opentask_stage_one`  ,  `uid`  ,  `opentask_stage_three`  ,  `opentask_level`  ,  `openybstamp`  ,  `luckbagstamp`  ,  `lastpay_timestamp`  ,  `openybreward` ) VALUES ( %d , '%s' , %d , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , %d , '%s' )" , sevenpay_count, limit_seven_stage.c_str(), opentask_stage_two, sevenpay_stage.c_str(), opentask_reward, vip_days, luckbagvalue, limit_seven_count, openybtotal, vip_stamp, limit_seven_stamp, limit_pub, opentask_stage_one, uid, opentask_stage_three, opentask_level, openybstamp, luckbagstamp, lastpay_timestamp, openybreward.c_str());
return db_service.sync_execute(buf);
}
int db_Cdkey_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;expire_date = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
sn = row_[i++];
flag=(int)std::atoi(row_[i++].c_str());
giventm = row_[i++];
domain = row_[i++];
nickname = row_[i++];
return 0;
}
int db_Cdkey_t::select_sn(const ystring_t<8>& sn_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `expire_date` , `uid` , `sn` , `flag` , `giventm` , `domain` , `nickname` FROM `Cdkey` WHERE  `sn` = '%s'", sn_.c_str());
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Cdkey_t::sync_select_sn(const ystring_t<8>& sn_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `expire_date` , `uid` , `sn` , `flag` , `giventm` , `domain` , `nickname` FROM `Cdkey` WHERE  `sn` = '%s'", sn_.c_str());
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Cdkey_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Cdkey` SET  `expire_date` = '%s' ,  `uid` = %d ,  `flag` = %d ,  `giventm` = '%s' ,  `domain` = '%s' ,  `nickname` = '%s' WHERE  `sn` = '%s'", expire_date.c_str(), uid, flag, giventm.c_str(), domain.c_str(), nickname.c_str(), sn.c_str());
return dbgl_service.async_execute(buf);
}
int db_Cdkey_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Cdkey` SET  `expire_date` = '%s' ,  `uid` = %d ,  `flag` = %d ,  `giventm` = '%s' ,  `domain` = '%s' ,  `nickname` = '%s' WHERE  `sn` = '%s'", expire_date.c_str(), uid, flag, giventm.c_str(), domain.c_str(), nickname.c_str(), sn.c_str());
return dbgl_service.sync_execute(buf);
}
string db_Cdkey_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Cdkey` ( `expire_date`  ,  `uid`  ,  `sn`  ,  `flag`  ,  `giventm`  ,  `domain`  ,  `nickname` ) VALUES ( '%s' , %d , '%s' , %d , '%s' , '%s' , '%s' )" , expire_date.c_str(), uid, sn.c_str(), flag, giventm.c_str(), domain.c_str(), nickname.c_str());
return string(buf);
}
int db_Cdkey_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Cdkey` ( `expire_date`  ,  `uid`  ,  `sn`  ,  `flag`  ,  `giventm`  ,  `domain`  ,  `nickname` ) VALUES ( '%s' , %d , '%s' , %d , '%s' , '%s' , '%s' )" , expire_date.c_str(), uid, sn.c_str(), flag, giventm.c_str(), domain.c_str(), nickname.c_str());
return dbgl_service.async_execute(buf);
}
int db_Cdkey_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Cdkey` ( `expire_date`  ,  `uid`  ,  `sn`  ,  `flag`  ,  `giventm`  ,  `domain`  ,  `nickname` ) VALUES ( '%s' , %d , '%s' , %d , '%s' , '%s' , '%s' )" , expire_date.c_str(), uid, sn.c_str(), flag, giventm.c_str(), domain.c_str(), nickname.c_str());
return dbgl_service.sync_execute(buf);
}
int db_NewAccount_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;ctime = row_[i++];
aid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
name = row_[i++];
return 0;
}
string db_NewAccount_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewAccount` ( `ctime`  ,  `aid`  ,  `domain`  ,  `name` ) VALUES ( '%s' , %d , '%s' , '%s' )" , ctime.c_str(), aid, domain.c_str(), name.c_str());
return string(buf);
}
int db_NewAccount_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewAccount` ( `ctime`  ,  `aid`  ,  `domain`  ,  `name` ) VALUES ( '%s' , %d , '%s' , '%s' )" , ctime.c_str(), aid, domain.c_str(), name.c_str());
return db_service.async_execute(buf);
}
int db_NewAccount_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NewAccount` ( `ctime`  ,  `aid`  ,  `domain`  ,  `name` ) VALUES ( '%s' , %d , '%s' , '%s' )" , ctime.c_str(), aid, domain.c_str(), name.c_str());
return db_service.sync_execute(buf);
}
int db_RuneShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;rshopid=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
rshopindex=(int)std::atoi(row_[i++].c_str());
refresh_time=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_RuneShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rshopid` , `uid` , `count` , `rshopindex` , `refresh_time` FROM `RuneShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `rshopid` , `uid` , `count` , `rshopindex` , `refresh_time` FROM `RuneShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_RuneShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneShop` SET  `rshopid` = %d ,  `count` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `rshopindex` = %d", rshopid, count, refresh_time, uid, rshopindex);
return db_service.async_execute(buf);
}
int db_RuneShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `RuneShop` SET  `rshopid` = %d ,  `count` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `rshopindex` = %d", rshopid, count, refresh_time, uid, rshopindex);
return db_service.sync_execute(buf);
}
string db_RuneShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneShop` ( `rshopid`  ,  `uid`  ,  `count`  ,  `rshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , rshopid, uid, count, rshopindex, refresh_time);
return string(buf);
}
int db_RuneShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneShop` ( `rshopid`  ,  `uid`  ,  `count`  ,  `rshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , rshopid, uid, count, rshopindex, refresh_time);
return db_service.async_execute(buf);
}
int db_RuneShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `RuneShop` ( `rshopid`  ,  `uid`  ,  `count`  ,  `rshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , rshopid, uid, count, rshopindex, refresh_time);
return db_service.sync_execute(buf);
}
int db_NpcShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;item2=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
item6=(int)std::atoi(row_[i++].c_str());
item5=(int)std::atoi(row_[i++].c_str());
item4=(int)std::atoi(row_[i++].c_str());
item3=(int)std::atoi(row_[i++].c_str());
item1=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_NpcShop_t::select_npcshop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `item2` , `uid` , `item6` , `item5` , `item4` , `item3` , `item1` FROM `NpcShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_NpcShop_t::sync_select_npcshop(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `item2` , `uid` , `item6` , `item5` , `item4` , `item3` , `item1` FROM `NpcShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_NpcShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `NpcShop` SET  `item2` = %d ,  `item6` = %d ,  `item5` = %d ,  `item4` = %d ,  `item3` = %d ,  `item1` = %d WHERE  `uid` = %d", item2, item6, item5, item4, item3, item1, uid);
return db_service.async_execute(buf);
}
int db_NpcShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `NpcShop` SET  `item2` = %d ,  `item6` = %d ,  `item5` = %d ,  `item4` = %d ,  `item3` = %d ,  `item1` = %d WHERE  `uid` = %d", item2, item6, item5, item4, item3, item1, uid);
return db_service.sync_execute(buf);
}
string db_NpcShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `NpcShop` ( `item2`  ,  `uid`  ,  `item6`  ,  `item5`  ,  `item4`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , item2, uid, item6, item5, item4, item3, item1);
return string(buf);
}
int db_NpcShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NpcShop` ( `item2`  ,  `uid`  ,  `item6`  ,  `item5`  ,  `item4`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , item2, uid, item6, item5, item4, item3, item1);
return db_service.async_execute(buf);
}
int db_NpcShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `NpcShop` ( `item2`  ,  `uid`  ,  `item6`  ,  `item5`  ,  `item4`  ,  `item3`  ,  `item1` ) VALUES ( %d , %d , %d , %d , %d , %d , %d )" , item2, uid, item6, item5, item4, item3, item1);
return db_service.sync_execute(buf);
}
int db_FpException_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
resfp=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
rolefp=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_FpException_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `FpException` ( `nickname`  ,  `uid`  ,  `resfp`  ,  `hostnum`  ,  `rolefp`  ,  `aid`  ,  `domain`  ,  `resid` ) VALUES ( '%s' , %d , %d , %d , %d , %d , '%s' , %d )" , nickname.c_str(), uid, resfp, hostnum, rolefp, aid, domain.c_str(), resid);
return string(buf);
}
int db_FpException_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FpException` ( `nickname`  ,  `uid`  ,  `resfp`  ,  `hostnum`  ,  `rolefp`  ,  `aid`  ,  `domain`  ,  `resid` ) VALUES ( '%s' , %d , %d , %d , %d , %d , '%s' , %d )" , nickname.c_str(), uid, resfp, hostnum, rolefp, aid, domain.c_str(), resid);
return db_service.async_execute(buf);
}
int db_FpException_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `FpException` ( `nickname`  ,  `uid`  ,  `resfp`  ,  `hostnum`  ,  `rolefp`  ,  `aid`  ,  `domain`  ,  `resid` ) VALUES ( '%s' , %d , %d , %d , %d , %d , '%s' , %d )" , nickname.c_str(), uid, resfp, hostnum, rolefp, aid, domain.c_str(), resid);
return db_service.sync_execute(buf);
}
int db_Pet_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;hp=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
atk=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
res=(int)std::atoi(row_[i++].c_str());
mgc=(int)std::atoi(row_[i++].c_str());
petid=(int)std::atoi(row_[i++].c_str());
def=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Pet_t::select_pet(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `hp` , `uid` , `atk` , `resid` , `res` , `mgc` , `petid` , `def` FROM `Pet` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pet_t::sync_select_pet(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `hp` , `uid` , `atk` , `resid` , `res` , `mgc` , `petid` , `def` FROM `Pet` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pet_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Pet` SET  `hp` = %d ,  `atk` = %d ,  `resid` = %d ,  `res` = %d ,  `mgc` = %d ,  `def` = %d WHERE  `uid` = %d AND  `petid` = %d", hp, atk, resid, res, mgc, def, uid, petid);
return db_service.async_execute(buf);
}
int db_Pet_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Pet` SET  `hp` = %d ,  `atk` = %d ,  `resid` = %d ,  `res` = %d ,  `mgc` = %d ,  `def` = %d WHERE  `uid` = %d AND  `petid` = %d", hp, atk, resid, res, mgc, def, uid, petid);
return db_service.sync_execute(buf);
}
int db_Pet_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Pet` WHERE  `uid` = %d AND  `petid` = %d", uid, petid);
return db_service.async_execute(buf);
}
string db_Pet_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pet` ( `hp`  ,  `uid`  ,  `atk`  ,  `resid`  ,  `res`  ,  `mgc`  ,  `petid`  ,  `def` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , hp, uid, atk, resid, res, mgc, petid, def);
return string(buf);
}
int db_Pet_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pet` ( `hp`  ,  `uid`  ,  `atk`  ,  `resid`  ,  `res`  ,  `mgc`  ,  `petid`  ,  `def` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , hp, uid, atk, resid, res, mgc, petid, def);
return db_service.async_execute(buf);
}
int db_Pet_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pet` ( `hp`  ,  `uid`  ,  `atk`  ,  `resid`  ,  `res`  ,  `mgc`  ,  `petid`  ,  `def` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , hp, uid, atk, resid, res, mgc, petid, def);
return db_service.sync_execute(buf);
}
int db_TreasureConqueror_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;profit=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
debian_secs=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
slot_pos=(int)std::atoi(row_[i++].c_str());
last_stamp=(int)std::atoi(row_[i++].c_str());
last_round=(int)std::atoi(row_[i++].c_str());
n_rob=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_TreasureConqueror_t::select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `profit` , `uid` , `debian_secs` , `hostnum` , `slot_pos` , `last_stamp` , `last_round` , `n_rob` FROM `TreasureConqueror` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureConqueror_t::sync_select_uid(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `profit` , `uid` , `debian_secs` , `hostnum` , `slot_pos` , `last_stamp` , `last_round` , `n_rob` FROM `TreasureConqueror` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_TreasureConqueror_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureConqueror` SET  `profit` = %d ,  `debian_secs` = %d ,  `hostnum` = %d ,  `slot_pos` = %d ,  `last_stamp` = %d ,  `last_round` = %d ,  `n_rob` = %d WHERE  `uid` = %d", profit, debian_secs, hostnum, slot_pos, last_stamp, last_round, n_rob, uid);
return db_service.async_execute(buf);
}
int db_TreasureConqueror_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `TreasureConqueror` SET  `profit` = %d ,  `debian_secs` = %d ,  `hostnum` = %d ,  `slot_pos` = %d ,  `last_stamp` = %d ,  `last_round` = %d ,  `n_rob` = %d WHERE  `uid` = %d", profit, debian_secs, hostnum, slot_pos, last_stamp, last_round, n_rob, uid);
return db_service.sync_execute(buf);
}
string db_TreasureConqueror_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureConqueror` ( `profit`  ,  `uid`  ,  `debian_secs`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `n_rob` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, debian_secs, hostnum, slot_pos, last_stamp, last_round, n_rob);
return string(buf);
}
int db_TreasureConqueror_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureConqueror` ( `profit`  ,  `uid`  ,  `debian_secs`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `n_rob` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, debian_secs, hostnum, slot_pos, last_stamp, last_round, n_rob);
return db_service.async_execute(buf);
}
int db_TreasureConqueror_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `TreasureConqueror` ( `profit`  ,  `uid`  ,  `debian_secs`  ,  `hostnum`  ,  `slot_pos`  ,  `last_stamp`  ,  `last_round`  ,  `n_rob` ) VALUES ( %d , %d , %d , %d , %d , %d , %d , %d )" , profit, uid, debian_secs, hostnum, slot_pos, last_stamp, last_round, n_rob);
return db_service.sync_execute(buf);
}
int db_GangShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
gshopid=(int)std::atoi(row_[i++].c_str());
gshopindex=(int)std::atoi(row_[i++].c_str());
refresh_time=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_GangShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `gshopid` , `gshopindex` , `refresh_time` FROM `GangShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `gshopid` , `gshopindex` , `refresh_time` FROM `GangShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_GangShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `GangShop` SET  `count` = %d ,  `gshopid` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `gshopindex` = %d", count, gshopid, refresh_time, uid, gshopindex);
return db_service.async_execute(buf);
}
int db_GangShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `GangShop` SET  `count` = %d ,  `gshopid` = %d ,  `refresh_time` = %d WHERE  `uid` = %d AND  `gshopindex` = %d", count, gshopid, refresh_time, uid, gshopindex);
return db_service.sync_execute(buf);
}
string db_GangShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangShop` ( `uid`  ,  `count`  ,  `gshopid`  ,  `gshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, gshopid, gshopindex, refresh_time);
return string(buf);
}
int db_GangShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangShop` ( `uid`  ,  `count`  ,  `gshopid`  ,  `gshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, gshopid, gshopindex, refresh_time);
return db_service.async_execute(buf);
}
int db_GangShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `GangShop` ( `uid`  ,  `count`  ,  `gshopid`  ,  `gshopindex`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %d )" , uid, count, gshopid, gshopindex, refresh_time);
return db_service.sync_execute(buf);
}
int db_EventLog_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;nickname = row_[i++];
resid=(int)std::atoi(row_[i++].c_str());
eventid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
extra = row_[i++];
uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
hostnum=(int)std::atoi(row_[i++].c_str());
eventm = row_[i++];
aid=(int)std::atoi(row_[i++].c_str());
flag=(int)std::atoi(row_[i++].c_str());
code=(int)std::atoi(row_[i++].c_str());
return 0;
}
string db_EventLog_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `EventLog` ( `nickname`  ,  `resid`  ,  `eventid`  ,  `domain`  ,  `extra`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `eventm`  ,  `aid`  ,  `flag`  ,  `code` ) VALUES ( '%s' , %d , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , %d , %d )" , nickname.c_str(), resid, eventid, domain.c_str(), extra.c_str(), uid, count, hostnum, eventm.c_str(), aid, flag, code);
return string(buf);
}
int db_EventLog_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `EventLog` ( `nickname`  ,  `resid`  ,  `eventid`  ,  `domain`  ,  `extra`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `eventm`  ,  `aid`  ,  `flag`  ,  `code` ) VALUES ( '%s' , %d , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , %d , %d )" , nickname.c_str(), resid, eventid, domain.c_str(), extra.c_str(), uid, count, hostnum, eventm.c_str(), aid, flag, code);
return db_service.async_execute(buf);
}
int db_EventLog_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `EventLog` ( `nickname`  ,  `resid`  ,  `eventid`  ,  `domain`  ,  `extra`  ,  `uid`  ,  `count`  ,  `hostnum`  ,  `eventm`  ,  `aid`  ,  `flag`  ,  `code` ) VALUES ( '%s' , %d , %d , '%s' , '%s' , %d , %d , %d , '%s' , %d , %d , %d )" , nickname.c_str(), resid, eventid, domain.c_str(), extra.c_str(), uid, count, hostnum, eventm.c_str(), aid, flag, code);
return db_service.sync_execute(buf);
}
int db_LmtShop_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
count=(int)std::atoi(row_[i++].c_str());
shopindex=(int)std::atoi(row_[i++].c_str());
shopid=(int)std::atoi(row_[i++].c_str());
refresh_time=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_LmtShop_t::select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `shopindex` , `shopid` , `refresh_time` FROM `LmtShop` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LmtShop_t::sync_select_all(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `count` , `shopindex` , `shopid` , `refresh_time` FROM `LmtShop` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_LmtShop_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `LmtShop` SET  `count` = %d ,  `shopindex` = %d ,  `refresh_time` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, shopindex, refresh_time, uid, shopid);
return db_service.async_execute(buf);
}
int db_LmtShop_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `LmtShop` SET  `count` = %d ,  `shopindex` = %d ,  `refresh_time` = %u WHERE  `uid` = %d AND  `shopid` = %d", count, shopindex, refresh_time, uid, shopid);
return db_service.sync_execute(buf);
}
string db_LmtShop_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `LmtShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return string(buf);
}
int db_LmtShop_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LmtShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return db_service.async_execute(buf);
}
int db_LmtShop_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `LmtShop` ( `uid`  ,  `count`  ,  `shopindex`  ,  `shopid`  ,  `refresh_time` ) VALUES ( %d , %d , %d , %d , %u )" , uid, count, shopindex, shopid, refresh_time);
return db_service.sync_execute(buf);
}
int db_ReportUser_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;reportNum=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
reportTime=(int)std::atoi(row_[i++].c_str());
accusedNum=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_ReportUser_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `reportNum` , `uid` , `reportTime` , `accusedNum` FROM `ReportUser` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ReportUser_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `reportNum` , `uid` , `reportTime` , `accusedNum` FROM `ReportUser` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_ReportUser_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `ReportUser` SET  `reportNum` = %d ,  `reportTime` = %d ,  `accusedNum` = %d WHERE  `uid` = %d", reportNum, reportTime, accusedNum, uid);
return db_service.async_execute(buf);
}
int db_ReportUser_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `ReportUser` SET  `reportNum` = %d ,  `reportTime` = %d ,  `accusedNum` = %d WHERE  `uid` = %d", reportNum, reportTime, accusedNum, uid);
return db_service.sync_execute(buf);
}
string db_ReportUser_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `ReportUser` ( `reportNum`  ,  `uid`  ,  `reportTime`  ,  `accusedNum` ) VALUES ( %d , %d , %d , %d )" , reportNum, uid, reportTime, accusedNum);
return string(buf);
}
int db_ReportUser_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ReportUser` ( `reportNum`  ,  `uid`  ,  `reportTime`  ,  `accusedNum` ) VALUES ( %d , %d , %d , %d )" , reportNum, uid, reportTime, accusedNum);
return db_service.async_execute(buf);
}
int db_ReportUser_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `ReportUser` ( `reportNum`  ,  `uid`  ,  `reportTime`  ,  `accusedNum` ) VALUES ( %d , %d , %d , %d )" , reportNum, uid, reportTime, accusedNum);
return db_service.sync_execute(buf);
}
int db_Rune_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uid=(int)std::atoi(row_[i++].c_str());
pid=(int)std::atoi(row_[i++].c_str());
resid=(int)std::atoi(row_[i++].c_str());
rid=(int)std::atoi(row_[i++].c_str());
exp=(int)std::atoi(row_[i++].c_str());
pos=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Rune_t::select_rune(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `resid` , `rid` , `exp` , `pos` FROM `Rune` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Rune_t::sync_select_rune(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uid` , `pid` , `resid` , `rid` , `exp` , `pos` FROM `Rune` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Rune_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Rune` SET  `uid` = %d ,  `pid` = %d ,  `resid` = %d ,  `exp` = %d ,  `pos` = %d WHERE  `uid` = %d AND  `rid` = %d", uid, pid, resid, exp, pos, uid, rid);
return db_service.async_execute(buf);
}
int db_Rune_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Rune` SET  `uid` = %d ,  `pid` = %d ,  `resid` = %d ,  `exp` = %d ,  `pos` = %d WHERE  `uid` = %d AND  `rid` = %d", uid, pid, resid, exp, pos, uid, rid);
return db_service.sync_execute(buf);
}
int db_Rune_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Rune` WHERE  `uid` = %d AND  `rid` = %d", uid, rid);
return db_service.async_execute(buf);
}
string db_Rune_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rune` ( `uid`  ,  `pid`  ,  `resid`  ,  `rid`  ,  `exp`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, resid, rid, exp, pos);
return string(buf);
}
int db_Rune_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rune` ( `uid`  ,  `pid`  ,  `resid`  ,  `rid`  ,  `exp`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, resid, rid, exp, pos);
return db_service.async_execute(buf);
}
int db_Rune_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Rune` ( `uid`  ,  `pid`  ,  `resid`  ,  `rid`  ,  `exp`  ,  `pos` ) VALUES ( %d , %d , %d , %d , %d , %d )" , uid, pid, resid, rid, exp, pos);
return db_service.sync_execute(buf);
}
int db_Arena_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;stamp=(int)std::atoi(row_[i++].c_str());
fight_count=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
in_buy=(int)std::atoi(row_[i++].c_str());
target_id=(int)std::atoi(row_[i++].c_str());
win_count=(int)std::atoi(row_[i++].c_str());
in_stamp=(int)std::atoi(row_[i++].c_str());
n_buy=(int)std::atoi(row_[i++].c_str());
in_fight_count=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Arena_t::select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `stamp` , `fight_count` , `uid` , `in_buy` , `target_id` , `win_count` , `in_stamp` , `n_buy` , `in_fight_count` FROM `Arena` WHERE  `uid` = %d", uid_);
db_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Arena_t::sync_select(const int32_t& uid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `stamp` , `fight_count` , `uid` , `in_buy` , `target_id` , `win_count` , `in_stamp` , `n_buy` , `in_fight_count` FROM `Arena` WHERE  `uid` = %d", uid_);
db_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Arena_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Arena` SET  `stamp` = %u ,  `fight_count` = %d ,  `in_buy` = %d ,  `target_id` = %d ,  `win_count` = %d ,  `in_stamp` = %u ,  `n_buy` = %d ,  `in_fight_count` = %d WHERE  `uid` = %d", stamp, fight_count, in_buy, target_id, win_count, in_stamp, n_buy, in_fight_count, uid);
return db_service.async_execute(buf);
}
int db_Arena_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Arena` SET  `stamp` = %u ,  `fight_count` = %d ,  `in_buy` = %d ,  `target_id` = %d ,  `win_count` = %d ,  `in_stamp` = %u ,  `n_buy` = %d ,  `in_fight_count` = %d WHERE  `uid` = %d", stamp, fight_count, in_buy, target_id, win_count, in_stamp, n_buy, in_fight_count, uid);
return db_service.sync_execute(buf);
}
string db_Arena_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Arena` ( `stamp`  ,  `fight_count`  ,  `uid`  ,  `in_buy`  ,  `target_id`  ,  `win_count`  ,  `in_stamp`  ,  `n_buy`  ,  `in_fight_count` ) VALUES ( %u , %d , %d , %d , %d , %d , %u , %d , %d )" , stamp, fight_count, uid, in_buy, target_id, win_count, in_stamp, n_buy, in_fight_count);
return string(buf);
}
int db_Arena_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Arena` ( `stamp`  ,  `fight_count`  ,  `uid`  ,  `in_buy`  ,  `target_id`  ,  `win_count`  ,  `in_stamp`  ,  `n_buy`  ,  `in_fight_count` ) VALUES ( %u , %d , %d , %d , %d , %d , %u , %d , %d )" , stamp, fight_count, uid, in_buy, target_id, win_count, in_stamp, n_buy, in_fight_count);
return db_service.async_execute(buf);
}
int db_Arena_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Arena` ( `stamp`  ,  `fight_count`  ,  `uid`  ,  `in_buy`  ,  `target_id`  ,  `win_count`  ,  `in_stamp`  ,  `n_buy`  ,  `in_fight_count` ) VALUES ( %u , %d , %d , %d , %d , %d , %u , %d , %d )" , stamp, fight_count, uid, in_buy, target_id, win_count, in_stamp, n_buy, in_fight_count);
return db_service.sync_execute(buf);
}
int db_Pay_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;uin = row_[i++];
cristal=(int)std::atoi(row_[i++].c_str());
appid = row_[i++];
giventime = row_[i++];
paytime = row_[i++];
domain = row_[i++];
repo_rmb=(int)std::atoi(row_[i++].c_str());
state=(int)std::atoi(row_[i++].c_str());
serid=(int)std::atoi(row_[i++].c_str());
goodsid=(int)std::atoi(row_[i++].c_str());
goodnum=(int)std::atoi(row_[i++].c_str());
reward_cristal=(int)std::atoi(row_[i++].c_str());
pay_rmb=(int)std::atoi(row_[i++].c_str());
uid=(int)std::atoi(row_[i++].c_str());
sid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Pay_t::select_serid(const int32_t& serid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uin` , `cristal` , `appid` , `giventime` , `paytime` , `domain` , `repo_rmb` , `state` , `serid` , `goodsid` , `goodnum` , `reward_cristal` , `pay_rmb` , `uid` , `sid` FROM `Pay` WHERE  `serid` = %d", serid_);
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pay_t::select_uid_state(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uin` , `cristal` , `appid` , `giventime` , `paytime` , `domain` , `repo_rmb` , `state` , `serid` , `goodsid` , `goodnum` , `reward_cristal` , `pay_rmb` , `uid` , `sid` FROM `Pay` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pay_t::sync_select_serid(const int32_t& serid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uin` , `cristal` , `appid` , `giventime` , `paytime` , `domain` , `repo_rmb` , `state` , `serid` , `goodsid` , `goodnum` , `reward_cristal` , `pay_rmb` , `uid` , `sid` FROM `Pay` WHERE  `serid` = %d", serid_);
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pay_t::sync_select_uid_state(const int32_t& uid_, const int32_t& state_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `uin` , `cristal` , `appid` , `giventime` , `paytime` , `domain` , `repo_rmb` , `state` , `serid` , `goodsid` , `goodnum` , `reward_cristal` , `pay_rmb` , `uid` , `sid` FROM `Pay` WHERE  `uid` = %d AND  `state` = %d", uid_, state_);
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Pay_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Pay` SET  `cristal` = %d ,  `giventime` = '%s' ,  `paytime` = '%s' ,  `domain` = '%s' ,  `repo_rmb` = %d ,  `state` = %d ,  `reward_cristal` = %d ,  `pay_rmb` = %d WHERE  `serid` = %d", cristal, giventime.c_str(), paytime.c_str(), domain.c_str(), repo_rmb, state, reward_cristal, pay_rmb, serid);
return dbgl_service.async_execute(buf);
}
int db_Pay_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Pay` SET  `cristal` = %d ,  `giventime` = '%s' ,  `paytime` = '%s' ,  `domain` = '%s' ,  `repo_rmb` = %d ,  `state` = %d ,  `reward_cristal` = %d ,  `pay_rmb` = %d WHERE  `serid` = %d", cristal, giventime.c_str(), paytime.c_str(), domain.c_str(), repo_rmb, state, reward_cristal, pay_rmb, serid);
return dbgl_service.sync_execute(buf);
}
string db_Pay_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pay` ( `uin`  ,  `cristal`  ,  `appid`  ,  `giventime`  ,  `paytime`  ,  `domain`  ,  `repo_rmb`  ,  `state`  ,  `serid`  ,  `goodsid`  ,  `goodnum`  ,  `reward_cristal`  ,  `pay_rmb`  ,  `uid`  ,  `sid` ) VALUES ( '%s' , %d , '%s' , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , uin.c_str(), cristal, appid.c_str(), giventime.c_str(), paytime.c_str(), domain.c_str(), repo_rmb, state, serid, goodsid, goodnum, reward_cristal, pay_rmb, uid, sid);
return string(buf);
}
int db_Pay_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pay` ( `uin`  ,  `cristal`  ,  `appid`  ,  `giventime`  ,  `paytime`  ,  `domain`  ,  `repo_rmb`  ,  `state`  ,  `serid`  ,  `goodsid`  ,  `goodnum`  ,  `reward_cristal`  ,  `pay_rmb`  ,  `uid`  ,  `sid` ) VALUES ( '%s' , %d , '%s' , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , uin.c_str(), cristal, appid.c_str(), giventime.c_str(), paytime.c_str(), domain.c_str(), repo_rmb, state, serid, goodsid, goodnum, reward_cristal, pay_rmb, uid, sid);
return dbgl_service.async_execute(buf);
}
int db_Pay_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Pay` ( `uin`  ,  `cristal`  ,  `appid`  ,  `giventime`  ,  `paytime`  ,  `domain`  ,  `repo_rmb`  ,  `state`  ,  `serid`  ,  `goodsid`  ,  `goodnum`  ,  `reward_cristal`  ,  `pay_rmb`  ,  `uid`  ,  `sid` ) VALUES ( '%s' , %d , '%s' , '%s' , '%s' , '%s' , %d , %d , %d , %d , %d , %d , %d , %d , %d )" , uin.c_str(), cristal, appid.c_str(), giventime.c_str(), paytime.c_str(), domain.c_str(), repo_rmb, state, serid, goodsid, goodnum, reward_cristal, pay_rmb, uid, sid);
return dbgl_service.sync_execute(buf);
}
int db_Account_t::init(sql_result_row_t& row_){
    if (row_.empty())
    {
        return -1;
    }
    size_t i=0;name = row_[i++];
lasthostnum=(int)std::atoi(row_[i++].c_str());
flag=(int)std::atoi(row_[i++].c_str());
aid=(int)std::atoi(row_[i++].c_str());
domain = row_[i++];
lastuid=(int)std::atoi(row_[i++].c_str());
return 0;
}
int db_Account_t::select_aid(const int32_t& aid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `name` , `lasthostnum` , `flag` , `aid` , `domain` , `lastuid` FROM `Account` WHERE  `aid` = %d", aid_);
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Account_t::select_name(const ystring_t<10>& domain_, const ystring_t<64>& name_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `name` , `lasthostnum` , `flag` , `aid` , `domain` , `lastuid` FROM `Account` WHERE  `domain` = '%s' AND  `name` = '%s'", domain_.c_str(), name_.c_str());
dbgl_service.async_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Account_t::sync_select_aid(const int32_t& aid_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `name` , `lasthostnum` , `flag` , `aid` , `domain` , `lastuid` FROM `Account` WHERE  `aid` = %d", aid_);
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Account_t::sync_select_name(const ystring_t<10>& domain_, const ystring_t<64>& name_, sql_result_t &res_){
char buf[4096];
sprintf(buf, "SELECT `name` , `lasthostnum` , `flag` , `aid` , `domain` , `lastuid` FROM `Account` WHERE  `domain` = '%s' AND  `name` = '%s'", domain_.c_str(), name_.c_str());
dbgl_service.sync_select(buf, res_);
        sql_result_row_t* row = res_.get_row_at(0); 
        if (row != NULL)
        {
            return 0;
        }
        return -1;
}
int db_Account_t::update(){
char buf[4096];
sprintf(buf, "UPDATE `Account` SET  `lasthostnum` = %d ,  `flag` = %d ,  `domain` = '%s' ,  `lastuid` = %d WHERE  `aid` = %d", lasthostnum, flag, domain.c_str(), lastuid, aid);
return dbgl_service.async_execute(buf);
}
int db_Account_t::sync_update(){
char buf[4096];
sprintf(buf, "UPDATE `Account` SET  `lasthostnum` = %d ,  `flag` = %d ,  `domain` = '%s' ,  `lastuid` = %d WHERE  `aid` = %d", lasthostnum, flag, domain.c_str(), lastuid, aid);
return dbgl_service.sync_execute(buf);
}
int db_Account_t::remove(){
char buf[4096];
sprintf(buf, "DELETE FROM `Account` WHERE  `aid` = %d", aid);
return dbgl_service.async_execute(buf);
}
string db_Account_t::gen_insert_sql(){
char buf[4096];
sprintf(buf, "INSERT INTO `Account` ( `name`  ,  `lasthostnum`  ,  `flag`  ,  `aid`  ,  `domain`  ,  `lastuid` ) VALUES ( '%s' , %d , %d , %d , '%s' , %d )" , name.c_str(), lasthostnum, flag, aid, domain.c_str(), lastuid);
return string(buf);
}
int db_Account_t::insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Account` ( `name`  ,  `lasthostnum`  ,  `flag`  ,  `aid`  ,  `domain`  ,  `lastuid` ) VALUES ( '%s' , %d , %d , %d , '%s' , %d )" , name.c_str(), lasthostnum, flag, aid, domain.c_str(), lastuid);
return dbgl_service.async_execute(buf);
}
int db_Account_t::sync_insert(){
char buf[4096];
sprintf(buf, "INSERT INTO `Account` ( `name`  ,  `lasthostnum`  ,  `flag`  ,  `aid`  ,  `domain`  ,  `lastuid` ) VALUES ( '%s' , %d , %d , %d , '%s' , %d )" , name.c_str(), lasthostnum, flag, aid, domain.c_str(), lastuid);
return dbgl_service.sync_execute(buf);
}
