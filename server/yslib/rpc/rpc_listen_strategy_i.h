#ifndef _RPC_LISTEN_STRATEGY_I_H_
#define _RPC_LISTEN_STRATEGY_I_H_

#include <string>
using namespace std;

#include "rpc_def.h"
#include "rpc_connecter.h"

class rpc_connecter_t;
class rpc_listen_strategy_i
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    rpc_listen_strategy_i() {}
    virtual ~rpc_listen_strategy_i() {}

    virtual void reset() = 0;
    virtual int on_remote_open(sp_rpc_conn_t conn_) = 0;
    virtual int on_connect(sp_rpc_conn_t conn_, const boost::system::error_code& e_) = 0;
    virtual int on_read(sp_rpc_conn_t conn_, const char* data_, size_t bytes_transferred_) = 0;
    virtual int on_write(sp_rpc_conn_t conn_, size_t bytes_transferred_, size_t msg_transferred_) = 0;
    virtual bool on_write_check(sp_rpc_conn_t conn_, const string& data_){ return true; }
    virtual void on_error(sp_rpc_conn_t conn_, rpc_error_e err_, const string& err_info_) = 0;
    virtual void on_closed(sp_rpc_conn_t conn_)=0;

    //[normal:1/broken:0, cmd, res, body, connecter]
    virtual void handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_)=0;
};

#endif
