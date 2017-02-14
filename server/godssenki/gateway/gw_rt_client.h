#ifndef _gw_rt_client_h_
#define _gw_rt_client_h_

#include "rpc_client.h"
#include "singleton.h"
#include "msg_def.h"
#include "config.h"

class gw_rt_client_t;
class gw_rt_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
    typedef boost::shared_ptr<gw_rt_client_t>           sp_client_t;
public:
    gw_rt_handler_t(io_t& io_);

    //路由断开
    void on_broken(sp_rpc_conn_t conn_);
    //路由返回网关注册
    void on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_);
private:
    sp_client_t m_client;
};

class gw_rt_client_t : public rpc_client_t<gw_rt_handler_t>
{
    friend class gw_rt_handler_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    gw_rt_client_t();
    ~gw_rt_client_t();

    //获得场景id
    uint32_t sid() {  return m_sid; }

    void set_conf(const conf_def::gateway_t& conf_){ m_conf = conf_; }
    
    //向route注册
    void regist(uint16_t serid_, string ip_, string port_);
    bool is_registed() { return m_registed; }

    void close();
private:
    void start_timer();
    void on_time(const boost::system::error_code& error_);
    void set_registed(bool ok_) { m_registed = ok_; }
private:
    bool                m_started;
    uint32_t            m_sid;
    string              m_ip;
    string              m_port;
    sp_timer_t          m_timer;
    bool                m_registed;
    conf_def::gateway_t m_conf;
};

class gw_rt_client_mgr_t
{
    typedef boost::shared_ptr<gw_rt_client_t> sp_client_t;
public:
    gw_rt_client_mgr_t():m_client(new gw_rt_client_t()){}
    sp_client_t get_client() { return m_client; }
private:
    sp_client_t m_client;
};

#define rt_client_mgr (singleton_t<gw_rt_client_mgr_t>::instance())

#endif
