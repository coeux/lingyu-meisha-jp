#ifndef _sc_lua_h_
#define _sc_lua_h_

#include "ys_lua.h"
#include "singleton.h"

#include <set>
using namespace std;

class sc_lua_t
{
public:
    sc_lua_t();

    int reload_script(const string& path_);
    int do_script(const string& method_, uint16_t cmd_, const string& msg_);
    boost::shared_ptr<ys_lua_t> prt() { return m_sp_lua; }
private:
    boost::shared_ptr<ys_lua_t> m_sp_lua;
};

#endif
