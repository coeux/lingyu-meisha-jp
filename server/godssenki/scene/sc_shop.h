#ifndef _sc_shop_h_
#define _sc_shop_h_

#include <unordered_map>
using namespace std;

#include <boost/shared_ptr.hpp>

#include "db_ext.h"
#include "msg_def.h"

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_shopitem_t
{
public:
    db_Shop_ext_t db;
public:
    sc_shopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_shopitem_t> sp_shopitem_t;


class sc_shop_t
{
    typedef unordered_map<int32_t, sp_shopitem_t> shopitem_hm_t;
public:
    sc_shop_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items(int tab_, int page_, int sheet_);
    int unicast_npc_shop_items(int type_);
    int buy(int id_, int num_, int& dbid_);
    int npc_buy(int id_, int& dbid_, int placeNum_, int type_);
    void buy_coin(sc_msg_def::ret_buy_coin_t& ret);
    int sell(int eid_, int resid_);
    uint32_t str2stamp(string str); 
    int buy_power();
    int buy_energy();
    int buy_bag_cap();
    void update();
    int npc_shop_update(int type_);
    int npc_shop_update_free(int type_);
    int buy_item(int resid_, int num_);
private:
    sc_user_t       &m_user;
    shopitem_hm_t   m_shopitem_hm;
    db_NpcShop_t    dbMsg;
    db_SpShop_t     dbSp;
};

class sc_expeditionshopitem_t
{
public:
    db_ExpeditionShop_ext_t db;
public:
    sc_expeditionshopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_expeditionshopitem_t> sp_eshopitem_t;

class sc_expeditionshop_mgr_t
{
    typedef unordered_map<int32_t, sp_eshopitem_t> eshopitem_hm_t;
public:
    sc_expeditionshop_mgr_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    eshopitem_hm_t m_eshopitem_hm;
};

class sc_prestigeitem_t
{
public:
    db_PrestigeShop_ext_t db;
public:
    sc_prestigeitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_prestigeitem_t> sp_prestigeitem_t;

class sc_unprestigeitem_t
{
public:
    db_UnPrestigeShop_ext_t db;
public:
    sc_unprestigeitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_unprestigeitem_t> sp_unprestigeitem_t;


class sc_prestige_shop_t
{
    typedef unordered_map<int32_t, sp_prestigeitem_t> prestigeitem_hm_t;
    typedef unordered_map<int32_t, sp_unprestigeitem_t> unprestigeitem_hm_t;
public:
    sc_prestige_shop_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items(int shopindex_);
    int buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_, int32_t shopindex_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    uint32_t unbuystamp = 0;
    prestigeitem_hm_t m_prestigeitem_hm;
    unprestigeitem_hm_t m_unprestigeitem_hm;
};


class sc_npcshop_t
{
public:
    void update();
private:
    uint32_t        npctime = 0;
    db_NpcShop_t    dbNpc;
    db_SpShop_t     dbShop;
};
#define shop_ins (singleton_t<sc_npcshop_t>::instance())

class sc_chipitem_t
{
public:
    db_ChipShop_ext_t db;
public:
    sc_chipitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_chipitem_t> sp_chipitem_t;

class sc_chip_shop_t
{
    typedef unordered_map<int32_t, sp_chipitem_t> chipitem_hm_t;
public:
    sc_chip_shop_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    chipitem_hm_t m_chipitem_hm;
};

class sc_plantshop_item_t
{
public:
    db_PlantShop_ext_t db;
public:
    sc_plantshop_item_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_plantshop_item_t> sp_plantshopitem_t;

class sc_plant_shop_t
{
    typedef unordered_map<int32_t, sp_plantshopitem_t> plantitem_hm_t;
public:
    sc_plant_shop_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    plantitem_hm_t m_plantshop_hm;
};

class sc_inventoryshop_item_t
{
public:
    db_InventoryShop_ext_t db;
public:
    sc_inventoryshop_item_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_inventoryshop_item_t> sp_inventoryshopitem_t;


class sc_inventoryshop_t
{
    typedef unordered_map<int32_t, sp_inventoryshopitem_t> inventoryitem_hm_t;
public:
    sc_inventoryshop_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_, int32_t& resid_, int32_t& count_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    inventoryitem_hm_t m_inventoryshop_hm;
};


class sc_gang_shopitem_t
{
public:
    db_GangShop_ext_t db;
public:
    sc_gang_shopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_gang_shopitem_t> sp_gangitem_t;

class sc_gang_shop_mgr_t
{
    typedef unordered_map<int32_t, sp_gangitem_t> gangitem_hm_t;
public:
    sc_gang_shop_mgr_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    gangitem_hm_t m_gangitem_hm;
};

class sc_rune_shopitem_t
{
public:
    db_RuneShop_ext_t db;
public:
    sc_rune_shopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_rune_shopitem_t> sp_runeitem_t;

class sc_rune_shop_mgr_t
{
    typedef unordered_map<int32_t, sp_runeitem_t> runeitem_hm_t;
public:
    sc_rune_shop_mgr_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    runeitem_hm_t m_runeitem_hm;
};

class sc_cardevent_shopitem_t
{
public:
    db_CardEventShop_ext_t db;
public:
    sc_cardevent_shopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_cardevent_shopitem_t> sp_cardeventitem_t;

class sc_cardevent_shop_mgr_t
{
    typedef unordered_map<int32_t, sp_cardeventitem_t> cardevent_hm_t;
public:
    sc_cardevent_shop_mgr_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    cardevent_hm_t m_cardevent_hm;
};

class sc_lmt_shopitem_t
{
public:
    db_LmtShop_ext_t db;
public:
    sc_lmt_shopitem_t(sc_user_t& user_);
    void save_db();
private:
    sc_user_t& m_user;
};
typedef boost::shared_ptr<sc_lmt_shopitem_t> sp_lmtitem_t;

class sc_lmt_shop_mgr_t
{
    typedef unordered_map<int32_t, sp_lmtitem_t> lmt_hm_t;
public:
    sc_lmt_shop_mgr_t(sc_user_t& user_);
    void load_db();
    int unicast_shop_items();
    uint32_t str2stamp(string str); 
    int buy(int32_t id_, int32_t num_);
private:
    sc_user_t &m_user;
    uint32_t buystamp = 0;
    lmt_hm_t m_lmt_hm;
};

#endif
