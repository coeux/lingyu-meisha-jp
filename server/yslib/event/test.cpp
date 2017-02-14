#include <iostream>
#include "event.h"
using namespace std;

void on_login(int uid_, const char* name_)
{
    cout <<"global:" <<  uid_ << ", " << name_ << endl;
}

void on_game_start()
{
    cout << "game start" << endl;
}

class user_mgr_t
{
public:
    void on_login(int uid_, const char* name_)
    {
        cout << "user_mgr_t:" << uid_ << ", " << name_ << endl;
    }
};

class ghost_mgr_t
{
public:
    void on_login(int uid_, const char* name_)
    {
        cout << "ghost_mgr_t:" << uid_ << ", " << name_ << endl;
    }
};

int main()
{
    user_mgr_t user_mgr;
    ghost_mgr_t ghost_mgr;

    event_mgr_t<string> em;
    em.reg("login", &user_mgr, &user_mgr_t::on_login); 
    em.reg("login", &ghost_mgr, &ghost_mgr_t::on_login); 
    em.reg("login", on_login); 
    em.reg("start", on_game_start);

    em.send("login", 123, "liliwang");
    em.send("start");
}
