
#include <boost/regex.hpp>
#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>

#include "mysql_json_connection.h"

mysql_json_conn_t::mysql_json_conn_t(const string& db_id, const string& host, const string& port,
    const string& usr, const string& pwd, const string& database)
    : mysql_conn_t(db_id, host, port, usr, pwd, database),
    m_db_id(db_id), m_db_host(host), m_db_port(port), m_db_usr(usr), m_db_pwd(pwd), m_db_name(database)
{
    logtrace((COMMON, "mysql_json_conn_t::mysql_json_conn_t"));
}

mysql_json_conn_t::~mysql_json_conn_t()
{
    logtrace((COMMON, "mysql_json_conn_t::~mysql_json_conn_t"));
}

int mysql_json_conn_t::execute_update(const string& key, const string& value)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_update <%s><%s> begin ...", key.c_str(), value.c_str()));

    vector<string> key_vec;
    string columns;
    if (parse_key_i(key, key_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_update failed to parse json key"));
        return -1;
    } //! else continue to parse json value string to sql format

    if (parse_update_value_i(value, columns))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_update failed to parse json value"));
        return -1;
    } //! else continue to assemable update sql

    boost::format fmt_sql("update `%s` set %s where `uid` = %s");
    fmt_sql % key_vec[KEY_TABLE].c_str();
    fmt_sql % columns.c_str();
    fmt_sql % key_vec[KEY_UID].c_str();

    string sql = fmt_sql.str();
    if (KEY_INDEX_MAX == key_vec.size()) //! exist another condition
    {
        sql.append(" and `");
        sql.append(key_vec[KEY_COLUMN]);
        sql.append("` = \"");
        sql.append(key_vec[KEY_COLUMN_VALUE]);
        sql.append("\"");
    }

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_update execute sql=<%s> failed.", sql.c_str()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::execute_update end ok."));
    return 0;
}

int mysql_json_conn_t::execute_insert(const string& key, const string& value)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_insert <%s><%s> begin ...", key.c_str(), value.c_str()));

    vector<string> key_vec;
    string columns;
    string column_values;
    if (parse_key_i(key, key_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_insert failed to parse json key"));
        return -1;
    }
    if (parse_insert_value_i(value, columns, column_values))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_insert failed to parse json value"));
        return -1;
    }

    //! insert into %s(uid,%s,%s) values(%s%s%s)
    string sql("insert into `");
    sql.append(key_vec[KEY_TABLE]);
    sql.append("`(`uid`, ");
    bool append_key_column = (KEY_INDEX_MAX == key_vec.size()) && !check_column_exist_i(key_vec[KEY_COLUMN], columns);
    if (append_key_column)
    {
        sql.append("`");
        sql.append(key_vec[KEY_COLUMN]);
        sql.append("`,");
    } //! else no need to append another column
    sql.append(columns);
    sql.append(") values(");
    sql.append(key_vec[KEY_UID]);
    sql.append(",");
    if (append_key_column)
    {
        sql.append("\"");
        sql.append(key_vec[KEY_COLUMN_VALUE]);
        sql.append("\",");
    } //! else no need to append another column
    sql.append(column_values);
    sql.append(")");

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_insert execute sql=<%s> failed.", sql.c_str()));
        return -1;
    } //! else successful to execute sql and return OK

    logtrace((COMMON, "mysql_json_conn_t::execute_insert end ok."));
    return 0;
}

int mysql_json_conn_t::execute_delete(const string& key)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_delete <%s> begin ...", key.c_str()));
    vector<string> key_vec;
    if (parse_key_i(key, key_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_delete failed to parse json key"));
        return -1;
    } //! else continue to assemable delete sql

    boost::format fmt_sql("delete from `%s` where `uid` = %s");
    fmt_sql % key_vec[KEY_TABLE].c_str();
    fmt_sql % key_vec[KEY_UID].c_str();

    string sql = fmt_sql.str();
    if (KEY_INDEX_MAX == key_vec.size())
    {
        sql.append(" and `");
        sql.append(key_vec[KEY_COLUMN]);
        sql.append("` = \"");
        sql.append(key_vec[KEY_COLUMN_VALUE]);
        sql.append("\"");
    }

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_delete execute sql=<%s> failed.", sql.c_str()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::execute_delete end ok."));
    return 0;
}

int mysql_json_conn_t::execute_select(const string& key, const string& value, string& result)
{
    logtrace((COMMON, "mysql_json_conn_t::execute_select <%s><%s> begin ...", key.c_str(), value.c_str()));
    vector<string> key_vec;
    string columns;
    vector<string> column_vec;
    if (parse_key_i(key, key_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select failed to parse json key"));
        return -1;
    } //! else continue to parse json value string to columns and column values string

    if (parse_select_value_i(value, columns, column_vec))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select failed to parse json value"));
        return -1;
    } //! else continue to assemable select sql

    boost::format fmt_sql("select %s from `%s` where `uid` = %s");
    fmt_sql % columns.c_str();
    fmt_sql % key_vec[KEY_TABLE].c_str();
    fmt_sql % key_vec[KEY_UID].c_str();

    string sql = fmt_sql.str();
    if (KEY_INDEX_MAX == key_vec.size())
    {
        sql.append(" and `");
        sql.append(key_vec[KEY_COLUMN]);
        sql.append("` = \"");
        sql.append(key_vec[KEY_COLUMN_VALUE]);
        sql.append("\"");
    }

    if(execute(sql))
    {
        logerror((COMMON, "mysql_json_conn_t::execute_select execute sql=<%s> failed.", sql.c_str()));
        return -1;
    }

    mysql_res_t result_set(get_result());
    unsigned long result_num_row = result_set.fetch_num_rows();
    if (1 < result_num_row) //! it just can return one row result for select
    {
        logerror((COMMON, "mysql_json_conn_t::assemble_select_i fetch more than one row result."));
        return -1;
    } //! else assemable result string

    if (1 == result_num_row)
    {
        if (assemble_select_i(result_set, column_vec, result))
        {
            logerror((COMMON, "mysql_json_conn_t::execute_select failed to assemble select result."));
            return -1;
        } //! else successful to assemable select result and return OK
    }
    else
    {
        result.assign("{}");
    }

    logtrace((COMMON, "mysql_json_conn_t::execute_select end ok <%s>.", result.c_str()));
    return 0;
}

int mysql_json_conn_t::parse_key_i(const string& key, vector<string>& key_vec, bool check_index_max)
{
    logtrace((COMMON, "mysql_json_conn_t::parse_key_i begin ..."));

    try
    {
        //! only can exist "#" "a-zA-Z" "0-9" "'" "_"
        boost::regex reg;
        if (check_index_max)  //! format: 123#object_table#column#value
        {
            reg.assign("[0-9]+#[a-zA-Z0-9_]+(#[a-zA-Z0-9_]+#[a-zA-Z0-9_']+){0, 1}");
        }
        else   //! format: 123#object_table
        {
            reg.assign("[0-9]+#[a-zA-Z0-9_]+");
        }

        if (!boost::regex_match(key, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::parse_key_i json key format is incorrect"));
            return -1;
        } //! else split key to array

        typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
        boost::char_separator<char> separator("#", "", boost::keep_empty_tokens);
        tokenizer tokens(key, separator);

        for (tokenizer::iterator it = tokens.begin(); it != tokens.end(); ++it)
        {
            key_vec.push_back(*it);
        }
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::parse_key_i catch exception <%s> ...", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::parse_key_i end ok."));
    return 0;
}

int mysql_json_conn_t::parse_update_value_i(const string& value, string& columns)
{
    logtrace((COMMON, "mysql_json_conn_t::parse_update_value_i <%s> begin ...", value.c_str()));

    try
    {
        //! string format {"type":"buy","x1":1,"x2":2,"x3":"3"}
        boost::regex reg("^\\{((\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+))),)*(\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+)))\\}$");
        boost::regex replace_reg("(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(,)");
        boost::regex replace_reg2("^\\{((.*),)*(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(\\})$");

        if (!boost::regex_match(value, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::parse_update_value_i update json value format is incorrect"));
            return -1;
        } //! else replace ":"

        columns = boost::regex_replace(value, replace_reg, "`$2`=$4$9");
        columns = boost::regex_replace(columns, replace_reg2, "$1`$4`=$6");
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::parse_update_value_i catch exception: <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::parse_update_value_i end ok <%s><%s>.", value.c_str(), columns.c_str()));
    return 0;
}

int mysql_json_conn_t::parse_insert_value_i(const string& value, string& columns, string& column_values)
{
    logtrace((COMMON, "mysql_json_conn_t::parse_insert_value_i begin <%s>...", value.c_str()));

    try
    {
        //! string format {"type":"buy","x1":1,"x2":2,"x3":"3"}
        boost::regex reg("^\\{((\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+))),)*(\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+)))\\}$");
        boost::regex replace_reg("(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(,)");
        boost::regex replace_reg2("^\\{((.*),)*(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(\\})$");

        if (!boost::regex_match(value, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::parse_insert_value_i update json value format is incorrect"));
            return -1;
        } //! else replace ":"

        columns = boost::regex_replace(value, replace_reg, "`$2`$9");
        columns = boost::regex_replace(columns, replace_reg2, "$1`$4`");
        column_values = boost::regex_replace(value, replace_reg, "$4$9");
        column_values = boost::regex_replace(column_values, replace_reg2, "$1$6");
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::parse_insert_value_i catch exception <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::parse_insert_value_i end ok <%s><%s><%s>.", value.c_str(), columns.c_str(), column_values.c_str()));
    return 0;
}

int mysql_json_conn_t::parse_select_value_i(const string& value, string& columns, vector<string>& column_vec)
{
    logtrace((COMMON, "mysql_json_conn_t::parse_select_value_i <%s> begin ...", value.c_str()));

    try
    {
        //! format: {"type","x1","x2","x3"}
        boost::regex reg("^\\{((\"[a-zA-Z0-9_]+\"),)*(\"[a-zA-Z0-9_]+\")\\}$");
        boost::regex replace_reg("\"");

        if (!boost::regex_match(value, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::parse_select_value_i json value format is incorrect"));
            return -1;
        } //! else replace "{" and "}" with " "
        columns = value.substr(1, value.length() - 2);

        typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
        boost::char_separator<char> separator(",", "", boost::keep_empty_tokens);
        tokenizer tokens(columns, separator);

        for (tokenizer::iterator it = tokens.begin(); it != tokens.end(); ++it)
        {
            column_vec.push_back(*it);
        }

        columns = boost::regex_replace(columns, replace_reg, "`");
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::parse_select_value_i catch exception <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::parse_select_value_i end ok."));
    return 0;
}

int mysql_json_conn_t::assemble_select_i(mysql_res_t& result_set, vector<string>& column_vec, string& result)
{
    logtrace((COMMON, "mysql_json_conn_t::assemble_select_i begin ..."));

    result.assign("{");
    if (mysql_row_t row = result_set.fetch_row())
    {
        column_type_e column_type = COLUMN_UNKNOW;
        for (size_t i = 0; i < column_vec.size(); ++i)
        {
            if (!row[i])
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_i selected columns is empty."));
                result.clear();
                return -1;
            }

            result.append(column_vec[i]);
            result.append(":");

            column_type = result_set.fetch_column_type(i);
            if (COLUMN_STRING == column_type)
            {
                result.append("\"");
                result.append(row[i]);
                result.append("\"");
            }
            else if (COLUMN_NUMERIC == column_type)
            {
                result.append(row[i]);
            }
            else
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_i failed to get column type."));
                result.clear();
                return -1;
            }

            if (i < column_vec.size() - 1)
            {
                result.append(",");
            } //! else no need to append comma
        }
    }
    result.append("}");

    logtrace((COMMON, "mysql_json_conn_t::assemble_select_i end ok."));
    return 0;
}

int mysql_json_conn_t::assemble_select_all_i(mysql_res_t& result_set, const string& key, const string& condition, vector<string>& column_vec, string& result)
{
    logtrace((COMMON, "mysql_json_conn_t::assemble_select_all_i begin ..."));
    if (0 < result_set.fetch_num_rows())
    {
        column_type_e condition_type = result_set.fetch_column_type(condition.c_str());
        if (COLUMN_UNKNOW == condition_type)
        {
            logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get condition type."));
            return -1;
        } //! else continue to get column index
        int condition_index = result_set.get_column_index(condition.c_str());
        if (0 > condition_index)
        {
            logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get condition index."));
            return -1;
        } //! else continue to get all column type
        vector<column_type_e> column_type_vec;
        column_type_e column_type;
        for (size_t i = 0; i < column_vec.size(); ++i)
        {
            column_type = result_set.fetch_column_type(i);
            if (COLUMN_UNKNOW == column_type)
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get column %d type.", i));
                return -1;
            } //! else push column type to vector
            column_type_vec.push_back(column_type);
        }

        result.assign("{");
        mysql_row_t row;
        while ((row = result_set.fetch_row()))
        {
            if (!row[condition_index])
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i selected columns <%s> is empty.", condition.c_str()));
                result.clear();
                return -1;
            } //! else continue to assemable result string

            result.append("\"");
            result.append(key);
            result.append("#");
            result.append(condition);
            result.append("#");
            result.append(row[condition_index]);

            result.append("\":{");

            for (size_t i = 0; i < column_vec.size(); ++i)
            {
                if (!row[i])
                {
                    logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i selected columns <%d> is empty.", i));
                    result.clear();
                    return -1;
                } //! else continue to assemable result string

                result.append(column_vec[i]);
                result.append(":");
                if (COLUMN_STRING == column_type_vec[i])
                {
                    result.append("\"");
                }
                result.append(row[i]);
                if (COLUMN_STRING == column_type_vec[i])
                {
                    result.append("\"");
                }

                if (i < column_vec.size() - 1)
                {
                    result.append(",");
                } //! else no need append comma
            }
            result.append("},");
        }
        result[result.size() - 1] = '}';
    }
    else
    {
        result.assign("{}");
    }

    logtrace((COMMON, "mysql_json_conn_t::assemble_select_all_i end ok."));
    return 0;
}

int mysql_json_conn_t::assemble_select_all_i(mysql_res_t& result_set, const string& key, const string& condition,
                              vector<string>& column_vec, boost::shared_ptr<map<string, string> > result)
{
    logtrace((COMMON, "mysql_json_conn_t::assemble_select_all_i begin ..."));
    if (0 < result_set.fetch_num_rows())
    {
        column_type_e condition_type = result_set.fetch_column_type(condition.c_str());
        if (COLUMN_UNKNOW == condition_type)
        {
            logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get condition type."));
            return -1;
        } //! else continue to get column index
        int condition_index = result_set.get_column_index(condition.c_str());
        if (0 > condition_index)
        {
            logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get condition index."));
            return -1;
        } //! else continue to get all column type
        vector<column_type_e> column_type_vec;
        column_type_e column_type;
        for (size_t i = 0; i < column_vec.size(); ++i)
        {
            column_type = result_set.fetch_column_type(i);
            if (COLUMN_UNKNOW == column_type)
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i failed to get column %d type.", i));
                return -1;
            } //! else push column type to vector
            column_type_vec.push_back(column_type);
        }

        string result_key;
        string result_value;
        mysql_row_t row;
        while ((row = result_set.fetch_row()))
        {
            if (!row[condition_index])
            {
                logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i selected columns <%s> is empty.", condition.c_str()));
                result->clear();
                return -1;
            } //! else continue to assemable result string

            result_key.assign(key);
            result_key.append("#");
            result_key.append(condition);
            result_key.append("#");
            result_key.append(row[condition_index]);

            result_value.assign("{");
            for (size_t i = 0; i < column_vec.size(); ++i)
            {
                if (!row[i])
                {
                    logerror((COMMON, "mysql_json_conn_t::assemble_select_all_i selected columns <%d> is empty.", i));
                    result->clear();
                    return -1;
                } //! else continue to assemable result string

                result_value.append(column_vec[i]);
                result_value.append(":");
                if (COLUMN_STRING == column_type_vec[i])
                {
                    result_value.append("\"");
                }
                result_value.append(row[i]);
                if (COLUMN_STRING == column_type_vec[i])
                {
                    result_value.append("\"");
                }

                if (i < column_vec.size() - 1)
                {
                    result_value.append(",");
                } //! else no need append comma
            }
            result_value.append("}");

            (*result)[result_key] = result_value;
        }
    }

    logtrace((COMMON, "mysql_json_conn_t::assemble_select_all_i end ok."));
    return 0;
}

int mysql_json_conn_t::check_condition_format(const string& condition)
{
    logtrace((COMMON, "mysql_json_conn_t::check_condition_format <%s> begin ...", condition.c_str()));

    try
    {
        boost::regex reg("[^,^*]+");

        if (!boost::regex_match(condition, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::check_condition_format json condition format is incorrect"));
            return -1;
        } //! else match and return OK
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::check_condition_format catch exception <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::check_condition_format end ok."));
    return 0;
}

bool mysql_json_conn_t::check_column_exist_i(const string& column, const string& columns)
{
    logtrace((COMMON, "mysql_json_conn_t::check_column_exist_i begin ..."));

    try
    {
        boost::format fmt("(^`%s`$)|(^`%s`,)|(, `%s`,)|(,`%s`,)|(,`%s`$)|(, `%s`$)");
        fmt % column.c_str();
        fmt % column.c_str();
        fmt % column.c_str();
        fmt % column.c_str();
        fmt % column.c_str();
        fmt % column.c_str();
        boost::regex reg(fmt.str());

        if (!boost::regex_search(columns, reg))
        {
            return false;
        } //! else find and return OK
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::check_column_exist_i catch exception <%s>", e.what()));
        return false;
    }

    logtrace((COMMON, "mysql_json_conn_t::check_column_exist_i end ok."));
    return true;
}

int mysql_json_conn_t::parse_select_conditions_i(const string& conditions, string& condition_sql)
{
    logtrace((COMMON, "mysql_json_conn_t::parse_select_conditions_i <%s> begin ...", conditions.c_str()));

    try
    {
        //! string format {"type":"buy","x1":1,"x2":2,"x3":"3"}
        //! the result format: AND `type`="buy" AND `x1`=1 AND `x2`=2 AND `x3`="3"
        boost::regex reg("^\\{((\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+))),)*(\"[a-zA-Z0-9_]+\":((\"([^\"]|(\\\"))*?\")|([0-9]+)))\\}$");
        boost::regex replace_reg("(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(,)");
        boost::regex replace_reg2("^\\{((.*) AND )*(\")([a-zA-Z0-9_]+)(\"):((\"([^\"]|(\\\"))*?\")|([0-9]+))(\\})$");

        if (!boost::regex_match(conditions, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::parse_select_conditions_i update json value format is incorrect"));
            return -1;
        } //! else replace ":"

        condition_sql = boost::regex_replace(conditions, replace_reg, "`$2`=$4 AND ");
        condition_sql = boost::regex_replace(condition_sql, replace_reg2, "$1`$4`=$6");
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::parse_select_conditions_i catch exception: <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::parse_select_conditions_i end ok <%s>.", condition_sql.c_str()));
    return 0;
}

int mysql_json_conn_t::check_order_by_format_i(const string& order_by)
{
    logtrace((COMMON, "mysql_json_conn_t::check_order_by_format_i <%s> begin ...", order_by.c_str()));

    try
    {
        //! string format c1,c2 asc/desc
        boost::regex reg("^[A-Za-z0-9_, ]+(( asc)|( desc)){0,1}$");

        if (!boost::regex_match(order_by, reg))
        {
            logerror((COMMON, "mysql_json_conn_t::check_order_by_format_i order by string format is incorrect"));
            return -1;
        }
    }
    catch (const exception& e)
    {
        logerror((COMMON, "mysql_json_conn_t::check_order_by_format_i catch exception: <%s>", e.what()));
        return -1;
    }

    logtrace((COMMON, "mysql_json_conn_t::check_order_by_format_i end ok."));
    return 0;
}

