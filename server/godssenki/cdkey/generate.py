#!/usr/bin/env python
import os
import re
import sys
import time
import random
import os.path
import traceback

import MySQLdb

from utils import attr_autoset, num2jinzhi, num2readable, get_conn

ONE_GENUM = 500     #generate and insert ONE_GENUM as a batch

class SN_Generator(object):
    def __init__(self, gen_num, expiredate, type):
        try:
            if int(gen_num) <= 0: raise
        except:
            print ('GEN_NUM should be a positive integer!\n')
            print (help())
            sys.exit()

        if not re.match(r'^\d{4}(-\d{2}){2}$', expiredate):
            print ("EXPIREDATE's format should be 'YYYY-MM-DD'!\n")
            print (help())
            sys.exit()

        try:
            if int(type) <= 0: raise
        except:
            print ('TYPE should be a positive integer!\n')
            print (help())
            sys.exit()

        self.conn = get_conn()
        self.cur = self.conn.cursor()
        self.gameid = 'god'

        attr_autoset(locals())

        #import_file = os.path.join(self.workdir, 'data', self.gameid + '/')
        import_file = './data/'
        if not os.path.exists(import_file):
            os.makedirs(import_file)
        self.importtime = time.strftime('%Y-%m-%d %H:%M:%S')
        _importtime = self.importtime.replace('-', '').replace(':','').replace(' ','')
        import_file += '_'.join((self.gameid, _importtime, str(self.type),num2readable(int(self.gen_num)))) + '.txt'
        self.import_file_o = open(import_file, 'a+')

    def gen_sn(self):
        batch_num = int(self.gen_num) / ONE_GENUM
        remainder = int(self.gen_num) % ONE_GENUM
        try:
            self.last_num = self.get_last_num()

            for i in xrange(batch_num):
                self.gen_batch(ONE_GENUM)
            if remainder:
                self.gen_batch(remainder)

            self.insert_gen_log()
        except:
            debugf(40, traceback.format_exc())
            raise

    def gen_batch(self, _gen_num):
        sql = "INSERT INTO cdkey.Cdkey(sn, flag, gentm, expiredate) VALUES"

        wrt_content = ''
        for i in xrange(_gen_num):
            self.last_num += 1
            sn = self.gen_one()
            sql+=("('%s','%s','%s','%s'),"%(sn,self.type,self.importtime,self.expiredate))
            wrt_content += sn + '\n'

        self.import_file_o.write(wrt_content)
        self.import_file_o.flush()
        os.fsync(self.import_file_o.fileno())

        try:
            self.cur.execute(sql[:-1])
        except:
            raise

    def gen_one(self):
        """Generate one sn for gameid"""
        #sn_len = 16
        #candi_chars = '23456789ABCDEFGHJKMNPQRSTUVWXYZ'
        #candi_chars = 'YKQ7R2SD3VMZEXJ4PH5F8N6AGWBTC9U' #shuffle from above
        candi_chars = 'MKV2WA9CE7ZIG5BDF8HJ3NPQ6RSTUX4Y' #old php's(productive)
        indexs = num2jinzhi(self.last_num, len(candi_chars))
        padding_len = 5 - len(indexs)    #assert len(indexs) < 8
        sn = candi_chars[0] * padding_len
        for i in indexs:
            sn += candi_chars[i]
        for i in xrange(3):
            sn += random.choice(candi_chars)
        return sn

    def insert_gen_log(self):
        """Record generate log into table"""
        sql = "INSERT INTO cdkey.gen_log(gameid,gentm,expiredate,type,gen_num,last_num) VALUES(%s, %s, %s, %s, %s, %s)"
        try:
            self.cur.execute(sql, (self.gameid, self.importtime, self.expiredate,self.type, self.gen_num, self.last_num))
        except:
            raise

    def get_last_num(self):
        sql = "SELECT last_num FROM cdkey.gen_log WHERE last_num<>0 ORDER BY gentm DESC LIMIT 1"
        try:
            self.cur.execute(sql)
        except:
            raise

        if self.cur.rowcount == 0:
            return 0
        else:
            return self.cur.fetchone()[0]

if __name__ == '__main__':
    try:
        sng = SN_Generator(sys.argv[1],sys.argv[2],sys.argv[3])
    except:
        print( traceback.format_exc() )

    try:
        sng.gen_sn()
    except:
        print ('generate error!')
    else:
        print ('generate succeed!')
