#include "serialize.h"
#include "package_exception.h"

namespace ys
{
void write(string& stream_, const string& v_)
{
    //cout << "serialize:write string len:" << v_.size() << endl;
    write(stream_, (uint16_t)v_.size());
    stream_.append(v_);
}
void serialize(string& stream_)
{
}
size_t read(bool check_, const char* stream_, string& v_)
{
    uint16_t len = 0;
    stream_ += read(check_, stream_, len); 
    //cout << "serialize:read string len:" << len << endl;
    if (check_ && len > 8192)
    {
        throw package_exception_t("package serialize read:illegal string len > 8192");
    }
    v_.append(string(stream_, len));
    return (len + sizeof(uint32_t));
}
void deserialize(const char* stream_)
{
    //cout << "deserialize end" << endl;
}
}
