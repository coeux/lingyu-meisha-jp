INCLUDES= -I$(top_srcdir)/yslib/ys_log 				\
		  -I$(top_srcdir)/yslib/mysql 				\
		  -I$(top_srcdir)/yslib/heart_beat 			\
		  -I$(top_srcdir)/yslib/perf 				\
		  -I$(top_srcdir)/yslib/utility 			\
		  -I$(top_srcdir)/yslib/rpc 				\
		  -I$(top_srcdir)/yslib/thread_pool 		\
		  -I$(top_srcdir)/yslib/package 			\
		  -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4 	\
		  -I$(top_srcdir)/yslib/ys_jpack 			\
		  -I$(top_srcdir)/yslib/db_service 			\
		  -I../common/

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64 -Wunused-function -DUSE_TBB_MALLOC -L/usr/lib64/mysql
LDFLAGS  = 

route_LDADD =\
				../common/libcommon.a\
				$(top_srcdir)/yslib/ys_jpack/libys_jpack.a    \
				$(top_srcdir)/yslib/rpc/libys_rpc.a            \
				$(top_srcdir)/yslib/thread_pool/libys_thread_pool.a            \
				$(top_srcdir)/yslib/ys_lua/libys_lua.a     	\
				$(top_srcdir)/yslib/perf/libys_perf.a         \
				$(top_srcdir)/yslib/mysql/libys_mysql.a        \
				$(top_srcdir)/yslib/utility/libys_utility.a    \
				$(top_srcdir)/yslib/ys_log/libys_log.a         \
				$(top_srcdir)/yslib/db_service/libys_db_service.a         \
				$(top_srcdir)/yslib/mysql/libys_mysql.a        \
				/usr/local/lib/libboost_system-mt.a\
				/usr/local/lib/libboost_thread-mt.a\
				-lreadline\
				-lcurl\
				-ltbb\
				-ltbbmalloc\
				-lpthread\
				-lmysqlclient\
				-lrt\
				-lz\
				-ldl 

bin_PROGRAMS = route 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

route_SOURCES = 		\
		rt_private_service.cpp \
		rt_public_service.cpp \
		main.cpp
