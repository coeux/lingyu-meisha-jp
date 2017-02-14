#ifndef _sc_partner_h_
#define _sc_partner_h_

#include <unordered_map>
#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>
#include "db_ext.h"
#include "msg_def.h"

#include "sc_pro.h"
#include "sc_maxid.h"


enum quality
{
    WHITE = 1,
    GREEN,
    BLUE,
    PURPLE,
    GOLD
};

class sc_user_t;

class sc_partner_t
{
public:
    db_Partner_ext_t    db;
    sc_pro_t            pro;
public:
    sc_partner_t(sc_user_t& user_);
    int on_exp_change(int32_t exp_);
    void on_lovevalue_change(int32_t lovevalue);
    int on_quality_change();
    int get_partner_jpk(sc_msg_def::jpk_role_data_t& jpk_);
    int get_jpk_view_data(sc_msg_def::jpk_view_role_data_t& jpk_);
    int get_pro_jpk(sc_msg_def::jpk_role_pro_t& jpk_);
    int get_jpk_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t& jpk_);
    int get_jpk_rank_view_data(sc_msg_def::jpk_fight_view_role_data_t& jpk_, float num, int32_t pos_);
    void get_jpk_gbattle_fight_view_data(sc_msg_def::jpk_fight_view_role_data_t &view_, int32_t pos_);
    void up_potential(int32_t flag_);
    int32_t up_potential(int32_t flag_,int32_t &delata_,int32_t &current_, int32_t &attribute);
    void on_pro_changed();
    void gen_pro(sc_msg_def::nt_role_pro_change_t& nt_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_partner_t> sp_partner_t;

class sc_partnerchip_t
{
public:
    db_PartnerChip_ext_t    db;
public:
    void save_db();
};
typedef boost::shared_ptr<sc_partnerchip_t> sp_partnerchip_t;

//======================================================
class sc_partner_mgr_t
{
    typedef unordered_map<int32_t, sp_partner_t> partner_hm_t;
    typedef unordered_map<int32_t, sp_partnerchip_t> chip_hm_t;
    typedef unordered_map<int32_t, int32_t> resid_hm_t;
public:
    sc_partner_mgr_t(sc_user_t& user_);
    void init_new_user();
    void load_db();
    void async_load_db();
    sp_partner_t get(int32_t pid_);
    sp_partner_t getbyresid(int32_t resid_);
    sp_partner_t hire(int32_t resid_, int32_t potential_);

    int32_t fire(int32_t pid_, int32_t &resid_);
    int32_t hire_from_chip(int32_t resid_,sc_msg_def::jpk_role_data_t &ret_);
    int32_t hire_from_reward(int32_t resid_,int32_t silence_=0);
    uint32_t get_size(){ return m_partner_hm.size(); }
    int32_t get_specific_partner(int32_t resid_, sc_msg_def::jpk_role_data_t &ret_);

    int32_t has_hero(int32_t resid_);
    int32_t get_need_piece_count(int32_t resid_);
    int32_t get_now_piece_count(int32_t resid_);
    void chip_to_soul(vector<sc_msg_def::jpk_chip_t> &chips_);

    bool add_new_chip(int32_t resid_,int32_t num_,vector<sc_msg_def::jpk_chip_t> &change_);
    bool add_new_chip(int32_t resid_,int32_t num_,sc_msg_def::nt_chip_change_t &change_);
    bool consume_chip(int32_t resid_,int32_t num_,sc_msg_def::nt_chip_change_t &change_);
    sp_partnerchip_t get_chip(int32_t resid_);
    void on_chip_change(sc_msg_def::nt_chip_change_t& change_);
    void naviClick(int32_t naviId, int32_t& resid, int32_t& index);

    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_partner_hm.begin(); it!=m_partner_hm.end(); it++)
        {
            fun_(it->second);
        }
    }
    
    template<class F>
    void foreachchip(F fun_)
    {
        for(auto it=m_chip_hm.begin(); it!=m_chip_hm.end(); it++)
        {
            fun_(it->second);
        }
    }
private:
    sc_user_t&      m_user;
    partner_hm_t    m_partner_hm;
    resid_hm_t      m_resid_hm;
    chip_hm_t       m_chip_hm;
    sc_maxid_t      m_maxid;
};

#endif
