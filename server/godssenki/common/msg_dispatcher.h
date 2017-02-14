#ifndef _msg_dispatcher_h_
#define _msg_dispatcher_h_

#include "msg_def.h"
#include "rpc_utility.h"
#include "log.h"
#include "rpc_connecter.h"
#include "performance_service.h"
#include "io_service_pool.h"
#include <ext/hash_map>
using namespace __gnu_cxx;

template<class TClass>
class msg_dispatcher_t
{
public:
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
private:
    typedef void(TClass::*void_fun_t)();
    struct call_i 
    {
        void_fun_t  cb;
        virtual bool happen(TClass* rpc_, uint64_t seskey_, uint16_t cmd_, const string& buff_, sp_rpc_conn_t conn_) = 0;
    };

    typedef boost::shared_ptr<call_i> sp_call_i;
    typedef hash_map<uint16_t, sp_call_i> call_hm_t;
public:
    int handle_msg(uint64_t seskey_, uint16_t cmd_, const string& msg_, sp_rpc_conn_t conn_);
protected:
    template<class T, class TMsg>
    void reg_call(void(T::*method_)(uint64_t, sp_rpc_conn_t, TMsg&))
    {
        struct call_t: public call_i 
        {
            bool happen(T* rpc_, uint64_t seskey_, uint16_t cmd_, const string& buff_, sp_rpc_conn_t conn_)
            {
                TMsg msg;
                try
                {
                    msg << buff_;
                }
                catch(exception& e_)
                {
                    logerror(("MSG_DISPATCH", "exception:<%s>", e_.what()));
                    return false;
                }

                typedef void(T::*F)(uint64_t, sp_rpc_conn_t, TMsg&);
                F tmp = (F)this->cb;
                (((T*)rpc_)->*tmp)(seskey_, conn_, msg);
                return true;
            }
        };

        call_t& c = *(new call_t);
        c.cb = (void_fun_t)method_;

        m_calls[TMsg::cmd()] = sp_call_i(&c);
    }
private:
    call_hm_t                    m_calls;
};

template<class TClass>
int msg_dispatcher_t<TClass>::handle_msg(uint64_t seskey_, uint16_t cmd_, const string& msg_, sp_rpc_conn_t conn_)
{
    /*
    char buff[128];
    sprintf(buff, "rpc_t::handle_msg, cmd:%d", cmd_);
    PERFORMANCE_GUARD(buff);
    */

    //static const char* LOG = "MSG_DISPATCH";
    logtrace(("MSG_DISPATCH", "handle_msg...,seskey:%lu, cmd:%u, msg size:%u", seskey_, cmd_, msg_.size()));
    auto it = m_calls.find(cmd_);
    if (it != m_calls.end())
    {
        if (!it->second->happen((TClass*)this, seskey_, cmd_, msg_, conn_))
        {
            logerror(("MSG_DISPATCH", "handle_msg...failed,unpack exception! cmd:%u, msg:%s", cmd_, msg_.c_str()));
        }
        logtrace(("MSG_DISPATCH", "handle_msg...ok,call cmd:%u", cmd_));
        return 0;
    }
    else
    {
        //just for debug
        string all_cmd;
        for(auto it=m_calls.begin(); it!=m_calls.end(); it++)
        {
            char buf[8]; sprintf(buf, "%u", it->first);
            all_cmd.append(buf);
            all_cmd.append(",");
        }
        logwarn(("MSG_DISPATCH", "handle_msg...failed,unknown cmd:%u, msg:%s, all_cmd[%s]", cmd_, msg_.c_str(), all_cmd.c_str()));
        return -1;
    }
}

class msg_sender_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    static void init(int threadnum_)
    {
        m_io_pool.start(threadnum_);
    }

    template<class TMsg>
    static void unicast(uint64_t seskey_, sp_rpc_conn_t conn_, TMsg& msg_)
    {
        async_do(seskey_, [](uint64_t seskey_, sp_rpc_conn_t& conn_, TMsg& msg_){
                inner_msg_def::unicast_bin_t cast;
                cast.seskey = seskey_;
                string jstr; msg_ >> jstr;
                cast.msg = rpc_msg_util_t::compress_msg(TMsg::cmd(), jstr);

                string out;
                cast >> out;
                conn_->async_send(rpc_msg_util_t::make_msg(inner_msg_def::unicast_bin_t::cmd(), out));
        }, seskey_, conn_, msg_);
    }

    static void unicast(uint64_t seskey_, sp_rpc_conn_t conn_, uint16_t cmd_, string& msg_)
    {
        async_do(seskey_, [](uint64_t seskey_, sp_rpc_conn_t& conn_, uint16_t cmd_, string& msg_){
                inner_msg_def::unicast_bin_t cast;
                cast.seskey = seskey_;
                cast.msg = rpc_msg_util_t::compress_msg(cmd_, msg_);

                string out;
                cast >> out;
                conn_->async_send(rpc_msg_util_t::make_msg(inner_msg_def::unicast_bin_t::cmd(), out));
        }, seskey_, conn_, cmd_, msg_);
    }

private:
    template<typename F, typename... Args>
    static int async_do(uint64_t seskey_, F fun_, Args&&... args_) //tid thread id
    {
        size_t tid = seskey_% m_io_pool.get_io_size();
        m_io_pool.get_io_service(tid).post(std::bind(&msg_sender_t::handle_do<F, Args&...>, fun_, std::forward<Args>(args_)...));
        return 0;
    }

    template<typename F, typename... Args>
    static void handle_do(F fun_, Args&... args_)
    {
        fun_(args_...);
    }
private:
    static io_service_pool_t   m_io_pool;
};

#endif
