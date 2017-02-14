<?php
function call($param_){
    $method = $param_->method;
    $domain = $param_->domain;
    foreach($param_->servers as $s)
    {
        exec("sudo /etc/init.d/godser $method $domain $s->ver $s->prog $s->sid", $ret, $status);
        $s->status = $status;
        $s->ret = $ret;
    }
    return true;
}
?>

<?php
    $inner_ip = array(
        '140.207.49.170'=>1,
        '10.0.128.17'=>1
    );

    $ip = $_SERVER["REMOTE_ADDR"];
    if ($inner_ip[$ip] != 1)
        return;

    $json = file_get_contents("php://input");
    $param = json_decode($json);

    if (call($param)){
        echo json_encode($param);
    }
?>
