#ifndef _MONITOR_H_
#define _MONITOR_H_

#include <stdint.h>

#include <string>
#include <fstream>
using namespace std;

#include <ext/hash_map>
using namespace __gnu_cxx;

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

#include "singleton.h"
#include "io_wrap.h"

#define TIMER_EXPIRATION 3600

class monitor_t
{
public:
    struct hash_string_t
    {
        size_t operator()(const string& s)const
        {
            return __stl_hash_string(s.c_str());
        }
    };

    struct performance_info_t
    {
        unsigned long    max_cost;
        unsigned long    min_cost;
        uint64_t         total_cost;
        uint64_t         sum;
        uint64_t         up50sum;
        uint64_t         up100sum;
        uint64_t         up500sum;
        uint64_t         up1000sum;
    };

    typedef hash_map<string, performance_info_t, hash_string_t>  string_hm_t;
public:
    monitor_t();
    ~monitor_t();

    int start();
    int stop();
    int set_timeout(int seconds_);
    void async_performance_log(const string& op_, size_t cost_);
    void async_action_increment(const string& action_, size_t inc_ = 1);

private:
    int monitor_record(const boost::system::error_code& error_);
    int sync_performance_log_i(const string& op_, size_t cost_);
    performance_info_t& find_hm(const string& op_name_);
private:
    bool                                                m_started;

    int                                                 m_timer_expiration;
    boost::asio::io_service                             m_io;
    boost::asio::io_service::work                       m_io_work;
    boost::asio::deadline_timer                         m_timer;
    boost::shared_ptr<boost::thread>                    m_thread_ptr;
private:
    string_hm_t                                         m_hm_info;
};

#endif
