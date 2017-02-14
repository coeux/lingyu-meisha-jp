#ifndef _lg_platform_h_
#define _lg_platform_h_

#include <boost/thread.hpp>
#include <string>
using namespace std;

#include "singleton.h"

class lg_platform_t
{
    typedef boost::mutex::scoped_lock lock_t;
    typedef boost::mutex mutex_t;
public:
    lg_platform_t();
    
    int verify(const string& domain_, const string& jinfo_);
private:
    int verify91(const string& jinfo_);
private:
    string gen_sign_91(const string& str_);
private:
    mutex_t m_mutex;
};

#define lg_platform (singleton_t<lg_platform_t>::instance())

#endif
