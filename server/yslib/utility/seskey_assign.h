#ifndef _seskey_assign_h_
#define _seskey_assign_h_

class seskey_assign_t
{
public:
	uint64_t new_seskey(uint16_t serid_)
    {
        uint32_t systime = time(NULL);
        if (systime != m_cur_systime)
        {
            m_n = 0;
            m_cur_systime = systime;
        }
        return (((uint64_t)serid_<<48)|((uint64_t)m_cur_systime << 16)|(m_n++));
    }
private:
	uint32_t m_cur_systime;
	uint32_t m_n;
};

#endif
