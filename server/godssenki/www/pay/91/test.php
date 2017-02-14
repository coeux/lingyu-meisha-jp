<?php
include "../base.php";

//战神91平台
$MyAppId = 110580;
$MyAppKey = 'cb4609b7d46c04d6a03cd7577754939daf32c51bbb55837c';

#$Res = pay_result_notify_process($MyAppId,$MyAppKey);

#print_r($Res);
if (!nt_game(1, 124602, 10187))
{
    elog("notify game server failed! sid:1");
}
function pay_result_notify_process($MyAppId,$MyAppKey){
	
	$Result = array();//存放结果数组

    $Result["ErrorCode"] =  "0";//注意这里的错误码一定要是字符串格式
    $Result["ErrorDesc"] =  urlencode("接收失败");

    if (empty($_GET)){
        $Result["ErrorDesc"] =  urlencode("no get");
		return urldecode(json_encode($Result));
    }


    $check_items = array(
	    "AppId","Act","ProductName","ConsumeStreamId","CooOrderSerial","Uin","GoodsId","GoodsInfo","GoodsCount","OriginalMoney","OrderMoney","Note","PayStatus","CreateTime","Sign"
    );

    foreach($check_items as $value){
        if (!isset($_GET[$value])){
            $Result["ErrorDesc"] =  urlencode("no set $value");
            return urldecode(json_encode($Result));
        }
    }
	
	$AppId 				= $_GET['AppId'];//应用ID
	$Act	 			= $_GET['Act'];//操作
	$ProductName		= $_GET['ProductName'];//应用名称
	$ConsumeStreamId	= $_GET['ConsumeStreamId'];//消费流水号
	$CooOrderSerial	 	= $_GET['CooOrderSerial'];//商户订单号
	$Uin			 	= $_GET['Uin'];//91帐号ID
    $GoodsId		 	= $_GET['GoodsId'];//商品ID
	$GoodsInfo		 	= $_GET['GoodsInfo'];//商品名称
	$GoodsCount		 	= $_GET['GoodsCount'];//商品数量
	$OriginalMoney	 	= $_GET['OriginalMoney'];//原始总价（格式：0.00）
	$OrderMoney		 	= $_GET['OrderMoney'];//实际总价（格式：0.00）
	$Note			 	= $_GET['Note'];//支付描述
	$PayStatus		 	= $_GET['PayStatus'];//支付状态：0=失败，1=成功
	$CreateTime		 	= $_GET['CreateTime'];//创建时间
	$Sign		 		= $_GET['Sign'];//91服务器直接传过来的sign
	
	//支付没有成功
	if((int)$PayStatus != 1){
		$Result["ErrorCode"] =  "1";//注意这里的错误码一定要是字符串格式
		$Result["ErrorDesc"] =  urlencode("接收成功, 平台支付失败");
        return urldecode(json_encode($Result));
	}
	
	//此值不为1时就是无效操作
	if($Act != 1){
		$Result["ErrorCode"] =  "3";//注意这里的错误码一定要是字符串格式
		$Result["ErrorDesc"] =  urlencode("Act无效");
        return urldecode(json_encode($Result));
	}
	
	//如果传过来的应用ID开发者自己的应用ID不同，那说明这个应用ID无效
	if($MyAppId != $AppId){
		$Result["ErrorCode"] =  "2";//注意这里的错误码一定要是字符串格式
		$Result["ErrorDesc"] =  urlencode("AppId无效");
        return urldecode(json_encode($Result));
	}

	
	//按照API规范里的说明，把相应的数据进行拼接加密处理
	$sign_check = md5($MyAppId.$Act.$ProductName.$ConsumeStreamId.$CooOrderSerial.$Uin.$GoodsId.$GoodsInfo.$GoodsCount.$OriginalMoney.$OrderMoney.$Note.$PayStatus.$CreateTime.$MyAppKey);
	if($sign_check == $Sign){//当本地生成的加密sign跟传过来的sign一样时说明数据没问题
        $db = begin_sql();
        if ($db != null)
        {
            $res = do_sql("select * from Pay where serid=$CooOrderSerial");
            if ($res != null)
            {
                if (mysql_affected_rows() <= 0)
                {
                    elog("db no seria serid:$CooOrderSerial");
                    $Result["ErrorCode"] =  "4";//注意这里的错误码一定要是字符串格式
                    $Result["ErrorDesc"] =  urlencode("数据库中不存在的订单号:$CooOrderSerial");
                    return urldecode(json_encode($Result));
                }

                $row = mysql_fetch_array($res, $MYSQL_ASSOC);
                $sid = (int)$row['sid']; 
                $uid = (int)$row['uid']; 
                $state = (int)$row['state'];

                if ($state == 1)
                {
                    date_default_timezone_set('PRC');
                    $str_date = date("Y-m-d H:i:s");
                    if (do_sql("update Pay set state=2, paytime='$str_date', pay_rmb='$OrderMoney' where serid=$CooOrderSerial"))
                    {
                        if (!nt_game($sid, $uid, $CooOrderSerial))
                        {
                            elog("notify game server failed! sid:$sid");
                        }
                    }
                    else
                    {
                        elog("update db failed!, serid:$CooOrderSerial");
                        $Result["ErrorCode"] =  "10";//注意这里的错误码一定要是字符串格式
                        $Result["ErrorDesc"] =  urlencode("接收成功，更新数据库失败");
                        return urldecode(json_encode($Result));
                    }
                }
                else
                {
                    elog("order state error! state:$state, serid:$CooOrderSerial");
                    $Result["ErrorCode"] =  "11";//注意这里的错误码一定要是字符串格式
                    $Result["ErrorDesc"] =  urlencode("错误的支付状态:$state");
                    return urldecode(json_encode($Result));
                }
            }
            else
            {
                elog("query sql failed!, serid:$CooOrderSerial");
                $Result["ErrorCode"] =  "12";//注意这里的错误码一定要是字符串格式
                $Result["ErrorDesc"] =  urlencode("查询数据库失败!");
                return urldecode(json_encode($Result));
            }
        }
        else
        {
            elog("begin sql failed!, serid:$CooOrderSerial");
            $Result["ErrorCode"] =  "13";//注意这里的错误码一定要是字符串格式
            $Result["ErrorDesc"] =  urlencode("链接数据库失败!");
            return urldecode(json_encode($Result));
        }

        $Result["ErrorCode"] =  "1";//注意这里的错误码一定要是字符串格式
        $Result["ErrorDesc"] =  urlencode("接收成功");
        return urldecode(json_encode($Result));
	}else{
		$Result["ErrorCode"] =  "5";//注意这里的错误码一定要是字符串格式
		$Result["ErrorDesc"] =  urlencode("Sign无效");
		return urldecode(json_encode($Result));
	}
}

function nt_game($sid_, $uid_, $orderid_)
{
    $msgs = array('uid'=>$uid_, 'serid'=>(int)$orderid_);
    $wrap= array('msg_cmd'=>1201, 'sid'=>(4<<16|$sid_), 'msg'=>json_encode($msgs));
    $pk = make_pack(1002, json_encode($wrap));
    if (!write_sock($pk['bytes'], $pk['size']))
    {
        elog("nt game failed! orderid:$orderid_");
        return false;
    }
    return true;
}

?>
