<?php 
include 'base.php';
include 'config.php';

function show_user_table($result_)
{
    begin_table('用户信息查询结果');
    show_table_header(array(
        '账户id' => '150px',
        '角色id'=>'150px', 
        '角色名'=>'150px', 
        '配置id'=>'100px', 
        '等级' => '80px', 
        //'创建时间' => '150px',
        '操作' => '150px'));

    while($row = mysql_fetch_array($result_))
    {
        show_table_row_submit($row, 5, array(
            '查询数值' => array('yonghu.php', 'param', $row['uid']),
            '查询包裹' => array('beibao.php', 'param', $row['uid']),
            '查询伙伴' => array('huoban.php', 'param', $row['uid']),
			'充值记录' => array('pay.php', 'param', $row['uid']),
			'查询关卡' => array('chapter.php', 'param', $row['uid']),
			'查询公会' => array('userguildinfo.php', 'param', $row['uid']),
			'查询排名' => array('userarena.php', 'param', $row['uid']),
			'查询消费' => array('query_event.php', 'param', $row['uid'])	
        ));
    }
    end_table();
}

function search_user($name)
{
    $username="%".$name."%";
    $query = '';
    if (strlen($name) == 0){
    	$query = "select aid,uid,nickname,resid,grade from UserInfo where nickname like '$username' limit 20";
    }else{
    	$query = "select aid,uid,nickname,resid,grade from UserInfo where nickname like '$username'";
    }
    $result = exec_select($query);

    $row_num = mysql_num_rows($result);
    if (0 == $row_num){
        show_error('当前角色不存在');
    }else{
        echo '<p align="center">找到'.$row_num.'个用户</p>';
        show_user_table($result);
    }
    mysql_free_result($result);
}
?>
<html>
<meta charset="UTF-8">
<body>
<form  method="get" action="">
<div align="center">角色名<input type="text" name="username" /><input type="submit" value="查询" /></div>
</form>
<?php 
    search_user(_get('username'));
?>
</body>
</html>
