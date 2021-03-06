port_info=
{
route = {out=41100,inner=41200},
gw = {out=42100,inner=42200},
inv = {out=0,inner=43000},
}
function get_port_info()
    return cjson.encode(port_info)
end

function get_domain()
    return 'android'
end


log = {
    level = 6,
    path = '/tmp/log/',
    print_file = 1,
    print_screen = 1,
    modules = {
        'PUSHINFO',
        'REPO',
        --'WRITE_STATE',
        'DB_MYSQL',
        'DB_SERVICE',
        --'HEART_BEAT',
        "RPC_ACCEPTOR",
        --"RPC_CONNECTER",
        "RPC_CCP",
        "RPC",
        "RPC_CLIENT",
        "RPC_SERVER",
        "RPC_CONN_MGR",
        'SERVICE_BASE',
        "LG_SERVER",
        "LG_SERVICE",
        'LG_LOGIC',
        'GEN_NAME',
        'SC_CACHE',
        "SC_SERVER",
        "SC_SERVICE",
        'SC_LOGIC',
        'SC_HOST',
        'SC_SESSION',
        'SC_SKILL',
        'SC_EQUIP',
        'SC_PARTNER',
        'SC_CITY',
        'SC_PRO',
        'SC_ROUND',
        'SC_TRIAL',
        'SC_TEAM',
        'SC_ARENA',
        'SC_ITEM',
        'SC_GANG',
        'SC_ARENA_RANK',
        'SC_TREASURE',
        'SC_TASK',
        'SC_CHRONICLE',
        'SC_SHOP',
        'SC_INV_CLIENT',
        'SC_MAIL',
        'SC_REWARD',
        'SC_VIP',
        'SC_LUA',
        'SC_DAILY_TASK',
        'SC_BOSS',
        'SC_CITY_BOSS',
        'SC_RANK_SEASON',
        'SC_RANK_MATCH',
        'RT_PUBLIC',
        'RT_PRIVATE',
        'GW_PUBLIC',
        'GW_PRIVATE',
        'GW_RT_CLIENT',
        'DBMID',
        'DBMID_CLIENT',
        'DBMID_SERVER',
        'DBMID_SERVICE',
        'DBMID_CACHE',
        'INV_SERVER',
        'INV_SERVICE',
        'PF_SERVICE',
        'MSG_DISPATCH',
        "SC_REWARD_MCARD",
        'SC_CARD_EVENT',
    }
}

function get_log()
    --print(cjson.encode(log))
    return cjson.encode(log)
end

comlog = {
    level = 3,
    path = './comlog/',
    print_file = 1,
    print_screen = 1,
    max_module = 64,
    modules = {
        'COM_PERF',
    }
}

function get_comlog()
    --print(cjson.encode(comlog))
    return cjson.encode(comlog)
end

heart_beat = {
    --是否启用心跳
    timedout_flag = 1,
    --心跳过期时间
    timedout = 3600*5,
    --是否启用最大心跳容器上限
    max_limit_flag = 0,
    --最大上限
    max_limit = 50000,
}

function get_heart_beat()
    --print(cjson.encode(heart_beat))
    return cjson.encode(heart_beat)
end

--性能监控
perf = {
    flag = 1,
    interval = 5,
}

function get_perf()
    --print(cjson.encode(perf))
    return cjson.encode(perf)
end

--本地缓存
cache = {
    max = 0,
}
function get_cache()
    return cjson.encode(cache)
end

--资源文件
res = 
{
lua_path = './script/',
repo_path = './repo/',
rank_path = './rank/',
bt_record_path = './bt_record/',
}

function get_res()
    return cjson.encode(res)
end

--消息压缩
msg_compress = {
    --是否启用
    open = 1,
    --不启用压缩上限
    max = 1024,
}
function get_msg_compress()
    return cjson.encode(msg_compress)
end

--配置数据库
conf_sqldb = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='nice_sertool',
}
function get_conf_sqldb()
    return cjson.encode(conf_sqldb)
end

--统计数据库
statics_sqldb = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd='13683048948o',
    name='nice_statics',
}
function get_static_sqldb()
    return cjson.encode(statics_sqldb)
end

--全局据库
global_sqldb = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceshot_base',
    --name='niceserver2',
}
function get_global_sqldb()
    return cjson.encode(global_sqldb)
end

--游戏数据库表
sqldb_map = {}
sqldb_map['1'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceshot_base',
    --name='niceserver_online',
}
sqldb_map['2'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceshot_jp',
    --name='niceserver_online',
}

function get_sqldb()  
    local wrap = {}
    wrap.contain = sqldb_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

invcode = {
    ip = '10.131.152.110',
    port = tostring(port_info.inv.inner),
    thread_num = 1,
    sqldb ={
        id = '1',
        conn_num = 1,
    },
}

function get_invcode()
    local wrap = {}
    return cjson.encode(invcode)
end

scene_map = {}
scene_map['1'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {1},
}
scene_map['2'] = {
    sqldb = {
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {2},
}

scene_map['3'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },

    thread_num = 1,
    contain_host = {3},
}
scene_map['321'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {321},
}
scene_map['323'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {323},
}
scene_map['123'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {123},
}

function get_scene()
    local wrap = {}
    wrap.contain = scene_map
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

gateway_map = {}
gateway_map['1'] = {
    listen_ip= '0.0.0.0',
    public_ip = '182.254.147.153',
    public_port = tostring(port_info.gw.out+1),
    private_ip = '127.0.0.1',
    private_port = tostring(port_info.gw.inner+1),
    thread_num = 4,
}
--[[
gateway_map['2'] = {
    listen_ip= '10.0.128.17',
    public_ip = '10.0.128.17',
    public_port = tostring(port_info.gw.out+2),
    private_ip = '10.0.128.17',
    private_port = tostring(port_info.gw.inner+2),
    thread_num = 4,
}
gateway_map['3'] = {
    listen_ip= '10.0.128.17',
    public_ip = '10.0.128.17',
    public_port = tostring(port_info.gw.out+3),
    private_ip = '10.0.128.17',
    private_port = tostring(port_info.gw.inner+3),
    thread_num = 4,
}
--]]

function get_gateway()
    local wrap = {}
    wrap.contain = gateway_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

route = {}
route.listen_ip= '0.0.0.0'
route.public_ip = '182.254.147.153'
route.private_port = tostring(port_info.route.inner)
route.private_ip = '127.0.0.1'
route.public_port = tostring(port_info.route.out)
route.thread_num = 10

function get_route()
    return cjson.encode(route)
end

gslist = 
{
    { hostnum = 1, name = '测试二服', serid = 1, recom=true},
    { hostnum = 2, name = '日文测试服（暂', serid = 2, recom=true},
} 

function get_gslist()
    local wrap = {}
    wrap.contain = gslist 
    return cjson.encode(wrap)
end
