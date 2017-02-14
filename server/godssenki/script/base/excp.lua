require "base.cpp"

---异常类
excp = {}

--- 抛出错误信息
-- @param message
-- @param code
--
function excp:throw( message , code )

    if code == nil then
        code = "nil"
    end

    local msg = "MESSAGE:" .. message .. "  CODE:" .. code 
    cpp_t:e("LUA_EXCP", msg)
    error(msg)
end
