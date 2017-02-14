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
		  -I../common/

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64
LDFLAGS  = 

super_LDADD =\
				$(top_srcdir)/yslib/ys_jpack/libys_jpack.la    \
				$(top_srcdir)/yslib/rpc/libys_rpc.la            \
				$(top_srcdir)/yslib/thread_pool/libys_thread_pool.la            \
				$(top_srcdir)/yslib/package/libys_package.la    \
				$(top_srcdir)/yslib/ys_lua/libys_lua.la     	\
				$(top_srcdir)/yslib/perf/libys_perf.la         \
				$(top_srcdir)/yslib/mysql/libys_mysql.la        \
				$(top_srcdir)/yslib/utility/libys_utility.la    \
				$(top_srcdir)/yslib/ys_log/libys_log.la         \
				/usr/local/lib/libboost_system-mt.a\
				/usr/local/lib/libboost_thread-mt.a\
				-ltbb\
				-ltbbmalloc\
				-lpthread\
				-lz\
				-ldl 

bin_PROGRAMS = super 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

super_SOURCES = 		\
		su_service.cpp \
		main.cpp
