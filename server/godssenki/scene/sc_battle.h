#ifndef _sc_battle_h_
#define _sc_battle_h_

#include <vector>
using namespace std;

#include "random.h"
#include "repo_def.h"
#include "msg_def.h"

typedef sc_msg_def::jpk_view_role_data_t role_t;
typedef sc_msg_def::jpk_role_pro_t  role_pro_t;

class sc_battlefield_t;
class sc_fobj_t
{
    typedef repo_def::role_fight_t      conf_fight_t;
    typedef repo_def::skill_t           conf_skill_t;
    typedef repo_def::skill_effect_t    conf_effect_t;
    typedef repo_def::buff_t            conf_buff_t;

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

    struct fskill_t
    {
        sc_fobj_t       *own;
        sc_fobj_t*      lock_targets[5];
        sc_fobj_t*      lock_targets2[5];
        conf_skill_t    *conf_skl;
        conf_buff_t     *conf_buf;
        conf_buff_t     *conf_buf2;
        conf_effect_t   *conf_eff;
        int             cd;
        int             actiontime;
        int             time;

        fskill_t(sc_fobj_t* fobj_):own(fobj_),cd(0),actiontime(0),time(0){
            memset(lock_targets, 0, sizeof(lock_targets));
            memset(lock_targets2, 0, sizeof(lock_targets2));
        }

        void begin_skill();
        bool enable_begin_skill();
        bool enable_cast_skill();
        void cast_skill(); 
        void update_skl_cd(int elapse_);
        int search_skl_target();
        int search_skl_target2();
    };

    typedef boost::shared_ptr<fskill_t> sp_fskill_t;
public:
    sc_fobj_t();
    ~sc_fobj_t();

    void init(sc_battlefield_t* field_, int dir_, role_t* role_, int team_pos_, float hp_percent_);
    void update(int elapse_);

    bool is_dead()              { return m_hp <= 0; }
    int  dir()                  { return m_dir; }
    int  team_pos()             { return m_team_pos; }
    float x()                   { return m_x; }
    role_pro_t& pro()           { return m_role->pro; }
    role_t& role()              { return *m_role; }
    sc_battlefield_t& field()   { return *m_field; }
    float buffstate(int s_)     { return m_bufstate[s_]; }
    bool in_range(sc_fobj_t* fobj_, float area_);
    float get_bufv(int pt_);
private:
    void wait(int elapse_);
    void move(int elapse_);

    void fight_atk(int elapse_);
    bool search_atk_target();
    void update_atk_cd(int elapse_);
    void begin_atk();
    void cast_atk();
    bool enable_cast_atk();

    void fight_act_skill(int elapse_);
    void fight_aut_skill(int elapse_);

    void on_dmg(int skid_, int dmg_);
    void on_hel(int hel_);
    void on_buff(sc_fobj_t* caster_, conf_buff_t* buff_);
    void update_buf(int elapse_);
    void on_buff_effect(fbuf_t& buf_);
    void on_buff_begin(fbuf_t& buf_);
    void on_buff_end(fbuf_t& buf_);
private:
    void record();
private:
    int                 m_uid;
    sc_battlefield_t*   m_field;
    role_t*             m_role;
    conf_fight_t        m_conf_fight;
    int                 m_dir;
    int                 m_team_pos;
    float               m_x;
    int                 m_state;
    int                 m_wait_time;
    int                 m_atk_cd;
    sc_fobj_t*          m_atk_target;
    int                 m_atk_actiontime;
    int                 m_atk_time;
    int                 m_power;
    int                 m_hp;
    int                 m_dmg;
    int                 m_round;
    list<fbuf_t>        m_attach_bufs;
    fskill_t            *m_act_skl;
    fskill_t            *m_aut_skl;
    int                 m_cast_num;
    bool                m_aut_skl_cast_num;
    float               m_bufstate[8];
};

class sc_battlefield_t
{
public:
    sc_battlefield_t(uint32_t seed_, sp_view_user_t left_, sp_view_user_t right_, int flag_=0);

    int run();
    int& flag() { return m_flag; }
    bool is_win() { return m_is_win; }
    uint32_t total_dmg() { return m_dmg; }
    uint32_t& left_dmg() { return m_left_dmg; }
    uint32_t& right_dmg() { return m_right_dmg; }
    void add_dmg(int dmg_) { m_dmg += dmg_; }

    sc_fobj_t* find_first_target(sc_fobj_t* cast_, int area_, int dir_, bool includeme_ = false);
    sc_fobj_t* find_first_target_inv(sc_fobj_t* cast_, int area_, int dir_, bool includeme_ = false);
    int find_target_in_area(sc_fobj_t* cast_, int area_, sc_fobj_t** fobjs_, int dir_);
    int find_target_in_area(sc_fobj_t* cast_, sc_fobj_t* lock_targ_, int area_, sc_fobj_t** fobjs_, int dir_);

    template<class F>
    void foreach(list<sc_fobj_t*>& fobjs_, F fun_)
    {
        for(auto it = fobjs_.begin(); it!=fobjs_.end(); it++)
        {
            sc_fobj_t* pfobj = (*it);
            fun_(*pfobj);
        }
    }

    random_t& random()              { return m_random; }

    list<sc_fobj_t*>& left()        { return m_left; }
    list<sc_fobj_t*>& right()       { return m_right; }
private:
    void update(int elapse_);
    bool update_live_fobjs(list<sc_fobj_t*>& fobjs_, int elapse_);
private:
    sp_view_user_t      m_views[2];
    list<sc_fobj_t*>    m_left;
    list<sc_fobj_t*>    m_right;
    sc_fobj_t           m_contain[12];
    int                 m_remain_time;
    bool                m_is_over;
    bool                m_is_win;
    random_t            m_random;
    uint32_t            m_dmg;
    uint32_t            m_left_dmg;
    uint32_t            m_right_dmg;
    int                 m_flag;
};

struct sc_fight_cal_t
{
    static int cal_dmg(random_t& r_, sc_fobj_t* cast_, sc_fobj_t* targ_, int val1_, int &round_);
};

#endif
