#ifndef _sc_pushinfo_h_
#define _sc_pushinfo_h_

#include "msg_def.h"
#include "repo_def.h"
#include "sc_logic.h"
#include "sc_gang.h"

enum pushtype_e 
{
    push_unkonw = 0,
    push_cityboss_info_1,
    push_cityboss_info_2,
    push_cityboss_killed,
    push_cityboss_goning,
    push_cityboss_gone,
    push_worldboss_come,
    push_worldboss_lowhp,
    push_worldboss_killed,
    push_worldboss_escaped,
    push_gangboss_come,
    push_gangboss_lowhp,
    push_gangboss_killed,
    push_gangboss_escaped,
    push_stone,
    push_partner,
    push_arena_fight,
    push_arena_first,
    push_yadiana,
    push_vip,
    push_box_equip = 20,
    push_scuffle_start,
    push_scuffle_10_win,
    push_scuffle_20_win,
    push_scuffle_con_win,
    push_scuffle_kill_con_win,
    push_scuffle_winner,
    push_scuffle_no_winner,
    push_hongbao,
    push_arena_rank_1,
    push_arena_rank_2,
    push_arena_rank_3,
    push_scuffle_5_win,
    push_scuffle_15_win,
};

class sc_pushinfo_t
{
    const char* LOG = "PUSHINFO";
public:
    void push(const string& info_)
    {
        if (info_ == "")
            return;

        sc_msg_def::nt_pushinfo_t nt;
        nt.info = info_;
        string msg; nt >> msg;
        logic.usermgr().broadcast(sc_msg_def::nt_pushinfo_t::cmd(), msg);
    }

    void push_gang(int uid_, const string& info_)
    {
        if (info_ == "")
            return;
        sc_msg_def::nt_pushinfo_t nt;
        nt.info = info_;
        string msg; nt >> msg;

        sp_gang_t sp_gang;
        sp_ganguser_t sp_guser;
        if (gang_mgr.get_gang_by_uid(uid_, sp_gang, sp_guser))
        {
            sp_gang->broadcast(sc_msg_def::nt_pushinfo_t::cmd(), msg);
        }
    }

    void push_gang(sp_gang_t sp_gang_, const string& info_)
    {
        sc_msg_def::nt_pushinfo_t nt;
        nt.info = info_;
        string msg; nt >> msg;
        sp_gang_->broadcast(sc_msg_def::nt_pushinfo_t::cmd(), msg);
    }

    string get_push(int pushtype_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return ""; 
        }
    }

    template<class P1>
    string get_push(int pushtype_, const P1& p1_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            return format.str();
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error! <%s>", ex_.what()));
            return "";
        }
    }

    template<class P1, class P2>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3, class P4>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }

    template<class P1, class P2, class P3, class P4, class P5>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }
    
    template<class P1, class P2, class P3, class P4, class P5, class P6>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_, const P6 &p6_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            format % p6_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }
    
    template<class P1, class P2, class P3, class P4, class P5, class P6, class P7, class P8, class P9>
    string get_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_, const P6 &p6_, const P7 &p7_, const P8 &p8_, const P9 &p9_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return "";
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            format % p6_;
            format % p7_;
            format % p8_;
            format % p9_;
            return (format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return "";
        }
    }

    void new_push(int pushtype_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return ;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return; 
        }
    }

    template<class P1>
    void new_push(int pushtype_, const P1& p1_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }

    template<class P1, class P2>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }

    template<class P1, class P2, class P3>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }

    template<class P1, class P2, class P3, class P4>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }

    template<class P1, class P2, class P3, class P4, class P5>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }
    
    template<class P1, class P2, class P3, class P4, class P5, class P6>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_, const P6 &p6_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            format % p6_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }
    
    template<class P1, class P2, class P3, class P4, class P5, class P6, class P7, class P8, class P9>
    void new_push(int pushtype_, const P1& p1_, const P2& p2_, const P3& p3_, const P4& p4_, const P5& p5_, const P6 &p6_, const P7 &p7_, const P8 &p8_, const P9 &p9_)
    {
        repo_def::pushinfo_t* rp_fmt = repo_mgr.push_format.get(pushtype_);
        if (rp_fmt == NULL)
        {
            logerror((LOG, "repo push format no id:%d", pushtype_));
            return;
        }

        try
        {
            boost::format format = boost::format(rp_fmt->info);
            format % p1_;
            format % p2_;
            format % p3_;
            format % p4_;
            format % p5_;
            format % p6_;
            format % p7_;
            format % p8_;
            format % p9_;
            push(format.str());
        }catch(std::exception& ex_)
        {
            logerror((LOG, "repo push format error!"));
            return;
        }
    }
};

#define pushinfo (singleton_t<sc_pushinfo_t>::instance())

#endif
