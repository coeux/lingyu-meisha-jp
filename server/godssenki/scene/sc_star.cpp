#include "sc_star.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "repo_def.h"
#include "code_def.h"
#include "db_def.h"
#include "random.h"

using namespace std;

#define LOG "SC_STAR"
//======================================================
sc_star_t::sc_star_t(sc_user_t &user_):m_user(user_)
{
}

void sc_star_t::get_star_jpk(sc_msg_def::jpk_star_t &jpk_)
{
    jpk_.lv = db.lv;
    jpk_.pos = db.pos;
    jpk_.att = db.att;
    jpk_.value = db.value;
}

//======================================================
sc_star_mgr_t::sc_star_mgr_t(sc_user_t &user_):m_user(user_),m_last_attr(0),m_last_value(0),m_last_pid(0)
{
}
void sc_star_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Star_t::sync_select_star(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_star_t sp_star(new sc_star_t(m_user));
            sp_star->db.init(*res.get_row_at(i));

            int32_t pid = sp_star->db.pid;

            auto it_hm = m_stars.find(pid);
            if( it_hm == m_stars.end() )
            {
                vector<sp_star_t> stars;
                it_hm = m_stars.insert( make_pair(pid,std::move(stars)) ).first;
            }
            it_hm->second.push_back( sp_star );
        }
        logwarn((LOG, "load star finish"));
    }
}
void sc_star_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Star_t::select_star(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            sp_star_t sp_star(new sc_star_t(m_user));
            sp_star->db.init(*res.get_row_at(i));

            int32_t pid = sp_star->db.pid;

            auto it_hm = m_stars.find(pid);
            if( it_hm == m_stars.end() )
            {
                vector<sp_star_t> stars;
                it_hm = m_stars.insert( make_pair(pid,std::move(stars)) ).first;
            }
            it_hm->second.push_back( sp_star );
        }
    }
}
int32_t sc_star_mgr_t::is_open(int32_t rare_,int32_t lv_,int32_t pos_)
{
    switch( rare_ )
    {
        case 1:
            //白
            switch( lv_ )
            {
                case 0:
                    return 0;
                case 1:
                    if( pos_==1)
                        return 1;
                    else
                        return 0;
                case 2:
                case 3:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;
                case 4:
                    if( 1<=pos_ && pos_<=3 )
                        return 1;
                    else
                        return 0;
            }
        case 2:
            //绿
            switch( lv_ )
            {
                case 0:
                    return 0;
                case 1:
                    if( pos_==1)
                        return 1;
                    else
                        return 0;
                case 2:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;
                case 3:
                case 4:
                    if( 1<=pos_ && pos_<=3 )
                        return 1;
                    else
                        return 0;
            }
        case 3:
            //蓝
            switch( lv_ )
            {
                case 0:
                case 1:
                    if( pos_==1)
                        return 1;
                    else
                        return 0;
                case 2:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;

                case 3:
                case 4:
                    if( 1<=pos_ && pos_<=3 )
                        return 1;
                    else
                        return 0;
            }
        case 4:
            //紫
            switch( lv_ )
            {
                case 0:
                case 1:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;
                case 2:
                    if( 1<=pos_ && pos_<=3 )
                        return 1;
                    else
                        return 0;
                case 3:
                case 4:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;
            }
        case 5:
            //金
            switch( lv_ )
            {
                case 0:
                case 1:
                case 2:
                    if( 1<=pos_ && pos_<=3 )
                        return 1;
                    else
                        return 0;
                case 3:
                    if( 1<=pos_ && pos_<=2 )
                        return 1;
                    else
                        return 0;
                case 4:
                    if( 1==pos_  )
                        return 1;
                    else
                        return 0;

            }
        default:
            return 0;
    }
}
void sc_star_mgr_t::open_attr(sc_msg_def::req_star_open_t &req_)
{
    sc_msg_def::ret_star_open_t ret;
    ret.pid = req_.pid;
    ret.lv = req_.lv;
    ret.pos = req_.pos;
    ret.att = 1;
    ret.value = 0;
    int32_t rare;
    //获取伙伴的稀有度
    //稀有度和星图有关 
    repo_def::role_t *role = NULL;
    if( 0 == req_.pid )
    {
        //rare = 5;
        role = repo_mgr.role.get(m_user.db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
        rare = role->rare;
    }
    else
    {
        sp_partner_t partner = m_user.partner_mgr.get(req_.pid);
        if( !partner )
        {
            logerror((LOG, "open_attr, no pid:%d", req_.pid));
            return;
        }
        role = repo_mgr.role.get(partner->db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
        rare = role->rare;
    }
    //角色是否有资格开启该星魂位置
    /* 去掉等级限制
    if( !is_open(rare,req_.lv,req_.pos) )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    */
    //该位置是否已经开启
    auto it_hm = m_stars.find(req_.pid);
    if( it_hm == m_stars.end() )
    {
        vector<sp_star_t> stars;
        it_hm = m_stars.insert( make_pair(req_.pid,std::move(stars)) ).first;
    }
    else
    {
        for( auto it_v=it_hm->second.begin();it_v!=it_hm->second.end();++it_v)
        {
          if((*it_v)->db.pos==req_.pos)
            {
                ret.code = ERROR_SC_ILLEGLE_REQ;
                logic.unicast(m_user.db.uid, ret);
                return;
          }
        }
    }
    //扣去星点
  //  int32_t resid = 19006 - req_.lv;
    int32_t resid = 19000 + req_.lv;
    if( m_user.item_mgr.has_items(resid,1) )
    {
        sc_msg_def::nt_bag_change_t nt;
        m_user.item_mgr.consume(resid,1,nt);
        m_user.item_mgr.on_bag_change(nt);
    }
    else
    {
        int32_t resid = 19000 + req_.lv;
        int32_t size = repo_mgr.shop.size();
        for (int32_t i = 1;repo_mgr.shop.get(i) != NULL;i++)
        {
            ret.code = ERROR_SC_NO_YB;
            repo_def::shop_t* shopInfo = repo_mgr.shop.get(i);
            if(shopInfo->item_id == resid && m_user.rmb() >= shopInfo->price)
            {
                m_user.consume_yb(shopInfo->price);
                m_user.save_db();
                ret.code = SUCCESS;
                break;
            }
        }

        if( ret.code != SUCCESS )
        {
            logic.unicast(m_user.db.uid, ret);
            return;
        }

    }
    //开启星魂位置
    sp_star_t sp_star(new sc_star_t(m_user));
    db_Star_t &db = sp_star->db;
    db.uid = m_user.db.uid;
    db.pid = req_.pid;
    db.lv = req_.lv;
    db.pos = req_.pos;
    random_attr(role->job,req_.lv,db.att,db.value);

    it_hm->second.push_back(sp_star);

    //属性变化
    m_user.on_pro_changed(req_.pid);

    m_user.reward.update_opentask(open_task_talent_num);
    
    ret.att = db.att;
    ret.value = db.value;
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Star_t& db_){
        db_.insert();
    }, db);
}
void sc_star_mgr_t::random_attr(int32_t job_,int32_t lv_,int32_t &att_,int32_t &value_)
{
    //随机数值权重区间
    int32_t r1 = random_t::rand_integer(1, 10000);
    int32_t sum=0,i=1;
    auto it_p=repo_mgr.star_prob.end();
    while(1)
    {
        it_p=repo_mgr.star_prob.find(i);
        if( it_p==repo_mgr.star_prob.end() )
        {
            att_ = 1;
            value_ = 0;
            return;
        }
        sum += it_p->second.probability;
        if( r1<=sum )
            break;
        ++i;
    }
    if( it_p->second.potential.size() != 3 )
    {
        att_ = 1;
        value_ = 0;
        return;
    }
    int32_t weight = random_t::rand_integer(it_p->second.potential[1],it_p->second.potential[2]);
    //随机属性种类
    r1 = random_t::rand_integer(1, 5);
    //获取属性值上下限
    auto it = repo_mgr.star.find(lv_);
    if( it == repo_mgr.star.end() )
    {
        att_ = value_ = 1;
        return;
    }
    int32_t low=0,high=0;
    
    switch( r1 )
    {
        case 1:
            {
                att_ = 1;
                low = it->second.min_atk;
                high = it->second.max_atk;
            }
            break;
        case 2:
            {
                att_ = 2;
                low = it->second.min_mgc;
                high = it->second.max_mgc;
            }
            break;
        case 3:
            {
                att_= 3;
                low = it->second.min_def;
                high = it->second.max_def;
            }
            break;
        case 4:
            {
                att_ = 4;
                low = it->second.min_res;
                high = it->second.max_res;
            }
            break;
        case 5:
            {
                att_ = 5;
                low = it->second.min_hp;
                high = it->second.max_hp;
            }
            break;
        default:break;
    }
    //生成属性值
    value_ = low + (high-low)*weight/100;
}
void sc_star_mgr_t::flush_attr(sc_msg_def::req_star_flush_t &req_)
{
    sc_msg_def::ret_star_flush_t ret;
    ret.pid = req_.pid;
    ret.lv = req_.lv;
    ret.pos = req_.pos;
    ret.att = ret.value = 0;
    ret.code = SUCCESS;
    
    //获取伙伴的职业
    repo_def::role_t *role;
    if( 0 == req_.pid )
    {
        role = repo_mgr.role.get(m_user.db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
    }
    else
    {
        sp_partner_t partner = m_user.partner_mgr.get(req_.pid);
        if( !partner )
        {
            logerror((LOG, "open_attr, no pid:%d", req_.pid));
            return;
        }
        role = repo_mgr.role.get(partner->db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
    }
    //该位置是否已经开启
    sp_star_t sp_star;
    auto it_hm = m_stars.find(req_.pid);
    if( it_hm == m_stars.end() )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    else
    {
        auto it_v = it_hm->second.begin();
        for( ;it_v!=it_hm->second.end();++it_v)
        {
            if( ((*it_v)->db.lv==req_.lv) && ((*it_v)->db.pos==req_.pos) )
            {
                sp_star = *it_v;
                break;
            }
        }
        if( it_v == it_hm->second.end() )
        {
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }
    //扣去星点
    if( 1==req_.flag )
    {
       // int32_t resid = 19006 - req_.lv;
        int32_t resid = 19000 + req_.lv;
        if( m_user.item_mgr.has_items(resid,1) )
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(resid,1,nt);
            m_user.item_mgr.on_bag_change(nt);
        }
        else
        {
            ret.code = ERROR_EQ_LESS_MATERIAL;
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }
    else if( 2==req_.flag )
    {
        int32_t resid = 19000 + req_.lv;
        int32_t size = repo_mgr.shop.size();
        for (int32_t i = 1;repo_mgr.shop.get(i) != NULL;i++)
        {
            ret.code = ERROR_SC_NO_YB;
            repo_def::shop_t* shopInfo = repo_mgr.shop.get(i);
            if(shopInfo->item_id == resid && m_user.rmb() >= shopInfo->price)
            {
                m_user.consume_yb(shopInfo->price);
                m_user.save_db();
                ret.code = SUCCESS;
                break;
            }
        }
        if( ret.code != SUCCESS )
        {
            logic.unicast(m_user.db.uid, ret);
            return;
        }
    }
    else
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    //刷新属性
    random_attr(role->job,req_.lv,sp_star->db.att,sp_star->db.value);
    
    //属性变化
    m_user.on_pro_changed(req_.pid);

    ret.att = sp_star->db.att;
    ret.value = sp_star->db.value;
    logic.unicast(m_user.db.uid, ret);
    
    m_user.reward.update_opentask(open_task_talent_num);
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Star_t& db_){
        db_.update();
    }, sp_star->db);

}
void sc_star_mgr_t::get_attr(sc_msg_def::req_star_get_t &req_)
{
    sc_msg_def::ret_star_get_t ret;
    ret.pid = req_.pid;
    ret.lv = req_.lv;
    ret.pos = req_.pos;
    ret.att = ret.value = 0;
    ret.code = SUCCESS;
    //获取伙伴的职业
    repo_def::role_t *role;
    if( 0 == req_.pid )
    {
        role = repo_mgr.role.get(m_user.db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
    }
    else
    {
        sp_partner_t partner = m_user.partner_mgr.get(req_.pid);
        if( !partner )
        {
            logerror((LOG, "open_attr, no pid:%d", req_.pid));
            return;
        }
        role = repo_mgr.role.get(partner->db.resid);
        if(! role )
        {
            logerror((LOG,"open_attr, repo no resid!"));
            return;
        }
    }
    //该位置是否已经开启
    sp_star_t sp_star;
    auto it_hm = m_stars.find(req_.pid);
    if( it_hm == m_stars.end() )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        logerror((LOG,"pos not open!"));
        return;
    }
    else
    {
        auto it_v = it_hm->second.begin();
        for( ;it_v!=it_hm->second.end();++it_v)
        {
            if((*it_v)->db.pos==req_.pos)
            {
                sp_star = *it_v;
                break;
            }
        }
        if( it_v == it_hm->second.end() )
        {
            ret.code = ERROR_SC_ILLEGLE_REQ;
            logic.unicast(m_user.db.uid, ret);
            logerror((LOG,"pos not open 2!"));
            return;
        }
    }
    //扣去星点
    if( 1==req_.flag )
    {
      //int32_t resid = 19006 - req_.lv;
        int32_t resid = 19000 + req_.lv;
        if( m_user.item_mgr.has_items(resid,1) )
        {
            sc_msg_def::nt_bag_change_t nt;
            m_user.item_mgr.consume(resid,1,nt);
            m_user.item_mgr.on_bag_change(nt);
        }
        else
        {
            ret.code = ERROR_EQ_LESS_MATERIAL;
            logic.unicast(m_user.db.uid, ret);
            logerror((LOG,"19005 is not enough!"));
            return;
        }
    }
    else if( 2==req_.flag )
    {
        int32_t resid = 19000 + req_.lv;
        int32_t size = repo_mgr.shop.size();
        for (int32_t i = 1;repo_mgr.shop.get(i) != NULL;i++)
        {
            ret.code = ERROR_SC_NO_YB;
            repo_def::shop_t* shopInfo = repo_mgr.shop.get(i);
            if(shopInfo->item_id == resid && m_user.rmb() >= shopInfo->price)
            {
                m_user.consume_yb(shopInfo->price);
                m_user.save_db();
                ret.code = SUCCESS;
                break;
            }
        }
        if( ret.code != SUCCESS )
        {
            logic.unicast(m_user.db.uid, ret);
            logerror((LOG,"yb is not enough!"));
            return;
        }
    }
    else
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        logerror((LOG,"wrong argu!"));
        return;
    }

    //刷新属性
    random_attr(role->job,req_.lv,m_last_attr,m_last_value);
    m_last_pid = req_.pid;
    m_last_sp_star = sp_star;
        
    
    m_user.reward.update_opentask(open_task_talent_num);
    
    ret.att = m_last_attr;
    ret.value = m_last_value;
    logic.unicast(m_user.db.uid, ret);
    m_user.daily_task.on_event(evt_starsoul_flash);
    m_user.reward.daily_talent_num(1);
    m_user.reward.update_talent_activity(1);
}
void sc_star_mgr_t::set_attr()
{
    sc_msg_def::ret_star_set_t ret;

    if( !m_last_sp_star )
    {
        ret.code = ERROR_SC_ILLEGLE_REQ;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    m_last_sp_star->db.att = m_last_attr;
    m_last_sp_star->db.value = m_last_value;
    m_user.on_pro_changed(m_last_pid);
    
    db_service.async_do((uint64_t)m_user.db.uid, [](db_Star_t& db_){
        db_.update();
    }, m_last_sp_star->db);

    m_last_sp_star = sp_star_t();

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
}
