<?php
include 'base.php';

function make_pack($cmd_, $msg_)
{
    $len = strlen($msg_);
    $bytes = '';
    $size = 0;

    $bytes.=pack( 'V', $len); 
    $size += 4;
    $bytes.=pack( 'v', $cmd_); 
    $size += 2;
    $bytes.=pack( 'v', 0); 
    $size += 2;
    $bytes.=$msg_;
    $size += $len;
    return array('bytes'=>$bytes, 'size'=>$size);
}

function write_sock($ip_, $port_, $bytes_, $size_)
{
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ($socket === false) 
    {
        echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
        return false;
    } 
    $result = socket_connect($socket, $ip_, $port_);
    if($result === false) 
    {
        echo "socket_connect() failed.\nReason: ($result) " . socket_strerror(socket_last_error($socket)) . "\n";
        return false;
    }
    $ret = socket_write($socket, $bytes_, $size_);
    if ($ret == $size_)
    {
        socket_close($socket);
        return true;
    }
    else
        return false;
}

function send_gonggao()
{
    $serid = $_POST['serid'];
    $ip = $_POST['ip'];
    $port = (int)$_POST['port']+(int)$serid;
    $msg1 = $_POST['msg1'];
    $msg2 = $_POST['msg2'];
    $msg3 = $_POST['msg3'];

    $msgs = array('infos'=>array($msg1, $msg2, $msg3));
    $broad = array('msg_cmd'=>4373, 'msg'=>json_encode($msgs));
    $pk = make_pack(1300, json_encode($broad));
    if (write_sock($ip, $port, $pk['bytes'], $pk['size']))
    {
        show_msg('发送公告成功!', '');
    }
    else 
    {
        show_error("发送公告失败!\n",'');
    }
}
?>

<?php
if (!empty($_POST['gonggao']))
{
    send_gonggao();
}

?>
