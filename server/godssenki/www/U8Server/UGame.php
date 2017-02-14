<?php

class UGame{
    private $games = array("1" => "niceshot"); //游戏列表

    public static function queryGame($gameID){
        return array_key_exists(strval($gameID), $games);
    }
}
