#!/bin/sh
export PATH=$PATH:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/mysql/bin/
 
#YESTERDAY=$(date -d yesterday +'%Y%m%d') 
for d in $(datelist 20120611 20120617)
do
    mysqldump -uroot NUTS XYQ_Newuser${d} | mysql -h220.181.36.18 -uquery -pQSJFsj_fee@GB NUTS
done
