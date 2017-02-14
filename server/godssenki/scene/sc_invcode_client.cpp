#include "sc_invcode_client.h"
#include "sc_service.h"
#include "sc_logic.h"

#include "msg_def.h"
#include "remote_info.h"
#include "code_def.h"
#include "config.h"

#define LOG "SC_INV_CLIENT"

sc_invcode_handler_t::sc_invcode_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&sc_invcode_handler_t::on_ret_regist);
}
int sc_invcode_handler_t::on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_)
{
    logic.handle_invcode_msg(cmd_, body_);
    return 0;
}
void sc_invcode_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
    {
        logwarn((LOG, "unknown server broken!"));
        return;
    }
    logwarn((LOG, "server broken! sertype:%u, serid:%u", info->sertype(), info->serid()));
    if (m_client == NULL)
        return;
    if (!m_client->is_closed())
    {
        m_client->set_registed(false);
        m_client->start_timer();
    }
}
void sc_invcode_handler_t::on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_)
{
    if (jpk_.code == SUCCESS)
    {
        logwarn((LOG, "regist invcode ok! invcode id:%d", (uint16_t)jpk_.sid));
        remote_info_t* info = new remote_info_t;
        info->is_client = false;
        info->remote_id = jpk_.sid;
        info->trans_id = jpk_.sid;
        conn_->set_data(info);

        m_client = sc_service.get_invclient();
        m_client->set_registed(true);
    }
    else
    {
        logerror((LOG, "regist invcode failed!, invcode id:%d", (uint16_t)jpk_.sid));
    }
}
//=========================================================
sc_invcode_client_t::sc_invcode_client_t(io_t& io_):rpc_client_t<sc_invcode_handler_t>(io_),
    m_started(false),
    m_sid(0),
    m_registed(false)
{
    m_timer.reset(new boost::asio::deadline_timer(get_io()));
}
sc_invcode_client_t::~sc_invcode_client_t()
{
    close();
}
void sc_invcode_client_t::close()
{
    m_started = false;
    m_timer->cancel();
    rpc_client_t<sc_invcode_handler_t>::close();
}
void sc_invcode_client_t::regist(uint32_t sid_, const string& ip_, const string& port_)
{
    if (m_started)
        return;
    m_started = true;

    m_sid = sid_; 
    m_ip = ip_;
    m_port = port_;

    start_timer();
}
void sc_invcode_client_t::start_timer()
{
    //logwarn((LOG, "invcode_client start_timer..."));
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&sc_invcode_client_t::on_time, this, boost::asio::placeholders::error));
    //logwarn((LOG, "invcode_client start_timer...ok"));
}
void sc_invcode_client_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    //logwarn((LOG, "begin connect to invcode[%s,%s]...", m_ip.c_str(), m_port.c_str()));
    connect(m_ip, m_port);
    if (get_conn()->has_status(RPC_DISCONNECTED))
    {
        //logerror((LOG, "invcode server connect failed!, wait for connect..."));
        start_timer();
    }else{
        inner_msg_def::req_regist_t req;
        req.sid = m_sid;
        req.jinfo = m_jinfo;

        async_call(req);

        //logwarn((LOG, "requset regist to invcode[%s,%s]", m_ip.c_str(), m_port.c_str()));
    }
}
