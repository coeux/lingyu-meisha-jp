--[[
split(',', "123,234,444")
return
{"123", "234", "444"}
]]
function split(c_, str_)
    local t={}
    local i=0
    local j=1
    while true do 
        i=string.find(str_,c_,i+1)
        if i==nil then 
            local fstr = string.sub(str_,j,string.len(str_))
            if fstr ~= "" then
                table.insert(t, fstr)
            end
            break 
        end
        local fstr = string.sub(str_,j,i-1)
        if fstr ~= "" then
            table.insert(t, fstr)
        end
        j=i+1
   end
   return t  
end
