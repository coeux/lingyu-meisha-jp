#ifndef _91MSG_DEF_H_
#define _91MSG_DEF_H_

#include "jserialize_macro.h"

//91登陆时客户端提交的信息
struct login91_info_t
{
    string AppID;
    string Uin;
    string SessionID;

    JSON3(login91_info_t, AppID, Uin, SessionID)
};

struct verfiy91_ret_t
{
    string ErrorCode;
    string ErrorDesc;
    JSON2(verfiy91_ret_t, ErrorCode, ErrorDesc)
};

struct pay91_t
{
    string AppID;
    string Uin;
    JSON2(pay91_t, AppID, Uin)
};

struct nt_91pay_ok_t
{
    string AppID;
    string Uin;
    string serid;
    int goodsid;
    int goodsnum;
    JSON5(nt_91pay_ok_t, AppID, Uin, serid, goodsid, goodsnum)
};

#endif
