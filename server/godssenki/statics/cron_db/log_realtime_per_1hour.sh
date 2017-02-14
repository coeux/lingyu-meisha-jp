#!/bin/sh
day=$(date +'%Y-%m-%d %T')
day_date=$(date +'%Y-%m-%d')
day_yesterday_date=$(date -d yesterday +'%Y-%m-%d')
echo ${day}

#参数，需要修改
db_name="God_statics"
mysql_bin="/home/mysql/mysql/bin"
mysql="$mysql_bin/mysql -S /tmp/mysql.sock -uroot"

#更新实时数据
#echo "delete from stat_realtime where stat_time<'$day_date';" | $mysql $db_name
echo "delete from stat_realtime;" | $mysql $db_name
echo "insert ignore into stat_realtime(stat_time,domain,hostnum) select distinct '$day_date',domain,hostnum from QuitLog;" | $mysql $db_name
echo "insert ignore into stat_realtime(stat_time,domain,hostnum) select distinct '$day_date',domain,hostnum from YBLog;" | $mysql $db_name

#更新充值金额
echo "update stat_realtime join 
    ( select '$day_date' stat_time,domain,hostnum,sum(rmb) s from YBLog group by stat_time,domain,hostnum) b 
    using(stat_time,domain,hostnum) set stat_realtime.payyb = b.s;" | $mysql $db_name

#更新付费人数
echo "update stat_realtime join 
    ( select '$day_date' stat_time,domain,hostnum,count(distinct aid) c from YBLog where rmb<>0 group by stat_time,domain,hostnum) b 
    using(stat_time,domain,hostnum) set stat_realtime.paycount = b.c;" | $mysql $db_name

#更新注册
echo "update stat_realtime join 
    ( select '$day_date' stat_time,domain,1 hostnum,count(*) c from NewAccount group by stat_time,domain,hostnum) b 
    using(stat_time,domain,hostnum) set stat_realtime.new = b.c;" | $mysql $db_name

#更新活跃 
echo "update stat_realtime join 
    ( select '$day_date' stat_time,domain,hostnum,count(distinct aid) c from QuitLog group by stat_time,domain,hostnum) b 
    using(stat_time,domain,hostnum) set stat_realtime.dau = b.c;" | $mysql $db_name

#更新前日新增的回流
echo "update stat_realtime join 
    ( select '$day_date' stat_time ,b.domain domain,b.hostnum hostnum,count(distinct aid) c from Account a join QuitLog b using(domain,aid) where a.firstdate>'$day_yesterday_date' ) b
    using(stat_time,domain,hostnum) set stat_realtime.ret = b.c ;" | $mysql $db_name
