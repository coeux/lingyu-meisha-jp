
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "com_log.h"
#include "com_log_impl.h"

const char* com_log_impl_t::m_com_log_level_desc[] =
{
    "FATAL",
    "ERROR",
    "WARN ",
    "INFO ",
    "TRACE",
    "DEBUG"
};

com_log_impl_t::com_log_impl_t()
{
	m_opened = false;
	memset(m_path, 0, sizeof(m_path));
	memset(m_filename, 0, sizeof(m_filename));
	m_maxline = 50000;	 //default 50000 lines
	m_maxsize = 1024000; //default 100M
	m_log_level = 0;
    m_log_format = 0;
	m_print_screen = false;
	m_print_file = false;
	m_cur_year = 0;
	m_cur_mon = 0;
	m_cur_mday = 0;
	m_cur_sn = 0;
	m_cur_line = 0;
	m_cur_size = 0;
}

com_log_impl_t::~com_log_impl_t()
{
	close();
}

int com_log_impl_t::open(const char* com,
        const char* module,
        const char* path,
        const char* file_name,
        int print_file,
        int print_screen,
        int log_level,
        int log_format,
        int max_line,
        int max_size)
{
    if(m_opened)
    {
        return 0;
    }

    m_com = com;
    m_module = module;
    strcpy(m_path, path);
    int len = strlen(m_path);
    if ('/' == m_path[len - 1])
    {
        m_path[len - 1] = '\0';
    }
    strcpy(m_filename, file_name);
    m_print_file = print_file;
    m_print_screen = print_screen;
    m_log_level = log_level;
    m_log_format = log_format;
    m_maxline = max_line;
    m_maxsize = max_size;

    return init();
}

int com_log_impl_t::close()
{
    if(!m_opened)
    {
        return 0;
    }

    m_ofstream.close();
    m_ofstream.clear();
    return 0;
}

int com_log_impl_t::_add_log(int level, const string& fmt)
{
    if(!m_opened)
    {
        return -1;
    }

    if (m_log_level < level + 1)    // log level too low
    {
        return -1;
    }

    return log(level, fmt);
}

int com_log_impl_t::init()
{
    time_t time = ::time(NULL);
    struct tm tm;
    localtime_r(&time, &tm);

    m_cur_year = tm.tm_year;
    m_cur_mon = tm.tm_mon;
    m_cur_mday = tm.tm_mday;
    m_cur_sn = 0;
    m_cur_line = 0;
    m_cur_size = 0;

    if (m_print_file)
    {
        if (0 != access(m_path, F_OK))    //! directory not exist
        {
            if (0 != mkdir(m_path, 0777))
            {
                std::cout<<"com_log_impl_t::init() mkdir <"<<m_path<<"> failed: "<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        //! creates sub path for component
        size_t path_len = strlen(m_path);
        snprintf(m_path + path_len, sizeof(m_path) - path_len, "/%s", m_com.c_str());
        path_len = strlen(m_path);
        if ('/' == m_path[path_len - 1])
        {
            m_path[path_len - 1] = '\0';
        }
        if (0 != access(m_path, F_OK))    //! directory not exist
        {
            if (0 != mkdir(m_path, 0777))
            {
                std::cout<<"com_log_impl_t::init() mkdir <"<<m_path<<"> failed: "<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        //! creates sub path for module
        path_len = strlen(m_path);
        snprintf(m_path + path_len, sizeof(m_path) - path_len, "/%s", m_module.c_str());
        path_len = strlen(m_path);
        if ('/' == m_path[path_len - 1])
        {
            m_path[path_len - 1] = '\0';
        }
        if (0 != access(m_path, F_OK))    //! directory not exist
        {
            if (0 != mkdir(m_path, 0777))
            {
                std::cout<<"com_log_impl_t::init() mkdir <"<<m_path<<"> failed: "<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        char file[1024];
        snprintf(file, sizeof(file), "%s/%d-%d-%d", m_path, m_cur_year + 1900, m_cur_mon + 1, m_cur_mday);
        if (0 != access(file, F_OK))
        {
            if (0 != mkdir(file, 0777))
            {
                std::cout<<"com_log_impl_t::init() mkdir <"<<m_path<<"> failed: "<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        while (true)
        {
            sprintf(file, "%s/%d-%d-%d/%s.%d", m_path, m_cur_year + 1900, m_cur_mon + 1, m_cur_mday, m_filename, m_cur_sn);
            if (0 == access(file, F_OK))
            {
                m_cur_sn++;
                continue;
            }
            break;
        }

        m_ofstream.open(file);
    }

    m_opened = true;
    return 0;
}

int com_log_impl_t::log(int level, const string& fmt)
{
    char log_record[MAX_LOG_LINE];
    memset(log_record, 0, sizeof(log_record));

    format_log_head(log_record, level);

    size_t len = strlen(log_record);
    size_t append_len = fmt.length();
    if (append_len > sizeof(log_record) - len - 1)
    {
        append_len = sizeof(log_record) - len - 1;
    }

    memcpy(log_record + len, fmt.c_str(), append_len);
    log_record[len + append_len] = 0;

    if (m_print_screen)
    {
        std::cout<<log_record;
    }
    if(m_print_file)
    {
        handle_print_file(log_record);
    }

    return 0;
}

int com_log_impl_t::format_log_head(char* log_head, int level)
{
    struct tm tm;
    size_t written_len = 0;
    time_t time = ::time(NULL);
    localtime_r(&time, &tm);

    if (m_log_format & COM_LOG_FMT_DATE)
    {
        written_len += snprintf(log_head + written_len, MAX_LOG_LINE - written_len - 1, "%04d%02d%02d ",
            tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
    }
    if (m_log_format & COM_LOG_FMT_TIME)
    {
        struct timeval timeval;
        gettimeofday(&timeval, NULL);
        written_len += snprintf(log_head + written_len, MAX_LOG_LINE - written_len - 1, "%02d:%02d:%02d.%06ld ",
            tm.tm_hour, tm.tm_min, tm.tm_sec, timeval.tv_usec);
    }
    if (COM_EMPTY_LEVEL != level && m_log_format & COM_LOG_FMT_LEVEL)
    {
        written_len += snprintf(log_head + written_len, MAX_LOG_LINE - written_len - 1, "%s ",
            m_com_log_level_desc[level]);
    }
    if (m_log_format & COM_LOG_FMT_COM)
    {
        written_len += snprintf(log_head + written_len, MAX_LOG_LINE - written_len - 1, "[%s] ",
            m_com.c_str());
    }
    if (m_log_format & COM_LOG_FMT_MODULE)
    {
        written_len += snprintf(log_head + written_len, MAX_LOG_LINE - written_len - 1, "[%s] ",
            m_module.c_str());
    }

	return 0;
}

int com_log_impl_t::handle_print_file(const char* msg)
{
	time_t time = ::time(NULL);
	struct tm tm;
    localtime_r(&time, &tm); //TODO deadline to modify time by several second

	// if date changed, create a new folder
	if ((m_cur_year != tm.tm_year) || (m_cur_mon != tm.tm_mon) || (m_cur_mday != tm.tm_mday))
	{
        m_ofstream.close();
        m_ofstream.clear();

		m_cur_year = tm.tm_year;
		m_cur_mon = tm.tm_mon;
		m_cur_mday = tm.tm_mday;
		m_cur_sn = 0;
		m_cur_line = 0;
		m_cur_size = 0;

		char file[1024];
        sprintf(file, "%s/%d-%d-%d", m_path, m_cur_year + 1900, m_cur_mon + 1, m_cur_mday);
        if (0 != access(file, F_OK))
        {
            if (0 != mkdir(file, 0777))
            {
                std::cout<<"CComLog::handle_print_file() mkdir <"<<m_path<<"> failed:"<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        while (true)
        {
            sprintf(file, "%s/%d-%d-%d/%s.%d", m_path, m_cur_year + 1900, m_cur_mon + 1, m_cur_mday, m_filename, m_cur_sn);
            if (0 == access(file, F_OK))
            {
                m_cur_sn++;
                continue;
            }
            break;
        }

		m_ofstream.open(file);
	}

	m_ofstream<<msg;
	m_ofstream.flush();
    m_cur_line += 1;
    m_cur_size += strlen(msg);

	// if line or filesie limit reached, create a new file
	if ((m_cur_line >= m_maxline) || (m_cur_size > m_maxsize))
	{
        m_ofstream.close();
        m_ofstream.clear();

		m_cur_sn++;
		m_cur_line = 0;
		m_cur_size = 0;

		char file[1024];
		sprintf(file, "%s/%d-%d-%d/%s.%d", m_path, m_cur_year + 1900, m_cur_mon + 1, m_cur_mday, m_filename, m_cur_sn);
		m_ofstream.open(file);
	}

    return 0;
}

