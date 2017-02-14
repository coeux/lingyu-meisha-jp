#ifndef _sc_chip_smash_h_
#define _sc_chip_smash_h_

#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_smashitem_t
{
public:
    db_ChipSmash_ext_t db;
public:
    sc_smashitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_smashitem_t> sp_smashitem_t;

class sc_chip_smash_t
{
    typedef unordered_map<int32_t, sp_smashitem_t> chipsmash_hm_t;
public:
    sc_chip_smash_t(sc_user_t& user_);
    void load_db();
    int unicast_smash_items();
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    chipsmash_hm_t m_chipsmash_hm;
};

class sc_chipvalue_t
{
public:
    db_ChipValue_ext_t db;
public:
    sc_chipvalue_t();
    void save_db();
};

typedef boost::shared_ptr<sc_chipvalue_t> sp_chipvalue_t;

class sc_chipvalue_mgr_t
{
    typedef unordered_map<int32_t, sp_chipvalue_t> chipvalue_hm_t;
public:
    sc_chipvalue_mgr_t();
    void load_db(vector<int32_t>& hostnums_); 
    void update_chipvalue(int32_t chipid_, int32_t value_);
    int  get_chipvalue(int32_t chipid_,int32_t& trend, int32_t type_);
private:
    chipvalue_hm_t      m_chipvalue_hm;
};

#define chip_value (singleton_t<sc_chipvalue_mgr_t>::instance())
#endif
