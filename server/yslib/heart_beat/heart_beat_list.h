/*************************************************
* copyright:    copyright @ 2010 fminutes.com
* file name:    double_list.h
* file impl:    N/A
* description:  the double linked list provides double linked list operation and includes:
*       1. push the node onto the header of list
*       2. push the node onto the tail of list
*       3. pop out the header node of list
*       4. pop out the tail node of list
*       5. gets the first header node pointer
*       6. gets the last tail node pointer
*       7. erase the special node of list
*       8. identify whether list  has element
* author:    congjun.chang@fminutes.com 2010.05.04 create the file
*************************************************/

#ifndef _HEART_BEAT_LIST_H_
#define _HEART_BEAT_LIST_H_

//! for template specilization
#include <boost/shared_ptr.hpp>
class connection_t;

#include "log.h"
#include "heart_beat_log_def.h"

//!  description:  the double linked list node
//!  thread safe:  unsafe
//!  Usage:     CDoubleListNode<data_type> node();
//!             CDoubleListNode<data_type> node(data);
template<typename data_type>
struct heart_beat_list_node_t
{
    typedef struct heart_beat_list_node_t<data_type> node_type;

    heart_beat_list_node_t() : front(NULL), next(NULL), data()
    {
    }

    heart_beat_list_node_t(const data_type& in_data) : front(NULL), next(NULL), data(in_data)
    {
    }

    heart_beat_list_node_t(const heart_beat_list_node_t& rhs)
    {
    }

    ~heart_beat_list_node_t()
    {
    }

    node_type* front;
    node_type* next;
    data_type data;
};

//!  description:   the double linked list object
//!                 this list just operate the list node directly
//!                 donot manager node memory allocate and free
//!  thread safe:  unsafe
//!  Usage:     CDoubleList<data_type> double_list();
//!             double_list.push_back(data_type*);
//!             double_list.erase(data_type*);
template<typename data_type>
class heart_beat_list_t
{
public:
    //! defines the node type
    typedef heart_beat_list_node_t<data_type> node_type;

public:
    //!  heart_beat_list_t: constructor
    heart_beat_list_t();

    //!  ~heart_beat_list_t: destructor which donot free node memory
    ~heart_beat_list_t();

    //!  push_front: push the node onto the header of list
    //!  @in   node_type*: the pointer of new node
    //!  @result: int 0: success, -1: new node is NULL pointer
    int push_front(node_type* node);

    //!  push_back: push the node onto the tail of list
    //!  @in   node_type*: the pointer of new node
    //!  @result: int 0: success, -1: new node is NULL pointer
    int push_back(node_type* node);

    //!  pop_front: pop out the header node of list
    //!  @result: node_type*: the pointer of pop node, NULL: list is empty
    node_type* pop_front();

    //!  pop_back: pop out the tail node of list
    //!  @result: node_type*: the pointer of pop node, NULL: list is empty
    node_type* pop_back();

    //!  begin: gets the first header node pointer
    //!  @result: node_type*: the pointer of node, NULL: list is empty
    node_type* front();

    //!  begin: gets the last tail node pointer
    //!  @result: node_type*: the pointer of node, NULL: list is empty
    node_type* back();

    //!  erase: erase the special node from list
    //!  @in   node_type*: the pointer of new node
    //!  @result: int 0: found and erase it, -1: donot find special node
    int erase(node_type* node);

    //!  empty: identify whether list  has element
    //!  @result: bool
    bool empty();

private:
    //! the header pointer of double linked list
    node_type* m_header;

    //! the tail pointer of double linked list
    node_type* m_tail;
};

template<typename data_type>
heart_beat_list_t<data_type>::heart_beat_list_t() : m_header(NULL), m_tail(NULL)
{
    // Empty
}

template<typename data_type>
heart_beat_list_t<data_type>::~heart_beat_list_t()
{
    //! this object donot free the node memory
    m_header = NULL;
    m_tail = NULL;
}

template<typename data_type>
int heart_beat_list_t<data_type>::push_front(node_type* node)
{
    if (!node)
    {
        return -1;
    }

    node->front = NULL;
    node->next = NULL;
    if (!m_header)  //! list is empty
    {
        m_header = node;
        m_tail = node;
    }
    else
    {
        node->next = m_header;
        m_header->front = node;
        m_header = node;
    }

    return 0;
}

template<typename data_type>
int heart_beat_list_t<data_type>::push_back(node_type* node)
{
    if (!node)
    {
        return -1;
    }

    node->front = NULL;
    node->next = NULL;
    if (!m_tail)  //! list is empty
    {
        m_header = node;
        m_tail = node;
    }
    else
    {
        m_tail->next = node;
        node->front = m_tail;
        m_tail = node;
    }

    return 0;
}

template<typename data_type>
heart_beat_list_node_t<data_type>* heart_beat_list_t<data_type>::pop_front()
{
    node_type* ret = NULL;

    if (!m_header)
    {
        ret = NULL;
    }
    else if (m_header == m_tail)
    {
        ret = m_header;
        m_header = NULL;
        m_tail = NULL;
    }
    else
    {
        ret = m_header;
        m_header = m_header->next;
        ret->next = NULL;
        m_header->front = NULL;
    }

    return ret;
}

template<typename data_type>
heart_beat_list_node_t<data_type>* heart_beat_list_t<data_type>::pop_back()
{
    node_type* ret = NULL;

    if (!m_tail)
    {
        ret = NULL;
    }
    else if (m_header == m_tail)
    {
        ret = m_tail;
        m_header = NULL;
        m_tail = NULL;
    }
    else
    {
        ret = m_tail;
        m_tail = m_tail->front;
        ret->front = NULL;
        m_tail->next = NULL;
    }

    return ret;
}

template<typename data_type>
heart_beat_list_node_t<data_type>* heart_beat_list_t<data_type>::front()
{
    return m_header;
}

template<typename data_type>
heart_beat_list_node_t<data_type>* heart_beat_list_t<data_type>::back()
{
    return m_tail;
}

template<typename data_type>
int heart_beat_list_t<data_type>::erase(node_type* node)
{
    if (!node ||  !m_header)
    {
        return -1;
    }

    int ret = -1;
    if (!(node->front) && !(node->next))
    {
        if (m_header == m_tail && m_header == node)
        {
            m_header = NULL;
            m_tail = NULL;
            ret = 0;
        }
    }
    else if (!(node->front) && node->next)
    {
        if (m_header == node)
        {
            m_header = m_header->next;
            m_header->front = NULL;
            node->next = NULL;
            ret = 0;
        }
    }
    if (node->front && !(node->next))
    {
        if (m_tail == node)
        {
            m_tail = m_tail->front;
            m_tail->next = NULL;
            node->front = NULL;
            ret = 0;
        }
    }
    else if (node->front && node->next)
    {
        node_type* node_front = node->front;
        node_type* node_next = node->next;
        node->front = NULL;
        node->next = NULL;
        node_front->next = node_next;
        node_next->front = node_front;
        ret = 0;
    }

    return ret;
}

template<typename data_type>
bool heart_beat_list_t<data_type>::empty()
{
    return !m_header;
}

#endif //! _HEART_BEAT_LIST_H_

