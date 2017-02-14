#ifndef _platform_msg_def_h_ 
#define _platform_msg_def_h_ 

#include "jserialize_macro.h"

namespace pf_msg
{
    //用户请求支付
    struct req_pay_t : public jcmd_t<20000>
    {
        uint32_t uid;
        uint32_t resid;
        uint32_t num;
        JSON3(req_pay_t, uid, resid, num);
    };
    struct ret_pay_t : public jcmd_t<20001>
    {
        uint32_t uid;
        uint64_t serial;
        JSON2(ret_pay_t, uid, serial);
    };

    //php通知用户购买成功
    struct nt_user_pay_result_t : public jcmd_t<21000>
    {
        //应用id
        string appid;
        //平台名
        string plat;
        //平台账户
        string uin;
        //订单号
        string serial;
        //服务器id
        uint16_t serid;
        //用户id
        uint32_t uid; 
        //商品
        uint32_t goodsid;
        //数量
        uint32_t goodsnum;
        //支付状态
        int paystatus;
        //支付时间
        string paytime;

        JSON10(nt_user_pay_result_t, appid, plat, uin, serial, serid, uid, goodsid, goodsnum, paystatus, paytime)
    };

    //通知php查询购买结果
    struct req_check_pay_result_t : public jcmd_t<21001>
    {
        string appid;
        string serial;
        JSON2(req_check_pay_result_t, appid, serial);
    };

    //通知游戏服务器购买成功
    struct nt_pay_ok_t : public jcmd_t<21001>
    {
        uint32_t uid;
        JSON1(nt_pay_ok_t, uid)
    };

    //游戏服务器请求领取购买的物品
    struct req_given_goods_t : public jcmd_t<21002>
    {
        uint32_t uid;
        JSON1(req_given_goods_t, uid);
    };

    struct goods_t
    {
        uint32_t resid;
        uint32_t num;
        JSON2(goods_t, resid, num)
    };
    struct ret_given_goods_t : public jcmd_t<21003>
    {
        uint32_t        uid;
        vector<goods_t> goods;
        JSON2(ret_given_goods_t, uid, goods);
    };
}

#endif
