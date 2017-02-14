#ifndef _DB_SERVICE_H_
#define _DB_SERVICE_H_

#include <string>
using namespace std;

#include <boost/shared_ptr.hpp>
#include <boost/asio.hpp>
#include <boost/thread.hpp>

#include "ys_mysql.h"
#include "sql_result.h"
#include "log.h"
#include "db_log_def.h"
#include "singleton.h"


//! 异步操作数据库
class db_service_t
{
    typedef boost::shared_ptr<mysql_conn_t>                         sp_mysql_conn_t;
    typedef boost::thread_specific_ptr<mysql_conn_t>                tss_conn_t;

    typedef boost::shared_ptr<boost::asio::io_service>              io_ptr_t;
    typedef boost::shared_ptr<boost::asio::io_service::work>        work_ptr_t;
public:
    db_service_t();
    ~db_service_t();

    int start(const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_, int thread_num_);
    int stop();

    
    //同步执行select
    int sync_select(const string& sql_, sql_result_t& res_);
    int sync_execute(const string& sql_);
    
    //事务,此函数只能用于单线程的场景,不能用于多线程场景
    void async_begin_trans(uint64_t uid_);
    void async_commit_trans(uint64_t uid_);
    void async_rollback_trans(uint64_t uid_);

    //! 异步执行sql操作 只能用在async_do中
    int async_execute(const string& sql_);

    //! 异步执行步执行sql操作 只能用在async_do中
    int async_select(const string& sql_, sql_result_t& res_);

    //! 异步方法，必须指明用户id, 保证一个用户的写都在一个线程上
    template<typename F, typename... Args>
    int async_do(uint64_t uid_, F fun_, Args&&... args_) //tid thread id
    {
        if (m_io.empty())
            return -1;

        uint16_t tid = uid_ % m_io.size();
        m_io[tid]->post(std::bind(&db_service_t::handle_do<F, Args&...>, this, fun_, std::forward<Args>(args_)...));
        return 0;
    }

    //! 异步方法，平均分配线程, 注意，这个只适用于不需要关注读写顺序的场合
    template<typename F, typename... Args>
    int async_do(F fun_, Args&&... args_) //tid thread id
    {
        if (m_io.empty())
            return -1;

        m_poll_tid++;
        uint16_t tid = m_poll_tid % m_io.size();
        m_io[tid]->post(std::bind(&db_service_t::handle_do<F, Args&...>, this, fun_, std::forward<Args>(args_)...));
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
    void init_thread(io_ptr_t io_, const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_);
private:
    sql_result_t                m_sql_result;

    vector<io_ptr_t>            m_io;
    vector<work_ptr_t>          m_work;
    boost::thread_group         m_thread_group;
    sp_mysql_conn_t             m_block_conn;
    tss_conn_t                  m_tss_conn;

    uint16_t                    m_poll_tid;
    bool                        m_started;
};

#define db_service (singleton_t<db_service_t>::instance())


#endif
