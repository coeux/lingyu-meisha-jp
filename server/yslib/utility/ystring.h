#ifndef _ystring_h_
#define _ystring_h_

#include "yarray.h"
#include <string.h>

template<size_t Len>
struct ystring_t
{
    const size_t cap() { return Len; }
    char contain[Len+1] = {0};
    size_t len = 0;

    ystring_t() { }
    ystring_t(const char* str_, size_t size_) { 
        assign(str_, size_);
    }
    ystring_t(const std::string& str_):ystring_t(str_.c_str(), str_.size()){}
    ystring_t(const ystring_t& str_)
    {
        assign(str_.contain, str_.len);
    }

    ystring_t& operator=(const char* str_)
    {
        assign(str_, strlen(str_));
        return *this;
    }

    void assign(const char* str_, size_t size_)
    {
        if (size_ > Len) size_ = Len;
        memcpy(contain, str_, size_);
        contain[size_+1] = '\0';
        len = size_;
    }

    std::string operator()() 
    {
        return string(contain, len);
    }

    char& operator[](size_t i_)
    {
        return contain[i_];
    }

    const char* c_str() const { return contain; } 

    size_t length() { return len;} 

    size_t size() { return len; }

    bool empty() { return len == 0; }

    void append(size_t off_, char c_)
    {
        if (len+off_ > Len)
            return;

        memset(contain+len, c_, off_);
        len += off_;
    }
};

#endif
