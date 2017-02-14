#include "rpc.h"
#include "rpc_common_conn_protocol.h"
#include "rpc_utility.h"
#include "rpc_log_def.h"
#include "log.h"

#include <stdexcept>
using namespace std;

rpc_t::rpc_t(io_t& io_):rpc_common_conn_protocol_t(io_)
{
}
void rpc_t::handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_)
{
#ifdef USE_PERF
    char buff[128];
    sprintf(buff, "rpc_t::handle_msg, cmd:%d", cmd_);
    PERFORMANCE_GUARD(buff);
#endif

    logtrace((RPC, "handle_msg...,flag:%d, cmd:%u, res:%d, body size:%lu", flag_, cmd_, res_, body_.size()));
    if (flag_ == 0)
    {
        on_broken(conn_);
        return;
    }
    auto it = m_calls.find(cmd_);
    if (it != m_calls.end())
    {
        if (!it->second->happen(this, cmd_, body_, conn_))
        {
            logerror((RPC, "handle_msg...failed,unpack exception! cmd:%u, body:%s, connecter will be SHUTDOWN", cmd_, body_.c_str()));
            conn_->close(RPC_SHUTDOWN);
            return;
        }
        logtrace((RPC, "handle_msg...ok,call cmd:%u", cmd_));
        return;
    }
    //如果返回非0,则关闭当前链接
    if (0!=on_unknown_msg(cmd_, body_, conn_))
    {
        logerror((RPC, "handle_msg...failed,unknown cmd:%u, connecter will be SHUTDOWN", cmd_));
        conn_->close(RPC_SHUTDOWN);
        string all_cmd;
        for(auto it=m_calls.begin(); it!=m_calls.end(); it++)
        {
            char buf[8]; sprintf(buf, "%u", it->first);
            all_cmd.append(buf);
            all_cmd.append(",");
        }
        logwarn((RPC, "handle_msg...failed,unknown cmd:%u, body:%s, all_cmd[%s]", cmd_, body_.c_str(), all_cmd.c_str()));
    }
}
int rpc_t::async_send(sp_rpc_conn_t conn_, uint16_t cmd_, const string& body_)
{
    conn_->async_send(std::move(rpc_msg_util_t::make_msg(cmd_, body_)));
    return 0;
}
