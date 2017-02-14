#include "dump.h"

namespace ys
{
void dumpv(string& info_, const char* name_, int v_)
{
    info_.append(name_);
    info_.append(":");
    char buff[256];
    sprintf(buff, "%d", v_);
    info_.append(buff);
    info_.append(";");
}
void dumpv(string& info_, const char* name_, uint64_t v_)
{
    info_.append(name_);
    info_.append(":");
    char buff[256];
    sprintf(buff, "%lu", v_);
    info_.append(buff);
    info_.append(";");
}
void dumpv(string& info_, const char* name_, float v_)
{
    info_.append(name_);
    info_.append(":");
    char buff[256];
    sprintf(buff, "%f", v_);
    info_.append(buff);
    info_.append(";");
}
void dumpv(string& info_, const char* name_, string& v_)
{
    info_.append(name_);
    info_.append(":");
    info_.append(v_);
    info_.append(";");
}
}
