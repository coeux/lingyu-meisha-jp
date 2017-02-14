#conf = {'dbi_conf':{'user':'root', 'unix_socket':'/tmp/mysql.sock', 'db':'God_statics'},
conf = {'dbi_conf':{'user':'root', 'passwd':'erikaerika', 'host':'mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com', 'db':'online_statics'},
        'tmpdir':'/tmp/',
        'logfile':'/data/logs/debug',
        'loglevel':1,
        'lock':'/tmp/nuts.lock',
       }
mysql_opt = {'sort_buffer_size':'536870912',
             'max_heap_table_size':'536870912',
             'tmp_table_size':'536870912'}
games = {
    'NICE':{'usertype':'CalStaticsData',},
#    'TEST':{'usertype':'Hello World',},
        }

def getconf(game):
    kv = {}
    kv.update(games.get(game.upper()))
    return kv

if __name__ == '__main__':
    print ( """the usertype of test is %(usertype)s """ % getconf('test') )
