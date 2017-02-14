#include "lg_service.h"
#include "log.h"
#include "code_def.h"
#include "remote_info.h"
#include "config.h"
#include "lg_logic.h"

#define LOG "LG_SERVICE" 

lg_handler_t::lg_handler_t(io_t& io_):rpc_t(io_)
{
    m_logic.reset(new lg_logic_t());
    reg_call(&lg_handler_t::on_ret_regist);
    reg_call(&lg_handler_t::on_trans_client_msg);
}
lg_handler_t::~lg_handler_t()
{
}
int lg_handler_t::on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_)
{
    return 0;
}
void lg_handler_t::on_broken(sp_rpc_conn_t conn_)
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
    else
    {
        lg_service.erase(info->remote_id);
    }
}
void lg_handler_t::on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_)
{
    if (jpk_.code == SUCCESS)
    {
        logwarn((LOG, "regist gateway ok! gw id:%d", (uint16_t)jpk_.sid));
        remote_info_t* info = new remote_info_t;
        info->is_client = false;
        info->remote_id = jpk_.sid;
        info->trans_id = jpk_.sid;
        conn_->set_data(info);

        if (!lg_service.get(jpk_.sid, m_client))
        {
            logerror((LOG, "can not found login gw client!, gw id:%d", (uint16_t)jpk_.sid));
        }
    }
    else
    {
        logerror((LOG, "regist gateway failed!, gw id:%d", (uint16_t)jpk_.sid));
    }
}
void lg_handler_t::on_trans_client_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_client_msg_t& jpk_)
{
    m_logic->handle_msg(jpk_.seskey, jpk_.msg_cmd, jpk_.msg, conn_);
}
//=========================================================
lg_gw_client_t::lg_gw_client_t(io_t& io_):rpc_client_t<lg_handler_t>(io_),
    m_started(false),
    m_sid(0),
    m_registed(false)
{
    m_timer.reset(new boost::asio::deadline_timer(get_io()));
}
lg_gw_client_t::~lg_gw_client_t()
{
    logwarn((LOG, "~lg_gw_client_t..."));
    close();
    logwarn((LOG, "~lg_gw_client_t...ok"));
}
void lg_gw_client_t::close()
{
    m_started = false;
    m_timer->cancel();
    rpc_client_t<lg_handler_t>::close();
}
void lg_gw_client_t::regist(uint32_t sid_, string ip_, string port_)
{
    if (m_started)
        return;
    m_started = true;

    m_sid = sid_; 
    m_ip = ip_;
    m_port = port_;

    start_timer();
}
void lg_gw_client_t::start_timer()
{
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&lg_gw_client_t::on_time, this, boost::asio::placeholders::error));
}
void lg_gw_client_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    logwarn((LOG, "begin connect to gateway[%s,%s]...", m_ip.c_str(), m_port.c_str()));
    connect(m_ip, m_port);
    if (get_conn()->has_status(RPC_DISCONNECTED))
    {
        logerror((LOG, "gateway server connect failed!, wait for connect..."));
        start_timer();
    }else{
        inner_msg_def::req_regist_t req;
        req.sid = m_sid;
        req.jinfo = m_jinfo;

        async_call(req);

        logwarn((LOG, "requset regist to gateway[%s,%s]", m_ip.c_str(), m_port.c_str()));
    }
}
//=============================================================
lg_service_t::lg_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
}
lg_service_t::~lg_service_t()
{
}
void lg_service_t::start(uint32_t sid_, const string& sqlid_)
{
    logwarn((LOG, "start login service..."));

    if (m_started)
        return;
    m_started = true;

    m_sid = sid_;

    for (auto it = config.gateway_map.contain.begin(); it != config.gateway_map.contain.end(); it++)
    {
        sp_lg_gw_client_t sp_client(new lg_gw_client_t(m_io_pool.get_io_service(0)));
        conf_def::gateway_t& gw = it->second;
        sp_client->set_regist_param(sqlid_);
        sp_client->regist(m_sid, gw.private_ip, gw.private_port);
        uint32_t gwsid = MAKE_SID(REMOTE_GW, atoi(it->first.c_str()));
        this->insert(gwsid, sp_client);
    };

   logwarn((LOG, "start login service ok! serid:%u", (uint16_t)m_sid));
}
void lg_service_t::close()
{
    logwarn((LOG, "close login service..."));

    this->foreach([](uint32_t sid_, sp_lg_gw_client_t client_){
        client_->close();
    }); 

    size_t closed_num = 0;
    while(closed_num < this->size()) { 
        this->foreach([&](uint32_t sid_, sp_lg_gw_client_t client_){
                if (client_->is_closed()) closed_num++;
        }); 
        logwarn((LOG, "wait client num:%d", this->size()));
        sleep(1); 
    }

    logwarn((LOG, "close login service...ok, serid:%d", (uint16_t)m_sid));
}
