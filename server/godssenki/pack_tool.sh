#!/bin/bash
echo '===========PUBSHIL==========='
echo 'Enter Domain(91, app, 360, test)':
read domain
echo 'Enter Version:'
read ver
echo PUBLISH domain:$domain version:$ver?y/n
read answer
if [ "$answer" == "y" ] 
then
    cd ../
    make install
    cd godssenki
    rm pack/ -rf
    mkdir -p pack/{lib,sql_scripts,repo,simu_tool}
    # exe
    cp ../inst/bin/ pack/ -r
    #svn export --force ./gmtool/ pack/gmtool/
    # sql
    svn export --force ./sql_scripts pack/sql_scripts/
    # repo
    cd repo
    sh update.sh
    cd ..
    cp repo/*.json pack/repo/
    cp repo/full_name.txt pack/repo/
    # lua
    svn export --force ./script pack/script/
    # roboot
    svn export --force ./simu_tool/script pack/simu_tool/script
    svn export --force ./simu_tool/script_robot pack/simu_tool/script_robot
    # config
    cp $domain.lua pack/$domain.lua
    cp godser pack/
    echo $ver > pack/version
    # tar
    cp pack $ver -r
    zip -r $ver.zip $ver/
    rm $ver -rf
    rm pack -rf
    # commit
    echo commit domain:$domain version:$ver?y/n
    read answer
    if [ "$answer" == "y" ]
    then
        #sudo svn up /data/god_server_pack_$domain/
        if [ ! -f  /app/servers/god/$domain ]; then
            sudo mkdir /app/servers/god/$domain
        fi
        sudo rm /app/servers/god/$domain/* -rf
        sudo cp $ver.zip /app/servers/god/$domain/
        cd /app/servers/god/$domain
        sudo unzip $ver.zip
        sudo mv $ver/* ./
        #sudo svn add /data/god_server_pack_$domain/$ver.zip
        #sudo svn ci -m "update $ver" /data/god_server_pack_$domain/$ver.zip
    fi
fi
echo PUBLISH OVER!
