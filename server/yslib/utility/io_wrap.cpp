#include "io_wrap.h"
#include "io_service_pool.h"

#include <stdexcept>
#include <assert.h>
using namespace std;

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/syscall.h>
#define gettid() syscall(SYS_gettid)

#include "log.h"

io_wrap_t::io_wrap_t(const char* name_):m_name(name_),m_io(io_pool.get_io_service())
{
    logtrace(("IO_WRAP", "%s create ok!", m_name.c_str()));
}
io_wrap_t::~io_wrap_t()
{
    logtrace(("IO_WRAP","%s release ok!", m_name.c_str()));
}
