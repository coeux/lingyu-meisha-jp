
#ifndef _LOG_H_
#define _LOG_H_

#include <string>
#include <vector>
using namespace std;

#include "singleton.h"
#include "log_impl.h"
#include "com_log.h"

#ifdef HAVE_CONFIG_H
#include "conf.h"
#endif

#define ENABLE_LOG_FATAL
#define ENABLE_LOG_ERROR

#ifdef DEBUG_LOG 
#define ENABLE_LOG_WARN
#define ENABLE_LOG_INFO
#define ENABLE_LOG_TRACE
#define ENABLE_LOG_DEBUG
#endif

#ifdef ENABLE_LOG_FATAL
#define logfatal(x) singleton_t<log_t>::instance()._logfatal x
#else
#define logfatal(x) {}
#endif

#ifdef ENABLE_LOG_ERROR
#define logerror(x) singleton_t<log_t>::instance()._logerror x
#else
#define logerror(x) {}
#endif

#ifdef ENABLE_LOG_WARN
#define logwarn(x) singleton_t<log_t>::instance()._logwarn x
#else
#define logwarn(x) {}
#endif

#ifdef ENABLE_LOG_INFO
#define loginfo(x) singleton_t<log_t>::instance()._loginfo x
#else
#define loginfo(x) {}
#endif

#ifdef ENABLE_LOG_TRACE
#define logtrace(x) singleton_t<log_t>::instance()._logtrace x
#else
#define logtrace(x) {}
#endif

#ifdef ENABLE_LOG_DEBUG
#define logdebug(x) singleton_t<log_t>::instance()._logdebug x
#else
#define logdebug(x) {}
#endif


int init_log(const std::string& path,
			 const std::string& file,
			 const int	flag_print_file,
			 const int	flag_print_screen,
			 const int  flag_log_level,
			 const std::vector<std::string>& modules,
			 const int  max_line = 100000,
			 const int  maz_size = 5000000);

int init_log(const std::string& path,
			 const std::string& file,
			 const int	flag_print_file,
			 const int	flag_print_screen,
			 const int  flag_log_level,
			 const std::string& modules,
			 const int  max_line = 100000,
			 const int  maz_size = 5000000);

void log_screen_open(bool isok_);

void close_log();
#endif //_LOG_H_
