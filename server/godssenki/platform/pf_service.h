#ifndef _pf_service_h_
#define _pf_service_h_

#include "service_base.h"
#include "singleton.h"
#include "pf_msg_def.h"
#include "msg_def.h"
#include <map>

class pf_handler_t : public rpc_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    pf_handler_t(io_t& io_);
    ~pf_handler_t();

    //客户端断开
    void on_broken(sp_rpc_conn_t conn_);
    //注册
    void on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_);
    //平台通知用户购买结果
    void on_user_pay(sp_rpc_conn_t conn_, pf_msg_def::nt_user_pay_result_t& jpk_);
    //游戏服务器领取购买的物品
    void on_req_given_goods(sp_rpc_conn_t conn_, pf_msg_def::req_given_goods_t& jpk_);
    //请求购买
    void on_req_pay(sp_rpc_conn_t conn_, pf_msg_def::req_given_goods_t& jpk_)
};

class pf_service_t: public service_base_t<pf_handler_t>
{
public:
    pf_service_t();

    uint32_t sid() {  return m_sid; }

    void start(uint16_t serid_, string ip_, string port_);
private:
    bool                m_started;
    uint32_t            m_sid;
    io_service_pool_t   m_io_pool;
};

#define pf_service (singleton_t<pf_service_t>::instance())

#endif
