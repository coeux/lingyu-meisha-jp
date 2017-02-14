#ifndef _dbgl_service_h_
#define _dbgl_service_h_

#include "singleton.h"
#include "db_service.h"


class dbgl_service_t : public db_service_t{
};

#define dbgl_service (singleton_t<dbgl_service_t>::instance())

#endif
