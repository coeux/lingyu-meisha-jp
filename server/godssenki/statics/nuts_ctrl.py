#!/usr/bin/python

import sys
from traceback import format_exc
from cal_nuts_data import *
from dbapi import DBApi
from nuts_conf import conf, mysql_opt, getconf
import mylog

log = mylog.debugf('nuts_control')

def run(games, datelist):
    log(20, 'games = %s, datelist=%s' % (games, datelist))
    try:
        dbi = DBApi(conf.get('dbi_conf'))
        for k in mysql_opt:
            dbi.run_sql("SET %s=%s" % (k, mysql_opt[k]))
    except Exception, ex: 
        log(40, format_exc())
        log(50, 'init local db failed.')
        sys.exit(1)

    for g in games:
        c = globals()[getconf(g).get('usertype')](dbi, datelist)
        c.cal(g)
 

if __name__ == '__main__':
    dates = []
    dates.append('20120605')
    games = []
    games.append('wh'.upper())
    print games
    print dates
    run(games,dates)
