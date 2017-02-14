#ifndef _URL_ALGORITHM_H_
#define _URL_ALGORITHM_H_

#include <string>
using namespace std;

class url_algorithm_t
{
public:
    static int url_encode(const string& input_, string& output_);
    static int url_decode(const string& input_, string& output_);

private:
    static unsigned int utf8_decode(char *s_, unsigned int *pi_);
    
};

#endif
