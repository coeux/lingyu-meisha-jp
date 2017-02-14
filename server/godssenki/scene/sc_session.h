#ifndef _sc_session_h_
#define _sc_session_h_

#include <ext/hash_map>
using namespace __gnu_cxx;

#include "singleton.h"
#include "rpc_client.h"

class sc_session_t
{
    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;

    typedef hash_map<uint64_t, int32_t> ses_uid_t;
    typedef hash_map<int32_t, uint64_t> uid_ses_t;
public:
    void add(uint64_t seskey_, int32_t uid_);
    void update(uint64_t seskey_, uint64_t newseskey_);
    int32_t get_uid(uint64_t seskey_); 
    uint64_t get_seskey(int32_t uid_);
    int on_broken(uint64_t seskey_);
    int broken_seskey(uint64_t seskey_, sp_rpc_conn_t conn_);
    void clear();
    void dump();
private:
    ses_uid_t m_session_hm;
    uid_ses_t m_user_hm;
};


#endif
