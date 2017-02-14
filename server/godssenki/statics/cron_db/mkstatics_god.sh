#!/bin/sh
day=`date -d yesterday +'%Y%m%d'`

#参数，需要修改
db_name="online_statics"
#db_name="Statics_test"
data_dir="/data/mysql/data/online_statics"
#data_dir="/data/mysql56/Statics_test"
mysql_bin="/home/mysql/mysql/bin"
#mysql="$mysql_bin/mysql -S /tmp/mysql.sock -uroot"
mysql="mysql -hmxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com -uroot -perikaerika"

#worker部分，不需要修改
quit="QuitLog$day"
quit_tmp="$db_name.QuitLogTmp"
quit_cur="$db_name.QuitLog"
quit_date="$db_name.$quit"
echo "
CREATE TABLE $quit_tmp like $quit_cur;
RENAME TABLE $quit_cur TO $quit_date, $quit_tmp TO $quit_cur;
ALTER TABLE $quit_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$quit
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$quit

login="LoginLog$day"
login_cur="$db_name.Online"
login_date="$db_name.$login"
echo "
CREATE TABLE $login_date select * from $login_cur;
ALTER TABLE $login_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$login
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$login

buy="BuyLog$day"
buy_tmp="$db_name.BuyLogTmp"
buy_cur="$db_name.BuyLog"
buy_date="$db_name.$buy"
echo "
CREATE TABLE $buy_tmp like $buy_cur;
RENAME TABLE $buy_cur TO $buy_date, $buy_tmp TO $buy_cur;
ALTER TABLE $buy_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$buy
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$buy

newaccount="NewAccount$day"
newaccount_tmp="$db_name.NewAccountTmp"
newaccount_cur="$db_name.NewAccount"
newaccount_date="$db_name.$newaccount"
echo "
CREATE TABLE $newaccount_tmp like $newaccount_cur;
RENAME TABLE $newaccount_cur TO $newaccount_date, $newaccount_tmp TO $newaccount_cur;
ALTER TABLE $newaccount_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$newaccount
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$newaccount

consume="ConsumeLog$day"
consume_tmp="$db_name.ConsumeLogTmp"
consume_cur="$db_name.ConsumeLog"
consume_date="$db_name.$consume"
echo "
CREATE TABLE $consume_tmp like $consume_cur;
RENAME TABLE $consume_cur TO $consume_date, $consume_tmp TO $consume_cur;
ALTER TABLE $consume_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$consume
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$consume

yb="YBLog$day"
yb_tmp="$db_name.YBLogTmp"
yb_cur="$db_name.YBLog"
yb_date="$db_name.$yb"
echo "
CREATE TABLE $yb_tmp like $yb_cur;
RENAME TABLE $yb_cur TO $yb_date, $yb_tmp TO $yb_cur;
ALTER TABLE $yb_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$yb
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$yb

#yes=`date -d yesterday +'%Y-%m-%d'`
#echo "insert ignore into online_statics.stat_yblog_by_date select '$yes',sum(rmb) from $yb_date;" | $mysql

event="EventLog$day"
event_tmp="$db_name.EventLogTmp"
event_cur="$db_name.EventLog"
event_date="$db_name.$event"
echo "
CREATE TABLE $event_tmp like $event_cur;
RENAME TABLE $event_cur TO $event_date, $event_tmp TO $event_cur;
ALTER TABLE $event_date ENGINE=MyISAM;
" |$mysql $db_name
#$mysql_bin/myisampack -s $data_dir/$event
#$mysql_bin/myisamchk -rq -a -S -s $data_dir/$event
