#ifndef _sc_pay_h_
#define _sc_pay_h_

#include <boost/shared_ptr.hpp>

#include "singleton.h"
#include <string>
using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_pay_t
{
public:
    int req_pay(sp_user_t sp_user_, int id_, const string& uin_, const string& domain_, const string& appid_);
    int on_payed(sp_user_t sp_user_, uint32_t serid_);
    int on_login(sp_user_t sp_user_);
};

#define pay_ins (singleton_t<sc_pay_t>::instance())

#endif
