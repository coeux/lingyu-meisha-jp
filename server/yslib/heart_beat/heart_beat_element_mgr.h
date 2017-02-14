/*************************************************
* copyright:    copyright @ 2010 fminutes.com
* file name:    element_manager.h
* file impl:    N/A
* description:  the element manager object provides element operation and includes:
*       1. sets the timed out callback function
*       2. checks element from list tail and invoke the callback fucntion if time expired
*       3. adds the special element
*       4. deletes the special element
* author:    congjun.chang@fminutes.com 2010.05.04 create the file
*************************************************/

#ifndef _HEART_BEAT_ELEMENT_MGR_H_
#define _HEART_BEAT_ELEMENT_MGR_H_

#include <ext/hash_map>
using namespace __gnu_cxx;

#include <boost/function.hpp>
#include <boost/pool/object_pool.hpp>

#include <boost/shared_ptr.hpp>
class connection_t;

#include "log.h"
#include "heart_beat_log_def.h"
#include "heart_beat_list.h"

//!  description:  the element data object
template<typename element_type>
struct element_data_t
{
    element_data_t();

    element_data_t(const element_type& in_element);

    element_type element;

    //! the timestamp for timedout checking of element
    time_t time;
};

//!  description:  the elemet manager object
//!  thread safe:  unsafe
//!  Usage:     heart_beat_element_mgr_t<element_type> element_manager();
//!             element_manager.add_element(element_type);
//!             element_manager.del_element(element_type);
template<typename element_type, typename element_hash>
class heart_beat_element_mgr_t : private boost::noncopyable
{
public:
    //! the callback function define for element_type
    typedef boost::function<void(element_type&)> callback_function_type;

    //! the element data info type
    typedef element_data_t<element_type> element_data_type;

    //! double linked list defines for storing busy element
    typedef heart_beat_list_t<element_data_type> list_type;

    //! double linked list node type
    typedef typename heart_beat_list_t<element_data_type>::node_type list_node_type;

    //! defines element and double linked list node pointer hash map
    //! the element type must provides equal operator
    typedef hash_map<element_type, list_node_type*, element_hash> element_map;

    //! the iterator of element hash map
    typedef typename element_map::iterator element_map_iterator;

public:
    //!  heart_beat_element_mgr_t: constructor
    //!  @result: N/A
    heart_beat_element_mgr_t();

    //!  set_callback_function: sets the timed out callback function
    //!  @in   callback_function_type: boost function object
    //!  @result: void
    int set_callback_function(callback_function_type callback_function);

    //!  set_timedout: sets the timed out flag and seconds for element ticks
    //!  @in   bool: timed out flag
    //!  @in   unsigned int: timed out seconds
    //!  @result: int
    int set_timeout(bool timeout_flag, unsigned int timedout);

    //!  set_max_limit: sets the max limit flag and number of element
    //!  @in   bool: element max limit flag
    //!  @in   unsigned long: max limit number
    //!  @result: int
    int set_max_limit(bool max_limit_flag, unsigned long max_limit);

    //!  handle_timeout: handles element from list tail and invoke the callback fucntion if time expired
    //!  @result: int
    int handle_timeout();

    //!  add_element: adds the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: int
    int add_element(element_type& element);

    //!  update_element: updates the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: int
    int update_element(element_type& element);

    //!  del_element: deletes the special element
    //!  @in   element_type&: deleted element reference
    //!  @result: int
    int del_element(element_type& element);

    //!  clear_element: clear all element for element manager when stop the heart beat
    //!  @result: int
    int clear_element();

    int get_all_element_and_clear(vector<element_type>* element_vt);
    void trigger_all_timeout();

private:
    //! element_type and double linked list node hash map
    element_map m_elements;

    //! element_type doule linked list
    list_type m_busy_list;

    //! list node object memory pool
    boost::object_pool<list_node_type> m_node_pool;

    //! the call back function of element
    callback_function_type m_callback_function;

    //! the current element count of list
    unsigned long m_element_count;

    //! the flag indicate whether enable timeout
    bool m_timeout_flag;

    //! the timed out seconds for element beat ticks
    unsigned int m_timeout;

    //! the flag indicate whether enable max limit of element
    bool m_max_limit_flag;

    //! the element max limit num
    unsigned long m_max_limit;
};

template<typename element_type>
element_data_t<element_type>::element_data_t() : element(), time(time(NULL))
{
    logtrace((HEART_BEAT, "element_data_t<element_type>::element_data_t"));
}

template<typename element_type>
element_data_t<element_type>::element_data_t(const element_type& in_element)
  : element(in_element), time(::time(NULL))
{
    logtrace((HEART_BEAT, "element_data_t<element_type>::element_data_t"));
}

template<typename element_type, typename element_hash>
heart_beat_element_mgr_t<element_type, element_hash>::heart_beat_element_mgr_t()
  : m_element_count(0), m_timeout_flag(false), m_timeout(0), m_max_limit_flag(false), m_max_limit(0)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::heart_beat_element_mgr_t"));
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::set_callback_function(callback_function_type callback_function)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_callback_function begin..."));
    m_callback_function = callback_function;
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_callback_function end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::set_timeout(bool timeout_flag, unsigned int timeout)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_timedout begin..."));
    m_timeout_flag = timeout_flag;
    m_timeout = timeout;
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_timedout end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::set_max_limit(bool max_limit_flag, unsigned long max_limit)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_max_limit begin..."));
    m_max_limit_flag = max_limit_flag;
    m_max_limit = max_limit;
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::set_max_limit end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::handle_timeout()
{
    //logtrace((HEART_BEAT, "heart_beat_element_mgr_t::handle_timeout() begin..."));

    if (m_timeout_flag)  //! if timeout flag is false, all element will never be deleted
    {
        time_t currect_time = time(NULL);
        list_node_type* node = NULL;
        unsigned int timeout = m_timeout;

        while ((node = m_busy_list.back()))
        {
            if (currect_time >= (node->data.time + timeout))
            {
                if (!m_callback_function)
                {
                    logwarn((HEART_BEAT, "heart_beat_element_mgr_t::handle_timeout "
                      "The element callback function is empty."));
                }
                else
                {
                    m_callback_function(node->data.element);
                }

                if (!(m_busy_list.pop_back()))
                {
                    logerror((HEART_BEAT, "heart_beat_element_mgr_t::handle_timeout "
                      "Failed to pop node from back of element busy list."));

                    return -1;
                }

                m_elements.erase(node->data.element);
                m_node_pool.destroy(node);
                --m_element_count;
            }
            else
            {
              break;  //! if time of element is earlier than current time, break directly
            }
        }
    }

    //logtrace((HEART_BEAT, "heart_beat_element_mgr_t::handle_timeout() end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::add_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::add_element begin..."));

    element_map_iterator it = m_elements.find(element);
    if (it != m_elements.end()) //! setted element is existed and reset element to list header
    {
        logerror((HEART_BEAT, "heart_beat_element_mgr_t::add_element element has existed"));

        return -1;;
    }
    else  //! sets new element onto list header
    {
        if (m_max_limit_flag) //! check max element flag and pop up last element
        {
            if (m_element_count + 1 > m_max_limit)
            {
                list_node_type* node = m_busy_list.pop_back();

                if (!m_callback_function)
                {
                    logwarn((HEART_BEAT, "heart_beat_element_mgr_t::add_element "
                      "The element callback function is empty."));
                }
                else
                {
                    m_callback_function(node->data.element);
                }

                m_elements.erase(node->data.element);
                m_node_pool.destroy(node);
                --m_element_count;
            }
        }

        list_node_type* node = m_node_pool.construct(element);
        if (!node)
        {
            logerror((HEART_BEAT, "heart_beat_element_mgr_t::add_element "
              "failed to malloc the element node."));

            return -1;
        }

        m_elements.insert(make_pair(element, node));
        m_busy_list.push_front(node);
        ++m_element_count;
    }

    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::add_element end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::update_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::update_element begin..."));

    element_map_iterator it = m_elements.find(element);
    if (it == m_elements.end()) //! setted element is existed and reset element to list header
    {
        logwarn((HEART_BEAT, "heart_beat_element_mgr_t::update_element "
          "Failed to find element."));

        return -1;
    }

    list_node_type* node = it->second;
    if (m_busy_list.erase(node))
    {
        logerror((HEART_BEAT, "heart_beat_element_mgr_t::update_element "
          "Failed to delete node from element busy list."));

        return -1;
    }
    node->data.time = ::time(NULL);
    m_busy_list.push_front(node);

    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::update_element end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::del_element(element_type& element)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::del_element begin..."));

    element_map_iterator it = m_elements.find(element);
    if (it != m_elements.end())
    {
        list_node_type* node = it->second;
        if (m_busy_list.erase(node))
        {
            logerror((HEART_BEAT, "heart_beat_element_mgr_t::del_element "
              "Failed to delete node from element busy list."));

            return -1;
        }

        m_elements.erase(element);
        m_node_pool.destroy(node);
        --m_element_count;
    }
    else
    {
        logwarn((HEART_BEAT, "heart_beat_element_mgr_t::del_element "
          "Failed to find element."));

        return -1;
    }

    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::del_element end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::clear_element()
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::clear_element begin..."));
    list_node_type* node = NULL;
    while (NULL != (node = m_busy_list.pop_front()))
    {
        m_node_pool.destroy(node);
    }

    m_elements.clear();
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::clear_element end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
int heart_beat_element_mgr_t<element_type, element_hash>::get_all_element_and_clear(
                                            vector<element_type>* element_vt)
{
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::get_all_element_and_clear begin..."));
    list_node_type* node = NULL;
    while (NULL != (node = m_busy_list.pop_front()))
    {
        element_vt->push_back(node->data.element);
        m_node_pool.destroy(node);
    }

    m_elements.clear();
    logtrace((HEART_BEAT, "heart_beat_element_mgr_t::get_all_element_and_clear end ok..."));
    return 0;
}

template<typename element_type, typename element_hash>
void heart_beat_element_mgr_t<element_type, element_hash>::trigger_all_timeout()
{
    list_node_type* node = NULL;
    while (NULL != (node = m_busy_list.pop_front()))
    {
        if (m_callback_function)
        {
            m_callback_function(node->data.element);
        }

        m_node_pool.destroy(node);
    }

    m_elements.clear();
}

#endif //! _HEART_BEAT_ELEMENT_MGR_H_

