#include "gw_public_service.h"
#include "log.h"
#include "code_def.h"
#include "seskey_assign.h"
#include "config.h"
#include "record_msg.h"
#include "random_key.h"
#include "frame_xtea.h"
#include "date_helper.h"

#include "gw_private_service.h"

#define LOG "GW_PUBLIC" 
#define MAX_PLAIN_LEN 8192

//#define RECORD_SCENE_MSG

gw_public_handler_t::gw_public_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&gw_public_handler_t::on_login);
    //reg_call(&gw_public_handler_t::on_req_new_seskey);
    reg_call(&gw_public_handler_t::on_req_gslist);
    //reg_call(&gw_public_handler_t::on_req_login_game);
    //reg_call(&gw_public_handler_t::on_nt_heartbeat);
    reg_call(&gw_public_handler_t::on_req_heartbeat);
    reg_call(&gw_public_handler_t::on_req_rolelist);
}
gw_public_handler_t::~gw_public_handler_t()
{
}
bool gw_public_handler_t::on_decrypt(sp_rpc_conn_t conn_, uint16_t cmd_, uint16_t res_, string& body_)
{
    if (!(res_ & 0x4000))
        return false;

    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return false;

    char buf[MAX_PLAIN_LEN];
    size_t plain_len = frame_xtea_decrypt((char*)body_.c_str(), body_.size(), buf, MAX_PLAIN_LEN, info->deckey.c_str());
    if (plain_len > MAX_PLAIN_LEN)
        throw std::runtime_error("ERROR DEC KEY!!!");

    body_ = string(buf, plain_len);

    return true;
}
void gw_public_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn((LOG, "gw_public_handler_t::on_broken..."));
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "client broken! seskey:%lu", info->remote_id));

    //转发客户端下线通知
    if (info != NULL && info->is_client && gw_public_service.has_client(info->remote_id))
    {
        inner_msg_def::nt_session_broken_t nt;
        nt.seskey = info->remote_id;

        inner_msg_def::trans_client_msg_t trans;
        trans.seskey = info->remote_id;
        trans.msg_cmd = inner_msg_def::nt_session_broken_t::cmd();
        nt >> trans.msg;

        gw_private_service.trans_to_server(info->trans_id, trans);

#ifdef RECORD_SCENE_MSG
        if ((info->trans_id)>>16 == REMOTE_SCENE)
            record_msg_ins.write(info->remote_id, 0, "");
        record_msg_ins.unreg(info->remote_id);
#endif
    }

    gw_public_service.del_client(info->remote_id);
    logwarn((LOG, "gw_public_handler_t::on_broken...ok"));
}
int gw_public_handler_t::on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();

    if (info != NULL && info->is_client && gw_public_service.has_client(info->remote_id))
    {
        if (lg_msg_def::req_mac_login_t::cmd() != cmd_ &&
            info->verified == false)
        {
            return -1;
        }

        inner_msg_def::trans_client_msg_t trans;
        trans.seskey = info->remote_id;
        trans.msg_cmd = cmd_;
        trans.msg = body_;

        if (0==gw_private_service.trans_to_server(info->trans_id, trans))
        {
            logwarn((LOG, "trans_to_server! seskey:%lu, cmd:%u, body:%s", trans.seskey, cmd_, body_.c_str()));

#ifdef RECORD_SCENE_MSG
            if ((info->trans_id)>>16 == REMOTE_SCENE)
                record_msg_ins.write(info->remote_id, cmd_, body_);
#endif
            return 0;
        }
        
    }
    return -1;
}
void gw_public_handler_t::on_login(sp_rpc_conn_t conn_, gw_msg_def::req_login_t& jpk_)
{
    logwarn((LOG, "client login... seskey:%lu", jpk_.seskey));

    gw_msg_def::ret_login_t ret;
    ret.code = SUCCESS;

    //检查seskey
    uint16_t serid = jpk_.seskey>>48;
    uint32_t stamp = jpk_.seskey>>16;

    if (serid != (uint16_t)gw_public_service.sid())
    {
        logerror((LOG, "client login but serid error! serid:%u", serid));

        ret.code = ERROR_SESKEY_EXCEPTION;
        async_call(conn_, ret);
        conn_->close();

        return;
    }

    //默认超时3600*60秒 
    uint32_t off = (time(NULL) - stamp)*0.001;
    if (off > 3600*60)
    {
        logerror((LOG, "client login but timeover! off:%u", off));

        ret.code = ERROR_SESKEY_TIMEOVER;
        async_call(conn_, ret);
        conn_->close();

        gw_public_service.del_trans(jpk_.seskey);

        return;
    }

    if (false == gw_public_service.add_client(jpk_.seskey, conn_))
    {

        logwarn((LOG, "client login but online! seskey:%lu", jpk_.seskey));
        ret.code = ERROR_SESKEY_EXISTED; 
        async_call(conn_, ret);
        conn_->close();

        return;
    }

    remote_info_t* remote = new remote_info_t;
    remote->is_client = true;
    remote->remote_id = jpk_.seskey;
    remote->trans_id = gw_public_service.get_trans(jpk_.seskey);
    if (remote->trans_id == 0)
        remote->trans_id = gw_private_service.assign_login();

    random_key_t rk(jpk_.seskey);
    rk.rand_str(remote->deckey, 16);

    conn_->set_data(remote);

    if (remote->trans_id != 0)
    {
        logwarn((LOG, "client login ok! seskey:%lu", jpk_.seskey));
        async_call(conn_, ret);
    }
    else
    {
        logwarn((LOG, "client login failed! no trans target! seskey:%lu", jpk_.seskey));
        ret.code = ERROR_GW_EXCEPTION;
        async_call(conn_, ret);
    }
}
void gw_public_handler_t::on_req_new_seskey(sp_rpc_conn_t conn_, gw_msg_def::req_new_seskey_t& jpk_)
{
    gw_msg_def::ret_new_seskey_t ret;
    ret.seskey = gw_public_service.reset_seskey(jpk_.seskey);
    if (ret.seskey != 0)
    {
        logwarn((LOG, "client change seskey:%lu", ret.seskey));
        ret.code = SUCCESS;
        async_call(conn_, ret);
    }
    else
    {
        logerror((LOG, "client change seskey failed!"));
        ret.code = ERROR_GW_RESET_SESKEY_FAILED;
        async_call(conn_, ret);
    }
}
void gw_public_handler_t::on_req_gslist(sp_rpc_conn_t conn_, gw_msg_def::req_gslist_t& jpk_)
{
    logwarn((LOG, "on_req_gslist, game server list size:%u!", config.gslist.contain.size()));

    gw_msg_def::ret_gslist_t ret;
    
    for(conf_def::gameserver_t& gs : config.gslist.contain)
    {
        gw_msg_def::jpk_gsinfo_t jpk;
        jpk.hostnum = gs.hostnum;
        jpk.name = gs.name;
        jpk.serid = gs.serid;
        ret.gslist.push_back(jpk);
        if (gs.recom)
        {
            ret.recom_gslist.push_back(jpk);
        }
    }
    async_call(conn_, ret);
}
void gw_public_handler_t::on_req_login_game(sp_rpc_conn_t conn_, sc_msg_def::req_login_t& jpk_)
{
    logwarn((LOG, "on_req_login_game..., uid:%d, serid:%u", jpk_.uid, jpk_.serid));

    remote_info_t* remote = conn_->get_data<remote_info_t>();
    if (remote == NULL || remote->verified == false)
    {
        logerror((LOG, "on_req_login_game, conn is not verified!"));
        conn_->close(RPC_SHUTDOWN);
        return;
    }

    sc_msg_def::ret_login_t ret;
    ret.code = SUCCESS;

    uint32_t scsid = ((uint32_t)REMOTE_SCENE<<16)|jpk_.serid;
    sp_rpc_conn_t sc_conn = gw_private_service.get_server(scsid);
    if (sc_conn == NULL)
    {
        logerror((LOG, "on_req_login_game, can not found target scene serid:%u", jpk_.serid));
        ret.code = ERROR_GW_NO_SCENE_SERVER;
        async_call(conn_, ret);
        return;
    }

    remote->trans_id = scsid;
    gw_public_service.add_trans(remote->remote_id, scsid);

    inner_msg_def::trans_client_msg_t trans;
    trans.seskey = remote->remote_id;
    trans.msg_cmd = sc_msg_def::req_login_t::cmd();
    jpk_ >> trans.msg;

    gw_private_service.trans_to_server(remote->trans_id, trans);


#ifdef RECORD_SCENE_MSG
    string sjson;
    jpk_ >> sjson;
    record_msg_ins.reg(remote->remote_id, jpk_.uid);
    record_msg_ins.write(remote->remote_id, jpk_.cmd(), sjson);
#endif

    logwarn((LOG, "on_req_login_game...ok, uid:%d, serid:%u", jpk_.uid, jpk_.serid));
}
void gw_public_handler_t::on_nt_heartbeat(sp_rpc_conn_t conn_, gw_msg_def::nt_heartbeat_t& jpk_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL || info->remote_id != jpk_.seskey)
    {
        logerror((LOG, "on_nt_heartbeat...unkonw conn! seskey:%lu", jpk_.seskey));
        conn_->close(RPC_SHUTDOWN);
    }
}
void gw_public_handler_t::on_req_heartbeat(sp_rpc_conn_t conn_, gw_msg_def::req_heartbeat_t& jpk_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL || info->remote_id != jpk_.seskey)
    {
        logerror((LOG, "on_nt_heartbeat...unkonw conn! seskey:%lu", jpk_.seskey));
        conn_->close(RPC_SHUTDOWN);
    }
    if (info->heart_stamp == 0)
        info->heart_stamp = date_helper.cur_sec();
    else if (date_helper.offsec(info->heart_stamp)<25)
    {
        conn_->close(RPC_SHUTDOWN);
        logerror((LOG, "!!!illegal heartbeat!!! seskey:%lu, stamp: %u, cur_sec", jpk_.seskey, info->heart_stamp, date_helper.cur_sec() ));
        return;
    }
    else info->heart_stamp = date_helper.cur_sec();

    gw_msg_def::ret_heartbeat_t ret;
    ret.code = SUCCESS;
    async_call(conn_, ret);
}
void gw_public_handler_t::on_req_rolelist(sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_)
{
    logwarn((LOG, "on_req_rolelist..., hostnum:%d, serid:%u", jpk_.hostnum, jpk_.serid));

    remote_info_t* remote = conn_->get_data<remote_info_t>();
    if (remote == NULL || remote->verified == false)
    {
        logerror((LOG, "on_req_rolelist, conn is not verified!"));
        conn_->close(RPC_SHUTDOWN);
        return;
    }

    uint32_t scsid = ((uint32_t)REMOTE_SCENE<<16)|jpk_.serid;
    sp_rpc_conn_t sc_conn = gw_private_service.get_server(scsid);
    if (sc_conn == NULL)
    {
        logerror((LOG, "on_req_rolelist, can not found target scene serid:%u", jpk_.serid));
        lg_msg_def::ret_rolelist_t ret;
        ret.code = ERROR_GW_NO_SCENE_SERVER;
        async_call(conn_, ret);
        return;
    }

    remote->trans_id = scsid;
    gw_public_service.add_trans(remote->remote_id, scsid);

    inner_msg_def::trans_client_msg_t trans;
    trans.seskey = remote->remote_id;
    trans.msg_cmd = lg_msg_def::req_rolelist_t::cmd();
    jpk_ >> trans.msg;

    gw_private_service.trans_to_server(remote->trans_id, trans);

    logwarn((LOG, "on_req_rolelist...ok, hostnum:%d, serid:%u", jpk_.hostnum, jpk_.serid));
}
//===============================================
gw_public_service_t::gw_public_service_t():
    service_base_t<gw_public_handler_t>(gw_private_service.get_io()),
    m_started(false),
    m_sid(0)
{
}
void gw_public_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start gateway public service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_GW<<16)|serid_; 
    listen(ip_, port_, true);

    logwarn((LOG, "start gateway public service ok! serid:%u", serid_));
}
void gw_public_service_t::add_trans(uint64_t seskey_, uint32_t sid_)
{
    m_trans_hm[seskey_] = sid_;
}
void gw_public_service_t::del_trans(uint64_t seskey_)
{
    m_trans_hm.erase(seskey_);
}
uint32_t gw_public_service_t::get_trans(uint64_t seskey_)
{
    auto it = m_trans_hm.find(seskey_);
    if (it != m_trans_hm.end())
        return it->second;
    return 0;
}
uint64_t gw_public_service_t::reset_seskey(uint64_t seskey_)
{
    auto it = m_trans_hm.find(seskey_);
    if (it != m_trans_hm.end())
    {
        inner_msg_def::nt_update_seskey_t nt;
        nt.old_seskey = seskey_;
        nt.now_seskey = singleton_t<seskey_assign_t>::instance().new_seskey((uint16_t)m_sid);
        gw_private_service.trans_to_server(it->second, nt);

        m_trans_hm.insert(make_pair(nt.now_seskey, it->second));
        m_trans_hm.erase(it);

        return nt.now_seskey;
    }
    return 0;
}
void gw_public_service_t::add_valid_seskey(uint64_t seskey_)
{
    sp_rpc_conn_t conn = get_client(seskey_);
    if (conn != NULL)
    {
        remote_info_t* info = conn->get_data<remote_info_t>();
        if (info != NULL)
            info->verified = true;
    }
}
void gw_public_service_t::close_scene_conn(uint32_t scid_)
{
    for (auto it=m_trans_hm.begin(); it != m_trans_hm.end(); it++)
    {
        if (it->second == scid_)
        {
            sp_rpc_conn_t conn = gw_public_service.get_client(it->first);
            if (conn != NULL)
            {
                conn->close();
            }
        }
    }
    m_trans_hm.clear();
}
