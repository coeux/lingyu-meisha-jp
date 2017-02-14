
#ifndef _IDL_DEF_I_
#define _IDL_DEF_I_

#include <stdint.h>
#include <string>
#include <vector>
#include <map>
#include <stdexcept>
#include <iostream>
using namespace std;

#include "rapidjson/document.h"     // rapidjson's DOM-style API
#include "rapidjson/prettywriter.h" // for stringify JSON
#include "rapidjson/filestream.h"   // wrapper of C stream for prettywriter as output
#include "json_instream.h"
#include "json_outstream.h"
#include "rapidjson/stringbuffer.h"
#include "smart_ptr/shared_ptr.h"
//! using namespace rapidjson;
using namespace ff;

typedef runtime_error        msg_exception_t;
typedef rapidjson::Document  json_dom_t;
typedef rapidjson::Value     json_value_t;

typedef int8_t int8;
typedef uint8_t uint8;
typedef int16_t int16;
typedef uint16_t uint16;
typedef int32_t int32;
typedef uint32_t uint32;
typedef int64_t int64;
typedef uint64_t uint64;

struct msg_t
{
    virtual ~msg_t(){}
    virtual string encode_json() const = 0;
};
typedef shared_ptr_t<msg_t> msg_ptr_t;

struct friend_t : public msg_t {
    uint16 level;
    uint64 uid;
    string name;
    int parse(const json_value_t& jval_) {

            json_instream_t in("friend_t");
            in.decode("level", jval_["level"], level).decode("uid", jval_["uid"], uid).decode("name", jval_["name"], name);
        return 0;
    }

    string encode_json() const
    {
        rapidjson::Document::AllocatorType allocator;
        rapidjson::StringBuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kObjectType);
        json_value_t                       ret_json(rapidjson::kObjectType);

        this->encode_json_val(ibj_json, allocator);
        ret_json.AddMember("friend_t", ibj_json, allocator);

        rapidjson::Writer<rapidjson::StringBuffer> writer(str_buff, &allocator);
        ret_json.Accept(writer);
        string output(str_buff.GetString(), str_buff.GetSize());
        return output;
    }
        
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const{

        json_outstream_t out(allocator);
		out.encode("level", dest, level).encode("uid", dest, uid).encode("name", dest, name);
        return 0;
    }

};
struct all_friends_ret_t : public msg_t {
    vector<uint32> friends;
    int parse(const json_value_t& jval_) {

            json_instream_t in("all_friends_ret_t");
            in.decode("friends", jval_["friends"], friends);
        return 0;
    }

    string encode_json() const
    {
        rapidjson::Document::AllocatorType allocator;
        rapidjson::StringBuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kObjectType);
        json_value_t                       ret_json(rapidjson::kObjectType);

        this->encode_json_val(ibj_json, allocator);
        ret_json.AddMember("all_friends_ret_t", ibj_json, allocator);

        rapidjson::Writer<rapidjson::StringBuffer> writer(str_buff, &allocator);
        ret_json.Accept(writer);
        string output(str_buff.GetString(), str_buff.GetSize());
        return output;
    }
        
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const{

        json_outstream_t out(allocator);
		out.encode("friends", dest, friends);
        return 0;
    }

};
struct get_friends_req_t : public msg_t {
    string msg;
    vector<friend_t> friends;
    uint64 uid;
    int parse(const json_value_t& jval_) {

            json_instream_t in("get_friends_req_t");
            in.decode("msg", jval_["msg"], msg).decode("friends", jval_["friends"], friends).decode("uid", jval_["uid"], uid);
        return 0;
    }

    string encode_json() const
    {
        rapidjson::Document::AllocatorType allocator;
        rapidjson::StringBuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kObjectType);
        json_value_t                       ret_json(rapidjson::kObjectType);

        this->encode_json_val(ibj_json, allocator);
        ret_json.AddMember("get_friends_req_t", ibj_json, allocator);

        rapidjson::Writer<rapidjson::StringBuffer> writer(str_buff, &allocator);
        ret_json.Accept(writer);
        string output(str_buff.GetString(), str_buff.GetSize());
        return output;
    }
        
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const{

        json_outstream_t out(allocator);
		out.encode("msg", dest, msg).encode("friends", dest, friends).encode("uid", dest, uid);
        return 0;
    }

};


template<typename T, typename R>
class msg_dispather_t
{
    typedef R                    socket_ptr_t;
    typedef int (msg_dispather_t<T, R>::*reg_func_t)(const json_value_t&, socket_ptr_t);
public:
    msg_dispather_t(T& msg_handler_):
        m_msg_handler(msg_handler_)
    {
        
        m_reg_func["friend_t"] = &msg_dispather_t<T, R>::friend_t_dispacher;
            
        m_reg_func["get_friends_req_t"] = &msg_dispather_t<T, R>::get_friends_req_t_dispacher;
            
    }

    int dispath(const string& json_, socket_ptr_t sock_)
    {
        json_dom_t document;  // Default template parameter uses UTF8 and MemoryPoolAllocator.
        if (document.Parse<0>(json_.c_str()).HasParseError())
        {
            throw msg_exception_t("json format not right");
        }
        if (false == document.IsObject() && false == document.Empty())
        {
            throw msg_exception_t("json must has one field");
        }
    
        const json_value_t& val = document.MemberBegin()->name;
        const char* func_name   = val.GetString();
        typename map<string, reg_func_t>::const_iterator it = m_reg_func.find(func_name);
    
        if (it == m_reg_func.end())
        {
            char buff[512];
            snprintf(buff, sizeof(buff), "msg not supported<%s>", func_name);
            throw msg_exception_t(buff);
            return -1;
        }
        reg_func_t func = it->second;
    
        (this->*func)(document.MemberBegin()->value, sock_);
        return 0;
    }
        
    int friend_t_dispacher(const json_value_t& jval_, socket_ptr_t sock_)
    {
        shared_ptr_t<friend_t> ret_val(new friend_t());
        ret_val->parse(jval_);

        m_msg_handler.handle(ret_val, sock_);
        return 0;
    }
            
    int get_friends_req_t_dispacher(const json_value_t& jval_, socket_ptr_t sock_)
    {
        shared_ptr_t<get_friends_req_t> ret_val(new get_friends_req_t());
        ret_val->parse(jval_);

        m_msg_handler.handle(ret_val, sock_);
        return 0;
    }
            
private:
    T&                      m_msg_handler;
    map<string, reg_func_t> m_reg_func;
};
        
#endif
