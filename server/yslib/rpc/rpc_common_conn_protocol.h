#ifndef _RPC_COMMON_CONN_PROTOCOL_H_
#define _RPC_COMMON_CONN_PROTOCOL_H_

#include <string>
using namespace std;

#include <boost/function.hpp>

#include "rpc_connecter.h"
#include "rpc_listen_strategy_i.h"
#include "rpc_msg_head.h"

class rpc_common_conn_protocol_t : public rpc_listen_strategy_i
{
public:
    typedef boost::asio::io_service                     io_t;
    typedef boost::shared_ptr<rpc_connecter_t> sp_rpc_conn_t;
public:
    rpc_common_conn_protocol_t(io_t& io_);
    ~rpc_common_conn_protocol_t();

    void reset();

    int  on_connect(sp_rpc_conn_t conn_, const boost::system::error_code& e);
    int  on_remote_open(sp_rpc_conn_t conn_);
    int  on_read(sp_rpc_conn_t conn_, const char* data_, size_t size_);
    int  on_write(sp_rpc_conn_t conn_, size_t size_, size_t msg_num_){ return 0; }
    void on_error(sp_rpc_conn_t conn_, rpc_error_e err_, const string& err_msg_);
    void on_closed(sp_rpc_conn_t conn_);

    io_t& get_io()  { return m_io; }
private:
    bool has_read_head_end_i() const { return m_msg_size >= sizeof(m_head); }
    bool has_read_body_end_i() const { return m_head.len == m_body.size();  }

    size_t read_head_i(const char* data_, size_t size_);
    size_t read_body_i(const char* data_, size_t size_);

    void post_broken_msg_i(sp_rpc_conn_t conn_);
    void clear();

    virtual bool on_decrypt(sp_rpc_conn_t conn_, uint16_t cmd_, uint16_t res_, string& m_body_) { return false; }
private:
    io_t&                   m_io;
    size_t                  m_msg_size;
    struct rpc_msg_head_t   m_head;
    string                  m_body;
    bool                    m_broken_flag;
};

#endif
