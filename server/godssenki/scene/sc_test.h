#ifndef _sc_test_h_
#define _sc_test_h_

#include "test_msg_def.h"
#include "singleton.h"

class sc_test_t
{
public:
    void test_arena(int32_t uid_, test_msg_def::req_test_arena_t& req_);
};

#define unit_test (singleton_t<sc_test_t>::instance())

#endif
