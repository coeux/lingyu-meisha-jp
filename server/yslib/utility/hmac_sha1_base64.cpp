#include "hmac_sha1_base64.h"
#include "base64.h"

extern "C"
{
#include <openssl/hmac.h>
#include <openssl/sha.h>
}

int hmac_sha1_base64_t::hmac_encode(const string& base_string_, const string& key_, string& signiture_)
{
    unsigned char hmac_sha1[1024] = {0};
    unsigned int hmac_sha1_len;

    HMAC_CTX ctx;
    HMAC_CTX_init(&ctx);
    if (0 == HMAC(EVP_sha1(),
            key_.data(),
            key_.size(),
            (unsigned char*)base_string_.data(),
            base_string_.size(),
            hmac_sha1,
            &hmac_sha1_len))
    {
        return -1;
    }

    hmac_sha1[hmac_sha1_len] = '\0';
    string input;
    input.assign((char*)hmac_sha1, hmac_sha1_len);
    base64_t::base64_encode(input, signiture_);
    HMAC_cleanup(&ctx);
    return 0;
}


int hmac_sha1_base64_t::sha1_encode(const string& base_string_, string& signiture_)
{
    unsigned char out[20];
    SHA1((const unsigned char*)base_string_.c_str(), base_string_.length(), out);

    string input;
    input.assign((const char*)out, 20);
    base64_t::base64_encode(input, signiture_);
    return 0;
}

