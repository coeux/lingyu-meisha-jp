#ifndef _RANDOM_H_
#define _RANDOM_H_
 
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

#include <iostream>
using namespace std;
  
  
//! it's safe in mutil thread environment.
class random_t
{
public:
    typedef unsigned long seed_type_t;
  
public:
    static const seed_type_t max_32_bit_long = 0xFFFFFFFFLU;
    static const seed_type_t random_max = max_32_bit_long;
  
    random_t(const seed_type_t seed_ = 0)
    {
        reset(seed_);
    }

    //ReSeed the random number generator
    void reset(const seed_type_t seed_ = 0)
    {
        m_seed[0] = (seed_ ^ 0xFEA09B9DLU) & 0xFFFFFFFELU;
        m_seed[0] ^= (((m_seed[0] << 7) & max_32_bit_long) ^ m_seed[0]) >> 31;
  
        m_seed[1] = (seed_ ^ 0x9C129511LU) & 0xFFFFFFF8LU;
        m_seed[1] ^= (((m_seed[1] << 2) & max_32_bit_long) ^ m_seed[1]) >> 29;
  
        m_seed[2] = (seed_ ^ 0x2512CFB8LU) & 0xFFFFFFF0LU;
        m_seed[2] ^= (((m_seed[2] << 9) & max_32_bit_long) ^ m_seed[2]) >> 28;
  
        rand_uint();
    }
  
    //Returns an unsigned integer from 0..random_max
    //0~RandMax uint Ëæ»úÊý
    unsigned long rand_uint(void)
    {
        m_seed[0] = (((m_seed[0] & 0xFFFFFFFELU) << 24) & max_32_bit_long)
            ^ ((m_seed[0] ^ ((m_seed[0] << 7) & max_32_bit_long)) >> 7);
  
        m_seed[1] = (((m_seed[1] & 0xFFFFFFF8LU) << 7) & max_32_bit_long)
            ^ ((m_seed[1] ^ ((m_seed[1] << 2) & max_32_bit_long)) >> 22);
  
        m_seed[2] = (((m_seed[2] & 0xFFFFFFF0LU) << 11) & max_32_bit_long)
            ^ ((m_seed[2] ^ ((m_seed[2] << 9) & max_32_bit_long)) >> 17);
  
        return (m_seed[0] ^ m_seed[1] ^ m_seed[2]);
    }

    //Returns a double in [0.0, 1.0]
    double rand_double(void)
    {
        return static_cast<double>(rand_uint())
            / (static_cast<double>(random_max));
    }

    //Returns a double in [start_, end_]
    double rand_double(double start_, double end_)
    {
        return ((end_ - start_) * rand_double()) + start_;
    }

    static void         reset_seed(const seed_type_t seed_);
    static uint32_t     rand_integer(uint32_t start_, uint32_t end_);
    static int			rand_str(char * dest_, uint32_t len_);
    static int			rand_str(string& dest_, uint32_t len_);

  
private:
    seed_type_t m_seed[3];
};
  
static const char CCH[] = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  
#endif // _RANDOM_H_

