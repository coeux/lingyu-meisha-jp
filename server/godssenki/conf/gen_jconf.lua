cjson = require 'cjson'
dofile(arg[1])

config = {}
config.log = log
config.comlog = comlog
config.heart_beat = heart_beat
config.perf = perf
config.local_cache = cache
config.res = res
config.statics_sqldb = statics_sqldb
config.sqldb_map = {contain = sqldb_map }
config.scene_map = {contain = scene_map }
config.gateway_map = {contain = gateway_map}
config.login_map = {contain = login_map}
config.invcode_map = {contain = invcode_map}
config.route = route
config.gslist= {contain = gslist}

local file = io.open(arg[2], "wb")
file:write(cjson.encode(config))
file:close()
