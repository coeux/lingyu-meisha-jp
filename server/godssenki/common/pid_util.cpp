#include "pid_util.h"
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/syscall.h>

#define gettid() syscall(SYS_gettid)

int pid_util_t::save(const char* path_)
{
    FILE* file = fopen(path_, "rt");
    if (file == NULL)
        return -1;
    fprintf(file, "%d", gettid());
    fclose(file);
    return 0;
}
int pid_util_t::remove(const char* path_)
{
    return remove(path_);
}
