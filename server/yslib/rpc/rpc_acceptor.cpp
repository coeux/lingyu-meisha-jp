#include "rpc_acceptor.h"
#include "log.h"
#include "rpc_log_def.h"
#include "io_service_pool.h"

rpc_acceptor_t::rpc_acceptor_t(boost::asio::io_service& io_, cb_listen_strategy_creator_t cb_):
    m_started(false),
    m_use_monitor(false),
    m_io_service(io_),
    m_acceptor(m_io_service),
    m_cb_ls_creator(cb_)
{
    logtrace((RPC_ACCEPTOR, "rpc_acceptor_t"));
}

rpc_acceptor_t::~rpc_acceptor_t()
{
    logtrace((RPC_ACCEPTOR, "~rpc_acceptor_t begin ..."));
    
    if(m_started)
    {
        m_started = false;
        sync_close_i();
    }
    
    logtrace((RPC_ACCEPTOR, "~rpc_acceptor_t ok."));
}

int rpc_acceptor_t::start(const string& host_, const string& port_, bool use_monitor_)
{
    logtrace((RPC_ACCEPTOR, "start endpoint<%s:%s> begin ...", host_.c_str(), port_.c_str()));
    if(m_started)
    {
        logwarn((RPC_ACCEPTOR, "start already started"));
        return 0;
    }
    
    m_use_monitor = use_monitor_;
    m_listen_ip   = host_;
    m_listen_port = port_;

    sync_start_listen_i();

    m_started = true;
    logtrace((RPC_ACCEPTOR, "start end ok."));
    return 0;
}

int rpc_acceptor_t::stop()
{
    logtrace((RPC_ACCEPTOR, "stop begin ..."));
    if(!m_started)
    {
        logwarn((RPC_ACCEPTOR, "stop has already stop"));
        return 0;
    }

    m_started = false;
    sync_close_i();
    logtrace((RPC_ACCEPTOR, "stop end ok."));
    return 0;
}

int rpc_acceptor_t::sync_close_i()
{
    try
    {
        m_acceptor.cancel();
        m_acceptor.close();
    }
    catch(std::exception& ex)
    {
        logerror((RPC_ACCEPTOR, "sync_close_i exception<%s>!", ex.what()));
    }
    return 0;
}

int rpc_acceptor_t::sync_start_listen_i()
{
    try
    {
        logtrace((RPC_ACCEPTOR, "sync_start_listen_i begin ..."));
        boost::asio::ip::tcp::resolver resolver(m_io_service);
        boost::asio::ip::tcp::endpoint endpoint;
        boost::asio::ip::tcp::resolver::query query(boost::asio::ip::tcp::v4(), m_listen_ip, m_listen_port);
        endpoint = *resolver.resolve(query);

        m_acceptor.open(endpoint.protocol());
        m_acceptor.set_option(boost::asio::ip::tcp::acceptor::reuse_address(true));
        m_acceptor.bind(endpoint);
        m_acceptor.listen();

        sp_rpc_conn_t socket_ptr(new rpc_connecter_t(io_pool.get_io_service(), m_cb_ls_creator()));
        
        m_acceptor.async_accept(socket_ptr->socket(),
                                boost::bind(&rpc_acceptor_t::sync_accept_i,
                                            this,
                                            socket_ptr,
                                            boost::asio::placeholders::error));

        logtrace((RPC_ACCEPTOR, "sync_start_listen_i end ok."));
    }
    catch(std::exception& ex)
    {
        logerror((RPC_ACCEPTOR, "sync_start_listen_i exception<%s>!", ex.what()));
    }
    return 0;
}

int rpc_acceptor_t::sync_accept_i(sp_rpc_conn_t ptr_, const boost::system::error_code& error_)
{
    try
    {
        logtrace((RPC_ACCEPTOR, "sync_accept_i begin ..."));
        if (error_)
        {
            logerror((RPC_ACCEPTOR, "sync_accept_i acceptor async accept error<%s>", error_.message().c_str()));
            if (m_started == false)
            {
                logerror((RPC_ACCEPTOR, "sync_accept_i acceptor async accept error, has beed canceled"));
            }
            return -1;
        }

        ptr_->remote_open(m_use_monitor);

        sp_rpc_conn_t new_ptr(new rpc_connecter_t(io_pool.get_io_service(), m_cb_ls_creator()));
        m_acceptor.async_accept(new_ptr->socket(),
                boost::bind(&rpc_acceptor_t::sync_accept_i,
                    this,
                    new_ptr,
                    boost::asio::placeholders::error));

        logtrace((RPC_ACCEPTOR, "sync_accept_i end ok."));
    }
    catch(...)
    {}
    return 0;
}
