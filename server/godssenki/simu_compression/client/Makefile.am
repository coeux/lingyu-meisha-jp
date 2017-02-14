INCLUDES= -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4 \
		  -I$(top_srcdir)/yslib/utility 			

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64 -msse2
LDFLAGS  =  

client_LDADD =\
				$(top_srcdir)/yslib/ys_lua/libys_lua.la     	\
				$(top_srcdir)/yslib/utility/libys_utility.la    \
				/usr/local/lib/libboost_system-mt.a\
				/usr/local/lib/libboost_thread-mt.a\
				-lreadline\
				-lcurl\
				-lcrypto\
				-lpthread\
				-lz\
				-ldl 

bin_PROGRAMS = client 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

client_SOURCES = 	\
		ys_socket.cpp \
		message.cpp \
		main.cpp
