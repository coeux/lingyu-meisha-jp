<?php
include "base.php";
include "config.php";

function show_user_pro($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select nickname,gold,grade,exp,freeyb,payyb,power,viplevel,vipexp,sceneid,questid,fpoint from UserInfo where uid=$uid_";

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
        'sceneid' => '最后关卡id',
        'questid' => '最后主线任务id',
        'fpoint' => '友情点'
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
    }
    end_table();
}
?>
<html>
<meta charset="UTF-8">
<body>
<form  method="get" action="set_user_pro.php">
<?php
    show_user_pro(_get('param'));
?>
<div align="center">
<input type="submit" value="提交修改"/>
</div>
</form>
</body>
</html>
