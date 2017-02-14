<?php
class config_t
{
    static private $m_instance = null;
    static public function ins()
    {
        if(is_null(self::$m_instance)) { 
            self::$m_instance = new config_t(); 
        } 
        return self::$m_instance; 
    }

    public $mysql_host = 'mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com:3306';
    //public $mysql_host = '10.1.13.24:3306';
    public $mysql_user = 'root';
    //public $mysql_user = 'test';
    public $mysql_pwd = 'erikaerika';
    public $mysql_db = 'nice_sertool';
    //public $mysql_db = 'God_banshu';
    public $progs = array(
        "route"=>1,
        "login"=>2,
        "gateway"=>3,
        "scene"=>4,
        "db"=>5,
        "invcode"=>6
    );
    public $prog_names = array(
        1=>"route",
        2=>"login",
        3=>"gateway",
        4=>"scene",
        5=>"db",
        6=>"invcode"
    );
}

?>
