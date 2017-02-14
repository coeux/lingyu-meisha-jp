log = {
    level = 6,
    path = '/home/dskong/log/',
    print_file = 1,
    print_screen = 1,
    modules = {
        '91LOGIN',
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
    path = '/home/dskong/comlog/',
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

--资源文件
res = 
{
lua_path = './script/',
repo_path = './repo/',
}

function get_res()
    return cjson.encode(res)
end

--游戏地图大小
mapsize = 
{
    lt = {x=-724, y=-240}, 
    rb = {x= 724, y=-50 },
}

function get_mapsize()
    return cjson.encode(mapsize)
end

--统计数据库
statics_sqldb = {
    ip = '192.168.4.240',
    port='3307',
    user='inter',
    pwd ='helloworld',
    name='91Statics',
}
function get_static_sqldb()
    return cjson.encode(statics_sqldb)
end

--游戏数据库表
sqldb_map = {}
sqldb_map['1'] = {
    ip = '192.168.4.240',
    port='3307',
    user='inter',
    pwd ='helloworld',
    name='91Godssenki',
}

function get_sqldb()  
    local wrap = {}
    wrap.contain = sqldb_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

invcode_map = {}
invcode_map['1'] = {
    ip = '192.168.4.240',
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

platform_map = {}
platform_map['1'] = {
    ip = '192.168.4.240',
    port = '30001',
    thread_num = 1,
    sqldb ={
        id = '1',
        conn_num = 1,
    },
}

function get_platform()
    local wrap = {}
    wrap.contain = platform_map 
    --print(cjson.encode(wrap))
    return cjson.encode(wrap)
end

dbmid_map = {}
dbmid_map['1'] = {
    ip = '127.0.0.1',
    port = '15001',
    thread_num = 4,
    sqldb = {
        id = '1',
        conn_num = 1,
    },
}

function get_dbmid()  
    local wrap = {}
    wrap.contain = dbmid_map
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
    public_ip = '192.168.4.240',
    public_port = '13001',
    private_ip = '192.168.4.240',
    private_port = '23001',
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
route.private_ip = '127.0.0.1'
route.private_port = '51000'
route.public_ip = '192.168.4.240'
route.public_port = '51001'
route.thread_num = 10

function get_route()
    return cjson.encode(route)
end

gslist = 
{
    { hostnum = 1, name = '测试1服', serid = 1},
}

recom_gslist = 
{
    { hostnum = 100, name = '火爆100服', serid = 100},
    { hostnum = 101, name = '火爆101服', serid = 101},
    { hostnum = 103, name = '火爆103服', serid = 103},
}

function get_gslist()
    local wrap = {}
    wrap.contain = gslist 
    return cjson.encode(wrap)
end

function get_recom_gslist()
    local wrap = {}
    wrap.contain = recom_gslist 
    return cjson.encode(wrap)
end

--新角色resid范围
newuser_role_resid_range = 
{
    b = 1001, 
    e = 1006,
}

function get_resid_range()
    return cjson.encode(newuser_role_resid_range)
end

--平台APP信息
appinfo =
{
    domain = '91',
    --内部连接
    url = 'http://192.168.4.240/91test/AP.php',
    --正式连接
    --url = 'http://service.sj.91.com/usercenter/AP.aspx',
    --测试连接
    --url= 'http://mobileusercenter.sj.91.com/usercenter1/Default.aspx',
    appkey = 'cb4609b7d46c04d6a03cd7577754939daf32c51bbb55837c',
    appid = '110580',
    timeout = 100,
}
function get_appinfo()
    return cjson.encode(appinfo)
end
