#include <curl/curl.h>
#include <openssl/crypto.h>

#include <iostream>
using namespace std;

#include "http_curl.h"

http_curl_t::http_curl_t():
    m_curl(NULL),
    m_enable_debug(0),
    m_started(false)
{
}

http_curl_t::~http_curl_t()
{
    stop();
}

bool http_curl_t::g_init_flag = false;

static pthread_mutex_t* thread_locks = NULL;

static unsigned long openssl_thread_id()
{
    return (unsigned long) pthread_self();
}

static void openssl_thread_lock(int mode_, int lock_id_, const char* file_, int line_)
{
    if (mode_ & CRYPTO_LOCK)
    {
        pthread_mutex_lock(&thread_locks[lock_id_]);
    }
    else
    {
        pthread_mutex_unlock(&thread_locks[lock_id_]);
    }
}

static int openssl_init()
{
    /* If some other library already set these, don't dick around */
    if (CRYPTO_get_locking_callback() && CRYPTO_get_id_callback())
    {
        fprintf(stderr, "OpenSSL locking callbacks are already in place?\n");
        fflush(stderr);
        return 1;
    }

    size_t num_thread_locks = CRYPTO_num_locks();
    thread_locks = (pthread_mutex_t*)calloc(sizeof(pthread_mutex_t), num_thread_locks);

    size_t i;
    for (i = 0; i < num_thread_locks; ++i)
    {
        if (pthread_mutex_init(&thread_locks[i], NULL))
        {
            fprintf(stderr, "Unable to initialize a mutex.\n");
            fflush(stderr);
            return -1;
        }
    }

    CRYPTO_set_locking_callback(&openssl_thread_lock);
    CRYPTO_set_id_callback(&openssl_thread_id);

    return 0;
}

int http_curl_t::global_init()
{
    if (g_init_flag)
    {
        return 0;
    }

    CURLcode res = curl_global_init(CURL_GLOBAL_ALL);
    if (CURLE_OK != res)
    {
        cout << "curl_global_init failed: " << res << endl;
        return -1;
    }

    int ret = openssl_init();
    if (ret < 0)
    {
        cout << "http_curl_t::global_init openssl_init ret=<" << ret << ">" << endl;
        return -1;
    }

    g_init_flag = true;
    return 0;
}

int http_curl_t::global_cleanup()
{
    if (!g_init_flag)
    {
        return 0;
    }

    curl_global_cleanup();
    g_init_flag = false;

    return 0;
}

int http_curl_t::start()
{
    if (m_started)
    {
        return 0;
    }

    m_curl = curl_easy_init();
    if (m_curl == NULL)
    {
        return -1;
    }
    m_started = true;

    //! init member variables
    m_agent.assign(DEFAULT_AGENT);
    m_enable_debug = 0;
    m_packet_body.clear();
    m_packet_md5.clear();
    m_result.clear();

    return 0;
}

int http_curl_t::stop()
{
    if (!m_started)
    {
        return 0;
    }

    curl_easy_cleanup(m_curl);
    m_started = false;

    return 0;
}

int http_curl_t::sync_prepare()
{
    m_packet_body.clear();
    m_packet_md5.clear();
    m_result.clear();

    return 0;
}
int http_curl_t::enable_debug(bool debug_)
{
    m_enable_debug = debug_ ? 1 : 0;

    return 0;
}

int http_curl_t::set_agent(const string& agent_)
{
    m_agent = agent_;

    return 0;
}

int http_curl_t::sync_get(const string& url_, long timeout_)
{
    if (!m_started)
    {
        return -1;
    }
    curl_easy_reset(m_curl);

    if (url_.empty())
    {
        return -1;
    }

    string full_url(url_);
    full_url += "?" + m_packet_body;

    curl_easy_setopt(m_curl, CURLOPT_HEADER, 0L);
    curl_easy_setopt(m_curl, CURLOPT_URL, full_url.c_str());
    curl_easy_setopt(m_curl, CURLOPT_HTTPGET, 1L);
    curl_easy_setopt(m_curl, CURLOPT_USERAGENT, m_agent.c_str());
    curl_easy_setopt(m_curl, CURLOPT_TIMEOUT_MS, timeout_);
    curl_easy_setopt(m_curl, CURLOPT_WRITEFUNCTION, http_curl_t::process_func_i);
    curl_easy_setopt(m_curl, CURLOPT_WRITEDATA, this);
    curl_easy_setopt(m_curl, CURLOPT_VERBOSE, m_enable_debug);

    curl_easy_setopt(m_curl, CURLOPT_NOSIGNAL, 1L);
    CURLcode res = curl_easy_perform( m_curl);

    if (res != CURLE_OK)
    {
        //! curl_easy_strerror(res)
        cout << "sync_get failed with error : \n";
        return -1;
    }

    return 0;
}

int http_curl_t::sync_post(const string& url_, string& err_code_, long timeout_)
{
    if (!m_started)
    {
        return -1;
    }
    curl_easy_reset(m_curl);
    curl_easy_setopt(m_curl, CURLOPT_HEADER, 0L);
    curl_easy_setopt(m_curl, CURLOPT_URL, url_.c_str());
    curl_easy_setopt(m_curl, CURLOPT_POST, 1L);
    curl_easy_setopt(m_curl, CURLOPT_POSTFIELDS, m_packet_body.c_str());
    curl_easy_setopt(m_curl, CURLOPT_USERAGENT, m_agent.c_str());
    curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYPEER, 0L); //! enable HTTPS
    //curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYHOST, 2L); //! validate HOST name, make sure use the URL to send request
    curl_easy_setopt(m_curl, CURLOPT_SSL_VERIFYHOST, 0L); //! validate HOST name, make sure use the URL to send request
    curl_easy_setopt(m_curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(m_curl, CURLOPT_TIMEOUT, timeout_);
    curl_easy_setopt(m_curl, CURLOPT_WRITEFUNCTION, http_curl_t::process_func_i); //! callback to get return data
    curl_easy_setopt(m_curl, CURLOPT_WRITEDATA, this);
    curl_easy_setopt(m_curl, CURLOPT_VERBOSE, m_enable_debug); //! console debug info
    //! set signal
    curl_easy_setopt(m_curl, CURLOPT_NOSIGNAL, 1L);

    CURLcode res = curl_easy_perform(m_curl);
    if (res != CURLE_OK)
    {
        err_code_ = curl_easy_strerror(res);
        return -1;
    }

    return 0;
}

int http_curl_t::add_packet(const string& key_, const string& value_, bool use_encode_ )
{
    /*
    if (key_.empty())
    {
        return -1;
    }
    */

    if (!m_packet_body.empty())
    {
        m_packet_body += "&";
    }

    //! urlencode the string for POST request
    char* escaped_value = curl_easy_escape(m_curl, value_.c_str(), 0);

    if (key_ == "")
    {
        if (use_encode_)
        {
            m_packet_body += escaped_value;
        }
        else
        {
            m_packet_body += value_;
        }
        m_packet_md5 += value_;
    }
    else
    {
        if (use_encode_)
        {
            m_packet_body += key_ + "=" + escaped_value;
        }
        else
        {
            m_packet_body += key_ + "=" + value_;
        }
        m_packet_md5 += key_ + "=" + value_;
    }

    curl_free(escaped_value);

    return 0;
}

int http_curl_t::get_packet_md5(string& packet_md5_)
{
    packet_md5_ = m_packet_md5;

    return 0;
}

int http_curl_t::get_result(string& result_)
{
    result_ = m_result;

    return 0;
}

size_t http_curl_t::process_func_i(void* ptr_, size_t size_, size_t nmemb_, void *usrptr_)
{
    http_curl_t* p =(http_curl_t*)usrptr_;

    return p->process_i(ptr_, size_, nmemb_);
}

size_t http_curl_t::process_i(void* data_, size_t size_, size_t nmemb_)
{
    //! this method would be called several times in a HTTP(s) request
    m_result.append((char*)data_, size_ * nmemb_);

    return size_ * nmemb_;
}
