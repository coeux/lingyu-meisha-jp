curl "http://checkip.dyndns.org/" 2>/dev/null|awk '{print $6}'|cut -d '<' -f1 
curl -s "http://checkip.dyndns.org/"|cut -f 6 -d" "|cut -f 1 -d"<"         
#w3m -dump http://submit.apnic.net/templates/yourip.html | grep -P -o '(\d+\.){3}\d+'      
curl -s "http://checkip.dyndns.org/"| sed 's/.*Address: \([0-9\.]*\).*/\1/g' 
curl -s "http://checkip.dyndns.org/"|cut -d "<" -f7|cut -c 26- 
#curl ifconfig.me        -----------重点推荐这个，实在是好记 
curl icanhazip.com    
