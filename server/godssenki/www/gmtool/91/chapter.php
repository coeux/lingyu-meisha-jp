<?php
include "base.php";
include "config.php";
include "repo.php";

function show_chapter($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select roundid, eliteid, zodiacid, treasure from UserInfo where uid=$uid_";
    $result = exec_select($query);
    show_chapter_table($result);
    mysql_free_result($result);
}

function show_chapter_table($result_)
{
    begin_table('角色关卡信息');

    $row_num = mysql_num_rows($result_);
    //echo '<p align="center">找到'.$row_num.'个道具</p>';

    show_table_header(array(
        '关卡类型'=>'150px', 
        '最高关卡id'=>'150px',
		'最高关卡名称'=>'150px'
        ));
	
    while($row = mysql_fetch_array($result_))
    {
        show_table_row_chapter($row, 4, array(
			"普通关卡",
			"精英关卡",
			"12宫",
			"巨龙宝库"
			));
    }

    end_table();
}

function show_table_row_chapter($row_, $n_, $col_)
{
   // echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
        echo '<tr>';
		echo format('<td align="center">{0}</td>', $col_[$i]);
		echo format('<td align="center">{0}</td>', $row_[$i]);
		
		if($row_[$i] == 0 || $row_[$i] == 3000)
		{
		  	echo '<td align="center">无</td>';
		}
		else
		{
			if($i<2)
			{
				$rp_round = repo_mgr_t::ins()->get_repo('round');
				$round = $rp_round[$row_[$i]];
				echo format('<td align="center">{0}</td>', $round->name);
			}
			else if($i==2)
			{
				$rp_z = repo_mgr_t::ins()->get_repo('zodiac');
				$zod = $rp_z[intval(($row_[$i]+9)/10)];
				echo format('<td align="center">{0}({1})第{2}关</td>', $zod->name,($row_[$i]-1)/10%10+1  , ($row_[$i]-1)%10+1);
			}
			else if($i==3)
			{
			  	echo format('<td align="center">第{0}层</td>', $row_[$i]-4000);
			}
		}

		echo '</tr>';
    }

}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body>
<?php
    show_chapter(_get('param'));
?>
</body>
</html>
