#include "rsa_pem.h"
#include <fstream>
#include <string.h>

void get_real_pem(string& content_)
{
    size_t pos_beg = content_.find_first_of('\n');
    content_ = content_.substr(pos_beg+1, content_.size()-pos_beg);

    size_t pos_end = content_.find_first_of('-');
    content_ = content_.substr(0, pos_end);
}
string read_pem(const char* path_)
{
    ifstream file(path_);
    file.seekg(0, ios::end);
    int len = file.tellg();
    string content;
    content.resize(len+1);
    file.seekg(0, ios::beg);
    while(!file.eof())
    {
        file.read((char*)content.c_str(), len+1);
    }
    file.close();
    cout << "pem file size:" << content.size() << endl;
    cout << content;
    return content;
}
RSA* get_rsa(const char* path_, int flag_)
{
    EVP_PKEY* k;
    BIO *in = BIO_new(BIO_s_file_internal());
    if (BIO_read_filename(in, path_) > 0) 
    {
        RSA* key = NULL;
        if (flag_ == 0)
        {
            k = PEM_read_bio_PUBKEY(in, NULL, NULL, NULL);    
            key = RSAPublicKey_dup(k->pkey.rsa);
        }
        else
        {
            k = PEM_read_bio_PrivateKey(in, NULL, NULL, NULL);    
            key = RSAPrivateKey_dup(k->pkey.rsa);
        }
        EVP_PKEY_free(k);
        BIO_free(in);
        return key;
    }
    else
    {
        return NULL;
    }
}
int encrypt(int len, unsigned char *from, unsigned char *to, RSA *rsa) 
{
    int    i, ret, nblocks, iblock_size, oblock_size;
    /* sanity check */
    if ((from == NULL) || (to == NULL) || (rsa == NULL))
        return (-1);

    /*
     *  * PKCS1 uses 11 bytes to do padding; therefore, we can encrypt only
     *   * bytes_of_RSA_key_length - 11 bytes of data per round.
     *
     *    */

    iblock_size = BN_num_bytes(rsa->n) - 11;
    oblock_size = BN_num_bytes(rsa->n);
    nblocks = (len / iblock_size) + ((len % iblock_size == 0) ? 0 : 1);
    for (i = 0; i < nblocks; i++)
    {
        if (i == nblocks - 1)
        {
            ret = RSA_public_encrypt(len % iblock_size,
                    &from[i * iblock_size],
                    &to[i * oblock_size],
                    rsa,
                    RSA_PKCS1_PADDING);
        }
        else
        {
            ret = RSA_public_encrypt(iblock_size,
                    &from[i * iblock_size],
                    &to[i * oblock_size],
                    rsa,
                    RSA_PKCS1_PADDING);
        }
        if (ret == -1)
        {
            printf("unable to do %d bytes RSA encryption", len);
            return (-1);
        }
    }
    return 0;
}
int decrypt(int len, unsigned char *from, unsigned char *to, RSA *rsa)
{
    int    i, ret, total, nblocks, block_size;
    unsigned char *buf;
    if ((from  == NULL) || (to == NULL) || (rsa == NULL))
        return (-1);

    block_size = BN_num_bytes(rsa->n);
    nblocks = len / block_size;
    if ((buf = (unsigned char *)malloc(block_size)) == NULL)
    {
        printf("virtual memory exhausted");
        return (-1);
    }
    for (i = total = 0; i < nblocks; i++, total += ret)
    {
        ret = RSA_private_decrypt(block_size, &from[i * block_size],
                buf, rsa, RSA_PKCS1_PADDING);
        if (ret == -1)
        {
            printf("unable to do %d bytes RSA decryption", len);
            free(buf);
            return (-1);
        }
        memcpy(&to[total], buf, ret);
    }
    free(buf);
    return 0;
}
rsa_pem_t::rsa_pem_t():m_pub_rsa(NULL), m_pri_rsa(NULL)
{
}
rsa_pem_t::~rsa_pem_t()
{
    RSA_free(m_pub_rsa);
    RSA_free(m_pri_rsa);
}
int rsa_pem_t::gen_pem_file(const string& shell_path_, const string& pri_path_, const string& pub_path_)
{
	scoped_lock_t lock(m_mutex);
    system(shell_path_.c_str());
    m_pubkey_pem_str_stand = m_pubkey_pem_str = read_pem(pub_path_.c_str());
    get_real_pem(m_pubkey_pem_str_stand);

    /*
    FILE *file;
    if((file=fopen(pub_path_.c_str(),"r"))==NULL){
        perror("open pub key file error");
        return -1;    
    }   
    if((m_pub_rsa = PEM_read_RSA_PUBKEY(file,NULL,NULL,NULL))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }   
    fclose(file);

    if((file=fopen(pri_path_.c_str(),"r"))==NULL){
        perror("open pri key file error");
        return -1;    
    }   
    if((m_pri_rsa = PEM_read_RSAPrivateKey(file,NULL,NULL,NULL))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }
    fclose(file);
    */
    if((m_pub_rsa = get_rsa(pub_path_.c_str(), 0))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }   
    if((m_pri_rsa = get_rsa(pri_path_.c_str(), 1))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }

    char* pubkey = new char[2048];
    char* tmp = pubkey;
    int pubkey_len = i2d_RSAPublicKey(m_pub_rsa, (unsigned char**)&tmp);
    m_pubkey_str.clear();
    m_pubkey_str.resize(pubkey_len);
    memcpy((char*)m_pubkey_str.c_str(), pubkey, pubkey_len);
    delete pubkey;

    return 0;
}
int rsa_pem_t::generate_pubkey_by_psck1(const string& str_)
{
	scoped_lock_t lock(m_mutex);

    m_pubkey_str = str_;

    char* tmp = (char*)str_.c_str();
    RSA_free(m_pub_rsa);
    m_pub_rsa = d2i_RSAPublicKey(NULL, (const unsigned char**)&tmp, str_.size());

    return 0;
}
int rsa_pem_t::generate_pubkey_by_pem(const string& str_)
{
	scoped_lock_t lock(m_mutex);
    
    ofstream out("tmp_pub.pem");
    out.write(str_.c_str(), str_.size());
    out.close();

    /*
    FILE *file;
    if((file=fopen("tmp_pub.pem","r"))==NULL){
        perror("open pub key file error");
        return -1;    
    }   
    RSA_free(m_pub_rsa);
    if((m_pub_rsa = PEM_read_RSA_PUBKEY(file,NULL,NULL,NULL))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }   
    fclose(file);
    */
    if((m_pub_rsa = get_rsa("tmp_pub.pem", 0))==NULL){
        ERR_print_errors_fp(stdout);
        return -1;
    }   

    remove("tmp_pub.pem");

    return 0;
}
int rsa_pem_t::encode(const string& src_, string& dst_)
{
	scoped_lock_t lock(m_mutex);

    int rsa_len=RSA_size(m_pub_rsa);
    dst_.resize(rsa_len);
    int len = 0;
    if((len = RSA_public_encrypt(src_.size(),(unsigned char *)src_.c_str(), (unsigned char*)dst_.c_str(), m_pub_rsa, RSA_PKCS1_PADDING))<0)
    {
        return -1;
    }
    return 0;
}
int rsa_pem_t::decode(const string& src_, string& dst_)
{
	scoped_lock_t lock(m_mutex);

    int rsa_len=RSA_size(m_pri_rsa);
    dst_.resize(rsa_len);
    int len = 0;
    if((len = RSA_private_decrypt(rsa_len,(unsigned char *)src_.c_str(),(unsigned char*)dst_.c_str(),m_pri_rsa,RSA_PKCS1_PADDING))<0)
    {
        return -1;
    }
    dst_ = dst_.substr(0, len);
    return 0;
}
