#include <algorithm>   // Need sort(), copy()
#include <iterator>
#include <numeric>
#include <vector>
#include <list>
#include <map>
using namespace std;

#include <boost/lexical_cast.hpp>

#include "log.h"
#include "dbmid_client.h"

#define LOG "DBMID"

dbmid_client_t::dbmid_client_t():
    m_socket(m_io)
{
}

int dbmid_client_t::connect(const string& host_, const string& port_)
{
    logwarn((LOG, "dbmid_client_t::connect dbmid[%s,%s]...", host_.c_str(), port_.c_str()));

    m_host = (host_);
    m_port = (port_);

    boost::system::error_code error = boost::asio::error::host_not_found;
    try
    {
        boost::asio::ip::tcp::resolver  resolver(m_io);

        boost::asio::ip::tcp::resolver::query query(boost::asio::ip::tcp::v4(), m_host, m_port);
        boost::asio::ip::tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);
        boost::asio::ip::tcp::resolver::iterator end;
        while (error && endpoint_iterator != end)
        {   
            m_socket.close();
            m_socket.connect(*endpoint_iterator++, error);
        }
    }
    catch(exception& ex)
    {
        logerror((LOG, "dbmid_client_t::connect dbmid[%s,%s]...error:%s", ex.what()));
    }

   
    if (error)
    {
        logerror((LOG, "dbmid_client_t::connect err<%s>", error.message().c_str()));
        return -1; 
    }

    logwarn((LOG, "dbmid_client_t::connect dbmid[%s,%s]...ok!", host_.c_str(), port_.c_str()));
    return 0;
}

int dbmid_client_t::send_buff(string&& buff_)
{
    logtrace((LOG, "dbmid_client_t::send msg size:%d...", buff_.size()));

    boost::system::error_code err;
    boost::asio::write(m_socket, boost::asio::buffer(buff_), boost::asio::transfer_all(), err);

    if (err)
    {
        logerror((LOG, "dbmid_client_t::send err<%s>", err.message().c_str()));
        m_socket.close();
        return -1;
    }

    logtrace((LOG, "dbmid_client_t::send msg...ok", buff_.c_str()));
    return 0;
}

int dbmid_client_t::read_msg(rpc_msg_head_t& msg_head, string& body_)
{
    size_t msg_size = 0;
    boost::system::error_code err;

    do
    {
        size_t n = m_socket.read_some(boost::asio::buffer(m_buff, sizeof(m_buff)), err);

        if (err)
        {
            logerror((LOG, "dbmid_client_t::read err<%s>", err.message().c_str()));
            m_socket.close();
            return -1;
        }

        //! append  head
        size_t will_append = 0;
        if (msg_size < sizeof(msg_head))
        {
            will_append = sizeof(msg_head) - msg_size;
            if (will_append > n)
            {   
                memcpy((char *)&msg_head + msg_size, m_buff, n);
                msg_size += n;
                continue;
            }
            else
            {   
                memcpy(&msg_head + msg_size, m_buff, will_append);
                msg_size += will_append;
            }
        }

        //! append body
        size_t body_will_append = n - will_append;
        body_.append(m_buff + will_append, body_will_append);
    }   
    while (body_.size() < msg_head.len);

    logtrace((LOG, "dbmid_client_t::recv msg, head:%d, body:%s", msg_head.cmd, body_.c_str()));

    return 0;
}
//======================================================
dbmid_helper_t::dbmid_helper_t()
{
}

dbmid_helper_t::~dbmid_helper_t()
{
    stop();
}

int dbmid_helper_t::start(const string& host_, const string& port_, int thread_num_)
{
    logtrace((LOG, "start begin...<%s:%s>",
                          host_.c_str(), port_.c_str()));

    //初始化同步连接
    m_block_conn.reset(new dbmid_client_t());
    if (m_block_conn->connect(host_, port_))
    {
        logerror((LOG, "conn dbmid failed!,<%s:%s>", host_.c_str(), port_.c_str()));
        return -1;
    }

    //初始化线程
    for (int i = 0; i < thread_num_; ++i)
    {
        io_ptr_t io(new boost::asio::io_service());
        work_ptr_t work(new boost::asio::io_service::work(*io));
        m_io.push_back(io);
        m_work.push_back(work);

        m_thread_group.create_thread(boost::bind(&dbmid_helper_t::init_thread, this, io, host_, port_));
    }
    logtrace((LOG, "start end ok"));
    return 0;
}

int dbmid_helper_t::stop()
{
    m_work.clear();
    m_thread_group.join_all();
    return 0;
}

void dbmid_helper_t::init_thread(io_ptr_t io_, const string& host_, const string& port_)
{
    //初始化异步连接
    logwarn((LOG, "init_thread done"));

    m_tss_conn.reset(new dbmid_client_t());
    if (m_tss_conn->connect(host_, port_))
    {
        logerror((LOG, "conn dbmid failed!,<%s:%s>", host_.c_str(), port_.c_str()));
        return;
    }

    io_->run();
}
