#!/bin/bash
ver=$1
servers=("
    10.10.10.225 
    10.10.10.29
    10.10.10.64
    10.10.10.158
    ")
for var in ${servers[@]};
do
    echo ============ Update Version $ver To $var
    if [ "$var" == "10.10.10.158" ] 
    then
        rsync -avz $ver.zip root@$var:/data/app/ -e 'ssh -o StrictHostKeyChecking=no -i cszs-key.pem -p 60020'
        ssh root@$var -o StrictHostKeyChecking=no -i cszs-key.pem -p 60020 "cd /data/app/ && unzip -o $ver.zip && rm $ver.zip && cd d/ && ./startup.sh"
    else
        rsync -avz $ver.zip root@$var:/data/app/ -e 'ssh -o StrictHostKeyChecking=no -i cszs-key.pem -p 22'
        ssh root@$var -o StrictHostKeyChecking=no -i cszs-key.pem -p 22 "cd /data/app/ && unzip -o $ver.zip && rm $ver.zip && cd d/ && ./startup.sh"
    fi
done
