#include <stdexcept>
using namespace std;

#include <boost/thread.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>

#include "io_service_pool.h"

io_service_pool_t::io_service_pool_t()
  : m_next_io_service(0)
{
}

void io_service_pool_t::start(std::size_t pool_size)
{
	if (pool_size == 0)
	{
	    throw std::runtime_error("io_service_pool_t size is 0");
	}

  	// Give all the io_services work to do so that their run() functions will not
  	// exit until they are explicitly stopped.
  	for (std::size_t i = 0; i < pool_size; ++i)
  	{
    	io_service_ptr io_service(new boost::asio::io_service);
    	work_ptr work(new boost::asio::io_service::work(*io_service));
    	m_io_services_set.push_back(io_service);
    	m_work_set.push_back(work);
  	}

  	for (std::size_t i = 0; i < m_io_services_set.size(); ++i)
  	{
    	boost::shared_ptr<boost::thread> thread(new boost::thread(
          boost::bind(&boost::asio::io_service::run, m_io_services_set[i])));
    	m_vt_threads.push_back(thread);
  	}
}

io_service_pool_t::~io_service_pool_t()
{
	stop();
}

void io_service_pool_t::stop()
{

	//! stop all work
	m_work_set.clear();
	for (std::size_t i = 0; i < m_vt_threads.size(); ++i)
	{
		m_vt_threads[i]->join();
	}
	m_vt_threads.clear();
    /*
  	// Explicitly stop all io_services.
  	for (std::size_t i = 0; i < m_io_services_set.size(); ++i)
        m_io_services_set[i]->stop();
    */
}

boost::asio::io_service& io_service_pool_t::get_io_service()
{
  	// Use a round-robin scheme to choose the next io_service to use.
  	boost::asio::io_service& ret = *m_io_services_set[m_next_io_service % m_io_services_set.size()];
  	++m_next_io_service;

  	return ret;
}
boost::asio::io_service& io_service_pool_t::get_io_service(std::size_t index_)
{
    if (index_ >= 0 && index_ < m_io_services_set.size())
    {
        return *m_io_services_set[index_];
    }
    else
    {
        throw std::exception(std::runtime_error("index error!"));
    }
}
std::size_t io_service_pool_t::get_io_size()
{
    return m_io_services_set.size();
}
