#ifndef _ARRAY_H_
#define _ARRAY_H_

#include <vector>
using namespace std;

template<typename T>
class array_t
{
    typedef vector<T>                 data_vector_t;
public:
    array_t()
    {}
    array_t(const array_t<T>& array_);
    virtual ~array_t() {}

    size_t size();
    T*     at(size_t i);
    T      value_at(size_t i);
    void   clear();
    void   push_back(const T& t_);
    void   push_back_ptr(T* p_);

private:
    data_vector_t           m_data;
};

template<typename T>
array_t<T>::array_t(const array_t<T>& src_array_)
{
    m_data = src_array_.m_data;
}

template<typename T>
void array_t<T>::clear()
{
    m_data.clear();
}

template<typename T>
size_t array_t<T>::size()
{
    return m_data.size();
}

template<typename T>
T* array_t<T>::at(size_t i_)
{
    if (i_ >= m_data.size())
    {
        return NULL;
    }

    return &m_data[i_];
}

template<typename T>
T array_t<T>::value_at(size_t i_)
{
    if (i_ >= m_data.size())
    {
        return T();
    }

    return m_data[i_];
}

template<typename T>
void array_t<T>::push_back(const T& t_)
{
    m_data.push_back(t_);
}

template<typename T>
void array_t<T>::push_back_ptr(T* p_)
{
    m_data.push_back(*p_);
}

#endif
