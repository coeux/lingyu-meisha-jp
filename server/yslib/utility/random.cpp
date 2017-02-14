#include "random.h"

random_t  rand_gen    = random_t((unsigned)time(NULL));
  
/*
uint32_t random_t::rand_integer(uint32_t start_, uint32_t end_)
{
    return (uint32_t)((end_ - start_) * rand_gen.rand_double()) + start_;
}
*/

uint32_t random_t::rand_integer(uint32_t start_, uint32_t end_)
{
    if (start_ >= end_)
        return start_;

    uint32_t r = rand_gen.rand_uint() % (end_ - start_ + 1);
    return (start_ + r);
    //return (r == 0 ? end_ : r);
}
  
int  random_t::rand_str(char * dest_, uint32_t len_)
{
    for (uint32_t i = 0; i < len_; ++i)
    {
        int x = random_t::rand_integer(0, sizeof(CCH) - 2);
        dest_[i] = CCH[x];
    }
  
    return 0;
}
  
int  random_t::rand_str(string& dest_, uint32_t len_)
{
    dest_ = "";
    dest_.reserve(len_ + 1);
    for (uint32_t i = 0; i < len_; ++i)
    {
        int x = random_t::rand_integer(1, 52);
        dest_  += CCH[x];
    }
  
    return 0;
}
  
void random_t::reset_seed(const seed_type_t seed_)
{
    rand_gen.reset(seed_);
}
