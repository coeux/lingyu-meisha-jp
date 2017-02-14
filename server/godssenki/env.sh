#!/bin/bash
echo ===============================
echo cmd   :startup all servers
echo        bash startup
echo cmd   :close all servers
echo        bash startup close
echo ===============================

domain=$1
servers=("route gateway invcode")
for var in ${servers[@]};
do
    echo $var
    ID=`ps -ef | grep "$var" | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
    echo "--start kill-------------"
    for id in $ID
    do
        kill $id
        echo "killed $id"
    done
    echo "--kill_process finished!-"
done

if [ "$1" != "close" ] 
then
    for var in ${servers[@]}
    do
        if [ "$var"  == "gateway" ]
        then
            ./bin/$var -id 1 -conf $domain.lua -d
            ./bin/$var -id 2 -conf $domain.lua -d
            ./bin/$var -id 3 -conf $domain.lua -d
            ./bin/$var -id 4 -conf $domain.lua -d
            echo startup server:$var
        else
            ./bin/$var -id 1 -conf ./$domain.lua -d
            echo startup server:$var
        fi 
        ps -aux | grep $var
    done
fi
