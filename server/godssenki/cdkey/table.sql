CREATE DATABASE if not exists cdkey;
use cdkey;
drop table if exists Cdkey;
create table if not exists Cdkey(
sn char(8) NOT NULL default '',
flag tinyint(3) NOT NULL default '0',
expiredate date default NULL,
gentm datetime NOT NULL default '0000-00-00 00:00:00',
primary key(sn))engine=innodb;

drop table if exists gen_log;
CREATE TABLE gen_log (
id int(11) NOT NULL auto_increment,
gameid varchar(16) NOT NULL default '',
gentm datetime NOT NULL default '0000-00-00 00:00:00',
expiredate date default NULL,
type int(11) NOT NULL default '0',
gen_num int(11) NOT NULL default '0',
last_num int(11) NOT NULL default '0',
PRIMARY KEY(id))engine=InnoDB;
