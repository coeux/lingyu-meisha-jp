#ifndef _REMOTE_INFO_H_
#define _REMOTE_INFO_H_

#include <string>
using namespace std;

enum remote_type_e
{
    REMOTE_UNKNOWN  = 0,
    REMOTE_ROUTE    = 1,
    REMOTE_LOGIN    = 2,
    REMOTE_GW       = 3,
    REMOTE_SCENE    = 4,
    REMOTE_DB       = 5,
    REMOTE_INVCODE  = 6,
    REMOTE_ALL      = 7,
};

struct remote_info_t
{
    bool is_client;
    //如果是客户端，则remote_id为用户id
    //如果是服务器, remote_id=(uint32_t)(server_type<<16|server_id)
    uint64_t remote_id;
    uint32_t trans_id;
    bool verified;
    string deckey;
    uint32_t heart_stamp;

    remote_info_t():is_client(false),remote_id(0),trans_id(0),verified(false),heart_stamp(0)
    {
    }

    bool is_server(uint16_t type_)
    {
        return (((uint32_t)remote_id)>>16) == type_;
    }

    uint16_t sertype()
    {
        return (((uint32_t)remote_id)>>16);
    }

    uint16_t serid()
    {
        if (!is_client)
        {
            return remote_id; 
        }
        return 0;
    }
};

#define MAKE_SID(remote_, serid_) (((uint32_t)remote_)<<16 | serid_)

#endif
