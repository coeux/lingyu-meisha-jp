
#include "com_log.h"
#include "mysql_connection.h"
#include "singleton.h"

boost::mutex mysql_conn_t::m_conn_mutex;    //! defines all mysql connection mutex lock

mysql_conn_t::mysql_conn_t(const string& db_id, const string& host, const string& port,
    const string& usr, const string& pwd, const string& database)
    : m_connected(false), m_db_id(db_id), m_host(host), m_port(port),
    m_usr(usr), m_pwd(pwd), m_database(database)
{
    logtrace((DB_MYSQL, "mysql_conn_t::mysql_conn_t id:<%s> host:<%s:%s> db:<%s:%s:%s>",
              m_db_id.c_str(), m_host.c_str(), m_port.c_str(), m_usr.c_str(), m_pwd.c_str(), m_database.c_str()));
}

mysql_conn_t::~mysql_conn_t()
{
    logtrace((DB_MYSQL, "mysql_conn_t::~mysql_conn_t begin ..."));
    if (m_connected) disconnect();
    logtrace((DB_MYSQL, "mysql_conn_t::~mysql_conn_t end ok."));
}

int mysql_conn_t::connect()
{
    logtrace((DB_MYSQL, "mysql_conn_t::connect begin ..."));

    {
        boost::lock_guard<boost::mutex> lock(m_conn_mutex);

        if(m_connected)
        {
           logwarn((DB_MYSQL, "mysql_conn_t::connect already connected."));
           return 0;
        } //! else try to connect DB server

        if(!mysql_init(&m_mysql))
        {
            logerror((DB_MYSQL, "mysql_conn_t::connect mysql_init failed:<%s>.", mysql_error(&m_mysql)));
            return -1;
        } //! else invoke mysql_real_connect to connect

        //! set mysql connection charset as utf8
        mysql_options(&m_mysql, MYSQL_SET_CHARSET_NAME, "utf8");

        //! try to connect remote mysql server for MYSQL_TRY_CONNC_NUM times
        for (int i = 0; i < MYSQL_TRY_CONNC_NUM; ++i)
        {
            if (mysql_real_connect(&m_mysql, m_host.c_str(), m_usr.c_str(),
                m_pwd.c_str(), m_database.c_str(), atoi(m_port.c_str()), NULL, 0))
            {
                m_connected = true;
                break;
            }
            else
            {
                logerror((DB_MYSQL, "mysql_conn_t::connect mysql_real_connect failed to try to connect at %d times and msg: <%s>.", i + 1, mysql_error(&m_mysql)));
            }
        }

        if (!m_connected)
        {
            logerror((DB_MYSQL, "mysql_conn_t::connect failed to connect to mysql server"));
            return -1;
        } //! else successful to connect DB and return OK.
    }

    logtrace((DB_MYSQL, "mysql_conn_t::connect end ok."));
    return 0;
}

int mysql_conn_t::disconnect()
{
    logtrace((DB_MYSQL, "mysql_conn_t::disconnect begin ..."));

    {
        boost::lock_guard<boost::mutex> lock(m_conn_mutex);

        if(!m_connected)
        {
           logwarn((DB_MYSQL, "mysql_conn_t::disconnect already disconnected."));
           return 0;
        } //! else close connection

        mysql_close(&m_mysql);
        m_connected = false;
    }

    logtrace((DB_MYSQL, "mysql_conn_t::disconnect end ok."));
    return 0;
}

int mysql_conn_t::reconnect()
{
    logtrace((DB_MYSQL, "mysql_conn_t::reconnect begin ..."));

    disconnect();

    if (connect())
    {
        logerror((DB_MYSQL, "mysql_conn_t::reconnect failed to reconnect."));
        return -1;
    } //! else successful to connect DB and return OK.

    logtrace((DB_MYSQL, "mysql_conn_t::reconnect end ok."));
    return 0;
}

bool mysql_conn_t::connected()
{
    return m_connected;
}

int mysql_conn_t::execute(const string& sql)
{
    logtrace((DB_MYSQL, "mysql_conn_t::execute sql = <%s> begin ...", sql.c_str()));

    if(!m_connected)
    {
        logwarn((DB_MYSQL, "mysql_conn_t::execute disconnected status."));
        if (connect())
        {
            logerror((DB_MYSQL, "mysql_conn_t::execute disconnected and failed to connect."));
            //logcom((COM_DB_LOST, m_db_id.c_str(), "%s\n", sql.c_str()));    //! backup sql for db server lost
            return -1;
        } //! else continue to execute sql
    } //! else continue to execute sql

    if (mysql_query(&m_mysql, sql.c_str()))
    {
        if(CR_SERVER_GONE_ERROR == mysql_errno(&m_mysql) || CR_SERVER_LOST == mysql_errno(&m_mysql))
        {
            logerror((DB_MYSQL, "mysql_conn_t::execute mysql DB server has gone away and try to reconnect"));
            if (reconnect())
            {
                logerror((DB_MYSQL, "mysql_conn_t::execute failed to try reconnect"));
                //logcom((COM_DB_LOST, m_db_id.c_str(), "%s\n", sql.c_str()));    //! backup sql for db server lost

                return -1;
            } //! else try to execute sql again

            //! if successful to reconnect, try to execute sql again
            if (mysql_query(&m_mysql, sql.c_str()))
            {
                logerror((DB_MYSQL, "mysql_conn_t::execute failed to execute sql <%s> again and msg <%d:%s>", sql.c_str(), mysql_errno(&m_mysql), mysql_error(&m_mysql)));
                //logcom((COM_SQL_ERROR, m_db_id.c_str(), "%s\n", sql.c_str()));    //! backup sql for db sql error
                return -1;
            } //! successful to execute sql and return 0
        }
        else
        {
            //printf("%s\n", mysql_error(&m_mysql));
            logerror((DB_MYSQL, "mysql_conn_t::execute failed to execute sql <%s> and msg <%d:%s>", sql.c_str(), mysql_errno(&m_mysql), mysql_error(&m_mysql)));
            //logcom((COM_SQL_ERROR, m_db_id.c_str(), "%s\n", sql.c_str()));    //! backup sql for db sql error

            return -1;
        }
    } //! else 0 == query_result and successful to execute sql, return OK

    logtrace((DB_MYSQL, "mysql_conn_t::execute end ok."));
    return 0;
}

unsigned long mysql_conn_t::affected_rows()
{
    return (unsigned long)mysql_affected_rows(&m_mysql);
}

unsigned long mysql_conn_t::get_server_version()
{
    //! major_version*10000 + minor_version*100 + sub_version
    return (unsigned long)mysql_get_server_version(&m_mysql);
}

mysql_res_ptr_t mysql_conn_t::get_result()
{
    return mysql_store_result(&m_mysql);
}

void mysql_conn_t::start_transaction()
{
    execute("START TRANSACTION;");
}

void mysql_conn_t::rollback()
{
    execute("ROLLBACK;");
}

void mysql_conn_t::commit()
{
    execute("COMMIT;");
}

///////////////////////////////////////////////////////////////////
mysql_res_t::mysql_res_t()
    : m_result(NULL), m_row(NULL), m_column_num(0), m_column_infos(NULL)
{
    logtrace((DB_MYSQL, "mysql_res_t::mysql_res_t"));
}

mysql_res_t::mysql_res_t(mysql_res_ptr_t result)
    : m_result(result), m_row(NULL), m_column_num(0), m_column_infos(NULL)
{
    logtrace((DB_MYSQL, "mysql_res_t::mysql_res_t"));
}

mysql_res_t::~mysql_res_t()
{
    logtrace((DB_MYSQL, "mysql_res_t::~mysql_res_t begin ..."));
    free_result();
    logtrace((DB_MYSQL, "mysql_res_t::~mysql_res_t end ok."));
}

int mysql_res_t::reset(mysql_res_ptr_t result)
{
    logtrace((DB_MYSQL, "mysql_res_t::reset begin ..."));

    free_result();
    m_result = result;
    m_row = NULL;
    m_column_num = 0;
    m_column_infos = NULL;
    logtrace((DB_MYSQL, "mysql_res_t::reset end ok."));
    return 0;
}

column_type_e mysql_res_t::fetch_column_type(unsigned int index)
{
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column_type <%d> begin ...", index));

    column_type_e type = COLUMN_UNKNOW;
    if (!m_result)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type result set is NULL"));
        return type;
    } //! else check index is out of range
    if (fetch_num_columns() <= index)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type column index is out of range"));
        return type;
    } //! else gets field type

    MYSQL_FIELD* field = mysql_fetch_field_direct(m_result, index);
    if (!field)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type failed to get filed type"));
        return type;
    } //! else checks field type

    type = IS_NUM(field->type) ? COLUMN_NUMERIC : COLUMN_STRING;
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column_type end ok."));
    return type;
}

column_type_e mysql_res_t::fetch_column_type(const char* column_name)
{
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column_type <%s> begin ...", column_name));

    column_type_e type = COLUMN_UNKNOW;
    if (!column_name)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type column_name is NULL"));
        return type;
    } //! else check result
    if (!m_result)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type result set is NULL"));
        return type;
    } //! else check index is out of range
    int column_index = get_column_index(column_name);
    if (0 > column_index)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type column index is out of range"));
        return type;
    } //! else gets field type

    MYSQL_FIELD* field = mysql_fetch_field_direct(m_result, column_index);
    if (!field)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column_type failed to get filed type"));
        return type;
    } //! else checks field type

    type = IS_NUM(field->type) ? COLUMN_NUMERIC : COLUMN_STRING;
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column_type end ok."));
    return type;
}

char* mysql_res_t::fetch_column(const char* column_name)
{
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column <%s> begin ...", column_name));

    char* column = NULL;
    if (!column_name)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column index is empty"));
        return column;
    }  //! else check whether result set is empty
    if (!m_row)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column row set is NULL"));
        return column;
    }  //! else gets column index
    int column_index = get_column_index(column_name);
    if (0 > column_index)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_column column <%s> not exist", column_name));
        return column;
    }  //! else gets special column

    column = m_row[column_index];
    logtrace((DB_MYSQL, "mysql_res_t::fetch_column end ok."));
    return column;
}

unsigned long* mysql_res_t::fetch_field_lengths()
{
    logtrace((DB_MYSQL, "mysql_res_t::fetch_field_lengths begin ..."));

    unsigned long* lengths = NULL;
    if (!m_result)
    {
        logerror((DB_MYSQL, "mysql_res_t::fetch_field_lengths result set is NULL"));
        return lengths;
    }  //! else gets every field length by mysql API

    lengths = mysql_fetch_lengths(m_result);
    logtrace((DB_MYSQL, "mysql_res_t::fetch_field_lengths end ok."));
    return lengths;
}

int mysql_res_t::free_result()
{
    logtrace((DB_MYSQL, "mysql_res_t::free_result begin ..."));
    if (m_result)
    {
        mysql_free_result(m_result);
        m_result = NULL;
    } //! else return OK.
    m_row = NULL;
    m_column_num = 0;
    m_column_infos = NULL;

    logtrace((DB_MYSQL, "mysql_res_t::free_result end ok."));
    return 0;
}

int mysql_res_t::get_column_index(const char* column_name)
{
    logtrace((DB_MYSQL, "mysql_res_t::get_column_index begin ..."));

    int ret = -1;
    if (!m_result)
    {
        logerror((DB_MYSQL, "mysql_res_t::get_column_index result set is NULL"));
        return ret;
    } //! else lazy load column infos
    if (!m_column_infos)
    {
        m_column_infos = mysql_fetch_fields(m_result);
    } //! else lazy load number infos
    if (!m_column_num)
    {
        m_column_num = mysql_num_fields(m_result);
    } //! else compary every column

    for (size_t i = 0; i < m_column_num; ++i)
    {
        if (0 == strcmp(column_name, m_column_infos[i].name))
        {
            ret = i;
            break;
        } //! else continue compary every column
    }

    logtrace((DB_MYSQL, "mysql_res_t::get_column_index end ok."));
    return ret;
}

