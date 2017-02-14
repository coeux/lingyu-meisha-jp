#!/usr/bin/env python
 
import time
from datetime import date,timedelta
import mylog

log = mylog.debugf('tools')

def str2date(s):
    """YYYYMMDD to date"""
    return date(int(s[0:4]),int(s[4:6]),int(s[6:]))

def date_list(begin, end):
    dates = []
    b = str2date(begin)
    e = str2date(end)
    while b <= e:
        dates.append(b.strftime('%Y%m%d'))
        b += timedelta(1)
    return dates
