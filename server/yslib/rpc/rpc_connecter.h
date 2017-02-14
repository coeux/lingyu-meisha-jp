#ifndef _rpc_connecter_h_
#define _rpc_connecter_h_

#include <string>
#include <deque>
using namespace std;

#include <assert.h>

#include <boost/array.hpp>
#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>

#include "rpc_def.h"

class rpc_listen_strategy_i;

class rpc_connecter_t:public boost::enable_shared_from_this<rpc_connecter_t>, private boost::noncopyable
{
public:
    enum { BUFFER_SIZE = 1024*8 };

public:
    rpc_connecter_t(boost::asio::io_service& io_, rpc_listen_strategy_i* strategy_);
    ~rpc_connecter_t();

    //open when accept remote connecter
    void remote_open(bool use_monitor_ = false);

    //async operation
    void async_connect(const string& address_, const string& port_);
    void async_read();
    void async_send(string& data_);
    void async_send(string&& data_);

    //sync operation
    int sync_connect(const string& address_, const string& port_);
    int sync_read_n(char* buff_, size_t len_);
    int sync_send(const string& data_);
    pair<const char*, size_t> sync_read_some();

    void close(rpc_close_type_e type_ = RPC_CLOSE);

    template<class T>
    T* get_data() 
    { return (T*)m_pdata; }
    void  set_data(void* pdate_);
public:
    boost::asio::ip::tcp::socket& socket()
    { return m_socket; }

    bool has_type(rpc_connection_type_e type_)
    { return type_ == m_type; }

    rpc_status_e status() const
    { return m_status; }

    bool has_status(rpc_status_e status_)
    { return m_status == status_; }

    boost::shared_ptr<rpc_connecter_t> get_shared_ptr() 
    { return shared_from_this(); }

    bool has_monitor()
    { return m_use_monitor; }

private:
    void handle_resolve_i(const boost::system::error_code& err_,
                                         boost::asio::ip::tcp::resolver::iterator endpoint_iterator_,
                                         boost::shared_ptr<boost::asio::ip::tcp::resolver> resolver_ptr_);

    void handle_connect_i(const boost::system::error_code& err_,
                                         boost::asio::ip::tcp::resolver::iterator endpoint_iterator_);

    void read_completed_i(const boost::system::error_code& err_, size_t bytes_transferred_);
    void write_completed_i(const boost::system::error_code& err_, size_t bytes_transferred_);

    void sync_write_i(string& data_);
    bool start_sending_buffers_i();
    int sync_close_i(rpc_close_type_e type_);

    void set_write_state(bool writing_); 
private:
    boost::asio::io_service&            m_io_service;
    rpc_listen_strategy_i*              m_strategy;

    rpc_status_e                        m_status;
    rpc_connection_type_e               m_type;

    bool                                m_write_in_progress;
    int                                 m_sending_seq_index;
    int                                 m_waiting_seq_index;
    //boost::array<char, BUFFER_SIZE>     m_read_buffer;
    char                                m_read_buffer[BUFFER_SIZE];
    deque<string>                       m_sequences;
    boost::asio::ip::tcp::socket        m_socket ;

    //boost::any                          m_data;
    void*                               m_pdata;
    bool                                m_use_monitor;
    size_t                              m_waiting_write_total;
};

#endif
