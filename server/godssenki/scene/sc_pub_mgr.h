#ifndef _sc_pub_mgr_h_
#define _sc_pub_mgr_h_

#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"
#include "sc_maxid.h"

class sc_user_t;
class sc_pub_mgr_t
{
private:
    db_PubMgr_ext_t db;
public:
    sc_pub_mgr_t(sc_user_t& user_);
    void load_db();
	void save_db();
	void init_new_user();
	bool is_pub_3_first();
	void set_pub_3_first();
	bool is_pub_4_first();
	void set_pub_4_first();
	void add_pub_sum(int32_t num_);
	int32_t get_stepup_state();
	void add_stepup_state();
	int32_t get_event_state();
	void add_event_state();
private:
    sc_user_t&          m_user;
};

#endif
