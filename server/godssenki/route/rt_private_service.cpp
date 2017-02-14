#include "rt_private_service.h"
#include "log.h"
#include "remote_info.h"
#include "code_def.h"

#define LOG "RT_PRIVATE" 

rt_private_handler_t::rt_private_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&rt_private_handler_t::on_regist);
}
rt_private_handler_t::~rt_private_handler_t()
{
}
void rt_private_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "server broken! sertype:%d, serid:%d", info->sertype(), info->serid()));
    if (REMOTE_GW == (info->sertype()))
        rt_private_service.del_gw(info->serid());
    rt_private_service.del_server(info->remote_id);
}
void rt_private_handler_t::on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_)
{
    inner_msg_def::ret_regist_t ret;

    uint16_t sertype = jpk_.sid >> 16;
    uint16_t serid = jpk_.sid;

    if (REMOTE_GW != sertype)
    {
        ret.code = ERROR_ILLEGLE_SERVER;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    if (sertype <= 0 || sertype >= REMOTE_ALL)
    {
        logerror((LOG, "unkonw server requset regist! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_UNKNOWN_SERVER;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    if (rt_private_service.get_server(jpk_.sid) != NULL)
    {
        logerror((LOG, "server has registed! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_SERVER_HAS_REGISTED;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    remote_info_t* remote = new remote_info_t; 
    remote->is_client = false;
    remote->remote_id = jpk_.sid;
    remote->trans_id = jpk_.sid;
    conn_->set_data(remote);

    rt_private_service.add_server(jpk_.sid, conn_); 

    inner_msg_def::jpk_gw_info_t gwinfo;
    gwinfo << jpk_.jinfo;
    rt_private_service.add_gw(gwinfo);

    ret.sid = rt_private_service.sid(); 
    ret.code = SUCCESS;  
    async_call(conn_, ret);
}
//=========================================================
rt_private_service_t::rt_private_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    service_base_t<rt_private_handler_t>(m_io_pool.get_io_service());
    m_timer.reset(new boost::asio::deadline_timer(m_io_pool.get_io_service()));
}
void rt_private_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start route private service..."));

    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_ROUTE<<16)|serid_; 
    listen(ip_, port_);
    start_timer();

    logwarn((LOG, "start route private service! serid:%u", serid_));
}
void rt_private_service_t::close()
{
    m_started = false;
    m_timer->cancel();
}
void rt_private_service_t::add_gw(inner_msg_def::jpk_gw_info_t& gwinfo_)
{
    gwinfo_array_t::iterator it = 
        std::find_if(m_gws.begin(), m_gws.end(), [&](const gwinfo_t& info_)->bool{
                return (gwinfo_.serid == info_.gw.serid);
            });

    if (it == m_gws.end())
    {
        logwarn((LOG, "add gateway:%u, addr:[%s,%s]", gwinfo_.serid, gwinfo_.ip.c_str(), gwinfo_.port.c_str()));
        gwinfo_t gi;
        gi.gw = gwinfo_;
        if (m_gws.empty())
            gi.actived = true;
        m_gws.push_back(std::move(gi));
    }
    else
    {
        logerror((LOG, "add existed gateway:%u, addr:[%s,%s]", gwinfo_.serid, gwinfo_.ip.c_str(), gwinfo_.port.c_str()));
    }
}
void rt_private_service_t::del_gw(uint16_t serid_)
{
    gwinfo_array_t::iterator it = 
        std::find_if(m_gws.begin(), m_gws.end(), [=](const gwinfo_t& info_)->bool{
                return (serid_ == info_.gw.serid);
            });

    if (it != m_gws.end())
    {
        inner_msg_def::jpk_gw_info_t& gw = (*it).gw; 
        logwarn((LOG, "del gateway:%u, addr:[%s,%s]", gw.serid, gw.ip.c_str(), gw.port.c_str()));

        m_gws.erase(it);
    }
    else
    {
        logerror((LOG, "del unkonwn gateway:%u", serid_));
    }
}
inner_msg_def::jpk_gw_info_t* rt_private_service_t::assgin_gw()
{
    static uint16_t gi=0;
    if (m_gws.empty())
        return NULL;
begin_assgin_gw:
    gwinfo_t& gwi = m_gws[(gi++)%m_gws.size()];
    if (gwi.actived)
        return &(gwi.gw);
    else
        goto begin_assgin_gw;
}
void rt_private_service_t::start_timer()
{
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&rt_private_service_t::on_time, this, boost::asio::placeholders::error));
}
void rt_private_service_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    for(gwinfo_t& gi : m_gws)
    {
        if (gi.actived)
            continue;
        gi.waittime -= 1;
        if (gi.waittime <= 0)
            gi.actived = true;
    }

    start_timer();
}
