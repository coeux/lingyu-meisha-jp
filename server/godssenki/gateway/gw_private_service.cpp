#include "gw_private_service.h"
#include "log.h"
#include "remote_info.h"
#include "code_def.h"
#include "gw_public_service.h"
#include "config.h"

#define LOG "GW_PRIVATE" 

gw_private_handler_t::gw_private_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&gw_private_handler_t::on_regist);
    reg_call(&gw_private_handler_t::on_trans_msg);
    reg_call(&gw_private_handler_t::on_trans_msg_ext);
    //reg_call(&gw_private_handler_t::on_unicast);
    reg_call(&gw_private_handler_t::on_close_session);
    //reg_call(&gw_private_handler_t::on_multicast);
    reg_call(&gw_private_handler_t::on_broadcast);
}
gw_private_handler_t::~gw_private_handler_t()
{
}
int gw_private_handler_t::on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_)
{
    if (cmd_ == inner_msg_def::unicast_bin_t::cmd())
    {
        auto seskey = *((uint64_t*)(body_.c_str()));
        auto msg_cmd = *((uint16_t*)(body_.c_str()+sizeof(uint64_t)+4));
        auto msg_len = *((uint32_t*)(body_.c_str()+sizeof(uint64_t)));
        if (msg_cmd == lg_msg_def::ret_login_t::cmd())
        {

            auto msg = string(body_.c_str()+sizeof(uint64_t)+8, msg_len);
            lg_msg_def::ret_login_t ret;
            ret << msg;
            if (ret.code == SUCCESS)
            {
                gw_public_service.add_valid_seskey(seskey);
            }
        }

        auto conn = gw_public_service.get_client(seskey);
        if (conn != NULL)
        {
            auto jpk = string(body_.c_str()+sizeof(uint64_t), body_.size()-8);
            conn->async_send(std::move(jpk));
        }
    }

    return 0;
}
void gw_private_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn((LOG, "gw_private_service::on_broken..."));
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "server broken! sertype:%d, serid:%d", info->sertype(), info->serid()));
    /*
    if (info->sertype() == REMOTE_LOGIN)
    {
        gw_private_service.del_login(info->remote_id);
    }
    */
    if (info->sertype() == REMOTE_SCENE)
    {
        gw_private_service.del_login(info->remote_id);
        uint32_t sid = ((uint32_t)REMOTE_SCENE<<16)|(info->serid());
        gw_public_service.close_scene_conn(sid);
    }
    gw_private_service.del_server(info->remote_id);
    logwarn((LOG, "gw_private_service::on_broken...ok"));
}
void gw_private_handler_t::on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_)
{
    inner_msg_def::ret_regist_t ret;
    ret.sid = gw_private_service.sid(); 

    uint16_t sertype = jpk_.sid >> 16;
    uint16_t serid = jpk_.sid;


    if (sertype <= 0 || sertype >= REMOTE_ALL)
    {
        logerror((LOG, "unkonw server requset regist! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_UNKNOWN_SERVER;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    /*
     * 不适用
    if (!gw_private_service.has_scene_server_in_conf(serid))
    {
        config.reset();
        if (!gw_private_service.has_scene_server_in_conf(serid))
        {
            logerror((LOG, "unkonw server requset regist, no in config.lua! sertype:%d, serid:%d", sertype, serid));
            ret.code = ERROR_UNKNOWN_SERVER;
            async_call(conn_, ret);
            conn_->close();
            return;
        }
    }
    */

    if (gw_private_service.get_server(jpk_.sid) != NULL)
    {
        logerror((LOG, "server has registed! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_SERVER_HAS_REGISTED;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    remote_info_t* remote = new remote_info_t; 
    remote->is_client = false;
    remote->remote_id = jpk_.sid;
    remote->trans_id = jpk_.sid;
    conn_->set_data(remote);

    gw_private_service.add_server(jpk_.sid, conn_); 

    ret.code = SUCCESS;  
    async_call(conn_, ret);

    logwarn((LOG, "new server regist ok! sertype:%d, serid:%d", remote->sertype(), remote->serid()));

    /*
    if (sertype == REMOTE_LOGIN)
    {
        gw_private_service.add_login(jpk_.sid);
    }
    */
    if (sertype == REMOTE_SCENE)
        gw_private_service.add_login(jpk_.sid);

    //更新服务器列表
    if (sertype == REMOTE_SCENE)
    {
        conf_def::gameserver_list_t gslist;
        try
        {
            gslist << jpk_.jinfo;
        }catch(exception& ex){
            return;
        }

        for(conf_def::gameserver_t& gs : gslist.contain)
        {
            bool found = false;
            for(conf_def::gameserver_t& gsl : config.gslist.contain)
            {
                if (gs.hostnum == gsl.hostnum)
                {
                    found = true;
                    gsl = gs;
                    break;
                }
            }

            if (!found) 
            {
                config.gslist.contain.push_back(gs);
            }
        }
    }
}
void gw_private_handler_t::on_trans_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_server_msg_t& jpk_)
{
    if (jpk_.sid != 0)
    {
        if (gw_private_service.trans_to_server(jpk_.sid, jpk_.msg_cmd, jpk_.msg))
        {
            logerror((LOG, "no trans target! sertype:%d, serid:%d", jpk_.sid>>16, (uint16_t)jpk_.sid));
        }
    }
    else
    {
        gw_private_service.broadcast_to_server(REMOTE_SCENE, jpk_.msg_cmd, jpk_.msg);
    }
}
void gw_private_handler_t::on_trans_msg_ext(sp_rpc_conn_t conn_, inner_msg_def::trans_server_msg_ext_t& jpk_)
{
    if (jpk_.sids.empty())
    {
        gw_private_service.broadcast_to_server(REMOTE_SCENE, jpk_.msg_cmd, jpk_.msg);
    }
    else
    {
        for(auto sid:jpk_.sids)
        {
            if (gw_private_service.trans_to_server(sid, jpk_.msg_cmd, jpk_.msg))
            {
                logerror((LOG, "no trans target! sertype:%d, serid:%d", sid>>16, (uint16_t)sid));
            }
        }
    }
}
//发送到客户端
void gw_private_handler_t::on_unicast(sp_rpc_conn_t conn_, inner_msg_def::unicast_t& jpk_)
{
    logwarn((LOG, "on_unicast, seskey:%lu, msg_cmd:%u, msg_len:%u", jpk_.seskey, jpk_.msg_cmd, jpk_.msg.size()));

    if (jpk_.msg_cmd == lg_msg_def::ret_login_t::cmd())
    {
        lg_msg_def::ret_login_t ret;
        ret << jpk_.msg;
        if (ret.code == SUCCESS)
            gw_public_service.add_valid_seskey(jpk_.seskey);
    }

    gw_public_service.unicast_to_client(jpk_.seskey, jpk_.msg_cmd, jpk_.msg);
    /*
    if (gw_public_service.unicast_to_client(jpk_.seskey, jpk_.msg_cmd, jpk_.msg))
    {
        logerror((LOG, "exception! on_unicast,no seskey:%lu! ", jpk_.seskey));
    }
    */
}
void gw_private_handler_t::on_broadcast(sp_rpc_conn_t conn_, inner_msg_def::broadcast_t& jpk_)
{
    logwarn((LOG, "on_broadcast, msg_cmd:%u", jpk_.msg_cmd));
    gw_public_service.broadcast_client(jpk_.msg_cmd, jpk_.msg);
}
void gw_private_handler_t::on_close_session(sp_rpc_conn_t conn_, inner_msg_def::nt_close_session_t& jpk_)
{
    logwarn((LOG, "on_close_session, seskey:%lu", jpk_.seskey));
    sp_rpc_conn_t conn = gw_public_service.get_client(jpk_.seskey);
    if (conn != NULL)
    {
        conn->close();
    }
}
//=========================================================
gw_private_service_t::gw_private_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    service_base_t<gw_private_service_t>(m_io_pool.get_io_service(0));
}
void gw_private_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start gateway private service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_GW<<16)|serid_; 
    listen(ip_, port_);
    logwarn((LOG, "start gateway private service ok! serid:%u", serid_));
}
void gw_private_service_t::add_login(uint32_t sid_)
{
    auto it = std::find(m_login_array.begin(), m_login_array.end(), sid_);
    if (it == m_login_array.end())
    {
        logwarn((LOG, "add login ok! sid:%u", sid_));
        m_login_array.push_back(sid_);
    }
    else
    {
        logerror((LOG, "add existed login sid:%u", sid_));
    }
}
void gw_private_service_t::del_login(uint32_t sid_)
{
    auto it = std::find(m_login_array.begin(), m_login_array.end(), sid_);
    if (it != m_login_array.end())
    {
        logwarn((LOG, "del login ok! sid:%u", sid_));
        m_login_array.erase(it);
    }
    else
    {
        logerror((LOG, "del unknown login sid:%u", sid_));
    }
}
uint32_t gw_private_service_t::assign_login()
{
    if (m_login_array.empty())
    {
        return 0;
    }

    static int gid = 0;
    gid++;
    return m_login_array[gid % m_login_array.size()];
}
bool gw_private_service_t::has_scene_server_in_conf(uint16_t serid_)
{
    //检查配置中是否存在, 如果不存在则加载配置
    for(conf_def::gameserver_t& gs : config.gslist.contain)
    {
        if (gs.serid == serid_)
        {
            return true;
        }
    }

    return false;
}
