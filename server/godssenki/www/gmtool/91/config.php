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
    public $mysql_user = 'inter';
    public $mysql_pwd = 'helloworld';
    public $mysql_db= 'God_91';
    public $mysql_db_default = 'God_91';
	
	public $hostnum = 1;
	public $hostnum_default = 1;

	public function change_db($dbname_){
		$this->mysql_db = $dbname_;
	}

	public function reset_db(){
		$this->mysql_db = $this->mysql_db_default;
	}
	public function set_default_db($dbname_){
		$this->mysql_db_default = $dbname_;
	}

	public function reset_hostnum(){
		$this->hostnum = $this->hostnum_default;	
	}

	public function set_default_hostnum($hostnum_){
		$this->hostnum_default = $hostnum_;	
	}

}

?>
