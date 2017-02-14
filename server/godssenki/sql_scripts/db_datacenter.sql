set names utf8;

CREATE TABLE if not exists Account (
aid int(11) NOT NULL DEFAULT '0',
name varchar(60) DEFAULT NULL,
domain varchar(10) NOT NULL DEFAULT '',
firstdate datetime not NULL DEFAULT '0000-00-00 00:00:00',
firstmac varchar(64) DEFAULT NULL,
firstsys tinyint(3) NOT NULL DEFAULT '0',
firstdevice varchar(20) DEFAULT NULL,
firstos varchar(20) DEFAULT NULL,
firstpay datetime DEFAULT NULL,
firstpaylv int(11) unsigned DEFAULT '0',
lastdate timestamp not NULL DEFAULT '0000-00-00 00:00:00',
lastmac varchar(64) DEFAULT NULL,
lastsys tinyint(3) NOT NULL DEFAULT '0',
lastdevice varchar(20) DEFAULT NULL,
lastos varchar(20) DEFAULT NULL,
lastpay datetime DEFAULT NULL,
uid int(11) unsigned DEFAULT NULL,
hostnum int(10) unsigned default '0',
nickname varchar(30) DEFAULT NULL,
grade int(10) unsigned default '0',
exp int(10) unsigned DEFAULT NULL,
resid int(10) unsigned DEFAULT NULL,
vip int(10) unsigned DEFAULT 0,
questid int(10) unsigned DEFAULT NULL,
step smallint(5) unsigned NOT NULL DEFAULT '0',
PRIMARY KEY (domain,aid),
UNIQUE KEY name (name,domain),
UNIQUE KEY domain (domain,name),
KEY lastdate (lastdate),
KEY newdate (firstdate),
KEY aid (aid,firstdate)
) ENGINE=InnoDB;

create table stat_realtime(
stat_time date NOT NULL,
domain varchar(10) character set utf8 DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
new int(10) unsigned NOT NULL DEFAULT '0',
dau int(10) unsigned NOT NULL DEFAULT '0',
ret int(10) unsigned NOT NULL DEFAULT '0',
payyb int(10) unsigned NOT NULL DEFAULT '0',
paycount int(10) unsigned NOT NULL DEFAULT '0',
PRIMARY KEY (stat_time,domain,hostnum)
)engine=innodb;

CREATE TABLE stat_dashboard (
id int(10) unsigned auto_increment,
domain varchar(10) character set utf8 DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
stat_time date NOT NULL DEFAULT '0000-00-00',
newuser int(11) NOT NULL DEFAULT '0',
alluser int(11) NOT NULL DEFAULT '0',
dau int(11) NOT NULL DEFAULT '0',
pay int(11) NOT NULL DEFAULT '0',
new_pay int(11) NOT NULL DEFAULT '0',
pay_people int(11) NOT NULL DEFAULT '0',
retain_1 float NOT NULL DEFAULT '0',
retain_3 float NOT NULL DEFAULT '0',
retain_7 float NOT NULL DEFAULT '0',
first_pay int(11) NOT NULL DEFAULT '0',
new_first_pay int(11) NOT NULL DEFAULT '0',
double_pay int(11) NOT NULL DEFAULT '0',
all_pay_people int(11) NOT NULL DEFAULT '0',
vip1 int(11) NOT NULL DEFAULT '0',
vip2 int(11) NOT NULL DEFAULT '0',
vip3 int(11) NOT NULL DEFAULT '0',
vip4 int(11) NOT NULL DEFAULT '0',
vip5 int(11) NOT NULL DEFAULT '0',
vip6 int(11) NOT NULL DEFAULT '0',
vip7 int(11) NOT NULL DEFAULT '0',
vip8 int(11) NOT NULL DEFAULT '0',
vip9 int(11) NOT NULL DEFAULT '0',
vip10 int(11) NOT NULL DEFAULT '0',
vip11 int(11) NOT NULL DEFAULT '0',
vip12 int(11) NOT NULL DEFAULT '0',
newrole int(11) NOT NULL DEFAULT '0',
device int(11) NOT NULL DEFAULT '0',
wau int(11) NOT NULL DEFAULT '0',
mau int(11) NOT NULL DEFAULT '0',
pay_1 int(11) NOT NULL DEFAULT '0',
pay_3 int(11) NOT NULL DEFAULT '0',
pay_7 int(11) NOT NULL DEFAULT '0',
pay_30 int(11) NOT NULL DEFAULT '0',
top int(11) NOT NULL DEFAULT '0',
dect int(11) NOT NULL DEFAULT '0',
doat int(11) NOT NULL DEFAULT '0',
dect_n int(11) NOT NULL DEFAULT '0',
doat_n int(11) NOT NULL DEFAULT '0',
rmb_sum int(11) NOT NULL DEFAULT '0',
rmb_day int(11) NOT NULL DEFAULT '0',
dau_device int(11) NOT NULL DEFAULT '0',
new_device int(11) NOT NULL DEFAULT '0',
primary key(id)
) ENGINE=InnoDB;

CREATE TABLE stat_pay_analyst(
domain varchar(10) character set utf8 DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
alluser int(11) NOT NULL DEFAULT '0',
first_pay int(11) NOT NULL DEFAULT '0',
double_pay int(11) NOT NULL DEFAULT '0',
all_pay_people int(11) NOT NULL DEFAULT '0',
vip0 int(11) NOT NULL DEFAULT '0',
vip1 int(11) NOT NULL DEFAULT '0',
vip2 int(11) NOT NULL DEFAULT '0',
vip3 int(11) NOT NULL DEFAULT '0',
vip4 int(11) NOT NULL DEFAULT '0',
vip5 int(11) NOT NULL DEFAULT '0',
vip6 int(11) NOT NULL DEFAULT '0',
vip7 int(11) NOT NULL DEFAULT '0',
vip8 int(11) NOT NULL DEFAULT '0',
vip9 int(11) NOT NULL DEFAULT '0',
vip10 int(11) NOT NULL DEFAULT '0',
vip11 int(11) NOT NULL DEFAULT '0',
vip12 int(11) NOT NULL DEFAULT '0',
primary key(domain,hostnum)
) ENGINE=InnoDB;

CREATE TABLE stat_online_new (
id int(10) unsigned auto_increment,
domain varchar(10) character set utf8 DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
stat_time datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
num int(11) NOT NULL DEFAULT '0',
primary key(id)
) ENGINE=InnoDB;

create table stat_grade (
id int(10) unsigned auto_increment,
domain varchar(10) NOT NULL DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
stat_time date NOT NULL DEFAULT '0000-00-00',
lv smallint(11) unsigned NOT NULL DEFAULT '0',
num int(11) unsigned NOT NULL DEFAULT '0',
primary key(id),
key(stat_time,domain,hostnum)
) ENGINE=InnoDB;

create table if not exists stat_zone(
zone varchar(16) CHARACTER SET utf8 default null,
primary key(zone))
engine=innodb;
insert into stat_zone value('android');
insert into stat_zone value('iOS');
insert into stat_zone value('appstore');

create table if not exists stat_zone_hostnum(
id int(10) unsigned auto_increment comment 'id',
zone varchar(16) CHARACTER SET utf8 default null,
hostnum int(10) unsigned default '0',
ctime timestamp not null default CURRENT_TIMESTAMP,
primary key(id),
unique key(zone,hostnum))
engine=innodb;
insert into stat_zone_hostnum(zone,hostnum) value('android',1);

create table if not exists stat_platform(
id int(10) unsigned auto_increment comment 'id',
zone varchar(16) CHARACTER SET utf8 default null,
domain varchar(16) CHARACTER SET utf8 default null,
ctime timestamp not null default CURRENT_TIMESTAMP,
primary key(id),
unique key(zone,domain))
engine=innodb;
insert into stat_platform(zone,domain) value('android','uc');
insert into stat_platform(zone,domain) value('android','duoku');
insert into stat_platform(zone,domain) value('android','360');

create table if not exists stat_hostnum(
id int(10) unsigned auto_increment comment 'id',
domain varchar(16) CHARACTER SET utf8 default null,
hostnum int(10) unsigned default '0',
ctime timestamp not null default CURRENT_TIMESTAMP,
primary key(id),
unique key(domain,hostnum))
engine=innodb;

create table if not exists stat_itemname(
resid smallint(5) not null default '0',
itemname varchar(30) CHARACTER SET utf8 DEFAULT null,
ctime timestamp not null default CURRENT_TIMESTAMP,
primary key(resid))
engine=innodb;

create table if not exists stat_buy(
id int(10) unsigned auto_increment,
buyday date default null,
domain varchar(16) character set utf8 default null,
hostnum int(10) unsigned not null default '0',
vip tinyint(10) unsigned not null default '0',
resid smallint(5) unsigned not null default '0',
count int(10) unsigned not null default '0',
people int(10) unsigned not null default '0',
yb int(10) unsigned not null default '0',
primary key(id))
engine=innodb;

create table stat_newuser_login (
id int(10) unsigned auto_increment,
domain varchar(10) NOT NULL DEFAULT '',
hostnum int(10) unsigned not null default '0',
start_time date NOT NULL DEFAULT '0000-00-00',
end_time date NOT NULL DEFAULT '0000-00-00',
login_user_high int(11) NOT NULL DEFAULT '0',
login_user_low int(11) NOT NULL DEFAULT '0',
primary key(id),
unique key(domain,hostnum,start_time,end_time)
) ENGINE=InnoDB;

CREATE TABLE stat_pay_5mins (
id int(10) unsigned auto_increment,
domain varchar(10) character set utf8 DEFAULT '',
hostnum int(11) NOT NULL DEFAULT '0',
stat_time datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
num int(11) NOT NULL DEFAULT '0',
primary key(id)
) ENGINE=InnoDB;

CREATE TABLE stat_yblog_by_date (
day date NOT NULL,
payyb int(10) unsigned NOT NULL DEFAULT '0',
new int(10) unsigned NOT NULL DEFAULT '0',
dau int(10) unsigned NOT NULL DEFAULT '0',
ret int(10) unsigned not null default '0',
PRIMARY KEY (day)
) ENGINE=InnoDB;

CREATE TABLE FirstBuyLog (
aid int(10) unsigned not null default '0' comment '帐号id',
uid int(10) unsigned NOT NULL default '0' comment '角色id',
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
PRIMARY KEY (aid)
)ENGINE=Innodb DEFAULT CHARSET=latin1;

CREATE TABLE Steps (
step int(10) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO Steps VALUES (1000),(1010),(1020),(1030),(1040),(1050),(1060),(1070),(1080),(1090),(1100),(1110),(1120),(1130),(1140),(1150),(1160),(1170),(1180),(1190),(1200),(1210),(1220),(1230),(1240),(1250),(1260),(1270),(1280),(1290),(1300),(1310),(1320),(1330),(1340),(1350),(1360),(1370),(1380),(1390),(1400),(1410),(1420),(1430),(1440),(1450),(1460),(1470),(1480),(1490),(1500),(1510),(1520),(1530),(1540),(1550),(1560),(1570),(1580),(1590),(1600),(1610),(1620),(1630),(1640),(1650),(1660),(1670),(1680),(1690),(1700),(1710),(1720),(1730),(1740),(1750),(1760),(1770),(1780),(1790),(1800),(1810),(1820),(1830),(1840),(1850),(1860),(1870),(1880),(1890),(1900),(1910),(1920),(1930),(1940),(1950),(1960),(1970),(1980),(1990),(2000),(2010),(2020),(2030),(2040),(2050),(2060),(2070),(2080),(2090),(2100),(2110),(2120),(2130),(2140),(2150),(2160),(2170),(2180),(2190),(2200),(2210),(2220),(2230),(2240),(2250),(2260),(2270),(2280),(2290),(2300),(2310),(2320),(2330),(2340),(2350),(2360),(2370),(2380),(2390),(2400),(2410),(2420),(2430),(2440),(2450),(2460),(2470),(2480),(2490),(2500),(2510),(2520),(2530),(2540),(2550),(2560),(2570),(2580),(2590),(2600),(2610),(2620),(2630),(2640),(2650),(2660),(2670),(2680),(2690),(2700),(2710),(2720),(2730),(2740),(2750),(2760),(2770),(2780),(2790),(2800),(2810),(2820),(2830),(2840),(2850),(2860),(2870);
