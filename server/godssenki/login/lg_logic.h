#ifndef _lg_logic_h_
#define _lg_logic_h_

#include "msg_dispatcher.h"
#include "msg_def.h"
#include "lg_service.h"

class lg_logic_t : public msg_dispatcher_t<lg_logic_t>
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    lg_logic_t();

private:
    //客户端请求登陆
    void on_mac_login(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_);
    //请求角色列表
    void on_req_rolelist(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_);
    //请求创建角色
    void on_req_new_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_);
    //请求删除角色
    void on_req_del_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_);
private:
};

#endif
