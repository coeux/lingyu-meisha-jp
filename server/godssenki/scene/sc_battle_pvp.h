#ifndef _sc_battle_pvp_h_
#define _sc_battle_pvp_h_

#include <vector>
#include <string>
using namespace std;

#include "random.h"
#include "repo_def.h"
#include "msg_def.h"

typedef sc_msg_def::jpk_view_role_data_t role_t;
typedef sc_msg_def::jpk_role_pro_t       role_pro_t;
typedef repo_def::skill_t        conf_skill_t;

class sc_battlefield_t;
class sc_record_t;
class sc_fobj_t
{
    typedef repo_def::role_fight_t   conf_fight_t;
    typedef repo_def::skill_effect_t conf_effect_t;
    typedef repo_def::buff_t         conf_buff_t;

    struct fbuf_t
    {
        sc_fobj_t* caster;
        sc_fobj_t* target;
        conf_buff_t* conf;
        int effect_times;
        int last_time;
        int cast_time;

        fbuf_t(sc_fobj_t* caster_, sc_fobj_t* target_, conf_buff_t* buf_):
            caster(caster_),
            target(target_),
            conf(buf_),
            effect_times(buf_->effect_times - 1),
            last_time(buf_->last_time * 1000),
            cast_time(0)
        {}

        void reset_cast_time()
        {
            cast_time = ((last_time / (float)effect_times) * 1000);
        }
    };

public:
    struct fskill_t
    {
        sc_fobj_t*     own;
        sc_fobj_t*     lock_enemy[5];
        sc_fobj_t*     lock_ally[5];
        conf_skill_t*  conf_skl;
        map<int32_t, conf_buff_t*>   hm_conf_bufs;
        conf_effect_t* conf_eff;
        int            level;
        int            cd;
        int            actiontime;
        int            time;
        int            cast_times;

        fskill_t(sc_fobj_t* fobj_):
            own(fobj_), 
            level(1),
            cd(0), 
            actiontime(0), 
            time(0), 
            cast_times(0)
        {
            memset(lock_enemy, 0, sizeof(lock_enemy));
            memset(lock_ally, 0, sizeof(lock_ally));
        }

        bool enable_begin_skill();
        void begin_skill();
        bool enable_cast_skill();
        void cast_skill();
        void update_skl_cd(int elapse_);
        int search_skl_enemy();
        int search_skl_ally();
    public:
        float dmg_fac();
    };

    typedef boost::shared_ptr<fskill_t> sp_fskill_t;

//public:
    sc_fobj_t();
    ~sc_fobj_t();

    void init(sc_battlefield_t* field_, int dir_, role_t* role_, int y_, int team_pos_, float hp_percent_);
    void update(int elapse);

    bool is_dead()                 { return m_cur_hp <= 0; }
    int dir()                      { return m_dir; }
    int team_pos()                 { return m_team_pos; }
    float x()                      { return m_x; }
    float y()                      { return m_y; }
    role_pro_t& pro()              { return m_role->pro; }
    role_t& role()                 { return *m_role; }
    sc_battlefield_t& field()      { return *m_field; }
    sc_record_t& record()          { return *m_record; }
    conf_fight_t& conf_fight()     { return m_conf_fight; }

    void set_cur_hp(int hp) { m_cur_hp = hp; }
    int hp()         const { return m_hp; }
    int cur_hp()     const { return m_cur_hp; } 
    float atk()      const { return m_cur_phy_atk; }
    float def()      const { return m_cur_phy_def; }
    float mgc()      const { return m_cur_mgc_atk; }
    float res()      const { return m_cur_mgc_def; }
    float cir()      const { return m_cur_cir; }
    float ten()      const { return m_cur_ten; }
    float acc()      const { return m_cur_acc; }
    float dod()      const { return m_cur_dod; }
    float imm()      const { return m_cur_imm; }
    float atk_fac()  const { return m_phy_atk_fac; }
    float def_fac()  const { return m_phy_def_fac; }
    float mgc_fac()  const { return m_mgc_atk_fac; }
    float res_fac()  const { return m_mgc_def_fac; }
    float cha_fac()  const { return m_cha_fac; }
    float thorns()   const { return m_thorns_pro; }
    float vampiric() const { return m_vampiric_pro; }
    int atk_count()  const { return m_atk_count; };
    //list<int> special() const { return m_cur_special_state; }
    list<int>            m_cur_special_state;

    bool in_range(sc_fobj_t* fobj_, float area_);
    void on_dmg(sc_fobj_t* cast_, int dmg_);
    void on_hel(int hel_);
private:
    void wait(int elapse_);
    void move(int elapse_);

    bool search_atk_target();
    void fight_atk(int elapse_);
    void begin_atk();
    bool enable_cast_atk();
    void cast_atk();
    void update_atk_cd(int elapse_);
    void update_buf(int elapse_);

    void fight_skill(fskill_t* &skill_, int elapse_);

    void on_buff(sc_fobj_t* caster_, conf_buff_t* buff_);
    void on_buff_begin(fbuf_t& buf_);
    void on_buff_effect(fbuf_t& buf_);
    void on_special_state_effect(int state_type, float value_);
    void on_buff_end(fbuf_t& buf_);

    void change_property_data(int type_, int value_);
    float get_property_data(int type_);
private:
    int                  m_uid;
    sc_battlefield_t*    m_field;
    role_t*              m_role;
    conf_fight_t         m_conf_fight;
    int                  m_dir;
    int                  m_team_pos;
    float                m_x;
    float                m_y;
    uint32_t             m_state;
    int                  m_wait_time;
    int                  m_atk_cd;
    sc_fobj_t*           m_atk_target;
    int                  m_atk_actiontime;
    int                  m_atk_time;
    bool                 m_in;
    sc_record_t*         m_record;
    int                  m_atk_count;

    int                  m_hp;
    int                  m_cur_hp;
    int                  m_cur_phy_atk;
    int                  m_cur_phy_def;
    int                  m_cur_mgc_atk;
    int                  m_cur_mgc_def;
    int                  m_cur_cir;
    int                  m_cur_ten;
    int                  m_cur_acc;
    int                  m_cur_dod;
    float                m_cur_imm;

    //float m_cur_ang; // ???? !!!!!!!!!!!!!!!!!!!!
    float m_phy_atk_fac;
    float m_phy_def_fac;
    float m_mgc_atk_fac;
    float m_mgc_def_fac;
    float m_cha_fac;

    float m_recover_effect;
    float m_more_anger;
    float m_dodge_add_anger;
    float m_thorns_pro;
    float m_vampiric_pro;
    float m_real_dam_pro;
    float m_combo_dam_pro;
    float m_skill_add[5];
    float m_mark_add[5];

    int                  m_dmg;
    int                  m_round;
    list<fbuf_t>         m_attach_bufs;
    fskill_t             *m_act_skl1;
    fskill_t             *m_act_skl2;
    fskill_t             *m_act_skl3;
    fskill_t             *m_aut_skl1;
    fskill_t             *m_aut_skl2;
    fskill_t             *m_aut_skl3;
    //float                m_bufstate[8];
};

class sc_battlefield_t
{
public:
    sc_battlefield_t(uint32_t seek_, sp_view_user_t left_, sp_view_user_t right_, bool is_record = true, int flag_ = 0);

    int run();
    void set_left_hp(unordered_map<int32_t, int32_t>& l_hp);
    void get_left_hp(unordered_map<int32_t, int32_t>& l_hp);
    int& flag()              { return m_flag; }
    bool is_win()            { return m_is_win; }

    uint32_t total_dmg()     { return m_dmg; }
    uint32_t& left_dmg()     { return m_left_dmg; }
    uint32_t& right_dmg()    { return m_right_dmg; }
    void add_dmg(int dmg_)   { m_dmg += dmg_; }

    uint32_t& left_anger()   { return m_left_anger; }
    uint32_t& right_anger()  { return m_right_anger; }
    void add_left_anger(uint32_t anger_);
    void add_right_anger(uint32_t anger_);

    const uint32_t left_hp() const { return m_left_hp; }
    const uint32_t right_hp() const { return m_right_hp; }

    bool is_record()         { return m_is_record; }

    int find_target_in_area(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int dir_);
    sc_fobj_t* select_one_targeter(sc_fobj_t* cast_, int area_, int dir_);
    int find_target_Pt(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int type);
    int find_target_HL(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_);
    int find_target_VL(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int row);
    int find_target_Ce(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, float radius);
    int find_target_Cs(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_);
    int find_target_Al(sc_fobj_t* cast_, sc_fobj_t** fobjs_);

    template<class F>
    void foreach(list<sc_fobj_t*>& fobjs_, F fun_)
    {
        for (auto it = fobjs_.begin(); it != fobjs_.end(); ++it)
        {
            sc_fobj_t* pfobj = (*it);
            fun_(*pfobj);
        }
    }

    random_t& random()        { return m_random; }

    list<sc_fobj_t*>& left()  { return m_left; }
    list<sc_fobj_t*>& right() { return m_right; }
    uint32_t num() { return g_frame_num; }
    void add_record(sc_msg_def::jpk_arena_fight_record_t &jpk_) {
        m_fight_record.push_back(std::move(jpk_));
    }
    void fill_record(vector<sc_msg_def::jpk_arena_fight_record_t> &ret_) {
        for (auto it = m_fight_record.begin(); it != m_fight_record.end(); ++it)
        {
            ret_.push_back(std::move(*it));
        }
        m_fight_record.clear();
    }
private:
    void update(int elapse_);
    bool update_live_fobjs(list<sc_fobj_t*>& fobjs_, int elapse_);
private:
    sp_view_user_t        m_views[2];
    list<sc_fobj_t*>      m_left;
    list<sc_fobj_t*>      m_right;
    sc_fobj_t             m_contain[10];
    int                   m_remain_time;
    bool                  m_is_over;
    bool                  m_is_win;
    uint32_t              m_left_anger;
    uint32_t              m_right_anger;
    uint32_t              m_left_hp;
    uint32_t              m_right_hp;
    bool                  m_is_record;
    random_t              m_random;
    uint32_t              m_dmg;
    uint32_t              m_left_dmg;
    uint32_t              m_right_dmg;
    int                   m_flag;
    uint32_t              g_frame_num;
    vector<sc_msg_def::jpk_arena_fight_record_t> m_fight_record;
};

struct sc_fight_cal_t
{

    static int cal_dmg(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* targ_, sc_fobj_t::fskill_t* skill_, int &round_);
    static int cal_skl_acc_pro(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);
    static double cal_lvl_suppress(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_, double rate_);
    static int rand_atk_state(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);
    static int cal_nor_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);
    static int cal_ext_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);
    static int cal_skl_atk_dmg(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);
    static double pro_check_and_amend(double pro);
    static double base_cri_pro(sc_fobj_t* fobj_);
    static double base_def_cri_pro(sc_fobj_t* fobj_);
    static double base_acc_pro(sc_fobj_t* fobj_);
    static double base_dod_pro(sc_fobj_t* fobj_);
    static int cal_cri_pro(sc_fobj_t* cast_, sc_fobj_t* target_);
    static int cal_acc_pro(sc_fobj_t* cast_, sc_fobj_t* target_, sc_fobj_t::fskill_t* skill_);

};

class sc_record_t
{
public:
    sc_record_t(sc_fobj_t* sc_fobj_):
        m_recorder(sc_fobj_),
        m_eventType(0), 
        m_time(0), 
        m_isEnemy(false), 
        m_actorTeamIndex(0),
        m_x(0),
        m_y(0),
        m_targeterIsEnemy(0),
        m_targeterTeamID(0),
        m_skillType(0),
        m_attackState(0),
        m_damageValue(0),
        m_attackerTeamIndex(0),
        m_attackerIsEnemy(0),
        m_isLethal(false),
        m_buffResID(""),
        m_buffID(0),
        m_state(0),
        m_cur_state(0)
    {};
    void record(int32_t event_type);
//private:
    sc_fobj_t*          m_recorder;
    int32_t             m_eventType;
    uint32_t            m_time;
    bool                m_isEnemy;
    int32_t             m_actorTeamIndex;
    int32_t             m_x;
    int32_t             m_y;

    int32_t             m_targeterIsEnemy;
    int32_t             m_targeterTeamID;
    int32_t             m_skillType;
    int32_t             m_attackState;
    int32_t             m_damageValue;
    int32_t             m_attackerTeamIndex;
    int32_t             m_attackerIsEnemy;
    int32_t             m_isLethal; // false
    string              m_buffResID;
    int32_t             m_buffID;
    int32_t             m_state;

    uint32_t             m_cur_state;
};
#endif
