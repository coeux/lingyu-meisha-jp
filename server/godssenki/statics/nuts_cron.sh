#!/bin/sh
export PATH=$PATH:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/mysql/bin/

echo "start at "$(date +'%Y-%m-%d %H:%M:%S')

python /home/mysql/statics/nuts_main.py -a

echo "end at "$(date +'%Y-%m-%d %H:%M:%S')
