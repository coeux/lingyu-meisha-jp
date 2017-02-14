#ifndef _sc_rank_h
#define _sc_rank_h

using namespace std;
#include <stdint.h>
#include <msg_def.h>
#include <db_def.h>
#include <unordered_map>
#include <boost/shared_ptr.hpp>
#include <sc_maxid.h>
enum rank_type_index
{
    fight_top = 0,
    arena_top,
    hot_top,
    gang_top,
    card_top,
    level_top,
    fight_five,
    arena_five,
    hot_five,
    gang_five, 
    card_five,
    level_five, 
};


class sc_user_t;
class sc_rank_t
{
    public:
        sc_rank_t(){};
    public:
        void load_db(vector<int32_t>& hostnums_);
        int unicast_rank_infos(int32_t uid, vector<sc_msg_def::jpk_rank_t>& rankinfo);
        int update_rank_infos(int32_t uid, int rankindx, int ranknum);
        unordered_map<int32_t, db_Rank_t>  db_rank;
        sc_maxid_t                      m_maxid;
        char        db_sql[20];
};
#define rank_ins (singleton_t<sc_rank_t>::instance())
#endif
