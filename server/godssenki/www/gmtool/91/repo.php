<?php
class repo_mgr_t
{
    static private $m_instance = null;
    static public function ins()
    {
        if(is_null(self::$m_instance)) { 
            self::$m_instance = new repo_mgr_t(); 
        } 
        return self::$m_instance; 
    }
    
    private $contains = array();

    public function get_repo($name_)
    {
        if (empty($this->contains[$name_]))
        {
            $content = file_get_contents('./repo/'.$name_.'.json');  
			$obj = json_decode($content);   
            $tmp = array();
            foreach($obj->contain as $key=>$value)
            {
                $tmp[$key] = $value;
            }
            ksort($tmp);
            $this->contains[$name_] = $tmp;
        }
        return $this->contains[$name_];
    }
}
?>
