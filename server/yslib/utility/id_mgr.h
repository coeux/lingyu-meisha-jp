#ifndef _ID_MGR_H_
#define _ID_MGR_H_

#include "singleton.h"

class id_mgr_t
{
public:
    id_mgr_t():m_dbid(0), m_cur_systime(0), m_id(0){}

    void set_dbid(uint16_t dbid_)
    {
        m_dbid = dbid_;
    }

	uint64_t new_id()
    {
        uint64_t dbid = m_dbid;
        uint32_t systime = time(NULL);
        if (systime != m_cur_systime)
        {
            m_id = 0;
            m_cur_systime = systime;
        }
        return ((dbid << 48)|((uint64_t)m_cur_systime << 16)|(m_id++));
    }
private:
    uint16_t m_dbid;
	uint32_t m_cur_systime;
	uint16_t m_id;
};

#define id_mgr (singleton_t<id_mgr_t>::instance())

#endif
