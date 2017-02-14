#ifndef _IO_WRAP_H_
#define _IO_WRAP_H_

#include <string>
using namespace std;

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <boost/shared_ptr.hpp>

class io_wrap_t: private boost::noncopyable
{
    typedef boost::asio::io_service          io_t;
public:
    explicit io_wrap_t(const char* name_);
    virtual ~io_wrap_t();

    boost::asio::io_service& get_io() { return m_io; }
private:
    string                      m_name;
    io_t&                       m_io;
};

#endif
