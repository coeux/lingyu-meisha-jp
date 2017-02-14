#include "rpc_utility.h"

#ifdef USE_TBB_MALLOC

#include <tbb/scalable_allocator.h>

#endif

size_t rpc_msg_util_t::ZLIB_SIZE_LIMIT = 1024; 
bool rpc_msg_util_t::opened = false;
uint16_t rpc_msg_util_t::cmd_filter[65535] = {0};

string rpc_msg_util_t::compress_msg(uint16_t cmd, const string& data_)
{
    rpc_msg_head_t msg_head;
    msg_head.cmd = cmd;
    msg_head.len = data_.size();
    string msg((const char*)&msg_head, sizeof(msg_head));

    if (data_.size() < ZLIB_SIZE_LIMIT || !opened || cmd_filter[cmd])
    {
        msg.append(data_);
        return msg;
    }
    else
    {
        char* tmp_dest;
        //zlib_util_t::compress(data_, tmp_dest);
        int len = zlib_util_t::compress((char*)data_.c_str(), data_.size(), &tmp_dest);
        if (len <= 0)
            msg.append(data_);
        else
        {
            msg.append(tmp_dest, len);
#ifdef USE_TBB_MALLOC
            scalable_free(tmp_dest);
#else
            free(tmp_dest);
#endif
            rpc_msg_head_t* p = (rpc_msg_head_t*)(msg.data());
            p->len = len;
            p->res = (p->res | ZLIB_FLAG_MASK);
        }
        return msg;
    }
}

string rpc_msg_util_t::make_msg(uint16_t cmd, const string& data_)
{
    rpc_msg_head_t msg_head;
    msg_head.len = data_.size();
    msg_head.cmd = cmd;
    string msg((const char*)&msg_head, sizeof(msg_head));
    msg.append(data_);
    return msg;
}
