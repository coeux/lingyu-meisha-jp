#include "sql_result.h"
#include "db_log_def.h"

sql_result_row_t::sql_result_row_t()
{
}

sql_result_row_t::~sql_result_row_t()
{
}

string sql_result_row_t::get_value_at(size_t idx_)
{
    if (idx_ >= m_field_values.size())
    {
        return "";
    }

    return m_field_values[idx_];
}

size_t sql_result_row_t::affect_column_num() const
{
    return m_field_values.size();
}

void sql_result_row_t::append_field(const string& val_)
{
    m_field_values.push_back(val_);
}

void sql_result_row_t::dump()
{
    string ret = "<";
    for (size_t i =0 ; i < m_field_values.size(); ++i)
    {
        ret += m_field_values[i] + " ";
    }
    ret += ">";
    logdebug((DB_SQL_RES, "dump row_data=%s", ret.c_str()));
}

sql_result_t::sql_result_t()
{
}

sql_result_t::~sql_result_t()
{
}

int sql_result_t::set_mysql_result(mysql_res_t& result_)
{
    mysql_row_t row;
    unsigned int column_num = result_.fetch_num_columns();
    unsigned long row_num   = result_.fetch_num_rows();
    m_result_rows.resize(row_num);

    row = result_.fetch_row();
    for (unsigned long row_i = 0; row_i < row_num && row; ++row_i, row = result_.fetch_row())
    {
        for(unsigned int i = 0; i < column_num; ++i)
        {
            if (!row[i])
            {
                logerror((DB_SQL_RES, "set_mysql_result failed whend check row"));
                return -1;
            }
            m_result_rows[row_i].append_field(row[i]);
        }
    }
    return 0;
}

int sql_result_t::clear_mysql_result()
{
    m_result_rows.clear();
    return 0;
}

size_t sql_result_t::affect_row_num() const
{
    return m_result_rows.size();
}

size_t sql_result_t::affect_column_num() const
{
    if (m_result_rows.empty())
    {
        return 0;
    }
    return m_result_rows[0].affect_column_num();
}

void sql_result_t::dump()
{
    logdebug((DB_SQL_RES, "dump begin..."));
    vector<sql_result_row_t>::iterator it = m_result_rows.begin();
    for (; it != m_result_rows.end(); ++it)
    {
        it->dump();
    }
    logdebug((DB_SQL_RES, "dump end ok"));
}

sql_result_row_t* sql_result_t::get_row_at(size_t idx_)
{
    if (idx_ >= m_result_rows.size())
    {
        return NULL;
    }

    return &(m_result_rows[idx_]);
}
