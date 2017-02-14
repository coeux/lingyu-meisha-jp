<?php
header("Content-Type: text/html;charset=utf-8");
error_reporting(E_ALL);
//ini_set('display_errors', '1');

include "config.php";

function elog($msg_)
{
    $cfg = config_t::ins();
    date_default_timezone_set('PRC');
    echo "$msg_";
    error_log(date("[Y-m-d H:i:s]")."[".$msg_."]\n", 3, $cfg->elog_path);
}

function exec_select($query_)
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        elog('connect db error:' . mysql_error());
        return null;
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
    $result = mysql_query($query_);
    if (!$result){
        elog("do sql:$query_, failed! sql error:".mysql_error());
        return null; 
    }
    mysql_close($db);

    return $result;
}

function exec_sql($sql_)
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        elog('connect db error:' . mysql_error());
        return false;
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
    $res = mysql_query($sql_);
    if (!$res){
        elog("do sql:$sql_, failed! sql error:".mysql_error());
        return false;
    }
    mysql_close($db);
    return true;
}

function begin_sql()
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        elog('connect db error:' . mysql_error());
        return null;
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
    return $db;
}

function do_sql($sql_)
{
    $res = mysql_query($sql_);
    if (!$res){
        elog("do sql:$sql_, failed! sql error:".mysql_error());
        return null;
    }
    return $res;
}

function end_sql($db_)
{
    mysql_close($db_);
}

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

function write_sock($bytes_, $size_)
{
    $cfg = config_t::ins();
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ($socket === false) 
    {
        error_log("socket_create() failed: reason: " . socket_strerror(socket_last_error()));
        return false;
    } 
    $result = socket_connect($socket, $cfg->gw_ip, $cfg->gw_port);
    if($result === false) 
    {
        elog("socket_connect() failed.Reason: ($result) " . socket_strerror(socket_last_error($socket)));
        return false;
    }

    $pos = 0;
    while($size_ > $pos)
    {
        $ret = socket_write($socket, substr($bytes_, $pos, $size_-$pos), $size_-$pos);
        if (!$ret)
        {
            elog("socket send failed!");
            break;
        }

        $pos += $ret;
    }

    socket_close($socket);
    return true;
}

?>
