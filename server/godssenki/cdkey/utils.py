import ConfigParser
import traceback
import sys

import MySQLdb

class Config(object):
    def __init__(self, confile):
        self.cfpar = ConfigParser.ConfigParser()
        self.cfpar.read(confile)

    def get(self, section):
        return dict([[option, self.cfpar.get(section, option)] for option in self.cfpar.options(section)])

def get_conn():
    #config_path = os.path.join(script_dir, 'conf.ini')
    config = Config('./conf.ini')

    try:
        conn_opt = config.get('cdkey_dbmain')
        if conn_opt['port']:
            conn_opt['port'] = int(conn_opt['port'])
        else:
            del conn_opt['port']
    except:
        print traceback.format_exc()
        sys.exit(1)

    try:
        conn = MySQLdb.connect(**conn_opt)
        conn.autocommit(True)
    except:
        print traceback.format_exc()
        sys.exit(1)

    return conn

def attr_autoset(d):
    self = d.pop('self')
    for n, v in d.iteritems():
        setattr(self, n, v)

def test_attr_autoset():
    class Aclass(object):
        def __init__(self, a, b, c=100):
            attr_autoset(locals())
            self.d = 50

    aclass = Aclass(10, 20)
    print aclass.a, aclass.b, aclass.c, aclass.d

def num2jinzhi(num, jinzhi):
    ret = []
    while num >= jinzhi:
        ret.insert(0, num % jinzhi)
        num /= jinzhi
    ret.insert(0, num)

    return ret

def num2readable(num):
    wan = num / 10000
    qian = num % 10000 / 1000
    ge = num % 1000

    ret = ''
    if wan > 0:
        ret += str(wan) + 'W'
    if qian > 0:
        ret += str(qian) + 'K'
    if ge > 0:
        ret += str(ge)

    return ret

if '__main__' == __name__:
    import sys
    #conf = Config(sys.argv[1])
    #print(conf.get(sys.argv[2]))

    #test_attr_autoset()

    #print num2jinzhi(int(sys.argv[1]), int(sys.argv[2]))
    print num2readable(int(sys.argv[1]))
