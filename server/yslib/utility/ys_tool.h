#ifndef _ys_tool_h_
#define _ys_tool_h_

#include <boost/algorithm/string.hpp>
#include <string>
using namespace std;

class ys_tool_t
{
public:
    static void filter_str(string& str)
    {
        boost::algorithm::replace_all(str, " ", "");
        boost::algorithm::replace_all(str, "\a", "");
        boost::algorithm::replace_all(str, "\b", "");
        boost::algorithm::replace_all(str, "\f", "");
        boost::algorithm::replace_all(str, "\n", "");
        boost::algorithm::replace_all(str, "\r", "");
        boost::algorithm::replace_all(str, "\v", "");
        boost::algorithm::replace_all(str, "\t", "");
        boost::algorithm::replace_all(str, "\'", "");
        boost::algorithm::replace_all(str, "\"", "");
        boost::algorithm::replace_all(str, "\\", "");
        boost::algorithm::replace_all(str, "\?", "");
        boost::algorithm::replace_all(str, "\0", "");
        boost::algorithm::replace_all(str, "`", "");
        boost::algorithm::replace_all(str, "#", "");
        boost::algorithm::replace_all(str, "$", "");
        boost::algorithm::replace_all(str, "%", "");
        boost::algorithm::replace_all(str, "^", "");
        boost::algorithm::replace_all(str, "&", "");
        boost::algorithm::replace_all(str, "*", "");
        boost::algorithm::replace_all(str, "(", "");
        boost::algorithm::replace_all(str, ")", "");
        boost::algorithm::replace_all(str, "_", "");
        boost::algorithm::replace_all(str, "-", "");
        boost::algorithm::replace_all(str, "+", "");
        boost::algorithm::replace_all(str, "=", "");
        boost::algorithm::replace_all(str, ",", "");
        boost::algorithm::replace_all(str, ".", "");
    }
};

#endif
