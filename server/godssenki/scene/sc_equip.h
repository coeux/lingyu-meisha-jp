#ifndef _sc_equip_h_
#define _sc_equip_h_

#include <unordered_map>
#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;
class sc_equip_t
{
public:
    db_Equip_ext_t db;
public:
    sc_equip_t(sc_user_t& user_);
    //当前的等级
    int32_t level();
    //装备升级
    int32_t upgrade(int num_);
    //目标装备resid
    int32_t compose(int32_t dst_resid_);
    int32_t compose_by_yb(int32_t dst_resid_);
    //槽id
    int32_t open_slot(int32_t slotid_);
    //宝石的id， 槽id
    int32_t inlay(int32_t resid_, int32_t slotid_);
    //拆下宝石
    int32_t unlay(int32_t flag_, int32_t slotid_);
    //得到装备的jpk包 
    void get_equip_jpk(sc_msg_def::jpk_equip_t& equip_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_equip_t> sp_equip_t;
//======================================================
class sc_equip_mgr_t
{
    typedef unordered_map<int32_t, sp_equip_t> equip_hm_t;
    typedef unordered_map<int32_t, sp_equip_t> equip_slot_t;
    typedef unordered_map<int32_t, equip_slot_t> role_equip_slot_t;
public:
    sc_equip_mgr_t(sc_user_t& user_);

    void init_new_user(); 

    void load_db();
    void async_load_db();

    sp_equip_t get(int32_t eid_);
    sp_equip_t get_part(int32_t pid_, int32_t part_);
    int32_t bag_size();
    void unlay_all(); //卸下所有装备宝石 新功能用

    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_equip_hm.begin(); it!=m_equip_hm.end(); it++)
        {
            fun_(it->second);
        }
    }

    int wear_equip(int32_t pid_, int32_t eid_, int slot_pos_);
    int get_quality_by_equip(int32_t uid);
    int takeoff_equip(int32_t pid_, int32_t eid_,  int slot_pos_);
    void takeoff_all_equip(int32_t pid_, sc_msg_def::nt_bag_change_t& ret_);
    void fire_all_equip(int32_t pid_, sc_msg_def::nt_bag_change_t& ret_);

    void init_new_partner(int32_t pid_, int32_t resid_);
    void sell_equip(int32_t eid_);
    //从商城买装备
    void addnew(int32_t resid_,int32_t num_,sc_msg_def::nt_bag_change_t& change_);
private:
    int add_part(sp_equip_t equip_, int32_t part);
    int del_part(sp_equip_t equip_);
    bool is_white_equip(sp_equip_t equip_);
private:
    sc_user_t&          m_user;
    equip_hm_t          m_equip_hm;
    equip_slot_t        m_user_equip_slot;
    role_equip_slot_t   m_partner_equip_slot;
    sc_maxid_t          m_maxid;
    unordered_map<int32_t, db_Equip_t> db_equip;
};

#endif
