<?php
header("Content-Type: text/html;charset=utf-8");
error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('error_log', dirname(__FILE__).'/error_log');

function _get($str_)
{
    $val = !empty($_GET[$str_]) ? $_GET[$str_] : null;
    return $val;
}

function format() 
{    
    $args = func_get_args();   

    if (count($args) == 0) { return;}   

    if (count($args) == 1) { return $args[0]; }

    $str = array_shift($args);     

    $str = preg_replace_callback('/\\{(0|[1-9]\\d*)\\}/', create_function('$match', '$args = '.var_export($args, true).'; return isset($args[$match[1]]) ? $args[$match[1]] : $match[0];'), $str); 

    return $str; 
} 

function show_error($msg_)
{
    echo format(
    "<div align=\"center\" style=\"border:solid 2px blue\">
    <h3>错误信息</h3>
    <p>{0}</p></div>",
    $msg_
    ); 
}

function show_msg($title_, $msg_)
{
    echo format(
    "<div align=\"center\" style=\"border:solid 2px blue\">
    <h3>{0}</h3>
    <p>{1}</p></div>",
    $title_,
    $msg_
    ); 
}

function begin_table($title_)
{
    echo format('
            <p align="center" >
            <font color="000000">{0}</font>
            </p>
            <table border="1px" bordercolor="#c0a1c1" align="center">'
            ,$title_);
}

function show_table_header($header_)
{
    echo '<tr>';
    foreach($header_ as $key=>$value)
    {
        echo format('<th width="{1}">{0}</th>', $key, $value);
    }
    echo '</tr>';
}

function show_table_row($row_, $n_)
{
    echo '<tr>';
    for($i=0;$i<$n_;$i++)
    {
        echo format('<td align="center">{0}</td>', $row_[$i]);
    }

    echo '</tr>';
}

function show_table_row_submit($row_, $n_, $submits_)
{
    echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
        echo format('<td align="center">{0}</td>', $row_[$i]);
    }

    echo '<td align="center">';
    foreach($submits_ as $key => $value)
    {
        echo format('
                <form  style="float:left;margin:0px;padding:0px" method="get" action="{1}">
                <input type="hidden" name="{2}" value="{3}"/>
                <input type="submit" value="{0}"/>
                </form>
                ',
                $key, $value[0], $value[1], $value[2]);
    }
    echo '</td>';

    echo '</tr>';
}

function show_table_row_input($name_, $key_, $value_)
{
    echo '<tr>';

    echo format('<td align="center">{0}</td><td align="center"><input type="text" name="{1}" value="{2}"/></td>
    ', $name_, $key_, $value_);

    echo '</tr>';
}

function show_table_row_check($row_, $n_, $check_name_)
{
    echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
        if ($i == 0)
        {
            echo format('<td align="left"><input type="checkbox" name="{0}" value="{1}"/>{1}</td>', $check_name_, $row_[$i]);
        }
        else
        {
            echo format('<td align="center">{0}</td>', $row_[$i]);
        }
    }

    echo '</tr>';
}

function end_table()
{
    echo '
            </table>
    ';
}


function exec_select($query_)
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        die('connect db error:' . mysql_error());
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
    $result = mysql_query($query_);
    if (!$result){
        die('query error:' . mysql_error());
    }
    mysql_close();

    return $result;
}

function exec_sql($sql_)
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        die('connect db error:' . mysql_error());
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
    mysql_query($sql_);
    mysql_close();
}

function begin_sql()
{
    $cfg = config_t::ins();
    $db = mysql_connect($cfg->mysql_host,$cfg->mysql_user,$cfg->mysql_pwd);
    if (!$db){
        die('connect db error:' . mysql_error());
    }
    mysql_select_db($cfg->mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
}

function do_sql($sql_)
{
    return mysql_query($sql_);
}

function end_sql()
{
    mysql_close();
}

function new_dbid($name_)
{
    $sql = format("update Id set value=last_insert_id(value+1) where name='{0}'",$name_);
    do_sql($sql);

    $sql = format("select last_insert_id()");
    $result  = do_sql($sql);

    $row = mysql_fetch_array($result);
    print_r($row);
    return $row[0];
}

?>
