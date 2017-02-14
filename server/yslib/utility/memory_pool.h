#ifndef _MEMORY_POOL_H_
#define _MEMORY_POOL_H_

#include <vector>
using namespace std;

#include <boost/shared_ptr.hpp>
#include <boost/pool/pool.hpp>
#include <boost/pool/detail/singleton.hpp>
#include <boost/pool/detail/guard.hpp>

namespace utility
{

typedef boost::default_user_allocator_malloc_free   default_allocator_t;
typedef boost::details::pool::pthread_mutex         default_system_mutex_t;

#define MEMORY_POOL_MIN_F_SIZE          64u
#define MEMORY_POOL_MIN_S_SIZE          1024u

#define MEMORY_POOL_BASE_CHUNK_SIZE     64u
#define MEMORY_POOL_BASE_CHUNK_SIZE_EX  1024u
#define MEMORY_POOL_MAX_CHUNK_SIZE      1024u*20

#define ALIGN_F_SIZE                    64u
#define ALIGN_FIRST(n)                  ((n + ALIGN_F_SIZE - 1)&~(ALIGN_F_SIZE-1))

#define ALIGN_S_SIZE                    1024u
#define ALIGN_SECOND(n)                 ((n + ALIGN_S_SIZE - 1)&~(ALIGN_S_SIZE-1))

#define MEMORY_POOL_EXTRA_SIZE          8u

template <typename allocator_t,
          unsigned next_size_n>
class memory_pool_t
{
    typedef boost::pool<allocator_t>            default_pool_t;
    typedef boost::shared_ptr<default_pool_t>   default_pool_ptr_t;

    public:
        memory_pool_t() :
            m_second_chunk_start_index(0),
            m_pool_tag(0x1717A0A0)
        {
        }

        void init()
        {
            default_pool_ptr_t pool_ptr;

            //! first pool step: 64, 128, 192, ..., 1024
            for (unsigned int s = MEMORY_POOL_MIN_F_SIZE;
                 s < MEMORY_POOL_MIN_S_SIZE;
                 s += MEMORY_POOL_BASE_CHUNK_SIZE)
            {
                pool_ptr.reset(new default_pool_t(s + MEMORY_POOL_EXTRA_SIZE, next_size_n));
                m_pool_vt.push_back(pool_ptr);
            }

            m_second_chunk_start_index = m_pool_vt.size();
            //! second pool step: 1024, 2048, 3072, ..., 20480
            for (unsigned int s = MEMORY_POOL_MIN_S_SIZE;
                 s <= MEMORY_POOL_MAX_CHUNK_SIZE;
                 s += MEMORY_POOL_BASE_CHUNK_SIZE_EX)
            {
                pool_ptr.reset(new default_pool_t(s + MEMORY_POOL_EXTRA_SIZE, next_size_n));
                m_pool_vt.push_back(pool_ptr);
            }
        }

        void* malloc(unsigned int size_)
        {
            if (size_ > MEMORY_POOL_MAX_CHUNK_SIZE)
            {
                char* ptr = (char*)::std::malloc(size_ + MEMORY_POOL_EXTRA_SIZE);
                if (ptr == NULL)
                {
                    return NULL;
                }

                memcpy(ptr, &m_pool_tag, sizeof(unsigned int));
                memcpy(ptr + sizeof(unsigned int), &size_, sizeof(unsigned int));
                return (void*)(ptr + MEMORY_POOL_EXTRA_SIZE);
            }

            int index = get_index_i(size_);
            if (index <= -1 || index >= (int)m_pool_vt.size())
            {
                return NULL;
            }

            char* ptr = (char*)m_pool_vt[index]->malloc();
            if (ptr == NULL)
            {
                return NULL;
            }

            memcpy(ptr, &m_pool_tag, sizeof(unsigned int));
            memcpy(ptr + sizeof(unsigned int), &size_, sizeof(unsigned int));

            //! keep 8 bytes before actual memory to store the index value
            return (void*)(ptr + MEMORY_POOL_EXTRA_SIZE);
        }

        void free(void* const ptr_)
        {
            char* actual_ptr = (char*)ptr_ - MEMORY_POOL_EXTRA_SIZE;

            unsigned int tag = 0;
            memcpy(&tag, actual_ptr, sizeof(unsigned int));
            if (tag != m_pool_tag)
            {
                return;
            }

            unsigned int chunk_size = 0;
            memcpy(&chunk_size, actual_ptr + sizeof(unsigned int), sizeof(unsigned int));

            free(ptr_, chunk_size);
        }

        void free(void* const ptr_, unsigned int size_)
        {
            if (size_ > MEMORY_POOL_MAX_CHUNK_SIZE)
            {
                return ::std::free( (char*)ptr_ - MEMORY_POOL_EXTRA_SIZE );
            }

            int index = get_index_i(size_);
            if (index <= -1 || index >= (int)m_pool_vt.size())
            {
                return;
            }

            m_pool_vt[index]->free( (char*)ptr_ - MEMORY_POOL_EXTRA_SIZE );
        }

        //! release all memory to pool
        bool release_memory()
        {
            bool ret = true;
            size_t pool_size = m_pool_vt.size();
            for (size_t i = 0; i < pool_size; ++i)
            {
                if (!m_pool_vt[i]->release_memory())
                {
                    ret = false;
                }
            }

            return ret;
        }

        //! release all memory to system
        bool purge_memory()
        {
            bool ret = true;
            size_t pool_size = m_pool_vt.size();
            for (size_t i = 0; i < pool_size; ++i)
            {
                if (!m_pool_vt[i]->purge_memory())
                {
                    ret = false;
                }
            }

            return ret;
        }

    private:
        int get_index_i(unsigned int size_)
        {
            if (size_ > MEMORY_POOL_MAX_CHUNK_SIZE)
            {
                return -1;
            }
            else if (size_ > MEMORY_POOL_MIN_S_SIZE)
            {
                int index = m_second_chunk_start_index - 1 + (ALIGN_SECOND(size_) / MEMORY_POOL_BASE_CHUNK_SIZE_EX -1);
                return index;
            }
            else if (size_ > 0)
            {
                return (ALIGN_FIRST(size_) / MEMORY_POOL_BASE_CHUNK_SIZE -1);
            }

            return -1;
        }

    private:
        int                                 m_second_chunk_start_index;
        vector<default_pool_ptr_t>          m_pool_vt;
        const unsigned int                  m_pool_tag;

};

typedef struct default_memory_pool_tag_t {} default_memory_pool_tag_t;

template <typename tag_t = default_memory_pool_tag_t,
          typename allocator_t = default_allocator_t,
          typename mutex_t = default_system_mutex_t,
          unsigned next_size_n = 32>
class singleton_memory_pool_t
{
    private:
        struct memory_pool_type_t : mutex_t
        {
            memory_pool_t<allocator_t, next_size_n> m;
            memory_pool_type_t()
            {
                m.init();
            }
        };

        typedef boost::details::pool::singleton_default<memory_pool_type_t> singleton_ex_t;

        singleton_memory_pool_t();

    public:
        static void* malloc(unsigned int size_)
        {
            memory_pool_type_t & m = singleton_ex_t::instance();
            boost::details::pool::guard<mutex_t> g(m);

            return m.m.malloc(size_);
        }

        static void free(void* const ptr_)
        {
            memory_pool_type_t & m = singleton_ex_t::instance();
            boost::details::pool::guard<mutex_t> g(m);

            return m.m.free(ptr_);
        }

        static void free(void* const ptr_, unsigned int size_)
        {
            memory_pool_type_t & m = singleton_ex_t::instance();
            boost::details::pool::guard<mutex_t> g(m);

            return m.m.free(ptr_, size_);
        }

        static bool release_memory()
        {
            memory_pool_type_t & m = singleton_ex_t::instance();
            boost::details::pool::guard<mutex_t> g(m);

            return m.m.release_memory();
        }

        static bool purge_memory()
        {
            memory_pool_type_t & m = singleton_ex_t::instance();
            boost::details::pool::guard<mutex_t> g(m);

            return m.m.purge_memory();
        }
};

} //! ENDOF namespace utility

#define singleton_memory_pool_t() \
        utility::singleton_memory_pool_t<>

#define singleton_memory_pool_ex_t(x) \
        utility::singleton_memory_pool_t<utility::default_memory_pool_tag_t, \
                                         utility::default_allocator_t,\
                                         utility::default_system_mutex_t, x>

#endif //! _MEMORY_POOL_H_
