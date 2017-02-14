#include <iostream>

#include "signal_handler.h"

signal_handler_t::signal_handler_t()// : m_terminate(false)
:m_isquit(false)
{
    //! clear up wait mask signal
    sigemptyset(&m_wait_mask);
}

signal_handler_t::~signal_handler_t()
{
    //! Empty
}

int signal_handler_t::block_all_signal()
{
    sigset_t all_mask;
    sigfillset(&all_mask);
    return pthread_sigmask(SIG_BLOCK, &all_mask, NULL);
}

int signal_handler_t::register_quit_signal(unsigned int signal_num_)
{
    sigaddset(&m_wait_mask, signal_num_);
    if (m_signal_func_map.end() != m_signal_func_map.find(signal_num_))
    {
        return -1;
    }

    //! register empty signal handler function
    m_signal_func_map[signal_num_] = signal_callback_func_t();
    return 0;
}

int signal_handler_t::register_signal(unsigned int signal_num_, signal_callback_func_t signal_callback_func_)
{
    sigaddset(&m_wait_mask, signal_num_);
    if (m_signal_func_map.end() != m_signal_func_map.find(signal_num_))
    {
        return -1;
    }

    m_signal_func_map[signal_num_] = signal_callback_func_;
    return 0;
}

int signal_handler_t::event_loop()
{
    pthread_sigmask(SIG_BLOCK, &m_wait_mask, 0);

    int sig_num = 0;
    while (!sigwait(&m_wait_mask, &sig_num))
    {
		/*if(m_terminate)
		{
			std::cout << __PRETTY_FUNCTION__ << " : terminated" << std::endl;
		}*/

        m_signal_func_map_t::iterator it = m_signal_func_map.find(sig_num);
        if (m_signal_func_map.end() != it)
        {
            if (it->second)
            {
                //printf("invokes signal callback function and continue to event loop\n");
                //! invokes signal callback function and continue to event loop
                (it->second)();
            }
            else
            {
                //! receives quit signal break out the event loop
                //printf("receives quit signal break out the event loop\n");
                return 0;
            }
        }
        else
        {
            printf("no singnal callback fun, signal break out the event loop\n");
            return -1;
        }
    }

    return 0;
}

void signal_handler_t::set_terminate(uint32_t pid_)
{
	kill(pid_, SIGQUIT);
}
