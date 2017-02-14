#include "sc_battle_pvp.h"
#include "sc_battle_record.h"
#include "repo_def.h"
#include "random.h"
#include "sc_guwu.h"

#include <math.h>

#define KNIGHT_DMG_PER (0.8f)
//#define MIN_DMG_PER (0.95f)
//#define MAX_DMG_PER (1.00f)
#define CRIT_MLT (1.5f)

#define FRAME_TIME 100          //ms
#define MAX_FRAME_TIME 60000    // 单局战斗所需最大时间
#define LT_X (-473.0f)
#define RT_X (+473.0f)
#define MAX_POWER               800     // 最大怒气值
#define SINGLE_CONSUME_POWER    100     // 单张卡牌消耗的总怒气值
#define WAIT_TIME               1300

#define IS_WORLD_BOSS(resid) ((0<=(resid-3100))&&((resid-3100)<=4))

#define MIN_DMG_PER (95)
#define MAX_DMG_PER (105)
#define STORMS_HIT_MULTIPLE 2
#define SUPPRESS_LEVEL 3
#define LEVEL_TO_SUPRESS_ACCURACY_RATE 1
#define LEVEL_TO_SUPRESS_DAMAGE_RATE 1
#define EXTRA_ATTACK_PERCENT 0.25f
#define CUR_STATE() if (m_record->m_cur_state != m_state) m_record->m_cur_state = m_state
enum
{
    RET_enter_scene = 0,
    RET_idle,
    RET_keep_idle,
    RET_move,
    RET_normal_attack,
    RET_skill_attack,
    RET_damage,
    RET_buff,
    RET_camera_zoom_in,
    RET_fight_pause,
    RET_fight_resume,
    RET_start_show_skill,
    RET_end_show_skill,
    RET_action_pause,
    RET_action_resume,
    RET_bring_to_front,
    RET_recover_zorder,
    RET_remove_buff,
    RET_buff_damage,
};

enum
{
    e_atk      = 1,
    e_def      = 2,
    e_res      = 3,
    e_hp       = 4,
    e_cri      = 5,
    e_acc      = 6,
    e_dodge    = 7,
    e_speed    = 8,
};

enum // 战斗中的特殊状态
{
    s_none = 0,
    s_freeze,
    s_dizziness,
    s_invincible,
    s_thorns,
    s_immune,
    s_blind,
    s_chaos,
    s_silence,
    s_deny,
    s_bloodthirsty,
    s_cleanse = 13,
    s_relieve,
    s_dodge_and_anger,

    h_no_anger = 11,
    h_more_anger,
    h_recover_effect = 16,
    h_throns,
    h_immune_damage,
    h_damage,
    h_combo_damage,
    h_skill_property0 = 100,
    h_skill_property1,
    h_skill_property2,
    h_skill_property3,
    h_skill_property4,

    ma_skill_property0 = 200,
    ma_skill_property1,
    ma_skill_property2,
    ma_skill_property3,
    ma_skill_property4,
};

enum
{
    FPT_none = 0,
    FPT_phy,
    FPT_mag,
    FPT_phy_def,
    FPT_mag_def,
    FPT_hp,
    FPT_cri,
    FPT_acc,
    FPT_dod,
    FPT_ang = 9,
    FPT_ten,
    FPT_imm_dam_pro,
    FPT_mov_spe,
    FPT_phy_att_fac,
    FPT_mag_att_fac,
    FPT_phy_def_fac,
    FPT_mag_def_fac,
    FPT_phy_dam = 101,
    FPT_mag_dam,
    FPT_pur_dam,
};

enum
{
    Point = 1,
    Horizonta_Line,
    Vertical_Line,
    Oblique_Line,
    Cycle,
    Cross,
    All,
};

/*
enum
{
    Front = 50,
    Middle = 180,
    Rear = 280,
};
*/

char T(int dir, int pos)
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
    do_wait       = 0x0000,
    do_move       = 0x0001,
    do_atk        = 0x0002,
    do_act_skill1 = 0x0004,
    do_act_skill2 = 0x0008,
    do_act_skill3 = 0x0010,
    do_aut_skill1 = 0x0020,
    do_aut_skill2 = 0x0040,
    do_aut_skill3 = 0x0080,
};

enum
{
    dir_left = -1,
    dir_right = 1,
};

enum
{
    active_skill = 0,
    passive_skill,
    normal_attack,
};

static int stand_y[] = {-120, -95, -70, -45, -20};

/*************************************************************
 * sc_fobj_t class begin
 * ***********************************************************/
sc_fobj_t::sc_fobj_t():
    m_state(do_wait),
    m_atk_cd(0),
    m_atk_target(NULL),
    m_atk_actiontime(0),
    m_atk_time(0),
    m_record(NULL),
    m_atk_count(0),
    m_hp(100000000),
    m_dmg(0),
    m_round(0),
    m_act_skl1(NULL),
    m_act_skl2(NULL),
    m_act_skl3(NULL),
    m_aut_skl1(NULL),
    m_aut_skl2(NULL),
    m_aut_skl3(NULL)
{
}

sc_fobj_t::~sc_fobj_t()
{
    if (m_record != NULL) delete m_record;
    if (m_act_skl1 != NULL) delete m_act_skl1;
    if (m_act_skl2 != NULL) delete m_act_skl2;
    if (m_act_skl3 != NULL) delete m_act_skl3;
    if (m_aut_skl1 != NULL) delete m_aut_skl1;
    if (m_aut_skl2 != NULL) delete m_aut_skl2;
    if (m_aut_skl3 != NULL) delete m_aut_skl3;
}

void sc_fobj_t::init(sc_battlefield_t* field_, int dir_, role_t* role_, int y_, int team_pos_, float hp_percent_)
{
    float v = guwu_mgr.get_v(role_->uid, field_->flag());
    role_->pro.atk *= (1+v);
    role_->pro.mgc *= (1+v);
    if (IS_WORLD_BOSS(role_->resid))
    {
        hp_percent_ = 1;
    }

    m_hp = role_->pro.hp;
    m_cur_hp = role_->pro.hp * hp_percent_;
    m_cur_phy_atk = role_->pro.atk;
    m_cur_phy_def = role_->pro.def;
    m_cur_mgc_atk = role_->pro.mgc;
    m_cur_mgc_def = role_->pro.res;
    m_cur_cir = role_->pro.cri;
    m_cur_ten = role_->pro.ten;
    m_cur_acc = role_->pro.acc;
    m_cur_dod = role_->pro.dodge;
    m_cur_imm = role_->pro.imm_dam_pro;
    m_phy_atk_fac = role_->pro.factor[1];
    m_mgc_atk_fac = role_->pro.factor[2];
    m_phy_def_fac = role_->pro.factor[3];
    m_mgc_def_fac = role_->pro.factor[4];
    m_cha_fac = role_->pro.factor[5];

    m_field = (field_);
    m_dir = (dir_);
    m_role = (role_);
    m_x = (dir_ == 1 ? LT_X : RT_X);
    m_y = y_;
    m_in = false;
    m_team_pos = team_pos_;
    m_wait_time = WAIT_TIME * (m_team_pos - 1);
    m_record = new sc_record_t(this);

    if (IS_WORLD_BOSS(role_->resid))
    {
        conf_fight_t *fd = repo_mgr.boss_fight.get(role_->resid);
        if (fd != NULL) m_conf_fight = *fd;
    }
    else
    {
        conf_fight_t *fd = repo_mgr.role_fight.get(role_->resid);
        if (fd != NULL) m_conf_fight = *fd;
    }

    if (!role_->skls.empty())
    {
        auto f_init_fskill = [&](sc_msg_def::jpk_skill_t& db_skl_){
            conf_skill_t* conf_skl = repo_mgr.skill.get(db_skl_.resid);
            if (conf_skl == NULL)
                return ;

            fskill_t* skl = NULL;
            switch(conf_skl->skill_type)
            {
                case 0:
                {
                    if (m_act_skl1 == NULL)
                        skl = m_act_skl1 = new fskill_t(this);
                    else if (m_act_skl2 == NULL)
                        skl = m_act_skl2 = new fskill_t(this);
                    else if (m_act_skl3 == NULL)
                        skl = m_act_skl3 = new fskill_t(this);
                }
                break;
                case 1:
                {
                    if (m_aut_skl1 == NULL)
                        skl = m_aut_skl1 = new fskill_t(this);
                    else if (m_aut_skl2 == NULL)
                        skl = m_aut_skl2 = new fskill_t(this);
                    else if (m_aut_skl3 == NULL)
                        skl = m_aut_skl3 = new fskill_t(this);
                }
                break;
            }
            if (skl == NULL)
                return;
            skl->conf_skl = conf_skl;
            uint32_t size = conf_skl->buff_data1.size();
            for (uint32_t i = 1; i < size; ++i)
            {
                conf_buff_t* b = repo_mgr.buff.get((int32_t)(conf_skl->buff_data1[i][1])*100 + skl->level);
                if (b != NULL)
                    skl->hm_conf_bufs.insert(make_pair((int32_t)(conf_skl->buff_data1[i][1]), b));
            }
            size = conf_skl->buff_data2.size();
            for (uint32_t i = 1; i < size; ++i)
            {
                conf_buff_t* b = repo_mgr.buff.get((int32_t)(conf_skl->buff_data2[i][1])*100 + skl->level);
                if (b != NULL)
                    skl->hm_conf_bufs.insert(make_pair((int32_t)(conf_skl->buff_data2[i][1]), b));
            }
        };
        for (size_t i = 0; i < role_->skls.size(); ++i)
        {
            f_init_fskill(role_->skls[i]);
        }
    }
}

bool sc_fobj_t::fskill_t::enable_begin_skill()
{
    //如果在cd中，则返回
    if ((own->m_state & 0x00F8) || cd > 0)
        return false;

    switch(conf_skl->skill_type)
    {
        case 0:
        {
            if (own->dir() == dir_left && own->field().left_anger() < SINGLE_CONSUME_POWER)
                return false;
            else if (own->dir() == dir_right && own->field().right_anger() < SINGLE_CONSUME_POWER)
                return false;
        }
        break;
        case 1:
        {
            if (cast_times == 0 && own->m_atk_count < conf_skl->first_spell)
                return false;
            // combo ?!!!
            else if (conf_skl->skill_class != 0)
                return false;
            else if (conf_skl->skill_class == 0 && (conf_skl->loop_spell == 0 || (((own->m_atk_count - conf_skl->first_spell) % conf_skl->loop_spell) != 0)))
                return false;
        }
        break;
    }
    return (search_skl_enemy() || search_skl_ally());
}

void sc_fobj_t::fskill_t::begin_skill()
{
    actiontime = own->m_conf_fight.skill_cancel_time * 1000;
    time = conf_skl->spell_time * 1000;
}

bool sc_fobj_t::fskill_t::enable_cast_skill()
{
    if (cd > 0) return false;
    if (conf_skl->skill_type == active_skill)
    {
        if (own->dir() == dir_left && own->field().left_anger() < SINGLE_CONSUME_POWER)
            return false;
        if (own->dir() == dir_right && own->field().right_anger() < SINGLE_CONSUME_POWER)
            return false;
    }

    //判断是否到达施法点
    //技能改为瞬发(继承原有逻辑)
    if (true || actiontime <= 0)
    {
        cd = time - own->m_conf_fight.skill_cancel_time * 1000;
        if (lock_enemy[0] && lock_enemy[0]->is_dead())
            return false;
        else return true;
    }
}

void sc_fobj_t::fskill_t::cast_skill()
{
    if (conf_skl == NULL) return ;

    ++own->m_atk_count;
    switch(conf_skl->skill_type)
    {
        case 0:  
        {
            int anger_ = 0;
            if (own->dir() == dir_left)
                anger_ = own->field().left_anger();
            else if (own->dir() == dir_right)
                anger_ = own->field().right_anger();
            anger_ -= SINGLE_CONSUME_POWER;
        }
        break; // 应该是减掉总怒气值
        case 1:
        {
            cast_times++;
        }
        break;
    }
    auto fill_record = [&](sc_fobj_t* c_, sc_fobj_t* t_, int type) {
        c_->record().m_skillType = conf_skl->skill_type;
        c_->record().m_targeterTeamID = t_->team_pos();
        c_->record().m_targeterIsEnemy = t_->dir() == dir_right ? true : false;
        c_->record().record(type);
    };
    auto fill_buff_record = [&](sc_fobj_t* c_, sc_fobj_t* t_, conf_buff_t* buff_){
        t_->record().m_attackerTeamIndex = c_->team_pos();
        t_->record().m_attackerIsEnemy = c_->dir() == dir_right ? true : false;
        t_->record().m_buffResID = buff_->id_level;
        t_->record().m_buffID = buff_->id;
        t_->record().record(RET_buff);
    };

    bool record_ = false;
    for (auto fobj : lock_enemy)
    {
        if (fobj == NULL) break;
        fobj->on_dmg(own, sc_fight_cal_t::cal_dmg(own->field().random(), own, fobj, this, own->m_round));

        auto it = find(fobj->m_cur_special_state.begin(), fobj->m_cur_special_state.end(), s_immune);
        if (it != fobj->m_cur_special_state.end()) continue;

        auto it_deny = find(fobj->m_cur_special_state.begin(), fobj->m_cur_special_state.end(), s_deny);
        bool is_deny = it_deny == fobj->m_cur_special_state.end() ? false : true;
        if (!is_deny)
        {
            uint32_t size = conf_skl->buff_data1.size();
            for (uint32_t i = 1; i < size; ++i)
            {
                int skl_acc_pro = sc_fight_cal_t::cal_skl_acc_pro(own, fobj, this);
                if (skl_acc_pro >= 100 || (int)(own->field().random().rand_integer(1, 100)) <= skl_acc_pro)
                {
                    if (conf_skl->skill_type == passive_skill)
                        fill_record(own, fobj, RET_skill_attack);
                    else if (!record_ && conf_skl->skill_type == active_skill)
                    {
                        fill_record(own, fobj, RET_start_show_skill);
                        fill_record(own, fobj, RET_fight_pause);
                        fill_record(own, fobj, RET_action_resume);
                        fill_record(own, fobj, RET_skill_attack);
                        record_ = true;
                    }
                    int pro = conf_skl->buff_data1[i][0] * 100;
                    if (pro >= 100 || (int)(own->field().random().rand_integer(1, 100)) <= pro)
                    {
                        auto it = hm_conf_bufs.find((int32_t)(conf_skl->buff_data1[i][1]));
                        if (it == hm_conf_bufs.end()) continue;
                        fobj->on_buff(own, it->second);
                        // fill_buff_record(own, fobj, it->second);
                    }
                }
            }
        }
    }

    for (auto fobj : lock_ally)
    {
        if (fobj == NULL) break;
        int skl_acc_pro = sc_fight_cal_t::cal_skl_acc_pro(own, fobj, this);
        if (skl_acc_pro >= 100 || (int)(own->field().random().rand_integer(1, 100)) <= skl_acc_pro)
        {
            if (conf_skl->skill_type == passive_skill)
                fill_record(own, fobj, RET_skill_attack);
            else if (!record_ && conf_skl->skill_type == active_skill)
            {
                fill_record(own, fobj, RET_start_show_skill);
                fill_record(own, fobj, RET_fight_pause);
                fill_record(own, fobj, RET_action_resume);
                fill_record(own, fobj, RET_skill_attack);
                record_ = true;
            }
            uint32_t size = conf_skl->buff_data2.size();
            for (uint32_t i = 1; i < size; ++i)
            {
                int pro = conf_skl->buff_data2[i][0] * 100;
                if (pro >= 100 || (int)(own->field().random().rand_integer(1, 100)) <= pro);
                {
                    auto it = hm_conf_bufs.find(((int32_t)(conf_skl->buff_data2[i][1])));
                    if (it == hm_conf_bufs.end()) continue;
                    fobj->on_buff(own, it->second);
                    // fill_buff_record(own, fobj, it->second);
                }
            }
        }
    }
    if (record_) own->record().record(RET_fight_resume);
}

void sc_fobj_t::fskill_t::update_skl_cd(int elapse_)
{
    if (actiontime > 0)
    {
        actiontime -= elapse_;
        if (actiontime < 0)
            actiontime = 0;
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
    }
}

float sc_fobj_t::fskill_t::dmg_fac()
{
    if (conf_skl->spread_num == 1)
        return 1.0f;
    else if (conf_skl->spread_num > 1 && conf_skl->spread_num <= 3)
        return 0.5f;
    else
        return 0.4f;
}

void sc_fobj_t::update(int elapse_)
{
    if (is_dead())
        return ;

    update_buf(elapse_);

    switch(m_state)
    {
    case do_wait: 
        wait(elapse_); 
        m_record->record(RET_keep_idle);
        CUR_STATE();
        break;
    case do_move: 
        if (false == m_in)
        {
            m_in = true; 
            m_record->record(RET_enter_scene);
            m_record->record(RET_move);
        }
        else if (m_record->m_cur_state != do_move)
        {
            m_record->record(RET_move);
        }
        move(elapse_); 
        CUR_STATE();
        break;
    case do_atk: 
        fight_atk(elapse_); 
        CUR_STATE();
        break;
    case do_act_skill1: 
        CUR_STATE();
        fight_skill(m_act_skl1, elapse_); 
        break;
    case do_act_skill2: 
        CUR_STATE();
        fight_skill(m_act_skl2, elapse_); 
        break;
    case do_act_skill3: 
        CUR_STATE();
        fight_skill(m_act_skl3, elapse_); 
        break;
    case do_aut_skill1: 
        CUR_STATE();
        fight_skill(m_aut_skl1, elapse_); 
        break;
    case do_aut_skill2: 
        CUR_STATE();
        fight_skill(m_aut_skl2, elapse_); 
        break;
    case do_aut_skill3: 
        CUR_STATE();
        fight_skill(m_aut_skl3, elapse_); 
        break;
    }
}

void sc_record_t::record(int32_t event_type)
{
    static bool is_pause = false;
    if (!m_recorder->field().is_record()) return;
    sc_msg_def::jpk_arena_fight_record_t fight_record_;
    fight_record_.m_eventType = event_type;
    fight_record_.m_isEnemy = m_recorder->dir() == dir_left ? true : false;
    fight_record_.m_actorTeamIndex = m_recorder->team_pos();
    fight_record_.m_x = m_recorder->x();
    fight_record_.m_y = m_recorder->y();
    switch(event_type)
    {
    case RET_damage:
        fight_record_.m_attackState = m_recorder->record().m_attackState;
        fight_record_.m_damageValue = m_recorder->record().m_damageValue;
        fight_record_.m_skillType = m_recorder->record().m_skillType;
        fight_record_.m_attackerTeamIndex = m_recorder->record().m_attackerTeamIndex;
        fight_record_.m_attackerIsEnemy = m_recorder->record().m_attackerTeamIndex;
        fight_record_.m_isLethal = m_recorder->record().m_isLethal;
        break;
    case RET_skill_attack:
        fight_record_.m_skillType = m_recorder->record().m_skillType;
        fight_record_.m_attackerTeamIndex = m_recorder->record().m_attackerTeamIndex;
        fight_record_.m_attackerIsEnemy = m_recorder->record().m_attackerIsEnemy;
        break;
    case RET_buff:
        fight_record_.m_attackerTeamIndex = m_recorder->record().m_attackerTeamIndex;
        fight_record_.m_attackerIsEnemy = m_recorder->record().m_attackerIsEnemy;
        fight_record_.m_buffResID = m_recorder->record().m_buffResID;
        fight_record_.m_buffID = m_recorder->record().m_buffID;
        break;
    case RET_fight_pause:
        is_pause = true;
        break;
    case RET_fight_resume:
        if (!is_pause) return;
        is_pause = false;
        break;
    };
    if (!is_pause)
        fight_record_.m_time = m_recorder->field().num();
    else if (event_type != RET_fight_resume)
        fight_record_.m_time = 0;

    m_recorder->field().add_record(fight_record_);
}

bool sc_fobj_t::in_range(sc_fobj_t* fobj_, float area_)
{
    int off = (abs(this->m_x -  fobj_->m_x) - this->m_conf_fight.width*0.5f - fobj_->m_conf_fight.width*0.5f);
    return (off <= area_);
}

void sc_fobj_t::update_buf(int elapse_)
{
    auto fill_record = [&](sc_fobj_t* c_, sc_fobj_t* t_, conf_buff_t* buf_){
        t_->record().m_attackerTeamIndex = c_->team_pos();
        t_->record().m_attackerIsEnemy = c_->dir() == dir_right ? true : false;
        t_->record().m_buffID = buf_->id;
        t_->record().m_state = 1;
        t_->record().record(RET_damage);
    };

    for (auto it = m_attach_bufs.begin(); it != m_attach_bufs.end();)
    {
        fbuf_t& fbuf = (*it);
        if ((fbuf.conf->prop_type1 == FPT_hp || fbuf.conf->prop_type2 == FPT_hp) && fbuf.effect_times > 0)
        {
            fbuf.effect_times -= elapse_;
            if (fbuf.cast_time <= 0)
            {
                --fbuf.effect_times;
                if (fbuf.effect_times > 0)
                    fbuf.reset_cast_time();
                on_buff_effect(fbuf);
            }
        }
        fbuf.last_time -= elapse_;
        if (fbuf.last_time <= 0)
        {
            on_buff_end(*it);
            fill_record(it->caster, it->target, it->conf);
            it = m_attach_bufs.erase(it);
        }
        else ++it;
    }
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
    for (auto it = m_cur_special_state.begin(); it != m_cur_special_state.end(); ++it)
    {
        if ((*it) == s_freeze || (*it) == s_dizziness)
            return;
    }

    if (m_act_skl1 != NULL && m_act_skl1->enable_begin_skill() && false)
    {
        m_state = do_act_skill1;
        return;
    }

    if (m_act_skl2 != NULL && m_act_skl2->enable_begin_skill() && false)
    {
        m_state = do_act_skill2;
        return;
    }

    if (m_act_skl3 != NULL && m_act_skl3->enable_begin_skill() && false)
    {
        m_state = do_act_skill3;
        return;
    }

    if (m_aut_skl1 != NULL && m_aut_skl1->enable_begin_skill())
    {
        m_state = do_aut_skill1;
        return;
    }

    if (m_aut_skl2 != NULL && m_aut_skl2->enable_begin_skill())
    {
        m_state = do_aut_skill2;
        return;
    }

    if (m_aut_skl3 != NULL && m_aut_skl3->enable_begin_skill())
    {
        m_state = do_aut_skill3;
        return;
    }

    // normal
    if (search_atk_target())
    {
        m_state = do_atk;
        return;
    }

    m_x += m_conf_fight.speed * elapse_ * m_dir * 0.001f;
}

bool sc_fobj_t::search_atk_target()
{
    /*
    m_atk_target = field().select_one_targeter(this, this->m_conf_fight.hit_area, -dir());
    */
    return (m_atk_target != NULL && !m_atk_target->is_dead());
}

void sc_fobj_t::fight_atk(int elapse_)
{
    if (m_atk_time <= 0)
    {
        m_record->m_skillType = 2;
        m_record->record(RET_skill_attack);
        begin_atk();
    }
    else if (enable_cast_atk())
        cast_atk();
    else update_atk_cd(elapse_);
}

void sc_fobj_t::begin_atk()
{
    m_atk_actiontime = m_conf_fight.actiontime * 1000;
    m_atk_time = m_conf_fight.hit_rate * 1000;
}

bool sc_fobj_t::enable_cast_atk()
{
    if (m_atk_cd > 0)
        return false;

    if (m_atk_actiontime <= 0)
    {
        m_atk_cd = m_atk_time - m_conf_fight.actiontime * 1000;
        if (m_atk_target->is_dead())
            return false;
        return true;
    }
    else if (m_atk_target->is_dead())
    {
        // 动作取消
        m_atk_time = 0;
        m_atk_cd = 0;
        m_atk_target = NULL;
        m_state = do_move;
        return false;
    }
    return false;
}

void sc_fobj_t::cast_atk()
{
    ++m_atk_count;

    bool is_invincible = false;
    for(auto it = m_atk_target->m_cur_special_state.begin(); it != m_atk_target->m_cur_special_state.end(); ++it)
    {
        if ((*it) == s_invincible)
            is_invincible = true;
    }
    if (!is_invincible)
    {
        int dmg = sc_fight_cal_t::cal_dmg(field().random(), this, m_atk_target, NULL, m_round);
        m_atk_target->on_dmg(this, dmg);
    }
}

void sc_fobj_t::on_dmg(sc_fobj_t* cast_, int dmg_)
{
    uint32_t base_ = 0;
    m_dmg = dmg_;
    if (dir() > 0)
    {
        field().left_dmg() += dmg_;
        base_ = (uint32_t)(dmg_ * 1.0f / field().left_hp() * MAX_POWER);
        field().add_left_anger(base_ * m_conf_fight.hit_power / 100);
        field().add_right_anger(base_ * cast_->conf_fight().atk_power / 100);
    }
    else
    {
        field().right_dmg() += dmg_;
        base_ = (uint32_t)(dmg_ * 1.0f / field().right_hp() * MAX_POWER);
        field().add_left_anger(base_ * cast_->conf_fight().atk_power / 100);
        field().add_right_anger(base_ * m_conf_fight.hit_power / 100);
    }
    m_cur_hp -= dmg_;

    if(m_dir == -1)
        m_field->add_dmg(dmg_);

    if (m_cur_hp <= 0)
        m_cur_hp = 0;
}

void sc_fobj_t::on_hel(int hel_)
{
    if (m_cur_hp + hel_ > m_hp)
        m_cur_hp = m_hp;
    else
        m_cur_hp += hel_;
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

int sc_fobj_t::fskill_t::search_skl_enemy()
{
    memset(lock_enemy, 0, sizeof(lock_enemy));

    switch(conf_skl->target_type)
    {
        case Point:
            return own->field().find_target_Pt(own, conf_skl->spread_area, lock_enemy, conf_skl->spread_area_type);
        case Horizonta_Line:
            return own->field().find_target_HL(own, conf_skl->spread_area, lock_enemy);
        case Vertical_Line:
            return own->field().find_target_VL(own, conf_skl->spread_area, lock_enemy, conf_skl->spread_area_type);
        case Cycle:
            return own->field().find_target_Ce(own, conf_skl->spread_area, lock_enemy, conf_skl->spread_area_type);
        case Cross:
            return own->field().find_target_Cs(own, conf_skl->spread_area, lock_enemy);
        case All:
            return own->field().find_target_Al(own, lock_enemy);
        default:
            return 0;
    }
}

int sc_fobj_t::fskill_t::search_skl_ally()
{
    memset(lock_ally, 0, sizeof(lock_ally));

    switch(conf_skl->target_type2)
    {
        case Point:
            return own->field().find_target_Pt(own, conf_skl->spread_area2, lock_ally, conf_skl->spread_area_type2);
        case Horizonta_Line:
            return own->field().find_target_HL(own, conf_skl->spread_area2, lock_ally);
        case Vertical_Line:
            return own->field().find_target_VL(own, conf_skl->spread_area2, lock_ally, conf_skl->spread_area_type2);
        case Cycle:
            return own->field().find_target_Ce(own, conf_skl->spread_area2, lock_ally, conf_skl->spread_area_type2);
        case Cross:
            return own->field().find_target_Cs(own, conf_skl->spread_area2, lock_ally);
        case All:
            return own->field().find_target_Al(own, lock_ally);
        default:
            return 0;
    }
}
void sc_fobj_t::fight_skill(fskill_t* &skill_, int elapse_)
{
    auto fill_record = [&](sc_fobj_t* c_, sc_fobj_t* t_, int type) {
        c_->record().m_skillType = skill_->conf_skl->skill_type;
        c_->record().m_targeterTeamID = t_->team_pos();
        c_->record().m_targeterIsEnemy = t_->dir() == dir_right ? true : false;
        c_->record().m_time = skill_->conf_skl->spell_time;
        c_->record().record(type);
    };
    if (skill_->time <= 0)
        skill_->begin_skill();
    else if (skill_->enable_cast_skill())
    {
        skill_->cast_skill();
        if (skill_->conf_skl->skill_type == active_skill)
            fill_record(this, this, RET_fight_resume);
    }
    else 
        skill_->update_skl_cd(elapse_);
}

void sc_fobj_t::on_buff(sc_fobj_t* cast_, conf_buff_t* buff_)
{
    return;
    /*
    if (is_dead() || !buff_) return ;
    repo_def::buff_relation_t* rela = repo_mgr.buff_relation.get(buff_->buff_type);
    if (rela == NULL) return;

    for (auto it = m_attach_bufs.begin(); it != m_attach_bufs.end();)
    {
        auto rj = find(rela->reject.begin(), rela->reject.end(), it->conf->buff_type);
        if (rj == rela->reject.end()) return ;
        auto rp = find(rela->replace.begin(), rela->replace.end(), it->conf->buff_type);
        if (rp != rela->replace.end())
            it = m_attach_bufs.erase(it);
        else ++it;
    }
    m_attach_bufs.push_back(std::move(fbuf_t(cast_, this, buff_)));
    on_buff_begin(*m_attach_bufs.rbegin());*/
}

void sc_fobj_t::on_buff_begin(fbuf_t& buf_)
{
    auto it = find(m_cur_special_state.begin(), m_cur_special_state.end(), buf_.conf->state_type);
    if (it != m_cur_special_state.end())
    {
        if (buf_.conf->state_type != s_none)
        {
            m_cur_special_state.push_back(buf_.conf->state_type);
            on_special_state_effect(buf_.conf->state_type, buf_.conf->state_value);
            m_vampiric_pro += buf_.conf->state_value;
        }
    }
    on_buff_effect(buf_);
}

void sc_fobj_t::on_buff_effect(fbuf_t& buf_)
{
    auto f = [&](int pt_, int pf_, int pv_) {
        if (pt_ != FPT_hp)
        {
            change_property_data(pt_, pf_ == 0 ? get_property_data(pt_) * pv_ : pv_);
        }
        else
        {
            float delt_hp = 0;
            if (pf_ == 0)
            {
                sc_fobj_t* c_ = buf_.caster;
                if (pv_ < 0)
                {
                    delt_hp = fabs(floor(((c_->m_cur_phy_atk + c_->m_cur_mgc_atk) * c_->m_mgc_atk_fac - m_cur_mgc_def * m_mgc_def_fac) * (1 - m_cur_imm) * pv_));
                }
                else
                {
                    delt_hp = fabs(floor(((c_->m_cur_phy_atk + c_->m_cur_mgc_atk) * c_->m_mgc_atk_fac * pv_) * (1 + m_recover_effect)));
                }
            }
            else if (pf_ == 1)
            {
                delt_hp = pv_ < 0 ? pv_ : floor(pv_ * (1 + m_recover_effect));
            }
            if (pv_ < 0) on_dmg(buf_.caster, delt_hp);
            if (pv_ > 0) on_hel(delt_hp);
        }
    };
    f(buf_.conf->prop_type1, buf_.conf->affect_method1, buf_.conf->prop_value1);
    f(buf_.conf->prop_type2, buf_.conf->affect_method2, buf_.conf->prop_value2);
}

void sc_fobj_t::on_buff_end(fbuf_t& buf_)
{
    auto f = [&](int pt_, int pf_, int pv_){
        if (pt_ != FPT_hp)
        {
            change_property_data(pt_, pf_ == 0 ? -get_property_data(pt_) * pv_ : -pv_);
        }
    };
    f(buf_.conf->prop_type1, buf_.conf->affect_method1, buf_.conf->prop_type1);
    f(buf_.conf->prop_type2, buf_.conf->affect_method2, buf_.conf->prop_type2);

    auto s = find(m_cur_special_state.begin(), m_cur_special_state.end(), buf_.conf->state_type);
    if (s != m_cur_special_state.end())
    {
        m_cur_special_state.erase(s);
        on_special_state_effect(buf_.conf->state_type, -buf_.conf->state_value);
    }
}

void sc_fobj_t::on_special_state_effect(int state_type, float value_)
{
    switch(state_type)
    {
        case s_freeze: break;
        case s_dizziness: break;
        case s_thorns: 
            m_thorns_pro += value_;
            break;
        case s_bloodthirsty: 
            m_vampiric_pro += value_;
            break;
        case s_cleanse: 
            break;
        case s_relieve: break;
        case s_dodge_and_anger: 
            m_dodge_add_anger += value_;
            break;
        case h_more_anger: 
            m_more_anger += value_;
            break;
        case h_recover_effect: 
            m_recover_effect += value_;
            break;
        case h_throns: 
            m_thorns_pro += value_;
            break;
        case h_immune_damage: 
            m_cur_imm += value_;
            break;
        case h_damage:
            m_real_dam_pro += value_;
            break;
        case h_combo_damage: 
            m_combo_dam_pro += value_;
            break;
        case h_skill_property0: 
            m_skill_add[0] += value_;
            break;
        case h_skill_property1: 
            m_skill_add[1] += value_;
            break;
        case h_skill_property2: 
            m_skill_add[2] += value_;
            break;
        case h_skill_property3: 
            m_skill_add[3] += value_;
            break;
        case h_skill_property4:
            m_skill_add[4] += value_;
            break;
        case ma_skill_property0: 
            m_mark_add[0] += value_;
            break;
        case ma_skill_property1: 
            m_mark_add[1] += value_;
            break;
        case ma_skill_property2: 
            m_mark_add[2] += value_;
            break;
        case ma_skill_property3: 
            m_mark_add[3] += value_;
            break;
        case ma_skill_property4:
            m_mark_add[4] += value_;
            break;
    }
}

void sc_fobj_t::change_property_data(int type_, int value_)
{
    switch(type_)
    {
        case FPT_hp: m_cur_hp += value_; break;
        case FPT_phy: m_cur_phy_atk += value_; break;
        case FPT_phy_def: m_cur_phy_def += value_; break;
        case FPT_mag: m_cur_mgc_atk += value_; break;
        case FPT_mag_def: m_cur_mgc_def += value_; break;
        case FPT_cri: m_cur_cir += value_; break;
        case FPT_ten: m_cur_ten += value_; break;
        case FPT_acc: m_cur_acc += value_; break;
        case FPT_dod: m_cur_dod += value_; break;
        case FPT_imm_dam_pro: m_cur_imm += value_; break;
        //case FPT_ang: m_cur_ang += value_; break;
    }
}

float sc_fobj_t::get_property_data(int type_)
{
    switch(type_)
    {
        case FPT_hp: return pro().hp;
        case FPT_phy: return pro().atk;
        case FPT_phy_def: return pro().def;
        case FPT_mag: return pro().mgc;
        case FPT_mag_def: return pro().res;
        case FPT_cri: return pro().cri;
        case FPT_ten: return pro().ten;
        case FPT_acc: return pro().acc;
        case FPT_dod: return pro().dodge;
        case FPT_imm_dam_pro: return pro().imm_dam_pro;
        //case FPT_ang: return pro().ang;
    }
    return 0.0f;
}
/*************************************************************
 * sc_fobj_t class end
 * ***********************************************************/

/*************************************************************
 * sc_battlefield_t class begin
 * ***********************************************************/
int sc_battlefield_t::find_target_Pt(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int type)
{
    if (type == 2)
    {
        fobjs_[0] = select_one_targeter(cast_, area_, cast_->dir());
        return 1;
    }
    else if (type == 1)
    {
        int n = find_target_in_area(cast_, area_, fobjs_, cast_->dir());
        fobjs_[0] = fobjs_[random_t::rand_integer(0, n-1)];
        return 1;
    }
    return 0;
}

sc_fobj_t* sc_battlefield_t::select_one_targeter(sc_fobj_t* cast_, int area_, int dir_)
{
    auto it = dir_ == -1 ? m_right.begin() : m_left.begin();
    auto it_end = dir_ == -1 ? m_right.end() : m_left.end();
    sc_fobj_t* pfobj = NULL;
    for (; it != it_end; ++it)
    {
        if ((*it)->is_dead())
            continue;

        if (cast_->in_range((*it), area_))
        {
            if (pfobj == NULL)
                pfobj = (*it);
            else if ((*it)->y() == cast_->y())
            {
                bool is_nearest = fabs((*it)->x() - cast_->x()) < fabs(pfobj->x() - cast_->x()) ? true : false;
                if ((*it)->y() != pfobj->y() || is_nearest)
                    pfobj = (*it);
            }
            else if (fabs((*it)->y() - cast_->y()) < fabs(pfobj->y() - cast_->y()))
                pfobj = (*it);
        }
    }
    return pfobj;
}

int sc_battlefield_t::find_target_in_area(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int dir_)
{
    auto it = dir_ == -1 ? m_right.begin() : m_left.begin();
    auto it_end = dir_ == -1 ? m_right.end() : m_left.end();
    int i = 0;
    for (; it != it_end; ++it)
    {
        sc_fobj_t* pfobj = (*it);
        if (pfobj == cast_)
            continue;
        if (pfobj->is_dead())
            continue;
        if (cast_->in_range(pfobj, area_))
            fobjs_[i++] = pfobj;
    }
    return i;
}

int sc_battlefield_t::find_target_HL(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_)
{
    int y = cast_->y();
    int i = 0;
    if (cast_->dir() == -1)
    {
        m_right.sort([&](sc_fobj_t* a_, sc_fobj_t* b_)->bool{
            return fabs(a_->y() - y) < fabs(b_->y() - y);
        });
        for (auto it = m_right.begin(); it != m_right.end(); ++it)
        {
            if (!((*it)->is_dead()) && cast_->in_range((*it), area_) && (*it)->y() == (*m_right.begin())->y())
                fobjs_[i++] = (*it);
        }
    }
    else
    {
        m_left.sort([&](sc_fobj_t* a_, sc_fobj_t* b_)->bool{
            return fabs(a_->y() - y) < fabs(b_->y() - y);
        });
        for (auto it = m_left.begin(); it != m_left.end(); ++it)
        {
            if (!((*it)->is_dead()) && cast_->in_range((*it), area_) && (*it)->y() == (*m_left.begin())->y())
                fobjs_[i++] = (*it);
        }
    }
    return i;
}

int sc_battlefield_t::find_target_VL(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int row)
{
    /*
    int i = 0;
    auto it = cast_->dir() == -1 ? m_right.begin() : m_left.begin();
    auto it_end = cast_->dir() == -1 ? m_right.end() : m_left.end();
    for (; it != it_end; ++it)
    {
        if ((*it)->is_dead())
            continue;

        if (cast_->in_range((*it), area_))
        {
            int sub = fabs(cast_->pro().hit_area - (*it)->pro().hit_area);
            if (row == 1 && sub <= Front)
            {
                fobjs_[i++] = (*it);
            }
            else if (row == 3 && sub > Middle && sub <= Rear)
            {
                fobjs_[i++] = (*it);
            }
        }
    }
    return i;
    */
}

int sc_battlefield_t::find_target_Ce(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, float radius)
{
    sc_fobj_t* base = select_one_targeter(cast_, area_, cast_->dir());
    int i = 0;
    auto it = cast_->dir() == -1 ? m_right.begin() : m_left.begin();
    auto it_end = cast_->dir() == -1 ? m_right.end() : m_left.end();
    float radius2 = radius * radius;
    for (; it != it_end; ++it)
    {
        if ((*it)->is_dead())
            continue;
        float x = base->x() - (*it)->x();
        float y = base->y() - (*it)->y();
        float dis = x * x + y * y;
        if (dis <= radius2)
            fobjs_[i++] = (*it);
    }
    return i;
}

int sc_battlefield_t::find_target_Cs(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_)
{
    sc_fobj_t* base = select_one_targeter(cast_, area_, cast_->dir());
    int i = 0;
    auto it = cast_->dir() == -1 ? m_right.begin() : m_left.begin();
    auto it_end = cast_->dir()== -1 ? m_right.end() : m_left.end();
    for (; it != it_end; ++it)
    {
        if ((*it)->is_dead())
            continue;

        if (cast_->in_range((*it), area_))
        {
            if ((*it)->y() == base->y())
                fobjs_[i++] = *it;
            else if ((*it)->x() - cast_->x() == base->x() - cast_->x())
                fobjs_[i++] = *it;
        }
    }
    return i;
}

int sc_battlefield_t::find_target_Al(sc_fobj_t* cast_, sc_fobj_t** fobjs_)
{
    int i = 0;
    auto it = cast_->dir() == -1 ? m_right.begin() : m_left.begin();
    auto it_end = cast_->dir()== -1 ? m_right.end() : m_left.end();
    for(; it != it_end; ++it)
    {
        if ((*it)->is_dead())
            continue;

        fobjs_[i++] = *it;
    }
    return i;
}

sc_battlefield_t::sc_battlefield_t(uint32_t seed_, sp_view_user_t left_, sp_view_user_t right_,  bool is_record, int flag_):
    m_remain_time(MAX_FRAME_TIME), m_is_over(false), m_is_win(false), m_left_anger(0), m_right_anger(0), m_left_hp(0), m_right_hp(0), m_is_record(is_record), m_random(seed_), m_dmg(0), m_left_dmg(0), m_right_dmg(0), m_flag(flag_)
{
    /*
#if USE_RECORD
    battle_record.caster = left_;
    battle_record.target = right_;
#endif
    m_views[0] = left_;
    m_views[1] = right_;
    m_fight_record.clear();

    int i = 0, s, pos;
    uint32_t b = 0u, t;
    cout << endl;
    for (auto it = left_->roles.begin(); it != left_->roles.end(); ++it)
    {
        cout << "init left " << it->first << endl;
        s = b >> it->second.pro.hit_area^Front?it->second.pro.hit_area^Middle?10:5:0;
        t = b>>s;
        pos = t&0x02u?1:t&0x08u?3:t&0x04u?2:t&0x01u?0:t&0x10u?4:2;
        b|=1u<<(s+pos);
        m_contain[i].init(this, 1, &(it->second), stand_y[pos], it->first, left_->hp_percent); // 这个血量不是这么来的
        m_left_hp += it->second.pro.hp;
        m_left.push_back(&m_contain[i]);
        ++i;
    }

    b = 0u;
    for (auto it = right_->roles.begin(); it != right_->roles.end(); ++it)
    {
        cout << "init right " << it->first << endl;
        s = b >> it->second.pro.hit_area^Front?it->second.pro.hit_area^Middle?10:5:0;
        t = b>>s;
        pos = t&0x02u?1:t&0x08u?3:t&0x04u?2:t&0x01u?0:t&0x10u?4:2;
        b|=1u<<(s+pos);
        m_contain[i].init(this, -1, &(it->second), stand_y[pos], it->first, right_->hp_percent);
        m_right_hp += it->second.pro.hp;
        m_right.push_back(&m_contain[i]);
        ++i;
    }
    cout << endl;
    */
}

int sc_battlefield_t::run()
{
    g_frame_num = 0;
    while (!m_is_over)
    {
        ++g_frame_num;
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
        sc_msg_def::jpk_arena_fight_record_t jpk_;
        jpk_.m_eventType = RET_camera_zoom_in;
        jpk_.m_time = g_frame_num;
        add_record(jpk_);
        m_is_win = false;
        m_is_over = true;
        return ;
    }
    if (false == update_live_fobjs(m_right, elapse_))
    {
        sc_msg_def::jpk_arena_fight_record_t jpk_;
        jpk_.m_eventType = RET_camera_zoom_in;
        jpk_.m_time = g_frame_num;
        add_record(jpk_);
        m_is_win = true;
        m_is_over = true;
        return ;
    }

    m_remain_time -= elapse_;
    if (m_remain_time <= 0)
    {
        sc_msg_def::jpk_arena_fight_record_t jpk_;
        jpk_.m_eventType = RET_camera_zoom_in;
        jpk_.m_time = g_frame_num;
        add_record(jpk_);
        m_is_win = false;
        m_is_over = true;
        return ;
    }

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
    for (auto it = fobjs_.begin(); it != fobjs_.end(); ++it)
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

void sc_battlefield_t::get_left_hp(unordered_map<int32_t, int32_t>& l_hp)
{
    for (auto it = m_left.begin(); it != m_left.end(); ++it)
    {
        l_hp.insert(make_pair((*it)->role().pid, (*it)->cur_hp()));
    }
}

void sc_battlefield_t::set_left_hp(unordered_map<int32_t, int32_t>& l_hp)
{
    for (auto it = m_left.begin(); it != m_left.end(); ++it)
    {
        auto l = l_hp.find((*it)->role().pid);
        if (l!= l_hp.end())
            (*it)->set_cur_hp(l->second);
    }
}

inline void sc_battlefield_t::add_left_anger(uint32_t anger_)
{
    m_left_anger += anger_;
    if (m_left_anger > MAX_POWER)
        m_left_anger = MAX_POWER;
}

inline void sc_battlefield_t::add_right_anger(uint32_t anger_)
{
    m_right_anger += anger_;
    if (m_right_anger > MAX_POWER)
        m_right_anger = MAX_POWER;
}
/*************************************************************
 * sc_battlefield_t class end
 * ***********************************************************/

/*************************************************************
 * sc_fight_cal_t class begin
 * ***********************************************************/
int sc_fight_cal_t::cal_dmg(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_, int& round_)
{
    int state = 0;
    int dmg = 0;

    auto fill_record = [&](sc_fobj_t* c_, sc_fobj_t* t_){
        if (skill_ == NULL)
            t_->record().m_skillType = normal_attack;
        else
            t_->record().m_skillType = skill_->conf_skl->skill_type;
        t_->record().m_damageValue = dmg;
        t_->record().m_attackState = state;
        t_->record().m_attackerTeamIndex = c_->team_pos();
        t_->record().m_attackerIsEnemy = c_->dir() == dir_right ? true : false;
        t_->record().m_isLethal = false;
        t_->record().record(RET_damage);
    };

    if(IS_WORLD_BOSS(cast_->role().resid) || IS_WORLD_BOSS(target_->role().resid))
        state = fs_normal;
    else if((state = rand_atk_state(r_, cast_, target_, skill_)) == fs_miss)
    {
        fill_record(cast_, target_);
        return dmg; // 技能miss不一定buff miss 得改改
    }

    if (skill_ == NULL)
    {
        auto it = find(cast_->m_cur_special_state.begin(), cast_->m_cur_special_state.end(), s_blind);
        if (it != cast_->m_cur_special_state.end())
            return 0;
        dmg = cal_nor_atk_dmg(cast_, target_, NULL);
    }
    else if (skill_->conf_skl->skill_type == active_skill)
        dmg = cal_skl_atk_dmg(cast_, target_, skill_);
    else if (skill_->conf_skl->skill_type == passive_skill && skill_->conf_skl->skill_class == 4)
        dmg = cal_ext_atk_dmg(cast_, target_, skill_);

    if (state == fs_crit)
        dmg *= STORMS_HIT_MULTIPLE;

    fill_record(cast_, target_);

    list<int>::iterator it;
    it = find(target_->m_cur_special_state.begin(), target_->m_cur_special_state.end(), s_dodge_and_anger);
    if (state == fs_miss && it != target_->m_cur_special_state.end());
    {
        //jia nu qi
    }
    if (state == fs_miss && skill_ == NULL)
    {
        it = find(cast_->m_cur_special_state.begin(), cast_->m_cur_special_state.end(), s_bloodthirsty);
        if (it != cast_->m_cur_special_state.end())
            cast_->on_hel(floor(dmg * cast_->vampiric()));
    }
    for (auto it_t = target_->m_cur_special_state.begin(); it_t != target_->m_cur_special_state.end(); ++it_t)
    {
        if ((*it_t) == s_thorns || (*it_t) == h_throns)
        {
            cast_->on_dmg(target_, floor(dmg * target_->thorns()));
            break;
        }
    }
    if (IS_WORLD_BOSS(cast_->role().resid))
    {
        if (round_ < 7)
        {
            if (dmg < cast_->pro().atk/2)
                dmg = cast_->pro().atk/2;
        }
        else
            dmg = 9990000;
        ++round_;
    }
    return dmg > 0 ? dmg : 1;
}

int sc_fight_cal_t::rand_atk_state(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    int acc_pro = skill_ != NULL ? cal_skl_acc_pro(cast_, target_, skill_) : cal_acc_pro(cast_, target_, NULL);
    if ((int)(r_.rand_integer(1, 100)) > acc_pro)
        return fs_miss;
    int cri_pro = cal_cri_pro(cast_, target_);
    if ((int)(r_.rand_integer(1, 100)) > cri_pro)
        return fs_normal;
    return fs_crit;
}

int sc_fight_cal_t::cal_nor_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    double phy_atk = cast_->atk() * random_t::rand_integer(MIN_DMG_PER, MAX_DMG_PER) / 100;
    double att_dmg = phy_atk * cast_->atk_fac();
    double def_dmg = target_->def() * target_->def_fac();
    double dmg = (att_dmg - def_dmg) * (1 - target_->imm());
    int d = floor(dmg * cal_lvl_suppress(cast_, target_, skill_, LEVEL_TO_SUPRESS_DAMAGE_RATE));
    return d <= 0 ? 1 : d;
}

int sc_fight_cal_t::cal_ext_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    double phy_atk = cast_->atk() * random_t::rand_integer(MIN_DMG_PER, MAX_DMG_PER) / 100;
    double ext_dmg = (phy_atk + cast_->mgc()) * cast_->cha_fac();
    double def_dmg = target_->res() * target_->res_fac();
    double halo_add = 0;
    double mark_add = 0;
    double factor = skill_->dmg_fac() * skill_->conf_skl->skill_factor;
    double dmg = (ext_dmg - def_dmg) * (1 - target_->imm()) * EXTRA_ATTACK_PERCENT * factor * (1 + halo_add + mark_add);
    int d = floor(dmg * cal_lvl_suppress(cast_, target_, skill_, LEVEL_TO_SUPRESS_DAMAGE_RATE));
    return d <= 0 ? 1 : d;
}

int sc_fight_cal_t::cal_skl_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    double phy_atk = cast_->atk() * random_t::rand_integer(MIN_DMG_PER, MAX_DMG_PER) / 100;
    double skl_dmg = (phy_atk + cast_->mgc()) * cast_->mgc_fac();
    double def_dmg = target_->res() * target_->res_fac();
    double halo_add = 0;
    double mark_add = 0;
    double factor = skill_->dmg_fac() * skill_->conf_skl->skill_factor;
    double dmg = (skl_dmg - def_dmg) * (1 - target_->imm()) * factor * (1 + halo_add + mark_add);
    int d = floor(dmg * cal_lvl_suppress(cast_, target_, skill_, LEVEL_TO_SUPRESS_DAMAGE_RATE));
    return d <= 0 ? 1 : d;
}

double sc_fight_cal_t::pro_check_and_amend(double pro)
{
    if (pro < 0) return 0.0f;
    if (pro > 1) return 1.0f;
    return pro;
}

double sc_fight_cal_t::base_cri_pro(sc_fobj_t* fobj_)
{
    double cri_pro = 0.15f + fobj_->cir() * 5.0f / fobj_->role().lvl.level / 100.0f;
    return pro_check_and_amend(cri_pro);
}

double sc_fight_cal_t::base_def_cri_pro(sc_fobj_t* fobj_)
{
    double def_cri_pro = 0.15f + fobj_->ten() * 5.0f / fobj_->role().lvl.level / 100.0f;
    return pro_check_and_amend(def_cri_pro);
}

double sc_fight_cal_t::base_acc_pro(sc_fobj_t* fobj_)
{
    double acc_pro = 0.92f + fobj_->acc() * 5.0f / fobj_->role().lvl.level / 100.0f;
    return pro_check_and_amend(acc_pro);
}

double sc_fight_cal_t::base_dod_pro(sc_fobj_t* fobj_)
{
    double dod_pro = 0.05f + fobj_->dod() * 5.0f / fobj_->role().lvl.level / 100.0f;
    return pro_check_and_amend(dod_pro);
}

double sc_fight_cal_t::cal_lvl_suppress(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_, double rate_)
{
    double sup_lvl = 0;
    if (skill_ == NULL)
        sup_lvl = target_->role().lvl.level - SUPPRESS_LEVEL - cast_->role().lvl.level;
    else
        sup_lvl = target_->role().lvl.level - SUPPRESS_LEVEL - skill_->level;
    return sup_lvl <= 0 ? 1 : pow(rate_, sup_lvl);
}

int sc_fight_cal_t::cal_cri_pro(sc_fobj_t* cast_, sc_fobj_t* target_)
{
    double cri_pro = ceil(base_cri_pro(cast_) * (1 - base_def_cri_pro(target_)) * 100) / 100;
    return (int)(pro_check_and_amend(cri_pro) * 100);
}

int sc_fight_cal_t::cal_acc_pro(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    double acc_pro = base_acc_pro(cast_) * (1 - base_dod_pro(target_)) * cal_lvl_suppress(cast_, target_, skill_, LEVEL_TO_SUPRESS_ACCURACY_RATE);
    return (int)(pro_check_and_amend(acc_pro) * 100);
}

int sc_fight_cal_t::cal_skl_acc_pro(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_)
{
    double skl_pro = skill_->conf_skl->skill_accuaracy * cal_lvl_suppress(cast_, target_, skill_, LEVEL_TO_SUPRESS_ACCURACY_RATE);
    return (int)(pro_check_and_amend(skl_pro) * 100);
}
/*************************************************************
 * sc_fight_cal_t class end
 * ***********************************************************/
