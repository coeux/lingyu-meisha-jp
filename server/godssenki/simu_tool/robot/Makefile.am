INCLUDES= -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4 \
		  -I$(top_srcdir)/yslib/ys_jpack 			\
		  -I$(top_srcdir)/yslib/utility 			

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64 -msse2 -DUSE_TBB_MALLOC
LDFLAGS  =  

robot_LDADD =\
				$(top_srcdir)/yslib/ys_jpack/libys_jpack.a\
				$(top_srcdir)/yslib/ys_lua/libys_lua.a\
				$(top_srcdir)/yslib/utility/libys_utility.a\
				/usr/local/lib/libboost_system-mt.a\
				/usr/local/lib/libboost_thread-mt.a\
				-ltbb\
				-ltbbmalloc\
				-lreadline\
				-lcurl\
				-lcrypto\
				-lpthread\
				-lrt\
				-lz\
				-ldl 

bin_PROGRAMS = robot 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

robot_SOURCES = 	\
		ys_socket.cpp \
		message.cpp \
		decode.cpp\
		main.cpp
