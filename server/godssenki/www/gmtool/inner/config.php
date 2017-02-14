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

    public $mysql_host = '192.168.4.240:3307';
    //public $mysql_host = '10.1.13.24:3306';
    public $mysql_user = 'inter';
    public $mysql_pwd = 'helloworld';
    public $mysql_db = 'God_91';
    //public $mysql_db = 'God_banshu';
}
?>
