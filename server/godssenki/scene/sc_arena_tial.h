#ifndef _sc_arena_trial_h_
#define _sc_arena_trial_h_

class sc_arena_trial_t
{
public:
    void create_robot();
    void get_targets(int off_);
    bool get_jpk_arena_target(uint32_t uid_, int rank_, sc_msg_def::jpk_arena_target_t& jpk_);
};

#endif
