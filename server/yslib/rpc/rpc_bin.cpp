#include "rpc_bin.h"
#include "rpc_common_conn_protocol.h"
#include "rpc_utility.h"
#include "rpc_log_def.h"
#include "log.h"


rpc_bin_t::rpc_bin_t(io_t& io_):rpc_common_conn_protocol_t(io_)
{
}
int rpc_bin_t::async_send(sp_rpc_conn_t conn_, uint16_t cmd_, void* body_, uint32_t size_)
{
    conn_->async_send(std::move(rpc_msg_util_t::bin_msg(cmd_, body_, size_)));
    return 0;
}
