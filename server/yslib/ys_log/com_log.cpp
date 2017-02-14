
#include "com_log.h"

int init_comlog(const vector<string>& coms,
        unsigned int max_num_modules,
        const string& path,
        const string& file,
        const int print_file,
        const int print_screen,
        const int log_level,
        const int log_format,
        const int max_line,
        const int max_size)
{
    return singleton_t<com_log_mgr_t>::instance().open(coms, max_num_modules, path, file, print_file,
        print_screen, log_level, log_format, max_line, max_size);
}

int init_comlog(const string& coms,
        unsigned int max_num_modules,
        const string& path,
        const string& file,
        const int print_file,
        const int print_screen,
        const int log_level,
        const int log_format,
        const int max_line,
        const int max_size)
{
    return init_comlog(parse_log_module(coms), max_num_modules, path, file, print_file,
        print_screen, log_level, log_format, max_line, max_size);
}

static string trim(const string& str, char c_)
{
    string::size_type pos = str.find_first_not_of(c_);
    if (pos == string::npos)
    {
        return str;
    }
    string::size_type pos2 = str.find_last_not_of(c_);
    if (pos2 != string::npos)
    {
        return str.substr(pos, pos2 - pos + 1);
    }
    return str.substr(pos);
}

static vector<std::string> trim_str(const string& mod_str)
{
    vector<std::string> vt;
    if (mod_str.empty())
    {
        return vt;
    }

    string::size_type pos_begin = 0;
    while (pos_begin != string::npos)
    {
        string tmp;
        string::size_type n = pos_begin;
        string::size_type comma_pos = mod_str.find(' ', n);
        if (comma_pos != string::npos)
        {
            tmp = mod_str.substr(pos_begin, comma_pos - pos_begin);
            pos_begin = comma_pos + 1;
        }
        else
        {
            tmp = mod_str.substr(pos_begin);
            pos_begin = comma_pos;
        }

        if (false == tmp.empty())
        {
            if (tmp[0] != '#')
            {
                vt.push_back(tmp);
            }
        }
    }

    return vt;
}


vector<std::string> parse_log_module(const string& mod_str)
{
    vector<std::string>  comma_modules;

    //! parse string, ',' as token
    //! trim_str parse str, trim first, if has '#'  falg, ignore this module name

    if (false == mod_str.empty())
    {
        string::size_type pos_begin = mod_str.find_first_not_of(',');
        while (pos_begin != string::npos)
        {
            string tmp;
            string::size_type comma_pos = mod_str.find(',', pos_begin);
            if (comma_pos != string::npos)
            {
                tmp = mod_str.substr(pos_begin, comma_pos - pos_begin);
                pos_begin = comma_pos + 1;
            }
            else
            {
                tmp = mod_str.substr(pos_begin);
                pos_begin = comma_pos;
            }
            tmp = trim(tmp, (char)10);
            tmp = trim(tmp, (char)32);
            comma_modules.push_back(tmp);
        }
    }

    /*
    for(size_t n=0; n<comma_modules.size(); n++)
    {
        for(size_t i=0; i<comma_modules[n].size(); i++)
        {
            printf("%d", comma_modules[n][i]);
        }
        cout << "size:" << comma_modules[n].size() << ","<< comma_modules[n]<< endl;
    }
    */
    return comma_modules;
}
