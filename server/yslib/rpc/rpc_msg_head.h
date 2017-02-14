
#ifndef _RPC_MSG_HEAD_H_
#define _RPC_MSG_HEAD_H_

#include <string.h>
#include <string>
using namespace std;

struct rpc_msg_i
{
    virtual ~rpc_msg_i(){}
    virtual string encode(uint16_t cmd_) const= 0;
    virtual int    decode(const string& srd_) = 0;
};

struct rpc_msg_head_t
{
    uint32_t len;      //! the msg length
    uint16_t cmd;      //! the msg command
    uint16_t res;      //! 0: failed : 1, success

    rpc_msg_head_t()
    {
        memset(this , 0, sizeof(rpc_msg_head_t));
    }

    rpc_msg_head_t(uint16_t cmd_) : len(0), cmd(cmd_)
    {
        //! Empty
    }

    rpc_msg_head_t(uint32_t len_, uint16_t cmd_) : len(len_), cmd(cmd_)
    {
        //! Empty
    }

    rpc_msg_head_t(uint32_t len_, uint16_t cmd_, uint16_t res_)
        : len(len_), cmd(cmd_), res(res_)
    {
        //! Empty
    }
};

#endif //! _RPC_MSG_HEAD_H_

