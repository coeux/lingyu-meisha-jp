#include "gw_public_service.h"
#include "log.h"

#include "code_def.h"
#include "gw_private_service.h"

#define LOG "SU_SERVICE" 

su_handler_t::su_handler_t(io_t& io_):rpc_t(io_)
{
    reg_call(&su_handler_t::on_regist);
}
su_handler_t::~su_handler_t()
{
}
void su_handler_t::on_broken(sp_rpc_conn_t conn_)
{
    remote_info_t* info = conn_->get_data<remote_info_t>();
    if (info == NULL)
        return;
    logwarn((LOG, "server broken! sertype:%d, serid:%d", info->sertype(), info->serid()));
    su_service.del_server(info->remote_id);
}
void su_handler_t::on_regist(sp_rpc_conn_t conn_, inner_msg_def::req_regist_t& jpk_)
{
    if (!su_service.add_server(jpk_.sid, conn_))
    {
        logerror((LOG, "server has registed!, sertype:%d, serid:%d", 
                (uint16_t)(jpk_.sid>>16), (uint16_t)jpk_.sid));

        return;
    }

    remote_info_t* info = new remote_info_t();
    info->is_client = false;
    info->remote_id = jpk_.sid;
    info->trans_id = jpk_.sid;
    conn_->set_data(info);

    logwarn((LOG, "server regist ok!, sertype:%d, serid:%d", 
                (uint16_t)(jpk_.sid>>16), (uint16_t)jpk_.sid));
}
void su_handler_t::on_ret_server_info(sp_rpc_conn_t conn_, inner_msg_def::ret_server_info_t& jpk_)
{
    sp_rpc_conn_t conn = su_service.get_server(jpk_.sid);
    if (conn == NULL)
    {
        logerror((LOG, "unkonwn server return server info!, sertype:%d, serid:%d", 
                (uint16_t)(jpk_.sid>>16), (uint16_t)jpk_.sid));
        return;
    }

    m_server_info_hm[jpk_.sid] = jpk_;
}
