#!/bin/bash
echo ===============================
echo cmd   :startup all servers
echo        bash startup
echo cmd   :close all servers
echo        bash startup close
echo ===============================

#echo "truncate table Online;" | /usr/bin/mysql -h10.1.13.24 -uinter -phelloworld God_statics_2 -Bs

servers=("login scene")
#servers=("route gateway login invcode")

php fixarena.php
echo $var
ID=`ps -ef | grep "serveronline" | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
IDNAME=`ps -ef | grep "serveronline" | grep -v "$0" | grep -v "grep" | awk '{print $8}'`
echo process ID   list: $ID
echo process NAME list: $IDNAME
echo "--start kill-------------"
for id in $ID
do
    kill -9 $id
    echo "killed $id"
done
echo "--kill_process finished!-"

if [ "$1" != "close" ] 
then
    for var in ${servers[@]}
    do
        echo startup server:$var
        if [ "$var" = "scene" -a "$1" = "slog" ]; then
            ./$var/$var --serveronline -id 101 -conf ./online.lua
        elif [ "$var" = "scene" -a "$1" = "sgdb" ]; then
            gdb -ex "set args --serveronline -id 1 -conf ./online.lua" ./scene/scene
        else
            ./$var/$var --serveronline -id 101 -conf ./online.lua -d
            ps -aux | grep $var
        fi
    done
fi
