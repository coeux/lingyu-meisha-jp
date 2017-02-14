#include "sc_bag.h"
#include "sc_item.h"
#include "sc_equip.h"
#include "sc_user.h"
#include "sc_wing.h"

#include "code_def.h"
#include "repo_def.h"

#define LOG "SC_BAG"

sc_bag_t::sc_bag_t(sc_user_t& user_):m_user(user_)
{
}

bool sc_bag_t::is_full()
{
    return ((m_user.item_mgr.size()+m_user.equip_mgr.bag_size()+m_user.wing.bag_size()) >= get_size());
}

bool sc_bag_t::can_change(sc_msg_def::nt_bag_change_t& change_)
{
    int num = (m_user.item_mgr.size()+m_user.equip_mgr.bag_size());
    for (size_t i=0; i<change_.items.size(); i++)
    {
        sc_msg_def::jpk_item_t& item = change_.items[i];
        if (item.num <= 0)
            continue;

        sp_item_t sp_item = m_user.item_mgr.get(item.resid);
        if (sp_item == NULL)
            num++;
    }
    return (num <= get_size());
}

bool sc_bag_t::can_contain(int32_t resid_)
{
    //有空格子一定可以放新东西
    if (is_full())
    {
        //如果没有空格子，但是有同类的道具，则可以叠加
        sp_item_t sp_item = m_user.item_mgr.get(resid_);
        return (sp_item != NULL);
    }
    return true;
}

int32_t sc_bag_t::get_size()          
{ 
    int cap = m_user.db.bagn * 5 + 1000; 
    if (m_user.vip.enable_do(vop_add_bag_max))
        return cap + 200;
    else
        return cap + 100;
}
int32_t sc_bag_t::get_current_size()
{
    return m_user.item_mgr.size()+m_user.equip_mgr.bag_size();
}
