<?
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
    public $mysql_user = 'inter';
    public $mysql_pwd = 'helloworld';
}
?>
