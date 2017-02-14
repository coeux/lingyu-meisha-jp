#include "sc_boss.h"
#include "sc_logic.h"
#include "sc_message.h"
#include "sc_battle_pvp.h"
#include "sc_cache.h"
#include "sc_gang.h"
#include "code_def.h"
#include "repo_def.h"
#include "log.h"
#include "date_helper.h"

#define LOG "SC_GANG_BOSS"

//公会boss的表格id
#define BOSS_RESID 3100

//玩家前5分钟开始准备
#define PREPARE_TIME 300

//每两次战斗之间需要间隔15秒
#define FIGHT_CD 15

//boss持续90分钟, 5400秒
#define BOSS_TIME 5400

//开始时间是21点
#define BEGIN_TIME (21*3600)

//一天的总秒数
#define SECONDS_DAY 86400

sc_gang_boss_t::sc_gang_boss_t(sc_gang_t& gang_):
    m_gang(gang_),
    m_started_time(0),
    m_ref_hp(NULL),
    m_hpmax(0),
    m_state(state_closed)
{
}
int sc_gang_boss_t::unicast_boss_info(sp_ganguser_t sp_guser_)
{
    check_time();

    sc_msg_def::ret_gboss_info_t ret;
    ret.resid = BOSS_RESID;
    ret.hpmax = m_hpmax;
    ret.countdown = countdown();

    if (has_state(state_prepared) || has_state(state_started))
    {
        ret.hp = *m_ref_hp;

        if (is_time_over())
        {
            on_gone();
        }
    }

    logic.unicast(sp_guser_->db.uid, ret);

    return SUCCESS;
}
int sc_gang_boss_t::unicast_rank(sp_ganguser_t sp_guser_)
{
    sc_msg_def::ret_gboss_rank_t ret;

    for(size_t i=0; i<m_targets.size(); i++)
    {
        if (i<10 || m_targets[i]->uid == sp_guser_->db.uid)
        {
            sc_msg_def::jpk_gboss_rank_t jpk;
            jpk.uid = m_targets[i]->uid;
            jpk.nickname = m_targets[i]->nickname;
            jpk.dmg = m_targets[i]->dmg;
            jpk.rank = i+1;
            ret.rank.push_back(std::move(jpk));
        }
    }

    logic.unicast(sp_guser_->db.uid, ret);

    return SUCCESS;
}
int sc_gang_boss_t::fight(sp_ganguser_t sp_guser_)
{
    sp_target_t sp_target;
    if (!get_target(sp_guser_->db.uid, sp_target))
    {
        sp_target.reset(new target_t);
        sp_target->uid = sp_guser_->db.uid;
        sp_target->nickname = sp_guser_->db.nickname();
        sp_target->dmg = 0;
        m_targets.push_back(sp_target);
    }

    //产生随机种子
    uint32_t rseed = random_t::rand_integer(10000, 100000);
    sp_view_user_t sp_cast_data = view_cache.get_view(sp_guser_->db.uid);

    sc_battlefield_t field(rseed, sp_cast_data, m_boss);
    int n = field.run();
    //保存胜负
    bool is_win = field.is_win();
    //产生战斗伤害
    int32_t damage = field.total_dmg();

    logwarn((LOG, "boss battle total frames:%d, damge:%d, is_win:%d", n, damage, is_win));

    //更新排名
    update_rank(sp_guser_->db.uid, damage);

    //更新bosshp
    update_hp(sp_guser_->db.uid, damage);

    if (is_win)
    {
        m_gang.on_boss_killed(sp_guser_);
    }

    return SUCCESS;
}
void sc_gang_boss_t::spawn_boss()
{
    //获取boss血量
    auto it = repo_mgr.guildboss.find(m_gang.db.bosslv);
    if( it == repo_mgr.guildboss.end() )
    {
        logerror((LOG, "spawn_boss, repo no grade:%d", m_gang.db.bosslv));
        return;
    }

    m_targets.clear();
    m_boss->roles.clear();

    sc_msg_def::jpk_view_role_data_t vboss;
    m_hpmax = vboss.pro.hp = it->second.hp;
    vboss.pro.atk = it->second.atk;
    vboss.pro.mgc = it->second.mgc;
    vboss.pro.def = it->second.def;
    vboss.pro.res = it->second.res;
    vboss.pro.cri = it->second.crit;
    vboss.pro.acc = it->second.acc;
    vboss.pro.dodge = it->second.dodge;
    vboss.resid = BOSS_RESID;
    vboss.lvl.level = m_gang.db.bosslv;
    vboss.skls.resize(1);

    repo_def::monster_t* rp_monster = repo_mgr.monster.get(BOSS_RESID);
    if (rp_monster == NULL)
    {
        logerror((LOG, "spawn_boss, repo no monster:%d", BOSS_RESID));
    }
    vboss.skls[0].resid = rp_monster->skill;
    vboss.skls[0].level = 1;

    m_boss->roles.insert(std::move(make_pair(1, std::move(vboss))));

    m_boss.reset(new sc_msg_def::jpk_view_user_data_t());
    m_ref_hp = &(m_boss->roles[1].pro.hp);
}
void sc_gang_boss_t::update_hp(int uid_, int damage_)
{
    float oldp = (*m_ref_hp / (float)m_hpmax);
    *m_ref_hp -= damage_;
    float nowp = (*m_ref_hp / (float)m_hpmax);
    if (oldp > 0.1f &&  nowp <= 0.1f)
    {
        //通告boss血量不足
    }

    //产生每次挑战的奖励
    auto it = repo_mgr.guildboss.find(m_gang.db.bosslv);
    if( it != repo_mgr.guildboss.end() )
    {
        sp_user_t sp_user;
        if (logic.usermgr().get(uid_, sp_user))
        {
            sp_user->on_money_change(it->second.join_coin);
            sp_user->save_db();
        }
        else
        {
            logerror((LOG, "update_hp, no online user:%d",uid_));
        }
    }
    else
    {
        logerror((LOG, "update_hp, repo guildboss no grade:%d", m_gang.db.bosslv));
    }

    if (*m_ref_hp <= 0)
    {
        on_dead(uid_);
    }
}
void sc_gang_boss_t::on_dead(int uid_)
{
    //boss成长
    uint32_t off = date_helper.cur_sec() - m_started_time;
    bool change = false;
    if( off < 60 )
    {
        m_gang.db.set_bosslv(m_gang.db.bosslv + 3);
        change = true;
    }
    else
    {
        if( off < 180 )
        {
            m_gang.db.set_bosslv(m_gang.db.bosslv + 2);
            change = true;
        }
        else
        {
            if( off < 300)
            {
                m_gang.db.set_bosslv(m_gang.db.bosslv + 1);
                change = true;
            }
        }
    }
    if (change)
    {
        m_gang.save_db();
    }

    //发布奖励

    //通告boss击杀

    //清除boss
    m_boss->roles.clear();
} 
void sc_gang_boss_t::on_gone()
{
    //通告boss逃跑
    //关闭公会boss
    set_state(state_closed);
}
void sc_gang_boss_t::update_rank(int uid_, int damage_)
{
    sp_target_t sp_target;
    if (get_target(uid_, sp_target))
    {
        sp_target->dmg += damage_;
        std::sort(m_targets.begin(), m_targets.end(), [](const sp_target_t& a_, const sp_target_t& b_){
            return (a_->dmg > b_->dmg);
        });
    }
}
bool sc_gang_boss_t::get_target(int uid_, sp_target_t& sp_target_)
{
    for(sp_target_t sp_target:m_targets)
    {
        if (sp_target->uid == uid_)
        {
            sp_target_ = sp_target;
            return true;
        }
    }
    return false;
}
bool sc_gang_boss_t::is_time_over()
{
    if (!has_state(state_started))
        return true;

    uint32_t off = date_helper.cur_sec() - m_started_time;
    return (off >= BOSS_TIME);
}
void sc_gang_boss_t::check_time()
{
    if (date_helper.cur_dayofweek() == m_gang.db.bossday)
    {
        if (!has_state(state_prepared) && date_helper.secoffday() >= (BEGIN_TIME-PREPARE_TIME) && date_helper.secoffday() < BEGIN_TIME)
        {
            set_state(state_prepared);
        }
        else if (!has_state(state_started) && date_helper.secoffday() >= BEGIN_TIME)
        {
            set_state(state_started);
        }
    }
}
void sc_gang_boss_t::set_state(int state_)
{
    m_state = state_;
    switch(m_state)
    {
    case state_closed:
        on_close();
    break;
    case state_prepared:
        on_prepare();
    break;
    case state_started:
        on_start();
    break;
    }
}
void sc_gang_boss_t::on_prepare()
{
    //通知公会boss进入准备阶段
    //创建boss
    spawn_boss();
}
void sc_gang_boss_t::on_start()
{
    //通知公会boss战开始
    //记录开始时间
    m_started_time = date_helper.cur_sec();
}
void sc_gang_boss_t::on_close()
{
    //通知公会关闭
    m_boss->roles.clear();
    m_ref_hp = NULL;
    m_hpmax = 0;
}
int sc_gang_boss_t::countdown()
{
    int nday = date_helper.cur_dayofweek();
    if (nday == 0) nday = 7;
    int tday = m_gang.db.bossday;
    if (tday == 0) tday = 7;
    int offday = tday - nday;
    int offsec = 0;
    if (offday >= 0)
        offsec = (offday * SECONDS_DAY + BEGIN_TIME)-date_helper.secoffday();
    else 
        offsec = ((offday+7)* SECONDS_DAY+BEGIN_TIME)-date_helper.secoffday(); 
    return offsec;
}
