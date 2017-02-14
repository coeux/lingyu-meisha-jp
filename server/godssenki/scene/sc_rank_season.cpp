#include "sc_rank_season.h"
#include "date_helper.h"
#include "sc_message.h"
#include "sc_user.h"
#include "sc_mailinfo.h"

#define LOG "SC_RANK_SEASON"

sc_rank_season_t::sc_rank_season_t()
{
}

    void
sc_rank_season_t::load_user(int32_t uid_, sp_user_t sp_user_)
{
    int season_now = get_cur_season();

    /* 从数据库中获取该玩家当前赛季的信息 */
    sql_result_t res;
    db_RankSeason_t db;
    if (0 == db_RankSeason_t::sync_select_uid(uid_, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        db.uid = uid_;
        db.rank = 63;
        db.score = 0;
        db.season = season_now;
        db.successive_defeat = 0;
        db.max_rank = 63;
        db.last_fight_stamp = 0;

        db_service.async_do((uint64_t)uid_, [](db_RankSeason_t& db_){
                db_.insert();
                }, db);
    }

    user_info_set user_info_;
    user_info_.uid = db.uid;
    user_info_.rank = db.rank;
    user_info_.score = db.score;
    user_info_.season = db.season;
    user_info_.successive_defeat = db.successive_defeat;
    user_info_.max_rank = db.max_rank;
    user_info_.last_fight_stamp = db.last_fight_stamp;

    auto it = user_info_map.find(uid_);
    if (it != user_info_map.end())
        user_info_map.erase(it);
    user_info_map.insert(make_pair(uid_, user_info_));
    it = user_info_map.find(uid_);

    if (it->second.season != season_now)
    {
        season_reward(it->second.uid, it->second.rank, sp_user_);
        reset_user(it->second, season_now);
        save_user(it->second);                
    }
}

//获取玩家的段位
void sc_rank_season_t::get_rank(int32_t uid_, int32_t& rank_)
{
    int season_now = get_cur_season();
    /* 从数据库中获取该玩家当前赛季的信息 */
    sql_result_t res;
    db_RankSeason_t db;
    if (0 == db_RankSeason_t::sync_select_uid(uid_, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        db.uid = uid_;
        db.rank = 63;
        db.score = 0;
        db.season = season_now;
        db.successive_defeat = 0;
        db.max_rank = 63;
        db.last_fight_stamp = 0;

        db_service.async_do((uint64_t)uid_, [](db_RankSeason_t& db_){
                db_.insert();
                }, db);
    }

    rank_ = db.rank;
}

// 返回用户信息
    int32_t
sc_rank_season_t::find_user(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_, int32_t& month_, int32_t& day_, int32_t& hour_)
{
    load_user(uid_, sp_user_);
    auto it = user_info_map.find(uid_);
    if (it == user_info_map.end())
        return ERROR_NO_RANK_SEASON_USER;

    check_active(it->second);

    user_info_.uid = it->second.uid;
    user_info_.rank = it->second.rank;
    user_info_.score = it->second.score;
    user_info_.season = it->second.season;
    user_info_.successive_defeat = it->second.successive_defeat;
    get_cur_season_end_time(month_, day_, hour_);

    return SUCCESS;
}

    int32_t
sc_rank_season_t::win_match(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_)
{
    auto it = user_info_map.find(uid_);
    if (it == user_info_map.end())
    {
        return ERROR_NO_RANK_SEASON_USER;
    }
    /*根据repo表更新用户数据*/
    // 清空连败,增加积分
    auto rp = repo_mgr.rank_season.get(it->second.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", it->second.rank));
        return ERROR_NO_SUCH_RANK;
    }
    it->second.score += rp->win_score;
    it->second.successive_defeat = 0;
    it->second.last_fight_stamp = date_helper.cur_sec();
    // 积分到达升阶点则升段
    if ((it->second.score >= rp->rankup_score) && (it->second.rank != 10))
    {
        it->second.score = 0;
        it->second.rank = rp->win_rank;
        if (rp->win_rank < it->second.max_rank)
        {
            rank_reward(uid_, rp->win_rank, sp_user_);
            it->second.max_rank = rp->win_rank;
        }
    }
    // 王者1500分上限
    if ( it->second.score > 1500 && it->second.rank == 10)
        it->second.score = 1500;

    save_user(it->second);

       

    user_info_.uid = it->second.uid;
    user_info_.rank = it->second.rank;
    user_info_.score = it->second.score;
    user_info_.season = it->second.season;
    user_info_.successive_defeat = it->second.successive_defeat;
    sp_user_->daily_task.on_event(evt_rank_fight);
    sp_user_->reward.update_opentask(open_task_rank_winnumber);
    return SUCCESS;
}

    int32_t
sc_rank_season_t::lose_match(int32_t uid_, user_info_set& user_info_, sp_user_t sp_user_)
{
    auto it = user_info_map.find(uid_);
    if (it == user_info_map.end())
    {
        return ERROR_NO_RANK_SEASON_USER;
    }
    /*根据repo表更新用户数据*/
    // 增加连败 如果到达指定连败数则降段
    auto rp = repo_mgr.rank_season.get(it->second.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", it->second.rank));
        return ERROR_NO_SUCH_RANK;
    }
    it->second.score -= rp->lose_score;
    it->second.successive_defeat ++;
    if ((it->second.successive_defeat >= rp->lose_count) && (rp->lose_count > 0) && (it->second.score < 0))
    {
        auto rp_lose = repo_mgr.rank_season.get(rp->lose_rank);
        if (NULL == rp_lose) 
        {
            logwarn((LOG, "load_repo, rank %d not exists", rp->lose_rank));
            return ERROR_NO_SUCH_RANK;
        }
        it->second.score = rp_lose->rankup_score-rp_lose->win_score*rp->lose_count;
        if (it->second.score < 0)
            it->second.score = 0;
        it->second.rank = rp->lose_rank;
        it->second.successive_defeat = 0;
    }
    if (it->second.score < 0)
        it->second.score = 0;

    it->second.last_fight_stamp = date_helper.cur_sec();
    save_user(it->second);

    user_info_.uid = it->second.uid;
    user_info_.rank = it->second.rank;
    user_info_.score = it->second.score;
    user_info_.season = it->second.season;
    user_info_.successive_defeat = it->second.successive_defeat;
    sp_user_->daily_task.on_event(evt_rank_fight);
    return SUCCESS;
}

/* 段位奖励 */
    void
sc_rank_season_t::rank_reward(int32_t uid_, int32_t r_t, sp_user_t sp_user)
{
    auto rp_rank_reward = repo_mgr.rank_season.get(r_t);
    if (rp_rank_reward != NULL)
    {
        sc_msg_def::nt_bag_change_t nt;
        int total_num = 0;
        auto reward_size = rp_rank_reward->rank_reward.size();
        for (auto i=1;i<reward_size;++i)
        {
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = rp_rank_reward->rank_reward[i][0];
            item_.num = rp_rank_reward->rank_reward[i][1];
            total_num += item_.num;
            nt.items.push_back(item_);
        }
        if (0 >= total_num)
        {
            return;
        }
        string msg = mailinfo.new_mail(mail_rank_season_rankreward, rp_rank_reward->name);
        auto rp_gmail = mailinfo.get_repo(mail_rank_season_rankreward);
        if (rp_gmail != NULL) 
        {
            sp_user->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
        }
    }
}

/* 新赛季 重置用户信息 */
    void 
sc_rank_season_t::reset_user(user_info_set& user_info_, int new_season)
{
    auto rp = repo_mgr.rank_season.get(user_info_.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", user_info_.rank));
        return;
    }
    user_info_.rank = rp->next_season_rank;
    user_info_.score = 0;
    user_info_.season = new_season;
    user_info_.successive_defeat = 0;    
    user_info_.max_rank = rp->next_season_rank;
    user_info_.last_fight_stamp = date_helper.cur_sec();
}

/* 赛季奖励 */
    void
sc_rank_season_t::season_reward(int32_t uid_, int32_t r_t, sp_user_t sp_user)
{
    auto rp_season_reward = repo_mgr.rank_season.get(r_t);
    if (rp_season_reward != NULL) 
    {
        sc_msg_def::nt_bag_change_t nt;
        int total_num = 0;
        auto reward_size = rp_season_reward->reward.size();
        for (auto i=1;i<reward_size;++i)
        {
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = rp_season_reward->reward[i][0];
            item_.num = rp_season_reward->reward[i][1];
            total_num += item_.num;
            nt.items.push_back(item_);
        }
        if (0 >= total_num)
        {
            return;
        }
        string msg = mailinfo.new_mail(mail_rank_season_seasonward, rp_season_reward->name);
        auto rp_gmail = mailinfo.get_repo(mail_rank_season_seasonward);
        if (rp_gmail != NULL) 
        {
            sp_user->gmail.send(rp_gmail->title, rp_gmail->sender, msg,
                    rp_gmail->validtime, nt.items);
        }
    }
}

/* 将用户信息从缓存写入数据库 */
    void
sc_rank_season_t::save_user(user_info_set& user_info_)
{
    db_RankSeason_t db;
    db.uid = user_info_.uid;
    db.rank = user_info_.rank;
    db.score = user_info_.score;
    db.season = user_info_.season;
    db.successive_defeat = user_info_.successive_defeat;
    db.max_rank = user_info_.max_rank;
    db.last_fight_stamp = user_info_.last_fight_stamp;

    db_service.async_do((uint64_t)user_info_.uid, [](db_RankSeason_t& db_){
            db_.update();
            }, db);
}

/* 获取当前赛季 */
    int32_t
sc_rank_season_t::get_cur_season()
{
    // 1453996800 为2016年1月29日0点0分0秒 以后每三周1814400 为一个赛季
    int32_t cur_time = date_helper.cur_sec();
    if (cur_time < 1453996800)
        return 1;
    else
    {
        return int32_t((cur_time - 1453996800)/1814400) + 1;
    }
}

/* 赛季结束时间 */
    void
sc_rank_season_t::get_cur_season_end_time(int32_t& month, int32_t& day, int32_t& hour)
{
    int32_t end_time = 1453996800;
    int32_t cur_time = date_helper.cur_sec();
    for(int i=1; i < 1000; ++i)
    {
        end_time += 1814400;
        if (end_time > cur_time)
            break;
    }
    int32_t year,minute,second;
    date_helper.get_time_by_sec(end_time,year,month,day,hour,minute,second);
}

    void
sc_rank_season_t::check_active(user_info_set& user_info_)
{
    auto rp = repo_mgr.rank_season.get(user_info_.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", user_info_.rank));
        return;
    }

    int day_time = date_helper.offday(user_info_.last_fight_stamp);    
    if ((day_time >= (rp->day_off)) && (rp->day_off > 0))
    {
        int punish_times = int(day_time/(rp->day_off));
        int punish_score = punish_times * rp->day_score;

        // 积分处理
        if (user_info_.score >= punish_score)
        {
            // 不降段 只扣分
            user_info_.score -= punish_score;
        }
        else
        {
            // 降段
            auto rp_lose = repo_mgr.rank_season.get(rp->lose_rank);
            if (rp_lose == NULL)
                return;
            user_info_.score = rp_lose->rankup_score - (punish_score - user_info_.score);
            user_info_.rank = rp->lose_rank;
        }

        // 时间更新
        user_info_.last_fight_stamp += punish_times * (rp->day_off) * 86400;
        save_user(user_info_);
    }
}

/* 计算排位赛战斗胜利和失败的结果 */
int32_t sc_rank_season_t::cal_match_result(int32_t uid_)
{
    
    temporary_match_result match_result_;
    int32_t code = -1;
    code = cal_win_result(uid_, match_result_.win_result);
    if(code != SUCCESS)
        return code;
    code = cal_lose_result(uid_, match_result_.lose_result); 
    if(code != SUCCESS)
        return code;   

    auto it = match_result_map.find(uid_);
    if (it != match_result_map.end())
        match_result_map.erase(it);
    match_result_map.insert(make_pair(uid_, match_result_));

    auto itt = match_result_map.find(uid_);
    if(itt != match_result_map.end())
    {
        save_user(itt->second.lose_result);
    }
    return SUCCESS;
}

int32_t sc_rank_season_t::win_rank_match(int32_t uid_, sp_user_t sp_user_, user_info_set &user_info_)
{
    auto it = match_result_map.find(uid_);
    if(it == match_result_map.end())
        return ERROR_NO_RANK_SEASON_USER;
    //判断是否升段，发放奖励
    auto itt = user_info_map.find(uid_);
    if(itt != user_info_map.end())
    {
        if(it->second.win_result.rank < itt->second.max_rank)
            rank_reward(uid_, it->second.win_result.max_rank, sp_user_);
    }
    save_user(it->second.win_result);
    user_info_ = it->second.win_result;
    sp_user_->daily_task.on_event(evt_rank_fight);
    sp_user_->reward.update_opentask(open_task_rank_winnumber);
    return SUCCESS;
}

int32_t sc_rank_season_t::lose_rank_match(int32_t uid_, sp_user_t sp_user_, user_info_set &user_info_)
{
    auto it = match_result_map.find(uid_);
    if(it == match_result_map.end())
        return ERROR_NO_RANK_SEASON_USER;
    user_info_ = it->second.lose_result;
    sp_user_->daily_task.on_event(evt_rank_fight);
    return SUCCESS;
}

int32_t sc_rank_season_t::cal_win_result(int32_t uid_, user_info_set &win_result_)
{
    //计算胜利的结果
    auto it = user_info_map.find(uid_);
    if (it == user_info_map.end())
    {
        return ERROR_NO_RANK_SEASON_USER;
    }
    /*根据repo表更新用户数据*/
    // 清空连败,增加积分
    auto rp = repo_mgr.rank_season.get(it->second.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", it->second.rank));
        return ERROR_NO_SUCH_RANK;
    }
    win_result_.score =it->second.score + rp->win_score;
    win_result_.successive_defeat = 0;
    win_result_.last_fight_stamp = date_helper.cur_sec();
    win_result_.rank = it->second.rank;
    win_result_.season = it->second.season;
    win_result_.max_rank = it->second.max_rank;
    win_result_.uid = it->second.uid;
    // 积分到达升阶点则升段
    if ((win_result_.score >= rp->rankup_score) && (win_result_.rank != 10))
    {
        win_result_.score = 0;
        win_result_.rank = rp->win_rank;
        if (rp->win_rank < win_result_.max_rank)
        {
            win_result_.max_rank = rp->win_rank;
        }
    }
    // 王者1500分上限
    if ( win_result_.score > 1500 && win_result_.rank == 10)
        win_result_.score = 1500;

    return SUCCESS;
}

int32_t sc_rank_season_t::cal_lose_result(int32_t uid_, user_info_set &lose_result_)
{
    //计算失败结果
    auto it = user_info_map.find(uid_);
    if (it == user_info_map.end())
    {
        return ERROR_NO_RANK_SEASON_USER;
    }
    /*根据repo表更新用户数据*/
    // 增加连败 如果到达指定连败数则降段
    auto rp = repo_mgr.rank_season.get(it->second.rank);
    if (NULL == rp) 
    {
        logwarn((LOG, "load_repo, rank %d not exists", it->second.rank));
        return ERROR_NO_SUCH_RANK;
    }
    lose_result_.score = it->second.score - rp->lose_score;
    lose_result_.successive_defeat = it->second.successive_defeat + 1;
    lose_result_.uid = it->second.uid;
    lose_result_.rank = it->second.rank;
    lose_result_.season = it->second.season;
    lose_result_.max_rank = it->second.max_rank;
    lose_result_.last_fight_stamp = date_helper.cur_sec();
    if ((lose_result_.successive_defeat >= rp->lose_count) && (rp->lose_count > 0) && (lose_result_.score < 0))
    {
        auto rp_lose = repo_mgr.rank_season.get(rp->lose_rank);
        if (NULL == rp_lose) 
        {
            logwarn((LOG, "load_repo, rank %d not exists", rp->lose_rank));
            return ERROR_NO_SUCH_RANK;
        }
        lose_result_.score = rp_lose->rankup_score - rp_lose->win_score*rp->lose_count;
        if (lose_result_.score < 0)
            lose_result_.score = 0;
        lose_result_.rank = rp->lose_rank;
        lose_result_.successive_defeat = 0;
    }
    if (lose_result_.score < 0)
        lose_result_.score = 0;

    return SUCCESS;    
}
