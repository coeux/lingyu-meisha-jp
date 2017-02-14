#include "lg_logic.h"
#include "log.h"
#include "code_def.h"
#include "db_service.h"
#include "db_ext.h"
#include "crypto.h"
#include "remote_info.h"
#include "seskey_assign.h"
#include "lg_gen_name.h"
#include "lg_platform.h"
#include "lg_statics.h"

#define LOG "LG_LOGIC" 

#define ROLE_RESID_BEGIN 1001
#define ROLE_RESID_END 1006

lg_logic_t::lg_logic_t()
{
    reg_call(&lg_logic_t::on_mac_login);
    reg_call(&lg_logic_t::on_req_rolelist);
    reg_call(&lg_logic_t::on_req_new_role);
    reg_call(&lg_logic_t::on_req_del_role);
}
void lg_logic_t::on_mac_login(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_)
{
    uint32_t hash = crypto_t::crc32(jpk_.mac.c_str(), jpk_.mac.size());
    db_service.async_do((uint64_t)hash, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_mac_login_t& jpk_){

        logwarn((LOG, "req_mac_login..., seskey:%lu", seskey_));

        /*
        int vcode = SUCCESS;
        if ((vcode = lg_platform.verify(jpk_.domain, jpk_.jinfo)) != SUCCESS)
        {
            lg_msg_def::ret_login_t ret;
            ret.code = vcode;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
        */

        sql_result_t res;

        db_Account_ext_t acc;
        if (db_Account_ext_t::select_name(jpk_.domain, jpk_.name, res))
        {
            if ((acc.aid = async_new_dbid("aid")) == 0)
            {
                logerror((LOG, "on_mac_login, create new aid failed!"));
                lg_msg_def::ret_login_t ret;
                ret.code = ERROR_LG_EXCEPTION;
                msg_sender_t::unicast(seskey_, conn_, ret);
                return;
            }

            acc.domain = jpk_.domain;
            acc.name = jpk_.name;
            acc.flag= 0;
            acc.lasthostnum = 0;
            acc.lastuid = 0;

            if (acc.insert())
            {
                logerror((LOG, "on_mac_login, create new account failed!"));
                lg_msg_def::ret_login_t ret;
                ret.code = ERROR_LG_EXCEPTION;
                msg_sender_t::unicast(seskey_, conn_, ret);
                return;
            }

            //统计数据
            lg_statics_ins.unicast_newaccount(jpk_.domain,jpk_.name,acc.aid);
        }
        else
        {
            acc.init(*res.get_row_at(0));
        }

        lg_msg_def::ret_login_t ret;
        ret.aid = acc.aid;
        ret.hostnum = acc.lasthostnum;
        ret.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, ret);
    }, seskey_, conn_, jpk_);
}
void lg_logic_t::on_req_rolelist(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_)
{
    db_service.async_do((uint64_t)jpk_.aid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_rolelist_t& jpk_){
        lg_msg_def::ret_rolelist_t ret;
        sql_result_t res;
        ret.hostnum = jpk_.hostnum;

        //确认账户存在
        db_Account_ext_t acc;
        if (db_Account_ext_t::select_aid(jpk_.aid, res))
        {
            ret.code = ERROR_LG_NO_AID;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
        else
        {
            acc.init(*res.get_row_at(0));
        }

        //设置上一次选择的服务器角色
        ret.lastuid = acc.lastuid;

        //查找角色
        if (db_UserID_ext_t::select_user_condition(jpk_.aid, jpk_.hostnum, "state>=0", res))
        {
            ret.code = SUCCESS;
            msg_sender_t::unicast(seskey_, conn_, ret);
        }
        else
        {
            int i=0;
            sql_result_row_t* row = NULL;
            while((row=res.get_row_at(i++))!=NULL)
            {
                db_UserID_ext_t userid;
                userid.init(*row);
                
                lg_msg_def::jpk_role_t jpk;
                jpk.uid = userid.uid;
                jpk.resid = userid.resid;
                jpk.nickname = userid.nickname();
                jpk.level = userid.grade;
                jpk.viplevel = 0;
                jpk.weaponid = 0;

                ret.rolelist.push_back(jpk);
            }

            ret.code = SUCCESS;
            msg_sender_t::unicast(seskey_, conn_, ret);
        }
    }, seskey_, conn_, jpk_);
}
//请求创建角色
void lg_logic_t::on_req_new_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_)
{
    if (ROLE_RESID_BEGIN > jpk_.resid || jpk_.resid > ROLE_RESID_END)
    {
        logerror((LOG, "on_req_new_role, error role resid:%d,%d,%d!", ROLE_RESID_BEGIN, jpk_.resid, ROLE_RESID_END));
        lg_msg_def::ret_new_role_t ret;
        ret.code = ERROR_LG_ROLE_RESID;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }

    db_service.async_do((uint64_t)jpk_.aid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_new_role_t& jpk_){

        lg_msg_def::ret_new_role_t ret;
        ret.code = SUCCESS;

        sql_result_t res;
        //确认账户是否存在
        if (db_Account_ext_t::select_aid(jpk_.aid, res))
        {
            ret.uid = 0;
            ret.code = ERROR_LG_NO_AID;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }

        //检查角色数是否溢出
        db_UserID_ext_t::select_user_condition(jpk_.aid, jpk_.hostnum, "state>=0", res);
        if (res.affect_row_num() >= 3)
        {
            ret.uid = 0;
            ret.code = ERROR_LG_ROLE_MAX_NUM;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }

        //插入角色ID
        db_UserID_ext_t userid;
        if ((userid.uid = async_new_dbid("uid"))==0)
        {
            logerror((LOG, "on_req_new_role, create new uid failed!"));
            ret.uid = 0;
            ret.code = ERROR_LG_EXCEPTION;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }
        userid.aid = jpk_.aid; 
        userid.resid = jpk_.resid;

        do
        {
            userid.nickname = gen_name.random_name();
            if (userid.nickname.empty())
            {
                logerror((LOG, "on_req_new_role, create random_name failed!"));

                ret.code = ERROR_LG_EXCEPTION;
                msg_sender_t::unicast(seskey_, conn_, ret);
                return;
            }

            //! 异步执行步执行sql操作 只能用在async_do中
            char sql[256]; 
            sprintf(sql, "select uid from UserID where nickname='%s'",userid.nickname.c_str());
            db_service.async_select(sql, res);
        }while(res.affect_row_num() > 0);

        userid.grade = 1;
        userid.viplevel = 0;
        userid.state = 0;
        userid.hostnum = jpk_.hostnum;
        if (userid.insert())
        {
            logerror((LOG, "on_req_new_role, create new role failed!"));
            ret.code = ERROR_LG_EXCEPTION;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }

        ret.uid = userid.uid;
        ret.role.uid = userid.uid;
        ret.role.nickname = userid.nickname();
        ret.role.resid = userid.resid;
        ret.role.level = userid.grade;
        ret.role.viplevel = userid.viplevel;
        ret.role.weaponid = 0;
        ret.code = SUCCESS;
        msg_sender_t::unicast(seskey_, conn_, ret);

    }, seskey_, conn_, jpk_);
}
void lg_logic_t::on_req_del_role(uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_)
{
    db_service.async_do((uint64_t)jpk_.uid, [](uint64_t seskey_, sp_rpc_conn_t conn_, lg_msg_def::req_del_role_t& jpk_){

        logwarn((LOG, "req_del_role，uid:%d", jpk_.uid)); 

        lg_msg_def::ret_del_role_t ret;
        ret.uid = jpk_.uid;
        ret.code = SUCCESS;

        sql_result_t res;
        if (db_UserID_ext_t::select_uid_condition(jpk_.uid, "state>=0", res))
        {
            logerror((LOG, "req_del_role，no uid:%d", jpk_.uid)); 
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
        }

        db_UserID_ext_t userid;
        userid.init(*res.get_row_at(0));
        userid.set_state(-1);
        db_service.async_execute(userid.get_up_sql());
        
        inner_msg_def::nt_role_deleted_t nt;
        nt.uid = jpk_.uid;

        inner_msg_def::trans_server_msg_t trans;
        trans.sid = (REMOTE_SCENE<<16)|(seskey_>>48);
        trans.msg_cmd = nt.cmd();
        nt >> trans.msg;
        string out;
        trans >> out;
        conn_->async_send(rpc_msg_util_t::make_msg(inner_msg_def::trans_server_msg_t::cmd(), out));

        msg_sender_t::unicast(seskey_, conn_, ret);
    }, seskey_, conn_, jpk_);
}
