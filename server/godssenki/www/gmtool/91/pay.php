<?php
include "base.php";
include "config.php";


function show_user_pay($uid_){
	echo '<p align = "center">' . '用户ID:'. $uid_ . '</p>';
	begin_sql();
	$query = "select goodsid, goodnum, cristal, reward_cristal, repo_rmb, pay_rmb,paytime, giventime, state from Pay where uid = $uid_";
	$result = do_sql($query);
	if(mysql_affected_rows() > 0){
		show_pay_table($result);
	}
	else {
		echo '<center>';
		echo '无充值记录！！！';
	}

}

function show_pay_table($result_){
	begin_table('充值信息');
	show_table_header(array(
		'goodsid' => '150px',
		'数量' => '150px',
		'购买水晶数' => '150px',
		'奖励的水晶数' => '150px',		
		'表格价格' => '150px',
		'实际支付价格' => '150px',
		'支付时间' => '150px',
		'领取时间' => '150px',
		'交易状态' => '150px'
	));
	while ($row = mysql_fetch_array($result_)){
		// paytime 6	
		if(strcasecmp($row[6], '')==0) $row[6] = '时间无效';
		// giventime 7
		if(strcasecmp($row[7], '')==0){
			 $row[7] = '时间无效';
		}
		// state 8
		if($row[8]==0)$row[8]= '无效';
		elseif ($row[8]==1)$row[8]= '新订单, 未付款';
		elseif ($row[8]==2)$row[8]= '支付完成的订单，未领取';
		elseif ($row[8]==3)$row[8]= '已经关闭的成功订单';
		
		show_table_row($row, 9);	
	}
}

?>
<html>
<meta charset = "UTF-8">
<body>
<?php
	show_user_pay(_get('param'));
?>
</body>
</html>
