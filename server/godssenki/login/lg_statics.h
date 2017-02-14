#ifndef _lg_statics_h_
#define _lg_statics_h_

#include <string>

#include "singleton.h"
#include "db_service.h"
#include "db_ext.h"

using namespace std;

class lg_statics_t
{
public:
    void unicast_newaccount(string &domain_,string &name_,int aid);
public:
    db_service_t m_statics_db;
};

#define lg_statics_ins (singleton_t<lg_statics_t>::instance())

#endif
