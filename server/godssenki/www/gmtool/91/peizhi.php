<html>
<meta charset="UTF-8">
<body >
<center>
<form method="post" action="post_ini.php" >
<p align="center" >
<font color="000000">服务器状态配置</font>
</p>
<?php
include "base.php";
$cfg = json_decode(post('http://god.123u.com/cfg/read_ini.php'));
$state = array('0'=>'运营', '1'=>'维护');
$flag = array('0'=>'关闭', '1'=>'内部测试','2'=>'外部测试');
$test = array('0'=>'关闭', '1'=>'开启');
echo '<p align="center">'.'当前服务器状态:'.$state[$cfg->state].', 测试状态:'.$flag[$cfg->flag].'</p>';
echo '<p align="center">'.'当前测试服务器状态:'.$test[$cfg->test].', 测试版本:'.$cfg->test_version.'</p>';
?>
<table border="1px" bordercolor="#c0a1c1" align="center">
<tr>
<th>配置项</th>
<th>选项</th>
</tr>
<tr>
<td align="center">服务器状态</td>
<td align="center">
<select name="state" >
<option value="0">运营</option>
<option value="1">维护</option>
</select>
</td>
</tr>
<tr>
<td align="center">测试状态</td>
<td align="center">
<select name="flag" >
<option value="0">关闭</option>
<option value="1">内网测试</option>
<option value="2">外网测试</option>
</select>
</td>
</tr>
<tr>
<td align="center">测试服务器状态</td>
<td align="center">
<select name="test" >
<option value="0">关闭</option>
<option value="1">开启</option>
</select>
</td>
</tr>
<td align="center">测试版本</td>
<td align="center">
<input type="text" name="test_version" />
</td>
</table>
<input type="submit" name="peizhi" value="确认"/>
</form>
</center>
</body>
</html>
