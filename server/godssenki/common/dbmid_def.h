#ifndef _dbmid_def_h_
#define _dbmid_def_h_

#include <memory>

#include <unordered_map>
#include <list>
using namespace std;

#include "db_def.h"
#include "jserialize_macro.h"

#define SQL_ERROR -1 

struct dbmid_acc_t : public jcmd_t<10000>
{
    typedef unordered_map<int32_t, db_UserID_t>  userid_hm_t;
    typedef typename unordered_map<int32_t, db_UserID_t>::iterator it_userid_hm_t ;

    db_Account_t                                account;
    //[uid][db]
    userid_hm_t                                 userids;
    //[hostnum][set<it_userid>]
    unordered_map<int32_t, list<it_userid_hm_t>> hostindex;

    void update_hostindex()
    {
        for(auto it = userids.begin(); it!= userids.end(); it++)
        {
            auto it_host = hostindex.find(it->second.uid);
            if (it_host == hostindex.end())
            {
                it_host = hostindex.insert(make_pair(it->second.hostnum, list<dbmid_acc_t::it_userid_hm_t>())).first;
            }
            list<dbmid_acc_t::it_userid_hm_t>& uids = it_host->second;
            uids.push_back(it);
        }
    }

    JSON2(dbmid_acc_t, account, userids)
};

struct dbmid_user_t : public jcmd_t<10001>
{
    db_UserInfo_t                                 user;
    db_Team_t                                     team;
    //[eid][db]
    unordered_map<int32_t, db_Equip_t>            equips;
    //[itid][db]
    unordered_map<int32_t, db_Item_t>             items;
    //[skid][db]
    unordered_map<int32_t, db_Skill_t>            skills;
    //[pid][db]
    unordered_map<int32_t, db_Partner_t>          partners;

    JSON6(dbmid_user_t, user, team, equips, items, skills, partners)
};

struct dbmid_insert_t : public jcmd_t<10003>
{
    int32_t aid;
    int32_t uid;
    string tablename;
    string datas;
    dbmid_insert_t():aid(0), uid(0) { }
    JSON4(dbmid_insert_t, aid, uid, tablename, datas)
};

struct dbmid_update_t : public jcmd_t<10004>
{
    int32_t aid;
    int32_t uid;
    string tablename;
    string datas;
    dbmid_update_t():aid(0), uid(0) { }
    JSON4(dbmid_update_t, aid, uid, tablename, datas)
};

struct dbmid_select_acc_t : public jcmd_t<10005>
{
    string mac;
    JSON1(dbmid_select_acc_t, mac)
};

struct dbmid_select_user_t : public jcmd_t<10006>
{
    int32_t uid;
    JSON1(dbmid_select_user_t, uid)
};

struct dbmid_error_t : public jcmd_t<11000>
{
    uint16_t code;
    JSON1(dbmid_error_t, code)
};

template<class T>
struct dbmid_array_t
{
    vector<T> elms;
    JSON1(dbmid_array_t, elms)
};

struct dbmid_new_dbid_t : public jcmd_t<12000>
{
    string idname;
    vector<int32_t> ids;
    JSON2(dbmid_new_dbid_t, idname, ids)
};

struct dbmid_test_t : public jcmd_t<20000>
{
    uint16_t code;
    JSON1(dbmid_test_t, code)
};

#endif
