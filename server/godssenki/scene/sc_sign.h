#ifndef _sc_sign_h_
#define _sc_sign_h_

#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_sign_t
{
public:
    sc_sign_t(sc_user_t& user_);
    int get_sign_reward(int id_);
    int get_sign_remedy(int id_);
private:
    sc_user_t       &m_user;
};
#endif
