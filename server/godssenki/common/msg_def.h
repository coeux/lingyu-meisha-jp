#ifndef _SU_CMD_DEF_H_
#define _SU_CMD_DEF_H_

#include <boost/shared_ptr.hpp>

#include "jserialize_macro.h"
#include "yarray.h"

#define DEC_CMD_RANGE(s, e) static bool cmd_range(uint16_t cmd_){return (s<=cmd_&&cmd_<e);}

//服务器内部消息 
struct inner_msg_def
{
    DEC_CMD_RANGE(1000, 2000)

    //内部注册时提供的网关信息
    struct jpk_gw_info_t
    {
        uint16_t    serid;
        string      ip;
        string      port;
        JSON3(jpk_gw_info_t, serid, ip, port)
    };

    //请求注册
    struct req_regist_t : public jcmd_t<1000>
    {
        //服务器id(包含type和实际id, 以下雷同)
        uint32_t sid;
        string jinfo;
        JSON2(req_regist_t, sid, jinfo)
    };

    //注册请求返回
    struct ret_regist_t : public jcmd_t<1001>
    {
        uint32_t sid;
        uint16_t code;
        JSON2(ret_regist_t, sid, code)
    };

    //通知转发消息 
    struct trans_server_msg_t : public jcmd_t<1002>
    {
        //服务器id,如果sid为0，则向所有scene广播
        uint32_t sid;
        //命令
        uint16_t msg_cmd;
        //消息 
        string msg;
        JSON3(trans_server_msg_t, sid, msg_cmd, msg)
    };

    //通知转发消息 
    struct trans_server_msg_ext_t : public jcmd_t<1012>
    {
        //服务器id,如果sids为空，则向所有scene广播
        vector<uint32_t> sids;
        //命令
        uint16_t msg_cmd;
        //消息 
        string msg;
        JSON3(trans_server_msg_ext_t, sids, msg_cmd, msg)
    };

    //请求服务器信息
    struct req_server_info_t : public jcmd_t<1003>
    { 
        JSON0(req_server_info_t)
    };

    //返回服务器信息
    struct ret_server_info_t : public jcmd_t<1004>
    {
        uint32_t sid;
        uint16_t cpu;
        uint16_t mem;
        uint16_t conn_num;
        JSON4(ret_server_info_t, sid, cpu, mem, conn_num);
    };
    
    //请求执行super命令
    struct req_su_cmd_t : public jcmd_t<1005>
    {
        string jcmd;
        JSON1(req_su_cmd_t, jcmd)
    };

    //返回super命令结果
    struct ret_su_cmd_t : public jcmd_t<1006>
    {
        string jresult;
        JSON1(ret_su_cmd_t, jresult)
    };

    //通知更新seskey
    struct nt_update_seskey_t :public jcmd_t<1007>
    {
        uint64_t old_seskey;
        uint64_t now_seskey;
        JSON2(nt_update_seskey_t, old_seskey, now_seskey)
    };

    //转发游戏消息
    struct trans_client_msg_t : public jcmd_t<1008>
    {
        uint64_t seskey;
        uint16_t msg_cmd;
        string msg;
        JSON3(trans_client_msg_t, seskey, msg_cmd, msg)
    };

    //转发到客户端
    struct unicast_t : public jcmd_t<1009>
    {
        uint64_t seskey;
        uint16_t msg_cmd;
        string msg;
        JSON3(unicast_t, seskey, msg_cmd, msg);
    };

    //二进制转发包到客户端
    struct unicast_bin_t : public jcmd_t<1010>
    {
        uint64_t seskey;
        string msg;

        unicast_bin_t& operator<< (const string& in_)
        {
            seskey = *((uint64_t*)in_.c_str());
            msg = std::move(string(in_.c_str()+sizeof(seskey), in_.size()-sizeof(seskey)));
            return *this;
        }
        unicast_bin_t& operator>>(string& out_)
        {
            out_.append((const char*)&seskey, sizeof(seskey));
            out_.append(msg);
            return *this;
        }
    };

    //通知关闭客户端会话
    struct nt_close_session_t : public jcmd_t<1100>
    {
        uint64_t seskey;
        JSON1(nt_close_session_t, seskey)
    };

    //设置转发
    struct nt_set_trans_t : public jcmd_t<1101>
    {
        uint64_t seskey;
        uint32_t sid;
        JSON2(nt_set_trans_t, seskey, sid)
    };

    //通知客户端会话断开
    struct nt_session_broken_t : public jcmd_t<1102>
    {
        uint64_t seskey;
        JSON1(nt_session_broken_t, seskey)
    };

    //通知角色被删除
    struct nt_role_deleted_t :  public jcmd_t<1200>
    {
        int uid;
        JSON1(nt_role_deleted_t, uid)
    };
    
    //通知支付到达
    struct nt_buy_yb_ok_t : public jcmd_t<1201>
    {
        uint32_t uid;
        uint32_t serid;
        JSON2(nt_buy_yb_ok_t, uid, serid)
    };

    //广播到客户端
    struct broadcast_t : public jcmd_t<1300>
    {
        uint16_t msg_cmd;
        string msg;
        JSON2(broadcast_t, msg_cmd, msg);
    };

    //gm转发消息 
    //通过trans server来转
    struct gm_msg_t : public jcmd_t<1301>
    {
        //gmid
        uint32_t gmid;
        //命令
        uint16_t msg_cmd;
        //消息 
        string msg;
        JSON3(gm_msg_t, gmid, msg_cmd, msg)
    };

    //角色封停通知
    struct nt_expel_t : public jcmd_t<1400>
    {
        int uid;
        JSON1(nt_expel_t, uid)
    };
    //角色禁言通知
    struct nt_notalk_t : public jcmd_t<1401>
    {
        int uid;
        int enable;
        JSON2(nt_notalk_t, uid, enable)
    };
    //客服邮件
    struct nt_gm_mail_t : public jcmd_t<1402>
    {
        int uid;
        JSON1(nt_gm_mail_t, uid)
    };
    //补偿通知
    struct nt_compensate_t: public jcmd_t<1403>
    {
        int uid;
        JSON1(nt_compensate_t, uid)
    };
    //通知场景服务器关闭时间
    struct nt_terminate_tm_t: public jcmd_t<1404>
    {
        uint32_t tm;
        JSON1(nt_terminate_tm_t, tm)
    };
    //紧急通知
    struct nt_notice_t : public jcmd_t<1405>
    {
        string msg;
        JSON1(nt_notice_t, msg)
    };

    //用户邮件
    struct nt_gmail_t : public jcmd_t<1406>
    {
        vector<int> uids;
        //jpk_gamil_t的json序列化字串
        string msg;
        JSON2(nt_gmail_t, uids, msg)
    };

    //通知重新加载
    struct nt_reload_t : public jcmd_t<1407>
    {
        int what; //1:repo,2:cfg
        JSON1(nt_reload_t, what);
    };

    //世界boss复活
    struct set_worldboss_alive_t : public jcmd_t<1408>
    {
        JSON0(set_worldboss_alive_t);
    };

    struct nt_reload_single_t : public jcmd_t<1409>
    {
        string what;
        JSON1(nt_reload_single_t, what);
    };

};

//登陆服务器消息 
struct lg_msg_def
{
    DEC_CMD_RANGE(2000, 3000)

    //请求登陆 
    struct req_mac_login_t : public jcmd_t<2000>
    {
        //客户端的平台账户id
        //Joyyou:等同mac
        //91:Uin字段
        string name;
        //客户端的mac地址
        string mac;
        //平台名
        string domain;
        //平台登陆信息
        //Joyyou:""
        //91:serialized 91_login_info_t 
        string jinfo;
        JSON4(req_mac_login_t, name, mac, domain, jinfo)
    };

    //返回登陆
    struct ret_login_t: public jcmd_t<2001>
    {
        //用户id
        int32_t aid;
        //上一次登陆
        int32_t hostnum;
        //返回码
        uint16_t code;
        JSON3(ret_login_t, aid, hostnum, code)
    };

    //角色信息
    struct jpk_role_t
    {
        int32_t uid;
        string nickname;
        int32_t resid;
        int32_t level;
        int32_t viplevel;
        int32_t weaponid;
        int32_t wingid;
        JSON7(jpk_role_t, uid, nickname, resid, level, viplevel, weaponid, wingid)
    };

    //请求获取角色列表
    struct req_rolelist_t : public jcmd_t<2002>
    {
        //账户id
        int32_t aid;
        //服务器号
        int32_t hostnum;
        //服务器id
        uint16_t serid;

        JSON3(req_rolelist_t, aid, hostnum, serid)
    };

    //返回角色列表
    struct ret_rolelist_t : public jcmd_t<2003>
    {
        //服务器号
        int32_t hostnum;
        //上一次登陆的角色
        int32_t lastuid;
        vector<jpk_role_t> rolelist;
        uint16_t code;
        JSON4(ret_rolelist_t, hostnum, lastuid, rolelist, code)
    };

    //请求创建角色
    struct req_new_role_t : public jcmd_t<2004>
    {
        //账户id
        int32_t aid;
        //服务器号
        int32_t hostnum;
        //角色名
        string name;
        //角色表id
        int32_t resid;

        JSON4(req_new_role_t, aid, hostnum, name, resid)
    };

    //返回角色创建结果
    struct ret_new_role_t : public jcmd_t<2005>
    {
        uint32_t uid;
        jpk_role_t role;
        uint16_t code;
        JSON3(ret_new_role_t, uid, role, code)
    };

    //删除角色
    struct req_del_role_t : public jcmd_t<2006>
    {
        int32_t uid;
        JSON1(req_del_role_t, uid)
    };

    //返回删除的角色
    struct ret_del_role_t : public jcmd_t<2007>
    {
        int32_t uid;
        int32_t code;
        JSON2(ret_del_role_t, uid, code)
    };
};

//网关消息
struct gw_msg_def
{
    DEC_CMD_RANGE(3000, 4000)

    //请求登陆网关
    struct req_login_t: public jcmd_t<3001>
    {
        uint64_t    seskey;
        JSON1(req_login_t, seskey)
    };

    //返回网关登陆
    struct ret_login_t: public jcmd_t<3002>
    {
        //返回码
        uint16_t code;
        JSON1(ret_login_t, code)
    };

    struct req_new_seskey_t: public jcmd_t<3004>
    {
        uint64_t seskey;
        JSON1(req_new_seskey_t, seskey)
    };

    struct ret_new_seskey_t : public jcmd_t<3005>
    {
        uint64_t seskey;
        uint16_t code;
        JSON2(ret_new_seskey_t, seskey, code)
    };

    //服务器列表
    struct jpk_gsinfo_t
    {
        int32_t     hostnum;
        uint16_t    serid;
        string      name;
        JSON3(jpk_gsinfo_t, hostnum, serid, name);
    };

    struct req_gslist_t : public jcmd_t<3006>
    {
        uint64_t seskey;
        JSON1(req_gslist_t, seskey)
    };

    struct ret_gslist_t : public jcmd_t<3007>
    {
        vector<jpk_gsinfo_t>  recom_gslist;
        vector<jpk_gsinfo_t>  gslist;
        JSON2(ret_gslist_t, gslist, recom_gslist)
    };

    //心跳
    struct nt_heartbeat_t : public jcmd_t<3008>
    {
        uint64_t seskey;
        JSON1(nt_heartbeat_t, seskey);
    };
    //心跳
    struct req_heartbeat_t : public jcmd_t<3009>
    {
        uint64_t seskey;
        JSON1(req_heartbeat_t, seskey);
    };
    struct ret_heartbeat_t : public jcmd_t<3010>
    {
        int32_t code;
        JSON1(ret_heartbeat_t, code);
    };

    //请求场景数量
    struct req_scene_num_t : public jcmd_t<3011>
    {
        JSON0(req_scene_num_t)
    };

    //返回场景数量
    struct ret_scene_num_t : public jcmd_t<3012>
    {
        int num;
        JSON1(ret_scene_num_t, num)
    };
};

struct rt_msg_def
{
    DEC_CMD_RANGE(6000, 7000)

    struct req_gw_t : public jcmd_t<6000>
    {
        JSON0(req_gw_t)
    };

    struct ret_gw_t : public jcmd_t<6001>
    {
        uint64_t seskey;
        string ip;
        string port;
        JSON3(ret_gw_t, seskey, ip, port)
    };
};

//场景消息
struct sc_msg_def
{
    DEC_CMD_RANGE(4000, 5999)

    //请求登陆游戏
    struct req_login_t : public jcmd_t<4000>
    {
        int32_t aid;
        int32_t uid;
        int32_t hostnum;
        uint16_t serid;
        //平台账户id
        string name;
        //平台名
        string domain;
        //mac地址
        string mac;
        //客户端所在系统,1,pc，2,android，3,ios
        int sys;
        //设备
        string device;
        //操作系统
        string os;
        //版本
//        string version;

        JSON10(req_login_t, aid, uid, hostnum, serid, name, domain, mac, sys, device, os)
    };

    //返回登陆
    struct ret_login_t : public jcmd_t<4001>
    {
        uint16_t code;
        int32_t  step; 
        JSON2(ret_login_t, code, step)
    };

    //角色属性
    struct jpk_role_pro_t
    {
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        int32_t cri;
        int32_t acc;
        int32_t dodge;
        int32_t fp;  //战斗力
        int32_t power;
        int32_t ten;
        float imm_dam_pro;
        float move_speed;
        vector<float> factor; // 5个因子
        float atk_power;
        float hit_power;
        float kill_power;
        float love_coefficient;
        float rank_coefficient;
        float p1_d;
        float p2_d;
        float p3_d;
        float p4_d;
        float p5_d;
        float p1_a;
        float p2_a;
        float p3_a;
        float p4_a;
        float p5_a;
        JSON29(jpk_role_pro_t, atk, mgc, def, res, hp, cri, acc, dodge, fp, power, ten, imm_dam_pro, move_speed, factor, atk_power, hit_power, kill_power, love_coefficient, rank_coefficient, p1_d, p2_d, p3_d, p4_d, p5_d, p1_a, p2_a, p3_a, p4_a, p5_a)
    };

    // 角色战斗属性
    struct jpk_role_fight_pro_t
    {
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        int32_t cri;
        int32_t acc;
        int32_t dodge;
        float ten;
        float imm_dam_pro;
        vector<float> factor;
        float atk_power;
        float hit_power;
        float kill_power;
        float love_coefficient;
        float rank_coefficient;
        float vip_coefficient;
        JSON17(jpk_role_fight_pro_t, atk, mgc, def, res, hp, cri, acc, dodge, ten, imm_dam_pro, factor, atk_power, hit_power, kill_power, love_coefficient, rank_coefficient, vip_coefficient)
    };

    
    //排行榜信息
    struct jpk_rank_t
    {
        int32_t rankindex;
        int32_t ranknum;
        int32_t uid;
        JSON3(jpk_rank_t, rankindex, ranknum, uid)
    };

    //角色等级
    struct jpk_role_lvl_t
    {
        int32_t level;
        int32_t exp;
        int32_t lovelevel;
        JSON3(jpk_role_lvl_t, level, exp, lovelevel)
    };

    //技能
    struct jpk_skill_t
    {
        int32_t skid;
        int32_t resid;
        int32_t level;
        JSON3(jpk_skill_t, skid, resid, level)
    };

    //道具
    struct jpk_item_t
    {
        int32_t itid;
        int32_t resid;
        int32_t num;
        JSON3(jpk_item_t, itid, resid, num)
    };
    //碎片
    struct jpk_chip_t
    {
        int32_t resid;
        int32_t count;
        JSON2(jpk_chip_t,resid,count);
    };
    //装备
    struct jpk_equip_t
    {
        int32_t eid;
        int32_t resid;
        yarray_t<int32_t, 5> gresids;
        int32_t strenlevel;
        bool isweared;
        JSON5(jpk_equip_t, eid, resid, gresids, strenlevel, isweared)
    };

    //翅膀
    struct jpk_wing_t
    {
        int wid;
        int resid;
        int atk;
        int mgc;
        int def;
        int res;
        int hp;
        int crit;
        int acc;
        int dodge;
        int lucky;
        JSON11(jpk_wing_t, wid, resid, atk, mgc, def, res, hp, crit, acc, dodge, lucky)
    };

    // 宠物
    struct jpk_pet_t
    {
        int32_t petid;
        int32_t resid;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        JSON7(jpk_pet_t, petid, resid, atk, mgc, def, res, hp)
    };

    //队伍
    struct jpk_team_t
    {
        int tid;
        string name;
        int pid1;
        int pid2;
        int pid3;
        int pid4;
        int pid5;
        int is_default;
        JSON8(jpk_team_t, tid, name, pid1, pid2, pid3, pid4, pid5, is_default);
    };

    //背包
    struct jpk_bag_t
    {
        vector<jpk_item_t> items;
        vector<jpk_equip_t> equips;
        vector<jpk_chip_t> chips;
        vector<jpk_wing_t> wings;
        JSON4(jpk_bag_t, items, equips, chips, wings);
    };
    //符文
    struct jpk_rune_t
    {
        int32_t pos;
        int32_t resid;
        int32_t exp;
        JSON3(jpk_rune_t, pos, resid, exp);
    };
    //符文怪物
    struct jpk_rune_monster_t
    {
        int32_t line;        //怪物线路,0~9,每次都会返回十个怪
        int32_t resid;       //怪物resid, resid=0,表示这条线路上没有怪物
        int32_t coat;        //怪物外套
        int32_t drop;        //怪物掉落
        JSON4(jpk_rune_monster_t,line,resid,coat,drop);
    };
    //角色星位
    struct jpk_star_t
    {
        int32_t lv;   //星座等级，特~四，0~4
        int32_t pos;   //星座位置，1~3
        int32_t att;   //属性种类
        int32_t value;   //属性值
        JSON4(jpk_star_t,lv,pos,att,value);
    };

    //角色数据
    struct jpk_role_data_t
    {
        int32_t pid;
        int32_t resid;
        int32_t job;
        //公会名称
        string ggname;
        //技能列表
        vector<jpk_skill_t> skls;
        //装备列表
        map<int32_t, jpk_equip_t> equips;
        //符文列表
        vector<jpk_rune_t> runes;
        //角色星座图
        vector<jpk_star_t> stars;
        //角色属性
        jpk_role_pro_t pro;
        //角色等级
        jpk_role_lvl_t lvl;
        //角色星级
        int32_t quality;
        int32_t viptype;
        //角色爱恋度值
        int32_t lovevalue;
        //角色潜力
        int32_t potential_1;
        int32_t potential_2;
        int32_t potential_3;
        int32_t potential_4;
        int32_t potential_5;
        int32_t naviClickNum1;
        int32_t naviClickNum2;

        //角色战历
        int32_t battexp;
        // 翅膀
        vector<jpk_wing_t> wings;
        // 宠物
        jpk_pet_t pet; 
        bool have_pet;
        //抽卡次数
        int32_t draw_num;
        int32_t kanban;
        int32_t kanban_type;
        int32_t draw_ten_diamond;
        string draw_reward;
        string round_stars_reward;
        int32_t season_rank;
        JSON29(jpk_role_data_t, pid, resid, skls, ggname, equips, runes, stars, pro, lvl, quality, lovevalue, potential_1, potential_2, potential_3, potential_4, potential_5, naviClickNum1, naviClickNum2, battexp, wings, pet, have_pet, draw_num, kanban, kanban_type, draw_ten_diamond, draw_reward, round_stars_reward, season_rank)
    };

    struct jpk_view_role_data_t
    {
        int uid;
        uint8_t job;
        //0主角，>0:伙伴pid
        int32_t pid;
        //角色表格id
        int32_t resid;
        //技能列表
        vector<jpk_skill_t> skls;
        //装备列表
        map<int, jpk_equip_t> equips;
        //角色属性
        jpk_role_pro_t pro;
        //角色等级
        jpk_role_lvl_t lvl;
        //角色星级
        int32_t quality;
        //角色潜力
        int32_t potential_1;
        int32_t potential_2;
        int32_t potential_3;
        int32_t potential_4;
        int32_t potential_5;
        //翅膀
        vector<jpk_wing_t> wings;

        jpk_view_role_data_t():resid(0){}

        JSON13(jpk_view_role_data_t, pid, resid, skls, equips, pro, lvl, quality, potential_1, potential_2, potential_3, potential_4, potential_5, wings);
    };

    struct jpk_combo_pro_view_t
    {
        float combo_d_down;
        float combo_r_down;
        float combo_d_up;
        float combo_r_up;
        map<int32_t, float> combo_anger;
        JSON5(jpk_combo_pro_view_t, combo_d_down, combo_r_down, combo_d_up, combo_r_up, combo_anger)
    };

    struct jpk_view_user_data_t
    {
        int                                   uid;
        string                                name;
        int                                   rank;
        int                                   lv;
        int                                   fp;
        int                                   viplevel;
        int                                   ggid;
        int32_t                               model;
        string                                ggname;
        map<int, jpk_view_role_data_t>        roles;
        //血量百分比
        float                                 hp_percent;
        jpk_combo_pro_view_t                  combo_pro;
        JSON12(jpk_view_user_data_t, uid, ggid, model,ggname, fp, name, rank, lv, viplevel, roles, hp_percent, combo_pro)
    };
    struct jpk_view_other_data_t
    {
        int                                   uid;
        int                                   resid;
        string                                name;
        int                                   rank;
        int                                   lv;
        int                                   fp;
        int                                   viplevel;
        int                                   ggid;
        int                                   draw_num;
        int                                   total_login_days;
        int                                   kanban;
        int                                   kanban_type;
        int                                   equip1_resid;
        int                                   equip2_resid;
        int                                   equip3_resid;
        int                                   equip4_resid;
        int                                   equip5_resid;
        int                                   strenlevel;
        int                                   lovelevel;
        int                                   quality;
        string                                ggname;
        jpk_team_t                            team;
        map<int, jpk_role_data_t>        roles;
        jpk_combo_pro_view_t                  combo_pro;
        //血量百分比
        float                                 hp_percent;
        JSON25(jpk_view_other_data_t, uid, resid, ggid, ggname, fp, name, rank, lv, viplevel, draw_num, total_login_days, kanban, kanban_type, equip1_resid, equip2_resid, equip3_resid, equip4_resid, equip5_resid, strenlevel, roles, hp_percent, team,lovelevel,quality,combo_pro)
    };

    struct jpk_fight_view_role_data_t
    {
        int32_t uid;
        int32_t pid;
        int32_t resid;
        vector<vector<int32_t>> skls;
        vector<float> pro;
        vector<int32_t> lvl; // 等级相关数据，各种等级
        jpk_fight_view_role_data_t():resid(0){}
        int32_t wid; // wings resid
        JSON7(jpk_fight_view_role_data_t,uid,pid,resid,skls,pro,lvl,wid)
    };

    struct jpk_fight_view_user_data_t
    {
        int uid;
        string name;
        int rank;
        int lv;
        int fp;
        int viplevel;
        map<int, jpk_fight_view_role_data_t> roles;
        jpk_combo_pro_view_t combo_pro;
        JSON8(jpk_fight_view_user_data_t,uid,name,rank,lv,fp,viplevel,roles,combo_pro)
    };
    
    struct sc_cave_t
    {
        int32_t n_enter;
        int32_t n_flush;
        sc_cave_t():n_enter(0),n_flush(0){}
        JSON2(sc_cave_t,n_enter,n_flush);
    };
    //关卡相关数据
    struct jpk_round_data_t
    {
        vector<int32_t>         passround;          //当前打过的限次关卡resid
    //    map<int32_t,int32_t>    round_flush;        //关卡组的刷新次数
        int32_t                 elite_flush;        //精英关卡的重置次数
        int32_t                 zodiac_flush;       //黄道十二宫的重置次数
        map<int32_t,int32_t>    zodiac;             //当前打过的每个宫的最高关卡(无效)

        int32_t                 cur_rid;            //普通关卡挂机:关卡resid
        int32_t                 seconds_need;       //both:总挂机剩余时间
        int32_t                 halt_times;         //both:剩余挂机次数
        int32_t                 halt_flag;          //both: -1,没有挂机，0,普通关卡，2,十二宫关卡
        int32_t                 halt_gid;           //十二宫挂机:组id(无效)
        int32_t                 roundid;            //当前关卡进度
        int32_t                 elite_roundid;      //当前精英关卡进度
        int32_t                 zodiacid;           //当前黄道十二宫进度
        int32_t                 eliteid;            //当前精英关卡进度
        string                  stars;              //所有关卡的评定信息, 索引为关卡id偏移，字符为当前关卡的评定等级
        string                  elite_round_times;  //精英关已打次数
        string                  elite_reset_times;  //精英关已重置次数
        int32_t                 cur_fp;             //今日获得的友情点总数
        // 矿
        int32_t                 cur_slot;           //当前占领的坑,如果没有占领，则为-1
        int32_t                 treasure;           //今日打过的最高巨龙宝库关卡
        int32_t                 max_treasure;           //今日打过的最高巨龙宝库关卡
        int32_t                 cur_slot_sec;       //当前占领的坑的占领时间
        int32_t                 debian_secs;        //今日还可以占坑的时间
        int32_t                 n_rob;              //今日已经打劫的次数
        int32_t                 n_help;             //今日协守次数
        int32_t                 cur_help_slot;      //当前协守的坑，没有则-1
        int32_t                 profit;             //当前所获得总收益
        int32_t                 treasure_reset_num;  //今日重置巨龙宝库的次数

        int32_t                 pass_round_left;    //普通关卡下一次可以挂机的剩余秒数
        int32_t					pass_cave_left;		//英雄迷窟关卡下一次可以挂机的剩余秒数--lewton--
		int32_t                 free_flush_elite;   //今天的免费刷新精英次数,-1,活动不开，>=0,刷新次数
        int32_t                 free_flush_zodiac;  //今天的免费刷新十二宫次数
        map<int32_t,sc_cave_t>  cave;               //英雄迷窟的进入次数
        int32_t                 caveid;             //当前迷窟进度
        int32_t                 limit_round_left;   //限时副本剩余次数
        //vector<int32_t>         limit_round_sec;    //限时副本冷却时间
        int32_t                 limit_round_sec;
        vector<int32_t>         limit_open_round;   //限时副本开放的副本
        int32_t                 limit_round_reset_times;
        //vector<int32_t>         limit_open_level;   //限时副本开放的关卡
        int32_t                 expedition_cur_round;  //远征当前进度关卡 
        int32_t                 expedition_max_round;  //远征当前进度总关卡 
        JSON39(jpk_round_data_t, passround, elite_flush, zodiac_flush, zodiac, cur_rid, seconds_need, halt_times, halt_flag, halt_gid, roundid,elite_roundid, zodiacid, eliteid,stars,elite_round_times,elite_reset_times,cur_fp,treasure,max_treasure,cur_slot,cur_slot_sec,debian_secs,n_rob,n_help,cur_help_slot,profit,pass_round_left,pass_cave_left,free_flush_elite,free_flush_zodiac,cave,caveid,limit_round_left,limit_round_sec,limit_open_round,limit_round_reset_times,expedition_cur_round,expedition_max_round, treasure_reset_num);
    };

    //英灵殿相关数据
    struct jpk_pub_data_t
    {
        int32_t left_sec1;
        int32_t round2;
        int32_t left_sec2;
        int32_t round3;
        int32_t left_sec3;
        JSON5(jpk_pub_data_t, left_sec1, round2, left_sec2, round3, left_sec3);
    };

    //请求用户数据
    struct req_user_data_t : public jcmd_t<4002>
    {
        int32_t uid;
        JSON1(req_user_data_t, uid)
    };
    
    struct jpk_lmt_event_item_t
    {
        vector<int32_t> item;
        JSON1(jpk_lmt_event_item_t, item)        
    };
    
    struct jpk_recharge_info_t
    {
        int32_t id;
        int32_t rmb;
        vector<vector<int32_t>> item;
        string description;
        string name;
        int32_t value;
        int32_t value2;
        int32_t times;
        JSON8(jpk_recharge_info_t, id, rmb, item, description, name, value, value2, times)
    };


    struct jpk_lmt_event_t
    {
        int32_t first_rmb;                   //首充多少可领取奖励
        int32_t can_get_first;               //是否可以领取首充大礼 
        uint32_t lmt_event_begin;            //限时活动开始时间戳
        uint32_t lmt_event_end;              //限时活动结束时间戳
        string lmt_event_begin_year;       //限时活动开始年份
        string lmt_event_begin_month;      //限时活动开始月份
        string lmt_event_begin_day;        //限时活动开始天数
        string lmt_event_end_year;         //限时活动结束年份
        string lmt_event_end_month;        //限时活动结束月份
        string lmt_event_end_day;          //限时活动结束天数
        vector <jpk_recharge_info_t> recharge_info; //限时活动奖励信息
        JSON11(jpk_lmt_event_t,first_rmb,can_get_first,lmt_event_begin,lmt_event_end,lmt_event_begin_year,lmt_event_begin_month,lmt_event_begin_day,lmt_event_end_year,lmt_event_end_month,lmt_event_end_day, recharge_info)
    };

    struct jpk_lmt_double_t
    {
        //包含新活动扩展
        string   sevenpay_stage;                         //七日充值的状态结果。
        uint32_t lmt_double_dailytask_begin;             //双倍每日任务开始的时间戳
        uint32_t lmt_double_dailytask_end;               //双倍每日任务结束的时间戳
        uint32_t lmt_double_stage_begin;                 //双倍普通副本物品开始的时间戳
        uint32_t lmt_double_stage_end;                   //双倍普通副本物品结束的时间戳
        uint32_t lmt_double_soul_begin;                  //双倍魂晶熔炼开始的时间戳
        uint32_t lmt_double_soul_end;                    //双倍魂晶熔炼结束的时间戳
        uint32_t lmt_double_expedition_begin;            //双倍远征开始的时间戳
        uint32_t lmt_double_expedition_end;              //双倍远程结束的时间戳
        uint32_t lmt_double_expedition_state;            //双倍远程活动的状态  0 此次远征的收益为原始收益  1 此次远征的收益双倍。
        uint32_t lmt_double_rate_high_stage_begin;       //双倍精英副本掉率开始的时间戳
        uint32_t lmt_double_rate_high_stage_end;         //双倍精英副本掉率结束的时间戳
        uint32_t lmt_double_high_stage_begin;            //双倍精英副本物品开始的时间戳
        uint32_t lmt_double_high_stage_end;              //双倍精英副本物品结束的时间戳 
        uint32_t lmt_double_rate_stage_begin;            //双倍普通副本掉率开始的时间戳
        uint32_t lmt_double_rate_stage_end;              //双倍普通副本掉率结束的时间戳    
        JSON16(jpk_lmt_double_t,sevenpay_stage,lmt_double_dailytask_begin,lmt_double_dailytask_end,lmt_double_stage_begin,lmt_double_stage_end,lmt_double_soul_begin,lmt_double_soul_end,lmt_double_expedition_begin,lmt_double_expedition_end,lmt_double_expedition_state,lmt_double_rate_stage_begin,lmt_double_rate_stage_end,lmt_double_rate_high_stage_begin,lmt_double_rate_high_stage_end,lmt_double_high_stage_begin,lmt_double_high_stage_end);
    };
   
    struct jpk_lmt_time_t
    {
        uint32_t lmt_event_begin;            //限时活动开始时间戳
        uint32_t lmt_event_end;              //限时活动结束时间戳
        JSON2(jpk_lmt_time_t,lmt_event_begin,lmt_event_end)
    };
    
    struct jpk_weekly_reward_t
    {
        int id;
        string name;
        string description;
        vector<int> vip;
        vector<vector<int>> reward;
        JSON5(jpk_weekly_reward_t, id, name,description, vip, reward)
    };

    struct jpk_online_reward_t
    {
        int id;
        int time;
        vector<vector<int>> reward;
        JSON3(jpk_online_reward_t, id, time, reward)
    };

    struct jpk_limit_activity_t
    {
        jpk_lmt_double_t limit_double_activity;
        int32_t limit_draw_ten;
        string limit_draw_ten_reward;
        string limit_wing_reward;
        jpk_lmt_event_t limit_draw_activity;
        jpk_lmt_event_t limit_wing_activity;
        int32_t limit_consume_power;
        string limit_consume_power_reward;
        jpk_lmt_event_t limit_power_activity;
        jpk_lmt_event_t limit_lucky_bag_activity;
        string luckybag_reward;
        jpk_lmt_event_t limit_growing_activity;
        int32_t limit_recharge_money;
        string limit_recharge_reward;
        jpk_lmt_event_t limit_recharge_activity;
        int32_t daily_draw_num;
        string daily_draw_reward;
        jpk_lmt_event_t daily_draw_activity;
        int32_t daily_consume_ap;
        string daily_consume_ap_reward;
        jpk_lmt_event_t daily_consume_activity;
        int32_t daily_melting_num;
        string daily_melting_reward;
        jpk_lmt_event_t daily_melting_activity;
        int32_t limit_melting_num;
        string limit_melting_reward;
        jpk_lmt_event_t limit_melting_activity;
        int32_t daily_talent_num;
        string daily_talent_reward;
        jpk_lmt_event_t daily_talent_activity;
        int32_t limit_talent_num;
        string limit_talent_reward;
        jpk_lmt_event_t limit_talent_activity;
        int32_t week_reward;
        vector<jpk_weekly_reward_t> weekly_info;
        int32_t online_cd;
        vector<jpk_online_reward_t> online_info;
        int32_t online;
        JSON38(jpk_limit_activity_t, limit_draw_ten, limit_draw_ten_reward, limit_wing_reward, limit_draw_activity, limit_wing_activity, limit_consume_power, limit_consume_power_reward, limit_power_activity, limit_lucky_bag_activity, luckybag_reward, limit_growing_activity, limit_recharge_money, limit_recharge_reward, limit_recharge_activity, daily_draw_num, daily_draw_reward, daily_draw_activity, daily_consume_ap, daily_consume_ap_reward, daily_consume_activity, daily_melting_num, daily_melting_reward, daily_melting_activity, limit_melting_num, limit_melting_reward, limit_melting_activity, daily_talent_num, daily_talent_reward, daily_talent_activity, limit_talent_num, limit_talent_reward, limit_talent_activity, week_reward, weekly_info, online_cd, online_info, online ,limit_double_activity);
    };

    struct jpk_limit_activity_ext_t
    {
        int32_t limit_single_recharge;
        string  limit_single_reward;
        jpk_lmt_event_t limit_single_activity;
        int32_t limit_pub;
        int32_t openybtotal;
        string openybreward;
        int32_t luckybagvalue;
        jpk_lmt_event_t openybactivity;
        jpk_lmt_event_t limit_seven_activity;
        string limit_seven_stage;
        JSON10(jpk_limit_activity_ext_t, limit_single_recharge,limit_single_reward,limit_single_activity, limit_pub, openybtotal, openybreward, luckybagvalue, openybactivity, limit_seven_activity, limit_seven_stage);
    };
    
    //活动相关标志位
    struct jpk_reward_data_t
    {
        int32_t rank;                       //竞技场奖励排名
        int32_t first_yb;                   //首次充值
        yarray_t<int32_t, 18>   vip_reward; //vip奖励领取记录
        yarray_t<int32_t, 7>    acc_yb;     //累计充值
        yarray_t<int32_t, 7>    con_lg;     //连续登录
        int32_t con_hero;                   //是否已经领取过英雄
        int32_t con_equip;                  //是否已经领取过装备
        yarray_t<int32_t, 24>    acc_lg;    //累计登录
        yarray_t<int32_t, 11>    lv_reward; //等级礼包
        int32_t acclgexp;                   //累计登录天数
        int32_t month;                      //累计登录奖励对应月份
        int32_t first_lg;                   //是否是当日首次登录
        int32_t sec_2_tom;                  //距离00:00的秒数
        int32_t cumureward;                 //累计30天登录活动奖励
        int32_t cumulevel;                  //累计30天登录活动等级
        int32_t fpreward;                   //战斗力冲刺奖励
        uint32_t server_ctime;              //服务器开服时间
        uint32_t cur_sec;                   //当前时间
        int32_t cumu_yb_exp;                //累计消费金额
        int32_t cumu_yb_reward;             //累计消费奖励领取情况
        int32_t daily_pay;                  //当日充值
        int32_t daily_pay_reward;           //当日充值领奖情况
        jpk_lmt_event_t recharge_back;
        int32_t mcard_event_buy_count;      //活动月卡购买次数
        int32_t mcard_event_state;          //活动月卡状态
        jpk_lmt_time_t mcard_event_time;    //活动月卡时间
        int32_t lg_days;                    //连续登录天数
        string  loginrewards;               //次日奖励状态
        int32_t total_login_days;           //连续登录天数
        int32_t isshowtoday;                //是否显示次日奖励，0没显示过，1显示过了
        int32_t wingactivity;               //获得翅膀活动状态
        int32_t wingactivityreward;         //获得翅膀活动奖励状态
        uint32_t servercreatestamp;          //服务器创建时间戳
        int32_t growing_package_status;      //成长计划礼包购买状态
        string growing_reward;               //成长计划奖励领取状态      
        int32_t is_consume_hundred;         //是否单笔充值100或者以上
        jpk_limit_activity_t limit_activity;   //限时活动
        jpk_limit_activity_ext_t limit_activity_ext;  //限时活动ext
        int32_t pvelose_times;              //pve失败次数
        JSON39(jpk_reward_data_t,rank, first_yb, vip_reward, acc_yb,con_lg,con_hero,con_equip,acc_lg,lv_reward,acclgexp,month,first_lg,sec_2_tom,cumureward,cumulevel,fpreward,server_ctime,cur_sec,cumu_yb_exp,cumu_yb_reward, daily_pay, daily_pay_reward, wingactivity, wingactivityreward, servercreatestamp, recharge_back, mcard_event_buy_count, mcard_event_state, mcard_event_time, lg_days, loginrewards, total_login_days, growing_package_status, growing_reward,  isshowtoday, is_consume_hundred, limit_activity,limit_activity_ext, pvelose_times);
    };
   
    struct jpk_guwu_t
    {
        float v;
        uint32_t    progress;
        uint32_t    stamp_v;
        uint32_t    stamp_yb;
        uint32_t    stamp_coin;
        JSON5(jpk_guwu_t, v, progress, stamp_v, stamp_yb, stamp_coin)
    };

    struct jpk_soulnode_t
    {
        map<int,int> soul_node_point;
        JSON1(jpk_soulnode_t, soul_node_point)
    };


    struct n_primary_t
    {
        int32_t n_friend;           //好友请求数
        int32_t n_pvp;              //竞技场剩余次数
        int32_t n_pray;             //公会祭祀次数
        int32_t n_dtask;            //日常任务次数
        int32_t n_trial;            //试炼次数
        int32_t n_gang_req;         //帮会申请次数
        int32_t n_gmail_unopend;    //未读的邮件
        int32_t n_gmail_isrewardEmail; //是否有未领取邮件
        int32_t n_golden_box;       //当天黄金宝箱开启次数
        int32_t n_silver_box;       //当天白银宝箱开启次数
        int32_t n_twoprecord;       //tw用户操作记录
        map<int, jpk_guwu_t>   n_guwu;   //鼓舞加成百分比
        int32_t soulvalue;
        int32_t soulranknum;
        int32_t soulid;
        map<int, jpk_soulnode_t>  soul_node_infos;
        float   zodiac_hp_percent;
        float   scuffle_hp_percent;
        JSON18(n_primary_t,n_friend, n_pvp, n_pray, n_dtask, n_trial, n_gang_req, n_gmail_unopend, n_gmail_isrewardEmail, n_golden_box, n_silver_box, n_twoprecord, n_guwu, zodiac_hp_percent, scuffle_hp_percent, soulvalue, soulranknum, soulid, soul_node_infos);
    };

    struct jpk_task_t
    {
        int resid;
        //对话任务,step:0未完成，1完成
        //收集任务,step:为收集到的道具总数
        //打怪任务,step:为消灭怪物的总数
        int step;
        JSON2(jpk_task_t, resid, step)
    };

    struct jpk_main_task_t
    {
        int32_t questid; //最后完成的主线任务
        int32_t nextquestid; //下一个可接主线任务
        JSON2(jpk_main_task_t, questid, nextquestid)
    };

    /* 竞技场相关的一些东东 */
    struct jpk_arena_t 
    {
        int32_t honor;
        int32_t unhonor;
        int32_t title_lv;
        int32_t meritorious;
        JSON4(jpk_arena_t, honor, unhonor, meritorious, title_lv)
    };

    // 远征数据
    struct jpk_expedition_data_t
    {
        int32_t expeditioncoin;
        int32_t reset_num; // 每日重置次数
        JSON2(jpk_expedition_data_t, expeditioncoin, reset_num)
    };

    // 编年史数据
    struct jpk_chronicle_data_t
    {
        int32_t chronicle_sum;  // 签到总天数
        bool    is_sign;        // 今日是否已签到
        JSON2(jpk_chronicle_data_t, chronicle_sum, is_sign)
    };

    //新手引导相关数据
    struct jpk_userguide_t
    {
        int32_t isnew;
        int32_t isnewlv;
        int32_t viptype;
        vector<jpk_rank_t>  rankinfo;
        JSON4(jpk_userguide_t, isnew, isnewlv, rankinfo, viptype)
    };

    struct jpk_card_event_partner_t
    {
        int32_t pid;
        float   hp;
        JSON2(jpk_card_event_partner_t, pid, hp)
    };

    struct jpk_card_event_team_t
    {
        int32_t anger;
        vector<jpk_card_event_partner_t> actors;
        JSON2(jpk_card_event_team_t, anger, actors)
    };
    
    /* 玩家活动相关数据 */
    struct jpk_card_event_t
    {
        bool is_open;
        bool is_close;
        int32_t event_id;
        int32_t score;
        int32_t coin;
        int32_t goal_level;
        int32_t round;
        int32_t round_status;
        int32_t round_max;
        int32_t rank;
        string begin_month;
        string begin_day;
        string begin_hour;
        string end_month;
        string end_day;
        string end_hour;
        jpk_card_event_team_t team;
        vector<jpk_card_event_partner_t> partners;
        int32_t difficult;
        int32_t open_times;
        int32_t open_level;
        int32_t next_count;
        int32_t is_first_enter;
        uint32_t begin_stamp;
        uint32_t end_stamp;
        JSON25(jpk_card_event_t, is_open, is_close, event_id, score, coin, goal_level,
               round, round_status, round_max, rank, team, partners, begin_month, begin_day, begin_hour, end_month, end_day, end_hour, difficult, open_times, open_level,next_count,is_first_enter,begin_stamp,end_stamp)
    };

    /* 神器 奇物 连击强化系统 */
    struct jpk_combo_pro_t
    {
        int32_t c1_level;
        int32_t c2_level;
        int32_t c3_level;
        int32_t c4_level;
        int32_t c5_level;
        int32_t c1_exp;
        int32_t c2_exp;
        int32_t c3_exp;
        int32_t c4_exp;
        int32_t c5_exp;
        JSON10(jpk_combo_pro_t, c1_level, c2_level, c3_level, c4_level, c5_level, c1_exp, c2_exp, c3_exp, c4_exp, c5_exp)
    };

    struct jpk_new_rune_t
    {
        int32_t id;
        int32_t lv;
        int32_t resid;
        int32_t exp;
        int32_t page;
        JSON5(jpk_new_rune_t, id, lv, resid, exp, page)
    };
/*
    struct jpk_rune_page_slot_t
    {
        int32_t slot;
        int32_t id;
        JSON2(jpk_rune_page_slot_t, slot, id)
    };
    */

    struct jpk_rune_page_t
    {
        map<int32_t, int32_t> page_info;
        JSON1(jpk_rune_page_t, page_info)
    };
    
    struct jpk_rune_info_t
    {
        vector<jpk_new_rune_t>  rune_list;
        map<int32_t, jpk_rune_page_t> rune_page;
        JSON2(jpk_rune_info_t, rune_list, rune_page)
    };

    /* 玩法活动 */
    struct jpk_function_t
    {
        jpk_card_event_t card_event;
        jpk_combo_pro_t combo_pro; 
        jpk_rune_info_t rune_info;
        int32_t model;
        JSON4(jpk_function_t, card_event, combo_pro, rune_info, model);
    };
    struct last_chat_role_info
    {
        int32_t uid;
        int32_t grade;
        int32_t resid;
        string name;
        int32_t lovelevel;
        int32_t stmp;
        JSON6(last_chat_role_info,uid,grade,resid,name,lovelevel,stmp)
    };

    /* 格外数据 */
    struct jpk_extra_data_t
    {
        int32_t                 dayofweek; //周几
        int32_t                 vip_days;
        int32_t                 vip_stamp;
        int32_t                 cur_0_stamp;
        int32_t                 isSend;   //feedback 是否反馈
        bool                 is_pub_4;
        vector<last_chat_role_info> last_chat_info; //最后聊天的玩家
        JSON7(jpk_extra_data_t, dayofweek, vip_days, vip_stamp, cur_0_stamp,isSend,is_pub_4,last_chat_info);
    };


    struct ret_user_data_t : public jcmd_t<4003>
    {
        int32_t                 uid;
        string                  name;
        int32_t                 viplevel;
        int32_t                 vipexp;
        int32_t                 money;
        int32_t                 rmb;
        int32_t                 power;
        int32_t                 energy;
        int32_t                 fpoint;
        int32_t                 soul;             //灵能
        int32_t                 runechip;
        jpk_userguide_t         userguide; //新手引导及称号数据
        int32_t                 sceneid; //角色所在的主城id
        int32_t                 x,y;

        jpk_chronicle_data_t    chronicle;
        jpk_role_data_t         role;
        vector<jpk_role_data_t> partners;
        jpk_round_data_t        round;    
        /* 新增加的玩法及活动的相关数据请在该结构体内添加:) */
        jpk_function_t          functions; /* 各种功能玩法 */

        int32_t                 left_power_secons;
        int32_t                 left_energy_secons;
        jpk_bag_t               bag;
        vector<jpk_team_t>      team; //0:uid, >0:pid, -1:未使用位置
        jpk_arena_t             arena;
        jpk_expedition_data_t   expedition;
        n_primary_t             counts;   //主界面请求数
        jpk_main_task_t         main_task;
        int32_t                 ggid; //公会id
        jpk_reward_data_t       reward; //奖励信息
        int32_t                 isinvited;  //是否已经设置过邀请人
        int32_t                 bagn;        //背包大小
        int32_t                 wb_start;         //世界boss开始时间
        jpk_extra_data_t        extra_data;
        uint64_t                func;         //新手引导相关标志位
        vector<jpk_task_t>      tasks;
        int32_t                 pay_rmb;        //玩家离线期间充值的水晶
        jpk_pub_data_t          pub;
        int32_t                 first_pay; //首次充值
        JSON39(ret_user_data_t, uid, name, viplevel, vipexp, money, rmb, power,
               energy, fpoint, soul, runechip, userguide, sceneid, x, y, 
               chronicle, role, bag, partners, round, functions, 
               left_power_secons, left_energy_secons, team, arena, expedition,
               counts, main_task, ggid, reward, isinvited,bagn,wb_start, 
               extra_data, func, tasks, pay_rmb, pub, first_pay
              );
    };

    struct ret_user_data_failed_t : public jcmd_t<4003>
    {
        int32_t uid;
        uint16_t code;
        JSON2(ret_user_data_failed_t, uid, code)
    };

    //通知客户端背包改变, 改变的道具和装备
    struct nt_bag_change_t : public jcmd_t<4006>
    {
        vector<jpk_chip_t> chips; 
        vector<jpk_item_t> items;
        vector<jpk_equip_t> add_equips;
        vector<jpk_equip_t> del_equips;
        vector<jpk_wing_t> add_wings;
        vector<jpk_wing_t> del_wings;
        vector<jpk_pet_t> add_pet;
        JSON7(nt_bag_change_t, items, add_equips, del_equips, chips, add_wings, del_wings, add_pet);
    };

    //进入主城
    struct req_enter_city_t : public jcmd_t<4007>
    {
        int32_t resid;
        int32_t show_player_num;
        JSON2(req_enter_city_t, resid, show_player_num)
    };
    //返回进入主城
    struct ret_enter_city_t : public jcmd_t<4008>
    {
        int32_t code;
        int32_t x, y;
        int32_t sceneid;
        JSON4(ret_enter_city_t, code, x, y, sceneid)
    };
    //进入乱斗场返回
    struct ret_enter_scuffle_t : public jcmd_t<4008>
    {
        int32_t code;
        int32_t x, y;
        int32_t sceneid;
        int32_t n_win;
        int32_t n_con_win;
        JSON6(ret_enter_scuffle_t, code, x, y, sceneid,n_win,n_con_win);
    };
    //角色移动
    struct nt_move_t : public jcmd_t<4009>
    {
        int32_t uid;
        int32_t sceneid;
        int32_t x, y;
        JSON4(nt_move_t, uid, sceneid, x, y);
    };

    //角色传送
    struct nt_transport_t : public jcmd_t<4010>
    {
        int32_t uid;
        int32_t sceneid;
        int32_t x, y;
        JSON4(nt_transport_t, uid, sceneid, x, y);
    };

    //角色出现
    struct nt_user_in_t : public jcmd_t<4011>
    {
        int32_t uid;
        int32_t resid;
        string name;
        int32_t level;
        int32_t viplevel;
        int32_t weaponid;
        int32_t wingid;
        int32_t quality;
        int32_t viptype;
        int32_t x, y;
        bool have_pet;
        int32_t petid;
        vector<jpk_rank_t> rankinfo;
        string gangname;
        int32_t season_rank;
        int32_t model;
        JSON17(nt_user_in_t, uid, resid, name, level, viplevel, weaponid,quality, wingid, x, y, have_pet, petid, gangname, rankinfo, season_rank, viptype, model)
    };

    //角色消失
    struct nt_user_out_t : public jcmd_t<4012>
    {
        int32_t uid;
        JSON1(nt_user_out_t, uid);
    };

    //请求进入关卡
    struct req_begin_round_t : public jcmd_t<4013>
    {
        //关卡id
        int32_t resid;
        int32_t flag; //0-普通，1-精英, 2-十二宫关卡
        int32_t uid;
        int32_t pid;
        JSON4(req_begin_round_t, resid, flag, uid,pid);
    };

    //返回请求进入关卡
    struct ret_begin_round_t : public jcmd_t<4014>
    {
        int32_t resid;
        uint16_t code;
        vector<jpk_item_t> drop_items;
        int32_t exp;
        int32_t coin;
        int32_t rmb;
        jpk_view_role_data_t hhero;
        JSON7(ret_begin_round_t, resid, code, drop_items, exp, coin, rmb,hhero);
    };

    //返回请求进入关卡失败
    struct ret_begin_round_failed_t : public jcmd_t<4014>
    {
        uint16_t code;
        JSON1(ret_begin_round_failed_t, code);
    };

    struct jpk_round_monster_t;
    
    //通知关卡结果
    struct nt_end_round_t : public jcmd_t<4015>
    {
        int32_t resid;
        bool win;
        int32_t stars;
        vector<jpk_round_monster_t> killed;
        JSON4(nt_end_round_t, resid, win, stars, killed)
    };

    //通知体力改变
    struct nt_power_change_t : public jcmd_t<4016>
    {
        //当前值
        int32_t now;
        int32_t is_in_limit_activity;
        string limit_consume_power_reward;
        int32_t limit_consume_power;
        JSON4(nt_power_change_t, now, is_in_limit_activity, limit_consume_power_reward, limit_consume_power) 
    };

    //通知阵型改变
    struct nt_team_change_t : public jcmd_t<4017> 
    {
        //出站序列, 0:uid，>0:pid, -1:未使用的位置
        int32_t tid;
        yarray_t<int32_t, 5> team;
        JSON2(nt_team_change_t, team, tid)
    };

    //通知升级
    struct nt_levelup_t : public jcmd_t<4018>
    {
        //伙伴dbid， 如果为0,则为主角
        int32_t pid;
        //当前等级
        int32_t level;
        string growing_reward;
        JSON3(nt_levelup_t, pid, level, growing_reward)
    };

    //通知金币改变
    struct nt_money_change_t : public jcmd_t<4019>
    {
        //当前值
        int32_t now;
        JSON1(nt_money_change_t, now)
    };

    //通知水晶改变
    struct nt_yb_change_t : public jcmd_t<4020> 
    {
        int32_t now;
        JSON1(nt_yb_change_t, now);
    };

    //通知角色属性改变
    struct nt_role_pro_change_t : public jcmd_t<4021>
    {
        //伙伴dbid， 如果为0,则为主角
        int32_t pid;
        //角色当前属性
        jpk_role_pro_t pro;
        JSON2(nt_role_pro_change_t, pid, pro)
    };

    //通知角色战斗属性改变
    struct nt_role_fight_pro_change_t : public jcmd_t<7855>
    {
        //伙伴dbid， 如果为0,则为主角
        int32_t pid;
        //角色当前属性
        jpk_role_fight_pro_t f_pro;
        JSON2(nt_role_fight_pro_change_t, pid, f_pro)
    };

    //通知角色经验改变
    struct nt_exp_change_t : public jcmd_t<4022>
    {
        //伙伴dbid， 如果为0,则为主角
        int32_t pid;
        int32_t now;
        JSON2(nt_exp_change_t, pid, now)
    };

    //请求挂机
    struct req_begin_auto_round_t : public jcmd_t<4023>
    {
        //关卡id
        int32_t resid;
        //重复战斗次数
        int32_t repeat_num;
        JSON2(req_begin_auto_round_t, resid, repeat_num)
    };

    //返回关卡挂机请求
    struct ret_begin_auto_round_t : public jcmd_t<4024>
    {
        //0成功，其他都不成功
        uint16_t code;
        JSON1(ret_begin_auto_round_t, code);
    };

    //请求一次挂机结果
    struct req_auto_round_resu_t : public jcmd_t<4025>
    {
        //关卡id
        int32_t resid;
        //0-计时,1-付费
        int32_t flag;
        JSON2(req_auto_round_resu_t, resid, flag);
    };

    //返回一次挂机结果
    struct ret_auto_round_resu_t : public jcmd_t<4026>
    {
        //当前次数
        uint16_t num;
        //掉落道具
        vector<jpk_item_t> drop_items;
        //经验
        int32_t exp;
        //金币
        int32_t coin;
        //水晶
        int32_t rmb;
        JSON5(ret_auto_round_resu_t, num, drop_items, exp, coin, rmb);
    };

    //请求挂机结果失败
    struct ret_auto_round_resu_failed_t : public jcmd_t<4026>
    {
        uint16_t code;
        JSON1(ret_auto_round_resu_failed_t, code);
    };

    //请求结束挂机
    struct nt_stop_auto_round_t : public jcmd_t<4027>
    {
        int32_t resid;
        JSON1(nt_stop_auto_round_t, resid);
    };
    //请求刷新精英关卡和黄道十二宫关卡
    struct req_flush_round_t : public jcmd_t<4028>
    {
        //黄道十二宫关卡 gid=300
        //精英关卡 实际gid
        uint16_t gid;
        JSON1(req_flush_round_t, gid);
    };

    //返回刷新关卡
    struct ret_flush_round_t : public jcmd_t<4029>
    {
        uint16_t code;
        int32_t gid;
        JSON2(ret_flush_round_t, code, gid );
    };

    //wear equip
    struct req_wear_equip_t : public jcmd_t<4030>
    {
        int32_t pid; //主角为0
        int32_t eid;
        int32_t flag; //0:off, 1:on
        int32_t slot_pos;
        JSON4(req_wear_equip_t, pid, eid, flag, slot_pos)
    };

    struct ret_wear_equip_t : public jcmd_t<4031>
    {
        int32_t code;
        int32_t pid;
        int32_t eid;
        int32_t flag; //0:off, 1:on
        int32_t slot_pos;
        jpk_equip_t weared_equip;
        JSON6(ret_wear_equip_t, pid, eid, flag, code, slot_pos, weared_equip)
    };

    //upgrade equip
    struct req_upgrade_equip_t : public jcmd_t<4032>
    {
        int32_t eid; 
        //强化次数
        int32_t num;
        JSON2(req_upgrade_equip_t, eid, num)
    };

    struct ret_upgrade_equip_t : public jcmd_t<4033>
    {
        int32_t pid;
        jpk_equip_t equip;
        JSON2(ret_upgrade_equip_t, pid, equip)
    };

    struct ret_upgrade_equip_failed_t : public jcmd_t<4033>
    {
        int32_t eid;
        int32_t code;
        JSON2(ret_upgrade_equip_failed_t, eid, code)
    };

    //compose equip
    struct req_compose_equip_t : public jcmd_t<4034>
    {
        int32_t eid;
        //强化后的装备id
        int32_t dst_resid;
        JSON2(req_compose_equip_t, eid, dst_resid)
    };
    
    //compose equip
    struct req_compose_equip_yb_t : public jcmd_t<4036>
    {
        int32_t eid;
        //强化后的装备id
        int32_t dst_resid;
        JSON2(req_compose_equip_yb_t, eid, dst_resid)
    };

    struct ret_compose_equip_t : public jcmd_t<4035>
    {
        int32_t pid;
        jpk_equip_t equip;
        JSON2(ret_compose_equip_t, pid, equip)
    };

    struct ret_compose_equip_failed_t : public jcmd_t<4035>
    {
        int32_t eid;
        int32_t code;
        JSON2(ret_compose_equip_failed_t, eid, code)
    };

    //gemstone
    struct req_gemstone_compose_t : public jcmd_t<4037>
    {
        //原料宝石
        int32_t src_resid;
        //合成数量
        int32_t compose_num;
        //是否使用保护石, 0不使用，1使用，2不足则直接用元宝购买
        int32_t  safe;
        JSON3(req_gemstone_compose_t, src_resid, compose_num, safe)
    };

    struct ret_gemstone_compose_t : public jcmd_t<4038>
    {
        jpk_item_t src;
        jpk_item_t dst;
        int fail;
        JSON3(ret_gemstone_compose_t, src, dst, fail)
    };

    struct ret_gemstone_compose_failed_t : public jcmd_t<4038>
    {
        int32_t code;
        JSON1(ret_gemstone_compose_failed_t, code)
    };

    struct req_gemstone_inlay_t : public jcmd_t<4039>
    {
        int32_t resid;
        int32_t pageid;
        int32_t slotid;
        int32_t flag; //1-装上宝石, 2-道具卸下宝石, 3-水晶卸下 
        JSON4(req_gemstone_inlay_t, resid, pageid, slotid, flag)
    };

    struct ret_gemstone_inlay_t : public jcmd_t<4040>
    {
        int32_t code;
        int32_t resid;
        int32_t pageid;
        int32_t slotid;
        int32_t flag; //1-装上宝石, 2-道具卸下宝石, 3-水晶卸下 
        JSON5(ret_gemstone_inlay_t, code, resid, pageid, slotid, flag)
    };
    
    struct req_gemstone_inlay_all_t : public jcmd_t<5400>
    {
        int32_t flag; //1-镶嵌宝石 2-卸下宝石
        vector<vector<int32_t>> eg;
        JSON2(req_gemstone_inlay_all_t, flag, eg)
    };

    struct ret_gemstone_inlay_all_t : public jcmd_t<5401>
    {
        int32_t code;
        int32_t flag; //1-镶嵌宝石 2-卸下宝石
        vector<vector<int32_t>> eg;
        JSON3(ret_gemstone_inlay_all_t, code, flag, eg)
    };

    struct req_gemstone_syn_all_t : public jcmd_t<5422>
    {
        int32_t type_gem;
        JSON1(req_gemstone_syn_all_t, type_gem)
    };

    struct ret_gemstone_syn_all_t : public jcmd_t<5423>
    {
        int32_t flag;
        JSON1(ret_gemstone_syn_all_t, flag)
    };

    struct ret_gemstone_inlay_failed_t : public jcmd_t<4040>
    {
        int32_t resid;
        int32_t eid;
        int32_t slotid;
        int32_t flag; //1-装上宝石, 2-道具卸下宝石, 3-水晶卸下 
        int32_t code;
        JSON5(ret_gemstone_inlay_failed_t, resid, eid, slotid, code, flag)
    };

    struct req_gemstone_slot_open_t : public jcmd_t<4041>
    {
        int32_t eid;
        int32_t slotid;
        JSON2(req_gemstone_slot_open_t, eid, slotid)
    };

    struct ret_gemstone_slot_open_t : public jcmd_t<4042>
    {
        int32_t code;
        int32_t eid;
        int32_t slotid;
        JSON3(ret_gemstone_slot_open_t, code, eid, slotid)
    };

    struct gem_page
    {
        map<int32_t, int32_t> slot_map;
        JSON1(gem_page, slot_map)
    };

    struct req_gem_page_info_t : public jcmd_t<6850>
    {
        JSON0(req_gem_page_info_t)
    };

    struct ret_gem_page_info_t : public jcmd_t<6851>
    {
        int32_t code;
        map<int32_t, gem_page> gem_page_map;
        JSON2(ret_gem_page_info_t, code, gem_page_map)
    };

    //酒馆伙伴信息
    struct jpk_pub_partner_t
    {
        int32_t resid;
        bool hired;
        int32_t potential;
        int32_t rare;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        int32_t cri;
        int32_t acc;
        int32_t dodge;
        int32_t fp;
        int32_t old;
        JSON14(jpk_pub_partner_t, resid, hired, potential, rare, atk, mgc, def, res, hp, cri, acc, dodge, fp, old)
    };

    struct jpk_pub_chip_t
    {
        int32_t resid;   	// res id
        int32_t count;		
        int32_t reduced;	// 碎片，1：分解的  0：直接抽的
        JSON3(jpk_pub_chip_t,resid,count,reduced);
    };
    //请求刷新酒馆
    struct req_pub_flush_t : public jcmd_t<4046>
    {
        //flag
        // 1 金币抽1次
        // 2 金币抽10次
        // 3 钻石抽1次
        // 4 钻石抽10次
        // 5 神秘抽1次
        // 6 神秘抽10次
        int32_t flag;
        JSON1(req_pub_flush_t, flag);
    };
    //返回请求酒馆信息
    struct ret_pub_flush_t : public jcmd_t<4047>
    {
        int32_t flag;
        int32_t left_flush_seconds;
        vector<jpk_pub_chip_t> chips;
        vector<jpk_role_data_t> partners;
        vector<jpk_item_t> items;
        int32_t draw_num;   //次数
        int32_t is_ten_diamond;
        string draw_reward;
        string limit_draw_reward;    //限时十连
        int32_t is_in_limit_activity;
        int32_t flush1times;
        int32_t stepup_state;
        int32_t event_state;
        bool  is_pub_4;
        JSON13(ret_pub_flush_t,left_flush_seconds,chips,partners,items, draw_num, is_ten_diamond, draw_reward, limit_draw_reward, is_in_limit_activity, flush1times, stepup_state, event_state, is_pub_4)
    };
    struct ret_pub_flush_failed_t : public jcmd_t<4047>
    {
        int32_t code;
        JSON1(ret_pub_flush_failed_t, code)
    };
    struct req_enter_pub_t : public jcmd_t<6900>
    {
        JSON0(req_enter_pub_t)
    };
    struct ret_enter_pub_t : public jcmd_t<6901>
    {
        int32_t code;
        int32_t flush1times;
        int32_t flush1lasttime;
        int32_t flush2lasttime;
        bool flush3flag;
        bool flush4flag;
        int32_t stepup_state;
        int32_t event_state;
        JSON8(ret_enter_pub_t, code, flush1times, flush1lasttime, flush2lasttime, flush3flag, flush4flag, stepup_state, event_state)
    };
    //请求返回免费时间
    struct req_pub_time_t : public jcmd_t<5048>
    {
        JSON0(req_pub_time_t)
    };
    struct ret_pub_time_t : public jcmd_t<5049>
    {
        int32_t left_sec1;
        int32_t left_sec2;
        int32_t left_sec3;
        JSON3(ret_pub_time_t, left_sec1, left_sec2, left_sec3)
    };
    /*
    //获取当天的限时金色英雄碎片
    struct req_gold_chip_t : public jcmd_t<4048>
    {
        JSON0(req_gold_chip_t);
    };
    struct ret_gold_chip_t : public jcmd_t<4049>
    {
        int32_t gold_chip;
        JSON1(ret_gold_chip_t,gold_chip);
    };
    */
    /*
    //雇佣伙伴
    struct req_hire_partner_t : public jcmd_t<4048>
    {
        int32_t pos;
        JSON1(req_hire_partner_t, pos);
    };
    struct ret_hire_partner_t : public jcmd_t<4049>
    {
        int32_t pos;
        jpk_role_data_t partner;
        JSON2(ret_hire_partner_t, pos, partner);
    };
    struct ret_hire_partner_failed_t : public jcmd_t<4049>
    {
        int32_t code;
        JSON1(ret_hire_partner_failed_t, code);
    };
    */
    //请求每半小时体力增长
    struct req_gen_power_t : public jcmd_t<4050>
    {
        JSON0(req_gen_power_t)
    };
    struct ret_gen_power_t : public jcmd_t<4051>
    {
        int32_t left_gen_seconds;
        int32_t power;
        JSON2(ret_gen_power_t,left_gen_seconds,power)
    };
    //请求离线经验
    struct req_offline_exp_t : public jcmd_t<4052>
    {
        JSON0(req_offline_exp_t)
    };
    struct jpk_trial_task_t
    {
        int32_t taskid;
        int32_t rewardid;
        JSON2(jpk_trial_task_t, taskid, rewardid)
    };
    struct jpk_trial_target_info_t
    {
        int32_t uid;
        int32_t resid;
        string name;
        int32_t lv;
        int32_t fp;
        int32_t win;
        JSON6(jpk_trial_target_info_t, uid, resid, name, lv, fp, win)
    };
    struct jpk_trial_info_t
    {
        //0 未接任务
        //1 已接任务
        //2 正在战斗
        int32_t current_stage;
        //已经打赢的对手数
        int32_t successed_target;
        //已经接受的任务
        int32_t current_task;
        //试炼场任务
        vector<jpk_trial_task_t> tasks;
        //当前已接任务的对手
        vector<jpk_trial_target_info_t> targets;
        //刷新任务倒计时
        int32_t left_secs;
        JSON6(jpk_trial_info_t, current_stage, successed_target, current_task, tasks, targets, left_secs)
    };
    //请求试炼场信息
    struct req_trial_info_t : public jcmd_t<4053>
    {
        JSON0(req_trial_info_t)
    };
    struct ret_trial_info_t : public jcmd_t<4054>
    {
        jpk_trial_info_t trial;
        JSON1(ret_trial_info_t, trial)
    };
    //试炼场接任务
    struct req_trial_receive_task_t : public jcmd_t<4055>
    {
        int32_t pos;
        JSON1(req_trial_receive_task_t, pos)
    };
    struct ret_trial_receive_task_t : public jcmd_t<4056>
    {
        vector<jpk_trial_target_info_t> targets;
        JSON1(ret_trial_receive_task_t, targets)
    };
    //试炼场放弃任务
    struct req_trial_giveup_task_t : public jcmd_t<4057>
    {
        JSON0(req_trial_giveup_task_t)
    };
    struct ret_trial_giveup_task_t : public jcmd_t<4058>
    {
        int32_t code;
        JSON1(ret_trial_giveup_task_t, code)
    };
    //试炼场刷新任务
    struct req_trial_flush_task_t : public jcmd_t<4059>
    {
        JSON0(req_trial_flush_task_t)
    };
    struct ret_trial_flush_task_t : public jcmd_t<4060>
    {
        int32_t left_secs;
        vector<jpk_trial_task_t> tasks;
        JSON2(ret_trial_flush_task_t, left_secs, tasks)
    };
    struct ret_trial_flush_task_failed_t : public jcmd_t<4060>
    {
        int32_t code;
        JSON1(ret_trial_flush_task_failed_t, code)
    };

    //试炼场开始战斗
    struct req_trial_start_batt_t : public jcmd_t<4061>
    {
        int32_t pos;
        JSON1(req_trial_start_batt_t, pos)
    };
    struct ret_trial_start_batt_t : public jcmd_t<4062>
    {   
    //    jpk_trial_target_info_t new_target;
        //目标的数据(serialized jpk_view_user_data_t)
        string target_data;
        int32_t battlexp;
        JSON2(ret_trial_start_batt_t, target_data, battlexp)
    };
    struct ret_trial_start_batt_fail_t : public jcmd_t<4062>
    {
        int32_t code;
        JSON1(ret_trial_start_batt_fail_t, code)
    };

    //试炼场结束战斗
    struct req_trial_end_batt_t : public jcmd_t<4063>
    {
        int32_t battle_win;
        JSON1(req_trial_end_batt_t,battle_win)
    };
    struct ret_trial_end_batt_t : public jcmd_t<4064>
    {
        int32_t code;
        JSON1(ret_trial_end_batt_t,code)
    };
    //试炼场刷新对手
    struct req_trial_flush_targets_t : public jcmd_t<4065>
    {
        JSON0(req_trial_flush_targets_t)
    };
    struct ret_trial_flush_targets : public jcmd_t<4066>
    {
        vector<jpk_trial_target_info_t> targets;
        JSON1(ret_trial_flush_targets, targets)
    };
    struct ret_trial_flush_targets_failed_t : public jcmd_t<4066>
    {
        int32_t code;
        JSON1(ret_trial_flush_targets_failed_t, code)
    };
    //通知活力改变
    struct nt_energy_change_t : public jcmd_t<4067>
    {
        //当前值
        int32_t now;
        int32_t left_secs;
        JSON2(nt_energy_change_t, now, left_secs) 
    };
        //通知战历改变
    struct nt_battlexp_change_t : public jcmd_t<4068>
    {
        //当前值
        int32_t now;
        JSON1(nt_battlexp_change_t, now) 
    };
    //请求每小时活力增长
    struct req_gen_energy_t : public jcmd_t<4069>
    {
        JSON0(req_gen_energy_t)
    };
    struct ret_gen_energy_t : public jcmd_t<4070>
    {
        int32_t left_gen_seconds;
        int32_t energy;
        JSON2(ret_gen_energy_t,left_gen_seconds,energy)
    };
    //升级技能
    struct req_upgrade_skill_t : public jcmd_t<4071>
    {
        int32_t pid;
        int32_t skid; 
        int32_t num;
        JSON3(req_upgrade_skill_t, pid, skid, num)
    };
    struct ret_upgrade_skill_t : public jcmd_t<4072>
    {
        int32_t pid;
        int32_t skid;
        int32_t num;
        int32_t code;
        JSON4(ret_upgrade_skill_t, pid, skid, num, code)
    };
    //升阶技能
    struct req_upnext_skill_t : public jcmd_t<4073>
    {
        int32_t pid;
        int32_t skid; 
        JSON2(req_upnext_skill_t, pid, skid)
    };
    struct ret_upnext_skill_t : public jcmd_t<4074>
    {
        int32_t pid;
        int32_t skid;
        jpk_skill_t skill;
        JSON3(ret_upnext_skill_t, pid, skid, skill)
    };
    struct ret_upnext_skill_failed_t : public jcmd_t<4074>
    {
        int32_t pid;
        int32_t skid;
        int32_t code;
        JSON3(ret_upnext_skill_failed_t, pid, skid, code)
    };
    //试炼场领取奖励
    struct req_trial_rewards_t : public jcmd_t<4075>
    {
        JSON0(req_trial_rewards_t)
    };
    struct ret_trial_rewards_t : public jcmd_t<4076>
    {
        int32_t code;
        int32_t rewards;
        jpk_trial_task_t new_task;
        JSON3(ret_trial_rewards_t, code, rewards, new_task)
    };
        //通知客户端英雄碎片改变
    struct nt_chip_change_t : public jcmd_t<4077>
    {
        vector<jpk_chip_t> chips;
        JSON1(nt_chip_change_t, chips);
    };


    //竞技场
    //请求竞技场信息
    struct req_arena_info_t : public jcmd_t<4080>
    {
        int32_t flag; //0：本服竞技场，1：全服竞技场
        JSON1(req_arena_info_t,flag)
    };

    //队伍信息
    struct jpk_arena_team_info_t
    {
        int32_t resid;
        int32_t level;
        int32_t starnum;
        int32_t equiplv;
        int32_t lovelevel;
        int32_t pid;
        JSON6(jpk_arena_team_info_t, resid, level, starnum, equiplv, lovelevel, pid)
    };

    //挑战对象
    struct jpk_arena_target_t
    {
        int32_t uid;
        int32_t resid;
        int32_t rank;
        string  name; 
        int32_t level;
        int32_t hostnum;
        int32_t lovelevel;
        int32_t fp;     //战斗力
        int32_t wingid;
        bool have_pet;
        int32_t petid;
        int32_t model;
        vector<jpk_arena_team_info_t> team_info;
        jpk_combo_pro_view_t combo_pro;
        JSON13(jpk_arena_target_t, uid, resid, rank, name, level, hostnum, fp, wingid, have_pet, petid, model,team_info,combo_pro)
    };

    //挑战记录
    struct jpk_arena_record_t
    {
        //上次挑战的时刻
        uint32_t time;
        //上次到目前的竞技时长
        uint32_t during; //sec
        //挑战者uid
        int32_t caster_uid;
        //挑战者角色名
        string  caster_name; 
        //挑战者角色名
        //int32_t caster_lv;
        int32_t caster_fp;
        //目标uid
        int32_t target_uid; 
        //目标的角色名
        string  target_name; 
        //目标的等级
        //int32_t target_lv;
        int32_t target_fp;

        //是否战胜
        bool    is_win;
        //排名
        int32_t cast_rank;
        int32_t target_rank;

        JSON10(jpk_arena_record_t, during, caster_uid, caster_name, caster_fp, target_uid, target_name, target_fp, is_win, cast_rank, target_rank)
    };
    
    //返回竞技场信息
    struct ret_arena_info_t : public jcmd_t<4081>
    {
        int32_t                         flag;
        vector<jpk_arena_target_t>      targets;
        vector<jpk_arena_record_t>      records;
        int32_t                         fight_count;
        int32_t                         meritorious;
        int32_t                         rank;
        int32_t                         reward_btp_cd; //定时战力奖励倒计时
        int32_t                         time; // 竞技场战斗时间间隔
        JSON8(ret_arena_info_t, flag,  targets, records, fight_count, meritorious, rank, reward_btp_cd, time)
    };

    struct ret_arena_info_failed_t : public jcmd_t<4081>
    {
        int code;
        JSON1(ret_arena_info_failed_t, code)
    };

    //请求挑战
    struct req_begin_arena_fight_t : public jcmd_t<4082>
    {
        int32_t pos;
        JSON1(req_begin_arena_fight_t, pos)
    };

    // 以下内容不用了 05/15
    struct jpk_arena_fight_record_t
    {
        int32_t             m_eventType;
        uint32_t            m_time;
        bool                m_isEnemy;
        int32_t             m_actorTeamIndex;
        int32_t             m_x;
        int32_t             m_y;
        
        int32_t             m_targeterIsEnemy;
        int32_t             m_targeterTeamID;
        int32_t             m_skillType;
        int32_t             m_attackState;
        int32_t             m_damageValue;
        int32_t             m_attackerTeamIndex;
        int32_t             m_attackerIsEnemy;
        int32_t             m_isLethal; // false
        string              m_buffResID;
        int32_t             m_buffID;
        int32_t             m_state;
        JSON17(jpk_arena_fight_record_t, m_eventType, m_time, m_isEnemy, m_actorTeamIndex, m_x, m_y, m_targeterIsEnemy, m_targeterTeamID, m_skillType, m_attackState, m_damageValue, m_attackerTeamIndex, m_attackerIsEnemy, m_isLethal, m_buffResID, m_buffID, m_state);
    };

    struct ret_begin_arena_fight_t : public jcmd_t<4083>
    {
        int32_t code;
        //目标的数据(serialized jpk_view_user_data_t)
        string                          target_data; 
        //随机数种子
        uint32_t                        rseed;
        string                          salt;
        //胜负结果
        bool                            is_win;
        //奖励
        int32_t                         money;
        int32_t                         meritorious;
        int32_t                         honor;
        //挑战间隔
        uint32_t                        time;
        JSON9(ret_begin_arena_fight_t, code, target_data, rseed, salt, is_win, money, meritorious, honor, time)
    };

    struct req_end_arena_fight_t : public jcmd_t<4088>
    {
        bool        is_win;
        string      salt;
        JSON2(req_end_arena_fight_t, is_win, salt)
    };

    struct ret_end_arena_fight_t : public jcmd_t<4089>
    {
        int32_t code;
        int32_t money;
        int32_t meritorious;
        int32_t honor;
        JSON4(ret_end_arena_fight_t, code, money, meritorious, honor);
    };

    //竞技排名的行数据
    struct jpk_arena_page_row_t
    {
        int uid;
        int rank;
        string name;
        int level;
        int fp;
        int utype;
        int vip;

        JSON6(jpk_arena_page_row_t, uid, rank, name, level, fp,vip)
    };

    //竞技排名的页数据
    struct jpk_arena_page_t
    {
        int page;
        vector<jpk_arena_page_row_t> rows;
        JSON2(jpk_arena_page_t, page, rows)
    };

    //请求竞技场页面
    struct req_arena_rank_page_t : public jcmd_t<4084>
    {
        JSON0(req_arena_rank_page_t);
    };

    //返回竞技场页面
    struct ret_arena_rank_page_t : public jcmd_t<4085>
    {
        //string serialized jpk_arena_page_t
        vector<string> pages;
        JSON1(ret_arena_rank_page_t, pages)
    };

    //请求竞技场奖励倒计时
    struct req_arena_reward_countdown_t : public jcmd_t<4086>
    {
        JSON0(req_arena_reward_countdown_t);
    };
    struct ret_arena_reward_countdown_t : public jcmd_t<4087>
    {
        uint32_t countdown;
        JSON1(ret_arena_reward_countdown_t, countdown)
    };

    //购买竞技场挑战次数
    struct req_buy_fight_count_t :  public jcmd_t<4090>
    {
        JSON0(req_buy_fight_count_t)
    };

    struct ret_buy_fight_count_t : public jcmd_t<4091>
    {
        int32_t code;
        int32_t fight_count;
        JSON2(ret_buy_fight_count_t, code, fight_count)
    };

    //清除竞技场冷却时间
    struct req_arena_clear_time_t :  public jcmd_t<5389>
    {
        JSON0(req_arena_clear_time_t)
    };

    struct ret_arena_clear_time_t : public jcmd_t<5390>
    {
        int32_t code;
        JSON1(ret_arena_clear_time_t, code)
    };

    //查看其他用户信息
    struct req_view_user_info_t : public jcmd_t<4100>
    {
        int32_t uid;
        JSON1(req_view_user_info_t , uid)
    };

    struct ret_view_user_info_t : public jcmd_t<4101>
    {
        //serialized jpk_view_user_data_t
        string info;
        JSON1(ret_view_user_info_t, info)
    };

    struct ret_view_user_info_failed_t : public jcmd_t<4101>
    {
        int32_t code;
        int32_t uid;
        JSON1(ret_view_user_info_failed_t, code)
    };

    //请求升级潜能
    struct req_potential_up_t : public jcmd_t<4112>
    {
        //0 uid
        //else pid
        int32_t pid;
        int32_t attribute;
        //1 潜力丹
        //2 至尊潜力丹
        int32_t flag;
        JSON3(req_potential_up_t, pid, attribute, flag)
    };
    //返回升级潜能
    struct ret_potential_up_t : public jcmd_t<4113>
    {
        int32_t pid;
        int32_t code;
        int32_t delta;
        jpk_role_pro_t pro;
        JSON4(ret_potential_up_t, pid, code, delta, pro)
    };
    //通知友情点改变
    struct nt_fpoint_change_t : public jcmd_t<4114>
    {
        //当前值
        int32_t now;
        JSON1(nt_fpoint_change_t, now) 
    };
    //请求黄道十二宫挂机
    struct req_begin_auto_zodiac_t : public jcmd_t<4118>
    {
        //组id
        int32_t gid;
        JSON1(req_begin_auto_zodiac_t, gid)
    };
    //返回黄道十二宫挂机请求
    struct ret_begin_auto_zodiac_t : public jcmd_t<4119>
    {
        //0成功，其他都不成功
        int32_t gid;
        uint16_t code;
        JSON2(ret_begin_auto_zodiac_t, gid, code);
    };
    //请求一次十二宫挂机结果
    struct req_auto_zodiac_resu_t : public jcmd_t<4220>
    {
        //关卡组id
        int32_t gid;
        //0-计时,1-付费
        int32_t flag;
        JSON2(req_auto_zodiac_resu_t, gid, flag);
    };

    //返回一次挂机结果
    struct ret_auto_zodiac_resu_t : public jcmd_t<4221>
    {
        //当前关卡resid
        int32_t resid;
        //掉落道具
        vector<jpk_item_t> drop_items;
        //经验
        int32_t exp;
        //金币
        int32_t coin;
        //水晶
        int32_t rmb;
        JSON5(ret_auto_zodiac_resu_t, resid, drop_items, exp, coin, rmb);
    };
    struct ret_auto_zodiac_resu_failed_t : public jcmd_t<4021>
    {
        int32_t gid;
        uint16_t code;
        JSON2(ret_auto_zodiac_resu_failed_t, gid, code);
    };

    //获取boss状态
    struct req_boss_state_t : public jcmd_t<4222>
    {
        int32_t flag;  //1-世界boss,2-帮派boss
        JSON1(req_boss_state_t, flag);
    };
    struct ret_boss_state_t : public jcmd_t<4223>
    {
        //1-世界boss
        //2-帮派boss
        int32_t flag;
        //-1-无效请求
        //0-不在时间段
        //1-准备
        //2-开始时间
        //3-该服务器尚未开放世界boss
        //4-玩家未达到特定等级
        //5-公会等级不足
        int32_t state;   
        int32_t resid;
        int32_t sceneid;
        int32_t cd;
        int32_t hp;
        int32_t x;
        int32_t y;
        int32_t bosslv;
        int32_t revieve_times;
        int32_t boss_leave_time;
        JSON11(ret_boss_state_t,flag,state,resid,sceneid,cd,hp,x,y,bosslv,revieve_times,boss_leave_time);
    };
    //进入战斗
    struct req_boss_start_batt_t : public jcmd_t<4224>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        int32_t charge;    //  0-免费,1-收费
        JSON2(req_boss_start_batt_t, flag, charge);
    };
    struct ret_boss_start_batt_t : public jcmd_t<4225>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        jpk_role_data_t boss; //怪物数据
        string salt;
        int32_t revieve_times;
        JSON4(ret_boss_start_batt_t,flag,boss,salt,revieve_times);
    };
    struct ret_boss_start_batt_fail_t : public jcmd_t<4225>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        int32_t code;
        int32_t cd;
        JSON3(ret_boss_start_batt_fail_t,flag,code, cd);
    };
    struct nt_union_boss_open_t : public jcmd_t<4238>
    {
        int32_t flag;
        JSON1(nt_union_boss_open_t,flag);
    };
    struct req_boss_end_batt_t : public jcmd_t<5373>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        bool is_win;
        float damage;
        string salt;
        JSON4(req_boss_end_batt_t, flag, is_win, damage, salt)
    };
    struct ret_boss_end_batt_t : public jcmd_t<5374>
    {
        int32_t code;
        int32_t flag;    //  1-世界boss,2-帮派boss
        int32_t gold;
        JSON3(ret_boss_end_batt_t, code, flag, gold)
    };
    //boss消失
    struct nt_boss_go_t : public jcmd_t<4226>
    {
        int32_t die;       //0-怪物自动消失，1-怪物死亡
        int32_t flag;    //  1-世界boss,2-帮派boss
        JSON2(nt_boss_go_t, die,flag);
    };
    //请求伤害排名
    struct req_dmg_ranking_t : public jcmd_t<4227>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        JSON1(req_dmg_ranking_t,flag);
    };
    struct jpk_dmg_info_t
    {
        int32_t damage;
        int32_t lv;
        int32_t uid;
        string nickname;
        JSON4(jpk_dmg_info_t,damage,lv,uid,nickname);
    };
    //返回伤害排名
    struct ret_dmg_ranking_t : public jcmd_t<4228>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        vector<jpk_dmg_info_t> rank;
        int32_t damage;
        int32_t count;
        int32_t join_count;
        JSON5(ret_dmg_ranking_t,flag,rank,damage,count,join_count);
    };
    //请求离开场景
    struct req_boss_leave_scene : public jcmd_t<4229>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        JSON1(req_boss_leave_scene,flag);
    };
    struct ret_boss_leave_scene : public jcmd_t<4230>
    {
        int32_t sceneid;
        int x;
        int y;
        JSON3(ret_boss_leave_scene,sceneid, x, y);
    };

    //服务器向客户端推送通知
    struct nt_msg_push_t : public jcmd_t<4115>
    {
        //type
        //1 世界聊天
        //2 公会聊天
        //3 私人聊天
        //4 信封
        //5 登录公告
        int32_t type;
        int32_t resid;
        int32_t quality;
        int32_t uid;
        int32_t lv;
        string name;
        int32_t vipLevel;
        string info;
        string msg;
        int32_t lovelevel;
        uint32_t stmp; 
        JSON11(nt_msg_push_t, type, resid, quality, uid, lv, name, vipLevel, info, msg, lovelevel, stmp);
    };
    
    //玩家上线获取离线的聊天记录
    struct req_chat_info_t : public jcmd_t<4236>
    {
        JSON0(req_chat_info_t);
    };

    struct ret_chat_info_t : public jcmd_t<4237>
    {
        vector<nt_msg_push_t> infos;
        JSON1(ret_chat_info_t, infos);
    };

    //玩家上线获取离线期间产生的信封
    struct req_mail_info_t : public jcmd_t<4233>
    {
        JSON0(req_mail_info_t);
    };
    struct ret_mail_info_t : public jcmd_t<4234>
    {
        vector<nt_msg_push_t> mails;
        JSON1(ret_mail_info_t,mails);
    };
    struct nt_pushinfo_t : public jcmd_t<4235>
    {
        string info;
        JSON1(nt_pushinfo_t, info)
    };

    //客户端向服务器发送聊天信息
    struct nt_chart_t : public jcmd_t<4231>
    {
        // 1 世界聊天
        // 2 公会聊天
        // 3 私人聊天
        int32_t type;
        // 公会id or uid
        int32_t id;
        string msg;
        JSON3(nt_chart_t, type, id, msg);
    };
    //事件公告系统
    struct nt_event_general_t : public jcmd_t<4232>
    {
        //2 通关黄道十二宫
        //3 通关精英关卡
        //4 招募伙伴
        //8 世界boss逃逸
        //9 第一名上线
        int32_t type;
        int32_t flag;
        string name;
        int32_t uid;
        int32_t lv;
        int32_t resid;
        JSON6(nt_event_general_t,type,flag,name,uid,lv,resid);
    };
    struct nt_event_boss_kill_t : public jcmd_t<4232>
    {
        //6 世界boss被杀死
        int32_t type;
        int32_t flag;
        string name;
        int32_t uid;
        int32_t lv;
        int32_t resid;
        int32_t gold;
        int32_t btp;
        int32_t item;
        string dmg_name;
        int32_t dmg_uid;
        int32_t dmg_lv;
        int32_t dmg_viplevel;
        JSON13(nt_event_boss_kill_t,type, flag, name,uid,lv,resid,gold,btp,item,dmg_name,dmg_uid,dmg_lv,dmg_viplevel);
    };
    struct nt_event_arena_t : public jcmd_t<4232>
    {
        //7 撸第一
        int32_t type;
        int32_t uid1;
        int32_t lv1;
        string name1;
        int32_t uid2;
        int32_t lv2;
        string name2;
        JSON7(nt_event_arena_t,type,uid1,lv1,name1,uid2,lv2,name2);
    };
    struct nt_event_gemstone_t : public jcmd_t<4232>
    {
        //1 合成宝石
        //5 关卡获得水晶
        int32_t type;
        string name;
        int32_t uid;
        int32_t lv;
        int32_t resid;
        int32_t count;
        JSON6(nt_event_gemstone_t,type,name,uid,lv,resid,count);
    };
    struct nt_event_blank_t : public jcmd_t<4232>
    {
        //10 世界boss的血量低于10%
        int32_t type;
        int32_t flag;
        int32_t resid;
        JSON3(nt_event_blank_t, type, flag, resid);
    };
    
    //好友系统
    //寻找好友
    struct req_friend_search_uid_t : public jcmd_t<4338>
    {
        int32_t uid;
        JSON1(req_friend_search_uid_t, uid);
    };
    struct req_friend_search_t : public jcmd_t<4340>
    {
        string name;
        JSON1(req_friend_search_t, name);
    };
    struct ret_friend_search_t : public jcmd_t<4341>
    {
        string name;
        int32_t uid;  //0,没有此角色名的角色
        int32_t resid;
        int32_t lv;
        JSON4(ret_friend_search_t, name, uid, resid, lv);
    };
    //添加好友
    struct req_friend_add_t : public jcmd_t<4342>
    {
        int32_t uid;
        int32_t fp;
        JSON2(req_friend_add_t, uid, fp);
    };
    struct ret_friend_add_t : public jcmd_t<4343>
    {
        int32_t uid;
        int32_t code;
        JSON2(ret_friend_add_t, uid, code);
    };
    //被添加好友通知
    struct nt_friend_beenadd_t : public jcmd_t<4344>
    {
        int32_t uid; 
        string name;
        int32_t lv;
        JSON3(nt_friend_beenadd_t, uid, name, lv);
    };
    //回复被添加好友
    struct req_friend_add_res_t : public jcmd_t<4345>
    {
        int32_t uid;
        int32_t reject;
        JSON2(req_friend_add_res_t, uid, reject);
    };
    struct ret_friend_add_res_t : public jcmd_t<4339>
    {
        int32_t uid;
        int32_t code;
        JSON2(ret_friend_add_res_t, uid, code);
    };
    //删除好友
    struct req_friend_del_t : public jcmd_t<4346>
    {
        int32_t uid;
        JSON1(req_friend_del_t, uid);
    };
    struct ret_friend_del_t : public jcmd_t<4347>
    {
        int32_t code;
        int32_t uid;
        JSON2(ret_friend_del_t, code, uid);
    };
    //黑名单，暂时不错
    struct req_friend_blacklist_t : public jcmd_t<4348>
    {
        int32_t uid;
        JSON1(req_friend_blacklist_t, uid);
    };
    struct ret_friend_blacklist_t : public jcmd_t<4349>
    {
        int32_t code;
        int32_t uid;
        JSON2(ret_friend_blacklist_t, code, uid);
    };
    //更换助战英雄
    struct req_friend_helpbattle_t : public jcmd_t<4350>
    {
        int32_t pid;  //0,主角  非0,伙伴
        JSON1(req_friend_helpbattle_t, pid);
    };
    struct ret_friend_helpbattle_t : public jcmd_t<4351>
    {
        int32_t code;
        int32_t uid;
        JSON2(ret_friend_helpbattle_t, code, uid);
    };
    struct friend_info_t
    {
        //主角
        int32_t uid;
        string name;
        int32_t lv;
        int32_t fp;
        int32_t online;  //0,不在线   1,在线
        //助战英雄
        int32_t pid;
        int32_t checkGiveState;
        int32_t resid;
        int32_t ishelped;
        JSON9(friend_info_t,uid,name,lv,fp,online,pid,resid,ishelped,checkGiveState);
    };
    //请求好友列表
    struct req_friend_list_t : public jcmd_t<4352>
    {
        int32_t page;  //start from 0, up to 4
        JSON1(req_friend_list_t, page);
    };
    struct ret_friend_list_t : public jcmd_t<4353>
    {
        int32_t page;
        int32_t n_online;
        int32_t n_all;
        int32_t remain;
        int32_t numFlower;
        int32_t useFlower;
        uint32_t resetFlowerStamp;
        vector<friend_info_t> frds;
        JSON8(ret_friend_list_t,page,n_online,n_all,remain,frds,numFlower,useFlower,resetFlowerStamp);
    };
    //好友在线变化
    struct nt_friend_olchange_t : public jcmd_t<4354>
    {
        int32_t uid;
        int32_t online;
        JSON2(nt_friend_olchange_t, uid, online);
    };
    //好友助战英雄变化
    struct nt_friend_hbchange_t : public jcmd_t<4355>
    {
        int32_t uid;
        int32_t resid;
        JSON2(nt_friend_hbchange_t, uid, resid);
    };
    //好友增加
    struct nt_friend_addone_t : public jcmd_t<4356>
    {
        friend_info_t frd;
        JSON1(nt_friend_addone_t, frd);
    };
    //好友删除
    struct nt_friend_delone_t : public jcmd_t<4357>
    {
        int32_t uid;
        JSON1(nt_friend_delone_t, uid);
    };
    //请求好友申请列表
    struct nt_request_info_t
    {
        int32_t uid;
        int32_t lv;
        string name;
        int32_t resid;
        int32_t fp;
        nt_request_info_t(int32_t uid_,const string &name_,int32_t lv_,int32_t resid_,int32_t fp_)
        :uid(uid_),lv(lv_),name(name_),resid(resid_),fp(fp_)
        {
        }
        nt_request_info_t()
        {
        }
        JSON5(nt_request_info_t, uid, lv, name, resid, fp);
    };
    struct req_friend_addlist_t : public jcmd_t<4358>
    {
        JSON0(req_friend_addlist_t);
    };
    struct ret_friend_addlist_t : public jcmd_t<4359>
    {
        vector<nt_request_info_t> list;
        JSON1(ret_friend_addlist_t, list);
    };
    
    struct nt_reward_t : public jcmd_t<4360>
    {
        //101 首次充值
        //
        //201~207 累计充值1~7
        //
        //301~305 连续登录1~5
        //
        //401~424 累计登录1~24
        //
        //501~512 vip等级奖励1~12 
        int32_t flag;
        int32_t can_get_first;
        JSON2(nt_reward_t, flag,can_get_first);
    };
    struct req_reward_t : public jcmd_t<4361>
    {
        int32_t flag;
        JSON1(req_reward_t, flag);
    };
    struct ret_reward_t : public jcmd_t<4362>
    {
        int32_t flag;
        int32_t code;
        int32_t dismess;  //是否有过拆解英雄的行为
        JSON3(ret_reward_t, flag, code, dismess);
    };
    //活动系统奖励一个伙伴
    struct nt_reward_partner_t : public jcmd_t<4363>
    {
        jpk_role_data_t partner;
        JSON1(nt_reward_partner_t, partner);
    };
    //好友助战系统，申请陌生人信息
    struct req_helphero_stranger_t : public jcmd_t<4364>
    {
        int32_t count;
        JSON1( req_helphero_stranger_t,count);
    };
    struct ret_helphero_stranger_t : public jcmd_t<4365>
    {
        vector<friend_info_t> strs;
        JSON1(ret_helphero_stranger_t,strs);
    };
    //零点时，请求登录奖励
    struct req_lg_rewardinfo_t : public jcmd_t<4366>
    {
        JSON0(req_lg_rewardinfo_t);
    };
    struct ret_lg_rewardinfo_t : public jcmd_t<4367>
    {
        yarray_t<int32_t, 5>    con_lg;     //连续登录
        yarray_t<int32_t, 24>    acc_lg;     //累计登录
        int32_t acclgexp;                   //累计登录天数
        int32_t month;                      //累计登录奖励对应月份
        int32_t sec_2_tom;                  //距离00:00的秒数
        JSON5(ret_lg_rewardinfo_t,con_lg,acc_lg,acclgexp,month,sec_2_tom);
    };
    //好友挑战
    struct req_friend_battle_t : public jcmd_t<4368>
    {
        int32_t uid;
        JSON1(req_friend_battle_t , uid)
    };

    struct ret_friend_battle_t : public jcmd_t<4369>
    {
        //serialized jpk_view_user_data_t
        string info;
        JSON1(ret_friend_battle_t, info)
    };
    struct ret_friend_battle_failed_t : public jcmd_t<4369>
    {
        int32_t code;
        int32_t uid;
        JSON1(ret_friend_battle_failed_t, code)
    };
    //请求伙伴属性信息
    struct req_role_pro_t : public jcmd_t<4370>
    {
        int32_t pid;
        JSON1(req_role_pro_t,pid);
    };
    struct ret_role_pro_t : public jcmd_t<4371>
    {
        int32_t pid;
        jpk_role_pro_t pro;
        JSON2(ret_role_pro_t,pid,pro);
    };
    //走马灯系统
    struct req_maquee_info_t : public jcmd_t<4372>
    {
        JSON0(req_maquee_info_t);
    };
    struct ret_maquee_info_t : public jcmd_t<4373>
    {
        vector<string> infos;
        JSON1(ret_maquee_info_t,infos);
    };
    //通知服务器退出阶段
    struct nt_quit_step_t : public jcmd_t<4374>
    {
        int32_t step;
        JSON1(nt_quit_step_t,step);
    };
   
    //巨龙宝藏个人信息
    struct team_member_info_t
    {
        int32_t pid;
        int32_t lovelevel;
        int32_t equiplv;
        int32_t level;
        int32_t starnum;
        int32_t resid;
        JSON6(team_member_info_t, pid, lovelevel, equiplv, level, starnum, resid);
    };

    //巨龙宝库的队伍配置信息
    struct treasure_team_info_t
    {
        vector<team_member_info_t> hero1;
        vector<team_member_info_t> hero2;
        vector<team_member_info_t> hero3;
        vector<team_member_info_t> hero4;
        vector<team_member_info_t> hero5;
        JSON5(treasure_team_info_t, hero1, hero2, hero3, hero4, hero5);
    };
   
   //巨龙宝藏的蹲位
    struct treasure_cli_slot_t
    {
        int32_t uid;
        int32_t resid;
        string nickname;
        string gangname;         //公会名字
        int32_t grade;
        uint32_t stamp;         //占领时间
        int32_t n_rob;          //被打劫次数
        int32_t n_help;         //协守次数
        int32_t rob_money;      //被打劫金钱
        int32_t lovelevel;      //爱恋度等级
        int32_t fp;             //战斗力
        int32_t viplevel;       //vip等级
        vector<treasure_team_info_t> team_info;//队伍信息
        JSON13(treasure_cli_slot_t,uid,resid,nickname,gangname,grade,stamp,n_rob,n_help,rob_money,lovelevel,fp, viplevel, team_info);
    };
   
    //巨龙宝库获取某一层的信息
    struct req_treasure_floor_t : public jcmd_t<4375>
    {
        int32_t floor; //1~100
        JSON1(req_treasure_floor_t,floor);
    };
    struct ret_treasure_floor_t : public jcmd_t<4376>
    {
        int32_t floor;
        int32_t code;
        vector<treasure_cli_slot_t> slots; // 拥有者
        vector<treasure_cli_slot_t> helper; // 协守者
        JSON4(ret_treasure_floor_t,floor,code,slots,helper);
    };
    struct treasure_drop_t
    {
        int32_t floor;
        int32_t coin;
        map<int, int> drops;
        JSON3(treasure_drop_t,floor,coin,drops);
    };
    //巨龙宝库进入战斗
    struct req_treasure_enter_t : public jcmd_t<4377>
    {
        int32_t resid;
        JSON1(req_treasure_enter_t,resid);
    };
    struct ret_treasure_enter_t : public jcmd_t<4378>
    {
        int32_t code;
        int32_t resid;
        string salt;
        JSON3(ret_treasure_enter_t,code,resid,salt);
    };
    //巨龙宝库结束战斗
    struct req_treasure_exit_t : public jcmd_t<4379>
    {
        int32_t resid;
        int32_t win;
        string salt;
        JSON3(req_treasure_exit_t,resid,win,salt);
    };
    struct ret_treasure_exit_t : public jcmd_t<4380>
    {
        int32_t resid;
        int32_t win;
        int32_t code;
        map<int, int> drops;
        JSON4(ret_treasure_exit_t,resid,win,code,drops);
    };
    //巨龙宝库一键登塔
    struct req_treasure_pass_t : public jcmd_t<4381>
    {
        JSON0(req_treasure_pass_t);
    };
    struct ret_treasure_pass_t : public jcmd_t<4382>
    {
        int32_t code;
        int32_t start;
        int32_t last;
        vector<treasure_drop_t> drops;
        JSON4(ret_treasure_pass_t,code,start,last,drops);
    };
    //  宝库重置
    struct req_treasure_reset_t : public jcmd_t<5500>
    {
        JSON0(req_treasure_reset_t);
    };
    struct ret_treasure_reset_t : public jcmd_t<5501>
    {
        int32_t code;
        int32_t remain_times;
        int32_t n_rob;
        JSON3(ret_treasure_reset_t, code, remain_times, n_rob);
    };
    //改名功能
    struct req_change_name_t : public jcmd_t<5502>
    {
        //服务器号
        int32_t hostnum;
        //角色表id
        int32_t uid;
        //名字
        string name;

        JSON3(req_change_name_t, hostnum, name, uid);
    };
    struct ret_change_name_t : public jcmd_t<5503>
    {
        uint32_t code;
        uint32_t yb;
        string nickname;

        JSON3(ret_change_name_t, nickname, yb, code);
    };
    //竞技场冷却
    struct req_arena_cool_down_t : public jcmd_t<5504>
    {
        JSON0(req_arena_cool_down_t);
    };
    struct ret_arena_cool_down_t : public jcmd_t<5505>
    {
        uint32_t time;
        uint32_t fight_count;
        int32_t code;
        JSON3(ret_arena_cool_down_t, time, fight_count, code)
    };
    //探宝放弃协守去占领
    struct req_treasure_give_occupy_t : public jcmd_t<5506>
    {
        uint32_t uid;
        int32_t pos;
        JSON2(req_treasure_give_occupy_t, uid, pos);
    };

    struct ret_treasure_give_occupy_t : public jcmd_t<5507>
    {
        int32_t code;
        JSON1(ret_treasure_give_occupy_t, code);
    };
    //放弃协守
    struct req_treasure_giveup_help_t : public jcmd_t<5508>
    {
        uint32_t uid;
        JSON1(req_treasure_giveup_help_t, uid);
    };
    
    struct ret_treasure_giveup_help_t :public jcmd_t<5509>
    {
        int32_t code;
        JSON1(ret_treasure_giveup_help_t, code);
    };
    //看板娘
    struct req_set_kanban_role_t : public jcmd_t<5510>
    {
        int32_t uid;
        int32_t resid;
        int32_t type;
        JSON3(req_set_kanban_role_t, uid, resid, type);
    };

    struct ret_set_kanban_role_t : public jcmd_t<5511>
    {
        int32_t resid;
        int32_t type;
        int32_t code;
        JSON3(ret_set_kanban_role_t, resid, type, code);
    };
    //开服期限内奖励领取
    struct req_get_open_service_reward_t : public jcmd_t<5512>
    {
        int32_t uid;
        int32_t index;
        JSON2(req_get_open_service_reward_t, uid, index);
    };
    struct ret_get_open_service_reward_t : public jcmd_t<5513>
    {
        int32_t index;
        int32_t code;
        JSON2(ret_get_open_service_reward_t, index, code);
    };  
    struct req_buy_growing_package_t : public jcmd_t<5514>
    {
        int32_t uid;
        JSON1(req_buy_growing_package_t, uid);
    }; 
    struct ret_buy_growing_package_t : public jcmd_t<5515>
    {
        int32_t code;
        string growing_reward;
        JSON2(ret_buy_growing_package_t, code, growing_reward);
    };
    
    //卡牌评论
    struct jpk_card_comment_info_t
    {
        int32_t uid;
        string name;
        int32_t viplevel;
        int32_t grade;
        int32_t equiprank;
        int32_t isshow;
        int32_t praisenum;
        string comment;
        int32_t id;
        JSON9(jpk_card_comment_info_t, uid, name, viplevel, grade, equiprank, isshow, praisenum, comment, id);
    };

    struct req_comment_card_t : public jcmd_t<5516>
    {
        int32_t uid;                        //发表评论的玩家id
        int32_t resid;                      //卡牌的resid
        string comment;                         //评论内容
        int32_t isshow;                      //是否公开自己的角色信息
        JSON4(req_comment_card_t, uid, resid, comment, isshow);
    };
    struct ret_comment_card_t : public jcmd_t<5517>
    {
        int32_t code;
        vector<jpk_card_comment_info_t> infos;
        jpk_card_comment_info_t max_comment;    //最热的评论
        JSON3(ret_comment_card_t, code, infos, max_comment);
    }; 

    //请求最新卡牌评论
    struct req_newest_card_comment_t : public jcmd_t<5518>
    {
        int32_t resid;
        int32_t uid;
        int32_t type;           //类型 1表示最新  2表示最热
        JSON3(req_newest_card_comment_t, resid, uid, type);
    };
    struct ret_newest_card_comment_t : public jcmd_t<5519>
    {
        int32_t code;
        int32_t type;
        vector<jpk_card_comment_info_t> infos;
        jpk_card_comment_info_t max_comment;
        int32_t stamp;
        JSON5(ret_newest_card_comment_t, infos, code, type, stamp, max_comment);
    };
    //请求某个玩家的某个角色的属性
    struct req_index_role_info_t : public jcmd_t<5520>
    {
        int32_t uid;
        int32_t resid;
        JSON2(req_index_role_info_t, uid, resid);
    };
    struct ret_index_role_info_t : public jcmd_t<5521>
    {
        jpk_role_data_t data;
        int32_t isfind;
        int32_t code;
        string name;
        int32_t resid;
        JSON5(ret_index_role_info_t, data, isfind, code, name, resid); 
    };
    //卡牌评论点赞
    struct req_praise_comment_t : public jcmd_t<5522>
    {
        int32_t commentuid;         //发表评论的uid
        int32_t praiseuid;          //点赞的uid
        int32_t commentid;          //评论id
        JSON3(req_praise_comment_t, commentuid, praiseuid, commentid);
    };
    struct ret_praise_comment_t : public jcmd_t<5523>
    {
        int32_t id;
        int32_t code;
        JSON2(ret_praise_comment_t, code, id);
    };
    //领取福袋奖励
    struct req_luckybag_reward_t : public jcmd_t<5524>
    {
        int32_t id;
        JSON1(req_luckybag_reward_t, id);
    };
    struct ret_luckybag_reward_t : public jcmd_t<5525>
    {
        int32_t code;
        int32_t id;
        string luckybag_reward;
        JSON3(ret_luckybag_reward_t, code, luckybag_reward, id);
    };
    //pve失败次数
    struct req_pvelose_times_t : public jcmd_t<5526>
    {
        int32_t uid;
        JSON1(req_pvelose_times_t, uid);
    };
    struct ret_pvelose_times_t : public jcmd_t<5527>
    {
        int32_t code;
        int32_t times;
        JSON2(ret_pvelose_times_t, code, times);
    };

    //累计充值通知
    struct nt_recharge_activity_t : public jcmd_t<5528>
    {
        int32_t totalmoney;
        string recharge_reward;
        JSON2(nt_recharge_activity_t, totalmoney, recharge_reward);
    };

    //每日抽卡通知
    struct nt_daily_draw_t : public jcmd_t<5529>
    {
        int32_t totaldraw;
        string daily_draw_reward;
        JSON2(nt_daily_draw_t, totaldraw, daily_draw_reward);
    };

    //每日体力通知
    struct nt_daily_consume_t : public jcmd_t<5530>
    {
        int32_t totalpower;
        string daily_consume_ap_reward;
        JSON2(nt_daily_consume_t, totalpower, daily_consume_ap_reward);
    };
    
    //熔炼通知
    struct nt_melting_t : public jcmd_t<5531>
    {
        int32_t type;       //1表示每日 2表示累计
        int32_t totalmelting;
        string melting_reward;
        JSON3(nt_melting_t, totalmelting, melting_reward, type);
    };

    //天赋通知
    struct nt_talent_t : public jcmd_t<5532>
    {
        int32_t type;
        int32_t totaltalent;
        string talent_reward;
        JSON3(nt_talent_t, totaltalent, talent_reward, type);
    };

    //请求获得周礼包奖励
    struct req_get_weekly_reward_t : public jcmd_t<5533>
    {
        int32_t id;
        JSON1(req_get_weekly_reward_t, id)
    };
    struct ret_get_weekly_reward_t : public jcmd_t<5534>
    {
        int32_t code;
        int32_t week_reward;
        JSON2(ret_get_weekly_reward_t, code, week_reward)
    };

    //请求获得在线包奖励
    struct req_get_online_reward_t : public jcmd_t<5535>
    {
        int32_t id;
        JSON1(req_get_online_reward_t, id)
    };
    struct ret_get_online_reward_t : public jcmd_t<5536>
    {
        int32_t code;
        int32_t online;
        int32_t cd;
        JSON3(ret_get_online_reward_t, code, online, cd)
    };

    //单日充值通知
    struct nt_single_activity_t : public jcmd_t<5537>
    {
        int32_t totalmoney;
        string recharge_reward;
        JSON2(nt_single_activity_t, totalmoney, recharge_reward);
    };


    //巨龙宝库占领空位
    struct req_treasure_occupy_t : public jcmd_t<4383>
    {
        int32_t pos; //(floor*4-4) ~ (floor*4-1)
        JSON1(req_treasure_occupy_t,pos);
    };
    struct ret_treasure_occupy_t : public jcmd_t<4384>
    {
        int32_t code;
        int32_t pos;
        JSON2(ret_treasure_occupy_t,code,pos);
    };
    //巨龙宝库抢占蹲位
    struct req_treasure_fight_t : public jcmd_t<4385>
    {
        int32_t pos;
        int32_t uid;
        JSON2(req_treasure_fight_t, pos, uid);
    };
    struct ret_treasure_fight_t : public jcmd_t<4386>
    {
        //目标的数据(serialized jpk_view_user_data_t)
        string                          help_data;
        string                          target_data; 
        string                          salt;
        JSON3(ret_treasure_fight_t,help_data, target_data,salt)
    };
    struct ret_treasure_fight_failed_t : public jcmd_t<4386>
    {
        int32_t code;
        JSON1(ret_treasure_fight_failed_t, code);
    };
    struct req_treasure_fight_end_t : public jcmd_t<5269>
    {
        bool is_win;
        string salt;
        JSON2(req_treasure_fight_end_t, is_win, salt)
    };
    struct ret_treasure_fight_end_t : public jcmd_t<5270>
    {
        int32_t code;
        int32_t pos;
        JSON2(ret_treasure_fight_end_t, pos, code)
    };
    //巨龙宝库打劫
    struct req_treasure_rob_t : public jcmd_t<4387>
    {
        int32_t pos;
        int32_t uid;
        JSON2(req_treasure_rob_t, pos,uid);
    };
    struct ret_treasure_rob_t : public jcmd_t<4388>
    {
        //目标的数据(serialized jpk_view_user_data_t)
        string                          help_data;
        string                          target_data; 
        string                          salt;
        JSON3(ret_treasure_rob_t, help_data, target_data, salt)
    };
    struct req_treasure_rob_end_t : public jcmd_t<5375>
    {
        bool is_win;
        string salt;
        JSON2(req_treasure_rob_end_t, is_win, salt)
    };
    struct ret_treasure_rob_end_t : public jcmd_t<5376>
    {
        int32_t code;
        int32_t money;
        JSON2(ret_treasure_rob_end_t, code, money)
    };
    struct ret_treasure_rob_failed_t : public jcmd_t<4388>
    {
        int32_t code;
        JSON1(ret_treasure_rob_failed_t, code)
    };
    //巨龙宝库放弃坑位
    struct req_treasure_giveup_t : public jcmd_t<4389>
    {
        JSON0(req_treasure_giveup_t);
    };
    struct ret_treasure_giveup_t : public jcmd_t<4390>
    {
        int32_t code;
        int32_t left_secs;   //当日剩余占坑时间
        JSON2(ret_treasure_giveup_t,code,left_secs);
    };
    //巨龙宝库被踢出坑位
    struct nt_treasure_kick_out_t : public jcmd_t<4391>
    {
        int32_t left_secs;   //当日剩余占坑时间
        int32_t lv;
        string name;
        int32_t coin;
        JSON4(nt_treasure_kick_out_t,left_secs,lv,name,coin);
    };
    //巨龙宝库协守结束
    struct nt_treasure_help_end_t : public jcmd_t<5352>
    {
        int32_t n_help;
        int32_t pos;
        JSON2(nt_treasure_help_end_t, n_help, pos);
    };
    //巨龙宝库收益变化通知
    struct nt_treasure_profit_t : public jcmd_t<5388>
    {
        int32_t now;
        JSON1(nt_treasure_profit_t, now);
    };
    //巨龙宝库领取坑位奖励
    struct req_treasure_slot_rewd_t : public jcmd_t<4392>
    {
        int32_t uid;
        JSON1(req_treasure_slot_rewd_t, uid);
    };
    struct ret_treasure_slot_rewd_t : public jcmd_t<4393>
    {
        int32_t code;
        int32_t m_or_t;  //或者结算金币，或者剩余时间
        JSON2(ret_treasure_slot_rewd_t,code,m_or_t);
    };
    //到达零点的剩余秒数
    struct req_secs_to_zero_t : public jcmd_t<4394>
    {
        JSON0(req_secs_to_zero_t);
    };
    struct ret_secs_to_zero_t : public jcmd_t<4395>
    {
        int32_t secs;
        JSON1(ret_secs_to_zero_t,secs);
    };
    //挑战记录
    struct jpk_treasure_record_t
    {
        //战斗时间
        uint32_t time;
        //距离当前的时间
        uint32_t elapsed; //sec
        //主动者uid
        int32_t uid;
        //主动者角色名
        string name; 
        //主动者等级
        int32_t lv;
        int32_t lovelevel;
        //被动者uid
        int32_t uid2;
        //被动者角色名
        string  name2; 
        //被动者等级
        int32_t lv2;
        //关系
        int32_t flag; //1,打劫 2,抢占
        //主动者是否战胜
        int32_t is_win;
        //被动者损失的金钱
        int32_t money;
        JSON12(jpk_treasure_record_t,time,elapsed,uid,name,lv,lovelevel,uid2,name2,lv2,flag,is_win,money);
    };
    //请求巨龙宝库战斗记录
    struct req_treasure_rcds_t : public jcmd_t<4396>
    {
        JSON0(req_treasure_rcds_t);
    };
    struct ret_treasure_rcds_t : public jcmd_t<4397>
    {
        vector<jpk_treasure_record_t> records;
        JSON1(ret_treasure_rcds_t,records);
    };
    struct jpk_treasure_revenge_t
    {
        int32_t uid;
        int32_t lv;
        int32_t lovelevel;
        int32_t resid;
        string nickname;
        int32_t pos;
        int32_t secs;
        int32_t gold;  //被抢劫的金币
        JSON8(jpk_treasure_revenge_t,uid,lv,lovelevel,resid,nickname,pos,secs,gold);
    };
    //请求巨龙宝库复仇记录
    struct req_treasure_revenge_t : public jcmd_t<4398>
    {
        JSON0(req_treasure_revenge_t);
    };
    struct ret_treasure_revenge_t : public jcmd_t<4399>
    {
        vector<jpk_treasure_revenge_t> records;
        JSON1(ret_treasure_revenge_t,records);
    };
    //请求协守宝藏
    struct req_treasure_help_t : public jcmd_t<5267>
    {
        int32_t pos;
        JSON1(req_treasure_help_t, pos)
    };
    struct ret_treasure_help_t : public jcmd_t<5268>
    {
        int32_t code; // 成功协守与否
        int32_t pos;
        JSON2(ret_treasure_help_t, code, pos)
    };
            
    //打开礼包
    struct req_open_pack_t : public jcmd_t<4300>
    {
        //礼包道具的resid
        int32_t resid;
        JSON1(req_open_pack_t, resid)
    };

    struct ret_open_pack_t : public jcmd_t<4301>
    {
        //礼包中的道具
        vector<jpk_item_t> items;
        JSON1(ret_open_pack_t, items);
    };

    struct ret_open_pack_failed_t : public jcmd_t<4301>
    {
        int code;
        JSON1(ret_open_pack_failed_t, code)
    };

    //领取礼包中的道具
    struct req_use_pack_t : public jcmd_t<4302>
    {
        JSON0(req_use_pack_t)
    };

    struct ret_use_pack_t : public jcmd_t<4303>
    {
        int code;
        JSON1(ret_use_pack_t, code)
    };

    struct jpk_rank_reward_t
    {
        int32_t gold;
        //int32_t battlexp;
        int32_t item;
        JSON2(jpk_rank_reward_t,gold,item);
    };
    //全服通告伤害排名
    struct nt_dmg_ranking_t : public jcmd_t<4304>
    {
        int32_t flag;    //  1-世界boss,2-帮派boss
        vector<jpk_dmg_info_t> rank;
        int32_t damage;
        int32_t resid;
        vector<jpk_rank_reward_t> reward;
        JSON5(nt_dmg_ranking_t,flag,rank,damage,resid,reward);
    };
    //请求任务列表
    struct req_task_list_t : public jcmd_t<4400>
    {
        JSON0(req_task_list_t)
    };

    struct ret_task_list_t : public jcmd_t<4401>
    {
        vector<jpk_task_t> tasks;
        JSON1(ret_task_list_t, tasks)
    };
    
    //限时提示消息
    struct req_limitnews_t : public jcmd_t<4410>
    {
        JSON0(req_limitnews_t)
    };

    struct ret_limitnews_t : public jcmd_t<4411>
    {
        //1 吃蛋糕，2 世界boss，3 怪物入侵，4 npc商店，5公会红包
        int32_t typenum;
        JSON1(ret_limitnews_t, typenum)
    };

    //请求获得任务
    struct req_get_task_t : public jcmd_t<4402>
    {
        int resid;
        JSON1(req_get_task_t, resid)
    };

    struct ret_get_task_t : public jcmd_t<4403>
    {
        int resid;
        int code;
        JSON2(ret_get_task_t, resid, code)
    };

    //提交任务
    struct req_commit_task_t : public jcmd_t<4404>
    {
        int resid;
        int next_id;
        JSON2(req_commit_task_t, resid, next_id)
    };

    struct ret_commit_task_t : public jcmd_t<4405>
    {
        int code;
        int resid;
        int next_id;
        JSON3(ret_commit_task_t, code, resid, next_id)
    };

    //放弃任务
    struct req_abort_task_t : public jcmd_t<4406>
    {
        int resid;
        JSON1(req_abort_task_t, resid)
    };

    struct ret_abort_task_t : public jcmd_t<4407>
    {
        int code;
        int resid;
        JSON2(ret_abort_task_t, code, resid)
    };

    //已经完成的支线任务
    struct req_finished_bline_t : public jcmd_t<4408>
    {
        int sceneid;
        JSON1(req_finished_bline_t, sceneid);
    };

    struct ret_finished_bline_t : public jcmd_t<4409>
    {
        vector<int> resids;
        JSON1(ret_finished_bline_t, resids);
    };

    struct nt_task_change_t : public jcmd_t<4420>
    {
        jpk_task_t task;
        JSON1(nt_task_change_t, task)
    };
/*
    //请求日常任务列表
    struct req_daily_task_list_t : public jcmd_t<4410>
    {
        JSON0(req_daily_task_list_t)
    };

    struct ret_daily_task_list_t : public jcmd_t<4411>
    {
        vector<jpk_task_t> tasks;
        //已经执行的任务数
        //int num;
        //已经购买的次数
        //int buy_num;
        JSON1(ret_daily_task_list_t, tasks)
    };

    //请求提交日常任务
    struct req_commit_daily_task_t : public jcmd_t<4412>
    {
        //任务的位置
        int pos;
        JSON1(req_commit_daily_task_t, pos)
    };

    //请求提交任务
    struct ret_commit_daily_task_t : public jcmd_t<4413>
    {
        //任务的位置
        int         pos;
        //是否成功
        int         code;
        JSON2(ret_commit_daily_task_t, pos, code)
    };

    //请求购买刷新日常任务数
    struct req_buy_daily_task_num_t : public jcmd_t<4414>
    {
        JSON0(req_buy_daily_task_num_t)
    };

    struct ret_buy_daily_task_num_t : public jcmd_t<4415>
    {
        int code;
        JSON1(ret_buy_daily_task_num_t, code);
    };
*/
    //训练系统
    //请求训练场信息
    struct req_practice_info_t : public jcmd_t<4500>
    {
        JSON0(req_practice_info_t);
    };
    struct sc_practice_info_t
    {
        int32_t state;  //-1,场地未开放 0,空闲 1,冷却
        int32_t remains;   //state为1时读取,剩余的秒数
        JSON2(sc_practice_info_t, state, remains);
    };
    struct ret_practice_info_t : public jcmd_t<4501>
    {
        vector<sc_practice_info_t> infos;
        JSON1(ret_practice_info_t, infos);
    };

    //请求训练伙伴
    struct req_practice_partner_t : public jcmd_t<4502>
    {
        int32_t pos;
        int32_t pid;
        int32_t type;   //1,普通训练   2,王者训练
        JSON3(req_practice_partner_t, pos, pid, type);
    };
    struct ret_practice_partner_t : public jcmd_t<4503>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_practice_partner_t, pos, code);
    };
    //请求清除冷却
    struct req_practice_clear_t : public jcmd_t<4504>
    {
        int32_t pos;
        JSON1(req_practice_clear_t, pos);
    };
    struct ret_practice_clear_t : public jcmd_t<4505>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_practice_clear_t, pos, code);
    };
    
    //符文系统
    //
    //打开符文系统，获取怪物信息
    struct req_rune_info_t : public jcmd_t<4508>
    {
        JSON0(req_rune_info_t);
    };
    struct ret_rune_info_t : public jcmd_t<4509>
    {
        vector<jpk_rune_monster_t> mons;
        JSON1(ret_rune_info_t,mons);
    };
    //吞噬符文或者移动符文
    //如果两个位置中有一个位置为空，则为移动符文,例如，在包裹内移动，或者穿戴，或者脱下
    //如果两个位置都不为空，则为吞噬符文，目标符文吞噬源符文
    //0~7 伙伴身上的位置,对应策划表中的位置1~8,通过pid来标识伙伴
    //8~16 背包的位置
    struct req_rune_switchpos_t : public jcmd_t<4510>
    {
        int32_t src_pos;
        int32_t dst_pos;
        int32_t pid;
        JSON3(req_rune_switchpos_t, src_pos, dst_pos, pid);
    };
    struct ret_rune_switchpos_t : public jcmd_t<4511>
    {
        int32_t src_pos;
        int32_t dst_pos;
        int32_t pid;
        int32_t code;
        JSON4(ret_rune_switchpos_t, src_pos, dst_pos, pid, code);
    };
    //吞噬背包内所有符文
    struct req_rune_eatall_t : public jcmd_t<4512>
    {
        JSON0(req_rune_eatall_t);
    };
    struct ret_rune_eatall_t : public jcmd_t<4513>
    {
        int32_t code;
        JSON1(ret_rune_eatall_t, code);
    };
    //猎魔
    //flag
    //0 不合成
    //5 合成金色以下符文
    //4 合成紫色以下符文
    //3 合成蓝色以下符文
    struct req_rune_huntsome_t : public jcmd_t<4514>
    {
        vector<int32_t> lines;  //0~9
        int32_t flag;
        JSON2(req_rune_huntsome_t, lines,flag);
    };
    struct ret_rune_huntsome_t : public jcmd_t<4515>
    {
        vector<jpk_rune_monster_t> monsters;
        int32_t flag;   //或者钱不够，或者背包满
        JSON2(ret_rune_huntsome_t, monsters, flag);
    };
    struct ret_rune_huntsome_fail_t : public jcmd_t<4515>
    {
        int32_t code;
        JSON1(ret_rune_huntsome_fail_t, code);
    };
    //符文增删
    struct nt_rune_change_t : public jcmd_t<4521>
    {
        int32_t pid;
        vector<int32_t> dels;
        vector<jpk_rune_t> adds;
        JSON3(nt_rune_change_t, pid, dels, adds);
    };
    //召唤魔王
    struct req_rune_callboss_t : public jcmd_t<4522>
    {
        JSON0(req_rune_callboss_t);
    };
    struct ret_rune_callboss_t : public jcmd_t<4523>
    {
        int32_t code;
        jpk_rune_monster_t monster;
        JSON2(ret_rune_callboss_t, code, monster);
    };
    //通知符文碎片改变
    struct nt_runechip_change_t : public jcmd_t<4524>
    {
        //当前值
        int32_t now;
        JSON1(nt_runechip_change_t, now)
    };
    //购买符文
    struct req_rune_buy_t : public jcmd_t<4525>
    {
        int32_t resid;
        JSON1(req_rune_buy_t, resid);
    };
    struct ret_rune_buy_t : public jcmd_t<4526>
    {
        int32_t code;
        int32_t resid;
        JSON2(ret_rune_buy_t, code, resid);
    };
    //关闭符文界面
    struct req_rune_close_t : public jcmd_t<4527>
    {
        JSON0(req_rune_close_t);
    };
    struct ret_rune_close_t : public jcmd_t<4528>
    {
        int32_t code;
        JSON1(ret_rune_close_t,code);
    };
    //新手引导系统
    struct nt_guidence_set_t : public jcmd_t<4550>
    {
        int32_t step;
        JSON1(nt_guidence_set_t,step);
    };
    //新手系统奖励伙伴
    struct req_guidence_partner_t : public jcmd_t<4551>
    {
        JSON0(req_guidence_partner_t);
    };
    struct ret_guidence_partner_t : public jcmd_t<4552>
    {
        jpk_role_data_t partner;
        JSON1(ret_guidence_partner_t, partner);
    };
    struct ret_guidence_partner_fail_t : public jcmd_t<4552>
    {
        int32_t code;
        JSON1(ret_guidence_partner_fail_t, code);
    };
    //新手系统设置角色名
    struct req_guidence_rename_t : public jcmd_t<4553>
    {
        string name;
        JSON1(req_guidence_rename_t, name);
    };
    struct ret_guidence_rename_t : public jcmd_t<4554>
    {
        int32_t code;
        JSON1(ret_guidence_rename_t, code);
    };
    //新手系统奖励宝石
    struct req_guidence_gemstone_t : public jcmd_t<4555>
    {
        JSON0(req_guidence_gemstone_t);
    };
    struct ret_guidence_gemstone_t : public jcmd_t<4556>
    {
        int32_t resid;
        int32_t count;
        JSON2(ret_guidence_gemstone_t,resid,count);
    };
    struct ret_guidence_gemstone_fail_t : public jcmd_t<4556>
    {
        int32_t code;
        JSON1(ret_guidence_gemstone_fail_t,code);
    };
    //新手系统奖励元宝
    struct req_guidence_yb_t : public jcmd_t<4557>
    {
        JSON0(req_guidence_yb_t);
    };
    struct ret_guidence_yb_t : public jcmd_t<4558>
    {
        int32_t count;
        JSON1(ret_guidence_yb_t,count);
    };
    //新手系统酒馆
    struct req_guidence_pub_t : public jcmd_t<4559>
    {
        JSON0(req_guidence_pub_t);
    };
    struct ret_guidence_pub_t : public jcmd_t<4560>
    {
        jpk_role_data_t partner;
        int32_t yb_left;
        int32_t kg_left;
        JSON3(ret_guidence_pub_t,partner,yb_left,kg_left);
    };
    struct ret_guidence_pub_fail_t : public jcmd_t<4560>
    {
        int32_t code;
        JSON1(ret_guidence_pub_fail_t,code);
    };
    //新手系统奖励洗礼道具
    struct req_guidence_potential_t : public jcmd_t<4561>
    {
        JSON0(req_guidence_potential_t);
    };
    struct ret_guidence_potential_t : public jcmd_t<4562>
    {
        int32_t code;
        JSON1(ret_guidence_potential_t,code);
    };
    //获得邀请码及邀请好友情况
    struct req_invcode_t : public jcmd_t<4570>
    {
        JSON0(req_invcode_t);
    };
    struct ret_invcode_t : public jcmd_t<4571>
    {
        int code;
        string invcode;
        string inviter;
        int32_t r1; //是否领奖
        int32_t n1; //达到人数
        int32_t r2;
        int32_t n2;
        int32_t r3;
        int32_t n3;
        int32_t r4;
        int32_t n4;
        JSON11(ret_invcode_t,code,invcode,r1,n1,r2,n2,r3,n3,r4,n4,inviter);
    };
    
    //通知客户端邀请码奖励达成情况
    struct nt_invcode_rewinfo_t : public jcmd_t<4573>
    {
        int32_t r1;
        int32_t r2;
        int32_t r3;
        int32_t r4;
        JSON4( nt_invcode_rewinfo_t,r1,r2,r3,r4);
    };

    //领取邀请码奖励
    struct req_invcode_reward_t : public jcmd_t<4574>
    {
        int32_t flag; //1,2,3,4
        JSON1(req_invcode_reward_t,flag);
    };
    struct ret_invcode_reward_t : public jcmd_t<4575>
    {
        int32_t flag;
        int32_t code;
        int32_t dismess;
        JSON3(ret_invcode_reward_t,flag,code,dismess);
    };
    //设置邀请人
    struct req_invcode_set_t : public jcmd_t<4572>
    {
        string invcode;
        JSON1(req_invcode_set_t,invcode);
    };
    struct ret_invcode_set_t : public jcmd_t<4576>
    {
        int32_t code;
        JSON1(ret_invcode_set_t,code);
    };

    //请求记录新手引导状态
    struct req_write_guidence_t : public jcmd_t <4577>
    {
        int32_t index;
        int32_t guideindex;
        JSON2(req_write_guidence_t, index, guideindex);
    };

    //返回记录新手引导态
    struct ret_write_guidence_t : public jcmd_t <4578>
    {
        int32_t index;
        int32_t guideindex;
        JSON2(ret_write_guidence_t, index, guideindex);
    };

    //获取boss死活
    struct req_boss_alive_t : public jcmd_t<4579>
    {
        int32_t flag;  //1-世界boss,2-帮派boss
        JSON1(req_boss_alive_t, flag);
    };
    struct ret_boss_alive_t : public jcmd_t<4580>
    {
        int32_t flag;
        int32_t bosscount;  //本周剩余boss开启次数
        int32_t st; // 1.未开boss, 2.已开boss，boss活, 3.已开boss，boss死
        JSON3(ret_boss_alive_t, flag, bosscount, st);
    };
    struct req_open_union_boss_t : public jcmd_t<4581>
    {
        //int32_t flag; 
        JSON0(req_open_union_boss_t);
    };
    struct ret_open_union_boss_t : public jcmd_t<4582>
    {
        //int32_t flag; 
        int32_t st;
        int32_t m_prepare;
        int32_t m_start;
        int32_t m_end;
        JSON4(ret_open_union_boss_t, st, m_prepare, m_start, m_end);
    };
    //公会
    //创建公会
    struct req_create_gang_t : public jcmd_t<4600>
    {
        string name;
        JSON1(req_create_gang_t, name)
    };

    struct ret_create_gang_t : public jcmd_t<4601>
    {
        int ggid;
        int code;
        JSON2(ret_create_gang_t, ggid, code)
    };
    
    //申请加入公会
    struct req_add_gang_t : public jcmd_t<4602>
    {
        int ggid;
        JSON1(req_add_gang_t, ggid)
    };
    struct ret_add_gang_t : public jcmd_t<4603>
    {
        int code; //8000，公会满
        int ggid;
        JSON2(ret_add_gang_t, code, ggid)
    };

    //申请数据
    struct jpk_gang_requser_t
    {
        int32_t uid;
        string  nickname;
        int32_t grade;
        int32_t rank;
        JSON4(jpk_gang_requser_t, uid, nickname, grade, rank);
    };

    //请求公会申请列表
    struct req_gang_reqlist_t : public jcmd_t<4604>
    {
        JSON0(req_gang_reqlist_t)
    };

    struct ret_gang_reqlist_t : public jcmd_t<4605>
    {
        vector<jpk_gang_requser_t> reqs;
        JSON1(ret_gang_reqlist_t, reqs)
    };


    //通知加入公会结果
    struct nt_add_gang_res_t : public jcmd_t<4606>
    {
        int ggid;
        string name;
        int code;
        JSON3(nt_add_gang_res_t, ggid, name, code)
    };

    struct jpk_gangmem_t
    {
        int uid;
        string name;
        int quality;   //装备最低等级
        int grade;
        int flag; //0:普通会员，1:官员,2:会长
        int gm;
        int totalgm;
        int rank;
        bool online;
        int offtime; //sec
        JSON10(jpk_gangmem_t, uid, name, quality, grade, flag, gm, totalgm, rank, online, offtime)
    };
    
    //请求公会会员列表, 分页请求
    struct req_gang_mem_t : public jcmd_t<4607>
    {
        int page;
        JSON1(req_gang_mem_t, page);
    };

    struct ret_gang_mem_t : public jcmd_t<4608>
    {
        vector<jpk_gangmem_t> members;
        JSON1(ret_gang_mem_t, members)
    };

    //处理公会申请
    struct req_deal_gang_req_t : public jcmd_t<4609> 
    {
        int uid;  //申请者, 如果uid为0，则全部
        int flag; //0:不同意，1:同意
        JSON2(req_deal_gang_req_t, uid, flag)
    };
    struct ret_deal_gang_req_t : public jcmd_t<4610> 
    {
        int code;
        int flag; //0:不同意，1:同意
        JSON2(ret_deal_gang_req_t, code, flag)
    };

    //请求踢人
    struct req_kick_mem_t : public jcmd_t<4611>
    {
        int uid;
        JSON1(req_kick_mem_t, uid)
    };
    struct ret_kick_mem_t : public jcmd_t<4612>
    {
        int uid;
        int code;
        JSON2(ret_kick_mem_t, uid, code)
    };

    //请求设置官员
    struct req_set_adm_t : public jcmd_t<4613>
    {
        int32_t uid;
        bool    isadm;
        JSON2(req_set_adm_t, uid, isadm)
    };
    struct ret_set_adm_t : public jcmd_t<4614>
    {
        int32_t uid;
        bool    isadm;
        int     code;
        JSON3(ret_set_adm_t, code, uid, isadm)
    };

    //请求设置公告
    struct req_set_notice_t : public jcmd_t<4615>
    {
        string notice;
        JSON1(req_set_notice_t, notice);
    };

    struct ret_set_notice_t : public jcmd_t<4616>
    {
        int code;
        JSON1(ret_set_notice_t, code);
    };

    //请求解散公会
    struct req_close_gang_t : public jcmd_t<4617>
    {
        JSON0(req_close_gang_t)
    };
    struct ret_close_gang_t : public jcmd_t<4618>
    {
        int32_t code;
        JSON1(ret_close_gang_t, code)
    };

    //公会留言
    struct nt_gang_msg_t : public jcmd_t<4619>
    {
        int type;
        string msg;
        JSON2(nt_gang_msg_t, type, msg)
    };

    //设置公会boss时间
    struct req_set_gang_boss_time_t : public jcmd_t<4620>
    {
        //0~6，boss出现在星期几,0周日
        int day;
        JSON1(req_set_gang_boss_time_t, day)
    };
    struct ret_set_gang_boss_time_t : public jcmd_t<4621>
    {
        int code;
        JSON1(ret_set_gang_boss_time_t, code);
    };

    //设置公会boss时间
    struct nt_gang_boss_time_t : public jcmd_t<4622>
    {
        int day;
        JSON1(nt_gang_boss_time_t, day)
    };

    //请求公会boss信息
    struct req_gboss_info_t : public jcmd_t<4630>
    {
        JSON0(req_gboss_info_t)
    };
    struct ret_gboss_info_t : public jcmd_t<4631>
    {
        //boss resid
        int resid;
        //hp
        int hp;
        //最大hp
        int hpmax;
        //开放倒计时
        int countdown;
        JSON4(ret_gboss_info_t, resid, hp, hpmax, countdown)
    };

    //请求获取公会boss对战排名
    struct req_gboss_rank_t : public jcmd_t<4632>
    {
        JSON0(req_gboss_rank_t)
    };

    struct jpk_gboss_rank_t
    {
        int         uid;
        string      nickname;
        int         dmg;
        int         rank;
        JSON4(jpk_gboss_rank_t, uid, nickname, dmg, rank)
    };
    struct ret_gboss_rank_t : public jcmd_t<4633>
    {
        vector<jpk_gboss_rank_t> rank;
        JSON1(ret_gboss_rank_t, rank)
    };

    //请求挑战boss
    struct req_gboss_fight_t : public jcmd_t<4634>
    {
        JSON0(req_gboss_fight_t)
    };

    struct ret_gboss_fight_t : public jcmd_t<4635>
    {
        //错误码
        int code;
        //总伤害
        int dmg;
        //是否pk掉boss
        bool iswin;
        JSON3(ret_gboss_fight_t, code, dmg, iswin);
    };

    struct jpk_gang_pro_t
    {
        int             ggid;  //公会id
        int             level; //等级
        int             exp;   //经验
        int             online;//在线人数
        int             total; //总人数
        string          name;  //公会名
        string          cname; //公会会长名
        int             quality; //会长的最低装备等级  
        int             cgrade; //会长等级
        int             reqed; //是否申请加入当前公会, 0未申请，1已申请
        int             grank;  //公会排名
        JSON11(jpk_gang_pro_t, ggid, level, exp, online, total, name, cname, quality, cgrade, reqed, grank)
    };

    //请求公会信息
    struct req_gang_info_t : public jcmd_t<4650>
    {
        int ggid;
        JSON1(req_gang_info_t, ggid)
    };

    struct jpk_gang_msg_t
    {
        int         type;
        uint32_t    offtime;
        string      nickname;
        int         grade;
        int         quality;
        string      msg;
        JSON6(jpk_gang_msg_t, type, offtime, nickname, msg, grade,quality)
    };

    struct jpk_hongbao_t
    {
        uint64_t id;
        int yb;
        //发红包的角色uid
        int uid;
        int quality;
        //发红包的角色名
        string nickname;
        //剩余领取次数
        int count;
        JSON5(jpk_hongbao_t, uid, id, yb, nickname, quality)
    };

    struct ret_gang_info_t : public jcmd_t<4651>
    {
        jpk_gangmem_t   mem;    //请求者的公会成员数据
        jpk_gang_pro_t  pro;    //公会属性
        string          notice; //公告
        vector<string>  msgs;   //留言, serial jpk_gang_msg_t
        int             dpm;    //当天捐献总钱数
        int             bossday;//公会世界boss天
        int             bosslv; //公会boss等级
        vector<jpk_hongbao_t> hongbao;//公会红包
        JSON8(ret_gang_info_t, mem, pro, notice, msgs, dpm, bossday, bosslv, hongbao)
    };
    struct ret_gang_info_failed_t : public jcmd_t<4651>
    {
        int code;
        JSON1(ret_gang_info_failed_t, code)
    };

    //请求公会列表
    struct req_gang_list_t : public jcmd_t<4652>
    {
        int page;
        JSON1(req_gang_list_t, page);
    };
    struct ret_gang_list_t : public jcmd_t<4653>
    {
        vector<jpk_gang_pro_t> gangs;
        JSON1(ret_gang_list_t, gangs)
    };

    //学习公会技能
    struct req_learn_gskl_t : public jcmd_t<4654>
    {
        int resid;
        JSON1(req_learn_gskl_t, resid)
    };
    struct ret_learn_gskl_t : public jcmd_t<4655>
    {
        int code;
        JSON1(ret_learn_gskl_t, code)
    };

    //公会捐献
    struct req_gang_pay_t : public jcmd_t<4656>
    {
        int money;
        int rmb;
        JSON2(req_gang_pay_t, money, rmb);
    };
    struct ret_gang_pay_t : public jcmd_t<4657>
    {
        int code;
        int dpm; //当天已经捐献的总钱数
        JSON2(ret_gang_pay_t, code, dpm);
    };

    //公会祭祀
    struct req_gang_pray_t : public jcmd_t<4658>
    {
        JSON0(req_gang_pray_t)
    };
    struct ret_gang_pray_t : public jcmd_t<4659>
    {
        int code;
        //数量
        int num;
        //出现的道具id
        int resid;
        int loc;
        JSON4(ret_gang_pray_t, code, num, resid, loc)
    };

    //查找公会
    struct req_search_gang_t : public jcmd_t<4660>
    {
        string name;
        JSON1(req_search_gang_t, name)
    };
    struct ret_search_gang_t : public jcmd_t<4661>
    {
        vector<jpk_gang_pro_t> gangs;
        JSON1(ret_search_gang_t, gangs)
    };

    //通知公会等级改变
    struct nt_gang_level_change_t : public jcmd_t<4662>
    {
        int level; 
        int exp;
        JSON2(nt_gang_level_change_t, level, exp)
    };

    //通知公会用户贡献改变
    struct nt_gang_pay_change_t : public jcmd_t<4663>
    {
        int gm;
        int totalgm;
        JSON2(nt_gang_pay_change_t, gm, totalgm);
    };

    //通知公会经验改变
    struct nt_gang_exp_change_t : public jcmd_t<4664>
    {
        int exp;
        JSON1(nt_gang_exp_change_t, exp)
    };

    struct jpk_gskl_t
    {
        int resid;
        int level;
        JSON2(jpk_gskl_t, resid, level)
    };

    //请求公会会员的公会技能列表
    struct req_gskl_list_t : public jcmd_t<4665>
    {
        JSON0(req_gskl_list_t)
    };
    struct ret_gskl_list_t : public jcmd_t<4666>
    {
        vector<jpk_gskl_t> gskls;
        int32_t gm;
        int32_t lv;
        JSON3(ret_gskl_list_t, gskls,gm,lv)
    };

    //通知公会技能等级改变
    struct nt_gskl_lv_change_t:public jcmd_t<4667>
    {
        int resid;
        int level;
        JSON2(nt_gskl_lv_change_t, resid, level);
    };

    //请求离开公会
    struct req_leave_gang_t : public jcmd_t<4668>
    {
        JSON0(req_leave_gang_t)
    };
    struct ret_leave_gang_t : public jcmd_t<4669>
    {
        int code;
        JSON1(ret_leave_gang_t, code);
    };

    //改变公会会长
    struct req_change_charman_t : public jcmd_t<4670>
    {
        //新会长用户id
        int uid;
        JSON1(req_change_charman_t, uid)
    };
    struct ret_change_charman_t : public jcmd_t<4671>
    {
        int code;
        JSON1(ret_change_charman_t, code)
    };

    //请求进入祭坛
    struct req_enter_pray_t : public jcmd_t<4672>
    {
        JSON0(req_enter_pray_t);
    };
    struct ret_enter_pray_t : public jcmd_t<4673>
    {
        int code;
        int prn;
        int lv;
        int gm;
        JSON4(ret_enter_pray_t,code,prn,lv,gm);
    };
    //推送公会申请通知
    struct nt_gang_req_t : public jcmd_t<4674>
    {
        int32_t code;
        JSON1(nt_gang_req_t,code);
    };

    /////////////新关卡协议//////////////////////
    //请求进入普通关卡
    struct req_round_enter_t : public jcmd_t<4680>
    {
        int32_t resid;
        int32_t uid;
        int32_t pid;
        JSON3(req_round_enter_t,resid,uid,pid);
    };
    //请求进入精英关卡
    struct req_elite_enter_t : public jcmd_t<4681>
    {
        int32_t resid;
        JSON1(req_elite_enter_t,resid);
    };
    //请求重置精英关卡
    struct req_reset_elite_t : public jcmd_t<5453>
    {
        int32_t resid;
        JSON1(req_reset_elite_t,resid);
    };
    //返回重置精英关卡
    struct ret_reset_elite_t : public jcmd_t<5454>
    {
        int32_t resid;
        int32_t code;
        string new_round_times;
        string new_reset_times;
        JSON4(ret_reset_elite_t,resid,new_round_times,new_reset_times, code);
    };
    //请求进入十二宫关卡
    struct req_zodiac_enter_t : public jcmd_t<4682>
    {
        int32_t resid;
        int32_t uid;
        int32_t pid;
        JSON3(req_zodiac_enter_t,resid,uid,pid);
    };
    //进入关卡返回，包括普通关卡，精英关卡，十二宫关卡
    struct ret_round_enter_t : public jcmd_t<4683>
    {
        int32_t resid;
        vector<jpk_item_t> drop_items;
        int32_t exp;
        int32_t coin;
        int32_t lovevalue;
        int32_t rmb;
        float hp_percent;
        int fpower;
        //按照数组下标对应当前怒气
        //[pid][anger]
        map<int, int> angers;
        jpk_view_role_data_t hhero;
        string salt;
        JSON11(ret_round_enter_t,resid,drop_items,exp,coin,lovevalue,rmb,hhero, angers, fpower, hp_percent, salt);
    };
    struct ret_round_enter_failed_t : public jcmd_t<4683>
    {
        int32_t resid;
        uint16_t code;
        JSON2(ret_round_enter_failed_t,resid,code);
    };
    //客户端请求结束关卡
    struct jpk_round_monster_t
    {
        int resid;
        int num;
        JSON2(jpk_round_monster_t, resid, num)
    };
    //结束普通关卡
    struct req_round_exit_t : public jcmd_t<4684>
    {
        int32_t resid;
        bool win;
        string stars;
        string salt;
        vector<jpk_round_monster_t> killed;
        JSON5(req_round_exit_t, resid, win, stars, salt, killed)
    };
    //结束精英关卡
    struct req_elite_exit_t : public jcmd_t<4685>
    {
        int32_t resid;
        bool win;
        int32_t stars;
        vector<jpk_round_monster_t> killed;
        JSON4(req_elite_exit_t, resid, win, stars, killed)
    };
    //结束黄道十二宫
    struct req_zodiac_exit_t : public jcmd_t<4686>
    {
        int32_t resid;
        bool win;
        int32_t stars;
        vector<jpk_round_monster_t> killed;
        //血量百分比
        float hp_percent;
        //手指滑动的能量
        int fpower;
        //按照数组下标对应当前怒气
        //[pid][anger]
        map<int, int> angers;
        JSON7(req_zodiac_exit_t, resid, win, stars, killed, hp_percent, fpower, angers)
    };
    //服务器返回结束关卡
    struct ret_round_exit_t : public jcmd_t<4687>
    {
        int32_t resid;
        bool win;
        string stars;
        string new_round_times;
        string round_stars_reward;
        JSON5(ret_round_exit_t,resid,win,stars,new_round_times, round_stars_reward);
    };
    //十二宫挂机
    struct jpk_pass_result_t
    {
        int32_t resid;
        int32_t exp;
        int32_t coin;
        int32_t rmb;
        vector<jpk_item_t> drops;
        JSON5(jpk_pass_result_t,resid,exp,coin,rmb,drops);
    };
    struct req_zodiac_pass_t : public jcmd_t<4688>
    {
        int32_t gid;
        JSON1(req_zodiac_pass_t,gid);
    };
    struct ret_zodiac_pass_t : public jcmd_t<4689>
    {
        int32_t gid;
        vector<jpk_pass_result_t> results;
        JSON2(ret_zodiac_pass_t,gid,results);
    };

    //请求刷新精英关卡和黄道十二宫关卡
    struct req_round_flush_t : public jcmd_t<4690>
    {
        //黄道十二宫关卡 gid=300
        //精英关卡 实际gid
        uint16_t gid;
        JSON1(req_round_flush_t, gid);
    };
    struct ret_round_flush_t : public jcmd_t<4691>
    {
        uint16_t code;
        int32_t gid;
        JSON2(ret_round_flush_t, code, gid );
    };
    //普通关卡挂机
    struct req_round_pass_t : public jcmd_t<4692>
    {
        int32_t resid;
        int32_t count;
        JSON2(req_round_pass_t,resid,count);
    };
    struct req_round_pass_new_t : public jcmd_t<4696>
    {
        int32_t resid;
        int32_t count;
        vector<jpk_round_monster_t> killed;
        JSON3(req_round_pass_new_t,resid,count,killed);
    };
    struct jpk_pass_round_result_t
    {
        int32_t exp;
        int32_t coin;
        int32_t rmb;
        int32_t lovevalue;
        vector<jpk_item_t> drop_items;
        JSON5(jpk_pass_round_result_t,exp,coin,rmb,drop_items, lovevalue);
    };
    struct ret_round_pass_t : public jcmd_t<4693>
    {
        int32_t resid;
        int32_t count;
        vector<jpk_pass_round_result_t> results;
        int32_t left_secs;
        string times;
        string new_round_times;
        JSON6(ret_round_pass_t,resid,count,results,left_secs,times,new_round_times);
    };
    struct ret_round_pass_fail_t : public jcmd_t<4693>
    {
        int32_t resid;
        int32_t count;
        int32_t code;
        JSON3(ret_round_pass_fail_t,resid,count,code);
    };
    //清除普通关卡挂机cd
    struct req_round_pass_clear_cd_t : public jcmd_t<4694>
    {
        JSON0(req_round_pass_clear_cd_t);
    };
    struct ret_round_pass_clear_cd_t : public jcmd_t<4695>
    {
        int32_t code;
        JSON1(ret_round_pass_clear_cd_t,code);
    };
    /////////////////////////////////////////

    //up_xx消息是更新请求消息
    //请求更新队伍属性数据
    struct up_team_pro_t : public jcmd_t<4700>
    {
        JSON0(up_team_pro_t);
    };

    //通知被提出公会
    struct nt_kick_gang_t :  public jcmd_t<4701>
    {
        int ggid;
        JSON1(nt_kick_gang_t, ggid)
    };

    //商城
    struct req_shop_buy_t : public jcmd_t<4801>
    {
        int id;
        int num;
        JSON2(req_shop_buy_t, id, num)
    };

    struct ret_shop_buy_t : public jcmd_t<4802>
    {
        int code;
        int id;
        int num;
        int dbid;
        JSON4(ret_shop_buy_t, id, num, dbid, code)
    };

    struct req_shop_items_t : public jcmd_t<4803>
    {
        int tab;
        int page;
        int sheet;
        JSON3(req_shop_items_t, tab, page, sheet)
    };

    struct shop_item_t
    {
        int id;
        int tab;
        int page;
        int item_id;
        int money_type;
        int sheet;
        int price;
        int ishot;
        int isnew;
        //islimit,0:不限量 >0:限量,个数 -1:限量,售完
        int islimit;         
        int discount;
        int imt;
        int time;
        JSON13(shop_item_t, id, tab, page, item_id, money_type, price, ishot, isnew, sheet, islimit, discount, imt, time)
    };

    struct ret_shop_items_t : public jcmd_t<4804>
    {
        int tab;
        int page;
        vector<shop_item_t> items;
        vector<shop_item_t> lmtitems;
        JSON2(ret_shop_items_t, items, lmtitems)
    };

    //npc商城
    struct req_npc_shop_buy_t : public jcmd_t<4862>
    {
        int id;
        int placeNum;
        int typenum;
        JSON3(req_npc_shop_buy_t, id, placeNum, typenum)
    };

    struct ret_npc_shop_buy_t : public jcmd_t<4863>
    {
        int code;
        int id;
        int placeNum;
        int dbid;
        JSON4(ret_npc_shop_buy_t, id, placeNum, dbid, code)
    };

    struct req_npcshop_items_t : public jcmd_t<4860>
    {
        int typenum;
        JSON1(req_npcshop_items_t, typenum)
    };

    struct npcshop_item_t
    {
        int id;
        int item_id;
        int money_type;
        int price;
        int item_num;
        int buytype;
        int probability;
        //islimit,0:不限量 >0:限量,个数 -1:限量,售完
        int islimit;         
        JSON8(npcshop_item_t, id, item_id, money_type, price, item_num, buytype, probability, islimit)
    };    
    
    struct ret_npcshop_items_t : public jcmd_t<4861>
    {
        vector<npcshop_item_t> items;
        JSON1(ret_npcshop_items_t, items)
    };

    struct req_npc_shop_update_t : public jcmd_t<4864>
    {
        int typenum;
        JSON1(req_npc_shop_update_t, typenum)
    };

    struct ret_npc_shop_update_t : public jcmd_t<4865>
    {
        int code;
        int typenum;
        JSON2(ret_npc_shop_update_t, code, typenum)
    };

    //炼金
    struct req_buy_coin_t : public jcmd_t<4810>
    {
        JSON0(req_buy_coin_t)
    };

    struct ret_buy_coin_t : public jcmd_t<4811>
    {
        int code;
        int times;
        JSON2(ret_buy_coin_t, code, times);
    };

    //vip等级改变
    struct nt_vip_levelup_t : public jcmd_t<4820>
    {
        int now;
        int32_t week_reward;
        JSON2(nt_vip_levelup_t, now, week_reward);
    };
    struct nt_vip_exp_changed_t : public jcmd_t<4821>
    {
        int now;
        JSON1(nt_vip_exp_changed_t, now);
    };

    //出售
    struct req_sell_t : public jcmd_t<4830>
    {
        //equip:eid>0,item:eid==0
        int eid;
        //item:resid
        int resid;
        JSON2(req_sell_t, eid, resid)
    };
    struct ret_sell_t : public jcmd_t<4831>
    {
        int code;
        JSON1(ret_sell_t, code)
    };

/*
    //获取排名奖励信息
    struct req_rank_reward_t : public jcmd_t<4840>
    {
        JSON0(req_rank_reward_t);
    };
    struct ret_rank_reward_t : public jcmd_t<4841>
    {
        //code不为0，表示当前没有奖励
        int code;
        //发奖时的排名
        int rank;
        JSON2(ret_rank_reward_t, code, rank);
    };

    //请求领取竞技场奖励
    struct req_given_rank_reward_t : public jcmd_t<4842>
    {
        JSON0(req_given_rank_reward_t)
    };
    struct ret_given_rank_reward_t : public jcmd_t<4843>
    {
        //0表示领取成功
        int code;
        JSON1(ret_given_rank_reward_t, code)
    };
*/

    //请求领取体力奖励
    struct req_given_power_reward_t : public jcmd_t<4844>
    {
        JSON0(req_given_power_reward_t);
    };
    struct ret_given_power_reward_t : public jcmd_t<4845>
    {
        int code;
        JSON1(ret_given_power_reward_t, code)
    };

    //请求领取体力奖励
    struct req_reward_power_cd_t : public jcmd_t<4854>
    {
        JSON0(req_reward_power_cd_t);
    };
    struct ret_reward_power_cd_t : public jcmd_t<4855>
    {
        //如果返回<0则表示当前请求无效
        int cd;
        JSON1(ret_reward_power_cd_t, cd)
    };

    //请求vip升级奖励
    struct req_given_vip_reward_t : public jcmd_t<4846>
    {
        int viplevel;
        JSON1(req_given_vip_reward_t, viplevel)
    };
    struct ret_given_vip_reward_t : public jcmd_t<4847>
    {
        int code;
        int viplevel;
        JSON2(ret_given_vip_reward_t , code, viplevel);
    };
    //领取战斗力冲刺活动奖励
    struct req_fp_reward_t : public jcmd_t<4848>
    {
        int32_t pos;
        JSON1(req_fp_reward_t,pos);
    };
    struct ret_fp_reward_t : public jcmd_t<4849>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_fp_reward_t,pos,code);
    };
    //请求vip购买信息
    struct req_buy_vip_info_t : public jcmd_t<4900>
    {
        int flag;
        int resid; //英雄迷窟重置，填resid,其他购买不需要
        JSON2(req_buy_vip_info_t, flag, resid)
    };
    struct ret_buy_vip_info_t : public jcmd_t<4901>
    {
        //需要的元宝
        uint32_t yb;
        //还可以购买的次数
        uint32_t count;
        JSON2(ret_buy_vip_info_t, yb, count)
    };

    //请求购买体力
    struct req_buy_power_t : public jcmd_t<4902>
    {
        JSON0(req_buy_power_t)
    };
    struct ret_buy_power_t : public jcmd_t<4903>
    {
        int code;
        JSON1(ret_buy_power_t,code);
    };
    //请求购买活力
    struct req_buy_energy_t : public jcmd_t<4904>
    {
        JSON0(req_buy_energy_t)
    };
    struct ret_buy_energy_t : public jcmd_t<4905>
    {
        int code;
        JSON1(ret_buy_energy_t,code);
    };
    //请求随机名字
    struct req_random_name_t : public jcmd_t<4906>
    {
        JSON0(req_random_name_t);
    };
    struct ret_random_name_t : public jcmd_t<4907>
    {
        string name;
        JSON1(ret_random_name_t,name);
    };
    //请求在线奖励cd
    struct req_online_reward_cd_t : public jcmd_t<4910>
    {
        JSON0(req_online_reward_cd_t)
    };
    struct ret_online_reward_cd_t : public jcmd_t<4911>
    {
        int cd;
        JSON1(ret_online_reward_cd_t, cd)
    };
    //请求在线奖励
    struct req_online_reward_t : public jcmd_t<4912>
    {
        JSON0(req_online_reward_t)
    };
    struct ret_online_reward_t : public jcmd_t<4913>
    {
        int code;
        int resid; //在线奖励表的id
        JSON2(ret_online_reward_t, code, resid)
    };
    //请求在线奖励Id
    struct req_online_reward_num_t : public jcmd_t<4914>
    {
        JSON0(req_online_reward_num_t)
    };
    struct ret_online_reward_num_t : public jcmd_t<4915>
    {
        int code;
        int resid; //在线奖励表的id
        JSON2(ret_online_reward_num_t, code, resid)
    };
    //请求离开游戏
    struct req_quit_game_t : public jcmd_t<4920>
    {
        JSON0(req_quit_game_t)
    };
    struct ret_quit_game_t : public jcmd_t<4921>
    {
        int code;
        JSON1(ret_quit_game_t, code)
    };

    //请求领取登陆奖励
    struct req_login_yb_t : public jcmd_t<4922>
    {
        JSON0(req_login_yb_t)
    };

    struct ret_login_yb_t : public jcmd_t<4923>
    {
        int code;
        vector<jpk_item_t> items;
        JSON2(ret_login_yb_t, code, items)
    };

    //请求购买元宝
    struct req_buy_yb_t : public jcmd_t<4990>
    {
        int id;
        string appid;
        string uin;
        string domain;
        JSON4(req_buy_yb_t, id, appid, uin, domain)
    };
    struct ret_buy_yb_t : public jcmd_t<4991>
    {
        int code;
        //订单号
        uint32_t serid;
        JSON2(ret_buy_yb_t, code, serid)
    };

    //请求购买yb表
    struct req_pay_repo_t : public jcmd_t<4993>
    {
        string domain;
        JSON1(req_pay_repo_t, domain)
    };

    struct ret_pay_repo_t : public jcmd_t<4994>
    {
        //json字符串
        string repo;
        JSON1(ret_pay_repo_t, repo)
    };

    //请求购买背包格子
    struct req_buy_bag_cap_t : public jcmd_t<5000>
    {
        JSON0(req_buy_bag_cap_t)
    };
    //返回购买背包容量
    struct ret_buy_bag_cap_t : public jcmd_t<5001>
    {
        int code;
        //当前背包容量
        int cap;
        JSON2(ret_buy_bag_cap_t, code, cap)
    };

    struct jpk_city_boss_t
    {
        int id;
        int resid; 
        int level;
        int x;
        int y;
        //被杀死的次数
        int killcount;
        //0表示不再战斗中，1表示在战斗中
        int fighting;
        JSON7(jpk_city_boss_t, id, resid, level, x, y, killcount, fighting)
    };

    //请求主城boss信息
    struct req_city_boss_info_t : public jcmd_t<5010>
    {
        //场景id
        int sceneid;
        JSON1(req_city_boss_info_t, sceneid)
    };

    //返回主城boss信息
    struct ret_city_boss_info_t : public jcmd_t<5011>
    {
        int code;
        //倒计时
        int cd;
        //boss信息
        vector<jpk_city_boss_t> bosses;
        //用户当前已经击杀boss的次数
        int killcount;
        JSON4(ret_city_boss_info_t, code, cd, bosses, killcount)
    };

    //请求挑战主城boss
    struct req_fight_city_boss_t : public jcmd_t<5012>
    {
        int bossid;
        bool win;
        JSON2(req_fight_city_boss_t, bossid, win)
    };

    //返回挑战主城boss
    struct ret_fight_city_boss_t : public jcmd_t<5013>
    {
        int code;
        JSON1(ret_fight_city_boss_t, code)
    };

    //请求开始挑战boss
    struct req_begin_fight_city_boss_t : public jcmd_t<5014>
    {
        int bossid;
        JSON1(req_begin_fight_city_boss_t, bossid)
    };

    //返回请求开始挑战boss
    struct ret_begin_fight_city_boss_t : public jcmd_t<5015>
    {
        int bossid;
        int code;
        vector<jpk_item_t> drop_items;
        int gold;
        JSON4(ret_begin_fight_city_boss_t, bossid, code, drop_items, gold)
    };

    //通知cityboss状态
    struct nt_city_boss_state_t : public jcmd_t<5016>
    {
        int sceneid;
        vector<int> bossids;
        //0:无特殊状态,1:在战斗中,2:消失,3:出生
        int state;
        JSON3(nt_city_boss_state_t, sceneid, bossids, state)
    };

    //星座图系统
    struct req_star_open_t : public jcmd_t<5020>
    {
        int32_t pid;
        int32_t lv;
        int32_t pos;
        JSON3(req_star_open_t,pid,lv,pos);
    };
    struct ret_star_open_t : public jcmd_t<5021>
    {
        int32_t code;
        int32_t pid;
        int32_t lv;
        int32_t pos;
        int32_t att;
        int32_t value;
        JSON6(ret_star_open_t,code,pid,lv,pos,att,value);
    };
    struct req_star_flush_t : public jcmd_t<5022>
    {
        int32_t pid;
        int32_t lv;
        int32_t pos;
        int32_t flag;   //1.星点  2.水晶
        JSON4(req_star_flush_t,pid,lv,pos,flag);
    };
    struct ret_star_flush_t : public jcmd_t<5023>
    {
        int32_t pid;
        int32_t code;
        int32_t lv;
        int32_t pos;
        int32_t att;
        int32_t value;
        JSON6(ret_star_flush_t,pid,code,lv,pos,att,value);
    };
    struct req_lv_reward_t : public jcmd_t<5024>
    {
        int32_t lv;
        JSON1(req_lv_reward_t,lv);
    };
    struct ret_lv_reward_t : public jcmd_t<5025>
    {
        int32_t lv;
        int32_t code;
        JSON2(ret_lv_reward_t,lv,code);
    };
    struct req_star_set_t : public jcmd_t<5026>
    {
        JSON0(req_star_set_t);
    };
    struct ret_star_set_t : public jcmd_t<5027>
    {
        int32_t code;
        JSON1(ret_star_set_t,code);
    };
    struct req_star_get_t : public jcmd_t<5028>
    {
        int32_t pid;
        int32_t lv;
        int32_t pos;
        int32_t flag;   //1.星点  2.水晶
        JSON4(req_star_get_t,pid,lv,pos,flag);
    };
    struct ret_star_get_t : public jcmd_t<5029>
    {
        int32_t pid;
        int32_t code;
        int32_t lv;
        int32_t pos;
        int32_t att;
        int32_t value;
        JSON6(ret_star_get_t,pid,code,lv,pos,att,value);
    };

    //图纸合成
    struct req_compose_drawing_t : public jcmd_t<5030>
    {
        //目标图纸
        int resid;
        //材料图纸
        vector<int> source;
        JSON2(req_compose_drawing_t, resid, source)
    };
    //返回图纸合成结果
    struct ret_compose_drawing_t : public jcmd_t<5031>
    {
        int code;
        JSON1(ret_compose_drawing_t, code)
    };

    //请求领取关卡星级奖励
    struct req_starreward_t : public jcmd_t<5040>
    {
        //关卡页面id
        int id;
        int starnum;  // 10, 20, 30
        JSON2(req_starreward_t, id, starnum)
    };
    struct ret_starreward_t : public jcmd_t<5041>
    {
        int code;
        JSON1(ret_starreward_t, code)
    };

    //请求关卡星级信息
    struct req_starreward_info_t : public jcmd_t<5042>
    {
        //关卡页面id
        int id;
        JSON1(req_starreward_info_t, id)
    };

    struct ret_starreward_info_t : public jcmd_t<5043>
    {
        int code;
        //关卡页面id
        int id;
        //领取的关卡奖励
        //数组的值0:表示未领取，1:表示领取
        yarray_t<int, 4> given;
        JSON3(ret_starreward_info_t, code, id, given)
    };
    //修改附加功能点
    struct nt_function_t : public jcmd_t<5044>
    {
        uint64_t func;
        JSON1(nt_function_t,func);
    };
    //领取序列号奖励
    struct req_cdkey_reward_t : public jcmd_t<5055>
    {
        string cdkey;
        JSON1(req_cdkey_reward_t,cdkey);
    };
    struct ret_cdkey_reward_t : public jcmd_t<5056>
    {
        int32_t code;
        int32_t resid;
        vector<vector<int32_t>> items;
        JSON3(ret_cdkey_reward_t,code,resid,items);
    };


    //乱斗场报名
    struct req_scuffle_regist_t : public jcmd_t<5060>
    {
        JSON0(req_scuffle_regist_t);
    };
    struct ret_scuffle_regist_t : public jcmd_t<5061>
    {
        int32_t code;
        JSON1(ret_scuffle_regist_t,code);
    };
    //请求离开乱斗场
    struct req_scuffle_leave_scene : public jcmd_t<5062>
    {
        JSON0(req_scuffle_leave_scene);
    };
    struct ret_scuffle_leave_scene : public jcmd_t<5063>
    {
        int32_t sceneid;
        int x;
        int y;
        JSON3(ret_scuffle_leave_scene,sceneid, x, y);
    };
    struct jpk_scuffle_partner_t
    {
        int32_t pid;
        float hp;
        JSON2(jpk_scuffle_partner_t, pid, hp)
    };

    //进入战斗
    struct req_scuffle_battle_t : public jcmd_t<5064>
    {
        int32_t uid;
        JSON1(req_scuffle_battle_t,uid);
    };
    struct ret_scuffle_battle_t : public jcmd_t<5065>
    {
        int32_t code;
        string view_data;
        vector<jpk_scuffle_partner_t> team_self;
        vector<jpk_scuffle_partner_t> team_enemy;
        JSON4(ret_scuffle_battle_t, code, view_data, team_self, team_enemy)
    };
    struct ret_scuffle_battle_fail_t : public jcmd_t<5065>
    {
        int32_t code;
        JSON1(ret_scuffle_battle_fail_t, code)
    };

    //战斗结束
    struct req_scuffle_battle_end_t : public jcmd_t<5067>
    {
        bool is_win;
        vector<jpk_scuffle_partner_t> team_hp;
        JSON2(req_scuffle_battle_end_t, is_win, team_hp);
    };
    struct ret_scuffle_battle_end_t : public jcmd_t<5068>
    {
        int32_t code;
        int32_t x;
        int32_t y;
        JSON3(ret_scuffle_battle_end_t, code, x, y);
    };
    //角色出现
    struct nt_scuffle_hero_in_t : public jcmd_t<5069>
    {
        int32_t uid;
        int32_t resid;
        string name;
        int32_t level;
        int32_t weaponid;
        int32_t x, y;
        int32_t in_battle;
        int32_t n_win;
        int32_t n_con_win;
        int32_t wingid;
        bool have_pet;
        int32_t petid;
        JSON13(nt_scuffle_hero_in_t,uid,resid,name,level,weaponid,x,y,in_battle,n_win,n_con_win, wingid, have_pet, petid)
    };
    //角色状态改变
    struct nt_scuffle_hero_change_t : public jcmd_t<5070>
    {
        int32_t uid;
        int32_t in_battle;
        int32_t n_win;
        int32_t n_con_win;
        int32_t score;
        int32_t morale;
        JSON6(nt_scuffle_hero_change_t, uid,in_battle,n_win,n_con_win, score, morale);
    };
    //请求积分排名
    struct req_scuffle_ranking_t : public jcmd_t<5071>
    {
        JSON0(req_scuffle_ranking_t);
    };
    struct jpk_hero_info_t
    {
        int32_t rank;
        int32_t score;
        int32_t uid;
        string nickname;
        JSON4(jpk_hero_info_t,rank,score,uid,nickname);
    };
    struct ret_score_ranking_t : public jcmd_t<5072>
    {
        int32_t left;
        vector<jpk_hero_info_t> rank;
        JSON2(ret_score_ranking_t,left,rank);
    };
    //通知乱斗场结束
    struct nt_scuffle_end_t : public jcmd_t<5073>
    {
        int32_t uid;   //>0:擂台主 0:乱斗场结束 -1:被踢
        JSON1(nt_scuffle_end_t,uid);
    };
    //获取乱斗场状态
    struct req_scuffle_state_t : public jcmd_t<5074>
    {
        JSON0(req_scuffle_state_t);
    };
    struct ret_scuffle_state_t : public jcmd_t<5075>
    {
        int32_t code;
        int32_t state; // 0 不在时间段； 1 报名； 2 战斗;  3 战斗结束；
        int32_t self_state; // 0 未报名； 1 已报名；
        int32_t remain_time;
        JSON3(ret_scuffle_state_t, state, self_state, remain_time);
    };
    //全服通告积分排名
    struct nt_score_ranking_t : public jcmd_t<5090>
    {
        vector<jpk_hero_info_t> top;
        JSON1(nt_score_ranking_t,top);
    };

    //领取累计登录30天活动奖励
    struct req_cumulogin_reward_t : public jcmd_t<5078>
    {
        int32_t lv;
        JSON1(req_cumulogin_reward_t,lv);
    };
    struct ret_cumulogin_reward_t : public jcmd_t<5079>
    {
        int32_t code;
        JSON1(ret_cumulogin_reward_t,code);
    };
    //玩家成功充值多少水晶
    struct nt_payyb_change_t : public jcmd_t<5080>
    {
        int32_t delta;
        JSON1(nt_payyb_change_t,delta);
    };
    //玩家连续登录领取了一个金色英雄
    struct nt_conlogin_hero_t : public jcmd_t<5081>
    {
        int32_t resid;
        JSON1(nt_conlogin_hero_t,resid);
    };

    //战斗力排行榜
    struct jpk_fp_node_t 
    {
        int32_t uid;
        string nickname;
        int32_t lv;
        int32_t fp;
        int32_t vip;
        JSON5(jpk_fp_node_t,uid,nickname,lv,fp,vip);
    };
    struct req_fp_rank_t : public jcmd_t<5082>
    {
        JSON0(req_fp_rank_t);
    };
    struct ret_fp_rank_t : public jcmd_t<5083>
    {
        vector<jpk_fp_node_t> users;
        JSON1(ret_fp_rank_t,users);
    };

    //等级排行榜
    struct jpk_lv_node_t 
    {
        int32_t uid;
        string nickname;
        int32_t lv;
        int32_t exp;
        int32_t vip;
        JSON5(jpk_lv_node_t,uid,nickname,lv,exp,vip);
    };
    struct req_lv_rank_t : public jcmd_t<5084>
    {
        JSON0(req_lv_rank_t);
    };
    struct ret_lv_rank_t : public jcmd_t<5085>
    {
        vector<jpk_lv_node_t> users;
        JSON1(ret_lv_rank_t,users);
    };
    //同步战力
    struct req_sync_fp_t : public jcmd_t<5086>
    {
        JSON0(req_sync_fp_t);
    };
    struct ret_sync_fp_t : public jcmd_t<5087>
    {
        int32_t fp;
        JSON1(ret_sync_fp_t,fp);
    }; 
    //请求竞技场排名
    struct req_arena_rank_t : public jcmd_t<5088>
    {
        JSON0(req_arena_rank_t);
    };
    struct ret_arena_rank_t : public jcmd_t<5089>
    {
        int32_t rank;
        JSON1(ret_arena_rank_t,rank);
    };

    //抽卡排行榜
    struct jpk_pub_node_t 
    {
        int32_t uid;
        string nickname;
        int32_t lv;
        int32_t fp;
        int32_t vip;
        int32_t count;
        JSON6(jpk_pub_node_t,uid,nickname,lv,fp,vip,count);
    };
    struct req_pub_rank_t : public jcmd_t<9010>
    {
        JSON0(req_pub_rank_t);
    };
    struct ret_pub_rank_t : public jcmd_t<9011>
    {
        vector<jpk_pub_node_t> users;
        JSON1(ret_pub_rank_t,users);
    };

    struct nt_limit_pub_t : public jcmd_t<9012>
    {
        int32_t now;
        JSON1(nt_limit_pub_t,now);
    };

    struct nt_openyb_change_t : public jcmd_t<9013>
    {
        int32_t totalyb;
        string openybreward;
        JSON2(nt_openyb_change_t, totalyb, openybreward);
    };
    
    struct ret_openyb_reward_t :public jcmd_t<9015>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_openyb_reward_t, pos, code);
    };

    //使用道具
    struct req_use_item_t : public jcmd_t<5100>
    {
        int resid;
        int num;
        string param;
        JSON3(req_use_item_t, resid, num, param)
    };

    //返回使用道具的结果
    struct ret_use_item_t : public jcmd_t<5101>
    {
        int code;
        int resid;
        int num;
        int value;
        //返回的道具
        vector<jpk_item_t> items;
        JSON5(ret_use_item_t, code, resid, num, value, items);
    };

    struct ret_use_item_failed_t : public jcmd_t<5101>
    {
        int code;
        JSON1(ret_use_item_failed_t, code)
    };

    //请求月卡信息
    struct req_mcard_info_t : public jcmd_t<5110>
    {
        JSON0(req_mcard_info_t)
    };
    struct ret_mcard_info_t : public jcmd_t<5111>
    {
        //今天是否可以领取
        int todayn;;
        //剩余的可领取天数
        int mcardn;
        JSON2(ret_mcard_info_t, todayn, mcardn)
    };

    //请求领取月卡奖励
    struct req_mcard_reward_t : public jcmd_t<5112>
    {
        JSON0(req_mcard_reward_t)
    };
    struct ret_mcard_reward_t : public jcmd_t<5113>
    {
        int code;
        JSON1(ret_mcard_reward_t, code)
    };

    //通知月卡信息改变
    struct nt_mcard_info_t : public jcmd_t<5114>
    {
        //今天是否可以领取
        int todayn;
        //剩余的可领取天数
        int mcardn;
        JSON2(nt_mcard_info_t, todayn, mcardn)
    };

    //英雄系统
    //雇佣伙伴
    struct req_hire_partner_t : public jcmd_t<5200>
    {
        int32_t resid;
        JSON1(req_hire_partner_t, resid);
    };
    struct ret_hire_partner_t : public jcmd_t<5201>
    {
        jpk_role_data_t partner;
        JSON1(ret_hire_partner_t, partner);
    };
    struct ret_hire_partner_failed_t : public jcmd_t<5201>
    {
        int32_t code;
        JSON1(ret_hire_partner_failed_t, code);
    };
    //解雇伙伴
    struct req_fire_partner_t : public jcmd_t<4116>
    {
        int32_t pid;
        JSON1(req_fire_partner_t, pid);
    };
    struct ret_fire_partner_t : public jcmd_t<4117>
    {
        int32_t code;
        int32_t pid;
        JSON2(ret_fire_partner_t, code, pid);
    };
    //请求伙伴或者主角升阶
    struct req_quality_up_t : public jcmd_t<4043>
    {
        //pid:0 主角升阶
        //pid >0 伙伴升阶
        int32_t pid;
        JSON1(req_quality_up_t, pid);
    };
    struct ret_quality_up_t : public jcmd_t<4044>
    {
        //0成功，其他都不成功
        uint16_t code;
        int32_t pid;
        JSON2(ret_quality_up_t, code, pid);
    };

    struct nt_skill_open_t : public jcmd_t<4045>
    {
        int32_t pid;
        int32_t skillid;
        JSON2(nt_skill_open_t, pid, skillid);
    };
    //碎片兑换灵能
    struct req_chip_to_soul_t : public jcmd_t<5202>
    {
        vector<jpk_chip_t> chips;
        JSON1(req_chip_to_soul_t, chips);
    };
    struct ret_chip_to_soul_t : public jcmd_t<5203>
    {
        int32_t code;
        int32_t soul;
        JSON2(ret_chip_to_soul_t, code, soul);
    };

    
    //英雄迷窟
    //请求进入英雄迷窟
    struct req_cave_enter_t : public jcmd_t<5220>
    {
        int32_t resid;
        int32_t uid;
        int32_t pid;
        JSON3(req_cave_enter_t,resid,uid,pid);
    };
    struct ret_cave_enter_t : public jcmd_t<5221>
    {
        int32_t resid;
        vector<jpk_item_t> drop_items;
        int32_t exp;
        int32_t coin;
        int32_t soul;
        jpk_view_role_data_t hhero;
        JSON6(ret_cave_enter_t,resid,drop_items,exp,coin,soul,hhero);
    };
    struct ret_cave_enter_failed_t : public jcmd_t<5221>
    {
        int32_t resid;
        uint16_t code;
        JSON2(ret_cave_enter_failed_t,resid,code);
    };
    //结束英雄迷窟
    struct req_cave_exit_t : public jcmd_t<5222>
    {
        int32_t resid;
        bool win;
        int32_t stars;
        vector<jpk_round_monster_t> killed;
        JSON4(req_cave_exit_t, resid, win, stars, killed)
    };
    struct ret_cave_exit_t : public jcmd_t<5223>
    {
        int32_t resid;
        bool win;
        int32_t stars;
        JSON3(ret_cave_exit_t,resid,win,stars);
    };
    //通知灵能改变
    struct nt_soul_change_t : public jcmd_t<5224>
    {
        //当前值
        int32_t now;
        JSON1(nt_soul_change_t, now) 
    };
    //英雄迷窟挂机
    struct req_cave_pass_t : public jcmd_t<5225>
    {
        int32_t resid;
        int32_t count;
        vector<jpk_round_monster_t> killed;
        JSON3(req_cave_pass_t,resid,count,killed);
    };
    struct jpk_pass_cave_result_t
    {
        int32_t exp;
        int32_t coin;
        int32_t soul;
        vector<jpk_item_t> drop_items;
        JSON4(jpk_pass_cave_result_t,exp,coin,soul,drop_items);
    };
    struct ret_cave_pass_t : public jcmd_t<5226>
    {
        int32_t resid;
        int32_t count;
        vector<jpk_pass_cave_result_t> results;
        int32_t left_secs;
        JSON4(ret_cave_pass_t,resid,count,results,left_secs);
    };
    struct ret_cave_pass_fail_t : public jcmd_t<5226>
    {
        int32_t resid;
        int32_t count;
        int32_t code;
        JSON3(ret_cave_pass_fail_t,resid,count,code);
    };
    //重置英雄迷窟次数
    struct req_cave_flush_t : public jcmd_t<5227>
    {
        int32_t resid;
        JSON1(req_cave_flush_t,resid);
    };
    struct ret_cave_flush_t : public jcmd_t<5228>
    {
        int32_t resid;
        int32_t code;
        JSON2(ret_cave_flush_t,resid,code);
    };
    //清除英雄迷窟挂机cd
    struct req_cave_pass_clear_cd_t : public jcmd_t<5229>
    {
        JSON0(req_cave_pass_clear_cd_t);
    };
    struct ret_cave_pass_clear_cd_t : public jcmd_t<5230>
    {
        int32_t code;
        JSON1(ret_cave_pass_clear_cd_t,code);
    };

    //通知声望改变
    struct nt_honor_change_t : public jcmd_t<5231>
    {
        //当前值
        int32_t now;
        JSON1(nt_honor_change_t, now)
    };

    //通知声望改变
    struct nt_unhonor_change_t : public jcmd_t<5209>
    {
        //当前值
        int32_t now;
        JSON1(nt_unhonor_change_t, now)
    };


    struct nt_meritorious_t : public jcmd_t<5353>
    {
        int32_t now;
        JSON1(nt_meritorious_t, now);
    };

    struct nt_titleup_t : public jcmd_t<5354>
    {
        int32_t now;
        JSON1(nt_titleup_t, now);
    };

    //通知首冲状态
    struct nt_first_pay_t : public jcmd_t<5232>
    {
        int32_t state;
        int32_t firstpay;
        JSON2(nt_first_pay_t, state, firstpay)
    };

    //道具购买
    struct req_item_buy_t : public jcmd_t<5233>
    {
        int resid;
        int num;
        JSON2(req_item_buy_t, resid, num)
    };
    struct ret_item_buy_t : public jcmd_t<5234>
    {
        int code;
        int resid;
        int num;
        JSON3(ret_item_buy_t,code, resid, num);
    };
    //领取累计消费奖励
    struct req_cumu_yb_reward_t : public jcmd_t<5235>
    {
        int32_t pos;
        JSON1(req_cumu_yb_reward_t,pos);
    };
    struct ret_cumu_yb_reward_t : public jcmd_t<5236>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_cumu_yb_reward_t,pos,code);
    };
    //领取当日充值奖励
    struct req_daily_pay_reward_t: public jcmd_t<5237>
    {
        int32_t pos;
        JSON1(req_daily_pay_reward_t,pos);
    };
    struct ret_daily_pay_reward_t: public jcmd_t<5238>
    {
        int32_t pos;
        int32_t code;
        JSON2(ret_daily_pay_reward_t,pos,code);
    };

    //通知当天充值额度
    struct nt_daily_pay_t : public jcmd_t<5239>
    {
        //当次充值
        int rmb;
        //当前充值总额
        int total;
        JSON2(nt_daily_pay_t, rmb, total)
    };

    //通知竞技场战历获得
    struct nt_arena_battlexp_t : public jcmd_t<5240>
    {
        int rank;
        int btp;
        JSON2(nt_arena_battlexp_t, rank, btp)
    };

    struct jpk_gmail_t
    {
        int     id;
        int     flag; //1-奖励邮件，2-客户邮件
        int     resid;//邮件id
        string  title;
        string  sender;
        string  content;
        int     readed;
        int     rewarded;
        uint32_t stamp;
        int     validtime;
        string  date;
        vector<jpk_item_t> reward_items;
        JSON11(jpk_gmail_t, id, flag, title, sender, content, reward_items, readed, rewarded, stamp, date, validtime)
    };

    //请求邮件列表
    struct req_gmail_list_t : public jcmd_t<5241>
    {
        JSON0(req_gmail_list_t)
    };

    struct ret_gmail_list_t : public jcmd_t<5242>
    {
        vector<jpk_gmail_t> mails;
        JSON1(ret_gmail_list_t, mails)
    };

    //请求领取邮件奖励
    struct req_gmail_reward_t : public jcmd_t<5243>
    {
        int id;
        JSON1(req_gmail_reward_t,id)
    };

    struct ret_gmail_reward_t : public jcmd_t<5244>
    {
        int id;
        int code;
        JSON2(ret_gmail_reward_t, id, code)
    };

    //客户端通知邮件已读
    struct nt_gmail_readed_t : public jcmd_t<5245>
    {
        int id;
        JSON1(nt_gmail_readed_t, id)
    };

    //通知新邮件到达
    struct nt_new_gmail_t: public jcmd_t<5246>
    {
        jpk_gmail_t mail;
        JSON1(nt_new_gmail_t, mail)
    };

    //请求删除邮件
    struct req_gmail_delete_t: public jcmd_t<5271>
    {
        int id;
        JSON1(req_gmail_delete_t, id);
    };

    //删除邮件结果返回
    struct ret_gmail_delete_t: public jcmd_t<5272>
    {
        int id;
        int code;
        JSON2(ret_gmail_delete_t, id, code);
    };

    struct req_gmail_getallreward_t: public jcmd_t<5273>
    {
        JSON0(req_gmail_getallreward_t);  
    };

    struct ret_gmail_getallreward_t: public jcmd_t<5274>
    {
        vector<int32_t> id;
        int code;
        JSON2(ret_gmail_getallreward_t, id, code);
    };
    //删除所有邮件
    struct nt_delete_gmail_t: public jcmd_t<5250>
    {
        int id; //0邮件全删除
        int flag;
        JSON2(nt_delete_gmail_t, id, flag)
    };

    //水晶累计消费排名项
    struct jpk_cumu_yb_rank_t 
    {
        int uid;
        string nickname;
        int grade;
        int yb;
        JSON4(jpk_cumu_yb_rank_t, uid, nickname, grade, yb)
    };

    //请求累计消费排行榜
    struct req_cumu_yb_rank_t : public jcmd_t<5247>
    {
        JSON0(req_cumu_yb_rank_t)
    };

    //返回累计消费排行榜
    struct ret_cumu_yb_rank_t : public jcmd_t<5248>
    {
        vector<jpk_cumu_yb_rank_t> ranks;
        JSON1(ret_cumu_yb_rank_t, ranks)
    };

    //通知年卡
    struct nt_mcard_event_t : public jcmd_t<5249>
    {
        //年卡状态
        int state;
        //活动月卡购买次数
        int count;
        JSON2(nt_mcard_event_t, state, count)
    };

    //请求请求活跃度任务
    struct req_act_task_t : public jcmd_t<5300>
    {
        JSON0(req_act_task_t)
    };

    struct jpk_daily_task_t
    {
        int resid;
        int collect;
        int step;
        JSON3(jpk_daily_task_t, resid, collect, step)
    };

    struct ret_act_task_t : public jcmd_t<5301>
    {
        vector<jpk_daily_task_t> tasks;
        JSON1(ret_act_task_t, tasks)
    };
    
    //请求请求活跃度任务
    struct req_achievement_task_t : public jcmd_t<5410>
    {
        JSON0(req_achievement_task_t);
    };

    struct jpk_achievement_t
    {
        int resid;
        int tasktype;
        int systype;
        int collect;
        int step;
        JSON5(jpk_achievement_t, resid, collect, step, tasktype, systype)
    };

    struct ret_achievement_t : public jcmd_t<5411>
    {
        vector<jpk_achievement_t> tasks;
        JSON1(ret_achievement_t, tasks)
    };

    //请求活跃度奖励
    struct req_act_reward_t : public jcmd_t<5302>
    {
        //奖励id
        int resid;
        JSON1(req_act_reward_t, resid)
    };

    struct ret_act_reward_t : public jcmd_t<5303>
    {
        //奖励id
        int resid;
        int code;
        JSON2(ret_act_reward_t, resid, code)
    };
    
    //请求成就任务奖励
    struct req_achievement_reward_t :public jcmd_t<5412>
    {
        //奖励id
        int resid;
        int systype;
        JSON2(req_achievement_reward_t, resid, systype);
    };

    struct ret_achievement_reward_t :public jcmd_t<5413>
    {
        //奖励id;
        int resid;
        int systype;
        int code;
        JSON3(ret_achievement_reward_t, resid, code, systype);  
    };
    //通知twoprecrod
    struct nt_twoprecrod_t : public jcmd_t<5304>
    {
        //某个操作完成,oprecord | (1<<op_done)
        int op_done;
        JSON1(nt_twoprecrod_t, op_done)
    };

    //通知活跃度改变
    struct nt_act_changed_t : public jcmd_t<5305>
    {
        int resid;
        int step;
        JSON2(nt_act_changed_t, resid, step)
    };

    //通知活跃度改变
    struct nt_achievement_t : public jcmd_t<5414>
    {
        int resid;
        int step;
        JSON2(nt_achievement_t, resid, step)
    };

    //请求领红包
    struct req_hongbao_t: public jcmd_t<5306>
    {
        //红包id
        uint64_t id;
        JSON1(req_hongbao_t, id)
    };
    //返回红包
    struct ret_hongbao_t: public jcmd_t<5307>
    {
        //领取红包的用户id
        int uid;
        //0领取成功
        int code;
        //红包id
        uint64_t id;
        //红包剩余可领次数
        int count;
        //领取的水晶
        int yb;
        //发红包的人的名字
        string nickname;
        //等级
        int level; 
        JSON7(ret_hongbao_t, uid, code, id, count, yb, nickname, level)
    };

    //通知发红包了
    struct nt_hongbao_t : public jcmd_t<5308>
    {
        vector<jpk_hongbao_t> hongbao;
        JSON1(nt_hongbao_t, hongbao)
    };

    //请求打限时副本
    struct req_limit_round_t : public jcmd_t<5320>
    {
        //限时副本的关卡id
        int roundid;
        vector<int> partners;
        JSON2(req_limit_round_t, roundid, partners);
    };

    //返回限时副本参数
    struct ret_limit_round_t : public jcmd_t<5321>
    {
        //限时副本的结果
        int code;
        int roundid;
        int coin;          // 奖励金币
        int num;           // 剩余次数
        int lovevalue;       //奖励爱恋度
        int exp;
        vector<jpk_item_t> drop_items;
        string salt;
        JSON8(ret_limit_round_t, code, roundid, coin, num, exp, lovevalue, drop_items, salt);
    };

    //请求退出限时副本，发放奖励
    struct req_limit_quit_t : public jcmd_t<5322>
    {
        //打限时副本的结果
        int result;
        int roundid;
        string salt;
        JSON3(req_limit_quit_t, result, roundid, salt);
    };

    //请求返回限时副本
    struct ret_limit_quit_t : public jcmd_t<5323>
    {
       //限时副本奖励
       int code;
       int roundid;
       int cool_down;     // 冷却时间
       JSON3(ret_limit_quit_t, code, roundid, cool_down);
    };
    struct req_limit_round_data : public jcmd_t<5324>
    {
        JSON0(req_limit_round_data);   
    };
    struct ret_limit_round_data : public jcmd_t<5325>   
    {
        int code;
        jpk_round_data_t        round;
        JSON2(ret_limit_round_data,code,round);   
    };
    struct req_reset_limit_round_times : public jcmd_t<5326>
    {
        JSON0(req_reset_limit_round_times);
    };
    struct ret_reset_limit_round_times : public jcmd_t<5327>
    {
        int code;
        jpk_round_data_t round;
        JSON2(ret_reset_limit_round_times,code,round);
    };

    struct req_guwu_t : public jcmd_t<5330>
    {
        //模块类型 1:世界boss,2:公会boss,3:乱斗场
        int flag;
        int yb;
        int coin;
        JSON3(req_guwu_t, flag, yb, coin)
    };

    struct ret_guwu_t : public jcmd_t<5331>
    {
        int flag;
        int code;
        float v;
        uint32_t progress;
        uint32_t stamp_yb;
        uint32_t stamp_coin;
        JSON6(ret_guwu_t, code, v, flag, progress, stamp_yb, stamp_coin)
    };

    struct req_fuhuo_t : public jcmd_t<5332>
    {
        JSON0(req_fuhuo_t)
    };

    struct ret_fuhuo_t : public jcmd_t<5333>
    {
        int code;
        float v;
        JSON2(ret_fuhuo_t, code, v);
    };

    struct req_zodiacid_t : public jcmd_t<5334>
    {
        JSON0(req_zodiacid_t);
    };
    struct ret_zodiacid_t : public jcmd_t<5335>
    {
        int id;
        JSON1(ret_zodiacid_t, id);
    };

    struct req_wear_wing_t : public jcmd_t<5340>
    {
        int wid;
        int resid;
        int32_t flag; //0:off, 1:on
        JSON3(req_wear_wing_t, wid, resid, flag)
    };
    struct ret_wear_wing_t : public jcmd_t<5341>
    {
        int code;
        int wid;
        int resid;
        int32_t flag; //0:off, 1:on
        JSON4(ret_wear_wing_t, code, wid, resid, flag)
    };

    struct req_compose_wing_t : public jcmd_t<5342>
    {
        int wid;
        int flag; //0:compose, 1:split
        JSON2(req_compose_wing_t, wid, flag)
    };
    struct ret_compose_wing_t : public jcmd_t<5343>
    {
        int code;
        int wid;
        int resid;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        int flag; //0:compose, 1:split
        JSON9(ret_compose_wing_t, code, wid, resid, atk, mgc, def, res, hp, flag)
    };

    struct jpk_gacha_res_t
    {
        int pos;
        int res_id;
        int res_num;
        JSON3(jpk_gacha_res_t, pos, res_id, res_num);
    };

    struct req_gacha_wing_t : public jcmd_t<5344>
    {
        int num;
        JSON1(req_gacha_wing_t, num);
    };

    struct ret_gacha_wing_t : public jcmd_t<5345>
    {
        int code;
        vector<jpk_gacha_res_t> gacha_res;
        JSON2(ret_gacha_wing_t, code, gacha_res);
    };

    struct req_get_wing_t : public jcmd_t<5346>
    {
        JSON0(req_get_wing_t);
    };

    struct ret_get_wing_t : public jcmd_t<5347>
    {
        int code;
        JSON1(ret_get_wing_t, code);
    };

    struct jpk_wing_rank_t
    {
        int uid;
        int score;
        string nickname;
        int grade;
        JSON4(jpk_wing_rank_t, uid, score, nickname, grade);
    };

    struct req_wing_rank_t : public jcmd_t<5348>
    {
        JSON0(req_wing_rank_t);
    };

    struct ret_wing_rank_t : public jcmd_t<5349>
    {
        int32_t con_wing;					//是否领取过翅膀
        int32_t con_wing_score;				//翅膀活动积分
        vector<jpk_wing_rank_t> wing_rank;
        JSON3(ret_wing_rank_t, con_wing, con_wing_score, wing_rank);
    };

    struct req_sell_wing_t : public jcmd_t<5350>
    {
        int wid;
        JSON1(req_sell_wing_t, wid)
    };

    struct ret_sell_wing_t : public jcmd_t<5351>
    {
        int code;
        JSON1(ret_sell_wing_t, code)
    };

    //编年史系统
    //请求编年史信息
    struct req_chronicle_t : public jcmd_t<5252>
    {
        uint32_t chronicle_id;
        JSON1(req_chronicle_t, chronicle_id);
    };

    //编年史信息
    struct jpk_chronicle_t
    {
        uint32_t id;
        string name;
        string background;
        vector<int32_t> source_ids;
        vector<int32_t> source_condition;
        JSON5(jpk_chronicle_t, id, name, background, source_ids, source_condition)
    };

    //编年史月信息
    struct jpk_chronicle_story_t
    {
        uint32_t id;
        uint32_t day;
        string pre_story;
        string finish_story;
        int32_t plot_id;
        vector<vector<int32_t>> item_ids;
        JSON6(jpk_chronicle_story_t, id, day, pre_story, finish_story, plot_id, item_ids)
    };

    //用户编年史进度信息
    struct jpk_chronicle_progress_t
    {
        uint32_t chronicle_story_id;
        int32_t step;
        int32_t state;
        JSON3(jpk_chronicle_progress_t, chronicle_story_id, step, state)
    };

    //返回编年史信息
    struct ret_chronicle_t : public jcmd_t<5253>
    {
        jpk_chronicle_t chronicle_month;
        vector<jpk_chronicle_story_t> chronicle_day;
        vector<jpk_chronicle_progress_t> chronicle_progress;
        JSON3(ret_chronicle_t, chronicle_month, chronicle_day, chronicle_progress)
    };

    //请求完成当日编年史任务
    struct req_chronicle_sign_t : public jcmd_t<5254>
    {
        uint32_t year_month_day;
        JSON1(req_chronicle_sign_t, year_month_day)
    };

    //返回完成当日编年史任务
    struct ret_chronicle_sign_t : public jcmd_t<5255>
    {
        uint32_t chronicle_story_id;
        int32_t step;
        int32_t state;
        JSON3(ret_chronicle_sign_t, chronicle_story_id, step, state)
    };

    //通知编年史签到总天数变化
    struct nt_chronicle_sum_change_t : public jcmd_t<5256>
    {
        //当前值
        int32_t now;
        JSON1(nt_chronicle_sum_change_t, now) 
    };

    //请求编年史剧情找回
    struct req_chronicle_sign_retrieve_t : public jcmd_t<5257>
    {
        JSON0(req_chronicle_sign_retrieve_t)
    };

    //返回编年史剧情找回结果
    struct ret_chronicle_sign_retrieve_t : public jcmd_t<5258>
    {
        // -1 扣费失败，余额不足
        // 0 扣费成功
        int32_t state;
        vector<jpk_chronicle_progress_t> chronicle_progress;
        JSON2(ret_chronicle_sign_retrieve_t, chronicle_progress, state)
    };

    //请求所有编年史签到信息
    struct req_chronicle_sign_all_t : public jcmd_t<5259>
    {
        JSON0(req_chronicle_sign_all_t)
    };

    //返回编年史所有签到记录
    struct ret_chronicle_sign_all_t : public jcmd_t<5260>
    {
        map<int32_t, uint32_t> record;
        JSON1(ret_chronicle_sign_all_t, record)
    };

    struct jpk_love_task_t
    {
        int32_t pid;
        //role_id*100 + lovelevel
        int32_t ltid;
        //收集任务,step:为收集到的道具总数
        //通关任务,step:通关次数
        //打怪任务,step:消灭怪物总数 
        int step;
        int state;
        JSON4(jpk_love_task_t, pid, ltid, step, state)
    };

    //请求所有卡牌爱恋度任务
    struct req_love_task_list_t : public jcmd_t<5261>
    {
        JSON0(req_love_task_list_t)
    };

    //返回所有卡牌爱恋度任务
    struct ret_love_task_list_t : public jcmd_t<5262>
    {
        vector<jpk_love_task_t> love_task;
        JSON1(ret_love_task_list_t, love_task)
    };

    //请求完成爱恋度任务
    struct req_commit_love_task_t : public jcmd_t<5263>
    {
        //int32_t pid;
        //int32_t rid;
        int32_t resid;
        JSON1(req_commit_love_task_t, resid)
    };

    //返回完成的爱恋度任务并自动开启下一任务
    struct ret_commit_love_task_t : public jcmd_t<5264>
    {
        int code;
        int32_t resid;
        jpk_love_task_t love_task;
        JSON3(ret_commit_love_task_t, code, resid, love_task)
    };

    //通知爱恋度任务进度变化
    struct nt_love_task_change_t : public jcmd_t<5265>
    {
        jpk_love_task_t love_task;
        JSON1(nt_love_task_change_t, love_task)
    };

    //通知爱恋度等级提升
    struct nt_lovelevelup_t : public jcmd_t<5266>
    {
        int pid;
        int lovelevel; //当前等级
        JSON2(nt_lovelevelup_t, pid, lovelevel)
    };

    //请求领取每日签到奖励
    struct req_sign_reward_t: public jcmd_t<5310>
    {
        int id;
        JSON1(req_sign_reward_t, id)
    };

    struct ret_sign_reward_t: public jcmd_t<5311>
    {
        int id;
        int code;
        JSON2(ret_sign_reward_t, id, code)
    };

    //请求每日签到相关信息
    struct req_sign_daily_t : public jcmd_t<5312>
    {
        JSON0(req_sign_daily_t)
    };
     
    struct ret_sign_daily_t : public jcmd_t<5313>
    {
        uint32_t sign_daily;
        int     cost;
        int32_t cur_day;
        int32_t cur_month;
        JSON4(ret_sign_daily_t, sign_daily, cost, cur_day, cur_month)
    };

    //请求补签
    struct req_sign_remedy_t : public jcmd_t<5314>
    { 
        int signid;
        JSON1(req_sign_remedy_t, signid) 
    };

    struct ret_sign_remedy_t : public jcmd_t<5315>
    {
        int id;
        int code;
        int cost;
        JSON3(ret_sign_remedy_t, id, code, cost)
    };

    struct req_prestige_shop_items_t : public jcmd_t<5355>
    {
        int index;
        JSON1(req_prestige_shop_items_t, index);
    };

    struct prestige_item_t
    {
        int id;
        int item_id;
        int count;
        int price;
        bool isnew;
        int limited;
        int buy_num;
        string name;
        JSON8(prestige_item_t, id, item_id, count, price, isnew, limited, buy_num, name)
    };

    struct ret_prestige_shop_items_t : public jcmd_t<5356>
    {
        int index;
        vector<prestige_item_t> items;
        JSON2(ret_prestige_shop_items_t, index, items)
    };

    struct req_prestige_shop_buy_t : public jcmd_t<5357>
    {
        int id;
        int num;
        int shopindex;
        JSON3(req_prestige_shop_buy_t, id, num, shopindex)
    };

    struct ret_prestige_shop_buy_t : public jcmd_t<5358>
    {
        int code;
        int id;
        int item_id;
        int num;
        JSON4(ret_prestige_shop_buy_t, code, id, item_id, num)
    };

    struct req_chip_shop_items_t : public jcmd_t<6801>
    {
        int page;
        JSON1(req_chip_shop_items_t, page);
    };

    struct chip_item_t
    {
        int id;
        int item_id;
        int count;
        int price;
        bool isnew;
        int limited;
        int buy_num;
        int trend;
        string name;
        JSON9(chip_item_t, id, item_id, count, price, isnew, limited, buy_num,trend, name)
    };

    struct ret_chip_shop_items_t : public jcmd_t<6802>
    {
        int page;
        vector<chip_item_t> items;
        JSON2(ret_chip_shop_items_t, page, items)
    };

    struct req_chip_shop_buy_t : public jcmd_t<6803>
    {
        int id;
        int num;
        JSON2(req_chip_shop_buy_t, id, num)
    };

    struct ret_chip_shop_buy_t : public jcmd_t<6804>
    {
        int code;
        int id;
        int item_id;
        int num;
        JSON4(ret_chip_shop_buy_t, code, id, item_id, num)
    };

    struct chip_smash_item_t
    {
        int item_id;
        string name;
        int price;
        int value;
        int limited;
        int buy_num;
        int chipnum;
        int trend;
        JSON8(chip_smash_item_t, item_id, name, price, value, limited, buy_num,chipnum, trend)
    };
    struct ret_chip_smash_items_t :  public jcmd_t <6805>
    {
        vector<chip_smash_item_t> items;
        JSON1(ret_chip_smash_items_t, items)
    };

    struct req_chip_smash_items_t : public jcmd_t<6806>
    {
        JSON0(req_chip_smash_items_t);
    };

    struct req_chip_smash_buy_t : public jcmd_t<6807>
    {
        int id;
        int num;
        JSON2(req_chip_smash_buy_t, id, num);
    };

    struct ret_chip_smash_buy_t : public jcmd_t<6808>
    {
        int code;
        int id;
        int num;
        JSON3(ret_chip_smash_buy_t, code, id, num);
    };

    struct nt_chip_value_changed_t : public jcmd_t<6809>
    {
        int id;
        int price;
        int buyprice;
        int trend;
        JSON4(nt_chip_value_changed_t,id,price,buyprice,trend);
    };

    struct req_expedition_t : public jcmd_t<5359>
    {
        JSON0(req_expedition_t)
    };

    struct jpk_expedition_t
    {
        int32_t resid;
        int32_t box;
        JSON2(jpk_expedition_t,resid,box)
    };

    struct ret_expedition_t : public jcmd_t<5360>
    {
        int32_t code;
        int32_t reset_times;
        int32_t cur_max_round;
        int32_t last_max_round;
        bool can_sweep;
        vector<jpk_expedition_t> round;
        JSON6(ret_expedition_t,code,reset_times,cur_max_round,last_max_round,can_sweep,round)
    };

    struct req_expedition_round_t : public jcmd_t<5377>
    {
        JSON0(req_expedition_round_t)
    };

    struct jpk_expedition_enemy_t
    {
        int resid;
        float hp;
        int level;
        int lovelevel;
        int equiplv;        //  最低装备等级
        int starnum;
        JSON6(jpk_expedition_enemy_t, resid, hp, level, lovelevel, equiplv, starnum)
    };
    
    //用于存放远征敌人的主角信息
    struct jpk_expedition_enemy_role_t
    {
        int uid;
        int viplv;      // vip等级
        int rank;      // 属性值
        string nickname;
        string unionname;
        int fp;
        int level;
        JSON6(jpk_expedition_enemy_role_t, viplv, rank, nickname, unionname, fp, level)
    };

    struct ret_expedition_round_t : public jcmd_t<5378>
    {
        int32_t code;
        vector<jpk_expedition_enemy_role_t> info;
        vector<jpk_expedition_enemy_t> enemys;
        jpk_combo_pro_view_t combo_pro;
        JSON4(ret_expedition_round_t, code, enemys, info,combo_pro)
    };

    struct req_enter_expedition_round_t : public jcmd_t<5361>
    {
        int32_t resid;
        JSON1(req_enter_expedition_round_t, resid)
    };

    struct jpk_expedition_partner_t
    {
        int32_t pid;
        float hp;
        JSON2(jpk_expedition_partner_t, pid, hp)
    };

    struct ret_enter_expedition_round_t : public jcmd_t<5362>
    {
        int32_t code;
        int32_t resid;
        //serialized jpk_view_user_data_t
        string view_data;
        vector<jpk_expedition_partner_t> team;
        string salt;
        JSON5(ret_enter_expedition_round_t, code, resid, team, view_data, salt)
    };

    struct req_exit_expedition_round_t : public jcmd_t<5363>
    {
        int32_t is_win;
        int32_t anger;
        vector<jpk_expedition_partner_t> enemy;
        vector<jpk_expedition_partner_t> ally;
        string salt;
        JSON5(req_exit_expedition_round_t, is_win, anger, enemy, ally, salt)
    };

    struct ret_exit_expedition_round_t : public jcmd_t<5364>
    {
        int32_t code;
        JSON1(ret_exit_expedition_round_t, code)
    };
    
    struct req_expedition_team_t : public jcmd_t<5365>
    {
        JSON0(req_expedition_team_t)
    };

    struct jpk_expedition_team_t
    {
        int pid;
        float hp;
        JSON2(jpk_expedition_team_t, pid, hp)
    };

    struct ret_expedition_team_t : public jcmd_t<5366>
    {
        int32_t code;
        int32_t anger;
        vector<jpk_expedition_team_t> team;
        JSON3(ret_expedition_team_t, code, anger, team)
    };

    struct nt_expedition_team_change_t : public jcmd_t<5367>
    {
        int32_t anger;
        yarray_t<jpk_expedition_team_t, 5> team;
        JSON2(nt_expedition_team_change_t, anger, team)
    };

    struct nt_expeditioncoin_t :public jcmd_t<5368>
    {
        int32_t now;
        JSON1(nt_expeditioncoin_t, now)
    };

    struct req_expedition_round_reward_t : public jcmd_t<5369>
    {
        int32_t resid;
        JSON1(req_expedition_round_reward_t, resid)
    };

    struct jpk_expedition_reward_t
    {
        int32_t resid;
        int32_t num;
        JSON2(jpk_expedition_reward_t, resid, num)
    };

    struct ret_expedition_round_reward_t : public jcmd_t<5370>
    {
        int32_t code;
        int32_t resid;
        vector<jpk_expedition_reward_t> reward;
        JSON3(ret_expedition_round_reward_t, code, resid, reward)
    };

    struct req_expedition_partners_t : public jcmd_t<5371>
    {
        JSON0(req_expedition_partners_t)
    };

    struct ret_expedition_partners_t : public jcmd_t<5372>
    {
        int32_t code;
        vector<jpk_expedition_partner_t> partners;
        JSON2(ret_expedition_partners_t, code, partners)
    };

    struct req_expedition_reset_t : public jcmd_t<5379>
    {
        JSON0(req_expedition_reset_t)
    };

    struct ret_expedition_reset_t : public jcmd_t<5380>
    {
        int32_t code;
        JSON1(ret_expedition_reset_t, code)
    };

    // 远征商店
    struct req_expedition_shop_items_t : public jcmd_t<5381>
    {
        JSON0(req_expedition_shop_items_t)
    };

    struct jpk_expedition_shop_item_t
    {
        int id;
        int item_id;
        int count;
        string name;
        int money_type;
        int price;
        int limited;
        int buy_num; // 已经购买次数
        JSON8(jpk_expedition_shop_item_t,id,item_id,count,name,money_type,price,limited,buy_num)
    };

    struct ret_expedition_shop_items_t : public jcmd_t<5382>
    {
        int32_t code;
        vector<jpk_expedition_shop_item_t> items;
        JSON2(ret_expedition_shop_items_t, code, items)
    };

    struct req_expedition_shop_buy_t : public jcmd_t<5383>
    {
        int index;
        JSON1(req_expedition_shop_buy_t,index)
    };

    struct ret_expedition_shop_buy_t : public jcmd_t<5384>
    {
        int code;
        int index;
        JSON2(ret_expedition_shop_buy_t,code,index)
    };

    //通知客户端远征商店已刷新
    struct nt_expedition_shop_reset_t : public jcmd_t<5385>
    {
        JSON0(nt_expedition_shop_reset_t)
    };

    //navi点击计数增加请求
    struct req_naviClickNum_add_t : public jcmd_t<5386>
    {
        int naviId;
        JSON1(req_naviClickNum_add_t, naviId);
    };

    //navi点击计数增加回调
    struct ret_naviClickNum_add_t : public jcmd_t<5387>
    {
        int resid;
        int index;
        JSON2(ret_naviClickNum_add_t, resid, index);
    };

    //排行公会信息
    struct jpk_ganginfo_t 
    {
        int ggid;
        string name;
        string leadername;
        int grade;
        int allgm;
        JSON5(jpk_ganginfo_t, ggid, name, leadername, grade, allgm)
    };
   
    struct req_union_rank_t : public jcmd_t<5091>
    {
        JSON0(req_union_rank_t);
    };   
    
    struct ret_union_rank_t : public jcmd_t<5092>
    {
        vector<jpk_ganginfo_t> users;
        JSON1(ret_union_rank_t, users);
    };
    //卡牌排行榜信息
    struct jpk_card_rank_t
    {
        int uid;
        string nickname;
        int level;
        int fp;
        int starnum;
        int32_t vip;
        JSON6(jpk_card_rank_t, uid, nickname, level, fp, starnum,vip)
    };

    struct req_card_rank_t : public jcmd_t<5093>
    {
        JSON0(req_card_rank_t);
    };
    
    struct ret_card_rank_t : public jcmd_t<5094>
    {
        vector<jpk_card_rank_t> users;
        JSON1(ret_card_rank_t, users);
    };

    //请求送花
    struct req_send_flower_t : public jcmd_t<5402>
    {
        int32_t uid;
        string name;
        JSON2(req_send_flower_t, uid, name);
    };

    //送花返回
    struct ret_send_flower_t : public jcmd_t<5403>
    {
        int32_t code;
        JSON1(ret_send_flower_t, code);
    };

    //请求接受鲜花
    struct req_receive_flower_t : public jcmd_t<5404>
    {
        int32_t id;
        JSON1(req_receive_flower_t, id);
    };

    //请求接受所有鲜花
    struct req_receive_all_t : public jcmd_t<5405>
    {
        int32_t uid; //没用的属性只是为了凑数
        JSON1(req_receive_all_t, uid);
    };

    //接花返回
    struct ret_receive_flower_t : public jcmd_t<5406>
    {
        vector<int32_t> idList;
        int32_t code;
        JSON2(ret_receive_flower_t, idList, code);
    };

    struct flower_info_t
    {
        int32_t id;
        int32_t uid;
        string name;
        int32_t rest_time;
        int32_t life_time;
        int32_t headid;
        int32_t lv;
        JSON7(flower_info_t, id, uid, name, rest_time, life_time, headid, lv);
    };
    //请求鲜花列表
    struct req_flower_list_t : public jcmd_t<5407>
    {
        int32_t uid;
        JSON1(req_flower_list_t, uid);
    };
    //返回鲜花列表
    struct ret_flower_list_t : public jcmd_t<5408>
    {
        int32_t code;
        vector<flower_info_t> flowers;
        JSON2(ret_flower_list_t, code, flowers);
    };

    //通知玩家获得心
    struct nt_receieve_flower_t : public jcmd_t<5409>
    {
        int successed;
       JSON1(nt_receieve_flower_t, successed);
    };

    //通知移除队伍
    /*
    struct req_remove_team_t : public jcmd_t<5451>
    {
        int32_t tid;
        JSON1(req_remove_team_t, tid)
    };
    */

    //通知改变默认队伍
    struct req_change_default_team_t : public jcmd_t<5450>
    {
        int32_t tid;
        JSON1(req_change_default_team_t, tid);
    };

    //通知改变队伍名称
    struct nt_change_team_name : public jcmd_t<5452>
    {
        int32_t tid;
        string name;
        JSON2(nt_change_team_name, tid, name);
    };

    /* 卡牌活动：通知 */
    struct nt_card_event_t : public jcmd_t<5455>
    {
        string info;
        int status;
        JSON2(nt_card_event_t, info, status);
    };

    struct nt_card_event_coin_t : public jcmd_t<5464>
    {
        int32_t now;
        JSON1(nt_card_event_coin_t, now)
    };

    struct nt_card_event_score_t : public jcmd_t<5472>
    {
        int32_t now;
        int32_t goal_level;
        JSON2(nt_card_event_score_t, now, goal_level)
    };

    /* 道具掉落通知 */
    struct nt_card_event_drop_coin_t : public jcmd_t<5473>
    {
        int32_t resid; /* 固定死16001 */
        int32_t num;
        JSON2(nt_card_event_drop_coin_t, resid, num)
    };

    /* 卡牌活动：开启关卡 */
    struct req_card_event_open_round_t : public jcmd_t<5456>
    {
        int32_t resid;
        int32_t is_reset;
        JSON2(req_card_event_open_round_t, resid, is_reset)
    };

    struct ret_card_event_open_round_t : public jcmd_t<5457>
    {
        int32_t code;
        JSON1(ret_card_event_open_round_t, code)
    };

    /* 卡牌活动：战斗 */
    struct req_card_event_fight_t : public jcmd_t<5458>
    {
        int32_t resid;
        JSON1(req_card_event_fight_t, resid)
    };

    struct ret_card_event_fight_t : public jcmd_t<5459>
    {
        int32_t code;
        int32_t resid;
        string view_data;
        yarray_t<jpk_card_event_partner_t, 5> team;
        JSON4(ret_card_event_fight_t, code, resid, view_data, team)
    };

    /* 卡牌活动：战斗退出 */
    struct req_card_event_round_exit_t : public jcmd_t<5460>
    {
        int32_t is_win;
        int32_t anger;
        vector<jpk_card_event_partner_t> ally;
        vector<jpk_card_event_partner_t> enemy;
        JSON4(req_card_event_round_exit_t, is_win, anger, ally, enemy)
    };

    struct ret_card_event_round_exit_t: public jcmd_t<5461>
    {
        int32_t code;
        bool win;
        int32_t goal_level;
        int32_t max_round;
        JSON4(ret_card_event_round_exit_t, code, win, goal_level, max_round)
    };

    /* 卡牌活动：重置 */
    struct req_card_event_reset_t : public jcmd_t<5462>
    {
        JSON0(req_card_event_reset_t)
    };

    struct ret_card_event_reset_t : public jcmd_t<5463>
    {
        int32_t code;
        JSON1(ret_card_event_reset_t, code)
    };

    /* 卡牌活动：队伍 */
    struct nt_card_event_change_team_t : public jcmd_t<5465>
    {
        int32_t anger;
        yarray_t<jpk_card_event_partner_t, 5> team;
        JSON2(nt_card_event_change_team_t, anger, team)
    };

    struct jpk_card_event_enemy_role_t
    {
        int viplv;
        int rank; // 属性值
        string nickname;
        string unionname;
        int fp;
        int level;
        JSON6(jpk_card_event_enemy_role_t, viplv, rank, nickname, unionname,
              fp, level)
    };

    struct jpk_card_event_enemy_t
    {
        int resid;
        float hp;
        int level;
        int lovelevel;
        int equiplv;
        int starnum;
        JSON6(jpk_card_event_enemy_t, resid, hp, level, lovelevel, equiplv,
              starnum)
    };

    struct req_card_event_round_enemy_t : public jcmd_t<5466>
    {
        JSON0(req_card_event_round_enemy_t)
    };

    struct ret_card_event_round_enemy_t : public jcmd_t<5467>
    {
        int32_t code;
        jpk_card_event_enemy_role_t role;
        vector<jpk_card_event_enemy_t> enemys;
        jpk_combo_pro_view_t combo_pro;
        JSON4(ret_card_event_round_enemy_t, code, role, enemys,combo_pro)
    };

    /* 卡牌活动：复活伙伴 */
    struct req_card_event_revive_t : public jcmd_t<5468>
    {
        int32_t pid;
        JSON1(req_card_event_revive_t, pid)
    };

    struct ret_card_event_revive_t : public jcmd_t<5469>
    {
        int32_t code;
        int32_t pid;
        JSON2(ret_card_event_revive_t, code, pid)
    };

    /* 卡牌活动：排行榜 */
    struct jpk_card_event_rank_t
    {
        int uid;
        string nickname;
        int level;
        int fp;
        int score;
        int32_t vip;
        JSON6(jpk_card_event_rank_t, uid, nickname, level, fp, score,vip)
    };

    struct req_card_event_rank_t : public jcmd_t<5470>
    {
        JSON0(req_card_event_rank_t)
    };

    struct ret_card_event_rank_t : public jcmd_t<5471>
    {
        int32_t rank; /* 我的排行 */
        vector<jpk_card_event_rank_t> users;
        JSON2(ret_card_event_rank_t, rank, users)
    };
    struct req_card_event_sweep_t : public jcmd_t<5480>
    {
        JSON0(req_card_event_sweep_t)
    };

    struct ret_card_event_sweep_t : public jcmd_t<5481>
    {
        int32_t code;
        int32_t start_round;
        int32_t end_round;
        int32_t score;
        JSON4(ret_card_event_sweep_t,code,start_round,end_round,score)
    };
    struct req_next_card_event_t : public jcmd_t<5482>
    {
        JSON0(req_next_card_event_t)
    };
    struct ret_next_card_event_t : public jcmd_t<5483>
    {
        int32_t code;
        int32_t max_round;
        int32_t goal_level;
        int32_t next_count;
        JSON4(ret_next_card_event_t,code,max_round,goal_level,next_count)
    };
    struct req_card_event_first_enter_t : public jcmd_t<5484>
    {
        JSON0(req_card_event_first_enter_t)
    };
    struct ret_card_event_first_enter : public jcmd_t<5485>
    {
        int32_t code;
        JSON1(ret_card_event_first_enter,code)
    };
    struct nt_card_event_change_state_t : public jcmd_t<5486>
    {
        int32_t state;
        JSON1(nt_card_event_change_state_t, state)
    };

    struct nt_card_event_get_reward_t : public jcmd_t<5487>
    {
        int32_t level;
        JSON1(nt_card_event_get_reward_t, level)
    };

    struct nt_card_event_get_level_t : public jcmd_t<5488>
    {
        int32_t level;
        JSON1(nt_card_event_get_level_t, level)
    };

    struct nt_card_event_open_t : public jcmd_t<7902>
    {
        int32_t open_times;
        int32_t open_level;
        int32_t next_count;
        JSON3(nt_card_event_open_t, open_times, open_level,next_count)
    };
    
    struct nt_wingactivity_changed_t : public jcmd_t<6600>
    {
        int32_t wingactivity;
        int32_t is_in_limit_activity;
        string limit_wing_reward;
        JSON3(nt_wingactivity_changed_t, wingactivity, is_in_limit_activity, limit_wing_reward)
    };

    struct nt_sevenpay_changed_t : public jcmd_t<6610>
    {
        string stage;
        JSON1(nt_sevenpay_changed_t,stage)
    };
    struct req_change_roletype_t : public jcmd_t<6601>
    {
        int32_t roletype;
        JSON1(req_change_roletype_t, roletype)
    };

    struct ret_change_roletype_t : public jcmd_t<6602>
    {
        int32_t code;
        JSON1(ret_change_roletype_t, code)
    };

    struct nt_limit_sevenpay_changed_t : public jcmd_t<6611>
    {
        string stage;
        JSON1(nt_limit_sevenpay_changed_t,stage)
    };

    struct req_rank_season_match_t : public jcmd_t<6650>
    {
        yarray_t<int32_t, 5> team;
        JSON1(req_rank_season_match_t, team)
    };

    struct nt_rank_match_fight_t : public jcmd_t<6651>
    {
        string view_data_self;
        string view_data;
        JSON2(nt_rank_match_fight_t, view_data, view_data_self)
    };

    struct req_rank_season_info_t : public jcmd_t<6652>
    {
        JSON0(req_rank_season_info_t)
    };

    struct ret_rank_season_info_t : public jcmd_t<6653>
    {
        uint16_t code;
        int32_t rank;
        int32_t score;
        int32_t season;
        int32_t lose_count;
        int32_t month;
        int32_t day;
        int32_t hour;
        JSON8(ret_rank_season_info_t, code, rank, score, season, lose_count, month, day, hour)
    };

    struct req_rank_seson_fight_end_t : public jcmd_t<6654>
    {
        bool is_win;
        JSON1(req_rank_seson_fight_end_t, is_win)
    };

    struct ret_rank_season_fight_end_t : public jcmd_t<6655>
    {
        uint16_t code;
        int32_t rank;
        int32_t score;
        int32_t lose_count;
        JSON4(ret_rank_season_fight_end_t, code, rank, score, lose_count)
    };

    struct req_cancel_rank_season_wait_t : public jcmd_t<6656>
    {
        JSON0(req_cancel_rank_season_wait_t)
    };

    struct req_begin_rank_match_fight_t : public jcmd_t<6657>
    {
        JSON0(req_begin_rank_match_fight_t)
    };
    struct ret_begin_rank_match_fight_t : public jcmd_t<6658>
    {
        int32_t code;
        JSON1(ret_begin_rank_match_fight_t, code)
    };

    struct req_get_soul_info_t : public jcmd_t<6700>
    {
        JSON0(req_get_soul_info_t)
    };

    struct ret_get_soul_info_t : public jcmd_t<6701>
    {
        int32_t code;
        int32_t soul_id;
        int32_t level;
        int32_t time;
        int32_t rare;
        int32_t state;
        int32_t gem_need;
        JSON7(ret_get_soul_info_t, code, soul_id, level,time, rare, state, gem_need)
    };

    struct req_hunt_soul_t : public jcmd_t<6702>
    {
        JSON0(req_hunt_soul_t)
    };

    struct ret_hunt_soul_t : public jcmd_t<6703>
    {
        int32_t code;
        int32_t soul_id;
        int32_t level;
        int32_t time;
        int32_t rare;
        int32_t state;
        int32_t gem_need;
        JSON7(ret_hunt_soul_t, code, soul_id, level,time, rare, state, gem_need)
    };

    struct req_rankup_soul_t : public jcmd_t<6704>
    {
        JSON0(req_rankup_soul_t)
    };

    struct ret_rankup_soul_t : public jcmd_t<6705>
    {
        int32_t code;
        int32_t state;
        int32_t soul_id;
        int32_t level;
        int32_t time;
        int32_t rare;
        int32_t gem_need;
        JSON7(ret_rankup_soul_t, code, state, soul_id, level,time, rare, gem_need)
    };

    struct req_get_soul_reward_t : public jcmd_t<6706>
    {
        JSON0(req_get_soul_reward_t)
    };

    struct ret_get_soul_reward_t : public jcmd_t<6707>
    {
        int32_t code;
        int32_t state;
        int32_t soul_id;
        int32_t level;
        int32_t time;
        int32_t rare;
        int32_t gem_need;
        JSON7(ret_get_soul_reward_t, code, state, soul_id, level,time, rare, gem_need)
    };

    struct nt_soulnode_coin_t : public jcmd_t<6603>
    {
        int32_t now;
        JSON1(nt_soulnode_coin_t, now)
    };

    struct nt_soulnode_info_t : public jcmd_t<6604>
    {
        int32_t soulranknum;
        int32_t soulid;
        map<int, sc_msg_def::jpk_soulnode_t> soul_node_info;
        JSON3(nt_soulnode_info_t, soulranknum, soulid, soul_node_info);
    };

    struct req_soulnode_open_t : public jcmd_t<6605>
    {
        int32_t soulid;
        JSON1(req_soulnode_open_t, soulid);
    };

    struct ret_soulnode_open_t : public jcmd_t<6606>
    {
        int32_t code;
        JSON1(ret_soulnode_open_t, code);
    };

    struct req_soulnode_pro_t : public jcmd_t<6607>
    {
        int32_t soulid;
        JSON1(req_soulnode_pro_t, soulid)
    };

    struct ret_soulnode_pro_t : public jcmd_t<6608>
    {
        map<int, sc_msg_def::jpk_soulnode_t> node_info;
        JSON1(ret_soulnode_pro_t, node_info);
    };

    // 公会战
    // 报名
    struct req_guild_battle_sign_up : public jcmd_t<6750>
    {
        JSON0(req_guild_battle_sign_up);
    };

    struct ret_guild_battle_sign_up : public jcmd_t<6751>
    {
        int32_t code;
        JSON1(ret_guild_battle_sign_up, code);
    };

    // 守方信息
    struct jpk_gbattle_target_t
    {
        int32_t uid;
        string  name; 
        int32_t fp;     //战斗力
        vector<jpk_arena_team_info_t> team_info;
        JSON4(jpk_gbattle_target_t, uid, name, fp, team_info)
    };

    // 布阵 布阵信息查看
    struct req_guild_battle_defence_info : public jcmd_t<6752>
    {
        int32_t building_id;
        JSON1(req_guild_battle_defence_info, building_id);
    };

    struct ret_guild_battle_defence_info : public jcmd_t<6753>
    {
        int32_t code;
        map<int, jpk_gbattle_target_t> defence_info;
        JSON2(ret_guild_battle_defence_info, code, defence_info)
    };
    
    // 布阵 上阵
    struct req_guild_battle_defence_pos_on : public jcmd_t<6754>
    {
        int32_t building_id;
        int32_t building_pos;
        vector<int32_t> team_info;
        int32_t fp;
        JSON4(req_guild_battle_defence_pos_on, building_id, building_pos, team_info, fp)
    };

    struct ret_guild_battle_defence_pos_on : public jcmd_t<6755>
    {
        int32_t code;
        JSON1(ret_guild_battle_defence_pos_on, code);
    };

    // 布阵 下阵
    struct req_guild_battle_defence_pos_off : public jcmd_t <6756>
    {
        int32_t building_id;
        int32_t building_pos;
        JSON2(req_guild_battle_defence_pos_off, building_id, building_pos)
    };

    struct ret_guild_battle_defence_pos_off : public jcmd_t<6757>
    {
        int32_t code;
        JSON1(ret_guild_battle_defence_pos_off, code);
    };
    
    // 布阵 让他人下阵
    struct req_guild_battle_cancel_other_pos : public jcmd_t<6758>
    {
        int32_t building_id;
        int32_t building_pos;
        JSON2(req_guild_battle_cancel_other_pos, building_id, building_pos)
    };

    struct ret_guild_battle_cancel_other_pos : public jcmd_t<6759>
    {
        int32_t code;
        JSON1(ret_guild_battle_cancel_other_pos, code);
    };

    // 战斗
    struct req_guild_battle_defence_info_fight : public jcmd_t<6760>
    {
        int32_t building_id;
        JSON1(req_guild_battle_defence_info_fight, building_id)
    };

    struct ret_guild_battle_defence_info_fight : public jcmd_t<6761>
    {
        int32_t code;
        map<int, jpk_gbattle_target_t> defence_info;
        map<int, int> defence_state;
        JSON3(ret_guild_battle_defence_info_fight, code, defence_info, defence_state)
    };

    struct req_guild_battle_fight : public jcmd_t<6762>
    {
        int32_t building_id;
        int32_t building_pos;
        vector<int32_t> partners;
        JSON3(req_guild_battle_fight, building_id, building_pos, partners)
    };

    struct ret_guild_battle_fight :public jcmd_t<6763>
    {
        int32_t code;
        int32_t anger;
        int32_t anger_enemy;
        string view_data;
        map<int32_t, float> partners;
        map<int32_t, jpk_card_event_partner_t> enemy_team;
        JSON6(ret_guild_battle_fight, code, anger, anger_enemy, view_data, partners, enemy_team)
    };

    struct jpk_guild_battle_partner_t
    {
        int32_t pid;
        float hp;
        JSON2(jpk_guild_battle_partner_t, pid, hp)
    };

    struct req_guild_battle_fight_end : public jcmd_t<6764>
    {
        bool is_win;
        int32_t anger;
        int32_t anger_enemy;
        vector<jpk_guild_battle_partner_t> partners;
        float hp1;
        float hp2;
        float hp3;
        float hp4;
        float hp5;
        JSON9(req_guild_battle_fight_end, is_win, anger, anger_enemy, partners, hp1, hp2, hp3, hp4, hp5);
    };

    struct ret_guild_battle_fight_end : public jcmd_t<6765>
    {
        int32_t code;
        int32_t cool_down;
        JSON2(ret_guild_battle_fight_end, code, cool_down)
    };

    struct nt_guild_boardcast_fight_state_switch : public jcmd_t<6766>
    {
        int32_t building_id;
        int32_t building_pos;
        int32_t new_state;
        JSON3(nt_guild_boardcast_fight_state_switch, building_id, building_pos, new_state)
    };

    //战报推送
    struct nt_guild_boardcast_fight_info : public jcmd_t<6767>
    {
        int32_t fight_side; //0 防守; 1 进攻
        int32_t win_count;
        string name;
        string name_enemy;
        JSON4(nt_guild_boardcast_fight_info, fight_side, win_count, name, name_enemy)
    };

    // 全部战报
    struct req_guild_battle_fight_record_info : public jcmd_t<6768>
    {
        JSON0(req_guild_battle_fight_record_info)
    };

    struct ret_guild_battle_fight_record_info : public jcmd_t<6769>
    {
        int32_t code;
        string name_mvp;
        string name_attacker;
        string name_defencer;
        vector<nt_guild_boardcast_fight_info> info_list;
        JSON5(ret_guild_battle_fight_record_info, code, name_mvp, name_attacker, name_defencer, info_list);
    };

    // 实时战绩查看
    struct req_guild_battle_fight_info : public jcmd_t<6770>
    {
        JSON0(req_guild_battle_fight_info)
    };

    // 战绩结构
    struct gfight_info_t
    {
        int32_t score;
        int32_t win_count;
        int32_t lose_count;
        bool is_mvp;
        bool is_top_attacker;
        bool is_top_defencer;
        int32_t viplevel;
        jpk_arena_team_info_t head_info;
        string name;
        int32_t fp;
        int32_t rest_times;
        JSON11(gfight_info_t, score, win_count, lose_count, is_mvp, is_top_attacker, is_top_defencer, viplevel, head_info, name, fp, rest_times)
    };

    // 挑战战报
    struct fight_info_self
    {
        int32_t fight_side; //0 防守; 1 进攻
        bool is_win;
        jpk_arena_team_info_t head_info;
        string name_enemy;
        int32_t viplevel;
        int32_t fp;
        JSON6(fight_info_self, fight_side, is_win, head_info, name_enemy, viplevel, fp)
    };
        
    struct ret_guild_battle_fight_info : public jcmd_t<6771>
    {
        int32_t code;
        // 自己的战绩
        vector<fight_info_self> self_info;
        // 我方战绩
        map<int32_t, gfight_info_t> guild_fight_info_list;
        // 敌方战绩
        map<int32_t, gfight_info_t> enemy_fight_info_list;
        string guild_name;
        int32_t score;
        string guild_name_enemy;
        int32_t score_enemy;
        JSON8(ret_guild_battle_fight_info, code, self_info, guild_fight_info_list, enemy_fight_info_list, guild_name, score, guild_name_enemy, score_enemy)
    };

    // 状态查看请求
    struct req_guild_battle_state : public jcmd_t<6772>
    {
        JSON0(req_guild_battle_state);
    };

    struct ret_guild_battle_state : public jcmd_t<6773>
    {
        int32_t code;
        int32_t guild_state;        // 0 未报名；1 已报名；
        int32_t gbattle_state;      // 0 不处于任何期间；1 报名期间；2 布阵期间；3 战斗期间
        JSON3(ret_guild_battle_state, code, guild_state, gbattle_state)
    };

    // 布阵期间全局状态查看
    struct req_guild_battle_whole_defence_info : public jcmd_t<6774>
    {
        JSON0(req_guild_battle_whole_defence_info);
    };

    struct ret_guild_battle_whole_defence_info : public jcmd_t<6775>
    {
        int32_t code;
        map<int32_t, int32_t> building_state;
        map<int32_t, int32_t> building_level;
        map<int32_t, jpk_team_t> self_team;
        string opponent_name;
        JSON5(ret_guild_battle_whole_defence_info, code, building_state, building_level, self_team, opponent_name)
    };

    // 战斗期间全局状态查看
    struct req_guild_battle_whole_defence_info_fight : public jcmd_t<6776>
    {
        JSON0(req_guild_battle_whole_defence_info_fight)
    };

    struct ret_guild_battle_whole_defence_info_fight : public jcmd_t<6777>
    {
        int32_t code;
        map<int32_t, int32_t> building_state;
        map<int32_t, int32_t> building_level;
        map<int32_t, float> partners;
        int32_t rest_times;
        int32_t have_buy_times;
        int32_t cool_down;
        int32_t score;
        JSON8(ret_guild_battle_whole_defence_info_fight, code, building_state, partners, building_level, rest_times, have_buy_times, cool_down, score)
    };

    struct req_guild_battle_building_level_up : public jcmd_t<6778>
    {
        int32_t building_id;
        int32_t old_level;
        JSON2(req_guild_battle_building_level_up, building_id, old_level)
    };

    struct ret_guild_battle_building_level_up : public jcmd_t<6779>
    {
        int32_t code;
        int32_t new_level;
        JSON2(ret_guild_battle_building_level_up, code, new_level)
    };

    struct req_guild_battle_buy_fight_times : public jcmd_t<6780>
    {
        JSON0(req_guild_battle_buy_fight_times)
    };

    struct ret_guild_battle_buy_fight_times : public jcmd_t<6781>
    {
        int32_t code;
        JSON1(ret_guild_battle_buy_fight_times, code)
    };

    struct req_guild_battle_clear_fight_cd : public jcmd_t<6782>
    {
        JSON0(req_guild_battle_clear_fight_cd)
    };

    struct ret_guild_battle_clear_fight_cd : public jcmd_t<6783>
    {
        int32_t code;
        JSON1(ret_guild_battle_clear_fight_cd, code)
    };

    struct req_guild_battle_spy : public jcmd_t<6784>
    {
        int32_t building_id;
        int32_t building_pos;
        JSON2(req_guild_battle_spy, building_id, building_pos)
    };

    struct ret_guild_battle_spy : public jcmd_t<6785>
    {
        int32_t code;
        JSON1(ret_guild_battle_spy, code)
    };

    struct req_guild_battle_guild_info : public jcmd_t<6786>
    {
        JSON0(req_guild_battle_guild_info)
    };

    struct guild_info
    {
        string guild_name;
        int32_t win;
        int32_t lose;
        int32_t score;
        JSON4(guild_info, guild_name, win, lose, score)
    };

    struct ret_guild_battle_guild_info : public jcmd_t<6787>
    {
        int32_t code;
        map<int32_t, guild_info> guild_info_list;
        int32_t cur_turn;
        JSON3(ret_guild_battle_guild_info, code, guild_info_list, cur_turn) 
    };

    struct req_bullet_t : public jcmd_t<11001>
    {
        int round;
        JSON1(req_bullet_t, round)
    };

    struct bullet_t 
    {
        int    pos;
        int    stamp;
        string msg;
        JSON3(bullet_t, pos, stamp, msg)
    };

    struct ret_bullet_t : public jcmd_t<11002>
    {
        vector<bullet_t> bullets;
        JSON1(ret_bullet_t, bullets)
    };

    struct req_send_bullet_t : public jcmd_t<11003>
    {
        string msg;
        int pos;
        int round;
        JSON3(req_send_bullet_t, msg, pos, round)
    };

    struct ret_send_bullet_t : public jcmd_t<11004>
    {
        bool ok;
        JSON1(ret_send_bullet_t, ok)
    };

    struct req_farm_items_t : public jcmd_t<7814>
    {
        JSON0(req_farm_items_t)
    };

    struct jpk_farm_item_t
    {
        int farmid;
        int itemid;
        int isend;
        int getnum;
        int getstamp;
        int losetime;
        int canrob;
        int cstamp;
        JSON8(jpk_farm_item_t, farmid,itemid,isend,getnum,getstamp,losetime,canrob,cstamp)
    };

    struct ret_farm_items_t : public jcmd_t<7815>
    {
        int32_t code;
        vector<jpk_farm_item_t> items;
        JSON2(ret_farm_items_t, code, items)
    };

    struct req_plant_item : public jcmd_t<7816>
    {
        int32_t plantindex;
        JSON1(req_plant_item, plantindex);
    };

    struct ret_plant_item : public jcmd_t<7817>
    {
        int32_t code;
        jpk_farm_item_t res;
        JSON2(ret_plant_item, code, res)
    };

    struct req_plant_shop_items_t : public jcmd_t<7810>
    {
        int page;
        JSON1(req_plant_shop_items_t, page);
    };

    struct plant_item_t
    {
        int id;
        int item_id;
        int count;
        int price;
        bool isnew;
        int limited;
        int buy_num;
        string name;
        JSON8(plant_item_t, id, item_id, count, price, isnew, limited, buy_num, name)
    };

    struct ret_plant_shop_items_t : public jcmd_t<7811>
    {
        int page;
        vector<plant_item_t> items;
        JSON2(ret_plant_shop_items_t, page, items)
    };

    struct req_plant_shop_buy_t : public jcmd_t<7812>
    {
        int id;
        int num;
        JSON2(req_plant_shop_buy_t, id, num)
    };

    struct ret_plant_shop_buy_t : public jcmd_t<7813>
    {
        int code;
        int id;
        int item_id;
        int num;
        JSON4(ret_plant_shop_buy_t, code, id, item_id, num)
    };
    
    struct req_inventory_shop_items_t : public jcmd_t<7814>
    {
        int page;
        JSON1(req_inventory_shop_items_t, page);
    };

    struct inventory_item_t
    {
        int id;
        int item_id;
        int count;
        int price;
        bool isnew;
        int limited;
        int buy_num;
        string name;
        JSON8(inventory_item_t, id, item_id, count, price, isnew, limited, buy_num, name)
    };

    struct ret_inventory_shop_items_t : public jcmd_t<7815>
    {
        int page;
        vector<inventory_item_t> items;
        JSON2(ret_inventory_shop_items_t, page, items)
    };

    struct req_inventory_shop_buy_t : public jcmd_t<7816>
    {
        int id;
        int num;
        JSON2(req_inventory_shop_buy_t, id, num)
    };

    struct ret_inventory_shop_buy_t : public jcmd_t<7817>
    {
        int code;
        int id;
        int item_id;
        int num;
        JSON4(ret_inventory_shop_buy_t, code, id, item_id, num)
    };

    struct req_opentask_info_t : public jcmd_t<7818>
    {
        JSON0(req_opentask_info_t);
    };

    struct ret_opentask_info_t : public jcmd_t<7819>
    {
        int32_t opentasklv;
        int32_t opentask_step1;
        int32_t opentask_step2;
        int32_t opentask_step3;
        int32_t  opentask_reward;
        JSON5(ret_opentask_info_t, opentasklv, opentask_step1, opentask_step2, opentask_step3, opentask_reward);
    };

    struct nt_opentask_t : public jcmd_t<7820>
    {
        int32_t opentask_stage_one;
        int32_t opentask_stage_two;
        int32_t opentask_stage_three;
        int32_t opentask_reward;
        int32_t opentask_level;
        JSON5(nt_opentask_t, opentask_stage_one, opentask_stage_two, opentask_stage_three, opentask_reward, opentask_level);
    };

    struct req_opentask_reward_t : public jcmd_t<7821>
    {
        int32_t opentaskid;
        JSON1(req_opentask_reward_t, opentaskid);
    };

    struct ret_opentask_reward_t : public jcmd_t<7822>
    {
        int32_t code;
        int32_t opentaskid;
        JSON2(ret_opentask_reward_t, code, opentaskid);
    };

    // 社团商店
    struct req_gang_shop_items_t : public jcmd_t<7823>
    {
        JSON0(req_gang_shop_items_t)
    };

    struct jpk_gang_shop_item_t
    {
        int id;
        int item_id;
        int count;
        string name;
        int money_type;
        int price;
        int limited;
        int buy_num; // 已经购买次数
        JSON8(jpk_gang_shop_item_t,id,item_id,count,name,money_type,price,limited,buy_num)
    };

    struct ret_gang_shop_items_t : public jcmd_t<7824>
    {
        int32_t code;
        vector<jpk_gang_shop_item_t> items;
        JSON2(ret_gang_shop_items_t, code, items)
    };

    struct req_gang_shop_buy_t : public jcmd_t<7825>
    {
        int index;
        JSON1(req_gang_shop_buy_t,index)
    };

    struct ret_gang_shop_buy_t : public jcmd_t<7826>
    {
        int code;
        int index;
        JSON2(ret_gang_shop_buy_t,code,index)
    };

    //通知客户端远征商店已刷新
    struct nt_gang_shop_reset_t : public jcmd_t<7827>
    {
        JSON0(nt_gang_shop_reset_t)
    };

    struct nt_newest_card_comment_t : public jcmd_t<7828>
    {
        int32_t type;
        vector<jpk_card_comment_info_t> infos;
        jpk_card_comment_info_t max_comment;    //最热的评论
        JSON3(nt_newest_card_comment_t,type, infos, max_comment);
    };

    // 符文商店
    struct req_rune_shop_items_t : public jcmd_t<7830>
    {
        JSON0(req_rune_shop_items_t)
    };

    struct jpk_rune_shop_item_t
    {
        int id;
        int item_id;
        int count;
        string name;
        int money_type;
        int price;
        int limited;
        int buy_num; // 已经购买次数
        JSON8(jpk_rune_shop_item_t,id,item_id,count,name,money_type,price,limited,buy_num)
    };

    struct ret_rune_shop_items_t : public jcmd_t<7831>
    {
        int32_t code;
        vector<jpk_rune_shop_item_t> items;
        JSON2(ret_rune_shop_items_t, code, items)
    };

    struct req_rune_shop_buy_t : public jcmd_t<7832>
    {
        int index;
        JSON1(req_rune_shop_buy_t,index)
    };

    struct ret_rune_shop_buy_t : public jcmd_t<7833>
    {
        int code;
        int index;
        JSON2(ret_rune_shop_buy_t,code,index)
    };

    //通知客户端远征商店已刷新
    struct nt_rune_shop_reset_t : public jcmd_t<7834>
    {
        JSON0(nt_rune_shop_reset_t)
    };

    // 活动商店
    struct req_cardevent_shop_items_t : public jcmd_t<7835>
    {
        JSON0(req_cardevent_shop_items_t)
    };

    struct jpk_cardevent_shop_item_t
    {
        int id;
        int item_id;
        int count;
        string name;
        int money_type;
        int price;
        int limited;
        int buy_num; // 已经购买次数
        JSON8(jpk_cardevent_shop_item_t,id,item_id,count,name,money_type,price,limited,buy_num)
    };

    struct ret_cardevent_shop_items_t : public jcmd_t<7836>
    {
        int32_t code;
        vector<jpk_cardevent_shop_item_t> items;
        JSON2(ret_cardevent_shop_items_t, code, items)
    };

    struct req_cardevent_shop_buy_t : public jcmd_t<7837>
    {
        int index;
        JSON1(req_cardevent_shop_buy_t,index)
    };

    struct ret_cardevent_shop_buy_t : public jcmd_t<7838>
    {
        int code;
        int index;
        JSON2(ret_cardevent_shop_buy_t,code,index)
    };

    // 限时商店
    struct req_lmt_shop_items_t : public jcmd_t<7839>
    {
        JSON0(req_lmt_shop_items_t)
    };

    struct jpk_lmt_shop_item_t
    {
        int id;
        int item_id;
        int count;
        string name;
        int money_type;
        int price;
        int limited;
        int buy_num; // 已经购买次数
        int start_time;
        int end_time;
        JSON10(jpk_lmt_shop_item_t,id,item_id,count,name,money_type,price,limited,buy_num, start_time, end_time)
    };

    struct ret_lmt_shop_items_t : public jcmd_t<7840>
    {
        int32_t code;
        vector<jpk_lmt_shop_item_t> items;
        JSON2(ret_lmt_shop_items_t, code, items)
    };

    struct req_lmt_shop_buy_t : public jcmd_t<7841>
    {
        int index;
        JSON1(req_lmt_shop_buy_t,index)
    };

    struct ret_lmt_shop_buy_t : public jcmd_t<7842>
    {
        int code;
        int index;
        JSON2(ret_lmt_shop_buy_t,code,index)
    };


    struct req_clear_lmt_cd : public jcmd_t<7850>
    {
        JSON0(req_clear_lmt_cd)
    };

    struct ret_clear_lmt_cd : public jcmd_t<7851>
    {
        int32_t code;
        JSON1(ret_clear_lmt_cd, code)
    };

    struct req_sweep_expedition_t : public jcmd_t<7852>
    {
        JSON0(req_sweep_expedition_t)
    };

    struct expedition_drop_t
    {
        int32_t floor;
        map<int, int> drops;
        JSON2(expedition_drop_t,floor,drops);
    };
    struct ret_sweep_expedition_t : public jcmd_t<7853>
    {
        int32_t code;
        int32_t start;
        int32_t last;
        vector<expedition_drop_t> drops;
        JSON4(ret_sweep_expedition_t, code, start, last, drops)
    };

    struct nt_luckybag_change : public jcmd_t<7854>
    {
        int32_t luckybagvalue;
        JSON1(nt_luckybag_change, luckybagvalue);
    };

    struct nt_report_t : public jcmd_t<7860>
    {
        int32_t code;
        JSON1(nt_report_t, code);
    };

    struct req_report_t : public jcmd_t<7861>
    {
        int32_t uid;
        JSON1(req_report_t, uid);
    };

    struct nt_role_pros_change_t : public jcmd_t<7862>
    {
        vector<nt_role_pro_change_t> pro_list;
        JSON1(nt_role_pros_change_t, pro_list)
    };

    struct req_compose_pet_t : public jcmd_t<7900>
    {
        JSON0(req_compose_pet_t)
    };

    struct ret_compose_pet_t : public jcmd_t<7901>
    {
        int32_t code;
        int32_t resid;
        int32_t atk;
        int32_t mgc;
        int32_t def;
        int32_t res;
        int32_t hp;
        JSON7(ret_compose_pet_t, resid, code, atk, mgc, def, res, hp)
    };

    struct req_combo_pro_open_t : public jcmd_t<7903>
    {
        int32_t type_id;
        JSON1(req_combo_pro_open_t, type_id)
    };

    struct ret_combo_pro_open_t : public jcmd_t<7904>
    {
        int32_t code;
        JSON1(ret_combo_pro_open_t, code)
    };

    struct req_combo_pro_levelup_t : public jcmd_t<7905>
    {
        int32_t type_id;
        JSON1(req_combo_pro_levelup_t, type_id)
    };

    struct ret_combo_pro_levelup_t : public jcmd_t<7906>
    {
        int32_t code;
        JSON1(ret_combo_pro_levelup_t, code)
    };

    struct nt_combo_pro_attribute_change : public jcmd_t<7907>
    {
        int32_t attribute_id;
        int32_t value;
        JSON2(nt_combo_pro_attribute_change, attribute_id, value)
    };

    struct nt_combo_pro_exp_change : public jcmd_t<7908>
    {
        int32_t attribute_id;
        int32_t value;
        JSON2(nt_combo_pro_exp_change, attribute_id, value)
    };

    struct req_hunt_rune_t : public jcmd_t<7950>
    {
        int32_t use_item;
        JSON1(req_hunt_rune_t, use_item)
    };

    struct ret_hunt_rune_t : public jcmd_t<7951>
    {
        int32_t code;
        int32_t new_level;
        int32_t new_resid;
        JSON3(ret_hunt_rune_t, code, new_level, new_resid);
    };

    struct req_enter_rune_hunt_t : public jcmd_t<7952>
    {
        JSON0(req_enter_rune_hunt_t)
    };

    struct hunt_news
    {
        string name;
        int32_t resid;
        JSON2(hunt_news, name, resid)
    };

    struct ret_enter_rune_hunt_t : public jcmd_t<7953>
    {
        int32_t code;
        vector<hunt_news> news;
        int32_t curLevel;
        JSON3(ret_enter_rune_hunt_t, code, news, curLevel)
    };

    struct nt_new_rune_be_hunted_t : public jcmd_t<7954>
    {
        hunt_news news;
        JSON1(nt_new_rune_be_hunted_t, news);
    };

    struct nt_leave_rune_hunt_t : public jcmd_t<7955>
    {
        JSON0(nt_leave_rune_hunt_t);
    };

    struct nt_add_new_rune_t : public jcmd_t<7956>
    {
        vector<int32_t> id_list;
        int32_t lv;
        int32_t resid;
        int32_t exp;
        JSON4(nt_add_new_rune_t, id_list, lv, resid, exp)
    };

    struct req_new_rune_inlay_t : public jcmd_t<7957>
    {
        int32_t id;
        int32_t pid;
        int32_t pos;
        JSON3(req_new_rune_inlay_t, id, pid, pos)
    };

    struct ret_new_rune_inlay_t : public jcmd_t<7958>
    {
        int32_t code;
        int32_t id;
        int32_t pid;
        int32_t pos;
        JSON4(ret_new_rune_inlay_t, code, id, pid, pos)
    };

    struct req_new_rune_unlay_t : public jcmd_t<7959>
    {
        int32_t pid;
        int32_t pos;
        JSON2(req_new_rune_unlay_t, pid, pos)
    };

    struct ret_new_rune_unlay_t : public jcmd_t<7960>
    {
        int32_t code;
        int32_t pid;
        int32_t pos;
        JSON3(ret_new_rune_unlay_t, code, pid, pos)
    };

    struct req_new_rune_levelup_t : public jcmd_t<7961>
    {
        int32_t rune;
        vector<int32_t> mat_list;
        JSON2(req_new_rune_levelup_t, rune, mat_list)
    };

    struct ret_new_rune_levelup_t : public jcmd_t<7962>
    {
        int32_t code;
        int32_t id;
        int32_t exp;
        JSON3(ret_new_rune_levelup_t, code, id, exp)
    };

    struct nt_del_rune_t : public jcmd_t<7963>
    {
        vector<int32_t> id_list;
        JSON1(nt_del_rune_t, id_list)
    };

    struct req_new_rune_compose_t : jcmd_t<7964>
    {
        int32_t id;
        vector<int32_t> mat_list;
        JSON2(req_new_rune_compose_t, id, mat_list);
    };

    struct ret_new_rune_compose_t : jcmd_t<7965>
    {
        int32_t code;
        int32_t id;
        int32_t lv;
        JSON3(ret_new_rune_compose_t, code, id, lv)
    };

    struct req_new_rune_active_t : jcmd_t<7966>
    {
        int32_t pid;
        JSON1(req_new_rune_active_t, pid)
    };

    struct ret_new_rune_active_t : jcmd_t<7967>
    {
        int32_t code;
        int32_t pid;
        JSON2(ret_new_rune_active_t, code, pid)
    };

    struct req_announcement_t : jcmd_t<8050>
    {
        JSON0(req_announcement_t);
    };

    struct jpk_announcement_info
    {
        int32_t id;
        string  title;
        string time;
        string content;
        int32_t timestamp;
        JSON5(jpk_announcement_info, id, title, time, content, timestamp)
    };
    struct jpk_announcement_event
    {
        int32_t id;
        string  title;
        string start_time;
        string end_time;
        int32_t timestamp;
        string content;
        JSON6(jpk_announcement_event, id, title, start_time,end_time, content, timestamp)
    };


    struct ret_announcement_t : jcmd_t<8051>
    {
        vector<jpk_announcement_info> info_update;
        vector<jpk_announcement_event> info_event;
        JSON2(ret_announcement_t, info_update, info_event);
    };

    struct req_gen_inheritance_code_t : jcmd_t<8000>
    {
        JSON0(req_gen_inheritance_code_t)
    };

    struct ret_gen_inheritance_code_t : jcmd_t<8001>
    {
        int32_t code;
        string inheritance_code;
        JSON2(ret_gen_inheritance_code_t, code, inheritance_code)
    };

    struct req_model_t : jcmd_t<8002>
    {
        JSON0(req_model_t)
    };

    struct ret_model_t : jcmd_t<8003>
    {
        int32_t code;
        int32_t model;
        JSON2(ret_model_t, code, model)
    };

    struct req_change_model_t : jcmd_t<8004>
    {
        int32_t new_model;
        JSON1(req_change_model_t, new_model)
    };

    struct ret_change_model_t : jcmd_t<8005>
    {
        int32_t code;
        int32_t model;
        JSON2(ret_change_model_t, code, model)
    };

    struct req_vip_exp_t : jcmd_t <8080>
    {
        JSON0(req_vip_exp_t);
    };
    struct ret_vip_exp_t :jcmd_t<8081>
    {
        int32_t vip_days;
        int32_t vip_stamp;
        JSON2(ret_vip_exp_t, vip_days, vip_stamp);
    };
    //反馈返回
    struct nt_feedback_t : jcmd_t<8082>
    {
        int32_t code;
        JSON1(nt_feedback_t,code);
    };
    //获得跟别人的聊天记录
    struct req_private_chat_info_t : jcmd_t<8070>
    {
        int32_t player_uid;
        JSON1(req_private_chat_info_t,player_uid);
    };
    struct ret_private_chat_info_t : jcmd_t<8071>
    {
        int32_t player_uid;
        int32_t stamp;
        int32_t resid;
        int32_t level;
        string name;
        vector<nt_msg_push_t> private_chat_infos;
        JSON6(ret_private_chat_info_t, player_uid,stamp,resid,level,name,private_chat_infos);
    };
};

typedef boost::shared_ptr<sc_msg_def::jpk_view_role_data_t> sp_helphero_t;
typedef boost::shared_ptr<sc_msg_def::jpk_view_user_data_t> sp_view_user_t;
typedef boost::shared_ptr<sc_msg_def::jpk_view_other_data_t> sp_view_user_other_t;
typedef boost::shared_ptr<sc_msg_def::jpk_fight_view_user_data_t> sp_fight_view_user_t;

#endif
