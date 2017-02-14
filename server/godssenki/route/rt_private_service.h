#ifndef _rt_private_service_h_
#define _rt_private_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"

class rt_private_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    rt_private_handler_t(io_t& io_);
    ~rt_private_handler_t();
private:
    void on_broken(sp_rpc_conn_t conn_);
    void on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_);
};

class rt_private_service_t : public service_base_t<rt_private_handler_t>
{
    struct gwinfo_t
    {
        inner_msg_def::jpk_gw_info_t gw;
        bool actived;
        int waittime;
        gwinfo_t():actived(false),waittime(5){}
    };

    friend class rt_private_handler_t;
    typedef vector<gwinfo_t> gwinfo_array_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    typedef boost::asio::io_service          io_t;
public:
    rt_private_service_t();
    uint32_t sid() { return m_sid; }
    void start(uint16_t serid_, string ip_, string port_);
    void close();
    void add_gw(inner_msg_def::jpk_gw_info_t& gwinfo_);
    void del_gw(uint16_t serid_);
    inner_msg_def::jpk_gw_info_t* assgin_gw();
private:
    void start_timer();
    void on_time(const boost::system::error_code& error_);
private:
    bool                m_started;
    uint32_t            m_sid;
    gwinfo_array_t      m_gws;
    io_service_pool_t   m_io_pool;
    sp_timer_t          m_timer;
};

#define rt_private_service (singleton_t<rt_private_service_t>::instance())

#endif
