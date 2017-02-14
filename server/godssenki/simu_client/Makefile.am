INCLUDES= -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64 -msse2
LDFLAGS  =  

client_LDADD =\
				$(top_srcdir)/yslib/ys_lua/libys_lua.la     	\
				-lz\
				-ldl 

bin_PROGRAMS = client 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

client_SOURCES = 	\
		ys_socket.cpp\
		main.cpp
