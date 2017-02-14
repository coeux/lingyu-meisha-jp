#!/bin/sh
day=$(date +'%Y-%m-%d %T')
day_date=$(date +'%Y-%m-%d')
day_yesterday_date=$(date -d yesterday +'%Y-%m-%d')
echo ${day}

#参数，需要修改
db_name="God_statics"
mysql_bin="/home/mysql/mysql/bin"
mysql="$mysql_bin/mysql -S /tmp/mysql.sock -uroot"

#更新数据中心的实时数据
echo "insert into stat_online_new(domain,hostnum,stat_time,num) select domain,hostnum,'$day',count(*) from Online where domain<>'' group by domain,hostnum" | $mysql $db_name
echo "insert into stat_pay_5mins(domain,hostnum,stat_time,num) select domain,hostnum,'$day',sum(rmb) from YBLog where domain<>'' and tradetm>'$day_date' group by domain,hostnum" | $mysql $db_name

#更新手机版数据中心的数据
echo "insert ignore into stat_yblog_by_date(day) values('$day_date');" | $mysql $db_name
echo "update stat_yblog_by_date join ( select '$day_date' day ,sum(rmb) s from YBLog ) b using(day) set stat_yblog_by_date.payyb = b.s;" | $mysql $db_name
echo "update stat_yblog_by_date join ( select '$day_date' day ,count(*) c from NewAccount where ctime>'$day_date' ) b using(day) set stat_yblog_by_date.new = b.c;" | $mysql $db_name
echo "update stat_yblog_by_date join ( select '$day_date' day ,count(distinct aid) c from QuitLog ) b using(day) set stat_yblog_by_date.dau = b.c;" | $mysql $db_name
echo "update stat_yblog_by_date join 
    ( select '$day_date' day ,count(distinct aid) c from Account a join QuitLog b using(aid) where a.firstdate>'$day_yesterday_date' ) b
    using(day) set stat_yblog_by_date.ret = b.c ;" | $mysql $db_name
