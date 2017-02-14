#ifndef _daemon_server_h_
#define _daemon_server_h_

#include "log.h"
#include "rpc_server.h"
#include "daemon_lua.h"
#include "jserialize_macro.h"
#include "file_monitor.h"

struct req_msg_t : public jcmd_t<1000>
{
    string  jmsg;
    JSON1(req_msg_t, jmsg)
};

struct ret_msg_t : public jcmd_t<1001>
{
    string jmsg;
    JSON1(ret_msg_t, jmsg)
};

//================================================

class daemon_pctl_t;

class daemon_server_t : public rpc_server_t<daemon_pctl_t>
{
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
    typedef boost::shared_ptr<file_monitor_t>       sp_file_monitor_t;
public:
    daemon_server_t()
    {
        m_file_monitor.reset(new file_monitor_t(get_io()));
        if (0 == m_file_monitor->init())
        {
            struct lamda_t {
                daemon_server_t* ds;
                void callback(const string& path_){
                    ds->load_script(path_.c_str());
                }
            };
            boost::shared_ptr<lamda_t> sp_lamda(new lamda_t); 
            sp_lamda->ds = this;
            m_file_monitor->cb_file_modified = boost::bind(&lamda_t::callback, sp_lamda, _1);
            m_file_monitor->add_watch_file("./script/entry.lua");
            m_file_monitor->start();
        }
    }

    daemon_lua_t& lua() {return m_lua;}

    void load_script(const string& path_)
    {
        m_lua.reload_script(path_);
    }

    void start_timer(int sec_)
    {
        if (m_timer == NULL)
        {
            m_timer.reset(new boost::asio::deadline_timer(get_io()));
        }

        m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(sec_));
        m_timer->async_wait(boost::bind(&daemon_server_t::on_time, this, boost::asio::placeholders::error));
    }
private:
    void on_time(const boost::system::error_code& error_)
    {
        if (error_)
            return;
        m_lua.do_script("on_timer", "");
    }
private:
    bool                    m_started;
    sp_timer_t              m_timer;
    daemon_lua_t            m_lua;
    sp_file_monitor_t       m_file_monitor;
};

#define daemon_server (singleton_t<daemon_server_t>::instance())

//================================================
class daemon_pctl_t : public rpc_t
{	
    typedef boost::shared_ptr<rpc_connecter_t>              sp_rpc_conn_t;
public:
	daemon_pctl_t(io_t& io_):rpc_t(io_){
		reg_call(&daemon_pctl_t::on_msg);
	}

    void on_broken(sp_rpc_conn_t conn_)
	{
        logerror(("DAEMON", "connecter broken!"));
	}

    void on_msg(sp_rpc_conn_t conn_, req_msg_t& jpk_)
	{
        logtrace(("DAEMON", "on_msg begin, recv:%s", jpk_.jmsg.c_str()));
        string jret = daemon_server.lua().do_script("on_msg", jpk_.jmsg);
        ret_msg_t ret;
        ret.jmsg = std::move(jret);
		async_call(conn_, ret);
        logtrace(("DAEMON", "on_msg end, send:%s", ret.jmsg.c_str()));
	}
};

#endif
