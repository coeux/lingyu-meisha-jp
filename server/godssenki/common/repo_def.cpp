#include "repo_def.h"
#include <boost/regex.hpp>

repo_def::repo_role_t g_role;
repo_def::repo_init_equip_t g_init_equip;
repo_def::repo_item_t g_item;
repo_def::repo_lvup_attr_t g_lvup_attr;
repo_def::repo_city_t g_city;
repo_def::repo_equip_t g_equip;
repo_def::repo_round_t g_round;
repo_def::repo_zodiac_drop_t g_zodiac_drop;
repo_def::repo_lvup_t g_levelup;
repo_def::repo_rdgp_t g_roundgroup;
repo_def::repo_alchemy_money_t g_alchemy_money;
repo_def::repo_flsrd_t g_flushround;
repo_def::repo_vip_t g_vip;
repo_def::repo_equip_up_t g_equip_up;
repo_def::repo_equip_up_pay_t g_equip_up_pay;
repo_def::repo_equip_compose_t g_equip_compose;
repo_def::repo_equip_slot_t g_equip_slot;
repo_def::repo_qualityup_attr_t g_qualityup_attr;
repo_def::repo_qualityup_staff_t g_qualityup_staff;
repo_def::repo_gemstone_t g_gemstone;
repo_def::repo_gemstone_compose_t g_gemstone_compose;
repo_def::repo_gemstone_part_t g_gemstone_part;
repo_def::repo_pub_t g_pub;
repo_def::repo_team_t g_team;
repo_def::repo_trial_t g_trial;
repo_def::repo_trial_reward_t g_trial_reward;
repo_def::repo_arena_reward_t g_arena_reward;
repo_def::repo_in_arena_reward_t g_in_arena_reward;
repo_def::repo_skill_upgrade_t g_skill_upgrade;
repo_def::repo_skill_compose_t g_skill_compose;
repo_def::repo_skill_t g_skill;
repo_def::repo_potential_upgrade_t g_potential_upgrade;
repo_def::repo_activity_time_t g_activity_time;
repo_def::repo_potential_caps_t g_potential_caps;
repo_def::repo_potential_t g_potential;
repo_def::repo_worldboss_t g_worldboss;
repo_def::repo_unionboss_t g_unionboss;
repo_def::repo_boss_reward_t g_boss_reward;
repo_def::repo_unionboss_reward_t g_unionboss_reward;
repo_def::repo_monster_t g_monster;
repo_def::repo_skill_effect_t g_skill_effect;
repo_def::repo_role_fight_t g_role_fight;
repo_def::repo_role_fight_t g_boss_fight;
repo_def::repo_buff_t g_buff;
repo_def::repo_pack_t g_pack;
repo_def::repo_practice_t g_practice;
repo_def::repo_quest_t g_quest;
repo_def::repo_quest_daily_t g_quest_daily;
repo_def::repo_achievement_t g_achievement;
repo_def::repo_lmt_event_t g_lmt_event;
repo_def::repo_lmt_double_t g_lmt_double;
repo_def::repo_lmt_reward_t g_lmt_reward;
repo_def::repo_lmt_gift_t g_lmt_gift;
repo_def::repo_weekly_t g_weekly;
repo_def::repo_npc_t g_npc;
//repo_def::repo_quest_daily_reward_t g_quest_daily_reward;
repo_def::repo_chronicle_t g_chronicle;
repo_def::repo_chronicle_story_t g_chronicle_story;
repo_def::repo_rune_t g_rune;
repo_def::repo_rune_prob_t g_rune_prob;
repo_def::repo_guild_t g_guild;
repo_def::repo_guildboss_open_t g_guildboss_open;
repo_def::repo_guildskill_t g_guildskill;
repo_def::repo_guildskill_cost_t g_guildskill_cost;
repo_def::repo_altar_t g_altar;
repo_def::repo_shop_t g_shop;
repo_def::repo_npc_shop_t g_npc_shop;
repo_def::repo_special_shop_t g_special_shop;
repo_def::repo_daily_sign_t g_daily_sign;
repo_def::repo_vip_open_t g_vip_open;
repo_def::repo_acc_yb_t g_acc_yb;
repo_def::repo_acc_login_t g_acc_login;
repo_def::repo_con_login_t g_con_login;
repo_def::repo_newly_reward_t g_newly_reward;
repo_def::repo_growup_reward_t g_growup_reward;
repo_def::repo_mail_format_t g_mail_format;
repo_def::repo_pay_t g_pay;
repo_def::repo_apppay_t g_apppay;
repo_def::repo_online_t g_online;
repo_def::repo_maquee_t g_maquee;
repo_def::repo_treasure_t g_treasure;
repo_def::repo_first_lgrw_t g_first_lgrw;
repo_def::repo_backpack_t g_backpack;
repo_def::repo_star_t g_star;
repo_def::repo_star_prob_t g_star_prob;
repo_def::repo_city_boss_t g_city_boss;
repo_def::repo_city_boss_pos_t g_city_boss_pos;
repo_def::repo_city_boss_drop_t g_city_boss_drop;
repo_def::repo_pushinfo_t g_push_format;
repo_def::repo_starreward_t g_starreward;
repo_def::repo_level_reward_t g_level_reward;
repo_def::repo_cdkey_reward_t g_cdkey_reward;
repo_def::repo_scuffle_rank_t g_scuffle_rank;
repo_def::repo_scuffle_last_t g_scuffle_last;
repo_def::repo_sign_reward_t g_sign_reward;
repo_def::repo_robot_conf_t g_robot_conf;
repo_def::repo_salary_t g_salary;
repo_def::repo_insalary_t g_insalary;
repo_def::repo_titleup_t g_titleup;
repo_def::repo_prestige_shop_t g_prestige_shop;
repo_def::repo_unprestige_shop_t g_unprestige_shop;
repo_def::repo_chip_shop_t g_chip_shop;
repo_def::repo_chip_smash_t g_chip_smash;
repo_def::repo_box_t g_box;
repo_def::repo_drug_t g_drug;
repo_def::repo_tskill_t  g_tskill;
repo_def::repo_fp_reward_t  g_fp_reward;
repo_def::repo_gold_chip_t g_gold_chip;
repo_def::repo_chip_t g_chip;
repo_def::repo_destiny_t g_destiny;
repo_def::repo_cave_t g_cave;
repo_def::repo_buff_reject_t g_buff_reject;
repo_def::repo_cumu_consume_t g_cumu_consume;
repo_def::repo_daily_pay_t g_daily_pay;
repo_def::repo_activity_cfg_t g_activity_cfg;
repo_def::repo_limited_round_data_t g_limited_round_data;
repo_def::repo_vip_package_t g_vip_package;
repo_def::repo_wing_t g_wing;
repo_def::repo_wing_compose_t g_wing_compose;
repo_def::repo_wing_act_t g_wing_act;
repo_def::repo_pet_t g_pet;
repo_def::repo_pet_compose_t g_pet_compose;
repo_def::repo_love_task_t g_love_task;
repo_def::repo_love_reward_t g_love_reward;
repo_def::repo_boss_up_t g_boss_up;
repo_def::repo_expedition_t g_expedition;
repo_def::repo_expedition_box_t g_expedition_box;
repo_def::repo_expedition_shop_t g_expedition_shop;
repo_def::repo_gang_shop_t g_gang_shop;
repo_def::repo_rune_shop_t g_rune_shop;
repo_def::repo_expedition_hero_piece_t g_expedition_hero_piece;
repo_def::repo_recharge_frist_t g_recharge_fristtime;
repo_def::repo_friend_reward_t g_friend_reward;
repo_def::repo_card_event_t g_card_event;
repo_def::repo_card_event_point_t g_card_event_point;
repo_def::repo_card_event_ranking_t g_card_event_ranking;
repo_def::repo_card_event_round_t g_card_event_round;
repo_def::repo_card_event_reward_t g_card_event_reward;
repo_def::repo_card_event_difficult_t g_card_event_difficult;
repo_def::repo_card_event_open_reward_t g_card_event_open_reward;
repo_def::repo_soul_pursue_t g_soul_pursue;
repo_def::repo_rank_season_t g_rank_season;
repo_def::repo_configure_t g_configure;
repo_def::repo_soulnode_t g_soulnode;
repo_def::repo_guild_battle_t g_guild_battle;
repo_def::repo_guild_battle_building_t g_guild_battle_building;
repo_def::repo_residence_plant_t g_residence_plant;
repo_def::repo_residence_plantshop_t g_residence_plantshop;
repo_def::repo_inventory_shop_t g_inventoryshop;
repo_def::repo_guild_battle_reward_t g_guild_battle_reward;
repo_def::repo_open_task_t g_open_task;
repo_def::repo_artifact_t g_artifact;
repo_def::repo_artifact_levelup_t g_artifact_levelup;
repo_def::repo_guildboss_reward_t g_guildboss_reward;
repo_def::repo_announcement_update_t g_announcement_update;
repo_def::repo_announcement_event_t g_announcement_event;
repo_def::repo_model_change_t g_model_change;
repo_def::repo_skin_t g_skin;
repo_def::repo_pub_special_t g_pub_special;
repo_def::repo_cardevent_shop_t g_cardevent_shop;
repo_def::repo_lmt_shop_t g_lmt_shop;

repo_mgr_t::repo_mgr_t():
role(g_role),
init_equip(g_init_equip),
item(g_item),
lvup_attr(g_lvup_attr),
city(g_city),
equip(g_equip),
round(g_round),
zodiac_drop(g_zodiac_drop),
levelup(g_levelup),
roundgroup(g_roundgroup),
alchemy_money(g_alchemy_money),
flushround(g_flushround),
vip(g_vip),
equip_up(g_equip_up),
equip_up_pay(g_equip_up_pay),
equip_compose(g_equip_compose),
equip_slot(g_equip_slot),
qualityup_attr(g_qualityup_attr),
qualityup_staff(g_qualityup_staff),
gemstone(g_gemstone),
gemstone_compose(g_gemstone_compose),
gemstone_part(g_gemstone_part),
pub(g_pub),
team(g_team),
trial(g_trial),
trial_reward(g_trial_reward),
arena_reward(g_arena_reward),
in_arena_reward(g_in_arena_reward),
skill_upgrade(g_skill_upgrade),
skill_compose(g_skill_compose),
skill(g_skill),
potential_upgrade(g_potential_upgrade),
potential_caps(g_potential_caps),
potential(g_potential),
worldboss(g_worldboss),
unionboss(g_unionboss),
boss_reward(g_boss_reward),
unionboss_reward(g_unionboss_reward),
monster(g_monster),
skill_effect(g_skill_effect),
role_fight(g_role_fight),
boss_fight(g_boss_fight),
buff(g_buff),
pack(g_pack),
practice(g_practice),
quest(g_quest),
quest_daily(g_quest_daily),
achievement(g_achievement),
lmt_event(g_lmt_event),
lmt_double(g_lmt_double),
lmt_reward(g_lmt_reward),
lmt_gift(g_lmt_gift),
weekly(g_weekly),
npc(g_npc),
//quest_daily_reward(g_quest_daily_reward),
chronicle(g_chronicle),
chronicle_story(g_chronicle_story),
rune(g_rune),
rune_prob(g_rune_prob),
guild(g_guild),
guildboss_open(g_guildboss_open),
guildskill(g_guildskill),
guildskill_cost(g_guildskill_cost),
altar(g_altar),
shop(g_shop),
npc_shop(g_npc_shop),
special_shop(g_special_shop),
daily_sign(g_daily_sign),
vip_open(g_vip_open),
acc_yb(g_acc_yb),
acc_login(g_acc_login),
con_login(g_con_login),
newly_reward(g_newly_reward),
growup_reward(g_growup_reward),
mail_format(g_mail_format),
pay(g_pay),
apppay(g_apppay),
online(g_online),
maquee(g_maquee),
treasure(g_treasure),
first_lgrw(g_first_lgrw),
backpack(g_backpack),
star(g_star),
star_prob(g_star_prob),
city_boss(g_city_boss),
city_boss_pos(g_city_boss_pos),
city_boss_drop(g_city_boss_drop),
push_format(g_push_format),
starreward(g_starreward),
level_reward(g_level_reward),
cdkey_reward(g_cdkey_reward),
scuffle_rank(g_scuffle_rank),
scuffle_last(g_scuffle_last),
sign_reward(g_sign_reward),
robot_conf(g_robot_conf),
salary(g_salary),
insalary(g_insalary),
titleup(g_titleup),
prestige_shop(g_prestige_shop),
unprestige_shop(g_unprestige_shop),
chip_shop(g_chip_shop),
chip_smash(g_chip_smash),
box(g_box),
drug(g_drug),
tskill(g_tskill),
fp_reward(g_fp_reward),
activity_time(g_activity_time),
gold_chip(g_gold_chip),
chip(g_chip),
destiny(g_destiny),
cave(g_cave),
buff_reject(g_buff_reject),
cumu_consume(g_cumu_consume),
daily_pay(g_daily_pay),
activity_cfg(g_activity_cfg),
limited_round_data(g_limited_round_data),
vip_package(g_vip_package),
wing(g_wing),
wing_compose(g_wing_compose),
wing_act(g_wing_act),
pet(g_pet),
pet_compose(g_pet_compose),
love_task(g_love_task),
love_reward(g_love_reward),
boss_up(g_boss_up),
expedition(g_expedition),
expedition_box(g_expedition_box),
expedition_shop(g_expedition_shop),
gang_shop(g_gang_shop),
rune_shop(g_rune_shop),
expedition_hero_piece(g_expedition_hero_piece),
recharge_fristtime(g_recharge_fristtime),
configure(g_configure),
soulnode(g_soulnode),
guild_battle(g_guild_battle),
guild_battle_building(g_guild_battle_building),
residence_plant(g_residence_plant),
residence_plantshop(g_residence_plantshop),
inventory_shop(g_inventoryshop),
guild_battle_reward(g_guild_battle_reward),
friend_reward(g_friend_reward),
card_event(g_card_event),
card_event_point(g_card_event_point),
card_event_ranking(g_card_event_ranking),
card_event_round(g_card_event_round),
card_event_reward(g_card_event_reward),
card_event_difficult(g_card_event_difficult),
card_event_open_reward(g_card_event_open_reward),
soul(g_soul_pursue),
rank_season(g_rank_season),
open_task(g_open_task),
guildboss_reward(g_guildboss_reward),
announcement_update(g_announcement_update),
announcement_event(g_announcement_event),
model_change(g_model_change),
skin(g_skin),
pub_special(g_pub_special),
cardevent_shop(g_cardevent_shop),
lmt_shop(g_lmt_shop),
artifact(g_artifact),
artifact_levelup(g_artifact_levelup)
{
}



void repo_mgr_t::reload(const string& path_)
{
    auto it = contain.find(path_);
    if(it != contain.end())
    {
        for(auto itt=it->second.begin(); itt!=it->second.end(); itt++)
        {
            repo_i* repo = *itt;
            if (repo->reload(path_))
            {
                if (!repo->cb_loaded.empty())
                    repo->cb_loaded();
            }
            else
                logerror(("REPO", "load repo failed! repo:%s", path_.c_str()));
        }
    }
}
void repo_mgr_t::reload_single(const string& path_)
{
    auto it = contain.find(path_);
    auto itt = it->second.begin();
    repo_i* repo = *itt;
    if(path_ == "")
        return;
    if (repo->reload(path_))
    {
        if (!repo->cb_loaded.empty())
            repo->cb_loaded();
    }
}
void repo_mgr_t::revert_roundgroup()
{
    rid2gid.clear();

    auto it_hm = roundgroup.begin();
    while( it_hm!=roundgroup.end() )
    {
        auto it_v = (it_hm->second).scene_id.begin();
        while( it_v != (it_hm->second).scene_id.end() )
        {
            rid2gid.insert(make_pair(*it_v,it_hm->first));
            ++it_v;
        }
        ++it_hm;
    }
}
void repo_mgr_t::init_altar_hm()
{
    altar_hm.clear();
    for(auto it=altar.begin();it!=altar.end();it++)
    {
        auto itt = (altar_hm.find(it->second.prob));
        if (itt == altar_hm.end())
            altar_hm[it->second.prob] = vector<repo_def::altar_t>();

        altar_hm[it->second.prob].push_back(it->second);
    }
}

void repo_mgr_t::init_box_map()
{
    box_equips.clear();
    box_map.clear();
    for(auto it=box.begin();it!=box.end();it++)
    {
        auto itt = (box_map.find(it->second.boxid));
        if (itt == box_map.end())
            box_map[it->second.boxid] = vector<repo_def::box_t>();

        box_map[it->second.boxid].push_back(it->second);

        repo_def::item_t* rp_item = repo_mgr.item.get(it->second.item1);
        //2是道具表中的装备类型,4及以上都是紫装以上装备
        if (rp_item != NULL && rp_item->type == 2 && rp_item->quality>=4)
        {
            box_equips.push_back(it->second.item1);
        }
    }
    for(auto it=box_map.begin();it!=box_map.end();it++)
    {
        vector<repo_def::box_t>& array = it->second;
        std::sort(array.begin(), array.end(), [](const repo_def::box_t& a_, const repo_def::box_t& b_){
            return a_.pro1 < b_.pro1;
        });

        for(size_t i=1; i<array.size(); i++)
        {
            array[i].pro1 += array[i-1].pro1;   
        }
    }
}

#define SoulProperty(n) if(itinfo.propertytype##n.size() > 0)\
                {\
                    for(int32_t index = 1;index < itinfo.propertytype##n.size();index++)\
                    {\
                        auto itt = cur_soulnode.find(itinfo.propertytype##n[index]);\
                        if(itt == cur_soulnode.end())\
                            cur_soulnode[itinfo.propertytype##n[index]] = map<int,int>();\
\
                        auto ittindex = cur_soulnode[itinfo.propertytype##n[index]].find(itinfo.propertyindex##n);\
                        if(ittindex == cur_soulnode[itinfo.propertytype##n[index]].end())\
                            cur_soulnode[itinfo.propertytype##n[index]][itinfo.propertyindex##n] = 0;\
                        cur_soulnode[itinfo.propertytype##n[index]][itinfo.propertyindex##n] = cur_soulnode[itinfo.propertytype##n[index]][itinfo.propertyindex##n] + itinfo.promote##n;\
                    }\
                }

void repo_mgr_t::init_soulnode_info()
{
    cur_soulnode.clear();
    soulnode_info.clear();
    vector<int> array;
    for(auto it=soulnode.begin();it!=soulnode.end();it++)
    {
        array.push_back(it->second.id);
    }
    std::sort(array.begin(),array.end(),[](const int& a_, const int& b_){
        return a_ < b_; 
    });
    for(size_t i = 0;i<array.size();i++)
    { 
        auto it = soulnode.find(array[i]);
        if(it != soulnode.end())
        {
            auto itinfo = it->second;

            SoulProperty(1)
            SoulProperty(2)
            SoulProperty(3)
            SoulProperty(4)
            soulnode_info[it->second.id] =cur_soulnode;
        }
    }  
}

void repo_mgr_t::init_shop_map()
{
    shop_item.clear();
    shop_map.clear();
    for(auto it=shop.begin();it!=shop.end();it++)
    {
        auto itt = (shop_map.find(it->second.id));
        if(itt == shop_map.end())
            shop_map[it->second.id] = vector<repo_def::shop_t>();

        shop_map[it->second.id].push_back(it->second);

        repo_def::shop_t* rp_shop = repo_mgr.shop.get(it->second.id);

        if(rp_shop != NULL && rp_shop->hide == 0)
        {
            shop_item.push_back(it->second.id);

        }
    }
}

void repo_mgr_t::load(const char* path_)
{
    LOAD_REPO(role, path_, "role");
    LOAD_REPO(init_equip, path_, "init_equip");
    LOAD_REPO(item, path_, "item");
    LOAD_REPO(lvup_attr, path_, "levelup_attribute");
    LOAD_REPO(city, path_, "scene");
    LOAD_REPO(equip, path_, "equip");
    LOAD_REPO(round, path_, "round");
    LOAD_REPO(zodiac_drop, path_, "zodiac_drop");
    LOAD_REPO(levelup, path_, "levelup");
    LOAD_REPO(roundgroup, path_, "scene_reset", &repo_mgr_t::revert_roundgroup);
    LOAD_REPO(vip, path_, "vip_config");
    LOAD_REPO(equip_up, path_, "equip_upgrade");
    LOAD_REPO(equip_up_pay, path_, "equip_upgrade_pay");
    LOAD_REPO(equip_compose, path_, "equip_compose");
    LOAD_REPO(equip_slot, path_, "equip_slot");
    LOAD_REPO(qualityup_attr, path_, "qualityup_attribute");
    LOAD_REPO(qualityup_staff, path_, "qualityup_stuff");
    LOAD_REPO(gemstone, path_, "gemstone");
    LOAD_REPO(gemstone_compose, path_, "gemstone_compose");
    LOAD_REPO(gemstone_part, path_, "gemstone_part");
    LOAD_REPO(pub, path_, "pub");
    LOAD_REPO(team, path_, "team");
    LOAD_REPO(trial, path_, "trial");
    LOAD_REPO(trial_reward, path_, "trial_reward");
    LOAD_REPO(arena_reward, path_, "arena_rank");
    LOAD_REPO(in_arena_reward, path_, "unarena_rank");
    LOAD_REPO(skill_upgrade, path_, "skill_upgrade");
    LOAD_REPO(skill_compose, path_, "skill_compose");
    LOAD_REPO(skill, path_, "skill");
    LOAD_REPO(potential_upgrade, path_, "potential_upgrade");
    LOAD_REPO(potential_caps, path_, "potential_caps");
    LOAD_REPO(potential, path_, "potential");
    LOAD_REPO(worldboss, path_, "worldboss");
    LOAD_REPO(unionboss, path_, "guildboss");
    LOAD_REPO(boss_reward, path_, "boss_reward");
    LOAD_REPO(unionboss_reward, path_, "rank_reward");
    LOAD_REPO(monster, path_, "monster");
    LOAD_REPO(skill_effect, path_, "skill_effect");
    LOAD_REPO(role_fight, path_, "role");
    LOAD_REPO(boss_fight, path_, "monster");
    LOAD_REPO(buff, path_, "buff");
    LOAD_REPO(pack, path_, "equip_packs");
    LOAD_REPO(practice, path_, "practice");
    LOAD_REPO(quest, path_, "quest");
    LOAD_REPO(quest_daily, path_, "dailyquest");
    LOAD_REPO(achievement, path_, "achievement_task");
    LOAD_REPO(lmt_event, path_, "lmt_event");
    LOAD_REPO(lmt_double, path_, "lmt_double_reward");
    LOAD_REPO(lmt_reward, path_, "lmt_reward");
    LOAD_REPO(lmt_gift, path_, "lmt_gift");
    LOAD_REPO(weekly, path_, "weekly");
    LOAD_REPO(npc, path_, "npc");
    //LOAD_REPO(quest_daily_reward, path_, "dailyquest_reward");
    LOAD_REPO(chronicle, path_, "chronicle");
    LOAD_REPO(chronicle_story, path_, "chronicle_story");
    LOAD_REPO(rune, path_, "rune");
    LOAD_REPO(rune_prob, path_, "rune_prob");
    LOAD_REPO(guild, path_, "guild");
    LOAD_REPO(guildboss_open, path_, "guildboss_open");
    LOAD_REPO(guildskill, path_, "guildskill");
    LOAD_REPO(guildskill_cost, path_, "guildskill_cost");
    LOAD_REPO(altar, path_, "altar", &repo_mgr_t::init_altar_hm);
    LOAD_REPO(shop, path_, "money_shop", &repo_mgr_t::init_shop_map);
    LOAD_REPO(npc_shop, path_, "npc_shop");
    LOAD_REPO(special_shop, path_, "special_shop");
    LOAD_REPO(daily_sign, path_, "daily_sign");
    LOAD_REPO(vip_open, path_, "vip_open");
    LOAD_REPO(acc_yb, path_, "recharge_accumulative");
    LOAD_REPO(acc_login, path_, "login_accumulative");
    LOAD_REPO(con_login, path_, "login_count");
    LOAD_REPO(newly_reward, path_, "newly_reward");
    LOAD_REPO(growup_reward, path_, "growup_reward");
    LOAD_REPO(mail_format, path_, "mail_format");
    LOAD_REPO(pay, path_, "pay");
    LOAD_REPO(apppay, path_, "apppay");
    LOAD_REPO(online, path_, "online");
    LOAD_REPO(maquee, path_, "maquee");
    LOAD_REPO(first_lgrw, path_, "sign");
    LOAD_REPO(treasure, path_, "treasure");
    LOAD_REPO(backpack, path_, "backpack");
    LOAD_REPO(star, path_, "star");
    LOAD_REPO(star_prob, path_, "star_prob");
    LOAD_REPO(city_boss, path_, "invasion_city");
    LOAD_REPO(city_boss_pos, path_, "invasion_coordinate");
    LOAD_REPO(city_boss_drop, path_, "invasion_drop");
    LOAD_REPO(push_format, path_, "pushinfo");
    LOAD_REPO(starreward, path_, "starreward");
    LOAD_REPO(level_reward, path_, "level_reward");
    LOAD_REPO(cdkey_reward, path_, "cdkey_reward");
    LOAD_REPO(scuffle_rank, path_, "kof_reward");
    LOAD_REPO(scuffle_last, path_, "kof_1st_reward");
    LOAD_REPO(sign_reward, path_, "sigh_reward");
    LOAD_REPO(robot_conf, path_, "robot_config");
    LOAD_REPO(salary, path_, "salary");
    LOAD_REPO(insalary, path_, "unsalary");
    LOAD_REPO(titleup, path_, "meritorious");
    LOAD_REPO(prestige_shop, path_, "prestige_shop");
    LOAD_REPO(unprestige_shop, path_, "unprestige_shop");
    LOAD_REPO(chip_shop, path_, "chip_shop");
    LOAD_REPO(chip_smash, path_, "chip_smash");
    LOAD_REPO(box, path_, "treasure_box", &repo_mgr_t::init_box_map);
    LOAD_REPO(drug, path_, "drug");
    LOAD_REPO(tskill, path_, "passiveskill");
    LOAD_REPO(fp_reward, path_, "fp_reward");
    LOAD_REPO(activity_time, path_, "activity_time");
    LOAD_REPO(gold_chip, path_, "ltd_hero_piece");
    LOAD_REPO(chip, path_, "hero_piece");
    LOAD_REPO(destiny, path_, "destiny");
    LOAD_REPO(cave, path_, "miku");
    LOAD_REPO(buff_reject, path_, "buff_reject");
    LOAD_REPO(cumu_consume, path_, "activity_consumption");
    LOAD_REPO(daily_pay, path_, "daily_pay");
    LOAD_REPO(activity_cfg, path_, "activity_cfg");
    LOAD_REPO(limited_round_data, path_, "lmt_battle_round");
    LOAD_REPO(vip_package, path_, "vip_package");
    LOAD_REPO(wing, path_, "wing");
    LOAD_REPO(wing_compose, path_, "wing_compose");
    LOAD_REPO(wing_act, path_, "time_wing");
    LOAD_REPO(pet, path_, "pet");
    LOAD_REPO(pet_compose, path_, "pet_compose");
    LOAD_REPO(love_task, path_, "love_task");
    LOAD_REPO(love_reward, path_, "love_reward");
    LOAD_REPO(alchemy_money, path_, "alchemy_money");
    LOAD_REPO(boss_up, path_, "boss_up");
    LOAD_REPO(expedition, path_, "expedition");
    LOAD_REPO(expedition_box, path_, "expedition_drop");
    LOAD_REPO(expedition_shop, path_, "expedition_shop");
    LOAD_REPO(gang_shop, path_, "guild_shop");
    LOAD_REPO(rune_shop, path_, "rune_exchange");
    LOAD_REPO(expedition_hero_piece, path_, "expedition_hero");
    LOAD_REPO(recharge_fristtime, path_, "recharge_fristtime");
    LOAD_REPO(friend_reward, path_, "friend_reward");
    LOAD_REPO(card_event, path_, "event");
    LOAD_REPO(card_event_point, path_, "event_point");
    LOAD_REPO(card_event_ranking, path_, "event_ranking");
    LOAD_REPO(card_event_round, path_, "event_round");
    LOAD_REPO(card_event_reward, path_, "event_reward");
    LOAD_REPO(card_event_difficult, path_, "event_difficulty");
    LOAD_REPO(card_event_open_reward, path_, "event_open");
    LOAD_REPO(soul, path_, "soul_pursue");
    LOAD_REPO(rank_season, path_, "rank_season");
    LOAD_REPO(configure, path_, "config");
    LOAD_REPO(soulnode, path_, "soul_node", &repo_mgr_t::init_soulnode_info);
    LOAD_REPO(guild_battle, path_, "guild_battle");
    LOAD_REPO(guild_battle_building, path_, "guild_battle_building");
    LOAD_REPO(guild_battle_reward, path_, "guild_battle_reward");
    //LOAD_REPO(soulnode, path_, "soul_node");
    LOAD_REPO(artifact, path_, "artifact");
    LOAD_REPO(artifact_levelup, path_, "artifact_levelup");
    LOAD_REPO(residence_plant, path_, "residence_plant");
    LOAD_REPO(residence_plantshop, path_, "residence_plantshop");
    LOAD_REPO(inventory_shop, path_, "inventoryshop");
    LOAD_REPO(open_task, path_, "open_task");
    LOAD_REPO(guildboss_reward, path_, "guildboss_reward");
    LOAD_REPO(announcement_update, path_, "announcement_update");
    LOAD_REPO(announcement_event, path_, "announcement_event");
    LOAD_REPO(model_change, path_, "model_change");
    LOAD_REPO(skin, path_, "skin");
    LOAD_REPO(pub_special, path_, "pub_special");
    LOAD_REPO(cardevent_shop, path_, "PT_shop");
    LOAD_REPO(lmt_shop, path_, "Imt_shop");

    revert_roundgroup();
    init_altar_hm();
    init_box_map();
    init_soulnode_info();
    init_shop_map();
}
