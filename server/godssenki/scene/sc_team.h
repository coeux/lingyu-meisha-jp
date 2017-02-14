#ifndef _sc_team_h_
#define _sc_team_h_

#include <stdint.h>

#include <boost/shared_ptr.hpp>

#include "db_def.h"
#include "db_ext.h"
#include "msg_def.h"
#include <unordered_map>
#include "yarray.h"

#define TEAM_SIZE 20
#define TEAM_BATTLE_SIZE 5

class sc_user_t;
class sc_team_t
{
public:
    db_Team_ext_t db;
public:
    sc_team_t(sc_user_t& user_);
    void get_team_jpk(sc_msg_def::jpk_team_t& jpk_);
    void update_team_pos(int resid);
    void save_db();
    template<class T>
    void foreach_get_view(T f_)
    {
        f_(db.p1, 1);
        f_(db.p2, 2);
        f_(db.p3, 3);
        f_(db.p4, 4);
        f_(db.p5, 5);
    }
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_team_t> sp_team_t;

/* 远征队伍 */
class sc_expedition_team_t
{
public:
    db_ExpeditionTeam_ext_t db;
    bool exist_team;
public:
    sc_expedition_team_t(sc_user_t& user_);
    void update_team_pos(int resid);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_expedition_team_t> sp_expedition_team_t;

class sc_expedition_partner_t
{
public:
    db_ExpeditionPartners_ext_t db;
public:
    sc_expedition_partner_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_expedition_partner_t> sp_expedition_partner_t;

/* 卡牌活动队伍 */
class sc_card_event_team_t 
{
public:
    db_CardEventTeam_ext_t db;
    bool exist_team;
public:
    sc_card_event_team_t(sc_user_t& user_);
    void update_team_pos(int resid);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_card_event_team_t> sp_card_event_team_t;

class sc_card_event_partner_t
{
public:
    db_CardEventUserPartner_ext_t db;
public:
    sc_card_event_partner_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_card_event_partner_t> sp_card_event_partner_t;

/* 通用队伍 */
class sc_team_mgr_t
{
typedef unordered_map<int32_t, sp_team_t> team_hm_t;
typedef unordered_map<int32_t, sp_expedition_partner_t> expedition_partners_hm_t;
typedef unordered_map<int32_t, sp_card_event_partner_t> card_event_partners_hm_t;
public:
    sc_team_mgr_t(sc_user_t& user_);
    void init_new_user();
    
    void load_db();
    void async_load_db();
private:
    sp_team_t           m_team_default;

public:
    sp_team_t& get_default() {return m_team_default;}
    sp_team_t get(int32_t tid_);
    int32_t get_pos_from_pid(int32_t pid_);

    //int size();

    //bool add_new_team(yarray_t<int32_t, TEAM_BATTLE_SIZE>& team_, int tid_);
    //void remove_team(int tid_);
    
    void change_default_team(int tid_);
    void change_team_name(int tid_, string name_);
    int32_t& operator[](const int32_t& i_); 

    void change_team(yarray_t<int32_t, TEAM_BATTLE_SIZE>& team_, int tid_);
    void on_levelup();

    /* 远征相关 */
    int32_t get_expedition_team(sc_msg_def::ret_expedition_team_t &ret);
    void change_expedition_team(sc_msg_def::nt_expedition_team_change_t &jpk_);
    sp_expedition_partner_t get_expedition_partner(int32_t pid_);
    int32_t get_expedition_partners(sc_msg_def::ret_expedition_partners_t &ret);
    int32_t update_team(const vector<sc_msg_def::jpk_expedition_partner_t>&
                        ally_team_, int32_t anger_);
    int32_t reset_expedition_partners();

    /* 卡牌活动队伍 */
    void card_event(sc_msg_def::jpk_card_event_t &ret_);
    int32_t card_event_change_team(sc_msg_def::nt_card_event_change_team_t
                                   &jpk_);
    void card_event_update_team(vector<sc_msg_def::jpk_card_event_partner_t>
                                   &ally_);
    int32_t card_event_revive(int32_t pid_);
    void card_event_reset_partner();
    void update_team_pos(int resid);

    template<class T>
    void foreach_change_pro_pid(T cb_)
    {
        cb_(m_team_default->db.p1); 
        cb_(m_team_default->db.p2); 
        cb_(m_team_default->db.p3); 
        cb_(m_team_default->db.p4); 
        cb_(m_team_default->db.p5); 
    };

    template<class F>
    void foreachteam(F fun_)
    {
        for(auto it=m_team_hm.begin(); it!=m_team_hm.end(); it++)
        {
            fun_(it->second);
        }

    };
private:
    sp_expedition_partner_t expedition_add_partner(int32_t pid_, float hp_);
    sp_card_event_partner_t card_event_add_partner(int32_t pid_, float hp_);
    void card_event_get_ally_team(sc_msg_def::jpk_card_event_t &jpk_);
    void card_event_get_partners(sc_msg_def::jpk_card_event_t &ret_);
private:
    sc_user_t&               m_user;
    team_hm_t                m_team_hm;
    sp_expedition_team_t     m_expedition_team;
    expedition_partners_hm_t m_expedition_partners;
    sp_card_event_team_t     m_card_event_team;
    card_event_partners_hm_t m_card_event_partners;
};

#endif
