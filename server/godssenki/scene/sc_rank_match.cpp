#include "sc_rank_match.h"
#include "sc_rank_season.h"
#include "sc_arena_rank.h"
#include "date_helper.h"
#include "sc_cache.h"
#include "sc_logic.h"
#include "sc_statics.h"
#include "sc_user.h"
#include "random.h"

#define LOG "SC_RANK_MATCH"
#define MAX_RESERVE_SIZE 10

sc_rank_match_t::sc_rank_match_t()
{
    init_constant();
    default_get = false;
}

//服务器启动时 从数据库读取缓存的备用队列
    void
sc_rank_match_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load rank match ..."));
    host_num = hostnums_[0];
    
    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }

    str_hosts = str_hosts.substr(0, str_hosts.length()-1);
    char sql[256];
    sql_result_t res;

    sprintf(sql, "select uid, req_times, stamp, rank_type from RankMatch where hostnum in (%s);", str_hosts.c_str());
    db_service.sync_select(sql, res);

    int32_t uid = 0;
    int32_t req_times = 0;
    int32_t stamp = 0;
    int r_t = 63;
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int32_t)std::atoi(row_[0].c_str());
        req_times=(int32_t)std::atoi(row_[1].c_str());
        stamp=(int32_t)std::atoi(row_[2].c_str());
        r_t=(int)std::atoi(row_[3].c_str());
        
        queue_member q_m;
        q_m.uid = uid;
        q_m.req_times = req_times;
        q_m.stamp = stamp;
        reserve_queue[r_t].insert(make_pair(q_m.uid, q_m));
    }
}

    int32_t
sc_rank_match_t::match(int32_t uid_, sc_msg_def::req_rank_season_match_t& jpk_, sp_user_t sp_user_)
{
    user_info_set user_info;
    int32_t month,day,hour;
    int32_t ret = rank_season_s.find_user(uid_, user_info, sp_user_,month,day,hour);
    if (SUCCESS != ret)
        return ret;
    // 首先在online中匹配
    // 匹配成功则往备用队列里添加该user，在online中删除他和被匹配到的成员
    // 匹配失败则更新online队列以及备用队列


    auto it_match_mem = online_queue[user_info.rank].begin();
    bool success_match = false;
    int32_t match_uid = 0;
    //随机，四次难度提升, 采用默认数据

    logwarn((LOG, "match begin %d ...", uid_));
        //同级匹配
    if (!success_match)
    {
        while(!success_match && (it_match_mem != online_queue[user_info.rank].end()))
        {
            if (it_match_mem->second.uid != uid_)
                success_match = true;
            else
                it_match_mem++;
        }
    }
    // 往上匹配1级
    int next1_rank = get_rank(user_info.rank,1);
    if (!success_match && (next1_rank != user_info.rank))
    {
        while(!success_match && (it_match_mem != online_queue[next1_rank].end()))
        {
            if (it_match_mem->second.uid != uid_)
                success_match = true;
            else
                it_match_mem++;
        }
    }
    // 往下匹配1级
    int prev1_rank = get_rank(user_info.rank,-1);
    if (!success_match && (prev1_rank != user_info.rank))
    {
        while(!success_match && (it_match_mem != online_queue[prev1_rank].end()))
        {
            if (it_match_mem->second.uid != uid_)
                success_match = true;
            else
                it_match_mem++;
        }
    }
    // 往上匹配2级
    int next2_rank = get_rank(user_info.rank,2);
    if (!success_match && (next2_rank != user_info.rank))
    {
        while(!success_match && (it_match_mem != online_queue[next2_rank].end()))
        {
            if (it_match_mem->second.uid != uid_)
                success_match = true;
            else
                it_match_mem++;
        }
    }
    // 往下匹配2级
    int prev2_rank = get_rank(user_info.rank,-2);
    if (!success_match && (prev2_rank != user_info.rank))
    {
        while(!success_match && (it_match_mem != online_queue[prev2_rank].end()))
        {
            if (it_match_mem->second.uid != uid_)
            {
                success_match = true;
            }
            else
            {
                it_match_mem++;
            }
        }
    }

    auto it_user_mem = online_queue[user_info.rank].find(uid_);
    // 向在线和备用队列中更新该角色；如果有该角色，判断时候到等待阈值，到了以后从备用队列或者其他服队列中找角色进行战斗
    if (it_user_mem == online_queue[user_info.rank].end())
    {
        //第一次请求
        queue_member q_m_online;
        q_m_online.stamp = date_helper.cur_sec();
        q_m_online.uid = uid_;
        q_m_online.req_times = 1;
        online_push_back(user_info.rank, q_m_online);

        queue_member q_m_reserve;
        q_m_reserve.stamp = date_helper.cur_sec();
        q_m_reserve.uid = uid_;
        reserve_push_back(user_info.rank, q_m_reserve, jpk_.team);
        it_user_mem = online_queue[user_info.rank].find(uid_);
    }
    else
    {
        queue_member q_m_reserve;
        q_m_reserve.stamp = date_helper.cur_sec();
        q_m_reserve.uid = uid_;
        reserve_push_back(user_info.rank, q_m_reserve, jpk_.team);
    }

    int32_t rate = random_t::rand_integer(1, 100); 
    if(rate > 25)
    {
        if (success_match)
        {
            // 在线队列匹配成功
            online_pop(user_info.uid);
            online_pop(it_match_mem->second.uid);

            auto it_role = cur_view_cache.find(it_match_mem->second.uid);
            auto it_enmey = cur_view_cache.find(user_info.uid);
            if ( it_role == cur_view_cache.end() || it_enmey == cur_view_cache.end())
            {
                return ERROR_SC_EXCEPTION;
            }
            sc_msg_def::nt_rank_match_fight_t nt_, nt_enmey_;
            (*(it_role->second)) >> nt_.view_data;
            (*(it_role->second)) >> nt_enmey_.view_data_self;
            (*(it_enmey->second)) >> nt_enmey_.view_data;
            (*(it_enmey->second)) >> nt_.view_data_self;
            logic.unicast(user_info.uid, nt_);
            logic.unicast(it_match_mem->second.uid, nt_enmey_);
            statics_ins.unicast_eventlog(*sp_user_,8888,0,it_match_mem->second.uid,0);
            return SUCCESS;
        }
        if (it_user_mem->second.req_times < 3)
        {
            //前3次请求 等待
            it_user_mem->second.req_times++;
            return SUCCESS;
        }

        online_pop(user_info.uid);
        // 如果备用队列里面所有被引用的次数都到达了3 则从其他服务器队里找人
        for (auto it=reserve_queue[user_info.rank].begin();it !=reserve_queue[user_info.rank].end();it++)
        {
            if ((it->second.req_times <= 3) && (it->second.uid != uid_))
            {
                it->second.req_times++;
                match_uid = it->second.uid;
                success_match = true;
                break;
            }
        }
        if (success_match)
        {
            // 备用队列匹配成功
            sc_msg_def::nt_rank_match_fight_t nt_;
            auto it_reserve = cur_view_cache.find(match_uid);
            if (it_reserve == cur_view_cache.end())
                return ERROR_SC_EXCEPTION; 
            auto it_self = cur_view_cache.find(uid_);
            (*(it_reserve->second)) >> nt_.view_data;
            (*(it_self->second)) >> nt_.view_data_self;
            logic.unicast(user_info.uid, nt_);
            statics_ins.unicast_eventlog(*sp_user_,8888,1,match_uid,0);
            return SUCCESS;
        }

        //如果跨服队列里没有人，则更新列表，更新完了还没人，用默认数据
        if (other_reserve_queue[get_rank_grade(user_info.rank)].size() == 0)
        {
            update_host_queue_info();
        }
        if (other_reserve_queue[get_rank_grade(user_info.rank)].size() != 0)
        {
            // 跨服队列匹配
            auto it = other_reserve_queue[get_rank_grade(user_info.rank)].begin();
            match_uid = it->second.uid;
            sc_msg_def::nt_rank_match_fight_t nt_;
            auto it_self = cur_view_cache.find(uid_);
            nt_.view_data = other_reserve_cache[match_uid];
            (*(it_self->second)) >> nt_.view_data_self;
            logic.unicast(user_info.uid, nt_);
            statics_ins.unicast_eventlog(*sp_user_,8888,2,match_uid,0);
            other_reserve_queue[get_rank_grade(user_info.rank)].erase(it);
            return SUCCESS;
        }
    }
    // 增加一步
    int32_t pids[5] = {-1, -1, -1, -1, -1};
    match_uid = get_default_fight_user(uid_, user_info.rank, pids);
    logwarn((LOG, "match SUCCESS %d ...", match_uid));
    if (match_uid != 0)
    {
        sc_msg_def::nt_rank_match_fight_t nt_;
        auto it_self = cur_view_cache.find(uid_);
        logwarn((LOG, "view_data_self get %d ...", uid_));
        (*(it_self->second)) >> nt_.view_data_self;

        logwarn((LOG, "view_data_self done %d ...", uid_));
        sp_fight_view_user_t new_view = view_cache.get_rank_view(match_uid, pids);
        (*new_view) >> nt_.view_data;

        logwarn((LOG, "new_view done %d ...", match_uid));
        logic.unicast(user_info.uid, nt_);

        logwarn((LOG, "nt back ..."));
        statics_ins.unicast_eventlog(*sp_user_,8888, user_info.rank, match_uid, rate + 1000);
        return SUCCESS;
    }

    // 默认数据匹配
    if (!default_get)
    {
        init_default_user();
        default_get = true;
    }
    sc_msg_def::nt_rank_match_fight_t nt_;
    auto it_self = cur_view_cache.find(uid_);
    (*(it_self->second)) >> nt_.view_data_self;
    (*get_default_fight_view()) >> nt_.view_data;
    logic.unicast(user_info.uid, nt_);
    statics_ins.unicast_eventlog(*sp_user_,8888,0,0,0);
    
    return SUCCESS;
}

int32_t sc_rank_match_t::get_default_fight_user(int32_t uid_, int32_t rank_, int32_t* pids)
{    
    int32_t uid_default = arena_rank.get_rank()[random_t::rand_integer(1, 30)];

    logwarn((LOG, "get_user from rank %d ...", uid_default));

    char buf[1024];

    sql_result_t res_;
    if(random_t::rand_integer(1, 100) > 33)
    {
        sprintf(buf, "SELECT `uid` FROM `RankSeason` WHERE rank <= %d and rank >= %d - 10 and uid != %d order by rand() limit 1", rank_, rank_, uid_);
        db_service.sync_select(buf, res_);
        if (res_.affect_row_num() > 0)    
        {
            sql_result_row_t& row_ = *res_.get_row_at(0);
            uid_default=(int32_t)std::atoi(row_[0].c_str());
            logwarn((LOG, "get_user RankSeason %d ...", uid_default));
        }
    }

    sql_result_t res;
    memset(buf, 0, sizeof(buf));
    sprintf(buf, "SELECT p1, p2, p3, p4, p5 FROM Team WHERE uid = %d and is_default = 1", uid_default);
    db_service.sync_select(buf, res);
    if (res.affect_row_num() > 0)    
    {
        sql_result_row_t& row_ = *res.get_row_at(0);
        pids[0]=(int32_t)std::atoi(row_[0].c_str());
        pids[1]=(int32_t)std::atoi(row_[1].c_str());
        pids[2]=(int32_t)std::atoi(row_[2].c_str());
        pids[3]=(int32_t)std::atoi(row_[3].c_str());
        pids[4]=(int32_t)std::atoi(row_[4].c_str());
    }

    return uid_default;
}

    int32_t
sc_rank_match_t::cancel_wait(int32_t uid_, sp_user_t sp_user_)
{
    user_info_set user_info;
    int32_t month,day,hour;
    int32_t ret = rank_season_s.find_user(uid_, user_info, sp_user_,month,day,hour);
    if (SUCCESS != ret)
        return ret;
    // 在online中找到等待匹配的用户 
    online_pop(uid_);
}

    void
sc_rank_match_t::update_db_user_info(queue_member& q_m, int r_t, sp_fight_view_user_t view_)
{
    sql_result_t res;
    if (0 == db_RankMatch_t::sync_select_uid(q_m.uid, res))
    {
        // 更新数据
        db_RankMatch_t db;
        db.uid          = q_m.uid;
        db.req_times    = 0;
        db.stamp        = 0;
        db.rank_type    = r_t;
        db.hostnum      = host_num;
        (*view_) >> db.view_data;
        db_service.async_do((uint64_t)q_m.uid, [](db_RankMatch_t& db_){
            db_.update();
        }, db);
    }
    else
    {
        // 插入数据
        db_RankMatch_t db;
        db.uid          = q_m.uid;
        db.req_times    = 0;
        db.stamp        = 0;
        db.rank_type    = r_t;
        db.hostnum      = host_num;
        (*view_) >> db.view_data;

        db_service.async_do((uint64_t)q_m.uid, [](db_RankMatch_t& db_) {
            db_.insert();
        }, db);
    }
}

/*
    void
sc_rank_match_t::save_queue_info()
{
    string m_sql;
    m_sql = "INSERT INTO `RankMatch` ( `uid` , `req_times` , `stamp` , `hostnum` , `rank_type`, `view_data` ) VALUES";
    int count = 0;
    for (auto it=reserve_queue.begin(); it!=reserve_queue.end(); ++it)
    {
        for (auto it2=it->second.begin(); it2!=it->second.end(); ++it2)
        {
        count++;
            string view_data;
            auto it_cache = cur_view_cache.find(it2->second.uid);
            if (it_cache == cur_view_cache.end())
                continue;
            (*(it_cache->second)) >> view_data;
            char tmp_sql[256];
            sprintf(tmp_sql, "(%d, %d, %d, %d, %d, '%s'),", it2->second.uid, it2->second.req_times, it2->second.stamp, host_num, int(it->first), view_data.c_str());
            cout << it2->second.uid << endl;
            cout << it2->second.req_times << endl;
            cout << it2->second.stamp << endl;
            cout << host_num << endl;
            cout << it->first << endl;
            cout << view_data << endl;
            m_sql += string(tmp_sql);
        }
    }
    if (count == 0)
        return;
    m_sql = m_sql.substr(0, m_sql.length()-1);
    m_sql += " ON DUPLICATE KEY UPDATE";
    cout << m_sql << endl;
    db_service.async_execute(m_sql);
}
*/

    void
sc_rank_match_t::update_host_queue_info()
{
    for (auto it=other_reserve_queue.begin();it != other_reserve_queue.end(); ++it)
    {
        it->second.clear();
    }
    other_reserve_cache.clear();

    logwarn((LOG, "update other host queue info ..."));
    /*
    vector<int32_t> hostnums_;
    hostnums_.push_back(host_num-2);
    hostnums_.push_back(host_num-1);
    hostnums_.push_back(host_num+1);
    hostnums_.push_back(host_num+2);
    
    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }

    str_hosts = str_hosts.substr(0, str_hosts.length()-1);
    */
    char sql[256];
    sql_result_t res;

    //sprintf(sql, "select uid, req_times, stamp, rank_type from RankMatch where hostnum in (%s);", str_hosts.c_str());
    sprintf(sql, "select uid, req_times, stamp, rank_type, view_data from RankMatch WHERE hostnum != %d", host_num);
    db_service.sync_select(sql, res);

    int32_t uid = 0;
    int32_t req_times = 0;
    int32_t stamp = 0;
    int r_t = 63;
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int32_t)std::atoi(row_[0].c_str());
        req_times=(int32_t)std::atoi(row_[1].c_str());
        stamp=(int32_t)std::atoi(row_[2].c_str());
        r_t=(int)std::atoi(row_[3].c_str());
        other_reserve_cache.insert(make_pair(uid, row_[4].c_str()));
        
        queue_member q_m;
        q_m.uid = uid;
        q_m.req_times = req_times;
        q_m.stamp = stamp;
        other_reserve_queue[get_rank_grade(r_t)].insert(make_pair(q_m.uid, q_m));
    }
}

// 在线队列中添加成员
    void
sc_rank_match_t::online_push_back(int r_t, queue_member& q_m)
{
    online_queue[r_t].insert(make_pair(q_m.uid, q_m));
}

// 在线队列中移除成员
    void
sc_rank_match_t::online_pop(int32_t uid_)
{
    for(auto it=online_queue.begin(); it!=online_queue.end(); ++it)
    {
        it->second.erase(uid_);
    }
}

// 备用队列中添加成员
    void
sc_rank_match_t::reserve_push_back(int r_t, queue_member& q_m, yarray_t<int32_t, 5>& team_)
{
    int32_t pid_[5];
    for(int i=0; i<5; ++i)
    {
        pid_[i] = team_[i];
    }
    
    bool is_insert = false;
    auto it = reserve_queue[r_t].find(q_m.uid);
    if (it == reserve_queue[r_t].end())
    {
        is_insert = true;
        // 队列中没有 则检测是否超过最大个数限制 超过则把最老的干掉
        if (reserve_queue[r_t].size() >= MAX_RESERVE_SIZE)
        {
            int32_t old_stamp = date_helper.cur_sec();
            int32_t erase_uid = 0;
            for(auto it2=reserve_queue[r_t].begin();it2!=reserve_queue[r_t].end();it2++)
            {
                if (it2->second.stamp > old_stamp)
                {
                    erase_uid = it2->first;
                    old_stamp = it2->second.stamp;
                }
            }
            if (erase_uid !=0)
                reserve_queue[r_t].erase(erase_uid);
        }
        q_m.req_times = 0;
        reserve_queue[r_t].insert(make_pair(q_m.uid, q_m));
    }
    else
    {
        it->second.stamp = q_m.stamp;
    }

    /* 把新的信息 放入缓存 */
    sp_fight_view_user_t new_view = view_cache.get_rank_view(q_m.uid, pid_);
    auto it2 = cur_view_cache.find(q_m.uid); 
    if (it2 != cur_view_cache.end())
        cur_view_cache.erase(q_m.uid);
    cur_view_cache.insert(make_pair(q_m.uid, new_view));

    /*更新该用户的数据库数据*/
    if (is_insert)
        update_db_user_info(q_m, r_t, new_view);
}

    int
sc_rank_match_t::get_rank(int r_t, int32_t delta_)
{
    int find_rank_type = r_t;
    if (delta_ > 0)
    {
        for(int i=0;i<delta_;++i)
        {
            auto rp = repo_mgr.rank_season.get(find_rank_type);
            if (NULL == rp)
            {
                logwarn((LOG, "load_repo, rank %d not exists", find_rank_type));
                return r_t;
            } 
            find_rank_type = rp->win_rank;
        }
    }
    else if (delta_ < 0)
    {
        for(int i=0;i>delta_;--i)
        {
            auto rp = repo_mgr.rank_season.get(find_rank_type);
            if (NULL == rp)
            {
                logwarn((LOG, "load_repo, rank %d not exists", find_rank_type));
                return r_t;
            } 
            find_rank_type = rp->lose_rank;
        }
    }
    return find_rank_type;
}

    int
sc_rank_match_t::get_rank_grade(int r_t)
{
    return int(r_t/10);
}

    void
sc_rank_match_t::init_constant()
{
    //online 队列初始化
    for (auto it=repo_mgr.rank_season.begin();it!=repo_mgr.rank_season.end();++it)
    {
        online_queue.insert(make_pair(it->second.id, unordered_map<int32_t, queue_member>()));
    }
    
    //备用队列初始化
    for (auto it=repo_mgr.rank_season.begin();it!=repo_mgr.rank_season.end();++it)
    {
        reserve_queue.insert(make_pair(it->second.id, unordered_map<int32_t, queue_member>()));
    }

    //其他服务器队列初始化
    for (int i=1; i<=6; ++i)
    {
        other_reserve_queue.insert(make_pair(i, unordered_map<int32_t,queue_member>()));
    }
}

    void
sc_rank_match_t::init_default_user()
{
    default_user_pid.clear();
    sp_user_t sp_user;
    sp_user.reset(new sc_user_t);
    sql_result_t res_;
    char buf[4096];
    sprintf(buf, "SELECT `uid` FROM `UserInfo` WHERE `rank` = 1 AND `hostnum` = %d", host_num);
    db_service.sync_select(buf, res_);
    sql_result_row_t& row_ = *res_.get_row_at(0);
    int32_t uid_default=(int32_t)std::atoi(row_[0].c_str());
    sp_user->load_db(uid_default);
    sp_user->partner_mgr.foreach([&](sp_partner_t partner_){
        sc_msg_def::jpk_fight_view_role_data_t view;
        partner_->get_jpk_rank_view_data(view, 0, 0);
        default_user_view.insert(std::move(make_pair(partner_->db.pid, view)));
        default_user_pid.push_back(partner_->db.pid);
    });

    sc_msg_def::jpk_fight_view_role_data_t view_0;
    sp_user->get_jpk_rank_view_data(view_0, 0, 0);
    default_user_view.insert(std::move(make_pair(0, view_0)));
    default_user_pid.push_back(0);
}

    sp_fight_view_user_t
sc_rank_match_t::get_default_fight_view()
{
    sp_fight_view_user_t sp_fight_view(new sc_msg_def::jpk_fight_view_user_data_t());
    sp_fight_view->uid = 203525;
    sp_fight_view->name = "";
    sp_fight_view->rank = 20;
    sp_fight_view->lv = 20;
    sp_fight_view->viplevel = 10;
    sp_fight_view->combo_pro.combo_d_down = 0;
    sp_fight_view->combo_pro.combo_r_down = 0;
    sp_fight_view->combo_pro.combo_d_up = 0;
    sp_fight_view->combo_pro.combo_r_up = 0;
    sp_fight_view->combo_pro.combo_anger.insert(make_pair(50,0));

    for(int i=1; i<=5; ++i)
    {
        int32_t r = random_t::rand_integer(0,default_user_pid.size()-i);
        int32_t pid = default_user_pid[r];
        sc_msg_def::jpk_fight_view_role_data_t role(default_user_view.find(pid)->second);
        sp_fight_view->roles.insert(std::move(make_pair(pid,std::move(role))));
        swap(default_user_pid[r],default_user_pid[default_user_pid.size()-1]);
    }
    return sp_fight_view;
}
