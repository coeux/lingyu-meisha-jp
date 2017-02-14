#!/bin/bash
echo '===========PUBSHIL==========='
echo 'Enter Version:'
read ver
echo ========================================================
echo PUBLISH version:$ver?y/n
read answer
if [ "$answer" == "y" ] 
then
    cd ../
    svn up
    make install
    cd godssenki
    mkdir $ver
    mkdir $ver/repo
    mkdir $ver/bin
    mkdir $ver/d

    #daemon
    cp ../inst/bin/daemon $ver/d
    cp daemon/startup.sh $ver/d
    cp cszs-key.pem $ver/d
    svn export --force daemon/script/ $ver/d/script

    # exe
    cp ../inst/bin/scene $ver/bin
    cp ../inst/bin/gateway $ver/bin
    cp ../inst/bin/route $ver/bin
    cp ../inst/bin/invcode $ver/bin
    cp ../inst/bin/daemon $ver/bin

    strip --strip-debug $ver/bin/scene
    strip --strip-debug $ver/bin/route
    strip --strip-debug $ver/bin/gateway
    strip --strip-debug $ver/bin/invcode
    strip --strip-debug $ver/bin/daemon

    # repo
    cd repo
    #sh update.sh
    cd ..
    cp repo/*.json $ver/repo/
    cp repo/full_name.txt $ver/repo/
    # lua
    svn export --force ./script $ver/script/
    # sql
    svn export --force ./sql_scripts/ $ver/sql/
    # config
    cp ios.lua $ver/ios.lua
    cp android.lua $ver/android.lua
    # startup
    cp startup $ver/
    cp env.sh $ver/
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
    rsync -avz upversion_test.sh root@211.151.21.199:/data/app/ -e 'ssh -i cszs-key.pem -p 22'
    ssh root@211.151.21.199 -i cszs-key.pem -p 22 "cd /data/app && ./upversion.sh $ver"
fi 
echo PUBLISH OVER!
