#include "rt_public_service.h"
#include "log.h"
#include "code_def.h"
#include "remote_info.h"
#include "config.h"
#include "seskey_assign.h"
#include "config.h"

#include "rt_private_service.h"

#define LOG "RT_PUBLIC" 

rt_public_handler_t::rt_public_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&rt_public_handler_t::on_req_gw);
}
rt_public_handler_t::~rt_public_handler_t()
{
}
void rt_public_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
    {
        logwarn((LOG, "unknown client broken!"));
        return;
    }
    logwarn((LOG, "client broken! uid:%lu", info->remote_id));
    rt_public_service.del_client(info->remote_id);
}
void rt_public_handler_t::on_req_gw(sp_rpc_conn_t conn_, rt_msg_def::req_gw_t& jpk_)
{
    inner_msg_def::jpk_gw_info_t* gw = rt_private_service.assgin_gw();
    if (gw == NULL)
    {
        logerror((LOG, "assign gw failed!"));
        conn_->close();
        return;
    }

    rt_msg_def::ret_gw_t ret;
    ret.seskey = singleton_t<seskey_assign_t>::instance().new_seskey(gw->serid);
    ret.ip = gw->ip;
    ret.port = gw->port;
    async_call(conn_, ret);
    //conn_->close();
}
//==========================================================
rt_public_service_t::rt_public_service_t():
    service_base_t<rt_public_handler_t>(rt_private_service.get_io()),
    m_started(false),
    m_sid(0)
{
}
void rt_public_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start route public service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_ROUTE<<16)|serid_; 
    
    listen(ip_, port_, true);

    logwarn((LOG, "start route public service ok! serid:%u", serid_));
}
