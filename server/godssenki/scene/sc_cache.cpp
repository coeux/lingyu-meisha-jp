#include "sc_cache.h"
#include "sc_logic.h"
#include "sc_friend.h"
#include "code_def.h"
#include <boost/format.hpp>

#define LOG "SC_CACHE"

#define N_TRAIL_TARGET 3

sp_view_user_t sc_view_cache_t::get_view(int32_t uid_, bool withdb_)
{
    sp_view_user_t sp_view;
    sp_user_t sp_user;

    if ( logic.usermgr().get(uid_, sp_user) )
    {
        sp_view = sp_user->get_view();
        put(uid_, sp_view);
        return sp_view;
    }

    if (get(uid_, sp_view))
    {
        return sp_view;
    }

    if( cache.get(uid_, sp_user) )
    {
        sp_view = sp_user->get_view();
        put(uid_, sp_view);
        return sp_view;
    }

    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid :%d", uid_));
        }
        else
        {
            logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
            cache.put(uid_, sp_user);
            sp_view = sp_user->get_view();
            put(uid_, sp_view);
            return sp_view;
        }
    }

    return sp_view;
}

sp_view_user_t sc_view_cache_t::get_other_view(int32_t uid_)
{
    sp_view_user_t sp_view;
    sp_user_t sp_user;

    /*
       if ( logic.usermgr().get(uid_, sp_user) )
       {
       sp_view = sp_user->get_view();
       put(uid_, sp_view);
       return sp_view;
       }
    if (get(uid_, sp_view))
    {
        return sp_view;
    }
       */
    sp_user.reset(new sc_user_t);
    if (!sp_user->load_db(uid_))
    {
        logerror((LOG, "db no uid :%d", uid_));
    }
    else
    {
        logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
        //cache.put(uid_, sp_user);
        sp_view = sp_user->get_view();
        //put(uid_, sp_view);
        return sp_view;
    }

    return sp_view;
}

sp_view_user_other_t sc_view_cache_other_t::get_view_others(int32_t uid_, bool withdb_)
{
    sp_view_user_other_t sp_view;
    sp_user_t sp_user;

    if ( logic.usermgr().get(uid_, sp_user) )
    {
        sp_view = sp_user->get_view_others();
        put(uid_, sp_view);
        return sp_view;
    }

    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid :%d", uid_));
        }
        else
        {
            logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
            cache.put(uid_, sp_user);
            sp_view = sp_user->get_view_others();
            put(uid_, sp_view);
            return sp_view;
        }
    }

    return sp_view;
}

sp_view_user_t sc_view_cache_t::get_view(int32_t uid_, int32_t* rid_, bool withdb_)
{
    sp_view_user_t sp_view;
    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        sp_view = sp_user->get_view(rid_);
        return sp_view;
    }
    if (cache.get(uid_, sp_user))
    {
        sp_view = sp_user->get_view(rid_);
        return sp_view;
    }
    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid:%d", uid_));
        }
        else
        {
            logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
            cache.put(uid_, sp_user);
            sp_view = sp_user->get_view(rid_);
            return sp_view;
        }
    }
    return sp_view;
}

sp_fight_view_user_t sc_view_cache_t::get_fight_view(int32_t uid_, int32_t* rid_, bool withdb_)
{
    sp_fight_view_user_t sp_view;
    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        sp_view = sp_user->get_fight_view(rid_);
        return sp_view;
    }
    if (cache.get(uid_, sp_user))
    {
        sp_view = sp_user->get_fight_view(rid_);
        return sp_view;
    }
    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid:%d", uid_));
        }
        else
        {
            logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
            cache.put(uid_, sp_user);
            sp_view = sp_user->get_fight_view(rid_);
            return sp_view;
        }
    }
    return sp_view;
}

sp_fight_view_user_t sc_view_cache_t::get_gbattle_fight_view(int32_t uid_, int32_t* rid_, bool withdb_)
{
    sp_fight_view_user_t sp_view;
    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        sp_view = sp_user->get_gbattle_fight_view(rid_);
        return sp_view;
    }
    if (cache.get(uid_, sp_user))
    {
        sp_view = sp_user->get_gbattle_fight_view(rid_);
        return sp_view;
    }
    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid:%d", uid_));
        }
        else
        {
            logwarn((LOG, "sc_view_cache_t::put %d to view_cache", uid_));
            cache.put(uid_, sp_user);
            sp_view = sp_user->get_gbattle_fight_view(rid_);
            return sp_view;
        }
    }
    return sp_view;
}

sp_fight_view_user_t sc_view_cache_t::get_rank_view(int32_t uid_, int32_t* rid_)
{
    sp_fight_view_user_t sp_view;
    sp_user_t sp_user;
    sp_user.reset(new sc_user_t);
    sp_user->load_db(uid_);
    sp_view = sp_user->get_rank_view(rid_);
    return sp_view;
}

sp_helphero_t sc_hero_cache_t::get_helphero(int32_t uid_, bool withdb_)
{
    sp_helphero_t sp_helphero;
    sp_user_t sp_user;

    if ( logic.usermgr().get(uid_, sp_user) )
    {
        sp_helphero = sp_user->get_helphero();
        hero_cache.put(uid_, sp_helphero);
        return sp_helphero;
    }

    if (get(uid_, sp_helphero))
    {
        return sp_helphero;
    }

    if( cache.get(uid_, sp_user) )
    {
        sp_helphero = sp_user->get_helphero();
        hero_cache.put(uid_, sp_helphero);
        return sp_helphero;
    }

    if (withdb_)
    {
        sp_user.reset(new sc_user_t);
        if (!sp_user->load_db(uid_))
        {
            logerror((LOG, "db no uid :%d", uid_));
        }
        else
        {
            cache.put(uid_, sp_user);
            sp_helphero = sp_user->get_helphero();
            hero_cache.put(uid_, sp_helphero);
            return sp_helphero;
        }
    }

    return sp_helphero;
}
int32_t sc_view_cache_t::get_fp_total(sp_view_user_t &view_)
{
    int32_t fp = 0;
    for(auto it=view_->roles.begin();it!=view_->roles.end();++it)
    {
        fp += (it->second.pro.fp);
    }
    return fp;
}
void sc_view_cache_t::insert_view(sp_view_user_t view_) 
{
    /*
    db_service.async_do((uint64_t)view_->uid, [](sc_msg_def::jpk_view_user_data_t& view_){
        string data;
        view_ >> data;
        boost::format format = boost::format("insert into UserData (uid, data) values(%1%,'%2%')");
        format % view_.uid;
        format % data;
        db_service.async_execute(format.str().c_str());
    }, *view_);
    */
}
void sc_view_cache_t::update_view(sp_view_user_t view_)
{
    /*
    db_service.async_do((uint64_t)view_->uid, [](sc_msg_def::jpk_view_user_data_t& view_){
        string data;
        view_ >> data;
        boost::format format = boost::format("update UserData set data='%2%'where uid=%1%");
        format % view_.uid;
        format % data;
        
        db_service.async_execute(format.str().c_str());
    }, *view_);
    */
}
sp_baseinfo_t sc_baseinfo_cache_t::get_baseinfo(int32_t uid_, bool withdb_)
{
    sp_baseinfo_t frd;
    if (get(uid_, frd))
    {
        return frd;
    }

    sp_user_t user;
    if ( logic.usermgr().get(uid_, user) )
    {
        frd = user->get_frd_info();
        put(uid_, frd);
        return frd;
    }
    if( cache.get(uid_, user) )
    {
        frd = user->get_frd_info();
        put(uid_, frd);
        return frd;
    }

    if (withdb_)
    {
        char sql[256];
        sql_result_t res;

        sprintf(sql,"select nickname,grade,fp,helphero,frd,resid from UserInfo where uid=%d;",uid_);
        db_service.sync_select(sql, res);

        if( 0==res.affect_row_num() )
            return sp_baseinfo_t();

        sp_baseinfo_t sp_frd(new sc_baseinfo_t());

        /*
        stringstream stream;
        stream << ( *( res.get_row_at(0) ) )[0];stream >> sp_frd->nickname;stream.clear();
        stream << ( *( res.get_row_at(0) ) )[1];stream >> sp_frd->grade; stream.clear();
        stream << ( *( res.get_row_at(0) ) )[2];stream >> sp_frd->fp; stream.clear();
        stream << ( *( res.get_row_at(0) ) )[3];stream >> sp_frd->helphero;stream.clear();
        stream << ( *( res.get_row_at(0) ) )[4];stream >> sp_frd->frdcount;stream.clear();
        */

        sql_result_row_t& row = *res.get_row_at(0);
        sp_frd->nickname = row[0];
        sp_frd->grade = std::atoi(row[1].c_str());
        sp_frd->fp = std::atoi(row[2].c_str());
        sp_frd->helphero = std::atoi(row[3].c_str());
        sp_frd->frdcount = std::atoi(row[4].c_str());

        if( 0 == sp_frd->helphero )
        {
            //stream <<( *( res.get_row_at(0) ) )[5];stream >> sp_frd->helpresid;stream.clear();
            sp_frd->helpresid = std::atoi(row[5].c_str());
        }
        else
        {
            char sql[256];
            sql_result_t res;

            sprintf(sql,"select resid from Partner where pid=%d;",sp_frd->helphero);
            db_service.sync_select(sql, res);

            if( 0==res.affect_row_num() )
                return sp_baseinfo_t();

            //stringstream stream;
            //stream <<( *( res.get_row_at(0) ) )[0];stream >> sp_frd->helpresid;stream.clear();

            sql_result_row_t& row = *res.get_row_at(0);
            sp_frd->helpresid = std::atoi(row[0].c_str());
        }

        put(uid_, sp_frd);
        return sp_frd;
    }
    else
        return sp_baseinfo_t();
}


int32_t sc_name_cache_t::get_uid_by_name(const string &name_,bool withdb_)
{
    int32_t uid;
    if (get(name_, uid))
    {
        return uid;
    }

    if (withdb_)
    {
        char sql[256];
        sql_result_t res;

        sprintf(sql,"select uid,grade,fp,helphero,frd,resid from UserInfo where nickname='%s';",name_.c_str());
        db_service.sync_select(sql, res);

        if( 0==res.affect_row_num() )
            return 0;

        sp_baseinfo_t sp_frd(new sc_baseinfo_t());
        sp_frd->nickname = name_;

        /*
        stringstream stream;
        stream << ( *( res.get_row_at(0) ) )[0];stream >> uid;stream.clear();
        stream << ( *( res.get_row_at(0) ) )[1];stream >> sp_frd->grade; stream.clear();
        stream << ( *( res.get_row_at(0) ) )[2];stream >> sp_frd->fp; stream.clear();
        stream << ( *( res.get_row_at(0) ) )[3];stream >> sp_frd->helphero;stream.clear();
        stream << ( *( res.get_row_at(0) ) )[4];stream >> sp_frd->frdcount;stream.clear();
        */

        sql_result_row_t& row = *res.get_row_at(0);
        uid = std::atoi(row[0].c_str());
        sp_frd->grade = std::atoi(row[1].c_str());
        sp_frd->fp = std::atoi(row[2].c_str());
        sp_frd->helphero = std::atoi(row[3].c_str());
        sp_frd->frdcount = std::atoi(row[4].c_str());

        if( 0 == sp_frd->helphero )
        {
            //stream <<( *( res.get_row_at(0) ) )[5];stream >> sp_frd->helpresid;stream.clear();
            sp_frd->helpresid = std::atoi(row[5].c_str());
        }
        else
        {
            char sql[256];
            sql_result_t res;

            sprintf(sql,"select resid from Partner where pid=%d;",sp_frd->helphero);
            db_service.sync_select(sql, res);

            if( 0==res.affect_row_num() )
                return 0;

            //stringstream stream;
            //stream <<( *( res.get_row_at(0) ) )[0];stream >> sp_frd->helpresid;stream.clear();
            sql_result_row_t& row = *res.get_row_at(0);
            sp_frd->helpresid = std::atoi(row[0].c_str());
        }

        baseinfo_cache.put(uid, sp_frd);
        put(name_,uid);
        return uid;
    }
    else
        return 0;
}
/////////////////////////////////////////
void sc_grade_user_t::load_db(vector<int32_t>& hostnums_) 
{ 
    logwarn((LOG, "load grade user..."));

    string strhostnums;
    for(size_t i=0; i<hostnums_.size(); i++){
        strhostnums.append(std::to_string(hostnums_[i]));
        if (i < hostnums_.size() - 1)
            strhostnums.append(",");
    }

    std::atomic_int loaded;
    loaded.store(0);

    for( size_t i=0;i<4;++i )
    {
        int32_t g = 1+i ; 
        while( g<=MAX_GRADE )
        {
            db_service.async_do((uint64_t)i, [](sc_grade_user_t *p_gu, int32_t grade_, atomic_int* loaded_, string& hosts_){

                char sql[256];
                sql_result_t res;
                sprintf(sql, "select uid,resid,nickname,grade,fp,helphero,hhresid from UserInfo where grade=%d and hostnum in (%s) limit 10", grade_, hosts_.c_str());

                //printf("%s\n", sql);

                db_service.async_select(sql, res);

                sc_grade_user_data_t info;
                for(size_t i=0; i<res.affect_row_num(); i++)
                {
                    sql_result_row_t& row = *res.get_row_at(i) ;
                    info.uid = std::atoi(row[0].c_str());
                    info.resid = std::atoi(row[1].c_str());
                    info.name = row[2];
                    info.lv = std::atoi(row[3].c_str());
                    info.fp = std::atoi(row[4].c_str());
                    info.helphero = std::atoi(row[5].c_str());
                    info.helpresid = std::atoi(row[6].c_str());
                    
                    p_gu->grade_user[grade_-1].push_front(info);
                }
                loaded_->fetch_add(1, std::memory_order_relaxed);

            }, this, g, (atomic_int*)&loaded, strhostnums);

            g+=4;
        }
    }
    while(loaded.load() < 200)
    { 
        sleep(0);
    }
    logwarn((LOG, "load grade user...ok"));
}
int32_t sc_grade_user_t::get_strangers(sp_user_t user_,int32_t uid_,int32_t grade_,int32_t count_,vector<sc_msg_def::friend_info_t> &ret_)
{
    int32_t grade = grade_;
    int32_t left = count_;
    int32_t suid;
    sc_msg_def::friend_info_t info;
    //首先选取等级相同的陌生人
    for( size_t i=0;i<grade_user[grade-1].size();++i)
    {
        suid = grade_user[grade-1].front().uid;
        if( (suid!=uid_) && !(user_->friend_mgr.is_frd(suid)) && !(helphero_cache.is_graduated(suid)) )
        {
            info.uid = grade_user[grade-1].front().uid;
            info.pid = grade_user[grade-1].front().helphero;
            info.resid = grade_user[grade-1].front().helpresid;
            info.name = grade_user[grade-1].front().name;
            info.lv = grade_user[grade-1].front().lv;
            info.fp = grade_user[grade-1].front().fp;
            info.online = 0;
            info.ishelped = 0;
            ret_.push_back(info);

            grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
            if(0==(--left))
                return SUCCESS;
        }
        else
            grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
    }
    //然后一上一下扩大范围选取
    int32_t delta = 1, still=1, low,high;
    while( still )
    {
        low = grade-delta;
        high = grade+delta;
        still = 0;
        
        if( high<201 )
        {
            still = 1;
            for( size_t i=0;i<grade_user[high-1].size();++i)
            {
                suid = grade_user[high-1].front().uid;
                if( (suid!=uid_) && !(user_->friend_mgr.is_frd(suid)) && !(helphero_cache.is_graduated(suid)) )
                {
                    info.uid = grade_user[high-1].front().uid;
                    info.pid = grade_user[high-1].front().helphero;
                    info.resid = grade_user[high-1].front().helpresid;
                    info.name = grade_user[high-1].front().name;
                    info.lv = grade_user[high-1].front().lv;
                    info.fp = grade_user[high-1].front().fp;
                    info.online = 0;
                    info.ishelped = 0;
                    ret_.push_back(info);

                    grade_user[high-1].splice( grade_user[high-1].end(), grade_user[high-1], grade_user[high-1].begin() );
                    if(0==(--left))
                        return SUCCESS;
                }
                else
                    grade_user[high-1].splice( grade_user[high-1].end(), grade_user[high-1], grade_user[high-1].begin() );
            }
        }

        if( low>0 )
        {
            still = 1;
            for( size_t i=0;i<grade_user[low-1].size();++i)
            {
                suid = grade_user[low-1].front().uid;
                if( (suid!=uid_) && !(user_->friend_mgr.is_frd(suid)) && !(helphero_cache.is_graduated(suid)) )
                {
                    info.uid = grade_user[low-1].front().uid;
                    info.pid = grade_user[low-1].front().helphero;
                    info.resid = grade_user[low-1].front().helpresid;
                    info.name = grade_user[low-1].front().name;
                    info.lv = grade_user[low-1].front().lv;
                    info.fp = grade_user[low-1].front().fp;
                    info.online = 0;
                    info.ishelped = 0;
                    ret_.push_back(info);

                    grade_user[low-1].splice( grade_user[low-1].end(), grade_user[low-1], grade_user[low-1].begin() );
                    if(0==(--left))
                        return SUCCESS;
                }
                else
                    grade_user[low-1].splice( grade_user[low-1].end(), grade_user[low-1], grade_user[low-1].begin() );
            }
        }
        
        ++delta;
    }
    return -1;
}
int32_t sc_grade_user_t::get_users(int32_t uid_, int32_t grade_, vector<sc_msg_def::jpk_trial_target_info_t> &ret_/*, int32_t left*/)
{
    int32_t grade = grade_;
    sc_msg_def::jpk_trial_target_info_t info;
    int32_t left = N_TRAIL_TARGET;
    sp_user_t user;
    while( grade<=MAX_GRADE )
    {
        for( size_t i=0;i<grade_user[grade-1].size();++i)
        {
            if( grade_user[grade-1].front().uid != uid_ )
            {
                info.uid = grade_user[grade-1].front().uid;
                info.resid = grade_user[grade-1].front().resid;
                info.name = grade_user[grade-1].front().name;
                info.lv = grade_user[grade-1].front().lv;
                //判断玩家是否在线,如果在线，取玩家的战力
                if( cache.get(info.uid,user)||logic.usermgr().get(info.uid, user) )
                    info.fp = grade_user[grade-1].front().fp = user->get_total_fp();
                else
                    info.fp = grade_user[grade-1].front().fp;
                info.win = 0;
                ret_.push_back(info);

                grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
                if(0==(--left))
                    return SUCCESS;
            }
            else
                grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
        }
        ++grade;
    }
    
    grade = grade_-1;
    while( grade>=1 )
    {
        for( size_t i=0;i<grade_user[grade-1].size();++i)
        {
            if( grade_user[grade-1].front().uid != uid_ )
            {
                info.uid = grade_user[grade-1].front().uid;
                info.resid = grade_user[grade-1].front().resid;
                info.name = grade_user[grade-1].front().name;
                info.lv = grade_user[grade-1].front().lv;
                //判断玩家是否在线,如果在线，取玩家的战力
                if( cache.get(info.uid,user)||logic.usermgr().get(info.uid, user) )
                    info.fp = grade_user[grade-1].front().fp = user->get_total_fp();
                else
                    info.fp = grade_user[grade-1].front().fp;
                info.win = 0;
                ret_.push_back(info);

                grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
                if(0==(--left))
                    return SUCCESS;
            }
            else
                grade_user[grade-1].splice( grade_user[grade-1].end(), grade_user[grade-1], grade_user[grade-1].begin() );
        }
        --grade;
    }

    return -1;
}

void sc_grade_user_t::put_user(sp_user_t user_)
{
    int32_t grade = user_->db.grade;
    for( auto it=grade_user[grade-1].begin();it!=grade_user[grade-1].end();++it)
    {
        if( it->uid == user_->db.uid )
            return;
    }

    sc_grade_user_data_t info;
    info.uid = user_->db.uid;
    info.resid = user_->db.resid;
    info.name = user_->db.nickname();
    info.lv = user_->db.grade;
    info.fp = user_->db.fp;
    info.helphero = user_->db.helphero;
    info.helpresid = user_->db.hhresid;
    grade_user[grade-1].push_front( std::move(info) );

    while( grade_user[grade-1].size() > 10 )
        grade_user[grade-1].pop_back();
}
void sc_grade_user_t::remove_user(int32_t uid_,int32_t grade_)
{
    for( auto it=grade_user[grade_-1].begin();it!=grade_user[grade_-1].end();++it)
    {
        if( it->uid == uid_ )
        {
            grade_user[grade_-1].erase(it);
            return;
        }
    }
}
