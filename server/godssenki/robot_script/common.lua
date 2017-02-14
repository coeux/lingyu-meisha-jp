--define
OK = 0

--global
--mac
g_mac = ''
--账户id
g_aid = 0
--用户id
g_uid = 0
--全局的用户数据
g_ud = {}

--recv hanlder
cmd_mgr = {}

function table_size(table_)
    local n = 0
    for _,v in pairs(table_) do
        if v ~= nil then
            n = n+1
        else 
            return n
        end
    end
    return n
end
