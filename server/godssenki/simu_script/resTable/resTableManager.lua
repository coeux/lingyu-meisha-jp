resTableManager = 
{
	m_KeyTableList = {};
}
resTableManager.__index = resTableManager

--[[
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
--]]

string.split = function(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

string.trim = function(s) 
  return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end 

string.trim2 = function(s)
    return string.gsub(s, "%\"", '')
end

function resTableManager:LoadTable(tableID, fileName, keyName)
	if nil ~= self.m_KeyTableList[tableID] then
		return false;
	end	

    print(string.format('load file:%s, keyName:%s...', fileName, keyName))
	
	local file = io.open(fileName, "rb")
    if file == nil then
        print(string.format('ERROR! can not found file:%s', fileName))
        return false
    end

	local data = file:read('*all')
	file:close()

    local rows = string.split(data, '\r\n')
    local keys = {}
    local n=0
    local row_data = {}
    for k, v in pairs(rows) do
        v = string.trim(v)
        v = string.trim2(v)
        if string.len(v) == 0 then 
            break;
        end
        local cols = string.split(v, '\t') 
        n = n + 1
        if n == 1 then
            for kk, vv in pairs(cols) do
                table.insert(keys, string.trim(vv))
            end
        else
            local keyv = nil
            local node = {}
            for kk,vv in pairs(keys) do
                if keyName == vv then
                    keyv = cols[kk]	
                end
                node[vv] = cols[kk]
            end
            row_data[keyv] = node
        end
    end

    self.m_KeyTableList[tableID] = row_data
    print(string.format('load file:%s...ok', fileName))

    return true
end

function resTableManager:GetValue(id, key, colname)
    return self.m_KeyTableList[id][key][colname]
end

function resTableManager:GetRowValue(id, key)
    return self.m_KeyTableList[id][key]
end

--resTableManager:LoadTable(1, "role.txt", 'aa');
