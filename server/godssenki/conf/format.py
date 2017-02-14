#!/usr/bin/python  
#coding=utf-8  

import sys  
reload(sys)   
sys.setdefaultencoding('utf8') 

import codecs
import glob
import os
import json
import sys
from io import BytesIO

src_path = sys.argv[1]
dst_path = sys.argv[2]

with codecs.open(src_path, "rb", "utf-8") as in_file:
    data = json.load(in_file)

with codecs.open(dst_path,"wb","utf-8") as out_file:
    out_buffer = BytesIO()
    json.dump(data, out_buffer, sort_keys=True, indent=4)
    out_buffer.seek(0)
    for line in out_buffer.readlines():
        line = line.encode('utf-8')
        out_file.write(line.rstrip() + "\n")
