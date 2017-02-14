#include "file_monitor.h"

#include <unistd.h>
#include <sys/inotify.h>
#include <errno.h>

#define LOG "FILE_MONITER"

file_monitor_t::file_monitor_t(io_t& io_):m_io(io_),m_started(false)
{
}
file_monitor_t::~file_monitor_t()
{
    close();
}
int file_monitor_t::init()
{
    m_fd = inotify_init1(IN_NONBLOCK|IN_CLOEXEC);
    if (m_fd < 0)
    {
        return -1;
    }
    return 0;
}
int file_monitor_t::add_watch_file(const string& path_)
{
    int wd = inotify_add_watch(m_fd, path_.c_str(), IN_CLOSE_WRITE|IN_IGNORED);
    if (wd < 0) {
        return -1;
    }
    m_watch_files[wd] = path_;
    return 0;
}
void file_monitor_t::start()
{
    if (m_started)
        return;

    m_started = true;
    m_timer.reset(new boost::asio::deadline_timer(m_io));
    start_timer();
}
void file_monitor_t::close()
{
    if (!m_started)
        return;

    m_started = false;
    m_timer->cancel();

    for(auto it=m_watch_files.begin(); it!=m_watch_files.end(); it++)
    {
        inotify_rm_watch(m_fd, it->first);
    }
    m_watch_files.clear();
}
const char * event_array[] = {
    "File was accessed",
    "File was modified",
    "File attributes were changed",
    "writtable file closed",
    "Unwrittable file closed",
    "File was opened",
    "File was moved from X",
    "File was moved to Y",
    "Subfile was created",
    "Subfile was deleted",
    "Self was deleted",
    "Self was moved",
    "",
    "Backing fs was unmounted",
    "Event queued overflowed",
    "File was ignored"
};
#define EVENT_NUM 16
void file_monitor_t::update(const boost::system::error_code& error_)
{
    if (!m_started)
        return;

    const static int MAX_BUF_SIZE=1024*10;
    char buffer[MAX_BUF_SIZE];

    char* offset = NULL;
    int len, tmp_len;

    inotify_event* event = NULL;
    len = read(m_fd, buffer, MAX_BUF_SIZE);
    //printf("file_monitor_t::update, len:%d", len);
    if (len>0)
    {
        offset = buffer;
        event = (inotify_event *)buffer;
        while (((char *)event - buffer) < len) {
            /*
            printf("%08X\n", event->mask);
            for (int i=0; i<EVENT_NUM; i++) {
                if (event_array[i][0] == '\0') continue;
                if (event->mask & (1<<i)) {
                    printf("Event: %s, File:%s\n", event_array[i], event->name);
                }
            }
            */
            if (event->mask & IN_CLOSE_WRITE) {
                auto it = m_watch_files.find(event->wd);
                if (it != m_watch_files.end())
                    cb_file_modified(it->second);
            }
            else if (event->mask & IN_IGNORED)
            {
                auto it = m_watch_files.find(event->wd);
                if (it != m_watch_files.end())
                    add_watch_file(it->second);
            }

            tmp_len = sizeof(struct inotify_event) + event->len;
            event = (struct inotify_event *)(offset + tmp_len); 
            offset += tmp_len;
        }
    }

    start_timer();
}
void file_monitor_t::start_timer()
{
    if (!m_started)
        return;
    m_timer->expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(1));
    m_timer->async_wait(boost::bind(&file_monitor_t::update, this, boost::asio::placeholders::error));
}
