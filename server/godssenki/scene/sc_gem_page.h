#ifndef _sc_gem_page_h_
#define _sc_gem_page_h_

#include "singleton.h"
#include "repo_def.h"
#include "db_ext.h"
#include "code_def.h"
#include "msg_def.h"

using namespace std;

class sc_user_t;
class sc_gem_t
{
public:
    sc_gem_t(sc_user_t& user_);
    int32_t inlay(int32_t resid_, sc_msg_def::ret_gemstone_inlay_t& ret_);
    int32_t unlay(sc_msg_def::ret_gemstone_inlay_t& ret_);
    void save_db();
public:
    db_GemPage_ext_t db;
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_gem_t> sp_gem_t;

class sc_gem_page_t
{
public:
    sc_gem_page_t(sc_user_t& user_);
    void load_db();
    void init_new_user();
    int32_t get_gem_info(sc_msg_def::ret_gem_page_info_t& ret_);
    int32_t get(int32_t pageid_, int32_t slotid_, sp_gem_t& sp_gem);
    int32_t get_attribute(int32_t pageid_, int32_t gem_type_);
private:
    unordered_map<int32_t, unordered_map<int32_t, unordered_map<int32_t, sp_gem_t>>> gem_map;
    sc_user_t& m_user; 
};

#endif

