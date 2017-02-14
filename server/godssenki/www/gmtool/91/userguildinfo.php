<?php
include "base.php";
include "config.php";
//include "repo.php";

function show_userguildinfo($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select Gang.ggid, name, gm, totalgm from Gang,GangUser  where uid=$uid_ and Gang.ggid = GangUser.ggid and 
		Gang.hostnum = GangUser.hostnum";
    $result = exec_select($query);
    show_userguildinfo_table($result);
    mysql_free_result($result);
}

function show_userguildinfo_table($result_)
{
    begin_table('角色公会信息');

    $row_num = mysql_num_rows($result_);
    //echo '<p align="center">找到'.$row_num.'个道具</p>';

	if($row_num == 0){
		echo "<p align=center >该角色没有公会</p>";
		return ;
	}
    show_table_header(array(
		'公会id'=>'150px',
        '公会名称'=>'150px', 
        '当前贡献'=>'150px',
		'总贡献'=>'150px'
        ));
	
    while($row = mysql_fetch_array($result_))
    {
        show_table_row_userguildinfo($row, 4);
    }

    end_table();
}

function show_table_row_userguildinfo($row_, $n_)
{
    echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
       // echo '<tr>';
		//echo format('<td align="center">{0}</td>', $col_[$i]);
		echo format('<td align="center">{0}</td>', $row_[$i]);


		//echo '</tr>';
    }
	echo '</tr>';
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body>
<?php
    show_userguildinfo(_get('param'));
?>
</body>
</html>
