#include "sc_test.h"
#include "sc_user.h"
#include "sc_battle_pvp.h"
#include "sc_logic.h"

void sc_test_t::test_arena(int32_t uid_, test_msg_def::req_test_arena_t& req_)
{
    sc_user_t cast, target;

    db_UserID_t db;

    db.nickname = "caster";
    db.resid = req_.cast_resid;
    db.uid = 1;
    db.hostnum = 1;
    db.aid = 1;
    cast.init_new_user(db);
    cast.db.grade = req_.cast_lv;
    cast.team_mgr[0] = 0;
    int i=1;
    cast.partner_mgr.foreach([&](sp_partner_t partner_){
            if (i<5&&i<req_.cast_with_partner_num)
            {
                (cast.team_mgr)[i++] = partner_->db.pid;
                partner_->db.grade = req_.cast_lv;
            }
    });

    db.nickname = "target";
    db.resid = req_.target_resid;
    db.uid = 2;
    db.hostnum = 1;
    db.aid = 2;
    target.init_new_user(db);
    target.db.grade = req_.target_lv;;
    (target.team_mgr)[0] = 0;
    i=1;
    target.partner_mgr.foreach([&](sp_partner_t partner_){
            if (i<5&&i<=req_.target_with_partner_num)
            {
                (target.team_mgr)[i++] = partner_->db.pid;
                partner_->db.grade = req_.target_lv;
            }
    });

    sp_view_user_t sp_cast_data = cast.get_view();
    sp_view_user_t sp_target_data = target.get_view();

    int win_num = 0;
    //uint32_t rseed = time(NULL);
    for(int i=0; i<req_.test_total_num; i++)
    {
        uint32_t rseed = random_t::rand_integer(10000, 100000);

        //开始pvp
        sc_battlefield_t field(rseed, sp_cast_data, sp_target_data);

        int n = field.run();
        cout << n << endl;
        //胜负逻辑
        if (field.is_win()) win_num++;
    }

    cout << win_num << endl;

    test_msg_def::ret_test_arena_t ret; 
    (*sp_cast_data) >> ret.cast_data;
    (*sp_target_data) >> ret.target_data;
    ret.win_num = win_num;
    ret.test_total_num = req_.test_total_num;

    logic.unicast(uid_, ret);
}
