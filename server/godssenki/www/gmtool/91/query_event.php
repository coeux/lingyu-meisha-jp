<?php 
include 'base.php';
include 'config.php';
include 'repo.php';

function show_user_table($result_)
{
    begin_table('用户事件查询结果');
    show_table_header(array(
                '序号'=>'50px',
                '事件时间'=>'200px',
                '事件名称'=>'150px',
                '事件明细'=>'500px',
                ));

    $index = 0;
    while($row = mysql_fetch_array($result_)) {
        $infos = array();
        $infos[0] = ++$index;
        $infos[1] = $row['eventm'];
        $infos[2] = $row['msg'];
        switch ( $row['eventid'] )
        {
            case 3999:
                if( $row['resid'] < 10000 )
                    $infos[3] = "补偿伙伴: " . $row['count'];
                else if ( $row['resid'] == 10001 )
                    $infos[3] = "补偿金币: " . $row['count'];
                else if ( $row['resid'] == 10002 )
                    $infos[3] = "补偿战历: " . $row['count'];
                else if ( $row['resid'] == 10003 )
                    $infos[3] = "补偿水晶: " . $row['count'];
                else if ( $row['resid'] == 10004 )
                    $infos[3] = "补偿友情点: " . $row['count'];
                else if ( $row['resid'] == 10005 )
                    $infos[3] = "补偿体力: " . $row['count'];
                else
                    $infos[3] = "补偿道具，resid: " . $row['count'] . " 个数: " . $row['count'];
                break;

            case 4006:
                $rp_item = repo_mgr_t::ins()->get_repo('item');
                if( $row['flag'] == 1 )
                    $infos[3] = "获得物品: " . $rp_item[$row['resid']]->name . "; 个数: " . $row['count'];
                else
                    $infos[3] = "消耗物品: " . $rp_item[$row['resid']]->name . "; 个数: " . $row['count'];
                break;

            case 4007:
                $rp_scene = repo_mgr_t::ins()->get_repo('scene');
                $infos[3] = $rp_scene[$row['resid']]->name;
                break;

            case 4016:
                $infos[3] = "改变前: " . $row['resid'] . " 改变后: " . $row['count']. " 变化值: " . ($row['count']-$row['resid']);
                break;

            case 4018:
                if( $row['resid'] == 0 )
                    $infos[3] = "主角升级，升级前等级: " . $row['count'] . "  升级后等级: " . $row['flag'];
                else
                    $infos[3] = "伙伴" . $row['resid'] . "升级，升级前等级: " . $row['count'] . "  升级后等级: " . $row['flag'];
                break;
                
            case 4019:
                $infos[3] = "改变前: " . $row['resid'] . " 改变后: " . $row['count'] . " 变化值: " . ($row['count']-$row['resid']);
                break;
                
            case 4020:
                $infos[3] = "改变前: " . $row['resid'] . " 改变后: " . $row['count']. " 变化值: " . ($row['count']-$row['resid']);
                break;

            case 4032:
                if( $row['code'] == 0 )
                    $infos[3] = "装备id: " . $row['resid'] . " 强化次数: " . $row['count'] . " 强化结果: 成功";
                else
                    $infos[3] = "装备id: " . $row['resid'] . " 强化次数: " . $row['count'] . " 强化结果: 失败";
                break;
                
             case 4034:
                $rp_item = repo_mgr_t::ins()->get_repo('item');
                if ( $row['flag'] == 0 )
                    $infos[3] = "装备id: " . $row['count'] . " 目标装备: " . $rp_item[$row['resid']]->name . " 结果: 成功";
                else
                    $infos[3] = "装备id: " . $row['count'] . " 目标装备: " . $rp_item[$row['resid']]->name . " 结果: 失败";
                break;
    
            case 4039:
                $rp_item = repo_mgr_t::ins()->get_repo('item');
                if( $row['flag'] == 1 )
                    $infos[3] = "装宝石: " . $rp_item[$row['resid']]->name . " 装备: " . $row['count'];
                else
                    $infos[3] = "卸宝石: " . $rp_item[$row['resid']]->name . " 装备: " . $row['count'];
                break;

            case 4046:
                if( $row['flag'] == 1 )
                    $infos[3] = "友情点刷新";
                else if ( $row['flag'] == 2 )
                    $infos[3] = "水晶刷新";
                else if ( $row['flag'] == 3 )
                    $infos[3] = "至尊刷新";
                else
                    $infos[3] = "打开酒馆";
                break;

            case 4048:
                $rp_role = repo_mgr_t::ins()->get_repo('role');
                $infos[3] = $rp_role[$row['resid']]->name;
                break;
                
            case 4055:
                $infos[3] = $row['resid'];
                break;

            case 4068:
                $infos[3] = "改变前: " . $row['resid'] . " 改变后: " . $row['count']. " 变化值: " . ($row['count']-$row['resid']);
                break;
                
            case 4071:
                $infos[3] = "伙伴: " . $row['resid'] . " 成功: " . $row['code'] ;
                break;
                
            case 4990:
                $infos[3] = "兑换id: " . $row['resid'] . " 订单号: " . $row['flag'] ;
                break;

            case 4114:
                $infos[3] = "改变前: " . $row['resid'] . " 改变后: " . $row['count'] . " 变化值: " . ($row['count']-$row['resid']);
                break;
                
            case 4224:
                if( $row['flag'] == 1 )
                    $infos[3] = "收费";
                else
                    $infos[3] = "免费";
                break;
                
            case 4231:
                if( $row['flag'] == 1 )
                    $infos[3] = "世界聊天，聊天内容: " . $row['extra'];
                else if ( $row['flag'] == 2 )
                    $infos[3] = "公会聊天，聊天内容: " . $row['extra'];
                else
                    $infos[3] = "私人聊天，聊天内容: " . $row['extra'];
                break;
                            
            case 4300:
                $rp_item = repo_mgr_t::ins()->get_repo('item');
                $infos[3] = $rp_item[$row['resid']]->name;
                break;
                
            case 4342:
                $infos[3] = "添加对象: " . $row['resid'];
                break;
                
            case 4345:
                $infos[3] = "申请对象: " . $row['resid'] . " 拒绝: " . $row['flag'];
                break;

            case 4361:
                if ( $row['flag'] == 101 )
                    $infos[3] = "首次充值";
                else if ( $row['flag'] < 300 )
                    $infos[3] = "累计充值" . $row['flag']%100;
                else if ( $row['flag'] < 400 )
                    $infos[3] = "连续登录" . $row['flag']%100;
                else if ( $row['flag'] < 500 )
                    $infos[3] = "累计登录" . $row['flag']%100;
                else if ( $row['flag'] < 600 )
                    $infos[3] = "vip奖励" . $row['flag']%100;
                break;

            case 4402:
            case 4404:
                $rp_quest = repo_mgr_t::ins()->get_repo('quest');
                $infos[3] = $rp_quest[$row['resid']]->name;
                break;
                
            case 4559:
                $rp_role = repo_mgr_t::ins()->get_repo('role');
                $infos[3] = $rp_role[$row['resid']]->name;
                break;
                
            case 4684:
            case 4685:
                $rp_round = repo_mgr_t::ins()->get_repo('round');
                $infos[3] = $rp_round[$row['resid']]->name;
                break;

            case 4912:
#                $rp_item = repo_mgr_t::ins()->get_repo('item');
#                $infos[3] = $rp_item[$row['resid']]->name;
#                break;


            default:
                $infos[3] = "";
        }
        show_table_row($infos, 4);
    }
    end_table();
}

function search_user($uid)
{
   	$query = "select eventm,msg,eventid,resid,count,code,flag,extra from God_statics.EventLog a join God_statics.EventDefine b on a.eventid=b.id where uid='$uid'";
    $result = exec_select($query);
    $row_num = mysql_num_rows($result);
    if (0 == $row_num)
        show_error('当前角色不存在事件');
    else
        show_user_table($result);
    mysql_free_result($result);
}
?>
<html>
<body>
<form method="get" action="">
<?php
    search_user(_get('param'));
?>
</body>
</html>
