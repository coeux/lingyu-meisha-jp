#include "login_service.h"
#include "log.h"

#define LOGIN "LOGIN"

login_service_t::login_service_t():rpc_server_t(*singleton_t<thread_pool_t>::instance().poll_io()) 
//login_service_t::login_service_t():rpc_server_t(4, "login_service_t")
{
    reg_call(CMD_LOGIN, &login_service_t::on_login);
}
login_service_t::~login_service_t()
{
}
void login_service_t::on_login(sp_rpc_conn_t conn_, rq_login_t& rq_)
{
    logtrace((LOGIN, "user login! id:%lu, name:%s, level:%d!", rq_.id, rq_.name.c_str(), rq_.level));
    ret_login_t ret;
    ret.id = rq_.id;
    ret.success = true;
    async_call(conn_, CMD_LOGIN, ret);
}
void login_service_t::on_broken(sp_rpc_conn_t conn_)
{
}
