out_ip = '42.62.22.92'
inner_ip = '10.1.11.57'

port_map=
{
route = {out=51100,inner=51200},
gw = {out=52100,inner=52200},
inv = {inner=53000},
}

log = {
    level = 6,
    path = '/tmp/godssenki/log/',
    print_file = 1,
    print_screen = 1,
    modules = {
        'REPO',
        --'WRITE_STATE',
        'DB_MYSQL',
        --'DB_SERVICE',
        --'HEART_BEAT',
        "RPC_ACCEPTOR",
        "RPC_CONNECTER",
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
        'SC_TASK',
        'SC_SHOP',
        'SC_INV_CLIENT',
        'SC_MAIL',
        'SC_REWARD',
        'SC_VIP',
        'SC_LUA',
        'SC_DAILY_TASK',
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
    }
}

function get_log()
    --print(cjson.encode(log))
    return cjson.encode(log)
end

comlog = {
    level = 3,
    path = '/tmp/godssenki/comlog/',
    print_file = 0,
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
    interval = 300,
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
lua_path = '/tmp/godssenki/script/',
repo_path = '/tmp/godssenki/repo/',
rank_path = '/tmp/godssenki/rank/91/',
bt_record_path = '/tmp/godssenki/bt_record/91/',
}

function get_res()
    return cjson.encode(res)
end

--统计数据库
statics_sqldb = {
    ip = '10.1.13.24',
    port='3306',
    user='inter',
    pwd ='helloworld',
    name='God_statics',
}
function get_static_sqldb()
    return cjson.encode(statics_sqldb)
end

--游戏数据库表
sqldb_map = {}
sqldb_map['1'] = {
    ip = '10.1.13.24',
    port='3306',
    user='test',
    pwd ='helloworld',
    name='God_91',
}

function get_sqldb()  
    local wrap = {}
    wrap.contain = sqldb_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

invcode_map = {}
invcode_map['1'] = {
    ip = inner_ip,
    port = '20001',
    thread_num = 1,
    sqldb ={
        id = '1',
        conn_num = 1,
    },
}

function get_invcode()
    local wrap = {}
    wrap.contain = invcode_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
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

function get_scene()
    local wrap = {}
    wrap.contain = scene_map
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

gateway_map = {}
gateway_map['1'] = {
    private_ip = inner_ip,
    private_port = tostring(port_map.gw.inner),
    public_ip = out_ip,
    public_port = tostring(port_map.gw.out),
    thread_num = 1,
}

function get_gateway()
    local wrap = {}
    wrap.contain = gateway_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

login_map = {}
login_map['1'] = {
    sqldb= {
        id = '1',
        conn_num = 1,
    },
    thread_num = 1,
}

function get_login()
    local wrap = {}
    wrap.contain = login_map
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

route = {}
route.private_ip = inner_ip
route.public_port = tostring(port_map.route.out)
route.public_ip = out_ip
route.private_port = tostring(port_map.route.inner)
route.thread_num = 10

function get_route()
    return cjson.encode(route)
end

gslist = 
{
    { hostnum = 1, name = '众神之巅', serid = 1, recom=true},
}

function get_gslist()
    local wrap = {}
    wrap.contain = gslist 
    return cjson.encode(wrap)
end
