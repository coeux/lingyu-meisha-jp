#include "dbmid_service.h"
#include "log.h"
#include "remote_info.h"
#include "code_def.h"
#include "crypto.h"
#include "dbmid_msg_def.h"
#include "dbmid_cache.h"

#define LOG "DBMID_SERVICE" 


dbmid_handler_t::dbmid_handler_t(io_t& io_):rpc_t(io_)
{
}
dbmid_handler_t::~dbmid_handler_t()
{
}
void dbmid_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn((LOG, "dbmid_service::on_broken..."));
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "server broken! sertype:%d, serid:%d", info->sertype(), info->serid()));
    dbmid_service.del_server(info->remote_id);
    logwarn((LOG, "dbmid_service::on_broken...ok"));
}
void dbmid_handler_t::handle_msg(uint8_t flag_, uint16_t cmd_, uint16_t res_, const string& body_, sp_rpc_conn_t conn_)
{
    switch(cmd_)
    {
    case DBMID_CMD_REGIST: 
    {
        uint32_t sid = *((uint32_t*)body_.c_str());    
        on_regist(conn_, sid);
    }
    break;
    case DBMID_CMD_DO: 
        char pdata = new char[body_.size()]; 
        memcpy(pdata, body_.c_str(), body_.size()) 
        on_do(conn_, pdata, body_.size());
    break;
    }
}
void dbmid_handler_t::on_regist(sp_rpc_conn_t conn_, uint32_t sid_)
{
    uint16_t sertype = sid_ >> 16;
    uint16_t serid = sid_;

    if (sertype <= 0 || sertype >= REMOTE_ALL)
    {
        logerror((LOG, "unkonw server requset regist! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_UNKNOWN_SERVER;
        async_send(conn_, DBMID_CMD_REGIST, (void*)&ret, sizeof(ret));
        conn_->close();
        return;
    }

    remote_info_t* remote = new remote_info_t; 
    remote->is_client = true;
    remote->remote_id = sid_;
    remote->trans_id = sid_;
    conn_->set_data(remote);

    dbmid_service.add_client(sid_, conn_);

    ret.sid = dbmid_service.sid(); 
    ret.code = SUCCESS;  
    async_send(conn_, DBMID_CMD_REGIST, (void*)&ret, sizeof(ret));
}
//数据库操作
void on_do(sp_rpc_conn_t conn_, const char* data_, size_t size_);
{
    dbmid_op_t& op = *((dbmid_op_t*)body_.c_str());    
    db_service.async_do((uint64_t)op.uid, [](sp_rpc_conn_t conn_, char* data_, size_t size_){
        dbmid_op_t& op = *((dbmid_op_t*)data_);    
        switch(op.cmd)
        {
        case DBMID_CMD_SELECT: 
        break;
        case DBMID_CMD_INSERT: 
        break;
        case DBMID_CMD_UPDATE: 
        break;
        case DBMID_CMD_REMOVE: 
        break;
        }
    }, conn_, data_, size_);
}
//=========================================================
dbmid_service_t::dbmid_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    service_base_t<dbmid_handler_t>(m_io_pool.get_io_service(0));
}
void dbmid_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start dbmid service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_DB<<16)|serid_; 
    listen(ip_, port_);
    logwarn((LOG, "start dbmid service ok! serid:%u", serid_));
}
