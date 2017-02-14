#ifndef _random_key_h_
#define _random_key_h_

#include <time.h>
#include <stdlib.h>
#include <stdint.h>

#include <iostream>
using namespace std;

//! it's safe in mutil thread environment.
class random_key_t
{
public:
    typedef unsigned long seed_type_t;
  
public:
    static const seed_type_t max_32_bit_long = 0xFFFFFFFFLU;
    static const seed_type_t random_max = max_32_bit_long;
  
    random_key_t(const seed_type_t seed_)
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

    uint32_t rand_integer(uint32_t start_, uint32_t end_)
    {
        if (start_ == end_)
            return start_;

        uint32_t r = rand_uint() % (end_ - start_ + 1);
        return (start_ + r);
    }

    int  rand_str(char * dest_, uint32_t len_)
    {
        static const char CCH[] = "_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
        for (uint32_t i = 0; i < len_; ++i)
        {
            int x = rand_integer(0, sizeof(CCH) - 1);
            dest_[i] = CCH[x];
        }

        return 0;
    }

    int  rand_str(string& dest_, uint32_t len_)
    {
        static const char CCH[] = "_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
        dest_ = "";
        dest_.reserve(len_ + 1);
        for (uint32_t i = 0; i < len_; ++i)
        {
            int x = rand_integer(0, sizeof(CCH) - 1);
            dest_  += CCH[x];
        }

        return 0;
    }
private:
    seed_type_t m_seed[3];
};

#endif
