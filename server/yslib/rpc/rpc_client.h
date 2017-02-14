#ifndef _RPC_CLIENT_H_
#define _RPC_CLIENT_H_

#include "rpc.h"
#include "io_service_pool.h"
#include "rpc_utility.h"

template<class Listener>
class rpc_client_t
{
public:
    typedef boost::asio::io_service          io_t;
    typedef boost::shared_ptr<rpc_connecter_t>  sp_rpc_conn_t;
public:
    rpc_client_t():m_io(io_pool.get_io_service())
    {
    }
    rpc_client_t(io_t& io_):m_io(io_)
    {
    }

    int connect(string ip_, string port_)
    {
        if (m_sp_conn != NULL && !m_sp_conn->has_status(RPC_DISCONNECTED))
        {
            m_sp_conn->close(RPC_CLOSE);    
        }

        if (m_sp_conn == NULL)
        {
            m_sp_conn.reset(new rpc_connecter_t(io_pool.get_io_service(), 
                create_listener(m_io)));
        }

        try
        {
            return m_sp_conn->sync_connect(ip_, port_);
        }
        catch(exception& ex)
        {
            logerror((RPC_CLIENT, "connect exception:%s, ip:%s, port:%s", ex.what(), ip_.c_str(), port_.c_str()));
            return -1;
        }
    }

    void close()
    {
        if (m_sp_conn != NULL)
            m_sp_conn->close(RPC_CLOSE);
    }

    io_t& get_io()
    {
        return m_io;
    }

    sp_rpc_conn_t get_conn() { return m_sp_conn; }           

    template<typename F, typename... Args>
    void async_do(F fun_, Args&... args_)
    {
        m_io.post(boost::bind(&rpc_client_t<Listener>::handle_do<F, Args...>, this, fun_, args_...));
    }

    template<class TMsg>
    void async_call(TMsg& msg_)
    {
        string out;
        msg_ >> out;
        async_call(TMsg::cmd(), out);
    }

    void async_call(uint16_t cmd_, const string& body_)
    {
        m_sp_conn->async_send(std::move(rpc_msg_util_t::compress_msg(cmd_, body_)));
    }

    template<class TMsg>
    static void async_call(sp_rpc_conn_t conn_, TMsg& msg_)
    {
        string out;
        msg_ >> out;
        conn_->async_send(std::move(rpc_msg_util_t::compress_msg(TMsg::cmd(), out)));
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
    sp_rpc_conn_t           m_sp_conn;
};

#endif
