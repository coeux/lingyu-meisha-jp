#ifndef _DUMP_H_
#define _DUMP_H_

#include <string>
#include <vector>
using namespace std;

namespace ys
{
template<class T>
void dumpv(string& info_, const char* name_, T& v_)
{
    info_.append(name_);
    info_.append(":");
    v_.dump(info_);
}
void dumpv(string& info_, const char* name_, int v_);
void dumpv(string& info_, const char* name_, uint64_t v_);
void dumpv(string& info_, const char* name_, float v_);
void dumpv(string& info_, const char* name_, string& v_);

template<class T>
void dumpv(string& info_, const char* name_, vector<T>& v_)
{
    info_.append(name_);
    info_.append(":");
    info_.append("[");
    size_t i=0;
    for(auto iter = v_.begin(); iter != v_.end();)
    {
        char buff[256];
        sprintf(buff, "%lu", i++);
        dumpv(info_, buff, *iter); 
        iter++;
        if (iter != v_.end())
            info_.append(", ");
    }
    info_.append("]");
    info_.append(";");
}

class formater_t
{
    int m_indent_n;
public:
    formater_t(string& content_):m_indent_n(0) 
    {
        proc(content_);
    }
    void proc(string& content_)
    {
        for(size_t i=0; i<content_.size(); i++)
        {
            if (content_[i] == '{')
            {
                m_indent_n++;
                continue;
            }
            else
            {
                m_indent_n++;
            }
        }
    }
};
}

#endif
