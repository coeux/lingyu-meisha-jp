#include "invcode_service.h"
#include "log.h"
#include "code_def.h"
#include "config.h"
#include "dbgl_service.h"
#include "msg_dispatcher.h"

#define LOG "INV_SERVICE" 

const char code_data[] = "123456789ABCDEFGHIJKLMNPQRSTUVWXYZ";

/*
const string domain_name[]=
{
    "91",
    "360",
    "uc",
    "duoku",
};
const int domain_num = 4;
*/

template<class TMsg>
int g_async_call(boost::shared_ptr<rpc_connecter_t> conn_, TMsg& msg_)
{
    string out;
    msg_ >> out;
    conn_->async_send(std::move(rpc_msg_util_t::make_msg(TMsg::cmd(), out)));
    return 0;
}

invcode_handler_t::invcode_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&invcode_handler_t::on_regist);
    reg_call(&invcode_handler_t::on_req_invcode);
    reg_call(&invcode_handler_t::on_req_uid);
    reg_call(&invcode_handler_t::on_invitee_upgrade);
//    reg_call(&invcode_handler_t::on_req_reward_info);
}
invcode_handler_t::~invcode_handler_t()
{
}
void invcode_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    logwarn((LOG, "invcode_handler_t::on_broken..."));
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;

    logwarn((LOG, "client broken! seskey:%lu", info->remote_id));
    invcode_service.del_client(info->remote_id);

    logwarn((LOG, "invcode_handler_t::on_broken...ok"));
}
void invcode_handler_t::on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_)
{
    inner_msg_def::ret_regist_t ret;

    uint16_t sertype = jpk_.sid >> 16;
    uint16_t serid = jpk_.sid;


    if (sertype <= 0 || sertype >= REMOTE_ALL)
    {
        logerror((LOG, "unkonw server requset regist! sertype:%d, serid:%d", sertype, serid));
        ret.code = ERROR_UNKNOWN_SERVER;
        async_call(conn_, ret);
        conn_->close();
        return;
    }

    remote_info_t* remote = new remote_info_t; 
    remote->is_client = false;
    remote->remote_id = jpk_.sid;
    remote->trans_id = jpk_.sid;
    conn_->set_data(remote);

    invcode_service.add_client(jpk_.sid, conn_);

    ret.sid = invcode_service.sid(); 
    ret.code = SUCCESS;  
    async_call(conn_, ret);

    logwarn((LOG, "new server regist ok! sertype:%d, serid:%d", remote->sertype(), remote->serid()));
}

void invcode_handler_t::on_req_invcode(sp_rpc_conn_t conn_, invcode_msg::req_code_t &jpk_)
{
    invcode_msg::ret_code_t ret;
    ret.uid = jpk_.uid;

    //映射domain为数字
    /*
    int p = 0;
    for(;p<domain_num;++p)
    {
        if( jpk_.domain == domain_name[p] )
            break;
    }
    if( domain_num == p )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        async_call(conn_,ret);
        return;
    }
    */
    int p = invcode_service.get_serid(jpk_.domain);
    if( -1 == p )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        async_call(conn_,ret);
        return;
    }

    //生成激活码
    int uid = (ret.uid*100) + p;
    int len = strlen(code_data);
    while( uid )
    {
        ret.invcode.append(1,code_data[uid%len]);
        uid/=len;
    }
    
    char sql[256];
    sql_result_t res;
    sprintf(sql,"select lv1,lv2,lv3,lv4 from InvCode where uid=%d;",(jpk_.uid*100)+p );
    dbgl_service.sync_select(sql, res);
    if( 0==res.affect_row_num() )
    {
        ret.n1=ret.n2=ret.n3=ret.n4=0;
        dbgl_service.async_do((uint64_t)jpk_.uid, [](int uid_){
            char sql[256];
            sprintf(sql,"insert ignore into InvCode(uid) values(%d);",uid_);
            dbgl_service.async_execute(sql);
        }, (jpk_.uid*100)+p);
    }
    else
    {
        stringstream stream;
        stream<<(*(res.get_row_at(0)))[0];stream>>ret.n1;stream.clear();
        stream<<(*(res.get_row_at(0)))[1];stream>>ret.n2;stream.clear();
        stream<<(*(res.get_row_at(0)))[2];stream>>ret.n3;stream.clear();
        stream<<(*(res.get_row_at(0)))[3];stream>>ret.n4;stream.clear();
    }
    ret.code = SUCCESS;
    async_call(conn_,ret);
}

void invcode_handler_t::on_req_uid(sp_rpc_conn_t conn_, invcode_msg::req_uid_t &jpk_)
{
    int p = invcode_service.get_serid(jpk_.domain);
    if( -1 == p )
    {
        invcode_msg::ret_uid_t ret;
        ret.code = ERROR_SC_ILLEGLE_REQ;
        ret.suid = jpk_.suid;
        ret.duid = 0;
        async_call(conn_,ret);
        return;
    }

    int uid=invcode2uid(jpk_.invcode);
    if( 0==uid )
    {
        invcode_msg::ret_uid_t ret;
        ret.code = ERROR_SC_ERROR_INVCODE;
        ret.suid = jpk_.suid;
        ret.duid = 0;
        async_call(conn_,ret);
        return;
    }
    if( uid == (jpk_.suid*100+p) )
    {
        invcode_msg::ret_uid_t ret;
        ret.code = ERROR_SC_NO_INV_SELF;
        ret.suid = jpk_.suid;
        ret.duid = 0;
        async_call(conn_,ret);
        return;
    }

    dbgl_service.async_do((uint64_t)jpk_.suid,[](sp_rpc_conn_t conn_,int suid_,int duid_){
        char sql[256];
        sql_result_t res;
        sprintf(sql,"select uid from InvCode where uid=%d;",duid_);
        dbgl_service.async_select(sql, res);
        sql_result_row_t* row = res.get_row_at(0); 

        invcode_msg::ret_uid_t ret;
        ret.suid = suid_;

        if (row == NULL)
        {
            ret.code = ERROR_SC_ERROR_INVCODE;
            ret.duid = 0;
            g_async_call(conn_,ret);
            return;
        }

        ret.code = SUCCESS;
        ret.duid = duid_;
        g_async_call(conn_,ret);
    }, conn_, jpk_.suid,uid);
}
void invcode_handler_t::on_invitee_upgrade(sp_rpc_conn_t conn_, invcode_msg::nt_upgrade_t &jpk_)
{
    dbgl_service.async_do((uint64_t)jpk_.inviter, [](int uid_,int grade_){

        char sql[256];
        switch( grade_ )
        {
            case 27:
                sprintf(sql,"update InvCode set lv1=lv1+1 where uid=%d;",uid_);
                break;
            case 33:
                sprintf(sql,"update InvCode set lv2=lv2+1 where uid=%d;",uid_);
                break;
            case 40:
                sprintf(sql,"update InvCode set lv3=lv3+1 where uid=%d;",uid_);
                break;
            case 50:
                sprintf(sql,"update InvCode set lv4=lv4+1 where uid=%d;",uid_);
                break;
            default:
                return;
        }
        dbgl_service.async_execute(sql);

    }, jpk_.inviter,jpk_.grade);
}
int invcode_handler_t::invcode2uid(string &invcode_)
{
    int i,uid=0,base=1;
    int len = strlen(code_data);
    for( auto it=invcode_.begin();it!=invcode_.end();++it)
    {
        for( i=0;i<len;++i)
        {
            if( toupper(*it) == code_data[i] )
            {
                uid += (i*base);
                break;
            }
        }
        
        if( len==i )
            return 0;

        base *= len;
    }
    return uid;
}
//===============================================
invcode_service_t::invcode_service_t():
    m_started(false),
    m_sid(0)
{
    m_io_pool.start(1);
    service_base_t<invcode_handler_t>(m_io_pool.get_io_service(0));
}

void invcode_service_t::start(uint16_t serid_, string ip_, string port_)
{
    logwarn((LOG, "start invcode service..."));
    if (m_started)
        return;
    m_started = true;

    m_sid = ((uint32_t)REMOTE_INVCODE<<16)|serid_; 
    listen(ip_, port_);

    logwarn((LOG, "start invcode service ok! serid:%u", serid_));
}

int32_t invcode_service_t::get_serid(string platform_)
{
    auto it = m_platform.find(platform_);
    if( it != m_platform.end() )
        return it->second;
        
    char sql[128];
    sql_result_t res;
    sprintf(sql, "select serid from InvPlatform where domain = '%s' ",platform_.c_str());
    dbgl_service.sync_select(sql, res);
    if( res.affect_row_num() == 0 )
        return -1;
    sql_result_row_t& row = *res.get_row_at(0);
    int32_t serid =  std::atoi(row[0].c_str()); 

    m_platform.insert( make_pair(platform_,serid) );

    return serid;
}
