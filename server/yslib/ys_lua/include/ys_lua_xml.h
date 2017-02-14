#ifndef _FM_LUA_XML_H_
#define _FM_LUA_XML_H_

#include "ys_lua.h"
#include "ys_json.h"
#include "xml_util.h"

namespace ys_lua
{
    static Json::Value gen(xml_value_t& xv, const string& key_)
    {
        Json::Value obj;
        for (size_t i = 0; i < xv.size(); ++ i)
        {
            string key = xv.get_child_tag_at(i);
            Json::Value value;
    
            xml_value_t cxv = xv.get_child_node_at(i);
            if (cxv.size() == 0)
            {
                value = Json::Value(xv.get_child_value_at(i));
                obj[key] = value;
            }
            else
            {
                value = gen(cxv, key);
                obj[key].append(value);
            }
        }

        return obj;
    }

    static string xml_to_json(const string& xml_)
    {
        xml_value_t xv;
        if (xv.parse_xml(xml_))
        {
            return "";
        }

        Json::Value root = gen(xv, "root");
        Json::FastWriter writer;
        return writer.write(root);
    }
};

LUA_REGISTER_BEGIN(ys_lua_xml)

REGISTER_STATIC_FUNCTION("ys_lua", "xml_to_json", ys_lua::xml_to_json)

LUA_REGISTER_END

#endif
