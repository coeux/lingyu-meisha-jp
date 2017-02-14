#include "sc_friend_flower.h"
#include "date_helper.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "db_service.h"
#include "code_def.h"

#define LOG "SC_FRIEND_FLOWER"
#define ONE_HOUR 3600

int sc_friend_flower_t::addNew(int uid, string name,int lifetime)
{
    if (true)
        return ERROR_SC_FLOWER_UNOPEN;
    //检测是否能送花
    db_FriendFlower_t db;
    /*if (m_user.db.resetFlowerStamp + ONE_HOUR> date_helper.cur_sec())
    {
        return ERROR_SC_HAD_SENT_FLOWER;    
    }*/
    if (!checkIsOrNoSendFlower(m_user.db.uid,uid))
    {
       return ERROR_SC_HAD_SENT_FLOWER;
    }
    db.fuid = m_user.db.uid;
    db.uid = uid;
    db.stamp = date_helper.cur_sec();
    db.lifetime = lifetime;
    db.name = name;
    db.lv = m_user.db.grade;
    db.headid = m_user.db.headid;
    db.getPower = 0;
    db_service.async_do((uint64_t)db.uid, [](db_FriendFlower_t& db_){
        db_.insert();
    }, db);
    m_user.friend_mgr.set_flower_sent(uid);
    m_user.db.set_numFlower(m_user.db.numFlower - 1);
    m_user.db.set_resetFlowerStamp(date_helper.cur_sec());
    m_user.save_db();
    sc_msg_def::nt_receieve_flower_t nt;
    nt.successed = 1;
    logic.unicast(uid, nt);
    return SUCCESS;
}

bool sc_friend_flower_t::checkIsOrNoSendFlower(int32_t frienduid, int32_t uid)  //一小时可以送一次
{
    if (true)
        return false;
    sc_friend_flower_t::load_db();
    //遍历一下好友的Uid和送花时候记录的uid是否相等
    auto time = date_helper.cur_sec(); 
    uint32_t latesttime = 0;
    bool YN = true;
    int32_t index = 0;
    for (auto it=db_hm.begin();it!=db_hm.end();)
    {
        if(frienduid == it->second.fuid && uid == it->second.uid)
        {
            //if (it->second.stamp > latesttime)
                //latesttime = it->second.stamp;
            if (date_helper.offday(it->second.stamp) >= 1)
            {
                if (it->second.stamp > index)
                {
                    index = it->second.stamp;
                    YN = true;
                }
                //return true;
            }
            else  
            {
                if (it->second.stamp > index)
                {
                    index = it->second.stamp;
                    YN = false;
                }
                //return false;
            }
        }
        it++;
    }
    return YN;
    //return true;
    /*if (time > latesttime + ONE_HOUR) //检测该次鲜花是否是一小时前
    {
        return true;    
    }
    else
    {
        return false;          
    }*/
}
void sc_friend_flower_t::load_db()
{
    if (true)
    {
        return;
    }
    db_hm.clear();
    db_info.clear();
    sql_result_t res;
    char buf[4096];
    sprintf(buf, "SELECT `fuid` , `uid` , `name` , `getPower`, `lv`, `headid`, `lifetime` , `stamp` , `id` FROM `FriendFlower` WHERE  `fuid` = %d", m_user.db.uid);
    if (0==db_service.sync_select(buf, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db_FriendFlower_t db;
            size_t j = 0;
            sql_result_row_t& row_= *res.get_row_at(i);
            db.fuid = (int)std::atoi(row_[j++].c_str());
            db.uid = (int)std::atoi(row_[j++].c_str());
            db.name = row_[j++];
            db.getPower = (int)std::atoi(row_[j++].c_str());
            db.lv = (int)std::atoi(row_[j++].c_str());
            db.headid = (int)std::atoi(row_[j++].c_str());
            db.lifetime = (int)std::atoi(row_[j++].c_str());
            db.stamp = (int)std::atoi(row_[j++].c_str());
            int id = (int)std::atoi(row_[j++].c_str());
            db_hm.insert(make_pair(id,db));
        }
        logwarn((LOG, "load friend flower finish"));
    }
    
    sql_result_t res1;
    char buf1[4096];
    sprintf(buf1, "SELECT `fuid` , `uid` , `name` , `getPower`, `lv`, `headid`, `lifetime` , `stamp` , `id` FROM `FriendFlower` WHERE  `uid` = %d", m_user.db.uid);
    if (0==db_service.sync_select(buf1, res1))
    {
        for(size_t i=0; i<res1.affect_row_num(); i++)
        {
            db_FriendFlower_t db;
            size_t j = 0;
            sql_result_row_t& row_= *res1.get_row_at(i);
            db.fuid = (int)std::atoi(row_[j++].c_str());
            db.uid = (int)std::atoi(row_[j++].c_str());
            db.name = row_[j++];
            db.getPower = (int)std::atoi(row_[j++].c_str());
            db.lv = (int)std::atoi(row_[j++].c_str());
            db.headid = (int)std::atoi(row_[j++].c_str());
            db.lifetime = (int)std::atoi(row_[j++].c_str());
            db.stamp = (int)std::atoi(row_[j++].c_str());
            int id = (int)std::atoi(row_[j++].c_str());
            db_info.insert(make_pair(id,db));

        }
        logwarn((LOG, "load friend flower finish"));
    }

}

void sc_friend_flower_t::get_flowers()
{
    if (true)
    {
        sc_msg_def::ret_flower_list_t ret;
        ret.code = ERROR_SC_FLOWER_UNOPEN;
        logic.unicast( m_user.db.uid,ret);
        return;
    }
    sc_friend_flower_t::load_db();
    sc_msg_def::ret_flower_list_t ret;
    // TODO 可能更新不完整，在用户登录期间db_hm不会更新，但表已经更新
    for (auto it=db_info.begin();it!=db_info.end();)
    {
        //检测该次鲜花是否凋谢，凋谢就删了
        auto time = date_helper.cur_sec(); 
        if (time > it->second.stamp + it->second.lifetime )
        {
            int flower_id = it->first;
            it++;
            this->del_flower(flower_id);
            db_info.erase(flower_id);
            continue;
        }
        if (it->second.getPower == 1)
        {   
            it++; 
            continue;
        }
        int32_t restTime = it->second.stamp + it->second.lifetime - time;
        //如果没有则送回客户端
        sc_msg_def::flower_info_t info;
        info.id = it->first;
        info.uid = it->second.fuid;
        info.rest_time = restTime;
        
        char sql[256];
        sql_result_t res;
        sprintf(sql,"select nickname from UserInfo where uid=%d;",it->second.fuid);
        db_service.sync_select(sql, res); 
        if( 0==res.affect_row_num() ) 
            info.name = it->second.name();
        else
        {
            sql_result_row_t& row = *res.get_row_at(0);
            info.name = row[0];
        }
        info.life_time = it->second.lifetime;
        info.lv = it->second.lv;
        info.headid = it->second.headid;
        ret.flowers.push_back(info);
        it++;
    }
    logic.unicast( m_user.db.uid,ret);
}

void sc_friend_flower_t::receive_flower(int32_t id)
{
    if (true)
    {
        sc_msg_def::ret_receive_flower_t ret;
        ret.code = ERROR_SC_FLOWER_UNOPEN;
        logic.unicast( m_user.db.uid,ret);
        return;
    }
    sc_msg_def::ret_receive_flower_t ret;
    for (auto it=db_info.begin();it!=db_info.end();it++)
    {
        bool successReceiveFlower = false; //用于标识成功收到花的flag
        if (it->first == id)
        {
            //检测该次鲜花是否凋谢，凋谢就删了
            auto time = date_helper.cur_sec(); 
            if (time < it->second.stamp + it->second.lifetime)
            {
                successReceiveFlower = true;
            }
            else
            {
                this->del_flower(id);
                db_info.erase(id);
            } 
            if (it->second.getPower == 1)
            {
                ret.code = ERROR_SC_FLOWER_USED; 
                break;
            }

            if (m_user.db.useFlower >= 10)
            {
                if (ret.idList.capacity() > 0)
                    ret.code = SUCCESS;
                else
                    ret.code = ERROR_SC_FLOWER_USE_LIMIT;
                break;
            }
            m_user.db.set_useFlower(m_user.db.useFlower + 1);
            db_FriendFlower_t db;
            db.getPower = 1;
            db.id = id;
            db.uid = it->second.uid;
            db.name = it->second.name();
            db.fuid = it->second.fuid;
            db.lv = it->second.lv;
            db.headid = it->second.headid;
            db.stamp = it->second.stamp;
            db.lifetime = it->second.lifetime; 
            db_service.async_do((uint64_t)db.id, [](db_FriendFlower_t db_){
                db_.update();    
            }, db);
            m_user.on_power_change(6);
            m_user.save_db();
            
            if (successReceiveFlower)
            {
                ret.code = SUCCESS;
                ret.idList.push_back(id);
            }
            break;
        }
    }
    logic.unicast( m_user.db.uid,ret);
}

void sc_friend_flower_t::receive_userguide()//新手引导
{
    if (true)
    {
        sc_msg_def::ret_receive_flower_t ret;
        ret.code = ERROR_SC_FLOWER_UNOPEN;
        logic.unicast( m_user.db.uid,ret);
        return;
    }
    sc_msg_def::ret_receive_flower_t ret;
    ret.code = SUCCESS;
    ret.idList.push_back(1);
    m_user.on_power_change(6);
    m_user.save_db();
    logic.unicast( m_user.db.uid,ret);
}
void sc_friend_flower_t::receive_all()
{
    if (true)
    {
        sc_msg_def::ret_receive_flower_t ret;
        ret.code = ERROR_SC_FLOWER_UNOPEN;
        logic.unicast( m_user.db.uid,ret);
        return;
    }
    sc_msg_def::ret_receive_flower_t ret;
    bool successReceiveFlower = false; //用于标识成功收到花的flag
    for (auto it=db_info.begin();it!=db_info.end();)
    {
        //检测该次鲜花是否凋谢，凋谢就删了
        auto time = date_helper.cur_sec(); 
        if (time >= it->second.stamp + it->second.lifetime)
        {
            int flower_id = it->first;
            this->del_flower(flower_id);
            it = db_info.erase(it);            
        }
        else
        {
            successReceiveFlower = true;
            it++;
        }
    }
    for (auto it=db_info.begin();it!=db_info.end();++it)
    {
        if (m_user.db.useFlower >= 10 )
        {
            if (ret.idList.capacity() > 0)
                ret.code = SUCCESS;
            else
                ret.code = ERROR_SC_FLOWER_USE_LIMIT;
            break;
        }
        if ( it->second.getPower == 0)
        {
            m_user.db.set_useFlower(m_user.db.useFlower + 1);
            db_FriendFlower_t db;
            db.getPower = 1;
            db.id = it->first;
            db.uid = it->second.uid;
            db.fuid = it->second.fuid;
            db.name = it->second.name();
            db.lv = it->second.lv;
            db.headid = it->second.headid;
            db.stamp = it->second.stamp;
            db.lifetime = it->second.lifetime;
            db_service.async_do((uint64_t)it->first, [](db_FriendFlower_t db_){
                db_.update();    
            }, db);
            it->second.getPower = 1;
            m_user.on_power_change(6);
            m_user.save_db();

            if (successReceiveFlower)
            {
                ret.code = SUCCESS;
                ret.idList.push_back(it->first);
            }
        }
    }
    logic.unicast( m_user.db.uid,ret);
}

void sc_friend_flower_t::del_flower(int32_t id)
{
    if (true)
    {
        return;
    }
    auto it = db_info.find(id);
    char buf[4096];
    sprintf(buf, "DELETE FROM `FriendFlower` WHERE  `id` = %d", id);
    db_service.async_do((uint64_t)id, [&](db_FriendFlower_t& db_){
        db_service.async_execute(buf);
    }, it->second);
}
