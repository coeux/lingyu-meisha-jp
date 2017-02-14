#include "gw_rt_client.h"
#include "msg_def.h"
#include "remote_info.h"
#include "code_def.h"
#include "gw_public_service.h"

#define LOG "GW_RT_CLIENT"

gw_rt_handler_t::gw_rt_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&gw_rt_handler_t::on_ret_regist);
}
void gw_rt_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "route broken! serid:%u", info->serid()));
    if (m_client != NULL)
    {
        m_client->set_registed(false);
        m_client->start_timer();
    }
}
void gw_rt_handler_t::on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_)
{
    if (jpk_.code == SUCCESS)
    {
        logwarn((LOG, "regist route ok! route id:%d", (uint16_t)jpk_.sid));
        remote_info_t* info = new remote_info_t;
        info->is_client = false;
        info->remote_id = jpk_.sid;
        info->trans_id = jpk_.sid;
        conn_->set_data(info);
        m_client = rt_client_mgr.get_client();
    }
    else
    {
        logerror((LOG, "regist route failed!, route id:%d", (uint16_t)jpk_.sid));
    }
}
//=========================================================
gw_rt_client_t::gw_rt_client_t():rpc_client_t<gw_rt_handler_t>(),
    m_started(false),
    m_sid(0),
    m_registed(false)
{
    m_timer.reset(new boost::asio::deadline_timer(get_io()));
}
gw_rt_client_t::~gw_rt_client_t()
{
    close();
}
void gw_rt_client_t::close()
{
    m_started = false;
    m_timer->cancel();
    rpc_client_t<gw_rt_handler_t>::close();
}
void gw_rt_client_t::regist(uint16_t serid_,string ip_, string port_)
{
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_GW<<16)|serid_; 
    m_ip = ip_;
    m_port = port_;

    start_timer();
}
void gw_rt_client_t::start_timer()
{
    if (!m_started)
        return;

    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&gw_rt_client_t::on_time, this, boost::asio::placeholders::error));
}
void gw_rt_client_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    logwarn((LOG, "begin connect to route[%s,%s]...", m_ip.c_str(), m_port.c_str()));
    connect(m_ip, m_port);
    if (get_conn()->has_status(RPC_DISCONNECTED))
    {
        logerror((LOG, "route server connect failed!, wait for connect..."));
        start_timer();
    }else{
        inner_msg_def::req_regist_t req;
        req.sid = m_sid;

        inner_msg_def::jpk_gw_info_t jpk;
        jpk.serid = (uint16_t)m_sid;
        jpk.ip = m_conf.public_ip;
        jpk.port = m_conf.public_port;
        jpk >> req.jinfo;

        async_call(req);

        logwarn((LOG, "requset regist to route[%s,%s]", m_ip.c_str(), m_port.c_str()));
    }
}
