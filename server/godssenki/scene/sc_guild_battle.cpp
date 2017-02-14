#include "sc_guild_battle.h"
#include "date_helper.h"
#include "sc_user.h"
#include "sc_message.h"
#include "sc_gang.h"
#include "sc_cache.h"
#include "sc_logic.h"
#include "sc_mailinfo.h"
#include "sc_statics.h"

#define TIME_HOUR 3600
#define TIME_MINUTE 60
#define TIME_HALF_HOUR 1800
#define TIME_DAY 86400
#define TIME_BEGIN 1461254400
#define TIME_WEEK 604800
#define TIME_THREE_DAY 259200
#define TIME_FOUR_WEEK 2419200

#define LOG "SC_GUILD_BATTLE"

int32_t
get_jpk_gbattle_target_by_uid_pid(int32_t uid_, int32_t pid_[], sc_msg_def::jpk_gbattle_target_t& target_)
{
    if (-1 == uid_)
    {
        target_.uid = -1;
        target_.name = "社团守卫";
        sc_msg_def::jpk_arena_team_info_t role_view;
        role_view.pid = 0;
        role_view.equiplv = 30;
        role_view.resid = 2;
        role_view.level = 30;
        role_view.lovelevel = 0;
        role_view.starnum = 1;
        target_.team_info.push_back(role_view);
        target_.fp = 5000;
        return SUCCESS;
    }
    sp_view_user_t sp_view = view_cache.get_view(uid_, pid_, true);
    if (sp_view != NULL)
    {
        target_.uid = uid_;
        target_.name = sp_view->name;
        int total_fp = 0;
        for(auto it=sp_view->roles.begin(); it!=sp_view->roles.end(); it++)
        {
            sc_msg_def::jpk_arena_team_info_t role_view;
            role_view.pid = it->second.pid;
            role_view.equiplv = sc_user_t::get_equip_level(uid_, it->second.pid);
            if (it->second.pid == 0)
            {
                role_view.resid = it->second.resid;
                role_view.level = it->second.lvl.level;
                role_view.lovelevel = it->second.lvl.lovelevel;

                sql_result_t res_2;
                char tmp_sql[256];
                sprintf(tmp_sql, "select quality from UserInfo where uid=%d;", uid_);
                db_service.sync_select(tmp_sql, res_2);
                if (0 == res_2.affect_row_num())
                {
                    role_view.starnum = 1;
                }else{
                    sql_result_row_t& row = *res_2.get_row_at(0);
                    role_view.starnum = (int)std::atoi(row[0].c_str());
                }
            }
            else
            {
                sql_result_t res_2;
                char tmp_sql[256];
                sprintf(tmp_sql, "select grade,lovelevel,quality,resid  from Partner where uid=%d and pid=%d;", uid_, it->second.pid);
                db_service.sync_select(tmp_sql, res_2);
                if (0 == res_2.affect_row_num())
                {
                    role_view.level = 0;
                    role_view.lovelevel = 0;
                    role_view.starnum = 1;
                    role_view.resid = 0;
                }
                else
                {
                    sql_result_row_t& row = *res_2.get_row_at(0);
                    role_view.level = (int)std::atoi(row[0].c_str());
                    role_view.lovelevel = (int)std::atoi(row[1].c_str());
                    role_view.starnum = (int)std::atoi(row[2].c_str());
                    role_view.resid = (int)std::atoi(row[3].c_str());
                }
            }
            target_.team_info.push_back(role_view);
            total_fp += it->second.pro.fp;
        }
        target_.fp = total_fp;
        return SUCCESS;
    }
    return ERROR_NO_SUCH_USER;
}

sc_guild_battle_t::sc_guild_battle_t()
:state_gb(0),has_sign_up(false),during_arrange(false),has_arrange(false),during_fight(false),during_summary(false),battle_over(true)
{
}

void
sc_guild_battle_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load guild battle ..."));
    for (int32_t host : hostnums_)
    {
        hosts.push_back(host);
    }

    load_guild_name();
    load_g_opponent();
    load_guild_info();
    load_battle_log();
    update_cur_season();
}

void
sc_guild_battle_t::begin_battle()
{
    if (!battle_over)
        return;
    battle_over = false;
    reset_guild_info();
    update_cur_season();
}

void
sc_guild_battle_t::pre_arrange()
{
    if (has_sign_up)
        return;
    has_sign_up = true;
    guild_match();
    arrange_user_list.clear();
}

void
sc_guild_battle_t::in_arrange()
{
    if (during_arrange)
        return;
    during_arrange = true;
    load_guild_info();
    load_arrange_defence_info();
    load_arrange_building_info();
    load_arrange_partner();
}

void
sc_guild_battle_t::pre_fight()
{
    if (has_arrange)
        return;
    has_arrange = true;
    position_adjust();
    building_level_adjust();
    user_join_qualifications();
    add_robot();
}

void
sc_guild_battle_t::in_fight()
{
    if (during_fight)
        return;
    during_fight = true;
    load_guild_info();
    load_battle_log();
    load_fight_partner();
    init_fight_state();
    load_fight_building_info();
    load_fight_user();
}

void
sc_guild_battle_t::after_fight()
{
    if (during_summary)
        return;
    summary_turn();
    send_reward();
    during_summary = true;
    battle_over = true;
}

/*
void
sc_guild_battle_t::load_db_user()
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT uid, anger, attack_win, attack_lose, defence_win, defence_lose, score, last_fight_time, rest_times, have_buy_times, ggid FROM GuildBattleUser");
    db_service.sync_select(sql, res);

    if (0 == res.affect_row_num())
    {
        return;
    }
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        fight_user_info info;
        info.uid = (int32_t)std::atoi(row_[0].c_str());
        info.anger = (int32_t)std::atoi(row_[1].c_str());
        info.attack_win = (int32_t)std::atoi(row_[2].c_str());
        info.attack_lose = (int32_t)std::atoi(row_[3].c_str());
        info.defence_win =  (int32_t)std::atoi(row_[4].c_str());
        info.defence_lose = (int32_t)std::atoi(row_[5].c_str());
        info.score = (int32_t)std::atoi(row_[6].c_str());
        info.last_fight_time = (int32_t)std::atoi(row_[7].c_str());
        info.rest_times = (int32_t)std::atoi(row_[8].c_str());
        info.have_buy_times = (int32_t)std::atoi(row_[9].c_str());
        info.guild_id = (int32_t)std::atoi(row_[10].c_str());

        fight_user_info_list.insert(make_pair(info.uid, info));
    }
}
*/

void
sc_guild_battle_t::update()
{
    int32_t cur_day = date_helper.cur_dayofweek();
    int32_t cur_sec = date_helper.cur_sec();
    int32_t cur_0_stmp = date_helper.cur_0_stmp();
    bool can_open = true;
    /*
    for (int32_t host : hosts)
    {
        if (host == 1 || host == 91 || host == 101 || host == 102 || host == 103 || host == 104 || host == 105)
        {
            can_open = true;
            break;
        }
    }
    */
    if (cur_sec < TIME_BEGIN)
        can_open = false;
    
    if (!can_open)
        return;
    update_fights(cur_sec);
 /*   
    if (true)
    {
        int32_t time_1 = 16;
        int32_t time_2 = 40;
        int32_t begin_time = time_1*TIME_HOUR + time_2*60;
        if (cur_sec <cur_0_stmp+begin_time+0*60)
        {
            begin_battle();
            state_gb = 10;
        }
        else if (cur_sec < cur_0_stmp+begin_time+5*60)
        {
            state_gb = 1;
        }
        else if (cur_sec < cur_0_stmp+begin_time+6*60)
        {
            pre_arrange();
            state_gb = 11;
        }
        else if (cur_sec < cur_0_stmp+begin_time+30*60)
        {
            in_arrange();
            state_gb = 2;
        }
        else if (cur_sec < cur_0_stmp+begin_time+31*60)
        {
            pre_fight();
            state_gb = 12;
        }
        else if (cur_sec < cur_0_stmp+begin_time+365*60)
        {
            in_fight();
            state_gb = 3;
        }
        else if (cur_sec < cur_0_stmp+begin_time+70*60)
        {
            after_fight();
            state_gb = 13;
        }
        return;
    }
*/
    if (cur_day == 1)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            begin_battle();
            state_gb = 10;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            state_gb = 1;
        }
        else
        {
            pre_arrange();
            state_gb = 11;
        }
    }
    else if (cur_day == 2)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            pre_arrange();
            state_gb = 11;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            in_arrange();
            state_gb = 2;
        }
        else
        {
            pre_fight();
            state_gb = 12;
        }
    }
    else if (cur_day == 3)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            pre_fight();
            state_gb = 12;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            in_fight();
            state_gb = 3;
        }
        else
        {
            after_fight();
            state_gb = 13;
        }
    }
    else if (cur_day == 4)
    {
    }
    else if (cur_day == 5)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            begin_battle();
            state_gb = 10;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            state_gb = 1;
        }
        else
        {
            pre_arrange();
            state_gb = 11;
        }
    }
    else if (cur_day == 6)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            pre_arrange();
            state_gb = 11;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            in_arrange();
            state_gb = 2;
        }
        else
        {
            pre_fight();
            state_gb = 12;
        }
    }
    else if (cur_day == 0)
    {
        if (cur_sec < cur_0_stmp+10*TIME_HOUR)
        {
            pre_fight();
            state_gb = 12;
        }
        else if (cur_sec < cur_0_stmp+23*TIME_HOUR)
        {
            in_fight();
            state_gb = 3;
        }
        else
        {
            after_fight();
            state_gb = 13;
        }
    }
}

void
sc_guild_battle_t::update_cur_season()
{
    // 每周两场社团战 八场社团战 四周 一个大赛季
    int32_t cur_time = date_helper.cur_sec();
    /*
    int32_t cur_sec = cur_time - date_helper.cur_0_stmp();
    if (cur_sec < 21*3600)
        cur_season = 3;
    else
        cur_season = 4;
    if (true)
        return; 
    */
    if (cur_time < TIME_BEGIN)
    {
        cur_season = 1;
        cur_turn = 1;
    }
    else
    {
        int32_t extra_time = cur_time - TIME_BEGIN;
        cur_season = extra_time/TIME_FOUR_WEEK+1;
        extra_time -= (cur_season-1)*TIME_FOUR_WEEK;
        int32_t week = extra_time/TIME_WEEK+1;
        extra_time -= (week-1)*TIME_WEEK;
        if (extra_time <= TIME_THREE_DAY)
            cur_turn = week*2-1;
        else
            cur_turn = week*2;
    }
}

void
sc_guild_battle_t::load_g_opponent()
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, opponent, hostnum FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);
    
    if (0 == res.affect_row_num())
    {
        return;
    }

    int32_t ggid;
    int32_t opponent;
    int32_t hostnum;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        ggid = (int32_t)std::atoi(row_[0].c_str());
        hostnum = (int32_t)std::atoi(row_[2].c_str());
        opponent = (int32_t)std::atoi(row_[1].c_str());

        if (g_opponent_list.find(ggid) == g_opponent_list.end())
        {
            g_opponent_list.insert(make_pair(ggid, opponent));
        }
        if (opponent == -1)
            g_opponent_list.insert(make_pair(opponent, ggid));
    }
}

void
sc_guild_battle_t::update_fights(int32_t cur_sec_)
{
    for (auto it_gg=fighting_list.begin();it_gg!=fighting_list.end();++it_gg)
    {
        for (auto it_building=it_gg->second.begin();it_building!=it_gg->second.end();++it_building)
        {
            for (auto it_pos=it_building->second.begin();it_pos!=it_building->second.end();)
            {
                if (it_pos->second + 150 <= cur_sec_)
                {
                    //切换状态
                    set_pos_state(it_gg->first, it_building->first, it_pos->first, 1);
                    it_pos = it_building->second.erase(it_pos);
                }
                else
                    ++it_pos;
            }
        }
    }
}

void
sc_guild_battle_t::load_arrange_partner()
{
    arrange_partner_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT uid, pid FROM GuildBattlePartner");
    db_service.sync_select(sql, res);
    
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t uid = (int32_t)std::atoi(row_[0].c_str());
        int32_t pid = (int32_t)std::atoi(row_[1].c_str());
        auto it_u = arrange_partner_list.find(uid);
        if (it_u == arrange_partner_list.end())
        {
            unordered_map<int32_t, int32_t> partners;
            arrange_partner_list.insert(make_pair(uid, partners));
            it_u = arrange_partner_list.find(uid);
        }
        it_u->second.insert(make_pair(pid, 1));
    }
}

void
sc_guild_battle_t::save_arrange_partner(int32_t uid_, int32_t pid_[], bool is_save_)
{
    auto it_u = arrange_partner_list.find(uid_);
    if (it_u == arrange_partner_list.end())
    {
        unordered_map<int32_t, int32_t> partners;
        arrange_partner_list.insert(make_pair(uid_, partners));
        it_u = arrange_partner_list.find(uid_);
    }
    if (is_save_)
    {
        string m_sql = "INSERT IGNORE INTO `GuildBattlePartner` (`uid`, `pid`, `hp` ) VALUES ";
        for (int32_t i=0; i<5; ++i)
        {
            if (pid_[i] != -1)
            {
                it_u->second.insert(make_pair(pid_[i], 1));
                char tmp_sql[256];
                sprintf(tmp_sql, "(%d, %d, 1),", uid_, pid_[i]);
                m_sql += string(tmp_sql);
            }
        }
        m_sql = m_sql.substr(0, m_sql.length()-1);
    
        db_service.async_do((uint64_t)uid_, [](string& sql_){
            db_service.async_execute(sql_);
        }, m_sql);
        return;
    }
    else
    {
        string m_sql = "DELETE FROM `GuildBattlePartner` WHERE uid = ";
        char tmp_sql[256];
        sprintf(tmp_sql, "%d AND pid in(", uid_);
        m_sql += string(tmp_sql);
        for (int32_t i=0; i<5; ++i)
        {
            if (pid_[i] != -1)
            {
                it_u->second.erase(pid_[i]);
                char tmp_sql[256];
                sprintf(tmp_sql, "%d, ", pid_);
                m_sql += string(tmp_sql);
            }
        }
        m_sql = m_sql.substr(0, m_sql.length()-2);
        m_sql += ")";

        db_service.async_do((uint64_t)uid_, [](string& sql_){
            db_service.async_execute(sql_);
        }, m_sql);
        return;
    }
}

void
sc_guild_battle_t::load_fight_partner()
{
    fight_partner_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT uid, pid, hp FROM GuildBattlePartner");
    db_service.sync_select(sql, res);
    
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t uid = (int32_t)std::atoi(row_[0].c_str());
        int32_t pid = (int32_t)std::atoi(row_[1].c_str());
        float hp = (float)std::atof(row_[2].c_str());
        auto it_u = fight_partner_list.find(uid);
        if (it_u == fight_partner_list.end())
        {
            unordered_map<int32_t, float> partners;
            fight_partner_list.insert(make_pair(uid, partners));
            it_u = fight_partner_list.find(uid);
        }
        it_u->second.insert(make_pair(pid, hp));
    }
}

void
sc_guild_battle_t::update_fight_partner(int32_t uid_, map<int32_t, float>& partners_)
{
    auto it_u = fight_partner_list.find(uid_);
    if (it_u == fight_partner_list.end())
        return;

    for (auto it_p=partners_.begin(); it_p!=partners_.end(); ++it_p)
    {
        auto it_pl=it_u->second.find(it_p->first);
        if (it_pl==it_u->second.end())
        {
            it_u->second.insert(make_pair(it_p->first, it_p->first));
        }
        else
        {
            it_pl->second = it_p->second;
        }
    }

    // 写入数据库
    string m_sql = "UPDATE GuildBattlePartner SET hp = (case ";
    for (auto it_p=partners_.begin(); it_p!=partners_.end(); ++it_p)
    {
        char tmp_sql[256];
        sprintf(tmp_sql, "WHEN pid = %d THEN %f ", it_p->first, it_p->second);
        m_sql += string(tmp_sql);

    }
    char tmp_sql[256];
    sprintf(tmp_sql, "WHERE uid = %d", uid_);
    m_sql += ("ELSE hp END) " + string(tmp_sql));
    
    db_service.async_do((uint64_t)uid_, [](string& sql_){
        db_service.async_execute(sql_);
    }, m_sql);
    return;
}

int32_t
sc_guild_battle_t::get_fight_partner(int32_t uid_, map<int32_t, float>& partners_)
{
    bool get_all = (partners_.size() == 0);
    auto it_u = fight_partner_list.find(uid_);
    if (it_u == fight_partner_list.end())
        return ERROR_NO_SUCH_USER;

    if (get_all)
    {
        partners_.insert(it_u->second.begin(), it_u->second.end());
    }
    else
    {
        for (auto it_p=partners_.begin(); it_p!=partners_.end(); ++it_p)
        {
            auto it_pl=it_u->second.find(it_p->first);
            if (it_pl==it_u->second.end())
            {
                it_p->second = 0;
            }
            else
            {
                it_p->second = it_pl->second;
            }
        }        
    }
    return SUCCESS;
}

void
sc_guild_battle_t::load_guild_info()
{
    fight_guild_info_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum, score, opponent, state, total_score, win, lose, is_win, sign_time FROM GuildBattleInfo");
    db_service.sync_select(sql, res);
    
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        fight_guild_info info;
        sql_result_row_t& row_ = *res.get_row_at(i);
        info.guild_id = (int32_t)std::atoi(row_[0].c_str());
        int32_t code = get_guild_name(info.guild_id, info.name);
        if (code != SUCCESS)
            info.name = "社团守卫";
        info.host = (int32_t)std::atoi(row_[1].c_str());
        info.score = (int32_t)std::atoi(row_[2].c_str());
        info.add_score = 0;
        info.opponent = (int32_t)std::atoi(row_[3].c_str());
        info.state = (int32_t)std::atoi(row_[4].c_str());
        info.total_score = (int32_t)std::atoi(row_[5].c_str());
        info.win = (int32_t)std::atoi(row_[6].c_str());
        info.lose = (int32_t)std::atoi(row_[7].c_str());
        info.is_win = (int32_t)std::atoi(row_[8].c_str());
        info.sign_time = (int32_t)std::atoi(row_[9].c_str());
        fight_guild_info_list.insert(make_pair(info.guild_id, info));
    }
}

void
sc_guild_battle_t::summary_turn()
{
    unordered_map<int32_t, int32_t> gg_list;
    get_cur_host_guilds(gg_list);
    string str_gg;
    for (auto it=gg_list.begin(); it!= gg_list.end(); ++it)
    {
        str_gg.append(std::to_string(it->first)+",");
    }
    str_gg = str_gg.substr(0, str_gg.length()-1);

    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum, score, opponent, state, total_score, win, lose, is_win FROM GuildBattleInfo WHERE ggid in (%s)", str_gg.c_str());
    db_service.sync_select(sql, res);

    if (0 == res.affect_row_num())
    {
        return;
    }

    unordered_map<int32_t, fight_guild_info> summary_guild_info_list;
    
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        fight_guild_info info;
        sql_result_row_t& row_ = *res.get_row_at(i);
        info.guild_id = (int32_t)std::atoi(row_[0].c_str());
        info.host = (int32_t)std::atoi(row_[1].c_str());
        info.score = (int32_t)std::atoi(row_[2].c_str());
        info.opponent = (int32_t)std::atoi(row_[3].c_str());
        info.state = (int32_t)std::atoi(row_[4].c_str());
        info.total_score = (int32_t)std::atoi(row_[5].c_str());
        info.win = (int32_t)std::atoi(row_[6].c_str());
        info.lose = (int32_t)std::atoi(row_[7].c_str());
        info.is_win = (int32_t)std::atoi(row_[8].c_str());
        summary_guild_info_list.insert(make_pair(info.guild_id, info));
    }

    for (auto it_g=summary_guild_info_list.begin(); it_g!=summary_guild_info_list.end(); ++it_g)
    {
        if (it_g->second.is_win == 1)
        {
            it_g->second.win++;
        }
        else if(it_g->second.is_win == 0)
        {
            it_g->second.lose++;
        }
        if (it_g->second.opponent != 0)
        {
            it_g->second.total_score += it_g->second.score;
            char sql_char[256];
            sprintf(sql_char, "UPDATE `GuildBattleInfo` SET total_score=%d, score=%d, is_win=%d, win=%d, lose=%d WHERE ggid=%d", it_g->second.total_score, it_g->second.score, it_g->second.is_win, it_g->second.win, it_g->second.lose, it_g->first);
            string sql=string(sql_char);
            logerror((LOG, "%s", sql.c_str()));
            db_service.sync_execute(sql);
        }
    }
}

void
sc_guild_battle_t::load_battle_log()
{
    fight_info_map.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, attack_uid, defence_uid, win_count, is_win FROM GuildBattleLog");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t ggid = (int32_t)std::atoi(row_[0].c_str());
        int32_t attacker_uid = (int32_t)std::atoi(row_[1].c_str());
        int32_t defencer_uid = (int32_t)std::atoi(row_[2].c_str());
        int32_t win_count = (int32_t)std::atoi(row_[3].c_str());
        int32_t is_win = (int32_t)std::atoi(row_[4].c_str());
        fight_info info_;
        info_.stamp = 0;
        info_.attack_name = get_name(attacker_uid);
        info_.defence_name = get_name(defencer_uid);
        info_.win_count = win_count;
        info_.state = is_win;
        info_.attacker_uid = attacker_uid;
        info_.defencer_uid = defencer_uid;
        info_.building_id = 1;
        info_.position_id = 1;
        add_battle_log(ggid, info_);
    }
}

void
sc_guild_battle_t::add_guild_score(int32_t guild_id_, int32_t score_)
{
    auto it_g = fight_guild_info_list.find(guild_id_);
    if (it_g == fight_guild_info_list.end())
        return;

    it_g->second.add_score = score_;
    save_guild_score(guild_id_);
}

void
sc_guild_battle_t::add_guild_score_e(int32_t guild_id_, int32_t score_)
{
    auto it_o = g_opponent_list.find(guild_id_);
    if (it_o == g_opponent_list.end())
        return;

    if (it_o->second == -1)
        return;

    add_guild_score(it_o->second, score_);
}

void
sc_guild_battle_t::save_guild_score(int32_t guild_id_)
{
    if (guild_id_ == -1)
        return;
    auto it_g = fight_guild_info_list.find(guild_id_);
    if (it_g == fight_guild_info_list.end())
        return;

    fight_guild_info& info = it_g->second;
    char sql_sel[256];
    sql_result_t res;
    sprintf(sql_sel, "SELECT score FROM GuildBattleInfo WHERE ggid=%d", guild_id_);
    db_service.sync_select(sql_sel, res);
    sql_result_row_t& row_ = *res.get_row_at(0);
    int32_t old_score = (int32_t)std::atoi(row_[0].c_str());

    int32_t new_score = info.add_score+old_score;
    info.score = new_score;
    
    char sql_char[256];
    sprintf(sql_char, "UPDATE `GuildBattleInfo` SET score=%d WHERE ggid=%d", info.score, info.guild_id);
    string sql=string(sql_char);
    db_service.sync_execute(sql);
    
    auto it_o = g_opponent_list.find(guild_id_);
    if (it_o == g_opponent_list.end())
        return;

    if (it_o->second == -1)
        return;

    update_guild_opponent_score(it_o->second);
}

void
sc_guild_battle_t::save_guild_info(int32_t guild_id_)
{
    if (guild_id_ == -1)
        return;
    auto it_g = fight_guild_info_list.find(guild_id_);
    if (it_g == fight_guild_info_list.end())
        return;

    fight_guild_info& info = it_g->second;
    char sql_char[256];
    sprintf(sql_char, "UPDATE `GuildBattleInfo` SET total_score=%d, score=%d, is_win=%d, win=%d, lose=%d WHERE ggid=%d", info.total_score, info.score, info.is_win, info.win, info.lose, guild_id_);
    string sql=string(sql_char);
    //cout << sql << endl;
    db_service.sync_execute(sql);
}

void
sc_guild_battle_t::get_guild_score(int32_t guild_id_, int32_t& score_)
{
    auto it_g = fight_guild_info_list.find(guild_id_);
    if (it_g == fight_guild_info_list.end())
    {
        score_ = 0;
    }
    else
    {
        score_ = it_g->second.score;
    }
}

void
sc_guild_battle_t::get_opponent_guild_score(int32_t guild_id_, int32_t& score_)
{
    auto it_o = g_opponent_list.find(guild_id_);
    if (it_o == g_opponent_list.end())
    {
        score_ = 0;
        return;
    }

    get_guild_score(it_o->second, score_);
}

void
sc_guild_battle_t::save_user_info(int32_t uid_, string update_str)
{
    if (uid_ == -1)
        return;
    auto it_user=fight_user_info_list.find(uid_);
    if (it_user==fight_user_info_list.end())
        return;

    fight_user_info& info = it_user->second;
    string update_string="UPDATE `GuildBattleUser` SET ";;
    char sql_char[256];
    sprintf(sql_char, " WHERE uid=%d", uid_);
    string sql=update_string+update_str+string(sql_char);
    db_service.async_do((uint64_t)uid_, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void
sc_guild_battle_t::add_user_score(int32_t uid_, int32_t score_)
{
    auto it_u = fight_user_info_list.find(uid_);
    if (it_u == fight_user_info_list.end())
        return;
    it_u->second.add_score = score_;

    fight_user_info& info = it_u->second;
    char sql_sel[256];
    sql_result_t res;
    sprintf(sql_sel, "SELECT score FROM GuildBattleUser WHERE uid=%d", uid_);
    db_service.sync_select(sql_sel, res);
    sql_result_row_t& row_ = *res.get_row_at(0);
    int32_t old_score = (int32_t)std::atoi(row_[0].c_str());

    int32_t new_score = info.add_score+old_score;
    info.score = new_score;
    
    char sql_char[256];
    sprintf(sql_char, "UPDATE `GuildBattleUser` SET score=%d WHERE uid=%d", info.score, uid_);
    string sql=string(sql_char);
    db_service.async_do((uint64_t)uid_, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void
sc_guild_battle_t::add_fight(int32_t ggid_, int32_t building_id_, int32_t building_pos_)
{
    int32_t cur_sec = date_helper.cur_sec();
    
    auto it_gg = fighting_list.find(ggid_);
    if (it_gg == fighting_list.end())
    {
        unordered_map<int32_t, unordered_map<int32_t, int32_t>> new_gg;
        fighting_list.insert(make_pair(ggid_, new_gg));
        it_gg = fighting_list.find(ggid_);
    }

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
    {
        unordered_map<int32_t, int32_t> new_building;
        it_gg->second.insert(make_pair(building_id_, new_building));
        it_building = it_gg->second.find(building_id_);
    }

    it_building->second.insert(make_pair(building_pos_, cur_sec));
}

void
sc_guild_battle_t::del_fight(int32_t ggid_, int32_t building_id_, int32_t building_pos_)
{
    auto it_gg = fighting_list.find(ggid_);
    if (it_gg == fighting_list.end())
    {
        return;
    }

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
    {
        return;
    }

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
    {
        return;
    }

    it_building->second.erase(it_pos);
}


void
sc_guild_battle_t::guild_match()
{
    g_opponent_list.clear();
    /* 从服务器读取所有报名公会
     * 排列顺序按照：
     * 1. 积分          a > b
     * 2. 公会id        a < b
     * 排列并匹配以后，按照 1-2 3-4 ... 的方式匹配公会
     * 未匹配到的公会匹配-1 表示轮空
     * 匹配完成以后，将自己服务器的公会更新匹配信息
     */
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, total_score, hostnum, sign_time FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);

    int32_t ggid;
    int32_t score;
    int32_t host;
    int32_t sign_time;

    unordered_map<int32_t, guild_info> g_map;
    vector<int32_t> g_vector;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        ggid = (int32_t)std::atoi(row_[0].c_str());
        score = (int32_t)std::atoi(row_[1].c_str());
        host = (int32_t)std::atoi(row_[2].c_str());
        sign_time = (int32_t)std::atoi(row_[3].c_str());

        guild_info g_info;
        g_info.guild_id = ggid;
        g_info.score = score;
        g_info.host = host;
        g_info.opponent = 0;
        g_info.sign_time = sign_time;
        g_info.in_cur_host = false;

        for (int32_t it_host : hosts)
        {
            if (it_host == host)
            {
                g_info.in_cur_host = true;
                break;
            }
        }

        g_map.insert(make_pair(ggid,g_info));
        g_vector.push_back(ggid);
    }

    // 排序 匹配对手
    std::sort(g_vector.begin(), g_vector.end(), [&](const int32_t& gg_a, const int32_t& gg_b)
    {
        int32_t score_a, score_b;
        score_a = g_map.find(gg_a)->second.score;
        score_b = g_map.find(gg_b)->second.score;
        int32_t sign_time_a, sign_time_b;
        sign_time_a = g_map.find(gg_a)->second.sign_time;
        sign_time_b = g_map.find(gg_b)->second.sign_time;
        if (score_a > score_b)
        {
            return true;
        }
        if (score_a < score_b)
        {
            return false;
        }
        return (sign_time_a < sign_time_b);
    });

    for (size_t i=0;i < g_vector.size(); ++i)
    {
        auto it_gg = g_map.find(g_vector[i]);
        if(i % 2 == 0)
        {
            if (i+1 < g_vector.size())
            {
                it_gg->second.opponent = g_vector[i+1];
            }
            else
            {
                it_gg->second.opponent = -1;
            }
        }
        else
        {
            it_gg->second.opponent = g_vector[i-1];
        }
    }
    
    // 将对手写入数据库
    string m_sql = "UPDATE GuildBattleInfo SET opponent = (case ";
    int sum_update = 0;
    for (auto it = g_map.begin(); it != g_map.end(); ++it)
    {
        g_opponent_list.insert(make_pair(it->second.guild_id, it->second.opponent));
        if (it->second.in_cur_host)
        {
            sum_update++;
            char tmp_sql[256];
            sprintf(tmp_sql, "WHEN ggid = %d THEN %d ", it->second.guild_id, it->second.opponent);
            m_sql += string(tmp_sql);
        }
    }
    m_sql += "ELSE opponent END)";
    if (sum_update > 0)
    {
        db_service.sync_execute(m_sql);
    }
}

void
sc_guild_battle_t::position_adjust()
{
    unordered_map<int32_t, int32_t> gg_list;
    get_cur_host_guilds(gg_list);
    string str_gg;
    for (auto it=gg_list.begin(); it!= gg_list.end(); ++it)
    {
        str_gg.append(std::to_string(it->first)+",");
    }
    str_gg = str_gg.substr(0, str_gg.length()-1);

    char sql_pos[256];
    sql_result_t res_pos;
    sprintf(sql_pos, "SELECT ggid, building_id, building_pos FROM GuildBattleDefenceInfo WHERE ggid in (%s)", str_gg.c_str());
    db_service.sync_select(sql_pos, res_pos);

    if (0 == res_pos.affect_row_num())
    {
        return;
    }

    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t,int32_t>>> pos_list;
    int32_t gg_id, building_id, building_pos;
    for (size_t i=0;i<res_pos.affect_row_num();++i)
    {
        if (res_pos.get_row_at(i) == NULL)
        {
            continue;
        }

        sql_result_row_t& row_ = *res_pos.get_row_at(i);
        gg_id = (int32_t)std::atoi(row_[0].c_str());
        building_id = (int32_t)std::atoi(row_[1].c_str());
        building_pos = (int32_t)std::atoi(row_[2].c_str());

        auto it_gg = pos_list.find(gg_id);
        if (it_gg == pos_list.end())
        {
            unordered_map<int32_t, unordered_map<int32_t,int32_t>> new_gg;
            unordered_map<int32_t, int32_t> new_building;
            new_building.insert(make_pair(building_pos,1));
            new_gg.insert(make_pair(building_id, new_building));
            pos_list.insert(make_pair(gg_id, new_gg));
        }
        else
        {
            auto it_building = it_gg->second.find(building_id);
            if (it_building == it_gg->second.end())
            {
                unordered_map<int32_t, int32_t> new_building;
                new_building.insert(make_pair(building_pos,1));
                it_gg->second.insert(make_pair(building_id, new_building));
            }
            else
            {
                it_building->second.insert(make_pair(building_pos,1));
            }
        }
    }

    string m_sql = "UPDATE GuildBattleDefenceInfo SET building_pos = (case ";
    int sum_update = 0;
    for (auto it_gg = pos_list.begin(); it_gg != pos_list.end(); ++it_gg)
    {
        for (auto it_building = it_gg->second.begin(); it_building != it_gg->second.end(); ++it_building)
        {
            vector<int32_t> sort_pos;
            for (auto it_pos = it_building->second.begin(); it_pos != it_building->second.end(); ++it_pos)
            {
                sort_pos.push_back(it_pos->first);
            }
            std::sort(sort_pos.begin(), sort_pos.end());
            for (size_t i=0; i<sort_pos.size(); ++i)
            {
                auto it_map = it_building->second.find(sort_pos[i]);
                if (it_map == it_building->second.end())
                    continue;
                it_map->second = i+1;
            }
            for (auto it_pos = it_building->second.begin(); it_pos != it_building->second.end(); ++it_pos)
            {
                ++sum_update;
                char tmp_sql[256];
                sprintf(tmp_sql, "WHEN ggid = %d AND building_id = %d AND building_pos = %d THEN %d ", it_gg->first, it_building->first, it_pos->first, it_pos->second);
                m_sql += string(tmp_sql);
            }
        }
    }
    m_sql += "ELSE building_pos END)";
    if (sum_update > 0)
    {
        db_service.sync_execute(m_sql);
    }
}

void
sc_guild_battle_t::building_level_adjust()
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);
    
    if (0 == res.affect_row_num())
    {
        return;
    }

    int32_t ggid;
    int32_t hostnum;
    unordered_map<int32_t, int32_t> gg_list;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        ggid = (int32_t)std::atoi(row_[0].c_str());
        hostnum = (int32_t)std::atoi(row_[1].c_str());

        for (int32_t it_host : hosts)
        {
            if (it_host == hostnum)
            {
                if (gg_list.find(ggid) == gg_list.end())
                    gg_list.insert(make_pair(ggid, 1));
                break;
            }
        }
    }
    gg_list.insert(make_pair(-1,1));

    vector<int32_t> building_list;
    for (auto it=repo_mgr.guild_battle.begin(); it!=repo_mgr.guild_battle.end(); ++it)
    {
        building_list.push_back(it->second.id);
    }

    string m_sql = "INSERT IGNORE INTO `GuildBattleBuildingInfo` (`ggid`, `building_id`, `level` ) VALUES ";
    for (auto it=gg_list.begin(); it!=gg_list.end(); ++it)
    {
        for(size_t i=0; i<building_list.size(); ++i)
        {
            char tmp_sql[256];
            sprintf(tmp_sql, "(%d, %d, 1),", it->first, building_list[i]);
            m_sql += string(tmp_sql);
        }
    }
    m_sql = m_sql.substr(0, m_sql.length()-1);

    db_service.sync_execute(m_sql);
    return;
}

void
sc_guild_battle_t::user_join_qualifications()
{
    unordered_map<int32_t, int32_t> gg_list;
    get_cur_host_guilds(gg_list);
    string str_gg;
    for (auto it=gg_list.begin(); it!= gg_list.end(); ++it)
    {
        str_gg.append(std::to_string(it->first)+",");
    }
    str_gg = str_gg.substr(0, str_gg.length()-1);

    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT uid FROM GuildBattleDefenceInfo WHERE ggid in (%s)", str_gg.c_str());
    db_service.sync_select(sql, res);

    if (0 == res.affect_row_num())
    {
        return;
    }

    unordered_map<int32_t, int32_t> user_list;
    string m_sql = "UPDATE GuildBattleUser SET state=1 WHERE uid in (";
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t uid = (int32_t)std::atoi(row_[0].c_str());
        
        auto it_u = user_list.find(uid);
        if (it_u == user_list.end())
        {
            user_list.insert(make_pair(uid, 1));
            if (uid != -1)
            {
                char tmp_sql[256];
                sprintf(tmp_sql, "%d, ", uid);
                m_sql += string(tmp_sql);
            }
        }
    }
    m_sql = m_sql.substr(0, m_sql.length()-2);
    m_sql += ")";
    db_service.sync_execute(m_sql);
}

void
sc_guild_battle_t::add_robot()
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);
    
    if (0 == res.affect_row_num())
    {
        return;
    }

    int32_t ggid;
    int32_t hostnum;
    unordered_map<int32_t, int32_t> gg_list;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        ggid = (int32_t)std::atoi(row_[0].c_str());
        hostnum = (int32_t)std::atoi(row_[1].c_str());

        for (int32_t it_host : hosts)
        {
            if (it_host == hostnum)
            {
                if (gg_list.find(ggid) == gg_list.end())
                    gg_list.insert(make_pair(ggid, 1));
                break;
            }
        }
    }
    gg_list.insert(make_pair(-1,1));

    vector<int32_t> building_list;
    for (auto it=repo_mgr.guild_battle.begin(); it!=repo_mgr.guild_battle.end(); ++it)
    {
        building_list.push_back(it->second.id);
    }


    string view_data = "{\"uid\":-1,\"name\":\"社团守卫\",\"rank\":30,\"lv\":30,\"fp\":2333,\"viplevel\":1,\"roles\":{\"1\":{\"uid\":-1,\"pid\":0,\"resid\":2,\"skls\":[[1,0,1],[2,0,1],[3,0,1],[4,0,1],[5,0,1],[6,0,1],[7,0,1],[8,0,1]],\"pro\":[555,274,487,514,1583,0,0,0,4764,0,0,0,0,0.85,0.96,0.85,0.96,0.72,1,0.6,50,0,0,0,0,0,0,0,0,0,0],\"lvl\":[30,0],\"wid\":-1}},\"combo_pro\":{\"combo_d_down\":0,\"combo_r_down\":0,\"combo_d_up\":0,\"combo_r_up\":0,\"combo_anger\":{\"50\":0}}}";
    string m_sql = "INSERT IGNORE INTO `GuildBattleDefenceInfo` (`ggid`, `building_id`, `building_pos`, `uid`, `hp1`, `hp2`, `hp3`, `hp4`, `hp5`, `pid1`, `pid2`, `pid3`, `pid4`, `pid5`, `view_data`, `state`, `fp`) VALUES ";
    for (auto it=gg_list.begin(); it!=gg_list.end(); ++it)
    {
        for(size_t i=0; i<building_list.size(); ++i)
        {
            char tmp_sql[1024];
            sprintf(tmp_sql, "(%d, %d, 1, -1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -1, \'", it->first, building_list[i]);
            string str_buff = string(tmp_sql)+view_data+"\', 0, 5000),";
            m_sql += str_buff;
        }
    }
    m_sql = m_sql.substr(0, m_sql.length()-1);
    //logerror((LOG, "add robot sql: %s", m_sql));

    db_service.sync_execute(m_sql);
}

void
sc_guild_battle_t::init_fight_state()
{
    fight_state_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum, opponent FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);
    
    if (0 == res.affect_row_num())
    {
        return;
    }

    int32_t ggid;
    int32_t hostnum;
    int32_t opponent;
    unordered_map<int32_t, int32_t> gg_list;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        ggid = (int32_t)std::atoi(row_[0].c_str());
        hostnum = (int32_t)std::atoi(row_[1].c_str());
        opponent = (int32_t)std::atoi(row_[2].c_str());


        for (int32_t it_host : hosts)
        {
            if (it_host == hostnum)
            {
                if (gg_list.find(opponent) == gg_list.end())
                    gg_list.insert(make_pair(opponent, ggid));
                break;
            }
        }
    }
    string str_gg;
    for (auto it=gg_list.begin(); it!= gg_list.end(); ++it)
    {
        str_gg.append(std::to_string(it->first)+",");
    }
    str_gg = str_gg.substr(0, str_gg.length()-1);

    char sql_pos[256];
    sql_result_t res_pos;
    sprintf(sql_pos, "SELECT ggid, building_id, building_pos, uid, pid1, pid2, pid3, pid4, pid5, state, view_data, anger, hp1, hp2, hp3, hp4, hp5, fp FROM GuildBattleDefenceInfo WHERE ggid in (%s)", str_gg.c_str());
    db_service.sync_select(sql_pos, res_pos);


    if (res_pos.affect_row_num() == 0)
    {
        return;
    }

    for(size_t i=0; i<res_pos.affect_row_num(); ++i)
    {
        if (res_pos.get_row_at(i) == NULL)
        {
            continue;
        }

        int32_t pid_[5];
        sql_result_row_t& row_ = *res_pos.get_row_at(i);
        int32_t opponent_ggid = (int32_t)std::atoi(row_[0].c_str());
        int32_t building_id = (int32_t)std::atoi(row_[1].c_str());
        int32_t building_pos = (int32_t)std::atoi(row_[2].c_str());
        int32_t opponent_uid = (int32_t)std::atoi(row_[3].c_str());
        pid_[0] = (int32_t)std::atoi(row_[4].c_str());
        pid_[1] = (int32_t)std::atoi(row_[5].c_str());
        pid_[2] = (int32_t)std::atoi(row_[6].c_str());
        pid_[3] = (int32_t)std::atoi(row_[7].c_str());
        pid_[4] = (int32_t)std::atoi(row_[8].c_str());
        int32_t state = (int32_t)std::atoi(row_[9].c_str());
        string view_data = row_[10];
        int32_t anger_enemy = (int32_t)std::atoi(row_[11].c_str());
        float hp1 = (float)std::atoi(row_[12].c_str());
        float hp2 = (float)std::atoi(row_[13].c_str());
        float hp3 = (float)std::atoi(row_[14].c_str());
        float hp4 = (float)std::atoi(row_[15].c_str());
        float hp5 = (float)std::atoi(row_[16].c_str());
        int32_t fp = (int32_t)std::atoi(row_[17].c_str());

        auto it_gg = gg_list.find(opponent_ggid);
        if (it_gg == gg_list.end())
            continue;

        int32_t self_ggid = it_gg->second;

        auto it_self = fight_state_list.find(self_ggid);
        if (it_self == fight_state_list.end())
        {
            unordered_map<int32_t, unordered_map<int32_t, fight_state>> new_gg;
            fight_state_list.insert(make_pair(self_ggid, new_gg));
            it_self = fight_state_list.find(self_ggid);
        }
        
        auto it_building = it_self->second.find(building_id);
        if (it_building == it_self->second.end())
        {
            unordered_map<int32_t, fight_state> new_building;
            it_self->second.insert(make_pair(building_id, new_building));
            it_building = it_self->second.find(building_id);
        }
        
        fight_state new_f_s;
        new_f_s.defence_uid = opponent_uid;
        new_f_s.state = state;
        new_f_s.view_data = view_data;
        new_f_s.anger_enemy = anger_enemy;
        new_f_s.hp1 = hp1;
        new_f_s.hp2 = hp2;
        new_f_s.hp3 = hp3;
        new_f_s.hp4 = hp4;
        new_f_s.hp5 = hp5;
        new_f_s.pid1 = pid_[0];
        new_f_s.pid2 = pid_[1];
        new_f_s.pid3 = pid_[2];
        new_f_s.pid4 = pid_[3];
        new_f_s.pid5 = pid_[4];
        get_jpk_gbattle_target_by_uid_pid(opponent_uid, pid_, new_f_s.jpk_target);
        new_f_s.jpk_target.fp = fp;
        it_building->second.insert(make_pair(building_pos, new_f_s));
    }

    check_fight_states();

    guild_fighters.clear();
}

void
sc_guild_battle_t::check_fight_states()
{
    vector<int32_t> building_list;
    for (auto it=repo_mgr.guild_battle.begin(); it!=repo_mgr.guild_battle.end(); ++it)
    {
        building_list.push_back(it->second.id);
    }

    for(auto it_g=fight_state_list.begin(); it_g!=fight_state_list.end(); ++it_g)
    {
         for(auto it_b=building_list.begin(); it_b!=building_list.end(); ++it_b)
         {
             auto it_b_plus=it_g->second.find(*it_b);
             if (it_b_plus==it_g->second.end())
             {
                 add_robot_fight(it_g->second, *it_b, it_g->first);
             }
         }
    }
}

void
sc_guild_battle_t::add_robot_fight(unordered_map<int32_t, unordered_map<int32_t, fight_state>>& guild_, int32_t building_id_, int32_t guild_id_)
{
    unordered_map<int32_t, fight_state> new_building;
    guild_.insert(make_pair(building_id_, new_building));
    auto it_building = guild_.find(building_id_);
    
    fight_state new_f_s;
    new_f_s.defence_uid = -1;
    new_f_s.state = 0;
    new_f_s.view_data = "{\"uid\":-1,\"name\":\"社团守卫\",\"rank\":30,\"lv\":30,\"fp\":2333,\"viplevel\":1,\"roles\":{\"1\":{\"uid\":-1,\"pid\":0,\"resid\":2,\"skls\":[[1,0,1],[2,0,1],[3,0,1],[4,0,1],[5,0,1],[6,0,1],[7,0,1],[8,0,1]],\"pro\":[555,274,487,514,1583,0,0,0,4764,0,0,0,0,0.85,0.96,0.85,0.96,0.72,1,0.6,50,0,0,0,0,0,0,0,0,0,0],\"lvl\":[30,0],\"wid\":-1}},\"combo_pro\":{\"combo_d_down\":0,\"combo_r_down\":0,\"combo_d_up\":0,\"combo_r_up\":0,\"combo_anger\":{\"50\":0}}}";
    new_f_s.anger_enemy = 0;
    new_f_s.hp1 = 1;
    new_f_s.hp2 = 1;
    new_f_s.hp3 = 1;
    new_f_s.hp4 = 1;
    new_f_s.hp5 = 1;
    new_f_s.pid1 = 0;
    new_f_s.pid2 = -1;
    new_f_s.pid3 = -1;
    new_f_s.pid4 = -1;
    new_f_s.pid5 = -1;
    int32_t pid_[5];
    pid_[0] = 0;
    pid_[1] = -1;
    pid_[2] = -1;
    pid_[3] = -1;
    pid_[4] = -1;
    get_jpk_gbattle_target_by_uid_pid(new_f_s.defence_uid, pid_, new_f_s.jpk_target);
    new_f_s.jpk_target.fp = 5000;
    it_building->second.insert(make_pair(1, new_f_s));

    auto it_o = g_opponent_list.find(guild_id_);
    if (it_o == g_opponent_list.end())
        return;

    string m_sql = "INSERT IGNORE INTO `GuildBattleDefenceInfo` (`ggid`, `building_id`, `building_pos`, `uid`, `hp1`, `hp2`, `hp3`, `hp4`, `hp5`, `pid1`, `pid2`, `pid3`, `pid4`, `pid5`, `view_data`, `state`, `fp`) VALUES ";
    char tmp_sql[1024];
    sprintf(tmp_sql, "(%d, %d, 1, -1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -1, \'", it_o->second, building_id_);
    string str_buff = string(tmp_sql)+new_f_s.view_data+"\', 0, 5000)";
    m_sql += str_buff;
    db_service.sync_execute(m_sql);
}

void
sc_guild_battle_t::load_fight_user()
{
    fight_user_info_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT uid, ggid, score, last_fight_time, rest_times, have_buy_times, anger, attack_win, attack_lose, defence_win, defence_lose FROM GuildBattleUser WHERE state=1");
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())
        return;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            continue;
        }
        fight_user_info info;
        sql_result_row_t& row_ = *res.get_row_at(i);
        info.uid = (int32_t)std::atoi(row_[0].c_str());
        //cout <<"load fight: " << info.uid << endl;
        info.guild_id = (int32_t)std::atoi(row_[1].c_str());
        info.score = (int32_t)std::atoi(row_[2].c_str());
        info.add_score = 0;
        info.last_fight_time = (int32_t)std::atoi(row_[3].c_str());
        info.rest_times = (int32_t)std::atoi(row_[4].c_str());
        info.have_buy_times = (int32_t)std::atoi(row_[5].c_str());
        info.anger = (int32_t)std::atoi(row_[6].c_str());
        info.win_count = 0;
        info.attack_win = (int32_t)std::atoi(row_[7].c_str());
        info.attack_lose = (int32_t)std::atoi(row_[8].c_str());
        info.defence_win = (int32_t)std::atoi(row_[9].c_str());
        info.defence_lose = (int32_t)std::atoi(row_[10].c_str());

        fight_user_info_list.insert(make_pair(info.uid, info));
    }
}

void
sc_guild_battle_t::load_fight_building_info()
{
    // 清理一下缓存状态
    fight_building_info_list.clear();

    // 从当前公会正要进行攻击的防御列表中获取防守信息
    for (auto it_g=fight_state_list.begin(); it_g!=fight_state_list.end(); ++it_g)
    {
        unordered_map<int32_t, building_info> g_building_map;

        for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
        {
            int sum_state = 0;
            for (auto it_p=it_b->second.begin(); it_p!=it_b->second.end(); ++it_p)
            {
                sum_state += it_p->second.state;
            }
            int state_building = (sum_state == int(it_b->second.size())*3) ? 1 : 0;                 
            building_info b_info;
            b_info.guild_id = it_g->first;
            b_info.building_id = it_b->first;
            b_info.level = 1;
            b_info.state = state_building;
            g_building_map.insert(make_pair(it_b->first, b_info));
        }

        fight_building_info_list.insert(make_pair(it_g->first, g_building_map));
    }

    // 从数据库载入建筑等级
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, building_id, level FROM GuildBattleBuildingInfo");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            continue;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t guild_id = (int32_t)std::atoi(row_[0].c_str());
        int32_t building_id = (int32_t)std::atoi(row_[1].c_str());
        int32_t level = (int32_t)std::atoi(row_[2].c_str());
        auto it_o = g_opponent_list.find(guild_id);
        if (it_o == g_opponent_list.end())
            continue;
        int32_t opponent_guild_id = it_o->second;
        auto it_g = fight_building_info_list.find(opponent_guild_id);
        if (it_g == fight_building_info_list.end())
            continue;
        auto it_b = it_g->second.find(building_id);
        if (it_b == it_g->second.end())
            continue;
        it_b->second.level = level;
    }

    // 补全没有的信息
    for (auto it_g = fight_building_info_list.begin(); it_g!=fight_building_info_list.end(); ++it_g)
    {
        //  用1-10表示建筑编号 
        //  TODO
        for(int32_t i=1; i<=10; ++i)
        {
            auto it_b=it_g->second.find(i);
            if (it_b==it_g->second.end())
            {
                building_info b_info;
                b_info.guild_id = it_g->first;
                b_info.building_id = i;
                b_info.level = 1;
                b_info.state = 0;
                it_g->second.insert(make_pair(i, b_info));
            }
        }
    }
}

void
sc_guild_battle_t::send_reward()
{
    // 一次公会战结束以后 个人奖励
    // 获取公会获胜情况
    unordered_map<int32_t, bool> guild_win_map;
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum, is_win FROM GuildBattleInfo");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t guild_id = (int32_t)std::atoi(row_[0].c_str());
        int32_t hostnum = (int32_t)std::atoi(row_[1].c_str());
        bool is_win = ((int32_t)std::atoi(row_[2].c_str())==1);
        for (int32_t it_host : hosts)
        {
            if (it_host == hostnum)
            {
                guild_win_map.insert(make_pair(guild_id, is_win));
                break;
            }
        }
    }

    // 找出用户 发奖励
    sc_gmail_mgr_t::begin_offmail();
    char sql_user[256];
    sql_result_t res_user;
    sprintf(sql_user, "SELECT uid, ggid, score FROM GuildBattleUser WHERE state=1");
    db_service.sync_select(sql_user, res_user);
    for (size_t i=0; i<res_user.affect_row_num(); ++i)
    {
        if (res_user.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        
        sql_result_row_t& row_ = *res_user.get_row_at(i);
        int32_t uid = (int32_t)std::atoi(row_[0].c_str());
        int32_t guild_id = (int32_t)std::atoi(row_[1].c_str());
        int32_t score = (int32_t)std::atoi(row_[2].c_str());

        auto it_g=guild_win_map.find(guild_id);
        if (it_g!=guild_win_map.end())
        {
            if(it_g->second)
            {
                sc_msg_def::nt_bag_change_t nt;
                sc_msg_def::jpk_item_t item_;
                item_.itid = 0;
                item_.resid = 16006;
                int32_t win_base = repo_mgr.configure.find(27)->second.value;
                int32_t user_base = repo_mgr.configure.find(28)->second.value;
                int32_t num = win_base+int32_t(score/user_base);
                //cout <<"win base: " << win_base << " user_base: " << user_base << " score: "  << score << " num: " << num<<endl;
                item_.num = num;
                nt.items.push_back(item_);
                string msg = mailinfo.new_mail(mail_guild_battle_user_reward);
                auto rp_gmail = mailinfo.get_repo(mail_guild_battle_user_reward);

                sp_user_t sp_user;
                if (logic.usermgr().get(uid, sp_user))
                {
                    statics_ins.unicast_eventlog(*sp_user, 6788, 1, score, num);
                }

                if (rp_gmail != NULL)
                {
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                }
            }
            else
            {
                string msg = mailinfo.new_mail(mail_guild_battle_failed);
                auto rp_gmail = mailinfo.get_repo(mail_guild_battle_failed);

                sp_user_t sp_user;
                if (logic.usermgr().get(uid, sp_user))
                {
                    statics_ins.unicast_eventlog(*sp_user, 6788, 0);
                }

                if (rp_gmail != NULL)
                {
                    sc_msg_def::nt_bag_change_t nt;
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                }
            }
        }
    }
    sc_gmail_mgr_t::do_offmail();

    // 赛季奖励
    if (cur_turn == 8)
        send_season_reward();
}

void
sc_guild_battle_t::send_season_reward()
{
    // 公会战赛季结束以后 所有人发奖励
    // 获取公会积分情况
    unordered_map<int32_t, fight_guild_info> guild_map;
    vector<int32_t> guild_id_list;
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum, win, lose, total_score FROM GuildBattleInfo");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t guild_id = (int32_t)std::atoi(row_[0].c_str());
        int32_t hostnum = (int32_t)std::atoi(row_[1].c_str());
        int32_t win = (int32_t)std::atoi(row_[2].c_str());
        int32_t lose = (int32_t)std::atoi(row_[3].c_str());
        int32_t score = (int32_t)std::atoi(row_[4].c_str());
        fight_guild_info info;
        info.guild_id = guild_id;
        info.host = hostnum;
        info.win = win;
        info.lose = lose;
        info.score = score;
        guild_map.insert(make_pair(guild_id, info));
        guild_id_list.push_back(guild_id);
    }
    std::sort(guild_id_list.begin(), guild_id_list.end(), [&](const int32_t& g_a, const int32_t& g_b)
    {
        int32_t score_a, score_b;
        score_a = guild_map.find(g_a)->second.score;
        score_b = guild_map.find(g_b)->second.score;
        int32_t sign_time_a, sign_time_b;
        sign_time_a = guild_map.find(g_a)->second.sign_time;
        sign_time_b = guild_map.find(g_b)->second.sign_time;
        if (score_a > score_b)
        {
            return true;
        }
        if (score_a < score_b)
        {
            return false;
        }
        return (sign_time_a < sign_time_b);
    });
    string gg_del_list;
    sc_gmail_mgr_t::begin_offmail();
    for(size_t i=0;i<guild_id_list.size();++i)
    {
        bool is_cur_host = false;
        fight_guild_info& info=guild_map.find(guild_id_list[i])->second;
        for (int32_t it_host : hosts)
        {
            if (it_host == info.host)
            {
                is_cur_host = true;                
                break;
            }
        }
        if(!is_cur_host)
            continue;
        int32_t rank=i+1;
        int32_t win_num=repo_mgr.configure.find(29)->second.value * info.win;
        int32_t lose_num=repo_mgr.configure.find(30)->second.value * info.lose;
        int32_t rank_num=0;
        for (auto it_r=repo_mgr.guild_battle_reward.begin(); it_r!=repo_mgr.guild_battle_reward.end(); ++it_r)
        {
            if (rank >= it_r->second.ranking[2] && rank <= it_r->second.ranking[1])
            {
                rank_num = it_r->second.reward[1][1];
            }
        }
        // 找出用户 发奖励
        char sql_user[256];
        sql_result_t res_user;
        sprintf(sql_user, "SELECT uid FROM GuildBattleUser WHERE ggid=%d", info.guild_id);
        db_service.sync_select(sql_user, res_user);
        for (size_t i=0; i<res_user.affect_row_num(); ++i)
        {
            if (res_user.get_row_at(i) == NULL)
            {
                logerror((LOG, "get row is NULL!, at:%lu", i));
                break;
            }
        
            sql_result_row_t& row_ = *res_user.get_row_at(i);
            int32_t uid = (int32_t)std::atoi(row_[0].c_str());
            sc_msg_def::nt_bag_change_t nt;
            sc_msg_def::jpk_item_t item_;
            item_.itid = 0;
            item_.resid = 16006;
            item_.num = rank_num+win_num+lose_num;
            nt.items.push_back(item_);
            string msg = mailinfo.new_mail(mail_guild_battle_season_reward);
            auto rp_gmail = mailinfo.get_repo(mail_guild_battle_season_reward);
            if (rp_gmail != NULL)
            {
                sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
            }
            sp_user_t sp_user;
            if (logic.usermgr().get(uid, sp_user))
            {
                statics_ins.unicast_eventlog(*sp_user, 6789, rank, rank_num, win_num, lose_num);
            }
        }
        gg_del_list.append(std::to_string(info.guild_id)+",");
    }
    sc_gmail_mgr_t::do_offmail();

    gg_del_list = gg_del_list.substr(0, gg_del_list.length()-1);
    char sql_reset_guild[256];
    sprintf(sql_reset_guild, "DELETE FROM `GuildBattleInfo` WHERE ggid in (%s)", gg_del_list.c_str());
    db_service.sync_execute(sql_reset_guild);
}

void 
sc_guild_battle_t::load_arrange_defence_info()
{
    arrange_defence_info_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, building_id, building_pos, uid, pid1, pid2, pid3, pid4, pid5, fp FROM GuildBattleDefenceInfo");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        
        sql_result_row_t& row_ = *res.get_row_at(i);
        arrange_defence_info a_d_info;
        a_d_info.guild_id = (int32_t)std::atoi(row_[0].c_str());
        a_d_info.building_id = (int32_t)std::atoi(row_[1].c_str());
        a_d_info.position_id = (int32_t)std::atoi(row_[2].c_str());
        a_d_info.defence_uid = (int32_t)std::atoi(row_[3].c_str());
        a_d_info.pid[0] = (int32_t)std::atoi(row_[4].c_str());
        a_d_info.pid[1] = (int32_t)std::atoi(row_[5].c_str());
        a_d_info.pid[2] = (int32_t)std::atoi(row_[6].c_str());
        a_d_info.pid[3] = (int32_t)std::atoi(row_[7].c_str());
        a_d_info.pid[4] = (int32_t)std::atoi(row_[8].c_str());
        a_d_info.view_data = "";
        get_jpk_gbattle_target_by_uid_pid(a_d_info.defence_uid, a_d_info.pid, a_d_info.jpk_target);
        a_d_info.jpk_target.fp = (int32_t)std::atoi(row_[9].c_str());
        arrange_defence_info_list[a_d_info.guild_id][a_d_info.building_id][a_d_info.position_id] = a_d_info;
    }
}

void
sc_guild_battle_t::save_arrange_defence_info(int32_t guild_id_, int32_t building_id_, int32_t position_id_)
{
    arrange_defence_info& a_d_info = arrange_defence_info_list[guild_id_][building_id_][position_id_];
    sp_fight_view_user_t sp_view = view_cache.get_gbattle_fight_view(a_d_info.defence_uid, a_d_info.pid, true);
    (*sp_view) >> a_d_info.view_data;

    char sql_char[256];
    sprintf(sql_char, "REPLACE INTO `GuildBattleDefenceInfo` SET ggid=%d, building_id=%d, building_pos=%d, uid=%d, hp1=1, hp2=1, hp3=1, hp4=1, hp5=1, pid1=%d, pid2=%d, pid3=%d, pid4=%d, pid5=%d, fp=%d, view_data=\'", a_d_info.guild_id, a_d_info.building_id, a_d_info.position_id, a_d_info.defence_uid, a_d_info.pid[0], a_d_info.pid[1], a_d_info.pid[2], a_d_info.pid[3], a_d_info.pid[4], a_d_info.jpk_target.fp);
    string sql=string(sql_char)+a_d_info.view_data+"\', state=0, anger=0";
    //    db_service.sync_execute(sql);
    db_service.async_do((uint64_t)a_d_info.defence_uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void
sc_guild_battle_t::load_arrange_building_info()
{
    arrange_building_info_list.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, building_id, level FROM GuildBattleBuildingInfo");
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        
        sql_result_row_t& row_ = *res.get_row_at(i);
        building_info b_info;
        b_info.guild_id = (int32_t)std::atoi(row_[0].c_str());
        b_info.building_id = (int32_t)std::atoi(row_[1].c_str());
        b_info.level = (int32_t)std::atoi(row_[2].c_str());
        b_info.state = 0;
        arrange_building_info_list[b_info.guild_id][b_info.building_id] = b_info;
    }
}

void
sc_guild_battle_t::save_arrange_building_info(int32_t guild_id_, int32_t building_id_)
{
    building_info& b_info = arrange_building_info_list[guild_id_][building_id_];

    char sql_char[256];
    sprintf(sql_char, "REPLACE INTO `GuildBattleBuildingInfo` SET ggid=%d, building_id=%d, level=%d", b_info.guild_id, b_info.building_id, b_info.level);
    string sql=string(sql_char);
    db_service.sync_execute(sql);
}

int32_t
sc_guild_battle_t::get_arrange_building_level(int32_t guild_id_, int32_t building_id_)
{
    auto it_g = arrange_building_info_list.find(guild_id_);
    if (it_g == arrange_building_info_list.end())
    {
        return 1;
    }

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
    {
        return 1;
    }

    return it_b->second.level;
}

void
sc_guild_battle_t::set_arrange_building_level(int32_t guild_id_, int32_t building_id_, int32_t level_)
{
    building_info b_info;
    b_info.guild_id = guild_id_;
    b_info.building_id = building_id_;
    b_info.level = level_;
    b_info.state = 0;

    arrange_building_info_list[guild_id_][building_id_] = b_info;
    save_arrange_building_info(guild_id_, building_id_);
}


int32_t
sc_guild_battle_t::get_arrange_building_defence_info(int32_t guild_id_, int32_t building_id_, map<int, sc_msg_def::jpk_gbattle_target_t>& defence_info_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return SUCCESS;

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
        return SUCCESS;

    for (auto it_p=it_b->second.begin(); it_p!=it_b->second.end(); ++it_p)
    {
        defence_info_.insert(make_pair(it_p->first, it_p->second.jpk_target));
    }
    return SUCCESS;
}

int32_t 
sc_guild_battle_t::get_arrange_defence_info(int32_t guild_id_, int32_t uid_, map<int32_t, int32_t>& building_state_, map<int32_t, sc_msg_def::jpk_team_t>& self_team_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return SUCCESS;

    for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
    {
        // 建筑中 已布阵的人员信息
        building_state_.insert(make_pair(it_b->first, it_b->second.size()));
        for (auto it_p=it_b->second.begin(); it_p!=it_b->second.end(); ++it_p)
        {
            if (it_p->second.defence_uid == uid_)
            {
                sc_msg_def::jpk_team_t team;
                team.tid = 1;
                team.name = "";
                team.pid1 = it_p->second.pid[0];
                team.pid2 = it_p->second.pid[1];
                team.pid3 = it_p->second.pid[2];
                team.pid4 = it_p->second.pid[3];
                team.pid5 = it_p->second.pid[4];
                team.is_default = 0;

                self_team_.insert(make_pair(it_b->first*100+it_p->first, team));
            }
        }
    }
    return SUCCESS;
}

bool
sc_guild_battle_t::is_user_more_than_3(int32_t guild_id_, int32_t uid_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return false;

    int sum=0;
    for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
    {
        for (auto it_p=it_b->second.begin(); it_p!=it_b->second.end(); ++it_p)
        {
            if (it_p->second.defence_uid == uid_)
                sum++;
        }
    }
    return (sum >= 3);
}

bool
sc_guild_battle_t::is_partner_on(int32_t guild_id_, int32_t uid_, vector<int32_t>& team_info_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return false;

    unordered_map<int32_t, int32_t> conflict_map;
    for (auto it=team_info_.begin(); it!=team_info_.end(); ++it)
    {
        if (*it != -1)
            conflict_map.insert(make_pair(*it, 1));
    }

    for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
    {
        for (auto it_p=it_b->second.begin(); it_p!=it_b->second.end(); ++it_p)
        {
            if (it_p->second.defence_uid == uid_)
            {
                for (int32_t i=0; i<5; ++i)
                {
                    if (conflict_map.find(it_p->second.pid[i]) != conflict_map.end())
                        return true;
                }
            }
        }
    }
    return false;
}

bool
sc_guild_battle_t::is_occupy(int32_t guild_id_, int32_t building_id_, int32_t position_id_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return false;

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
        return false;

    auto it_p = it_b->second.find(position_id_);
    if (it_p == it_b->second.end())
        return false;
    else
        return true;
}

void 
sc_guild_battle_t::occupy_pos(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t uid_, vector<int32_t>& team_info_, int32_t fp_)
{
    arrange_defence_info a_d_info;
    a_d_info.guild_id = guild_id_;
    a_d_info.building_id = building_id_;
    a_d_info.position_id = position_id_;
    a_d_info.defence_uid = uid_;
    a_d_info.pid[0] = team_info_[0];
    a_d_info.pid[1] = team_info_[1];
    a_d_info.pid[2] = team_info_[2];
    a_d_info.pid[3] = team_info_[3];
    a_d_info.pid[4] = team_info_[4];
    a_d_info.view_data = "";
    get_jpk_gbattle_target_by_uid_pid(a_d_info.defence_uid, a_d_info.pid, a_d_info.jpk_target);
    a_d_info.jpk_target.fp = fp_;

    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
    {
        unordered_map<int32_t, unordered_map<int32_t, arrange_defence_info>> g_map;
        arrange_defence_info_list.insert(make_pair(guild_id_, g_map));
        it_g = arrange_defence_info_list.find(guild_id_);
    }

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
    {
        unordered_map<int32_t, arrange_defence_info> b_map;
        it_g->second.insert(make_pair(building_id_, b_map));
        it_b = it_g->second.find(building_id_);
    }

    auto it_p = it_b->second.find(position_id_);
    if (it_p != it_b->second.end())
    {
        it_b->second.erase(it_p);
    }
    it_b->second.insert(make_pair(position_id_, a_d_info));

    save_arrange_defence_info(guild_id_, building_id_, position_id_);
    save_arrange_partner(uid_, a_d_info.pid, true);
}

void
sc_guild_battle_t::arrange_add_user(int32_t guild_id_, int32_t uid_)
{
    auto it_u = arrange_user_list.find(uid_);
    if (it_u == arrange_user_list.end())
    {
        arrange_user_list.insert(make_pair(uid_, 1));
        char sql_user[256];
        sprintf(sql_user, "REPLACE INTO `GuildBattleUser` (`uid`, `ggid`, `anger`, `attack_win`, `attack_lose`, `defence_win`, `defence_lose`) VALUES (%d, %d, 0, 0, 0, 0, 0)", uid_, guild_id_);
        string sql = string(sql_user);
        db_service.async_do((uint64_t)uid_, [](string& sql_){
            db_service.async_execute(sql_);
        }, sql);
    }
}

bool
sc_guild_battle_t::is_this_user(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t uid_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return false;

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
        return false;

    auto it_p = it_b->second.find(position_id_);
    if (it_p == it_b->second.end())
        return false;
    else
        return (it_p->second.defence_uid == uid_);
}

void
sc_guild_battle_t::get_arrange_uid(int32_t guild_id_, int32_t building_id_, int32_t position_id_, int32_t& uid_)
{
    uid_ = arrange_defence_info_list[guild_id_][building_id_][position_id_].defence_uid;
}

void
sc_guild_battle_t::off_pos(int32_t guild_id_, int32_t building_id_, int32_t position_id_)
{
    auto it_g = arrange_defence_info_list.find(guild_id_);
    if (it_g == arrange_defence_info_list.end())
        return;

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
        return;

    auto it_p = it_b->second.find(position_id_);
    if (it_p == it_b->second.end())
        return;
    
    int32_t uid = it_p->second.defence_uid;
    char sql_del[256];
    sprintf(sql_del, "DELETE FROM `GuildBattleDefenceInfo` WHERE ggid=%d AND building_id=%d AND building_pos=%d", guild_id_, building_id_, position_id_);
    string sql = string(sql_del);
    db_service.async_do((uint64_t)uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);

    save_arrange_partner(uid, it_p->second.pid, false); 

    it_b->second.erase(it_p);
}


void
sc_guild_battle_t::reset_guild_info()
{
    has_sign_up = false;
    during_arrange = false;
    has_arrange = false;
    during_fight = false;
    during_summary = false;
    string sql_building="UPDATE GuildBattleBuildingInfo SET level=1";
    string sql_defence="TRUNCATE TABLE GuildBattleDefenceInfo";
    string sql_guild="UPDATE GuildBattleInfo SET state=0, score=0, opponent=0, is_win=-1";
    string sql_log="TRUNCATE TABLE GuildBattleLog";
    string sql_partner="TRUNCATE TABLE GuildBattlePartner";
    string sql_user="UPDATE GuildBattleUser SET anger=0, attack_win=0, attack_lose=0, defence_win=0, defence_lose=0, score=0, last_fight_time=0, rest_times=5, have_buy_times=0, state=0";
    db_service.sync_execute(sql_building);
    db_service.sync_execute(sql_defence);
    db_service.sync_execute(sql_guild);
    db_service.sync_execute(sql_log);
    db_service.sync_execute(sql_partner);
    db_service.sync_execute(sql_user);
}

bool
sc_guild_battle_t::sign_up_time()
{
    return (state_gb == 1);
}

int32_t
sc_guild_battle_t::get_state()
{
    return state_gb;
}

void
sc_guild_battle_t::get_guild_fight_state_list(int32_t guild_id_, map<int32_t, int32_t>& state_list_)
{
    auto it_g = fight_building_info_list.find(guild_id_);
    if (it_g == fight_building_info_list.end())
    {
        return;
    }
    for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
    {
        state_list_.insert(make_pair(it_b->first, it_b->second.state));
    }
}

int32_t
sc_guild_battle_t::get_guild_building_level_list(int32_t guild_id_, map<int32_t, int32_t>& level_list_)
{
    auto it_g = fight_building_info_list.find(guild_id_);
    if (it_g == fight_building_info_list.end())
        return ERROR_NO_SUCH_GANG;
    
    for (auto it_b=it_g->second.begin(); it_b!=it_g->second.end(); ++it_b)
    {
        level_list_.insert(make_pair(it_b->first, it_b->second.level));
    }

    return SUCCESS;
}

void
sc_guild_battle_t::get_guild_building_level(int32_t guild_id_, int32_t building_id_, int32_t& level_)
{
    auto it_g = fight_building_info_list.find(guild_id_);
    if (it_g == fight_building_info_list.end())
    {
        level_ = 1;
        return;
    }

    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
    {
        level_ = 1;
        return;
    }

    level_ = it_b->second.level;
}

int32_t
sc_guild_battle_t::get_guild_building_fight_info(int32_t ggid_, int32_t building_id_, map<int32_t, int32_t>& defence_state_,
    map<int32_t, sc_msg_def::jpk_gbattle_target_t>& defence_info_)
{
    auto it_gg = fight_state_list.find(ggid_);
    if (it_gg == fight_state_list.end())
        return ERROR_FIGHT_STATE;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ERROR_FIGHT_STATE;

    for (auto it_pos=it_building->second.begin(); it_pos!=it_building->second.end(); ++it_pos)
    {
        defence_state_.insert(make_pair(it_pos->first, it_pos->second.state));
        
        defence_info_.insert(make_pair(it_pos->first, it_pos->second.jpk_target));
    }
    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_abb_info(int32_t uid_, sc_msg_def::jpk_arena_team_info_t& info_, int32_t& fp_, int32_t& viplevel_)
{
    if (uid_ == -1)
    {
        fp_ = 5000;
        viplevel_ = 1;
        info_.resid = 2;
        info_.level = 30;
        info_.starnum = 1;
        info_.equiplv = 1;
        info_.lovelevel = 0;
        info_.pid = 0;

        return SUCCESS;
    }
    auto it=abb_user_info.find(uid_);
    if (it==abb_user_info.end())
    {
        fight_user_abb_info new_info;
        int32_t pid[5];
        pid[0] = 0;
        pid[1] = -1;
        pid[2] = -1;
        pid[3] = -1;
        pid[4] = -1;

        sp_view_user_t sp_view = view_cache.get_view(uid_, pid, true);
        if (sp_view != NULL)
        {
            for(auto it=sp_view->roles.begin(); it!=sp_view->roles.end(); it++)
            {
                if (it->second.pid == 0)
                {
                    new_info.pid = 0;
                    new_info.equiplv = sc_user_t::get_equip_level(uid_, it->second.pid);
                    new_info.resid = it->second.resid;
                    new_info.level = it->second.lvl.level;
                    new_info.lovelevel = it->second.lvl.lovelevel;

                    sql_result_t res;
                    char tmp_sql[256];
                    sprintf(tmp_sql, "SELECT quality, viplevel, fp FROM UserInfo WHERE uid=%d;", uid_);
                    db_service.sync_select(tmp_sql, res);
                    if (0 == res.affect_row_num())
                    {
                        new_info.starnum = 1;
                        new_info.viplevel = 1;
                        new_info.fp = 5000;
                    }
                    else
                    {
                        sql_result_row_t& row = *res.get_row_at(0);
                        new_info.starnum = (int32_t)std::atoi(row[0].c_str());
                        new_info.viplevel = (int32_t)std::atoi(row[1].c_str());
                        new_info.fp = (int32_t)std::atoi(row[2].c_str());
                    }
                    break;
                }
            }
        }
        else
        {
            return ERROR_NO_SUCH_USER;
        }
        abb_user_info.insert(make_pair(uid_, new_info));
        it=abb_user_info.find(uid_);
    }
    info_.resid = it->second.resid;
    info_.level = it->second.level;
    info_.starnum = it->second.starnum;
    info_.equiplv = it->second.equiplv;
    info_.lovelevel = it->second.lovelevel;
    info_.pid = it->second.pid;
    fp_ = it->second.fp;
    viplevel_ = it->second.viplevel;

    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_gbattle_cache(int32_t ggid_, int32_t building_id_, int32_t building_pos_, sc_msg_def::jpk_gbattle_target_t& gbattle_)
{
    auto it_gg = defence_state_list.find(ggid_);
    if (it_gg == defence_state_list.end())
    {
        unordered_map<int32_t, unordered_map<int32_t, fight_state>> new_gg;
        defence_state_list.insert(make_pair(ggid_, new_gg));
        it_gg = defence_state_list.find(ggid_);
    }

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
    {
        unordered_map<int32_t, fight_state> new_building;
        it_gg->second.insert(make_pair(building_id_, new_building));
        it_building = it_gg->second.find(building_id_);
    }

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
    {
        char sql[256];
        sql_result_t res;
        sprintf(sql, "SELECT uid, pid1, pid2, pid3, pid4, pid5, state FROM GuildBattleDefenceInfo WHERE ggid=%d AND building_id=%d AND building_pos=%d", ggid_, building_id_, building_pos_);
        db_service.sync_select(sql, res);
        if (res.get_row_at(0) == NULL)
        {
            return ERROR_DEFENCE_INFO;
        }
        
        sql_result_row_t& row_ = *res.get_row_at(0);
        fight_state new_f_s;
        int32_t pid_[5];
        new_f_s.defence_uid = (int32_t)std::atoi(row_[0].c_str());
        pid_[0] = (int32_t)std::atoi(row_[1].c_str());
        pid_[1] = (int32_t)std::atoi(row_[2].c_str());
        pid_[2] = (int32_t)std::atoi(row_[3].c_str());
        pid_[3] = (int32_t)std::atoi(row_[4].c_str());
        pid_[4] = (int32_t)std::atoi(row_[5].c_str());
        new_f_s.state = (int32_t)std::atoi(row_[6].c_str());
        int32_t code = get_jpk_gbattle_target_by_uid_pid(new_f_s.defence_uid, pid_, new_f_s.jpk_target);
        if (code != SUCCESS)
            return code;

        it_building->second.insert(make_pair(building_pos_, new_f_s));
        gbattle_ = sc_msg_def::jpk_gbattle_target_t(new_f_s.jpk_target);

        return SUCCESS;
    }

    gbattle_ = sc_msg_def::jpk_gbattle_target_t(it_pos->second.jpk_target);
    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_pos_state(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t& state_)
{
    auto it_gg = fight_state_list.find(ggid_);
    if (it_gg == fight_state_list.end())
        return ERROR_FIGHT_STATE;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ERROR_FIGHT_STATE;

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
        return ERROR_FIGHT_STATE;

    state_ = it_pos->second.state;
    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_fight_view(int32_t ggid_, int32_t building_id_, int32_t building_pos_, string& view_data_, int32_t& anger_enemy_, int32_t& opponent_uid_)
{
    auto it_gg = fight_state_list.find(ggid_);
    if (it_gg == fight_state_list.end())
        return ERROR_FIGHT_STATE;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ERROR_FIGHT_STATE;

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
        return ERROR_FIGHT_STATE;

    view_data_ = it_pos->second.view_data;
    anger_enemy_ = it_pos->second.anger_enemy;
    opponent_uid_ = it_pos->second.defence_uid;
    return SUCCESS;
}

bool
sc_guild_battle_t::set_pos_state(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t state_)
{
    auto it_gg = fight_state_list.find(ggid_);
    if (it_gg == fight_state_list.end())
        return false;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return false;

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
        return false;

    // 状态切换 广播
    sc_msg_def::nt_guild_boardcast_fight_state_switch state_switch_;
    state_switch_.building_id = building_id_;
    state_switch_.building_pos = building_pos_;
    state_switch_.new_state = state_;
    
    boardcast_fight_state(ggid_, state_switch_);
    it_pos->second.state = state_;
    if (state_ == 2)
        return true;
    
    auto it_opponent = g_opponent_list.find(ggid_);
    char sql_update[256];
    sprintf(sql_update, "UPDATE `GuildBattleDefenceInfo` SET state=%d WHERE ggid=%d AND building_id=%d AND building_pos=%d", state_, it_opponent->second, building_id_, building_pos_);
    db_service.sync_execute(sql_update);
    if (state_ == 3 && it_pos->first == it_building->second.size())
    {
        set_building_state(ggid_, building_id_, 1);
        return true;
    }
    return false;
}

void
sc_guild_battle_t::set_building_state(int32_t guild_id_, int32_t building_id_, int32_t state_)
{
    auto it_g = fight_building_info_list.find(guild_id_);
    if (it_g == fight_building_info_list.end())
        return;
    auto it_b = it_g->second.find(building_id_);
    if (it_b == it_g->second.end())
        return;
    it_b->second.state = state_;
    if (building_id_ == 1)
    {
        //cout << "set_building_state, g: " << guild_id_ << " b: " << building_id_ << " s: " << state_ << endl;
        fight_guild_info_list[guild_id_].is_win = 1;
        save_guild_info(guild_id_);
    }
}

void
sc_guild_battle_t::set_enemy_anger(int32_t ggid_, int32_t building_id_, int32_t building_pos_, int32_t anger_)
{
    auto it_gg = fight_state_list.find(ggid_);
    if (it_gg == fight_state_list.end())
        return ;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ;

    auto it_pos = it_building->second.find(building_pos_);
    if (it_pos == it_building->second.end())
        return ;

    it_pos->second.anger_enemy = anger_;
}

void
sc_guild_battle_t::set_enemy_hp(int32_t guild_id_, int32_t building_id_, int32_t position_id_, float hp1_, float hp2_, float hp3_, float hp4_, float hp5_)
{
    auto it_gg = fight_state_list.find(guild_id_);
    if (it_gg == fight_state_list.end())
        return ;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ;

    auto it_pos = it_building->second.find(position_id_);
    if (it_pos == it_building->second.end())
        return ;

    it_pos->second.hp1 = hp1_;
    it_pos->second.hp2 = hp2_;
    it_pos->second.hp3 = hp3_;
    it_pos->second.hp4 = hp4_;
    it_pos->second.hp5 = hp5_;
}

void
sc_guild_battle_t::get_enemy_hp(int32_t guild_id_, int32_t building_id_, int32_t position_id_, map<int32_t, sc_msg_def::jpk_card_event_partner_t>& team_)
{
    auto it_gg = fight_state_list.find(guild_id_);
    if (it_gg == fight_state_list.end())
        return ;

    auto it_building = it_gg->second.find(building_id_);
    if (it_building == it_gg->second.end())
        return ;

    auto it_pos = it_building->second.find(position_id_);
    if (it_pos == it_building->second.end())
        return ;

    float hp_[5];
    int32_t pid_[5];
    hp_[0] = it_pos->second.hp1;
    hp_[1] = it_pos->second.hp2;
    hp_[2] = it_pos->second.hp3;
    hp_[3] = it_pos->second.hp4;
    hp_[4] = it_pos->second.hp5;
    pid_[0] = it_pos->second.pid1;
    pid_[1] = it_pos->second.pid2;
    pid_[2] = it_pos->second.pid3;
    pid_[3] = it_pos->second.pid4;
    pid_[4] = it_pos->second.pid5;
    for (int32_t i=0; i<5; ++i)
    {
        sc_msg_def::jpk_card_event_partner_t jpk_;
        jpk_.pid = pid_[i];
        jpk_.hp = hp_[i];
        team_.insert(make_pair(i+1, jpk_));
    }
}

void
sc_guild_battle_t::add_fighter(int32_t ggid_, int32_t uid_)
{
    auto it_gg = guild_fighters.find(ggid_);
    if (it_gg == guild_fighters.end())
    {
        unordered_map<int32_t, int32_t> fighters;
        guild_fighters.insert(make_pair(ggid_,fighters));
        it_gg = guild_fighters.find(ggid_);
    }
    it_gg->second.insert(make_pair(uid_,1));
}

void
sc_guild_battle_t::boardcast_fight_info(int32_t ggid_, sc_msg_def::nt_guild_boardcast_fight_info& nt_)
{
    auto it_gg = guild_fighters.find(ggid_);
    if (it_gg == guild_fighters.end())
    {
        return;
    }

    for (auto it_fighter=it_gg->second.begin();it_fighter!=it_gg->second.end();++it_fighter)
    {
        int32_t uid = it_fighter->first;
        logic.unicast(uid, nt_);
    }
}

void
sc_guild_battle_t::boardcast_fight_state(int32_t ggid_, sc_msg_def::nt_guild_boardcast_fight_state_switch& nt_)
{
    auto it_gg = guild_fighters.find(ggid_);
    if (it_gg == guild_fighters.end())
    {
        return;
    }

    for (auto it_fighter=it_gg->second.begin();it_fighter!=it_gg->second.end();++it_fighter)
    {
        int32_t uid = it_fighter->first;
        logic.unicast(uid, nt_);
    }
}

void
sc_guild_battle_t::add_fight_info(int32_t uid_, int32_t opponent_uid_, int32_t ggid_, int32_t state_, int32_t win_count_, int32_t building_id_, int32_t building_pos_)
{    
    fight_info info;
    info.attack_name = get_name(uid_);
    info.defence_name = get_name(opponent_uid_);
    info.state = state_;
    info.win_count = win_count_;
    int32_t stamp = date_helper.cur_sec();
    info.stamp = stamp;
    info.attacker_uid = uid_;
    info.defencer_uid = opponent_uid_;
    info.ggid = ggid_;
    info.building_id = building_id_;
    info.position_id = building_pos_;
    
    auto it_opponent = g_opponent_list.find(ggid_);
    int32_t opponent_ggid;
    bool opponent_cur = false;
    if (it_opponent != g_opponent_list.end())
    {
        if (it_opponent->second != -1)
        {
            opponent_cur = true;
            opponent_ggid = it_opponent->second;
        }
    }

    sc_msg_def::nt_guild_boardcast_fight_info f_info;
    f_info.fight_side = info.state;
    f_info.win_count = info.win_count;
    f_info.name = info.attack_name;
    f_info.name_enemy = info.defence_name;

    push_back_fight_info(ggid_, info);
    boardcast_fight_info(ggid_, f_info);

    if (opponent_cur)
    {
        push_back_fight_info(opponent_ggid, info);
        boardcast_fight_info(opponent_ggid, f_info);
    }
}

void
sc_guild_battle_t::push_back_fight_info(int32_t ggid_, fight_info& info_)
{
    auto it=fight_info_map.find(ggid_);
    if (it==fight_info_map.end())
    {
        vector<fight_info> f_v;
        fight_info_map.insert(make_pair(ggid_, f_v));
        it=fight_info_map.find(ggid_);
    }
    it->second.push_back(info_);
    char sql[256];
    sprintf(sql, "INSERT INTO `GuildBattleLog` (`ggid`, `attack_uid`, `defence_uid`, `win_count`, `is_win`) VALUES (%d, %d, %d, %d, %d)", ggid_, info_.attacker_uid, info_.defencer_uid, info_.win_count, info_.state);

    db_service.sync_execute(sql);
}

void
sc_guild_battle_t::add_battle_log(int32_t ggid_, fight_info& info_)
{
    fight_info_map[ggid_].push_back(info_);
}

int32_t
sc_guild_battle_t::get_AllBattleLog(int32_t ggid_, sc_msg_def::ret_guild_battle_fight_record_info& ret_)
{
    auto it=fight_info_map.find(ggid_);
    if (it==fight_info_map.end())
    {
        return ERROR_0_SIZE;
    }

    if (it->second.size() == 0)
        return ERROR_0_SIZE;

    vector<fight_info> v_bl;
    v_bl.insert(v_bl.begin(), it->second.begin(), it->second.end());
    std::sort(v_bl.begin(), v_bl.end(), [&](const fight_info& bl_a, const fight_info& bl_b)
    {
        return bl_a.stamp < bl_b.stamp;
    });

    for (auto it_bl=v_bl.begin();it_bl!=v_bl.end();++it_bl)
    {
        sc_msg_def::nt_guild_boardcast_fight_info info;
        info.fight_side = it_bl->state;
        info.win_count = it_bl->win_count;
        info.name = it_bl->attack_name;
        info.name_enemy = it_bl->defence_name;
        ret_.info_list.push_back(info);
    }

    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_user_battle_log(int32_t guild_id_, int32_t uid_, vector<sc_msg_def::fight_info_self>& info_)
{
    auto it_g = fight_info_map.find(guild_id_);
    if (it_g == fight_info_map.end())
    {
        vector<fight_info> f_v;
        fight_info_map.insert(make_pair(guild_id_, f_v));
        it_g=fight_info_map.find(guild_id_);
    }

    for (auto it_bl=it_g->second.begin();it_bl!=it_g->second.end();++it_bl)
    {
        //if (it_bl->attacker_uid == uid_ || it_bl->defencer_uid == uid_)
        if (it_bl->attacker_uid == uid_)
        {
            sc_msg_def::fight_info_self info_self;
            info_self.fight_side = 1;
            info_self.is_win = (it_bl->state == 1);
            info_self.name_enemy = it_bl->defence_name;
            int32_t opponent_uid = it_bl->defencer_uid;
            int32_t code = get_abb_info(opponent_uid, info_self.head_info, info_self.fp, info_self.viplevel);
            if (code != SUCCESS)
                return code;

            info_.push_back(info_self);
        }
    }
    auto it_go = g_opponent_list.find(guild_id_);
    if (it_go != g_opponent_list.end())
    {
        auto it_goo = fight_info_map.find(it_go->second);
        if (it_goo != fight_info_map.end())
        {
            for (auto it_bl=it_goo->second.begin();it_bl!=it_goo->second.end();++it_bl)
            {
                if (it_bl->defencer_uid == uid_)
                {
                    sc_msg_def::fight_info_self info_self;
                    info_self.fight_side = 0;
                    info_self.is_win = (it_bl->state == 0);
                    info_self.name_enemy = it_bl->attack_name;
                    int32_t opponent_uid = it_bl->attacker_uid;
                    int32_t code = get_abb_info(opponent_uid, info_self.head_info, info_self.fp, info_self.viplevel);
                    if (code != SUCCESS)
                        return code;

                    info_.push_back(info_self);
                }
            }
        }
    }
    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_gfight_info(int32_t guild_id_, map<int32_t, sc_msg_def::gfight_info_t>& info_)
{
    if (fight_user_info_list.size() == 0)
        return SUCCESS;
    int32_t max_score = 0;
    int32_t user_mvp = fight_user_info_list.begin()->second.uid;
    int32_t max_attack_win = 0;
    int32_t user_attacker = fight_user_info_list.begin()->second.uid;
    int32_t max_defence_win = 0;
    int32_t user_defencer = fight_user_info_list.begin()->second.uid;

    for (auto it_u=fight_user_info_list.begin();it_u!=fight_user_info_list.end();++it_u)
    {
        if (it_u->second.guild_id != guild_id_)
            continue;
        int32_t uid = it_u->first;
        sc_msg_def::gfight_info_t g_info;
        fight_user_info uinfo;
        int32_t code = get_user_fight_info(uid, uinfo);
        if (code != SUCCESS)
            return code;
        g_info.name = get_name(uid);
        g_info.score = uinfo.score;
        g_info.win_count = uinfo.attack_win;
        g_info.lose_count = uinfo.attack_lose;
        g_info.is_mvp = false;
        g_info.is_top_attacker = false;
        g_info.is_top_defencer = false;
        code = get_abb_info(uid, g_info.head_info, g_info.fp, g_info.viplevel);
        if (code != SUCCESS)
            return code;
        g_info.rest_times = uinfo.rest_times;
        if (g_info.score >= max_score)
        {
            max_score = g_info.score;
            user_mvp = uid;
        }
        if (g_info.win_count >= max_attack_win)
        {
            max_attack_win = g_info.win_count;
            user_attacker = uid;
        }
        if (g_info.lose_count >= max_defence_win)
        {
            max_defence_win = g_info.lose_count;
            user_defencer = uid;
        }
        info_.insert(make_pair(uid, g_info));
    }
    if (info_.size() == 0)
        return SUCCESS;
    info_[user_mvp].is_mvp = true;
    info_[user_attacker].is_top_attacker = true;
    info_[user_defencer].is_top_defencer = true;

    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_gfight_info_e(int32_t guild_id_, map<int32_t, sc_msg_def::gfight_info_t>& info_)
{
    auto it_op = g_opponent_list.find(guild_id_);
    if (it_op == g_opponent_list.end())
        return ERROR_NO_OPPONENT;

    return get_gfight_info(it_op->second, info_);
}

void
sc_guild_battle_t::update_guild_opponent_score(int32_t guild_id_)
{
    // 更新公会信息
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT score FROM GuildBattleInfo WHERE ggid=%d", guild_id_);
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())
    {
        return;
    }
    else
    {
        sql_result_row_t& row_ = *res.get_row_at(0);
        auto it_g = guild_info_list.find(guild_id_);
        if (it_g != guild_info_list.end())
        {
            it_g->second.score = (int32_t)std::atoi(row_[0].c_str());
        }
    }
}

void
sc_guild_battle_t::update_guild_opponent_user_info(int32_t guild_id_)
{
    auto it_o = g_opponent_list.find(guild_id_);
    if (it_o == g_opponent_list.end())
        return;
    if (it_o->second == -1)
        return;

    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT score, attack_win, attack_lose, rest_times, uid FROM GuildBattleUser WHERE ggid=%d", it_o->second);
    db_service.sync_select(sql, res);
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t uid = (int32_t)std::atoi(row_[4].c_str());
        int32_t score = (int32_t)std::atoi(row_[0].c_str());
        int32_t attack_win = (int32_t)std::atoi(row_[1].c_str());
        int32_t attack_lose = (int32_t)std::atoi(row_[2].c_str());
        int32_t rest_times = (int32_t)std::atoi(row_[3].c_str());
        auto it_u = fight_user_info_list.find(uid);
        if (it_u != fight_user_info_list.end())
        {
            it_u->second.score = score;
            it_u->second.attack_win = attack_win;
            it_u->second.attack_lose = attack_lose;
            it_u->second.rest_times = rest_times;
        }
    }
}

string
sc_guild_battle_t::get_name(int32_t uid_)
{
    auto it=name_map.find(uid_);
    if (it==name_map.end())
    {
        char sql[256];
        sql_result_t res;
        sprintf(sql, "SELECT nickname FROM UserInfo WHERE uid=%d", uid_);
        db_service.sync_select(sql, res);
        if (0 == res.affect_row_num())
        {
            return "社团守卫";
        }
        else
        {
            sql_result_row_t& row_ = *res.get_row_at(0);
            name_map.insert(make_pair(uid_, row_[0]));
        }
        it=name_map.find(uid_);
    }
    return it->second;
}

int32_t
sc_guild_battle_t::get_user_fight_info(int32_t uid_, fight_user_info& info_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
    {
        return ERROR_DID_JOIN_FIGHT;
    }

    info_ = it_user->second;
    return SUCCESS;
}

int32_t
sc_guild_battle_t::get_battle_log_names(int32_t ggid_, string& mvp_, string& attacker_, string& defencer_)
{
    int32_t mvp=0;
    int32_t attacker=0;
    int32_t defencer=0;
    for (auto it=fight_user_info_list.begin();it!=fight_user_info_list.end();++it)
    {
        if (it->second.guild_id == ggid_)
        {
            if (it->second.score >= mvp)
            {
                mvp_ = get_name(it->second.uid);
                mvp = it->second.score;
            }
            if (it->second.attack_win >= attacker)
            {
                attacker_ = get_name(it->second.uid);
                attacker = it->second.attack_win;
            }
            if (it->second.defence_win >= defencer)
            {
                defencer_ = get_name(it->second.uid);
                defencer = it->second.defence_win;
            }
        }
    }
    return SUCCESS;
}

int32_t
sc_guild_battle_t::user_fight(int32_t uid_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
        return ERROR_NO_SUCH_USER;

    int32_t cur_sec = date_helper.cur_sec();
    if (cur_sec - it_user->second.last_fight_time < 900)
        return ERROR_FIGHT_IN_COOLING;

    if (it_user->second.rest_times <= 0)
        return ERROR_FIGHT_NO_TIMES;

    it_user->second.last_fight_time = cur_sec;
    it_user->second.rest_times--;
    char sql_tmp[256];
    sprintf(sql_tmp, "last_fight_time=%d, rest_times=%d", it_user->second.last_fight_time, it_user->second.rest_times);
    save_user_info(uid_,string(sql_tmp));
}

void
sc_guild_battle_t::user_attack_end(int32_t uid_, bool is_win_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
        return;
    char sql_tmp[256];
    if (is_win_)
    {
        it_user->second.attack_win++;
        sprintf(sql_tmp, "attack_win=%d", it_user->second.attack_win);
    }
    else
    {
        it_user->second.attack_lose++;
        sprintf(sql_tmp, "attack_lose=%d", it_user->second.attack_lose);
    }

    save_user_info(uid_, string(sql_tmp));
}

void
sc_guild_battle_t::user_defence_end(int32_t uid_, bool is_win_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
        return;
    char sql_tmp[256];
    if (is_win_)
    {
        it_user->second.defence_win++;
        sprintf(sql_tmp, "defence_win=%d", it_user->second.defence_win);
    }
    else
    {
        it_user->second.defence_lose++;
        sprintf(sql_tmp, "defence_lose=%d", it_user->second.defence_lose);
    }
    save_user_info(uid_, string(sql_tmp));
}

void
sc_guild_battle_t::add_fight_times(int32_t uid_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
    {
        return;
    }
    it_user->second.rest_times++;
    it_user->second.have_buy_times++;
    char sql_tmp[256];
    sprintf(sql_tmp, "rest_times=%d, have_buy_times=%d", it_user->second.rest_times, it_user->second.have_buy_times);
    save_user_info(uid_, string(sql_tmp));
}

void
sc_guild_battle_t::save_user_anger(int32_t uid_, int32_t anger_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
    {
        return;
    }
    it_user->second.anger = anger_;

    char sql_tmp[256];
    sprintf(sql_tmp, "anger=%d", it_user->second.anger);
    save_user_info(uid_, string(sql_tmp));
}

void
sc_guild_battle_t::clear_fight_cd(int32_t uid_)
{
    auto it_user = fight_user_info_list.find(uid_);
    if (it_user == fight_user_info_list.end())
    {
        return;
    }
    it_user->second.last_fight_time = 0;
}

int32_t
sc_guild_battle_t::get_opponent_guild_name(int32_t ggid_, string& opponent_name_)
{
    auto it_opponent=g_opponent_list.find(ggid_);
    if (it_opponent==g_opponent_list.end())
    {
        return ERROR_NO_SUCH_GANG;
    }
    
    return get_guild_name(it_opponent->second, opponent_name_);
}

int32_t
sc_guild_battle_t::get_guild_name(int32_t guild_id_, string& name_)
{
    auto it_name=guild_name_list.find(guild_id_);
    if (it_name==guild_name_list.end())
    {
        return ERROR_NO_SUCH_GANG;
    }

    name_ = it_name->second;
    return SUCCESS;
}

void
sc_guild_battle_t::load_guild_name()
{
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, name FROM Gang");
    db_service.sync_select(sql, res);
    guild_name_list.clear();

    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }
        sql_result_row_t& row_ = *res.get_row_at(i);
        int32_t guild_id = (int32_t)std::atoi(row_[0].c_str());
        string guild_name = row_[1];
        guild_name_list.insert(make_pair(guild_id, guild_name));
    }
    guild_name_list.insert(make_pair(-1, "社团守卫"));
}

void
sc_guild_battle_t::get_cur_host_guilds(unordered_map<int32_t, int32_t>& guild_list_)
{
    guild_list_.clear();
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid, hostnum FROM GuildBattleInfo WHERE state = 1");
    db_service.sync_select(sql, res);
    
    if (0 == res.affect_row_num())
    {
        return;
    }

    int32_t guild_id;
    int32_t hostnum;
    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        guild_id = (int32_t)std::atoi(row_[0].c_str());
        hostnum = (int32_t)std::atoi(row_[1].c_str());

        for (int32_t it_host : hosts)
        {
            if (it_host == hostnum)
            {
                if (guild_list_.find(guild_id) == guild_list_.end())
                    guild_list_.insert(make_pair(guild_id, 1));
                break;
            }
        }
    }
}

int32_t
sc_guild_battle_t::get_whole_guild_info(map<int32_t, sc_msg_def::guild_info>& info_list_)
{
    int32_t sum = fight_guild_info_list.size();
    if (0 == sum)
        return SUCCESS;
    vector<int32_t> sort_g;
    for (auto it_g=fight_guild_info_list.begin();it_g!=fight_guild_info_list.end();++it_g)
    {
        sort_g.push_back(it_g->first);
    }
    std::sort(sort_g.begin(), sort_g.end(), [&](const int32_t& g_a, const int32_t& g_b)
    {
        int32_t score_a, score_b;
        score_a = fight_guild_info_list.find(g_a)->second.total_score;
        score_b = fight_guild_info_list.find(g_b)->second.total_score;
        int32_t sign_time_a, sign_time_b;
        sign_time_a = fight_guild_info_list.find(g_a)->second.sign_time;
        sign_time_b = fight_guild_info_list.find(g_b)->second.sign_time;
        if (score_a > score_b)
        {
            return true;
        }
        if (score_a < score_b)
        {
            return false;
        }
        return (sign_time_a < sign_time_b);
    });
    int32_t index=1;
    for (auto it_g=sort_g.begin();it_g!=sort_g.end();++it_g)
    {
        sc_msg_def::guild_info info;
        fight_guild_info& f_info = fight_guild_info_list.find(*it_g)->second;
        info.guild_name = f_info.name;
        info.win = f_info.win;
        info.lose = f_info.lose;
        info.score = f_info.total_score;
        info_list_.insert(make_pair(index, info));
        index++;
    }
    return SUCCESS;
}
//==============================================================================================
//

/* 公会信息 state说明
 * 0 默认（重置以后）
 * 1 已报名
 * 2 已布阵
 */

sc_guild_battle_user_t::sc_guild_battle_user_t(sc_user_t& user_)
:m_user(user_), cur_fight_building_id(0), cur_fight_building_pos(0), win_count(0)
{
}

int32_t
sc_guild_battle_user_t::sign_up()
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        if (sp_guser->db.flag != gang_adm && sp_guser->db.flag != gang_chairman)
        {
            return ERROR_PERMISSION_DENIED;
        }
    }
    else
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    // 校验条件
    if (!guild_battle_s.sign_up_time())
    {
        return ERROR_NOT_IN_SIGH_UP_TIME;
    }
    if (sp_gang->db.level < 5)
    {
        return ERROR_GBATTLE_GANG_LEVEL;
    }

    // 写数据库
    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT ggid FROM GuildBattleInfo WHERE ggid = %d", sp_gang->db.ggid);
    db_service.sync_select(sql, res);

    char sql_new[256];
    if (0 == res.affect_row_num())
    {
        int32_t cur_sec = date_helper.cur_sec();
        sprintf(sql_new, "INSERT INTO `GuildBattleInfo` (`ggid`, `hostnum`, `score`, `opponent`, `state`, `is_win`, `sign_time`) VALUES (%d, %d, 0, -1, 1, 0, %d)", sp_gang->db.ggid, sp_gang->db.hostnum, cur_sec);
        db_service.sync_execute(sql_new);
    }
    else
    {
        sprintf(sql_new, "UPDATE `GuildBattleInfo` SET state = 1, is_win = 0 WHERE ggid = %d", sp_gang->db.ggid);
        db_service.sync_execute(sql_new);
    }
    return SUCCESS;
}

int32_t 
sc_guild_battle_user_t::get_defence_info(int32_t building_id_, sc_msg_def::ret_guild_battle_defence_info& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    int32_t code = guild_battle_s.get_arrange_building_defence_info(sp_gang->db.ggid, building_id_, ret_.defence_info);
    if (code != SUCCESS)
        return code;

    return SUCCESS;
}

int32_t 
sc_guild_battle_user_t::get_whole_defence_info(sc_msg_def::ret_guild_battle_whole_defence_info& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }
    
    // 获取守卫信息
    int32_t code = guild_battle_s.get_arrange_defence_info(sp_gang->db.ggid, m_user.db.uid, ret_.building_state, ret_.self_team);
    if (code != SUCCESS)
        return code;

    // 获取建筑等级信息
    for (auto it=repo_mgr.guild_battle.begin(); it!=repo_mgr.guild_battle.end(); ++it)
    {
        int building_level_id = it->second.id;
        ret_.building_level.insert(make_pair(building_level_id, guild_battle_s.get_arrange_building_level(sp_gang->db.ggid, building_level_id)));
    }

    code = guild_battle_s.get_opponent_guild_name(sp_gang->db.ggid, ret_.opponent_name);
    if (code != SUCCESS)
        return code;

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::defence_pos_on(sc_msg_def::req_guild_battle_defence_pos_on& jpk_)
{
    if (guild_battle_s.get_state() != 2)
    {
        return ERROR_NOT_IN_ARRANGE;
    }
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }
    if (date_helper.cur_sec() - sp_guser->db.lastenter < TIME_DAY)
    {
        return ERROR_CUR_G_B_ISNT_AVAILABLE;
    }

    // 判断已占据的位置是否超过了3个
    if (guild_battle_s.is_user_more_than_3(sp_gang->db.ggid, m_user.db.uid))
    {
        return ERROR_POS_MORE_THEN_3;
    }

    // 判断要上阵的人员是否已经上阵
    if (guild_battle_s.is_partner_on(sp_gang->db.ggid, m_user.db.uid, jpk_.team_info))
    {
        return ERROR_PID_REPEAT;
    }

    // 判断当前位置有没有人占了
    if (guild_battle_s.is_occupy(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos))
    {
        return ERROR_POS_OCCUPY;
    }

    // 占位置
    guild_battle_s.occupy_pos(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos, m_user.db.uid, jpk_.team_info, jpk_.fp);

    // 添加战斗人员
    guild_battle_s.arrange_add_user(sp_gang->db.ggid, m_user.db.uid);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::defence_pos_off(sc_msg_def::req_guild_battle_defence_pos_off& jpk_)
{
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    // 判断当前位置是否是自己
    if (!guild_battle_s.is_this_user(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos, m_user.db.uid))
    {
        return ERROR_NOT_THE_OWNER;
    }

    // 下阵
    guild_battle_s.off_pos(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos);
    
    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::cancel_others_pos(sc_msg_def::req_guild_battle_cancel_other_pos& jpk_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        if (sp_guser->db.flag != gang_adm && sp_guser->db.flag != gang_chairman)
        {
            return ERROR_PERMISSION_DENIED;
        }
    }
    else
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    // 判断当前位置有没有人占了
    if (!guild_battle_s.is_occupy(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos))
    {
        return ERROR_NO_SUCH_USER;
    }

    // 找对应user
    int32_t off_uid;
    guild_battle_s.get_arrange_uid(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos, off_uid);

    // 下阵 
    guild_battle_s.off_pos(sp_gang->db.ggid, jpk_.building_id, jpk_.building_pos);

    string mail = mailinfo.new_mail(mail_guild_battle_been_cancel_pos);
    if(!mail.empty())
        notify_ctl.push_mail(off_uid, mail);
    
    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::building_level_up(int32_t building_id_, int32_t old_level_, int32_t& new_level_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    // 校验等级
    int32_t b_level = guild_battle_s.get_arrange_building_level(sp_gang->db.ggid, building_id_);
    if (b_level != old_level_)
    {
        new_level_ = b_level;
        return ERROR_LEVEL_NOT_MATCH;
    }

    // 校验花费
    auto rp_building = repo_mgr.guild_battle.get(building_id_);
    if (NULL == rp_building)
    {
        logwarn((LOG, "load guild_battle, building_id %d not exists", building_id_));
        return ERROR_NO_SUCH_GB_REPO;
    }
    int32_t key = rp_building->type*100 + old_level_;
    auto rp_cost = repo_mgr.guild_battle_building.get(key);
    if (NULL == rp_cost)
    {
        logwarn((LOG, "load guild_battle_building, key %d not exists", key));
        return ERROR_NO_SUCH_GBB_REPO;
    }

    // 校验下一级是否存在
    int32_t key_next = rp_building->type*100 + old_level_+1;
    auto rp_building_next = repo_mgr.guild_battle_building.get(key);
    if (NULL == rp_building_next)
    {
        return ERROR_NO_SUCH_GB_REPO;
    }

    if (m_user.db.gold < rp_cost->gold_spend )
    {
        return ERROR_LEVEL_UP_MONEY;
    }
    
    new_level_ = old_level_+1;
    guild_battle_s.set_arrange_building_level(sp_gang->db.ggid, building_id_, new_level_); 
    m_user.consume_gold(rp_cost->gold_spend);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::get_whole_defence_info_fight(sc_msg_def::ret_guild_battle_whole_defence_info_fight& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    guild_battle_s.get_guild_fight_state_list(sp_gang->db.ggid, ret_.building_state);
    
    if (ret_.building_state.size() == 0)
        return ERROR_NO_BUILDING_STATE;

    int32_t code = guild_battle_s.get_guild_building_level_list(sp_gang->db.ggid, ret_.building_level);
    if (code != SUCCESS)
        return code;

    code = guild_battle_s.get_fight_partner(m_user.db.uid, ret_.partners);
    if (code != SUCCESS)
        return code;

    fight_user_info info;
    code = guild_battle_s.get_user_fight_info(m_user.db.uid, info);
    if (code != SUCCESS)
        return code;
    ret_.rest_times = info.rest_times;
    ret_.have_buy_times = info.have_buy_times;
    ret_.score = info.score;
    int32_t cur_sec = date_helper.cur_sec();
    int32_t cool_down = 900 - (cur_sec - info.last_fight_time);
    ret_.cool_down = (cool_down>0)?cool_down+10:0;

    // 向该公会的人添加该战斗人员
    guild_battle_s.add_fighter(sp_gang->db.ggid, m_user.db.uid);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::get_defence_info_fight(int32_t building_id_, sc_msg_def::ret_guild_battle_defence_info_fight& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    int32_t code = guild_battle_s.get_guild_building_fight_info(sp_gang->db.ggid, building_id_, ret_.defence_state, ret_.defence_info);
    if (code != SUCCESS)
        return code;

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::fight(int32_t building_id_, int32_t building_pos_, vector<int32_t>& partners_, sc_msg_def::ret_guild_battle_fight& ret_)
{
    if (guild_battle_s.get_state() != 3)
    {
        return ERROR_NOT_IN_FIGHT;
    }
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    // 校验是否能攻击
    int state;
    int code = guild_battle_s.get_pos_state(sp_gang->db.ggid, building_id_, building_pos_, state);
    if (code != SUCCESS)
        return code;

    if (state == 2 || state == 3)
        return ERROR_IN_FIGHT_OR_END;

    string view_data;
    int32_t anger_enemy;
    code = guild_battle_s.get_fight_view(sp_gang->db.ggid, building_id_, building_pos_, view_data, anger_enemy, cur_fight_opponent);
    if (code != SUCCESS)
        return code;
    ret_.view_data = view_data;
    ret_.anger_enemy = anger_enemy;;

    fight_user_info info;
    code = guild_battle_s.get_user_fight_info(m_user.db.uid, info);
    if (code != SUCCESS)
        return code;
    ret_.anger = info.anger;

    for (auto it=partners_.begin(); it!=partners_.end(); ++it)
    {
        ret_.partners.insert(make_pair(*it, 0));
    }
    code = guild_battle_s.get_fight_partner(m_user.db.uid, ret_.partners);
    if (code != SUCCESS)
        return code;

    guild_battle_s.user_fight(m_user.db.uid);

    cur_fight_building_id = building_id_;
    cur_fight_building_pos = building_pos_;

    guild_battle_s.set_pos_state(sp_gang->db.ggid, building_id_, building_pos_, 2);
    guild_battle_s.add_fight(sp_gang->db.ggid, building_id_, building_pos_);

    guild_battle_s.get_enemy_hp(sp_gang->db.ggid, building_id_, building_pos_, ret_.enemy_team);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::fight_end(bool is_win_, int32_t anger_, int32_t anger_enemy_, vector<sc_msg_def::jpk_guild_battle_partner_t>& partners_, int32_t& cool_down_, sc_msg_def::req_guild_battle_fight_end& jpk_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    fight_user_info info;
    int32_t code = guild_battle_s.get_user_fight_info(m_user.db.uid, info);
    if (code != SUCCESS)
        return code;
    int32_t cur_sec = date_helper.cur_sec();
    int32_t cool_down = 900 - (cur_sec - info.last_fight_time);
    cool_down_ =(cool_down>0)?cool_down+10:0;

    if (is_win_)
    {
        win_count++;

        // 状态切换
        if (guild_battle_s.set_pos_state(sp_gang->db.ggid, cur_fight_building_id, cur_fight_building_pos, 3))
        {
            int32_t building_type;
            auto rp_building = repo_mgr.guild_battle.get(cur_fight_building_id);
            if (NULL == rp_building)
            {
                building_type = 4;
            }
            else
            {
                building_type = rp_building->type;
            }
            int32_t building_level;
            guild_battle_s.get_guild_building_level(sp_gang->db.ggid, cur_fight_building_id, building_level);
            int32_t id = building_type*100+building_level;
            auto rp_building_cost = repo_mgr.guild_battle_building.get(id);
            int32_t extra_score;
            if (NULL == rp_building_cost)
            {
                extra_score = 50;
            }
            else
            {
                extra_score = rp_building_cost->score;
            }
            //cout <<"buildind score: " <<building_type <<" " <<building_level << " "<<extra_score<<endl;
            
            guild_battle_s.add_guild_score(sp_gang->db.ggid, extra_score);
            guild_battle_s.add_user_score(m_user.db.uid, extra_score);   
        }

        // 增加胜利数
        guild_battle_s.user_attack_end(m_user.db.uid, true);
        guild_battle_s.user_defence_end(cur_fight_opponent, false);

        // 生成战报
        //cout << " add_fight_info " << endl;
        guild_battle_s.add_fight_info(m_user.db.uid, cur_fight_opponent, sp_gang->db.ggid, 1, win_count, cur_fight_building_id, cur_fight_building_pos);

        // 测试积分获取
        int32_t attack_win_score = repo_mgr.configure.find(25)->second.value;
        guild_battle_s.add_guild_score(sp_gang->db.ggid, attack_win_score);
        guild_battle_s.add_user_score(m_user.db.uid, attack_win_score);   
    }
    else
    {
        // 状态切换
        guild_battle_s.set_pos_state(sp_gang->db.ggid, cur_fight_building_id, cur_fight_building_pos, 1);
        
        // 增加胜利数
        guild_battle_s.user_attack_end(m_user.db.uid, false);
        guild_battle_s.user_defence_end(cur_fight_opponent, true);

        // 生成战报
        guild_battle_s.add_fight_info(m_user.db.uid, cur_fight_opponent, sp_gang->db.ggid, 0, win_count, cur_fight_building_id, cur_fight_building_pos);

        // 测试积分获取
        int32_t defence_win_score = repo_mgr.configure.find(26)->second.value;
        guild_battle_s.add_guild_score_e(sp_gang->db.ggid, defence_win_score);
        guild_battle_s.add_user_score(cur_fight_opponent, defence_win_score);   

        // 更新对手信息
        guild_battle_s.update_guild_opponent_user_info(sp_gang->db.ggid);
    }

    map<int32_t, float> partners_map;
    for (auto it=partners_.begin(); it!=partners_.end(); ++it)
    {
        partners_map.insert(make_pair(it->pid, it->hp));
    }
    guild_battle_s.update_fight_partner(m_user.db.uid, partners_map);

    guild_battle_s.save_user_anger(m_user.db.uid, anger_);

    guild_battle_s.del_fight(sp_gang->db.ggid, cur_fight_building_id, cur_fight_building_pos);

    guild_battle_s.set_enemy_anger(sp_gang->db.ggid, cur_fight_building_id, cur_fight_building_pos, anger_enemy_);
    guild_battle_s.set_enemy_hp(sp_gang->db.ggid, cur_fight_building_id, cur_fight_building_pos, jpk_.hp1, jpk_.hp2, jpk_.hp3, jpk_.hp4, jpk_.hp5);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::cur_state(int32_t& g_state_, int32_t& gb_state_)
{
    gb_state_ = guild_battle_s.get_state();

    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT state FROM GuildBattleInfo WHERE ggid = %d", sp_gang->db.ggid);
    db_service.sync_select(sql, res);

    if (0 == res.affect_row_num())
    {
        g_state_ = 0;
    }
    else
    {
        sql_result_row_t& row_ = *res.get_row_at(0);
        g_state_ = (int32_t)std::atoi(row_[0].c_str());
    }

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::buy_fight_times()
{
    fight_user_info info;
    int32_t code = guild_battle_s.get_user_fight_info(m_user.db.uid, info);
    if (code != SUCCESS)
        return code;

    int32_t consume = 100*(info.have_buy_times+1);
    if (m_user.rmb() < consume)
    {
        return ERROR_NOT_ENOUGH_RMB;
    }

    guild_battle_s.add_fight_times(m_user.db.uid);
    m_user.consume_yb(consume);
    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::clear_fight_cd()
{
    fight_user_info info;
    int32_t code = guild_battle_s.get_user_fight_info(m_user.db.uid, info);
    if (code != SUCCESS)
        return code;

    int32_t consume = 50;
    if (m_user.rmb() < consume)
    {
        return ERROR_NOT_ENOUGH_RMB;
    }

    guild_battle_s.clear_fight_cd(m_user.db.uid);
    m_user.consume_yb(consume);
    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::spy(int32_t building_id_, int32_t building_pos_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }


    // 校验是否能侦查
    int state;
    int code = guild_battle_s.get_pos_state(sp_gang->db.ggid, building_id_, building_pos_, state);
    if (code != SUCCESS)
        return code;

    if (state != 0)
    {
        return ERROR_CANT_SPY;
    }

    int32_t consume = 20;
    if (m_user.rmb() < consume)
    {
        return ERROR_NOT_ENOUGH_RMB;
    }

    guild_battle_s.set_pos_state(sp_gang->db.ggid, building_id_, building_pos_, 1);
    m_user.consume_yb(consume);
    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::get_guild_fight_info(sc_msg_def::ret_guild_battle_fight_record_info& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }
    
    int32_t code = guild_battle_s.get_AllBattleLog(sp_gang->db.ggid, ret_);
    if (code != SUCCESS)
        return code;

    code = guild_battle_s.get_battle_log_names(sp_gang->db.ggid, ret_.name_mvp, ret_.name_attacker, ret_.name_defencer);
    if (code != SUCCESS)
        return code;

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::get_guild_battle_info(sc_msg_def::ret_guild_battle_fight_info& ret_)
{
    // 校验身份
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (!gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        return ERROR_NO_SUCH_GANG_USER;
    }

    int32_t code = guild_battle_s.get_user_battle_log(sp_gang->db.ggid, m_user.db.uid, ret_.self_info);
    if (code != SUCCESS)
        return code;
    code = guild_battle_s.get_gfight_info(sp_gang->db.ggid, ret_.guild_fight_info_list);
    if (code != SUCCESS)
        return code;
    code = guild_battle_s.get_gfight_info_e(sp_gang->db.ggid, ret_.enemy_fight_info_list);
    if (code != SUCCESS)
        return code;

    code = guild_battle_s.get_guild_name(sp_gang->db.ggid, ret_.guild_name);
    if (code != SUCCESS)
        return code;
    code = guild_battle_s.get_opponent_guild_name(sp_gang->db.ggid, ret_.guild_name_enemy);
    if (code != SUCCESS)
        return code;

    guild_battle_s.get_guild_score(sp_gang->db.ggid, ret_.score);
    guild_battle_s.get_opponent_guild_score(sp_gang->db.ggid, ret_.score_enemy);

    return SUCCESS;
}

int32_t
sc_guild_battle_user_t::get_guild_info(sc_msg_def::ret_guild_battle_guild_info& ret_)
{
    int32_t code = guild_battle_s.get_whole_guild_info(ret_.guild_info_list);
    ret_.cur_turn = guild_battle_s.cur_turn;
    return code;
}
