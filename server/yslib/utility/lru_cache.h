#ifndef _lru_cache_
#define _lru_cache_

#include <unordered_map>
#include <list>
#include <boost/thread.hpp>

template<typename key_t, typename value_t>
class lru_cache_t 
{
    typedef boost::mutex::scoped_lock Scoped_lock;
    typedef boost::mutex Mutex;
public:
    typedef typename std::pair<key_t, value_t> key_value_pair_t;
    typedef typename std::list<key_value_pair_t>::iterator list_iterator_t;

    lru_cache_t():_max_size(10000){
    }

    lru_cache_t(size_t max_size) :
        _max_size(max_size) {
        }

    void set_size(size_t max_size){
        _max_size = max_size;
    }

    void put(const key_t& key, const value_t& value) {
        Scoped_lock lock(m_mutex);
        auto it = _cache_items_map.find(key);
        if (it != _cache_items_map.end()) {
            _cache_items_list.erase(it->second);
            _cache_items_map.erase(it);
        }

        _cache_items_list.push_front(key_value_pair_t(key, value));
        _cache_items_map[key] = _cache_items_list.begin();

        if (_cache_items_map.size() > _max_size) {
            auto last = _cache_items_list.end();
            last--;
            _cache_items_map.erase(last->first);
            _cache_items_list.pop_back();
        }
    }

    bool get(const key_t& key, value_t& value) {
        Scoped_lock lock(m_mutex);
        auto it = _cache_items_map.find(key);
        if (it == _cache_items_map.end()) {
            return false;
        } else {
            _cache_items_list.splice(_cache_items_list.begin(), _cache_items_list, it->second);
            value = it->second->second;
            return true;
        }
    }

    bool exists(const key_t& key) const {
        Scoped_lock lock(m_mutex);
        return _cache_items_map.find(key) != _cache_items_map.end();
    }

    size_t size() const {
        Scoped_lock lock(m_mutex);
        return _cache_items_map.size();
    }

private:
    Mutex    m_mutex;
    std::list<key_value_pair_t> _cache_items_list;
    std::unordered_map<key_t, list_iterator_t> _cache_items_map;
    size_t _max_size;
};

#endif
