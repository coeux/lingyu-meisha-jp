<?php

function connect()
{
    $config = array(
        'host' => '10.66.109.182',
        'port' => '3306',
        'user' => 'root',
        'pwd'  => '13683048948o',
        'name' => 'niceshot_base',
    );
    $conn = mysql_connect($config['host'].':'.$config['port'], $config['user'], $config['pwd']);
    if (!$conn) {
        die("Couldn't not connect: " . mysql_error());
    }
    
    mysql_select_db($config['name'], $conn);
    mysql_query("SET NAMES utf8");
    return $conn;
}
/* 获取榜单 */
function record_log_and_reset_user_data($conn, $event_id)
{
    $update_sql_template = "UPDATE CardEventUser SET coin = 0, score = 0, goal_level = 0," .
                  "round = 6001, round_status = 0, round_max = 6001, reset_time = 0," .
                  "hp1 = 1, hp2 = 1, hp3 = 1, hp4 = 1, hp5 = 1, anger = 0, enemy_view_data = ''" .
                  "WHERE uid = %d"; /* 为了避免错误，不一次性更新用户数据 */
    /* 记录日志模板 */
    $log_sql_template = "INSERT INTO CardEventUserLog(eid, uid, coin, score, goal_level," .
               "round, round_status, round_max, reset_time)" .
               "VALUE(%d, %d, %d, %d, %d, %d, %d, %d, %d)";
    /* 获取参加了活动的所有玩家，不区分服务器 */
    $sql = "SELECT ceu.uid, ceu.coin, ceu.score, ceu.goal_level, " .
           "ceu.round, ceu.round_status, ceu.round_max, ceu.reset_time " .
           "FROM UserInfo ui LEFT JOIN CardEventUser ceu " .
           "ON ui.uid = ceu.uid " .
           "WHERE ceu.score > 0 or ceu.coin > 0 " .
           "ORDER BY ceu.score DESC ";

    $log_sql_list = array();
    $update_sql_list = array();
    $result = mysql_query($sql);
    while ($row = mysql_fetch_array($result)) {
        $log_sql_list[$row['uid']] = sprintf(
            $log_sql_template, 
            $event_id, 
            (int)$row['uid'], 
            (int)$row['coin'],
            (int)$row['score'],
            (int)$row['goal_level'],
            (int)$row['round'],
            (int)$row['round_status'],
            (int)$row['round_max'],
            (int)$row['reset_time']);
        $update_sql_list[$row['uid']] = sprintf($update_sql_template, (int)$row['uid']);
    }

    foreach($log_sql_list as $uid => $log_sql) {
        $result = mysql_query($log_sql);
        if (!$result) {
            echo("\r\n执行失败: [ERR] " . mysql_error() . "\t[SQL] $log_sql.\r\n");
            continue;
        }
        echo "uid = $uid, INSERT success, ";
        $result = mysql_query($update_sql_list[$uid]);
        if (!$result) {
            echo("\r\n执行失败: [ERR] " . mysql_error() . "\t[SQL] $update_sql_list[$uid].\r\n");
        }
        echo "UPDATE success.\r\n";
    }

    return true;
}

function check($event_id)
{
    $content = file_get_contents("./repo/event.json");
    $events = json_decode($content, true);
    $event = $events['contain'][$event_id];
    if (empty($event)) {
        echo "活动ID错误，无此活动信息.\r\n";
        return false;
    }
    printf("[INFO] 活动ID = %d, 活动名称 = %s, 起始时间 = %s, 结束时间 = %s\r\n", 
           (int)$event['id'], $event['name'], $event['start_time'], $event['end_time']);
    if (time() <= strtotime($event['end_time'])) {
        echo "[ERR] 活动未结束，不可重置用户数据，now = " . date("Y-m-d H:i:s") . PHP_EOL;
        return false;
    }
    while($line = readline("请确认活动信息正确(yes/no): ")) {
        if ($line == 'yes') {
            break;
        }
        return false;
    }
    return true;
}

function reset_data($event_id)
{
    if (!is_numeric($event_id)) {
        echo "参数错误，请传入正确的活动ID.\r\n";
        return;
    }
    if (!check($event_id)) {
        return;
    }

    $conn = connect();
    record_log_and_reset_user_data($conn, $event_id);
    mysql_close($conn);
}
reset_data($argv[1]);
