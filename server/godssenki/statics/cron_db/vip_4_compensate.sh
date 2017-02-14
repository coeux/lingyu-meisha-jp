#!/bin/sh

day=$(date +'%Y-%m-%d %T')
echo ${day}

db_name="God_android"
mysql_bin="/app/mysql56/bin"
mysql="$mysql_bin/mysql -S /log/mysql56/mysql.sock -uroot -Bs"

for uid in $(echo "select a.uid from UserID a left join Compensate b using(uid) where b.uid is null" | $mysql $db_name);
    do echo "insert into Compensate(uid,resid,count) values(${uid},10007,4)" | $mysql $db_name
done
