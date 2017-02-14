#ifndef _sc_user_rec_h_
#define _sc_user_rec_h_

#include <stdint.h>
#include <string>
#include <vector>
using namespace std;

struct rec_head_t
{
    uint16_t    cmd;
    uint32_t    len;
    uint32_t    stmp;
};

struct rec_t
{
    rec_head_t head;
    string msg;
};

class sc_user_rec_t
{
public:
    int  init(uint32_t uid_, uint32_t resid_);
    void add_msg(uint16_t cmd_, const string& msg_);
    int  flush();
private:
    FILE*               m_file;
    vector<rec_t>       m_msgs;
    string              m_fullpath;
    uint32_t            m_cur_sn;
};

#endif
