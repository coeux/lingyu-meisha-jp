#include "echo_service.h"
#include "log.h"

#define LOGIN "LOGIN"

echo_service_t::echo_service_t(io_t& io_):rpc_t(io_)
{
    reg_call(&echo_service_t::on_echo);
}
echo_service_t::~echo_service_t()
{
    m_conn_set.clear();
}
void echo_service_t::on_echo(sp_rpc_conn_t conn_, req_echo_t& jpk_)
{
    logtrace(("ECHO", "用户:%lu, msg:%s", jpk_.uid, jpk_.msg.c_str()));
    /*
    m_conn_set.insert(conn_);
    string str = msg_.msg;
    for(int i=0; i<2; i++)
    {
        msg_.msg.append(str);
    }
    */
    async_call(conn_, jpk_);
}
void echo_service_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn(("ECHO", "user broken!"));
}
