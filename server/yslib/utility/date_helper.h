#ifndef _date_helper_h_
#define _date_helper_h__

#include <stdint.h>
#include <string>
using namespace std;

#include "singleton.h"

class date_helper_t
{
public:
    int offday(uint32_t tv_sec);
    int sec_2_tomorrow(int32_t cur_);
    uint32_t cur_0_stmp();
    int offday(uint32_t tv_sec_b, uint32_t tv_sec_e);
    int offsec(uint32_t tv_sec);
    int offmonth(uint32_t stamp_);  //date: '20131025'
    uint32_t cur_sec();
    uint32_t cur_local_sec();
    int cur_month();
    int cur_year();
    string str_date(uint32_t tv_);
    string str_date();
    string str_date_only();
    string str_date_mysql(uint32_t time_);
    string str_dayofweek(int day_);
    void get_time_by_sec(uint32_t tv_, int32_t& year_, int32_t& month_, int32_t& day_, int32_t& hour_, int32_t& minute_, int32_t& second_);
    int cur_dayofweek();
    int cur_dayofmonth();
    uint32_t trans_unixstamp(uint32_t date_);
    uint32_t secoffday();
    uint32_t secoffday(uint32_t sec_);
    int same_month(uint32_t tv_sec);
    int get_day_sec(int day_);
    uint32_t day_0_stmp(uint32_t sec_);
    //倒计时，返回秒数
    //从起始时间戳开始，每隔offday的倒计时
    uint32_t countdown(uint32_t start_stamp_, uint32_t offday_);
};

#define date_helper (singleton_t<date_helper_t>::instance())

#endif
