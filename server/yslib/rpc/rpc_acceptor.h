#ifndef _RPC_ACCEPTOR_H_
#define _RPC_ACCEPTOR_H_

#include <string>
using namespace std;

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>

#include "rpc_connecter.h"

class rpc_acceptor_t: private boost::noncopyable
{
public:
    typedef boost::asio::io_service                     io_t;
    typedef boost::shared_ptr<rpc_connecter_t> sp_rpc_conn_t;
    typedef boost::function<rpc_listen_strategy_i*()> cb_listen_strategy_creator_t;
public:
    rpc_acceptor_t(boost::asio::io_service& io_, cb_listen_strategy_creator_t cb_);
    virtual ~rpc_acceptor_t();

    int start(const string& host_, const string& port_, bool use_monitor_ = false);
    int stop();
protected:
    int sync_start_listen_i();
    int sync_accept_i(sp_rpc_conn_t ptr_, const boost::system::error_code& error_);
    int sync_close_i();
protected:

    bool                                                    m_started;
    bool                                                    m_use_monitor;
    string                                                  m_listen_ip;
    string                                                  m_listen_port;

    boost::asio::io_service&                                m_io_service;
    boost::asio::ip::tcp::acceptor                          m_acceptor;

    cb_listen_strategy_creator_t                            m_cb_ls_creator;
};

#endif
