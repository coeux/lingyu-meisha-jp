local vop_e = 
{
    vop_buy_power = 1,           --购买体力
    vop_do_halt = 2,             --开启挂机
    vop_buy_halt_time = 3,       --购买挂机时间
    vop_acc_fight_speed = 4,     --加速战斗
    vop_reste_adv_round = 5,     --重置精英关卡
    vop_add_bag_max = 6,         --增加背包上限
    vop_do_trial_pos3 = 7,       --训练位置3
    vop_acc_trial = 8,           --加速训练
    vop_buy_fight_count = 9,     --购买训练次数
    vop_buy_trial_energy = 10,   --购买活力
    vop_do_vp_trial = 11,        --王者训练
    vop_reset_zodiac = 12,       --重置12宫
    vop_rune_cost = 13,          --符文召唤高级小怪
    vop_given_power = 14,        --每日体力赠送
    vop_do_buy_money = 15,       --炼金
    vop_flash_pub = 16,          --酒馆刷新
    vop_flash_vp_pub = 17,       --酒馆至尊刷新
    vop_reset_daily_task = 18,   --重置日常任务
    vop_pay_gm = 19,             --公会捐献水晶
    vop_immedia_fight_wboss = 20,--被世界boss击杀后，立刻复活
    vop_add_bag_max_vip = 21,    --增加背包上限100
    vop_flush_star = 22,         --水晶刷新星魂
    vop_flush_targets = 23,      --试炼刷新对手
    vop_clear_pass_round = 24,   --关卡挂机清除cd
    vop_equip_compose_buy = 25,  --升阶材料购买
    vop_flush_cave = 26,         --刷新英雄迷窟
    vop_buy_golden_box = 27,     --购买黄金宝箱
    vop_buy_silver_box = 28,     --购买白银宝箱
}

vop_f={}

vop_f[vop_e.vop_equip_compose_buy] = function(n_)
    return n_
end

vop_f[vop_e.vop_flush_star] = function(n_)
    local price = n_ * 2
    if price > 20 then
        return 20
    end
    return price
end

vop_f[vop_e.vop_add_bag_max] = function(n_)
    if 1<=n_ and n_ <=4 then
        return 100
    end
    if 5<=n_ and n_ <=8 then
        return 200
    end
    if 9<=n_ and n_ <=12 then
        return 300
    end
    if 13<=n_ and n_ <=16 then
        return 400
    end
    if 17<=n_ and n_ <=20 then
        return 500
    end
    return 0
end

vop_f[vop_e.vop_flush_cave] = function(n_)
    if  n_==1 then
        return 50
    end
    if  n_==2 then
        return 100
    end
    if  n_==3 then
        return 150
    end
    return 0
end

vop_f[vop_e.vop_buy_power] = function(n_)
    if n_ <= 5 then
        return 40
    end
    if n_ <= 10 then
        return 50
    end
    if 11<=n_ and n_ <=15 then
        return 60
    end
    if 16<=n_ and n_ <=20 then
        return 70
    end
    if n_ >= 21 then
        return 80
    end
    return 80
end

vop_f[vop_e.vop_buy_halt_time] = function(n_)
    return n_ * 10
end

vop_f[vop_e.vop_reste_adv_round] = function(n_)
    local price = {}
    price[1] = 100
    price[2] = 200
    price[3] = 300
    price[4] = 400
    price[5] = 500
    if (n_ > 5) then
        n_ = 5
    end
    return price[n_]
end

vop_f[vop_e.vop_acc_trial] = function(n_)
    return n_ * 5 
end

vop_f[vop_e.vop_buy_fight_count] = function(n_)
    local price = n_ * 2
    if price > 20 then
        price = 20
    end
    return price
end

vop_f[vop_e.vop_buy_trial_energy] = function(n_)
    if 1<=n_ and n_ <=5 then
        return 10
    end
    if 6<=n_ and n_ <=10 then
        return 20
    end
    if 11<=n_ and n_ <=15 then
        return 30
    end
    if 16<=n_ and n_ <=20 then
        return 40
    end
    return 40
end

vop_f[vop_e.vop_do_vp_trial] = function(n_)
    return 2000
end

vop_f[vop_e.vop_reset_zodiac] = function(n_)
    local price = {}
    price[1] = 100
    price[2] = 200
    price[3] = 300
    price[4] = 400
    price[5] = 500
    if (n_ > 5) then
        n_ = 5
    end
    return price[n_]
end

vop_f[vop_e.vop_rune_cost] = function(n_)
    return 50 
end

vop_f[vop_e.vop_do_buy_money] = function(n_)
    if n_ <= 1 then
        return 0
    end
    if n_ <= 2 then
        return 5
    end
    if 3<=n_ and n_ <=4 then
        return 10
    end
    if 5<=n_ and n_ <=8 then
        return 20
    end
    if 9<=n_ and n_ <=15 then
        return 30
    end
    if 16<=n_ and n_ <=30 then
        return 50
    end
    if 31<=n_ and n_ <= 40 then
        return 75
    end
    if n_ >= 40 then
        return 100
    end
    return 100
end

vop_f[vop_e.vop_flash_pub] = function(n_)
    if n_ == 3 then
        return 180
    end
    if n_ == 4 then
        return 1800
    end
end

vop_f[vop_e.vop_flush_targets] = function(n_)
    return 1
end

vop_f[vop_e.vop_clear_pass_round] = function(n_)
    return 10
end

vop_f[vop_e.vop_flash_vp_pub] = function(n_)
    if n_ == 5 then
        return 180
    end
    if n_ == 6 then
        return 1800
    end
end

vop_f[vop_e.vop_reset_daily_task] = function(n_)
    local price = {}
    price[1] = 50
    price[2] = 100
    price[3] = 150
    price[4] = 200 
    price[5] = 300 
    if n_ > 5 then
        n_ = 5
    end
    return price[n_]
end

vop_f[vop_e.vop_pay_gm] = function(n_)
    -- 参数n_为请求购买的贡献值
    -- 返回为需要的水晶数量
    return n_ * 0.1
end

vop_f[vop_e.vop_immedia_fight_wboss] = function(n_)
    return 2 * n_
end

vop_f[vop_e.vop_buy_golden_box] = function(n_)
    return 49
end

vop_f[vop_e.vop_buy_silver_box] = function(n_)
    return 29
end
