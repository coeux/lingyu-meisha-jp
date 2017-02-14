#include "sc_team.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_guidence.h"
#include "db_def.h"
#include "repo_def.h"
#include "sc_fp_rank.h"
#include "code_def.h"

#define LOG "SC_TEAM"

sc_team_t::sc_team_t(sc_user_t& user_):m_user(user_)
{    
}

void sc_team_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}
void sc_team_t::get_team_jpk(sc_msg_def::jpk_team_t& jpk_)
{
    jpk_.tid = db.tid;
    jpk_.name = db.name();
    jpk_.pid1 = db.p1;
    jpk_.pid2 = db.p2;
    jpk_.pid3 = db.p3;
    jpk_.pid4 = db.p4;
    jpk_.pid5 = db.p5;
    jpk_.is_default = db.is_default;
}
void sc_team_t::update_team_pos(int resid)
{
    bool isInsert = false;
    auto userinfo = repo_mgr.role.get(resid);
    int oldteam[5] = {db.p1,db.p2,db.p3,db.p4,db.p5};
    int updateteam[5] ={-1,-1,-1,-1,-1};
    int i = 0;
    for(int index = 0; index <= 4; index++)
    {
        if(oldteam[index]== -1)
        {
            updateteam[i] = -1;
            i++;
        }
        else if (oldteam[index] == 0)
        {
            continue;
        }
        else if (!isInsert)
        {
            sp_partner_t p=m_user.partner_mgr.get(oldteam[index]);
            auto partnerinfo = repo_mgr.role.get(p->db.resid);
            if( userinfo->hit_area > partnerinfo->hit_area)
            {
                updateteam[i] = 0;
                i++;
                updateteam[i] = oldteam[index];
                i++;
                isInsert = true;
            }
            else
            {
                updateteam[i] = oldteam[index];
                i++;
            }
        }
        else
        {
            updateteam[i] = oldteam[index];
            i++;
        }
    }
    if(!isInsert)
    {
        int j= 0;
        for(int index = 0; index <= 4; index++)
        {
            if(oldteam[index] != 0)
            {
                updateteam[j] = oldteam[index];
                j++;
            }
        }
        updateteam[4]= 0;
    }
    db.p1 = updateteam[0];
    db.p2 = updateteam[1];
    db.p3 = updateteam[2];
    db.p4 = updateteam[3];
    db.p5 = updateteam[4];
    db.set_p1(updateteam[0]);
    db.set_p2(updateteam[1]);
    db.set_p3(updateteam[2]);
    db.set_p4(updateteam[3]);
    db.set_p5(updateteam[4]);
    save_db();
}
/* 远征队伍 */
sc_expedition_team_t::sc_expedition_team_t(sc_user_t& user_):m_user(user_)
{
    exist_team = false;
}

void sc_expedition_team_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void sc_expedition_team_t::update_team_pos(int resid)
{
    bool isInsert = false;
    auto userinfo = repo_mgr.role.get(resid);
    int oldteam[5] = {db.pid1,db.pid2,db.pid3,db.pid4,db.pid5};
    int updateteam[5] ={-1,-1,-1,-1,-1};
    int i = 0;
    for(int index = 0; index <= 4; index++)
    {
        if(oldteam[index]== -1)
        {
            updateteam[i] = -1;
            i++;
        }
        else if (oldteam[index] == 0)
        {
            continue;
        }
        else if (!isInsert)
        {
            sp_partner_t p=m_user.partner_mgr.get(oldteam[index]);
            auto partnerinfo = repo_mgr.role.get(p->db.resid);
            if( userinfo->hit_area > partnerinfo->hit_area)
            {
                updateteam[i] = 0;
                i++;
                updateteam[i] = oldteam[index];
                i++;
                isInsert = true;
            }
            else
            {
                updateteam[i] = oldteam[index];
                i++;
            }
        }
        else
        {
            updateteam[i] = oldteam[index];
            i++;
        }
    }
    if(!isInsert)
    {
        int j= 0;
        for(int index = 0; index <= 4; index++)
        {
            if(oldteam[index] != 0)
            {
                updateteam[j] = oldteam[index];
                j++;
            }
        }
        updateteam[4]= 0;
    }
    db.pid1 = updateteam[0];
    db.pid2 = updateteam[1];
    db.pid3 = updateteam[2];
    db.pid4 = updateteam[3];
    db.pid5 = updateteam[4];
    db.set_pid1(updateteam[0]);
    db.set_pid2(updateteam[1]);
    db.set_pid3(updateteam[2]);
    db.set_pid4(updateteam[3]);
    db.set_pid5(updateteam[4]);
    save_db();
}
sc_expedition_partner_t::sc_expedition_partner_t(sc_user_t& user_):m_user(user_)
{
}

void sc_expedition_partner_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

/* 卡牌活动队伍 begin */
sc_card_event_team_t::sc_card_event_team_t(sc_user_t& user_):m_user(user_)
{
    exist_team = false;
}

void
sc_card_event_team_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}

void sc_card_event_team_t::update_team_pos(int resid)
{ 
    bool isInsert = false;
    auto userinfo = repo_mgr.role.get(resid);
    int oldteam[5] = {db.pid1,db.pid2,db.pid3,db.pid4,db.pid5};
    int updateteam[5] ={-1,-1,-1,-1,-1};
    int i = 0;
    for(int index = 0; index <= 4; index++)
    {
        if(oldteam[index]== -1)
        {
            updateteam[i] = -1;
            i++;
        }
        else if (oldteam[index] == 0)
        {
            continue;
        }
        else if (!isInsert)
        {
            sp_partner_t p=m_user.partner_mgr.get(oldteam[index]);
            auto partnerinfo = repo_mgr.role.get(p->db.resid);
            if( userinfo->hit_area > partnerinfo->hit_area)
            {
                updateteam[i] = 0;
                i++;
                updateteam[i] = oldteam[index];
                i++;
                isInsert = true;
            }
            else
            {
                updateteam[i] = oldteam[index];
                i++;
            }
        }
        else
        {
            updateteam[i] = oldteam[index];
            i++;
        }
    }
    if(!isInsert)
    {
        int j= 0;
        for(int index = 0; index <= 4; index++)
        {
            if(oldteam[index] != 0)
            {
                updateteam[j] = oldteam[index];
                j++;
            }
        }
        updateteam[4]= 0;
    }
    db.pid1 = updateteam[0];
    db.pid2 = updateteam[1];
    db.pid3 = updateteam[2];
    db.pid4 = updateteam[3];
    db.pid5 = updateteam[4];
    db.set_pid1(updateteam[0]);
    db.set_pid2(updateteam[1]);
    db.set_pid3(updateteam[2]);
    db.set_pid4(updateteam[3]);
    db.set_pid5(updateteam[4]);
    save_db();}
sc_card_event_partner_t::sc_card_event_partner_t(sc_user_t& user_):
m_user(user_)
{
}

void 
sc_card_event_partner_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}

//=========================================================================
sc_team_mgr_t::sc_team_mgr_t(sc_user_t& sc_user):m_user(sc_user)
{
}

void sc_team_mgr_t::init_new_user()
{
    boost::shared_ptr<sc_card_event_team_t> 
        sp_card_event_team(new sc_card_event_team_t(m_user));
    m_card_event_team = sp_card_event_team;
    //0-主角
    //>0伙伴pid
    //-1开启但未使用
    //-2未开启 (现在没有未开启)
    string default_name[5];
    default_name[0] = "チームA";
    default_name[1] = "チームB";
    default_name[2] = "チームC";
    default_name[3] = "チームD";
    default_name[4] = "チームE";
    for (int i=1;i<=5;i++)
    {
        boost::shared_ptr<sc_team_t> sp_team(new sc_team_t(m_user));
        db_Team_t& team_db = sp_team->db;
        team_db.uid = m_user.db.uid;
        team_db.tid = i;
        team_db.name = default_name[i-1];
        team_db.is_default = (i==1)? 1 : 0;
        team_db.p1 = -1;
        team_db.p2 = -1;
        team_db.p3 = -1;
        team_db.p4 = -1;
        team_db.p5 = 0;

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Team_t& db_){
            db_.insert();
        }, team_db);
        m_team_hm.insert(make_pair(sp_team->db.tid, sp_team));
        if( i==1 )
        {
            m_team_default = sp_team;
        }
    }
    logwarn((LOG, "load team finish"));
}

void sc_team_mgr_t::load_db()
{
    sql_result_t res;

    if (0==db_Team_t::sync_select_team_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_team_t> sp_team(new sc_team_t(m_user));
            sp_team->db.init(*res.get_row_at(i));
            m_team_hm.insert(make_pair(sp_team->db.tid, sp_team));
            if (sp_team->db.is_default == 1)
                m_team_default = sp_team;
        }
    }

    /* 远征队伍及伙伴 */
    sql_result_t res2;
    boost::shared_ptr<sc_expedition_team_t> sp_expedition_team(
        new sc_expedition_team_t(m_user));
    if (0 == db_ExpeditionTeam_t::sync_select_uid(m_user.db.uid, res2)) {
        sp_expedition_team->db.init(*res2.get_row_at(0));
        sp_expedition_team->exist_team = true;
    }
    m_expedition_team = sp_expedition_team;

    sql_result_t res3;
    if (0 == db_ExpeditionPartners_t::sync_select_uid(m_user.db.uid, res3)) {
        for (size_t i = 0; i < res3.affect_row_num(); ++i) {
            boost::shared_ptr<sc_expedition_partner_t> sp_expedition_partner(
                new sc_expedition_partner_t(m_user));
            sp_expedition_partner->db.init(*res3.get_row_at(i));
            m_expedition_partners.insert(
                make_pair(sp_expedition_partner->db.pid, sp_expedition_partner)
            );
        }
    }

    /* 卡牌活动队伍 */
    sql_result_t res4;
    boost::shared_ptr<sc_card_event_team_t> sp_card_event_team(
        new sc_card_event_team_t(m_user));
    if (0 == db_CardEventTeam_t::sync_select_uid(m_user.db.uid, res4)) {
        sp_card_event_team->db.init(*res4.get_row_at(0));
        sp_card_event_team->exist_team = true;
    }
    m_card_event_team = sp_card_event_team;

    sql_result_t res5;
    if (0 == db_CardEventUserPartner_t::sync_select_uid(m_user.db.uid, res5)) {
        for (size_t i = 0; i < res5.affect_row_num(); ++i) {
            boost::shared_ptr<sc_card_event_partner_t> sp_card_event_partner(
                new sc_card_event_partner_t(m_user));
            sp_card_event_partner->db.init(*res5.get_row_at(i));
            m_card_event_partners.insert(
                make_pair(sp_card_event_partner->db.pid, sp_card_event_partner)
            );
        }
    }
}

void sc_team_mgr_t::async_load_db()
{
    sql_result_t res;

    if (0==db_Team_t::select_team_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_team_t> sp_team(new sc_team_t(m_user));
            sp_team->db.init(*res.get_row_at(i));
            m_team_hm.insert(make_pair(sp_team->db.tid, sp_team));
            if (sp_team->db.is_default == 1)
                m_team_default = sp_team;
        }
    }

    /* 远征队伍 */
    sql_result_t res2;
    boost::shared_ptr<sc_expedition_team_t> sp_expedition_team(
        new sc_expedition_team_t(m_user));
    if (0 == db_ExpeditionTeam_t::select_uid(m_user.db.uid, res2)) {
        sp_expedition_team->db.init(*res2.get_row_at(0));
        sp_expedition_team->exist_team = true;
    }
    m_expedition_team = sp_expedition_team;

    sql_result_t res3;
    if (0 == db_ExpeditionPartners_t::select_uid(m_user.db.uid, res3)) {
        for (size_t i = 0; i < res3.affect_row_num(); ++i) {
            boost::shared_ptr<sc_expedition_partner_t> sp_expedition_partner(
                new sc_expedition_partner_t(m_user));
            sp_expedition_partner->db.init(*res3.get_row_at(i));
            m_expedition_partners.insert(
                make_pair(sp_expedition_partner->db.pid, sp_expedition_partner));
        }
    }

    /* 活动队伍 */
    sql_result_t res4;
    boost::shared_ptr<sc_card_event_team_t> sp_card_event_team(
        new sc_card_event_team_t(m_user));
    if (0 == db_CardEventTeam_t::select_uid(m_user.db.uid, res4)) {
        sp_card_event_team->db.init(*res4.get_row_at(0));
        sp_card_event_team->exist_team = true;
    }
    m_card_event_team = sp_card_event_team;

    sql_result_t res5;
    if (0 == db_CardEventUserPartner_t::select_uid(m_user.db.uid, res5)) {
        for (size_t i = 0; i < res5.affect_row_num(); ++i) {
            boost::shared_ptr<sc_card_event_partner_t> sp_card_event_partner(
                new sc_card_event_partner_t(m_user));
            sp_card_event_partner->db.init(*res5.get_row_at(i));
            m_card_event_partners.insert(
                make_pair(sp_card_event_partner->db.pid, sp_card_event_partner)
            );
        }
    }
}

sp_team_t sc_team_mgr_t::get(int tid_)

{
    auto it = m_team_hm.find(tid_);
    if (it != m_team_hm.end())
        return it->second;
    return sp_team_t();
}
/*
bool sc_team_mgr_t::add_new_team(yarray_t<int32_t, TEAM_BATTLE_SIZE>& team_, int tid_)
{
    //校验队伍pid数据
    for(int i=0; i<TEAM_BATTLE_SIZE; i++)
    {
        if (team_[i] < 0)
            team_[i] = -1;

        if (team_[i] > 0)
        {
            auto partner = m_user.partner_mgr.get(team_[i]);
            if (partner == NULL)
                team_[i] = -1;
        }
    }

    boost::shared_ptr<sc_team_t> sp_team(new sc_team_t(m_user));
    db_Team_t& db = sp_team->db;
    memset( &db, 0, sizeof(db) );
    
    db.uid = m_user.db.uid;
    db.tid = tid_;
    db.name = " ";
    db.p1 = team_[0];
    db.p2 = team_[1];
    db.p3 = team_[2];
    db.p4 = team_[3];
    db.p5 = team_[4];
    db.is_default = 0;
    
    m_team_hm.insert(make_pair(sp_team->db.tid, sp_team));

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Team_t& db_){
        db_.insert();
    }, db);

    return true;
}

void sc_team_mgr_t::remove_team(int tid_)
{
    sp_team_t sp_team = get(tid_);
    if (sp_team == NULL)
        return;
    
    m_team_hm.erase(tid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Team_t& db_){
        db_.remove();
    }, sp_team->db.data());
}
*/
void sc_team_mgr_t::change_default_team(int tid_)
{
    sp_team_t sp_team = get(tid_);
    if (sp_team == NULL)
    {
        return ;
    }
    
    db_Team_ext_t& db = sp_team->db;
    db.set_is_default(1);
    sp_team->save_db();

    db_Team_ext_t& db2 = m_team_default->db;
    db2.set_is_default(0);
    m_team_default->save_db();

    m_team_default = sp_team;
    
    //战斗力改变
    m_user.on_team_pro_changed();
}

void sc_team_mgr_t::change_team_name(int tid_, string name_)
{
    sp_team_t sp_team = get(tid_);
    if (sp_team == NULL)
    {
        return;
    }
    db_Team_ext_t& db = sp_team->db;
    db.set_name(name_);
    sp_team->save_db();    
    //战斗力改变
    m_user.on_team_pro_changed();
}

void sc_team_mgr_t::change_team(yarray_t<int32_t, TEAM_BATTLE_SIZE>& team_, int tid_)
{
    sp_team_t sp_team = get(tid_);
    /*
    if (sp_team == NULL)
    {
        this->add_new_team(team_, tid_);
        return;
    }
    */

    for(int i=0; i<TEAM_BATTLE_SIZE; i++)
    {
        if (team_[i] < -1)
            team_[i] = -1;

        if (team_[i] > 0)
        {
            auto partner = m_user.partner_mgr.get(team_[i]);
            if (partner == NULL)
                team_[i] = -1;
        }

        //这里是等级限制判断 先去掉
        /*
        if (team_[i] >= 0)
        {
            repo_def::team_t* rp_team = repo_mgr.team.get(i+1);
            if (rp_team == NULL)
                team_[i] = -1;
            if (rp_team != NULL && rp_team->level > m_user.db.grade)
                team_[i] = -1;
        }
        */
    }
    //防止主角位置丢失
    bool is_lost = true;
    for(int i=0; i<=4; i++)
    {
        if (team_[i] == 0)
            is_lost = false;
    }
    if (is_lost)
        team_[4] = 0;

    db_Team_ext_t& db = sp_team->db;
    db.set_p1(team_[0]);
    db.set_p2(team_[1]);
    db.set_p3(team_[2]);
    db.set_p4(team_[3]);
    db.set_p5(team_[4]);

    sp_team->save_db();

    //设置新手引导步骤
    /*
    if ( ( (m_user.db.isnew) & ( 1<< evt_guidence_team )) == 0 )
        guidence_ins.on_guidence_event(m_user,evt_guidence_team);
    else if( ( (m_user.db.isnew) & ( 1<< evt_guidence_team2) ) == 0 )
        guidence_ins.on_guidence_event(m_user,evt_guidence_team2);
    */
    //战斗力改变
    m_user.on_team_pro_changed();
}

int32_t& sc_team_mgr_t::operator[](const int32_t& i_)
{
    //TODO, FATAL ERROR!
    if(!m_team_default)
        init_new_user();

    switch(i_)
    {
    case 0:
        return m_team_default->db.p1;
    case 1:
        return m_team_default->db.p2;
    case 2:
        return m_team_default->db.p3;
    case 3:
        return m_team_default->db.p4;
    case 4:
        return m_team_default->db.p5;
    }
}

/*
int sc_team_mgr_t::size()
{
    int n=0;
    for(int i=0; i<TEAM_BATTLE_SIZE; i++)
    {
        if ((*this)[i] == -1)
            continue;
        n++;
    }
    return n;
}
*/

int32_t sc_team_mgr_t::get_expedition_team(sc_msg_def::ret_expedition_team_t &ret)
{
    load_db();
    if (!m_expedition_team->exist_team)
        return ERROR_NO_EXPEDITION_TEAM;
    ret.anger = m_expedition_team->db.anger;

    auto fill_jpk = [&](int32_t pid){
        if (pid < 0) return true;
        sc_msg_def::jpk_expedition_team_t jpk_;
        auto it = m_expedition_partners.find(pid);
        if (it == m_expedition_partners.end())
            return false;
        jpk_.pid = it->second->db.pid;
        jpk_.hp = it->second->db.hp;
        ret.team.push_back(std::move(jpk_));
        return true;
    };

    if (!(fill_jpk(m_expedition_team->db.pid1) &&
          fill_jpk(m_expedition_team->db.pid2) &&
          fill_jpk(m_expedition_team->db.pid3) &&
          fill_jpk(m_expedition_team->db.pid4) &&
          fill_jpk(m_expedition_team->db.pid5)))
        return ERROR_NO_EXPEDITION_PARTNER;
    return SUCCESS;
}
void sc_team_mgr_t::change_expedition_team(sc_msg_def::nt_expedition_team_change_t &jpk_)
{
    auto update_partner = [&](int32_t pid, float hp) {
        if (pid < 0) return;
        auto it = m_expedition_partners.find(pid);
        if (it == m_expedition_partners.end())
        {
            sp_expedition_partner_t sp_ep_ = expedition_add_partner(pid, hp);
            if (sp_ep_ != NULL) m_expedition_partners.insert(make_pair(pid, sp_ep_));
        }
        else
        {
            it->second->db.set_hp(hp);
            it->second->save_db();
        }
    };

    m_expedition_team->db.uid = m_user.db.uid;
    m_expedition_team->db.set_pid1(jpk_.team[0].pid);
    m_expedition_team->db.set_pid2(jpk_.team[1].pid);
    m_expedition_team->db.set_pid3(jpk_.team[2].pid);
    m_expedition_team->db.set_pid4(jpk_.team[3].pid);
    m_expedition_team->db.set_pid5(jpk_.team[4].pid);
    m_expedition_team->db.set_anger(jpk_.anger);
    if (!m_expedition_team->exist_team)
    {
        db_service.async_do((uint64_t)m_user.db.uid, [](db_ExpeditionTeam_t& db_){
            db_.insert();
        }, m_expedition_team->db.data());
        m_expedition_team->exist_team = true;
    }
    else m_expedition_team->save_db();
    update_partner(jpk_.team[0].pid, jpk_.team[0].hp);
    update_partner(jpk_.team[1].pid, jpk_.team[1].hp);
    update_partner(jpk_.team[2].pid, jpk_.team[2].hp);
    update_partner(jpk_.team[3].pid, jpk_.team[3].hp);
    update_partner(jpk_.team[4].pid, jpk_.team[4].hp);
}
sp_expedition_partner_t sc_team_mgr_t::expedition_add_partner(int32_t pid_, float hp_)
{
    sp_expedition_partner_t sp_expedition_partner_(new sc_expedition_partner_t(m_user));
    sp_expedition_partner_->db.uid = m_user.db.uid;
    sp_expedition_partner_->db.pid = pid_;
    sp_expedition_partner_->db.hp = hp_;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_ExpeditionPartners_t& db_){
        db_.insert();
    }, sp_expedition_partner_->db.data());
    return sp_expedition_partner_;
}
sp_expedition_partner_t sc_team_mgr_t::get_expedition_partner(int32_t pid_)
{
    auto it = m_expedition_partners.find(pid_);
    if (it != m_expedition_partners.end())
        return it->second;
    return NULL;
}
int32_t sc_team_mgr_t::get_expedition_partners(sc_msg_def::ret_expedition_partners_t &ret)
{
    for (auto it = m_expedition_partners.begin(); it != m_expedition_partners.end(); ++it)
    {
        sc_msg_def::jpk_expedition_partner_t jpk_;
        jpk_.pid = it->second->db.pid;
        jpk_.hp = it->second->db.hp;
        ret.partners.push_back(std::move(jpk_));
    }
    return SUCCESS;
}
int32_t sc_team_mgr_t::update_team(const vector<sc_msg_def::jpk_expedition_partner_t> &ally_team_, int32_t anger_)
{
    for (auto actor : ally_team_)
    {
        if (actor.pid < 0) continue;
        auto it = m_expedition_partners.find(actor.pid);
        if (it != m_expedition_partners.end())
        {
            it->second->db.set_hp(actor.hp);
            it->second->save_db();
        }
        else return FAILED;
    }
    if (m_expedition_team->exist_team)
    {
        m_expedition_team->db.set_anger(anger_);
        m_expedition_team->save_db();
    }
    else return FAILED;

    return SUCCESS;
}
int32_t sc_team_mgr_t::reset_expedition_partners()
{
    //for (auto it : m_expedition_partners) {
    for (auto it = m_expedition_partners.begin(); it != m_expedition_partners.end(); ++it){
        if (it->second->db.pid < 0) continue;
        it->second->db.set_hp(1.0);
        it->second->save_db();
    }
    return SUCCESS;
}

/* 卡牌活动队伍 begin */
void
sc_team_mgr_t::card_event_get_ally_team(sc_msg_def::jpk_card_event_t &jpk_)
{
    if (!m_card_event_team->exist_team) {
        return;
    }
    jpk_.team.anger = m_card_event_team->db.anger;

    auto fill_jpk = [&](int32_t pid) {
        if (pid < 0) {
            return true;
        }
        sc_msg_def::jpk_card_event_partner_t jpk;
        auto it = m_card_event_partners.find(pid);
        if (it == m_card_event_partners.end()) {
            return false;
        }
        jpk.pid = it->second->db.pid;
        jpk.hp = it->second->db.hp;
        jpk_.team.actors.push_back(std::move(jpk));
    };
    fill_jpk(m_card_event_team->db.pid1);
    fill_jpk(m_card_event_team->db.pid2);
    fill_jpk(m_card_event_team->db.pid3);
    fill_jpk(m_card_event_team->db.pid4);
    fill_jpk(m_card_event_team->db.pid5);
}

void
sc_team_mgr_t::card_event_get_partners(sc_msg_def::jpk_card_event_t &jpk_)
{
    for (auto it = m_card_event_partners.begin();
         it != m_card_event_partners.end(); ++it) {
        sc_msg_def::jpk_card_event_partner_t jpk;
        jpk.pid = it->second->db.pid;
        jpk.hp = it->second->db.hp;
        jpk_.partners.push_back(std::move(jpk));
    }
}

void
sc_team_mgr_t::card_event(sc_msg_def::jpk_card_event_t &ret_)
{
    card_event_get_ally_team(ret_);
    card_event_get_partners(ret_);
}

int32_t
sc_team_mgr_t::card_event_change_team(sc_msg_def::nt_card_event_change_team_t&
                                      jpk_)
{
    auto update_partner = [&](int32_t pid, float hp) {
        if (pid < 0) return;
        auto it = m_card_event_partners.find(pid);
        if (it == m_card_event_partners.end()) {
            auto sp_card_event_partner = card_event_add_partner(pid, hp);
            if (sp_card_event_partner != NULL) {
                m_card_event_partners.insert(
                    make_pair(pid, sp_card_event_partner)
                );
            }
        } else {
            it->second->db.set_hp(hp);
            it->second->save_db();
        }
    };
    for (size_t i = 0; i < 5; ++i) {
        update_partner(jpk_.team[i].pid, jpk_.team[i].hp);
    }
    m_card_event_team->db.uid = m_user.db.uid;
    m_card_event_team->db.set_pid1(jpk_.team[0].pid);
    m_card_event_team->db.set_pid2(jpk_.team[1].pid);
    m_card_event_team->db.set_pid3(jpk_.team[2].pid);
    m_card_event_team->db.set_pid4(jpk_.team[3].pid);
    m_card_event_team->db.set_pid5(jpk_.team[4].pid);
    m_card_event_team->db.set_anger(jpk_.anger);
    if (!m_card_event_team->exist_team) {
        db_service.async_do((uint64_t)m_user.db.uid, 
            [](db_CardEventTeam_t &db_) { db_.insert(); }, 
            m_card_event_team->db.data()
        );
        m_card_event_team->exist_team = true;
    } else {
        m_card_event_team->save_db();
    }
    return SUCCESS;
}

int32_t
sc_team_mgr_t::card_event_revive(int32_t pid_)
{
    auto it = m_card_event_partners.find(pid_);
    if (it == m_card_event_partners.end()) {
        return FAILED;
    }
    it->second->db.set_hp(1.0);
    it->second->save_db();
    return SUCCESS;
}

void
sc_team_mgr_t::card_event_reset_partner()
{
    for (auto it = m_card_event_partners.begin();
         it != m_card_event_partners.end(); ++it) {
        it->second->db.set_hp(1.0);
        it->second->save_db();
    }
}

void
sc_team_mgr_t::card_event_update_team(
                vector<sc_msg_def::jpk_card_event_partner_t>& ally_)
{
    for (auto actor : ally_) {
        if (actor.pid < 0) {
            continue;
        }
        auto it = m_card_event_partners.find(actor.pid);
        if (it != m_card_event_partners.end()) {
            it->second->db.set_hp(actor.hp);
            it->second->save_db();
        }
    }
}

sp_card_event_partner_t
sc_team_mgr_t::card_event_add_partner(int32_t pid_, float hp_)
{
    sp_card_event_partner_t sp_card_event_partner(
        new sc_card_event_partner_t(m_user));
    sp_card_event_partner->db.uid = m_user.db.uid;
    sp_card_event_partner->db.pid = pid_;
    sp_card_event_partner->db.hp = hp_;
    db_service.async_do(
        (uint64_t)m_user.db.uid, 
        [](db_CardEventUserPartner_t& db_) { db_.insert(); },
        sp_card_event_partner->db.data()
    );
    return sp_card_event_partner;
}
/* 卡牌活动队伍 end */

int32_t
sc_team_mgr_t::get_pos_from_pid(int32_t pid_)
{
    if (m_team_default->db.p1 == pid_)
        return 1;
    if (m_team_default->db.p2 == pid_)
        return 2;
    if (m_team_default->db.p3 == pid_)
        return 3;
    if (m_team_default->db.p4 == pid_)
        return 4;
    if (m_team_default->db.p5 == pid_)
        return 5;

    return 0;
}

void sc_team_mgr_t::update_team_pos(int resid)
{
    for(auto it=m_team_hm.begin(); it!=m_team_hm.end(); it++)
    {
        auto teaminfo = it->second;
        teaminfo->update_team_pos(resid);
    }
    if (m_expedition_team->exist_team)
        m_expedition_team->update_team_pos(resid); 
    if (m_card_event_team->exist_team)
        m_card_event_team->update_team_pos(resid);
}
