#ifndef _gw_client_h_
#define _gw_client_h_

#include "rpc_client.h"
#include "singleton.h"
#include "msg_def.h"
#include "config.h"

class gw_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    gw_handler_t(io_t& io_);

    //路由断开
    void on_broken(sp_rpc_conn_t conn_);
    //路由返回网关注册
    void on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_);
};

class gw_client_t : public rpc_client_t<gw_handler_t>
{
    friend class gw_handler_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    gw_client_t();
    ~gw_client_t();

    //获得场景id
    uint32_t sid() {  return m_sid; }

    //设置注册参数
    void set_regist_param(const string& jinfo_) { m_jinfo = jinfo_; }

    //向route注册
    void regist(uint16_t serid_, string ip_, string port_);
    bool is_registed() { return m_registed; }
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
    string              m_jinfo;
};

#define gw_client (singleton_t<gw_client_t>::instance())

#endif
