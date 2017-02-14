#ifndef _DB_HELP_
#define _DB_HELP_

#include "singleton.h"
#include <boost/thread.hpp>

class dbid_assign_t
{
    boost::mutex m_mutex;
public:
    int new_dbid(const char *idname_);
};
#define dbid_assign (singleton_t<dbid_assign_t>::instance())

//注意async_new_dbid只能用在gldb_service的异步线程中！！！！！
int async_new_dbid(const char *idname_);

#endif
