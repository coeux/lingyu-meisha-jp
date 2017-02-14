#ifndef _PROPERTIES_H_
#define _PROPERTIES_H_

#include <string>
#include <iostream>
#include <algorithm>
#include <ext/hash_map>

class properties_t
{
    public:

        const std::string & get_prop(const std::string &key_)	
        {
            return m_properties[key_];
        }

        void set_prop(const std::string &key_, const std::string &value_)	
        {
            m_properties[key_] = value_;
        }

        std::string & operator[] (const std::string &key_)
        {
            return m_properties[key_];
        }

        void dump(std::ostream &out_)
        {
            typedef property_hash_t::const_iterator const_iter_t;

            for(const_iter_t it = m_properties.begin(); it != m_properties.end(); ++it)
            {
                out_ << it->first << " = " << it->second << std::endl;
            }
        }

        bool first_item()
        {
            m_cur_it = m_properties.begin(); 
            return m_cur_it != m_properties.end();
        }

        bool next_item()
        {
            m_cur_it++;
            return m_cur_it != m_properties.end();
        }

        string get_item_key(){
            if (m_cur_it == m_properties.end())
                return "";
            return m_cur_it->first;
        }
        string get_item_value(){
            if (m_cur_it == m_properties.end())
                return "";
            return m_cur_it->second;
        }

    protected:

        struct key_hash : public std::unary_function<std::string, size_t>
    {
        struct to_lower 
        {
            char operator() (char c) const
            {
                return std::tolower(c);
            }
        };

        size_t operator() (const std::string &x) const
        {
            std::string s = x;
            __gnu_cxx::hash<const char *> H;

            std::transform(s.begin(), s.end(), s.begin(), to_lower());

            return H(s.c_str());
        }
    };

        struct key_equal : public std::binary_function<std::string, std::string, bool>
    {
        bool operator() (const std::string &lh, const std::string &rh) const
        {
            return (0 == strcasecmp(lh.c_str(), rh.c_str()));
        }
    };

        typedef __gnu_cxx::hash_map<std::string, std::string, key_hash, key_equal> property_hash_t;
        typedef property_hash_t::iterator iter_t;
        iter_t m_cur_it;
        property_hash_t m_properties;
};

#endif /* _FM_PROPERTIES_H_ */
