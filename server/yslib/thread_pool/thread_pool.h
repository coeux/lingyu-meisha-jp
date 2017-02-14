#ifndef _THREAD_POOL_H_
#define _THREAD_POOL_H_ 

#include <vector>
#include <assert.h>
using namespace std;

#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <boost/asio.hpp>

#include "log.h"
#include "thread_pool_log_def.h"

class thread_pool_t : public boost::noncopyable
{
public:
    typedef boost::shared_ptr<boost::asio::io_service>          sp_ios_t;
    typedef boost::shared_ptr<boost::asio::io_service::work>    sp_work_t;
    typedef vector<sp_ios_t>                                    sp_ios_vt_t;
    typedef vector<sp_work_t>                                   sp_work_vt_t;
public:
    thread_pool_t():m_started(false), m_thread_num(1), m_poll_tid(0){}
    ~thread_pool_t() { stop(); }

    void start(uint16_t thread_num_ = 1);
    void stop();

    sp_ios_t get_io(uint16_t tid_)
    {
        if (!m_started)
            return sp_ios_t();

        uint16_t witch = tid_ % m_thread_num;  
        return m_sp_ios_vt[witch];
    }

    sp_ios_t poll_io()
    {
        if (!m_started)
            return sp_ios_t();

        uint16_t witch = m_poll_tid % m_thread_num;  
        m_poll_tid++;
        return m_sp_ios_vt[witch];
    }

    template<typename F, typename... Args>
    uint16_t async_do(uint16_t tid_, F fun_, Args... args_) //tid thread id
    {
        if (m_sp_ios_vt.empty())
            return -1;

        uint16_t witch = tid_ % m_thread_num;  
        m_sp_ios_vt[witch]->post(boost::bind(&thread_pool_t::handle_do<F, Args...>, this, fun_, args_...));
        return witch;
    }

    template<typename F, typename... Args>
    uint16_t async_do(F fun_, Args... args_) //tid thread id
    {
        if (m_sp_ios_vt.empty())
            return -1;

        uint16_t witch = m_poll_tid % m_thread_num;  
        m_poll_tid++;

        m_sp_ios_vt[witch]->post(boost::bind(&thread_pool_t::handle_do<F, Args...>, this, fun_, args_...));
        return witch;
    }

    int get_thread_num() { return m_thread_num; }
private:
    template<typename F, typename... Args>
    void handle_do(F fun_, const Args&... args_)
    {
        fun_(args_...);
    }
private:
    bool                    m_started;
    uint16_t                m_thread_num;
    uint16_t                m_poll_tid;
    sp_work_vt_t            m_sp_work_vt;
    sp_ios_vt_t             m_sp_ios_vt;
    boost::thread_group     m_threads;
};

#endif
