#ifndef _LOCAL_CACHE_H_
#define _LOCAL_CACHE_H_

#include <string>
using namespace std;

#include <ext/hash_map>
using namespace __gnu_cxx;

#include <boost/thread.hpp>

#include "singleton.h"

class local_cache_t
{
    typedef boost::mutex                      mutex_t;
    typedef boost::mutex::scoped_lock         scoped_lock_t;

    struct str_hash_t
    {
        size_t operator()(const string& str) const
        {
            return __stl_hash_string(str.c_str());
        }
    };
    typedef hash_map<string, string, str_hash_t> cache_map_t;
public:
    local_cache_t();
    ~local_cache_t();

    bool   set(const string& key_, const string& value_);
    string get(const string& key_);
    bool   del(const string& key_);
    bool   add(const string& key_, const string& value_);

    void   dump();
    size_t size();
private:
    mutex_t                 m_mutex;
    cache_map_t             m_cache;
};
typedef boost::shared_ptr<local_cache_t>  sp_local_cache_t;

class local_cache_pool_t
{
    typedef boost::mutex                      mutex_t;
    typedef boost::mutex::scoped_lock         scoped_lock_t;

    struct str_hash_t
    {
        size_t operator()(const string& str) const
        {
            return __stl_hash_string(str.c_str());
        }
    };
    typedef hash_map<string, sp_local_cache_t, str_hash_t> pool_map_t;
public:
    local_cache_pool_t();
    ~local_cache_pool_t();

    sp_local_cache_t create(const string& cache_name_);
    sp_local_cache_t get(const string& cache_name_);
    void clear();
private:
    mutex_t                 m_mutex;
    pool_map_t              m_pool;
};

#define cache_pool (singleton_t<local_cache_pool_t>::instance())

#endif
