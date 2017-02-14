#include "sc_message.h"
#include "msg_def.h"
#include "date_helper.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_gang.h"
#include <sys/time.h>
#include <string.h>

#define LOG "SC_MESSAGE"
bool sort_func(const last_role_info& role1,const last_role_info& role2){
    return role1.stmp > role2.stmp;
}
void string_replace(string & strBig, const string & strsrc, const string &strdst)
{
    string::size_type pos=0;
    string::size_type srclen=strsrc.size();
    string::size_type dstlen=strdst.size();
    while( (pos=strBig.find(strsrc, pos)) != string::npos)
    {
        strBig.replace(pos, srclen, strdst);
        pos += dstlen;
    }
};

enum
{
    chart_world = 1,      //世界聊天
    chart_gang,           //公会聊天
    chart_private,        //私人聊天
    mail_msg,             //信封
    login_notify,         //登录公告
};

bool sc_notify_ctl_t::can_chart(int32_t uid_)
{
    struct timeval tm;
    gettimeofday(&tm, NULL);

    auto it=m_last_msg_hm.find(uid_);
    if( it==m_last_msg_hm.end() )
    {
        m_last_msg_hm.insert( make_pair(uid_,tm.tv_sec) );
        return true;
    }

    if( tm.tv_sec - it->second >= 5 )
    {
        it->second = tm.tv_sec;
        return true;
    }
    else
        return false;
}

void sc_notify_ctl_t::push_to_all(int32_t suid_,int32_t resid_,int32_t quality_,int32_t grade_,int32_t vip_,const string &name_, int32_t type_, string &msg_)
{
    if( (chart_world == type_) && !can_chart(suid_) )
        return;
    
    struct timeval tm;
    gettimeofday(&tm, NULL);

    sc_msg_def::nt_msg_push_t mp;
    mp.type = type_;
    mp.msg = msg_;
    mp.uid = suid_;
    mp.lv = grade_;
    mp.vipLevel = vip_;
    mp.name = name_;
    mp.stmp = tm.tv_sec;
    mp.resid = resid_;
    mp.quality = quality_;
    mp.lovelevel = get_lovelevel(suid_);

    string message;
    mp >> message;
    
    logic.usermgr().broadcast( sc_msg_def::nt_msg_push_t::cmd(),message );

    //日常任务
    if (suid_ != 0 && chart_world == type_)
    {
        sp_user_t sp_user;
        if (logic.usermgr().get(suid_, sp_user))
        {
            //sp_user->daily_task.on_event(evt_world_msg);
        }
    }
}
void sc_notify_ctl_t::push_event(sc_msg_def::nt_event_general_t &event_)
{
    string message;
    event_ >> message;
    logic.usermgr().broadcast(sc_msg_def::nt_event_general_t::cmd(),message );
}
void sc_notify_ctl_t::push_event(sc_msg_def::nt_event_blank_t &event_)
{
    string message;
    event_ >> message;
    logic.usermgr().broadcast(sc_msg_def::nt_event_blank_t::cmd(),message );
}
void sc_notify_ctl_t::push_event(sc_msg_def::nt_event_gemstone_t &event_)
{
    string message;
    event_ >> message;
    logic.usermgr().broadcast(sc_msg_def::nt_event_general_t::cmd(),message );
}
void sc_notify_ctl_t::push_event(sc_msg_def::nt_event_arena_t &event_)
{
    string message;
    event_ >> message;
    logic.usermgr().broadcast(sc_msg_def::nt_event_general_t::cmd(),message );
}
void sc_notify_ctl_t::push_event(sc_msg_def::nt_event_boss_kill_t &event_)
{
    string message;
    event_ >> message;
    logic.usermgr().broadcast(sc_msg_def::nt_event_general_t::cmd(),message );
}

void sc_notify_ctl_t::push_to_gang(int32_t suid_,int32_t resid_,int32_t quality_,int32_t grade_,int32_t vip_,const string &name_,int32_t type_,int32_t ggid_, string &msg_)
{
    /*
    if( (chart_gang == type_) && !can_chart(suid_) )
        return;
    */

    sp_gang_t gang;
    if( !gang_mgr.get(ggid_,gang) )
    {
        //帮会不存在
        return;
    }

    struct timeval tm;
    gettimeofday(&tm, NULL);

    sc_msg_def::nt_msg_push_t mp;
    mp.type = type_;
    mp.resid = resid_;
    mp.quality = quality_;
    mp.msg = msg_;
    mp.uid = suid_;
    mp.vipLevel = vip_;
    mp.lv = grade_;
    mp.name = name_;
    mp.stmp = tm.tv_sec;
    mp.lovelevel = get_lovelevel(suid_);

    string message;
    mp >> message ;
    
    gang->broadcast( sc_msg_def::nt_msg_push_t::cmd(),message );
}

int32_t sc_notify_ctl_t::get_lovelevel(int32_t uid_)
{
    int32_t lovelevel = 0;
    char sql[256];
    sql_result_t res;
    sprintf(sql, "select lovelevel from UserInfo where uid = %d", uid_);
    db_service.sync_select(sql, res);
    if (res.affect_row_num() > 0)
    {
        sql_result_row_t& row = *res.get_row_at(0);
        lovelevel = (int)std::atoi(row[0].c_str());
    }else
        lovelevel = 0;
    return lovelevel;
}

void sc_notify_ctl_t::push_to_uid(int32_t suid_,int32_t resid_,int32_t quality_,int32_t grade_,int32_t vip_,const string &name_, int32_t type_, int32_t duid_, string &msg_)
{
    sc_msg_def::nt_msg_push_t mp;
    mp.type = type_;
    mp.resid = resid_;
    mp.quality = quality_;
    mp.msg = msg_;
    mp.uid = suid_;
    mp.vipLevel = vip_;
    mp.lv = grade_;
    mp.name = name_;
    mp.stmp = date_helper.cur_sec();
    mp.lovelevel = get_lovelevel(suid_);

    //判断该玩家是否在线
    if(logic.usermgr().has(duid_))
    {
        logic.unicast(duid_, mp);
    }
    else
    {
        //玩家不在线
        notify_cache.put_msg(duid_,std::move(mp));
    }
}
void sc_notify_ctl_t::push_mail(int32_t uid_, const string& msg_)
{
    sc_msg_def::nt_msg_push_t mp;
    mp.type = mail_msg;
    mp.msg = msg_;
    mp.uid = uid_;
    mp.lv = 0;
    mp.name = "";
    mp.stmp = date_helper.cur_sec();

    //判断该玩家是否在线
    if(logic.is_online(uid_))
    {
        logic.unicast(uid_, mp);
    }
    else
    {
        //玩家不在线
        notify_cache.put_msg(uid_,std::move(mp));
    }
}
void sc_notify_ctl_t::push_offlinemail(int32_t uid_, const string& msg_)
{
    sc_msg_def::nt_msg_push_t mp;
    mp.type = mail_msg;
    mp.msg = msg_;
    mp.uid = uid_;
    mp.lv = 0;
    mp.name = "";
    mp.stmp = date_helper.cur_sec();

    notify_cache.put_msg(uid_,std::move(mp));
}
/////////////////////////////////////////////
int32_t sc_notify_cache_t::unicast_cache_msg(int32_t uid_)
{
    sc_msg_def::ret_mail_info_t ret;
    auto it = m_private_msg.find(uid_);
    if (it != m_private_msg.end())
    {
        msg_bucket_t& bucket = it->second;
        /*
        std::for_each(bucket.begin(), bucket.end(), [&](sc_notify_t& nt_){ 
            logic.unicast(uid_, nt_);
        });
        */
        ret.mails.insert( ret.mails.begin(),bucket.begin(),bucket.end());
        bucket.clear();
    }
    logic.unicast(uid_, ret);
    return 0;
}

int32_t sc_notify_cache_t::put_msg(int32_t uid_, sc_notify_t &&nt_)
{
    auto it = m_private_msg.find(uid_);
    if( it == m_private_msg.end() )
    {
        msg_bucket_t mb;
        mb.push_back(nt_);
        m_private_msg.insert( make_pair(uid_,std::move(mb)) );
    }
    else
    {
        it->second.push_back( std::move(nt_) );
        if( it->second.size() > 10)
            it->second.pop_front();
    }

    return 0;
}

bool sc_chat_t::addNew(int32_t suid_, int32_t resid_, int32_t quality_, int32_t grade_, int32_t vip_, string name_, int32_t typeindex, string msg_, uint64_t hostnum)
{
    db.suid = suid_;
    db.resid = resid_;
    db.quality = quality_;
    db.grade = grade_;
    db.vip = vip_;
    db.name = name_;
    db.typeindex = typeindex;
    string_replace(msg_,"\\","\\\\");
    db.msg = msg_;
    db.hostnum = hostnum;
    db_service.async_do((uint64_t)db.suid,[](db_Chat_t db_){
        db_.insert();
    }, db);
    return true;
}

bool sc_notify_cache_t::addToUid(sp_user_t& user_ ,int32_t acuid_, int32_t typeindex, string msg_)
{
    sc_msg_def::nt_msg_push_t mp;
    mp.type = typeindex;
    mp.resid = user_->db.resid;
    mp.quality = user_->db.quality;
    mp.msg = msg_;
    mp.uid = user_->db.uid;
    mp.vipLevel = user_->db.viplevel;
    mp.lv = user_->db.grade;
    mp.name = user_->db.nickname();
    mp.stmp = date_helper.cur_sec();
    mp.lovelevel = notify_ctl.get_lovelevel(user_->db.uid);

    string key1;
    key1.append(std::to_string(user_->db.uid)+std::to_string(acuid_));
    auto key1_it = m_new_private_msg.find(key1);
    if (m_new_private_msg.end() != key1_it){
        new_msg_bucket_t& bucket = key1_it->second.new_bucket;
        bucket.push_back(mp);     
        if (bucket.size() > 30){
            bucket.pop_front(); 
        }
    }else{
        string key2;
        key2.append(std::to_string(acuid_)+std::to_string(user_->db.uid));
        auto key2_it = m_new_private_msg.find(key2);
        if (m_new_private_msg.end() != key2_it){
            new_msg_bucket_t& bucket = key2_it->second.new_bucket;
            bucket.push_back(mp); 
            if (bucket.size() > 30){
                bucket.pop_front(); 
            }
        }else{
            private_chat_item_info pcii;
            pcii.uid1 = user_->db.uid;
            pcii.uid2 = acuid_;
            pcii.new_bucket.push_back(mp);
            m_new_private_msg.insert(make_pair(key1,std::move(pcii)));
            key1_it = m_new_private_msg.find(key1);
            new_msg_bucket_t& bucket = key1_it->second.new_bucket;
        }
    }

    char sql[512];
    sql_result_t res;

    string str_hosts;
    for (int32_t host : chat_ins.m_hosts)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);
    sprintf(sql, "select id,suid,acuid,quality,grade,vip,name,typeindex,msg,resid from PrivateChat where (suid = %d and acuid = %d) or (suid = %d and acuid = %d) and hostnum in (%s) order by id asc;",user_->db.uid,acuid_,acuid_,user_->db.uid,str_hosts.c_str());

    db_service.sync_select(sql, res);
    if (res.affect_row_num() >= 30){
        sql_result_row_t& row_ = *res.get_row_at(0);
        int32_t autoid = (int32_t)std::atoi(row_[0].c_str());
        sprintf(sql, "delete from PrivateChat where  id = %d;", autoid);
        db_service.sync_execute(sql);
    }

    db_service.async_do((uint64_t)user_->db.uid,[](sp_user_t& user_ ,int32_t acuid_, int32_t typeindex, string msg_){

            db_PrivateChat_t db;
            db.suid = user_->db.uid;
            db.acuid = acuid_;
            db.resid = user_->db.resid;
            db.quality = user_->db.quality;
            db.grade = user_->db.grade;
            db.vip = user_->db.viplevel;
            db.name = user_->db.nickname();
            db.typeindex = typeindex;
            string_replace(msg_,"\\","\\\\");
            db.msg = msg_;
            db.hostnum = user_->db.hostnum;
            db_service.async_do((uint64_t)db.suid,[&](db_PrivateChat_t db_){
                db_.insert();
                }, db);
        },user_,acuid_,typeindex,msg_);

    auto role_cache_it = m_role_cache.find(user_->db.uid);
    if (role_cache_it != m_role_cache.end()){

        bool is_have = false;
        vector<last_role_info>& cur_last_role = role_cache_it->second.last_role;

        for (auto c_it = cur_last_role.begin(); c_it != cur_last_role.end();c_it++){
            if ((*c_it).uid == acuid_){
                (*c_it).stmp = mp.stmp;
                is_have = true;
                break;
            }
        }
        if (!is_have){
            last_role_info last_r;
            last_r.uid = acuid_;
            last_r.stmp = mp.stmp;
            cur_last_role.push_back(std::move(last_r));
        }
        if (cur_last_role.size()>=2)
            std::sort(cur_last_role.begin(),cur_last_role.end(),sort_func); 
        if (cur_last_role.size() >= 6){
            cur_last_role.pop_back();
        }
        /*
        cout<<"enter-uid->"<<user_->db.uid<<endl;
        for(auto it = cur_last_role.begin();it != cur_last_role.end();it++){
            cout<<"last-uid->"<<(*it).uid<<" -stmp->"<<(*it).stmp<<endl;
        }
        */
    }

     
    if(logic.usermgr().has(acuid_))
        logic.unicast(acuid_, mp);
    return true;
}

void sc_notify_cache_t::getPrivateChatMessage(sp_user_t& user,int32_t player_uid_)
{
    sc_msg_def::ret_private_chat_info_t ret;
    ret.player_uid = player_uid_;
    ret.stamp = date_helper.cur_sec();
    int32_t lovelevel = 0;
    char sel[256];
    sql_result_t reu;
    sprintf(sel, "select lovelevel,resid,grade,nickname from UserInfo where uid = %d", player_uid_);
    db_service.sync_select(sel, reu);
    if (reu.affect_row_num() > 0)
    {
        sql_result_row_t& row1 = *reu.get_row_at(0);
        lovelevel = (int)std::atoi(row1[0].c_str());
        ret.resid = (int)std::atoi(row1[1].c_str());
        ret.level = (int)std::atoi(row1[2].c_str());
        ret.name = row1[3];
    }else{
        ret.resid = 101;
        ret.level = 3;
        ret.name = "";
    }

    string cur_key;
    string key1;
    key1.append(std::to_string(user->db.uid)+std::to_string(player_uid_));
    auto key1_it = m_new_private_msg.find(key1);
    if (m_new_private_msg.end() != key1_it){
        cur_key = key1;
        new_msg_bucket_t& bucket = key1_it->second.new_bucket;
        ret.private_chat_infos.insert(ret.private_chat_infos.begin(),bucket.begin(),bucket.end()); 
    }else{ 
        string key2;
        key2.append(std::to_string(player_uid_)+std::to_string(user->db.uid));
        auto key2_it = m_new_private_msg.find(key2);
        if (m_new_private_msg.end() != key2_it){
            cur_key = key2;
            new_msg_bucket_t& bucket = key2_it->second.new_bucket;
            ret.private_chat_infos.insert(ret.private_chat_infos.begin(),bucket.begin(),bucket.end()); 
        }else{
            char sql[512];
            sql_result_t res;

            string str_hosts;
            for (int32_t host : chat_ins.m_hosts)
            {
                str_hosts.append(std::to_string(host)+",");
            }
            str_hosts = str_hosts.substr(0, str_hosts.length()-1);
            sprintf(sql, "select suid,quality,grade,vip,name,typeindex,msg,resid from PrivateChat where (suid = %d and acuid = %d) or (suid = %d and acuid = %d) and hostnum in (%s) order by id asc;",user->db.uid,player_uid_,player_uid_,user->db.uid,str_hosts.c_str());
            db_service.sync_select(sql, res);
            private_chat_item_info mb;
            
            int32_t row_num = res.affect_row_num(); 
            if (row_num>30)
                row_num = 30;

            for (int32_t i = 0;i < row_num; i++)
            {
                if (res.get_row_at(i) == NULL)
                {
                    logerror((LOG, "getPrivateChatMessage load chat info get_row_at is NULL!!, at:%lu",i));
                    break;
                }
                sql_result_row_t& row_ = *res.get_row_at(i);
                sc_msg_def::nt_msg_push_t info;
                info.uid = (int)std::atoi(row_[0].c_str());
                info.quality = (int)std::atoi(row_[1].c_str());
                info.lv = (int)std::atoi(row_[2].c_str());
                info.vipLevel = (int)std::atoi(row_[3].c_str());
                info.name = row_[4];
                info.type = (int)std::atoi(row_[5].c_str());
                info.msg = row_[6];
                info.resid = (int)std::atoi(row_[7].c_str());

                if (info.uid == user->db.uid)
                    info.lovelevel = user->db.lovelevel;
                else
                    info.lovelevel = lovelevel;

                mb.new_bucket.push_back(info);
                ret.private_chat_infos.push_back(info);
            }
            cur_key = key1;
            mb.uid1 = user->db.uid;
            mb.uid2 = player_uid_;
            m_new_private_msg.insert(make_pair(key1,std::move(mb)));
        }
    }
    bool is_have = false;
    auto role_cache_it = m_role_cache.find(user->db.uid);
    if (role_cache_it == m_role_cache.end()){
        role_cache role_c;
        sql_result_t res;                                          
        if (0 == db_ChatUser_t::sync_select_all(user->db.uid,res)){      
            if (res.affect_row_num() > 0){ 
                for(int32_t index = 0 ; index < res.affect_row_num();index++)    
                {                                                                
                    sql_result_row_t& row1 = *res.get_row_at(index);             
                    db_ChatUser_t chat_db;                                       
                    chat_db.init(row1); 
                    last_role_info info_;
                    info_.uid = chat_db.player_uid;
                    info_.stmp = chat_db.stmp;
                    role_c.last_role.push_back(std::move(info_));
                }
            }
        }
        m_role_cache.insert(make_pair(user->db.uid,role_c));
        role_cache_it = m_role_cache.find(user->db.uid);
    }
    vector<string>& cur_chat_id = role_cache_it->second.chat_id;
    vector<last_role_info>& cur_last_role = role_cache_it->second.last_role;
    for (auto chat_id_it = cur_chat_id.begin();chat_id_it != cur_chat_id.end();chat_id_it++){
        if (cur_key == *chat_id_it){
            is_have = true;         
            break;
        }
    }
    if (!is_have)
        cur_chat_id.push_back(cur_key); 
    
    is_have = false;
    for (auto c_it = cur_last_role.begin(); c_it != cur_last_role.end();c_it++){
        if ((*c_it).uid == player_uid_){
            (*c_it).stmp = ret.stamp;
            is_have = true;
            break;
        }
    }
    if (!is_have){
        last_role_info last_r;
        last_r.uid = player_uid_;
        last_r.stmp = ret.stamp;
        cur_last_role.push_back(std::move(last_r));
    }
    if (cur_last_role.size()>=2)
        std::sort(cur_last_role.begin(),cur_last_role.end(),sort_func); 
    if (cur_last_role.size() >= 6){
        cur_last_role.pop_back();
    }
    /*
    cout<<"getChatMessage-enter-uid->"<<user->db.uid<<endl;
    for(auto it = cur_last_role.begin();it != cur_last_role.end();it++){
        cout<<"getChatMessage-last-uid->"<<(*it).uid<<" -stmp->"<<(*it).stmp<<endl;
    }
    cout<<"addcout-uid->"<<user->db.uid<<endl;
    for(auto chat_id_it = cur_chat_id.begin();chat_id_it != cur_chat_id.end();chat_id_it++){
        cout<<"getChatMessage-----------------------chat_id->"<<*chat_id_it<<endl;
    }
    */

    logic.unicast(user->db.uid, ret);
}
void sc_notify_cache_t::on_session_broken(int32_t uid_)
{
    auto role_cache_it = m_role_cache.find(uid_);
    if (role_cache_it != m_role_cache.end()){
        vector<string>& cur_chat_id = role_cache_it->second.chat_id;
        for(auto chat_id_it = cur_chat_id.begin();chat_id_it != cur_chat_id.end();chat_id_it++){
            auto new_pm_it = m_new_private_msg.find(*chat_id_it);
            if (new_pm_it != m_new_private_msg.end()){
                private_chat_item_info& pcii = new_pm_it->second;
                if (pcii.uid1 != uid_){
                    auto cache_it = m_role_cache.find(pcii.uid1);
                    if (cache_it == m_role_cache.end()){ 
                        m_new_private_msg.erase(*chat_id_it); 
                    }
                        
                }
                if (pcii.uid2 != uid_){
                    auto cache_it = m_role_cache.find(pcii.uid2);
                    if (cache_it == m_role_cache.end()){ 
                        m_new_private_msg.erase(*chat_id_it); 
                    }
                }
            }
        }   

        char sql[256]; 
        sprintf(sql, "delete from ChatUser where uid = %d;",uid_);
        db_service.sync_execute(sql);
        vector<last_role_info> last_role;
        /*
        for(auto it = role_cache_it->second.last_role.begin();it != role_cache_it->second.last_role.end();it++){
            cout<<"last-uid->"<<(*it).uid<<" -stmp->"<<(*it).stmp<<endl;
        }
        */
        db_service.async_do((uint64_t)uid_,[](vector<last_role_info> last_role,int32_t uid_){
            if (last_role.size()>0){
                string msql;
                msql.append("insert into ChatUser(uid,player_uid,stmp) value");
                char temp[256];
                int32_t num = 1;
                for (auto last_role_it = last_role.begin();last_role_it != last_role.end();last_role_it++){ 
                    if (num > 5)
                    break;
                    sprintf(temp,"(%d,%d,%d),",uid_,(*last_role_it).uid,(*last_role_it).stmp);
                    msql.append(temp);
                    num += 1;
                }
                msql = msql.substr(0, msql.length()-1);
                db_service.async_execute(msql.c_str());
            }

        },role_cache_it->second.last_role,uid_);
        m_role_cache.erase(uid_);
    }
    /* 
    for(auto it = m_new_private_msg.begin();it!=m_new_private_msg.end();it++){
        cout<<"onseeion-id->"<<it->first<<endl;
    }
    */
}

void sc_chat_t::getChatMessage(int32_t uid_, uint64_t hostnum)
{
    sc_msg_def::ret_chat_info_t ret;
    char sql[256];
    sql_result_t res;

    string str_hosts;
    for (int32_t host : m_hosts)
    {
        str_hosts.append(std::to_string(host)+",");
    }
    str_hosts = str_hosts.substr(0, str_hosts.length()-1);

    sprintf(sql, "select suid,quality,grade,vip,name,typeindex,msg,resid from Chat where hostnum in (%s) order by id desc limit 15;", str_hosts.c_str() );
    db_service.sync_select(sql, res);
    for (size_t i = 0;i < res.affect_row_num(); i++)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "load chat info get_row_at is NULL!!, at:%lu",i));
            break;
        }
        sc_msg_def::nt_msg_push_t info;
        sql_result_row_t& row_ = *res.get_row_at(i);
        info.uid = (int)std::atoi(row_[0].c_str());
        info.quality = (int)std::atoi(row_[1].c_str());
        info.lv = (int)std::atoi(row_[2].c_str());
        info.vipLevel = (int)std::atoi(row_[3].c_str());
        info.name = row_[4];
        info.type = (int)std::atoi(row_[5].c_str());
        info.msg = row_[6];
        info.resid = (int)std::atoi(row_[7].c_str());
       
        char sel[256];
        sql_result_t reu;
        sprintf(sel, "select lovelevel from UserInfo where uid = %d", info.uid);
        db_service.sync_select(sel, reu);
        if (reu.affect_row_num() > 0)
        {
            sql_result_row_t& row1 = *reu.get_row_at(0);
            info.lovelevel = (int)std::atoi(row1[0].c_str());
        }else
            info.lovelevel = 0;
        
        ret.infos.push_back(std::move(info));
    }
    logic.unicast(uid_, ret);
}
