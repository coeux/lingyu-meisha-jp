#ifndef _afl_h_
#define _afl_h_

#include "jserialize_macro.h"
#include "singleton.h"
#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "ys_lua.h"
#include "ticker.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "remote_info.h"
#include "repo_def.h"
#include "db_service.h"
#include "rpc.h"
#include "rpc_client.h"
#include "rpc_server.h"
#include "concurrent_hash_map.h"

#include "repo.h"
#include "repo_def.h"
#include "db_def.h"
#include "config.h"
#include "db_helper.h"
#include "code_def.h"
#include "msg_def.h"
#include "msg_dispatcher.h"
#include "service_base.h"
#include "remote_info.h"

#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <list>
#include <deque>
#include <string>
#include <sstream>
#include <ext/hash_map>
using namespace __gnu_cxx;
using namespace std;

#include <boost/shared_ptr.hpp>
#include <boost/function.hpp>
#include <boost/any.hpp>
#include <boost/array.hpp>
#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>

#include <assert.h>

#endif
