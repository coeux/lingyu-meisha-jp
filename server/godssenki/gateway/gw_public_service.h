#ifndef _gw_public_service_h_
#define _gw_public_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"

class gw_public_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    gw_public_handler_t(io_t& io_);
    ~gw_public_handler_t();
protected:
    bool on_decrypt(sp_rpc_conn_t conn_, uint16_t cmd_, uint16_t res_, string& body_); 
private:
    //收到未绑定的消息
    int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_);
    //客户端断开
    void on_broken(sp_rpc_conn_t conn_);
    //客户端请求登陆网关
    void on_login(sp_rpc_conn_t conn_, gw_msg_def::req_login_t& jpk_);
    //请求新seskey
    void on_req_new_seskey(sp_rpc_conn_t conn_, gw_msg_def::req_new_seskey_t& jpk_);
    //请求服务器列表
    void on_req_gslist(sp_rpc_conn_t conn_, gw_msg_def::req_gslist_t& jpk_);
    //请求登陆游戏服务器
    void on_req_login_game(sp_rpc_conn_t conn_, sc_msg_def::req_login_t& jpk_);
    //客户端发来的心跳消息
    void on_nt_heartbeat(sp_rpc_conn_t conn_, gw_msg_def::nt_heartbeat_t& jpk_);
    void on_req_heartbeat(sp_rpc_conn_t conn_, gw_msg_def::req_heartbeat_t& jpk_);
    //请求角色列表
    void on_req_rolelist(sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_);
};


class gw_public_service_t : public service_base_t<gw_public_handler_t>
{
public:
    //[seskey][sid]
    typedef hash_map<uint64_t, uint32_t> trans_hm_t;
    //[uid][seskey]
    typedef hash_map<int32_t, uint64_t> user_ses_hm_t;
public:
    gw_public_service_t();

    uint32_t sid() {  return m_sid; }

    void start(uint16_t serid_, string ip_, string port_);

    //增删查，转发表
    //用来保存当前seskey对应的转发服务器id
    //在断线重连的情况下，可以根据seskey找到转发，重新设置链接信息
    void add_trans(uint64_t seskey_, uint32_t sid_);
    void del_trans(uint64_t seskey_);
    uint32_t get_trans(uint64_t seskey_);

    //重置seskey, 参数是老的seskey
    uint64_t reset_seskey(uint64_t seskey_);

    //保存有效的seskey
    void add_valid_seskey(uint64_t seskey_);

    void close_scene_conn(uint32_t scid_);
private:
    bool                m_started;
    uint32_t            m_sid;
    trans_hm_t          m_trans_hm;
    user_ses_hm_t       m_user_ses_hm;
};

#define gw_public_service (singleton_t<gw_public_service_t>::instance())

#endif
