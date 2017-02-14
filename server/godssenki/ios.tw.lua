port_info=
{
route = {out=51100,inner=51200},
gw = {out=52100,inner=52200},
inv = {out=0,inner=53000},
}
function get_port_info()
    return cjson.encode(port_info)
end

function get_domain()
    return 'android'
end

log = {
    level = 6,
    path = '/data/log/',
    print_file = 1,
    print_screen = 1,
    modules = {
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
        'SC_BOSS',
        'SC_CITY_BOSS',
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
    return cjson.encode(log)
end

comlog = {
    level = 3,
    path = '/data/comlog/',
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
    flag = 0,
    interval = 300,
}

function get_perf()
    --print(cjson.encode(perf))
    return cjson.encode(perf)
end

--本地缓存
cache = {
    max = 10000,
}
function get_cache()
    return cjson.encode(cache)
end

--资源文件
res = 
{
lua_path = '/data/app/script/',
repo_path = '/data/app/repo/',
rank_path = '/data/rank/',
bt_record_path = '/data/bt_record/',
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
    ip = '192.168.1.6',
    port='3306',
    user='inter',
    pwd ='#hj$TUDJtp',
    name='God_gmtool',
}
function get_conf_sqldb()
    return cjson.encode(conf_sqldb)
end

--统计数据库
statics_sqldb = {
    ip = '192.168.1.6',
    port='3306',
    user='inter',
    pwd ='#hj$TUDJtp',
    name='God_statics',
}
function get_static_sqldb()
    return cjson.encode(statics_sqldb)
end

--全局据库
global_sqldb = {
    ip = '192.168.1.6',
    port='3306',
    user='inter',
    pwd ='#hj$TUDJtp',
    name='God_global',
}
function get_global_sqldb()
    return cjson.encode(global_sqldb)
end

--游戏数据库表
sqldb_map = {}
sqldb_map['1'] = {
    ip = '192.168.1.6',
    port='3306',
    user='inter',
    pwd ='#hj$TUDJtp',
    name='God_android_1',
}

function get_sqldb()  
    local wrap = {}
    wrap.contain = sqldb_map 
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
scene_map['998'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {998},
}

function get_scene()
    local wrap = {}
    wrap.contain = scene_map
    return cjson.encode(wrap)
end

gateway_map = {}
gateway_map['1'] = {
    listen_ip= '202.133.247.200',
    public_ip = '202.133.247.200',
    public_port = tostring(port_info.gw.out+1),
    private_ip = '192.168.1.15',
    private_port = tostring(port_info.gw.inner+1),
    thread_num = 4,
}

function get_gateway()
    local wrap = {}
    wrap.contain = gateway_map 
    return cjson.encode(wrap)
end

route = {}
route.listen_ip= '202.133.247.200'
route.public_ip = '202.133.247.200'
route.private_port = tostring(port_info.route.inner)
route.private_ip = '192.168.1.15'
route.public_port = tostring(port_info.route.out)
route.thread_num = 10

function get_route()
    return cjson.encode(route)
end

invcode = {}
invcode.ip = '192.168.1.15'
invcode.port = tostring(port_info.inv.inner)
invcode.thread_num = 1
invcode.sqldb = {id = '1', conn_num = 1,}

function get_invcode()
    local wrap = {}
    return cjson.encode(invcode)
end

gslist = 
{
    { hostnum = 1, name = '1区', serid = 1, recom=true},
    { hostnum = 998, name = '998区-外网测试', serid = 998, recom=true},
} 

function get_gslist()
    local wrap = {}
    wrap.contain = gslist 
    return cjson.encode(wrap)
end
