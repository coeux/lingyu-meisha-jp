<?php
class config_t{
    static private $m_instance = null;
    static public function ins()
    {   
        if(is_null(self::$m_instance)) { 
            self::$m_instance = new config_t(); 
        }   
        return self::$m_instance; 
    }   

    function __construct(){
        $ini = parse_ini_file($this->ini_path);
        if ($ini != null)
        {
            $this->mysql_host = $ini['mysql_host'];
            $this->mysql_db = $ini['mysql_db'];
            $this->mysql_user = $ini['mysql_user'];
            $this->mysql_pwd = $ini['mysql_pwd'];

            $this->gw_ip = $ini['gw_ip'];
            $this->gw_port = $ini['gw_port'];

            $this->elog_path = $ini['elog_path'];
        }
    }

    public $ini_path = './cfg.ini';
    public $elog_path = '';
    public $mysql_host = 'mxsq.cdwbpyj9hefz.ap-northeast-1.rds.amazonaws.com:3306';
    public $mysql_user = 'root';
    public $mysql_pwd = 'erikaerika';
    public $mysql_db = 'niceshot';
    public $gw_ip = '127.0.0.1';
    public $gw_port = '52201';
}
?>
