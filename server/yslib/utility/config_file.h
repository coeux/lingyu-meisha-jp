#ifndef _CONFIGFILE_H_
#define _CONFIGFILE_H_

#include <map>
#include <vector>
#include <string>
#include <cstdlib>
#include <fstream>
#include <iostream>
using namespace std;

typedef vector<string> str_vec_t;

class config_file_t
{
public:

    config_file_t()
    {}

    int load(const string& filename_)
    {
        ifstream file(filename_.c_str());
        if(!file)
        {
            cerr << filename_ <<" is not exist"<<endl;
            return -1;
        }
        char line[2048] = { 0 };

        cout<<" --------------------------------------- Config File Begin --------------------------------------- \n";

        string content;
        while (!file.eof())
        {
            content.clear();
            file.getline(line, 500);
            if (false == file.good())
            {
                break;
            }
            content = line;
            if(content.empty())
            {
                continue;
            }

            if (content[0] == '#')
            {
                continue;
            }

            int pos = content.find(":");
            if(pos > 0)
            {
                cout<<content.substr(0, pos)<<"  <=>  ";
                cout<<content.substr(pos+1 ,content.length() - pos - 1)<<endl;
                m_config_map[content.substr(0, pos)].push_back(content.substr(pos+1, content.length() - pos - 1));
            }
        }

        std::cout<<" --------------------------------------- Config File End --------------------------------------- \n\n";

        return 0;
    }

    const str_vec_t& get(const string& index_)
    {
        return m_config_map[index_];
    }

private:

    map<string, str_vec_t> m_config_map;
};

#define GET_CONFIG_FILE(x) singleton_t<config_file_t>::instance().get(x)

#endif  //! _CONFIGFILE_H_

