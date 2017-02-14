#ifndef _dbmid_service_h_
#define _dbmid_service_h_

#include "service_base.h"
#include "singleton.h"
#include "msg_def.h"
#include "dbmid_def.h"

class dbmid_handler_t : public rpc_bin_t 
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    dbmid_handler_t(io_t& io_);
    ~dbmid_handler_t();
private:
    void on_broken(sp_rpc_conn_t conn_);
    void handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_);
    void on_regist(sp_rpc_conn_t conn_, uint32_t sid_);
    void on_do(sp_rpc_conn_t conn_, const char* data_, size_t size_);
};

class dbmid_service_t : public service_base_t<dbmid_handler_t>
{
    typedef boost::asio::io_service io_t;
    friend class dbmid_handler_t;
public:
    dbmid_service_t();
    uint32_t sid() { return m_sid; }
    void start(uint16_t serid_, string ip_, string port_);
    io_t& get_io(int i_) { return m_io_pool.get_io_service(i_); }
private:
    bool                m_started;
    uint32_t            m_sid;
    io_service_pool_t   m_io_pool;
};

#define dbmid_service (singleton_t<dbmid_service_t>::instance())

#endif
