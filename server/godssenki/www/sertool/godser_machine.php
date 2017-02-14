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

<form method="post" action="godser_machine.php" >

</p>
<div align="center">
<input type="submit" name="view_machine_submit" value="查看物理机" />
<input type="submit" name="add_machine_submit" value="增加物理机" />
</div>

<?php
    if (isset($_POST['add_machine_submit']))
    {
        gen_add_table();
    }
    elseif (isset($_POST['do_add_machine']))
    {
        add_machine();
        show_machine();
    }
    elseif (isset($_POST['edit_submit']))
    {
        show_edit_table();
    }
    elseif (isset($_POST['up_submit']))
    {
        up_machine();
        show_machine();
    }
    else
    {
        show_machine();
    }
?>

</form>
</center>
</body>
</html>

<?php
function gen_add_table(){ 
    begin_table("[新增]物理机信息");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));

    show_table_row_option("类型", "type", array(
        '虚拟机'=>'1',
        '数据库'=>'2',
        '邀请码'=>'3',
        '路由'=>'4',
    ));
    show_table_row_input("外网ip", "pubip", "");
    show_table_row_input("内网ip", "priip", "");
    show_table_row_input("描述", "des", "");

    end_table();

    echo '<div align="center"><input type="submit" name="do_add_machine" value="添加" /></div>';
}
function show_machine(){

    begin_table("物理机信息");
    show_table_header(array(
        "id"=>"50px",
        "类型"=>"80px",
        "外网ip"=>"150px",
        "内网ip"=>"150px",
        "描述"=>"150px",
        "创建时间"=>"100px",
        "操作"=>"50px",
    ));

    begin_sql();
    $query = "select id, type, pubip, priip, des, ctime from Machine";
    $ret = do_sql($query);
    if ($ret == false){
        end_sql();
        echo "<p><font color=red>获取物理机数据失败!</font></p>";
        return;
    }

    if (mysql_affected_rows() <= 0)
        return;

    $typenames=array(
        '1'=>'虚拟机',
        '2'=>'数据库',
        '3'=>'邀请码',
        '4'=>'路由',
    );

    
    $tmp = array();
    $i=0;
    while($row = mysql_fetch_array($ret))
    {
        $tmp[$i]=$row;
        $i++;
    }

    $n=0;
    $type_sort = array(2,4,3,1);
    foreach($type_sort as $type){
        for($j=0;$j<count($tmp);$j++){
            if ($tmp[$j]['type'] == $type)
            {
                $rows[$n]=$tmp[$j];
                $n++;
            }
        }
    }

    foreach($rows as $row)
    {
        echo '<tr>';
        echo format('<td align="center">{0}</td>', $row['id']);
        echo format('<td align="center">{0}</td>', $typenames[$row['type']]);
        echo format('<td align="left">{0}</td>', $row['pubip']);
        echo format('<td align="left">{0}</td>', $row['priip']);
        echo format('<td align="center">{0}</td>', $row['des']);
        echo format('<td align="center">{0}</td>', $row['ctime']);


        echo '<td>';
        echo format('
                <form  style="float:left;margin:0px;padding:0px" method="post" action="godser_machine.php">
                <input type="hidden" name="id" value={0}></input>
                <input type="submit" name="edit_submit" value="编辑"/>
                </form>
                ',
        $row['id']);

        echo '</td>';

        echo '</tr>';
    }
}
function add_machine(){
    begin_sql();

    $query = "select id, type, pubip, priip, ctime from Machine";
    $ret = do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>数据库异常!</font></p>";
        return;
    }

    $type = $_POST['type'];
    $pubip = $_POST['pubip'];
    $priip = $_POST['priip'];
    $des=$_POST['des'];

    while($row = mysql_fetch_array($ret))
    {
        if ($row['type']==$type && $row["priip"] == $priip){
            echo "<p><font color=red>添加失败,类型$type,内网ip:".$priip."物理机已经存在!</font></p>";
            return;
        }
    }

    $sql = "insert into Machine (type, pubip, priip, des) Values ($type, \"$pubip\", \"$priip\", \"$des\")";

    $ret = do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>创建新物理机失败!</font></p>";
        return;
    }

    end_sql();
}
function show_edit_table(){
    $id = $_POST['id'];

    begin_sql();

    $query = "select * from Machine where id=$id";
    $ret = do_sql($query);
    $row = mysql_fetch_array($ret);

    if ($ret == false){
        echo "<p><font color=red>数据库异常!</font></p>";
        return;
    }

    begin_table("[编辑]物理机信息");
    show_table_header(array(
        '参数类型' => '150px',
        '参数值'=>'150px', 
    ));


    $option = array();
    if ($row['type']==1){
        $option = array(
            '虚拟机'=>'1',
            '数据库'=>'2',
            '邀请码'=>'3',
            '路由'=>'4',
        );
    }
    if ($row['type']==2){
        $option = array(
            '数据库'=>'2',
            '虚拟机'=>'1',
            '邀请码'=>'3',
            '路由'=>'4',
        );
    }
    if ($row['type']==3){
        $option = array(
            '邀请码'=>'3',
            '虚拟机'=>'1',
            '数据库'=>'2',
            '路由'=>'4',
        );
    }
    if ($row['type']==4){
        $option = array(
            '路由'=>'4',
            '邀请码'=>'3',
            '虚拟机'=>'1',
            '数据库'=>'2',
        );
    }

    show_table_row_option("类型", "type", $option);

    show_table_row_input("外网ip", "pubip", $row['pubip']);
    show_table_row_input("内网ip", "priip", $row['priip']);
    show_table_row_input("描述", "des", $row['des']);

    end_table();

    echo format('<input type="hidden" name="id" value={0}></input>', $id);
    echo '<div align="center"><input type="submit" name="up_submit" value="更新" /></div>';
}
function up_machine()
{
    $id = $_POST['id'];
    begin_sql();

    $query = "select id, type, pubip, priip, ctime from Machine";
    $ret = do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>数据库异常!</font></p>";
        return;
    }

    $type = $_POST['type'];
    $pubip = $_POST['pubip'];
    $priip = $_POST['priip'];
    $des=$_POST['des'];

    while($row = mysql_fetch_array($ret))
    {
        if ($row['type']==$type && $row["priip"] == $priip){
            echo "<p><font color=red>添加失败,类型$type,内网ip:".$priip."物理机已经存在!</font></p>";
            return;
        }
    }

    $sql = "update Machine set type=$type, pubip=\"$pubip\", priip=\"$priip\", des=\"$des\" where id=$id";

    $ret = do_sql($sql);
    if ($ret == false){
        echo "<p><font color=red>更新失败!</font></p>";
        return;
    }

    end_sql();
}
?>
