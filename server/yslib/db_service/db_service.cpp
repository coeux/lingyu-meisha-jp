#include "db_service.h"
#include <assert.h>

db_service_t::db_service_t():m_poll_tid(0),m_started(false)
{
}

db_service_t::~db_service_t()
{
    stop();
}

int db_service_t::start(const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_, int thread_num_)
{
    logtrace((DB_SERVICE, "start begin...<%s:%s:%s:%s:%s>", host_.c_str(), port_.c_str(), usr_.c_str(), pwd_.c_str(), database_.c_str()));
    if (m_started)
    {
        logerror((DB_SERVICE, "start begin...<%s:%s:%s:%s:%s> failed! started!", host_.c_str(), port_.c_str(), usr_.c_str(), pwd_.c_str(), database_.c_str()));
    }

    m_started = true;

    //初始化同步连接
    m_block_conn.reset(new mysql_conn_t("JSGMDB", host_, port_, usr_, pwd_, database_));
    if (m_block_conn->connect())
    {
        logerror((DB_SERVICE, "conn db failed!,<%s:%s:%s:%s:%s>",
                          host_.c_str(), port_.c_str(), usr_.c_str(), pwd_.c_str(), database_.c_str()));
        return -1;
    }


    //初始化线程
    for (int i = 0; i < thread_num_; ++i)
    {
        io_ptr_t io(new boost::asio::io_service());
        work_ptr_t work(new boost::asio::io_service::work(*io));
        m_io.push_back(io);
        m_work.push_back(work);

        m_thread_group.create_thread(boost::bind(&db_service_t::init_thread, this, io, host_, port_, usr_, pwd_, database_));
    }
    logtrace((DB_SERVICE, "start end ok"));
    return 0;
}

int db_service_t::stop()
{
    logwarn((DB_SERVICE, "close ..."));
    m_work.clear();
    m_thread_group.join_all();
    logwarn((DB_SERVICE, "close ... done"));
    return 0;
}

void db_service_t::init_thread(io_ptr_t io_, const string& host_, const string& port_, const string& usr_, const string& pwd_, const string& database_)
{
    //初始化异步连接
    logwarn((DB_SERVICE, "init_thread done"));
    //! mysql_conn_t必须赋值dbid，只是个字符串名称，可以为任意值
    m_tss_conn.reset(new mysql_conn_t("JSGMDB", host_, port_, usr_, pwd_, database_));
    if (m_tss_conn->connect())
    {
        logerror((DB_SERVICE, "conn db failed!,<%s:%s:%s:%s:%s>",
                          host_.c_str(), port_.c_str(), usr_.c_str(), pwd_.c_str(), database_.c_str()));
        return;
    }

    io_->run();
}

int db_service_t::async_execute(const string& sql_)
{
    logtrace((DB_SERVICE, "async_execute begin...sql_<%s>", sql_.c_str()));

    if (m_tss_conn->execute(sql_))
    {
        logerror((DB_SERVICE, "async_execute failed exe sql_<%s>", sql_.c_str()));
        return -1;
    }

    logtrace((DB_SERVICE, "async_execute end ok"));
    return 0;
}

void db_service_t::async_begin_trans(uint64_t uid_)
{
    db_service.async_do(uid_, [](){
        db_service.async_execute("begin");
    });
}
void db_service_t::async_commit_trans(uint64_t uid_)
{
    db_service.async_do(uid_, [](){
        db_service.async_execute("commit");
    });
}
void db_service_t::async_rollback_trans(uint64_t uid_)
{
    db_service.async_do(uid_, [](){
        db_service.async_execute("rollback");
    });
}

int db_service_t::async_select(const string& sql_, sql_result_t& res_)
{
    logtrace((DB_SERVICE, "async_select begin...sql_<%s>", sql_.c_str()));

    res_.clear_mysql_result();

    if (m_tss_conn->execute(sql_))
    {
        logerror((DB_SERVICE, "async_select failed exe sql_<%s>", sql_.c_str()));
        return -1;
    }

    mysql_res_t result(m_tss_conn->get_result());
    res_.set_mysql_result(result);

    logtrace((DB_SERVICE, "async_select end ok"));
    return 0;
}

int db_service_t::sync_select(const string& sql_, sql_result_t& res_)
{
    logtrace((DB_SERVICE, "sync_select begin...sql_<%s>", sql_.c_str()));

    res_.clear_mysql_result();

    if (m_block_conn == NULL)
    {
        logerror((DB_SERVICE, "sync_select block conn is NULL!", sql_.c_str()));
        return -1;
    }

    if (m_block_conn->execute(sql_))
    {
        logerror((DB_SERVICE, "sync_select failed exe sql_<%s>", sql_.c_str()));
        return -1;
    }

    mysql_res_t result(m_block_conn->get_result());
    res_.set_mysql_result(result);

    logtrace((DB_SERVICE, "sync_select end ok"));
    return 0;
}
int db_service_t::sync_execute(const string& sql_)
{
    logtrace((DB_SERVICE, "sync_execute begin...sql_<%s>", sql_.c_str()));

    if (m_block_conn == NULL)
    {
        logerror((DB_SERVICE, "sync_execute block conn is NULL!", sql_.c_str()));
        return -1;
    }

    if (m_block_conn->execute(sql_))
    {
        logerror((DB_SERVICE, "sync_execute failed exe sql_<%s>", sql_.c_str()));
        return -1;
    }

    logtrace((DB_SERVICE, "sync_execute end ok"));
    return 0;
}
