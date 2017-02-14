set names utf8;

create table if not exists aid(
value int(10) unsigned not null default '0',
primary key(value))engine=innodb;
insert into aid values(1000);

create table if not exists uid(
value int(10) unsigned not null default '0',
primary key(value))engine=innodb;
insert into uid values(1000);

create table if not exists ggid(
value int(10) unsigned not null default '0',
primary key(value))engine=innodb;
insert into ggid values(1000);

create table if not exists orderid(
value int(10) unsigned not null default '0',
primary key(value))engine=innodb;
insert into orderid values(1000);

create table if not exists Account(
aid int(10) unsigned NOT NULL comment '帐号id',
domain varchar(10) not null default '' comment '平台名',
name varchar(64) not null default '' comment '平台id',
flag tinyint(3) default '0' comment '帐号状态，0,正常',
lasthostnum smallint(5) unsigned default '0' comment '最后登录服务器',
lastuid int(10) unsigned default null comment '最后登录角色',
ctime timestamp not null default CURRENT_TIMESTAMP comment '帐号建立时间',
primary key(aid),
unique key(domain, name))engine=innodb;

create table if not exists Pay(
serid int(10) unsigned not null default '0' comment '订单号',
sid smallint(5) unsigned not null default '0' comment '服务器id', 
uid int(11) not null default '0' comment '游戏中的用户id',
appid char(32) NOT NULL default '' comment '应用id',
uin char(32) NOT NULL default '' comment '平台账号',
domain char(10) NOT NULL default '' comment '平台名',
goodsid int(11) not null default '0' comment '购买的商品id',
goodnum int(11) not null default '0' comment '购买的商品数量',
cristal int(11) not null default '0' comment '购买的水晶数量',
reward_cristal int(11) not null default '0' comment '奖励的水晶数量',
repo_rmb int(11) not null default '0' comment '表格价格',
pay_rmb int(11) not null default '0' comment '实际支付价格',
orderid varchar(64) NOT NULL DEFAULT '',
paytime char(32) NOT NULL default '' comment '支付时间',
giventime char(32) NOT NULL default '' comment '领取时间',
state int(11) not null default '0' comment '0:无效，1:新订单(新创建的订单), 2:支付完成的订单(未领取奖励), 3:已经关闭的订单',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(serid),
key(uid,state))engine=innodb;

create table if not exists InvCode(
uid int(10) unsigned not null default '0',
lv1 smallint(5) unsigned not null default '0',
lv2 smallint(5) unsigned not null default '0',
lv3 smallint(5) unsigned not null default '0',
lv4 smallint(5) unsigned not null default '0',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(uid))engine=innodb;

create table if not exists InvPlatform(
id int(10) unsigned auto_increment,
domain varchar(10) NOT NULL default '' comment '平台名',
serid int(10) unsigned not null default '0',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id),
unique key(domain))engine=innodb;
insert into InvPlatform(domain,serid) values('91',1);
insert into InvPlatform(domain,serid) values('360',1);
insert into InvPlatform(domain,serid) values('downjoy',1);
insert into InvPlatform(domain,serid) values('duoku',1);
insert into InvPlatform(domain,serid) values('mi',1);
insert into InvPlatform(domain,serid) values('mzw',1);
insert into InvPlatform(domain,serid) values('uc',1);
insert into InvPlatform(domain,serid) values('wdj',1);
insert into InvPlatform(domain,serid) values('teeplay',1);
insert into InvPlatform(domain,serid) values('teeplay2',1);
insert into InvPlatform(domain,serid) values('91ios',2);
insert into InvPlatform(domain,serid) values('ky',2);
insert into InvPlatform(domain,serid) values('pp',2);
insert into InvPlatform(domain,serid) values('tbt',2);
insert into InvPlatform(domain,serid) values('itools',2);
insert into InvPlatform(domain,serid) values('teeplayios',2);

create table if not exists Bugchang(
id int(10) unsigned auto_increment,
domain char(10) NOT NULL default '' comment '平台名',
name varchar(64) not null default '' comment '平台id',
totalpay int(11) not null default '0' comment '总支付',
vip int(11) not null default '0' comment 'vip等级',
state int(11) not null default '0' comment '0:未领取，1:领取',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(id),
key(domain,name))engine=innodb;

create table if not exists Cdkey(
sn char(8) NOT NULL default '' COMMENT '序列号',
flag tinyint(3) NOT NULL default '0',
expire_date date default null,
gentm datetime default null,
domain varchar(10) not null default '' comment '平台名',
uid int(11) NOT NULL default '0',
nickname varchar(30) character set utf8 default '',
giventm datetime DEFAULT '0000-00-00',
ctime timestamp not null default CURRENT_TIMESTAMP comment 'create time',
primary key(sn),
key(flag,uid))engine=innodb;

