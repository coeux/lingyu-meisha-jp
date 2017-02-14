#ifndef _jserialize_macro_h_
#define _jserialize_macro_h_

#include <stdint.h>
#include <string>
#include <vector>
#include <map>
#include <stdexcept>
#include <iostream>
using namespace std;

#include "rapidjson/document.h"     // rapidjson's DOM-style API
#include "rapidjson/prettywriter.h" // for stringify JSON
#include "rapidjson/filestream.h"   // wrapper of C stream for prettyWriter as output
#include "json_instream.h"
#include "json_outstream.h"
#include "rapidjson/stringbuffer.h"

typedef runtime_error        msg_exception_t;
typedef rapidjson::Document  json_dom_t;
typedef rapidjson::Value     json_value_t;

template<uint16_t CmdValue>
struct jcmd_t 
{
    static uint16_t cmd() { return CmdValue; }
};

#define JSON0(r)\
    r& operator<< (const string& in_)\
    {\
        return *this;\
    }\
    r& operator>>(string& out_)\
    {\
        return *this;\
    }

#define JSON1(r, s1)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1);\
        return 0;\
    }

#define JSON2(r, s1, s2)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, this->s1).encode(#s2, dest, this->s2);\
        return 0;\
    }

#define JSON3(r, s1, s2, s3)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3);\
        return 0;\
    }

#define JSON4(r, s1, s2, s3, s4)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4);\
        return 0;\
    }

#define JSON5(r, s1, s2, s3, s4, s5)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5);\
        return 0;\
    }

#define JSON6(r, s1, s2, s3, s4, s5, s6)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6);\
        return 0;\
    }

#define JSON7(r, s1, s2, s3, s4, s5, s6, s7)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7);\
        return 0;\
    }

#define JSON8(r, s1, s2, s3, s4, s5, s6, s7, s8)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8);\
        return 0;\
    }

#define JSON9(r, s1, s2, s3, s4, s5, s6, s7, s8, s9)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9);\
        return 0;\
    }

#define JSON10(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10);\
        return 0;\
    }

#define JSON11(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11);\
        return 0;\
    }

#define JSON12(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12);\
        return 0;\
    }
#define JSON13(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13);\
        return 0;\
    }
#define JSON14(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14);\
        return 0;\
    }
#define JSON15(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15);\
        return 0;\
    }
#define JSON16(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16);\
        return 0;\
    }
#define JSON17(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17);\
        return 0;\
    }
#define JSON18(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18);\
        return 0;\
    }
#define JSON19(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19);\
        return 0;\
    }
#define JSON20(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20);\
        return 0;\
    }
#define JSON21(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21);\
        return 0;\
    }
#define JSON22(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22);\
        return 0;\
    }
#define JSON23(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23);\
        return 0;\
    }
#define JSON24(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24);\
        return 0;\
    }
#define JSON25(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25);\
        return 0;\
    }
#define JSON26(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26);\
        return 0;\
    }
#define JSON27(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27);\
        return 0;\
    }
#define JSON28(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28);\
        return 0;\
    }
#define JSON29(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29);\
        return 0;\
    }
#define JSON30(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30);\
        return 0;\
    }
#define JSON31(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31);\
        return 0;\
    }
#define JSON32(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32);\
        return 0;\
    }
#define JSON33(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33);\
        return 0;\
    }
#define JSON34(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34);\
        return 0;\
    }

#define JSON35(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34).decode(#s35, jval[#s35], s35);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34).encode(#s35, dest, s35);\
        return 0;\
    }

#define JSON36(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34).decode(#s35, jval[#s35], s35).decode(#s36, jval[#s36], s36);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34).encode(#s35, dest, s35).encode(#s36, dest, s36);\
        return 0;\
    }
    
    #define JSON37(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36, s37)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34).decode(#s35, jval[#s35], s35).decode(#s36, jval[#s36], s36).decode(#s37, jval[#s37], s37);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34).encode(#s35, dest, s35).encode(#s36, dest, s36).encode(#s37, dest, s37);\
        return 0;\
    }

    #define JSON38(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36, s37, s38)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34).decode(#s35, jval[#s35], s35).decode(#s36, jval[#s36], s36).decode(#s37, jval[#s37], s37).decode(#s38, jval[#s38], s38);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34).encode(#s35, dest, s35).encode(#s36, dest, s36).encode(#s37, dest, s37).encode(#s38, dest, s38);\
        return 0;\
    }
    #define JSON39(r, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36, s37, s38, s39)\
    r& operator<< (const string& in_)\
    {\
        json_dom_t document;\
        if (document.Parse<0>(in_.c_str()).HasParseError())\
        {\
            throw msg_exception_t("json format not right");\
        }\
        const json_value_t& jval = document;\
        parse(jval);\
        return *this;\
    }\
    int parse(const json_value_t& jval) {\
        json_instream_t in(#r);\
        in.decode(#s1, jval[#s1], s1).decode(#s2, jval[#s2], s2).decode(#s3, jval[#s3], s3).decode(#s4, jval[#s4], s4).decode(#s5, jval[#s5], s5).decode(#s6, jval[#s6], s6).decode(#s7, jval[#s7], s7).decode(#s8, jval[#s8], s8).decode(#s9, jval[#s9], s9).decode(#s10, jval[#s10], s10).decode(#s11, jval[#s11], s11).decode(#s12, jval[#s12], s12).decode(#s13, jval[#s13], s13).decode(#s14, jval[#s14], s14).decode(#s15, jval[#s15], s15).decode(#s16, jval[#s16], s16).decode(#s17, jval[#s17], s17).decode(#s18, jval[#s18], s18).decode(#s19, jval[#s19], s19).decode(#s20, jval[#s20], s20).decode(#s21, jval[#s21], s21).decode(#s22, jval[#s22], s22).decode(#s23, jval[#s23], s23).decode(#s24, jval[#s24], s24).decode(#s25, jval[#s25], s25).decode(#s26, jval[#s26], s26).decode(#s27, jval[#s27], s27).decode(#s28, jval[#s28], s28).decode(#s29, jval[#s29], s29).decode(#s30, jval[#s30], s30).decode(#s31, jval[#s31], s31).decode(#s32, jval[#s32], s32).decode(#s33, jval[#s33], s33).decode(#s34, jval[#s34], s34).decode(#s35, jval[#s35], s35).decode(#s36, jval[#s36], s36).decode(#s37, jval[#s37], s37).decode(#s38, jval[#s38], s38).decode(#s39, jval[#s39], s39);\
        return 0;\
    }\
    r& operator>>(string& out_)\
    {\
        rapidjson::Document::AllocatorType allocator;\
        rapidjson::StringBuffer            str_buff;\
        json_value_t                       ibj_json(rapidjson::kObjectType);\
        this->encode_json_val(ibj_json, allocator);\
        rapidjson::Writer<rapidjson::StringBuffer> Writer(str_buff, &allocator);\
        ibj_json.Accept(Writer);\
        out_.append(str_buff.GetString(), str_buff.Size());\
        return *this;\
    }\
    int encode_json_val(json_value_t& dest, rapidjson::Document::AllocatorType& allocator) const\
    {\
        json_outstream_t out(allocator);\
		out.encode(#s1, dest, s1).encode(#s2, dest, s2).encode(#s3, dest, s3).encode(#s4, dest, s4).encode(#s5, dest, s5).encode(#s6, dest, s6).encode(#s7, dest, s7).encode(#s8, dest, s8).encode(#s9, dest, s9).encode(#s10, dest, s10).encode(#s11, dest, s11).encode(#s12, dest, s12).encode(#s13, dest, s13).encode(#s14, dest, s14).encode(#s15, dest, s15).encode(#s16, dest, s16).encode(#s17, dest, s17).encode(#s18, dest, s18).encode(#s19, dest, s19).encode(#s20, dest, s20).encode(#s21, dest, s21).encode(#s22, dest, s22).encode(#s23, dest, s23).encode(#s24, dest, s24).encode(#s25, dest, s25).encode(#s26, dest, s26).encode(#s27, dest, s27).encode(#s28, dest, s28).encode(#s29, dest, s29).encode(#s30, dest, s30).encode(#s31, dest, s31).encode(#s32, dest, s32).encode(#s33, dest, s33).encode(#s34, dest, s34).encode(#s35, dest, s35).encode(#s36, dest, s36).encode(#s37, dest, s37).encode(#s38, dest, s38).encode(#s39, dest, s39);\
        return 0;\
    }



#endif
