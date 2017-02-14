<?PHP
$sid = $argv[1];
date_default_timezone_set("PRC");
mail("309808251@qq.com", "time" . time(), "restart server = ". $sid . "  , time = ". date('Y-m-d H:i:s',time()), "from:13341158565@sina.cn");
mail("79401265@qq.com", "time" . time(), "restart server = ". $sid . "  , time = ". date('Y-m-d H:i:s',time()), "from:13341158565@sina.cn");
mail("214929973@qq.com", "time" . time(), "restart server = ". $sid . "  , time = ". date('Y-m-d H:i:s',time()), "from:13341158565@sina.cn");
