#!/usr/bin/env python

import sys, getopt, time, os
from datetime import date,timedelta
from tools import date_list, str2date
import nuts_conf
import mylog
 
def usage():
    print "usage: %s [options]" % sys.argv[0]
    print "-h --help            print this message"
    print "-a --all             cal all game in configurate file"
    print "-g GAME --game=GAME  cal GAME only"
    print "-b begindate         cal from begindate, default is yesterday"
    print "-e enddate           cal end date, default is yesterday"

def exit(code):
    try:
        os.remove(nuts_conf.conf['lock'])
    except Exception, ex:
        pass
    sys.exit(code)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "hag:b:e:", ["help","all","game="])
    except getopt.GetoptError, err:
        print str(err)
        exit(2)
   
    if args != []:
        usage()
        exit(2)
	 
    yesterday = date.today() - timedelta(1)
    begindate = yesterday.strftime('%Y%m%d')
    enddate = begindate
    games = set()
    for o,v in opts:
        if o in ('-h', '--help'):
            usage()
            exit(0)
        elif o in ('-a', '--all'):
            games.update(nuts_conf.games.keys())
        elif o in ('-g', '--game'):
            games.add(v.upper())
        elif o == '-b':
            begindate = v
        elif o == '-e':
            enddate = v
        else: assert False, "unhandled option"

    dl = date_list(begindate,enddate)

    if os.path.exists(nuts_conf.conf['lock']):
        print 'sync_main is running or last execute exit unexpected.'
        sys.exit(0)
    else:
        open(nuts_conf.conf['lock'], 'w')

    mylog.init(filename=nuts_conf.conf['logfile'], loglevel=nuts_conf.conf['loglevel'])
    from nuts_ctrl import run
    run(games, dl)
    os.remove(nuts_conf.conf['lock'])

if __name__ == '__main__':
    if len(sys.argv) == 1:
        usage()
    else:
        main()
