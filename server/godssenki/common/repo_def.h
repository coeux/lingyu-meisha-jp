#ifndef _repo_def_h_
#define _repo_def_h_

#include "repo.h"
#include <map>
#include <unordered_map>
using namespace std;

namespace repo_def
{
    //角色初始数据表
    struct role_t 
    {
        int id;
        string name;
        string title;
        int job;
        int rare;
        int price;
        int gender;
        int base_atk;
        int base_mgc;
        int base_def;
        int base_res;
        int base_hp;
        int base_crit;
        int base_acc;
        int base_dodge;
        int base_ten;
        int hit_area;
        float base_imm_dam_pro;
        vector<float> factor; // 5个因子
        float atk_power;
        float hit_power;
        float kill_power;
        int skill_id;
        int skill_id2;
        int skill_id3;
        int skill_passive;
        int skill_passive2;
        int skill_auto;
        int skill_auto2;
        int skill_auto3;
        vector<int> partner; 
        int hero_piece;
        int destiny1;
        int destiny2;
        int destiny3;
        int destiny4;
        int fate; // 是否有命格
        int attribute; // 自然属性

        JSON38(role_t, id, name, title, job, rare, price, gender, base_atk, base_mgc, base_def, base_res, base_hp, base_crit, base_acc, base_dodge, base_ten,hit_area, base_imm_dam_pro, factor, atk_power, hit_power, kill_power, skill_id, skill_id2, skill_id3, partner, skill_passive, skill_passive2, hero_piece, destiny1, destiny2, destiny3, destiny4, skill_auto, skill_auto2, skill_auto3, fate, attribute)
    };
    typedef repo_t<role_t> repo_role_t;

    enum equip_solt_e
    {
        //头
        helmet = 1,
        //胸
        armor,
        //腿
        foot,
        //武器
        weapon,
        //首饰
        accessory,
    };

    //角色初始装备表
    struct init_equip_t
    {
        //角色id
        int role_id;
        //初始装备
        vector<int32_t> init_equip;
        JSON2(init_equip_t, role_id, init_equip)
    };
    typedef repo_t<init_equip_t> repo_init_equip_t;

    //角色升级属性增长表
    struct lvup_attr_t
    {
        int32_t id;
        int32_t level;
        int32_t job;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        int32_t dodge;
        int32_t cri;
        float tough;
        JSON11(lvup_attr_t, id, level, job, atk, mgc, def, res, hp, dodge, cri, tough)
    };
    typedef repo_t<lvup_attr_t> repo_lvup_attr_t;

    //道具表
    struct item_t
    {
        int32_t id;
        string name;
        //int32_t stack_number;
        int32_t price;
        int32_t quality;
        int32_t type;
        int32_t usable;
        int32_t price_yb;
        int32_t rare;
        //JSON5(item_t, id, stack_number, price, quality, usable)
        JSON8(item_t, id, name, type, price, quality, usable, price_yb, rare)
    };
    typedef repo_t<item_t> repo_item_t;

    //主城
    struct city_t
    {
        int32_t id;
        string name;
        JSON2(city_t, id, name)
    };
    typedef repo_t<city_t> repo_city_t;

    //装备初始属性表
    struct equip_t
    {
        int32_t id;
        string name;
        string icon;
        string description;
        int32_t type;
        int32_t attribute;
        int32_t base_value;
        int32_t upgrade_lv;
        int32_t can_rank;
        int32_t rank;
        JSON10(equip_t, id, name, icon, description, type, attribute, base_value, upgrade_lv, can_rank, rank)
    };
    typedef repo_t<equip_t> repo_equip_t;

    //关卡表
    struct round_t
    {
        int32_t id;
        int32_t city_id;
        int32_t exp;
        int32_t coin; //金币
        int32_t level;
        int32_t pre_quest;
        vector<vector<int32_t>> item_drop; //[[itemid, prob, num]], pro 1/10000
        vector<vector<int32_t>> darwing_drop; //[[itemid, prob]], pro 1/10000
        int32_t zodiac_drop;
        int32_t fighting_capacity; //战力
        vector<vector<float>> initial_monster;
        vector<vector<float>> monster;
        vector<float> initial_boss;
        vector<float> boss;
        vector<vector<int>> first_drop;

        JSON15(round_t, id, city_id, exp, coin, level, pre_quest, item_drop, darwing_drop,zodiac_drop,fighting_capacity, initial_monster, monster, initial_boss, boss, first_drop)
    };
    typedef repo_t<round_t> repo_round_t;
    
    //英雄迷窟
    struct cave_t
    {
        int32_t id;
        int32_t exp;
        int32_t coin; //金币
        int32_t soul;
        int32_t pre_level;
        int32_t fighting_capacity;
        int32_t level;
        vector<vector<int32_t>> item_drop; //[[itemid, prob, num]], pro 1/10000

        JSON8(cave_t, id, exp, coin, soul, pre_level,item_drop,fighting_capacity, level);
    };
    typedef repo_t<cave_t> repo_cave_t;

    
    //十二宫掉落表
    struct zodiac_drop_t
    {
        int32_t lv;
        int32_t exp;
        int32_t coin;
        vector<vector<int32_t>> drop1;
        vector<vector<int32_t>> drop2;
        vector<vector<int32_t>> drop3;
        vector<vector<int32_t>> drop4;
        vector<vector<int32_t>> drop5;
        vector<vector<int32_t>> drop6;
        vector<vector<int32_t>> drop7;
        vector<vector<int32_t>> drop8;
        vector<vector<int32_t>> drop9;
        vector<vector<int32_t>> drop10;
        vector<vector<int32_t>> drop11;
        vector<vector<int32_t>> drop12;
        vector<vector<int32_t>> drop13;
        vector<vector<int32_t>> drop14;
        vector<vector<int32_t>> drop15;
        vector<vector<int32_t>> drop16;
        vector<vector<int32_t>> drop17;
        JSON20(zodiac_drop_t,lv,exp,coin,drop1,drop2,drop3,drop4,drop5,drop6,drop7,drop8,drop9,drop10,drop11,drop12,drop13,drop14,drop15,drop16,drop17);
    };
    typedef repo_t<zodiac_drop_t> repo_zodiac_drop_t;

    //关卡组表
    struct round_group_t
    {
        int32_t id;
        vector<int32_t> scene_id;
        int32_t get_min_round()
        {
            int32_t min = 999999;
            auto it=scene_id.begin();
            if( it == scene_id.end() )
                return -1;
            ++it;
            while(it!=scene_id.end())
            {
                if( min > *it )
                    min = *it;
                ++it;
            }
            return min;
        }
        int32_t get_max_round()
        {
            int32_t max = -1;
            auto it=scene_id.begin();
            if( it == scene_id.end() )
                return -1;
            ++it;
            while(it!=scene_id.end())
            {
                if( max < *it )
                    max = *it;
                ++it;
            }
            return max;
        }
        JSON2(round_group_t, id, scene_id)
    };
    typedef repo_t<round_group_t> repo_rdgp_t;
    
    //升级表
    struct levelup_t
    {
        int32_t level;
        int32_t exp;
        int32_t offline_exp_bonus;
        int32_t alchemy_money;
        int32_t energy;
        JSON5(levelup_t, level, exp, offline_exp_bonus, alchemy_money, energy)
    };
    typedef repo_t<levelup_t> repo_lvup_t;

    //炼金倍数表
    struct alchemy_money_t
    {
        int32_t vip_level;
        vector<int32_t> times;
        vector<int32_t> probability;
        JSON3(alchemy_money_t, vip_level, times, probability)
    };
    typedef repo_t<alchemy_money_t> repo_alchemy_money_t;

    //刷新精英关卡元宝表
    struct flush_round_t
    {
        int32_t times;
        int32_t money;
        JSON2(flush_round_t, times, money)
    };
    typedef repo_t<flush_round_t> repo_flsrd_t;

    //vip等级配置
    struct vip_t
    {
        int32_t vip_level;
        int32_t pay;
        int32_t buy_power;
        int32_t power_limit;
        int32_t reset_elite;
        int32_t buy_ladder;
        int32_t buy_train;
        int32_t reset_zodiac;
        int32_t reset_trial;
        int32_t summon_rune;
        int32_t buy_coin;
        int32_t reset_mission;
        int32_t refresh_star;
        int32_t reset_miku;
        int32_t reset_golden_box;
        int32_t reset_silver_box;
        int32_t item1;
        int32_t pro1;
        int32_t item2;
        int32_t pro2;
        JSON20(vip_t,vip_level,pay,buy_power,power_limit,reset_elite,buy_ladder,buy_train,reset_zodiac,reset_trial,summon_rune,buy_coin, reset_mission, refresh_star, reset_miku,item1, pro1, item2, pro2, reset_golden_box, reset_silver_box)
    };
    typedef repo_t<vip_t> repo_vip_t;

    //装备强化表
    struct equip_upgrade_t
    {
        int type;
        int value;

        JSON2(equip_upgrade_t, type, value)
    };
    typedef repo_t<equip_upgrade_t> repo_equip_up_t;

    //装备强化付费表
    struct equip_upgrade_pay_t
    {
        int strength_lv;
        int money;
        JSON2(equip_upgrade_pay_t, strength_lv, money)
    };
    typedef repo_t<equip_upgrade_pay_t> repo_equip_up_pay_t;

    //装备合成表
    struct equip_compose_t
    {
        int id;
        int rankup_id;
        int stuff_1;
        int stuff_1_num;
        int stuff_2;
        int stuff_2_num;
        int stuff_3;
        int stuff_3_num;
        int stuff_4;
        int stuff_4_num;
        JSON10(equip_compose_t, id, rankup_id, stuff_1, stuff_1_num, stuff_2, stuff_2_num, stuff_3, stuff_3_num, stuff_4, stuff_4_num)
    };
    typedef repo_t<equip_compose_t> repo_equip_compose_t;

    //装备槽开启表
    struct equip_slot_t
    {
        int id;
        int openlv;
        JSON2(equip_slot_t, id, openlv);
    };
    typedef repo_t<equip_slot_t> repo_equip_slot_t;

    //伙伴生阶属性
    struct qualityup_attr_t
    {
        int32_t id;
        int32_t quality;
        float rankup_atk;
        float rankup_mgc;
        float rankup_def;
        float rankup_res;
        float rankup_hp;
        float rankup_cri;
        float rankup_acc;
        float rankup_dodge;
        float rankup_tough;
        int32_t active1;
        int32_t active2;
        int32_t active3;
        int32_t passive1;
        int32_t passive2;
        int32_t passive3;
        int32_t talent1;
        int32_t talent2;
        JSON19(qualityup_attr_t, id, quality, rankup_atk, rankup_mgc, rankup_def, rankup_res, rankup_hp, rankup_cri, rankup_acc, rankup_dodge, rankup_tough, active1, active2, active3, passive1, passive2, passive3, talent1, talent2);
    };
    typedef repo_t<qualityup_attr_t> repo_qualityup_attr_t;

    //伙伴生阶材料
    struct qualityup_staff_t
    {
        int32_t quality; 
        int32_t var1;
        int32_t var2;
        int32_t var3;
        JSON4(qualityup_staff_t, quality ,var1, var2, var3)
    };
    typedef repo_t<qualityup_staff_t> repo_qualityup_staff_t;

    //宝石表
    struct gemstone_t
    {
        int32_t         id;
        int32_t         attribute;
        int32_t         level;
        int32_t         value;
        int32_t         safestone_id;
        int32_t         safestone_shopid;
        JSON6(gemstone_t, id, attribute, level, value, safestone_id, safestone_shopid)
    };
    typedef repo_t<gemstone_t> repo_gemstone_t;

    //宝石合成表
    struct gemstone_compose_t
    {
        int32_t level;
        int32_t prob;
        JSON2(gemstone_compose_t, level, prob)
    };
    typedef repo_t<gemstone_compose_t> repo_gemstone_compose_t;

    //宝石镶嵌表
    struct gemstone_part_t
    {
        int32_t position; 
        vector<int32_t> attribute;
        JSON2(gemstone_part_t, position, attribute)
    };
    typedef repo_t<gemstone_part_t> repo_gemstone_part_t;

    //酒馆刷新伙伴概率表
    struct pub_t
    {
        int32_t rare;
        vector<int32_t> level;
        int32_t hpay_probability;
        int32_t hpay_rate;
        vector<int32_t> hpay_number;
        int32_t pay_probability;
        int32_t pay_rate;
        vector<int32_t> pay_number;
        int32_t lpay_probability;
        int32_t lpay_rate;
        vector<int32_t> lpay_number;
        //int32_t quality;
        JSON11(pub_t, rare, level, hpay_probability, hpay_rate, hpay_number, pay_probability, pay_rate, pay_number, lpay_probability, lpay_rate, lpay_number)
    };
    typedef repo_t<pub_t> repo_pub_t;

    //限时英雄碎片
    struct gold_chip_t
    {
        int32_t id;
        vector<int32_t> limited_hero_piece;
        vector<int32_t> limited_hero_number;
        JSON3(gold_chip_t,id,limited_hero_piece,limited_hero_number);
    };
    typedef repo_t<gold_chip_t> repo_gold_chip_t;

    //队伍开启
    struct team_t
    {
        int32_t position;
        int32_t level;
        JSON2(team_t, position, level);
    };
    typedef repo_t<team_t> repo_team_t;

    //星魂数值表
    struct star_t
    {
        int32_t id;
        int32_t min_atk;
        int32_t max_atk;
        int32_t min_mgc;
        int32_t max_mgc;
        int32_t min_def;
        int32_t max_def;
        int32_t min_res;
        int32_t max_res;
        int32_t min_hp;
        int32_t max_hp;
        JSON11(star_t,id,min_atk,max_atk,min_mgc,max_mgc,min_def,max_def,min_res,max_res,min_hp,max_hp);
    };
    typedef repo_t<star_t> repo_star_t;

    //星魂概率表
    struct star_prob_t
    {
        int32_t id;
        vector<int32_t> potential;
        int32_t probability;
        JSON3(star_prob_t,id,potential,probability);
    };
    typedef repo_t<star_prob_t> repo_star_prob_t;

    //等级礼包
    struct level_reward_t
    {
        int32_t level;
        int32_t item1;
        int32_t count1;
        int32_t item2;
        int32_t count2;
        int32_t item3;
        int32_t count3;
        int32_t item4;
        int32_t count4;
        int32_t item5;
        int32_t count5;
        JSON11(level_reward_t,level,item1,count1,item2,count2,item3,count3,item4,count4,item5,count5);
    };
    typedef repo_t<level_reward_t> repo_level_reward_t;

    //试炼任务概率
    struct trial_t
    {
        int32_t id;
        int32_t probab;
        JSON2(trial_t, id, probab);
    };
    typedef repo_t<trial_t> repo_trial_t;

    //91删测首次登录奖励
    struct first_lgrw_t
    {
        int32_t item1;
        int32_t count1;
        JSON2(first_lgrw_t,item1,count1);
    };
    typedef repo_t<first_lgrw_t> repo_first_lgrw_t;

    //试炼奖励
    struct trial_reward_t
    {
        int32_t id;
        int32_t bpt;
        // [ [17101,1250],[17201,1250],[17301,1250] ]
        vector< vector<int32_t> > item_pro;
        JSON3(trial_reward_t, id, bpt, item_pro)
    };
    typedef repo_t<trial_reward_t> repo_trial_reward_t;

    //竞技场排名奖励
    struct arena_reward_t
    {
        int32_t rank;
        int32_t honor_win;
        vector<vector<int32_t>> item;
        JSON3(arena_reward_t, rank, honor_win, item)
    };
    typedef repo_t<arena_reward_t> repo_arena_reward_t;

    struct in_arena_reward_t
    {
        int32_t rank;
        int32_t honor_win;
        vector<vector<int32_t>> item;
        JSON3(in_arena_reward_t, rank, honor_win, item)
    };
    typedef repo_t<in_arena_reward_t> repo_in_arena_reward_t;

    //技能升级
    struct skill_upgrade_t
    {
        int32_t lv;
        int32_t btp;
        JSON2(skill_upgrade_t, lv, btp)
    };
    typedef repo_t<skill_upgrade_t> repo_skill_upgrade_t;

    //技能升阶
    struct skill_compose_t
    {
        int32_t skillid;
        int32_t consume;
        JSON2(skill_compose_t, skillid,consume)
    };
    typedef repo_t<skill_compose_t> repo_skill_compose_t;

/*    //技能表
    struct skill_t
    {
        int32_t id;
        int32_t skill_property;
        int32_t skill_class;
        int32_t skill_type;
        int32_t next_skill;
        int32_t next_skill_drawing;

        float spell_time;
        int area;

        int target;
        int target_type;
        int spread_area;
        int spread_area_type;
        int spread_num;
        int buffid;

        int target2;
        int target_type2;
        int spread_area2;
        int spread_area_type2;
        int spread_num2;
        int buffid2;

        int open_btp;

        int first_spell;
        int loop_spell;

        JSON23(skill_t, id, skill_property, skill_class, skill_type, next_skill, next_skill_drawing, spell_time, area, target, target_type, spread_area, spread_area_type, spread_num, buffid, 
            target2, target_type2, spread_area2, spread_area_type2, spread_num2, buffid2, open_btp,first_spell,loop_spell)
    };
    typedef repo_t<skill_t> repo_skill_t;
*/
/**/    struct skill_t
    {
        int32_t id;
        float skill_accuaracy;
        int32_t skill_property;
        int32_t skill_class;
        int32_t next_skill;
        int32_t next_skill_drawing;
        float spell_time;
        int open_btp;

        vector<int> combo_cause;
        int32_t combo_result;
        int32_t combo_num;
        int32_t combo_maxnum;
        //int32_t combo_numneed;
        int32_t skill_type;
        int32_t is_halo;
        int32_t first_spell;
        int32_t loop_spell;
        //target select function
        int32_t target;
        int32_t target_type;
        int32_t spread_area;
        int32_t spread_area_type;
        int32_t target_func;
        int32_t spread_num;
        int32_t target2;
        int32_t target_type2;
        int32_t spread_area2;
        int32_t spread_area_type2;
        int32_t target_func2;
        int32_t spread_num2;
        //buff
        int32_t probability;
        vector<vector<float>> buff_data1;
        vector<vector<float>> buff_data2;
        float skill_factor;

        int32_t area; // 临时 其实没啥用 要改pvp的

        JSON33(skill_t, id, skill_accuaracy, skill_property, skill_class, next_skill, next_skill_drawing, spell_time, open_btp, combo_cause, combo_result, combo_num, combo_maxnum, skill_type, is_halo, first_spell, loop_spell, target, target_type, spread_area, spread_area_type, target_func, spread_num, target2, target_type2, spread_area2, spread_area_type2, target_func2, spread_num2, probability, buff_data1, buff_data2, skill_factor, area)
    };
    typedef repo_t<skill_t> repo_skill_t;
/**/
    //活动时间配置
    struct activity_time_t
    {
        int32_t id;
        int32_t sort;
        string start;
        string end;
        JSON4(activity_time_t,id,sort,start,end);
    };
    typedef repo_t<activity_time_t> repo_activity_time_t;

    //潜力概率表
    struct potential_upgrade_t
    {
        int32_t lv;
        vector<int32_t> normal_success_rate;
        vector<int32_t> super_success_rate;
        JSON3(potential_upgrade_t, lv, normal_success_rate, super_success_rate)
    };
    typedef repo_t<potential_upgrade_t> repo_potential_upgrade_t;

    //序列号奖励表
    struct cdkey_reward_t
    {
        int32_t id;
        vector<vector<int> > item;
        JSON2(cdkey_reward_t,id,item);
    };
    typedef repo_t<cdkey_reward_t> repo_cdkey_reward_t;

    //潜力上限表
    struct potential_caps_t
    {
        int32_t level;
        int32_t caps;
        JSON2(potential_caps_t, level, caps)
    };
    typedef repo_t<potential_caps_t> repo_potential_caps_t;

    //潜力表
    struct potential_t
    {
        int32_t id;
        int32_t job;
        int32_t attribute;
        int32_t value;
        int32_t consume;
        JSON5(potential_t, id, job, attribute, value, consume)
    };
    typedef repo_t<potential_t> repo_potential_t;

/*    //世界boss
    struct worldboss_t
    {
        int32_t lv;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        uint64_t hp;
        int32_t critical;
        int32_t accuracy;
        int32_t dodge;
        int32_t skill_lv;
        int32_t gold_kill;
        int32_t gold_join;
        int32_t gold_rank1;
        int32_t gold_rank2;
        int32_t gold_rank3;
        int32_t gold_rank4;
        int32_t gold_rank11;
        int32_t btp_kill;
        int32_t btp_join;
        int32_t btp_rank1;
        int32_t btp_rank2;
        int32_t btp_rank3;
        int32_t btp_rank4;
        int32_t btp_rank11;
        vector<int32_t> item_kill;
        vector<int32_t> item_join;
        vector<int32_t> item_rank;
        JSON27(worldboss_t, lv,atk,mgc,def,res, hp,critical,accuracy,dodge,skill_lv,gold_kill,gold_join,gold_rank1,gold_rank2,gold_rank3,gold_rank4,gold_rank11,btp_kill,btp_join,btp_rank1,btp_rank2,btp_rank3,btp_rank4,btp_rank11,item_kill,item_join,item_rank)
    };
    typedef repo_t<worldboss_t> repo_worldboss_t;
*/
    //世界boss
    struct worldboss_t
    {
        int32_t lv;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        uint64_t hp;
        int32_t critical;
        int32_t accuracy;
        int32_t dodge;
        int32_t skill_lv;
        vector<int32_t> gold_kill;
        int32_t gold_join;
        int32_t gold_rank1;
        int32_t gold_rank2;
        int32_t gold_rank3;
        int32_t gold_rank4;
        int32_t gold_rank5;
        int32_t gold_rank6;
        int32_t gold_rank7;
        float total_power;
        vector<int32_t> item_kill;
        int32_t item_join;
        vector<int32_t> item_rank;
        JSON23(worldboss_t, lv,atk,mgc,def,res, hp,critical,accuracy,dodge,skill_lv,gold_kill,gold_join,gold_rank1,gold_rank2,gold_rank3,gold_rank4,gold_rank5,gold_rank6,gold_rank7,total_power,item_kill,item_join,item_rank)
    };
    typedef repo_t<worldboss_t> repo_worldboss_t;

    //公会boss
    struct unionboss_t
    {
        int32_t bosslv;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        uint64_t hp;
        int32_t critical;
        int32_t accuracy;
        int32_t dodge;
        vector<int32_t> gold_kill;
        int32_t join_coin;
        int32_t champion_coin;
        int32_t second_coin;
        int32_t third_coin;
        int32_t topten_coin;
        int32_t all_coin;
        float total_power;
        vector<int32_t> item_kill;
        int32_t item_join;
        vector<int32_t> item_rank;
        JSON20(unionboss_t, bosslv, atk, mgc, def, res, hp, critical, accuracy, dodge, gold_kill, join_coin, champion_coin, second_coin, third_coin, topten_coin, all_coin, total_power, item_kill, item_join, item_rank)
    };
    typedef repo_t<unionboss_t> repo_unionboss_t;

    //boss奖励
    struct boss_reward_t
    {
        int32_t id;
        vector<vector<int32_t>> reward_item;
        JSON2(boss_reward_t,id,reward_item)
    };
    typedef repo_t<boss_reward_t> repo_boss_reward_t;

    //boss奖励
    struct unionboss_reward_t
    {
        int32_t id;
        vector<vector<int32_t>> reward_item;
        JSON2(unionboss_reward_t,id,reward_item)
    };
    typedef repo_t<unionboss_reward_t> repo_unionboss_reward_t;

    //怪物表
    struct monster_t
    {
        int32_t id;
        int32_t job;
        int32_t skill;
        JSON3(monster_t,id,job,skill)
    };
    typedef repo_t<monster_t> repo_monster_t;

    //技能效果
    struct skill_effect_t
    {
        int id;
        float var1;
        float var2;
        JSON3(skill_effect_t, id, var1, var2)
    };
    typedef repo_t<skill_effect_t> repo_skill_effect_t;

    struct role_fight_t
    {
        int     id;
        int     job;
        float   actiontime;
        float   skill_cancel_time;
        int     width;
        int     height;
        int     speed;
        float   hit_rate;
        float   atk_power;
        float   hit_power;
        float   kill_power;
        JSON11(role_fight_t, id, job, actiontime, skill_cancel_time, width, height, speed, hit_rate, atk_power, hit_power, kill_power)
    };
    typedef repo_t<role_fight_t> repo_role_fight_t;

/*    struct buff_t
    {
        int id;
        int buff_type;
        int prop_type1;
        float prop_value1;
        int prop_type2;
        float prop_value2;
        int state_type;
        float state_value;
        int effect_times;
        float last_time; 

        JSON10(buff_t, id, buff_type, prop_type1, prop_value1, prop_type2, prop_value2, state_type, state_value, effect_times, last_time)
    };
    typedef repo_t<buff_t> repo_buff_t;
*/
/**/    struct buff_t
    {
        int id;
        string id_level;
        int buff_symbol;
        int buff_type;
        int prop_type1;
        int affect_method1;
        float prop_value1;
        int prop_type2;
        int affect_method2;
        float prop_value2;
        int state_type;
        float state_value;
        int effect_times;
        float last_time;
        JSON14(buff_t, id, id_level, buff_symbol, buff_type, prop_type1, affect_method1, prop_value1, prop_type2, affect_method2, prop_value2, state_type, state_value, effect_times, last_time)
    };
    typedef repo_t<buff_t> repo_buff_t;
/**/
    struct pack_t
    {
        int         id;
        vector<int> item1;
        int         pro1;
        int         count1;
        vector<int> item2;
        int         pro2;
        int         count2;
        vector<int> item3;
        int         pro3;
        int         count3;
        vector<int> item4;
        int         pro4;
        int         count4;
        vector<int> item5;
        int         pro5;
        int         count5;

        JSON16(pack_t, id, item1, pro1, count1, item2, pro2, count2, item3, pro3, count3,
                item4, pro4, count4, item5, pro5, count5)
    };
    typedef repo_t<pack_t> repo_pack_t;

    struct practice_t
    {
        int32_t lv;
        int32_t exp;
        JSON2(practice_t, lv, exp);
    };
    typedef repo_t<practice_t> repo_practice_t;

    struct quest_t
    {
        int id;
        int level;
        //int mainline;
        int task_class;
        //int pre_quest;
        //int quest_get;
        int type;
        vector<int> value;
        int exp;
        int coin;
        int diamond;
        vector<vector<int> > item_id;
        JSON9(quest_t, id, level, task_class, type, value, exp, coin, diamond, item_id)
    };
    typedef repo_t<quest_t> repo_quest_t;

    struct quest_daily_t
    {
        int id;
        int times;
        int openlv;
        //int active;
        int power;
        int coin;
        int diamond;
        int exp;
        vector<vector<int>> reward;
        JSON8(quest_daily_t, id, times, openlv, power, coin, diamond, exp, reward)
    };
    typedef repo_t<quest_daily_t> repo_quest_daily_t;
    
    struct achievement_t
    {
        int id;
        int times;
        int openlv;
        int sort;
        //int active;
        int typeindex;
        int taskindex;
        int power;
        int coin;
        int diamond;
        int exp;
        vector<vector<int>> reward;
        JSON11(achievement_t, id, sort,typeindex, taskindex, times, openlv, power, coin, diamond, exp, reward)
    };
    typedef repo_t<achievement_t> repo_achievement_t;

    struct lmt_event_t
    {
        int id;
        string start_time;
        string end_time;
        JSON3(lmt_event_t, id, start_time, end_time)
    };

    typedef repo_t<lmt_event_t> repo_lmt_event_t;
    
    struct lmt_double_t
    {
        int id;
        string start_time;
        string end_time;
        JSON3(lmt_double_t,id,start_time,end_time)
    };
    typedef repo_t<lmt_double_t> repo_lmt_double_t;


    
    struct lmt_reward_t
    {
        int id;
        string name;
        int value;
        string description;
        vector<vector<int>> reward;
        JSON5(lmt_reward_t, id, name, value, description, reward)
    };

    typedef repo_t<lmt_reward_t> repo_lmt_reward_t;

    struct lmt_gift_t
    {
        int id;
        string name;
        int value;
        string description;
        vector<vector<int>> reward;
        int32_t value2;
        int32_t times;
        JSON7(lmt_gift_t, id, name, value, description, reward, value2, times)
    };

    typedef repo_t<lmt_gift_t> repo_lmt_gift_t;

    struct weekly_t
    {
        int id;
        string name;
        string description;
        vector<int> VIP;
        vector<vector<int>> reward;
        JSON5(weekly_t, id, name, description, VIP, reward)
    };

    typedef repo_t<weekly_t> repo_weekly_t;
/*
    struct quest_daily_reward_t
    {
        int id;
        int active;
        int reward1;
        int reward1_count;
        int reward2;
        int reward2_count;
        int reward3;
        int reward3_count;
        JSON8(quest_daily_reward_t, id, active, reward1, reward1_count, reward2, reward2_count, reward3, reward3_count)
    };
    typedef repo_t<quest_daily_reward_t> repo_quest_daily_reward_t;
*/
    struct chronicle_t
    {
        uint32_t id;
        string name;
        string background;
        vector<int32_t> source_ids;
        vector<int32_t> source_condition;
        string begin_date;
        string end_date;
        JSON7(chronicle_t, id, name, background, source_ids, source_condition, begin_date, end_date)
    };
    typedef repo_t<chronicle_t> repo_chronicle_t;

    struct chronicle_story_t
    {
        uint32_t id;
        uint32_t day;
        string pre_story;
        string finish_story;
        uint32_t plot_id;
        vector<vector<int32_t>> item_ids;
        JSON6(chronicle_story_t, id, day, pre_story, finish_story, plot_id, item_ids)
    };
    typedef repo_t<chronicle_story_t> repo_chronicle_story_t;

    struct npc_t
    {
        int id;
        int city_id;
        JSON2(npc_t, id, city_id)
    };
    typedef repo_t<npc_t> repo_npc_t;

    struct rune_t
    {
        int32_t id;
        int32_t type;
        int32_t quality;
        int32_t level;
        int32_t attribute;
        float value;
        int32_t exp;
        int32_t base_exp;
        int32_t stuff;
        int32_t rare;
        JSON10(rune_t,id,type,quality,level,attribute,value,exp,base_exp,stuff,rare);
    };
    typedef repo_t<rune_t> repo_rune_t;
    
    struct rune_prob_t
    {
        int32_t id;
        vector<int32_t> drop;
        vector<int32_t> lvup;
        int32_t cost;
        JSON4(rune_prob_t,id,drop,lvup,cost);
    };
    typedef repo_t<rune_prob_t> repo_rune_prob_t;

    struct scuffle_rank_t
    {
        vector<int32_t> ranking;
        vector<vector<int32_t>> reward;
        JSON2(scuffle_rank_t,ranking,reward);
    };
    typedef repo_t<scuffle_rank_t> repo_scuffle_rank_t;

    struct scuffle_last_t
    {
        int32_t id;
        int32_t reward;
        JSON2(scuffle_last_t,id,reward);
    };
    typedef repo_t<scuffle_last_t> repo_scuffle_last_t;

    struct guild_t
    {
        int guildlv;
        int member;
        int exp;
        int data;
        JSON4(guild_t, guildlv, member, exp, data)
    };
    typedef repo_t<guild_t> repo_guild_t;

    struct guildboss_open_t
    {
        int id;
        vector<vector<int>> cost;
        int guild_lv;
        JSON3(guildboss_open_t, id, cost, guild_lv)
    };
    typedef repo_t<guildboss_open_t> repo_guildboss_open_t;

    struct guildskill_t
    {
        int keyid;
        int id;
        int level;
        int type;
        int value;
        int unlock_guildlv;
        int cost;
        JSON7(guildskill_t, keyid, id, level, type, value, unlock_guildlv, cost)
    };
    typedef repo_t<guildskill_t> repo_guildskill_t;

    struct guildskill_cost_t
    {
        int skilllv;
        vector<int> type_one;
        int cost_one;
        vector<int> type_two;
        int cost_two;

        JSON5(guildskill_cost_t, skilllv, type_one, cost_one, type_two, cost_two)
    };
    typedef repo_t<guildskill_cost_t> repo_guildskill_cost_t;

    struct altar_t 
    {
        int item;
        int prob;
        int quantity;
        int location;
        JSON4(altar_t, item, prob, quantity, location)
    };
    typedef repo_t<altar_t> repo_altar_t;

    struct shop_t
    {
        int id;
        int item_id;
        string name;
        int sheet;
        int money_type;
        int price;
        int ishot;
        int isnew;
        int islimited;
        int hide;
        int discount;
        int imt;
        int time;
        JSON13(shop_t, id, item_id, name,sheet, money_type, price, ishot, isnew, islimited, hide, discount, imt, time)
    };
    typedef repo_t<shop_t> repo_shop_t;

    struct npc_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int item_num;
        int probability;
        JSON8(npc_shop_t, id, item_id, name, money_type, price, islimited, item_num, probability)
    };    
    typedef repo_t<npc_shop_t> repo_npc_shop_t;
    
    struct special_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int item_num;
        int probability;
        JSON8(special_shop_t, id, item_id, name, money_type, price, islimited, item_num, probability)
    };    
    typedef repo_t<special_shop_t> repo_special_shop_t;
    
    struct daily_sign_t
    {
        int32_t         id;
        int32_t         data;
        int32_t         day;
        vector<int32_t> reward;
        int32_t         vip_level;
        int32_t         times;
        JSON6(daily_sign_t, id, data, day, reward, vip_level, times)
    };
    typedef repo_t<daily_sign_t> repo_daily_sign_t;

    struct vip_open_t
    {
        int id;
        int viplv;
        JSON2(vip_open_t, id, viplv)
    };
    typedef repo_t<vip_open_t> repo_vip_open_t;

    struct fp_reward_t
    {
        int id;
        int fp;
        int item1;
        int count1;
        int item2;
        int count2;
        int item3;
        int count3;
        int item4;
        int count4;
        int item5;
        int count5;
        JSON12(fp_reward_t,id,fp,item1,count1,item2,count2,item3,count3,item4,count4,item5,count5);
    };
    typedef repo_t<fp_reward_t> repo_fp_reward_t;

    struct acc_yb_t
    {
        int id;
        int recharge;
        int item1;
        int count1;
        int item2;
        int count2;
        int item3;
        int count3;
        int heroid;
        JSON9(acc_yb_t,id,recharge,item1,count1,item2,count2,item3,count3,heroid);
    };
    typedef repo_t<acc_yb_t> repo_acc_yb_t;

    struct acc_login_t
    {
        int id;
        int month;
        int login_accumulative;
        int item;
        int count;
        int heroid;
        JSON6(acc_login_t, id, month, login_accumulative, item, count, heroid);
    };
    typedef repo_t<acc_login_t> repo_acc_login_t;

    struct sign_reward_t
    {
        int32_t id;
        int32_t item1;
        int32_t count1;
        int32_t item2;
        int32_t count2;
        int32_t item3;
        int32_t count3;
        JSON7(sign_reward_t,id,item1,count1,item2,count2,item3,count3);
    };
    typedef repo_t<sign_reward_t> repo_sign_reward_t;

    struct con_login_t
    {
        int login_count;
        int item1;
        int count1;
        int item2;
        int count2;
        int heroid;
        JSON6(con_login_t,login_count,item1,count1,item2,count2,heroid);
    };
    typedef repo_t<con_login_t> repo_con_login_t;

    struct newly_reward_t
    {
        int id;
        string name;
        int value;
        vector<vector<int>> reward;
        JSON4(newly_reward_t, id, name, value, reward);
    };
    typedef repo_t<newly_reward_t> repo_newly_reward_t;
    
    struct growup_reward_t
    {
        int id;
        int level;
        vector<vector<int>> reward;
        JSON3(growup_reward_t, id, level, reward);
    };
    typedef repo_t<growup_reward_t> repo_growup_reward_t;

    struct mail_format_t
    {
        int id;
        string title;
        string sender;
        string format;
        int validtime;
        JSON5(mail_format_t, id, title, sender, format, validtime)
    };
    typedef repo_t<mail_format_t> repo_mail_format_t;

    struct pay_t
    {
        int id;
        int cristal;
        int rmb;
        int first_reward;
        float ratio;

        JSON5(pay_t, id, cristal, rmb, first_reward, ratio)
    };
    typedef repo_t<pay_t> repo_pay_t;

    struct apppay_t:pay_t
    {
        int id;
        int cristal;
        int rmb;
        int first_reward;
        float ratio;

        JSON5(apppay_t, id, cristal, rmb, first_reward, ratio)
    };
    typedef repo_t<apppay_t> repo_apppay_t;

    struct cumu_consume_t
    {
        int32_t id;
        int32_t consumption;
        int32_t item1;
        int32_t count1;
        int32_t item2;
        int32_t count2;
        int32_t item3;
        int32_t count3;
        int32_t day;
        JSON9(cumu_consume_t,id,consumption,item1,count1,item2,count2,item3,count3,day);
    };
    typedef repo_t<cumu_consume_t> repo_cumu_consume_t;

    struct daily_pay_t 
    {
        int32_t id;
        int32_t rmb;
        vector<vector<int>> item;
        JSON3(daily_pay_t,id,rmb,item)
    };
    typedef repo_t<daily_pay_t> repo_daily_pay_t;

    struct online_t
    {
        int id;
        int time;
        vector<vector<int>> reward;

        JSON3(online_t, id, time, reward)
    };
    typedef repo_t<online_t> repo_online_t;

    struct maquee_t
    {
        int id;
        string tip;
        JSON2(maquee_t,id ,tip);
    };
    typedef repo_t<maquee_t> repo_maquee_t;

    struct treasure_t
    {
        int id;
        int openid;
        int gold;
        int gold_minute;
        int gold_1hour;
        int gold_2hour;
        int gold_3hour;
        int gold_4hour;
        int level;
        vector<vector<int>> treasure_drop;
        vector<vector<int>> first_drop;
        JSON11(treasure_t,id,openid,gold,gold_minute,gold_1hour,gold_2hour,gold_3hour,gold_4hour, level, treasure_drop, first_drop);
    };
    typedef repo_t<treasure_t> repo_treasure_t;

    struct backpack_t
    {
        int id;
        int num;
        int rmb;
        JSON3(backpack_t, id, num, rmb)
    };
    typedef repo_t<backpack_t> repo_backpack_t;

    struct city_boss_t
    {
        int id;
        vector<int> level;
        vector<int> monster;
        JSON3(city_boss_t, id, level, monster)
    };
    typedef repo_t<city_boss_t> repo_city_boss_t;

    struct city_boss_pos_t
    {
        int id;
        int x;
        int y;
        JSON3(city_boss_pos_t, id, x, y)
    };
    typedef repo_t<city_boss_pos_t> repo_city_boss_pos_t;

    struct city_boss_drop_t
    {
        int drop_level;
        vector<vector<int>> item_drop;
        JSON2(city_boss_drop_t, drop_level, item_drop)
    };
    typedef repo_t<city_boss_drop_t> repo_city_boss_drop_t;

    struct pushinfo_t
    {
        int id;
        string info;
        JSON2(pushinfo_t, id, info)
    };
    typedef repo_t<pushinfo_t> repo_pushinfo_t;

    struct starreward_t
    {
        int id;
        vector<vector<int>> count1;
        vector<vector<int>> count2;
        vector<vector<int>> count3;
        vector<vector<int>> count4;
        JSON5(starreward_t, id, count1, count2, count3, count4)
    };
    typedef repo_t<starreward_t> repo_starreward_t;

    struct robot_conf_t
    {
        int id;
        vector<int> rank;
        int level;
        int number; //英雄数量
        vector<int> item_pro; //英雄resid数组
        JSON5(robot_conf_t, id, rank, level, number, item_pro)
    };
    typedef repo_t<robot_conf_t> repo_robot_conf_t;

    struct salary_t
    {
        int id;
        vector<int> rank;
        int meritorious;
        int honor_win;
        JSON4(salary_t, id, rank, meritorious, honor_win)
    };
    typedef repo_t<salary_t> repo_salary_t;

    struct insalary_t
    {
        int id;
        vector<int> rank;
        int meritorious;
        int honor_win;
        JSON4(insalary_t, id, rank, meritorious, honor_win)
    };
    typedef repo_t<insalary_t> repo_insalary_t;

    struct titleup_t
    {
        int id;
        int meritorious;
        string name;
        vector<int32_t> reward;
        JSON4(titleup_t, id, meritorious, name, reward)
    };
    typedef repo_t<titleup_t> repo_titleup_t;

    struct prestige_shop_t
    {
        int id;
        vector<int32_t> item;
        string name;
        int price;
        int isnew;
        int islimited;
        int hide;
        JSON7(prestige_shop_t, id, item, name, price, isnew, islimited, hide)
    };
    typedef repo_t<prestige_shop_t> repo_prestige_shop_t;

    struct unprestige_shop_t
    {
        int id;
        vector<int32_t> item;
        string name;
        int price;
        int isnew;
        int islimited;
        int hide;
        JSON7(unprestige_shop_t, id, item, name, price, isnew, islimited, hide)
    };
    typedef repo_t<unprestige_shop_t> repo_unprestige_shop_t;


    struct chip_shop_t
    {
        int id;
        int item;
        string name;
        int ishot;
        int islimited;
        int hide;
        JSON6(chip_shop_t, id, item, name, ishot, islimited, hide)
    };
    typedef repo_t<chip_shop_t> repo_chip_shop_t;
    struct chip_smash_t
    {
        int item_id;
        string name;
        int base_value;
        int max_value;
        int min_value;
        float income_rate;
        int cost;
        int islimit;
        JSON8(chip_smash_t, item_id, name, base_value, max_value, min_value, income_rate, cost, islimit)
    };
    typedef repo_t<chip_smash_t> repo_chip_smash_t;

    struct box_t
    {
        int id;
        int item1;
        int pro1;
        int num;
        int boxid;
        JSON5(box_t, id, item1, pro1, num, boxid)
    };
    typedef repo_t<box_t> repo_box_t;

    struct drug_t
    {
        int id;
        int num;
        int type;
        JSON3(drug_t, id, num, type);
    };
    typedef repo_t<drug_t> repo_drug_t;

    //天赋表
    struct tskill_t
    {
        int32_t id;
        int32_t next_skill;
        int type1;
        float value1;
        float base1;
        int type2;
        float value2;
        float base2;
        int quality;
        int32_t next_skill_drawing;

        JSON10(tskill_t, id, next_skill, type1, value1, base1, type2, value2, base2, quality, next_skill_drawing)
    };
    typedef repo_t<tskill_t> repo_tskill_t;

    //英雄碎片表
    struct chip_t
    {
        int32_t id;
        int32_t actorid;
        int32_t soul;
        JSON3(chip_t, id, actorid,soul);
    };
    typedef repo_t<chip_t> repo_chip_t ;

    //命运
    struct destiny_t
    {
        int id;
        int hero1;
        int hero2;
        int hero3;
        int hero4;
        int hero5;
        int effect;
        float effect_value;

        JSON8(destiny_t, id, hero1, hero2, hero3, hero4, hero5, effect, effect_value)
    };
    typedef repo_t<destiny_t> repo_destiny_t;

    //buff互斥
    struct buff_reject_t
    {
        int buff_type;
        int reject;

        JSON2(buff_reject_t, buff_type, reject) 
    };
    typedef repo_t<buff_reject_t> repo_buff_reject_t;

    //活动配置
    struct activity_cfg_t
    {
        int                 hostnum;
        string              domain;
        vector<vector<int>> actives;
        JSON3(activity_cfg_t, hostnum, domain, actives)
    };
    typedef repo_t<activity_cfg_t> repo_activity_cfg_t;

    struct limited_round_data_t
    {
        int32_t             id;
        int32_t             exp;
        int32_t             power;
        vector<vector<int>> lmt_battle_drop;
        JSON4(limited_round_data_t, id, exp, power, lmt_battle_drop)
    };
    typedef repo_t<limited_round_data_t> repo_limited_round_data_t;

    struct vip_package_t
    {
        int vip_level;
        int item1;
        int count1;
        int item2;
        int count2;
        int item3;
        int count3;
        int item4;
        int count4;
        JSON9(vip_package_t, vip_level, item1, count1, item2, count2, item3, count3, item4, count4)
    };
    typedef repo_t<vip_package_t> repo_vip_package_t;

    struct wing_t
    {
        int id;
        int rare;
        string name;
        int type;
        vector<int> atk;
        vector<int> mgc;
        vector<int> def;
        vector<int> res;
        vector<int> hp;
        vector<int> acc;
        vector<int> crit;
        vector<int> dodge;
        float speed;
        vector<int> pro;
        int32_t split;
        JSON15(wing_t, id, rare, name, type, atk, mgc, def, res, hp, acc, crit, dodge, speed, pro, split)
    };
    typedef repo_t<wing_t> repo_wing_t;

    struct wing_compose_t
    {
        int id;
        string name;
        int former_equip;
        int stuff_1;
        int stuff_1_num;
        JSON5(wing_compose_t, id, name, former_equip, stuff_1, stuff_1_num)
    };
    typedef repo_t<wing_compose_t> repo_wing_compose_t;

    struct pet_t
    {
        int32_t id;
        vector<int32_t> atk;
        vector<int32_t> mgc;
        vector<int32_t> def;
        vector<int32_t> res;
        vector<int32_t> hp;
        JSON6(pet_t, id, atk, mgc, def, res, hp)
    };
    typedef repo_t<pet_t> repo_pet_t;

    struct pet_compose_t
    {
        int32_t id;
        int32_t next_resid;
        int32_t stuff_1;
        int32_t stuff_1_num;
        JSON4(pet_compose_t, id, next_resid, stuff_1, stuff_1_num)
    };
    typedef repo_t<pet_compose_t> repo_pet_compose_t;

    struct wing_act_t
    {
        int item;
        vector<int> genpro;
        int prob;
        int quantity;
        int location;
        JSON5(wing_act_t, item, genpro, prob, quantity, location)
    };
    typedef repo_t<wing_act_t> repo_wing_act_t;

    struct love_task_t
    {
        int id;
        int love_max;
        int love_type1;
        vector<int> value1;
        int love_type2;
        vector<int> value2;
        int love_type3;
        vector<int> value3;
        int love_reward_id;
        JSON9(love_task_t, id,love_max, love_type1, value1, love_type2, value2, love_type3, value3, love_reward_id)
    };
    typedef repo_t<love_task_t> repo_love_task_t;

    struct love_reward_t
    {
        int id;
        int level;
        float atk;
        float mgc;
        float def;
        float res;
        float hp;
        float gold_cost_decreased;
        JSON8(love_reward_t, id, level, atk, mgc, def, res, hp, gold_cost_decreased)
    };
    typedef repo_t<love_reward_t> repo_love_reward_t;

    struct boss_up_t
    {
        int id;
        float factor;
        uint32_t pro1;
        vector<int> range1;
        uint32_t pro2;
        vector<int> range2;
        JSON6(boss_up_t, id, factor, pro1, range1, pro2, range2)
    };
    typedef repo_t<boss_up_t> repo_boss_up_t;

    struct expedition_t
    {
        int id;
        int gold_drop;
        int expedition_coin;
        int lv_min;
        int lv_max;
        vector<int> drop;
        JSON6(expedition_t, id, gold_drop, expedition_coin, lv_min, lv_max, drop)
    };
    typedef repo_t<expedition_t> repo_expedition_t;

    struct expedition_box_t
    {
        int id;
        vector<int> level_range;
        vector<int> reward;
        int pro_1;
        int pro_2;
        JSON5(expedition_box_t, id, level_range, reward, pro_1, pro_2)
    };
    typedef repo_t<expedition_box_t> repo_expedition_box_t;

    struct expedition_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int item_num;
        int probability;
        JSON8(expedition_shop_t,id,item_id,name,money_type,price,islimited,item_num,probability)
    };
    typedef repo_t<expedition_shop_t> repo_expedition_shop_t;

    struct gang_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int item_num;
        int probability;
        JSON8(gang_shop_t,id,item_id,name,money_type,price,islimited,item_num,probability)
    };
    typedef repo_t<gang_shop_t> repo_gang_shop_t;

    struct rune_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int item_num;
        int probability;
        JSON8(rune_shop_t,id,item_id,name,money_type,price,islimited,item_num,probability)
    };
    typedef repo_t<rune_shop_t> repo_rune_shop_t;


    struct expedition_hero_piece_t
    {
        int id;
        vector<int> hero_piece1;
        vector<int> hero_piece2;
        vector<int> hero_piece3;
        JSON4(expedition_hero_piece_t, id, hero_piece1, hero_piece2, hero_piece3)
    };
    typedef repo_t<expedition_hero_piece_t> repo_expedition_hero_piece_t;

    struct recharge_frist_t
    {
        int id;
        int item1;
        int count1;
        int item2;
        int count2;
        int item3;
        int count3;
        int item4;
        int count4;
        int item5;
        int count5;
        int item6;
        int count6;
        int item7;
        int count7;
        int item8;
        int count8;
        int item9;
        int count9;
        JSON19(recharge_frist_t, id, item1, count1, item2, count2, item3, count3, item4, count4, item5, count5, item6, count6, item7, count7, item8, count8, item9, count9)
    };
    typedef repo_t<recharge_frist_t> repo_recharge_frist_t;

    struct friend_reward_t
    {
        int id;
        int friend_count;
        int lv;
        int reward;
        int count;
        int hero;
        JSON6(friend_reward_t, id, friend_count, lv, reward, count, hero)
    };
    typedef repo_t<friend_reward_t> repo_friend_reward_t;

    struct card_event_t
    {
        int id;
        int role_id;
        int item_id;
        string start_time;
        string end_time;
        string reset_time;
        JSON6(card_event_t, id, role_id, item_id, start_time, end_time, reset_time)
    };
    typedef repo_t<card_event_t> repo_card_event_t;

    struct card_event_point_t
    {
        int id;
        int event_id;
        int order;
        int goal_point;
        vector<vector<int>> reward;
        JSON5(card_event_point_t, id, event_id, order, goal_point, reward)
    };
    typedef repo_t<card_event_point_t> repo_card_event_point_t;

    struct card_event_ranking_t
    {
        int id;
        int event_id;
        int order;
        vector<int> ranking;
        vector<vector<int>> reward;
        JSON5(card_event_ranking_t, id, event_id, order, ranking, reward)
    };
    typedef repo_t<card_event_ranking_t> repo_card_event_ranking_t;

    struct card_event_round_t
    {
        int id;
        int point;
        float atk;
        float mgc;
        float def;
        float res;
        float hp;
        JSON7(card_event_round_t, id, point, atk, mgc, def, res, hp)
    };
    typedef repo_t<card_event_round_t> repo_card_event_round_t;

    struct card_event_reward_t
    {
        int id;
        int difficult;
        vector<vector<int>> reward;
        JSON3(card_event_reward_t, id, difficult, reward)
    };
    typedef repo_t<card_event_reward_t> repo_card_event_reward_t;

    struct card_event_difficult_t
    {
        int id;
        int max_round;
        string name;
        string name_1;
        float attribute;
        int open_cost;
        JSON6(card_event_difficult_t, id, max_round, name, name_1, attribute, open_cost)
    };
    typedef repo_t<card_event_difficult_t> repo_card_event_difficult_t;

    struct card_event_open_reward_t
    {
        int id;
        int times;
        vector<vector<int>> reward;
        JSON3(card_event_open_reward_t, id, times, reward)
    };
    typedef repo_t<card_event_open_reward_t> repo_card_event_open_reward_t;

    // 猎魂表
    struct soul_pursue_t
    {
        int32_t id;
        int32_t level;
        int32_t rare;
        vector<int32_t> suc_reward;
        vector<int32_t> fail_reward;
        int32_t suc_rara;
        float fail_rara;
        float invalid_rara;
        JSON8(soul_pursue_t, id, level, rare, suc_reward, fail_reward, suc_rara, fail_rara, invalid_rara)
    };
    typedef repo_t<soul_pursue_t> repo_soul_pursue_t;

    struct rank_season_t
    {
        int id;
        string name;
        int rankup_score;
        int win_score;
        int lose_score;
        int lose_count;
        int lose_rank;
        int win_rank;
        int next_season_rank;
        vector<vector<int>> rank_reward;
        vector<vector<int>> reward;
        int day_off;
        int day_score;
        JSON13(rank_season_t, id, name, rankup_score, win_score, lose_score, lose_count, lose_rank, win_rank, next_season_rank, rank_reward, reward, day_off, day_score)
    };
    typedef repo_t<rank_season_t> repo_rank_season_t;

    //策划配置表
    struct configure_t
    {
        int id;
        float value;
        JSON2(configure_t, id, value)
    };
    typedef repo_t<configure_t> repo_configure_t;

    //魂师配置表
    struct soulnode_t
    {
        int         id;
        int         rank;
        string      name;
        int         cost;
        vector<int> propertytype1;
        int         propertyindex1;
        int         promote1;
        vector<int> propertytype2;
        int         propertyindex2;
        int         promote2;
        vector<int> propertytype3;
        int         propertyindex3;
        int         promote3;
        vector<int> propertytype4;
        int         propertyindex4;
        int         promote4;
        int         isfinal;
        int         round;
        JSON18(soulnode_t, id, rank, name, cost, propertytype1, propertyindex1, promote1, propertytype2, propertyindex2, promote2, propertytype3, propertyindex3, promote3, propertytype4, propertyindex4, promote4, isfinal, round)
    };
    typedef repo_t<soulnode_t> repo_soulnode_t;

    // 公会战 建筑物配置表
    struct guild_battle_t
    {
        int         id;
        int         type;
        vector<int> pre_building;
        JSON3(guild_battle_t, id, type, pre_building)
    };
    typedef repo_t<guild_battle_t> repo_guild_battle_t;

    // 公会战 建筑物信息配置表
    struct guild_battle_building_t
    {
        int         id;
        int         type;
        int         level;
        int         score;
        int         station;
        int         gold_spend;
        JSON6(guild_battle_building_t, id, type, level, score, station, gold_spend)
    };
    typedef repo_t<guild_battle_building_t> repo_guild_battle_building_t;

    //家园种植园
    struct residence_plant_t
    {
        int         id;
        string      name;
        int         growth_stage;
        int         maturation_stage;
        int         harvest_id;
        vector<int> harvest_count;
        int         is_robbed;
        JSON7(residence_plant_t, id,name,growth_stage,maturation_stage,harvest_id,harvest_count,is_robbed)
    };
    typedef repo_t<residence_plant_t> repo_residence_plant_t;

    //家园种植园商店
    struct residence_plantshop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int ishot;
        int islimited;
        int hide;
        JSON8(residence_plantshop_t,id,item_id,name,money_type,price,ishot,islimited,hide)
    };
    typedef repo_t<residence_plantshop_t> repo_residence_plantshop_t;

    //库存商店
    struct inventory_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int ishot;
        int islimited;
        int hide;
        JSON8(inventory_shop_t,id,item_id,name,money_type,price,ishot,islimited,hide)
    };
    typedef repo_t<inventory_shop_t> repo_inventory_shop_t;

    // 公会战 奖励
    struct guild_battle_reward_t
    {
        int                     id;
        vector<int32_t>         ranking;
        vector<vector<int32_t>> reward;
        JSON3(guild_battle_reward_t, id, ranking, reward)
    };
    typedef repo_t<guild_battle_reward_t> repo_guild_battle_reward_t;

    struct open_task_t
    {
        int32_t id;
        string name;
        string description1;
        int32_t type1;
        int32_t value1;
        string description2;
        int32_t type2;
        int32_t value2;
        string description3;
        int32_t type3;
        int32_t value3;
        vector<vector<int>> reward;
        JSON12(open_task_t, id, name, description1, type1, value1, description2, type2, value2, description3, type3, value3, reward)
    };
    typedef repo_t<open_task_t> repo_open_task_t;

    // combo pro info
    struct artifact_t
    {
        int                     id;
        int                     max_level;
        vector<vector<int32_t>> open;
        int                     item;
        JSON4(artifact_t, id, max_level, open, item)
    };
    typedef repo_t<artifact_t> repo_artifact_t;

    // combo pro levelup info
    struct artifact_levelup_t
    {
        int                     id;
        int                     type;
        int                     level;
        int                     exp;
        vector<vector<float>>  attribute;
        JSON5(artifact_levelup_t, id, type, level, exp, attribute);
    };
    typedef repo_t<artifact_levelup_t> repo_artifact_levelup_t;

    struct guildboss_reward_t
    {
        int id;
        vector<vector<int32_t>> reward_item;     
        JSON2(guildboss_reward_t,id,reward_item);
    };
    typedef repo_t<guildboss_reward_t> repo_guildboss_reward_t;

    struct announcement_update_t
    {
        int id;
        string title;
        string time;
        string content;     
        JSON4(announcement_update_t,id,title, time, content);
    };
    typedef repo_t<announcement_update_t> repo_announcement_update_t;

    struct announcement_event_t
    {
        int id;
        string title;
        string start_time;
        string end_time;
        string content;     
        JSON5(announcement_event_t,id,title, start_time,end_time, content);
    };
    typedef repo_t<announcement_event_t> repo_announcement_event_t;

    struct model_change_t
    {
        int role_id;
        vector<int32_t> skin_id;
        JSON2(model_change_t, role_id, skin_id);
    };
    typedef repo_t<model_change_t> repo_model_change_t;

    struct skin_t
    {
        int id;
        string name;
        string model;
        int type;
        int value;
        JSON5(skin_t, id, name, model, type, value);
    };
    typedef repo_t<skin_t> repo_skin_t;

    struct pub_special_t
    {
        int id;
        int type;
        int role_id;
        int rate;
        JSON4(pub_special_t, id, type, role_id, rate);
    };
    typedef repo_t<pub_special_t> repo_pub_special_t;

    struct cardevent_shop_t
    {
        int id;
        int item_id;
        string name;
        int price;
        int islimited;
        int item_num;
        int event_id;
        int isnew;
        int hide;
        JSON9(cardevent_shop_t, id, item_id, name, price, islimited, item_num, event_id, isnew, hide);
    };
    typedef repo_t<cardevent_shop_t> repo_cardevent_shop_t;

    struct lmt_shop_t
    {
        int id;
        int item_id;
        string name;
        int money_type;
        int price;
        int islimited;
        int hide;
        string start_time;
        string end_time;
        JSON9(lmt_shop_t, id, item_id, name, money_type, price, islimited, hide, start_time, end_time);
    };
    typedef repo_t<lmt_shop_t> repo_lmt_shop_t;


}

struct repo_mgr_t
{
    const char* LOG = "REPO";

    typedef map<string, set<repo_i*>> contain_t;
    contain_t contain;

    void reload(const string& path_);
    void reload_single(const string& path_);
    void load(const char* path_);

    repo_mgr_t();

    template<class Repo, class F>
    bool LOAD_REPO(Repo& repo, const char* path, const char* name, F func)
    {
        char buf[256] = {0};
        sprintf(buf, "%s/%s.json", path, name);
        string fullpath(buf);
        auto it=contain.find(fullpath);
        if (it!=contain.end())
        {
            it->second.insert((repo_i*)(&repo));
        }else
        {
            set<repo_i*> repos;
            repos.insert((repo_i*)(&repo));
            contain[fullpath] = std::move(repos);
        }
        repo.cb_loaded = boost::bind(func, this);
        if (!repo.load(path, name))
        {
            return false;
        }
        return true;
    }

    template<class Repo>
    bool LOAD_REPO(Repo& repo, const char* path, const char* name)
    {
        char buf[256] = {0};
        sprintf(buf, "%s/%s.json", path, name);
        string fullpath(buf);
        auto it=contain.find(fullpath);
        if (it!=contain.end())
        {
            it->second.insert((repo_i*)(&repo));
        }else
        {
            set<repo_i*> repos;
            repos.insert((repo_i*)(&repo));
            contain[fullpath] = std::move(repos);
        }
        if (!repo.load(path, name))
        {
            return false;
        }
        return true;
    }

    repo_def::repo_role_t& role;
    repo_def::repo_init_equip_t&  init_equip;
    repo_def::repo_item_t&   item;
    repo_def::repo_lvup_attr_t&  lvup_attr;
    repo_def::repo_city_t&  city;
    repo_def::repo_equip_t&  equip;
    repo_def::repo_round_t&  round;
    repo_def::repo_zodiac_drop_t&  zodiac_drop;
    repo_def::repo_lvup_t&  levelup;
    repo_def::repo_rdgp_t&  roundgroup;
    repo_def::repo_alchemy_money_t& alchemy_money;
    repo_def::repo_flsrd_t&  flushround;
    repo_def::repo_vip_t&  vip;
    repo_def::repo_equip_up_t&  equip_up;
    repo_def::repo_equip_up_pay_t&  equip_up_pay;
    repo_def::repo_equip_compose_t&  equip_compose;
    repo_def::repo_equip_slot_t&  equip_slot;
    repo_def::repo_qualityup_attr_t&  qualityup_attr;
    repo_def::repo_qualityup_staff_t&  qualityup_staff;
    repo_def::repo_gemstone_t&  gemstone;
    repo_def::repo_gemstone_compose_t&  gemstone_compose;
    repo_def::repo_gemstone_part_t&  gemstone_part;
    repo_def::repo_pub_t&  pub;
    repo_def::repo_team_t&  team;
    repo_def::repo_trial_t&  trial;
    repo_def::repo_trial_reward_t&  trial_reward;
    repo_def::repo_arena_reward_t&  arena_reward;
    repo_def::repo_in_arena_reward_t&  in_arena_reward;
    repo_def::repo_skill_upgrade_t&  skill_upgrade;
    repo_def::repo_skill_compose_t&  skill_compose;
    repo_def::repo_skill_t&  skill;
    repo_def::repo_potential_upgrade_t&  potential_upgrade;
    repo_def::repo_potential_caps_t&  potential_caps;
    repo_def::repo_potential_t& potential;
    repo_def::repo_worldboss_t&  worldboss;
    repo_def::repo_unionboss_t&  unionboss;
    repo_def::repo_boss_reward_t& boss_reward;
    repo_def::repo_unionboss_reward_t& unionboss_reward;
    repo_def::repo_monster_t&  monster;
    repo_def::repo_skill_effect_t&  skill_effect;
    repo_def::repo_role_fight_t&  role_fight;
    repo_def::repo_role_fight_t&  boss_fight;
    repo_def::repo_buff_t&  buff;
    repo_def::repo_pack_t&  pack;
    repo_def::repo_practice_t&  practice;
    repo_def::repo_quest_t&  quest;
    repo_def::repo_quest_daily_t&  quest_daily;
    repo_def::repo_achievement_t& achievement;
    repo_def::repo_lmt_event_t& lmt_event;
    repo_def::repo_lmt_double_t& lmt_double;
    repo_def::repo_lmt_reward_t& lmt_reward;
    repo_def::repo_lmt_gift_t& lmt_gift;
    repo_def::repo_weekly_t& weekly;
    repo_def::repo_npc_t&  npc;
    //repo_def::repo_quest_daily_reward_t&  quest_daily_reward;
    repo_def::repo_chronicle_t& chronicle;
    repo_def::repo_chronicle_story_t& chronicle_story;
    repo_def::repo_rune_t&  rune;
    repo_def::repo_rune_prob_t&  rune_prob;
    repo_def::repo_guild_t&  guild;
    repo_def::repo_guildboss_open_t&  guildboss_open;
    repo_def::repo_guildskill_t&  guildskill;
    repo_def::repo_guildskill_cost_t&  guildskill_cost;
    repo_def::repo_altar_t&  altar;
    repo_def::repo_shop_t&  shop;
    repo_def::repo_npc_shop_t& npc_shop;
    repo_def::repo_special_shop_t& special_shop;
    repo_def::repo_daily_sign_t& daily_sign;
    repo_def::repo_vip_open_t&  vip_open;
    repo_def::repo_acc_yb_t&  acc_yb;
    repo_def::repo_acc_login_t&  acc_login;
    repo_def::repo_con_login_t&  con_login;
    repo_def::repo_newly_reward_t& newly_reward;
    repo_def::repo_growup_reward_t& growup_reward;
    repo_def::repo_mail_format_t&  mail_format;
    repo_def::repo_pay_t&  pay;
    repo_def::repo_apppay_t&  apppay;
    repo_def::repo_online_t&  online;
    repo_def::repo_maquee_t&  maquee;
    repo_def::repo_treasure_t &treasure;
    repo_def::repo_first_lgrw_t&  first_lgrw;
    repo_def::repo_backpack_t& backpack;
    repo_def::repo_star_t &star;
    repo_def::repo_star_prob_t &star_prob;
    repo_def::repo_city_boss_t& city_boss;
    repo_def::repo_city_boss_pos_t& city_boss_pos;
    repo_def::repo_city_boss_drop_t& city_boss_drop;
    repo_def::repo_pushinfo_t& push_format;
    repo_def::repo_starreward_t& starreward;
    repo_def::repo_level_reward_t& level_reward;
    repo_def::repo_cdkey_reward_t& cdkey_reward;
    repo_def::repo_scuffle_rank_t &scuffle_rank;
    repo_def::repo_scuffle_last_t &scuffle_last;
    repo_def::repo_sign_reward_t &sign_reward;
    repo_def::repo_robot_conf_t&    robot_conf;
    repo_def::repo_salary_t& salary;
    repo_def::repo_insalary_t& insalary;
    repo_def::repo_titleup_t& titleup;
    repo_def::repo_prestige_shop_t& prestige_shop;
    repo_def::repo_unprestige_shop_t& unprestige_shop;
    repo_def::repo_chip_shop_t& chip_shop;
    repo_def::repo_chip_smash_t& chip_smash;
    repo_def::repo_box_t& box;
    repo_def::repo_drug_t& drug;
    repo_def::repo_tskill_t&  tskill;
    repo_def::repo_fp_reward_t &fp_reward;
    repo_def::repo_activity_time_t &activity_time;
    repo_def::repo_gold_chip_t &gold_chip;
    repo_def::repo_chip_t &chip;
    repo_def::repo_destiny_t &destiny;
    repo_def::repo_cave_t &cave;
    repo_def::repo_buff_reject_t &buff_reject;
    repo_def::repo_cumu_consume_t &cumu_consume;
    repo_def::repo_daily_pay_t &daily_pay;
    repo_def::repo_activity_cfg_t &activity_cfg;
    repo_def::repo_limited_round_data_t &limited_round_data;
    repo_def::repo_vip_package_t &vip_package;
    repo_def::repo_wing_t &wing;
    repo_def::repo_wing_compose_t &wing_compose;
    repo_def::repo_pet_t &pet;
    repo_def::repo_pet_compose_t &pet_compose;
    repo_def::repo_wing_act_t &wing_act;
    repo_def::repo_love_task_t &love_task;
    repo_def::repo_love_reward_t &love_reward;
    repo_def::repo_boss_up_t &boss_up;
    repo_def::repo_expedition_t &expedition;
    repo_def::repo_expedition_box_t &expedition_box;
    repo_def::repo_expedition_shop_t &expedition_shop;
    repo_def::repo_gang_shop_t &gang_shop;
    repo_def::repo_rune_shop_t &rune_shop;
    repo_def::repo_expedition_hero_piece_t &expedition_hero_piece;
    repo_def::repo_recharge_frist_t &recharge_fristtime;
    repo_def::repo_friend_reward_t& friend_reward;
    repo_def::repo_card_event_t& card_event;
    repo_def::repo_card_event_point_t& card_event_point;
    repo_def::repo_card_event_ranking_t& card_event_ranking;
    repo_def::repo_card_event_round_t& card_event_round;
    repo_def::repo_card_event_reward_t& card_event_reward;
    repo_def::repo_card_event_difficult_t& card_event_difficult;
    repo_def::repo_card_event_open_reward_t& card_event_open_reward;
    repo_def::repo_soul_pursue_t& soul;
    repo_def::repo_rank_season_t& rank_season;
    repo_def::repo_configure_t& configure;
    repo_def::repo_soulnode_t& soulnode;
    repo_def::repo_residence_plant_t& residence_plant;
    repo_def::repo_residence_plantshop_t& residence_plantshop;
    repo_def::repo_inventory_shop_t& inventory_shop;
    repo_def::repo_guild_battle_t& guild_battle;
    repo_def::repo_guild_battle_building_t& guild_battle_building;
    repo_def::repo_guild_battle_reward_t& guild_battle_reward;
    repo_def::repo_artifact_t& artifact;
    repo_def::repo_artifact_levelup_t& artifact_levelup;
    repo_def::repo_guildboss_reward_t& guildboss_reward;
    repo_def::repo_model_change_t& model_change;
    repo_def::repo_skin_t& skin;
    repo_def::repo_pub_special_t& pub_special;

    repo_def::repo_open_task_t& open_task;
    repo_def::repo_announcement_update_t& announcement_update;
    repo_def::repo_announcement_event_t& announcement_event;
    repo_def::repo_cardevent_shop_t& cardevent_shop;
    repo_def::repo_lmt_shop_t& lmt_shop;

    //[roundid] [groupid]
    unordered_map<int32_t, int32_t> rid2gid;
    void revert_roundgroup();

    //[概率][]
    map<int, vector<repo_def::altar_t>> altar_hm;
    void init_altar_hm();

    //[boxid][info]
    map<int, vector<repo_def::box_t>> box_map;
    void init_box_map();

    //宝箱中会出的紫色装备
    vector<int> box_equips;

    map<int, vector<repo_def::shop_t>> shop_map;
    void init_shop_map();


    map<int, map<int,int>> cur_soulnode;
    map<int,map<int,map<int,int>>> soulnode_info;
    void init_soulnode_info();

    vector<int> shop_item;
};

#define repo_mgr (singleton_t<repo_mgr_t>::instance())
#endif
