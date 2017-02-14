
#ifndef _PROCESSOR_HELPER_H_
#define _PROCESSOR_HELPER_H_

#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

class processor_helper_t
{
public:
	//! daemonize the current process
	static void daemonize();
	static void daemonize(const char* uname);
	static int get_uid(const char* uname_);
	static bool get_parent_cwd(char* path_, const size_t max_size_);
	static bool log_pid(const char* path_);
};

#endif //! _PROCESSOR_HELPER_H_

