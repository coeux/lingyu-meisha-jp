#ifndef _RPC_UTILITY_H_
#define _RPC_UTILITY_H_

#include "zlib_util.h"
#include "rpc_msg_head.h"

#define ZLIB_FLAG_MASK   0x8000

struct rpc_msg_util_t
{
    static size_t ZLIB_SIZE_LIMIT; 
    static bool opened;
    static uint16_t cmd_filter[65535];

    static string compress_msg(uint16_t cmd, const string& data_);
    static string make_msg(uint16_t cmd, const string& data_);

    static string bin_msg(uint16_t cmd, void* data_, uint32_t size_)
    {
        rpc_msg_head_t msg_head;
        msg_head.cmd = cmd;
        msg_head.len = size_;
        string msg((const char*)&msg_head, sizeof(msg_head));
        if (size_ > 0)
            msg.append((const char*)data_, size_);
        return msg;
    }
    
    static string compress_msg(const string& src_msg_)
    {
        if (!opened)
            return src_msg_;

        if (src_msg_.size() < ZLIB_SIZE_LIMIT + sizeof(rpc_msg_head_t))
        {
            return src_msg_;
        }
        else
        {
            string zlib_msg(src_msg_.c_str(), sizeof(rpc_msg_head_t));
            string tmp_dest;
            string tmp_src(src_msg_.c_str() + sizeof(rpc_msg_head_t), src_msg_.size() - sizeof(rpc_msg_head_t));
            zlib_util_t::compress(tmp_src, tmp_dest);
            zlib_msg += tmp_dest;
            rpc_msg_head_t* p = (rpc_msg_head_t*)(zlib_msg.data());
            p->len = tmp_dest.size();
            p->res = (p->res | ZLIB_FLAG_MASK);
            return zlib_msg;
        }
    }
    
    static string uncompress_msg(uint16_t res_, const string& src_)
    {
        if (!opened)
            return src_;

        if (res_ & ZLIB_FLAG_MASK)
        {
            string tmp_dest;
            zlib_util_t::uncompress(src_, tmp_dest);
            return tmp_dest;
        }
        return src_;
    }
};

#endif
