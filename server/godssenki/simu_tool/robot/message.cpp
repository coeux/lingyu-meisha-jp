#include "message.h"
#include <sys/types.h> 
#include <sys/stat.h>
#include <unistd.h>

msg_cache_t::msg_cache_t()
{
}

bool msg_cache_t::load(const string& path_)
{
    char body[10240];
    FILE* file = fopen(path_.c_str(), "rb");
    if (file == NULL)
    {
        printf("read file:%s failed!", path_.c_str());
        return false;
    }

    uint32_t total_len = 0;
    fseek(file, 0L, SEEK_END);  
    total_len = ftell(file); 
    fseek(file, 0L, SEEK_SET);  

    int len=0,cmd=0,res=0;
    while( total_len > 0 )
    {
        fread(&len, 4, 1, file);
        fread(&cmd, 2, 1, file);
        fread(&res, 2, 1, file);
        if (len > 0)
        {
            fread(body, len, 1, file);
            msg m(cmd,body);
            m_vec_msgs.push_back(std::move(m));
        }
        else
        {
            msg m(cmd,"");
            m_vec_msgs.push_back(std::move(m));
        }
        total_len -= (8+len);
    }
    fclose(file);
    return true;
}

string msg_cache_t::get_body(int32_t pos_)
{
    if (pos_>=0 && pos_<(int)m_vec_msgs.size() )
        return m_vec_msgs[pos_].body;
    return "";
}
int msg_cache_t::get_cmd(int32_t pos_)
{
    if (pos_>=0 && pos_<(int)m_vec_msgs.size() )
        return m_vec_msgs[pos_].cmd;
    return -1;
}

