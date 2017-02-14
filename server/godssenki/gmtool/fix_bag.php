<?
include "base.php";
include "config.php";

if (!empty($_POST['fix']))
{
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);

    begin_sql();
    foreach($arr as $item)
    {
        $sql = format("update Item set resid={1}, count={2}, isdel = 0,  where itid={0}", $item[0], $item[1], $item[2]);
        do_sql($sql);
    }
    end_sql();
    show_msg('修改背包道具', '操作成功');
}
elseif(!empty($_POST['del']))
{
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);

    begin_sql();
    foreach($arr as $item)
    {
        if ($item[3] == 1)
        {
            $sql = format("delete from Item where itid={0}", $item[0]);
            do_sql($sql);
        }
    }
    end_sql();
    show_msg('删除背包道具', '操作成功');
}
elseif(!empty($_POST['add']))
{
    include "add_item.php";
}
elseif(!empty($_POST['filter_item_type']))
{
    include "add_item.php";
}
elseif(!empty($_POST['submit_new_item']))
{
    $jstr = $_POST['submit_param'];
    $arr = json_decode($jstr);
    echo $jstr;
    echo '</br>';
    
    begin_sql();

    $uid = $_POST['uid'];
    $sql = format("select itid, resid, count from Item where uid={0}", $uid);
    $result = do_sql($sql);

    $exists = array();
    $update = array();
    $insert = array();
    
    while($row = mysql_fetch_array($result))
    {
        $exists[$row['itid']] = array(
            'itid'=>$row['itid'],
            'resid'=>$row['resid'],
            'count'=>$row['count']
        );
    }

    $i = 0;
    foreach($arr as $item)
    {
        $found = false;
        foreach($exists as $key=>$value)
        {
            $row = $value;
            if ($row['resid'] == $item[0])
            {
                $found = true;
                $update[$i++] = array($row['itid'], $row['resid'], $row['count']+$item[1]);
                break;
            }
        }

        if(!$found) 
        {
            $insert[$i++] = array(new_dbid('itid'), $item[0], $item[1]);
        }
    }

    foreach($update as $item)
    {
        $sql = format("update Item set resid={1}, count={2}, isdel=0  where itid={0}", $item[0], $item[1], $item[2]);
        echo $sql;
        do_sql($sql);
    }

    foreach($insert as $item)
    {
        $sql = format("insert into Item (uid, itid, resid, count) Values ({0}, {1}, {2}, {3})", $uid, $item[0], $item[1], $item[2]);
        echo $sql;
        do_sql($sql);
    }

    end_sql();

    show_msg('添加背包道具', '操作成功');
}
?>
