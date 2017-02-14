#ifndef _farm_h_
#define _farm_h_

#include<unordered_map>
#include<map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;

class sc_farmitem_t
{
public:
   db_HomeFarm_ext_t db;
public:
    sc_farmitem_t(sc_user_t& user_);
    void save_db(); 

private:
    sc_user_t& m_user;
};

typedef boost::shared_ptr<sc_farmitem_t> sp_farmitem_t;

class sc_farm_mgr_t
{
    typedef unordered_map<int32_t, sp_farmitem_t> farm_hm_t;

public:
    sc_farm_mgr_t(sc_user_t& user_);

    void init_new_user();
    void load_db();
    int32_t unicast_farm_item();
    int32_t plant_farm_item(int32_t farmid_, int32_t resid_);
    int32_t harvest_farm_item(int32_t farmid_); 
    int32_t steal_farm_item();
private:
    sc_user_t& m_user;
    farm_hm_t m_farm_hm;
};

#endif 
