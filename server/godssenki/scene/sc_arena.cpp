#include "sc_arena.h"
#include "repo_def.h"
#include "code_def.h"
#include "date_helper.h"
#include "random.h"
#include "config.h"

#include "sc_server.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_arena_rank.h"
#include "sc_cache.h"
#include "sc_battle_pvp.h"
#include "sc_arena_page_cache.h"
#include "sc_push_def.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_card_event.h"

#define LOG "SC_ARENA"
#define OFFTIME (21*3600)
#define MAX_FIGHT_COUNT (5)
#define DAILY_TASK_BEGIN_LEVEL 21
#define MAX_FIGHT_TIME_INTVAL (480)  /* 8 minutes */
#define CLEAR_COOLING_TIME_CONSUME_YB 10 /* 消耗10钻石 */

sc_arena_t::sc_arena_t(sc_user_t& user_):
    m_user(user_),m_salt(""),m_fight_time(0),m_flag(0)
{
}
void sc_arena_t::init_new_user()
{
    m_user.db.set_rank(arena_rank.add_user(m_user.db.uid, 0));
    if(m_user.db.m_rank ==0){
        string str_hosts;
        char tmp_sql[512];
        sql_result_t tmp_res;
        sprintf(tmp_sql, "SELECT hostnum FROM ArenaHostGroup WHERE arena_group = (SELECT arena_group FROM ArenaHostGroup WHERE hostnum = %d)",m_user.db.hostnum);
        db_service.sync_select(tmp_sql,tmp_res);
        size_t tmp_num = tmp_res.affect_row_num();
        if (tmp_num == 0)
            str_hosts.append(std::to_string(m_user.db.hostnum)+",");
        else
            for(size_t i = 0; i < tmp_num; i ++)
            {   
                if (tmp_res.get_row_at(i) == NULL)
                {   
                    logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                    break;
                }   

                sql_result_row_t& row_t = *tmp_res.get_row_at(i);
                int tmp_host = (int)std::atoi(row_t[0].c_str());
                str_hosts.append(std::to_string(tmp_host)+",");
            }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);
        char rank_sql[512];
        sql_result_t rank_res;
        sprintf(rank_sql, "SELECT max(m_rank+1) FROM UserInfo WHERE hostnum in (%s)", str_hosts.c_str());
        db_service.sync_select(rank_sql,rank_res);
        //size_t rank_num = rank_res.affect_row_num();
        int max_rank = 1;
        //if(rank_num > 0){
            sql_result_row_t& row_ = *rank_res.get_row_at(0);
            if(!row_.empty())
                max_rank = (int)std::atoi(row_[0].c_str());
        //}
        m_user.db.set_m_rank(max_rank);
    }
    m_user.save_db();

    db.uid=m_user.db.uid;
    db.fight_count=MAX_FIGHT_COUNT;
    db.in_fight_count=MAX_FIGHT_COUNT;
    db.win_count = 0;
    db.stamp=0;
    db.in_stamp=0;
    db.n_buy=0;
    db.in_buy=0;
    db.target_id=0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
            db_.insert();
    }, db);
}
void sc_arena_t::load_db()
{
    sql_result_t res;
    if (0==db_Arena_t::sync_select(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        db.uid=m_user.db.uid;
        db.fight_count=MAX_FIGHT_COUNT;
        db.in_fight_count=MAX_FIGHT_COUNT;
        db.win_count = 0;
        db.stamp=0;
        db.in_stamp=0;
        db.n_buy=0;
        db.in_buy=0;
        db.target_id=0;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
                db_.insert();
        }, db);
    }
    m_in_fight = false;
}
void sc_arena_t::on_login()
{
    if (date_helper.offday(db.stamp) >= 1)
    {
        db.fight_count = MAX_FIGHT_COUNT;
        db.n_buy = 0;
    }
    if (date_helper.offday(db.in_stamp) >= 1)
    {
        db.in_fight_count = MAX_FIGHT_COUNT;
        db.in_buy = 0;
    }
    if (!is_last_fight_end())
    {
        sc_msg_def::req_end_arena_fight_t jpk_;
        sc_msg_def::ret_end_arena_fight_t ret;
        jpk_.is_win = false;
        jpk_.salt = "";
        m_target_uid = db.target_id;
        fight_end(jpk_,ret);
    }
}
/*
 * @comment fanbin
 * @function 
 *   判断自己是否在某排名范围内
 * @params
 *   b_: 起始排名
 *   e_: 终止排名, b_ < e_
 * @return
 *   bool
 */
inline bool sc_arena_t::is_in_rank(int b_, int e_) 
{
    if(m_flag == 0)
        return b_ <= m_user.db.rank && m_user.db.rank <= e_; 
    else if (m_flag == 1)
        return b_ <= m_user.db.m_rank && m_user.db.m_rank <= e_; 
}

void sc_arena_t::get_cool_down(sc_msg_def::ret_arena_cool_down_t &ret_)
{
    if (date_helper.offday(db.stamp) >= 1 && date_helper.offday(db.in_stamp) >= 1)
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
            db_.update();
        }, db);
    }
    
    if(m_flag == 0){
        ret_.fight_count = db.fight_count;
        uint32_t intval = date_helper.cur_sec() - db.stamp;
        if (intval >= MAX_FIGHT_TIME_INTVAL) {
            ret_.time = 0;
            m_in_fight = false;
        } else {
            ret_.time = MAX_FIGHT_TIME_INTVAL - intval;
        }
    }else if(m_flag == 1){
        ret_.fight_count = db.in_fight_count;
        uint32_t intval = date_helper.cur_sec() - db.in_stamp;
        if (intval >= MAX_FIGHT_TIME_INTVAL) {
            ret_.time = 0;
            m_in_fight = false;
        } else {
            ret_.time = MAX_FIGHT_TIME_INTVAL - intval;
        }
    }

}

int sc_arena_t::unicast_arena_info(int32_t flag)
{
    arena_cache.update();
    if (m_user.db.rank == MAX_RANK)
    {
        int32_t res = arena_rank.add_user(m_user.db.uid, 0);
        if (res != MAX_RANK)
        {
            m_user.db.set_rank(res);
            m_user.save_db();
        }
    }
    
    sc_msg_def::ret_arena_info_t ret;
    ret.flag = flag;
    m_flag = flag;

    if (date_helper.offday(db.stamp) >= 1 && date_helper.offday(db.in_stamp) >= 1)
    {
        //db.fight_count = MAX_FIGHT_COUNT;
        //db.n_buy = 0;
        //db.stamp = date_helper.cur_sec();
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
            db_.update();
        }, db);
    }

    if(m_flag == 0){
        ret.rank = m_user.db.rank;
        ret.fight_count = db.fight_count;
    }else if(m_flag == 1){
        ret.fight_count = db.in_fight_count;
        if(m_user.db.m_rank ==0){
            string str_hosts;
            char tmp_sql[512];
            sql_result_t tmp_res;
            sprintf(tmp_sql, "SELECT hostnum FROM ArenaHostGroup WHERE arena_group = (SELECT arena_group FROM ArenaHostGroup WHERE hostnum = %d)",m_user.db.hostnum);
            db_service.sync_select(tmp_sql,tmp_res);
            size_t tmp_num = tmp_res.affect_row_num();
            if (tmp_num == 0)
                str_hosts.append(std::to_string(m_user.db.hostnum)+",");
            else
                for(size_t i = 0; i < tmp_num; i ++)
                {   
                    if (tmp_res.get_row_at(i) == NULL)
                    {   
                        logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                        break;
                    }   

                    sql_result_row_t& row_t = *tmp_res.get_row_at(i);
                    int tmp_host = (int)std::atoi(row_t[0].c_str());
                    str_hosts.append(std::to_string(tmp_host)+",");
                }
            str_hosts = str_hosts.substr(0, str_hosts.length()-1);
            char rank_sql[512];
            sql_result_t rank_res;
            sprintf(rank_sql, "SELECT max(m_rank+1) FROM UserInfo WHERE hostnum in (%s)", str_hosts.c_str());
            db_service.sync_select(rank_sql,rank_res);
            sql_result_row_t& row_ = *rank_res.get_row_at(0);
            int max_rank = (int)std::atoi(row_[0].c_str());
            logerror((LOG, "max_rank:%d", max_rank));
            m_user.db.set_m_rank(max_rank);
            m_user.save_db();
            ret.rank = m_user.db.m_rank;
        }else{
            ret.rank = db_get_rank(m_user.db.uid);
        }
    }
    ret.reward_btp_cd = arena_rank.get_reward_btp_cd();
    ret.meritorious = m_user.db.meritorious;
    uint32_t intval = 0;
    if(m_flag == 0)
        intval = date_helper.cur_sec() - db.stamp;
    else if(m_flag == 1)
        intval = date_helper.cur_sec() - db.in_stamp;
    if (intval >= MAX_FIGHT_TIME_INTVAL) {
        ret.time = 0;
    } else {
        ret.time = MAX_FIGHT_TIME_INTVAL - intval;
    }

    int n = find_rank_targets();
    if (n <= 0) {
        return ERROR_SC_EXCEPTION;
    }

    ret.targets.resize(n);
    for(int i=0; i<n; i++)
    {
        if (false == get_jpk_arena_target(m_targets[i], m_ranks[i], ret.targets[i]))
        {
            logerror((LOG, "get_jpk_arena_target failed!, uid:%d, i:%d", m_targets[i], i));
        }
    }
    
    sp_arena_record_t sp_record;
    if(m_flag == 0){
    if (arena_cache.get_record(m_user.db.uid, sp_record, m_flag))
    {
        ret.records.resize(sp_record->records.size());
        int i=0;
        for(sp_jpk_arena_record_t sp_jpk:sp_record->records)
        {
            (sp_jpk)->during = date_helper.cur_sec() - (sp_jpk)->time;
            ret.records[i++] = (*sp_jpk);
        }
    }
    }else if(m_flag == 1){
        char sql[512];
        sql_result_t res;
        sprintf(sql, "SELECT caster_uid, caster_name, caster_fp, target_uid, target_name, target_fp, is_win, caster_rank, target_rank, time FROM ArenaRecord WHERE (caster_uid = %d or target_uid = %d) and time > %d order by time desc limit 10",m_user.db.uid,m_user.db.uid,date_helper.cur_sec()- 86400);
        db_service.sync_select(sql,res);
        size_t tmp_num = res.affect_row_num();
        if (tmp_num != 0){
            ret.records.resize(tmp_num);
            for(size_t i = 0; i < tmp_num; i ++)
            {   
                if (res.get_row_at(i) == NULL)
                {   
                    logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                    break;
                }   

                sql_result_row_t& row_t = *res.get_row_at(i);
                sp_jpk_arena_record_t sp_jpk(new sc_msg_def::jpk_arena_record_t);
                sp_jpk->caster_uid = (int)std::atoi(row_t[0].c_str());
                sp_jpk->caster_name = (string)row_t[1];
                sp_jpk->caster_fp = (int)std::atoi(row_t[2].c_str());
                sp_jpk->target_uid = (int)std::atoi(row_t[3].c_str());
                sp_jpk->target_name = (string)row_t[4];
                sp_jpk->target_fp = (int)std::atoi(row_t[5].c_str());
                sp_jpk->is_win = (int)std::atoi(row_t[6].c_str());
                sp_jpk->cast_rank = (int)std::atoi(row_t[7].c_str());
                sp_jpk->target_rank = (int)std::atoi(row_t[8].c_str());
                sp_jpk->time = (int)std::atoi(row_t[9].c_str());
                sp_jpk->during = date_helper.cur_sec()-(int)std::atoi(row_t[9].c_str());
                ret.records[i] = (*sp_jpk);
            }
        }
    }
    logic.unicast(m_user.db.uid, ret);

    return SUCCESS;
}

/*
 * @comment fanbin
 * @function 
 *   填充m_targets and m_ranks(m_targets:目标uid, m_ranks:目标排名)
 * @params
 *   off_: 从[1, off_]范围内随机出5个排行榜上人物
 * @return
 *   int: 该范围内获取的排行榜人数 <=5人
 */
int sc_arena_t::get_targets(int off_)
{
    memset(m_targets, 0, sizeof(m_targets));
    memset(m_ranks, 0, sizeof(m_ranks));

    sql_result_t res;
    char sql[512];
    int rank = m_user.db.rank;
    if(rank > MAX_RANK) rank = MAX_RANK;
    
    string str_hosts;
    string rank_name;
    if(m_flag == 0 ){
        for (int32_t host : arena_cache.m_hosts)
        {
            str_hosts.append(std::to_string(host)+",");
        }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);
        rank_name = "rank";
    }else if(m_flag == 1){
        rank = db_get_rank(m_user.db.uid);
        rank_name = "m_rank";
        char tmp_sql[512];
        sql_result_t tmp_res;
        sprintf(tmp_sql, "SELECT hostnum FROM ArenaHostGroup WHERE arena_group = (SELECT arena_group FROM ArenaHostGroup WHERE hostnum = %d)",m_user.db.hostnum);
        db_service.sync_select(tmp_sql,tmp_res);
        size_t tmp_num = tmp_res.affect_row_num();
        if (tmp_num == 0)
            str_hosts.append(std::to_string(m_user.db.hostnum)+",");
        else
            for(size_t i = 0; i < tmp_num; i ++)
            {   
                if (tmp_res.get_row_at(i) == NULL)
                {   
                    logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                    break;
                }   

                sql_result_row_t& row_t = *tmp_res.get_row_at(i);
                int tmp_host = (int)std::atoi(row_t[0].c_str());
                str_hosts.append(std::to_string(tmp_host)+",");
            }
        str_hosts = str_hosts.substr(0, str_hosts.length()-1);
    }

    if(rank <= 5) 
        sprintf(sql, "SELECT uid, %s FROM UserInfo where %s <= 5 and %s >0 and hostnum in (%s) order by %s asc LIMIT 5; ", rank_name.c_str(), rank_name.c_str(), rank_name.c_str(), str_hosts.c_str(), rank_name.c_str() );
    else
    {
        //更改匹配区间
        if(rank > 800)
            off_ = rank/5;


        off_ = rank - off_;
        if (off_ < 0) off_ = 0;
        sprintf(sql, "(SELECT uid, %s FROM UserInfo WHERE hostnum in (%s) and %s != 0 and %s >= %d and %s < %d order by rand() LIMIT 5) order by %s asc; ", rank_name.c_str(), str_hosts.c_str(), rank_name.c_str(), rank_name.c_str(), off_, rank_name.c_str(), rank, rank_name.c_str() );
    }
    db_service.sync_select(sql, res);
    size_t res_num = res.affect_row_num();
    for(size_t i = 0; i < res_num; i ++)
    {   
        if (res.get_row_at(i) == NULL)
        {   
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }   

        sql_result_row_t& row_ = *res.get_row_at(i);
        m_targets[i] = (int)std::atoi(row_[0].c_str());
        if (m_targets[i] == 0)
            break;
        m_ranks[i] = (int)std::atoi(row_[1].c_str());
    }
    return res_num; 
}

/*
 * @comment fanbin
 * @function 
 *   根据自己所在排行榜的位置，从不同范围内选取5人作为当前排行榜可攻击目标
 * @params
 *
 * @return
 *   int: 该范围内获取的排行榜人数 <=5人
 */
int sc_arena_t::find_rank_targets()
{
    if (is_in_rank(1, 20))
        return get_targets(10);
    else if (is_in_rank(21, 80))
        return get_targets(30);
    else if (is_in_rank(81, 200))
        return get_targets(50);
    else if (is_in_rank(201, 800))
        return get_targets(200);
    else if (is_in_rank(801, 9999999))
        return get_targets(400);
    return 0;
}

/*
 * @comment fanbin
 * @function 
 *   根据提供uid rank 将该对象的竞技场基本数据填充至jpk_
 * @params
 *   uid_: 目标uid
 *   rank_: 目标rank
 *   jpk_: 填充对象
 * @return
 *   bool: 填充成功与否
 */
bool sc_arena_t::get_jpk_arena_target(uint32_t uid_, int rank_, sc_msg_def::jpk_arena_target_t& jpk_)
{
    jpk_.uid = uid_;
    jpk_.rank = rank_;
    sp_view_user_t sp_view;
    if(m_flag ==0)
    sp_view = view_cache.get_other_view(uid_);
    else if(m_flag ==1)
    sp_view = view_cache.get_other_view(uid_);
    if (sp_view != NULL)
    {
        int total_fp = 0;
        jpk_.name = sp_view->name;
        jpk_.model = sp_view->model;
        jpk_.combo_pro.combo_d_down = sp_view->combo_pro.combo_d_down;
        jpk_.combo_pro.combo_r_down = sp_view->combo_pro.combo_r_down;
        jpk_.combo_pro.combo_d_up =  sp_view->combo_pro.combo_d_up;
        jpk_.combo_pro.combo_r_up =  sp_view->combo_pro.combo_r_up;
        for (auto it = sp_view->combo_pro.combo_anger.begin();it != sp_view->combo_pro.combo_anger.end();++it){
            jpk_.combo_pro.combo_anger.insert(make_pair(it->first,it->second)); 
        }
        int size = sp_view->roles.size();
        jpk_.team_info.resize(size);
        int index = 0;
        for(auto it=sp_view->roles.begin(); it!=sp_view->roles.end(); it++)
        {
            jpk_.team_info[index].pid = it->second.pid;
            jpk_.team_info[index].equiplv = sc_user_t::get_equip_level(uid_, it->second.pid);
            if (it->second.pid == 0)
            {
                jpk_.team_info[index].resid = it->second.resid;
                jpk_.team_info[index].level = it->second.lvl.level;
                jpk_.team_info[index].lovelevel = it->second.lvl.lovelevel;
                sql_result_t res;
                char sql[256];
                sprintf(sql, "select quality, hostnum from UserInfo where uid=%d;", uid_);
                db_service.sync_select(sql, res);
                if (0 == res.affect_row_num())    //没有找到
                {    
                    jpk_.team_info[index].starnum = 1;
                }else{
                    sql_result_row_t& row = *res.get_row_at(0);
                    jpk_.team_info[index].starnum = (int)std::atoi(row[0].c_str());
                    jpk_.hostnum = (int)std::atoi(row[1].c_str());
                }
            }else {
                get_level_info(uid_, it->second.pid, jpk_.team_info[index].level, jpk_.team_info[index].lovelevel, jpk_.team_info[index].starnum, jpk_.team_info[index].resid);
            }
            if (it->second.pid == 0)
            {
                jpk_.resid = it->second.resid;
                jpk_.level = it->second.lvl.level;
                jpk_.lovelevel = it->second.lvl.lovelevel;
                if (!it->second.wings.empty())
                    jpk_.wingid = it->second.wings[0].resid;
                else
                    jpk_.wingid = -1;
                jpk_.have_pet = false;
                jpk_.petid = 0;
            }
            total_fp += it->second.pro.fp;
            logerror((LOG, "uid:%d,total_fp:%d", uid_, total_fp));
            ++index;
        }
        jpk_.fp = total_fp;
        return true;
    }
    return false;
}

/*void sc_arena_t::get_equip_level(int32_t uid,int32_t pid, int32_t &equiplv)
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

void sc_arena_t::get_level_info(int32_t uid, int32_t pid, int32_t &level, int32_t &lovelevel, int32_t &starnum, int32_t &resid)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select grade,lovelevel,quality,resid  from Partner where uid=%d and pid=%d;", uid, pid);  //Partner表不包含主角本身
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())    //没有找到
    {    
        level = 0;
        lovelevel = 0;
        starnum = 1;
        resid = 0;
        return;
    }

    sql_result_row_t& row = *res.get_row_at(0);
    level = (int)std::atoi(row[0].c_str());
    lovelevel = (int)std::atoi(row[1].c_str());
    starnum = (int)std::atoi(row[2].c_str());
    resid = (int)std::atoi(row[3].c_str());
}

void sc_arena_t::buy_fight_count()
{
    sc_msg_def::ret_buy_fight_count_t ret;

    int code = m_user.vip.buy_vip(vop_buy_fight_count);
    if (code == SUCCESS)
    {
        //修改cache数据
        if(m_flag ==0){
            db.n_buy += 1;
            db.fight_count += 1;
        }else if(m_flag == 1){
            db.in_buy += 1;
            db.in_fight_count += 1;
        }

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
            db_.update();
        }, db);

        ret.fight_count = 1;
    }

    ret.code = code;
    logic.unicast(m_user.db.uid, ret);
}

int sc_arena_t::need_yb()
{
    return CLEAR_COOLING_TIME_CONSUME_YB;
}

void sc_arena_t::clear_time()
{
    /* 不花钻石 */
    if(m_flag == 0){
        if (date_helper.cur_sec() - db.stamp >= MAX_FIGHT_TIME_INTVAL) {
            return;
        }
        db.stamp = db.stamp - MAX_FIGHT_TIME_INTVAL;
    }else if(m_flag == 1){
        if (date_helper.cur_sec() - db.in_stamp >= MAX_FIGHT_TIME_INTVAL) {
            return;
        }
        db.in_stamp = db.in_stamp - MAX_FIGHT_TIME_INTVAL;
    }

    /* 花钻石 */
    m_user.consume_yb(CLEAR_COOLING_TIME_CONSUME_YB);
    m_user.save_db();

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
        db_.update();
    }, db);

    sc_msg_def::ret_arena_clear_time_t ret;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}

/*
 * @comment fanbin
 * @function 
     战斗胜利
 * @params
 *   lrank_: 攻击方战斗前排名
 *   ruid_ : 受击方uid
 *   rrank_: 受击方战斗前排名
 *   ret: 请求返回的数据引用
 * @return
 *   void
 */
void sc_arena_t::win(int lrank_, int32_t ruid_, int rrank_, sc_msg_def::ret_end_arena_fight_t &ret)
{
    logwarn((LOG, "BEFORE SWAP %d, %d, %d, %d", m_user.db.uid, lrank_, ruid_, rrank_));
    if (lrank_ > rrank_)
    {
        if(m_flag == 0)
            m_user.db.rank = rrank_;
        else if(m_flag == 1)
            m_user.db.set_m_rank(rrank_);
        sp_user_t sp_target_user;
        bool incacheOronline = logic.usermgr().get(ruid_, sp_target_user) || cache.get(ruid_, sp_target_user);
        if (!incacheOronline) {
            sp_target_user.reset(new sc_user_t);
            if (sp_target_user->load_db(ruid_)){
                if(m_flag ==0)
                    logic.usermgr().insert(sp_target_user->db.uid, sp_target_user);
            }
        }
        //发公告 
        sp_user_t user;
        /*
        if (m_flag == 0 && logic.usermgr().get(ruid_, user))
        {
            if (1 == rrank_)
            {
                string msg = pushinfo.get_push(push_arena_rank_1, m_user.db.nickname(), m_user.db.grade, m_user.db.uid, m_user.db.viplevel,user->db.nickname(), user->db.grade, user->db.uid, user->db.viplevel, rrank_);
                pushinfo.push(msg);
            }
            if (2 == rrank_)
            {
                string msg = pushinfo.get_push(push_arena_rank_2, m_user.db.nickname(), m_user.db.grade, m_user.db.uid, m_user.db.viplevel,user->db.nickname(), user->db.grade, user->db.uid, user->db.viplevel, rrank_);
                pushinfo.push(msg);
            }
            if (3 == rrank_)
            {
                string msg = pushinfo.get_push(push_arena_rank_3, m_user.db.nickname(), m_user.db.grade, m_user.db.uid, m_user.db.viplevel,user->db.nickname(), user->db.grade, user->db.uid, user->db.viplevel, rrank_);
                pushinfo.push(msg);
            }
        }
        */

        if (sp_target_user != NULL) {
            if(m_flag ==0)
                sp_target_user->db.rank = lrank_;
        }
        if(m_flag == 1){
            char set_sql[512];
            sprintf(set_sql,"UPDATE UserInfo SET m_rank = %d where uid = %d", lrank_, ruid_);
            db_service.sync_execute(set_sql);
        }

        // lrank_, rrank_ 引用传递
        if(m_flag ==0){
            arena_rank.swap_user(m_user.db.uid, lrank_, ruid_, rrank_);
            logwarn((LOG, "PAGE_UPDATE_RANK %d, %d, %d, %d", m_user.db.uid, lrank_, ruid_, rrank_));
            arena_page_cache.update_rank(m_user.db.uid, lrank_, rrank_);
        }
        //if (1 == rrank_)
          //  pushinfo.new_push(push_arena_fight, m_user.db.nickname(), m_user.db.grade, m_user.db.uid, m_user.db.viplevel);
    }
    
    ++db.win_count;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
        db_.update();
    }, db);
    int32_t extra_ho_ = db.win_count >= 50 ? 3 : db.win_count >= 10 ? 2 : db.win_count >= 3 ? 1 : 0;
    ret.honor = extra_ho_;
    int32_t span = rrank_ - lrank_;
    int32_t span_win = span >= 70 ? 5 : span >= 50 ? 4 : span >= 10 ? 2 : span >= 5 ? 1 : 0;
    int32_t extra_me_ = random_t::rand_integer(1, 3) + extra_ho_ + span_win;
    ret.meritorious = extra_me_;
    if(m_flag == 0){
        for (auto it = repo_mgr.salary.begin(); it != repo_mgr.salary.end(); ++it)
        {
            if (m_user.db.rank >= it->second.rank[1] && m_user.db.rank <= it->second.rank[2])
            {
                ret.money = 0;
                ret.meritorious = it->second.meritorious + extra_me_;
                ret.honor = it->second.honor_win + extra_ho_;
                break;
            }
        }
    }else if(m_flag == 1){
        for (auto it = repo_mgr.insalary.begin(); it != repo_mgr.insalary.end(); ++it)
        {
            if (m_user.db.m_rank >= it->second.rank[1] && m_user.db.m_rank <= it->second.rank[2])
            {
                ret.money = 0;
                ret.meritorious = it->second.meritorious + extra_me_;
                ret.honor = it->second.honor_win + extra_ho_;
                break;
            }
        }
    }

   logwarn((LOG,"arena win, ret.meritorious:%d", ret.meritorious)); 
    int index = 0;
    if (ret.meritorious > 0)
        index = m_user.on_meritorious_change(ret.meritorious);
    if (ret.honor > 0){ 
        if( m_flag == 0)
            m_user.on_honor_change(ret.honor);
        else if (m_flag == 1)
            m_user.on_unhonor_change(ret.honor);//todo
    }
    if (m_user.db.rank >= 50)
    {
        card_event_s.unlock_new_host();
    }
    m_user.save_db();
}

/*
 * @comment ssx
 * @function 
 *   战斗作弊
 * @params
 *   ret: 请求返回的数据引用
 * @return
 *   void
 */
void sc_arena_t::clear(sc_msg_def::ret_end_arena_fight_t &ret)
{
    ret.money = 0;
    ret.meritorious = 0;
    ret.honor = 0;
}

/*
 * @comment fanbin
 * @function 
 *   战斗失败
 * @params
 *   ret: 请求返回的数据引用
 * @return
 *   void
 */
void sc_arena_t::lose(sc_msg_def::ret_end_arena_fight_t &ret)
{
    ret.meritorious = 0;
    ret.honor = 0;
    if (m_flag == 0){
        for (auto it = repo_mgr.salary.begin(); it != repo_mgr.salary.end(); ++it)
        {
            if (m_user.db.rank >= it->second.rank[1] && m_user.db.rank <= it->second.rank[2])
            {
                ret.money = 0;
                ret.meritorious = floor(it->second.meritorious/2);
                ret.honor = floor(it->second.honor_win/2);
                break;
            }
        }
    }else if (m_flag == 1){
    for (auto it = repo_mgr.insalary.begin(); it != repo_mgr.insalary.end(); ++it)
    {
        if (m_user.db.m_rank >= it->second.rank[1] && m_user.db.m_rank <= it->second.rank[2])
        {
            ret.money = 0;
            ret.meritorious = floor(it->second.meritorious/2);
            ret.honor = floor(it->second.honor_win/2);
            break;
        }
    }
    }
    logwarn((LOG, "arena lose, meritorious:%d", ret.meritorious));
    if (ret.meritorious > 0)
        m_user.on_meritorious_change(ret.meritorious);
    if (ret.honor > 0){
        if(m_flag == 0)
            m_user.on_honor_change(ret.honor);
        else if (m_flag == 1)
            m_user.on_unhonor_change(ret.honor);//todo
    }
    db.win_count = 0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
        db_.update();
    }, db);
    m_user.save_db();
}

/*
 * @comment fanbin
 * @function 
 *   记录战报  
 * @params
 *   win_: 胜利结果
 *   lfp_: 左侧（攻击方）战斗力
 *   rfp_: 右侧（防守方）战斗力
 *   ruid_: 右侧（防守方）uid
 *   rname_: 右侧（防守方）姓名
 *   rrank_: 右侧（防守方）排行榜名次
 * @return
 *   void
 */
void sc_arena_t::record(bool win_, int32_t lfp_, int32_t rfp_, int32_t ruid_, string rname_, int rlv_, int rrank_)
{
    sp_jpk_arena_record_t sp_record(new sc_msg_def::jpk_arena_record_t);
    sp_record->time = date_helper.cur_sec();
    sp_record->during = 0;
    sp_record->is_win = win_;
    sp_record->caster_uid = m_user.db.uid;
    sp_record->caster_name = m_user.db.nickname();
    sp_record->caster_fp = lfp_;
    if(m_flag == 0)
        sp_record->cast_rank = m_user.db.rank;
    else if(m_flag == 1)
        sp_record->cast_rank = m_user.db.m_rank;
    sp_record->target_uid = ruid_;
    sp_record->target_name = rname_;
    sp_record->target_fp = rfp_;
    sp_record->target_rank = rrank_;
    arena_cache.add_record(sp_record->caster_uid, sp_record, m_flag);
    arena_cache.add_record(sp_record->target_uid, sp_record, m_flag);
}

void sc_arena_t::record_a(bool win_, int32_t lfp_, int32_t rfp_, sp_view_user_t sp_target_data, int lrank_, int rrank_, int hostnum)
{
    int time = date_helper.cur_sec();
    int is_win = win_?1:0;
    int caster_uid = m_user.db.uid;
    int caster_hostnum = m_user.db.hostnum;
    if(caster_hostnum > 100)
        caster_hostnum = (caster_hostnum / 10) * 5 + (caster_hostnum % 10);
    string caster_name = std::to_string(caster_hostnum).append("-").append(m_user.db.nickname());
    int caster_fp = lfp_;
    int cast_rank = lrank_;
    int target_uid = sp_target_data->uid;
    if(hostnum > 100)
        hostnum = (hostnum / 10) * 5 + (hostnum % 10);
    string target_name = std::to_string(hostnum).append("-").append(sp_target_data->name);
    int target_fp = rfp_;
    int target_rank = rrank_;
    char sql[512];
    sprintf(sql,"INSERT INTO ArenaRecord (caster_uid, caster_name, caster_fp, target_uid, target_name, target_fp, is_win, caster_rank, target_rank, time) VALUES (%d, '%s', %d, %d, '%s', %d, %d, %d, %d, %d);", caster_uid, caster_name.c_str(), caster_fp, target_uid, target_name.c_str(), target_fp, is_win, cast_rank, target_rank,date_helper.cur_sec());
    db_service.sync_execute(sql);
}

int sc_arena_t::fight(sc_msg_def::ret_begin_arena_fight_t &ret_, int pos_)
{
    /* 异常判断时不应该有逻辑处理 */
    if (pos_ > 5 || m_targets[pos_-1] == 0) {
        return ERROR_SC_EXCEPTION;
    }
    if (m_flag == 0 && db.fight_count <= 0) {
        return ERROR_ARENA_NO_FIGHT_COUNT;
    }
    if (m_flag == 1 && db.in_fight_count <= 0) {
        return ERROR_ARENA_NO_FIGHT_COUNT;
    }
    int32_t target_uid = m_targets[pos_-1];
    if (target_uid == m_user.db.uid) {
        return ERROR_ARENA_ILLEGLE_TARGET;
    }
    //如果对面正在战斗 且为真人 则该玩家返回正在战斗
    if(m_flag == 0){
        sp_user_t target_user;
        if (logic.usermgr().get(target_uid, target_user))
        {
            if (target_user->arena.is_in_fight())
            {
                return ERROR_ARENA_IN_FIGHTING;
            }
        }
    //判断rank等级 如果对方rank比自己低，则不加锁
        sql_result_t res;
        char sql[256];
        sprintf(sql, "select rank, uid from UserInfo where uid = %d ;", m_user.db.uid);
        db_service.sync_select(sql, res);
        sql_result_row_t& row_ = *res.get_row_at(0);
        int rank_self = (int)std::atoi(row_[0].c_str());
        sprintf(sql, "select rank, uid from UserInfo where uid = %d ;", target_uid);
        db_service.sync_select(sql, res);
        row_ = *res.get_row_at(0);
        int rank_target = (int)std::atoi(row_[0].c_str());
        if(rank_self > rank_target)
            m_in_fight = true;
    }else if(m_flag == 1){
        char sql[512];
        sql_result_t res;
        sprintf(sql, "select stamp from Arena where target_id = %d", target_uid);
        db_service.sync_select(sql, res);
        size_t num = res.affect_row_num();
        if (num != 0){
            sql_result_row_t& row_ = *res.get_row_at(0);
            int timestamp = (int32_t)std::atoi(row_[0].c_str());
            if(timestamp + 10 * 60 > date_helper.cur_sec() && timestamp < date_helper.cur_sec())
                return ERROR_ARENA_IN_FIGHTING;
        }
    }

    //pvp
    sp_view_user_t sp_cast_data = view_cache.get_view(m_user.db.uid);
    if (sp_cast_data == NULL) {
        return ERROR_SC_EXCEPTION;
    }
    sp_view_user_t sp_target_data = view_cache.get_other_view(target_uid);
    if (sp_target_data == NULL) {
        return ERROR_SC_EXCEPTION;
    }
    //time
    if (m_flag == 0 && date_helper.cur_sec() - db.stamp <= MAX_FIGHT_TIME_INTVAL) {
        return ERROR_ARENA_IN_COOLING; // 时间的xxx
    }
    if (m_flag == 1 && date_helper.cur_sec() - db.in_stamp <= MAX_FIGHT_TIME_INTVAL) {
        return ERROR_ARENA_IN_COOLING; // 时间的xxx
    }

    /* 逻辑处理 */
    if(m_flag == 0){
        db.stamp = date_helper.cur_sec();
        db.fight_count--;
    }else if(m_flag == 1){
        db.in_stamp = date_helper.cur_sec();
        db.in_fight_count--;
    }

    db.target_id = target_uid;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
        db_.update();
    }, db);
    ret_.time = MAX_FIGHT_TIME_INTVAL;

    (*sp_target_data) >> ret_.target_data;

    uint32_t rseed = random_t::rand_integer(0, 100000);
    random_t::rand_str(ret_.salt, 16);
    m_fight_time = date_helper.cur_sec() % 3600;

    m_salt = ret_.salt;
    m_target_uid = target_uid;

    /* 这个玩意儿是没用的 */
    ret_.is_win = true;
    return SUCCESS;
}

int sc_arena_t::db_get_rank(uint32_t uid_)
{
    sql_result_t res;
    char sql[512];
    int rank = 1;
    if(m_flag ==0)
        sprintf(sql, "select rank from UserInfo where uid = %d", uid_);
    else if (m_flag == 1)
        sprintf(sql, "select m_rank from UserInfo where uid = %d", uid_);
    db_service.sync_select(sql, res);
    for(size_t i=0; i<res.affect_row_num(); i++)
    {   
        if (res.get_row_at(i) == NULL)
        {   
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }   

        sql_result_row_t& row_ = *res.get_row_at(i);
        rank=(int)std::atoi(row_[0].c_str());
    }

    return rank;
}
int sc_arena_t::db_get_host_rank(int& hostnum, uint32_t uid_)
{
    sql_result_t res;
    char sql[512];
    int rank = 1;
    sprintf(sql, "select m_rank, hostnum from UserInfo where uid = %d", uid_);
    db_service.sync_select(sql, res);
    for(size_t i=0; i<res.affect_row_num(); i++)
    {   
        if (res.get_row_at(i) == NULL)
        {   
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }   

        sql_result_row_t& row_ = *res.get_row_at(i);
        rank=(int)std::atoi(row_[0].c_str());
        hostnum=(int)std::atoi(row_[1].c_str());
    }

    return rank;
}
int sc_arena_t::fight_end(sc_msg_def::req_end_arena_fight_t &jpk_, sc_msg_def::ret_end_arena_fight_t &ret)
{
    m_in_fight = false;
    sp_view_user_t sp_target_data;
    int lrank_;
    int rrank_;
    int hostnum = 0;
    if(m_flag ==0){
        lrank_ = m_user.db.rank;
        sp_target_data = view_cache.get_other_view(m_target_uid);
        rrank_ = db_get_rank(m_target_uid);
    }else if(m_flag ==1){
        lrank_ = db_get_rank(m_user.db.uid);
        sp_target_data = view_cache.get_other_view(m_target_uid);
        rrank_ = db_get_host_rank(hostnum, m_target_uid);
    }

    if (jpk_.is_win) {
        win(lrank_, m_target_uid, rrank_, ret);
    }
    else  lose(ret);

    //判断是否作弊
    if (m_salt != jpk_.salt)
    {
        // 校验salt失败
        this->clear(ret);
    }
    m_salt = "randomstring";

    //时间校验
    int cur_time = date_helper.cur_sec();
    if( cur_time < m_fight_time )
        cur_time += 3600;
    if( cur_time - m_fight_time <= 2 )
    {
        this->clear(ret);
    }

    sp_view_user_t sp_cast_data = view_cache.get_view(m_user.db.uid);

    {
        //fp
        int32_t fp1 = 0, fp2 = 0;
        int32_t pid1[5] = {-1, -1, -1, -1, -1}, pid2[5] = {-1, -1, -1, -1, -1};
        auto total_fp = [&](int32_t& total_fp, int32_t* pid_, sp_view_user_t& sp_view_) {
            total_fp = 0;
            if (sp_view_ == NULL)
                return false;
            int i = 0;
            for (auto it = sp_view_->roles.begin(); it != sp_view_->roles.end(); ++it)
            {
                pid_[i++] = it->second.pid;
                total_fp += it->second.pro.fp;
            }
            return true;
        };

        total_fp(fp1, pid1, sp_cast_data);
        total_fp(fp2, pid2, sp_target_data);

        int rlv = 0;
        for(auto it=sp_target_data->roles.begin(); it!=sp_target_data->roles.end(); it++)
        {
            if (it->second.pid == 0)
            {
                rlv = it->second.lvl.level;
                break;
            }
        }
        if(m_flag ==0)
            record(jpk_.is_win, fp1, fp2, sp_target_data->uid, sp_target_data->name, rlv, rrank_);
        else if(m_flag == 1)
            record_a(jpk_.is_win, fp1, fp2, sp_target_data, lrank_, rrank_, hostnum);

        string vd; (*sp_cast_data) >> vd;
        arena_info_cache.update(m_user.db.hostnum, m_user.db.uid, fp1, m_user.db.grade, pid1);
    }
    if (jpk_.is_win && m_flag == 0)
    {
        //推送信封
        if (rrank_ < lrank_) 
        {
            string mail = mailinfo.new_mail(mail_arena_failed, date_helper.str_date(), m_user.db.nickname(), lrank_); 
            if (!mail.empty())
                notify_ctl.push_mail(sp_target_data->uid, mail);
        }
    }
    if (m_user.db.grade >= DAILY_TASK_BEGIN_LEVEL)
        m_user.daily_task.on_event(evt_arena_fight_win);
    m_user.reward.update_opentask(open_task_arena_num);
    db.target_id = 0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Arena_t& db_){
        db_.update();
    }, db);
    return SUCCESS;
}
bool sc_arena_t::is_in_fight()
{
    return m_in_fight;
}
bool sc_arena_t::is_last_fight_end()
{
    return (db.target_id == 0);
}

//==========================================================
sc_arena_cache_t::sc_arena_cache_t():m_flush_time(0)
{
    m_reward_time = date_helper.cur_local_sec()%(24*3600);
    if (m_reward_time > 21*3600)
    {
        m_reward_time = 24*3600 - m_reward_time + 21*3600;
    }
    else
    {
        m_reward_time = 21*3600 - m_reward_time;
    }
}

void sc_arena_cache_t::update()
{
    if (m_flush_time == 0)
    {
        m_flush_time = date_helper.cur_sec();
        return;
    }

    if (date_helper.offday(m_flush_time) >= 3)
    {
        m_record_hm.clear();
        m_record_g_hm.clear();
        m_flush_time = date_helper.cur_sec();
    }
}
/*
 * @comment fanbin
 * @function 
 *   记录战报至cache，用于玩家观看战报使用
 * @params
 *   uid_: 填充战报的玩家uid
 *   record_: 实际战报内容
 * @return
 *   void
 */
void sc_arena_cache_t::add_record(int32_t uid_, sp_jpk_arena_record_t record_, int32_t m_flag)
{
    sp_arena_record_t sp_record;
    if(m_flag == 0){
        auto it = m_record_hm.find(uid_);
        if (it == m_record_hm.end())
        {
            sp_arena_record_t sp_record(new sc_arena_record_t());
            it = m_record_hm.insert(make_pair(uid_, sp_record)).first;
        }
        sp_record = it->second;
    }else if(m_flag == 1){
        auto it = m_record_g_hm.find(uid_);
        if (it == m_record_g_hm.end())
        {
            sp_arena_record_t sp_record(new sc_arena_record_t());
            it = m_record_g_hm.insert(make_pair(uid_, sp_record)).first;
        }
        sp_record = it->second;
    }
    if (sp_record->record_time == 0)
    {
        sp_record->record_time = date_helper.cur_sec();
    }
    else if (date_helper.offday(sp_record->record_time) >= 3)
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
/*
 * @comment fanbin
 * @function 
 *   根据玩家uid获取战报信息，并填充至sp_record_
 * @params
 *   uid_: 请求获取战报的玩家uid
 *   sp_record_: 待填充的对象
 * @return
 *   bool: 填充结果，true有战报数据，false无战报数据
 */
bool sc_arena_cache_t::get_record(int32_t uid_, sp_arena_record_t& sp_record_, int32_t m_flag)
{
    if(m_flag == 0){
        auto it = m_record_hm.find(uid_);
        if (it != m_record_hm.end())
        {
            sp_record_ = it->second; 
            return true;
        }
    }else if(m_flag == 1){
        auto it = m_record_g_hm.find(uid_);
        if (it != m_record_g_hm.end())
        {
            sp_record_ = it->second; 
            return true;
        }
    }

    return false;
}
uint32_t sc_arena_cache_t::reward_countdown()
{
    return m_reward_time;
}
//更新奖励时间
void sc_arena_cache_t::update_reward_time(int sec_)
{
    m_reward_time -= sec_;

    //printf("%d\n", m_reward_time);
    if (m_reward_time <= 0)
    {
        m_reward_time = 24*3600;
        server.db.set_result_rank_stamp(date_helper.cur_sec());
        server.save_db();
        arena_rank.save_reward_rank();
    }

    arena_rank.update_reward(sec_);
}

sc_arena_info_cache_t::sc_arena_info_cache_t()
{
}
void sc_arena_info_cache_t::load_db(vector<int32_t>& hostnums_)
{
    for (auto it = hostnums_.begin(); it != hostnums_.end(); ++it)
    {
        sql_result_t res;
        if (0 == db_ArenaInfo_t::sync_select_hostnum(*it, res))
        {
            for (size_t i = 0; i < res.affect_row_num(); ++i)
            {
                sp_arena_info_t sp_arena_info(new arena_info_t);
                sp_arena_info->init(*res.get_row_at(i));
                m_arena_info.insert(make_pair(sp_arena_info->uid, sp_arena_info));
                m_hlu[sp_arena_info->hostnum*1000+sp_arena_info->level].push_back(sp_arena_info->uid);
            }
        }
    }
}
void sc_arena_info_cache_t::update(int32_t hostnum_, int32_t uid_, int32_t total_fp_, int32_t level_, int32_t* pid_)
{
    auto it = m_arena_info.find(uid_);
    if (it == m_arena_info.end())
    {
        sp_arena_info_t sp_arena_info_(new arena_info_t);
        sp_arena_info_->uid = uid_;
        sp_arena_info_->total_fp = total_fp_;
        sp_arena_info_->hostnum = hostnum_;
        sp_arena_info_->level = level_;
        sp_arena_info_->pid1 = pid_[0];
        sp_arena_info_->pid2 = pid_[1];
        sp_arena_info_->pid3 = pid_[2];
        sp_arena_info_->pid4 = pid_[3];
        sp_arena_info_->pid5 = pid_[4];
        m_arena_info.insert(make_pair(uid_, sp_arena_info_));
        it = m_arena_info.find(uid_);
        auto t = m_hlu.find(hostnum_*1000 + level_);
        if (t != m_hlu.end())
            t->second.push_back(uid_);
        else m_hlu[hostnum_*1000 + level_].push_back(uid_);

        db_service.async_do((uint64_t)uid_, [](db_ArenaInfo_t& db_) {
            db_.insert();
        }, sp_arena_info_->data());
        return;
    }
    if (it->second->total_fp >= total_fp_)
        return;
    if (it->second->level != level_)
    {
        auto t = m_hlu.find(hostnum_*1000 + it->second->level);
        t->second.remove(uid_);
        m_hlu[hostnum_*1000 + level_].push_back(uid_);
    }

    it->second->total_fp = total_fp_;
    it->second->level = level_;
    it->second->pid1 = pid_[0];
    it->second->pid2 = pid_[1];
    it->second->pid3 = pid_[2];
    it->second->pid4 = pid_[3];
    it->second->pid5 = pid_[4];
    db_service.async_do((uint64_t)uid_, [](db_ArenaInfo_t& db_){
        db_.update();
    }, it->second->data());
}
/*
 * @comment fanbin
 * @function 
 *   用于远征选择敌人，在同一个hostnum_的用户中选取等级为level_
 *   的任意一个玩家的默认队伍作为远征的某一关卡的敌人
 * @params
 *   hostnum_: 服务器编号
 *   uid: 玩家uid，用于防止选中自己作为敌人
 *   level_: 某一等级中的玩家
 *   uid_: 填充数据，将选中的玩家的uid填充至此
 *   pid_: 选中玩家的默认队伍的pid[]数据
 * @return
 *   bool: true选取成功, false选取失败
 */
bool sc_arena_info_cache_t::get_arena_pid(int32_t hostnum_, int32_t uid, int32_t level_, int32_t& uid_, int32_t* pid_)
{
    auto it = m_hlu.find(hostnum_*1000 + level_);
    if (it == m_hlu.end())
        return false;
    size_t size = it->second.size();
    uint32_t r = random_t::rand_integer(1, size);
    uint32_t cnt = 0;
    int iuid = 0;
    for (auto iit = it->second.begin(); iit != it->second.end(); ++iit)
    {
        ++cnt;
        if (cnt == r)
        {
            if (*iit == uid || iuid == uid)
            {
                --cnt;
                continue;
            }
            iuid = *iit;
            break;
        }
    }
    auto it2 = m_arena_info.find(iuid);
    if (it2 == m_arena_info.end())
        return false;
    uid_ = iuid;
    pid_[0] = it2->second->pid1;
    pid_[1] = it2->second->pid2;
    pid_[2] = it2->second->pid3;
    pid_[3] = it2->second->pid4;
    pid_[4] = it2->second->pid5;
    return true;
}

bool
sc_arena_info_cache_t::get_arena_pid(int32_t from_, int32_t to_, int32_t& uid_,
                                     int32_t* pid_)
{
    int32_t rank = random_t::rand_integer(from_, to_);
    int32_t uid = arena_rank.get_user(rank);
    if (0 == uid) {
        return false;
    }
    sp_view_user_t sp_view = view_cache.get_view(uid, true);
    if (sp_view == NULL)  {
        return false;
    }
    uid_ = uid;
    int i = 0;
    pid_[0] = pid_[1] = pid_[2] = pid_[3] = pid_[4] = -1;
    for (auto it = sp_view->roles.begin(); it != sp_view->roles.end(); ++it) {
        pid_[i++] = it->second.pid;
    }
    return true;
}

sp_fight_view_user_t
sc_arena_info_cache_t::get_arena_view(int32_t rank_, int32_t& uid_, bool& succ_)
{
    sp_fight_view_user_t view_(new sc_msg_def::jpk_fight_view_user_data_t());
    uid_ = arena_rank.get_user(rank_);
    if (0 == uid_) {
        succ_ = false;
        return view_;
    }
    sp_view_user_t sp_view = view_cache.get_view(uid_, true);
    if (sp_view == NULL)  {
        succ_ = false;
        return view_;
    }

    view_->uid = sp_view->uid;
    view_->name = sp_view->name;
    view_->rank = sp_view->rank;
    view_->lv = sp_view->lv;
    view_->fp = sp_view->fp;
    view_->viplevel = sp_view->viplevel;
    view_->combo_pro = sp_view->combo_pro;
    auto change_2 = [](float num_) 
    {
        double d_n = (double)((int)((num_+0.005)*100))/100;
        return float(d_n);
    };
    for (auto it = sp_view->roles.begin(); it != sp_view->roles.end(); ++it) 
    {
        sc_msg_def::jpk_fight_view_role_data_t role_fight_data;
        role_fight_data.uid = it->second.uid;
        role_fight_data.pid = it->second.pid;
        role_fight_data.resid = it->second.resid;
        
        for(auto it_skl = it->second.skls.begin(); it_skl != it->second.skls.end(); ++it_skl)
        {
            vector<int32_t> tmp;
            tmp.push_back(it_skl->skid);
            tmp.push_back(it_skl->resid);
            tmp.push_back(it_skl->level);
            role_fight_data.skls.push_back(std::move(tmp));
        }

        role_fight_data.pro.clear();
        role_fight_data.pro.push_back(change_2(float(it->second.pro.atk)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.mgc)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.def)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.res)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.hp)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.cri)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.acc)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.dodge)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.fp)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.power)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.ten)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.imm_dam_pro)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.move_speed)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.factor[0])));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.factor[1])));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.factor[2])));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.factor[3])));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.factor[4])));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.atk_power)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.hit_power)));
        role_fight_data.pro.push_back(change_2(float(it->second.pro.kill_power)));

        role_fight_data.lvl.clear();
        role_fight_data.lvl.push_back(it->second.lvl.level);
        role_fight_data.lvl.push_back(it->second.lvl.lovelevel);

        if (it->second.wings.size() > 0)
        {
            role_fight_data.wid = it->second.wings[0].resid;
        }
        else
        {
            role_fight_data.wid = -1;
        }
        view_->roles.insert(make_pair(it->first, role_fight_data));
    }
    
    succ_ = true;
    return view_;
}
