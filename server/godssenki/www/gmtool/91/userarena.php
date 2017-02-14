<?php
include "base.php";
include "config.php";
//include "repo.php";

function show_userarena($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select fp ,rank from UserInfo where uid=$uid_";
    $result = exec_select($query);
    show_userarena_table($result);
    mysql_free_result($result);
}

function show_userarena_table($result_)
{
    begin_table('角色竞技场排名');

    $row_num = mysql_num_rows($result_);
    //echo '<p align="center">找到'.$row_num.'个道具</p>';

	if($row_num == 0){
		echo "<p align=center >该角色没有公会</p>";
		return ;
	}
    show_table_header(array(
		'战力'=>'150px',
        '竞技场排名'=>'150px' 
        ));
	
    while($row = mysql_fetch_array($result_))
    {
        show_table_row_rank($row, 2);
    }

    end_table();
}

function show_table_row_rank($row_, $n_)
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
    show_userarena(_get('param'));
?>
</body>
</html>
