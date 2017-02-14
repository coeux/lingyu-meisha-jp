#!/bin/bash
echo ===============================
echo auto gen rebot
echo ip port hostnum mac_begin mac_end 
echo ===============================

for ((id=$4; id<=$5; id++))
do
    echo gen reobot: $id
    ./simu_client/client $1 $2 ./simu_script/ ./repo/ $3 $id
done
