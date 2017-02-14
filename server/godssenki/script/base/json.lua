json_t = {}
json_t.__index = json_t

function json_t:encode(tb_)
    return cjson.encode(tb_)
end

function json_t:decode(json_str_)
    return cjson.decode(json_str_)
end

function json_unit_test()

    tb = {{["abc"] = 123, [123] = 345, [234]="xxx", [455]=true, [34535]={{123}}}, 123, true, false, "array_item", {123, true, false, "item"}}
    -- ret = "[{\"123\":345,\"234\":\"xxx\",\"34535\":[[123]],\"455\":true,\"abc\":123},123,true,false,\"array_item\",[123,true,false,\"item\"]]"
    local ret = json_t:encode(tb)
    print (ret)

    local root = json_t:decode(ret)
    for k, v in pairs(root)
    do
        print(k, v)
        if type(v) == "table"
        then
            for k2, v2 in pairs(v)
            do
                print("", k2, v2)
                if type(v2) == "table"
                then
                    for k3, v3 in pairs(v2)
                    do
                        print("", "", k3, v3)
                    end
                end
            end
        end
    end
end
