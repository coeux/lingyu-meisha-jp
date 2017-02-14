#include "sc_session.h"
#include "sc_service.h"
#include "log.h"
#include "msg_def.h"
#include "remote_info.h"

using namespace std;

#define LOG "SC_SESSION"

void sc_session_t::add(uint64_t seskey_, int32_t uid_)
{
    m_session_hm[seskey_] = uid_;
    m_user_hm[uid_] = seskey_;
}
void sc_session_t::update(uint64_t seskey_, uint64_t newseskey_)
{
    auto it = m_session_hm.find(seskey_);
    if (it != m_session_hm.end())
    {
        m_session_hm.insert(make_pair(newseskey_, it->second));
        auto it2 = m_user_hm.find(it->second);
        it2->second = newseskey_;
        m_session_hm.erase(it);
    }
}
int32_t sc_session_t::get_uid(uint64_t seskey_)
{
    auto it = m_session_hm.find(seskey_);
    if (it != m_session_hm.end())
        return it->second;
    return 0;
}
uint64_t sc_session_t::get_seskey(int32_t uid_)
{
    auto it = m_user_hm.find(uid_);
    if (it != m_user_hm.end())
        return it->second;
    return 0;
}
void sc_session_t::clear()
{
    m_session_hm.clear();
    m_user_hm.clear();
}
void sc_session_t::dump()
{
    for(auto it=m_session_hm.begin(); it!=m_session_hm.end(); it++)
    {
        logwarn((LOG, "ses:%lu,uid:%d", it->first, it->second));
    }
}
int sc_session_t::on_broken(uint64_t seskey_)
{
    auto it = m_session_hm.find(seskey_);
    if (it != m_session_hm.end())
    {
        m_user_hm.erase(it->second);
        m_session_hm.erase(it);
        return 0;
    }
    return -1;
}
int sc_session_t::broken_seskey(uint64_t seskey_, sp_rpc_conn_t conn_)
{
    //通知网关关闭老的seskey
    inner_msg_def::nt_close_session_t nt;
    nt.seskey = seskey_;
    string out;
    nt >> out;

    uint32_t gwsid = ((uint32_t)REMOTE_GW<<16 | seskey_>>48);
    sp_sc_gw_client_t client;
    if (sc_service.get(gwsid, client))
    {
        logwarn((LOG, "broken seskey:%lu, gwsid:%d",seskey_, (uint16_t)gwsid));
        client->get_conn()->async_send(rpc_msg_util_t::make_msg(nt.cmd(), out));
    }
    else{
        logerror((LOG, "unknown seskey:%lu, gwsid:%d",seskey_, (uint16_t)gwsid));
    }

    return 0;
}
