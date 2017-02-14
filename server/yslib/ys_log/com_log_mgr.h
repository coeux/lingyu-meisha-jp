#ifndef _COM_LOG_MGR_H_
#define _COM_LOG_MGR_H_

#include <map>
#include <vector>
#include <string>
using namespace std;

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/noncopyable.hpp>

#define FORMAT_MAX_BUF_SIZE 1024

class com_log_impl_t;

/*! @ingroup    BASE_LIB
 *  @class      com_log_mgr_t
 *  @brief      this class defines component log manager
 */
class com_log_mgr_t : private boost::noncopyable
{
public:

    //! defines component log instance pointer
    typedef boost::shared_ptr<com_log_impl_t>  sp_com_log_t;

    //! defines module and com log pair map
    typedef map<string, sp_com_log_t>     module_log_map_t;

    //! defines component and module/log instance pair m
    typedef map<string, module_log_map_t>  com_log_map_t;

public:

    /*! @fn         com_log_mgr_t();
     *  @brief      constructor
     */
    com_log_mgr_t();

    /*! @fn         ~com_log_mgr_t();
     *  @brief      destructor
     */
    ~com_log_mgr_t();

    /*! @fn         int open(const vector<string>&, unsigned int, const string&, const string&, int, int, int, int, int, int)
     *  @brief      open all component log
     *  @param      const vector<string>& coms: all component that need to record log
     *  @param      unsigned int max_num_modules: max module number for every opened component
     *  @param      const string& path: log path
     *  @param      const string& file: log file name
     *  @param      int print_file: print file flag
     *  @param      int print_screen: print screen flag
     *  @param      int log_level: setting log level
     *  @param      int log_format: log record head format
     *  @param      int max_line: one log file max line number
     *  @param      int max_size: one log file max size
     *  @return     int
     */
    int open(const vector<string>& coms,
        unsigned int max_num_modules,
        const string& path,
        const string& file,
        int print_file,
        int print_screen,
        int log_level,
        int log_format,
        int max_line,
        int max_size);

    /*! @fn         int close();
     *  @brief      close all component log
     *  @return     int
     */
    int close();

    /*! @fn         _add_log(const char* com, const char* module, int level, const char* fmt, ...);
     *  @brief      adds one log record
     *  @param      const char* com: component name
     *  @param      const char* module: module name
     *  @param      int level: level for this log record
     *  @param      const char* fmt: format for print out
     *  @param      ...: argument for format print
     *  @return     int
     */
    int _add_log(const char* com, const char* module, const char* fmt, ...);
    int _add_log(const char* com, const char* module, int level, const char* fmt, ...);

private:

    /*! @fn         int add_log(const string com, const string module, int level, const string fmt);
     *  @brief      adds one log record
     *  @param      const string com: component name
     *  @param      const string module: module name
     *  @param      int level: level for this log record
     *  @param      const string fmt: format for print out and has invoke vsnprintf to format
     *  @return     int
     */
    int add_log(const string com, const string module, string fmt);
    int add_log(const string com, const string module, int level, const string fmt);
    int log(const string& com, const string& module, int level, const string& fmt);

    /*! @fn         int check_log_conf();
     *  @brief      check component log configure
     *  @return     int
     */
    int check_log_conf();

private:

    bool                                    m_opened;               //! log manager server status
    com_log_map_t                           m_com_logs;             //! component and log instance map info
    unsigned int                            m_max_num_modules;
    string                                  m_path;
    string                                  m_file;
    bool                                    m_print_file;
    bool                                    m_print_screen;
    int                                     m_log_level;
    unsigned int                            m_log_format;
    int                                     m_max_line;
    int                                     m_max_size;
    boost::asio::io_service                 m_io_service;
    boost::asio::io_service::work           m_work;
    boost::scoped_ptr<boost::thread>        m_work_thread;
};

#endif //! _H_COM_LOG_MGR_H_

