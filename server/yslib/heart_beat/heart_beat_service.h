/*************************************************
* copyright:    copyright @ 2010 fminutes.com
* file name:    heart_beat_service.h
* file impl:    N/A
* description:  the heart beat service object provides element heart beat server and includes:
*       1. sets the timed out callback function
*       2. sets the timed out flag and seconds for loop checking
*       3. start/stop the service of heart beat
*       4. asynchronously sets the special element
*       5. asynchronously deletes the special element
* author:    congjun.chang@fminutes.com 2010.05.04 create the file
*************************************************/

#ifndef _HEART_BEAT_SERVICE_H_
#define _HEART_BEAT_SERVICE_H_

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <boost/scoped_ptr.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

#include "heart_beat_log_def.h"
#include "heart_beat_element_mgr.h"

//! defines the heart beat loop checking tick seconds, you can use compile option to define it
#ifndef HEART_BEAT_TICKS
#define HEART_BEAT_TICKS 10
#endif

//!  description:  the heart beat service object
//!  thread safe:  unsafe
//!  Usage:     heart_beat_service_t<element_type, element_hash> heart_beat_service();
//!             heart_beat_service.set_callback_function(callback_function);
//!             heart_beat_service.set_timedout(true, 25);
//!             heart_beat_service.set_max_limit(true, 3000000);
//!             heart_beat_service.start();
//!             heart_beat_service.async_add_element(element_type&);
template<typename element_type, typename element_hash = __gnu_cxx::hash<element_type> >
class heart_beat_service_t : private boost::noncopyable
{
public:
    //! the callback function define for element_type
    typedef boost::function<void(element_type&)> callback_function_type;

public:
    //!  heart_beat_service_t: constructor
    heart_beat_service_t();

    //!  heart_beat_service_t: destructor
    ~heart_beat_service_t();

    //!  set_callback_function: sets the timed out callback function
    //!  @in   callback_function_type: boost function object
    //!  @result: int
    int set_callback_function(callback_function_type callback_function);

    //!  set_timeout: sets the timed out flag and seconds for element ticks
    //!  @in   bool: timed out flag
    //!  @in   unsigned int: timed out seconds
    //!  @result: int
    int set_timeout(bool timeout_flag, unsigned int timedout);

    //!  set_max_limit: sets the max limit flag and number of element
    //!  @in   bool: element max limit flag
    //!  @in   unsigned long: max limit number
    //!  @result: int
    int set_max_limit(bool max_limit_flag, unsigned long max_limit);

    //!  start: start the service of heart beat
    //!  @result: int
    int start();

    //!  stop: stop the service of heart beat
    //!  @result: int
    int stop();

    //!  async_set_element: asynchronously sets the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: void
    void async_add_element(element_type& element);

    //!  async_set_element: asynchronously updates the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: void
    void async_update_element(element_type& element);

    //!  async_del_element: asynchronously deletes the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: void
    void async_del_element(element_type& element);

    void get_all_element_and_clear(vector<element_type>* element_vt);

    void trigger_all_timeout();
private:
    //!  stop_service: clear all element and stop the service
    //!  @result: int
    int stop_service();

    //!  handle_timeout: handles all element when timer is timedout
    //!  @in   boost::system::error_code&: async wait error info
    //!  @result: int
    int handle_timeout(const boost::system::error_code& error);

    //!  add_element: adds the special element
    //!  @in   element_type&: setted element reference
    //!  @result: int
    int add_element(element_type& element);

    //!  update_element: updates the special element
    //!  @in   element_type&: setted element reference
    //!  @result: int
    int update_element(element_type& element);

    //!  del_element: deletes the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: int
    int del_element(element_type& element);

    int get_all_element_and_clear_i(vector<element_type>* element_vt);
    void trigger_all_timeout_i();
private:
    //! identify whether service is running
    bool m_started;

    //! io service object of boost for deadline time and thread working
    boost::asio::io_service m_io_service;

    //! io service work object of boost for keeping io service is running
    boost::asio::io_service::work m_io_work;

    //! the service thread of heart beat service
    boost::scoped_ptr<boost::thread> m_thread;

    //! the timer for loop checking timedout task
    boost::asio::deadline_timer m_timer;

    //! mananges all element operation
    heart_beat_element_mgr_t<element_type, element_hash> m_element_manager;

    volatile bool m_get_element_flag;
};

template<typename element_type, typename element_hash>
heart_beat_service_t<element_type, element_hash>::heart_beat_service_t()
    : m_started(false), m_io_work(m_io_service), m_timer(m_io_service)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::heart_beat_service_t ..."));
}

template<typename element_type, typename element_hash>
heart_beat_service_t<element_type, element_hash>::~heart_beat_service_t()
{
    logtrace((HEART_BEAT, "heart_beat_service_t::~heart_beat_service_t begin ..."));
    stop();
    logtrace((HEART_BEAT, "heart_beat_service_t::~heart_beat_service_t end ok."));
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::set_callback_function(callback_function_type callback_function)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::set_callback_function begin ..."));
    if (m_started)
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::set_callback_function "
          "Heart beat service has been started and cannot set callback function again"));

        return -1;
    }

    if (m_element_manager.set_callback_function(callback_function))
    {
        logerror((HEART_BEAT, "heart_beat_service_t::set_callback_function "
          "Failed to set callback function of element."));

        return -1;
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::set_callback_function end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::set_timeout(bool timeout_flag, unsigned int timedout)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::set_timedout begin ..."));
    if (m_started)
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::set_timeout "
          "Heart beat service has been started and cannot set timeout again."));

        return -1;
    }

    if (m_element_manager.set_timeout(timeout_flag, timedout))
    {
        logerror((HEART_BEAT, "heart_beat_service_t::set_timeout "
          "Failed to set timeout flag and seconds of element."));

        return -1;
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::set_timeout end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::set_max_limit(bool max_limit_flag, unsigned long max_limit)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::set_max_limit begin ..."));

    if (m_started)
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::set_max_limit "
          "Heart beat service has been started and cannot set max limit of element agagin."));

        return -1;
    }

    if (m_element_manager.set_max_limit(max_limit_flag, max_limit))
    {
        logerror((HEART_BEAT, "heart_beat_service_t::set_max_limit "
          "Failed to set max limit flag and number of element."));

        return -1;
    }

    logtrace((HEART_BEAT, "heart_beat_service_t::set_max_limit end ok ..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::start()
{
    logtrace((HEART_BEAT, "heart_beat_service_t::start begin ..."));

    if (m_started)
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::start "
          "Heart beat service is already started."));

        return 0;
    }

    m_timer.expires_from_now(boost::posix_time::seconds(HEART_BEAT_TICKS));
    m_timer.async_wait(
        boost::bind(&heart_beat_service_t<element_type, element_hash>::handle_timeout,
          this, boost::asio::placeholders::error));

    m_thread.reset(new boost::thread(boost::bind(&boost::asio::io_service::run, &m_io_service)));
    m_started = true;

    logtrace((HEART_BEAT, "heart_beat_service_t::start end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::stop()
{
    logtrace((HEART_BEAT, "heart_beat_service_t::stop begin ..."));
    if (!m_started)
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::stop "
          "Heart beat service is already stoped."));

        return 0;
    }

    //! clear up all existed element and stop the io service
    m_io_service.post(boost::bind(&heart_beat_service_t::stop_service, this));
    m_thread->join();

    m_started = false;
    logtrace((HEART_BEAT, "heart_beat_service_t::stop end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::stop_service()
{
    logtrace((HEART_BEAT, "heart_beat_service_t::stop_service begin ..."));
    m_element_manager.clear_element();
    m_io_service.stop();
    logtrace((HEART_BEAT, "heart_beat_service_t::stop_service end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::async_add_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::async_add_element begin..."));
    m_io_service.post(boost::bind(&heart_beat_service_t<element_type, element_hash>::add_element, this, element));
    logtrace((HEART_BEAT, "heart_beat_service_t::async_add_element end ok."));
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::async_update_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::async_update_element begin..."));
    m_io_service.post(boost::bind(&heart_beat_service_t<element_type, element_hash>::update_element, this, element));
    logtrace((HEART_BEAT, "heart_beat_service_t::async_update_element end ok."));
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::async_del_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::async_del_element begin..."));
    m_io_service.post(boost::bind(&heart_beat_service_t<element_type, element_hash>::del_element, this, element));
    logtrace((HEART_BEAT, "heart_beat_service_t::async_del_element end ok."));
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::handle_timeout(const boost::system::error_code& error)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::handle_timeout() begin..."));
    if (error)
    {
        logfatal((HEART_BEAT, "heart_beat_service_t::handle_timeout "
          "Failed to async wait of timer and stop the heart beat service"));
    }

    m_timer.expires_at(m_timer.expires_at() + boost::posix_time::seconds(HEART_BEAT_TICKS));
    m_timer.async_wait(
      boost::bind(&heart_beat_service_t<element_type, element_hash>::handle_timeout,
        this, boost::asio::placeholders::error));

    if (m_element_manager.handle_timeout())
    {
        logerror((HEART_BEAT, "heart_beat_service_t::handle_timeout "
          "Failed to invoke handle element at element manager."));

        return -1;
    }

    logtrace((HEART_BEAT, "heart_beat_service_t::handle_timeout() end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::add_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::add_element begin ..."));
    if (m_element_manager.add_element(element))
    {
        logerror((HEART_BEAT, "heart_beat_service_t::add_element "
          "Failed to invoke add element at element manager."));

        return -1;
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::add_element end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::update_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::update_element begin ..."));
    if (m_element_manager.update_element(element))
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::update_element "
          "Failed to invoke update element at element manager."));

        return -1;
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::update_element end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::del_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::del_element begin ..."));
    if (m_element_manager.del_element(element))
    {
        logwarn((HEART_BEAT, "heart_beat_service_t::del_element "
          "Failed to invoke delete element at element manager."));

        return -1;
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::del_element end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::get_all_element_and_clear(vector<element_type>* element_vt)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::get_all_element_and_clear begin ..."));
    m_get_element_flag = false;
    m_io_service.post(boost::bind(&heart_beat_service_t<element_type, element_hash>::get_all_element_and_clear_i,
                                  this,
                                  element_vt));
    for (;;)
    {
        if (m_get_element_flag == true)
        {
            break;
        }
    }
    logtrace((HEART_BEAT, "heart_beat_service_t::get_all_element_and_clear end ok."));
}


template<typename element_type, typename element_hash>
int heart_beat_service_t<element_type, element_hash>::get_all_element_and_clear_i(vector<element_type>* element_vt)
{
    logtrace((HEART_BEAT, "heart_beat_service_t::get_all_element_and_clear_i begin ..."));
    m_element_manager.get_all_element_and_clear(element_vt);
    m_get_element_flag = true;
    logtrace((HEART_BEAT, "heart_beat_service_t::get_all_element_and_clear_i end ok."));
    return 0;
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::trigger_all_timeout()
{
    m_io_service.post(boost::bind(&heart_beat_service_t<element_type, element_hash>::trigger_all_timeout_i, this));
}

template<typename element_type, typename element_hash>
void heart_beat_service_t<element_type, element_hash>::trigger_all_timeout_i()
{
    logtrace((HEART_BEAT, "heart_beat_service_t::trigger_all_timeout_i begin ..."));
    m_element_manager.trigger_all_timeout();
    logtrace((HEART_BEAT, "heart_beat_service_t::trigger_all_timeout_i end ok."));
}

#endif //! _HEART_BEAT_SERVICE_H_
