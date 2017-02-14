#include "sc_combo_pro.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_statics.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include "date_helper.h"
#include "sc_server.h"

#define LOG "SC_COMBO_PRO"
#define EXP_PER_LEVEL(level) level*0+10
sc_combo_pro_t::sc_combo_pro_t(sc_user_t& user_)
:m_user(user_)
{
}

void
sc_combo_pro_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void
sc_combo_pro_t::load_db()
{
    sql_result_t res;
    if (0 == db_ComboPro_t::sync_select_all(m_user.db.uid, res))
    {
        db.init(*res.get_row_at(0));
    }
    else
    {
        init_new_user();
    }
}

void
sc_combo_pro_t::init_new_user()
{
    db.uid = m_user.db.uid;
    db.o1 = -1;
    db.o2 = -1;
    db.o3 = -1;
    db.o4 = -1;
    db.o5 = -1;
    db.exp1 = 0;
    db.exp2 = 0;
    db.exp3 = 0;
    db.exp4 = 0;
    db.exp5 = 0;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_ComboPro_t& db_) {
        db_.insert();
    }, db.data());
}

int32_t
sc_combo_pro_t::open(int32_t type_id_)
{
    sc_msg_def::nt_combo_pro_attribute_change nt;
    nt.attribute_id = type_id_;
    nt.value = 0;
    switch(type_id_)
    {
    case 1:
        db.o1 = 0;
        db.set_o1(0);
        break;
    case 2:
        db.o2 = 0;
        db.set_o2(0);
        break;
    case 3:
        db.o3 = 0;
        db.set_o3(0);
        break;
    case 4:
        db.o4 = 0;
        db.set_o4(0);
        break;
    case 5:
        db.o5 = 0;
        db.set_o5(0);
        break;
    default:
        return ERROR_COMBOPRO_NO_SUCH_TYPE;
    }
    save_db();
    logic.unicast(m_user.db.uid, nt);
    return SUCCESS;
}

int32_t
sc_combo_pro_t::add_exp(int32_t type_id_)
{
    int32_t level_array[5];
    level_array[0] = db.o1;
    level_array[1] = db.o2;
    level_array[2] = db.o3;
    level_array[3] = db.o4;
    level_array[4] = db.o5;
    auto rp_combo_type = repo_mgr.artifact.get(type_id_);
    if (rp_combo_type == NULL)
        return ERROR_COMBOPRO_NO_SUCH_TYPE;
        
    int32_t item_id = rp_combo_type->item;
    int32_t count = int32_t(level_array[type_id_-1]/10) * 2;
    if (count < 1 )
        count = 1;
    if (m_user.item_mgr.get_items_count(item_id) < count )
    {
        return ERROR_COMBOPRO_NOT_ENOUGH_MAT;
    }
    
    sc_msg_def::nt_combo_pro_exp_change nt;
    nt.attribute_id = type_id_;
    switch(type_id_)
    {
    case 1:
        db.exp1 += EXP_PER_LEVEL(db.o1);
        db.set_exp1(db.exp1);
        nt.value = db.exp1;
        break;
    case 2:
        db.exp2 += EXP_PER_LEVEL(db.o2);
        db.set_exp2(db.exp2);
        nt.value = db.exp2;
        break;
    case 3:
        db.exp3 += EXP_PER_LEVEL(db.o3);
        db.set_exp3(db.exp3);
        nt.value = db.exp3;
        break;
    case 4:
        db.exp4 += EXP_PER_LEVEL(db.o4);
        db.set_exp4(db.exp4);
        nt.value = db.exp4;
        break;
    case 5:
        db.exp5 += EXP_PER_LEVEL(db.o5);
        db.set_exp5(db.exp5);
        nt.value = db.exp5;
        break;
    default:
        return ERROR_COMBOPRO_NO_SUCH_TYPE;
    }

    check_compose(type_id_);
    logic.unicast(m_user.db.uid, nt);
    save_db();        

    sc_msg_def::nt_bag_change_t nt2;
    m_user.item_mgr.consume(item_id, count, nt2);
    m_user.item_mgr.on_bag_change(nt2);

    return SUCCESS;
}
int32_t
sc_combo_pro_t::check_compose(int32_t type_id_)
{
    sc_msg_def::nt_combo_pro_attribute_change nt;
    nt.attribute_id = type_id_;
    auto rp_combo_type = repo_mgr.artifact.get(type_id_);
    if (rp_combo_type == NULL)
        return -1;
    int32_t max_level = rp_combo_type->max_level;
    int32_t id;
    switch(type_id_)
    {
    case 1:
        id = 1000+db.o1;
        break;
    case 2:
        id = 2000+db.o2;
        break;
    case 3:
        id = 3000+db.o3;
        break;
    case 4:
        id = 4000+db.o4;
        break;
    case 5:
        id = 5000+db.o5;
        break;
    default:
        id = 0;
    }
    auto rp_combo_levelup = repo_mgr.artifact_levelup.get(id);
    if (rp_combo_levelup == NULL)
        return -1;
    int32_t levelup_exp = rp_combo_levelup->exp;
    switch(type_id_)
    {
    case 1:
        if (db.exp1 < levelup_exp)
            return SUCCESS;
        if (db.o1 >= max_level)
            return ERROR_COMBOPRO_MAX_LEVEL;
        db.o1++;
        db.set_o1(db.o1);
        nt.value = db.o1;
        break;
    case 2:
        if (db.exp2 < levelup_exp)
            return SUCCESS;
        if (db.o2 >= max_level)
            return ERROR_COMBOPRO_MAX_LEVEL;
        db.o2++;
        db.set_o2(db.o2);
        nt.value = db.o2;
        break;
    case 3:
        if (db.exp3 < levelup_exp)
            return SUCCESS;
        if (db.o3 >= max_level)
            return ERROR_COMBOPRO_MAX_LEVEL;
        db.o3++;
        db.set_o3(db.o3);
        nt.value = db.o3;
        break;
    case 4:
        if (db.exp4 < levelup_exp)
            return SUCCESS;
        if (db.o4 >= max_level)
            return ERROR_COMBOPRO_MAX_LEVEL;
        db.o4++;
        db.set_o4(db.o4);
        nt.value = db.o4;
        break;
    case 5:
        if (db.exp5 < levelup_exp)
            return SUCCESS;
        if (db.o5 >= max_level)
            return ERROR_COMBOPRO_MAX_LEVEL;
        db.o5++;
        db.set_o5(db.o5);
        nt.value = db.o5;
        break;
    default:
        return ERROR_COMBOPRO_NO_SUCH_TYPE;
    }
    logic.unicast(m_user.db.uid, nt);
    save_db();        
    return SUCCESS;
}

void
sc_combo_pro_t::get_combo_pro(sc_msg_def::jpk_combo_pro_view_t& view_)
{
    view_.combo_d_down = 0;
    view_.combo_r_down = 0;
    view_.combo_d_up = 0;
    view_.combo_r_up = 0;
    view_.combo_anger.insert(make_pair(50,0));
    int32_t level_array[5];
    level_array[0] = db.o1;
    level_array[1] = db.o2;
    level_array[2] = db.o3;
    level_array[3] = db.o4;
    level_array[4] = db.o5;
    for(int i=0; i<5; ++i)
    {
        if (level_array[i] <= 0)
            continue;
        int id_begin = (i+1)*1000;
        int id = (i+1)*1000 + level_array[i];
        for(int j=id_begin; j<=id; ++j)
        {
            auto rp_combo = repo_mgr.artifact_levelup.get(j);
            for(size_t n=1; n<rp_combo->attribute.size(); ++n)
            {
                vector<float>& attribute = rp_combo->attribute[n];
                if (attribute[0] == 1)
                {
                    view_.combo_d_down += attribute[1];
                }
                else if (attribute[0] == 2)
                {
                    view_.combo_r_down += attribute[1];
                }
                else if (attribute[0] == 3)
                {
                    view_.combo_d_up += attribute[1];
                }
                else if (attribute[0] == 4)
                {
                    view_.combo_r_up += attribute[1];
                }
                else if (attribute[0] == 5)
                {
                    auto it = view_.combo_anger.find(attribute[1]);
                    if (it == view_.combo_anger.end())
                    {
                        view_.combo_anger.insert(make_pair(attribute[1], attribute[2]));
                    }
                    else
                    {
                        it->second += attribute[2];
                    }
                }
            }
        }
    }
}

void
sc_combo_pro_t::get_user_info(sc_msg_def::jpk_combo_pro_t &jpk_)
{
    jpk_.c1_level = db.o1;
    jpk_.c2_level = db.o2;
    jpk_.c3_level = db.o3;
    jpk_.c4_level = db.o4;
    jpk_.c5_level = db.o5;
    jpk_.c1_exp = db.exp1;
    jpk_.c2_exp = db.exp2;
    jpk_.c3_exp = db.exp3;
    jpk_.c4_exp = db.exp4;
    jpk_.c5_exp = db.exp5;
}
