#ifndef _EVENT_H_
#define _EVENT_H_

#include <map>
#include <memory>
#include <vector>
#include <tuple>
#include <boost/any.hpp>
using namespace std;

#include "log.h"
#include "event_log_def.h"

template<class TCmd>
class event_mgr_t
{
    struct event_i
    {
        void*           obj;
        boost::any      cb;
        boost::any      params;

        virtual void happen() = 0;
    };

    //=====我是聪明的分割线=====
    
    template<int N, class T, class... Args>
    struct holder_t{ 
        holder_t(event_i* e_){} 
    };
    template<class... Args>
    struct holder_t<0, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)();
            F tmp = boost::any_cast<F>(e_->cb);
            (*tmp)();
        } 
    };
    template<class... Args>
    struct holder_t<1, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            (*tmp)(std::get<0>(p));
        } 
    };
    template<class... Args>
    struct holder_t<2, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            (*tmp)(std::get<0>(p), std::get<1>(p));
        } 
    };
    template<class... Args>
    struct holder_t<3, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            (*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p));
        } 
    };
    template<class... Args>
    struct holder_t<4, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            (*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p), std::get<3>(p));
        } 
    };
    template<class... Args>
    struct holder_t<5, void, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            (*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p), std::get<3>(p), std::get<4>(p));
        } 
    };
    
    //=====我是聪明的分割线=====

    template<class T, class... Args>
    struct holder_t<0, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)();
            F tmp = boost::any_cast<F>(e_->cb);
            T* obj = (T*)e_->obj;
            (obj->*tmp)();
        } 
    };
    template<class T, class... Args>
    struct holder_t<1, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            T* obj = (T*)e_->obj;
            (obj->*tmp)(std::get<0>(p));
        } 
    };
    template<class T, class... Args>
    struct holder_t<2, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            T* obj = (T*)e_->obj;
            (obj->*tmp)(std::get<0>(p), std::get<1>(p));
        } 
    };
    template<class T, class... Args>
    struct holder_t<3, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            T* obj = (T*)e_->obj;
            (obj->*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p));
        } 
    };
    template<class T, class... Args>
    struct holder_t<4, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            T* obj = (T*)e_->obj;
            (obj->*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p), std::get<3>(p));
        } 
    };
    template<class T, class... Args>
    struct holder_t<5, T, Args...>{ 
        holder_t(event_i* e_)
        { 
            typedef void(T::*F)(Args...);
            F tmp = boost::any_cast<F>(e_->cb);
            std::tuple<Args...>& p = *boost::any_cast<std::tuple<Args...>*>(e_->params);
            T* obj = (T*)e_->obj;
            (obj->*tmp)(std::get<0>(p), std::get<1>(p), std::get<2>(p), std::get<3>(p), std::get<4>(p));
        } 
    };

    //=====我是聪明的分割线=====

    typedef std::shared_ptr<event_i>    sp_event_i;
    typedef std::vector<sp_event_i>     event_vec_t;

    typedef std::map<TCmd, event_vec_t> event_map_t;
public:
    //不要使用const& 这种传递，会导致无法识别
    template<class... Args>
    void reg(const TCmd& cmd_, void(*fun_)(Args...))
    {
        struct event_t : public event_i
        {
            void happen()
            {
                holder_t<sizeof...(Args), void, Args...>(this);
            }
        };
        event_t& evt = *(new event_t);
        evt.obj = NULL;
        evt.cb = fun_;

        auto iter = m_event_map.find(cmd_);
        if (iter == m_event_map.end())
        {
            event_vec_t evts;
            evts.push_back(sp_event_i(&evt));
            m_event_map.insert(make_pair(cmd_, evts));
        }
        else
        {
            iter->second.push_back(sp_event_i(&evt));
        }
    }

    template<class T, class... Args>
    void reg(const TCmd& cmd_, T* obj_, void(T::*fun_)(Args...))
    {
        struct event_t : public event_i
        {
            void happen()
            {
                holder_t<sizeof...(Args), T, Args...>(this);
            }
        };
        event_t& evt = *(new event_t);
        evt.obj = obj_;
        evt.cb = fun_;
       
        auto iter = m_event_map.find(cmd_);
        if (iter == m_event_map.end())
        {
            event_vec_t evts;
            evts.push_back(sp_event_i(&evt));
            m_event_map.insert(make_pair(cmd_, evts));
        }
        else
        {
            iter->second.push_back(sp_event_i(&evt));
        }
    }

    template<class... Args>
    void send(const TCmd& cmd_, Args... args_)
    {
        auto it = m_event_map.find(cmd_);
        if (it != m_event_map.end())
        {
            event_vec_t& evts = it->second;
            try
            {
                std::tuple<Args...> tmp_params = std::make_tuple(args_...);
                auto iter = evts.begin();
                for(; iter != evts.end(); iter++)
                {
                    (*iter)->params = &tmp_params;
                    (*iter)->happen();
                }
            }
            catch(exception& ex)
            {
                logerror((EVENT, "send exception:%s", ex.what()));
            }
        }
    }
private:
    event_map_t m_event_map;
};

#endif
