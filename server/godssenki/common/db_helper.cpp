#include "db_helper.h"
#include "dbgl_service.h"

#define BUFF_LEN 256

int dbid_assign_t::new_dbid(const char *idname_)
{
    boost::mutex::scoped_lock lock(m_mutex);

    char buf[BUFF_LEN];

    sprintf(buf,"update %s set value=last_insert_id(value+1)",idname_);
    dbgl_service.sync_execute(buf);

    sql_result_t res;
    sprintf(buf,"select last_insert_id()");
    dbgl_service.sync_select(buf,res);

    sql_result_row_t *row = res.get_row_at(0);
    if( row != NULL )
    {
        stringstream stream;
        int dbid = 0 ;
        stream << (*row)[0]; stream >> dbid; 
        return dbid;
    }
    return 0;
}

int async_new_dbid(const char *idname_)
{
    char buf[BUFF_LEN];

    sprintf(buf,"update %s set value=last_insert_id(value+1)",idname_);
    dbgl_service.async_execute(buf);

    sql_result_t res;
    sprintf(buf,"select last_insert_id()");
    dbgl_service.async_select(buf,res);

    sql_result_row_t *row = res.get_row_at(0);
    if( row != NULL )
    {
        stringstream stream;
        int dbid = 0 ;
        stream << (*row)[0]; stream >> dbid; 
        return dbid;
    }
    return 0;
}
