#include "xml_util.h"

xml_value_t::xml_value_t()
{
}

xml_value_t::xml_value_t(const boost::property_tree::ptree& pt_):
    m_pt(pt_)
{
}

int xml_value_t::parse_xml(const string& filename_)
{
    try
    {
        read_xml(filename_, m_pt);
    }
    catch(exception& e_)
    {
        cerr << "xml_value_t::parse_xml =>" << e_.what() <<"\n";
        return -1;
    }
    return 0;
}

string xml_value_t::get_value(const string& node_)
{
    try
    {
        return m_pt.get<string>(node_);
    }
    catch(exception& e_)
    {
        cerr << "xml_value_t::get_value =>" << e_.what() <<"\n";
    }
    return "";
}

string xml_value_t::get_attr(const string& node_)
{
    string tmp_path;
    string::size_type sep = node_.rfind('.');
    if (sep == string::npos || sep == node_.length() - 1)
    {
        return "";
    }
    tmp_path.append(node_.begin(), node_.begin() + sep + 1);
    tmp_path += "<xmlattr>";
    tmp_path.append(node_.begin()+ sep, node_.end());
    //! cout <<tmp_path <<"\n";
    return this->get_value(tmp_path);
}

map<string, string> xml_value_t::get_all_attrs(const string& node_)
{
    map<string, string> ret;
    xml_value_t tmp = get_child(node_ + ".<xmlattr>");
    for (size_t i = 0; i < tmp.size(); ++ i)
    {
        ret[tmp.get_child_tag_at(i)] = tmp.get_child_value_at(i);
    }
    return ret;
}

xml_value_t xml_value_t::get_child(const string& node_)
{
    try
    {
        ptree pt = m_pt.get_child(node_);
        return xml_value_t(pt);
    }
    catch(exception& e_)
    {
        //! TODO cerr << "xml_value_t::get_child =>" << e_.what() <<"\n";
    }
    return xml_value_t();
}

size_t xml_value_t::size() const
{
    return m_pt.size();
}

ptree::iterator xml_value_t::get_iter_i(size_t i_)
{
    ptree::iterator it = m_pt.begin();
    for (size_t n = 0; n < i_ && it != m_pt.end(); ++ n, ++ it)
    {
    }
    return it;
}

string xml_value_t::get_child_tag_at(size_t i_)
{
    ptree::iterator it = get_iter_i(i_);
    return it->first.data();
}

string xml_value_t::get_child_value_at(size_t i_)
{
    ptree::iterator it = get_iter_i(i_);
    return it->second.data();
}

string xml_value_t::get_child_attr_at(size_t i_, const string& node_)
{
    return get_child_all_attrs_at(i_)[node_];
}

map<string, string> xml_value_t::get_child_all_attrs_at(size_t i_)
{
    ptree::iterator it = get_iter_i(i_);
    xml_value_t child(it->second);

    map<string, string> ret;
    xml_value_t tmp = child.get_child("<xmlattr>");
    for (size_t i = 0; i < tmp.size(); ++ i)
    {
        ret[tmp.get_child_tag_at(i)] = tmp.get_child_value_at(i);
    }
    return ret;
}

xml_value_t xml_value_t::get_child_node_at(size_t i_)
{
    ptree::iterator it = get_iter_i(i_);
    return xml_value_t(it->second);
}

bool xml_value_t::is_exist(const string& node_)
{
    try
    {
        m_pt.get_child(node_);
        return true;
    }
    catch(exception& e_)
    {
        return false;
    }
    return false;
}
