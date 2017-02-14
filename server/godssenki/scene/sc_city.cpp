#include "sc_city.h"
#include "sc_logic.h"
#include "msg_def.h"
#include "log.h"
#include "repo_def.h"
#include "random.h"
#include "config.h"
#include "code_def.h"
#include "sc_gang.h"
#include "sc_statics.h"
#include "sc_rank.h"
#include "sc_rank_season.h"

#define LOG "SC_CITY"
#define MAX_WATCHED 100

#define IS_GANG(resid) (resid==2998||resid==2999)

#define LTX (-1250)
#define LTY (-1250)
#define RBX (1250)
#define RBY (1250)

sc_city_user_t::sc_city_user_t(int32_t uid_, sc_city_t& city_):
    uid(uid_), 
    city(city_)
{
    sp_user_t user;
    if (logic.usermgr().get(uid_, user))
    {
        if(user->db.grade >= 5) {
            x = 202 + random_t::rand_integer(0, 84*2) - 84;
            y = 56 + random_t::rand_integer(0, 67*2) - 67;
        }else{
            x = -1007 + random_t::rand_integer(0, 84*2) - 84;
            y = -1067 + random_t::rand_integer(0, 67*2) - 67;
        }
    }
}
bool sc_city_user_t::is_fullwatch()
{ 
    return max_watch <= watch_other.size(); 
}
bool sc_city_user_t::is_fullwatched()
{ 
    return MAX_WATCHED <= watch_me.size(); 
}
void sc_city_user_t::sync_pos(int32_t x_, int32_t y_)
{
    //检查是否越界
    if (x_ < LTX || y_ < LTY || RBX < x_ || RBY < y_)
    {
        sc_msg_def::nt_transport_t nt;
        nt.uid = uid;
        nt.x = x;
        nt.y = y;
        nt.sceneid = city.resid;
        logic.unicast(uid, nt);
        return;
    }
    else
    {
        x = x_;
        y = y_;
    }

    //logwarn((LOG, "uid:%d move broad to..., watched num:%u", uid, watch_me.size()));
    for(auto it=watch_me.begin(); it!=watch_me.end(); it++)
    {
        //sp_user_t user;
        //if (logic.usermgr().get(*it, user) && !user->round.is_user_in())
        //{
            sc_msg_def::nt_move_t nt;
            nt.uid = uid;
            nt.sceneid = city.resid;
            nt.x = x;
            nt.y = y;
            logic.unicast(*it, nt);
            //logwarn((LOG, "uid:%d move to [%d,%d], broad to uid:%d", uid, x, y, *it));
        //}
    }
    //logwarn((LOG, "uid:%d move broad to...ok, watch num:%u, watched num:%d", uid, watch_other.size(), watch_me.size()));
}
void sc_city_user_t::watch(int32_t uid_, int32_t x_, int32_t y_)
{
    if (has_watch(uid_))
        return;

    //把目标信息发送给观察者
    sp_user_t user;
    if (logic.usermgr().get(uid_, user))
    {
        if (IS_GANG(city.resid)) 
        {
            uint32_t ggid_watcher = gang_mgr.get_ggid_by_uid(this->uid);
            uint32_t ggid_user = gang_mgr.get_ggid_by_uid(uid_);

            if (ggid_watcher != ggid_user)
            {
                return;
            }
        }

        watch_other.insert(uid_);
        logwarn((LOG, "uid:%d watch uid:%d, x:%d,y:%d, now watch num:%d", uid, uid_, x, y, watch_other.size()));
    }
}
void sc_city_user_t::watched(int32_t uid_, int32_t x_, int32_t y_)
{
    if (watch_me.find(uid_) != watch_me.end())
        return;

    //把目标信息发送给观察者
    sp_user_t user;
    if (logic.usermgr().get(uid, user))
    {
        if (IS_GANG(city.resid)) 
        {
            uint32_t ggid_watcher = gang_mgr.get_ggid_by_uid(this->uid);
            uint32_t ggid_user = gang_mgr.get_ggid_by_uid(uid_);

            if (ggid_watcher != ggid_user)
            {
                return;
            }
        }

        sc_msg_def::nt_user_in_t nt;
        nt.uid = uid;
        nt.model = user->db.model;
        nt.resid = user->db.resid;
        nt.name = user->db.nickname();
        nt.level = user->db.grade;
        nt.quality = user->equip_mgr.get_quality_by_equip(uid);
        nt.viplevel = user->db.viplevel;
        nt.viptype = user->reward.db.vip18;
        nt.weaponid = 0;
        nt.wingid= 0;
        nt.have_pet = false;
        nt.petid = 0;
        rank_ins.unicast_rank_infos(uid, nt.rankinfo);
        if (user->db.grade >= 20)
            rank_season_s.get_rank(uid, nt.season_rank); 
        else
            nt.season_rank = 0;
        
        if (user->wing.get_weared() != NULL)
            nt.wingid=user->wing.get_weared()->db.resid;
        user->pet_mgr.get_pet_state(nt.have_pet, nt.petid);
        sp_equip_t equip = user->equip_mgr.get_part(0, 4);
        if (equip != NULL)
            nt.weaponid = equip->db.resid;

        sp_gang_t sp_gang; 
        sp_ganguser_t sp_guser; 
        if (gang_mgr.get_gang_by_uid(uid, sp_gang, sp_guser))
        {
            nt.gangname = sp_gang->db.name(); 
        }

        nt.x = x;
        nt.y = y;
        logic.unicast(uid_, nt);

        watch_me.insert(uid_);
        //logwarn((LOG, "uid:%d watched uid:%d, x:%d,y:%d", uid, uid_, x, y));
    }
}
//=========================================================
sc_city_t::sc_city_t(int32_t resid_):resid(resid_)
{
}
sp_city_user_t sc_city_t::get_user(int32_t uid_)
{
    auto it = user_hm.find(uid_);
    if (it != user_hm.end())
        return it->second;
    return sp_city_user_t();
}
sp_city_user_t sc_city_t::add_user(int32_t uid_, int32_t watch_max_)
{
    logwarn((LOG, "city:%d add uid:%d...", resid, uid_));

    sp_city_user_t cuser = sp_city_user_t(new sc_city_user_t(uid_, *this));
    cuser->max_watch = watch_max_;
    user_hm.insert(make_pair(uid_, cuser));
    users.insert(users.begin(), uid_);
    return cuser;
}
void sc_city_t::del_user(int32_t uid_)
{
    auto it = user_hm.find(uid_);
    if (it != user_hm.end())
    {
        sp_city_user_t& cuser = it->second;
        cuser->watch_other.clear();
        for(auto itt=cuser->watch_me.begin(); itt != cuser->watch_me.end(); itt++)
        {
            sc_msg_def::nt_user_out_t nt;
            nt.uid = cuser->uid;
            logic.unicast(*itt, nt);
            auto it_ouser = user_hm.find(*itt);
            if (it_ouser != user_hm.end())
            {
                it_ouser->second->watch_other.erase(cuser->uid);
                it_ouser->second->watch_me.erase(cuser->uid);
            }
        }
        cuser->watch_me.clear();
        user_hm.erase(it);

        auto it_users = std::find(users.begin(), users.end(), uid_);
        if (it_users != users.end())
            users.erase(it_users);
    }
}
void sc_city_t::update(sp_city_user_t cuser)
{
    logwarn((LOG, "sc_city_t, update..., resid:%d, total:%d", resid, users.size()));
    for(auto it=users.begin(); it!=users.end();)
    {
        if (cuser->is_fullwatch())
            break;

        sp_city_user_t ouser = get_user(*it);
        if (ouser == NULL)
        {
            it = users.erase(it);
        }
        else if ( ouser->uid != cuser->uid )
        {
            cuser->watch(ouser->uid, ouser->x, ouser->y);
            ouser->watched(cuser->uid, cuser->x, cuser->y);
            if (!ouser->is_fullwatch())
            {
                ouser->watch(cuser->uid, cuser->x, cuser->y);
                cuser->watched(ouser->uid, ouser->x, ouser->y);
            }
            it++;
        }
        else it++;
    };
    logwarn((LOG, "sc_city_t, update...ok!, resid:%d", resid));
}
//=========================================================
int sc_city_mgr_t::enter_city(uint32_t uid_, sc_msg_def::req_enter_city_t& jpk_,int32_t slience_)
{
    logwarn((LOG, "sc_city_mgr_t, enter_city..., uid:%d, resid:%d", uid_, jpk_.resid));

    sc_msg_def::ret_enter_city_t ret;

    sp_user_t user;
    if (!logic.usermgr().get(uid_, user))
    {
        logerror((LOG, "no user:%d", jpk_.resid));

        ret.code = ERROR_SC_NO_USER;
        if( !slience_ )
            logic.unicast(uid_, ret);
        return ERROR_SC_NO_USER;
    }

    
    //主城
    if (!IS_GANG(jpk_.resid))
    {
        if (repo_mgr.city.get(jpk_.resid) == NULL)
        {
            //logerror((LOG, "repo no city:%d", jpk_.resid));
            ret.code = ERROR_SC_NO_CITY;
            if( !slience_ )
                logic.unicast(uid_, ret);
            return ERROR_SC_NO_CITY;
        }

        if( jpk_.resid != 1999 )
        {
            user->db.sceneid = jpk_.resid;
            //保存到数据库
            db_service.async_do((uint64_t)user->db.sceneid, [](int32_t uid_, int32_t sceneid_){
                char sql[256];
                sprintf(sql, "UPDATE `UserInfo` SET  `sceneid` = %d WHERE  `uid` = %d", sceneid_, uid_);
                db_service.async_execute(sql);
            }, user->db.uid, user->db.sceneid);
        }
    }
    else
    {
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        user->db.sceneid = jpk_.resid;
        if (!gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
        {
            logerror((LOG, "user is not gang user, uid:%d", uid_));
            ret.code = ERROR_SC_NO_CITY;
            if( !slience_ )
                logic.unicast(uid_, ret);
            return ERROR_SC_NO_CITY;
        }
    }

    sp_city_t city;
    if (this->get(user->lastsceneid, city))
    {
        city->del_user(uid_);
    }
    user->lastsceneid = jpk_.resid;

    ret.code = SUCCESS;
    //这里是主城的，公会做好之后这里要改逻辑的，移动到主城的代码段中
    if(user->db.grade >= 5) {
        ret.x = 202 + random_t::rand_integer(0, 84*2) - 84;
        ret.y = 56 + random_t::rand_integer(0, 67*2) - 67;
    }else{
        ret.x = -500 + random_t::rand_integer(0, 10*2) - 84;
        ret.y = -850 + random_t::rand_integer(0, 10*2) - 67;
    }
    ret.sceneid = jpk_.resid;
    if( !slience_ )
        logic.unicast(uid_, ret);

    if (!this->get(jpk_.resid, city))
    {
        city.reset(new sc_city_t(jpk_.resid));
        this->insert(city->resid, city);
    }
    sp_city_user_t cuser = city->add_user(uid_, jpk_.show_player_num);
    city->update(cuser);

    logwarn((LOG, "sc_city_mgr_t, enter_city...ok!, uid:%d, resid:%d", uid_, jpk_.resid));
    
    //记录事件
    statics_ins.unicast_eventlog(*user,jpk_.cmd(),jpk_.resid);

    return SUCCESS;
}
int sc_city_mgr_t::move(sc_msg_def::nt_move_t& jpk_)
{
    sp_user_t user;
    if (!logic.usermgr().get(jpk_.uid, user))
    {
        logerror((LOG, "no user:%d", jpk_.uid));
        return ERROR_SC_NO_USER;
    }

    int32_t resid = jpk_.sceneid;
    logwarn((LOG, "move in city:%d...", jpk_.sceneid));
    sp_city_t city;
    if (!this->get(resid, city))
    {
        //logerror((LOG, "no city:%d", resid));
        return ERROR_SC_NO_CITY;
    }
    sp_city_user_t cuser = city->get_user(jpk_.uid);
    if (cuser == NULL)
    {
        //logerror((LOG, "city:%d no user:%d", resid, jpk_.uid));
        return ERROR_SC_NO_CITY_USER;
    }
    cuser->sync_pos(jpk_.x, jpk_.y);
    logwarn((LOG, "move ...ok"));
    return SUCCESS;
}
int sc_city_mgr_t::get_uid_pos(int32_t uid_, int32_t sceneid_, int32_t& x_, int32_t&y_)
{
    sp_city_t city;
    if (!this->get(sceneid_, city))
    {
        //logerror((LOG, "server no city:%d", sceneid_));
        return ERROR_SC_NO_CITY;
    }
    sp_city_user_t cuser = city->get_user(uid_);
    if (cuser == NULL)
    {
        //logerror((LOG, "server no city user:%d", uid_));
        return ERROR_SC_NO_CITY_USER;
    }
    x_ = cuser->x;
    y_ = cuser->y;
    return SUCCESS;
}
int sc_city_mgr_t::del_uid(int32_t uid_, int32_t sceneid_)
{
    sp_city_t city;
    if (!this->get(sceneid_, city))
    {
        //logerror((LOG, "server no city:%d", sceneid_));
        return ERROR_SC_NO_CITY;
    }
    city->del_user(uid_);
    return SUCCESS;
}
bool sc_city_mgr_t::get(int32_t sceneid_, sp_city_t& city_)
{
    auto it = m_city_hm.find(sceneid_);
    if (it != m_city_hm.end())
    {
        city_ = it->second;
        return true;
    }
    return false; 
}
void sc_city_mgr_t::insert(int32_t sceneid_, sp_city_t city_)
{
    m_city_hm[sceneid_] = city_;
}
void sc_city_mgr_t::unicast(int uid_, uint16_t cmd_, const string& msg_)
{
    logic.unicast(uid_, cmd_, msg_);
}
