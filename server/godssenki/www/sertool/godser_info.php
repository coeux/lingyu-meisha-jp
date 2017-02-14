<?php
include "base.php";

$path = "http://10.0.128.17/gmtool/91/godser.php";
$param = array(
    'method'=>'version',
    'domain'=>'91',
    'servers'=>array(
        array(
            'prog'=>'scene',
            'ver'=>'0.0.0',
            'sid'=>'0',
            'ret'=>'',
            'status'=>'1',
        ),
        array(
            'prog'=>'gateway',
            'ver'=>'0.0.0',
            'sid'=>'0',
            'ret'=>'',
            'status'=>'1',
        ),
        array(
            'prog'=>'route',
            'ver'=>'0.0.0',
            'sid'=>'0',
            'ret'=>'',
            'status'=>'1',
        ),
        array(
            'prog'=>'login',
            'ver'=>'0.0.0',
            'sid'=>'0',
            'ret'=>'',
            'status'=>'1',
        ),
        array(
            'prog'=>'invcode',
            'ver'=>'0.0.0',
            'sid'=>'0',
            'ret'=>'',
            'status'=>'1',
        )
    ),
);
$ret = json_decode(post($path,$param));
?>

<?php
include "sm_head.php";
?>

<html>
<meta charset="UTF-8">
<head>
</head>

<body>

<table id=tb_prog_ver align=center>
<?php
    begin_table("服务器信息");

    show_table_header(array(
        '类型' => '150px',
        '信息'=>'150px', 
    ));

    show_table_row(array("平台", $ret->domain), 2);

    foreach($ret->servers as $s){
        show_table_row(array($s->prog."版本", $s->ret[0]), 2);
    }

    end_table();
?>
</table>

</body>
</html>
