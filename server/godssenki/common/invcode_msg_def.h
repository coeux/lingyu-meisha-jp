#ifndef _invcode_msg_def_h_
#define _invcode_msg_def_h_

#include <boost/shared_ptr.hpp>

#include "jserialize_macro.h"
#include "yarray.h"

namespace invcode_msg
{
    //请求邀请码
    struct req_code_t : public jcmd_t<10000>
    {
        int uid;
        string domain;
        JSON2(req_code_t, uid, domain)
    };
    struct ret_code_t : public jcmd_t<10001>
    {
        int code;
        int uid;
        string invcode;
        int n1;
        int n2;
        int n3;
        int n4;
        JSON7(ret_code_t,code,uid,invcode,n1,n2,n3,n4)
    };
    //请求邀请码对应的uid
    struct req_uid_t : public jcmd_t<10002>
    {
        int suid; 
        string domain;
        string invcode;
        JSON3(req_uid_t,suid,domain,invcode);
    };
    struct ret_uid_t : public jcmd_t<10003>
    {
        int code;
        int suid;
        int duid;
        JSON3(ret_uid_t,code,suid,duid);
    };
    //被邀请者升级
    struct nt_upgrade_t : public jcmd_t<10004>
    {
        int inviter;
        int grade;
        JSON2(nt_upgrade_t,inviter,grade);
    };
    /*
    //请求奖励
    struct req_reward_t: public jcmd_t<10006>
    {
        int uid;
        JSON1(req_reward_t, uid);
    };
    struct ret_reward_t: public jcmd_t<10007>
    {
        int uid;
        int r1;
        int r2;
        int r3;
        int r4;
        JSON5(ret_reward_t, uid, r1,r2,r3,r4)
    };
    //推送奖励
    struct nt_reward_t : public jcmd_t<10008>
    {
        int uid;
        int lv;
        JSON2(nt_reward_t,uid,lv);
    };
    */
}

#endif
