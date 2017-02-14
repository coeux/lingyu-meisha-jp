#ifndef _SQL_RESULT_H_
#define _SQL_RESULT_H_

#include <stdint.h>

#include <string>
#include <vector>
using namespace std;

#include "ys_mysql.h"

class sql_result_row_t
{
public:
    sql_result_row_t();
    ~sql_result_row_t();

    size_t affect_column_num() const;

    string get_value_at(size_t idx_);

    //! 添加新字段值到result中
    void append_field(const string& val_);

    //! 输出所有数据
    void dump();

    bool empty() { return m_field_values.empty(); }
    string& operator[](const size_t& i_){ return m_field_values[i_]; }
    void clear() {m_field_values.clear();}
private:
    vector<string>  m_field_values;
};

class sql_result_t
{
public:
    sql_result_t();
    ~sql_result_t();

    int set_mysql_result(mysql_res_t& result_);
    int clear_mysql_result();

    size_t affect_row_num() const;
    size_t affect_column_num() const;

    sql_result_row_t* get_row_at(size_t idx_);

    void dump();
private:
    vector<sql_result_row_t>    m_result_rows;
};

#endif
