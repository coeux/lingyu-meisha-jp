#ifndef _SERVICE_BASE_H_ 
#define _SERVICE_BASE_H_ 

#include <ext/hash_map>
#include <ext/hash_set>
using namespace __gnu_cxx;

#include "rpc_server.h"
#include "remote_info.h"
#include "log.h"

template<class Listener>
class service_base_t : public rpc_server_t<Listener>
{
protected:
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;
    typedef hash_map<uint32_t, sp_rpc_conn_t>           server_conn_hm_t;
    typedef hash_map<uint64_t, sp_rpc_conn_t>           client_conn_hm_t;
public:
    service_base_t():rpc_server_t<Listener>(){}
    service_base_t(boost::asio::io_service& io_):rpc_server_t<Listener>(io_){}

    virtual ~service_base_t() {
    }

    void close_wait()
    {
        logwarn(("SERVICE_BASE", "close wait..."));
        rpc_server_t<Listener>::close();
        close_all_conn();
        while(!m_server_conn_hm.empty()) {logwarn(("SERVICE_BASE", "server conn num:%u", m_server_conn_hm.size())); sleep(1);}
        while(!m_client_conn_hm.empty()) {logwarn(("SERVICE_BASE", "client conn num:%u", m_client_conn_hm.size())); sleep(1);}
        logwarn(("SERVICE_BASE", "close wait...ok!"));
    }

    template<class F>
    void foreach_server(F fun_)
    {
        auto it = m_server_conn_hm.begin();
        for(; it != m_server_conn_hm.end(); it++)
        {
            fun_(it->second); 
        }
    }

    template<class F>
    void foreach_server(uint16_t sertype_, F fun_)
    {
        auto it = m_server_conn_hm.begin();
        for(; it != m_server_conn_hm.end(); it++)
        {
            remote_info_t* info = it->second->get_data<remote_info_t>();
            if (info != NULL && sertype_ == info->sertype())
            {
                fun_(it->second); 
            }
        }
    }


    template<class TMsg>
    int async_trans_to_server(uint32_t sid_, TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, uint32_t sid_, TMsg& msg_){
                sp_rpc_conn_t conn = service_->get_server_conn(sid_); 
                if (conn != NULL)
                    service_->async_call(conn, msg_);
        }, this, sid_, msg_);

        return 0;
    }

    int async_trans_to_server(uint32_t sid_, uint16_t cmd_, string& body_)
    {
        this->async_do([](service_base_t* service_, uint32_t sid_, uint16_t cmd_, const string& body_){
                sp_rpc_conn_t conn = service_->get_server(sid_); 
                if (conn != NULL)
                    service_->async_call(conn, cmd_, body_);
        }, this, sid_, cmd_, body_);

        return 0;
    }

    template<class TMsg>
    int async_broadcast_to_server(uint16_t sertype_, TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, uint16_t sertype_, TMsg& msg_){
            service_->foreach(sertype_, [&](sp_rpc_conn_t conn_){
                    service_->async_call(conn_, msg_);
            });
        }, this, sertype_, msg_);
        return 0;
    }

    template<class TMsg>
    int async_broadcast_server(TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, TMsg& msg_){
            service_->foreach_server([&](sp_rpc_conn_t conn_){
                service_->async_call(conn_, msg_);
            });
        }, this, msg_);
        return 0;
    }

    template<class TMsg>
    int trans_to_server(uint32_t sid_, TMsg& msg_)
    {
        sp_rpc_conn_t conn = get_server(sid_); 
        if (conn != NULL){
            this->async_call(conn, msg_);
            return 0;
        } 
        return -1;
    }

    int trans_to_server(uint32_t sid_, uint16_t cmd_, const string& body_)
    {
        sp_rpc_conn_t conn = get_server(sid_); 
        if (conn != NULL){
            this->async_call(conn, cmd_, body_);
            return 0;
        }
        return -1;
    }

    int broadcast_to_server(uint16_t sertype_, uint16_t cmd_, const string& body_)
    {
        foreach_server(sertype_, [&](sp_rpc_conn_t conn_){
            this->async_call(conn_, cmd_, body_);
        });
        return 0;
    }

    template<class TMsg>
    int broadcast_to_server(uint16_t sertype_, TMsg& msg_)
    {
        foreach_server(sertype_, [&](sp_rpc_conn_t conn_){
            this->async_call(conn_, msg_);
        });
        return 0;
    }

    template<class TMsg>
    int broadcast_server(TMsg& msg_)
    {
        foreach_server([&](sp_rpc_conn_t conn_){
            this->async_call(conn_, msg_);
        });
        return 0;
    }

    bool add_server(uint32_t sid_, sp_rpc_conn_t conn_)
    {
        auto it = m_server_conn_hm.find(sid_);
        if (it != m_server_conn_hm.end())
            return false;
        m_server_conn_hm[sid_] = conn_;
        return true;
    }

    sp_rpc_conn_t get_server(uint32_t sid_)
    {
        auto it = m_server_conn_hm.find(sid_);
        if (it != m_server_conn_hm.end())
        {
            return it->second;
        }
        return sp_rpc_conn_t();
    }
    void del_server(uint32_t sid_)
    {
        m_server_conn_hm.erase(sid_);
    }

    bool has_server(uint32_t sid_)
    {
        return (m_server_conn_hm.find(sid_) != m_server_conn_hm.end());
    }

    //==========================================================================
    template<class F>
    void foreach_client(F fun_)
    {
        auto it = m_client_conn_hm.begin();
        for(; it != m_client_conn_hm.end(); it++)
        {
            fun_(it->second); 
        }
    }

    template<class F>
    void foreach_client(set<uint64_t>& uids_, F fun_)
    {
        for(auto it = uids_.begin(); it != uids_.end(); it++)
        {
            auto found = m_client_conn_hm.find(*it);
            if (found != m_client_conn_hm.end())
                fun_(found->second); 
        }
    }
    

    template<class TMsg>
    int async_unicast_to_client(uint64_t uid_, TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, uint64_t uid_, TMsg& msg_){
            sp_rpc_conn_t conn = service_->get_client(uid_);
            if (conn != NULL)
                service_->async_call(conn, msg_);
        }, this, uid_, msg_);

        return 0;
    }

    int async_unicast_to_client(uint64_t uid_, uint16_t cmd_, string& msg_)
    {
        this->async_do([](service_base_t* service_, uint64_t uid_, uint16_t cmd_, string& msg_){
            sp_rpc_conn_t conn = service_->get_client(uid_);
            if (conn != NULL)
                service_->async_call(conn, cmd_, msg_);
        }, this, uid_, cmd_, msg_);

        return 0;
    }

    template<class TMsg>
    int async_broadcast_to_client(set<uint64_t>& uids_, TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, set<uint64_t>& uids_, TMsg& msg_){
            service_->foreach_client(uids_, [&](sp_rpc_conn_t conn_){
                    service_->async_call(conn_, msg_);
            });
        }, this, uids_, msg_);
        return 0;
    }

    int async_broadcast_to_client(set<uint64_t>& uids_, uint16_t cmd_, string& msg_)
    {
        this->async_do([](service_base_t* service_, set<uint64_t>& uids_, uint16_t cmd_, string& msg_){
            service_->foreach_client(uids_, [&](sp_rpc_conn_t conn_){
                    service_->async_call(conn_, cmd_, msg_);
            });
        }, this, uids_, cmd_, msg_);
        return 0;
    }

    template<class TMsg>
    int async_broadcast_client(TMsg& msg_)
    {
        this->async_do([](service_base_t* service_, TMsg& msg_){
            service_->foreach_client([&](sp_rpc_conn_t conn_){
                service_->async_call(conn_, msg_);
            });
        }, this, msg_);
        return 0;
    }

    int async_broadcast_client(uint16_t cmd_, string& msg_)
    {
        this->async_do([](service_base_t* service_, uint16_t cmd_, string& msg_){
            service_->foreach_client([&](sp_rpc_conn_t conn_){
                service_->async_call(conn_, cmd_, msg_);
            });
        }, this, cmd_, msg_);
        return 0;
    }

    template<class TMsg>
    int unicast_to_client(uint64_t uid_, TMsg& msg_)
    {
        sp_rpc_conn_t conn = get_client(uid_);
        if (conn != NULL)
            async_call(conn, msg_);
        return 0;
    }

    int unicast_to_client(uint64_t uid_, uint16_t cmd_, string& msg_)
    {
        sp_rpc_conn_t conn = this->get_client(uid_);
        if (conn != NULL)
        {
            this->async_call(conn, cmd_, msg_);
            return 0;
        }
        return -1;
    }

    template<class TMsg>
    int broadcast_to_client(set<uint64_t>& uids_, TMsg& msg_)
    {
        foreach_client(uids_, [&](sp_rpc_conn_t conn_){
            async_call(conn_, msg_);
        });
        return 0;
    }

    int broadcast_to_client(set<uint64_t>& uids_, uint16_t cmd_, string& body_)
    {
        foreach_client(uids_, [&](sp_rpc_conn_t conn_){
            this->async_call(conn_, cmd_, body_);
        });
        return 0;
    }

    template<class TMsg>
    int broadcast_client(TMsg& msg_)
    {
        foreach_client([&](sp_rpc_conn_t conn_){
            async_call(conn_, msg_);
        });
        return 0;
    }

    int broadcast_client(uint16_t cmd_, string& body_)
    {
        foreach_client([&](sp_rpc_conn_t conn_){
            this->async_call(conn_, cmd_, body_);
        });
        return 0;
    }

    bool add_client(uint64_t uid_, sp_rpc_conn_t conn_)
    {
        if (has_client(uid_))
            return false;

        m_client_conn_hm[uid_] = conn_;
        return true;
    }

    boost::shared_ptr<rpc_connecter_t> get_client(uint64_t uid_)
    {
        auto it = m_client_conn_hm.find(uid_);
        if (it != m_client_conn_hm.end())
            return it->second;
        return boost::shared_ptr<rpc_connecter_t>();
    }

    void del_client(uint64_t uid_)
    {
        m_client_conn_hm.erase(uid_);
    }

    bool has_client(uint64_t uid_)
    {
        return (m_client_conn_hm.find(uid_) != m_client_conn_hm.end());
    }

    void close_all_conn()
    {
        foreach_server([&](sp_rpc_conn_t conn_){
            conn_->close();
        });

        foreach_client([&](sp_rpc_conn_t conn_){
            conn_->close();
        });
    }
protected:
    server_conn_hm_t    m_server_conn_hm;
    client_conn_hm_t    m_client_conn_hm;
};

#endif 
