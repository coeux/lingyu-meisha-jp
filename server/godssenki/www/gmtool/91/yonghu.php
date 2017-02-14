<?php
include "base.php";
include "config.php";

function show_user_pro($uid_)
{
 //   echo format('<input type="hidden" name="uid" value="{0}">', $uid_);
	printf('<input type="hidden" name="uid" value="%s">', $uid_);

	$cfg = config_t::ins();
	$cfg->change_db( "God_statics" );
    $query = "select uid from Online where uid=$uid_";
	begin_sql();
    $result = do_sql($query);

	if (mysql_affected_rows() > 0)
	{
		echo '<p align="center">'.'当前用户在线';
		echo "<p>";
	}
	else
	{
		echo '<p align="center">'.'当前用户不在线';
		echo "<p>";
	}
	end_sql();

	$cfg->reset_db();

    $query = 'select name from Account,UserInfo where Account.aid=UserInfo.aid and UserInfo.uid='.$uid_;
    $rs = exec_select($query);
    $row2 = mysql_fetch_array($rs);

    echo '<p align="center">'.'平台UIN:'.$row2['name'].', 用户UID:'.$uid_.'</p>';

    $query = "select nickname,gold,grade,exp,freeyb,payyb,power,viplevel,vipexp,roundid,questid,fpoint,battlexp,energy,runechip,lastquit  from UserInfo where uid=$uid_";

    $result = exec_select($query);
    
    $row_num = mysql_num_rows($result);
    if (0 == $row_num){
        show_error('当前角色不存在');
    }else{
        show_pro_table($result);
    }
    mysql_free_result($result);

}

function show_pro_table($result_)
{
    begin_table('角色信息');
    show_table_header(array(
        '名称'=>'150px', 
        '数值'=>'150px'));

    $inputs = array(
        'nickname' => '角色名',
        'power' => '体力',
        'grade' => '等级',
        'exp' => '经验',
        'gold' => '金币',
        'freeyb' => '免费元宝',
        'payyb' => '付费元宝',
	    'viplevel' => 'vip等级',
	    'vipexp' => 'vip经验',
        'roundid' => '最后关卡id',
        'questid' => '最后主线任务id',
        'fpoint' => '友情点',
        'battlexp' => '战历',
		'energy' => '活力',
		'runechip' => '符文数量'
			
    );

    while($row = mysql_fetch_array($result_))
    {
        foreach($inputs as $key=>$value)
        {
            $n = $value;
            $k = $key;
            $v = $row[$key];
            show_table_row_input($n,$k,$v);
        }
		// 处理最后在线时间
		$n = '最后在线时间';
		$k = 'lastquit';
		$v = date("Y/m/d H:i:s", $row[$k]); 
		show_table_row_input($n, $k, $v);
    }

    end_table();
}
?>
<html>
<meta charset="UTF-8">
<body>
<?php
    show_user_pro(_get('param'));
?>
</body>
</html>
