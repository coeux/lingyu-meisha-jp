#ifndef _sc_server_h_
#define _sc_server_h_

#include "singleton.h"
#include "db_ext.h"

class sc_server_t
{
public:
    db_Server_ext_t db;

    void load_db(int32_t serid_);
    void save_db();
private:
};

#define server (singleton_t<sc_server_t>::instance())

#endif
