#ifndef _IOP_H_
#define _IOP_H_

#include "singleton.h"
#include "io_wrap.h"


class io_pool_t
{
public:
    io_pool_t():m_iow("io_pool_t")
    {
    }
    boost::asio::io_service& get_io() { return m_iow.get_io(); }
private:
    io_wrap_t m_iow;
};

#define iop (singleton_t<io_pool_t>::instance())

#endif
