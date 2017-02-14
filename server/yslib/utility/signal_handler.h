
#ifndef _SIGNAL_HANDLER_H_
#define _SIGNAL_HANDLER_H_

#include <signal.h>

#include <map>
using namespace std;

#include <boost/function.hpp>

/*! @ingroup    LIB
 *  @class      signal_handler_t
 *  @brief      the signal handler for handle all register signal
 */
class signal_handler_t
{
public:

    //! signal callback function
    typedef boost::function<void()>                         signal_callback_func_t;
    //! signal and callback function map table
    typedef map<unsigned int, signal_callback_func_t>       m_signal_func_map_t;

public:

    /*! @fn         signal_handler_t();
     *  @brief      constructor
     */
    signal_handler_t();

   /*! @fn         ~signal_handler_t();
     *  @brief      destructor
     */
    ~signal_handler_t();

    /*! @fn         int block_all_signal();
     *  @brief      block all signal for all thread
     *  @return     int
     */
    int block_all_signal();

    /*! @fn         int register_quit_signal(unsigned int signal_num_);
     *  @brief      register signal event loop quit signal number
     *              if receives this signal, break out this event loop
     *  @param      unsigned int signal_num_: signal number eg: SIGINT/SIGQUIT/SIGTERM/SIGHUP
     *  @return     int
     */
    int register_quit_signal(unsigned int signal_num_);

    /*! @fn         int register_signal(unsigned int signal_num_, signal_callback_func_t signal_callback_func_);
     *  @brief      register signal and signal handler to event loop
     *              if receive this signal, invokes refered handler
     *  @param      unsigned int signal_num_: signal number eg: SIGUSR1/SIGUSR2
     *  @return     int
     */
    int register_signal(unsigned int signal_num_, signal_callback_func_t signal_callback_func_);

    /*! @fn         int event_loop();
     *  @brief      event loop and waiting for signal
     *  @return     int
     */
    int event_loop();
    /*! @fn         void set_terminate();
     *  @brief      set terminate flag
     *  @return     void 
     */
    void set_terminate(uint32_t pid_=0);

private:

    sigset_t                        m_wait_mask;            //! wait masked signal
    m_signal_func_map_t             m_signal_func_map;
    bool                            m_isquit;
};

#endif //! _SIGNAL_HANDLER_H_

