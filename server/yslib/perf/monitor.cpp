#include "monitor.h"
#include "log.h"
#include "com_log.h"
#include "performance_service.h"

monitor_t::monitor_t() :
    m_started(false),
    m_timer_expiration(TIMER_EXPIRATION),
    m_io_work(m_io),
    m_timer(m_io)
{
}

monitor_t::~monitor_t()
{
    stop();
}

int monitor_t::set_timeout(int seconds)
{
    m_timer_expiration = seconds;
    return 0;
}

int monitor_t::start()
{
    if (m_started)
    {
        return 0;
    }

    m_thread_ptr.reset(new boost::thread(boost::bind(&boost::asio::io_service::run, &m_io)));
    m_timer.expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(m_timer_expiration));
    m_timer.async_wait(boost::bind(&monitor_t::monitor_record, this, boost::asio::placeholders::error));
    if(!m_thread_ptr.get())
    {
        std::cout<<"monitor_t::open() new boost::thread failed."<<std::endl;
        return -1;
    }

    m_started = true;

    return 0;
}

int monitor_t::stop()
{
    if (!m_started)
        return 0;

    m_timer.cancel();
    m_io.stop();
    m_thread_ptr->join();
    m_started = false;

    return 0;
}

int monitor_t::monitor_record(const boost::system::error_code& error_)
{
    if (error_)
        return 0;

    time_t now = ::time(NULL);
    struct tm tmp;
    localtime_r(&now, &tmp);

    char buff[1024];
    snprintf(buff, sizeof(buff), "[%04d/%02d/%02d %02d:%02d:%02d]  timeout=[%d s] monitor record[%lu]:\n",
            tmp.tm_year + 1900, tmp.tm_mon + 1, tmp.tm_mday, tmp.tm_hour, tmp.tm_min, tmp.tm_sec,
            m_timer_expiration, m_hm_info.size());
    logcom((COM_PERF, "perf_monitor", "%s", buff));

    string_hm_t::iterator iter_hm = m_hm_info.begin();
    for (; iter_hm != m_hm_info.end(); iter_hm++)
    {
        const string& op_name = iter_hm->first;
        performance_info_t& refer = iter_hm->second;
        unsigned long per_cost, req_per_sec;

        if (0 == refer.sum)
        {
            per_cost = 0;
        }
        else
        {
            /*
            if (refer.sum > 2)
                per_cost = (refer.total_cost - refer.max_cost - refer.min_cost) / (refer.sum);
            else
                per_cost = (refer.total_cost) / (refer.sum);
            */
            per_cost = (refer.total_cost) / (refer.sum);
        }
        req_per_sec = (per_cost == 0) ? 0 : (1000000 / per_cost);

        snprintf(buff, sizeof(buff), "max:[%lu us], min:[%lu us], seg:[%lu, %lu, %lu, %lu], per:[%lu us], rps:[%lu], exe:[%lu times]",
                    refer.max_cost, refer.min_cost, refer.up50sum, refer.up100sum, refer.up500sum, refer.up1000sum, per_cost, req_per_sec, refer.sum);

        logcom((COM_PERF, "perf_monitor", "\t%s : %s\n", op_name.c_str(), buff));
    }
    m_hm_info.clear();

    m_timer.expires_at(boost::posix_time::microsec_clock::universal_time() + boost::posix_time::seconds(m_timer_expiration));
    m_timer.async_wait(boost::bind(&monitor_t::monitor_record, this, boost::asio::placeholders::error));

    return 0;
}

void monitor_t::async_performance_log(const string& op_, size_t cost_)
{
    if (m_started)
        m_io.post(boost::bind(&monitor_t::sync_performance_log_i, this, op_, cost_));
}

int monitor_t::sync_performance_log_i(const string& op_, size_t cost_)
{
    performance_info_t& refer = find_hm(op_);
    if (cost_ > refer.max_cost)
    {
        refer.max_cost = cost_;
    }

    if (0 == refer.min_cost)
    {
        refer.min_cost = cost_;
    }
    else if (cost_ < refer.min_cost)
    {
        refer.min_cost = cost_;
    }

    refer.total_cost += cost_;
    refer.sum++;

    if (0 < cost_ && cost_ <= 50)
        refer.up50sum++;
    if (50 < cost_ && cost_ <= 100)
        refer.up100sum++;
    if (100 < cost_ && cost_ <= 500)
        refer.up500sum++;
    if (500 < cost_ && cost_ <= 1000)
        refer.up1000sum++;

    return 0;
}
monitor_t::performance_info_t& monitor_t::find_hm(const string& op_name_)
{
    string_hm_t::iterator iter_hm = m_hm_info.find(op_name_);
    if(iter_hm == m_hm_info.end())
    {
        performance_info_t info;
        memset(&info, 0, sizeof(info));
        pair<string_hm_t::iterator, bool> rt = m_hm_info.insert(make_pair(op_name_, info));
        iter_hm = rt.first;
    }
    return iter_hm->second;
}

