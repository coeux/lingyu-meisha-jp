<?php
include "base.php";
include "config.php";

function show_pro_table()
{
    begin_table('补偿信息');
    show_table_header(array(
        '补偿种类'=>'150px', 
        '补偿值'=>'150px'));

    $inputs = array(
        'partner' => '伙伴id',
        'gold' => '金币',
        'battlexp' => '战历',
        'freeyb' => '免费水晶',
        'fpoint' => '友情点'
    );

    foreach($inputs as $key=>$value)
    {
        $n = $value;
        $k = $key;
        $v = 0;
        show_table_row_input($n,$k,$v);
    }

    end_table();
}
?>
<html>
<meta charset="UTF-8">
<body >
<center>
<form method="post" action="send_msg.php" >
<div align="center">补偿范围
<select name="range">
<option value="1">全部</option>
<option value="2">指定</option>
</select>
用户uid<input type="text" name="ip" size="10" value="" />
</div>
<?php
show_pro_table();
?>
</form>
</center>
</body>
</html>
