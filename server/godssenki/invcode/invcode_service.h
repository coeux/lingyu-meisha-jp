#ifndef _invcode_service_h_
#define _invcode_service_h_

#include "service_base.h"
#include "singleton.h"
#include "invcode_msg_def.h"
#include "msg_def.h"
#include <map>

class invcode_handler_t : public rpc_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
private:
    int invcode2uid(string &invcode_);
public:
    invcode_handler_t(io_t& io_);
    ~invcode_handler_t();

    //客户端断开
    void on_broken(sp_rpc_conn_t conn_);
    //注册
    void on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_);
    //请求邀请码
    void on_req_invcode(sp_rpc_conn_t conn_, invcode_msg::req_code_t& jpk_);
    //请求邀请码对应的uid
    void on_req_uid(sp_rpc_conn_t conn_, invcode_msg::req_uid_t &jpk_);
    //被邀请者升级
    void on_invitee_upgrade(sp_rpc_conn_t conn_, invcode_msg::nt_upgrade_t &jpk_);
    /*
    //请求奖励信息
    void on_req_reward_info(sp_rpc_conn_t conn_,invcode_msg::req_reward_t &jpk_);
    */
};

class invcode_service_t: public service_base_t<invcode_handler_t>
{   
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
    typedef unordered_map<int32_t,sp_rpc_conn_t>        conn_hm_t;
    typedef unordered_map<string,int32_t>               platform_hm_t;
private:
    conn_hm_t     m_conn_hm;
public:
    invcode_service_t();

    uint32_t sid() {  return m_sid; }

    void start(uint16_t serid_, string ip_, string port_);

    conn_hm_t& conn_hm() { return m_conn_hm; }

    int32_t get_serid(string platform_);
private:
    bool                m_started;
    uint32_t            m_sid;
    io_service_pool_t   m_io_pool;
    platform_hm_t       m_platform;
};

#define invcode_service (singleton_t<invcode_service_t>::instance())

#endif
