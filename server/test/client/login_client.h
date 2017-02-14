#ifndef _RPC_SERVICE_H_
#define _RPC_SERVICE_H_

#include "rpc_client.h"
#include "msg_def.h"

class login_client_t : public rpc_client_t
{
    uint64_t m_uid;
public:
    login_client_t();
    ~login_client_t();
    void start_test(uint64_t id_);
    void stop_test();
private:
    void on_time(const boost::system::error_code& error_);
    void on_broken(sp_rpc_conn_t conn_);
    void ret_login(sp_rpc_conn_t conn_, ret_login_t& ret_);
private:
    boost::shared_ptr<boost::asio::deadline_timer> m_sp_timer;
};

#endif
