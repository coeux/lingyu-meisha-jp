#ifndef _RPC_SERVER_H_
#define _RPC_SERVER_H_

#include "rpc.h"
#include "rpc_conn_monitor.h"
#include "rpc_utility.h"
#include "io_service_pool.h"

template<class Listener>
class rpc_server_t
{
    typedef boost::asio::io_service                     io_t;
    typedef boost::shared_ptr<rpc_acceptor_t>   sp_rpc_acc_t;
    typedef boost::shared_ptr<rpc_connecter_t>  sp_rpc_conn_t;
public:
    rpc_server_t():m_io(io_pool.get_io_service()){}
    rpc_server_t(io_t& io_):m_io(io_){}

    int listen(string host_, string port_, bool use_monitor_=false)
    {
        if (!m_sp_acc)
        {
            logtrace((RPC_SERVER, "listen: ip:%s, port:%s", host_.c_str(), port_.c_str()));
            m_sp_acc.reset(new rpc_acceptor_t(io_pool.get_io_service(), 
                    boost::bind(&rpc_server_t<Listener>::create_listener, boost::ref(m_io))));
        }

        try
        {
            m_sp_acc->start(host_, port_, use_monitor_);
            return 0;
        }
        catch(exception& e)
        {
            logerror((RPC_SERVER, "listen exception:%s, ip:%s, port:%s", e.what(), host_.c_str(), port_.c_str()));
            m_sp_acc.reset();
            return -1;
        }
    }

    virtual void close()
    {
        if (m_sp_acc)
        {
            m_sp_acc->stop();
        }
    }

    io_t& get_io()
    {
        return m_io;
    }

    template<typename F, typename... Args>
    void async_do(F fun_, Args&... args_)
    {
        m_io.post(boost::bind(&rpc_server_t<Listener>::handle_do<F, Args...>, this, fun_, args_...));
    }

    template<class TMsg>
    int async_call(sp_rpc_conn_t conn_, TMsg& msg_)
    {
        string out;
        msg_ >> out;
        return async_call(conn_, TMsg::cmd(), out);
    }

    int async_call(sp_rpc_conn_t conn_, uint16_t cmd_, const string& body_)
    {
        conn_->async_send(std::move(rpc_msg_util_t::compress_msg(cmd_, body_)));
        return 0;
    }

private:
    static rpc_listen_strategy_i* create_listener(io_t& io_)
    {
        return new Listener(io_);
    }

    template<typename F, typename... Args>
    void handle_do(F fun_, Args&... args_)
    {
        fun_(args_...);
    }
private:
    io_t&                   m_io;
    sp_rpc_acc_t            m_sp_acc;
};

#endif
