#ifndef _sc_mailinfo_h_
#define _sc_mailinfo_h_

#include "log.h"
#include "singleton.h"
#include "repo_def.h"
#include <boost/format.hpp>

#define MAIL_LOG "SC_MAIL"

enum mail_e 
{
    mail_unknown = 0,
    mail_frd_add,
    mail_arena_failed,
    mail_gang_add,
    mail_gang_kick,
    mail_gang_close,
    mail_gang_appoint,
    mail_gang_fire,
    mail_gang_boss_time,
    mail_gang_boss_killed,
    mail_gang_chairman,
    mail_put_acc_lg,
    mail_login_reward_info,
    mail_treasure_timeup,
    mail_treasure_kickoff,
    mail_treasure_robbed,
    mail_pay_ok,
    mail_worldboss_kill,
    mail_worldboss_rank,
    mail_worldboss_join,
    mail_gangboss_kill,
    mail_gangboss_rank,
    mail_gangboss_join,
    mail_scuffle_score,
    mail_scuffle_rank,
    mail_scuffle_last,
    mail_arena_reward = 26,
    mail_scuffle_zero,
    mail_mcard_nt,
    mail_cumu_yb_rank2=46, //包含2项奖励的
    mail_cumu_yb_rank1=47, //包含1项奖励的
    mail_vip_package=36,
    mail_act_wing_rank=37,
    mail_act_wing_score=38,
    mail_treasure_help=39,
    mail_worldboss_stage_hit=40,
    mail_mcard_daily = 41,
    mail_arena_rank_up = 42,    //竞技场爵位提升
    mail_card_event_stage = 43, /* 卡牌活动阶段奖励 */
    mail_card_event_ranking = 44, /* 卡牌活动排行榜奖励 */
    mail_card_event_difficult = 45, /* 卡牌活动通关奖励 */
    mail_rank_season_rankreward = 46, /* 排位赛段位奖励 */
    mail_rank_season_seasonward = 47, /* 排位赛赛季末奖励 */
    mail_guild_battle_been_cancel_pos = 48, /*公会战被撤下的通知*/
    mail_guild_battle_user_reward = 49, /*公会战个人奖励*/
    mail_guild_battle_failed = 50, /*公会战公会失败*/
    mail_guild_battle_season_reward = 51, /*公会战赛季奖励*/
    mail_inarena_reward = 52, /*公会战赛季奖励*/
    mail_pub_rank = 53, /*召唤排行奖励*/
    mail_lv_rank = 54, /*等级排行奖励*/
    mail_arena_rank = 55, /*竞技排行奖励*/
    mail_gang_rank = 56,
    mail_add_speed = 57,
    mail_gang_info = 58,
    mail_card_event_open = 59,
    mail_guildboss_reward = 60,
    mail_guildboss_kill_reward = 61,
    mail_feedback = 63,
    mail_new_user = 64,/*新用户加群邮件*/
    mail_new_user_zhanji = 65,/*新用户加群邮件*/
    mail_pub_stepup = 66,
    mail_pack_mail = 67,/*新用户加群邮件*/
    mail_open_reward1 = 68,
    mail_open_reward2 = 69
};

class sc_mailinfo_t
{
public:
    repo_def::mail_format_t* get_repo(int mailtype_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        return rp_fmt;
    }

    string new_mail(int mailtype_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }

    template<class P1>
    string new_mail(int mailtype_, const P1& p1_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            format % p1_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }

    template<class P1, class P2>
    string new_mail(int mailtype_, const P1& p1_, const P2& p2_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            format % p1_;
            format % p2_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3>
    string new_mail(int mailtype_, const P1& p1_, const P2& p2_, const P3& p3_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            format % p1_;
            format % p2_;
            format % p3_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3, class P4>
    string new_mail(int mailtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3, class P4, class P5>
    string new_mail(int mailtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_)
    {
        repo_def::mail_format_t* rp_fmt = repo_mgr.mail_format.get(mailtype_);
        if (rp_fmt == NULL)
        {
            logerror((MAIL_LOG, "repo mail format no id:%d", mailtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->format);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((MAIL_LOG, "repo mail format error!"));
            return "";
        }
    }
};

#define mailinfo (singleton_t<sc_mailinfo_t>::instance())

#endif
