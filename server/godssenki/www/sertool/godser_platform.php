<?php
include "config.php";
include "base.php";
include "sm_head.php";
?>

<html>
<meta charset="UTF-8">
<head>
</head>
<body>
<center>
<form method="post" action="godser_platform.php" >
<?php
if (isset($_POST['add_platform_submit']))
{
    add_platform_submit();
}
else if (isset($_POST['do_add_platform']))
{
    do_add_platform();
}
else if (isset($_POST['edit_platform_submit']))
{
    edit_platform_submit();
}
else if (isset($_POST['do_edit_platform']))
{
    do_edit_platform();
    edit_platform_submit();
}
else
    show_platform_table();
?>
</form>
</center>
</body>
</html>
<?php
function show_platform_table()
{
    begin_sql();
    $sql = "select id, name, type from Domain";
    $ret=do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>获取服务器组数据失败!</font></p>";
        return;
    }
    $domaininfo = array();
    $domaininfo[0] ='无';
    while($tmp = mysql_fetch_array($ret))
    {
        $domaininfo[$tmp['id']] = $tmp['name'];
    }


    begin_table_submit("游戏平台", array('add_platform_submit'=>'新建平台'));

    show_table_header(array(
        "id"=>"50px",
        "平台名"=>"80px",
        "运营状态"=>"100px",
        "测试状态"=>"100px",
        "版本测试"=>"250px",
        "运营组"=>"100px",
        "内网测试组"=>"100px",
        "版本测试组"=>"100px",
        "创建时间"=>"100px",
        "操作"=>"50px",
    ));


    $sql = "select id, name, state, test, vertest, ver, outid, inid, vtid, ctime from Platform";
    $ret=do_sql($sql);

    if ($ret == false){
        echo "<p><font color=red>获取平台数据失败!</font></p>";
        return;
    }

    if (mysql_affected_rows() <= 0)
        return;

    $statenames=array(
        '0'=>'运营',
        '1'=>'维护',
    );

    $vertestnames=array(
        '0'=>'关闭',
        '1'=>'开启',
    );

    $testoption=array(
        '0'=>'关闭',
        '1'=>'内网测试',
        '2'=>'外网测试',
    );


    while($row = mysql_fetch_array($ret))
    {
        echo '<tr>';
        echo format('<td align="center">{0}</td>', $row['id']);
        echo format('<td align="center">{0}</td>', $row['name']);
        echo format('<td align="center">{0}</td>', $statenames[$row['state']]);
        echo format('<td align="center">{0}</td>', $testoption[$row['test']]);
        echo format('<td align="center">{0}</td>', $vertestnames[$row['vertest']].",版本号:[".$row['ver']."]");
        echo format('<td align="center">{0}</td>', $domaininfo[$row['outid']]);
        echo format('<td align="center">{0}</td>', $domaininfo[$row['inid']]);
        echo format('<td align="center">{0}</td>', $domaininfo[$row['vtid']]);
        echo format('<td align="center">{0}</td>', $row['ctime']);

        echo '<td>';

        table_btn($row['id'], "编辑", "edit_platform_submit");

        echo '</td>';

        echo '</tr>';
    }

    end_table();
}

function edit_platform_submit()
{
    begin_table("[修改]平台信息");

    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));


    begin_sql();
    $query = "select * from Domain";
    $ret=do_sql($query);
    if ($ret == false){

        echo "<p><font color=red>获取服务器组数据失败!</font></p>";
        //return;
    }
    if (mysql_affected_rows() <= 0)
    {
        show_table_header(array(
                    'select error' => '150px',
                    '参数值'=>'150px', 
                    ));
        return;
    }

    $outidinfos = array();
    $outidinfos['无'] = 0;
    $inidinfos = array();
    $inidinfos['无'] = 0;
    $vtidinfos = array();
    $vtidinfos['无'] = 0;
    while($row = mysql_fetch_array($ret))
    {
        if ($row['type'] == 1)
            $outidinfos[$row['name']] = $row['rid'];
        else if ($row['type'] == 2)
            $inidinfos[$row['name']] = $row['rid'];
        else if ($row['type'] == 3)
            $vtidinfos[$row['name']] = $row['rid'];
    }

    $statenames = array(
       '运营'=>'0', 
       '维护'=>'1', 
    );

    $testnames = array(
       '关闭'=>'0', 
       '内网测试'=>'1', 
       '外网测试'=>'2', 
    );

    $vertestnames = array(
       '关闭'=>'0', 
       '开启'=>'1', 
    );


    $id = $_POST['id'];
    $query = "select * from Platform where id=$id";
    $ret=do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>获取平台数据失败!</font></p>";
        return;
    }
    if (mysql_affected_rows() <= 0)
        return;
    $row = mysql_fetch_array($ret);
    show_table_row_input("平台名", "name", $row['name']);
    show_table_row_option_value("运营", "state", $statenames, $row['state']);
    show_table_row_option_value("测试", "test", $testnames, $row['test']);
    show_table_row_option_value("版本测试", "vertest", $vertestnames, $row['vertest']);
    show_table_row_input("测试版本号", "ver", $row['ver']);
    show_table_row_option_value("运营入口", "outid", $outidinfos, $row['outid']);
    show_table_row_option_value("内网测试入口", "inid", $inidinfos, $row['inid']);
    show_table_row_option_value("版本测试入口", "vtid", $vtidinfos, $row['vtid']);

    end_table();

    echo "<input type=hidden name=id value=$id></input>";
    echo '<div align="center"><input type="submit" name="do_edit_platform" value="提交修改" /></div>';
}
function do_edit_platform()
{
    begin_sql();

    $id = $_POST['id'];
    $name = $_POST['name'];
    $state = $_POST['state'];
    $test = $_POST['test'];
    $vertest = $_POST['vertest'];
    $ver = $_POST['ver'];
    $outid = $_POST['outid'];
    $inid= $_POST['inid'];
    $vtid = $_POST['vtid'];
    $outip = "";
    $inip = "";
    $vtip = "";

    echo $outid;

    if ($outid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$outid");
        if ($ret != false)
        {
            $row = mysql_fetch_array($ret);
            $outip = $row['pubip'];
        }
    }
    if ($inid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$inid");
        if ($ret != false)
        {
            $row = mysql_fetch_array($ret);
            $inip = $row['pubip'];
        }
    }
    if ($vtid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$vtid");
        if ($ret != false)
        {
            $row = mysql_fetch_array($ret);
            $vtip = $row['pubip'];
        }
    }

    $query = "update Platform set name=\"$name\", state=$state, test=$test, vertest=$vertest, ver=\"$ver\", outid=$outid, inid=$inid, vtid=$vtid, outip=\"$outip\", inip=\"$inip\", vtip=\"$vtip\" where id=$id";
    $ret=do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>修改平台失败!</font></p>";
        return;
    }
    end_sql();
    echo "<p><font color=blue>修改平台成功!</font></p>";
}
function add_platform_submit()
{
    begin_table("[新建]平台信息");

    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    begin_sql();

    $statenames = array(
       '运营'=>'0', 
       '维护'=>'1', 
    );

    $testnames = array(
       '关闭'=>'0', 
       '内网测试'=>'1', 
       '外网测试'=>'2', 
    );

    $vertestnames = array(
       '关闭'=>'0', 
       '开启'=>'1', 
    );

    $sql = "select id, name, type from Domain";
    $ret=do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>获取服务器组数据失败!</font></p>";
        return;
    }

    $outidinfos = array();
    $outidinfos['无'] = 0;
    $inidinfos = array();
    $inidinfos['无'] = 0;
    $vtidinfos = array();
    $vtidinfos['无'] = 0;
    while($row = mysql_fetch_array($ret))
    {
        if ($row['type'] == 1)
            $outidinfos[$row['name']] = $row['rid'];
        else if ($row['type'] == 2)
            $inidinfos[$row['name']] = $row['rid'];
        else if ($row['type'] == 3)
            $vtidinfos[$row['name']] = $row['rid'];
    }

    show_table_row_input("平台名", "name", "");
    show_table_row_option("运营", "state", $statenames);
    show_table_row_option("测试", "test", $testnames);
    show_table_row_option("版本测试", "vertest", $vertestnames);
    show_table_row_input("测试版本号", "ver", "");
    show_table_row_option("运营入口", "outid", $outidinfos);
    show_table_row_option("内网测试入口", "inid", $inidinfos);
    show_table_row_option("版本测试入口", "vtid", $vtidinfos);

    end_table();

    echo '<div align="center"><input type="submit" name="do_add_platform" value="提交新建" /></div>';
}
function do_add_platform()
{
    begin_sql();

    $name = $_POST['name'];
    $state = $_POST['state'];
    $test = $_POST['test'];
    $vertest = $_POST['vertest'];
    $ver = $_POST['ver'];
    $outid = $_POST['outid'];
    $inid= $_POST['inid'];
    $vtid = $_POST['vtid'];
    $outip = "";
    $inip = "";
    $vtip = "";
    
    if ($outid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$outid");
        $row = mysql_fetch_array($ret);
        $outip = $row['pubip'];
    }
    if ($inid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$inid");
        $row = mysql_fetch_array($ret);
        $inip = $row['pubip'];
    }
    if ($vtid != 0)
    {
        $ret=do_sql("select pubip from Machine where id=$vtid");
        $row = mysql_fetch_array($ret);
        $vtip = $row['pubip'];
    }


    $query = "insert into Platform (name, state, test, vertest, ver, outid, inid, vtid, outip, inip, vtip) values (\"$name\", $state, $test, $vertest, \"$ver\", $outid, $inid, $vtid, \"$outip\", \"$inip\", \"$vtip\")";
    $ret=do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>新建平台失败!</font></p>";
        return;
    }
    end_sql();
    echo "<p><font color=blue>新建平台成功!</font></p>";

    redirect("godser_platform.php");
}
?>
