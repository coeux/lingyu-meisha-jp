#ifndef _SC_XML_H_
#define _SC_XML_H_

#include "singleton.h"
#include "properties.h"
#include "xml_util.h"

class sc_xml_t
{
public: 
    bool parse(string xml_)
    {
        xml_value_t root;
        if (root.parse_xml(xml_))
        {
            return false;
        }

        vector<properties_t> pros;
        
        xml_value_t dataset = root.get_child("NewDataSet");
        for(size_t i=0; i<dataset.size(); i++)
        {
            properties_t pro;
            xml_value_t table = dataset.get_child_node_at(i);
            for(size_t n=0; n<table.size(); n++)
            {
                pro[table.get_child_tag_at(n)] = table.get_child_value_at(n);
            }
            pros.push_back(pro);
        }
        m_xml_map.insert(make_pair(xml_, pros));
        return true;
    }
    vector<properties_t>* get_dataset(string xml_)
    {
        auto it = m_xml_map.find(xml_);
        if (it != m_xml_map.end())
        {
            return &it->second;
        }
        return NULL;
    }
private:
    std::map<string, vector<properties_t>> m_xml_map;    
};

#define sc_xml (singleton_t<sc_xml_t>::instance())

#endif
