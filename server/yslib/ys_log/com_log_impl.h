#ifndef _COM_LOG_IMPL_H_
#define _COM_LOG_IMPL_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <sys/time.h>

#include <set>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
using namespace std;

#include <boost/noncopyable.hpp>

/*! @ingroup    BASE_LIB
 *  @class      CComLog
 *  @brief      it defines component log implement
 */
class com_log_impl_t : private boost::noncopyable
{
public:

    /*! @fn         com_log_impl_t();
     *  @brief      constructor
     */
	com_log_impl_t();

    /*! @fn         com_log_impl_t();
     *  @brief      destructor
     */
	~com_log_impl_t();

    /*! @fn         int open(const char*, const char*, const char*, const char*, int, int, int, int, int, int)
     *  @brief      open component log
     *  @param      const char* com: component that need to record log
     *  @param      const char* module: module name
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
    int open(const char* com,
        const char* module,
        const char* path,
        const char* file_name,
        int print_file,
        int print_screen,
        int log_level,
        int log_format,
        int max_line,
        int max_size);

    /*! @fn         int close();
     *  @brief      close log
     *  @return     int
     */
    int close();

    /*! @fn         int _add_log(int level, const char* fmt);
     *  @brief      adds one log record
     *  @param      int level: level for this log record
     *  @param      const char* fmt: format for print out
     *  @return     int
     */
    int _add_log(int level, const string& fmt);

private:

    /*! @fn         int init();
     *  @brief      initializes the log instance
     *  @return     int
     */
    int init();

    /*! @fn         int log(int level, const char* fmt);
     *  @brief      adds one log record
     *  @param      int level: level for this log record
     *  @param      const char* fmt: format for print out
     *  @return     int
     */
    int log(int level, const string& fmt);

    /*! @fn         int format_log_head(char* log_head, int level);
     *  @brief      adds one log record
     *  @param      char* log_head: log head buffer
     *  @param      int level: level for this log record
     *  @return     int
     */
	int format_log_head(char* log_head, int level);

    /*! @fn         void handle_print_file(const char* msg);
     *  @brief      adds one log record
     *  @param      const char* msg: log content
     *  @return     int
     */
	int handle_print_file(const char* msg);

private:

    std::ofstream                       m_ofstream;
    string                              m_com;                  //! current component name
    string                              m_module;               //! current module name
    static const int                    MAX_LOG_LINE = 102400;
    bool                                m_opened;               //! identify for component log instance
    char				                m_path[1024];           //! log path
    char				                m_filename[1024];       //! log file path
    int					                m_maxline;              //! max line number for one log file
    int					                m_maxsize;              //! max size for one log file
    int		                            m_log_level;
    unsigned int                        m_log_format;           //! log head format
    bool				                m_print_screen;         //! print screen
    bool				                m_print_file;           //! print file
    int					                m_cur_sn;               //! current file id
    int					                m_cur_year;             //! current date
    int					                m_cur_mon;
    int					                m_cur_mday;
    int					                m_cur_line;             //! current log line number
    int					                m_cur_size;             //! current log size
    static const char*                  m_com_log_level_desc[];
};

#endif //! _H_COM_LOG_IMPL_H_

