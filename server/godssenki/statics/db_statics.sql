set names utf8;

create table if not exists Online(
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
serid smallint(5) unsigned NOT NULL default '0' comment '服务器进程id',
name varchar(64) not null default '' comment '平台帐号',
domain varchar(10) not null default '' comment '平台类型',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
nickname varchar(30) character set utf8 default null comment '角色名',
counttime int(10) unsigned default '0' comment '登录时角色寿命',
logintm datetime default NULL comment '登录时间',
loginstamp int(10) unsigned not null default '0' comment '登录时间戳',
mac char(64) default null comment '设备地址',
sys tinyint(3) unsigned not null default '0' comment '设备类型，1,pc，2,android，3,ios',
device varchar(20) not null default '' comment '设备类型',
os varchar(20) not null default '' comment '操作系统',
grade smallint(5) unsigned default NULL comment '等级',
exp int(10) unsigned not null default '0' comment '经验',
resid smallint(5) unsigned DEFAULT NULL comment '职业',
vip tinyint(3) unsigned default null comment 'vip等级',
questid smallint(5) unsigned default null comment '主线任务',
primary key(id),
key(serid,uid))ENGINE=InnoDB;

CREATE TABLE if not exists QuitLog (
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
name varchar(64) not null default '' comment '平台帐号',
domain varchar(10) not null default '' comment '平台类型',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
nickname varchar(30) character set utf8 default null comment '角色名',
counttime int(10) unsigned default '0' comment '登录时角色寿命',
totaltime int(10) unsigned default '0' comment '退出时角色寿命',
logintm datetime default NULL comment '登录时间',
quittm datetime default NULL comment '退出时间',
mac char(64) default null comment '设备地址',
sys tinyint(3) unsigned not null default '0' comment '设备类型，1,pc，2,android，3,ios',
device varchar(20) not null default '' comment '设备类型',
os varchar(20) not null default '' comment '操作系统',
grade smallint(5) unsigned default NULL comment '等级',
exp int(10) unsigned not null default '0' comment '经验',
resid smallint(5) unsigned DEFAULT NULL comment '职业',
vip tinyint(3) unsigned default null comment 'vip等级',
questid smallint(5) unsigned default null comment '主线任务',
step smallint(5) unsigned default null comment '流失点',
primary key(id),
key(aid))ENGINE=InnoDB;

CREATE TABLE BuyLog (
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
domain varchar(10) not null default '' comment '平台类型',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
nickname varchar(30) character set utf8 default null comment '角色名',
vip tinyint(3) unsigned default null comment 'vip等级',
buytm datetime DEFAULT NULL comment '购买时间',
resid smallint(5) unsigned not null default '0' comment '道具种类',
itemname varchar(30) character set utf8 default null comment '道具名',
count smallint(5) unsigned not null default '0' comment '道具个数',
buytype tinyint(3) unsigned not null default '0' comment '购买类型，1,水晶购买，2,友情点购买',
price int(10) unsigned not NULL default '0' comment '价格',
payyb int(10) unsigned not NULL default '0' comment '收费元宝',
freeyb int(10) unsigned not NULL default '0' comment '免费元宝',
fpoint int(10) unsigned not null default '0' comment '友情点',
PRIMARY KEY (id),
key(uid)
)ENGINE=Innodb DEFAULT CHARSET=latin1;

CREATE TABLE ConsumeLog (
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
domain varchar(10) not null default '' comment '平台类型',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
nickname varchar(30) character set utf8 default null comment '角色名',
consumetm datetime DEFAULT NULL comment '消耗时间',
consumetype tinyint(3) unsigned default null comment '消耗类型，1,使用,2,售出',
resid smallint(5) unsigned DEFAULT NULL comment '道具种类',
itemname varchar(30) character set utf8 default null comment '道具名',
count smallint(5) unsigned not null default '0' comment '道具个数',
balance smallint(5) unsigned not null default '0' comment '剩余个数',
PRIMARY KEY (id),
key(uid)
)ENGINE=Innodb DEFAULT CHARSET=latin1;

CREATE TABLE YBLog(
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
sid smallint(5) unsigned not null default '0' comment '服务器id', 
nickname varchar(30) character set utf8 default null comment '角色名',
name varchar(32) NOT NULL default '' comment '平台账号',
domain varchar(10) not null default '' comment '平台类型',
appid varchar(32) NOT NULL default '' comment '应用id',
serid int(10) unsigned not null default '0' comment '订单号',
payyb int(10) unsigned not null default '0' comment '收费水晶数',
freeyb int(10) unsigned not null default '0' comment '免费水晶数',
totalyb int(10) unsigned not null default '0' comment '水晶总数',
resid int(10) unsigned not null default '0' comment '表格id',
price int(10) unsigned not null default '0' comment '表格价格',
count int(10) unsigned not null default '0' comment '购买个数',
rmb int(10) unsigned not null default '0' comment '实际支付价格',
tradetm datetime DEFAULT NULL comment '充值时间',
giventm datetime default NULL comment '领取时间',
PRIMARY KEY (id),
key(domain,uid)
)ENGINE=innodb deFAULT CHARSET=latin1;

create table EventLog(
id int(10) unsigned auto_increment,
uid int(10) unsigned NOT NULL default '0' comment '角色id',
aid int(10) unsigned not null default '0' comment '帐号id',
domain varchar(10) character set utf8 not null default '' comment '平台类型',
hostnum smallint(5) unsigned NOT NULL default '0' comment '服务器编号',
nickname varchar(30) character set utf8 default null comment '角色名',
eventid int(10) unsigned not null default '0' comment '事件id',
eventm datetime DEFAULT NULL comment '事件时间',
resid int(10) unsigned not null default '0' comment '表格id',
count int(10) unsigned not null default '0' comment '物品个数',
code int(10) unsigned not null default '0' comment '返回码',
flag int(10) unsigned not null default '0' comment '标志位',
extra varchar(300) character set utf8 default NULL comment '附加信息',
PRIMARY KEY (id),
key(domain,uid)
)ENGINE=innodb deFAULT CHARSET=latin1;

create table EventDefine(
id int(10) unsigned not null default '0' comment '事件id',
msg varchar(100) character set utf8 default null comment '事件明细',
primary key(id));
insert INTO EventDefine VALUES (1102,'离开游戏'),(3999,'补偿'),(4000,'登陆游戏'),(4006,'背包改变'),(4007,'进入主城'),(4016,'体力改变'),(4017,'阵型改变'),(4018,'等级改变'),(4019,'金币改变'),(4020,'水晶改变'),(4032,'强化装备'),(4034,'装备升级'),(4039,'宝石镶嵌'),(4046,'酒馆刷新'),(4048,'招募伙伴'),(4055,'试炼场接任务'),(4068,'战历改变'),(4071,'技能升级'),(4082,'竞技场挑战'),(4100,'查看其他用户信息'),(4114,'友情点改变'),(4222,'进入boss场景'),(4224,'攻打boss'),(4229,'离开boss场景'),(4231,'聊天'),(4300,'打开礼包'),(4342,'添加好友'),(4345,'回应添加好友请求'),(4346,'删除好友'),(4361,'领取奖励'),(4368,'好友挑战'),(4402,'接任务'),(4404,'交任务'),(4453,'设置角色名'),(4502,'训练伙伴'),(4524,'符文碎片改变'),(4553,'设置角色名'),(4555,'新手奖励宝石'),(4559,'新手酒馆招募'),(4684,'普通关卡'),(4685,'精英关卡'),(4803,'进入商城'),(4810,'炼金'),(4842,'领取竞技场奖励'),(4844,'匹萨'),(4900,'查看vip购买信息'),(4906,'随机取名'),(4912,'领取在线奖励'),(4990,'兑换水晶');

create table NewAccount(
id int(10) unsigned auto_increment,
domain varchar(10) character set utf8 not null default '' comment '平台类型',
name varchar(64) not null default '' comment '平台帐号',
aid int(10) unsigned not null default '0' comment '帐号id',
ctime datetime DEFAULT NULL comment '购买时间',
primary key(id),
key(domain,ctime)
)engine=innodb;

CREATE TABLE NewRole (
id int(10) unsigned NOT NULL AUTO_INCREMENT,
domain varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '' COMMENT '平台类型',
hostnum int(11) NOT NULL DEFAULT '0',
aid int(10) unsigned NOT NULL DEFAULT '0' COMMENT '帐号id',
uid int(11) unsigned DEFAULT NULL,
mac char(64) DEFAULT NULL,
ctime datetime DEFAULT NULL COMMENT '创建时间',
PRIMARY KEY (id)
) ENGINE=InnoDB;

create table FpException(
id int(10) unsigned NOT NULL AUTO_INCREMENT,
domain varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '' COMMENT '平台类型',
hostnum int(11) NOT NULL DEFAULT '0',
aid int(10) unsigned NOT NULL DEFAULT '0' COMMENT '帐号id',
uid int(11) unsigned DEFAULT NULL,
nickname varchar(30) character set utf8 default null comment '角色名',
resid smallint(5) unsigned DEFAULT NULL comment '职业',
rolefp int(10) unsigned NOT NULL DEFAULT '0',
resfp int(10) unsigned NOT NULL DEFAULT '0',
ctime datetime DEFAULT NULL COMMENT '创建时间',
primary key(id)
) ENGINE=InnoDB;
