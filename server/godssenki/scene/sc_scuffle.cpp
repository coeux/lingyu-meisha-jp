#include "sc_scuffle.h"

#include "date_helper.h"
#include "code_def.h"
#include "repo_def.h"

#include "sc_user.h"
#include "sc_logic.h"
#include "sc_battle_pvp.h"
#include "sc_cache.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_push_def.h"
#include "random.h"
#include "sc_statics.h"

#define LOG "SC_SCUFFLE"

//乱斗场每天开放1次，分别是20点
#define BASE_TIME_SCUF_2 20
#define BASE_TIME_SCUF_3 0
//每次开放持续20分钟
#define SCUF_DURATION 30

//提前15分钟开始报名(无报名时间)
#define REGIST_TIME 420

//开始5分钟之后不准进入(无此限制)
#define ENTER_LIMIT 30

//超过10级可以报名
#define ACCESS_LV 30

//最多只能报名500人(无此限制)
#define MAX_HERO 50000000

#define REGION_SIZE 30
//玩家掉线三分钟不能再进(无此限制)
#define QUIT_INTERVAL 1800000

//乱斗场场景
#define SCUFFLE_SCENEID 2000

//以25级区分乱斗场
#define SCUFFLE_DEVIDE 55

//战斗前1分钟等待
#define wait_battle 60

// 战斗前进入默认位置
#define ENTER_POS_X -100
#define ENTER_POS_Y -150

// 战斗复活位置
#define REVIVE_LEFT_POS_X -700
#define REVIVE_LEFT_POS_Y -230
#define REVIVE_RIGHT_POS_X 750
#define REVIVE_RIGHT_POS_Y -230

// 乱斗场中最长允许待机时间
#define STANDBY_TIME 300

// 最多允许进入次数
#define MAX_ENTER_TIME 2

sc_scuffle_hero_t::sc_scuffle_hero_t(int32_t uid_,int32_t resid_,const string &nickname_,int32_t lv_, int32_t viplevel_, sc_scuffle_t &scuffle_):
    uid(uid_),
    resid(resid_),
    nickname(nickname_),
    lv(lv_),
    viplevel(viplevel_),
    old_scene(0),
    last_in(0),
    quit_stmp(0),
    in_scuffle(0),
    in_battle(0),
    n_victory(0),
    n_con_victory(0),
    n_fail(0),
    score(0),
    x(0),
    y(0),
    watch_max(0),
    hp_percent(1),
    morale(100),
    last_fight_time(0),
    last_beat_time(0),
    last_con_win(0),
    enter_times(0),
    scuffle(scuffle_)
{
    watch.clear();
}

bool sc_scuffle_hero_t::is_fullwatch()
{
    return watch_max<= watch.size();
}
//互相看见
void sc_scuffle_hero_t::watch_eachother(int32_t uid_)
{
    //处理对方
    auto it = scuffle.m_hero_hm.find(uid_);
    if( it == scuffle.m_hero_hm.end() )
        return;
    sp_hero_t object_hero = it->second;
    if( object_hero != NULL )
    {
        object_hero->watch.insert(make_pair(uid,1));
        
        //对方看见我
        sc_msg_def::nt_scuffle_hero_in_t nt;
        nt.uid = uid;
        nt.resid = resid;
        nt.name = nickname;
        nt.level = lv;
        nt.weaponid = 0;
        nt.x = x;
        nt.y = y;
        nt.in_battle = in_battle;
        nt.n_win = n_victory;
        nt.n_con_win = n_con_victory;

        sp_user_t user;
        if (logic.usermgr().get(uid, user))
        {
            if (user->wing.get_weared() != NULL)
            {
                nt.wingid=user->wing.get_weared()->db.resid;
            }
            sp_equip_t equip = user->equip_mgr.get_part(0, 4);
            if (equip != NULL)
                nt.weaponid = equip->db.resid;
            user->pet_mgr.get_pet_state(nt.have_pet, nt.petid);
        }
        logic.unicast(uid_,nt);
        
        //我看见对方
        nt.uid = uid_;
        nt.resid = object_hero->resid;
        nt.name = object_hero->nickname;
        nt.level = object_hero->lv;
        nt.weaponid = 0;
        nt.wingid = 0;
        nt.x = object_hero->x;
        nt.y = object_hero->y;
        nt.in_battle = object_hero->in_battle;
        nt.n_win = object_hero->n_victory;
        nt.n_con_win = object_hero->n_con_victory;
        if (logic.usermgr().get(uid_, user))
        {
            if (user->wing.get_weared() != NULL)
            {
                nt.wingid=user->wing.get_weared()->db.resid;
            }
            sp_equip_t equip = user->equip_mgr.get_part(0, 4);
            if (equip != NULL)
                nt.weaponid = equip->db.resid;
        }
        logic.unicast(uid,nt);
    }
    //处理自己
    watch.insert(make_pair(uid_, 1));
}
//互相看不见
void sc_scuffle_hero_t::unwatch_eachother(int32_t uid_)
{
    //处理对方
    auto it = scuffle.m_hero_hm.find(uid_);
    if( it == scuffle.m_hero_hm.end() )
        return;
    sp_hero_t object_hero = it->second;
    if( object_hero != NULL )
    {
        object_hero->watch.erase(uid);
        
        sc_msg_def::nt_user_out_t nt;
        nt.uid = uid;
        logic.unicast(uid_,nt);
        
        nt.uid = uid_;
        logic.unicast(uid,nt);

        scuffle.update(object_hero);
    }
}
void sc_scuffle_hero_t::leave(int32_t active_)
{
    int32_t sum = 0;
    for( auto it=watch.begin();it!=watch.end();)
    {
        if (sum > 200)
            break;
        unwatch_eachother(it->first);
        it = watch.erase(it);
        sum++;
    }
    if( active_ )
        last_in = 1;
    else
        quit_stmp = date_helper.cur_sec();
    in_scuffle = 0;
    in_battle = 0;
    watch.clear();
}
void sc_scuffle_hero_t::sync_pos(int32_t x_,int32_t y_)
{
    x = x_;
    y = y_;
    update_stamp = date_helper.cur_sec();

    for( auto it=watch.begin();it!=watch.end();++it )
    {
        sc_msg_def::nt_move_t nt;
        nt.uid = uid;
        nt.sceneid = SCUFFLE_SCENEID;
        nt.x = x;
        nt.y = y;
        logic.unicast(it->first,nt);
    }
}
void sc_scuffle_hero_t::rush_into(int32_t x_,int32_t y_)
{
    x = x_;
    y = y_;
    update_stamp = date_helper.cur_sec();

    for( auto it=watch.begin();it!=watch.end();++it )
    {
        sc_msg_def::nt_transport_t nt;
        nt.uid = uid;
        nt.sceneid = SCUFFLE_SCENEID;
        nt.x = x;
        nt.y = y;
        logic.unicast(it->first,nt);
    }
}
void sc_scuffle_hero_t::unicast_state()
{
    sc_msg_def::nt_scuffle_hero_change_t nt;
    nt.uid = uid;
    nt.in_battle = in_battle;
    nt.n_win = n_victory;
    nt.n_con_win = n_con_victory;
    nt.score = score;
    nt.morale = morale;

    logic.unicast(uid,nt);

    for( auto it=watch.begin();it!=watch.end();++it )
        logic.unicast(it->first,nt);
}
//////////////////////////////
sc_scuffle_t::sc_scuffle_t(int32_t key_):key(key_),m_prepare_tm(0),top_cut(0),m_open(0)
{
}
void sc_scuffle_t::update(sp_hero_t hero_)
{
    auto it=users.begin();
    while(it!=users.end())
    {
        if( hero_->is_fullwatch() )
            break;
        sp_hero_t object_hero = get_hero(*it);
        if( object_hero == NULL )
            it = users.erase(it);
        else if( !object_hero->is_fullwatch() && (object_hero->uid!=hero_->uid) )
        {
            hero_->watch_eachother(*it);
            if( object_hero->is_fullwatch() )
            {
                users.push_back(*it);
                it = users.erase(it);
            }
            else
                it++;
        }
        else it++;
    }
}
sp_hero_t sc_scuffle_t::get_hero(int32_t uid_)
{
    auto it=m_hero_hm.find(uid_);
    if( it!=m_hero_hm.end() )
        return it->second;
    return sp_hero_t();
}
bool score_compare(sc_msg_def::jpk_hero_info_t a, sc_msg_def::jpk_hero_info_t b)
{
    return a.score> b.score;
}
void sc_scuffle_t::update_top(sp_hero_t hero_)
{
    auto it_v = top.begin();
    for( ; it_v!=top.end() ; ++it_v )
    {
        if( it_v->uid == hero_->uid )
            break;
    }
    if( it_v == top.end() )
    {
        if( top.size() < 10 )
        {
            sc_msg_def::jpk_hero_info_t h;
            h.uid = hero_->uid;
            h.nickname = hero_->nickname;
            h.score = hero_->score;
            top.push_back( std::move(h) );
        }
        else
        {
            if( hero_->score > top_cut )
            {
                top[9].uid = hero_->uid;
                top[9].nickname = hero_->nickname;
                top[9].score = hero_->score;
            }
        }
    }
    else
        it_v->score = hero_->score;

    //重新排序
    sort( top.begin(),top.end(),score_compare );
    if( 10 == top.size() )
        top_cut = top[9].score;
}
void sc_scuffle_t::req_score_rank(int32_t uid_)
{
    sc_msg_def::ret_score_ranking_t ret;

    for (auto it=m_hero_hm.begin(); it!=m_hero_hm.end(); ++it)
    {
        sc_msg_def::jpk_hero_info_t h;
        h.uid = it->second->uid;
        h.nickname = it->second->nickname;
        h.score = it->second->score;
        ret.rank.push_back( std::move(h) );
    }
    ret.left = users.size();
    std::sort(ret.rank.begin(), ret.rank.end(), [&](const sc_msg_def::jpk_hero_info_t& a, const sc_msg_def::jpk_hero_info_t& b)
    {
        if (a.score > b.score)
        {
            return true;
        }
        else if(a.score < b.score)
        {
            return false;
        }
        else
        {
            return a.uid < b.uid;
        }
    });
    for (int32_t i=0; i<ret.rank.size(); ++i)
    {
        ret.rank[i].rank = i+1;
    }
    logic.unicast(uid_, ret);
}
void sc_scuffle_t::rank_reward()
{
    sc_gmail_mgr_t::begin_offmail();
    vector<sc_msg_def::jpk_hero_info_t> h_info;
    for (auto it=m_hero_hm.begin(); it!=m_hero_hm.end(); ++it)
    {
        sc_msg_def::jpk_hero_info_t h;
        h.uid = it->second->uid;
        h.nickname = it->second->nickname;
        h.score = it->second->score;
        h_info.push_back( std::move(h) );
    }
    std::sort(h_info.begin(), h_info.end(), [&](const sc_msg_def::jpk_hero_info_t& a, const sc_msg_def::jpk_hero_info_t& b)
    {
        if (a.score > b.score)
        {
            return true;
        }
        else if (a.score < b.score)
        {
            return false;
        }
        else
        {
            return a.uid < b.uid;
        }
    });

    for (int32_t i=0; i<h_info.size(); ++i)
    {
        h_info[i].rank = i+1;
    }

    for (auto it=h_info.begin(); it!=h_info.end(); ++it)
    {
        if (it->score <= 0)
            continue;
        bool find_reward = false;
        auto it_reward = repo_mgr.scuffle_rank.begin();
        for(; it_reward!=repo_mgr.scuffle_rank.end(); ++it_reward)
        {
            if ( (it->rank >= it_reward->second.ranking[1]) && (it->rank <= it_reward->second.ranking[2]) && (it_reward->first < (key+1)*100) )
            {
                find_reward = true;
                break;
            }
        }
        if (!find_reward)
            continue;

        //保存邮件道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        for(size_t j=1; j<it_reward->second.reward.size(); ++j)
        {
            sc_msg_def::jpk_item_t itm;
            itm.itid=0;
            itm.resid=it_reward->second.reward[j][0];
            itm.num=it_reward->second.reward[j][1];
            nt.items.push_back(itm);
        }
        string msg = mailinfo.new_mail(mail_scuffle_rank,it->rank);
        auto rp_gmail = mailinfo.get_repo(mail_scuffle_rank);

        if (rp_gmail != NULL)
        {
            sc_gmail_mgr_t::add_offmail(it->uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
        }
    }
    sc_gmail_mgr_t::do_offmail();
}

void sc_scuffle_t::unicast_top10()
{
    sc_msg_def::nt_score_ranking_t ret;
    ret.top = top;
    
    string message;
    ret >> message;
    logic.usermgr().broadcast( sc_msg_def::nt_score_ranking_t::cmd(),message );
}

bool
sc_scuffle_t::remain_one_fighter()
{
    int32_t has_morale_meber = 0;
    for (auto it=m_hero_hm.begin(); it!=m_hero_hm.end(); ++it)
    {
        if (it->second->morale > 0)
        {
            has_morale_meber++;
        }
    }
    return (has_morale_meber == 1);
}

void
sc_scuffle_t::remain_one_end()
{
    if (m_open == 0)
        return;
    int32_t uid_winner = 0;
    for (auto it_u=m_hero_hm.begin(); it_u!=m_hero_hm.end(); ++it_u)
    {
        if (it_u->second->morale > 0)
        {
            uid_winner = it_u->second->uid;
            break;
        }
    }
    if (uid_winner == 0)
        return;
    if (m_hero_hm.size() == 0)
        return;
    for (auto it_u=m_hero_hm.begin(); it_u!=m_hero_hm.end(); ++it_u)
    {
        int32_t uid = it_u->second->uid;
        sp_user_t user;
        if (logic.usermgr().get(uid, user))
        {
            if (it_u->second->in_scuffle == 0)
                continue;
            sc_msg_def::nt_scuffle_end_t ret;
            ret.uid = uid_winner;
            logic.unicast(uid, ret);            
            scuffle_mgr.exit_scuffle(user);
        }
    }
    rank_reward();
    clear_rest();
}

void sc_scuffle_t::clear_rest()
{
    m_open = 0;
    m_hero_hm.clear();
}

void sc_scuffle_t::rank_score()
{
    for(auto it=m_hero_hm.begin();it!=m_hero_hm.end();++it)
    {
        int32_t uid = it->second->uid;
        sp_user_t user;
        if ( logic.usermgr().get(uid, user) || cache.get(uid, user) )
        {
            int32_t score = it->second->score;
            if( score <= 0 )
            {
                //推送信封
                auto rp_gmail = mailinfo.get_repo(mail_scuffle_zero);
                if (rp_gmail != NULL)
                {
                    string msg = mailinfo.new_mail(mail_scuffle_zero); 
                    user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime);
                }
                /*
                   string mail = mailinfo.new_mail(mail_scuffle_zero); 
                   if (!mail.empty())
                   notify_ctl.push_mail(uid, mail);
                   */
                continue;
            }
            int32_t gold = score*10;
            int32_t battlexp = cal_battlexp(user->db.grade,score);

            vector<sc_msg_def::jpk_item_t> items;
            items.push_back({0, 10001, gold});
            items.push_back({0, 10002, battlexp});
            //user->on_money_change(gold);
            //user->on_battlexp_change(battlexp);
            //推送信封
            auto rp_gmail = mailinfo.get_repo(mail_scuffle_score);
            if (rp_gmail != NULL)
            {
                string msg = mailinfo.new_mail(mail_scuffle_score,score,gold,battlexp); 
                user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, items);
            }
        }

    }
}
int32_t sc_scuffle_t::cal_battlexp(int32_t grade_,int32_t score_)
{
    if( score_ <= 0 )
        return 0;
    if( grade_<SCUFFLE_DEVIDE && score_>1200 )
        return 1200;
    if( grade_>=SCUFFLE_DEVIDE && score_>2000 )
        return 2000;
    return score_;
}
void sc_scuffle_t::rank_last(int32_t uid_)
{
    auto it_reward=repo_mgr.scuffle_last.find(key);
    if( it_reward==repo_mgr.scuffle_last.end() )
        return;

    sp_user_t user;
    if( logic.usermgr().get(uid_, user) || cache.get(uid_, user) )
    {
        //保存道具到数据库
        sc_msg_def::nt_bag_change_t nt;
        sc_msg_def::jpk_item_t itm;
        itm.itid=0;
        itm.resid=it_reward->second.reward;
        itm.num=1;
        nt.items.push_back(itm);
        //user->item_mgr.put(nt);
        //user->item_mgr.on_bag_change(nt);

        //获取礼包名
        repo_def::item_t* ritem = repo_mgr.item.get(itm.resid); 
        if (ritem == NULL)
        {
            logerror((LOG, "repo no item resid:%d", itm.resid));
            return;
        }

        //推送信封
        auto rp_gmail = mailinfo.get_repo(mail_scuffle_last);
        if (rp_gmail != NULL)
        {
            string msg = mailinfo.new_mail(mail_scuffle_last,ritem->name); 
            user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
        }

        pushinfo.new_push(push_scuffle_winner,user->db.nickname(),user->db.grade,user->db.uid,user->db.viplevel);
    }
}
//////////////////////////////
sc_scuffle_mgr_t::sc_scuffle_mgr_t()
{
    can_arrange = true;
    m_start = BASE_TIME_SCUF_2 * 3600 + BASE_TIME_SCUF_3 * 60;
    m_end = m_start + SCUF_DURATION * 60;
    m_prepare = m_start - REGIST_TIME * 60;
    m_access = m_start + ENTER_LIMIT * 60;
}
int32_t sc_scuffle_mgr_t::is_prepare_stage()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();

    if( ((base+m_prepare)<=cur) && (cur<=(base+m_start)) )
        return 1;
    return 0;
}
int32_t sc_scuffle_mgr_t::is_enter_stage()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();

    if( ((base+m_start)<=cur) && (cur<=(base+m_access)) )
        return 1;
    return 0;
}
int32_t sc_scuffle_mgr_t::is_balance_stage()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();

    if( ((base+m_access)<=cur) && (cur<=(base+m_end)) )
        return 1;
    return 0;
}
int32_t sc_scuffle_mgr_t::is_close_stage()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();
    if( cur<(base+m_prepare) )
        return 1;
    if( cur>=(base+m_end) )
        return 1;
    return 0;
}
bool sc_scuffle_mgr_t::is_sign_up_time()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();
    if( cur>=(base+m_prepare) || cur<(base+m_start) )
        return true;
    return false;
}
bool sc_scuffle_mgr_t::is_fight_time()
{
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();
    if( cur>(base+m_start+5) && cur <(base+m_end) )
        return true;
    return false;
}
void sc_scuffle_mgr_t::get_reward()
{
    if( !is_close_stage() )
        return;

    auto it=m_scuffle_hm.begin();
    while( it!=m_scuffle_hm.end() )
    {
        if( it->second->m_open )
        {
            it->second->rank_reward();
            it->second->rank_score();
            it->second->m_open = 0;
        }
        ++it;
    }
}
void sc_scuffle_mgr_t::clear(sp_scuffle_t sp_scuf)
{
    if( date_helper.offday(sp_scuf->m_prepare_tm)>=1 )
    {
        sp_scuf->m_hero_hm.clear();
        sp_scuf->users.clear();

        sp_scuf->top.clear();
        sp_scuf->top_cut = 0;

        sp_scuf->m_prepare_tm = date_helper.cur_sec();
        sp_scuf->m_open = 1;
    }
}

int32_t sc_scuffle_mgr_t::get_key(int32_t uid_)
{
    auto it=user_region_list.find(uid_);
    if (it==user_region_list.end())
        return 1;
    else
        return it->second;
    /*
    if( lv_<SCUFFLE_DEVIDE )
        return 1;
    return 2;
    */
}
int32_t sc_scuffle_mgr_t::cal_point(bool is_win_, int32_t con_win_, int32_t e_con_win_)
{
    if (is_win_)
    {
        int32_t win_point = repo_mgr.configure.find(34)->second.value;
        int32_t con_point = repo_mgr.configure.find(36)->second.value*(con_win_-1);
        int32_t e_con_point = repo_mgr.configure.find(36)->second.value*(e_con_win_-1);
        if (con_point > 200)
            con_point = 200;
        if (con_point < 0)
            con_point = 0;
        if (e_con_point > 200)
            e_con_point = 200;
        if (e_con_point < 0)
            e_con_point = 0;
        return (win_point+con_point+e_con_point);
    }
    else
    {
        int32_t lose_point = repo_mgr.configure.find(35)->second.value;
        return lose_point;
    }
}
int32_t
sc_scuffle_mgr_t::sign_up(sp_user_t user_)
{
    if (!is_sign_up_time())
        return ERROR_SCUFFLE_NOT_OPEN;

    if( user_->db.grade < ACCESS_LV )
    {
        return ERROR_SCUFFLE_LV;
    }
    
    auto it = sign_up_list.find(user_->db.uid);
    if (it != sign_up_list.end())
        return ERROR_USER_HAS_SIGNUP;

    sign_up_list.insert(make_pair(user_->db.uid, user_));
/*
    // 建立该分区的乱斗场
    int key = get_key(user_->db.grade);
    auto it = m_scuffle_hm.find(key);
    if( it == m_scuffle_hm.end() )
    {
        sp_scuffle_t sp_scuf(new sc_scuffle_t(key));
        it=m_scuffle_hm.insert(make_pair(key,sp_scuf)).first;
    }
    clear(it->second);

    it->second->m_open = 1;

    //报名
    auto it_u = it->second->m_hero_hm.find(user_->db.uid);
    if (it_u != it->second->m_hero_hm.end())
        return ERROR_USER_HAS_SIGNUP;
    sp_hero_t sp_hero(new sc_scuffle_hero_t(user_->db.uid,user_->db.resid,user_->db.nickname(),user_->db.grade,*(it->second)));
    it->second->m_hero_hm.insert(make_pair(user_->db.uid,sp_hero));
    */
    return SUCCESS;
}

void
sc_scuffle_mgr_t::arrange_region()
{
    if (!can_arrange)
        return;
    can_arrange = false;
    if (sign_up_list.size() == 0)
        return;

    /*
    vector<int32_t> member_list;
    for (auto it=sign_up_list.begin(); it!=sign_up_list.end(); ++it)
    {
        member_list.push_back(it->first);
    }

    sort(member_list.begin(), member_list.end(), [&](int32_t a, int32_t b)
    {
        if (sign_up_list[a]->db.grade <= sign_up_list[b]->db.grade)
            return true;
        else
            return false;
    });
    */

    int32_t num;
    if (sign_up_list.size() < REGION_SIZE)
        num = 1;
    else
        num = sign_up_list.size()/REGION_SIZE;

    int32_t count_num = 1;
    int32_t turn = 0;
    for (auto it=sign_up_list.begin(); it!=sign_up_list.end(); ++it)
    {
        if (it->first > 1000000 || it->first <= 0)
            continue;
        count_num = turn/REGION_SIZE + 1;
        if (count_num > num)
            count_num = num;

        user_region_list.insert(make_pair(it->first, count_num));
        // 建立该分区的乱斗场
        int key = count_num;
        auto it2 = m_scuffle_hm.find(key);
        if( it2 == m_scuffle_hm.end() )
        {
            sp_scuffle_t sp_scuf(new sc_scuffle_t(key));
            m_scuffle_hm.insert(make_pair(key,sp_scuf));
            it2 = m_scuffle_hm.find(key);
        }

        it2->second->m_open = 1;

        //报名
        sp_user_t& user_ = it->second;
        sp_hero_t sp_hero(new sc_scuffle_hero_t(user_->db.uid,user_->db.resid,user_->db.nickname(),user_->db.grade,user_->db.viplevel,*(it2->second)));
        it2->second->m_hero_hm.insert(make_pair(user_->db.uid,sp_hero));
        statics_ins.unicast_eventlog(*user_,5060,1,key);
        turn++;
    }
    /*
    for (size_t i=0; i<member_list.size(); ++i)
    {
        count_num = i/REGION_SIZE + 1;
        if (count_num > num)
            count_num = num;
        user_region_list.insert(make_pair(member_list[i], count_num));
        // 建立该分区的乱斗场
        int key = count_num;
        auto it = m_scuffle_hm.find(key);
        if( it == m_scuffle_hm.end() )
        {
            sp_scuffle_t sp_scuf(new sc_scuffle_t(key));
            m_scuffle_hm.insert(make_pair(key,sp_scuf));
            it = m_scuffle_hm.find(key);
        }

        it->second->m_open = 1;

        //报名
        sp_user_t user_ = sign_up_list[member_list[i]];
        sp_hero_t sp_hero(new sc_scuffle_hero_t(user_->db.uid,user_->db.resid,user_->db.nickname(),user_->db.grade,user_->db.viplevel,*(it->second)));
        it->second->m_hero_hm.insert(make_pair(user_->db.uid,sp_hero));
        statics_ins.unicast_eventlog(*user_,5060,1,key);
    }
    */
}

void
sc_scuffle_mgr_t::update()
{
    int32_t cur = date_helper.cur_sec();
    int32_t base = date_helper.cur_0_stmp();
    update_fights(cur);
    if( cur == date_helper.cur_0_stmp() )
    {
        m_scuffle_hm.clear();
        can_arrange = true;
        sign_up_list.clear();
        user_region_list.clear();
        partner_hp_map.clear();
        return;
    }

    if( cur < base+m_start)
        return;
    else if (cur < base+m_start+5)
    {
        arrange_region();
    }
    else if (cur < base+m_end)
    {
        for (auto it=m_scuffle_hm.begin(); it!=m_scuffle_hm.end(); ++it)
        {
            if (it->second->m_open == 0)
                continue;
            int32_t sum = 0;
            for (auto it_u=it->second->m_hero_hm.begin(); it_u!=it->second->m_hero_hm.end(); ++it_u)
            {
                sum += it_u->second->in_battle;
            }
            if (sum != 0)
                continue;
            if (it->second->remain_one_fighter())
            {
                it->second->remain_one_end();
            }
        }

        return;
    }
    else if (cur > base+m_end)
    {
        for (auto it=m_scuffle_hm.begin(); it!=m_scuffle_hm.end(); ++it)
        {
            if (it->second->m_open == 0)
                continue;
            int32_t sum = 0;
            for (auto it_u=it->second->m_hero_hm.begin(); it_u!=it->second->m_hero_hm.end(); ++it_u)
            {
                sum += it_u->second->in_battle;
            }
            if (sum != 0)
                continue;
            for (auto it_u=it->second->m_hero_hm.begin(); it_u!=it->second->m_hero_hm.end(); ++it_u)
            {
                int32_t uid = it_u->second->uid;
                sp_user_t user;
                if (logic.usermgr().get(uid, user))
                {
                    if (it_u->second->in_scuffle == 0)
                        continue;
                    sc_msg_def::nt_scuffle_end_t ret;
                    ret.uid = 0;
                    logic.unicast(uid, ret);
                    exit_scuffle(user);
                }
            }
            it->second->rank_reward();
            it->second->clear_rest();
        }
        int32_t sum=0;
        for (auto it=m_scuffle_hm.begin(); it!=m_scuffle_hm.end(); ++it)
        {
            sum += it->second->m_open;
        }
        if (sum == 0)
        {
            m_scuffle_hm.clear();
            can_arrange = true;
            sign_up_list.clear();
            user_region_list.clear();
            partner_hp_map.clear();
        }
    }
    
}
void
sc_scuffle_mgr_t::update_fights(int32_t cur)
{
    for (auto it_scu=m_scuffle_hm.begin(); it_scu!=m_scuffle_hm.end(); ++it_scu)
    {
        for (auto it_u=it_scu->second->m_hero_hm.begin(); it_u!=it_scu->second->m_hero_hm.end(); ++it_u)
        {
            if ((it_u->second->last_fight_time + 360 < cur) && (it_u->second->in_battle == 1))
            {
                it_u->second->in_battle = 0;
            }
        }
    }
}
int sc_scuffle_mgr_t::prepare(sp_user_t user_)
{
    if (is_close_stage())
        return ERROR_SC_ILLEGLE_REQ;

    //sc_msg_def::ret_scuffle_regist_t ret;

    if( user_->db.grade < ACCESS_LV )
    {
        //ret.code = ERROR_SC_ILLEGLE_REQ;
        //logic.unicast(user_->db.uid, ret);
        return ERROR_SC_ILLEGLE_REQ;
    }

    //不在报名时间
    /*
    if( !is_prepare_stage() )
    {
        ret.code = ERROR_SCUFFLE_NOT_OPEN;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    */

    int key = get_key(user_->db.uid);
    auto it = m_scuffle_hm.find(key);
    if( it == m_scuffle_hm.end() )
    {
        sp_scuffle_t sp_scuf(new sc_scuffle_t(key));
        it=m_scuffle_hm.insert(make_pair(key,sp_scuf)).first;
    }
    clear(it->second);

    it->second->m_open = 1;

    //是否已经报名
    auto it_hero = it->second->m_hero_hm.find(user_->db.uid);
    if( it_hero != it->second->m_hero_hm.end() )
    {
        if (it_hero->second->n_fail>=10)
            return ERROR_SCUFFLE_FAIL10;
        //ret.code = ERROR_SCUFFLE_REGISTED;
        //logic.unicast(user_->db.uid, ret);
        return SUCCESS;
    }
    //报名人数已满
    /*
    if( it->second->m_hero_hm.size() == MAX_HERO )
    {
        ret.code = ERROR_SCUFFLE_FULL;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    */
    //报名
    sp_hero_t sp_hero(new sc_scuffle_hero_t(user_->db.uid,user_->db.resid,user_->db.nickname(),user_->db.grade,user_->db.viplevel,*(it->second)));
    it->second->m_hero_hm.insert(make_pair(user_->db.uid,sp_hero));
    //ret.code = SUCCESS;
    //logic.unicast(user_->db.uid, ret);
    return SUCCESS;
}

void sc_scuffle_mgr_t::move(sc_msg_def::nt_move_t &jpk_,int32_t uid_)
{
    int key = get_key(uid_);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
        return;
    auto it_hero = it_cur->second->m_hero_hm.find(jpk_.uid);
    if( it_hero == it_cur->second->m_hero_hm.end() )
        return;

    it_hero->second->sync_pos(jpk_.x,jpk_.y);
}
void sc_scuffle_mgr_t::get_rank(int32_t uid_)
{
    int key = get_key(uid_);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
        return;

    it_cur->second->req_score_rank(uid_);

    /*
    it_cur->second->req_score_rank(uid_);
        
    if( it_cur->second->m_open )
    {
        //int32_t last_uid = 0;
        if( is_close_stage() )
        {
            if( it_cur->second->users.size() > 1 )
            {
                for(auto it=it_cur->second->users.begin();it!=it_cur->second->users.end();++it)
                {
                    sc_msg_def::nt_scuffle_end_t ret;
                    ret.uid = 0;
                    logic.unicast(*it, ret);
                }
            }
            else if( it_cur->second->users.size() == 1 )
            {
                sc_msg_def::nt_scuffle_end_t ret;
                auto it = it_cur->second->users.begin();
                //last_uid = ret.uid = *it;
                logic.unicast(*it, ret);
            }
            //发送擂主奖励
            if( last_uid )
                it_cur->second->rank_last(last_uid);
            //发放排名奖励
            it_cur->second->rank_reward();
            //发放积分奖励
            it_cur->second->rank_score();
            //发送积分排名
            it_cur->second->unicast_top10();
            //设置结束状态
            it_cur->second->m_open = 0;
        }
        else if( is_balance_stage() )
        {
            if( it_cur->second->users.size() == 1 )
            {
                sc_msg_def::nt_scuffle_end_t ret;
                auto it = it_cur->second->users.begin();
                //last_uid = ret.uid = *it;
                logic.unicast(*it, ret);

                //发送擂主奖励
                //it_cur->second->rank_last(last_uid);
                //发放排名奖励
                it_cur->second->rank_reward();
                //发放积分奖励
                it_cur->second->rank_score();
                //发送积分排名
                it_cur->second->unicast_top10();
                //设置结束状态
                it_cur->second->m_open = 0;
            }
        }
    }
    */
}
void sc_scuffle_mgr_t::exit_scuffle(sp_user_t user_)
{
    sc_msg_def::ret_enter_city_t ret;
    
    int key = get_key(user_->db.uid);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
    {
        sc_msg_def::req_enter_city_t req;
        req.resid = 1001;
        req.show_player_num = 20;

        logic.citymgr().enter_city(user_->db.uid,req);

        return;
    }
    auto it_hero = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_hero == it_cur->second->m_hero_hm.end() )
    {
        sc_msg_def::req_enter_city_t req;
        req.resid = 1001;
        req.show_player_num = 20;

        logic.citymgr().enter_city(user_->db.uid,req);

        return;
    }

    auto it_user = it_cur->second->users.begin();
    while(it_user != it_cur->second->users.end())
    {
        if( *it_user == user_->db.uid )
            break;
        ++it_user;
    }
    if( it_user == it_cur->second->users.end() )
    {
        sc_msg_def::req_enter_city_t req;
        req.resid = 1001;
        req.show_player_num = 20;

        logic.citymgr().enter_city(user_->db.uid,req);

        return;
    }
    
    it_cur->second->users.erase(it_user);
    it_hero->second->leave();

    sc_msg_def::req_enter_city_t req;
    req.resid = it_hero->second->old_scene;
    req.show_player_num = 20;
    
    logic.citymgr().enter_city(user_->db.uid,req);

    //结算阶段
    /*
    if( it_cur->second->m_open )
    {
        if( is_balance_stage() )
        {
            int32_t is_end = 0;//,last_uid=0;
            if( it_cur->second->users.size()==1 )
            {
                //只剩一人
                sc_msg_def::nt_scuffle_end_t ret;
                auto it = it_cur->second->users.begin();
                ret.uid = *it;
                logic.unicast(*it, ret);
                is_end = 1;
                //last_uid = *it;
            }
            else if( it_cur->second->users.size()==0 )
            {
                //只剩零人
                sc_msg_def::nt_scuffle_end_t ret;
                ret.uid = user_->db.uid;
                logic.unicast(user_->db.uid, ret);
                is_end = 1;
                //last_uid = user_->db.uid;
            }
            if( is_end )
            {
                //发送擂主奖励
                //it_cur->second->rank_last(last_uid);
                //发放排名奖励
                it_cur->second->rank_reward();
                //发放积分奖励
                it_cur->second->rank_score();
                //发送积分排名
                it_cur->second->unicast_top10();
                //设置结束状态
                it_cur->second->m_open = 0;
            }
        }
    }
    */
}

/*
void sc_scuffle_mgr_t::on_loginoff(sp_user_t user_)
{
    int key = get_key(user_->db.grade);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur!=m_scuffle_hm.end() )
    {
        auto it_hero = it_cur->second->m_hero_hm.find(user_->db.uid);
        if( it_hero != it_cur->second->m_hero_hm.end() )
        {
            auto it_user = it_cur->second->users.begin();
            while(it_user != it_cur->second->users.end())
            {
                if( *it_user == user_->db.uid )
                    break;
                ++it_user;
            }
            if( it_user == it_cur->second->users.end() )
                return;

            it_cur->second->users.erase(it_user);
            it_hero->second->leave(0);
        }
    }
}
*/

/*
void sc_scuffle_mgr_t::login_enter_scuffle(sp_user_t user_, int32_t show_player_num_)
{
    // 是否已经报名
    // 进入对应分区的乱斗场
    int code = prepare(user_);
    if (code != SUCCESS)
    {
        sc_msg_def::ret_enter_scuffle_t ret;
        ret.sceneid = SCUFFLE_SCENEID;
        ret.x = -100;
        ret.y = -150;
        //-100, -150

        ret.code = code;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    //查找玩家当前等级段的报名表
    int key = get_key(user_->db.grade);
    auto it_cur = m_scuffle_hm.find(key);
    if( (it_cur!=m_scuffle_hm.end()) && (it_cur->second->m_open) )
    {
        auto it_hero = it_cur->second->m_hero_hm.find(user_->db.uid);
        if( it_hero!=it_cur->second->m_hero_hm.end() && (date_helper.cur_sec()-it_hero->second->quit_stmp<QUIT_INTERVAL) )
        {
            //处理进入逻辑
            it_cur->second->users.push_back(user_->db.uid);
            sc_msg_def::ret_enter_scuffle_t ret;
            ret.sceneid = SCUFFLE_SCENEID;
            ret.x = -300;
            ret.y = -100;
            ret.code = SUCCESS;
            ret.n_win = it_hero->second->n_victory;
            ret.n_con_win = it_hero->second->n_con_victory;
            logic.unicast(user_->db.uid, ret);
            it_cur->second->update(it_hero->second);
            return;
        }
    }
    int32_t resid = user_->lastsceneid;
    if( resid == 0 )
        resid = 1001;
    
    sc_msg_def::req_enter_city_t req;
    req.resid = resid;
    req.show_player_num = show_player_num_;
    logic.citymgr().enter_city(user_->db.uid,req);
}
*/

void sc_scuffle_mgr_t::enter_scuffle(sp_user_t user_, int32_t show_player_num_)
{
    sc_msg_def::ret_enter_scuffle_t ret;

    if (!is_fight_time())
    {
        // 未到乱斗场开放时间
        ret.code = ERROR_SCUFFLE_NOT_FIGHT;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    ret.sceneid = SCUFFLE_SCENEID;
    ret.x = ENTER_POS_X;
    ret.y = ENTER_POS_Y;
    ret.n_win = 0;
    ret.n_con_win = 0;

    //是否已经报名
    int key = get_key(user_->db.uid);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
    {
        // 没有该等级乱斗场
        ret.code = ERROR_NO_SUCH_SCUFFLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    auto it_hero = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_hero == it_cur->second->m_hero_hm.end() )
    {
        // 该乱斗场没有该玩家
        ret.code = ERROR_SCUFFLE_NO_REGISTED;
        logic.unicast(user_->db.uid, ret);
        statics_ins.unicast_eventlog(*user_,4008,1,key,-1);
        return;
    }

    int32_t state;
    int32_t self_state;
    int32_t times;
    int32_t code = req_scuffle_state(user_, state, self_state, times);
    if (state != 2)
    {
        ret.code = ERROR_SCUFFLE_NOT_FIGHT;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    // 未开放 已关闭
    if(it_cur->second->m_open==0)
    {
        ret.code = ERROR_SCUFFLE_CLOSE;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    // 只有一个玩家 关闭该等级乱斗场
    if (it_cur->second->m_hero_hm.size() == 1)
    {
        it_cur->second->clear_rest();
        ret.code = ERROR_LESS_PLAYER;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    
    if (it_hero->second->morale <= 0)
    {
        ret.code = ERROR_SCUFFLE_FAIL10;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    if (it_hero->second->enter_times > MAX_ENTER_TIME)
    {
        ret.code = ERROR_MORE_THAN_MAX_TIMES;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    //玩家可以进入,处理进入场景逻辑
    //原场景删除
    sp_city_t city;
    if (logic.citymgr().get(user_->lastsceneid, city))
    {
        city->del_user(user_->db.uid);
    }
    it_hero->second->old_scene = user_->db.sceneid;
    user_->lastsceneid = user_->db.sceneid;
    //user_->db.sceneid = SCUFFLE_SCENEID;

    //新场景添加
    it_hero->second->enter_times++;
    it_hero->second->in_scuffle = 1;
    it_hero->second->in_battle = 0;
    it_hero->second->x = ENTER_POS_X;
    it_hero->second->y = ENTER_POS_Y;
    it_hero->second->watch_max = show_player_num_;
    it_hero->second->update_stamp = date_helper.cur_sec();
    it_cur->second->users.push_back(user_->db.uid);

    ret.code = SUCCESS;
    ret.n_win = it_hero->second->n_victory;
    ret.n_con_win = it_hero->second->n_con_victory;
    logic.unicast(user_->db.uid, ret);

    it_cur->second->update(it_hero->second);
    it_hero->second->unicast_state();
}

void sc_scuffle_mgr_t::exit_battle(sp_user_t user_, sc_msg_def::req_scuffle_battle_end_t& jpk_)
{
    sc_msg_def::ret_scuffle_battle_end_t ret;

    //判断是否在战斗
    int key = get_key(user_->db.uid);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
        return;
    auto it_cast = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_cast == it_cur->second->m_hero_hm.end() )
        return;
    if( 0 == it_cast->second->in_battle )
    {
        ret.code = ERROR_NOT_IN_BATTLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    it_cast->second->in_battle = 0;
    it_cast->second->update_stamp = date_helper.cur_sec();
    if (jpk_.is_win)
    {
        it_cast->second->n_victory++;
        it_cast->second->n_con_victory++;
        it_cast->second->score += cal_point(true, it_cast->second->n_con_victory, it_cast->second->last_con_win);
        it_cast->second->morale += 10;
        if (it_cast->second->morale > 100)
            it_cast->second->morale = 100;

        //发送推送
        if( it_cast->second->n_victory == 5 )
            pushinfo.new_push(push_scuffle_5_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        if( it_cast->second->n_victory == 10 )
            pushinfo.new_push(push_scuffle_10_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        if( it_cast->second->n_victory == 15 )
            pushinfo.new_push(push_scuffle_15_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        else if( it_cast->second->n_victory == 20 )
            pushinfo.new_push(push_scuffle_20_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        else if( it_cast->second->n_victory > 20 )
            pushinfo.new_push(push_scuffle_con_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel,it_cast->second->n_victory);

        if( it_cast->second->last_con_win >= 5 )
            pushinfo.new_push(push_scuffle_kill_con_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel,it_cast->second->last_fight_user->nickname,it_cast->second->last_fight_user->lv,it_cast->second->last_fight_user->uid,it_cast->second->last_fight_user->viplevel,it_cast->second->last_con_win);

        auto it=partner_hp_map.find(user_->db.uid);
        if (it!=partner_hp_map.end())
        {
            for (auto it_h=jpk_.team_hp.begin(); it_h!=jpk_.team_hp.end(); ++it_h)
            {
                it->second[it_h->pid] = it_h->hp;
            }
        }
    }
    else
    {
        it_cast->second->score += cal_point(false, 0, 0);
        it_cast->second->morale -= 25;
        if (it_cast->second->morale > 0)
        {
            int32_t r = random_t::rand_integer(1, 2);
            if (r == 1)
            {
                ret.x = REVIVE_LEFT_POS_X;
                ret.y = REVIVE_LEFT_POS_Y;
                it_cast->second->rush_into(REVIVE_LEFT_POS_X, REVIVE_LEFT_POS_Y);
            }
            else
            {
                ret.x = REVIVE_RIGHT_POS_X;
                ret.y = REVIVE_RIGHT_POS_Y;
                it_cast->second->rush_into(REVIVE_RIGHT_POS_X, REVIVE_LEFT_POS_Y);
            }
        }
        it_cast->second->n_con_victory = 0;
        it_cast->second->last_beat_time = date_helper.cur_sec();
        auto it=partner_hp_map.find(user_->db.uid);
        if (it!=partner_hp_map.end())
        {
            for (auto it_h=it->second.begin(); it_h!=it->second.end(); ++it_h)
                it_h->second = 1;
        }
    }
    //it_cast->second->hp_percent = hp_percent_;
    ret.code = SUCCESS;
    logic.unicast(user_->db.uid, ret);
    
    if (it_cast->second->morale <= 0)
    {
        sc_msg_def::nt_scuffle_end_t ret;
        ret.uid = -1;
        logic.unicast(it_cast->second->uid, ret);
    }
    it_cast->second->unicast_state();
}

int32_t
sc_scuffle_mgr_t::req_scuffle_state(sp_user_t user_, int32_t& state_, int32_t& user_state_, int32_t& remain_time)
{
    int32_t cur_day = date_helper.cur_dayofweek();
    if (cur_day == 1 || cur_day == 3 || cur_day == 6)
    {
        state_ = 0;
        remain_time = 0;
        user_state_ = 0;
        return SUCCESS;
    }
    int32_t cur = date_helper.cur_sec();
    int32_t base = date_helper.cur_0_stmp();
    if (cur < base+m_prepare)
    {
        remain_time = base+m_prepare-cur;
        state_ = 0;
    }
    else if (cur < base+m_start)
    {
        remain_time = base+m_start-cur;
        state_ = 1;
    }
    else if (cur < base+m_end)
    {
        remain_time = base+m_end-cur;
        state_ = 2;
    }
    else
    {
        remain_time = 0;
        state_ = 3;
    }

    //是否已经报名
    user_state_ = 0;
    auto it = sign_up_list.find(user_->db.uid);
    if (it != sign_up_list.end())
    {
        user_state_ = 1;
    }

    return SUCCESS;
}

void sc_scuffle_mgr_t::enter_battle(sp_user_t user_,int32_t uid_)
{
    sc_msg_def::ret_scuffle_battle_t ret;
    int32_t base = date_helper.cur_0_stmp();
    int32_t cur = date_helper.cur_sec();
    //if ( cur < (base+m_prepare) || cur > (base+m_end))
    if ( cur < (base+m_start) || cur > (base+m_end))
    {
        ret.code = ERROR_SCUFFLE_NOT_FIGHT;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    //判断是否在乱斗场内
    int key = get_key(user_->db.uid);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
    {
        ret.code = ERROR_NO_SUCH_SCUFFLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    auto it_cast = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_cast == it_cur->second->m_hero_hm.end() )
    {
        ret.code = ERROR_SCUFFLE_NO_REGISTED;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( 0 == it_cast->second->in_scuffle)
    {
        ret.code = ERROR_NOT_IN_SCUFFLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( 1 == it_cast->second->in_battle )
    {
        ret.code = ERROR_SCUFFLE_TARGET_BATTLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    //
    auto it_target = it_cur->second->m_hero_hm.find(uid_);
    if( it_target == it_cur->second->m_hero_hm.end() )
    {
        ret.code = ERROR_SCUFFLE_NO_REGISTED;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( 0 == it_target->second->in_scuffle)
    {
        ret.code = ERROR_NOT_IN_SCUFFLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( 1 == it_target->second->in_battle )
    {
        ret.code = ERROR_SCUFFLE_TARGET_BATTLE;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( cur > it_target->second->update_stamp+STANDBY_TIME)
    {
        ret.code = ERROR_IDLE_TOO_MUCH;
        sc_msg_def::nt_scuffle_end_t ret;
        ret.uid = -1;
        logic.unicast(it_target->second->uid, ret);            
        sp_user_t user_target;
        if (logic.usermgr().get(it_target->second->uid, user_target))
        {
            exit_scuffle(user_target);
        }
        logic.unicast(user_->db.uid, ret);
        return;
    }
    if( cur < it_target->second->last_beat_time + 20)
    {
        ret.code = ERROR_FUHUO;
        logic.unicast(user_->db.uid, ret);
        return;
    }
        
    it_cast->second->in_battle = 1;
    it_cast->second->last_fight_time = cur;
    it_cast->second->last_fight_user = it_target->second; 
    it_cast->second->last_con_win = it_target->second->n_con_victory;
    it_target->second->in_battle = 1;
    it_target->second->last_fight_time = cur;
    it_target->second->last_fight_user = it_cast->second;
    it_target->second->last_con_win = it_cast->second->n_con_victory;

    //获取施法者数据
    sp_view_user_t sp_cast_data = view_cache.get_view(user_->db.uid);
    if (sp_cast_data == NULL)
    {
        ret.code = ERROR_NO_VIEW_DATA;
        logic.unicast(user_->db.uid, ret);
        return;
    }
    //获取目标数据
    sp_view_user_t sp_target_data = view_cache.get_view(uid_, true);
    if (sp_target_data == NULL)
    {
        ret.code = ERROR_NO_VIEW_DATA;
        logic.unicast(user_->db.uid, ret);
        return;
    }

    sc_msg_def::ret_scuffle_battle_t ret_target;

    auto it_cast_partner = partner_hp_map.find(it_cast->second->uid);
    if (it_cast_partner == partner_hp_map.end())
    {
        unordered_map<int32_t, float> partners;
        partner_hp_map.insert(make_pair(it_cast->second->uid, partners));
        it_cast_partner = partner_hp_map.find(it_cast->second->uid);
    }
    
    auto it_target_partner = partner_hp_map.find(it_target->second->uid);
    if (it_target_partner == partner_hp_map.end())
    {
        unordered_map<int32_t, float> partners;
        partner_hp_map.insert(make_pair(it_target->second->uid, partners));
        it_target_partner = partner_hp_map.find(it_target->second->uid);
    }
    
    for (auto it=sp_cast_data->roles.begin(); it!=sp_cast_data->roles.end(); ++it)
    {
        int32_t pid = it->second.pid;
        sc_msg_def::jpk_scuffle_partner_t jpk;
        auto it_cast_p=it_cast_partner->second.find(pid);
        if (it_cast_p==it_cast_partner->second.end())
        {
            it_cast_partner->second.insert(make_pair(pid, 1));
            it_cast_p = it_cast_partner->second.find(pid);
        }
        jpk.pid = pid;
        jpk.hp = it_cast_p->second;
        ret.team_self.push_back(jpk);
        ret_target.team_enemy.push_back(jpk);
    }
        
    for (auto it=sp_target_data->roles.begin(); it!=sp_target_data->roles.end(); ++it)
    {
        int32_t pid = it->second.pid;
        sc_msg_def::jpk_scuffle_partner_t jpk;
        auto it_target_p=it_target_partner->second.find(pid);
        if (it_target_p==it_target_partner->second.end())
        {
            it_target_partner->second.insert(make_pair(pid, 1));
            it_target_p = it_target_partner->second.find(pid);
        }
        jpk.pid = pid;
        jpk.hp = it_target_p->second;
        ret.team_enemy.push_back(jpk);
        ret_target.team_self.push_back(jpk);
    }

    (*sp_target_data) >> ret.view_data;

    (*sp_cast_data) >> ret_target.view_data;

    ret.code = SUCCESS;
    logic.unicast(user_->db.uid, ret);
    ret_target.code = SUCCESS;
    logic.unicast(uid_, ret_target);

    it_cast->second->unicast_state();
    it_target->second->unicast_state();

    /*
    sc_msg_def::ret_scuffle_battle_fail_t fail;

    int32_t base = date_helper.cur_0_stmp();
    if (date_helper.offsec(base+m_start)<=60)
    {
        fail.code = 90000;
        logic.unicast(user_->db.uid, fail);
        return;
    }

    uint32_t b = base+m_start;
    uint32_t e = base+m_end;
    user_->update_guwu(3, b, e);

    //判断是否在战斗
    int key = get_key(user_->db.grade);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
        return;
    auto it_cast = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_cast == it_cur->second->m_hero_hm.end() )
        return;
    if( 0 == it_cast->second->in_scuffle)
    {
        fail.code = 90001;
        logic.unicast(user_->db.uid, fail);
        return;
    }
    if( 1 == it_cast->second->in_battle )
    {
        fail.code = 90002;
        logic.unicast(user_->db.uid, fail);
        return;
    }
    auto it_target = it_cur->second->m_hero_hm.find(uid_);
    if( it_target == it_cur->second->m_hero_hm.end() )
        return;
    if( 0 == it_target->second->in_scuffle)
    {
        fail.code = 90003;
        logic.unicast(user_->db.uid, fail);
        return;
    }
    if( 1 == it_target->second->in_battle )
    {
        fail.code = ERROR_SCUFFLE_TARGET_BATTLE;
        logic.unicast(user_->db.uid, fail);
        return;
    }

    it_cast->second->in_battle = 1;
    it_target->second->in_battle = 1;

    sc_msg_def::ret_scuffle_battle_t ret;
    //获取施法者数据
    sp_view_user_t sp_cast_data = view_cache.get_view(user_->db.uid);
    if (sp_cast_data == NULL)
        return;
    sp_cast_data->hp_percent = it_cast->second->hp_percent;
    //获取目标数据
    sp_view_user_t sp_target_data = view_cache.get_view(uid_, true);
    if (sp_target_data == NULL)
        return;
    sp_target_data->hp_percent = it_target->second->hp_percent;
    (*sp_target_data) >> ret.target_data;
    ret.target_guwu_v = guwu_mgr.get_v(uid_, 3);
    //产生随机种子
    uint32_t rseed = random_t::rand_integer(10000, 100000);
    ret.rseed = rseed;
    //开始pvp
    sc_battlefield_t field(rseed, sp_cast_data, sp_target_data, 3);
    int n = field.run();
    logerror((LOG, "on_scuffle_battle, n:%d", n)); 
    //保存胜负
    ret.is_win = field.is_win();
    //胜负逻辑
    int32_t score_cast=0, score_target = 0;
    if (field.is_win())
    {
        //加积分,加连胜，减连胜，加失败
        score_cast = cal_point(it_target->second->n_con_victory);
        it_cast->second->score += score_cast;
        (it_cast->second->n_victory)++;
        (it_cast->second->n_con_victory)++;

        //发送推送
        if( it_cast->second->n_victory == 10 )
            pushinfo.new_push(push_scuffle_10_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        else if( it_cast->second->n_victory == 20 )
            pushinfo.new_push(push_scuffle_20_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel);
        else if( it_cast->second->n_victory % 10 == 0 )
            pushinfo.new_push(push_scuffle_con_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel,it_cast->second->n_victory);

        if( it_target->second->n_con_victory >= 5 )
            pushinfo.new_push(push_scuffle_kill_con_win,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel,sp_target_data->name,sp_target_data->lv,sp_target_data->uid,sp_target_data->viplevel,it_target->second->n_con_victory);

        it_target->second->n_con_victory=0;
        (it_target->second->n_fail)++;
        it_cur->second->update_top(it_cast->second);
    }
    else
    {   score_target = cal_point(it_cast->second->n_con_victory);
        it_target->second->score += score_target;
        (it_target->second->n_victory)++;
        (it_target->second->n_con_victory)++;
        
        //发送推送
        if( it_target->second->n_victory == 10 )
            pushinfo.new_push(push_scuffle_10_win,sp_target_data->name,sp_target_data->lv,sp_target_data->uid,sp_target_data->viplevel);
        else if( it_target->second->n_victory == 20 )
            pushinfo.new_push(push_scuffle_20_win,sp_target_data->name,sp_target_data->lv,sp_target_data->uid,sp_target_data->viplevel);
        else if( it_target->second->n_victory % 10 == 0 )
            pushinfo.new_push(push_scuffle_con_win,sp_target_data->name,sp_target_data->lv,sp_target_data->uid,sp_target_data->viplevel,it_target->second->n_victory);

        if( it_cast->second->n_con_victory >= 5 )
            pushinfo.new_push(push_scuffle_kill_con_win,sp_target_data->name,sp_target_data->lv,sp_target_data->uid,sp_target_data->viplevel,user_->db.nickname(),user_->db.grade,user_->db.uid,user_->db.viplevel,it_cast->second->n_con_victory);

        it_cast->second->n_con_victory=0;
        (it_cast->second->n_fail)++;
        it_cur->second->update_top(it_target->second);
    }
    //更新前十排行榜
    it_cast->second->unicast_state();
    it_target->second->unicast_state();

    ret.hp_percent = it_cast->second->hp_percent;
    ret.score = score_cast;
    logic.unicast(user_->db.uid, ret);

    sc_msg_def::ret_scuffle_battle_t ret_o;
    sp_cast_data->hp_percent = it_cast->second->hp_percent;
    (*sp_cast_data) >> ret_o.target_data;
    ret_o.is_win = !(ret.is_win);
    ret_o.rseed = ret.rseed;
    ret_o.score = score_target;
    ret_o.hp_percent = it_target->second->hp_percent;
    logic.unicast(uid_, ret_o);
    */
}
int sc_scuffle_mgr_t::fuhuo(sp_user_t user_)
{
    if (user_->rmb() < 50)
        return ERROR_SC_NO_YB;

    //判断是否在战斗
    int key = get_key(user_->db.uid);
    auto it_cur = m_scuffle_hm.find(key);
    if( it_cur == m_scuffle_hm.end() )
        return -1;
    auto it_cast = it_cur->second->m_hero_hm.find(user_->db.uid);
    if( it_cast != it_cur->second->m_hero_hm.end() )
    {
        if (it_cast->second->hp_percent >= 1)
            return 1;

        user_->consume_yb(50);
        user_->save_db();
        it_cast->second->hp_percent = 1;
        return SUCCESS;
    }
    return -1; 
}
sp_hero_t sc_scuffle_mgr_t::get_hero(int uid_)
{
    int key = get_key(uid_);
    auto it = m_scuffle_hm.find(key);
    if (it == m_scuffle_hm.end())
        return sp_hero_t();
    auto it_hero = it->second->m_hero_hm.find(uid_);
    if (it_hero == it->second->m_hero_hm.end())
        return sp_hero_t();
    return it_hero->second;
}
