#include "sc_pet.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_PET"

sc_pet_t::sc_pet_t(sc_user_t& user_):m_user(user_)
{
}

void
sc_pet_t::get_pet_jpk(sc_msg_def::jpk_pet_t& jpk_)
{
    jpk_.petid = db.petid;
    jpk_.resid = db.resid;
    jpk_.atk = db.atk;
    jpk_.mgc = db.mgc;
    jpk_.def = db.def;
    jpk_.res = db.res;
    jpk_.hp = db.hp;
}

void
sc_pet_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

//====================================================================
sc_pet_mgr_t::sc_pet_mgr_t(sc_user_t& user_)
:m_user(user_),m_pet(new sc_pet_t(user_))
{
    have_pet = false;
}

void
sc_pet_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Pet_t::sync_select_pet(m_user.db.uid, res))
    {
        m_pet->db.init(*res.get_row_at(0));
        have_pet = true;
    }
    else
    {
        have_pet = false;
    }
}

void
sc_pet_mgr_t::init_new_user()
{
}

sp_pet_t
sc_pet_mgr_t::get()
{
    if (have_pet)
    {
        return m_pet;
    }
    else
    {
        return sp_pet_t();
    }
}

bool
sc_pet_mgr_t::addnew(int32_t resid_, sc_msg_def::nt_bag_change_t& change_)
{
    if (have_pet)
        return false;
    auto rp_pet = repo_mgr.pet.get(resid_);

    if (rp_pet == NULL)
    {
        logerror((LOG, "addnew error!,resid:%d ", resid_));
        return false;
    }

    db_Pet_t& db = m_pet->db.data();
    memset( &db, 0, sizeof(db) );

    db.uid = m_user.db.uid;
    db.petid = m_user.db.uid*100;
    db.resid = resid_;
    genpro(m_pet);
    m_pet->db.set_resid(resid_);
    m_pet->db.set_atk(m_pet->db.atk);
    m_pet->db.set_mgc(m_pet->db.mgc);
    m_pet->db.set_def(m_pet->db.def);
    m_pet->db.set_res(m_pet->db.res);
    m_pet->db.set_hp(m_pet->db.hp);
    m_pet->save_db();

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Pet_t& db_){
        db_.insert();
    }, db);
    
    sc_msg_def::jpk_pet_t jpk;
    m_pet->get_pet_jpk(jpk);
    have_pet = true;
    change_.add_pet.push_back(std::move(jpk));

    m_user.on_team_pro_changed();
    return true;
}

void
sc_pet_mgr_t::genpro(sp_pet_t sp_pet_)
{
    db_Pet_t& db = sp_pet_->db;
    auto rp_pet = repo_mgr.pet.get(db.resid);
    if (rp_pet == NULL)
        return ;

    db.atk = random_t::rand_integer(rp_pet->atk[1], rp_pet->atk[2]);
    db.mgc = random_t::rand_integer(rp_pet->mgc[1], rp_pet->mgc[2]);
    db.def = random_t::rand_integer(rp_pet->def[1], rp_pet->def[2]);
    db.res = random_t::rand_integer(rp_pet->res[1], rp_pet->res[2]);
    db.hp = random_t::rand_integer(rp_pet->hp[1], rp_pet->hp[2]);
}

int32_t
sc_pet_mgr_t::compose(sc_msg_def::ret_compose_pet_t& ret_)
{
    if (!have_pet)
    {
        return ERROR_HAVE_NO_PET;
    }

    // 进阶数量
    auto rp_compose = repo_mgr.pet_compose.get(m_pet->db.resid);
    if (rp_compose == NULL)
    {
        return ERROR_PET_MAT;
    }
    if (rp_compose->stuff_1_num > 0 && m_user.item_mgr.get_items_count(rp_compose->stuff_1)<rp_compose->stuff_1_num)
    {
        return ERROR_NOT_ENOUGH_PET_MAT;
    }
    
    logerror((LOG, "compose pet: %d, uid: %d", m_pet->db.resid, m_user.db.uid));

    int32_t new_resid = rp_compose->next_resid;
    if (new_resid == 0)
    {
        return ERROR_LEVEL_MAX;
    }

    m_pet->db.set_resid(new_resid);
    genpro(m_pet);
    m_pet->db.set_atk(m_pet->db.atk);
    m_pet->db.set_mgc(m_pet->db.mgc);
    m_pet->db.set_def(m_pet->db.def);
    m_pet->db.set_res(m_pet->db.res);
    m_pet->db.set_hp(m_pet->db.hp);

    ret_.resid = new_resid;
    ret_.atk = m_pet->db.atk;
    ret_.def = m_pet->db.def;
    ret_.mgc = m_pet->db.mgc;
    ret_.res = m_pet->db.res;
    ret_.hp = m_pet->db.hp;

    m_pet->save_db();
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(rp_compose->stuff_1, rp_compose->stuff_1_num, nt);
    m_user.item_mgr.on_bag_change(nt);
    m_user.on_team_pro_changed();
    return SUCCESS;
}

void
sc_pet_mgr_t::get_pet_state(bool& have_pet_, int32_t& petid_)
{
    have_pet_ = have_pet;
    if (have_pet)
    {
        petid_ = m_pet->db.resid;
    }
    else
    {
        petid_ = 0;
    }
}

void
sc_pet_mgr_t::get_pet_jpk(sc_msg_def::jpk_pet_t& jpk_, bool& have_pet_)
{
    have_pet_ = have_pet;
    if (have_pet)
        m_pet->get_pet_jpk(jpk_);
}
