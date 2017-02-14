#ifndef _lg_service_h_
#define _lg_service_h_

#include "rpc_client.h"
#include "singleton.h"
#include "msg_def.h"
#include "concurrent_hash_map.h"

class lg_logic_t;
typedef boost::shared_ptr<lg_logic_t> sp_lg_logic_t;
class lg_gw_client_t;
typedef boost::shared_ptr<lg_gw_client_t> sp_lg_gw_client_t;

class lg_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    lg_handler_t(io_t& io_);
    ~lg_handler_t();
private:
    //收到未绑定的消息
    int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_);
    //链接断开
    void on_broken(sp_rpc_conn_t conn_);
    //返回网关注册
    void on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_);
    //客户端消息
    void on_trans_client_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_client_msg_t& jpk_);
private:
    sp_lg_gw_client_t m_client;
    sp_lg_logic_t m_logic;
};

class lg_gw_client_t : public rpc_client_t<lg_handler_t>
{
    friend class lg_handler_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    lg_gw_client_t(io_t& io_);
    ~lg_gw_client_t();

    uint32_t sid() {  return m_sid; }
    //设置注册参数
    void set_regist_param(const string& jinfo_) { m_jinfo = jinfo_; }

    //向route注册
    void regist(uint32_t sid_, string ip_, string port_);
    bool is_registed() { return m_registed; }

    void close();
    bool is_closed() { return !m_started; }
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

class lg_service_t : public concurrent_hash_map_t<uint32_t, sp_lg_gw_client_t>
{
public:
    typedef boost::asio::io_service          io_t;
public:
    lg_service_t();
    ~lg_service_t();
    
    void start(uint32_t sid_, const string& sqlid_);
    void close();

    uint32_t sid() {  return m_sid; }

    io_t& get_io() { return m_io_pool.get_io_service(0); } 
private:
    bool                m_started;
    uint32_t            m_sid;
    io_service_pool_t   m_io_pool;
};

#define lg_service (singleton_t<lg_service_t>::instance())

#endif
