#ifndef _MSG_DEF_H_
#define _MSG_DEF_H_

#include "serialize_macro.h"
#include "dump_macro.h"

enum msg_cmd_e
{
    CMD_LOGIN = 1000,
    CMD_ECHO = 2000,
};

struct player_info_t
{
    uint64_t id;
    string   name;
    float    atk;
    float    defs;
    S4(id, name, atk, defs)
};

struct rq_login_t
{
    uint64_t    id;
    string      name;
    int         level;
    float       time;
    vector<uint64_t> uids;
    vector<player_info_t> infos;

    S6(id, name, level, time, uids, infos)
};

struct ret_login_t
{
    uint64_t id;
    bool success;
    S2(id, success)
};

struct msg_echo_t
{
    uint64_t uid;
    string msg;
    S2(uid, msg)
};

#endif
