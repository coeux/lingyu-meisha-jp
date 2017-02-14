#ifndef _sc_practice_h_
#define _sc_practice_h_

#include <stdint.h>
#include <vector>
#include <map>
#include <boost/shared_ptr.hpp>

#include <msg_def.h>
using namespace std;

class sc_user_t;

class sc_practice_t
{
public:
    sc_practice_t(sc_user_t &user_);
public:
    //清除cd
    void clear_cd(int32_t pos_);
    //训练伙伴
    void practice_partner(int32_t pos_, int32_t pid_, int32_t type_);
private:
    sc_user_t       &m_user;
};

typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_practice_cache_t
{
    //[uid] [cds]   0,未开放    1,clear    other,cd start timestamp
    typedef unordered_map<int32_t, vector<uint32_t> > practice_hm_t;
private:
    practice_hm_t m_practice_hm;
public:
    int32_t isopen(int32_t uid_, int32_t pos_);
    void open(sc_user_t &user_, int32_t pos_);
    void get_info(sp_user_t user_, vector<sc_msg_def::sc_practice_info_t> &ret_);
    int32_t get_last_prac(int32_t uid_, int32_t pos_);
    void set(int32_t uid_, int32_t pos_);
    void clear(int32_t uid_, int32_t pos_);
};
#define practice_cache (singleton_t<sc_practice_cache_t>::instance())

#endif
