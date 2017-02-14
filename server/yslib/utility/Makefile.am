INCLUDES= -I../ys_log/

#CXXFLAGS = -Wall -g -O2 -fPIC
AM_CPPFLAGS = -Wall -O2  -fPIC -Wno-deprecated -std=c++0x -DUSE_TBB_MALLOC

noinst_LIBRARIES = libys_utility.a

libys_utility_a_SOURCES = \
		io_wrap.cpp\
		rsa.cpp\
		rsa_pem.cpp\
		local_cache.cpp\
		processor_helper.cpp \
		signal_handler.cpp \
		md5.cpp \
		id_info.cpp \
		zlib_util.cpp \
		io_service_pool.cpp \
		base64.cpp \
		hmac_sha1_base64.cpp \
		http_curl.cpp \
		url_algorithm.cpp \
		crc32.cpp \
		random.cpp \
		xml_util.cpp\
		crypto.cpp\
		date_helper.cpp\
		file_monitor.cpp\
		frame_xtea.cpp
