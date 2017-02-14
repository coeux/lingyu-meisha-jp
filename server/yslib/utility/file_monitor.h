#ifndef _file_monitor_h_
#define _file_monitor_h_

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>

#include <string>
#include <vector>
using namespace std;


typedef boost::function<void(const string& path_)> cb_file_modified_t;

class file_monitor_t
{
    typedef boost::asio::io_service  io_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
public:
    cb_file_modified_t cb_file_modified;
public:
    file_monitor_t(io_t& io_);
    ~file_monitor_t();
    int  init();
    int  add_watch_file(const string& path_);
    void start();
    void close();
private:
    void start_timer();
    void update(const boost::system::error_code& error_);
private:
    int                     m_fd;
    bool                    m_closed;
    //[wd][path]
    map<uint32_t, string>   m_watch_files;
private:
    io_t                    &m_io;
    bool                    m_started;
    sp_timer_t              m_timer;
};

#endif
