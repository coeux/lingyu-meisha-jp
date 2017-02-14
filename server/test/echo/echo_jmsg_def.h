#ifndef _echo_jmsg_def_h_
#define _echo_jmsg_def_h_

#include "jserialize_macro.h"
#include "yarray.h"

struct req_echo_t : public jcmd_t<2000>
{
    uint64_t uid;
    string msg;
    JSON2(req_echo_t, uid, msg);
};

struct jpk_friend_t 
{
    uint64_t uid;
    uint16_t level;
    string name;
    
    /*
    jpk_friend_t& operator<< (const string& in_)
    {
        json_dom_t document;
        if (document.Parse<0>(in_.c_str()).HasParseError())
        {
            throw msg_exception_t("json format not right");
        }
        const json_value_t& jval = document;
        parse(jval);
        return *this;
    }
    int parse(const json_value_t& jval) {
        json_instream_t in("jpk_friend_t");
        in.decode("uid", jval["uid"], uid).decode("level", jval["level"], level).decode("name", jval["name"], name);
        return 0;
    }
    jpk_friend_t& operator>>(string& out_)
    {
        rapidjson::Document::AllocatorType allocator;
        rapidjson::StringBuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kObjectType);
        this->encode_json_val(ibj_json, allocator);
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);
        ibj_json.Accept(Writer);
        out_.append(str_buff.GetString(), str_buff.GetSize());
        return *this;
    }
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const
    {
        json_outstream_t out(allocator);
		out.encode("uid", dest, uid).encode("level", dest, level).encode("name", dest, name);
        return 0;
    }
    */
    JSON3(jpk_friend_t, uid, level, name);
};

struct req_friends_t : public jcmd_t<20001>
{
    uint64_t uid;
    string msg;
    vector<uint64_t> friendids;
    vector<jpk_friend_t> friends;

    /*
    req_friends_t& operator<< (const string& in_)
    {
        json_dom_t document;
        if (document.Parse<0>(in_.c_str()).HasParseError())
        {
            throw msg_exception_t("json format not right");
        }
        const json_value_t& jval = document;
        parse(jval);
        return *this;
    }
    int parse(const json_value_t& jval) {
        json_instream_t in("req_friends_t");
        in.decode("uid", jval["uid"], uid).decode("msg", jval["msg"], msg).decode("friends", jval["friends"], friends);
        return 0;
    }
    req_friends_t& operator>>(string& out_)
    {
        rapidjson::Document::AllocatorType allocator;
        rapidjson::StringBuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kObjectType);
        this->encode_json_val(ibj_json, allocator);
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);
        ibj_json.Accept(Writer);
        out_.append(str_buff.GetString(), str_buff.GetSize());
        return *this;
    }
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const
    {
        json_outstream_t out(allocator);
		out.encode("uid", dest, uid).encode("msg", dest, msg).encode("friends", dest, friends);
        return 0;
    }
    */
    JSON4(req_friends_t, uid, msg, friendids, friends);
};

//多播到客户端 
struct multicast_t : public jcmd_t<30004>
{
    vector<string> uids;
    uint16_t cmd;
    string msg;
    JSON3(multicast_t, uids, cmd, msg);
};

struct equip_t
{
    int eid;
    int pid;
    int uid;
    int resid;

    JSON4(equip_t, eid, pid, uid, resid)
};

struct test_t : public jcmd_t<10000>
{
    char str[30]; 
    int n[20];
    yarray_t<equip_t, 5> equip_solt;

    JSON1(test_t, equip_solt)
};


#endif
