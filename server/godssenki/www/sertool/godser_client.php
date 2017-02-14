<?php
function call($method_, $hid_)
{
    begin_sql();

    $query = "select * from Host where id=$hid_";
    $ret_query_host = do_sql($query);
    if ($ret_query_host == false){
        echo "<p><font color=red>获取HOST数据失败!</font></p>";
        return;
    }
    $row_host = mysql_fetch_array($ret_query_host);
    $did = $row_host['did'];
    $mid = $row_host['mid'];
    $hostid = $row_host['hostid'];
    $sertype = $row_host['sertype'];

    $query = "select * from Domain where id=$did";
    $ret_query_domain = do_sql($query);
    $row_domain = mysql_fetch_array($ret_query_domain);
    $dname = $row_domain['name'];

    $query = "select * from Machine where id=$mid";
    $ret_query_machine = do_sql($query);
    $row_machine = mysql_fetch_array($ret_query_machine);
    $priip = $row_machine['priip'];

    $cfg = config_t::ins();
    $prog = $cfg->prog_names[$sertype];

    if ($dname == "test")
    {
        $path = "http://$priip/sertool/godser.php";
        $param = array(
                'method'=>$method_,
                'domain'=>$dname,
                'servers'=>array(
                    array(
                        'prog'=>$prog,
                        'ver'=>'1.2.0',
                        'sid'=>$hostid,
                        'ret'=>'',
                        'status'=>1
                        )
                    )
                );

        $ret = json_decode(post($path,$param));
    }
    else
    {
        $cmd = array(
            $ips = array(
                $priip
            ),
            $action="$method_ $domain last $prog $hostid"
        );

        $client= new GearmanClient();
        $client->addServer("10.1.13.210");
        $cmd = json_encode($cmd);
        echo $cmd;
        echo $client->doNormal("handle_service", $cmd);
    }

    //print_r($ret);

    if ($ret == false)
    {
        echo "<p><font color=red>操作失败!</font></p>";
    }

    end_sql();
}
?>
