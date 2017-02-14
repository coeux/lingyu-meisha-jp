#include "rpc_connecter.h"
#include "log.h"
#include "rpc_log_def.h"
#include "rpc_listen_strategy_i.h"

rpc_connecter_t::rpc_connecter_t(boost::asio::io_service& io_, rpc_listen_strategy_i* strategy_):
    m_io_service(io_),
    m_strategy(strategy_),
    m_status(RPC_DISCONNECTED),
    m_type(RPC_PASSIVE),
    m_write_in_progress(false),
    m_sending_seq_index(0),
    m_waiting_seq_index(1),
    m_socket(io_),
    m_pdata(NULL),
    m_use_monitor(false),
    m_waiting_write_total(0)
{
    logtrace((RPC_CONNECTER, "rpc_connection_t begin..."));
    if(NULL == m_strategy)
    {
        throw std::runtime_error("rpc_connecter_t strategy NULL ptr");
    }
    logtrace((RPC_CONNECTER, "rpc_connection_t end ok"));
}
rpc_connecter_t::~rpc_connecter_t()
{
    logtrace((RPC_CONNECTER, "~rpc_connection_t begin...socket type[%d]", m_type));

    sync_close_i(RPC_CLOSE);

    if (m_strategy)
    {
        delete m_strategy;
        m_strategy = NULL;
    }

    if (m_pdata)
    {
        delete m_pdata;
    }

    logtrace((RPC_CONNECTER, "~rpc_connection_t end ok"));
}

void rpc_connecter_t::set_data(void* pdate_)
{ 
    if(m_pdata != NULL)
    {
        delete m_pdata;
    } 
    m_pdata = pdate_; 
}

void rpc_connecter_t::remote_open(bool use_monitor_)
{
    logtrace((RPC_CONNECTER, "remote_open begin..."));

    m_use_monitor = use_monitor_;
    m_status = RPC_CONNECTED;
    m_strategy->on_remote_open(shared_from_this());

    logtrace((RPC_CONNECTER, "remote_open end ok"));
}

int  rpc_connecter_t::sync_connect(const string& address_, const string& port_)
{
    logtrace((RPC_CONNECTER, "sync_connect begin..." ) );

    using boost::asio::ip::tcp;
    tcp::resolver resolver(m_io_service);
    tcp::resolver::query query(address_, port_);
    tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);
    tcp::resolver::iterator end;

    // Try each endpoint until we successfully establish a connection.
    boost::system::error_code error = boost::asio::error::host_not_found;
    while (error && endpoint_iterator != end)
    {
        m_socket.close();
        m_socket.connect(*endpoint_iterator++, error);
    }

    if (error)
    {
        logwarn((RPC_CONNECTER, "sync_connect catch exception=<%s>", error.message().c_str()));
        m_status = RPC_DISCONNECTED;
        return -1;
    }

    m_type   = RPC_ACTIVE;
    m_status = RPC_CONNECTED;

    async_read();

    logtrace((RPC_CONNECTER, "sync_connect end ok"));
    return 0;
}

void rpc_connecter_t::async_connect(const string& address_, const string& port_)
{
    logtrace((RPC_CONNECTER, "async_connect begin..." ) );

    if (RPC_DISCONNECTED != m_status)
    {
        loginfo((RPC_CONNECTER, "async_connect connecting end"));
        return;
    }

    using boost::asio::ip::tcp;
    tcp::resolver::query query(address_, port_);
    boost::shared_ptr<tcp::resolver> resolver_ptr(new tcp::resolver(m_io_service));

    resolver_ptr->async_resolve(query, boost::bind(&rpc_connecter_t::handle_resolve_i,
                                                        shared_from_this(),
                                                        boost::asio::placeholders::error,
                                                        boost::asio::placeholders::iterator,
                                                        resolver_ptr));
    m_status = RPC_CONNECTING;
    m_type   = RPC_ACTIVE;
    logtrace((RPC_CONNECTER, "async_connect end ok" ) );
}

void rpc_connecter_t::close(rpc_close_type_e type_)
{
    logwarn((RPC_CONNECTER, "close begin..."));

    m_io_service.post(boost::bind(&rpc_connecter_t::sync_close_i,
                      	                            shared_from_this(),
						                            type_));
}

int rpc_connecter_t::sync_close_i(rpc_close_type_e type_)
{
    logwarn((RPC_CONNECTER, "sync_close_i begin..."));

    if (RPC_DISCONNECTED == m_status)
    {
        logwarn((RPC_CONNECTER, "sync_close_i already closed!"));
        return 0;
    }

	switch(type_)
    {
        case RPC_SHUTDOWN:
        {
            try
            {
                boost::asio::socket_base::linger option(true, 0);
                m_socket.set_option(option);

            }catch(exception& e)
            {
                logwarn((RPC_CONNECTER, "sync_close_i shutdown exception=<%s>", e.what()));
            }
        }break;
        default:
            break;
    }


    try
    {
        m_socket.close();
    }
    catch(...)
    {
    }
    m_status = RPC_DISCONNECTED;

    m_strategy->reset();
    m_strategy->on_closed(shared_from_this());
    logwarn((RPC_CONNECTER, "sync_close_i end ok." ) );
    return 0;
}

void rpc_connecter_t::handle_resolve_i(const boost::system::error_code& err_,
                                         boost::asio::ip::tcp::resolver::iterator endpoint_iterator_,
                                         boost::shared_ptr<boost::asio::ip::tcp::resolver> resolver_ptr_)
{
    logtrace((RPC_CONNECTER, "handle_resolve_i begin..." ) );

    if (!err_)
    {
        // Attempt a connection to the first endpoint in the list. Each endpoint
        // will be tried until we successfully establish a connection.
        boost::asio::ip::tcp::endpoint endpoint = *endpoint_iterator_;
        m_socket.close();
        m_socket.async_connect(endpoint,
                             boost::bind(&rpc_connecter_t::handle_connect_i,
                                                           shared_from_this(),
                                                           boost::asio::placeholders::error,
                                                           ++endpoint_iterator_));
    }
    else
    {
        logwarn((RPC_CONNECTER, "handle_resolve_i catch exception=<%s>" , err_.message().c_str()));

        sync_close_i(RPC_CLOSE);
        m_strategy->on_connect(shared_from_this(), err_);
        return;
    }

    logtrace((RPC_CONNECTER, "async_handle_resolve_i end ok"));
}

void rpc_connecter_t::handle_connect_i(const boost::system::error_code& err_,
                                         boost::asio::ip::tcp::resolver::iterator endpoint_iterator_)
{
    logtrace((RPC_CONNECTER, "sync_handle_connect_i begin..."));

    if (!err_)
    {
        m_status = RPC_CONNECTED;

        loginfo((RPC_CONNECTER, "sync_handle_connect_i connect remote ok "));
        m_strategy->on_connect(shared_from_this(), err_);

        async_read();
        return;
    }
    else if (endpoint_iterator_ != boost::asio::ip::tcp::resolver::iterator())
    {
        // The connection failed. Try the next endpoint in the list.
        m_socket.close();
        boost::asio::ip::tcp::endpoint endpoint = *endpoint_iterator_;
        m_socket.async_connect(endpoint,
                             boost::bind(&rpc_connecter_t::handle_connect_i,
                                                           shared_from_this(),
                                                           boost::asio::placeholders::error,
                                                           ++endpoint_iterator_));
    }
    else
    {
        logwarn((RPC_CONNECTER, "sync_handle_connect_i connect remote fail<%s>", err_.message().c_str()));
        sync_close_i(RPC_CLOSE);
        m_strategy->on_connect(shared_from_this(), err_);
        return;
    }

    logtrace((RPC_CONNECTER, "sync_handle_connect_i end ok"));
}

void rpc_connecter_t::async_read()
{
    logtrace((RPC_CONNECTER, "async_read begin..." ) );

    m_socket.async_read_some(boost::asio::buffer(m_read_buffer),
                             boost::bind(&rpc_connecter_t::read_completed_i,
                                                           shared_from_this(),
                                                           boost::asio::placeholders::error,
                                                           boost::asio::placeholders::bytes_transferred));

    logtrace((RPC_CONNECTER, "async_read end ok"));
}

void rpc_connecter_t::read_completed_i(const boost::system::error_code& err_, size_t bytes_transferred_)
{
    logtrace((RPC_CONNECTER, "read_completed_i begin..."));
    if(err_)
    {
        logerror((RPC_CONNECTER, "read_completed_i socket error=<%s>", err_.message().c_str()));

        if (!has_status(RPC_DISCONNECTED))
        {
            sync_close_i(RPC_CLOSE);
            //m_strategy->on_error(shared_from_this(), RPC_READ_ERROR, err_.message());
        }
        return;
    }

    int ret = m_strategy->on_read(shared_from_this(), m_read_buffer, bytes_transferred_);
    if (ret == -1)
    {
        close(RPC_SHUTDOWN);
    }

    logtrace((RPC_CONNECTER, "read_completed_i end ok" ) );
}

void rpc_connecter_t::async_send(string& data_)
{
    logtrace((RPC_CONNECTER, "async_send begin..." ) );

    m_io_service.post(std::bind(&rpc_connecter_t::sync_write_i,
                                                    shared_from_this(),
                                                    std::move(data_)));

   logtrace((RPC_CONNECTER, "async_send end ok." ) );
}

void rpc_connecter_t::async_send(string&& data_)
{
    logtrace((RPC_CONNECTER, "async_send begin..." ) );

    m_io_service.post(std::bind(&rpc_connecter_t::sync_write_i,
                                                    shared_from_this(),
                                                    std::move(data_)));

   logtrace((RPC_CONNECTER, "async_send end ok." ) );
}

void rpc_connecter_t::sync_write_i(string& data_)
{
    logtrace((RPC_CONNECTER, "sync_write_i begin, len:[%u]...", data_.size() ) );

    /*
	//! first strategy chack   data
    if(!m_strategy->on_write_check(shared_from_this(), data_))
    {
        logwarn((RPC_CONNECTER, "async_send, strategy check fail data=<%s>", data_.c_str()));

        string err("aysnc write data check invalid.");
        m_strategy->on_error(shared_from_this(), RPC_BEAUDITED, err);
        return ;
    }
    */

    m_waiting_write_total += data_.size();
    if (m_waiting_write_total > 1024*1024*10)
    {
        logerror((RPC_CONNECTER, "waiting sending data too full! total:%lu, size:%lu", m_waiting_write_total, data_.size()));
    }

    m_sequences.push_back(std::move(data_));

    if(!m_write_in_progress)//not processing
    {
        if(start_sending_buffers_i()) set_write_state(true);
    }

    logtrace((RPC_CONNECTER, "sync_write_i end ok"));
}


bool rpc_connecter_t::start_sending_buffers_i()
{
    logtrace((RPC_CONNECTER, "start_sending_buffers_i ..."));
    if(!m_sequences.empty())
    {
        boost::asio::async_write(m_socket, std::move(boost::asio::buffer(*m_sequences.begin())),
                                 boost::bind(&rpc_connecter_t::write_completed_i,
                                                               shared_from_this(),
                                                               boost::asio::placeholders::error,
                                                               boost::asio::placeholders::bytes_transferred));

        logtrace((RPC_CONNECTER, "start_sending_buffers_i writing..."));
        return true;
    }

    logtrace((RPC_CONNECTER, "start_sending_buffers_i empty sequences!"));
    return false;
}

void rpc_connecter_t::write_completed_i(const boost::system::error_code& err_, size_t bytes_transferred_)
{
    logtrace((RPC_CONNECTER, "write_completed_i begin...,bytes_transferred:%u", bytes_transferred_));

    //! change to not in write processing
    set_write_state(false);

    //! clear sending seq
    m_waiting_write_total -= bytes_transferred_;
    m_sequences.pop_front();

    if(err_)
    {
        logerror((RPC_CONNECTER, "write_completed_i socket error=<%s>", err_.message().c_str()));
        if (!has_status(RPC_DISCONNECTED))
        {
            sync_close_i(RPC_CLOSE);
        }
        return;
    }

    if(start_sending_buffers_i()) set_write_state(true);
    logtrace((RPC_CONNECTER, "write_completed_i end ok" ) );
}

pair<const char*, size_t> rpc_connecter_t::sync_read_some()
{
    size_t len = m_socket.read_some(boost::asio::buffer(m_read_buffer));
    return pair<const char*, size_t>(m_read_buffer, len);
}

int rpc_connecter_t::sync_read_n(char* buff_, size_t len_)
{
    try{
        boost::asio::read(m_socket, boost::asio::buffer(buff_, len_));
    }
    catch(exception& e)
    {
        logerror((RPC_CONNECTER, "read_n err<%s>", e.what()));
        return -1;
    }
    return 0;
}

int rpc_connecter_t::sync_send(const string& data_)
{
    boost::asio::write(m_socket, boost::asio::buffer(data_));
    return 0;
}

void rpc_connecter_t::set_write_state(bool writing_)
{
    logwarn(("WRITE_STATE", "write state %d => %d", m_write_in_progress, writing_));
    m_write_in_progress = writing_;
}
