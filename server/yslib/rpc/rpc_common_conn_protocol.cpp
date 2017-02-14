#include "rpc_common_conn_protocol.h"
#include "rpc_connecter.h"
#include "log.h"
#include "rpc_log_def.h"
#include "rpc_utility.h"
#include "rpc_conn_monitor.h"
#include "random.h"

rpc_common_conn_protocol_t::rpc_common_conn_protocol_t(io_t& io_):
                m_io(io_),
                m_msg_size(0),
                m_broken_flag(false)
{
}

void rpc_common_conn_protocol_t::reset()
{
    m_msg_size = 0;
    m_broken_flag = false;
}

rpc_common_conn_protocol_t::~rpc_common_conn_protocol_t()
{
}

int rpc_common_conn_protocol_t::on_connect(sp_rpc_conn_t conn_, const boost::system::error_code& e_)
{
    logtrace((RPC_CCP, "on_connect begin..." ));

    if (e_)
    {
        logwarn((RPC_CCP, "on_connect faild<%s>", e_.message().c_str()));
        post_broken_msg_i(conn_);
    }
    else
    {
        clear();
        conn_->async_read();
    }
    logtrace((RPC_CCP, "on_connect end ok" ));
    return 0;
}

int rpc_common_conn_protocol_t::on_remote_open(sp_rpc_conn_t conn_)
{
    logtrace((RPC_CCP, "on_remote_open begin..." ));

    if (conn_->has_type(RPC_PASSIVE))
    {
        logtrace((RPC_CCP, "add a passive connecter monitor" ));
        if (conn_->has_monitor())
            singleton_t<rpc_conn_monitor_t>::instance().add(conn_);
    }

    clear();
    conn_->async_read();
    logtrace((RPC_CCP, "on_remote_open end ok" ));
    return 0;
}

int rpc_common_conn_protocol_t::on_read(sp_rpc_conn_t conn_, const char* data_, size_t size_)
{
    logtrace((RPC_CCP, "on_read begin...size_=<%u>, m_msg_size[%u]", size_, m_msg_size));

    //! read head -> read body, while process all data end
    size_t left_len = size_;
    size_t tmp = 0;
    
    while (left_len > 0)
    {
        if (false == has_read_head_end_i())
        {
            tmp = read_head_i(data_, left_len);
            left_len -= tmp;
            data_    += tmp;
            if (has_read_head_end_i())
            {
                logtrace((RPC_CCP, "on_read got head, cmd:%u, body size:%u", m_head.cmd, m_head.len ));
            }
        }
        else
        {
            tmp = read_body_i(data_, left_len);
            left_len -= tmp;
            data_    += tmp;

            if (true == has_read_body_end_i())
            {
                if (conn_->has_type(RPC_PASSIVE))
                {
                    if (conn_->has_monitor())
                        singleton_t<rpc_conn_monitor_t>::instance().update(conn_);
                }

                //处理加密消息
                try
                {
                    on_decrypt(conn_, m_head.cmd, m_head.res, m_body);
                }
                catch(std::exception& e_)
                {
                    logerror((RPC, "exception:<%s>", e_.what()));
                    return -1;
                }

                m_io.post(std::bind(&rpc_common_conn_protocol_t::handle_msg, this, 1, m_head.cmd, m_head.res, m_body, conn_));

                memset(&m_head, 0, sizeof(m_head));
                m_msg_size = 0;
                m_body.clear();
            }
        }
    }

    conn_->async_read();
    logtrace((RPC_CCP, "on_read end ok!"));
    return 0;
}

void rpc_common_conn_protocol_t::on_error(sp_rpc_conn_t conn_, rpc_error_e type_, const string& err_msg_)
{
    logtrace((RPC_CCP, "on_error begin ...err_msg_<%s>", err_msg_.c_str()));

    /*
    if (conn_->has_type(RPC_PASSIVE))
    {
        if (conn_->has_monitor())
            singleton_t<rpc_conn_monitor_t>::instance().del(conn_);
    }

    post_broken_msg_i(conn_);
    */

    logtrace((RPC_CCP, "on_error end ok" ));
}
    
void rpc_common_conn_protocol_t::on_closed(sp_rpc_conn_t conn_)
{
    logtrace((RPC_CCP, "on_closed begin..." ));

    if (conn_->has_type(RPC_PASSIVE))
    {
        if (conn_->has_monitor())
            singleton_t<rpc_conn_monitor_t>::instance().del(conn_);
    }
    post_broken_msg_i(conn_);

    logtrace((RPC_CCP, "on_closed end ok" ));
}

size_t rpc_common_conn_protocol_t::read_head_i(const char* data_, size_t size_)
{
    size_t will_append = sizeof(m_head) - m_msg_size;
    if (will_append > size_) will_append = size_;

    void* dest = (char*)&m_head + m_msg_size;
    memcpy(dest, data_, will_append);
	m_msg_size += will_append;
    return will_append;
}

size_t rpc_common_conn_protocol_t::read_body_i(const char* data_, size_t size_)
{
    size_t will_append = m_head.len + sizeof(m_head) - m_msg_size;
    if (will_append > size_) will_append = size_;
    m_body.append(data_, will_append);
	m_msg_size += will_append;
    return will_append;
}

void rpc_common_conn_protocol_t::post_broken_msg_i(sp_rpc_conn_t conn_)
{
    if (true == m_broken_flag)
    {
        return;
    }

    m_broken_flag = true;
    m_io.post(boost::bind(&rpc_common_conn_protocol_t::handle_msg, this, 0, 0, 0, "", conn_));
}

void rpc_common_conn_protocol_t::clear()
{
    m_msg_size = 0;
    m_body.clear();
    m_broken_flag = false;
}
