#ifndef _sc_card_comment_h_
#define _sc_card_comment_h_

#include <boost/shared_ptr.hpp>

#include "singleton.h"
#include "msg_def.h"
#include <string>
using namespace std;

class sc_user_t;
typedef boost::shared_ptr<sc_user_t> sp_user_t;

class sc_card_comment_t
{
public:
    int req_newest_comment(sp_user_t user_, int32_t resid, vector<sc_msg_def::jpk_card_comment_info_t> &infos, sc_msg_def::jpk_card_comment_info_t &info_);           //请求最新评论
    int req_hotest_comment(sp_user_t user_, int32_t resid, vector<sc_msg_def::jpk_card_comment_info_t> &infos);           //请求最热评论
    int add_parise_num( sp_user_t user_, int32_t cid_, int32_t cuid_, int32_t puid_);               //点赞
    int req_add_comment(sp_user_t user_, int32_t uid, int32_t resid, int32_t isshow, string msg, vector<sc_msg_def::jpk_card_comment_info_t> &infos, sc_msg_def::jpk_card_comment_info_t &info_);              //评论
    //int get_equip_level(int32_t uid, int32_t pid);
};

#define card_comment_ins (singleton_t<sc_card_comment_t>::instance())

#endif
