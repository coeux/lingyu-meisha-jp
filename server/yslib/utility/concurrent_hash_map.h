#ifndef _concurrent_hash_map_h_
#define _concurrent_hash_map_h_

#include "tbb/concurrent_hash_map.h"

template<class Key, class Value>
class concurrent_hash_map_t
{
    typedef tbb::concurrent_hash_map<Key,Value>  concurrent_hm_t;
public:
    bool find(const Key& key_)
    {
        typename concurrent_hm_t::accessor a;
        return m_contain.find(a, key_);
    }
    bool get(const Key& key_, Value& value_)
    {
        typename concurrent_hm_t::accessor a;
        if (m_contain.find(a, key_))
        {
            value_ = a->second;
            return true;
        }
        return false;
    }
    bool insert(const Key& key_, const Value& value_)
    {
        typename concurrent_hm_t::accessor a;
        if (m_contain.insert(a, key_))
        {
            a->second = value_;
            return true;
        }
        return false;
        
    }
    bool erase(const Key& key_)
    {
        return m_contain.erase(key_);
    }
    size_t size() const 
    {
        return m_contain.size();
    }
    bool empty() const
    {
        return m_contain.empty();
    }
    void clear()
    {
        m_contain.clear();
    }

    template<class F>
    void foreach(F fun_)
    {
        for(typename concurrent_hm_t::iterator it=m_contain.begin(); it!=m_contain.end(); ++it) 
        {
            fun_(it->first, it->second);
        }
    }
private:
    concurrent_hm_t m_contain;
};

#endif
