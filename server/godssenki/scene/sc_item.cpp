#include "sc_item.h"
#include "sc_user.h"
#include "sc_bag.h"
#include "sc_logic.h"
#include "sc_statics.h"
#include "sc_message.h"
#include "sc_push_def.h"
#include "sc_lv_rank.h"
#include "sc_fp_rank.h"
#include "sc_activity.h"
#include "sc_gang.h"
#include "sc_cache.h"
#include "sc_mailinfo.h"

#include "ys_tool.h"
#include "repo_def.h"
#include "code_def.h"
#include "random.h"
#include <sstream>

#define LOG "SC_ITEM"

#define ITEM_MONEY    10001
#define ITEM_BATEPX   10002
#define ITEM_YB       10003
#define ITEM_FPOINT   10004
#define ITEM_POWER    10005
#define ITEM_RUNE     10006
#define ITEM_VIP      10007
#define ITEM_GRADE    10008
#define ITEM_SOUL     10009
#define ITEM_HONOR    10010
#define ITEM_EXP      10011
#define SILV_BOX      20001
#define GOLD_BOX      20002
#define ITEM_CARD_EVENT_COIN 16001
#define ITEM_SOULNODE_COIN 16003
#define ITEM_UNHONOR     16013
#define ITEM_EXPEDITIONCOIN 10019

#define EQUIP_TYPE 2
#define CHIP_TYPE 14
#define WING_TYPE 15
#define PET_TYPE 17

sc_item_t::sc_item_t(sc_user_t& user_):m_user(user_)
{
}
void sc_item_t::get_item_jpk(sc_msg_def::jpk_item_t& jpk_)
{
    jpk_.itid = db.itid;
    jpk_.resid = db.resid;
    jpk_.num = db.count;
}
void sc_item_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
            }, sql);
}
//======================================================
sc_item_mgr_t::sc_item_mgr_t(sc_user_t& user_):
    m_user(user_)
{
}
void sc_item_mgr_t::init_new_user()
{
    sc_msg_def::nt_bag_change_t nt;
    addnew(19001,0,nt);
    addnew(15001,0,nt);
    /*
       addnew(13001,5,nt);
       addnew(13002,5,nt);
       addnew(13003,5,nt);
       addnew(13004,5,nt);
       addnew(13008,5,nt);
       addnew(13009,5,nt);
       addnew(17101,1,nt);
       addnew(17201,1,nt);
       */
}
void sc_item_mgr_t::load_db()
{
    sql_result_t res;
    if (0==db_Item_t::sync_select_item_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_item_t> sp_item(new sc_item_t(m_user));
            sp_item->db.init(*res.get_row_at(i));
            m_maxid.update(sp_item->db.itid);
            m_item_hm.insert(make_pair(sp_item->db.resid, sp_item));
        }
        logwarn((LOG, "load item finish"));
    }
}
void sc_item_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0==db_Item_t::select_item_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_item_t> sp_item(new sc_item_t(m_user));
            sp_item->db.init(*res.get_row_at(i));
            m_maxid.update(sp_item->db.itid);
            m_item_hm.insert(make_pair(sp_item->db.resid, sp_item));
        }
    }
}
sp_item_t sc_item_mgr_t::get(int32_t resid_)
{
    auto it = m_item_hm.find(resid_);
    if (it != m_item_hm.end())
        return it->second;
    return sp_item_t();
}
int32_t sc_item_mgr_t::getdbid(int32_t resid_)
{
    auto it = m_item_hm.find(resid_);
    if (it != m_item_hm.end())
        return it->second->db.itid;
    return 0;
}
void sc_item_mgr_t::put(sc_msg_def::nt_bag_change_t& change_)
{
    for (size_t i=0; i<change_.items.size(); i++)
    {
        sc_msg_def::jpk_item_t& item = change_.items[i];

        if (item.num <= 0)
        {
            logerror((LOG, "put but item num<=0!"));
            continue;
        }

        switch(item.resid)
        {
            case ITEM_MONEY:
                m_user.on_money_change(item.num);
                break;
            case ITEM_BATEPX:
                m_user.on_battlexp_change(item.num);
                break;
            case ITEM_YB:
                m_user.on_freeyb_change(item.num);
                break;
            case ITEM_POWER:
                m_user.on_power_change(item.num);
                break;
            case ITEM_FPOINT:
                m_user.on_fpoint_change(item.num);
                break;
            case ITEM_SOUL:
                m_user.on_soul_change(item.num);
                break;
            case ITEM_GRADE:
                m_user.compensate_grade(item.num, 0);
                break;
            case ITEM_UNHONOR:
                m_user.on_unhonor_change(item.num);
                break;
            default:
                {
                    /*
                    //记录事件
                    statics_ins.unicast_eventlog(m_user,change_.cmd(),item.resid,item.num,0,1);
                    */

                    sp_item_t sp_item = get(item.resid);
                    if (sp_item != NULL)
                    {
                        db_Item_ext_t& db = sp_item->db;
                        db.set_count(db.count + item.num);


                        item.num = db.count;
                        item.itid = db.itid;
                        sp_item->save_db();


                    }
                    else
                    {
                        boost::shared_ptr<sc_item_t> sp_item(new sc_item_t(m_user));
                        db_Item_t& db = sp_item->db;
                        db.uid = m_user.db.uid;
                        db.itid = item.itid = m_maxid.newid();
                        db.resid = item.resid;
                        db.count = item.num;
                        m_item_hm.insert(make_pair(sp_item->db.resid, sp_item));

                        db_service.async_do((uint64_t)m_user.db.uid, [](db_Item_t& db_){
                                db_.insert();
                                }, db);
                    }

                }
        }
    }
}
void sc_item_mgr_t::on_bag_change(sc_msg_def::nt_bag_change_t& change_)
{
    if(!change_.items.empty()||!change_.add_equips.empty()||!change_.del_equips.empty()||!change_.chips.empty()||!change_.add_wings.empty()||!change_.del_wings.empty()||!change_.add_pet.empty())
    {
        logic.unicast(m_user.db.uid, change_);
    }
}
bool sc_item_mgr_t::has_items(int32_t resid_, int32_t num_)
{
    auto it = m_item_hm.find(resid_);
    if (it != m_item_hm.end() && it->second->db.count >= num_)
    {
        return true;
    }
    if (resid_ == 0)
    {
        return true;
    }
    return false;
}
int32_t sc_item_mgr_t::get_items_count(int32_t resid_)
{
    auto it = m_item_hm.find(resid_);
    if( it == m_item_hm.end() )
        return 0;

    return it->second->db.count;
}
bool sc_item_mgr_t::consume(int32_t resid_, int32_t num_, sc_msg_def::nt_bag_change_t& change_)
{
    if( num_<=0 )
        return true;

    auto it = m_item_hm.find(resid_);
    if (it != m_item_hm.end() && it->second->db.count >= num_)
    {
        db_Item_ext_t& db = it->second->db;
        int32_t ori_count = db.count;

        db.set_count(db.count - num_);

        if (db.count<=0)
        {
            m_item_hm.erase(db.resid);
            db_service.async_do((uint64_t)m_user.db.uid, [](db_Item_t& db_){
                    db_.remove();
                    }, db.data());
        }
        else
        {
            it->second->save_db();
        }

        //生成消耗记录
        statics_ins.unicast_consumelog(m_user,resid_,1,num_,ori_count-num_);

        sc_msg_def::jpk_item_t item;
        item.itid = db.itid;
        item.resid = db.resid;
        item.num = db.count;
        change_.items.push_back(item);

        /*
        //记录事件
        statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,0,-1);
        */

        return true;

    }
    return false;
}
bool sc_item_mgr_t::consume_all(int32_t resid_, sc_msg_def::nt_bag_change_t& change_)
{
    auto it = m_item_hm.find(resid_);
    if ( it != m_item_hm.end() )
    {
        db_Item_ext_t& db = it->second->db;
        int32_t ori_count = db.count;

        db.set_count(0);

        if (db.count<=0)
        {
            m_item_hm.erase(db.resid);
            db_service.async_do((uint64_t)m_user.db.uid, [](db_Item_t& db_){
                    db_.remove();
                    }, db.data());
        }
        else
        {
            it->second->save_db();
        }

        //生成消耗记录
        statics_ins.unicast_consumelog(m_user,resid_,1,0,ori_count);

        sc_msg_def::jpk_item_t item;
        item.itid = db.itid;
        item.resid = db.resid;
        item.num = db.count;
        change_.items.push_back(item);

        /*
        //记录事件
        statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,0,-1);
        */

        return true;
    }
    return false;
}
bool sc_item_mgr_t::addnew(int32_t resid_, int32_t num_, sc_msg_def::nt_bag_change_t& change_)
{
    if (num_ <= 0)
        return false;

    repo_def::item_t* rp_item = repo_mgr.item.get(resid_);
    if (rp_item == NULL)
        return false;

    switch(rp_item->type)
    {
        case EQUIP_TYPE: 
            m_user.equip_mgr.addnew(resid_, num_, change_);
            //记录事件
            statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,EQUIP_TYPE);
            return true;
        case CHIP_TYPE:
            m_user.partner_mgr.add_new_chip(resid_, num_, change_.chips);
            //记录事件
            statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,CHIP_TYPE);
            return true;
        case WING_TYPE:
            m_user.wing.addnew(resid_, num_, change_);
            //记录事件
            statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,WING_TYPE);
            return true;
        case PET_TYPE:
            m_user.pet_mgr.addnew(resid_, change_);
            //记录事件
            statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,1,PET_TYPE);
            return true;
    }

    //伙伴
    if (resid_ / 10000 == 4)
    {
        m_user.partner_mgr.hire_from_reward(resid_%10000,1);
        return true;
    }

    // 符文
    if (resid_ / 1000 == 18 && resid_ >= 18010)
    {
        m_user.new_rune_mgr.add_new_rune(resid_, num_);
    }

    switch(resid_)
    {
        case ITEM_MONEY:
            m_user.on_money_change(num_);
            break;
        case ITEM_BATEPX:
            m_user.on_battlexp_change(num_);
            break;
        case ITEM_YB:
            m_user.on_freeyb_change(num_);
            break;
        case ITEM_POWER:
            m_user.on_power_change(num_);
            break;
        case ITEM_FPOINT:
            m_user.on_fpoint_change(num_);
            break;
        case ITEM_RUNE:
            m_user.on_runechip_change(num_);
            break;
        case ITEM_SOUL:
            m_user.on_soul_change(num_);
            break;
        case ITEM_HONOR:
            m_user.on_honor_change(num_);
            break;
        case ITEM_EXP:
            m_user.on_exp_change(num_);
            break;
        case ITEM_CARD_EVENT_COIN:
            m_user.card_event.on_coin_change(num_);
            break;
        case ITEM_EXPEDITIONCOIN:
            m_user.on_expeditioncoin_change(num_);
            break;
        case ITEM_SOULNODE_COIN:
            m_user.soulrank_mgr.on_coin_change(num_);
            break;
        case ITEM_UNHONOR:
            m_user.on_unhonor_change(num_);
            break;
        case ITEM_VIP:
            {
                //补偿vip等级
                if( m_user.db.viplevel < num_ )
                    m_user.vip.compensate_vip(num_);
            }
            break;
        default:
            {
                if (m_user.bag.can_contain(resid_))
                {
                    m_user.task.on_got_items(resid_, num_);
                    m_user.love_task.on_got_items(resid_, num_);

                    sp_item_t sp_item = get(resid_);
                    if (sp_item != NULL)
                    {
                        db_Item_ext_t& db = sp_item->db;
                        db.set_count(db.count + num_);
                        sp_item->save_db();


                        sc_msg_def::jpk_item_t item;
                        item.itid = db.itid;
                        item.resid = resid_;
                        item.num = db.count;
                        change_.items.push_back(std::move(item));
                    }
                    else
                    {
                        boost::shared_ptr<sc_item_t> sp_item(new sc_item_t(m_user));
                        db_Item_t& db = sp_item->db;
                        db.uid = m_user.db.uid;
                        db.itid = m_maxid.newid();
                        db.resid = resid_;
                        db.count = num_;
                        m_item_hm.insert(make_pair(sp_item->db.resid, sp_item));
                        db_service.async_do((uint64_t)m_user.db.uid, [](db_Item_t& db_){
                                db_.insert();
                                }, db);


                        sc_msg_def::jpk_item_t item;
                        item.itid = db.itid;
                        item.resid = db.resid;
                        item.num = db.count;
                        change_.items.push_back(std::move(item));
                    }
                    //记录事件
                    statics_ins.unicast_eventlog(m_user,change_.cmd(),resid_,num_,0,1);


                    return true;
                }
                else return false;
            }
    }

    return true;
}
int32_t sc_item_mgr_t::gemstone_compose(int32_t src_, int32_t compose_num_, int32_t safe_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    sc_msg_def::nt_bag_change_t nt;

    repo_def::gemstone_t *rp_src = repo_mgr.gemstone.get(src_);
    if (rp_src == NULL)
    {
        logerror((LOG, "repo no gemstone resid:%d", src_));
        return ERROR_SC_EXCEPTION; 
    }

    repo_def::gemstone_t *rp_dst = repo_mgr.gemstone.get(src_+1);
    if (rp_dst == NULL)
    {
        logerror((LOG, "repo no gemstone resid:%d", src_+1));
        return ERROR_SC_EXCEPTION; 
    }

    int dst_level = rp_src->level+1;
    repo_def::gemstone_compose_t* rp_cmp = repo_mgr.gemstone_compose.get(dst_level);
    if (rp_cmp == NULL)
    {
        logerror((LOG, "repo no gemstone compose level:%d", dst_level));
        return ERROR_SC_EXCEPTION;
    }

    sp_item_t sp_item = get(src_);
    if (sp_item == NULL)
    {
        return ERROR_GEM_NO_ITEM; 
    }

    //TODO:防止数据溢出
    int need = compose_num_ * 3;
    if (sp_item->db.count < need)
    {
        return ERROR_GEM_LESS_MATERIAL; 
    }

    //判断包裹能否保存生成的宝石
    if (!m_user.bag.can_contain(rp_dst->id))
    {
        return ERROR_BAG_FULL;
    }

    //TODO:以后查找商城表
    static const int32_t safestone_price = 15;
    int32_t need_rmb = 0;
    if (safe_ > 0)
    {
        sp_item_t sp_safestone = get(rp_src->safestone_id);
        if (safe_ == 1)
        {
            if (sp_safestone == NULL)
                return ERROR_GEM_LESS_SAFESTONE;
            else if (sp_safestone->db.count < compose_num_)
                return ERROR_GEM_LESS_SAFESTONE;
            else
                consume(rp_src->safestone_id, compose_num_, nt);
        }
        else if (safe_ == 2)
        {
            if (sp_safestone == NULL)
            {
                need_rmb = compose_num_ * safestone_price;
                if (need_rmb > m_user.rmb())
                    return ERROR_GEM_LESS_RMB;
            }
            else if (sp_safestone->db.count < compose_num_)
            {
                need_rmb = (compose_num_- sp_safestone->db.count) * safestone_price;
                if (need_rmb > m_user.rmb())
                    return ERROR_GEM_LESS_RMB;
                consume(rp_src->safestone_id, sp_safestone->db.count, nt);
            }
        }
    }

    //获得成功的数量
    int32_t sucess_num = 0; 
    for(int i=0;i<compose_num_;i++)
    {
        //旧逻辑
        /*int32_t n = random_t::rand_integer(1, 10000);
          if (n <= rp_cmp->prob)
          sucess_num++;
          */
        //新逻辑
        sucess_num++;
    }

    logwarn((LOG, "gemstone_compose, safe:%d, need_rmb:%d, sucess_num:%d", safe_, need_rmb, sucess_num));

    //消耗掉材料宝石
    if (safe_ <= 0)
    {
        //没有保护石则直接消耗
        consume(src_, need, nt);
    }
    else
    {
        //在使用安全石的情况下，失败的结果不会导致宝石消失, 只消耗成功的宝石 
        consume(src_, sucess_num*3, nt);
        //如果需要额外的费用，则消耗rmb
        if (need_rmb > 0)
        {
            m_user.consume_yb(need_rmb);
            m_user.save_db();
        }
    }

    //如果有成功合成的宝石
    addnew(rp_dst->id, sucess_num, nt);

    //刷新数据
    on_bag_change(nt);

    //通知合成结果
    sc_msg_def::ret_gemstone_compose_t ret;
    ret.fail = compose_num_ - sucess_num;
    ret.src = {0, 0, 0};
    ret.dst = {0, 0, 0};
    ret.src.resid = src_;
    ret.dst.resid = rp_dst->id;

    //发送事件
    if( (sucess_num>0) && ((rp_dst->id)%100>=7) )
    {
        pushinfo.new_push(push_stone,m_user.db.nickname(),m_user.db.grade,m_user.db.uid,m_user.db.viplevel,sucess_num,rp_dst->id);
        /*
           sc_msg_def::nt_event_gemstone_t event;
           event.type = 1;
           event.name = m_user.db.nickname();
           event.lv = m_user.db.grade;
           event.uid = m_user.db.uid;
           event.resid = rp_dst->id;
           event.count = sucess_num;
           notify_ctl.push_event(event);
           */
    }

    sp_item_t sp_src = get(ret.src.resid);
    if (sp_src != NULL)
        sp_src->get_item_jpk(ret.src);

    sp_item_t sp_dst = get(ret.dst.resid);
    if (sp_dst != NULL)
        sp_dst->get_item_jpk(ret.dst);

    logic.unicast(m_user.db.uid, ret);

    /*
       for(int i=0; i<sucess_num; i++)
       m_user.daily_task.on_event(evt_gemstone_compose);
       */

    return SUCCESS;
}
int32_t sc_item_mgr_t::gemstone_compose_all(int32_t compose_type)
{
    for(int i=1;i<=8;i++)
    {
        int gem_resid = compose_type*100 + i;
        sp_item_t sp_item = get(gem_resid);
        if( sp_item == NULL )
            continue;
        int count = sp_item->db.count / 3;
        gemstone_compose(gem_resid, count, 0);
    }
}
//图纸合成
int sc_item_mgr_t::drawing_compose(int resid_, const vector<int>& src_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    repo_def::item_t* rp_item = repo_mgr.item.get(resid_);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;
    if (rp_item->type != 5)
        return ERROR_SC_EXCEPTION;
    if (src_.size() != 3)
        return ERROR_SC_EXCEPTION;

    map<int,int> nums;
    for(int id : src_){
        if (id == resid_)
            return ERROR_SC_EXCEPTION;
        if (nums.find(id) == nums.end())
            nums[id] = 1;
        if (!has_items(id, nums[id]))
            return ERROR_SC_EXCEPTION;
        int off = resid_ - id;
        off = off < 0 ? -off:off;
        if (off > 8)
            return ERROR_SC_EXCEPTION;
        nums[id]++;
    }

    sc_msg_def::nt_bag_change_t nt;
    consume(src_[0], 1, nt);
    consume(src_[1], 1, nt);
    consume(src_[2], 1, nt);

    addnew(resid_, 1, nt);

    //刷新数据
    on_bag_change(nt);

    return SUCCESS;
}
int32_t sc_item_mgr_t::size()
{
    return m_item_hm.size();
}
int sc_item_mgr_t::open_pack_item(int resid_, int num_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    auto rp_pack = repo_mgr.pack.find(resid_);
    if (rp_pack == repo_mgr.pack.end())
        return -1;

    //通知消耗的道具
    sc_msg_def::nt_bag_change_t nt_consume;
    consume(resid_, num_, nt_consume);
    on_bag_change(nt_consume);

    sc_msg_def::ret_use_item_t ret;
    ret.code = SUCCESS;
    ret.resid = resid_;
    ret.num = num_;
    ret.value = 0;

    for(int i=0; i<num_; i++)
    {
        gen_pack_item(ret.items, rp_pack->second.item1, rp_pack->second.pro1, rp_pack->second.count1);
        gen_pack_item(ret.items, rp_pack->second.item2, rp_pack->second.pro2, rp_pack->second.count2);
        gen_pack_item(ret.items, rp_pack->second.item3, rp_pack->second.pro3, rp_pack->second.count3);
        gen_pack_item(ret.items, rp_pack->second.item4, rp_pack->second.pro4, rp_pack->second.count4);
        gen_pack_item(ret.items, rp_pack->second.item5, rp_pack->second.pro5, rp_pack->second.count5);
    }
    
    auto rp_item = repo_mgr.item.find(resid_);
    if (rp_item == repo_mgr.item.end())
        return ERROR_SC_EXCEPTION;
    auto rp_gmail = mailinfo.get_repo(mail_pack_mail);
    if (rp_gmail != NULL)
    {
        vector<sc_msg_def::jpk_item_t> items;

        for(size_t i=0; i<ret.items.size(); i++)
        {
            sc_msg_def::jpk_item_t itm;
            itm.resid=ret.items[i].resid;
            itm.num=ret.items[i].num;
            items.push_back(std::move(itm));
        }
        string msg = mailinfo.new_mail(mail_pack_mail, rp_item->second.name);
        m_user.gmail.send(rp_item->second.name, rp_gmail->sender, msg,rp_gmail->validtime, items); 
    }

    /*
    //通知新获得的道具
    sc_msg_def::nt_bag_change_t nt_new;
    for(size_t i=0; i<ret.items.size(); i++)
    {
        auto rp_item = repo_mgr.item.get(ret.items[i].resid);
        switch(rp_item->type)
        {
            case CHIP_TYPE:
                m_user.partner_mgr.add_new_chip(ret.items[i].resid, ret.items[i].num, nt_new.chips);
                break;
            default:
                addnew(ret.items[i].resid, ret.items[i].num, nt_new);
        }
    }
    on_bag_change(nt_new);

    m_user.save_db();

    logic.unicast(m_user.db.uid, ret);
    */
    return SUCCESS;
}
void sc_item_mgr_t::gen_pack_item(vector<sc_msg_def::jpk_item_t>& drops_, vector<int>& items_, int prob_, int count_)
{
    if (prob_ == 0)
        return;
    if (count_ == 0)
        return;

    //注意，所有的表格vector都是从1开始，故其会在实际长度上多加1
    int n = items_.size()-1;
    if (n <= 0)
        return;

    if (prob_ < 10000)
    {
        int32_t r = random_t::rand_integer(1, 10000);
        if (prob_ < r)
            return;
    }

    //只有一种道具
    if (n == 1)
    {
        //如果已经产生了这种道具，则直接加1
        auto it = std::find_if(drops_.begin(), drops_.end(), [&](sc_msg_def::jpk_item_t& item_){
                return (items_[1] == item_.resid);
                });

        if (it != drops_.end())
            (*it).num += count_;
        else
        {
            sc_msg_def::jpk_item_t item;
            item.itid = 0;
            item.resid = items_[1];
            item.num = count_;
            drops_.push_back(std::move(item));
        }
    }
    else
    {
        //有多种道具
        for(int i=0; i<count_; i++)
        {
            int32_t rr = random_t::rand_integer(1, n);

            //如果已经产生了这种道具，则直接加1
            auto it = std::find_if(drops_.begin(), drops_.end(), [&](sc_msg_def::jpk_item_t& item_){
                    return (items_[rr] == item_.resid);
                    });

            if (it != drops_.end())
                (*it).num++;
            else
            {
                sc_msg_def::jpk_item_t item;
                item.itid = 0;
                item.resid = items_[rr];
                item.num = 1;
                drops_.push_back(std::move(item));
            }
        }
    }
}
void sc_item_mgr_t::sell_item(int32_t resid_)
{
    sp_item_t sp_item = get(resid_);
    if (sp_item == NULL)
        return;

    sc_msg_def::nt_bag_change_t nt;
    nt.items.resize(1);
    nt.items[0].itid = sp_item->db.itid;
    nt.items[0].resid = resid_;
    nt.items[0].num = 0;
    logic.unicast(m_user.db.uid, nt);

    m_item_hm.erase(resid_);

    db_service.async_do((uint64_t)m_user.db.uid, [](db_Item_t& db_){
            db_.remove();
            }, sp_item->db.data());
}

int sc_item_mgr_t::use_item(int resid_, int num_, const string& param_)
{
    if (num_ <= 0)
        return ERROR_SC_ILLEGLE_REQ;

    repo_def::item_t* rp_item = repo_mgr.item.get(resid_);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;

    //如果是开宝箱，不判断剩余个数，如果不足，自动购买
    if(rp_item->type != 11 )
    {
        sp_item_t sp_item = get(resid_);
        if (sp_item == NULL)
            return ERROR_SC_ILLEGLE_REQ;

        if (sp_item->db.count < num_)
            return ERROR_SC_ILLEGLE_REQ;
    }

    switch(rp_item->type)
    {
        //礼包
        case 6:
            return open_pack_item(resid_, num_);
            break;
            //宝箱
        case 11:
            return open_box_item(resid_, num_);
            break;
            //药水
        case 12:
            return use_drug_item(resid_, num_, param_);
            break;
            //改名卡
        case 13:
            return rename(resid_, 1, param_);
            break;
    }

    return ERROR_SC_ILLEGLE_REQ;
}

int sc_item_mgr_t::open_box_item(int resid_, int num_)
{
    if (m_user.bag.is_full())
        return ERROR_BAG_FULL;

    /*
       sp_item_t sp_item = get(resid_);
       if (sp_item == NULL)
       {
       logerror((LOG, "open_box_item no itemid:%d!!!", resid_));
       return ERROR_SC_ILLEGLE_REQ;
       }
       */

    auto it = repo_mgr.box_map.find(resid_);
    if (it == repo_mgr.box_map.end())
    {
        logerror((LOG, "box_map no resid:%d!!!", resid_));
        return ERROR_SC_ILLEGLE_REQ;
    }

    //获取当前宝箱个数
    int32_t count = m_user.item_mgr.get_items_count(resid_);
    int32_t count_consume = num_;
    if( count < num_ )
    {
        //个数不足，自动购买
        auto it_shop = repo_mgr.shop.begin();
        while( it_shop!=repo_mgr.shop.end() && it_shop->second.item_id!=resid_ )
            ++it_shop;
        if ( it_shop == repo_mgr.shop.end() )
        {
            logerror((LOG, "shop no resid:%d!!!", resid_));
            return ERROR_SC_ILLEGLE_REQ;
        }
        //宝箱购买次数上限
        int off = num_-count;
        if (resid_ == GOLD_BOX && m_user.vip.get_num_count(vop_buy_golden_box)<off)
            return ERROR_SC_ILLEGLE_REQ; 
        else if (resid_  == SILV_BOX && m_user.vip.get_num_count(vop_buy_silver_box)<off)
            return ERROR_SC_ILLEGLE_REQ; 
        int32_t price = it_shop->second.price*(off);
        int32_t payyb,freeyb;
        if (m_user.rmb() >= price)
        {
            payyb = m_user.consume_yb( price );
            freeyb = price - payyb;
        }
        else 
            return ERROR_SC_NO_YB;

        m_user.save_db();
        statics_ins.unicast_buylog(m_user,it_shop->second.item_id,it_shop->second.name,num_-count,it_shop->second.money_type,price,payyb,freeyb,0);

        count_consume = count;


        if (resid_ == GOLD_BOX)
            m_user.vip.update_vip_recordn(vop_buy_golden_box, off);
        else if (resid_ == SILV_BOX)
            m_user.vip.update_vip_recordn(vop_buy_silver_box, off);
    }

    //消耗当前宝箱
    sc_msg_def::nt_bag_change_t nt_consume;
    consume(resid_, count_consume, nt_consume);
    on_bag_change(nt_consume);

    sc_msg_def::ret_use_item_t ret;
    ret.code = SUCCESS;
    ret.resid = resid_;
    ret.num = num_;
    ret.value = 0;

    int old_boxe = m_user.db.boxe;
    int old_boxn = m_user.db.boxn;

    sc_msg_def::nt_bag_change_t nt_new;
    for(int i=0; i<num_; i++)
    {
        //黄金宝箱
        if (resid_ == GOLD_BOX)
        {
            //只有黄金宝箱才会设置boxn
            m_user.db.set_boxn(m_user.db.boxn+1);
        }

        //如果是黄金宝箱,第三次开宝箱，如果没有出现紫装，则设置则把紫装出现范围设置在7次以内
        if (resid_ == GOLD_BOX && m_user.db.boxe==0 && m_user.db.boxn == 3)
            m_user.db.set_boxn(random_t::rand_integer(93, 100));


        int itemid=0;
        int num=0;

        //必出的紫装 
        if (resid_ == GOLD_BOX && m_user.db.boxn>=100)
        {
            int r = random_t::rand_integer(1,repo_mgr.box_equips.size());
            itemid =repo_mgr.box_equips[r-1];
            num = 1;
        }
        else
        {
            vector<repo_def::box_t>& rp_box = it->second;
            //产生掉落的装备
            int r = random_t::rand_integer(1, 100000);
            for(size_t i=0; i<rp_box.size(); i++)
            {
                if (r <= rp_box[i].pro1)
                {
                    itemid = rp_box[i].item1;
                    num = rp_box[i].num;
                    break;
                }
            }
        }

        repo_def::item_t* rp_item = repo_mgr.item.get(itemid);
        if (rp_item == NULL)
        {
            logerror((LOG, "open_box_item no itemid:%d, uid:%d!!!", itemid, m_user.db.uid));

            if (resid_ == GOLD_BOX)
            {
                //重置宝箱开启次数
                m_user.db.set_boxn(old_boxn);
                //重置紫装领取次数
                m_user.db.set_boxe(old_boxe);
                m_user.save_db();
            }

            return ERROR_SC_EXCEPTION;
        }

        //给予奖励
        switch(rp_item->type)
        {
            //装备
            case 2:
                {
                    m_user.equip_mgr.addnew(itemid, num, nt_new);
                    if (resid_ == GOLD_BOX && rp_item->type==2 && rp_item->quality >= 4)
                    {
                        //重置宝箱开启次数
                        m_user.db.set_boxn(0);
                        //设置宝箱紫装领取次数加1
                        m_user.db.set_boxe(m_user.db.boxe + 1);

                        //通知获得紫装
                        pushinfo.new_push(push_box_equip, m_user.db.nickname(), m_user.db.grade, m_user.db.uid, m_user.db.viplevel,itemid);
                    }
                    break;
                }
                //碎片
            case 14:
                {
                    m_user.partner_mgr.add_new_chip(itemid, num, nt_new.chips);
                }
                break;
            default:
                addnew(itemid, num, nt_new);
                break;
        }

        ret.items.push_back({0,itemid, num});
    }

    //保存用户
    m_user.save_db();

    //背包改变
    on_bag_change(nt_new);

    //通知用户使用道具结果
    logic.unicast(m_user.db.uid, ret);

    return SUCCESS;
}
int sc_item_mgr_t::use_drug_item(int resid_, int num_, const string& param_)
{
    sp_item_t sp_item = get(resid_);
    if (sp_item == NULL)
        return ERROR_BAG_NO_ITEM;

    repo_def::drug_t* rp_drug = repo_mgr.drug.get(resid_);
    if (rp_drug == NULL)
        return ERROR_NO_SUCH_DRUG;

    sp_partner_t partner;
    if (rp_drug->type == 2) // 加经验
    {
        partner = m_user.partner_mgr.get(std::atoi(param_.c_str()));
        if (partner == NULL)
            return ERROR_SC_NO_PARTNER;
    }
    sc_msg_def::ret_use_item_t ret;
    ret.code = SUCCESS;
    ret.resid = resid_;
    ret.num = num_;
    ret.value = 0;

    //刷新消耗血瓶/包子
    sc_msg_def::nt_bag_change_t nt;
    consume(resid_, num_, nt);
    on_bag_change(nt);

    switch(rp_drug->type)
    {
        //恢复体力
        case 1:
            ret.value = rp_drug->num * num_;
            m_user.on_power_change(ret.value);
            m_user.save_db();
            break;
        case 2:
            for (int32_t i = 1; i <= num_; i++)
            {
                m_user.daily_task.on_event(evt_practice);
            }
            ret.value = rp_drug->num * num_;
            partner->on_exp_change(ret.value);
            partner->save_db();
            break;
    }

    //通知用户使用道具结果
    logic.unicast(m_user.db.uid, ret);

    return SUCCESS;
}
int sc_item_mgr_t::rename(int resid_, int num_, const string& name_)
{
    sp_item_t sp_item = get(resid_);
    if (sp_item == NULL)
        return -1;

    uint64_t seskey=logic.session.get_seskey(m_user.db.uid);
    if (seskey == 0)
        return -1;

    uint32_t gwsid = ((uint32_t)REMOTE_GW<<16 | seskey>>48);
    sp_sc_gw_client_t client;
    if (!sc_service.get(gwsid, client))
        return -1;

    string newname = name_;
    ys_tool_t::filter_str(newname);
    if (newname.empty())
        return ERROR_SC_ILLEGLE_REQ;

    typedef boost::shared_ptr<rpc_connecter_t>          sp_rpc_conn_t;

    db_service.async_do((uint64_t)m_user.db.uid, [](uint64_t seskey_, sp_rpc_conn_t conn_, int resid_, uint32_t uid_, const string& name_){

            char sql[512];
            sprintf(sql, "select uid from UserInfo where nickname = '%s'", name_.c_str());

            sql_result_t res;
            db_service.async_select(sql, res);
            if( res.affect_row_num() >= 1)
            {
            sc_msg_def::ret_use_item_t ret;
            ret.code = ERROR_SC_NAME_EXISTENCE;
            ret.resid = resid_;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }

            db_service.async_execute("begin");
            sprintf(sql,"update UserInfo set nickname='%s' where uid=%d", name_.c_str(),uid_);
            if ( db_service.async_execute(sql)!=SUCCESS )
            {
            db_service.async_execute("rollback");

            sc_msg_def::ret_use_item_t ret;
            ret.code = ERROR_SC_NAME_EXISTENCE;
            ret.resid = resid_;
            msg_sender_t::unicast(seskey_, conn_, ret);
            return;
            }
    sprintf(sql, "update UserID set nickname = '%s' where uid=%d", name_.c_str(), uid_);
    if ( db_service.async_execute(sql)!=SUCCESS )
    {
        db_service.async_execute("rollback");

        sc_msg_def::ret_use_item_t ret;
        ret.code = ERROR_SC_NAME_EXISTENCE;
        ret.resid = resid_;
        msg_sender_t::unicast(seskey_, conn_, ret);
        return;
    }
    db_service.async_execute("commit");

    sc_service.async_do([](uint64_t seskey_, sp_rpc_conn_t conn_, int resid_, uint32_t uid_, const string& name_){
            sp_user_t user;
            if (logic.usermgr().get(uid_, user))
            {
            //刷新消耗一个改名卡
            sc_msg_def::nt_bag_change_t nt;
            user->item_mgr.consume(resid_, 1, nt);
            user->item_mgr.on_bag_change(nt);
            user->db.nickname = name_;        

            sc_msg_def::ret_use_item_t ret;
            ret.code = SUCCESS;
            ret.resid = resid_;
            msg_sender_t::unicast(seskey_, conn_, ret);

            activity.on_rename(user->db.uid, name_);
            user->friend_mgr.on_rename(user->db.uid, name_);

            sp_baseinfo_t frd = baseinfo_cache.get_baseinfo( user->db.uid );
            if( frd != NULL )
            {
                frd->nickname = name_;
            }

            sp_ganguser_t sp_guser;
            sp_gang_t sp_gang;
            if (gang_mgr.get_gang_by_uid(user->db.uid, sp_gang, sp_guser))
            {
                sp_guser->on_rename(name_);
            }
            }
    }, seskey_, conn_, resid_, uid_, name_); 
    }, seskey, client->get_conn(), resid_, m_user.db.uid, newname);

    return SUCCESS;
}
