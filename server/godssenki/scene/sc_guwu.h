#ifndef _sc_guwu_h_
#define _sc_guwu_h_

#include <unordered_map>
#include "msg_def.h"
#include "singleton.h"
#include "db_def.h"
#include "sc_service.h"

enum guwu_e
{
    guwu_unknown,
    guwu_worldboss,
    guwu_gangboss,
    guwu_scuffle,
};

typedef sc_msg_def::jpk_guwu_t sc_guwu_t;

typedef map<int, sc_guwu_t> sc_user_guwu_t;

class sc_guwu_mgr_t
{
    typedef unordered_map<int, sc_user_guwu_t> user_guwu_map_t;
public:
    user_guwu_map_t user_guwu_map;
    float get_v(int uid_, int flag_)
    {
        auto it_guwu = user_guwu_map.find(uid_);
        if (it_guwu != user_guwu_map.end())
        {
            sc_user_guwu_t& guwu_map = it_guwu->second; 
            auto it = guwu_map.find(flag_);
            if (it!=guwu_map.end())
            {
                return it->second.v;
            }
        }
        return 0;
    }
    void clean_guwu(int flag_)
    {
        for(auto info = user_guwu_map.begin();info != user_guwu_map.end(); info++)
        {
            sc_user_guwu_t& guwu_map = info->second;
            auto it = guwu_map.find(flag_);
            if(it!=guwu_map.end())
            {
                it->second.v = 0;
                it->second.progress = 0;
                it->second.stamp_v = 0;
                it->second.stamp_coin = 0;
                if (flag_ == 2){
                    save_db(info->first,flag_,guwu_map);
                }
            }
        }
    }
    int32_t load_db(int32_t uid_,int32_t flag_,sc_user_guwu_t& user_guwu_,bool is_create)
    {
        sql_result_t res;
        db_GangBossGuwu_t db;
        if(0 == db_GangBossGuwu_t::sync_select_uid(uid_,res)){
            db.init(*res.get_row_at(0));
            user_guwu_[flag_].v = db.v;
            user_guwu_[flag_].progress = db.progress;
            user_guwu_[flag_].stamp_v= db.stamp_v;
            user_guwu_[flag_].stamp_yb = db.stamp_yb;
            user_guwu_[flag_].stamp_coin = db.stamp_coin;
            return 0;
        }
        else if(is_create){
            db.uid = uid_;
            db.v = 0;
            db.progress = 0;
            db.stamp_v = 0;
            db.stamp_yb = 0;
            db.stamp_coin = 0;
            //db_service.async_do((uint64_t)uid_,[](db_GangBossGuwu_t& db_){
                db.sync_insert();
            //},db);
        }
        return 1;
    }
    void save_db(int32_t uid_, int32_t flag_,sc_user_guwu_t& user_guwu_){
        db_GangBossGuwu_t db;
        db.uid = uid_;
        db.v = user_guwu_[flag_].v;
        db.progress = user_guwu_[flag_].progress;
        db.stamp_v = user_guwu_[flag_].stamp_v;
        db.stamp_yb = user_guwu_[flag_].stamp_yb;
        db.stamp_coin = user_guwu_[flag_].stamp_coin;
//        cout<<"v->"<<user_guwu_[flag_].v<<" progress->"<<user_guwu_[flag_].progress<<" stamp_v->"<<user_guwu_[flag_].stamp_v<<" stamp_yb->"<<user_guwu_[flag_].stamp_yb<<" stamp_coin->"<<user_guwu_[flag_].stamp_coin<<endl;
        db_service.async_do((uint64_t)uid_,[](db_GangBossGuwu_t& db_){
            db_.update(); 
        },db);
    }
    void delete_db(int32_t uid_)
    {
        char sql[128];
        sprintf(sql,"delete from GangBossGuwu  where uid = %d",uid_);
        db_service.sync_execute(sql);
    }
};

#define guwu_mgr (singleton_t<sc_guwu_mgr_t>::instance())

#endif
