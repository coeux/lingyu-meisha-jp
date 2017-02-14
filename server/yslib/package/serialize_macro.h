#ifndef _SERIALIZE_MACRO_H_
#define _SERIALIZE_MACRO_H_

#include "package.h"
#include "serialize.h"

#define out cout

#define S1(v1)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1);\
}

#define S2(v1, v2)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2);\
}

#define S3(v1, v2, v3)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3);\
}

#define S4(v1, v2, v3, v4)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4);\
}

#define S5(v1, v2, v3, v4, v5)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4, v5);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4, v5);\
}

#define S6(v1, v2, v3, v4, v5, v6)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4, v5, v6);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4, v5, v6);\
}

#define S7(v1, v2, v3, v4, v5, v6, v7)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4, v5, v6, v7);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4, v5, v6, v7, v8);\
}

#define S8(v1, v2, v3, v4, v5, v6, v7, v8)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4, v5, v6, v7, v8);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4, v5, v6, v7, v8);\
}

#define S9(v1, v2, v3, v4, v5, v6, v7, v8, v9)\
void operator>>(ys::package_t& p_)\
{\
    p_.pack(v1, v2, v3, v4, v5, v6, v7, v8, v9);\
}\
void operator<<(ys::package_t& p_)\
{\
    p_.unpack(v1, v2, v3, v4, v5, v6, v7, v8, v9);\
}

#endif
