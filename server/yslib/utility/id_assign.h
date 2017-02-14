#ifndef _ID_ASSIGN_H_
#define _ID_ASSIGN_H_

#include "singleton.h"

#include <boost/thread.hpp>

#define MAX_ARRAY 1024 

template<class Scoped_lock, class Mutex>
class id_assign_t
{
public:
    id_assign_t():m_index(MAX_ARRAY)
    {
    }

	uint64_t new_id(uint16_t hostnum_)
    {
        Scoped_lock lock(m_mutex);

        if (m_index >= MAX_ARRAY)
        {
            for(int i=0; i<MAX_ARRAY; i++)
            {
                m_array[i] = new_id_i(hostnum_);
            }
            m_index = 0;
        }
        return m_array[m_index++];
    }
private:
    uint64_t new_id_i(uint16_t hostnum_)
    {
        uint32_t systime = time(NULL);
        if (systime != m_cur_systime)
        {
            m_n = 0;
            m_cur_systime = systime;
        }
        return ((uint64_t)hostnum_<<48|(uint64_t)m_cur_systime << 16|(m_n++));
    }
private:
    Mutex    m_mutex;
	uint32_t m_cur_systime;
	uint16_t m_n;
    uint64_t m_array[MAX_ARRAY];
    uint16_t m_index;
};

#define id_assign (singleton_t<id_assign_t<boost::mutex::scoped_lock, boost::mutex>>::instance())

#endif
