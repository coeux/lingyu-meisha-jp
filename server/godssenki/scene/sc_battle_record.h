#ifndef _sc_battle_record_h_
#define _sc_battle_record_h_

#include "jserialize_macro.h"
#include "yarray.h"
#include "singleton.h"

#include <vector>
#include <string>
using namespace std;

#include "msg_def.h"

struct record_head_t
{
    int frame;
    int n;
};

struct record_t
{
    int     dir;
    int     pos;
    float   x;
    int     hp;
    int     dmg;
    int     power;
    int     atk_target;
    int     skl_target[5];
    int     state;
    int     skl;
    int     skl_time;
    int     skl_action_time;
    int     skl_cd;
    int     atk;
    int     atk_time;
    int     atk_action_time;
    int     atk_cd;
};

struct frames_t
{
};

class sc_battle_record_t
{
public:
    vector<vector<record_t>> records;
    bool                open_record;
    string              logname;
    sp_view_user_t      caster;
    sp_view_user_t      target;

    sc_battle_record_t();
    
    void add_record(int frame_, record_t&& record_);
    void flush();
};


#define battle_record (singleton_t<sc_battle_record_t>::instance())

#endif
