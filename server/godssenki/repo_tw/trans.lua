string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

local file = io.open("full_name.txt", "rb")
local data = file:read("*all")
file:close()

local real = {}
local slines = string.split(data, '\r\n')
for k, v in pairs(slines) do
    table.insert(real, v)
end

local sdata = table.concat(real, '\n')

file = io.open("full_name.txt", "wb")
file:write(sdata)
file:close()
