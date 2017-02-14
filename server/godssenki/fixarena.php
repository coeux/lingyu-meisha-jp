<?php
$conn = mysql_connect("mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com", "root", "erikaerika");
mysql_select_db('niceshot_jp', $conn);
$result = mysql_query("SELECT uid, rank FROM UserInfo where ctime > '2015-08-31 00:00:00' and hostnum = 1 order by rank asc");
$i = 1;
while($row = mysql_fetch_array($result))
{
    mysql_query("update UserInfo set rank = $i where uid = " . $row['uid']);
    $i++;
}

mysql_close($conn);
