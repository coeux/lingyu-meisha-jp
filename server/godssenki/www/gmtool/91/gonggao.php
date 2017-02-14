<html>
<meta charset="UTF-8">
<body >
<center>
<form method="post" action="send_msg.php" >
<div align="center">服务器id
<select name="serid">
<option value="1">1</option>
</select>
服务器地址
<input type="text" name="ip" size="10" value="192.168.4.240" />
<input type="text" name="port" size="10" value="52200" />
</div>
<div align="center">输入公告1
<input type="text" name="msg1" size="63" value="" />
</div>
<div align="center">输入公告2
<input type="text" name="msg2" size="63" value="" />
</div>
<div align="center">输入公告3
<input type="text" name="msg3" size="63" value="" />
</div>
<input type="submit" name="gonggao" value="发送"/>
</form>
</center>
</body>
</html>
