<?
include "base.php";
include "config.php";

if (!empty($_GET['fix']))
{
    $jstr = $_GET['submit_param'];
    $arr = json_decode($jstr);
    echo $jstr;
    echo '<br/>';

    begin_sql();
    foreach($arr as $partner)
    {
        $sql = format("update Partner set resid={1}, grade={2},exp={3},quality={4},potential={5} where pid={0}", $partner[0], $partner[1], $partner[2], $partner[3], $partner[4], $partner[5]);
        echo $sql;
        echo '<br/>';
        do_sql($sql);
    }
    end_sql();
    show_msg('修改伙伴', '操作成功');
}
elseif(!empty($_GET['del']))
{
    $jstr = $_GET['submit_param'];
    $arr = json_decode($jstr);

    begin_sql();
    foreach($arr as $partner)
    {
        if ($partner[6] == 1)
        {
            $sql = format("delete from Partner where pid={0}", $partner[0]);
            do_sql($sql);
        }
    }
    end_sql();
    show_msg('删除伙伴', '操作成功');
}
elseif(!empty($_GET['add']))
{
    include "add_partner.php";
}
elseif(!empty($_GET['filter_partner']))
{
    include "add_partner.php";
}
elseif(!empty($_GET['submit_new_partner']))
{
    $jstr = $_GET['submit_param'];
    $arr = json_decode($jstr);
    $uid = $_GET['uid'];

    begin_sql();

    $insert = array();

    $i = 0;
    foreach($arr as $partner)
    {
        $insert[$i++] = array(new_dbid('pid'), $partner[0], 1);
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
