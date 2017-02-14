#!/bin/bash
echo ===============================
echo cmd   :startup all servers
echo        bash startup
echo cmd   :close all servers
echo        bash startup close
echo ===============================

#echo "truncate table Online;" | /usr/bin/mysql -h10.1.13.24 -uinter -phelloworld God_statics_2 -Bs

servers=("route gateway login invcode scene")
for var in ${servers[@]};
do
    echo $var
    ID=`ps -ef | grep "server1" | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
    IDNAME=`ps -ef | grep "server1" | grep -v "$0" | grep -v "grep" | awk '{print $8}'`
    echo process ID   list: $ID
    echo process NAME list: $IDNAME
    echo "--start kill-------------"
    for id in $ID
    do
        kill -9 $id
        echo "killed $id"
    done
    echo "--kill_process finished!-"
done

if [ "$1" != "close" ] 
then
    for var in ${servers[@]}
    do
        echo startup server:$var
        if [ "$var" = "scene" -a "$1" = "sgdb" ]; then
            gdb -ex "set args --server1 -id 1 -conf ./config-server1.lua" ./scene/scene
        else
            ./$var/$var --server1 -id 1 -conf ./config-server1.lua -d
            ps -aux | grep $var
        fi
    done
fi
