#ifndef _sc_cache_data_h_
#define _sc_cache_data_h_

#include <boost/shared_ptr.hpp>
#include <string>
using namespace std;

struct sc_baseinfo_t
{
    string nickname;
    int32_t grade;
    int32_t fp;
    int32_t helphero;
    int32_t helpresid;
    int32_t frdcount;
};
typedef boost::shared_ptr<sc_baseinfo_t> sp_baseinfo_t;

struct sc_grade_user_data_t
{
    int32_t uid;
    int32_t resid;
    string name;
    int32_t lv;
    int32_t fp;
    int32_t helphero;
    int32_t helpresid;
};


#endif
