#include "lg_gen_name.h"
#include "log.h"
#include "random.h"

#define LOG "GEN_NAME"

int lg_gen_name_t::init(const char* path_, const char* name_)
{
    m_names.clear();
    char fullpath[256] = {0};
    sprintf(fullpath, "%s/%s.txt", path_, name_);

    ifstream ifs;
    ifs.open(fullpath, ios::in);

    if (ifs)
    {
        string line;
        while(getline(ifs, line))
        {
            m_names.push_back(std::move(line.substr(0, line.size()-1)));
        }
        ifs.close();
        logwarn((LOG, "load:%s/%s.txt ok!size:%u", path_, name_, m_names.size()));
        return 0;
    }
    else
    {
        logerror((LOG, "read file failed!file:%s/%s.txt", path_, name_));
        return -1;
    }
}
string lg_gen_name_t::random_name()
{
    uint32_t r = random_t::rand_integer(0, m_names.size()-1);
    if (m_names.size() > r)
        return m_names[r];
    return "";
}
