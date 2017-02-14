#include "sc_arena_page_cache.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "date_helper.h"

#define IN_PAGE_RANK(r) (1<=r&&r<=MAX_ARENA_PAGE_RANK)

typedef sc_msg_def::jpk_arena_page_row_t jpk_row_t;

void sc_arena_page_cache_t::add_user(sp_user_t user_)
{
    if (user_->db.rank > MAX_ARENA_PAGE_RANK)
        return;
    get_jpk_row(user_, m_rows[user_->db.rank]);

    int page = get_page(user_->db.rank);
    serial_page(page);
}
void sc_arena_page_cache_t::add_row(int uid_, int rank_, const string& name_, int level_, int fp_, int utype_,int uVip)
{
    if (rank_ > MAX_ARENA_PAGE_RANK)
        return;
    m_rows[rank_].uid = uid_;
    m_rows[rank_].rank = rank_;
    m_rows[rank_].name = name_;
    m_rows[rank_].level = level_;
    m_rows[rank_].fp = fp_;
    m_rows[rank_].utype = utype_;
    m_rows[rank_].vip = uVip;
}
void sc_arena_page_cache_t::update_rank(int32_t uid_, int old_rank_, int now_rank_)
{
    if (now_rank_ > MAX_ARENA_PAGE_RANK)
        return;

    if (old_rank_ <= MAX_ARENA_PAGE_RANK && now_rank_ <= MAX_ARENA_PAGE_RANK)
    {
        std::swap(m_rows[now_rank_], m_rows[old_rank_]);
        m_rows[now_rank_].rank = now_rank_;
        m_rows[old_rank_].rank = old_rank_;
    }

    if (old_rank_ > MAX_ARENA_PAGE_RANK)
    {
        sp_user_t sp_user;
        if (logic.usermgr().get(uid_, sp_user))
            get_jpk_row(sp_user, m_rows[now_rank_]);
    }

    int oldpage = get_page(old_rank_);
    int nowpage = get_page(now_rank_);

    if (oldpage == nowpage)
    {
        serial_page(oldpage);
    }
    else
    {
        if (oldpage <= MAX_ARENA_PAGE_NUM)
        {
            serial_page(oldpage);
        }

        if (nowpage <= MAX_ARENA_PAGE_NUM)
        {
            serial_page(nowpage);
        }
    }
}
void sc_arena_page_cache_t::unicast_arena_page(int uid_)
{
    sc_msg_def::ret_arena_rank_page_t ret;
    for(int i=1; i<=MAX_ARENA_PAGE_NUM; i++)
    {
        if (m_serialed_rows[i].empty())
        {
            break;
        }

        ret.pages.push_back(m_serialed_rows[i]);
    }

    logic.unicast(uid_, ret);
}
void sc_arena_page_cache_t::get_jpk_row(sp_user_t user_, jpk_row_t& row_)
{
    row_.uid = user_->db.uid;
    row_.rank = user_->db.rank;
    row_.level = user_->db.grade;
    row_.name = user_->db.nickname();
    row_.fp = user_->get_total_fp();
    row_.utype = user_->db.utype;
    row_.vip = user_->db.viplevel;
}
void sc_arena_page_cache_t::serial_page(int page_)
{
    sc_msg_def::jpk_arena_page_t jpk;

    jpk.page = page_;

    int b = (jpk.page-1)*MAX_ARENA_PAGE_ROW_NUM+1;
    for (int i=0; i<MAX_ARENA_PAGE_ROW_NUM; i++)
    {
        if (m_rows[b+i].utype > 0)
            continue;
        jpk.rows.push_back(m_rows[b+i]);
    }

    m_serialed_rows[jpk.page].clear();
    jpk >> m_serialed_rows[jpk.page];
}
void sc_arena_page_cache_t::init_serialize()
{
    for(int i=1; i<=MAX_ARENA_PAGE_NUM; i++)
    {
        serial_page(i);
    }
}
void sc_arena_page_cache_t::on_level_up(int uid_)
{
    sp_user_t sp_user;
    if (logic.usermgr().get(uid_, sp_user))
    {
        if (sp_user->db.rank <= MAX_ARENA_PAGE_RANK)
        {
            get_jpk_row(sp_user, m_rows[sp_user->db.rank]);
            serial_page(get_page(sp_user->db.rank));
        }
    }
}
