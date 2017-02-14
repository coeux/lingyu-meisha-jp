#ifndef _MYSQL_CONNECTION_H_
#define _MYSQL_CONNECTION_H_

extern "C"{
#include <mysql/mysql.h>
#include <mysql/errmsg.h>
}

#include <string>
using namespace std;

#include <boost/noncopyable.hpp>
#include <boost/thread/mutex.hpp>

#include "log.h"
#include "mysql_log_def.h"

#ifndef MYSQL_TRY_CONNC_NUM
#define MYSQL_TRY_CONNC_NUM 3
#endif

//! defines mysql result set pointer
typedef MYSQL_RES* mysql_res_ptr_t;

//! defines mysql row type
typedef MYSQL_ROW mysql_row_t;

//! defines mysql column type for numeric and string
enum column_type_e
{
    COLUMN_NUMERIC,
    COLUMN_STRING,
    COLUMN_UNKNOW
};

/*! @ingroup    BASE_LIB
 *  @class      mysql_conn_t
 *  @author     congjun.chang@fminutes.com
 *  @brief      this class provides Mysql connection operation
 *  @details    this class includes
 *              1. connect to DB server
 *              2. executes Mysql sql
 */
class mysql_conn_t
{
public:

    /*! @fn         mysql_conn_t(const string& db_id, const string& host, const string& port,
     *                  const string& usr, const string& pwd, const string& database);
     *  @brief      constructor
     */
    mysql_conn_t(const string& db_id, const string& host, const string& port,
        const string& usr, const string& pwd, const string& database);

    /*! @fn         ~mysql_conn_t();
     *  @brief      destructor
     */
    ~mysql_conn_t();

    /*! @fn         int connect();
     *  @brief      connects to remote mysql DB server
     *  @return     int
     */
    int connect();

    /*! @fn         int disconnect();
     *  @brief      disconnects to remote mysql DB server
     *  @return     int
     */
    int disconnect();

    /*! @fn         int reconnect();
     *  @brief      reconnects to remote mysql DB server
     *  @return     int
     */
    int reconnect();

    /*! @fn         bool connected();
     *  @brief      gets connection status
     *  @return     int
     */
    bool connected();

    /*! @fn         int execute(const string& sql);
     *  @brief      executes sqlgets connection status
     *  @param      const string& sql: executed sql
     *  @return     int
     */
    int execute(const string& sql);

    /*! @fn         unsigned long affected_rows();
     *  @brief      gets affected row by insert/update/delete operation
     *  @return     unsigned long
     */
    unsigned long affected_rows();

    /*! @fn         unsigned long get_server_version();
     *  @brief      gets MySQL server version in number
     *  @return     unsigned long
     */
    unsigned long get_server_version();

    /*! @fn         mysql_res_ptr_t get_result();
     *  @brief      gets executed sql result
     *  @return     mysql_res_ptr_t: mysql result set
     */
    mysql_res_ptr_t get_result();

    /*! @fn         void start_transaction();
     *  @brief      start one transaction
     *  @return     void
     */
    void start_transaction();

    /*! @fn         void rollback();
     *  @brief      rollback one transaction
     *  @return     void
     */
    void rollback();

    /*! @fn         void commit();
     *  @brief      commit one transaction
     *  @return     void
     */
    void commit();
private:

    bool   m_connected;     //! identify mysql connection status
    string m_db_id;         //! remote mysql DB id for unique identify every mysql server
    string m_host;          //! remote mysql server host
    string m_port;          //! remote mysql server port
    string m_usr;           //! remote mysql server user account
    string m_pwd;           //! remote mysql server account password
    string m_database;      //! remote mysql server targeted database name
    MYSQL  m_mysql;         //! remote mysql server connection handler
    //! static singleton connection mutex for multi-thread mysql connection issue
    static boost::mutex m_conn_mutex;
};

/*! @ingroup    BASE_LIB
 *  @class      mysql_res_t
 *  @author     congjun.chang@fminutes.com
 *  @brief      this class provides Mysql sql execute result operation
 *  @details    this class includes
 *              1. fetch result row
 *              2. fetch row number etc...
 */
class mysql_res_t : private boost::noncopyable
{
public:
    /*! @fn         mysql_res_t();
     *  @brief      constructor
     */
    mysql_res_t();

    /*! @fn         mysql_res_t(mysql_res_t result);
     *  @brief      constructor
     */
    mysql_res_t(mysql_res_ptr_t result);

    /*! @fn         ~mysql_res_t();
     *  @brief      destructor
     */
    ~mysql_res_t();

    /*! @fn         int reset(mysql_res_t result);
     *  @brief      reset mysql result
     *  @return     int
     */
    int reset(mysql_res_ptr_t result = NULL);

    /*! @fn         unsigned long fetch_num_rows();
     *  @brief      gets number of row from result
     *  @return     unsigned long
     */
    inline unsigned long fetch_num_rows()
    {
        logtrace((DB_MYSQL, "mysql_res_t::fetch_num_rows begin ..."));

        unsigned long num = 0;
        if (!m_result)
        {
            logerror((DB_MYSQL, "mysql_res_t::fetch_num_rows result set is NULL"));
            return num;
        } //! else gets number of row normally

        num = mysql_num_rows(m_result);
        logtrace((DB_MYSQL, "mysql_res_t::fetch_num_rows end ok."));
        return num;
    }

    /*! @fn         unsigned int fetch_num_columns();
     *  @brief      gets result column number
     *  @return     unsigned int
     */
    inline unsigned int fetch_num_columns()
    {
        logtrace((DB_MYSQL, "mysql_res_t::fetch_num_columns begin ..."));

        if (!m_result)
        {
            logerror((DB_MYSQL, "mysql_res_t::fetch_num_columns result set is NULL"));
            return 0;
        } //! else gets number of field normally

        if (!m_column_num)
        {
            m_column_num = mysql_num_fields(m_result);
        }
        logtrace((DB_MYSQL, "mysql_res_t::fetch_num_columns end ok."));
        return m_column_num;
    }

    /*! @fn         column_type_e fetch_column_type(unsigned int index);
     *  @brief      fetchs special column type
     *  @return     column_type_e
     *  @notes      no need to define as inline function, it just need invoke one time for one select
     */
    column_type_e fetch_column_type(unsigned int index);

    /*! @fn         column_type_e fetch_column_type(const char* column_name);
     *  @brief      fetchs special column type
     *  @return     column_type_e
     *  @notes      no need to define as inline function, it just need invoke one time for one select
     */
    column_type_e fetch_column_type(const char* column_name);

    /*! @fn         mysql_row_t fetch_row();
     *  @brief      fetchs one row
     *  @return     mysql_row_t
     *  @notes      inline function for performance
     */
    inline mysql_row_t fetch_row()
    {
        //logtrace((DB_MYSQL, "mysql_res_t::fetch_row begin ..."));

        m_row = NULL;
        if (!m_result)
        {
            logerror((DB_MYSQL, "mysql_res_t::fetch_row result set is NULL"));
            return m_row;
        }  //! else gets next row by mysql API

        m_row = mysql_fetch_row(m_result);
        //logtrace((DB_MYSQL, "mysql_res_t::fetch_row end ok."));
        return m_row;
    }

    /*! @fn         char* fetch_column(unsigned int index);
     *  @brief      fetchs special column value
     *  @return     char*
     *  @notes      inline function for performance
     */
    inline char* fetch_column(unsigned int index)
    {
        logtrace((DB_MYSQL, "mysql_res_t::fetch_column <%u> begin ...", index));

        char* column = NULL;
        if (!m_row)
        {
            logerror((DB_MYSQL, "mysql_res_t::fetch_column row set is NULL"));
            return column;
        } //! else check index is out of range
        if (fetch_num_columns() <= index)
        {
            logerror((DB_MYSQL, "mysql_res_t::fetch_column column index is out of range"));
            return column;
        }  //! else gets special column

        column = m_row[index];
        logtrace((DB_MYSQL, "mysql_res_t::fetch_column end ok."));
        return column;
    }

    /*! @fn         char* fetch_column(const char* column_name);
     *  @brief      fetchs special column value
     *  @return     char*
     *  @notes      not recomand to use it for performance,
     *              you can invoke get_column_index() to get index at one times
     */
    char* fetch_column(const char* column_name);

    /*! @fn         unsigned long* fetch_field_lengths();
     *  @brief      fetchs every column content length
     *  @return     unsigned long*
     *  @notes      inline function for performance
     */
    unsigned long* fetch_field_lengths();

    /*! @fn         int free_result();
     *  @brief      free result set
     *  @return     int
     */
    int free_result();

    /*! @fn         int get_column_index_i(const char* column_name);
     *  @brief      gets column index by name
     *  @return     int: < 0 error
     */
    int get_column_index(const char* column_name);

private:

    mysql_res_ptr_t m_result;       //! mysql result set pointer
    mysql_row_t m_row;                //! mysql result row
    unsigned int m_column_num;      //! column number of current result set
    MYSQL_FIELD* m_column_infos;    //! all column info
};


//! Usage

//! mysql_conn_t conn(host, port, usr, pwd, db);
//! conn.connect();
//! conn.execute(sql);
//! mysql_res_t result(conn->get_result());
//! result->fetch_num_rows();

//! while (result.fetch_row()) {
//!   result.fetch_field_lengths();
//!   result.fetch_column(0);
//!   result.fetch_column("uid");
//! }
//! result.free_result();

//! -------- or --------

//! mysql_row_t row;
//! while (row = result.fetch_row()) {
//!   result.fetch_field_lengths();
//!   row[0];
//!   row[1];
//! }
//! result.free_result();
#endif //! _MYSQL_CONNECTION_H_

