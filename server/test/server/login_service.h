#ifndef _login_service_h_
#define _login_service_h_

#include "rpc_server.h"
#include "msg_def.h"

class login_service_t : public rpc_server_t
{
public:
    login_service_t();
    ~login_service_t();
private:
    void on_broken(sp_rpc_conn_t conn_);
    void on_login(sp_rpc_conn_t conn_, rq_login_t& rq_);
};

#endif
