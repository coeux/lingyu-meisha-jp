#ifndef _sc_service_h_
#define _sc_service_h_

#include "rpc_client.h"
#include "singleton.h"
#include "msg_def.h"
#include "concurrent_hash_map.h"

class sc_gw_client_t;
typedef boost::shared_ptr<sc_gw_client_t> sp_sc_gw_client_t;
class sc_handler_t : public rpc_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
public:
    sc_handler_t(io_t& io_);

    //网关断开
    void on_broken(sp_rpc_conn_t conn_);
    //收到未知消息，提交到lua处理
    int on_unknown_msg(uint16_t cmd_, const string& body_, sp_rpc_conn_t conn_);
    //返回网关注册信息
    void on_ret_regist(sp_rpc_conn_t conn_, inner_msg_def::ret_regist_t& jpk_);
    //客户端消息
    void on_trans_client_msg(sp_rpc_conn_t conn_, inner_msg_def::trans_client_msg_t& jpk_);
    //通知角色被删除
    void on_role_deleted(sp_rpc_conn_t conn_, inner_msg_def::nt_role_deleted_t& jpk_);
    //通知支付到达
    void on_pay_ok(sp_rpc_conn_t conn_, inner_msg_def::nt_buy_yb_ok_t& jpk_);
    //通知账户被封停
    void on_expel(sp_rpc_conn_t conn_, inner_msg_def::nt_expel_t& jpk_);
    //通知禁言
    void on_notalk(sp_rpc_conn_t conn_, inner_msg_def::nt_notalk_t& jpk_);
    //通知gm mail
    void on_gm_mail(sp_rpc_conn_t conn_, inner_msg_def::nt_gm_mail_t& jpk_);
    //通知补偿到达
    void on_compensate(sp_rpc_conn_t conn_, inner_msg_def::nt_compensate_t& jpk_);
    //通知关闭服务器时间
    void on_terminate_tm(sp_rpc_conn_t conn_, inner_msg_def::nt_terminate_tm_t& jpk_);
    //通知关闭服务器
    void on_notice(sp_rpc_conn_t conn_, inner_msg_def::nt_notice_t& jpk_);
    //通知用户邮件
    void on_gm_gmail(sp_rpc_conn_t conn_, inner_msg_def::nt_gmail_t& jpk_);
    //通知重新加载
    void on_reload(sp_rpc_conn_t conn_, inner_msg_def::nt_reload_t& jpk_);
    //世界boss复活
    void set_boss_available(sp_rpc_conn_t conn_, inner_msg_def::set_worldboss_alive_t& jpk_);
    void on_reload_single(sp_rpc_conn_t conn_, inner_msg_def::nt_reload_single_t& jpk_);

private:
    sp_sc_gw_client_t m_client;
};

class sc_gw_client_t : public rpc_client_t<sc_handler_t>
{
    friend class sc_handler_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
    typedef hash_map<int32_t, uint64_t> route_hm_t;
public:
    sc_gw_client_t(io_t& io_);
    ~sc_gw_client_t();

    uint32_t sid() {  return m_sid; }
    //设置注册参数
    void set_regist_param(const string& jinfo_) { m_jinfo = jinfo_; }

    void regist(uint32_t sid_, const string& ip_, const string& port_);
    void close();
    bool is_closed() { return !m_started; }

    void unicast(uint64_t seskey_, uint16_t cmd_, const string& msg_);
private:
    void start_timer();
    void on_time(const boost::system::error_code& error_);
    void set_registed(bool ok_) { m_registed = ok_; }
private:
    bool                m_started;
    uint32_t            m_sid;
    string              m_ip;
    string              m_port;
    sp_timer_t          m_timer;
    bool                m_registed;
    string              m_jinfo;
};

class file_monitor_t;
class sc_invcode_client_t;
class sc_service_t : public concurrent_hash_map_t<uint32_t, sp_sc_gw_client_t>
{
public:
    typedef boost::asio::io_service          io_t;
    typedef boost::shared_ptr<boost::asio::deadline_timer>  sp_timer_t;
    typedef boost::shared_ptr<sc_invcode_client_t>  sp_sc_invcode_client_t;
    typedef boost::shared_ptr<file_monitor_t>       sp_file_monitor_t;
public:
    sc_service_t();
    
    void start(const string& serid);
    void close();
    bool is_closed() { return !m_started; }

    uint32_t sid() {  return m_sid; }
    uint16_t hostnum() { return (uint16_t)m_sid; }
    io_t& get_io() { return m_io_pool.get_io_service(0); } 

    void send_invcode_msg(uint16_t cmd_, const string& msg_);
    sp_sc_invcode_client_t get_invclient() { return m_invcode_client; }
    
    template<typename F, typename... Args>
    int async_do(F fun_, Args&&... args_)
    {
        get_io().post(std::bind(&sc_service_t::handle_do<F, Args&...>, this, fun_, std::forward<Args>(args_)...));
        return 0;
    }

    bool has_host(int hostnum_);
    void hotload_config(const string& path_);
private:
    template<typename F, typename... Args>
    void handle_do(F fun_, Args&... args_)
    {
        fun_(args_...);
    }
private:
    void start_timer();
    void on_time(const boost::system::error_code& error_);
private:
    bool                    m_started;
    uint32_t                m_sid;
    io_service_pool_t       m_io_pool;
    sp_timer_t              m_timer;
    sp_sc_invcode_client_t  m_invcode_client;
    sp_file_monitor_t       m_file_monitor;
    vector<int>             m_hosts;
};

#define sc_service (singleton_t<sc_service_t>::instance())

#endif
