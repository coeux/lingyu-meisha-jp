#include "sc_pub.h"
#include "sc_round.h"
#include "sc_new_round.h"
#include "sc_message.h"
#include "sc_push_def.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_mailinfo.h"
#include "repo_def.h"
#include "code_def.h"
#include "sc_statics.h"
#include "date_helper.h"
#include "random.h"
#include "msg_def.h"
#include "sc_server.h"
#include <sys/time.h>
#include <math.h>
#include <ctime>

#define LOG "SC_PUB"

#define FLUSH_TIME_1 600
#define FLUSH_TIME_2 86400
#define FLUSH_TIME_3 86400
#define FLUSH_TIME_FREE 0
#define WHITE 1
#define GREEN 2
#define BLUE 3
#define PURPLE 4
#define GOLD 5
#define MAIN_HERO 39999
#define MINUTE_10 600
#define MINUTE_FREE 0

sc_pub_ctl_t::sc_pub_ctl_t():yesterday_gold_chip(0),gold_chip(0),flush_tm(0)
{
    //生成各稀有度伙伴表
    auto it_par = repo_mgr.role.begin();
    while(it_par != repo_mgr.role.end() )
    {
        if (it_par->second.id > 100 and it_par->second.id <= 110)
        {
            ++it_par;
            continue;
        }
        if( it_par->second.rare < 1 || it_par->second.rare > 10 )
        {
            ++it_par;
            continue;
        }
        ps[it_par->second.rare].push_back(it_par->second.id);
        
        ++it_par;
    }

    //生成物品稀有度表
    auto it2_par = repo_mgr.item.begin();
    while(it2_par != repo_mgr.item.end() )
    {
        if( it2_par->second.rare < 10 )
        {
            ++it2_par;
            continue;
        }
        item[it2_par->second.rare].push_back(it2_par->second.id);
        
        ++it2_par;
    }

	//生成特殊卡包
	auto it3_par = repo_mgr.pub_special.begin();
    while(it3_par != repo_mgr.pub_special.end() )
    {
		auto it = special_pub_list.find(it3_par->second.type);
		if( it == special_pub_list.end() )
		{
			vector<pub_special_t> ps_t;
			special_pub_list.insert(make_pair(it3_par->second.type, ps_t));
			it = special_pub_list.find(it3_par->second.type);
		}
		auto it2 = special_pub_sum.find(it3_par->second.type);
		if( it2 == special_pub_sum.end() )
		{
			special_pub_sum.insert(make_pair(it3_par->second.type, 0));
			it2 = special_pub_sum.find(it3_par->second.type);
		}
		pub_special_t ps_t;
		ps_t.role_id = it3_par->second.role_id;
		ps_t.rate = it3_par->second.rate;
		it->second.push_back(ps_t);
		it2->second += it3_par->second.rate;
        ++it3_par;
    }

    //生成碎片映射表
    auto it_chip = repo_mgr.chip.begin();
    while( it_chip != repo_mgr.chip.end() )
    {
        chip_hm_t[ it_chip->second.actorid ] = it_chip->second.id;
        ++it_chip;
    }
}

void sc_pub_ctl_t::get_random_item(sp_user_t user_, int32_t flag_,int32_t &rare_,int32_t &chip_, int32_t &num_, bool is_free, int stepup_state_)
{
    int level = user_->db.grade;
    int sum = 10000;
    int extra = 1;
    if (flag_ == 7 || flag_ == 5)
    {
        if (3 == stepup_state_)
            extra = 2;
        else if (4 == stepup_state_)
            extra = 3;
        else if (5 == stepup_state_)
            extra = 6;
        
        if( extra > 1 )
        {
            auto it2 = repo_mgr.pub.begin();
            while( it2 != repo_mgr.pub.end() )
            {
                if( it2->second.level[1] > level || it2->second.level[2] < level )
                {
                    ++it2;
                    continue;
                }
                if( it2->second.rare >=6 && it2->second.rare <=8 )
                    sum += it2->second.pay_probability * (extra-1);
                ++it2;
            }
        }
    }
    
    int32_t r = random_t::rand_integer(1,sum);


    //找出是否出整卡，数量，rare数值    
    auto it = repo_mgr.pub.begin();
    while( it != repo_mgr.pub.end() )
    {
        if( it->second.level[1] > level || it->second.level[2] < level )
        {
            ++it;
            continue;
        }
        switch( flag_ )
        {
            case 1:
            {
                if( r<= it->second.lpay_probability )
                {
                    rare_ = it->second.rare;
                    if (rare_ == 5 && is_free)
                        rare_ = 2;
                    num_ = random_t::rand_integer( it->second.lpay_number[1], it->second.lpay_number[2] );
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.lpay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.lpay_probability;
            }
            break;
            case 2:
            {
                if( r<= it->second.lpay_probability )
                {
                    rare_ = it->second.rare;
                    num_ = random_t::rand_integer( it->second.lpay_number[1], it->second.lpay_number[2] );
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.lpay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.lpay_probability;
            }
            break;
            case 3:
            {
                if( r<= it->second.pay_probability )
                {
                    rare_ = it->second.rare;
                    if (rare_ == 5 && is_free)
                        rare_ = 2;
                    num_ = random_t::rand_integer( it->second.pay_number[1],it->second.pay_number[2] );
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.pay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.pay_probability;
            }
            break;
            case 4:
            {
                if( r<= it->second.pay_probability )
                {
                    rare_ = it->second.rare;
                    num_ = random_t::rand_integer( it->second.pay_number[1],it->second.pay_number[2] );
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.pay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.pay_probability;
            }
            break;
            case 5:
            {
                int extra_7 = 1;
                if( it->second.rare >=6 && it->second.rare <=8 )
                {
                    extra_7 = extra;
                }
                if( r<= it->second.pay_probability * extra_7)
                {
                    rare_ = it->second.rare;
                    num_ = random_t::rand_integer( it->second.pay_number[1],it->second.pay_number[2] );
                    
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.pay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.pay_probability*extra_7;
            }
            break;
            case 7:
            {
                int extra_7 = 1;
                if( it->second.rare >=6 && it->second.rare <=8 )
                {
                    extra_7 = extra;
                }
                if( r<= it->second.pay_probability * extra_7)
                {
                    rare_ = it->second.rare;
                    num_ = random_t::rand_integer( it->second.pay_number[1],it->second.pay_number[2] );
                    
                    int32_t r1 = random_t::rand_integer(1,10000);
                    if( r1 < it->second.pay_rate )
                        chip_ = 0;
                    else
                        chip_ = 1;

                    return;
                }
                r -= it->second.pay_probability*extra_7;
            }
            break;
        }

        ++it;
    }
    rare_ = chip_ = -1;
}

int32_t sc_pub_ctl_t::get_chip_resid(int32_t resid_)
{
    auto it = chip_hm_t.find(resid_);
    if( it == chip_hm_t.end() )
    {
        logerror((LOG,"get_chip_resid, repo no resid: %d!",resid_)); 
        return -1;
    }
    return it->second;
}

int32_t sc_pub_ctl_t::get_chip(sp_user_t user_,int32_t resid_,int32_t num_, sc_msg_def::ret_pub_flush_t &ret_,sc_msg_def::nt_chip_change_t &change_)
{
    sc_msg_def::jpk_pub_chip_t chip;
    chip.resid = resid_;
    chip.count = num_;
    chip.reduced = 0;
    //将碎片塞入背包
    user_->partner_mgr.add_new_chip(chip.resid,chip.count,change_);
    ret_.chips.push_back(chip);
    return SUCCESS;
}
int32_t sc_pub_ctl_t::get_hero(sp_user_t user_,int32_t resid_,int32_t potential_, sc_msg_def::ret_pub_flush_t &ret_,sc_msg_def::nt_chip_change_t &change_)
{
    sc_msg_def::jpk_pub_chip_t chip;
    //判断该玩家是否已经有该英雄
    if( user_->partner_mgr.has_hero(resid_%1000) )
    {
        chip.resid = resid_ - 10000;
        if( chip.resid <= 0 )
        {
            statics_ins.unicast_eventlog(*user_, 4046, chip.resid, 101);
            return ERROR_CHIP_ERROR;
        }

        chip.count = repo_mgr.configure.find(6+potential_)->second.value;
        chip.reduced = 1;

        //将碎片塞入背包
        user_->partner_mgr.add_new_chip(chip.resid,chip.count,change_);
    }
    else
    {
        chip.resid = resid_ % 1000;
        chip.count = 1;
        chip.reduced = 0;
        //雇佣英雄
        sp_partner_t sp_par = user_->partner_mgr.hire(resid_%1000, 1);
        if( sp_par == NULL )
        {
            statics_ins.unicast_eventlog(*user_, 4046, resid_, 102);
            return ERROR_NO_PARTNER;
        }
        sc_msg_def::jpk_role_data_t data;
        sp_par->get_partner_jpk(data);
        ret_.partners.push_back(std::move(data));
    }
    ret_.chips.push_back(chip);
    return SUCCESS;
}

void sc_pub_ctl_t::reset_gold_chip()
{
    if(date_helper.offday(flush_tm)>=1)
    {
        uint32_t r;
        int32_t new_resid = 0,round = 0;

        auto it = repo_mgr.gold_chip.find(1);
        if( it != repo_mgr.gold_chip.end() )
        {
            do
            {
                r = random_t::rand_integer(1,it->second.limited_hero_piece.size()-1);
                new_resid = it->second.limited_hero_piece[r];
                ++round;
            }while((round<100)||(new_resid==gold_chip)||(new_resid==yesterday_gold_chip));
        }

        yesterday_gold_chip = gold_chip;
        gold_chip = new_resid;
        flush_tm = date_helper.cur_sec();
    }
}
int32_t sc_pub_ctl_t::get_gold_chip_count()
{
    auto it = repo_mgr.gold_chip.find(1);
    if( it != repo_mgr.gold_chip.end() )
        return random_t::rand_integer(it->second.limited_hero_number[1],it->second.limited_hero_number[2]);
    return 1;
}
void sc_pub_ctl_t::set_flushtm(sp_user_t user_)
{
    //这个部分只有新手引导会用到

    /*int32_t cur_sec = date_helper.cur_sec();
    //往前提23小时 
    user_->db.set_ybflushtimes(cur_sec-23*3600) ;
    //往前提46个小时
    user_->db.set_kgflushtimes(cur_sec-46*3600) ;
    user_->save_db();
    */
}

uint32_t sc_pub_ctl_t::str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

void sc_pub_ctl_t::update_limit_draw_ten_reward(sp_user_t user_, int32_t num_, int32_t &is_in_activity, string &str)
{
    repo_def::lmt_event_t* rp = repo_mgr.lmt_event.get(2);
    is_in_activity = 0;
    if (NULL == rp) {
       logwarn((LOG, "load_db, lmt_event_time not exists"));
    }
    else
    {
        uint32_t lmt_event_begin = str2stamp(rp->start_time);
        uint32_t lmt_event_end = str2stamp(rp->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
        {
            if (num_ <= 0)
                return;
            is_in_activity = 1;
            user_->reward.db.set_limit_draw_ten(user_->reward.db.limit_draw_ten + num_);
            user_->reward.save_db();
            auto it_draw_reward = repo_mgr.lmt_reward.begin();
            while(it_draw_reward != repo_mgr.lmt_reward.end())
            {
                if (it_draw_reward->second.value == user_->reward.db.limit_draw_ten && it_draw_reward->second.id /100 == 2)
                {
                    //置位
                    if ((it_draw_reward->second.id - 200) > user_->reward.db.limit_draw_ten_reward.length())
                    {
                        user_->reward.db.limit_draw_ten_reward.append(1,'0');
                    }
                    if ( user_->reward.db.limit_draw_ten_reward[it_draw_reward->second.id - 200 - 1] == '0')
                    {
                        user_->reward.db.limit_draw_ten_reward[it_draw_reward->second.id - 200 - 1] = '1';
                        user_->reward.db.set_limit_draw_ten_reward(user_->reward.db.limit_draw_ten_reward);
                    } 
                    logerror((LOG, "limit draw ten diamond activity update: %d",user_->db.uid));
                    user_->reward.save_db();
                    break;
                }
                it_draw_reward++;
            } 
        }else
        {
            //如果不在活动时间内，则需要把奖励状态置成0，用来给下次做准备
            user_->reward.db.set_limit_draw_ten(0);
            if (user_->reward.db.limit_draw_ten_reward.length() > 1)
            {
                ystring_t<30> state;
                state.append(1,'0');
                user_->reward.db.set_limit_draw_ten_reward(state);
            }else if(user_->reward.db.limit_draw_ten_reward[0] != '0')
            {
                user_->reward.db.limit_draw_ten_reward[0] = '0';
                user_->reward.db.set_limit_draw_ten_reward(user_->reward.db.limit_draw_ten_reward);
            }
            user_->reward.save_db();
        }
        str = user_->reward.db.limit_draw_ten_reward();
    }
}

int32_t sc_pub_ctl_t::flush_pub(sp_user_t user_, int32_t uid_, int32_t flag_, int eid)
{
    int32_t c_id = 0;
    int draw_num = 0;
    int ten_diamond_num = 0;
    int jinbi_1 = repo_mgr.configure.find(1)->second.value;
    int jinbi_10 = repo_mgr.configure.find(2)->second.value;
    int zhizun_1 = repo_mgr.configure.find(3)->second.value;
    int zhizun_10 = repo_mgr.configure.find(4)->second.value;
    int shenmi_1 = repo_mgr.configure.find(5)->second.value;
    int shenmi_10 = repo_mgr.configure.find(6)->second.value;
    int stepup_rmb[5];
    for (int i=0;i<5;++i)
    {
        stepup_rmb[i] = repo_mgr.configure.find(49+i)->second.value;
    }

	// pub_4 price

    sc_msg_def::nt_chip_change_t change;

    sc_msg_def::ret_pub_flush_t ret;
    ret.flag = flag_;

    bool is_free = false;

    //注： 钻石抽卡逻辑修改 以后要重新加入log 新逻辑没走log 但通过了读表

    int32_t cur_sec = date_helper.cur_sec();
    switch( flag_ )
    {
        //普通抽1次
        case 1:
            {
                if (user_->db.flush1round <= 0)
                {
                    is_free = false;
                }
                else
                {
                    if (cur_sec - user_->db.flush1times >= get_flushtime(user_->db.viplevel))
                    {
                        is_free = true;
                    }
                    else
                    {
                        is_free = false;
                    }
                }
                //先看是否免费
                if( is_free)
                {
                    //免费刷新
                    ret.flush1times = user_->db.flush1round-1;
                    user_->db.set_flush1round(user_->db.flush1round-1);
                    user_->db.set_flush1times(cur_sec) ;
                    user_->save_db();


                    ret.left_flush_seconds = get_flushtime(user_->db.viplevel);
                    draw_num = 1;
                }
                else 
                {
                    ret.flush1times = user_->db.flush1round;
                    //检查卷轴
                    if( user_->item_mgr.has_items(10012, 1) )
                    {
                        sc_msg_def::nt_bag_change_t nt;
                        user_->item_mgr.consume(10012, 1, nt);
                        user_->item_mgr.on_bag_change(nt);
                    }
                    else if( user_->db.gold >= jinbi_1 )
                    {
                        user_->on_money_change( 0-jinbi_1 );
                        user_->save_db();
                    }
                    else
                    {
                        logerror((LOG,"flush_pub, not enough money: %d!",user_->db.gold)); 
                        return ERROR_SC_NO_GOLD;
                    }
                    c_id = 0;
                    draw_num = 1;
                    ret.left_flush_seconds = get_flushtime(user_->db.viplevel) - (cur_sec-user_->db.flush1times);
                }
            }
            break;
        //普通抽10次
        case 2:
            {
                //检查卷轴
                if( user_->item_mgr.has_items(10012, 10) )
                {
                    sc_msg_def::nt_bag_change_t nt;
                    user_->item_mgr.consume(10012, 10, nt);
                    user_->item_mgr.on_bag_change(nt);
                }
                else if( user_->db.gold >= jinbi_10 )
                {
                    user_->on_money_change( 0-jinbi_10);
                    user_->save_db();
                }
                else
                {
                    logerror((LOG,"flush_pub, not enough money: %d!",user_->db.gold)); 
                    return ERROR_SC_NO_GOLD;
                }
                c_id = 0;
                draw_num = 10;
                ret.flush1times = user_->db.flush1round;
                ret.left_flush_seconds = 0;
            }
            break;
        //至尊抽1次
        case 3:
            {
                if( cur_sec - user_->db.flush2times >= FLUSH_TIME_2)
                {
                    //免费刷新
                    user_->db.set_flush2times(cur_sec) ;
                    user_->save_db();
                    ret.left_flush_seconds = FLUSH_TIME_2;
                    draw_num = 1;
                    is_free = true;
                }
                else
                {
                    //检查卷轴
                    if( user_->item_mgr.has_items(10013, 1) )
                    {
                        sc_msg_def::nt_bag_change_t nt;
                        user_->item_mgr.consume(10013, 1, nt);
                        user_->item_mgr.on_bag_change(nt);
                    }
                    else if(user_->rmb() >= zhizun_1)
                    {
                        user_->consume_yb( zhizun_1);
                        user_->save_db();
                    }
                    else
                    {
                        logerror((LOG,"flush_pub, not enough yb: %d!",user_->rmb())); 
                        return ERROR_PUB_NO_YB;
                    }
                    ret.left_flush_seconds = FLUSH_TIME_2 - (cur_sec-user_->db.flush2times);
                    draw_num = 1;
                }
                c_id = 1;
                user_->reward.update_limit_pub_activity(1);
                ret.flush1times = user_->db.flush1round;
            }
            break;
        //至尊抽10次
        case 4:
            {
                //检查卷轴
                if( user_->item_mgr.has_items(10013, 10) )
                {
                    sc_msg_def::nt_bag_change_t nt;
                    user_->item_mgr.consume(10013, 10, nt);
                    user_->item_mgr.on_bag_change(nt);
                }
                else if(user_->rmb() >= zhizun_10)
                {
                    user_->consume_yb( zhizun_10);
                    //记录钻石十连的次数  只有在开服限定期限内才计算
                    ten_diamond_num = 1;

                    user_->save_db();
                }
                else
                {
                    logerror((LOG,"flush_pub, not enough yb: %d!",user_->rmb())); 
                    return ERROR_PUB_NO_YB;
                }
                c_id = 1;
                draw_num = 10;
                ret.left_flush_seconds = 0;
                ret.flush1times = user_->db.flush1round;

                user_->reward.update_limit_pub_activity(10);
            }
            break;
        //神秘抽1次
        case 5:
            {
                switch (user_->pub_mgr.get_event_state())
                {
                    case 1:
                        draw_num = 1;
                        break;
                    case 2:
                        draw_num = 2;
                        break;
                    case 3:
                        draw_num = 6;
                        break;
                    case 4:
                        draw_num = 7;
                        break;
                    case 5:
                        draw_num = 14;
                        break;
                    default:
                        draw_num = 0;
                        break;
                }
                int rmb_consume = stepup_rmb[user_->pub_mgr.get_event_state()-1];

                if(user_->rmb() >= rmb_consume)
                {
                    user_->consume_yb( rmb_consume);

                    user_->save_db();
                }
                else
                {
                    logerror((LOG,"flush_pub, not enough yb: %d!",user_->rmb())); 
                    return ERROR_PUB_NO_YB;
                }
            }
            break;
        // stepup pub
        case 7:
            {
                switch (user_->pub_mgr.get_stepup_state())
                {
                    case 1:
                        draw_num = 1;
                        break;
                    case 2:
                        draw_num = 2;
                        break;
                    case 3:
                        draw_num = 6;
                        break;
                    case 4:
                        draw_num = 7;
                        break;
                    case 5:
                        draw_num = 14;
                        break;
                    default:
                        draw_num = 0;
                        break;
                }
                int rmb_consume = stepup_rmb[user_->pub_mgr.get_stepup_state()-1];

                if(user_->rmb() >= rmb_consume)
                {
                    user_->consume_yb( rmb_consume);

                    user_->save_db();
                }
                else
                {
                    logerror((LOG,"flush_pub, not enough yb: %d!",user_->rmb())); 
                    return ERROR_PUB_NO_YB;
                }
            }
            break;
        default:
            return ERROR_SC_ILLEGLE_REQ;
    }
    
    ret.is_ten_diamond = 0;
    ret.draw_num = draw_num;
    ret.stepup_state = user_->pub_mgr.get_stepup_state();
    ret.event_state = user_->pub_mgr.get_event_state();
    user_->db.set_draw_num(user_->db.draw_num + draw_num);
    user_->save_db();
   
    //判断是否在活动期内 
    int32_t ctimestamp = user_->db.createtime;
    uint32_t activity_end_time_stamp = ctimestamp + 7*86400;
    if ( date_helper.cur_sec() <= activity_end_time_stamp && ten_diamond_num > 0)
    {
        ret.is_ten_diamond = 1;
        user_->db.set_draw_ten_diamond(user_->db.draw_ten_diamond + ten_diamond_num);
        user_->save_db();
        
        if ( date_helper.cur_sec() <= activity_end_time_stamp )
        {
            repo_def::newly_reward_t * rp_draw_reward = NULL;
            //已经记录的不再更新
            uint32_t  i = 301;
            if (user_->db.draw_reward.length() == 1 && user_->db.draw_reward[0] == '0')
                i = 301;
            else
                i = 300 + user_->db.draw_reward.length() + 1;
            for (; repo_mgr.newly_reward.get(i) != NULL; ++i)
            {
                rp_draw_reward = repo_mgr.newly_reward.get(i);
                if ( user_->db.draw_ten_diamond >= rp_draw_reward->value )
                {
                    if ((i - 300) > user_->db.draw_reward.length() && user_->db.draw_reward[i - 301] != '2')
                    {
                        user_->db.draw_reward.append(i - 300 - user_->db.draw_reward.length(),'1');
                    }
                    if (user_->db.draw_reward[i - 301] != '2')
                        user_->db.draw_reward[i - 301] = '1';
                    
                    user_->db.set_draw_reward(user_->db.draw_reward); 
                    user_->save_db();
                }
            }
        }
    }
    ret.draw_reward = user_->db.draw_reward();
    //限时钻石十连
    update_limit_draw_ten_reward(user_, ten_diamond_num, ret.is_in_limit_activity, ret.limit_draw_reward);
    user_->reward.daily_draw_num(ten_diamond_num);
	
    int32_t count = 1;
    if( (2==flag_) || (4==flag_) || (6==flag_) )
        count = 10;
    if( 7==flag_ || 5==flag_)
        count = draw_num;

	unordered_map<int32_t, bool> secret_door_list;
	secret_door_list.clear();
    // 首次钻石单抽奖励
    if( (3==flag_) && (user_->pub_mgr.is_pub_3_first()) )
	{
		secret_door_list.insert(make_pair(99, true));
		user_->pub_mgr.set_pub_3_first();
	}     
	// 首次钻石十连奖励
    else if( (4==flag_) && (user_->pub_mgr.is_pub_4_first()) )
	{
		secret_door_list.insert(make_pair(96, true));
		user_->pub_mgr.set_pub_4_first();
	}
	// 钻石十连保底
	else if( (4==flag_) && !(user_->pub_mgr.is_pub_4_first()) )
	{
		secret_door_list.insert(make_pair(97, true));
	}
	// 限时第五档保底
	else if( (7==flag_) && (user_->pub_mgr.get_stepup_state() == 5) )
	{
		secret_door_list.insert(make_pair(98, true));
	}
    else if( (5==flag_) && (user_->pub_mgr.get_event_state() == 5) )
    {
		secret_door_list.insert(make_pair(93, true));
    }
    ret.is_pub_4 = user_->pub_mgr.is_pub_4_first();	
    string pub_info;

    for( int j=1;j<=count;++j)
    {
        user_->daily_task.on_event(evt_pub_flash);
		bool is_secret = false;
		int32_t secret_num = 0;
		for(auto it = secret_door_list.begin(); it != secret_door_list.end(); ++it)
		{
			if (it->second)
			{
				is_secret = true;
				secret_num = it->first;
				break;
			}
		}
		if (is_secret)
		{
			secret_door_list.clear();
			auto it_sec_par = special_pub_list.find(secret_num);
			auto it_sec_sum = special_pub_sum.find(secret_num);
			if( it_sec_par == special_pub_list.end() || it_sec_sum == special_pub_sum.end() )
            {
                logerror((LOG,"flush_pub, not %d item!", secret_num)); 
                return ERROR_NO_ITEM;
            }
			if( it_sec_sum->second <= 1 )
			{
                logerror((LOG,"flush_pub, repo error, %d item!", secret_num)); 
                return ERROR_NO_ITEM;
            }
			int32_t r = random_t::rand_integer(1, it_sec_sum->second);
			int32_t resid = -1;
			for( auto it = it_sec_par->second.begin(); it != it_sec_par->second.end(); ++it)
			{
				if( r <= it->rate )
				{
					resid = it->role_id;
					break;
				}
				r -= it->rate;
			}
			if( resid == -1)
			{
                logerror((LOG,"flush_pub, repo reisd error, %d item! r = %d ", secret_num, r)); 
                return ERROR_NO_ITEM;
			}

            int32_t role_item_id = resid + 40000;
            int32_t potential = repo_mgr.item.find(role_item_id)->second.quality;
            int32_t res = get_hero(user_,role_item_id,potential,ret,change);
            if( res != SUCCESS )
            {
                return res;
            }
			stringstream ss;
			ss << secret_num;

            statics_ins.unicast_eventlog(*user_, eid, resid, 1, 0, flag_, ss.str());
            continue;
        }
        //随机英雄resid
        int32_t rare,chip,num;
        if (flag_ == 7)
            get_random_item(user_,flag_,rare,chip,num,is_free,user_->pub_mgr.get_stepup_state());
        else if (flag_ == 5)
            get_random_item(user_,flag_,rare,chip,num,is_free,user_->pub_mgr.get_event_state());
        else
            get_random_item(user_,flag_,rare,chip,num,is_free,1);
            

        //判断是否为物品
        if( rare >=1 and rare <=10 )
        {
            int32_t r = random_t::rand_integer(0,ps[rare].size()-1);
            int32_t resid = ps[rare][r];

            if( 0==chip )
            {
                int32_t role_item_id = get_chip_resid( resid ) + 10000;
                int32_t potential = repo_mgr.item.find(role_item_id)->second.quality;
                int32_t res = get_hero(user_,role_item_id,potential,ret,change);
                if( res != SUCCESS )
                {
                    return res;
                }
                pub_info = "";
                statics_ins.unicast_eventlog(*user_, eid, role_item_id, 1, 0, flag_, pub_info);
            }
            else
            {
                int32_t chip_resid = get_chip_resid( resid );
                if( chip_resid <= 0 )
                {
                    statics_ins.unicast_eventlog(*user_, 4046, chip_resid, 103);
                    return ERROR_CHIP_ERROR;
                }

                int32_t res = get_chip(user_,chip_resid,num,ret,change);
                if( res != SUCCESS )
                {
                    return res;
                }
                pub_info = "";
                statics_ins.unicast_eventlog(*user_, eid, chip_resid, num, 0, flag_, pub_info);
            }
        }
        else
        {
            int32_t r = random_t::rand_integer(0,item[rare].size()-1);
            int32_t resid = item[rare][r];

            //判断是否为主角碎片
            if( resid == MAIN_HERO)
            {
                //找出当前主角id
                int hero_id = user_->db.resid;
                if (hero_id < 100 or hero_id > 110)
                {
                    continue;
                }

                //生成主角碎片
                int chip_id = hero_id + 30000;
                
                int32_t res = get_chip(user_,chip_id,num,ret,change);
                if( res != SUCCESS )
                {
                    return res;
                }
                pub_info = "";
                statics_ins.unicast_eventlog(*user_, eid, chip_id, num, 0, flag_, pub_info);
            }
            else
            {
                sc_msg_def::jpk_item_t data;
                
                data.itid = 0;
                data.resid = resid;
                data.num = num;
                ret.items.push_back(std::move(data));
    
                sc_msg_def::nt_bag_change_t nt;
                user_->item_mgr.addnew(resid, num, nt);
                user_->item_mgr.on_bag_change(nt);
                pub_info = "";
                statics_ins.unicast_eventlog(*user_, eid, resid, num, 0, flag_, pub_info);
            }
        }
    }

    if( 3==flag_  || 4 == flag_ || 5 == flag_ || 7 == flag_)
		user_->pub_mgr.add_pub_sum(count);
    if( 7==flag_ )
    {
        if( user_->pub_mgr.get_stepup_state() == 1 )
        {
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = 10001;
            item_.num = 10000;
            nt.items.push_back(item_);
            sc_msg_def::jpk_item_t item2_;
            item2_.itid = 0;
            item2_.resid = 24001;
            item2_.num = 10;
            nt.items.push_back(item2_);

            string msg = mailinfo.new_mail(mail_pub_stepup);
            auto rp_gmail = mailinfo.get_repo(mail_pub_stepup);
            if (rp_gmail != NULL)
            {
                user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
            }
        }
        else if( user_->pub_mgr.get_stepup_state() == 2)
        {
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = 10001;
            item_.num = 20000;
            nt.items.push_back(item_);
            sc_msg_def::jpk_item_t item2_;
            item2_.itid = 0;
            item2_.resid = 24001;
            item2_.num = 20;
            nt.items.push_back(item2_);

            string msg = mailinfo.new_mail(mail_pub_stepup);
            auto rp_gmail = mailinfo.get_repo(mail_pub_stepup);
            if (rp_gmail != NULL)
            {
                user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
            }
        }
        user_->pub_mgr.add_stepup_state();
    }
    if( 5==flag_ )
    {
        if( user_->pub_mgr.get_event_state() == 1 )
        {
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = 10001;
            item_.num = 10000;
            nt.items.push_back(item_);
            sc_msg_def::jpk_item_t item2_;
            item2_.itid = 0;
            item2_.resid = 16001;
            item2_.num = 10;
            nt.items.push_back(item2_);

            string msg = mailinfo.new_mail(mail_pub_stepup);
            auto rp_gmail = mailinfo.get_repo(mail_pub_stepup);
            if (rp_gmail != NULL)
            {
                user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
            }
        }
        else if( user_->pub_mgr.get_event_state() == 2)
        {
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = 10001;
            item_.num = 20000;
            nt.items.push_back(item_);
            sc_msg_def::jpk_item_t item2_;
            item2_.itid = 0;
            item2_.resid = 16001;
            item2_.num = 20;
            nt.items.push_back(item2_);

            string msg = mailinfo.new_mail(mail_pub_stepup);
            auto rp_gmail = mailinfo.get_repo(mail_pub_stepup);
            if (rp_gmail != NULL)
            {
                user_->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
            }
        }
        user_->pub_mgr.add_event_state();
    }
    user_->save_db();
    user_->partner_mgr.on_chip_change(change);

    logic.unicast(uid_, ret);

    return SUCCESS;
}

void sc_pub_ctl_t::get_free_time(sp_user_t user_, int32_t uid_)
{
    sc_msg_def::ret_pub_time_t ret;

    int32_t cur_sec = date_helper.cur_sec();
    ret.left_sec1 = get_flushtime(user_->db.viplevel) - (cur_sec - user_->db.flush1times);
    ret.left_sec2 = FLUSH_TIME_2 - (cur_sec - user_->db.flush2times);
    ret.left_sec3 = FLUSH_TIME_3 - (cur_sec - user_->db.flush3times);

    logic.unicast(uid_, ret);
}

int32_t sc_pub_ctl_t::get_gold_chip()
{
    reset_gold_chip();
    return gold_chip;
}

void sc_pub_ctl_t::get_pub_data(sc_user_t &user_,sc_msg_def::jpk_pub_data_t &pub_)
{
    int32_t cur_sec = date_helper.cur_sec();

    pub_.left_sec1 = get_flushtime(user_.db.viplevel) - (cur_sec - user_.db.flush1times);
    pub_.round2 = user_.db.flush2round;
    pub_.left_sec2 = FLUSH_TIME_2 - (cur_sec - user_.db.flush2times);
    pub_.round3 = user_.db.flush3round;
    pub_.left_sec3 = FLUSH_TIME_3 - (cur_sec - user_.db.flush3times);
}

int32_t sc_pub_ctl_t::req_enter_modular(sp_user_t user_, sc_msg_def::ret_enter_pub_t& ret_)
{
    // check reset
    if (user_->db.flush1times < date_helper.cur_0_stmp())
    {
        user_->db.set_flush1times(date_helper.cur_0_stmp() - get_minite_time(user_->db.viplevel)) ;
        user_->db.set_flush1round(5);
        user_->save_db();
    }

    // return data
    ret_.flush1times = user_->db.flush1round;
    ret_.flush1lasttime = user_->db.flush1times;
    ret_.flush2lasttime = user_->db.flush2times;
    ret_.stepup_state = user_->pub_mgr.get_stepup_state();
    ret_.event_state = user_->pub_mgr.get_event_state();
    bool during_event_3 = false;
    repo_def::lmt_event_t* rp_lmt_event_3 = repo_mgr.lmt_event.get(21);
    if (rp_lmt_event_3 != NULL){ 
        uint32_t lmt_event_begin = str2stamp(rp_lmt_event_3->start_time);
        uint32_t lmt_event_end = str2stamp(rp_lmt_event_3->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
            during_event_3 = true;
    }
    bool during_event_4 = false;
    repo_def::lmt_event_t* rp_lmt_event_4 = repo_mgr.lmt_event.get(22);
    if (rp_lmt_event_4 != NULL){ 
        uint32_t lmt_event_begin = str2stamp(rp_lmt_event_4->start_time);
        uint32_t lmt_event_end = str2stamp(rp_lmt_event_4->end_time);
        if(date_helper.cur_sec() >= lmt_event_begin && date_helper.cur_sec() <= lmt_event_end)
            during_event_4 = true;
    }
    ret_.flush3flag = during_event_3;
    ret_.flush4flag = during_event_4;
    return SUCCESS;
}

int32_t sc_pub_ctl_t::get_flushtime(int32_t viplevel_)
{
    int32_t flushtime = FLUSH_TIME_FREE;
    if(viplevel_ < 10)
        flushtime = FLUSH_TIME_1;

    return flushtime;
}

int32_t sc_pub_ctl_t::get_minite_time(int32_t viplevel_)
{
    int32_t minitetime = MINUTE_FREE;
    if(viplevel_ < 10)
        minitetime = MINUTE_10;

    return minitetime;
}
