#!/bin/bash

rootpath='/data'
runpath="$rootpath/run"
if [ ! -d "$runpath" ]; then
    mkdir "$runpath"
fi

/sbin/ifconfig |grep inet|grep -v 127.0.0.1|grep -v inet6|awk 'NR==1 {print $2}'|tr -d "addr:" > ip
ip=`cat ip`
pid=`ps -ef | grep "daemon -h $ip" | grep -v "$0" | grep -v "grep" |  awk '{print $2}'`
echo $ip
if [ "$pid" == "" ] 
then
    ./daemon -h $ip -p 12345 -s ./script/entry.tw.lua -d
fi
