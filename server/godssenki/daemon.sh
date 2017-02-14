#!/bin/sh
date
CheckQQ_RET=$(ps -ef|grep "scene --server3 -id 1"|grep -v "grep"|wc -l)
echo $CheckQQ_RET
if [ "$CheckQQ_RET" -lt "1" ];
then
cd  /home/ec2-user/niceserver/niceshot-server/godssenki/ && ./scene/scene --server3 -id 1 -conf ./config-server3.lua -d 
cd /home/ec2-user/niceserver/niceshot-server/godssenki/ && php mail.php 1 
echo 'restart now'
fi

#CheckQQ_RET=$(ps -ef|grep "id 82"|grep -v "grep"|wc -l)
#echo $CheckQQ_RET
#if [ "$CheckQQ_RET" -lt "1" ];
#then
#cd  /data/nice/online-server/godssenki/ && ./scene/scene --serveronline -id 82 -conf ./online.lua -d 
#echo 'restart online now'
#fi
