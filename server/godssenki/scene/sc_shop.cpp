#include "sc_shop.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "sc_statics.h"

#include "code_def.h"
#include "repo_def.h"
#include "db_def.h"
#include "date_helper.h"
#include "random.h"
#include "stdlib.h"
#include "time.h"
#include "sc_chip_smash.h"

#define PRESTIGE_SHOP_MAX_PAGE_NUM (6)
#define CARDEVENT_SHOP_ITEM 16101

#define LOG "SC_SHOP"

sc_shopitem_t::sc_shopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_shopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
            db_service.async_execute(sql_);
    }, sql);
}
sc_shop_t::sc_shop_t(sc_user_t& user_): m_user(user_)
{
}

void sc_shop_t::load_db()
{
    sql_result_t res;
    if (0==db_Shop_t::sync_select_shop(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            boost::shared_ptr<sc_shopitem_t> sp_shopitem(new sc_shopitem_t(m_user));
            sp_shopitem->db.init(*res.get_row_at(i));
            m_shopitem_hm.insert(make_pair(sp_shopitem->db.resid, sp_shopitem));
        }
    }
}

int sc_shop_t::npc_buy(int id_, int& dbid_, int placeNum_, int type_)
{
    if (id_ <= 0 )
        return ERROR_SC_EXCEPTION;
    if (type_ == 1)
    {
        repo_def::npc_shop_t* npc_shop = repo_mgr.npc_shop.get(id_);
        if (npc_shop == NULL)
            return ERROR_NO_SHOPID;
        repo_def::item_t* npc_item = repo_mgr.item.get(npc_shop->item_id);
        if (npc_item == NULL)
            return ERROR_SC_EXCEPTION;
        if ((m_user.db.npcshopbuy >> placeNum_ & 1) == 1)
            return ERROR_BAG_FULL; 
        //判断背包是否能够放得下
        if( 2==npc_item->type )
        {
            //装备不能叠加
            if( (m_user.bag.get_size() - m_user.bag.get_current_size())<npc_shop->item_num)
                return ERROR_BAG_FULL;
        }
        else
        {
            //道具可以叠加，只要有一个空格就可以
            if (m_user.bag.is_full())
                return ERROR_BAG_FULL;
        }
        
        //扣除消耗点
        int price=0,payyb=0,freeyb=0,fpoint=0;
        price = npc_shop->price;
        if (npc_shop->money_type == 2)
        {
            if (m_user.rmb() >= price && price > 0)
            {
                payyb = m_user.consume_yb( price );
                freeyb = price - payyb;
            }else return ERROR_SC_NO_YB;
        }
        else
        {
            if(m_user.db.gold >= price )
                m_user.on_money_change(-price);
            else return ERROR_SC_NO_GOLD;
        }
        m_user.save_db();
        //判断是装备还是道具
        sc_msg_def::nt_bag_change_t nt;
        if( 16 == npc_shop->item_id/1000 )
        {
            //装备
            m_user.equip_mgr.addnew(npc_shop->item_id, npc_shop->item_num, nt);
            if (nt.add_equips.empty())
            {
                logerror((LOG, "buy add equips error!"));
                return ERROR_SC_EXCEPTION;
            }
            dbid_ = nt.add_equips[0].eid;
        }
        else if( npc_shop->item_id / 10000 == 3 )
        {
            //英雄碎片
            if (!m_user.partner_mgr.add_new_chip(npc_shop->item_id, npc_shop->item_num, nt.chips))
            {
                logerror((LOG, "buy add chips error!"));
                return ERROR_SC_EXCEPTION;
            }
            dbid_ = npc_shop->item_id;
        }
        else
        {
            //道具
            m_user.item_mgr.addnew(npc_shop->item_id, npc_shop->item_num, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));

                return ERROR_SC_EXCEPTION;
            }
            dbid_ = nt.items[0].itid;
        }
        m_user.item_mgr.on_bag_change(nt);
        //生成购买记录
        statics_ins.unicast_buylog(m_user,npc_shop->item_id,npc_shop->name,npc_shop->item_num,npc_shop->money_type,price,payyb,freeyb,fpoint);
        
        m_user.db.set_npcshopbuy( m_user.db.npcshopbuy | (1 << placeNum_)); 
        m_user.save_db();    
        return SUCCESS;
    }
    else
    {
        repo_def::special_shop_t* sp_shop = repo_mgr.special_shop.get(id_);
        if (sp_shop == NULL)
            return ERROR_NO_SHOPID;
        repo_def::item_t* sp_item = repo_mgr.item.get(sp_shop->item_id);
        if (sp_item == NULL)
            return ERROR_SC_EXCEPTION;
        if ((m_user.db.spshopbuy >> placeNum_ == 1) == 1)
            return ERROR_BAG_FULL; 
        //判断背包是否能够放得下
        if( 2== sp_item->type )
        {
            //装备不能叠加
            if( (m_user.bag.get_size() - m_user.bag.get_current_size()) < sp_shop->item_num)
                return ERROR_BAG_FULL;
        }
        else
        {
            //道具可以叠加，只要有一个空格就可以
            if (m_user.bag.is_full())
                return ERROR_BAG_FULL;
        }
    
        //扣除消耗点
        int price=0,payyb=0,freeyb=0,fpoint=0;
        price = sp_shop->price;
        if (sp_shop->money_type == 2)
        {
            if (m_user.rmb() >= price && price > 0)
            {
                payyb = m_user.consume_yb( price );
                freeyb = price - payyb;
            }else return ERROR_SC_NO_YB;
        }
        else
        {
            if(m_user.db.gold >= price )
                m_user.on_money_change(-price);
            else return ERROR_SC_NO_GOLD;
        }
        m_user.save_db();
        //判断是装备还是道具
        sc_msg_def::nt_bag_change_t nt;
        if( 16 == sp_shop->item_id/1000 )
        {
            //装备
            m_user.equip_mgr.addnew(sp_shop->item_id,sp_shop->item_num, nt);
            if (nt.add_equips.empty())
            {
                logerror((LOG, "buy add equips error!"));
                return ERROR_SC_EXCEPTION;
            }
            dbid_ = nt.add_equips[0].eid;
        }
        else if(sp_shop->item_id / 10000 == 3 )
        {
            //英雄碎片
            if (!m_user.partner_mgr.add_new_chip(sp_shop->item_id,sp_shop->item_num, nt.chips))
            {
                logerror((LOG, "buy add chips error!"));
                return ERROR_SC_EXCEPTION;
            }
            dbid_ =sp_shop->item_id;
        }
        else
        {
            //道具
            m_user.item_mgr.addnew(sp_shop->item_id,sp_shop->item_num, nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_EXCEPTION;
            }
            dbid_ = nt.items[0].itid;
        }
        m_user.item_mgr.on_bag_change(nt);

        //记录购买次数
        if(sp_shop->islimited > 0 )
        {
            auto it = m_shopitem_hm.find(sp_shop->item_id);
            if( it != m_shopitem_hm.end() )
            {
                db_Shop_ext_t &db = it->second->db;
                db.set_count(db.count+sp_shop->item_num);
                it->second->save_db();
            }
            else
            {
                boost::shared_ptr<sc_shopitem_t> sp_shopitem(new sc_shopitem_t(m_user));
                db_Shop_t &db = sp_shopitem->db;
                db.uid = m_user.db.uid;
                db.resid = sp_shop->item_id;
                db.count = sp_shop->item_num;
                m_shopitem_hm.insert(make_pair(sp_shopitem->db.resid, sp_shopitem));
                db_service.async_do((uint64_t)m_user.db.uid, [](db_Shop_t& db_){
                    db_.insert();
                }, db);
            }
        }

        //生成购买记录
        statics_ins.unicast_buylog(m_user,sp_shop->item_id,sp_shop->name,sp_shop->item_num,sp_shop->money_type,price,payyb,freeyb,fpoint);

        m_user.db.set_spshopbuy( m_user.db.spshopbuy | (1 << placeNum_)); 
        m_user.save_db();    
        return SUCCESS;   
    }    
}

uint32_t sc_shop_t::str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

int sc_shop_t::buy(int id_, int num_, int& dbid_)
{
    if (id_ <= 0 || num_ <= 0 || num_ >= 110)
        return ERROR_SC_EXCEPTION;

    repo_def::shop_t* rp_shop = repo_mgr.shop.get(id_);
    if (rp_shop == NULL)
        return ERROR_NO_SHOPID;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_shop->item_id);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;
    
    if(rp_shop->imt != 0 and (date_helper.cur_sec() > date_helper.day_0_stmp(m_user.db.createtime)+ 86400 * rp_shop->time))
        return ERROR_SC_EXCEPTION;
    //购买次数是否足够
    if( rp_shop->islimited > 0 )
    {
        int32_t current;
        auto it = m_shopitem_hm.find(rp_shop->item_id);
        if( it == m_shopitem_hm.end() )
            current = 0;
        else
            current = it->second->db.count;
        if( (current + num_) > rp_shop->islimited )
            return ERROR_SHOP_LIMIT_OUT;
    }
    if( 15 == rp_shop->item_id/1000 && m_user.db.createtime + 86400 * (rp_shop->time) < date_helper.cur_sec())
        return ERROR_SC_EXCEPTION;

    //扣除消耗点
    int price=0,payyb=0,freeyb=0,fpoint=0;
    price = rp_shop->price*num_;
    //if (m_user.db.viplevel >= 6)
    //    price = rp_shop->discount * num_;
    if (m_user.rmb() >= price && price > 0)
    {
        payyb = m_user.consume_yb( price );
        freeyb = price - payyb;
    }else return ERROR_SC_NO_YB;
    m_user.save_db();
    //判断是装备还是道具
    sc_msg_def::nt_bag_change_t nt;

    if( 16 == rp_shop->item_id/1000 )
    {
        //装备
        m_user.equip_mgr.addnew(rp_shop->item_id, num_, nt);
        if (nt.add_equips.empty())
        {
            logerror((LOG, "buy add equips error!"));
            return ERROR_SC_EXCEPTION;
        }
        dbid_ = nt.add_equips[0].eid;
    }
    else if( 15 == rp_shop->item_id/1000 )
    {
        if(m_user.db.createtime + 86400 * (rp_shop->time) > date_helper.cur_sec())
            m_user.item_mgr.open_pack_item(rp_shop->item_id, 1);
    }
    else if( rp_shop->item_id / 10000 == 3 )
    {
        //英雄碎片
        if (!m_user.partner_mgr.add_new_chip(rp_shop->item_id, num_, nt.chips))
        {
            logerror((LOG, "buy add chips error!"));
            return ERROR_SC_EXCEPTION;
        }
        dbid_ = rp_shop->item_id;
    }
    else
    {
        //道具
        m_user.item_mgr.addnew(rp_shop->item_id, num_, nt);
        bool is_empty = true;
        if (!nt.items.empty())
        {
            dbid_ = nt.items[0].itid;
            is_empty = false;
        }
        else if (!nt.add_wings.empty())
        {
            dbid_ = 0;
            is_empty = false;
        }
        else if (!nt.add_pet.empty())
        {
            dbid_ = 0;
            is_empty = false;
        }
        if (is_empty)
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    m_user.item_mgr.on_bag_change(nt);

    //记录购买次数
    if( rp_shop->islimited > 0 )
    {
        auto it = m_shopitem_hm.find(rp_shop->item_id);
        if( it != m_shopitem_hm.end() )
        {
            db_Shop_ext_t &db = it->second->db;
            db.set_count(db.count+num_);
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_shopitem_t> sp_shopitem(new sc_shopitem_t(m_user));
            db_Shop_t &db = sp_shopitem->db;
            db.uid = m_user.db.uid;
            db.resid = rp_shop->item_id;
            db.count = num_;
            m_shopitem_hm.insert(make_pair(sp_shopitem->db.resid, sp_shopitem));

            db_service.async_do((uint64_t)m_user.db.uid, [](db_Shop_t& db_){
                db_.insert();
            }, db);
        }
    }

    //生成购买记录
    statics_ins.unicast_buylog(m_user,rp_shop->item_id,rp_shop->name,num_,rp_shop->money_type,price,payyb,freeyb,fpoint);

    return SUCCESS;
}
void sc_shop_t::buy_coin(sc_msg_def::ret_buy_coin_t& ret)
{
    repo_def::levelup_t* rp_lvup = repo_mgr.levelup.get(m_user.db.grade); 
    if (rp_lvup == NULL)
    {
        ret.code = ERROR_SC_EXCEPTION;
        return ;
    }

    int coin = rp_lvup->alchemy_money;
    int32_t code = m_user.vip.buy_vip(vop_do_buy_money);
    if (code == SUCCESS)
    {
        repo_def::alchemy_money_t* rp_am = repo_mgr.alchemy_money.get(m_user.db.viplevel);
        int32_t times = 1;
        if (rp_am != NULL)
        {
            int32_t size = rp_am->probability.size();
            int32_t rpro = random_t::rand_integer(1, 10000);
            int32_t totalprobability = 0;
            for (int32_t i = 1; i < size; ++i)
            {
                bool flag = (i == 1 && 0 < rpro && rpro <= rp_am->probability[i]) || (rp_am->probability[i-1] < rpro && rpro <= rp_am->probability[i] + totalprobability);
                if (flag)
                {
                    times = rp_am->times[i];
                    break;
                }
                totalprobability = totalprobability + rp_am->probability[i];
            }
        }
        ret.times = times;
        m_user.on_money_change(coin * times);
        m_user.save_db();

        //日常任务
        //更新购买金币的日常任务
        m_user.daily_task.on_event(evt_buy_money);
    }

    ret.code = code;
}
int sc_shop_t::sell(int eid_, int resid_)
{
    int num = 1;
    int price = 0;

    repo_def::item_t* rp_item = repo_mgr.item.get(resid_);
    if (rp_item == NULL)
    {
        logerror((LOG, "repo item no resid:%d", resid_));
        return ERROR_SC_EXCEPTION;
    }
    price = rp_item->price;

    if (eid_ > 0)
    {
        sp_equip_t sp_eq = m_user.equip_mgr.get(eid_);
        if (sp_eq == NULL)
            return ERROR_SELL_NO_EQUIP;
        if (sp_eq->db.isweared)
            return ERROR_SELL_EQUIPED;
        if (sp_eq->db.strenlevel>0){
            price += 0;
        }
        m_user.equip_mgr.sell_equip(eid_);

        //记录事件
        statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),resid_,1,0,-1);

    }
    else
    {
        sp_item_t sp_item = m_user.item_mgr.get(resid_);
        if (sp_item == NULL)
            return ERROR_SELL_NO_ITEM;
        num = sp_item->db.count;
        m_user.item_mgr.sell_item(resid_);

        //记录事件
        statics_ins.unicast_eventlog(m_user,sc_msg_def::nt_bag_change_t::cmd(),resid_,num,0,-1);

    }

    int add_gold = 0;

    //生成消耗记录
    statics_ins.unicast_consumelog(m_user,resid_,2,num,0);

    add_gold = price * num;
    m_user.on_money_change(add_gold);
    m_user.save_db();

    return SUCCESS;
}
int sc_shop_t::unicast_shop_items(int tab_, int page_, int sheet_)
{
    sc_msg_def::ret_shop_items_t ret;
    if (tab_ == 2)
    { 
        int numBegin = (page_-1)*6;
        for (int i = 0;i<= 5;i++)
        {
            int numGem = numBegin + i;
            int id = repo_mgr.shop_item[numGem];
            repo_def::shop_t* rp_shop = repo_mgr.shop.get(id);
            if (rp_shop == NULL)
                break;
            if (rp_shop->hide)
                 continue;
            sc_msg_def::shop_item_t item; 
            item.tab = tab_;
            item.page = page_;
            item.id = rp_shop->id;
            item.item_id = rp_shop->item_id;
            item.money_type = rp_shop->money_type;
            item.price = rp_shop->price;
            item.ishot = rp_shop->ishot;
            item.sheet = i;
            item.isnew = rp_shop->isnew;
            item.imt = rp_shop->imt;
            item.time = rp_shop->time;
            if( rp_shop->islimited > 0 )
            {
                //获取玩家已经购买的次数
                auto it = m_shopitem_hm.find( item.item_id );
                if( it == m_shopitem_hm.end() )
                    item.islimit = rp_shop->islimited;
                else
                {
                    item.islimit = rp_shop->islimited - it->second->db.count;
                    if( item.islimit <= 0 )
                        item.islimit = -1;
                }
            }
            if(item.imt == 1)
            {
                if(m_user.db.createtime + 86400 * (item.time) > date_helper.cur_sec())
                    ret.lmtitems.push_back(std::move(item));
            }
            else
                ret.items.push_back(std::move(item));                     
 
        }
        logic.unicast(m_user.db.uid, ret); 
        return SUCCESS;


    }
    else
    {
        for(size_t i = 0; i < repo_mgr.shop_item.size(); i++)
        {
            repo_def::shop_t* rp_shop = repo_mgr.shop.get(repo_mgr.shop_item[i]);
            if (rp_shop == NULL)
                break;
            if (rp_shop->hide)
                continue;
            sc_msg_def::shop_item_t item;
            item.id = rp_shop->id;
            item.item_id = rp_shop->item_id;
            item.money_type = rp_shop->money_type;
            item.price = rp_shop->price;
            item.ishot = rp_shop->ishot;
            item.isnew = rp_shop->isnew;
            item.discount = rp_shop->discount;
            item.imt = rp_shop->imt;
            item.time = rp_shop->time;
            if( rp_shop->islimited > 0 )
            {
                //获取玩家已经购买的次数
                auto it = m_shopitem_hm.find( item.item_id );
                if( it == m_shopitem_hm.end() )
                    item.islimit = rp_shop->islimited;
                else
                {
                    item.islimit = rp_shop->islimited - it->second->db.count;
                    if( item.islimit <= 0 )
                        item.islimit = -1;
                }
            }
            else
                item.islimit = 0;
            if(item.imt == 1)
            {
                if(m_user.db.createtime + 86400 * (item.time) > date_helper.cur_sec())
                    ret.lmtitems.push_back(std::move(item));
            }
            else
                ret.items.push_back(std::move(item));                     
        }
        logic.unicast(m_user.db.uid, ret);
    
        return SUCCESS;
    }
}
int sc_shop_t::unicast_npc_shop_items(int type_)
{
    if(type_ == 1)
    {
        sc_msg_def::ret_npcshop_items_t ret;
        int shopId = m_user.db.npcshop;
        db_NpcShop_t dbNpcShop;
        sql_result_t res;
        int itemGoods[6] = {1, 2, 3, 4, 5, 6};
        if (0 == dbNpcShop.sync_select_npcshop(shopId, res))
        {
            dbMsg.init(*res.get_row_at(0));
            itemGoods[0] = dbMsg.item1,itemGoods[1] = dbMsg.item2,itemGoods[2] = dbMsg.item3;
            itemGoods[3] = dbMsg.item4,itemGoods[4] = dbMsg.item5,itemGoods[5] = dbMsg.item6;
        }
        for(int i=0; i<=5; i++)
        {
            int id = itemGoods[i];
            if (id > repo_mgr.npc_shop.size())
                id = random_t::rand_integer(1, repo_mgr.npc_shop.size());
            repo_def::npc_shop_t* npc_shop = repo_mgr.npc_shop.get(id);
            if (npc_shop == NULL)
                break;
            sc_msg_def::npcshop_item_t item;
            item.id = npc_shop->id;
            item.item_id = npc_shop->item_id;
            item.money_type = npc_shop->money_type;
            item.buytype = (m_user.db.npcshopbuy >> i)& 1;
            item.price = npc_shop->price;
            item.item_num = npc_shop->item_num;
            //暂时存刷新钻石
            item.probability = m_user.db.npcshoprefresh;
            item.islimit = i;
            ret.items.push_back(std::move(item));
        }
        logic.unicast(m_user.db.uid, ret);
        return SUCCESS;
    }
    else
    {
        sc_msg_def::ret_npcshop_items_t ret1;
        sc_msg_def::ret_npcshop_items_t ret2;
        int shopId = m_user.db.specicalshop;
        db_SpShop_t dbSpShop;
        sql_result_t res;
        int itemGoods[12] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
        if (0 == dbSpShop.sync_select_spshop(shopId, res))
        {
            dbSp.init(*res.get_row_at(0));
            itemGoods[0] = dbSp.item1,itemGoods[1] = dbSp.item2,itemGoods[2] = dbSp.item3;
            itemGoods[3] = dbSp.item4,itemGoods[4] = dbSp.item5,itemGoods[5] = dbSp.item6;
            itemGoods[6] = dbSp.item7,itemGoods[7] = dbSp.item8,itemGoods[8] = dbSp.item9;
            itemGoods[9] = dbSp.item10,itemGoods[10] = dbSp.item11,itemGoods[11] = dbSp.item12;
        }
        for(int i=0; i<=11; i++)
        {
            int id = itemGoods[i];
            if (id > repo_mgr.special_shop.size())
                id = random_t::rand_integer(1, repo_mgr.special_shop.size());
            repo_def::special_shop_t* npc_shop = repo_mgr.special_shop.get(id);
            if (npc_shop == NULL)
                break;
            sc_msg_def::npcshop_item_t item;
            item.id = npc_shop->id;
            item.item_id = npc_shop->item_id;
            item.money_type = npc_shop->money_type;
            item.buytype = (m_user.db.spshopbuy >> i)& 1;
            item.price = npc_shop->price;
            item.item_num = npc_shop->item_num;
            //暂时存刷新钻石
            item.probability = m_user.db.spshoprefresh;
            item.islimit = i;
            if (i <= 5)
            {
                ret1.items.push_back(std::move(item));
            }
            else
            {
                ret2.items.push_back(std::move(item));
            }
        }
        logic.unicast(m_user.db.uid, ret1);
        logic.unicast(m_user.db.uid, ret2);
        return SUCCESS;
    }
}
int sc_shop_t::buy_power()
{
    repo_def::vip_t* vip_info = repo_mgr.vip.get(m_user.db.viplevel);
    if (m_user.db.power >= vip_info->power_limit)
        return ERROR_POWER_MAX;
    else
    {
        int32_t code = m_user.vip.buy_vip(vop_buy_power);
        if (code == SUCCESS)
        {
            if (m_user.db.power + 60 > vip_info->power_limit)
                m_user.on_power_change(vip_info->power_limit - m_user.db.power);
            else
                m_user.on_power_change(60);
            m_user.save_db();
        }
        
        return code;
    }
}
int sc_shop_t::buy_energy()
{
    int32_t code = m_user.vip.buy_vip(vop_buy_trial_energy);
    if (code == SUCCESS)
    {
        m_user.on_energy_change(1);
        m_user.save_db();
    }

    return code;
}
int sc_shop_t::buy_bag_cap()
{
    repo_def::backpack_t* rp_bb = repo_mgr.backpack.get(m_user.db.bagn+1);
    if (rp_bb == NULL)
    {
        logerror((LOG, "repo backpack no bagn:%d", m_user.db.bagn+1));
        return ERROR_SC_EXCEPTION;
    }

    int bagn = m_user.db.bagn + 1;

    int32_t code = m_user.vip.buy_vip(vop_buy_bag_num, bagn);
    if (code != SUCCESS)
        return code;
    m_user.db.set_bagn(bagn);
    m_user.save_db();
    return SUCCESS;
}
int sc_shop_t::buy_item(int resid_, int num_)
{
    repo_def::shop_t* rp_item = repo_mgr.shop.get(resid_);
    if (rp_item == NULL || num_ <= 0)
        return ERROR_SC_EXCEPTION;

    if (rp_item->price <= 0)
        return ERROR_SC_EXCEPTION;
    int price = rp_item->price * num_;
/*    if (m_user.db.viplevel >= 5)
    {
        price = rp_item->discount * num_;
    }
*/
    int payyb,freeyb;
    payyb=freeyb=0;
    if (m_user.rmb() >= price && price > 0)
    {
        payyb = m_user.consume_yb( price );
        freeyb = price - payyb;
    }else return ERROR_SC_NO_YB;

    sc_msg_def::nt_bag_change_t nt;
    if( 16 == resid_/1000 )
    {
        //装备
        m_user.equip_mgr.addnew(resid_, num_, nt);
    }
    else if( resid_ / 10000 == 3 )
    {
        //英雄碎片
        m_user.partner_mgr.add_new_chip(resid_, num_, nt.chips);
    }
    else
    {
        //道具
        m_user.item_mgr.addnew(resid_, num_, nt);
    }

    m_user.item_mgr.on_bag_change(nt);

    m_user.save_db();

    //生成购买记录
    statics_ins.unicast_buylog(m_user,resid_,rp_item->name,num_,1,price,payyb,freeyb,0);

    return SUCCESS;
}

//npc商店商品更新
int sc_shop_t::npc_shop_update(int type_)
{
    if (type_ == 1)
    {    
        int price = m_user.db.npcshoprefresh;
        if (m_user.rmb() < price)
            return ERROR_SC_NO_YB;
        if (m_user.db.npcshoprefresh < 50)
            m_user.db.set_npcshoprefresh(price + 5);
        m_user.consume_yb(price);
        m_user.db.set_npcshop(random_t::rand_integer(1, 50));
        m_user.db.set_npcshopbuy(0);
        return SUCCESS;  
    }
    else if (type_ == 2)
    {
        int price = m_user.db.spshoprefresh;
        if (m_user.rmb() < price)
            return ERROR_SC_NO_YB;
        if (m_user.db.spshoprefresh < 50)
            m_user.db.set_spshoprefresh(price + 5);
        m_user.consume_yb(price);
        m_user.db.set_specicalshop(random_t::rand_integer(1, 25));
        m_user.db.set_spshopbuy(0);
        return SUCCESS;   
    }
    return ERROR_SC_NO_YB;
}
//npc商店商品更新
int sc_shop_t::npc_shop_update_free(int type_)
{
    if (type_ == 1)
    {    
        m_user.db.set_npcshop(random_t::rand_integer(1, 50));
        m_user.db.set_npcshopbuy(0);
        return SUCCESS;  
    }
    else if (type_ == 2)
    {
        m_user.db.set_specicalshop(random_t::rand_integer(1, 25));
        m_user.db.set_spshopbuy(0);
        return SUCCESS;   
    }
    return ERROR_SC_NO_YB;
}

void sc_shop_t::update()
{
    uint32_t sec = date_helper.secoffday();
    uint32_t cur_0_stmp = date_helper.cur_0_stmp();
    uint32_t now_stmp = date_helper.cur_sec();
    uint32_t time_8 = 8* 3600;
    uint32_t time_14 = 14* 3600;
    uint32_t time_20 = 20* 3600; 
    if( sec >= time_8 && sec <= time_14)
    {
        if(m_user.db.npcshoptime1 < cur_0_stmp + time_8)
        {
            npc_shop_update_free(1);
            m_user.db.set_npcshoptime1(now_stmp);
            m_user.db.set_npcshopbuy(0);

            //刷新特殊npc商店
            npc_shop_update_free(2);
            m_user.db.set_spshopbuy(0);

        }
    }
    else if( sec >= time_14 && sec <= time_20)
    {
        if(m_user.db.npcshoptime2 < cur_0_stmp + time_14)
        {
            npc_shop_update_free(1);
            m_user.db.set_npcshoptime2(now_stmp);
            m_user.db.set_npcshopbuy(0);

            //刷新特殊npc商店
            npc_shop_update_free(2);
            m_user.db.set_spshopbuy(0);

        }
    }
    else if( sec >= time_20)
    {
        if(m_user.db.npcshoptime3 < cur_0_stmp + time_20)
        {
            npc_shop_update_free(1);
            m_user.db.set_npcshoptime3(now_stmp);
            m_user.db.set_npcshopbuy(0);

            //刷新特殊npc商店
            npc_shop_update_free(2);
            m_user.db.set_spshopbuy(0);
        }
    }
    else if ( m_user.db.npcshoptime1 <= cur_0_stmp && m_user.db.npcshoptime2 <= cur_0_stmp && m_user.db.npcshoptime3 <= cur_0_stmp - 4 * 3600)
    {
        npc_shop_update_free(1);
        m_user.db.set_npcshoptime1(now_stmp);
        m_user.db.set_npcshoptime2(now_stmp);
        m_user.db.set_npcshoptime3(now_stmp);
        m_user.db.set_npcshopbuy(0);
        
        //刷新特殊npc商店
        npc_shop_update_free(2);
        m_user.db.set_spshopbuy(0);
    }
    if ( m_user.db.spshoptime < cur_0_stmp )
    {
        m_user.db.set_spshoptime(now_stmp);
        m_user.db.set_npcshoprefresh(20);
        m_user.db.set_spshoprefresh(20);
    }
}

//npc商店随机商品更新
void sc_npcshop_t::update()
{
    if (npctime == 0)
        npctime = date_helper.cur_sec(); 
    if(npctime < date_helper.cur_0_stmp() && date_helper.secoffday() >= 20*3600)
    {   

        logwarn((LOG, "update shop begin..."));
        int npcshop[300];
        int spshop[300];
        int npcsize = repo_mgr.npc_shop.size();
        int spsize  = repo_mgr.special_shop.size();
        
        int npcTop = 0,spTop = 0;
        for (int32_t i = 1; repo_mgr.npc_shop.get(i) != NULL; i++)
        {
            repo_def::npc_shop_t* npcShop = repo_mgr.npc_shop.get(i);
            for(int32_t index = 1; index <= npcShop->probability; index++)
            {
                npcshop[npcTop] = i;
                npcTop++;
            }
        }
        for (int32_t i = 1;repo_mgr.special_shop.get(i) != NULL; i++)
        {
            repo_def::special_shop_t* spShop = repo_mgr.special_shop.get(i);
            for(int32_t index = 1; index <= spShop->probability; index++)
            {
                spshop[spTop] = i;
                spTop++;
            }
        }

        for(int32_t shopPlanIndex = 0; shopPlanIndex < 300; shopPlanIndex++)
        {
            int npcrandomNum = random_t::rand_integer(shopPlanIndex, npcTop - 1);
            int sprandomNum = random_t::rand_integer(shopPlanIndex,spTop - 1);
            int exchangeNum = 0;

            exchangeNum = npcshop[shopPlanIndex];
            npcshop[shopPlanIndex] = npcshop[npcrandomNum];
            npcshop[npcrandomNum] = exchangeNum;

            exchangeNum = spshop[shopPlanIndex];
            spshop[shopPlanIndex] = spshop[sprandomNum];
            spshop[sprandomNum] = exchangeNum;
        }

        for(int index = 1;index <= 50;index++)
        {
            sql_result_t res;
            dbNpc.uid = index; 
            int numBer[6];
            for (int num =0; num <= 5; num++)
            {
                numBer[num] = npcshop[(index-1)*6 + num];
            }
            dbNpc.item1 = numBer[0],dbNpc.item2 = numBer[1],dbNpc.item3 = numBer[2];
            dbNpc.item4 = numBer[3], dbNpc.item5 = numBer[4], dbNpc.item6 = numBer[5];

            sql_result_t res1;
            char sql1[128];
            sprintf(sql1, "select uid from NpcShop where uid=%d;", dbNpc.uid);
            db_service.sync_select(sql1, res1);
            if (0 == res1.affect_row_num())    //没有找到
            {    
                db_service.async_do((uint64_t)dbNpc.uid, [](db_NpcShop_t& db_){
                db_.insert();
                }, dbNpc);
            }
            else
            {

                db_service.async_do((uint64_t)dbNpc.uid, [](db_NpcShop_t& db_){
                db_.update();
                }, dbNpc);
            }
        }

        for(int index = 1;index <= 25;index++)
        {
            sql_result_t res;
            dbShop.uid = index; 
            int numBer[12];
            for (int num = 0; num <= 11; num++)
            {
               numBer[num] = spshop[(index - 1)* 12 + num]; 
            }
            dbShop.item1 = numBer[0],dbShop.item2 = numBer[1],dbShop.item3 = numBer[2];
            dbShop.item4 = numBer[3],dbShop.item5 = numBer[4],dbShop.item6 = numBer[5];
            dbShop.item7 = numBer[6],dbShop.item8 = numBer[7],dbShop.item9 = numBer[8];
            dbShop.item10 = numBer[9],dbShop.item11 = numBer[10],dbShop.item12 = numBer[11];
            sql_result_t res2;
            char sql2[128];
            sprintf(sql2, "select uid from SpShop where uid=%d;", dbNpc.uid);
            db_service.sync_select(sql2, res2);
            if (0 == res2.affect_row_num())    //没有找到
            {
                db_service.async_do((uint64_t)dbShop.uid, [](db_SpShop_t& db_){
                db_.insert();
                }, dbShop);
            }
            else
            {
                db_service.async_do((uint64_t)dbShop.uid, [](db_SpShop_t& db_){
                db_.update();
                }, dbShop);
            }
        }
        npctime = date_helper.cur_sec() + date_helper.cur_0_stmp();
        logwarn((LOG, "update shop end..."));
    }
}

//======================================================
sc_expeditionshopitem_t::sc_expeditionshopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_expeditionshopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}
sc_expeditionshop_mgr_t::sc_expeditionshop_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_expeditionshop_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_ExpeditionShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_expeditionshopitem_t> sp_expeditionitem(new sc_expeditionshopitem_t(m_user));
            sp_expeditionitem->db.init(*res.get_row_at(i));
            if (sp_expeditionitem->db.refresh_time > buystamp)
            {
                buystamp = sp_expeditionitem->db.refresh_time;
            }
            m_eshopitem_hm.insert(make_pair(sp_expeditionitem->db.eshopindex, sp_expeditionitem));
        }
    }
}

// chipitem_hm_t m_chipitem_hm;
int sc_expeditionshop_mgr_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.expedition_shop.size(); ++i)
        {
            repo_def::expedition_shop_t* rp_eshop_ = repo_mgr.expedition_shop.get(i+1);
            if(rp_eshop_ == NULL)
                break;
            auto it = m_eshopitem_hm.find(rp_eshop_->id);
            if(it != m_eshopitem_hm.end())
            {
                db_ExpeditionShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }
    sc_msg_def::ret_expedition_shop_items_t ret;
    for (size_t i = 0; i < repo_mgr.expedition_shop.size(); ++i)
    {
        repo_def::expedition_shop_t* rp_eshop_ = repo_mgr.expedition_shop.get(i+1);
        if (rp_eshop_ == NULL)
            break;

        sc_msg_def::jpk_expedition_shop_item_t item;
        item.id = rp_eshop_->id;
        item.item_id = rp_eshop_->item_id;
        item.count = rp_eshop_->item_num;
        item.name = rp_eshop_->name;
        item.price = rp_eshop_->price;
        item.limited = rp_eshop_->islimited;
        int current;
        auto it = m_eshopitem_hm.find(rp_eshop_->id);
        if (it == m_eshopitem_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_expeditionshop_mgr_t::buy(int32_t id_, int32_t num_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::expedition_shop_t* rp_pshop_ = repo_mgr.expedition_shop.get(id_);
    if (rp_pshop_ == NULL)
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;

    if (rp_pshop_->islimited > 0)
    {
        int32_t current;
        auto it = m_eshopitem_hm.find(rp_pshop_->id);
        if (it == m_eshopitem_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_pshop_->islimited)
            return ERROR_SC_NOT_ENOUGH_EXPEDITION_SHOP;
    }
    //扣道具
    if (rp_pshop_->money_type != 3)
        return ERROR_SC_EXCEPTION;
    if (m_user.db.expeditioncoin < rp_pshop_->price)
        return ERROR_SC_NO_EXPEDITION_COIN;


    m_user.consume_expeditioncoin(rp_pshop_->price);
    m_user.save_db();

    sc_msg_def::nt_bag_change_t nt;
    if (rp_pshop_->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_pshop_->item_id, rp_pshop_->item_num, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_pshop_->item_id == 10001)
    {
        m_user.on_money_change(rp_pshop_->item_num);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_pshop_->item_id, rp_pshop_->item_num, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_pshop_->islimited > 0)
    {
        auto it = m_eshopitem_hm.find(rp_pshop_->id);
        if (it != m_eshopitem_hm.end())
        {
            db_ExpeditionShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_refresh_time(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_expeditionshopitem_t> sp_expeditionitem(new sc_expeditionshopitem_t(m_user));
            db_ExpeditionShop_t& db = sp_expeditionitem->db;
            db.uid = m_user.db.uid;
            db.eshopindex = rp_pshop_->id;
            db.count = num_;
            db.refresh_time = date_helper.cur_sec();
            m_eshopitem_hm.insert(make_pair(sp_expeditionitem->db.eshopindex, sp_expeditionitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_ExpeditionShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_pshop_->item_id,rp_pshop_->name,rp_pshop_->item_num,-1,rp_pshop_->price,0,0,0);
    return SUCCESS;
}
//======================================================


sc_prestigeitem_t::sc_prestigeitem_t(sc_user_t& user_):m_user(user_)
{
}

void sc_prestigeitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_unprestigeitem_t::sc_unprestigeitem_t(sc_user_t& user_):m_user(user_)
{
}

void sc_unprestigeitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}


sc_prestige_shop_t::sc_prestige_shop_t(sc_user_t& user_):m_user(user_)
{
}

void sc_prestige_shop_t::load_db()
{
    sql_result_t res;
    if (0 == db_PrestigeShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_prestigeitem_t> sp_prestigeitem(new sc_prestigeitem_t(m_user));
            sp_prestigeitem->db.init(*res.get_row_at(i));
            if (sp_prestigeitem->db.buystamp > buystamp)
            {
                buystamp = sp_prestigeitem->db.buystamp;
            }
            m_prestigeitem_hm.insert(make_pair(sp_prestigeitem->db.resid, sp_prestigeitem));
        }
    }

    sql_result_t res1;
    if (0 == db_UnPrestigeShop_t::sync_select_all(m_user.db.uid, res1))
    {
        for (size_t i = 0; i < res1.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_unprestigeitem_t> sp_unprestigeitem(new sc_unprestigeitem_t(m_user));
            sp_unprestigeitem->db.init(*res1.get_row_at(i));
            if (sp_unprestigeitem->db.buystamp > unbuystamp)
            {
                unbuystamp = sp_unprestigeitem->db.buystamp;
            }
            m_unprestigeitem_hm.insert(make_pair(sp_unprestigeitem->db.resid, sp_unprestigeitem));
        }
    }

}

// prestigeitem_hm_t m_prestigeitem_hm;
int sc_prestige_shop_t::unicast_shop_items(int shopindex_)
{
    if (shopindex_ == 1)
    {
        if (buystamp < date_helper.cur_0_stmp())
        {
            for(size_t i = 0; i < repo_mgr.prestige_shop.size(); ++i)
            {
                repo_def::prestige_shop_t* rp_pshop_ = repo_mgr.prestige_shop.get(i+1);
                if(rp_pshop_ == NULL)
                    break;
                auto it = m_prestigeitem_hm.find(rp_pshop_->id);
                if(it != m_prestigeitem_hm.end())
                {
                    db_PrestigeShop_ext_t &db = it->second->db;
                    db.set_count(0);
                    it->second->save_db();
                }
            }
        
        }
    }
    else if (shopindex_ == 2)
    {
        if (unbuystamp < date_helper.cur_0_stmp())
        {
            for(size_t i = 0; i < repo_mgr.unprestige_shop.size(); ++i)
            {
                repo_def::unprestige_shop_t* rp_pshop_ = repo_mgr.unprestige_shop.get(i+1);
                if(rp_pshop_ == NULL)
                    break;
                auto it = m_unprestigeitem_hm.find(rp_pshop_->id);
                if(it != m_unprestigeitem_hm.end())
                {
                    db_UnPrestigeShop_ext_t &db = it->second->db;
                    db.set_count(0);
                    it->second->save_db();
                }
            }
        
        }
    }

    sc_msg_def::ret_prestige_shop_items_t ret;
    ret.index = shopindex_;
    if(shopindex_ == 1)
    {
        for (size_t i = 0; i < repo_mgr.prestige_shop.size(); ++i)
        {
            repo_def::prestige_shop_t* rp_pshop_ = repo_mgr.prestige_shop.get(i+1);
            if (rp_pshop_ == NULL)
                break;
            if (rp_pshop_->hide)
                continue;

            sc_msg_def::prestige_item_t item;
            item.id = rp_pshop_->id;
            item.item_id = rp_pshop_->item[1];
            item.count = rp_pshop_->item[2];
            item.name = rp_pshop_->name;
            item.price = rp_pshop_->price;
            item.isnew = rp_pshop_->isnew == 1 ? true : false;
            item.limited = rp_pshop_->islimited;
            int current;
            auto it = m_prestigeitem_hm.find(rp_pshop_->id);
            if (it == m_prestigeitem_hm.end())
                current = 0;
            else 
            {
                current = it->second->db.count;
            }
            item.buy_num = current;
            ret.items.push_back(std::move(item));
        }
    }
    else if (shopindex_ == 2)
    {
        for (size_t i = 0; i < repo_mgr.unprestige_shop.size(); ++i)
        {
            repo_def::unprestige_shop_t* rp_pshop_ = repo_mgr.unprestige_shop.get(i+1);
            if (rp_pshop_ == NULL)
                break;
            if (rp_pshop_->hide)
                continue;
            sc_msg_def::prestige_item_t item;
            item.id = rp_pshop_->id;
            item.item_id = rp_pshop_->item[1];
            item.count = rp_pshop_->item[2];
            item.name = rp_pshop_->name;
            item.price = rp_pshop_->price;
            item.isnew = rp_pshop_->isnew == 1 ? true : false;
            item.limited = rp_pshop_->islimited;
            int current;
            auto it = m_unprestigeitem_hm.find(rp_pshop_->id);
            if (it == m_unprestigeitem_hm.end())
                current = 0;
            else 
            {
                current = it->second->db.count;
            }
            item.buy_num = current;
            ret.items.push_back(std::move(item));
        }
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}
int sc_prestige_shop_t::buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_,int32_t shopindex_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    if(shopindex_ == 1)
    {
        repo_def::prestige_shop_t* rp_pshop_ = repo_mgr.prestige_shop.get(id_);
        if (rp_pshop_ == NULL)
            return ERROR_NO_SHOPID;
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item[1]);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;
        if (2 == rp_item->type)
        {
            if((m_user.bag.get_size() - m_user.bag.get_current_size()) < rp_pshop_->item[2])
                return ERROR_BAG_FULL;
        }
        else if (m_user.bag.is_full())
            return ERROR_BAG_FULL;
        if (rp_pshop_->islimited > 0)
        {
            int32_t current;
            auto it = m_prestigeitem_hm.find(rp_pshop_->id);
            if (it == m_prestigeitem_hm.end())
                current = 0;
            else current = it->second->db.count;
            if ((current + num_) > rp_pshop_->islimited)
                return ERROR_SHOP_LIMIT_OUT;
        }
        int32_t price = rp_pshop_->price * num_;
        if (m_user.honor() < price && price > 0)
            return ERROR_SC_NO_HONOR;
        m_user.consume_honor(price);
        m_user.save_db();
        resid_ = rp_pshop_->item[1];
        count_ = rp_pshop_->item[2];

        sc_msg_def::nt_bag_change_t nt;
        if (rp_pshop_->item[1] / 10000 == 3)
        {
            m_user.partner_mgr.add_new_chip(rp_pshop_->item[1], rp_pshop_->item[2], nt.chips);
            m_user.item_mgr.on_bag_change(nt);
        }
        else if (rp_pshop_->item[1] == 10001)
        {
            m_user.on_money_change(rp_pshop_->item[2]);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(rp_pshop_->item[1], rp_pshop_->item[2], nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_EXCEPTION;
            }
        }
        if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

        if (rp_pshop_->islimited > 0)
        {
            auto it = m_prestigeitem_hm.find(rp_pshop_->id);
            if (it != m_prestigeitem_hm.end())
            {
                db_PrestigeShop_ext_t &db = it->second->db;
                db.set_count(db.count + num_);
                db.set_buystamp(date_helper.cur_sec());
                buystamp = date_helper.cur_sec();
                it->second->save_db();
            }
            else
            {
                boost::shared_ptr<sc_prestigeitem_t> sp_prestigeitem(new sc_prestigeitem_t(m_user));
                db_PrestigeShop_t& db = sp_prestigeitem->db;
                db.uid = m_user.db.uid;
                db.resid = rp_pshop_->id;
                db.count = num_;
                db.buystamp = date_helper.cur_sec();
                m_prestigeitem_hm.insert(make_pair(sp_prestigeitem->db.resid, sp_prestigeitem));
                db_service.async_do((uint64_t)m_user.db.uid, [](db_PrestigeShop_t& db_){
                    db_.insert();
                }, db);
            }
        }
        statics_ins.unicast_buylog(m_user,rp_pshop_->item[1],rp_pshop_->name,rp_pshop_->item[2],-1,price,0,0,0);
    }
    else if (shopindex_ == 2)
    {
        repo_def::unprestige_shop_t* rp_pshop_ = repo_mgr.unprestige_shop.get(id_);
        if (rp_pshop_ == NULL)
            return ERROR_NO_SHOPID;
        repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item[1]);
        if (rp_item == NULL)
            return ERROR_SC_EXCEPTION;
        if (2 == rp_item->type)
        {
            if((m_user.bag.get_size() - m_user.bag.get_current_size()) < rp_pshop_->item[2])
                return ERROR_BAG_FULL;
        }
        else if (m_user.bag.is_full())
            return ERROR_BAG_FULL;

        if (rp_pshop_->islimited > 0)
        {
            int32_t current;
            auto it = m_unprestigeitem_hm.find(rp_pshop_->id);
            if (it == m_unprestigeitem_hm.end())
                current = 0;
            else current = it->second->db.count;
            if ((current + num_) > rp_pshop_->islimited)
                return ERROR_SHOP_LIMIT_OUT;
        }
        int32_t price = rp_pshop_->price * num_;
        if (m_user.unhonor() < price && price > 0)
            return ERROR_SC_NO_HONOR;
        m_user.consume_unhonor(price);
        m_user.save_db();
        resid_ = rp_pshop_->item[1];
        count_ = rp_pshop_->item[2];

        sc_msg_def::nt_bag_change_t nt;
        if (rp_pshop_->item[1] / 10000 == 3)
        {
            m_user.partner_mgr.add_new_chip(rp_pshop_->item[1], rp_pshop_->item[2], nt.chips);
            m_user.item_mgr.on_bag_change(nt);
        }
        else if (rp_pshop_->item[1] == 10001)
        {
            m_user.on_money_change(rp_pshop_->item[2]);
            m_user.save_db();
        }
        else
        {
            m_user.item_mgr.addnew(rp_pshop_->item[1], rp_pshop_->item[2], nt);
            if (nt.items.empty())
            {
                logerror((LOG, "buy add items error!"));
                return ERROR_SC_EXCEPTION;
            }
        }
        if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

        if (rp_pshop_->islimited > 0)
        {
            auto it = m_unprestigeitem_hm.find(rp_pshop_->id);
            if (it != m_unprestigeitem_hm.end())
            {
                db_UnPrestigeShop_ext_t &db = it->second->db;
                db.set_count(db.count + num_);
                db.set_buystamp(date_helper.cur_sec());
                unbuystamp = date_helper.cur_sec();
                it->second->save_db();
            }
            else
            {
                boost::shared_ptr<sc_unprestigeitem_t> sp_unprestigeitem(new sc_unprestigeitem_t(m_user));
                db_UnPrestigeShop_t& db = sp_unprestigeitem->db;
                db.uid = m_user.db.uid;
                db.resid = rp_pshop_->id;
                db.count = num_;
                db.buystamp = date_helper.cur_sec();
                m_unprestigeitem_hm.insert(make_pair(sp_unprestigeitem->db.resid, sp_unprestigeitem));
                db_service.async_do((uint64_t)m_user.db.uid, [](db_UnPrestigeShop_t& db_){
                    db_.insert();
                }, db);
            }
        }
    }
    return SUCCESS;
}

//==================碎片商店
sc_chipitem_t::sc_chipitem_t(sc_user_t& user_):m_user(user_)
{
}

void sc_chipitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_chip_shop_t::sc_chip_shop_t(sc_user_t& user_):m_user(user_)
{
}

void sc_chip_shop_t::load_db()
{
    sql_result_t res;
    if (0 == db_ChipShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_chipitem_t> sp_chipitem(new sc_chipitem_t(m_user));
            sp_chipitem->db.init(*res.get_row_at(i));
            if (sp_chipitem->db.buystamp > buystamp)
            {
                buystamp = sp_chipitem->db.buystamp;
            }
            m_chipitem_hm.insert(make_pair(sp_chipitem->db.resid, sp_chipitem));
        }
    }
}

// chipitem_hm_t m_chipitem_hm;
int sc_chip_shop_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.chip_shop.size(); ++i)
        {
            repo_def::chip_shop_t* rp_pshop_ = repo_mgr.chip_shop.get(i+1);
            if(rp_pshop_ == NULL)
                break;
            auto it = m_chipitem_hm.find(rp_pshop_->id);
            if(it != m_chipitem_hm.end())
            {
                db_ChipShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }
    sc_msg_def::ret_chip_shop_items_t ret;
    ret.page = 1;
    for (size_t i = 0; i < repo_mgr.chip_shop.size(); ++i)
    {
        repo_def::chip_shop_t* rp_pshop_ = repo_mgr.chip_shop.get(i+1);
        if (rp_pshop_ == NULL)
            break;
        if (rp_pshop_->hide)
            continue;

        sc_msg_def::chip_item_t item;
        item.id = rp_pshop_->id;
        item.item_id = rp_pshop_->item;
        item.count = 1;
        repo_def::chip_smash_t* rp_psmash_ = repo_mgr.chip_smash.get(rp_pshop_->item);
        if (rp_psmash_ == NULL)
            continue;
        item.name = rp_pshop_->name;
        item.price = chip_value.get_chipvalue(rp_pshop_->item,item.trend, 2);
        item.isnew = rp_pshop_->ishot == 1 ? true : false;
        item.limited = rp_pshop_->islimited;
        int current;
        auto it = m_chipitem_hm.find(rp_pshop_->id);
        if (it == m_chipitem_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_chip_shop_t::buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::chip_shop_t* rp_pshop_ = repo_mgr.chip_shop.get(id_);
    if (rp_pshop_ == NULL)
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;

    if (rp_pshop_->islimited > 0)
    {
        int32_t current;
        auto it = m_chipitem_hm.find(rp_pshop_->id);
        if (it == m_chipitem_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_pshop_->islimited)
            return ERROR_SHOP_LIMIT_OUT;
    }
    int32_t trend;
    int32_t price = chip_value.get_chipvalue(rp_pshop_->item, trend, 2) * num_;
    if (m_user.item_mgr.get_items_count(16005) < price && price > 0)
        return ERROR_SHOP_LIMIT_OUT;
    //扣道具
    sc_msg_def::nt_bag_change_t zt;
    m_user.item_mgr.consume(16005, price, zt);
    m_user.item_mgr.on_bag_change(zt);
    m_user.save_db();
    resid_ = rp_pshop_->item;
    count_ = num_;

    sc_msg_def::nt_bag_change_t nt;
    if (rp_pshop_->item / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_pshop_->item, count_, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_pshop_->item == 10001)
    {
        m_user.on_money_change(count_);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_pshop_->item, count_, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_pshop_->islimited > 0)
    {
        auto it = m_chipitem_hm.find(rp_pshop_->id);
        if (it != m_chipitem_hm.end())
        {
            db_ChipShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_buystamp(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_chipitem_t> sp_chipitem(new sc_chipitem_t(m_user));
            db_ChipShop_t& db = sp_chipitem->db;
            db.uid = m_user.db.uid;
            db.resid = rp_pshop_->id;
            db.count = num_;
            db.buystamp = date_helper.cur_sec();
            m_chipitem_hm.insert(make_pair(sp_chipitem->db.resid, sp_chipitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_ChipShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    chip_value.update_chipvalue(resid_, count_);
    statics_ins.unicast_buylog(m_user,rp_pshop_->item,rp_pshop_->name,count_,-1,price,0,0,0);
    return SUCCESS;
}

//==================种子商店
sc_plantshop_item_t::sc_plantshop_item_t(sc_user_t& user_):m_user(user_)
{
}

void sc_plantshop_item_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_plant_shop_t::sc_plant_shop_t(sc_user_t& user_):m_user(user_)
{
}

void sc_plant_shop_t::load_db()
{
    sql_result_t res;
    if (0 == db_PlantShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_plantshop_item_t> sp_plantitem(new sc_plantshop_item_t(m_user));
            sp_plantitem->db.init(*res.get_row_at(i));
            if (sp_plantitem->db.buystamp > buystamp)
            {
                buystamp = sp_plantitem->db.buystamp;
            }
            m_plantshop_hm.insert(make_pair(sp_plantitem->db.plantid, sp_plantitem));
        }
    }
}

int sc_plant_shop_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.residence_plantshop.size(); ++i)
        {
            repo_def::residence_plantshop_t* rp_pshop_ = repo_mgr.residence_plantshop.get(i+1);
            if(rp_pshop_ == NULL)
                break;
            auto it = m_plantshop_hm.find(rp_pshop_->id);
            if(it != m_plantshop_hm.end())
            {
                db_PlantShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }
    sc_msg_def::ret_plant_shop_items_t ret;
    ret.page = 1;
    for (size_t i = 0; i < repo_mgr.residence_plantshop.size(); ++i)
    {
        repo_def::residence_plantshop_t* rp_pshop_ = repo_mgr.residence_plantshop.get(i+1);
        if (rp_pshop_ == NULL)
            break;
        if (rp_pshop_->hide)
            continue;

        sc_msg_def::plant_item_t item;
        item.id = rp_pshop_->id;
        item.item_id = rp_pshop_->item_id;
        item.count = 1;
        item.name = rp_pshop_->name;
        item.price = rp_pshop_->price;
        item.isnew = rp_pshop_->ishot == 1 ? true : false;
        item.limited = rp_pshop_->islimited;
        int current;
        auto it = m_plantshop_hm.find(rp_pshop_->id);
        if (it == m_plantshop_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_plant_shop_t::buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::residence_plantshop_t* rp_pshop_ = repo_mgr.residence_plantshop.get(id_);
    if (rp_pshop_ == NULL)
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;

    if (rp_pshop_->islimited > 0)
    {
        int32_t current;
        auto it = m_plantshop_hm.find(rp_pshop_->id);
        if (it == m_plantshop_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_pshop_->islimited)
            return ERROR_SHOP_LIMIT_OUT;
    }
    int32_t price = rp_pshop_->price * num_;
    if (rp_pshop_->money_type == 2)
    {
        if (m_user.rmb() >= price && price > 0)
        {
            m_user.consume_yb( price );
        }else return ERROR_SC_NO_YB;
    }
    else
    {
        if(m_user.db.gold >= price && price > 0)
            m_user.on_money_change(-price);
        else return ERROR_SC_NO_GOLD;
    }
    m_user.save_db();
    resid_ = rp_pshop_->item_id;
    count_ = num_;

    sc_msg_def::nt_bag_change_t nt;
    if (rp_pshop_->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_pshop_->item_id, count_, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_pshop_->item_id == 10001)
    {
        m_user.on_money_change(count_);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_pshop_->item_id, count_, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_pshop_->islimited > 0)
    {
        auto it = m_plantshop_hm.find(rp_pshop_->id);
        if (it != m_plantshop_hm.end())
        {
            db_PlantShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_buystamp(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_plantshop_item_t> sp_plantitem(new sc_plantshop_item_t(m_user));
            db_PlantShop_t& db = sp_plantitem->db;
            db.uid = m_user.db.uid;
            db.plantid = rp_pshop_->id;
            db.count = num_;
            db.buystamp = date_helper.cur_sec();
            m_plantshop_hm.insert(make_pair(sp_plantitem->db.plantid, sp_plantitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_PlantShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_pshop_->item_id,rp_pshop_->name,count_,-1,price,0,0,0);
    return SUCCESS;
}

//==================库存商店
sc_inventoryshop_item_t::sc_inventoryshop_item_t(sc_user_t& user_):m_user(user_)
{
}

void sc_inventoryshop_item_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

sc_inventoryshop_t::sc_inventoryshop_t(sc_user_t& user_):m_user(user_)
{
}

void sc_inventoryshop_t::load_db()
{
    sql_result_t res;
    if (0 == db_InventoryShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_inventoryshop_item_t> sp_inventoryshopitem(new sc_inventoryshop_item_t(m_user));
            sp_inventoryshopitem->db.init(*res.get_row_at(i));
            if (sp_inventoryshopitem->db.buystamp > buystamp)
            {
                buystamp = sp_inventoryshopitem->db.buystamp;
            }
            m_inventoryshop_hm.insert(make_pair(sp_inventoryshopitem->db.shopid, sp_inventoryshopitem));
        }
    }
}

int sc_inventoryshop_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.inventory_shop.size(); ++i)
        {
            repo_def::inventory_shop_t* rp_pshop_ = repo_mgr.inventory_shop.get(i+1);
            if(rp_pshop_ == NULL)
                break;
            auto it = m_inventoryshop_hm.find(rp_pshop_->id);
            if(it != m_inventoryshop_hm.end())
            {
                db_InventoryShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }

    sc_msg_def::ret_inventory_shop_items_t ret;
    ret.page = 1;
    for (size_t i = 0; i < repo_mgr.inventory_shop.size(); ++i)
    {
        repo_def::inventory_shop_t* rp_pshop_ = repo_mgr.inventory_shop.get(i+1);
        if (rp_pshop_ == NULL)
            break;
        if (rp_pshop_->hide)
            continue;

        sc_msg_def::inventory_item_t item;
        item.id = rp_pshop_->id;
        item.item_id = rp_pshop_->item_id;
        item.count = 1;
        item.name = rp_pshop_->name;
        item.price = rp_pshop_->price;
        item.isnew = rp_pshop_->ishot == 1 ? true : false;
        item.limited = rp_pshop_->islimited;
        int current;
        auto it = m_inventoryshop_hm.find(rp_pshop_->id);
        if (it == m_inventoryshop_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_inventoryshop_t::buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_EXCEPTION;
    repo_def::inventory_shop_t* rp_pshop_ = repo_mgr.inventory_shop.get(id_);
    if (rp_pshop_ == NULL)
        return ERROR_SC_EXCEPTION;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_pshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_EXCEPTION;
    //等级是否满足条件
    if (rp_pshop_->islimited > 0)
    {
        return ERROR_SHOP_LIMIT_OUT;
    }

    int32_t price = rp_pshop_->price * num_;

    //扣道具
    sc_msg_def::nt_bag_change_t zt;
    m_user.item_mgr.consume(rp_pshop_->money_type, price, zt);
    m_user.item_mgr.on_bag_change(zt);
    m_user.save_db();

    resid_ = rp_pshop_->item_id;
    count_ = num_;

    sc_msg_def::nt_bag_change_t nt;
    if (rp_pshop_->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_pshop_->item_id, count_, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_pshop_->item_id == 10001)
    {
        m_user.on_money_change(count_);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_pshop_->item_id, count_, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);
/*
    if (rp_pshop_->islimited > 0)
    {
        auto it = m_inventoryshop_hm.find(rp_pshop_->id);
        if (it != m_inventoryshop_hm.end())
        {
            db_InventoryShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_buystamp(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_inventoryshop_item_t> sp_inventoryshopitem(new sc_inventoryshop_item_t(m_user));
            db_InventoryShop_t& db = sp_inventoryshopitem->db;
            db.uid = m_user.db.uid;
            db.shopid = rp_pshop_->id;
            db.count = num_;
            db.buystamp = date_helper.cur_sec();
            m_inventoryshop_hm.insert(make_pair(sp_inventoryshopitem->db.shopid, sp_inventoryshopitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_InventoryShop_t& db_){
                db_.insert();
            }, db);
        }
    }
*/
    statics_ins.unicast_buylog(m_user,rp_pshop_->item_id,rp_pshop_->name,count_,-1,price,0,0,0);
    return SUCCESS;
}


//=======社团商店
sc_gang_shopitem_t::sc_gang_shopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_gang_shopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}
sc_gang_shop_mgr_t::sc_gang_shop_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_gang_shop_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_GangShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_gang_shopitem_t> sp_gangitem(new sc_gang_shopitem_t(m_user));
            sp_gangitem->db.init(*res.get_row_at(i));
            if (sp_gangitem->db.refresh_time > buystamp)
            {
                buystamp = sp_gangitem->db.refresh_time;
            }
            m_gangitem_hm.insert(make_pair(sp_gangitem->db.gshopindex, sp_gangitem));
        }
    }
}

// gangitem_hm_t m_gangitem_hm;
int sc_gang_shop_mgr_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.gang_shop.size(); ++i)
        {
            repo_def::gang_shop_t* rp_gshop_ = repo_mgr.gang_shop.get(i+1);
            if(rp_gshop_ == NULL)
                break;
            auto it = m_gangitem_hm.find(rp_gshop_->id);
            if(it != m_gangitem_hm.end())
            {
                db_GangShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }
    sc_msg_def::ret_gang_shop_items_t ret;
    for (size_t i = 0; i < repo_mgr.gang_shop.size(); ++i)
    {
        repo_def::gang_shop_t* rp_gshop_ = repo_mgr.gang_shop.get(i+1);
        if (rp_gshop_ == NULL)
            break;

        sc_msg_def::jpk_gang_shop_item_t item;
        item.id = rp_gshop_->id;
        item.item_id = rp_gshop_->item_id;
        item.count = rp_gshop_->item_num;
        item.name = rp_gshop_->name;
        item.price = rp_gshop_->price;
        item.limited = rp_gshop_->islimited;
        int current;
        auto it = m_gangitem_hm.find(rp_gshop_->id);
        if (it == m_gangitem_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_gang_shop_mgr_t::buy(int32_t id_, int32_t num_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_GANGSHOP_INFO;
    repo_def::gang_shop_t* rp_gshop_ = repo_mgr.gang_shop.get(id_);
    if (rp_gshop_ == NULL)
        return ERROR_SC_GANGSHOP_INFO;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_gshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_GANG_ITEM;

    if (rp_gshop_->islimited > 0)
    {
        int32_t current;
        auto it = m_gangitem_hm.find(rp_gshop_->id);
        if (it == m_gangitem_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_gshop_->islimited)
            return ERROR_SC_NOT_ENOUGH_GANG_SHOP;
    }
    
    int32_t price = rp_gshop_->price * num_;
    if (m_user.item_mgr.get_items_count(16006) < price && price > 0)
        return ERROR_GANG_SHOP_LIMIT_OUT;
    
    //扣道具
    sc_msg_def::nt_bag_change_t zt;
    m_user.item_mgr.consume(16006, price, zt);
    m_user.item_mgr.on_bag_change(zt);
    m_user.save_db();


    sc_msg_def::nt_bag_change_t nt;
    if (rp_gshop_->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_gshop_->item_id, rp_gshop_->item_num, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_gshop_->item_id == 10001)
    {
        m_user.on_money_change(rp_gshop_->item_num);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_gshop_->item_id, rp_gshop_->item_num, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_gshop_->islimited > 0)
    {
        auto it = m_gangitem_hm.find(rp_gshop_->id);
        if (it != m_gangitem_hm.end())
        {
            db_GangShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_refresh_time(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_gang_shopitem_t> sp_gangitem(new sc_gang_shopitem_t(m_user));
            db_GangShop_t& db = sp_gangitem->db;
            db.uid = m_user.db.uid;
            db.gshopindex = rp_gshop_->id;
            db.count = num_;
            db.refresh_time = date_helper.cur_sec();
            m_gangitem_hm.insert(make_pair(sp_gangitem->db.gshopindex, sp_gangitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_GangShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_gshop_->item_id,rp_gshop_->name,rp_gshop_->item_num,-1,rp_gshop_->price,0,0,0);
    return SUCCESS;
}

//=======符文商店
sc_rune_shopitem_t::sc_rune_shopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_rune_shopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}
sc_rune_shop_mgr_t::sc_rune_shop_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_rune_shop_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_RuneShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_rune_shopitem_t> sp_runeitem(new sc_rune_shopitem_t(m_user));
            sp_runeitem->db.init(*res.get_row_at(i));
            if (sp_runeitem->db.refresh_time > buystamp)
            {
                buystamp = sp_runeitem->db.refresh_time;
            }
            m_runeitem_hm.insert(make_pair(sp_runeitem->db.rshopindex, sp_runeitem));
        }
    }
}

// runeitem_hm_t m_runeitem_hm;
int sc_rune_shop_mgr_t::unicast_shop_items()
{
    if (buystamp < date_helper.cur_0_stmp())
    {
        for(size_t i = 0; i < repo_mgr.rune_shop.size(); ++i)
        {
            repo_def::rune_shop_t* rp_gshop_ = repo_mgr.rune_shop.get(i+1);
            if(rp_gshop_ == NULL)
                break;
            auto it = m_runeitem_hm.find(rp_gshop_->id);
            if(it != m_runeitem_hm.end())
            {
                db_RuneShop_ext_t &db = it->second->db;
                db.set_count(0);
                it->second->save_db();
            }
        }
        
    }
    sc_msg_def::ret_rune_shop_items_t ret;
    for (size_t i = 0; i < repo_mgr.rune_shop.size(); ++i)
    {
        repo_def::rune_shop_t* rp_gshop_ = repo_mgr.rune_shop.get(i+1);
        if (rp_gshop_ == NULL)
            break;

        sc_msg_def::jpk_rune_shop_item_t item;
        item.id = rp_gshop_->id;
        item.item_id = rp_gshop_->item_id;
        item.count = rp_gshop_->item_num;
        item.name = rp_gshop_->name;
        item.price = rp_gshop_->price;
        item.limited = rp_gshop_->islimited;
        int current;
        auto it = m_runeitem_hm.find(rp_gshop_->id);
        if (it == m_runeitem_hm.end())
            current = 0;
        else 
        {
                current = it->second->db.count;
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_rune_shop_mgr_t::buy(int32_t id_, int32_t num_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_RUNESHOP_INFO;
    repo_def::rune_shop_t* rp_gshop_ = repo_mgr.rune_shop.get(id_);
    if (rp_gshop_ == NULL)
        return ERROR_SC_RUNESHOP_INFO;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_gshop_->item_id);
    if (rp_item == NULL)
        return ERROR_SC_RUNE_ITEM;

    if (rp_gshop_->islimited > 0)
    {
        int32_t current;
        auto it = m_runeitem_hm.find(rp_gshop_->id);
        if (it == m_runeitem_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_gshop_->islimited)
            return ERROR_SC_NOT_ENOUGH_RUNE_SHOP;
    }
    
    int32_t price = rp_gshop_->price * num_;
    if (m_user.item_mgr.get_items_count(18001) < price && price > 0)
        return ERROR_RUNE_SHOP_LIMIT_OUT;
    
    //扣道具
    sc_msg_def::nt_bag_change_t zt;
    m_user.item_mgr.consume(18001, price, zt);
    m_user.item_mgr.on_bag_change(zt);
    m_user.save_db();


    sc_msg_def::nt_bag_change_t nt;
    if (rp_gshop_->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_gshop_->item_id, rp_gshop_->item_num, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_gshop_->item_id == 10001)
    {
        m_user.on_money_change(rp_gshop_->item_num);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_gshop_->item_id, rp_gshop_->item_num, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_SC_EXCEPTION;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_gshop_->islimited > 0)
    {
        auto it = m_runeitem_hm.find(rp_gshop_->id);
        if (it != m_runeitem_hm.end())
        {
            db_RuneShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_refresh_time(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_rune_shopitem_t> sp_runeitem(new sc_rune_shopitem_t(m_user));
            db_RuneShop_t& db = sp_runeitem->db;
            db.uid = m_user.db.uid;
            db.rshopindex = rp_gshop_->id;
            db.count = num_;
            db.refresh_time = date_helper.cur_sec();
            m_runeitem_hm.insert(make_pair(sp_runeitem->db.rshopindex, sp_runeitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_RuneShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_gshop_->item_id,rp_gshop_->name,rp_gshop_->item_num,-1,rp_gshop_->price,0,0,0);
    return SUCCESS;
}


//=======活动商店
sc_cardevent_shopitem_t::sc_cardevent_shopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_cardevent_shopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}

sc_cardevent_shop_mgr_t::sc_cardevent_shop_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_cardevent_shop_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_CardEventShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_cardevent_shopitem_t> sp_cardeventitem(new sc_cardevent_shopitem_t(m_user));
            sp_cardeventitem->db.init(*res.get_row_at(i));
            m_cardevent_hm.insert(make_pair(sp_cardeventitem->db.shopindex, sp_cardeventitem));
        }
    }
}

// cardevent_hm_t m_cardevent_hm;
int sc_cardevent_shop_mgr_t::unicast_shop_items()
{
    sc_msg_def::ret_cardevent_shop_items_t ret;
    uint32_t beginStamp = 0, endStamp = 0;
    card_event_s.getBeginResetStamp( beginStamp, endStamp);
    if(date_helper.cur_sec() < beginStamp || date_helper.cur_sec() > endStamp)
    {
        ret.code = ERROR_NO_OPEN_SHOP;
        logic.unicast(m_user.db.uid, ret);
        return ERROR_NO_OPEN_SHOP; 
    }

    for (size_t i = 0; i < repo_mgr.cardevent_shop.size(); ++i)
    {
        repo_def::cardevent_shop_t* rp_shop = repo_mgr.cardevent_shop.get(i+1);
        if (rp_shop == NULL)
            break;
        sc_msg_def::jpk_cardevent_shop_item_t item;
        item.id = rp_shop->id;
        item.item_id = rp_shop->item_id;
        item.count = rp_shop->item_num;
        item.name = rp_shop->name;
        item.price = rp_shop->price;
        item.limited = rp_shop->islimited;
        int current;
        auto it = m_cardevent_hm.find(rp_shop->id);
        if (it == m_cardevent_hm.end())
        {
            current = 0;
        }
        else 
        {
                if (it->second->db.refresh_time < beginStamp || it->second->db.refresh_time > endStamp)
                {
                    db_CardEventShop_ext_t &db = it->second->db;
                    db.set_count(0);
                    db.set_refresh_time(date_helper.cur_sec());
                    it->second->save_db();
                    current = 0;
                }
                else
                {
                    current = it->second->db.count;
                }
        }
        item.buy_num = current;
        ret.code = SUCCESS;
        ret.items.push_back(std::move(item));
    }
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

int sc_cardevent_shop_mgr_t::buy(int32_t id_, int32_t num_)
{
    uint32_t beginStamp = 0, endStamp = 0;
    card_event_s.getBeginResetStamp( beginStamp, endStamp);
    if(date_helper.cur_sec() < beginStamp || date_helper.cur_sec() > endStamp)
    {
        return ERROR_CARDEVENT_SHOP; 
    }

    if (id_ <= 0 || num_ <= 0)
        return ERROR_SC_RUNESHOP_INFO;
    repo_def::cardevent_shop_t* rp_shop = repo_mgr.cardevent_shop.get(id_);
    if (rp_shop == NULL)
        return ERROR_CARDEVENT_SHOP;
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_shop->item_id);
    if (rp_item == NULL)
        return ERROR_CARDEVENT_SHOP;

    if (rp_shop->islimited > 0)
    {
        int32_t current;
        auto it = m_cardevent_hm.find(rp_shop->id);
        if (it == m_cardevent_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_shop->islimited)
            return ERROR_CARDEVENT_SHOP;
    }
    
    int32_t price = rp_shop->price * num_;
    if (m_user.item_mgr.get_items_count(CARDEVENT_SHOP_ITEM) < price && price > 0)
        return ERROR_CARDEVENT_SHOP;
    
    //扣道具
    sc_msg_def::nt_bag_change_t zt;
    m_user.item_mgr.consume(CARDEVENT_SHOP_ITEM, price, zt);
    m_user.item_mgr.on_bag_change(zt);
    m_user.save_db();


    sc_msg_def::nt_bag_change_t nt;
    if (rp_shop->item_id / 10000 == 3)
    {
        m_user.partner_mgr.add_new_chip(rp_shop->item_id, rp_shop->item_num, nt.chips);
        m_user.item_mgr.on_bag_change(nt);
    }
    else if (rp_shop->item_id == 10001)
    {
        m_user.on_money_change(rp_shop->item_num);
        m_user.save_db();
    }
    else
    {
        m_user.item_mgr.addnew(rp_shop->item_id, rp_shop->item_num, nt);
        if (nt.items.empty())
        {
            logerror((LOG, "buy add items error!"));
            return ERROR_CARDEVENT_SHOP;
        }
    }
    if (!nt.items.empty()) m_user.item_mgr.on_bag_change(nt);

    if (rp_shop->islimited > 0)
    {
        auto it = m_cardevent_hm.find(rp_shop->id);
        if (it != m_cardevent_hm.end())
        {
            db_CardEventShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_refresh_time(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_cardevent_shopitem_t> sp_cardeventitem(new sc_cardevent_shopitem_t(m_user));
            db_CardEventShop_t& db = sp_cardeventitem->db;
            db.uid = m_user.db.uid;
            db.shopindex = rp_shop->id;
            db.count = num_;
            db.refresh_time = date_helper.cur_sec();
            m_cardevent_hm.insert(make_pair(sp_cardeventitem->db.shopindex, sp_cardeventitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_CardEventShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_shop->item_id,rp_shop->name,rp_shop->item_num,-1,rp_shop->price,0,0,0);
    return SUCCESS;
}

//=======限时商店
sc_lmt_shopitem_t::sc_lmt_shopitem_t(sc_user_t& user_):m_user(user_)
{
}
void sc_lmt_shopitem_t::save_db()
{
    string sql = db.get_up_sql();
    if (sql.empty()) return;
    db_service.async_do((uint64_t)db.uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql);
}

sc_lmt_shop_mgr_t::sc_lmt_shop_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_lmt_shop_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_LmtShop_t::sync_select_all(m_user.db.uid, res))
    {
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            boost::shared_ptr<sc_lmt_shopitem_t> sp_lmtitem(new sc_lmt_shopitem_t(m_user));
            sp_lmtitem->db.init(*res.get_row_at(i));
            m_lmt_hm.insert(make_pair(sp_lmtitem->db.shopindex, sp_lmtitem));
        }
    }
}

// cardevent_hm_t m_cardevent_hm;
int sc_lmt_shop_mgr_t::unicast_shop_items()
{
    sc_msg_def::ret_lmt_shop_items_t ret;
    for (size_t i = 0; i < repo_mgr.lmt_shop.size(); ++i)
    {
        repo_def::lmt_shop_t* rp_shop = repo_mgr.lmt_shop.get(i+1);
        if (rp_shop == NULL)
            break;
        
        if(date_helper.cur_sec() < str2stamp(rp_shop->start_time) || date_helper.cur_sec() > str2stamp(rp_shop->end_time))
            continue;
        sc_msg_def::jpk_lmt_shop_item_t item;
        item.id = rp_shop->id;
        item.item_id = rp_shop->item_id;
        item.count = 1;
        item.name = rp_shop->name;
        item.price = rp_shop->price;
        item.limited = rp_shop->islimited;
        item.money_type = rp_shop->money_type;
        item.end_time = str2stamp(rp_shop->end_time);
        int current;
        auto it = m_lmt_hm.find(rp_shop->id);
        if (it == m_lmt_hm.end())
            current = 0;
        else 
        {
                if (it->second->db.refresh_time < str2stamp(rp_shop->start_time) || it->second->db.refresh_time > str2stamp(rp_shop->end_time))
                {
                    db_LmtShop_ext_t &db = it->second->db;
                    db.set_count(0);
                    db.set_refresh_time(date_helper.cur_sec());
                   it->second->save_db();
                    current = 0;
                }
                else
                {
                    current = it->second->db.count;
                }
        }
        item.buy_num = current;
        ret.items.push_back(std::move(item));
    }
    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    return SUCCESS;
}

uint32_t sc_lmt_shop_mgr_t::str2stamp(string str)
{
    tm tm_;
    strptime(str.c_str(), "%Y-%m-%d %H:%M:%S", &tm_);
    time_t time_ = mktime(&tm_);
    return (uint32_t)time_;
}

int sc_lmt_shop_mgr_t::buy(int32_t id_, int32_t num_)
{
    if (id_ <= 0 || num_ <= 0)
        return ERROR_LIMIT_SHOP_ERROR;
    repo_def::lmt_shop_t* rp_shop = repo_mgr.lmt_shop.get(id_); 
    if (rp_shop == NULL)
        return ERROR_NO_LIMIT_ITME;
    if(date_helper.cur_sec() < str2stamp(rp_shop->start_time) || date_helper.cur_sec() > str2stamp(rp_shop->end_time))
    {
        return ERROR_NO_LIMIT_OPEN; 
    }
    repo_def::item_t* rp_item = repo_mgr.item.get(rp_shop->item_id);
    if (rp_item == NULL)
        return ERROR_NO_LIMIT_REWARD;

    if (rp_shop->islimited > 0)
    {
        int32_t current;
        auto it = m_lmt_hm.find(rp_shop->id);
        if (it == m_lmt_hm.end())
            current = 0;
        else current = it->second->db.count;
        if ((current + num_) > rp_shop->islimited)
            return ERROR_NOT_ENOUGH_TIMES;
    }
    
     //扣除消耗点
    int32_t price = rp_shop->price * num_;
    if (m_user.rmb() >= price && price > 0)
    {
        m_user.consume_yb( price );
    }else return ERROR_NO_LIMIT_COST;
    m_user.save_db();

    sc_msg_def::nt_bag_change_t nt;
    if( 15 == rp_shop->item_id/1000 )
    {
        m_user.item_mgr.open_pack_item(rp_shop->item_id, 1);
    }

    if (rp_shop->islimited > 0)
    {
        auto it = m_lmt_hm.find(rp_shop->id);
        if (it != m_lmt_hm.end())
        {
            db_LmtShop_ext_t &db = it->second->db;
            db.set_count(db.count + num_);
            db.set_refresh_time(date_helper.cur_sec());
            buystamp = date_helper.cur_sec();
            it->second->save_db();
        }
        else
        {
            boost::shared_ptr<sc_lmt_shopitem_t> sp_lmtitem(new sc_lmt_shopitem_t(m_user));
            db_LmtShop_t& db = sp_lmtitem->db;
            db.uid = m_user.db.uid;
            db.shopindex = rp_shop->id;
            db.shopid = rp_shop->item_id;
            db.count = num_;
            db.refresh_time = date_helper.cur_sec();
            m_lmt_hm.insert(make_pair(sp_lmtitem->db.shopindex, sp_lmtitem));
            db_service.async_do((uint64_t)m_user.db.uid, [](db_LmtShop_t& db_){
                db_.insert();
            }, db);
        }
    }
    statics_ins.unicast_buylog(m_user,rp_shop->item_id,rp_shop->name,1,-1,rp_shop->price,0,0,0);
    return SUCCESS;
}
