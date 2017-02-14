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
    path = '/data/logs/online/',
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
        'SC_CARD_EVENT',
        'SC_RANK_MATCH',
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
        "SC_RANK",
        "SC_LV_RANK",
        "SC_CARD_RANK",
        "SC_CARD_EVENT",
        "SC_UNION_CARD_RANK",
        "SC_SHOP",
        "SC_CARD_COMMENT",
        "SC_SOULRANK",
        "SC_GUILD_BATTLE",
        "SC_USER",

    }
}

function get_log()
    --print(cjson.encode(log))
    return cjson.encode(log)
end

comlog = {
    level = 3,
    path = '/data/logs/comlog/',
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
    name='niceserver2',
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
    name='niceserver_online',
}
sqldb_map['2'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceserver_online_2',
}
sqldb_map['3'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceserver_online_3',
}

sqldb_map['4'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceserver_online_4',
}

sqldb_map['5'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceserver_online_5',
}

sqldb_map['51'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceserver_online_yyb',
}


sqldb_map['52'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceshot_jp',
}

sqldb_map['53'] = {
    ip = '10.66.109.182',
    port='3306',
    user='root',
    pwd ='13683048948o',
    name='niceshot_jp',
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

for i=101, 345 do
    if i%10 <= 5 and i%10 > 0 then
        if i >= 101 and i<=145 then
            scene_map[tostring(i)] = {
                sqldb ={
                    id = '1',
                    conn_num = 4,
                },
                thread_num = 1,
                contain_host = {i},
            }
        elseif i > 145 and i < 201 then
            scene_map[tostring(i)] = {
                sqldb ={
                    id = '2',
                    conn_num = 4,
                },
                thread_num = 1,
                contain_host = {i},
            }
        elseif i >= 201 and i <= 245 then
            scene_map[tostring(i)] = {
                sqldb ={
                    id = '3',
                    conn_num = 4,
                },
                thread_num = 1,
                contain_host = {i},
            }
        elseif i >= 251 and i <= 295 then
            scene_map[tostring(i)] = {
                sqldb ={
                    id = '4',
                    conn_num = 4,
                },
                thread_num = 1,
                contain_host = {i},
            }
        elseif i >= 301 and i <= 345 then
            scene_map[tostring(i)] = {
                sqldb ={
                    id = '5',
                    conn_num = 4,
                },
                thread_num = 1,
                contain_host = {i},
            }
        end
    end
end
-- 102-105合服
scene_map['102'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {102,103,104,105},
}
scene_map['111'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {111,112,113,114,115},
}
scene_map['121'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {121,122,123,124,125},
}
scene_map['131'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {131,132,133,134,135},
}
scene_map['151'] = {
    sqldb ={
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {151,152,153,154,155},
}
scene_map['141'] = {
    sqldb ={
        id = '1',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {141,142,143,144,145},
}

scene_map['161'] = {
    sqldb ={
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {161,162,163,164,165},
}

scene_map['171'] = {
    sqldb ={
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {171,172,173,174,175},
} 

scene_map['181'] = {
    sqldb ={
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {181,182,183,184,185},
} 

scene_map['191'] = {
    sqldb ={
        id = '2',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {191,192,193,194,195},
}

scene_map['211'] = {
    sqldb ={
        id = '3',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {211,212,213,214,215},
}


scene_map['82'] = {
    sqldb ={
        id = '51',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {82},
}

scene_map['2'] = {
    sqldb ={
        id = '52',
        conn_num = 4,
    },
    thread_num = 1,
    contain_host = {2},
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
    private_ip = '10.131.152.110',
    private_port = tostring(port_info.gw.inner+1),
    thread_num = 4,
}
--[[
gateway_map['2'] = {
    listen_ip= '0.0.0.0',
    public_ip = '182.254.147.153',
    public_port = '62101',
    private_ip = '182.254.147.153',
    private_port = '62201',
    thread_num = 4,
}
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
    { hostnum = 1, name = '誓约胜利之剑', serid = 1, recom=true},
    { hostnum = 101, name = '1-墨阳', serid = 101, recom=true},
    { hostnum = 102, name = '2-天丛云', serid = 102, recom=true},
} 

function get_gslist()
    local wrap = {}
    wrap.contain = gslist 
    return cjson.encode(wrap)
end
