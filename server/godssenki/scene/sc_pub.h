#ifndef _sc_pub_h_
#define _sc_pub_h_

#include <stdint.h>
#include "msg_def.h"
#include <set>
#include <map>
#include <ext/hash_map>

#define N_RARE 5

using namespace __gnu_cxx;
using namespace std;
    
/*
struct sc_pub_info_t
{
    int32_t last_flush_stamp;
    vector<sc_msg_def::jpk_pub_partner_t> r_partners;
    sc_pub_info_t():last_flush_stamp(0) {}
};
*/
struct pub_special_t
{
	int32_t role_id;
	int32_t rate;
};

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_pub_ctl_t
{
//    typedef hash_map<int32_t, struct sc_pub_info_t> pub_hm_t;
private:
//    pub_hm_t m_pub_hm;

    /*
    //f_id:
    //0 免费概率表,免费刷新包括自动刷新和友情点刷新
    //1 付费概率表
    //2 至尊概率表
    int32_t probab[3][N_RARE];
    int32_t probab_id[N_RARE];
    */

    //c_id:
    //0 免费伙伴表
    //1 付费伙伴表
    //2 至尊伙伴表
    //p_id: 
    //白绿蓝紫金
    vector<int32_t> ps[N_RARE];
    vector<int32_t> item[100];
	unordered_map<int32_t, vector<pub_special_t>> special_pub_list;
	unordered_map<int32_t, int32_t> special_pub_sum;
    //伙伴碎片映射表
    hash_map<int32_t,int32_t> chip_hm_t;
    //当天的指定金色英雄碎片
    int32_t yesterday_gold_chip;
    int32_t gold_chip;
    uint32_t flush_tm;

private:
    void reset_gold_chip();
    int32_t get_gold_chip_count();
    void get_random_item(sp_user_t user_, int32_t flag_,int32_t &rare_,int32_t &chip_,int32_t &num_,bool is_free,int32_t stepup_sate_);
    int32_t get_chip(sp_user_t user_,int32_t resid_,int32_t num_,sc_msg_def::ret_pub_flush_t &ret_,sc_msg_def::nt_chip_change_t &change_);
    int32_t get_hero(sp_user_t user_,int32_t resid_,int32_t potential_, sc_msg_def::ret_pub_flush_t &ret_,sc_msg_def::nt_chip_change_t &change_);
//    int32_t cal_pro( sc_msg_def::jpk_pub_partner_t &p_ );
//    int32_t is_exists(int32_t uid_, int32_t resid_);
//    int32_t gen_poten(int32_t p_id_);
//    int32_t init_pub(sp_user_t user_, int32_t uid_);
    // charge_: 0免费  1收费
    // color_: 0白 1绿 2蓝 3紫 4金
//    int32_t gen_partner(int32_t uid_,int32_t charge_,int32_t color_,sc_msg_def::jpk_pub_partner_t &new_partner);

public:
    sc_pub_ctl_t();
    int32_t flush_pub(sp_user_t user_, int32_t uid_, int32_t flag_, int eid);
    void get_free_time(sp_user_t user_, int32_t uid_);
    int32_t get_gold_chip();
    void get_pub_data(sc_user_t &user_,sc_msg_def::jpk_pub_data_t &pub_);
    int32_t req_enter_modular(sp_user_t user_, sc_msg_def::ret_enter_pub_t& ret_);
    int32_t get_chip_resid(int32_t resid_);
    void set_flushtm(sp_user_t user_);
    uint32_t str2stamp(string str);
    void update_limit_draw_ten_reward(sp_user_t user_, int32_t num_, int32_t &is_in_activity, string &str);
    int32_t get_flushtime(int32_t viplevel_);
    int32_t get_minite_time(int32_t viplevel_);

    //人物login时，读取酒馆信息，更新人物的酒馆数据
    //void on_login(int32_t uid_);
    //int32_t get_pub_info(sp_user_t user_,int32_t uid_,int32_t flag_,sc_msg_def::ret_pub_flush_t &ret_);
//    int32_t hire_partner(sp_user_t user_, int32_t uid_, int32_t pos_, sc_msg_def::jpk_role_data_t &ret);
};
#define pub_ctl (singleton_t<sc_pub_ctl_t>::instance())

#endif
