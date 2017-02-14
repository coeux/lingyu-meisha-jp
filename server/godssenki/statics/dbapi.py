#/bin/env python
#-*- coding: GB2312 -*-
 
from traceback import format_exc
import MySQLdb
import mylog

log = mylog.debugf('dbapi')

class DBApi(object):
    
    def __init__(self, db_config, autocommit=True):
        self.db_config = db_config
        self.conn = MySQLdb.connect(**self.db_config)
        log(20, "connect to db by config " + str(self.db_config))
        self.conn.autocommit(autocommit)

    def _get_cursor(self, dictcur, rowbyrow):
        """"""
    
        if self.conn != None:
            try:
                self.conn.ping(1)
            except Exception, ex:
                log(40, format_exc())
                self.conn = MySQLdb.connect(**self.db_config)
                log(20, "connect to db by %s again " % str(self.db_config)) 

        if rowbyrow == True:
            if dictcur == True:
                return self.conn.cursor(MySQLdb.cursors.SSDictCursor)
            else:
                return self.conn.cursor(MySQLdb.cursors.SSCursor)
        else:
            if dictcur == True:
                return self.conn.cursor(MySQLdb.cursors.DictCursor)
            else:
                return self.conn.cursor()
    
    def select_db(self, db):
        log(20, 'change default database to %s' % db)
        self.conn.select_db(db)

    def run_sql(self, sql, data=None, dictcursor=False, rowbyrow=False, disable_warning=False):
        """ """

        self.cursor = self._get_cursor(dictcursor, rowbyrow)
        if disable_warning == True:
            self.cursor._defer_warnings = True
        if data in (None, [], {}):
            log(20, " ".join(x.strip() for x in sql.split('\n')))
        else:
            log(20, " ".join(x.strip() for x in sql.split('\n')) % data)
        self.cursor.execute(sql, data)
        affected_rows = self.cursor.rowcount
        log(20, "rowbyrow is %s return %s rows." % (rowbyrow,affected_rows))
        return affected_rows

    def insert_many(self, sql, data, batch=1000, warnning=False):
        """ """
        self.cursor = self._get_cursor(False, False)
        if warnning == True:
            self.cursor._defer_warnings = True
        
        ldata = len(data)
        log(20, "data length is %s" % ldata)
        log(20, " ".join(x.strip() for x in sql.split('\n')))
        log(5, data)

        subfix = 0
        affected_rows_sum = 0
        while ldata > 0 :
            sub_data = data[subfix:subfix+batch] 
            affected_rows = self.cursor.executemany(sql, sub_data)
            affected_rows_sum += affected_rows
            log(20, "insert %s rows, total %s rows." % (affected_rows, affected_rows_sum))
            subfix += batch
            ldata -= batch
        return affected_rows_sum

    def get_one_row(self):
        """ """
        row = self.cursor.fetchone()
        if row is None:
            log(20, "have fetch all rows by fetchone")
        else:
            log(10, "fetch one row='%s'" % str(row))
        return row 


    def get_all_rows(self):
        """
        failed return None, success will return rows.
        """
        rows = self.cursor.fetchall()
        log(20, "fetch all rows by fetchall")
        log(10, "fetch all rows " + str(rows))
        return rows

