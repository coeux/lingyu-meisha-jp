#!/bin/bash
echo '===========PUBSHIL==========='
echo 'Enter Version:'
read ver
echo ========================================================
echo PUBLISH version:$ver?y/n
read answer
if [ "$answer" == "y" ] 
then
    mkdir $ver
    mkdir $ver/repo

    # repo
    cd repo
    #sh update.sh
    cd ..
    cp repo/*.json $ver/repo/
    cp repo/full_name.txt $ver/repo/
    # version
    echo $ver > $ver/version
    # zip 
    cd $ver
    zip -r $ver.zip *
    cp $ver.zip ../
    cd ../
    rm $ver -rf
fi
# rsync 
echo ========================================================
echo COMMIT version:$ver?y/n
read answer
if [ "$answer" == "y" ] 
then
    rsync -avz $ver.zip root@211.151.21.199:/data/app/ -e 'ssh -i cszs-key.pem -p 22'
    ssh root@211.151.21.199 -i cszs-key.pem -p 22 "ls -l /data/app && df -h"
fi
#upversion
echo ========================================================
echo Do UPVERSON:$ver?y/n
read answer
if [ "$answer" == "y" ] 
then
    rsync -avz cszs-key.pem root@211.151.21.199:/data/app/ -e 'ssh -i cszs-key.pem -p 22'
    rsync -avz upversion.sh root@211.151.21.199:/data/app/ -e 'ssh -i cszs-key.pem -p 22'
    ssh root@211.151.21.199 -i cszs-key.pem -p 22 "cd /data/app && ./upversion.sh $ver"
fi 
echo PUBLISH OVER!
