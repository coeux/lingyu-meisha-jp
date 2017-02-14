insert into Bugchang (domain, name, totalpay)(select domain,uin name,sum(pay_rmb) totalpay from Pay where pay_rmb>0 group by uin);
