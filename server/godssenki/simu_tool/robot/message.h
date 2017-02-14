#ifndef _message_h_
#define _message_h_

#include <stdint.h>
#include <string>
#include <vector>
#include "singleton.h"

using namespace std;

struct msg
{
    int32_t cmd;
    string body;
    msg(int32_t cmd_,const char *body_):cmd(cmd_),body(body_){}
};

class msg_cache_t
{
public:
    msg_cache_t();
    bool load(const string& path_);
    string get_body(int32_t pos_);
    int get_cmd(int32_t pos_);
private:
    vector<msg> m_vec_msgs;
};

#endif
