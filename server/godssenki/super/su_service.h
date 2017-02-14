#ifndef _gw_public_service_h_
#define _gw_public_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"

class su_handler_t : public rpc_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
    typedef hash_map<uint64_t, sp_rpc_conn_t>           client_conn_hm_t;
public:
    su_handler_t(io_t& io_);
    ~su_handler_t();

    static const char* name() { return "su_handler_t"; }
private:
    //服务器断开
    void on_broken(sp_rpc_conn_t conn_);
    //服务器向super注册
    void on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_);
    //返回服务器信息
    void on_ret_server_info(sp_rpc_conn_t conn_, inner_msg_def::ret_server_info_t& jpk_);
};

class su_service_t:public service_base_t<su_handler_t>
{
    typedef hash_map<uint32_t, ret_server_info_t> server_info_hm_t;
public:
    su_service_t();
    ~su_service_t();
private:
    server_info_hm_t m_server_info_hm;
};

#define su_service (singleton_t<su_service_t>::instance())

#endif
