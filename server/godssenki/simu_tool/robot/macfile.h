#ifndef _macfile_h_
#define _macfile_h_

#include <stdio.h>
#include <fstream>
#include <iostream>
#include <string>
using namespace std;

#include "id_assign.h"
#include "singleton.h"

class mac_file_t
{
public:
    vector<string> mac_list;
    string path;

    bool load(const string& path_)
    {
        path = path_;
        mac_list.clear();

        ifstream in(path.c_str());
        if(!in)
            return false;

        string str;
        while(getline(in, str))
        {
            mac_list.push_back(str);
        }
                                                                                                    }
        return true;
    }

    void write(const string& mac_)
    {
        FILE* fp = fopen(mac_.c_str(), "a");
        fprintf( fp, "%s\n", mac_.c_str() );
        fclose(fp);
    }

    void gen_mac(uint16_t hostnum_, int n_)
    {
        mac_list.clear();
        for(int i=0; i<n_; i++)
        {
            uint64_t id = gen_id();
            string mac = std::to_string(id);
            mac = "robot"+mac;
        }
    }

    uint64_t gen_id(uint16_t hostnum_)
    {
        return id_assign.new_id((uint16_t)hostnum_);
    }
};

#define mac_file (singleton_t<mac_file_t>::instance())

#endif
