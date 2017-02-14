<?php

class UChannel{
    private $channels = array("25" => "appchina"); //游戏列表

    public static function queryChannel($channel){
        return $channels[$channel];
    }
}
