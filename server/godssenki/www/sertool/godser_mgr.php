<?php
include "godser_client.php";

function show_host_list()
{
    $url = $_SERVER['PHP_SELF'];  
    $curphp = end(explode('/',$url));  

    if (isset($_POST['did']))
        $did = $_POST['did'];
    if (isset($_POST['domainlist']))
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
            $machine_info[$row['id']] = "虚拟机:".$row['priip'];
        if ($row['type']==4)
            $machine_info[$row['id']] = "路由:".$row['priip'];
    }


    begin_table("服务器列表");

    echo '<div align="center">';
    echo '<input type="submit" name="create_host_submit" value="新增服务器" />';
    echo '<input type="submit" name="start_all_submit" value="全部开启" />';
    echo '<input type="submit" name="stop_all_submit" value="全部关闭" />';
    echo '</div>';

    show_table_header(array(
        "id"=>"50px",
        "组名"=>"100px",
        "物理机"=>"100px",
        "hostid"=>"40px",
        "类型"=>"80px",
        "名称"=>"120px",
        "推荐"=>"80px",
        "状态"=>"40px",
        "合并"=>"40px",
        "创建时间"=>"100px",
        "操作"=>"150px",
    ));

    $query = "select * from Host where did=$did";
    $ret = do_sql($query);
    if ($ret == false){
        echo "<p><font color=red>获取服务器数据失败!</font></p>";
        return;
    }

    $typename = array(
        "1"=>"路由",
        "2"=>"登陆",
        "3"=>"网关",
        "4"=>"逻辑",
        "5"=>"dbcache",
        "6"=>"邀请码",
    );

    $recomname = array(
        "0"=>"不推荐",
        "1"=>"推荐",
    );

    $statename = array(
        "-1"=>"启动失败",
        "0"=>"关闭",
        "1"=>"开启",
        "2"=>"启动中",
    );

    $tmp = array();
    $i=0;
    while($row = mysql_fetch_array($ret))
    {
        $tmp[$i]=$row;
        $i++;
    }

    $n=0;
    $sertype_sort = array(1,3,2,4);
    foreach($sertype_sort as $sertype){
        for($j=0;$j<count($tmp);$j++){
            if ($tmp[$j]['sertype'] == $sertype)
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
        echo format('<td align="center">{0}</td>', $domain_name);
        echo format('<td align="center">{0}</td>', $machine_info[$row['mid']]);
        echo format('<td align="center">{0}</td>', $row['hostid']);
        echo format('<td align="center">{0}</td>', $typename[$row['sertype']]);
        echo format('<td align="center">{0}</td>', $row['sername']);

        if ($row['sertype'] != 4)
        {
            echo format('<td align="center">{0}</td>', "无");
        }
        else
        {
            if ($row['recom'] == 0)
            {
                echo format('<td align="center">{0}</td>', $recomname[$row['recom']]);
            }
            else
            {
                echo format('<td align="center"><font color=green>{0}</font></td>', $recomname[$row['recom']]);
            }
        }



        if ($row['state'] <= 0)
        {
            echo format('<td align="center"><font color=red>{0}</font></td>', $statename[$row['state']]);
        }
        else
        {
            echo format('<td align="center"><font color=blue>{0}</font></td>', $statename[$row['state']]);
        }

        echo format('<td align="center">{0}</td>', $row['compo']);
        echo format('<td align="center">{0}</td>', $row['ctime']);

        echo '<td>';

        echo format('
                <form  style="float:left;margin:0px;padding:0px" method="post" action="{0}">
                <input type="hidden" name="id" value={1}></input>
                <input type="hidden" name="did" value={2}></input>
                <input type="submit" name="edit_submit" value="编辑"/>
                </form>
                ',
        $curphp, $row['id'], $did);

        if ($row['sertype'] == 4)
        {
            if ($row['recom'] == 0)
            {
                echo format('
                        <form  style="float:left;margin:0px;padding:0px" method="post" action="{0}">
                        <input type="hidden" name="id" value={1}></input>
                        <input type="hidden" name="did" value={2}></input>
                        <input type="submit" name="recom_submit" value="推荐"/>
                        </form>
                        ',
                $curphp, $row['id'], $did);
            }
            elseif ($row['recom'] == 1)
            {
                echo format('
                        <form  style="float:left;margin:0px;padding:0px" method="post" action="{0}">
                        <input type="hidden" name="id" value={1}></input>
                        <input type="hidden" name="did" value={2}></input>
                        <input type="submit" name="unrecom_submit" value="不推荐"/>
                        </form>
                        ',
                $curphp, $row['id'], $did);
            }
        }

        if ($row['state'] == 0 || $row['state'] == -1)
        {
            echo format('
                    <form  style="float:right;margin:0px;padding:0px" method="post" action="{0}">
                    <input type="hidden" name="id" value={1}></input>
                    <input type="hidden" name="did" value={2}></input>
                    <input type="submit" name="start_submit" value="开启"/>
                    </form>
                    ',
            $curphp, $row['id'], $did);
        }
        elseif ($row['state'] == 1 || $row['state'] == 2)
        {
            echo format('
                    <form  style="float:right;margin:0px;padding:0px" method="post" action="{0}">
                    <input type="hidden" name="id" value={1}></input>
                    <input type="hidden" name="did" value={2}></input>
                    <input type="submit" name="stop_submit" value="关闭"/>
                    </form>
                    ',
            $curphp, $row['id'], $did);
        }


        echo '</td>';

        echo '</tr>';
    }

    end_table();

    end_sql();
}

function start(){
    $id = $_POST['id'];
    $sql="update Host set state=2 where id=$id";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }

    call('schphpstart', $id);

    show_host_list();
}

function stop(){
    $id = $_POST['id'];
    $sql="update Host set state=0 where id=$id";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }

    call('stop', $id);

    show_host_list();
}

function start_all(){

    echo "<p><font color=red>禁止当前操作</font></p>";
    show_host_list();

    /*
    $sql="update Host set state=2";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }
    show_host_list();
    */
}
function stop_all(){
    echo "<p><font color=red>禁止当前操作</font></p>";
    show_host_list();

    /*
    $sql="update Host set state=0";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }
    show_host_list();
    */
}
function recom(){
    $id = $_POST['id'];
    $sql="update Host set recom=1 where id=$id";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }
    show_host_list();
}
function unrecom(){
    $id = $_POST['id'];
    $sql="update Host set recom=0 where id=$id";
    if (!exec_sql($sql))
    {
        echo "<p><font color=red>操作失败</font></p>";
        echo "<p>";
    }
    show_host_list();
}
?>
