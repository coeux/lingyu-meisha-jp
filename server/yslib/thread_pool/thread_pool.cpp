#include "thread_pool.h"
#include "log.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/syscall.h>
#define gettid() syscall(SYS_gettid)

void thread_pool_t::start(uint16_t thread_num_)
{
    if (m_started)
        return;

    logwarn(("THREAD_POOL", "start!"));
    m_started = true;
    m_thread_num = thread_num_;
    for(int i=0; i<thread_num_; i++)
    {
        sp_ios_t    sp_ios = sp_ios_t(new boost::asio::io_service());
        m_sp_ios_vt.push_back(sp_ios);

        sp_work_t   sp_work = sp_work_t(new boost::asio::io_service::work(*sp_ios));
        m_sp_work_vt.push_back(sp_work);

        m_threads.create_thread([=](){ 
            logwarn(("THREAD_POOL", "start thread:%d", gettid()));
            sp_ios->run(); 
        });
    }
}
void thread_pool_t::stop()
{
    if (!m_started)
        return;

    logwarn(("THREAD_POOL", "stop!"));
    m_started = false;
    m_sp_ios_vt.clear();
    m_sp_work_vt.clear();
    m_threads.join_all();
}
