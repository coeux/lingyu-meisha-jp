#ifndef _sc_spec_weapon_h_
#define _sc_spec_weapon_h_

using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

class sc_user_t;
class sc_spec_weapon_t
{
public:
    db_SpecWeapon_ext_t db;

public:
    sc_spec_weapon_t(sc_user_t& user_);
    void get_sweapon_jpk(sc_msg_def::jpk_sweapon_t& jpk_);
    void save_db();
private:
    sc_user_t& m_user;
};

typedef boost::shared_ptr<sc_spec_weapon_t> sp_sweapon_t;

class sc_sweapon_mgr_t
{
public:
    sc_sweapon_mgr_t(sc_user_t& user_);
    void load_db();
    void init_new_user();

    void addnew(int32_t resid_);
    void genpro(sp_sweapon_t sp_sweapon_);
	void change_pro(sp_sweapon_t sp_sweapon_);
	void wear(int32_t weapon_id_, int32_t pid_);
	void takeoff(int32_t weapon_id_, int32_t pid_);

private:
    sc_user_t& m_user;
	unordered_map<int32_t, sp_sweapon_t> weapon_map;
	sc_maxid_t m_maxid;
};

#endif
