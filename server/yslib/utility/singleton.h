#ifndef _SINGLETON_H_
#define _SINGLETON_H_

#define BOOST_SINGLETON

#ifdef BOOST_SINGLETON

template <class T>
class singleton_t : private T
{
private:
    singleton_t(){}
    ~singleton_t(){}

public:
    static T &instance()
    {
        static singleton_t<T> s_oT;
        return(s_oT);
    }
};

#else

#include <stdlib.h>
#include <pthread.h>

template<class T>
class singleton_t
{
public:
    static T& instance()
    {
	    pthread_once(&m_ponce, &singleton_t::init);
        return *m_instance;
    }

private:
	static void init()
	{
		m_instance = new T();
		atexit(destroy);
	}
	static void destroy()
	{
		if(m_instance)
		{
			delete m_instance;
			m_instance = 0;
		}
	}

private:
	static T* volatile m_instance;
	static pthread_once_t m_ponce;
};

template<class T>
T* volatile singleton_t<T>::m_instance = NULL;

template<typename T>
pthread_once_t singleton_t<T>::m_ponce = PTHREAD_ONCE_INIT;

/*
//! Usage:
//! singleton_t<class_name>::instance().method
//!
template<class T>
class singleton_t 
{
    struct  object_creator
    {
        object_creator(){ singleton_t<T>::instance(); }
        inline  void  do_nothing() const {}
    };

    static  object_creator create_object;

public :
    typedef T object_type;
    static  object_type &  instance()
    {
        static  object_type obj;
        create_object.do_nothing();
        return  obj;
    }
};
template<class T> 
typename singleton_t<T>::object_creator singleton_t<T>::create_object;
*/
#endif

#endif //! _SINGLETON_H_
