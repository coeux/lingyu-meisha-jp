#ifndef _lg_gen_name_h_ 
#define _lg_gen_name_h_ 

#include <vector>
#include <string>
using namespace std;

#include "singleton.h"

class lg_gen_name_t
{
public:
    int init(const char* path_, const char* name_);
    string random_name();
private:
    vector<string> m_names;
};

#define gen_name (singleton_t<lg_gen_name_t>::instance())

#endif
