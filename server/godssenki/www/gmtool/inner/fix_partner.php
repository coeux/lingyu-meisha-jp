<?php
include "base.php";
include "config.php";

if (!empty($_POST['fix']))
{
    $uid = $_POST['uid'];
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);
    echo $jstr;
    echo '<br/>';

    begin_sql();
    foreach($arr as $partner)
    {
        $sql = format("update Partner set resid={1}, grade={2},exp={3},quality={4},potential={5} where uid=$uid and pid={0}", $partner[0], $partner[1], $partner[2], $partner[3], $partner[4], $partner[5]);
        echo $sql;
        echo '<br/>';
        do_sql($sql);
    }
    end_sql();
    show_msg('修改伙伴', '操作成功');
}
elseif(!empty($_POST['del']))
{
    $uid = $_POST['uid'];
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);

    begin_sql();
    foreach($arr as $partner)
    {
        if ($partner[6] == 1)
        {
            $sql = format("delete from Partner where uid=$uid and pid={0}", $partner[0]);
            echo $sql;
            echo '</br>';
            do_sql($sql);
        }
    }
    end_sql();
    show_msg('删除伙伴', '操作成功');
}
elseif(!empty($_POST['add']))
{
    include "add_partner.php";
}
elseif(!empty($_POST['filter_partner']))
{
    include "add_partner.php";
}
elseif(!empty($_POST['submit_new_partner']))
{
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);
    $uid = $_POST['uid'];

    begin_sql();

    $sql = format("select pid from Partner where uid={0}", $uid);
    $result = do_sql($sql);

    $max_pid = 0;
    while($row = mysql_fetch_array($result))
    {
        if ($max_pid < $row['pid'])
        {
            $max_pid = $row['pid'];
        }
    }

    $insert = array();

    $i = 0;
    foreach($arr as $partner)
    {
        $max_pid++;
        $insert[$i++] = array($max_pid, $partner[0], 1);
    }

    foreach($insert as $partner)
    {
        $sql = format("insert into Partner (uid, pid, resid, grade) Values ({0}, {1}, {2}, {3})", $uid, $partner[0], $partner[1], $partner[2]);
        echo $sql;
        do_sql($sql);
    }

    end_sql();

    show_msg('添加伙伴', '操作成功');
}
?>
