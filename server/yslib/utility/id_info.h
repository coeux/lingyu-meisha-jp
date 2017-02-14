
#ifndef _ID_INFO_H_
#define _ID_INFO_H_

#include <string>
#include <fstream>
#include <iostream>
using namespace std;

int get_ip_addr(string& ip_str_);

int init_for_get();

int get_mac_addr(string& mac_addr_);

int get_mac_id(string & mac_ids_md5_, bool need_dump_ = false);

int get_disk_id(string & disk_ids_md5_, bool need_dump_ = false);

int get_host_id(string & disk_host_, bool need_dump_ = false);

int get_system_id(string & system_ids_md5_, bool need_dump_ = false);

int get_system_uuid(string & system_uuid_md5_, bool need_dump_ = false);

int get_base_board_ids(string & base_board_ids_md5_, bool need_dump_ = false);

int get_chassis_id(string & chassis_md5_, bool need_dump_ = false);

int get_memory_id(string & memory_ids_md5_, bool need_dump_ = false);

int get_server_ids_for_check(string& id_info);

int get_server_ids_for_get();

#endif //! _ID_INFO_H_

