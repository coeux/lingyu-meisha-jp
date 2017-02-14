#ifndef _sc_arena_rank_h_
#define _sc_arena_rank_h_

#include <vector>
#include <string>
#include <unordered_map>
using namespace std;

#include "singleton.h"
#include "sc_mailinfo.h"
#include "sc_server.h"

#define MAX_RANK 2001 
#define SWAP_MAX_RANK 1500

class sc_arena_rank_t
{
public:
    sc_arena_rank_t();
    int load_db(vector<int32_t>& hostnums_);
    //return:uid
    int32_t get_user(int rank_);
    void get_user(int& rank_, uint32_t& uid_);
    int32_t get_trial(int rank_);
    //return:rank
    int32_t add_user(int32_t uid_, int32_t rank_);
    void swap_user(int32_t uid1_, int& rank1_, int32_t uid2_, int& rank2_);
    void arrangement_rank(int size_data);
    //return rank array
    int32_t* get_rank() { return m_rank; }
    //return cur max rank
    int32_t get_max_rank() { return m_max_rank; }

    static void db_update_rank(int32_t uid_,int32_t rank_);
    //排名奖励记录
    int load_reward_rank();
    int save_reward_rank();
    int get_reward_rank(int uid_);

    //定时战历记录
    void update_reward(int sec_);
    int get_reward_btp_cd();

    void on_login(uint32_t uid_);
    void update_rank_info();
    void send_reward();
private:
    void init_robort(int rank_);
    int get_reward_id(int rank_);
private:
    int32_t                             m_max_rank;
    int32_t                             m_rank[MAX_RANK+1];
    int32_t                             m_reward_rank[MAX_RANK+1];
    uint32_t                            m_reward_btp_time ;
    bool                                m_is_send;
    bool                                issend1;
    bool                                issend2;
    bool                                issend3;
    uint32_t                            m_send_reward_stamp;
    uint32_t                            m_arena_serize_tm;
    char                                db_sql[20];
};

#define arena_rank (singleton_t<sc_arena_rank_t>::instance()) 

#endif
