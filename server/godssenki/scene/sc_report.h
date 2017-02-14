#ifndef _sc_report_h_
#define _sc_report_h_

#include "db_ext.h"
#include "msg_def.h"

using namespace std;

class sc_user_t;
class sc_report_t
{
public:
    db_ReportUser_ext_t db;
    /* soul */
public:
    sc_report_t(sc_user_t& user_);
    void save_db();
    void load_db();
    void init_new_user();
    // 获得举报信息
    int32_t get_info();
    // 开始举报
    int32_t reportuser(int32_t uid_);
private:
    sc_user_t& m_user;
};

#endif
