#ifndef _test_msg_h_
#define _test_msg_h_

#include "jserialize_macro.h"

struct test_msg_def
{
    //请求竞技场测试
    struct req_test_arena_t : public jcmd_t<9000>
    {
        //测试总数
        int             test_total_num;

        //施法者resid
        int             cast_resid;
        //施法者等级
        int             cast_lv;

        int             cast_with_partner_num;

        //目标resid
        int             target_resid;
        //目标等级
        int             target_lv;

        int             target_with_partner_num;

        JSON7(req_test_arena_t, test_total_num, cast_resid, cast_lv, cast_with_partner_num, target_resid, target_lv, target_with_partner_num)
    };

    //返回竞技场测试结果
    struct ret_test_arena_t : public jcmd_t<9001>
    {
        //施法者数据(serialized jpk_view_user_data_t)
        string      cast_data;
        //目标者数据(serialized jpk_view_user_data_t)
        string      target_data; 
        //测试总数
        int         test_total_num;
        //胜利次数
        int         win_num;
        JSON4(ret_test_arena_t, cast_data, target_data, test_total_num, win_num)
    };

    struct req_pay_t : public jcmd_t<9002>
    {
        int id;
        JSON1(req_pay_t, id)
    };

    struct ret_pay_t : public jcmd_t<9003>
    {
        int code;
        JSON1(ret_pay_t, code)
    };

    struct req_fight_test_t : public jcmd_t<9100>
    {
        uint32_t cast_uid; 
        uint32_t target_uid;
        int fight_num;
        JSON3(req_fight_test_t, cast_uid, target_uid, fight_num);
    };

    struct ret_fight_test_t : public jcmd_t<9101>
    {
        int code;
        int win_num; 
        int lose_num;
        uint32_t left_dmg;
        uint32_t right_dmg;
        string logname;
        JSON6(ret_fight_test_t, code, win_num, lose_num, logname, left_dmg, right_dmg);
    };

    struct req_overdue_t : public jcmd_t<9200>
    {
        uint32_t uid;
        JSON1(req_overdue_t, uid)
    };
    struct ret_overdue_t : public jcmd_t<9201>
    {
        int code;
        JSON1(ret_overdue_t, code)
    };

    struct req_round_drop_t : public jcmd_t<9300>
    {
        //关卡id
        int resid;
        //挑战次数
        int fight_num;
        JSON2(req_round_drop_t, resid, fight_num)
    };

    struct ret_round_drop_t : public jcmd_t<9301>
    {
        map<uint32_t, uint32_t> drops;
        JSON1(ret_round_drop_t, drops)
    };
};

#endif
