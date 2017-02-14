<?
class user_data_t
{
}
class user_pro_t
{
}
class user_team_t
{
}
class user_bag_t
{
}

class user_cache_t
{
    public $ud = new user_data_t();
    public $up = new user_pro_t();
    public $ut = new user_team_t();
    public $ub = new user_bag_t();
}

class cache_t
{
    static private $m_instance = null;
    static public function ins()
    {
        if(is_null(self::$m_instance)) { 
            self::$m_instance = new cache_t(); 
        } 
        return self::$m_instance; 
    }

    $cache = array();
    function add($uid_, $user_cache_)
    {
        $cache[$uid_] = $user_cache_;
    }
}
?>
