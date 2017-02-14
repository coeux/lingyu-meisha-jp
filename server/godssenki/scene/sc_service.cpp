#include "sc_service.h"
#include "signal_service.h"
#include "sc_logic.h"
#include "sc_invcode_client.h"
#include "sc_trial.h"
#include "sc_arena_rank.h"
#include "sc_gang.h"
#include "sc_cache.h"
#include "sc_server.h"
#include "sc_pay.h"
#include "sc_fp_rank.h"
#include "sc_lv_rank.h"
#include "sc_push_def.h"
#include "sc_activity.h"
#include "sc_arena.h"
#include "sc_rank.h"
#include "sc_boss.h"
#include "sc_card_event.h"
#include "sc_reward_mcard.h"
#include "sc_card_rank.h"
#include "sc_pub_rank.h"
#include "sc_message.h"
#include "sc_union_rank.h"
#include "sc_rank_match.h"
#include "sc_chip_smash.h"
#include "sc_guild_battle.h"
#include "sc_treasure.h"
#include "sc_new_rune.h"

#include "msg_def.h"
#include "remote_info.h"
#include "code_def.h"
#include "config.h"
#include "repo_def.h"
#include "file_monitor.h"

#define LOG "SC_SERVICE"

sc_handler_t::sc_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&sc_handler_t::on_ret_regist);
    reg_call(&sc_handler_t::on_trans_client_msg);
    reg_call(&sc_handler_t::on_role_deleted);
    reg_call(&sc_handler_t::on_pay_ok);
    reg_call(&sc_handler_t::on_expel);
    reg_call(&sc_handler_t::on_notalk);
    reg_call(&sc_handler_t::on_gm_mail);
    reg_call(&sc_handler_t::on_compensate);
    reg_call(&sc_handler_t::on_terminate_tm);
    reg_call(&sc_handler_t::on_notice);
    reg_call(&sc_handler_t::on_gm_gmail);
    reg_call(&sc_handler_t::on_reload);
    reg_call(&sc_handler_t::set_boss_available);
    reg_call(&sc_handler_t::on_reload_single);

}
int sc_handler_t::on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_)
{
    return 0;
}
void sc_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
    {
        logwarn((LOG, "unknown server broken!"));
        return;
    }
    logwarn((LOG, "server broken! sertype:%u, serid:%u", info->sertype(), info->serid()));
    if (m_client == NULL)
    {
        logerror((LOG, "server broken! no client!"));
        return;
    }
    if (!m_client->is_closed())
    {
        logwarn((LOG, "reset sertype:%u, serid:%u", info->sertype(), info->serid()));
        m_client->set_registed(false);
        m_client->start_timer();
    }
    else
    {
        logwarn((LOG, "erase sertype:%u, serid:%u", info->sertype(), info->serid()));
        sc_service.erase(info->remote_id);
    }
}
void sc_handler_t::on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_)
{
    if (jpk_.code == SUCCESS)
    {
        logwarn((LOG, "regist gateway ok! gw id:%d", (uint16_t)jpk_.sid));
        remote_info_t* info = new remote_info_t;
        info->is_client = false;
        info->remote_id = jpk_.sid;
        info->trans_id = jpk_.sid;
        conn_->set_data(info);

        if (!sc_service.get(jpk_.sid, m_client))
        {
            logerror((LOG, "can not found scene gw client!, gw id:%d", (uint16_t)jpk_.sid));
        }
    }
    else
    {
        sc_service.erase(jpk_.sid);
        logerror((LOG, "regist gateway failed!, gw id:%d", (uint16_t)jpk_.sid));
    }
}
void sc_handler_t::on_trans_client_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_client_msg_t& jpk_)
{
    logwarn((LOG, "on_trans_client_msg..., seskey:%lu, cmd:%u", jpk_.seskey, jpk_.msg_cmd));

    logic.handle_msg(jpk_.seskey, jpk_.msg_cmd, jpk_.msg, conn_);
}
//通知角色被删除
void sc_handler_t::on_role_deleted(sp_rpc_conn_t conn_, inner_msg_def::nt_role_deleted_t& jpk_)
{
    logwarn((LOG, "on_role_deleted, uid:%u", jpk_.uid));
    logic.on_role_deleted(jpk_.uid);
}
//通知支付到达
void sc_handler_t::on_pay_ok(sp_rpc_conn_t conn_, inner_msg_def::nt_buy_yb_ok_t& jpk_)
{
    logwarn((LOG, "on_pay_ok, serid:%u", jpk_.serid));
    logic.on_payed(jpk_.uid, jpk_.serid);
}
//通知账户被封停
void sc_handler_t::on_expel(sp_rpc_conn_t conn_, inner_msg_def::nt_expel_t& jpk_)
{
    logwarn((LOG, "on_expel, uid:%u", jpk_.uid));
    logic.on_expel(conn_,jpk_);
}
//通知禁言
void sc_handler_t::on_notalk(sp_rpc_conn_t conn_, inner_msg_def::nt_notalk_t& jpk_)
{
    logwarn((LOG, "on_notalk, uid:%u, enable:%d", jpk_.uid, jpk_.enable));
    logic.on_notalk(jpk_);
}
//通知gm mail
void sc_handler_t::on_gm_mail(sp_rpc_conn_t conn_, inner_msg_def::nt_gm_mail_t& jpk_)
{
    logwarn((LOG, "on_gm_mail, uid:%u", jpk_.uid));
    logic.on_gm_mail(jpk_);
}
//通知补偿到达
void sc_handler_t::on_compensate(sp_rpc_conn_t conn_, inner_msg_def::nt_compensate_t& jpk_)
{
    logwarn((LOG, "on_compensate, uid:%u", jpk_.uid));
    logic.on_compensate(jpk_);
}
//通知关闭服务器
void sc_handler_t::on_terminate_tm(sp_rpc_conn_t conn_, inner_msg_def::nt_terminate_tm_t& jpk_)
{
    logwarn((LOG, "on_terminate_tm, tm:%u", jpk_.tm));
    config.stoptm() = jpk_.tm;
}
void sc_handler_t::on_notice(sp_rpc_conn_t conn_, inner_msg_def::nt_notice_t& jpk_)
{
    logwarn((LOG, "on_notice, msg:%s", jpk_.msg.c_str()));
    pushinfo.push(jpk_.msg);
}
//通知用户邮件
void sc_handler_t::on_gm_gmail(sp_rpc_conn_t conn_, inner_msg_def::nt_gmail_t& jpk_)
{
    logwarn((LOG, "on_gm_gmail"));
    logic.on_gm_gmail(jpk_.uids, jpk_.msg);
}
//重新加载 
void sc_handler_t::on_reload(sp_rpc_conn_t conn_, inner_msg_def::nt_reload_t& jpk_)
{
    switch(jpk_.what)
    {
    case 1:
    {
        for(auto it=repo_mgr.contain.begin(); it!=repo_mgr.contain.end();it++)
        {
            repo_mgr.reload(it->first);
        }
        activity.on_reload_repo();
    }
    break;
    case 2:
        sc_service.hotload_config(config.get_path());
    break;
    }
}

//复活世界boss
void sc_handler_t::set_boss_available(sp_rpc_conn_t conn_, inner_msg_def::set_worldboss_alive_t& jpk_)
{
    world_boss.set_boss_available();
}

void sc_handler_t::on_reload_single(sp_rpc_conn_t conn_, inner_msg_def::nt_reload_single_t& jpk_)
{
    logwarn((LOG, "nt_reload_single:%s",jpk_.what.c_str()));
    repo_mgr.reload_single(jpk_.what);
}

//=========================================================
sc_gw_client_t::sc_gw_client_t(io_t& io_):rpc_client_t<sc_handler_t>(io_),
    m_started(false),
    m_sid(0),
    m_registed(false)
{
    m_timer.reset(new boost::asio::deadline_timer(get_io()));
}
sc_gw_client_t::~sc_gw_client_t()
{
    close();
}
void sc_gw_client_t::close()
{
    m_started = false;
    m_timer->cancel();
    rpc_client_t<sc_handler_t>::close();
}
void sc_gw_client_t::regist(uint32_t sid_, const string& ip_, const string& port_)
{
    if (m_started)
        return;
    m_started = true;

    m_sid = sid_; 
    m_ip = ip_;
    m_port = port_;

    start_timer();
}
void sc_gw_client_t::start_timer()
{
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&sc_gw_client_t::on_time, this, boost::asio::placeholders::error));
}
void sc_gw_client_t::on_time(const boost::system::error_code& error_)
{
    if (error_)
        return;

    logwarn((LOG, "begin connect to gateway[%s,%s]...", m_ip.c_str(), m_port.c_str()));
    connect(m_ip, m_port);
    if (get_conn()->has_status(RPC_DISCONNECTED))
    {
        logerror((LOG, "gateway server connect failed!, wait for connect..."));
        start_timer();
    }else{
        inner_msg_def::req_regist_t req;
        req.sid = m_sid;
        req.jinfo = m_jinfo;

        async_call(req);

        logwarn((LOG, "requset regist to gateway[%s,%s]", m_ip.c_str(), m_port.c_str()));
    }
}
void sc_gw_client_t::unicast(uint64_t seskey_, uint16_t cmd_, const string& msg_)
{
    inner_msg_def::unicast_t cast;
    cast.seskey = seskey_;
    cast.msg_cmd = cmd_;
    cast.msg = msg_;

    async_call(cast);
};
//=========================================================
sc_service_t::sc_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    m_timer.reset(new boost::asio::deadline_timer(get_io()));
    m_file_monitor.reset(new file_monitor_t(get_io()));
}
void sc_service_t::start(const string& serid)
{
    logwarn((LOG, "start scene service..."));

    if (m_started)
        return;
    m_started = true;

    m_sid = MAKE_SID(REMOTE_SCENE, atoi(serid.c_str()));

    auto it_scene = config.scene_map.contain.find(serid);
    if (it_scene == config.scene_map.contain.end()) 
    {
        logerror((LOG, "no scene config! serid:%s", serid.c_str()));
        return;
    }
    m_hosts = it_scene->second.contain_host;

    cache.set_size(config.local_cache.max);
    rpc_msg_util_t::opened=config.msg_compress.open;
    rpc_msg_util_t::ZLIB_SIZE_LIMIT=config.msg_compress.max;

    logic.set_hosts(m_hosts);
    reward_mcard.set_hosts(m_hosts);
    arena_cache.set_hosts(m_hosts);
    card_rank.set_hosts(m_hosts);
    chat_ins.set_hosts(m_hosts);
    union_rank.set_hosts(m_hosts);
    card_event_rank.set_hosts(m_hosts);
    server.load_db(atoi(serid.c_str()));
    grade_user_cache.load_db(m_hosts);
    gang_mgr.load_db(m_hosts);
    activity.load_db(m_hosts);
    arena_info_cache.load_db(m_hosts);
    rank_ins.load_db(m_hosts);
    arena_rank.load_db(m_hosts);
    fp_rank.load_db(m_hosts);
    chip_value.load_db(m_hosts);
    lv_rank.load_db(m_hosts);
    sc_gmail_mgr_t::load_hostmail(m_hosts);
    card_event_s.load_db(m_hosts);
    rank_match_s.load_db(m_hosts);
    guild_battle_s.load_db(m_hosts);
    pub_rank.load_db(m_hosts);
    treasure_cache.load_db(m_hosts);
    rune_message_s.load_db(m_hosts);

    if (SUCCESS == m_file_monitor->init())
    {
        struct lamda_t
        {
            static void fun(const string& path_)
            {
                if (path_ == config.get_path())
                {
                    sc_service.hotload_config(path_.c_str());
                }
                else
                {
                    repo_mgr.reload(path_);
                    activity.on_reload_repo();
                }
            }
        };
        m_file_monitor->cb_file_modified = boost::bind(&lamda_t::fun, _1);

        for(auto it=repo_mgr.contain.begin();it!=repo_mgr.contain.end();it++)
            m_file_monitor->add_watch_file(it->first);

        m_file_monitor->add_watch_file(config.get_path());

        m_file_monitor->start();
    }

    string json;
    conf_def::gameserver_list_t gslist;
    for(conf_def::gameserver_t& gs : config.gslist.contain)
    {
        if (gs.serid == atoi(serid.c_str()))
        {
            gslist.contain.push_back(gs);
        }
    }

    gslist >> json;

    for (auto it = config.gateway_map.contain.begin(); it != config.gateway_map.contain.end(); it++)
    {
        sp_sc_gw_client_t sp_client(new sc_gw_client_t(m_io_pool.get_io_service(0)));

        conf_def::gateway_t& gw = it->second;

        sp_client->set_regist_param(json);
        sp_client->regist(m_sid, gw.private_ip, gw.private_port);

        uint32_t gwsid = MAKE_SID(REMOTE_GW, atoi(it->first.c_str()));
        this->insert(gwsid, sp_client);
    };

    m_invcode_client.reset(new sc_invcode_client_t(m_io_pool.get_io_service(0)));
    const conf_def::invcode_t& inv = config.invcode;
    m_invcode_client->regist(m_sid, inv.ip, inv.port);

    start_timer();

    logwarn((LOG, "start scene service ok! serid:%u", (uint16_t)m_sid));
}
void sc_service_t::close()
{
    logwarn((LOG, "close scene service..."));
    m_started = false;
    m_timer->cancel();

    this->foreach([](uint32_t sid_, sp_sc_gw_client_t client_){
        client_->close();
    }); 

    m_invcode_client->close();

    //关闭文件监控
    m_file_monitor->close();

    //关闭服务器，保存数据
    logic.close();

    //等待所有和网关的连接都断开
    size_t closed_num = 0;
    while(closed_num < this->size()) { 
        this->foreach([&](uint32_t sid_, sp_sc_gw_client_t client_){
                if (client_->is_closed()) closed_num++;
        }); 
        logwarn((LOG, "wait client num:%d", this->size()));
        sleep(1); 
    }

    logwarn((LOG, "close scene service...ok, serid:%d", (uint16_t)m_sid));
}
void sc_service_t::start_timer()
{
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&sc_service_t::on_time, this, boost::asio::placeholders::error));
}
void sc_service_t::on_time(const boost::system::error_code& error_)
{
    start_timer();
    logic.handle_time(1);
    /*
    if (config.stoptm() > 0)
    {
        logwarn((LOG, "now:%lu, stoptm:%lu", time(NULL), config.stoptm()));
        if (time(NULL) >= config.stoptm())
        {
            signal_service.terminate();
        }
    }
    */
}
void sc_service_t::send_invcode_msg(uint16_t cmd_, const string& msg_)
{
    if (m_invcode_client != NULL)
        m_invcode_client->async_call(cmd_, msg_);
}
bool sc_service_t::has_host(int hostnum_)
{
    return (std::find(m_hosts.begin(), m_hosts.end(), hostnum_)!=m_hosts.end());
}
void sc_service_t::hotload_config(const string& path_)
{
    config.hotload(path_.c_str());

    cache.set_size(config.local_cache.max);
    rpc_msg_util_t::opened=config.msg_compress.open;
    rpc_msg_util_t::ZLIB_SIZE_LIMIT=config.msg_compress.max;

    string json;
    conf_def::gameserver_list_t gslist;
    for(conf_def::gameserver_t& gs : config.gslist.contain)
    {
        if (gs.serid == config.serid)
        { 
            gslist.contain.push_back(gs);
        }
    }

    gslist >> json;

    for (auto it = config.gateway_map.contain.begin(); it != config.gateway_map.contain.end(); it++)
    {
        sp_sc_gw_client_t  sp_client;
        uint32_t gwsid = MAKE_SID(REMOTE_GW, atoi(it->first.c_str()));
        if (!this->get(gwsid, sp_client))
        {
            sp_client.reset(new sc_gw_client_t(m_io_pool.get_io_service(0)));
            conf_def::gateway_t& gw = it->second;
            sp_client->set_regist_param(json);
            sp_client->regist(m_sid, gw.private_ip, gw.private_port);

            this->insert(gwsid, sp_client);
        }
    }
}
