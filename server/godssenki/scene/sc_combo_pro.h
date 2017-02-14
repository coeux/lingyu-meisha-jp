#ifndef _sc_combo_pro_h_
#define _sc_combo_pro_h_

#include "db_ext.h"
#include "msg_def.h"

using namespace std;

class sc_user_t;
class sc_combo_pro_t
{
public:
    db_ComboPro_ext_t db;
public:
    sc_combo_pro_t(sc_user_t& user_);
    void save_db();
    void load_db();
    void init_new_user();
    // 开启
    int32_t open(int32_t type_id_);
    // 增加经验
    int32_t add_exp(int32_t type_id_);
    // 升级
    int32_t check_compose(int32_t type_id_);
public:
    void get_combo_pro(sc_msg_def::jpk_combo_pro_view_t& view_);
    void get_user_info(sc_msg_def::jpk_combo_pro_t &jpk_);
private:
    sc_user_t& m_user;
};

#endif
