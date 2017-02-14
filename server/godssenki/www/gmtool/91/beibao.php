<?php
include "base.php";
include "config.php";
include "repo.php";

function show_bag($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select itid, resid, count from Item where uid=$uid_";
    $result = exec_select($query);
    show_item_table($result);
    mysql_free_result($result);
}

function show_item_table($result_)
{
    begin_table('背包中的道具信息');

    $row_num = mysql_num_rows($result_);
    echo '<p align="center">找到'.$row_num.'个道具</p>';

    show_table_header(array(
        'dbid'=>'150px', 
        '道具id'=>'150px',
        '道具名'=>'150px',
        '数量'=>'150px'
        ));

    while($row = mysql_fetch_array($result_))
    {
        show_table_row_item($row, 4, 'chk_itid');
    }

    end_table();
}

function show_table_row_item($row_, $n_, $check_name_)
{
    echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
        if ($i == 0)
        {
            echo format('<td align="left"><input type="checkbox" name="{0}" value="{1}"/>{1}</td>', $check_name_, $row_[0]);
        }
        elseif ($i == 1)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'resid', $row_[1]);
        }
        elseif ($i == 2)
        {
            $rp_item = repo_mgr_t::ins()->get_repo('item');
            $item = $rp_item[$row_[1]];
            echo format('<td align="center">{0}</td>', $item->name);
        }
        elseif ($i == 3)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'count', $row_[2]);
        }
    }

    echo '</tr>';
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script language="JavaScript">
function get_jparam()
{
    var arr = new Array();
    for(var i=0;i<document.bag_form.chk_itid.length;i++)
    {
        var row = new Array();
        row[0] = parseInt(document.bag_form.chk_itid[i].value);
        row[1] = parseInt(document.bag_form.resid[i].value);
        row[2] = parseInt(document.bag_form.count[i].value);
        if (document.bag_form.chk_itid[i].checked)
            row[3] = 1;
        else
            row[3] = 0;
        arr[i] = row;
    }
    document.bag_form.submit_param.value=JSON.stringify(arr);
    return true;
}

//全选操作
function checkall(form, prefix, checkall) {
    var checkall = checkall ? checkall : 'chkall';
    for(var i = 0; i < form.elements.length; i++) {
        var e = form.elements[i];
        if(e.name && e.name != checkall && (!prefix || (prefix && e.name.match(prefix)))) {
            e.checked = form.elements[checkall].checked;
        }
    }
}
</script>
</head>

<body>
<?php
    show_bag(_get('param'));
?>
</body>
</html>
