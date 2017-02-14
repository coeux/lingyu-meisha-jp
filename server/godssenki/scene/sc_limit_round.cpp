#include "sc_limit_round.h"
#include "sc_logic.h"
#include "date_helper.h"
#include "log.h"
#include "repo_def.h"
#include "random.h"
#include "sc_act_daily_task.h"
#include "sc_partner.h"
#include "db_def.h"

#define LOG "SC_LOGIC"

#define LIMIT_ROUND_CD_TIME 900
#define LIMIT_ROUND_MAX_TIMES 3
/*
#define LIMIT_REFRESH_H 1463106000 
#define LIMIT_REFRESH_SEC 50
*/

const int round_id[20][2] = {
    {3, 2}, {4, 3}, {5, 4}, {2, 5},
    {2, 5}, {2, 3}, {2, 4}, {2, 5},
    {3, 4}, {3, 2}, {3, 4}, {3, 5},
    {4, 3}, {4, 2}, {4, 3}, {4, 5},
    {5, 2}, {5, 2}, {5, 3}, {5, 3}
};
const int round_list_v[12][2] = {
    {2,3},{4,5},{2,4},{3,5},    
    {2,5},{3,4},{3,2},{5,4},
    {4,2},{5,3},{5,2},{4,3}
};

sc_limit_round_mgr_t::sc_limit_round_mgr_t()
{
    gen_time = 0;
}

sc_limit_round_mgr_t::~sc_limit_round_mgr_t()
{
}

void sc_limit_round_mgr_t::init_round_mgr_data()
{
}

void sc_limit_round_mgr_t::gen_limit_round()
{
    vector<int> limit_round;
    int count = 0;
    for(auto it= repo_mgr.limited_round_data.begin(); it!=repo_mgr.limited_round_data.end(); it++)
    {
        int round_id = (it->first - 7000)/10;
        bool is_in = false;
        for(int i=0;i<count;i++)
        {
            if( limit_round[i] == round_id )
            {
                is_in = true;
                break;
            }
        }
        if ( not is_in )
        {
            count++;
            limit_round.push_back(round_id);
        }
    }
    gen_time = date_helper.cur_sec();
/*
    int first = random_t::rand_integer(0, count-1);
    int second = random_t::rand_integer(0, count-2);
    if( second >= first){
        second++;
    }

    m_limit_open_round.clear();
    m_limit_open_round.push_back(round_list[first]);
    m_limit_open_round.push_back(round_list[second]);
     vector<vector<int>> round_list;
     auto rl_it1 = limit_round.begin();
     auto rl_it2 = rl_it1+1;
     while (rl_it1!= limit_round.end()){
        if (rl_it2 == limit_round.end()){
                break; 
        } 
        vector<int> round;
        round.push_back(*rl_it1);
        round.push_back(*rl_it2);
        round_list.push_back(round);
        rl_it1+=2;
        rl_it2+=2;

    } 
    */
    /*
     cout<<"-->2"<<endl;
    auto rl_it3 = limit_round.begin();
    auto rl_it4 = limit_round.rbegin();
    while(rl_it3 < rl_it4){
        vector<int> round;
        round.push_back(*rl_it3);
        round.push_back(*rl_it4);     
        round_list.push_back(round);
        cout<<"while-it3->"<<*rl_it3<<" -it4->"<<*rl_it4<<endl;
        rl_it3++;
        rl_it4++;
    }
    */
    /*
    int lr_size = limit_round.size();
    int lr_base = lr_size/2;
    for(int i = 0 ; i < lr_size;i++){
        if (i>=lr_base)
            break;
        vector<int> round;
        round.push_back(limit_round[i]);
        round.push_back(limit_round[lr_size-i-1]); 
        round_list.push_back(round);
    }
    */
    int32_t curSec = date_helper.cur_sec();
    int32_t dayCount = curSec/86400;
    int index = dayCount%12;
    m_limit_open_round.clear();
    m_limit_open_round.push_back(round_list_v[index][0]); 
    m_limit_open_round.push_back(round_list_v[index][1]);
}

void sc_limit_round_mgr_t::req_user_login_data(int uid_, sc_user_t& user_, sc_msg_def::ret_user_data_t& user_data_)
{
    get_user_round_data(uid_,user_,user_data_.round);
}
int32_t sc_limit_round_mgr_t::req_reset_limit_round_times(int uid_,sc_user_t &user_,sc_msg_def::ret_reset_limit_round_times &round_data)
{
    auto it = m_user_data.find(uid_);
    if (it != m_user_data.end()) {
        
        int timesec = date_helper.cur_sec() - (it->second)->m_user_last_reset_time;
        if (timesec >= LIMIT_ROUND_CD_TIME)
            round_data.round.limit_round_sec = 0;
        else round_data.round.limit_round_sec = LIMIT_ROUND_CD_TIME - timesec;

        sql_result_t res;
        db_LimitRound_t db;
        if (0 != db_LimitRound_t::sync_select_uid(uid_,res))
            return FAILED;
        db.init(*res.get_row_at(0));
        if (db.reset_times <= 0)
            return ERROR_NOT_ENOUGH_RESET_TIMES;

        if (user_.rmb() < 50)
        {
            return ERROR_SC_NO_YB;
        }
        user_.consume_yb(50);

        db.reset_times -= 1;
        db_service.async_do(uint64_t(uid_),[](db_LimitRound_t& db_){
                db_.update();
                },db);
        user_.db.set_limitround(0);
        user_.save_db();
        round_data.round.limit_round_left = 0;
        round_data.round.limit_round_reset_times = db.reset_times;

    }else {
        logerror((LOG, "req_reset_limit_round_times, can't find user data, id:%d" , uid_));
        return FAILED;
    }
     
    return SUCCESS;
}
void sc_limit_round_mgr_t::req_user_round_data(int uid_,sc_user_t &user_, sc_msg_def::ret_limit_round_data &limit_user_data)
{
   limit_user_data.code = SUCCESS;
   get_user_round_data(uid_,user_,limit_user_data.round);     
}
void sc_limit_round_mgr_t::get_user_round_data(int uid_,sc_user_t &user_,sc_msg_def::jpk_round_data_t &round_data)
{
    if (!gen_time || (gen_time && date_helper.offday(gen_time) >= 1))
        gen_limit_round();
    round_data.limit_round_left = user_.db.limitround;

    int32_t reset_trial = 0; 
    repo_def::vip_t* vipinfo = repo_mgr.vip.get(user_.db.viplevel);
    if (vipinfo != NULL)
    {
        reset_trial = vipinfo->reset_trial; 
    }

    auto it = m_user_data.find(uid_);
    if (it != m_user_data.end()) {
        int timesec = date_helper.cur_sec() - (it->second)->m_user_last_reset_time;
        if (timesec >= LIMIT_ROUND_CD_TIME)
            round_data.limit_round_sec = 0;
        else round_data.limit_round_sec = LIMIT_ROUND_CD_TIME - timesec;
        for (auto it = m_limit_open_round.begin(); it != m_limit_open_round.end(); ++it)
            round_data.limit_open_round.push_back((*it));

        sql_result_t res;
        db_LimitRound_t db;
        if (0 == db_LimitRound_t::sync_select_uid(uid_,res)){
            db.init(*res.get_row_at(0));     
            round_data.limit_round_reset_times = db.reset_times;
        } else 
            round_data.limit_round_reset_times = reset_trial;

        
        
        int off_day = date_helper.offday((it->second)->m_user_whole_time_stamp);
        if (off_day) {
            (it->second)->m_user_whole_time_stamp = date_helper.cur_sec();
            round_data.limit_round_sec = 0;
            round_data.limit_round_left = 0;
            round_data.limit_round_reset_times = reset_trial;
            for (auto it = m_limit_open_round.begin(); it != m_limit_open_round.end(); ++it)
                round_data.limit_open_round.push_back((*it));
            user_.db.set_limitround(0);
            user_.save_db();
            sql_result_t res;
            db_LimitRound_t db;
            if (0 == db_LimitRound_t::sync_select_uid(uid_,res)){
                db.init(*res.get_row_at(0));     
                db.lasttime = date_helper.cur_sec();
                db.reset_times = reset_trial;
                db_service.async_do((uint64_t)uid_,[](db_LimitRound_t& db_){
                    db_.update();     
                },db);
            }
            else {
                db.uid = uid_;
                db.lasttime = date_helper.cur_sec();     
                db.reset_times = reset_trial;
                db_service.async_do((uint64_t)uid_,[](db_LimitRound_t& db_){
                    db_.insert();     
                },db);
            }
        }
    } else {
        sql_result_t res;
        db_LimitRound_t db;
        bool newFlag = false;
        if (0==db_LimitRound_t::sync_select_uid(uid_,res)){
            db.init(*res.get_row_at(0));     
        }
        else {
           newFlag = true;
           db.uid = uid_;
           db.lasttime = date_helper.cur_sec();      
           db.reset_times = reset_trial;
           db_service.async_do((uint64_t)uid_,[](db_LimitRound_t& db_){
              db_.insert(); 
            },db);

        }
        if (newFlag) {
            round_data.limit_round_left = 0;
            user_.db.set_limitround(0);
            user_.save_db();
        }
        if (date_helper.offday(db.lasttime)){
            round_data.limit_round_left = 0;
            user_.db.set_limitround(0);
            user_.save_db();
            db_LimitRound_t db;
            db.uid = uid_;
            db.lasttime = date_helper.cur_sec(); 
            db.reset_times = reset_trial;
            db_service.async_do((uint64_t)uid_,[](db_LimitRound_t& db_){
                db_.update();     
            },db);
        }
        else if(!newFlag) {
            round_data.limit_round_left = user_.db.limitround; 
        }
        sc_limit_user_data* udata = new sc_limit_user_data();
        udata->m_user_whole_time_stamp = date_helper.cur_sec();
        udata->m_fight_start_time_stamp = date_helper.cur_sec();
        m_user_data.insert(std::map<int, sc_limit_user_data*>::value_type(uid_, udata));
        round_data.limit_round_sec = 0;
        round_data.limit_open_round.push_back(m_limit_open_round[0]);
        round_data.limit_open_round.push_back(m_limit_open_round[1]);
        round_data.limit_round_reset_times = db.reset_times;
    }
}

void sc_limit_round_mgr_t::user_round_battle(int uid_, int roundid,vector<int>& partners, sp_user_t& user_)
{
    m_salt = "abcdefghijklmnop";
    random_t::rand_str(m_salt,16);
    sc_msg_def::ret_limit_round_t ret;
    ret.code = SUCCESS;
    ret.roundid = roundid;
    ret.coin = 0;
    ret.exp = 0;
    ret.lovevalue = 0;
    int round_id = int(roundid/10)%10;
    bool exist = false;
    for ( auto it = m_limit_open_round.begin();it != m_limit_open_round.end(); ++it) {
        if ((*it) == round_id)
        {
            exist = true;
            break;
        }
    }
    if (!exist) {
        logerror((LOG, "limit round not correct, roundid[%d], round_id[%d]", roundid, round_id));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    int32_t maxtimes = LIMIT_ROUND_MAX_TIMES; 
    /*
    repo_def::vip_t* vipinfo = repo_mgr.vip.get(user_->db.viplevel);
    if (vipinfo != NULL)
    {
         maxtimes = vipinfo->reset_trial; 
    }
    */
    int left_times = user_->db.limitround;
    if (maxtimes - left_times <= 0) {
        logerror((LOG, "user_round_battle, not enough time to fight"));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    auto it = m_user_data.find(uid_);
    if (it == m_user_data.end()) {
        logerror((LOG, "user_round_battle, can't find user data, id:%d", uid_));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    (it->second)->m_fight_start_time_stamp = date_helper.cur_sec();
    repo_def::limited_round_data_t* data = repo_mgr.limited_round_data.get(roundid);
    if (data->lmt_battle_drop.size() <= 0) {
        logerror((LOG, "user_round_battle, lmt_battle_drop is empty"));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    //判断体力是否足够
    if( user_->db.power<it->second->power)
    {
        logerror((LOG,"enter round,no power!"));
        ret.code = ERROR_SC_NO_POWER;
        logic.unicast(uid_, ret);
        return;
    }
    vector<vector<int>> drop = data->lmt_battle_drop;
    it->second->partners.swap(partners);
    it->second->drop_items.clear();
    uint32_t size = drop.size();
    for (uint32_t i = 1; i < size; ++i) {
        int drop_resid = drop[i][0];
        int drop_rate = drop[i][1];
        int drop_min = drop[i][2];
        int drop_max = drop[i][3];
        int pro = random_t::rand_integer(1, 10000);
        if (pro <= drop_rate) {
            if (drop_resid == 10001) {
                int drop_num = random_t::rand_integer(drop_min, drop_max);
                it->second->coin = drop_num;
                ret.coin = drop_num;
            } else {
                int drop_num = random_t::rand_integer(0, drop_max - drop_min);
                sc_msg_def::jpk_item_t drop_;
                drop_.itid = 0;
                drop_.resid = drop_resid;
                drop_.num = drop_min + drop_num;
                if ( drop_.num > 0 )
                {
                    it->second->drop_items.push_back(std::move(drop_));
                    ret.drop_items.push_back(std::move(drop_));
                }
            }
        }
    }
    ret.salt = m_salt;
    ret.exp = data->exp;
    ret.lovevalue = random_t::rand_integer(30,45); 
    it->second->exp = data->exp;
    it->second->power = data->power;
    it->second->lovevalue = ret.lovevalue;
    logic.unicast(uid_, ret);
}

void sc_limit_round_mgr_t::user_round_battle_res(int uid_, int res_, int roundid, sp_user_t& user, string salt_)
{
    sc_msg_def::ret_limit_quit_t ret;
    ret.code = SUCCESS;
    ret.roundid = roundid;
    ret.cool_down = LIMIT_ROUND_CD_TIME;

/*
    if ( salt_ != m_salt )
    {
        cout << "before salt is : " << m_salt << endl;
        cout << "after  salt is : " << salt_ << endl;

        ret.code = ERROR_SALT_FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    */
    m_salt = "qwertyuimnbvcxz;%";

    auto it = m_user_data.find(uid_);
    if (it == m_user_data.end()) {
        logerror((LOG, "user_round_battle ret, can't find user data, id:%d" , uid_));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    int off_day = date_helper.offday((it->second)->m_fight_start_time_stamp);
    if(!off_day)
    {
    int round_id = int(roundid/10)%10;
    bool exist = false;
    for (auto it = m_limit_open_round.begin(); it != m_limit_open_round.end(); ++it) {
        if ((*it) == round_id)
            exist = true;
    }
    if (!exist) {
        logerror((LOG, "limit round not correct, roundid[%d], round_id[%d]", roundid, round_id));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    }
    if (res_ == 0) {
        sc_msg_def::ret_limit_quit_t ret;
        ret.code = SUCCESS;
        ret.roundid = roundid;
        ret.cool_down = 0;
        logic.unicast(uid_, ret);
        return;
    }
    else
    {
        user->daily_task.on_event(evt_limitround_pass);
    }
    sc_msg_def::nt_bag_change_t nt;
    for (auto iti = it->second->drop_items.begin(); iti != it->second->drop_items.end(); ++iti) {
        if (iti->num > 0) {
            user->item_mgr.addnew(iti->resid, iti->num, nt);
        }
    }
    user->item_mgr.on_bag_change(nt);
    it->second->drop_items.clear();
    user->on_money_change(it->second->coin);
    user->on_exp_change(it->second->exp);
    user->on_power_change(-it->second->power);
    int32_t size = it->second->partners.size();
    for (auto iti = it->second->partners.begin(); iti != it->second->partners.end(); ++iti)
    {
        if ((*iti)== 0)
        {
            auto love_info = repo_mgr.love_task.get(user->db.resid * 100 + user->db.lovelevel + 1);
        if (love_info != NULL)
        {
            if( user->db.lovevalue + it->second->lovevalue >= love_info->love_max)
            {
                user->db.lovevalue = love_info->love_max;
                user->db.set_lovevalue( user->db.lovevalue );
            }
            else
            {
                user->db.lovevalue = user->db.lovevalue + it->second->lovevalue;
                user->db.set_lovevalue( user->db.lovevalue );
            }
        }

        }
        else
        {
            sp_partner_t partner = user->partner_mgr.get((*iti));
            if(partner == NULL)
                continue;
            partner->on_lovevalue_change(it->second->lovevalue);
            partner->save_db();
        }
    }
    int32_t maxtimes = LIMIT_ROUND_MAX_TIMES; 
    /*
    repo_def::vip_t* vipinfo = repo_mgr.vip.get(user->db.viplevel);
    if (vipinfo != NULL)
    {
         maxtimes = vipinfo->reset_trial; 
    }
    */
    if(!off_day)
    {
    if (maxtimes - user->db.limitround > 0)
        user->db.set_limitround(user->db.limitround + 1);
    it->second->m_user_last_reset_time = date_helper.cur_sec();
    ret.cool_down = LIMIT_ROUND_CD_TIME;
    }
    else
    {
        it->second->m_user_last_reset_time = date_helper.cur_sec()-LIMIT_ROUND_CD_TIME*2;
        ret.cool_down = 0;
    }
    user->save_db();
    user->reward.update_opentask(open_task_limitround_num);
    ret.code = SUCCESS;
    ret.roundid = roundid;
    logic.unicast(uid_, ret);
}

void
sc_limit_round_mgr_t::clear_fight_cd(int32_t uid_, sp_user_t user_)
{
    sc_msg_def::ret_clear_lmt_cd ret;
    if (user_->rmb() < 25)
    {
        ret.code = ERROR_SC_NO_YB;
        logic.unicast(uid_, ret);
        return;
    }
    
    auto it = m_user_data.find(uid_);
    if (it == m_user_data.end()) {
        logerror((LOG, "user_round_battle ret, can't find user data, id:%d" , uid_));
        ret.code = FAILED;
        logic.unicast(uid_, ret);
        return;
    }
    it->second->m_user_last_reset_time = date_helper.cur_sec()-LIMIT_ROUND_CD_TIME*2;
    user_->consume_yb(25);
    ret.code = SUCCESS;
    logic.unicast(uid_, ret);
    return;
}

void sc_limit_round_mgr_t::update()
{
    if (!gen_time || (gen_time && date_helper.offday(gen_time) >= 1))
        gen_limit_round();
   // cout<<"sc_limit_round->"<<date_helper.cur_0_stmp()<<endl;
   /*
    if  (date_helper.cur_sec() == LIMIT_REFRESH_H)
    {
        cout<<"limit_updata"<<endl;
        gen_limit_round();
    }
    */
}

void sc_limit_round_mgr_t::update_reset_times(int32_t uid_, int32_t viplevel_)
{
    int32_t oldtimes = 0; 
    repo_def::vip_t* vipinfo1 = repo_mgr.vip.get(viplevel_ - 1);
    if (vipinfo1 != NULL)
    {
        oldtimes = vipinfo1->reset_trial; 
    }
    
    int32_t newtimes = 0; 
    repo_def::vip_t* vipinfo = repo_mgr.vip.get(viplevel_);
    if (vipinfo != NULL)
    {
        newtimes = vipinfo->reset_trial; 
    }
    int32_t addtimes = newtimes - oldtimes;
    if(addtimes > 0)
    {
        auto it = m_user_data.find(uid_);
        if (it != m_user_data.end()) {
        
            sql_result_t res;
            db_LimitRound_t db;
            if (0 != db_LimitRound_t::sync_select_uid(uid_,res))
                return ;
            db.init(*res.get_row_at(0));
            db.reset_times = db.reset_times + addtimes;
            db_service.async_do(uint64_t(uid_),[](db_LimitRound_t& db_){
                db_.update();
            },db);
        }
    }
}
