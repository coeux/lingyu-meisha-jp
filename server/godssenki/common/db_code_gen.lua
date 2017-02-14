db_account_t = 
{
    db = {
        aid = 'int32_t',
        domain='ystring_t<10>',
        name = 'ystring_t<64>',
        flag = 'int32_t',
        lasthostnum = 'int32_t',
        lastuid = 'int32_t',
    },
    key = {'aid', 'name'},
    --autokey = {'aid'},
    ops_conditon = {
        sel = {
            select_name = {'domain', 'name'},
            select_aid = {'aid'},
        },
        update = {
            {'aid'},
        },
        del = {
            {'aid'},
        },
    },
    db_service="dbgl_service"
}

--
db_bullet_t =
{
    db = {
        round = 'uint32_t',
        stamp = 'uint32_t',
        uid = 'int32_t',
        pos = 'int32_t',
        msg = 'ystring_t<30>',
    },
    ops_conditon = {
        sel = {
            select_round = {'round'},
        },
        update = {
            {'round'},
        },
    },
}

db_cdkey_t =
{
    db = {
        sn = 'ystring_t<8>',
        flag = 'int32_t',
        expire_date = 'ystring_t<30>',
        domain = 'ystring_t<30>',
        uid = 'int32_t',
        nickname = 'ystring_t<30>',
        giventm = 'ystring_t<30>',
    },
    key = {'sn'},
    ops_conditon = {
        sel = {
            select_sn = {'sn'},
        },
        update = {
            {'sn'},
        },
    },
    db_service="dbgl_service"
}

db_userid_t = 
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        resid = 'int32_t',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        grade = 'int32_t',
        viplevel = 'int32_t',
        wingid = 'int32_t',
        state = 'int32_t',
        isoverdue='int32_t',
    },
    key = {'aid', 'uid', 'resid'},
    --autokey = {'uid'},
    ops_conditon = {
        sel = {
            select_user = {'aid', 'hostnum'},
            select_user_state = {'aid', 'hostnum', 'state'},
            select_user_condition = {'aid', 'hostnum', '@condition'},
            select_uid = {'uid'},
            select_uid_state = {'uid', 'state'},
            select_all_uid_state = {'aid', 'state'},
            select_uid_condition = {'uid', '@condition'},
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}

db_newaccount_t =
{
    db = {
        domain = 'ystring_t<10>',
        name = 'ystring_t<64>',
        aid = 'int32_t',
        ctime = 'ystring_t<30>',
    },
    ops_conditon = {},
}

db_buylog_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        vip = 'int32_t',
        buytm = 'ystring_t<30>',
        resid = 'int32_t',
        itemname = 'ystring_t<30>',
        count = 'int32_t',
        buytype = 'int32_t',
        price = 'int32_t',
        payyb = 'int32_t',
        freeyb = 'int32_t',
        fpoint = 'int32_t',
    },
    ops_conditon = {},
}

db_fpexception_t =
{
    db = {
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        aid = 'int32_t',
        uid = 'int32_t',
        nickname = 'ystring_t<30>',
        resid = 'int32_t',
        rolefp = 'int32_t',
        resfp = 'int32_t',
    },
    ops_conditon = {},
}

db_yblog_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        hostnum = 'int32_t',
        sid = 'int32_t',
        nickname = 'ystring_t<30>',
        name = 'ystring_t<32>',
        domain = 'ystring_t<10>',
        appid = 'ystring_t<32>',
        domain = 'ystring_t<10>',
        serid = 'int32_t',
        payyb = 'int32_t',
        freeyb = 'int32_t',
        totalyb = 'int32_t',
        resid = 'int32_t',
        price = 'int32_t',
        count = 'int32_t',
        rmb = 'int32_t',
        tradetm = 'ystring_t<30>',
        giventm = 'ystring_t<30>',
    },
    ops_conditon = {},
}
db_eventlog_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        eventid = 'int32_t',
        eventm = 'ystring_t<30>',
        resid = 'int32_t',
        count = 'int32_t',
        code = 'int32_t',
        flag = 'int32_t',
        extra = 'ystring_t<300>',
    },
    ops_conditon = {},
}
db_consumelog_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        consumetm = 'ystring_t<30>',
        consumetype = 'int32_t',
        resid = 'int32_t',
        itemname = 'ystring_t<30>',
        count = 'int32_t',
        balance = 'int32_t',
    },
    ops_conditon = {},
}
db_quitlog_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        name = 'ystring_t<32>',
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        counttime = 'int32_t',
        totaltime = 'int32_t',
        logintm = 'ystring_t<30>',
        quittm = 'ystring_t<30>',
        mac = 'ystring_t<64>',
        sys = 'int32_t',
        device = 'ystring_t<20>',
        os = 'ystring_t<20>',
        grade = 'int32_t',
        exp = 'int32_t',
        resid = 'int32_t',
        vip = 'int32_t',
        questid = 'int32_t',
        step = 'int32_t',
    },
    ops_conditon = {},
}
db_online_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        serid = 'int32_t',
        name = 'ystring_t<32>',
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        counttime = 'int32_t',
        logintm = 'ystring_t<30>',
        loginstamp = 'uint32_t',
        mac = 'ystring_t<64>',
        sys = 'int32_t',
        device = 'ystring_t<20>',
        os = 'ystring_t<20>',
        grade = 'int32_t',
        exp = 'int32_t',
        resid = 'int32_t',
        vip = 'int32_t',
        questid = 'int32_t',
    },
    ops_conditon = {},
}

db_newrole_t =
{
    db = {
        domain = 'ystring_t<10>',
        hostnum = 'int32_t',
        aid = 'int32_t',
        uid = 'int32_t',
        mac = 'ystring_t<64>',
        ctime = 'ystring_t<30>',
    },
    ops_conditon = {},
}

db_card_event_user_log_t =
{
    db = {
        uid = 'int32_t',
        hostnum = 'int32_t',
        score = 'int32_t',
        coin = 'int32_t',
        goal_level = 'int32_t',
        round = 'int32_t',
        round_status = 'int32_t',
        round_max = 'int32_t',
        difficult = 'int32_t',
        reset_time = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
        anger = 'int32_t',
        enemy_view_data = 'string',
        hp1 = 'float',
        hp2 = 'float',
        hp3 = 'float',
        hp4 = 'float',
        hp5 = 'float',
        season = 'int32_t',
    },
    ops_conditon = {};
}

db_userinfo_t =
{
    db = {
        uid = 'int32_t',
        aid = 'int32_t',
        resid = 'int32_t',
        nickname = 'ystring_t<30>',
        headid = 'int32_t',
        hostnum = 'int32_t',
        chronicle_sum = 'uint32_t',
        lovelevel = 'int32_t',
        lovevalue = 'int32_t',
        vipexp = 'int32_t',
        viplevel = 'int32_t',
        fpoint = 'int32_t',
        gold = 'int32_t',
        payyb = 'int32_t',
        freeyb = 'int32_t',
        exp = 'int32_t',
        grade = 'int32_t',
        isnew = 'int32_t',
        isnewlv = 'int32_t',
        draw_num = 'int32_t',
        draw_ten_diamond = 'int32_t',
        draw_reward = 'ystring_t<30>',
        round_stars_reward = 'ystring_t<30>',
        kanban = 'int32_t',
        kanban_type = 'int32_t',
        flush1times = 'int32_t',
        flush2first = 'int32_t',
        flush2round = 'int32_t',
        flush2times = 'int32_t',
        flush1round = 'int32_t',
        flush3round = 'int32_t',
        flush3times = 'int32_t',
        power = 'int32_t',
        energy = 'int32_t',
        quality = 'int32_t',
        potential_1 = 'int32_t',
        potential_2 = 'int32_t',
        potential_3 = 'int32_t',
        potential_4 = 'int32_t',
        potential_5 = 'int32_t',
        naviClickNum1 = 'int32_t',
        naviClickNum2 = 'int32_t',
        battlexp = 'int32_t',
        runechip = 'int32_t',
        sceneid = 'int32_t',
        roundid = 'int32_t',
        elite_roundid = 'int32_t';
        eliteid = 'int32_t',
        zodiacid = 'int32_t',
        zodiacstamp = 'uint32_t',
        questid = 'int32_t',
        nextquestid = 'int32_t',
        treasure = 'int32_t',
        lastquit = 'uint32_t',
        roundstars = 'ystring_t<1024>',
        elite_round_times = 'ystring_t<1024>',
        elite_reset_times = 'ystring_t<1024>',
        rank = 'int32_t',
        m_rank = 'int32_t',
        fp = 'int32_t',
        helphero = 'int32_t',
        hhresid = 'int32_t',
        frd = 'int32_t',
        totaltime = 'uint32_t',
        bagn = 'int32_t',
        func = 'uint64_t',
        utype='int32_t',
        boxn='int32_t',
        boxe='int32_t',
        firstpay='int32_t',
        soul='int32_t',
        caveid='int32_t',
        honor='int32_t',
        unhonor='int32_t',
        meritorious='int32_t',
        expeditioncoin='int32_t',
        titlelv = 'int32_t',
        hm_maxid='int32_t',
        npcshop='uint32_t',
        npcshoprefresh = 'int32_t',
        npcshopbuy = 'int32_t',
        npcshoptime1 = 'uint32_t',
        npcshoptime2 = 'uint32_t',
        npcshoptime3 = 'uint32_t',
        specicalshop = 'int32_t',
        spshoprefresh = 'int32_t',
        spshopbuy ='int32_t',
        spshoptime = 'uint32_t',
        sign_daily = 'uint32_t',
        sign_cost  = 'int32_t',
        twoprecord='int32_t',
        limitround='int32_t',
        numFlower = 'int32_t',
        useFlower = 'int32_t',
        resetFlowerStamp = 'uint32_t',
        useFlowerStamp = 'uint32_t',
        last_power_stamp = 'int32_t',
        sign_month = 'int32_t',
        model = 'int32_t',
        createtime = 'uint32_t',
    },
    key = {'uid', 'resid', 'aid', 'nickname'},
    ops_conditon = {
        sel = {
            select_user = {'uid'}
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}

db_partner_t=
{
    db = {
        pid = 'int32_t',
        uid = 'int32_t',
        resid = 'int32_t',
        grade = 'int32_t',
        lovelevel = 'int32_t',
        lovevalue = 'int32_t',
        exp = 'int32_t',
        quality = 'int32_t',
        potential_1 = 'int32_t',
        potential_2 = 'int32_t',
        potential_3 = 'int32_t',
        potential_4 = 'int32_t',
        potential_5 = 'int32_t',
        naviClickNum1 = 'int32_t',
        naviClickNum2 = 'int32_t', 
    },
    key = {'uid', 'pid', 'resid'},
    --autokey = {'pid'},
    ops_conditon = {
        sel = {
            select_partner = {'uid'}
        },
        update = {
            {'uid', 'pid'},
        },
        del = {
            {'uid', 'pid'},
        },
    }
}

db_partnerchip_t=
{
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
    },
    key = {'uid', 'resid'},
    --autokey = {'pid'},
    ops_conditon = {
        sel = {
            select_partnerchip = {'uid'}
        },
        update = {
            {'uid', 'resid'},
        },
        del = {
            {'uid', 'resid'},
        },
    }
}

db_item_t=
{
    db = {
        itid = 'int32_t',
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
    },
    key = {'itid', 'uid', 'resid'},
    --autokey = {'itid'},
    ops_conditon = {
        sel = {
            select_item_all = {'uid'},
        },
        update = {
            {'uid', 'itid'},
        },
        del = {
            {'uid', 'itid'},
        },
    }
}

db_equip_t = 
{
    db = {
        eid = 'int32_t',
        resid = 'int32_t',
        uid = 'int32_t',
        pid = 'int32_t',
        gresid1 = 'int32_t',
        gresid2 = 'int32_t',
        gresid3 = 'int32_t',
        gresid4 = 'int32_t',
        gresid5 = 'int32_t',
        strenlevel = 'int32_t',
        isweared = 'int32_t', 
    },
    key = {'eid', 'uid'},
    --autokey = {'eid'},
    ops_conditon = {
        sel = {
            select_equip_all = {'uid'},
        },
        update = {
            {'uid', 'eid'},
        },
        del = {
            {'uid', 'eid'},
        },
    }
}

db_skill_t = 
{
    db = {
        skid  = 'int32_t',
        resid  = 'int32_t',
        uid  = 'int32_t',
        pid  = 'int32_t',
        level  = 'int32_t',
    },
    key = {'skid', 'uid', 'pid'},
    ops_conditon = {
        sel = {
            select_skill = {'uid'}
        },
        update = {
            {'uid', 'skid'},
        },
        del = {
            {'uid', 'skid'},
        },
    }
}

db_team_t = 
{
    db = {
        uid = 'int32_t',
        tid = 'int32_t',
        name = 'ystring_t<30>',
        p1 = 'int32_t',
        p2 = 'int32_t',
        p3 = 'int32_t',
        p4 = 'int32_t',
        p5 = 'int32_t',
        is_default = 'int32_t',
    },
    key = {'uid', 'tid'},
    ops_conditon = {
        sel = {
            select_team_all = {'uid'};
            select_team_default = {'uid', 'is_default'};
        },
        update = {
            {'uid', 'tid'},
        },
        del = {
            {'uid', 'tid'},
        },
    }
}

db_server_t = 
{
    db = {
        serid = 'int32_t',
        maxlv = 'int32_t',
        wbcut = 'uint32_t',
        bosslv = 'int32_t',
        result_rank_stamp = 'uint32_t',
        ctime = 'uint32_t',
    },
    key = {'serid'},
    ops_conditon = {
        sel = {
            select_server = {'serid'}
        },
        update = {
            {'serid'},
        },
        del = {
            {'serid'},
        },
    }
}
db_reward_extentioni_t =
{
    db = {
        uid = 'int32_t',
        sevenpay_count = 'int32_t',
        sevenpay_stage = 'ystring_t<30>',
        lastpay_timestamp  = 'int32_t',
        limit_seven_count = 'int32_t',
        limit_seven_stage = 'ystring_t<30>',
        limit_seven_stamp = 'int32_t',
        limit_pub       = 'int32_t',
        openybtotal     = 'int32_t',
        openybreward    = 'ystring_t<30>',
        openybstamp     = 'int32_t',
        opentask_level  = 'int32_t',
        opentask_stage_one = 'int32_t',
        opentask_stage_two = 'int32_t',
        opentask_stage_three = 'int32_t',
        opentask_reward = 'int32_t',
        luckbagvalue = 'int32_t',
        luckbagstamp = 'int32_t',
        vip_stamp = 'int32_t',
        vip_days = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_reward = {'uid'}
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}
db_reward_t = 
{
    db = {
        uid = 'int32_t',
        vip1 = 'int32_t',
        vip2 = 'int32_t',
        vip3 = 'int32_t',
        vip4 = 'int32_t',
        vip5 = 'int32_t',
        vip6 = 'int32_t',
        vip7 = 'int32_t',
        vip8 = 'int32_t',
        vip9 = 'int32_t',
        vip10 = 'int32_t',
        vip11 = 'int32_t',
        vip12 = 'int32_t',
        vip13 = 'int32_t',
        vip14 = 'int32_t',
        vip15 = 'int32_t',
        vip16 = 'int32_t',
        vip17 = 'int32_t',
        vip18 = 'int32_t',
        pvelose_times = 'int32_t',
        given_power_stamp = 'uint32_t',
        given_rank_stamp = 'uint32_t',
        first_yb = 'int32_t',
        can_get_first = 'int32_t',
        acc_yb1 = 'int32_t',
        acc_yb2 = 'int32_t',
        acc_yb3 = 'int32_t',
        acc_yb4 = 'int32_t',
        acc_yb5 = 'int32_t',
        acc_yb6 = 'int32_t',
        acc_yb7 = 'int32_t',
        yblevel = 'int32_t',
        con_lg1 = 'int32_t',
        con_lg2 = 'int32_t',
        con_lg3 = 'int32_t',
        con_lg4 = 'int32_t',
        con_lg5 = 'int32_t',
        con_lg6 = 'int32_t',
        con_lg7 = 'int32_t',
        conhero = 'int32_t',
        conequip = 'int32_t',
        conlglevel = 'int32_t',
        acc_lg1 = 'int32_t',
        acc_lg2 = 'int32_t',
        acc_lg3 = 'int32_t',
        acc_lg4 = 'int32_t',
        acc_lg5 = 'int32_t',
        acc_lg6 = 'int32_t',
        acc_lg7 = 'int32_t',
        acc_lg8 = 'int32_t',
        acc_lg9 = 'int32_t',
        acc_lg10 = 'int32_t',
        acc_lg11 = 'int32_t',
        acc_lg12 = 'int32_t',
        acc_lg13 = 'int32_t',
        acc_lg14 = 'int32_t',
        acc_lg15 = 'int32_t',
        acc_lg16 = 'int32_t',
        acc_lg17 = 'int32_t',
        acc_lg18 = 'int32_t',
        acc_lg19 = 'int32_t',
        acc_lg20 = 'int32_t',
        acc_lg21 = 'int32_t',
        acc_lg22 = 'int32_t',
        acc_lg23 = 'int32_t',
        acc_lg24 = 'int32_t',
        acclglevel = 'int32_t',
        login_days = 'int32_t',
        login_rewards = 'ystring_t<30>',
        total_login_days = 'int32_t',
        growing_package_status = 'int32_t',
        growing_reward = 'ystring_t<30>',
        is_consume_hundred = 'int32_t',
        limit_wing_reward = 'ystring_t<30>',
        limit_draw_ten = 'int32_t',
        limit_draw_ten_reward = 'ystring_t<30>',
        limit_consume_power = 'int32_t',
        limit_consume_power_reward = 'ystring_t<30>',
        limit_consume_power_stamp = 'int32_t',
        luckybag_reward = 'ystring_t<30>',
        limit_recharge_money = 'int32_t',
        limit_recharge_reward = 'ystring_t<10>',
        limit_single_recharge = 'int32_t',
        limit_single_reward = 'ystring_t<10>',
        limit_single_stamp = 'int32_t',
        daily_draw = 'int32_t',
        daily_draw_reward = 'ystring_t<10>',
        daily_draw_stamp = 'int32_t',
        daily_consume_ap = 'int32_t',
        daily_consume_ap_reward = 'ystring_t<10>',
        daily_consume_ap_stamp = 'int32_t',
        daily_melting = 'int32_t',
        daily_melting_reward =  'ystring_t<10>',
        daily_melting_stamp = 'int32_t',
        limit_melting = 'int32_t',
        limit_melting_reward = 'ystring_t<10>',
        daily_talent = 'int32_t',
        daily_talent_reward = 'ystring_t<10>',
        daily_talent_stamp = 'int32_t',
        limit_talent = 'int32_t',
        limit_talent_reward = 'ystring_t<10>',
        week_reward = 'int32_t',
        acclgexp = 'int32_t',
        first_login = 'uint32_t',
        last_login = 'uint32_t',
        invcode = 'int32_t',
        inviter = 'int32_t',
        inv_reward1 = 'int32_t',
        inv_reward2 = 'int32_t',
        inv_reward3 = 'int32_t',
        inv_reward4 = 'int32_t',
        lv_20 = 'int32_t',
        lv_25 = 'int32_t',
        lv_30 = 'int32_t',
        lv_35 = 'int32_t',
        lv_40 = 'int32_t',
        lv_45 = 'int32_t',
        lv_50 = 'int32_t',
        lv_55 = 'int32_t',
        lv_60 = 'int32_t',
        lv_65 = 'int32_t',
        lv_70 = 'int32_t',
        online = 'int32_t',
        next_online = 'int32_t',
        cumureward = 'int32_t',
        cumulevel= 'int32_t',
        mcardtm='uint32_t',
        mcardn ='int32_t',
        mcardbuytm='uint32_t',
        mcard_event_buy_count='uint32_t',
        mcard_event_state='uint32_t',
        fpreward = 'int32_t',
        cumu_yb_exp = 'int32_t',
        cumu_yb_reward = 'int32_t',
        daily_pay = 'int32_t',
        daily_pay_reward = 'int32_t',
        daily_pay_stamp = 'int32_t',
        wingactivity = 'int32_t',
        wingactivityreward = 'int32_t',
        adt_reward='int32_t',
        adt_stamp='uint32_t',
        vip_package_stamp='uint32_t',
        double_expedition='int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_reward = {'uid'}
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}

db_shop_t = 
{
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
    },
    key = {'uid', 'resid'},
    --autokey = {'rwid'},
    ops_conditon = {
        sel = {
            select_shop = {'uid'}
        },
        update = {
            {'uid', 'resid'},
        },
        del = {
            {'uid', 'resid'},
        },
    }
}

db_task_t = 
{
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        step = 'int32_t',
        state = 'int32_t',
    },
    key = {'uid', 'resid'},
    --autokey = {'rwid'},
    ops_conditon = {
        sel = {
            select_task = {'uid'}
        },
        update = {
            {'uid', 'resid'},
        },
        del = {
            {'uid', 'resid'},
        },
    }
}

db_chronicle_t =
{
    db = {
        uid = 'int32_t',
        chronicle_month = 'int32_t',
        chronicle_day = 'int32_t',
        step = 'int32_t',
        state = 'int32_t',
    },
    key = {'uid', 'chronicle_day'},
    ops_conditon = {
        sel = {
            select_chronicle = {'uid'},
            select_chronicle_day = {'uid', 'chronicle_day'},
            select_chronicle_month = {'uid', 'chronicle_month'},
            select_chronicle_undone = {'uid', 'state'},
        },
        update = {
            {'uid', 'chronicle_day'},
        },
        del = {
            {'uid', 'chronicle_day'},
        },
    }
}

db_friend_t =
{
    db = {
        uid = 'int32_t',
        fuid = 'int32_t',
        hasSendFlower = 'int32_t';
    },
    key = {'uid','fuid'},
    ops_conditon = {
        sel = {
            select_friend = {'uid'}
        },
        update = {
            {'uid','fuid'},
        },
        del = {
            {'uid','fuid'},
        },
    }
}

db_friend_flower_t =
{
    db = {
        id = 'int32_t',
        uid = 'int32_t',
        name = 'ystring_t<30>',
        lv = 'int32_t',
        headid = 'int32_t',
        fuid = 'int32_t',
        stamp = 'uint32_t',
        lifetime = 'int32_t',
        getPower = 'int32_t',
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select_friend_flower = {'uid'}
        },
        update = {
            {'id'},
        },
    }
}



db_rune_t =
{
    db = {
        uid = 'int32_t',
        rid = 'int32_t',
        pid = 'int32_t',
        resid = 'int32_t',
        exp = 'int32_t',
        pos = 'int32_t',
    },
    key = {'rid'},
    ops_conditon = {
        sel = {
            select_rune = {'uid'}
        },
        update = {
            {'uid','rid'},
        },
        del = {
            {'uid','rid'},
        },
    }
}

db_rune_info_t = 
{
    db = {
        uid = 'int32_t',
        page_num = 'int32_t',
        hunt_level = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'}
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}

db_rune_page_t = 
{
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        slot = 'int32_t',
        id = 'int32_t',
    },
    key = {'uid', 'pid', 'slot'},
    ops_conditon = {
        sel = {
            select_rune_page_all = {'uid'}
        },
        update = {
            {'uid', 'pid', 'slot'},
        },
        del = {
            {'uid', 'pid', 'slot'},
        },
    }
}

db_rune_item_t = 
{
    db = {
        uid = 'int32_t',
        id = 'int32_t',
        resid = 'int32_t',
        exp = 'int32_t',
        level = 'int32_t',
    },
    key = {'uid', 'id'},
    ops_conditon = {
        sel = {
            select_rune_item_all = {'uid'}
        },
        update = {
            {'uid', 'id'},
        },
        del = {
            {'uid', 'id'},
        },
    }
}

db_star_t =
{
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        lv = 'int32_t',
        pos = 'int32_t',
        att = 'int32_t',
        value = 'int32_t',
    },
    key = {'uid','pid','lv','pos'},
    ops_conditon = {
        sel = {
            select_star = {'uid'}
        },
        update = {
            {'uid','pid','lv','pos'},
        },
    }
}

db_gang_t = 
{
    db = {
        ggid = 'int32_t',
        hostnum = 'int32_t',
        level = 'int32_t',
        exp = 'int32_t',
        name = 'ystring_t<30>',
        notice = 'ystring_t<100>',
        bossday = 'int32_t',
        bosslv = 'int32_t',
        bosscount = 'int32_t',
        todaycount = 'int32_t',
        lastboss = 'int32_t',
    },
    key = {'ggid', 'hostnum'},
    ops_conditon = {
        sel = {
            select_gang = {'ggid', 'hostnum'},
            select_ganginfo = {'ggid'},
            select_host_gang = {'hostnum'}
        },
        update = {
            {'ggid', 'hostnum'},
        },
        del = {
            {'ggid', 'hostnum'},
        },
    }
}

db_compensate_t =
{
    db = {
        id = 'uint32_t',
        uid = 'uint32_t',
        resid = 'uint32_t',
        count = 'uint32_t',
        state = 'int32_t',
        givenstamp = 'uint32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_compensate = {'uid','state'},
        },
        update = {
            {'id'},
        },
    }
}

db_ganguser_t = 
{
    db = {
        uid = 'int32_t',
        ggid = 'int32_t',
        hostnum = 'int32_t',
        flag = 'int32_t',
        gm = 'int32_t',
        totalgm = 'int32_t',
        nickname = 'ystring_t<30>',
        grade = 'int32_t',
        rank= 'int32_t',
        lastquit = 'uint32_t',
        lastenter = 'uint32_t',
        todaycount = 'uint32_t',
        bossrewardcount = 'uint32_t',
        bossrewardtime = 'uint32_t',
        lastboss = 'uint32_t',
        state = 'int32_t',
        skl1 = 'int32_t',
        skl2 = 'int32_t',
        skl3 = 'int32_t',
        skl4 = 'int32_t',
        skl5 = 'int32_t',
        skl6 = 'int32_t',
        skl7 = 'int32_t',
        skl8 = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_ganguser = {'hostnum'}
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    }
}

db_pay_t = 
{
    db={
        serid = 'int32_t',
        sid = 'int32_t',
        uid = 'int32_t',
        appid = 'ystring_t<32>',
        uin = 'ystring_t<32>',
        domain = 'ystring_t<10>',
        goodsid = 'int32_t',
        goodnum = 'int32_t',
        cristal = 'int32_t',
        reward_cristal = 'int32_t',
        repo_rmb = 'int32_t',
        pay_rmb = 'int32_t',
        paytime = 'ystring_t<32>',
        giventime = 'ystring_t<32>',
        state = 'int32_t',
    },
    key = {'serid','sid', 'uid','appid','uin','plat','goodsid','goodnum'},
    ops_conditon = {
        sel = {
            select_serid = {'serid'},
            select_uid_state = {'uid','state'},
        },
        update = {
            {'serid'},
        },
    },
    db_service="dbgl_service"
}

db_roundstarreward_t=
{
    db={
        uid = 'int32_t',
        rpid = 'int',
        r1 =  'int',
        r2 =  'int',
        r3 =  'int',
        r4 =  'int',
    },
    key = {'uid', 'rpid'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid', 'rpid'},
        },
    }
}

db_mail_t={
    db={
        uid = 'int32_t',
        info= 'ystring_t<500>',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
    }
}

db_host_t={
    db={
        id='int',
        hostnum='int',
        platname='string',
        jstr='string',
        state='int',
        stoptm='uint32_t',
    },
    key={'id'},
    ops_conditon = {
        sel = {
            select = {'hostnum', 'platname'},
        }
    }
}

db_vip_t={
    db={
        uid = 'int32_t',
        vop = 'int32_t',
        num = 'int32_t',
        stamp = 'uint32_t',
    },
    key = {'uid', 'vop'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid', 'vop'},
        },
    }
}

db_arena_t={
    db={
        uid = 'int32_t',
        fight_count = 'int32_t',
        in_fight_count = 'int32_t',
        n_buy = 'int32_t',
        in_buy = 'int32_t',
        win_count = 'int32_t',
        target_id = 'int32_t',
        stamp = 'uint32_t',
        in_stamp = 'uint32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_activity_t={
    db={
        uid = 'int32_t',
        hostnum = 'int32_t',
        nickname = 'ystring_t<30>',
        grade = 'int32_t',
        cumu_yb_rank_exp = 'int32_t',
        cumu_yb_rank = 'int32_t',
        cumu_yb_rank_stamp = 'uint32_t',
        con_wing_stamp='uint32_t',
        con_wing_score='int32_t',
        con_wing_rank='int32_t',
        con_wing_given='int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_gmail_t={
    db={
        uid = 'int32_t',
        mid = 'int32_t',
        resid = 'int32_t',
        flag = 'int32_t',
        opened = 'int32_t',
        rewarded = 'int32_t',
        item1 = 'int32_t',
        count1 = 'int32_t',
        item2 = 'int32_t',
        count2 = 'int32_t',
        item3 = 'int32_t',
        count3 = 'int32_t',
        item4 = 'int32_t',
        count4 = 'int32_t',
        item5 = 'int32_t',
        count5 = 'int32_t',
        title = 'ystring_t<64>',
        sender = 'ystring_t<64>',
        info = 'ystring_t<256>',
        stamp = 'uint32_t',
        validtime = 'int32_t',
    },
    key = {'uid', 'mid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
            select_mid = {'mid'},
        },
        update = {
            {'uid', 'mid'},
        },
        del = {
            {'uid', 'mid'},
        },
    }
}

db_actdaliytask_t={
    db={
        uid = 'int32_t',
        resid = 'int32_t',
        step = 'int32_t',
        collect = 'int32_t',
        stamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
        del = {
            {'uid', 'resid'},
        },
    }
}

db_achievement_t={
    db={
        uid = 'int32_t',
        resid = 'int32_t',
        systype = 'int32_t',
        tasktype = 'int32_t',
        step = 'int32_t',
        collect = 'int32_t',
        stamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
        del = {
            {'uid', 'resid'},
        },
    }
}


db_wing_t = {
    db = {
        uid = 'int32_t',
        wid = 'int32_t',
        resid = 'int32_t',
        isweared = 'int32_t', 
        atk = 'int32_t', 
        mgc = 'int32_t', 
        def = 'int32_t', 
        res = 'int32_t', 
        hp = 'int32_t', 
        crit = 'int32_t', 
        acc = 'int32_t', 
        dodge = 'int32_t', 
        lucky = 'int32_t',
    },
    key = {'wid', 'uid'},
    --autokey = {'eid'},
    ops_conditon = {
        sel = {
            select_wing_all = {'uid'},
        },
        update = {
            {'uid', 'wid'},
        },
        del = {
            {'uid', 'wid'},
        },
    }
}

db_pet_t = {
    db = {
        uid = 'int32_t',
        petid = 'int32_t',
        resid = 'int32_t',
        atk = 'int32_t',
        mgc = 'int32_t',
        def = 'int32_t',
        res = 'int32_t',
        hp = 'int32_t',
    },
    key = {'uid', 'petid'},
    ops_conditon = {
        sel = {
            select_pet = {'uid'},
        },
        update = {
            {'uid', 'petid'},
        },
        del = {
            {'uid', 'petid'},
        },
    },
}

db_combo_pro_t = {
    db = {
        uid = 'int32_t',
        o1 = 'int32_t',
        o2 = 'int32_t',
        o3 = 'int32_t',
        o4 = 'int32_t',
        o5 = 'int32_t',
        exp1 = 'int32_t',
        exp2 = 'int32_t',
        exp3 = 'int32_t',
        exp4 = 'int32_t',
        exp5 = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid'},
        },
        del = {
            {'uid'},
        },
    },
}

db_lovetask_t = {
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        resid = 'int32_t',
        step = 'int32_t',
        state = 'int32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_love_task_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}

db_npcshop_t = {
    db = {
        uid = 'int32_t',
        item1 = 'int32_t',
        item2 = 'int32_t',
        item3 = 'int32_t',
        item4 = 'int32_t',
        item5 = 'int32_t',
        item6 = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_npcshop = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_spshop_t = {
    db = {
        uid = 'int32_t',
        item1 = 'int32_t',
        item2 = 'int32_t',
        item3 = 'int32_t',
        item4 = 'int32_t',
        item5 = 'int32_t',
        item6 = 'int32_t',
        item7 = 'int32_t',
        item8 = 'int32_t',
        item9 = 'int32_t',
        item10 = 'int32_t',
        item11 = 'int32_t',
        item12 = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_spshop = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_arenainfo_t = {
    db = {
        hostnum = 'int32_t',
        uid = 'int32_t',
        level = 'int32_t',
        total_fp = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
    },
    key = {'hostnum', 'uid'},
    ops_conditon = {
        sel = {
            select_hostnum = {'hostnum'},
        },
        update = {
            {'hostnum', 'uid'},
        },
    }
}
db_prestigeshop_t = {
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}

db_unprestigeshop_t = {
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}

db_chipshop_t = {
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}
db_chipsmash_t = {
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}

db_chipvalue_t = {
    db = {
        id          = 'int32_t',
        hostnum     = 'int32_t',
        resid       = 'int32_t',
        price       = 'int32_t',
        cur_value   = 'int32_t',        
        trend       = 'int32_t',
    },
    key = {'id','hostnum'},
    ops_conditon = {
        sel = {
            select_all = {'hostnum'},
        },
        update = {
            {'id'},
        },    
    }
}

db_expedition_t = {
    db = {
        uid = 'int32_t',
        resid = 'int32_t',
        pid1 = 'int32_t',
        hp1 = 'float',
        pid2 = 'int32_t',
        hp2 = 'float',
        pid3 = 'int32_t',
        hp3 = 'float',
        pid4 = 'int32_t',
        hp4 = 'float',
        pid5 = 'int32_t',
        hp5 = 'float',
        view_data ='string',
        open_box = 'int32_t',
        refresh_type='int32_t',
        utime = 'int32_t',
        is_refresh_today = 'int32_t',
    },
    key = {'uid', 'resid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid', 'resid'},
        },
    }
}
db_treasure_t = {
    db = {
        uid = 'int32_t',
        reset_num = 'int32_t',
        utime = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_expedition_partners_t = {
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        hp = 'float',
    },
    key = {'uid', 'pid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid', 'pid'},
        },
    }
}
db_expedition_team_t = {
    db = {
        uid = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
        anger = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_expedition_shop_t = {
    db = {
        uid = 'int32_t',
        eshopindex = 'int32_t',
        eshopid = 'int32_t',
        count = 'int32_t',
        refresh_time = 'int32_t',
    },
    key = {'uid','eshopindex'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'eshopindex'},
        },
    }
}

db_gang_shop_t = {
    db = {
        uid = 'int32_t',
        gshopindex = 'int32_t',
        gshopid = 'int32_t',
        count = 'int32_t',
        refresh_time = 'int32_t',
    },
    key = {'uid','gshopindex'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'gshopindex'},
        },
    }
}

db_rune_shop_t = {
    db = {
        uid = 'int32_t',
        rshopindex = 'int32_t',
        rshopid = 'int32_t',
        count = 'int32_t',
        refresh_time = 'int32_t',
    },
    key = {'uid','rshopindex'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'rshopindex'},
        },
    }
}
db_card_event_round_t = {
    db = {
        eid = 'int32_t',
        round = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
        view_data = 'string',
    },
    key = {'eid', 'round'},
    ops_conditon = {
        sel = {
            select_all = {'eid'},
        },
        update = {
            {'eid', 'round'},
        },
    }
}
db_card_event_rank_t = {
    db = {
        uid = 'int32_t',
        rank = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'}
        },
        update = {
            {'uid'},
        },
    }
}
db_card_event_user_t = {
    db = {
        uid = 'int32_t',
        hostnum = 'int32_t',
        score = 'int32_t',
        coin = 'int32_t',
        goal_level = 'int32_t',
        round = 'int32_t',
        round_status = 'int32_t',
        round_max = 'int32_t',
        difficult = 'int32_t',
        reset_time = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
        anger = 'int32_t',
        enemy_view_data = 'string',
        hp1 = 'float',
        hp2 = 'float',
        hp3 = 'float',
        hp4 = 'float',
        hp5 = 'float',
        season = 'int32_t',
        open_times = 'int32_t',
        open_level = 'int32_t',
        next_count = 'int32_t',
        first_enter_time = 'int32_t'
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_card_event_team_t = {
    db = {
        uid = 'int32_t',
        pid1 = 'int32_t',
        pid2 = 'int32_t',
        pid3 = 'int32_t',
        pid4 = 'int32_t',
        pid5 = 'int32_t',
        anger = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}
db_card_event_user_partner_t = {
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        hp = 'float',
    },
    key = {'uid', 'pid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid', 'pid'},
        },
    }
}

db_rank_t = {
    db = {
        id = 'int32_t',
        hostnum = 'int32_t',
        rankindex = 'int32_t',
        ranknum = 'int32_t',
        uid = 'int32_t',
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select_id = {'id'},
        },
        update = {
            {'id'},
        },
    
    }

}

db_soul_t = {
    db = {
        uid = 'int32_t',
        soul_id = 'int32_t',
        level = 'int32_t',
        time = 'int32_t',
        rare = 'int32_t',
        state = 'int32_t',
        gem_need = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_chat_t = {
    db = {

        id          = 'int32_t',
        hostnum     = 'int32_t',
        suid        = 'int32_t',
        resid       = 'int32_t',
        quality     = 'int32_t',
        grade       = 'int32_t',
        vip         = 'int32_t',
        name        = 'string',
        typeindex   = 'int32_t',
        msg         = 'string',    
    },
    key = {'id'},
    ops_conditon = {
        sel = {
            select_id = {'id'},
        },
    },  
}

db_rank_season_t = {
    db = {
        uid          = 'int32_t',
        rank         = 'int32_t',
        score        = 'int32_t',
        season       = 'int32_t',
        successive_defeat = 'int32_t',
        max_rank     = 'int32_t',
        last_fight_stamp = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_rank_match_t = {
    db = {
        uid          = 'int32_t',
        req_times    = 'int32_t',
        stamp        = 'int32_t',
        rank_type    = 'int32_t',
        hostnum      = 'int32_t',
        view_data    = 'string',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_card_comment_t = {
    db = {
        id          = 'int32_t',
        resid       = 'int32_t',
        uid         = 'int32_t',
        viplevel    = 'int32_t',
        grade       = 'int32_t',
        equiprank   = 'int32_t',
        isshow      = 'int32_t',
        praisenum   = 'int32_t',
        name        = 'string',
        comment     = 'string',
        stamp       = 'int32_t',
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select_id = {'id'},
        },
        update = {
            {'id'},
        },
    },
    db_service = "dbgl_service",
}

db_card_comment_praise_t = {
    db = {
        commentid       = 'int32_t',
        praiseuid       = 'int32_t',
        stamp           = 'int32_t',
    },
    key = {'commentid', 'praiseuid'},
    ops_conditon = {
        select_detail = {'commentid', 'praiseuid'},
    },
    update = {
        {'commentid', 'praiseuid'},
    },
    db_service = "dbgl_service",
}

db_souluser = {
    db = {
        uid         = 'int32_t',
        hostnum     = 'int32_t',
        soulmoney   = 'int32_t',
        soullevel   = 'int32_t',
        soulid      = 'int32_t',
        ctime       = 'ystring_t<30>',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_id = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}

db_gbattle_defence_t = {
    db = {
        ggid        = 'int32_t',
        building_id  = 'int32_t',
        building_pos= 'int32_t',
        uid         = 'int32_t',
        hp1         = 'float',
        hp2         = 'float',
        hp3         = 'float',
        hp4         = 'float',
        hp5         = 'float',
        pid1        = 'int32_t',
        pid2        = 'int32_t',
        pid3        = 'int32_t',
        pid4        = 'int32_t',
        pid5        = 'int32_t',
        view_data   = 'string',
    },
    key = {'ggid', 'building_id', 'building_pos'},
    ops_conditon = {
        sel = {
            select_info = {'ggid', 'building_id', 'building_pos'},
        },
        update = {
            {'ggid', 'building_id', 'building_pos'},
        },
    }
}

db_gbattle_partner_t = {
    db = {
        uid = 'int32_t',
        pid = 'int32_t',
        hp = 'float',
    },
    key = {'uid', 'pid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid', 'pid'},
        },
    }
}

db_gem_page_t = {
    db = {
        uid = 'int32_t',
        pageid = 'int32_t',
        gemtype = 'int32_t',
        slotid = 'int32_t',
        resid = 'int32_t',
    },
    key = {'uid', 'pageid', 'gemtype', 'slotid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid', 'pageid', 'gemtype', 'slotid'},
        },
    }
}

db_farm = {
    db = {
        uid         = 'int32_t',
        farmid      = 'int32_t',
        itemid      = 'int32_t',
        getnum      = 'int32_t',
        isend       = 'int32_t',
        getstamp    = 'int32_t',
        losetime    = 'int32_t',
        canrob      = 'int32_t',
        cstamp      = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_id = {'uid'},
        },
        update = {
            {'uid'},
        },

    }
}

db_plantshop_t = {
    db = {
        uid = 'int32_t',
        plantid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'plantid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'plantid'},
        },
    }
}

db_inventoryshop_t = {
    db = {
        uid = 'int32_t',
        shopid = 'int32_t',
        count = 'int32_t',
        buystamp = 'uint32_t',
    },
    key = {'uid', 'shopid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'shopid'},
        },
    }
}
db_limitround_t = {
    db = {
        uid = 'int32_t',    
        lasttime = 'int32_t',
        reset_times = 'int32_t'
    }, 
    key = {'uid'}, 
    ops_conditon = {
        sel = {
            select_uid = {'uid'},     
        },     
        update = {
            {'uid'},     
        },
    },
    
}
db_treasureconqueror_t = {
    db = {
        uid = 'int32_t',     
        hostnum = 'int32_t',
        slot_pos = 'int32_t',
        last_round = 'int32_t',
        debian_secs = 'int32_t',
        last_stamp = 'int32_t',
        n_rob = 'int32_t',
        profit = 'int32_t',
    },    
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},     
        },     
        update = {
            {'uid'},     
        },
    },
}
db_treasurecoopertive_t = {
    db = {
        uid = 'int32_t',     
        hostnum = 'int32_t',
        slot_pos = 'int32_t',
        last_round = 'int32_t',
        debian_secs = 'int32_t',
        last_stamp = 'int32_t',
        n_help = 'int32_t',
        profit = 'int32_t',
    },    
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},     
        },     
        update = {
            {'uid'},     
        },
    },
}
db_treasureslot_t = {
    db = {
        id = 'int32_t',     
        hostnum = 'int32_t',
        slot_type = 'int32_t',
        slot_pos = 'int32_t',
        uid = 'int32_t',
        resid = 'int32_t',
        nickname = 'string',
        fp = 'int32_t',
        grade = 'int32_t',
        stamp = 'int32_t',
        n_rob = 'int32_t',
        rob_money = 'int32_t',
        robers = 'string',
        lovelevel = 'int32_t',
        is_pvp_fighting = 'int32_t',
        begin_pvp_fight_time = 'int32_t',
    },    
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select = {'hostnum','slot_type','slot_pos'},     
        },     
        update = {
            {'hostnum','slot_type','slot_pos'},        
        },
    },
}

db_gangboss_t = {
    db = {
        ggid = 'int32_t',
        m_spawned = 'int32_t',
        m_spawne_time = 'int32_t',
        m_resid = 'int32_t',
        m_grade = 'int32_t',
        m_hp = 'int32_t',
        m_max_hp = 'int32_t',
        is_event = 'int32_t',
        m_damage = 'int32_t',
        top_cut = 'int32_t',
        m_cur_count = 'int32_t',
        m_join_count = 'int32_t',
        is_join_reward = 'int32_t',
        reward_send = 'int32_t',
        m_start = 'int32_t',
        m_end = 'int32_t',
        m_prepare = 'int32_t',
        top = 'string',
    },
    key = {'ggid'},
    ops_conditon = {
        sel = {
            select_ggid = {'ggid'},
        },
        update = {
            {'ggid'},     
        },
    },
}
db_gangbossdamage_t = {
    db = {
        uid = 'int32_t',
        ggid = 'int32_t',
        in_scene = 'int32_t',
        damage = 'int32_t',
        last_batt_time = 'int32_t',
        old_scene = 'int32_t',
        nickname = 'ystring_t<30>',
        lv = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
           select_ggid = {'ggid'},
        },
        update = {
            {'uid'},
        },
    },
}
db_gangbossguwu_t = {
    db = {
        uid = 'int32_t',
        v = 'float',
        progress = 'int32_t',
        stamp_v = 'int32_t',
        stamp_yb = 'int32_t',
        stamp_coin = 'int32_t',
    },
    key = {'uid'},
    ops_conditon = {
        sel = {
            select_uid = {'uid'},
        },
        update = {
            {'uid'},
        },
    },
}

db_report_t = {
    db = {
        id = 'int32_t',
        uid = 'int32_t',
        reportuid = 'int32_t',    
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select = {'uid','reportuid'},
        },
        update = {
            {'uid', 'reportuid'},
        },
    },
}

db_reportuser_t = {
    db = {
        uid = 'int32_t',
        reportNum = 'int32_t',
        accusedNum = 'int32_t',
        reportTime = 'int32_t',
    },
    key = {'uid'},
    ops_conditon ={
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid'},
        },
    },
}

db_PubMgr_t = {
    db = {
        uid = 'int32_t',
        pub_3_first = 'int32_t',
        pub_4_first = 'int32_t',
        pub_sum = 'int32_t',
        stepup_state = 'int32_t',
        event_state = 'int32_t',
    },
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid'},
        },
    },
}

db_feedbackFlag_t = {
    db = {
        id = 'int32_t',
        uid = 'int32_t',
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select = {'uid'},
        },
        update = {
            {'uid'},
        },
    },
}
db_private_chat_t = {
    db = {
        id          = 'int32_t',
        hostnum     = 'int32_t',
        suid        = 'int32_t',
        acuid       = 'int32_t',
        resid       = 'int32_t',
        quality     = 'int32_t',
        grade       = 'int32_t',
        vip         = 'int32_t',
        name        = 'string',
        typeindex   = 'int32_t',
        msg         = 'string',    
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select_all = {'suid','acuid'},
        },
        del = {
            {'suid','acuid'},    
        },
    },  
}


db_CardEvent_Shop_t = {
    db = {
        uid = 'int32_t',
        shopindex = 'int32_t',
        shopid = 'int32_t',
        count = 'int32_t',
        refresh_time = 'uint32_t',
    },
    key = {'uid', 'shopid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'shopid'},
        },
    }
}

db_Lmt_Shop_t = {
    db = {
        uid = 'int32_t',
        shopindex = 'int32_t',
        shopid = 'int32_t',
        count = 'int32_t',
        refresh_time = 'uint32_t',
    },
    key = {'uid', 'shopid'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid', 'shopid'},
        },
    }
}
db_ChatUser_t = {
    db = {
        id = 'int32_t',
        uid = 'int32_t',
        player_uid = 'int32_t',
        stmp = 'int32_t'
    },
    autokey = {'id'},
    ops_conditon = {
        sel = {
            select_all = {'uid'},
        },
        update = {
            {'uid'},
        },
    }
}


--@end

dbs = {}
dbs['Account'] = db_account_t
dbs['UserID'] = db_userid_t
dbs['Cdkey'] = db_cdkey_t
dbs['UserInfo'] = db_userinfo_t
dbs['NewRole'] = db_newrole_t
dbs['BuyLog'] = db_buylog_t
dbs['FpException'] = db_fpexception_t
dbs['NewAccount'] = db_newaccount_t
dbs['YBLog'] = db_yblog_t
dbs['EventLog'] = db_eventlog_t
dbs['ConsumeLog'] = db_consumelog_t
dbs['QuitLog'] = db_quitlog_t
dbs['CardEventUserLog'] = db_card_event_user_log_t
dbs['Online'] = db_online_t
dbs['Partner'] = db_partner_t 
dbs['PartnerChip'] = db_partnerchip_t 
dbs['Item'] = db_item_t 
dbs['Equip'] = db_equip_t 
dbs['Skill'] = db_skill_t
dbs['Team'] = db_team_t 
dbs['UserData'] = db_userdata_t 
dbs['Server'] = db_server_t
dbs['Reward'] = db_reward_t
dbs['RewardExtentionI'] = db_reward_extentioni_t
dbs['Task'] = db_task_t
dbs['Chronicle'] = db_chronicle_t
dbs['Shop'] = db_shop_t
dbs['Friend'] = db_friend_t
dbs['FriendFlower'] = db_friend_flower_t
dbs['Rune'] = db_rune_t
dbs['RuneInfo'] = db_rune_info_t
dbs['RuneItem'] = db_rune_item_t
dbs['RunePage'] = db_rune_page_t
dbs['Star'] = db_star_t
dbs['Gang'] = db_gang_t
dbs['GangUser'] = db_ganguser_t
dbs['Compensate'] = db_compensate_t
dbs['Pay'] = db_pay_t
dbs['RoundStarReward'] = db_roundstarreward_t
dbs['Mail'] = db_mail_t 
dbs['Host'] = db_host_t
dbs['Vip']=db_vip_t
dbs['Arena']=db_arena_t
dbs['Activity']=db_activity_t
dbs['GMail']=db_gmail_t
dbs['ActDailyTask']=db_actdaliytask_t
dbs['Achievement'] = db_achievement_t
dbs['Wing']=db_wing_t
dbs['Pet']=db_pet_t
dbs['Bullet']=db_bullet_t
dbs['LoveTask'] = db_lovetask_t
dbs['NpcShop'] = db_npcshop_t
dbs['SpShop'] = db_spshop_t
dbs['ArenaInfo'] = db_arenainfo_t
dbs['PrestigeShop'] = db_prestigeshop_t
dbs['UnPrestigeShop'] = db_unprestigeshop_t
dbs['ChipShop'] = db_chipshop_t
dbs['ChipSmash'] = db_chipsmash_t
dbs['ChipValue'] = db_chipvalue_t
dbs['Expedition'] = db_expedition_t
dbs['ExpeditionPartners'] = db_expedition_partners_t
dbs['ExpeditionTeam'] = db_expedition_team_t
dbs['ExpeditionShop'] = db_expedition_shop_t
dbs['GangShop'] = db_gang_shop_t
dbs['RuneShop'] = db_rune_shop_t
dbs['Treasure'] = db_treasure_t
dbs['CardEventRound'] = db_card_event_round_t
dbs['CardEventRank'] = db_card_event_rank_t
dbs['CardEventUser'] = db_card_event_user_t
dbs['CardEventTeam'] = db_card_event_team_t
dbs['CardEventUserPartner'] = db_card_event_user_partner_t
dbs['Rank'] = db_rank_t
dbs['Chat'] = db_chat_t
dbs['Soul'] = db_soul_t
dbs['RankSeason'] = db_rank_season_t
dbs['RankMatch'] = db_rank_match_t
dbs['CardComment'] = db_card_comment_t
dbs['CardCommentPraise'] = db_card_comment_praise_t
dbs['SoulUser'] = db_souluser
dbs['GuildBattleDefenceInfo'] = db_gbattle_defence_t
dbs['GuildBattlePartner'] = db_gbattle_partner_t
dbs['GemPage'] = db_gem_page_t
dbs['HomeFarm'] = db_farm
dbs['PlantShop'] = db_plantshop_t
dbs['InventoryShop'] = db_inventoryshop_t
dbs['LimitRound'] = db_limitround_t
dbs['TreasureConqueror'] = db_treasureconqueror_t
dbs['TreasureCoopertive'] = db_treasurecoopertive_t
dbs['TreasureSlot'] = db_treasureslot_t
dbs['ComboPro'] = db_combo_pro_t
dbs['GangBoss'] = db_gangboss_t
dbs['GangBossDamage'] = db_gangbossdamage_t 
dbs['GangBossGuwu'] = db_gangbossguwu_t
dbs['Report'] = db_report_t
dbs['ReportUser'] = db_reportuser_t
dbs['FeedbackFlag'] = db_feedbackFlag_t
dbs['PubMgr'] = db_PubMgr_t
dbs['CardEventShop'] = db_CardEvent_Shop_t
dbs['LmtShop'] = db_Lmt_Shop_t
dbs['PrivateChat'] = db_private_chat_t
dbs['ChatUser'] = db_ChatUser_t;
--==============================================================

function gen()
    local h_file = io.open('db_def.h', 'w') 
    local seg = {}
    table.insert(seg, '#ifndef _db_def_h_\n')
    table.insert(seg, '#define _db_def_h_\n')
    table.insert(seg, '#include <stdint.h>\n')
    table.insert(seg, '#include <sstream>\n')
    table.insert(seg, 'using namespace std;\n')
    table.insert(seg, '#include \"sql_result.h\"\n')
    table.insert(seg, '#include \"db_helper.h\"\n')
    table.insert(seg, '#include \"dbgl_service.h\"\n')
    table.insert(seg, '#include \"db_service.h\"\n')
    table.insert(seg, '#include \"ystring.h\"\n')
    for k, v in pairs(dbs) do
        if v.key ~= nil then
            for _, kn in pairs(v.key) do
                v.key[kn] = kn
            end
        end
        --[
        if v.autokey ~= nil then
            for _, kn in pairs(v.autokey) do
                v.autokey[kn] = kn
            end
        end
        --]]
        table.insert(seg, gen_db_dec(k, v))
    end
    table.insert(seg, '#endif\n')
    h_file:write(table.concat(seg))
    h_file:close()
    
    local cpp_file = io.open('db_def.cpp', 'w')
    seg = {}
    table.insert(seg, '#include \"db_def.h\"\n')
    table.insert(seg, '#include \"db_service.h\"\n')
    for k, v in pairs(dbs) do
        table.insert(seg, gen_db_impl(k, v))
    end
    cpp_file:write(table.concat(seg)) cpp_file:close() 
end

function gen_db_dec(name_, t_)
    local seg = {}

    table.insert(seg, 'struct db_'..name_..'_t {\n')
    local mem_array = {} 
    for k,v in pairs(t_.db) do
        if v == 'timedate' then
            v = 'int'
        end
        table.insert(mem_array, v..' '..k)
    end
    table.insert(seg, table.concat(mem_array, ';\n')..';\n')

    table.insert(seg, string.format('static const char* tablename(){ return \"%s\"; }\n', name_))

    table.insert(seg, 'int init(sql_result_row_t& row_);\n')
    if t_.ops_conditon.sel ~= nil then
        table.insert(seg, gen_db_select_dec(name_, t_)..'\n')
        table.insert(seg, gen_db_sync_select_dec(name_, t_)..'\n')
    end
    if t_.ops_conditon.update ~= nil then
        table.insert(seg, 'int update();\n')
        table.insert(seg, 'int sync_update();\n')
    end
    if t_.ops_conditon.del ~= nil then
        table.insert(seg, 'int remove();\n')
    end
    table.insert(seg, 'int insert();\n')
    table.insert(seg, 'string gen_insert_sql();\n')
    table.insert(seg, 'int sync_insert();\n')
    --table.insert(seg, 'static int new_id();\n')
    --table.insert(seg, gen_db_json_dec(name_, t_))
    table.insert(seg, '};\n')
    return table.concat(seg)
end

function gen_db_impl(name_, t_)
    local seg = {}
    table.insert(seg, gen_db_init_impl(name_, t_))

    if t_.ops_conditon.sel ~= nil then
        table.insert(seg, gen_db_select_impl(name_, t_))
        table.insert(seg, gen_db_sync_select_impl(name_, t_))
    end
    if t_.ops_conditon.update ~= nil then
        table.insert(seg, gen_db_update_impl(name_, t_))
        table.insert(seg, gen_db_sync_update_impl(name_, t_))
    end
    if t_.ops_conditon.del ~= nil then
        table.insert(seg, gen_db_remove_impl(name_, t_))
    end

    table.insert(seg, gen_db_insert_sql_impl(name_, t_))
    table.insert(seg, gen_db_insert_impl(name_, t_))
    table.insert(seg, gen_db_sync_insert_impl(name_, t_))
    return table.concat(seg)
end

function gen_db_select_dec(name_, t_)
    local selmethods = {}
    if t_.ops_conditon.sel == nil then
        return
    end
    for k,v in pairs(t_.ops_conditon.sel) do
        local params = {}
        local begin_str = 'static int select(';
        if type(k) == 'string' then
            begin_str = 'static int '..k..'(';
        end
        for _, vv  in pairs(v) do
            local dec_type
            local dec_par
            if (vv == '@condition') then
                dec_type = "const char*"
                dec_par = "condition_"
            else
                dec_type = t_.db[vv]
                if dec_type == 'timedate' then
                    dec_type = 'int'
                end
                dec_type = 'const '..dec_type..'&'
                dec_par = vv..'_'
            end
            table.insert(params, dec_type..' '..dec_par)
        end
        table.insert(params, 'sql_result_t &res_')
        local param_str = table.concat(params, ', ')
        local end_str = ');'
        table.insert(selmethods, begin_str..param_str..end_str)
    end
    return table.concat(selmethods, '\n')
end

function gen_db_sync_select_dec(name_, t_)
    local selmethods = {}
    if t_.ops_conditon.sel == nil then
        return
    end
    for k,v in pairs(t_.ops_conditon.sel) do
        local params = {}
        local begin_str = 'static int sync_select(';
        if type(k) == 'string' then
            begin_str = 'static int sync_'..k..'(';
        end
        for _, vv  in pairs(v) do
            local dec_type
            local dec_par
            if (vv == '@condition') then
                dec_type = "const char*"
                dec_par = "condition_"
            else
                dec_type = t_.db[vv]
                if dec_type == 'timedate' then
                    dec_type = 'int'
                end
                dec_type = 'const '..dec_type..'&'
                dec_par = vv..'_'
            end
            table.insert(params, dec_type..' '..dec_par)
        end
        table.insert(params, 'sql_result_t &res_')
        local param_str = table.concat(params, ', ')
        local end_str = ');'
        table.insert(selmethods, begin_str..param_str..end_str)
    end
    return table.concat(selmethods, '\n')
end

function gen_db_json_dec(name_, t_)
    local seg ={}
    local n =0
    for k,v in pairs(t_.db) do
        table.insert(seg, k)
        n = n+1
    end
    local mem_dec = table.concat(seg, ', ')
    return 'JSON'..n..'(db_'..name_..'_t, '..mem_dec..');\n'
end

function gen_db_init_impl(name_, t_)
    local head = 'int db_'..name_..'_t::init(sql_result_row_t& row_){\
    if (row_.empty())\
    {\
        return -1;\
    }\
    size_t i=0;'
    
    local seg = {}
    for k, v in pairs(t_.db) do
        if string.find(v,'ystring_t') ~= nil then
            local c = k..' = row_[i++];\n'
            table.insert(seg, c)
        elseif string.find(v,'string') ~= nil then
            local c = k..' = row_[i++];\n'
            table.insert(seg, c)
        elseif value == 'uint64_t' then
            local c = 'stringstream stream;\n stream << row_[i++]; stream >> '..k..'; stream.clear();\n'
            table.insert(seg, c)
        elseif value == 'uint32_t' then
            local c = k..'=(uint32_t)std::atoi(row_[i++].c_str());\n'
            table.insert(seg, c)
        elseif string.find(v, 'float') ~= nil then
            local c = k..'=(float)std::atof(row_[i++].c_str());\n'
            table.insert(seg, c)
        else
            local c = k..'=(int)std::atoi(row_[i++].c_str());\n'
            table.insert(seg, c)
        end
    end

    return head..table.concat(seg)..'return 0;\n}\n'
end

function gen_db_select_impl(name_, t_)
    local codes = {}
    if t_.ops_conditon.sel == nil then
        return
    end
    for k,v in pairs(t_.ops_conditon.sel) do

        local params = {}
        local begin_str = 'int db_'..name_..'_t::select(';
        if type(k) == 'string' then
            begin_str = 'int db_'..name_..'_t::'..k..'(';
        end
        for _, vv  in pairs(v) do
            local dec_type
            local dec_par
            if (vv == '@condition') then
                dec_type = "const char*";
                dec_par = "condition_";
            else
                dec_type = 'const '..t_.db[vv]..'&'
                dec_par = vv..'_'
            end
            table.insert(params, dec_type..' '..dec_par)
        end
        table.insert(params, 'sql_result_t &res_')
        local param_str = table.concat(params, ', ')
        local end_str = '){\n'

        local head = begin_str..param_str..end_str

        --生成条件语句
        local condition_str = gen_condition( t_.db, v )
        local columns_str = gen_columns(t_.db)
        local sql = "\"SELECT " .. columns_str .. " FROM `" .. name_ .. "` WHERE " .. condition_str..'\"'
        local seg = {}
        table.insert(seg, 'char buf[4096];\nsprintf(buf')
        table.insert(seg, sql)
        for _, vv in pairs(v) do 
            if vv=='@condition' then
                table.insert(seg, 'condition_')
            elseif string.find(t_.db[vv], 'ystring_t')  then 
                table.insert(seg, vv..'_.c_str()')
            elseif string.find(t_.db[vv], 'string')  then 
                table.insert(seg, vv..'_.c_str()')
            else
                table.insert(seg, vv..'_')
            end
        end
        local code = table.concat(seg, ', ')
        code = code..');\n'

        local dbser = "db_service"
        if t_.db_service ~= nil then
            dbser = t_.db_service
        end

        code = code .. dbser..'.async_select(buf, res_);\
        sql_result_row_t* row = res_.get_row_at(0); \
        if (row != NULL)\
        {\
            return 0;\
        }\
        return -1;'

        code = head..code..'\n}\n'
        table.insert(codes, code)
    end
    return table.concat(codes)
end

function gen_db_sync_select_impl(name_, t_)
    local codes = {}
    if t_.ops_conditon.sel == nil then
        return
    end
    for k,v in pairs(t_.ops_conditon.sel) do

        local params = {}
        local begin_str = 'int db_'..name_..'_t::sync_select(';
        if type(k) == 'string' then
            begin_str = 'int db_'..name_..'_t::sync_'..k..'(';
        end
        for _, vv  in pairs(v) do
            local dec_type
            local dec_par
            if (vv == '@condition') then
                dec_type = "const char*";
                dec_par = "condition_";
            else
                dec_type = 'const '..t_.db[vv]..'&'
                dec_par = vv..'_'
            end
            table.insert(params, dec_type..' '..dec_par)
        end
        table.insert(params, 'sql_result_t &res_')
        local param_str = table.concat(params, ', ')
        local end_str = '){\n'

        local head = begin_str..param_str..end_str

        --生成条件语句
        local condition_str = gen_condition( t_.db, v )
        local columns_str = gen_columns(t_.db)
        local sql = "\"SELECT " .. columns_str .. " FROM `" .. name_ .. "` WHERE " .. condition_str..'\"'
        local seg = {}
        table.insert(seg, 'char buf[4096];\nsprintf(buf')
        table.insert(seg, sql)
        for _, vv in pairs(v) do 
            if vv=='@condition' then
                table.insert(seg, 'condition_')
            elseif string.find(t_.db[vv], 'ystring_t')  then 
                table.insert(seg, vv..'_.c_str()')
            elseif string.find(t_.db[vv], 'string')  then 
                table.insert(seg, vv..'_.c_str()')
            else
                table.insert(seg, vv..'_')
            end
        end
        local code = table.concat(seg, ', ')
        code = code..');\n'

        local dbser = "db_service"
        if t_.db_service ~= nil then
            dbser = t_.db_service
        end

        code = code .. dbser ..'.sync_select(buf, res_);\
        sql_result_row_t* row = res_.get_row_at(0); \
        if (row != NULL)\
        {\
            return 0;\
        }\
        return -1;'

        code = head..code..'\n}\n'
        table.insert(codes, code)
    end
    return table.concat(codes)
end

function gen_db_insert_sql_impl(name_, t_)
    --生成数据插入语句
    local data_arr = {}
    local data_cols_name = {}
    local data_cols_val = {}
    for k, v in pairs( t_.db ) do
        if t_.autokey == nil or t_.autokey[k] == nil then
            table.insert( data_cols_name , ' `' .. k.. '` ' )
            table.insert( data_cols_val , gen_value( v ) )
        end
    end
    local data_cols_name_str = table.concat( data_cols_name , ' , ' )
    local data_cols_val_str = table.concat( data_cols_val, ' , ' )

    local sql = "\"INSERT INTO `" .. name_.. "` (" .. data_cols_name_str .. ") VALUES ( " .. data_cols_val_str .. " )\" "


    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for k, v in pairs(t_.db) do 
        if t_.autokey == nil or t_.autokey[k] == nil then
            if string.find(v, 'ystring_t')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            elseif string.find(v, 'string')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            else
                table.insert(seg, k)
            end
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    code = 'string db_'..name_..'_t::gen_insert_sql(){\n'..code .. 'return string(buf);\n}\n'
    return code
end

function gen_db_insert_impl(name_, t_)
    --生成数据插入语句
    local data_arr = {}
    local data_cols_name = {}
    local data_cols_val = {}
    for k, v in pairs( t_.db ) do
        if t_.autokey == nil or t_.autokey[k] == nil then
            table.insert( data_cols_name , ' `' .. k.. '` ' )
            table.insert( data_cols_val , gen_value( v ) )
        end
    end
    local data_cols_name_str = table.concat( data_cols_name , ' , ' )
    local data_cols_val_str = table.concat( data_cols_val, ' , ' )

    local sql = "\"INSERT INTO `" .. name_.. "` (" .. data_cols_name_str .. ") VALUES ( " .. data_cols_val_str .. " )\" "


    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for k, v in pairs(t_.db) do 
        if t_.autokey == nil or t_.autokey[k] == nil then
            if string.find(v, 'ystring_t')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            elseif string.find(v, 'string')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            else
                table.insert(seg, k)
            end
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    local dbser = "db_service"
    if t_.db_service ~= nil then
        dbser = t_.db_service
    end

    code = 'int db_'..name_..'_t::insert(){\n'..code .. 'return '..dbser..'.async_execute(buf);\n}\n'
    return code
end

function gen_db_sync_insert_impl(name_, t_)
    --生成数据插入语句
    local data_arr = {}
    local data_cols_name = {}
    local data_cols_val = {}
    for k, v in pairs( t_.db ) do
        if t_.autokey == nil or t_.autokey[k] == nil then
            table.insert( data_cols_name , ' `' .. k.. '` ' )
            table.insert( data_cols_val , gen_value( v ) )
        end
    end
    local data_cols_name_str = table.concat( data_cols_name , ' , ' )
    local data_cols_val_str = table.concat( data_cols_val, ' , ' )

    local sql = "\"INSERT INTO `" .. name_.. "` (" .. data_cols_name_str .. ") VALUES ( " .. data_cols_val_str .. " )\" "


    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for k, v in pairs(t_.db) do 
        if t_.autokey == nil or t_.autokey[k] == nil then
            if string.find(v, 'ystring_t')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            elseif string.find(v, 'string')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            else
                table.insert(seg, k)
            end
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    local dbser = "db_service"
    if t_.db_service ~= nil then
        dbser = t_.db_service
    end
    code = 'int db_'..name_..'_t::sync_insert(){\n'..code .. 'return '..dbser..'.sync_execute(buf);\n}\n'
    return code
end

function gen_db_update_impl(name_, t_)
    if t_.ops_conditon.update  == nil then
        return
    end
    local cond = t_.ops_conditon.update[1]
    --生成条件语句
    local condition_str = gen_condition( t_.db, cond , t_.key)

    --生成数据更新语句
    local data_str = gen_data_string( t_.db, t_.key)

    local sql = "\"UPDATE `" .. name_.. "` SET " .. data_str .." WHERE " .. condition_str.."\""

    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for k, v in pairs(t_.db) do 
        if t_.key == nil or t_.key[k] == nil then
            if string.find(v, 'ystring_t')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            elseif string.find(v, 'string')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            else
                table.insert(seg, k)
            end
        end
    end
    for _, v in pairs(cond) do
        if string.find(t_.db[v], 'ystring_t')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        elseif string.find(t_.db[v], 'string')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        else
            table.insert(seg, v)
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    local dbser = "db_service"
    if t_.db_service ~= nil then
        dbser = t_.db_service
    end
    code = 'int db_'..name_..'_t::update(){\n'..code .. 'return '..dbser..'.async_execute(buf);\n}\n'
    return code
end

function gen_db_sync_update_impl(name_, t_)
    if t_.ops_conditon.update  == nil then
        return
    end
    local cond = t_.ops_conditon.update[1]
    --生成条件语句
    local condition_str = gen_condition( t_.db, cond, t_.key )

    --生成数据更新语句
    local data_str = gen_data_string( t_.db, t_.key)

    local sql = "\"UPDATE `" .. name_.. "` SET " .. data_str .." WHERE " .. condition_str.."\""

    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for k, v in pairs(t_.db) do 
        if t_.key == nil or t_.key[k] == nil then
            if string.find(v, 'ystring_t')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            elseif string.find(v, 'string')  ~= nil then 
                table.insert(seg, k..'.c_str()')
            else
                table.insert(seg, k)
            end
        end
    end
    for _, v in pairs(cond) do
        if string.find(t_.db[v], 'ystring_t')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        elseif string.find(t_.db[v], 'string')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        else
            table.insert(seg, v)
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    local dbser = "db_service"
    if t_.db_service ~= nil then
        dbser = t_.db_service
    end

    code = 'int db_'..name_..'_t::sync_update(){\n'..code .. 'return '..dbser..'.sync_execute(buf);\n}\n'
    return code
end

function gen_db_remove_impl(name_, t_)
    if t_.ops_conditon.del == nil then
        return
    end
    local cond = t_.ops_conditon.del[1]
    --生成条件语句
    local condition_str = gen_condition( t_.db, cond )

    local sql = "\"DELETE FROM `" .. name_.. "` WHERE " .. condition_str.."\""
    local seg = {}
    table.insert(seg, 'char buf[4096];\nsprintf(buf')
    table.insert(seg, sql)
    for _, v in pairs(cond) do
        if string.find(t_.db[v], 'ystring_t')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        elseif string.find(t_.db[v], 'string')  ~= nil then 
            table.insert(seg, v..'.c_str()')
        else
            table.insert(seg, v)
        end
    end
    local code = table.concat(seg, ', ')
    code = code..');\n'

    local dbser = "db_service"
    if t_.db_service ~= nil then
        dbser = t_.db_service 
    end

    code = 'int db_'..name_..'_t::remove(){\n'..code .. 'return '..dbser..'.async_execute(buf);\n}\n'
    return code
end

function gen_columns(db_)
    local colname = {}
    for k, v in pairs(db_) do
        table.insert( colname , '`' .. k .. '`' )
    end
    return table.concat( colname , ' , ' )
end

function gen_condition(db_, cond_, exclude_)
    --生成SQL条件部分
    local condition_arr = {}
    local condition_str = ''
    for _, v in pairs( cond_) do
        if (v == '@condition') then
            table.insert( condition_arr , '%s');
        else
        --if exclude_ == nil or exclude_[v] == nil then
            table.insert( condition_arr , ' `' .. v.. '`' .. " = " .. gen_value(db_[v] ) )
        --end
        end
    end
    --大于一个条件则需要使用AND连接
    if #condition_arr > 1 then
        condition_str = table.concat( condition_arr , ' AND ' )
    else
        condition_str = condition_arr[1]
    end

    return condition_str
end

function gen_data_string( data , exclude_)
    --生成SQL条件部分
    local data_arr = {}
    local data_str
    for key , value in pairs( data ) do
        if exclude_ == nil or exclude_[key] == nil then
            table.insert( data_arr, ' `' .. key .. '`' .. " = " .. gen_value( value ) )
        end
    end
    --大于一个条件则需要使用AND连接
    if #data_arr > 1 then
        data_str = table.concat( data_arr, ' , ' )
    else
        data_str = data_arr[1]
    end

    return data_str
end

function gen_value(value)
    if string.find(value,'ystring_t') ~= nil then
        return  '\'%s\'' 
    elseif string.find(value,'string') ~= nil then
        return  '\'%s\'' 
    elseif value == 'uint64_t' then
        return '%lu' 
    elseif value == 'uint32_t' then
        return '%u' 
    elseif value == 'float' then
        return '%f'
    elseif value == 'timedate' then
        return 'FROM_UNIXTIME(%d)'
    else
        return '%d'
    end
end

gen()

--===========================================================
function gen_ext()
    local h_file = io.open('db_ext.h', 'w') 
    local seg = {}
    table.insert(seg, '#ifndef _db_ext_h_\n')
    table.insert(seg, '#define _db_ext_h_\n')
    table.insert(seg, '#include "db_def.h"\n')
    table.insert(seg, '#include "db_smart_up.h"\n')
    table.insert(seg, '#include <boost/noncopyable.hpp>\n')

    for k, v in pairs(dbs) do
        table.insert(seg, gen_db_ext_dec(k, v))
    end

    table.insert(seg, '#endif\n')

    h_file:write(table.concat(seg))
    h_file:close()
end

function gen_db_ext_dec(k_,v_)
    if v_.ops_conditon.update == nil then
        return ""
    end

    local seg = {}
    table.insert(seg, "class ".."db_"..k_.."_ext_t")
    table.insert(seg, ": public db_"..k_.."_t, db_smart_up_t, boost::noncopyable\n")
    table.insert(seg, "{\n")
    table.insert(seg, "public:\n")
    table.insert(seg, "db_"..k_.."_ext_t()\n")
    table.insert(seg, "{\n")
    for memname, memtype in pairs(v_.db) do
        if v_.key == nil or v_.key[memname] == nil then
            table.insert(seg, string.format("REG_MEM(%s,%s)\n", memtype, memname))
        end
    end
    table.insert(seg, "}\n")

    for memname, memtype in pairs(v_.db) do
        if v_.key == nil or v_.key[memname] == nil then
            table.insert(seg, string.format("DEC_SET(%s,%s)\n", memtype, memname))
        end
    end

    table.insert(seg, "string get_up_sql()\n")
    table.insert(seg, "{\n")
    table.insert(seg, "if (!has_changed()) return \"\";\n")

    local cond = v_.ops_conditon.update[1]
    --生成条件语句
    local condition_str = gen_condition( v_.db, cond, v_.key)

    local sql = "\"UPDATE `" .. k_ .. "` SET %%1%% WHERE " .. condition_str.."\""

    local upseg = {}
    table.insert(upseg, 'char buf[256];\nsprintf(buf')
    table.insert(upseg, sql)
    for _, v in pairs(cond) do
        if string.find(v_.db[v], 'ystring_t')  ~= nil then 
            table.insert(upseg, v..'.c_str()')
        elseif string.find(v_.db[v], 'string')  ~= nil then 
            table.insert(upseg, v..'.c_str()')
        else
            table.insert(upseg, v)
        end
    end
    table.insert(seg, table.concat(upseg, ', ') .. ');\n')
    table.insert(seg, 'return gen_up_sql(buf);\n')
    table.insert(seg, "}\n")

    table.insert(seg, "db_"..k_.."_t& data()\n")
    table.insert(seg, "{\n")
    table.insert(seg, "return *((db_"..k_.."_t*)(this));\n")
    table.insert(seg, "}\n")
    
    table.insert(seg, "};\n")
    return table.concat(seg)
end

gen_ext()
