<?php
include 'base.php'; 
if (!empty($_POST['peizhi']))
{
    $path_map = array(
        '91'=>'http://god.123u.com/cfg/save_ini.php'
    );

    $state = (int)$_POST['state'];
    $flag = (int)$_POST['flag'];
    $test = (int)$_POST['test'];
    $test_version = $_POST['test_version'];

    $path = $path_map['91'];
    if ($path != null)
    {
        $cfg = array('state'=>$state, 'flag'=>$flag, 'test'=>$test, 'test_version'=>$test_version);
        $ret = post($path, $cfg);
        if (0==(int)$ret)
        {
            show_msg('配置完成!', '');
            return;
        }
    }

    show_error("失败失败!",'');
}
?>
