<?php
include "base.php";
include "config.php";

function update_user_pro()
{
    $sql = format("update UserInfo set nickname='{1}',gold={2},grade={3},exp={4},freeyb={5},payyb={6},power={7},viplevel={8},vipexp={9},sceneid={10},questid={11},fpoint={12} where uid={0}",
        $_GET['uid'],
        $_GET['nickname'],
        $_GET['gold'],
        $_GET['grade'],
        $_GET['exp'],
        $_GET['freeyb'],
        $_GET['payyb'],
        $_GET['power'],
        $_GET['viplevel'],
        $_GET['vipexp'],
        $_GET['sceneid'],
        $_GET['questid'],
        $_GET['fpoint']
    );
    exec_sql($sql);
    show_msg('修改成功', '');
}
?>
<html>
<meta charset="UTF-8">
<body>
<?php
    update_user_pro();
?>
</form>
</body>
</html>
