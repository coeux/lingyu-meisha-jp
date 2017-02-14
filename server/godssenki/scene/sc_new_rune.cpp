#include "sc_new_rune.h"
#include "date_helper.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "random.h"
#include "sc_statics.h"

#define LOG "SC_NEW_RUNE"
#define RUNE_BEGIN_ID 1800000
#define RUNE_END_ID 1810000

sc_rune_page_t::sc_rune_page_t(sc_user_t &user_)
:m_user(user_)
{
}

void
sc_rune_page_t::save_db_info()
{
    string sql = db_info.get_up_sql();
    db_service.async_do((uint64_t)db_info.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, sql);
}

void
sc_rune_page_t::load_db()
{
    sql_result_t res;
    if (0 == db_RunePage_t::sync_select_rune_page_all(m_user.db.uid, res))
    {
        for(size_t i=0; i<res.affect_row_num(); i++)
        {
            db_RunePage_t db_page;
            db_page.init(*res.get_row_at(i));
            auto it_page = rune_page_map.find(db_page.pid);
            if (it_page == rune_page_map.end())
            {
                unordered_map<int32_t, int32_t> page;
                rune_page_map.insert(make_pair(db_page.pid, page));
                it_page = rune_page_map.find(db_page.pid);
            }

            it_page->second.insert(make_pair(db_page.slot, db_page.id));
        }
    }
    else
    {
        init_new_user_page();
    }

    sql_result_t res_info;
    if (0 == db_RuneInfo_t::sync_select_uid(m_user.db.uid, res_info))
    {
        db_info.init(*res_info.get_row_at(0));
    }
    else
    {
        init_new_user_info();
    }

    sql_result_t res_i;
    max_id = 0;
    if (0 == db_RuneItem_t::sync_select_rune_item_all(int32_t(m_user.db.uid), res_i))
    {
        for(size_t i=0; i<res_i.affect_row_num(); i++)
        {
            db_RuneItem_t db_item;
            db_item.init(*res_i.get_row_at(i));
            if (db_item.id > max_id)
                max_id = db_item.id;

            rune_map.insert(make_pair(db_item.id, db_item));
        }
    }

    rune_function.load_db();
}

void
sc_rune_page_t::init_new_user_page()
{
    for(int i=1; i<=1; ++i)
    {
        unordered_map<int32_t, int32_t> page;
        for(int j=0; j<=22; ++j)
        {
            page.insert(make_pair(j, -1));
            db_RunePage_t db_page;
            db_page.uid = m_user.db.uid;
            db_page.pid = 0;
            db_page.slot = j;
            db_page.id = -1;
            db_service.async_do((uint64_t)m_user.db.uid, [](db_RunePage_t& db_) {
                db_.insert();
            }, db_page);
        }
        rune_page_map.insert(make_pair(0, page));
    }
}

void
sc_rune_page_t::init_new_user_info()
{
    db_info.uid = m_user.db.uid;
    db_info.hunt_level = 1;
    db_service.async_do((uint64_t)m_user.db.uid, [](db_RuneInfo_t& db_) {
        db_.insert();
    }, db_info.data());
}

void
sc_rune_page_t::enter_hunt(sc_msg_def::req_enter_rune_hunt_t& jpk_)
{
    sc_msg_def::ret_enter_rune_hunt_t ret;
    ret.curLevel = db_info.hunt_level;
    rune_message_s.get_latest_20(ret.news);

    ret.code = SUCCESS;
    logic.unicast(m_user.db.uid, ret);
    statics_ins.unicast_eventlog(m_user,jpk_.cmd(),ret.curLevel);
}

void
sc_rune_page_t::hunt(int32_t use_item_)
{
    sc_msg_def::ret_hunt_rune_t ret;

    // hunt_level check
    auto rp_rune_prob = repo_mgr.rune_prob.get(db_info.hunt_level);
    if (rp_rune_prob == NULL)
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    // cost check
    int32_t cost = rp_rune_prob->cost;
    if (m_user.db.gold < cost)
    {
        ret.code = ERROR_RUNE_NOT_ENOUGH_MONEY;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    // get new rune
    int32_t sum = 0;
    for (auto i=1; i<rp_rune_prob->drop.size(); ++i)
    {
        sum += rp_rune_prob->drop[i];
    }
    if (sum < 1)
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    int32_t pro = random_t::rand_integer(1, sum);
    int32_t rare = -1;
    for (auto i=1; i<rp_rune_prob->drop.size(); ++i)
    {
        if (pro <= rp_rune_prob->drop[i])
        {
            rare = i;
            break;
        }
        pro -= rp_rune_prob->drop[i];
    }
    if (rare == -1)
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    auto pro_info = rune_function.get_prob_info();

    auto it = pro_info->find(rare);
    if( it == pro_info->end() )
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    int32_t resid = -1;
    int32_t count = it->second.size();
    if( count <= 0 )
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    int32_t pro_r = random_t::rand_integer(1, count);
    int32_t i = 0;
    for(auto it_r=it->second.begin(); it_r!=it->second.end(); ++it_r)
    {
        i++;
        if( i == pro_r)
        {
            resid = it_r->first;
            break;
        } 
    }
    if (resid == -1)
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }

    // get next level
    int32_t sum_l = 0;
    for (auto i=1; i<rp_rune_prob->lvup.size(); ++i)
    {
        sum_l += rp_rune_prob->lvup[i];
    }
    if (sum_l < 1)
    {
        ret.code = ERROR_RUNE_REPO;
        logic.unicast(m_user.db.uid, ret);
        return;
    }
    int32_t pro_l = random_t::rand_integer(1, sum_l);
    int32_t new_level = -1;
    int32_t use_item_flag = 0;
    for (auto i=1; i<rp_rune_prob->lvup.size(); ++i)
    {
        if (pro_l <= rp_rune_prob->lvup[i])
        {
            new_level = i;
            break;
        }
        pro_l -= rp_rune_prob->lvup[i];
    }
    if( db_info.hunt_level == 1 && use_item_ != -1)
    {
        sc_msg_def::nt_bag_change_t nt;
        if (m_user.item_mgr.get_items_count(use_item_) >= 1)
        {
            if (use_item_ == 18002)
            {
                use_item_flag = 1;
                db_info.hunt_level = 3;
                m_user.item_mgr.consume(18002, 1, nt);
                m_user.item_mgr.on_bag_change(nt);
            }
            else if(use_item_ == 18003)
            {
                use_item_flag = 1;
                db_info.hunt_level = 4;
                m_user.item_mgr.consume(18003, 1, nt);
                m_user.item_mgr.on_bag_change(nt);
            }
            else
            {
                db_info.hunt_level = new_level;
            }
        }
        else
        {
            db_info.hunt_level = new_level;
        }
    }
    else
    {
        db_info.hunt_level = new_level;
    }
    
    // bag add
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.addnew(resid,1,nt);
    m_user.item_mgr.addnew(18001,1,nt);
    m_user.item_mgr.on_bag_change(nt);

    rune_message_s.add_user(m_user.db.uid);
    auto rp_rune = repo_mgr.rune.get(resid*100+1);
    if (rp_rune->quality > 3)
    {
        rune_message_s.push_message(m_user.db.nickname(), resid, m_user.db.uid);
    }

    m_user.consume_gold(cost);
    ret.new_level = db_info.hunt_level;
    ret.new_resid = resid;
    ret.code = SUCCESS;

    db_info.set_hunt_level(db_info.hunt_level);
    save_db_info();
            
    logic.unicast(m_user.db.uid, ret);
    statics_ins.unicast_eventlog(m_user,ret.cmd(),use_item_flag, use_item_, resid, db_info.hunt_level);
}

void
sc_rune_page_t::add_new_rune(int32_t resid_, int32_t num_)
{
    // db add
    if (num_ <= 0)
        return;
    sc_msg_def::nt_add_new_rune_t nt_n;
    nt_n.id_list.clear();
    for(int i=0;i<num_;++i)
    {
        db_RuneItem_t db_item;
        max_id++;
        db_item.id = max_id;
        db_item.resid = resid_;
        db_item.exp = 0;
        db_item.level = 1;
        db_item.uid = m_user.db.uid;

        nt_n.id_list.push_back(db_item.id);

        db_service.async_do((uint64_t)m_user.db.uid, [](db_RuneItem_t& db_) {
            db_.insert();
        }, db_item);
        rune_map.insert(make_pair(db_item.id, db_item));
        statics_ins.unicast_eventlog(m_user, nt_n.cmd(), db_item.id, resid_);
    }

    nt_n.lv = 1;
    nt_n.resid = resid_;
    nt_n.exp = 0;

    logic.unicast(m_user.db.uid, nt_n);
}
    
    int32_t
sc_rune_page_t::active_new_partner(int32_t pid_, sc_msg_def::ret_new_rune_active_t& ret_)
{
    auto it_page = rune_page_map.find(pid_);
    if (it_page != rune_page_map.end())
    {
        if (it_page->second.find(0) == it_page->second.end())
        {
            return ERROR_HAVE_ACTIVE_PARTNER;
        }
    }

    int32_t consume_money = repo_mgr.configure.find(42)->second.value;
    if (m_user.rmb() < consume_money)
        return ERROR_RUNE_NO_YB;

    unordered_map<int32_t, int32_t> page;
    for(int j=0; j<=22; ++j)
    {
        page.insert(make_pair(j, -1));
        db_RunePage_t db_page;
        db_page.uid = m_user.db.uid;
        db_page.pid = pid_;
        db_page.slot = j;
        db_page.id = -1;
        db_service.async_do((uint64_t)m_user.db.uid, [](db_RunePage_t& db_) {
            db_.insert();
        }, db_page);
    }
    rune_page_map.insert(make_pair(pid_, page));

    ret_.pid = pid_;

    m_user.consume_yb(consume_money);
    return SUCCESS;
}

    void 
sc_rune_page_t::inform_leave()
{
    rune_message_s.del_user(m_user.db.uid);
}

void
sc_rune_page_t::get_rune_list(vector<sc_msg_def::jpk_new_rune_t>& list_)
{
    for(auto it=rune_map.begin(); it!=rune_map.end(); ++it)
    {
        sc_msg_def::jpk_new_rune_t jpk;
        jpk.id = it->second.id;
        jpk.resid = it->second.resid;
        jpk.lv = it->second.level;
        jpk.exp = it->second.exp;

        list_.push_back(jpk);
    }
}

void
sc_rune_page_t::get_rune_page(map<int32_t, sc_msg_def::jpk_rune_page_t>& map_)
{
    map_.clear();
    for(auto it=rune_page_map.begin(); it!=rune_page_map.end(); ++it)
    {
        sc_msg_def::jpk_rune_page_t page_info;
        for(auto it_p=it->second.begin(); it_p!=it->second.end(); ++it_p)
        {
            page_info.page_info.insert(make_pair(it_p->first, it_p->second));
        }
        map_.insert(make_pair(it->first, page_info));
    }
}

    int32_t
sc_rune_page_t::inlay_rune(int32_t rune_id_, int32_t pid_, int32_t pos_, sc_msg_def::ret_new_rune_inlay_t& ret_)
{
    auto it_rune = rune_map.find(rune_id_);
    // check rune_id_, pid_, pos_
    if (it_rune == rune_map.end())
    {
        return ERROR_RUNE_MAP;
    }

    if (pos_ > 22 || pos_ < 1)
    {
        return ERROR_RUNE_POS;
    }
    
    auto it_page = rune_page_map.find(pid_);
    if (it_page == rune_page_map.end())
    {
        return ERROR_RUNE_NO_PAGE;
    }
    auto it_pos = it_page->second.find(pos_);
    if (it_pos == it_page->second.end())
    {
        return ERROR_RUNE_NO_POS;
    }
    if (it_pos->second != -1)
    {
        return ERROR_RUNE_HAS_OCCUPY;
    }

    it_pos->second = rune_id_;

    char sql_page[256];
    sprintf(sql_page, "UPDATE RunePage set `id`=%d WHERE `uid`=%d AND `pid`=%d AND `slot`=%d ;", rune_id_, db_info.uid, pid_, pos_);
    db_service.async_do((uint64_t)db_info.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql_page));

    ret_.id = rune_id_;
    ret_.pid = pid_;
    ret_.pos = pos_;

    m_user.on_pro_changed(pid_);

    return SUCCESS;
}

    int32_t
sc_rune_page_t::unlay_rune(int32_t pid_, int32_t pos_, sc_msg_def::ret_new_rune_unlay_t& ret_)
{
    // check rune_id_, page_, pos_
    auto it_page = rune_page_map.find(pid_);
    if (it_page == rune_page_map.end())
    {
        return ERROR_RUNE_NO_PAGE;
    }
    else if(it_page->second.find(0) == it_page->second.end())
    {
        return ERROR_NOT_ACTIVE;
    }

    if (pos_ > 22 || pos_ < 1)
    {
        return ERROR_RUNE_POS;
    }
    
    auto it_pos = it_page->second.find(pos_);
    if (it_pos == it_page->second.end())
    {
        return ERROR_RUNE_NO_POS;
    }
    if (it_pos->second == -1)
    {
        return ERROR_RUNE_HAS_OCCUPY;
    }

    it_pos->second = -1;

    char sql_page[256];
    sprintf(sql_page, "UPDATE RunePage set `id`=%d WHERE `uid`=%d AND `pid`=%d AND `slot`=%d ;", -1, db_info.uid, pid_, pos_);
    db_service.async_do((uint64_t)db_info.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql_page));

    ret_.pid = pid_;
    ret_.pos = pos_;

    m_user.on_pro_changed(pid_);

    return SUCCESS;
}

    int32_t
sc_rune_page_t::levelup(int32_t rune_id_, vector<int32_t>& mat_list, sc_msg_def::ret_new_rune_levelup_t& ret_)
{
    auto main_rune = rune_map.find(rune_id_);
    if (main_rune == rune_map.end())
    {
        return ERROR_RUNE_MAP;
    }
    // check mat inlay
    // check mat exp
    int32_t sum_exp = 0;
    for (auto it_rune=mat_list.begin(); it_rune!=mat_list.end(); ++it_rune)
    {
        auto mat_rune=rune_map.find(*it_rune);
        if (mat_rune==rune_map.end())
            return ERROR_RUNE_MAP;
        auto rp_rune = repo_mgr.rune.get(mat_rune->second.resid*100+mat_rune->second.level);
        if (rp_rune == NULL)
            return ERROR_RUNE_REPO;
        sum_exp += (mat_rune->second.exp+rp_rune->base_exp);
    }
    sc_msg_def::nt_del_rune_t nt_n;
    for (auto it_rune=mat_list.begin(); it_rune!=mat_list.end(); ++it_rune)
    {
        remove_rune(*it_rune, nt_n.id_list);
    }
    main_rune->second.exp += sum_exp;

    ret_.id = main_rune->second.id;
    ret_.exp = main_rune->second.exp;

    char sql_item[256];
    sprintf(sql_item, "UPDATE RuneItem set `exp`=%d WHERE `uid`=%d AND `id`=%d ;", main_rune->second.exp, m_user.db.uid, rune_id_);
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql_item));

    logic.unicast(m_user.db.uid, nt_n);
    return SUCCESS;    
}

    void
sc_rune_page_t::remove_rune(int32_t rune_id_, vector<int32_t>& del_list_)
{
    auto rune_item = rune_map.find(rune_id_);
    if (rune_item == rune_map.end())
        return;

    // bag remove
    sc_msg_def::nt_bag_change_t nt;
    m_user.item_mgr.consume(rune_item->second.resid,1,nt);
    m_user.item_mgr.on_bag_change(nt);

    // db remove
    char sql_item[256];
    sprintf(sql_item, "DELETE FROM RuneItem WHERE uid=%d AND id=%d ;", m_user.db.uid, rune_id_);
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql_item));

    del_list_.push_back(rune_id_);

    statics_ins.unicast_eventlog(m_user, 7963, rune_id_, rune_item->second.resid);

    rune_map.erase(rune_id_);
}

    int32_t
sc_rune_page_t::compose(int32_t rune_id_, vector<int32_t>& mat_list, sc_msg_def::ret_new_rune_compose_t& ret_)
{
    auto main_rune = rune_map.find(rune_id_);
    if (main_rune == rune_map.end())
    {
        return ERROR_RUNE_MAP;
    }

    auto rp_rune = repo_mgr.rune.get(main_rune->second.resid*100+main_rune->second.level);
    if (rp_rune == NULL)
        return ERROR_RUNE_REPO;
    auto rp_rune_next = repo_mgr.rune.get(main_rune->second.resid*100+main_rune->second.level+1);
    if (rp_rune == NULL)
        return ERROR_RUNE_MAX_LEVEL;

    if (main_rune->second.exp < rp_rune->exp)
    {
        return ERROR_NOT_ENOUGH_EXP;
    }

    // stuff
    sc_msg_def::nt_del_rune_t nt_n;
    for (auto it_rune=mat_list.begin(); it_rune!=mat_list.end(); ++it_rune)
    {
        remove_rune(*it_rune, nt_n.id_list);
    }

    main_rune->second.level++;

    // check max level and set exp
    auto rp_rune_max_level = repo_mgr.rune.get(main_rune->second.resid*100+main_rune->second.level+1);
    if (rp_rune_max_level == NULL)
    {
        main_rune->second.exp = rp_rune->exp;
    }

    char sql_item[256];
    sprintf(sql_item, "UPDATE RuneItem set `level`=%d, `exp`=%d WHERE `uid`=%d AND `id`=%d ;", main_rune->second.level, main_rune->second.exp, m_user.db.uid, rune_id_);
    db_service.async_do((uint64_t)m_user.db.uid, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql_item));

    ret_.id = rune_id_;
    ret_.lv = main_rune->second.level;

    logic.unicast(m_user.db.uid, nt_n);
    check_rune_inlay_pro_changed(rune_id_);
    return SUCCESS;
}

    float
sc_rune_page_t::get_attribute(int32_t attribute_, int32_t pid_)
{
    auto it_page = rune_page_map.find(pid_);
    if (it_page == rune_page_map.end())
    {
        return 0;
    }
    float sum_attribute = 0;
    for(auto it_pos=it_page->second.begin(); it_pos!=it_page->second.end(); ++it_pos)
    {
        auto rune_item = rune_map.find(it_pos->second);
        if (rune_item == rune_map.end())
            continue;

        auto rp_rune = repo_mgr.rune.get(rune_item->second.resid*100+rune_item->second.level);
        if (rp_rune == NULL)
            continue;

        if (rp_rune->attribute == attribute_)
            sum_attribute += rp_rune->value;
    }
    return sum_attribute;
}

    void
sc_rune_page_t::check_rune_inlay_pro_changed(int32_t rune_id_)
{
    vector<int32_t> pid_list;
    for(auto it_page=rune_page_map.begin();it_page!=rune_page_map.end(); ++it_page)
    {
        bool have_rune = false;
        for(auto it_pos=it_page->second.begin(); it_pos!=it_page->second.end(); ++it_pos)
        {
            if (it_pos->second == rune_id_)
            {
                have_rune = true;
                break;
            }
        }
        if (have_rune)
            pid_list.push_back(it_page->first);
    }
    m_user.on_pro_changed_multiple(pid_list);
}

//================================================================================================

sc_rune_message_t::sc_rune_message_t()
{
}

void
sc_rune_message_t::load_db(vector<int32_t>& hostnums_)
{
    string host_list;
    for (int32_t host : hostnums_)
    {
        host_list.append(std::to_string(host)+",");
        hosts.push_back(host);
    }
    host_list = host_list.substr(0, host_list.length()-1);

    char sql[256];
    sql_result_t res;
    sprintf(sql, "SELECT id, name, resid FROM `RuneMessage` WHERE `hosthum` in (%s) ORDER BY `id` DESC limit 0,20", host_list.c_str());
    db_service.sync_select(sql, res);

    if (0 == res.affect_row_num())
    {
        return;
    }

    for (size_t i=0; i<res.affect_row_num(); ++i)
    {
        if (res.get_row_at(i) == NULL)
        {
            logerror((LOG, "get row is NULL!, at:%lu", i));
            break;
        }

        sql_result_row_t& row_ = *res.get_row_at(i);
        rune_message message;
        message.name = row_[1];
        message.resid = (int32_t)std::atoi(row_[2].c_str());
        message_vector.push_back(message);
    }
}

void
sc_rune_message_t::push_message(string name_, int32_t resid_, int32_t uid_)
{
    rune_message message;
    message.name = name_;
    message.resid = resid_;
    message_vector.push_back(message);

    sc_msg_def::nt_new_rune_be_hunted_t nt;
    nt.news.name = message.name;
    nt.news.resid = message.resid;
    for(auto it=user_map.begin(); it!=user_map.end(); ++it)
    {
        logic.unicast(it->first, nt);
    }

    char sql[256];
    sprintf(sql, "INSERT INTO RuneMessage (`hosthum`, `name`, `resid`) VALUES (%d, '%s', %d)", hosts[0], name_.c_str(), resid_);
    db_service.async_do((uint64_t)uid_, [](string& sql_){
        db_service.async_execute(sql_);
    }, string(sql));
} 

void
sc_rune_message_t::add_user(int32_t uid_)
{
    user_map.insert(make_pair(uid_, 0));
}

void
sc_rune_message_t::del_user(int32_t uid_)
{
    user_map.erase(uid_);
}

void 
sc_rune_message_t::get_latest_20(vector<sc_msg_def::hunt_news>& news_)
{
    size_t size_m = message_vector.size();
    for(size_t i=0;i<10;i++)
    {
        int32_t turn = size_m-9+i;
        if (turn >= size_m || turn <0)
            continue;
        sc_msg_def::hunt_news news;
        news.name = message_vector[turn].name;
        news.resid = message_vector[turn].resid;
        news_.push_back(news);
    }
}

//================================================================================================
sc_rune_function_t::sc_rune_function_t()
:is_load(false)
{
}

void
sc_rune_function_t::load_db()
{
    if (!is_load)
    {
        load_rune_info();
        is_load = true;
    }
}

void
sc_rune_function_t::load_rune_info()
{
    rune_prob_info.clear();
    for(size_t i = RUNE_BEGIN_ID; i < RUNE_END_ID; ++i)
    {
        auto rp_rune = repo_mgr.rune.get(i+1);
        if (rp_rune == NULL)
            continue;
        int32_t resid = int32_t(rp_rune->id / 100);
        int32_t rare = rp_rune->rare;
        auto it = rune_prob_info.find(rare);
        if( it == rune_prob_info.end() )
        {
            unordered_map<int32_t, int32_t> resid_map;
            rune_prob_info.insert(make_pair(rare, resid_map));
            it = rune_prob_info.find(rare);
        }
        it->second.insert(make_pair(resid, 0));
    }
}

unordered_map<int32_t, unordered_map<int32_t, int32_t>>*
sc_rune_function_t::get_prob_info()
{
    return &rune_prob_info;
}
