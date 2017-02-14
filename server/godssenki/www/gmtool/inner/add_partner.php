<?php
include "repo.php";

function show_partner_res_table($job_, $rare_)
{
    begin_table('可以添加的伙伴');
    show_table_header(array(
        '表格id'=>'100px',
        '角色名'=>'150px',
        '职业'=>'150px',
        '稀有度'=>'100px',
        ));
    
    $rp_partner = repo_mgr_t::ins()->get_repo('role');
    foreach($rp_partner as $key=>$value)
    {
        if ($value->id < 2000)
            continue;

        if ($job_ == null && $rare_ == null)
        {
            show_table_row_partner_res($value, 'chk_resid');
        }
        else
        {
            if ($value->job == $job_ && $value->rare == $rare_)
            {
                show_table_row_partner_res($value, 'chk_resid');
            }
        }
    }

    end_table();
}

function show_table_row_partner_res($res_, $check_name_)
{
    $job_names = array(
            "1"=>"骑士",
            "2"=>"战士",
            "3"=>"射手",
            "4"=>"法师"
            );

    $rare_names = array(
            "1"=>"白",
            "2"=>"绿",
            "3"=>"蓝",
            "4"=>"紫",
            "5"=>"金"
            );

    echo '<tr>';

        echo format('<td align="left"><input type="checkbox" name="{0}" value="{1}"/>{1}</td>', $check_name_, $res_->id);
        echo format('<td align="center">{0}</td>', $res_->name);
        echo format('<td align="center">{0}</td>', $job_names[$res_->job]);
        echo format('<td align="center">{0}</td>', $rare_names[$res_->rare]);

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
    for(var i=0;i<document.new_partner_form.chk_resid.length;i++)
    {
        var row = new Array();
        if (document.new_partner_form.chk_resid[i].checked)
        {
            row[0] = parseInt(document.new_partner_form.chk_resid[i].value);
            arr[i] = row;
        }
    }
    document.new_partner_form.submit_param.value=JSON.stringify(arr);
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
<form method="post" action="fix_partner.php" >
<div align="center">职业
<select name="sel_partner_job">
<option value="1">骑士</option>
<option value="2">战士</option>
<option value="3">射手</option>
<option value="4">法师</option>
</select>
稀有度
<select name="sel_partner_rare">
<option value="1">白</option>
<option value="2">绿</option>
<option value="3">蓝</option>
<option value="4">紫</option>
<option value="5">金</option>
</select>
<?php
    echo format('<input type="hidden" name="uid" value="{0}">', $_POST['uid']);
?>
<input type="submit" name="filter_partner" value="过滤"/>
</div>
</form>
<form  name="new_partner_form" method="post" action="fix_partner.php" onSubmit="return get_jparam()">
<?php
    echo format('<input type="hidden" name="uid" value="{0}">', $_POST['uid']);

    if (!empty($_POST['filter_partner']))
        show_partner_res_table($_POST['sel_partner_job'], 
            $_POST['sel_partner_rare']);
    else
        show_partner_res_table(null, null);
?>
<div align="center">
<input type="checkbox" name="chkall" onClick="checkall(this.form, 'chk_resid')" class="checkbox">全选</input>
<input name="submit_param" type="hidden" id="submit_param">
<input type="submit" name="submit_new_partner" value="提交选中"/>
</div>
</form>
</body>
</html>
