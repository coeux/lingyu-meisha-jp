#include "sc_spec_weapon.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"

#define LOG "SC_SPEC_WEAPON"

sc_spec_weapon_t::sc_spec_weapon_t(sc_user_t& user_):m_user(user_)
{
}

void
sc_spec_weapon_t::get_sweapon_jpk(sc_msg_def::jpk_sweapon_t& jpk_)
{
    jpk_.uid = db.uid;
    jpk_.id = db.id;
    jpk_.resid = db.resid;
	jpk_.rank = db.rank;
	jpk_.owner = db.owner;
	jpk_.atk = db.atk;
    jpk_.mgc = db.mgc;
    jpk_.def = db.def;
    jpk_.res = db.res;
    jpk_.hp = db.hp;
	jpk_.pid = db.pid;
}

void
sc_spec_weapon_t::save_db()
{
    string sql = db.get_up_sql();
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}

//====================================================================
sc_sweapon_mgr_t::sc_sweapon_mgr_t(sc_user_t& user_)
:m_user(user_)
{
}

void
sc_sweapon_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_SpecWeapon_t::sync_select_all(m_user.db.uid, res))
    {
		for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_spec_weapon_t> sp_sweapon(new sc_spec_weapon_t(m_user));
            sp_sweapon->db.init(*res.get_row_at(i));
			weapon_map.insert(make_pair(sp_sweapon->db.id, sp_sweapon));
            m_maxid.update(sp_sweapon->db.id);
        }
    }
}

void
sc_sweapon_mgr_t::init_new_user()
{
}

void
sc_sweapon_mgr_t::addnew(int32_t resid_, sc_msg_def::nt_bag_change_t& change_)
{
	//TODO
	auto rp_sweapon = repo_mgr.wing.get(resid_);
    if (rp_sweapon == NULL)
    {
        logerror((LOG, "addnew sweapon error!,resid:%d, num:%d", resid_));
        return;
    }
	        
	boost::shared_ptr<sc_spec_weapon_t> sp_sweapon(new sc_spec_weapon_t(m_user));
	db_SpecWeapon_t& db = sp_sweapon->db.data();
	memset( &db, 0, sizeof(db) );

    db.uid = m_user.db.uid;
    db.id = m_maxid.newid(); 
    db.resid = resid_;
    genpro(sp_sweapon);
        
	weapon_map.insert(make_pair(sp_sweapon->db.id, sp_sweapon));

    db_service.async_do((uint64_t)m_user.db.uid, [](db_SpecWeapon_t& db_){
        db_.insert();
    }, db);

    sc_msg_def::jpk_sweapon_t jpk;
    sp_sweapon->get_sweapon_jpk(jpk);
	change_.add_sweapons.push_back(std::move(jpk));
}

void
sc_sweapon_mgr_t::genpro(sp_sweapon_t sp_sweapon_)
{
	//TODO
	auto rp_sweapon = repo_mgr.wing.get(resid_);
    if (rp_sweapon == NULL)
    {
        logerror((LOG, "genpro sweapon error!,resid:%d, num:%d", resid_));
        return;
    }
    db_SpecWeapon_t& db = sp_sweapon_->db;

    db.atk = random_t::rand_integer(rp_sweapon->atk[1], rp_sweapon->atk[2]);
    db.mgc = random_t::rand_integer(rp_sweapon->mgc[1], rp_sweapon->mgc[2]);
    db.def = random_t::rand_integer(rp_sweapon->def[1], rp_sweapon->def[2]);
    db.res = random_t::rand_integer(rp_sweapon->res[1], rp_sweapon->res[2]);
    db.hp = random_t::rand_integer(rp_sweapon->hp[1], rp_sweapon->hp[2]);
}

void
sc_sweapon_mgr_t::change_pro(sp_sweapon_t sp_sweapon_)
{
	//TODO
	auto rp_sweapon = repo_mgr.wing.get(resid_);
    if (rp_sweapon == NULL)
    {
        logerror((LOG, "genpro sweapon error!,resid:%d, num:%d", resid_));
        return;
    }
    db_SpecWeapon_t& db = sp_sweapon_->db;

    db.atk = random_t::rand_integer(rp_sweapon->atk[1], rp_sweapon->atk[2]);
    db.mgc = random_t::rand_integer(rp_sweapon->mgc[1], rp_sweapon->mgc[2]);
    db.def = random_t::rand_integer(rp_sweapon->def[1], rp_sweapon->def[2]);
    db.res = random_t::rand_integer(rp_sweapon->res[1], rp_sweapon->res[2]);
    db.hp = random_t::rand_integer(rp_sweapon->hp[1], rp_sweapon->hp[2]);
}

int32_t
sc_sweapon_mgr_t::wear(int32_t weapon_id_, int32_t pid_)
{
	auto it = weapon_map.find(weapon_id_);
	if( it == weapon_map.end() )
	{
	}

	if (pid_ != 0)
	{
		sp_partner_t partner = m_user.partner_mgr.get(pid_);
		if( partner == NULL)
		{
		}
	}

	for(auto it_w=weapon_map.begin(); it_w!=weapon_map.end(); ++it)
	{
		if (it_w->db.pid == pid_)
		{
			int32_t code = takeoff(it_w->db.id, pid_);
			if (code != SUCCESS)
				return code;
		}
	}	

	it->db.pid = pid_;
	it->db.set_pid(pid_);
	it->save_db();

	m_user.on_pro_changed(pid_);
}

int32_t
sc_sweapon_mgr_t::takeoff(int32_t weapon_id_, int32_t pid_)
{
	auto it = weapon_map.find(weapon_id_);
	if( it == weapon_map.end() )
	{
	}

	if (pid_ != 0)
	{
		sp_partner_t partner = m_user.partner_mgr.get(pid_);
		if( partner == NULL)
		{
		}
	}

	it->db.pid = -1;
	it->db.set_pid(-1);
	it->save_db();

	m_user.on_pro_changed(pid_);
	return SUCCESS;
}
