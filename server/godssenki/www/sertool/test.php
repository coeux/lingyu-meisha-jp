<html>
<meta charset="UTF-8">
<body >
<center>
<form method="post" action="test.php" >
<input type="submit" name="start" value="启动"/>
<input type="submit" name="status" value="状态"/>
<input type="submit" name="version" value="版本"/>
<input type="submit" name="close" value="关闭"/>
</form>
</center>
</body>
</html>
<?php
if (isset($_POST['start']))
{
exec("sudo /etc/init.d/godser schstart 91 1.2.0 scene 1", $ret, $status);
echo $status;
echo "<p>";
print_r($ret);
echo "<p>";
}
if (isset($_POST['status']))
{
$ret = 0;
exec("sudo /etc/init.d/godser status 91 1.2.0 scene 1", $ret, $status);
echo $status;
echo "<p>";
print_r($ret);
echo "<p>";
}
if (isset($_POST['version']))
{
$ret = 0;
exec("sudo /etc/init.d/godser version 91 1.2.0 scene 1", $ret, $status);
echo $status;
echo "<p>";
print_r($ret);
echo "<p>";
}
if (isset($_POST['close']))
{
exec("sudo /etc/init.d/godser schstop 91 1.2.0 scene 1", $ret, $status);
echo $status;
echo "<p>";
print_r($ret);
echo "<p>";
}
?>
