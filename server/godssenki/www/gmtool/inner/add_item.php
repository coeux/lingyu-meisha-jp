<?php
include "repo.php";

function show_item_res_table($filter_)
{
    begin_table('可以添加的道具');
    show_table_header(array(
        '道具id'=>'100px',
        '道具名'=>'150px',
        '说明'=>'150px',
        '数量'=>'100px',
        ));
    
    $rp_item = repo_mgr_t::ins()->get_repo('item');
    foreach($rp_item as $key=>$value)
    {
        if ($filter_ == null)
        {
            if ($value->type != 2 && 
                $value->type != 8)
            {
                show_table_row_item_res($value, 'chk_resid');
            }
        }
        else
        {
            if ($value->type == $filter_)
            {
                show_table_row_item_res($value, 'chk_resid');
            }
        }
    }

    end_table();
}

function show_table_row_item_res($res_, $check_name_)
{
    echo '<tr>';

        echo format('<td align="left"><input type="checkbox" name="{0}" value="{1}"/>{1}</td>', $check_name_, $res_->id);
        echo format('<td align="center">{0}</td>', $res_->name);
        echo format('<td align="center">{0}</td>', $res_->info);
        echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'count', 1);

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
    var n = 0;
    for(var i=0;i<document.new_item_form.chk_resid.length;i++)
    {
        if (document.new_item_form.chk_resid[i].checked)
        {
            var row = new Array();
            row[0] = parseInt(document.new_item_form.chk_resid[i].value);
            row[1] = parseInt(document.new_item_form.count[i].value);
            arr[n++] = row;
        }
    }
    document.new_item_form.submit_param.value=JSON.stringify(arr);
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
<form method="post" action="fix_bag.php" >
<div align="center">道具类型
<select name="sel_item_type">
<option value="1">道具</option>
<option value="3">材料</option>
<option value="4">宝石</option>
<option value="5">图纸</option>
<option value="6">礼包</option>
<option value="7">卖钱垃圾</option>
</select>
<?php
    echo format('<input type="hidden" name="uid" value="{0}">', $_POST['uid']);
?>
<input type="submit" name="filter_item_type" value="过滤"/>
</div>
</form>
<form  name="new_item_form" method="post" action="fix_bag.php" onSubmit="return get_jparam()">
<?php
    echo format('<input type="hidden" name="uid" value="{0}">', $_POST['uid']);

    if (!empty($_POST['filter_item_type']))
        show_item_res_table($_POST['sel_item_type']);
    else
        show_item_res_table(null);
?>
<div align="center">
<input type="checkbox" name="chkall" onClick="checkall(this.form, 'chk_resid')" class="checkbox">全选</input>
<input name="submit_param" type="hidden" id="submit_param">
<input type="submit" name="submit_new_item" value="提交选中"/>
</div>
</form>
</body>
</html>
