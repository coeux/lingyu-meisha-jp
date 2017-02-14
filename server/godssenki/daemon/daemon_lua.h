#ifndef _daemon_lua_h_
#define _daemon_lua_h_

#include "ys_lua.h"
#include "singleton.h"

#include <set>
using namespace std;

class daemon_lua_t
{
public:
    daemon_lua_t();

    int reload_script(const string& path_);
    string do_script(const string& method_, const string& msg_);
private:
    boost::shared_ptr<ys_lua_t> m_sp_lua;
};

#endif
