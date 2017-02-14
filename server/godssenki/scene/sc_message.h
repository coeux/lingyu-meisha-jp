#ifndef _SC_MESSAGE_H_
#define _SC_MESSAGE_H_

#include <stdint.h>
#include "msg_def.h"
#include "code_def.h"
#include "sc_user.h"

#include <vector>
#include <list>
#include <unordered_map>

using namespace std;

class sc_notify_ctl_t
{
    //[uid] [last msg time]
    typedef unordered_map<int32_t, uint32_t> last_msg_hm_t;
private:
    last_msg_hm_t m_last_msg_hm;
public:
    void push_to_all(int32_t suid_,int32_t resid, int32_t quality_, int32_t grade_,int32_t vip_,const string &name_, int32_t type_, string &msg_);
    void push_to_gang(int32_t suid_,int32_t resid_, int32_t quality_, int32_t grade_,int32_t vip_,const string &name_,int32_t type_,int32_t ggid_, string &msg_);
    void push_to_uid(int32_t suid_,int32_t resid_, int32_t quality_,int32_t grade_,int32_t vip_,const string &name_, int32_t type_, int32_t duid_, string &msg_);
    void push_mail(int32_t uid_, const string& msg_);
    void push_offlinemail(int32_t uid_, const string& msg_);
    void push_event(sc_msg_def::nt_event_general_t &event_);
    void push_event(sc_msg_def::nt_event_gemstone_t &event_);
    void push_event(sc_msg_def::nt_event_arena_t &event_);
    void push_event(sc_msg_def::nt_event_blank_t &event_);
    void push_event(sc_msg_def::nt_event_boss_kill_t &event_);
    int32_t get_lovelevel(int32_t uid_);
private:
    bool can_chart(int32_t uid_);
};
#define notify_ctl (singleton_t<sc_notify_ctl_t>::instance())

typedef sc_msg_def::nt_msg_push_t sc_notify_t;
typedef list<sc_notify_t> new_msg_bucket_t;
struct private_chat_item_info
{
    new_msg_bucket_t new_bucket; 
    int32_t uid1;
    int32_t uid2;
};
struct last_role_info
{
    int32_t uid;
    uint32_t stmp;
};
struct role_cache
{
    vector<last_role_info> last_role;
    vector<string> chat_id;
};

class sc_notify_cache_t
{
    typedef list<sc_notify_t> msg_bucket_t;
    typedef unordered_map< int32_t, msg_bucket_t > msg_cache_t;
    typedef unordered_map< std::string, private_chat_item_info > msg_new_cache_t;
    typedef unordered_map<int32_t,role_cache> chat_role_cache_t;
private:
    //私人聊天cache
    msg_cache_t m_private_msg;
public:
    //新的私人聊天cache
    msg_new_cache_t m_new_private_msg;
    //进入聊天的人
    chat_role_cache_t m_role_cache;
    int32_t unicast_cache_msg(int32_t uid_);
    int32_t put_msg(int32_t uid_, sc_notify_t &&nt);
    void getPrivateChatMessage(sp_user_t& user,int32_t player_uid_);
    bool addToUid(sp_user_t& user_ ,int32_t acuid_, int32_t typeindex, string msg_);
    void on_session_broken(int32_t uid_);
};
#define notify_cache (singleton_t<sc_notify_cache_t>::instance())

class sc_chat_t
{
    public:
        vector<int32_t>  m_hosts;
        bool addNew(int32_t suid_, int32_t resid_, int32_t quality_, int32_t grade_, int32_t vip_, string name_, int32_t typeindex, string msg_, uint64_t hostnum);
        void getChatMessage(int32_t uid_, uint64_t hostnum);
        void set_hosts(const vector<int32_t>& hostnums_) { m_hosts = hostnums_; }
    private:
        db_Chat_t db;
};
#define chat_ins (singleton_t<sc_chat_t>::instance())
#endif
