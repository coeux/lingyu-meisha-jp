#include "sc_practice.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_partner.h"

#include <sys/time.h>

#include "repo_def.h"
#include "code_def.h"
#include "msg_def.h"

#define LOG "SC_PRACTICE"
#define PRACTICE_CD 28800
#define CARBET_LV_1ST 18
#define CARBET_LV_2ND 40
#define CARBET_VIPLV_3ST 3
#define COST_PER_HOUR 5

sc_practice_t::sc_practice_t(sc_user_t& user_):m_user(user_)
{
}
void sc_practice_t::clear_cd(int32_t pos_)
{
    sc_msg_def::ret_practice_clear_t ret;
    ret.pos = pos_;

    int32_t last_prac = practice_cache.get_last_prac(m_user.db.uid,pos_);
    //客户端非法请求
    if( -1 == last_prac )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //位置未开放
    if( 0==last_prac )
    {
        int32_t open = 0;
        switch( pos_ )
        {
            case 0:
                {
                    if( m_user.db.grade >= 20 )
                    {
                        practice_cache.clear(m_user.db.uid,0);
                        open =1;
                    }
                }
                break;
            case 1:
                {
                    if( m_user.db.grade >= 40 )
                    {
                        practice_cache.clear(m_user.db.uid,1);
                        open = 1;
                    }
                }
                break;
            case 2:
                {
                    if( m_user.db.viplevel >= 3 )
                    {
                        practice_cache.clear(m_user.db.uid,2);
                        open = 1;
                    }
                }
        }
        if( 0==open)
        {
            ret.code = ERROR_SC_PRACTICE_LOCKED;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }

    //位置不需要清除cd
    struct timeval tm;
    gettimeofday(&tm, NULL);
    if( (tm.tv_sec-last_prac)>=PRACTICE_CD )
    {
        ret.code = ERROR_SC_PRACTICE_NO_CLEAR;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //计算价钱
    //int32_t n_yb = ((last_prac+PRACTICE_CD-tm.tv_sec-1)/3600+1)*COST_PER_HOUR;
    uint32_t cd = ((last_prac+PRACTICE_CD-tm.tv_sec-1)/3600+1);
    int32_t code = m_user.vip.buy_vip(vop_acc_trial, cd);
    if (code == SUCCESS)
    {
        //更新cd时间
        practice_cache.clear(m_user.db.uid,pos_);
    }

    ret.code = code;
    logic.unicast(m_user.db.uid, ret);
}
void sc_practice_t::practice_partner(int32_t pos_, int32_t pid_, int32_t type_)
{
    sc_msg_def::ret_practice_partner_t ret;
    ret.pos = pos_;

    //该伙伴是否有资格训练
    sp_partner_t partner = m_user.partner_mgr.get(pid_);

    //客户端非法请求
    if( (NULL == partner) || ((type_!=1)&&(type_!=2)) || (m_user.db.grade<CARBET_LV_1ST) )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //伙伴与主角等级相等，不能训练
    if( partner->db.grade == m_user.db.grade )
    {
        ret.code = ERROR_SC_PRACTICE_LV_EQUAL;
        logic.unicast(m_user.db.uid, ret);
        return;
    }


    //更新cd时间
    practice_cache.clear(m_user.db.uid,pos_);

    //位置是否冷却
    int32_t last_prac = practice_cache.get_last_prac(m_user.db.uid,pos_);
    //客户端非法请求
    if( -1 == last_prac )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    //位置未开放
    if( 0==last_prac )
    {
        int32_t open = 0;
        switch( pos_ )
        {
            case 0:
                {
                    if( m_user.db.grade >= 20 )
                    {
                        practice_cache.clear(m_user.db.uid,0);
                        open =1;
                    }
                }
                break;
            case 1:
                {
                    if( m_user.db.grade >= 40 )
                    {
                        practice_cache.clear(m_user.db.uid,1);
                        open = 1;
                    }
                }
                break;
            case 2:
                {
                    if( m_user.db.viplevel >= 3 )
                    {
                        practice_cache.clear(m_user.db.uid,2);
                        open = 1;
                    }
                }
        }
        if( 0==open)
        {
            ret.code = ERROR_SC_PRACTICE_LOCKED;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }
    //位置cd
    struct timeval tm;
    gettimeofday(&tm, NULL);
    if( (tm.tv_sec-last_prac)<PRACTICE_CD )
    {
        ret.code = ERROR_SC_PRACTICE_CD;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //所有条件都满足，开始训练
    //计算所得经验
    if( 1==type_ )
    {
        //普通训练
        int32_t exp_key = m_user.db.grade - m_user.db.grade%10;

        repo_def::practice_t *p_practice = repo_mgr.practice.get(exp_key);
        if( p_practice == NULL )
        {
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return;
        }

        int32_t exp;
        if( (p_practice->exp + partner->db.exp) > m_user.db.exp )
            exp = m_user.db.exp - partner->db.exp;
        else
            exp = p_practice->exp;
        partner->on_exp_change(exp);
        partner->save_db();
    }
    else
    {
        //王者训练
        repo_def::levelup_t *p_lvup = repo_mgr.levelup.get(m_user.db.grade);
        if( p_lvup == NULL )
        {
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
        partner->on_exp_change( p_lvup->exp - partner->db.exp );
        partner->save_db();
    }

    //计算价钱
    if( 2==type_ )
    {
        int32_t code = m_user.vip.buy_vip(vop_do_vp_trial);
        if (code != SUCCESS)
        {
            ret.code = code;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }

    //更新cd时间
    practice_cache.set(m_user.db.uid,pos_);

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);

    m_user.daily_task.on_event(evt_practice);
}
//======================================================
//-1,error  0,unopen  1,open
int32_t sc_practice_cache_t::isopen(int32_t uid_, int32_t pos_)
{
    auto it=m_practice_hm.find(uid_);
    if( it==m_practice_hm.end() )
        return -1;

    if(pos_>2 || pos_<0)
        return -1;

    return ((it->second)[pos_]==0)?0:1;
}
void sc_practice_cache_t::open(sc_user_t &user_, int32_t pos_)
{
    auto it=m_practice_hm.find(user_.db.uid);
    if( it==m_practice_hm.end() )
    {
        vector<uint32_t> carbets(3);
        carbets[0] = (user_.db.grade>=CARBET_LV_1ST)?1:0;
        carbets[1] = (user_.db.grade>=CARBET_LV_2ND)?1:0;
        carbets[2] = (user_.db.viplevel>=CARBET_VIPLV_3ST)?1:0;
        it=m_practice_hm.insert( make_pair(user_.db.uid,std::move(carbets)) ).first;
    }

    (it->second)[pos_] = 1;
}
void sc_practice_cache_t::get_info(sp_user_t user_, vector<sc_msg_def::sc_practice_info_t> &ret_)
{
    auto it=m_practice_hm.find(user_->db.uid);
    if( it==m_practice_hm.end() )
    {
        vector<uint32_t> carbets(3);
        carbets[0] = (user_->db.grade>=CARBET_LV_1ST)?1:0;
        carbets[1] = (user_->db.grade>=CARBET_LV_2ND)?1:0;
        carbets[2] = (user_->db.viplevel>=CARBET_VIPLV_3ST)?1:0;
        it=m_practice_hm.insert( make_pair(user_->db.uid,std::move(carbets)) ).first;
    }

    struct timeval tm;
    gettimeofday(&tm, NULL);

    sc_msg_def::sc_practice_info_t info;
    int32_t old;
    for(size_t i=0;i<3;++i)
    {
        old = (it->second)[i];

        if( 0==old )
            info.state = -1;
        else
        {
            if( tm.tv_sec - old >= PRACTICE_CD )
                info.state = 0;
            else
            {
                info.state = 1;
                info.remains = PRACTICE_CD - (tm.tv_sec-old) ;
            }
        }

        ret_.push_back( std::move(info) );
    }
}
int32_t sc_practice_cache_t::get_last_prac(int32_t uid_, int32_t pos_)
{
    auto it=m_practice_hm.find(uid_);
    if( it==m_practice_hm.end() )
        return -1; 

    if(pos_>2 || pos_<0)
        return -1;
    
    return (it->second)[pos_];
}
void sc_practice_cache_t::set(int32_t uid_, int32_t pos_)
{
    auto it=m_practice_hm.find(uid_);
    if( it==m_practice_hm.end() )
        return; 

    if(pos_>2 || pos_<0)
        return;

    struct timeval tm;
    gettimeofday(&tm, NULL);

    (it->second)[pos_] = tm.tv_sec;
}
void sc_practice_cache_t::clear(int32_t uid_, int32_t pos_)
{
    if(pos_>2 || pos_<0)
        return;

    auto it=m_practice_hm.find(uid_);
    if( it==m_practice_hm.end() )
        return; 

    (it->second)[pos_] = 1;
}
