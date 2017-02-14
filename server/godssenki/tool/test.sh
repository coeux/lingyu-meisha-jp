#!/bin/bash
echo ===============================
echo test
echo ip port test_total test_num
echo ===============================

for ((id=1; id<=$3; id++))
do
    bmac = $[$[id-1]*$4]
    emac = $[bmac + $4]
    echo start test: $id $bmac $emac
    ./gen_robot.sh $1 $2 $bmac $emac 
done
