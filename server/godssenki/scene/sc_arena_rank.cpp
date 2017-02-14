#include "sc_arena_rank.h"
#include "sc_arena_page_cache.h"
#include "sc_gang.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_logic.h"
#include "config.h"
#include "db_service.h"
#include "date_helper.h"
#include "random.h"
#include "sc_cache.h"
#include "sc_name.h"
#include "sc_rank.h"
#include "sc_card_event.h"

#include <atomic>
#include <unistd.h>

#define LOG "SC_ARENA_RANK"

#define REWARD_BTP_OFF 1200
//#define ROLE_RESID_BEGIN 1001
//#define ROLE_RESID_END 1006
#define ROLE_RESID_BEGIN 101
#define ROLE_RESID_END 103

#define ARENA_RANK_REWARD1 69 * 3600
#define ARENA_RANK_REWARD2 141 * 3600
#define ARENA_RANK_REWARD3 213 * 3600

#define BEGIN_REWARD_STAMP 21*3600
#define END_REWARD_STAMP 21*3600 + 1800

sc_arena_rank_t::sc_arena_rank_t():m_max_rank(0),m_reward_btp_time(0),m_is_send(false),m_send_reward_stamp(0),issend1(false),issend2(false),issend3(false)
{
    memset(m_rank, 0, sizeof(m_rank));
    memset(m_reward_rank, 0, sizeof(m_reward_rank));
}

int sc_arena_rank_t::load_db(vector<int32_t>& hostnums_)
{
    logwarn((LOG, "load arena rank ..."));

    //已经加载过就不能再次加载
    if (m_max_rank >= MAX_RANK)
    {
        load_reward_rank();
        return 0;
    }

    string str_hosts;
    for (int32_t host : hostnums_)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);
    strcpy(db_sql, str_hosts.c_str());
    char sql[256];
    sql_result_t res;

    sprintf(sql, "select uid, rank, nickname, grade, fp, utype,viplevel from UserInfo where hostnum in (%s) and rank>=1 and rank<2001 order by rank desc;", str_hosts.c_str());
    db_service.sync_select(sql, res);

    //如果排名不存在，初始化机器人
    if (res.affect_row_num() <= 0)
    {
        printf("create robot ...!\n");
        for(int i=1; i<=MAX_RANK; i++)
        {
            //init_robort(i);
        }
        arena_page_cache.init_serialize();
        printf("create robot ok!\n");
        
        return 1;
    }


    int uid = 0;
    int rank = 0;
    string name = "";
    int grade = 0;
    int fp = 0;
    int utype = 0;
    int uVip = 0;

    int ranks[MAX_RANK+1];
    memset(ranks, 0, sizeof(ranks));

    int size_data = res.affect_row_num();

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int)std::atoi(row_[0].c_str());
        rank=(int)std::atoi(row_[1].c_str());
        name=row_[2];
        grade=(int)std::atoi(row_[3].c_str());
        fp=(int)std::atoi(row_[4].c_str());
        utype=(int)std::atoi(row_[5].c_str());
        uVip=(int)std::atoi(row_[6].c_str());

        add_user(uid, rank);
        arena_page_cache.add_row(uid, rank, name, grade, fp, utype,uVip);
    }
    arena_page_cache.init_serialize();
    load_reward_rank();

/*
    //加载1500名一个用户
    sprintf(sql, "select uid,rank from UserInfo where hostnum=%d and rank=1500 limit 1;", hostnums_[0]);
    db_service.sync_select(sql, res);
    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int)std::atoi(row_[0].c_str());
        rank=(int)std::atoi(row_[1].c_str());
        add_user(uid, rank);
    }


    //加载1501到2000的机器人
    sprintf(sql, "select uid,rank from UserInfo where hostnum=%d and rank>1500 and rank<2000 and utype=1;", hostnums_[0]);
    db_service.sync_select(sql, res);
    if (res.affect_row_num() == 0)
    {
        for(int i=1501; i<=MAX_RANK; i++)
        {
            init_robort(i);
        }
        return 0;
    }

    for(size_t i=0; i<res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        uid=(int)std::atoi(row_[0].c_str());
        rank=(int)std::atoi(row_[1].c_str());
        add_user(uid, rank);
    }
*/
    uint32_t cur_sec_ = date_helper.cur_sec();
    uint32_t today_sec_ = (cur_sec_ % 86400);
    m_send_reward_stamp = cur_sec_;
    if (today_sec_ >= BEGIN_REWARD_STAMP && today_sec_ <= END_REWARD_STAMP && !m_is_send)
    {
        update_reward(0);
    }
    return 0;
}
int32_t sc_arena_rank_t::get_user(int rank_)
{
    if (rank_ >= 1 && rank_ <= MAX_RANK)
    {
        return m_rank[rank_];
    }
    return 0;
}
void sc_arena_rank_t::get_user(int& rank_, uint32_t& uid_)
{
    if (rank_ < 1 || rank_ > MAX_RANK)
    {
        uid_ = 0;
        return;
    }
    while((m_rank[rank_] == 0) && rank_ > 5)
    {
        rank_--;
    }
    uid_ = m_rank[rank_];
}
int32_t sc_arena_rank_t::add_user(int32_t uid_, int32_t rank_)
{
    if (rank_ >= 1 && rank_ <= MAX_RANK)
    {
        m_rank[rank_] = uid_;
        if (m_max_rank < rank_)
            m_max_rank = rank_;
        if (m_max_rank >= 50)
            card_event_s.unlock_new_host();
        return rank_;
    }
    if (rank_ == 0 && m_max_rank < MAX_RANK)
    {
        m_rank[++m_max_rank] = uid_;
        if (m_max_rank >= 50)
            card_event_s.unlock_new_host();
        return m_max_rank;
    }
    return MAX_RANK;
}
void sc_arena_rank_t::swap_user(int32_t uid1_, int& rank1_, int32_t uid2_, int& rank2_)
{
    logwarn((LOG, "SWAP_USER %d, %d, %d, %d", uid1_, rank1_, uid2_, rank2_));
    if (rank1_ <= rank2_)
        return;

    //1500到2000之间，则只提升排名
    /*
    if (rank1_ >= SWAP_MAX_RANK && rank2_ >= SWAP_MAX_RANK)
    {
        rank1_ = rank2_;
        char sql[512];
        sprintf(sql, "update UserInfo set `rank` = %d where uid=%d", rank1_, uid1_);
        db_service.sync_execute(sql);
        db_update_rank(uid1_, rank1_);
        return;
    }

    //战胜超过1500名的人，则目标只下降到1500名
    if (rank1_ >= SWAP_MAX_RANK && rank2_ < SWAP_MAX_RANK)
    {
        m_rank[rank2_] = uid1_;
        rank1_ = rank2_;
        rank2_ = SWAP_MAX_RANK;
        char sql[512];
        sprintf(sql, "update UserInfo set `rank` = case uid when %d then %d when %d then %d end where uid in (%d,%d)",
                uid1_, rank1_, uid2_, rank2_, uid1_, uid2_);
        db_service.sync_execute(sql);
        db_update_rank(uid1_, rank1_);
        db_update_rank(uid2_, rank2_);
        return;
    }
    */

    //一般情况
    //if (rank1_ < SWAP_MAX_RANK && rank2_ < SWAP_MAX_RANK)
    if ( true )
    { 
        m_rank[rank1_] = uid2_;
        m_rank[rank2_] = uid1_;
        std::swap(rank1_, rank2_);
        char sql[512];
        sprintf(sql, "update UserInfo set `rank` = case uid when %d then %d when %d then %d end where uid in (%d,%d)",
                uid1_, rank1_, uid2_, rank2_, uid1_, uid2_);
        logwarn((LOG, "SWAP_USER SQL %s", sql));
        db_service.sync_execute(sql);
        db_update_rank(uid1_, rank1_);
        db_update_rank(uid2_, rank2_);
        return;
    }
}
void sc_arena_rank_t::db_update_rank(int32_t uid_, int32_t rank_)
{
    //设置公会用户等级
    sp_gang_t sp_gang; 
    sp_ganguser_t sp_guser; 
    if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
    {
        sp_gang->on_rank_changed(uid_, rank_);
    }
}
int sc_arena_rank_t::save_reward_rank()
{
    memcpy(m_reward_rank, m_rank, sizeof(m_rank));

    const char* path = config.res.rank_path.c_str();
	int rc = access(path, F_OK);
	if (0 != rc)
	{	// 目录不存在,创建
		rc = mkdir(path, 0777);
		if (rc != 0)
		{
            logerror((LOG, "create %s failed!", path));
			return -1;
		}
	}

    char fullpath[64];
    sprintf(fullpath, "%s/rank_%d", path, config.serid);

    FILE* file = fopen(fullpath, "wb");
    if (file)
    {
        fwrite(m_reward_rank, sizeof(m_reward_rank), 1, file);
        fclose(file);
    }
    return 0;
}
int sc_arena_rank_t::load_reward_rank()
{
    const char* path = config.res.rank_path.c_str();
	int rc = access(path, F_OK);
	if (0 != rc)
	{	// 目录不存在,创建
		rc = mkdir(path, 0777);
		if (rc != 0)
		{
            logerror((LOG, "create %s failed!", path));
			return -1;
		}
	}

    char fullpath[64];
    sprintf(fullpath, "%s/rank_%d", path, config.serid);

    FILE* file = fopen(fullpath, "rb");
    if (file != NULL)
    {
        fread(m_reward_rank, sizeof(m_reward_rank), 1, file);
        fclose(file);
    }
    return 0;
}
int sc_arena_rank_t::get_reward_rank(int uid_)
{
    for(int i=1; i<=MAX_RANK; i++)
    {
        if (m_reward_rank[i] == 0)
            continue; 
        if (m_reward_rank[i] == uid_)
            return i;
    }
    return MAX_RANK;
}
int sc_arena_rank_t::get_reward_id(int rank_)
{
    if (rank_ > 2000) return 2001;
    if (rank_ > 1000) return 2000;
    if (rank_ > 700) return 1000;
    if (rank_ > 500) return 700;
    if (rank_ > 400) return 500;
    if (rank_ > 300) return 400;
    if (rank_ > 200) return 300;
    if (rank_ > 100) return 200;
    return rank_;
}
void sc_arena_rank_t::update_reward(int sec__)
{
    if (date_helper.offday(m_send_reward_stamp) >= 1)
    {
        m_is_send = false;
        m_send_reward_stamp = date_helper.cur_sec() + 600; // 确保进入下一天
        return;
    }
    if (m_is_send)
        return;

    uint32_t today_sec_ = date_helper.cur_sec() - date_helper.cur_0_stmp();
    if (!(today_sec_ >= BEGIN_REWARD_STAMP && today_sec_ <= END_REWARD_STAMP))
        return;

    logerror((LOG, "==================SEND REWARD BEGIN=============================="));

    char sql[256];
    sql_result_t res;

    //sprintf(sql, "select uid, rank from UserInfo where hostnum in (%s) and rank>=1 and rank<=%d order by rank asc;", db_sql, MAX_RANK);
    sprintf(sql, "select uid, rank, m_rank,grade from UserInfo where hostnum in (%s) and rank>=1 and rank<=%d order by rank asc;", db_sql, MAX_RANK);
    db_service.sync_select(sql, res);

    if (res.affect_row_num() > 0)
    {
        sc_gmail_mgr_t::begin_offmail();
        for(size_t i = 0; i < res.affect_row_num(); i++)
        {
            if (i > MAX_RANK + 1000) break;

            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                break;
            }

            sql_result_row_t& row_ = *res.get_row_at(i);
            int uid = (int)std::atoi(row_[0].c_str());
            int rank = (int)std::atoi(row_[1].c_str());
            int mrank = (int)std::atoi(row_[2].c_str());
            int lvl = (int)std::atoi(row_[3].c_str());
            if (lvl < 21) //竞技场未开启不发奖
                continue;
            mrank = 0;//屏蔽跨服竞技场奖励
            //if(mrank != 0)
                //rank = rank < mrank ? rank : mrank;//取本服和全服排行中最小的发奖励 WTF
            if (rank == 1)
                rank_ins.update_rank_infos(uid, arena_top, rank);
            else if (rank <= 5)
                rank_ins.update_rank_infos(uid, arena_five, rank);

            //logerror((LOG, "SEND REWARD %d %d", uid, rank));
            repo_def::arena_reward_t* rp = repo_mgr.arena_reward.get(get_reward_id(rank));
            //if (rp == NULL)
                //continue;

            if (uid != 0 && rp != NULL)
            {
                //if (sp_user->db.rank > MAX_RANK) continue;
                sc_msg_def::nt_bag_change_t nt;
                sc_msg_def::jpk_item_t item;
                item.itid = 0;
                item.resid = 10010;
                item.num = rp->honor_win;
                nt.items.push_back(item);
                for (size_t i = 1; i < rp->item.size(); ++i)
                {
                    item.itid = 0;
                    item.resid = rp->item[i][0];
                    item.num = rp->item[i][1];
                    nt.items.push_back(item);
                }

                auto rp_gmail = mailinfo.get_repo(mail_arena_reward);
                if (rp_gmail != NULL)
                {
               //     string msg = mailinfo.new_mail(mail_arena_reward, rank);
                    char msg[256];
                    sprintf(msg, "json:%d", rank); 
                    sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                    //sp_user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                }
            }
            if(mrank != 0){
                repo_def::in_arena_reward_t* rp_in = repo_mgr.in_arena_reward.get(get_reward_id(mrank));
                if (uid != 0 && rp_in != NULL)
                {
                    //if (sp_user->db.rank > MAX_RANK) continue;
                    sc_msg_def::nt_bag_change_t nt;
                    sc_msg_def::jpk_item_t item;
                    item.itid = 0;
                    item.resid = 16013;//todo
                    item.num = rp_in->honor_win;
                    nt.items.push_back(item);
                    for (size_t i = 1; i < rp_in->item.size(); ++i)
                    {
                        item.itid = 0;
                        item.resid = rp_in->item[i][0];
                        item.num = rp_in->item[i][1];
                        nt.items.push_back(item);
                    }

                    auto rp_gmail = mailinfo.get_repo(mail_inarena_reward);
                    if (rp_gmail != NULL)
                    {
                        string msg = mailinfo.new_mail(mail_inarena_reward, mrank);
                        sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                        //sp_user->gmail.send(rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items); 
                    }
                }
            }
        }
        sc_gmail_mgr_t::do_offmail();
    }
    logerror((LOG, "==================SEND  REWARD END!!=============================="));
    m_is_send = true;
}
void sc_arena_rank_t::on_login(uint32_t uid_)
{
    /*
    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        if (sp_user->db.lastquit <= 0)
            return;

        if (sp_user->db.rank >= SWAP_MAX_RANK)
            return;

        repo_def::salary_t* rp = repo_mgr.salary.get(sp_user->db.rank);
        if (rp == NULL)
            return;

        int ntime = date_helper.offsec(sp_user->db.lastquit) / REWARD_BTP_OFF;
        int btp = rp->btp * ntime;
        if (btp > 0)
        {
            sp_user->on_battlexp_change(btp);
            sp_user->save_db();

            string mail = mailinfo.new_mail(mail_arena_reward, sp_user->db.rank, btp);
            if (!mail.empty())
            {
                notify_ctl.push_mail(uid_, mail);
            }
        }
    }
    */
}
int sc_arena_rank_t::get_reward_btp_cd()
{
    int cd = REWARD_BTP_OFF - m_reward_btp_time;
    if (cd < 0)
        return 0;
    return cd;
}
void sc_arena_rank_t::init_robort(int rank_)
{
    sql_result_t res;
    //插入角色ID
    db_UserID_ext_t userid;

    if ((userid.aid = dbid_assign.new_dbid("aid"))==0)
    {
        logerror((LOG, "init_robort, create new aid failed!"));
        return;
    }

    userid.resid = random_t::rand_integer(ROLE_RESID_BEGIN, ROLE_RESID_END); 

    if ((userid.uid = dbid_assign.new_dbid("uid"))==0)
    {
        logerror((LOG, "init_robort, create new uid failed!"));
        return;
    }

    do
    {
        userid.nickname = gen_name.random_name();
        if (userid.nickname.empty())
        {
            logerror((LOG, "on_req_new_role, create random_name failed!"));
            return;
        }

        //! 异步执行步执行sql操作 只能用在async_do中
        char sql[256]; 
        sprintf(sql, "select uid from UserID where nickname='%s'",userid.nickname.c_str());
        db_service.sync_select(sql, res);
    }while(res.affect_row_num() > 0);

    repo_def::robot_conf_t* conf = NULL;
    for(auto it=repo_mgr.robot_conf.begin(); it!=repo_mgr.robot_conf.end(); it++)
    {
        if (it->second.rank[1] <= rank_ && rank_ <= it->second.rank[2])
        {
            conf = &(it->second);
            break;
        }
    }

    userid.grade = conf->level;
    userid.viplevel = 0;
    userid.state = 100;
    userid.hostnum = config.serid; 
    userid.isoverdue = 0;
    if (userid.sync_insert())
    {
        logerror((LOG, "init_robort, create new role failed!"));
        return;
    }

    sp_user_t sp_user(new sc_user_t());
    sp_user->init_new_user(userid);

    sp_user->db.set_grade(conf->level);
    sp_user->db.set_utype(1);

    yarray_t<int32_t, TEAM_BATTLE_SIZE> team;
    team[1] = team[2] = team[3] = team[4] = -1;

    set<int> exist_partner;
    for(int i=0; i<conf->number; i++)
    {
        int r = random_t::rand_integer(1, conf->item_pro.size()-1);
check_existed:
        r= (r+1) % conf->item_pro.size();
        r= r<= 0 ? 1 : r;
        int resid = conf->item_pro[r];
        if (exist_partner.find(resid) != exist_partner.end())
            goto check_existed;
        exist_partner.insert(resid);
        sp_partner_t sp_partner = sp_user->partner_mgr.hire(resid, 0);
        if (sp_partner != NULL)
        {
            sp_partner->db.set_grade(conf->level);
            sp_partner->save_db();
        }
        //伙伴进队伍
        team[i+1] = sp_partner->db.pid;
    }
    // 暂时注释 等到做pvp的时候回来写
    sp_user->team_mgr.change_team(team, 1);
    
    sp_user->db.set_fp( sp_user->get_total_fp() );

    sp_user->save_db();

    sp_view_user_t sp_view = sp_user->get_view();
    view_cache.put(userid.uid, sp_view);

    const db_UserInfo_t& db = sp_user->db;
    arena_page_cache.add_row(db.uid, db.rank, db.nickname.c_str(), db.grade, db.fp, db.utype,db.viplevel);
}

void sc_arena_rank_t::update_rank_info()
{ 
    if((date_helper.secoffday() >= 21 * 3600) && (m_arena_serize_tm < date_helper.cur_0_stmp())) 
    {
        char sql[256];
        sql_result_t res;

        sprintf(sql, "select uid, rank from UserInfo where hostnum in (%s) and rank>=1 and rank<=5 order by rank asc;", db_sql);
        db_service.sync_select(sql, res);

        if (res.affect_row_num() > 0)
        {
            for(size_t i=0; i<res.affect_row_num(); i++)
            {
                if (res.get_row_at(i) == NULL)
                {
                    logerror((LOG, "get_row_at is NULL!!, at:%lu", i));
                    break;
                }

                sql_result_row_t& row_ = *res.get_row_at(i);
                int uid=(int)std::atoi(row_[0].c_str());
                int rank=(int)std::atoi(row_[1].c_str());
                if (rank == 1)
                    rank_ins.update_rank_infos(uid, arena_top, rank);
                else
                    rank_ins.update_rank_infos(uid, arena_five, rank);
            }
        }
    }

    m_arena_serize_tm = date_helper.cur_sec();
}

void sc_arena_rank_t::send_reward()
{
    int32_t time1 = date_helper.cur_sec() - ARENA_RANK_REWARD1 - server.db.ctime;
    int32_t time2 = date_helper.cur_sec() - ARENA_RANK_REWARD2 - server.db.ctime;
    int32_t time3 = date_helper.cur_sec() - ARENA_RANK_REWARD3 - server.db.ctime;
    if((time1 >= 0 && time1 <= 5 && !issend1) || (time2>= 0 && time2 <= 5 && !issend2) || (time3 >= 0 && time3 <= 5 && !issend3)) 
    {
        if(time1 >= 0)
            issend1 = true;
        if(time2 >= 0)
            issend2 = true;
        if(time3 >= 0)
            issend3 = true;
        
        char sql_user[256];
        sql_result_t res_user;

        sprintf(sql_user, "select uid, rank, m_rank from UserInfo where hostnum in (%s) and rank>=1 and rank<=20 order by rank asc;", db_sql);
        db_service.sync_select(sql_user, res_user);
        
        sc_gmail_mgr_t::begin_offmail();
        for(size_t i = 0; i < res_user.affect_row_num(); ++i)
        {
            if(res_user.get_row_at(i) == NULL)
            {
                logerror((LOG, "get row is NULL!, pub limit reward at:%lu",i));
                break;
            }
            if(i > 10)
                break;

            sql_result_row_t& row_ = *res_user.get_row_at(i);
            int32_t uid = (int32_t)std::atoi(row_[0].c_str());
            int32_t rank_ = (int32_t)std::atoi(row_[1].c_str());
            //jp
            /*            
            for(int32_t index = 1; index <= 10; index++)
            {
                repo_def::newly_reward_t* publimit_pub_info = repo_mgr.newly_reward.get(500 + index);
                if(publimit_pub_info != NULL)
                {
                    if(rank_ <= publimit_pub_info->value)
                    {
                        sc_msg_def::nt_bag_change_t nt;
                        for(size_t itemindex = 1;itemindex < publimit_pub_info->reward.size();itemindex++)
                        {
                            sc_msg_def::jpk_item_t item_;
                            item_.itid = 0;
                            item_.resid = publimit_pub_info->reward[itemindex][0];
                            item_.num = publimit_pub_info->reward[itemindex][1];
                            nt.items.push_back(item_);
                        }
                        auto rp_gmail = mailinfo.get_repo(mail_arena_rank);

                        if (rp_gmail != NULL)
                        {
                             string msg = mailinfo.new_mail(mail_arena_rank, i + 1);
                             sc_gmail_mgr_t::add_offmail(uid, rp_gmail->title, rp_gmail->sender, msg, rp_gmail->validtime, nt.items);
                             break;
                        }
                    }
                }
            }
            */
        }
        sc_gmail_mgr_t::do_offmail();
    }

}
