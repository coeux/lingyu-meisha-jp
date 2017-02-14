#include "message.h"

msg_cache_t::msg_cache_t()
{
    char path[] = "/tmp/rec_msg/6787.rec";
    char body[10240];
    FILE* file = fopen(path, "rb");
    if (file == NULL)
    {
        printf("read file:%s failed!", path);
        return;
    }
    int len=0,cmd=0,res=0;
    fread(&len, 4, 1, file);

    while( len>0 )
    {
        fread(&cmd, 2, 1, file);
        fread(&res, 2, 1, file);
        fread(body, len, 1, file);
        body[len] = 0;
        fread(&len, 4, 1, file);

        msg m(cmd,body);
        m_vec_msgs.push_back(std::move(m));
    }
    fclose(file);
}

void msg_cache_t::print()
{
    for(auto it=m_vec_msgs.begin();it!=m_vec_msgs.end();++it)
    {
        printf("%d\n",it->cmd);
        printf("%s\n",it->body.c_str());
    }
}
string msg_cache_t::get_body(int32_t pos_)
{
    return m_vec_msgs[pos_].body;
}
int msg_cache_t::get_cmd(int32_t pos_)
{
    if (pos_>=0 && pos_<(int32_t)m_vec_msgs.size() )
        return m_vec_msgs[pos_].cmd;
    return -1;
}

