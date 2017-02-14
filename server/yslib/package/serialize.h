#ifndef _SERIALIZE_H_
#define _SERIALIZE_H_

#include <string.h>
#include <vector>
#include <string>
using namespace std;

#include <iostream>
using namespace std;

namespace ys 
{
template<typename T>
void write(string& stream_, const T& v_)
{
    //cout << "1.append:" << sizeof(T) << endl;
    stream_.append(string((const char*)&v_, sizeof(T)));
}
void write(string& stream_, const string& v_);

template<typename T, typename... Args>
void serialize(string& stream_, const T& v_, const Args&... args_)
{
    //cout << "serialize..." << sizeof...(Args) << endl;
    write(stream_, v_);
    serialize(stream_, args_...);
}
//最后模板参数都解包结束后会调用这个函数
void serialize(string& stream_);

//===========================================================
template<typename T>
size_t read(bool check_, const char* stream_, T& v_)
{
    memcpy(&v_, stream_, sizeof(T));
    return sizeof(T);
}

size_t read(bool check_, const char* stream_, string& v_);

template<typename T, typename... Args>
void deserialize(bool check_, const char* stream_, T& v_, Args&... args_)
{
    deserialize(stream_ + read(check_, stream_, v_), args_...);
}
//最后模板参数都打包结束后会调用这个函数
void deserialize(bool check_, const char* stream_);
}
#endif
