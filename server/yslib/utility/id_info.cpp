
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <linux/if.h>

#include "id_info.h"
#include "md5_process.h"

static char info_plain_txt[1024] = "./info_plain.txt";
static char info_txt[1024] = "./info.txt";

int get_ip_addr(string& ip_str_)
{
    struct sockaddr_in sin;
    struct ifreq ifr;
    uint32_t ip_num = 0;
    char buf[64];
    size_t len = 0;

    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (-1 == sockfd)
    {
        return -1;
    }

    strcpy(ifr.ifr_name, "eth0");
    if (0 > ioctl(sockfd, SIOCGIFADDR, &ifr))
    {
        return -1;
    }

    memcpy(&sin, &ifr.ifr_addr, sizeof(sin));
    ip_num = sin.sin_addr.s_addr;

    len += snprintf(buf + len, sizeof(buf) - len, "%u.", ip_num & 0x000000FF);
    len += snprintf(buf + len, sizeof(buf) - len, "%u.", ip_num >> 8 & 0x000000FF);
    len += snprintf(buf + len, sizeof(buf) - len, "%u.", ip_num >> 16 & 0x000000FF);
    len += snprintf(buf + len, sizeof(buf) - len, "%u", ip_num >> 24 & 0x000000FF);
    ip_str_.append(buf);

    close(sockfd);
    return 0;
}

int init_for_get()
{
    string ip_str;
    if (get_ip_addr(ip_str))
    {
        return -1;
    }

    snprintf(info_plain_txt, sizeof(info_plain_txt), "./info_plain_%s.txt", ip_str.c_str());
    snprintf(info_txt, sizeof(info_txt), "./info_%s.txt", ip_str.c_str());

    return 0;
}

int get_mac_addr(string& mac_addr_)
{
    u_char addr[6];
    struct ifreq ifr;
    struct ifreq* ifr_ptr;
    struct ifconf ifc;
    char buf[1024];
    size_t len = 0;
    int flag = 0;

    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (-1 == sockfd)
    {
        return -1;
    }

    ifc.ifc_len = sizeof(buf);
    ifc.ifc_buf = buf;
    ioctl(sockfd, SIOCGIFCONF, &ifc);

    ifr_ptr = ifc.ifc_req;
    for (int i = ifc.ifc_len / sizeof(struct ifreq); --i >= 0; ++ifr_ptr)
    {
        strcpy(ifr.ifr_name, ifr_ptr->ifr_name);
        if (0 == ioctl(sockfd, SIOCGIFFLAGS, &ifr))
        {
            if (!(ifr.ifr_flags & IFF_LOOPBACK))
            {
                if (0 == ioctl(sockfd, SIOCGIFHWADDR, &ifr))
                {
                    flag = 1;
                    break;
                }
            }
        }
    }
    close(sockfd);

    if (flag)
    {
        bcopy(ifr.ifr_hwaddr.sa_data, addr, 6);
        for (int i = 0; i < 6; ++i)
        {
            len += snprintf(buf + len, sizeof(buf) - len, "%2.2x:", addr[i]);
        }
        mac_addr_.append(buf, strlen(buf) - 1);
    }
    else
    {
        return -1;
    }

    return 0;
}

int get_mac_id(string & mac_ids_md5_, bool need_dump_)
{
    string mac_addr;

    get_mac_addr(mac_addr);

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"Mac addr:\n";
        fout<<mac_addr;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(mac_addr, mac_ids_md5_);

    return 0;
}

int get_disk_id(string & disk_ids_md5_, bool need_dump_)
{
    string disk_ids;
    char buff[2048] = {0};

    system("ls /dev/disk/by-id/ > info_tmp.txt");

    ifstream fin("./info_tmp.txt");
    while (fin >> buff)
    {
        disk_ids.append(buff);
        disk_ids.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"Disk ids:\n";
        fout<<disk_ids;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(disk_ids, disk_ids_md5_);

    return 0;
}

int get_host_id(string & disk_host_, bool need_dump_)
{
    char buff[64] = {0};
    snprintf(buff, sizeof(buff), "%ld", gethostid());

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nHost id:\n";
        fout<<buff;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(buff, disk_host_);

    return 0;
}

int get_system_id(string & system_ids_md5_, bool need_dump_)
{
    string system_ids;
    char buff[2048] = {0};

    system("/usr/sbin/dmidecode --type 1 | grep \"Serial Number:\" > info_tmp.txt");

    ifstream fin("info_tmp.txt");
    while (fin >> buff)
    {
        system_ids.append(buff);
        system_ids.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nSystem id:\n";
        fout<<system_ids;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(system_ids, system_ids_md5_);

    return 0;
}

int get_system_uuid(string & system_uuid_md5_, bool need_dump_)
{
    string system_uuid;
    char buff[2048] = {0};

    system("/usr/sbin/dmidecode --type 1 | grep \"UUID\" > info_tmp.txt");

    ifstream fin("info_tmp.txt");
    while (fin >> buff)
    {
        system_uuid.append(buff);
        system_uuid.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nSystem uuid:\n";
        fout<<system_uuid;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(system_uuid, system_uuid_md5_);

    return 0;
}

int get_base_board_ids(string & base_board_ids_md5_, bool need_dump_)
{
    string ids;
    char buff[2048] = {0};

    system("/usr/sbin/dmidecode --type 2 | grep \"Serial Number:\" > info_tmp.txt");

    ifstream fin("info_tmp.txt");
    while (fin >> buff)
    {
        ids.append(buff);
        ids.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nbase board uuid:\n";
        fout<<ids;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(ids, base_board_ids_md5_);

    return 0;
}

int get_chassis_id(string & chassis_md5_, bool need_dump_)
{
    string ids;
    char buff[2048] = {0};

    system("/usr/sbin/dmidecode --type 3 | grep \"Serial Number:\" > info_tmp.txt");

    ifstream fin("info_tmp.txt");
    while (fin >> buff)
    {
        ids.append(buff);
        ids.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nchassis id:\n";
        fout<<ids;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(ids, chassis_md5_);

    return 0;
}

int get_memory_id(string & memory_ids_md5_, bool need_dump_)
{
    string memory_ids;
    char buff[2048] = {0};

    system("/usr/sbin/dmidecode --type 17 | grep \"Serial Number:\" > info_tmp.txt");

    ifstream fin("info_tmp.txt");
    while (fin >> buff)
    {
        memory_ids.append(buff);
        memory_ids.append("  ");
        memset(buff, 0, sizeof(buff));
    }

    if (need_dump_)
    {
        ofstream fout(info_plain_txt, ios::app);
        fout<<"\nMemory ids:\n";
        fout<<memory_ids;
        fout<<"\r\n";
        fout.flush();
        fout.close();
    }

    md5_process(memory_ids, memory_ids_md5_);

    return 0;
}

int get_server_ids_for_check(string& id_info)
{
    system("rm -rf ./info_tmp.txt");

    get_mac_id(id_info);
    id_info.append("-");
    get_disk_id(id_info);
    id_info.append("-");
    get_system_id(id_info);
    id_info.append("-");
    get_memory_id(id_info);
    //id_info.append("-");
    //get_host_id(id_info);
    id_info.append("-");
    get_system_uuid(id_info);
    id_info.append("-");
    get_base_board_ids(id_info);
    id_info.append("-");
    get_chassis_id(id_info);

    system("rm -rf ./info_tmp.txt");

    return 0;
}

int get_server_ids_for_get()
{
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "rm -rf %s", info_plain_txt);
    system(cmd);
    system("rm -rf ./info_tmp.txt");
    snprintf(cmd, sizeof(cmd), "rm -rf %s", info_txt);
    system(cmd);

    string ids;

    get_mac_id(ids, true);
    ids.append("-");
    get_disk_id(ids, true);
    ids.append("-");
    get_system_id(ids, true);
    ids.append("-");
    get_memory_id(ids, true);
    //ids.append("-");
    //get_host_id(ids, true);
    ids.append("-");
    get_system_uuid(ids, true);
    ids.append("-");
    get_base_board_ids(ids, true);
    ids.append("-");
    get_chassis_id(ids, true);

    ofstream fout(info_txt);
    fout<<ids;
    fout.flush();
    fout.close();

    system("rm -rf ./info_tmp.txt");

    return 0;
}

