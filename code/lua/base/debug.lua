--debug.lua
---
-- @version 20130920
--
-- @author Phoenix

local GLOBAL = _G

local LEVEL_MAX = 7

local write_to_file = true;

function getTimeString()
  return os.date("%H:%M:%S");
end
function getUID()
  return tostring(ActorManager.user_data.uid);
end
function StandardHead()
  return getTimeString() .. "[" .. getUID() .. "]";
end


--有些机器、包括windows下，没有cache文件夹
if not OperationSystem.IsPathExist( appFramework:GetCachePath() ) then
  OperationSystem.CreatePath( appFramework:GetCachePath(), 755 );
end

local debug_file_path = appFramework:GetCachePath() .. "debug.txt";

local halt = false

local debugfile = nil

local syslog = function(a)
  if write_to_file then
    if not debugfile then
      os.remove(debug_file_path)
      debugfile = io.open(debug_file_path, "a")
    end
    if debugfile == nil then --如果未打开成功，则后续所有操作都不进行
      return
    else
      debugfile:write(a .. "\n");
      debugfile:flush();
    end
  else
    print(a)
  end
end

local is_debug = true
local logtime = 0


local eventString =
{
  [0] =				'入场事件',
  [1] =				'待机事件',
  [2] =				'保持事件',
  [3] =				'移动事件',
  [4] =				'普攻事件',
  [5] =				'技攻事件',
  [6] =				'受到伤害',
  [7] =				'添加效果',
  [8] =				'镜头拉近',
  [9] =				'游戏暂停',
  [10]=				'游戏恢复',
  [11]=				'开始技能',
  [12]=				'结束技能',
  [13]=				'动作暂停',
  [14]=				'动作恢复',
  [15]=				'层级提前',
  [16]=				'恢复层级',
  [17]=				'删除效果',
  [18]=				'效果伤害',
};

local skilltypeString = {
  [0] = '主动技能',
  [1] = '自动技能',
  [2] = '普通攻击',
};

Debug = {
  ---
  -- Usage : <br />
  -- local objA = {['hoge'] = 'fuga', ['foo'] = 'bar'} <br />
  -- local objB = 200 <br />
  -- syslog(GLOBAL.Debug.inspect(objA, objB)) <br />
  -- @param ...
  -- @return
  ['inspect'] = function(...)
    if not is_debug then return "" end

    local function recursiveInspect(value, key, level)
      local str

      local fillSpace = function()
        local str = ''
        for i = 1,level do
          str = str .. ' '
        end

        return str
      end

      local functionTable = {
        ['table'] = function(value, key)
          str = fillSpace() .. string.format('%s[table]\n', key)
          for _key, _value in pairs(value) do
            str = str ..  recursiveInspect(_value, _key, level + 1)
          end
          return str;
        end;

        ['string'] = function(value, key)
          return fillSpace() .. string.format('%s[string] = %s\n', key, value)
        end;

        ['number'] = function(value, key)
          value = tostring(value)
          return fillSpace() .. string.format('%s[number] = %s\n', key, value)
        end;

        ['boolean'] = function(value, key)
          if value then value ='True' else value = 'False' end
          return fillSpace() .. string.format('%s[boolean] = %s\n', key, value)
        end;
      }

      -- 5
      if level > 5 then
        return fillSpace() .. '...'
      end

      --
      local f = functionTable[type(value)]
      if f then
        return f(value, key)
      end
      return fillSpace() .. string.format('%s[%s]\n', key, type(value))
    end

    local resultString = ''
    for i, v in pairs({...}) do
      resultString = resultString .. recursiveInspect(v, '', 0)
    end

    return resultString
  end;

  ---
  -- local objA = {['hoge'] = 'fuga', ['foo'] = 'bar'}
  -- local objB = true
  -- GLOBAL.Debug.var_dump(objA, objB)
  -- @param ...
  -- @return
  ['var_dump'] = function(...)
    if not is_debug then return end
    syslog(GLOBAL.Debug.inspect(...))
  end;

  ---
  --
  -- 'var_dump'
  -- Usage : <br />
  -- local objA = {['hoge'] = 'fuga', ['foo'] = 'bar'} <br />
  -- local objB = 200 <br />
  -- GLOBAL.Debug.printInspect(objA, objB)) <br />
  -- @param ...
  -- @return
  ['print_inspect'] = function(...)
    if not is_debug then return end
    -- space filler
    local fillSpace = function(level)
      local str = ''
      for i = 1,level-1 do
        str = str .. '| '
      end
      if level > 0 then
        str = str .. '+-'
      end
      return str
    end

    -- build linked-list
    local last = nil
    local e = {}
    e.level = 0
    e.name = "(parameter is nil)"
    e.data = ""
    e.next = nil
    local head = e
    for k, v in pairs({...}) do
      e.level = 0
      e.name = k
      e.data = v
      e.next = nil
      if last then
        last.next = e
      end
      last = e
      e = {}
    end

    -- inspect iteratively
    e = head
    while e do
      if type(e.data) == 'table' then
        if e.level > LEVEL_MAX then
          local new = {}
          new.level = e.level + 1
          new.name = '(too deep, stop inspection)'
          new.data = '...'
          new.next = e.next
          e.next = new
        else
          local tmp = e
          local tmp_next = e.next
          for k, v in pairs(e.data) do
            local new = {}
            new.level = e.level + 1
            new.name = k
            new.data = v
            new.next = nil
            tmp.next = new
            tmp = new
          end
          tmp.next = tmp_next
        end
      end
      e = e.next
    end

    -- output string
    e = head
    while e do
      syslog(string.format('%s[%s] %s => %s',
      fillSpace(e.level), type(e.data), tostring(e.name), tostring(e.data)))
      e = e.next
    end
  end;

  ---
  -- local objA = {['hoge'] = 'fuga', ['foo'] = 'bar'}
  -- local objB = true
  -- GLOBAL.Debug.var_dump(objA, objB)
  -- @param ...
  -- @return
  ['print_var_dump'] = function(...)
    if not is_debug then return end
    GLOBAL.Debug.print_inspect(...)
  end;

  ['dump_lua'] = function(t)
    if not is_debug then return end
    if type(t) ~= 'table' then
      return
    end

    local output = function(k, v, indent)
      syslog(string.format('%s%s = %s,', indent, k, v))
    end

    local lua_key = function(k)
      if type(k) == 'string' then
        return string.format("['%s']", k)
      elseif type(k) == 'number' then
        return string.format("[%d]", k)
      else
        return tostring(k)
      end
    end

    local recursive
    recursive = function(t, indent)
      for k, v in pairs(t) do
        if type(v) == 'number' then
          output(lua_key(k), tostring(v), indent)
        elseif type(v) == 'string' then
          output(lua_key(k), string.format('"%s"', v), indent)
        elseif type(v) == 'boolean' then
          output(lua_key(k), tostring(v), indent)
        elseif type(v) == 'table' then
          syslog(string.format('%s%s = {', indent, lua_key(k)))
          recursive(t[k], indent..'  ')
          syslog(string.format('%s},', indent))
        end
      end
    end

    syslog('{')
    recursive(t, '  ')
    syslog('}')
  end;

  ['dump_json'] = function(t)
    if not is_debug then return end
    if type(t) ~= 'table' then
      return
    end

    local output = function(k, v, indent)
      return (string.format('%s%s: %s', indent, k, v))
    end

    local output_l = function(v, indent)
      return (string.format('%s%s', indent, v))
    end

    local json_key = function(k)
      if type(k) == 'string' then
        return string.format('"%s"', k)
      elseif type(k) == 'number' then
        return ""
      else
        return tostring(k)
      end
    end

    local recursive
    recursive = function(t, indent)
      local str = ''
      local first = true
      if #t > 0 then
        for i, v in ipairs(t) do
          if first then
            first = false
          else
            str = str .. ','
            syslog(str)
          end

          if type(v) == 'number' then
            str = output_l(tostring(v), indent)
          elseif type(v) == 'string' then
            str = output_l(string.format('"%s"', v), indent)
          elseif type(v) == 'boolean' then
            str = output_l(tostring(v), indent)
          elseif type(v) == 'table' then
            if #v > 0 then
              syslog(string.format('%s[', indent))
              recursive(v, indent..'  ')
              str = string.format('%s]', indent)
            else
              syslog(string.format('%s{', indent))
              recursive(v, indent..'  ')
              str = string.format('%s}', indent)
            end
          end
        end
      else
        for k, v in pairs(t) do
          if first then
            first = false
          else
            str = str .. ','
            syslog(str)
          end

          if type(v) == 'number' then
            str = output(json_key(k), tostring(v), indent)
          elseif type(v) == 'string' then
            str = output(json_key(k), string.format('"%s"', v), indent)
          elseif type(v) == 'boolean' then
            str = output(json_key(k), tostring(v), indent)
          elseif type(v) == 'table' then
            if #v > 0 then
              syslog(string.format('%s%s: [', indent, json_key(k)))
              recursive(t[k], indent..'  ')
              str = string.format('%s]', indent)
            else
              syslog(string.format('%s%s: {', indent, json_key(k)))
              recursive(t[k], indent..'  ')
              str = string.format('%s}', indent)
            end
          end
        end
      end

      if not first then
        syslog(str)
      end
    end

    syslog('{')
    recursive(t, '  ')
    syslog('}')
  end;


  ['json_2_str'] = function(t, force)
    if (not is_debug) and (not force) then return end
    if type(t) ~= 'table' then
      return
    end

    local result = ""
    local syslog = function(str)
      result = result .. "\n" .. str
    end

    local output = function(k, v, indent)
      return (string.format('%s%s: %s', indent, k, v))
    end

    local output_l = function(v, indent)
      return (string.format('%s%s', indent, v))
    end

    local json_key = function(k)
      if type(k) == 'string' then
        return string.format('"%s"', k)
      elseif type(k) == 'number' then
        return ""
      else
        return tostring(k)
      end
    end

    local recursive
    recursive = function(t, indent)
      local str = ''
      local first = true
      if #t > 0 then
        for i, v in ipairs(t) do
          if first then
            first = false
          else
            str = str .. ','
            syslog(str)
          end

          if type(v) == 'number' then
            str = output_l(tostring(v), indent)
          elseif type(v) == 'string' then
            str = output_l(string.format('"%s"', v), indent)
          elseif type(v) == 'boolean' then
            str = output_l(tostring(v), indent)
          elseif type(v) == 'table' then
            if #v > 0 then
              syslog(string.format('%s[', indent))
              recursive(v, indent..'  ')
              str = string.format('%s]', indent)
            else
              syslog(string.format('%s{', indent))
              recursive(v, indent..'  ')
              str = string.format('%s}', indent)
            end
          end
        end
      else
        for k, v in pairs(t) do
          if first then
            first = false
          else
            str = str .. ','
            syslog(str)
          end

          if type(v) == 'number' then
            str = output(json_key(k), tostring(v), indent)
          elseif type(v) == 'string' then
            str = output(json_key(k), string.format('"%s"', v), indent)
          elseif type(v) == 'boolean' then
            str = output(json_key(k), tostring(v), indent)
          elseif type(v) == 'table' then
            if #v > 0 then
              syslog(string.format('%s%s: [', indent, json_key(k)))
              recursive(t[k], indent..'  ')
              str = string.format('%s]', indent)
            else
              syslog(string.format('%s%s: {', indent, json_key(k)))
              recursive(t[k], indent..'  ')
              str = string.format('%s}', indent)
            end
          end
        end
      end

      if not first then
        syslog(str)
      end
    end

    syslog('{')
    recursive(t, '  ')
    syslog('}')

    return result
  end;

  ['assert'] = function(cond, str, isMsgBox)
    if not str then str = "" end
    if not cond then
      syslog("[assert faild]: " .. str )
      syslog(debug.traceback())
      if isMsgBox then
        MessageBox:ShowDialog(MessageBoxType.Ok, "[assert faild]: " .. str .. debug.traceback(), nil);
      end
    end
  end;

  ['print'] = function(str)
    syslog(str)
  end;

  ['print_update'] = function(str, elapse, range)
    logtime = logtime + elapse
    if logtime > range then
      logtime = 0
      syslog(str)
    end
  end;



  ['print_fight_event'] = function (fighter, eventType, time, actorJson)
    local extString = '(' .. actorJson.m_x ..')'

    if eventType == 6 then
      extString = extString .. " 伤害：" .. actorJson.m_damageValue;
    elseif eventType == 5 then
      extString = extString .. " 技能类型：" .. skilltypeString[actorJson.m_skillType];
    end

    local str = string.format('[%f] [%s] [%s:%d] [%s]',
    time * 0.100,
    eventString[eventType],
    (fighter.isEnemy and "敌方" or "己方"),
    fighter.teamIndex,
    extString
    );
    syslog(str);
  end;


  ['assert_value'] = function(obj, str)
    if not obj then
      Logger:push_back(str);
      print(str);
      return false
    else
      return true
    end
  end;

  ['report_debuglog'] = function(str)
    if not halt then
      halt = true
      str = StandardHead() .. "\nreport_debuglog:" .. tostring(str);
      curlManager:SendHttpScriptRequest('http://niceadm.cgmars.com/test4.php', '', '', str, 0);
    end
  end;

  ['report_once'] = function(str)
    if not halt then
      halt = true
      str = StandardHead() .. "\nreport_once:" .. tostring(str);
      str = str .. "\nLogger ==> \n" .. Logger:to_s();
      curlManager:SendHttpScriptRequest('http://niceadm.cgmars.com/test2.php', '', '', str, 0);
    end
  end;

  ['report'] = function(str)
    str = StandardHead() .. "\nreport:" .. tostring(str);
    --str = str .. "\nLogger ==> \n" .. Logger:to_s();
    curlManager:SendHttpScriptRequest('http://niceadm.cgmars.com/test2.php', '', '', str, 0);
  end;

  ['hook'] = function(fun)
    local old_fun = fun;

    local onerror = function(msg)
      local str = tostring(msg) .. "\n" .. debug.traceback("UID: " .. tostring(ActorManager.user_data.uid), 1);
      local log = Logger:to_s();
      print("==================DEBUG BT===================");
      print(str);
      print(log);
      print("==================DEBUG BT===================");
      if not halt then
        halt = true
        if buglyReortLuaException then
          buglyReportLuaException(msg, debug.traceback())
        end
        curlManager:SendHttpScriptRequest('http://niceadm.cgmars.com:8010/test2.php', '', '', str .. "\n" .. log, 0);
      end
    end

    return function(...)
      local args = { ... }

      local run = function()
        return old_fun(unpack(args))
      end

      local s, e= xpcall(run, onerror);
      if s then
        return e;
      else
        return false;
      end
    end;

  end
}

Debug.is_debug = true;
