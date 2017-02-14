#!/bin/sh
mysql_bin="/home/dskong/mysql_5.6.10/bin"
mysql="$mysql_bin/mysql -S /home/dskong/mysql.5.6.sock -uroot"
day=`date -d yesterday +'%Y%m%d'`

#参数，需要修改
db_name="God_statics"
data_dir="/home/dskong/mysql_5.6.10_data/data/God_statics"


quit="QuitLog$day"
quit_tmp="$db_name.QuitLogTmp"
quit_cur="$db_name.QuitLog"
quit_date="$db_name.$quit"
echo "
CREATE TABLE $quit_tmp like $quit_cur;
RENAME TABLE $quit_cur TO $quit_date, $quit_tmp TO $quit_cur;
ALTER TABLE $quit_date ENGINE=MyISAM;
" |$mysql $db_name
$mysql_bin/myisampack -s $data_dir/$quit
$mysql_bin/myisamchk -rq -a -S -s $data_dir/$quit

login="LoginLog$day"
login_cur="$db_name.Online"
login_date="$db_name.$login"
echo "
CREATE TABLE $login_date select * from $login_cur;
ALTER TABLE $login_date ENGINE=MyISAM;
" |$mysql $db_name
$mysql_bin/myisampack -s $data_dir/$login
$mysql_bin/myisamchk -rq -a -S -s $data_dir/$login

buy="BuyLog$day"
buy_tmp="$db_name.BuyLogTmp"
buy_cur="$db_name.BuyLog"
buy_date="$db_name.$buy"
echo "
CREATE TABLE $buy_tmp like $buy_cur;
RENAME TABLE $buy_cur TO $buy_date, $buy_tmp TO $buy_cur;
ALTER TABLE $buy_date ENGINE=MyISAM;
" |$mysql $db_name
$mysql_bin/myisampack -s $data_dir/$buy
$mysql_bin/myisamchk -rq -a -S -s $data_dir/$buy

consume="ConsumeLog$day"
consume_tmp="$db_name.ConsumeLogTmp"
consume_cur="$db_name.ConsumeLog"
consume_date="$db_name.$consume"
echo "
CREATE TABLE $consume_tmp like $consume_cur;
RENAME TABLE $consume_cur TO $consume_date, $consume_tmp TO $consume_cur;
ALTER TABLE $consume_date ENGINE=MyISAM;
" |$mysql $db_name
$mysql_bin/myisampack -s $data_dir/$consume
$mysql_bin/myisamchk -rq -a -S -s $data_dir/$consume

yb="YBLog$day"
yb_tmp="$db_name.YBLogTmp"
yb_cur="$db_name.YBLog"
yb_date="$db_name.$yb"
echo "
CREATE TABLE $yb_tmp like $yb_cur;
RENAME TABLE $yb_cur TO $yb_date, $yb_tmp TO $yb_cur;
ALTER TABLE $yb_date ENGINE=MyISAM;
" |$mysql $db_name
$mysql_bin/myisampack -s $data_dir/$yb
$mysql_bin/myisamchk -rq -a -S -s $data_dir/$yb
