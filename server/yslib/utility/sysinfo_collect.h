#ifndef _sysinfo_collet_h_
#define _sysinfo_collet_h_

#include "singleton.h"
#include <string>
using namespace std;

class sysinfo_collect_t
{
    struct CPU_OCCUPY//定义一个cpu occupy的结构体
    {
        char name[20];      //定义一个char类型的数组名name有20个元素
        unsigned int user; //定义一个无符号的int类型的user
        unsigned int nice; //定义一个无符号的int类型的nice
        unsigned int system;//定义一个无符号的int类型的system
        unsigned int idle; //定义一个无符号的int类型的idle
    };

    struct MEM_OCCUPY //定义一个mem occupy的结构体
    {
        char name[20];      //定义一个char类型的数组名name有20个元素
        unsigned long total; 
        char name2[20];
        unsigned long free;
    };

    void get_memoccupy (MEM_OCCUPY *mem) //对无类型get函数含有一个形参结构体类弄的指针O
    {
        FILE *fd;          
        char buff[256];   
        MEM_OCCUPY *m;
        m=mem;

        fd = fopen ("/proc/meminfo", "r"); 

        fgets (buff, sizeof(buff), fd); 
        sscanf (buff, "%s %lu %s", m->name, &m->total, m->name2); 
        fgets (buff, sizeof(buff), fd); 
        sscanf (buff, "%s %lu %s", m->name2, &m->free, m->name2); 

        fclose(fd);     //关闭文件fd
    }

    float cal_cpuoccupy (CPU_OCCUPY *o, CPU_OCCUPY *n) 
    {   
        float cpu_use = 0;   

        unsigned long total1 = (unsigned long) (o->user + o->nice + o->system +o->idle);
        unsigned long total2 = (unsigned long) (n->user + n->nice + n->system +n->idle);

        unsigned used1 = o->user + o->nice + o->system;
        unsigned used2 = n->user + n->nice + n->system;

        if((total2-total1) != 0)
            cpu_use = ((float)(used2-used1))/(total2-total1); //((用户+系统)*100)除(第一次和第二次的时间差)再赋给cpu_used

        return cpu_use;
    }

    void get_cpuoccupy (CPU_OCCUPY *cpust) //对无类型                                    
    {
        FILE *fd;         
        char buff[256]; 

        fd = fopen ("/proc/stat", "r"); 
        fgets (buff, sizeof(buff), fd);
        sscanf (buff, "%s %u %u %u %u", cpust->name, &cpust->user, &cpust->nice, &cpust->system, &cpust->idle);
        fclose(fd);    
    }

public:
    void begin()
    {
        //获取cpu使用情况
        get_cpuoccupy((CPU_OCCUPY *)&cpu_stat1);
    } 

    void end(float& cpu_, float& mem_)
    {
        //获取cpu使用情况
        get_cpuoccupy((CPU_OCCUPY *)&cpu_stat2);
        //获取内存
        get_memoccupy ((MEM_OCCUPY *)&mem_stat);
        mem_ = ((float)(mem_stat.total-mem_stat.free) / mem_stat.total);
        //计算cpu使用率
        cpu_ = cal_cpuoccupy ((CPU_OCCUPY *)&cpu_stat1, (CPU_OCCUPY *)&cpu_stat2);
    }

private:
    CPU_OCCUPY cpu_stat1;
    CPU_OCCUPY cpu_stat2;
    MEM_OCCUPY mem_stat;
};

#define sysinfo_collect (singleton_t<sysinfo_collect_t>::instance())

#endif
