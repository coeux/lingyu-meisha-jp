#ifndef _sc_name_h_ 
#define _sc_name_h_ 

#include <vector>
#include <string>
using namespace std;

#include "singleton.h"

class sc_name_t
{
public:
    int init(const char* path_, const char* name_);
    string random_name();
private:
    vector<string> m_names;
};

#define gen_name (singleton_t<sc_name_t>::instance())

#endif
