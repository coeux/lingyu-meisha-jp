<?php
include "base.php";
include "config.php";
session_start();

if(isset($_SESSION['view']))
	$_SESSION['view'] = $_SESSION['view'] +1;
else $_SESSION['view'] = 1;

//$cfg = config_t::ins();
//if(isset($_SESSION['config']))
	
?>
<html>
<body>
<center>
<?php
/*
	if(!empty($_POST['sub'])){
		$_plat	= $_POST['platform'];
		$_hostnum = $_POST['hostnum'];
		echo $_plat . ':'. $_hostnum ;
		$cfg = config_t::ins();
		$cfg->set_default_db($_plat); 
		$cfg->reset_db();
		echo $cfg->mysql_db;	
		$cfg->set_default_hostnum($_hostnum);	
		$cfg->reset_hostnum();
	}
	*/
?>	
	<form method = "post" action = "platform.php">
		<?php
			show_table_row_option('选择平台', 'platform', array(
				'91' => 'God_91',
				'360' => 'God_360'
				)	
			);
			show_table_row_input('输入服务器:', 'hostnum', '');

		?>
		<input type = "submit" name = "sub" value = "确认"/>
	</form>
</body>
</html>
