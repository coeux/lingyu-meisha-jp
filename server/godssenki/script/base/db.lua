require "base.excp"
require "base.tools"
require "base.cpp"
require "base.coroutine_mgr"

--[[
columns = {
    {
        ['name'] = 'uid',
        ['type'] = 'number'
    },
    {
        ['name'] = 'master_uid',
        ['type'] = 'number'
    },
    {
        ['name'] = 'last_revolt_time',
        ['type'] = 'number'
    },
}

condition = {
    uid = 1001,
}

list = db_t:fetch_object( 'player_profile' , columns , condition )


db_t:delete( 1001 , 'player_profile', condition )

local data = {
    ['uid'] = 1004,
    ['master_uid'] = 1005,
    ['last_revolt_time'] = 111111111
}

db_t:insert( 1001, 'player_profile' , data )

db_t:update( 1001, 'player_profile' , data , condition )
--]]

db_t = {}

--- 获取指定结果集第一行数据
-- @param result
--
function db_t:fetch_row(id_, table_name, columns , condition )
    local result = db_t:_get_result(id_, table_name, columns , condition )

    local row_num = tonumber(result.object:affect_row_num())
    cpp_t:trace('LUA_DB', "row_num:"..row_num..", id:"..id_)
    if row_num == 0 then
        result.object:delete() --note: object is cpp pointer! must be delete!
        result.object = nil
        return nil
    end

    local column_num = tonumber( result.object:affect_column_num() )

    cpp_t:trace('LUA_DB', "column_num:"..column_num..", id:"..id_)
    --验证列显示字段和实际字段数量是否一致
    if #result.columns <= 0 then
        excp_t:throw( "DB_COLUMNS_PARAM_ERROR" )
    end

    local row_data = {}
    for i=0,row_num-1 do
        local row = result.object:get_row_at(i)
        local row_item = {}
        for k = 0 , column_num - 1 do
            local value
            --转换数据类型(数据库取出全为字符串)
            local col_type = result.columns[k+1]['type']
            if col_type == 'string' then
                value = tostring( row:get_value_at( k ) )
            elseif col_type == 'number' then
                value = tonumber( row:get_value_at( k ) )
            end
            row_item[result.columns[k+1]['name']] = value
        end
        table.insert(row_data, row_item)
    end
    result.object:delete() --note: object is cpp pointer! must be delete!
    result.object = nil
    return row_data
end

--- 通过结果对象返回多行数据, 键名作为key
-- @param result
--
function db_t:fetch_object(id_, table_name, columns , condition )
    local result = db_t:_get_result(id_, table_name , columns , condition )
    local datalist = {}

    local column_num = tonumber( result.object:affect_column_num() )
    local row_num = tonumber( result.object:affect_row_num() )

    --验证列显示字段和实际字段数量是否一致
    if #result.columns <= 0 then
        excp_t:throw( "DB_COLUMNS_PARAM_ERROR" )
    end

    for i = 0, row_num - 1 do
        local data = {}
        local row = result.object:get_row_at(i)
        for k = 0 , column_num - 1 do
            local value

            --转换数据类型(数据库取出全为字符串)
            local col_type = result.columns[k+1]['type']
            if col_type == 'string' then
                value = tostring( row:get_value_at( k ) )
            elseif col_type == 'number' then
                value = tonumber( row:get_value_at( k ) )
            end
            data[result.columns[k+1]['name']] = value
        end
        table.insert(datalist, data)
    end

    result.object:delete() --note: object is cpp pointer! must be delete!
    result.object = nil

    return datalist
end

--- 通过SQL生成器返回result
-- @param table_name             表名
-- @param columns   table   各列字段名称
--  table{
--      table{
--          type:string         字段类型
--          name:string         字段名称
--      }
--      ...
--  }
-- @param condition         查找条件
-- @return  table_name      返回result对象
--  table{
--      object:class            result对象
--      columns:table           各列字段名称
--  }
function db_t:_get_result(uid_, table_name, columns , condition )
    local db_result = {
        ['columns'] = {},
        ['object'] = {}
    }

    --必须有条件
    if not next( condition ) then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --验证表名称
    if #table_name <= 0 then
        excp_t:throw( "DB_TABLE_NAME_ERROR" )
    end

    --必须有列字段
    if not next( columns ) then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --判断列字段格式是否正确
    if self:_columns_valid( columns ) == false then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --生成SQL显示列部分
    local colname = {}
    for _ , col in pairs( columns ) do
        table.insert( colname , '`' .. col['name'] .. '`' )
    end
    local columns_str = table.concat( colname , ' , ' )

    --生成条件语句
    local condition_str = self:_create_condition_string( condition )

    sql = "SELECT " .. columns_str .. " FROM `" .. table_name .. "` WHERE " .. condition_str

    db_result.columns = columns

    cpp_t:trace('LUA_DB', 'sql_select..., uid:'..uid_)
    local res = sql_result_t:new()
    cpp_t:sql_select(sql, res)
    --[[
    cpp_t:sql_select(id_, sql, res, "on_select")
    --不在使用携程了
    coroutine.yield()
    --]]
    --note: object is cpp pointer! must be delete!
    db_result.object = res 
    cpp_t:trace('LUA_DB', 'sql_select...ok, id:'..uid_)
    return db_result
end

--- 删除指定条件的数据
-- @param uid           number      用户名
-- @param table_name    string      表名
-- @param condition     table       条件
--
function db_t:delete( uid , table_name , condition )
    --必须有条件
    if not next( condition ) then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --验证表名称
    if #table_name <= 0 then
        excp_t:throw( "DB_TABLE_NAME_ERROR" )
    end

    --必须有条件
    if not next( condition ) then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --生成条件语句
    local condition_str = self:_create_condition_string( condition )

    local sql = "DELETE FROM `" .. table_name .. "` WHERE " .. condition_str

    cpp_t:sql_execute(uid, sql )
end

--- 插入一行数据
-- @param uid
-- @param table_name
-- @param data
function db_t:insert( uid , table_name , data )

    --验证用户ID
    if tonumber( uid ) <= 0 then
        excp_t:throw( "DB_UID_ERROR" )
    end

    --验证表名称
    if #table_name <= 0 then
        excp_t:throw( "DB_TABLE_NAME_ERROR" )
    end

    --生成数据插入语句
    local data_arr = {}
    local data_cols_name = {}
    local data_cols_val = {}
    for key , value in pairs( data ) do
        table.insert( data_cols_name , ' `' .. key .. '` ' )
        table.insert( data_cols_val , self:_create_value( value ) )
    end
    --大于一个条件则需要使用AND连接
    local data_cols_name_str = table.concat( data_cols_name , ' , ' )
    local data_cols_val_str = table.concat( data_cols_val, ' , ' )

    local sql = "INSERT INTO `" .. table_name .. "` (" .. data_cols_name_str .. ") VALUES ( " .. data_cols_val_str .. " ) "

    cpp_t:sql_execute(uid, sql )
end

--- 更新指定条件的数据
-- @param uid
-- @param table_name
-- @param data
-- @param condition
--
function db_t:update( uid , table_name , data , condition )
    --验证用户ID
    if tonumber(uid) <= 0 then
        excp_t:throw( "DB_UID_ERROR" )
    end

    --验证表名称
    if #table_name <= 0 then
        excp_t:throw( "DB_TABLE_NAME_ERROR" )
    end

    --必须有条件
    if not next( condition ) then
        excp_t:throw( "DB_PARAM_ERROR" )
    end

    --生成条件语句
    local condition_str = self:_create_condition_string( condition )

    --生成数据更新语句
    local data_str = self:_create_data_string( data )

    local sql = "UPDATE `" .. table_name .. "` SET " .. data_str .." WHERE " .. condition_str

    cpp_t:sql_execute(uid, sql )
end

--- 返回影响行数
-- @param result
--
function db_t:affected_row( result )
    result.object:affect_row_num()
end

--- 生成条件语句
-- @param condition
--
function db_t:_create_condition_string( condition )
    --生成SQL条件部分
    local condition_arr = {}
    local condition_str = ''
    for key , value in pairs( condition ) do
        table.insert( condition_arr , ' `' .. key .. '`' .. " = " .. self:_create_value( value ) )
    end
    --大于一个条件则需要使用AND连接
    if #condition_arr > 1 then
        condition_str = table.concat( condition_arr , ' AND ' )
    else
        condition_str = condition_arr[1]
    end

    return condition_str
end

--- 生成更新语句
-- @param condition
--
function db_t:_create_data_string( data )
    --生成SQL条件部分
    local data_arr = {}
    local data_str
    for key , value in pairs( data ) do
        table.insert( data_arr, ' `' .. key .. '`' .. " = " .. self:_create_value( value ) )
    end
    --大于一个条件则需要使用AND连接
    if #data_arr > 1 then
        data_str = table.concat( data_arr, ' , ' )
    else
        data_str = data_arr[1]
    end

    return data_str
end

--- 判断显示列格式是否正确
-- @param columns
--
function db_t:_columns_valid( columns )
    for _ , col in pairs( columns ) do
        if type( col['type'] ) ~= 'string' or #col['type'] <= 0 then
            return false
        end

        if col['type'] == 'number' then
        elseif col['type'] == 'string' then
        else
            return false
        end

        if type( col['name'] ) ~= 'string' or #col['name'] <= 0 then
            return false
        end
    end
end

--- 根据值类型生成SQL内VALUE
-- @param value
--
function db_t:_create_value( value )
    local value_type = type( value )
    if value_type == "number" then
        return value
    elseif value_type == "string" then
        return " '" .. value .. "' "
    end
end

--[[
function on_select(id_)
    cpp_t:trace('LUA_DB', 'on_select, id:'..id_)
    schedule_t:resume(id_)
    return "on_select"
end
--]]
