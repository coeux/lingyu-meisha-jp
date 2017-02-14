#ifndef _XML_UTIL_H_
#define _XML_UTIL_H_

#include <iostream>
#include <map>
#include <string>
using namespace std;

#include <boost/property_tree/ptree.hpp>                                                                                                                     
#include <boost/property_tree/xml_parser.hpp>
#include <boost/typeof/typeof.hpp>

using boost::property_tree::ptree;

#include "utility.h"

class xml_value_t
{
public:
    xml_value_t();
    explicit xml_value_t(const boost::property_tree::ptree& pt_);

    int parse_xml(const string& filename_);

    string              get_value(const string& node_);
    template<typename T>
    T                   get_value(const string& node_);

    xml_value_t         get_child(const string& node_);
    string              get_attr(const string& node_);
    map<string, string> get_all_attrs(const string& node_);

    size_t              size() const;

    string              get_child_tag_at(size_t i_);
    template<typename T>
    T                   get_child_value_at(size_t i_);
    string              get_child_value_at(size_t i_);
    xml_value_t         get_child_node_at(size_t i_);
    string              get_child_attr_at(size_t i_, const string& node_);
    map<string, string> get_child_all_attrs_at(size_t i_);

    //! if this node exist, return true, or return false
	bool                is_exist(const string& node_);

private:
    ptree::iterator get_iter_i(size_t i_);
private:
    ptree m_pt;
};

template<typename T>
T xml_value_t::get_value(const string& node_)
{
    return utility::string2num<T>(this->get_value(node_).c_str());
}

template<typename T>
T xml_value_t::get_child_value_at(size_t i_)
{
    return utility::string2num<T>(this->get_child_value_at(i_).c_str());
}
#endif

/* tutorial codes
//! config.xml contents as follows:
<?xml version='1.0' encoding='utf-8' ?>
<config>
    <mode fullscreen="false">screen mode</mode>
    <size>123</size>
    <color>  
        <red>0.1</red>
        <green>0.1</green>
        <blue>0.1</blue>
        <alpha>1.0</alpha>
        <alpha>1.0</alpha>
    </color>
</config>

//! use xml_value to parse xml file.
void unit_test
{
    xml_value_t xml;
    if (xml.parse_xml("./config.xml"))
    {
        return -1;
    }
    cout << "config.mode =>" << xml.get_value("config.mode") << endl;
    cout << "config.size =>" << xml.get_value<int>("config.size") << endl;
    cout << "config.mode.fullscreen =>" << xml.get_attr("config.mode.fullscreen") << endl;

    //! traverse child node
    xml_value_t color = xml.get_child("config.color");
    for (size_t i = 0; i < color.size(); ++ i)
    {
        cout << "child tag =>" << color.get_child_tag_at(i) << endl;
        cout << "child value =>" << color.get_child_value_at(i) << endl;
    }
}
*/

