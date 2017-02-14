#ifndef _gmail_h_
#define _gmail_h_

#include "msg_def.h"
#include "sc_maxid.h"
#include "db_ext.h"
#include <boost/shared_ptr.hpp> 

class sc_user_t;

typedef sc_msg_def::jpk_gmail_t sc_gmail_t;
typedef boost::shared_ptr<db_GMail_ext_t> sp_gmail_t;

class sc_gmail_mgr_t
{
    typedef list<sp_gmail_t>   gmail_list_t;
    typedef map<int, gmail_list_t::iterator> gmail_map_t;
public:
    sc_gmail_mgr_t(sc_user_t& user_);
    void load_db();
    void on_login();
    void unicast();
    void open(int id_);
    void reward(int id_);
    void deletemail(int id_);
    void getallreward();
    void send(sc_msg_def::jpk_gmail_t& jpk_);
    void send(const string& title_, const string& sender_, const string& info_,int validtime_, int flag_ = 0);
    void send(const string& title_, const string& sender_, const string& info_,int validtime_, vector<sc_msg_def::jpk_item_t>& items_, int flag_=1);
    void clear(int flag_);
    int get_unopened_num();
    int ishaverewardEmail();
public:
    //启动的时候加载全服邮件
    static void load_hostmail(vector<int32_t>& hostnums_);
    static void add_hostmail(sc_msg_def::jpk_gmail_t& jpk_);
    //对不在线的用户发送邮件
    
    static void begin_offmail();
    static void add_offmail(int32_t uid, const string& title_, const string& sender_, const string& info_,int validtime_, vector<sc_msg_def::jpk_item_t>& items_, int flag_=1);
    static void do_offmail();

private:
    void save_db(sp_gmail_t sp_gmail_);
private:
    sc_user_t&              m_user;
    gmail_list_t            m_gmail_list;
    gmail_map_t             m_gmail_map;
    sc_maxid_t              m_maxid;

    //收到的全服邮件
    static vector<sp_gmail_t>   g_hostmail;

    static string               m_sql;
    static string               compare_sql;
    static int64_t              max_mid;
};

#endif
