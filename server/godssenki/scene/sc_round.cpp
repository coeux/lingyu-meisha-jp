#include "sc_round.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_cache.h"
#include "sc_friend.h"
#include "sc_guidence.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "date_helper.h"
#include <sys/time.h>

#define LOG "SC_ROUND"
#define POW(flag) ((flag==1)?10:5)
#define COST_ONE_HOUR_HALT 5
#define SECONDS_PER_HALT 300
#define MIN(a,b) ((a)<(b)?(a):(b))

#define MAX_HELP 50
#define FPOINT_HELPER 100
#define FPOINT_HELPEE 20
#define FPOINT_STRANGER 50
#define FPOINT_STRANGEE 10

#define MAX_DROP_RMB 50
#define DROP_RMB 10

sc_round_t::sc_round_t(sc_user_t &user_):
    m_user(user_),
    m_cur_rid(0),
    m_cur_flag(0),
    m_cur_uid(0),
    m_cur_pid(0),
    m_in_stamp(0),
    m_halt_times(0),
    m_halt_sent(0),
    m_halt_flag(-1),
    m_halt_gid(0),
    m_limit_round(0),
    m_limit_cooldown(0)
{
}

//resid_ 关卡resid
//flag_ 关卡类型  
//0 普通关卡  
//1 精英关卡，resid同普通关卡，需要加上1000  
//2 黄道十二宫
//uid_ pid_ 助战英雄
int32_t sc_round_t::enter_round(int32_t resid_,int32_t flag_,int32_t uid_,int32_t pid_)
{
    clear_state();
    round_ctl.reset(m_user.db.uid);
    //判断关卡id是否有效
    repo_def::round_t *p_r = NULL;
    if( flag_ == 1)
        p_r = repo_mgr.round.get(resid_+1000);
    else
        p_r = repo_mgr.round.get(resid_);

    if (p_r == NULL)
    {
        logerror((LOG, "enter_round, repo no round, resid:%d", resid_));

        sc_msg_def::ret_begin_round_failed_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_SC_ILLEGLE_REQ;
    }

    //如果是精英关卡或者黄道十二宫，判断是否还有剩余次数
    if( flag_ > 0 )
    {
        //取得该精英关卡所属的组id
        int32_t gid;
        if( 2==flag_ )
            gid = 300;
        else
        {
            auto it_rg = repo_mgr.rid2gid.find(resid_);
            if( it_rg == repo_mgr.rid2gid.end() )
            {
                logerror((LOG, "enter_round, repo no rid to gid, resid:%d", resid_));

                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_SC_EXCEPTION;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_SC_EXCEPTION;
            }
            gid = it_rg->second;
        }

        auto it_hm = round_ctl.m_round_hm.find(m_user.db.uid);
        if( it_hm != round_ctl.m_round_hm.end() )
        {
            auto it_m = (it_hm->second).find(gid);
            if( it_m != (it_hm->second).end() )
            {
                if( (it_m->second).count(resid_) )
                {
                    //没有进入次数，返回
                    logerror((LOG, "enter_round, round no permit, resid:%d", resid_));
                    sc_msg_def::ret_begin_round_failed_t ret;
                    ret.code = ERROR_ROUND_NO_PERMIT;
                    logic.unicast(m_user.db.uid, ret);
                    return ERROR_ROUND_NO_PERMIT;
                }
            }
        }
    }

    //判断进入关卡的条件
    if( 2 == flag_ )
    {
        //获取黄道十二宫关卡id所属的组
        auto it_rg = repo_mgr.rid2gid.find(resid_);
        if( it_rg == repo_mgr.rid2gid.end() )
        {
            logerror((LOG, "enter_round,round no group,resid: %d", resid_));
            sc_msg_def::ret_begin_round_failed_t ret;
            ret.code = ERROR_SC_EXCEPTION;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_EXCEPTION;
        }
        int32_t gid = it_rg->second;

        //获取当前打过的最高黄道十二宫关卡
        int32_t max_round = -1;
        auto it_hm = round_ctl.m_zodiac_hm.find(m_user.db.uid);
        if( it_hm != round_ctl.m_zodiac_hm.end() )
        {
            auto it_m = (it_hm->second).find(gid);
            if( it_m != (it_hm->second).end() )
                max_round = it_m->second;
        }

        if( -1 == max_round )
        {
            repo_def::round_group_t *p_rg = repo_mgr.roundgroup.get(gid);
            if( p_rg == NULL )
            {
                logerror((LOG, "enter_round, repo no roundgroup gid:%d", gid));
                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_SC_EXCEPTION;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_SC_EXCEPTION;
            }
            int32_t min = p_rg->get_min_round();

            max_round = min-1;
        }

        if( ((max_round+1) < resid_) || (m_user.db.grade < p_r->level) )
        {
            //进入条件不满足
            logerror((LOG, "enter_round, round no permit, resid:%d, max_round:%d,grade:%d, round_level:%d ", resid_,max_round,m_user.db.grade,p_r->level));
            sc_msg_def::ret_begin_round_failed_t ret;
            ret.code = ERROR_ROUND_NO_PERMIT;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_ROUND_NO_PERMIT;
        }
    }
    if( 0 == flag_ )
    {
        if( 0 == m_user.db.roundid )
        {
            if( resid_ != 1001 )
            {
                //进入条件不满足
                logerror((LOG, "enter_round, round no permit, resid:%d", resid_));
                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_ROUND_NO_PERMIT;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_ROUND_NO_PERMIT;
            }
        }
        else
        {
            if( ((m_user.db.roundid+1)<resid_) || (m_user.db.questid<p_r->pre_quest))
            {
                //进入条件不满足
                logerror((LOG, "enter_round, round no permit, resid:%d", resid_));
                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_ROUND_NO_PERMIT;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_ROUND_NO_PERMIT;
            }
        }
    }
    if( 1 == flag_ )
    {
        if( 0==m_user.db.eliteid )
        {
            if( (resid_ != 1005) || (m_user.db.roundid<1005) )
            {
                //进入条件不满足
                logerror((LOG, "enter_round, round no permit, resid:%d", resid_));
                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_ROUND_NO_PERMIT;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_ROUND_NO_PERMIT;
            }
        }
        else
        {
            if( ((m_user.db.eliteid+5)<resid_) || (m_user.db.roundid<resid_) )
            {
                //进入条件不满足
                logerror((LOG, "enter_round, round no permit, resid:%d", resid_));
                sc_msg_def::ret_begin_round_failed_t ret;
                ret.code = ERROR_ROUND_NO_PERMIT;
                logic.unicast(m_user.db.uid, ret);
                return ERROR_ROUND_NO_PERMIT;
            }
        }
    }

    //助战英雄
    m_ret.hhero.resid = 0;
    if( ((0==flag_)||(2==flag_))&&(uid_!=0) )
    {
        //该玩家是否有资格助战
        /*
        if( helphero_cache.is_helped(m_user.db.uid,uid_) )
        {
            sc_msg_def::ret_begin_round_failed_t ret;
            ret.code = ERROR_SC_ROUND_HELPED;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_ROUND_HELPED;
        }
        */
        //获取助战英雄相关数据
        sp_view_user_t sp_view = view_cache.get_view(uid_, true);
        if (sp_view != NULL)
        {
            for( auto it=sp_view->roles.begin();it!=sp_view->roles.end();++it)
            {
                if( it->second.pid == pid_ )
                {
                    m_ret.hhero =  it->second;
                    break;
                }
            }
        }
    }

    //判断体力是否足够
    int pow = POW(flag_);
    if( m_user.db.power<pow)
    {
        logerror((LOG, "enter_round, round no power, resid:%d", resid_));
        sc_msg_def::ret_begin_round_failed_t ret;
        ret.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_NO_POWER;
    }
    else
    {
        if( 1==flag_ )
            m_cur_rid = resid_+1000;
        else
            m_cur_rid = resid_;

        m_cur_flag = flag_;
        m_cur_uid = uid_;
        m_cur_pid = pid_;

        //返回关卡开始
        m_ret.resid = p_r->id;
        m_ret.code = SUCCESS;
        m_ret.rmb = gen_rmb();
        m_ret.exp = p_r->exp;
        m_ret.coin = p_r->coin;

        if( (1==m_cur_flag) && (m_user.db.isnew < evt_guidence_elite2) )
            guidence_ins.gen_elite_drop(m_user,m_ret.drop_items);
        else
            gen_drop_items_i(m_ret.drop_items);

        logic.unicast(m_user.db.uid, m_ret);

        return SUCCESS;
    }
}

void sc_round_t::clear_state()
{
    m_cur_rid = 0;
    m_cur_flag = 0;
    m_cur_uid = 0;
    m_cur_pid = 0;

    m_ret.exp = 0;
    m_ret.coin= 0;
    m_ret.rmb= 0;
    m_ret.hhero.resid = 0;
    m_ret.drop_items.clear();
}

int32_t sc_round_t::exit_round( int32_t resid_, bool batt_win_, int32_t stars_, vector<sc_msg_def::jpk_round_monster_t>& killed_)
{
    //判断玩家当前是否在关卡战斗中
    if( !m_cur_rid || m_cur_rid != resid_ )
    {
        logerror((LOG, "exit_round, cur_rid:%d, error resid:%d, win:%d", m_cur_rid, resid_, batt_win_));

        clear_state();

        //通知客户端战斗结束
        sc_msg_def::nt_end_round_t nte;
        nte.resid = resid_;
        nte.win = batt_win_;
        nte.stars = stars_;
        logic.unicast(m_user.db.uid, nte);

        return -1;
    }

    if (m_cur_flag == 1)
    {
        resid_ -= 1000;
    }

    if( batt_win_ && m_user.db.power >= POW(m_cur_flag))
    {
        //====================================
        //保存用户
        //保存经验
        //保存等级
        //如果升级则更新角色属性
        //通知经验和等级改变
        //通知角色属性改变
        switch( m_cur_flag )
        {
            case 0:
                {
                    if( m_user.db.roundid < resid_ )
                        m_user.db.set_roundid(resid_);

                }
                break;
            case 1:
                {
                    if( m_user.db.eliteid < (resid_+1000) )
                        m_user.db.set_eliteid(resid_+1000);
                }

                break;
            case 2:
                {
                    if( m_user.db.zodiacid < resid_ )
                        m_user.db.set_zodiacid(resid_);
                }
        }
        m_user.on_money_change(m_ret.coin);
        m_user.on_freeyb_change(m_ret.rmb);
        m_user.on_exp_change(m_ret.exp);
        //扣去体力 
        int pow = POW(m_cur_flag);
        m_user.on_power_change(-pow);

        //结算助战英雄
        if( ((0==m_cur_flag)||(2==m_cur_flag)) && (m_cur_uid!=0) )
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

        //保存关卡评定等级
        if (m_cur_flag == 0)
        {
            int off = resid_-1001-m_user.db.roundstars.length()+1; 
            if (off > 0)
            {
                m_user.db.roundstars.append(off, '0');
            }
            m_user.db.roundstars[resid_-1001] = (char)('0'+stars_); 
            m_user.db.set_roundstars(m_user.db.roundstars);
        }
        m_user.save_db();

        //====================================
        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<m_ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = m_ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }

        //新手引导相关
        if( 1==m_cur_flag )
        {
            //偷偷塞点东西给玩家，便于升阶教学，恶心
            if( m_user.db.isnew == (evt_guidence_elite1-1) )
            {
                m_user.item_mgr.addnew(11021,10,nt);
                m_user.item_mgr.addnew(11023,6,nt);
                m_user.item_mgr.addnew(11024,10,nt);
                m_user.item_mgr.addnew(11025,10,nt);
                m_user.item_mgr.addnew(11026,20,nt);
                guidence_ins.on_guidence_event(m_user,evt_guidence_elite1);
            }
            if( m_user.db.isnew == (evt_guidence_elite2-1) )
                guidence_ins.on_guidence_event(m_user,evt_guidence_elite2);
        }

        m_user.item_mgr.on_bag_change(nt);

        //如果是精英关卡，减去进入次数
        //首先取得该精英关卡所属的组id
        if( m_cur_flag > 0 )
        {
            int32_t gid;
            if( 2==m_cur_flag )
                gid = 300;
            else
            {
                auto it_rg = repo_mgr.rid2gid.find(resid_);
                if( it_rg == repo_mgr.rid2gid.end() )
                {
                    logerror((LOG, "exit_round, repo rid2gid no round, resid:%d", resid_));
                    clear_state();
                    return ERROR_SC_EXCEPTION;
                }
                gid = it_rg->second;
            }

            //然后减去进入次数
            auto it_hm = round_ctl.m_round_hm.find(m_user.db.uid);
            if( it_hm != round_ctl.m_round_hm.end() )
            {
                auto it_v = (it_hm->second).find(gid);
                if( it_v == (it_hm->second).end() )
                {
                    set<int32_t> rounds;
                    rounds.insert(resid_);
                    (it_hm->second).insert(make_pair(gid,std::move(rounds) ));
                }
                else
                {
                    (it_v->second).insert(resid_);
                }
            }
            else
            {
                set<int32_t> rounds;
                rounds.insert(resid_);

                map<int32_t,set<int32_t> > gid_rounds;
                gid_rounds.insert( make_pair(gid,std::move(rounds)) );

                round_ctl.m_round_hm.insert( make_pair(m_user.db.uid,gid_rounds) );
            }
        }

        if( 2 == m_cur_flag )
        {
            //如果是黄道十二宫关卡，更新内存结构

            //获取黄道十二宫关卡id所属的组
            auto it_rg = repo_mgr.rid2gid.find(resid_);
            if( it_rg == repo_mgr.rid2gid.end() )
            {
                logerror((LOG, "exit_round, repo no rid to gid, resid:%d, m_cur_flag:%d", resid_,m_cur_flag));
                clear_state();
                return ERROR_SC_EXCEPTION;
            }

            int32_t gid = it_rg->second;
            
            //获取当前打过的最高黄道十二宫关卡
            auto it_hm = round_ctl.m_zodiac_hm.find(m_user.db.uid);
            if( it_hm != round_ctl.m_zodiac_hm.end() )
            {
                auto it_m = (it_hm->second).find(gid);
                if( it_m != (it_hm->second).end() )
                {
                    if( it_m->second < resid_ )
                        it_m->second = resid_;
                }
                else
                {
                    (it_hm->second).insert( make_pair(gid, resid_) );
                }
            }
            else
            {
                map<int32_t, int32_t> m;
                m.insert( make_pair(gid,resid_) );
                round_ctl.m_zodiac_hm.insert( make_pair(m_user.db.uid,m) );
            }
        }
    }

    //通知客户端战斗结束
    sc_msg_def::nt_end_round_t nte;
    nte.resid = resid_;
    nte.win = batt_win_;
    nte.stars = stars_;
    logic.unicast(m_user.db.uid, nte);

    if (batt_win_)
    {
        m_user.task.on_round_pass(resid_);
        m_user.love_task.on_round_pass(resid_);

        if( resid_/1000 == 1)
            m_user.daily_task.on_event(evt_round_pass);

        if( resid_/1000 == 3)
            m_user.daily_task.on_event(evt_pass_zodiac);
    }

    for(size_t i=0; i<killed_.size(); i++)
    {
        m_user.task.on_monsert_killed(killed_[i].resid, killed_[i].num);
        m_user.love_task.on_monster_killed(killed_[i].resid, killed_[i].num);
    }

    clear_state();
    return SUCCESS;
}

void sc_round_t::gen_drop_items_i(vector<sc_msg_def::jpk_item_t>& drop_items_)
{
    m_ret.drop_items.clear();
    gen_drop_items(m_cur_rid, m_cur_flag, drop_items_);
}

void sc_round_t::gen_drop_items(int rid_, int rflag_, vector<sc_msg_def::jpk_item_t>& drop_items_)
{
    repo_def::round_t *p_r = repo_mgr.round.get(rid_);
    if( NULL == p_r )
    {
        logerror((LOG, "gen_drop_items, no roundid, %d,%d", rid_,rflag_));
        return;
    }
    if (rflag_==0 && p_r->item_drop.size()<=1)
    {
        logerror((LOG, "gen_drop_items, round:%d no item_drop", p_r->id));
        return;
    }
    if (rflag_==1 && p_r->darwing_drop.size()<=1)
    {
        logerror((LOG, "gen_drop_items, round:%d no darwing_drop", p_r->id));
        return;
    }
    if (rflag_==2 && p_r->zodiac_drop==0)
    {
        logerror((LOG, "gen_drop_items, round:%d no zodiac_drop", p_r->id));
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
            ditem.num = 1;
            drop_items_.push_back(std::move(ditem));
        }
    }

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

        uint32_t r = random_t::rand_integer(1, 10000);
        //logwarn((LOG, "gen_drop_items, r:%u, drop:%d, resid:%d ", r, drop[1], drop[0]));

        if (r > (uint32_t)drop[1])
            continue;

        int32_t n = random_t::rand_integer(1, drop[2]);

        ditem.itid = 0;
        ditem.resid = drop[0];
        ditem.num = n;
        drop_items_.push_back(std::move(ditem));
    }

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
/*
int32_t sc_round_t::gen_array2_resid(vector<vector<int32_t>> &drop_)
{
    uint32_t sum=0,r = random_t::rand_integer(1, 10000);
    for(size_t i=1; i<drop_.size(); i++)
    {
        vector<int32_t> &drop = drop_[i];
        if (drop.size() != 2)
        {
            logerror((LOG, "gen_array2_resid,zodiac drop size error!"));
            return 0;
        }
        sum += drop[1];
        if( r <= sum )
            return drop[0];
    }
    return 0;
}
*/
int32_t sc_round_t::gen_array2_resid(vector<vector<int32_t>> &drop_)
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

int sc_round_t::gen_rmb()
{
//    round_ctl.reset();
    auto it_hm = round_ctl.m_rmb_hm.find(m_user.db.uid);
    if( it_hm == round_ctl.m_rmb_hm.end() )
        it_hm=round_ctl.m_rmb_hm.insert(make_pair(m_user.db.uid, 0)).first;

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

int32_t sc_round_t::flush_round(int32_t gid_)
{
    //验证该组id是否有效
    if( (gid_/100==3)&&(gid_!=300) )
    {
        logerror((LOG, "flush_round, ERROR_SC_EXCEPTION,%d", gid_));
        sc_msg_def::ret_flush_round_t ret;
        ret.code = ERROR_SC_EXCEPTION;
        ret.gid = gid_;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }
    if( gid_ != 300 )
    {
        auto it_g=repo_mgr.roundgroup.find(gid_);
        if( it_g == repo_mgr.roundgroup.end() )
        {
            logerror((LOG, "flush_round, ERROR_SC_NO_RD_GP,%d", gid_));
            sc_msg_def::ret_flush_round_t ret;
            ret.code = ERROR_SC_EXCEPTION;
            ret.gid = gid_;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_EXCEPTION;
        }
    }

    int32_t code = 0;
    if( gid_>200 && gid_<300 )
    {
        //精英关卡
        code = m_user.vip.buy_vip(vop_reste_adv_round);
    }
    if( 300==gid_ )
    {
        //黄道十二宫
        code = m_user.vip.buy_vip(vop_reset_zodiac);
    }
    if (code != SUCCESS)
    {
        sc_msg_def::ret_flush_round_t ret;
        ret.code = code;
        ret.gid = gid_;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_EXCEPTION;
    }

    //清空已打关卡集合
    auto it_hm = round_ctl.m_round_hm.find(m_user.db.uid);
    if( it_hm != round_ctl.m_round_hm.end() )
    {
        auto it_m = (it_hm->second).find(gid_);
        if( it_m != (it_hm->second).end() )
            (it_m->second).clear();
    }
    //清空十二宫最高关卡
    if( 300==gid_ )
    {
        auto it_z = round_ctl.m_zodiac_hm.find(m_user.db.uid);
        if( it_z != round_ctl.m_zodiac_hm.end() )
            (it_z->second).clear();
    }

    sc_msg_def::ret_flush_round_t ret;
    ret.code = SUCCESS;
    ret.gid = gid_;
    logic.unicast(m_user.db.uid, ret);

    return SUCCESS;
}

int32_t sc_round_t::start_halt(int32_t resid_, int32_t times_)
{
    clear_state();
    if(times_<1)
    {
        logerror((LOG, "start_halt, times minus, times:%d", times_));

        sc_msg_def::ret_begin_auto_round_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_SC_ILLEGLE_REQ;
    }

    //判断关卡id是否有效
    repo_def::round_t *p_r = repo_mgr.round.get(resid_);
    if( p_r == NULL )
    {
        logerror((LOG, "start_halt, repo no round, resid:%d", resid_));

        sc_msg_def::ret_begin_auto_round_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_SC_ILLEGLE_REQ;
    }

    //判断该玩家当前状态
    if( m_in_stamp || m_cur_rid )
    {
        logerror((LOG, "start_halt, current in halt or round, resid:%d, m_in_stamp:%d, m_cur_rid:%d", resid_,m_in_stamp,m_cur_rid));

        sc_msg_def::ret_begin_auto_round_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_SC_ILLEGLE_REQ;
    }
    
    //判断关卡是否是普通关卡
    if( m_cur_rid>=2000 )
    {
        logerror((LOG, "start_halt, illegal resid, resid:%d", resid_));

        sc_msg_def::ret_begin_auto_round_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_SC_ILLEGLE_REQ;
    }

    //判断进入关卡的条件
    if( (m_user.db.roundid>=resid_)&&(m_user.db.questid>=p_r->pre_quest) )
    {
        //判断体力是否足够
        int pow = POW(0);
        if( m_user.db.power<pow*times_ )
        {
            logerror((LOG, "start_halt, no power, resid:%d, power:%d, times:%d", resid_, pow, times_));
            sc_msg_def::ret_begin_auto_round_t ret;
            ret.code = ERROR_SC_NO_POWER;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_NO_POWER;
        }
        else
        {
            struct timeval tm;
            gettimeofday(&tm, NULL);
            m_in_stamp = tm.tv_sec;
            m_cur_rid = resid_;
            m_halt_times = times_;
            m_halt_sent = 0;
            m_halt_flag = 0;

            store_halt_info();
            
            //返回关卡开始
            sc_msg_def::ret_begin_auto_round_t ret;
            ret.code = SUCCESS;
            logic.unicast(m_user.db.uid, ret);

            return SUCCESS;
        }
    }

    logerror((LOG, "start_halt, no permit, resid:%d", resid_));
    sc_msg_def::ret_begin_auto_round_t ret;
    ret.code = ERROR_SC_ILLEGLE_REQ;
    logic.unicast(m_user.db.uid, ret);

    return ERROR_SC_ILLEGLE_REQ;
}

int32_t sc_round_t::start_zodiac_halt(int32_t gid_)
{
    clear_state();
    sc_msg_def::ret_begin_auto_zodiac_t ret;
    ret.gid = gid_;

    //判断十二宫组id是否存在
    auto it = repo_mgr.roundgroup.find(gid_);
    if( it == repo_mgr.roundgroup.end() )
    {
        logerror((LOG, "start_zodiac_halt, bad gid:%d", gid_));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    //判断该玩家是否有资格挂机
    int32_t max_zodiac_id = it->second.get_max_round();
    if( m_user.db.zodiacid < max_zodiac_id )
    {
        logerror((LOG, "start_zodiac_halt, no quality:%d,%d", max_zodiac_id,m_user.db.zodiacid));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    //判断该玩家当前状态
    if( m_in_stamp || m_cur_rid )
    {
        logerror((LOG, "start_zodiac_halt, current in round:%d,%d", m_in_stamp,m_cur_rid));
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    //根据体力判断该玩家的挂机次数
    uint32_t n_power = m_user.db.power/POW(0);
    if( !n_power )
    {
        ret.code = ERROR_SC_NO_POWER;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_NO_POWER;
    }

    //生成该宫未打关卡列表
    vector<int32_t> rounds;
    round_ctl.get_raw_zodiac(m_user.db.uid,gid_,rounds);

    struct timeval tm;
    gettimeofday(&tm, NULL);
    m_in_stamp = tm.tv_sec;
    m_cur_flag = 2;
    m_halt_gid = gid_;
    m_halt_flag = 2;
//    m_halt_times = MIN(rounds.size(),n_power);

    if( rounds.size() < n_power )
        m_halt_times = rounds.size();
    else
        m_halt_times = n_power;

    store_halt_info();

    //返回关卡开始
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}


int32_t sc_round_t::get_zodiac_halt_result(int32_t gid_, int32_t flag_)
{
    //判断玩家当前是否在挂机中
    if( !m_in_stamp || m_halt_gid != gid_)
    {
        sc_msg_def::ret_auto_zodiac_resu_failed_t ret;
        ret.code = ERROR_ROUND_NO_HALT;
        ret.gid = gid_;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_ROUND_NO_HALT;
    }

    //生成该宫未打关卡列表
    vector<int32_t> rounds;
    round_ctl.get_raw_zodiac(m_user.db.uid,gid_,rounds);

    int32_t n_halt = m_halt_times;
    if(flag_)
    {

        uint32_t cd = (n_halt-1)*SECONDS_PER_HALT/3600 + 1;
        int32_t code = m_user.vip.buy_vip(vop_buy_halt_time, cd);

        if (code != SUCCESS)
        {
            sc_msg_def::ret_auto_zodiac_resu_failed_t ret;
            ret.code = code;
            ret.gid = gid_;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_NO_YB;
        }
    }
    else
    {
        //计算挂机次数
        struct timeval tm;
        gettimeofday(&tm, NULL);
        int32_t delt = tm.tv_sec-m_in_stamp;
        int32_t n_delt = delt/SECONDS_PER_HALT;
        if( n_delt < n_halt  )
            n_halt = n_delt;

        if( 0 == n_halt )
        {
            sc_msg_def::ret_auto_zodiac_resu_failed_t ret;
            ret.code = ERROR_SC_NOT_ENOUGH_TIME;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_NOT_ENOUGH_TIME;
        }
    }

    int exp = 0;
    int coin = 0;
    int rmb = 0;

    for(int i = 0;i<n_halt;++i)
    {
        repo_def::round_t *p_r = repo_mgr.round.get( rounds[i] );
        if( NULL == p_r )
        {
            logerror((LOG, "get_zodiac_halt_result, no resid:%d", rounds[i]));
            sc_msg_def::ret_auto_zodiac_resu_failed_t ret;
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return ERROR_SC_ILLEGLE_REQ;
        }
        //生成掉落
        m_cur_rid = rounds[i];
        sc_msg_def::ret_auto_zodiac_resu_t ret;
        ret.resid = rounds[i];
        exp += ret.exp = p_r->exp;
        coin += ret.coin = p_r->coin;
        rmb += ret.rmb = gen_rmb();

        gen_drop_items_i(ret.drop_items);
        logic.unicast(m_user.db.uid, ret);

        //日常任务，完成一次十二宫战斗
        m_user.daily_task.on_event(evt_pass_zodiac);

        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        m_user.item_mgr.on_bag_change(nt);

        //更新当前打过的最高十二宫关卡
        int32_t resid_ = rounds[i];
        auto it_hm = round_ctl.m_zodiac_hm.find(m_user.db.uid);
        if( it_hm != round_ctl.m_zodiac_hm.end() )
        {
            auto it_m = (it_hm->second).find(gid_);
            if( it_m != (it_hm->second).end() )
            {
                if( it_m->second < resid_ )
                    it_m->second = resid_;
            }
            else
            {
                (it_hm->second).insert( make_pair(gid_, resid_) );
            }
        }
        else
        {
            map<int32_t, int32_t> m;
            m.insert( make_pair(gid_,resid_) );
            round_ctl.m_zodiac_hm.insert( make_pair(m_user.db.uid,m) );
        }
        //然后减去进入次数
        auto it_hms = round_ctl.m_round_hm.find(m_user.db.uid);
        if( it_hms != round_ctl.m_round_hm.end() )
        {
            auto it_vs = (it_hms->second).find(300);
            if( it_vs == (it_hms->second).end() )
            {
                set<int32_t> rounds;
                rounds.insert(resid_);
                (it_hms->second).insert(make_pair( gid_,std::move(rounds) ));
            }
            else
            {
                (it_vs->second).insert(resid_);
            }
        }
        else
        {
            set<int32_t> rounds;
            rounds.insert(resid_);

            map<int32_t, set<int32_t> > gid_rounds;
            gid_rounds.insert( make_pair( 300, std::move(rounds) ) );

            round_ctl.m_round_hm.insert( make_pair(m_user.db.uid, std::move(gid_rounds)) );
        }
    }

    //====================================
    //保存用户
    //保存经验
    //保存等级
    //如果升级则更新角色属性
    //通知经验和等级改变
    //通知角色属性改变
    m_user.on_money_change(coin);
    m_user.on_freeyb_change(rmb);
    m_user.on_exp_change(exp);
    m_user.on_power_change(-POW(0)*n_halt);
    m_user.save_db();

    //====================================
    //保存伙伴
    if( m_halt_times-n_halt )
    {
        m_in_stamp += n_halt * SECONDS_PER_HALT;
        m_halt_times-=n_halt;
    }
    else
    {
        m_in_stamp = 0;
        m_cur_rid = 0;
        m_halt_sent = 0;
        m_halt_times = 0;
        m_halt_flag = -1;
        m_halt_gid = 0;
    }
    store_halt_info();

    return SUCCESS;
}

int32_t sc_round_t::get_halt_result(int32_t resid_, int32_t flag_)
{
    //判断玩家当前是否在挂机中
    if( !m_in_stamp || m_cur_rid != resid_)
    {
        logerror((LOG, "start_halt, no halt, resid:%d", resid_));
        sc_msg_def::ret_auto_round_resu_failed_t ret;
        ret.code = ERROR_ROUND_NO_HALT;
        logic.unicast(m_user.db.uid, ret);

        return ERROR_ROUND_NO_HALT;
    }

    int32_t n_halt;
    if(flag_)
    {
        uint32_t cd = (m_halt_times-1)*SECONDS_PER_HALT/3600 + 1;
        int32_t code = m_user.vip.buy_vip(vop_buy_halt_time, cd);

        if (code != SUCCESS)
        {
            sc_msg_def::ret_auto_round_resu_failed_t ret;
            ret.code = code;
            logic.unicast(m_user.db.uid, ret);

            return ERROR_SC_NO_YB;
        }

        n_halt = m_halt_times;
    }
    else
    {
        //计算挂机次数
        struct timeval tm;
        gettimeofday(&tm, NULL);
        int delt = tm.tv_sec-m_in_stamp;
        n_halt = delt/SECONDS_PER_HALT;
        if( n_halt > m_halt_times )
            n_halt = m_halt_times;
    }
    repo_def::round_t *p_r = repo_mgr.round.get(resid_);
    if( NULL == p_r )
    {
        logerror((LOG, "get_zodiac_halt_result, no resid:%d", resid_));
        sc_msg_def::ret_auto_round_resu_failed_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    int exp = 0;
    int coin = 0;
    int rmb = 0;

    for(int i = 0;i<n_halt;++i)
    {
        //生成掉落
        sc_msg_def::ret_auto_round_resu_t ret;
        ret.num = ++m_halt_sent;
        exp += ret.exp = p_r->exp;
        coin += ret.coin = p_r->coin;
        rmb += ret.rmb = gen_rmb();
        gen_drop_items_i(ret.drop_items);
        logic.unicast(m_user.db.uid, ret);


        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t i=0; i<ret.drop_items.size(); i++)
        {
            sc_msg_def::jpk_item_t& item = ret.drop_items[i];
            m_user.item_mgr.addnew(item.resid, item.num, nt);
        }
        m_user.item_mgr.on_bag_change(nt);
    }

    //====================================
    //保存用户
    //保存经验
    //保存等级
    //如果升级则更新角色属性
    //通知经验和等级改变
    //通知角色属性改变
    m_user.on_money_change(coin);
    m_user.on_freeyb_change(rmb);
    m_user.on_exp_change(exp);
    m_user.on_power_change(-POW(0)*n_halt);
    m_user.save_db();

    if( m_halt_times-n_halt )
    {
        m_in_stamp += n_halt * SECONDS_PER_HALT;
        m_halt_times-=n_halt;
    }
    else
    {
        m_in_stamp = 0;
        m_cur_rid = 0;
        m_halt_sent = 0;
        m_halt_times = 0;
        m_halt_flag = -1;
    }
    store_halt_info();

    //通知杀怪个数
    repo_def::round_t* rp_round = repo_mgr.round.get(resid_);
    if (rp_round != NULL)
    {
        for(int n=0;n<n_halt;n++)
        {
            for(size_t i=1; i<rp_round->initial_monster.size(); i++)
            {
                m_user.task.on_monsert_killed((int)rp_round->initial_monster[i][0], 1);
                m_user.love_task.on_monster_killed((int)rp_round->initial_monster[i][0], 1);
            }
            for(size_t i=1; i<rp_round->monster.size(); i++)
            {
                m_user.task.on_monsert_killed((int)rp_round->monster[i][0], 1);
                m_user.love_task.on_monster_killed((int)rp_round->monster[i][0], 1);
            }
            m_user.task.on_monsert_killed((int)rp_round->initial_boss[1], 1);
            m_user.task.on_monsert_killed((int)rp_round->boss[1], 1);
            m_user.love_task.on_monster_killed((int)rp_round->initial_boss[1], 1);
            m_user.love_task.on_monster_killed((int)rp_round->boss[1], 1);

            m_user.task.on_round_pass(resid_);
            m_user.love_task.on_round_pass(resid_);

            if( resid_/1000 == 1)
                m_user.daily_task.on_event(evt_round_pass);

            if( resid_/1000 == 3)
                m_user.daily_task.on_event(evt_pass_zodiac);
        }
    }
    else
    {
        logerror((LOG, "get_halt_result, repo no round, resid:%d", resid_));
    }

    return SUCCESS;
}

//将挂机信息放入内存结构
void sc_round_t::store_halt_info()
{
    auto it_hm = round_ctl.m_halt_hm.find(m_user.db.uid);
    if( it_hm != round_ctl.m_halt_hm.end() )
    {
        it_hm->second.r_cur_rid = m_cur_rid;
        it_hm->second.r_cur_flag = m_cur_flag;
        it_hm->second.r_in_stamp = m_in_stamp;
        it_hm->second.r_halt_times = m_halt_times;
        it_hm->second.r_halt_sent = m_halt_sent;
        it_hm->second.r_halt_flag = m_halt_flag;
        it_hm->second.r_halt_gid = m_halt_gid;
    }
    else
    {
        round_ctl.m_halt_hm.insert(make_pair(m_user.db.uid,sc_halt_t(m_cur_rid,m_cur_flag,m_in_stamp,m_halt_times,m_halt_sent,m_halt_flag,m_halt_gid)));
    }
}

int32_t sc_round_t::stop_halt()
{
    m_in_stamp = 0;
    m_cur_rid = 0;
    m_halt_times = 0;
    m_halt_sent = 0;
    m_halt_flag = -1;
    m_halt_gid = 0;

    store_halt_info();

    return SUCCESS;
}

void sc_round_t::load_halt_info()
{
    auto it_hm = round_ctl.m_halt_hm.find(m_user.db.uid);
    if( it_hm != round_ctl.m_halt_hm.end() )
    {
        m_cur_rid = it_hm->second.r_cur_rid;
        m_cur_flag = it_hm->second.r_cur_flag;
        m_in_stamp = it_hm->second.r_in_stamp;
        m_halt_times = it_hm->second.r_halt_times;
        m_halt_sent = it_hm->second.r_halt_sent;
        m_halt_flag = it_hm->second.r_halt_flag;
        m_halt_gid = it_hm->second.r_halt_gid;
    }
    else
    {
        m_cur_rid = 0;
        m_cur_flag = 0;
        m_in_stamp = 0;
        m_halt_times = 0;
        m_halt_sent = 0;
        m_halt_flag = -1;
        m_halt_gid = 0;
    }
}

void sc_round_t::get_halt_info(int32_t &rid_, int32_t &stamp_, int32_t &times_, int32_t &flag_, int32_t &gid_)
{
    rid_ = m_cur_rid;
    times_ = m_halt_times;
    flag_ = m_halt_flag;
    gid_ = m_halt_gid;

    struct timeval tm;
    gettimeofday(&tm, NULL);
    stamp_ = (times_*SECONDS_PER_HALT)-(tm.tv_sec-m_in_stamp);
    if( stamp_ < 0 )
        stamp_ = 0;
}
void sc_round_ctl_t::reset(int32_t uid_)
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

            it_flush->second = date_helper.cur_sec();
        }
    }
    else
        m_flush_hm.insert( make_pair(uid_,date_helper.cur_sec()) );
    /*
    if( date_helper.offday(flush_sec) >= 1)
    {
        flush_sec = date_helper.cur_sec();
        m_round_hm.clear();
        m_zodiac_hm.clear();
    }
    */
}
void sc_round_ctl_t::get_pass_round(int32_t uid_, vector<int32_t> &ret)
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

void sc_round_ctl_t::get_zodiac(int32_t uid_, map<int32_t,int32_t> &ret)
{
    reset(uid_);
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
}

//获取该十二宫组未打过的关卡
int32_t sc_round_ctl_t::get_raw_zodiac(int32_t uid_, int32_t gid_, vector<int32_t> &rounds)
{
    auto it = repo_mgr.roundgroup.find(gid_);
    if( it == repo_mgr.roundgroup.end() )
        return ERROR_SC_ILLEGLE_REQ;
    for(auto it_v=it->second.scene_id.begin();it_v!=it->second.scene_id.end();++it_v)
    {
        if( -1 == *it_v )
            continue;
        //判断该玩家对于当前关卡是否有次数
        auto it_hm=round_ctl.m_round_hm.find(uid_);
        if( it_hm!=round_ctl.m_round_hm.end() )
        {
            auto it_hm_hm = it_hm->second.find(300);
            if( it_hm_hm != it_hm->second.end() )
            {
                if( 1 == it_hm_hm->second.count(*it_v) )
                    continue;
            }
        }
        rounds.push_back(*it_v);
    }
    return SUCCESS;
}
