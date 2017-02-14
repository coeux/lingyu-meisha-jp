#include "sc_card_comment.h"
#include "date_helper.h"
#include "sc_server.h"
#include "sc_statics.h"
#include "db_helper.h"
#include "sc_logic.h"
#include "code_def.h"
#include "msg_def.h"
#include "db_ext.h"

#define LOG "SC_CARD_COMMENT"

int sc_card_comment_t::req_newest_comment(sp_user_t user_, int32_t resid_, vector< sc_msg_def::jpk_card_comment_info_t> &infos, sc_msg_def::jpk_card_comment_info_t &info_)
{
    dbgl_service.async_do((uint64_t)user_->db.uid, [](sp_user_t sp_user_,int resid, vector< sc_msg_def::jpk_card_comment_info_t>& infos_, sc_msg_def::jpk_card_comment_info_t &info){
        
        sql_result_t res;
        sql_result_t res_hot;
        char sql_hot[1024];
        char sql[1024];
        if (resid > 100)
        {
            sprintf(sql_hot, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where praisenum >= 5 and resid > 100 order by praisenum desc limit 1");
            sprintf(sql, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where resid > 100 order by stamp desc limit 50");
        }
        else
        {
            sprintf(sql_hot, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where resid = %d and praisenum >= 5 order by praisenum desc limit 1", resid); 
            sprintf(sql, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where resid = %d order by stamp desc limit 50", resid); 
        }
    
        dbgl_service.async_select(sql_hot, res_hot);
        if (res_hot.affect_row_num() > 0)
        {
            sql_result_row_t& row_hot = *res_hot.get_row_at(0);
            info.uid = (int)std::atoi(row_hot[0].c_str());
            info.name = row_hot[1];
            info.viplevel = (int)std::atoi(row_hot[2].c_str());
            info.grade = (int)std::atoi(row_hot[3].c_str());
            info.equiprank = (int)std::atoi(row_hot[4].c_str());
            info.isshow = (int)std::atoi(row_hot[5].c_str());
            info.praisenum = (int)std::atoi(row_hot[6].c_str());
            info.comment = row_hot[7];
            info.id = (int)std::atoi(row_hot[8].c_str());
        }
        else
        {
            info.uid = 0;
            info.id = -1;
            info.name = "";
            info.viplevel = 0;
            info.grade = 0;
            info.equiprank = 0;
            info.isshow = 0;
            info.praisenum = 0;
            info.comment = "";
        }

        dbgl_service.async_select(sql, res);  
        for (size_t i = 0;i < res.affect_row_num(); i++)
        {
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "load chat info get_row_at is NULL!!, at:%lu",i));
                break;
            }
            sc_msg_def::jpk_card_comment_info_t info;
            sql_result_row_t& row_ = *res.get_row_at(i);
            info.uid = (int)std::atoi(row_[0].c_str());
            info.name = row_[1];
            info.viplevel = (int)std::atoi(row_[2].c_str());
            info.grade = (int)std::atoi(row_[3].c_str());
            info.equiprank = (int)std::atoi(row_[4].c_str());
            info.isshow = (int)std::atoi(row_[5].c_str());
            info.praisenum = (int)std::atoi(row_[6].c_str());
            info.comment = row_[7];
            info.id = (int)std::atoi(row_[8].c_str());
           
            infos_.push_back(std::move(info));

        }

        sc_msg_def::nt_newest_card_comment_t nt;
        nt.infos = infos_;
        nt.type = 1;
        nt.max_comment = info;
        logic.unicast((uint64_t)sp_user_->db.uid, nt); 
            }, user_, resid_, infos, info_);

    return SUCCESS;    
}

int sc_card_comment_t::req_hotest_comment(sp_user_t user_, int32_t resid_, vector<sc_msg_def::jpk_card_comment_info_t> &infos)
{

    dbgl_service.async_do((uint64_t)user_->db.uid, [](sp_user_t sp_user_,int resid, vector< sc_msg_def::jpk_card_comment_info_t>& infos_){
        sql_result_t res;
        char sql[1024];
        if (resid > 100)
        {
            sprintf(sql, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where praisenum >= 5 and resid > 100 order by praisenum desc limit 10");
        }else
            sprintf(sql, "select uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id from CardComment where resid = %d and praisenum >= 5 order by praisenum desc limit 10", resid); 
        
        dbgl_service.async_select(sql, res);
        
        for (size_t i = 0;i < res.affect_row_num(); i++)
        {
            if (res.get_row_at(i) == NULL)
            {
                logerror((LOG, "load chat info get_row_at is NULL!!, at:%lu",i));
                break;
            }
            sc_msg_def::jpk_card_comment_info_t info;
            sql_result_row_t& row_ = *res.get_row_at(i);
            info.uid = (int)std::atoi(row_[0].c_str());
            info.name = row_[1];
            info.viplevel = (int)std::atoi(row_[2].c_str());
            info.grade = (int)std::atoi(row_[3].c_str());
            info.equiprank = (int)std::atoi(row_[4].c_str());
            info.isshow = (int)std::atoi(row_[5].c_str());
            info.praisenum = (int)std::atoi(row_[6].c_str());
            info.comment = row_[7];
            info.id = (int)std::atoi(row_[8].c_str());
             
            infos_.push_back(std::move(info));
        }

        sc_msg_def::nt_newest_card_comment_t nt;
        nt.type = 2;
        nt.infos = infos_;
        logic.unicast((uint64_t)sp_user_->db.uid, nt); 
    }, user_, resid_, infos);
        
    return SUCCESS;
}

int sc_card_comment_t::add_parise_num(sp_user_t user_, int32_t cid_, int32_t cuid_, int32_t puid_)
{
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select  praiseuid from CardCommentPraise where commentid = %d and praiseuid = %d", cid_, puid_); 
    dbgl_service.sync_select(sql, res);
    if (0 == res.affect_row_num())
    {
        //之前没有给cuid_玩家的cid_评论点过赞   CardComment表的点赞数加1 CardCommentPraise表增加一条
        /*sql_result_t res1;
        char sql1[256];
        sprintf(sql1, "select praisenum from CardComment where id = %d and uid = %d", cid_, cuid_);
        dbgl_service.sync_select(sql1, res1);
        if (0 == res1.affect_row_num()) 
            return ERROR_SC_ILLEGLE_REQ;
        sql_result_row_t &row = *res1.get_row_at(0);
        int32_t num = (int)std::atoi(row[0].c_str());
        num = num + 1;*/
        
        dbgl_service.async_do((uint64_t)user_->db.uid, [](sp_user_t sp_user_,int32_t id_, int32_t prauid_){
            sql_result_t res1;
            if (SUCCESS != db_CardComment_ext_t::select_id(id_, res1))
            {
                logerror((LOG, "on praise but no comment id:%d", id_));
                return ERROR_SC_NO_COMMENT;
            }
            boost::shared_ptr<db_CardComment_ext_t> sp_db(new db_CardComment_ext_t);
            sp_db->init(*res1.get_row_at(0));
            sp_db->set_praisenum(sp_db->praisenum + 1);
        
            string sql1 = sp_db->get_up_sql();
            if (SUCCESS == dbgl_service.async_execute(sql1))
            {
                db_CardCommentPraise_t db;
                db.commentid = id_;
                db.praiseuid = prauid_;
                db.stamp = date_helper.cur_sec();
                dbgl_service.async_do((uint64_t)sp_user_->db.uid, [](db_CardCommentPraise_t& db_){
                    if (SUCCESS != db_.insert())
                    {
                        return ERROR_SC_PRAISE_FAILED; 
                    }
                }, db);    
            }
            else
            {
                logerror((LOG, "on praise but update praisenum failed, comment id:%d", id_));
                return ERROR_SC_PRAISE_FAILED;
            }
        }, user_, cid_, puid_);
    }
    else
    {
        return ERROR_SC_HAS_PRAISE;
    }
    return SUCCESS;
}

int sc_card_comment_t::req_add_comment(sp_user_t user_, int32_t uid, int32_t resid, int32_t isshow, string msg, vector<sc_msg_def::jpk_card_comment_info_t> &infos, sc_msg_def::jpk_card_comment_info_t &info_)
{
    db_CardComment_t db;
    
    db.praisenum = 0;
    db.resid = resid;
    db.uid = uid;
    db.isshow = isshow;
    db.comment = msg;
    db.stamp = date_helper.cur_sec();
    db.equiprank = sc_user_t::get_equip_level(uid, 0);
    
    sql_result_t res;
    char sql[256];
    sprintf(sql, "select nickname, grade, viplevel from UserInfo where uid = %d;", uid);
    db_service.sync_select(sql, res);
    if (0 == res.affect_row_num())
    {
        return ERROR_SC_ILLEGLE_REQ;
    }
    sql_result_row_t& row = *res.get_row_at(0);
    db.name = row[0];
    db.grade = (int)std::atoi(row[1].c_str());
    db.viplevel = (int)std::atoi(row[2].c_str());
    
    if (SUCCESS != db.sync_insert())
    {
        return ERROR_SC_COMMENT_FAILED; 
    } 
    /*dbgl_service.async_do((uint64_t)db.uid, [](db_CardComment_t& db_, int32_t resid_, vector<sc_msg_def::jpk_card_comment_info_t> &infos_){
        if (db_.sync_insert())
        {
            return ERROR_SC_EXCEPTION; 
        }
        
        card_comment_ins.req_newest_comment(resid_, infos_);
    }, db, resid, infos);  */
    
    req_newest_comment(user_, resid, infos, info_);     
    return SUCCESS;
}
