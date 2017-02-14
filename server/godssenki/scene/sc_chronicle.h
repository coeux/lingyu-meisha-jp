#ifndef _sc_chronicle_h_
#define _sc_chronicle_h_

#include "msg_def.h"
#include "db_ext.h"
#include "repo_def.h"

#include <boost/shared_ptr.hpp>

#include <unordered_map>
#include <vector>
using namespace std;

class sc_user_t;

typedef vector<sc_msg_def::jpk_chronicle_progress_t> chronicle_pro_vec_t;

class sc_chronicle_mgr_t
{
    static const int32_t Done;
    static const int32_t Undone;
    static const int32_t CAN_READ;
    static const uint32_t DAYS[];
    typedef db_Chronicle_ext_t chronicle_t;
    typedef boost::shared_ptr<chronicle_t> sp_chronicle_t;
    typedef unordered_map<int32_t, sp_chronicle_t> chronicle_hm_t;
public:
    sc_chronicle_mgr_t(sc_user_t& user_);
    void load_db();
    void async_load_db();
    void unicast_chronicle_list(uint32_t month);
    bool is_sign();
    void sign(sc_msg_def::ret_chronicle_sign_t& ret, int32_t year_month_day);
    void record_retrieve(sc_msg_def::ret_chronicle_sign_retrieve_t& ret);
    void progress(sc_msg_def::ret_chronicle_sign_all_t& ret) const;
private:
    void save_db(sp_chronicle_t& sp_chronicle_);
    void add_chronicle(sp_chronicle_t& sp_chronicle_, uint32_t year_month_day, uint32_t state = 0);
    void month_chronicle(sc_msg_def::ret_chronicle_t& ret, uint32_t year_month) const;
    void progress(sc_msg_def::ret_chronicle_t& ret, uint32_t year_month);
    void progress(sc_msg_def::ret_chronicle_sign_retrieve_t& ret, uint32_t year_month) const;
    bool is_leap_year(const uint32_t year) const;
    int32_t get_current_year() const;
    int32_t get_current_month() const;
    int32_t get_current_day() const;
private:
    sc_user_t&      m_user;
    chronicle_hm_t  m_chronicle;
};
#endif
