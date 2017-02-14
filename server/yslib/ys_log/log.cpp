
#include "log.h"

int init_log(const std::string& path,
			 const std::string& file,
			 const int	flag_print_file,
			 const int	flag_print_screen,
			 const int  flag_log_level,
			 const std::vector<std::string>& modules,
			 const int  max_line,
			 const int  maz_size)
{
	singleton_t<log_t>::instance().set_path(path.c_str());
	singleton_t<log_t>::instance().set_filename(file.c_str());
	singleton_t<log_t>::instance().set_maxline(max_line);
	singleton_t<log_t>::instance().set_maxsize(maz_size);
	if(flag_print_file)	singleton_t<log_t>::instance().enable_print_file(true);	
	if(flag_print_screen)	singleton_t<log_t>::instance().enable_print_screen(true);
	if( flag_log_level >=1 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_FATAL), true);
	if( flag_log_level >=2 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_ERROR), true);
	if( flag_log_level >=3 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_WARN), true);
	if( flag_log_level >=4 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_INFO), true);
	if( flag_log_level >=5 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_TRACE), true);
	if( flag_log_level >=6 ) singleton_t<log_t>::instance().enable_log_level(LOG_FLAG(LF_DEBUG), true);
	for(std::size_t i = 0 ; i < modules.size() ; i++)
	{
		singleton_t<log_t>::instance().enable_log_module(modules[i].c_str(), true);
	}
	return singleton_t<log_t>::instance().open();
}

int init_log(const std::string& path,
			 const std::string& file,
			 const int	flag_print_file,
			 const int	flag_print_screen,
			 const int  flag_log_level,
			 const std::string& mod_str,
			 const int  max_line,
			 const int  maz_size)
{
    

    return init_log(path, file, flag_print_file, flag_print_screen, flag_log_level, parse_log_module(mod_str), max_line, maz_size);
}

void close_log()
{
	singleton_t<log_t>::instance().close();
}

void log_screen_open(bool isok_)
{
	singleton_t<log_t>::instance().enable_print_screen(isok_);	
}
