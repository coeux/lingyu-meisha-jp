#ifndef _record_msg_h_
#define _record_msg_h_

#include <unordered_map>
#include <stdint.h>
#include <string>
using namespace std;

#include "singleton.h"

class record_msg_t
{
    unordered_map<uint64_t, uint32_t> m_ses_uid_map;
public:
    void reg(uint64_t seskey_, uint32_t uid_);
    void unreg(uint64_t seskey_);
    void write(uint64_t seskey_, uint16_t cmd_, const string& body_);
};

#define record_msg_ins (singleton_t<record_msg_t>::instance())

#endif
