#include <iostream>
using namespace std;

#include "package.h"
#include "serialize_macro.h"
#include "dump_macro.h"

struct man_t
{
    uint64_t uid;
    int id;
    string name;

    S3(uid, id, name)
    D3(uid, id, name)
};

struct msg_skill_t
{
    man_t caster; 
    vector<man_t> targets;

    S2(caster, targets)
    D2(caster, targets)
};

template<class T>
void send(uint16_t cmd_, const T& v_)
{
    string sbody;
    v_>>sbody;
}

int main()
{
    man_t m1 = {123456789, 1, "kanel"};
    man_t m2 = {444, 2, "tom"};
    man_t m3 = {777, 3, "xiaobao"};
    
    msg_skill_t msg, recv_msg;
    msg.caster = m1;
    msg.targets.push_back(m2);
    msg.targets.push_back(m3);

    ys::package_t p;
    msg >> p;

    string buff = p;

    ys::package_t p2;
    p2 = buff;
    recv_msg << p2;

    string dump_info;
    recv_msg.dump(dump_info);
    cout << dump_info << endl;
}
