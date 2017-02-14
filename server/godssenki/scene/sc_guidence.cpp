#include "sc_guidence.h"
#include "sc_user.h"

#define LOG "SC_GUIDENCE"

void sc_guidence_t::on_guidence_event(sc_user_t &user_, int evt_)
{
    //user_.db.set_isnew( user_.db.isnew|(1<<evt_) );
    user_.save_db();
}

void sc_guidence_t::gen_elite_drop(sc_user_t &user_,vector<sc_msg_def::jpk_item_t>& drop_items)
{
    //获取该玩家的职业
    repo_def::role_t *role = repo_mgr.role.get(user_.db.resid);
    if (role == NULL)
        return;
    
    int gen_resid = 0;

    if( (user_.db.isnew & (1<<evt_guidence_elite1))==0 )
    {
        //第一次进精英关卡
        switch( role->job )
        {
            case 2:
                gen_resid = 12025;
                break;
            case 3:
                gen_resid = 12026;
                break;
            case 4:
                gen_resid = 12027;
                break;
            default:
                return;
        }
    }
    else if( (user_.db.isnew & (1<<evt_guidence_elite2))==0 )
    {
        //第二次进精英关卡
        switch( role->job )
        {
            case 2:
            case 3:
                gen_resid = 12029;
                break;
            case 4:
                gen_resid = 12028;
                break;
            default:
                return;
        }
    }

    if( gen_resid != 0 )
    {
        sc_msg_def::jpk_item_t ditem;
        ditem.itid = 0;
        ditem.resid = gen_resid;
        ditem.num = 1;
        drop_items.push_back(std::move(ditem));
    }
}
