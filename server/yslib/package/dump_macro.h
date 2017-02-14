#ifndef _DUMP_MACRO_H_
#define _DUMP_MACRO_H_

#include "dump.h"

#define D1(v1)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    info_.append("}");\
}
#define D2(v1, v2)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    info_.append("}");\
}
#define D3(v1, v2, v3)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    info_.append("}");\
}
#define D4(v1, v2, v3, v4)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    info_.append("}");\
}
#define D5(v1, v2, v3, v4, v5)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    ys::dumpv(info_, #v5, v5);\
    info_.append("}");\
}
#define D6(v1, v2, v3, v4, v5, v6)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    ys::dumpv(info_, #v5, v5);\
    ys::dumpv(info_, #v6, v6);\
    info_.append("}");\
}
#define D7(v1, v2, v3, v4, v5, v6, v7)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    ys::dumpv(info_, #v5, v5);\
    ys::dumpv(info_, #v6, v6);\
    ys::dumpv(info_, #v7, v7);\
    info_.append("}");\
}
#define D8(v1, v2, v3, v4, v5, v6, v7, v8)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    ys::dumpv(info_, #v5, v5);\
    ys::dumpv(info_, #v6, v6);\
    ys::dumpv(info_, #v7, v7);\
    ys::dumpv(info_, #v8, v8);\
    info_.append("}");\
}
#define D9(v1, v2, v3, v4, v5, v6, v7, v8, v9)\
void dump(string& info_)\
{\
    info_.append("{");\
    ys::dumpv(info_, #v1, v1);\
    ys::dumpv(info_, #v2, v2);\
    ys::dumpv(info_, #v3, v3);\
    ys::dumpv(info_, #v4, v4);\
    ys::dumpv(info_, #v5, v5);\
    ys::dumpv(info_, #v6, v6);\
    ys::dumpv(info_, #v7, v7);\
    ys::dumpv(info_, #v8, v8);\
    ys::dumpv(info_, #v9, v9);\
    info_.append("}");\
}

#endif
