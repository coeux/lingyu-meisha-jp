#ifndef _repo_h_
#define _repo_h_

#include <stdio.h>
#include <unordered_map>
using namespace __gnu_cxx;
using namespace std;

#include "jserialize_macro.h"
#include "log.h"
#include "singleton.h"

#include <boost/bind.hpp>

#define IS_REPO_ARRAY_EMPTY(arr) ((arr).size()<=1)

typedef boost::function<void()> cb_loaded_t;
struct repo_i
{
    virtual bool reload(const string& path_) = 0;
    cb_loaded_t cb_loaded;
};

template<class T>
struct repo_t : public repo_i, unordered_map<int, T> 
{
    const char* LOG = "REPO";

    struct holder_t
    {
        map<string, T> contain;
        JSON1(holder_t, contain)
    };

    string str_json; 

    bool reload(const string& path_)
    {
        string json;
        FILE* file = fopen(path_.c_str(), "rb");
        if (file)
        {
            char buf[256] = {0};
            int readlen = 0;
            while((readlen = fread(buf, 1, sizeof(buf), file)))
            {
                json.append(buf, readlen);
            }
            if (readlen == -1)
            {
                logerror((LOG, "read file failed!file:%s", path_.c_str()));
            }
            fclose(file);

            holder_t holder;
            holder << json;

            this->clear();
            for(auto it=holder.contain.begin(); it!=holder.contain.end(); it++)
            {
                this->insert(make_pair(atoi(it->first.c_str()), it->second));
            }
            logwarn((LOG, "load repo:%s ok!repo size:%u", path_.c_str(), this->size()));

            str_json = json; 

            return true;
        }
        return false;
    }

    bool load(const char* path_, const char* name_)
    {
        char fullpath[256] = {0};
        sprintf(fullpath, "%s/%s.json", path_, name_);
        return reload(fullpath);
    }

    T* get(int32_t id_) {
        auto it = this->find(id_);
        if (it != this->end())
            return &it->second;
        return NULL;
    }
};

#endif
