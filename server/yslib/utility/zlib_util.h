#ifndef _ZLIB_UTIL_H_
#define _ZLIB_UTIL_H_

#include <string>
using namespace std;

class zlib_util_t
{
public:
	static int compress(const string& source, string& dest);
    static int compress( char* in, uint32_t inLength, char** out);
	static int uncompress(const string& source, string& dest);
};

#endif
