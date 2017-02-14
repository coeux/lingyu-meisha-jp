#ifndef _yarray_h_
#define _yarray_h_

#include <iostream>
using namespace std;

template<class T, size_t Size>
struct yarray_t
{
    size_t cap()const  { return Size; }

    T contain[Size];

    T& operator[](size_t i_){ return contain[i_]; }
    const T& operator[](size_t i_)const{ return contain[i_]; }
};

#endif
