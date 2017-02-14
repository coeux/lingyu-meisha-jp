#!/usr/bin/python

from nuts_conf import getconf
from datetime import timedelta
from tools import str2date,date_list
import mylog
import re

log = mylog.debugf('cal_nuts_data')

class CalStaticsData(object):
    def __init__(self, dbi, datelist):
        self.dbi = dbi
        self.datelist = datelist

    def cal(self, game):
        log(20, 'datelist = %s' % self.datelist)
        kv = {'game':game}
        kv.update(getconf(game))
        for d in self.datelist:
            kv['rundt']=str(d)
            kv['rundt_date']=str2date(kv['rundt'])
            kv['rundt_tomorrow_date']=str2date(kv['rundt']) + timedelta(1)
            kv['rundt_29_before_date']=str2date(kv['rundt']) - timedelta(29)
            kv['rundt_1_before_date']=str2date(kv['rundt']) - timedelta(1)
            kv['rundt_3_before_date']=str2date(kv['rundt']) - timedelta(3)
            kv['rundt_6_before_date']=str2date(kv['rundt']) - timedelta(6)
            kv['rundt_7_before_date']=str2date(kv['rundt']) - timedelta(7)
            kv['rundt_30_before_date']=str2date(kv['rundt']) - timedelta(30)
#update table account
            self.update_account(kv)
#update metadata
            self.update_metadata(kv)
#call __update_
            prefix = re.compile('^_update_\w+')
            funclist = []
            for x in dir(self):
                func = prefix.search(x)
                if func:
                    funclist.append(getattr(self, x))
            funclist.sort()
            for f in funclist:
                f(kv)

    def update_metadata(self,kv):
        sql="""
    insert ignore into stat_hostnum(domain,hostnum)
    select distinct domain,hostnum from QuitLog%(rundt)s where domain<>'';
            """ % kv
        #self.dbi.run_sql(sql)
        
        sql="""
    insert ignore into stat_itemname(resid,itemname)
    select distinct resid,itemname from BuyLog%(rundt)s;
            """ % kv
        self.dbi.run_sql(sql)

    def _update_yblog_by_date_(self,kv):
        sql="""
    delete from stat_yblog_by_date where day='%(rundt_date)s';
            """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    insert into stat_yblog_by_date(day,payyb)
    select '%(rundt_date)s',sum(rmb) from YBLog%(rundt)s;
            """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_yblog_by_date join (
    select '%(rundt_date)s' day ,count(*) c from NewAccount%(rundt)s ) b
    using(day)
    set stat_yblog_by_date.new = b.c;
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_yblog_by_date join
    ( select '%(rundt_date)s' day, count(*) c
    from Account 
    where domain<>'' and 
    lastdate>'%(rundt_date)s' and lastdate<'%(rundt_tomorrow_date)s' ) b
    using(day)
    set stat_yblog_by_date.dau = b.c
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_yblog_by_date join (
    select '%(rundt_date)s' day ,count(*) c from Account
    where firstdate>'%(rundt_1_before_date)s' and firstdate<'%(rundt_date)s' and lastdate>'%(rundt_date)s' ) b
    using(day)
    set stat_yblog_by_date.ret = b.c;
            """ % kv
        self.dbi.run_sql(sql)

    def _update_login_(self,kv):
        sql="""
    delete from stat_newuser_login where end_time='%(rundt_date)s';
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_newuser_login(domain,hostnum,start_time,end_time,login_user_high,login_user_low)
    select domain,hostnum,'%(rundt_date)s','%(rundt_date)s',count(*),count(*)
    from Account
    where firstdate>'%(rundt_date)s' and domain<>''
    group by domain,hostnum;
                """ % kv
        self.dbi.run_sql(sql)

        for i in range(1,30):
            kv['start_start'] = str(str2date(kv['rundt']) - timedelta(i))
            kv['start_end'] = str(str2date(kv['rundt']) - timedelta(i-1))
            sql="""
    insert into stat_newuser_login(domain,hostnum,start_time,end_time,login_user_high)
    select domain,hostnum,'%(start_start)s','%(rundt_date)s',count(*)
    from Account
    where firstdate>'%(start_start)s' and firstdate<'%(start_end)s'
    and lastdate>'%(start_end)s' and domain<>''
    group by domain,hostnum;
                """ % kv
            self.dbi.run_sql(sql)
            
            sql="""
    update stat_newuser_login a join
    ( select domain,hostnum,'%(start_start)s' s,'%(rundt_date)s' e,count(*) c
    from Account
    where firstdate>'%(start_start)s' and firstdate<'%(start_end)s'
    and lastdate>'%(rundt_date)s' and domain<>''
    group by domain,hostnum ) b 
    on a.domain=b.domain and a.hostnum=b.hostnum and a.start_time=b.s and a.end_time=b.e
    set a.login_user_low = b.c
                """ % kv
            self.dbi.run_sql(sql)

    def _update_pay_analyst_(self,kv):
        sql="""
    insert into stat_pay_analyst(domain,hostnum,alluser)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account where domain<>''
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.alluser = c;
            """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    insert into stat_pay_analyst(domain,hostnum,first_pay)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and date(firstdate)=date(firstpay)
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.first_pay = c;
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_pay_analyst(domain,hostnum,double_pay)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and firstpay<>lastpay
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.double_pay = c;
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    insert into stat_pay_analyst(domain,hostnum,all_pay_people)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and firstpay is not null
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.all_pay_people = c;
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip0)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=0
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip0 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip1)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=1
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip1 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip2)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=2
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip2 = c;
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip3)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=3
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip3 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip4)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=4
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip4 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip5)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=5
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip5 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip6)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=6
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip6 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip7)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=7
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip7 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip8)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=8
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip8 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip9)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=9
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip9 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip10)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=10
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip10 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip11)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=11
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip11 = c;
        """ % kv
        self.dbi.run_sql(sql)
        sql="""
    insert into stat_pay_analyst(domain,hostnum,vip12)
    select domain,hostnum,c from
    (
         select domain,hostnum,count(*) c
         from Account
         where domain<>'' and vip=12
         group by domain,hostnum
    ) b
    on duplicate key update stat_pay_analyst.vip12 = c;
        """ % kv
        self.dbi.run_sql(sql)

    def _update_buy_(self,kv):
        sql="""
    delete from stat_buy where buyday='%(rundt_date)s';
            """ % kv
        self.dbi.run_sql(sql)

#        sql="""
#    insert into stat_buy(buyday,domain,hostnum,vip,resid,count,people)
#    select '%(rundt)s',domain,hostnum,vip,resid,sum(count),count(distinct uid)
#    from BuyLog%(rundt)s
#    where domain<>''
#    group by domain,hostnum,resid,vip
#            """ % kv
#        self.dbi.run_sql(sql)
        sql="""
    insert into stat_buy(buyday,domain,resid,count,people,yb)
    select '%(rundt_date)s',domain,resid,sum(count),count(distinct uid),sum(payyb+freeyb)
    from BuyLog%(rundt)s
    where domain<>''
    group by domain,resid
            """ % kv
        self.dbi.run_sql(sql)

        
    def _update_dashboard_(self,kv):
        sql="""
    delete from stat_dashboard where stat_time='%(rundt_date)s';
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_dashboard(domain,hostnum,stat_time,alluser)
    select domain,hostnum,'%(rundt_date)s',count(*)
    from Account where domain<>''
    group by domain,hostnum
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and 
    firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.newuser = b.c
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and 
    lastdate>'%(rundt_date)s' and lastdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.dau = b.c
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,sum(rmb) c
    from YBLog%(rundt)s where domain<>''
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay = b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select y.domain domain,y.hostnum hostnum,'%(rundt_date)s' stat_time,sum(rmb) c
    from YBLog%(rundt)s y join Account c using(domain,aid)
    where domain<>'' and
    firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s'
    group by y.domain,y.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.new_pay = b.c
        """ % kv
        self.dbi.run_sql(sql)


        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(distinct aid) c
    from YBLog%(rundt)s 
    where domain<>'' and rmb<>0
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay_people = b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and date(firstdate)=date(firstpay)
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.first_pay = b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and firstpay<>lastpay
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.double_pay = b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and firstpay is not null
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.all_pay_people = b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=1
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip1= b.c
        """ % kv
        self.dbi.run_sql(sql)
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=2
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip2= b.c
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=3
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip3= b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=4
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip4= b.c
        """ % kv
        self.dbi.run_sql(sql)       

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=5
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip5= b.c
        """ % kv
        self.dbi.run_sql(sql)       
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=6
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip6= b.c
        """ % kv
        self.dbi.run_sql(sql)       
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=7
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip7= b.c
        """ % kv
        self.dbi.run_sql(sql)       
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=8
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip8= b.c
        """ % kv
        self.dbi.run_sql(sql)       
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=9
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip9= b.c
        """ % kv
        self.dbi.run_sql(sql)       
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=10
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip10= b.c
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=11
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip11= b.c
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and vip=12
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.vip12= b.c
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from NewRole
    where domain<>'' and ctime>'%(rundt_date)s' and ctime<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.newrole= b.c
        """ % kv

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account
    where domain<>'' and 
    firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s' and uid is not null
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.newrole= b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(distinct firstmac) c
    from Account
    where domain<>'' and 
    firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.new_device= b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from QuitLog%(rundt)s where domain<>''
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.dect = b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,sum(totaltime-counttime) c
    from QuitLog%(rundt)s where domain<>''
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.doat = b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select q.domain domain,q.hostnum hostnum,'%(rundt_date)s' stat_time,count(*) c
    from QuitLog%(rundt)s q join Account acc using(aid) 
    where acc.firstdate>'%(rundt_date)s' and acc.firstdate<'%(rundt_tomorrow_date)s'
    group by q.domain,q.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.dect_n = b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select q.domain domain,q.hostnum hostnum,'%(rundt_date)s' stat_time,sum(totaltime-counttime) c
    from QuitLog%(rundt)s q join Account acc using(aid) 
    where acc.firstdate>'%(rundt_date)s' and acc.firstdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.doat_n = b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account
    where domain<>'' and firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.device= b.c
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and firstdate>'%(rundt_date)s' and firstdate<'%(rundt_tomorrow_date)s'
    and date(firstdate)=date(firstpay)
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.new_first_pay = b.c
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and lastdate>'%(rundt_6_before_date)s' 
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.wau = b.c
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(*) c
    from Account 
    where domain<>'' and lastdate>'%(rundt_29_before_date)s' 
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.mau = b.c
        """ % kv
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( 
        select domain,hostnum,'%(rundt_date)s' stat_time,max(s) max_s from 
        (
            select domain,hostnum,stat_time,sum(num) s
            from stat_online_new
            where domain<>'' and stat_time>'%(rundt_date)s' and stat_time<'%(rundt_tomorrow_date)s'
            group by domain,hostnum,stat_time 
        ) b 
        group by domain,hostnum
    ) c
    using(domain,hostnum,stat_time)
    set a.top = c.max_s
        """ % kv
        #print(sql)
        self.dbi.run_sql(sql)

        sql="""
    update stat_dashboard a join
    ( select domain,y.hostnum hostnum,'%(rundt_1_before_date)s' stat_time,sum(rmb) s
    from YBLog%(rundt)s y join Account using(domain,aid) where domain<>'' 
    and date(firstdate)='%(rundt_1_before_date)s'
    group by domain,y.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay_1 = b.s
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,y.hostnum hostnum,'%(rundt_3_before_date)s' stat_time,sum(rmb) s
    from YBLog%(rundt)s y join Account using(domain,aid) where domain<>'' 
    and date(firstdate)='%(rundt_3_before_date)s'
    group by domain,y.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay_3 = b.s
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,y.hostnum hostnum,'%(rundt_7_before_date)s' stat_time,sum(rmb) s
    from YBLog%(rundt)s y join Account using(domain,aid) where domain<>'' 
    and date(firstdate)='%(rundt_7_before_date)s'
    group by domain,y.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay_7 = b.s
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,y.hostnum hostnum,'%(rundt_30_before_date)s' stat_time,sum(rmb) s
    from YBLog%(rundt)s y join Account using(domain,aid) where domain<>'' 
    and date(firstdate)='%(rundt_30_before_date)s'
    group by domain,y.hostnum ) b
    using(domain,hostnum,stat_time)
    set a.pay_30 = b.s
        """ % kv
        self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select '%(rundt_date)s' stat_time, domain ,hostnum, sum(rmb) s
    from YBLog%(rundt)s 
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.rmb_day = b.s;
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a join
    ( select '%(rundt_date)s' stat_time,domain,hostnum,rmb_sum s
    from stat_dashboard where stat_time='%(rundt_1_before_date)s' ) b
    using(domain,hostnum,stat_time)
    set a.rmb_sum = b.s;
        """ % kv
        self.dbi.run_sql(sql)   
        
        sql="""
    update stat_dashboard a
    set a.rmb_sum = a.rmb_sum + a.rmb_day
    where stat_time = '%(rundt_date)s';
        """ % kv
        self.dbi.run_sql(sql)   
        
   #     sql="""
   # update stat_dashboard a join
   # ( select '%(rundt_date)s' stat_time,domain,hostnum,count(distinct mac) s
   # from QuitLog%(rundt)s group by domain,hostnum ) b
   # using(domain,hostnum,stat_time)
   # set a.dau_device = b.s;
   #     """ % kv
   #     self.dbi.run_sql(sql)   

        sql="""
    update stat_dashboard a join
    ( select domain,hostnum,'%(rundt_date)s' stat_time,count(distinct lastmac) c
    from Account
    where domain<>'' and 
    lastdate>'%(rundt_date)s' and lastdate<'%(rundt_tomorrow_date)s'
    group by domain,hostnum ) b
    using(domain,hostnum,stat_time)
    set a.dau_device= b.c
        """ % kv
        self.dbi.run_sql(sql)   


   
    def _update_pay_(self,kv):
        sql="""
    delete from stat_pay where stat_time='%(rundt_date)s';
            """ % kv
    #    self.dbi.run_sql(sql)

        sql="""
    insert into stat_pay(domain,hostnum,stat_time,num)
    select domain,hostnum,'%(rundt_date)s',sum(rmb)
    from YBLog%(rundt)s where domain<>''
    group by domain,hostnum;
            """ % kv
    #    self.dbi.run_sql(sql)

    def _update_grade_(self,kv):
        sql="""
    delete from stat_grade where stat_time='%(rundt_date)s';
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
    insert into stat_grade(domain,hostnum,stat_time,lv,num)
    select domain,hostnum,'%(rundt_date)s',grade,count(*)
    from Account where domain<>'' and lastdate>'%(rundt_date)s'
    group by domain,hostnum,grade;
            """ % kv
        self.dbi.run_sql(sql)

    def update_account(self, kv):
        sql="""
insert ignore into 
Account(aid,name,domain,firstdate,firstmac,firstsys,firstdevice,firstos,lastdate,lastmac,lastsys,lastdevice,lastos,uid,hostnum,nickname,grade,exp,resid,vip,questid)
select aid,name,domain,logintm,mac,sys,device,os,logintm,mac,sys,device,os,uid,hostnum,nickname,grade,exp,resid,vip,questid 
from LoginLog%(rundt)s q where domain<>''
on duplicate key update
Account.name = q.name,
Account.firstdate = if(Account.firstdate<q.logintm,Account.firstdate,q.logintm),
Account.firstmac = if(Account.firstdate<q.logintm,Account.firstmac,q.mac),
Account.firstsys = if(Account.firstdate<q.logintm,Account.firstsys,q.sys),
Account.firstdevice = if(Account.firstdate<q.logintm,Account.firstdevice,q.device),
Account.firstos = if(Account.firstdate<q.logintm,Account.firstos,q.os),
Account.lastdate = if(Account.lastdate>q.logintm,Account.lastdate,q.logintm),
Account.lastmac = if(Account.lastdate>q.logintm,Account.lastmac,q.mac),
Account.lastsys = if(Account.lastdate>q.logintm,Account.lastsys,q.sys),
Account.lastdevice = if(Account.lastdate>q.logintm,Account.lastdevice,q.device),
Account.lastos = if(Account.lastdate>q.logintm,Account.lastos,q.os),
Account.uid = if(Account.exp>q.exp,Account.uid,q.uid),
Account.hostnum = if(Account.exp>q.exp,Account.hostnum,q.hostnum),
Account.nickname = if(Account.exp>q.exp,Account.nickname,q.nickname),
Account.grade = if(Account.exp>q.exp,Account.grade,q.grade),
Account.resid = if(Account.exp>q.exp,Account.resid,q.resid),
Account.exp = if(Account.exp>q.exp,Account.exp,q.exp),
Account.vip = if(Account.exp>q.exp,Account.vip,q.vip),
Account.questid = if(Account.exp>q.exp,Account.questid,q.questid);
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
insert ignore into 
Account(aid,name,domain,firstdate,firstmac,firstsys,firstdevice,firstos,lastdate,lastmac,lastsys,lastdevice,lastos,uid,hostnum,nickname,grade,exp,resid,vip,questid,step)
select aid,name,domain,logintm,mac,sys,device,os,logintm,mac,sys,device,os,uid,hostnum,nickname,grade,exp,resid,vip,questid,step 
from QuitLog%(rundt)s q where domain<>''
on duplicate key update
Account.name = q.name,
Account.firstdate = if(Account.firstdate<q.logintm,Account.firstdate,q.logintm),
Account.firstmac = if(Account.firstdate<q.logintm,Account.firstmac,q.mac),
Account.firstsys = if(Account.firstdate<q.logintm,Account.firstsys,q.sys),
Account.firstdevice = if(Account.firstdate<q.logintm,Account.firstdevice,q.device),
Account.firstos = if(Account.firstdate<q.logintm,Account.firstos,q.os),
Account.lastdate = if(Account.lastdate>q.quittm,Account.lastdate,q.quittm),
Account.lastmac = if(Account.lastdate>q.quittm,Account.lastmac,q.mac),
Account.lastsys = if(Account.lastdate>q.quittm,Account.lastsys,q.sys),
Account.lastdevice = if(Account.lastdate>q.logintm,Account.lastdevice,q.device),
Account.lastos = if(Account.lastdate>q.logintm,Account.lastos,q.os),
Account.uid = if(Account.exp>q.exp,Account.uid,q.uid),
Account.hostnum = if(Account.exp>q.exp,Account.hostnum,q.hostnum),
Account.nickname = if(Account.exp>q.exp,Account.nickname,q.nickname),
Account.grade = if(Account.exp>q.exp,Account.grade,q.grade),
Account.resid = if(Account.exp>q.exp,Account.resid,q.resid),
Account.exp = if(Account.exp>q.exp,Account.exp,q.exp),
Account.vip = if(Account.exp>q.exp,Account.vip,q.vip),
Account.questid = if(Account.exp>q.exp,Account.questid,q.questid),
Account.step = if(Account.step>q.step,Account.step,q.step);
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
insert ignore into Account(aid,name,domain,firstdate,lastdate)
select aid,name,domain,ctime,ctime
from NewAccount%(rundt)s;
            """ % kv
        self.dbi.run_sql(sql)

        sql="""
insert into Account(aid,domain,firstpay,lastpay)
select aid,domain,tradetm,tradetm
from YBLog%(rundt)s y
where rmb<>0
on duplicate key update
Account.firstpay = if(Account.firstpay<y.tradetm,Account.firstpay,y.tradetm),
Account.firstpaylv = if(Account.firstpaylv=0,Account.grade,Account.firstpaylv),
Account.lastpay = if(Account.firstpay>y.tradetm,Account.firstpay,y.tradetm);
            """ % kv
        self.dbi.run_sql(sql)
        
if __name__ == '__main__':
    from dbapi import DBApi
    from nuts_conf import conf
    dbi = DBApi(conf.get('dbi_conf'))
    dates = []
    dates.append('20120605')
    c=CalTimeGame(dbi,dates)
    c.cal('XYQ')
