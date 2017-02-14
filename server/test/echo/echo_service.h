#ifndef _echo_service_h_
#define _echo_service_h_

#include "rpc_server.h"
#include "rpc.h"
#include "singleton.h"
#include "echo_jmsg_def.h"

#include <set>
using namespace std;

class echo_service_t : public rpc_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    echo_service_t(io_t& io_);
    ~echo_service_t();

    static const char* name() { return "echo"; }
private:
    void on_broken(sp_rpc_conn_t conn_);
    void on_echo(sp_rpc_conn_t conn_, req_echo_t& jpk_);
private:
    set<sp_rpc_conn_t> m_conn_set;
};

#define echo_service (singleton_t<rpc_server_t<echo_service_t>>::instance())

#endif
