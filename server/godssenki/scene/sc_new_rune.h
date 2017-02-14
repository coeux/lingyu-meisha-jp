#ifndef _sc_new_rune_h_
#define _sc_new_rune_h_

#include <map>
#include <set>
#include <vector>
#include <list>

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

using namespace std;

class sc_user_t;
class sc_rune_page_t
{
public:
    db_RuneInfo_ext_t db_info;
public:
    sc_rune_page_t(sc_user_t &user_);
    void load_db();
    void save_db_info();
    void init_new_user_page();
    void init_new_user_info();
    void enter_hunt(sc_msg_def::req_enter_rune_hunt_t& jpk_);
    void hunt(int32_t use_item_);
    void inform_leave();
    int32_t active_new_partner(int32_t pid_, sc_msg_def::ret_new_rune_active_t& ret_);
    void get_rune_list(vector<sc_msg_def::jpk_new_rune_t>& list_);
    void get_rune_page(map<int32_t, sc_msg_def::jpk_rune_page_t>& map_);
    int32_t inlay_rune(int32_t rune_id_, int32_t pid_, int32_t pos_, sc_msg_def::ret_new_rune_inlay_t& ret_);
    int32_t unlay_rune(int32_t pid_, int32_t pos_, sc_msg_def::ret_new_rune_unlay_t& ret_);
    int32_t levelup(int32_t rune_id_, vector<int32_t>& mat_list, sc_msg_def::ret_new_rune_levelup_t& ret_);
    int32_t compose(int32_t rune_id_, vector<int32_t>& mat_list, sc_msg_def::ret_new_rune_compose_t& ret_);
    void remove_rune(int32_t rune_id_, vector<int32_t>& del_list_);
    float get_attribute(int32_t attribute_, int32_t pid_);
    void add_new_rune(int32_t resid_, int32_t num_);
private:
    void check_rune_inlay_pro_changed(int32_t rune_id_);
private:
    sc_user_t &m_user;
    int32_t hunt_level;
    int32_t max_id;
    unordered_map<int32_t, unordered_map<int32_t, int32_t>> rune_page_map;
    unordered_map<int32_t, db_RuneItem_t> rune_map;
};

struct rune_message
{
    string name;
    int32_t resid;
};

class sc_rune_message_t
{
public:
    sc_rune_message_t();
    void load_db(vector<int32_t>& hostnums_);
    void push_message(string name_, int32_t resid_, int32_t uid_);
    void get_latest_20(vector<sc_msg_def::hunt_news>& news_);
    void add_user(int32_t uid_);
    void del_user(int32_t uid_);
private:
    vector<rune_message> message_vector;
    unordered_map<int32_t, int32_t> user_map;
    vector<int32_t> hosts;
};

class sc_rune_function_t
{
public:
    sc_rune_function_t();
    void load_db();
public:
    unordered_map<int32_t, unordered_map<int32_t, int32_t>>* get_prob_info();
private:
    void load_rune_info();
private:
    unordered_map<int32_t, unordered_map<int32_t, int32_t>> rune_prob_info;
    bool is_load;
};


#define rune_message_s (singleton_t<sc_rune_message_t>::instance())
#define rune_function (singleton_t<sc_rune_function_t>::instance())
#endif
