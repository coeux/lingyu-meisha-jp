#include "sc_friend.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_cache.h"
#include "sc_mailinfo.h"
#include "sc_message.h"
#include "sc_friend_flower.h"
#include "repo_def.h"
#include "code_def.h"

#include "date_helper.h"

#define LOG "SC_FRIEND"

#define FRIEND_MAX 100
#define FRIEND_PER_PAGE 10
#define GET_FRD_COUNT(grade) (((grade*2)>FRIEND_MAX)?FRIEND_MAX:(grade*2))
#define ONE_HOUR 3600

#define MAX_FPOINT_PER_DAY 10000

sc_friend_t::sc_friend_t(sc_user_t& user_):m_user(user_)
{
}
//======================================================
sc_friend_mgr_t::sc_friend_mgr_t(sc_user_t& user_):m_user(user_)
{
}
void sc_friend_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Friend_t::sync_select_friend(m_user.db.uid, res))
    {
        m_friend_vec.resize(res.affect_row_num());
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_friend_t> sp_friend(new sc_friend_t(m_user));
            sp_friend->db.init(*res.get_row_at(i));
            if( logic.is_online(sp_friend->db.fuid) )
                sp_friend->online = 1;
            else
                sp_friend->online = 0;

            m_friend_hm.insert(make_pair(sp_friend->db.fuid, sp_friend));
            m_friend_vec[i] = sp_friend;

            frd_loadinfo.put(sp_friend->db.fuid);
        }
        frd_loadinfo.load_frd_info();
    }
}
void sc_friend_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Friend_t::select_friend(m_user.db.uid, res))
    {
        m_friend_vec.resize(res.affect_row_num());
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_friend_t> sp_friend(new sc_friend_t(m_user));
            sp_friend->db.init(*res.get_row_at(i));
            m_friend_hm.insert(make_pair(sp_friend->db.fuid, sp_friend));
            m_friend_vec[i]=sp_friend;
        }
    }
}

void sc_friend_mgr_t::load_info()
{
    for(sp_friend_t& f : m_friend_vec)
    {
        frd_loadinfo.put(f->db.fuid);
    }
    frd_loadinfo.load_frd_info();
}

sp_friend_t sc_friend_mgr_t::get(int32_t fuid_)
{
    auto it = m_friend_hm.find(fuid_);
    if (it != m_friend_hm.end())
        return it->second;
    return sp_friend_t();
}
void sc_friend_mgr_t::del(int32_t uid_)
{
    auto it = m_friend_hm.find(uid_);
    if (it != m_friend_hm.end())
        m_friend_hm.erase(it);
    for( auto it_v=m_friend_vec.begin();it_v!=m_friend_vec.end();++it_v)
    {
        if ( uid_==(*it_v)->db.fuid )
        {
            m_friend_vec.erase(it_v);
            return;
        }
    }
}
void sc_friend_mgr_t::put(sp_friend_t frd_)
{
    m_friend_hm.insert( make_pair(frd_->db.fuid,frd_) );
    m_friend_vec.push_back( frd_ );
}
void sc_friend_mgr_t::search_friend(string &name_)
{
    sc_msg_def::ret_friend_search_t ret;
    ret.name = name_;

    int32_t uid = name_cache.get_uid_by_name(name_);
    if( 0 == uid )
    {
        ret.uid = 0;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    sp_user_t user;
    if( logic.usermgr().get(uid,user) || cache.get(uid,user) )
    {
        ret.uid = uid;
        ret.lv = user->db.grade;
        ret.resid = user->db.resid;
    }
    else
    {
        sp_baseinfo_t frd = baseinfo_cache.get_baseinfo( uid );
        if( frd != NULL )
        {
            ret.uid = uid;
            ret.lv = frd->grade;
            ret.resid = frd->helpresid;
        }
        else
            ret.uid = 0;
    }
    logic.unicast(m_user.db.uid, ret);
}

void sc_friend_mgr_t::search_friend_by_uid(int32_t uid)
{
    sc_msg_def::ret_friend_search_t ret;
    
    sp_user_t user;
    if( logic.usermgr().get(uid,user) || cache.get(uid,user) )
    {
        ret.uid = uid;
        ret.lv = user->db.grade;
        ret.resid = user->db.hhresid;
        ret.name = user->db.nickname();
    }
    else
    {
        sp_baseinfo_t frd = baseinfo_cache.get_baseinfo( uid );
        if( frd != NULL )
        {
            ret.uid = uid;
            ret.lv = frd->grade;
            ret.resid = frd->helpresid;
            ret.name = frd->nickname;
        }
        else
            ret.uid = 0;
    }
    logic.unicast(m_user.db.uid, ret);
}

void sc_friend_mgr_t::add_friend(int32_t uid_, int32_t fp_)
{
    sc_msg_def::ret_friend_add_t ret;
    ret.uid = uid_;

    //判断是否添加自己
    if( uid_ == m_user.db.uid )
    {
        ret.code = ERROR_SC_FRIEND_NO_SELF;
        logic.unicast(m_user.db.uid, ret);
        return ;
    }

    //判断该玩家是否已经是好友
    auto it_v = m_friend_vec.begin();
    for( ;it_v!=m_friend_vec.end();++it_v)
    {
        if( uid_ == (*it_v)->db.fuid )
            break;
    }
    if( it_v != m_friend_vec.end() )
    {
        ret.code = ERROR_SC_FRIEND_REDU_ADD;
        logic.unicast(m_user.db.uid, ret);
        return ;
    }

    if( m_user.db.frd >= GET_FRD_COUNT(m_user.db.grade) )
    {
        ret.code = ERROR_SC_FRIEND_MAX_SOURCE;
        logic.unicast(m_user.db.uid, ret);
        return ;
    }

    //判断对方好友是否已达上限
    sp_baseinfo_t sp_frd = baseinfo_cache.get_baseinfo(uid_);
    if( (sp_frd != NULL) && (sp_frd->frdcount >=  GET_FRD_COUNT(sp_frd->grade)   ) )
    {
        ret.code = ERROR_SC_FRIEND_MAX_TARGET;
        logic.unicast(m_user.db.uid, ret);
        return ;
    }

    frd_request_cache.put( uid_, m_user.db.uid, m_user.db.nickname(), m_user.db.grade, m_user.db.resid, fp_ );

    sp_user_t user;
    //判断玩家当前是否在线
    if( logic.usermgr().get(uid_, user) )
    {
        //被加玩家在线
        sc_msg_def::nt_friend_beenadd_t nt;
        nt.uid = m_user.db.uid;
        nt.name = m_user.db.nickname();
        nt.lv = m_user.db.grade;
        logic.unicast(uid_, nt);
    }

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}
bool frdcmp(sp_friend_t a,sp_friend_t b)
{
    return ( a->online > b->online );
}
void sc_friend_mgr_t::get_friend_info(int32_t uid_, sc_msg_def::friend_info_t &ret_)
{
    sp_baseinfo_t sp_frd = baseinfo_cache.get_baseinfo(uid_);
    sp_user_t user;
    bool online;
    char sql[256];
    sql_result_t res;

    sprintf(sql,"select nickname from UserInfo where uid=%d;",uid_);
    db_service.sync_select(sql, res);    
    if( sp_frd != NULL )
    {
        ret_.uid = uid_;
        ret_.pid = sp_frd->helphero;
        if( 0==res.affect_row_num() ) 
            ret_.name = sp_frd->nickname;
        else
        {
            sql_result_row_t& row = *res.get_row_at(0);
            ret_.name = row[0];
        }
        ret_.checkGiveState = sc_friend_mgr_t::check_send_flower(uid_);       
        //判断玩家是否在线,如果在线，取玩家的战力
        if((online=logic.usermgr().get(uid_, user)) || cache.get(uid_,user))
        {
            ret_.fp = sp_frd->fp = user->get_total_fp();
            ret_.lv = sp_frd->grade = user->db.grade;
        }
        else
        {
            ret_.lv = sp_frd->grade;
            ret_.fp = sp_frd->fp;
        }
        ret_.resid = sp_frd->helpresid;
        ret_.ishelped = helphero_cache.is_helped(m_user.db.uid,uid_);
    }
    else
        return;
    
    if( online )
    {
         ret_.online = 1;
    } else
    {
        ret_.online = 0;
    }
}

void sc_friend_mgr_t::get_friends(int32_t page_)
{
    sc_msg_def::ret_friend_list_t ret;
    /*if (m_user.db.resetFlowerStamp + ONE_HOUR >= date_helper.cur_sec())
    {
        m_user.db.set_numFlower(0);
        ret.resetFlowerStamp = m_user.db.resetFlowerStamp + ONE_HOUR - date_helper.cur_sec();
    }
    else
    {
        m_user.db.set_numFlower(1);
        ret.resetFlowerStamp = 0 ;
    }*/
    
    if (date_helper.offday(m_user.db.resetFlowerStamp) >= 1)
    {
        m_user.db.set_numFlower(20);
    }

    if (m_user.db.useFlowerStamp <= date_helper.cur_0_stmp())
    {
        m_user.db.set_useFlowerStamp(date_helper.cur_sec());
        m_user.db.set_useFlower(0);
    }
    ret.page = page_;
    ret.n_all = m_friend_vec.size();
    ret.numFlower = m_user.db.numFlower;
    ret.useFlower = m_user.db.useFlower;
    
    sc_msg_def::friend_info_t frd;
    if( 0==page_ )
    {
        //获取所有在线玩家
        sort( m_friend_vec.begin(),m_friend_vec.end(),frdcmp );
        auto it = m_friend_vec.begin();
        while ( it!= m_friend_vec.end() )
        {
            if( (*it)->online )
            {
                get_friend_info((*it)->db.fuid,frd);
                ret.frds.push_back(std::move(frd));
            }
            else
                break;
            ++it;
        }

        ret.n_online = ret.frds.size();

        //如果在线数为0,放一个好友进去
        if( (0==ret.n_online) && (it!=m_friend_vec.end()) )
        {
            get_friend_info((*it)->db.fuid,frd);
            ret.frds.push_back(std::move(frd));
            ++it;
        }

        //取整为10的整数倍
        while( (ret.frds.size()%FRIEND_PER_PAGE) != 0 )
        {
            if( it != m_friend_vec.end() )
            {
                get_friend_info((*it)->db.fuid,frd);
                ret.frds.push_back(std::move(frd));
            }
            else
                break;
            ++it;
        }

        if( ret.frds.size() == m_friend_vec.size() )
            ret.remain = 0;
        else
            ret.remain = 1;

        logic.unicast( m_user.db.uid,ret);
    }
    else
    {
        for(size_t i=page_*FRIEND_PER_PAGE;i<(size_t)((page_+1)*FRIEND_PER_PAGE);++i)
        {
            if( i<m_friend_vec.size() )
            {
                get_friend_info(m_friend_vec[i]->db.fuid,frd);
                ret.frds.push_back(std::move(frd));
            }
            else
                break;
        }
        if( (ret.frds.size() + page_*FRIEND_PER_PAGE) >= m_friend_vec.size() )
            ret.remain = 0;
        else
            ret.remain = 1;

        logic.unicast( m_user.db.uid,ret);
    }
}
void sc_friend_mgr_t::del_friend(int32_t uid_)
{
    //清除数据库
    db_service.async_do((uint64_t)m_user.db.uid, [](int32_t uid_, int32_t fuid_){
            char sql[256];
            sprintf(sql,"delete from Friend where uid=%d and fuid=%d",uid_,fuid_);
            db_service.async_execute(sql);
    }, m_user.db.uid, uid_);
    
    db_service.async_do((uint64_t)uid_, [](int32_t uid_, int32_t fuid_){
            char sql[256];
            sprintf(sql,"delete from Friend where uid=%d and fuid=%d",fuid_,uid_);
            db_service.async_execute(sql);
    }, m_user.db.uid, uid_);

    //从自己的好友列表中删除对方
    del(uid_);

    sc_msg_def::nt_friend_delone_t ret;
    ret.uid = uid_;
    logic.unicast( m_user.db.uid,ret);
    
    m_user.db.set_frd(m_user.db.frd - 1);
    m_user.save_db();

    //从对方的好友列表中删除自己
    sp_user_t user;
    bool online;
    if ( (online=logic.usermgr().get(uid_, user)) || cache.get(uid_, user) )
    {
        user->friend_mgr.del(m_user.db.uid);
        --(user->db.frd);
    }

    if( online )
    {
        sc_msg_def::nt_friend_delone_t ret;
        ret.uid = m_user.db.uid;
        logic.unicast(uid_,ret);
    }
    
    db_service.async_do((uint64_t)uid_, [](int32_t uid_){
        char sql[256];
        sprintf(sql,"update UserInfo set frd=frd-1 where uid=%d",uid_);
        db_service.async_execute(sql);
     },  uid_);
}
void sc_friend_mgr_t::on_helphero_change(int32_t resid_)
{
    sc_msg_def::nt_friend_hbchange_t ret;
    ret.uid = m_user.db.uid;
    ret.resid = resid_;

    for(auto it=m_friend_vec.begin(); it!=m_friend_vec.end(); it++)
    {
        if( (*it)->online )
            logic.unicast( (*it)->db.fuid,ret);
    }
}
bool sc_friend_mgr_t::check_send_flower(int32_t uid_)
{
    if (true)
        return 0;

    auto it = m_friend_hm.find(uid_);
    if( it != m_friend_hm.end() )
        if (m_user.friend_flower_mgr.checkIsOrNoSendFlower(m_user.db.uid, uid_))
            return 0;
        else 
            return 1;
    //    return (it->second->db.hasSendFlower == 1);
    return 0;
}
void sc_friend_mgr_t::set_flower_sent(int32_t uid_)
{
    auto it = m_friend_hm.find(uid_);
    if( it != m_friend_hm.end() )
    {
        it->second->db.hasSendFlower = 1;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_Friend_t& db_){
            db_.update();
        },it->second->db);
    }
}
void sc_friend_mgr_t::update_online(int32_t uid_,int32_t online_)
{
    auto it = m_friend_hm.find(uid_);
    if( it!= m_friend_hm.end() )
        it->second->online = online_;
}
void sc_friend_mgr_t::on_online_change(int32_t online_)
{
    sc_msg_def::nt_friend_olchange_t ret;
    ret.uid = m_user.db.uid;
    ret.online = online_;

    sp_user_t user;

    for(auto it=m_friend_vec.begin(); it!=m_friend_vec.end(); it++)
    {
        if( (*it)->online )
            logic.unicast( (*it)->db.fuid,ret);

        if ( logic.usermgr().get((*it)->db.fuid, user) || cache.get((*it)->db.fuid, user) )
            user->friend_mgr.update_online(m_user.db.uid,online_);
    }
}
int32_t sc_friend_mgr_t::is_frd(int32_t uid_)
{
    auto it=m_friend_hm.find(uid_);
    if( it==m_friend_hm.end() )
        return 0;
    return 1;
}
void sc_friend_mgr_t::add_req_return(int32_t suid_,int32_t reject_)
{
    sc_msg_def::ret_friend_add_res_t ret;
    ret.uid = suid_;

    if( reject_ )
    {
        ret.code = SUCCESS;
        logic.unicast(m_user.db.uid, ret);

   
        //系统推送
        //notify_ctl.push_to_uid(suid_,
    }
    else
    {
        //判断当前玩家好友是否已达上限
        if( m_user.db.frd >= GET_FRD_COUNT(m_user.db.grade) )
        {
            ret.code = ERROR_SC_FRIEND_MAX_SOURCE;
            logic.unicast(m_user.db.uid, ret);
            return ;
        }

        //判断对方好友是否已达上限
        sp_baseinfo_t sp_frd = baseinfo_cache.get_baseinfo(suid_);
        if( (sp_frd != NULL) && (sp_frd->frdcount >= GET_FRD_COUNT(sp_frd->grade) ) )
        {
            ret.code = ERROR_SC_FRIEND_MAX_TARGET;
            logic.unicast(m_user.db.uid, ret);
            return ;
        }

        db_Friend_t db;
        bool online;
        sp_user_t user;
    
        //判断该玩家是否已经是好友
        auto it_v = m_friend_vec.begin();
        for( ;it_v!=m_friend_vec.end();++it_v)
        {
            if( suid_ == (*it_v)->db.fuid )
            {
                ret.code = ERROR_SC_FRIEND_REDU_ADD;
                logic.unicast(m_user.db.uid, ret);
                return;
            }
        }

        //添加自己到对方的好友列表
        db.uid = suid_;
        db.fuid = m_user.db.uid;
        db_service.async_do((uint64_t)suid_, [](db_Friend_t& db_){
                db_.insert();
            }, db);

        if ( (online=logic.usermgr().get(suid_, user)) || (cache.get(suid_, user)) )
        {
            boost::shared_ptr<sc_friend_t> sp_friend(new sc_friend_t(*user));
            sp_friend->db = db;
            sp_friend->online = 1;
            user->friend_mgr.put(sp_friend);
            ++(user->db.frd);
        }
    
        db_service.async_do((uint64_t)suid_, [](int32_t uid_){
            char sql[256];
            sprintf(sql,"update UserInfo set frd=frd+1 where uid=%d",uid_);
            db_service.async_execute(sql);
        },  suid_);

        sc_msg_def::nt_friend_addone_t frd;
        if( online )
        {
            get_friend_info(m_user.db.uid,frd.frd);
            logic.unicast(suid_, frd);
        }

        //添加对方到自己的好友列表
        db.uid = m_user.db.uid;
        db.fuid = suid_;

        db_service.async_do((uint64_t)m_user.db.uid, [](db_Friend_t& db_){
                db_.insert();
                }, db);

        boost::shared_ptr<sc_friend_t> sp_friend(new sc_friend_t(m_user));
        sp_friend->db = db;
        if(online)
            sp_friend->online = 1;
        else
            sp_friend->online = 0;
        put(sp_friend);
        
        get_friend_info(suid_,frd.frd);
        logic.unicast(m_user.db.uid, frd);

        ++(m_user.db.frd);
        db_service.async_do((uint64_t)m_user.db.uid, [](int32_t uid_){
            char sql[256];
            sprintf(sql,"update UserInfo set frd=frd+1 where uid=%d",uid_);
            db_service.async_execute(sql);
        },  m_user.db.uid);

        ret.code = SUCCESS;
        logic.unicast(m_user.db.uid, ret);

        string msg = mailinfo.new_mail(mail_frd_add, date_helper.str_date(), m_user.db.nickname()); 
        if (!msg.empty())
            notify_ctl.push_mail(suid_, msg);
    }

    frd_request_cache.del(m_user.db.uid,suid_);
}
void sc_friend_mgr_t::on_rename(int uid_, const string& name_)
{
    foreach([&](sp_friend_t sp_friend_){
        sp_baseinfo_t sp_frd = baseinfo_cache.get_baseinfo(sp_friend_->db.fuid);
        if (sp_frd != NULL)
            sp_frd->nickname = name_;
    });
}
//=================================
void sc_frd_request_cache_t::get_frd_req_info(int32_t uid_,vector<sc_msg_def::nt_request_info_t> &ret_)
{
    auto it=m_request_hm.find(uid_);
    if( it!= m_request_hm.end() )
    {
        auto it_l = it->second.begin();
        while( it_l != it->second.end() )
        {
            ret_.push_back( *it_l );
            ++it_l;
        }
    }
}
void sc_frd_request_cache_t::put(int32_t duid_,int32_t suid_,const string &name_,int32_t lv_,int32_t resid, int32_t fp)
{
    auto it=m_request_hm.find(duid_);
    if( it==m_request_hm.end() )
    {
        list<sc_msg_def::nt_request_info_t> frd_list;
        frd_list.push_back( sc_msg_def::nt_request_info_t(suid_,name_,lv_,resid,fp) );

        m_request_hm.insert( make_pair(duid_,std::move(frd_list)) );
        return;
    }
    for(auto it_l=it->second.begin();it_l!=it->second.end();++it_l)
    {
        if( suid_ == (it_l->uid) )
            return;
    }
    it->second.push_back(sc_msg_def::nt_request_info_t(suid_,name_,lv_,resid,fp));
}
void sc_frd_request_cache_t::del(int32_t duid_,int32_t suid_)
{
    auto it=m_request_hm.find(duid_);
    if( it!= m_request_hm.end() )
    {
        auto it_l = it->second.begin();
        while( it_l != it->second.end() )
        {
            if ( it_l->uid == suid_ )
            {
                it->second.erase( it_l );
                return;
            }
            ++it_l;
        }
    }
}
int32_t sc_frd_request_cache_t::get_n_request(int32_t uid_)
{
    auto it=m_request_hm.find(uid_);
    if( it!= m_request_hm.end() )
    {
        return it->second.size();
    }
    return 0;
}
//=================================
void sc_frd_loadinfo_t::put(int32_t uid_)
{
    m_uids.push_back(uid_);
}
void sc_frd_loadinfo_t::load_frd_info() 
{ 
    int32_t uid;
    while( !(m_uids.empty()) )
    {
        uid = m_uids.front();
        m_uids.pop_front();

        sp_baseinfo_t frd;
        if ( baseinfo_cache.get(uid,frd) )
            continue;

        sp_user_t user;
        if ( logic.usermgr().get(uid, user) )
        {
            frd = user->get_frd_info();
            baseinfo_cache.put(uid, frd);
            continue;
        }
/*        if( cache.get(uid, user) )
        {
            frd = user->get_frd_info();
            baseinfo_cache.put(uid, frd);
            continue;
        }
*/        
        db_service.async_do((uint64_t)(uid), [](int32_t uid_){
            char sql[256];
            sql_result_t res;

            sprintf(sql,"select nickname,grade,fp,helphero,frd,resid from UserInfo where uid=%d;",uid_);
            db_service.async_select(sql, res);

            if( 0==res.affect_row_num() )
                return;

            sp_baseinfo_t sp_frd(new sc_baseinfo_t());

            /*
            stringstream stream;
            stream << ( *( res.get_row_at(0) ) )[0];stream >> sp_frd->nickname;stream.clear();
            stream << ( *( res.get_row_at(0) ) )[1];stream >> sp_frd->grade; stream.clear();
            stream << ( *( res.get_row_at(0) ) )[2];stream >> sp_frd->fp; stream.clear();
            stream << ( *( res.get_row_at(0) ) )[3];stream >> sp_frd->helphero;stream.clear();
            stream << ( *( res.get_row_at(0) ) )[4];stream >> sp_frd->frdcount;stream.clear();
            */
            
            sql_result_row_t& row = *res.get_row_at(0);
            sp_frd->nickname = row[0];
            sp_frd->grade = std::atoi(row[1].c_str());
            sp_frd->fp = std::atoi(row[2].c_str());
            sp_frd->helphero = std::atoi(row[3].c_str());
            sp_frd->frdcount = std::atoi(row[4].c_str());

            if( 0 == sp_frd->helphero )
            {
                sp_frd->helpresid= std::atoi(row[5].c_str());
                //stream <<( *( res.get_row_at(0) ) )[5];stream >> sp_frd->helpresid;stream.clear();
            }
            else
            {
                char sql[256];
                sql_result_t res;

                sprintf(sql, "select resid from Partner where uid=%d and pid=%d;", uid_, sp_frd->helphero);
                db_service.async_select(sql, res);

                if( 0==res.affect_row_num() )
                    return;

                /*
                stringstream stream;
                stream <<( *( res.get_row_at(0) ) )[0];stream >> sp_frd->helpresid;stream.clear();
                */
                sql_result_row_t& row = *res.get_row_at(0);
                sp_frd->helpresid = std::atoi(row[0].c_str());
            }

            baseinfo_cache.put(uid_, sp_frd);

        }, uid);
    }
}
//=================================
sc_helphero_cache_t::sc_helphero_cache_t()
{   
    flush_sec = date_helper.cur_sec();
}
void sc_helphero_cache_t::reset()
{
    if( date_helper.offday(flush_sec) >= 1)
    {
        flush_sec = date_helper.cur_sec();
        m_helphero_hm.clear();
        m_graduated_set.clear();
    }
}
int32_t sc_helphero_cache_t::is_graduated(int32_t uid_)
{
    return m_graduated_set.count(uid_);
}
int32_t sc_helphero_cache_t::get_helpcount(int32_t uid_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
    {
        m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
        return 0;
    }
    return it->second.m_helpcount;
}
int32_t sc_helphero_cache_t::get_fpoint(int32_t uid_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
    {
        m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
        return 0;
    }
    return it->second.m_fpoint;
}
void sc_helphero_cache_t::add_helpcount(int32_t uid_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
        it = m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
    ++(it->second.m_helpcount);
    if( 50 == it->second.m_helpcount )
        m_graduated_set.insert(uid_);
}
int32_t sc_helphero_cache_t::add_fpoint(int32_t uid_,int32_t delta_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
        it = m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
    if( (it->second.m_fpoint) >= MAX_FPOINT_PER_DAY ) 
        return 0;

    int32_t real = delta_;
    if( (it->second.m_fpoint)+delta_ > MAX_FPOINT_PER_DAY )
        real = MAX_FPOINT_PER_DAY - (it->second.m_fpoint);
    
    db_service.async_do((uint64_t)uid_, [](int32_t uid_, int32_t real_){
            char sql[256];
            sprintf(sql,"update UserInfo set fpoint=fpoint+%d where uid=%d",real_,uid_);
            db_service.async_execute(sql);
    }, uid_, real);
    
    sp_user_t user;
    if( logic.usermgr().get(uid_, user) )
        user->on_fpoint_change(real);
    else
    {
        if( cache.get(uid_, user) )
            user->db.fpoint += real;
    }

    return real;
}
int32_t sc_helphero_cache_t::is_helped(int32_t uid_,int32_t hhero_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
        it = m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
    return it->second.m_uids.count(hhero_);
}
void sc_helphero_cache_t::set_helper(int32_t uid_,int32_t hhero_)
{
    reset();
    auto it = m_helphero_hm.find(uid_);
    if( it == m_helphero_hm.end() )
        it = m_helphero_hm.insert( make_pair(uid_,sc_helphero_info_t()) ).first;
    it->second.m_uids.insert(hhero_);
}
