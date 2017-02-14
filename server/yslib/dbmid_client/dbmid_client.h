#ifndef _dbmid_client_h_
#define _dbmid_client_h_

#include <iostream>
#include <vector>
using namespace std;
#include <boost/asio.hpp>
#include <boost/thread.hpp>

#include "rpc_msg_head.h"
#include "singleton.h"
#include "jserialize_macro.h"
#include "rpc_utility.h"
#include "performance_service.h"

#include "log.h"

#define DBMID_ERROR_ID 11000

class dbmid_client_t
{
    struct error_t
    {
        uint16_t code;
        JSON1(error_t, code)
    };
public:
    enum
    {
        BUFFER_SIZE = 8092
    };

    dbmid_client_t();

    int connect(const string& host_, const string& port_);

    template<class TParam, class TResult>
    int get(TParam& param_, TResult& result_)
    {
        PERFORMANCE_GUARD("dbmid_client");

        try
        {
            string buff;
            param_ >> buff;
            if ((send_buff(std::move(rpc_msg_util_t::compress_msg(TParam::cmd(), buff)))))
            {
                return -1;
            }
            rpc_msg_head_t head;
            buff.clear();
            if (read_msg(head, buff))
            {
                return -1;
            }
        
            if (head.cmd == DBMID_ERROR_ID)
            {
                error_t error;
                error << buff;
                return error.code;
            }
            else
            {
                cout << buff << endl;
                result_ << buff;
                return 0;
            }
        }catch(exception& e_)
        {
            logerror(("DBMID_CLIENT", "exception:<%s>", e_.what()));
            return -1;
        }
    }

    template<class TParam>
    int update(TParam& param_)
    {
        string buff;
        param_ >> buff;
        return (send_buff(std::move(rpc_msg_util_t::compress_msg(TParam::cmd(), buff))));
    }
private:
    int send_buff(string&& buff_);
    int read_msg(rpc_msg_head_t& head_, string& body_);
private:
    string                          m_host;
    string                          m_port;
    boost::asio::io_service         m_io;
    boost::asio::ip::tcp::socket    m_socket;
    char                            m_buff[BUFFER_SIZE];
};
//===================================================================================
class dbmid_helper_t
{
    typedef boost::shared_ptr<dbmid_client_t>                       sp_client_t;
    typedef boost::thread_specific_ptr<dbmid_client_t>              tss_conn_t;

    typedef boost::shared_ptr<boost::asio::io_service>              io_ptr_t;
    typedef boost::shared_ptr<boost::asio::io_service::work>        work_ptr_t;
public:
    dbmid_helper_t();
    ~dbmid_helper_t();

    int start(const string& host_, const string& port_, int thread_num_);
    int stop();

    sp_client_t block_conn() { return m_block_conn; }

    template<class T>
    void async_update(T& pk_)
    {
        m_tss_conn->update(pk_);
    }

    //! 异步方法，必须指明用户id, 保证一个用户的写都在一个线程上
    template<typename F, typename... Args>
    int async_do(uint64_t uid_, F fun_, Args&&... args_) //tid thread id
    {
        if (m_io.empty())
            return -1;

        uint16_t tid = uid_ % m_io.size();
        m_io[tid]->post(std::bind(&dbmid_helper_t::handle_do<F, Args&...>, this, fun_, std::forward<Args>(args_)...));
        return 0;
    }
private:
    template<typename F, typename... Args>
    void handle_do(F fun_, Args&... args_)
    {
        fun_(args_...);
    }
private:
    //! 初始化线程私有数据, 每个线程各自拥有单独的一个mysql的连接
    void init_thread(io_ptr_t io_, const string& host_, const string& port_);
private:
    vector<io_ptr_t>            m_io;
    vector<work_ptr_t>          m_work;
    boost::thread_group         m_thread_group;
    sp_client_t                 m_block_conn;
    tss_conn_t                  m_tss_conn;
};

#define dbmid_helper (singleton_t<dbmid_helper_t>::instance())

#endif
