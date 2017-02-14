import os
import sys
import commands
import string

shell=sys.argv[1]
ip = sys.argv[2]
port = sys.argv[3]
num =  string.atoi(sys.argv[4])
seg =  string.atoi(sys.argv[5])
print(ip, port, num, seg)

for i in range(1, num):
    bmac = (i-1)*seg 
    emac = bmac + seg 

    pid = os.fork()
    cmd = shell+' '+ip+' '+port+' '+str(bmac)+' '+str(emac)
    print(cmd)
    os.system(cmd) 

    '''
    while True:
        s=commands.getoutputs('ps aux | grep simu_client')
        stat = s.split()
        print(stat[1], stat[7])
        time.sleep(30)
    '''
