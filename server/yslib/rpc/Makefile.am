INCLUDES=-I../ys_log -I../heart_beat -I../utility -I../perf -I../package/ -I../thread_pool/

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -DUSE_TBB_MALLOC -DUSE_PERF

noinst_LIBRARIES = libys_rpc.a
libys_rpc_a_LIBFLAGS =
libys_rpc_a_LIBADD =

libys_rpc_a_SOURCES = \
					   rpc_acceptor.cpp     			\
					   rpc_connecter.cpp  				\
					   rpc_common_conn_protocol.cpp  	\
					   rpc_conn_monitor.cpp 			\
					   rpc.cpp 						    \
					   rpc_utility.cpp 					\
					   rpc_bin.cpp 						
