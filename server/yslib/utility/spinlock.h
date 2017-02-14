#ifndef _spinlock_h_
#define _spinlock_h_

#include <boost/atomic.hpp>
#include <boost/utility.hpp>

class spinlock_t:boost::noncopyable {
private:
    typedef enum {Locked, Unlocked} LockState;
    boost::atomic<LockState> state_;

public:
    spinlock_t() : state_(Unlocked) {}
    ~spinlock_t() {
        unlock();
    }

    void lock()
    {
        while (state_.exchange(Locked, boost::memory_order_acquire) == Locked) {
            /* busy-wait */
        }
    }
    void unlock()
    {
        state_.store(Unlocked, boost::memory_order_release);
    }
};

#endif
