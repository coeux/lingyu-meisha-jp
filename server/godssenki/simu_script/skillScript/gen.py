# home.zhenliang@gmail.com
# auto unity build

import os
import sys

def walk(path) :  
    for filename in os.listdir(path) :
        abspath = path + '\\' + filename
        if os.path.isdir(abspath) :  
            walk(abspath) 
        elif filename.endswith('.lua') and filename != 'afx.lua' :         
            print 'require "./skillScript/' + abspath[2:].strip('.lua') + '"'

sys.stdout = open('./afx.lua', 'w')
walk(os.curdir)

