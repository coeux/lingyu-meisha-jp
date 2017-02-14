#include "pf_service.h"
#include "log.h"
#include "code_def.h"
#include "config.h"
#include "db_service.h"
#include "msg_dispatcher.h"

#define LOG "PF_SERVICE" 

template<class TMsg>
int g_async_call(boost::shared_ptr<rpc_connecter_t> conn_, TMsg& msg_)
{
    string out;
    msg_ >> out;
    conn_->async_send(std::move(rpc_msg_util_t::compress_msg(TMsg::cmd(), out)));
    return 0;
}

pf_handler_t::pf_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&pf_handler_t::on_regist);
}
pf_handler_t::~pf_handler_t()
{
}
void pf_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn((LOG, "pf_handler_t::on_broken..."));
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;

    logwarn((LOG, "client broken! seskey:%lu", info->remote_id));
    pf_service.del_client(info->remote_id);

    logwarn((LOG, "pf_handler_t::on_broken...ok"));
}
void pf_handler_t::on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_)
{
    inner_msg_def::ret_regist_t ret;

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

    remote_info_t* remote = new remote_info_t; 
    remote->is_client = false;
    remote->remote_id = jpk_.sid;
    remote->trans_id = jpk_.sid;
    conn_->set_data(remote);

    pf_service.add_client(jpk_.sid, conn_);

    ret.sid = pf_service.sid(); 
    ret.code = SUCCESS;  
    async_call(conn_, ret);

    logwarn((LOG, "new server regist ok! sertype:%d, serid:%d", remote->sertype(), remote->serid()));
}
//平台通知用户购买yb
void pf_handler_t::on_user_buy_yb(sp_rpc_conn_t conn_, pf_msg_def::nt_user_pay_result_t& jpk_)
{
    //写购买数据库日志
    //

    //保存购买的yb数据,等待游戏服务器领取
    //

    //通知游戏服务器领取yb元宝
    uint32_t sid = MAKE_SID(REMOTE_SCENE, jpk_.serid);
    sp_rpc_conn_t sc_conn = pf_service.get_client(sid);
    if (sc_conn == NULL)
    {
        logerror((LOG, "no scene conn, serid:%d", jpk_.serid));
        return;
    }

    pf_msg_def::nt_pay_ok_t nt;
    nt.uid = jpk_.uid;
    async_send(sc_conn, nt);
}
//游戏服务器领取购买的道具
void pf_handler_t::on_req_given_goods(sp_rpc_conn_t conn_, pf_msg_def::req_given_goods_t& jpk_)
{
}
void pf_handler_t::on_req_pay(sp_rpc_conn_t conn_, pf_msg_def::req_given_goods_t& jpk_)
{
}
//===============================================
pf_service_t::pf_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    service_base_t<pf_handler_t>(m_io_pool.get_io_service(0));
}
void pf_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start pf service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_INVCODE<<16)|serid_; 
    listen(ip_, port_);

    logwarn((LOG, "start pf service ok! serid:%u", serid_));
}
