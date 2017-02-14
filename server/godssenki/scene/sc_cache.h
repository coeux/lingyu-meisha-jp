#ifndef _sc_cache_h_
#define _sc_cache_h_

#include <boost/shared_ptr.hpp>

using namespace std;

#include "lru_cache.h"
#include "singleton.h"
#include "msg_def.h"
#include "sc_user.h"
#include "sc_cache_data.h"

#define MAX_GRADE 200

typedef lru_cache_t<int32_t, sp_user_t> sc_cache_t;
#define cache (singleton_t<sc_cache_t>::instance())

class sc_view_cache_t : public lru_cache_t<int32_t, sp_view_user_t>
{
public:
    sp_view_user_t get_view(int32_t uid_, bool withdb_ = false);
    sp_view_user_t get_other_view(int32_t uid_);
    sp_view_user_t get_view(int32_t uid_, int32_t* rid_, bool withdb_ = false);
    sp_fight_view_user_t get_fight_view(int32_t uid_, int32_t* rid_, bool withdb_ = false);
    sp_fight_view_user_t get_gbattle_fight_view(int32_t uid_, int32_t* rid_, bool withdb_=false);
    sp_fight_view_user_t get_rank_view(int32_t uid_, int32_t* rid_);
    int32_t get_fp_total(sp_view_user_t &view_);

    void insert_view(sp_view_user_t view_);
    void update_view(sp_view_user_t view_);
};
#define view_cache (singleton_t<sc_view_cache_t>::instance())

typedef lru_cache_t<int32_t, sp_user_t> sc_cache_other_t;
#define cache_other (singleton_t<sc_cache_other_t>::instance())

class sc_view_cache_other_t : public lru_cache_t<int32_t, sp_view_user_other_t>
{
public:
    sp_view_user_other_t get_view_others(int32_t uid_, bool withdb_ = false);
};
#define view_cache_other (singleton_t<sc_view_cache_other_t>::instance())

class sc_hero_cache_t : public lru_cache_t<int32_t, sp_helphero_t>
{
public:
    sp_helphero_t get_helphero(int32_t uid_, bool withdb_ = true);
};
#define hero_cache (singleton_t<sc_hero_cache_t>::instance())

class sc_baseinfo_cache_t : public lru_cache_t<int32_t, sp_baseinfo_t>
{
public:
    sp_baseinfo_t get_baseinfo(int32_t uid_, bool withdb_ = true);
};
#define baseinfo_cache (singleton_t<sc_baseinfo_cache_t>::instance())

class sc_name_cache_t : public lru_cache_t<string, int32_t>
{
public:
    int32_t get_uid_by_name(const string &name_, bool withdb_ = true);
};
#define name_cache (singleton_t<sc_name_cache_t>::instance())

class sc_grade_user_t
{
    typedef list<sc_grade_user_data_t> grade_bucket_t;
private:
    grade_bucket_t grade_user[MAX_GRADE];
public:
    void load_db(vector<int32_t>& hostnums_);
    int32_t get_users(int32_t uid_, int32_t grade_, vector<sc_msg_def::jpk_trial_target_info_t> &ret_);
    int32_t get_strangers(sp_user_t user_,int32_t uid_,int32_t grade_,int32_t count_,vector<sc_msg_def::friend_info_t> &ret_);
    void put_user(sp_user_t user_);
    void remove_user(int32_t uid_,int32_t grade_);
};
#define grade_user_cache (singleton_t<sc_grade_user_t>::instance())

#endif
