#include "sc_boss.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_message.h"
#include "sc_mailinfo.h"
#include "sc_battle_pvp.h"
#include "sc_cache.h"
#include "sc_server.h"
#include "sc_gang.h"

#include "sc_push_def.h"

#include "config.h"
#include "random.h"
#include "date_helper.h"

#include <sys/time.h>

#define LOG "SC_BOSS"

#define SECONDS_DAY 86400
#define SECONDS_8_HOUR 28800
#define SECONDS_7_DAY (SECONDS_DAY*7)

//世界boss每天12点开发一次
#define BASE_TIME_WBOSS_Fri 12
#define BASE_TIME_WBOSS_Sec 20
#define BASE_TIME_WBOSS_Split 16

//公会boss每周某一天的21开放一次
#define BASE_TIME_GBOSS 21

//玩家前5分钟开始准备
#define PREPARE_TIME 5

//每个服务器之间相差10分钟
#define OFFSET_PER_SERVER 0

//boss持续1小时
#define BOSS_LIFE 1

//每两次战斗之间需要间隔43秒
#define SERVER_CD 43 

//世界boss场景
#define SCENE_WB 1999

//公会boss场景
#define SCENE_GB 2999

//公会场景
#define SCENE_GG 2998

//表格索引宏
#define REPO_ID(grade) ((m_flag-1)*10000+grade)

//战斗限制
#define FIGHT_LIMIT 5

#define SCENE_GB_RC 8 //公会boss需要参与人数
#define UB_BT 17 //社团boss场景开始进入时间
#define UB_ET 23 //社团boss场景结束进入时间
/////////////////////////////////////////////
sc_boss_t::sc_boss_t():
    m_spawned(0),
    m_spawne_time(0),
    m_spawne_time2(0),
    m_resid(0),
    m_grade(0),
    m_hp(0),
    m_max_hp(0),
    is_event(0),
    m_damage(0),
    m_flag(0),
    top_cut(0),
    m_cur_count(0),
    m_join_count(0),
    reward60(false),
    reward30(false),
    reward10(false),
    reward0(false),
    is_join_reward(false)
{}

void sc_boss_t::do_user_enter(int32_t uid_,int32_t scene_,const string &nickname_,int32_t sceneid_, int lv_)
{
    auto it = m_damage_hm.find(uid_);
    if(it == m_damage_hm.end())
    {
        it=m_damage_hm.insert(make_pair(uid_,damage_info_t(nickname_))).first;
        it->second.lv = lv_;
        it->second.in_scene = 1;
        it->second.old_scene = scene_;

        sc_msg_def::req_enter_city_t req;
        req.resid = sceneid_;
        req.show_player_num = 20;
        logic.citymgr().enter_city(uid_, req, 1);
        ++m_join_count;
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser) && m_flag == 2)
        {
            sp_guser->db.set_lastboss(date_helper.cur_sec());
            sp_guser->db.set_todaycount(sp_guser->db.todaycount + 1);
            sp_guser->save_db();
            db_GangBossDamage_t db_;
            db_.uid = uid_;
            db_.ggid = sp_guser->db.ggid;
            db_.in_scene = it->second.in_scene;
            db_.damage = it->second.damage;
            db_.last_batt_time = it->second.last_batt_time;
            db_.old_scene = it->second.old_scene;
            db_.nickname = nickname_;
            db_.lv = it->second.lv;
            db_service.async_do((uint64_t)sp_guser->db.ggid,[](db_GangBossDamage_t& db){
                db.insert();
            },db_);
        }
        ++m_cur_count;
    }
}

void sc_boss_t::do_user_leave(int32_t uid_)
{
    auto it = m_damage_hm.find(uid_);
    if( it == m_damage_hm.end() )
        return ;
    it->second.in_scene = 0;
    if (2 == m_flag){
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
            save_damage_db(uid_,sp_guser->db.ggid,it->second); 
    }
    sc_msg_def::req_enter_city_t req;
    req.resid = it->second.old_scene;
    req.show_player_num = 20;
    logic.citymgr().enter_city(uid_, req, 1);
    sc_msg_def::ret_boss_leave_scene ret;
    ret.sceneid = it->second.old_scene;
    ret.x = -300;
    ret.y = -100;
    logic.unicast(uid_,ret);

    if(ret.sceneid != SCENE_GB)
        --m_cur_count;
}
void sc_boss_t::save_damage_db(int32_t uid_,int32_t ggid_, damage_info_t& d_info)
{ 
    db_GangBossDamage_t db_;
    db_.uid = uid_;
    db_.ggid = ggid_;
    db_.in_scene = d_info.in_scene;
    db_.damage = d_info.damage;
    db_.last_batt_time = d_info.last_batt_time;
    db_.old_scene = d_info.old_scene;
    db_.nickname = d_info.nickname;
    db_.lv = d_info.lv;
    db_service.async_do((uint64_t)ggid_,[](db_GangBossDamage_t& db){
            db.update();
            },db_);
}
int32_t sc_boss_t::get_last_batt_time(int32_t uid_)
{
    auto it = m_damage_hm.find(uid_);
    if( it == m_damage_hm.end() )
        return 0;
    else
        return it->second.last_batt_time;
}
int32_t sc_boss_t::set_last_batt_time(int32_t uid_,uint32_t bt_)
{
    auto it = m_damage_hm.find(uid_);
    if( it == m_damage_hm.end() )
        return -1;
    it->second.last_batt_time=bt_;

    if (m_flag == 2)
    {
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
        {
            sp_guser->db.set_lastboss(date_helper.cur_sec());
            sp_guser->save_db();
            save_damage_db(uid_,sp_guser->db.ggid,it->second);
        }
    }
    return 0;
}

bool damage_compare(sc_msg_def::jpk_dmg_info_t a, sc_msg_def::jpk_dmg_info_t b)
{
    return a.damage > b.damage;
}

int32_t sc_boss_t::update_damage(int32_t uid_,int32_t damage_)
{
    logerror((LOG, "UPDATE_DAMAGE uid = %d, damage = %d", uid_, damage_));
    //更新伤害
    auto it = m_damage_hm.find(uid_);
    if( it == m_damage_hm.end() )
        return -1;
    sp_user_t user;
    if(logic.usermgr().get(uid_,user))
    {
        //不在线则不增加
        int fp = user->get_total_fp();
        logerror((LOG, "UPDATE_DAMAGE GET_FP, fp = %d, hp = %d", fp, m_hp));
        if(damage_ > fp * 50)
        {
            //伤害作弊
            logerror((LOG, "UPDATE_DAMAGE BINGO"));
            return floor(m_hp*1.0/m_max_hp*100);
        }

        if((float)m_hp/(float)m_max_hp<=0.1f && m_flag == 1)
        {
            damage_ = damage_ * random_t::rand_integer(20, 100) / 100.0;
        }

        it->second.damage+=damage_;
        if (m_flag == 2){
            sp_gang_t sp_gang;
            sp_ganguser_t sp_guser;
            if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
                save_damage_db(uid_,sp_guser->db.ggid,it->second);
        }
        m_damage+=damage_;

        //更新boss血量
        m_hp -= damage_;
    }
    if((!is_event) && (float)m_hp/(float)m_max_hp<=0.1f && (float)m_hp/(float)m_max_hp>0.0f)
    {
        switch(m_flag)
        {
            case 1:
            {
                //string msg = pushinfo.get_push(push_worldboss_lowhp,m_resid);
                //pushinfo.push(msg);
            }
            break;
            case 2:
            {
                //string msg = pushinfo.get_push(push_gangboss_lowhp,m_resid);
                //pushinfo.push_gang(uid_, msg);
            }
            break;
        }
        is_event = 1;
    }

    if( m_hp <= 0 )
    {
        m_hp = 0;
        m_spawned = 0;
        is_event = 0;
    }

    //更新前十排行榜
    auto it_v = top.begin();
    for(;it_v!=top.end();++it_v)
        if(it_v->uid == it->first) break;

    if( it_v == top.end() )
    {
        if( top.size() < 10 )
        {
            sc_msg_def::jpk_dmg_info_t d;
            d.uid = it->first;
            d.damage = it->second.damage;
            d.lv = it->second.lv;
            d.nickname = it->second.nickname;
            top.push_back( std::move(d) );
        }
        else if( it->second.damage > top_cut )
        {
            top[9].damage = it->second.damage;
            top[9].uid = it->first;
            top[9].lv = it->second.lv;
            top[9].nickname = it->second.nickname;
        }
    }
    else it_v->damage = it->second.damage;

    //重新排序
    sort( top.begin(),top.end(),damage_compare );
    if( 10 == top.size() )
        top_cut = top[9].damage;
    if (m_flag == 2){
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
            gang_boss_mgr.m_mgr[sp_guser->db.ggid]->save_db(sp_guser->db.ggid);
    }
    return floor(m_hp*1.0/m_max_hp*100);
}

//lv_:      boss等级
int32_t sc_boss_t::boss_spawn(int32_t lv_, int tag)
{
    //生成boss resid
    if( tag == 1 )
    {
        //世界boss
        m_resid = 99999;
    }
    else if( tag == 2 )
    {
        //公会boss
        m_resid = 99998;
    }
    //if( 1==m_flag )
    //    m_resid-=random_t::rand_integer(1,4);
    //获取boss等级
    m_grade = lv_;
    //获取boss血量
    
    if( tag == 1)
    {
        auto it = repo_mgr.worldboss.find(m_grade);
        if( it == repo_mgr.worldboss.end() )
        {
            logerror((LOG, "on_boss_spawn, worldboss repo no grade:%d", m_grade));
            return -1;
        }
        m_max_hp = m_hp = it->second.hp;
    }
    else if( tag == 2 )
    {
        auto it = repo_mgr.unionboss.find(m_grade);
        if( it == repo_mgr.unionboss.end() )
        {
            logerror((LOG, "on_boss_spawn, unionboss repo no grade:%d", m_grade));
            return -1;
        }
        m_max_hp = m_hp = it->second.hp;
    }

    //初始化伤害列表和排行榜
    m_damage_hm.clear();
    top.clear();
    top_cut = 0;
    m_damage=0;

    m_spawned = 1;
    if(date_helper.secoffday() < BASE_TIME_WBOSS_Split*3600)
        m_spawne_time = date_helper.cur_sec();
    else
        m_spawne_time2 = date_helper.cur_sec();

    m_cur_count = 0;
    reward60 = false;
    reward30 = false;
    reward10 = false;
    reward0 = false;

    return 0;
}

int32_t sc_boss_t::boss_gone(int32_t uid_)
{
    m_hp = m_spawned = is_event = 0;

    sc_msg_def::nt_boss_go_t ret;
    ret.flag = m_flag;
    ret.die = uid_;

    string message;
    if( 0==uid_ )
    {
        ret.die = 0;
        switch(m_flag)
        {
        case 1:
            {
            //string msg = pushinfo.get_push(push_worldboss_escaped,m_resid);
            //pushinfo.push(msg);
            }
            break;
        case 2:
            {
            //string msg = pushinfo.get_push(push_gangboss_escaped,m_resid);
            //pushinfo.push_gang(uid_, msg);
            }
            break;
        }
        ret >> message;
    }
    else
    {
        ret.die = 1;
        //发送事件
        sp_user_t user;
        if( logic.usermgr().get(uid_,user) || cache.get(uid_, user) )
        {
            //发送事件
            switch(m_flag)
            {
            case 1:
                {
                    vector<sc_msg_def::jpk_dmg_info_t> rank;
                    //获取伤害最高的玩家
                    get_rank(1,rank);   
                    
                    string nickname = "";
                    int32_t grade = 0;
                    int32_t uid = 0;
                    int32_t viplevel = 0;
                    
                    if (rank.size() > 0)
                    {
                        nickname = rank[0].nickname;
                        uid = rank[0].uid;
                        grade = rank[0].lv;

                        sql_result_t res;
                        char sql[256];
                        sprintf(sql, "select viplevel from UserInfo where uid = %d", uid);
                        db_service.sync_select(sql, res);
                        if (0 != res.affect_row_num()) 
                        {
                            sql_result_row_t &row = *res.get_row_at(0);
                            viplevel = (int)std::atoi(row[0].c_str());
                        }
                    }
                    /*
                    string msg = pushinfo.get_push(push_worldboss_killed,
                        nickname,
                        grade,
                        uid,
                        viplevel,
                        user->db.nickname(),
                        user->db.grade,
                        user->db.uid,
                        user->db.viplevel,
                        m_resid);
                    pushinfo.push(msg);
                    */
                }
                break;
            case 2:
                {
                    /*
                    string msg = pushinfo.get_push(push_gangboss_killed,
                        user->db.nickname(),
                        user->db.grade,
                        user->db.uid,
                        user->db.viplevel,
                        m_resid);
                    pushinfo.push_gang(uid_, msg);
                    */
                }
                break;
            }
        }
        ret >> message;
    }

    switch(m_flag)
    {
    case 1:
        logic.usermgr().broadcast( sc_msg_def::nt_boss_go_t::cmd(),message );
        break;
    case 2:
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser)){
            sp_gang->broadcast( sc_msg_def::nt_boss_go_t::cmd(),message );
            gang_boss_mgr.m_mgr[sp_guser->db.ggid]->save_db(sp_guser->db.ggid);
        }
        break;
    }

    return 0;
}

void sc_boss_t::boss_grow_up(int32_t uid_, uint32_t cur_sec_)
{
    int32_t life = cur_sec_ - m_spawne_time - 300;
    if(date_helper.secoffday() > BASE_TIME_WBOSS_Split * 3600)
        life = cur_sec_ - m_spawne_time2 - 300;
    bool change = life < 300 ? true : false;
    if (change)
    {
        bool find_boss = false;
        m_grade += life < 60 ? 3 : life < 180 ? 2 : life < 300 ? 1 : 0;
        switch(m_flag)
        {
        case 1:
            while(not find_boss)
            {
                auto it = repo_mgr.worldboss.find(m_grade);
                if( it == repo_mgr.worldboss.end() ){
                    m_grade--;
                }
                else
                {
                    find_boss = true;
                }
            }
            server.db.set_bosslv(m_grade);
            server.save_db();
            break;
        case 2:
            while(not find_boss)
            {
                auto it = repo_mgr.unionboss.find(m_grade);
                if( it == repo_mgr.unionboss.end() ){
                    m_grade--;
                }
                else
                {
                    find_boss = true;
                }
            }
            sp_gang_t sp_gang;
            sp_ganguser_t sp_guser;
            if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
            {
                sp_gang->db.set_bosslv(m_grade);
                sp_gang->save_db();
            }
            break;
        }
    }
}

void sc_boss_t::req_damage_rank(int32_t uid_)
{
    sc_msg_def::ret_dmg_ranking_t ret;
    ret.flag = m_flag;
    ret.damage = m_damage;
    ret.rank = top;
    ret.count = m_cur_count;
    ret.join_count = m_join_count;

    auto it=m_damage_hm.find(uid_);
    if( it!=m_damage_hm.end() )
    {
        sc_msg_def::jpk_dmg_info_t d;
        d.damage = it->second.damage;
        d.lv = it->second.lv;
        d.uid = uid_;
        d.nickname = it->second.nickname;
        ret.rank.push_back( std::move(d) );
    }

    logic.unicast(uid_, ret);
}

void sc_boss_t::get_rank(int32_t count_, vector<sc_msg_def::jpk_dmg_info_t> &rank_)
{
    multimap<int32_t,sc_msg_def::jpk_dmg_info_t> rank_mmap;

    auto it=m_damage_hm.begin();
    for(;it!=m_damage_hm.end();++it)
    {
        if( it->second.damage == 0 )
            continue;

        sc_msg_def::jpk_dmg_info_t d;
        d.damage = it->second.damage;
        d.lv = it->second.lv;
        d.uid = it->first;
        d.nickname = it->second.nickname;
        rank_mmap.insert(make_pair(it->second.damage,std::move(d)));
    }
    int32_t i = 0;
    auto it_mmap=rank_mmap.rbegin();
    for(;it_mmap!=rank_mmap.rend();++it_mmap)
    {
        rank_.push_back( std::move(it_mmap->second) );
        ++i;
        if( count_ == i )
            break;
    }
}

/////////////////////////////////////////////
sc_world_boss_t::sc_world_boss_t()
{
    m_flag = 1;
    //获取当前服务器boss的出生漂移时间
    m_start=OFFSET_PER_SERVER*60+BASE_TIME_WBOSS_Fri*3600;
    m_end=m_start + BOSS_LIFE * 3600;
    m_prepare=m_start - PREPARE_TIME*60;
}
void sc_world_boss_t::get_startime(int32_t &start_)
{
    start_ = m_start;
}

void sc_world_boss_t::update_boss_time()
{
    uint32_t sec_drift = date_helper.secoffday();
    if (sec_drift <= BASE_TIME_WBOSS_Split * 3600)   
        m_start= OFFSET_PER_SERVER*60+BASE_TIME_WBOSS_Fri*3600;
    else
        m_start= OFFSET_PER_SERVER*60+BASE_TIME_WBOSS_Sec*3600;
    m_end=m_start + BOSS_LIFE * 3600;
    m_prepare=m_start - PREPARE_TIME*60;
}
int32_t sc_world_boss_t::is_boss_available()
{
    update_boss_time();
    //获得今日凌晨十二点的时间戳
    int32_t cur = date_helper.cur_sec();
    uint32_t sec_drift = date_helper.secoffday();
    //判断是否已开boss
    if (sec_drift <= BASE_TIME_WBOSS_Split * 3600)   
    {
        if (cur <= date_helper.cur_0_stmp() + BASE_TIME_WBOSS_Fri * 3600 || cur > date_helper.cur_0_stmp() + (BASE_TIME_WBOSS_Fri + BOSS_LIFE) * 3600) 
            return 1;
    }
    else
    {
        //判断是否已开boss
        if (cur <= date_helper.cur_0_stmp() + BASE_TIME_WBOSS_Sec * 3600 || cur > date_helper.cur_0_stmp() + (BASE_TIME_WBOSS_Sec + BOSS_LIFE) * 3600) 
            return 1;
    }
    //boss的出生时间是昨天
    if (cur < date_helper.cur_0_stmp() + (BASE_TIME_WBOSS_Fri + BOSS_LIFE) * 3600)
        return 2;

    //boss是否已经被打死
    if (!m_spawned )
        return 3;
    
    return 2;
}

void sc_world_boss_t::set_boss_available()
{
    m_end = m_start + 11 * 3600;
    server.db.set_wbcut(date_helper.cur_0_stmp());
    m_spawne_time = date_helper.cur_0_stmp() - 300;
    m_spawned = 0;
}

int32_t sc_world_boss_t::is_battle_stage(sp_user_t user_)
{
    update_boss_time();

    switch(m_flag)
    {
    case 1:
    {
        uint32_t base = date_helper.cur_0_stmp();
        uint32_t cur = date_helper.cur_sec();
        user_->update_guwu(m_flag, (base+m_start) - PREPARE_TIME*60, (base+m_end));
        if( ((base+m_start)<=cur) && (cur<=(base+m_end)) )
            return 1;
    }
    break;
    case 2:
    {
        uint32_t curlocalsec = date_helper.cur_sec();
        user_->update_guwu(m_flag, m_start , m_end);
        return (m_start <= curlocalsec && curlocalsec <= m_end);
    }
    break;
    }
    return 0;
}

void sc_world_boss_t::get_boss_state(int32_t uid_, int32_t scene_, int32_t grade_, const string &nickname_)
{
    update_boss_time();
    sc_msg_def::ret_boss_state_t ret;
    ret.flag= m_flag;
    ret.sceneid = SCENE_WB;
    ret.resid = 0;
    ret.cd = 0;
    ret.hp = 0;
    ret.x = -300;
    ret.y = -100;
    ret.bosslv = server.db.bosslv;
    ret.revieve_times = 0;

    sp_user_t user;
    if( logic.usermgr().get(uid_,user) || cache.get(uid_, user) )
    {
        ret.revieve_times = user->vip.get_num_count(vop_immedia_fight_wboss);
    }

    //该玩家等级是否足够
    if( grade_ < 23 )
    {
        ret.state = 4;
        logic.unicast(uid_, ret);
        return;
    }

    //获取当前时间相对当天00:00的漂移秒数
    uint32_t sec_drift = date_helper.secoffday();
    //处于准备时间
    if( (sec_drift>=m_prepare)&&(sec_drift<m_start) )
    {
        //boss出生
        if( !m_spawned )
        {
            boss_spawn(server.db.bosslv, 1);
        }
        else
        {
            if( date_helper.offday(m_spawne_time) >= 1 && date_helper.secoffday() < BASE_TIME_WBOSS_Split*3600 )
            {

                boss_spawn(server.db.bosslv, 1);
            }
            else if( date_helper.offday(m_spawne_time2) >= 1 && date_helper.secoffday() > BASE_TIME_WBOSS_Split*3600 )
            {

                boss_spawn(server.db.bosslv, 1);
            }

        }
        //玩家进入准备状态
        do_user_enter(uid_,scene_,nickname_,SCENE_WB, grade_);

        //初始化返回数据
        ret.state = 1;
        ret.resid = m_resid;
        ret.cd = m_start - sec_drift;
        ret.hp = m_max_hp;
        ret.boss_leave_time = m_end - sec_drift;

        logic.unicast(uid_, ret);
        return;
    }
    //处于开始时间
    if( (sec_drift>=m_start)&&(sec_drift<m_end) )
    {
        if( !m_spawned )
        {
            if( date_helper.offday(m_spawne_time) >= 1 && date_helper.secoffday() < BASE_TIME_WBOSS_Split*3600 )
            {
                //boss尚未出生
                boss_spawn(server.db.bosslv, 1);
            }
            else if( date_helper.offday(m_spawne_time2) >= 1 && date_helper.secoffday() >  BASE_TIME_WBOSS_Split*3600 )
            {
                //boss尚未出生
                boss_spawn(server.db.bosslv, 1);
            }
            else
            {
                //boss已被打死
                ret.state=6;
                logic.unicast(uid_, ret);
                return;
            }
        }
        else
        {
            if( date_helper.offday(m_spawne_time) >= 1 && date_helper.secoffday() < BASE_TIME_WBOSS_Split*3600 )
            {

                boss_spawn(server.db.bosslv, 1);
            }
            else if( date_helper.offday(m_spawne_time2) >= 1 && date_helper.secoffday() > BASE_TIME_WBOSS_Split*3600 )
            {

                boss_spawn(server.db.bosslv, 1);
            }

        }

        ret.state = 2;
        ret.resid = m_resid;
        int32_t delta = date_helper.cur_sec()-get_last_batt_time(uid_);
        if(delta>SERVER_CD)
            ret.cd = 0;
        else
            ret.cd = SERVER_CD-delta;
        //vip4开始无cd
        if(user->db.viplevel >= 4)
            ret.cd = 0;
        ret.boss_leave_time = m_end - sec_drift;
        ret.hp = m_max_hp;
        logic.unicast(uid_, ret);
        
        //玩家进入准备状态
        do_user_enter(uid_,scene_,nickname_,SCENE_WB, grade_);

        return;
    }
    //不在时间段
    ret.state=0;
    logic.unicast(uid_, ret);
}

void sc_world_boss_t::enter_battle(sp_user_t user_,int32_t uid_,int32_t fee_)
{
    update_boss_time();
    sc_msg_def::ret_boss_start_batt_fail_t fail;
    fail.flag = m_flag;

    //是否在时间段
    if( !is_battle_stage(user_) )
    {
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(uid_, fail);
        return ;
    }

    //boss是否已经死亡
    if( !m_spawned )
    {
        logerror((LOG, "on_enter_battle, boss dead:%d", m_spawned));
        fail.code = ERROR_SC_BOSS_DEAD;
        logic.unicast(uid_, fail);
        return ;
    }

    //boss是否逃匿
    uint32_t sec_drift = 0;
    switch(m_flag)
    {
    case 1:
        sec_drift = date_helper.secoffday();
    break;
    case 2:
        sec_drift = date_helper.cur_sec();
    break;
    }

    if( sec_drift>m_end )
    {
        logerror((LOG, "on_enter_battle, boss run!"));
        boss_gone(0);
        sc_msg_def::ret_boss_start_batt_fail_t fail;
        fail.code = ERROR_SC_BOSS_DEAD;
        fail.flag = m_flag;
        logic.unicast(uid_, fail);
        return ;
    }

    int cur_sec = date_helper.cur_sec();

    //判断cd时间
    int32_t delta = cur_sec-get_last_batt_time(uid_);
    if( delta < FIGHT_LIMIT)
    {
        sc_msg_def::ret_boss_start_batt_fail_t fail;
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(uid_, fail);
        return;
    }

    sc_msg_def::ret_boss_start_batt_t ret;
    ret.revieve_times = 0;
    //是否收费
    if( fee_ )
    {
        int32_t code = user_->vip.buy_vip(vop_immedia_fight_wboss);
        if (code != SUCCESS)
        {
            sc_msg_def::ret_boss_start_batt_fail_t fail;
            fail.code = code;
            fail.flag = m_flag;
            logic.unicast(uid_, fail);
            return;
        }
        ret.revieve_times = user_->vip.get_num_count(vop_immedia_fight_wboss);
    }
    else
    {
        //判断cd时间
        int32_t delta = cur_sec-get_last_batt_time(uid_);
        if( delta < SERVER_CD && user_->db.viplevel < 4 )
        {
            sc_msg_def::ret_boss_start_batt_fail_t fail;
            fail.code = ERROR_SC_NOT_ENOUGH_TIME;
            fail.cd = SERVER_CD-delta;
            fail.flag = m_flag;
            logic.unicast(uid_, fail);
            return;
        }
    }
    set_last_batt_time(uid_,cur_sec);

    sc_msg_def::jpk_skill_t skill;
    auto it_sk=repo_mgr.monster.find(m_resid);
    if( it_sk==repo_mgr.monster.end() )
        return;
    skill.resid = it_sk->second.skill;
    if( m_flag == 1)
    {
        auto it = repo_mgr.worldboss.find(m_grade);
        if( it == repo_mgr.worldboss.end() )
        {
            return;
        }
        ret.boss.pro.atk = it->second.atk;
        ret.boss.pro.mgc = it->second.mgc;
        ret.boss.pro.def = it->second.def;
        ret.boss.pro.res = it->second.res;
        ret.boss.pro.cri = it->second.critical;
        ret.boss.pro.acc = it->second.accuracy;
        ret.boss.pro.dodge = it->second.dodge;
        skill.level = it->second.skill_lv;
    }
    else if( m_flag == 2 )
    {
        auto it = repo_mgr.unionboss.find(m_grade);
        if( it == repo_mgr.unionboss.end() )
        {
            return;
        }
        ret.boss.pro.atk = it->second.atk;
        ret.boss.pro.mgc = it->second.mgc;
        ret.boss.pro.def = it->second.def;
        ret.boss.pro.res = it->second.res;
        ret.boss.pro.cri = it->second.critical;
        ret.boss.pro.acc = it->second.accuracy;
        ret.boss.pro.dodge = it->second.dodge;
        skill.level = 1;
    }

    ret.flag = m_flag;
    ret.boss.resid = m_resid;
    ret.boss.lvl.level = m_grade;
    ret.boss.pro.hp = m_hp;
    ret.boss.pro.ten = 0;
    ret.boss.pro.imm_dam_pro = 0;
    ret.boss.pro.factor.push_back(1);
    ret.boss.pro.factor.push_back(1);
    ret.boss.pro.factor.push_back(1);
    ret.boss.pro.factor.push_back(1);
    ret.boss.pro.factor.push_back(1);
    ret.boss.pro.factor.push_back(1);
    ret.boss.skls.push_back( std::move(skill) );

    user_->m_fight_boss_time = date_helper.cur_sec() % 3600;

    logic.unicast(uid_, ret);
}

int32_t sc_world_boss_t::exit_battle(sp_user_t user_, sc_msg_def::req_boss_end_batt_t &jpk_, sc_msg_def::ret_boss_end_batt_t &ret)
{
    //校验时间
    int cur_time = date_helper.cur_sec() % 3600;
    if( cur_time < user_->m_fight_boss_time )
        cur_time += 3600;
    if( cur_time - user_->m_fight_boss_time <= 2 )
        return FAILED;
    //更新玩家战斗伤害
    int32_t uid_ = user_->db.uid;
    int32_t before_hp_per = floor(m_hp*1.0/m_max_hp*100);
    int32_t after_hp_per = update_damage(uid_, (int32_t)jpk_.damage);
    if( jpk_.flag == 1)
    {
        auto it = repo_mgr.worldboss.find(m_grade);
        if( it == repo_mgr.worldboss.end() )
        {
            return FAILED;
        }
        ret.gold = it->second.gold_join;
        user_->on_money_change(ret.gold);
        user_->save_db();

        user_->daily_task.on_event(evt_world_boss);
        ret.flag = jpk_.flag;
    
        // 60, 30, 10, 0 策划说的，呵呵, 小于（以下）
        if (!reward60 && 60 > after_hp_per && before_hp_per >= 60)
        {
            reward60 = true;
            send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
        }
        else if (!reward30 && 30 > after_hp_per && before_hp_per >= 30)
        {
            reward30 = true;
            if (!reward60 && before_hp_per >= 60) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
            }
            send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
        }
        else if (reward10 == false && 10 > after_hp_per && before_hp_per >= 10)
        {
            reward10 = true;
            if (!reward60 && before_hp_per >= 60) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
            }
            if (!reward30 && before_hp_per >= 30) {
                reward30 = false;
                send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
            }
            send_satge_reward(uid_, it->second.gold_kill[3], it->second.item_kill[3]);
        } 
        
        if(reward0 == false && 0 == after_hp_per)
        {
            reward0 = true;
            int cur_sec = date_helper.cur_sec();
            boss_grow_up(uid_, cur_sec);

            if (!reward60 && before_hp_per >= 60) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
            }
            if (!reward30 && before_hp_per >= 30) {
                reward30 = true;
                send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
            }
            if (!reward10 && before_hp_per >= 10) {
                reward10 = true;
                send_satge_reward(uid_, it->second.gold_kill[3], it->second.item_kill[3]);
            }
            send_satge_reward(uid_, it->second.gold_kill[4], it->second.item_kill[4]);
            
            //全服公告
            boss_gone(uid_);
            //发送伤害排名
            unicast_top10();
            //参与奖励
            join_reward();
            //排名奖励
            rank_reward();

            //重置鼓舞
            guwu_mgr.clean_guwu(1);
        }
    }
    else if( jpk_.flag == 2 )
    {
        auto it = repo_mgr.unionboss.find(m_grade);
        if( it == repo_mgr.unionboss.end() )
        {
            return FAILED;
        }
        ret.gold = it->second.join_coin;
        user_->on_money_change(ret.gold);
        user_->save_db();

        ret.flag = jpk_.flag;
        if (!reward60 && 75 > after_hp_per && before_hp_per >= 75)
        {
            reward60 = true;
            send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
            send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),75); 
            gang_boss_mgr.m_mgr[gang_mgr.get_ggid_by_uid(uid_)]->save_db(gang_mgr.get_ggid_by_uid(uid_));
        }
        else if (!reward30 && 50 > after_hp_per && before_hp_per >= 50)
        {
            reward30 = true;
            if (!reward60 && before_hp_per >= 75) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
            send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),75); 
            }
            send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
            send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),50); 
            gang_boss_mgr.m_mgr[gang_mgr.get_ggid_by_uid(uid_)]->save_db(gang_mgr.get_ggid_by_uid(uid_));
        }
        else if (reward10 == false && 25 > after_hp_per && before_hp_per >= 25)
        {
            reward10 = true;
            if (!reward60 && before_hp_per >= 75) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
                send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),75); 
            }
            if (!reward30 && before_hp_per >= 50) {
                reward30 = false;
                send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
                send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),50); 
            }
            send_satge_reward(uid_, it->second.gold_kill[3], it->second.item_kill[3]);
            send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),25); 
            gang_boss_mgr.m_mgr[gang_mgr.get_ggid_by_uid(uid_)]->save_db(gang_mgr.get_ggid_by_uid(uid_));
        } 
               
        if(reward0 == false && 0 == after_hp_per)
        {
            reward0 = true;
            int cur_sec = date_helper.cur_sec();
            boss_grow_up(uid_, cur_sec);

            if (!reward60 && before_hp_per >= 75) {
                reward60 = true;
                send_satge_reward(uid_, it->second.gold_kill[1], it->second.item_kill[1]);
                send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),75); 
            }
            if (!reward30 && before_hp_per >= 50) {
                reward30 = true;
                send_satge_reward(uid_, it->second.gold_kill[2], it->second.item_kill[2]);
                send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),50); 
            }
            if (!reward10 && before_hp_per >= 25) {
                reward10 = true;
                send_satge_reward(uid_, it->second.gold_kill[3], it->second.item_kill[3]);
                send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),25); 
            }
            send_satge_reward(uid_, it->second.gold_kill[4], it->second.item_kill[4]);
            send_gang_boss_reward(gang_mgr.get_ggid_by_uid(uid_),1); 
            
            //全服公告
            boss_gone(uid_);
            //发送伤害排名
            unicast_top10();
            //参与奖励
            join_reward();
            is_join_reward = true;
            gang_boss_mgr.m_mgr[gang_mgr.get_ggid_by_uid(uid_)]->save_db(gang_mgr.get_ggid_by_uid(uid_));
            //排名奖励
            rank_reward();

            //重置鼓舞
            guwu_mgr.clean_guwu(2);
        }
    }
    //cout << endl << "is_win = " << jpk_.is_win << " salt = " << jpk_.salt << " damage = " << (int32_t)jpk_.damage << " cur_hp = " << m_hp << " max_hp = " << m_max_hp << endl;

    return SUCCESS;
}
int32_t sc_world_boss_t::send_gang_boss_reward(int32_t ggid_,int32_t percent_)
{
    sc_gmail_mgr_t::begin_offmail();
    char sql[128]; 
    sprintf(sql, "select uid from GangUser where ggid = %d", ggid_);  
    sql_result_t res;
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i){
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "send_gang_boss_reward get row is NULL!, at:%lu", i));
            continue;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t uid  = (int32_t)std::atoi(row_[0].c_str());
        auto gbreward = repo_mgr.guildboss_reward.get(percent_);
        if (gbreward == NULL){
            logerror((LOG,"send_gang_boss_reward ,repo no item reward"));
            return -1;
        };
        sc_msg_def::nt_bag_change_t nt;
        for (size_t j = 1 ; j < gbreward->reward_item.size();++j){
            logerror((LOG,"send_gang_boss_reward , reward num = %lu", j));
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = gbreward->reward_item[j][0];
            item_.num = gbreward->reward_item[j][1];
            nt.items.push_back(item_);
        }
        string msg;
        int32_t mail_type;
        if (percent_ == 1){
            mail_type = mail_guildboss_kill_reward; 
            msg = mailinfo.new_mail( mail_type);
        }
        else{
            mail_type = mail_guildboss_reward; 
            msg = mailinfo.new_mail( mail_type,percent_);
        }
        auto rp_gmail = mailinfo.get_repo(mail_type);//阶段奖励
        if (rp_gmail != NULL){
            sp_gang_t sp_gang;
            sp_ganguser_t sp_guser;

            if (gang_mgr.get_gang_by_uid(uid, sp_gang, sp_guser))
            {
                int rewardtime = sp_guser->db.bossrewardtime;
                int curweek = (date_helper.cur_sec()-SECONDS_DAY*4) / SECONDS_7_DAY;
                int lastweek = (rewardtime-SECONDS_DAY*4) / SECONDS_7_DAY;
                if(curweek > lastweek){
                    sp_guser->db.bossrewardcount = 0;
                }
                if (sp_guser->db.bossrewardcount < 28){
                    sp_guser->db.set_bossrewardcount(sp_guser->db.bossrewardcount+1);
                    sp_guser->db.set_bossrewardtime(date_helper.cur_sec());
                    sp_guser->save_db();
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                }
            }
        }
    }
    sc_gmail_mgr_t::do_offmail();

}
int32_t sc_world_boss_t::send_satge_reward(int32_t uid_, int32_t gold_, int32_t reward_id_)
{
    sc_msg_def::nt_bag_change_t nt;
    sc_msg_def::jpk_item_t itm;
    itm.itid = 0;
    itm.resid = 10001;
    itm.num = gold_;
    nt.items.push_back(itm);

    if( m_flag == 1)
    {
        auto ritems = repo_mgr.boss_reward.find(reward_id_);
        if (ritems == repo_mgr.boss_reward.end())
        {
            logerror((LOG, "send_satge_reward, repo no item reward"));
            return -1;
        }
        for (size_t i = 1; i < ritems->second.reward_item.size(); ++i)
        {
            itm.itid = 0;
            itm.resid = ritems->second.reward_item[i][0];
            itm.num = ritems->second.reward_item[i][1];
            nt.items.push_back(itm);
        }
    }
    else if( m_flag == 2)
    {
        auto ritems = repo_mgr.unionboss_reward.find(reward_id_);
        if (ritems == repo_mgr.unionboss_reward.end())
        {
            logerror((LOG, "send_satge_reward, repo no item reward"));
            return -1;
        }
        for (size_t i = 1; i < ritems->second.reward_item.size(); ++i)
        {
            itm.itid = 0;
            itm.resid = ritems->second.reward_item[i][0];
            itm.num = ritems->second.reward_item[i][1];
            nt.items.push_back(itm);
        }
    }
    sp_user_t user;
    if (logic.usermgr().get(uid_, user) || cache.get(uid_, user))
    {
        string msg;
        if( m_flag == 1)
        {
            msg = mailinfo.new_mail(mail_worldboss_stage_hit, gold_);
            auto rp_gmail = mailinfo.get_repo(mail_worldboss_stage_hit);
            if (rp_gmail != NULL)
                user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
        }
        else if( m_flag == 2)
        {
            msg = mailinfo.new_mail(mail_gangboss_kill, gold_);
            auto rp_gmail = mailinfo.get_repo(mail_gangboss_kill);//阶段奖励
            if (rp_gmail != NULL)
                user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
        }
    }
    return 0;
}
void sc_world_boss_t::unicast_top10()
{
    sc_msg_def::nt_dmg_ranking_t ret;
    ret.flag = m_flag;
    ret.damage = m_damage;
    ret.rank = top;
    ret.resid = m_resid;

    sc_msg_def::jpk_rank_reward_t reward;
    
    auto it=repo_mgr.worldboss.find( REPO_ID(m_grade) );
    if( it == repo_mgr.worldboss.end() )
        return;
    if( it->second.item_rank.size() != 11 )
        return;

    int uid = 0;
    for( size_t i = 0; i<=9; ++i )
    {
        if( i>=3 && i<=9 )
        {
            reward.gold = it->second.gold_rank4;
            //reward.battlexp = it->second.btp_rank4;
            reward.item = it->second.item_rank[i+1];
            ret.reward.push_back(std::move(reward));
        }
        else if( 2==i )
        {
            reward.gold = it->second.gold_rank3;
            //reward.battlexp = it->second.btp_rank3;
            reward.item = it->second.item_rank[i+1];
            ret.reward.push_back(std::move(reward));
        }
        else if( 1==i )
        {
            reward.gold = it->second.gold_rank2;
            //reward.battlexp = it->second.btp_rank2;
            reward.item = it->second.item_rank[i+1];
            ret.reward.push_back(std::move(reward));
        }
        else
        {
            uid = ret.rank[0].uid;
            reward.gold = it->second.gold_rank1;
            //reward.battlexp = it->second.btp_rank1;
            reward.item = it->second.item_rank[i+1];
            ret.reward.push_back(std::move(reward));
        }
    }

    string message;
    ret >> message;
    switch(m_flag)
    {
    case 1:
        logic.usermgr().broadcast( sc_msg_def::nt_dmg_ranking_t::cmd(),message );
    break;
    case 2:
    {
        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid, sp_gang, sp_guser))
        {
            sp_gang->broadcast( sc_msg_def::nt_dmg_ranking_t::cmd(),message );
        }
    }
    break;
    }
}
void sc_world_boss_t::join_reward()
{
    auto it=repo_mgr.worldboss.find( m_grade );
    if( it== repo_mgr.worldboss.end() )
        return;
    auto it2=repo_mgr.unionboss.find( m_grade );
    if( it2== repo_mgr.unionboss.end() )
        return;
    int32_t item;
    if ( m_flag == 1)
    {
        item = it->second.item_join;
    }
    else if( m_flag == 2)
    {
        item = it2->second.item_join;
    }
    auto rd = repo_mgr.boss_reward.find(item);
    if (rd == repo_mgr.boss_reward.end())
        return;
    auto rd2 = repo_mgr.unionboss_reward.find(item);
    if (rd2 == repo_mgr.unionboss_reward.end())
        return;

    sc_gmail_mgr_t::begin_offmail();
    for(auto it=m_damage_hm.begin();it!=m_damage_hm.end();++it)
    {
        int32_t uid=it->first;
        sp_user_t user;
        if( logic.usermgr().get(uid, user) || cache.get(uid, user) )
        {
            logerror((LOG, "world boss join reward , uid = %d",uid));
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t itm;
            if( m_flag == 1)
            {
                size_t size = rd->second.reward_item.size();
                for (size_t i = 1; i < size; ++i)
                {
                    itm.itid = 0;
                    itm.resid = rd->second.reward_item[i][0];
                    itm.num = rd->second.reward_item[i][1];
                    nt.items.push_back(itm);
                }
            }
            else if( m_flag == 2)
            {
                size_t size = rd2->second.reward_item.size();
                for (size_t i = 1; i < size; ++i)
                {
                    itm.itid = 0;
                    itm.resid = rd2->second.reward_item[i][0];
                    itm.num = rd2->second.reward_item[i][1];
                    nt.items.push_back(itm);
                }
            }

            string msg;
            if (m_flag == 1)
            {
                auto rp_gmail = mailinfo.get_repo(mail_worldboss_join);
                if (rp_gmail != NULL)
                {
                    // 已和策划沟通，当前未做邮件功能，完成后再写以下功能
                    auto msg = mailinfo.new_mail(mail_worldboss_join); 
                    user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                }
            }
            else
            {
                auto rp_gmail = mailinfo.get_repo(mail_gangboss_join);
                if (rp_gmail != NULL)
                {
                    auto msg = mailinfo.new_mail(mail_gangboss_join); 
                    user->gmail.send(rp_gmail->title, rp_gmail->sender, msg,rp_gmail->validtime, nt.items); 
                }
            }
        }
        else
        {
            logerror((LOG, "world boss join reward off, uid = %d",uid));
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t itm;
            if( m_flag == 1)
            {
                size_t size = rd->second.reward_item.size();
                for (size_t i = 1; i < size; ++i)
                {
                    itm.itid = 0;
                    itm.resid = rd->second.reward_item[i][0];
                    itm.num = rd->second.reward_item[i][1];
                    nt.items.push_back(itm);
                }
            }
            else if( m_flag == 2)
            {
                size_t size = rd2->second.reward_item.size();
                for (size_t i = 1; i < size; ++i)
                {
                    itm.itid = 0;
                    itm.resid = rd2->second.reward_item[i][0];
                    itm.num = rd2->second.reward_item[i][1];
                    nt.items.push_back(itm);
                }
            }

            string msg;
            if (m_flag == 1)
            {
                auto rp_gmail = mailinfo.get_repo(mail_worldboss_join);
                if (rp_gmail != NULL)
                {
                    // 已和策划沟通，当前未做邮件功能，完成后再写以下功能
                    auto msg = mailinfo.new_mail(mail_worldboss_join); 
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                }
            }
            else
            {
                auto rp_gmail = mailinfo.get_repo(mail_gangboss_join);
                if (rp_gmail != NULL)
                {
                    auto msg = mailinfo.new_mail(mail_gangboss_join); 
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg,rp_gmail->validtime, nt.items); 
                }
            }
        }
    }
    sc_gmail_mgr_t::do_offmail();
}


void sc_world_boss_t::rank_reward()
{
    //首先获取排名
    vector<sc_msg_def::jpk_dmg_info_t> rank;
    get_rank(100000,rank);

    //发放奖励
    auto it=repo_mgr.worldboss.find( m_grade );
    if( it == repo_mgr.worldboss.end() )
        return;
    auto it2=repo_mgr.unionboss.find( m_grade );
    if( it2 == repo_mgr.unionboss.end() )
        return;

    int32_t gold=0;
    int32_t rid = 0;
    
    sc_gmail_mgr_t::begin_offmail();
    for( size_t i=0;i<rank.size();++i)
    {
        if( m_flag == 1 )
        {
            if (i == 0)
                gold = it->second.gold_rank1;
            else if (i == 1)
                gold = it->second.gold_rank2;
            else if (i == 2)
                gold = it->second.gold_rank3;
            else if (i >= 3 && i <= 9)
                gold = it->second.gold_rank4;
            else if (i >= 10 && i <= 49)
                gold = it->second.gold_rank5;
            else if (i >= 50 && i <= 199)
                gold = it->second.gold_rank6;
            else if (i >= 200)
                gold = it->second.gold_rank7;
        }
        else if( m_flag == 2 )
        {
            if (i == 0)
                gold = it2->second.champion_coin;
            else if (i == 1)
                gold = it2->second.second_coin;
            else if (i == 2)
                gold = it2->second.third_coin;
            else if (i >= 3 && i <= 9)
                gold = it2->second.topten_coin;
            else
                gold = it2->second.all_coin;
        }

        rid = i==0?1:i==1?2:i==2?3:i<=4?4:i<=9?5:i<=19?6:i<=49?7:i<=99?8:i<=199?9:0;

        //修改玩家数据
        sp_user_t user;
        if( logic.usermgr().get(rank[i].uid, user) || cache.get(rank[i].uid, user) )
        {
            logerror((LOG, "world boss rank reward , uid = %d,rank = %d",rank[i].uid, i));
            sc_msg_def::nt_bag_change_t nt;

            sc_msg_def::jpk_item_t itm;
            itm.itid = 0;
            itm.resid = 10001;
            itm.num = gold;
            nt.items.push_back(itm);

            if (rid != 0)
            {
                if( m_flag == 1 )
                {
                    auto ritems = repo_mgr.boss_reward.find(it->second.item_rank[rid]);
                    if (ritems == repo_mgr.boss_reward.end())
                    {
                        logerror((LOG, "repo no item reward"));
                        continue;
                    }
                    for (size_t index = 1; index != ritems->second.reward_item.size(); ++index)
                    {
                        itm.itid = 0;
                        itm.resid = ritems->second.reward_item[index][0];
                        itm.num = ritems->second.reward_item[index][1];
                        nt.items.push_back(itm);
                    }
                    auto msg = mailinfo.new_mail(mail_worldboss_rank, (i+1), gold, "");
                    auto rp_gmail = mailinfo.get_repo(mail_worldboss_rank);
                    if (rp_gmail != NULL)
                        user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                }
                else if( m_flag == 2)
                {
                    auto ritems = repo_mgr.unionboss_reward.find(it2->second.item_rank[rid]);
                    if (ritems == repo_mgr.unionboss_reward.end())
                    {
                        logerror((LOG, "repo no item reward"));
                        continue;
                    }
                    for (size_t index = 1; index != ritems->second.reward_item.size(); ++index)
                    {
                        itm.itid = 0;
                        itm.resid = ritems->second.reward_item[index][0];
                        itm.num = ritems->second.reward_item[index][1];
                        nt.items.push_back(itm);
                    }
                    auto msg = mailinfo.new_mail(mail_gangboss_rank, (i+1), gold, "");
                    auto rp_gmail = mailinfo.get_repo(mail_gangboss_rank);
                    if (rp_gmail != NULL)
                        user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                }
            }
        }
        else
        {
            logerror((LOG, "world boss rank reward off, uid = %d,rank = %d",rank[i].uid, i));
            sc_msg_def::nt_bag_change_t nt;

            sc_msg_def::jpk_item_t itm;
            itm.itid = 0;
            itm.resid = 10001;
            itm.num = gold;
            nt.items.push_back(itm);

            if (rid != 0)
            {
                if( m_flag == 1 )
                {
                    auto ritems = repo_mgr.boss_reward.find(it->second.item_rank[rid]);
                    if (ritems == repo_mgr.boss_reward.end())
                    {
                        logerror((LOG, "repo no item reward"));
                        continue;
                    }
                    for (size_t index = 1; index != ritems->second.reward_item.size(); ++index)
                    {
                        itm.itid = 0;
                        itm.resid = ritems->second.reward_item[index][0];
                        itm.num = ritems->second.reward_item[index][1];
                        nt.items.push_back(itm);
                    }
                    auto msg = mailinfo.new_mail(mail_worldboss_rank, (i+1), gold, "");
                    auto rp_gmail = mailinfo.get_repo(mail_worldboss_rank);
                    if (rp_gmail != NULL)
                    {
                        sc_gmail_mgr_t::add_offmail(rank[i].uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                    }
                }
                else if( m_flag == 2)
                {
                    auto ritems = repo_mgr.unionboss_reward.find(it2->second.item_rank[rid]);
                    if (ritems == repo_mgr.unionboss_reward.end())
                    {
                        logerror((LOG, "repo no item reward"));
                        continue;
                    }
                    for (size_t index = 1; index != ritems->second.reward_item.size(); ++index)
                    {
                        itm.itid = 0;
                        itm.resid = ritems->second.reward_item[index][0];
                        itm.num = ritems->second.reward_item[index][1];
                        nt.items.push_back(itm);
                    }
                    auto msg = mailinfo.new_mail(mail_gangboss_rank, (i+1), gold, "");
                    auto rp_gmail = mailinfo.get_repo(mail_gangboss_rank);
                    if (rp_gmail != NULL)
                    {
                        sc_gmail_mgr_t::add_offmail(rank[i].uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                    }
                }
            }
        }
        sc_gmail_mgr_t::do_offmail();
    }
}
//==================================================================================
sc_gang_boss_t::sc_gang_boss_t()
{
    m_flag = 2;
    m_start = m_prepare = m_end = 0;
}
void sc_gang_boss_t::load_db(int32_t ggid_)
{
    //cout << "load_db->1"<<endl;
    sql_result_t res;
    char sql[512];
    sprintf(sql,"select m_spawned,m_spawne_time,m_resid,m_grade,m_hp,m_max_hp,is_event,m_damage,top_cut,m_cur_count,m_join_count,is_join_reward,reward_send,m_start,m_end,m_prepare,top from GangBoss where ggid = %d",ggid_);
    db_service.sync_select(sql,res);
    //cout << "load_db->2"<<endl;
    if (0 != res.affect_row_num()){
        //cout << "load_db->2-2"<<endl;
        sql_result_row_t& row_ = *res.get_row_at(0);
        m_spawned = (int32_t)std::atoi(row_[0].c_str()); 
        m_spawne_time = (int32_t)std::atoi(row_[1].c_str());
        m_resid = (int32_t)std::atoi(row_[2].c_str());
        m_grade = (int32_t)std::atoi(row_[3].c_str());
        m_hp = (int64_t)std::atoi(row_[4].c_str());
        m_max_hp = (int64_t)std::atoi(row_[5].c_str());
        is_event = (int32_t)std::atoi(row_[6].c_str());
        m_damage = (int32_t)std::atoi(row_[7].c_str());
        top_cut = (int32_t)std::atoi(row_[8].c_str());
        m_cur_count = (int32_t)std::atoi(row_[9].c_str());
        m_join_count = (int32_t)std::atoi(row_[10].c_str()); 
        int32_t is_join  = (int32_t)std::atoi(row_[11].c_str());
        is_join_reward = (is_join == 1 ? true : false);
        int32_t reward_send = (int32_t)std::atoi(row_[12].c_str());
        m_start = (int32_t)std::atoi(row_[13].c_str());
        m_end = (int32_t)std::atoi(row_[14].c_str());
        m_prepare = (int32_t)std::atoi(row_[15].c_str()); 
        int tn = int32_t(reward_send | 7);
        //cout<<"tn-1->"<<tn<<endl;
        //cout << "load_db->2-3"<<endl;
        reward60 = (int32_t(tn & 8)) > 0 ? true : false;
        tn = int32_t(reward_send | 11);
        //cout<<"tn-2->"<<tn<<endl;
        reward30 = (int32_t(tn & 4)) > 0 ? true : false;
        tn = int32_t(reward_send | 13);
        //cout<<"tn-3->"<<tn<<endl;
        reward10 = (int32_t(tn & 2)) > 0 ? true : false;
        tn = int32_t(reward_send | 14);
        //cout<<"tn-4->"<<tn<<endl;
        reward0 = (int32_t(tn & 1)) > 0 ? true : false;
        //cout << "load_db-reward60->"<<reward60<<endl;
        //cout << "load_db-reward30->"<<reward30<<endl;
        //cout << "load_db-reward10->"<<reward10<<endl;
        //cout << "load_db-reward0->"<<reward0<<endl;
        //cout << "load_db-row[16]->" <<row_[16]<<endl;
        if (row_[16]!= ""){
        //cout << "load_db->2-4"<<endl;
            top.clear();
        //cout << "load_db->2-5"<<endl;
            char s[1024];
        //cout << "load_db->2-6"<<endl;
            std::strcpy(s,row_[16].c_str());
        //cout << "load_db->2-7"<<endl;
            const char *d = "|";
        //cout << "load_db->2-8"<<endl;
            char *p = NULL;
        //cout << "load_db->2-9"<<endl;
            p = std::strtok(s,d);
        //cout << "load_db->2-10"<<endl;
            while(p)
            {
                //cout << "load_db->2-p->"<<p<<endl;
                sc_msg_def::jpk_dmg_info_t dmg_info_;
                dmg_info_ << string(p);
                top.push_back(dmg_info_);
                p=strtok(NULL,d);
            }
        }
    }
    else{
        db_GangBoss_t db_;
        db_.ggid = ggid_;
        db_.m_spawned = m_spawned; 
        db_.m_spawne_time = m_spawne_time;
        db_.m_resid = m_resid;
        db_.m_grade = m_grade;
        db_.m_hp = m_hp;
        db_.m_max_hp = m_max_hp;
        db_.is_event = is_event;
        db_.m_damage = m_damage;
        db_.top_cut = top_cut;
        db_.m_cur_count = m_cur_count;
        db_.m_join_count = m_join_count;
        db_.is_join_reward = 0;
        db_.reward_send = 0;
        db_.m_start = m_start;
        db_.m_end = m_end;
        db_.m_prepare = m_prepare;
        db_.top = "";
        //cout << "load_db->2->1"<<endl;

        db_service.async_do((uint64_t)ggid_,[](db_GangBoss_t& db){
                db.insert();         
                },db_);
    }
    //cout << "load_db->3"<<endl;
    sprintf(sql,"select uid,in_scene,damage,last_batt_time,old_scene,nickname,lv from GangBossDamage  where ggid = %d",ggid_);
    if (0!=db_service.sync_select(sql,res)){
        return; 
    }
    //cout << "load_db->4"<<endl;
    m_damage_hm.clear();
    for(int32_t i = 0;i<res.affect_row_num();i++){
        sql_result_row_t& row_ = *res.get_row_at(i);
        string nickname_ = row_[5];
        int32_t uid_ = (int32_t)std::atoi(row_[0].c_str());
        auto it=m_damage_hm.insert(make_pair(uid_,damage_info_t(nickname_))).first;
        it->second.in_scene = (int32_t)std::atoi(row_[1].c_str());
        //it->second.in_scene = 0;
        it->second.damage = (int32_t)std::atoi(row_[2].c_str());
        it->second.last_batt_time = (int32_t)std::atoi(row_[3].c_str());
        it->second.old_scene = (int32_t)std::atoi(row_[4].c_str());
       // it->second.old_scene = 0;
        it->second.nickname  = nickname_;
        it->second.lv = (int32_t)std::atoi(row_[6].c_str());
    } 
    //cout << "load_db->5"<<endl;
}
void sc_gang_boss_t::save_db(int32_t ggid_)
{
    //cout<<"save_db"<<endl;
        db_GangBoss_t db_;
        db_.ggid = ggid_;
        db_.m_spawned = m_spawned; 
        db_.m_spawne_time = m_spawne_time;
        db_.m_resid = m_resid;
        db_.m_grade = m_grade;
        db_.m_hp = m_hp;
        db_.m_max_hp = m_max_hp;
        db_.is_event = is_event;
        db_.m_damage = m_damage;
        db_.top_cut = top_cut;
        db_.m_cur_count = m_cur_count;
        db_.m_join_count = m_join_count;
        if (is_join_reward){
            db_.is_join_reward = 1;
        }
        else{
            db_.is_join_reward = 0;
        }
        int32_t tn = 0;
        if (reward60)
            tn += 8;
        if (reward30)
            tn += 4;
        if (reward10)
            tn += 2;
        if (reward0)
            tn += 1;
        db_.reward_send = tn;
        db_.m_start = m_start;
        db_.m_end = m_end;
        db_.m_prepare = m_prepare;
        if (top.size()>0){
            string s_top;

            for (auto it = top.begin(); it != top.end();it++){
                string t_s_top = "";
                *it >> t_s_top;
                if (it+1 == top.end()){
                    s_top.append(t_s_top);
                }
                else
                {
                    s_top.append(t_s_top);
                    s_top.append(string("|"));
                }
            }
            //cout<<"save_db-s_top->"<<s_top<<endl;
            db_.top = s_top;
        }else
            db_.top = "";
        

        db_service.async_do((uint64_t)ggid_,[](db_GangBoss_t& db){
            db.update();         
        },db_);
}
void sc_gang_boss_t::get_boss_state(int32_t uid_,int32_t scene_,int32_t grade_, const string &nickname_)
{
    sc_msg_def::ret_boss_state_t ret;
    ret.flag= m_flag;
    ret.sceneid = SCENE_GB;
    ret.resid = 0;
    ret.cd = 0;
    ret.hp = 0;
    ret.x = -300;
    ret.y = -100;
    ret.revieve_times = 0;
    ret.boss_leave_time = 0;

    sp_user_t user;
    if( logic.usermgr().get(uid_,user) || cache.get(uid_, user) )
    {
        ret.revieve_times = user->vip.get_num_count(vop_immedia_fight_wboss);
    }
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
    {
        ret.state = -1;
        logic.unicast(uid_, ret);
        return;
    }

    ret.bosslv = sp_gang->db.bosslv;
    auto it_ = repo_mgr.guildboss_open.find(1);
    if (sp_gang->db.level < it_->second.guild_lv)
    {
        ret.state = 5;
        logic.unicast(uid_, ret);
        return;
    }
    if (date_helper.secoffday()< UB_BT*3600 ||  date_helper.secoffday() > UB_ET*3600){
        ret.state = 0;
        logic.unicast(uid_, ret);
        return;
    }
    int lastboss = sp_guser->db.lastboss;
    if(lastboss == 0){
        sp_guser->db.set_todaycount(0);
    }else{
        int curweek = (date_helper.cur_sec()-SECONDS_DAY*4) / SECONDS_7_DAY;
        int lastweek = (lastboss-SECONDS_DAY*4) / SECONDS_7_DAY;
        if(curweek > lastweek){
            sp_guser->db.set_todaycount(0);
        }
    }
    sp_guser->save_db();
    if(sp_guser->db.todaycount >= 7){
        auto it=m_damage_hm.find(uid_);
        if( it==m_damage_hm.end() )
        {
            ret.state = 7;
            logic.unicast(uid_, ret);
            return;
        }
    }

    //重置start时刻
    if (m_end > 0 && date_helper.cur_sec() >= m_end){
        m_start = 0;
        save_db(sp_guser->db.ggid);
    }

    //从当前时刻开始的倒计时
    int cd = 0;// update_time(sp_gang, sp_guser);

    //获取当前时间
    uint32_t curtime=date_helper.cur_sec();

    //处于准备时间
    if( (curtime>=m_prepare)&&(curtime<m_start) )
    {
        //boss出生
        if( !m_spawned ){
            boss_spawn(sp_gang->db.bosslv, 2);
            char sql[128];
            sprintf(sql,"delete from GangBossDamage where ggid = %d",sp_guser->db.ggid);
            db_service.sync_execute(sql);                                                     
        }
        //玩家进入准备状态
        do_user_enter(uid_,SCENE_GG,nickname_,SCENE_GB, grade_);
        save_db(sp_guser->db.ggid);
        //初始化返回数据
        ret.state = 1;
        ret.resid = m_resid;
        ret.cd = m_start - curtime;
        ret.hp = m_max_hp;
        ret.boss_leave_time = m_end - curtime;

        logic.unicast(uid_, ret);

        if(m_join_count >= SCENE_GB_RC){
            m_start = date_helper.cur_sec();
            save_db(sp_guser->db.ggid);
            for(auto it = m_damage_hm.begin(); it != m_damage_hm.end(); it++){
                int32_t uid_t = it->first;
                sc_msg_def::nt_union_boss_open_t ret_;
                ret_.flag = 2;
                logic.unicast(uid_t, ret_);
            }
        }
        return;
    }
    //处于开始时间
    if( (curtime>=m_start)&&(curtime<m_end) )
    {
        if( !m_spawned )
        {
            if (date_helper.offday(m_spawne_time)>= 1)
            {
                //boss尚未出生
                boss_spawn(sp_gang->db.bosslv, 2);
                char sql[128];
                sprintf(sql,"delete from GangBossDamage where ggid = %d",sp_guser->db.ggid);
                db_service.sync_execute(sql);                                                     
            }
            else
            {
                //boss已被打死
                ret.state=0;
                logic.unicast(uid_, ret);
                return;
            }
        }

        ret.state = 2;
        ret.resid = m_resid;
        int32_t delta = date_helper.cur_sec()-get_last_batt_time(uid_);
        if(delta>SERVER_CD)
            ret.cd = 0;
        else
            ret.cd = SERVER_CD-delta;
        //vip4开始无cd
        if(user->db.viplevel >= 4)
            ret.cd = 0;
        ret.hp = m_max_hp;
        ret.boss_leave_time = m_end - curtime;
        logic.unicast(uid_, ret);
        
        //玩家进入准备状态
        do_user_enter(uid_,SCENE_GG,nickname_,SCENE_GB, grade_);
        save_db(sp_guser->db.ggid);
        return;
    }
    //不在时间段
    ret.state=0;
    ret.cd = cd;
    logic.unicast(uid_, ret);
}
void sc_gang_boss_t::update_boss(const sp_gang_t& sp_gang_, const sp_ganguser_t& sp_guser_, int32_t& bosscount)
{
    if (m_end > 0 && date_helper.cur_sec() >= m_end){
        m_start = 0;
        save_db(sp_gang_->db.ggid);
    }
    int32_t lastboss = sp_gang_->db.lastboss;
    if(lastboss == 0){
        sp_gang_->db.set_bosscount(0); //read repo
        sp_gang_->save_db();
    }else{
        int curweek = (date_helper.cur_sec()-SECONDS_DAY*4) / SECONDS_7_DAY;
        int lastweek = (lastboss-SECONDS_DAY*4) / SECONDS_7_DAY;
        if(curweek > lastweek){
            sp_gang_->db.set_bosscount(0); //read repo
            sp_gang_->save_db();
        }
    }
    bosscount = sp_gang_->db.bosscount;
    return;
}
void sc_gang_boss_mgr_t::open_boss(sp_user_t sp_user_, sc_msg_def::ret_open_union_boss_t& ret)
{
    ret.st = 0;
    ret.m_prepare = 0;
    ret.m_start = 0;
    ret.m_end = 0;
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
    {
        ret.st = -1;
        return;
    }
    if (sp_guser->db.flag == 0)
    {
        ret.st = 8;
        return;
    }
    auto it = m_mgr.find(sp_gang->db.ggid);
    if (it != m_mgr.end())
    {
        if(it->second->is_spawned() && date_helper.offday(sp_gang->db.lastboss) < 1)
        {
            ret.st = -1;
            return;
        }
    }
    auto it_ = repo_mgr.guildboss_open.find(1);
    if (sp_gang->db.level < it_->second.guild_lv)
    {
        ret.st = 2;
        return;
    }

    auto it_t = repo_mgr.guildboss_open.find(sp_gang->db.bosscount+1);
    if( it_t == repo_mgr.guildboss_open.end() )
    {
        ret.st = 3;
        return;
    }
    if( sp_gang->db.level < it_t->second.guild_lv){
        ret.st = 4;
        return;
    }
    if (date_helper.secoffday() > 20*3600)
    {
        ret.st = 5;
        return;
    }

    for (size_t i = 1; i < it_t->second.cost.size(); i++)
    {
        if(it_t->second.cost[i][0] == 10001){
            if(sp_user_->db.gold<it_t->second.cost[i][1]){
                ret.st = 6;
                return;
            }
        }else if(it_t->second.cost[i][0] == 10003){
            if(sp_user_->db.payyb + sp_user_->db.freeyb < it_t->second.cost[i][1]){
                ret.st = 7;
                return;
            }
        }
    }
    /*
    if (date_helper.offday(sp_gang->db.lastboss) >= 1)
        sp_gang->db.set_todaycount(0);
    if (sp_gang->db.todaycount >= 3){
        ret.st = 9;
        return;
    }
    */
    for (size_t i = 1; i < it_t->second.cost.size(); i++)
    {
        if(it_t->second.cost[i][0] == 10001){
            sp_user_->consume_gold(it_t->second.cost[i][1]);
            sp_user_->save_db();
        }else if(it_t->second.cost[i][0] == 10003){
            sp_user_->consume_yb(it_t->second.cost[i][1]);
            sp_user_->save_db();
        }
    }

    sp_gang->db.set_bosscount(sp_gang->db.bosscount+1);
    //sp_gang->db.set_todaycount(sp_gang->db.todaycount+1);
    sp_gang->db.set_lastboss(date_helper.cur_sec());
    sp_gang->save_db();
    sp_gang_boss_t sp_boss;
    //auto it = m_mgr.find(sp_gang->db.ggid);
    //if (it == m_mgr.end())
    //{
        sp_boss.reset(new sc_gang_boss_t());
        m_mgr[sp_gang->db.ggid] = sp_boss;
        //sp_boss->load_db(sp_gang->db.ggid);
    //}
    //else sp_boss = it->second;
    sp_boss->m_prepare = date_helper.cur_sec();
    sp_boss->m_end = date_helper.cur_0_stmp() + UB_ET * 3600;
    sp_boss->m_start = sp_boss->m_end;
    sp_boss->save_db(sp_gang->db.ggid);
    ret.st = 1;
    ret.m_prepare = sp_boss->m_prepare;
    ret.m_end = sp_boss->m_end;
    ret.m_start = sp_boss->m_start;
    return;
}
int sc_gang_boss_t::update_time(const sp_gang_t& sp_gang_, const sp_ganguser_t& sp_guser_)
{
    //重置start时刻
    if (m_end > 0 && date_helper.cur_sec() >= m_end){
        m_start = 0;
        save_db(sp_guser_->db.ggid);
    }

    //从当前时刻开始的倒计时
    int cd = 0;

    //初始化开始时间
    if (m_start <= 0)
    {
        //注意这里使用的是本地时间
        //当前时刻归一到一周内
        //1970.1.1是星期四
        int curtime = (date_helper.cur_local_sec()-SECONDS_DAY*3)  % SECONDS_7_DAY;

        /*
        //计算上次打公会boss是否在本周内
        //当前是第几周
        int curweek = (date_helper.cur_local_sec()) / SECONDS_7_DAY;
        //上次打boss是第几周
        int lastweek = (sp_guser_->db.lastboss) / SECONDS_7_DAY;
        //间隔时间
        int offweek = curweek - lastweek;
        if (sp_guser_->db.lastboss == 0)
            offweek = 0;

        //下一周时间
        int bossday = (uint8_t)(sp_gang_->db.bossday);
        int nextday = ((sp_gang_->db.bossday)>>8);
        //如果存在下一周设置，且当前对boss的战斗已经超过一周，则取下一周为当前周的boss时间
        if (nextday > 0 && offweek >= 1)
        {
            //把bossday设置为下一周
            bossday = nextday-1;
            sp_gang_->db.set_bossday(nextday<<8|(uint8_t)bossday);
            sp_gang_->save_db();
        }

        //从周日开始的偏移时间
        //int startoff = bossday*24*3600 + (sp_gang_->db.ggid%10)*OFFSET_PER_SERVER*60+BASE_TIME_GBOSS*3600;
        */
        int bossday = 6;
        int startoff = bossday *24*3600 + BASE_TIME_GBOSS*3600;

        bool is_spawned = false;
        auto it = gang_boss_mgr.m_mgr.find(sp_gang_->db.ggid);
        if (it != gang_boss_mgr.m_mgr.end())
            is_spawned = it->second->is_spawned();

        //如果本周已经打过或者当前时间不在偏移范围内
        if (is_spawned)
            cd = 0;
        else if (curtime > (startoff + BOSS_LIFE*3600))
            cd = SECONDS_7_DAY + startoff - curtime;
        else
            cd = startoff - curtime;

        if (cd < 0) cd = 0;

        //公会boss开始时间
        m_start=date_helper.cur_local_sec()+ cd;
        //公会boss结束时间
        m_end=m_start + BOSS_LIFE * 3600;
        //公会boss准备时间
        if (is_spawned)
            m_prepare=0;
        else
            m_prepare=m_start - PREPARE_TIME*60;
        save_db(sp_guser_->db.ggid);
    }

    return cd;
}
sp_gang_boss_t sc_gang_boss_mgr_t::get_boss(sp_user_t sp_user_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (gang_mgr.get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
    {
        auto it = m_mgr.find(sp_gang->db.ggid);
        if (it == m_mgr.end())
        {
            sp_gang_boss_t sp_boss(new sc_gang_boss_t());
            m_mgr[sp_gang->db.ggid] = sp_boss;
            sp_boss->load_db(sp_gang->db.ggid);
            return sp_boss;
        }
        return it->second;
    }
    return sp_gang_boss_t(); 
}
int32_t sc_gang_boss_mgr_t::is_boss_available(sp_user_t sp_user_, int32_t& bosscount)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(sp_user_->db.uid, sp_gang, sp_guser))
    {
        return -1;
    }

    auto it_ = repo_mgr.guildboss_open.find(1);
    if (sp_gang->db.level < it_->second.guild_lv)
    {
        return 1; 
    }

    sp_gang_boss_t sp_boss;
    auto it = m_mgr.find(sp_gang->db.ggid);
    if (it == m_mgr.end())
    {
        sp_boss.reset(new sc_gang_boss_t());
        m_mgr[sp_gang->db.ggid] = sp_boss;
        sp_boss->load_db(sp_gang->db.ggid);
    }
    else sp_boss = it->second;

    //从当前时刻开始的倒计时
    sp_boss->update_boss(sp_gang, sp_guser, bosscount);
    uint32_t curtime=date_helper.cur_sec();
    //处于准备时间
    if( (curtime>=sp_boss->m_prepare)&&(curtime<sp_boss->m_start) )
    {
        return 2;
    }
    //处于开始时间
    if( (curtime>=sp_boss->m_start)&&(curtime<sp_boss->m_end) )
    {
        if (!sp_boss->is_spawned() && sp_boss->m_max_hp > 0) return 3;
        else return 2;
    }
    if (curtime >= sp_boss->m_end)
    {
        return 1;
    }
    return 1;
}
void sc_gang_boss_mgr_t::update_reward()
{
    int32_t curtime = date_helper.secoffday();
    if(curtime < UB_ET *3600 || curtime > UB_BT *3600 + 10*60){
        return;
    }
    for(auto it=m_mgr.begin();it!=m_mgr.end();++it)
    {
        if( it->second->is_join_reward )
            continue;
        it->second->join_reward();
        it->second->is_join_reward = true;
    }
}
