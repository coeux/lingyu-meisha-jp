<?php
function begin_sql()
{
    $mysql_host = 'mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com:3306';
    //$mysql_host = '10.1.13.24:3306';
    $mysql_user = 'root';
    $mysql_pwd = 'erikaerika';
    $mysql_db = 'nice_sertool';
    $db = mysql_connect($mysql_host,$mysql_user,$mysql_pwd);
    if (!$db){
        die('connect db error:' . mysql_error());
    }
    mysql_select_db($mysql_db, $db);
    mysql_query("set character set 'utf8'");//读库
    mysql_query("set names 'utf8'");
}
function do_sql($sql_)
{
    return mysql_query($sql_);
}
function end_sql()
{
    mysql_close();
}
?>
<?php
    $inner_ip = array(
	    //'113.46.106.226'=>1
        '113.46.48.14'=>1,
//        '180.170.22.50'=>1
    );

    $iipp = $_SERVER["REMOTE_ADDR"];

    $app_names = array(
        'Win32' => 'Win32.zip',
        'Android'=>'Android.pkg',
        'iOS'=>'iOS.ipa'
    );

    $out_url = 'http://niceshot-10000116.file.myqcloud.com/niceshot-10000116/10000116/niceshot/PKG/';
    $inner_url = 'http://niceshot-10000116.file.myqcloud.com/niceshot-10000116/10000116/niceshot/PKG/';

    $version = ""; 
    $domain = "";
    $system = "";

    $json = file_get_contents("php://input");
    $req = json_decode($json);

    $version = $req->version;
    $domain = $req->domain;
    $system = $req->system;

    //if ( !$domain )
        $domain = "common";

    if ($version == "" || $domain == "" || $system == "")
    {
        $ret = array(
            'state' => 1
        );
//        echo json_encode($ret);
        return;
    }

    //0:运营,1:维护
    //内部测试，不需要内部测试:flag设置0，flag设置1去offic测试，在维护状态下设置2去外网测试
    $sql="select * from Platform where name=\"$domain\"";
    begin_sql();
    $sqlret = do_sql($sql);
    if ($sqlret == false)
    {
        end_sql();
        $ret = array(
            'state' => 1,
            'code' => 'read db failed!'
        );
        echo json_encode($ret);
        return;
    }

    $row = mysql_fetch_array($sqlret); 
    if (mysql_affected_rows() <= 0)
    {
        end_sql();
        $ret = array(
            'state' => 1,
            'code' => 'none info'
        );
        echo json_encode($ret);
        return;
    }
    end_sql();

    $state = $row['state'];
    $flag = $row['test'];
    $test = $row['vertest'];
    $test_version = $row['ver'];

    $routes = array(
        'out' => array('ip'=>"182.254.147.153", 'port'=>61100),
        'inner' => array('ip'=>"182.254.147.153", 'port'=>61100),
        //'out' => array('ip'=>$row['outip'], 'port'=>41104),
        //'inner' => array('ip'=>$row['inip'], 'port'=>41104),
        //'test' => array('ip'=>$row['vtip'], 'port'=>41104),
    );

    //更新url地址
    $url = '';
    //服务器route的ip和端口
    $route = null;

    if($state == 0)
    {
        $url = $out_url;
        $route = $routes['out'];
    }

    if ($flag == 1)
    {
        if ($inner_ip[$iipp] == 1)
        {
            $state = 0;
            $url = $inner_url;
            $route = $routes['inner'];
        }
    }

    if ($flag == 2)
    {
        if ($inner_ip[$iipp] == 1)
        {
            $state = 0;
            $url = $inner_url;
            $route = $routes['out'];
        }
    }
/*
    if ($test == 1 && ($inner_ip[$iipp] == 0 || $flag==0))
    {
        if ($version == $test_version)
        {
            $url = $inner_url;
            $route = $routes['test'];
        }
    }
*/
    $vfile = file_get_contents("VersionFile/version.json");
    $vfile_test = file_get_contents("VersionFile/version_test.json");
    $ret = array(
        'state' => $state,
        'route' => $route,
        'appUrl' => $url.'Client/'.$domain.'/'.$system.'/'.$app_names[$system],
        'pkgUrl' => $url.'Client/'.$domain.'/PKG/',
        'versionUrl' => $url.'Client/'.$domain.'/PKG/version.json',
        'versionFile'=>$vfile,
        'test' => $req
    );

    $ret_test = array(
        'state' => $state,
        'route' => $route,
        'domain' => $_GET['domain'],
        'appUrl' => $url.'Client/'.$domain.'/'.$system.'/'.$app_names[$system],
        'pkgUrl' => $url.'Client/'.$domain.'/PKG/',
        'versionUrl' => $url.'Client/'.$domain.'/PKG/version.json',
        'versionFile'=>$vfile_test,
        'test' => $domain
    );
    file_put_contents("/tmp/p.txt", print_r($ret_test, true));


    if ($inner_ip[$iipp] == 1)
        echo json_encode($ret_test);
    else
        echo json_encode($ret);
?>
