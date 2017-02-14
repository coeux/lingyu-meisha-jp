#ifndef _PERFORMANCE_SERVICE_H_
#define _PERFORMANCE_SERVICE_H_

#include <sys/time.h>
#include <sys/types.h>

#include "monitor.h"

class performance_guard_t
{
public:
    performance_guard_t(const string& str_):m_str(str_)
    {
        gettimeofday(&m_tm, NULL);
    }

    ~performance_guard_t()
    {
        struct timeval temp_tm;
        gettimeofday(&temp_tm, NULL);
        unsigned long cost = (temp_tm.tv_sec - m_tm.tv_sec)*1000*1000 + (temp_tm.tv_usec - m_tm.tv_usec);

        singleton_t<monitor_t>::instance().async_performance_log(m_str, cost);
    }

private:
    string m_str;
    struct timeval m_tm;
};

#ifdef  PERFORMANCE_DISABLE
#define PERFORMANCE_GUARD(x) {}
#else
#define PERFORMANCE_GUARD(x) \
        performance_guard_t __guard_foo__(x)
#endif

#ifdef  PERFORMANCE_DISABLE
#define MONITOR_START() {}
#else
#define MONITOR_START() \
        singleton_t<monitor_t>::instance().start()
#endif

#ifdef  PERFORMANCE_DISABLE
#define MONITOR_STOP() {}
#else
#define MONITOR_STOP() \
        singleton_t<monitor_t>::instance().stop()
#endif

#ifdef  PERFORMANCE_DISABLE
#define MONITOR_SET_TIMER(x) {}
#else
#define MONITOR_SET_TIMER(x) \
        singleton_t<monitor_t>::instance().set_timeout(x)
#endif

#endif //! #ifndef _PERFORMANCE_SERVICE_H_
