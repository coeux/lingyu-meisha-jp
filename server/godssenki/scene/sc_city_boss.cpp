#include "sc_city_boss.h"
#include "sc_logic.h"
#include "sc_push_def.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "date_helper.h"

#define LOG "SC_CITY_BOSS"

namespace sc_city_boss{

//开始时刻
#define BEGIN_TIME (13*3600)
//BOSS生命(sec)
#define BOSS_LIFE 3500
//BOSS可以被打的最大次数
#define MAX_BOSS_FIGHT 15
//BOSS最大刷新间隔
#define BOSS_SPAWN_OFF 100
//通知1相对开始的偏移息时刻
#define NOTIFY_OFF_1 600
//通知2相对开始的偏移息时刻
#define NOTIFY_OFF_2 300
//通知3相对结束的偏移息时刻
#define NOTIFY_OFF_3 300
//获得10012号物品推送信息
#define NOTIFY_ITID 19005 
//用户每天最大战斗次数
#define USER_FIGHT_MAX 5
//战斗超时
#define OVERTIME 120 
//一次战斗给予boss等级50倍的金钱
#define GOLD_PER_HIT 50

enum
{
    ST_BOSS_NORMAL = 0,
    ST_BOSS_FIGHTING,
    ST_BOSS_GONE,
    ST_BOSS_SPAWN,
};

city_t::city_t(int sceneid_):
    m_sceneid(sceneid_),
    m_spawn_num(0),
    m_notify1(false),
    m_notify2(false),
    m_notify3(false),
    m_spawned(false),
    m_bossgone(false)
{
}
int city_t::update()
{
    //获取当前时间相对当天00:00的漂移秒数
    uint32_t curtime = date_helper.secoffday();
    //如果过了12点且在BOSS出生时间段，则curtime+23小时
    if (curtime <= BOSS_LIFE)
        curtime += 24 * 3600;

    //更新spawn_num
    m_spawn_num = (curtime - BEGIN_TIME);
    if (m_spawn_num < 0) 
        m_spawn_num = 0; //小于0则取0
    else
        m_spawn_num = (int)(m_spawn_num / 3600.f  + 0.5f); //四舍五入取整

    uint32_t cur_start_time = BEGIN_TIME + BOSS_SPAWN_OFF * m_spawn_num;
    int cd = cur_start_time - curtime; 
    //在开始时间之前10分钟
    if (m_spawned && cd > 0)
    {
        //超出boss生命,boss默默的离开
        gone();
        //通知boss跑路
        //pushinfo.new_push(push_cityboss_gone);
    }
    if ( 0 < cd && cd < NOTIFY_OFF_1 )
    {
        if (!m_notify1)
        {
            //刷怪刷新前10分钟发送通知1
            m_notify1=true;
            //pushinfo.new_push(push_cityboss_info_1, (cur_start_time / 3600));
        }
    }
    /*
    //在开始时间之前5分钟
    else if (0 < cd && cd <= NOTIFY_OFF_2)
    {
        if (!m_notify2)
        {
            //怪物刷新前5分钟发送通知2
            m_notify2=true;
            pushinfo.new_push(push_cityboss_info_2);
        }
    }
    */
    else if (!m_spawned && cd <= 0 && BOSS_LIFE + cd > 0)
    {
        m_spawned = true;
        spawn();
        //pushinfo.new_push(push_cityboss_info_2);
    }
    if (m_spawned && cd < 0 &&  0<BOSS_LIFE+cd && BOSS_LIFE+cd <= NOTIFY_OFF_3)
    {
        if (!m_notify3)
        {
            //怪物逃跑前5分钟发送通知3
            m_notify3=true;
            //pushinfo.new_push(push_cityboss_goning);
        }
    }
    /*
    if (m_spawned && cd < 0 && BOSS_LIFE + cd <= 0)
    {
        //超出boss生命
        gone();
        //通知boss跑路
        pushinfo.new_push(push_cityboss_gone);
    }
    */

    return cd;
}
int city_t::gone()
{
    m_notify1 = m_notify2 = m_notify3 = false;
    m_spawned = false;

    if (!m_boss_map.empty())
    {
        sc_msg_def::nt_city_boss_state_t nt;
        nt.sceneid = m_sceneid;
        for(auto it=m_boss_map.begin(); it!=m_boss_map.end(); it++)
            nt.bossids.push_back(it->second->id);
        nt.state = ST_BOSS_GONE;
        logic.citymgr().broadcast(m_sceneid, nt);
    }

    //清除boss
    m_boss_map.clear();
    return 0;
}
int city_t::spawn()
{
    if (!m_boss_map.empty())
        return ERROR_SC_EXCEPTION;

    repo_def::city_boss_t* cb = repo_mgr.city_boss.get(m_sceneid);
    if (cb == NULL){
        return ERROR_SC_EXCEPTION;
    }

    int rpos = random_t::rand_integer(1, repo_mgr.city_boss_pos.size());
    for(size_t i=1;i<cb->level.size(); i++)
    {
        int r = random_t::rand_integer(1, cb->monster.size()-1);
        sp_boss_t sp_boss(new boss_t(i));
        sp_boss->resid = cb->monster[r];
        sp_boss->level = cb->level[i];
        sp_boss->spawnstamp = date_helper.cur_sec();
        sp_boss->fightstamp = 0;
        sp_boss->fightingbyuid = 0;
        sp_boss->killcount = 0;
        sp_boss->x = 0;
        sp_boss->y = 0;

        rpos = rpos % repo_mgr.city_boss_pos.size() + 1;
        //logerror((LOG, "rpos:%d", rpos));

        repo_def::city_boss_pos_t* repo_pos = repo_mgr.city_boss_pos.get(rpos);
        if (repo_pos != NULL){
            sp_boss->x = repo_pos->x;
            sp_boss->y = repo_pos->y;
        }

        m_boss_map[sp_boss->id] = sp_boss;
    }

    sc_msg_def::nt_city_boss_state_t nt;
    nt.sceneid = m_sceneid;
    for(auto it=m_boss_map.begin(); it!=m_boss_map.end(); it++)
        nt.bossids.push_back(it->second->id);
    nt.state = ST_BOSS_SPAWN;
    logic.citymgr().broadcast(m_sceneid, nt);

    return SUCCESS;
}
int city_t::get_boss_jpk(jpk_boss_vec_t& jpks_)
{
    for(auto it=m_boss_map.begin(); it!= m_boss_map.end(); it++)
    {
        sp_boss_t& sp_boss = it->second;
        if (sp_boss->killcount >= MAX_BOSS_FIGHT)
            continue;

        sc_msg_def::jpk_city_boss_t jpk;
        jpk.id = sp_boss->id;
        jpk.resid = sp_boss->resid;
        jpk.level = sp_boss->level;
        jpk.killcount = sp_boss->killcount;
        jpk.x = sp_boss->x;
        jpk.y = sp_boss->y;
        jpk.fighting = sp_boss->fightingbyuid != 0;
        jpks_.push_back(std::move(jpk));
    }
    return 0;
}
int city_t::begin_fight(sp_user_t sp_user_, uint32_t bossid_)
{
    auto it_boss = m_boss_map.find(bossid_);
    if (it_boss == m_boss_map.end())
    {
        logerror((LOG, "fight_boss,bossid:%d", bossid_));
        return ERROR_SC_EXCEPTION;
    }

    sp_boss_t& sp_boss = it_boss->second;

    if (sp_boss->killcount >= MAX_BOSS_FIGHT)
        return ERROR_CITYBOSS_KILLED;

    /*
    if (sp_boss->fightingbyuid != 0)
    {
        if (date_helper.offsec(sp_boss->fightstamp) >= OVERTIME)
        {
            sp_boss->fightingbyuid = 0;
            sp_boss->fightstamp = 0;
        }
        else return ERROR_CITYBOSS_FIGHTING;
    }
    */

    sp_cbuser_t sp_cbuser;
    auto it_user = cityboss.m_user_map.find(sp_user_->db.uid);
    if (it_user != cityboss.m_user_map.end())
    {
        sp_cbuser = it_user->second;
        if (date_helper.offday(sp_cbuser->fightstamp) >= 1)
        {
            sp_cbuser->fightcount = 0;
            sp_cbuser->fightstamp = date_helper.cur_sec();
            sp_cbuser->sp_boss = sp_boss;
        }
        if (sp_cbuser->fightcount >= USER_FIGHT_MAX)
        {
            return ERROR_CITYBOSS_FIGHTMAX;
        }
        else
        {
         //   sp_cbuser->fightcount++;
            sp_cbuser->fightstamp = date_helper.cur_sec();
            sp_cbuser->sp_boss = sp_boss;
        }
    }
    else{
        sp_cbuser.reset(new user_t);
        //sp_cbuser->fightcount = 1;
        sp_cbuser->fightcount = 0;
        sp_cbuser->fightstamp = date_helper.cur_sec();
        sp_cbuser->sp_boss = sp_boss;
        cityboss.m_user_map[sp_user_->db.uid] = sp_cbuser;
    }

    sp_boss->fightingbyuid = sp_user_->db.uid;
    sp_boss->fightstamp = date_helper.cur_sec();

    repo_def::city_boss_drop_t* repo_drop = repo_mgr.city_boss_drop.get(sp_boss->level);
    if (repo_drop == NULL)
    {
        logerror((LOG, "repo city boss drop no drop_level:%d", sp_boss->level));
        return ERROR_SC_EXCEPTION;
    }

    sc_msg_def::ret_begin_fight_city_boss_t ret;
    ret.bossid = bossid_;
    ret.code = SUCCESS;
    //ret.gold = sp_boss->level * GOLD_PER_HIT;
    sp_user_->city_boss_id = bossid_;

    for(size_t i=1; i<repo_drop->item_drop.size(); i++)
    {
        vector<int32_t> &drop = repo_drop->item_drop[i];
        if (drop.size() != 4)
        {
            logerror((LOG, "gen_drop_items, drop size error! size:%d!=3", drop.size()));
            continue;
        }
        repo_def::item_t* rp_item = repo_mgr.item.get(drop[0]);
        if (rp_item == NULL)
        {
            logerror((LOG, "gen_drop_items, repo no item resid:%d", drop[0]));
            continue;
        }

        uint32_t r = random_t::rand_integer(1, 10000);
        //logwarn((LOG, "gen_drop_items, r:%u, drop:%d, resid:%d ", r, drop[1], drop[0]));

        if (r > (uint32_t)drop[1])
            continue;

        int32_t n = random_t::rand_integer(drop[2], drop[3]);
        sc_msg_def::jpk_item_t ditem;
        ditem.itid = 0;
        ditem.resid = drop[0];
        ditem.num = n;
        ret.drop_items.push_back(std::move(ditem));
        ret.gold = n;
    }

    /*
    if (ret.drop_items.empty())
    {
        sc_msg_def::jpk_item_t ditem;
        ditem.itid = 0;
        ditem.resid = 19001;
        ditem.num = 1;
        ret.drop_items.push_back(std::move(ditem));
    }
    else if (ret.drop_items.size() > 3)
    {
        std::sort(ret.drop_items.begin(), ret.drop_items.end(), [](const sc_msg_def::jpk_item_t& a_, const sc_msg_def::jpk_item_t& b_){
            return a_.resid > b_.resid;
        });

        if (ret.drop_items.size() > 3)
            ret.drop_items.erase(ret.drop_items.begin()+3, ret.drop_items.end());
    }
    */

    sp_cbuser->drop_items = ret.drop_items;

    logic.unicast(sp_user_->db.uid, ret);

    sc_msg_def::nt_city_boss_state_t nt;
    nt.sceneid = m_sceneid;
    nt.bossids.push_back(sp_boss->id);
    nt.state = ST_BOSS_FIGHTING;
    logic.citymgr().broadcast(m_sceneid, nt);

    return SUCCESS;
}
int city_t::fight_boss(sp_user_t sp_user_, uint32_t bossid_, bool win_)
{
    auto it_user = cityboss.m_user_map.find(sp_user_->db.uid);
    if (it_user == cityboss.m_user_map.end())
    {
        logerror((LOG, "fight_boss,no user:%d, bossid:%d", sp_user_->db.uid, bossid_));
        return ERROR_SC_EXCEPTION;
    }
    sp_cbuser_t& sp_cbuser = it_user->second;

    /*
    if (sp_cbuser->sp_boss->fightingbyuid != sp_user_->db.uid)
    {
        logerror((LOG, "fight_boss,fightingbyuid is uid::%d", sp_user_->db.uid));
        return ERROR_SC_EXCEPTION;
    }
    */

    sp_boss_t& sp_boss = sp_cbuser->sp_boss;
    if (sp_boss == NULL)
        return ERROR_SC_EXCEPTION;

    if( win_ )
    {
        sp_boss->killcount++;
        sp_cbuser->fightcount++;
    }
    sp_boss->fightingbyuid = 0;
    sp_boss->fightstamp = 0;

    if (sp_boss->killcount >= MAX_BOSS_FIGHT)
    {
        sc_msg_def::nt_city_boss_state_t nt;
        nt.sceneid = m_sceneid;
        nt.bossids.push_back(sp_boss->id);
        nt.state = ST_BOSS_GONE;
        logic.citymgr().broadcast(m_sceneid, nt);
    }
    else
    {
        sc_msg_def::nt_city_boss_state_t nt;
        nt.sceneid = m_sceneid;
        nt.bossids.push_back(sp_boss->id);
        nt.state = ST_BOSS_NORMAL;
        logic.citymgr().broadcast(m_sceneid, nt);
    }

    //保存金币
    if( win_ )
    {
        sp_user_->on_money_change( sp_boss->level * GOLD_PER_HIT );
        sp_user_->save_db();
    }

    //保存道具到数据库
    if (win_ && !sp_cbuser->drop_items.empty())
    {
        bool haspush = false;
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<sp_cbuser->drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = sp_cbuser->drop_items[i];
            if (sp_user_->item_mgr.addnew(item.resid, item.num, nt)){
                haspush = (item.resid == NOTIFY_ITID);
            }
        }
        sp_user_->item_mgr.on_bag_change(nt);
        sp_cbuser->drop_items.clear();

        if (haspush)
        {
            /*
            pushinfo.new_push(push_cityboss_killed, 
                sp_user_->db.nickname(), 
                sp_user_->db.grade, 
                sp_user_->db.uid, 
                sp_user_->db.viplevel,
                sp_boss->resid, NOTIFY_ITID);
            */
        }
    }

    sp_boss.reset();
    return SUCCESS;
}
//=========================================================
int mgr_t::unicast(int uid_, int sceneid_)
{
    repo_def::city_boss_t* cb = repo_mgr.city_boss.get(sceneid_);
    if (cb == NULL){
        return ERROR_CITYBOSS_NONE;
    }

    sp_city_t sp_city;
    auto it = m_city_map.find(sceneid_);
    if (it == m_city_map.end()){
        sp_city = sp_city_t(new city_t(sceneid_));
        m_city_map[sceneid_] = sp_city;
    }
    else
        sp_city = it->second;

    sc_msg_def::ret_city_boss_info_t ret;
    ret.code = SUCCESS;
    ret.cd = sp_city->update();
    sp_city->get_boss_jpk(ret.bosses);
    auto it_user = m_user_map.find(uid_);
    if (it_user != m_user_map.end())
    {
        sp_cbuser_t& sp_cbuser = it_user->second;
        if (date_helper.offday(sp_cbuser->fightstamp) >= 1)
        {
            m_user_map.erase(it_user);
            ret.killcount = 0;
        }
        else ret.killcount = sp_cbuser->fightcount;
    }else ret.killcount = 0;

    logic.unicast(uid_, ret);

    return SUCCESS; 
}

int mgr_t::begin_fight(sp_user_t sp_user_, int bossid_)
{
    auto it_city = m_city_map.find(sp_user_->db.sceneid);
    if (it_city == m_city_map.end())
        return ERROR_SC_EXCEPTION;
    return it_city->second->begin_fight(sp_user_, bossid_);
}

int mgr_t::fight(sp_user_t sp_user_, int bossid_, bool win_)
{
    sp_user_->city_boss_id = 0;

    auto it_city = m_city_map.find(sp_user_->db.sceneid);
    if (it_city == m_city_map.end())
        return ERROR_SC_EXCEPTION;
    return it_city->second->fight_boss(sp_user_, bossid_, win_);
}

int mgr_t::update()
{
    auto it = m_city_map.begin();
    for(;it!=m_city_map.end();it++)
    {
        it->second->update();
    }
    return 0;
}

}
