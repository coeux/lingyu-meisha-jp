#ifndef _PACKAGE_H_
#define _PACKAGE_H_

#include <string>
using namespace std;

#include "serialize.h"

namespace ys 
{
class package_t : public string
{
public:
    package_t(bool check_=false):m_read_pos(0),m_check(check_){}
    package_t(const string& buff_, bool check_=false):string(buff_),m_read_pos(0), m_check(check_) {}

    template<class T, class... Args>
    void pack(T& v_, Args&... args_)
    {
        ////cout << "pack..." << sizeof...(Args) << endl;
        *this << v_;
        pack(args_...);
    }

    template<class T, class... Args>
    void unpack(T& v_, Args&... args_)
    {
        *this >> v_;
        unpack(args_...);
    }

    void reset()
    {
        m_read_pos = 0;
        clear();
    }
private:
    template<class T>
    package_t& operator<<(T& v_)
    {
        v_ >> *this;
        return *this;
    }

    package_t& operator<<(bool& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(int& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(uint64_t& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(uint32_t& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(uint16_t& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(float& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    package_t& operator<<(string& v_)
    {
        ////cout << "pack:" << v_ << endl;
        write(*(string*)this, v_);
        return *this;
    }

    template<class T>
    package_t& operator<<(vector<T>& v_)
    {
        ////cout << "pack vector size:" << v_.size() << endl;
        write(*(string*)this, (uint16_t)v_.size());
        for(auto iter = v_.begin(); iter != v_.end(); iter++)
            *this << *iter;
        return *this;
    }

    template<class T>
    package_t& operator>>(T& v_)
    {
        v_ << *this;
        return *this;
    }

    package_t& operator>>(bool& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(int& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(uint64_t& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(uint32_t& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(uint16_t& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(float& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    package_t& operator>>(string& v_)
    {
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, v_);
        //cout << "unpack:" << v_ << endl;
        return *this;
    }

    template<class T>
    package_t& operator>>(vector<T>& v_)
    {
        //cout << "unpack vector size:" << v_.size() << endl;
        uint16_t size = 0;
        m_read_pos += read(m_check, ((string*)this)->c_str() + m_read_pos, size);
        for(uint16_t i=0; i<size; i++)
        {
            T v;
            *this >> v;
            v_.push_back(v);
        }
        return *this;
    }

    void pack()     { /*//cout << "pack end" << endl;*/  }
    void unpack()   { /*unpack end;*/ }
private:
    size_t m_read_pos;
    bool m_check;
};
}

#endif
