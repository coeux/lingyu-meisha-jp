#!/bin/bash
g++ msg_def.h -I../../yslib/ys_jpack -I../../yslib/utility -Wall -g -O2 -fPIC -std=c++0x -m64 -pipe  -Wno-deprecated 
g++ repo_def.h -I../../yslib/rpc -I../../yslib/ys_jpack -I../../yslib/utility -I../../yslib/ys_log -Wall -g -O2 -fPIC -std=c++0x -m64 -pipe  -Wno-deprecated 
g++ config.h -I../../yslib/rpc -I../../yslib/ys_jpack -I../../yslib/utility -I../../yslib/ys_log -I../../yslib/ys_lua/include -Wall -g -O2 -fPIC -std=c++0x -m64 -pipe  -Wno-deprecated 
g++ db_def.h -I../../yslib/rpc -I../../yslib/ys_jpack -I../../yslib/utility -I../../yslib/ys_log -I../../yslib/mysql/ -I../../yslib/db_service -Wall -g -O2 -fPIC -std=c++0x -m64 -pipe  -Wno-deprecated 
g++ db_ext.h -I../../yslib/rpc -I../../yslib/ys_jpack -I../../yslib/utility -I../../yslib/ys_log -I../../yslib/mysql/ -I../../yslib/db_service -Wall -g -O2 -fPIC -std=c++0x -m64 -pipe  -Wno-deprecated 
