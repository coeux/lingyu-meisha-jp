
#ifndef _IO_SERVICE_POOL_H_
#define _IO_SERVICE_POOL_H_

#include <vector>
using namespace std;

#include <boost/asio.hpp>
#include <boost/noncopyable.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>


/// A pool of io_service objects.
class io_service_pool_t
  : private boost::noncopyable
{
public:
  /// Construct the io_service pool.
  io_service_pool_t();

  void start(std::size_t pool_size);

  /// Run all io_service objects in the pool.
  //void run();

  ~io_service_pool_t();
public:
  /// Get an io_service to use.
  boost::asio::io_service& get_io_service();
  boost::asio::io_service& get_io_service(std::size_t index_);
  std::size_t get_io_size();

  /// Stop all io_service objects in the pool.
  void stop();

private:
  typedef boost::shared_ptr<boost::asio::io_service> io_service_ptr;
  typedef boost::shared_ptr<boost::asio::io_service::work> work_ptr;

  /// The pool of io_services.
  std::vector<io_service_ptr>  m_io_services_set;

  /// The work that keeps the io_services running.
  std::vector<work_ptr> m_work_set;

  /// The next io_service to use for a connection.
  std::size_t m_next_io_service;

  std::vector<boost::shared_ptr<boost::thread> > m_vt_threads;
};

typedef boost::shared_ptr<io_service_pool_t> io_service_pool_ptr_t;

#define io_pool (singleton_t<io_service_pool_t>::instance())

#endif
