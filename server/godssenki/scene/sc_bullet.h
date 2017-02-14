#ifndef _sc_bullet_h_
#define _sc_bullet_h_

#include <stdint.h>
#include <msg_def.h>
#include <db_def.h>
#include "sc_user.h"


class sc_bullet_t
{
    public:
        sc_bullet_t(sp_user_t user_):m_user(user_){}

        bool addnew(string msg_, int time_, int pos_, int rount_);
        void getList(int round_, sc_msg_def::ret_bullet_t& ret);
    private:
        sp_user_t m_user;
        db_Bullet_t db;
};

#endif
