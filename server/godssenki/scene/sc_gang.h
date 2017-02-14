#ifndef _sc_gang_h_
#define _sc_gang_h_

#include <boost/shared_ptr.hpp> 

#include <deque>
#include <map>
#include <string>
using namespace std;

#include "msg_def.h"
#include "db_ext.h"

enum ganguser_flag_e
{
    gang_member = 0,
    gang_adm,
    gang_chairman,
};

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_gang_t;
typedef boost::shared_ptr<sc_gang_t> sp_gang_t;

typedef sc_msg_def::jpk_hongbao_t sc_hongbao_t;

class sc_gang_mgr_t;
class sc_ganguser_t
{
    friend class sc_gang_mgr_t;
    friend class sc_gang_t;
public:
    db_GangUser_ext_t db;
    bool isonline;
public:
    sc_ganguser_t();
    ~sc_ganguser_t();
    int on_daily_pay(int pay_);
    void get_mem_jpk(sc_msg_def::jpk_gangmem_t& jpk_, int uid_);
    void get_gskl_jpk(vector<sc_msg_def::jpk_gskl_t>& jpk_);
    void upgrade_gskl(int resid_);
    int  get_gskl_lv(int resid_);
    int  get_gskl_pro(int type_);
    void on_change_gm(int gm_);
    void on_rename(const string& name_);
    void set_leave_gang();
    void enter_pray(sp_user_t sp_user_);
    void pray(sp_user_t sp_user_);
    int get_daily_pay();
    void update_praynum();
    int get_pray_num() { return m_pray_num; }
    void save_db();
    //int get_equip_level(int uid, int pid);
private:
    sp_gang_t get_gang();
private:
    int                 m_daily_pay; 
    uint32_t            m_last_pay_time;
    vector<int32_t*>    m_dbgsklv;
    uint32_t            m_last_pray_time;
    int                 m_pray_num;
    int                 m_max_pray_num;
    map<uint32_t, uint32_t> m_gotted_hongbao; //[uid][stamp]
};
typedef boost::shared_ptr<sc_ganguser_t> sp_ganguser_t;

struct sc_gang_msg_t
{
    int type;
    uint32_t stamp;
    string nickname;
    uint32_t grade;
    string msg;
};

struct gang_add_req_t
{
    int uid;
    int hostnum;
    string nickname;
    int grade;
    int rank;
};

class sc_gang_t
{
    friend class sc_gang_mgr_t;

    typedef map<int, gang_add_req_t> add_req_hm_t;
    //[uid_][sp_ganguser_t]
    typedef unordered_map<int32_t, sp_ganguser_t> ganguser_hm_t;
public:
    db_Gang_ext_t db;
public:
    sc_gang_t();
    ~sc_gang_t();

    void broadcast(int32_t cmd_, string &msg_);

    void on_login(int uid_);
    void on_session_broken(int32_t uid_);
    void on_upgrade(int32_t uid_, int32_t grade_);
    void on_rank_changed(int32_t uid_, int32_t rank_);

    void add_user(sp_ganguser_t sp_guser_);
    void new_user(sp_user_t sp_user_, int flag_);
    void new_user(gang_add_req_t& req_, int flag_);
    bool get_user(int32_t uid_, sp_ganguser_t& sp_guser_);

    int online_num() { return m_online_role.size(); }
    int total_num() { return m_ganguser_hm.size(); }

    void add_msg(sp_ganguser_t sp_ganuser_, int type_, string& msg_);
    void get_msg(vector<string>& msgs_);

    bool has_adm(int32_t uid_) { return m_adm_uid.find(uid_) != m_adm_uid.end(); }
    int  set_adm(int32_t cuid_,int32_t uid_, bool isadm_);

    void get_pro_jpk(int uid_, sc_msg_def::jpk_gang_pro_t& jpk_);

    int  add_req(sp_user_t sp_user_);
    void del_req(int uid_);
    void get_req(vector<sc_msg_def::jpk_gang_requser_t>& reqs_);
    int deal_req(int uid_, int flag_);
    int get_req_count();

    void get_memjpk_list(vector<sc_msg_def::jpk_gangmem_t>& list_, int page_);
    int kick_mem(int uid_, sp_ganguser_t sp_guser_);
    int leave_gang(sp_ganguser_t sp_guser_);

    int change_charman(sp_ganguser_t a_, sp_ganguser_t b_);
    int on_role_deleted(int uid_);
    int set_boss_time(sp_ganguser_t sp_guser_, int day_);
    void update_guser_paynum();
    void on_boss_killed(sp_ganguser_t sp_guser_);

    void save_db();

    sp_ganguser_t get_chairman() { return m_sp_chairman; }

    int given_hongbao(sp_user_t sp_user_, uint64_t id_);
private:
    void sort_mem();
    void save_add_res(int uid_, int code_, string& msg_);
    void nt_add_res(int uid_);
private:
    //[uid]
    set<int32_t>            m_online_role;
    ganguser_hm_t           m_ganguser_hm;
    deque<sc_gang_msg_t>    m_gang_msg;
    //[uid]
    set<int32_t>            m_adm_uid;
    add_req_hm_t            m_add_req_hm;
    vector<sp_ganguser_t>   m_sort_mem;
    //[uid][code]
    map<int, int>           m_cache_deal_req;
    sp_ganguser_t           m_sp_chairman;
    map<uint64_t, sc_hongbao_t>  m_hongbao_map;
    uint32_t                m_hongbao_stamp;
};
typedef boost::shared_ptr<sc_gang_t> sp_gang_t;

class sc_gang_mgr_t 
{
    //[ggid][it_gang_t]
    typedef unordered_map<int32_t, sp_gang_t> gang_hm_t;
    typedef unordered_map<int32_t, sp_gang_t>::iterator it_gang_t;
    //[uid][sc_ganguser_t]
    typedef unordered_map<int32_t, sp_ganguser_t> ganguser_hm_t;
    typedef vector<it_gang_t> gang_vec_t;
public:
    sc_gang_mgr_t();

    void load_db(vector<int32_t>& hostnums_);
    bool get(int32_t ggid_, sp_gang_t &sp_gang_);
    size_t size() const { return m_gang_hm.size(); }

    int create_gang(sp_user_t sp_user_, string& name_); 
    int unicast_ganginfo(int uid_, int ggid_);
    int unicast_ganglist(int uid_, int page_);
    int search_gang(int uid_, string& name_);
    int set_notice(int uid_, string& notice_);
    int add_msg(int uid_, int type_, string& msg_);
    int set_adm(int cuid_,int uid_, bool isadm_);
    int pay(sp_user_t sp_user_, int money_, int rmb_, int& dpm_);
    int close_gang(sp_user_t sp_user_);
    int learn_gskl(sp_user_t sp_user_, int resid_);
    int unicast_gskl_list(sp_user_t sp_user_);
    int add_req(sp_user_t sp_user_, int32_t ggid_);
    int unicast_reqlist(sp_user_t sp_user_);
    int deal_gang_req(sp_user_t sp_user_, int uid_, int flag_);
    int unicast_mem(sp_user_t sp_user_, int page_);
    int kick_mem(sp_user_t sp_user_, int uid_);
    int enter_pray(sp_user_t sp_user_);
    int pray(sp_user_t sp_user_);
    int change_charman(sp_user_t sp_user_, int uid_);
    int on_role_deleted(int uid_);
    int leave_gang(sp_user_t sp_user_);
    bool get_gang_by_uid(int uid_, sp_gang_t& sp_gang_, sp_ganguser_t& sp_guser_);
    bool has_gang_by_uid(int uid_);
    int get_ggid_by_uid(int uid_);
    void get_ggname_by_uid(int uid_, sc_msg_def::jpk_role_data_t& ganginfo);
    void add_del_guser(sp_ganguser_t guser_);
    void remove_del_guser(int uid_);
    bool get_del_guser(int uid_, sp_ganguser_t& guser_);
    int set_boss_time(sp_user_t sp_user_, int day_);

    void remove_req(int uid_);
    void sort_gang();
    int get_grank(int ggid_);
    void add_gang(sp_gang_t sp_gang_);
    void del_gang(int ggid_); 

    int get_guser_pray_num(int uid_);
    int get_gang_add_req(int uid_);

    void on_level_up(int uid_);
    void refresh_chairman();
private:
    int             m_max_ggid; 
    gang_hm_t       m_gang_hm;
    ganguser_hm_t   m_del_user_hm;
    gang_vec_t      m_gang_sort;
};

#define gang_mgr (singleton_t<sc_gang_mgr_t>::instance())

#endif
