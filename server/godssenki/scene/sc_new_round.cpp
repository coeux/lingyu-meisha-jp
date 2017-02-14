#include "sc_new_round.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_cache.h"
#include "sc_message.h"
#include "sc_friend.h"
#include "sc_guidence.h"
#include "sc_statics.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "date_helper.h"
#include "sc_server.h"
#include <sys/time.h>
#include "zlib_util.h"

#define LOG "SC_NEW_ROUND"

#define POW_ZODIAC 6
#define POW_ROUND 6
#define POW_CAVE 6
#define POW_ELITE 10

#define N_ENTER_CAVE 5
#define RESID_FIRST_CAVE 5001

#define MAX_HELP 50
#define FPOINT_HELPER 100
#define FPOINT_HELPEE 20
#define FPOINT_STRANGER 50
#define FPOINT_STRANGEE 10
#define PASS_ROUND_INTERVAL 3600
#define FPOINT_PER_PASS 50

#define MAX_DROP_RMB 50
#define DROP_RMB 10
#define EXPEDITION_BEGIN 8001
#define EXPEDITION_END 8015
#define EXPEDITION_BEGIN_LEVEL 23
#define EXPEDITION_REFRESH_VIP_LEVEL 10
#define EXPEDITION_REWARD_VIP_LEVEL 6
#define ELITE_RESET_CONSUME_DIAMOND 50

int c2i_fun(char key)
{
    if('0' <= key && key <= '9')
        return key - '0';
    else if('a' <= key && key <= 'z')
        return (key - 'a' + 10);
    else
        return -1;
}

char i2c_fun(int value)
{
    char char_map[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    if(0 <= value && value <= 35)
        return char_map[value];
    else
        return '@';
}

sc_new_round_t::sc_new_round_t(sc_user_t &user_):
    m_user(user_),
    m_cur_rid(0),
    m_cur_uid(0),
    m_cur_pid(0)
{
    m_fight_time = -1;
}

void sc_new_round_t::clear_state()
{
    m_cur_rid = 0;
    m_cur_uid = 0;
    m_cur_pid = 0;

    m_ret.exp = 0;
    m_ret.lovevalue = 0;
    m_ret.coin= 0;
    m_ret.rmb= 0;
    m_ret.hhero.resid = 0;
    m_ret.drop_items.clear();

    m_cave_ret.exp = 0;
    m_cave_ret.coin = 0;
    m_cave_ret.soul = 0;
    m_cave_ret.hhero.resid = 0;
    m_cave_ret.drop_items.clear();

}

void sc_new_round_t::gen_drop_items_i(int32_t rid_,vector<sc_msg_def::jpk_item_t>& drop_items_ ,int32_t flag)
{
    //传入参数的flag 0表示未知副本 1表示 普通副本 2表示 精英副本
    int32_t flag_item = 0;
    bool isDoubleRate =  false;
    bool isDoubleNumber = false;
    if((flag == 1)&&(m_user.reward.isInDoubleActivity(1)))
        isDoubleRate = true;
    if((flag == 1)&&(m_user.reward.isInDoubleActivity(2)))
        isDoubleNumber = true;
    if((flag == 2)&&(m_user.reward.isInDoubleActivity(5)))
        isDoubleRate = true;
    if((flag == 2)&&(m_user.reward.isInDoubleActivity(6)))
        isDoubleNumber = true;
    if(isDoubleNumber)
        flag_item = 2;
    if(isDoubleRate)
        flag_item = 1;
    if(isDoubleRate && isDoubleNumber)
        flag_item = 3;
    drop_items_.clear();
    //flag_item 是当前去寻找掉落的标识位。1表示掉率双倍 2表示数量双倍 3表示都双倍 0都不双倍。
    gen_drop_items(rid_, drop_items_ ,flag_item);
}

void sc_new_round_t::gen_drop_chips(int32_t resid_,vector<sc_msg_def::jpk_item_t> &drop_items_)
{
    drop_items_.clear();
    sc_msg_def::jpk_item_t item;

    repo_def::cave_t *p_r = repo_mgr.cave.get(resid_);
    if( NULL == p_r )
    {
        logerror((LOG, "gen_drop_chips, no roundid, %d", resid_));
        return;
    }

    for(size_t i=1; i<p_r->item_drop.size(); i++)
    {
        vector<int32_t> &drop = p_r->item_drop[i];
        if (drop.size() != 3)
            continue;

        /*
           repo_def::chip_t* rp_chip = repo_mgr.chip.get(drop[0]);
           if (rp_chip == NULL)
           continue;
           */

        uint32_t r = random_t::rand_integer(1, 10000);
        if (r > (uint32_t)drop[1])
            continue;

        item.itid = 0 ;
        item.resid = drop[0];
        item.num = random_t::rand_integer(1, drop[2]);
        drop_items_.push_back(std::move(item));

        if( drop_items_.size() >= 3 )
            return;
    }
}

void sc_new_round_t::gen_zodiac_drop_items_i(int32_t rid_,vector<sc_msg_def::jpk_item_t>& drop_items_)
{
    drop_items_.clear();
    repo_def::zodiac_drop_t *p_z = repo_mgr.zodiac_drop.get(m_user.db.grade);
    if( NULL == p_z )
    {
        logerror((LOG, "gen_drop_items,no zodiac drop,%d,%d",rid_,m_user.db.grade));
        return;
    }
    int index = rid_-3000;
    vector<vector<int>>* drops[] = {
        &(p_z->drop1),
        &(p_z->drop2),
        &(p_z->drop3),
        &(p_z->drop4),
        &(p_z->drop5),
        &(p_z->drop6),
        &(p_z->drop7),
        &(p_z->drop8),
        &(p_z->drop9),
        &(p_z->drop10),
        &(p_z->drop11),
        &(p_z->drop12),
        &(p_z->drop13),
        &(p_z->drop14),
        &(p_z->drop15),
        &(p_z->drop16),
        &(p_z->drop17),
    };
    vector<vector<int>>& drop = *drops[index-1];
    for(size_t i=1; i<drop.size(); i++)
    {
        int resid = drop[i][0];
        int p = drop[i][1];
        int max = drop[i][2];
        if ((int)random_t::rand_integer(1, 10000)<=p)
        {
            sc_msg_def::jpk_item_t ditem;
            ditem.itid = 0;
            ditem.resid = resid;
            ditem.num = random_t::rand_integer(1, max);
            drop_items_.push_back(std::move(ditem));
        } 
    }
} 

void sc_new_round_t::gen_drop_items(int rid_,vector<sc_msg_def::jpk_item_t>& drop_items_ ,int32_t flag)
{
    repo_def::round_t *p_r = repo_mgr.round.get(rid_);
    if( NULL == p_r )
    {
        logerror((LOG, "gen_drop_items, no roundid, %d", rid_));
        return;
    }

    drop_items_.clear();

    sc_msg_def::jpk_item_t ditem;

    if (p_r->darwing_drop.size() > 1)
    {
        int item = gen_array2_resid(p_r->darwing_drop);
        if (item > 0)
        {
            ditem.itid = 0;
            ditem.resid = item;
            ditem.num = (flag > 1) ? 2 : 1;    
            drop_items_.push_back(std::move(ditem));
        }
    }

    vector<int32_t> items;
    for(size_t i=1; i<p_r->item_drop.size(); i++)
    {
        vector<int32_t> &drop = p_r->item_drop[i];
        if (drop.size() != 3)
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
        items.push_back(drop[0]);
        uint32_t r = random_t::rand_integer(1, 10000);
         
        if (flag % 2 == 1)
            r = (uint32_t)r / 2;

        //logwarn((LOG, "gen_drop_items, r:%u, drop:%d, resid:%d ", r, drop[1], drop[0]));

        if (r > (uint32_t)drop[1])
            continue;

        int32_t n = random_t::rand_integer(1, drop[2]);

        ditem.itid = 0;
        ditem.resid = drop[0];
        ditem.num = (flag > 1) ? 2 * n : n;
        drop_items_.push_back(std::move(ditem));
    }
    /*
    if( (items.size()!=0) && (drop_items_.size()==0) )
    {
        uint32_t r = random_t::rand_integer(1,items.size());
        ditem.itid = 0;
        ditem.resid = items[r-1];
        ditem.num = 1;
        drop_items_.push_back(std::move(ditem));
    }
    */

    if( p_r->zodiac_drop != 0 )
    {
        repo_def::zodiac_drop_t *p_z = repo_mgr.zodiac_drop.get(p_r->zodiac_drop);
        if( NULL == p_z )
        {
            logerror((LOG, "gen_drop_items,no zodiac drop,%d,%d",rid_,p_r->zodiac_drop));
            return;
        }
        /*
        //产生材料掉落
        ditem.resid = gen_array2_resid(p_z->drop1);
        if( ditem.resid != 0 )
        {
        ditem.itid = 0;
        ditem.num = 1;
        drop_items_.push_back(std::move(ditem));
        }
        */
        //产生宝石袋掉落
        int32_t gem_group = gen_array2_resid(p_z->drop2);
        if( gem_group != 0 )
        {
            ditem.itid = 0;
            ditem.num = 1;
            ditem.resid = gem_group;
            drop_items_.push_back(std::move(ditem));
        }
        //产生钱袋掉落
        ditem.resid = gen_array2_resid(p_z->drop3);
        if( ditem.resid != 0 )
        {
            ditem.itid = 0;
            ditem.num = 1;
            drop_items_.push_back(std::move(ditem));
        }
    }
}

int32_t sc_new_round_t::gen_array2_resid(vector<vector<int32_t>> &drop_)
{
    map<int,int> drop_map;
    int last_p = 0;
    for(size_t i=1; i<drop_.size(); i++)
    {
        const vector<int32_t> &store_items = drop_[i];
        last_p = store_items[1]+last_p;
        drop_map[last_p] = store_items[0];
    }

    int max_p = 10000;
    if (last_p > max_p)
        max_p = last_p;

    int r = random_t::rand_integer(1, max_p);
    for(auto it = drop_map.begin(); it!=drop_map.end(); it++)
    {
        //printf("r:%d,rr:%d,item:%d\n", r, it->first, it->second);
        if (r <= it->first)
        {
            return it->second;
        }
    }

    return 0;
}

int sc_new_round_t::gen_rmb(int uid_)
{
    auto it_hm = round_cache.m_rmb_hm.find(uid_);
    if( it_hm == round_cache.m_rmb_hm.end() )
        it_hm=round_cache.m_rmb_hm.insert(make_pair(uid_, 0)).first;

    if ( (it_hm->second) >= MAX_DROP_RMB )
        return 0;

    uint32_t r = random_t::rand_integer(1, 100);
    if (r<=10)
    {
        (it_hm->second)+=DROP_RMB;
        return DROP_RMB;
    }

    return 0;
}

void sc_new_round_t::flush_round(int32_t gid_)
{
    //验证该组id是否有效
    if( (gid_/100==3)&&(gid_!=300) )
    {
        logerror((LOG, "flush_round, ERROR_SC_EXCEPTION,%d", gid_));
        sc_msg_def::ret_round_flush_t ret;
        ret.code = ERROR_SC_EXCEPTION;
        ret.gid = gid_;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    if( gid_ != 300 )
    {
        auto it_g=repo_mgr.roundgroup.find(gid_);
        if( it_g == repo_mgr.roundgroup.end() )
        {
            logerror((LOG, "flush_round, ERROR_SC_NO_RD_GP,%d", gid_));
            sc_msg_def::ret_round_flush_t ret;
            ret.code = ERROR_SC_EXCEPTION;
            ret.gid = gid_;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }

    //是否在免费刷新活动时间
    //bool is_open = m_user.reward.is_activity_open(activity_free_flush_round);
    bool is_open = false;

    int32_t code = 0;
    if( gid_>200 && gid_<300 )
    {
        //精英关卡
        if( is_open )
        {
            round_cache.reset(m_user.db.uid);
            auto it_elite = round_cache.m_free_elite_hm.find(m_user.db.uid);
            if( it_elite == round_cache.m_free_elite_hm.end() )
            {
                //免费刷新
                round_cache.m_free_elite_hm.insert( make_pair(m_user.db.uid,0) );
                code = SUCCESS;
            }
            else 
                code = m_user.vip.buy_vip(vop_reste_adv_round);
        }
        else if (m_user.db.viplevel >= 6)
        {
            round_cache.reset(m_user.db.uid);
            code = SUCCESS;
        }
        else
            code = m_user.vip.buy_vip(vop_reste_adv_round);
    }
    if( 300==gid_ )
    {
        //黄道十二宫每组打过的最大关卡
        if( is_open )
        {
            round_cache.reset(m_user.db.uid);
            auto it_zodiac = round_cache.m_free_zodiac_hm.find(m_user.db.uid);
            if( it_zodiac == round_cache.m_free_zodiac_hm.end() )
            {
                //免费刷新
                round_cache.m_free_zodiac_hm.insert( make_pair(m_user.db.uid,0) );
                code = SUCCESS;
            }
            else 
                code = m_user.vip.buy_vip(vop_reset_zodiac);
        }
        else
            code = m_user.vip.buy_vip(vop_reset_zodiac);
    }
    if (code != SUCCESS)
    {
        sc_msg_def::ret_round_flush_t ret;
        ret.code = code;
        ret.gid = gid_;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //清空精英关卡
    if( gid_>200 && gid_<300 )
    {
        auto it_hm = round_cache.m_round_hm.find(m_user.db.uid);
        if( it_hm != round_cache.m_round_hm.end() )
        {
            auto it_m = (it_hm->second).find(gid_);
            if( it_m != (it_hm->second).end() )
                (it_m->second).clear();
        }
    }
    //清空十二宫关卡
    if( 300==gid_ )
    {
        m_user.db.set_zodiacid(0);
        round_cache.m_zodiac_hm.erase(m_user.db.uid);
    }

    sc_msg_def::ret_round_flush_t ret;
    ret.code = SUCCESS;
    ret.gid = gid_;
    logic.unicast(m_user.db.uid, ret);
}

//崭新的普通关卡/////////////////////////////////
void sc_new_round_t::enter_round(int32_t resid_,int32_t uid_,int32_t pid_)
{
    //salt
    random_t::rand_str(m_salt, 16);

    round_cache.reset(m_user.db.uid);
    clear_state();

    sc_msg_def::ret_round_enter_failed_t fail;
    fail.resid = resid_;
    //判断体力是否足够
    if( m_user.db.power<POW_ROUND)
    {
        logerror((LOG,"enter round,no power!"));
        fail.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    p_r = repo_mgr.round.get(resid_);

    if (p_r == NULL)
    {
        logerror((LOG,"enter round,no round,resid:%d",resid_));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断进入关卡的条件
    if( resid_ < 600)
    {
        int iscorrect = 0;
        for(auto itt = repo_mgr.soulnode.begin();itt!=repo_mgr.soulnode.end();itt++)
        {
            if(itt->second.id == m_user.soulrank_mgr.db.soulid && itt->second.round == resid_)
                iscorrect = 1;            
        }
        if (iscorrect == 0)
        {
                //进入条件不满足
                logerror((LOG, "enter soulround, round is not correct, resid:%d", resid_));
                fail.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, fail);
                return;
        }
         
    }
    else if ( resid_ < 5000)
    {
        if( 0 == m_user.db.roundid )
        {
            if( resid_ != 1001 )
            {
                //进入条件不满足
                logerror((LOG, "enter round, round no permit 1, resid:%d", resid_));
                fail.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, fail);
                return;
            }
        }
        else
        {
            if( ((m_user.db.roundid+1)<resid_) || (m_user.db.questid<p_r->pre_quest))
            {
                //进入条件不满足
                logerror((LOG, "enter round, round no permit 2, resid:%d", resid_));
                fail.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, fail);
                return;
            }
        }
    }
    else
    {
        if ( (m_user.db.elite_roundid + 1 < resid_) && (m_user.db.elite_roundid != 0))
        {
            //进入条件不满足
            logerror((LOG, "enter round, round no permit 2, resid:%d", resid_));
            fail.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
        int times;
        int off = resid_-5000-m_user.db.elite_round_times.length(); 
        if (off > 0)
        {
            m_user.db.elite_round_times.append(off, '0');
            m_user.db.set_elite_round_times(m_user.db.elite_round_times);
        }
        char time_temp = m_user.db.elite_round_times[resid_-5001];
        times = c2i_fun(time_temp);
        if(-1 == times)
            return;
        if( times >= 3 )
        {
            //精英关卡次数限制
            logerror((LOG, "enter round, times >= 3, resid:%d", resid_));
            fail.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    //助战英雄
    m_ret.hhero.resid = 0;
    if( uid_!=0 )
    {
        sp_helphero_t sp_helphero = hero_cache.get_helphero(uid_);
        if( sp_helphero )
            m_ret.hhero = *sp_helphero;

    }
    //记录服务器状态
    m_cur_rid = resid_;
    m_cur_uid = uid_;
    m_cur_pid = pid_;

    //返回关卡开始
    m_ret.resid = p_r->id;
    m_ret.rmb = gen_rmb(m_user.db.uid);
    m_ret.exp = p_r->exp;
    m_ret.lovevalue = random_t::rand_integer(20,30);
    if(resid_ > 5000 && (m_user.reward.isInDoubleActivity(6))){
        m_ret.coin = p_r->coin * 2;
    }else if(resid_ > 600 && resid_ < 5000 && (m_user.reward.isInDoubleActivity(2))){
        m_ret.coin = p_r->coin * 2;
    }else{
        m_ret.coin = p_r->coin;
    }
    m_ret.salt = m_salt;
    m_fight_time  = date_helper.cur_sec() % 3600;

    //新手引导相关
    if((resid_ == 1005) && (((m_user.db.isnew) & (1<<evt_guidence_elite1))==0) )
    {
        guidence_ins.gen_elite_drop(m_user,m_ret.drop_items);
    }
    else
    {
        //筛选副本等级。精英传2  普通传1
        if(resid_ > 5000) {
            gen_drop_items_i(m_ret.resid, m_ret.drop_items ,2);
        }else if(resid_ > 600){
            gen_drop_items_i(m_ret.resid, m_ret.drop_items ,1);
        }else{
            gen_drop_items_i(m_ret.resid, m_ret.drop_items);
        }
    }
    logic.unicast(m_user.db.uid, m_ret);
}

int32_t sc_new_round_t::get_left_secs()
{
    auto it_pass_round = round_cache.m_pass_round_hm.find(m_user.db.uid);
    if( it_pass_round == round_cache.m_pass_round_hm.end() )
        return 0;

    if (m_user.db.viplevel >= 4)
    {
        it_pass_round->second = 0;
        return 0;
    }

    uint32_t cur_sec = date_helper.cur_sec();
    if( cur_sec - it_pass_round->second >= PASS_ROUND_INTERVAL )
        return 0;
    else
        return PASS_ROUND_INTERVAL - ( cur_sec-it_pass_round->second);
}

//lewton
int32_t sc_new_round_t::get_cave_left_secs(){

    auto it_cave_pass_round = round_cache.m_cave_pass_round_hm.find(m_user.db.uid);
    if(it_cave_pass_round ==  round_cache.m_cave_pass_round_hm.end())
        return 0;	//玩家还未用过英雄迷窟这个功能
    uint32_t cur_sec = date_helper.cur_sec();
    if(cur_sec - it_cave_pass_round->second >= PASS_ROUND_INTERVAL)
        return 0;
    else
        return PASS_ROUND_INTERVAL - (cur_sec-it_cave_pass_round->second);
}

void sc_new_round_t::clear_pass_round_cd()
{
    sc_msg_def::ret_round_pass_clear_cd_t ret;

    //扣除水晶
    int32_t code = m_user.vip.buy_vip(vop_clear_pass_round);
    if (code != SUCCESS)
    {
        ret.code = code;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    auto it_pass_round = round_cache.m_pass_round_hm.find(m_user.db.uid);
    if( it_pass_round == round_cache.m_pass_round_hm.end() )
        it_pass_round = round_cache.m_pass_round_hm.insert(make_pair(m_user.db.uid,0)).first;
    it_pass_round->second = 0;

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_new_round_t::refrsh_daily_data()
{
    ystring_t<1024> zero_time;
    zero_time.append(1 ,'0');
    m_user.db.set_elite_round_times(zero_time);
    m_user.db.set_elite_reset_times(zero_time);
    m_user.save_db();
}

void sc_new_round_t::clear_pass_cave_cd()
{
    sc_msg_def::ret_cave_pass_clear_cd_t ret;

    //扣除水晶
    int32_t code = m_user.vip.buy_vip(vop_clear_pass_round);
    if (code != SUCCESS)
    {
        ret.code = code;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    auto it_pass_round = round_cache.m_cave_pass_round_hm.find(m_user.db.uid);
    if( it_pass_round == round_cache.m_cave_pass_round_hm.end() )
        it_pass_round = round_cache.m_cave_pass_round_hm.insert(make_pair(m_user.db.uid,0)).first;
    it_pass_round->second = 0;

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

void sc_new_round_t::pass_round_new(sc_msg_def::req_round_pass_new_t &req_ )
{
    sc_msg_def::ret_round_pass_fail_t fail;
    fail.resid = req_.resid;
    fail.count = req_.count;

    string elite_round = "";
    string elite_times = "0";
    /*
       auto it_pass_round = round_cache.m_pass_round_hm.find(m_user.db.uid);
       if( it_pass_round == round_cache.m_pass_round_hm.end() )
       it_pass_round = round_cache.m_pass_round_hm.insert(make_pair(m_user.db.uid,0)).first;
       */
    //计算挂机结果
    sc_msg_def::ret_round_pass_t ret;
    ret.resid = req_.resid;
    ret.count = req_.count;

    /*
       if (m_user.db.viplevel >= 4)
       {
       ret.left_secs = 0;
       it_pass_round->second = 0;
       }
       else
       ret.left_secs = PASS_ROUND_INTERVAL;
       */

    //判断挂机是否冷却
    /*
       uint32_t cur_sec = date_helper.cur_sec();
       if( cur_sec - it_pass_round->second < PASS_ROUND_INTERVAL )
       {
       logerror((LOG,"pass round, time interval"));
       fail.code = ERROR_SC_ILLEGLE_REQ;
       logic.unicast(m_user.db.uid, fail);
       return;
       }
       */
    //判断扫荡次数是否合法
    if (req_.count <= 0)
    {
        logerror((LOG,"pass round, swipe times is illegal!!!!"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    if (req_.count > 1 && m_user.db.viplevel < 0)//去掉vip等级限制
    {
        logerror((LOG,"pass round, viplevel not enough!!!!"));
        fail.code = ERROR_ROUND_SWIPE_SERVERAL_VIP_NOT_ENOUGH;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断体力是否足够
    if( m_user.db.power<(POW_ROUND*req_.count) )
    {
        logerror((LOG,"pass round, not enough power"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    p_r = repo_mgr.round.get(req_.resid);
    if (p_r == NULL)
    {
        logerror((LOG,"pass round,no round,resid:%d",req_.resid));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //该关卡是否已经打过
    if( (req_.resid > 1000) && (req_.resid < 5000))
    {
        if( m_user.db.roundid < req_.resid )
        {
            logerror((LOG,"pass round, no enterance"));
            fail.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    else if (req_.resid > 500 && req_.resid < 600)
    {
        auto soulinfo = repo_mgr.soulnode.get(m_user.soulrank_mgr.db.soulid);
        if(soulinfo == NULL)
            return;
        if(soulinfo->round == req_.resid)
        {
            for(auto itt = repo_mgr.soulnode.begin(); itt!= repo_mgr.soulnode.end();itt++)
            {
                if(itt->second.isfinal == m_user.soulrank_mgr.db.soulid)
                    m_user.soulrank_mgr.req_open_soulnode(itt->second.id);
            }        
        }
    }
    else if ((req_.resid > 5000))
    {
        if( m_user.db.elite_roundid < req_.resid )
        {
            logerror((LOG,"pass round, no enterance"));
            fail.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
        //精英关卡增加次数
        if( req_.resid > 5000 )
        {
            int off = req_.resid-5000-m_user.db.elite_round_times.length(); 
            if (off > 0)
            {
                m_user.db.elite_round_times.append(off, '0');
            }
            int times;
            char time_temp = m_user.db.elite_round_times[req_.resid-5001];
            times = c2i_fun(time_temp);
            if(-1 == times)
                return;
            if( times >= 3 )
            {
                //精英关卡次数限制
                logerror((LOG, "enter round, times >= 3, resid:%d", req_.resid));
                fail.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, fail);
                return;
            }
            //判断当前请求扫荡的次数是否合法
            if ((3- times) < req_.count )
            {
                //精英关卡次数限制
                logerror((LOG, "enter round, remain times < request times, resid:%d", req_.resid));
                fail.code = ERROR_ELITE_ROUND_SWIPE_TIMES;
                logic.unicast(m_user.db.uid, fail);
                return;
            }

            char time_e = i2c_fun(times + req_.count);
            if('@' == time_e)
                return;

            m_user.db.elite_round_times[req_.resid-5001] = time_e; 
            m_user.db.set_elite_round_times(m_user.db.elite_round_times);            
            elite_round = m_user.db.elite_round_times();
            elite_times = time_e;
        }
    }
    ret.times = elite_times;
    ret.new_round_times = elite_round;

    //int32_t sum_rmb = 0;
    int32_t lovevaluenum = 0;
    sc_msg_def::nt_bag_change_t nt;
    for( int i = 0; i < req_.count; ++i )
    {
        //计算掉落
        sc_msg_def::jpk_pass_round_result_t res;
        res.rmb = gen_rmb(m_user.db.uid);
        res.exp = p_r->exp;
        if(req_.resid > 5000 && (m_user.reward.isInDoubleActivity(6))){
            res.coin = p_r->coin *2;
        }else if(req_.resid > 600 && req_.resid < 5000 && (m_user.reward.isInDoubleActivity(2))){
            res.coin = p_r->coin *2;
        }else{
            res.coin = p_r->coin;
        }

        int32_t temp = 0;
        if (m_user.db.viplevel >= 3) 
            temp = random_t::rand_integer(10,15);
        res.lovevalue = temp;
        lovevaluenum += temp; 
        if(req_.resid > 5000){
            gen_drop_items_i(req_.resid, res.drop_items,2);
        }else if(req_.resid > 600){
            gen_drop_items_i(req_.resid, res.drop_items,1);
        }else{
            gen_drop_items_i(req_.resid, res.drop_items);
        }

        //掉落结算
        //sum_rmb += res.rmb; 
        //保存道具到数据库
        for(size_t j=0; j<res.drop_items.size(); ++j)
        {
            sc_msg_def::jpk_item_t& item = res.drop_items[j];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        ret.results.push_back( std::move(res) );
        //掉落cardevent物品
        m_user.card_event.add_coin();

        //任务
        //排除魂师干扰
        if(req_.resid > 600)
        {
            m_user.task.on_round_pass(req_.resid);
            m_user.love_task.on_round_pass(req_.resid);
            if (req_.resid < 5000)
                m_user.daily_task.on_event(evt_round_pass);
            else
                m_user.daily_task.on_event(evt_elite_pass);
            for(size_t j=0;j<req_.killed.size();j++) {
                m_user.task.on_monsert_killed(req_.killed[j].resid,req_.killed[j].num);
                m_user.love_task.on_monster_killed(req_.killed[j].resid,req_.killed[j].num);
            }
        }
    }
    m_user.item_mgr.on_bag_change(nt);

        //m_user.card_event.add_coin();

    m_user.on_money_change( (p_r->coin) * req_.count );
        /*
           if( sum_rmb > 0 )
           m_user.on_freeyb_change(sum_rmb);
           */
    m_user.on_exp_change( (p_r->exp) * req_.count );
    //排除魂师干扰
    if (req_.resid >600)
    {
        m_user.on_power_change( - POW_ROUND * req_.count );
        m_user.on_fpoint_change( FPOINT_PER_PASS * req_.count );
        m_user.on_lovevalue_change( lovevaluenum );
    }
    m_user.save_db();

    //it_pass_round->second = cur_sec;
    logic.unicast(m_user.db.uid, ret);
}

//重置精英关卡挑战次数
void sc_new_round_t::reset_elite(sc_msg_def::req_reset_elite_t &req_)
{
    sc_msg_def::ret_reset_elite_t ret_;
    ret_.resid = req_.resid;

    //检测该关卡的重置次数是否小于当天规定次数
    int times;
    int off = req_.resid-5000-m_user.db.elite_reset_times.length(); 
    if (off > 0)
    {
        m_user.db.elite_reset_times.append(off, '0');
        m_user.db.set_elite_reset_times(m_user.db.elite_reset_times);
    }
    char time_temp = m_user.db.elite_reset_times[req_.resid-5001];
    cout << "before: " << time_temp << endl;
    times = c2i_fun(time_temp);
    if(-1 == times)
        return;
    cout << "========= times: " << times << endl;
    repo_def::vip_t* vip_info = repo_mgr.vip.get(m_user.db.viplevel);
    if (times >= vip_info->reset_elite)
    {
        logerror((LOG,"pass round, not enough power"));
        return;
    }
    
    //消耗钻石
    if ((m_user.db.payyb + m_user.db.freeyb) < ELITE_RESET_CONSUME_DIAMOND)
    {
        ret_.code = ERROR_SC_NO_YB;
        logic.unicast(m_user.db.uid, ret_);
        return;
    }
    logwarn((LOG, "before reset elite_round_times, total yb = %d, uid = %d", (m_user.db.payyb + m_user.db.freeyb), m_user.db.uid));
    m_user.consume_yb(ELITE_RESET_CONSUME_DIAMOND);
    logwarn((LOG, "after reset elite_round_times, total yb = %d, uid = %d", (m_user.db.payyb + m_user.db.freeyb), m_user.db.uid));
    /*int leftPayyb = ((m_user.db.payyb + ELITE_RESET_CONSUME_DIAMOND)>0)?(m_user.db.payyb + ELITE_RESET_CONSUME_DIAMOND):0;
    int leftFreeyb = ((m_user.db.payyb + ELITE_RESET_CONSUME_DIAMOND)>0)?m_user.db.freeyb:(m_user.db.freeyb + m_user.db.payyb + ELITE_RESET_CONSUME_DIAMOND);
    if (leftFreeyb >= 0)
    {
        m_user.db.set_freeyb(leftFreeyb);
        m_user.db.set_payyb(leftPayyb);

        sc_msg_def::nt_yb_change_t nt;
        nt.now = leftPayyb + leftFreeyb;
        logic.unicast(m_user.db.uid, nt);
    }else
    {
        ret_.code = ERROR_SC_NO_YB;
        logic.unicast(m_user.db.uid, ret_);
        return; 
    }*/

    //该关卡重置次数加一
    cout << "after: " << times+1 << endl;
    char time_c = i2c_fun(times+1);
    if('@' == time_c)
        return;
    cout << "==========timec: " << time_c << endl;

    m_user.db.elite_reset_times[req_.resid-5001] = time_c;
    m_user.db.set_elite_reset_times(m_user.db.elite_reset_times);

    //重置该关卡
    m_user.db.elite_round_times[req_.resid-5001] = '0';
    m_user.db.set_elite_round_times(m_user.db.elite_round_times);
    
    m_user.save_db();
    ret_.code = 0;
    ret_.new_round_times = m_user.db.elite_round_times();
    ret_.new_reset_times = m_user.db.elite_reset_times();

    logic.unicast(m_user.db.uid, ret_);
}

void sc_new_round_t::pass_round(sc_msg_def::req_round_pass_t &req_)
{
    sc_msg_def::ret_round_pass_fail_t fail;
    fail.resid = req_.resid;
    fail.count = req_.count;

    //计算挂机结果
    sc_msg_def::ret_round_pass_t ret;
    ret.resid = req_.resid;
    ret.count = req_.count;

    auto it_pass_round = round_cache.m_pass_round_hm.find(m_user.db.uid);
    if( it_pass_round == round_cache.m_pass_round_hm.end() )
        it_pass_round = round_cache.m_pass_round_hm.insert(make_pair(m_user.db.uid,0)).first;

    if (m_user.db.viplevel >= 4)
    {
        ret.left_secs = 0;
        it_pass_round->second = 0;
    }
    else
        ret.left_secs = PASS_ROUND_INTERVAL;

    //判断挂机是否冷却
    uint32_t cur_sec = date_helper.cur_sec();
    if( cur_sec - it_pass_round->second < PASS_ROUND_INTERVAL )
    {
        logerror((LOG,"pass round, time interval"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断体力是否足够
    if( m_user.db.power<(POW_ROUND*req_.count) )
    {
        logerror((LOG,"pass round, not enough power"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    p_r = repo_mgr.round.get(req_.resid);
    if (p_r == NULL)
    {
        logerror((LOG,"pass round,no round,resid:%d",req_.resid));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //该关卡是否已经打过
    if( m_user.db.roundid < req_.resid )
    {
        logerror((LOG,"pass round, no enterance"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }

    int32_t sum_rmb = 0;
    sc_msg_def::nt_bag_change_t nt;
    for( int i = 0; i < req_.count; ++i )
    {
        //计算掉落
        sc_msg_def::jpk_pass_round_result_t res;
        res.rmb = gen_rmb(m_user.db.uid);
        res.exp = p_r->exp;
        res.coin = p_r->coin;
        gen_drop_items_i(req_.resid, res.drop_items);

        //掉落结算
        sum_rmb += res.rmb; 
        //保存道具到数据库
        for(size_t j=0; j<res.drop_items.size(); ++j)
        {
            sc_msg_def::jpk_item_t& item = res.drop_items[j];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        ret.results.push_back( std::move(res) );

        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        m_user.daily_task.on_event(evt_round_pass);
    }
    m_user.item_mgr.on_bag_change(nt);

    m_user.card_event.add_coin();

    m_user.on_money_change( (p_r->coin) * req_.count );
    if( sum_rmb > 0 )
        m_user.on_freeyb_change(sum_rmb);
    m_user.on_exp_change( (p_r->exp) * req_.count );
    m_user.on_power_change( - POW_ROUND * req_.count );
    m_user.save_db();

    it_pass_round->second = cur_sec;
    logic.unicast(m_user.db.uid, ret);
}

int32_t sc_new_round_t::get_round_total_stars()
{
    int32_t total_stars_num = 0;
    int32_t temp = 0;
    for (uint32_t i = 0; i < m_user.db.roundstars.length(); ++i)
    {
        temp = 0;
        switch( m_user.db.roundstars[i] )
        {
            case '0': temp = 0;break;
            case '1': temp = 1;break;
            case '2': temp = 1;break;
            case '3': temp = 2;break;
            case '4': temp = 1;break;
            case '5': temp = 2;break;
            case '6': temp = 2;break;
            case '7': temp = 3;break;
            case '8': temp = 1;break;
            case '9': temp = 2;break;
            case 'a': temp = 2;break;
            case 'b': temp = 3;break;
            case 'c': temp = 2;break;
            case 'd': temp = 3;break;
            case 'e': temp = 3;break;
            case 'f': temp = 4;break;
        }
        total_stars_num += temp;
    }
    
    return total_stars_num;
}

void sc_new_round_t::update_round_stars_reward()
{
    //判断是否在活动期内
    int32_t ctimestamp = m_user.db.createtime;
    uint32_t activity_end_time_stamp = ctimestamp + 7*86400;
    if ( date_helper.cur_sec() <= activity_end_time_stamp )
    {
        repo_def::newly_reward_t * rp_draw_reward = NULL;
        //已经记录的不再更新
        uint32_t  i = 401;
        if (m_user.db.round_stars_reward.length() == 1 && m_user.db.round_stars_reward[0] == '0')
            i = 401;
        else
            i = 400 + m_user.db.round_stars_reward.length() + 1;
        for (; repo_mgr.newly_reward.get(i) != NULL; ++i)
        {
            rp_draw_reward = repo_mgr.newly_reward.get(i);
            if ( get_round_total_stars()  >= rp_draw_reward->value )
            {
                if ((i - 400) > m_user.db.round_stars_reward.length() && m_user.db.round_stars_reward[i - 401] != '2')
                {
                    m_user.db.round_stars_reward.append(i - 400 - m_user.db.round_stars_reward.length(),'1');
                }
                if (m_user.db.round_stars_reward[i - 401] != '2')
                    m_user.db.round_stars_reward[i - 401] = '1';

                m_user.db.set_round_stars_reward(m_user.db.round_stars_reward); 
                m_user.save_db();
            }
        }
    }
}

void sc_new_round_t::get_first_pass_elite_round_reward(int32_t resid_)
{
    repo_def::round_t *p_r = repo_mgr.round.get(resid_);
    if( NULL == p_r )
    {
        logerror((LOG, "gen_drop_items, no roundid, %d", resid_));
        return;
    }
    
    /*int itemid = 0;
    for(size_t i=1; i < p_r->item_drop.size(); i++)
    {
        vector<int32_t> &drop = p_r->item_drop[i];
        if (drop.size() != 3)
        {
            logerror((LOG, "gen_drop_items, drop size error! size:%d!=3", drop.size()));
            continue;
        }
        
        if (drop[0] > 30000 && drop[0] < 40000)
        { 
            itemid = drop[0];
            break;
        }
    }
    
    repo_def::item_t* rp_item = repo_mgr.item.get(itemid);
    if (rp_item == NULL)
    {
        logerror((LOG, "gen_drop_items, repo no item resid:%d", itemid));
        return;
    }
    int quality = rp_item->quality;
    repo_def::configure_t * rp_config = NULL;
    int configid = 17;
    int piecenum = 0;
    switch(quality)
    {
        case 1: configid = 17; break;
        case 2: configid = 18; break;
        case 3: configid = 19; break;
        case 4: configid = 20; break;
        case 5: configid = 21; break;
    }
    if ((rp_config = repo_mgr.configure.get(configid)) != NULL)
        piecenum = rp_config->value;*/
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
    //get(itemid, piecenum);
    int size = p_r->first_drop.size();
    for (auto i = 1; i < size; ++i)
    {
        get(p_r->first_drop[i][0], p_r->first_drop[i][1]);
    }
}

void sc_new_round_t::exit_round( sc_msg_def::req_round_exit_t &req_ )
{
    sc_msg_def::ret_round_exit_t ret;
    if ( req_.salt != m_salt )
    {
        clear_state();

        ret.resid = req_.resid;
        ret.win = req_.win;
        ret.stars = req_.stars;
        ret.round_stars_reward = m_user.db.round_stars_reward();
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    m_salt = "qwertyuimnbvcxz;%";
    int cur_time = date_helper.cur_sec() % 3600;
    if( cur_time < m_fight_time )
        cur_time += 3600;
    if( cur_time - m_fight_time <= 2 )
    {
        clear_state();

        ret.resid = req_.resid;
        ret.win = req_.win;
        ret.stars = req_.stars;
        ret.round_stars_reward = m_user.db.round_stars_reward();
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    string elite_round = "";
    //判断玩家当前是否在关卡战斗中
    if( !m_cur_rid || m_cur_rid != req_.resid )
    {
        logerror((LOG,"exit round,cur rid:%d,req rid:%d",m_cur_rid,req_.resid));
        clear_state();

        ret.resid = req_.resid;
        ret.win = req_.win;
        ret.stars = req_.stars;
        ret.round_stars_reward = m_user.db.round_stars_reward();
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    if( req_.win )
    {
        m_user.card_event.add_coin();
        //关卡结算
        if( req_.resid > 5000 )
        {
            if( m_user.db.elite_roundid < req_.resid)
            {
                //首次通关，获得通关奖励
                get_first_pass_elite_round_reward(req_.resid);
                m_user.db.set_elite_roundid(req_.resid);
            }
        }
        else if (req_.resid > 500 && req_.resid < 600)
        {

            for(auto it = repo_mgr.soulnode.begin(); it!= repo_mgr.soulnode.end();it++)
            {
                if(it->second.id == m_user.soulrank_mgr.db.soulid)
                {
                    if(it->second.round == req_.resid)
                    {
                        for(auto itt = repo_mgr.soulnode.begin(); itt!= repo_mgr.soulnode.end();itt++)
                        {
                            if(itt->second.isfinal == m_user.soulrank_mgr.db.soulid)
                            {
                                m_user.soulrank_mgr.req_open_soulnode(itt->second.id);
                                break;
                            }
                        }
                    }
                }        
            }
        }
        else
        {
            if( m_user.db.roundid < req_.resid )
                m_user.db.set_roundid(req_.resid);
        }
        m_user.on_money_change(m_ret.coin);
        m_user.on_freeyb_change(m_ret.rmb);
        m_user.on_exp_change(m_ret.exp);
        m_user.on_lovevalue_change(m_ret.lovevalue);
        //排除魂师干扰
        if(req_.resid > 600)
            m_user.on_power_change(-POW_ROUND);
        //保存关卡评定等级 (普通关卡)
        if( req_.resid < 5000 )
        {
            int off = req_.resid-1001-m_user.db.roundstars.length()+1; 
            if (off > 0)
            {
                m_user.db.roundstars.append(off, '0');
            }
            m_user.db.roundstars[req_.resid-1001] = req_.stars[0]; 
            m_user.db.set_roundstars(m_user.db.roundstars);
        }
        //精英关卡增加次数
        if( req_.resid > 5000 )
        {
            char times;
            switch(m_user.db.elite_round_times[req_.resid-5001])
            {
                case '0':
                    times = '1';
                    break;
                case '1':
                    times = '2';
                    break;
                case '2':
                    times = '3';
                    break;
                default:
                    times = '3';
            }
            m_user.db.elite_round_times[req_.resid-5001] = times; 
            m_user.db.set_elite_round_times(m_user.db.elite_round_times);            
            elite_round = m_user.db.elite_round_times();
        }

        //结算助战英雄
        if( m_cur_uid!=0 )
        {
            helphero_cache.add_helpcount(m_cur_uid);
            if( m_user.friend_mgr.is_frd(m_cur_uid) )
            {
                helphero_cache.add_fpoint(m_user.db.uid,FPOINT_HELPER);
                helphero_cache.add_fpoint(m_cur_uid,FPOINT_HELPER);
                helphero_cache.set_helper(m_user.db.uid,m_cur_uid);
            }
            else
            {
                helphero_cache.add_fpoint(m_user.db.uid,FPOINT_STRANGER);
                helphero_cache.add_fpoint(m_cur_uid,FPOINT_STRANGEE);
            }
        }
        m_user.save_db();
        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<m_ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = m_ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        m_user.item_mgr.on_bag_change(nt);

        //新手引导相关
        if((req_.resid == 1005) && (((m_user.db.isnew) & (1<<evt_guidence_elite1))==0) )
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.addnew(11021,10,nt);
            m_user.item_mgr.addnew(11023,6,nt);
            m_user.item_mgr.addnew(11024,10,nt);
            m_user.item_mgr.addnew(11025,10,nt);
            m_user.item_mgr.addnew(11026,20,nt);
            m_user.item_mgr.on_bag_change(nt);
            guidence_ins.on_guidence_event(m_user,evt_guidence_elite1);
        }

        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        if (req_.resid < 5000 && req_.resid > 600)
            m_user.daily_task.on_event(evt_round_pass);
        else if(req_.resid > 5000)
            m_user.daily_task.on_event(evt_elite_pass);
        for(size_t i=0;i<req_.killed.size();i++){
            m_user.task.on_monsert_killed(req_.killed[i].resid,req_.killed[i].num);
            m_user.love_task.on_monster_killed(req_.killed[i].resid,req_.killed[i].num);
        }
        //判断战斗力
        repo_def::round_t *p_r = repo_mgr.round.get(req_.resid);
        if( NULL == p_r )
        {
            logerror((LOG, "compare fp, no roundid, %d", req_.resid));
            return;
        }
        if( p_r->fighting_capacity > m_user.db.fp )
            statics_ins.unicast_fpexception(m_user,req_.resid,p_r->fighting_capacity);
    }
    
    int32_t ctimestamp = m_user.db.createtime;
    uint32_t activity_end_time_stamp = ctimestamp + 10*86400;
    if ( date_helper.cur_sec() <= activity_end_time_stamp )
        update_round_stars_reward();
    //通知客户端战斗结束
    ret.resid = req_.resid;
    ret.win = req_.win;
    ret.stars = req_.stars;
    ret.new_round_times = elite_round;
    ret.round_stars_reward = m_user.db.round_stars_reward();
    logic.unicast(m_user.db.uid, ret);

    clear_state();
}
//崭新的精英关卡///////////////////////////////////////////////
void sc_new_round_t::enter_elite(int32_t resid_)
{
    round_cache.reset(m_user.db.uid);
    clear_state();

    sc_msg_def::ret_round_enter_failed_t fail;
    fail.resid = resid_;
    //判断体力是否足够
    if( m_user.db.power<POW_ELITE)
    {
        logerror((LOG,"enter elite,no power!"));
        fail.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    p_r = repo_mgr.round.get(resid_);
    if (p_r == NULL)
    {
        logerror((LOG,"enter elite,no round,resid:%d",resid_));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //是否还有剩余次数
    auto it_rg = repo_mgr.rid2gid.find(resid_);
    if( it_rg == repo_mgr.rid2gid.end() )
    {
        logerror((LOG, "enter elite, repo no gid, resid:%d", resid_));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    int32_t gid = it_rg->second;
    auto it_hm = round_cache.m_round_hm.find(m_user.db.uid);
    if( it_hm != round_cache.m_round_hm.end() )
    {
        auto it_m = (it_hm->second).find(gid);
        if( (it_m!=(it_hm->second).end())&&((it_m->second).count(resid_)) )
        {
            //没有进入次数，返回
            logerror((LOG, "enter elite, round no permit 1, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    //进入条件是否满足
    if( 0==m_user.db.eliteid )
    {
        if( (resid_ != 2005) || (m_user.db.roundid<1005) )
        {
            //进入条件不满足
            logerror((LOG, "enter elite, round no permit 2, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    else
    {
        if( ((m_user.db.eliteid+5)<resid_) || (m_user.db.roundid<(resid_-1000)) )
        {
            //进入条件不满足
            logerror((LOG, "enter elite, round no permit 3, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    //记录服务器状态
    m_cur_rid = resid_;
    m_cur_uid = 0;
    m_cur_pid = 0;
    //返回关卡开始
    m_ret.resid = p_r->id;
    m_ret.rmb = gen_rmb(m_user.db.uid);
    m_ret.exp = p_r->exp;
    m_ret.lovevalue = random_t::rand_integer(20,30);
    m_ret.coin = p_r->coin;
    gen_drop_items_i(m_ret.resid,m_ret.drop_items);

    logic.unicast(m_user.db.uid, m_ret);
}
void sc_new_round_t::exit_elite( sc_msg_def::req_elite_exit_t &req_ )
{
    sc_msg_def::ret_round_exit_t ret;
    //判断玩家当前是否在关卡战斗中
    if( !m_cur_rid || m_cur_rid != req_.resid )
    {
        logerror((LOG,"exit elite,cur rid:%d,req rid:%d",m_cur_rid,req_.resid));
        clear_state();

        ret.resid = req_.resid;
        ret.win = req_.win;
        ret.stars = req_.stars;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    if( req_.win )
    {
        m_user.card_event.add_coin();
        //关卡结算
        if( m_user.db.eliteid < req_.resid )
        {
            m_user.db.set_eliteid(req_.resid);
        }
        m_user.on_money_change(m_ret.coin);
        m_user.on_freeyb_change(m_ret.rmb);
        m_user.on_exp_change(m_ret.exp);
        m_user.on_power_change(-POW_ELITE);
        m_user.save_db();
        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<m_ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = m_ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        /*
           if((m_user.db.isnew & (1<<evt_guidence_elite2))==0)
           guidence_ins.on_guidence_event(m_user,evt_guidence_elite2);
           */

        m_user.item_mgr.on_bag_change(nt);
        //减去进入次数
        auto it_rg = repo_mgr.rid2gid.find(req_.resid);
        if( it_rg == repo_mgr.rid2gid.end() )
            logerror((LOG, "exit elite, repo rid2gid no round, resid:%d", req_.resid));
        else
        {
            int32_t gid = it_rg->second;
            auto it_hm = round_cache.m_round_hm.find(m_user.db.uid);
            if( it_hm != round_cache.m_round_hm.end() )
            {
                auto it_v = (it_hm->second).find(gid);
                if( it_v == (it_hm->second).end() )
                {
                    set<int32_t> rounds;
                    rounds.insert(req_.resid);
                    (it_hm->second).insert(make_pair(gid,std::move(rounds) ));
                }
                else
                {
                    (it_v->second).insert(req_.resid);
                }
            }
            else
            {
                set<int32_t> rounds;
                rounds.insert(req_.resid);

                map<int32_t,set<int32_t> > gid_rounds;
                gid_rounds.insert( make_pair(gid,std::move(rounds)) );

                round_cache.m_round_hm.insert( make_pair(m_user.db.uid,gid_rounds) );
            }
        }

        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        m_user.daily_task.on_event(evt_elite_pass);
        for(size_t i=0;i<req_.killed.size();i++){
            m_user.task.on_monsert_killed(req_.killed[i].resid,req_.killed[i].num);
            m_user.love_task.on_monster_killed(req_.killed[i].resid,req_.killed[i].num);
        }

        //判断战斗力
        repo_def::round_t *p_r = repo_mgr.round.get(req_.resid);
        if( NULL == p_r )
        {
            logerror((LOG, "compare fp, no roundid, %d", req_.resid));
            return;
        }
        if( p_r->fighting_capacity > m_user.db.fp )
            statics_ins.unicast_fpexception(m_user,req_.resid,p_r->fighting_capacity);

    }

    //通知客户端战斗结束
    ret.resid = req_.resid;
    ret.win = req_.win;
    ret.stars = req_.stars;
    logic.unicast(m_user.db.uid, ret);

    clear_state();
}
int32_t sc_new_round_t::is_last_round(int32_t resid_)
{
    auto it_gid = repo_mgr.rid2gid.find(resid_);
    if( it_gid == repo_mgr.rid2gid.end() )
        return 0;
    int32_t gid = it_gid->second;
    repo_def::round_group_t *p_rg = repo_mgr.roundgroup.get(gid);
    if( p_rg == NULL )
        return 0;
    if( resid_ == p_rg->get_max_round() )
        return 1;
    else
        return 0;
}

//崭新的十二宫/////////////////////////////////////////////////
void sc_new_round_t::enter_zodiac(int32_t resid_,int32_t uid_,int32_t pid_)
{
    sc_msg_def::ret_round_enter_failed_t fail;
    fail.resid = resid_;
    if (m_user.db.zodiacid > 0 && resid_ > (m_user.db.zodiacid+1))
    {
        logerror((LOG,"enter zodiac,resid error, %d>%d!", resid_, m_user.db.zodiacid));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }

    round_cache.reset(m_user.db.uid);
    clear_state();

    //判断体力是否足够
    if( m_user.db.power<POW_ZODIAC)
    {
        logerror((LOG,"enter zodiac,no power!"));
        fail.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    p_r = repo_mgr.round.get(resid_);
    if (p_r == NULL)
    {
        logerror((LOG,"enter zodiac,no round,resid:%d",resid_));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //助战英雄
    m_ret.hhero.resid = 0;
    /*
       if( uid_!=0 )
       {
       sp_helphero_t sp_helphero = hero_cache.get_helphero(uid_);
       if( sp_helphero )
       m_ret.hhero = *sp_helphero;
       }
       */
    //记录服务器状态
    m_cur_rid = resid_;
    m_cur_uid = uid_;
    m_cur_pid = pid_;

    //返回关卡开始
    m_ret.resid = p_r->id;
    m_ret.rmb = gen_rmb(m_user.db.uid);
    m_ret.exp = p_r->exp;
    m_ret.lovevalue = random_t::rand_integer(30,45);
    m_ret.coin = p_r->coin;

    auto it = round_cache.m_zodiac_hm.find(m_user.db.uid);
    if (it == round_cache.m_zodiac_hm.end())
    {
        m_ret.hp_percent = 1.0f;
        m_ret.fpower = 0;
        m_ret.angers.clear();
    }
    else
    {
        sc_zodiac_t& z = it->second;
        m_ret.hp_percent = z.hp_percent;
        m_ret.fpower = z.fpower;
        m_ret.angers = z.angers;
    }

    //gen_drop_items_i(m_ret.resid, m_ret.drop_items);
    gen_zodiac_drop_items_i(m_ret.resid, m_ret.drop_items);
    logic.unicast(m_user.db.uid, m_ret);
}
void sc_new_round_t::exit_zodiac( sc_msg_def::req_zodiac_exit_t &req_ )
{
    auto it = round_cache.m_zodiac_hm.find(m_user.db.uid);
    if (it == round_cache.m_zodiac_hm.end())
    {
        sc_zodiac_t z;
        z.hp_percent = req_.hp_percent;
        z.fpower = req_.fpower;
        z.angers = req_.angers; 
        round_cache.m_zodiac_hm.insert(make_pair(m_user.db.uid, std::move(z)));
    }
    else
    {
        sc_zodiac_t& z = it->second;
        z.hp_percent = req_.hp_percent;
        z.fpower = req_.fpower;
        for(auto it=req_.angers.begin(); it!=req_.angers.end(); it++)
        {
            z.angers[it->first]=it->second;
        }
    }

    sc_msg_def::ret_round_exit_t ret;
    //判断玩家当前是否在关卡战斗中
    if( !m_cur_rid || m_cur_rid != req_.resid )
    {
        logerror((LOG,"exit zodiac,cur rid:%d,req rid:%d",m_cur_rid,req_.resid));
        clear_state();

        ret.resid = req_.resid;
        ret.win = req_.win;
        ret.stars = req_.stars;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    if( req_.win )
    {
        //关卡结算
        if( m_user.db.zodiacid < req_.resid )
        {
            m_user.db.set_zodiacid(req_.resid);
            //m_user.db.set_zodiacstamp(date_helper.cur_sec());
        }
        m_user.on_money_change(m_ret.coin);
        m_user.on_freeyb_change(m_ret.rmb);
        m_user.on_exp_change(m_ret.exp);
        m_user.on_lovevalue_change(m_ret.lovevalue);
        m_user.on_power_change(-POW_ZODIAC);
        //结算助战英雄
        /*
           if( m_cur_uid!=0 )
           {
           helphero_cache.add_helpcount(m_cur_uid);
           if( m_user.friend_mgr.is_frd(m_cur_uid) )
           {
           helphero_cache.add_fpoint(m_user.db.uid,FPOINT_HELPER);
           helphero_cache.add_fpoint(m_cur_uid,FPOINT_HELPER);
           helphero_cache.set_helper(m_user.db.uid,m_cur_uid);
           }
           else
           {
           helphero_cache.add_fpoint(m_user.db.uid,FPOINT_STRANGER);
           helphero_cache.add_fpoint(m_cur_uid,FPOINT_STRANGEE);
           }
           }
           */
        m_user.save_db();
        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<m_ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = m_ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        m_user.item_mgr.on_bag_change(nt);

        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        m_user.daily_task.on_event(evt_pass_zodiac);
        for(size_t i=0;i<req_.killed.size();i++){
            m_user.task.on_monsert_killed(req_.killed[i].resid,req_.killed[i].num);
            m_user.love_task.on_monster_killed(req_.killed[i].resid,req_.killed[i].num);
        }
        //判断战斗力
        repo_def::round_t *p_r = repo_mgr.round.get(req_.resid);
        if( NULL == p_r )
        {
            logerror((LOG, "compare fp, no roundid, %d", req_.resid));
            return;
        }
        if( p_r->fighting_capacity > m_user.db.fp )
            statics_ins.unicast_fpexception(m_user,req_.resid,p_r->fighting_capacity);

    }

    //通知客户端战斗结束
    ret.resid = req_.resid;
    ret.win = req_.win;
    ret.stars = req_.stars;
    logic.unicast(m_user.db.uid, ret);

    clear_state();
}
//英雄迷窟///////////////////////////////////////////////
void sc_new_round_t::enter_cave(int32_t resid_, int32_t uid_, int32_t pid_)
{
    round_cache.reset(m_user.db.uid);	
    clear_state();

    sc_msg_def::ret_cave_enter_failed_t fail;
    fail.resid = resid_;
    //判断体力是否足够
    if( m_user.db.power<POW_CAVE)
    {
        logerror((LOG,"enter cave,no power!"));
        fail.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::cave_t *p_r = NULL;
    p_r = repo_mgr.cave.get(resid_);	//cave.get(resid_)不太清楚
    if (p_r == NULL)
    {
        logerror((LOG,"enter cave,no round,resid:%d",resid_));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    if( m_user.db.grade < p_r->level)
    {
        logerror((LOG,"enter cave,error level!"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //是否还有剩余次数
    auto it_hm = round_cache.m_cave_hm.find(m_user.db.uid);
    if( it_hm != round_cache.m_cave_hm.end() )
    {
        auto it_m = (it_hm->second).find(resid_);
        if( (it_m!=(it_hm->second).end()) && (it_m->second->n_enter>=N_ENTER_CAVE) )
        {
            //没有进入次数，返回
            logerror((LOG, "enter cave, round no permit 1, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    //进入条件是否满足
    if( 0==m_user.db.caveid )
    {
        if( resid_ != RESID_FIRST_CAVE )
        {
            //进入条件不满足
            logerror((LOG, "enter cave, round no permit 2, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    else
    {
        if( (m_user.db.caveid+1) < resid_ )
        {
            //进入条件不满足
            logerror((LOG, "enter cave, round no permit 3, resid:%d", resid_));
            fail.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, fail);
            return;
        }
    }
    //助战英雄
    m_cave_ret.hhero.resid = 0;
    if( uid_!=0 )
    {
        sp_helphero_t sp_helphero = hero_cache.get_helphero(uid_);
        if( sp_helphero )
            m_cave_ret.hhero = *sp_helphero;

    }
    //记录服务器状态
    m_cur_rid = resid_;
    m_cur_uid = uid_;
    m_cur_pid = pid_;
    //返回关卡开始
    m_cave_ret.resid = p_r->id;
    m_cave_ret.exp = p_r->exp;
    m_cave_ret.coin = p_r->coin;
    m_cave_ret.soul = p_r->soul;
    gen_drop_chips(m_cave_ret.resid,m_cave_ret.drop_items);

    logic.unicast(m_user.db.uid, m_cave_ret);
}
void sc_new_round_t::exit_cave( sc_msg_def::req_cave_exit_t &req_ )
{
    sc_msg_def::ret_cave_exit_t ret;
    //判断玩家当前是否在关卡战斗中
    if( !m_cur_rid || m_cur_rid != req_.resid )
    {
        logerror((LOG,"exit elite,cur rid:%d,req rid:%d",m_cur_rid,req_.resid)); 	
        ret.resid = req_.resid; 
        ret.win = req_.win;
        ret.stars = req_.stars;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    if( req_.win )
    {
        //减去进入次数
        auto it_hm = round_cache.m_cave_hm.find(m_user.db.uid);
        if( it_hm != round_cache.m_cave_hm.end() )
        {
            auto it_p = (it_hm->second).find(req_.resid);
            if( it_p == (it_hm->second).end() )
            {
                sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
                ++(sp_cave->n_enter);

                (it_hm->second).insert( make_pair(req_.resid,sp_cave) );
            }
            else
                ++(it_p->second->n_enter);
        }
        else
        {
            sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
            ++(sp_cave->n_enter);

            hash_map<int32_t,sp_cave_t> user_hm;
            user_hm.insert(make_pair(req_.resid,sp_cave));

            round_cache.m_cave_hm.insert( make_pair(m_user.db.uid,std::move(user_hm) ) );
        }

        //关卡结算
        if( m_user.db.caveid < req_.resid )
        {
            m_user.db.set_caveid(req_.resid);
        }
        m_user.on_money_change(m_cave_ret.coin);
        m_user.on_exp_change(m_cave_ret.exp);
        m_user.on_power_change(-POW_CAVE);
        m_user.on_soul_change(m_cave_ret.soul);

        //结算助战英雄
        if( m_cur_uid!=0 )
        {
            helphero_cache.add_helpcount(m_cur_uid);
            if( m_user.friend_mgr.is_frd(m_cur_uid) )
            {
                helphero_cache.add_fpoint(m_user.db.uid,FPOINT_HELPER);
                helphero_cache.add_fpoint(m_cur_uid,FPOINT_HELPER);
                helphero_cache.set_helper(m_user.db.uid,m_cur_uid);
            }
            else
            {
                helphero_cache.add_fpoint(m_user.db.uid,FPOINT_STRANGER);
                helphero_cache.add_fpoint(m_cur_uid,FPOINT_STRANGEE);
            }
        }

        m_user.save_db();
        //保存碎片到数据库
        sc_msg_def::nt_chip_change_t nt_chip;
        sc_msg_def::nt_bag_change_t nt_bag;
        for(size_t i=0; i<m_cave_ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = m_cave_ret.drop_items[i];
            if( 30001 <= item.resid && item.resid <= 39999 )
                m_user.partner_mgr.add_new_chip(item.resid, item.num, nt_chip);
            else
                m_user.item_mgr.addnew(item.resid, item.num, nt_bag);
        }
        m_user.partner_mgr.on_chip_change(nt_chip);
        m_user.item_mgr.on_bag_change(nt_bag);


        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        //m_user.daily_task.on_event(evt_miku_pass);
        for(size_t i=0;i<req_.killed.size();i++){
            m_user.task.on_monsert_killed(req_.killed[i].resid,req_.killed[i].num);
            m_user.love_task.on_monster_killed(req_.killed[i].resid,req_.killed[i].num);
        }

        //判断战斗力
        repo_def::cave_t *p_r = repo_mgr.cave.get(req_.resid);
        if( NULL == p_r )
        {
            logerror((LOG, "compare fp, no roundid, %d", req_.resid));
            return;
        }
        if( p_r->fighting_capacity > m_user.db.fp )
            statics_ins.unicast_fpexception(m_user,req_.resid,p_r->fighting_capacity);

    }

    //通知客户端战斗结束
    ret.resid = req_.resid;
    ret.win = req_.win;
    ret.stars = req_.stars;
    logic.unicast(m_user.db.uid, ret);

    clear_state();
}
void sc_new_round_t::pass_cave(sc_msg_def::req_cave_pass_t &req_)
{
    sc_msg_def::ret_cave_pass_fail_t fail;
    fail.resid = req_.resid;
    fail.count = req_.count;

    //判断挂机是否冷却
    auto it_pass_round = round_cache.m_cave_pass_round_hm.find(m_user.db.uid);
    if( it_pass_round == round_cache.m_cave_pass_round_hm.end() )
        it_pass_round = round_cache.m_cave_pass_round_hm.insert(make_pair(m_user.db.uid,0)).first;
    uint32_t cur_sec = date_helper.cur_sec();	//取得当前时间

    //计算挂机结果
    sc_msg_def::ret_cave_pass_t ret;
    ret.resid = req_.resid;
    ret.count = req_.count;

    if (m_user.db.viplevel >= 4)
    {
        ret.left_secs = 0; 
        it_pass_round->second = 0;
    }
    else
        ret.left_secs = PASS_ROUND_INTERVAL; 

    if( cur_sec - it_pass_round->second < PASS_ROUND_INTERVAL )
    {
        logerror((LOG,"pass cave, time interval"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断关卡id是否有效
    repo_def::cave_t *p_r = NULL;
    p_r = repo_mgr.cave.get(req_.resid);
    if (p_r == NULL)
    {
        logerror((LOG,"pass cave,no round,resid:%d",req_.resid));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //该关卡是否有资格打
    if( m_user.db.caveid < req_.resid )
    {
        logerror((LOG,"pass cave, no enterance"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //剩余次数是否足够
    auto it_hm = round_cache.m_cave_hm.find(m_user.db.uid);
    if( it_hm == round_cache.m_cave_hm.end() )
    {
        hash_map<int32_t, sp_cave_t> user_hm;
        it_hm = round_cache.m_cave_hm.insert(make_pair(m_user.db.uid,std::move(user_hm))).first;
    }
    auto it_p = it_hm->second.find(req_.resid);
    if( it_p == it_hm->second.end() )
    {
        sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
        it_p = it_hm->second.insert( make_pair(req_.resid,sp_cave) ).first;
    }
    if( (it_p->second->n_enter + req_.count ) > N_ENTER_CAVE )
    {
        logerror((LOG,"pass cave, not enough enter"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }
    //判断体力是否足够
    if( m_user.db.power<(POW_CAVE*req_.count) )
    {
        logerror((LOG,"pass round, not enough power"));
        fail.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, fail);
        return;
    }

    //减去进入次数
    auto it_cave_hm = round_cache.m_cave_hm.find(m_user.db.uid);
    if( it_cave_hm != round_cache.m_cave_hm.end() )
    {
        auto it_p = (it_cave_hm->second).find(req_.resid);
        if( it_p == (it_cave_hm->second).end() )
        {
            sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
            (sp_cave->n_enter) += req_.count;

            (it_cave_hm->second).insert( make_pair(req_.resid,sp_cave) );
        }
        else
            (it_p->second->n_enter) += req_.count;
    }
    else
    {
        sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
        (sp_cave->n_enter) += req_.count;

        hash_map<int32_t,sp_cave_t> user_hm;
        user_hm.insert(make_pair(req_.resid,sp_cave));

        round_cache.m_cave_hm.insert( make_pair(m_user.db.uid,std::move(user_hm) ) );
    }

    sc_msg_def::nt_chip_change_t nt_chip;
    sc_msg_def::nt_bag_change_t nt_bag;
    for( int i = 0; i < req_.count; ++i )
    {
        //计算掉落
        sc_msg_def::jpk_pass_cave_result_t res;
        res.exp = p_r->exp;
        res.coin = p_r->coin;
        res.soul = p_r->soul;
        gen_drop_chips(req_.resid, res.drop_items);

        //保存碎片到数据库
        for(size_t j=0; j<res.drop_items.size(); ++j)
        {
            sc_msg_def::jpk_item_t& item = res.drop_items[j];
            if( 30001 <= item.resid && item.resid <= 39999 )
                m_user.partner_mgr.add_new_chip(item.resid, item.num, nt_chip);
            else
                m_user.item_mgr.addnew(item.resid, item.num, nt_bag);

        }
        ret.results.push_back( std::move(res) );

        //任务
        m_user.task.on_round_pass(req_.resid);
        m_user.love_task.on_round_pass(req_.resid);
        //m_user.daily_task.on_event(evt_miku_pass);
        for(size_t j=0;j<req_.killed.size();j++){
            m_user.task.on_monsert_killed(req_.killed[j].resid,req_.killed[j].num);
            m_user.love_task.on_monster_killed(req_.killed[j].resid,req_.killed[j].num);
        }
    }
    m_user.partner_mgr.on_chip_change(nt_chip);
    m_user.item_mgr.on_bag_change(nt_bag);

    m_user.on_money_change( (p_r->coin) * req_.count );
    m_user.on_exp_change( (p_r->exp) * req_.count );
    m_user.on_power_change( - POW_CAVE * req_.count );
    m_user.on_fpoint_change( FPOINT_PER_PASS * req_.count );
    m_user.on_soul_change((p_r->soul) * req_.count );
    m_user.save_db();

    it_pass_round->second = cur_sec;
    logic.unicast(m_user.db.uid, ret); 
} 
void sc_new_round_t::flush_cave( int32_t resid_ )
{
    sc_msg_def::ret_cave_flush_t ret;
    ret.resid = resid_;

    //判断关卡id是否有效
    repo_def::cave_t *p_r = NULL;
    p_r = repo_mgr.cave.get(resid_);
    if (p_r == NULL)
    {
        logerror((LOG,"flush cave,no round,resid:%d",resid_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //扣钱 
    int32_t cur = round_cache.get_cave_flush_count(m_user.db.uid,resid_);
    int32_t code = m_user.vip.buy_vip(vop_flush_cave,cur+1);
    if (code != SUCCESS)
    {
        ret.code = code;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //刷新英雄迷窟
    auto it_hm = round_cache.m_cave_hm.find(m_user.db.uid);
    if( it_hm == round_cache.m_cave_hm.end() )
    {
        hash_map<int32_t, sp_cave_t> user_hm;
        it_hm = round_cache.m_cave_hm.insert(make_pair(m_user.db.uid,std::move(user_hm))).first;
    }
    auto it_p = it_hm->second.find(resid_);
    if( it_p == it_hm->second.end() )
    {
        sp_cave_t sp_cave(new sc_msg_def::sc_cave_t);
        it_p = it_hm->second.insert( make_pair(resid_,sp_cave) ).first;
    }
    it_p->second->n_enter = 0;
    ++(it_p->second->n_flush);

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}
/////////////////////////////////////////
void sc_round_cache_t::reset(int32_t uid_)
{
    auto it_flush = m_flush_hm.find(uid_);
    if( it_flush != m_flush_hm.end() )
    {
        if(date_helper.offday(it_flush->second)>=1)
        {
            auto it_round = m_round_hm.find(uid_);
            if( it_round != m_round_hm.end() )
                m_round_hm.erase( it_round );

            auto it_zodiac = m_zodiac_hm.find(uid_);
            if( it_zodiac != m_zodiac_hm.end() )
                m_zodiac_hm.erase( it_zodiac );

            auto it_rmb = m_rmb_hm.find(uid_);
            if( it_rmb != m_rmb_hm.end() )
                m_rmb_hm.erase( it_rmb );

            auto it_free_zodiac = m_free_zodiac_hm.find(uid_);
            if( it_free_zodiac != m_free_zodiac_hm.end() )
                m_free_zodiac_hm.erase( it_free_zodiac );

            auto it_free_elite = m_free_elite_hm.find(uid_);
            if( it_free_elite != m_free_elite_hm.end() )
                m_free_elite_hm.erase( it_free_elite );

            auto it_cave = m_cave_hm.find(uid_);
            if( it_cave != m_cave_hm.end() )
                m_cave_hm.erase( it_cave );
            //第二天重置英雄迷窟时间
            auto it_cave_flush = m_cave_pass_round_hm.find(uid_);
            if(it_cave_flush != m_cave_pass_round_hm.end())
                m_cave_pass_round_hm.erase(it_cave_flush);

            it_flush->second = date_helper.cur_sec();
        }
    }
    else
        m_flush_hm.insert( make_pair(uid_,date_helper.cur_sec()) );
}

void sc_round_cache_t::get_pass_round(int32_t uid_, vector<int32_t> &ret)
{
    reset(uid_);
    auto it_hm = m_round_hm.find(uid_);
    if( it_hm != m_round_hm.end() )
    {
        auto it_m = (it_hm->second).begin();
        while( it_m != (it_hm->second).end() )
        {
            ret.insert(ret.end(),(it_m->second).begin(),(it_m->second).end() );
            ++it_m;
        }
    }
}

void sc_round_cache_t::get_zodiac(int32_t uid_,map<int32_t,int32_t> &ret,map<int32_t,sc_msg_def::sc_cave_t> &cave_)
{
    reset(uid_);

    /*
       auto it_hm = m_zodiac_hm.find(uid_);
       if(it_hm!=m_zodiac_hm.end() )
       {
       auto it_m = (it_hm->second).begin();
       while(it_m!=(it_hm->second).end() )
       {
       ret.insert(make_pair(it_m->first,it_m->second));
       ++it_m;
       }
       }
       */

    auto it_hm_cave = m_cave_hm.find(uid_);
    if( it_hm_cave != m_cave_hm.end() )
    {
        auto it_p = (it_hm_cave->second).begin();
        while(it_p!=(it_hm_cave->second).end())
        {
            cave_.insert(make_pair(it_p->first,*(it_p->second)));
            ++it_p;
        }
    }
}

int32_t sc_round_cache_t::get_cave_flush_count(int32_t uid_,int32_t resid_)
{
    reset(uid_);

    auto it_hm_cave = m_cave_hm.find(uid_);
    if( it_hm_cave != m_cave_hm.end() )
    {
        auto it_p = (it_hm_cave->second).find(resid_);
        if( it_p != (it_hm_cave->second).end() )
            return it_p->second->n_flush;
        else
            return 0;
    }
    return 0;
}
void sc_round_cache_t::get_free_flush(sc_user_t &user_,int32_t uid_,int32_t &elite_,int32_t &zodiac_)
{
    if( user_.reward.is_activity_open(activity_free_flush_round) )
    {
        reset(uid_);

        auto it_elite = m_free_elite_hm.find(uid_);
        if(it_elite==m_free_elite_hm.end() )
            elite_ = 0;
        else
            elite_ = 1;

        auto it_zodiac= m_free_zodiac_hm.find(uid_);
        if(it_zodiac==m_free_zodiac_hm.end() )
            zodiac_= 0;
        else
            zodiac_ = 1;
    }
    else
        elite_ = zodiac_ = -1;
}
sc_expedition_t::sc_expedition_t(sc_user_t& user_):m_user(user_)
{
    m_cur_round = 0;
    m_cur_max_round = -1;
    m_last_max_round = -1;
    m_utime = date_helper.cur_sec();
    m_is_refresh_today = 0;
    m_is_pass_all_round = false;
    m_fight_time = -1;
    m_set_last = false;
    m_can_sweep = true;
}
void sc_expedition_t::load_db()
{
    m_cur_max_round = EXPEDITION_BEGIN-1;
    sql_result_t res;
    int passnum = 0;
    if (0 == db_Expedition_t::sync_select_uid(m_user.db.uid, res)) {
        for (size_t i = 0; i < res.affect_row_num(); ++i) {
            sp_expedition_t sp_expedition(new expedition_t);
            sp_expedition->init(*res.get_row_at(i));
            m_expedition_hm.insert(make_pair(sp_expedition->resid, sp_expedition));
            if (sp_expedition->open_box != -1 && m_cur_max_round < sp_expedition->resid)
            {
                ++passnum;   
                m_cur_max_round = sp_expedition->resid;
            }
            m_utime = sp_expedition->utime;
            m_is_refresh_today = sp_expedition->is_refresh_today;
        }
    }
    if (m_cur_max_round < EXPEDITION_END)
        ++m_cur_max_round;
    if (passnum == 15)
        m_is_pass_all_round = true;
    char sql[256];
    sql_result_t res_last;
    sprintf(sql, "SELECT last_max_round_expedition FROM UserInfo WHERE uid=%d;", m_user.db.uid);
    db_service.sync_select(sql, res_last);
    if (0 == res_last.affect_row_num())    //没有找到
    {
        m_last_max_round = -1;
    }
    else
    {
        sql_result_row_t& row = *res_last.get_row_at(0);
        m_last_max_round = (int)std::atoi(row[0].c_str());
    }
    check24();
}
void sc_expedition_t::save_db(sp_expedition_t& sp_expedition_)
{
    string sql = sp_expedition_->get_up_sql();
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
            db_service.async_execute(sql_);
            }, sql);
}
//策划说一共15关
void sc_expedition_t::reset_round_data(int32_t refresh_times_= 0)
{
    uint32_t cur_sec = date_helper.cur_sec();
    int32_t duid = 0;
    int32_t pids[5] = {-1, -1, -1, -1, -1};
    m_utime = cur_sec;

    sql_result_t res;
    char sql[512];
    //sprintf(sql, "(select Team.uid, p1, p2, p3, p4, p5, grade from UserInfo, Team where UserInfo.uid = Team.uid and is_default = 1 and hostnum = %d and UserInfo.uid != %d and ((cast(grade as signed) - %d < 5 and grade >= %d) or (%d - cast(grade as signed) < 10 and grade < %d)) and p1 + p2 + p3 + p4 + p5 > 0 order by rand() limit %d )order by grade", m_user.db.hostnum, m_user.db.uid, m_user.db.grade, m_user.db.grade, m_user.db.grade, m_user.db.grade, EXPEDITION_END - EXPEDITION_BEGIN + 1);
    sprintf(sql, "(select Team.uid, p1, p2, p3, p4, p5, grade, fp from UserInfo, Team where UserInfo.uid = Team.uid and is_default = 1 and hostnum = %d and UserInfo.uid != %d and ((cast(grade as signed) - %d < 5 and grade >= %d) or (%d - cast(grade as signed) < 10 and grade < %d)) and p1 + p2 + p3 + p4 + p5 > 0 order by rand() limit %d )order by grade asc, fp asc", m_user.db.hostnum, m_user.db.uid, m_user.db.grade, m_user.db.grade, m_user.db.grade, m_user.db.grade, EXPEDITION_END - EXPEDITION_BEGIN + 1);
    db_service.sync_select(sql, res);
    if (res.affect_row_num() < 15)
    {
        sprintf(sql, "(select Team.uid, p1, p2, p3, p4, p5, grade, fp from UserInfo, Team where UserInfo.uid = Team.uid and is_default = 1 and hostnum = %d and UserInfo.uid != %d and p1 + p2 + p3 + p4 + p5 > 0 order by abs(cast(grade as signed) - %d) limit %d )order by grade asc, fp asc", m_user.db.hostnum, m_user.db.uid, m_user.db.grade, EXPEDITION_END - EXPEDITION_BEGIN + 1);
        db_service.sync_select(sql, res);
    }
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load expedition grade get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        duid = (int)std::atoi(row_[0].c_str()); 
        pids[0] = (int)std::atoi(row_[1].c_str());
        pids[1] = (int)std::atoi(row_[2].c_str());
        pids[2] = (int)std::atoi(row_[3].c_str());
        pids[3] = (int)std::atoi(row_[4].c_str());
        pids[4] = (int)std::atoi(row_[5].c_str());

        sp_fight_view_user_t sp_view = view_cache.get_fight_view(duid, pids, true);

        add_hp(sp_view);
        string vd;
        (*sp_view) >> vd;
        update_expedition_round(i + EXPEDITION_BEGIN, pids, vd, refresh_times_);
    }

    //for (int i = EXPEDITION_BEGIN; i <= EXPEDITION_END; ++i)
    //    fill_round(i, refresh_times_);
    m_cur_max_round = EXPEDITION_BEGIN;
}
void sc_expedition_t::fill_round(int32_t index_, int32_t refresh_times_ = 0)
{
    repo_def::expedition_t *expedition_ = repo_mgr.expedition.get(index_);
    if (expedition_ == NULL)
    {
        logerror((LOG, "expedition is null, index = %d", index_));
        return;
    }
    int l = m_user.db.grade;
    int h = m_user.db.grade;
    l += expedition_->lv_min;
    h += expedition_->lv_max;
    int32_t l_pid[5] = {-1, -1, -1, -1, -1}, h_pid[5] = {-1, -1, -1, -1, -1}, *pid = NULL;;
    int32_t l_uid, h_uid;
    bool bl = arena_info_cache.get_arena_pid(m_user.db.hostnum, m_user.db.uid, l, l_uid, l_pid);
    bool bh = arena_info_cache.get_arena_pid(m_user.db.hostnum, m_user.db.uid, h, h_uid, h_pid);
    sp_fight_view_user_t sp_view;
    if (bl && bh) {
        if (random_t::rand_integer(0, 1)) {
            pid = l_pid;
            sp_view = view_cache.get_fight_view(l_uid, l_pid, true);
        } else {
            pid = h_pid;
            sp_view = view_cache.get_fight_view(h_uid, h_pid, true);
        }
    }
    else if (bl) {
        pid = l_pid;
        sp_view = view_cache.get_fight_view(l_uid, l_pid, true);
    } else if (bh) {
        pid = h_pid;
        sp_view = view_cache.get_fight_view(h_uid, h_pid, true);
    } else {
        int32_t base = l;
        int32_t span = 1;
        int32_t level = 0;
        while(true) {
            level = base + span;
            if (level > 0 && level <= server.db.maxlv) {
                bl = arena_info_cache.get_arena_pid(m_user.db.hostnum, m_user.db.uid, level, l_uid, l_pid);
                if (bl) {
                    pid = l_pid;
                    sp_view = view_cache.get_fight_view(l_uid, l_pid, true);
                    break;
                }
                span = span > 0 ? -span : -span + 1;
            }
            else break;
        };
    }
    add_hp(sp_view);
    string vd;
    (*sp_view) >> vd;
    update_expedition_round(index_, pid, vd, refresh_times_);
}
void sc_expedition_t::update_expedition_round(int32_t resid_, int32_t *pid_, string view_, int32_t refresh_times_ = 0)
{
    auto it = m_expedition_hm.find(resid_);
    if (it == m_expedition_hm.end()) {
        sp_expedition_t sp_expedition_(new expedition_t);
        sp_expedition_->uid = m_user.db.uid;
        sp_expedition_->resid = resid_;
        sp_expedition_->pid1 = pid_[0];
        sp_expedition_->pid2 = pid_[1];
        sp_expedition_->pid3 = pid_[2];
        sp_expedition_->pid4 = pid_[3];
        sp_expedition_->pid5 = pid_[4];
        sp_expedition_->hp1 = 1;
        sp_expedition_->hp2 = 1;
        sp_expedition_->hp3 = 1;
        sp_expedition_->hp4 = 1;
        sp_expedition_->hp5 = 1;
        sp_expedition_->view_data = view_;
        sp_expedition_->open_box = -1;
        sp_expedition_->refresh_type = refresh_times_;
        sp_expedition_->is_refresh_today = m_is_refresh_today;
        sp_expedition_->utime = m_utime;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Expedition_t& db_){
                db_.insert();
                }, sp_expedition_->data());
        m_expedition_hm.insert(make_pair(sp_expedition_->resid, sp_expedition_));
    } else {
        it->second->set_pid1(pid_[0]);
        it->second->set_pid2(pid_[1]);
        it->second->set_pid3(pid_[2]);
        it->second->set_pid4(pid_[3]);
        it->second->set_pid5(pid_[4]);
        it->second->set_hp1(1.0);
        it->second->set_hp2(1.0);
        it->second->set_hp3(1.0);
        it->second->set_hp4(1.0);
        it->second->set_hp5(1.0);
        it->second->set_view_data(view_);
        it->second->set_open_box(-1);
        it->second->set_refresh_type(refresh_times_);
        it->second->set_is_refresh_today(m_is_refresh_today);
        it->second->set_utime(m_utime);
        save_db(it->second);
    }
}
void sc_expedition_t::get_gang_name(int32_t uid, string &gangname)
{
    char sql1[256];
    sql_result_t res1;
    sprintf(sql1,  "select ggid from GangUser where uid=%d;",uid);
    db_service.sync_select(sql1, res1);
    if (0 == res1.affect_row_num())
    {
        gangname = "未参加";
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
int32_t sc_expedition_t::get_expedition_round(sc_msg_def::ret_expedition_round_t& ret)
{
    if (m_cur_max_round == -1) {
        reset_round_data(3);
    }
    if (!(EXPEDITION_BEGIN <= m_cur_max_round && m_cur_max_round <= EXPEDITION_END))
        return -1;
    auto it = m_expedition_hm.find(m_cur_max_round);
    if (it == m_expedition_hm.end())
        return -1;
    check24();
    sc_msg_def::jpk_fight_view_user_data_t data_;
    data_ << it->second->view_data;
    
    sc_msg_def::jpk_expedition_enemy_role_t info_;
    info_.nickname = data_.name;
    info_.viplv = data_.viplevel;
    info_.rank = data_.rank;
    info_.unionname = "無";
    info_.level = data_.lv;
    ret.combo_pro.combo_d_down = data_.combo_pro.combo_d_down;
    ret.combo_pro.combo_r_down = data_.combo_pro.combo_r_down;
    ret.combo_pro.combo_d_up =  data_.combo_pro.combo_d_up;
    ret.combo_pro.combo_r_up =  data_.combo_pro.combo_r_up;
    for (auto it = data_.combo_pro.combo_anger.begin(); it != data_.combo_pro.combo_anger.end(); ++it){
       ret.combo_pro.combo_anger.insert(make_pair(it->first,it->second)); 
    }
    //获取公会名字
    get_gang_name(data_.uid, info_.unionname);

    //  求总战斗力
    int total_fp = 0;
    //这个方法获取的是实时战斗力
    /*sp_view_user_t sp_view = view_cache.get_view(data_.uid, true);
    if (sp_view != NULL)
    {
        for(auto it = sp_view->roles.begin(); it!= sp_view->roles.end(); it++)
        {    
            total_fp += it->second.pro.fp;
        }
    }
    info_.fp = total_fp; 
    ret.info.push_back(std::move(info_));
    */
    auto fill_jpk = [&](int32_t pid) {
        if (pid < 0) return -1;
        sc_msg_def::jpk_expedition_enemy_t jpk_;
        for (auto itt = data_.roles.begin(); itt != data_.roles.end(); ++itt)
        {
            if (itt->second.pid == pid)
            {
                jpk_.resid = itt->second.resid;
                jpk_.level = itt->second.lvl[0];
                jpk_.lovelevel = itt->second.lvl[1];
                //data_.roles.pro[8]是每一个人的战斗力
                total_fp += itt->second.pro[8]; 
                if (pid == 0)
                {
                    sql_result_t buf;
                    char sel[256];
                    sprintf(sel, "select quality from UserInfo where uid=%d;",data_.uid );
                    db_service.sync_select(sel, buf);
                    if (0 == buf.affect_row_num())    //没有找到
                    {
                        jpk_.starnum = 1;    
                    }else {
                        sql_result_row_t& row = *buf.get_row_at(0);
                        jpk_.starnum = (int)std::atoi(row[0].c_str());
                    }
                }else{
                    get_starnum(itt->second.uid, pid, jpk_.starnum);
                }
                jpk_.equiplv = sc_user_t::get_equip_level(itt->second.uid, pid);
                break;
            }
        }
        auto e = m_expedition_hm.find(m_cur_max_round);
        if (e == m_expedition_hm.end()) return -1;
        if (pid == it->second->pid1)
            jpk_.hp = it->second->hp1;
        else if (pid == it->second->pid2)
            jpk_.hp = it->second->hp2;
        else if (pid == it->second->pid3)
            jpk_.hp = it->second->hp3;
        else if (pid == it->second->pid4)
            jpk_.hp = it->second->hp4;
        else if (pid == it->second->pid5)
            jpk_.hp = it->second->hp5;
        else jpk_.hp = 1;
        ret.enemys.push_back(std::move(jpk_));
        return 0;
    };

    fill_jpk(it->second->pid1);
    fill_jpk(it->second->pid2);
    fill_jpk(it->second->pid3);
    fill_jpk(it->second->pid4);
    fill_jpk(it->second->pid5);
    //战斗力
    info_.fp = total_fp; 
    ret.info.push_back(std::move(info_));
    return SUCCESS;
}

/*void sc_expeditget_equip_level(int32_t uid,int32_t pid, int32_t &equiplv)
{
    // !!! 卡牌活动也有此函数 
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

void sc_expedition_t::get_starnum(int32_t uid, int32_t pid, int32_t &rank)
{
    /* !!! 卡牌活动也有此函数 */
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select quality from Partner where uid=%d and pid=%d;", uid, pid);  //Partner表不包含主角本身
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        rank = 0;
        return;
    }

    sql_result_row_t& row = *res.get_row_at(0);
    rank = (int)std::atoi(row[0].c_str());
}


int32_t sc_expedition_t::get_expedition_data(sc_msg_def::ret_expedition_t& ret)
{
    if (m_user.db.grade < EXPEDITION_BEGIN_LEVEL) {
        logerror((LOG, "get_expedition_data failed, grade <= %d", EXPEDITION_BEGIN_LEVEL));
        return ERROR_SC_EXPEDITION_LESS_LEVEL;
    }
    if (m_expedition_hm.size() == 0) {
        reset_round_data(4);
    }
    check24();
    
    for (int i = EXPEDITION_BEGIN; i <= m_cur_max_round; ++i) {
        auto it = m_expedition_hm.find(i);
        if (it == m_expedition_hm.end())
        {
            reset_round_data(1);
            return ERROR_SC_NO_EXPEDITION_ROUND;
        }
        sc_msg_def::jpk_expedition_t jpk_;
        jpk_.resid = i;
        jpk_.box = it->second->open_box;
        ret.round.push_back(std::move(jpk_));
        if (it->second->open_box == 1) break;
    }
    ret.cur_max_round = m_cur_max_round;
    ret.last_max_round = m_last_max_round;
    ret.can_sweep = (m_last_max_round - (EXPEDITION_BEGIN+3) >= 0) && m_can_sweep;
    ret.reset_times = 0;
    return SUCCESS;
}
int32_t sc_expedition_t::enter_expedition(int32_t resid_, sc_msg_def::ret_enter_expedition_round_t &ret)
{
    random_t::rand_str(m_salt,16);
    m_fight_time = date_helper.cur_sec() % 3600;
    if (resid_ < EXPEDITION_BEGIN || resid_ > EXPEDITION_END)
        return ERROR_SC_NO_EXPEDITION_ROUND;
    auto it = m_expedition_hm.find(resid_);
    if (it == m_expedition_hm.end())
        return ERROR_SC_NO_EXPEDITION_ROUND;
    ret.view_data = it->second->view_data;
    auto fill_team = [&](int32_t pid_, float hp_){
        sc_msg_def::jpk_expedition_partner_t jpk_;
        jpk_.pid = pid_;
        jpk_.hp = hp_;
        ret.team.push_back(std::move(jpk_));
    };
    fill_team(it->second->pid1, it->second->hp1);
    fill_team(it->second->pid2, it->second->hp2);
    fill_team(it->second->pid3, it->second->hp3);
    fill_team(it->second->pid4, it->second->hp4);
    fill_team(it->second->pid5, it->second->hp5);
    m_cur_round = resid_;
    m_user.daily_task.on_event(evt_pass_zodiac);
    ret.salt = m_salt;
    return SUCCESS;
}
int32_t sc_expedition_t::exit_expedition(const sc_msg_def::req_exit_expedition_round_t &jpk_)
{
    if (jpk_.salt != m_salt)
    {
        logwarn((LOG, "EXPEDITION_END ERROR_SALT_FAILED, jpk_.salt: %s, m_salt: %s ", jpk_.salt.c_str(), m_salt.c_str()));
        return ERROR_SALT_FAILED;
    }
    m_salt = "qwertyuimnbvcxz;%";
    int cur_time = date_helper.cur_sec() % 3600;
    if( cur_time < m_fight_time )
        cur_time += 3600;
    if( cur_time - m_fight_time <= 2 )
    {
        logwarn((LOG, "EXPEDITION_END ERROR time check fail"));
        return ERROR_SALT_FAILED;
    }

    if (m_cur_round == 0)
        return FAILED;

    auto it = m_expedition_hm.find(m_cur_round);
    if (it == m_expedition_hm.end())
        return ERROR_SC_NO_EXPEDITION_ROUND;

    for (auto actor : jpk_.enemy)
    {
        if (actor.pid == it->second->pid1)
            it->second->set_hp1(actor.hp);
        else if (actor.pid == it->second->pid2)
            it->second->set_hp2(actor.hp);
        else if (actor.pid == it->second->pid3)
            it->second->set_hp3(actor.hp);
        else if (actor.pid == it->second->pid4)
            it->second->set_hp4(actor.hp);
        else if (actor.pid == it->second->pid5)
            it->second->set_hp5(actor.hp);
    }
    save_db(it->second);
    if (jpk_.is_win && m_cur_max_round < EXPEDITION_END) 
    {
        ++m_cur_max_round;
        m_user.reward.update_opentask(open_task_expedition_allnum);
        if (it->second->open_box == -1)
        {
            it->second->set_open_box(1);
            save_db(it->second);
        }
    }
    else if (jpk_.is_win && m_cur_max_round == EXPEDITION_END)
    { 
        set_last_max_round(EXPEDITION_END);
        m_user.reward.update_opentask(open_task_expedition_allnum);
        if (it->second->open_box == -1)
        {
            it->second->set_open_box(1);
            save_db(it->second);
        }
    }

    m_cur_round = 0;
    return m_user.team_mgr.update_team(jpk_.ally, jpk_.anger);
}
void sc_expedition_t::pass_expedition()
{
    sc_msg_def::ret_sweep_expedition_t ret;
    int32_t round_can_sweep = m_last_max_round - 3;
    if (m_cur_max_round > round_can_sweep)
    {
        ret.code = ERROR_CANT_SWEEP;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    bool isDouble = m_user.reward.get_expedition_state();
    ret.start = m_cur_max_round;
    ret.last = round_can_sweep;
    for (int i = m_cur_max_round; i <= round_can_sweep; ++i) {
        auto it = m_expedition_hm.find(i);
        sc_msg_def::ret_expedition_round_reward_t ret_reward;
        int32_t ret_code = send_reward(it->second->resid, it->second->refresh_type, ret_reward, isDouble);
        if (ret_code == SUCCESS)
        {
            it->second->set_open_box(0);
            save_db(it->second);
            sc_msg_def::expedition_drop_t drop;
            drop.floor = it->second->resid;
            for (auto it_r=ret_reward.reward.begin(); it_r!=ret_reward.reward.end(); ++it_r)
            {
                drop.drops.insert(make_pair(it_r->resid, it_r->num));
            }
            ret.drops.push_back(std::move(drop));
            m_user.reward.update_opentask(open_task_expedition_allnum);
        }
    }
    m_cur_max_round = round_can_sweep+1;
    if (m_cur_max_round > EXPEDITION_END)
        m_cur_max_round = EXPEDITION_END;

    m_can_sweep = false;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return;
}
void sc_expedition_t::set_last_max_round(int32_t round_)
{
    if (m_set_last)
        return;
    m_set_last = true;
    m_last_max_round = round_;
    char sql[256];
    sql_result_t res;
    sprintf(sql, "UPDATE UserInfo SET last_max_round_expedition = %d WHERE uid = %d;", m_last_max_round,m_user.db.uid);
    db_service.sync_select(sql, res);
}
int32_t sc_expedition_t::get_reward(int32_t resid_, sc_msg_def::ret_expedition_round_reward_t &ret ,bool isDouble)
{
    if (resid_ > m_cur_max_round)
        return ERROR_SC_NO_PASS_EXPEDITION_ROUND;
    auto it = m_expedition_hm.find(resid_);
    if (it == m_expedition_hm.end())
        return ERROR_SC_NO_EXPEDITION_ROUND;
    if (it->second->open_box == -1)
        return ERROR_SC_NO_PASS_EXPEDITION_ROUND;
    if (it->second->open_box == 0)
        return ERROR_SC_HAS_BEEN_OPEND;
    int32_t ret_code = send_reward(resid_, it->second->refresh_type, ret ,isDouble);
    if (ret_code == SUCCESS)
    {
        it->second->set_open_box(0);
        save_db(it->second);
    }
    return ret_code;
}

int32_t sc_expedition_t::send_reward(int32_t resid_, int32_t type, sc_msg_def::ret_expedition_round_reward_t &ret , bool isDouble)
{
    repo_def::expedition_t *expedition_ = repo_mgr.expedition.get(resid_);
    if (expedition_ == NULL)
        return ERROR_SC_NO_EXPEDITION_ROUND;
    sc_msg_def::nt_bag_change_t nt;

    auto fill_reward = [&](int32_t resid, int32_t num, int32_t ext = 0){
        if (resid == 10001) {
            num = random_t::rand_integer((int32_t)(num*0.95), (int32_t)(num*1.05));
            m_user.on_money_change(num);
            m_user.save_db();
        }
        else if (resid == 10019) {
            m_user.on_expeditioncoin_change(num);
            m_user.save_db();
        }
        else if (resid == -1) {
            repo_def::expedition_hero_piece_t *ehp = repo_mgr.expedition_hero_piece.get(ext);
            if (ehp == NULL)
                return;
            if (m_user.db.resid == 101)
            { resid = ehp->hero_piece1[1]; num = ehp->hero_piece1[2]; }
            else if (m_user.db.resid == 102)
            { resid = ehp->hero_piece2[1]; num = ehp->hero_piece2[2]; }
            else if (m_user.db.resid == 103)
            { resid = ehp->hero_piece3[1]; num = ehp->hero_piece3[2]; }

            m_user.item_mgr.addnew(resid,num, nt);
        }
        else 
            m_user.item_mgr.addnew(resid,num, nt);
        sc_msg_def::jpk_expedition_reward_t er;
        er.resid = resid; er.num = num;
        ret.reward.push_back(std::move(er));
    };
    auto single_reward = [&](int32_t box_id) {
        uint32_t r = random_t::rand_integer(1, 10000), now_r = 0;
        int32_t end = (box_id + 1) * 10000;
        for (int32_t i = box_id * 10000 + 1; i < end; ++i)
        {
            repo_def::expedition_box_t *box = repo_mgr.expedition_box.get(i);
            if (box == NULL) break;
            if (box->level_range[1] <= m_user.db.grade && m_user.db.grade <= box->level_range[2])
            {
                now_r += m_user.db.viplevel >= EXPEDITION_REWARD_VIP_LEVEL ? box->pro_2 : box->pro_1;
                if (now_r >= r)
                {
                    fill_reward(box->reward[1], box->reward[2], box->reward[2]);
                    break;
                }
            }
        }
    };
    if (type == 0 || type == 1)
    {
        fill_reward(10001, isDouble ? (int32_t)(expedition_->gold_drop * 2.2) : (int32_t)(expedition_->gold_drop * 1.1)); // 
        fill_reward(10019, isDouble ? expedition_->expedition_coin * 2 : expedition_->expedition_coin);
    }
    else fill_reward(10001, isDouble ? expedition_->gold_drop * 2 : expedition_->gold_drop);
    for (int i = 0; i < expedition_->drop[2]; ++i)
        single_reward(expedition_->drop[1]);

    ret.resid = resid_;
    m_user.item_mgr.on_bag_change(nt);
    return SUCCESS;
}
int32_t sc_expedition_t::reset(sc_msg_def::req_expedition_reset_t &jpk_, sc_msg_def::ret_expedition_reset_t &ret)
{
    auto anyone = m_expedition_hm.begin();
    if (anyone == m_expedition_hm.end()) {
        return FAILED;
    }
    check24();
    set_last_max_round(m_cur_max_round-1);
    m_set_last = false;
    m_can_sweep = true;
    if (m_is_refresh_today == 0) { // 今日未重置过则可以重置远征，不考虑以往状况
        m_is_refresh_today = 1;
        reset_round_data(1);
    } else if (anyone->second->refresh_type == 0) { // 可进行一次免费刷新
        reset_round_data(1);
    } 
    /*else if (anyone->second->refresh_type == 1) { // 可进行钻石刷新，需VIP等级，具体等级策划暂时未给
        if (m_user.db.viplevel >= EXPEDITION_REFRESH_VIP_LEVEL) { // 乱写的等级 等策划定好viplevel后再进行更改
            // m_is_refresh_today 在此处可不用set
            reset_round_data(2);
        } else {
            return ERROR_SC_NOT_ENOUGH_VIP; // vip等级不足
        }
    }
    */
    else {
        return ERROR_SC_NO_FLUSH; // 当日不可再刷新
    }
    //如果双倍远征 需要将标识位设置为1
    if (m_user.reward.isInDoubleActivity(4))
    {
        m_user.reward.change_expedition_state(1);
    }else{
        m_user.reward.change_expedition_state(0);
    }
    return m_user.team_mgr.reset_expedition_partners();
}
inline void sc_expedition_t::check24()
{
    if (date_helper.offday(m_utime) >= 1) {
        m_is_refresh_today = 0;
        for (auto it = m_expedition_hm.begin(); it != m_expedition_hm.end(); ++it) {
            it->second->set_refresh_type(0);
            it->second->set_is_refresh_today(0);
            save_db(it->second);
        }
    }
}
int32_t sc_expedition_t::get_cur_round()
{
    return m_cur_round;
}
int32_t sc_expedition_t::get_max_round()
{
    if (m_is_pass_all_round)
        return EXPEDITION_END - EXPEDITION_BEGIN + 1;
    return m_cur_max_round - EXPEDITION_BEGIN;
}
int32_t sc_expedition_t::get_reset_num()
{
    if (m_is_refresh_today == 0) {
        return 1; // 免费1次+vip1次
    }
    auto anyone = m_expedition_hm.begin();
    if (anyone == m_expedition_hm.end()) {
        return 0; // 异常
    }
    if (anyone->second->refresh_type == 0) {
        return 1; // 免费1次 + vip 1次
    }
    if (anyone->second->refresh_type == 1) {
        return 1; // vip 1次
    }
    return 0;
}

void sc_expedition_t::add_hp(sp_fight_view_user_t view)
{
    // 远征对手的血量乘以150%
    for (auto it = view->roles.begin(); it != view->roles.end(); ++it)
    {
        it->second.pro[4] = it->second.pro[4] * 1.5;
    }

}
