#ifndef _sc_friend_flower_h
#define _sc_friend_flower_h

using namespace std;
#include <stdint.h>
#include <msg_def.h>
#include <db_def.h>
#include <unordered_map>
#include <boost/shared_ptr.hpp>
class sc_user_t;
class sc_friend_flower_t
{
    public:
        sc_friend_flower_t(sc_user_t& user_):m_user(user_){};

        int addNew(int uid, string name, int lifetime);
        bool  checkIsOrNoSendFlower(int32_t frienduid, int32_t uid);
        void get_flowers();
        void receive_flower(int32_t id);
        void receive_all();
        void receive_userguide();
        void load_db();
    private:
        sc_user_t& m_user;
        unordered_map<int32_t, db_FriendFlower_t>  db_hm;
        unordered_map<int32_t, db_FriendFlower_t>  db_info;
    private:
        void del_flower(int32_t id);
};

#endif
