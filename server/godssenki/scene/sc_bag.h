#ifndef _sc_bag_h_
#define _sc_bag_h_

#include <stdint.h>
#include <msg_def.h>


class sc_user_t;
class sc_bag_t
{
public:
    sc_bag_t(sc_user_t& user_);
    int32_t get_size();
    int32_t get_current_size();
    bool can_contain(int32_t resid_);
    bool can_change(sc_msg_def::nt_bag_change_t& change_);
    bool is_full();
private:
    sc_user_t&  m_user;
};

#endif
