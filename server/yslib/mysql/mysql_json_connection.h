#ifndef MYSQL_JSON_CONNECTION_H
#define MYSQL_JSON_CONNECTION_H

#include <map>
#include <vector>
#include <string>
using namespace std;

#include <boost/format.hpp>
#include <boost/shared_ptr.hpp>

#include "log.h"
#include "mysql_connection.h"

/*! @ingroup    BASE_LIB
 *  @class      mysql_json_conn_t
 *  @author     congjun.chang@fminutes.com
 *  @brief      this class provides Mysql json connection operation
 *  @details    this class includes
 *              1. execute json update operation
 *              2. execute json delete operation
 *              3. execute json insert operation
 *              4. execute json select operation
 */
class mysql_json_conn_t : public mysql_conn_t
{
public:

    //! json key attribute index
    enum EJsonKeyIndex
    {
        KEY_UID = 0,
        KEY_TABLE,
        KEY_COLUMN,
        KEY_COLUMN_VALUE,
        KEY_INDEX_MAX
    };

public:

    /*! @fn         mysql_json_conn_t(const string& db_id, const string& host, const string& port,
     *                  const string& usr, const string& pwd, const string& database);
     *  @brief      constructor
     */
    mysql_json_conn_t(const string& db_id, const string& host, const string& port,
        const string& usr, const string& pwd, const string& database);

    /*! @fn         ~mysql_json_conn_t();
     *  @brief      destructor
     */
    ~mysql_json_conn_t();

    /*! @fn         int execute_update(const string& key, const string& value);
     *  @brief      executes update sql based on json key and value string
     *  @param      const string& key:  json key attribute
     *  @param      const string& value:  json string for updated column
     *  @return     int
     *  @note       the key string format:
     *                  "uid#table_name#conditon#conditon_value"
     *                  "uid#table_name"
     *              the value string format:
     *                  "{"column1":"value_str","column2":"value_str","column3":value_num,"column4":value_num}"
     */
    int execute_update(const string& key, const string& value);

    /*! @fn         int execute_insert(const string& key, const string& value);
     *  @brief      executes insert sql based on json key and value string
     *  @param      const string& key:  json key attribute
     *  @param      const string& value:  json string for inserted column
     *  @return     int
     *  @note       the key string format:
     *                  "uid#table_name#conditon#conditon_value"
     *                  "uid#table_name"
     *              the value string format:
     *                  "{"column1":"value_str","column2":"value_str","column3":value_num,"column4":value_num}"
     */
    int execute_insert(const string& key, const string& value);

    /*! @fn         int execute_delete(const string& key);
     *  @brief      executes delete sql based on json key
     *  @param      const string& key:  json key attribute
     *  @return     int
     *  @note       the key string format:
     *                  "uid#table_name#conditon#conditon_value"
     *                  "uid#table_name"
     */
    int execute_delete(const string& key);

    /*! @fn         int execute_select(const string& key, const string& value, string result);
     *  @brief      executes select sql and out result by param #3 based on json key and value
     *  @param      const string& key:  json key attribute
     *  @param      const string& value:  json string for selected column
     *  @return     int
     *  @note       the key string format:
     *                  "uid#table_name#conditon#conditon_value"
     *                  "uid#table_name"
     *              the value string format:
     *                  "{"column1","column2"}"
     *              the result string format:
     *                  "{"column1":"value_str","column2":value_num}"
     */
    int execute_select(const string& key, const string& value, string& result);

    /*! @fn         int execute_select_all(const string& key, const string& condition, const string& value, string& result);
     *  @brief      executes select sql and out result by param #4 based on json key and value
     *  @param      const string& key:  json key attribute
     *  @param      const string& value:  json string for selected column
     *  @return     int
     *  @note       the key string format:
     *                  "uid#table_name"
     *              the value string format:
     *                  "{"column1","column2"}"
     *              the result string format:
     *                  "{uid#table_name#conditon#value1:{"column1":"value_str","column2":value_num},uid#table_name#conditon#value2:{"column1":value_num,"column2":"value_str"}}
     */
    template<class CResultContainer>
    int execute_select_all(const string& key, const string& condition, const string& value, CResultContainer& result);

    /*! @fn         void execute_select_all_limit(const string& key, const string& condition, const string& value, const string& conditions,
     *                                            const string& order_by, unsigned int start, unsigned int offset);
     *  @brief      async find muliti db content result out by param #3 based on json key
     *  @param      const string& key:  json key attribute
     *  @param      const string& condition:  json condition column
     *  @param      const string& value:  json string for selected column
     *  @param      const string& conditions: muliti-column:value pair json string
     *  @param      const string& order_by: select order by columns and order by rule
     *  @param      unsigned int start: select result start value
     *  @param      unsigned int limit: select limit number
     *  @return     void
     *  @note       the key string format:
     *                  "uid#table_name"
     *              the condition string format:
     *                  "column1"
     *              the value string format:
     *                  "{"column1","column2"}"
     *              the conditions string format:
     *                  "{"column3":"value_str","column4":value_num}"
     *              the order_by string format:
     *                  " column1,column2 ASC/DESC"
     *              the result string format:
     *                  "{uid#table_name#conditon#value1:{"column1":"value_str","column2":value_num},uid#table_name#conditon#value2:{"column1":value_num,"column2":"value_str"}}
     */
    template<class CResultContainer>
    int execute_select_all_limit(const string& key, const string& condition, const string& value, const string& conditions,
                                 const string& order_by, unsigned int start, unsigned int limit, CResultContainer& result);

private:

    /*! @fn         int parse_key_i(const string& key, vector<string>& key_vec);
     *  @brief      parse key json string
     *  @param      const string& key:  json key attribute
     *  @param      vector<string>& key_vec:  json subkey vector
     *  @param      bool check_index_max: identify whether need to check max index
     *  @return     int
     */
    int parse_key_i(const string& key, vector<string>& key_vec, bool check_index_max = true);

    /*! @fn         int parse_update_value_i(const string& value, string& columns);
     *  @brief      parse value json string for update SQL
     *  @param      const string& value:  json value attribute
     *  @param      string columns:  out parameter for SQL column format
     *  @return     int
     *  @note       the value string format:
     *                  "{"column1":value_num,"column2":value_num,"column3":"value_str"}"
     *              the out columns format:
     *                  "`column1`=value_num,`column2`=value_num,`column3`="value_str""
     */
    int parse_update_value_i(const string& value, string& columns);

    /*! @fn         int parse_insert_value_i(const string& value, string& columns, string& column_values);
     *  @brief      parse value json string for insert SQL
     *  @param      const string& value:  json key attribute
     *  @param      string columns:  columns string
     *  @param      string& column_values: column values string
     *  @return     int
     *  @note       the value string format:
     *                  "{"column1":value_num,"column2":value_num,"column3":"value_str"}"
     *              the out columns format:
     *                  "`column1`,`column2`,`column3`"
     *              the out column values format:
     *                  "value_num,"value_num,"value_str""
     */
    int parse_insert_value_i(const string& value, string& columns, string& column_values);

    /*! @fn         int parse_select_value_i(const string& value, string& columns, vector<string>& column_vec);
     *  @brief      parse value json string for select SQL
     *  @param      const string& value:  json key attribute
     *  @param      string columns:  columns string
     *  @param      vector<string>& column_vec: column string vector
     *  @return     int
     *  @note       the value string format:
     *                  "{"column1","column2","column3"}"
     *              the out columns format:
     *                  "`column1`,`column2`,`column3`"
     */
    int parse_select_value_i(const string& value, string& columns, vector<string>& column_vec);

    /*! @fn         int assemble_select_i(mysql_res_t& result_set, vector<string>& column_vec, string& result);
     *  @brief      assemble json string for select result
     *  @param      mysql_res_t& result_set: result set
     *  @param      vector<string>& column_vec: column string vector
     *  @param      string& result:  select result json string
     *  @return     int
     */
    int assemble_select_i(mysql_res_t& result_set, vector<string>& column_vec, string& result);

    /*! @fn         int assemble_select_all_i(mysql_res_t&, const string&, const string&, vector<string>&, string&);
     *  @brief      assemble json string for select result
     *  @param      mysql_res_t& result_set: result set
     *  @param      const string& key:  select json key string
     *  @param      const string& condition:  select json condition string
     *  @param      vector<string>& column_vec: column string vector
     *  @param      string& result:  select result json string
     *  @return     int
     */
    int assemble_select_all_i(mysql_res_t& result_set, const string& key, const string& condition, vector<string>& column_vec, string& result);
    int assemble_select_all_i(mysql_res_t& result_set, const string& key, const string& condition,
                              vector<string>& column_vec, boost::shared_ptr<map<string, string> > result);

    /*! @fn         int check_condition_format(const string& condition);
     *  @brief      check select condition format
     *  @param      const string& condition:  one column condition string
     *  @return     int
     *  @note       cannot exist ",", "*"
     */
    int check_condition_format(const string& condition);

    /*! @fn         bool check_column_exist_i(const string& column, const string& columns);
     *  @brief      check select condition format
     *  @param      const string& column:  column string
     *  @param      const string& columns: all columns string
     *  @return     bool
     */
    bool check_column_exist_i(const string& column, const string& columns);

    int parse_select_conditions_i(const string& conditions, string& condition_sql);

    int check_order_by_format_i(const string& order_by);

private:

    string                                              m_db_id;
    string                                              m_db_host;
    string                                              m_db_port;
    string                                              m_db_usr;
    string                                              m_db_pwd;
    string                                              m_db_name;
};

template<class CResultContainer>
int mysql_json_conn_t::execute_select_all(const string& key, const string& condition,
                                             const string& value, CResultContainer& result)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_select_all <%s><%s><%s> begin ...", key.c_str(), condition.c_str(), value.c_str()));

    vector<string> key_vec;
    string columns;
    vector<string> column_vec;
    if (parse_key_i(key, key_vec, false)) //! key format: "uid#table_name"
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all failed to parse json key"));
        return -1;
    }
    if (check_condition_format(condition))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all failed to check json condition format"));
        return -1;
    }
    if (parse_select_value_i(value, columns, column_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all failed to parse json value"));
        return -1;
    }
    if (!check_column_exist_i(condition, columns))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all failed to check condition column from json value column string"));
        return -1;
    }

    boost::format fmt_sql("select %s from `%s` where `uid` = %s");
    fmt_sql % columns.c_str();
    fmt_sql % key_vec[KEY_TABLE].c_str();
    fmt_sql % key_vec[KEY_UID].c_str();
    string sql = fmt_sql.str();

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all execute sql=<%s> failed.", sql.c_str()));
        return -1;
    }

    mysql_res_t result_set(get_result());
    if (assemble_select_all_i(result_set, key, condition, column_vec, result))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all failed to assemble select result."));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::execute_select_all end ok."));
    return 0;
}

template<class CResultContainer>
int mysql_json_conn_t::execute_select_all_limit(const string& key, const string& condition, const string& value, const string& conditions,
                                                   const string& order_by, unsigned int start, unsigned int limit, CResultContainer& result)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_select_all_limit <%s><%s><%s> begin ...", key.c_str(), condition.c_str(), value.c_str()));

    vector<string> key_vec;
    string columns;
    vector<string> column_vec;
    string condition_sql;
    if (parse_key_i(key, key_vec, false)) //! key format: "uid#table_name"
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to parse json key"));
        return -1;
    }
    if (check_condition_format(condition))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to check json condition format"));
        return -1;
    }
    if (parse_select_value_i(value, columns, column_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to parse json value"));
        return -1;
    }
    if (parse_select_conditions_i(conditions, condition_sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to parse conditions"));
        return -1;
    }
    if (check_order_by_format_i(order_by))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to check order by format"));
        return -1;
    }
    if (!check_column_exist_i(condition, columns))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to check condition column from json value column string"));
        return -1;
    }

    boost::format fmt_sql("select %s from `%s` where `uid` = %s AND %s order by %s limit %u,%u");
    fmt_sql % columns.c_str();
    fmt_sql % key_vec[KEY_TABLE].c_str();
    fmt_sql % key_vec[KEY_UID].c_str();
    fmt_sql % condition_sql.c_str();
    fmt_sql % order_by.c_str();
    fmt_sql % start;
    fmt_sql % limit;
    string sql = fmt_sql.str();

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit execute sql=<%s> failed.", sql.c_str()));
        return -1;
    }

    mysql_res_t result_set(get_result());
    if (assemble_select_all_i(result_set, key, condition, column_vec, result))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select_all_limit failed to assemble select result."));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::execute_select_all_limit end ok."));
    return 0;
}

#endif //! MYSQL_JSON_CONNECTION_H

