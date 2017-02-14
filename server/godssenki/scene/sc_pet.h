#ifndef _sc_pet_h_
#define _sc_pet_h_

using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

class sc_user_t;
class sc_pet_t
{
public:
    db_Pet_ext_t db;

public:
    sc_pet_t(sc_user_t& user_);
    void get_pet_jpk(sc_msg_def::jpk_pet_t& jpk_);
    void save_db();

private:
    sc_user_t& m_user;
};

typedef boost::shared_ptr<sc_pet_t> sp_pet_t;

class sc_pet_mgr_t
{
public:
    sc_pet_mgr_t(sc_user_t& user_);
    void load_db();
    void init_new_user();
    sp_pet_t get();

    bool addnew(int32_t resid_, sc_msg_def::nt_bag_change_t& change_);
    void genpro(sp_pet_t sp_pet_);
    int32_t compose(sc_msg_def::ret_compose_pet_t& ret_);
    void get_pet_state(bool& have_pet_, int32_t& petid_);
    void get_pet_jpk(sc_msg_def::jpk_pet_t& jpk_, bool& have_pet_);
public:
    bool have_pet;

private:
    sc_user_t& m_user;
    sp_pet_t m_pet;
};

#endif
