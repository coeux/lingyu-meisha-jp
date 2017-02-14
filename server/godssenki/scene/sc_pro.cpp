#include "sc_pro.h"
#include "sc_user.h"
#include "sc_equip.h"
#include "repo_def.h"
#include "log.h"
#include "code_def.h"
#include "msg_def.h"
#include "sc_gang.h"
#include "sc_logic.h"
#include "sc_team.h"

#include <math.h>

#define LOG "SC_PRO"

sc_pro_t::sc_pro_t(sc_user_t &user_):m_user(user_)
{
    memset(m_base_pro, 0, sizeof(m_base_pro));
}
int sc_pro_t::cal_pro(int32_t pid_, int32_t pos_, float num_)
{
    int32_t roleid = m_user.db.resid;
    int32_t rolelv  = m_user.db.grade;
    int32_t qulv = m_user.db.quality;
    int32_t potential_1 = m_user.db.potential_1;
    int32_t potential_2 = m_user.db.potential_2;
    int32_t potential_3 = m_user.db.potential_3;
    int32_t potential_4 = m_user.db.potential_4;
    int32_t potential_5 = m_user.db.potential_5;


    if (pid_ != 0)
    {
        sp_partner_t partner = m_user.partner_mgr.get(pid_);
        if (partner == NULL)
        {
            logerror((LOG,"repo no partner pid: %d",pid_));
            return ERROR_SC_EXCEPTION;
        }
        roleid = partner->db.resid;
        rolelv = partner->db.grade;
        qulv = partner->db.quality;
        potential_1 = partner->db.potential_1;
        potential_2 = partner->db.potential_2;
        potential_3 = partner->db.potential_3;
        potential_4 = partner->db.potential_4;
        potential_5 = partner->db.potential_5;
    }

    //读表获得初始属性数值
    repo_def::role_t *role = repo_mgr.role.get(roleid);
    if(role == NULL)
    {
        logerror((LOG,"repo no role resid: %d",roleid));
        return ERROR_SC_EXCEPTION;
    }

    m_base_pro[0] = role->base_atk;
    m_base_pro[1] = role->base_mgc;
    m_base_pro[2] = role->base_def;
    m_base_pro[3] = role->base_res;
    m_base_pro[4] = role->base_hp;
    m_base_pro[5] = role->base_crit;
    m_base_pro[6] = role->base_acc;
    m_base_pro[7] = role->base_dodge;
    m_base_pro[8] = 0;
    m_base_pro[10] = role->base_ten;
    m_base_pro[11] = role->base_imm_dam_pro;
    uint32_t i = 13;
    for (auto fac : role->factor)
    {
        if (fac == -1) continue;
        m_base_pro[i++] = fac;
    }
    m_base_pro[18] = role->atk_power;
    m_base_pro[19] = role->hit_power;
    m_base_pro[20] = role->kill_power;

    //计算角色等级增长而获得的属性
    int plus_lv = 85;
    if (num_ == 1)
        plus_lv = rolelv;
    int MAX_LEVEL = repo_mgr.configure.find(41)->second.value;
    int lvup_id = (role->job-1) * MAX_LEVEL + plus_lv;
    repo_def::lvup_attr_t *lvup_attr =  repo_mgr.lvup_attr.get(lvup_id);
    if( lvup_attr == NULL )
    {
        logerror((LOG,"repo no job lvup attr: %d",role->job));
        return ERROR_SC_EXCEPTION;
    }
    m_base_pro[0] += lvup_attr->atk;
    m_base_pro[1] += lvup_attr->mgc;
    m_base_pro[2] += lvup_attr->def;
    m_base_pro[3] += lvup_attr->res;
    m_base_pro[4] += lvup_attr->hp;
    m_base_pro[5] += lvup_attr->cri;
    m_base_pro[7] += lvup_attr->dodge;

    auto soul_pro = m_user.soulrank_mgr.get_pro_gen(m_user.soulrank_mgr.db.soulid, role->attribute);
    m_base_pro[0] = m_base_pro[0] + soul_pro[1];
    m_base_pro[1] = m_base_pro[1] + soul_pro[2];
    m_base_pro[2] = m_base_pro[2] + soul_pro[3];
    m_base_pro[3] = m_base_pro[3] + soul_pro[4];
    m_base_pro[4] = m_base_pro[4] + soul_pro[5];

    //计算星魂系统属性
    m_user.star_mgr.foreach([&](sp_star_t sp_star_){
            if( (sp_star_->db.att>=1) && (sp_star_->db.att<=5) )
            m_base_pro[sp_star_->db.att - 1] += sp_star_->db.value * num_;
            },pid_);

    //公会技能加成
    sp_gang_t sp_gang;
    sp_ganguser_t sp_guser;
    if (gang_mgr.get_gang_by_uid(m_user.db.uid, sp_gang, sp_guser))
    {
        //增加公会技能增加的技能
        for(int i=0; i<=4; i++)
        {
            m_base_pro[i] += sp_guser->get_gskl_pro(i);
        }
    }
    else{
        sql_result_t res_s;
        char sql[256];
        sprintf(sql,"SELECT skl1, skl2, skl3, skl4, skl5 FROM GangUser WHERE uid = %d AND state = 1", m_user.db.uid);
        db_service.sync_select(sql,res_s);
        if (res_s.affect_row_num() > 0){
            sql_result_row_t& row_s = *res_s.get_row_at(0);
            for(int i=0; i<=4; i++)
            {
                int skl = (int)std::atoi(row_s[i].c_str());
                int resid = i+101;
                repo_def::guildskill_t* gskl = repo_mgr.guildskill.get(resid*1000+skl); 
                if (gskl == NULL)
                    continue;
                m_base_pro[i] += gskl->value * num_;
            }
        }

    }

    //天赋加成
    //角色星级>=3计算天赋
    if (qulv >= 3)
    {
        m_user.skill_mgr.foreach([&](sp_skill_t sp_skill_){
                if (sp_skill_->db.pid != pid_)
                return;

                if (pid_ > 0)
                {
                auto partner = m_user.partner_mgr.get(pid_);
                if (partner == NULL || partner->db.quality < 1)
                return;
                }

                if (role->skill_passive2 == sp_skill_->db.resid && qulv < 5)
                return;

                auto rp_pskill = repo_mgr.tskill.get(sp_skill_->db.resid);
                if (rp_pskill != NULL)
                {
                //base + value * level;
                if (rp_pskill->type1 != 0)
                {
                int value = rp_pskill->base1 + rp_pskill->value1 * sp_skill_->db.level;
                m_base_pro[rp_pskill->type1-1] += value;
                }
                if (rp_pskill->type2 != 0)
                {
                    int value = rp_pskill->base2 + rp_pskill->value2 * sp_skill_->db.level;
                    m_base_pro[rp_pskill->type2-1] += value;
                }
                }
        });
    }

    //计算潜力加成
    //获取潜力值的加成值
    int32_t idx_offset = role->job * 100 ;
    auto rp_potential_value_1 = repo_mgr.potential.get( idx_offset + 1);
    auto rp_potential_value_2 = repo_mgr.potential.get( idx_offset + 2);
    auto rp_potential_value_3 = repo_mgr.potential.get( idx_offset + 3);
    auto rp_potential_value_4 = repo_mgr.potential.get( idx_offset + 4);
    auto rp_potential_value_5 = repo_mgr.potential.get( idx_offset + 5);
    m_base_pro[0] += potential_1 * rp_potential_value_1->value * num_;
    m_base_pro[1] += potential_2 * rp_potential_value_2->value * num_;
    m_base_pro[2] += potential_3 * rp_potential_value_3->value * num_;
    m_base_pro[3] += potential_4 * rp_potential_value_4->value * num_;
    m_base_pro[4] += potential_5 * rp_potential_value_5->value * num_;

    //计算装备获得的属性
    for (int i=1; i<=5; i++)
    {
        sp_equip_t eq = m_user.equip_mgr.get_part(pid_, i);
        if (eq == NULL)
            continue;
        //获取装备初始属性
        repo_def::equip_t *p_e = repo_mgr.equip.get( eq->db.resid );
        if (p_e == NULL)
        {
            logerror((LOG,"repo no equip resid: %d",eq->db.resid ));
            return -1;
        }

        m_base_pro[p_e->attribute-1] += p_e->base_value;

        //获取装备强化获得的属性
        repo_def::equip_t* rp_equip = repo_mgr.equip.get(eq->db.resid); 
        if (rp_equip == NULL)
        {
            logerror((LOG, "repo no equip resid:%d", eq->db.resid));
            return ERROR_SC_EXCEPTION; 
        }

        if (eq->db.strenlevel > 0)
        {
            int strLevel = eq->db.strenlevel;
            repo_def::equip_upgrade_t* reup = repo_mgr.equip_up.get(rp_equip->type);
            if (reup == NULL)
            {
                logerror((LOG, "repo no equip upgrage strenlevel:%d, type:%d", 
                            eq->db.strenlevel, rp_equip->type));
                return ERROR_SC_EXCEPTION; 
            }

            m_base_pro[rp_equip->attribute-1] += reup->value * strLevel * num_;
        }
    }

    // 魂器页提供的属性
    int32_t team_pos_ = m_user.team_mgr.get_pos_from_pid(pid_);
    if (pos_ != -1)
        team_pos_ = pos_;
    m_base_pro[0] += m_user.gem_page_mgr.get_attribute(team_pos_, 17100) * num_;
    m_base_pro[1] += m_user.gem_page_mgr.get_attribute(team_pos_, 17200) * num_;
    m_base_pro[2] += m_user.gem_page_mgr.get_attribute(team_pos_, 17300) * num_;
    m_base_pro[3] += m_user.gem_page_mgr.get_attribute(team_pos_, 17400) * num_;
    m_base_pro[4] += m_user.gem_page_mgr.get_attribute(team_pos_, 17500) * num_;

    // 符文提供的属性
    m_base_pro[0] += m_user.new_rune_mgr.get_attribute(1, pid_) * num_;
    m_base_pro[1] += m_user.new_rune_mgr.get_attribute(2, pid_) * num_;
    m_base_pro[2] += m_user.new_rune_mgr.get_attribute(3, pid_) * num_;
    m_base_pro[3] += m_user.new_rune_mgr.get_attribute(4, pid_) * num_;
    m_base_pro[4] += m_user.new_rune_mgr.get_attribute(5, pid_) * num_;

    //翅膀属性
    sp_wing_t sp_wing = m_user.wing.get_weared();
    if (sp_wing != NULL)
    {
        db_Wing_t& db = sp_wing->db;
        m_base_pro[0] += db.atk * num_;
        m_base_pro[1] += db.mgc * num_;
        m_base_pro[2] += db.def * num_;
        m_base_pro[3] += db.res * num_;
        m_base_pro[4] += db.hp * num_;
        //m_base_pro[5] += db.crit;
        //m_base_pro[6] += db.acc;
        //m_base_pro[7] += db.dodge;
    }

    // 宠物属性
    if (m_user.pet_mgr.have_pet)
    {
        sp_pet_t sp_pet = m_user.pet_mgr.get();
        db_Pet_t& db = sp_pet->db;
        m_base_pro[0] += db.atk * num_;
        m_base_pro[1] += db.mgc * num_;
        m_base_pro[2] += db.def * num_;
        m_base_pro[3] += db.res * num_;
        m_base_pro[4] += db.hp * num_;
    }

    //计算爱恋度加成(最后计算百分比数据)
    if (m_user.love_task.cal_love_reward_pro(pid_, m_base_pro) == -1)
        return -1;

    //计算角色职业升阶而获得的属性
    int quup_id = (roleid) * 100 + qulv ;
    repo_def::qualityup_attr_t *quup_attr = repo_mgr.qualityup_attr.get(quup_id);
    if( quup_attr == NULL )
    {
        logerror((LOG,"repo no job quup attr: %d",role->job));
        return ERROR_SC_EXCEPTION;
    }
    m_base_pro[0] += (quup_attr->rankup_atk)*m_base_pro[0];
    m_base_pro[1] += (quup_attr->rankup_mgc)*m_base_pro[1];
    m_base_pro[2] += (quup_attr->rankup_def)*m_base_pro[2];
    m_base_pro[3] += (quup_attr->rankup_res)*m_base_pro[3];
    m_base_pro[4] += (quup_attr->rankup_hp)*m_base_pro[4];
    m_base_pro[5] += (quup_attr->rankup_cri)*m_base_pro[5];

    //jp
    /*
    //计算角色vip等级获得的属性
    double vipquality = 0.00;
    if (m_user.db.viplevel >= 12 && m_user.db.viplevel <= 13)
        vipquality = 0.03;
    else if (m_user.db.viplevel >= 14 && m_user.db.viplevel <= 16)
        vipquality = 0.06;
    else if (m_user.db.viplevel >= 17 && m_user.db.viplevel <= 17)
        vipquality = 0.09;
    else if (m_user.db.viplevel >= 18)
        vipquality = 0.10;
    m_base_pro[0] += (vipquality)*m_base_pro[0];
    m_base_pro[1] += (vipquality)*m_base_pro[1];
    m_base_pro[2] += (vipquality)*m_base_pro[2];
    m_base_pro[3] += (vipquality)*m_base_pro[3];
    m_base_pro[4] += (vipquality)*m_base_pro[4];
    m_base_pro[5] += (vipquality)*m_base_pro[5];
    */

    // 符文提供的属性抗性以及加成
    m_base_pro[21] += m_user.new_rune_mgr.get_attribute(100, pid_);
    m_base_pro[22] += m_user.new_rune_mgr.get_attribute(101, pid_);
    m_base_pro[23] += m_user.new_rune_mgr.get_attribute(102, pid_);
    m_base_pro[24] += m_user.new_rune_mgr.get_attribute(103, pid_);
    m_base_pro[25] += m_user.new_rune_mgr.get_attribute(104, pid_);
    m_base_pro[26] += m_user.new_rune_mgr.get_attribute(200, pid_);
    m_base_pro[27] += m_user.new_rune_mgr.get_attribute(201, pid_);
    m_base_pro[28] += m_user.new_rune_mgr.get_attribute(202, pid_);
    m_base_pro[29] += m_user.new_rune_mgr.get_attribute(203, pid_);
    m_base_pro[30] += m_user.new_rune_mgr.get_attribute(204, pid_);

    //计算战力点
    m_base_pro[8] = cal_fight_point(pid_, plus_lv);
    m_base_pro[8] = (int32_t)ceilf(m_base_pro[8] * 0.90f);

    return SUCCESS;
}

void sc_pro_t::copy(sc_msg_def::jpk_role_pro_t &jpk_)
{
    jpk_.atk    = m_base_pro[0];
    jpk_.mgc    = m_base_pro[1];
    jpk_.def    = m_base_pro[2];
    jpk_.res    = m_base_pro[3];
    jpk_.hp     = m_base_pro[4];
    jpk_.cri    = m_base_pro[5];
    jpk_.acc    = m_base_pro[6];
    jpk_.dodge  = m_base_pro[7];
    jpk_.fp     = m_base_pro[8];
    jpk_.power  = m_base_pro[9];
    jpk_.ten    = m_base_pro[10];
    jpk_.imm_dam_pro = m_base_pro[11];
    uint32_t i = 13;
    for (; i <= 17; ++i)
    {
        jpk_.factor.push_back(m_base_pro[i]);
    }
    jpk_.atk_power = m_base_pro[18];
    jpk_.hit_power = m_base_pro[19];
    jpk_.kill_power = m_base_pro[20];
    jpk_.p1_d = m_base_pro[21];
    jpk_.p2_d = m_base_pro[22];
    jpk_.p3_d = m_base_pro[23];
    jpk_.p4_d = m_base_pro[24];
    jpk_.p5_d = m_base_pro[25];
    jpk_.p1_a = m_base_pro[26];
    jpk_.p2_a = m_base_pro[27];
    jpk_.p3_a = m_base_pro[28];
    jpk_.p4_a = m_base_pro[29];
    jpk_.p5_a = m_base_pro[30];
}

void sc_pro_t::copy(vector<float> &pro)
{
    for (int i = 0; i < BASE_PRO_COUNT; ++i)
        pro.push_back(m_base_pro[i]);
}

int32_t sc_pro_t::cal_fight_point(int32_t pid_, int32_t rolelv_)
{
    float fp = 0;
    //计算技能增加战斗力
    m_user.skill_mgr.foreach([&](sp_skill_t sp_skill_){
        if (sp_skill_->db.pid != pid_) return;
        auto skill_ = repo_mgr.skill.get(sp_skill_->db.resid);
        if (skill_ != NULL)
        {
            if (skill_->next_skill == 0)
                fp += (int32_t)(4.0f * sp_skill_->db.level*1.5f);
            else 
                fp += (int32_t)(4.0f * sp_skill_->db.level *1.0f);
        }
        else
        {
            auto pskill_ = repo_mgr.tskill.get(sp_skill_->db.resid);
            if (pskill_ != NULL)
            {
                if (pskill_->next_skill == 0)
                    fp += (int32_t)(4.0f * sp_skill_->db.level *1.5f);
                else 
                    fp += (int32_t)(4.0f * sp_skill_->db.level *1.0f);
                }
            }
        });

    /* card_event 敌人更新也有此计算公式，修改同时请一并修改 */
    fp += (m_base_pro[atk] * 1.10f + m_base_pro[mgc]) * 1.00f + m_base_pro[def] * 1.20f + m_base_pro[res] * 1.00f + m_base_pro[hp] * 0.30f + rolelv_ * 20;
    return (int32_t)ceilf(fp);
}
