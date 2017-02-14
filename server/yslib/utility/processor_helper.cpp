
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <pwd.h>

#include <string>
#include <iostream>
using namespace std;

#include "processor_helper.h"

void processor_helper_t::daemonize()
{
	daemonize(NULL);
}

//! daemonize the current process
void processor_helper_t::daemonize(const char* uname_)
{
	pid_t pid, sid;

	if ((pid = fork()) < 0)
    {
		cerr<<"processor_helper_t::daemonize fork failed:"<<strerror(errno)<<endl;
		exit(EXIT_FAILURE);
	}
	else if(pid != 0)
    {
	   exit(EXIT_SUCCESS);
    }

	/* change work dir to parent */
	char cwd_path[1024];
	if(processor_helper_t::get_parent_cwd(cwd_path, sizeof(cwd_path)) == false)
	{
		cout<<"processor_helper_t::get_parent_cwd failed:"<<strerror(errno)<<endl;
		exit(EXIT_FAILURE);
	}
	if(chdir(cwd_path) == -1)
	{
		cout<<"chdir failed:"<<strerror(errno)<<endl;
		exit(EXIT_FAILURE);
	}

	/* change privilige */
	if(uname_ != NULL)
	{
		int uid = processor_helper_t::get_uid(uname_);
		if(uid == -1)
		{
			cout<<"processor_helper_t::get_uid failed:"<<strerror(errno)<<endl;
			exit(EXIT_FAILURE);
		}
		if(setuid(uid) == -1)
		{
			cout<<"setuid failed:"<<strerror(errno)<<endl;
			exit(EXIT_FAILURE);
		}
	}

	/* set a new session id*/
	sid = setsid();
	if (sid < 0)
    {
		cout<<"processor_helper_t::daemonize setsid failed:"<<strerror(errno)<<endl;
		exit (EXIT_FAILURE);
	}

	/* ensure all files created by itself are accessible */
	umask (022);

    /*close all descriptors */
    for (int i = getdtablesize() - 1; i >= 0; --i)
    {
        (void)close(i);
    }
    //! dup the base io
    int fd_dev = open("/dev/null", O_RDWR);
    (void)dup(fd_dev);
    (void)dup(fd_dev);
}

int processor_helper_t::get_uid(const char* uname_)
{
	struct passwd *user = NULL;
	user = getpwnam(uname_);
	if(user == NULL)
	{
		return -1;
	}
	return user->pw_uid;
}

bool processor_helper_t::get_parent_cwd(char* path_, const size_t max_size_)
{
	ssize_t size = readlink("/proc/self/exe", path_, max_size_);
	if(size <= 0 || static_cast<size_t>(size) >= max_size_)
	{
		return false;
	}

	const char* last_slash = strrchr(path_, '/');
	if(last_slash != path_)
	{
		// end str at last_slash position
		path_[last_slash - path_] = '\0';

		last_slash = strrchr(path_, '/');
		if(last_slash != path_)
		{
			// end str at last_slash position
			path_[last_slash - path_] = '\0';
		}
		else
		{
			path_[1] = '\0';
		}
	}
	else
	{
		path_[1] = '\0';
	}

	return true;
}

bool processor_helper_t::log_pid(const char* path_)
{
	return true;
}
