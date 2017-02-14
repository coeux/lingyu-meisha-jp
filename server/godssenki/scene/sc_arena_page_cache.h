#ifndef _sc_arena_page_cache_h_
#define _sc_arena_page_cache_h_

#include <boost/shared_ptr.hpp>
#include "msg_def.h"
#include "singleton.h"

#define MAX_ARENA_PAGE_RANK 100
#define MAX_ARENA_PAGE_NUM 10 
#define MAX_ARENA_PAGE_ROW_NUM (MAX_ARENA_PAGE_RANK/MAX_ARENA_PAGE_NUM)

class sc_user_t;

class sc_arena_page_cache_t
{
    typedef boost::shared_ptr<sc_user_t> sp_user_t;
    typedef sc_msg_def::jpk_arena_page_row_t jpk_row_t;

public:
    sc_arena_page_cache_t(){}

    void add_user(sp_user_t user_);
    void add_row(int uid_, int rank_, const string& name_, int level_, int fp_, int utype_ ,int uVip);

    //角色排名更新
    void update_rank(int32_t uid_, int old_rank_, int now_rank_);

    int get_page(int rank_) { return (rank_-1)/MAX_ARENA_PAGE_ROW_NUM+1; }

    void unicast_arena_page(int uid_);

    void init_serialize(); 

    void on_level_up(int uid_);
private:
    void get_jpk_row(sp_user_t user_, jpk_row_t& row_);
    void serial_page(int page_);
private:
    jpk_row_t       m_rows[MAX_ARENA_PAGE_RANK+1];
    string          m_serialed_rows[MAX_ARENA_PAGE_NUM+1];
};

#define arena_page_cache (singleton_t<sc_arena_page_cache_t>::instance())

#endif
