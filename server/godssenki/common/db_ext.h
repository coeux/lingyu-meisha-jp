#ifndef _db_ext_h_
#define _db_ext_h_
#include "db_def.h"
#include "db_smart_up.h"
#include <boost/noncopyable.hpp>
class db_ActDailyTask_ext_t: public db_ActDailyTask_t, db_smart_up_t, boost::noncopyable
{
public:
db_ActDailyTask_ext_t()
{
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,step)
REG_MEM(int32_t,collect)
}
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,step)
DEC_SET(int32_t,collect)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ActDailyTask` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_ActDailyTask_t& data()
{
return *((db_ActDailyTask_t*)(this));
}
};
class db_Treasure_ext_t: public db_Treasure_t, db_smart_up_t, boost::noncopyable
{
public:
db_Treasure_ext_t()
{
REG_MEM(int32_t,utime)
REG_MEM(int32_t,reset_num)
}
DEC_SET(int32_t,utime)
DEC_SET(int32_t,reset_num)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Treasure` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_Treasure_t& data()
{
return *((db_Treasure_t*)(this));
}
};
class db_CardEventUserPartner_ext_t: public db_CardEventUserPartner_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventUserPartner_ext_t()
{
REG_MEM(float,hp)
}
DEC_SET(float,hp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventUserPartner` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d", uid, pid);
return gen_up_sql(buf);
}
db_CardEventUserPartner_t& data()
{
return *((db_CardEventUserPartner_t*)(this));
}
};
class db_Star_ext_t: public db_Star_t, db_smart_up_t, boost::noncopyable
{
public:
db_Star_ext_t()
{
REG_MEM(int32_t,value)
REG_MEM(int32_t,att)
}
DEC_SET(int32_t,value)
DEC_SET(int32_t,att)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Star` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d AND  `lv` = %d AND  `pos` = %d", uid, pid, lv, pos);
return gen_up_sql(buf);
}
db_Star_t& data()
{
return *((db_Star_t*)(this));
}
};
class db_ChipShop_ext_t: public db_ChipShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_ChipShop_ext_t()
{
REG_MEM(uint32_t,buystamp)
REG_MEM(int32_t,count)
}
DEC_SET(uint32_t,buystamp)
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ChipShop` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_ChipShop_t& data()
{
return *((db_ChipShop_t*)(this));
}
};
class db_Vip_ext_t: public db_Vip_t, db_smart_up_t, boost::noncopyable
{
public:
db_Vip_ext_t()
{
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,num)
}
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,num)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Vip` SET %%1%% WHERE  `uid` = %d AND  `vop` = %d", uid, vop);
return gen_up_sql(buf);
}
db_Vip_t& data()
{
return *((db_Vip_t*)(this));
}
};
class db_PlantShop_ext_t: public db_PlantShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_PlantShop_ext_t()
{
REG_MEM(uint32_t,buystamp)
REG_MEM(int32_t,count)
}
DEC_SET(uint32_t,buystamp)
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `PlantShop` SET %%1%% WHERE  `uid` = %d AND  `plantid` = %d", uid, plantid);
return gen_up_sql(buf);
}
db_PlantShop_t& data()
{
return *((db_PlantShop_t*)(this));
}
};
class db_RankSeason_ext_t: public db_RankSeason_t, db_smart_up_t, boost::noncopyable
{
public:
db_RankSeason_ext_t()
{
REG_MEM(int32_t,score)
REG_MEM(int32_t,last_fight_stamp)
REG_MEM(int32_t,max_rank)
REG_MEM(int32_t,successive_defeat)
REG_MEM(int32_t,season)
REG_MEM(int32_t,rank)
}
DEC_SET(int32_t,score)
DEC_SET(int32_t,last_fight_stamp)
DEC_SET(int32_t,max_rank)
DEC_SET(int32_t,successive_defeat)
DEC_SET(int32_t,season)
DEC_SET(int32_t,rank)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RankSeason` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_RankSeason_t& data()
{
return *((db_RankSeason_t*)(this));
}
};
class db_TreasureSlot_ext_t: public db_TreasureSlot_t, db_smart_up_t, boost::noncopyable
{
public:
db_TreasureSlot_ext_t()
{
REG_MEM(string,nickname)
REG_MEM(int32_t,slot_type)
REG_MEM(int32_t,stamp)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,id)
REG_MEM(int32_t,begin_pvp_fight_time)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,is_pvp_fighting)
REG_MEM(string,robers)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,lovelevel)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,rob_money)
REG_MEM(int32_t,slot_pos)
REG_MEM(int32_t,fp)
REG_MEM(int32_t,n_rob)
}
DEC_SET(string,nickname)
DEC_SET(int32_t,slot_type)
DEC_SET(int32_t,stamp)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,id)
DEC_SET(int32_t,begin_pvp_fight_time)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,is_pvp_fighting)
DEC_SET(string,robers)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,lovelevel)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,rob_money)
DEC_SET(int32_t,slot_pos)
DEC_SET(int32_t,fp)
DEC_SET(int32_t,n_rob)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `TreasureSlot` SET %%1%% WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", hostnum, slot_type, slot_pos);
return gen_up_sql(buf);
}
db_TreasureSlot_t& data()
{
return *((db_TreasureSlot_t*)(this));
}
};
class db_Achievement_ext_t: public db_Achievement_t, db_smart_up_t, boost::noncopyable
{
public:
db_Achievement_ext_t()
{
REG_MEM(int32_t,tasktype)
REG_MEM(int32_t,systype)
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,step)
REG_MEM(int32_t,collect)
}
DEC_SET(int32_t,tasktype)
DEC_SET(int32_t,systype)
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,step)
DEC_SET(int32_t,collect)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Achievement` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_Achievement_t& data()
{
return *((db_Achievement_t*)(this));
}
};
class db_Expedition_ext_t: public db_Expedition_t, db_smart_up_t, boost::noncopyable
{
public:
db_Expedition_ext_t()
{
REG_MEM(int32_t,open_box)
REG_MEM(float,hp4)
REG_MEM(int32_t,is_refresh_today)
REG_MEM(float,hp3)
REG_MEM(int32_t,refresh_type)
REG_MEM(float,hp2)
REG_MEM(int32_t,pid3)
REG_MEM(int32_t,utime)
REG_MEM(string,view_data)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,pid1)
REG_MEM(float,hp5)
REG_MEM(int32_t,pid5)
REG_MEM(float,hp1)
}
DEC_SET(int32_t,open_box)
DEC_SET(float,hp4)
DEC_SET(int32_t,is_refresh_today)
DEC_SET(float,hp3)
DEC_SET(int32_t,refresh_type)
DEC_SET(float,hp2)
DEC_SET(int32_t,pid3)
DEC_SET(int32_t,utime)
DEC_SET(string,view_data)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,pid1)
DEC_SET(float,hp5)
DEC_SET(int32_t,pid5)
DEC_SET(float,hp1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Expedition` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_Expedition_t& data()
{
return *((db_Expedition_t*)(this));
}
};
class db_GangUser_ext_t: public db_GangUser_t, db_smart_up_t, boost::noncopyable
{
public:
db_GangUser_ext_t()
{
REG_MEM(uint32_t,todaycount)
REG_MEM(int32_t,flag)
REG_MEM(uint32_t,bossrewardcount)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,totalgm)
REG_MEM(int32_t,skl8)
REG_MEM(int32_t,skl6)
REG_MEM(uint32_t,lastenter)
REG_MEM(ystring_t<30>,nickname)
REG_MEM(uint32_t,lastquit)
REG_MEM(int32_t,skl7)
REG_MEM(int32_t,skl5)
REG_MEM(int32_t,skl1)
REG_MEM(int32_t,ggid)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,skl2)
REG_MEM(uint32_t,lastboss)
REG_MEM(int32_t,skl4)
REG_MEM(int32_t,skl3)
REG_MEM(uint32_t,bossrewardtime)
REG_MEM(int32_t,gm)
REG_MEM(int32_t,state)
REG_MEM(int32_t,rank)
}
DEC_SET(uint32_t,todaycount)
DEC_SET(int32_t,flag)
DEC_SET(uint32_t,bossrewardcount)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,totalgm)
DEC_SET(int32_t,skl8)
DEC_SET(int32_t,skl6)
DEC_SET(uint32_t,lastenter)
DEC_SET(ystring_t<30>,nickname)
DEC_SET(uint32_t,lastquit)
DEC_SET(int32_t,skl7)
DEC_SET(int32_t,skl5)
DEC_SET(int32_t,skl1)
DEC_SET(int32_t,ggid)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,skl2)
DEC_SET(uint32_t,lastboss)
DEC_SET(int32_t,skl4)
DEC_SET(int32_t,skl3)
DEC_SET(uint32_t,bossrewardtime)
DEC_SET(int32_t,gm)
DEC_SET(int32_t,state)
DEC_SET(int32_t,rank)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GangUser` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_GangUser_t& data()
{
return *((db_GangUser_t*)(this));
}
};
class db_ChatUser_ext_t: public db_ChatUser_t, db_smart_up_t, boost::noncopyable
{
public:
db_ChatUser_ext_t()
{
REG_MEM(int32_t,id)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,player_uid)
REG_MEM(int32_t,stmp)
}
DEC_SET(int32_t,id)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,player_uid)
DEC_SET(int32_t,stmp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ChatUser` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_ChatUser_t& data()
{
return *((db_ChatUser_t*)(this));
}
};
class db_GangBossGuwu_ext_t: public db_GangBossGuwu_t, db_smart_up_t, boost::noncopyable
{
public:
db_GangBossGuwu_ext_t()
{
REG_MEM(int32_t,stamp_yb)
REG_MEM(int32_t,progress)
REG_MEM(int32_t,stamp_coin)
REG_MEM(int32_t,stamp_v)
REG_MEM(float,v)
}
DEC_SET(int32_t,stamp_yb)
DEC_SET(int32_t,progress)
DEC_SET(int32_t,stamp_coin)
DEC_SET(int32_t,stamp_v)
DEC_SET(float,v)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GangBossGuwu` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_GangBossGuwu_t& data()
{
return *((db_GangBossGuwu_t*)(this));
}
};
class db_ChipValue_ext_t: public db_ChipValue_t, db_smart_up_t, boost::noncopyable
{
public:
db_ChipValue_ext_t()
{
REG_MEM(int32_t,trend)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,price)
REG_MEM(int32_t,cur_value)
}
DEC_SET(int32_t,trend)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,price)
DEC_SET(int32_t,cur_value)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ChipValue` SET %%1%% WHERE  `id` = %d", id);
return gen_up_sql(buf);
}
db_ChipValue_t& data()
{
return *((db_ChipValue_t*)(this));
}
};
class db_Skill_ext_t: public db_Skill_t, db_smart_up_t, boost::noncopyable
{
public:
db_Skill_ext_t()
{
REG_MEM(int32_t,resid)
REG_MEM(int32_t,level)
}
DEC_SET(int32_t,resid)
DEC_SET(int32_t,level)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Skill` SET %%1%% WHERE  `uid` = %d AND  `skid` = %d", uid, skid);
return gen_up_sql(buf);
}
db_Skill_t& data()
{
return *((db_Skill_t*)(this));
}
};
class db_Shop_ext_t: public db_Shop_t, db_smart_up_t, boost::noncopyable
{
public:
db_Shop_ext_t()
{
REG_MEM(int32_t,count)
}
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Shop` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_Shop_t& data()
{
return *((db_Shop_t*)(this));
}
};
class db_SpShop_ext_t: public db_SpShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_SpShop_ext_t()
{
REG_MEM(int32_t,item11)
REG_MEM(int32_t,item10)
REG_MEM(int32_t,item8)
REG_MEM(int32_t,item12)
REG_MEM(int32_t,item4)
REG_MEM(int32_t,item2)
REG_MEM(int32_t,item6)
REG_MEM(int32_t,item9)
REG_MEM(int32_t,item7)
REG_MEM(int32_t,item5)
REG_MEM(int32_t,item3)
REG_MEM(int32_t,item1)
}
DEC_SET(int32_t,item11)
DEC_SET(int32_t,item10)
DEC_SET(int32_t,item8)
DEC_SET(int32_t,item12)
DEC_SET(int32_t,item4)
DEC_SET(int32_t,item2)
DEC_SET(int32_t,item6)
DEC_SET(int32_t,item9)
DEC_SET(int32_t,item7)
DEC_SET(int32_t,item5)
DEC_SET(int32_t,item3)
DEC_SET(int32_t,item1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `SpShop` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_SpShop_t& data()
{
return *((db_SpShop_t*)(this));
}
};
class db_RuneItem_ext_t: public db_RuneItem_t, db_smart_up_t, boost::noncopyable
{
public:
db_RuneItem_ext_t()
{
REG_MEM(int32_t,resid)
REG_MEM(int32_t,level)
REG_MEM(int32_t,exp)
}
DEC_SET(int32_t,resid)
DEC_SET(int32_t,level)
DEC_SET(int32_t,exp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RuneItem` SET %%1%% WHERE  `uid` = %d AND  `id` = %d", uid, id);
return gen_up_sql(buf);
}
db_RuneItem_t& data()
{
return *((db_RuneItem_t*)(this));
}
};
class db_FriendFlower_ext_t: public db_FriendFlower_t, db_smart_up_t, boost::noncopyable
{
public:
db_FriendFlower_ext_t()
{
REG_MEM(int32_t,fuid)
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,id)
REG_MEM(int32_t,getPower)
REG_MEM(int32_t,uid)
REG_MEM(ystring_t<30>,name)
REG_MEM(int32_t,lifetime)
REG_MEM(int32_t,lv)
REG_MEM(int32_t,headid)
}
DEC_SET(int32_t,fuid)
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,id)
DEC_SET(int32_t,getPower)
DEC_SET(int32_t,uid)
DEC_SET(ystring_t<30>,name)
DEC_SET(int32_t,lifetime)
DEC_SET(int32_t,lv)
DEC_SET(int32_t,headid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `FriendFlower` SET %%1%% WHERE  `id` = %d", id);
return gen_up_sql(buf);
}
db_FriendFlower_t& data()
{
return *((db_FriendFlower_t*)(this));
}
};
class db_HomeFarm_ext_t: public db_HomeFarm_t, db_smart_up_t, boost::noncopyable
{
public:
db_HomeFarm_ext_t()
{
REG_MEM(int32_t,getstamp)
REG_MEM(int32_t,isend)
REG_MEM(int32_t,losetime)
REG_MEM(int32_t,getnum)
REG_MEM(int32_t,canrob)
REG_MEM(int32_t,cstamp)
REG_MEM(int32_t,farmid)
REG_MEM(int32_t,itemid)
}
DEC_SET(int32_t,getstamp)
DEC_SET(int32_t,isend)
DEC_SET(int32_t,losetime)
DEC_SET(int32_t,getnum)
DEC_SET(int32_t,canrob)
DEC_SET(int32_t,cstamp)
DEC_SET(int32_t,farmid)
DEC_SET(int32_t,itemid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `HomeFarm` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_HomeFarm_t& data()
{
return *((db_HomeFarm_t*)(this));
}
};
class db_Gang_ext_t: public db_Gang_t, db_smart_up_t, boost::noncopyable
{
public:
db_Gang_ext_t()
{
REG_MEM(int32_t,todaycount)
REG_MEM(int32_t,exp)
REG_MEM(ystring_t<100>,notice)
REG_MEM(int32_t,bosscount)
REG_MEM(int32_t,bossday)
REG_MEM(int32_t,lastboss)
REG_MEM(ystring_t<30>,name)
REG_MEM(int32_t,level)
REG_MEM(int32_t,bosslv)
}
DEC_SET(int32_t,todaycount)
DEC_SET(int32_t,exp)
DEC_SET(ystring_t<100>,notice)
DEC_SET(int32_t,bosscount)
DEC_SET(int32_t,bossday)
DEC_SET(int32_t,lastboss)
DEC_SET(ystring_t<30>,name)
DEC_SET(int32_t,level)
DEC_SET(int32_t,bosslv)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Gang` SET %%1%% WHERE  `ggid` = %d AND  `hostnum` = %d", ggid, hostnum);
return gen_up_sql(buf);
}
db_Gang_t& data()
{
return *((db_Gang_t*)(this));
}
};
class db_Soul_ext_t: public db_Soul_t, db_smart_up_t, boost::noncopyable
{
public:
db_Soul_ext_t()
{
REG_MEM(int32_t,state)
REG_MEM(int32_t,time)
REG_MEM(int32_t,gem_need)
REG_MEM(int32_t,level)
REG_MEM(int32_t,rare)
REG_MEM(int32_t,soul_id)
}
DEC_SET(int32_t,state)
DEC_SET(int32_t,time)
DEC_SET(int32_t,gem_need)
DEC_SET(int32_t,level)
DEC_SET(int32_t,rare)
DEC_SET(int32_t,soul_id)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Soul` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_Soul_t& data()
{
return *((db_Soul_t*)(this));
}
};
class db_LoveTask_ext_t: public db_LoveTask_t, db_smart_up_t, boost::noncopyable
{
public:
db_LoveTask_ext_t()
{
REG_MEM(int32_t,state)
REG_MEM(int32_t,pid)
REG_MEM(int32_t,step)
}
DEC_SET(int32_t,state)
DEC_SET(int32_t,pid)
DEC_SET(int32_t,step)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `LoveTask` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_LoveTask_t& data()
{
return *((db_LoveTask_t*)(this));
}
};
class db_ArenaInfo_ext_t: public db_ArenaInfo_t, db_smart_up_t, boost::noncopyable
{
public:
db_ArenaInfo_ext_t()
{
REG_MEM(int32_t,total_fp)
REG_MEM(int32_t,pid3)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid1)
REG_MEM(int32_t,level)
REG_MEM(int32_t,pid5)
REG_MEM(int32_t,pid2)
}
DEC_SET(int32_t,total_fp)
DEC_SET(int32_t,pid3)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid1)
DEC_SET(int32_t,level)
DEC_SET(int32_t,pid5)
DEC_SET(int32_t,pid2)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ArenaInfo` SET %%1%% WHERE  `hostnum` = %d AND  `uid` = %d", hostnum, uid);
return gen_up_sql(buf);
}
db_ArenaInfo_t& data()
{
return *((db_ArenaInfo_t*)(this));
}
};
class db_Wing_ext_t: public db_Wing_t, db_smart_up_t, boost::noncopyable
{
public:
db_Wing_ext_t()
{
REG_MEM(int32_t,lucky)
REG_MEM(int32_t,isweared)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,mgc)
REG_MEM(int32_t,hp)
REG_MEM(int32_t,dodge)
REG_MEM(int32_t,acc)
REG_MEM(int32_t,def)
REG_MEM(int32_t,res)
REG_MEM(int32_t,crit)
REG_MEM(int32_t,atk)
}
DEC_SET(int32_t,lucky)
DEC_SET(int32_t,isweared)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,mgc)
DEC_SET(int32_t,hp)
DEC_SET(int32_t,dodge)
DEC_SET(int32_t,acc)
DEC_SET(int32_t,def)
DEC_SET(int32_t,res)
DEC_SET(int32_t,crit)
DEC_SET(int32_t,atk)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Wing` SET %%1%% WHERE  `uid` = %d AND  `wid` = %d", uid, wid);
return gen_up_sql(buf);
}
db_Wing_t& data()
{
return *((db_Wing_t*)(this));
}
};
class db_ExpeditionTeam_ext_t: public db_ExpeditionTeam_t, db_smart_up_t, boost::noncopyable
{
public:
db_ExpeditionTeam_ext_t()
{
REG_MEM(int32_t,anger)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,pid1)
REG_MEM(int32_t,pid3)
REG_MEM(int32_t,pid5)
}
DEC_SET(int32_t,anger)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,pid1)
DEC_SET(int32_t,pid3)
DEC_SET(int32_t,pid5)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ExpeditionTeam` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_ExpeditionTeam_t& data()
{
return *((db_ExpeditionTeam_t*)(this));
}
};
class db_RuneInfo_ext_t: public db_RuneInfo_t, db_smart_up_t, boost::noncopyable
{
public:
db_RuneInfo_ext_t()
{
REG_MEM(int32_t,hunt_level)
REG_MEM(int32_t,page_num)
}
DEC_SET(int32_t,hunt_level)
DEC_SET(int32_t,page_num)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RuneInfo` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_RuneInfo_t& data()
{
return *((db_RuneInfo_t*)(this));
}
};
class db_CardEventShop_ext_t: public db_CardEventShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventShop_ext_t()
{
REG_MEM(int32_t,count)
REG_MEM(int32_t,shopindex)
REG_MEM(uint32_t,refresh_time)
}
DEC_SET(int32_t,count)
DEC_SET(int32_t,shopindex)
DEC_SET(uint32_t,refresh_time)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventShop` SET %%1%% WHERE  `uid` = %d AND  `shopid` = %d", uid, shopid);
return gen_up_sql(buf);
}
db_CardEventShop_t& data()
{
return *((db_CardEventShop_t*)(this));
}
};
class db_Compensate_ext_t: public db_Compensate_t, db_smart_up_t, boost::noncopyable
{
public:
db_Compensate_ext_t()
{
REG_MEM(int32_t,state)
REG_MEM(uint32_t,count)
REG_MEM(uint32_t,resid)
REG_MEM(uint32_t,id)
REG_MEM(uint32_t,givenstamp)
}
DEC_SET(int32_t,state)
DEC_SET(uint32_t,count)
DEC_SET(uint32_t,resid)
DEC_SET(uint32_t,id)
DEC_SET(uint32_t,givenstamp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Compensate` SET %%1%% WHERE  `id` = %u", id);
return gen_up_sql(buf);
}
db_Compensate_t& data()
{
return *((db_Compensate_t*)(this));
}
};
class db_PubMgr_ext_t: public db_PubMgr_t, db_smart_up_t, boost::noncopyable
{
public:
db_PubMgr_ext_t()
{
REG_MEM(int32_t,pub_sum)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,pub_4_first)
REG_MEM(int32_t,stepup_state)
REG_MEM(int32_t,event_state)
REG_MEM(int32_t,pub_3_first)
}
DEC_SET(int32_t,pub_sum)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,pub_4_first)
DEC_SET(int32_t,stepup_state)
DEC_SET(int32_t,event_state)
DEC_SET(int32_t,pub_3_first)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `PubMgr` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_PubMgr_t& data()
{
return *((db_PubMgr_t*)(this));
}
};
class db_FeedbackFlag_ext_t: public db_FeedbackFlag_t, db_smart_up_t, boost::noncopyable
{
public:
db_FeedbackFlag_ext_t()
{
REG_MEM(int32_t,id)
REG_MEM(int32_t,uid)
}
DEC_SET(int32_t,id)
DEC_SET(int32_t,uid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `FeedbackFlag` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_FeedbackFlag_t& data()
{
return *((db_FeedbackFlag_t*)(this));
}
};
class db_Reward_ext_t: public db_Reward_t, db_smart_up_t, boost::noncopyable
{
public:
db_Reward_ext_t()
{
REG_MEM(int32_t,adt_reward)
REG_MEM(uint32_t,given_power_stamp)
REG_MEM(int32_t,lv_40)
REG_MEM(int32_t,inv_reward4)
REG_MEM(int32_t,vip10)
REG_MEM(int32_t,vip13)
REG_MEM(int32_t,vip16)
REG_MEM(int32_t,acc_lg16)
REG_MEM(int32_t,con_lg6)
REG_MEM(int32_t,acc_lg18)
REG_MEM(int32_t,daily_draw_stamp)
REG_MEM(int32_t,vip7)
REG_MEM(ystring_t<30>,login_rewards)
REG_MEM(int32_t,acc_lg9)
REG_MEM(int32_t,acc_lg23)
REG_MEM(int32_t,conequip)
REG_MEM(int32_t,vip8)
REG_MEM(int32_t,acc_lg19)
REG_MEM(ystring_t<30>,luckybag_reward)
REG_MEM(uint32_t,mcard_event_state)
REG_MEM(int32_t,vip15)
REG_MEM(int32_t,wingactivityreward)
REG_MEM(int32_t,limit_melting)
REG_MEM(int32_t,vip12)
REG_MEM(int32_t,vip11)
REG_MEM(int32_t,acc_lg5)
REG_MEM(int32_t,lv_70)
REG_MEM(int32_t,acc_yb2)
REG_MEM(int32_t,next_online)
REG_MEM(int32_t,cumu_yb_exp)
REG_MEM(int32_t,daily_pay_stamp)
REG_MEM(int32_t,daily_consume_ap_stamp)
REG_MEM(int32_t,acc_lg6)
REG_MEM(int32_t,daily_talent)
REG_MEM(int32_t,daily_consume_ap)
REG_MEM(ystring_t<10>,daily_draw_reward)
REG_MEM(int32_t,acc_yb3)
REG_MEM(int32_t,acc_yb6)
REG_MEM(int32_t,acc_yb5)
REG_MEM(uint32_t,mcardtm)
REG_MEM(ystring_t<30>,limit_wing_reward)
REG_MEM(int32_t,acc_lg17)
REG_MEM(int32_t,double_expedition)
REG_MEM(int32_t,daily_melting)
REG_MEM(int32_t,lv_65)
REG_MEM(int32_t,inv_reward1)
REG_MEM(int32_t,acc_lg20)
REG_MEM(int32_t,growing_package_status)
REG_MEM(int32_t,acc_lg3)
REG_MEM(ystring_t<30>,limit_draw_ten_reward)
REG_MEM(uint32_t,first_login)
REG_MEM(int32_t,vip4)
REG_MEM(int32_t,online)
REG_MEM(uint32_t,mcardbuytm)
REG_MEM(int32_t,limit_single_stamp)
REG_MEM(int32_t,cumulevel)
REG_MEM(int32_t,con_lg3)
REG_MEM(int32_t,inv_reward3)
REG_MEM(int32_t,con_lg4)
REG_MEM(int32_t,acc_yb4)
REG_MEM(int32_t,vip5)
REG_MEM(uint32_t,adt_stamp)
REG_MEM(int32_t,con_lg5)
REG_MEM(int32_t,can_get_first)
REG_MEM(int32_t,vip3)
REG_MEM(int32_t,lv_35)
REG_MEM(int32_t,acc_lg1)
REG_MEM(int32_t,lv_55)
REG_MEM(ystring_t<10>,limit_melting_reward)
REG_MEM(int32_t,daily_draw)
REG_MEM(int32_t,vip17)
REG_MEM(ystring_t<30>,growing_reward)
REG_MEM(int32_t,login_days)
REG_MEM(int32_t,cumureward)
REG_MEM(int32_t,acc_lg22)
REG_MEM(int32_t,vip1)
REG_MEM(int32_t,vip6)
REG_MEM(int32_t,acc_yb1)
REG_MEM(int32_t,acc_lg7)
REG_MEM(int32_t,acc_yb7)
REG_MEM(int32_t,lv_60)
REG_MEM(int32_t,vip18)
REG_MEM(int32_t,acc_lg14)
REG_MEM(int32_t,conhero)
REG_MEM(uint32_t,vip_package_stamp)
REG_MEM(int32_t,wingactivity)
REG_MEM(int32_t,daily_pay_reward)
REG_MEM(int32_t,pvelose_times)
REG_MEM(int32_t,lv_30)
REG_MEM(int32_t,lv_20)
REG_MEM(int32_t,limit_draw_ten)
REG_MEM(ystring_t<10>,daily_consume_ap_reward)
REG_MEM(int32_t,cumu_yb_reward)
REG_MEM(int32_t,acc_lg12)
REG_MEM(int32_t,con_lg7)
REG_MEM(int32_t,conlglevel)
REG_MEM(int32_t,fpreward)
REG_MEM(uint32_t,mcard_event_buy_count)
REG_MEM(int32_t,mcardn)
REG_MEM(int32_t,lv_50)
REG_MEM(int32_t,lv_45)
REG_MEM(ystring_t<10>,limit_talent_reward)
REG_MEM(int32_t,limit_consume_power_stamp)
REG_MEM(int32_t,limit_recharge_money)
REG_MEM(int32_t,daily_pay)
REG_MEM(int32_t,acc_lg4)
REG_MEM(int32_t,inviter)
REG_MEM(int32_t,inv_reward2)
REG_MEM(int32_t,vip9)
REG_MEM(int32_t,invcode)
REG_MEM(uint32_t,last_login)
REG_MEM(int32_t,acc_lg15)
REG_MEM(int32_t,acclgexp)
REG_MEM(int32_t,week_reward)
REG_MEM(int32_t,limit_talent)
REG_MEM(int32_t,daily_talent_stamp)
REG_MEM(ystring_t<10>,daily_talent_reward)
REG_MEM(int32_t,daily_melting_stamp)
REG_MEM(int32_t,con_lg2)
REG_MEM(ystring_t<10>,daily_melting_reward)
REG_MEM(ystring_t<10>,limit_single_reward)
REG_MEM(int32_t,limit_single_recharge)
REG_MEM(ystring_t<10>,limit_recharge_reward)
REG_MEM(int32_t,lv_25)
REG_MEM(ystring_t<30>,limit_consume_power_reward)
REG_MEM(int32_t,limit_consume_power)
REG_MEM(int32_t,yblevel)
REG_MEM(int32_t,is_consume_hundred)
REG_MEM(int32_t,total_login_days)
REG_MEM(int32_t,con_lg1)
REG_MEM(int32_t,acc_lg24)
REG_MEM(int32_t,acc_lg21)
REG_MEM(int32_t,acc_lg13)
REG_MEM(int32_t,acc_lg11)
REG_MEM(int32_t,acc_lg10)
REG_MEM(int32_t,first_yb)
REG_MEM(int32_t,acc_lg8)
REG_MEM(int32_t,vip2)
REG_MEM(int32_t,acc_lg2)
REG_MEM(int32_t,vip14)
REG_MEM(int32_t,acclglevel)
REG_MEM(uint32_t,given_rank_stamp)
}
DEC_SET(int32_t,adt_reward)
DEC_SET(uint32_t,given_power_stamp)
DEC_SET(int32_t,lv_40)
DEC_SET(int32_t,inv_reward4)
DEC_SET(int32_t,vip10)
DEC_SET(int32_t,vip13)
DEC_SET(int32_t,vip16)
DEC_SET(int32_t,acc_lg16)
DEC_SET(int32_t,con_lg6)
DEC_SET(int32_t,acc_lg18)
DEC_SET(int32_t,daily_draw_stamp)
DEC_SET(int32_t,vip7)
DEC_SET(ystring_t<30>,login_rewards)
DEC_SET(int32_t,acc_lg9)
DEC_SET(int32_t,acc_lg23)
DEC_SET(int32_t,conequip)
DEC_SET(int32_t,vip8)
DEC_SET(int32_t,acc_lg19)
DEC_SET(ystring_t<30>,luckybag_reward)
DEC_SET(uint32_t,mcard_event_state)
DEC_SET(int32_t,vip15)
DEC_SET(int32_t,wingactivityreward)
DEC_SET(int32_t,limit_melting)
DEC_SET(int32_t,vip12)
DEC_SET(int32_t,vip11)
DEC_SET(int32_t,acc_lg5)
DEC_SET(int32_t,lv_70)
DEC_SET(int32_t,acc_yb2)
DEC_SET(int32_t,next_online)
DEC_SET(int32_t,cumu_yb_exp)
DEC_SET(int32_t,daily_pay_stamp)
DEC_SET(int32_t,daily_consume_ap_stamp)
DEC_SET(int32_t,acc_lg6)
DEC_SET(int32_t,daily_talent)
DEC_SET(int32_t,daily_consume_ap)
DEC_SET(ystring_t<10>,daily_draw_reward)
DEC_SET(int32_t,acc_yb3)
DEC_SET(int32_t,acc_yb6)
DEC_SET(int32_t,acc_yb5)
DEC_SET(uint32_t,mcardtm)
DEC_SET(ystring_t<30>,limit_wing_reward)
DEC_SET(int32_t,acc_lg17)
DEC_SET(int32_t,double_expedition)
DEC_SET(int32_t,daily_melting)
DEC_SET(int32_t,lv_65)
DEC_SET(int32_t,inv_reward1)
DEC_SET(int32_t,acc_lg20)
DEC_SET(int32_t,growing_package_status)
DEC_SET(int32_t,acc_lg3)
DEC_SET(ystring_t<30>,limit_draw_ten_reward)
DEC_SET(uint32_t,first_login)
DEC_SET(int32_t,vip4)
DEC_SET(int32_t,online)
DEC_SET(uint32_t,mcardbuytm)
DEC_SET(int32_t,limit_single_stamp)
DEC_SET(int32_t,cumulevel)
DEC_SET(int32_t,con_lg3)
DEC_SET(int32_t,inv_reward3)
DEC_SET(int32_t,con_lg4)
DEC_SET(int32_t,acc_yb4)
DEC_SET(int32_t,vip5)
DEC_SET(uint32_t,adt_stamp)
DEC_SET(int32_t,con_lg5)
DEC_SET(int32_t,can_get_first)
DEC_SET(int32_t,vip3)
DEC_SET(int32_t,lv_35)
DEC_SET(int32_t,acc_lg1)
DEC_SET(int32_t,lv_55)
DEC_SET(ystring_t<10>,limit_melting_reward)
DEC_SET(int32_t,daily_draw)
DEC_SET(int32_t,vip17)
DEC_SET(ystring_t<30>,growing_reward)
DEC_SET(int32_t,login_days)
DEC_SET(int32_t,cumureward)
DEC_SET(int32_t,acc_lg22)
DEC_SET(int32_t,vip1)
DEC_SET(int32_t,vip6)
DEC_SET(int32_t,acc_yb1)
DEC_SET(int32_t,acc_lg7)
DEC_SET(int32_t,acc_yb7)
DEC_SET(int32_t,lv_60)
DEC_SET(int32_t,vip18)
DEC_SET(int32_t,acc_lg14)
DEC_SET(int32_t,conhero)
DEC_SET(uint32_t,vip_package_stamp)
DEC_SET(int32_t,wingactivity)
DEC_SET(int32_t,daily_pay_reward)
DEC_SET(int32_t,pvelose_times)
DEC_SET(int32_t,lv_30)
DEC_SET(int32_t,lv_20)
DEC_SET(int32_t,limit_draw_ten)
DEC_SET(ystring_t<10>,daily_consume_ap_reward)
DEC_SET(int32_t,cumu_yb_reward)
DEC_SET(int32_t,acc_lg12)
DEC_SET(int32_t,con_lg7)
DEC_SET(int32_t,conlglevel)
DEC_SET(int32_t,fpreward)
DEC_SET(uint32_t,mcard_event_buy_count)
DEC_SET(int32_t,mcardn)
DEC_SET(int32_t,lv_50)
DEC_SET(int32_t,lv_45)
DEC_SET(ystring_t<10>,limit_talent_reward)
DEC_SET(int32_t,limit_consume_power_stamp)
DEC_SET(int32_t,limit_recharge_money)
DEC_SET(int32_t,daily_pay)
DEC_SET(int32_t,acc_lg4)
DEC_SET(int32_t,inviter)
DEC_SET(int32_t,inv_reward2)
DEC_SET(int32_t,vip9)
DEC_SET(int32_t,invcode)
DEC_SET(uint32_t,last_login)
DEC_SET(int32_t,acc_lg15)
DEC_SET(int32_t,acclgexp)
DEC_SET(int32_t,week_reward)
DEC_SET(int32_t,limit_talent)
DEC_SET(int32_t,daily_talent_stamp)
DEC_SET(ystring_t<10>,daily_talent_reward)
DEC_SET(int32_t,daily_melting_stamp)
DEC_SET(int32_t,con_lg2)
DEC_SET(ystring_t<10>,daily_melting_reward)
DEC_SET(ystring_t<10>,limit_single_reward)
DEC_SET(int32_t,limit_single_recharge)
DEC_SET(ystring_t<10>,limit_recharge_reward)
DEC_SET(int32_t,lv_25)
DEC_SET(ystring_t<30>,limit_consume_power_reward)
DEC_SET(int32_t,limit_consume_power)
DEC_SET(int32_t,yblevel)
DEC_SET(int32_t,is_consume_hundred)
DEC_SET(int32_t,total_login_days)
DEC_SET(int32_t,con_lg1)
DEC_SET(int32_t,acc_lg24)
DEC_SET(int32_t,acc_lg21)
DEC_SET(int32_t,acc_lg13)
DEC_SET(int32_t,acc_lg11)
DEC_SET(int32_t,acc_lg10)
DEC_SET(int32_t,first_yb)
DEC_SET(int32_t,acc_lg8)
DEC_SET(int32_t,vip2)
DEC_SET(int32_t,acc_lg2)
DEC_SET(int32_t,vip14)
DEC_SET(int32_t,acclglevel)
DEC_SET(uint32_t,given_rank_stamp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Reward` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_Reward_t& data()
{
return *((db_Reward_t*)(this));
}
};
class db_UserInfo_ext_t: public db_UserInfo_t, db_smart_up_t, boost::noncopyable
{
public:
db_UserInfo_ext_t()
{
REG_MEM(int32_t,spshopbuy)
REG_MEM(int32_t,useFlower)
REG_MEM(int32_t,nextquestid)
REG_MEM(int32_t,spshoprefresh)
REG_MEM(int32_t,last_power_stamp)
REG_MEM(int32_t,sceneid)
REG_MEM(int32_t,eliteid)
REG_MEM(int32_t,lovelevel)
REG_MEM(int32_t,draw_ten_diamond)
REG_MEM(uint32_t,totaltime)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,naviClickNum2)
REG_MEM(int32_t,potential_5)
REG_MEM(int32_t,draw_num)
REG_MEM(int32_t,energy)
REG_MEM(int32_t,headid)
REG_MEM(int32_t,zodiacid)
REG_MEM(int32_t,flush1times)
REG_MEM(int32_t,flush2times)
REG_MEM(uint32_t,npcshoptime3)
REG_MEM(int32_t,unhonor)
REG_MEM(int32_t,flush2round)
REG_MEM(int32_t,flush1round)
REG_MEM(int32_t,kanban)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,hhresid)
REG_MEM(int32_t,sign_cost)
REG_MEM(int32_t,fpoint)
REG_MEM(uint32_t,chronicle_sum)
REG_MEM(int32_t,battlexp)
REG_MEM(int32_t,questid)
REG_MEM(int32_t,utype)
REG_MEM(int32_t,rank)
REG_MEM(uint32_t,createtime)
REG_MEM(int32_t,hm_maxid)
REG_MEM(uint32_t,sign_daily)
REG_MEM(uint32_t,useFlowerStamp)
REG_MEM(uint32_t,resetFlowerStamp)
REG_MEM(ystring_t<30>,draw_reward)
REG_MEM(int32_t,caveid)
REG_MEM(int32_t,npcshopbuy)
REG_MEM(int32_t,vipexp)
REG_MEM(int32_t,payyb)
REG_MEM(int32_t,limitround)
REG_MEM(int32_t,boxe)
REG_MEM(uint32_t,spshoptime)
REG_MEM(int32_t,sign_month)
REG_MEM(int32_t,quality)
REG_MEM(int32_t,isnew)
REG_MEM(int32_t,twoprecord)
REG_MEM(int32_t,naviClickNum1)
REG_MEM(int32_t,helphero)
REG_MEM(int32_t,soul)
REG_MEM(int32_t,power)
REG_MEM(uint32_t,npcshoptime1)
REG_MEM(int32_t,potential_2)
REG_MEM(ystring_t<30>,round_stars_reward)
REG_MEM(int32_t,elite_roundid)
REG_MEM(uint32_t,npcshop)
REG_MEM(int32_t,model)
REG_MEM(ystring_t<1024>,elite_round_times)
REG_MEM(int32_t,expeditioncoin)
REG_MEM(int32_t,meritorious)
REG_MEM(int32_t,bagn)
REG_MEM(int32_t,fp)
REG_MEM(int32_t,honor)
REG_MEM(uint32_t,zodiacstamp)
REG_MEM(int32_t,exp)
REG_MEM(int32_t,flush2first)
REG_MEM(int32_t,numFlower)
REG_MEM(uint64_t,func)
REG_MEM(int32_t,firstpay)
REG_MEM(int32_t,boxn)
REG_MEM(int32_t,isnewlv)
REG_MEM(ystring_t<1024>,roundstars)
REG_MEM(int32_t,potential_3)
REG_MEM(int32_t,frd)
REG_MEM(int32_t,viplevel)
REG_MEM(int32_t,m_rank)
REG_MEM(ystring_t<1024>,elite_reset_times)
REG_MEM(int32_t,titlelv)
REG_MEM(uint32_t,lastquit)
REG_MEM(int32_t,treasure)
REG_MEM(int32_t,kanban_type)
REG_MEM(int32_t,roundid)
REG_MEM(int32_t,runechip)
REG_MEM(int32_t,specicalshop)
REG_MEM(int32_t,potential_4)
REG_MEM(int32_t,potential_1)
REG_MEM(uint32_t,npcshoptime2)
REG_MEM(int32_t,flush3times)
REG_MEM(int32_t,lovevalue)
REG_MEM(int32_t,flush3round)
REG_MEM(int32_t,npcshoprefresh)
REG_MEM(int32_t,freeyb)
REG_MEM(int32_t,gold)
}
DEC_SET(int32_t,spshopbuy)
DEC_SET(int32_t,useFlower)
DEC_SET(int32_t,nextquestid)
DEC_SET(int32_t,spshoprefresh)
DEC_SET(int32_t,last_power_stamp)
DEC_SET(int32_t,sceneid)
DEC_SET(int32_t,eliteid)
DEC_SET(int32_t,lovelevel)
DEC_SET(int32_t,draw_ten_diamond)
DEC_SET(uint32_t,totaltime)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,naviClickNum2)
DEC_SET(int32_t,potential_5)
DEC_SET(int32_t,draw_num)
DEC_SET(int32_t,energy)
DEC_SET(int32_t,headid)
DEC_SET(int32_t,zodiacid)
DEC_SET(int32_t,flush1times)
DEC_SET(int32_t,flush2times)
DEC_SET(uint32_t,npcshoptime3)
DEC_SET(int32_t,unhonor)
DEC_SET(int32_t,flush2round)
DEC_SET(int32_t,flush1round)
DEC_SET(int32_t,kanban)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,hhresid)
DEC_SET(int32_t,sign_cost)
DEC_SET(int32_t,fpoint)
DEC_SET(uint32_t,chronicle_sum)
DEC_SET(int32_t,battlexp)
DEC_SET(int32_t,questid)
DEC_SET(int32_t,utype)
DEC_SET(int32_t,rank)
DEC_SET(uint32_t,createtime)
DEC_SET(int32_t,hm_maxid)
DEC_SET(uint32_t,sign_daily)
DEC_SET(uint32_t,useFlowerStamp)
DEC_SET(uint32_t,resetFlowerStamp)
DEC_SET(ystring_t<30>,draw_reward)
DEC_SET(int32_t,caveid)
DEC_SET(int32_t,npcshopbuy)
DEC_SET(int32_t,vipexp)
DEC_SET(int32_t,payyb)
DEC_SET(int32_t,limitround)
DEC_SET(int32_t,boxe)
DEC_SET(uint32_t,spshoptime)
DEC_SET(int32_t,sign_month)
DEC_SET(int32_t,quality)
DEC_SET(int32_t,isnew)
DEC_SET(int32_t,twoprecord)
DEC_SET(int32_t,naviClickNum1)
DEC_SET(int32_t,helphero)
DEC_SET(int32_t,soul)
DEC_SET(int32_t,power)
DEC_SET(uint32_t,npcshoptime1)
DEC_SET(int32_t,potential_2)
DEC_SET(ystring_t<30>,round_stars_reward)
DEC_SET(int32_t,elite_roundid)
DEC_SET(uint32_t,npcshop)
DEC_SET(int32_t,model)
DEC_SET(ystring_t<1024>,elite_round_times)
DEC_SET(int32_t,expeditioncoin)
DEC_SET(int32_t,meritorious)
DEC_SET(int32_t,bagn)
DEC_SET(int32_t,fp)
DEC_SET(int32_t,honor)
DEC_SET(uint32_t,zodiacstamp)
DEC_SET(int32_t,exp)
DEC_SET(int32_t,flush2first)
DEC_SET(int32_t,numFlower)
DEC_SET(uint64_t,func)
DEC_SET(int32_t,firstpay)
DEC_SET(int32_t,boxn)
DEC_SET(int32_t,isnewlv)
DEC_SET(ystring_t<1024>,roundstars)
DEC_SET(int32_t,potential_3)
DEC_SET(int32_t,frd)
DEC_SET(int32_t,viplevel)
DEC_SET(int32_t,m_rank)
DEC_SET(ystring_t<1024>,elite_reset_times)
DEC_SET(int32_t,titlelv)
DEC_SET(uint32_t,lastquit)
DEC_SET(int32_t,treasure)
DEC_SET(int32_t,kanban_type)
DEC_SET(int32_t,roundid)
DEC_SET(int32_t,runechip)
DEC_SET(int32_t,specicalshop)
DEC_SET(int32_t,potential_4)
DEC_SET(int32_t,potential_1)
DEC_SET(uint32_t,npcshoptime2)
DEC_SET(int32_t,flush3times)
DEC_SET(int32_t,lovevalue)
DEC_SET(int32_t,flush3round)
DEC_SET(int32_t,npcshoprefresh)
DEC_SET(int32_t,freeyb)
DEC_SET(int32_t,gold)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `UserInfo` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_UserInfo_t& data()
{
return *((db_UserInfo_t*)(this));
}
};
class db_Partner_ext_t: public db_Partner_t, db_smart_up_t, boost::noncopyable
{
public:
db_Partner_ext_t()
{
REG_MEM(int32_t,potential_4)
REG_MEM(int32_t,naviClickNum1)
REG_MEM(int32_t,potential_5)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,potential_2)
REG_MEM(int32_t,naviClickNum2)
REG_MEM(int32_t,potential_3)
REG_MEM(int32_t,lovevalue)
REG_MEM(int32_t,potential_1)
REG_MEM(int32_t,lovelevel)
REG_MEM(int32_t,exp)
REG_MEM(int32_t,quality)
}
DEC_SET(int32_t,potential_4)
DEC_SET(int32_t,naviClickNum1)
DEC_SET(int32_t,potential_5)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,potential_2)
DEC_SET(int32_t,naviClickNum2)
DEC_SET(int32_t,potential_3)
DEC_SET(int32_t,lovevalue)
DEC_SET(int32_t,potential_1)
DEC_SET(int32_t,lovelevel)
DEC_SET(int32_t,exp)
DEC_SET(int32_t,quality)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Partner` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d", uid, pid);
return gen_up_sql(buf);
}
db_Partner_t& data()
{
return *((db_Partner_t*)(this));
}
};
class db_UnPrestigeShop_ext_t: public db_UnPrestigeShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_UnPrestigeShop_ext_t()
{
REG_MEM(uint32_t,buystamp)
REG_MEM(int32_t,count)
}
DEC_SET(uint32_t,buystamp)
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `UnPrestigeShop` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_UnPrestigeShop_t& data()
{
return *((db_UnPrestigeShop_t*)(this));
}
};
class db_Report_ext_t: public db_Report_t, db_smart_up_t, boost::noncopyable
{
public:
db_Report_ext_t()
{
REG_MEM(int32_t,id)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,reportuid)
}
DEC_SET(int32_t,id)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,reportuid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Report` SET %%1%% WHERE  `uid` = %d AND  `reportuid` = %d", uid, reportuid);
return gen_up_sql(buf);
}
db_Report_t& data()
{
return *((db_Report_t*)(this));
}
};
class db_GMail_ext_t: public db_GMail_t, db_smart_up_t, boost::noncopyable
{
public:
db_GMail_ext_t()
{
REG_MEM(int32_t,count1)
REG_MEM(int32_t,flag)
REG_MEM(int32_t,validtime)
REG_MEM(int32_t,opened)
REG_MEM(ystring_t<256>,info)
REG_MEM(int32_t,count5)
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,resid)
REG_MEM(ystring_t<64>,sender)
REG_MEM(int32_t,item5)
REG_MEM(int32_t,count3)
REG_MEM(int32_t,count2)
REG_MEM(int32_t,rewarded)
REG_MEM(ystring_t<64>,title)
REG_MEM(int32_t,count4)
REG_MEM(int32_t,item4)
REG_MEM(int32_t,item3)
REG_MEM(int32_t,item2)
REG_MEM(int32_t,item1)
}
DEC_SET(int32_t,count1)
DEC_SET(int32_t,flag)
DEC_SET(int32_t,validtime)
DEC_SET(int32_t,opened)
DEC_SET(ystring_t<256>,info)
DEC_SET(int32_t,count5)
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,resid)
DEC_SET(ystring_t<64>,sender)
DEC_SET(int32_t,item5)
DEC_SET(int32_t,count3)
DEC_SET(int32_t,count2)
DEC_SET(int32_t,rewarded)
DEC_SET(ystring_t<64>,title)
DEC_SET(int32_t,count4)
DEC_SET(int32_t,item4)
DEC_SET(int32_t,item3)
DEC_SET(int32_t,item2)
DEC_SET(int32_t,item1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GMail` SET %%1%% WHERE  `uid` = %d AND  `mid` = %d", uid, mid);
return gen_up_sql(buf);
}
db_GMail_t& data()
{
return *((db_GMail_t*)(this));
}
};
class db_Item_ext_t: public db_Item_t, db_smart_up_t, boost::noncopyable
{
public:
db_Item_ext_t()
{
REG_MEM(int32_t,count)
}
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Item` SET %%1%% WHERE  `uid` = %d AND  `itid` = %d", uid, itid);
return gen_up_sql(buf);
}
db_Item_t& data()
{
return *((db_Item_t*)(this));
}
};
class db_GangBossDamage_ext_t: public db_GangBossDamage_t, db_smart_up_t, boost::noncopyable
{
public:
db_GangBossDamage_ext_t()
{
REG_MEM(ystring_t<30>,nickname)
REG_MEM(int32_t,lv)
REG_MEM(int32_t,old_scene)
REG_MEM(int32_t,last_batt_time)
REG_MEM(int32_t,ggid)
REG_MEM(int32_t,in_scene)
REG_MEM(int32_t,damage)
}
DEC_SET(ystring_t<30>,nickname)
DEC_SET(int32_t,lv)
DEC_SET(int32_t,old_scene)
DEC_SET(int32_t,last_batt_time)
DEC_SET(int32_t,ggid)
DEC_SET(int32_t,in_scene)
DEC_SET(int32_t,damage)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GangBossDamage` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_GangBossDamage_t& data()
{
return *((db_GangBossDamage_t*)(this));
}
};
class db_Equip_ext_t: public db_Equip_t, db_smart_up_t, boost::noncopyable
{
public:
db_Equip_ext_t()
{
REG_MEM(int32_t,strenlevel)
REG_MEM(int32_t,pid)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,gresid2)
REG_MEM(int32_t,gresid4)
REG_MEM(int32_t,isweared)
REG_MEM(int32_t,gresid5)
REG_MEM(int32_t,gresid3)
REG_MEM(int32_t,gresid1)
}
DEC_SET(int32_t,strenlevel)
DEC_SET(int32_t,pid)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,gresid2)
DEC_SET(int32_t,gresid4)
DEC_SET(int32_t,isweared)
DEC_SET(int32_t,gresid5)
DEC_SET(int32_t,gresid3)
DEC_SET(int32_t,gresid1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Equip` SET %%1%% WHERE  `uid` = %d AND  `eid` = %d", uid, eid);
return gen_up_sql(buf);
}
db_Equip_t& data()
{
return *((db_Equip_t*)(this));
}
};
class db_GangBoss_ext_t: public db_GangBoss_t, db_smart_up_t, boost::noncopyable
{
public:
db_GangBoss_ext_t()
{
REG_MEM(int32_t,m_join_count)
REG_MEM(int32_t,m_prepare)
REG_MEM(int32_t,is_event)
REG_MEM(int32_t,m_resid)
REG_MEM(int32_t,top_cut)
REG_MEM(int32_t,m_hp)
REG_MEM(int32_t,m_end)
REG_MEM(int32_t,m_spawned)
REG_MEM(int32_t,m_grade)
REG_MEM(string,top)
REG_MEM(int32_t,m_max_hp)
REG_MEM(int32_t,m_spawne_time)
REG_MEM(int32_t,m_start)
REG_MEM(int32_t,reward_send)
REG_MEM(int32_t,m_cur_count)
REG_MEM(int32_t,is_join_reward)
REG_MEM(int32_t,m_damage)
}
DEC_SET(int32_t,m_join_count)
DEC_SET(int32_t,m_prepare)
DEC_SET(int32_t,is_event)
DEC_SET(int32_t,m_resid)
DEC_SET(int32_t,top_cut)
DEC_SET(int32_t,m_hp)
DEC_SET(int32_t,m_end)
DEC_SET(int32_t,m_spawned)
DEC_SET(int32_t,m_grade)
DEC_SET(string,top)
DEC_SET(int32_t,m_max_hp)
DEC_SET(int32_t,m_spawne_time)
DEC_SET(int32_t,m_start)
DEC_SET(int32_t,reward_send)
DEC_SET(int32_t,m_cur_count)
DEC_SET(int32_t,is_join_reward)
DEC_SET(int32_t,m_damage)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GangBoss` SET %%1%% WHERE  `ggid` = %d", ggid);
return gen_up_sql(buf);
}
db_GangBoss_t& data()
{
return *((db_GangBoss_t*)(this));
}
};
class db_PartnerChip_ext_t: public db_PartnerChip_t, db_smart_up_t, boost::noncopyable
{
public:
db_PartnerChip_ext_t()
{
REG_MEM(int32_t,count)
}
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `PartnerChip` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_PartnerChip_t& data()
{
return *((db_PartnerChip_t*)(this));
}
};
class db_TreasureCoopertive_ext_t: public db_TreasureCoopertive_t, db_smart_up_t, boost::noncopyable
{
public:
db_TreasureCoopertive_ext_t()
{
REG_MEM(int32_t,profit)
REG_MEM(int32_t,n_help)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,slot_pos)
REG_MEM(int32_t,last_stamp)
REG_MEM(int32_t,last_round)
REG_MEM(int32_t,debian_secs)
}
DEC_SET(int32_t,profit)
DEC_SET(int32_t,n_help)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,slot_pos)
DEC_SET(int32_t,last_stamp)
DEC_SET(int32_t,last_round)
DEC_SET(int32_t,debian_secs)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `TreasureCoopertive` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_TreasureCoopertive_t& data()
{
return *((db_TreasureCoopertive_t*)(this));
}
};
class db_ChipSmash_ext_t: public db_ChipSmash_t, db_smart_up_t, boost::noncopyable
{
public:
db_ChipSmash_ext_t()
{
REG_MEM(uint32_t,buystamp)
REG_MEM(int32_t,count)
}
DEC_SET(uint32_t,buystamp)
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ChipSmash` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_ChipSmash_t& data()
{
return *((db_ChipSmash_t*)(this));
}
};
class db_LimitRound_ext_t: public db_LimitRound_t, db_smart_up_t, boost::noncopyable
{
public:
db_LimitRound_ext_t()
{
REG_MEM(int32_t,reset_times)
REG_MEM(int32_t,lasttime)
}
DEC_SET(int32_t,reset_times)
DEC_SET(int32_t,lasttime)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `LimitRound` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_LimitRound_t& data()
{
return *((db_LimitRound_t*)(this));
}
};
class db_PrestigeShop_ext_t: public db_PrestigeShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_PrestigeShop_ext_t()
{
REG_MEM(uint32_t,buystamp)
REG_MEM(int32_t,count)
}
DEC_SET(uint32_t,buystamp)
DEC_SET(int32_t,count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `PrestigeShop` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_PrestigeShop_t& data()
{
return *((db_PrestigeShop_t*)(this));
}
};
class db_InventoryShop_ext_t: public db_InventoryShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_InventoryShop_ext_t()
{
REG_MEM(int32_t,count)
REG_MEM(uint32_t,buystamp)
}
DEC_SET(int32_t,count)
DEC_SET(uint32_t,buystamp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `InventoryShop` SET %%1%% WHERE  `uid` = %d AND  `shopid` = %d", uid, shopid);
return gen_up_sql(buf);
}
db_InventoryShop_t& data()
{
return *((db_InventoryShop_t*)(this));
}
};
class db_GemPage_ext_t: public db_GemPage_t, db_smart_up_t, boost::noncopyable
{
public:
db_GemPage_ext_t()
{
REG_MEM(int32_t,resid)
}
DEC_SET(int32_t,resid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GemPage` SET %%1%% WHERE  `uid` = %d AND  `pageid` = %d AND  `gemtype` = %d AND  `slotid` = %d", uid, pageid, gemtype, slotid);
return gen_up_sql(buf);
}
db_GemPage_t& data()
{
return *((db_GemPage_t*)(this));
}
};
class db_Chronicle_ext_t: public db_Chronicle_t, db_smart_up_t, boost::noncopyable
{
public:
db_Chronicle_ext_t()
{
REG_MEM(int32_t,state)
REG_MEM(int32_t,step)
REG_MEM(int32_t,chronicle_month)
}
DEC_SET(int32_t,state)
DEC_SET(int32_t,step)
DEC_SET(int32_t,chronicle_month)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Chronicle` SET %%1%% WHERE  `uid` = %d AND  `chronicle_day` = %d", uid, chronicle_day);
return gen_up_sql(buf);
}
db_Chronicle_t& data()
{
return *((db_Chronicle_t*)(this));
}
};
class db_GuildBattlePartner_ext_t: public db_GuildBattlePartner_t, db_smart_up_t, boost::noncopyable
{
public:
db_GuildBattlePartner_ext_t()
{
REG_MEM(float,hp)
}
DEC_SET(float,hp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GuildBattlePartner` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d", uid, pid);
return gen_up_sql(buf);
}
db_GuildBattlePartner_t& data()
{
return *((db_GuildBattlePartner_t*)(this));
}
};
class db_GuildBattleDefenceInfo_ext_t: public db_GuildBattleDefenceInfo_t, db_smart_up_t, boost::noncopyable
{
public:
db_GuildBattleDefenceInfo_ext_t()
{
REG_MEM(string,view_data)
REG_MEM(int32_t,pid5)
REG_MEM(float,hp2)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,pid3)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,pid4)
REG_MEM(float,hp5)
REG_MEM(int32_t,pid1)
REG_MEM(float,hp3)
REG_MEM(float,hp4)
REG_MEM(float,hp1)
}
DEC_SET(string,view_data)
DEC_SET(int32_t,pid5)
DEC_SET(float,hp2)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,pid3)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,pid4)
DEC_SET(float,hp5)
DEC_SET(int32_t,pid1)
DEC_SET(float,hp3)
DEC_SET(float,hp4)
DEC_SET(float,hp1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GuildBattleDefenceInfo` SET %%1%% WHERE  `ggid` = %d AND  `building_id` = %d AND  `building_pos` = %d", ggid, building_id, building_pos);
return gen_up_sql(buf);
}
db_GuildBattleDefenceInfo_t& data()
{
return *((db_GuildBattleDefenceInfo_t*)(this));
}
};
class db_SoulUser_ext_t: public db_SoulUser_t, db_smart_up_t, boost::noncopyable
{
public:
db_SoulUser_ext_t()
{
REG_MEM(int32_t,hostnum)
REG_MEM(ystring_t<30>,ctime)
REG_MEM(int32_t,soullevel)
REG_MEM(int32_t,soulid)
REG_MEM(int32_t,soulmoney)
}
DEC_SET(int32_t,hostnum)
DEC_SET(ystring_t<30>,ctime)
DEC_SET(int32_t,soullevel)
DEC_SET(int32_t,soulid)
DEC_SET(int32_t,soulmoney)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `SoulUser` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_SoulUser_t& data()
{
return *((db_SoulUser_t*)(this));
}
};
class db_CardComment_ext_t: public db_CardComment_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardComment_ext_t()
{
REG_MEM(int32_t,praisenum)
REG_MEM(int32_t,equiprank)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,id)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,uid)
REG_MEM(string,name)
REG_MEM(int32_t,stamp)
REG_MEM(int32_t,viplevel)
REG_MEM(string,comment)
REG_MEM(int32_t,isshow)
}
DEC_SET(int32_t,praisenum)
DEC_SET(int32_t,equiprank)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,id)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,uid)
DEC_SET(string,name)
DEC_SET(int32_t,stamp)
DEC_SET(int32_t,viplevel)
DEC_SET(string,comment)
DEC_SET(int32_t,isshow)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardComment` SET %%1%% WHERE  `id` = %d", id);
return gen_up_sql(buf);
}
db_CardComment_t& data()
{
return *((db_CardComment_t*)(this));
}
};
class db_RankMatch_ext_t: public db_RankMatch_t, db_smart_up_t, boost::noncopyable
{
public:
db_RankMatch_ext_t()
{
REG_MEM(int32_t,stamp)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,req_times)
REG_MEM(string,view_data)
REG_MEM(int32_t,rank_type)
}
DEC_SET(int32_t,stamp)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,req_times)
DEC_SET(string,view_data)
DEC_SET(int32_t,rank_type)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RankMatch` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_RankMatch_t& data()
{
return *((db_RankMatch_t*)(this));
}
};
class db_CardEventUser_ext_t: public db_CardEventUser_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventUser_ext_t()
{
REG_MEM(int32_t,score)
REG_MEM(int32_t,goal_level)
REG_MEM(int32_t,round_status)
REG_MEM(int32_t,next_count)
REG_MEM(int32_t,open_level)
REG_MEM(int32_t,open_times)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,season)
REG_MEM(int32_t,round)
REG_MEM(float,hp5)
REG_MEM(float,hp4)
REG_MEM(int32_t,anger)
REG_MEM(float,hp3)
REG_MEM(int32_t,coin)
REG_MEM(int32_t,first_enter_time)
REG_MEM(float,hp2)
REG_MEM(int32_t,pid3)
REG_MEM(string,enemy_view_data)
REG_MEM(int32_t,pid5)
REG_MEM(int32_t,pid1)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,round_max)
REG_MEM(int32_t,difficult)
REG_MEM(int32_t,reset_time)
REG_MEM(float,hp1)
}
DEC_SET(int32_t,score)
DEC_SET(int32_t,goal_level)
DEC_SET(int32_t,round_status)
DEC_SET(int32_t,next_count)
DEC_SET(int32_t,open_level)
DEC_SET(int32_t,open_times)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,season)
DEC_SET(int32_t,round)
DEC_SET(float,hp5)
DEC_SET(float,hp4)
DEC_SET(int32_t,anger)
DEC_SET(float,hp3)
DEC_SET(int32_t,coin)
DEC_SET(int32_t,first_enter_time)
DEC_SET(float,hp2)
DEC_SET(int32_t,pid3)
DEC_SET(string,enemy_view_data)
DEC_SET(int32_t,pid5)
DEC_SET(int32_t,pid1)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,round_max)
DEC_SET(int32_t,difficult)
DEC_SET(int32_t,reset_time)
DEC_SET(float,hp1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventUser` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_CardEventUser_t& data()
{
return *((db_CardEventUser_t*)(this));
}
};
class db_CardEventTeam_ext_t: public db_CardEventTeam_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventTeam_ext_t()
{
REG_MEM(int32_t,anger)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,pid1)
REG_MEM(int32_t,pid3)
REG_MEM(int32_t,pid5)
}
DEC_SET(int32_t,anger)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,pid1)
DEC_SET(int32_t,pid3)
DEC_SET(int32_t,pid5)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventTeam` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_CardEventTeam_t& data()
{
return *((db_CardEventTeam_t*)(this));
}
};
class db_Rank_ext_t: public db_Rank_t, db_smart_up_t, boost::noncopyable
{
public:
db_Rank_ext_t()
{
REG_MEM(int32_t,uid)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,id)
REG_MEM(int32_t,rankindex)
REG_MEM(int32_t,ranknum)
}
DEC_SET(int32_t,uid)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,id)
DEC_SET(int32_t,rankindex)
DEC_SET(int32_t,ranknum)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Rank` SET %%1%% WHERE  `id` = %d", id);
return gen_up_sql(buf);
}
db_Rank_t& data()
{
return *((db_Rank_t*)(this));
}
};
class db_RoundStarReward_ext_t: public db_RoundStarReward_t, db_smart_up_t, boost::noncopyable
{
public:
db_RoundStarReward_ext_t()
{
REG_MEM(int,r4)
REG_MEM(int,r1)
REG_MEM(int,r2)
REG_MEM(int,r3)
}
DEC_SET(int,r4)
DEC_SET(int,r1)
DEC_SET(int,r2)
DEC_SET(int,r3)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RoundStarReward` SET %%1%% WHERE  `uid` = %d AND  `rpid` = %d", uid, rpid);
return gen_up_sql(buf);
}
db_RoundStarReward_t& data()
{
return *((db_RoundStarReward_t*)(this));
}
};
class db_CardEventRank_ext_t: public db_CardEventRank_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventRank_ext_t()
{
REG_MEM(int32_t,rank)
}
DEC_SET(int32_t,rank)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventRank` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_CardEventRank_t& data()
{
return *((db_CardEventRank_t*)(this));
}
};
class db_Activity_ext_t: public db_Activity_t, db_smart_up_t, boost::noncopyable
{
public:
db_Activity_ext_t()
{
REG_MEM(ystring_t<30>,nickname)
REG_MEM(int32_t,cumu_yb_rank_exp)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,con_wing_given)
REG_MEM(uint32_t,con_wing_stamp)
REG_MEM(int32_t,hostnum)
REG_MEM(uint32_t,cumu_yb_rank_stamp)
REG_MEM(int32_t,con_wing_rank)
REG_MEM(int32_t,con_wing_score)
REG_MEM(int32_t,cumu_yb_rank)
}
DEC_SET(ystring_t<30>,nickname)
DEC_SET(int32_t,cumu_yb_rank_exp)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,con_wing_given)
DEC_SET(uint32_t,con_wing_stamp)
DEC_SET(int32_t,hostnum)
DEC_SET(uint32_t,cumu_yb_rank_stamp)
DEC_SET(int32_t,con_wing_rank)
DEC_SET(int32_t,con_wing_score)
DEC_SET(int32_t,cumu_yb_rank)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Activity` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_Activity_t& data()
{
return *((db_Activity_t*)(this));
}
};
class db_CardEventRound_ext_t: public db_CardEventRound_t, db_smart_up_t, boost::noncopyable
{
public:
db_CardEventRound_ext_t()
{
REG_MEM(string,view_data)
REG_MEM(int32_t,pid4)
REG_MEM(int32_t,pid2)
REG_MEM(int32_t,pid1)
REG_MEM(int32_t,pid5)
REG_MEM(int32_t,pid3)
}
DEC_SET(string,view_data)
DEC_SET(int32_t,pid4)
DEC_SET(int32_t,pid2)
DEC_SET(int32_t,pid1)
DEC_SET(int32_t,pid5)
DEC_SET(int32_t,pid3)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `CardEventRound` SET %%1%% WHERE  `eid` = %d AND  `round` = %d", eid, round);
return gen_up_sql(buf);
}
db_CardEventRound_t& data()
{
return *((db_CardEventRound_t*)(this));
}
};
class db_UserID_ext_t: public db_UserID_t, db_smart_up_t, boost::noncopyable
{
public:
db_UserID_ext_t()
{
REG_MEM(ystring_t<30>,nickname)
REG_MEM(int32_t,grade)
REG_MEM(int32_t,state)
REG_MEM(int32_t,wingid)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,isoverdue)
REG_MEM(int32_t,viplevel)
}
DEC_SET(ystring_t<30>,nickname)
DEC_SET(int32_t,grade)
DEC_SET(int32_t,state)
DEC_SET(int32_t,wingid)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,isoverdue)
DEC_SET(int32_t,viplevel)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `UserID` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_UserID_t& data()
{
return *((db_UserID_t*)(this));
}
};
class db_Friend_ext_t: public db_Friend_t, db_smart_up_t, boost::noncopyable
{
public:
db_Friend_ext_t()
{
REG_MEM(int32_t,hasSendFlower)
}
DEC_SET(int32_t,hasSendFlower)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Friend` SET %%1%% WHERE  `uid` = %d AND  `fuid` = %d", uid, fuid);
return gen_up_sql(buf);
}
db_Friend_t& data()
{
return *((db_Friend_t*)(this));
}
};
class db_ComboPro_ext_t: public db_ComboPro_t, db_smart_up_t, boost::noncopyable
{
public:
db_ComboPro_ext_t()
{
REG_MEM(int32_t,exp5)
REG_MEM(int32_t,exp1)
REG_MEM(int32_t,o4)
REG_MEM(int32_t,o1)
REG_MEM(int32_t,o3)
REG_MEM(int32_t,o2)
REG_MEM(int32_t,exp4)
REG_MEM(int32_t,exp2)
REG_MEM(int32_t,o5)
REG_MEM(int32_t,exp3)
}
DEC_SET(int32_t,exp5)
DEC_SET(int32_t,exp1)
DEC_SET(int32_t,o4)
DEC_SET(int32_t,o1)
DEC_SET(int32_t,o3)
DEC_SET(int32_t,o2)
DEC_SET(int32_t,exp4)
DEC_SET(int32_t,exp2)
DEC_SET(int32_t,o5)
DEC_SET(int32_t,exp3)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ComboPro` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_ComboPro_t& data()
{
return *((db_ComboPro_t*)(this));
}
};
class db_RunePage_ext_t: public db_RunePage_t, db_smart_up_t, boost::noncopyable
{
public:
db_RunePage_ext_t()
{
REG_MEM(int32_t,id)
}
DEC_SET(int32_t,id)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RunePage` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d AND  `slot` = %d", uid, pid, slot);
return gen_up_sql(buf);
}
db_RunePage_t& data()
{
return *((db_RunePage_t*)(this));
}
};
class db_Bullet_ext_t: public db_Bullet_t, db_smart_up_t, boost::noncopyable
{
public:
db_Bullet_ext_t()
{
REG_MEM(int32_t,uid)
REG_MEM(uint32_t,stamp)
REG_MEM(uint32_t,round)
REG_MEM(ystring_t<30>,msg)
REG_MEM(int32_t,pos)
}
DEC_SET(int32_t,uid)
DEC_SET(uint32_t,stamp)
DEC_SET(uint32_t,round)
DEC_SET(ystring_t<30>,msg)
DEC_SET(int32_t,pos)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Bullet` SET %%1%% WHERE  `round` = %u", round);
return gen_up_sql(buf);
}
db_Bullet_t& data()
{
return *((db_Bullet_t*)(this));
}
};
class db_ExpeditionShop_ext_t: public db_ExpeditionShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_ExpeditionShop_ext_t()
{
REG_MEM(int32_t,count)
REG_MEM(int32_t,eshopid)
REG_MEM(int32_t,refresh_time)
}
DEC_SET(int32_t,count)
DEC_SET(int32_t,eshopid)
DEC_SET(int32_t,refresh_time)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ExpeditionShop` SET %%1%% WHERE  `uid` = %d AND  `eshopindex` = %d", uid, eshopindex);
return gen_up_sql(buf);
}
db_ExpeditionShop_t& data()
{
return *((db_ExpeditionShop_t*)(this));
}
};
class db_Team_ext_t: public db_Team_t, db_smart_up_t, boost::noncopyable
{
public:
db_Team_ext_t()
{
REG_MEM(int32_t,is_default)
REG_MEM(int32_t,p5)
REG_MEM(ystring_t<30>,name)
REG_MEM(int32_t,p4)
REG_MEM(int32_t,p2)
REG_MEM(int32_t,p3)
REG_MEM(int32_t,p1)
}
DEC_SET(int32_t,is_default)
DEC_SET(int32_t,p5)
DEC_SET(ystring_t<30>,name)
DEC_SET(int32_t,p4)
DEC_SET(int32_t,p2)
DEC_SET(int32_t,p3)
DEC_SET(int32_t,p1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Team` SET %%1%% WHERE  `uid` = %d AND  `tid` = %d", uid, tid);
return gen_up_sql(buf);
}
db_Team_t& data()
{
return *((db_Team_t*)(this));
}
};
class db_ExpeditionPartners_ext_t: public db_ExpeditionPartners_t, db_smart_up_t, boost::noncopyable
{
public:
db_ExpeditionPartners_ext_t()
{
REG_MEM(float,hp)
}
DEC_SET(float,hp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ExpeditionPartners` SET %%1%% WHERE  `uid` = %d AND  `pid` = %d", uid, pid);
return gen_up_sql(buf);
}
db_ExpeditionPartners_t& data()
{
return *((db_ExpeditionPartners_t*)(this));
}
};
class db_Task_ext_t: public db_Task_t, db_smart_up_t, boost::noncopyable
{
public:
db_Task_ext_t()
{
REG_MEM(int32_t,state)
REG_MEM(int32_t,step)
}
DEC_SET(int32_t,state)
DEC_SET(int32_t,step)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Task` SET %%1%% WHERE  `uid` = %d AND  `resid` = %d", uid, resid);
return gen_up_sql(buf);
}
db_Task_t& data()
{
return *((db_Task_t*)(this));
}
};
class db_Server_ext_t: public db_Server_t, db_smart_up_t, boost::noncopyable
{
public:
db_Server_ext_t()
{
REG_MEM(uint32_t,wbcut)
REG_MEM(uint32_t,ctime)
REG_MEM(int32_t,maxlv)
REG_MEM(int32_t,bosslv)
REG_MEM(uint32_t,result_rank_stamp)
}
DEC_SET(uint32_t,wbcut)
DEC_SET(uint32_t,ctime)
DEC_SET(int32_t,maxlv)
DEC_SET(int32_t,bosslv)
DEC_SET(uint32_t,result_rank_stamp)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Server` SET %%1%% WHERE  `serid` = %d", serid);
return gen_up_sql(buf);
}
db_Server_t& data()
{
return *((db_Server_t*)(this));
}
};
class db_RewardExtentionI_ext_t: public db_RewardExtentionI_t, db_smart_up_t, boost::noncopyable
{
public:
db_RewardExtentionI_ext_t()
{
REG_MEM(int32_t,sevenpay_count)
REG_MEM(ystring_t<30>,limit_seven_stage)
REG_MEM(int32_t,opentask_stage_two)
REG_MEM(ystring_t<30>,sevenpay_stage)
REG_MEM(int32_t,opentask_reward)
REG_MEM(int32_t,vip_days)
REG_MEM(int32_t,luckbagvalue)
REG_MEM(int32_t,limit_seven_count)
REG_MEM(int32_t,openybtotal)
REG_MEM(int32_t,vip_stamp)
REG_MEM(int32_t,limit_seven_stamp)
REG_MEM(int32_t,limit_pub)
REG_MEM(int32_t,opentask_stage_one)
REG_MEM(int32_t,opentask_stage_three)
REG_MEM(int32_t,opentask_level)
REG_MEM(int32_t,openybstamp)
REG_MEM(int32_t,luckbagstamp)
REG_MEM(int32_t,lastpay_timestamp)
REG_MEM(ystring_t<30>,openybreward)
}
DEC_SET(int32_t,sevenpay_count)
DEC_SET(ystring_t<30>,limit_seven_stage)
DEC_SET(int32_t,opentask_stage_two)
DEC_SET(ystring_t<30>,sevenpay_stage)
DEC_SET(int32_t,opentask_reward)
DEC_SET(int32_t,vip_days)
DEC_SET(int32_t,luckbagvalue)
DEC_SET(int32_t,limit_seven_count)
DEC_SET(int32_t,openybtotal)
DEC_SET(int32_t,vip_stamp)
DEC_SET(int32_t,limit_seven_stamp)
DEC_SET(int32_t,limit_pub)
DEC_SET(int32_t,opentask_stage_one)
DEC_SET(int32_t,opentask_stage_three)
DEC_SET(int32_t,opentask_level)
DEC_SET(int32_t,openybstamp)
DEC_SET(int32_t,luckbagstamp)
DEC_SET(int32_t,lastpay_timestamp)
DEC_SET(ystring_t<30>,openybreward)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RewardExtentionI` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_RewardExtentionI_t& data()
{
return *((db_RewardExtentionI_t*)(this));
}
};
class db_Cdkey_ext_t: public db_Cdkey_t, db_smart_up_t, boost::noncopyable
{
public:
db_Cdkey_ext_t()
{
REG_MEM(ystring_t<30>,expire_date)
REG_MEM(int32_t,uid)
REG_MEM(int32_t,flag)
REG_MEM(ystring_t<30>,giventm)
REG_MEM(ystring_t<30>,domain)
REG_MEM(ystring_t<30>,nickname)
}
DEC_SET(ystring_t<30>,expire_date)
DEC_SET(int32_t,uid)
DEC_SET(int32_t,flag)
DEC_SET(ystring_t<30>,giventm)
DEC_SET(ystring_t<30>,domain)
DEC_SET(ystring_t<30>,nickname)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Cdkey` SET %%1%% WHERE  `sn` = '%s'", sn.c_str());
return gen_up_sql(buf);
}
db_Cdkey_t& data()
{
return *((db_Cdkey_t*)(this));
}
};
class db_RuneShop_ext_t: public db_RuneShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_RuneShop_ext_t()
{
REG_MEM(int32_t,rshopid)
REG_MEM(int32_t,count)
REG_MEM(int32_t,refresh_time)
}
DEC_SET(int32_t,rshopid)
DEC_SET(int32_t,count)
DEC_SET(int32_t,refresh_time)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `RuneShop` SET %%1%% WHERE  `uid` = %d AND  `rshopindex` = %d", uid, rshopindex);
return gen_up_sql(buf);
}
db_RuneShop_t& data()
{
return *((db_RuneShop_t*)(this));
}
};
class db_NpcShop_ext_t: public db_NpcShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_NpcShop_ext_t()
{
REG_MEM(int32_t,item2)
REG_MEM(int32_t,item6)
REG_MEM(int32_t,item5)
REG_MEM(int32_t,item4)
REG_MEM(int32_t,item3)
REG_MEM(int32_t,item1)
}
DEC_SET(int32_t,item2)
DEC_SET(int32_t,item6)
DEC_SET(int32_t,item5)
DEC_SET(int32_t,item4)
DEC_SET(int32_t,item3)
DEC_SET(int32_t,item1)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `NpcShop` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_NpcShop_t& data()
{
return *((db_NpcShop_t*)(this));
}
};
class db_Pet_ext_t: public db_Pet_t, db_smart_up_t, boost::noncopyable
{
public:
db_Pet_ext_t()
{
REG_MEM(int32_t,hp)
REG_MEM(int32_t,atk)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,res)
REG_MEM(int32_t,mgc)
REG_MEM(int32_t,def)
}
DEC_SET(int32_t,hp)
DEC_SET(int32_t,atk)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,res)
DEC_SET(int32_t,mgc)
DEC_SET(int32_t,def)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Pet` SET %%1%% WHERE  `uid` = %d AND  `petid` = %d", uid, petid);
return gen_up_sql(buf);
}
db_Pet_t& data()
{
return *((db_Pet_t*)(this));
}
};
class db_TreasureConqueror_ext_t: public db_TreasureConqueror_t, db_smart_up_t, boost::noncopyable
{
public:
db_TreasureConqueror_ext_t()
{
REG_MEM(int32_t,profit)
REG_MEM(int32_t,debian_secs)
REG_MEM(int32_t,hostnum)
REG_MEM(int32_t,slot_pos)
REG_MEM(int32_t,last_stamp)
REG_MEM(int32_t,last_round)
REG_MEM(int32_t,n_rob)
}
DEC_SET(int32_t,profit)
DEC_SET(int32_t,debian_secs)
DEC_SET(int32_t,hostnum)
DEC_SET(int32_t,slot_pos)
DEC_SET(int32_t,last_stamp)
DEC_SET(int32_t,last_round)
DEC_SET(int32_t,n_rob)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `TreasureConqueror` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_TreasureConqueror_t& data()
{
return *((db_TreasureConqueror_t*)(this));
}
};
class db_GangShop_ext_t: public db_GangShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_GangShop_ext_t()
{
REG_MEM(int32_t,count)
REG_MEM(int32_t,gshopid)
REG_MEM(int32_t,refresh_time)
}
DEC_SET(int32_t,count)
DEC_SET(int32_t,gshopid)
DEC_SET(int32_t,refresh_time)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `GangShop` SET %%1%% WHERE  `uid` = %d AND  `gshopindex` = %d", uid, gshopindex);
return gen_up_sql(buf);
}
db_GangShop_t& data()
{
return *((db_GangShop_t*)(this));
}
};
class db_LmtShop_ext_t: public db_LmtShop_t, db_smart_up_t, boost::noncopyable
{
public:
db_LmtShop_ext_t()
{
REG_MEM(int32_t,count)
REG_MEM(int32_t,shopindex)
REG_MEM(uint32_t,refresh_time)
}
DEC_SET(int32_t,count)
DEC_SET(int32_t,shopindex)
DEC_SET(uint32_t,refresh_time)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `LmtShop` SET %%1%% WHERE  `uid` = %d AND  `shopid` = %d", uid, shopid);
return gen_up_sql(buf);
}
db_LmtShop_t& data()
{
return *((db_LmtShop_t*)(this));
}
};
class db_ReportUser_ext_t: public db_ReportUser_t, db_smart_up_t, boost::noncopyable
{
public:
db_ReportUser_ext_t()
{
REG_MEM(int32_t,reportNum)
REG_MEM(int32_t,reportTime)
REG_MEM(int32_t,accusedNum)
}
DEC_SET(int32_t,reportNum)
DEC_SET(int32_t,reportTime)
DEC_SET(int32_t,accusedNum)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `ReportUser` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_ReportUser_t& data()
{
return *((db_ReportUser_t*)(this));
}
};
class db_Rune_ext_t: public db_Rune_t, db_smart_up_t, boost::noncopyable
{
public:
db_Rune_ext_t()
{
REG_MEM(int32_t,uid)
REG_MEM(int32_t,pid)
REG_MEM(int32_t,resid)
REG_MEM(int32_t,exp)
REG_MEM(int32_t,pos)
}
DEC_SET(int32_t,uid)
DEC_SET(int32_t,pid)
DEC_SET(int32_t,resid)
DEC_SET(int32_t,exp)
DEC_SET(int32_t,pos)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Rune` SET %%1%% WHERE  `uid` = %d AND  `rid` = %d", uid, rid);
return gen_up_sql(buf);
}
db_Rune_t& data()
{
return *((db_Rune_t*)(this));
}
};
class db_Arena_ext_t: public db_Arena_t, db_smart_up_t, boost::noncopyable
{
public:
db_Arena_ext_t()
{
REG_MEM(uint32_t,stamp)
REG_MEM(int32_t,fight_count)
REG_MEM(int32_t,in_buy)
REG_MEM(int32_t,target_id)
REG_MEM(int32_t,win_count)
REG_MEM(uint32_t,in_stamp)
REG_MEM(int32_t,n_buy)
REG_MEM(int32_t,in_fight_count)
}
DEC_SET(uint32_t,stamp)
DEC_SET(int32_t,fight_count)
DEC_SET(int32_t,in_buy)
DEC_SET(int32_t,target_id)
DEC_SET(int32_t,win_count)
DEC_SET(uint32_t,in_stamp)
DEC_SET(int32_t,n_buy)
DEC_SET(int32_t,in_fight_count)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Arena` SET %%1%% WHERE  `uid` = %d", uid);
return gen_up_sql(buf);
}
db_Arena_t& data()
{
return *((db_Arena_t*)(this));
}
};
class db_Pay_ext_t: public db_Pay_t, db_smart_up_t, boost::noncopyable
{
public:
db_Pay_ext_t()
{
REG_MEM(int32_t,cristal)
REG_MEM(ystring_t<32>,giventime)
REG_MEM(ystring_t<32>,paytime)
REG_MEM(ystring_t<10>,domain)
REG_MEM(int32_t,repo_rmb)
REG_MEM(int32_t,state)
REG_MEM(int32_t,reward_cristal)
REG_MEM(int32_t,pay_rmb)
}
DEC_SET(int32_t,cristal)
DEC_SET(ystring_t<32>,giventime)
DEC_SET(ystring_t<32>,paytime)
DEC_SET(ystring_t<10>,domain)
DEC_SET(int32_t,repo_rmb)
DEC_SET(int32_t,state)
DEC_SET(int32_t,reward_cristal)
DEC_SET(int32_t,pay_rmb)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Pay` SET %%1%% WHERE  `serid` = %d", serid);
return gen_up_sql(buf);
}
db_Pay_t& data()
{
return *((db_Pay_t*)(this));
}
};
class db_Account_ext_t: public db_Account_t, db_smart_up_t, boost::noncopyable
{
public:
db_Account_ext_t()
{
REG_MEM(int32_t,lasthostnum)
REG_MEM(int32_t,flag)
REG_MEM(ystring_t<10>,domain)
REG_MEM(int32_t,lastuid)
}
DEC_SET(int32_t,lasthostnum)
DEC_SET(int32_t,flag)
DEC_SET(ystring_t<10>,domain)
DEC_SET(int32_t,lastuid)
string get_up_sql()
{
if (!has_changed()) return "";
char buf[256];
sprintf(buf, "UPDATE `Account` SET %%1%% WHERE  `aid` = %d", aid);
return gen_up_sql(buf);
}
db_Account_t& data()
{
return *((db_Account_t*)(this));
}
};
#endif
