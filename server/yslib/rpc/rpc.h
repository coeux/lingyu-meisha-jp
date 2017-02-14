#ifndef _RPC_H_
#define _RPC_H_

#include <string>
#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "rpc_acceptor.h"
#include "rpc_common_conn_protocol.h"
#include "log.h"
#include "rpc_log_def.h"
#include "thread_pool.h"
#include "performance_service.h"
#include "io_wrap.h"

class rpc_t : public rpc_common_conn_protocol_t, private boost::noncopyable
{
public:
    typedef boost::asio::io_service                     io_t;
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
private:
    typedef void(rpc_t::*void_fun_t)();
    struct call_i 
    {
        void_fun_t  cb;
        virtual bool happen(rpc_t* rpc_, uint16_t cmd_, const string& buff_, sp_rpc_conn_t conn_) = 0;
    };

    typedef boost::shared_ptr<call_i> sp_call_i;
    typedef unordered_map<uint16_t, sp_call_i> sp_call_hm_t;
public:
    rpc_t(io_t& io_);
    virtual ~rpc_t() {}

    template<class T, class TMsg>
    void reg_call(void(T::*method_)(sp_rpc_conn_t, TMsg&));

    template<class TMsg>
    static int async_call(sp_rpc_conn_t conn_, TMsg& msg_)
    {
        string out;
        msg_ >> out;
        return async_send(conn_, TMsg::cmd(), out);
    }

    static int async_call(sp_rpc_conn_t conn_, uint16_t cmd_, const string& body_);

    template<typename F, typename... Args>
    void async_do(F fun_, Args&... args_);

    virtual void on_broken(sp_rpc_conn_t conn_) = 0;
    virtual int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_){ return -1;}

protected:
    static int async_send(sp_rpc_conn_t conn_, uint16_t cmd_, const string& body_);
    void handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_);
private:
    template<typename F, typename... Args>
    void handle_do(F fun_, Args&... args_);
private:
    sp_call_hm_t                    m_calls;
};

template<class T, class TMsg>
void rpc_t::reg_call(void(T::*method_)(sp_rpc_conn_t, TMsg&))
{
    struct call_t: public call_i 
    {
        bool happen(rpc_t* rpc_, uint16_t cmd_, const string& buff_, sp_rpc_conn_t conn_)
        {
            TMsg msg;
            try
            {
                msg << buff_;
            }
            catch(exception& e_)
            {
                logerror((RPC, "exception:<%s>", e_.what()));
                return false;
            }

            typedef void(T::*F)(sp_rpc_conn_t, TMsg&);
            F tmp = (F)cb;
            (((T*)rpc_)->*tmp)(conn_, msg);
            return true;
        }
    };

    call_t& c = *(new call_t);
    c.cb = (void_fun_t)method_;

    m_calls[TMsg::cmd()] = sp_call_i(&c);
}


template<typename F, typename... Args>
void rpc_t::async_do(F fun_, Args&... args_)
{
    get_io().post(boost::bind(&rpc_t::handle_do<F, Args...>, this, fun_, args_...));
}

template<typename F, typename... Args>
void rpc_t::handle_do(F fun_, Args&... args_)
{
    fun_(args_...);
}

#endif
