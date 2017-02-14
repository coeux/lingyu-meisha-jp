#ifndef _rt_public_service_h_
#define _rt_public_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"

class rt_public_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    rt_public_handler_t(io_t& io_);
    ~rt_public_handler_t();
private:
    //客户端断开
    void on_broken(sp_rpc_conn_t conn_);
    //请求分配网关 
    void on_req_gw(sp_rpc_conn_t conn_, rt_msg_def::req_gw_t& jpk_);
};

class rt_public_service_t : public service_base_t<rt_public_handler_t>
{
public:
    rt_public_service_t();

    uint32_t sid() {  return m_sid; }

    void start(uint16_t serid_, string ip_, string port_);
private:
    bool                m_started;
    uint32_t            m_sid;
};

#define rt_public_service (singleton_t<rt_public_service_t>::instance())

#endif
