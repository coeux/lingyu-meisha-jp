#ifndef _BASE64_H_
#define _BASE64_H_

#include <string>
using namespace std;

class base64_t
{
public:
    static int base64_encode(const string& input_, string& output_);
    static int base64_decode(const string& input_, string& output_);    

private:
    static bool is_base64(char c_);
};

#endif

