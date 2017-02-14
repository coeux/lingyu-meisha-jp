#ifndef _JMSG_DEF_H_
#define _JMSG_DEF_H_

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

typedef runtime_error        msg_exception_t;
typedef rapidjson::Document  json_dom_t;
typedef rapidjson::Value     json_value_t;

struct jpk_friend_t 
{
    uint64_t uid;
    uint16_t level;
    string name;

    jpk_friend_t& operator<< (const string& in_)
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
    
        const json_value_t& jval = document.MemberBegin()->value;
        json_instream_t in("jpk_friend_t");
        in.decode("level", jval["level"], level).decode("uid", jval["uid"], uid).decode("name", jval["name"], name);
        return *this;
    }

    jpk_friend_t& operator>>(string& out_)
    {
        rapidjson::document::allocatortype allocator;
        rapidjson::stringbuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kobjecttype);
        json_value_t                       ret_json(rapidjson::kobjecttype);

        this->encode_json_val(ibj_json, allocator);
        ret_json.addmember("jpk_friend_t", ibj_json, allocator);

        rapidjson::writer<rapidjson::stringbuffer> writer(str_buff, &allocator);
        ret_json.accept(writer);
        out_.append(str_buff.getstring(), str_buff.getsize());
        return *this;
    }

    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const
    {
        json_outstream_t out(allocator);
		out.encode("level", dest, level).encode("uid", dest, uid).encode("name", dest, name);
        return 0;
    }
};

struct req_friends_t
{
    uint64_t uid;

    req_friends_t& operator<< (const string& in_)
    {
        json_dom_t document;  // Default template parameter uses UTF8 and MemoryPoolAllocator.
        if (document.Parse<0>(in_.c_str()).HasParseError())
        {
            throw msg_exception_t("json format not right");
        }
        if (false == document.IsObject() && false == document.Empty())
        {
            throw msg_exception_t("json must has one field");
        }
    
        const json_value_t& jval = document.MemberBegin()->value;
        json_instream_t in("req_friends_t");
        in.decode("uid", jval["uid"], uid);
        return *this;
    }

    req_friends_t& operator>>(string& out_)
    {
        rapidjson::document::allocatortype allocator;
        rapidjson::stringbuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kobjecttype);
        json_value_t                       ret_json(rapidjson::kobjecttype);

        this->encode_json_val(ibj_json, allocator);
        ret_json.addmember("req_friends_t", ibj_json, allocator);

        rapidjson::writer<rapidjson::stringbuffer> writer(str_buff, &allocator);
        ret_json.accept(writer);
        out_.append(str_buff.getstring(), str_buff.getsize());
        return *this;
    }

    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const
    {
        json_outstream_t out(allocator);
		out.encode("uid", dest, uid);
        return 0;
    }
};

struct creq_friends_t {
    vector<jpk_friend_t> friends; 

    creq_friends_t& operator<< (const string& in_)
    {
        json_dom_t document;  // Default template parameter uses UTF8 and MemoryPoolAllocator.
        if (document.Parse<0>(in_.c_str()).HasParseError())
        {
            throw msg_exception_t("json format not right");
        }
        if (false == document.IsObject() && false == document.Empty())
        {
            throw msg_exception_t("json must has one field");
        }
    
        const json_value_t& jval = document.MemberBegin()->value;
        json_instream_t in("creq_friends_t");
        in.decode("friends", jval["friends"], friends);
        return *this;
    }

    creq_friends_t& operator>>(string& out_)
    {
        rapidjson::document::allocatortype allocator;
        rapidjson::stringbuffer            str_buff;
        json_value_t                       ibj_json(rapidjson::kobjecttype);
        json_value_t                       ret_json(rapidjson::kobjecttype);

        this->encode_json_val(ibj_json, allocator);
        ret_json.addmember("creq_friends_t", ibj_json, allocator);

        rapidjson::writer<rapidjson::stringbuffer> writer(str_buff, &allocator);
        ret_json.accept(writer);
        out_.append(str_buff.getstring(), str_buff.getsize());
        return *this;
    }

    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const
    {
        json_outstream_t out(allocator);
		out.encode("friends", dest, friends);
        return 0;
    }
};

#endif
