#include "rpc_conn_monitor.h"
#include "log.h"
#include "rpc_log_def.h"
#include "rpc_connecter.h"

rpc_conn_monitor_t::rpc_conn_monitor_t():
    m_started(false)
{
}

rpc_conn_monitor_t::~rpc_conn_monitor_t()
{
    stop();
}

int rpc_conn_monitor_t::start(const heart_beat_setting_t& heart_beat_setting_)
{
    if (m_started)
    {
        return 0;
    }

    m_rpc_conn_heart_beat.set_callback_function(boost::bind(&rpc_conn_monitor_t::handle_timeout, this, _1));
    m_rpc_conn_heart_beat.set_timeout(heart_beat_setting_.timeout_flag, heart_beat_setting_.timeout);
    m_rpc_conn_heart_beat.set_max_limit(heart_beat_setting_.max_limit_flag, heart_beat_setting_.max_limit);
    
    if (m_rpc_conn_heart_beat.start())
    {
        logerror((RPC_CONN_MGR, "start failed to start heart beat service"));
        return -1;
    }

    m_started = true;
    return 0;
}

int rpc_conn_monitor_t::stop()
{
    if (false == m_started)
    {
        return 0;
    }

    close_all();
    m_started = false;
    return 0;
}

void rpc_conn_monitor_t::add(sp_rpc_conn_t sp_conn_)
{
    if (!m_started)
        return;

    logtrace((RPC_CONN_MGR, "add connecter"));
    m_rpc_conn_heart_beat.async_add_element(sp_conn_);
}

void rpc_conn_monitor_t::update(sp_rpc_conn_t sp_conn_)
{
    if (!m_started)
        return;
    logtrace((RPC_CONN_MGR, "update connecter"));
    m_rpc_conn_heart_beat.async_update_element(sp_conn_);
}

void rpc_conn_monitor_t::del(sp_rpc_conn_t sp_conn_)
{
    if (!m_started)
        return;
    logtrace((RPC_CONN_MGR, "del connecter"));
    m_rpc_conn_heart_beat.async_del_element(sp_conn_);
}

void rpc_conn_monitor_t::close_all()
{
    if (!m_started)
        return;
    logwarn((RPC_CONN_MGR, "close_all begin..."));

    m_rpc_conn_heart_beat.trigger_all_timeout();

    logwarn((RPC_CONN_MGR, "close_all end ok"));
}

void rpc_conn_monitor_t::handle_timeout(sp_rpc_conn_t sp_conn_)
{
    if (!m_started)
        return;
    logwarn((RPC_CONN_MGR, "handle_timeout, to close connecter..."));
    
    sp_conn_->close(RPC_CLOSE);

    logwarn((RPC_CONN_MGR, "handle_timeout end ok"));
}

void rpc_conn_monitor_t::start_monitor(heart_beat_setting_t* heart_)
{
    heart_beat_setting_t heart_beat_set(0, 86400, 1, 50000);
    if (heart_ != NULL)
        heart_beat_set = *heart_;
    singleton_t<rpc_conn_monitor_t>::instance().start(heart_beat_set);
}

void rpc_conn_monitor_t::stop_monitor()
{
    singleton_t<rpc_conn_monitor_t>::instance().stop();
}
