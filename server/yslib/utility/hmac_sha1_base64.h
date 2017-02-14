#ifndef _HMAC_SHA1_BASE64_H_
#define _HMAC_SHA1_BASE64_H_

#include <string>
using namespace std;

class hmac_sha1_base64_t
{
public:
    static int hmac_encode(const string& base_string_, const string& key_, string& signiture_);
    static int sha1_encode(const string& base_string_, string& signiture_);
};

#endif

