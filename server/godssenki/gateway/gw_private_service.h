#ifndef _gw_private_service_h_
#define _gw_private_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"

class gw_private_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    gw_private_handler_t(io_t& io_);
    ~gw_private_handler_t();
private:
    void on_broken(sp_rpc_conn_t conn_);
    int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_);
    //注册
    void on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_);
    //内部转发消息 
    void on_trans_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_server_msg_t& jpk_);
    //内部转发消息扩展
    void on_trans_msg_ext(sp_rpc_conn_t conn_, inner_msg_def::trans_server_msg_ext_t& jpk_);
    //发送到客户端
    void on_unicast(sp_rpc_conn_t conn_, inner_msg_def::unicast_t& jpk_);
    //广播到客户端
    void on_broadcast(sp_rpc_conn_t conn_, inner_msg_def::broadcast_t& jpk_);
    //关闭会话
    void on_close_session(sp_rpc_conn_t conn_, inner_msg_def::nt_close_session_t& jpk_);
};

class gw_private_service_t : public service_base_t<gw_private_handler_t>
{
    friend class gw_private_handler_t;
    typedef vector<uint32_t> login_array_t;
public:
    gw_private_service_t();
    uint32_t sid() { return m_sid; }
    void start(uint16_t serid_, string ip_, string port_);

    void add_login(uint32_t sid_);
    void del_login(uint32_t sid_);
    uint32_t assign_login();
    bool has_scene_server_in_conf(uint16_t serid_);
private:
    bool                m_started;
    uint32_t            m_sid;
    login_array_t       m_login_array;
    io_service_pool_t   m_io_pool;
};

#define gw_private_service (singleton_t<gw_private_service_t>::instance())

#endif
