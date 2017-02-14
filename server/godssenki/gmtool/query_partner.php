<?
include "base.php";
include "config.php";

function show_partner($uid_)
{
    echo format('<input type="hidden" name="uid" value="{0}">', $uid_);

    $query = "select pid, resid, grade, exp, quality, potential from Partner where uid=$uid_";
    $result = exec_select($query);
    show_partner_table($result);
    mysql_free_result($result);
}

function show_partner_table($result_)
{
    begin_table('伙伴信息');
    show_table_header(array(
        'dbid'=>'150px', 
        '表格id'=>'150px',
        '等级'=>'150px',
        '经验'=>'150px',
        '品质'=>'150px',
        '潜力'=>'150px',
        ));

    while($row = mysql_fetch_array($result_))
    {
        show_table_row_partner($row, 6, 'chk_pid');
    }

    end_table();
}

function show_table_row_partner($row_, $n_, $check_name_)
{
    echo '<tr>';

    for($i=0;$i<$n_;$i++)
    {
        if ($i == 0)
        {
            echo format('<td align="left"><input type="checkbox" name="{0}" value="{1}"/>{1}</td>', $check_name_, $row_[$i]);
        }
        elseif ($i == 1)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'resid', $row_[$i]);
        }
        elseif ($i == 2)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'grade', $row_[$i]);
        }
        elseif ($i == 3)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'exp', $row_[$i]);
        }
        elseif ($i == 4)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'quality', $row_[$i]);
        }
        elseif ($i == 5)
        {
            echo format('<td align="center"><input type="text" name="{0}" value="{1}"/></td>', 'potential', $row_[$i]);
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
    for(var i=0;i<document.partner_form.chk_pid.length;i++)
    {
        var row = new Array();
        row[0] = parseInt(document.partner_form.chk_pid[i].value);
        row[1] = parseInt(document.partner_form.resid[i].value);
        row[2] = parseInt(document.partner_form.grade[i].value);
        row[3] = parseInt(document.partner_form.exp[i].value);
        row[4] = parseInt(document.partner_form.quality[i].value);
        row[5] = parseInt(document.partner_form.potential[i].value);
        if (document.partner_form.chk_pid[i].checked)
            row[6] = 1;
        else
            row[6] = 0;
        arr[i] = row;
    }
    document.partner_form.submit_param.value=JSON.stringify(arr);
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
<form  name="partner_form" method="get" action="fix_partner.php" onSubmit="return get_jparam()">
<?php
    show_partner(_get('param'));
?>
<div align="center">
<input type="checkbox" name="chkall" onClick="checkall(this.form, 'chk_pid')" class="checkbox">全选</input>
<input name="submit_param" type="hidden" id="submit_param">
<input type="submit" name="fix" value="提交修改"/>
<input type="submit" name="del" value="删除选中"/>
<input type="submit" name="add" value="添加..."/>
</div>
</form>
</body>
</html>
