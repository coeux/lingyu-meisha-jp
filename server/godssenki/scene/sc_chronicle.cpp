#include "sc_chronicle.h"
#include "sc_user.h"
#include "sc_logic.h"
#include "log.h"
#include "repo_def.h"
#include "code_def.h"
#include <ctime>

#define LOG "SC_CHRONICLE"
#define RECORD_RETRIEVE_DAY 7
#define SINGLE_TIMES_CONSUME_YB 20

const int32_t sc_chronicle_mgr_t::CAN_READ = 2;
const int32_t sc_chronicle_mgr_t::Done = 1;
const int32_t sc_chronicle_mgr_t::Undone = 0;
const uint32_t sc_chronicle_mgr_t::DAYS[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

sc_chronicle_mgr_t::sc_chronicle_mgr_t(sc_user_t& user_):m_user(user_)
{
}

void sc_chronicle_mgr_t::load_db()
{
    sql_result_t res;
    if (0 == db_Chronicle_t::sync_select_chronicle_month(m_user.db.uid, get_current_month(), res))
    {
        auto year_month_day = get_current_day();
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            sp_chronicle_t sp_chronicle(new chronicle_t);
            sp_chronicle->init(*res.get_row_at(i));
            if (sp_chronicle->state == Undone && sp_chronicle->chronicle_day != year_month_day) {
                uint32_t chron_time = sp_chronicle->chronicle_day;
                db_service.async_do((uint64_t)m_user.db.uid, [](sp_chronicle_t sp_chronicle_) {
                    sp_chronicle_->remove();
                }, sp_chronicle);
                add_chronicle(sp_chronicle, chron_time);
            }
            m_chronicle.insert(make_pair(sp_chronicle->chronicle_day, sp_chronicle));
        }
    }
}

void sc_chronicle_mgr_t::async_load_db()
{
    sql_result_t res;
    if (0 == db_Chronicle_t::select_chronicle_month(m_user.db.uid, get_current_month(), res))
    {
        auto year_month_day = get_current_day();
        for (size_t i = 0; i < res.affect_row_num(); ++i)
        {
            sp_chronicle_t sp_chronicle(new chronicle_t);
            sp_chronicle->init(*res.get_row_at(i));
            if (sp_chronicle->state == Undone && sp_chronicle->chronicle_day != year_month_day) {
                uint32_t chron_time = sp_chronicle->chronicle_day;
                db_service.async_do((uint64_t)m_user.db.uid, [](sp_chronicle_t sp_chronicle_) {
                    sp_chronicle_->remove();
                }, sp_chronicle);
                add_chronicle(sp_chronicle, chron_time);
            }
            m_chronicle.insert(make_pair(sp_chronicle->chronicle_day, sp_chronicle));
        }
    }
}

void sc_chronicle_mgr_t::save_db(sp_chronicle_t& sp_chronicle_)
{
    string sql_ = sp_chronicle_->get_up_sql();
    if (sql_.empty()) return;
    db_service.async_do((uint64_t)sp_chronicle_->uid, [](string& sql_) {
        db_service.async_execute(sql_);
    }, sql_);
}

void sc_chronicle_mgr_t::add_chronicle(sp_chronicle_t& sp_chronicle_, uint32_t year_month_day, uint32_t state)
{
    sp_chronicle_->uid = m_user.db.uid;
    sp_chronicle_->chronicle_day = year_month_day;
    sp_chronicle_->chronicle_month = year_month_day / 100;
    sp_chronicle_->step = 0;
    sp_chronicle_->state = state;

    db_service.async_do((uint64_t)m_user.db.uid, [](sp_chronicle_t sp_chronicle_) {
        sp_chronicle_->insert();
    }, sp_chronicle_);
}

void sc_chronicle_mgr_t::unicast_chronicle_list(uint32_t resid_)
{
    sc_msg_def::ret_chronicle_t ret;

    uint32_t year_month = resid_;

    month_chronicle(ret, year_month), progress(ret, year_month);

    logic.unicast(m_user.db.uid, ret);
}

void sc_chronicle_mgr_t::progress(sc_msg_def::ret_chronicle_t& ret, uint32_t year_month)
{
    int month = year_month % 100;
    if (month > 12 || month <= 0)
    {
        logerror((LOG, "month: %d error"));
        return;
    }

    bool is_current_month = false;
    auto current_day = get_current_day();
    auto iterator = m_chronicle.begin();
    if (iterator != m_chronicle.end() && iterator->second->chronicle_day / 100 == current_day / 100)
        is_current_month = true;
    if (is_current_month) {
        for (auto it = m_chronicle.begin(); it != m_chronicle.end(); ++it)
        {
            sc_msg_def::jpk_chronicle_progress_t pg;
            pg.chronicle_story_id = it->second->chronicle_day;
            pg.step = it->second->step;
            pg.state = it->second->state;
            ret.chronicle_progress.push_back(std::move(pg));
        }
    }
    else {
        m_chronicle.clear();
        sp_chronicle_t sp_chronicle(new chronicle_t);
        add_chronicle(sp_chronicle, current_day);
        m_chronicle.insert(make_pair(sp_chronicle->chronicle_day, sp_chronicle));

        sc_msg_def::jpk_chronicle_progress_t pg;
        pg.chronicle_story_id = current_day;
        pg.step = 0;
        pg.state = Undone;
        ret.chronicle_progress.push_back(std::move(pg));
    }
}

void sc_chronicle_mgr_t::progress(sc_msg_def::ret_chronicle_sign_retrieve_t& ret, uint32_t year_month) const
{
    int month = year_month % 100;
    if (month > 12 || month <= 0)
    {
        logerror((LOG, "month: %d error"));
        return;
    }
    for (auto it = m_chronicle.begin(); it != m_chronicle.end(); ++it)
    {
        sc_msg_def::jpk_chronicle_progress_t pg;
        pg.chronicle_story_id = it->second->chronicle_day;
        pg.step = it->second->step;
        pg.state = it->second->state;
        ret.chronicle_progress.push_back(std::move(pg));
    }
}

void sc_chronicle_mgr_t::progress(sc_msg_def::ret_chronicle_sign_all_t& ret) const
{
    auto c_year = get_current_year();
    for (int32_t year = 2015; year <= c_year; ++year)
    {
        int32_t max_month = year * 100 + 12;
        for(int month = year*100+1; month <= max_month; ++month) {
            ret.record.insert(std::move(make_pair(month, std::move(0u))));
        }
    }
    sql_result_t res;
    if (0 == db_Chronicle_t::sync_select_chronicle(m_user.db.uid, res)) {
        for (size_t i = 0; i < res.affect_row_num(); ++i){
            sp_chronicle_t sp_chronicle(new chronicle_t);
            sp_chronicle->init(*res.get_row_at(i));
            if (sp_chronicle->state == Done)
                ret.record[sp_chronicle->chronicle_month] |= 1 << (sp_chronicle->chronicle_day%100 - 1);
        }
    }
}

void sc_chronicle_mgr_t::month_chronicle(sc_msg_def::ret_chronicle_t& ret, uint32_t year_month) const
{
    int month = year_month % 100;
    if (month > 12 || month <= 0)
    {
        logerror((LOG, "month: %d error"));
        return;
    }
    //月信息
    repo_def::chronicle_t* rp_chronicle = repo_mgr.chronicle.get(year_month);
    ret.chronicle_month.id = rp_chronicle->id;
    ret.chronicle_month.name = rp_chronicle->name;
    ret.chronicle_month.background = rp_chronicle->background;
    ret.chronicle_month.source_ids = rp_chronicle->source_ids;
    ret.chronicle_month.source_condition = rp_chronicle->source_condition;

    //日信息
    uint32_t days = DAYS[month-1];
    if (month == 2 && is_leap_year(year_month/100)) ++days;
    for (uint32_t i = 1; i <= days; ++i)
    {
        int id = year_month*100 + i;
        repo_def::chronicle_story_t* rp_chronicle_story = repo_mgr.chronicle_story.get(id);
        if (rp_chronicle_story == NULL)
            continue;
        sc_msg_def::jpk_chronicle_story_t story;
        story.id = rp_chronicle_story->id;
        story.day = rp_chronicle_story->day;
        story.pre_story = rp_chronicle_story->pre_story;
        story.finish_story = rp_chronicle_story->finish_story;
        story.plot_id = rp_chronicle_story->plot_id;
        story.item_ids = rp_chronicle_story->item_ids;
        ret.chronicle_day.push_back(std::move(story));
    }
}

bool sc_chronicle_mgr_t::is_sign()
{
    int32_t today = get_current_day();
    auto it = m_chronicle.find(today);
    if (it == m_chronicle.end()) {
        return false;
    }
    return it->second->state == Done;
}

void sc_chronicle_mgr_t::sign(sc_msg_def::ret_chronicle_sign_t& ret, int32_t year_month_day)
{
    /* 可签到非当日信息（记录找回） */
    /*
    auto ymd = get_current_day();
    if (ymd != year_month_day) {
        ret.chronicle_story_id = ymd;
        ret.step = 0;
        ret.state = Undone;
        logerror((LOG, "sc_chronicle_mgr_t::sign, req year_month_day = %d, but today is %d", year_month_day, ymd));
        return ;
    }
    */
    sc_chronicle_mgr_t::load_db();
    auto ymd = get_current_day();
    auto it = m_chronicle.find(year_month_day);
    if (it != m_chronicle.end()) {
        ret.chronicle_story_id = it->second->chronicle_day;
        ret.step = it->second->step;
        ret.state = Done;
    } else {
        sp_chronicle_t sp_chronicle(new chronicle_t);
        add_chronicle(sp_chronicle, year_month_day, Done);
        ret.chronicle_story_id = year_month_day;
        ret.step = 0;
        ret.state = Done;
    }

    m_user.on_chronicle_sum_change(1);
    if (ymd == year_month_day) { /* 当日签到有奖励(找回功能不可找回奖励) */
        if (it != m_chronicle.end()) {
            if (it->second->state != Done){
                it->second->set_state(Done);
                save_db(it->second);
                repo_def::chronicle_story_t* rp_chronicle_story = repo_mgr.chronicle_story.get(ymd);
                m_user.on_power_change(rp_chronicle_story->item_ids[1][1]); // 0 是假的
            }
        }
        else
        {
            repo_def::chronicle_story_t* rp_chronicle_story = repo_mgr.chronicle_story.get(ymd);
            m_user.on_power_change(rp_chronicle_story->item_ids[1][1]); // 0 是假的
        }
    }
    m_user.save_db();
}

void sc_chronicle_mgr_t::record_retrieve(sc_msg_def::ret_chronicle_sign_retrieve_t& ret)
{
    int32_t count = 0;
    auto ymd = get_current_day();
    int day = ymd % 100;
    if (day > RECORD_RETRIEVE_DAY) {
        day = RECORD_RETRIEVE_DAY;
        ymd -= RECORD_RETRIEVE_DAY;
    }
    else {
        ymd = ymd / 100 * 100 + 1;
    }

    auto tmp = ymd;
    for (int i = 0; i < day; ++i, ++tmp) {
        auto it = m_chronicle.find(tmp);
        if (it == m_chronicle.end() || (it != m_chronicle.end() && it->second->state == Undone))
            ++count;
    }
    if (m_user.rmb() < count * SINGLE_TIMES_CONSUME_YB) {
        ret.state = -1;
        return ;
    }

    for (int i = 0; i < day; ++i, ++ymd) {
        auto it = m_chronicle.find(ymd);
        if (it == m_chronicle.end()) {
            sp_chronicle_t sp_chronicle(new chronicle_t);
            add_chronicle(sp_chronicle, ymd, CAN_READ);
            m_chronicle.insert(make_pair(sp_chronicle->chronicle_day, sp_chronicle));
        } else if (it->second->state == Undone) {
            it->second->set_state(CAN_READ);
            save_db(it->second);
        }
    }
    m_user.consume_yb(count * SINGLE_TIMES_CONSUME_YB);
    m_user.on_chronicle_sum_change(count);
    m_user.save_db();
    ret.state = 0;
    progress(ret, ymd / 100);
}

//format: 2015
inline int32_t sc_chronicle_mgr_t::get_current_year() const
{
    time_t tp;
    time(&tp);
    struct tm* p = localtime(&tp);
    return p->tm_year + 1900;
}

//format: 201501
inline int32_t sc_chronicle_mgr_t::get_current_month() const
{
    time_t tp;
    time(&tp);
    struct tm* p = localtime(&tp);
    return (p->tm_year + 1900) * 100 + p->tm_mon + 1;
}

//format: 20150101
inline int32_t sc_chronicle_mgr_t::get_current_day() const
{
    time_t tp;
    time(&tp);
    struct tm* p = localtime(&tp);
    return ((p->tm_year + 1900) * 100 + p->tm_mon + 1)*100 + p->tm_mday;
}

inline bool sc_chronicle_mgr_t::is_leap_year(const uint32_t year) const
{
    return (year%4 == 0 && year%100 != 0) || year%400 == 0;
}
