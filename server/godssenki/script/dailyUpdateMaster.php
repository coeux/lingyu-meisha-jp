<?php
$con = mysql_connect('mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com:3306','root','erikaerika');
mysql_select_db('niceserver2',$con);
$sql = "update UserInfo set elite_round_times = '0'";
echo date('Y/m/d H:i:s').$sql."\n";
mysql_query($sql);
$sql = "update UserInfo set elite_reset_times = '0'";
echo date('Y/m/d H:i:s').$sql."\n";
mysql_query($sql);
mysql_close($con);
?>
