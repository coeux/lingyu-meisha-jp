#ifndef _RSA_PEM_H_
#define _RSA_PEM_H_

#include <string>
#include <iostream>
#include <fstream>
using namespace std;

#include <boost/thread.hpp>

extern "C"
{
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
}

class rsa_pem_t
{
    typedef boost::mutex				mutex_t;
    typedef boost::mutex::scoped_lock	scoped_lock_t;
public:
    rsa_pem_t();
    ~rsa_pem_t();

    int gen_pem_file(const string& shell_path_, const string& pri_path_, const string& pub_path_);

    int generate_pubkey_by_psck1(const string& str_);
    int generate_pubkey_by_pem(const string& str_);

    //use public key to encode
    int encode(const string& src_, string& dst_);
    //use private key to decode
    int decode(const string& src_, string& dst_);
    
    string get_pub_pcks1() { return m_pubkey_str; }
    string get_pub_pem() { return m_pubkey_pem_str; }
    string get_pub_pem_stand() { return m_pubkey_pem_str_stand; }
private:
    mutex_t	            m_mutex;
    RSA*    m_pub_rsa;
    RSA*    m_pri_rsa;
    string  m_pubkey_str;
    string  m_pubkey_pem_str;
    string  m_pubkey_pem_str_stand;
};

#endif
