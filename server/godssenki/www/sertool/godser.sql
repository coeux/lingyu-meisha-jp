drop database if exists GodSer;
create database GodSer;
use GodSer;

drop table if exists Machine;
create table if not exists Machine(
id int(10) unsigned auto_increment comment 'Machine id',
type tinyint(3) default '0' comment '1虚拟机，2数据库, 3邀请码服务器',
pubip varchar(16) not null default '' comment '外网ip',
priip varchar(16) not null default '' comment '内网ip',
des varchar(30) character set utf8 not null default '' comment '描述',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id))engine=innodb;

drop table if exists Domain;
create table if not exists Domain(
id int(10) unsigned auto_increment comment '组id',
name varchar(10) character set utf8 not null default '' comment '组名',
type tinyint(3) default '1' comment '1运营，2内部测试，3版本测试',
dbid int(10) unsigned default '0' comment '组数据库 DB id',
dbport  int(10) unsigned default '0' comment '组数据库 DB port',
dbname varchar(20) character set utf8 not null default '' comment '组数据库名',
rid int(10) unsigned default '0' comment '组路由',
invid int(10) unsigned default '0' comment '组邀请码服务器',
invdbid int(10) unsigned default '0' comment '组邀请码dbid',
invdbport  int(10) unsigned default '0' comment '邀请码DB port',
invdbname varchar(20) character set utf8 not null default '' comment '邀请码数据库名',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id), unique key(name))engine=innodb;

drop table if exists Host;
create table if not exists Host(
id int(10) unsigned auto_increment comment 'hostid',
did int(10) unsigned default '0' comment 'Domain id',
mid int(10) unsigned default '0' comment 'Machine id',
hostid int(10) unsigned default '0' comment 'host id',
sertype tinyint(3) default '0' comment '服务器类型,和remote_info中的remote_id对应',
sername varchar(10) character set utf8 not null default '' comment '服务器名',
recom tinyint(3) default '0' comment '是否推荐，1推荐，0不推荐',
state tinyint(3) default '0' comment '服务器状态, 0:关闭,1:开启,2:被合并',
compo int(10) default '0' comment '合并到服务器id',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id), 
key(did, mid))engine=innodb;

drop table if exists Log;
create table if not exists Log(
id int(10) unsigned auto_increment comment 'log id',
did int(10) unsigned default '0' comment '组id',
hid int(10) unsigned default '0' comment '服务器id',
info varchar(100) character set utf8 not null default '' comment '日志信息',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id), key(did))engine=innodb;

drop table if exists Platform;
create table if not exists Platform(
id int(10) unsigned auto_increment comment '平台id',
name varchar(10) character set utf8 not null default '' comment '平台名',
state tinyint(3) default '0' comment '平台状态, 0:关闭,1:开启',
test tinyint(3) default '0' comment '平台测试状态, 0:关闭,1:开启内部测试,2:开启外部测试',
vertest tinyint(3) default '0' comment '平台版本测试状态, 0:关闭,1:开启',
ver varchar(10) character set utf8 not null default '' comment '平台测试版本',
outid int(10) unsigned default '0' comment '运营组id',
inid int(10) unsigned default '0' comment '测试组id',
vtid int(10) unsigned default '0' comment '版本测试组id',
outip varchar(16) not null default '' comment '运营路由ip',
inip varchar(16) not null default '' comment '测试路由ip',
vtip varchar(16) not null default '' comment '版本测试路由ip',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id), unique key(name))engine=innodb;
