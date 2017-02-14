#ifndef _db_smart_up_h_
#define _db_smart_up_h_

#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>
#include <string>
#include <set>
#include <unordered_map>
using namespace std;

#include "ystring.h"

struct mem_wrap_i
{
    string kn;
    mem_wrap_i(const string& kn_):kn(kn_){}
    virtual string to_str() = 0;
    virtual bool is_number() = 0;
};

template<class T>
struct mem_wrap_t : public mem_wrap_i
{
    T* v;
    mem_wrap_t(T* v_, const string& kn_):mem_wrap_i(kn_), v(v_){ }
    bool is_number() { return true; }
    string to_str()
    {
        return std::to_string(*v);
    }
};
template<>
struct mem_wrap_t<string> : public mem_wrap_i
{
    string* v;
    mem_wrap_t(string* v_, const string& kn_):mem_wrap_i(kn_), v(v_){ }
    bool is_number() { return false; }
    string to_str()
    {
        return *v;
    }
};
template<size_t N>
struct mem_wrap_t<ystring_t<N>> : public mem_wrap_i
{
    ystring_t<N>* v;
    mem_wrap_t(ystring_t<N>* v_, const string& kn_):mem_wrap_i(kn_),v(v_) { }
    bool is_number() { return false; }
    string to_str()
    {
        return (*v)();
    }
};

#define REG_MEM(t,n)\
    {mem_map[(void*)(&(n))] = boost::shared_ptr<mem_wrap_t<t>>(new mem_wrap_t<t>(&(n),#n));}

#define DEC_SET(t, n)\
    void set_##n(const t& n##_)\
    {\
        n = n##_;\
        update_set.insert((void*)(&(n)));\
    }

class db_smart_up_t 
{
protected:
    typedef boost::shared_ptr<mem_wrap_i> sp_mem_wrap_i;
    set<void*> update_set;
    unordered_map<void*,sp_mem_wrap_i> mem_map;
public:
    db_smart_up_t(){}
    virtual ~db_smart_up_t() {}

    bool has_changed()
    {
        return !update_set.empty();
    }

    string gen_up_sql(const string& format_)
    {
        string sql;

        size_t i=0;
        for(auto it=update_set.begin(); it!=update_set.end(); it++)
        {
            sp_mem_wrap_i& wrap = mem_map[*it];

            sql.append(wrap->kn);
            sql.append("=");
            if (wrap->is_number())
                sql.append(wrap->to_str());
            else
            {
                sql.append("'");
                sql.append(wrap->to_str());
                sql.append("'");
            }
            if (++i < update_set.size())
                sql.append(",");
        }
        update_set.clear();

        boost::format format(format_);
        format % sql;
        return format.str();
    }
};

/*
class db_UserData_ext_t :  public db_UserData_t, db_smart_up_t
{
    db_UserData_ext_t()
    {
        REG_MEM(uint32_t, uid)
        REG_MEM(string, nickname)
        REG_MEM(uint16_t, grade)
    }

    DEC_SET(uint32_t, uid)
};

//db_UserData_t db;
db_UserData_ext_t db; 

//db.grade = 112;
db.set_grade(112);
....

void save_db()
{
    string sql = db.gen_update_sql();
    db_service.async(uid, [](const string& sql_){
        db_service.async_exec(sql);
    }, sql)
}

save_db();
*/

#endif
