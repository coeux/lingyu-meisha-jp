#include "rsa.h"
#include <string.h>

rsa_t::rsa_t():m_pub_rsa(NULL), m_priv_rsa(NULL)
{
}
rsa_t::~rsa_t()
{
    RSA_free(m_pub_rsa);
    RSA_free(m_priv_rsa);
}
int rsa_t::generate_key(int bits_)
{
    //rsa has public key and private key
    RSA* rsa = RSA_generate_key(bits_, RSA_F4, NULL, NULL);
    m_priv_rsa = rsa;

    //get public key info
    char* pubkey = new char[bits_];
    char* tmp = pubkey;
    int pubkey_len = i2d_RSAPublicKey(rsa, (unsigned char**)&tmp);
    m_pubkey_str = pubkey;

    m_pubkey_str.resize(pubkey_len);
    memcpy((char*)m_pubkey_str.c_str(), pubkey, pubkey_len);

    //create only public info key
    tmp = pubkey;
    m_pub_rsa = d2i_RSAPublicKey(NULL, (const unsigned char**)&tmp, pubkey_len);
    delete pubkey;

    return 0;
}
int rsa_t::generate_pubkey(const string& pubkey_str_)
{
    char* tmp = (char*)pubkey_str_.c_str();
    m_pub_rsa = d2i_RSAPublicKey(NULL, (const unsigned char**)&tmp, pubkey_str_.size());
    if (m_pub_rsa == NULL)
        return -1;
    else
        return 0;
}
int rsa_t::encode(const string& src_, string& dst_)
{
    if (m_pub_rsa == NULL)
        return -1;
    int rsa_len=RSA_size(m_pub_rsa);
    dst_.resize(rsa_len);
    if(RSA_public_encrypt(src_.size(),(unsigned char *)src_.c_str(),(unsigned char*)dst_.c_str(), m_pub_rsa, RSA_NO_PADDING)<0)
    {
        return -1;
    }
    return 0;
}
int rsa_t::decode(const string& src_, string& dst_)
{
    if (m_priv_rsa == NULL)
        return -1;
    int rsa_len=RSA_size(m_priv_rsa);
    char* buff = new char[rsa_len];
    if(RSA_private_decrypt(rsa_len,(unsigned char *)src_.c_str(),(unsigned char*)buff,m_priv_rsa,RSA_NO_PADDING)<0)
    {
        delete buff;
        return -1;
    }
    dst_ = buff;
    delete buff;
    return 0;
}
