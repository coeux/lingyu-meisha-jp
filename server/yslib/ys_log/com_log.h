/*! @ingroup    BASE_LIB
 *  @file       com_log.h
 *  @author     congjun.chang@fminutes.com
 *  @brief      this files defines component log interface
 *  @details    it provides following operation:
 *              1. initialize the special component/components log
 *              2. add one record log
 */

#ifndef _COM_LOG_H_
#define _COM_LOG_H_

#include <map>
#include <vector>
#include <string>
using namespace std;

#include "singleton.h"
#include "com_log_mgr.h"

enum EComLogLevel
{
    CLL_FATAL = 0,
    CLL_ERROR = 1,
    CLL_WARN = 2,
    CLL_INFO = 3,
    CLL_TRACE = 4,
    CLL_DEBUG = 5,
    CLL_ALL = 6
};

//! defines log head format and custom it when opening log
#define COM_LOG_FMT_NON     0X00000000      //! empty log head
#define COM_LOG_FMT_DATE    0X00000001      //! date 20100526
#define COM_LOG_FMT_TIME    0X00000002      //! time 11:06:15
#define COM_LOG_FMT_LEVEL   0X00000004      //! level description ERROR
#define COM_LOG_FMT_COM     0X00000008      //! component description COM_SYS
#define COM_LOG_FMT_MODULE  0X00000010      //! component description HOST_1

#define COM_LOG_FMT_DEFAULT COM_LOG_FMT_DATE | COM_LOG_FMT_TIME

//! default component
#define COM_SYS                 "COM_SYS"
#define COM_DB_LOST             "COM_DB_LOST"
#define COM_SQL_ERROR           "COM_SQL_ERROR"
#define COM_MIDWARE_JSON_ERR    "COM_MIDWARE_JSON_ERR"
//! monitor component log
#define COM_MNT                 "COM_MNT"
//! performance component log
#define COM_PERF                "COM_PERF"
#define COM_CONNECTION_MGR      "COM_CONNECTION_MGR"

#define COM_EMPTY_LEVEL -1          //! empty level and must can be print out
#define COM_MAX_MODULES 128         //! the max module number for one component
#define COM_DEFAULT_MODULE "main"   //! default module for every component

#define ENABLE_COM_LOG              //! identify whether open compoent log

/*! @fn         int init_comlog();
 *  @brief      initializes component log
 *  @return     int
 */
vector<std::string> parse_log_module(const string& mod_str);

int init_comlog(const vector<string>& coms,             //! all components
        unsigned int max_num_modules,                   //! the max module number for every componet
        const string& path,                             //! log path
        const string& file,                             //! log file name
        int print_file,                                 //! flag for print to file
        int print_screen,                               //! flag for print to screen
        int log_level,                                  //! log level
        int log_format = COM_LOG_FMT_DEFAULT,           //! log head format
        int max_line = 100000,                          //! file max line number
        int max_size = 5000000);                        //! file max charactor number

int init_comlog(const string& coms,             //! all components
        unsigned int max_num_modules,                   //! the max module number for every componet
        const string& path,                             //! log path
        const string& file,                             //! log file name
        int print_file,                                 //! flag for print to file
        int print_screen,                               //! flag for print to screen
        int log_level,                                  //! log level
        int log_format = COM_LOG_FMT_DEFAULT,           //! log head format
        int max_line = 100000,                          //! file max line number
        int max_size = 5000000);                        //! file max charactor number

/*! @fn         int logcom(const char* com, const char* module, EComLogLevel level, const char* fmt, ...);
 *  @param      const char* com: component name
 *  @param      const char* module: sub module name
 *  @param      EComLogLevel level: log level
 *  @param      const char* fmt: format string
 *  @param      ...: format print out
 *  @brief      adds one record log
 *  @return     int
 *  @Usage
 *              int logcom((const char* com, const char* module, const char* fmt, ...));
 *              int logcom((const char* com, const char* module, EComLogLevel level, const char* fmt, ...));
 *  @notes      fmt must be append "\n" to start one new line and example:
 *              addLog((COM_SQL_ERROR, "DB_202", CLL_ERROR, "%s\n", sql));
 */

#ifdef ENABLE_COM_LOG
#define logcom(args) singleton_t<com_log_mgr_t>::instance()._add_log args
#else
#define logcom(args) {}
#endif



#endif //! _COM_LOG_H_

