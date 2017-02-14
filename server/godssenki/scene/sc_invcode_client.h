#ifndef _sc_invcode_client_h_
#define _sc_invcode_client_h_

#include "rpc_client.h"
#include "singleton.h"
#include "invcode_msg_def.h"
#include "msg_def.h"

class sc_invcode_client_t;
typedef boost::shared_ptr<sc_invcode_client_t> sp_sc_invcode_client_t;

class sc_invcode_handler_t : public rpc_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    sc_invcode_handler_t(io_t& io_);
    //网关断开
    void on_broken(sp_rpc_conn_t conn_);
    //收到未知消息，提交到logic.handle_msg处理
    int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_);
    //返回注册
    void on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_);
private:
    sp_sc_invcode_client_t m_client;
};

class sc_invcode_client_t : public rpc_client_t<sc_invcode_handler_t>
{
    friend class sc_invcode_handler_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    sc_invcode_client_t(io_t& io_);
    ~sc_invcode_client_t();

    uint32_t sid() {  return m_sid; }
    //设置注册参数
    void set_regist_param(const string& jinfo_) { m_jinfo = jinfo_; }

    void regist(uint32_t sid_, const string& ip_, const string& port_);
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

#define invcode_client (singleton_t<sc_invcode_client_t>::instance())

#endif
