<?php
include "config.php";
include "base.php";
include "sm_head.php";
include "godser_mgr.php";
?>

<html>
<meta charset="UTF-8">
<head>
</head>
<body>
<center>

<form method="post" action="godser_host.php" >
<p>游戏服务器组</>
<?php
show_domain_select();
if (isset($_POST['sel_domain_submit']))
{
    select_domain();
}
if (isset($_POST['add_domain_submit']))
{
    add_domain_submit();
}
if (isset($_POST['do_add_domain']))
{
    do_add_domain();
}
if (isset($_POST['edit_domain_submit']))
{
    edit_domain_submit();
}
if (isset($_POST['do_edit_domain']))
{
    do_edit_domain();
    edit_domain_submit();
}
if (isset($_POST['add_ser_submit']))
{
    add_ser_submit();
    create_host_table();
}
if (isset($_POST['create_host_submit']))
{
    create_host_table();
}
if (isset($_POST['start_submit'])){
    start();
}
if (isset($_POST['stop_submit'])){
    stop();
}
if (isset($_POST['start_all_submit'])){
    start_all();
}
if (isset($_POST['stop_all_submit'])){
    stop_all();
}
if (isset($_POST['recom_submit'])){
    recom();
}
if (isset($_POST['unrecom_submit'])){
    unrecom();
}
if (isset($_POST['edit_submit'])){
    show_host_edit_table();
}
if (isset($_POST['up_ser_submit'])){
    up_ser_submit();
}
?>
</form>
</center>
</body>
</html>

<?php
function select_domain(){ 
    if (!isset($_POST['domainlist']))
    {
        return;
    }

    $did = $_POST['domainlist'];
    $query = "select * from Host where did=$did";

    begin_sql();
    $ret = do_sql($query);
    if (mysql_affected_rows()<=0){
        end_sql();

        echo "<p>";
        echo "当前服务器组没有被部署! 需要新建服务器";
        echo "<p>";
        create_host_table();
    }
    else
    {
        show_host_list();
    }
}

function create_host_table(){
    $did = $_POST['domainlist'];

    begin_sql();
    $query = "select name from Domain where id=$did";
    $ret_query_domain = do_sql($query);
    $row = mysql_fetch_array($ret_query_domain);
    $domain_name = $row['name'];

    $query = "select * from Machine";
    $ret_query_machine = do_sql($query);
    $machine_info = array();
    while($row = mysql_fetch_array($ret_query_machine))
    {
        if ($row['type']==1)
            $machine_info["虚拟机:".$row['priip']]=$row['id'];
    }
    end_sql();

    begin_table("[新建]服务器");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    show_table_row(array("服务器组",$domain_name),2);
    show_table_row_option("物理机", "mid", $machine_info);
    show_table_row_option("服务器类型", "sertype", array(
        "逻辑(可多个)"=>"scene",
        "登陆(可多个)"=>"login",
        "网关(可多个)"=>"gateway",
    ));
    show_table_row_input("服务器名称", "sername", "");
    show_table_row_option("推荐", "recom", array(
        "关闭"=>"0",
        "开启"=>"1",
    ));
    end_table();

    echo '<div align="center"><input type="submit" name="add_ser_submit" value="添加" /></div>';
}

function add_ser_submit()
{
    $cfg = config_t::ins();

    $did=$_POST['domainlist'];
    $mid=$_POST['mid'];
    $sertype=$cfg->progs[$_POST['sertype']];
    $sername=$_POST['sername'];
    $recom=$_POST['recom'];

    begin_sql();

    if ($sername == "" && $sertype != 4){
        $sername=$_POST['sertype'];
    }else if ($sername == "" && $sertype == 4){
        echo "<p><font color=red>无效操作, 需要服务器名</font></p>";
        return;
    }else if ($sertype == 4){
        do_sql("select * from Host where did=$did and sertype=$sertype and sername=\"$sername\"");
        if (mysql_affected_rows()>0){
            end_sql();
            echo "<p><font color=red>逻辑服务器名不能重复!</font></p>";
            return;
        }
    }

    $hostid = get_hostid($did, $sertype);
    if ($sertype == 4)
        $sername = $hostid."区-".$sername;
    $sql = "insert into Host (did, mid, hostid, sertype, sername, recom, state, compo) Values ($did, $mid, $hostid, $sertype, \"$sername\", $recom, 0, 0)";

    if (do_sql($sql))
    {
        echo "<p><font color=blue>操作成功</font></p>";
    }
    else
    {
        echo "<p><font color=red>操作失败</font></p>";
    }

    end_sql();
}

function show_domain_select()
{
    echo "<div>组名:";
    $sql = "select id, name from Domain";
    begin_sql();
    $ret=do_sql($sql);
    end_sql();

    $did = null;
    if (isset($_POST['domainlist']))
        $did = $_POST['domainlist'];
    if (isset($_POST['did']))
        $did = $_POST['did'];

    echo '<select name="domainlist">';
    if ($did != null)
    {
        $rows = array();
        while($row = mysql_fetch_array($ret))
        {
            array_push($rows, $row);
        }

        foreach($rows as &$row)
        {
            if ($did == $row['id'])
            {
                echo format("<option value={0}>{1}</option>", $row['id'], $row['name']);
                break;
            }
        }

        foreach($rows as &$row)
        {
            if ($did != $row['id'])
            {
                echo format("<option value={0}>{1}</option>", $row['id'], $row['name']);
            }
        }
    }
    else
    {
        while($row = mysql_fetch_array($ret))
        {
            echo format("<option value={0}>{1}</option>", $row['id'], $row['name']);
        }
    }
    echo '</select>';

    echo '<input type="submit" name="sel_domain_submit" value="选择" />';
    echo '<input type="submit" name="add_domain_submit" value="新增" />';
    echo '<input type="submit" name="edit_domain_submit" value="编辑" />';
    echo "</div>";
}

function add_domain_submit()
{
    begin_sql();
    $query = "select * from Machine";
    $ret_query_machine = do_sql($query);
    $machine_info = array();
    $db_info = array();
    $db_info['无']=0;
    $inv_info = array();
    $inv_info['无']=0;
    $route_info = array();
    $route_info['无']=0;
    while($row = mysql_fetch_array($ret_query_machine))
    {
        if ($row['type']==1)
            $machine_info["虚拟机:".$row['priip']]=$row['id'];
        elseif ($row['type']==2)
            $db_info["数据库:".$row['priip']]=$row['id'];
        elseif ($row['type']==3)
            $inv_info["邀请码".$row['priip']]=$row['id'];
        elseif ($row['type']==4)
            $route_info["路由".$row['priip']]=$row['id'];
    }
    end_sql();

    $type_info = array(
        "运营" => 1,
        "内部测试" => 2,
        "版本测试" => 3,
    );

    begin_table("[新建]服务器组");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    show_table_row_input("组名", "domain_name", "");
    show_table_row_option("类型", "type", $type_info);
    show_table_row_option("组路由", "rid", $route_info);
    show_table_row_option("邀请码服务", "invid", $inv_info);
    show_table_row_option("邀请码数据库", "invdbid", $db_info);
    show_table_row_input("邀请码数据库端口", "invdbport", "");
    show_table_row_input("邀请码数据库名", "invdbname", "");
    show_table_row_option("组数据库", "dbid", $db_info);
    show_table_row_input("组数据库端口", "dbport", "");
    show_table_row_input("组数据库名", "dbname", "");

    end_table();

    echo '<div align="center"><input type="submit" name="do_add_domain" value="添加" /></div>';
}

function do_add_domain()
{
    begin_sql();

    $name = $_POST['domain_name'];
    $type = $_POST['type'];
    $rid = $_POST['rid'];
    $invid= $_POST['invid'];
    $invdbid= $_POST['invdbid'];
    $invdbport= $_POST['invdbport'];
    $invdbname= $_POST['invdbname'];
    $dbid = $_POST['dbid'];
    $dbname = $_POST['dbname'];
    $dbport= $_POST['dbport'];

    if ($name == "")
    {
        echo "<p><font color=red>服务器组名不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($rid == 0)
    {
        echo "<p><font color=red>路由不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($invid == 0)
    {
        echo "<p><font color=red>邀请码服务器不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($invdbid == 0)
    {
        echo "<p><font color=red>邀请码数据库不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($invdbport == 0)
    {
        echo "<p><font color=red>邀请码数据库不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($invdbname == "")
    {
        echo "<p><font color=red>邀请码数据库名不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($dbid  == 0)
    {
        echo "<p><font color=red>数据库不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($dbname  == "")
    {
        echo "<p><font color=red>数据库名不能为空!</font></p>";
        add_domain_submit();
        return;
    }
    if ($dbport  == "")
    {
        echo "<p><font color=red>数据库端口不能为空!</font></p>";
        add_domain_submit();
        return;
    }

    $sql = "insert into Domain (name, type, rid, invid, invdbid, invdbport, invdbname, dbid, dbname, dbport) Values (\"$name\", $type, $rid, $invid, $invdbid, $invdbport, \"$invdbname\", $dbid, \"$dbname\", $dbport)";
    $ret = do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>新增服务器组失败!</font></p>";
        return;
    }
    $did = mysql_insert_id();

    //插入路由
    $sql = "insert into Host (did, mid, hostid, sertype, sername, recom, state, compo) Values ($did, $rid, 1, 1, \"\", 0, 0, 0)";
    $ret = do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>新增服务器组失败!</font></p>";
        return;
    }

    end_sql();

    redirect("godser_host.php");
}

function edit_domain_submit()
{
    begin_sql();
    $query = "select * from Machine";
    $ret_query_machine = do_sql($query);
    $machine_info = array();
    $db_info = array();
    $db_info['无']=0;
    $inv_info = array();
    $inv_info['无']=0;
    $route_info = array();
    $route_info['无']=0;
    while($row = mysql_fetch_array($ret_query_machine))
    {
        if ($row['type']==1)
            $machine_info["虚拟机:".$row['priip']]=$row['id'];
        elseif ($row['type']==2)
            $db_info["数据库:".$row['priip']]=$row['id'];
        elseif ($row['type']==3)
            $inv_info["邀请码".$row['priip']]=$row['id'];
        elseif ($row['type']==4)
            $route_info["路由".$row['priip']]=$row['id'];
    }
    $type_info = array(
        "运营" => '1',
        "内部测试" => '2',
        "版本测试" => '3',
    );

    begin_table("[修改]平台信息");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    $did = $_POST['domainlist'];
    $query = "select * from Domain where id=$did";
    $ret=do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>获取平台数据失败!</font></p>";
        return;
    }
    if (mysql_affected_rows() <= 0)
        return;

    $row = mysql_fetch_array($ret);
    show_table_row_input("组名", "name", $row['name']);
    show_table_row_option_value("类型", "type", $type_info, $row['type']);
    show_table_row_option_value("组路由", "rid", $route_info, $row['rid']);
    show_table_row_option_value("邀请码服务", "invid", $inv_info, $row['invid']);
    show_table_row_option_value("邀请码数据库", "invdbid", $db_info, $row['invdbid']);
    show_table_row_input("邀请码数据库端口", "invdbport", $row['invdbport']);
    show_table_row_input("邀请码数据库名", "invdbname", $row['invdbname']);
    show_table_row_option_value("组数据库", "dbid", $db_info, $row['dbid']);
    show_table_row_input("组数据库端口", "dbport", $row['dbport']);
    show_table_row_input("组数据库名", "dbname", $row['dbname']);

    end_table();

    echo "<input type=hidden name=did value=$did></input>";
    echo '<div align="center"><input type="submit" name="do_edit_domain" value="提交修改" /></div>';
}

function do_edit_domain()
{
    begin_sql();

    $did = $_POST['did'];
    $name = $_POST['name'];
    $type = $_POST['type'];
    $rid = $_POST['rid'];
    $invid= $_POST['invid'];
    $invdbid= $_POST['invdbid'];
    $invdbport= $_POST['invdbport'];
    $invdbname= $_POST['invdbname'];
    $dbid = $_POST['dbid'];
    $dbname = $_POST['dbname'];
    $dbport= $_POST['dbport'];

    if ($name == "")
    {
        echo "<p><font color=red>组名不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($rid == 0)
    {
        echo "<p><font color=red>路由不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($invid == 0)
    {
        echo "<p><font color=red>邀请码服务器不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($invdbid == 0)
    {
        echo "<p><font color=red>邀请码数据库不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($invdbport == 0)
    {
        echo "<p><font color=red>邀请码数据库不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($invdbname == "")
    {
        echo "<p><font color=red>邀请码数据库名不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($dbid  == 0)
    {
        echo "<p><font color=red>数据库不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($dbname  == "")
    {
        echo "<p><font color=red>数据库名不能为空!</font></p>";
        add_platform_submit();
        return;
    }
    if ($dbport  == "")
    {
        echo "<p><font color=red>数据库端口不能为空!</font></p>";
        add_platform_submit();
        return;
    }

    $sql = "update Domain set name=\"$name\", type=$type, rid=$rid, invid=$invid, invdbid=$invdbid, invdbport=$invdbport, invdbname=\"$invdbname\", dbid=$dbid, dbname=\"$dbname\", dbport=$dbport where id=$did";
    $ret = do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>修改平台失败!</font></p>";
        return;
    }

    end_sql();

    echo "<p><font color=blue>修改平台成功!</font></p>";
}

function get_hostid($did_, $sertype_)
{
    $sql = "select hostid from Host where did=$did_ and sertype=$sertype_";
    $ret = do_sql($sql);
    $max = 0;
    while($row = mysql_fetch_array($ret))
    {
        if ($max < (int)$row['hostid']){
            $max = (int)$row['hostid'];
        }
    }
    return $max+1;
}

function show_host_edit_table()
{
    $id = $_POST['id'];
    $did = $_POST['did'];

    begin_sql();

    $query = "select name from Domain where id=$did";
    $ret_query_domain = do_sql($query);
    $row = mysql_fetch_array($ret_query_domain);
    $domain_name = $row['name'];

    $query = "select * from Machine";
    $ret_query_machine = do_sql($query);
    $machine_info = array();
    while($row = mysql_fetch_array($ret_query_machine))
    {
        if ($row['type']==1)
            $machine_info["虚拟机:".$row['priip']]=$row['id'];
    }

    $query = "select * from Host where id=$id";
    $ret_query_host = do_sql($query);
    $row = mysql_fetch_array($ret_query_host);

    $tmp = array();
    foreach($machine_info as $k=>$v){
        if ($v == $row['mid']){
            $tmp[$k] = $v;
            break;
        }
    }
    foreach($machine_info as $k=>$v){
        if ($v != $row['mid']){
            $tmp[$k] = $v;
        }
    }
    $machine_info = $tmp;

    $sertype_info = array();
    if ($row['sertype']==2)
    {
        $sertype_info = array(
            "登陆(可多个)"=>"login",
            "逻辑(可多个)"=>"scene",
            "网关(可多个)"=>"gateway",
        );
    }
    if ($row['sertype']==3)
    {
        $sertype_info = array(
            "网关(可多个)"=>"gateway",
            "登陆(可多个)"=>"login",
            "逻辑(可多个)"=>"scene",
        );
    }
    if ($row['sertype']==4)
    {
        $sertype_info = array(
            "逻辑(可多个)"=>"scene",
            "登陆(可多个)"=>"login",
            "网关(可多个)"=>"gateway",
        );
    }

    $recom_info = array();
    if ($row['recom']==0){
        $recom_info = array(
            "关闭"=>"0",
            "开启"=>"1",
        );
    }
    if ($row['recom']==1){
        $recom_info = array(
            "开启"=>"1",
            "关闭"=>"0",
        );
    }

    begin_table("[编辑]服务器");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    show_table_row(array("组名",$domain_name),2);
    show_table_row_option("物理机", "mid", $machine_info);
    show_table_row_option("服务器类型", "sertype", $sertype_info);
    show_table_row_input("服务器名称", "sername", $row['sername']);
    show_table_row_option("推荐", "recom", $recom_info);
    end_table();

    echo format('<input type="hidden" name="id" value={0}></input>', $id);
    echo '<div align="center"><input type="submit" name="up_ser_submit" value="更新" /></div>';
}

function up_ser_submit()
{
    $cfg = config_t::ins();

    $id=$_POST['id'];
    $did=$_POST['domainlist'];
    $mid=$_POST['mid'];
    $sertype=$cfg->progs[$_POST['sertype']];
    $sername=$_POST['sername'];
    $recom=$_POST['recom'];

    $sql = "update Host set did=$did, mid=$mid, sertype=$sertype, sername=\"$sername\", recom=$recom where id=$id";

    begin_sql();

    if (do_sql($sql))
    {
        echo "<p><font color=blue>操作成功</font></p>";
    }
    else
    {
        echo "<p><font color=red>操作失败</font></p>";
    }

    end_sql();

    show_host_list();
}

?>
