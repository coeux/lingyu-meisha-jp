#ifndef _TICKER_H_
#define _TICKER_H_

#include <sys/time.h>

class ticker_t
{
    timeval m_val;
public:
    ticker_t()
    {
        gettimeofday(&m_val, NULL);
    }

    double count()
    {
        long long last = static_cast<long long>(1E6)*static_cast<long long>(m_val.tv_sec) + static_cast<long long>(m_val.tv_usec);
        
        gettimeofday(&m_val, NULL);
        long long now = static_cast<long long>(1E6)*static_cast<long long>(m_val.tv_sec) + static_cast<long long>(m_val.tv_usec);
        
        return (now - last) * 1E-6;
    }

    static long long time()
    {
        timeval val;
        gettimeofday(&val, NULL);
        return static_cast<long long>(1E6)*static_cast<long long>(val.tv_sec) + static_cast<long long>(val.tv_usec);
    }
};

#endif //TICKER_H_
