#ifndef _SIGNAL_SERVICE_H_
#define _SIGNAL_SERVICE_H_

#include "singleton.h"
#include "signal_handler.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/syscall.h>

class signal_service_t
{
    uint32_t m_pid;
    bool m_is_terminated;
    signal_handler_t m_handler;
public:
    void start()
    {
        m_pid = syscall(SYS_gettid);
        m_is_terminated = false;
        m_handler.register_quit_signal(SIGINT);
        m_handler.register_quit_signal(SIGQUIT);
        m_handler.register_quit_signal(SIGTERM);
        m_handler.register_quit_signal(SIGHUP);
        m_handler.event_loop();
    }

    void start(vector<uint16_t> quit_signals_)
    {
        m_is_terminated = false;
        for(size_t i=0; i<quit_signals_.size(); i++)
            m_handler.register_quit_signal(quit_signals_[i]);
        m_handler.event_loop();
    }

    void terminate()
    {
        m_is_terminated = true;
        m_handler.set_terminate(m_pid);
    }

    bool is_terminate() { return m_is_terminated; }

    signal_handler_t& get_handler() { return m_handler; }
};

#define signal_service (singleton_t<signal_service_t>::instance())

#endif
