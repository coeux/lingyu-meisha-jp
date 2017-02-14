
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_battle_pvp.h"
#include "sc_cache.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "date_helper.h"
#include "repo_def.h"
#include "code_def.h"

#define LOG "SC_TREASURE"

#define START_ROUND 4001
#define SLOT_PER_FLOOR 4
#define SECONDS_1_MIN 60
#define SECONDS_1_HOUR 3600
#define SECONDS_2_HOUR 7200
#define SECONDS_3_HOUR 10800
#define SECONDS_4_HOUR 14400
#define SECONDS_8_HOUR (3600*8)
#define SECONDS_9_HOUR (3600*9)
#define SECONDS_18_HOUR (3600*18)
#define SECONDS_DAY 86400
#define N_ROB_PER_SLOT 2
#define N_ROB_ALL 5
#define PERCENT_ROB 0.2
#define MAX_DEBIAN 14400
#define HELP_PROFIT 0.32f
#define MAX_PVP_FIGHT_TIME 360
#define SLOT_TYEP_SLOTS 0
#define SLOT_TYPE_HELPS 1
#define HOSTNUMERROR -1

sc_treasure_t::sc_treasure_t(sc_user_t &user_):m_user(user_), m_pos(-1)
{
    //  初始化宝库今日刷新次数
    m_utime = date_helper.cur_sec();
    m_today_refresh_times = 0;
}

void sc_treasure_t::load_db()
{
    sql_result_t res;
    // 在Treasure表中的查找当前玩家0 表示找到，-1，表示没找到
    if (0 == db_Treasure_t::sync_select_uid(m_user.db.uid,res)){
        for (size_t i =0; i < res.affect_row_num(); ++i)
        {
            sp_treasure_t sp_treasure(new treasure_t);
            sp_treasure->init(*res.get_row_at(i));
            m_treasure_hm.insert(make_pair(sp_treasure->uid, sp_treasure));
           
            if (date_helper.offday(sp_treasure->utime) >= 1) 
            {
                sp_treasure->set_reset_num(0);
                sp_treasure->reset_num = 0;
                save_db(sp_treasure);
            }
            m_today_refresh_times = sp_treasure->reset_num;
            m_utime = sp_treasure->utime; 
        }
    }else {
        update_treasure_reset_num(0);
    }
    check24();
}

void sc_treasure_t::save_db(sp_treasure_t& sp_treasure_)
{
    string sql = sp_treasure_->get_up_sql();
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
        db_service.async_execute(sql_);
        }, sql);
}

int32_t sc_treasure_t::is_open()
{
    return 1;
    //00:00 ~ 09:00 18:00 ~ 00:00 关闭
    int32_t cur = date_helper.cur_sec();
    int32_t base = cur - (cur + SECONDS_8_HOUR)%SECONDS_DAY;
    if( cur < base + SECONDS_9_HOUR || cur > base + SECONDS_18_HOUR) {
        return 0;
    }
    return 1;
}

int32_t sc_treasure_t::enter_round(int32_t resid_)
{
    random_t::rand_str(m_salt,16);
    m_fight_time = date_helper.cur_sec() % 3600;
    sc_msg_def::ret_treasure_enter_t ret;
    if( !is_open() )
    {
        ret.code = ERROR_TREASURE_NOT_OPEN;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_TREASURE_NOT_OPEN;
    }

    if( date_helper.offday(treasure_cache.flush_time) >= 1 )
        settle();
    ret.resid = resid_;

    //判断关卡id是否有效
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(resid_);
    if (p_r == NULL)
    {
        logerror((LOG, "enter_round, no treasure round, resid:%d", resid_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    if ((resid_ % 10 == 0) && (p_r->level > m_user.db.grade))
    {
        logerror((LOG, "enter_round, no enough level, resid:%d", resid_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    //是否有剩余次数
    auto it =  treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    int32_t last_round = 0;
    if( it != treasure_cache.conqueror_info_hm.end() )
    {
        last_round = it->second.last_round;
    }
    if( last_round == p_r->openid )
    {
        ret.salt = m_salt;
        ret.code = SUCCESS;
        logic.unicast(m_user.db.uid, ret);
        return SUCCESS;
    }
    else
    {
        ret.code = ERROR_ROUND_NO_PERMIT;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_ROUND_NO_PERMIT;
    }
}
void sc_treasure_t::gen_drop(int resid_,map<int, int>& ret_drop)
{
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(resid_);

    //生成掉落
    sc_msg_def::nt_bag_change_t nt;
    vector<vector<int>> drop = p_r->treasure_drop;
    uint32_t size = drop.size();
    for(uint32_t i=1;i < size; i++)
    {
        int drop_resid = drop[i][0];
        int drop_pro = drop[i][1];
        int drop_min = drop[i][2];
        int drop_max = drop[i][3];

        int pro = random_t::rand_integer(1, 10000);
        if( pro < drop_pro )
        {
            if (drop_min <= 0)
                drop_min = 1;
            int drop_num = random_t::rand_integer(drop_min, drop_max);
            m_user.item_mgr.addnew(drop_resid, drop_num, nt);
            ret_drop.insert(pair<int,int>(drop_resid,drop_num));
        }
    }
    m_user.item_mgr.on_bag_change(nt);
}

void sc_treasure_t::get_first_pass_treasure_reward(int32_t resid_)
{
    repo_def::treasure_t *p_r = repo_mgr.treasure.get(resid_);
    if( NULL == p_r )
    {
        logerror((LOG, "gen_drop_items, no roundid, %d", resid_));
        return;
    }
     
    auto get = [&](int item_, int num_)
    {
        if (num_ <= 0)
            return;
        sc_msg_def::nt_bag_change_t nt;
        if (item_ / 10000 == 3)
            m_user.partner_mgr.add_new_chip(item_, num_, nt.chips);
        else if (item_ == 10001)
        {
            m_user.on_money_change(num_);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(item_, num_, nt);
            bool is_empty = true;
            if (!nt.items.empty())
            {
                is_empty = false;
            }
            else if(!nt.add_wings.empty())
            {
                is_empty = false;
            }
            else if(!nt.add_pet.empty())
            {
                is_empty = false;
            }
            if (is_empty)
            {                                 
                logerror((LOG, "con reward items error!"));
                return;
            }
        }
        m_user.item_mgr.on_bag_change(nt);
    };
    
    int size = p_r->first_drop.size();
    for (size_t i = 1; i < size; ++i)
    {
        get(p_r->first_drop[i][0], p_r->first_drop[i][2]);
    }
}

int32_t sc_treasure_t::exit_round(int resid_, int win_, string salt_)
{
    sc_msg_def::ret_treasure_exit_t ret;
    ret.resid = resid_;
    ret.win = win_;
    if ( salt_ != m_salt )
    {
        logwarn((LOG, "treasure_t ERROR_SALT_FAILED, salt_: %s, m_salt: %s ", salt_.c_str(), m_salt.c_str()));
        ret.code = ERROR_SALT_FAILED;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SALT_FAILED;
    }
    m_salt = "qwertyuimnbvcxz;%";
    int cur_time = date_helper.cur_sec();
    if( cur_time < m_fight_time )
        cur_time += 3600;
    if( cur_time - m_fight_time <= 2 )
    {
        logwarn((LOG, "treasure_t ERROR time check fail"));
        ret.code = ERROR_SALT_FAILED;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SALT_FAILED;
    }

    //判断玩家当前是否在关卡战斗中
    /*
    if( !m_cur_rid || m_cur_rid != resid_ )
    {
        logerror((LOG, "exit_round, cur_rid:%d, input resid:%d, win:%d", m_cur_rid, resid_, win_));

        m_cur_rid = m_cur_drop = m_cur_count = 0;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    m_cur_rid = 0;
*/
    if( 0 == win_ )
    {
        ret.code = SUCCESS;
        logic.unicast(m_user.db.uid, ret);
        return SUCCESS;
    }

    //增加金币
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(resid_);
    m_user.on_money_change(p_r->gold);
    m_user.reward.update_opentask(open_task_treasure_round);
    
    if( m_user.db.treasure < resid_ )
    {
        //首次通关，获得通关奖励
        get_first_pass_treasure_reward(resid_);
        m_user.db.set_treasure( resid_ );
    }
    m_user.save_db();

    //增加物品
    gen_drop(resid_,ret.drops);

    //保存星魂到数据库
    /*
    if( m_cur_drop != 0 )
    {
        sc_msg_def::nt_bag_change_t nt;
        m_user.item_mgr.addnew(m_cur_drop,m_cur_count, nt);
        m_user.item_mgr.on_bag_change(nt);
    }
    */

    //记录进入次数
    auto it =  treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if( it == treasure_cache.conqueror_info_hm.end() )
    {
        it = treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0)); 
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_rob = db.n_rob;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_rob = 0;
            it->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        }
    }
    it->second.last_round = resid_;
    treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    
    return SUCCESS;
}
int32_t sc_treasure_t::pass_round()
{
    sc_msg_def::ret_treasure_pass_t ret;
    if( !is_open() )
    {
        ret.code = ERROR_TREASURE_NOT_OPEN;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_TREASURE_NOT_OPEN;
    }

    if( date_helper.offday(treasure_cache.flush_time) >= 1 )
        settle();
        
    ret.code = SUCCESS;

    auto it =  treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    int32_t start=0,end=0,current=0,sum=0;
    if( it != treasure_cache.conqueror_info_hm.end() )
    {
        if( it->second.last_round != 0 )
            start = current = it->second.last_round+1;
        else
            start = current = START_ROUND;
    }
    else
    {
        it = treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        start = current = START_ROUND;
    }

    //打关卡
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(current);
    int n1=0,n2=0;
    bool update_db_flag = false;
    while( (current<=m_user.db.treasure)&&(p_r!=NULL) )
    {
        update_db_flag = true;
        //生成掉落
        sc_msg_def::treasure_drop_t drop;
        drop.floor = current;
        drop.coin = p_r->gold;
        gen_drop(current,drop.drops);
        ret.drops.push_back(std::move(drop));
/*
        switch( drop.resid )
        {
            case 20001:++n1;break;
            case 20002:++n2;break;
        }*/
        sum += drop.coin;
        end = it->second.last_round = current;
        ++current;
        p_r = repo_mgr.treasure.get(current);
        m_user.reward.update_opentask(open_task_treasure_round);
    }
    if (update_db_flag){
        treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    }
    //保存金币
    if( sum != 0 )
    {
        m_user.on_money_change(sum);
        m_user.save_db();
    }
    /*
    //保存星魂
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(20001,n1,nt);
    m_user.item_mgr.addnew(20002,n2,nt);
    m_user.item_mgr.on_bag_change(nt);
*/

    ret.start = start;
    ret.last = end;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}
int32_t sc_treasure_t::occupy_blank(int32_t pos_)
{
    if(!is_open()) {
        return ERROR_TREASURE_NOT_OPEN;
    }

    if( pos_<0 || pos_>=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
    {
        logerror((LOG, "fight,illeagl slot id: %d", pos_));
        return ERROR_SC_ILLEGLE_REQ;
    }
    auto itt = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
    if (itt != treasure_cache.coopertive_info_hm.end() && itt->second.slot_pos != -1) // 此玩家有协守信息
        return ERROR_TREASURE_OCCUPY_HELP;

    auto it=treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if( it==treasure_cache.conqueror_info_hm.end() )
    {
        it =treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0));
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_rob = db.n_rob;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_rob = 0;
            it->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        }
    }
    
    if( it->second.slot_pos!=-1 )
        return ERROR_TREASURE_HAS_SLOT;
    if( it->second.debian_secs >= MAX_DEBIAN )
        return ERROR_TREASURE_NO_SECONDS;

    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if( t.uid!=0 )
        return ERROR_TREASURE_FULL_SLOT;
    logwarn((LOG, "occupy blank success, uid = %d", m_user.db.uid));
    logwarn((LOG, "occupy blank success, pos = %d", pos_));
    logwarn((LOG, "occupy blank success, current time = %d", date_helper.cur_sec()));
    int32_t sec_now = date_helper.cur_sec();
    //填充坑位
    t.uid = m_user.db.uid;
    t.resid = m_user.db.resid;
    t.nickname = m_user.db.nickname();
    t.fp = m_user.db.fp;
    t.grade = m_user.db.grade;
    t.stamp = sec_now;
    t.n_rob = 0;
    t.rob_money = 0;
    t.lovelevel = m_user.db.lovelevel;
/*
    db_TreasureSlot_t sdb;
    sdb.uid = m_user.db.uid;
    sdb.hostnum = m_user.db.hostnum;
    cout<<"hostnum->"<<m_user.db.hostnum<<endl;
    sdb.slot_type = SLOT_TYEP_SLOTS;
    sdb.slot_pos = pos_;
    sdb.resid = m_user.db.resid;      
    sdb.nickname = m_user.db.nickname();
    sdb.fp = m_user.db.fp;
    sdb.grade = m_user.db.grade;
    sdb.stamp = sec_now;
    sdb.n_rob = 0;
    sdb.rob_money = 0;
    sdb.lovelevel = m_user.db.lovelevel;
    treasure_cache.merge_robers(t.robers,sdb.robers);
    cout<<"1--->"<<endl;

    sql_result_t sres;
    char sql[256];
    sprintf(sql, "select * from TreasureSlot  where slot_type = %d AND slot_pos = %d AND hostnum = %d", SLOT_TYEP_SLOTS,pos_,m_user.db.hostnum);
    if (0 == db_service.sync_select(sql, sres)){
    cout<<"2--->"<<endl;
        if (t.is_pvp_fighting)
            sdb.is_pvp_fighting = 1;      
        else 
            sdb.is_pvp_fighting = 0;
        sdb.begin_pvp_fight_time = t.begin_pvp_fight_time;
        sdb.sync_update();
    }
    else
    {
        cout<<"3--->"<<endl;
        sdb.is_pvp_fighting = 0;
        sdb.begin_pvp_fight_time = 0;
        sdb.sync_insert();
    }
    */
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,m_user.db.hostnum);
    
    //填充占领者信息
    it->second.slot_pos = pos_;
    it->second.last_stamp = sec_now;
    treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    
    //任务
    m_user.daily_task.on_event(evt_treasure_occupy);
    
    return SUCCESS;
}
int32_t sc_treasure_t::giveup_slot(int32_t &left_secs_)
{
    left_secs_ = 0;
    int32_t rob_money = 0, ret, pos = -1;
    auto it = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if (it == treasure_cache.conqueror_info_hm.end())
        pos = it->second.slot_pos;
    uint32_t sec_now = date_helper.cur_sec();
    if ((ret = settle_owner(sec_now, left_secs_, pos, rob_money)) != SUCCESS) 
    {
        logerror((LOG, "give up slot error, settle owner wrong, uid = %d", m_user.db.uid));    
        return ret;
    }
    if ((ret = settle_helper(pos, sec_now, rob_money, "", false)) != SUCCESS) 
    {
        logerror((LOG, "give up slot error, settle helper wrong!!!!!  pos = :%d", pos));
        return ret;
    }
    return SUCCESS;
}
int32_t sc_treasure_t::occupy_fight(int32_t pos_,int32_t uid_,sc_msg_def::ret_treasure_fight_t &ret)
{
    if( !is_open() ) {
        return ERROR_TREASURE_NOT_OPEN;
    }

    if( pos_<0 || pos_>=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
    {
        logerror((LOG, "fight,illeagl slot id: %d", pos_));
        return ERROR_SC_ILLEGLE_REQ;
    }
    //自己是否有资格占坑
    auto it=treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if (it==treasure_cache.conqueror_info_hm.end())
    {
        it =treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0));
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_rob = db.n_rob;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_rob = 0;
            it->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        }
    }
    if (it->second.slot_pos!=-1)
        return ERROR_TREASURE_HAS_SLOT;
    if (it->second.debian_secs >= MAX_DEBIAN)
        return ERROR_TREASURE_NO_SECONDS;
    int32_t last_round = it->second.last_round;
    if( last_round != 0 )
        last_round -= 4000;
    if( pos_ > (last_round*4-1) )
        return ERROR_SC_ILLEGLE_REQ;
    treasure_srv_slot_t &k = treasure_cache.helps[pos_];
    if (k.uid == m_user.db.uid)
        return ERROR_TREASURE_HELP_SLOT;
    
    auto itt = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
    if (itt != treasure_cache.coopertive_info_hm.end() && itt->second.slot_pos != -1) // 此玩家有协守信息
        return ERROR_TREASURE_OCCUPY_HELP;

    //获取施法者数据
    sp_view_user_t sp_cast_data = view_cache.get_view(m_user.db.uid);
    if (sp_cast_data == NULL)
        return ERROR_SC_EXCEPTION;

    unordered_map<int32_t, int32_t> l_hp;
    treasure_srv_slot_t &h = treasure_cache.helps[pos_];
    if (h.uid != 0) {
        sp_view_user_t sp_help_data = view_cache.get_view(h.uid, true);
        if (sp_help_data == NULL)
            return ERROR_SC_EXCEPTION;
        (*sp_help_data) >> ret.help_data;
    }

    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    //如果是自己的坑位则不能抢占
    if (t.uid == m_user.db.uid)
        return ERROR_TREASURE_OCCUPY_OWN_SLOT; 
    sp_view_user_t sp_target_data = view_cache.get_view(t.uid, true);
    if (sp_target_data == NULL)
        return ERROR_SC_EXCEPTION;
    (*sp_target_data) >> ret.target_data;
    if (t.is_pvp_fighting && (date_helper.cur_sec() - t.begin_pvp_fight_time) <= MAX_PVP_FIGHT_TIME)
        return ERROR_TREASURE_PVP_FIGHTING;
    m_pos = pos_;
    t.is_pvp_fighting = true;
    t.begin_pvp_fight_time = date_helper.cur_sec();
    
    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
    if (ret_hostnum == HOSTNUMERROR)
        return FAILED;
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);
    random_t::rand_str(ret.salt, 16);

    return SUCCESS;
}
int32_t sc_treasure_t::occupy_fight_end(sc_msg_def::req_treasure_fight_end_t &jpk_, sc_msg_def::ret_treasure_fight_end_t &ret)
{
    if(m_pos <0 || m_pos >=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
        return ERROR_SC_EXCEPTION;

    sp_jpk_treasure_record_t sp_record(new sc_msg_def::jpk_treasure_record_t);
    sp_record->time = date_helper.cur_sec();
    sp_record->elapsed = 0;
    sp_record->uid = m_user.db.uid;
    sp_record->name = m_user.db.nickname();
    sp_record->lv = m_user.db.grade;

    treasure_srv_slot_t &t = treasure_cache.slots[m_pos];
    uint32_t formeruid = t.uid;
    t.is_pvp_fighting = false;
    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
    if (ret_hostnum == HOSTNUMERROR)
        return FAILED;
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,m_pos,ret_hostnum);
    sp_view_user_t sp_target_data = view_cache.get_view(t.uid, true);
    if (sp_target_data == NULL)
        return ERROR_SC_EXCEPTION;

    sp_record->uid2 = sp_target_data->uid;
    sp_record->name2 = sp_target_data->name;
    for(auto it=sp_target_data->roles.begin(); it!=sp_target_data->roles.end(); it++) {
        if (it->second.pid == 0) {
            sp_record->lv2 = it->second.lvl.level;
            break;
        }
    }
    sp_record->flag = 2;
    sp_record->is_win = jpk_.is_win;
    sp_record->money = 0;

    uint32_t sec_now = date_helper.cur_sec();
    int32_t rob_money = 0;
    int32_t res = settle_owner(m_pos, sec_now, rob_money);
    if (res == SUCCESS) {
        settle_helper(m_pos, sec_now, rob_money, "", false);
        return ERROR_TREASURE_EMPTY_SLOT;
    }
    else if (res != FAILED) return res;
    
    //初始化pos
    ret.pos = -1;
    if (jpk_.is_win)
    {
        uint32_t debian_secs_ = 0;
        int32_t money_all = 0;
        int32_t last_stamp = t.stamp;
        string name = t.nickname;
        settle_owner_and_occupy(m_pos, sec_now, debian_secs_, money_all, rob_money);
        //返回层数
        ret.pos = m_pos;
        if (m_pos == -1)
            logerror((LOG, "occupy_fight_end error, pos == -1"));
        settle_helper(m_pos, sec_now, rob_money, name, true);
        
        logwarn((LOG, "owner is kicked out, former owner uid = %d", formeruid));
        logwarn((LOG, "owner is kicked out, pos = %d", m_pos));
        logwarn((LOG, "owner is kicked out, is settle helper success = %d", settle_helper(m_pos, sec_now, rob_money, name, true)));

        sp_user_t user;
        if( logic.usermgr().get(t.uid,user) )
        {
            sc_msg_def::nt_treasure_kick_out_t nt;
            nt.left_secs = MAX_DEBIAN - debian_secs_;
            if( nt.left_secs < 0 )
                nt.left_secs = 0;
            nt.coin = money_all;
            nt.lv = m_user.db.grade;
            nt.name = m_user.db.nickname();
            
            logic.unicast(formeruid, nt);
        }
        
        //生成复仇记录
        sc_revenge_record_t rec;
        rec.uid = m_user.db.uid;
        rec.lv = m_user.db.grade;
        rec.lovelevel = m_user.db.lovelevel;
        rec.resid = m_user.db.resid;
        rec.nickname = m_user.db.nickname();
        treasure_cache.add_revenge(formeruid,rec);

        //占领者信息改变
        auto it = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
        if (it == treasure_cache.conqueror_info_hm.end())
        {
            it = treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid, conqueror_info_t())).first;
            db_TreasureConqueror_t db;
            sql_result_t res;
            if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
                db.init(*res.get_row_at(0));
                it->second.last_round = db.last_round;
                it->second.debian_secs = db.debian_secs;
                it->second.slot_pos = db.slot_pos;
                it->second.last_stamp = db.last_stamp;
                it->second.n_rob = db.n_rob;
                it->second.profit = db.profit;
            }
            else {
                it->second.last_round = 0;
                it->second.debian_secs = 0;
                it->second.slot_pos = -1;
                it->second.last_stamp = 0;
                it->second.n_rob = 0;
                it->second.profit = 0;
                treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
            }
        }
        if (it->second.slot_pos != -1)
            return ERROR_TREASURE_HAS_SLOT;
        if (it->second.debian_secs >= MAX_DEBIAN)
            return ERROR_TREASURE_NO_SECONDS;
        it->second.slot_pos = m_pos;
        it->second.last_stamp = sec_now;
        treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        //任务
        m_user.daily_task.on_event(evt_treasure_occupy);
    }

    treasure_cache.add_record(sp_record->uid,sp_record);
    treasure_cache.add_record(sp_record->uid2,sp_record);
    m_pos = -1;

    return SUCCESS;
}
void sc_treasure_t::put_reward(int32_t uid_,int32_t money_,int32_t now_profit_)
{
    //发放金钱
    sp_user_t user;
    int32_t online = 0;
    if((online=logic.usermgr().get(uid_,user)) || cache.get(uid_,user))
    {
        if(money_ > 0)
        {
            user->on_money_change(money_);
            user->save_db();
        }
        sc_msg_def::nt_treasure_profit_t nt;
        nt.now = now_profit_;
        logic.unicast(uid_, nt);
    }
    else if(money_ > 0)
    {
        db_service.async_do((uint64_t)uid_,[](int uid_,int money_){
            char buf[256];
            sprintf(buf,"update UserInfo set gold=gold+%d where uid=%d",money_,uid_);
            db_service.async_execute(buf);
        }, uid_,money_);
    }
}
int32_t sc_treasure_t::give_slot_to_occupy(int32_t uid_, int32_t pos_)
{
    if (pos_ < 0 || pos_ >= int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
    {
        logerror((LOG, "give slot to occupy error, pos = %d", pos_));
        return ERROR_SC_ILLEGLE_REQ;
    }

    auto it = treasure_cache.coopertive_info_hm.find(uid_);
    if (it == treasure_cache.coopertive_info_hm.end()) 
    {
        logerror((LOG, "give slot to occupy  error, is not helping, uid = %d", uid_));
        it = treasure_cache.coopertive_info_hm.insert(make_pair(m_user.db.uid, coopertive_info_t())).first;
        db_TreasureCoopertive_t db;
        sql_result_t res;
        if (0 == db_TreasureCoopertive_t::sync_select_uid(uid_,res)){
            db.init(*res.get_row_at(0)); 
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_help = db.n_help;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_help = 0;
            it->second.profit = 0;
            treasure_cache.insert_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);      
        }
    }


    if (it->second.slot_pos != -1)
    {
        treasure_srv_slot_t &h = treasure_cache.helps[it->second.slot_pos];
        if (h.uid != uid_)
            logerror((LOG, "give slot to occupy error, info not correct , h.uid = %d", h.uid));
        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(h.uid);
        if (ret_hostnum == HOSTNUMERROR)
            return FAILED;
        h.uid = 0;
        h.resid = 0;
        h.nickname = ""; 
        treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,it->second.slot_pos,ret_hostnum);
    }
    
    if (it->second.n_help == 1 )
    {
        if (it->second.slot_pos != -1)
        {
            int32_t sec_now = date_helper.cur_sec();
            int32_t rob_money = 0;
            auto tt = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
            int32_t totalincome = 0;
            if (tt != treasure_cache.conqueror_info_hm.end())
            {
                totalincome = tt->second.profit;
            }
            //协守者收益
            int32_t help_money = cal_help_money(it->second.slot_pos, it->second.last_stamp, sec_now, rob_money);
            it->second.profit += help_money;
            it->second.profit += totalincome;
            put_reward(m_user.db.uid, help_money, it->second.profit);

            treasure_srv_slot_t &owner = treasure_cache.slots[it->second.slot_pos];
            string mail = mailinfo.new_mail(mail_treasure_help, owner.nickname, help_money);
            if (!mail.empty()) notify_ctl.push_mail(m_user.db.uid, mail);
        }
    }

    sc_msg_def::nt_treasure_help_end_t nt;
    nt.n_help = it->second.n_help;
    nt.pos = 0;
    logic.unicast(uid_, nt);

    it->second.slot_pos = -1;
    it->second.last_round = it->second.slot_pos;
    it->second.debian_secs += date_helper.cur_sec() - it->second.last_stamp;
    it->second.last_stamp = 0;
    treasure_cache.update_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);

    return SUCCESS;
}

int32_t sc_treasure_t::giveup_help(int32_t uid_)
{
    auto it = treasure_cache.coopertive_info_hm.find(uid_);
    if (it == treasure_cache.coopertive_info_hm.end()) 
    {
        logerror((LOG, "give slot to occupy  error, is not helping, uid = %d", uid_));
        it = treasure_cache.coopertive_info_hm.insert(make_pair(m_user.db.uid, coopertive_info_t())).first;
        sql_result_t res;
        db_TreasureCoopertive_t db;
        if (0 == db_TreasureCoopertive_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0)); 
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_help = db.n_help;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_help = 0;
            it->second.profit = 0;
            treasure_cache.insert_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);      
        }
    }
   
    if (it->second.slot_pos != -1)
    {
        treasure_srv_slot_t &h = treasure_cache.helps[it->second.slot_pos];
        if (h.uid != uid_)
            logerror((LOG, "give slot to occupy error, info not correct , h.uid = %d", h.uid));
        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(h.uid);
        if (ret_hostnum == HOSTNUMERROR)
            return FAILED;
        h.uid = 0;
        h.resid = 0;
        h.nickname = ""; 
        treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,it->second.slot_pos,ret_hostnum);
    }
    
    if (it->second.n_help == 1 )
    {
        if (it->second.slot_pos != -1)
        {
            int32_t sec_now = date_helper.cur_sec();
            int32_t rob_money = 0;
            auto tt = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
            int32_t totalincome = 0;
            if (tt != treasure_cache.conqueror_info_hm.end())
            {
                totalincome = tt->second.profit;
            }
            //协守者收益
            int32_t help_money = cal_help_money(it->second.slot_pos, it->second.last_stamp, sec_now, rob_money);
            it->second.profit += help_money;
            it->second.profit += totalincome;
            put_reward(m_user.db.uid, help_money, it->second.profit);

            treasure_srv_slot_t &owner = treasure_cache.slots[it->second.slot_pos];
            string mail = mailinfo.new_mail(mail_treasure_help, owner.nickname, help_money);
            if (!mail.empty()) notify_ctl.push_mail(m_user.db.uid, mail);
        }
    }
    sc_msg_def::nt_treasure_help_end_t nt;
    nt.n_help = it->second.n_help;
    nt.pos = 0;
    logic.unicast(uid_, nt);

    it->second.slot_pos = -1;
    it->second.last_round = it->second.slot_pos;
    it->second.debian_secs += date_helper.cur_sec() - it->second.last_stamp;
    it->second.last_stamp = 0;
    treasure_cache.update_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);

    return SUCCESS;
}

int32_t sc_treasure_t::help(int32_t pos_)
{
    if( !is_open() ) {
        return ERROR_TREASURE_NOT_OPEN;
    }

    if (pos_<0 || pos_>=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
    {
        logerror((LOG, "help,illeagl slot id: %d", pos_));
        return ERROR_SC_ILLEGLE_REQ;
    }
    
    //确认玩家是否占领了宝库
    auto itt =  treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if( itt==treasure_cache.conqueror_info_hm.end() )
    {
        itt =treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0));
            itt->second.last_round = db.last_round;
            itt->second.debian_secs = db.debian_secs;
            itt->second.slot_pos = db.slot_pos;
            itt->second.last_stamp = db.last_stamp;
            itt->second.n_rob = db.n_rob;
            itt->second.profit = db.profit;
        }
        else {
            itt->second.last_round = 0;
            itt->second.debian_secs = 0;
            itt->second.slot_pos = -1;
            itt->second.last_stamp = 0;
            itt->second.n_rob = 0;
            itt->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,itt->second,m_user.db.hostnum);
        }
    }
    if( itt->second.slot_pos!=-1 )//玩家占领了就不能协守
        return ERROR_TREASURE_OCCUPY_HELP;
         
    auto it = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
    if (it == treasure_cache.coopertive_info_hm.end()) // 无此玩家协守信息
    {
        it = treasure_cache.coopertive_info_hm.insert(make_pair(m_user.db.uid, coopertive_info_t())).first;
        sql_result_t res;
        db_TreasureCoopertive_t db;
        if (0 == db_TreasureCoopertive_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0)); 
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_help = db.n_help;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_help = 0;
            it->second.profit = 0;
            treasure_cache.insert_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);      
        }
    }
    if (it->second.slot_pos != -1) // 有人协守
        return ERROR_TREASURE_HAS_SLOT;

    treasure_srv_slot_t &h = treasure_cache.helps[pos_]; // 获取服务器协守坑位
    if (h.uid != 0) // 有人协守
        return ERROR_TREASURE_FULL_SLOT;
    //如果坑位无人占领则不让协守
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if( 0 == t.uid )
        return ERROR_TREASURE_EMPTY_SLOT;

    int32_t sec_now = date_helper.cur_sec();
    //填充坑位
    h.uid = m_user.db.uid;
    h.resid = m_user.db.resid;
    h.nickname = m_user.db.nickname();
    h.fp = m_user.db.fp;
    h.grade = m_user.db.grade;
    h.stamp = sec_now;
    h.n_rob = 0;
    h.rob_money = 0;
    h.lovelevel = m_user.db.lovelevel;
    treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,pos_,m_user.db.hostnum);
    //填充协守者信息
    it->second.slot_pos = pos_;
    it->second.last_stamp = sec_now;
    it->second.n_help++; // 协守次数加1
    treasure_cache.update_coopertive_db(m_user.db.uid,it->second,m_user.db.hostnum);
    return SUCCESS;
}
int32_t sc_treasure_t::rob(int32_t pos_,int32_t uid_,sc_msg_def::ret_treasure_rob_t &ret)
{
    if( !is_open() ) {
        return ERROR_TREASURE_NOT_OPEN;
    }

    if( pos_<0 || pos_>=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
    {
        logerror((LOG, "rob,illeagl slot id: %d", pos_));
        return ERROR_SC_ILLEGLE_REQ;
    }
    //自己是否有打劫资格
    auto it=treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if( it==treasure_cache.conqueror_info_hm.end() )
    {
        it =treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0));
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_rob = db.n_rob;
            it->second.profit = db.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_rob = 0;
            it->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        }
    }
    if( it->second.n_rob >= N_ROB_ALL )
        return ERROR_TREASURE_NO_ROB;
    int32_t last_round = it->second.last_round;
    if( last_round != 0 )
        last_round -= 4000;
    if( pos_ > (last_round*4-1) )
        return ERROR_SC_ILLEGLE_REQ;
    //坑是否与客户端一致
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if( 0==t.uid )
        return ERROR_TREASURE_EMPTY_SLOT;
    if( t.uid != uid_ )
        return ERROR_TREASURE_SLOT_CHANGED;
    //不能掠夺自己的坑位
    if (t.uid == m_user.db.uid)
        return ERROR_TREASURE_ROB_OWN_SLOT;
    if (t.is_pvp_fighting && (date_helper.cur_sec() - t.begin_pvp_fight_time) <= MAX_PVP_FIGHT_TIME)
        return ERROR_TREASURE_PVP_FIGHTING;

    //坑是否还有打劫次数
    if( t.n_rob >= N_ROB_PER_SLOT )
        return ERROR_TREASURE_ROB_ALL;
    //是否被同一人打劫过
    for( auto it_v=t.robers.begin();it_v!=t.robers.end();++it_v )
    {
        if ( (*it_v)==m_user.db.uid )
            return ERROR_TREASURE_SLOT_ROBED;
    }


    treasure_srv_slot_t &h = treasure_cache.helps[pos_];
    if (h.uid != 0) {
        if (h.uid == m_user.db.uid)
            return ERROR_TREASURE_HELP_SLOT;
        sp_view_user_t sp_help_data = view_cache.get_view(h.uid, true);
        (*sp_help_data) >> ret.help_data;
    }

    sp_view_user_t sp_target_data = view_cache.get_view(t.uid, true);
    if (sp_target_data == NULL)
        return ERROR_SC_EXCEPTION;
    (*sp_target_data) >> ret.target_data;

    m_pos = pos_;
    (it->second.n_rob)++;
    treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    t.is_pvp_fighting = true;
    t.begin_pvp_fight_time = date_helper.cur_sec();
    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
    if (ret_hostnum == HOSTNUMERROR)
        return FAILED;
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);
    return SUCCESS;
}
int32_t sc_treasure_t::rob_end(sc_msg_def::req_treasure_rob_end_t &jpk_, sc_msg_def::ret_treasure_rob_end_t &ret)
{
    if(m_pos <0 || m_pos >=int(repo_mgr.treasure.size())*SLOT_PER_FLOOR)
        return ERROR_SC_EXCEPTION;
    
    logwarn((LOG, "treasure rob end ! pos  = %d",m_pos));
    treasure_srv_slot_t &t = treasure_cache.slots[m_pos];
    if (t.uid <= 0)
        return ERROR_TREASURE_EMPTY_SLOT;
    t.is_pvp_fighting = false;
    sp_view_user_t sp_target_data = view_cache.get_view(t.uid, true);
    if (sp_target_data == NULL)
        return ERROR_SC_EXCEPTION;
    //生成战报
    sp_jpk_treasure_record_t sp_record(new sc_msg_def::jpk_treasure_record_t);
    sp_record->time = date_helper.cur_sec();
    sp_record->elapsed = 0;
    sp_record->uid = m_user.db.uid;
    sp_record->name = m_user.db.nickname();
    sp_record->lv = m_user.db.grade;
    sp_record->uid2 = sp_target_data->uid;
    sp_record->name2 = sp_target_data->name;
    for(auto it=sp_target_data->roles.begin(); it!=sp_target_data->roles.end(); it++)
    {
        if (it->second.pid == 0)
        {
            sp_record->lv2 = it->second.lvl.level;
            break;
        }
    }
    sp_record->flag = 1;
    sp_record->is_win = jpk_.is_win;

    if (jpk_.is_win)
    {
        uint32_t sec_now = date_helper.cur_sec();
        //计算金钱
        auto it=treasure_cache.conqueror_info_hm.find(t.uid);
        if( it==treasure_cache.conqueror_info_hm.end() )
        {
            db_TreasureConqueror_t db;
            sql_result_t res;
            if (0==db_TreasureConqueror_t::sync_select_uid(t.uid,res)){
                db.init(*res.get_row_at(0));
                it =treasure_cache.conqueror_info_hm.insert(make_pair(t.uid,conqueror_info_t())).first;
                it->second.last_round = db.last_round;
                it->second.debian_secs = db.debian_secs;
                it->second.slot_pos = db.slot_pos;
                it->second.last_stamp = db.last_stamp;
                it->second.n_rob = db.n_rob;
                it->second.profit = db.profit;
            }
        }
        if( it==treasure_cache.conqueror_info_hm.end() )
            return ERROR_SC_EXCEPTION;
        int32_t totalmoney = cal_money(m_pos, t.stamp, sec_now, it->second.debian_secs, t.uid) - t.rob_money;
        
        sql_result_t resu;
        char sel[256];
        sprintf(sel, "select viplevel from UserInfo where uid=%d", t.uid);
        db_service.sync_select(sel, resu);
        int32_t viplevel = 0;
        if (resu.affect_row_num() > 0)
        {
            sql_result_row_t rt = *resu.get_row_at(0);
            viplevel = (int)std::atoi(rt[0].c_str());
        }
        
        if (viplevel >= 7)
            totalmoney /= 1.6;
        ret.money = totalmoney * PERCENT_ROB;
        int32_t delta = m_user.db.grade-t.grade;
        if(delta >= 15)
            ret.money *= 0.5 ;
        else if( delta >= 10 )
            ret.money *= ( 1-0.05f*(delta-5) );
        if (ret.money < 0) {
            logerror((LOG, "rob_end error, logic error, rob money < 0, rob_money:%d !", ret.money));
            logerror((LOG, "rob_end error, logic error, rob money < 0, duration:%d !", sec_now - t.stamp));
            logerror((LOG, "rob_end error, logic error, rob money < 0, rob money :%d !", t.rob_money));
            logerror((LOG, "rob_end error, logic error, rob money < 0, rob money :%d !", it->second.debian_secs));
            ret.money = 0;
        }
        auto tt = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
        int32_t totalincome = 0;
        if (tt != treasure_cache.coopertive_info_hm.end())
        {
            totalincome = tt->second.profit;
        }
        auto con = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
        if (con != treasure_cache.conqueror_info_hm.end())
        {
            con->second.profit += ret.money;
        }
        put_reward(m_user.db.uid, ret.money, (con->second.profit + totalincome));
        t.n_rob++;
        logwarn((LOG,"before rob end, slot rob money = %d", t.rob_money));
        t.rob_money += ret.money;
        logwarn((LOG,"after rob end, slot rob money = %d", t.rob_money));
        t.robers.push_back(m_user.db.uid);

        //推送信封
        string mail = mailinfo.new_mail(mail_treasure_robbed, date_helper.str_date(), m_user.db.nickname(), ret.money); 
        if (!mail.empty()) notify_ctl.push_mail(t.uid, mail);
            
        //生成复仇记录
        sc_revenge_record_t rec;
        rec.uid = m_user.db.uid;
        rec.lv = m_user.db.grade;
        rec.lovelevel = m_user.db.lovelevel;
        rec.resid = m_user.db.resid;
        rec.nickname = m_user.db.nickname();
        treasure_cache.add_revenge(t.uid,rec);
        
        //任务
        //m_user.daily_task.on_event(evt_treasure_occupy);
    }
    else ret.money = 0;
    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
    if (ret_hostnum == HOSTNUMERROR)
        return FAILED;
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,m_pos,ret_hostnum);
    sp_record->money = ret.money;
    treasure_cache.add_record(sp_record->uid,sp_record);
    treasure_cache.add_record(sp_record->uid2,sp_record);

    m_pos = -1;
    return SUCCESS;
}
void sc_treasure_t::get_gang_name(int32_t uid, string &gangname)
{
    char sql1[256];
    sql_result_t res1;
    sprintf(sql1,  "select ggid from GangUser where uid=%d;",uid);
    db_service.sync_select(sql1, res1);
    if (0 == res1.affect_row_num())
    {
        gangname = "未加入公会";
        return;
    }
    char sql2[256];
    sql_result_t res2;
    sql_result_row_t& row1 = *res1.get_row_at(0);
    sprintf(sql2, "select name from Gang where ggid=%d",(int)std::atoi(row1[0].c_str()) );
    db_service.sync_select(sql2, res2);
    if (0 == res2.affect_row_num())
    {
        gangname = "获取公会名失败";
        return;
    }
    sql_result_row_t& row2 = *res2.get_row_at(0);
    gangname = row2[0];
}
int32_t sc_treasure_t::get_jpk(int32_t floor_,sc_msg_def::ret_treasure_floor_t &ret)
{
    if( date_helper.offday(treasure_cache.flush_time) >= 1 )
        settle();
    if (floor_<1 || floor_ > int(repo_mgr.treasure.size()) )
        return ERROR_SC_ILLEGLE_REQ;
    for( int i=floor_*SLOT_PER_FLOOR-4;i<floor_*SLOT_PER_FLOOR;++i )
    {
        int32_t sec_now = date_helper.cur_sec();
        int32_t rob_money = 0;
        int res = settle_owner(i, sec_now, rob_money);
        if (res == SUCCESS)
            settle_helper(i, sec_now, rob_money, "", false);
        else if (res == ERROR_SC_ILLEGLE_REQ){
            return ERROR_SC_EXCEPTION;
        }

        treasure_srv_slot_t &t = treasure_cache.slots[i];
        sc_msg_def::treasure_cli_slot_t slot;
        if( t.uid == 0 )  //当前关卡没有占领者
        {    
            slot.uid = 0;
            slot.stamp = 0;
            slot.resid =  0;
            slot.grade = 0;
            slot.fp =  0;
            slot.n_help = 0;
            slot.n_rob = 0;
            slot.rob_money = 0;
            slot.lovelevel = 0;
            slot.viplevel = 0;
        }
        else
        {
            //顺便更新角色数据
            slot.fp = 0;
            slot.lovelevel = 0;
            sp_user_t user;
            if( logic.usermgr().get(t.uid,user) || cache.get(t.uid,user) )
            {
                //t.nickname = user->db.nickname();
                //t.grade = user->db.grade;
                slot.fp = user->db.fp;
                slot.lovelevel = user->db.lovelevel;
                slot.viplevel = user->db.viplevel;
            }else
            {
                sql_result_t resu;
                char sel[256];
                sprintf(sel, "select viplevel from UserInfo where uid=%d", t.uid);
                db_service.sync_select(sel, resu);
                slot.viplevel = 0;
                if (resu.affect_row_num() > 0)
                {
                    sql_result_row_t rt = *resu.get_row_at(0);
                    slot.viplevel = (int)std::atoi(rt[0].c_str());
                }
            }
            slot.uid = t.uid;
            slot.resid = t.resid;
            slot.nickname = t.nickname;
            get_gang_name(t.uid, slot.gangname);
            slot.grade = t.grade;
            slot.stamp = date_helper.cur_sec() - t.stamp;  //返回已经占领时间
            slot.n_rob = t.n_rob;
            slot.rob_money = t.rob_money;
            slot.n_help = 0;
            auto con = treasure_cache.coopertive_info_hm.find(t.uid);
            if (con == treasure_cache.coopertive_info_hm.end()){
                sql_result_t res;
                db_TreasureCoopertive_t db;
                if (0 == db_TreasureCoopertive_t::sync_select_uid(t.uid,res)){
                    db.init(*res.get_row_at(0)); 
                    con = treasure_cache.coopertive_info_hm.insert(make_pair(t.uid, coopertive_info_t())).first;
                    con->second.last_round = db.last_round;
                    con->second.debian_secs = db.debian_secs;
                    con->second.slot_pos = db.slot_pos;
                    con->second.last_stamp = db.last_stamp;
                    con->second.n_help = db.n_help;
                    con->second.profit = db.profit;
                }
            }
            if (con != treasure_cache.coopertive_info_hm.end())
                slot.n_help = con->second.n_help;
            
            char sql[1024];
            sql_result_t res;
            sprintf(sql, "select p1, p2, p3, p4, p5 from Team where uid=%d and is_default=1;",t.uid );
            db_service.sync_select(sql, res);
            if (0 == res.affect_row_num())    //没有找到
            {
                //更新队伍信息
                sc_msg_def::treasure_team_info_t team_info;
                for (int i =0; i < 5; ++i)
                {
                    sc_msg_def::team_member_info_t member_info;    
                    member_info.level = 0;
                    member_info.lovelevel = 0;
                    member_info.starnum = 0;
                    member_info.pid = -1;
                    member_info.equiplv = 0;
                    member_info.resid = 0;
                    if (i == 0)
                        team_info.hero1.push_back(member_info);
                    if (i == 1)
                        team_info.hero2.push_back(member_info);
                    if (i == 2)
                        team_info.hero3.push_back(member_info);
                    if (i == 3)
                        team_info.hero4.push_back(member_info);
                    if (i == 4)
                        team_info.hero5.push_back(member_info);
                }
                slot.team_info.push_back(team_info);
            }else {
                    //更新队伍信息
                     sc_msg_def::treasure_team_info_t team_info;
                //去Equip表查找装备信息
                //for (int32_t i = 0; i < res.affect_row_num(); ++i) 只可能有一支默认队伍
               // {
                    sql_result_row_t row = *res.get_row_at(0);
                    for (int n = 0; n < 5; ++n)
                    {
                        if ( ((int)std::atoi(row[n].c_str())) >= 0)   //这个位置有英雄
                        {
                            sc_msg_def::team_member_info_t member_info;
                            if ( (int)std::atoi(row[n].c_str()) == 0  )
                            {
                                sql_result_t buf;
                                char sel[256];
                                sprintf(sel, "select quality,lovelevel,resid from UserInfo where uid=%d;",t.uid );
                                db_service.sync_select(sel, buf);
                                if (0 == buf.affect_row_num())    //没有找到
                                {    
                                    member_info.starnum = 1;
                                    member_info.lovelevel = 0;
                                    member_info.resid = 0;
                                }else {
                                    sql_result_row_t& row = *buf.get_row_at(0);
                                    member_info.starnum = (int)std::atoi(row[0].c_str());
                                    member_info.lovelevel = (int)std::atoi(row[1].c_str());
                                    member_info.resid = (int)std::atoi(row[2].c_str());
                                }
                                member_info.level = t.grade;
                            }else {
                                get_level_info(t.uid, (int)std::atoi(row[n].c_str()), member_info.level, member_info.lovelevel, member_info.starnum, member_info.resid);
                            }
                            member_info.equiplv = sc_user_t::get_equip_level(t.uid, (int)std::atoi(row[n].c_str()));
                            member_info.pid = (int)std::atoi(row[n].c_str());
                            if (n == 0)
                                team_info.hero1.push_back(member_info);
                            if (n == 1)
                                team_info.hero2.push_back(member_info);
                            if (n == 2)
                                team_info.hero3.push_back(member_info);
                            if (n == 3)
                                team_info.hero4.push_back(member_info);
                            if (n == 4)
                                team_info.hero5.push_back(member_info);
                        }
                    }
                    slot.team_info.push_back(team_info);
                //}
           }
            //get_team_fp(t.uid, slot.fp);  //整个队伍的信息
            sp_view_user_t sp_view = view_cache.get_view(t.uid, true);
            int totalfp = 0;
            for (auto su = sp_view->roles.begin(); su!= sp_view->roles.end(); su++)
            {
                totalfp += su->second.pro.fp;
            }
            slot.fp = totalfp;
        }
        ret.slots.push_back( slot );

        //helper
        treasure_srv_slot_t &h = treasure_cache.helps[i];
        sc_msg_def::treasure_cli_slot_t cli_helper;
        if (h.uid == 0)
        {
            cli_helper.uid = 0;
            cli_helper.stamp = 0;
            cli_helper.resid = 0;
            cli_helper.grade = 0;
            cli_helper.n_help = 0;
            cli_helper.rob_money = 0;
            cli_helper.n_rob = 0;
            cli_helper.fp = 0;
            cli_helper.lovelevel = 0;
        }
        else
        {
            cli_helper.fp = 0;
            cli_helper.lovelevel = 0;
            sp_user_t user;
            if (logic.usermgr().get(h.uid, user) || cache.get(h.uid, user))
            {
                //h.grade = user->db.grade;
                cli_helper.fp = user->db.fp;
                cli_helper.lovelevel = user->db.lovelevel;
                cli_helper.viplevel = user->db.viplevel;
            }else
            {
                sql_result_t resu;
                char sel[256];
                sprintf(sel, "select viplevel from UserInfo where uid=%d", h.uid);
                db_service.sync_select(sel, resu);
                cli_helper.viplevel = 0;
                if (resu.affect_row_num() > 0)
                {
                    sql_result_row_t rt = *resu.get_row_at(0);
                    cli_helper.viplevel = (int)std::atoi(rt[0].c_str());
                }
            }

            cli_helper.uid = h.uid;
            cli_helper.resid = h.resid;
            cli_helper.nickname = h.nickname;
            get_gang_name(h.uid, cli_helper.gangname);
            cli_helper.grade = h.grade;
            cli_helper.stamp = date_helper.cur_sec() - h.stamp;
            cli_helper.n_rob = h.n_rob;
            cli_helper.rob_money = h.rob_money;

            char sql_h[1024];
            sql_result_t res_h;
            sprintf(sql_h, "select p1, p2, p3, p4, p5 from Team where uid=%d and is_default=1;",h.uid );
            db_service.sync_select(sql_h, res_h);
            if (0 == res_h.affect_row_num())    //没有找到
            {
                //更新队伍信息
                sc_msg_def::treasure_team_info_t team_info_h;
                for (int i =0; i < 5; ++i)
                {
                    sc_msg_def::team_member_info_t member_info_h;    
                    member_info_h.level = 0;
                    member_info_h.lovelevel = 0;
                    member_info_h.starnum = 0;
                    member_info_h.pid = -1;
                    member_info_h.equiplv = 0;
                    member_info_h.resid = 0;
                    if (i == 0)
                        team_info_h.hero1.push_back(member_info_h);
                    if (i == 1)
                        team_info_h.hero2.push_back(member_info_h);
                    if (i == 2)
                        team_info_h.hero3.push_back(member_info_h);
                    if (i == 3)
                        team_info_h.hero4.push_back(member_info_h);
                    if (i == 4)
                        team_info_h.hero5.push_back(member_info_h);
                }
                cli_helper.team_info.push_back(team_info_h);
            }else {
                    //更新队伍信息
                     sc_msg_def::treasure_team_info_t team_info;
                //去Equip表查找装备信息
                //for (int32_t i = 0; i < res.affect_row_num(); ++i) 只可能有一支默认队伍
               // {
                    sql_result_row_t row = *res_h.get_row_at(0);
                    for (int n = 0; n < 5; ++n)
                    {
                        if ( ((int)std::atoi(row[n].c_str())) >= 0)   //这个位置有英雄
                        {
                            sc_msg_def::team_member_info_t member_info;
                            if ( (int)std::atoi(row[n].c_str()) == 0  )
                            {
                                sql_result_t buf;
                                char sel[256];
                                sprintf(sel, "select quality,lovelevel,resid from UserInfo where uid=%d;",h.uid );
                                db_service.sync_select(sel, buf);
                                if (0 == buf.affect_row_num())    //没有找到
                                {    
                                    member_info.resid = 0;
                                    member_info.starnum = 1;
                                    member_info.lovelevel = 0;
                                }else {
                                    sql_result_row_t& row = *buf.get_row_at(0);
                                    member_info.starnum = (int)std::atoi(row[0].c_str());
                                    member_info.lovelevel = (int)std::atoi(row[1].c_str());
                                    member_info.resid = (int)std::atoi(row[2].c_str());
                                }
                                member_info.level = h.grade;
                            }else {
                                get_level_info(h.uid, (int)std::atoi(row[n].c_str()), member_info.level, member_info.lovelevel, member_info.starnum, member_info.resid);
                            }
                            member_info.equiplv = sc_user_t::get_equip_level(h.uid, (int)std::atoi(row[n].c_str()));
                            member_info.pid = (int)std::atoi(row[n].c_str());
                            if (n == 0)
                                team_info.hero1.push_back(member_info);
                            if (n == 1)
                                team_info.hero2.push_back(member_info);
                            if (n == 2)
                                team_info.hero3.push_back(member_info);
                            if (n == 3)
                                team_info.hero4.push_back(member_info);
                            if (n == 4)
                                team_info.hero5.push_back(member_info);
                        }
                    }
                    cli_helper.team_info.push_back(team_info);
                //}
           }
            //get_team_fp(h.uid, cli_helper.fp);  //整个队伍的信息
            
            sp_view_user_t sp_view = view_cache.get_view(h.uid, true);
            int totalfp = 0;
            for (auto su = sp_view->roles.begin(); su!= sp_view->roles.end(); su++)
            {
                totalfp += su->second.pro.fp;
            }
            cli_helper.fp = totalfp;
        }
        ret.helper.push_back(cli_helper);
    }
    return SUCCESS;
}

void sc_treasure_t::get_team_fp(int32_t uid,int32_t &fp)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select fp from UserInfo where uid=%d;",uid );
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        fp = 0;
        return;
    }

    sql_result_row_t& row = *res.get_row_at(0);
    fp = (int)std::atoi(row[0].c_str());
}

/*void sc_treasure_t::get_equip_level(int32_t uid,int32_t pid, int32_t &equiplv)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select resid from Equip where uid=%d and pid=%d;", uid, pid);
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        equiplv = 0;
        return;
    }
    //一个英雄有五件装备
    int lowest_lv = 13;//用于保存装备的最低等级
    for (int i = 0; i < (int)res.affect_row_num(); ++i)
    {    
        sql_result_row_t& row = *res.get_row_at(i);
        int temp = (int)std::atoi(row[0].c_str());
        
        repo_def::equip_t* rp_equip = repo_mgr.equip.get(temp);
        int temp_level = 13;
        if (rp_equip == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", temp));
            temp_level = 13;
        }else
        {
            temp_level = rp_equip->rank;
        }
        if (temp_level < lowest_lv)
            lowest_lv = temp_level; 
    }
    equiplv = lowest_lv;
}*/


void sc_treasure_t::get_level_info(int32_t uid, int32_t pid, int32_t &level, int32_t &lovelevel, int32_t &rank, int32_t &resid)
{
   /* sql_result_t res1;
    char sql1[256];
    sprintf(sql1, "select pid1, pid2, pid3, pid4, pid5 from Team where uid=%d and is_default=1 ;",uid );
    db_service.sync_select(sql1, res1);
    if (0 == res1.affect_row_num())    //没有找到
    {    
        level = 0;
        lovelevel = 0;
        rank = 0;
        equiplv = 0;
        return;
    }
    //去Equip表查找装备信息
    for (int32_t i = 0; i < res1.affect_row_num(); ++i)
    {
    }*/
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select grade,lovelevel,quality,resid  from Partner where uid=%d and pid=%d;", uid, pid);  //Partner表不包含主角本身
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        level = 0;
        lovelevel = 0;
        rank = 1;
        resid = 0;
        return;
    }

    sql_result_row_t& row = *res.get_row_at(0);
    level = (int)std::atoi(row[0].c_str());
    lovelevel = (int)std::atoi(row[1].c_str());
    rank = (int)std::atoi(row[2].c_str());
    resid = (int)std::atoi(row[3].c_str());
}

int32_t sc_treasure_t::get_reward(int32_t &m_or_t_)
{
    m_or_t_ = 0;

    auto it=treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if( it==treasure_cache.conqueror_info_hm.end() )
        return ERROR_SC_ILLEGLE_REQ;
    if( -1 ==  it->second.slot_pos )
        return ERROR_SC_ILLEGLE_REQ;
    treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
    if( t.uid != m_user.db.uid )
        return ERROR_SC_EXCEPTION;

    uint32_t sec_now = date_helper.cur_sec();
    int32_t pos = it->second.slot_pos;
    int32_t ht_secs = it->second.debian_secs;
    int32_t rob_money = 0;
    int32_t last_stamp = t.stamp;
    int32_t res = settle_owner(it->second.slot_pos, sec_now, rob_money);
    logwarn((LOG, "get reward current time = %d", date_helper.cur_sec()));
    if (res == SUCCESS)
    {
        m_or_t_ = cal_money(pos,last_stamp,sec_now,ht_secs, m_user.db.uid)-rob_money;
        if (pos == -1)
            logerror((LOG, "get_reward error, pos == -1"));
        settle_helper(pos, sec_now, rob_money, "", false);
        it->second.debian_secs = MAX_DEBIAN;
        treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
        return SUCCESS;
    }
    else
    {
        logerror((LOG, "get reward error, settle owner error: %d", res));
        m_or_t_ = sec_now - t.stamp;
        return ERROR_TREASURE_SLOT_GROWING;
    }
}
void sc_treasure_t::get_cur_floor(sc_msg_def::jpk_round_data_t &treasure_)
{
    if( date_helper.offday(treasure_cache.flush_time) >= 1 )
        settle();
    uint32_t sec_now = date_helper.cur_sec();
    auto it=treasure_cache.conqueror_info_hm.find(m_user.db.uid);   //确定当前是否在占领宝藏
    if( it!=treasure_cache.conqueror_info_hm.end() )
    {
        int32_t rob_money = 0;
        int32_t pos = it->second.slot_pos;
        int32_t res = settle_owner(it->second.slot_pos, sec_now, rob_money);
        if (res == SUCCESS)
        {
            it->second.debian_secs = MAX_DEBIAN;
            settle_helper(pos, sec_now, rob_money, "", false);
        }
        else if (res == FAILED)
        {
            treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
            treasure_.cur_slot_sec = sec_now - t.stamp;
        }
        else treasure_.cur_slot_sec = 0;
        treasure_.treasure = it->second.last_round;
        treasure_.cur_slot = it->second.slot_pos;
        treasure_.debian_secs = MAX_DEBIAN - it->second.debian_secs;
        if( treasure_.debian_secs < 0 )
            treasure_.debian_secs = 0;
        treasure_.n_rob = it->second.n_rob;
        treasure_.profit = it->second.profit;
    }
    else
    {
        it = treasure_cache.conqueror_info_hm.insert(make_pair(m_user.db.uid,conqueror_info_t())).first;
        db_TreasureConqueror_t db;
        sql_result_t res;
        if (0==db_TreasureConqueror_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0)); 
            it->second.last_round = db.last_round;
            it->second.debian_secs = db.debian_secs;
            it->second.slot_pos = db.slot_pos;
            it->second.last_stamp = db.last_stamp;
            it->second.n_rob = db.n_rob;
            it->second.profit = db.profit;

            int32_t rob_money = 0;
            int32_t pos = it->second.slot_pos;
            int32_t res = settle_owner(it->second.slot_pos, sec_now, rob_money);
            if (res == SUCCESS)
            {
                it->second.debian_secs = MAX_DEBIAN;
                settle_helper(pos, sec_now, rob_money, "", false);
            }
            else if (res == FAILED)
            {
                treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
                treasure_.cur_slot_sec = sec_now - t.stamp;
            }
            else treasure_.cur_slot_sec = 0;
            treasure_.treasure = it->second.last_round;
            treasure_.cur_slot = it->second.slot_pos;
            treasure_.debian_secs = MAX_DEBIAN - it->second.debian_secs;
            if( treasure_.debian_secs < 0 )
                treasure_.debian_secs = 0;
            treasure_.n_rob = it->second.n_rob;
            treasure_.profit = it->second.profit;
        }
        else {
            it->second.last_round = 0;
            it->second.debian_secs = 0;
            it->second.slot_pos = -1;
            it->second.last_stamp = 0;
            it->second.n_rob = 0;
            it->second.profit = 0;
            treasure_cache.insert_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
            treasure_.treasure = 0;
            treasure_.cur_slot = -1;
            treasure_.cur_slot_sec = 0;
            treasure_.debian_secs = MAX_DEBIAN;
            treasure_.n_rob = 0;
            treasure_.profit = 0;
        }
    }

    auto it_helper = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
    if (it_helper != treasure_cache.coopertive_info_hm.end())
    {
        treasure_.n_help = it_helper->second.n_help;
        treasure_.cur_help_slot = it_helper->second.slot_pos;
        treasure_.profit += it_helper->second.profit; // +
    }
    else
    {
        it_helper = treasure_cache.coopertive_info_hm.insert(make_pair(m_user.db.uid, coopertive_info_t())).first;
        sql_result_t res;
        db_TreasureCoopertive_t db;
        if (0 == db_TreasureCoopertive_t::sync_select_uid(m_user.db.uid,res)){
            db.init(*res.get_row_at(0)); 
            it_helper->second.last_round = db.last_round;
            it_helper->second.debian_secs = db.debian_secs;
            it_helper->second.slot_pos = db.slot_pos;
            it_helper->second.last_stamp = db.last_stamp;
            it_helper->second.n_help = db.n_help;
            it_helper->second.profit = db.profit;

            treasure_.n_help = it_helper->second.n_help;
            treasure_.cur_help_slot = it_helper->second.slot_pos;
            treasure_.profit += it_helper->second.profit; // +
        }
        else {
            it_helper->second.last_round = 0;
            it_helper->second.debian_secs = 0;
            it_helper->second.slot_pos = -1;
            it_helper->second.last_stamp = 0;
            it_helper->second.n_help = 0;
            it_helper->second.profit = 0;
            treasure_cache.insert_coopertive_db(m_user.db.uid,it_helper->second,m_user.db.hostnum);      

            treasure_.n_help = 0;
            treasure_.cur_help_slot = -1;
        }

    }
}
void sc_treasure_t::settle()
{
    treasure_cache.flush_time = date_helper.cur_sec();
    int n_slot = repo_mgr.treasure.size() * SLOT_PER_FLOOR ;
    for(int i = 0; i < n_slot; ++i)  //重置的时候给所有还在占领或者协守的人发放奖励
    {
        int32_t rob_money = 0;
        settle_owner(i, rob_money);
        settle_helper(i, treasure_cache.flush_time, rob_money, "", false);
    }
    treasure_cache.conqueror_info_hm.clear();
    treasure_cache.coopertive_info_hm.clear();
    char sql[128];
    sprintf(sql,"delete from TreasureConqueror where hostnum in (%s)",treasure_cache.db_sql);
    db_service.sync_execute(sql); 
    sprintf(sql,"delete from TreasureCoopertive where hostnum in (%s)",treasure_cache.db_sql);
    db_service.sync_execute(sql); 
    check24();
}
//删除要重置人的信息
void sc_treasure_t::reset(int32_t &time, int32_t &rob_time)
{
    treasure_cache.flush_time = date_helper.cur_sec();
    //清除坑位
    auto it = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if (it != treasure_cache.conqueror_info_hm.end())
    {    
        time = MAX_DEBIAN - it->second.debian_secs;
        rob_time = it->second.n_rob;
        if (it->second.slot_pos != -1)  //表示当前用户占领宝矿
        {
            treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
            if (t.uid == m_user.db.uid)
            {
                //结算
                int32_t  rob_money = 0;
                uint32_t sec_now = date_helper.cur_sec();        
                treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
                int32_t own_money = cal_money(it->second.slot_pos, t.stamp, sec_now, it->second.debian_secs, t.uid) - t.rob_money;
                if (own_money < 0)
                {
                    own_money = 0;
                    logerror((LOG,"treasure reset error, logic error, occupy money < 0, own_money:%d !",own_money));
                    logerror((LOG,"treasure reset error, logic error, occupy money < 0, duration:%d !",sec_now - t.stamp));
                    logerror((LOG,"treasure reset error, logic error, occupy money < 0, rob_money:%d !",t.rob_money));
                    logerror((LOG,"treasure reset error, logic error, occupy money < 0, debian_secs:%d !",it->second.debian_secs));
                }
                it->second.profit += own_money;
                rob_money = t.rob_money;
                put_reward(m_user.db.uid, own_money, it->second.profit);
                it->second.debian_secs +=  sec_now - t.stamp;
                if (it->second.debian_secs > MAX_DEBIAN) it->second.debian_secs = MAX_DEBIAN;
                time = MAX_DEBIAN - it->second.debian_secs;
                if (time < 0) time = 0;

                int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
                if (ret_hostnum == HOSTNUMERROR)
                    return;

                t.uid = 0;
                t.resid = 0;
                t.fp = 0;
                t.grade = 0;
                t.nickname = "";
                t.stamp = 0;
                t.rob_money = 0;
                t.n_rob = 0;
                t.robers.clear();
                t.is_pvp_fighting = false;
                t.lovelevel = 0;
                treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,it->second.slot_pos,ret_hostnum);
                //判断坑是否有协守者，有的话，清除协守者
                treasure_srv_slot_t &h = treasure_cache.helps[it->second.slot_pos];
                if (h.uid > 0)
                {
                    //清除协守者的坑位信息
                    auto itt = treasure_cache.coopertive_info_hm.find(h.uid);
                    if (itt == treasure_cache.coopertive_info_hm.end()){
                        sql_result_t res;
                        db_TreasureCoopertive_t db;
                        if (0 == db_TreasureCoopertive_t::sync_select_uid(h.uid,res)){
                            db.init(*res.get_row_at(0)); 
                            itt = treasure_cache.coopertive_info_hm.insert(make_pair(h.uid, coopertive_info_t())).first;
                            itt->second.last_round = db.last_round;
                            itt->second.debian_secs = db.debian_secs;
                            itt->second.slot_pos = db.slot_pos;
                            itt->second.last_stamp = db.last_stamp;
                            itt->second.n_help = db.n_help;
                            itt->second.profit = db.profit;
                        }
                    }
                    if (itt != treasure_cache.coopertive_info_hm.end())
                    {
                        if (itt->second.n_help == 1)
                        {
                            auto owner = treasure_cache.conqueror_info_hm.find(h.uid);
                            int32_t totalincome = 0;
                            if (owner != treasure_cache.conqueror_info_hm.end())
                            {
                                totalincome = owner->second.profit;
                            }
                            else
                            {
                                db_TreasureConqueror_t db;
                                sql_result_t res;
                                if (0==db_TreasureConqueror_t::sync_select_uid(h.uid,res)){
                                    db.init(*res.get_row_at(0)); 
                                    owner = treasure_cache.conqueror_info_hm.insert(make_pair(h.uid,conqueror_info_t())).first;
                                    owner->second.last_round = db.last_round;
                                    owner->second.debian_secs = db.debian_secs;
                                    owner->second.slot_pos = db.slot_pos;
                                    owner->second.last_stamp = db.last_stamp;
                                    owner->second.n_rob = db.n_rob;
                                    owner->second.profit = db.profit;

                                    totalincome = owner->second.profit;
                                }
                                
                            }
                            //协守者收益
                            int32_t help_money = cal_help_money(it->second.slot_pos, itt->second.last_stamp, sec_now, rob_money);
                            if (help_money < 0) 
                            {
                                logerror((LOG, "treasure reset error, logic error, help  money < 0, help_money:%d !", help_money));
                                logerror((LOG, "treasure reset error, logic error, help  money < 0, duration:%d !", sec_now-itt->second.last_stamp));
                                logerror((LOG, "treasure reset error, logic error, help money < 0, rob money :%d !", rob_money));
                                help_money = 0;
                            }
                            itt->second.profit += help_money;
                            itt->second.profit += totalincome;
                            put_reward(h.uid, help_money, itt->second.profit);

                            string mail = mailinfo.new_mail(mail_treasure_help, t.nickname, help_money);
                            if (!mail.empty()) notify_ctl.push_mail(h.uid, mail);
                        }
                        sc_msg_def::nt_treasure_help_end_t nt;
                        nt.n_help = itt->second.n_help;
                        nt.pos = 0;
                        logic.unicast(h.uid, nt);

                        itt->second.slot_pos = -1;
                        itt->second.last_round = it->second.slot_pos;
                        itt->second.debian_secs += sec_now - itt->second.last_stamp;
                        if (itt->second.debian_secs > MAX_DEBIAN) itt->second.debian_secs = MAX_DEBIAN;
                        itt->second.last_stamp = 0;
                    }
                    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(h.uid);
                    if (ret_hostnum == HOSTNUMERROR)
                        return;
                    h.uid = 0;
                    h.resid = 0;
                    h.nickname = "";
                    h.fp = 0;
                    h.grade = 0;
                    h.n_rob = 0;
                    h.stamp = 0;
                    h.rob_money = 0;
                    h.robers.clear();
                    h.is_pvp_fighting = false;
                    h.lovelevel = 0;
                    treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,it->second.slot_pos,ret_hostnum);
                }
            }
        }
        //将自己占领的宝矿的位置清除，自己开始的开启宝宝藏关卡置0
        it->second.last_round = 0;
        it->second.slot_pos = -1;
        treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    }else
    {
        time = MAX_DEBIAN;
        rob_time = 0;
    }

    auto helper = treasure_cache.coopertive_info_hm.find(m_user.db.uid);
    if (helper != treasure_cache.coopertive_info_hm.end() && helper->second.slot_pos != -1)
    {
        treasure_srv_slot_t &h = treasure_cache.helps[helper->second.slot_pos];
        if  (h.uid != m_user.db.uid)
            return;

        int32_t sec_now = date_helper.cur_sec();
        int32_t rob_money = 0;
        if (helper->second.n_help == 1 )
        {
            auto tt = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
            int32_t totalincome = 0;
            if (tt != treasure_cache.conqueror_info_hm.end())
            {
                totalincome = tt->second.profit;
            }
            //协守者收益
            int32_t help_money = cal_help_money(helper->second.slot_pos, helper->second.last_stamp, sec_now, rob_money);
            if (help_money < 0) {
                logerror((LOG, "treasure reset error, logic error, help  money < 0, help_money:%d !", help_money));
                logerror((LOG, "treasure reset error, logic error, help  money < 0, duration:%d !", sec_now - helper->second.last_stamp));
                logerror((LOG, "treasure reset error, logic error, help money < 0, rob money :%d !", rob_money));
                help_money = 0;
            }
            helper->second.profit += help_money;
            helper->second.profit += totalincome;
            put_reward(m_user.db.uid, help_money, helper->second.profit);
            
            treasure_srv_slot_t &owner = treasure_cache.slots[helper->second.slot_pos];
            if (owner.uid != 0)
            {
                string mail = mailinfo.new_mail(mail_treasure_help, owner.nickname, help_money);
                if (!mail.empty()) notify_ctl.push_mail(m_user.db.uid, mail);
            }
        }
        sc_msg_def::nt_treasure_help_end_t nt;
        nt.n_help = helper->second.n_help;
        nt.pos = 0;
        logic.unicast(m_user.db.uid, nt);
        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(h.uid);
        if (ret_hostnum == HOSTNUMERROR)
            return ;

        h.uid = 0;
        h.resid = 0;
        h.nickname = "";
        h.fp = 0;
        h.grade = 0;
        h.n_rob = 0;
        h.stamp = 0;
        h.rob_money = 0;
        h.robers.clear();
        h.is_pvp_fighting = false;
        h.lovelevel = 0;
        treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,helper->second.slot_pos,ret_hostnum);

        helper->second.last_round = 0;
        helper->second.slot_pos = -1;
        helper->second.debian_secs += sec_now - helper->second.last_stamp;
        if (helper->second.debian_secs > MAX_DEBIAN) helper->second.debian_secs = MAX_DEBIAN;
        helper->second.last_stamp = 0;

        treasure_cache.update_coopertive_db(m_user.db.uid,helper->second,m_user.db.hostnum);
    }
}
//  判断今日是否可以重置宝库
int sc_treasure_t::is_settle_today(int32_t &time, int32_t &rob_time)
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "select aid from UserInfo where uid = '%d';",m_user.db.uid);
    db_service.sync_select(sql, res);
    if (res.affect_row_num() == 0)
    {
        logerror((LOG, "on_req_treasure_reset, no uid:%lu",m_user.db. uid));
        return 1000000 ;
    }else
    {
        auto it = m_treasure_hm.find(m_user.db.uid);    // Treasure表里没有该用户信息
        if (it == m_treasure_hm.end()){
            update_treasure_reset_num(0);
        }
    }
   /* check24();
    reset();
    return 0;
  */
    if (m_today_refresh_times == 0)
    {
        if (m_user.db.viplevel >= 8)    // v8-v15可以重置一次
        {
            m_today_refresh_times = 1;
            update_treasure_reset_num(1);            
            reset(time, rob_time);
            return 0;            
        }else{
            return 2;
        }
    }else if (m_today_refresh_times == 1)
    {
        if (m_user.db.viplevel >= 13)
        {
            m_today_refresh_times = 2;
            update_treasure_reset_num(2);
            reset(time, rob_time);
            return 0;
        }
        else{
            return 1;
        }
    }else if (m_today_refresh_times == 2)
    {
        if (m_user.db.viplevel >= 14)
        {
            m_today_refresh_times = 3;
            update_treasure_reset_num(3);
            reset(time, rob_time);
            return 0;
        }
        else{
            return 1;
        }

    }else{
        return 1;
    }
}

inline void sc_treasure_t::check24()
{
    for (auto it = m_treasure_hm.begin(); it != m_treasure_hm.end(); ++it) 
    {
        if (date_helper.offday(it->second->utime) >= 1)
        {
            m_today_refresh_times = 0;
            it->second->set_reset_num(0);
            it->second->reset_num = 0;
            save_db(it->second);
        }

    }
}

void sc_treasure_t::update_treasure_reset_num(int32_t reset_times = 0)
{
    m_utime = date_helper.cur_sec();
    auto it = m_treasure_hm.find(m_user.db.uid);
    if (it == m_treasure_hm.end())    //  说明不存在记录，则插入
    {
        sp_treasure_t sp_treasure_(new treasure_t);
        sp_treasure_->uid = m_user.db.uid;
        sp_treasure_->reset_num = reset_times;
        sp_treasure_->utime = m_utime;
        db_service.async_do((uint64_t)m_user.db.uid, [&](db_Treasure_t& db_){
            db_.insert();
        }, sp_treasure_->data());
        m_treasure_hm.insert(make_pair(sp_treasure_->uid, sp_treasure_));
    }else {
        it->second->set_reset_num(reset_times);
        it->second->reset_num = reset_times;
        it->second->set_utime(m_utime);
        it->second->utime = m_utime;
        save_db(it->second);
    }
}

int32_t sc_treasure_t::get_reset_num()
{
    auto it = m_treasure_hm.find(m_user.db.uid);   //查找当前用户的次数
    if (it == m_treasure_hm.end())
    {
        return 0;   //异常
    }
    return it->second->reset_num;
}

int32_t sc_treasure_t::settle_owner(uint32_t sec_now_, int32_t &left_secs_, int32_t &pos_, int32_t &rob_money_)
{
    auto it = treasure_cache.conqueror_info_hm.find(m_user.db.uid);
    if (it == treasure_cache.conqueror_info_hm.end()){
        return ERROR_SC_ILLEGLE_REQ;
    }
    if (-1 == it->second.slot_pos){
        return ERROR_SC_ILLEGLE_REQ;
    }
    treasure_srv_slot_t &t = treasure_cache.slots[it->second.slot_pos];
    if (t.uid != m_user.db.uid)
    {
        logerror((LOG, "settle owner 4  failed, slot uid != m_user.db.uid, slot uid = %d", t.uid));
        return ERROR_SC_EXCEPTION;
    }
    pos_ = it->second.slot_pos;

    int32_t own_money = cal_money(it->second.slot_pos, t.stamp, sec_now_, it->second.debian_secs, t.uid) - t.rob_money;
    if (own_money < 0)
        {
            logerror((LOG, "settle owner 4 error, own_money = %d", own_money));
            logerror((LOG,"settle_owner 4 error, get money < 0,rob money = %d", t.rob_money));
            logerror((LOG, "duration = %d", sec_now_ - t.stamp));
            own_money = 0;
        }
    it->second.profit += own_money; // 占领 协守收益(矿主)
    put_reward(m_user.db.uid, own_money, it->second.profit);
    rob_money_ = t.rob_money;

    it->second.slot_pos = -1;
    it->second.debian_secs += sec_now_ - t.stamp;
    if (it->second.debian_secs > MAX_DEBIAN) it->second.debian_secs = MAX_DEBIAN;
    left_secs_ = MAX_DEBIAN - it->second.debian_secs;
    if (left_secs_ < 0) left_secs_ = 0;

    treasure_cache.update_conqueror_db(m_user.db.uid,it->second,m_user.db.hostnum);
    int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
    if (ret_hostnum == HOSTNUMERROR){
        return FAILED;
    }

    t.uid = 0;
    t.resid = 0;
    t.fp = 0;
    t.grade = 0;
    t.stamp = 0;
    t.rob_money = 0;
    t.n_rob = 0;
    t.robers.clear();
    t.lovelevel = 0;
    treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);
    return SUCCESS;
}
int32_t sc_treasure_t::settle_owner(int32_t pos_, int32_t &rob_money_)
{
    if (pos_ == -1) return ERROR_SC_ILLEGLE_REQ;
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if (t.uid != 0)
    {
        auto owner = treasure_cache.conqueror_info_hm.find(t.uid);
        if( owner ==treasure_cache.conqueror_info_hm.end() )
        {
            db_TreasureConqueror_t db;
            sql_result_t res;
            if (0==db_TreasureConqueror_t::sync_select_uid(t.uid,res)){
                db.init(*res.get_row_at(0));
                owner =treasure_cache.conqueror_info_hm.insert(make_pair(t.uid,conqueror_info_t())).first;
                owner->second.last_round = db.last_round;
                owner->second.debian_secs = db.debian_secs;
                owner->second.slot_pos = db.slot_pos;
                owner->second.last_stamp = db.last_stamp;
                owner->second.n_rob = db.n_rob;
                owner->second.profit = db.profit;
            }
        }
        if (owner == treasure_cache.conqueror_info_hm.end())
        {
            logerror((LOG, "settle_owner, logic error!"));
            return ERROR_SC_ILLEGLE_REQ;
        }
        int32_t own_money = cal_money(pos_, t.stamp, 0, owner->second.debian_secs, t.uid) - t.rob_money;
        if (own_money < 0)
        {
            logerror((LOG, "settle owner 2 error, own_money = %d", own_money));
            logerror((LOG,"settle_owner 2 error, get money < 0,rob money = %d", t.rob_money));
            logerror((LOG, "duration = %d", date_helper.cur_sec() - t.stamp));
            own_money = 0;
        }
        owner->second.profit += own_money; // 占领 协守收益(矿主)
        put_reward(t.uid, own_money, owner->second.profit);
        string mail = mailinfo.new_mail(mail_treasure_timeup, own_money);
        if (!mail.empty()) notify_ctl.push_mail(t.uid, mail);

        owner->second.slot_pos = -1;
        owner->second.debian_secs = MAX_DEBIAN;

        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
        if (ret_hostnum == HOSTNUMERROR){
            return FAILED;
        }

        t.resid = 0;
        t.uid = 0;
        t.nickname = "";
        t.fp = 0;
        t.grade = 0;
        t.stamp = 0;
        t.rob_money = 0;
        t.n_rob = 0;
        t.robers.clear();
        t.lovelevel = 0;
        treasure_cache.update_conqueror_db(t.uid,owner->second,ret_hostnum);
        treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);
        return SUCCESS;
    }
    return ERROR_TREASURE_EMPTY_SLOT;
}
int32_t sc_treasure_t::settle_owner(int32_t pos_, uint32_t end_, int32_t &rob_money_)
{
    if (pos_ == -1) 
    {
        logerror((LOG, "settle_owner failed, pos == -1"));
        return ERROR_SC_ILLEGLE_REQ;
    }
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if (t.uid != 0)
    {
        auto owner = treasure_cache.conqueror_info_hm.find(t.uid);
        if( owner ==treasure_cache.conqueror_info_hm.end() )
        {
            db_TreasureConqueror_t db;
            sql_result_t res;
            if (0==db_TreasureConqueror_t::sync_select_uid(t.uid,res)){
                db.init(*res.get_row_at(0));
                owner =treasure_cache.conqueror_info_hm.insert(make_pair(t.uid,conqueror_info_t())).first;
                owner->second.last_round = db.last_round;
                owner->second.debian_secs = db.debian_secs;
                owner->second.slot_pos = db.slot_pos;
                owner->second.last_stamp = db.last_stamp;
                owner->second.n_rob = db.n_rob;
                owner->second.profit = db.profit;
            }
        }
        if (owner == treasure_cache.conqueror_info_hm.end())
        {
            logerror((LOG, "occupy_fight, logic error!"));
            return ERROR_SC_ILLEGLE_REQ;
        }
        if ((end_ - t.stamp + owner->second.debian_secs) >= MAX_DEBIAN)//占领时间达到最大
        {
            int32_t own_money = cal_money(pos_, t.stamp, end_, owner->second.debian_secs, t.uid) - t.rob_money;
            if (own_money < 0)
            {
                logerror((LOG, "settle owner 3 error, own_money = %d", own_money));
                logerror((LOG,"settle_owner 3 error, get money < 0,rob money = %d", t.rob_money));
                logerror((LOG, "duration = %d", end_ - t.stamp));
                own_money = 0;
            }
            owner->second.profit += own_money; // 占领 协守收益(矿主)
            put_reward(t.uid, own_money, owner->second.profit);
            rob_money_ = t.rob_money;
            string mail = mailinfo.new_mail(mail_treasure_timeup, own_money);
            if (!mail.empty()) notify_ctl.push_mail(t.uid, mail);
            
            owner->second.slot_pos = -1;
            owner->second.debian_secs += end_ - t.stamp;
            if (owner->second.debian_secs > MAX_DEBIAN) owner->second.debian_secs = MAX_DEBIAN;

            int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
            if (ret_hostnum == HOSTNUMERROR){
                return FAILED;
            }
            treasure_cache.update_conqueror_db(t.uid,owner->second,ret_hostnum);

            t.uid = 0;
            t.resid = 0;
            t.nickname = "";
            t.fp = 0;
            t.grade = 0;
            t.stamp = 0;
            t.rob_money = 0;
            t.n_rob = 0;
            t.robers.clear();
            t.lovelevel = 0;
            treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);
            return SUCCESS;
        }
        return FAILED;
    }
    return ERROR_TREASURE_EMPTY_SLOT;
}
int32_t sc_treasure_t::settle_owner_and_occupy(int32_t pos_, uint32_t end_, uint32_t &ds_, int &money_all_, int32_t &rob_money_)
{
    if (pos_ == -1) return ERROR_SC_ILLEGLE_REQ;
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    if (t.uid != 0)
    {
        auto owner = treasure_cache.conqueror_info_hm.find(t.uid);
        if( owner ==treasure_cache.conqueror_info_hm.end() )
        {
            db_TreasureConqueror_t db;
            sql_result_t res;
            if (0==db_TreasureConqueror_t::sync_select_uid(t.uid,res)){
                db.init(*res.get_row_at(0));
                owner =treasure_cache.conqueror_info_hm.insert(make_pair(t.uid,conqueror_info_t())).first;
                owner->second.last_round = db.last_round;
                owner->second.debian_secs = db.debian_secs;
                owner->second.slot_pos = db.slot_pos;
                owner->second.last_stamp = db.last_stamp;
                owner->second.n_rob = db.n_rob;
                owner->second.profit = db.profit;
            }
        }
        if (owner == treasure_cache.conqueror_info_hm.end())
        {
            logerror((LOG, "occupy_fight, logic error!"));
            return ERROR_SC_ILLEGLE_REQ;
        }

        int32_t own_money = cal_money(pos_, t.stamp, end_, owner->second.debian_secs, t.uid) - t.rob_money;
        if (own_money < 0)
        {
            logerror((LOG,"fight occupy end error, own_money = %d",own_money));
            logerror((LOG,"fight occupy end error, duration = %d",end_ - t.stamp));
            logerror((LOG,"fight occupy end error, debian_secs = %d",owner->second.debian_secs));
            logerror((LOG,"fight occupy end error, rob_money = %d",t.rob_money));
            own_money = 0;
        }
        money_all_ = own_money;
        owner->second.profit += own_money; // 占领 协守收益(矿主)
        owner->second.debian_secs += end_ - t.stamp;
        owner->second.slot_pos = -1;
        put_reward(t.uid, own_money, owner->second.profit);
        rob_money_ = t.rob_money;
        ds_ = owner->second.debian_secs;

        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(t.uid);
        if (ret_hostnum == HOSTNUMERROR){
            cout<<"settle_owner-uid->"<<t.uid<<endl;
            return FAILED;
        }
        treasure_cache.update_conqueror_db(t.uid,owner->second,ret_hostnum);

        string mail = mailinfo.new_mail(mail_treasure_kickoff, date_helper.str_date(), m_user.db.nickname(), own_money);
        if (!mail.empty()) notify_ctl.push_mail(t.uid, mail);

        t.uid = m_user.db.uid;
        t.resid = m_user.db.resid;
        t.nickname = m_user.db.nickname();
        t.fp = m_user.db.fp;
        t.grade = m_user.db.grade;
        t.stamp = end_;
        t.n_rob = 0;
        t.rob_money = 0;
        t.lovelevel = m_user.db.lovelevel;
        t.robers.clear();
        treasure_cache.treasure_slot_db(t,SLOT_TYEP_SLOTS,pos_,ret_hostnum);

        return SUCCESS;
    }
    return ERROR_TREASURE_EMPTY_SLOT;
}
int32_t sc_treasure_t::settle_helper(int32_t pos_, uint32_t end_, int32_t rob_money_, string name, bool isused)
{
    if (pos_ == -1) 
    {
        logerror((LOG, "settle_helper, slot pos == -1"));
        return ERROR_SC_ILLEGLE_REQ;
    }
    treasure_srv_slot_t &t = treasure_cache.slots[pos_];
    treasure_srv_slot_t &h = treasure_cache.helps[pos_];
    if (h.uid != 0)
    {
        auto helper = treasure_cache.coopertive_info_hm.find(h.uid);
        if (helper == treasure_cache.coopertive_info_hm.end()){
            sql_result_t res;
            db_TreasureCoopertive_t db;
            if (0 == db_TreasureCoopertive_t::sync_select_uid(h.uid,res)){
                db.init(*res.get_row_at(0)); 
                helper = treasure_cache.coopertive_info_hm.insert(make_pair(h.uid, coopertive_info_t())).first;
                helper->second.last_round = db.last_round;
                helper->second.debian_secs = db.debian_secs;
                helper->second.slot_pos = db.slot_pos;
                helper->second.last_stamp = db.last_stamp;
                helper->second.n_help = db.n_help;
                helper->second.profit = db.profit;
            }
        }
        if (helper == treasure_cache.coopertive_info_hm.end())
        {
            logerror((LOG, "settle_helper, logic error!"));
            return ERROR_SC_ILLEGLE_REQ;
        }

        if (helper->second.n_help == 1)
        {
            int32_t help_money = cal_help_money(pos_, helper->second.last_stamp, end_, rob_money_);
            if (help_money < 0) {
                logerror((LOG, "treasure reset error, logic error, help  money < 0, help_money:%d !", help_money));
                logerror((LOG, "treasure reset error, logic error, help  money < 0, duration:%d !", end_ - helper->second.last_stamp));
                logerror((LOG, "treasure reset error, logic error, help money < 0, rob money :%d !", rob_money_));
                help_money = 0;
            }
            //收益得加上占领和抢夺的
            auto owner = treasure_cache.conqueror_info_hm.find(h.uid);
            if( owner ==treasure_cache.conqueror_info_hm.end() )
            {
                db_TreasureConqueror_t db;
                sql_result_t res;
                if (0==db_TreasureConqueror_t::sync_select_uid(h.uid,res)){
                    db.init(*res.get_row_at(0));
                    owner =treasure_cache.conqueror_info_hm.insert(make_pair(h.uid,conqueror_info_t())).first;
                    owner->second.last_round = db.last_round;
                    owner->second.debian_secs = db.debian_secs;
                    owner->second.slot_pos = db.slot_pos;
                    owner->second.last_stamp = db.last_stamp;
                    owner->second.n_rob = db.n_rob;
                    owner->second.profit = db.profit;
                }
            }
            int32_t totalincome = 0;
            if (owner != treasure_cache.conqueror_info_hm.end())
            {
                totalincome = owner->second.profit;
            }
            helper->second.profit += help_money; // 占领 协守收益(协守者)
            helper->second.profit += totalincome;
            put_reward(h.uid, help_money, helper->second.profit);
            
            if (isused)
            {
                string mail = mailinfo.new_mail(mail_treasure_help, name, help_money);
                if (!mail.empty()) notify_ctl.push_mail(h.uid, mail);
            }else
            {
                string mail = mailinfo.new_mail(mail_treasure_help, t.nickname, help_money);
                if (!mail.empty()) notify_ctl.push_mail(h.uid, mail);
            }
        }
        sc_msg_def::nt_treasure_help_end_t nt;
        nt.n_help = helper->second.n_help;
        nt.pos = pos_;
        logic.unicast(h.uid, nt);

        helper->second.slot_pos = -1;
        helper->second.last_round = pos_;
        helper->second.debian_secs = MAX_DEBIAN;
        helper->second.last_stamp = 0;

        int32_t ret_hostnum = treasure_cache.get_hostnum_by_uid(h.uid);
        if (ret_hostnum == HOSTNUMERROR){
            return FAILED;
        }
        treasure_cache.update_coopertive_db(h.uid,helper->second,ret_hostnum);

        h.uid = 0;
        h.resid = 0;
        h.nickname = "";
        h.fp = 0;
        h.grade = 0;
        h.stamp = 0;
        h.n_rob = 0;
        h.rob_money = 0;
        h.robers.clear();
        h.lovelevel = 0;
        treasure_cache.treasure_slot_db(h,SLOT_TYPE_HELPS,pos_,ret_hostnum);
    }
    return SUCCESS;
}
int32_t sc_treasure_t::cal_money(int32_t pos_,uint32_t start_,uint32_t end_,int32_t ht_sec_, int32_t uid_)
{
    int32_t resid = pos_/SLOT_PER_FLOOR+START_ROUND, sum = 0;
    
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(resid);
    if (p_r == NULL)
    {
        logerror((LOG, "cal_money, no treasure round, resid:%d", resid));
        return 0;
    }
    
    int32_t duration = 0;
    //计算本次占坑的持续时间
    if( 0==end_ )
        duration = date_helper.sec_2_tomorrow(start_);
    else
        duration = end_ - start_;
    //计算有效时间
    if( (duration+ht_sec_)>MAX_DEBIAN )
        duration = MAX_DEBIAN-ht_sec_;

    /*
    float p = 0;
    if (m_user.db.viplevel == 9)
        p=0.5f;
    else if (m_user.db.viplevel == 11)
        p=0.8f;
    else if (m_user.db.viplevel == 12)
        p=1.0f;
    sum += duration/SECONDS_1_HOUR * p_r->gold_1hour * (1+p);
    sum += duration/SECONDS_2_HOUR * p_r->gold_2hour;
    sum += duration/SECONDS_3_HOUR * p_r->gold_3hour;
    sum += duration/SECONDS_4_HOUR * p_r->gold_4hour;
    */
    sum += duration/SECONDS_1_MIN * p_r->gold_minute;
    if (duration >= SECONDS_1_HOUR)
        sum += p_r->gold_1hour;
    if (duration >= SECONDS_2_HOUR)
        sum += p_r->gold_2hour;
    if (duration >= SECONDS_3_HOUR )
        sum += p_r->gold_3hour;
    if (duration >= SECONDS_4_HOUR)
        sum += p_r->gold_4hour;

    int32_t viplevel = 0;
    if (uid_ > 0)
    {
        sql_result_t resu;
        char sel[256];
        sprintf(sel, "select viplevel from UserInfo where uid=%d", uid_);
        db_service.sync_select(sel, resu);
        if (resu.affect_row_num() > 0)
        {
            sql_result_row_t rt = *resu.get_row_at(0);
            viplevel = (int)std::atoi(rt[0].c_str());
        }
    }

    if (viplevel >= 5)
        sum *= 1.6;
    return sum;
}
int32_t sc_treasure_t::cal_help_money(int32_t pos_, uint32_t start_, uint32_t end_, int32_t rob_money)
{
    int32_t resid = pos_/SLOT_PER_FLOOR + START_ROUND;
    repo_def::treasure_t *p_r = NULL;
    p_r = repo_mgr.treasure.get(resid);
    if (p_r == NULL)
    {
        logerror((LOG, "cal_help_money, no treasure round, resid:%d", resid));
        return 0;
    }
    int32_t duration = 0;
    if (0 == end_)
        duration = date_helper.sec_2_tomorrow(start_);
    else
        duration = end_ - start_;
    if (duration > MAX_DEBIAN)
        duration = MAX_DEBIAN;
    if (((duration/SECONDS_1_MIN*p_r->gold_minute) ) < 0) 
    {
        logwarn((LOG, "help end, duration:%d", duration));
        logwarn((LOG, "help end, rob_money:%d",rob_money));
        logwarn((LOG, "help end, profit:%d", duration/SECONDS_1_MIN*p_r->gold_minute)); 
    }
    //这里不减rob_money，因为rob_money是指矿主占矿开始到占领结束或者被打劫的时间duration内矿主丢失金钱，而协守者的协守时间小于等于duration
    return (duration/SECONDS_1_MIN*p_r->gold_minute) * HELP_PROFIT;
    //return ((duration/SECONDS_1_MIN*p_r->gold_minute) - rob_money) * HELP_PROFIT;
}
void sc_treasure_t::unicast_records_info()
{
    sc_msg_def::ret_treasure_rcds_t ret;
    sp_treasure_record_t sp_record;

    if (treasure_cache.get_record(m_user.db.uid, sp_record))
    {
        ret.records.resize(sp_record->records.size());
        int i=0;
        for(sp_jpk_treasure_record_t sp_jpk:sp_record->records)
        {
            (sp_jpk)->elapsed = date_helper.cur_sec() - (sp_jpk)->time;
            ret.records[i++] = (*sp_jpk);
        }
    }
    logic.unicast(m_user.db.uid, ret);
}
void sc_treasure_t::unicast_revenge_info()
{
    sc_msg_def::ret_treasure_revenge_t ret;

    auto it=treasure_cache.m_revenge_hm.find(m_user.db.uid);
    if( it==treasure_cache.m_revenge_hm.end() )
    {
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    sc_msg_def::jpk_treasure_revenge_t jpk;
    ret.records.resize( it->second.size() );
    int i = 0;
    for( sc_revenge_record_t & rec : it->second )
    {
        jpk.uid = rec.uid;
        jpk.lv = rec.lv;
        jpk.lovelevel = rec.lovelevel;
        jpk.resid = rec.resid;
        jpk.nickname = rec.nickname;
        //判断玩家是否有坑
        auto it_new = treasure_cache.conqueror_info_hm.find( rec.uid );
        if((it_new==treasure_cache.conqueror_info_hm.end())||(it_new->second.slot_pos==-1))
        {
            jpk.secs = jpk.gold = 0;
            jpk.pos = -1;
            ret.records[i++] = jpk;
            continue;
        }
        size_t pos_ = it_new->second.slot_pos;
        //结算该坑
        if( pos_ >= treasure_cache.slots.size() )
        {
            jpk.secs = jpk.gold = 0;
            jpk.pos = -1;
            ret.records[i++] = jpk;
            continue;
        }
        uint32_t sec_now = date_helper.cur_sec();
        int32_t rob_money = 0;
        int32_t res = settle_owner(pos_, sec_now, rob_money);
        if (res == SUCCESS)
        {
            if (pos_ == -1)
            {
                logerror((LOG, "pos == -1, revenge errror!!!! "));
            }
            settle_helper(pos_, sec_now, rob_money, "", false);
            treasure_srv_slot_t &t = treasure_cache.slots[pos_];
            jpk.secs = jpk.gold = 0;
            jpk.lv = t.grade;
            jpk.pos = -1;
            ret.records[i++] = jpk;
            continue;
        }
        treasure_srv_slot_t &t = treasure_cache.slots[pos_];
        jpk.pos = pos_;
        jpk.secs = sec_now - t.stamp;
        jpk.gold = t.rob_money;
        jpk.lv = t.grade;
        ret.records[i++] = jpk;
    }
    logic.unicast(m_user.db.uid, ret);
}
///////////////////////////////
sc_treasure_cache_t::sc_treasure_cache_t():flush_time(0)
{
    flush_time = date_helper.cur_sec();
    slots.resize(repo_mgr.treasure.size()*SLOT_PER_FLOOR);
    helps.resize(repo_mgr.treasure.size()*SLOT_PER_FLOOR);
}
void sc_treasure_cache_t::load_db(vector<int32_t>& hostnums_)
{    
    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    strcpy(db_sql,str_hosts.c_str());
    sql_result_t res;
    char sql[1024];
    sprintf(sql, "select uid,slot_type,slot_pos,resid,nickname,fp,grade,stamp,n_rob,rob_money,robers,lovelevel,is_pvp_fighting,begin_pvp_fight_time from TreasureSlot where hostnum in (%s)" ,str_hosts.c_str());
    if (0!=db_service.sync_select(sql, res))
        return;

    for (size_t i = 0;i < res.affect_row_num(); i++){
        sql_result_row_t& row_ = *res.get_row_at(i);
        int cur_pos = (int)std::atoi(row_[2].c_str());
        if ((int)std::atoi(row_[1].c_str()) == SLOT_TYEP_SLOTS){
            slots[cur_pos].uid = (int)std::atoi(row_[0].c_str());         
            slots[cur_pos].resid = (int)std::atoi(row_[3].c_str());         
            slots[cur_pos].nickname = row_[4];         
            slots[cur_pos].fp = (int)std::atoi(row_[5].c_str());         
            slots[cur_pos].grade = (int)std::atoi(row_[6].c_str());         
            slots[cur_pos].stamp = (int)std::atoi(row_[7].c_str());         
            slots[cur_pos].n_rob = (int)std::atoi(row_[8].c_str());         
            slots[cur_pos].rob_money = (int)std::atoi(row_[9].c_str());         
            splits_robers(slots[cur_pos].robers,row_[10]);         
            slots[cur_pos].lovelevel = (int)std::atoi(row_[11].c_str());         
            if ((int)std::atoi(row_[12].c_str()) == 1){
                slots[cur_pos].is_pvp_fighting = true;     
            }
            else
            {
                slots[cur_pos].is_pvp_fighting = false;
            }
            slots[cur_pos].begin_pvp_fight_time = (int)std::atoi(row_[13].c_str());         
        }
        else if ((int)std::atoi(row_[1].c_str()) == SLOT_TYPE_HELPS){ 
            helps[cur_pos].uid = (int)std::atoi(row_[0].c_str());         
            helps[cur_pos].resid = (int)std::atoi(row_[3].c_str());         
            helps[cur_pos].nickname = row_[4];         
            helps[cur_pos].fp = (int)std::atoi(row_[5].c_str());         
            helps[cur_pos].grade = (int)std::atoi(row_[6].c_str());         
            helps[cur_pos].stamp = (int)std::atoi(row_[7].c_str());         
            helps[cur_pos].n_rob = (int)std::atoi(row_[8].c_str());         
            helps[cur_pos].rob_money = (int)std::atoi(row_[9].c_str());         
            splits_robers(helps[cur_pos].robers,row_[10]);         
            helps[cur_pos].lovelevel = (int)std::atoi(row_[11].c_str());         
            if ((int)std::atoi(row_[12].c_str()) == 1){
                helps[cur_pos].is_pvp_fighting = true;     
            }
            else
            {
                helps[cur_pos].is_pvp_fighting = false;
            }
            helps[cur_pos].begin_pvp_fight_time = (int)std::atoi(row_[13].c_str());         
        }

    }
}
void sc_treasure_cache_t::add_record(int32_t uid_, sp_jpk_treasure_record_t record_)
{
    auto it = m_record_hm.find(uid_);
    if (it == m_record_hm.end())
    {
        sp_treasure_record_t sp_record(new sc_treasure_record_t());
        it = m_record_hm.insert(make_pair(uid_, sp_record)).first;
    }
    sp_treasure_record_t sp_record = it->second;

    if (sp_record->record_time == 0)
        sp_record->record_time = date_helper.cur_sec();
    else if (date_helper.offday(sp_record->record_time) >= 1)
    {
        sp_record->records.clear();
        sp_record->record_time = date_helper.cur_sec();
    }
    
    while(sp_record->records.size()>=10)
    {
        sp_record->records.pop_front();
    }
    sp_record->records.push_back(record_);
}
void sc_treasure_cache_t::add_revenge(int32_t uid_, sc_revenge_record_t &record_)
{
    auto it = m_revenge_hm.find(uid_);
    if (it == m_revenge_hm.end())
    {
        deque<sc_revenge_record_t> dq;
        it = m_revenge_hm.insert(make_pair(uid_,std::move(dq))).first;
    }
    auto it_r=it->second.begin();
    while(it_r!=it->second.end())
    {
        if( (*it_r).uid == record_.uid )
            it_r = it->second.erase(it_r);
        else
            ++it_r;
    }
    while(it->second.size()>=10)
    {
        it->second.pop_front();
    }
    it->second.push_back(std::move(record_));
}
bool sc_treasure_cache_t::get_record(int32_t uid_, sp_treasure_record_t& sp_record_)
{
    auto it = m_record_hm.find(uid_);
    if (it != m_record_hm.end())
    {
        sp_record_ = it->second; 
        return true;
    }
    return false;
}
void sc_treasure_cache_t::insert_conqueror_db(int32_t uid_,conqueror_info_t& con_info_,int32_t hostnum_)
{
    db_TreasureConqueror_t db_;
    db_.uid = uid_;
    db_.hostnum = hostnum_;
    db_.last_round = con_info_.last_round;
    db_.debian_secs = con_info_.debian_secs;
    db_.slot_pos = con_info_.slot_pos;
    db_.last_stamp = con_info_.last_stamp;
    db_.n_rob = con_info_.n_rob;
    db_.profit = con_info_.profit; 


    db_.sync_insert();
    /*
       db_service.async_do((uint64_t)uid_,[](db_TreasureConqueror_t& db){
       db.insert();         
       },db_);
       */
}
void sc_treasure_cache_t::update_conqueror_db(int32_t uid_,conqueror_info_t& con_info_,int32_t hostnum_)
{
    db_TreasureConqueror_t db_;
    db_.uid = uid_;
    db_.hostnum = hostnum_;
    db_.last_round = con_info_.last_round;
    db_.debian_secs = con_info_.debian_secs;
    db_.slot_pos = con_info_.slot_pos;
    db_.last_stamp = con_info_.last_stamp;
    db_.n_rob = con_info_.n_rob;
    db_.profit = con_info_.profit; 

    db_.sync_update();
    /*
   db_service.async_do((uint64_t)uid_,[](db_TreasureConqueror_t& db){
        db.update();         
    },db_);
   */
}
void sc_treasure_cache_t::insert_coopertive_db(int32_t uid_,coopertive_info_t& coo_info_,int32_t hostnum_)
{
    db_TreasureCoopertive_t db_;
    db_.uid = uid_;
    db_.hostnum = hostnum_;
    db_.last_round = coo_info_.last_round;
    db_.debian_secs = coo_info_.debian_secs;
    db_.slot_pos = coo_info_.slot_pos;
    db_.last_stamp = coo_info_.last_stamp;
    db_.n_help = coo_info_.n_help;
    db_.profit = coo_info_.profit; 

    db_.sync_insert();
    /*
    db_service.async_do((uint64_t)uid_,[](db_TreasureCoopertive_t& db){
            db.insert();         
            },db_);
    */
}
void sc_treasure_cache_t::update_coopertive_db(int32_t uid_,coopertive_info_t& coo_info_,int32_t hostnum_)
{
    db_TreasureCoopertive_t db_;
    db_.uid = uid_;
    db_.hostnum = hostnum_;
    db_.last_round = coo_info_.last_round;
    db_.debian_secs = coo_info_.debian_secs;
    db_.slot_pos = coo_info_.slot_pos;
    db_.last_stamp = coo_info_.last_stamp;
    db_.n_help = coo_info_.n_help;
    db_.profit = coo_info_.profit; 

    db_.sync_update();
    /*
    db_service.async_do((uint64_t)uid_,[](db_TreasureCoopertive_t& db){
            db.update();         
            },db_);
    */
}
void sc_treasure_cache_t::splits_robers(vector<int32_t>& v_robers_,string& s_robers_)
{
    if (s_robers_ == ""){
       return; 
    }
    v_robers_.clear();
    char s[512];
    std::strcpy(s,s_robers_.c_str());
    const char *d = ",";
    char *p = NULL;
    p = std::strtok(s,d);
    while(p)
    {
        v_robers_.push_back((int)std::atoi(p));
        p=strtok(NULL,d);
    }

}
void sc_treasure_cache_t::merge_robers(vector<int32_t>& v_robers_,string& s_robers_)
{
    if (v_robers_.size() == 0){
       s_robers_ = ""; 
       return;
    }
    char tmp[64];
    for (auto it = v_robers_.begin(); it != v_robers_.end();it++){
        if (it+1 == v_robers_.end()){
            sprintf(tmp,"%d",*it);
        }   
        else 
        {
            sprintf(tmp,"%d,",*it);
        }
        s_robers_.append(tmp);
    } 
}
void sc_treasure_cache_t::treasure_slot_db(treasure_srv_slot_t &t,int32_t slot_type,int32_t slot_pos,int32_t hostnum_)
{
    db_TreasureSlot_t sdb;
    sdb.uid = t.uid;
    sdb.hostnum = hostnum_;
    sdb.slot_type = slot_type;
    sdb.slot_pos = slot_pos;
    sdb.resid = t.resid;      
    sdb.nickname = t.nickname;
    sdb.fp = t.fp;
    sdb.grade =t.grade;
    sdb.stamp = t.stamp;
    sdb.n_rob = t.n_rob;
    sdb.rob_money = t.rob_money;
    sdb.lovelevel = t.lovelevel;
    treasure_cache.merge_robers(t.robers,sdb.robers);
    if (t.is_pvp_fighting)
        sdb.is_pvp_fighting = 1;      
    else 
        sdb.is_pvp_fighting = 0;
    sdb.begin_pvp_fight_time = t.begin_pvp_fight_time;

    sql_result_t sres;
    char sql[1024];
    sprintf(sql, "select hostnum from TreasureSlot  where hostnum in (%s) AND slot_type = %d AND slot_pos = %d", db_sql,slot_type,slot_pos);
    if (0 == db_service.sync_select(sql, sres)){
        if (sres.affect_row_num() > 0){
            sql_result_row_t rt = *sres.get_row_at(0);
            int32_t host  = (int32_t)std::atoi(rt[0].c_str());
            sprintf(sql, "UPDATE `TreasureSlot` SET  `nickname` = '%s' ,  `slot_type` = %d ,  `stamp` = %d ,  `resid` = %d , `begin_pvp_fight_time` = %d ,  `grade` = %d ,  `is_pvp_fighting` = %d ,  `robers` = '%s' ,  `uid` = %d ,  `lovelevel` = %d ,  `hostnum` =%d ,  `rob_money` = %d ,  `slot_pos` = %d ,  `fp` = %d ,  `n_rob` = %d WHERE  `hostnum` = %d AND  `slot_type` = %d AND  `slot_pos` = %d", sdb.nickname.c_str(), sdb.slot_type, sdb.stamp, sdb.resid, sdb.begin_pvp_fight_time, sdb.grade, sdb.is_pvp_fighting, sdb.robers.c_str(), sdb.uid, sdb.lovelevel, sdb.hostnum, sdb.rob_money, sdb.slot_pos, sdb.fp, sdb.n_rob, host, sdb.slot_type, sdb.slot_pos);
            db_service.sync_execute(sql);
        }
        else
        {

            sdb.sync_insert();
        }
    }
}

int32_t sc_treasure_cache_t::get_hostnum_by_uid(int32_t uid_)
{
    char sql[512];
    sql_result_t res;
    sprintf(sql,"select hostnum from UserInfo where uid = %d",uid_);
    db_service.sync_select(sql,res);
    if (res.affect_row_num()>0){
        sql_result_row_t rt = *res.get_row_at(0);
        return (int32_t)std::atoi(rt[0].c_str());
    }
    return -1;
}
