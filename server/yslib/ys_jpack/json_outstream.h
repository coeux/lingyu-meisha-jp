#ifndef _JSON_OUTSTREAM_H_
#define _JSON_OUTSTREAM_H_

#include <stdint.h>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <stdexcept>
#include <sstream>
using namespace std;

#include "rapidjson/document.h"     // rapidjson's DOM-style API                                                                                             
#include "rapidjson/prettywriter.h" // for stringify JSON
#include "rapidjson/filestream.h"   // wrapper of C stream for prettywriter as output

#include "yarray.h"
#include "ystring.h"

typedef runtime_error       msg_exception_t;
typedef rapidjson::Document json_dom_t;
typedef rapidjson::Value    json_value_t;

class json_outstream_t
{
public:
    json_outstream_t(rapidjson::Document::AllocatorType& a);

    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, int8_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, uint8_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, int16_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, uint16_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, int32_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, uint32_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, int64_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, uint64_t dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, bool dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, float dest_);
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const string& dest_);

    template<typename T>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const T& dest_);
    template<typename T>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const vector<T>& dest_);
    template<typename T>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const vector<vector<T>>& dest_);
    template<typename T>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const T* dest_, size_t len_);
    template<typename T, typename R>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const map<T, R>& dest_);
    template<typename T, typename R>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const unordered_map<T, R>& dest_);
    template<typename T, size_t R>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const yarray_t<T, R>& dest_);
    template<size_t R>
    json_outstream_t& encode(const char* filed_name_, json_value_t& jval_, const ystring_t<R>& dest_);

    void to_json_val(const char* filed_name_, json_value_t& jval_, int8_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, uint8_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, int16_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, uint16_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, int32_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, uint32_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, uint64_t dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, float dest_) { jval_ = dest_; }
    void to_json_val(const char* filed_name_, json_value_t& jval_, const string& dest_) { jval_.SetString(dest_.c_str(), dest_.length(), m_allocator); }
    template<typename T>
    void to_json_val(const char* filed_name_, json_value_t& jval_, const T& dest_)
    {
        jval_.SetObject();
        dest_.encode_json_val(jval_, m_allocator);
    }

private:
    rapidjson::Document::AllocatorType& m_allocator;
};

template<typename T>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const T& dest_)
{
    json_value_t tmp_val(rapidjson::kObjectType);
    dest_.encode_json_val(tmp_val, m_allocator);
    jval_.AddMember(filed_name_, tmp_val, m_allocator);
    return *this;
}

template<typename T>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const vector<T>& dest_)
{
    json_value_t array_val(rapidjson::kArrayType);

    for (size_t i = 0; i < dest_.size(); ++i)
    {
        json_value_t tmp_val;
        to_json_val(filed_name_, tmp_val, dest_[i]);
        array_val.PushBack(tmp_val, m_allocator);
    }

    jval_.AddMember(filed_name_, array_val, m_allocator);
    return *this;
}

template<typename T>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const vector<vector<T>>& dest_)
{
    json_value_t array_val(rapidjson::kArrayType);

    for (size_t i = 0; i < dest_.size(); ++i)
    {
        const vector<T>& arr = dest_[i];
        json_value_t elm_val(rapidjson::kArrayType);
        for(size_t i=0; i<arr.size(); i++)
        {
            json_value_t tmp_val;
            to_json_val(filed_name_, tmp_val, arr[i]);
            elm_val.PushBack(tmp_val, m_allocator);
        }
        array_val.PushBack(elm_val, m_allocator);
    }

    jval_.AddMember(filed_name_, array_val, m_allocator);
    return *this;
}

template<typename T, typename R>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const map<T, R>& dest_)
{
    json_value_t map_val(rapidjson::kObjectType);

    stringstream stream;
    typename map<T, R>::const_iterator it = dest_.begin();
    for (int i=0; it != dest_.end(); ++it, i++)
    {
        ostringstream ostr;
        ostr << it->first;
        string str = ostr.str();
        json_value_t tmp_val;
        to_json_val(str.c_str(), tmp_val, it->second);
        map_val.AddMember(str.c_str(), m_allocator, tmp_val, m_allocator);
    }
    jval_.AddMember(filed_name_, map_val, m_allocator);
    return *this;
}

template<typename T, typename R>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const unordered_map<T, R>& dest_)
{
    json_value_t map_val(rapidjson::kObjectType);

    stringstream stream;
    typename unordered_map<T, R>::const_iterator it = dest_.begin();
    for (int i=0; it != dest_.end(); ++it, i++)
    {
        ostringstream ostr;
        ostr << it->first;
        string str = ostr.str();
        json_value_t tmp_val;
        to_json_val(str.c_str(), tmp_val, it->second);
        map_val.AddMember(str.c_str(), m_allocator, tmp_val, m_allocator);
    }
    jval_.AddMember(filed_name_, map_val, m_allocator);
    return *this;
}
template<typename T>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const T* dest_, size_t len_)
{
    json_value_t array_val(rapidjson::kArrayType);

    for (size_t i = 0; i < len_; ++i)
    {
        json_value_t tmp_val;
        to_json_val(filed_name_, tmp_val, dest_[i]);
        array_val.PushBack(tmp_val, m_allocator);
    }

    jval_.AddMember(filed_name_, array_val, m_allocator);
    return *this;
}
template<typename T, size_t R>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const yarray_t<T, R>& dest_)
{
    json_value_t array_val(rapidjson::kArrayType);

    for (size_t i = 0; i < dest_.cap(); ++i)
    {
        json_value_t tmp_val;
        to_json_val(filed_name_, tmp_val, dest_[i]);
        array_val.PushBack(tmp_val, m_allocator);
    }

    jval_.AddMember(filed_name_, array_val, m_allocator);
    return *this;
}
template<size_t R>
json_outstream_t& json_outstream_t::encode(const char* filed_name_, json_value_t& jval_, const ystring_t<R>& dest_)
{
    json_value_t tmp_val(rapidjson::kObjectType);
    dest_.encode_json_val(dest_(), m_allocator);
    jval_.AddMember(filed_name_, tmp_val, m_allocator);
    return *this;
}

#endif
