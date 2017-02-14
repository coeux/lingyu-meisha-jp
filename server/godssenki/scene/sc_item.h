#ifndef _item_h_
#define _item_h_

#include <unordered_map>
#include <map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;

class sc_item_t
{
public:
    db_Item_ext_t db;
public:
    sc_item_t(sc_user_t& user_);
    void get_item_jpk(sc_msg_def::jpk_item_t& jpk_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_item_t> sp_item_t;
//======================================================
class sc_item_mgr_t
{
    //[resid][sp_item_t]
    typedef unordered_map<int32_t, sp_item_t> item_hm_t;
public:
    sc_item_mgr_t(sc_user_t& user_);

    void init_new_user(); 

    void load_db();
    void async_load_db();
    void on_bag_change(sc_msg_def::nt_bag_change_t& change_);

    sp_item_t get(int32_t resid_);
    int32_t getdbid(int32_t resid_);
    void put(sc_msg_def::nt_bag_change_t& change_);
    bool has_items(int32_t resid_, int32_t num_);
    int32_t get_items_count(int32_t resid_);
    bool consume(int32_t resid_, int32_t num_, sc_msg_def::nt_bag_change_t& change_);
    bool consume_all(int32_t resid_, sc_msg_def::nt_bag_change_t& change_);
    bool addnew(int32_t resid_, int32_t num_, sc_msg_def::nt_bag_change_t& change_);
    int32_t size();
    void sell_item(int32_t resid_);

    //safe:安全合成，0不使用，1使用，2保护石头不够则自动购买
    int gemstone_compose(int32_t src_, int32_t compose_num_, int32_t safe_);
    int gemstone_compose_all(int32_t compose_type);
    //图纸合成
    int drawing_compose(int resid_, const vector<int>& src_);

    template<class F>
    void foreach(F fun_)
    {
        for(auto it=m_item_hm.begin(); it!=m_item_hm.end(); it++)
        {
            fun_(it->second);
        }
    }

    int use_item(int resid_, int num_, const string& param_);
    int open_pack_item(int resid_, int num_);
private:
    int open_box_item(int resid_, int num_);
    int use_drug_item(int resid_, int num_, const string& param_);
    int rename(int resid_, int num_, const string& name_);
    void gen_pack_item(vector<sc_msg_def::jpk_item_t>& drops_, vector<int>& items_, int prob_, int count_);
private:
    sc_user_t&                      m_user;
    item_hm_t                       m_item_hm;
    sc_maxid_t                      m_maxid;
};

#endif
