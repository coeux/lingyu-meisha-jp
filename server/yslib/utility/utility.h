#ifndef _UTILITY_H_
#define _UTILITY_H_

#include <string>
using namespace std;

namespace utility
{

/*! @ingroup    UTILITY_LIB
 *  @class      hash_string_t
 *  @brief      the functor
 */
class hash_string_t
{
public:
    static const unsigned int HASH_RADIX = 31;

    size_t operator()(const string& str_) const
    {
        size_t hash_value = 0;
        int len = str_.length();
        for (int i = 0; i < len; ++i)
        {
            hash_value = hash_value * HASH_RADIX + str_[i];
        }

        return hash_value;
    }
};

template<class T>
static T string2num(const char* str_)
{
    return atoi(str_);
}

template<>
short string2num<short>(const char* str_)
{
    return (short)atoi(str_);
}

template<>
unsigned short string2num<unsigned short>(const char* str_)
{
    return (unsigned short)atoi(str_);
}

template<>
int string2num<int>(const char* str_)
{
    return atoi(str_);
}
template<>
unsigned int string2num<unsigned int>(const char* str_)
{
    return (unsigned int)atoi(str_);
}

template<>
long string2num<long>(const char* str_)
{
    return atol(str_);
}
template<>
unsigned long string2num<unsigned long>(const char* str_)
{
    return strtoul(str_, (char**)NULL, 10);
}

template<>
long long string2num<long long>(const char* str_)
{
    return atoll(str_);
}

template<>
unsigned long long string2num<unsigned long long>(const char* str_)
{
    return strtoull(str_, (char**)NULL, 10);
}

template<>
float string2num<float>(const char* str_)
{
    return strtof(str_, (char**)NULL);
}

template<>
double string2num<double>(const char* str_)
{
    return atof(str_);
}

template<>
long double string2num<long double>(const char* str_)
{
    return strtold(str_, (char**)NULL);
}

} //! namespace utility

#endif //! _COMMON_UTILITY_H_

