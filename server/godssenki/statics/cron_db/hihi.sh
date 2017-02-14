#!/bin/sh
day=$(date +'%Y-%m-%d %T')
day_date=$(date +'%Y-%m-%d')
echo ${day}

#参数，需要修改
db_name="God_statics"
mysql_bin="/app/mysql56/bin"
mysql="$mysql_bin/mysql -S /log/mysql56/mysql.sock -uroot"

echo "insert into stat_hihi(day,aid,uid,grade,fp) select '$day_date',aid,uid,grade,fp from God_android.UserInfo where lastquit>'$day_date'" | $mysql $db_name
