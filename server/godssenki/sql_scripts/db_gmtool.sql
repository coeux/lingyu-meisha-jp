use God_gmtool;

create table if not exists Host(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
hostname varchar(16) character set utf8 default null comment '服务器名',
gwip varchar(16) character set utf8 default null comment '网关ip',
gwport int(10) unsigned default '0' comment '网关端口',
dbname varchar(16) DEFAULT NULL COMMENT '',
recome tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '',
isnew tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '',
comid int(10) unsigned NOT NULL DEFAULT '0' COMMENT '',
machineid int(10) unsigned DEFAULT '0' COMMENT '',
activetime varchar(32) DEFAULT '' COMMENT '',
stoptime varchar(32) DEFAULT '' COMMENT '',
stoptm int(10) unsigned DEFAULT '0' COMMENT '',
state tinyint(3) unsigned DEFAULT '0' COMMENT '',
jstr varchar(2048) DEFAULT '' COMMENT '',
primary key(id),
key(platname, hostnum))ENGINE=InnoDB;

create table if not exists GMUser(
`id` int(10) NOT NULL AUTO_INCREMENT,
`name` char(16) NOT NULL DEFAULT '',
`pwd` varchar(64) NOT NULL DEFAULT '',
`m1` tinyint(1) DEFAULT NULL,
`m2` tinyint(1) DEFAULT NULL,
`m3` tinyint(1) DEFAULT NULL,
`m4` tinyint(1) DEFAULT NULL,
`m5` tinyint(1) DEFAULT NULL,
`m6` tinyint(1) DEFAULT NULL,
`m7` tinyint(1) DEFAULT NULL,
`m8` tinyint(1) DEFAULT NULL,
`m9` tinyint(1) DEFAULT NULL,
`ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`id`),
UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

create table if not exists UpNotice(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
notice varchar(1024) character set utf8 not null default '' comment '公告内容',
version varchar(20) character set utf8 not null default '' comment '版本号',
gmid int(10) unsigned NOT NULL default '0' comment 'gm账号',
ctime timestamp not null default CURRENT_TIMESTAMP comment '创建时间',
primary key(id),
key(platname))ENGINE=InnoDB;

create table if not exists MaqueeNotice(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
notice varchar(1024) character set utf8 not null default '' comment '公告内容',
gmid int(10) unsigned NOT NULL default '0' comment 'gm账号',
ctime timestamp not null default CURRENT_TIMESTAMP comment '创建时间',
primary key(id),
key(platname, hostnum))ENGINE=InnoDB;

create table if not exists OpReward(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
uid int(10) unsigned NOT NULL default '0' comment 'uid',
nickname varchar(20) character set utf8 not null default '' comment '角色名',
resid int(10) unsigned NOT NULL default '0' comment '道具名',
num int(10) unsigned NOT NULL default '0' comment '道具数量',
cname varchar(20) character set utf8 not null default '' comment '提交审核的用户名',
vname varchar(20) character set utf8 not null default '' comment '审核通过的用户名',
state int(10) unsigned NOT NULL default '0' comment '状态',
ctime datetime default NULL comment '审核通过时间',
vtime datetime default NULL comment '审核通过时间',
info varchar(200) character set utf8 not null default '' comment '奖励原因',
primary key(id),
key(platname, state))ENGINE=InnoDB;

create table if not exists OpMail(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
uid int(10) unsigned NOT NULL default '0' comment 'uid',
nickname varchar(20) character set utf8 not null default '' comment '角色名',
mail varchar(500) character set utf8 not null default '' comment '邮件内容',
cname varchar(20) character set utf8 not null default '' comment '提交审核的用户名',
vname varchar(20) character set utf8 not null default '' comment '审核通过的用户名',
state int(10) unsigned NOT NULL default '0' comment '状态',
ctime datetime default NULL comment '审核通过时间',
vtime datetime default NULL comment '审核通过时间',
info varchar(200) character set utf8 not null default '' comment '备注',
primary key(id),
key(platname, state))ENGINE=InnoDB;

create table if not exists Log(
id int(10) unsigned auto_increment,
name varchar(20) character set utf8 not null default '' comment '操作gm名',
platname varchar(10) character set utf8 not null default '' comment '平台名',
op_type varchar(20) character set utf8 not null default '' comment '操作项',
op_target varchar(200) character set utf8 not null default '' comment '操作目标',
op_info varchar(1024) character set utf8 not null default '' comment '操作内容',
ctime timestamp not null default CURRENT_TIMESTAMP comment '创建时间',
primary key(id),
key(name, platname, op_type))ENGINE=InnoDB;

create table if not exists Maquee(
id int(10) unsigned auto_increment,
hostnum int(10) unsigned not null default '0',
platname varchar(20) character set utf8 default '', 
notice1 varchar(100) character set utf8 default '', 
notice2 varchar(100) character set utf8 default '', 
notice3 varchar(100) character set utf8 default '', 
btm varchar(30) character set utf8 default '', 
etm varchar(30) character set utf8 default '', 
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id),
key(hostnum,platname))engine=innodb;

create table if not exists Domain(
id int(10) unsigned auto_increment,
name varchar(20) character set utf8 not null default '' comment '游戏平台名',
ctime timestamp not null default CURRENT_TIMESTAMP comment '创建时间',
primary key(id),
key(name))ENGINE=InnoDB;

create table if not exists DB(
id int(10) unsigned auto_increment,
name varchar(30) character set utf8 not null default '' comment '名称',
ip varchar(16) character set utf8 default null comment 'ip',
port int(10) unsigned default '0' comment '端口',
primary key(id),
key(name))ENGINE=InnoDB;

create table if not exists CMail(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
uid int(10) unsigned NOT NULL default '0' comment 'uid',
nickname varchar(20) character set utf8 not null default '' comment '角色名',
mail varchar(256) character set utf8 not null default '' comment '邮件内容',
back varchar(256) character set utf8 not null default '' comment '回复',
state smallint(3) unsigned NOT NULL default '0' comment '状态',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id),
key(platname, hostnum))ENGINE=InnoDB;

create table if not exists CMailView(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
hostnum int(10) unsigned default '0' comment '服务器id',
uid int(10) unsigned NOT NULL default '0' comment 'uid',
nickname varchar(20) character set utf8 not null default '' comment '角色名',
mail varchar(256) character set utf8 not null default '' comment '邮件内容',
mailtm datetime default NULL comment '玩家提交时间',
back varchar(256) character set utf8 not null default '' comment '回复',
backtm timestamp not null default CURRENT_TIMESTAMP comment '回复时间',
primary key(id),
key(nickname))ENGINE=InnoDB;

create table if not exists GMailView(
id int(10) unsigned auto_increment,
platname varchar(10) character set utf8 not null default '' comment '平台名',
sender varchar(20) character set utf8 not null default '' comment '发送者',
jstr varchar(2048) character set utf8 default null comment '邮件jstr',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id, platname, sender))engine=innodb;
