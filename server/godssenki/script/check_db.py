import MySQLdb
test_db = 'niceshot_base'
online_db_list = ['niceserver2', 'niceserver_online', 'niceserver_online_2', 'niceserver_online_3']
all_db_list = ['niceshot_base', 'niceserver2', 'niceserver_online', 'niceserver_online_2', 'niceserver_online_3']

def get_str(list_):
    str = "("
    for db in list_:
        str = str + "'" + db + "', "
    str = str[0:-2]+ ")"
    return str

sql_str = []
try:
    conn=MySQLdb.connect(host="mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com", user="root", passwd="erikaerika");

    cur=conn.cursor()
    conn.select_db('INFORMATION_SCHEMA')

    sql = "SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `COLUMN_NAME` FROM COLUMNS WHERE `TABLE_SCHEMA` in " + get_str(all_db_list)
    cur.execute(sql)
    result=cur.fetchall()
    ary = {}
    for r in result:
        if not ary.has_key(r[0]):
            ary[r[0]] = {}
        if not ary[r[0]].has_key(r[1]):
            ary[r[0]][r[1]] = []
        ary[r[0]][r[1]].append(r[2])

    for db in online_db_list:
        for table in ary[test_db].keys():
            if ary[db].has_key(table):
                table_ary = list(set(ary[test_db][table]).difference(set(ary[db][table])))
                if len(table_ary) > 0:
                    sql_str_buff = "INSERT INTO " + db + "." + table + get_str(table_ary) + " SELECT"
                    print db + " ," + table + ", don't have cols: ",
                    print table_ary
            else:
                print db + " don't have table: " + table

    cur.close()
    #conn.commit()
    conn.close()
except MySQLdb.Error, e:
    print "Mysql Error %d: %s" % (e.args[0], e.args[1])

