#ifndef _RSA_H_
#define _RSA_H_

#include <string>
using namespace std; 

extern "C"
{
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
}

class rsa_t
{
public:
    rsa_t();
    ~rsa_t();

    const string& get_pubkey_str() const { return m_pubkey_str; }

    int generate_key(int bits_);
    int generate_pubkey(const string& pubkey_str_);

    //use public key to encode
    int encode(const string& src_, string& dst_);
    //use private key to decode
    int decode(const string& src_, string& dst_);
private:
    RSA*    m_pub_rsa;
    RSA*    m_priv_rsa;
    string  m_pubkey_str;
};

#endif
