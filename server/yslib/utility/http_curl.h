#ifndef _HTTP_CURL_H_
#define _HTTP_CURL_H_

#include <curl/curl.h>

#include <string>
#include <vector>
using namespace std;

#define TIMEOUT 15
#define DEFAULT_AGENT "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 (fm) Firefox/3.6.3"

class http_curl_t
{
public:
    http_curl_t();
    ~http_curl_t();

public:
    //! invokes one times for global
    static int global_init();
    static int global_cleanup();

private:
    static bool g_init_flag;

public:
    int start();
    int stop();
    int enable_debug(bool debug_ = true);
    int set_agent(const string& agent_);
    int sync_prepare();
    int sync_get(const string& url_, long timeout_ = TIMEOUT);
    int sync_post(const string& url_, string& err_code_, long timeout_ = TIMEOUT);
    int add_packet(const string& key_, const string& value_, bool use_encode_ = true);
    int get_packet_md5(string& packet_md5_);
    int get_result(string& result_);

private:
    static size_t process_func_i(void* ptr_, size_t size_, size_t nmemb_, void *usrptr_);
    size_t process_i(void* data_, size_t size_, size_t nmemb_);

private:
    CURL*       m_curl;
    string      m_agent;
    int         m_enable_debug;
    string      m_packet_body;
    string      m_packet_md5;
    string      m_result;
    bool        m_started;
};

//! Usage
//! boost::object_pool<http_curl_t> curl_pool;
//! http_curl_t* hcurl = curl_pool.construct();
//! hcurl->start();
//! hcurl->add_packet([key], [value]);
//! hcurl->sync_post([url], [timeout]);
//! hcurl->get_result([result_string]);
//!

#endif

