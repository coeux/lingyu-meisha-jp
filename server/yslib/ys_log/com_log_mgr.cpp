#include "com_log.h"
#include "com_log_mgr.h"
#include "com_log_impl.h"

com_log_mgr_t::com_log_mgr_t()
    : m_opened(false), m_max_num_modules(COM_MAX_MODULES), m_print_file(0), m_print_screen(0),
    m_log_level(0), m_log_format(0), m_max_line(0), m_max_size(0), m_work(m_io_service)
{}

com_log_mgr_t::~com_log_mgr_t()
{
    close();
}

int com_log_mgr_t::open(const vector<string>& coms,
    unsigned int max_num_modules,
    const string& path,
    const string& file,
    int print_file,
    int print_screen,
    int log_level,
    int log_format,
    int max_line,
    int max_size)
{
    if (m_opened)
    {
        return 0;
    }

    m_max_num_modules = max_num_modules;
    m_path = path;
    int len = m_path.length();
    if ('/' == m_path[len - 1])
    {
        m_path[len - 1] = '\0';
    }
    m_file = file;
    m_print_file = print_file;
    m_print_screen = print_screen;
    m_log_level = log_level;
    m_log_format = log_format;
    m_max_line = max_line;
    m_max_size = max_size;

    for (vector<string>::const_iterator it = coms.begin(); it != coms.end(); ++it)
    {
        m_com_logs.insert(std::make_pair(*it, module_log_map_t()));
    }

    if (check_log_conf())
    {
        return -1;
    }

    m_work_thread.reset(new boost::thread(boost::bind(&boost::asio::io_service::run, &m_io_service)));
    if (!m_work_thread.get())
    {
        cout<<"Failed to start component log thread and msg: "<<strerror(errno)<<endl;
        return -1;
    }

    m_opened = true;
    return 0;
}

int com_log_mgr_t::close()
{
    if (!m_opened)
    {
        return 0;
    }

    for (com_log_map_t::iterator com_it = m_com_logs.begin(); com_it != m_com_logs.end(); ++com_it)
    {
        for (module_log_map_t::iterator it = com_it->second.begin(); it != com_it->second.end(); ++it)
        {
            it->second->close();
            it->second.reset();
        }
    }
    m_com_logs.clear();
    m_opened = false;
    return 0;
}

int com_log_mgr_t::_add_log(const char* com, const char* module, const char* fmt, ...)
{
    if (!m_opened)
    {
        return -1;
    }

    if (m_com_logs.end() == m_com_logs.find(com))
    {
        return -1;  //! forbidden this component
    }

    char fmt_buffer[FORMAT_MAX_BUF_SIZE];
    va_list vl;
    va_start(vl, fmt);
    vsnprintf(fmt_buffer, sizeof(fmt_buffer), fmt, vl);
    int ret = add_log(com, module, fmt_buffer);
    va_end(vl);
    return ret;
}

int com_log_mgr_t::_add_log(const char* com, const char* module, int level, const char* fmt, ...)
{
    if (!m_opened)
    {
        return -1;
    }

    if (m_log_level >= level + 1)
    {
        if (m_com_logs.end() == m_com_logs.find(com))
        {
            return -1;  //! forbidden this component
        }

        char fmt_buffer[FORMAT_MAX_BUF_SIZE];
        va_list vl;
        va_start(vl, fmt);
        vsnprintf(fmt_buffer, sizeof(fmt_buffer), fmt, vl);
        int ret = add_log(com, module, level, fmt_buffer);
        va_end(vl);
        return ret;
    }

    return -1;
}

int com_log_mgr_t:: add_log(const string com, const string module, string fmt)
{
    m_io_service.post(boost::bind(&com_log_mgr_t::log, this, com, module, COM_EMPTY_LEVEL, fmt));
    return 0;
}

int com_log_mgr_t::add_log(const string com, const string module, int level, const string fmt)
{
    if (m_log_level >= level + 1)
    {
        m_io_service.post(boost::bind(&com_log_mgr_t::log, this, com, module, level, fmt));
        return 0;
    }
    return -1;
}

int com_log_mgr_t::log(const string& com, const string& module, int level, const string& fmt)
{
    com_log_map_t::iterator com_it = m_com_logs.find(com);
    if (com_it == m_com_logs.end())
    {
        return -1;  //! forbidden this component
    }

    module_log_map_t::iterator it = com_it->second.find(module);
    if (it == com_it->second.end())
    {
        if (m_max_num_modules <= com_it->second.size())
        {
            return -1; //! too much module instance
        }

        sp_com_log_t log_ptr(new com_log_impl_t());
        if (log_ptr->open(com.c_str(), module.c_str(), m_path.c_str(), m_file.c_str(), m_print_file, m_print_screen,
            m_log_level, m_log_format, m_max_line, m_max_size))
        {
            return -1;
        }
        com_it->second[module] = log_ptr;
    }

    return com_it->second[module]->_add_log(level, fmt);
}

int com_log_mgr_t::check_log_conf()
{
    if (m_print_file)
    {
        if (0 != access(m_path.c_str(), F_OK))    //! directory not exist
        {
            if (0 != mkdir(m_path.c_str(), 0777))
            {
                std::cout<<"com_log_mgr_t::check_log_conf() mkdir <"<<m_path<<"> failed and msg: "<< strerror(errno) <<std::endl;
                return -1;
            }
        }

        if (0 != access(m_path.c_str(), R_OK | W_OK))    //! check log path read and write permission
        {
            std::cout<<"com_log_mgr_t::check_log_conf() path <"<<m_path<<"> no read/write permission and msg: "<< strerror(errno) <<std::endl;
            return -1;
        }
    }

    return 0;
}

