#include "login_client.h"
#include "iop.h"
#include <assert.h>

#define CLIENT "CLIENT"

login_client_t::login_client_t():rpc_client_t(/*iop.get_io()*/*singleton_t<thread_pool_t>::instance().poll_io())
{
    reg_call(CMD_LOGIN, &login_client_t::ret_login);
}
login_client_t::~login_client_t()
{
}
void login_client_t::start_test(uint64_t id_)
{
    m_uid = id_;
    m_sp_timer.reset(new boost::asio::deadline_timer(get_cur_io()));
    m_sp_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_sp_timer->async_wait(boost::bind(&login_client_t::on_time, this, boost::asio::placeholders::error));
}
void login_client_t::stop_test()
{
    m_sp_timer->cancel();
    get_conn()->close(RPC_SHUTDOWN);
}
void login_client_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    if (get_conn()->has_status(RPC_DISCONNECTED))
    {
        connect("127.0.0.1", "20001", true);

        /*
        if (!get_conn()->has_status(RPC_DISCONNECTED))
        {
            //logtrace((CLIENT, "conn sever ok, %d!", m_uid));
        }
        else
        {
            //logerror((CLIENT, "conn sever failed, %d!", m_uid));
        }
        */
    }

    if (get_conn()->has_status(RPC_CONNECTED))
    {
        //logtrace((CLIENT, "conn sever ok and send..., %d!", m_uid));

        rq_login_t rq;
        rq.id = m_uid;
        rq.name = "pangzi";
        rq.time = 12.2f;
        rq.level = 10;
        async_call(CMD_LOGIN, rq);
    }

    m_sp_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_sp_timer->async_wait(boost::bind(&login_client_t::on_time, this, boost::asio::placeholders::error));
}
void login_client_t::ret_login(sp_rpc_conn_t conn_, ret_login_t& ret_)
{
    //logtrace((CLIENT, "user:%lu, login success!", ret_.id));
    get_conn()->close(RPC_SHUTDOWN);
}
void login_client_t::on_broken(sp_rpc_conn_t conn_)
{
}
