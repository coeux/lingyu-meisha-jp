local monitor_pid = {}
local mailaddr = '192.168.6.17:8080/server/mail.php'

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

function exec(cmd_)
    local fret = io.popen(cmd_)
    local str = fret:read('*all')
    local ret=string.split(str, '\n')
    fret:close()
    return ret
end

function show_version()
    local ret = exec('ls /data/app/ | grep zip')
    return cjson.encode(ret)
end

function cat_version()
    local ret = exec('cat /data/app/version')
    return ret[1]
end

function up_version(version_)
    local rsync_cmd=string.format("sudo rsync -avz root@211.151.21.146:/data/app/%s /data/app/ -e 'ssh -o StrictHostKeyChecking=no -i cszs-key.pem -p 60020' --progress", version_)
    local unzip_cmd=string.format('sudo unzip -o /data/app/%s -d /data/app/', version_)
    local remove_zip=string.format('sudo rm /data/app/%s -rf', version_)
    local ret = exec(rsync_cmd.." && "..unzip_cmd.." && "..remove_zip)
    return cat_version()
end

function grep_pid_file()
    local ret = exec(string.format('ls /data/run/ | grep pid'))
    for k,v in pairs(ret) do 
        local pid = exec(string.format('cat /data/run/%s', v))
        local info = string.split(v, '.')
        monitor_pid[pid[1]] = {domain=info[1], progname=info[2], hostnum=info[3], pid=pid[1]};
    end
end

function get_pid(domain_, progname_, hostnum_)
    local file = io.open(string.format('/data/run/%s.%s.%d.pid', domain_, progname_, hostnum_), 'r')
    if file ==nil then
        return nil 
    else
        local pid = file:read("*all")
        pid = string.split(pid, '\n')[1]
        file:close()
        return pid
    end
end

function has_pid_file(domain_, progname_, hostnum_)
    local file = io.open(string.format('/data/run/%s.%s.%d.pid', domain_, progname_, hostnum_),'r')
    if file ==nil then
        return false
    else
        file:close()
        return true
    end
end

function has_pid(domain_, progname_, hostnum_)
    local pid = get_pid(domain_, progname_, hostnum_)
    if pid == nil then
        return false
    end
    local cmd = string.format("ps --no-heading %s | wc -l", pid);
    local ret = exec(cmd)
    if tonumber(ret[1]) == 0 then
        return false
    end
    return true
end

function start_prog(domain_, progname_, hostnum_)
    os.execute(string.format("sudo /data/app/startup start %s %s %d", domain_, progname_, hostnum_));
end

function close_prog(domain_, progname_, hostnum_)
    os.execute(string.format("sudo /data/app/startup stop %s %s %d", domain_, progname_, hostnum_));
end

function watch_pid(domain_, progname_, hostnum_) 
    local pid = get_pid(domain_, progname_, hostnum_)
    local p = {}
    p.filepath = string.format('/data/run/%s.%s.%d.pid', domain_, progname_, hostnum_)
    p.domain = domain_
    p.progname = progname_
    p.hostnum = hostnum_
    p.pid = pid
    monitor_pid[p.pid]=p
end

function unwatch_pid(domain_, progname_, hostnum_)
    for k,v in pairs(monitor_pid) do
        if v.domain == domain_ and v.progname == progname_ and v.hostnum == hostnum_ then
            monitor_pid[k] = nil
            break
        end
    end
end

function remove_pid_file(domain_, progname_, hostnum_)
    exec(string.format("sudo rm /data/run/%s.%s.%d.pid -rf", domain_, progname_, hostnum_))
end

function update_watch_pid()
    grep_pid_file()
    for k,v in pairs(monitor_pid) do
        local haspidfile = has_pid_file(v.domain, v.progname, v.hostnum)
        local haspid = has_pid(v.domain, v.progname, v.hostnum)
        if false == haspid and 
           true == haspidfile then
            monitor_pid[k] = nil
            --print("CRASH:"..k)
            remove_pid_file(v.domain, v.progname, v.hostnum)
            --发邮件到139报警,同时重启进程
            start_prog(v.domain, v.progname, v.hostnum) 
            --cpp:http_post(mailaddr, cjson.encode({domain=v.domain,hostnum=v.hostnum,progname=v.progname,info=''}))
        elseif haspidfile and haspid then
            print("NOW PID:"..v.pid)
        else
            monitor_pid[v.pid] = nil
            --print("UNEXIST")
        end
    end
end

function reload()
end

local call={}
call['show_version']=show_version
call['cat_version']=cat_version
call['up_version']=up_version

function on_msg(msg_)
    local req = cjson.decode(msg_)
    return call[req.cmd](req.msg)
end

grep_pid_file()
cpp:begin_syscol()
cpp:start_timer(5)
function on_timer()
    --[[
    local sysinfo = cjson.decode(cpp:end_syscol())
    print('cpu:', (sysinfo.cpu * 100)..'%', 'mem:', (sysinfo.mem * 100)..'%');
    --]]

    update_watch_pid()
    cpp:start_timer(5)
    cpp:begin_syscol()
    return 'ok'
end

--[[
print('begin...')
print(up_version('1.5.2.zip'))
print('end...ok')
--]]
--print(get_pid('ios', 'scene', 199))
--print(has_pid('ios', 'scene', 199))
--local ret = cpp:http_post('192.168.6.17:8080/server/mail.php', cjson.encode({hostnum=199,domain='ios',progname='scene',info=''}))
--print(ret)
--start_prog('ios', 'scene', 199)
--
--print(cjson.encode({cpu=0,mem=0}))
--cjson.decode("{\"cpu\":0,\"mem\":0}")
