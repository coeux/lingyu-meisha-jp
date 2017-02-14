#include "sc_battle.h"
#include "sc_battle_record.h"
#include "repo_def.h"
#include "random.h"
#include "sc_guwu.h"

#include <math.h>

#define USE_RECORD 0

#define KNIGHT_DMG_PER (0.8f)
#define MIN_DMG_PER (0.95f)
#define MAX_DMG_PER (1.00f)
#define CRIT_MLT (1.5f)

#define FRAME_TIME 100          //ms
#define MAX_FRAME_TIME 60000  
#define LT_X (-473.0f)
#define RT_X (+473.0f)
#define MAX_POWER 1000
#define WAIT_TIME 1300

#define IS_WORLD_BOSS(resid) ((0<=(resid-3100))&&((resid-3100)<=4))

enum 
{
    e_atk    = 1,
    e_def    = 2,
    e_res    = 3,
    e_hp     = 4,
    e_cri    = 5,
    e_acc    = 6,
    e_dodge  = 7,
    e_speed  = 8,
};

enum
{
    s_none      = 0,
    s_stop_move,
    s_wudi,
    s_crit_hit,
    s_num,
};

uint32_t g_frame_num = 0;

char T(int dir,int pos) 
{
    char c;
    if (dir > 0) c = 'a'+pos-1;
    else c = 'z'-(pos-1);
    return c;
}

enum 
{
    fs_normal = 0,
    fs_crit = 1,
    fs_miss = 2,
};

enum
{
    job_knight = 1,
    job_warrior,
    job_hunter,
    job_magician,
};

enum
{
    do_wait,
    do_move,
    do_atk,
    do_act_skill,
    do_aut_skill,
};

enum
{
    dir_left = -1,
    dir_right = 1,
};

void sc_fobj_t::fskill_t::begin_skill()
{
    actiontime = own->m_conf_fight.skill_cancel_time * 1000;
    time = conf_skl->spell_time * 1000;

    //printf("[%c] begin skill [%c], actiontime:%d, skltime:%d\n", T(m_dir, m_team_pos), T(lock_targets[0]->m_dir, lock_targets[0]->m_team_pos), actiontime, time);
}

bool sc_fobj_t::fskill_t::enable_begin_skill()
{
    //如果在cd中，则返回
    if (cd > 0)
        return false;
        

    switch(conf_skl->skill_type)
    {
    case 0:
    {
        if (own->m_power < MAX_POWER)
            return false;
    }
    break;
    case 1:
    {
        if (own->m_aut_skl_cast_num  == 0 && own->m_cast_num < conf_skl->first_spell)
            return false;
        else if (own->m_cast_num < conf_skl->loop_spell)
            return false;
    }
    break;
    }

    return (search_skl_target() || search_skl_target2());
}

bool sc_fobj_t::fskill_t::enable_cast_skill()
{
    //如果在cd中，则返回
    if (cd > 0)
        return false;

    //判断是否到达施法点
    //技能改为瞬发
    if (true || actiontime <= 0)
    {
        cd = time - own->m_conf_fight.skill_cancel_time * 1000;  
        if (lock_targets[0] && lock_targets[0]->is_dead())
            return false;
        else return true;
    }
    /*
    else if (lock_targets[0]->is_dead())
    {
        //动作取消
        cd = 0;
        own->m_state = do_move;
        return false;
    }
    else return false;
    */
}
void sc_fobj_t::fskill_t::cast_skill()
{
    if (conf_skl == NULL)
        return;

    switch(conf_skl->skill_type)
    {
        case 0: own->m_power = 0; break;
        case 1: 
        {
            own->m_aut_skl_cast_num++; 
            own->m_cast_num = 0;
        }
            break;
    }

    own->m_cast_num++;

    for(auto* fobj : lock_targets2)
    {
        if (fobj == NULL)
            break;

        if (conf_buf2 && conf_buf2->id > 0)
            fobj->on_buff(own, conf_buf2);
    }

    for(auto fobj : lock_targets)
    {
        if (fobj == NULL)
            break;

        //printf("[%c] skill [%c], dmg:%d\n", T(m_dir, m_team_pos), T(fobj->m_dir, fobj->m_team_pos), dmg);
        //printf("    [%c] power:%d\n", T(m_dir, m_team_pos), m_power);

        if (conf_buf && conf_buf->id > 0)
            fobj->on_buff(own, conf_buf);


        if (fobj->m_bufstate[s_wudi] == 0)
        {
            int dmg = sc_fight_cal_t::cal_dmg(own->field().random(), own, fobj, conf_eff?conf_eff->var1:1.0f, own->m_round);
            fobj->on_dmg(conf_skl->id, dmg);
        }
    }
}
void sc_fobj_t::fskill_t::update_skl_cd(int elapse_)
{
    if (actiontime > 0)
    {
        actiontime -= elapse_;
        if (actiontime < 0)
            actiontime = 0;

        //printf("    [%c] update skl time, actiontime:%d\n", T(m_dir, m_team_pos), actiontime);
    }
    else if (cd > 0)
    {
        cd -= elapse_;
        if (cd <= 0)
        {
            cd = 0;
            time = 0;
            own->m_state = do_move;
        }
        //printf("    [%c] update skl time, cd:%d\n", T(m_dir, m_team_pos), cd);
    }
}

int sc_fobj_t::fskill_t::search_skl_target()
{
    memset(lock_targets, 0, sizeof(lock_targets));

    //不发动技能
    if (conf_skl->area <= 0)
        return 0;

    int dir = own->m_dir; 
    if (conf_skl->target >= 4)
        dir = -dir;

    int found_targets = 0;
    //判断技能的攻击的先后
    switch(conf_skl->target_type)
    {
    case 1:
        //优先攻击前排敌人
        lock_targets[0] = own->field().find_first_target(own, conf_skl->area, dir);
    break;
    case 2:
    {
        //随机目标
        int n = own->field().find_target_in_area(own, conf_skl->area, lock_targets, dir);
        if (n > 1)
        {
            int p = random_t::rand_integer(0, n-1);
            lock_targets[0] = lock_targets[p];
        }
    }
    break;
    case 3:
        //优先攻击后排的敌人
        lock_targets[0] = own->field().find_first_target_inv(own, conf_skl->area, dir);
    break;
    }

    //如果技能目标的第一个不是NULL, 则就找到技能目标
    if (lock_targets[0] != NULL)
        found_targets = 1;
    else return 0;

    //如果这个技能存在范围, 则以技能目标为中心进行查找扩散后的目标
    if (lock_targets[0] != NULL && conf_skl->spread_area > 0)
    {
        int n = own->field().find_target_in_area(own, lock_targets[0], conf_skl->spread_area, (sc_fobj_t**)(lock_targets+1), dir);

        switch(conf_skl->spread_area_type)
        {
        case 1:
            //有限扩散
            if (n > conf_skl->spread_num && conf_skl->spread_num > 0)
                found_targets += conf_skl->spread_num; 
            else
                found_targets += n;
        break;
        case 2:
            //随机扩散，目前没有
        break;
        case 3:
            //全体
            found_targets += n; 
        break;
        }
    }

    return found_targets;
}
int sc_fobj_t::fskill_t::search_skl_target2()
{
    memset(lock_targets2, 0, sizeof(lock_targets2));

    int found_targets = 0;
    int dir = own->m_dir;
    if (conf_skl->target2 >= 4)
        dir = -dir;
    
    switch(conf_skl->target_type2)
    {
    case 1:
        lock_targets2[0] = own->field().find_first_target(own, conf_skl->spread_area2, dir, conf_skl->target2 <= 2);
    break;
    case 2:
    {
        //随机目标
        int n = own->field().find_target_in_area(own, conf_skl->spread_area2, lock_targets2, dir);
        if (n > 1)
        {
            int p = random_t::rand_integer(0, n-1);
            lock_targets2[0] = lock_targets2[p];
        }
    }
    break;
    case 3:
        //优先攻击后排的敌人
        lock_targets2[0] = own->field().find_first_target_inv(own, conf_skl->spread_area2, dir, conf_skl->target2 <= 2);
    break;
    }

    //如果技能目标的第一个不是NULL, 则就找到技能目标
    if (lock_targets2[0] != NULL)
        found_targets = 1;
    else return 0;

    //如果这个技能存在范围, 则以技能目标为中心进行查找扩散后的目标
    if (lock_targets2[0] != NULL && conf_skl->spread_area2 > 0)
    {
        int n = own->field().find_target_in_area(own, lock_targets2[0], conf_skl->spread_area2, lock_targets2+1, dir);

        switch(conf_skl->spread_area_type2)
        {
        case 1:
            //有限扩散
            if (n > conf_skl->spread_num2 && conf_skl->spread_num2 > 0)
                found_targets += conf_skl->spread_num2; 
            else 
                found_targets += n; 
        break;
        case 2:
            //随机扩散，目前没有
        break;
        case 3:
            //全体
            found_targets += n; 
        break;
        }
    }

    return found_targets;
}

//===========================================================================
sc_fobj_t::sc_fobj_t():
m_state(do_wait),
m_atk_cd(0),
m_atk_target(NULL),
m_atk_actiontime(0),
m_atk_time(0), 
m_power(0),
m_hp(100000000), 
m_dmg(0),
m_round(0),
m_act_skl(NULL),
m_aut_skl(NULL),
m_cast_num(0),
m_aut_skl_cast_num(0)
{
}
sc_fobj_t::~sc_fobj_t()
{
    if (m_act_skl != NULL) delete m_act_skl;
    if (m_aut_skl != NULL) delete m_aut_skl;
}
void sc_fobj_t::init(sc_battlefield_t* field_, int dir_, role_t* role_, int team_pos_, float hp_percent_)
{
    float v = guwu_mgr.get_v(role_->uid, field_->flag());
    role_->pro.hp *= (1+v);
    role_->pro.atk *= (1+v);
    role_->pro.def *= (1+v);
    role_->pro.mgc *= (1+v);
    role_->pro.res *= (1+v);
    role_->pro.cri *= (1+v);
    role_->pro.acc *= (1+v);
    role_->pro.dodge *= (1+v);

    if (IS_WORLD_BOSS(role_->resid))
    {
        hp_percent_ = 1;
    }
    
    //printf("%c,%d,%d\n", T(dir_, team_pos_), role_->pro.hp, team_pos_);
    m_hp = role_->pro.hp * hp_percent_;
    m_power = role_->pro.power;
    //m_power = 0;
    //printf("power:%d\n",m_power);
    m_field = (field_);
    m_dir = (dir_);
    m_role = (role_);
    m_team_pos = (team_pos_);
    m_x = (dir_==1?LT_X:RT_X);
    m_wait_time=WAIT_TIME*(m_team_pos-1);

    if (IS_WORLD_BOSS(role_->resid))
    {
        conf_fight_t *fd = repo_mgr.boss_fight.get(role_->resid); 
        if (fd != NULL)
        {
            m_conf_fight = *fd;
            role_->job = m_conf_fight.job;
        }
    }
    else
    {
        conf_fight_t *fd = repo_mgr.role_fight.get(role_->resid); 
        if (fd != NULL)
        {
            m_conf_fight = *fd;
            role_->job = m_conf_fight.job;
        }
    }

    memset(m_bufstate,0,sizeof(m_bufstate));

    if (!role_->skls.empty())
    {
        auto f_init_fskill = [&](sc_msg_def::jpk_skill_t& db_skl_){
            conf_skill_t* conf_skl = repo_mgr.skill.get(db_skl_.resid);
            if (conf_skl == NULL)
                return;

            fskill_t* skl = NULL;
            switch(conf_skl->skill_type)
            {
                case 0: 
                {
                    if (m_act_skl == NULL)
                        skl = m_act_skl = new fskill_t(this);
                }
                break;
                case 1: 
                {
                    if (m_aut_skl == NULL)
                        skl = m_aut_skl = new fskill_t(this);
                }
                break;
            }
            if (skl == NULL)
                return;
/*
            skl->conf_skl = conf_skl;
            skl->conf_buf = repo_mgr.buff.get(conf_skl->buffid*100+db_skl_.level);
            skl->conf_buf2 = repo_mgr.buff.get(conf_skl->buffid2*100+db_skl_.level);
            skl->conf_eff = repo_mgr.skill_effect.get(db_skl_.resid*100+db_skl_.level);
*/
        };

        for(size_t i=0;i<role_->skls.size(); i++)
        {
            f_init_fskill(role_->skls[i]);
        }
    }
}
void sc_fobj_t::update(int elapse_)
{
    if (is_dead())
        return;

    update_buf(elapse_);

    switch(m_state)
    {
    case do_wait:
        wait(elapse_);
    break;
    case do_move:
        move(elapse_);
    break;
    case do_atk:
        fight_atk(elapse_);
    break;
    case do_act_skill:
        fight_act_skill(elapse_);
    break;
    case do_aut_skill:
        fight_aut_skill(elapse_);
    break;
    }


#if USE_RECORD
    record();
#endif
}

void sc_fobj_t::wait(int elapse_)
{
    m_wait_time -= elapse_;
    if (m_wait_time <= 0)
    {
        m_state = do_move;
    }
}

void sc_fobj_t::move(int elapse_)
{
    if (m_bufstate[s_stop_move] != 0)
        return;

    //找到技能攻击的目标
    //if (m_power >= MAX_POWER && (search_skl_target() || search_skl_target2()))

    if (m_act_skl != NULL && m_act_skl->enable_begin_skill())
    {
        m_state = do_act_skill;
        return;
    }

    if (m_aut_skl != NULL && m_aut_skl->enable_begin_skill())
    {
        m_state = do_aut_skill;
        return;
    }

    //找到普通攻击的目标
    if (search_atk_target())
    {
        m_state = do_atk;
        return;
    }

    //更新位置
    m_x += m_conf_fight.speed * elapse_ * m_dir * 0.001f ;

    //printf("[%c] x:%.3f\n", T(m_dir, m_team_pos), m_x);
}

void sc_fobj_t::fight_atk(int elapse_)
{
    if (m_atk_time <= 0)
        begin_atk();
    else if (enable_cast_atk())
        cast_atk();
    else update_atk_cd(elapse_);
}
void sc_fobj_t::begin_atk()
{
    m_atk_actiontime = m_conf_fight.actiontime * 1000;
    m_atk_time = m_conf_fight.hit_rate * 1000;

    //printf("[%c] begin atk [%c], actiontime:%d, atktime:%d\n", T(m_dir, m_team_pos), T(m_atk_target->m_dir, m_atk_target->m_team_pos), m_atk_actiontime, m_atk_time);
}
bool sc_fobj_t::enable_cast_atk()
{ 
    //printf("[%c] actiontime:%d, cd:%d\n", T(m_dir, m_team_pos), m_atk_actiontime, m_atk_cd);

    //如果在cd中，则返回
    if (m_atk_cd > 0)
        return false;

    //判断是否到达施法点
    if (m_atk_actiontime <= 0)
    {
        m_atk_cd = m_atk_time - m_conf_fight.actiontime * 1000;  
        if (m_atk_target->is_dead())
            return false;
        else return true;
    }
    else if (m_atk_target->is_dead())
    {
        //动作取消
        m_atk_time = 0;
        m_atk_cd = 0;
        m_atk_target = NULL;
        m_state = do_move;
        return false;
    }
    else return false;
}
void sc_fobj_t::cast_atk()
{
    m_power += m_conf_fight.atk_power;
    if (m_power > MAX_POWER)
        m_power = MAX_POWER;

    if (m_atk_target->m_bufstate[s_wudi] == 0)
    {
        int dmg = sc_fight_cal_t::cal_dmg(field().random(), this, m_atk_target, 1.0f, m_round);
        //printf("[%c] atk [%c], dmg:%d\n", T(m_dir, m_team_pos), T(m_atk_target->m_dir, m_atk_target->m_team_pos), dmg);
        //printf("    [%c] power:%d\n", T(m_dir, m_team_pos), m_power);
        m_atk_target->on_dmg(0, dmg);
    }
}
void sc_fobj_t::on_dmg(int skid_, int dmg_)
{
    if (skid_ == 0 && dmg_ != 0)
    {
        m_power += m_conf_fight.hit_power;
        if (m_power > MAX_POWER)
            m_power = MAX_POWER;
    }

    m_dmg = dmg_;

    if (dir() > 0)
        field().left_dmg() += dmg_;
    else
        field().right_dmg() += dmg_;

    //printf("hp:%d dir:%d atk: %d\n\n",m_hp,m_dir,dmg_);
    m_hp -= dmg_;

    //只统计发动进攻的伤害总值
    if (m_dir == -1)
    {
        m_field->add_dmg(dmg_);
    }

    /*
    printf("================================================\n");
    printf("    [%d] dmg:%d\n", m_dir*m_team_pos, dmg_);
    printf("    [%d] hp:%d\n", m_dir*m_team_pos, m_hp);
    printf("    [%d] state:%d\n", m_dir*m_team_pos, m_state);
    printf("    [%d] power:%d\n", m_dir*m_team_pos, m_power);
    */

    if (m_hp <= 0)
    {
        m_hp = 0;
        //printf("*********[%d] dead!\n", m_dir*m_team_pos);
    }
}
void sc_fobj_t::on_hel(int hel_)
{
    m_hp += hel_;
}
bool sc_fobj_t::search_atk_target()
{
    m_atk_target = field().find_first_target(this, this->m_conf_fight.hit_area, -dir());
    return (m_atk_target != NULL && !m_atk_target->is_dead());
}
void sc_fobj_t::update_atk_cd(int elapse_)
{
    if (m_atk_actiontime > 0)
    {
        m_atk_actiontime -= elapse_;
        if (m_atk_actiontime < 0)
            m_atk_actiontime = 0;
    }
    else if (m_atk_cd > 0)
    {
        m_atk_cd -= elapse_;
        if (m_atk_cd <= 0) 
        {
            m_atk_cd = 0;
            m_atk_time = 0;
            m_state = do_move;
        }
    }
}
void sc_fobj_t::fight_act_skill(int elapse_)
{
    if (m_act_skl->time <= 0)
        m_act_skl->begin_skill();
    else if (m_act_skl->enable_cast_skill())
        m_act_skl->cast_skill();
    else m_act_skl->update_skl_cd(elapse_);
}
void sc_fobj_t::fight_aut_skill(int elapse_)
{
    if (m_aut_skl->time <= 0)
        m_aut_skl->begin_skill();
    else if (m_aut_skl->enable_cast_skill())
        m_aut_skl->cast_skill();
    else m_aut_skl->update_skl_cd(elapse_);
}
void sc_fobj_t::on_buff(sc_fobj_t* caster_, conf_buff_t* buff_)
{
    auto rp_bufrej = repo_mgr.buff_reject.get(buff_->buff_type);
    for(auto it=m_attach_bufs.begin(); it!=m_attach_bufs.end();)
    {
        fbuf_t& fbuf = (*it);
        if (fbuf.conf->buff_type & rp_bufrej->reject)
            it = m_attach_bufs.erase(it);
        else  it++;
    }
    m_attach_bufs.push_back(std::move(fbuf_t(caster_, this, buff_)));
    on_buff_begin(*m_attach_bufs.rbegin());
}
void sc_fobj_t::on_buff_effect(fbuf_t& buf_)
{
    auto f=[&](int pt_, int pv_){
        if (pt_ != 4) 
            return;
        if (pv_ == 0)
            return;
         
        int eff = 0;
        if (buf_.caster->role().job == job_magician)
            eff = buf_.caster->pro().mgc ;
        else
            eff = buf_.caster->pro().atk;
        eff *= pv_;

        if (eff < 0) on_dmg(buf_.conf->id, eff);
        if (eff > 0) on_hel(eff);
    };
    f(buf_.conf->prop_type1, buf_.conf->prop_value1);
    f(buf_.conf->prop_type2, buf_.conf->prop_value2);
}
void sc_fobj_t::on_buff_begin(fbuf_t& buf_)
{
    if (buf_.conf->state_type != 0)
        m_bufstate[buf_.conf->state_type] = buf_.conf->state_value !=0 ? buf_.conf->state_value:1;
    on_buff_effect(buf_);
}
void sc_fobj_t::on_buff_end(fbuf_t& buf_)
{
    m_bufstate[buf_.conf->state_type] = 0;
}
void sc_fobj_t::update_buf(int elapse_)
{
    for(auto it=m_attach_bufs.begin(); it!=m_attach_bufs.end();)
    {
        fbuf_t& fbuf = (*it);

        //对生命的buff，都是dot，hot
        if ((fbuf.conf->prop_type1 == 4 || fbuf.conf->prop_type2 == 4) &&
            fbuf.effect_times > 0)
        {
            fbuf.cast_time -= elapse_;
            if (fbuf.cast_time <= 0)
            {
                fbuf.effect_times--;
                if (fbuf.effect_times > 0)
                    fbuf.reset_cast_time();
                on_buff_effect(fbuf);
            }
        }

        fbuf.last_time -= elapse_;
        if (fbuf.last_time <= 0)
        {
            on_buff_end(*it);
            it = m_attach_bufs.erase(it);
        }
        else it++;
    }
}
float sc_fobj_t::get_bufv(int pt_)
{
    float p = 0;
    for(auto it=m_attach_bufs.begin(); it!=m_attach_bufs.end(); it++)
    {
        fbuf_t& fbuf = (*it);
        if (fbuf.conf->prop_type1 == pt_)
            p += fbuf.conf->prop_value1;
        if (fbuf.conf->prop_type2 == pt_)
            p += fbuf.conf->prop_value2;
    }
    return (1.0f+p);
}
bool sc_fobj_t::in_range(sc_fobj_t* fobj_, float area_)
{
    //判断技能的距离
    int off = (abs(this->m_x -  fobj_->m_x) - this->m_conf_fight.width*0.5f - fobj_->m_conf_fight.width*0.5f);
    //printf("%d:%f\n", off, area_);
    return (off <= area_);
}
void sc_fobj_t::record()
{
    /*
    record_t rc;
    memset(&rc, 0, sizeof(rc));
    rc.dir = m_dir;
    rc.pos = m_team_pos; 
    rc.x = m_x;
    rc.state  = m_state;
    rc.hp = m_hp;
    rc.dmg = m_dmg;
    rc.power = m_power;
    rc.skl = 0;
    rc.atk = 0;
    rc.atk_time = m_atk_time;
    rc.atk_action_time = m_atk_actiontime;
    rc.atk_cd = m_atk_cd;
    rc.skl_time = m_skl_time;
    rc.skl_action_time = m_skl_actiontime;
    rc.skl_cd = m_skl_cd;
    if (m_state == do_atk && m_atk_target != NULL)
    {
        rc.atk = 1;
        rc.atk_target = m_atk_target->m_team_pos * m_atk_target->m_dir;
    }
    else if (m_state == do_skill)
    {
        rc.skl = 1;
        memset(rc.skl_target, 0, sizeof(rc.skl_target));
        for(int i=0; i<5; i++)
        {
            if (lock_targets[i] != NULL)
                rc.skl_target[i] = lock_targets[i]->m_team_pos * lock_targets[i]->m_dir;
        }
    }

    battle_record.add_record(g_frame_num, std::move(rc));
    */
}
//===========================================================================
sc_battlefield_t::sc_battlefield_t(uint32_t seed_, sp_view_user_t left_, sp_view_user_t right_, int flag_):
    m_remain_time(MAX_FRAME_TIME), m_is_over(false), m_is_win(false), m_random(seed_), m_dmg(0),m_left_dmg(0),m_right_dmg(0),m_flag(flag_)
{
#if USE_RECORD
    battle_record.caster = left_;
    battle_record.target = right_;
#endif

    m_views[0]=left_;
    m_views[1]=right_;

    int i=0;
    for(auto it=left_->roles.begin(); it!=left_->roles.end(); it++)
    {
        m_contain[i].init(this, 1, &(it->second), it->first, left_->hp_percent);
        m_left.push_back(&m_contain[i]); 
        i++;
    }

    for(auto it=right_->roles.begin(); it!=right_->roles.end(); it++)
    {
        m_contain[i].init(this, -1, &(it->second), it->first, right_->hp_percent);
        m_right.push_back(&m_contain[i]); 
        i++;
    }
}

int sc_battlefield_t::run()
{
    g_frame_num=0;
    while(!m_is_over)
    {
        g_frame_num++;
        //printf("========FRAME:%d=========\n", g_frame_num);
        update(FRAME_TIME);
    }
#if USE_RECORD
    battle_record.flush();
#endif
    return g_frame_num;
}

void sc_battlefield_t::update(int elapse_)
{
    if (false == update_live_fobjs(m_left, elapse_))
    {
        m_is_win = false;
        m_is_over = true;
        return;
    }

    if (false == update_live_fobjs(m_right, elapse_))
    {
        m_is_win = true;
        m_is_over = true;
        return;
    }

    m_remain_time -= elapse_;
    if (m_remain_time <= 0)
    {
        m_is_win = false;
        m_is_over = true;
        return;
    }

    //对双方进行排序
    m_left.sort([](sc_fobj_t* a_, sc_fobj_t* b_)->bool{
        return a_->x() > b_->x();
    });
    m_right.sort([](sc_fobj_t* a_, sc_fobj_t* b_)->bool{
        return a_->x() < b_->x();
    });
}

bool sc_battlefield_t::update_live_fobjs(list<sc_fobj_t*>& fobjs_, int elapse_)
{
    bool all_dead = true;
    for(auto it=fobjs_.begin(); it!=fobjs_.end(); it++)
    {
        sc_fobj_t* pfobj = *it;
        if (!pfobj->is_dead())
        {
            pfobj->update(elapse_);
            all_dead = false;
        }
    }
    return !all_dead;
}

sc_fobj_t* sc_battlefield_t::find_first_target(sc_fobj_t* cast_, int area_, int dir_, bool includeme_)
{
    auto it = dir_==-1?m_right.begin():m_left.begin();
    auto it_end = dir_==-1?m_right.end():m_left.end();

    for(; it!=it_end; it++)
    {
        sc_fobj_t* pfobj = (*it);
        if (pfobj->is_dead())
            continue;

        if (cast_ == pfobj && !includeme_)
            continue;

        if (cast_->in_range(pfobj, area_))
        {
            return pfobj;
        }
    }
    return NULL;
}

sc_fobj_t* sc_battlefield_t::find_first_target_inv(sc_fobj_t* cast_, int area_, int dir_, bool includeme_)
{
    auto it = dir_==-1?m_right.rbegin():m_left.rbegin();
    auto it_end = dir_==-1?m_right.rend():m_left.rend();

    for(; it!=it_end; it++)
    {
        sc_fobj_t* pfobj = (*it);
        if (pfobj->is_dead())
            continue;

        if (cast_ == pfobj && !includeme_)
            continue;

        if (cast_->in_range(pfobj, area_))
        {
            return pfobj;
        }
    }

    return NULL;
}

int sc_battlefield_t::find_target_in_area(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int dir_)
{
    auto it = dir_==-1?m_right.begin():m_left.begin();
    auto it_end = dir_==-1?m_right.end():m_left.end();

    int i=0;
    for(; it!=it_end; it++)
    {
        sc_fobj_t* pfobj = (*it);
        if (pfobj == cast_)
            continue;
        if (pfobj->is_dead())
            continue;
        if (cast_->in_range(pfobj, area_))
        {
            fobjs_[i++] = pfobj;
        }
    }
    return i;
}

int sc_battlefield_t::find_target_in_area(sc_fobj_t* cast_, sc_fobj_t* lock_target_, int area_, sc_fobj_t** fobjs_, int dir_)
{
    auto it = dir_==-1?m_right.begin():m_left.begin();
    auto it_end = dir_==-1?m_right.end():m_left.end();

    int i=0;
    for(; it!=it_end; it++)
    {
        sc_fobj_t* pfobj = (*it);
        if (pfobj->is_dead())
            continue;
        if (pfobj == cast_)
            continue;
        if (pfobj == lock_target_)
            continue;
        if (lock_target_->in_range(pfobj, area_))
        {
            fobjs_[i++] = pfobj;
        }
    }
    return i;
}
//===========================================================================
int sc_fight_cal_t::cal_dmg(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* targ_, int val1_, int &round_)
{
    int state = 0;

    double cri = cast_->pro().cri * cast_->get_bufv(e_cri);
    double acc = cast_->pro().acc * cast_->get_bufv(e_acc);
    double dodge = targ_->pro().dodge * targ_->get_bufv(e_dodge);

    double a = (dodge - (acc-300)*0.88f);

    double crit_p = cri/(cri + a + 2333.0f);
    if (crit_p < 0) crit_p=0;

    double miss_p = a/(a + cri + 2333.0f);
    if (miss_p < 0) miss_p=0;

    double p = r_.rand_double();
    //printf("crit_p:%f,miss_p:%f,p:%f\n", crit_p, miss_p, p);

    //如果有一方为世界boss，设置为普通攻击
//    printf("-----------------%d->%d   buffer:%f\n",cast_->resid,targ_->resid,var2_);
    if(IS_WORLD_BOSS(cast_->role().resid)||IS_WORLD_BOSS(targ_->role().resid))
    {
        state = fs_normal;
    }
    else
    {
        if (p <= (1-crit_p-miss_p))
        {
            state = fs_normal;
            //printf("state:normal\n");
        }
        else if (p <= (1-crit_p))
        {
            state = fs_miss;
            //printf("state:miss\n");
            return 0;
        }
        else 
        {
            state = fs_crit;
            //printf("state:crit\n");
        }
    }

    double atk = 0;
    double def = 0;
    double dmg = 0;
    int base_atk = 0;

    if (cast_->role().job == job_magician)
    {
        atk = base_atk = cast_->pro().mgc;
    }
    else
    {
        atk = base_atk = cast_->pro().atk;
    }

    atk *= cast_->get_bufv(e_atk);
    atk *= cast_->buffstate(s_crit_hit) != 0 ? cast_->buffstate(s_crit_hit) : 1;

    if (targ_->role().job == job_magician)
    {
        def = targ_->pro().res * targ_->get_bufv(e_res);
    }
    else
    {
        def = targ_->pro().def * targ_->get_bufv(e_res);
    }

    if (state == fs_crit)
        atk *= CRIT_MLT;

    atk *= r_.rand_double(MIN_DMG_PER, MAX_DMG_PER);

    atk *= val1_;
    
    int lv = targ_->role().lvl.level;
    dmg = ceil(atk*(1.0f-def/(def+lv*150.0f+2000.0f)) - def/(15.0f+ceil(lv*0.1f)));

    if (targ_->role().job == job_knight)
    {
        dmg = ceil(dmg * KNIGHT_DMG_PER); 
    }
    //世界boss，前五次保证至少一半攻击的伤害，第六次开始进入狂暴状态
    if(IS_WORLD_BOSS(cast_->role().resid))
    {
        if( round_<7 )
        {
            if( dmg < base_atk/2 )
                dmg = base_atk/2;
        }
        else
        {
            dmg = 9990000;
        }
        ++round_;
    //    printf("round:%d, dmg:%f, resid:%d, hp:%d\n",round_, dmg, targ_->resid,targ_->hp);
    }
//    else
 //       printf("dmg:%f\n",dmg);

    return dmg;
}
