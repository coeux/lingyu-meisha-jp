#include "sc_skill.h"
#include "sc_user.h"
#include "repo_def.h"
#include "code_def.h"
#include "sc_logic.h"
#include "sc_pro.h"

#define LOG "SC_SKILL"

sc_skill_t::sc_skill_t(sc_user_t& user_):m_user(user_)
{
}
void sc_skill_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
void sc_skill_t::get_skill_jpk(sc_msg_def::jpk_skill_t& jpk_)
{
    jpk_.skid = db.skid;
    jpk_.resid = db.resid;
    jpk_.level = db.level;
}

bool sc_skill_t::istskill(int skid_)
{
    auto rp_tskill = repo_mgr.tskill.get(skid_);
    return (rp_tskill && rp_tskill->id >= 0);
}

bool sc_skill_t::isaskill(int skid_)
{
    auto rp_skill = repo_mgr.skill.get(skid_);
    return (rp_skill && rp_skill->skill_type < 4);
}

bool sc_skill_t::ispskill(int skid_)
{
    auto rp_skill = repo_mgr.skill.get(skid_);
    return (rp_skill && rp_skill->skill_type >= 4);
}

int32_t sc_skill_t::upgrade(int num_)
{
    int need_money = 0;
    int quality = 0;
    int role_resid = 0;
    int role_lv = 0;
    if (db.pid == 0)
    {
        quality = m_user.db.quality;
        role_resid = m_user.db.resid;
        role_lv = m_user.db.grade;
    }
    else
    {
        auto partner = m_user.partner_mgr.get(db.pid);
        if (partner == NULL)
        {
            logerror((LOG, "skill upgrade no partner, uid:%d, pid:%d", m_user.db.uid, db.pid));
            return ERROR_SC_EXCEPTION;
        }
        quality = partner->db.quality; 
        role_resid = partner->db.resid;
        role_lv = partner->db.grade;
    }

    auto it_role = repo_mgr.role.find(role_resid);
    if (it_role == repo_mgr.role.end())
        return ERROR_SC_ILLEGLE_REQ;

   /* if(!m_user.skill_mgr.is_skill_cangrade(quality, role_resid, db.resid))
    {    
        return ERROR_SC_ILLEGLE_REQ;
    }
    */
    int skpresid = it_role->second.skill_passive;
    int skpresid2 = it_role->second.skill_passive2;

    int n = 1;
    int sum = 0;
    repo_def::skill_upgrade_t* rp_pay = NULL;
    if (ispskill(db.resid))
    {
        for(; n <= num_;n++)
        {
            int MAX_PSKILL_LEVEL = repo_mgr.configure.find(41)->second.value;
            if(db.level + n > MAX_PSKILL_LEVEL || db.level >= role_lv)
                return ERROR_SC_EXCEPTION;
            rp_pay = repo_mgr.skill_upgrade.get(db.level + n);
            if (rp_pay == NULL)
                return ERROR_SC_EXCEPTION;
            sum += rp_pay->btp; 
        }
    }
    else if (isaskill(db.resid))
    {
        for(; n <= num_;n++)
        {
            int MAX_ASKILL_LEVEL = repo_mgr.configure.find(41)->second.value;
            if(db.level + n > MAX_ASKILL_LEVEL || db.level >= role_lv)
                return ERROR_SC_EXCEPTION;
            rp_pay = repo_mgr.skill_upgrade.get(db.level + n);
            if (rp_pay == NULL)
                return ERROR_SC_EXCEPTION;
            sum += rp_pay->btp; 
        }
    }
    else if (istskill(db.resid))
    {
        for(; n <= num_;n++)
        {
            int MAX_TSKILL_LEVEL = repo_mgr.configure.find(41)->second.value;
            if(db.level + n > MAX_TSKILL_LEVEL || db.level >= role_lv)
                return ERROR_SC_EXCEPTION;
            rp_pay = repo_mgr.skill_upgrade.get(db.level + n);
            if (rp_pay == NULL)
                return ERROR_SC_EXCEPTION;
            sum += rp_pay->btp; 
        }
    }


    float discount_ = m_user.love_task.get_gold_discount(db.pid);
    if( sum * discount_ > 0 && m_user.db.gold < sum * discount_ )
    {
        logwarn((LOG, "skill upgrade,not enough money:%d", need_money));
        return ERROR_EQ_LESS_MONEY;
    }

    //钱改变
    m_user.on_money_change(-sum * discount_);

    //技能升级
    db.set_level(db.level + num_);
    m_user.on_pro_changed(db.pid);
    save_db();
    //日常任务
    for (int32_t index = 1;index <= num_;index++)
    {
        m_user.daily_task.on_event(evt_skill_upgrade);
    }

    if (db.pid == 0)
    {
        m_user.on_pro_changed();
    }
    else
    {
        sp_partner_t sp_partner = m_user.partner_mgr.get(db.pid);
        if (sp_partner != NULL)
        {
            sp_partner->on_pro_changed();
        }
    }

    return SUCCESS;
}
    
int32_t sc_skill_t::upnext(sc_msg_def::ret_upnext_skill_t &ret)
{
    if (not(ispskill(db.resid) || isaskill(db.resid) || istskill(db.resid)))
    {
        logerror((LOG, "skill upnext, repo no skill: %d", db.resid));
        return ERROR_SC_ILLEGLE_REQ;
    }

    auto it = repo_mgr.skill.find(db.resid);
    auto it2 = repo_mgr.tskill.find(db.resid);
    if (ispskill(db.resid) || isaskill(db.resid))
    {
        if( (0==it->second.next_skill_drawing) || (0==it->second.next_skill))
        {
            logerror((LOG, "skill upnext,repo no drawing: %d", db.resid));
            return ERROR_SC_ILLEGLE_REQ;
        }
    }    
    else if (istskill(db.resid))
    {
        auto it = repo_mgr.tskill.find(db.resid);
        if( (0==it->second.next_skill_drawing) || (0==it->second.next_skill))
        {
            logerror((LOG, "skill upnext,repo no drawing: %d", db.resid));
            return ERROR_SC_ILLEGLE_REQ;
        }
    }

    // 这里的next_skill 可能是天赋(tskill)或者被动技能/主动技能(skill)的next_skill 取决于请求的id
    auto next_skill = istskill(db.resid) ? it2->second.next_skill : it->second.next_skill;
    auto next_skill_drawing = istskill(db.resid) ? it2->second.next_skill_drawing : it->second.next_skill_drawing;

    //判断是否有材料
    if( !m_user.item_mgr.has_items(next_skill_drawing, repo_mgr.skill_compose.get(db.resid)->consume) )
    {
        logerror((LOG, "skill upnext,bag no material,mat id:%d", next_skill_drawing));
        return ERROR_SKILL_NOT_ENOUGH_DRAWING;
    }

    //扣去材料
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(next_skill_drawing, repo_mgr.skill_compose.get(db.resid)->consume,  nt);
    m_user.item_mgr.on_bag_change(nt);
    
    //技能升阶
    db.set_resid(next_skill);
    m_user.on_pro_changed(db.pid);
    db.set_level(db.level);
    save_db();
    
    ret.skid=db.skid;
    ret.skill.skid=db.skid;
    ret.skill.resid=db.resid;
    ret.skill.level=db.level;

    if (db.pid == 0)
    {
        m_user.on_pro_changed();
    }
    else
    {
        sp_partner_t sp_partner = m_user.partner_mgr.get(db.pid);
        if (sp_partner != NULL)
        {
            sp_partner->on_pro_changed();
        }
    }

    return SUCCESS;
}
//======================================================
sc_skill_mgr_t::sc_skill_mgr_t(sc_user_t& user_):
    m_user(user_)
{
}
void sc_skill_mgr_t::init_new_user()
{
    auto it_role = repo_mgr.role.find(m_user.db.resid);
    if (it_role == repo_mgr.role.end())
    {
        logerror((LOG, "repo no role resid:%d", m_user.db.resid));
        return;
    }
    
    int skresid = it_role->second.skill_id;
    int skresid2 = it_role->second.skill_id2;
    int skresid3 = it_role->second.skill_id3;

    int skaresid = it_role->second.skill_auto;
    int skaresid2 = it_role->second.skill_auto2;
    int skaresid3 = it_role->second.skill_auto3;

    int skpresid = it_role->second.skill_passive;
    int skpresid2 = it_role->second.skill_passive2;

    auto f = [&](int skid_, int pid_, int lv_){
        boost::shared_ptr<sc_skill_t> sp_skill(new sc_skill_t(m_user));
        db_Skill_t& skdb = sp_skill->db;
        skdb.skid = m_maxid.newid();
        skdb.uid = m_user.db.uid;
        skdb.pid = pid_; 
        skdb.resid = skid_;
        skdb.level = lv_;
        m_skill_hm.insert(make_pair(sp_skill->db.skid, sp_skill));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Skill_t& db_){
                db_.insert();
        }, skdb);
    };

    f(skresid, 0, 0);
    f(skresid2, 0, 0);
    f(skresid3, 0, 0);

    f(skaresid, 0, 0);
    f(skaresid2, 0, 0);
    f(skaresid3, 0, 0);

    f(skpresid, 0, 0);
    f(skpresid2, 0, 0);

    sc_skill_mgr_t::load_db();
    sc_skill_mgr_t::update_skill_level(0,m_user.db.quality+1,m_user.db.resid);
    m_user.partner_mgr.foreach([&](sp_partner_t partner){
        auto it_role = repo_mgr.role.find(partner->db.resid);
        if (it_role == repo_mgr.role.end())
        {
            logerror((LOG, "repo no role resid:%d", partner->db.resid));
            return;
        }
        if (it_role->second.skill_id == 0)
        {
            logerror((LOG, "repo no role skill resid:%d", it_role->first));
            return;
        }

        int skresid = it_role->second.skill_id;
        int skresid2 = it_role->second.skill_id2;
        int skresid3 = it_role->second.skill_id3;

        int skaresid = it_role->second.skill_auto;
        int skaresid2 = it_role->second.skill_auto2;
        int skaresid3 = it_role->second.skill_auto3;

        int skpresid = it_role->second.skill_passive;
        int skpresid2 = it_role->second.skill_passive;

        f(skresid, partner->db.pid, 0);
        f(skresid2, partner->db.pid, 0);
        f(skresid3, partner->db.pid, 0);

        f(skaresid, partner->db.pid, 0);
        f(skaresid2, partner->db.pid, 0);
        f(skaresid3, partner->db.pid, 0);

        f(skpresid, partner->db.pid, 0);
        f(skpresid2, partner->db.pid, 0);
        sc_skill_mgr_t::load_db();
        sc_skill_mgr_t::update_skill_level(partner->db.pid, partner->db.quality, partner->db.resid);
    });
}
void sc_skill_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Skill_t::sync_select_skill(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_skill_t> sp_skill(new sc_skill_t(m_user));
            sp_skill->db.init(*res.get_row_at(i));
            m_maxid.update(sp_skill->db.skid);
            //logwarn((LOG, "load skill from db, uid:%d, skid:%d, resid:%d, pid:%d", sp_skill->db.uid, sp_skill->db.skid, sp_skill->db.resid, sp_skill->db.pid));
            m_skill_hm.insert(make_pair(sp_skill->db.skid, sp_skill));
        }
        logwarn((LOG, "load skill finish"));
    }
}
void sc_skill_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Skill_t::select_skill(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_skill_t> sp_skill(new sc_skill_t(m_user));
            sp_skill->db.init(*res.get_row_at(i));
            m_maxid.update(sp_skill->db.skid);
            m_skill_hm.insert(make_pair(sp_skill->db.skid, sp_skill));
        }
    }
}
sp_skill_t sc_skill_mgr_t::get(int32_t skid_)
{
    auto it = m_skill_hm.find(skid_);
    if (it != m_skill_hm.end())
        return it->second;
    return sp_skill_t();
}
void sc_skill_mgr_t::init_new_partner(int32_t pid_, int32_t resid_, int32_t quality_)
{
    auto it_role = repo_mgr.role.find(resid_);
    if (it_role == repo_mgr.role.end())
    {
        logerror((LOG, "repo no role resid:%d", resid_));
        return;
    }

    auto f = [&](int skid_, int pid_, int lv_){
        boost::shared_ptr<sc_skill_t> sp_skill(new sc_skill_t(m_user));
        db_Skill_t& skdb = sp_skill->db;
        skdb.skid = m_maxid.newid();
        skdb.uid = m_user.db.uid;
        skdb.pid = pid_; 
        skdb.resid = skid_;
        skdb.level = lv_;
        m_skill_hm.insert(make_pair(sp_skill->db.skid, sp_skill));

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Skill_t& db_){
                db_.insert();
        }, skdb);
    };

    int skresid = it_role->second.skill_id;
    int skresid2 = it_role->second.skill_id2;
    int skresid3 = it_role->second.skill_id3;

    int skaresid = it_role->second.skill_auto;
    int skaresid2 = it_role->second.skill_auto2;
    int skaresid3 = it_role->second.skill_auto3;

    int skpresid = it_role->second.skill_passive;
    int skpresid2 = it_role->second.skill_passive2;

    f(skresid, pid_, 0);
    f(skresid2, pid_, 0);
    f(skresid3, pid_, 0);

    f(skaresid, pid_, 0);
    f(skaresid2, pid_, 0);
    f(skaresid3, pid_, 0);

    f(skpresid, pid_, 0);
    f(skpresid2, pid_, 0);
    
    sc_skill_mgr_t::load_db();
    sc_skill_mgr_t::update_skill_level(pid_, quality_, resid_);
}

void sc_skill_mgr_t::update_skill_level(int32_t pid_, int32_t quality, int32_t resid_)
{
    auto f = [&](int32_t skid, int skill_needqua, int32_t pid_){
        for(auto it = m_skill_hm.begin();it != m_skill_hm.end();it++)
        {
            if(it->second->db.resid == skid && skill_needqua <= quality && it->second->db.level == 0 && it->second->db.pid == pid_)
            {
                it->second->db.level = 1;
                db_Skill_t skilldb;
                skilldb.skid    = it->second->db.skid;
                skilldb.uid     = it->second->db.uid;
                skilldb.pid     = it->second->db.pid;
                skilldb.resid   = it->second->db.resid;
                skilldb.level   = 1;
                db_service.async_do((uint64_t)skilldb.uid, [](db_Skill_t& db_){
                    db_.update();    
                }, skilldb);
                sc_msg_def::nt_skill_open_t nt;
                nt.pid = pid_;
                nt.skillid = skilldb.resid;
                logic.unicast(m_user.db.uid, nt); 
                break;
            };
        };
        
    };
    auto skill_info = repo_mgr.qualityup_attr.find(resid_ * 100 + quality);
    if (skill_info != repo_mgr.qualityup_attr.end())
    {
        int32_t needqua = skill_info->second.quality;
        f(skill_info->second.active1, needqua, pid_);
        f(skill_info->second.active2, needqua, pid_);
        f(skill_info->second.active3, needqua, pid_);
        f(skill_info->second.passive1, needqua, pid_);
        f(skill_info->second.passive2, needqua, pid_);
        f(skill_info->second.passive3, needqua, pid_);
        f(skill_info->second.talent1, needqua, pid_);
        f(skill_info->second.talent2, needqua, pid_);
    }
    
    sc_skill_mgr_t::load_db();
}

//是否满足升级技能条件
bool sc_skill_mgr_t::is_skill_cangrade(int32_t quality, int32_t resid_, int32_t skill_id_)
{
    auto skill_info = repo_mgr.qualityup_attr.find(resid_ * 100 + quality);
    if (skill_info != repo_mgr.qualityup_attr.end())
    {
        if(skill_info->second.active1 == skill_id_ || skill_info->second.active2 == skill_id_  || skill_info->second.active3 == skill_id_
            || skill_info->second.passive1 == skill_id_ || skill_info->second.passive2 == skill_id_ || skill_info->second.passive3 == skill_id_ || 
            skill_info->second.talent1 == skill_id_ || skill_info->second.talent2 == skill_id_)
        {
            return true;
        }
    }
    return false;
}

int32_t sc_skill_mgr_t::get_total_battlexp(int32_t pid_)
{
    /*int32_t total_btp = 0;

    auto it = m_skill_hm.begin();
    while( it!= m_skill_hm.end() )
    {
        if( it->second->db.pid != pid_ )
        {
            ++it;
            continue;
        }

        int level = it->second->db.level ;

        if( it->second->ispskill(it->second->db.resid) )
        {
            //被动技能
            auto it_p = repo_mgr.pskill_upgrade.find( level );
            while( it_p != repo_mgr.pskill_upgrade.end() )
            {
                total_btp += it_p->second.btp ;
                it_p = repo_mgr.pskill_upgrade.find( --level );
            }
        }
        else if( it->second->isaskill(it->second->db.resid) )
        {
            //自动技能
            if( 1 == level )
            {
                auto it_a = repo_mgr.skill.find(it->second->db.resid);
                if( it_a != repo_mgr.skill.end() )
                    total_btp += it_a->second.open_btp;
            }
        }
        else
        {
            //主动技能
            int n = it->second->db.resid%10 ;
            auto it_s = repo_mgr.skill_upgrade.begin();
            while( it_s != repo_mgr.skill_upgrade.end() )
            {
                if( (it_s->second.next < n) || ((it_s->second.next==n) && (it_s->second.lv<=level)) )
                    total_btp += it_s->second.btp;
                ++it_s;
            }
        }

        //++it;
        //删除技能
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Skill_t& db_){
            db_.remove();
        }, it->second->db.data());

        it = m_skill_hm.erase(it);
    }
    return total_btp;
    */
    return 0;
}
