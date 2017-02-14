<?php
require_once "Login.php";

$params = array();
if (isset($_GET['gameID']))
    $params['gameID'] = $_GET['gameID']
if (isset($_GET['channelID']))
    $params['channelID'] = $_GET['channelID']
if (isset($_GET['appID']))
    $params['appID'] = $_GET['appID']
if (isset($_GET['cpID']))
    $params['cpID'] = $_GET['cpID']
if (isset($_GET['serverID']))
    $params['serverID'] = $_GET['serverID']
if (isset($_GET['sid']))
    $params['sid'] = $_GET['sid']
if (isset($_GET['token']))
    $params['token'] = $_GET['token']
if (isset($_GET['sessionID']))
    $params['sessionID'] = $_GET['sessionID']
if (isset($_GET['appKey']))
    $params['appKey'] = $_GET['appKey']
if (isset($_GET['appSecret']))
    $params['appSecret'] = $_GET['appSecret']
if (isset($_GET['extra']))
    $params['extra'] = $_GET['extra']

Login.getLoginToken($params);
