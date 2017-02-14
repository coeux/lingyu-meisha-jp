#ifndef _RPC_H_
#define _RPC_H_

#include <string>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "rpc_acceptor.h"
#include "rpc_common_conn_protocol.h"
#include "log.h"
#include "rpc_log_def.h"
#include "thread_pool.h"
#include "io_wrap.h"

class rpc_bin_t : public rpc_common_conn_protocol_t, private boost::noncopyable
{
public:
    typedef boost::asio::io_service                     io_t;
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    rpc_bin_t(io_t& io_);
    virtual ~rpc_bin_t() {}

    int async_send(sp_rpc_conn_t conn_, uint16_t cmd_, void* body_, uint32_t size_);

    virtual void on_broken(sp_rpc_conn_t conn_) = 0;
    virtual void handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_) = 0;
};

#endif
