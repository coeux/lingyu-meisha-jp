INCLUDES= -I$(top_srcdir)/yslib/ys_log 				\
		  -I$(top_srcdir)/yslib/rpc 				\
		  -I$(top_srcdir)/yslib/mysql 				\
		  -I$(top_srcdir)/yslib/perf 				\
		  -I$(top_srcdir)/yslib/ys_jpack 			\
		  -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4 	\
		  -I$(top_srcdir)/yslib/utility 			\
		  -I$(top_srcdir)/yslib/db_service 			

AM_CPPFLAGS = -Wall -O2  -fPIC -Wno-deprecated -std=c++0x -DDEBUG_LOG -m64 -pipe  

noinst_LIBRARIES = libcommon.a

libcommon_a_SOURCES = \
		config.cpp\
		repo_def.cpp\
		db_def.cpp\
		db_helper.cpp\
		msg_dispatcher.cpp	
