#ifndef _RPC_CONN_MONITOR_H_
#define _RPC_CONN_MONITOR_H_

#include <ext/hash_map>
#include <ext/hash_set>
using namespace __gnu_cxx;

#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include "singleton.h"
#include "heart_beat_service.h"

//! heart beat setting from configure file
struct heart_beat_setting_t
{
    heart_beat_setting_t()
    {
        memset(this, 0, sizeof(heart_beat_setting_t));
    }

    heart_beat_setting_t(bool timeout_flag_, unsigned int timeout_, bool max_limit_flag_, unsigned long max_limit_)
        : timeout_flag(timeout_flag_), timeout(timeout_), max_limit_flag(max_limit_flag_), max_limit(max_limit_)
    {
    }

    bool timeout_flag;
    unsigned int timeout;
    bool max_limit_flag;
    unsigned long max_limit;
};

class rpc_connecter_t;
class rpc_conn_monitor_t
{
public:
    typedef boost::shared_ptr<rpc_connecter_t>  sp_rpc_conn_t;
private:
    struct hash_conn_t
    {
        size_t operator()(const sp_rpc_conn_t& p_) const
        {
            return (size_t)p_.get();
        }
    };
    typedef heart_beat_service_t<sp_rpc_conn_t, hash_conn_t>   rpc_conn_heart_beat_t;
public:
    rpc_conn_monitor_t();
    ~rpc_conn_monitor_t();

    int start(const heart_beat_setting_t& heart_beat_setting_);
    int stop();

    void add(sp_rpc_conn_t sp_conn_);
    void update(sp_rpc_conn_t sp_conn_);
    void del(sp_rpc_conn_t sp_conn_);

    void close_all();

    static void start_monitor(heart_beat_setting_t* heart_);
    static void stop_monitor();
private:
    void handle_timeout(sp_rpc_conn_t sp_conn_);
private:
    bool                    m_started;
    rpc_conn_heart_beat_t   m_rpc_conn_heart_beat;
};


#endif
